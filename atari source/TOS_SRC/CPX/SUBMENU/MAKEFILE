### 	Makefile

COPTS	=       -d0 -cf -v 
CMODEL	=	-w -r0 -b0
CREFS	=	
DEFINES =	
LMODEL	=	snb
LDOPTS  =       -N -tx -Lmnbg+$(ALTLIB) #-Lnbg   
ALTLIB  =	aesa$(LMODEL).lib
#
CFLAGS	=	$(COPTS) $(CMODEL) $(CREFS) $(DEFINES)
ASFLAGS =
LDFLAGS =	$(COPTS) $(CMODEL) $(LDOPTS)
MAPOPTS =	#MAP $*.map

MENUTOOL  =	cpxstart.o submenu.o crysif.o crystal.o menubind.o

#.s.o:
#	mac $*.s
#	dr2lc $@
#.s.o:
#	e:\lattice\bin\mas -us $*.s
#	dr2lc $@
.s.o:
	gentt -L7 $*.s

submenu.cpx:	$(MENUTOOL)
		lcc $(LDFLAGS)=$@ $(MENUTOOL)
		@gstfix $@
		cp submenu.cpx c:\xcontrol

cpxstart.o:
submenu.o:	country.h submenu.h submenu.rsh cpxdata.h menubind.h
