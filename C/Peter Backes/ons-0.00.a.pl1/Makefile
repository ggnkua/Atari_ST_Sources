# The top level Makefile

DISTRIB = ons

SUBTARGETS = sky/libsky.a sky/gfalist
PHONYTARGETS = tests
TARGETS = CHANGELOG

TRASH = core ons.spec.OLD

all: $(SUBTARGETS) $(TARGETS) $(PHONYTARGETS)

sky/libsky.a:
	(cd sky; make libsky.a)

sky/gfalist:
	(cd sky; make gfalist)

tests:
	(cd tests; make tests)

realclean:
	(cd sky; make realclean)
	(cd tests; make clean)
	rm -f $(TRASH) $(TARGETS)

unclean:
	(cd sky; make unclean)

CHANGELOG: HISTORY sky/HISTORY
	cat $+ > CHANGELOG

dist: HISTORY packdist.sh ons.spec
	sh packdist.sh -t $(DISTRIB) -v HISTORY makedist

rpms: dist
	sh packdist.sh -t $(DISTRIB) -v HISTORY makerpms

ons.spec: README HISTORY packdist.sh
	sh packdist.sh -a README -v HISTORY -t $(DISTRIB) -s ons.spec fixspec

