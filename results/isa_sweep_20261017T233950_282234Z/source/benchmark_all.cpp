#include "kernels.hpp"
#include <algorithm>
#include <chrono>
#include <cmath>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

// Keep kernels in a separate translation unit and do not enable LTO.
enum class Kernel { multiply, axpy, dot };

template <typename T, Kernel K>
void measure(std::size_t n, const char* datatype, const char* name) {
    using Clock = std::chrono::steady_clock;
    std::vector<T> x(n), y(n), z(K == Kernel::multiply ? n : 0);
    long long dot_reference = 0;
    for (std::size_t i = 0; i < n; ++i) {
        const int xi = K == Kernel::dot ? int(i % 7) - 3 : 1 + int(i % 7);
        const int yi = 1 + int(i % 5);
        x[i] = T(xi);
        y[i] = T(yi);
        dot_reference += xi * yi;
    }
    // Signed dot inputs have zero sum over each 35-element period.
    // This keeps the reference bounded even for large float arrays.
    volatile T dot_sink = 0;
    auto batch = [&](std::size_t calls) {
        const auto start = Clock::now();
        if constexpr (K == Kernel::axpy) {
            // Two genuine AXPY calls restore y without a timed copy/reset.
            for (std::size_t r = 0; r < calls; r += 2) {
                axpy(T(0.5), x.data(), y.data(), n);
                axpy(T(-0.5), x.data(), y.data(), n);
            }
        } else {
            for (std::size_t r = 0; r < calls; ++r) {
                if constexpr (K == Kernel::multiply)
                    multiply(x.data(), y.data(), z.data(), n);
                else
                    dot_sink = dot(x.data(), y.data(), n);
            }
        }
        return std::chrono::duration<double>(Clock::now() - start).count();
    };
    auto validate = [&]() {
        double checksum = 0;
        if constexpr (K == Kernel::dot) {
            checksum = static_cast<T>(dot_sink);
            if (checksum != double(dot_reference))
                throw std::runtime_error("Dot validation failed");
        } else {
            for (std::size_t i = 0; i < n; ++i) {
                const T actual = K == Kernel::multiply ? z[i] : y[i];
                const T expected = K == Kernel::multiply
                    ? T((1 + i % 7) * (1 + i % 5)) : T(1 + i % 5);
                if (actual != expected)
                    throw std::runtime_error("Array validation failed");
                checksum += actual;
            }
        }
        return checksum;
    };
    // Check AXPY's intermediate result too: paired calls alone could hide errors.
    if constexpr (K == Kernel::axpy) {
        axpy(T(0.5), x.data(), y.data(), n);
        for (std::size_t i = 0; i < n; ++i)
            if (y[i] != T(1 + i % 5) + T(0.5) * T(1 + i % 7))
                throw std::runtime_error("AXPY intermediate validation failed");
        axpy(T(-0.5), x.data(), y.data(), n);
    }
    batch(2);
    validate();
    std::size_t calls = 2;
    while (true) {
        const double elapsed = batch(calls);
        validate();
        if (elapsed >= 0.030 || calls >= 16777216) break;
        calls *= 2;
    }
    std::vector<double> times;
    for (int trial = 1; trial <= 7; ++trial) {
        batch(2); // Warm-up outside the measured batch.
        const double seconds = batch(calls) / calls;
        const double checksum = validate();
        times.push_back(seconds);
        constexpr int arrays = K == Kernel::multiply ? 3 : 2;
        constexpr int flops = K == Kernel::multiply ? 1 : 2;
        // Useful bytes count reads/writes in the algorithm, not DRAM traffic.
        constexpr int streams = K == Kernel::dot ? 2 : 3;
        std::cout << name << ',' << datatype << ',' << n << ',' << trial
                  << ',' << calls << ',' << seconds << ','
                  << double(n) * flops / seconds / 1e9 << ','
                  << double(n) * arrays * sizeof(T) << ','
                  << double(n) * streams * sizeof(T) / seconds / (1ULL << 30)
                  << ',' << checksum << '\n';
    }
    std::sort(times.begin(), times.end());
    std::cerr << name << ' ' << datatype << ": median " << times[3] * 1e6
              << " microseconds/call\n";
}

template <typename T>
void dispatch(const std::string& kernel, std::size_t n, const char* datatype) {
    if (kernel == "multiply") measure<T, Kernel::multiply>(n, datatype, "multiply");
    else if (kernel == "axpy") measure<T, Kernel::axpy>(n, datatype, "axpy");
    else measure<T, Kernel::dot>(n, datatype, "dot");
}

int main(int argc, char** argv) {
    try {
        if (argc != 3) throw std::invalid_argument("Usage: bench_all MODE N; MODE = multiply, axpy, dot");
        const std::string kernel = argv[1], argument = argv[2];
        if (kernel != "multiply" && kernel != "axpy" && kernel != "dot")
            throw std::invalid_argument("Unknown kernel");
        if (argument.empty() || argument.find_first_not_of("0123456789") != std::string::npos)
            throw std::invalid_argument("N must contain only digits");
        const auto n = std::stoull(argument);
        if (n == 0 || n > 33554432) throw std::invalid_argument("Use N from 1 to 33554432");
        std::cout << std::setprecision(12)
                  << "kernel,datatype,n,trial,repetitions,seconds_per_call,gflops,working_set_bytes,useful_gib_per_second,checksum\n";
        dispatch<float>(kernel, n, "float");
        dispatch<double>(kernel, n, "double");
    } catch (const std::exception& e) {
        std::cerr << e.what() << '\n';
        return 1;
    }
}