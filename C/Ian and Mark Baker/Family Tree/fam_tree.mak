CC1 = lc1b
CC1OPTS = -cfish -d0 -rs -fm -j*e -j=fam_tree.err -Hgeninc.sym -dGEN_PH
CC2 = lc2
CC2OPTS = -ma
LD = clink c.o
LDOPTS = LIB lc.lib+lcg.lib TTLOAD TTMALLOC SHARED
PH = lc1b
PHOPTS = -cfish -d0 -rs -fm -j*e -j=fam_tree.err -ph

all : gen.prg fam_tree.hyp

fam_tree.hyp : fam_tree.stg
	c:\utils\stguide\hcp fam_tree.stg +z

gen.prg : gen.o genclip.o gencoup.o gendata.o gendesc.o genfile.o\
			genmerg.o gennote.o genpers1.o genpers2.o genpprn.o\
			genpref.o genpsel.o gentprn.o gentree.o genutil.o\
			genfsel.o genchek.o
	$(LD) $< $(LDOPTS)

gen.o : gen.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) gen.c
	$(CC2) $(CC2OPTS) gen.q

genclip.o : genclip.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) -cm genclip.c
	$(CC2) $(CC2OPTS) genclip.q

gencoup.o : gencoup.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) gencoup.c
	$(CC2) $(CC2OPTS) gencoup.q

gendata.o : gendata.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) gendata.c
	$(CC2) $(CC2OPTS) gendata.q

gendesc.o : gendesc.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) gendesc.c
	$(CC2) $(CC2OPTS) gendesc.q

genfile.o : genfile.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) genfile.c
	$(CC2) $(CC2OPTS) genfile.q

genmerg.o : genmerg.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) genmerg.c
	$(CC2) $(CC2OPTS) genmerg.q

gennote.o : gennote.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) gennote.c
	$(CC2) $(CC2OPTS) gennote.q

genpers1.o : genpers1.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) genpers1.c
	$(CC2) $(CC2OPTS) genpers1.q

genpers2.o : genpers2.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) genpers2.c
	$(CC2) $(CC2OPTS) genpers2.q

genpprn.o : genpprn.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) genpprn.c
	$(CC2) $(CC2OPTS) genpprn.q

genpref.o : genpref.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) genpref.c
	$(CC2) $(CC2OPTS) genpref.q

genpsel.o : genpsel.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) genpsel.c
	$(CC2) $(CC2OPTS) genpsel.q

gentprn.o : gentprn.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) gentprn.c
	$(CC2) $(CC2OPTS) gentprn.q

gentree.o : gentree.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) gentree.c
	$(CC2) $(CC2OPTS) gentree.q

genutil.o : genutil.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) genutil.c
	$(CC2) $(CC2OPTS) genutil.q

genchek.o : genchek.c genhd.h geninc.sym
	$(CC1) $(CC1OPTS) genchek.c
	$(CC2) $(CC2OPTS) genchek.q

geninc.sym : geninc.h
	$(PH) $(PHOPTS) geninc.h
