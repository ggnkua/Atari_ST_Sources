OFILES=xlisp.obj xlbfun.obj xlcont.obj xldbug.obj xldmem.obj xleval.obj \
xlfio.obj xlglob.obj xlimage.obj xlinit.obj xlio.obj xljump.obj xllist.obj \
xlmath.obj xlobj.obj xlpp.obj xlprin.obj xlread.obj xlstr.obj xlstruct.obj \
xlsubr.obj xlsym.obj xlsys.obj msstuff.obj

CFLAGS=-ml -f -O -G -w-pia -w-def -w-aus -Ic:\turboc\include

.c.obj:
	tcc -c $(CFLAGS) $<

xlisp.exe:	$(OFILES) xlftab.obj
	tlink @xlisp.lnk

xlftab.obj:	xlisp.h osdefs.h osptrs.h
$(OFILES):	xlisp.h

