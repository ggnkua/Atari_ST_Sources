#	makefile for FFT, IFFT, RI2M
CFLAGS= -w-par -w-pia -w-rvl
fft.exe: fft.obj args.obj
	tcc $(CFLAGS) fft.obj args.obj

ifft.exe: ifft.obj args.obj
	tcc $(CFLAGS) ifft.obj args.obj

ri2m.exe: ri2m.obj args.obj
	tcc $(CFLAGS) ri2m.obj args.obj

fft.obj: fft.c
ifft.obj: ifft.c
ri2m.obj: ri2m.c
args.obj: args.c

.c.obj:
	tcc -c $(CFLAGS) $* 

clean:
	erase fft.obj
	erase ifft.obj
	erase ri2m.obj
	erase args.obj

all: fft.exe ifft.exe ri2m.exe
distrib: fft.zip
fft.zip: readme args.c d.f d.f2 d.f3 d.t fft.c fft.doc fft.exe\
	fft.fil ifft.c ifft.doc ifft.exe ri2m.c ri2m.doc ri2m.exe makefile 
	echo fast fourier transforms|pkzip -z fft.zip
	pkzip -u fft @fft.fil
