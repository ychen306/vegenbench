# Set baremetal elf target
comp_PLATFORM := semihosting
HAVE_SIMD := 1

LLVM_NO_NEWLIB := 1
LLVM_NO_GCC_TOOLCHAIN := 1

TARGET_ARCH :=
TARGET_MACH := -mattr=+arran

include $(srcroot)/config/inc/llvm_common.mk

config_CFLAGS   += -marran -msandbox -DPOINTERS_ALIGN128 -DARRAN_SANDBOX -g
config_CXXFLAGS += -marran -msandbox -DPOINTERS_ALIGN128 -DARRAN_SANDBOX -g
config_LDFLAGS  += -marran -msandbox
