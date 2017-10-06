#
# MAKEFILE for VDIFAST Public Domain VDI bindings.
#
#   This makefile is for the make util that comes with Sozobon C.
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

VERSION = 18
ASM     = MAC.PRG
AR      = AR.TTP
IX      = DOINDEX.TTP
GLOBS   = GLOBS.TTP

#
# Override Sozobon's assembler->object rule to use MAC and GLOBS...
#

.s.o:
    $(ASM)   $(AFLAGS) $*.s
    $(GLOBS) $*.o

#
# The modules which make up VDIFAST...
#

LIB     = vdifast.a

OBJ01   = varcpie.o    vbar.o       vcellary.o   vcircle.o    vcontour.o
OBJ02   = vcurtext.o   vdspcur.o    vellipse.o   vescapes.o   vextimev.o
OBJ03   = vexvecto.o   vfillare.o   vgchar.o     vgdetect.o   vgetpix.o
OBJ04   = vgtext.o     vinstrin.o   vjustify.o   vlarcpie.o   vlocator.o
OBJ05   = voutwind.o   vpline.o     vpmarker.o   vqchcell.o   vqcolor.o
OBJ06   = vqcuradd.o   vqextnd.o    vqfattr.o    vqinmode.o   vqkeys.o
OBJ07   = vqlattr.o    vqmattr.o    vqmouse.o    vqtattr.o    vqtextnt.o
OBJ08   = vqtfinfo.o   vqtname.o    vqtwidth.o   vrbox.o      vrcpyfm.o
OBJ09   = vrecfl.o     vrqchoic.o   vrtrnfm.o    vscform.o    vsclip.o
OBJ10   = vscolor.o    vscuradd.o   vsetattr.o   vsfudpat.o   vshowc.o
OBJ11   = vsinmode.o   vslends.o    vslwidth.o   vsmchoic.o   vsmheigh.o
OBJ12   = vspalett.o   vstalign.o   vstfonts.o   vstheigh.o   vstpoint.o
OBJ13   = vvaluato.o   vwkstatn.o   vdi@note.o

OBJLAST = voutpxy.o    vstrstak.o   vdicomn.o # these MUST be last in library!

OBJS    = $(OBJ01) $(OBJ02) $(OBJ03) $(OBJ04) $(OBJ05) $(OBJ06) $(OBJ07) \
          $(OBJ08) $(OBJ09) $(OBJ10) $(OBJ11) $(OBJ12) $(OBJ13)          \
          $(OBJLAST)

#
# The main library...
#  The entire lib is deleted and rebuilt here.  This overcomes the
#  confusion AR.TTP tends to get about replacing modules, and also
#  guarantees the modules are in the proper order in the lib.
#

$(LIB): $(OBJS) makefile.mak
    $(RM) $(LIB) vdifast.ndx
    $(AR) qv $(LIB) $(OBJ01) 
    $(AR) qv $(LIB) $(OBJ02) 
    $(AR) qv $(LIB) $(OBJ03) 
    $(AR) qv $(LIB) $(OBJ04) 
    $(AR) qv $(LIB) $(OBJ05) 
    $(AR) qv $(LIB) $(OBJ06) 
    $(AR) qv $(LIB) $(OBJ07) 
    $(AR) qv $(LIB) $(OBJ08) 
    $(AR) qv $(LIB) $(OBJ09) 
    $(AR) qv $(LIB) $(OBJ10) 
    $(AR) qv $(LIB) $(OBJ11) 
    $(AR) qv $(LIB) $(OBJ12) 
    $(AR) qv $(LIB) $(OBJ13)
    $(AR) qv $(LIB) $(OBJLAST)

#
# Everybody depends on a change in the asm macros...
#

$(OBJS): vdimacro.s

#
# misc targets, used to backup and cleanup a version...
#

cleanup:
    $(RM) $(OBJ01) $(OBJ02) $(OBJ03) $(OBJ04) $(OBJ05) $(OBJ06)
    $(RM) $(OBJ07) $(OBJ08) $(OBJ09) $(OBJ10) $(OBJ11) $(OBJ12) 
    $(RM) $(OBJ13) $(OBJLAST)
    
force: cleanup $(LIB)
    $(ECHO) All remade!

