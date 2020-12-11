#include "bench.h"
#include "kernels.h"
#include <iostream>
#include <sstream>
#include <string>

int main() {
  MAKE_BENCH(dot_u8_by_4).run<Vec<uint8_t, 32>, Vec<uint8_t, 32>, Vec<uint32_t, 8>>(std::cout);
  MAKE_BENCH(dot_i8_by_4).run<Vec<int8_t, 32>, Vec<int8_t, 32>, Vec<int32_t, 8>>(std::cout);
  MAKE_BENCH(dot_i32_by_2).run<Vec<int32_t, 8>, Vec<int32_t, 8>, Vec<int64_t, 4>>(std::cout);
  MAKE_BENCH(dot_i16_by_2).run<Vec<int16_t, 16>, Vec<int16_t, 16>, Vec<int32_t, 8>>(std::cout);
}
