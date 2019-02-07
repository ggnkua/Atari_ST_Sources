
OBJ = main.o input.o gemstuff.o datadefs.o \
minipalt.o aesblit.o simumenu.o picsave.o fastplot.o

.c.o:
+ $(SETENV)BUFSIZE=16000
+ hcc.ttp    $*.c
+ top.ttp -v $*.s
+ jas.ttp    $*.s
+ $(RM)      $*.s

spinweel.prg: $(OBJ)
+ aln.prg -v -w -o spinweel.prg -c spinweel.lnk 


