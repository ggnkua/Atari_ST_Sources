	bra	START

	INCLUDE	IO.S
	TEXT

START:	moveq	#-1,d0
	lea	infilename_txt,a0
	lea	buffer_buf,a1
	bsr	load

	lea	buffer_buf,a0
	lea	buffer2_buf,a1
	move.w	#200-1,d7
.loop:	REPT	256
	move.w	(a0)+,(a1)+
	ENDR
	lea	(320-256)*2(a0),a0
	dbra	d7,.loop

	move.l	#256*200*2,d0
	lea	buffer2_buf,a1
	lea	outfilename_txt,a0
	bsr	save

	clr.w	-(sp)
	trap	#1

	DATA

infilename_txt:
	DC.B	"C:\CLOUD.RAW",0
outfilename_txt:
	DC.B	"C:\FUNGLE\CLOUD.RAW",0

	BSS

	EVEN

buffer_buf:
	DS.W	320*200
buffer2_buf:
	DS.W	256*200