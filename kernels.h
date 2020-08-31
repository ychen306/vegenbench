#ifndef KERNELS_H
#define KERNELS_H

#include <stdint.h>

extern void g722_apply_qmf(const int16_t *__restrict__ prev_samples, int *__restrict__ xout);

struct FFTComplex {
  float re, im;
};

void fft8(FFTComplex *z);
void fft4(FFTComplex *z);


void idct_add_impl(uint8_t *__restrict__ _dst, int16_t *__restrict__ _block, int stride);

#endif // end KERNELS_H
