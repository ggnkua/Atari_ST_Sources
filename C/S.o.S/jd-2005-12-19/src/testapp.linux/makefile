NAME	  = joy_lnx

CC        = gcc
CFLAGS    = -O2 -I/usr/local/include
DEFINES   =
INCLUDES  = -I. -I../include
LIBS	  = -L/usr/local/lib -lgem -lm

OBJECTS   = test.o

all: $(NAME)

$(NAME): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $@

.c.o:
	$(CC) -c $(CFLAGS) $(INCLUDES) $(DEFINES) $< -o $@

clean:
	rm -f $(OBJECTS) $(NAME)
