.PHONY: all clean distclean report asm rebuild rebuild_report

CXX = clang++
LD = ld.gold
CXX_ORGANIC = $(shell realpath -s ../organic-llvm-build/bin/clang++)
CXX_VEGEN = $(CXX_ORGANIC)
CXX_12 = $(shell realpath -s ../llvm-12.0.1-build/bin/clang++)
CXX_LATEST = $(shell realpath -s ../llvm-latest-build/bin/clang++)

CXX_ORGANIC_VER = $(shell $(CXX_ORGANIC) --version | head -1)
CXX_VEGEN_INTER_VER = $(shell $(CXX_VEGEN) --version | head -1) Vegen Inter-Block Optimised
CXX_VEGEN_VER = $(shell $(CXX_VEGEN) --version | head -1) Vegen Optimised
CXX_VEGEN_INTER_REFINED_VER =  $(shell $(CXX_VEGEN) --version | head -1 ) Vegen Inter-Block Optimised (Refined Plans)
CXX_VEGEN_REFINED_VER =  $(shell $(CXX_VEGEN) --version | head -1 ) Vegen Optimised (Refined Plans)
CXX_VEGEN_SLP_REFINED_VER =  $(shell $(CXX_VEGEN) --version | head -1 ) Vegen Optimised (Refined Plans, SLP enabled)
CXX_12_VER = $(shell $(CXX_12) --version | head -1)
CXX_LATEST_VER = $(shell $(CXX_LATEST) --version | head -1)



OPT_FLAGS_BASE = -O3 -ffast-math
OPT_FLAGS = $(OPT_FLAGS_BASE) -march=native
OPT_FLAGS_VEGEN = $(OPT_FLAGS_BASE) -march=skylake -mavx2 -mavx512f -mavx512bw -mavx512vl -msse2 -mcx16 -msahf -mprfchw \
 -mbmi2 -mfsgsbase -mpopcnt -maes -mxsaves -mclwb -mxsavec -mmmx -mrdseed -mclflushopt -mxsave -minvpcid -mavx512cd -mavx \
 -mfma -mrtm -mbmi -mrdrnd -msse4.1 -msse4.2 -mfxsr -msse -mlzcnt -mpclmul -mf16c -mssse3 -mmovbe -mxsaveopt \
 -mavx512dq -madx -msse3
COMP_FLAGS = $(CXXFLAGS) -stdlib=libc++ -std=c++17 -fPIC -L/arm/tools/llvm/clang/12.0.0/rhe7-x86_64/lib -I/arm/tools/llvm/clang/12.0.0/rhe7-x86_64/include/c++/v1/
LINK_FLAGS = $(LDFLAGS) -stdlib=libc++ -std=c++17 -fPIC -L/arm/tools/llvm/clang/12.0.0/rhe7-x86_64/lib -I/arm/tools/llvm/clang/12.0.0/rhe7-x86_64/include/c++/v1/
VEGEN_FLAGS = -Xclang -load -Xclang ../vegen-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=../vegen-build
VEGEN_INTER_FLAGS = -Xclang -load -Xclang ../vegen-inter-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=../vegen-inter-build
VEGEN_REFINED_FLAGS = $(VEGEN_FLAGS) -mllvm -refine-plans
VEGEN_INTER_REFINED_FLAGS = $(VEGEN_INTER_FLAGS) -mllvm -refine-plans
VEGEN_SLP_REFINED_FLAGS = -Xclang -load -Xclang ../vegen-build/gslp/libGSLP.so -mllvm --wrappers-dir=../vegen-build -mllvm -refine-plans

BENCH_LIST = bench-vegen bench-vegen-refined bench-vegen-inter bench-vegen-inter-refined bench-organic bench-12 bench-latest
BENCH_CC = $(addsuffix .cc,$(BENCH_LIST))
KERNEL_CC = $(subst bench,kernels,$(BENCH_CC))
KERNEL_ASM = $(KERNEL_CC:.cc=.s)

all: $(BENCH_LIST)
asm: $(KERNEL_ASM)
rebuild: clean all

report: all
	./compare.py

bench-vegen: kernels-vegen.o bench-vegen.o
	$(CXX_VEGEN) $(LINK_FLAGS) -o $@ $^

bench-vegen-slp-refined: kernels-vegen-slp-refined.o bench-vegen-slp-refined.o
	$(CXX_VEGEN) $(LINK_FLAGS) -o $@ $^

bench-vegen-refined: kernels-vegen-refined.o bench-vegen-refined.o
	$(CXX_VEGEN) $(LINK_FLAGS) -o $@ $^

bench-vegen-inter: kernels-vegen-inter.o bench-vegen-inter.o
	$(CXX_VEGEN) $(LINK_FLAGS) -o $@ $^

bench-vegen-inter-refined: kernels-vegen-inter-refined.o bench-vegen-inter-refined.o
	$(CXX_VEGEN) $(LINK_FLAGS) -o $@ $^

bench-organic: kernels-organic.o bench-organic.o
	$(CXX_ORGANIC) $(LINK_FLAGS) -o $@ $^

bench-12: kernels-12.o bench-12.o
	$(CXX_12) $(LINK_FLAGS) -o $@ $^

