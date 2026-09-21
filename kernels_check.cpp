#include "kernels.hpp"
#include <array>
#include <cstddef>
#include <iostream>



template <typename T>
bool check_kernels(const char* datatype) {
    constexpr std::size_t n = 5;

    const std::array<T, n> x = {1, 2, 3, 4, 5};
    const std::array<T, n> y = {5, 4, 3, 2, 1};

    // AXPY changes its output, so give it a copy of y.
    auto axpy_result = y;
    axpy(T{2}, x.data(), axpy_result.data(), n);

    std::array<T, n> multiply_result{};
    multiply(x.data(), y.data(), multiply_result.data(), n);

    const T dot_result = dot(x.data(), y.data(), n);

    const std::array<T, n> expected_axpy = {7, 8, 9, 10, 11};
    const std::array<T, n> expected_multiply = {5, 8, 9, 8, 5};

    const bool axpy_ok = (axpy_result == expected_axpy);
    const bool multiply_ok = (multiply_result == expected_multiply);
    const bool dot_ok = (dot_result == T{35});

    std::cout << datatype << '\n';
    std::cout << "  AXPY: " << (axpy_ok ? "PASS" : "FAIL") << '\n';
    std::cout << "  Multiply: "
              << (multiply_ok ? "PASS" : "FAIL") << '\n';
    std::cout << "  Dot product: "
              << (dot_ok ? "PASS" : "FAIL") << '\n';

    return axpy_ok && multiply_ok && dot_ok;
}

int main() {
    const bool float_ok = check_kernels<float>("float");
    const bool double_ok = check_kernels<double>("double");

    return (float_ok && double_ok) ? 0 : 1;
}