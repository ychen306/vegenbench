# Configure the environment for AArch64 cross-compilation with GCC
# using a newlib-based target.

# Allow the environment to override the prefix, e.g. to remove the
# "unknown".
TARGET_PREFIX ?= aarch64-none-elf-

# NEWLIB explicitly set by the user
ifdef library_prefix
  NEWLIB := $(library_prefix)
endif

ifndef NEWLIB
  ifneq (,$(wildcard $(install_prefix)/aarch64-none-elf/lib/librdimon.a))
    # We are using the warehouse build of the tools which includes newlib
    NEWLIB := $(install_prefix)
  else ifneq (,$(wildcard $(install_prefix)/aarch64-elf/lib/librdimon.a))
    # We are using the warehouse build of the tools which includes newlib
    NEWLIB := $(install_prefix)
  else ifneq (,$(wildcard /opt/aarch64-newlib/aarch64-elf))
    # This location is standard on mdc servers
    # (chef installed, see llvm-tools repo)
    NEWLIB := /opt/aarch64-newlib/aarch64-elf
  else
    $(error "Could not find newlib installation, please define library_prefix or NEWLIB")
  endif
endif

# We can't pull in the whole newlib lib directory, since it will
# override our libgcc.a, so pull in librdimon.a manually (it's needed
# by gap for ttyname)
ifneq ($(install_prefix),$(NEWLIB))
  ttyname_hack := $(NEWLIB)/lib/librdimon.a
  newlib_include := -I$(NEWLIB)/include
endif

config_CPPFLAGS += -DSEMIHOSTING $(newlib_include)
config_LDFLAGS  += $(ttyname_hack) --specs=aem-validation.specs
