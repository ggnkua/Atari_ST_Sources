
NAME = vditest

CC	= gcc

ifeq ($(CC),vc)
# VBCC
CFLAGS	= -v -O1 -c99
LDFLAGS	= -g -lgem
else
# GCC
WARN    = -Wall -W -Wmissing-prototypes -Wstrict-prototypes \
  -Wsign-compare -Wbad-function-cast -Wcast-qual -Wpointer-arith \
  -Wwrite-strings -Wshadow -Wcast-align -Werror
CFLAGS	= -O2 $(WARN)
LDFLAGS	= -lgem
endif

SRCS = contour.c fvdibug.c vdicolor.c vdifill.c vdiline.c vdimark.c vditext.c #vdiblit.c
OBJS = $(patsubst %.c, %.o, $(SRCS)) vdiutil.o
PRGS = $(patsubst %.c, %.prg, $(SRCS))

all: $(PRGS)

$(OBJS): vdiutil.h

fvdibug.prg: fvdibug.o
	$(CC) -o $@ $< $(LDFLAGS)

contour.prg: contour.o vdiutil.o
	$(CC) -o $@ $< vdiutil.o $(LDFLAGS)

vdiblit.prg: vdiblit.o vdiutil.o
	$(CC) -o $@ $< vdiutil.o $(LDFLAGS)

vdicolor.prg: vdicolor.o vdiutil.o
	$(CC) -o $@ $< vdiutil.o $(LDFLAGS)

vdifill.prg: vdifill.o vdiutil.o
	$(CC) -o $@ $< vdiutil.o $(LDFLAGS)

vdiline.prg: vdiline.o vdiutil.o
	$(CC) -o $@ $< vdiutil.o $(LDFLAGS)

vdimark.prg: vdimark.o vdiutil.o
	$(CC) -o $@ $< vdiutil.o $(LDFLAGS)

vditext.prg: vditext.o vdiutil.o
	$(CC) -o $@ $< vdiutil.o $(LDFLAGS)


clean:
	$(RM) *~ *.o *.map

veryclean: clean
	$(RM) $(PRGS)

PKG := $(NAME)-$(shell date -I).zip

package: $(PRGS) clean
	cd ..; \
	$(RM) $(PKG); \
	zip -r $(PKG) tests.vdi/*
