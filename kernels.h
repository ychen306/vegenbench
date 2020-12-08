#ifndef KERNELS_H
#define KERNELS_H

#include <stddef.h>
#include <stdint.h>

struct FFTComplex {
  float re, im;
};

void fft8(FFTComplex *z);
void fft4(FFTComplex *z);
void sbc_analyze_4(const int16_t *__restrict__ in, int32_t *__restrict__ out,
                   const int16_t *__restrict__ consts);
void idct8(const int16_t *__restrict__ src, int16_t *__restrict__ dst);
void idct4(const int16_t *__restrict__ src, int16_t *__restrict__ dst);
void chroma_420_filter_vss_impl(const int16_t *src, intptr_t srcStride,
                                int16_t *dst, intptr_t dstStride, int coeffIdx);
void imdct36(float *__restrict__ out, float *__restrict__ buf,
             float *__restrict__ in, float *__restrict__ win);

void dot_i8_by_4(int8_t *a, int8_t *b, int32_t *c);
void dot_u8_by_4(uint8_t *a, uint8_t *b, uint32_t *c);
void dot_i32_by_2(int32_t *a, int32_t *b, int64_t *c);
void dot_i16_by_2(int16_t *a, int16_t *b, int32_t *c);

#endif // end KERNELS_H
