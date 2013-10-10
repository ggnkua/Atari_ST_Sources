#
# Makefile for GREENDLE.APP
#

OBJ =	greendle.o init.o config.o dialog.o dtools.o popup.o fsel.o \
			 	event.o menu.o formatmg.o send.o mailbox.o msgload.o \
			 	msgwindw.o window.o transfer.o process.o pop3.o sockets.o \
			 	scroll.o util.o utils.o vdi.o vars.o adaptrsc.o
CFL =		-w -v -b4 -r6 -rs -m0 -d4 -fm -j149i
CFLAGS =	${CFL}
#CFLAGS =	-b4 -r6 -v -w -d4 -m0 -rs -fm -j149i
#CFL =	${CFLAGS}
ASFLAGS =	-m0 -w
LDFLAGS =	-Lvg+..\MT_AES\MT_AES.LIB -w
#CC=lc.ttp

GREENDLE.APP: ${OBJ}
	${LD} ${CFLAGS} ${LDFLAGS} -ogreendle.app ${OBJ}

greendle.o:	greendle.c init.h mt_aes.h vars.h event.h

init.o:		init.c mt_aes.h config.h init.h vars.h popup.h vdiws.h \
				greendle.h util.h

config.o:	config.c	mt_aes.h init.h config.h util.h vars.h

dialog.o:	dialog.c	mt_aes.h fsel.h event.h dialog.h vars.h greendle.h \
				dtools.h

dtools.o:	dtools.c	mt_aes.h vars.h dtools.h

popup.o:		popup.c mt_aes.h vars.h popup.h

fsel.o:		fsel.c mt_aes.h fsel.h

event.o:		event.c mt_aes.h event.h menu.h vars.h window.h mailbox.h \
				transfer.h greendle.h dialog.h dtools.h

menu.o:		menu.c mt_aes.h menu.h vars.h window.h mailbox.h transfer.h \
				greendle.h dialog.h dtools.h send.h

send.o:		send.c mt_aes.h vars.h defs.h greendle.h mailbox.h msgload.h \
				dialog.h dtools.h util.h

mailbox.o:	mailbox.c mt_aes.h vars.h defs.h greendle.h mailbox.h \
				msgload.h dialog.h dtools.h util.h scroll.h

msgload.o:	msgload.c mt_aes.h vars.h defs.h formatmg.h util.h

msgwindw.o:	msgwindw.c mt_aes.h vars.h defs.h formatmg.h util.h

formatmg.o:	formatmg.s

window.o:	window.c mt_aes.h vars.h defs.h window.h mailbox.h

transfer.o:	transfer.c mt_aes.h defs.h transfer.h pop3.h process.h \
				drivers.h transprt.h vars.h

process.o:	process.c mt_aes.h defs.h transfer.h process.h drivers.h \
				transprt.h vars.h

pop3.o:		pop3.c mt_aes.h defs.h pop3.h drivers.h transprt.h vars.h

sockets.o:	sockets.c mt_aes.h defs.h pop3.h drivers.h transprt.h vars.h

scroll.o:	scroll.c	mt_aes.h scroll.h vdiws.h vars.h

util.o:		util.c mt_aes.h defs.h util.h vars.h

utils.o:		utils.s

vdi.o:		vdi.c

vars.o:		vars.c vdiws.h mt_aes.h icons.c defs.h drivers.h transprt.h \
				vars.h

adaptrsc.o:	adaptrsc.c adaptrsc.h vdiws.h

clean:
	rm -f *.o
