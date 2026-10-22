#include <algorithm>
#include <chrono>
#include <cstdint>
#include <iostream>
#include <iomanip>
#include <string>
#include <sys/mman.h>
#include <sys/resource.h>
#include <linux/perf_event.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <stdexcept>
#include <cerrno>
#include <cstring>
#include <limits>

struct Counts { std::uint64_t nr, enabled, running, values[2]; };
class Counters {
    int fds[2] = {-1, -1};
    bool active;
public:
    explicit Counters(const std::string& kind): active(kind != "none") {
        if (!active) return;
        for (int i=0; i<2; ++i) {
            perf_event_attr a{};
            a.size=sizeof(a); a.disabled=1;
            a.exclude_kernel=1; a.exclude_hv=1;
            a.read_format=PERF_FORMAT_GROUP | PERF_FORMAT_TOTAL_TIME_ENABLED |
                          PERF_FORMAT_TOTAL_TIME_RUNNING;
            if (kind=="tlb") {
                a.type=PERF_TYPE_HW_CACHE;
                a.config=PERF_COUNT_HW_CACHE_DTLB |
                    (std::uint64_t(PERF_COUNT_HW_CACHE_OP_READ)<<8) |
                    (std::uint64_t(i ? PERF_COUNT_HW_CACHE_RESULT_MISS :
                                      PERF_COUNT_HW_CACHE_RESULT_ACCESS)<<16);
            } else {
                a.type=PERF_TYPE_HARDWARE;
                a.config=kind=="cache" ?
                    (i ? PERF_COUNT_HW_CACHE_MISSES : PERF_COUNT_HW_CACHE_REFERENCES) :
                    (i ? PERF_COUNT_HW_INSTRUCTIONS : PERF_COUNT_HW_CPU_CYCLES);
            }
            fds[i]=syscall(SYS_perf_event_open,&a,0,-1,i ? fds[0] : -1,
                           PERF_FLAG_FD_CLOEXEC);
            if (fds[i]<0) {
                const std::string error=std::strerror(errno);
                if (fds[0]>=0) close(fds[0]);
                throw std::runtime_error("perf_event_open ("+kind+"): "+error);
            }
        }
    }
    ~Counters() { for (int fd:fds) if(fd>=0) close(fd); }
    void enable(bool on) {
        if(active && ioctl(fds[0],on ? PERF_EVENT_IOC_ENABLE : PERF_EVENT_IOC_DISABLE,
                           PERF_IOC_FLAG_GROUP)<0)
            throw std::runtime_error("perf ioctl failed");
    }
    Counts read_counts() {
        Counts c{};
        if(active && (::read(fds[0],&c,sizeof(c))!=sizeof(c) || c.nr!=2))
            throw std::runtime_error("perf group read failed");
        return c;
    }
};
std::size_t number(const char* text, std::size_t max) {
    std::string s(text); std::size_t used=0;
    if(s.empty() || s.find_first_not_of("0123456789")!=std::string::npos)
        throw std::runtime_error("Expected positive integer");
    auto n=std::stoull(s,&used);
    if(used!=s.size() || !n || n>max) throw std::runtime_error("Argument out of range");
    return n;
}


using Clock=std::chrono::steady_clock;
struct Memory {
 void* p;std::size_t bytes;
 explicit Memory(std::size_t b):bytes(b){p=mmap(nullptr,b,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(p==MAP_FAILED)throw std::runtime_error("mmap failed");if(madvise(p,b,MADV_NOHUGEPAGE))throw std::runtime_error("madvise failed");}
 ~Memory(){munmap(p,bytes);}
};
__attribute__((noinline)) void init(double* x,double* y,std::size_t n){for(std::size_t i=0;i<n;++i){x[i]=1;y[i]=2;}asm volatile("":::"memory");}
__attribute__((noinline)) void axpy(const double* __restrict x,double* __restrict y,std::size_t n){for(std::size_t i=0;i<n;++i)y[i]=0.5*x[i]+y[i];asm volatile("":::"memory");}
int main(int argc,char** argv)try{
 if(argc!=5)throw std::runtime_error("Usage: axpy_memory SIZE_KIB steady|prepared|setup_inclusive TRIALS cache|none");
 auto kib=number(argv[1],524288),trials=number(argv[3],20);std::string mode=argv[2],kind=argv[4];
 if(kib%8 || (mode!="steady"&&mode!="prepared"&&mode!="setup_inclusive") || (kind!="cache"&&kind!="none"))throw std::runtime_error("Invalid arguments");
 std::size_t bytes=kib*1024,n=bytes/16;
 std::size_t passes=mode=="steady"?std::max<std::size_t>(1,(2ULL*1024*1024*1024)/bytes):1;
 Counters counters(kind);
 std::cout<<"mode,size_kib,trial,elements,passes,elapsed_ns,ns_per_element,useful_GB_s,cache_references_raw,cache_misses_raw,time_enabled_ns,time_running_ns,running_fraction,minor_faults,major_faults,checksum,counter_set\n";
 for(std::size_t trial=1;trial<=trials;++trial){
  Memory mem(bytes);double* x=static_cast<double*>(mem.p);double* y=x+n;
  if(mode!="setup_inclusive")init(x,y,n);
  if(mode=="steady")axpy(x,y,n);
  rusage r0{},r1{};getrusage(RUSAGE_SELF,&r0);auto c0=counters.read_counts();counters.enable(true);
  auto start=Clock::now();
  if(mode=="setup_inclusive")init(x,y,n);
  for(std::size_t j=0;j<passes;++j)axpy(x,y,n);
  asm volatile("mfence":::"memory");
  auto stop=Clock::now();counters.enable(false);auto c1=counters.read_counts();getrusage(RUSAGE_SELF,&r1);
  double elapsed=std::chrono::duration<double,std::nano>(stop-start).count();
  double expected=2+0.5*(passes+(mode=="steady"?1:0)),checksum=0;
  for(std::size_t i=0;i<n;++i){if(x[i]!=1||y[i]!=expected)throw std::runtime_error("Validation failed");checksum+=y[i];}
  auto enabled=c1.enabled-c0.enabled,running=c1.running-c0.running;
  if(kind!="none"&&!running)throw std::runtime_error("Counters did not run");
  std::cout<<mode<<','<<kib<<','<<trial<<','<<n<<','<<passes<<','<<std::fixed<<std::setprecision(6)<<elapsed<<','<<elapsed/(n*passes)<<','<<double(n*passes*24)/elapsed<<','<<c1.values[0]-c0.values[0]<<','<<c1.values[1]-c0.values[1]<<','<<enabled<<','<<running<<','<<(enabled?double(running)/enabled:0)<<','<<r1.ru_minflt-r0.ru_minflt<<','<<r1.ru_majflt-r0.ru_majflt<<','<<checksum<<','<<kind<<'\n';
 }
}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}
