#include "kernels.hpp"

#include <array>
#include <cstddef>
#include <iostream>
#include <vector>

template <typename T>
bool check_kernels(const char* datatype) {
    constexpr std::array<std::size_t, 10> sizes = {
        0, 1, 5, 8, 16, 17, 27, 32, 33, 1000
    };

    bool all_ok = true;
    std::cout << datatype << '\n';

    for (std::size_t n : sizes) {
        std::vector<T> x(n);
        std::vector<T> y(n);
        std::vector<T> z(n, T{-999});
        std::vector<T> expected_axpy(n);
        std::vector<T> expected_multiply(n);

        // Calculate reference answers using integer arithmetic.
        long long expected_dot = 0;

        for (std::size_t i = 0; i < n; ++i) {
            const int xi = static_cast<int>(i % 7) - 3;
            const int yi = static_cast<int>(i % 5) - 2;

            x[i] = static_cast<T>(xi);
            y[i] = static_cast<T>(yi);

            expected_axpy[i] = static_cast<T>(2 * xi + yi);
            expected_multiply[i] = static_cast<T>(xi * yi);
            expected_dot += xi * yi;
        }

        auto axpy_result = y;

        axpy(T{2}, x.data(), axpy_result.data(), n);
        multiply(x.data(), y.data(), z.data(), n);
        const T dot_result = dot(x.data(), y.data(), n);

        const bool axpy_ok = (axpy_result == expected_axpy);
        const bool multiply_ok = (z == expected_multiply);
        const bool dot_ok =
            (dot_result == static_cast<T>(expected_dot));

        std::cout << "  N=" << n
                  << "  AXPY=" << (axpy_ok ? "PASS" : "FAIL")
                  << "  Multiply=" << (multiply_ok ? "PASS" : "FAIL")
                  << "  Dot=" << (dot_ok ? "PASS" : "FAIL")
                  << '\n';

        all_ok = all_ok && axpy_ok && multiply_ok && dot_ok;
    }

    return all_ok;
}

int main() {
    const bool float_ok = check_kernels<float>("float");
    const bool double_ok = check_kernels<double>("double");
    const bool all_ok = float_ok && double_ok;

    std::cout << (all_ok ? "ALL CHECKS PASSED\n" : "CHECKS FAILED\n");
    return all_ok ? 0 : 1;
}