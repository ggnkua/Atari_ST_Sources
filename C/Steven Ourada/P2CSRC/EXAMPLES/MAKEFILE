
# Examples for "p2c", the Pascal to C translator.


# The following definitions assume p2c has been compiled into the "home"
# directory as shown in src/Makefile.
P2C = ../p2c
INC = ../home
LIB = ../home/libp2c.a


default: comp


# Translating everything:

trans:  fact.c  e.c  self.c  cref.c  basic.c

fact.c: fact.p
	$(P2C) fact.p

e.c: e.p
	$(P2C) e.p

self.c: self.p
	$(P2C) self.p

cref.c: cref.p
	$(P2C) cref.p

basic.c: basic.p
	$(P2C) basic.p



# Compiling everything:

comp:  fact  e  self  cref  basic

fact: fact.c
	$(CC) -I$(INC) fact.c $(LIB) -o fact

e: e.c
	$(CC) -I$(INC) e.c $(LIB) -o e

self: self.c
	$(CC) -I$(INC) self.c $(LIB) -o self

cref: cref.c
	$(CC) -I$(INC) cref.c $(LIB) -o cref

basic: basic.c
	$(CC) -I$(INC) basic.c $(LIB) -lm -o basic






