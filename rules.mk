# Default rule should be 'all'
.DEFAULT_GOAL := all

# ----------------------------------------------------------------------------
#  Environment

# Use some sensible defaults for target and config
target ?= a.out

# Re-define srcroot if we get here without being included in another makefile
srcroot ?= $(realpath $(dir $(filter %/rules.mk, $(abspath $(MAKEFILE_LIST)))))

# Include the compiler configuration environment if it has not been included
# already. This should set things such as CC, CXX, and config_XXX variables.
ifeq ($(filter $(srcroot)/config/$(config).mk, $(realpath $(MAKEFILE_LIST))),)
  include $(srcroot)/config/$(config).mk
endif

# Include any post-bench.mk compiler configuration files
ifneq ($(wildcard $(srcroot)/config/post/$(config).mk),)
  include $(srcroot)/config/post/$(config).mk
endif

# ----------------------------------------------------------------------------
#  Build variables

OUTPUT_OPTION = -o $@

# Preprocessor
target_CPPFLAGS = $(config_CPPFLAGS) $(CPPFLAGS)

# C
target_CFLAGS = $(config_CFLAGS) $(CFLAGS) $(CPORTABILITY) $(COPTIMIZE)
COMPILE.c = $(CC) $(target_CFLAGS) $(target_CPPFLAGS) $(TARGET_ARCH) -c

