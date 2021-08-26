# Configure the environment for a cross LLVM compile

include $(srcroot)/config/inc/setup.mk

ifndef install_prefix
  $(error install_prefix is not set - it must point to your LLVM build directory)
else
  export PATH := $(install_prefix)/bin:$(PATH)
  config_llvm_common_compilerpath := $(install_prefix)/bin/
endif

ifdef binutils_prefix
  export PATH := $(binutils_prefix)/bin:$(PATH)
  config_llvm_common_binutilspath := $(binutils_prefix)/bin/
else
  config_llvm_common_binutilspath := $(config_llvm_common_compilerpath)
endif

ifeq ($(comp_PLATFORM), semihosting)
  include $(srcroot)/config/inc/llvm_semi_common.mk
endif

ifeq ($(comp_PLATFORM), linux)
  include $(srcroot)/config/inc/llvm_linux_common.mk
endif

ifndef TARGET_TRIPLE
  $(error TARGET_TRIPLE is not set - must be a valid target eg: aarch64-none-elf)
endif

ifdef HAVE_SVE2
  HAVE_SVE := 1
endif

ifdef HAVE_SVE
  HAVE_SIMD := 1
endif

comp_LANG := C++ C
ifdef FORTRAN_SUPPORTED
  comp_LANG += fortran
endif

ifndef ARM_COMPILER_FOR_LINUX
  config_FCFLAGS  += -disable-arm-libs
  config_CFLAGS   += -disable-arm-libs
  config_CXXFLAGS += -disable-arm-libs
  config_LDFLAGS  += -disable-arm-libs
endif

ifneq (,$(wildcard $(install_prefix)/bin/sve-clang))
  # we are using a build of the SVE tools
  TARGET_PREFIX ?= sve-
endif
ifdef HAVE_MVE
	CC := $(config_llvm_common_binutilspath)armclang
	CXX := $(config_llvm_common_binutilspath)armclang
	LINK := $(config_llvm_common_binutilspath)armlink
	AS := $(config_llvm_common_binutilspath)armasm
else
	CC      := $(config_llvm_common_compilerpath)$(TARGET_PREFIX)clang
	CXX     := $(config_llvm_common_compilerpath)$(TARGET_PREFIX)clang++
endif
AS      := $(config_llvm_common_binutilspath)$(TARGET_PREFIX)llvm-mc
CPP     := $(CXX)
FC      := $(config_llvm_common_compilerpath)$(TARGET_PREFIX)flang
OBJDUMP := $(config_llvm_common_binutilspath)$(TARGET_PREFIX)llvm-objdump
LINK    := $(CXX)
ifndef HAVE_MVE
	# Portability with X86 -- AArch64 has unsigned chars by default,
	# which causes Pathfinder to enter an infinite loop
	CPORTABILITY   ?= -fsigned-char
	CXXPORTABILITY ?= -fsigned-char
	FCPORTABILITY  ?= -fsigned-char

	# Flag for setting fixed-form on the PGI fortran compiler
	FFIXEDFORM     ?= -Mfixed

	# Default optimizations
	COPTIMIZE   ?= -Ofast
	CXXOPTIMIZE ?= -Ofast
	FCOPTIMIZE  ?= -Ofast

	ifdef DEBUG_BUILD
		# add full debug flags to build options
		DEBUG_FLAGS ?= -g
	else
		DEBUG_FLAGS ?= -gline-tables-only
	endif

	# Common flags; provide location debug data and adjust vectorization thresholds
	# if SVE/SVE2 is enabled
	config_llvm_common_flags := -target $(TARGET_TRIPLE) $(DEBUG_FLAGS) -fcommon

	config_CPPFLAGS += -D__ARM_ARCH_ISA_A64
else
	config_llvm_common_flags := -target $(TARGET_TRIPLE)
endif

ifdef HAVE_MORTLACH2
  # generate code for SME2 (MultiVect)
  config_CPPFLAGS += -DHAVE_MORTLACH2 -DHAVE_MORTLACH -DHAVE_SVE -DHAVE_SVE2 -DHAVE_SIMD -DHAVE_ORGANIC_LLVM
  TARGET_ARCH     ?= -march=armv9-a+sme2+sve2-bitperm+bf16
  TARGET_MACH     ?= -mattr=+sme2
  config_llvm_common_flags += -mllvm -enable-load-pre=false \
			      -mllvm -runtime-memory-check-threshold=40

