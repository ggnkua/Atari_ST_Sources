#
# Makefile for Fnordadel 1.3 under GCC
#

.SUFFIXES:
.SUFFIXES: .c .s .o .tos .olb .h

.c.o:
	@echo 'Compiling $@'
	@$(CC) $(CFLAGS) -c -o $@ $<

LIB = citlib/libfnord.olb
CFLAGS = -Icith -O -fomit-frame-pointer -fcombine-regs -DATARIST
LDFLAGS = $(LIB) -liio -s
HCORE = cith/sysdep.h cith/ctdl.h cith/citlib.h
HNET = cith/net.h

# This setup for native ST environment:
#CC = gcc
#AS = gcc-as
#AR = gcc-ar
#RM = xrm

# This setup for a cross-compiler environment:
CC = /usr/atari/bin/cgcc
AS = /usr/atari/lib/gcc-as
AR = /usr/atari/bin/car
RM = /bin/rm

# CITADEL defines the main citadel.tos target.

CITADEL = citmain/citadel.tos

# CONFIGUR defines the main configur.tos target.

CONFIGUR = citmain/configur.tos

# USEFUL_UTILS defines those utilities which are likely to be of use to the
# average system; they comprise a subset of the full suite of utilities.

USEFUL_UTILS =	citutil/callstat.tos \
		citutil/citfs.tos \
		citutil/ckdoor.tos \
		citutil/clog.tos \
		citutil/collide.tos \
		citutil/conv32.tos \
		citutil/conv33d.tos \
		citutil/doorwrap.tos \
		citutil/dumpnet.tos \
		citutil/flipbits.tos \
		citutil/lchange.tos \
		citutil/loadnet.tos \
		citutil/logedit.tos \
		citutil/makezt.tos \
		citutil/mchange.tos \
		citutil/mexpand.tos \
		citutil/mshrink.tos \
		citutil/nchange.tos \
		citutil/netmap.tos \
		citutil/popular.tos \
		citutil/rchange.tos \
		citutil/scanzt.tos \
		citutil/sysop.tos \
		citutil/vlog.tos

# OTHER_UTILS defines the remainder of the utilities.

OTHER_UTILS =	citalt/citpeek.tos \
		citalt/dumpmsg.tos \
		citalt/runit.tos \
		citalt/spooledt.tos \
		citalt/users.tos

# CONVERTERS defines the conversion program(s) which may be needed for this
# release.  This target will change a lot.

CONVERTERS =

ALL_SOURCES = citalt/citpeek.c citalt/dumpmsg.c citalt/doorwrap.c \
citalt/runit.c citalt/spooledt.c citutil/sysop.c citalt/users.c \
citlib/cd.c citlib/checkpt.c citlib/clock.c citlib/congetyn.c citlib/conout.c \
citlib/crashout.c citlib/crypte.c citlib/ctdlfile.c citlib/dskspace.c \
citlib/findmsg.c citlib/formroom.c citlib/formtime.c citlib/fromdesk.c \
citlib/getcd.c citlib/getdiren.c citlib/getlog.c citlib/getnet.c \
citlib/getnmidx.c citlib/getroom.c citlib/getspool.c citlib/getyesno.c \
citlib/hangup.c citlib/hash.c citlib/io.c citlib/labelcmp.c citlib/libarch.c \
citlib/libevent.c citlib/libfloor.c citlib/libroute.c citlib/libtag.c \
citlib/locking.c citlib/makedate.c citlib/modputs.c citlib/msgio.c \
citlib/msgio2.c citlib/msgtime.c citlib/netnmidx.c citlib/nnisok.c \
citlib/normalis.c citlib/noteroom.c citlib/output.c citlib/printmsg.c \
citlib/putlog.c citlib/putnet.c citlib/putroom.c citlib/readtabl.c \
citlib/receive.c citlib/rmalias.c citlib/stricmp.c citlib/strnicmp.c \
citlib/strupr.c citlib/timeis.c citlib/timers.c citlib/version.c \
citlib/writetbl.c citlib/xfuncs.c \
citmain/archive.c citmain/calllog.c \
citmain/cfg.c citmain/ctdl.c citmain/doenter.c citmain/door.c \
citmain/doread.c \
citmain/dosysop.c citmain/driver.c citmain/editor.c citmain/floor.c \
citmain/format.c citmain/holdmsg.c citmain/hothelp.c citmain/login.c \
citmain/misc.c citmain/modem.c citmain/msg.c citmain/netcall.c \
citmain/neterror.c citmain/netmain.c citmain/netmisc.c citmain/netrcv.c \
citmain/nfs.c citmain/patchnum.c citmain/postmsg.c \
citmain/room.c citmain/roomedit.c citmain/scandir.c citmain/statbar.c \
citmain/sysdep.c citmain/terminat.c citmain/xymodem.c citmain/zaploop.c \
citutil/callstat.c citutil/citfs.c citutil/ckdoor.c citutil/clog.c \
citutil/collide.c citutil/conv32.c citutil/conv33d.c citutil/dumpnet.c \
citutil/flipbits.c citutil/lchange.c citutil/loadnet.c citutil/logedit.c \
citutil/makezt.c citutil/mchange.c citutil/mexpand.c citutil/mshrink.c \
citutil/nchange.c citutil/netmap.c citutil/popular.c citutil/rchange.c \
citutil/readtbl.c citutil/scanzt.c citutil/vlog.c

