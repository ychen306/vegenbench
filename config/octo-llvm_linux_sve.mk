# For compiling linux binaries with the ARM HPC Compiler Octopus package with SVE.
comp_PLATFORM := linux
HAVE_SVE := 1
FORTRAN_SUPPORTED := 1
LLVM_NO_GCC_TOOLCHAIN := 1

include $(srcroot)/config/inc/octo-llvm_common.mk
