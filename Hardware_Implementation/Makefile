# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

SHELL = /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

INSTALL_PREFIX        ?= install
INSTALL_DIR           = ${ROOT_DIR}/${INSTALL_PREFIX}
BENDER_INSTALL_DIR    = ${INSTALL_DIR}/bender

VENV_BIN=venv/bin/

BENDER_VERSION = 0.28.1
SIM_PATH   ?= modelsim/build
SYNTH_PATH  = synopsys

BENDER_TARGETS = -t rtl -t test

target ?= sim_tb_accelerator_streamer

VLOG_FLAGS += -svinputport=compat
VLOG_FLAGS += -timescale 1ns/1ps

STIMULI_DIR ?= ${ROOT_DIR}/verif/python/generated

# Default file paths (overridable)
DATA_GOLDEN_PATH            ?= ${STIMULI_DIR}/data_constants.txt
INITIAL_MEMORY_CONTENT_PATH ?= ${STIMULI_DIR}/initial_memory.txt
X_GOLDEN_PATH               ?= ${STIMULI_DIR}/x_order.txt
Y_GOLDEN_PATH               ?= ${STIMULI_DIR}/y_order.txt
Z_GOLDEN_PATH               ?= ${STIMULI_DIR}/z_order.txt

# Testbench parameters (defaults, overridable)
MP                   ?= 4
META_CHUNK_SIZE      ?= 128
X_ITEM_SIZE          ?= 32
Y_ITEM_SIZE          ?= 32
Z_ITEM_SIZE          ?= 64
Y_BLOCK_SIZE         ?= 4

# Addresses are interpreted as hexadecimal
X_BASE_ADDRESS       ?= 0
Y_BASE_ADDRESS       ?= 2000000
Z_BASE_ADDRESS       ?= 4000000
X_COLUMNS            ?= 16
Y_COLUMNS            ?= 16
X_ROWS               ?= 2
Y_ROWS               ?= 16
X_SPARSITY					 ?= 0.95

ifeq ("$(wildcard $(DATA_GOLDEN_PATH))","")
  $(error DATA_GOLDEN_PATH '$(DATA_GOLDEN_PATH)' not found )
endif

X_TOTAL_LOADS := $(shell awk 'NR==1 {print $$1}' $(DATA_GOLDEN_PATH))
Y_TOTAL_LOADS := $(shell awk 'NR==1 {print $$2}' $(DATA_GOLDEN_PATH))
X_TCDM_TOTAL_LOADS := $(shell awk 'NR==1 {print $$3}' $(DATA_GOLDEN_PATH))

TESTBENCH_DEFINES += \
  -DMP=$(MP) \
  -DMETA_CHUNK_SIZE=$(META_CHUNK_SIZE) \
  -DX_ITEM_SIZE=$(X_ITEM_SIZE) \
  -DY_ITEM_SIZE=$(Y_ITEM_SIZE) \
  -DZ_ITEM_SIZE=$(Z_ITEM_SIZE) \
  -DY_BLOCK_SIZE=$(Y_BLOCK_SIZE) \
  -DX_BASE_ADDRESS=$(X_BASE_ADDRESS) \
  -DY_BASE_ADDRESS=$(Y_BASE_ADDRESS) \
  -DZ_BASE_ADDRESS=$(Z_BASE_ADDRESS) \
  -DX_COLUMNS=$(X_COLUMNS) \
  -DY_COLUMNS=$(Y_COLUMNS) \
  -DX_ROWS=$(X_ROWS) \
  -DY_ROWS=$(Y_ROWS) \
  -DX_TCDM_TOTAL_LOADS=$(X_TCDM_TOTAL_LOADS) \
  -DX_TOTAL_LOADS=$(X_TOTAL_LOADS) \
  -DY_TOTAL_LOADS=$(Y_TOTAL_LOADS) \
  -DDATA_GOLDEN_PATH=\"$(DATA_GOLDEN_PATH)\" \
  -DINITIAL_MEMORY_CONTENT_PATH=\"$(INITIAL_MEMORY_CONTENT_PATH)\" \
  -DX_GOLDEN_PATH=\"$(X_GOLDEN_PATH)\" \
  -DY_GOLDEN_PATH=\"$(Y_GOLDEN_PATH)\" \
  -DZ_GOLDEN_PATH=\"$(Z_GOLDEN_PATH)\"

# .PHONY: clean-sim sim-script sim synopsys-script
all: testvector sim

clean-sim:
	rm -rf $(SIM_PATH)/work
	rm -rf $(SIM_PATH)/compile.tcl
	rm -rf $(SIM_PATH)/wlft*
	rm -rf $(SIM_PATH)/transcript
	rm -rf $(SIM_PATH)/modelsim.ini
	rm -rf $(SIM_PATH)/vsim.wlf

sim-script: clean-sim
	mkdir -p $(SIM_PATH)
	$(BENDER_INSTALL_DIR)/bender script vsim $(BENDER_TARGETS) $(TESTBENCH_DEFINES) --vlog-arg="$(VLOG_FLAGS)" >> $(SIM_PATH)/compile.tcl

sim: sim-script
	cd modelsim && \
	$(MAKE) $(target) buildpath=$(ROOT_DIR)/$(SIM_PATH)

stimuli: 
	python -m verif.python.generate_stimuli_streamer \
	  --mp $(MP) \
	  --meta_chunk_size $(META_CHUNK_SIZE) \
	  --x_item_size $(X_ITEM_SIZE) \
	  --y_item_size $(Y_ITEM_SIZE) \
	  --z_item_size $(Z_ITEM_SIZE) \
	  --y_block_size $(Y_BLOCK_SIZE) \
	  --x_base_address $(X_BASE_ADDRESS) \
	  --y_base_address $(Y_BASE_ADDRESS) \
	  --z_base_address $(Z_BASE_ADDRESS) \
	  --x_columns $(X_COLUMNS) \
	  --y_columns $(Y_COLUMNS) \
	  --x_rows $(X_ROWS) \
	  --y_rows $(Y_ROWS) \
	  --x_sparsity $(X_SPARSITY) \
	  --output_dir "verif/python/generated"

# Bender
bender: check-bender
	$(BENDER_INSTALL_DIR)/bender update
	$(BENDER_INSTALL_DIR)/bender vendor init

check-bender:
	@if [ -x $(BENDER_INSTALL_DIR)/bender ]; then \
		req="bender $(BENDER_VERSION)"; \
		current="$$($(BENDER_INSTALL_DIR)/bender --version)"; \
		if [ "$$(printf '%s\n' "$${req}" "$${current}" | sort -V | head -n1)" != "$${req}" ]; then \
			rm -rf $(BENDER_INSTALL_DIR); \
		fi \
	fi
	@$(MAKE) -C $(ROOT_DIR) $(BENDER_INSTALL_DIR)/bender

$(BENDER_INSTALL_DIR)/bender:
	mkdir -p $(BENDER_INSTALL_DIR) && cd $(BENDER_INSTALL_DIR) && \
	curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh -s -- $(BENDER_VERSION)
