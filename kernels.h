#ifndef KERNELS_H
#define KERNELS_H

#include <stdint.h>
#include <stddef.h>

extern void g722_apply_qmf(const int16_t *__restrict__ prev_samples, int *__restrict__ xout);

struct FFTComplex {
  float re, im;
};

void fft8(FFTComplex *z);
void fft4(FFTComplex *z);
void fft15(FFTComplex *__restrict__ out, FFTComplex *__restrict__ in, FFTComplex *__restrict__ exptab, ptrdiff_t stride);

void idct_add_impl(uint8_t *__restrict__ _dst, int16_t *__restrict__ _block, int stride);

void sbc_analyze_4(const int16_t *__restrict__ in,
    int32_t *__restrict__ out, const int16_t *__restrict__ consts);

void idct8(const int16_t *__restrict__ src, int16_t *__restrict__ dst);
void idct4(const int16_t *__restrict__ src, int16_t *__restrict__ dst);
void idct8_partial(const int16_t* __restrict__ src,
    int* __restrict__ E0, int* __restrict__ E1, int* __restrict__ E2, int *__restrict__ E3,
    int* __restrict__ O0, int* __restrict__ O1, int* __restrict__ O2, int *__restrict__ O3
    );

void chroma_420_filter_vss_impl(const int16_t* src, intptr_t srcStride, int16_t* dst, intptr_t dstStride, int coeffIdx);


void imdct36(float *__restrict__ out, float *__restrict__ buf, float *__restrict__ in, float *__restrict__ win);

void matmul_int16(int16_t **dst, int16_t **mat1, int16_t **mat2,
                  uint64_t dst_r, uint64_t dst_c, uint64_t mat1_r, uint64_t mat1_c, uint64_t mat2_r, uint64_t mat2_c);
void matmul_float(float **dst, float **mat1, float **mat2,
                  uint64_t dst_r, uint64_t dst_c, uint64_t mat1_r, uint64_t mat1_c, uint64_t mat2_r, uint64_t mat2_c);
void matmul_double(double **dst, double **mat1, double **mat2,
                  uint64_t dst_r, uint64_t dst_c, uint64_t mat1_r, uint64_t mat1_c, uint64_t mat2_r, uint64_t mat2_c);
void matmul_uint8(uint8_t **dst, uint8_t **mat1, uint8_t **mat2,
                  uint64_t dst_r, uint64_t dst_c, uint64_t mat1_r, uint64_t mat1_c, uint64_t mat2_r, uint64_t mat2_c);
void matmul_int32(int32_t **dst, int32_t **mat1, int32_t **mat2,
                  uint64_t dst_r, uint64_t dst_c, uint64_t mat1_r, uint64_t mat1_c, uint64_t mat2_r, uint64_t mat2_c);
void matmul_int64(int64_t **dst, int64_t **mat1, int64_t **mat2,
                  uint64_t dst_r, uint64_t dst_c, uint64_t mat1_r, uint64_t mat1_c, uint64_t mat2_r, uint64_t mat2_c);

#endif // end KERNELS_H
