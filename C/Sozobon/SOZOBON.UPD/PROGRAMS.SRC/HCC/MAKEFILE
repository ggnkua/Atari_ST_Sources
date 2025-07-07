#RM=rm
CC=cc
LD=ld
AS=jas

OBJS =	d2.o decl.o expr.o fix.o fun.o g2.o gen.o gsub.o gunk.o \
	main.o md.o nodes.o out_st.o p2.o pre.o tok.o subs_tos.o

H =	bstok.h cookie.h flags.h gen.h nodes.h ops.h param.h \
	sttok.h tok.h tytok.h

CFLAGS = -v -O

nhcc.ttp: $(OBJS)
	ld -vpb -f tos.ld -o nhcc.ttp

$(OBJS) : $(H)

clean:
	$(RM) *.o

clobber:
	$(RM) *.o hcc
