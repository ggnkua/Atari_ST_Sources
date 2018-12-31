# Makefile for IMG/PBM viewer

CC = gcc
CFLAGS = -O -fomit-frame-pointer
INSTALL_DIR = /gnu/source/view/

view: view.o
	gcc -o $@ $<
	strip view
	chmod 755 view

view.o: view.c dmatrix.h

install:
	cp view ${INSTALL_DIR}

clean:
	rm view.o

real-clean:
	rm Makefile view* dmatrix.h dither*.dit devil.img readme.txt

package:
	tar -zcvf view.tgz Makefile view.c dmatrix.h \
	dither*.dit devil.img readme.txt
