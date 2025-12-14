#
#	Makefile for the Mint-Net "test suite"
#

all: server client sockpair dgram dgramd speed speedd sockname

CC = tcc -v
CFLAGS = -fabsolute-calls
CPPFLAGS = -I=..\\lib
LIBS = socket.lib

server: server.o
	$(CC) $(CFLAGS) server.o $(LIBS) -o server.ttp
	chmod +x server.ttp

client: client.o
	$(CC) $(CFLAGS) client.o $(LIBS) -o client.ttp
	chmod +x client.ttp

speed: speed.o
	$(CC) $(CFLAGS) speed.o $(LIBS) -o speed.ttp
	chmod +x speed.ttp

speedd: speedd.o
	$(CC) $(CFLAGS) speedd.o $(LIBS) -o speedd.ttp
	chmod +x speedd.ttp

sockpair: sockpair.o
	$(CC) $(CFLAGS) sockpair.o $(LIBS) -o sockpair.ttp
	chmod +x sockpair.ttp

dgram: dgram.o
	$(CC) $(CFLAGS) dgram.o $(LIBS) -o dgram.ttp
	chmod +x dgram.ttp

dgramd: dgramd.o
	$(CC) $(CFLAGS) dgramd.o $(LIBS) -o dgramd.ttp
	chmod +x dgramd.ttp

sockname: sockname.o
	$(CC) $(CFLAGS) sockname.o $(LIBS) -o sockname.ttp
	chmod +x sockname.ttp

# No dependencies jet
depend:

clean:
	rm -f *.o
