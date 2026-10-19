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

int main() {
    constexpr std::size_t steps = 8000000;
    const std::size_t sizes_kib[] = {16, 512, 32768, 524288};

    std::cout << "size_kib,trial,loads,elapsed_ns,ns_per_load\n";

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
        if (madvise(allocation, bytes, MADV_NOHUGEPAGE) != 0) {
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
            const auto start = std::chrono::steady_clock::now();

            for (std::size_t i = 0; i < steps; ++i)
                p = p->next;

            // Keep the loads observable to the compiler.
            asm volatile("" : "+r"(p) : : "memory");
            const auto end = std::chrono::steady_clock::now();

            const double ns =
                std::chrono::duration<double, std::nano>(end - start).count();

            std::cout << kib << ',' << trial << ',' << steps << ','
                      << std::fixed << std::setprecision(3)
                      << ns << ',' << ns / steps << '\n';
        }

        munmap(allocation, bytes);
    }
}
