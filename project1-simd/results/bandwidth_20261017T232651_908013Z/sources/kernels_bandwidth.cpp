#include <cstddef>
// Two input streams and one ordinary (cached) output stream.
// No restrict promises or non-temporal stores; consistent with the multiply baseline.
template<class T>
void stream_add(const T* x, const T* y, T* z, std::size_t n) {
    for (std::size_t i = 0; i < n; ++i) z[i] = x[i] + y[i];
}
template void stream_add<float>(const float*, const float*, float*, std::size_t);
template void stream_add<double>(const double*, const double*, double*, std::size_t);
