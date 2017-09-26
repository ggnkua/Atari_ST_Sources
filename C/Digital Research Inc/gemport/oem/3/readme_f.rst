  

                            DON'T PANIC

                      Notes on building a system.

   In order to build the system, the first thing to do is run SETUP.BAT.
This batch file will copy from other directories all the needed files to 
build the system with.

The next thing to do is run SYSGEN.BAT.  This batch file will do the rest,
the result being GEMDOSFI.SYS.  GEMDOSFI.SYS is a FLOPPY disk operating 
system.

NOTE: While compiling 8X12.c the compiler will issue a number of warinings.
      It is safe to ignore these.

      When linking the newly created object files, a message to the effect
      that _GSX_ENT is an undefined symbol will occur.  Ignore this.

To build either a hard disk os, GEMDOSHI.SYS, or a floppy os, GEMDOSFI.SYS,
a byte must be changed in main.c.  This byte is documented with
the comment /* 0 if GEMDOSFI.SYS, 2 if GEMDOSHI.SYS */.  It will be obvious
what to do when viewing the code.

To build a 68010 based system, the procedure is the same except that SYSGEN10.BAT
is run in place of SYSGEN.BAT.
