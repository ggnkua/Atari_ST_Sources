#Makefile for "STED - The STUNE EDITOR"

CFLAGS = -I..  #-O +O-q-r +C-Q


OBS=stedinit.o stedgraf.o sted_aes.o steddisk.o  stedmain.o \
    ..\gebaeude.o ..\loadimg.o

sted: $(OBS)
	$(CC) $(OBS) -laes -lvdi -osted.prg

stedinit.o: sted.rsh stedmain.h stedgraf.h ..\loadimg.h ..\stunedef.h
stedgraf.o: stedmain.h ..\stunedef.h 
sted_aes.o: stedmain.h sted.rsh
stedmain.o: sted.rsh stedinit.h stedgraf.h ..\stunedef.h

clean:
	$(RM) *.o *.bak
