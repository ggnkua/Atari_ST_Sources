# Makefile for lib/i86/em.

CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE -Was-ncc
CC1	= $(CC) $(CFLAGS) -c

LIBRARY	= ../../libe.a
all:	$(LIBRARY)

OBJECTS	= \
	$(LIBRARY)(adi.o) \
	$(LIBRARY)(and.o) \
	$(LIBRARY)(blm.o) \
	$(LIBRARY)(cii.o) \
	$(LIBRARY)(cmi4.o) \
	$(LIBRARY)(cms.o) \
	$(LIBRARY)(cmu4.o) \
	$(LIBRARY)(com.o) \
	$(LIBRARY)(csa2.o) \
	$(LIBRARY)(csa4.o) \
	$(LIBRARY)(csb2.o) \
	$(LIBRARY)(csb4.o) \
	$(LIBRARY)(cuu.o) \
	$(LIBRARY)(dup.o) \
	$(LIBRARY)(dvi4.o) \
	$(LIBRARY)(dvu4.o) \
	$(LIBRARY)(error.o) \
	$(LIBRARY)(exg.o) \
	$(LIBRARY)(fat.o) \
	$(LIBRARY)(fp8087.o) \
	$(LIBRARY)(gto.o) \
	$(LIBRARY)(iaar.o) \
	$(LIBRARY)(ilar.o) \
	$(LIBRARY)(inn.o) \
	$(LIBRARY)(ior.o) \
	$(LIBRARY)(isar.o) \
	$(LIBRARY)(lar2.o) \
	$(LIBRARY)(lfr6.o) \
	$(LIBRARY)(lfr8.o) \
	$(LIBRARY)(loi.o) \
	$(LIBRARY)(mli4.o) \
	$(LIBRARY)(mon.o) \
	$(LIBRARY)(nop.o) \
	$(LIBRARY)(rck.o) \
	$(LIBRARY)(ret6.o) \
	$(LIBRARY)(ret8.o) \
	$(LIBRARY)(retarea.o) \
	$(LIBRARY)(return.o) \
	$(LIBRARY)(rmi4.o) \
	$(LIBRARY)(rmu4.o) \
	$(LIBRARY)(sar2.o) \
	$(LIBRARY)(sbi.o) \
	$(LIBRARY)(set.o) \
	$(LIBRARY)(stb.o) \
	$(LIBRARY)(sti.o) \
	$(LIBRARY)(stop.o) \
	$(LIBRARY)(strhp.o) \
	$(LIBRARY)(trp.o) \
	$(LIBRARY)(unknown.o) \
	$(LIBRARY)(vars.o) \
	$(LIBRARY)(xor.o) \

$(LIBRARY):	$(OBJECTS)
	aal cr $@ *.o
	rm *.o

$(LIBRARY)(adi.o):	adi.s
	$(CC1) adi.s

$(LIBRARY)(and.o):	and.s
	$(CC1) and.s

$(LIBRARY)(blm.o):	blm.s
	$(CC1) blm.s

$(LIBRARY)(cii.o):	cii.s
	$(CC1) cii.s

$(LIBRARY)(cmi4.o):	cmi4.s
	$(CC1) cmi4.s

$(LIBRARY)(cms.o):	cms.s
	$(CC1) cms.s

$(LIBRARY)(cmu4.o):	cmu4.s
	$(CC1) cmu4.s

$(LIBRARY)(com.o):	com.s
	$(CC1) com.s

$(LIBRARY)(csa2.o):	csa2.s
	$(CC1) csa2.s

$(LIBRARY)(csa4.o):	csa4.s
	$(CC1) csa4.s

$(LIBRARY)(csb2.o):	csb2.s
	$(CC1) csb2.s

$(LIBRARY)(csb4.o):	csb4.s
	$(CC1) csb4.s

$(LIBRARY)(cuu.o):	cuu.s
	$(CC1) cuu.s

$(LIBRARY)(dup.o):	dup.s
	$(CC1) dup.s

$(LIBRARY)(dvi4.o):	dvi4.s
	$(CC1) dvi4.s

$(LIBRARY)(dvu4.o):	dvu4.s
	$(CC1) dvu4.s

$(LIBRARY)(error.o):	error.s
	$(CC1) error.s

$(LIBRARY)(exg.o):	exg.s
	$(CC1) exg.s

$(LIBRARY)(fat.o):	fat.s
	$(CC1) fat.s

$(LIBRARY)(fp8087.o):	fp8087.s
	$(CC1) fp8087.s

$(LIBRARY)(gto.o):	gto.s
	$(CC1) gto.s

$(LIBRARY)(iaar.o):	iaar.s
	$(CC1) iaar.s

$(LIBRARY)(ilar.o):	ilar.s
	$(CC1) ilar.s

$(LIBRARY)(inn.o):	inn.s
	$(CC1) inn.s

$(LIBRARY)(ior.o):	ior.s
	$(CC1) ior.s

$(LIBRARY)(isar.o):	isar.s
	$(CC1) isar.s

$(LIBRARY)(lar2.o):	lar2.s
	$(CC1) lar2.s

$(LIBRARY)(lfr6.o):	lfr6.s
	$(CC1) lfr6.s

$(LIBRARY)(lfr8.o):	lfr8.s
	$(CC1) lfr8.s

$(LIBRARY)(loi.o):	loi.s
	$(CC1) loi.s

$(LIBRARY)(mli4.o):	mli4.s
	$(CC1) mli4.s

$(LIBRARY)(mon.o):	mon.s
	$(CC1) mon.s

$(LIBRARY)(nop.o):	nop.s
	$(CC1) nop.s

$(LIBRARY)(rck.o):	rck.s
	$(CC1) rck.s

$(LIBRARY)(ret6.o):	ret6.s
	$(CC1) ret6.s

$(LIBRARY)(ret8.o):	ret8.s
	$(CC1) ret8.s

$(LIBRARY)(retarea.o):	retarea.s
	$(CC1) retarea.s

$(LIBRARY)(return.o):	return.s
	$(CC1) return.s

$(LIBRARY)(rmi4.o):	rmi4.s
	$(CC1) rmi4.s

$(LIBRARY)(rmu4.o):	rmu4.s
	$(CC1) rmu4.s

$(LIBRARY)(sar2.o):	sar2.s
	$(CC1) sar2.s

$(LIBRARY)(sbi.o):	sbi.s
	$(CC1) sbi.s

$(LIBRARY)(set.o):	set.s
	$(CC1) set.s

$(LIBRARY)(stb.o):	stb.c
	$(CC1) stb.c

$(LIBRARY)(sti.o):	sti.s
	$(CC1) sti.s

$(LIBRARY)(stop.o):	stop.s
	$(CC1) stop.s

$(LIBRARY)(strhp.o):	strhp.s
	$(CC1) strhp.s

$(LIBRARY)(trp.o):	trp.s
	$(CC1) trp.s

$(LIBRARY)(unknown.o):	unknown.s
	$(CC1) unknown.s

$(LIBRARY)(vars.o):	vars.s
	$(CC1) vars.s

$(LIBRARY)(xor.o):	xor.s
	$(CC1) xor.s
