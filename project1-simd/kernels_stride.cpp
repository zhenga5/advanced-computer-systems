#include <cstddef>

template <typename T>
void multiply_stride(const T* x, const T* y, T* z,
                     std::size_t n, std::size_t stride)
{
    for (std::size_t i = 0; i < n; ++i) {
        const std::size_t j = i * stride;
        z[j] = x[j] * y[j];
    }
}

template void multiply_stride<float>(
    const float*, const float*, float*,
    std::size_t, std::size_t);

template void multiply_stride<double>(
    const double*, const double*, double*,
    std::size_t, std::size_t);