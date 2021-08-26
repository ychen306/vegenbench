# Check for presence of SVE versions and ASIMD through ACLE macros.
# Add config_CFLAGS as well in case the architecture is specified as part of an -mcpu=.
TARGET_SVE := $(shell ! $(CC) $(TARGET_ARCH) $(config_CFLAGS) -dM -E - < /dev/null | grep __ARM_FEATURE_SVE > /dev/null ; echo $$?)
TARGET_SVE2 := $(shell ! $(CC) $(TARGET_ARCH) $(config_CFLAGS) -dM -E - < /dev/null | grep __ARM_FEATURE_SVE2 > /dev/null ; echo $$?)
TARGET_SIMD := $(shell ! $(CC) $(TARGET_ARCH) $(config_CFLAGS) -dM -E - < /dev/null | grep __ARM_NEON > /dev/null ; echo $$?)

ifeq ($(TARGET_SIMD), 1)
  config_CFLAGS   += -fopenmp-simd
  config_CXXFLAGS += -fopenmp-simd
  config_FCFLAGS  += -fopenmp-simd
  config_CPPFLAGS += -DHAVE_SIMD
  # We should get rid of these eventually from all the sub-makefiles.
  HAVE_SIMD := 1
endif

ifeq ($(TARGET_SVE), 1)
  config_CPPFLAGS += -DHAVE_SVE
  # We should get rid of these eventually from all the sub-makefiles.
  HAVE_SVE := 1
endif

ifeq ($(TARGET_SVE2), 1)
  config_CPPFLAGS += -DHAVE_SVE2
  # We should get rid of these eventually from all the sub-makefiles.
  HAVE_SVE2 := 1
endif
