################################  makevdi  ####################################
#
# $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/makevdi,v $
# =============================================================================
# $Author: lozben $	$Date: 91/08/06 21:31:04 $     $Locker:  $
# =============================================================================
#
# $Log:	makevdi,v $
# Revision 3.0  91/08/06  21:31:04  lozben
# New generation VDI
# 
# Revision 2.11  91/07/26  12:08:28  lozben
# Made sbblit.s dependent on vdiincld.s.
# 
# Revision 2.10  91/07/08  16:37:19  lozben
# Added new files - sbscolog.s, sbsctlog.s sbsctran.s sbscopaq.s
# 
# Revision 2.9  90/06/13  18:06:32  lozben
# Added the -3 (68030 option) flag for the assembler.
# 
# Revision 2.8  90/03/01  12:38:02  lozben
# We now grep for comment "@check@" in relevant files before
# finishing the target. Also added "vdiincld.s" as one of the
# dependencies for some of the files.
# 
# Revision 2.7  90/02/28  11:41:19  lozben
# Fixed some typo errors.
# 
# Revision 2.6  90/02/27  16:20:53  lozben
# Made changes so that the makefile works for the ST and TT vdi.
# 
# Revision 2.5  90/02/20  12:33:18  lozben
# Added fnt16x32.c to the list of files.
# 
# Revision 2.4  90/01/29  18:40:21  lozben
# Added sbscrn.s to the list of .s files.
# 
# Revision 2.3  90/01/19  12:14:01  lozben
# Deleted sbtxt32.s from make file. It's a duplicate os sbtxtblt.s
# 
# Revision 2.2  90/01/19  11:57:15  lozben
# *** Initial Revision ***
# 
###############################################################################

.SUFFIXES: .o .c .s


# Where we should put the objects
DIR		=	..\objs

# Command for building an object file to be used in a TOS build
VDIOBJ		=	-p -s -v -u -y $(DIR) -o vdi.o


# Command for building an object file to be used in a TOS build
SMVDIOBJ	=	-p -s -v -u -y $(DIR) -o smvdi.o


# Command for building a stand alone vdi (screen.prg)
SCREEN		=	-l -v -u -y $(DIR) -o screen.prg jin.o alone.o vdivtg.o


# Command for building a stand alone vdi (screen.prg)
SMSCREEN	=	-l -v -u -y $(DIR) -o smscreen.prg jin.o alone.o vdivtg.o


# Flags for lc.ttp
#
# -w	16-bit ints
# -b0	full 32-bit addressing
# -bn	unknown
# -r0	subroutine calls will use absolute 32-bit relocated address
# -d 	Just enables debug info from line number/offset table
# -v	disable stack checking
# -rs	standard stack params
# -z2	generate DRI format objects
# -cf	force prototype checking
# NOTE: 3 files do not like the optimizer: deskdisk.c gemfslib.c deskfile.c

CMODEL	= -w -b0 -bn -r0 -v -rs -m3 -z2 -cf #-O
CFLAGS	= $(DEFINES) $(CMODEL)  

# Flags for just linking, see target
#
# -N	don't compile, just link
# -Labg	a	cause extended debug info in executable
#	b	batch option of the linker
#	g	search the AES and VDI library first
LDFLAGS	= -N $(CMODEL) -d -Labg 

# Assembly flags
#
ASFLAGS = $(DEFINES) -ic:\lc5\i

.c.o:
	lc -c $(CFLAGS) -o$@ $<
#	cp68 $*.c m:$*.i
#	c068 m:\$*.i m:\$*.1 m:\$*.2 m:\$*.3 -f
#	rm m:\$*.i
#	c168 m:\$*.1 m:\$*.2 $*.s
#	rm m:\$*.1
#	rm m:\$*.2
#	optimize $*.s
#	as68 -s m:\ -l -u -f m:\ $*.s
#	rm $*.s
#	mv $*.o $(DIR)\$*.o



.s.o:
	mas -SU3 $*.s
	mv $*.o $(DIR)\$*.o

