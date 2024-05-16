; Music by (N)o-more of Animal Mine

; Music :-

; Supplied by (N)o-more to me then onto you lot!!

; N.B. Not all the music is present in these released files as I have been
; asked by (N)o-more not to spread them yet!!

; A lot of files available.  See end of code

; Very, Very, Very, Very, Very, Very, Very, Very, GOOD music this!!! 
;;;; uses timera!!

	pea	0.w		; Super Mode
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	move.b	#2,$484.w	; key click off

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

	move.l	#$80000,$ffff8800.w	;Volume A off
	move.l	#$90000,$ffff8800.w	;Volume B off
	move.l	#$a0000,$ffff8800.w	;Volume C off

	pea	0.w		; Exit to assembler
	trap	#1

music	
	;incbin	POW*.*		;music-filename
	incbin	SENSETOR.MUS
	;incbin	WOTS_3D?.MUS
	;incbin trsi1.mus 

