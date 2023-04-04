FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

###############################################################################
# llvm-mingw
# https://github.com/mstorsjo/llvm-mingw
RUN apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates curl xz-utils && \
	curl -o /tmp/llvm-mingw.tar.xz -L https://github.com/mstorsjo/llvm-mingw/releases/download/20230320/llvm-mingw-20230320-ucrt-ubuntu-18.04-aarch64.tar.xz && \
	mkdir -p /llvm-mingw && \
	tar -C /llvm-mingw --strip-components 1 -xf /tmp/llvm-mingw.tar.xz && \
	echo "export PATH=\$PATH:/llvm-mingw/bin" > /etc/profile.d/99-llvm-mingw

###############################################################################
# osslsigncode

# OpenSSL-based signcode utility

# Platform-independent tool for Authenticode signing of PE(EXE/SYS/DLL/etc), 
# CAB and MSI files - uses OpenSSL and libcurl. It also supports 
# timestamping (Authenticode and RFC3161).

# https://sourceforge.net/projects/osslsigncode/
# https://sourceforge.net/p/osslsigncode/osslsigncode/ci/master/tree/
# https://stackoverflow.com/a/29073957/1951952

RUN apt-get update && apt-get install -y --no-install-recommends osslsigncode

###############################################################################
# msix-packaging

RUN apt-get update && \
	apt-get install -y --no-install-recommends git cmake make clang zlib1g-dev && \
	git clone https://github.com/microsoft/msix-packaging.git --depth 1 && \
	cd msix-packaging && ./makelinux.sh -sb --pack --skip-samples --skip-tests && \
	cp .vs/bin/makemsix /usr/local/bin

###############################################################################

RUN useradd --create-home --home /home/builder --groups users builder --shell /bin/bash
RUN mkdir /build

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/*

USER builder
WORKDIR /build
