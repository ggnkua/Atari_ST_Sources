
CFLAGS = -DTOS -DNHASH=64 -O

OBJS = main.o pass1.o pass2.o bio.o syms.o rel.o utls.o bcopy.o

xld.ttp: $(OBJS)
	cc -o xld.ttp $(OBJS)
