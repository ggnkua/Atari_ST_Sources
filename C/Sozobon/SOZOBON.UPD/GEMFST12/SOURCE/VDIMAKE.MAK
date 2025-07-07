#
# MAKEFILE for VDIFAST Public Domain VDI bindings.]
#  v1.1 - 02/10/89
#
#   This makefile is for the make util that comes with Sozobon C.  When
#   using other (less buggy) make programs, your mileage may vary.  
#
#   The players...
#     MAC.PRG      is the Atari Madmac assembler.  If you don't have
#                  this program, stop now, you lose (see VDI@NOTE.S).
#     AR.TTP       is the Sozobon archive/library maint util.  
#                  If you have Alcyon C, change this to AR68.PRG.
#     DOINDEX.TTP  is the library indexer for Atari's aln linker.
#                  If you don't use aln, macro-define IX as a comment.
#     GLOBS        is the Sozobon util to strip non-global symbols out
#                  of an object file.  If you don't have this, macro-define
#                  it as a comment. (Your finished lib will be bigger).
#

ASM   = MAC.PRG 
AR    = \SOZOBON\BIN\AR.TTP 
IX    = \SOZOBON\BIN\DOINDEX.TTP
GLOBS = \SOZOBON\BIN\GLOBS.TTP

#
# The modules which make up VDIFAST...
#

OBJ1 = vdi@note.o 
OBJ2 = vdiattr1.o vdiattr2.o vdiattr3.o vdiattr4.o vdicntl1.o vdicntl2.o 
OBJ3 = vdiescp1.o vdiescp2.o vdiinpt1.o vdiinpt2.o vdiinpt3.o 
OBJ4 = vdiinqr1.o vdiinqr2.o vdiinqr3.o vdioutp1.o vdioutp2.o vdioutp3.o 
OBJ5 = vdirastr.o vdicomn.o

#
# The main library...
#  The entire lib is deleted and rebuilt here.  This overcomes the
#  confusion AR.TTP tends to get about replacing modules, and also
#  guarantees the modules are in the proper order in the lib.
#

vdifast.a: $(OBJ1) $(OBJ2) $(OBJ3) $(OBJ4) $(OBJ5)
	$(RM) vdifast.a vdifast.ndx
	$(AR) qv vdifast.a $(OBJ1)
	$(AR) qv vdifast.a $(OBJ2)
	$(AR) qv vdifast.a $(OBJ3)
	$(AR) qv vdifast.a $(OBJ4)
	$(AR) qv vdifast.a $(OBJ5)
	$(AR) tv vdifast.a
	$(IX)	  vdifast.a

#
# Everybody (except note) depends on a change in the asm macros...
#

$(OBJ2) $(OBJ3) $(OBJ4) $(OBJ5) :	vdimacro.s

#
# Since Sozobon MAKE's default rule facility (.s.o:) doesn't work, we
# need to give rules/commands for each module (yuck!)...
#

vdi@note.o :	 vdi@note.s
	$(ASM)	 vdi@note.s
	$(GLOBS) vdi@note.o

vdiattr1.o  :	vdiattr1.s 
	$(ASM)	vdiattr1.s 
	$(GLOBS) vdiattr1.o

vdiattr2.o  :	vdiattr2.s 
	$(ASM)	vdiattr2.s 
	$(GLOBS) vdiattr2.o

vdiattr3.o  :	vdiattr3.s 
	$(ASM)	vdiattr3.s 
	$(GLOBS) vdiattr3.o

vdiattr4.o  :	vdiattr4.s 
	$(ASM)	vdiattr4.s 
	$(GLOBS) vdiattr4.o

vdicntl1.o  :	vdicntl1.s 
	$(ASM)	vdicntl1.s 
	$(GLOBS) vdicntl1.o

vdicntl2.o  :	vdicntl2.s 
	$(ASM)	vdicntl2.s 
	$(GLOBS) vdicntl2.o

vdicomn.o   :	vdicomn.s  
	$(ASM)	vdicomn.s 
	$(GLOBS) vdicomn.o

vdiescp1.o  :	vdiescp1.s 
	$(ASM)	vdiescp1.s 
	$(GLOBS) vdiescp1.o

vdiescp2.o  :	vdiescp2.s 
	$(ASM)	vdiescp2.s 
	$(GLOBS) vdiescp2.o

vdiinpt1.o  :	vdiinpt1.s 
	$(ASM)	vdiinpt1.s 
	$(GLOBS) vdiinpt1.o

vdiinpt2.o  :	vdiinpt2.s 
	$(ASM)	vdiinpt2.s 
	$(GLOBS) vdiinpt2.o

vdiinpt3.o  :	vdiinpt3.s 
	$(ASM)	vdiinpt3.s 
	$(GLOBS) vdiinpt3.o

vdiinqr1.o  :	vdiinqr1.s 
	$(ASM)	vdiinqr1.s 
	$(GLOBS) vdiinqr1.o

vdiinqr2.o  :	vdiinqr2.s 
	$(ASM)	vdiinqr2.s 
	$(GLOBS) vdiinqr2.o

vdiinqr3.o  :	vdiinqr3.s 
	$(ASM)	vdiinqr3.s 
	$(GLOBS) vdiinqr3.o

vdioutp1.o  :	vdioutp1.s 
	$(ASM)	vdioutp1.s 
	$(GLOBS) vdioutp1.o

vdioutp2.o  :	vdioutp2.s 
	$(ASM)	vdioutp2.s 
	$(GLOBS) vdioutp2.o

vdioutp3.o  :	vdioutp3.s 
	$(ASM)	vdioutp3.s 
	$(GLOBS) vdioutp3.o


vdirastr.o  :	vdirastr.s 
	$(ASM)	vdirastr.s 
	$(GLOBS) vdirastr.o

