#
# Makefile for make
#

CFLAGS = -O

OBJS1 = check.o input.o macro.o reader.o rules.o readenv.o
OBJS2 = main.o make.o ststuff.o
#OBJS2 =

make.ttp : $(OBJS1) $(OBJS2)
	cc $(OBJS1) $(OBJS2) -o make.ttp

touch.ttp : touch.c
	cc touch.c -o touch.ttp


$(OBJS1) : h.h
$(OBJS2) : h.h astat.h

clean:
	$(RM) *.o

clobber:
	$(RM) *.o *.ttp
