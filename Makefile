# vim: set ft=asm_ca65 ts=4 sw=4 et cc=80:
# 6502-Retro-Tetris Game
#
# Copyright (c) 2026 David Latham
#
# This code is licensed under the MIT license
#
# https://github.com/6502-retro/6502-retro-tetris

AS=ca65
LD=ld65
TOP = .

LOAD_TRIM = $(TOP)/loadtrim.py
INCLUDES = -I $(TOP)

DEBUG = 0
ASFLAGS = $(INCLUDES) -g --feature labels_without_colons --cpu 65C02 --feature string_escapes -D DEBUG=$(DEBUG)
CFG = $(TOP)/apps.cfg

APPNAME = tet
LOAD_ADDR = 800

BUILD_DIR = build
SOURCES = main.s \
	  vdp.s \
	  sn76489.s

OBJS = $(addprefix $(BUILD_DIR)/, $(SOURCES:.s=.o))

all: clean $(BUILD_DIR)/$(APPNAME).com

clean:
	rm -fr $(BUILD_DIR)/*

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $$(dirname $@)
	$(AS) $(ASFLAGS) -l $(BUILD_DIR)/$*.lst $< -o $@

$(BUILD_DIR)/$(APPNAME).raw: $(OBJS)
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG) $^ -o $@ -m $(BUILD_DIR)/$(APPNAME).map -Ln $(BUILD_DIR)/$(APPNAME).sym

$(BUILD_DIR)/$(APPNAME).com: $(BUILD_DIR)/$(APPNAME).raw
	$(LOAD_TRIM) $(BUILD_DIR)/$(APPNAME).raw $(BUILD_DIR)/$(APPNAME).com $(LOAD_ADDR)

copy: $(BUILD_DIR)/$(APPNAME).com
	../6502-retro-os/py_sfs_v2/cli.py rm \
		-i ../6502-retro-os/py_sfs_v2/6502-retro-sdcard.img \
		-d g://tet.com
	../6502-retro-os/py_sfs_v2/cli.py cp \
		-i ../6502-retro-os/py_sfs_v2/6502-retro-sdcard.img \
		-s $(BUILD_DIR)/$(APPNAME).com \
		-d g://tet.com

