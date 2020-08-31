.PHONY: all clean

ifeq ($(CXXFLAGS),)
CXXFLAGS := -O3 -march=native -ffast-math
endif

all: bench

bench: kernels.o bench.o
	$(CXX) -o $@ $^ $(CXXFLAGS)

bench.o: bench.cc bench.h 
	$(CXX) -O3 -o $@ $< -std=c++14 -c

clean:
	rm -f *.o bench
