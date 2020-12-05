#include "bench.h"
#include "kernels.h"
#include <iostream>
#include <sstream>
#include <string>

template <size_t SrcStride, size_t DstStride>
void chroma_420_filter_vss(int16_t *src, int16_t *dst) {
  chroma_420_filter_vss_impl(src, SrcStride, dst, DstStride, 1/*coeffIdx*/);
}

template <size_t SrcStride, size_t DstStride>
void bench_chroma_vert() __attribute__((always_inline)) {
  std::string benchName = "chroma_420_filter_vss(src-stride="+std::to_string(SrcStride) +
    ",dst-stride="+std::to_string(DstStride) + ")";
  Bench<decltype(chroma_420_filter_vss<SrcStride, DstStride>),
    chroma_420_filter_vss<SrcStride, DstStride>>(benchName).
    template run<Vec<int16_t, 4*4*SrcStride>, Vec<int16_t, 4*4*DstStride> >(std::cout);
}

int main() {
  MAKE_BENCH(fft4).run<Vec<FFTComplex, 4>>(std::cout);
  MAKE_BENCH(fft8).run<Vec<FFTComplex, 8>>(std::cout);
  MAKE_BENCH(sbc_analyze_4).run<Vec<int16_t, 64>, Vec<int32_t, 64>, Vec<int16_t, 64>>(std::cout);
  MAKE_BENCH(idct8).run<Vec<int16_t, 8*8>, Vec<int16_t, 8*8>>(std::cout);
  MAKE_BENCH(idct4).run<Vec<int16_t, 4*4>, Vec<int16_t, 4*4>>(std::cout);
  bench_chroma_vert<4, 4>();
  MAKE_BENCH(imdct36).run<Vec<float, 17*32+1>, Vec<float, 4*5>, Vec<float, 18>, Vec<float, 38>>(std::cout);
}
