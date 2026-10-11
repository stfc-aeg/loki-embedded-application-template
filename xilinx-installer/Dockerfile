FROM ubuntu:20.04

ARG UNIFIED_FILE_NAME=FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256
ARG PETALINUX_FILE_NAME=petalinux-v2023.2-10121855-installer

RUN apt-get update

# Fix locale issues
RUN apt-get -y install locales locales-all
RUN locale-gen "en_US.UTF-8"
RUN update-locale LANG=en_US.UTF-8

# Insall the Xilinx combined toolchain
######################################

# Dependencies for Vivado
RUN apt-get -y install gcc \
    xz-utils \
    libtinfo-dev \
    libtinfo5

# Dependencies for Vitis
RUN apt-get -y install xvfb \
    default-jre \
    libswt-gtk-4-jni \
    dbus-x11

# Extract the installer and insert it into the build image
ADD ./$UNIFIED_FILE_NAME.tar.gz /opt/xilinx/installer_unified/
ADD ./config.txt /opt/xilinx/installer_unified/
RUN echo contents of install directory: $(ls /opt/xilinx/installer_unified/$UNIFIED_FILE_NAME/)
RUN cd /opt/xilinx/installer_unified/$UNIFIED_FILE_NAME/ && \
   ./xsetup --agree XilinxEULA,3rdPartyEULA --batch Install --config /opt/xilinx/installer_unified/config.txt

# Insall PetaLinux dependencies
RUN dpkg --add-architecture i386
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive TZ='Europe/London' apt-get -y install iproute2 \
   gcc \
   g++ \
   net-tools \
   libncurses5-dev \
   zlib1g:i386 \
   libssl-dev \
   flex \
   bison \
   libselinux1 \
   xterm \
   autoconf \
   libtool \
   texinfo \
   zlib1g-dev \
   gcc-multilib \
   build-essential \
   screen \
   pax \
   gawk \
   python3 \
   python3-pexpect \
   python3-pip \
   python3-git \
   python3-jinja2 \
   xz-utils \
   debianutils \
   iputils-ping \
   libegl1-mesa \
   libsdl1.2-dev \
   pylint3 \
   cpio \
   rsync \
   bc \
   lsb-release \
   u-boot-tools

# Dependencies for general build system - menuconfig
RUN pip install kconfiglib

# Install PetaLinux toolchain
#############################

# Change term from dash to bash
RUN chsh -s /bin/bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Import the installer
ADD ./$PETALINUX_FILE_NAME.run /opt/xilinx/installer_petalinux/
RUN chmod a+x /opt/xilinx/installer_petalinux/$PETALINUX_FILE_NAME.run

# Create a new user because PetaLinux won't let you install it as root
RUN useradd -ms /bin/bash petalinux
RUN mkdir /opt/xilinx/petalinux_install
RUN chmod a+rw /opt/xilinx/petalinux_install
RUN chmod a+rw /tmp
RUN chmod a+rw /tmp/*

# Install the toolchain as petalinux user
USER petalinux
WORKDIR /opt/xilinx/petalinux_install
RUN mkdir -p /opt/xilinx/petalinux_install/2023.2 && /opt/xilinx/installer_petalinux/$PETALINUX_FILE_NAME.run --skip_license -d /opt/xilinx/petalinux_install/2023.2

USER root

# Make the Xilinx shared libraries work, preventing SELinux messing things up
RUN chcon -Rt svirt_sandbox_file_t /tools/Xilinx/Vivado/2023.2/lib/lnx64.o/
