# For compiling with organic clang with neon enabled
comp_PLATFORM := semihosting
HAVE_SIMD := 1

include $(srcroot)/config/inc/llvm_common.mk
