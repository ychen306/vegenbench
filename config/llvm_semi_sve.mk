# For compiling semihosted with organic clang with SVE enabled
comp_PLATFORM:= semihosting
HAVE_SVE := 1

include $(srcroot)/config/inc/llvm_common.mk
