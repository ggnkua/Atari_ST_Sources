#### Imakefile for YTalk version 3.0 ####
#
#			   NOTICE
#
# Copyright (c) 1990,1992,1993 Britt Yenne.  All rights reserved.
# 
# This software is provided AS-IS.  The author gives no warranty,
# real or assumed, and takes no responsibility whatsoever for any 
# use or misuse of this software, or any damage created by its use
# or misuse.
# 
# This software may be freely copied and distributed provided that
# no part of this NOTICE is deleted or edited in any manner.
# 

###################################
## CONFIGURATION  (The Fun Part) ##
###################################
#
# If your machine does not support TERMIOS (example: any NeXT running
# NeXTStep up to and including version 3.1), then uncomment the following
# line.
 
#TDEFS = -DUSE_SGTTY

#
# If you are running an older Sun OS using YP (now known as NIS), you might
# need to uncomment the next line if ytalk asks you "Who are you?"

#SLIBS = -lsun

#
# If you are on a sun running solaris 2.* you might need to uncomment the 
# following line.

#SLIBS = -lnsl -lsocket

#
# If your machine has a 64-bit architecture or uses 64-bit 'long's, then you
# will need to uncomment the following line.

#BDEFS = -DY64BIT

#
# If you have (or want) a system-wide .ytalkrc file, uncomment the next
# line and set it to the correct pathname.  The backslashes must remain
# before each double-quote.

#RCDEF = -DSYSTEM_YTALKRC=\"/usr/local/etc/ytalkrc\"

#
# If you plan to install ytalk on your system, you may want to modify
# the following lines.  Y_BINDIR is where the binary will be placed.
# Y_MANDIR is where the manpage will be placed.

Y_BINDIR = /usr/local/bin
Y_MANDIR = /usr/local/man/man1

############################################################
## Past this point, you shouldn't need to modify anything ##
############################################################
LIB = -lcurses -ltermcap $(SLIBS) $(XLIB)
CFLAGS = -I/usr/local/include $(TDEFS) $(BDEFS) $(RCDEF)
LDFLAGS = $(LDOPTIONS)
OBJ = main.o term.o user.o fd.o comm.o menu.o socket.o rc.o exec.o cwin.o \
      xwin.o
PRG = ytalk

all:	$(PRG) ytalk.cat

$(PRG):	$(OBJ)
	$(CC) $(LDFLAGS) -o $(PRG) $(OBJ) $(LIB)
    
ytalk.cat:	ytalk.1
	nroff -man ytalk.1 > ytalk.cat

start:	Imakefile
	sed 's/^DEFINES.*X11/CFLAGS =/' < Imakefile > Makefile

shar:
	make start
	shar -i Manifest -o ytalk-3.0.shar -t "== Now read the README file =="

clean::
	-rm -f $(OBJ)

install:: $(PRG)
	/bin/cp ytalk $(Y_BINDIR)
	/bin/cp ytalk.1 $(Y_MANDIR)
	@echo "Ytalk installation complete."

$(OBJ):		header.h
main.o:		menu.h
term.o:		cwin.h xwin.h menu.h
fd.o:		menu.h
comm.o:		socket.h menu.h
menu.o:		menu.h
socket.o:	socket.h
cwin.o:		cwin.h
xwin.o:		xwin.h

