comp_PLATFORM := semihosting
TARGET_ARCH := -march=armv9-a+sve2

include $(srcroot)/config/inc/gcc_common.mk
include $(srcroot)/config/inc/gcc_common_simd_flags.mk
