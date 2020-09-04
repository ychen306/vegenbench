#include "bench.h"
#include "kernels.h"
#include <iostream>
#include <sstream>
#include <string>

template <size_t Stride>
void idct_add(uint8_t *dst, int16_t *block) {
  return idct_add_impl(dst, block, Stride);
}

template <size_t Stride>
void bench_idct() {
  std::string benchName = "idct_add(stride="+std::to_string(Stride)+")";
  Bench<decltype(idct_add<Stride>), idct_add<Stride>>(benchName).
    template run<Vec<uint8_t, 4*4*Stride>, Vec<int16_t, 4*4*Stride>>(std::cout);
}

void partialButterfly(int16_t *a, int16_t *b) {
  return partialButterfly8(a, b, 0);
}

int main() {
  MAKE_BENCH(g722_apply_qmf).run<Vec<int16_t, 12 * 2>, Vec<int32_t, 2>>(std::cout);
  MAKE_BENCH(fft4).run<Vec<FFTComplex, 4>>(std::cout);
  MAKE_BENCH(fft8).run<Vec<FFTComplex, 8>>(std::cout);
  //bench_idct<1>();
  bench_idct<4>();
  //bench_idct<8>();
  //bench_idct<16>();
  MAKE_BENCH(sbc_analyze_4).run<Vec<int16_t, 64>, Vec<int32_t, 64>, Vec<int16_t, 64>>(std::cout);
  MAKE_BENCH(partialButterfly).run<Vec<int16_t, 8*8>, Vec<int16_t, 8*8>>(std::cout);
}
