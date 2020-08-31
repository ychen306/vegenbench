#include "kernels.h"
#include <stdint.h>
#include <math.h>

#define MAC16(rt, ra, rb) rt += (ra) * (rb)
#define MUL16(ra, rb) ((ra) * (rb))

// https://github.com/FFmpeg/FFmpeg/blob/a0ac49e38ee1d1011c394d7be67d0f08b2281526/libavcodec/g722dsp.c
// https://github.com/FFmpeg/FFmpeg/blob/a0ac49e38ee1d1011c394d7be67d0f08b2281526/libavcodec/x86/g722dsp.asm

void g722_apply_qmf(const int16_t *__restrict__ prev_samples, int *__restrict__ xout)
{
  xout[1] = MUL16(*prev_samples++, 3);
  xout[0] = MUL16(*prev_samples++, -11);

  MAC16(xout[1], *prev_samples++, -11);
  MAC16(xout[0], *prev_samples++, 53);

  MAC16(xout[1], *prev_samples++, 12);
  MAC16(xout[0], *prev_samples++, -156);

  MAC16(xout[1], *prev_samples++, 32);
  MAC16(xout[0], *prev_samples++, 362);

  MAC16(xout[1], *prev_samples++, -210);
  MAC16(xout[0], *prev_samples++, -805);

  MAC16(xout[1], *prev_samples++, 951);
  MAC16(xout[0], *prev_samples++, 3876);

  MAC16(xout[1], *prev_samples++, 3876);
  MAC16(xout[0], *prev_samples++, 951);

  MAC16(xout[1], *prev_samples++, -805);
  MAC16(xout[0], *prev_samples++, -210);

  MAC16(xout[1], *prev_samples++, 362);
  MAC16(xout[0], *prev_samples++, 32);

  MAC16(xout[1], *prev_samples++, -156);
  MAC16(xout[0], *prev_samples++, 12);

  MAC16(xout[1], *prev_samples++, 53);
  MAC16(xout[0], *prev_samples++, -11);

  MAC16(xout[1], *prev_samples++, -11);
  MAC16(xout[0], *prev_samples++, 3);
}

#define BF(x, y, a, b) do {                     \
          x = a - b;                              \
          y = a + b;                              \
      } while (0)

#define CMUL(dre, dim, are, aim, bre, bim) do { \
          (dre) = (are) * (bre) - (aim) * (bim);  \
          (dim) = (are) * (bim) + (aim) * (bre);  \
      } while (0)


#define BUTTERFLIES(a0,a1,a2,a3) {\
      BF(t3, t5, t5, t1);\
      BF(a2.re, a0.re, a0.re, t5);\
      BF(a3.im, a1.im, a1.im, t3);\
      BF(t4, t6, t2, t6);\
      BF(a3.re, a1.re, a1.re, t4);\
      BF(a2.im, a0.im, a0.im, t6);\
}

#define TRANSFORM(a0,a1,a2,a3,wre,wim) {\
      CMUL(t1, t2, a2.re, a2.im, wre, -wim);\
      CMUL(t5, t6, a3.re, a3.im, wre,  wim);\
      BUTTERFLIES(a0,a1,a2,a3)\
}

using FFTDouble = float;

void fft4(FFTComplex *z)
{
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
void fft8(FFTComplex *z)
{
  FFTDouble t1, t2, t3, t4, t5, t6;

  fft4(z);

  BF(t1, z[5].re, z[4].re, -z[5].re);
  BF(t2, z[5].im, z[4].im, -z[5].im);
  BF(t5, z[7].re, z[6].re, -z[7].re);
  BF(t6, z[7].im, z[6].im, -z[7].im);

  BUTTERFLIES(z[0],z[2],z[4],z[6]);
  TRANSFORM(z[1],z[3],z[5],z[7],sqrthalf,sqrthalf);
}
