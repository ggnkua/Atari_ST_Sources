# makefile for gcc

CC=gcc
FLAGS=-Datarist -O -fstrength-reduce -mshort
EXT=16
GDBFLAGS=#-gg -D__NO_INLINE__
CFLAGS=$(FLAGS) $(GDBFLAGS)
NM=xstrip
OBJS=$(NM).o
PGM=$(NM).ttp

$(PGM):$(OBJS)
	$(CC) $(FLAGS) -o $(PGM) $(OBJS) -liio$(EXT) -x
#	sym-ld -r -o $(NM).sym c:\gnu\lib\crt0.o $(NM).o -lgnu$(EXT)
