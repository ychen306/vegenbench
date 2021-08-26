# For compiling linux binaries with organic clang with SVE enabled
comp_PLATFORM := linux
HAVE_SVE := 1

include $(srcroot)/config/inc/llvm_common.mk
