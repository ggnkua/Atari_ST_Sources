p2c  --  Dave Gillespie's Pascal-to-C convertor for the Atari ST
(Ported by Steven Ourada sourada@iastate.edu)

This is just a quick and dirty port, I don't have a lot of interest in Pascal
except that I have to use it for some programming this semester. If there
are bugs in the port, I'll look at them, but don't count on me to fix them :-)
No extensive testing has been done.

All I did to port it was get the original source distribution, change the
char * in ISBOGUS to a void *, change ResultName in p2crc from Result to
Result%s, edit the Makefile appropriately, and make. There was a warning or
two during compilation, but in my judgement they were not significant.

The sources as they appear in the source archive are what I ended up with,
therefore they are a little different than the originals. If you want the
originals, get them from p2c-1.20.tar.Z.

Compiled with GCC 2.4.5, MiNTlibs 34. 

Usage:
------
Unpack this archive. (You knew that.)
Put the home directory somewhere appropriate, and point the env var P2C_HOME
to it.
Make a directory p2c somewhere in your includes, and put p2c.h in it.
Put libp2c.olb in your libs.
Put p2c in your binaries.
p2c filename.pas
gcc -o filename filename.c -llibp2c.olb

If all went right and you're lucky, you'll have an executable that does
what the pascal program was supposed to.

