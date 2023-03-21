# Docker Windows Build image

A Docker image to build, sign and package 32 and 64 bit Windows executables. Includes [MingW](http://www.mingw.org), [osslsigncode](https://sourceforge.net/projects/osslsigncode/) and [WiX Toolset](http://wixtoolset.org/).

osslsigncode is used in preference to Mono signcode as Mono signcode cannot sign msi files, while osslsigncode can.

## Building

Note that this Docker image can only be built on an x86_64 host as Winetricks fails to install when
building on arm64.

## Usage

You can run the image interactively, or run individual commands or scripts by appending them
to the run command.

Mount your working dir to `/build` in the Docker container. That is the default working dir.

```
docker run -v ~/build:/build karlvr/win-build ...
```

### Compiling

For more information on llvm-mingw see https://github.com/mstorsjo/llvm-mingw.
We use llvm-mingw so we can cross-compile to aarch64.

```
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

```
osslsigncode sign -pkcs12 Certificates.pfx -pass <password> -n <name> -i <time server> -in <in file> -out <out file>
```

### Packaging

For more information on WiX Toolset see http://wixtoolset.org/

We run WiX using [wine](http://winehq.com/), so it's not perfect. In particular, validating packages doesn't appear
to work, and fails with an odd error, so include the `-sval` flag to `light.exe` in order to disable validation.

```
WIXDIR=/opt/wix
HEAT="wine $WIXDIR/heat.exe"
CANDLE="wine $WIXDIR/candle.exe"
LIGHT="wine $WIXDIR/light.exe"
```

Then run the commands using the `$HEAT`, `$CANDLE` and `$LIGHT` environment variables.
