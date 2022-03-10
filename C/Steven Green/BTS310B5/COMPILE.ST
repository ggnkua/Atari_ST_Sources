Notes on Compiling BinkleyTerm-ST
---------------------------------

This source code will compile with Lattice C5 or Pure-C.

Lattice C
---------

MAKEFILE.ST and MAKERULE.DEF contain all the neccessary flags and things
for the compiler.

These are for use with the Make utility supplied with the Craft Shell.

To compile type in 'make -f makefile.st' [or define an alias to do this]


Turbo-C
-------

The *.PRJ files contain the neccessary info for the compiler.

These files are only used by Turbo C:
  CONIO.C
  TC_UTIME.H
  TCFUNCS.C

Also MAKEFILE.PC, MAKERULE.PC and PCC.CFG are included if you prefer to use 
a CLI with make and the CLI versions of PureC.

Note there was a bug in PureC's library function: chdir(), which I fixed by 
patching the library itself.  The patch I made involves changing one byte, 
but I can't remember what this was.



#defined Symbols used
---------------------

> Predefined

LATTICE : Something for the Lattice compiler only
ATARIST : ST specific code for Lattice and Turbo
__TOS__ : ST specific code for Turbo
MC68000 : Assume 680x0 processor

> within program

GENERIC    : Make it with any processor, i.e. doesn't assume 8086 byte
             ordering.

DEBUG      : Enable debugging code.
ZDEBUG
XDEBUG

> These last few are in for debugging reasons and are being phased out, but
  they do need to be defined if BT is to work properly.
  
EMSI       : Include EMSI code
NEW        : Include modifications
MULTIPOINT : Include modifications
7IOS        : Include code for IOS format *.?AT compressed packets


Contacts and acknowledgements
-----------------------------

The Atari ST conversion was originally converted from the PC sources of 
BinkleyTerm 2.40 by Steven Green using Lattice C5 and then later enhanced 
to version 3.00 using Pure C.

Modifications to allow compilation with Turbo C and some bug fixes were
done by Enno Borgsteede.

Some additional bug fixes were made by Rinnaldo Visscher.

There are a few other bits of code from Roland Bohn and Iain Paton, which 
are creditted where they are used.


If you make any worthwhile changes please pass the diffs onto me:
 Steven Green (FidoNet 2:252/25, NeST 90:1004/0, +44-793-849044, HST/V32bis)

This will reduce any confusion that could be caused by lots of slightly
different versions floating around.
