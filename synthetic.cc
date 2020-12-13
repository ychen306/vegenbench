#include "bench.h"
#include "kernels.h"
#include <iostream>
#include <sstream>
#include <string>

int main() {
  MAKE_BENCH(test_maxpd).run<Vec<double, 4>, Vec<double, 4>, Vec<double, 4>>(std::cout);
  MAKE_BENCH(test_minpd).run<Vec<double, 4>, Vec<double, 4>, Vec<double, 4>>(std::cout);
  MAKE_BENCH(test_maxps).run<Vec<float, 8>, Vec<float, 8>, Vec<float, 8>>(std::cout);
  MAKE_BENCH(test_minps).run<Vec<float, 8>, Vec<float, 8>, Vec<float, 8>>(std::cout);

  MAKE_BENCH(test_fmaddsub_pd).run<Vec<double, 4>, Vec<double, 4>, Vec<double, 4>>(std::cout);
  MAKE_BENCH(test_fmaddsub_ps).run<Vec<float, 8>, Vec<float, 8>, Vec<float, 8>>(std::cout);

  MAKE_BENCH(test_abs_pd).run<Vec<double, 4>, Vec<double, 4>>(std::cout);
  MAKE_BENCH(test_abs_ps).run<Vec<float, 8>, Vec<float, 8>>(std::cout);
  MAKE_BENCH(test_abs_i8).run<Vec<int8_t, 32>, Vec<int8_t, 32>>(std::cout);
  MAKE_BENCH(test_abs_i16).run<Vec<int16_t, 16>, Vec<int16_t, 16>>(std::cout);
  MAKE_BENCH(test_abs_i32).run<Vec<int32_t, 8>, Vec<int32_t, 8>>(std::cout);

  MAKE_BENCH(test_haddpd).run<Vec<double, 4>, Vec<double, 4>, Vec<double, 4>>(std::cout);
  MAKE_BENCH(test_haddps).run<Vec<float, 8>, Vec<float, 8>, Vec<float, 8>>(std::cout);
  MAKE_BENCH(test_hsubpd).run<Vec<double, 4>, Vec<double, 4>, Vec<double, 4>>(std::cout);
  MAKE_BENCH(test_hsubps).run<Vec<float, 8>, Vec<float, 8>, Vec<float, 8>>(std::cout);
  MAKE_BENCH(test_hadd_i16).run<Vec<int16_t, 16>, Vec<int16_t, 16>, Vec<int16_t, 16>>(std::cout);
  MAKE_BENCH(test_hsub_i16).run<Vec<int16_t, 16>, Vec<int16_t, 16>, Vec<int16_t, 16>>(std::cout);
  MAKE_BENCH(test_hadd_i32).run<Vec<int32_t, 8>, Vec<int32_t, 8>, Vec<int32_t, 8>>(std::cout);
  MAKE_BENCH(test_hsub_i32).run<Vec<int32_t, 8>, Vec<int32_t, 8>, Vec<int32_t, 8>>(std::cout);

  MAKE_BENCH(test_pmaddubs).run<Vec<int8_t, 256>, Vec<uint8_t, 256>, Vec<int16_t, 64>>(std::cout);
  MAKE_BENCH(test_pmaddwd).run<Vec<int16_t, 128>, Vec<int16_t, 128>, Vec<int32_t, 64>>(std::cout);
}
