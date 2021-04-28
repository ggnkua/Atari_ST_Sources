#
# makefile for minicolr.acc.  
#   notable items:
#   -there is no built-in rule in MAKE.INI for compiling accessories;
#    .ACC is not a known type.  therefore, we specify a linker rule
#    after the program target.  (yes, yes, we could have compiled as
#    a .prg using a default-ish rule then copied to the .ACC.  not as
#    much fun that way.)
#   -the -r compiler option is used to force usage of minstart.o instead
#    of the default dstart.o, since dstart is not compatible with ACCs.
#    (minstart is .PRG/.ACC compatible, and is the only ACC-compatible
#    startup file in the distribution)
# 

CFLAGS = -O 

minicolr.acc: minicolr.o
    cc -rminstart.o -o minicolr.acc minicolr.o aesfast.a dlibs.a
    $(CP) minicolr.acc minicolr.prg


