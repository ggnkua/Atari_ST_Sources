VERSION = 18

default:
    echo this makefile has no default target!
    
distrib:
    del gemfxm$(VERSION).lzh
    lharc a -xmpr gemfxm$(VERSION) *.c *.h *.r* *.mak
    
