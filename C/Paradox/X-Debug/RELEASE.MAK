
A = m:
Z = cp -f $* $A\$*

all: drivers\**

m:\drivers\moniterm.scr: drivers\moniterm.scr
	$Z

m:\drivers\reflex.scr: drivers\reflex.scr
	$Z

m:\drivers\moniterm.c: drivers\moniterm.c
	$Z

m:\drivers\checkram.o: drivers\checkram.o
	$Z

m:\drivers\moniterm.mak: drivers\moniterm.mak
	$Z

m:\drivers\driver.h: drivers\driver.h
	$Z