bench-latest: kernels-latest.o bench-latest.o
	$(CXX_LATEST) $(LINK_FLAGS) -o $@ $^

bench-vegen-inter.o: bench-vegen-inter.cc bench.h kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_INTER_FLAGS) -o $@ -c $<

bench-vegen-inter-refined.o: bench-vegen-inter-refined.cc bench.h kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_INTER_REFINED_FLAGS) -o $@ -c $<

bench-organic.o: bench-organic.cc bench.h kernels.h
	$(CXX_ORGANIC) $(COMP_FLAGS) $(OPT_FLAGS) -o $@ -c $<

bench-vegen.o: bench-vegen.cc bench.h kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_FLAGS) -o $@ -c $<

bench-vegen-slp-refined.o: bench-vegen-slp-refined.cc bench.h kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_SLP_REFINED_FLAGS) -o $@ -c $<

bench-vegen-refined.o: bench-vegen-refined.cc bench.h kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_REFINED_FLAGS) -o $@ -c $<

bench-12.o: bench-12.cc bench.h kernels.h
	$(CXX_12) $(COMP_FLAGS) $(OPT_FLAGS) -o $@ -c $<

bench-latest.o: bench-latest.cc bench.h kernels.h
	$(CXX_LATEST) $(COMP_FLAGS) $(OPT_FLAGS) -o $@ -c $<

bench-vegen.cc: bench.cc
	./replacer.py target="$@" ver="$(CXX_VEGEN_VER)" flags="$(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_FLAGS)"

bench-vegen-refined.cc: bench.cc
	./replacer.py target="$@" ver="$(CXX_VEGEN_REFINED_VER)" flags="$(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_REFINED_FLAGS)"

bench-vegen-slp-refined.cc: bench.cc
	./replacer.py target="$@" ver="$(CXX_VEGEN_SLP_REFINED_VER)" flags="$(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_SLP_REFINED_FLAGS)"

bench-vegen-inter.cc: bench.cc
	./replacer.py target="$@" ver="$(CXX_VEGEN_INTER_VER)" flags="$(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_INTER_FLAGS)"

bench-vegen-inter-refined.cc: bench.cc
	./replacer.py target="$@" ver="$(CXX_VEGEN_INTER_REFINED_VER)" flags="$(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_INTER_REFINED_FLAGS)"

bench-organic.cc: bench.cc
	./replacer.py target="$@" ver="$(CXX_ORGANIC_VER)" flags="$(COMP_FLAGS) $(OPT_FLAGS)"

bench-12.cc: bench.cc
	./replacer.py target="$@" ver="$(CXX_12_VER)" flags="$(COMP_FLAGS) $(OPT_FLAGS)"

bench-latest.cc: bench.cc
	./replacer.py target="$@" ver="$(CXX_LATEST_VER)" flags="$(COMP_FLAGS) $(OPT_FLAGS)"

kernels-vegen-inter.o: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_INTER_FLAGS) -o $@ -c $<

kernels-vegen-inter-refined.o: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_INTER_REFINED_FLAGS) -o $@ -c $<

kernels-vegen.o: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_FLAGS) -o $@ -c $<

kernels-vegen-refined.o: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_REFINED_FLAGS) -o $@ -c $<

kernels-vegen-slp-refined.o: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_SLP_REFINED_FLAGS) -o $@ -c $<

kernels-organic.o: kernels.cc kernels.h
	$(CXX_ORGANIC) $(COMP_FLAGS) $(OPT_FLAGS) -o $@ -c $<

kernels-12.o: kernels.cc kernels.h
	$(CXX_12) $(COMP_FLAGS) $(OPT_FLAGS) -o $@ -c $<

kernels-latest.o: kernels.cc kernels.h
	$(CXX_LATEST) $(COMP_FLAGS) $(OPT_FLAGS) -o $@ -c $<

kernels-vegen-inter.s: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_INTER_FLAGS) -o $@ -S $<

kernels-vegen-inter-refined.s: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_INTER_REFINED_FLAGS) -o $@ -S $<

kernels-vegen.s: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_FLAGS) -o $@ -S $<

kernels-vegen-refined.s: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_REFINED_FLAGS) -o $@ -S $<

kernels-vegen-slp-refined.s: kernels.cc kernels.h
	$(CXX_VEGEN) $(COMP_FLAGS) $(OPT_FLAGS_VEGEN) $(VEGEN_SLP_REFINED_FLAGS) -o $@ -S $<

kernels-organic.s: kernels.cc kernels.h
	$(CXX_ORGANIC) $(COMP_FLAGS) $(OPT_FLAGS) -o $@ -S $<

kernels-12.s: kernels.cc kernels.h
	$(CXX_12) $(COMP_FLAGS) $(OPT_FLAGS) -o $@ -S $<

kernels-latest.s: kernels.cc kernels.h
	$(CXX_LATEST) $(COMP_FLAGS) $(OPT_FLAGS) -o $@ -S $<

clean:
	rm -f *.o $(BENCH_LIST) $(BENCH_CC)

distclean: clean
	rm -f *.s bench-* kernel-*
