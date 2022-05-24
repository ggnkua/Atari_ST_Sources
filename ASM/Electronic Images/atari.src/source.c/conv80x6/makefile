CC            = wcc386

CFLAGS       =  /mf /d2 /4r /bt=dos4g /w2 /oe=3 /zp4 /oneatx /DPROGRAM_NAME="conv"

NAME          = conv 

LNK           = $(name).lnk

HDRS          = util.h video.h decoders.h fs2.h dither.h fs4.h

#ordered.obj

OBJS         = main.obj

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
	
