CC            = wcc386
ASM           = tasm
CFLAGS        = /mf /d2 /4r /zp4 /bt=dos4g /oe=3 /oneatx /s   
AFLAGS        = /zi /m2

.BEFORE
	@set DOS4G=QUIET

NAME          = phong 

LNK           = $(name).lnk

HDRS          = 
OBJS         = phong1.obj objects.obj matrix.obj screen.obj hware.obj 

$(name).exe :   $(OBJS) $(LNK)
                wlink @$(LNK)

.c.obj :        
		$(CC) $(CFLAGS) $[*
    
.asm.obj : 
		$(ASM) $(AFLAGS) $[*

$(LNK) : makefile $(OBJS) 
    %create $(LNK)
    @%append $(LNK) sys dos4g
    #@%append $(LNK) debug all
    @%append $(LNK) name $(name)
    @for %i in ($(OBJS)) do @%append $(LNK) file %i
	
