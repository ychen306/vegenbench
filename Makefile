.PHONY: all clean report

ifeq ($(CLANG_FLAGS),)
CLANG_FLAGS := -O3 -march=native -ffast-math
endif

ifeq ($(OPTCXX),)
OPTCXX := $(CXX)
endif

EXES = bench bench-ref dotprod dotprod-ref synthetic synthetic-ref

all: $(EXES)

report: $(EXES)
	python3 get-speedup.py

bench: kernels.o bench.o
	$(CXX) -o $@ $^

bench-ref: kernels-ref.o bench.o
	$(CXX) -o $@ $^

bench.o: bench.cc bench.h kernels.h
	$(CXX) -O3 -o $@ $< -std=c++14 -c

dotprod.o: dotprod.cc bench.h kernels.h
	$(CXX) -O3 -o $@ $< -std=c++14 -c

dotprod-ref: kernels-ref.o dotprod.o
	$(CXX) -o $@ $^

dotprod: kernels.o dotprod.o
	$(CXX) -o $@ $^

synthetic: kernels.o synthetic.o
	$(CXX) -o $@ $^

synthetic-ref: kernels-ref.o synthetic.o
	$(CXX) -o $@ $^

synthetic.o: synthetic.cc bench.h kernels.h
	$(CXX) -O3 -o $@ $< -std=c++14 -c

kernels.o: kernels.cc kernels.h
	$(OPTCXX) $(CLANG_FLAGS) -o $@ -c $< -std=c++11

kernels-ref.o: kernels.cc kernels.h
	$(CXX) -O3 -march=native -ffast-math -o $@ -c $< -std=c++11

clean:
	rm -f *.o bench bench-ref
