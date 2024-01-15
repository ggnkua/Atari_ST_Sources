
# Makefile for SMS Plus / F030
#
# Copyright (C) 1998-2003  Charles MacDonald
# Atari Falcon version by Peter Persson
#

NAME	  = sp.ttp

CC        = gcc
CFLAGS    = -O2 -I/usr/local/include
DEFINES   =
INCLUDES  = -I. -I.. -I../unzip -I../cpu -I../sound
LIBS	  = -L/usr/local/lib -lgem -lm -lz

#OBJECTS   = main.o input.o ikbd.o psg.o sms.o system.o loadrom.o\
#            drv_VIDEL5.o drv_VIDEL16.o \
#            ../render.o ../vdp.o \
#            ../cpu/z80.o
            
            
OBJECTS	=	../cpu/z80.o	\
		../sms.o	\
		pio.o	\
		memz80.o	\
		../render.o	\
		../vdp.o	\
		system.o	\
		../error.o
	        
OBJECTS	+=	state.o	\
		../loadrom.o	\
		../fileio.o	\
	        
OBJECTS	+=	../unzip/unzip.o	\
		../unzip/ioapi.o	\

OBJECTS	+=	main.o	\
		input.o	\
		ikbd.o	\
		drv_VIDEL5.o	\
		drv_VIDEL16.o	\
		psg.o

all: $(NAME)

$(NAME): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $@

.c.o:
	$(CC) -c $(CFLAGS) $(INCLUDES) $(DEFINES) $< -o $@

clean:
	rm -f $(OBJECTS) $(NAME)
