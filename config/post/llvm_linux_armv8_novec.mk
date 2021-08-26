# Generate scalar-only code
COPTIMIZE   += -fno-vectorize -fno-slp-vectorize
CXXOPTIMIZE += -fno-vectorize -fno-slp-vectorize

include $(srcroot)/config/post/inc/llvm_common.mk