#
# Following are the various targets.  Type 'make' to make citadel & configur.
#

minimum: $(CITADEL) $(CONFIGUR)

citadel: $(CITADEL)

configur: $(CONFIGUR)

fnord: $(CITADEL) $(CONFIGUR) $(USEFUL_UTILS)

remake: $(CITADEL) $(CONFIGUR) $(USEFUL_UTILS) $(OTHER_UTILS) $(CONVERTERS)

utils: $(USEFUL_UTILS) $(OTHER_UTILS)

conv: $(CONVERTERS)

#
# Library
#
# The order of the files in the library matters (if you care about speed)
# so don't farg with these too much.  From `getspool...msgtime...<etc>'
# onwards are all bottom-level, and can be in any order.
# 
LIBFNORDOBJ = citlib/rmalias.o citlib/msgio2.o citlib/findmsg.o \
citlib/printmsg.o citlib/msgio.o citlib/output.o citlib/getyesno.o \
citlib/formtime.o citlib/netnmidx.o citlib/putnet.o citlib/getnet.o \
citlib/putlog.o citlib/getnmidx.o citlib/getlog.o \
citlib/putroom.o citlib/getroom.o citlib/noteroom.o \
citlib/writetbl.o citlib/readtabl.o citlib/xfuncs.o citlib/locking.o \
citlib/formroom.o citlib/ctdlfile.o citlib/crashout.o \
citlib/hangup.o citlib/timers.o citlib/modputs.o citlib/receive.o \
citlib/getspool.o citlib/msgtime.o citlib/makedate.o citlib/conout.o \
citlib/crypte.o citlib/hash.o citlib/stricmp.o \
citlib/checkpt.o citlib/strnicmp.o  citlib/strupr.o \
citlib/normalis.o citlib/labelcmp.o citlib/nnisok.o citlib/cd.o citlib/getcd.o \
citlib/dskspace.o citlib/getdiren.o citlib/clock.o citlib/timeis.o \
citlib/congetyn.o citlib/fromdesk.o citlib/io.o citlib/version.o

$(LIB) : $(LIBFNORDOBJ)
	@$(RM) -f $(LIB)
	@$(AR) rus $(LIB) $(LIBFNORDOBJ)
#
# Main programs (citadel & configure)
#

CITOBJ = citmain/ctdl.o citmain/doread.o citmain/calllog.o citmain/login.o \
citmain/terminat.o citmain/misc.o citmain/xymodem.o citmain/modem.o \
citmain/msg.o citmain/room.o citmain/roomedit.o citmain/editor.o \
citmain/floor.o citlib/libfloor.o citlib/libarch.o citlib/libtag.o \
citlib/libevent.o citmain/postmsg.o citmain/netcall.o citmain/netmain.o \
citmain/netmisc.o citmain/netrcv.o \
citmain/door.o citmain/sysdep.o citmain/driver.o citmain/format.o \
citmain/zaploop.o citmain/archive.o citmain/doenter.o citmain/dosysop.o \
citlib/libroute.o citmain/nfs.o citmain/holdmsg.o \
citmain/scandir.o citmain/statbar.o citmain/hothelp.o citmain/neterror.o \
citmain/patchnum.o

