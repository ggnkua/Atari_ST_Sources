CC	= exec cc
CFLAGS	= -D_MINIX -D_POSIX_SOURCE -DACK
CC1	= $(CC) $(CFLAGS) -c

LIBRARY	= ../../libe.a
all:	$(LIBRARY)

OBJSOLD =	\
	$(LIBRARY)(_ara.o) \
	$(LIBRARY)(_cmi.o) \
	$(LIBRARY)(_cmp.o) \
	$(LIBRARY)(_cms.o) \
	$(LIBRARY)(_cmu.o) \
	$(LIBRARY)(_csa.o) \
	$(LIBRARY)(_csb.o) \
	$(LIBRARY)(_cuu.o) \
	$(LIBRARY)(_cvf.o) \
	$(LIBRARY)(_dvi.o) \
	$(LIBRARY)(_dvu.o) \
	$(LIBRARY)(_exg.o) \
	$(LIBRARY)(_fat.o) \
	$(LIBRARY)(_ffp.o) \
	$(LIBRARY)(_gto.o) \
	$(LIBRARY)(_inn.o) \
	$(LIBRARY)(_los.o) \
	$(LIBRARY)(_lpb.o) \
	$(LIBRARY)(_lxa.o) \
	$(LIBRARY)(_lxl.o) \
	$(LIBRARY)(_mli.o) \
	$(LIBRARY)(_mlu.o) \
	$(LIBRARY)(_mon.o) \
	$(LIBRARY)(_rck.o) \
	$(LIBRARY)(_ret.o) \
	$(LIBRARY)(_set.o) \
	$(LIBRARY)(_shp.o) \
	$(LIBRARY)(_sig.o) \
	$(LIBRARY)(_sts.o) \
	$(LIBRARY)(_trp.o)

OBJSNEW = \
	$(LIBRARY)(stb.o) \
	$(LIBRARY)(ara.o) \
	$(LIBRARY)(cii.o) \
	$(LIBRARY)(cmi.o) \
	$(LIBRARY)(cmp.o) \
	$(LIBRARY)(cmu.o) \
	$(LIBRARY)(csa.o) \
	$(LIBRARY)(csa4.o) \
	$(LIBRARY)(csb.o) \
	$(LIBRARY)(csb4.o) \
	$(LIBRARY)(cuu.o) \
	$(LIBRARY)(exg.o) \
	$(LIBRARY)(inn.o) \
	$(LIBRARY)(los.o) \
	$(LIBRARY)(rck.o) \
	$(LIBRARY)(ret.o) \
	$(LIBRARY)(set.o) \
	$(LIBRARY)(sts.o) \
	$(LIBRARY)(nop.o) \
	$(LIBRARY)(mon.o) \
	$(LIBRARY)(dvi.o) \
	$(LIBRARY)(dvu.o) \
	$(LIBRARY)(mli.o) \
	$(LIBRARY)(mlu.o) \
	$(LIBRARY)(shp.o) \
	$(LIBRARY)(sig.o) \
	$(LIBRARY)(cms.o) \
	$(LIBRARY)(gto.o) \
	$(LIBRARY)(fp68881.o) \
	$(LIBRARY)(fat.o) \
	$(LIBRARY)(trp.o) \
	$(LIBRARY)(dia.o) \
	$(LIBRARY)(lxl.o) \
	$(LIBRARY)(lxa.o) \
	$(LIBRARY)(lpb.o)

$(LIBRARY):	$(OBJSNEW)
	aal cr $@ *.o
	rm -f *.o

$(LIBRARY)(_ara.o):	_ara.s
	$(CC1) _ara.s

$(LIBRARY)(_cmi.o):	_cmi.s
	$(CC1) _cmi.s

$(LIBRARY)(_cmp.o):	_cmp.s
	$(CC1) _cmp.s
	
$(LIBRARY)(_cms.o):	_cms.s
	$(CC1) _cms.s

$(LIBRARY)(_cmu.o):	_cmu.s
	$(CC1) _cmu.s

$(LIBRARY)(_csa.o):	_csa.s
	$(CC1) _csa.s

$(LIBRARY)(_csb.o):	_csb.s
	$(CC1) _csb.s

$(LIBRARY)(_cuu.o):	_cuu.s
	$(CC1) _cuu.s

$(LIBRARY)(_cvf.o):	_cvf.s
	$(CC1) _cvf.s

$(LIBRARY)(_dvi.o):	_dvi.s
	$(CC1) _dvi.s

$(LIBRARY)(_dvu.o):	_dvu.s
	$(CC1) _dvu.s

