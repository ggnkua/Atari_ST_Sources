CC            = wcc386

CFLAGS       =  /mf /d2 /4r /bt=dos4g /w2 /oe=3 /zp4 /oneatx /dNO_SANITY_CHECKS /dNO_LRAND48 /dNDEBUG /dBSD  

# -DSH_MEM

NAME          = mpegplay

LNK           = $(name).lnk

HDRS          = util.h video.h decoders.h fs2.h dither.h fs4.h

#ordered.obj

OBJS         = ordered.obj ordered2.obj mb_order.obj fs2.obj fs2fast.obj fs4.obj hybrid.obj 2x2.obj gray.obj mono.obj 24bit.obj parseblo.obj jrevdct.obj motionve.obj decoders.obj hybrider.obj video.obj util.obj gdith.obj main.obj   

SRCS          = util.c video.c parseblo.c motionve.c decoders.c &
		main.c gdith.c fs2.c fs2fast.c fs4.c hybrid.c hybrider.c &
		2x2.c gray.c mono.c jrevdct.c 24bit.c ordered.c &
		ordered2.c mb_order.c 

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
	
