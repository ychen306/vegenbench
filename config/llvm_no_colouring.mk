# Set baremetal elf target
comp_PLATFORM := semihosting
HAVE_SIMD := 1

LLVM_NO_NEWLIB := 1
LLVM_NO_GCC_TOOLCHAIN := 1

include $(srcroot)/config/inc/llvm_common.mk

# Overwrite default optmisation flags
COPTIMIZE   = -O3
CXXOPTIMIZE = -O3
config_LDFLAGS  += -v
config_CFLAGS   += -fno-exceptions -v
config_CXXFLAGS += -fno-exceptions -v
