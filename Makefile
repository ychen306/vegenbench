.PHONY: all clean report

UNAME_P = $(shell uname -p)

#ifeq ($(OPTFLAGS),)
OPTFLAGS := -Ofast $(ARCH)
#endif

OPTFLAGS_VEGEN := $(OPTFLAGS) -Xclang -load -Xclang ../vegen-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=../vegen-build

ifeq ($(OPTCXX),)
OPTCXX := $(CXX)
endif

all: bench bench-ref

report: bench bench-ref
	python get-speedup.py

bench: kernels.o bench.o
	$(CXX) $(CXXFLAGS) $(OPTFLAGS_VEGEN) -o $@ $^

bench-ref: kernels-ref.o bench.o
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) -o $@ $^

bench.o: bench.cc bench.h kernels.h
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) -o $@ $< -std=c++14 -c

kernels.o: kernels.cc kernels.h
	$(OPTCXX) $(CXXFLAGS) $(OPTFLAGS_VEGEN) -o $@ -c $< -std=c++11

kernels-ref.o: kernels.cc kernels.h
	$(CXX) $(CXXFLAGS) $(ARCH) $(OPTFLAGS) -o $@ -c $< -std=c++11

clean:
	rm -f *.o bench bench-ref
