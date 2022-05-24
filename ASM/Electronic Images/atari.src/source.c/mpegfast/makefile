CC            = wcc386

CFLAGS       =  /mf /d2 /4r /bt=nt /w2 /oe=15 /oneatx /zp4 /dNO_SANITY_CHECKS /dNO_LRAND48 /dNDEBUG /dBSD  

# -DSH_MEM

NAME          = mpegplay

LNK           = $(name).lnk

HDRS          = util.h video.h decoders.h fs2.h dither.h fs4.h

#ordered.obj

OBJS         = display.obj mpeg2dec.obj spatscal.obj getblk.obj gethdr.obj getpic.obj getvlc.obj getbits.obj idct.obj motion.obj recon.obj  

SRCS          = 

$(name).exe :   $(OBJS) $(LNK)
		wlink @$(LNK)

.c.obj :
	$(CC) $(CFLAGS) $[*
    
$(LNK) : makefile 
    %create $(LNK)
    @%append $(LNK) debug all
    @%append $(LNK) sys dos4gw 
    @%append $(LNK) name $(name)
    @for %i in ($(OBJS)) do @%append $(LNK) file %i
	
