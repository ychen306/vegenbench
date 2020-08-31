#include "bench.h"
#include "kernels.h"
#include <iostream>

int main() {
  MAKE_BENCH(g722_apply_qmf).run<Vec<int16_t, 12 * 2>, Vec<int32_t, 2>>(std::cout);
  MAKE_BENCH(fft4).run<Vec<FFTComplex, 8>>(std::cout);
  MAKE_BENCH(fft8).run<Vec<FFTComplex, 8>>(std::cout);
}
