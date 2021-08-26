# For compiling linux binaries with organic clang with SVE enabled, without
# using the GNU toolchain for assembly/linking
comp_PLATFORM := linux
HAVE_SVE := 1

LLVM_NO_GCC_TOOLCHAIN := 1

include $(srcroot)/config/inc/llvm_common.mk
