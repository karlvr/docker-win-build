FROM ubuntu:25.10 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates curl

###############################################################################
# llvm-mingw
# https://github.com/mstorsjo/llvm-mingw
RUN apt-get update && \
	apt-get install -y --no-install-recommends xz-utils && \
	curl -o /tmp/llvm-mingw.tar.xz -L https://github.com/mstorsjo/llvm-mingw/releases/download/20250709/llvm-mingw-20250709-ucrt-ubuntu-22.04-$(dpkg --print-architecture | sed -e 's/arm64/aarch64/' | sed -e 's/amd64/x86_64/').tar.xz && \
	mkdir -p /llvm-mingw && \
	tar -C /llvm-mingw --strip-components 1 -xf /tmp/llvm-mingw.tar.xz && \
	rm -f /tmp/llvm-mingw.tar.xz && \
	echo "export PATH=\$PATH:/llvm-mingw/bin" > /etc/profile.d/99-llvm-mingw

###############################################################################
# msix-packaging
# https://learn.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview

RUN apt-get update && \
	apt-get install -y --no-install-recommends git cmake make clang zlib1g-dev && \
	cd /tmp && \
	git clone https://github.com/microsoft/msix-packaging.git --depth 1 && \
	cd msix-packaging && ./makelinux.sh -sb --pack --skip-samples --skip-tests && \
	cp .vs/bin/makemsix /usr/local/bin && \
	cp --no-dereference .vs/lib/*.so .vs/lib/*.so.* /usr/local/lib

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
	cd /tmp && \
	curl -o osslsigncode.tar.gz -L https://github.com/mtrojnar/osslsigncode/archive/refs/tags/2.8.tar.gz && \
	mkdir osslsigncode && cd osslsigncode && \
	tar --strip-components=1 -zxf ../osslsigncode.tar.gz && \
	mkdir build && cd build && cmake -S .. && \
	cmake --build . && \
	cmake --install .

###############################################################################
# msitools + wixl

RUN apt-get update && \
	apt-get install -y --no-install-recommends meson git clang valac bison libgsf-1-dev libgcab-dev gobject-introspection gir1.2-glib-2.0-dev && \
	cd /tmp && \
	git clone --depth=1 https://github.com/karlvr/msitools.git && \
	cd msitools && \
	git submodule init && \
	git submodule update && \
	meson setup build && \
	meson compile -C build && \
	meson install -C build && \
	ldconfig

###############################################################################

FROM ubuntu:25.10

COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /usr/local/lib/ /usr/local/lib/
COPY --from=build /usr/local/share/ /usr/local/share/

RUN apt-get update && \
	apt-get install -y --no-install-recommends curl libgsf-bin libgcab-1.0-0 gir1.2-glib-2.0 && \
	useradd --create-home --home /home/builder --groups users builder --shell /bin/bash && \
	mkdir /build && \
	ldconfig && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

USER builder
WORKDIR /build
