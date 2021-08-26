ifdef FORTRAN_BUILD
  LINK := $(FC)
endif

ifdef FORTRAN_AND_CXX_BUILD
  LINK := $(CXX)
  config_LASTLIBS := -lgfortran
endif

include $(srcroot)/config/post/inc/fortran_common.mk
