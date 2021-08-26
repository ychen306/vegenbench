# NOTE: AT THIS TIME ONLY SEMI HOSTING AND LLVM SUPPORTED IN REGRESSION TOOL
#
# common configuration file far regression tool additional feature enabled by
# $(srcroot)/include/cfg/config.json files.
#
# NEON:
# 	o feature enabled : HAVE_SIMD=1
#
# SVE:
# 	o feature enabled : HAVE_SVE=1
#
# SVE2:
# 	o feature enabled : HAVE_SVE2=1
#
# SME1:
# 	o feature enabled : HAVE_MORTLACH=1
#
# SSVE:
# 	o feature enabled : HAVE_MORTLACH=1 MORTLACH_SSVE2=1
#
# SME2:
# 	o feature enabled : HAVE_MORTLACH2=1
#
# MMLA_EXT:
# 	o feature enabled : HAVE_SVE_MMLA_EXT=1

comp_PLATFORM ?= semihosting

include $(srcroot)/config/regression/llvm_common.mk
