CFLAGS=-O
OBJS= 	proff.o proff01.o proff02.o lookup.o pinit.o putwrd.o\
	pxlex.o pxxparse.o dostuff2.o eval.o stack.o map.o
proff: $(OBJS)
	cc -s -o proff $(OBJS)

$(OBJS): lextab.h lextab.d

lextab.h lextab.d: proffsym.new ltb
	ltb proffsym.new lextab

ltb: ltb.o look.o
	cc -s -o ltb ltb.o look.o
clean:
	rm proff *.o
arch:
	./archc Makefile *.c *.h proffsym.new >proff.arc

