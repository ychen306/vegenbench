#include "kernels.h"
#include <math.h>
#include <stdint.h>
#include <string.h>

#define MAC16(rt, ra, rb) rt += (ra) * (rb)
#define MUL16(ra, rb) ((ra) * (rb))

#define BF(x, y, a, b)                                                         \
  do {                                                                         \
    x = a - b;                                                                 \
    y = a + b;                                                                 \
  } while (0)

#define CMUL(dre, dim, are, aim, bre, bim)                                     \
  do {                                                                         \
    (dre) = (are) * (bre) - (aim) * (bim);                                     \
    (dim) = (are) * (bim) + (aim) * (bre);                                     \
  } while (0)

#define CMUL3(c, a, b) CMUL((c).re, (c).im, (a).re, (a).im, (b).re, (b).im)

#define BUTTERFLIES(a0, a1, a2, a3)                                            \
  {                                                                            \
    BF(t3, t5, t5, t1);                                                        \
    BF(a2.re, a0.re, a0.re, t5);                                               \
    BF(a3.im, a1.im, a1.im, t3);                                               \
    BF(t4, t6, t2, t6);                                                        \
    BF(a3.re, a1.re, a1.re, t4);                                               \
    BF(a2.im, a0.im, a0.im, t6);                                               \
  }

#define TRANSFORM(a0, a1, a2, a3, wre, wim)                                    \
  {                                                                            \
    CMUL(t1, t2, a2.re, a2.im, wre, -wim);                                     \
    CMUL(t5, t6, a3.re, a3.im, wre, wim);                                      \
    BUTTERFLIES(a0, a1, a2, a3)                                                \
  }

using FFTDouble = float;

void fft4(FFTComplex *z) {
  FFTDouble t1, t2, t3, t4, t5, t6, t7, t8;

  BF(t3, t1, z[0].re, z[1].re);
  BF(t8, t6, z[3].re, z[2].re);
  BF(z[2].re, z[0].re, t1, t6);
  BF(t4, t2, z[0].im, z[1].im);
  BF(t7, t5, z[2].im, z[3].im);
  BF(z[3].im, z[1].im, t4, t8);
  BF(z[3].re, z[1].re, t3, t7);
  BF(z[2].im, z[0].im, t2, t5);
}

#define sqrthalf (float)M_SQRT1_2

// https://github.com/FFmpeg/FFmpeg/blob/a0ac49e38ee1d1011c394d7be67d0f08b2281526/libavcodec/fft_template.c#L553-L566
void fft8(FFTComplex *z) {
  FFTDouble t1, t2, t3, t4, t5, t6;

  fft4(z);

  BF(t1, z[5].re, z[4].re, -z[5].re);
  BF(t2, z[5].im, z[4].im, -z[5].im);
  BF(t5, z[7].re, z[6].re, -z[7].re);
  BF(t6, z[7].im, z[6].im, -z[7].im);

  BUTTERFLIES(z[0], z[2], z[4], z[6]);
  TRANSFORM(z[1], z[3], z[5], z[7], sqrthalf, sqrthalf);
}


