# For cross-compiling linux binaries with flang with SVE enabled
comp_PLATFORM := linux
HAVE_SVE := 1
FORTRAN_SUPPORTED := 1
FORTRAN_CROSS := 1
config_FCFLAGS += -fno-simdmath

include $(srcroot)/config/inc/llvm_common.mk
