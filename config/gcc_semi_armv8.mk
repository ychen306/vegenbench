comp_PLATFORM := semihosting
TARGET_ARCH ?= -march=armv8.4-a+fp+simd+fp16+crypto

include $(srcroot)/config/inc/gcc_common.mk
include $(srcroot)/config/inc/gcc_common_simd_flags.mk
