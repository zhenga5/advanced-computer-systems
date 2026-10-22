#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>
#include <sys/mman.h>
#include <sys/resource.h>
struct Node {Node* next;};
std::size_t number(const char* s,std::size_t hi){std::string t(s);if(t.empty()||t.find_first_not_of("0123456789")!=std::string::npos)throw std::runtime_error("Expected positive integer");auto v=std::stoull(t);if(!v||v>hi)throw std::runtime_error("Argument out of range");return v;}
struct Memory{void* p;std::size_t size;explicit Memory(std::size_t n):size(n){p=mmap(nullptr,n,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(p==MAP_FAILED)throw std::runtime_error("mmap failed");if(madvise(p,n,MADV_NOHUGEPAGE)){munmap(p,n);throw std::runtime_error("madvise failed");}}~Memory(){munmap(p,size);}};
int main(int argc,char** argv)try{
 if(argc!=6)throw std::runtime_error("Usage: pattern_latency SPAN_MIB seq|random SPACING_BYTES TRIALS LOADS");
 const auto mib=number(argv[1],4096),spacing=number(argv[3],1024),trials=number(argv[4],20),loads=number(argv[5],1000000000);
 std::string pattern=argv[2];if((pattern!="seq"&&pattern!="random")||(spacing!=64&&spacing!=256&&spacing!=1024))throw std::runtime_error("Invalid pattern or spacing");
 const std::size_t bytes=mib*1024*1024,count=bytes/spacing;
 Memory memory(bytes);auto base=static_cast<char*>(memory.p);
 auto node=[&](std::size_t i){return reinterpret_cast<Node*>(base+i*spacing);};
 Node* first=nullptr;Node* expected=nullptr;
 {
  std::vector<std::uint32_t> order(count);std::iota(order.begin(),order.end(),0);
  if(pattern=="random"){std::mt19937_64 rng(42);std::shuffle(order.begin(),order.end(),rng);}
  for(std::size_t i=0;i<count;++i)node(order[i])->next=node(order[(i+1)%count]);
  first=node(order[0]);expected=node(order[loads%count]);
 } // Free the construction index before warmup and measurement.
 Node* p=first;
 for(std::size_t i=0;i<count;++i)p=p->next;
 asm volatile("":"+r"(p)::"memory");
 if(p!=first)throw std::runtime_error("Warmup cycle validation failed");
 std::cout<<"pattern,span_mib,spacing_bytes,nodes,cacheline_footprint_bytes,trial,loads,elapsed_ns,ns_per_load,minor_faults,major_faults,final_offset_bytes\n";
 for(std::size_t trial=1;trial<=trials;++trial){
  p=first;rusage before{},after{};getrusage(RUSAGE_SELF,&before);
  auto start=std::chrono::steady_clock::now();
  for(std::size_t i=0;i<loads;++i)p=p->next;
  asm volatile("":"+r"(p)::"memory");
  auto end=std::chrono::steady_clock::now();getrusage(RUSAGE_SELF,&after);
  if(p!=expected)throw std::runtime_error("Final pointer validation failed");
  double ns=std::chrono::duration<double,std::nano>(end-start).count();
  std::cout<<pattern<<','<<mib<<','<<spacing<<','<<count<<','<<count*64<<','<<trial<<','<<loads<<','<<std::fixed<<std::setprecision(6)<<ns<<','<<ns/loads<<','<<after.ru_minflt-before.ru_minflt<<','<<after.ru_majflt-before.ru_majflt<<','<<reinterpret_cast<char*>(p)-base<<'\n';
 }
}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}
