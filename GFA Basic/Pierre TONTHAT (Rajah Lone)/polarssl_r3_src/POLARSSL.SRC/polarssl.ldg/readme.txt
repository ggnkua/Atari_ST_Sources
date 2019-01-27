- build with libpolarssl.a and libz.a
- need also the MiNTLib.
- for SSL/TLS clients.
- read the Makefiles, usage is to build polarssl.ldg for m68000, m68020-60
and mcpu=5475 (comment/uncomment some lines) with cross-compilation
(gcc, MaxOSX and Xcode).

- this is open software. Sorry, don't have time to study the GPL but it
should be that.