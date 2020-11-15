
# GEM Makefile

CC = gcc
CFLAGS = -g -O -I/e/Python-2.7.1/Include -I/e/Python-2.7.1

LIBS = -lgem -lldg

OBJECTS = gem.o py_aes.o py_vdi.o

TARGET = _gem.ldg

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<
	
$(TARGET): $(OBJECTS)
	$(CC) -o $(TARGET) $(OBJECTS) $(LIBS)

clean:
	rm -f $(TARGET) $(OBJECTS)

all: $(TARGET)
