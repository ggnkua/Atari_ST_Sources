BIN=
CC= gcc -O2
s3mod:	mod.o s3m.o main.o play.o gus.o mix.o cmdline.o
	$(CC) -o s3mod.ttp s3m.o mod.o main.o play.o gus.o mix.o cmdline.o

mod.o: mod.c
	$(CC) -c mod.c

s3m.o: s3m.c
	$(CC) -c s3m.c

main.o: main.c
	$(CC) -c main.c

play.o: play.c
	$(CC) -c play.c

gus.o:  gus.c
	$(CC) -c gus.c

mix.o: mix.c
	$(CC) -c mix.c

cmdline.o: cmdline.c
	$(CC) -c cmdline.c

clean:
	rm mod.o s3m.o s3mod gus.o play.o main.o cmdline.o
