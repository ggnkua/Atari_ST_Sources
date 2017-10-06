CFLAGS = -O

OBJ = formdemo.o

formdemo.prg: $(OBJ)
    cc -o formdemo.prg $(OBJ) aesfast.a vdifast.a dlibs.a

archive:
    lharc a formdemo.lzh form*.c form*.h form*.rs* form*.mak
    
dist: archive
    lharc a formdemo.lzh formdemo.prg
    
demo:
    $(RM) gemfdemo.lzh
    lharc a gemfdemo.lzh readme.txt gemfast.doc 
    lharc a gemfdemo.lzh formdemo.prg formdemo.rs* formdemo.h formdemo.c
    

