# Makefile for XBIOS DSP calls

.SUFFIXES:
.SUFFIXES: .o .asm .c

CDFN = -i.

#  88 Argument type incorrect
# 135 Assignment to shorter data type (precision may be lost)
# -ce don't print error line source code
# -ch writable strings
# -ci include once
# -cu unsigned char
# -cw no warning for return w/o value
# -q- never quit
# -. quiet
CERR = -j88i -j135i -ce -ch -ci -cu -cw -q- -.

# Memory model
# -w 16 bit (word) ints
# -b0 no base register
# -bn use a4 as reg var.
# -v no stack checking
# -m3 68030 code
CMOD = -w -b0 -bn -v -m3

# options
# -C suppress "press Y to abort"
# -d2 local & global debug info
# -O optimize
# -mf make stack frames (link/unlk)
# -z2 DRI format output
# -hd3 -ha3 only use d3+ and a3+ as reg. vars
COPT = -C -d2 -O -mf -z2 -hd3 -ha3

LCFLAGS = $(CDFN) $(CERR) $(CMOD) $(COPT)

.asm.o:
	mac $<

.c.o:
	lcc -c $(LCFLAGS) -o$@ $<

dsp.o: dspbind.o loadbind.o prgbind.o
	aln -u -u -p -w -l -o $@ $<

loadbind.o: loadbind.c dspcode.h loadbind.i
