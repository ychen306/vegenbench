#include "bench.h"
#include <iostream>

extern void g722_apply_qmf(const int16_t *__restrict__ prev_samples, int *__restrict__ xout);

int main() {
  MAKE_BENCH(g722_apply_qmf).run<Vec<int16_t, 12 * 2>, Vec<int32_t, 2>>(std::cout);
}
