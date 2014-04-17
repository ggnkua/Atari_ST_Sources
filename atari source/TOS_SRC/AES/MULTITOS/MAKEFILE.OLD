# The official makefile for GEM compiled with Alcyon and Lattice
# makefile for Lattice C 5.5
#


#
# Compiler options
#

DEFINES	= #-pr # makes prototypes, leave off for now

# Flags for lc.ttp
#
# -w	16-bit ints
# -b0	full 32-bit addressing
# -bn	unknown
# -r0	subroutine calls will use absolute 32-bit relocated address
# -d 	Just enables debug info from line number/offset table
# -v	disable stack checking
# -rs	standard stack params
# -z2	generate DRI format objects
# -cf	force prototype checking
# NOTE: 3 files do not like the optimizer: deskdisk.c gemfslib.c deskfile.c

CMODEL	= -w -b0 -bn -r0 -v -rs -m3 -z2 -cf #-O
CFLAGS	= $(DEFINES) $(CMODEL)  

##LCC_OPT=-C -cefishtu -q- -v -.

# Flags for just linking, see target
#
# -N	don't compile, just link
# -Labg	a	cause extended debug info in executable
#	b	batch option of the linker
#	g	search the AES and VDI library first
LDFLAGS	= -N $(CMODEL) -d -Labg 

# Assembly flags
#
ASFLAGS = $(DEFINES) -ic:\lc5\i

.c.o:
	lc -c $(CFLAGS) -o$@ $<


.s.o:
	mas -us $*.s

## Files that depend on the country switches are all dependent
## on the makefile, so you don't need to go deleting a bunch
## of objects every time you make a new country.

#### Country definitions

COUNTRY = usa

## NOTE: When making UK AES, set COUNTRY to usa and CDEF to UK.
##       This will build a ttaesusa.o which must then be manually
##	 renamed to ttaesuk.o.
##	The same goes for SWISSGER and SWISSFRA -- use grm and fre,
##	and manually rename the ttaesxxx.o file that gets built.


#
# Headers
#

STDESK.H =	portab.h deskdefi.h deskwin.h desk$(COUNTRY).h
STGEM.H =	machine.h gemusa.h
GEMPD.H =	pdstruct.h dispvars.h
GEMOLIB.H =	obdefs.h gemlib.h

RSC1 =		glue.usa
RSC2 =		glue.grm 
RSC3 =		glue.fre
RSC4 =		glue.ita 
#RSC5 =		glue.swe
RSC6 = 		glue.spa


#
# Objects
#

AB = 		gemctrl.o ctrlbind.o mn_event.o mn_mbar.o mn_popup.o\
		mn_tools.o mn_index.o mn_menu.o mn_submn.o

STARTUP =	gemstart.o

AESOBJ =	gemaints.o gemaplib.o gembase.o gemcli.o\
		gemdisp.o gemevlib.o gemflag.o gemfmalt.o gemfmlib.o\
		gemfslib.o gemsigna.o \
		gemobjop.o gemqueue.o gemrlist.o gemrom.o\
		gemsclib.o gemshlib.o gemtcpip.o gemwmlib.o romcart.o\
		apgrlib.o apgsxif.o gembind.o gemgrlib.o gemgsxif.o\
		dosbind.o utility.o \
		gemmnlib.o gemasync.o \
		gemrslib.o geminit.o \
		gemobed.o gemoblib.o gempd.o \
		gsx2.o aestrap.o aesdispa.o large.o\
		interrup.o traps.o

DESKOBJ = 	deskact.o deskapp.o deskvdi.o deskbutt.o \
		deskdir.o deskdisk.o deskfile.o deskinf.o deskins.o \
		deskmenu.o deskmisc.o deskmn.o deskopen.o \
		deskpref.o desksele.o deskshel.o deskshow.o deskvari.o\
		deskupda.o desksear.o kballoc.o \
 		deskstar.o deskmem.o \
		deskwin.o desktop.o \
		aesbin73

LCFILES = deskact.o gemrom.o gemrslib.o gemsclib.o gemwmlib.o gemsclib.o \
gemshlib.o gemsigna.o gemtcpip.o mn_event.o mn_index.o mn_mbar.o mn_menu.o \
mn_popup.o mn_submn.o mn_tools.o deskshow.o desktop.o deskupda.o deskvari.o \
deskvdi.o deskwin.o gemmnlib.o gemobed.o gemobjop.o gemoblib.o gempd.o \
gemqueue.o utility.o romcart.o geminit.o gemgrlib.o gemgsxif.o gemaplib.o \
gemasync.o deskpref.o desksear.o desksele.o deskshel.o apgrlib.o apgsxif.o \
gembase.o gembind.o deskmn.o dosbind.o gemaints.o gemcli.o gemctrl.o \
gemdisp.o gemevlib.o gemflag.o gemfmalt.o gemfmlib.o gemfslib.o \
deskapp.o deskbutt.o deskdir.o deskinf.o deskins.o deskmem.o ctrlbind.o \
deskmenu.o deskmisc.o gemrlist.o kballoc.o deskdisk.o deskopen.o deskfile.o
ACFILES = 