static void fft5(FFTComplex *out, FFTComplex *in, FFTComplex exptab[2]) __attribute__((always_inline))
{
    FFTComplex z0[4], t[6];

    t[0].re = in[3].re + in[12].re;
    t[0].im = in[3].im + in[12].im;
    t[1].im = in[3].re - in[12].re;
    t[1].re = in[3].im - in[12].im;
    t[2].re = in[6].re + in[ 9].re;
    t[2].im = in[6].im + in[ 9].im;
    t[3].im = in[6].re - in[ 9].re;
    t[3].re = in[6].im - in[ 9].im;

    out[0].re = in[0].re + in[3].re + in[6].re + in[9].re + in[12].re;
    out[0].im = in[0].im + in[3].im + in[6].im + in[9].im + in[12].im;

    t[4].re = exptab[0].re * t[2].re - exptab[1].re * t[0].re;
    t[4].im = exptab[0].re * t[2].im - exptab[1].re * t[0].im;
    t[0].re = exptab[0].re * t[0].re - exptab[1].re * t[2].re;
    t[0].im = exptab[0].re * t[0].im - exptab[1].re * t[2].im;
    t[5].re = exptab[0].im * t[3].re - exptab[1].im * t[1].re;
    t[5].im = exptab[0].im * t[3].im - exptab[1].im * t[1].im;
    t[1].re = exptab[0].im * t[1].re + exptab[1].im * t[3].re;
    t[1].im = exptab[0].im * t[1].im + exptab[1].im * t[3].im;

    z0[0].re = t[0].re - t[1].re;
    z0[0].im = t[0].im - t[1].im;
    z0[1].re = t[4].re + t[5].re;
    z0[1].im = t[4].im + t[5].im;

    z0[2].re = t[4].re - t[5].re;
    z0[2].im = t[4].im - t[5].im;
    z0[3].re = t[0].re + t[1].re;
    z0[3].im = t[0].im + t[1].im;

    out[1].re = in[0].re + z0[3].re;
    out[1].im = in[0].im + z0[0].im;
    out[2].re = in[0].re + z0[2].re;
    out[2].im = in[0].im + z0[1].im;
    out[3].re = in[0].re + z0[1].re;
    out[3].im = in[0].im + z0[2].im;
    out[4].re = in[0].re + z0[0].re;
    out[4].im = in[0].im + z0[3].im;
}


// https://github.com/FFmpeg/FFmpeg/blob/e409262837712016097c187e97bf99aadf6a4cdf/libavutil/common.h#L154-L163
static inline uint8_t av_clip_uint8_c(int a) {
  if (a & (~0xFF))
    return (~a) >> 31;
  else
    return a;
}

#define SUINT unsigned
#define pixel uint8_t
#define dctcoef int16_t
#define av_clip_pixel av_clip_uint8_c


#define SBC_COS_TABLE_FIXED_SCALE 15
#define SBC_PROTO_FIXED_SCALE 16
#define SCALE_OUT_BITS 15

void sbc_analyze_4(const int16_t *__restrict__ in, int32_t *__restrict__ out,
                   const int16_t *__restrict__ consts) {
  int32_t t1[8];
  int16_t t2[8];
  int i, j, hop = 0;

#pragma unroll
  /* rounding coefficient */
  for (i = 0; i < 4; i++)
    t1[i] = 1 << (SBC_PROTO_FIXED_SCALE - 1);

#pragma unroll
  /* low pass polyphase filter */
  for (hop = 0; hop < 10 * 4; hop += 2 * 4)
    for (i = 0; i < 2 * 4; i++)
      t1[i >> 1] += in[hop + i] * consts[hop + i];

  /* scaling */
  for (i = 0; i < 4; i++)
    t2[i] = t1[i] >> SBC_PROTO_FIXED_SCALE;

  memset(t1, 0, sizeof(t1));

#pragma unroll
  /* do the cos transform */
  for (i = 0; i < 4 / 2; i++)
    for (j = 0; j < 2 * 4; j++)
      t1[j >> 1] += t2[i * 2 + (j & 1)] * consts[10 * 4 + i * 2 * 4 + j];

#pragma unroll
  for (i = 0; i < 4; i++)
    out[i] = t1[i] >> (SBC_COS_TABLE_FIXED_SCALE - SCALE_OUT_BITS);
}

static constexpr int16_t g_t8[8][8] = {
    {65, 65, 65, 65, 65, 65, 65, 65},     {89, 75, 50, 18, -18, -50, -75, -89},
    {83, 36, -36, -83, -83, -36, 36, 83}, {75, -18, -89, -50, 50, 89, 18, -75},
    {65, -65, -65, 65, 65, -65, -65, 65}, {50, -89, 18, 75, -75, -18, 89, -50},
    {36, -83, 83, -36, -36, 83, -83, 36}, {18, -50, 75, -89, 89, -75, 50, -18}};

