
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

;*************************************************************************
;* VDINOTES.
;*
;* There is nothing executable in this module.  The library's version
;* number is here, and can be queried at runtime by looking at global
;* variable '_vdif_version', which is defined below.  I don't know why
;* anyone would want to do that.
;*
;* Mostly this is a collection of notes about the library and its source.
;*
;* The following little blurb will never get linked into an application
;* unless the program specifically references the version variable's name.
;*
;*  Maintenance:
;*   02/06/89     - v1.1 Added 'vdiV0110' global label, so I can quickly
;*                  check the version # from an aln link-map.
;*************************************************************************

_vdif_version::
vdiV0110::
        dc.w    $0110          ;* version 01.10
        dc.b    ' VDIFAST v1.10 '

;*************************************************************************
;*
;*  Notes about the VDIFAST VDI bindings.
;*
;*  The object code & library are in 'DRI' format, & are thus compatible 
;*  with Alcyon C, Sozobon C, and any other compiler/linker which can handle
;*  'DRI-compatible' object files (v0.92:  Laser C compatible).
;*  
;*  When used with the Atari 'aln' linker, you must first use the 'DOINDEX'
;*  program to create a .NDX index file for the library.
;*
;*  These bindings were written to be both fast, and frugal of memory.
;*  In most cases, when a pointer to an array (such as x/y coordinates for
;*  polylines) is passed to the bindings, that pointer is placed directly
;*  into the VDI 'contrl' structure.  When an intermediate array is needed
;*  (such as for the text functions), stack space will be used for temporary
;*  storage.  Since no global data space or bss space is allocated by these
;*  bindings, the amount of runtime memory used is about 1/2 of the size of
;*  the object modules which are linked into your program.  (DRI object 
;*  modules before linking are roughly twice the size they will be after
;*  linking.)  Thus, if you write a program that causes every module in the
;*  library to be included, the overhead added to your program will be less
;*  than 5k.
;*  
;*  You do NOT need to define the typical VDI arrays 'contrl', 'intin', 
;*  'intout', 'ptsin', and 'ptsout' in your C program!  (At least, not for 
;*  the use of these bindings...you may certainly use variables/arrays of
;*  those names if you find it convenient to do so for some reason.)
;*  
;*  The stack space used by these bindings in processing a typical VDI call
;*  is 30-50 bytes.  For the text-oriented calls, it will be approximately
;*  40 bytes plus twice the length of the string to be input/output.  In
;*  other words, a normal stack size should work just fine (I generally use
;*  a 1k stack without problems).
;*  
;*  The library contains no global symbols other than the function names
;*  themselves.  There are no external references within any of the modules;*  
;*  each is self-contained.  It should never be necessary to make multiple 
;*  passes of the linker to resolve all references, and it shouldn't matter
;*  where the VDIFAST name appears on the linker's command line.
;*
;*  This code was developed using the Digital Research publication _VDI
;*  Programmer's Guide_.  There may be differences between the DRI docs
;*  and the Abacus _GEM Programmer's Guide_, especially in the inquiry
;*  functions.  Sorry, but it seemed safest to use the DRI docs as the
;*  definitive source.
;*  
;*  There are some (obscure) functions which are not supported, notably
;*  the cell_array functions, and the VDI Escapes related to the Polaroid
;*  Palette Processor (whatever that is) and metafiles.
;*
;*  This code was developed under Atari's MadMac assembler, and probably
;*  won't assemble correctly on any other assembler. To convert this code 
;*  to another assembler, the following notes may be of use:
;*  
;*    All comments are preceded by ';*', most assemblers use the '*' for a
;*    comment delimiter.  Using an editor, do a 'search and replace all'
;*    to change ';*' to '*;'.  Please don't change them to just an '*',
;*    because trying to change them back will also catch computed constants
;*    such as 'move.l   4*SIZE,d0'.
;*    
;*    The MadMac '.cargs' opcode is used extensively.  This opcode simply
;*    generates equates for the named symbols; for another assembler, you
;*    can comment out the .cargs line and add normal equates, as follows:
;*    
;*       ;* .cargs  #8,.handle.w,.pxy.l,.color.w
;*       .handle = 8
;*       .pxy    = 10
;*       .color  = 14  
;*
;*    MadMac recognizes symbols starting with a '.' as local symbols, 
;*    limited in scope to the nearest surrounding non-local symbols.  For
;*    an assembler that doesn't use local symbols, you're gonna be spending
;*    a LOT of time removing leading '.' characters and thinking up unique
;*    names for everything.
;*    
;*    A single macro is used extensively.  This macro, called 'VContrl' is
;*    used as a coding shortcut to set up the VDI 'contrl' structure for
;*    each call.  If your assembler doesn't support macros, you are going
;*    to have to (tediously) change each occurance of 'VContrl' to the
;*    equivelent assembler code.
;*    
;*
;*************************************************************************

;       end of code

