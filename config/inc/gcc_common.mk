# Configure the environment for a native or cross GCC compile
#
include $(srcroot)/config/inc/setup.mk

ifdef install_prefix
  export PATH := $(install_prefix)/bin:$(PATH)
  config_gcc_common_compilerpath := $(install_prefix)/bin/
endif
ifdef binutils_prefix
  export PATH := $(binutils_prefix)/bin:$(PATH)
  config_gcc_common_binutilspath := $(binutils_prefix)/bin/
else
  config_gcc_common_binutilspath := $(config_gcc_common_compilerpath)
endif

ifeq ($(comp_PLATFORM), semihosting)
  include $(srcroot)/config/inc/gcc_semi_common.mk
endif

ifeq ($(comp_PLATFORM), linux)
  include $(srcroot)/config/inc/gcc_linux_common.mk
endif

# Assugme gfortran is installed
FORTRAN_SUPPORTED := 1

comp_LANG := C++ C fortran

AS      := $(config_gcc_common_binutilspath)$(TARGET_PREFIX)as
CC      := $(config_gcc_common_compilerpath)$(TARGET_PREFIX)gcc
CXX     := $(config_gcc_common_compilerpath)$(TARGET_PREFIX)g++
CPP     := $(config_gcc_common_compilerpath)$(TARGET_PREFIX)cpp
FC      := $(config_gcc_common_compilerpath)$(TARGET_PREFIX)gfortran
OBJDUMP := $(config_gcc_common_binutilspath)$(TARGET_PREFIX)objdump

LINK    := $(CXX)

# Portability with X86 -- AArch64 has unsigned chars by default,
CPORTABILITY   ?= -fsigned-char
CXXPORTABILITY ?= -fsigned-char -fpermissive
# Needed for 416.gamess (at least) since gfortran 8 now treats
# "Actual argument contains too few elements for dummy argument"
# as an error by default.
FCPORTABILITY  ?= -std=legacy -funconstrained-commons

# Used if the test has local arrays that are too large to be stored
# on the stack.
FHEAPARRAYS    ?= -fno-stack-arrays

# Flag for setting fixed-form on gfortran
FFIXEDFORM     ?= -ffixed-form

# Default optimizations
# Use GCC_OPTS if defined, otherwise fall back to -Ofast
ifdef GCC_OPTS
  COPTIMIZE	:= $(GCC_OPTS)
  CXXOPTIMIZE	:= $(GCC_OPTS)
  FCOPTIMIZE	:= $(GCC_OPTS)
  config_gcc_common_flags = $(GCC_OPTS)
else
  COPTIMIZE   ?= -Ofast
  CXXOPTIMIZE ?= -Ofast
  FCOPTIMIZE  ?= -Ofast
endif

# Optimisation flags that apply to all benchmarks, in addition to the
# benchmark-specific -O level given by COPTIMIZE & co.
#
# -flto is a general user-level option that is a win or neutral on
# almost all workloads.  In addition, some HPC benchmarks only vectorise
# with higher-than-normal inlining limits or higher-than-normal numbers
# of alias checks.  Add these options if the user didn't mandate any specific
# GCC_OPTS.
config_gcc_common_flags ?= -flto --param max-inline-insns-auto=70 \
			   --param vect-max-version-for-alias-checks=20

config_CFLAGS   += -g $(config_gcc_common_flags)
config_CXXFLAGS += -g $(config_gcc_common_flags)
config_FCFLAGS  += -g $(config_gcc_common_flags)
config_LDFLAGS  += -g $(config_gcc_common_flags)
config_ASFLAGS  += -g $(TARGET_ARCH)
config_ODFLAGS  += -d


compiler_version:
	@echo `$(CC) --version | head -1`