int16_t saturate_i16(int32_t x) {
  return x >= 32767 ? 32767 : (x <= -32768 ? -32768 : x);
}

// https://github.com/revec/VectorBench/blob/master/vector/x265/source/common/dct.cpp#L205
void idct8(const int16_t *__restrict__ src, int16_t *__restrict__ dst) {
  int j, k;
  int E[4], O[4];
  int EE[2], EO[2];
  constexpr int shift = 7;
  constexpr int add = 1 << (shift - 1);

  constexpr int line = 8;

#pragma unroll
  for (j = 0; j < line; j++) {
    /* Utilizing symmetry properties to the maximum to minimize the number of
     * multiplications */
    for (k = 0; k < 4; k++) {
      O[k] = g_t8[1][k] * src[line] + g_t8[3][k] * src[3 * line] +
             g_t8[5][k] * src[5 * line] + g_t8[7][k] * src[7 * line];
    }

    EO[0] = g_t8[2][0] * src[2 * line] + g_t8[6][0] * src[6 * line];
    EO[1] = g_t8[2][1] * src[2 * line] + g_t8[6][1] * src[6 * line];
    EE[0] = g_t8[0][0] * src[0] + g_t8[4][0] * src[4 * line];
    EE[1] = g_t8[0][1] * src[0] + g_t8[4][1] * src[4 * line];

    /* Combining even and odd terms at each hierarchy levels to calculate the
     * final spatial domain vector */
    E[0] = EE[0] + EO[0];
    E[3] = EE[0] - EO[0];
    E[1] = EE[1] + EO[1];
    E[2] = EE[1] - EO[1];

#pragma unroll
    for (k = 0; k < 4; k++) {
      dst[k] = saturate_i16((E[k] + O[k] + add) >> shift);
      dst[k + 4] = saturate_i16((E[3 - k] - O[3 - k] + add) >> shift);
    }

    src++;
    dst += 8;
  }
}

static constexpr int16_t g_t4[4][4] = {{65, 65, 65, 65},
                                       {83, 36, -36, -83},
                                       {65, -65, -65, 65},
                                       {36, -83, 83, -36}};

void idct4(const int16_t *__restrict__ src, int16_t *__restrict__ dst) {
  int j;
  int E[2], O[2];
  constexpr int line = 4;
  constexpr int shift = 7;
  constexpr int add = 1 << (shift - 1);

  for (j = 0; j < line; j++) {
    /* Utilizing symmetry properties to the maximum to minimize the number of
     * multiplications */
    O[0] = g_t4[1][0] * src[line] + g_t4[3][0] * src[3 * line];
    O[1] = g_t4[1][1] * src[line] + g_t4[3][1] * src[3 * line];
    E[0] = g_t4[0][0] * src[0] + g_t4[2][0] * src[2 * line];
    E[1] = g_t4[0][1] * src[0] + g_t4[2][1] * src[2 * line];

    /* Combining even and odd terms at each hierarchy levels to calculate the
     * final spatial domain vector */
    dst[0] = saturate_i16((E[0] + O[0] + add) >> shift);
    dst[1] = saturate_i16((E[1] + O[1] + add) >> shift);
    dst[2] = saturate_i16((E[1] - O[1] + add) >> shift);
    dst[3] = saturate_i16((E[0] - O[0] + add) >> shift);

    src++;
    dst += 4;
  }
}

static constexpr int16_t g_lumaFilter[4][8] = {
    {0, 0, 0, 641, 0, 0, 0, 0},
    {-1, 41, -10, 58, 17, -5, 1, 0},
    {-1, 41, -11, 40, 40, -11, 41, -1},
    {0, 1, -5, 17, 58, -10, 41, -1}};

static constexpr int16_t g_chromaFilter[8][4] = {
    {0, 641, 0, 0},     {-21, 58, 10, -21}, {-41, 54, 16, -21},
    {-61, 46, 28, -41}, {-41, 36, 36, -41}, {-41, 28, 46, -61},
    {-21, 16, 54, -41}, {-21, 10, 58, -21}};

