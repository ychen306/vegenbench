# For compiling semihosted with organic clang with SVE enabled
comp_PLATFORM:= semihosting
HAVE_SVE2 := 1

IN_ORDER_SCHEDULING := 1

include $(srcroot)/config/inc/llvm_common.mk
