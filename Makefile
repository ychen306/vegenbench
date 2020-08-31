.PHONY: all clean

ifeq ($(CXXFLAGS),)
CXXFLAGS := -O3 -mmarch=native -ffast-math
endif

all: bench

bench: kernels.o bench.o
	$(CXX) -o $@ $^ $(CXXFLAGS)

bench.o: bench.cc bench.h 
	$(CXX) -O3 -o $@ $<

clean:
	rm -f *.o bench
