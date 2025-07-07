#
# MAKEFILE for AESFAST Public Domain AES bindings.]
#  v1.1 - 02/10/89
#
#   This makefile is for the make util that comes with Sozobon C.  When
#   using other (less buggy) make programs, your mileage may vary.  
#
#   The players...
#     MAC.PRG       is the Atari Madmac assembler.  If you don't have
#                   this program, stop now, you lose (see AES@NOTE.S).
#     AR.TTP        is the Sozobon archive/library maint util.  
#                   If you have Alcyon C, change this to AR68.PRG.
#     DOINDEX.TTP   is the library indexer for Atari's aln linker.
#                   If you don't use aln, macro-define IX as a comment.
#     GLOBS         is the Sozobon util to strip non-global symbols out
#                   of an object file.  If you don't have this, macro-define
#                   it as a comment. (Your finished lib will be bigger).
#

ASM   = MAC.PRG  
AR    = AR.TTP 
IX    = DOINDEX.TTP
GLOBS = GLOBS.TTP

#
# The modules which make up AESFAST...
#

ONOT = aes@note.o 
OUT1 = aesutgr1.o aesutob1.o aesutob2.o aesutob3.o aesutob4.o 
OUT2 = aesutrc1.o aesutrc2.o aesutrc3.o aesutrc4.o 
OUT3 = aesutrs1.o aesutrs2.o aesutrs3.o
OAP1 = aesappl1.o aesappl2.o 
OEV1 = aesevnt1.o aesevnt2.o aesevnt3.o 
OEV2 = aesevnt4.o aesevnt5.o aesevnt6.o
OFM1 = aesform1.o aesform2.o aesform3.o
OMN1 = aesmenu1.o aesmenu2.o
OFS1 = aesfsel1.o aesfsel2.o aesfsel3.o
OGR1 = aesgraf1.o aesgraf2.o aesgraf3.o aesgraf4.o aesgraf5.o
OOB1 = aesobjc1.o aesobjc2.o 
ORS1 = aesrsrc1.o aesrsrc2.o 
OSH1 = aesshel1.o aesshel2.o aesscrp.o  
OWN1 = aeswind1.o aeswind2.o 
OCMN = aescomn.o

#
# Set the default rule for assembler source to be the madmac assembler.
#

.s.o:
	$(ASM)	 $*.s
	$(GLOBS) $*.o

#
# The main library...
#  The entire lib is deleted and rebuilt here. This overcomes the
#  confusion AR.TTP tends to get about replacing modules, and also
#  guarantees the modules are in the proper order in the lib.
#  (Proper order means essentially that the 'ut' modules call each
#  other, and mostly call normal AES functions, so they have to be 
#  first in the library to avoid multiple linker passes.)
#

aesfast.a: $(ONOT) $(OUT1) $(OUT2) $(OUT3) $(OAP1) $(OEV1) $(OEV2) \
$(OFM1) $(OFS1) $(OGR1) $(OMN1) $(OOB1) $(ORS1) $(OSH1) $(OWN1) $(OCMN)

	$(RM) aesfast.a aesfast.ndx
	$(AR) qv aesfast.a $(ONT1)
	$(AR) qv aesfast.a $(OUT1)
	$(AR) qv aesfast.a $(OUT2)
	$(AR) qv aesfast.a $(OUT3)
	$(AR) qv aesfast.a $(OAP1)
	$(AR) qv aesfast.a $(OEV1)
	$(AR) qv aesfast.a $(OEV2)
	$(AR) qv aesfast.a $(OFM1)
	$(AR) qv aesfast.a $(OFS1)
	$(AR) qv aesfast.a $(OGR1)
	$(AR) qv aesfast.a $(OMN1)
	$(AR) qv aesfast.a $(OOB1)
	$(AR) qv aesfast.a $(ORS1)
	$(AR) qv aesfast.a $(OSH1)
	$(AR) qv aesfast.a $(OWN1)
	$(AR) qv aesfast.a $(OCMN)
	$(AR) tv aesfast.a
	$(IX)    aesfast.a

#
# Everybody depends on a change in the asm macros...
#

$(ONOT) $(OUT1) $(OUT2) $(OUT3) $(OAP1) $(OEV1) $(OFM1) \
$(OFS1) $(OGR1) $(OMN1) $(OOB1) $(ORS1) $(OSH1) $(OWN1) \
$(OCMN) : aesfast.sh gemfast.sh

