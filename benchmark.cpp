#include "kernels.hpp"

#include <algorithm>
#include <chrono>
#include <cstddef>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

template <typename T>
bool benchmark(std::size_t n, const char* datatype) {
    using Clock = std::chrono::steady_clock;

    std::vector<T> x(n), y(n), z(n);

    // Small, exactly representable inputs.
    for (std::size_t i = 0; i < n; ++i) {
        x[i] = static_cast<T>(1 + i % 7);
        y[i] = static_cast<T>(1 + i % 5);
    }

    // More repetitions for small arrays.
    const std::size_t repetitions = std::max<std::size_t>(
        4, std::min<std::size_t>(10000, 16777216 / n)
    );

    constexpr int trials = 7;
    std::vector<double> times;

    for (int trial = 0; trial < trials; ++trial) {
        // Warm up the kernel and touch the output before timing.
        multiply(x.data(), y.data(), z.data(), n);

        const auto start = Clock::now();

        for (std::size_t r = 0; r < repetitions; ++r) {
            multiply(x.data(), y.data(), z.data(), n);
        }

        const auto end = Clock::now();

        const double seconds =
            std::chrono::duration<double>(end - start).count();
        const double seconds_per_call = seconds / repetitions;
        times.push_back(seconds_per_call);

        // Validate and consume the output OUTSIDE the timed region.
        double checksum = 0;

        for (std::size_t i = 0; i < n; ++i) {
            const T expected =
                static_cast<T>((1 + i % 7) * (1 + i % 5));

            if (z[i] != expected) {
                std::cerr << "Validation failed at element " << i << '\n';
                return false;
            }

            checksum += static_cast<double>(z[i]);
        }

        // Multiplication performs one floating-point operation per element.
        const double gflops =
            static_cast<double>(n) / seconds_per_call / 1e9;

        std::cout << datatype << ',' << n << ','
                  << trial + 1 << ',' << repetitions << ','
                  << seconds_per_call << ',' << gflops << ','
                  << checksum << '\n';
    }

    std::sort(times.begin(), times.end());

    std::cerr << datatype << ": median "
              << times[trials / 2] * 1e6 << " microseconds/call\n";

    return true;
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " N\n";
        return 1;
    }

    try {
        const std::string argument = argv[1];

        if (argument.empty() ||
            argument.find_first_not_of("0123456789") != std::string::npos) {
            throw std::invalid_argument("N must contain only digits");
        }

        const auto parsed = std::stoull(argument);

        if (parsed == 0 || parsed > 33554432ULL) {
            throw std::invalid_argument("Use N from 1 to 33554432");
        }

        const auto n = static_cast<std::size_t>(parsed);

        std::cout << std::setprecision(12);
        std::cout << "datatype,n,trial,repetitions,seconds_per_call,"
                     "gflops,checksum\n";

        const bool float_ok = benchmark<float>(n, "float");
        const bool double_ok = benchmark<double>(n, "double");

        return float_ok && double_ok ? 0 : 1;
    } catch (const std::exception& error) {
        std::cerr << "Error: " << error.what() << '\n';
        return 1;
    }
}