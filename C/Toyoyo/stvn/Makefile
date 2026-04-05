SOURCES_DIR=./src
BUILD_DIR=./build
DIST_DIR=./dist
RSC_DIR=./rsc
LIBCMINI=./deps/libcmini
ZLIB=./deps/zlib-1.3.1
ICE=./deps/pack-ice

CROSS=m68k-atari-mintelf-
CC=$(CROSS)gcc
AR=$(CROSS)ar
RANLIB=$(CROSS)ranlib
CFLAGS=-c -nostdlib -nostdinc -I$(LIBCMINI)/include -I$(ZLIB) -I${ICE}
LDFLAGS=-s -Wl,--gc-sections -fomit-frame-pointer $(ZLIB)/libz.a -L$(LIBCMINI)/build -L$(ICE) -lice -lcmini -lgcc

# VASM PARAMETERS
ASM=vasmm68k_mot
ASMFLAGS=-Felf -quiet -x -m68000 -spaces -showopt

all: prepare libcmini ice zlib dist compress

prepare:
	mkdir -p $(BUILD_DIR)

clean-compile : clean buffer.o screen.o main.o

libcmini:
	cd $(LIBCMINI) ; make

ice:
	cd $(ICE) ; make CFLAGS="-nostdlib -nostdinc -I../../$(LIBCMINI)/include" LDFLAGS="-L../../$(LIBCMINI)/build -lcmini -lgcc"

zlib:
	cd $(ZLIB) ; chmod +x ./configure
	if [ ! -f "$(ZLIB)/zlib.pc" ]; then\
		cd $(ZLIB) ; CC=$(CC) AR=$(AR) RANLIB=$(RANLIB) ./configure;\
	fi
	cd $(ZLIB) ; make CFLAGS="-O3 -nostdlib -nostdinc -I../../$(LIBCMINI)/include" LDFLAGS="-L../../$(LIBCMINI)/build -lcmini -lgcc" libz.a

sndhisr.o:
	$(ASM) $(ASMFLAGS) $(SOURCES_DIR)/sndhisr.s -o $(BUILD_DIR)/sndhisr.o

sndh.o:
	$(CC) $(CFLAGS) $(SOURCES_DIR)/sndh.c -o $(BUILD_DIR)/sndh.o

stvn.o:
	$(CC) $(CFLAGS) $(SOURCES_DIR)/stvn.c -o $(BUILD_DIR)/stvn.o

main: stvn.o sndh.o sndhisr.o
	$(CC) -nostdlib $(LIBCMINI)/build/objs/crt0.o \
		$(BUILD_DIR)/*.o \
		-o $(BUILD_DIR)/stvn.prg $(LDFLAGS);

dist: main
	mkdir -p $(DIST_DIR)
	cp $(BUILD_DIR)/stvn.prg $(DIST_DIR)
	$(CROSS)strip -s $(DIST_DIR)/stvn.prg
	cp -R $(RSC_DIR)/* $(DIST_DIR)

compress:
	upx --best $(DIST_DIR)/stvn.prg

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)
	cd $(LIBCMINI) ; make clean
	cd $(ZLIB) ; make distclean
	cd $(ICE) ; make clean
