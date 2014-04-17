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

MENUTOOL  =	cpxstart.o estring.o 

#.s.o:
#	mac $*.s
#	dr2lc $@
#.s.o:
#	e:\lattice\bin\mas -us $*.s
#	dr2lc $@
.s.o:
	gentt -L7 $*.s

setenv.cpx:	$(MENUTOOL)
		lcc $(LDFLAGS)=$@ $(MENUTOOL)
		@gstfix $@
		cp setenv.cpx c:\xcontrol

cpxstart.o:
estring.o:	country.h estring.h estring.rsh cpxdata.h tools.h
