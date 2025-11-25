# Makefile for 3D2-POV for use with gcc compiler

.c.o:
    gcc -O -Wall -c {$< }

3d2-pov.exe: 3d2-pov.o rayopt.o vect.o
    gcc 3d2-pov.o rayopt.o vect.o -lm
    strip a.out
    aout2exe 3d2-povx

3d2-pov.o: 3d2-pov.c rayopt.h vect.h

rayopt.o: rayopt.c rayopt.h vect.h

vect.o: vect.c vect.h
