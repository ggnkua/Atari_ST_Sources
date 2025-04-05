CC = /opt/vbcc/bin/vc
ASM = /opt/vbcc/bin/vasm
LD = /opt/vbcc/bin/vlink
CFLAGS	= -cpu=-cpu=68030 -fpu=68882 -O1
ASMFLAGS = -m68060 -Felf -noesc -nosym -quiet -no-opt
LDFLAGS = -bataritos -tos-flags 7
LOADLIBES = 
LDLIBS =

PRG = main.tos
OBJ = main.o

.PHONY:	main.s	# always rebuild target

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
	