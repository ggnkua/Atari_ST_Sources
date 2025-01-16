; This source code and music ripping by Zippy (TMB)
; This source plays back the Jambala Sample/Soundchip music
; Change the 'moveq #2,d0' to 'moveq #1,d0' for the other tune !!
;
; Zippy
;
	opt s-
super	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	lea 6(sp),sp
	move.l d0,oldstk
click	bclr #0,$484.w
reloc	move.l #(music+$1af0),(music+$1e)
	move.l #(music+$34e0),(music+$a4)
	move.l #(music+$8b0),(music+$202)
	move.l #(music+$8b0),(music+$87c)
	move.l $70.w,oldint
num	moveq #2,d0
init	bsr music	
ints	bsr (music+8)
	move.l #int,$70.w
wait	move.w #7,-(sp)
	trap #1
	lea 2(sp),sp
off	bsr (music+12)
	move.l oldint,$70.w
	bset #0,$484
user	move.l oldstk,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp  
term	clr.w -(sp)
	trap #1
int	movem.l d0-d7/a0-a6,-(sp)
	bsr (music+4)
	movem.l (sp)+,d0-d7/a0-a6
	move.l oldint,-(sp)
	rts
oldstk	dc.l 0
oldint	dc.l 0
music	incbin "jambala.mus"
