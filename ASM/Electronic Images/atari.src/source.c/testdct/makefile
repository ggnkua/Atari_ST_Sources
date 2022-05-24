CC            = wcc386

CFLAGS       =  /mf /d2 /4r /bt=dos4g /w2 /oe=3 /zp4 /oneatx /dNO_SANITY_CHECKS /dNO_LRAND48 /dNDEBUG /dBSD  

NAME          = test

LNK           = $(name).lnk

OBJS         = fastdct.obj idct.obj idct2.obj idct3.obj main.obj  

SRCS          = 

$(name).exe :   $(OBJS) $(LNK)
		wlink @$(LNK)

.c.obj :
	$(CC) $(CFLAGS) $[*
    
$(LNK) : makefile 
    %create $(LNK)
    @%append $(LNK) debug all
    @%append $(LNK) sys dos4g
    @%append $(LNK) name $(name)
    @for %i in ($(OBJS)) do @%append $(LNK) file %i
	
