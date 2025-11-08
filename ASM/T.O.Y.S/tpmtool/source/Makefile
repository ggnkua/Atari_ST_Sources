# Makefile for tpmtool

# Target platform: native or atari
TARGET ?= native

CXXFLAGS = -std=c++23 -Wall -Wextra -Wpedantic -I./include -fno-rtti -fno-exceptions -flto
LDFLAGS = -flto

# Compiler and flags (platform-specific)
ifeq ($(TARGET),atari)
    CXX = m68k-atari-mintelf-g++
    STRIP = m68k-atari-mintelf-strip
    GC_SECTIONS_FLAG = -Wl,--gc-sections,--stack,131072
    BINARY_NAME = TPMTOOL.TTP
else
    CXX = g++
    STRIP = strip
    GC_SECTIONS_FLAG = -Wl,-dead_strip
    BINARY_NAME = tpmtool
endif

# Debug mode: DEBUG=on or DEBUG=off (default: off)
DEBUG ?= off

ifeq ($(DEBUG),on)
    # Debug build: add debug symbols, no optimization
    CXXFLAGS += -g -O0
    STRIP_CMD =
else
    # Release build: optimize and strip symbols
    CXXFLAGS += -Os -ffunction-sections -fdata-sections
    CXXFLAGS += -fmerge-all-constants
    LDFLAGS += $(GC_SECTIONS_FLAG)
    STRIP_CMD = $(STRIP)
endif

# Directories
SRC_DIR = src
OBJ_DIR = obj
INC_DIR = include
ARTIFACTS_DIR = artifacts

# Output binary
OUTPUT_BINARY = $(ARTIFACTS_DIR)/$(BINARY_NAME)

# Source files
SRCS = $(wildcard $(SRC_DIR)/*.cpp)
OBJS = $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))

# Default target
all: $(OUTPUT_BINARY)

# Link the final executable
$(OUTPUT_BINARY): $(OBJS) | $(ARTIFACTS_DIR)
	$(CXX) $(LDFLAGS) -o $@ $^
ifneq ($(STRIP_CMD),)
	$(STRIP_CMD) $@
endif

# Compile source files to object files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Special dependency: sndh_writer.o requires player.bin (for #embed)
# player.bin must already exist - build it separately if needed
$(OBJ_DIR)/sndh_writer.o: $(SRC_DIR)/sndh_writer.cpp $(INC_DIR)/sndh.hpp | $(OBJ_DIR)
	@if [ ! -f $(ARTIFACTS_DIR)/player.bin ]; then \
		echo "Error: $(ARTIFACTS_DIR)/player.bin not found!"; \
		echo "Please build player.bin first (e.g., using vasm on player/SNDH.S)"; \
		exit 1; \
	fi
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Create directories if they don't exist
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(ARTIFACTS_DIR):
	mkdir -p $(ARTIFACTS_DIR)

# Clean build artifacts
clean:
	rm -f $(OBJ_DIR)/*.o $(ARTIFACTS_DIR)/tpmtool $(ARTIFACTS_DIR)/TPMTOOL.TTP

# Phony targets
.PHONY: all clean
