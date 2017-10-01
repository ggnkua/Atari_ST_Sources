# Makefile for Tetrax

CC=cc

OBJS = ttx_init.o ttx_aes.o ttx_rsc.o ttx_disk.o ttx_main.o \
       xgriff.o ftab12.o ftab25.o ftab50.o

tetrax.prg: $(OBJS)
	$(CC) -saccappcr $(OBJS) -laes  -otetrax.prg

ttx_init.o: ttx_rsc.h
ttx_main.o: ttx_init.h ttx_aes.h ttx_rsc.h ttx_disk.h

xgriff.o:  xgriff.s
	$(CC) -c xgriff.s -o xgriff.o

ftab12.o:	ftab12.s
	$(CC) -c ftab12.s -o ftab12.o

ftab25.o:	ftab25.s
	$(CC) -c ftab25.s -o ftab25.o

ftab50.o:	ftab50.s
	$(CC) -c ftab50.s -o ftab50.o

clean:
	$(RM) *.o *.bak
