#
# makefile for wnd2xmpl.prg
#   items of note:
#    -there are two object files for this program, so a special rule
#     for the link is written following the program target, so that 
#     both modules can be named.
#    -both object modules have to be remade if the application header
#     file changes, so an additional dependency is coded for that.

CFLAGS = -O
OBJ    = wnd2xmpl.o thermo.o

wnd2xmpl.prg: $(OBJ)
    cc -rapstart.o -o wnd2xmpl.prg $(OBJ) aesfast.a dlibs.a
    
$(OBJ): wnd2xmpl.h
