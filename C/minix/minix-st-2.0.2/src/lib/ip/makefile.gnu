# Makefile for lib/ip.

base = ..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= $(XCFLAGS) -I. -DNDEBUG
MAKE	= exec make -$(MAKEFLAGS)

LIBRARY	= $(LIBC)
all:	$(LIBRARY)

clean:
	$(RM) *.o

OBJECTS	= \
	ether_line.o \
	ethera2n.o \
	ethere2a.o \
	etherh2n.o \
	ethern2h.o \
	getdomain.o \
	gethnmadr.o \
	gethostent.o \
	gethostname.o \
	getnetbyname.o \
	getnetent.o \
	getproto.o \
	getprotoent.o \
	getservent.o \
	getsrvbyname.o \
	getsrvbyport.o \
	hton.o \
	inet_addr.o \
	inet_network.o \
	inet_ntoa.o \
	memcspn.o \
	rcmd.o \
	res_comp.o \
	res_init.o \
	res_mkquery.o \
	res_query.o \
	res_send.o \
	strcasecmp.o \

#	oneC_sum.o \

$(LIBRARY):	$(OBJECTS)
	$(AR) $(ARFLAGS) $@ *.o
	$(RM) *.o
