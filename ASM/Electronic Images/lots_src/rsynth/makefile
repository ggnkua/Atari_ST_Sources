# $Id: Makefile,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
PURIFYHOME = /net/miranda/home/disk9/simsus/purify2

all: $(PROGS) say klatt
#	say make completed

KLATT_OBJS = klatt.o parwave.o

kl2elm : kl2elm.o phonemes.o

klatt : $(KLATT_OBJS)
	$(CC) -o $@ $(LDFLAGS) $(KLATT_OBJS) $(LDLIBS)

SKLATT_OBJS = sklatt.o def_pars.o parwave.o hplay.o timer.o

sklatt : $(SKLATT_OBJS)
	$(CC) -o $@ $(LDFLAGS) $(SKLATT_OBJS) $(LDLIBS)

#BACKEND = parwave.o
BACKEND = nsynth.o

# SAY_OBJS = say.o saynum.o darray.o ASCII.o text.o english.o trie.o phtoelm.o holmes.o elements.o nsynth.o def_pars.o hplay.o dict.o getarg.o
SAY_OBJS = say.o saynum.o darray.o ASCII.o text.o english.o trie.o phtoelm.o \
           holmes.o elements.o $(BACKEND) def_pars.o hplay.o dict.o getarg.o


say : $(SAY_OBJS)
	$(CC) -o $@ $(LDFLAGS) $(SAY_OBJS) $(LDLIBS)

psay : $(SAY_OBJS)
	$(PURIFYHOME)/purify $(CC) -o $@ $(LDFLAGS) $(SAY_OBJS) $(LDLIBS)

clean:
	rm -f *.o $(PROGS) say klatt lex.yy.c tmp.par core

spotless: clean
	rm -f *~ *%

distribution: spotless
	-mkdir /tmp/rsynth
	tar cf - `cat FILES` | (cd /tmp/rsynth; tar xvf - )
	(cd /tmp; tar cvf - rsynth ) | compress > ../rsynth.tar.Z

#MM
ASCII.o : ASCII.c ASCII.h 
darray.o : darray.c proto.h darray.h 
def_pars.o : def_pars.c proto.h getargs.h h2pw.h nsynth.h hplay.h pars.def 
dict.o : dict.c proto.h dict.h 
elements.o : elements.c elements.h Elements.def 
english.o : english.c 
getarg.o : getarg.c proto.h getargs.h 
holmes.o : holmes.c proto.h h2pw.h nsynth.h elements.h darray.h holmes.h getargs.h 
hplay.o : hplay.c proto.h getargs.h hplay.h 
klatt.o : klatt.c proto.h parwave.h 
nsynth.o : nsynth.c proto.h nsynth.h 
parwave.o : parwave.c proto.h parwave.h 
phtoelm.o : phtoelm.c proto.h elements.h darray.h trie.h phtoelm.h holmes.h \
  phtoelm.def 
say.o : say.c proto.h h2pw.h nsynth.h hplay.h dict.h ASCII.h darray.h holmes.h \
  phtoelm.h text.h getargs.h say.h 
saynum.o : saynum.c proto.h darray.h say.h 
text.o : text.c proto.h darray.h phtoelm.h text.h say.h 
trie.o : trie.c proto.h trie.h 
