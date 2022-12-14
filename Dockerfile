# WiX Toolset
# Create Windows installation packages

# Run WiX on Linux using Wine

ARG ARCH=
FROM ${ARCH}ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

###############################################################################
# llvm-mingw
# https://github.com/mstorsjo/llvm-mingw
RUN apt-get update && \
	apt-get install -y curl xz-utils && \
	curl -o /tmp/llvm-mingw.tar.xz -L https://github.com/mstorsjo/llvm-mingw/releases/download/20220906/llvm-mingw-20220906-msvcrt-ubuntu-18.04-x86_64.tar.xz && \
	mkdir -p /llvm-mingw && \
	tar -C /llvm-mingw --strip-components 1 -xf /tmp/llvm-mingw.tar.xz

###############################################################################
# osslsigncode

# OpenSSL-based signcode utility

# Platform-independent tool for Authenticode signing of PE(EXE/SYS/DLL/etc), 
# CAB and MSI files - uses OpenSSL and libcurl. It also supports 
# timestamping (Authenticode and RFC3161).

# https://sourceforge.net/projects/osslsigncode/
# https://sourceforge.net/p/osslsigncode/osslsigncode/ci/master/tree/
# https://stackoverflow.com/a/29073957/1951952

RUN apt-get update && apt-get install -y osslsigncode

###############################################################################
# WiX

# Wine repository
RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get install -y wget apt-transport-https gnupg lsb-core && \
	mkdir -p /etc/apt/keyrings && \
	wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
	wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources && \
	apt-get update

# Install Wine
RUN apt-get install -y winehq-stable

# https://wiki.winehq.org/Winetricks
RUN wget -O /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
	chmod +x /usr/local/bin/winetricks

# Install WIX
RUN apt-get install -y unzip && \
	mkdir -p /opt/wix && \
	wget -O /opt/wix/wix.zip https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311-binaries.zip && \
	cd /opt/wix && \
	unzip wix.zip && \
	rm wix.zip

RUN apt-get install -y xauth ca-certificates

RUN useradd --create-home --home /home/builder --groups users builder --shell /bin/bash
RUN mkdir /build

USER builder
WORKDIR /build

# Setup Dotnet 4.0
ENV WINEARCH=win32
RUN /usr/local/bin/winetricks --unattended dotnet40

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/*
