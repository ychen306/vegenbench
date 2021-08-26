#include "bench.h"
#include "kernels.h"
#include <iostream>
#include <sstream>
#include <string>
#include <random>
#include <typeinfo>

#define LLVM_VERSION "UNKNOWN"
#define LLVM_FLAGS "FLAGS_HERE"

template <size_t Stride>
void idct_add(uint8_t *dst, int16_t *block) {
  return idct_add_impl(dst, block, Stride);
}

template <size_t Stride>
void bench_idct() {
  std::string benchName = "idct_add(stride="+patch::to_string(Stride)+")";
  Bench<decltype(idct_add<Stride>), idct_add<Stride>>(benchName).
    template run<Vec<uint8_t, 4*4*Stride>, Vec<int16_t, 4*4*Stride>>(std::cout);
}

template <size_t SrcStride, size_t DstStride>
void chroma_420_filter_vss(int16_t *src, int16_t *dst) {
  chroma_420_filter_vss_impl(src, SrcStride, dst, DstStride, 1/*coeffIdx*/);
}

template <size_t SrcStride, size_t DstStride>
void bench_chroma_vert() __attribute__((always_inline)) {
  std::string benchName = "chroma_420_filter_vss(src-stride="+patch::to_string(SrcStride) +
    ",dst-stride="+patch::to_string(DstStride) + ")";
  Bench<decltype(chroma_420_filter_vss<SrcStride, DstStride>),
    chroma_420_filter_vss<SrcStride, DstStride>>(benchName).
    template run<Vec<int16_t, 4*4*SrcStride>, Vec<int16_t, 4*4*DstStride> >(std::cout);
}

double bench_matmul_int16_impl(uint64_t iters = 10)
{
   constexpr unsigned trials = 20;
   constexpr unsigned warmups = 5;
   std::vector<double> timings;

   auto combine = [](unsigned lo, unsigned hi) -> uint64_t {
     return (uint64_t)lo | ((uint64_t)hi << 32);
   };

   for (int k = 0; k < trials + warmups; k++) {
     unsigned begin_lo, begin_hi, end_lo, end_hi;

     int16_t **dst = alloc_mat_int16(64, 64, MAT_BLANK);
     int16_t **mat1 = alloc_mat_int16(64, 64, MAT_RAND);
     int16_t **mat2 = alloc_mat_int16(64, 64, MAT_RAND);

     uint64_t begin = timer_begin();

     for (int i = 0; i < iters; i++)
       matmul_int16(dst, mat1, mat2, 64, 64, 64, 64, 64, 64);

     uint64_t end = timer_end();

     dealloc_mat_int16(&dst, 64, 64);
     dealloc_mat_int16(&mat1, 64, 64);
     dealloc_mat_int16(&mat2, 64, 64);

     double elapsed = end - begin;
     if (k >= warmups)
       timings.push_back(elapsed);
   }
   std::sort(timings.begin(), timings.end());
   return (timings[trials / 2] + timings[trials / 2 + 1]) / 2.0;
}
void bench_matmul_int16()
{
   double a = bench_matmul_int16_impl(20);
   double b = bench_matmul_int16_impl(10);
   double it_per_cyc = (a - b) / 10;
   std::cout << "matmul<int16>[64][64]," << it_per_cyc << std::endl;
}

double bench_matmul_float_impl(uint64_t iters = 10)
{
   constexpr unsigned trials = 20;
   constexpr unsigned warmups = 5;
   std::vector<double> timings;

   auto combine = [](unsigned lo, unsigned hi) -> uint64_t {
     return (uint64_t)lo | ((uint64_t)hi << 32);
   };

   for (int k = 0; k < trials + warmups; k++) {
     unsigned begin_lo, begin_hi, end_lo, end_hi;

     float **dst = alloc_mat_float(64, 64, MAT_BLANK);
     float **mat1 = alloc_mat_float(64, 64, MAT_RAND);
     float **mat2 = alloc_mat_float(64, 64, MAT_RAND);

     uint64_t begin = timer_begin();

     for (int i = 0; i < iters; i++)
       matmul_float(dst, mat1, mat2, 64, 64, 64, 64, 64, 64);

     uint64_t end = timer_end();

     dealloc_mat_float(&dst, 64, 64);
     dealloc_mat_float(&mat1, 64, 64);
     dealloc_mat_float(&mat2, 64, 64);

     double elapsed = end - begin;
     if (k >= warmups)
       timings.push_back(elapsed);
   }
   std::sort(timings.begin(), timings.end());
   return (timings[trials / 2] + timings[trials / 2 + 1]) / 2.0;
}
void bench_matmul_float()
{
   double a = bench_matmul_float_impl(20);
   double b = bench_matmul_float_impl(10);
   double it_per_cyc = (a - b) / 10;
   std::cout << "matmul<float>[64][64]," << it_per_cyc << std::endl;
}

