srcdir := $(patsubst %/,%, $(dir $(filter %/bench.mk, $(abspath $(MAKEFILE_LIST)))))
srcroot := $(realpath $(srcdir))

include $(srcroot)/config/$(config).mk

vpath %.c $(srcdir)
vpath %.cc $(srcdir)
vpath %.s $(srcdir)
vpath %.S $(srcdir)

CPPFLAGS = -I$(srcdir)
LDLIBS = -lm
MFLAGS= -march=armv8.6-a+fp16+crypto+bf16 -mtune=neoverse-n2
CXX = clang++
LD = ld.gold
CXX_ORGANIC = $(CXX)
CXX_VEGEN = $(CXX_ORGANIC)

CXX_ORGANIC_VER = $(shell $(CXX_ORGANIC) --version | head -1)
CXX_VEGEN_INTER_VER = $(shell $(CXX_VEGEN) --version | head -1) Vegen Inter-Block Optimised
CXX_VEGEN_VER = $(shell $(CXX_VEGEN) --version | head -1) Vegen Optimised
CXX_VEGEN_INTER_REFINED_VER =  $(shell $(CXX_VEGEN) --version | head -1 ) Vegen Inter-Block Optimised (Refined Plans)
CXX_VEGEN_REFINED_VER =  $(shell $(CXX_VEGEN) --version | head -1 ) Vegen Optimised (Refined Plans)

$(shell cd $(srcroot); ./replacer.py target="$(target)" ver="$(CXX)" flags="$(CPPFLAGS)"; cd -)

ifeq ($(target), bench-vegen)
    CPPFLAGS += -O3 -ffast-math -Xclang -load -Xclang ../vegen-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=$(srcdir)/../vegen-build $(MFLAGS)
    $(CXX) $(CPPFLAGS) -o kernels-vegen.o -c kernels.cc
    $(CXX) $(CPPFLAGS) -o bench-vegen.o -c bench-vegen.cc
    $(CXX) $(LDLIBS) -o $(target) kernels-vegen.o bench-vegen.o
endif

ifeq ($(target), bench-vegen-refine)
    CPPFLAGS += -O3 -ffast-math -Xclang -load -Xclang ../vegen-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=$(srcdir)/../vegen-build -mllvm -refine-plans  $(MFLAGS)
endif

ifeq ($(target), bench-vegen-inter)
    CPPFLAGS += -O3 -ffast-math -Xclang -load -Xclang ../vegen-inter-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=$(srcdir)/../vegen-inter-build  $(MFLAGS)
endif

ifeq ($(target), bench-vegen-inter-refine)
    CPPFLAGS += -O3 -ffast-math -Xclang -load -Xclang ../vegen-inter-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=$(srcdir)/../vegen-inter-build -mllvm -refine-plans  $(MFLAGS)
endif

ifeq ($(target), bench-organic)
    CPPFLAGS += -O3 -ffast-math  $(MFLAGS)
endif

include $(srcroot)/rules.mk
