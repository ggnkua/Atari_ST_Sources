PRG=etext.prg
ACC=etext.acc
CFLAGS=-v -O
#change the LIBS entry to reflect your setup
LIBS=\sozobon\lib\dlibs.a \sozobon\lib\aesfast.a

all:	etext.acc etext.prg

$(ACC):	etextacc.o
	ld -n -p -o etext.acc dastart.o etextacc.o $(LIBS)

$(PRG):	etext.o
	$(CC) $(CFLAGS) -o $(PRG) $*.o $(LIBS)	
		
etextacc.o: etext.c
	sh -c rm etextacc.o
	$(CC) $(CFLAGS) -c -DDESK_ACCESSORY etext.c
	sh -c mv etext.o etextacc.o
.c.o:
	$(CC) $(CFLAGS) -c $*.c