double bench_matmul_double_impl(uint64_t iters = 10)
{
   constexpr unsigned trials = 20;
   constexpr unsigned warmups = 5;
   std::vector<double> timings;

   auto combine = [](unsigned lo, unsigned hi) -> uint64_t {
     return (uint64_t)lo | ((uint64_t)hi << 32);
   };

   for (int k = 0; k < trials + warmups; k++) {
     unsigned begin_lo, begin_hi, end_lo, end_hi;

     double **dst = alloc_mat_double(64, 64, MAT_BLANK);
     double **mat1 = alloc_mat_double(64, 64, MAT_RAND);
     double **mat2 = alloc_mat_double(64, 64, MAT_RAND);

     uint64_t begin = timer_begin();

     for (int i = 0; i < iters; i++)
       matmul_double(dst, mat1, mat2, 64, 64, 64, 64, 64, 64);

     uint64_t end = timer_end();

     dealloc_mat_double(&dst, 64, 64);
     dealloc_mat_double(&mat1, 64, 64);
     dealloc_mat_double(&mat2, 64, 64);

     double elapsed = end - begin;
     if (k >= warmups)
       timings.push_back(elapsed);
   }
   std::sort(timings.begin(), timings.end());
   return (timings[trials / 2] + timings[trials / 2 + 1]) / 2.0;
}
void bench_matmul_double()
{
   double a = bench_matmul_double_impl(20);
   double b = bench_matmul_double_impl(10);
   double it_per_cyc = (a - b) / 10;
   std::cout << "matmul<double>[64][64]," << it_per_cyc << std::endl;
}

double bench_matmul_uint8_impl(uint64_t iters = 10)
{
   constexpr unsigned trials = 20;
   constexpr unsigned warmups = 5;
   std::vector<double> timings;

   auto combine = [](unsigned lo, unsigned hi) -> uint64_t {
     return (uint64_t)lo | ((uint64_t)hi << 32);
   };

   for (int k = 0; k < trials + warmups; k++) {
     unsigned begin_lo, begin_hi, end_lo, end_hi;

     uint8_t **dst = alloc_mat_uint8(64, 64, MAT_BLANK);
     uint8_t **mat1 = alloc_mat_uint8(64, 64, MAT_RAND);
     uint8_t **mat2 = alloc_mat_uint8(64, 64, MAT_RAND);

     uint64_t begin = timer_begin();

     for (int i = 0; i < iters; i++)
       matmul_uint8(dst, mat1, mat2, 64, 64, 64, 64, 64, 64);

     uint64_t end = timer_end();

     dealloc_mat_uint8(&dst, 64, 64);
     dealloc_mat_uint8(&mat1, 64, 64);
     dealloc_mat_uint8(&mat2, 64, 64);

     double elapsed = end - begin;
     if (k >= warmups)
       timings.push_back(elapsed);
   }
   std::sort(timings.begin(), timings.end());
   return (timings[trials / 2] + timings[trials / 2 + 1]) / 2.0;
}
void bench_matmul_uint8()
{
   double a = bench_matmul_uint8_impl(20);
   double b = bench_matmul_uint8_impl(10);
   double it_per_cyc = (a - b) / 10;
   std::cout << "matmul<uint8>[64][64]," << it_per_cyc << std::endl;
}

double bench_matmul_int32_impl(uint64_t iters = 10)
{
   constexpr unsigned trials = 20;
   constexpr unsigned warmups = 5;
   std::vector<double> timings;

   auto combine = [](unsigned lo, unsigned hi) -> uint64_t {
     return (uint64_t)lo | ((uint64_t)hi << 32);
   };

   for (int k = 0; k < trials + warmups; k++) {
     unsigned begin_lo, begin_hi, end_lo, end_hi;

     int32_t **dst = alloc_mat_int32(64, 64, MAT_BLANK);
     int32_t **mat1 = alloc_mat_int32(64, 64, MAT_RAND);
     int32_t **mat2 = alloc_mat_int32(64, 64, MAT_RAND);

     uint64_t begin = timer_begin();

     for (int i = 0; i < iters; i++)
       matmul_int32(dst, mat1, mat2, 64, 64, 64, 64, 64, 64);

     uint64_t end = timer_end();

     dealloc_mat_int32(&dst, 64, 64);
     dealloc_mat_int32(&mat1, 64, 64);
     dealloc_mat_int32(&mat2, 64, 64);

     double elapsed = end - begin;
     if (k >= warmups)
       timings.push_back(elapsed);
   }
   std::sort(timings.begin(), timings.end());
   return (timings[trials / 2] + timings[trials / 2 + 1]) / 2.0;
}
void bench_matmul_int32()
{
   double a = bench_matmul_int32_impl(20);
   double b = bench_matmul_int32_impl(10);
   double it_per_cyc = (a - b) / 10;
   std::cout << "matmul<int32>[64][64]," << it_per_cyc << std::endl;
}

