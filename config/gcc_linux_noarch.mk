# Configure the environment for native (host) compilation with GCC
comp_PLATFORM := linux

include $(srcroot)/config/inc/gcc_common.mk
include $(srcroot)/config/inc/gcc_common_simd_flags.mk
