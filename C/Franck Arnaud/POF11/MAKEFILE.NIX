# POF Makefile for Unix
# You'll need strftime

CC=gcc

# define USE_STRINS if you don't have, etc
CFLAGS=-O -DUNIX -DNO_LDIFFTIME

# libcext contains strftime
LDLIBS=-lcext

pof: pof.o
    $(CC) pof.o $(LDLIBS) -o pof
