#ifndef KERNELS_HPP
#define KERNELS_HPP

#include <cstddef>

template <typename T>
void axpy(T a, const T* x, T* y, std::size_t n);

template <typename T>
void multiply(const T* x, const T* y, T* z, std::size_t n);

template <typename T>
T dot(const T* x, const T* y, std::size_t n);

#endif