citmain/citadel.tos : $(CITOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(CITOBJ) $(LDFLAGS)

CFGOBJ = citmain/cfg.o citlib/libfloor.o

citmain/configur.tos : $(CFGOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(CFGOBJ) $(LDFLAGS)

#
# Utilities
#

CSTATOBJ = citutil/callstat.o citutil/readtbl.o 

citutil/callstat.tos : $(CSTATOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -f -o $@ $(CSTATOBJ) $(LDFLAGS)

CITFSOBJ = citutil/citfs.o

citutil/citfs.tos : $(CITFSOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(CITFSOBJ) $(LDFLAGS)

CITPEEKOBJ = citalt/citpeek.o citlib/libfloor.o citmain/patchnum.o \
citmain/format.o citlib/libroute.o

citalt/citpeek.tos : $(CITPEEKOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(CITPEEKOBJ) $(LDFLAGS)

CKDOOROBJ = citutil/ckdoor.o 

citutil/ckdoor.tos : $(CKDOOROBJ)
	@echo 'Linking $@'
	@$(CC) -o $@ $(CKDOOROBJ) $(LDFLAGS)

CLOGOBJ = citutil/clog.o

citutil/clog.tos : $(CLOGOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(CLOGOBJ) $(LDFLAGS)

COLLOBJ = citutil/collide.o citutil/readtbl.o

citutil/collide.tos : $(COLLOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(COLLOBJ) $(LDFLAGS)

CONV32OBJ = citutil/conv32.o

citutil/conv32.tos : $(CONV32OBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(CONV32OBJ) $(LDFLAGS)

CONV33DOBJ = citutil/conv33d.o

citutil/conv33d.tos : $(CONV33DOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(CONV33DOBJ) $(LDFLAGS)

DOORWRAPOBJ = citutil/doorwrap.o

citutil/doorwrap.tos : $(DOORWRAPOBJ)
	@echo 'Linking $@'
	@$(CC) -o $@ $(DOORWRAPOBJ) $(LDFLAGS)

DUMPNETOBJ = citutil/dumpnet.o citutil/readtbl.o

citutil/dumpnet.tos : $(DUMPNETOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(DUMPNETOBJ) $(LDFLAGS)

FLIPBITSOBJ = citutil/flipbits.o citutil/readtbl.o

citutil/flipbits.tos : $(FLIPBITSOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(FLIPBITSOBJ) $(LDFLAGS)

LCHGOBJ = citutil/lchange.o

citutil/lchange.tos : $(LCHGOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(LCHGOBJ) $(LDFLAGS)

LOADNETOBJ = citutil/loadnet.o

citutil/loadnet.tos : $(LOADNETOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(LOADNETOBJ) $(LDFLAGS)

LOGEDOBJ = citutil/logedit.o

citutil/logedit.tos : $(LOGEDOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(LOGEDOBJ) $(LDFLAGS)

MZTOBJ = citutil/makezt.o citlib/libroute.o
# libroute is here because of stupid parsepath() calls somewhere in libfnord.

citutil/makezt.tos : $(MZTOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(MZTOBJ) $(LDFLAGS)

MCHGOBJ = citutil/mchange.o

citutil/mchange.tos : $(MCHGOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(MCHGOBJ) $(LDFLAGS)

MEXPANDOBJ = citutil/mexpand.o

citutil/mexpand.tos : $(MEXPANDOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(MEXPANDOBJ) $(LDFLAGS)

MSHROBJ = citutil/mshrink.o citlib/libroute.o
# libroute is here because of stupid parsepath() calls somewhere in libfnord.

citutil/mshrink.tos : $(MSHROBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(MSHROBJ) $(LDFLAGS)

NCHGOBJ = citutil/nchange.o

citutil/nchange.tos : $(NCHGOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(NCHGOBJ) $(LDFLAGS)

NETMAPOBJ = citutil/netmap.o citutil/readtbl.o

citutil/netmap.tos : $(NETMAPOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(NETMAPOBJ) $(LDFLAGS)

POPULOBJ = citutil/popular.o citutil/readtbl.o citlib/libroute.o
# libroute is here because of stupid parsepath() calls somewhere in libfnord.

citutil/popular.tos : $(POPULOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(POPULOBJ) $(LDFLAGS)

RCHGOBJ = citutil/rchange.o

citutil/rchange.tos : $(RCHGOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(RCHGOBJ) $(LDFLAGS)

RUNITOBJ = citalt/runit.o

citalt/runit.tos : $(RUNITOBJ)
	@echo 'Linking $@'
	@$(CC) -o $@ $(RUNITOBJ) $(LDFLAGS)

SZTOBJ = citutil/scanzt.o

citutil/scanzt.tos : $(SZTOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(SZTOBJ) $(LDFLAGS)

SPOOLOBJ = citalt/spooledt.o citutil/readtbl.o

citalt/spooledt.tos : $(SPOOLOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(SPOOLOBJ) $(LDFLAGS)

citutil/sysop.tos : citutil/sysop.o
	@echo 'Linking $@'
	@$(CC) -o $@ citutil/sysop.o $(LDFLAGS)
	
USERSOBJ = citalt/users.o

citalt/users.tos : $(USERSOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -f -o $@ $(USERSOBJ) $(LDFLAGS)

VLOGOBJ = citutil/vlog.o citutil/readtbl.o

citutil/vlog.tos : $(VLOGOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(VLOGOBJ) $(LDFLAGS)

#
# Miscellaneous junk
#

DUMPMSGOBJ = citalt/dumpmsg.o

citalt/dumpmsg.tos : $(DUMPMSGOBJ) $(LIB)
	@echo 'Linking $@'
	@$(CC) -o $@ $(DUMPMSGOBJ) $(LDFLAGS)

#
# Dependencies
#
# \citmain dependencies redone by AA 90Aug29
#
citmain/archive.o : citmain/archive.c $(HCORE) cith/protocol.h cith/citadel.h
citmain/calllog.o : citmain/calllog.c $(HCORE) cith/calllog.h cith/citadel.h
citmain/cfg.o : citmain/cfg.c $(HCORE) $(HNET) cith/event.h cith/archiver.h cith/calllog.h cith/zaploop.h cith/configur.h
citmain/ctdl.o : citmain/ctdl.c $(HCORE) cith/event.h cith/calllog.h cith/protocol.h cith/door.h cith/terminat.h cith/citadel.h
citmain/doenter.o : citmain/doenter.c $(HCORE) cith/protocol.h cith/citadel.h
citmain/door.o : citmain/door.c $(HCORE) cith/door.h cith/archiver.h cith/citadel.h
citmain/doread.o : citmain/doread.c $(HCORE) cith/dirlist.h cith/archiver.h cith/browser.h cith/protocol.h  cith/citadel.h cith/dateread.h
citmain/dosysop.o : citmain/dosysop.c $(HCORE) cith/event.h cith/calllog.h cith/protocol.h cith/door.h cith/terminat.h cith/citadel.h
citmain/driver.o : citmain/driver.c $(HCORE) cith/citadel.h
citmain/editor.o : citmain/editor.c $(HCORE) cith/editor.h cith/citadel.h
citmain/floor.o : citmain/floor.c $(HCORE) cith/protocol.h cith/citadel.h
citmain/format.o : citmain/format.c $(HCORE) cith/citadel.h
citmain/holdmsg.o : citmain/holdmsg.c $(HCORE) cith/citadel.h
citmain/hothelp.o : citmain/hothelp.c $(HCORE) cith/citadel.h
citmain/login.o : citmain/login.c $(HCORE) cith/room.h cith/event.h cith/calllog.h cith/terminat.h cith/citadel.h
citmain/misc.o : citmain/misc.c $(HCORE) cith/dirlist.h cith/browser.h cith/calllog.h cith/event.h cith/protocol.h cith/dateread.h cith/citadel.h
citmain/modem.o : citmain/modem.c $(HCORE) cith/event.h cith/calllog.h cith/protocol.h cith/terminat.h cith/citadel.h
citmain/msg.o : citmain/msg.c $(HCORE) $(HNET) cith/editor.h cith/protocol.h cith/dateread.h cith/citadel.h
citmain/netcall.o : citmain/netcall.c $(HCORE) $(HNET) cith/dirlist.h cith/protocol.h cith/citadel.h
citmain/neterror.o : citmain/neterror.c $(HCORE) cith/citadel.h
citmain/netmain.o : citmain/netmain.c $(HCORE) $(HNET) cith/event.h cith/protocol.h cith/terminat.h cith/citadel.h
citmain/netmisc.o : citmain/netmisc.c $(HCORE) $(HNET) cith/event.h cith/dirlist.h cith/citadel.h cith/terminat.h
citmain/netrcv.o : citmain/netrcv.c $(HCORE) $(HNET) cith/dirlist.h cith/protocol.h cith/citadel.h
citmain/nfs.o : citmain/nfs.c $(HCORE) $(HNET) cith/dirlist.h cith/citadel.h
citmain/patchnum.o : citmain/patchnum.c
citmain/postmsg.o : citmain/postmsg.c $(HCORE) $(HNET) cith/protocol.h cith/citadel.h
citmain/room.o : citmain/room.c $(HCORE) cith/citadel.h cith/editor.h cith/room.h
citmain/rooma.o : citmain/rooma.c $(HCORE) $(HNET) cith/dirlist.h cith/protocol.h cith/citadel.h
citmain/roomb.o : citmain/roomb.c $(HCORE) $(HNET) cith/protocol.h cith/citadel.h
citmain/roomedit.o : citmain/roomedit.c $(HCORE) $(HNET) cith/editor.h cith/citadel.h
citmain/scandir.o : citmain/scandir.c $(HCORE) cith/dirlist.h cith/dateread.h cith/citadel.h
citmain/statbar.o : citmain/statbar.c $(HCORE) cith/citadel.h
citmain/sysdep.o : citmain/sysdep.c $(HCORE) $(HNET) cith/calllog.h cith/citadel.h
citmain/terminat.o : citmain/terminat.c $(HCORE) cith/calllog.h cith/terminat.h cith/citadel.h
citmain/xymodem.o : citmain/xymodem.c $(HCORE) cith/dirlist.h cith/calllog.h cith/protocol.h cith/citadel.h
citmain/zaploop.o : citmain/zaploop.c $(HCORE) cith/zaploop.h cith/citadel.h
#
# library dependencies compiled by AA 90Aug28
#
citlib/cd.o: citlib/cd.c
citlib/checkpt.o: citlib/checkpt.c $(HCORE) cith/config.h
citlib/clock.o: citlib/clock.c $(HCORE)
citlib/congetyn.o: citlib/congetyn.c $(HCORE)
citlib/conout.o: citlib/conout.c $(HCORE)
citlib/crashout.o: citlib/crashout.c $(HCORE)
citlib/crypte.o: citlib/crypte.c $(HCORE)
citlib/ctdlfile.o: citlib/ctdlfile.c $(HCORE)
citlib/dskspace.o: citlib/dskspace.c $(HCORE)
citlib/findmsg.o: citlib/findmsg.c $(HCORE)
citlib/formroom.o: citlib/formroom.c $(HCORE)
citlib/formtime.o: citlib/formtime.c
citlib/fromdesk.o: citlib/fromdesk.c
citlib/getcd.o: citlib/getcd.c $(HCORE)
citlib/getdiren.o: citlib/getdiren.c cith/dirlist.h
citlib/getlog.o: citlib/getlog.c $(HCORE)
citlib/getnet.o: citlib/getnet.c $(HCORE) $(HNET)
citlib/getnmidx.o: citlib/getnmidx.c $(HCORE)
citlib/getroom.o: citlib/getroom.c $(HCORE)
citlib/getspool.o: citlib/getspool.c $(HCORE)
citlib/getyesno.o: citlib/getyesno.c $(HCORE)
citlib/hangup.o: citlib/hangup.c $(HCORE)
citlib/hash.o: citlib/hash.c
citlib/io.o : citlib/io.c
citlib/labelcmp.o: citlib/labelcmp.c
citlib/libarch.o: citlib/libarch.c $(HCORE)
citlib/libevent.o: citlib/libevent.c $(HCORE) cith/event.h
citlib/libfloor.o: citlib/libfloor.c $(HCORE)
citlib/libroute.o: citlib/libroute.c $(HCORE) $(HNET)
citlib/libtag.o: citlib/libtag.c $(HCORE)
citlib/locking.o: citlib/locking.c $(HCORE)
citlib/makedate.o: citlib/makedate.c $(HCORE)
citlib/modputs.o: citlib/modputs.c
citlib/msgio.o: citlib/msgio.c $(HCORE)
citlib/msgio2.o: citlib/msgio2.c $(HCORE)
citlib/msgtime.o: citlib/msgtime.c $(HCORE)
citlib/netnmidx.o: citlib/netnmidx.c $(HCORE) $(HNET)
citlib/normalis.o: citlib/normalis.c
citlib/noteroom.o: citlib/noteroom.c $(HCORE)
citlib/nnisok.o: citlib/nnisok.c
citlib/output.o: citlib/output.c $(HCORE) cith/protocol.h
citlib/printmsg.o: citlib/printmsg.c $(HCORE)
citlib/prntword.o: citlib/prntword.c $(HCORE)
citlib/putlog.o: citlib/putlog.c $(HCORE)
citlib/putnet.o: citlib/putnet.c $(HCORE) $(HNET)
citlib/putroom.o: citlib/putroom.c $(HCORE)
citlib/readtabl.o: citlib/readtabl.c $(HCORE) $(HNET) cith/archiver.h cith/event.h cith/zaploop.h
citlib/receive.o: citlib/receive.c $(HCORE)
citlib/rmalias.o: citlib/rmalias.c $(HCORE)
citlib/stricmp.o: citlib/stricmp.c
citlib/strnicmp.o: citlib/strnicmp.c
citlib/strupr.o: citlib/strupr.c
citlib/timeis.o: citlib/timeis.c
citlib/timers.o: citlib/timers.c $(HCORE)
citlib/version.o: citlib/version.c
citlib/writetbl.o: citlib/writetbl.c $(HCORE) $(HNET) cith/archiver.h cith/event.h cith/zaploop.h
citlib/xfuncs.o: citlib/xfuncs.c cith/sysdep.h
#
# \citutil dependencies redone by AA 90Aug29
#
citutil/callstat.o : citutil/callstat.c $(HCORE) cith/calllog.h cith/terminat.h
citutil/citfs.o : citutil/citfs.c $(HCORE) $(HNET)
citutil/ckdoor.o : citutil/ckdoor.c cith/door.h
citutil/clog.o : citutil/clog.c $(HCORE)
citutil/collide.o : citutil/collide.c $(HCORE)
citutil/conv32.o : citutil/conv32.c $(HCORE) $(HNET)
citutil/conv33d.o : citutil/conv33d.c $(HCORE) $(HNET)
citutil/dumpnet.o : citutil/dumpnet.c $(HCORE) $(HNET) cith/event.h
citutil/flipbits.o : citutil/flipbits.c $(HCORE)
citutil/lchange.o : citutil/lchange.c $(HCORE)
citutil/loadnet.o : citutil/loadnet.c $(HCORE) $(HNET) cith/event.h
citutil/logedit.o : citutil/logedit.c $(HCORE)
citutil/makezt.o : citutil/makezt.c $(HCORE) $(HNET) cith/zaploop.h
citutil/mchange.o : citutil/mchange.c $(HCORE)
citutil/mexpand.o : citutil/mexpand.c $(HCORE)
citutil/mshrink.o : citutil/mshrink.c $(HCORE)
citutil/nchange.o : citutil/nchange.c $(HCORE) $(HNET)
citutil/netmap.o : citutil/netmap.c $(HCORE) $(HNET)
citutil/popular.o : citutil/popular.c $(HCORE) $(HNET)
citutil/rchange.o : citutil/rchange.c $(HCORE)
citutil/readtbl.o : citutil/readtbl.c $(HCORE) $(HNET)
citutil/scanzt.o : citutil/scanzt.c $(HCORE) cith/zaploop.h
citutil/sysop.o : citutil/sysop.c
citutil/vlog.o : citutil/vlog.c $(HCORE)
#
# \citalt dependencies redone by AA 90Aug29
#
citalt/citpeek.o : citalt/citpeek.c $(HCORE) $(HNET)
citalt/dumpmsg.o : citalt/dumpmsg.c $(HCORE) cith/sysdep.h
citalt/runit.o : citalt/runit.c
citalt/spooledt.o : citalt/spooledt.c $(HCORE)
citalt/users.o : citalt/users.c $(HCORE)

depend: $(ALL_SOURCES)
	$(CC) $(CFLAGS) -MM $(ALL_SOURCES) > depend
