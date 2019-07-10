# Makefile for man pages

NROFF = nroff
NRFLAGS = -man
FILTER = manfilt
RM = /bin/rm -f

.SUFFIXES: .1 .man

.1.man:
	@echo 'Formatting $@ from $<'
	@$(NROFF) $(NRFLAGS) $< | $(FILTER) > $@

MANSRC = callstat.1 citadel.1 citfs.1 ckdoor.1 clog.1 collide.1 configur.1 \
doorwrap.1 dumpnet.1 flipbits.1 lchange.1 loadnet.1 logedit.1 makezt.1 \
mchange.1 mexpand.1 mshrink.1 nchange.1 netmap.1 popular.1 rchange.1 scanzt.1 \
sysop.1 vlog.1

MANFMT = callstat.man citadel.man citfs.man ckdoor.man clog.man collide.man \
configur.man doorwrap.man dumpnet.man flipbits.man lchange.man loadnet.man \
logedit.man makezt.man mchange.man mexpand.man mshrink.man nchange.man \
netmap.man popular.man rchange.man scanzt.man sysop.man vlog.man

all: manpages

manpages: $(MANFMT)

clean:
	$(RM) $(MANFMT)

callstat.man: callstat.1 
citadel.man: citadel.1 
citfs.man: citfs.1 
ckdoor.man: ckdoor.1 
clog.man: clog.1 
collide.man: collide.1 
configur.man: configur.1 
doorwrap.man: doorwrap.1
dumpnet.man: dumpnet.1 
flipbits.man: flipbits.1 
lchange.man: lchange.1 
loadnet.man: loadnet.1 
logedit.man: logedit.1 
makezt.man: makezt.1 
mchange.man: mchange.1 
mexpand.man: mexpand.1 
mshrink.man: mshrink.1 
nchange.man: nchange.1 
netmap.man: netmap.1 
popular.man: popular.1 
rchange.man: rchange.1 
scanzt.man: scanzt.1 
sysop.man: sysop.1 
vlog.man: vlog.1 
