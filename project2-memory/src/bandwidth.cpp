#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>
#include <sys/mman.h>
#include <immintrin.h>
#include <cmath>

using Clock=std::chrono::steady_clock;
using U=std::uint64_t;
constexpr U written=12345;
std::size_t positive(const char* text,std::size_t limit) {
    std::string s(text);
    if(s.empty() || s.find_first_not_of("0123456789")!=std::string::npos)
        throw std::runtime_error("Expected positive integer");
    const auto v=std::stoull(s);
    if(!v || v>limit) throw std::runtime_error("Argument out of range");
    return v;
}

// 10 distinct cache-line operations per group: R reads and 10-R writes.
// Volatile guarantees each requested scalar access is executed.
template<int R, bool Random>
__attribute__((noinline)) U kernel(volatile U* data,const std::uint32_t* order,
                                  std::size_t blocks,std::size_t stride_words) {
    U sums[8]={};
    for(std::size_t base=0;base<blocks;base+=10) {
        for(int j=0;j<10;++j) {
            const std::size_t pos=base+j;
            const std::size_t slot=Random ? order[pos] : pos;
            volatile U* line=data+slot*stride_words;
            for(int w=0;w<8;++w) {
                if(j<R) sums[w]+=line[w];
                else line[w]=written;
            }
        }
    }
    U total=0; for(U s:sums) total+=s;
    return total;
}
using Kernel=U(*)(volatile U*,const std::uint32_t*,std::size_t,std::size_t);
template<bool Random> Kernel choose(int reads) {
    switch(reads) {
        case 10:return kernel<10,Random>;
        case 7:return kernel<7,Random>;
        case 5:return kernel<5,Random>;
        case 0:return kernel<0,Random>;
    }
    throw std::runtime_error("READ_PERCENT must be 0, 50, 70, or 100");
}

int main(int argc,char** argv) try {
    if(argc!=6) {
        std::cerr<<"Usage: bandwidth SPAN_MIB seq|random STRIDE_BYTES READ_PERCENT TRIALS\n";
        return 1;
    }
    const auto mib=positive(argv[1],4096), stride=positive(argv[3],1024);
    const std::string pattern=argv[2], ratio=argv[4];
    if(pattern!="seq" && pattern!="random") throw std::runtime_error("Bad pattern");
    if(stride!=64 && stride!=256 && stride!=1024) throw std::runtime_error("Bad stride");
    if(ratio!="0" && ratio!="50" && ratio!="70" && ratio!="100")
        throw std::runtime_error("Bad read percentage");
    const int reads=std::stoi(ratio)/10;
    const auto trials=positive(argv[5],20), bytes=mib*1024*1024;
    const auto blocks=(bytes/stride)/10*10; // exact read/write mix
    const auto touched=blocks*64;
    const bool random=pattern=="random";
    Kernel fn=random ? choose<true>(reads) : choose<false>(reads);
    void* allocation=mmap(nullptr,bytes,PROT_READ|PROT_WRITE,
                           MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(allocation==MAP_FAILED) {perror("mmap");return 1;}
    if(madvise(allocation,bytes,MADV_NOHUGEPAGE)) {perror("madvise");return 1;}
    volatile U* data=static_cast<volatile U*>(allocation);
    for(std::size_t i=0;i<bytes/sizeof(U);++i) data[i]=1;
    std::vector<std::uint32_t> order;
    if(random) {
        order.resize(blocks);std::iota(order.begin(),order.end(),0);
        std::mt19937 rng(42);std::shuffle(order.begin(),order.end(),rng);
    }
    const U expected=U(blocks/10)*reads*8;
    auto one_pass=[&]() {return fn(data,order.data(),blocks,stride/8);};
    const auto p0=Clock::now();
    const U warm=one_pass();
    _mm_mfence();
    const double pilot=std::chrono::duration<double>(Clock::now()-p0).count();
    if(warm!=expected) throw std::runtime_error("Warm-up checksum mismatch");
    const auto passes=std::size_t(std::clamp(std::ceil(.25/std::max(pilot,1e-9)),1.0,10000.0));
    std::cout<<"pattern,span_mib,stride_bytes,read_percent,trial,blocks,touched_line_bytes,index_bytes,passes,read_bytes,write_bytes,elapsed_ns,useful_GB_s,ns_per_block,checksum\n";
    for(std::size_t trial=1;trial<=trials;++trial) {
        U checksum=0;
        asm volatile("" ::: "memory");
        const auto start=Clock::now();
        for(std::size_t p=0;p<passes;++p) checksum+=one_pass();
        _mm_mfence(); // drain stores before ending timing (not DRAM writeback)
        const auto end=Clock::now();
        if(checksum!=expected*passes) throw std::runtime_error("Read checksum mismatch");
        const double ns=std::chrono::duration<double,std::nano>(end-start).count();
        const U read_bytes=U(blocks/10)*reads*64*passes;
        const U write_bytes=U(blocks/10)*(10-reads)*64*passes;
        std::cout<<pattern<<','<<mib<<','<<stride<<','<<reads*10<<','<<trial<<','
                 <<blocks<<','<<touched<<','<<order.size()*sizeof(std::uint32_t)<<','
                 <<passes<<','<<read_bytes<<','<<write_bytes<<','<<std::fixed
                 <<std::setprecision(3)<<ns<<','<<std::setprecision(6)
                 <<double(read_bytes+write_bytes)/ns<<','<<ns/(double(blocks)*passes)<<','
                 <<checksum<<'\n';
    }
    // Verify every selected word, outside all measurements.
    for(std::size_t pos=0;pos<blocks;++pos) {
        const auto slot=random ? std::size_t(order[pos]) : pos;
        const U wanted=int(pos%10)<reads ? 1 : written;
        for(int w=0;w<8;++w)
            if(data[slot*(stride/8)+w]!=wanted) throw std::runtime_error("Store validation failed");
    }
    munmap(allocation,bytes);
    return 0;
} catch(const std::exception& e) {std::cerr<<"Error: "<<e.what()<<'\n';return 1;}
