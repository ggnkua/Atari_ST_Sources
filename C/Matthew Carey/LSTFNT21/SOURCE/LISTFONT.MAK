#
# A make file for Metacomco MAKE
#
# The only part of the Lattice 3 package I am still using

# This 'make' file sends all the messages to the file pfb.lst
#
# The first line prints a text to a new file pfb.lst disposing of any
# old pfb.lst files at the same time
#
# (echo.ttp is my own little program that does just what the built in
# command echo does in most command line interface programs as it is
# compiled in Lattice C5 it is re-directable to a file)
# -j88e -j87e -j86e

.START : E:\DEV\BIN\echo.ttp Report of the making of fontlist >listfont.lst

#         E:\DEV\BIN\echo.ttp Setting the Compilation Date and Time >>listfont.lst
#         E:\DEV\BIN\LC1B.TTP -cufm  -w -rr  -oG:\QUAD\ E:\DEV\FON\cdate.c >>listfont.lst
#         E:\DEV\BIN\LC2.TTP -v -oE:\DEV\FON\ G:\QUAD\cdate.q >>listfont.lst

# .END : E:\DEV\BIN\more.ttp listfont.lst

TARGET =  listfont.prg

CFILES =  listfonr.c listfont.c listttf.c  misclist.c

COBJS  = listfonr.o listfont.o listttf.o  misclist.o

OBJFILES = $(COBJS)

#   
#######################################################
#                                                     #
# Standard implicit rules for inclusion in makefiles. #
# To include this file use the line:                  #
#                                                     #
# .INCLUDE :; MAKE.INC                                #
#                                                     #
#######################################################
#
# Suffix rules
# So far no assembler files
#
# .s.o :; E:\DEV\BIN\ASM.TTP -d E:\DEV\FON\$*.s
#
# Any file ending in .o depends on its namesake ending in .c
# if that has been altered it must be compiled again
#
 .c.o :; E:\DEV\BIN\ECHO.TTP Compiling $*.c >>listfont.lst
         E:\DEV\BIN\LC1B.TTP -cufm -rr -w -oG:\QUAD\ \
                E:\DEV\WORK\$*.c >>listfont.lst
         E:\DEV\BIN\LC2.TTP -v -oE:\DEV\WORK\ G:\QUAD\$*.q >>listfont.lst
#         E:\DEV\BIN\GO.TTP  G:\QUAD\$*.q >>listfont.lst
#
#
#
#
#
# Explicit rule

#
# Link if the object files have been altered
#
listfont.prg : $(OBJFILES) listfont.lnk
  E:\DEV\BIN\CLINK.TTP WITH E:\DEV\WORK\listfont.lnk BATCH >>listfont.lst
#
# Precompile the header files if they have been altered
#
#
# all the C source
#
$(COBJS) : listfont.h
#
#
# This module depends on the resource header file.
listfont.o : listfonr.h
#
# The resource file is decompiled to C and compiled into this program.
listfonr.c : listfonr.rsc 
  E:\DEV\BIN\dercs.ttp E:\DEV\WORK\listfonr.rsc
#
#
