# Makefile for <fnord>adel Reference Manual
# $Id: Makefile,v 2.4 91/09/01 21:40:38 royce Exp $

SOURCES = copying.tex intro.tex fifteen.tex theory.tex user-ref.tex \
	  aide-ref.tex sysopref.tex modem.tex events.tex network.tex \
	  doors.tex ruggie.tex shells.tex transfer.tex misc.tex \
	  support.tex history.tex

INDEX_SOURCES = fnord.cp fnord.fn fnord.ky fnord.pg fnord.tp fnord.vr \
fnorddoc.cp fnorddoc.fn fnorddoc.ky fnorddoc.pg fnorddoc.tp fnorddoc.vr

INDEX_SORTED = fnord.cps fnord.fns fnord.kys fnord.pgs fnord.tps fnord.vrs \
fnorddoc.cps fnorddoc.fns fnorddoc.kys fnorddoc.pgs fnorddoc.tps fnorddoc.vrs

JUNK = fnord.aux fnord.log fnord.toc fnorddoc.aux fnorddoc.log fnorddoc.toc \
fnorddoc.err

all: fnord.dvi

co:
	co fnord.tex fnorddoc.tex $(SOURCES)

quick.dvi: fnord.tex $(SOURCES)
	tex fnord.tex

fnord.dvi: fnord.tex $(SOURCES)
	tex fnord.tex
	tex fnord.tex
	texindex fnord.??
	tex fnord.tex

fnord.doc: fnorddoc.tex $(SOURCES)
	tex fnorddoc.tex
	tex fnorddoc.tex
	texindex fnorddoc.??
	tex fnorddoc.tex
	dvidoc -e fnorddoc.dvi > fnord.doc

clean:
	$(RM) -f $(INDEX_SOURCES) $(INDEX_SORTED) $(JUNK)

veryclean: clean
	$(RM) -f fnord.dvi fnorddoc.dvi fnord.doc

