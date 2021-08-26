# Set baremetal elf target
ifdef HAVE_MVE
		TARGET_TRIPLE ?= arm-arm-none-eabi
else
		TARGET_TRIPLE ?= aarch64-none-elf
		config_CPPFLAGS += -DSEMIHOSTING
endif

ifndef LLVM_NO_NEWLIB
  # NEWLIB explicitly set by the user
  ifdef library_prefix
    NEWLIB := $(library_prefix)
  endif
  
  # Search for newlib installation (if not defined in env or explicitly set)
  ifndef NEWLIB
    ifneq (,$(wildcard $(install_prefix)/.tools))
      # We are using the warehouse build of the tools which includes newlib
      NEWLIB := $(install_prefix)
    else ifneq (,$(wildcard /opt/aarch64-newlib/aarch64-elf))
      # Standard location on MDC servers (chef installed, see llvm-tools repo)
      NEWLIB := /opt/aarch64-newlib/aarch64-elf
    else ifneq (,$(wildcard /opt/aarch64-none-elf))
      # Typical location of a Linaro installation
      NEWLIB := /opt/aarch64-none-elf
    else
      $(error "Could not find newlib installation, please define library_prefix or NEWLIB")
    endif
  endif
  
  # Do not require users to specify the internal path in the packaged compiler
  ifneq (,$(wildcard $(NEWLIB)/.tools/toolchain/opt/aarch64-newlib/aarch64-elf))
    NEWLIB := $(NEWLIB)/.tools/toolchain/opt/aarch64-newlib/aarch64-elf
  endif
	ifndef HAVE_MVE
		config_CPPFLAGS += --sysroot=$(NEWLIB)
		config_LDFLAGS  += --sysroot=$(NEWLIB)
	endif
endif

# GCC_BAREMETAL explicitly set by the user
ifndef LLVM_NO_GCC_TOOLCHAIN
  ifdef linker_prefix
    GCC_BAREMETAL := $(linker_prefix)
  endif
  
  # Search for baremetal GCC for linkning (if not defined in env).
  ifndef GCC_BAREMETAL
    ifneq (,$(shell which aarch64-none-elf-gcc 2>/dev/null))
      # Found baremetal gcc in the user's path
      GCC_BAREMETAL := $(dir $(shell which aarch64-none-elf-gcc 2>/dev/null))
    else ifneq (,$(wildcard /arm/pdtl/builds/latest-fsf-7/installed/rhe6x86_64/aarch64-none-elf))
      # We are on EUHPC, use the latest PDTL build
      GCC_BAREMETAL := /arm/pdtl/builds/latest-fsf-7/installed/rhe6x86_64/aarch64-none-elf
    else ifneq (,$(wildcard /arm/tools/linaro/gcc-aarch64-none-elf/4.9-2014.06-02))
      # We are on NAHPC, use the latest Linaro build
      GCC_BAREMETAL := /arm/tools/linaro/gcc-aarch64-none-elf/4.9-2014.06-02
    else ifneq (,$(wildcard /opt/aarch64-bare-metal-cross-compiler))
      # Standard location on MDC servers
      GCC_BAREMETAL := /opt/aarch64-bare-metal-cross-compiler
    else ifneq (,$(wildcard /opt/aarch64-none-elf))
      # Typical location of a Linaro installation
      GCC_BAREMETAL := /opt/aarch64-none-elf
    else
      $(error "Could not find aarch64-none-elf-gcc, please define linker_prefix or GCC_BAREMETAL")
    endif
  endif
  
  ifneq (,$(wildcard $(GCC_BAREMETAL)/bin))
    config_LDFLAGS += -B$(GCC_BAREMETAL)/bin
  else
    config_LDFLAGS += -B$(GCC_BAREMETAL)
  endif
endif
