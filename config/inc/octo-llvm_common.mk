TARGET_PREFIX ?= arm

ARM_COMPILER_FOR_LINUX ?= 1

include $(srcroot)/config/inc/llvm_common.mk

AS := $(binutils_prefix)/llvm-bin/llvm-mc

# The Octopus compiler package puts unprefixed versions of the llvm binaries in
# llvm-bin.
export PATH := $(install_prefix)/llvm-bin:$(PATH)
