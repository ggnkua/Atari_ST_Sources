CC            = wcl386
ASM           = tasm
CFLAGS        =  /c /mf /d2 /5r /zp4 /bt=dos4g /oe=3 /oneatx /s   
AFLAGS        = /zi /m2

.BEFORE
	@set DOS4G=QUIET

NAME          = 3d

LNK           = $(name).lnk

HDRS          = 
OBJS         = 3d.obj hware.obj matrix2.obj modexstf.obj 

$(name).exe :   $(OBJS) $(LNK)
		wlink @$(LNK)

.c.obj :        
		$(CC) $(CFLAGS) $[*
    
.asm.obj : 
		$(ASM) $(AFLAGS) $[*

$(LNK) : makefile $(OBJS) 
    %create $(LNK)
    @%append $(LNK) debug all
    @%append $(LNK) sys dos4g
    @%append $(LNK) name $(name)
    @for %i in ($(OBJS)) do @%append $(LNK) file %i
	
