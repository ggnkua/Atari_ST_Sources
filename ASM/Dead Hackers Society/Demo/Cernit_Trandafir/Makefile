PATH := $(PATH):/usr/local/bin:/opt/vbcc/bin

CC = /opt/vbcc/bin/vc
ASM = /opt/vbcc/bin/vasm
LD = /opt/vbcc/bin/vlink
CFLAGS	= -cpu=68000 -O1
ASMFLAGS = -m68000 -Felf -noesc -nosym -quiet
LDFLAGS = -bataritos -tos-flags 7
LOADLIBES = 
LDLIBS =

PRG = fullmain.tos
OBJ = fullmain.o

.PHONY:	fullmain.s	# always rebuild target

all : $(PRG)

install : $(all)
	mcopy -o fullmain.tos e:fullmain.tos
	sync

	

$(PRG):	$(OBJ)
	$(LD) $< $(LDFLAGS) -o $@
.c.o:
	$(CC) -c $(CFLAGS) $<
.s.o:
	$(ASM) $(ASMFLAGS) $< -o $@

fullmain.o:	$(SRC)

clean:	
	rm -f $(PRG) $(OBJ)
