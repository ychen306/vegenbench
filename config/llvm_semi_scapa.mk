# For compiling semihosted with organic clang with scapa enabled
comp_PLATFORM := semihosting
HAVE_SVE2 := 1

include $(srcroot)/config/inc/llvm_common.mk