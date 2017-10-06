GB36_GEN = default2.out default4.out hell.out default.out default3.out \
	default5.out sky.out

GEN = $(GB36_GEN)

all: tests

tests: $(GEN)
	@for i in $(GEN); do ls -l $$i; done

%.out: gb36test.a ../sky/gfalist
	ar xvo $< $*.gfa $*.lst
	../sky/gfalist -b -o $*.tmp $*.gfa
	diff $*.lst $*.tmp > $@ || true
	rm $*.gfa $*.lst $*.tmp

../sky/gfalist:
	(cd ..; make sky/gfalist)

clean:
	rm -f $(GEN)

