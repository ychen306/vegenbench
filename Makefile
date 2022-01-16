.PHONY: all clean report

UNAME_P = $(shell uname -p)

ifeq ($(UNAME_P),aarch64)
ARCH :=
else
ARCH := -march=native
endif

ifeq ($(OPTFLAGS),)
OPTFLAGS := -O3 $(ARCH) -ffast-math -march=haswell -mavx512f -mavx512vl -mavx512vnni -mavx512bw -mllvm -refine-plans -mllvm -allow-transpose -mllvm -allow-deinterleave
OPTFLAGS := -O3 -march=haswell -mavx2 -mavx512f -mavx512bw -mavx512vl -mavx512vnni -mllvm -allow-deinterleave -mllvm -allow-transpose
OPTFLAGS := -O3 -march=native -ffast-math -mllvm -allow-transpose -mllvm -allow-deinterleave
OPTFLAGS := -O3 -ffast-math -march=haswell -mavx512f -mavx512vl -mavx512vnni -mavx512bw -mllvm -allow-transpose -mllvm -allow-deinterleave -mllvm -filter=sbc -mllvm -debug-only=heuristic
OPTFLAGS := -O3 -ffast-math -march=haswell -mavx512f -mavx512vl -mavx512vnni -mavx512bw -mllvm -allow-transpose -mllvm -allow-deinterleave
endif

ifeq ($(OPTCXX),)
OPTCXX := vegen-clang
endif

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
	$(OPTCXX) $(OPTFLAGS) -o $@ -c $< -std=c++11

kernels-ref.o: kernels.cc kernels.h
	$(CXX) -O3 $(ARCH) -ffast-math -o $@ -c $< -std=c++11

clean:
	rm -f *.o bench bench-ref