double bench_matmul_int64_impl(uint64_t iters = 10)
{
   constexpr unsigned trials = 20;
   constexpr unsigned warmups = 5;
   std::vector<double> timings;

   auto combine = [](unsigned lo, unsigned hi) -> uint64_t {
     return (uint64_t)lo | ((uint64_t)hi << 32);
   };

   for (int k = 0; k < trials + warmups; k++) {
     unsigned begin_lo, begin_hi, end_lo, end_hi;

     int64_t **dst = alloc_mat_int64(64, 64, MAT_BLANK);
     int64_t **mat1 = alloc_mat_int64(64, 64, MAT_RAND);
     int64_t **mat2 = alloc_mat_int64(64, 64, MAT_RAND);

     uint64_t begin = timer_begin();

     for (int i = 0; i < iters; i++)
       matmul_int64(dst, mat1, mat2, 64, 64, 64, 64, 64, 64);

     uint64_t end = timer_end();

     dealloc_mat_int64(&dst, 64, 64);
     dealloc_mat_int64(&mat1, 64, 64);
     dealloc_mat_int64(&mat2, 64, 64);

     double elapsed = end - begin;
     if (k >= warmups)
       timings.push_back(elapsed);
   }
   std::sort(timings.begin(), timings.end());
   return (timings[trials / 2] + timings[trials / 2 + 1]) / 2.0;
}
void bench_matmul_int64()
{
   double a = bench_matmul_int64_impl(20);
   double b = bench_matmul_int64_impl(10);
   double it_per_cyc = (a - b) / 10;
   std::cout << "matmul<int64>[64][64]," << it_per_cyc << std::endl;
}


void fft15_1(FFTComplex *__restrict__ out, FFTComplex *__restrict__ in, FFTComplex *__restrict__ exptab) {
  return fft15(out, in, exptab, 1);
}

int main() {
  std::cout << LLVM_VERSION << std::endl;
  std::cout << LLVM_FLAGS << std::endl;
  MAKE_BENCH(g722_apply_qmf).run<Vec<int16_t, 12 * 2>, Vec<int32_t, 2>>(std::cout);
  MAKE_BENCH(fft4).run<Vec<FFTComplex, 4>>(std::cout);
  MAKE_BENCH(fft8).run<Vec<FFTComplex, 8>>(std::cout);
  MAKE_BENCH(fft15_1).run<Vec<FFTComplex, 15>, Vec<FFTComplex, 15>, Vec<FFTComplex, 22>>(std::cout);
  bench_idct<1>();
  bench_idct<4>();
  bench_idct<8>();
  bench_idct<16>();
  MAKE_BENCH(sbc_analyze_4).run<Vec<int16_t, 64>, Vec<int32_t, 64>, Vec<int16_t, 64>>(std::cout);
  MAKE_BENCH(idct8).run<Vec<int16_t, 8*8>, Vec<int16_t, 8*8>>(std::cout);
  MAKE_BENCH(idct4).run<Vec<int16_t, 4*4>, Vec<int16_t, 4*4>>(std::cout);
  using i32x8 = Vec<int32_t, 8>;
  MAKE_BENCH(idct8_partial).run<Vec<int16_t, 4*4>, i32x8, i32x8, i32x8, i32x8,
    i32x8, i32x8, i32x8, i32x8
    >(std::cout);
  bench_chroma_vert<4, 4>();
  MAKE_BENCH(imdct36).run<Vec<float, 17*32+1>, Vec<float, 4*5>, Vec<float, 18>, Vec<float, 38>>(std::cout);
  bench_matmul_uint8();
  bench_matmul_int16();
  bench_matmul_int32();
  bench_matmul_int64();
  bench_matmul_float();
  bench_matmul_double();
}
