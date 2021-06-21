.PHONY: all clean report

ifeq ($(OPTFLAGS),)
OPTFLAGS := -O3 -march=native -ffast-math
endif

ifeq ($(OPTCXX),)
OPTCXX := $(CXX)
endif

LIBASAN =
LIBASAN = DYLD_INSERT_LIBRARIES=/Library/Developer/CommandLineTools/usr/lib/clang/12.0.0/lib/darwin/libclang_rt.asan_osx_dynamic.dylib


all: bench bench-ref

report: bench bench-ref
	python get-speedup.py

bench: kernels.o bench.o
	$(CXX) -o $@ $^

bench-ref: kernels-ref.o bench.o
	$(CXX) -o $@ $^

bench.o: bench.cc bench.h kernels.h
	$(CXX) -O3 -o $@ $< -std=c++14 -c

kernels.o: kernels.cc kernels.h
	$(LIBASAN) $(OPTCXX) $(OPTFLAGS) -o $@ -c $< -std=c++11

kernels-ref.o: kernels.cc kernels.h
	$(CXX) -O3 -march=haswell -mavx2 -ffast-math -o $@ -c $< -std=c++11

clean:
	rm -f *.o bench bench-ref