# C++
target_CXXFLAGS = $(config_CXXFLAGS) $(CXXFLAGS) $(CXXPORTABILITY) $(CXXOPTIMIZE)
COMPILE.cc  = $(CXX) $(target_CXXFLAGS) $(target_CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.cpp = $(COMPILE.cc)
COMPILE.C   = $(COMPILE.cc)

# Assembly
target_ASFLAGS = $(config_ASFLAGS) $(ASFLAGS) $(ASPORTABILITY) $(ASOPTIMIZE)
COMPILE.s    = $(AS) $(target_ASFLAGS) $(TARGET_MACH)
PREPROCESS.S = $(CC) -E $(target_CPPFLAGS)

# Fortran
target_FCFLAGS = $(config_FCFLAGS) $(FCFLAGS) $(FCPORTABILITY) $(FCOPTIMIZE)
COMPILE.f   = $(FC) $(target_FCFLAGS) $(TARGET_ARCH) -c
COMPILE.F   = $(FC) $(target_FCFLAGS) $(target_CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.f90 = $(COMPILE.f)
COMPILE.F90 = $(COMPILE.F)

# Linking
target_LDFLAGS = $(config_LDFLAGS) $(LDFLAGS) $(LDPORTABILITY) $(LDOPTIMIZE)
target_LDLIBS  = $(config_LDLIBS) $(LOADLIBES) $(LDLIBS) $(config_LASTLIBS)
target_LIBS    = $(LIBS)
LINK.o = $(LINK) $(target_LDFLAGS) $(TARGET_ARCH)

# Disassembly
target_ODFLAGS = $(config_ODFLAGS) $(ODFLAGS)

# Building
sandbox      = .build_$(target)
sandbox_OBJS = $(addprefix $(sandbox)/, $(OBJS))
sandbox_DIRS = $(patsubst %/,%,$(sort $(sandbox)/ $(dir $(sandbox_OBJS))))
target_DEPS  = $(patsubst %.o,%.d, $(sandbox_OBJS))
target_MODS  = $(shell find $(sandbox) -name '*.mod')
target_OBJS  = $(config_OBJS) $(sandbox_OBJS)
target_ASMS  = $(shell find $(sandbox) -name '*.s')

# Helper function to reverse a list
reverse = $(strip $(if $1,$(call reverse,$(wordlist 2,$(words $1),$1)) $(firstword $1)))

# ----------------------------------------------------------------------------
#  Targets

.PHONY: all
all: $(target).dis.gz

.PHONY: clean
clean:
	-$(RM) $(target) $(target).dis.gz
	-$(RM) $(target_OBJS) $(target_ASMS) $(target_MODS)

.PHONY: distclean
distclean: clean
	-$(RM) $(target_DEPS)
	-rmdir $(call reverse,$(sandbox_DIRS))

# This behaves like the standard 'install' targets, but it installs in-place
# (i.e. where the build occurred). This is done by simply deleting all the
# build generated files, but keeping the final target.
.PHONY: install
install: all
	-$(RM) $(target_OBJS) $(target_ASMS) $(target_MODS)
	-$(RM) $(target_DEPS)
	-rmdir $(call reverse,$(sandbox_DIRS))

.PHONY: help
help:
	@echo ""
	@echo "usage: make config=<path> [target=<name>] {action}"
	@echo ""
	@echo "'config' is the path to compiler configuration file"
	@echo ""
	@echo "'action' is one of 'help', 'all', 'install', 'clean', 'distclean',"
	@echo "'list_makefiles', 'list_sources', 'comp_config', etc. (default is 'all')"
	@echo ""
	@echo "'target' is the name of the target executable (default is 'a.out')"
	@echo ""

# List all makefiles for this target and configuration,
# as paths relative to $(srcroot)
.PHONY: list_makefiles
list_makefiles:
	@set -e; read -a TMP <<< \
	"$(subst $(srcroot)/,,$(realpath $(filter-out %.d, $(MAKEFILE_LIST))))"; \
	printf -- '%s\n' "$${TMP[@]}"

# List all source and header files for this target and configuration,
# as paths relative to $(srcdir)
.PHONY: list_sources
list_sources: $(target_DEPS)
	@set -e; read -a TMP <<< `cat $(wildcard $(target_DEPS)) | sed 's,^.*\.d : ,,'`; \
	printf -- '%s\n' "$${TMP[@]}" | sed s'|^\s*$(srcdir)/||' | sort -u

# Get the actual config info
.PHONY: comp_info
comp_info:
	@echo $(comp_PLATFORM)
	@echo $(comp_LANG)

# Get the actual config name
.PHONY: comp_config
comp_config:
	@echo $(config)

$(sandbox_DIRS):
	@mkdir -p $@

# This is the actual build target!
$(target): $(target_OBJS) $(target_LIBS)
	$(LINK.o) $(target_OBJS) $(target_LDLIBS) -o $@

# Use this to disassemble the target
$(target).dis.gz: $(target)
	@set -e; set -o pipefail; \
	$(OBJDUMP) $(target_ODFLAGS) $< | gzip --best >| $@

# ----------------------------------------------------------------------------
#  Implicit rules

# C
$(sandbox)/%.o: %.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<

# C++
$(sandbox)/%.o: %.C
	$(COMPILE.C) $(OUTPUT_OPTION) $<

$(sandbox)/%.o: %.cc
	$(COMPILE.cc) $(OUTPUT_OPTION) $<

$(sandbox)/%.o: %.cpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

# Assembly
$(sandbox)/%.s: %.S
	$(PREPROCESS.S) $< > $@

$(sandbox)/%.o: $(sandbox)/%.s
	$(COMPILE.s) -o $@ $<

$(sandbox)/%.o: %.s
	$(COMPILE.s) -o $@ $<

# Fortran
$(sandbox)/%.o: %.f
	$(COMPILE.f) $(OUTPUT_OPTION) $<

$(sandbox)/%.o: %.f90
	$(COMPILE.f90) $(OUTPUT_OPTION) $<

$(sandbox)/%.o: %.F
	$(COMPILE.F) $(OUTPUT_OPTION) $<

$(sandbox)/%.o: %.F90
	$(COMPILE.F90) $(OUTPUT_OPTION) $<

# ----------------------------------------------------------------------------
#  Dependences

-include $(target_DEPS)

$(sandbox_OBJS): | $(sandbox_DIRS)

$(target_DEPS): | $(sandbox_DIRS)

$(sandbox)/%.d: %.c
	$(shell set -e; $(RM) $@; \
	$(CC) -MM -MG $(target_CFLAGS) $(target_CPPFLAGS) $(TARGET_ARCH) $< | \
	sed 's,\($(*F)\)\.o[ :]*,\1.o $@ : ,g' > $@ )

$(sandbox)/%.d: %.C
	$(shell set -e; $(RM) $@; \
	$(CXX) -MM -MG $(target_CXXFLAGS) $(target_CPPFLAGS) $(TARGET_ARCH) $< | \
	sed 's,\($(*F)\)\.o[ :]*,\1.o $@ : ,g' > $@ )

$(sandbox)/%.d: %.cc
	$(shell set -e; $(RM) $@; \
	$(CXX) -MM -MG $(target_CXXFLAGS) $(target_CPPFLAGS) $(TARGET_ARCH) $< | \
	sed 's,\($(*F)\)\.o[ :]*,\1.o $@ : ,g' > $@ )

$(sandbox)/%.d: %.cpp
	$(shell set -e; $(RM) $@; \
	$(CXX) -MM -MG $(target_CXXFLAGS) $(target_CPPFLAGS) $(TARGET_ARCH) $< | \
	sed 's,\($(*F)\)\.o[ :]*,\1.o $@ : ,g' > $@ )

$(sandbox)/%.d: %.S
	$(shell set -e; $(RM) $@; \
	$(CC) -MM -MG $(target_CPPFLAGS) $< | \
	sed 's,\($(*F)\)\.o[ :]*,\1.o $@ : ,g' > $@ )

$(sandbox)/%.d: %.s
	$(shell echo "$(*F).o $@ : $^" > $@ )

$(sandbox)/%.d: %.f
	$(shell set -e; $(RM) $@; \
	$(CPP) -E -MM -MG $(target_CPPFLAGS) $< | \
	sed 's,\($(*F)\)\.o[ :]*,\1.o $@ : ,g' > $@ )

$(sandbox)/%.d: %.f90
	$(shell set -e; $(RM) $@; \
	$(CPP) -E -MM -MG $(target_CPPFLAGS) $< | \
	sed 's,\($(*F)\)\.o[ :]*,\1.o $@ : ,g' > $@ )

$(sandbox)/%.d: %.F
	$(shell set -e; $(RM) $@; \
	$(CPP) -E -MM -MG $(target_CPPFLAGS) $< | \
	sed 's,\($(*F)\)\.o[ :]*,\1.o $@ : ,g' > $@ )

$(sandbox)/%.d: %.F90
	$(shell set -e; $(RM) $@; \
	$(CPP) -E -MM -MG $(target_CPPFLAGS) $< | \
	sed 's,\($(*F)\)\.o[ :]*,\1.o $@ : ,g' > $@ )
