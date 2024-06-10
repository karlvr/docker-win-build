FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

###############################################################################
# llvm-mingw
# https://github.com/mstorsjo/llvm-mingw
RUN apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates curl xz-utils && \
	curl -o /tmp/llvm-mingw.tar.xz -L https://github.com/mstorsjo/llvm-mingw/releases/download/20240518/llvm-mingw-20240518-ucrt-ubuntu-20.04-$(dpkg --print-architecture | sed -e 's/arm64/aarch64/' | sed -e 's/amd64/x86_64/').tar.xz && \
	mkdir -p /llvm-mingw && \
	tar -C /llvm-mingw --strip-components 1 -xf /tmp/llvm-mingw.tar.xz && \
	echo "export PATH=\$PATH:/llvm-mingw/bin" > /etc/profile.d/99-llvm-mingw

###############################################################################
# CMake
# We need to install the latest CMake as msix-packaging uses a later one than
# provided in Ubuntu 22.
# https://cmake.org/
# https://apt.kitware.com

RUN apt-get update && \
	apt-get install -y ca-certificates gpg curl && \
	curl https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor - > /usr/share/keyrings/kitware-archive-keyring.gpg && \
	echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' > /etc/apt/sources.list.d/kitware.list && \
	apt-get update && \
	apt-get upgrade -y cmake

###############################################################################
# msix-packaging
# https://learn.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview

RUN apt-get update && \
	apt-get install -y --no-install-recommends git cmake make clang zlib1g-dev && \
	git clone https://github.com/microsoft/msix-packaging.git --depth 1 && \
	cd msix-packaging && ./makelinux.sh -sb --pack --skip-samples --skip-tests && \
	cp .vs/bin/makemsix /usr/local/bin

###############################################################################
# osslsigncode

# OpenSSL-based signcode utility

# Platform-independent tool for Authenticode signing of PE(EXE/SYS/DLL/etc), 
# CAB and MSI files - uses OpenSSL and libcurl. It also supports 
# timestamping (Authenticode and RFC3161).

# https://github.com/mtrojnar/osslsigncode
# https://stackoverflow.com/a/29073957/1951952

RUN apt-get update && \
	apt-get install -y --no-install-recommends cmake libssl-dev libcurl4-openssl-dev zlib1g-dev python3 && \
	curl -o osslsigncode.tar.gz -L https://github.com/mtrojnar/osslsigncode/archive/refs/tags/2.8.tar.gz && \
	mkdir osslsigncode && cd osslsigncode && \
	tar --strip-components=1 -zxf ../osslsigncode.tar.gz && \
	mkdir build && cd build && cmake -S .. && \
	cmake --build . && \
	cmake --install .

###############################################################################
# jsign

RUN apt-get update && \
	apt-get install -y --no-install-recommends openjdk-17-jdk-headless && \
	curl -L -o ./jsign_6.0_all.deb https://github.com/ebourg/jsign/releases/download/6.0/jsign_6.0_all.deb && \
	dpkg --install /jsign_6.0_all.deb && \
	rm /jsign_6.0_all.deb

###############################################################################

RUN useradd --create-home --home /home/builder --groups users builder --shell /bin/bash
RUN mkdir /build

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/*

USER builder
WORKDIR /build