DESK = $(LCFILES)

#
# Default target
#

#temp.prg: $(DESK)
#	lc $(LDFLAGS)=$@ $(DESK)
#	@gstfix $@

## -l generates too many symbols, so we use -s instead
##		aln -w -l -k gemstart -q -o $@

gem.sys:	$(STARTUP) $(AB) $(DESKOBJ) $(AESOBJ) $(RSC1) $(RSC2) $(RSC3)\
		$(RSC4) $(RSC6)
		.\aln -u -u -q -k _iscrmgr -k _mn_hdo -k _mn_popup\
		-k _mn_attach -k _mn_istart -k _mn_settings\
		-k _mn_free -k _mn_new -k _mn_init -k _ArrowScroll\
		-k _PushArrowTe -o ab.o $(AB)

		.\aln -u -s -o gem.sys $(STARTUP) ab.o $(AESOBJ) $(DESKOBJ)\
		-i $(RSC1) _USARSC -i $(RSC2) _GRMRSC -i $(RSC3) _FRERSC\
		-i $(RSC4) _ITARSC -i $(RSC6) _SPARSC

		prgflags 7 7 gem.sys
#		copy gem.sys c:\gem.sys				
		@echo 'gem.sys made.'

#
# Dependencies
#
gemrom.o:   $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h aesmint.h
gemrslib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h
gemwmlib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h
gemsclib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H)
gemshlib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h gemdos.h aesmint.h signal.h
gemsigna.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h
gemtcpip.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h
gemmnlib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h aesmint.h signal.h
gemobed.o:  $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h
gemobjop.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h vdidefs.h
gemoblib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h 
gempd.o:    $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h
gemqueue.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h
geminit.o:  $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h aesmint.h signal.h gemusa.h 	
gemgrlib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h
gemgsxif.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) vdidefs.h aesmint.h
gemaplib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) dispvars.h aesmint.h signal.h
gemasync.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h
gembase.o:  $(STGEM.H) $(GEMPD.H)
gembind.o:  $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h crysbind.h aesmint.h		
gemaints.o: $(STGEM.H) $(GEMPD.H)
gemcli.o:   $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h   
gemctrl.o:  $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h aesmint.h
gemdisp.o:   $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h signal.h
gemevlib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h   
gemflag.o:  $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h   
gemfmalt.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h aesmint.h
gemfmlib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h objaddr.h
gemfslib.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) gemdos.h objaddr.h
gemrlist.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) aesmint.h

mn_event.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h osbind.h mn_tools.h
mn_index.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h osbind.h mn_tools.h
mn_mbar.o:  $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h osbind.h mn_tools.h
mn_menu.o:  $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h osbind.h mn_tools.h
mn_popup.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h osbind.h mn_tools.h
mn_submn.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h osbind.h mn_tools.h
mn_tools.o: $(STGEM.H) $(GEMPD.H) $(GEMOLIB.H) objaddr.h osbind.h mn_tools.h

deskact.o:	$(STDESK.H) 
deskshow.o:	$(STDESK.H)
desktop.o:	$(STDESK.H) osbind.h extern.h mintbind.h signal.h 
deskmn.o:	$(STDESK.H) vdomode.h 
deskupda.o:	$(STDESK.H) 
deskvari.o:	$(STDESK.H) osbind.h
deskvdi.o:	portab.h vdidefs.h
deskwin.o:	$(STDESK.H) osbind.h 
deskpref.o:	$(STDESK.H) osbind.h
desksear.o:	$(STDESK.H) 
desksele.o: 	$(STDESK.H)
deskshel.o:	$(STDESK.H)
deskapp.o:	$(STDESK.H)
deskbutt.o:	$(STDESK.H)
deskdir.o:	$(STDESK.H) error.h osbind.h 
deskinf.o:	$(STDESK.H)
deskins.o:	$(STDESK.H) osbind.h
deskmem.o:	$(STDESK.H) extern.h	 
deskmenu.o: 	$(STDESK.H) mintbind.h
deskmisc.o:	$(STDESK.H) 
deskdisk.o:	$(STDESK.H) 
deskopen.o:	$(STDESK.H)
deskfile.o: 	$(STDESK.H) osbind.h

apgrlib.o:  $(STGEM.H) obdefs.h vdidefs.h
apgsxif.o:  $(STGEM.H) obdefs.h vdidefs.h aesmint.h
dosbind.o:  gemdos.h
romcart.o:  $(STGEM.H) $(GEMPD.H) gemdos.h
utility.o:  $(STGEM.H) objaddr.h obdefs.h
ctrlbind.o: portab.h crysbind.h obdefs.h    
