
base = ../..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

LIBRARY	= $(LIBC)

PPFLAGS	= $(XCPPFLAGS) -D__GNUC__ -D__DEF_ALL__

#OBJ1 =	atof.o xcvt.o
OBJ1 =	_muldf3.o _mulsf3.o _divdf3.o _divsf3.o _cmpdf2.o _cmpsf2.o \
	_truncdf.o _extends.o _isinf.o \
	_addsubd.o _addsubs.o _negdf2.o _negsf2.o modf.o ldexp.o frexp.o \
	_fixdfsi.o _fixsfsi.o _fxunsd.o _fltsi.o _fltsisf.o _normsf.o _normdf.o \
	_divmods.o _mulsi3.o _isnan.o _udivmod.o _umulsi3.o
#OBJ4 =  sozolong.o sozulong.o
#OBJ5 =  doprnt.o scanf.o fprintf.o fscanf.o sprintf.o sscanf.o

OBJECTS = $(OBJ1)

all : $(LIBRARY)

$(LIBRARY): $(OBJECTS)
	$(AR) $(ARFLAGS) $@ $(OBJECTS)
	$(RM) $(OBJECTS)

clean :
	$(RM) $(OBJECTS)

#
# Assembler stuff that needs to be preprocessed
#
.SUFFIXES: .cpp

.cpp.o:
	$(CPP) $(PPFLAGS) $< -o $*.s
	$(AS) $*.s -o $*.o
	$(RM) $*.s

_addsubd.o:	_addsubd.cpp
_addsubs.o:	_addsubs.cpp
_muldf3.o:	_muldf3.cpp
_mulsf3.o:	_mulsf3.cpp
_divdf3.o:	_divdf3.cpp
_divsf3.o:	_divsf3.cpp
_cmpdf2.o:	_cmpdf2.cpp
_cmpsf2.o:	_cmpsf2.cpp
_negdf2.o:	_negdf2.cpp
_negsf2.o:	_negsf2.cpp
_fixdfsi.o:	_fixdfsi.cpp
_fixsfsi.o:	_fixsfsi.cpp
_truncdf.o:	_truncdf.cpp
_extends.o:	_extends.cpp
_fxunsd.o:	_fxunsd.cpp
_fltsi.o:	_fltsi.cpp
_fltsisf.o:	_fltsisf.cpp
modf.o:		modf.cpp
ldexp.o:	ldexp.cpp
frexp.o:	frexp.cpp
_normdf.o:	_normdf.cpp
_normsf.o:	_normsf.cpp
_divmods.o:	_divmods.cpp
_mulsi3.o:	_mulsi3.cpp
_isinf.o:	_isinf.cpp
_isnan.o:	_isnan.cpp
_udivmod.o:	_udivmod.cpp
_umulsi3.o:	_umulsi3.cpp
