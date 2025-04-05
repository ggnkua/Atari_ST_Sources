; To call the different tunes available from each music file, just change
; the '1' in the line 'moveq #1,d0' (line 14) to whatever music number you
; want.  Oh yes, my tabs are set at 8 !!!
;
;
	opt s-					no symbols
	clr.l -(sp)				dummy
	move.w #$20,-(sp)			super mode
	trap #1					call dos
	addq.l #6,sp				correct stack
	move.l d0,oldstk			save old sp
	move.l $70.w,oldint			save old vbl
	bclr #0,$484.w				no keyclick
	moveq #1,d0				music #1
	bsr music				call init
	move.l #thane,$70.w			install new vbl
	addq.l #2,sp				correct stack
	move.l oldstk,-(sp)			back into
	move.w #$20,-(sp)			user mode
	trap #1					call dos
	addq.l #6,sp  				correct stack
	clr.w -(sp)				terminate
	pea $5000				and
	move.w #$31,-(sp)			stay
	trap #1					resident
thane	movem.l d0-a6,-(sp)			save registers
	bsr (music+4)				call playback
	movem.l (sp)+,d0-a6			restore registers
	move.l oldint,-(sp)			old vbl on sp
	rts					call old vbl
oldstk	dc.l 0
oldint	dc.l 0
music	incbin "\music.acf"			change this filename

