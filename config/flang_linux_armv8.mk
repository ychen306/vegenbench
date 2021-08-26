# For compiling with flang with neon enabled
comp_PLATFORM := linux
HAVE_SIMD := 1
FORTRAN_SUPPORTED := 1

include $(srcroot)/config/inc/llvm_common.mk
