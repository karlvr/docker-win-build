# Docker Windows Build image

A Docker image to build, sign and package 32 and 64 bit Windows executables. Includes [llvm-mingw](https://github.com/mstorsjo/llvm-mingw), [osslsigncode](https://github.com/mtrojnar/osslsigncode), [Jsign](https://github.com/ebourg/jsign) and [makemsix](https://learn.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview).

osslsigncode and Jsign are used in preference to Mono signcode as Mono signcode cannot sign `.appx`` files, while osslsigncode can.

## Building

```shell
make build
```

## Usage

You can run the image interactively, or run individual commands or scripts by appending them
to the run command.

Mount your working dir to `/build` in the Docker container. That is the default working dir.

```shell
docker run -v ~/build:/build karlvr/win-build ...
```

### Compiling

For more information on llvm-mingw see https://github.com/mstorsjo/llvm-mingw.
We use llvm-mingw so we can cross-compile to aarch64.

```shell
# 32 bit
WINDRES=/llvm-mingw/bin/i686-w64-mingw32-windres
CXX=/llvm-mingw/bin/i686-w64-mingw32-g++

# 64 bit
WINDRES=/llvm-mingw/bin/x86_64-w64-mingw32-windres
CXX=/llvm-mingw/bin/x86_64-w64-mingw32-g++

# aarch64
WINDRES=/llvm-mingw/bin/aarch64-w64-mingw32-windres
CXX=/llvm-mingw/bin/aarch64-w64-mingw32-g++

$WINDRES app.rc app-resources.o
$CXX -mwindows -o app.exe main.cpp
```

### Signing

For more information on osslsigncode see https://stackoverflow.com/a/29073957/1951952 and https://sourceforge.net/p/osslsigncode/osslsigncode/ci/master/tree/

```shell
osslsigncode sign -pkcs12 Certificates.pfx -pass <password> -n <name> -i <time server> -in <in file> -out <out file>
```

`Jsign` is also included. See https://github.com/ebourg/jsign

### Packaging

For more information on MSIX Packaging see https://learn.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview

```shell
makemsix
```
