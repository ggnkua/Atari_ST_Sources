#
# makefile for the GemFast AES bindings...
#

DELLIB = $(RM)
ADDLIB = AR.TTP q

#
# The modules which make up the bindings...
#

LIB    = aesbind.a

ONOT   = aes@note.o
OAP1   = aesappl1.o aesappl2.o
OEV1   = aesevnt1.o aesevnt2.o aesevnt3.o
OEV2   = aesevnt4.o aesevnt5.o aesevnt6.o
OFM1   = aesform1.o aesform2.o aesform3.o
OMN1   = aesmenu1.o aesmenu2.o
OFS1   = aesfsel1.o aesfsel2.o aesfsel3.o
OGR1   = aesgraf1.o aesgraf2.o aesgraf3.o aesgraf4.o aesgraf5.o
OOB1   = aesobjc1.o aesobjc2.o
ORS1   = aesrsrc1.o aesrsrc2.o
OSH1   = aesshel1.o aesshel2.o aesscrp.o
OWN1   = aeswind1.o aeswind2.o
OCMN   = aescomn.o

ALLOBJ = $(ONOT) $(OAP1) $(OEV1) $(OEV2) $(OFM1) $(OMN1) $(OFS1) \
         $(OFS1) $(OGR1) $(OOB1) $(ORS1) $(OSH1) $(OWN1) $(OCMN)

#
# Set the default rule for assembler source to be the madmac assembler.
#

.s.o:
    mac.prg   $*.s
    globs.ttp $*.o

#
# The main target...
#  The entire lib is deleted and rebuilt here. This overcomes the
#  confusion AR.TTP tends to get about replacing modules, and also
#  guarantees the modules are in the proper order in the lib.
#

$(LIB): $(ALLOBJ)
    $(DELLIB) $(LIB)
    $(ADDLIB) $(LIB) $(ONOT)
    $(ADDLIB) $(LIB) $(OAP1)
    $(ADDLIB) $(LIB) $(OEV1)
    $(ADDLIB) $(LIB) $(OEV2)
    $(ADDLIB) $(LIB) $(OFM1)
    $(ADDLIB) $(LIB) $(OFS1)
    $(ADDLIB) $(LIB) $(OGR1)
    $(ADDLIB) $(LIB) $(OMN1)
    $(ADDLIB) $(LIB) $(OOB1)
    $(ADDLIB) $(LIB) $(ORS1)
    $(ADDLIB) $(LIB) $(OSH1)
    $(ADDLIB) $(LIB) $(OWN1)
    $(ADDLIB) $(LIB) $(OCMN)

cleanup:
    del *.o *.a
    
force: cleanup $(LIB)
    @echo

