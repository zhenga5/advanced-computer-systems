#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <vector>
#include <sys/mman.h>

struct alignas(64) Node {
    Node* next;
    char padding[64 - sizeof(Node*)];
};
static_assert(sizeof(Node) == 64);


#include <fstream>
#include <string>
#include <cstdio>

// Read huge-page backing for the mapping containing this allocation.
// Return -1 if its exact boundaries cannot be verified.
long huge_kib(void* allocation, std::size_t bytes) {
    std::ifstream file("/proc/self/smaps");
    std::string line;
    const auto target = reinterpret_cast<std::uintptr_t>(allocation);
    bool exact = false;
    while (std::getline(file, line)) {
        unsigned long begin, end;
        if (std::sscanf(line.c_str(), "%lx-%lx", &begin, &end) == 2) {
            exact = begin == target && end == target + bytes;
        } else if (exact) {
            long value;
            if (std::sscanf(line.c_str(), "AnonHugePages: %ld kB",
                            &value) == 1)
                return value;
        }
    }
    return -1;
}


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

int main(int argc, char** argv) try {

    if (argc < 3 || argc > 6) {
        std::cerr << "Usage: latency_counters small|huge SIZE_KIB [tlb|cache|core|none] [TRIALS] [LOADS]\n";
        return 1;
    }
    const std::string mode=argv[1], kind=argc>3 ? argv[3] : "tlb";
    if((mode!="small" && mode!="huge") ||
       (kind!="tlb" && kind!="cache" && kind!="core" && kind!="none"))
        throw std::runtime_error("Invalid mode or counter set");
    const bool huge=mode=="huge";
    const std::size_t size=number(argv[2],1048576);
    if(size%4) throw std::runtime_error("SIZE_KIB must be a multiple of 4");
    const std::size_t trials=argc>4 ? number(argv[4],100) : 5;
    const std::size_t steps=argc>5 ? number(argv[5],1000000000) : 8000000;
    const std::size_t sizes_kib[]={size};
    Counters counters(kind);
    std::cout << "mode,huge_kib_before,huge_kib_after,size_kib,trial,loads,elapsed_ns,ns_per_load,counter_set,event1_raw,event2_raw,time_enabled_ns,time_running_ns,running_fraction\n";
    for (std::size_t kib : sizes_kib) {
        const std::size_t bytes = kib * 1024;
        const std::size_t count = bytes / sizeof(Node);

        void* allocation = mmap(nullptr, bytes, PROT_READ | PROT_WRITE,
                                MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (allocation == MAP_FAILED) {
            perror("mmap");
            return 1;
        }

        // Use ordinary pages for this baseline.
        if (madvise(allocation, bytes, huge ? MADV_HUGEPAGE : MADV_NOHUGEPAGE) != 0) {
            perror("madvise");
            munmap(allocation, bytes);
            return 1;
        }

        Node* nodes = static_cast<Node*>(allocation);

        {
            std::vector<std::size_t> order(count);
            std::iota(order.begin(), order.end(), 0);
            std::mt19937_64 generator(42);
            std::shuffle(order.begin(), order.end(), generator);

            // One cycle visits every node exactly once.
            for (std::size_t i = 0; i < count; ++i) {
                nodes[order[i]].next = &nodes[order[(i + 1) % count]];
            }
        }

        Node* p = &nodes[0];

        // Touch the full chain before timing: exclude initial page faults.
        for (std::size_t i = 0; i < count; ++i)
            p = p->next;
        asm volatile("" : "+r"(p) : : "memory");

        for (std::size_t trial = 1; trial <= trials; ++trial) {
            const long before = huge_kib(allocation, bytes);
            const Counts c0=counters.read_counts();
            counters.enable(true);
            const auto start = std::chrono::steady_clock::now();

            for (std::size_t i = 0; i < steps; ++i)
                p = p->next;

            // Keep the loads observable to the compiler.
            asm volatile("" : "+r"(p) : : "memory");
            const auto end = std::chrono::steady_clock::now();

            counters.enable(false);
            const Counts c1=counters.read_counts();
            const auto enabled=c1.enabled-c0.enabled, running=c1.running-c0.running;
            if(kind!="none" && (!enabled || !running))
                throw std::runtime_error("Counters did not run; no valid sample");
            const double ns =
                std::chrono::duration<double, std::nano>(end - start).count();

            std::cout << (huge ? "huge" : "small") << ','
                      << before << ','
                      << huge_kib(allocation, bytes) << ',' << kib << ',' << trial << ',' << steps << ','
                      << std::fixed << std::setprecision(3)
                      << ns << ',' << ns / steps << ',' << kind << ','
                      << c1.values[0]-c0.values[0] << ','
                      << c1.values[1]-c0.values[1] << ','
                      << enabled << ',' << running << ',';
            if (enabled) std::cout << std::setprecision(6) << double(running)/enabled;
            else std::cout << "NA";
            std::cout << '\n';
        }

        munmap(allocation, bytes);
    }
}

catch(const std::exception& e) { std::cerr << "Error: " << e.what() << "\n"; return 1; }
