ReadMe File For HiSoft C Interpreter for the Atari ST version 2.03.02
=====================================================================

Version 2.03.02
---------------
Serial printers are now supported and a 'typo' in linea.h has been
fixed.

Version 2.03.01
---------------
A few small bugs have been fixed and '\r' is now supported.

Version 2.03.00
---------------
This version now works correctly with TurboST installed and solves
a problem regarding structures.

Version 2.02.01
---------------
The major change in this version is that the space used for local
arrays has been increased to 20K.

Version 2.02.00
---------------
Apart from some bug fixes this version also includes libresou.c in
the SOURCE directory on disk 2. This includes the source code to some
of the GEM Toolbox functions.

A tip for hard disk owners: Remember to use Save Options and to save
a file to your hard disk, otherwise the interpreter will access the
floppy disk when loading.

Version 2.01.01
---------------
This version fixes a number of bugs and now allows '\x41' as well
as '\0x41' for 'A' in string constants as specified by the draft ANSI
standard.

A number of new features were added at version 2.01.00 to HiSoft C:

Improved trace facilities
-------------------------

You can now access the Memory Dump and Stack Dump commands as well as
the variable Dump Command whilst Tracing. Trace Mode is described
on Pages 16 and 17 of the manual.

Pressing S will activate the stack dump and M will access the memory dump
whilst single stepping; this lets you view the values of arrays, local
variables and variables given by pointers while your program is actually
running. Pressing S again will switch off the stack dump and M will switch
the memory dump off.

You may also activate/de-activate these facilities from within your
program using the mem_on(), mem_off(), stack_on(), stack_off() functions.
These work in a similar way to var_on() and var_off().


New Editor facilty
------------------

        This new feature lets you write only the beginning of the name
of a library function call. The complete function call (including the
parameters) is automatically written and managed by the editor.
        Try it. Type the beginning of a library function name.
'strni' for example. Then press the Esc key. 'strnicmp(str1,str2,n)' is
automatically written on the screen. The cursor is on the 1st argument of the
function. You are now in 'Esc' mode. Watch the top right corner of the
screen. 'Esc' is written, instead of 'Ins'. The editor is waiting for you to
type in the arguments of the function. After each parameter, you have to
press Return, and the cursor is positioned on the 1st character of the next
argument.
        The parameter names which are written by the editor are automatically
replaced by the new names you type. You don't need to erase the old names with
Backspace or Del. Just type them and press Return. If you don't want to
change the name of a parameter, just type Return.
        You exit 'Esc' mode when you have typed in all the parameters, or
when you use cursor keys or select a menu item.
        'Esc' mode can also be used with the C language keywords. 'f' is for
'for', 'w' for 'while', 's' for 'switch', etc...
        The list of the functions & parameters used by 'Esc' mode is in file
F11.IC. You can modify it as you want.

Hints when compiling the Toolbox
================================

Unfortunately the list of files in Appendix D.1 is slightly incorrect.
The correct files are in the toolbox.
If you are using Lattice C 3 remember to use the -n flag when compiling
the library functions. You can safely ignore the warnings that the
compiler gives.

The file define.h contains the constants and structure definitions that
are built into HiSoft C.


David Nutkins, HiSoft
8 January 1990