SFILES	=	$(DIR)\alone.o    $(DIR)\blastman.o $(DIR)\blitinit.o \
		$(DIR)\copyrfm.o  $(DIR)\entry.o    $(DIR)\escape.o \
		$(DIR)\gsxasm1.o  $(DIR)\gsxasm2.o  $(DIR)\jin.o \
		$(DIR)\line1010.o $(DIR)\mono.o     $(DIR)\mouse.o \
		$(DIR)\sbblit.o   $(DIR)\sbescape.o $(DIR)\sbfrag.o \
		$(DIR)\sbhline.o  $(DIR)\sbmono.o   $(DIR)\sbscrn.o \
		$(DIR)\sbtxtblt.o $(DIR)\sbvline.o  $(DIR)\textblt.o \
		$(DIR)\vdivar.o   $(DIR)\xfrmform.o $(DIR)\sbsctran.o \
		$(DIR)\sbsctlog.o $(DIR)\sbscolog.o $(DIR)\sbscopaq.o \
		$(DIR)\allgem.o   $(DIR)\spxesc.o   $(DIR)\pxmouse.o \
		$(DIR)\palette.o  $(DIR)\blaster.o  $(DIR)\hbline.o \
		$(DIR)\hbmono.o   $(DIR)\hbtxtblt.o $(DIR)\hbrect.o \
		$(DIR)\hbbitblt.o $(DIR)\hbescape.o $(DIR)\routines.o \
                $(DIR)\colorep.o  $(DIR)\spxtblit.o $(DIR)\spxoblit.o \
		$(DIR)\spxvline.o $(DIR)\spxhline.o $(DIR)\pxabline.o \
		$(DIR)\pxrectfl.o $(DIR)\spxmono.o  $(DIR)\pxtform.o \
		$(DIR)\hard.o	  $(DIR)\hpxoblit.o

CFILES	=	$(DIR)\cbssdefs.o $(DIR)\font6x6.o  $(DIR)\font8x16.o \
		$(DIR)\font8x8.o  $(DIR)\fnt16x32.o $(DIR)\isin.o \
		$(DIR)\jmptbl.o   $(DIR)\monobj.o   $(DIR)\monout.o \
		$(DIR)\seedfill.o $(DIR)\tables.o   $(DIR)\text.o \
		$(DIR)\devices.o  $(DIR)\opnwk.o    $(DIR)\init.o \
		$(DIR)\ttcolor.o  $(DIR)\spcolor.o  $(DIR)\spxtxtbl.o \
		$(DIR)\trucolor.o


HFILES	=	portab.h fontdef.h attrdef.h scrndev.h lineavar.h \
		vardefs.h gsxdef.h gsxextrn.h



###############################################################################
#                        These are our targets.                               #
#     Any target aside from vdi.o must be specified on the command line       #
#			i.e. make -f makevdi "targetname"		      #
###############################################################################
#
# First target. This file is linked in with tos.
#
vdi.o:			$(SFILES) $(CFILES)
			egrep @check@ vdiincld.s gsxdef.h
			aln $(VDIOBJ) -c vdi.aln
			@echo "VDI.O created"

#
# Second target. If you want it done specify it on the command line.
# This is stand alone vdi.
#
screen.prg:		$(SFILES) $(CFILES)
			egrep @check@ vdiincld.s gsxdef.h
			aln $(SCREEN) -c vdi.aln
			@echo "SCREEN.PRG created"

#
# Third target. If you want it done specify it on the command line.
# This file has no soft blit code and should be linked in with tos.
#
smvdi.o:		$(SFILES) $(CFILES)
			egrep @check@ vdiincld.s gsxdef.h
			aln $(SMVDIOBJ) -c nosftvdi.aln
			@echo "SMVDI.O created"

#
# Fourth target. If you want it done specify it on the command line.
# This is stand alone vdi which also has no soft blit code.
#
smscreen.prg:		$(SFILES) $(CFILES)
			egrep @check@ vdiincld.s gsxdef.h
			aln $(SMSCREEN) -c nosftvdi.aln
			@echo "SMSCREEN.PRG created"

###############################################################################


