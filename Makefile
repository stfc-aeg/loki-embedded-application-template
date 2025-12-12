# Check on Xilinx tools version for the project
TARGET_VIVADO_VERSION=v2023.2
CURRENT_VIVADO_VERSION=$(shell vivado -version | head -n 1 | cut -d' ' -f2)
ifneq (${TARGET_VIVADO_VERSION}, ${CURRENT_VIVADO_VERSION})
$(error Vivado version incorrect, this project uses ${TARGET_VIVADO_VERSION}, and your version is ${CURRENT_VIVADO_VERSION})
endif

# Default Setup - change these in your calling environment
USE_PREBUILT_HW ?= false 	# boolean - set true to use prebuilt hardware instead of garud-fw

# Firmware Project
VIVADO_HARDWARE_OUTPUT_DIR=$(shell pwd)/garud-fw/

# LOKI Submodule environment setup
export LOKI_DIR=./loki/
export APPLICATION_DIR=.
export LOKI_ENV_DIR=.

# If (above) environment variable USE_PREBUILT_HW is set, use the prebuilt hardware. Otherwise build the garud-fw project.
ifeq (${USE_PREBUILT_HW},true)
$(info Building GARUD with prebuilt hardware)
export HW_EXPORT_DIR=$(shell pwd)/prebuilt
else
$(info Building GARUD with garud-fw project hardware)
export HW_EXPORT_DIR=${VIVADO_HARDWARE_OUTPUT_DIR}
endif
export SW_EXPORT_DIR=$(shell pwd)/prebuilt

all: ${HW_EXPORT_DIR}/design_4cg_2gb.xsa ./machine.env os

# Creating this file is in the README but frequently forgotten, and should be done manually
./machine.env:
	$(error Your project has no machine.env; you should create this for your specific setup based on machine.env.example)

VIVADO_SOFTWARE_OUTPUT_DIR=???
# Extra rules to make the prebuilt files in case of hardware design file change.
#prebuilt/design_4cg_2gb.xsa prebuilt/fsbl.elf prebuilt/pmufw.elf:
${VIVADO_HARDWARE_OUTPUT_DIR}/design_4cg_2gb.xsa:
	$(info Build is using the garud-fw project for hardware)
	# Build the hardware and software using the garud firmware submodule
	$(MAKE) -C ./garud-fw/ all

# Include recipes to take the environment and run the configuration using the autoconf params
# Provides loki-configure-hw, loki-configure-sw, loki-configure-os
include ${LOKI_DIR}/config.mk

.PHONY: all os hardware software project local_hardware

project: loki-configure-hw
	# Instead of actually building the hardware, just make the project in Vivado and stop.
	# This now prepares the garud-fw project.
	$(MAKE) -C ./garud-fw/ project

hardware: loki-configure-hw
	$(MAKE) -C ${LOKI_DIR} hardware

software: loki-configure-sw hardware
	$(MAKE) -C ${LOKI_DIR} software

os: loki-configure-os software
	$(MAKE) -C ${LOKI_DIR} os

mostlyclean:
	unset HW_EXPORT_DIR
	$(MAKE) -C ${LOKI_DIR} mostlyclean
	$(MAKE) -C ./garud-fw/ mostlyclean

clean:
	unset HW_EXPORT_DIR
	$(MAKE) -C ${LOKI_DIR} clean
	$(MAKE) -C ./garud-fw/ clean

distclean:
	unset HW_EXPORT_DIR
	$(MAKE) -C ${LOKI_DIR} distclean
	$(MAKE) -C ./garud-fw/ distclean

clobber:
	unset HW_EXPORT_DIR
	$(MAKE) -C ${LOKI_DIR} clobber
