#include "kernels.hpp"

template <typename T>
void axpy(T a, const T* x, T* y, std::size_t n) {
    for (std::size_t i = 0; i < n; ++i) {
        y[i] = a * x[i] + y[i];
    }
}

template <typename T>
void multiply(const T* x, const T* y, T* z, std::size_t n) {
    for (std::size_t i = 0; i < n; ++i) {
        z[i] = x[i] * y[i];
    }
}

template <typename T>
T dot(const T* x, const T* y, std::size_t n) {
    T sum = 0;
    for (std::size_t i = 0; i < n; ++i) {
        sum += x[i] * y[i];
    }
    return sum;
}

// Generate compiled versions for float and double.
template void axpy<float>(
    float, const float*, float*, std::size_t);
template void axpy<double>(
    double, const double*, double*, std::size_t);

template void multiply<float>(
    const float*, const float*, float*, std::size_t);
template void multiply<double>(
    const double*, const double*, double*, std::size_t);

template float dot<float>(
    const float*, const float*, std::size_t);
template double dot<double>(
    const double*, const double*, std::size_t);