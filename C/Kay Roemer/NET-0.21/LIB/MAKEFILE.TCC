#
#	Makefile for the socket library.
#	modified by Thomas Schulze for use with TurboC
#

SHELL = /bin/sh

# this is written to use my own tcc driver. its very experimental
# and an awfull mess of hacks and tricks, so i will probably not
# distribute it in the near future:-((

CC = tcc -v
LD = tcc -v -d

#
# if you define UNX2DOS, all path names specified by `struct sockaddr_un'
# will be converted from unix style to dos style prior to passing them
# to the OS. Note that this is time consuming, espacially for sendto().
# You MUST define UNX2DOS if you are going to use unix style path names
# containing / and the like.
#
CPPFLAGS = -I=..\\include -DUNX2DOS
# -fabsolute-calls means use absolute calls inside modules when calling
# functions. (means -P for TC users...)
CFLAGS = -fabsolute-calls

SRCS = socket.c socketpair.c bind.c listen.c connect.c accept.c \
  recv.c send.c recvfrom.c sendto.c shutdown.c getsockname.c \
  getpeername.c getsockopt.c setsockopt.c sendmsg.c recvmsg.c \
  sncpy.c

OBJS = socket.o socketpair.o bind.o listen.o connect.o accept.o \
  recv.o send.o recvfrom.o sendto.o shutdown.o getsockname.o \
  getpeername.o getsockopt.o setsockopt.o sendmsg.o recvmsg.o \
  sncpy.o

SOCKETLIB = socket.lib

.c.o:
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

all: lib 

lib: $(OBJS)
	$(LD) -G -J -o $(SOCKETLIB) $(OBJS)

clean:
	rm -f $(OBJS) *.trg

depend:
	$(CC) -MM $(CPPFLAGS) *.c > depend

ifeq (depend, $(wildcard depend))
include depend
endif
