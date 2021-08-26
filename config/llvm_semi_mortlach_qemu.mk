# For compiling with organic clang with neon enabled
comp_PLATFORM := semihosting
HAVE_MORTLACH := 1
QEMU := 1

include $(srcroot)/config/inc/llvm_common.mk
