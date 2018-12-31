#DB=		ASCII_DB
DB=		BINARY_DB

#{{{script}}}#{{{ MiNT
CC=		gcc
CFLAGS=		-g -O2 -Wall -Wmissing-prototypes -Wstrict-prototypes -Wcast-qual -Wpointer-arith -Wcast-align -Wwrite-strings -Wnested-externs -fno-common
CPPFLAGS=	-D$(DB)
LDFLAGS=	-g
LIBS=		-lncurses
MAKEDEPEND=	gcc -MM
#{{{script}}}#{{{ Linux, moria machines
#CFLAGS=		-g -pipe -O2 -Wall -Wmissing-prototypes -Wstrict-prototypes -Wcast-qual -Wpointer-arith -Wcast-align -Wwrite-strings -Wmissing-declarations -Wnested-externs -pedantic -fno-common
#CPPFLAGS=	-D$(DB)
#LDFLAGS=	-g
#LIBS=		-lcurses
#MAKEDEPEND=	mkdep -d
#}}}
#{{{ Linux, RedHat & Debian, ncurses
#CFLAGS=		-pipe -O2 -Wall -Wmissing-prototypes -Wstrict-prototypes -Wcast-qual -Wpointer-arith -Wcast-align -Wwrite-strings -Wmissing-declarations -Wnested-externs -pedantic -fno-common
#CPPFLAGS=	-D$(DB)
#LDFLAGS=	
#LIBS=		-lncurses
#MAKEDEPEND=	gcc -MM
#}}}
#{{{ Solaris, gcc
#CC=		gcc
#CFLAGS=		-pipe -O2 -Wall -Wmissing-prototypes -Wstrict-prototypes -Wcast-qual -Wpointer-arith -Wcast-align -Wwrite-strings -Wmissing-declarations -Wnested-externs -pedantic -fno-common
#CPPFLAGS=	-DNO_POSIX_SOURCE -D$(DB)
#LDFLAGS=	
#LIBS=		-lcurses
#MAKEDEPEND=	gcc -MM
#}}}
#{{{ Solaris, SunPro cc
#CFLAGS=		-xstrconst -xO2 -v
#CPPFLAGS=	-DNO_POSIX_SOURCE -D$(DB)
#LDFLAGS=	
#LIBS=		-lcurses
#MAKEDEPEND=	makedepend -f-
#}}}
#{{{ FreeBSD, gcc, ncurses
#CC=		gcc
#CFLAGS=		-pipe -O2 -Wall -Wmissing-prototypes -Wstrict-prototypes -Wcast-qual -Wpointer-arith -Wcast-align -Wwrite-strings -Wmissing-declarations -Wnested-externs -pedantic -fno-common $(CPPFLAGS)
#CPPFLAGS=	-I.curses.h -DNO_POSIX_SOURCE -D$(DB)
#LIBS=		-lncurses -lmytinfo
#LDFLAGS=	
#MAKEDEPEND=	gcc -MM
#}}}
#{{{ SunOS 4, gcc
#CC=		gcc
#CFLAGS=		-pipe -O2 -fno-common
#CPPFLAGS=	-D$(DB) -I/usr/5include -DHAS_VFORK -DNEEDS_SSIZE_T -DNEEDS_MEMMOVE -DNEEDS_STRERROR
#LDFLAGS=	
#LIBS=		-L/usr/5lib -lcurses
#MAKEDEPEND=	gcc -MM
#}}}
#{{{ HP-UX A.09.01, unbundled cc, ncurses
#CFLAGS=		-Aa +ESlit -O +w1
#CPPFLAGS=	-I$(HOME)/ncurses/include -D$(DB)
#LDFLAGS=	-L$(HOME)/ncurses/lib.hp -z
#LIBS=		-lncurses
#MAKEDEPEND=	makedepend -f-
#}}}
#{{{ HP-UX A.09.01, gcc, ncurses
#CC=		gcc
#CFLAGS=		-pipe -O2 -Wall -Wmissing-prototypes -Wstrict-prototypes -Wcast-qual -Wpointer-arith -Wcast-align -Wwrite-strings -Wmissing-declarations -Wnested-externs -pedantic -fno-common
#CPPFLAGS=	-I$(HOME)/ncurses/include -D$(DB)
#LDFLAGS=	-L$(HOME)/ncurses/lib.hp -z
#LIBS=		-lncurses
#MAKEDEPEND=	gcc -MM
#}}}


cs:		alloc.o db.o getline.o pager.o scan.o main.o misc.o
		$(CC) -o $@ $(LDFLAGS) alloc.o db.o getline.o pager.o scan.o main.o misc.o $(LIBS)

#{{{ clean
clean:
		rm -f *.o
#}}}
#{{{ clobber
clobber:	clean
		rm -f core *.out cs
#}}}
#{{{ depend
depend:
		$(MAKEDEPEND) $(CPPFLAGS) *.c >.depend
#}}}
#{{{ tar
tar:		clobber
		(b=`pwd`; b=`basename $$b`; cd ..; tar zcvf $$b.tar.gz $$b/*.html $$b/ANNOUNCE $$b/Makefile $$b/.depend $$b/cs.1 $$b/*.[ch] $$b/.curses.h $$b/cemacs)
#}}}
#{{{ wc
wc:
		@wc -cl *.[ch] | tail -1
#}}}

include .depend
