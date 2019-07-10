OBJ1=xscheme.obj xsdmem.obj xsftab.obj xsimage.obj xsio.obj xsobj.obj \
xsprint.obj xsread.obj xssym.obj xsfun1.obj xsfun2.obj xsmath.obj \
msstuff.obj

OBJ2=xsinit.obj xscom.obj xsint.obj

CFLAGS=-ml -f -O -G -w-pia -w-def -w-aus -Ic:\turboc\include

.c.obj:
	tcc -c $(CFLAGS) $<

xscheme.exe:	$(OBJ1) $(OBJ2)
	tlink @xscheme.lnk

$(OBJ1):	xscheme.h
$(OBJ2):	xscheme.h xsbcode.h