template <int N, int width, int height>
void interp_vert_ss_c(const int16_t *__restrict__ src, intptr_t srcStride,
                      int16_t *__restrict__ dst, intptr_t dstStride,
                      int coeffIdx) {
  const int16_t *c =
      (N == 8 ? g_lumaFilter[coeffIdx] : g_chromaFilter[coeffIdx]);
  int shift = 6;
  int row, col;

  src -= (N / 2 - 1) * srcStride;
#pragma unroll
  for (row = 0; row < height; row++) {
#pragma unroll
    for (col = 0; col < width; col++) {
      int sum;

      sum = src[col + 0 * srcStride] * c[0];
      sum += src[col + 1 * srcStride] * c[1];
      sum += src[col + 2 * srcStride] * c[2];
      sum += src[col + 3 * srcStride] * c[3];
      if (N == 8) {
        sum += src[col + 4 * srcStride] * c[4];
        sum += src[col + 5 * srcStride] * c[5];
        sum += src[col + 6 * srcStride] * c[6];
        sum += src[col + 7 * srcStride] * c[7];
      }

      //int16_t val = (int16_t)((sum) >> shift);
      int16_t val = saturate_i16((sum) >> shift);
      dst[col] = val;
    }

    src += srcStride;
    dst += dstStride;
  }
}

void chroma_420_filter_vss_impl(const int16_t *src, intptr_t srcStride,
                                int16_t *dst, intptr_t dstStride,
                                int coeffIdx) {
  interp_vert_ss_c<4, 4, 8>(src, srcStride, dst, dstStride, coeffIdx);
}
#if 0
#define INTFLOAT float
#define SUINTFLOAT float
#define MULH3(x, y, s) ((s)*(y)*(x))
#define MULLx(x, y, s) ((x)*(y))
#define FRAC_BITS 0
#define FIXHR(x)        ((float)(x))
#define FIXR(x)        ((float)(x))
#define C1 FIXHR(0.98480775301220805936/2)
#define C2 FIXHR(0.93969262078590838405/2)
#define C3 FIXHR(0.86602540378443864676/2)
#define C4 FIXHR(0.76604444311897803520/2)
#define C5 FIXHR(0.64278760968653932632/2)
#define C6 FIXHR(0.5/2)
#define C7 FIXHR(0.34202014332566873304/2)
#define C8 FIXHR(0.17364817766693034885/2)
#define FFALIGN(x, a) (((x)+(a)-1)&~((a)-1))
#define MDCT_BUF_SIZE FFALIGN(36, 2*4)
#define SHR(a,b)       ((a)*(1.0f/(1<<(b))))
#define SBLIMIT 32
static const INTFLOAT icos36h[9] = {
    FIXHR(0.50190991877167369479/2),
    FIXHR(0.51763809020504152469/2), //0
    FIXHR(0.55168895948124587824/2),
    FIXHR(0.61038729438072803416/2),
    FIXHR(0.70710678118654752439/2), //1
    FIXHR(0.87172339781054900991/2),
    FIXHR(1.18310079157624925896/4),
    FIXHR(1.93185165257813657349/4), //2
//    FIXHR(5.73685662283492756461),
};

static const INTFLOAT icos36[9] = {
    FIXR(0.50190991877167369479),
    FIXR(0.51763809020504152469), //0
    FIXR(0.55168895948124587824),
    FIXR(0.61038729438072803416),
    FIXR(0.70710678118654752439), //1
    FIXR(0.87172339781054900991),
    FIXR(1.18310079157624925896),
    FIXR(1.93185165257813657349), //2
    FIXR(5.73685662283492756461),
};

