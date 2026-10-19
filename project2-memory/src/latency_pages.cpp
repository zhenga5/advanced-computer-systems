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

int main(int argc, char** argv) {
    if (argc != 2 ||
        (std::string(argv[1]) != "small" &&
         std::string(argv[1]) != "huge")) {
        std::cerr << "Usage: latency_pages small|huge\n";
        return 1;
    }
    const bool huge = std::string(argv[1]) == "huge";

    constexpr std::size_t steps = 8000000;
    const std::size_t sizes_kib[] = {4096, 8192, 16384, 32768, 65536, 98304, 131072, 524288};

    std::cout << "mode,huge_kib_before,huge_kib_after,size_kib,trial,loads,elapsed_ns,ns_per_load\n";

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

        for (int trial = 1; trial <= 5; ++trial) {
            const long before = huge_kib(allocation, bytes);
            const auto start = std::chrono::steady_clock::now();

            for (std::size_t i = 0; i < steps; ++i)
                p = p->next;

            // Keep the loads observable to the compiler.
            asm volatile("" : "+r"(p) : : "memory");
            const auto end = std::chrono::steady_clock::now();

            const double ns =
                std::chrono::duration<double, std::nano>(end - start).count();

            std::cout << (huge ? "huge" : "small") << ','
                      << before << ','
                      << huge_kib(allocation, bytes) << ',' << kib << ',' << trial << ',' << steps << ','
                      << std::fixed << std::setprecision(3)
                      << ns << ',' << ns / steps << '\n';
        }

        munmap(allocation, bytes);
    }
}
