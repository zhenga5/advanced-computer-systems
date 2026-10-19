// STREAM-like add calibration, independently implemented; not an official STREAM result.
#include <algorithm>
#include <chrono>
#include <cstddef>
#include <iomanip>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

template<class T> void stream_add(const T*, const T*, T*, std::size_t);
using Clock = std::chrono::steady_clock;

// Live T objects, with 64-byte alignment and guard elements on both sides.
template<class T> struct Buffer {
    std::vector<T> storage;
    T* data;
    explicit Buffer(std::size_t count) : storage(count + 64, T(-999)) {
        void* p = storage.data() + 16;
        std::size_t space = (storage.size() - 16) * sizeof(T);
        if (!std::align(64, count * sizeof(T), p, space))
            throw std::runtime_error("Alignment failed");
        data = static_cast<T*>(p);
    }
};

template<class T> double run(std::size_t n, std::size_t stride, bool measure) {
    const std::size_t span = n ? (n - 1) * stride + 1 : 0;
    Buffer<T> x(span), y(span), z(span);
    for (std::size_t j = 0; j < span; ++j) {
        x.data[j] = T(1 + j % 7);
        y.data[j] = T(1 + j % 5);
    }
    auto call = [&] { stream_add(x.data, y.data, z.data, n); };
    auto validate = [&] {
        double checksum = 0;
        for (std::size_t j = 0; j < span; ++j) {
            const bool touched = (j % stride == 0);
            const T expected = touched ? T((1 + j % 7) + (1 + j % 5)) : T(-999);
            if (z.data[j] != expected || x.data[j] != T(1 + j % 7) ||
                y.data[j] != T(1 + j % 5))
                throw std::runtime_error("Incorrect result or modified input/skipped element");
            if (touched) checksum += z.data[j];
        }
        for (auto* b : {&x, &y, &z}) {
            const auto start = static_cast<std::size_t>(b->data - b->storage.data());
            for (std::size_t j = 0; j < b->storage.size(); ++j)
                if ((j < start || j >= start + span) && b->storage[j] != T(-999))
                    throw std::runtime_error("Guard overwritten");
        }
        return checksum;
    };
    call();
    double checksum = validate();
    if (!measure) return checksum;
    auto batch = [&](std::size_t reps) {
        const auto begin = Clock::now();
        for (std::size_t r = 0; r < reps; ++r) call();
        return std::chrono::duration<double>(Clock::now() - begin).count();
    };
    std::size_t reps = 1;
    while (batch(reps) < 0.03 && reps < (1u << 24)) reps *= 2;
    std::vector<double> times;
    for (int trial = 0; trial < 7; ++trial) {
        call(); call();
        const double seconds = batch(reps) / double(reps);
        checksum = validate(); // Outside the timed region.
        times.push_back(seconds);
        const double useful_bytes = 3.0 * double(n) * sizeof(T);
        std::cout << (sizeof(T) == 4 ? "float" : "double") << ','
                  << n << ',' << stride << ',' << trial << ',' << reps << ','
                  << seconds << ',' << double(n) / seconds / 1e9 << ','
                  << 3 * span * sizeof(T) << ','
                  << useful_bytes / seconds / 1073741824.0 << ',' << checksum << '\n';
    }
    std::sort(times.begin(), times.end());
    std::cerr << (sizeof(T) == 4 ? "float" : "double") << " N=" << n
              << " stride=" << stride << ": median " << times[3] * 1e6
              << " microseconds/call; checks PASS\n";
    return checksum;
}

int main(int argc, char** argv) {
    try {
        if (argc == 2 && std::string(argv[1]) == "--check") {
            for (std::size_t s : {1u})
                for (std::size_t n : {0u, 1u, 5u, 8u, 16u, 17u, 27u, 32u, 33u, 1000u}) {
                    run<float>(n, s, false);
                    run<double>(n, s, false);
                }
            std::cout << "ALL BANDWIDTH CHECKS PASSED (float/double)\n";
            return 0;
        }
        if (argc != 2) throw std::runtime_error("Usage: bench_bandwidth N | --check");
        auto parse = [](const char* value) {
            const std::string text(value);
            if (text.empty() || text.find_first_not_of("0123456789") != std::string::npos)
                throw std::runtime_error("Arguments must be positive integers");
            return std::stoull(text);
        };
        const auto n = parse(argv[1]);
        const std::size_t s = 1;
        if (!n || n > 67108864ULL)
            throw std::runtime_error("Require 1<=N<=67108864");
        std::cout << std::setprecision(17)
                  << "datatype,n,stride,trial,repetitions,seconds_per_call,gflops,address_span_bytes,useful_gib_per_second,checksum\n";
        run<float>(n, s, true);
        run<double>(n, s, true);
    } catch (const std::exception& e) {
        std::cerr << "ERROR: " << e.what() << '\n';
        return 1;
    }
}
