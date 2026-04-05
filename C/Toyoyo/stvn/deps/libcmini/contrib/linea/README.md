# Line A support

This contribution adds Line A support to libcmini in case you do not have MiNTLib installed. It is nothing but a recent copy from [MiNTLib](https://github.com/freemint/mintlib).

## Usage

To add these functions and the include file to your libcmini, simply follow these steps:

1. Enter your libcmini directory.
2. Copy `linea.c` and `linea.h` to the libcmini source:<br>
   `$ make -C contrib/linea install`
3. Compile and install libcmini:<br>
   `$ make all install`<br>
   (or whatever you run to compile and install)
4. Remove `linea.c` and `linea.h` from the libcmini source:<br>
   `$ make -C contrib/linea uninstall`
