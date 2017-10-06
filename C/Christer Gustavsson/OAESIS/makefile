RCSFILES = makefile oaesis.cnf readme

all:
	cd src; $(MAKE)
	cd tools; $(MAKE)

rcsci:
	ci -l $(RCSFILES)
	cd doc; $(MAKE) rcsci
	cd src; $(MAKE) rcsci
	cd tools; $(MAKE) rcsci

clean:
	cd src; $(MAKE) clean
	cd tools; $(MAKE) clean

realclean:
	cd src; $(MAKE) realclean
	cd tools; $(MAKE) realclean
