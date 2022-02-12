
l = .
base = $(l)
include makeconfig
include $(l)/$(mk)/$(cfg).mk

LIB = $(LIBC)
#FLIB = libs/gnu/libcf.a
#MAKEFLAGS = -f makefile.gnu CC=gcc XCFLAGS="-DNOFLOAT=1 -D__MLONG__ -D_EM_WSIZE=4 -D_EM_LSIZE=4 -D_EM_PSIZE=4"
MAKEFLAGS = -f makefile.gnu
#FMAKEFLAGS = -f makefile.gnu CC=gcc XCFLAGS="-D__MLONG__ -D_EM_WSIZE=4 -D_EM_LSIZE=4 -D_EM_PSIZE=4"
FOBJS = doprnt.o doscan.o ecvt.o
FPOBJ = fphook.o
ibm=__sigreturn.s _sendrec.s brksize.s peekpoke.s portio.s setjmp.s

all:	
	cd $l/ansi;	     make $(MAKEFLAGS); $(AR) $(ARFLAGS) ../$(LIB) *.o
	cd $l/curses;	     make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../$(CURSESLIB) *.o
	cd $l/editline;	     make $(MAKEFLAGS); $(AR) $(ARFLAGS) ../$(EDITLINE) *.o
	cd $l/fphook;	     make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../$(LIB) *.o
	cd $l/math;	     make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../$(LIB) *.o
	cd $l/ip;	     make $(MAKEFLAGS); $(AR) $(ARFLAGS) ../$(LIB) *.o
	cd $l/other;	     make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../$(LIB) *.o
	cd $l/posix;	     make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../$(LIB) *.o
	cd $l/stdio;	     make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../$(LIB) *.o
	cd $l/syscall; 	     make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../$(LIB) *.o
	cd $l/syslib; 	     make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../$(LIB) *.o
	cd $l/`arch`/f64;    make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../../$(LIB) *.o
	cd $l/`arch`/rts;    make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../../$(LIB) *.o
#	cd $l/`arch`/string; make $(MAKEFLAGS);	$(AR) $(ARFLAGS) ../../$(LIB) *.o
	cd $l/`arch`/misc;   make $(MAKEFLAGS); $(AR) $(ARFLAGS) ../../$(LIB) *.o
#	$(AR) dv $(LIB) gcrtso.o
#	cp $(LIB) $(FLIB)
#	$(AR) dv $(FLIB) $(FOBJS) $(FPOBJ) strtod.o
#	cd $l/stdio;	rm -f $(FOBJS)
#	cd $l/stdio;	make $(FMAKEFLAGS) $(FOBJS); \
#		$(AR) rv ../$(FLIB) $(FOBJS) ; rm -f $(FOBJS)
#	cd $l/fphook;	rm -f $(FOBJS)
#	cd $l/fphook;	make $(FMAKEFLAGS) $(FPOBJ); \
#		$(AR) rv ../$(FLIB) $(FPOBJ) ; rm -f $(FPOBJ)


clean:
	cd $l/ansi;	  make $(MAKEFLAGS) clean
	cd $l/posix;	  make $(MAKEFLAGS) clean
	cd $l/other;	  make $(MAKEFLAGS) clean
	cd $l/curses;	  make $(MAKEFLAGS) clean
	cd $l/stdio;	  make $(MAKEFLAGS) clean
	cd $l/fphook;     make $(MAKEFLAGS) clean
	cd $l/math;	  make $(MAKEFLAGS) clean
	cd $l/ip;	  make $(MAKEFLAGS) clean
	cd $l/syscall;	  make $(MAKEFLAGS) clean
	cd $l/syslib;	  make $(MAKEFLAGS) clean
	cd $l/`arch`/f64; make $(MAKEFLAGS) clean
	cd $l/`arch`/rts; make $(MAKEFLAGS) clean
	cd $l/`arch`/string; make $(MAKEFLAGS) clean
	cd $l/`arch`/misc; make $(MAKEFLAGS) clean
#	cd $l/float;	  make $(MAKEFLAGS) clean
