CPPFLAGS += -DGEM5_SIMULATION -I$(srcroot)/m5utils

vpath %.S $(srcroot)

OBJS += m5utils/m5op_arm_A64.o
