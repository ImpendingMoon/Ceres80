#******************************************************************************
# @file Makefile
# @brief ROSS Makefile
# @license BSD-3-Clause
#******************************************************************************

PROJECT_NAME := ROSS
ROM_SIZE := 0x8000

CC := sdcc
AS := sdasz80
LD := sdcc
HEX := makebin

CFLAGS := -mz80 -c --reserve-regs-iy --opt-code-speed --max-allocs-per-node 1000000 --std-sdcc99
AFLAGS := -g
LFLAGS := -mz80 --reserve-regs-iy --no-std-crt0 --code-loc 0x003B --data-loc 0xF980 --constseg _CODE

CRT_FILE := crt0
MAIN_FILE := main

SRC_DIR := src
BLD_DIR := build
OBJ_DIR := $(BLD_DIR)/obj
BIN_DIR := $(BLD_DIR)/bin



.PHONY: all clean vars



# C runtime and main function MUST be linked first.
ORDERED_OBJS := $(OBJ_DIR)/$(CRT_FILE).rel $(OBJ_DIR)/$(MAIN_FILE).rel

SRCS := $(wildcard $(SRC_DIR)/*.c) $(wildcard $(SRC_DIR)/*.s)

# Make a list of all .s and .c files into .rel files,
# Make a list of crt0.s.rel and main.c.rel, since they need to be linked first
# Remove crt0.s.rel and main.c.rel from OBJS
# I will not subject anyone to a one-liner of this
OBJS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.c.rel,$(filter %.c,$(SRCS))) \
        $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.s.rel,$(filter %.s,$(SRCS)))

ORDERED_OBJS := $(OBJ_DIR)/$(CRT_FILE).s.rel $(OBJ_DIR)/$(MAIN_FILE).c.rel

OBJS := $(filter-out $(ORDERED_OBJS),$(OBJS))




IHX := $(BLD_DIR)/$(PROJECT_NAME).ihx
BIN := $(BIN_DIR)/$(PROJECT_NAME).bin

$(BIN): $(IHX)
	mkdir -p $(@D)
	$(HEX) -p -s $(ROM_SIZE) < $< > $@

$(IHX): $(ORDERED_OBJS) $(OBJS)
	$(LD) $(LFLAGS) $^ -o $@

# Use compiler for C files in SRCS
$(OBJ_DIR)/%.c.rel: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $< -o $@

# Use assembler for S files in SRCS
$(OBJ_DIR)/%.s.rel: $(SRC_DIR)/%.s
	mkdir -p $(@D)
	$(AS) $(AFLAGS) -o $@ $<



all: $(BIN)



clean:
	rm -rf $(BLD_DIR)



vars:
	$(info PROJECT_NAME is $(PROJECT_NAME))
	$(info ---)
	$(info CC is $(CC))
	$(info AS is $(AS))
	$(info LD is $(LD))
	$(info ---)
	$(info CFLAGS is $(CFLAGS))
	$(info AFLAGS is $(AFLAGS))
	$(info LFLAGS is $(LFLAGS))
	$(info ---)
	$(info SRC_DIR is $(SRC_DIR))
	$(info BLD_DIR is $(BLD_DIR))
	$(info OBJ_DIR is $(OBJ_DIR))
	$(info BIN_DIR is $(BIN_DIR))
	$(info ---)
	$(info ORDERED_OBJS is $(ORDERED_OBJS))
	$(info SRCS is $(SRCS))
	$(info OBJS is $(OBJS))
	$(info ---)
	$(info IHX is $(IHX))
	$(info BIN is $(BIN))