void imdct36(INTFLOAT *__restrict__ out, INTFLOAT * __restrict__ buf, SUINTFLOAT *__restrict__ in, INTFLOAT *__restrict__ win)
{
    int i, j;
    SUINTFLOAT t0, t1, t2, t3, s0, s1, s2, s3;
    SUINTFLOAT tmp[18], *tmp1, *in1;

    for (i = 17; i >= 1; i--)
        in[i] += in[i-1];
    for (i = 17; i >= 3; i -= 2)
        in[i] += in[i-2];

    for (j = 0; j < 2; j++) {
        tmp1 = tmp + j;
        in1 = in + j;

        t2 = in1[2*4] + in1[2*8] - in1[2*2];

        t3 = in1[2*0] + SHR(in1[2*6],1);
        t1 = in1[2*0] - in1[2*6];
        tmp1[ 6] = t1 - SHR(t2,1);
        tmp1[16] = t1 + t2;

        t0 = MULH3(in1[2*2] + in1[2*4] ,    C2, 2);
        t1 = MULH3(in1[2*4] - in1[2*8] , -2*C8, 1);
        t2 = MULH3(in1[2*2] + in1[2*8] ,   -C4, 2);

        tmp1[10] = t3 - t0 - t2;
        tmp1[ 2] = t3 + t0 + t1;
        tmp1[14] = t3 + t2 - t1;

        tmp1[ 4] = MULH3(in1[2*5] + in1[2*7] - in1[2*1], -C3, 2);
        t2 = MULH3(in1[2*1] + in1[2*5],    C1, 2);
        t3 = MULH3(in1[2*5] - in1[2*7], -2*C7, 1);
        t0 = MULH3(in1[2*3], C3, 2);

        t1 = MULH3(in1[2*1] + in1[2*7],   -C5, 2);

        tmp1[ 0] = t2 + t3 + t0;
        tmp1[12] = t2 + t1 - t0;
        tmp1[ 8] = t3 - t1 - t0;
    }

    i = 0;
    for (j = 0; j < 4; j++) {
        t0 = tmp[i];
        t1 = tmp[i + 2];
        s0 = t1 + t0;
        s2 = t1 - t0;

        t2 = tmp[i + 1];
        t3 = tmp[i + 3];
        s1 = MULH3(t3 + t2, icos36h[    j], 2);
        s3 = MULLx(t3 - t2, icos36 [8 - j], FRAC_BITS);

        t0 = s0 + s1;
        t1 = s0 - s1;
        out[(9 + j) * SBLIMIT] = MULH3(t1, win[     9 + j], 1) + buf[4*(9 + j)];
        out[(8 - j) * SBLIMIT] = MULH3(t1, win[     8 - j], 1) + buf[4*(8 - j)];
        buf[4 * ( 9 + j     )] = MULH3(t0, win[MDCT_BUF_SIZE/2 + 9 + j], 1);
        buf[4 * ( 8 - j     )] = MULH3(t0, win[MDCT_BUF_SIZE/2 + 8 - j], 1);

        t0 = s2 + s3;
        t1 = s2 - s3;
        out[(9 + 8 - j) * SBLIMIT] = MULH3(t1, win[     9 + 8 - j], 1) + buf[4*(9 + 8 - j)];
        out[         j  * SBLIMIT] = MULH3(t1, win[             j], 1) + buf[4*(        j)];
        buf[4 * ( 9 + 8 - j     )] = MULH3(t0, win[MDCT_BUF_SIZE/2 + 9 + 8 - j], 1);
        buf[4 * (         j     )] = MULH3(t0, win[MDCT_BUF_SIZE/2         + j], 1);
        i += 4;
    }

    s0 = tmp[16];
    s1 = MULH3(tmp[17], icos36h[4], 2);
    t0 = s0 + s1;
    t1 = s0 - s1;
    out[(9 + 4) * SBLIMIT] = MULH3(t1, win[     9 + 4], 1) + buf[4*(9 + 4)];
    out[(8 - 4) * SBLIMIT] = MULH3(t1, win[     8 - 4], 1) + buf[4*(8 - 4)];
    buf[4 * ( 9 + 4     )] = MULH3(t0, win[MDCT_BUF_SIZE/2 + 9 + 4], 1);
    buf[4 * ( 8 - 4     )] = MULH3(t0, win[MDCT_BUF_SIZE/2 + 8 - 4], 1);
}
#endif
