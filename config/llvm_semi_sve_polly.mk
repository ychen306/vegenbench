# For compiling with organic clang with SVE and polly optimization enabled
include $(srcroot)/config/inc/llvm_common.mk

arch := armv8-a+shoji
config_CFLAGS += -march=$(arch) -mllvm -enable-load-pre=false -mllvm -polly -mllvm -polly-vectorizer=stripmine
config_CXXFLAGS += -march=$(arch) -mllvm -enable-load-pre=false -mllvm -polly -mllvm -polly-vectorizer=stripmine
config_ODFLAGS += -arch=$(arch) -mattr=+shoji
config_LDFLAGS += -march=$(arch)