$(LIBRARY)(_exg.o):	_exg.s
	$(CC1) _exg.s

$(LIBRARY)(_fat.o):	_fat.s
	$(CC1) _fat.s

$(LIBRARY)(_ffp.o):	_ffp.s
	$(CC1) _ffp.s

$(LIBRARY)(_gto.o):	_gto.s
	$(CC1) _gto.s

$(LIBRARY)(_inn.o):	_inn.s
	$(CC1) _inn.s

$(LIBRARY)(_los.o):	_los.s
	$(CC1) _los.s

$(LIBRARY)(_lpb.o):	_lpb.s
	$(CC1) _lpb.s

$(LIBRARY)(_lxa.o):	_lxa.s
	$(CC1) _lxa.s

$(LIBRARY)(_lxl.o):	_lxl.s
	$(CC1) _lxl.s

$(LIBRARY)(_mli.o):	_mli.s
	$(CC1) _mli.s

$(LIBRARY)(_mlu.o):	_mlu.s
	$(CC1) _mlu.s

$(LIBRARY)(_mon.o):	_mon.s
	$(CC1) _mon.s

$(LIBRARY)(_rck.o):	_rck.s
	$(CC1) _rck.s

$(LIBRARY)(_ret.o):	_ret.s
	$(CC1) _ret.s

$(LIBRARY)(_set.o):	_set.s
	$(CC1) _set.s

$(LIBRARY)(_shp.o):	_shp.s
	$(CC1) _shp.s

$(LIBRARY)(_sig.o):	_sig.s
	$(CC1) _sig.s

$(LIBRARY)(_sts.o):	_sts.s
	$(CC1) _sts.s

$(LIBRARY)(_trp.o):	_trp.s
	$(CC1) _trp.s


$(LIBRARY)(stb.o):	stb.s
	$(CC1) $<

$(LIBRARY)(ara.o):	ara.s
	$(CC1) $<

$(LIBRARY)(cii.o):	cii.s
	$(CC1) $<

$(LIBRARY)(cmi.o):	cmi.s
	$(CC1) $<

$(LIBRARY)(cmp.o):	cmp.s
	$(CC1) $<

$(LIBRARY)(cmu.o):	cmu.s
	$(CC1) $<

$(LIBRARY)(csa.o):	csa.s
	$(CC1) $<

$(LIBRARY)(csa4.o):	csa4.s
	$(CC1) $<

$(LIBRARY)(csb.o):	csb.s
	$(CC1) $<

$(LIBRARY)(csb4.o):	csb4.s
	$(CC1) $<

$(LIBRARY)(cuu.o):	cuu.s
	$(CC1) $<

$(LIBRARY)(exg.o):	exg.s
	$(CC1) $<

$(LIBRARY)(inn.o):	inn.s
	$(CC1) $<

$(LIBRARY)(los.o):	los.s
	$(CC1) $<

$(LIBRARY)(rck.o):	rck.s
	$(CC1) $<

$(LIBRARY)(ret.o):	ret.s
	$(CC1) $<

$(LIBRARY)(set.o):	set.s
	$(CC1) $<

$(LIBRARY)(sts.o):	sts.s
	$(CC1) $<

$(LIBRARY)(nop.o):	nop.s
	$(CC1) $<

$(LIBRARY)(mon.o):	mon.s
	$(CC1) $<

$(LIBRARY)(dvi.o):	dvi.s
	$(CC1) $<

$(LIBRARY)(dvu.o):	dvu.s
	$(CC1) $<

$(LIBRARY)(mli.o):	mli.s
	$(CC1) $<

$(LIBRARY)(mlu.o):	mlu.s
	$(CC1) $<

$(LIBRARY)(shp.o):	shp.s
	$(CC1) $<

$(LIBRARY)(sig.o):	sig.s
	$(CC1) $<

$(LIBRARY)(cms.o):	cms.s
	$(CC1) $<

$(LIBRARY)(gto.o):	gto.s
	$(CC1) $<

$(LIBRARY)(fp68881.o):	fp68881.s
	$(CC1) $<

$(LIBRARY)(fat.o):	fat.s
	$(CC1) $<

$(LIBRARY)(trp.o):	trp.s
	$(CC1) $<

$(LIBRARY)(dia.o):	dia.s
	$(CC1) $<

$(LIBRARY)(lxl.o):	lxl.s
	$(CC1) $<

$(LIBRARY)(lxa.o):	lxa.s
	$(CC1) $<

$(LIBRARY)(lpb.o):	lpb.s
	$(CC1) $<


clean:
	rm -f $(OBJS)

clobber:
	rm -f $(OBJS)

