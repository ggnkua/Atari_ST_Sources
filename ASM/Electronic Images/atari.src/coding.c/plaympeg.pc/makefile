CC            = wcc386
ASM           = tasm
AFLAGS        = /ml /zi /m2
#AFLAGS        = /mf /d2 /4pr /bt=dos4g

CFLAGS       =  /mf /d2 /4r /bt=dos4g /w2 /oe=15 /oneatx /zp4 

NAME          = plaympeg

LNK           = $(name).lnk

HDRS          = 

OBJS         = display.obj plaympeg.obj getblk.obj gethdr.obj getpic.obj motion.obj getvlc.obj  getbits.obj getbitsa.obj idct.obj #jrevdct.obj

SRCS          = 

$(name).exe :   $(OBJS) $(LNK)
		wlink @$(LNK)

.c.obj :
	$(CC) $(CFLAGS) $[*
    
.asm.obj : 
		$(ASM) $(AFLAGS) $[*

$(LNK) : makefile 
    %create $(LNK)
    @%append $(LNK) debug all
    @%append $(LNK) sys dos4g
    @%append $(LNK) name $(name)
    @for %i in ($(OBJS)) do @%append $(LNK) file %i
