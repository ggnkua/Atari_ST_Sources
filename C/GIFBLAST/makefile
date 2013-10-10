
# makefile for gifblast program

# You need to substitute here the appropriate lines for your system.
# The next four lines are for the MSC 5.1 compiler on the PC.
# The meanings of the options are:
# -AL - use large model
# -Ox - max. optimization
# -c, -D - standard
# For systems that do not accept ANSI-style function prototypes
# you should add -DNOPROTOS to the CC_ONE = ... line.
CC_ONE = cl -AL -Ox -c -DARCON_NTYPES=2 -DARCON_SMALL_RBSIZE=64
CC_LINK = cl -AL
OBJ_SUFFIX = .obj  # object file suffix
EXE_SUFFIX = .exe  # executable file suffix

all: gifblast$(EXE_SUFFIX)

gifblast$(EXE_SUFFIX): gifblast$(OBJ_SUFFIX) ubasic$(OBJ_SUFFIX) \
		uffile$(OBJ_SUFFIX) gifcode$(OBJ_SUFFIX) \
		arith$(OBJ_SUFFIX) arithcon$(OBJ_SUFFIX) gb11code$(OBJ_SUFFIX)
	$(CC_LINK) gifblast$(OBJ_SUFFIX) ubasic$(OBJ_SUFFIX) \
		uffile$(OBJ_SUFFIX) gifcode$(OBJ_SUFFIX) \
		arith$(OBJ_SUFFIX) arithcon$(OBJ_SUFFIX) gb11code$(OBJ_SUFFIX)

ubasic$(OBJ_SUFFIX): ubasic.h ubasic.c
	$(CC_ONE) -DNOFLOAT ubasic.c

uffile$(OBJ_SUFFIX): uffile.h uffile.c
	$(CC_ONE) uffile.c

gifcode$(OBJ_SUFFIX): uffile.h gifcode.h gifcode.c
	$(CC_ONE) gifcode.c

arith$(OBJ_SUFFIX): uffile.h arith.h arith.c
	$(CC_ONE) arith.c

arithcon$(OBJ_SUFFIX): arithcon.h arithcon.c
	$(CC_ONE) arithcon.c

gb11code$(OBJ_SUFFIX): uffile.h arith.h arithcon.h gb11code.h gb11code.c
	$(CC_ONE) gb11code.c

gifblast$(OBJ_SUFFIX): ubasic.h uffile.h gifcode.h \
		arith.h arithcon.h gb11code.h gifblast.c
	$(CC_ONE) gifblast.c
