.PHONY: all clean report

ifeq ($(OPTFLAGS),)
OPTFLAGS := -O3 -march=native -ffast-math
endif

ifeq ($(OPTCXX),)
OPTCXX := $(CXX)
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
	$(OPTCXX) $(OPTFLAGS) -o $@ -c $<

kernels-ref.o: kernels.cc kernels.h
	$(CXX) -O3 -march=native -ffast-math -o $@ -c $<

clean:
	rm -f *.o bench
