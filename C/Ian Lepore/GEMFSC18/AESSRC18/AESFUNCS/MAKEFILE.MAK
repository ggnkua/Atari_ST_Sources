
CFLAGS = -I..\include\ -O -v2

DELLIB = $(RM)
ADDLIB = ar.ttp q

SYSHDR = c:\sozobon\include\gemfast.h
LCLHDR = ..\include\gemfast.h

LIB  = aesfuncs.a

OBJ03 = frmqchoi.o frmqerr.o  frmqmenu.o frmqtext.o frmquest.o
OBJ05 = frmerror.o frmverro.o frmprtf.o  frmvprtf.o
OBJ10 = frmnldia.o frmdsdia.o frmnlmen.o frmdsmen.o 
OBJ13 = frmmenu.o  frmprogr.o frmenabl.o frmeflag.o frmdial.o
OBJ15 = frmdeskt.o frmconfi.o frmvfmt.o  frmnldsu.o frmmkmov.o
OBJ20 = fsldialo.o grfmblit.o grfblit.o  grfmouse.o
OBJ25 = rsccubtn.o rscrrbtn.o rscsxtyp.o
OBJ30 = rscgstr.o  rscsstr.o  rscgtree.o rsctrfix.o
OBJ35 = objflchg.o objstchg.o objclcal.o objppstr.o objtherm.o
OBJ40 = objmxud.o  objrbutl.o objxtutl.o objbmbtn.o objoxywh.o
OBJ45 = wndupdat.o
OBJ50 = aplvwork.o aplxinit.o aplmallo.o
OBJ55 = mnutbar.o  mnubar.o   exterror.o rcconfin.o rcptinre.o

ALLOBJ = $(OBJ03) $(OBJ05) $(OBJ10) $(OBJ13) $(OBJ15) $(OBJ20) \
         $(OBJ25) $(OBJ30) $(OBJ35) $(OBJ40) $(OBJ45) $(OBJ50) $(OBJ55)

$(LIB): $(SYSHDR) $(ALLOBJ)
    $(DELLIB) $(LIB)
    $(ADDLIB) $(LIB) $(OBJ03)
    $(ADDLIB) $(LIB) $(OBJ05)
    $(ADDLIB) $(LIB) $(OBJ10)
    $(ADDLIB) $(LIB) $(OBJ13)
    $(ADDLIB) $(LIB) $(OBJ15)
    $(ADDLIB) $(LIB) $(OBJ20)
    $(ADDLIB) $(LIB) $(OBJ25)
    $(ADDLIB) $(LIB) $(OBJ30)
    $(ADDLIB) $(LIB) $(OBJ35)
    $(ADDLIB) $(LIB) $(OBJ40)
    $(ADDLIB) $(LIB) $(OBJ45)
    $(ADDLIB) $(LIB) $(OBJ50)
    $(ADDLIB) $(LIB) $(OBJ55)

c\:\sozobon\include\gemfast.h: $(LCLHDR)
    $(CP) $(LCLHDR) $(SYSHDR)

lib: $(LIB)
    $(PUSHDIR) ..
    make -h- lib
    $(POPDIR)

cleanup: 
    $(RM) *.o *.a
    
force: cleanup $(LIB)
    $(ECHO)

