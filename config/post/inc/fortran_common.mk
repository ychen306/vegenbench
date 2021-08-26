# Skip the build if fortran is not supported
ifdef FORTRAN_BUILD
  config_build_fortran := 1
endif
ifdef FORTRAN_AND_CXX_BUILD
  config_build_fortran := 1
endif

ifdef FORTRAN_SUPPORTED
  ifdef config_build_fortran
    $(shell test -f .skip-fortran_$(target) && rm .skip-fortran_$(target))
  endif
else
  ifdef config_build_fortran
    $(shell echo "Fortran is not supported by this target" > .skip-fortran_$(target))
    $(error Fortran benchmarks cannot be compiled with this compiler. SKIP)
  endif
endif
