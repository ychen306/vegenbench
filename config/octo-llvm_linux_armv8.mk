# For compiling linux binaries with the ARM HPC Compiler Octopus package with NEON.
comp_PLATFORM := linux
HAVE_SIMD := 1
FORTRAN_SUPPORTED := 1
LLVM_NO_GCC_TOOLCHAIN := 1

include $(srcroot)/config/inc/octo-llvm_common.mk
