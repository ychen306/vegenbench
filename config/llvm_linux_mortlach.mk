# For compiling with clang using alternate sysroot (e.g. linux glibc)
comp_PLATFORM := linux
HAVE_MORTLACH := 1

ifdef library_prefix
SYSROOT := $(library_prefix)
endif

include $(srcroot)/config/inc/llvm_common.mk
