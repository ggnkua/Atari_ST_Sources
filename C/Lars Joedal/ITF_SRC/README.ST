infocom.ttp - Infocom game file interpreter.

InfoTaskForce's Infocom Interpreter version 4.01 patch-level 2
(or perhaps 3, since I have corrected some minor bugs, see below).
Compiled for Atari ST by
Lars J|dal
joedal@dfi.aau.dk
using Sozobon C version 2.0 with dLibs library version 1.2

Atari-specific files:
INFOCOM.TTP - ready-to-run program for Atari ST (read the 
              original README file first)
INFOCOM.RC  - file containing a few parameters for the Infocom
              interpreter, such as the screen width and height.
              If this file is not present a screen width of 80
              and a height of 25 will be used.
ATARI_IO.H  - new header definitions (mostly relevant for I/O 
              routines); #include'd in MACHINE.H
ATARI_IO.C  - new routines for I/O on Atari using the VT52 
              protocol; #include'd in IO.C
MAKEFILE.ST - Makefile for compiling the whole program
ATARI.LD    - specifies the files to be linked together to form
              the program; referenced by MAKEFILE.ST
README.ST   - this file

Note: The rest of this document describes what I have changed in
      the source code to get it to compile and work on Atari ST.
      If you only want to use the program, not hack on it, you
      can skip the rest of this document. You still need to read
      the original README file, though.

Apart from adding the above files, I have changed a few things 
in existing files. Sozobon C version 2.0 doesn't recognize the 
'#elif' statement so this had to be replace by
    #else
    #if
and an extra '#endif' everywhere.
Besides, the compiler was not as liberal as some other compilers
when it came to constants. E.g. a construct as '((byte)0)+1' had
to be replace by '((byte)(0+1))'. This affected many macro 
definitions in INFOCOM.H and MACHINE.H. To solve these problems
I have put in some new macros with more explicit definitions.
An example: In the INFOCOM.H file is the definition
    #define     MAX_PARAMS                  ((byte)0x08)
This macro is used some places as MAX_PARAMS+1 in declaration of
arrays etc. Sozobon C version 2.0 does not allow this (it does
not consider the result a constant), so I have defined a new
macro:
    /* +++ new definition +++ */
    #define     MAX_1PAR                    ((byte)(0x08+1))
    /* +++ end new definition +++ */
and used MAX_1PAR instead of MAX_PARAMS+1 everywhere. All such
changes in the .H files are marked as above, but there may be
unmarked replacements in other files. The full list of files
that have been changed from the originals is
    INFOCOM.H
    MACHINE.H
    GLOBALS.C
    INPUT.C
    IO.C
    OPTIONS.C
The new code is in all these cases functionally identical to 
the old code.

Finally, I have found and corrected two bugs, both in IO.C:
At lines 303-305 (at line 299 in the original file) is now a 
check
            /* Added check for q == 0  -lj */
            if (q == 0)
                continue; /* empty line */
This check is needed if the paramter file INFOCOM.RC contains a
blank line.
At line 444 (line 436 in the original file) 'getchar ()' is
changed to 'GET_CH ()', which is the standard way of reading a
character in this program (see COMPILE.TXT for details).

KNOW SHORTCOMMINGS:

The interpreter does not use underlining. Some games will use upper
case for text that should be underlined.
The interpreter does not utilize colors. I should still run without
problems on color systems, though.
No 'signal handling' is included (I'm not even sure what this is -
is a 'signal' sent when control-C is pressed and similar events?).
I haven't tried to run the interpreter with input from a file, so
that may not work as it should.
And if output is redirected to a file VT52 screen codes will be
redirected, too (if you want to log the game, use the "script"
command - (almost) no screen codes is output'ed to the script file).

Summary: This could probably be done somewhat better (do it - you
         have the source), but for "normal" use the program seems
         to work fine. I have tested it on version 4 and 5 games.


Note to 2nd release: Anybody who tried to play level 3 games with
         my first Atari ST release of the ITF interpreter will most
         definitely agree that it could have been done better. On input
         the characters were not echoed and the line had to be ended
         with <ctrl> <return> instead of <return>.
         I have fixed a bug in my own I/O routines, so this release
         should work with all games.

