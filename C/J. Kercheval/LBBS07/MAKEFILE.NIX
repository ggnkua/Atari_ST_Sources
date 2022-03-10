# Preliminary lazyBBS makefile for Unix (gnu-make req?)
#
CC=gcc
CFLAGS=-O -g -DUNIX -Dstricmp=strcasecmp -Dstrnicmp=strncasecmp
LOADLIBES=-lcext
# libcext contains strlwr which is needed and is not in my libc
bbs: bbs.o linedit.o msg.o sysdep.o match.o miscio.o login.o

bbs.c: qbbs.h bbs.h match.h linedit.h login.h miscio.h sysdep.h 
linedit.c: bbs.h miscio.h 
msg.c: bbs.h qbbs.h miscio.h msg.h login.h 
sysdep.c: sysdep.h bbs.h 
miscio.c: sysdep.h bbs.h miscio.h 
login.c: bbs.h login.h miscio.h 
