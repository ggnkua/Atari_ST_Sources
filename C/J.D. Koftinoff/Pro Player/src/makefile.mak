/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

MAKEFILENAME = makefile.mak

GFLAGS = -I. -I..\inc -O -DHAL_TIPPER=0 #-DUSER_NUMBER=$(USER_NUMBER)

PLYFILES =	ply_main.o ply_io.o play_s1.o \
		playmidi.o disk.o joystick.o \
		setfile.o readcfg.o build.o ply_m2.o cfg.o \
		list.o dirlist.o \
		jkget200.o clocks.o jkfile.o msgin.o



RECEXCL = rec_excl.o recexcl.o recexclm.o

CFGEDIT = cfgeditm.o cfgedit.o cfg_edit.o cfg.o list.o jkfile.o

SETEDIT = setfile.o setedit.o seteditm.o set_edit.o dirlist.o list.o jkfile.o 

RENAMER = renamer.o dirlist.o list.o 

all : player.tos npplayer.tos renamer.prg set_edit.prg cfg_edit.prg rec_excl.prg


player.tos : $(PLYFILES) protect.o protect1.o $(MAKEFILENAME)
	$(G++) protect.o $(PLYFILES) protect1.o -ljk -o player.tos

npplayer.tos : $(PLYFILES) nprot.o nprot1.o $(MAKEFILENAME)
	$(G++) $(PLYFILES) nprot.o nprot1.o -ljk -o npplayer.tos


protect.o : protect.c
	$(GCC) -c -DPROTECT protect.c

protect1.o : protect1.c
	$(GCC) -c -DPROTECT protect1.c


nprot.o : protect.c
	$(GCC) -c protect.c -o nprot.o

nprot1.o : protect1.c
	$(GCC) -c protect1.c -o nprot1.o

ply_main.o : ..\inc\personal.h

ply_m2.o : ..\inc\personal.h



renamer.prg : $(RENAMER) 
	$(G++) $(RENAMER) -lsg -lgem -ljk -o renamer.prg

set_edit.prg : $(SETEDIT)
	$(G++) $(SETEDIT) -lsg -lgem -ljk -o set_edit.prg
	
set_edit.o : set_edit.rsc
	rsctoc set_edit.rsc -o set_edit.c
	$(GCC) -O -c set_edit.c
	$(RM) set_edit.c


cfg_edit.prg : $(CFGEDIT)
	$(G++) $(CFGEDIT) -lsg -lgem -ljk -o cfg_edit.prg

cfg_edit.o : cfg_edit.rsc
	rsctoc cfg_edit.rsc -o cfg_edit.c
	$(GCC) -O -c cfg_edit.c
	$(RM) cfg_edit.c

rec_excl.prg : $(RECEXCL)
	$(G++) -s $(RECEXCL) -lsg -lgem -ljk -o rec_excl.prg

rec_excl.o : rec_excl.rsc
	rsctoc rec_excl.rsc -o rec_excl.c
	$(GCC) -O -c rec_excl.c
	$(RM) rec_excl.c