$(DIR)\alone.o:		alone.s  lineaequ.s
$(DIR)\blaster.o:	blaster.s lineaequ.s
$(DIR)\blastman.o:	blastman.s lineaequ.s
$(DIR)\blitinit.o:	blitinit.s vdiincld.s lineaequ.s
$(DIR)\colorep.o:	colorep.s vdiincld.s lineaequ.s
$(DIR)\copyrfm.o:	copyrfm.s lineaequ.s
$(DIR)\entry.o:		entry.s lineaequ.s
$(DIR)\escape.o:	escape.s lineaequ.s devequ.s
$(DIR)\gsxasm1.o:	gsxasm1.s vdiincld.s lineaequ.s
$(DIR)\gsxasm2.o:	gsxasm2.s lineaequ.s
$(DIR)\hbescape.o:	hbescape.s lineaequ.s
$(DIR)\hbline.o:	hbline.s lineaequ.s
$(DIR)\hbmono.o:	hbmono.s lineaequ.s
$(DIR)\hbbitblt.o:	hbbitblt.s lineaequ.s
$(DIR)\hbrect.o:	hbrect.s lineaequ.s
$(DIR)\hbtxtblt.o:	hbtxtblt.s lineaequ.s
$(DIR)\jin.o:		jin.s vdiincld.s lineaequ.s
$(DIR)\line1010.o:	line1010.s lineaequ.s
$(DIR)\palette.o:	palette.s lineaequ.s
$(DIR)\mono.o:		mono.s lineaequ.s
$(DIR)\mouse.o:		mouse.s lineaequ.s
$(DIR)\allgem.o:	allgem.s devequ.s lineaequ.s
$(DIR)\sbblit.o:	sbblit.s vdiincld.s lineaequ.s
$(DIR)\sbescape.o:	sbescape.s lineaequ.s
$(DIR)\sbfrag.o:	sbfrag.s lineaequ.s
$(DIR)\sbhline.o:	sbhline.s lineaequ.s
$(DIR)\sbmono.o:	sbmono.s lineaequ.s
$(DIR)\sbsctlog.o:	sbsctlog.s lineaequ.s
$(DIR)\sbscolog.o:	sbscolog.s lineaequ.s
$(DIR)\sbscrn.o:	sbscrn.s lineaequ.s
$(DIR)\sbsctran.o:	sbsctran.s lineaequ.s
$(DIR)\sbscopaq.o:	sbscopaq.s lineaequ.s
$(DIR)\sbtxtblt.o:	sbtxtblt.s lineaequ.s
$(DIR)\sbvline.o:	sbvline.s lineaequ.s
$(DIR)\spxesc.o:	spxesc.s lineaequ.s
$(DIR)\spxvline.o:	spxvline.s lineaequ.s
$(DIR)\spxtxtbl.o:	spxtxtbl.s lineaequ.s
$(DIR)\spxmono.o:	spxmono.s lineaequ.s
$(DIR)\spxhline.o:	spxhline.s lineaequ.s
$(DIR)\pxabline.o:	pxabline.s lineaequ.s
$(DIR)\pxrectfl.o:	pxrectfl.s lineaequ.s
$(DIR)\textblt.o:	textblt.s lineaequ.s
$(DIR)\vdivar.o:	vdivar.s lineaequ.s
$(DIR)\xfrmform.o:	xfrmform.s lineaequ.s
$(DIR)\pxmouse.o:	pxmouse.s lineaequ.s
$(DIR)\pxtform.o:	pxtform.s lineaequ.s
$(DIR)\routines.o:	routines.s vdiincld.s lineaequ.s
$(DIR)\spxtblit.o:	spxtblit.s lineaequ.s
$(DIR)\spxoblit.o:	spxoblit.s lineaequ.s
$(DIR)\hard.o:		hard.s lineaequ.s
$(DIR)\hpxoblit.o:	hpxoblit.s lineaequ.s

$(DIR)\cbssdefs.o:	cbssdefs.c portab.h gsxdef.h fontdef.h attrdef.h
$(DIR)\font6x6.o:	font6x6.c portab.h fontdef.h
$(DIR)\font8x8.o: 	font8x8.c portab.h fontdef.h
$(DIR)\font8x16.o:	font8x16.c portab.h fontdef.h
$(DIR)\fnt16x32.o:	fnt16x32.c portab.h fontdef.h
$(DIR)\isin.o:		isin.c portab.h
$(DIR)\jmptbl.o:	jmptbl.c gsxdef.h portab.h gsxextrn.h jmptbl.h
$(DIR)\monobj.o:	monobj.c portab.h gsxdef.h gsxextrn.h
$(DIR)\monout.o:	monout.c $(HFILES)
$(DIR)\seedfill.o:	seedfill.c portab.h gsxdef.h gsxextrn.h
$(DIR)\tables.o:	tables.c portab.h gsxdef.h styles.h
$(DIR)\text.o:		text.c portab.h gsxdef.h gsxextrn.h
$(DIR)\opnwk.o:		opnwk.c $(HFILES)
$(DIR)\ttcolor.o:	ttcolor.c portab.h gsxdef.h fontdef.h attrdef.h
$(DIR)\devices.o:	devices.c portab.h scrndev.h
$(DIR)\init.o:		init.c $(HFILES)
$(DIR)\spcolor.o:	spcolor.c $(HFILES)
$(DIR)\trucolor.o:	trucolor.c $(HFILES)
