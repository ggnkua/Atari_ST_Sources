
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

;*************************************************************************
;* AESNOTES.
;*
;* There is nothing executable in this module.  The library's version
;* number is here, and can be queried at runtime by looking at global
;* variable '_aesf_version', which is defined below.  I don't know why
;* anyone would want to do that.
;*
;* Mostly this is a collection of notes about the library and its source.
;*
;*************************************************************************

_aesf_version::
aesV0180::

        dc.w    $0180          ;* version 01.80
        
        dc.b    'AESFAST v1.80  '
        dc.b    'by Ian Lepore  '
        
;*************************************************************************
;*
;*  Notes about the AESFAST AES bindings.
;*
;*  The object code & library are in 'DRI' format, & are thus compatible 
;*  with Alcyon C, Sozobon C, and any other compiler/linker which can handle
;*  'DRI-compatible' object files.
;*  
;*  When used with the Atari 'aln' linker, you must first use the 'DOINDEX'
;*  program to create a .NDX index file for the library.
;*  
;*  There is a small fixed overhead (the storage for the AES control blocks
;*  and a couple of small common interface routines) when using any of the
;*  AES functions.  This amounts to about a hundred or so bytes.  Beyond  
;*  that, the amount of runtime memory used is about 1/2 of the size of
;*  the object modules which are linked into your program.  (DRI object 
;*  modules before linking are roughly twice the size they will be after
;*  linking.)  Thus, if you write a program that causes every module in the
;*  library to be included, the overhead added to your program will be less
;*  than 4k.
;*  
;*  The stack space used by these bindings in processing a typical AES call
;*  is 10-40 bytes.  
;*  
;*  The library contains one global symbol other than the function names,
;*  '_gl_apid'.  There are no external references within the library, 
;*  it is self-contained.  It should never be necessary to make multiple 
;*  passes of the linker to resolve all references, and it shouldn't matter
;*  where the AESFAST name appears on the linker's command line. 
;*
;*  If you make changes, the 'aescomn' module should appear last in the
;*  library as all other modules reference it, and the 'aesutil' modules
;*  should appear first in the library as they contain calls to the other
;*  AES routines.
;*
;*  This code was developed using the Digital Research publication _AES
;*  Programmer's Guide_.  There may be differences between the DRI docs
;*  and the Abacus _GEM Programmer's Guide_.
;*  
;*  This code was developed under Atari's MadMac assembler, and probably
;*  won't assemble correctly on any other assembler. To convert this code 
;*  to another assembler, the following notes may be of use:
;*  
;*    All comments are preceded by ';*', many assemblers use the '*' for a
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
;*************************************************************************

;       end of code

