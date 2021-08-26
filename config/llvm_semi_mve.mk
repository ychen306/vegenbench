# For compiling semihosted with organic clang with MVE enabled
comp_PLATFORM:= semihosting
HAVE_MVE := 1

include $(srcroot)/config/inc/llvm_common.mk
