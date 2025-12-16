include .config

# Config settings stored in .config, should be modified by running `makeconfig` in this directory.
CONFIG_TARGET_VIVADO_VERSION?=v2023.2	# String - set the toolchain version the Makefile will check for
CONFIG_AUTO_INIT_FIRMWARE_SUBMODULE?=y	# Boolean - set true to init firmware module if empty
CONFIG_AUTO_INIT_LOKI_SUBMODULE?=y		# Boolean - set true to init loki module if empty
CONFIG_USE_PREBUILT_HW?=false			# Boolean - set true to use prebuilt hardware instead of garud-fw
CONFIG_USE_LOCAL_HW_BUILD?=false		# Boolean - set true to use a local hardware build

# Check on Xilinx tools version for the project
versioncheck: .config
	CURRENT_VIVADO_VERSION=$(shell vivado -version | head -n 1 | cut -d' ' -f2)
	ifneq (${CONFIG_TARGET_VIVADO_VERSION}, ${CURRENT_VIVADO_VERSION})
	$(error Vivado version incorrect, this project uses ${CONFIG_TARGET_VIVADO_VERSION}, and your version is ${CURRENT_VIVADO_VERSION})
	endif

init_submodules: .config
	@if [${CONFIG_AUTO_INIT_FIRMWARE_SUBMODULE} = "y" ]; then\
		git submodule update --init 
	endif

# Firmware Project
VIVADO_HARDWARE_OUTPUT_DIR=$(shell pwd)/${CONFIG_VIVADO_HARDWARE_OUTPUT_DIR_RELATIVE}

# LOKI Submodule environment setup
export LOKI_DIR=./loki/
export APPLICATION_DIR=.
export LOKI_ENV_DIR=.

# If (above) environment variable USE_PREBUILT_HW is set, use the prebuilt hardware. Otherwise build the garud-fw project.
ifeq (${CONFIG_USE_PREBUILT_HW},y)
$(info Hardware design from pre-built XSA project from ${CONFIG_PREBUILT_HW_DIR})
export HW_EXPORT_DIR=$(shell pwd)/${CONFIG_PREBUILT_HW_DIR}
else ifeq ($(CONFIG_USE_LOCAL_HW_BUILD),y)
$(info Hardware design will be build from local application-specific project at ${CONFIG_VIVADO_HARDWARE_MAKEFILE_DIR_RELATIVE})
export HW_EXPORT_DIR=${VIVADO_HARDWARE_OUTPUT_DIR}
else
$(info Hardware deisgn will be build from default LOKI Core)
unexport HW_EXPORT_DIR
endif

ifeq (${CONFIG_USE_PREBUILT_SW},y)
$(info Low-level software design from pre-built binaries in ${CONFIG_PREBUILT_SW_DIR})
export SW_EXPORT_DIR=$(shell pwd)/${CONFIG_PREBUILT_SW_DIR}
else ifeq ($(CONFIG_USE_LOCAL_SW_BUILD),y)
$(info Low-level software built from local project)
$(error Local software project not yet supported)
else
$(info Low-level software design from default LOKI Core build)
unexport SW_EXPORT_DIR
endif

all: .config init_submodules versioncheck ${HW_EXPORT_DIR}/design_4cg_2gb.xsa ./machine.env os

.config:
	$(info Project is not configured yet, running first-time setup)
	menuconfig

# Creating this file is in the README but frequently forgotten, and should be done manually
./machine.env:
	$(error Your project has no machine.env; you should create this for your specific setup based on machine.env.example)

VIVADO_SOFTWARE_OUTPUT_DIR=???
# Extra rules to make the prebuilt files in case of hardware design file change.
${VIVADO_HARDWARE_OUTPUT_DIR}/design_4cg_2gb.xsa:
	$(info Build is using the local project for hardware)
	# Build the hardware and software using the firmware submodule
	$(MAKE) -C ./${CONFIG_VIVADO_HARDWARE_MAKEFILE_DIR_RELATIVE}/ all

# Include recipes to take the environment and run the configuration using the autoconf params
# Provides loki-configure-hw, loki-configure-sw, loki-configure-os
include ${LOKI_DIR}/config.mk

.PHONY: all os hardware software project local_hardware versioncheck

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
