### 	Makefile

COPTS	=       -d0 -cf -v 
CMODEL	=	-w -r0 -b0
CREFS	=	
DEFINES =	
LMODEL	=	snb
LDOPTS  =       -N -tx -Lnbg+$(ALTLIB) #-Lnbg   
ALTLIB  =	aesa$(LMODEL).lib
#
CFLAGS	=	$(COPTS) $(CMODEL) $(CREFS) $(DEFINES)
ASFLAGS =
LDFLAGS =	$(COPTS) $(CMODEL) $(LDOPTS)
MAPOPTS =	#MAP $*.map

MENUTOOL  =	cpxstart.o system.o fixrsh.o

#.s.o:
#	mac $*.s
#	dr2lc $@
#.s.o:
#	e:\lattice\bin\mas -us $*.s
#	dr2lc $@
.s.o:
	gentt -L7 $*.s

system.cpx:	$(MENUTOOL)
		lcc $(LDFLAGS)=$@ $(MENUTOOL)
		@gstfix $@
		cp system.cpx c:\xcontrol

cpxstart.o:
system.o:	country.h system.h system.rsh cpxdata.h
fixrsh.o:
