# ****************************************************************
#
# makefile to create Low level sound.BOS Routines.
#
# ****************************************************************


CFLAGS = -A
OBJ = sndxbios.o soundcmd.o sndlow.o
TESTMEM	= smemtest.o debug.o		# Test Routine TT compatible
TESTDISK = sdisktst.o debug.o		# Test Routine TT compatible


sndxbios.prg:	$(OBJ)
		aln -o sndxbios.prg $(OBJ)

# ****************************************************************
#
# Files necessary for sound.bos driver
#
# ****************************************************************

sndxbios.o:	sndxbios.s makefile\
			e:\include\snderror.inc
		mac -u -y96  sndxbios

soundcmd.o:	soundcmd.s makefile\
			e:\include\sndhead.inc\
			e:\include\spardef.inc\
			e:\include\snderror.inc
		mac -u -y96  soundcmd


sndlow.o:	sndlow.s makefile\
			e:\include\soundef.inc\
			e:\include\spardef.inc\
			e:\include\snderror.inc
		mac -u -y96  sndlow



