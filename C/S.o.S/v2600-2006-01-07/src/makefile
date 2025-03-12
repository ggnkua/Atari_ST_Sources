NAME	  = v2600.ttp

CC        = gcc
CFLAGS    = -O2 -I/usr/local/include
DEFINES   =
INCLUDES  = -I. -I..
LIBS	  = -L/usr/local/lib -lgem -lm

OBJECTS   = ikbd.o atari_disp.o c2p.o atari_mouse.o atari_keyb.o atari_sound.o atari_joy.o\
	../no_ui.o ../raster.o ../table.o ../misc.o ../txt_debug.o ../files.o \
	../main.o ../cpu.o ../vmachine.o ../dbg_mess.o \
	../memory.o ../limiter.o ../exmacro.o ../keyboard.o \
	../collision.o ../options.o
	
all: $(NAME)

$(NAME): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $@

.c.o:
	$(CC) -c $(CFLAGS) $(INCLUDES) $(DEFINES) $< -o $@

clean:
	rm -f $(OBJECTS) $(NAME)
