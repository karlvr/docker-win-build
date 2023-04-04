FROM --platform=x86_64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

###############################################################################
# llvm-mingw
# https://github.com/mstorsjo/llvm-mingw
RUN apt-get update && \
	apt-get install -y curl xz-utils && \
	curl -o /tmp/llvm-mingw.tar.xz -L https://github.com/mstorsjo/llvm-mingw/releases/download/20230320/llvm-mingw-20230320-msvcrt-ubuntu-18.04-x86_64.tar.xz && \
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
	apt-get install -y --no-install-recommends git && \
	git clone https://github.com/microsoft/msix-packaging.git --depth 1
RUN apt-get install -y --no-install-recommends cmake make build-essential
RUN apt-get install -y --no-install-recommends clang
RUN apt-get install -y --no-install-recommends zlib1g-dev
RUN cd msix-packaging && ./makelinux.sh -sb --pack --skip-samples --skip-tests
RUN cp msix-packaging/.vs/bin/makemsix /usr/local/bin

###############################################################################

RUN useradd --create-home --home /home/builder --groups users builder --shell /bin/bash
RUN mkdir /build

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/*

USER builder
WORKDIR /build

