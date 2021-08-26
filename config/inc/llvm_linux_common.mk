# Set linux elf target
TARGET_TRIPLE ?= aarch64-linux-gnu

ifndef LLVM_NO_GCC_TOOLCHAIN
  # Headers and libs, standard location for mdc servers
  SYSROOT ?= /opt/aarch64-sysroot

  # GCC_TOOLCHAIN explicitly set by the user
  ifdef linker_prefix
    GCC_TOOLCHAIN := $(linker_prefix)
  endif

  # GCC used to assembly right now, standard location for
  # mdc servers. Should be able to remove this soon.
  GCC_TOOLCHAIN ?= /opt/aarch64-cross-compiler

  config_CPPFLAGS += --sysroot=$(SYSROOT) --gcc-toolchain=$(GCC_TOOLCHAIN)
  config_LDFLAGS  += --sysroot=$(SYSROOT) --gcc-toolchain=$(GCC_TOOLCHAIN)
endif
