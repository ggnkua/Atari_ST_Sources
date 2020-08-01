#ECHO=echo
#RM=rm
#CC=scc

#
# Makefile for various utilities
#
CFLAGS = -O

PROGS = nm.ttp size.ttp ar.ttp cc.ttp

all: $(PROGS)
	@$(ECHO) Compile done

nm.ttp: nm.c
	$(CC) $(CFLAGS) nm.c -o nm.ttp

size.ttp: size.c
	$(CC) $(CFLAGS) size.c -o size.ttp

ar.ttp: ar.c
	$(CC) $(CFLAGS) ar.c -o ar.ttp

cc.ttp: cc.c
	$(CC) $(CFLAGS) cc.c -o cc.ttp

clean:
	$(RM) *.o

clobber:
	$(RM) *.o $(PROGS)
