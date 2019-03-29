****************************************************
* Example Program for the use of TriMod v2.1 Music *
*       Coded by Eagle of Sentry on 20.4.1992      *
* If you use fast mode at initial, you may NOT use *
*       the diskdrive! (But it is REAL FAST)       *
****************************************************

	pea	0.w			Super Mode
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	moveq	#0,d0	; Use 0 for normal mode or 1 for Fast mode
	bsr	music			Music Init.
	move.l	#music+6,$4d2.w		Play Music

	move.w	#7,-(sp)		Wait for a key
	trap	#1
	addq.w	#2,sp

	bsr	music+2			Exit Music
	clr.l	$4d2.w			Stop VBL

	move.l	#$80000,$ffff8800.w	Volume A off
	move.l	#$90000,$ffff8800.w	Volume B off
	move.l	#$a0000,$ffff8800.w	Volume C off

	pea	0.w			Exit to assembler
	trap	#1

music	incbin	tri.mus
