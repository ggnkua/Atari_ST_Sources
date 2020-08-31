CC =gcc
CFLAGS =-Wall -O2 -I/usr/X11R6/include
LDFLAGS = -L/usr/X11R6/lib -lXtst -lX11 -lXtst -lX11
OBJS = client_udp.o creer_socket.o gem_remote.o
SRC = client_udp.c creer_socket.c gem_remote.c Makefile generic_list.h azerty.kbd

gem_remote: $(OBJS) generic_list.h
	$(CC) $(CFLAGS) -o gem_remote $(OBJS) $(LDFLAGS)

clean:
	rm -f gem_remote $(OBJS) *~

dist: $(SRC)
	tar cfvz gem_remote.tgz $(SRC)

%.o: %.c
	$(CC) $(CFLAGS) -c $<
