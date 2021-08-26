ifdef FORTRAN_SUPPORTED
  ifdef FORTRAN_BUILD
    LINK := $(FC)
  endif
  ifdef FORTRAN_AND_CXX_BUILD
    LINK := $(CXX)
  endif

  ifdef FORTRAN_CROSS
    config_LASTLIBS := -Wl,-rpath=$(install_prefix)/aarch64/lib \
		       -L$(install_prefix)/aarch64/lib
  else
    config_LASTLIBS := -Wl,-rpath=$(install_prefix)/lib -L$(install_prefix)/lib
  endif
  ifdef FORTRAN_AND_CXX_BUILD
    config_LASTLIBS += -lflang
  endif
endif

include $(srcroot)/config/post/inc/fortran_common.mk
