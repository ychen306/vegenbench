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

ifeq ($(target), bench)
    OBJS := bench.o kernels.o
    CPPFLAGS += -O3 -ffast-math -Xclang -load -Xclang ../vegen-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=$(srcdir)/../vegen-build $(MFLAGS)
endif

ifeq ($(target), bench-refine)
    OBJS := bench.o kernels.o
    CPPFLAGS += -O3 -ffast-math -Xclang -load -Xclang ../vegen-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=$(srcdir)/../vegen-build -mllvm -refine-plans  $(MFLAGS)
endif

ifeq ($(target), bench-inter)
    OBJS := bench.o kernels.o
    CPPFLAGS += -O3 -ffast-math -Xclang -load -Xclang ../vegen-inter-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=$(srcdir)/../vegen-inter-build  $(MFLAGS)
endif

ifeq ($(target), bench-inter-refine)
    OBJS := bench.o kernels.o
    CPPFLAGS += -O3 -ffast-math -Xclang -load -Xclang ../vegen-inter-build/gslp/libGSLP.so -fno-slp-vectorize -mllvm --wrappers-dir=$(srcdir)/../vegen-inter-build -mllvm -refine-plans  $(MFLAGS)
endif

ifeq ($(target), bench-ref)
    OBJS := bench.o kernels.o
    CPPFLAGS += -O3 -ffast-math  $(MFLAGS)
endif

include $(srcroot)/rules.mk