else ifdef HAVE_MORTLACH
  # generate code for Mortlach
  config_CPPFLAGS += -DHAVE_MORTLACH -DHAVE_SVE -DHAVE_SVE2 -DHAVE_SIMD -DHAVE_ORGANIC_LLVM
  TARGET_ARCH     ?= -march=armv9-a+sme+sve2-bitperm+bf16
  TARGET_MACH     ?= -mattr=+sme
  config_llvm_common_flags += -mllvm -enable-load-pre=false \
			      -mllvm -runtime-memory-check-threshold=40
else ifdef HAVE_SVE2
  # generate code for SVE2
  config_CPPFLAGS += -DHAVE_SIMD -DHAVE_SVE -DHAVE_SVE2 -DHAVE_ORGANIC_LLVM
  TARGET_ARCH     ?= -march=armv8.7-a+sve2+sve2-bitperm
  TARGET_MACH     ?= -mattr=+sve2
  config_llvm_common_flags += -mllvm -enable-load-pre=false \
			      -mllvm -runtime-memory-check-threshold=40
else ifdef HAVE_SVE_MMLA_EXT
  # generate code for SVE MMLA extension
  config_CPPFLAGS += -DHAVE_SIMD -DHAVE_SVE -DHAVE_SVE_MMLA_EXT -DHAVE_ORGANIC_LLVM
  TARGET_ARCH     ?= -march=armv8.6-a+sve+f64mm
  TARGET_MACH     ?= -mattr=+sve,+f64mm,+f32mm,+i8mm,+i16mm
  config_llvm_common_flags += -mllvm -enable-load-pre=false \
			      -mllvm -runtime-memory-check-threshold=40
else ifdef HAVE_SVE
  # generate code for SVE
  config_CPPFLAGS += -DHAVE_SIMD -DHAVE_SVE -DHAVE_ORGANIC_LLVM
  config_llvm_common_flags += -mllvm -enable-load-pre=false \
			      -mllvm -runtime-memory-check-threshold=40
  TARGET_ARCH     ?= -march=armv8-a+sve
  TARGET_MACH     ?= -mattr=+sve
else ifdef HAVE_MVE
  # generate code for MVE
  config_CPPFLAGS += -DHAVE_MVE -DHAVE_ORGANIC_LLVM
  config_llvm_common_flags += -mllvm -enable-load-pre=false \
			      -mllvm -runtime-memory-check-threshold=40
  TARGET_ARCH     ?= -march=armv8.1-m.main+mve.fp+fp.dp
  TARGET_MACH     ?= -mattr=+mve
else ifdef HAVE_SIMD
  # generate code for NEON
  config_CPPFLAGS += -DHAVE_SIMD
  TARGET_ARCH     ?= -march=armv8-a+fp+simd+dotprod
else
  # generate scalar-only code
  TARGET_ARCH ?= -march=armv8-a
endif

ifeq ($(QEMU),1)
  config_CPPFLAGS += -DQEMU
endif

ifeq ($(PROFILING),1)
  config_CPPFLAGS += -DPROFILING
endif

ifeq ($(IN_ORDER_SCHEDULING),1)
  config_CPPFLAGS += -DIN_ORDER_SCHEDULING
endif

ifeq ($(MORTLACH_SSVE2),1)
  config_CPPFLAGS += -DMORTLACH_SSVE2
endif

config_CFLAGS   += $(config_llvm_common_flags)
config_CXXFLAGS += $(config_llvm_common_flags)
config_FCFLAGS  += $(config_llvm_common_flags)
config_LDFLAGS  += -target $(TARGET_TRIPLE) $(DEBUG_FLAGS)
config_ASFLAGS  += -triple=$(TARGET_TRIPLE) -filetype=obj
config_ODFLAGS  += --disassemble $(subst -mattr=,--mattr=,$(TARGET_MACH))

compiler_version:
	@echo $(realpath $(install_prefix))
