	opt s-
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,oldstk
	bclr #0,$484
	move.l $70,oldint
	move.l #music+$45ec,music+$22c6
	move.l #music+$49ec,music+$22ca
	moveq #0,d0
	bsr music
	bsr music+8
	move.l #int,$70
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	moveq #-1,d0
	bsr music
	bsr music+$c
	move.l oldint,$70
	bset #0,$484
	move.l oldstk,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp  
	clr.w -(sp)
	trap #1
int	movem.l d0-d7/a0-a6,-(sp)
	bsr (music+$22)
	movem.l (sp)+,d0-d7/a0-a6
	move.l oldint,-(sp)
	rts
oldstk	dc.l 0
oldint	dc.l 0
music	incbin "f:\monster.mus"
