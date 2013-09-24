PATH := $(PATH):/usr/local/bin:/opt/vbcc/bin

CC = /opt/vbcc/bin/vc
ASM = /opt/vbcc/bin/vasm
LD = /opt/vbcc/bin/vlink
CFLAGS	= -cpu=68000 -O1
ASMFLAGS = -m68000 -Felf -noesc -nosym -quiet -no-opt
LDFLAGS = -bataritos -tos-flags 7
LOADLIBES = 
LDLIBS =

PRG = main.tos
OBJ = main.o

.PHONY:	main.s	# always rebuild target

all : $(PRG)

install : $(all)
	mcopy -o main.tos e:main.tos
	sync

	

$(PRG):	$(OBJ)
	$(LD) $< $(LDFLAGS) -o $@
.c.o:
	$(CC) -c $(CFLAGS) $<
.s.o:
	$(ASM) $(ASMFLAGS) $< -o $@

main.o:	$(SRC)

clean:	
	rm -f $(PRG) $(OBJ)
