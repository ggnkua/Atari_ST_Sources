# Makefile for Metaware High C

OBJ1=xscheme.obj xsdmem.obj xsimage.obj xsio.obj xsobj.obj \
xsprint.obj xsread.obj xssym.obj xsfun1.obj xsfun2.obj xsmath.obj \
msstuff.obj

OBJ2=xsinit.obj xscom.obj xsint.obj

CFLAGS=-Hansi -O -DHIGHC

.c.obj:
	hc386 -c $(CFLAGS) $<

xs_hc.exp:	$(OBJ1) $(OBJ2) xsftab.obj
	hc386 -o xs_hc xs*.obj msstuff.obj

$(OBJ1):	xscheme.h xsproto.h
$(OBJ2):	xscheme.h xsproto.h xsbcode.h
xsftab.obj:	xscheme.h xsproto.h osdefs.h osptrs.h
