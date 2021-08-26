# Set baremetal elf target
comp_PLATFORM := semihosting
HAVE_SIMD := 1

LLVM_NO_NEWLIB := 1
LLVM_NO_GCC_TOOLCHAIN := 1

include $(srcroot)/config/inc/llvm_common.mk

config_CFLAGS   += -g
config_CXXFLAGS += -g
