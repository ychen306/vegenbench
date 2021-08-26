# For compiling semihosted with organic clang with scapa enabled
comp_PLATFORM := semihosting
HAVE_SVE := 1
HAVE_SVE_MMLA_EXT := 1

include $(srcroot)/config/inc/llvm_common.mk
