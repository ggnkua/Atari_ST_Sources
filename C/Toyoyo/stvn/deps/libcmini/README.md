[![Build Status](https://travis-ci.org/freemint/libcmini.svg?branch=master)](https://travis-ci.org/freemint/libcmini)

# libcmini

libcmini aims to be a small-footprint C library for the m68k-atari-mint (cross) toolchain, similar to the C library
Pure-C came with. Many GEM programs do not need full MiNT support and only a handful of C library functions.

By default, gcc compiled programs on the Atari ST platform link to mintlib. Mintlib aims to implement all POSIX
functionality to make porting Unix/Linux programs easier (which is a very good thing to have). For small GEM-based
programs, this comes with a drawback, however: program size gets huge due to the underlying UNIX compatibility layer.

For programs that don't need this, libcmini tries to provide an alternative. It's far from finished, but already quite 
usable.

## Example
This small program

```
#include <stdio.h>

int main(int argc, char *argv[])
{
    printf("Hello World\r\n");
}
```

compiled with the standard m68k-atari-mint toolchain 

```
m68k-atari-mint-gcc -o hello.tos -s hello.c 
```

results in a binary size of 118220 bytes. Huge. The same thing compiled with libcmini:

```
m68k-atari-mint-gcc -nostdlib $LIBCMINI/crt0.o hello.c -o hello.tos -s -L$LIBCMINI -lcmini -lgcc
```
(note that - since we compile with -nostdlib - you have to add the gcc runtime support library libgcc.a to your command line for the processors that need it)

creates a binary with 11794 byts. About a tenth of the size.

Remember that gcc does not automatically look up multi-lib versions of
libraries in directories specified by -L. If you want to do the same as
above for a different architecture, you have to explicitly add the
correct sub-directory:

```
m68k-atari-mint-gcc -nostdlib -mcpu=5475 $LIBCMINI/crt0.o hello.c -o hello.tos -s -L$LIBCMINI/m5475 -lcmini -lgcc
```

Same applies if you are using any other switch that requires a
different library version, like --mshort and --mfastcall.

## Binary Releases Downloads

binary releases (in tar.gz format) can be downloaded from here: https://github.com/freemint/libcmini/releases
source is also available there.

## What's that libcmini.creator stuff about?

I'm using the QtCreator IDE for my Atari cross development work (most of the time, if I'm not in vi mode). The `libcmini.config`, `libcmini.creator`, `libcmini.files` and `libcmini.includes` files are used by QtCreator to keep track of the project.
If you are not using QtCreator (I would recommend it since it adds a few nice features to Atari cross development), just ignore these files.

## Fastcall?
(contributed by Frederik Olsson)

Fastcall requires [patched GCC 4.6.4](https://github.com/PeyloW/gcc-4.6.4) with -mfastcall support.

GCC passes all arguments on the stack by default. The Atari ST, and even the Falcon 030, have a slow 16 bit wide memory bus.
As a result memory operations are very expensive. Most functions take only a few arguments that can be passed in registers.

-mfastcall uses d0-2/a0-1/fp0-2 for passing integer and pointer arguments when possible, and always return pointers in a0.
a2 is not used for passing arguments, but is considered clobbered, this allows a2 to be used as call target function pointer.

The result is faster code execution, and slightly smaller memory footprint. Especially when used in combination with -mshort to 
avoid library calls for most integer operations.

With -mfastcall libcmini itself is 3% smaller binary, and the tests/bench test executes 20% faster. 

## Contribution

Contributions are always welcome.

Please make sure you provide all new code using 'four spaces' indentation without TAB characters and trailing spaces removed.
