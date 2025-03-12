*** Ghostbusters sort of music
***
*** Ripped by MAC SYS DATA from KGB (France)
***
*** Mad Max jobby!!!
***
***
***
	clr.l -(sp)				dummy
	move.w #$20,-(sp)			super mode
	trap #1					call gemdos
	lea 6(sp),sp				correct stack
	move.l d0,oldstk			save old sp
	bclr #0,$484.w				no keyclick

	bsr on

	move.w #7,-(sp)				wait key
	trap #1					call gemdos
	lea 2(sp),sp				correct stack

	bsr off

	move.l oldstk,-(sp)			back into
	move.w #$20,-(sp)			user mode
	trap #1					call gemdos
	lea 6(sp),sp  				correct stack
	clr.w -(sp)				terminate
	trap #1					call gemdos

isr	movem.l d0-a6,-(sp)			save registers
	bsr (music+8)				call playback
	movem.l (sp)+,d0-a6			restore registers
	move.l oldint,-(sp)			old vbl on sp
	rts					call old vbl

on	move.l $70.w,oldint			save old vbl
	moveq #1,d0				music #1
	bsr music				call init
	move.l #isr,$70.w			install new vbl
	rts

off	move.l oldint,$70.w			restore old vbl
	move.l #$08080000,$ff8800		clear vol. chan A
	move.l #$09090000,$ff8800		clear vol. chan B
	move.l #$0a0a0000,$ff8800		clear vol. chan C
	rts

oldstk	dc.l 0
oldint	dc.l 0
music	incbin "ghost.mus"			change this filename !!
