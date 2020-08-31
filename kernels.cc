#include <stdint.h>

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
