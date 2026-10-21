#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>
#include <sys/mman.h>
#include <pthread.h>
#include <sched.h>
using U=std::uint64_t;
using Clock=std::chrono::steady_clock;
U now_ns(){return std::chrono::duration_cast<std::chrono::nanoseconds>(Clock::now().time_since_epoch()).count();}
void pin(int cpu){cpu_set_t s;CPU_ZERO(&s);CPU_SET(cpu,&s);int e=pthread_setaffinity_np(pthread_self(),sizeof(s),&s);if(e)throw std::runtime_error(std::string("CPU affinity: ")+std::strerror(e));}
struct Memory {
 void* p;std::size_t bytes;
 explicit Memory(std::size_t b):bytes(b){p=mmap(nullptr,b,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(p==MAP_FAILED)throw std::runtime_error("mmap failed");if(madvise(p,b,MADV_NOHUGEPAGE)){munmap(p,b);throw std::runtime_error("madvise failed");}}
 ~Memory(){munmap(p,bytes);} Memory(const Memory&)=delete;
};
struct alignas(64) Node{Node* next;char pad[56];};
static_assert(sizeof(Node)==64);
struct alignas(64) Result{U bytes=0,checksum=0,excluded_chunks=0;};
__attribute__((noinline)) U stream(volatile U* a,std::size_t offset){
 U s[8]={};for(std::size_t j=0;j<8192;j+=8)for(int k=0;k<8;++k)s[k]+=a[offset+j+k];
 U total=0;for(U v:s)total+=v;return total;
}
std::size_t parse(const char* s,std::size_t lo,std::size_t hi){std::string t(s);if(t.empty()||t.find_first_not_of("0123456789")!=std::string::npos)throw std::runtime_error("Expected integer");auto n=std::stoull(t);if(n<lo||n>hi)throw std::runtime_error("Argument out of range");return n;}
int main(int argc,char** argv) try {
 if(argc!=5){std::cerr<<"Usage: loaded_latency LOAD_THREADS TRIALS SECONDS BUFFER_MIB\n";return 1;}
 const int n=parse(argv[1],0,7);const auto trials=parse(argv[2],1,20),seconds=parse(argv[3],1,30),mib=parse(argv[4],8,512);
 const std::size_t bytes=mib*1024*1024;
 pin(0);
 Memory probe(bytes);Node* nodes=static_cast<Node*>(probe.p);const auto count=bytes/64;
 {std::vector<std::uint32_t> order(count);std::iota(order.begin(),order.end(),0);std::mt19937 rng(42);std::shuffle(order.begin(),order.end(),rng);
 for(std::size_t i=0;i<count;++i)nodes[order[i]].next=&nodes[order[(i+1)%count]];}
 Node* ptr=nodes;for(std::size_t i=0;i<count;++i)ptr=ptr->next;asm volatile("":"+r"(ptr)::"memory");
 std::cout<<"load_threads,trial,probe_cpu,buffer_mib,load_read_percent,window_ns,load_bytes,load_GB_s,probe_loads,probe_elapsed_ns,probe_ns_per_load,excluded_load_chunks,probe_final_index\n";
 for(std::size_t trial=1;trial<=trials;++trial){
  std::atomic<int> ready{0};std::atomic<bool> go{false};U begin=0,end=0;
  std::vector<Result> results(n);std::vector<std::string> errors(n);std::vector<std::thread> workers;
  try {
   for(int t=0;t<n;++t)workers.emplace_back([&,t]{
    bool announced=false;
    try {
     pin(2*(t+1));Memory memory(bytes);volatile U* a=static_cast<volatile U*>(memory.p);
     for(std::size_t i=0;i<bytes/8;++i)a[i]=1;
     ready.fetch_add(1);announced=true;
     while(!go.load())std::this_thread::yield();
     std::size_t offset=0;U checksum=0,all_chunks=0,completed=0,excluded=0;
     U t0=now_ns();
     while(t0<end){
      checksum+=stream(a,offset);++all_chunks;
      const U t1=now_ns();
      if(t0>=begin && t1<=end)completed+=65536;else ++excluded;
      offset+=8192;if(offset==bytes/8)offset=0;
      t0=now_ns();
     }
     if(checksum!=all_chunks*8192)throw std::runtime_error("Worker checksum mismatch");
     results[t]={completed,checksum,excluded};
    }catch(const std::exception& e){errors[t]=e.what();if(!announced)ready.fetch_add(1);}
   });
  }catch(...){begin=end=0;go.store(true);for(auto& w:workers)w.join();throw;}
  while(ready.load()!=n)std::this_thread::yield();
  // Release/acquire publication of shared timestamps via go.
  begin=now_ns()+250000000;end=begin+seconds*1000000000ULL;go.store(true);
  U probe_loads=0,probe_time=0;
  U t0=now_ns();
  while(t0<end){
   for(int j=0;j<1024;++j)ptr=ptr->next;
   asm volatile("":"+r"(ptr)::"memory");
   const U t1=now_ns();
   if(t0>=begin && t1<=end){probe_loads+=1024;probe_time+=t1-t0;}
   t0=now_ns();
  }
  for(auto& w:workers)w.join();
  U total=0,excluded=0;for(int t=0;t<n;++t){if(!errors[t].empty())throw std::runtime_error(errors[t]);total+=results[t].bytes;excluded+=results[t].excluded_chunks;}
  if(!probe_loads)throw std::runtime_error("No probe samples");
  const auto address=reinterpret_cast<std::uintptr_t>(ptr),base=reinterpret_cast<std::uintptr_t>(nodes);
  if(address<base||address>=base+bytes||(address-base)%64)throw std::runtime_error("Invalid probe pointer");
  std::cout<<n<<','<<trial<<",0,"<<mib<<",100,"<<end-begin<<','<<total<<','<<std::fixed<<std::setprecision(6)
           <<double(total)/(end-begin)<<','<<probe_loads<<','<<probe_time<<','<<double(probe_time)/probe_loads<<','<<excluded<<','<<(address-base)/64<<'\n';
 }
}catch(const std::exception& e){std::cerr<<"Error: "<<e.what()<<'\n';return 1;}
