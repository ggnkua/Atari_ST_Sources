help:
	@( \
		echo "--- download and build tool chain for Atari ST/Falcon ---"; \
		echo ""; \
		echo "available targets:"; \
		echo "  binutils - GNU assembler, linker"; \
		echo "  gcc      - GNU C++ compiler"; \
		echo "  cleanall - remove all downloaded and generated files"; \
		echo "  clean    - like cleanall but keep the build results"; \
		echo ""; \
		echo "suggested arguments:"; \
		echo "  -j8 - enable parallel build"; \
		echo ""; \
		echo "The results are installed into the 'install/' directory."; \
		echo "" \
	)

INSTALL_DIR := $(PWD)/install
CONTRIB_DIR := $(PWD)/contrib
BUILD_DIR   := $(PWD)/build

# let gcc build process find binutils
export PATH := $(INSTALL_DIR)/bin:$(PATH)

PROGRAM_PREFIX := m68k

TARGET_NAME     := m68k-atari-mint

COMMON_CONFIG   := $(CONFIG_QUIET) \
                   --prefix=$(INSTALL_DIR) \
                   --program-prefix=$(PROGRAM_PREFIX)- \
                   --target=$(TARGET_NAME) \
                   --program-transform-name="s/$(TARGET_NAME)/$(PROGRAM_PREFIX)/"

BINUTILS_CONFIG += $(COMMON_CONFIG) \
                   --disable-werror \
                   --disable-gdb \
                   --disable-nls \
                   --enable-obsolete

GCC_CONFIG      := $(COMMON_CONFIG) \
                   --enable-languages=c++ \
                   --with-gnu-as \
                   --with-gnu-ld \
                   --disable-libssp \
                   --disable-nls \
                   --disable-libstdcxx-pch \
                   --disable-multilib \
                   --disable-shared \
                   --disable-tls \
                   --disable-libgomp \
                   --disable-libstdcxx

BINUTILS := m68k-atari-mint-binutils-gdb
GCC      := m68k-atari-mint-gcc

GIT_URL_$(BINUTILS)    := https://github.com/freemint/$(BINUTILS).git
GIT_URL_$(GCC)         := https://github.com/freemint/$(GCC).git
GIT_BRANCH_$(BINUTILS) := binutils-2_30-mint
GIT_BRANCH_$(GCC)      := gcc-7-mint

BINUTILS_DIR := $(CONTRIB_DIR)/$(BINUTILS)
GCC_DIR      := $(CONTRIB_DIR)/$(GCC)

BINUTILS_BINARIES           := $(BUILD_DIR)/$(BINUTILS)/binutils/objdump
BINUTILS_INSTALLED_BINARIES := $(INSTALL_DIR)/bin/$(PLATFORM)-objdump
GCC_BINARIES                := $(BUILD_DIR)/$(GCC)/gcc/g++-cross
GCC_INSTALLED_BINARIES      := $(INSTALL_DIR)/bin/$(PLATFORM)-g++

all: $(BINUTILS_INSTALLED_BINARIES) gcc binutils

.PHONY: gcc binutils

binutils: $(BINUTILS_INSTALLED_BINARIES)
gcc:      $(GCC_INSTALLED_BINARIES)

$(CONTRIB_DIR) $(BUILD_DIR):
	mkdir -p $@

$(BINUTILS_DIR)/configure $(GCC_DIR)/configure: $(CONTRIB_DIR)

$(BINUTILS_DIR)/configure:
	git clone --depth 1 --branch ${GIT_BRANCH_$(BINUTILS)} ${GIT_URL_$(BINUTILS)} $(BINUTILS_DIR)

$(GCC_DIR)/configure:
	git clone --depth 1 --branch ${GIT_BRANCH_$(GCC)} ${GIT_URL_$(GCC)} $(GCC_DIR)

$(BUILD_DIR)/$(BINUTILS)/Makefile: $(MAKEFILE_LIST) $(BINUTILS_DIR)/configure
	mkdir -p $(dir $@)
	cd $(dir $@); $(BINUTILS_DIR)/configure $(BINUTILS_CONFIG)

# gcc must be configured not before binutils are installed
$(BUILD_DIR)/$(GCC)/Makefile: $(MAKEFILE_LIST) $(GCC_DIR)/configure $(BINUTILS_INSTALLED_BINARIES)
	mkdir -p $(dir $@)
	cd $(dir $@); $(GCC_DIR)/configure $(GCC_CONFIG)

$(BINUTILS_BINARIES): $(BUILD_DIR)/$(BINUTILS)/Makefile
	$(MAKE) -C $(dir $<)

$(GCC_BINARIES): $(BUILD_DIR)/$(GCC)/Makefile
	$(MAKE) -C $(dir $<)

$(BINUTILS_INSTALLED_BINARIES): $(BINUTILS_BINARIES)
	$(VERBOSE)for i in binutils gas ld intl opcodes; do \
		$(MAKE) -C $(BUILD_DIR)/$(BINUTILS)/$$i install-strip; done

$(GCC_INSTALLED_BINARIES): $(GCC_BINARIES)
	$(MAKE) -C $(BUILD_DIR)/$(GCC) install-strip

clean:
	rm -rf $(BUILD_DIR) $(CONTRIB_DIR)

cleanall: clean
	rm -rf $(INSTALL_DIR)
