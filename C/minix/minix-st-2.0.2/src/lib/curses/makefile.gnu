# Makefile for lib/curses.

base = ..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= $(XCFLAGS)
CC1	= $(CC) $(CFLAGS) -c

LIBRARY	= $(CURSESLIB)
all:	$(LIBRARY)

OBJECTS	= \
	beep.o \
	charpick.o \
	curs_set.o \
	cursesio.o \
	endwin.o \
	flash.o \
	initscr.o \
	longname.o \
	move.o \
	mvcursor.o \
	newwin.o \
	options.o \
	overlay.o \
	prntscan.o \
	refresh.o \
	scrreg.o \
	setterm.o \
	tabsize.o \
	termmisc.o \
	unctrl.o \
	update.o \
	waddch.o \
	waddstr.o \
	wbox.o \
	wclear.o \
	wclrtobot.o \
	wclrtoeol.o \
	wdelch.o \
	wdeleteln.o \
	werase.o \
	wgetch.o \
	wgetstr.o \
	windel.o \
	winmove.o \
	winsch.o \
	winscrol.o \
	winsertln.o \
	wintouch.o \

$(LIBRARY):	$(OBJECTS)
	$(AR) $(ARFLAGS) $@ *.o
	$(RM) *.o

clean:
	$(RM) *.o

clobber: clean

beep.o:	beep.c
	$(CC1) beep.c

charpick.o:	charpick.c
	$(CC1) charpick.c

curs_set.o:	curs_set.c
	$(CC1) curs_set.c

cursesio.o:	cursesio.c
	$(CC1) cursesio.c

endwin.o:	endwin.c
	$(CC1) endwin.c

flash.o:	flash.c
	$(CC1) flash.c

initscr.o:	initscr.c
	$(CC1) initscr.c

longname.o:	longname.c
	$(CC1) longname.c

move.o:	move.c
	$(CC1) move.c

mvcursor.o:	mvcursor.c
	$(CC1) mvcursor.c

newwin.o:	newwin.c
	$(CC1) newwin.c

options.o:	options.c
	$(CC1) options.c

overlay.o:	overlay.c
	$(CC1) overlay.c

prntscan.o:	prntscan.c
	$(CC1) prntscan.c

refresh.o:	refresh.c
	$(CC1) refresh.c

scrreg.o:	scrreg.c
	$(CC1) scrreg.c

setterm.o:	setterm.c
	$(CC1) setterm.c

tabsize.o:	tabsize.c
	$(CC1) tabsize.c

termmisc.o:	termmisc.c
	$(CC1) termmisc.c

unctrl.o:	unctrl.c
	$(CC1) unctrl.c

update.o:	update.c
	$(CC1) update.c

waddch.o:	waddch.c
	$(CC1) waddch.c

waddstr.o:	waddstr.c
	$(CC1) waddstr.c

wbox.o:	wbox.c
	$(CC1) wbox.c

wclear.o:	wclear.c
	$(CC1) wclear.c

wclrtobot.o:	wclrtobot.c
	$(CC1) wclrtobot.c

wclrtoeol.o:	wclrtoeol.c
	$(CC1) wclrtoeol.c

wdelch.o:	wdelch.c
	$(CC1) wdelch.c

wdeleteln.o:	wdeleteln.c
	$(CC1) wdeleteln.c

werase.o:	werase.c
	$(CC1) werase.c

wgetch.o:	wgetch.c
	$(CC1) wgetch.c

wgetstr.o:	wgetstr.c
	$(CC1) wgetstr.c

windel.o:	windel.c
	$(CC1) windel.c

winmove.o:	winmove.c
	$(CC1) winmove.c

winsch.o:	winsch.c
	$(CC1) winsch.c

winscrol.o:	winscrol.c
	$(CC1) winscrol.c

winsertln.o:	winsertln.c
	$(CC1) winsertln.c

wintouch.o:	wintouch.c
	$(CC1) wintouch.c
