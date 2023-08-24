***********************************************
* Example Program for the use of TriMod Music *
*    Coded by Eagle of Sentry on 9.5.1992     *
*					      *
*   This Replayer is for versions from 2.5!   *
* You can play the samples by pressing on the *
*    keys 0 to 9, while playing the music!    *
***********************************************

	pea	0.w		; Super Mode
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,oldsp+2

	bclr	#0,$484.w	; key click off

	moveq	#1,d0		; use 1 for ST, 2 for fast ST and 3 for STE
	bsr	music		; Music Init.
	move.l	#music+6,$4d2.w	; Play Music

loop	move.w	#7,-(sp)	; Wait for a key
	trap	#1
	addq.w	#2,sp
	cmpi.b	#'0',d0
	blt.s	.exit
	cmpi.b	#'9',d0
	bgt.s	.exit

	sub.w	#'0',d0		; sample number (0-15)
	moveq	#-1,d1		; use default speed
	bsr	music+10	; play sample
	bra.s	loop

.exit	bsr	music+2		; Exit Music
	clr.l	$4d2.w		; Stop VBL

	bset	#0,$484.w

	move.l	#$80000,$ffff8800.w	;Volume A off
	move.l	#$90000,$ffff8800.w	;Volume B off
	move.l	#$a0000,$ffff8800.w	;Volume C off

oldsp	move.l	#$abab,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	0.w		; Exit to assembler
	trap	#1

music	incbin	f:\insignia\dba_6.mus		; change this name into yours
