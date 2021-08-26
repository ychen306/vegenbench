comp_PLATFORM := linux
TARGET_ARCH ?= -march=armv8-a+sve

include $(srcroot)/config/inc/gcc_common.mk
include $(srcroot)/config/inc/gcc_common_simd_flags.mk
