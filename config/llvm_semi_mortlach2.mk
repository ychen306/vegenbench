# For compiling semihosted with organic clang with SME2 (Multivect) enabled
comp_PLATFORM := semihosting
HAVE_MORTLACH2 := 1

include $(srcroot)/config/inc/llvm_common.mk
