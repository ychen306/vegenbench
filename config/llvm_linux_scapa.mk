# For compiling linux binaries with organic clang with Scapa enabled
comp_PLATFORM := linux
HAVE_SVE2 := 1

include $(srcroot)/config/inc/llvm_common.mk
