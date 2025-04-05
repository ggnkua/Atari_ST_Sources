*****************************************************
*          Atari TT 16bpp CRY image viewer          *
*****************************************************
* by ray//.tSCc. <ray@tscc.de>                      *
* http://ray.tscc.de                                *
*****************************************************

		opt	d-,o+,ow+
		opt	p=68030
		comment	HEAD=%111	; TT RAM + Fastload flags on
		output	.ttp		; Command line tool


; Constants

PHYSX           =	320		; Physical screen resolution in pixels
PHYSY		=	480

;>ANTIALIAS_CR		; Uncomment this line to have the Cr channel antialiased
ANTIALIAS_Y		; Uncomment this line to have the Y channel antialiased
ANTIALIAS_PASSES	=	1

		section	text
main		bsr.w	init
		bsr.w	loadCRY		; Load image

		pea.l	0.w
		move.w	#$20,-(sp)	; Super()
		trap	#1
		addq.l	#6,sp

		moveq.l	#$12,d0		; Mouse off
		bsr.w	sendIKBD

		move.w	#$2700,sr	; Disable IRQ
		move.w	$484.w,-(sp)
		move.l	$70.w,-(sp)
		move.l	$ffff8260.w,-(sp); Save as .l for TT compatibility
		move.l	$ffff8200.w,-(sp)
		move.w	$ffff820c.w,-(sp)
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,-(sp)

		clr.b	$484.w			; Keyclick off
		move.b	#%111,$ffff8262.w	; Set 320x480x8bpp
		move.l	#vblY,$70.w	; Install interlacer as vbl handler

		move.w	#$2300,sr

		bsr.w	flush

; Wait until user presses escape

.wait		cmpi.b	#1,kbHit
		bne.s	.wait


; Restore and exit

		bsr.w	flush

		move.w	#$2700,sr
		movem.l	(sp)+,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	(sp)+,$ffff820c.w
		move.l	(sp)+,$ffff8200.w
		move.l	(sp)+,$ffff8260.w
		move.l	(sp)+,$70.w
		move.w	(sp)+,$484.w
		move.w	#$2300,sr

		moveq.l	#$8,d0		; Mouse on
		bsr.w	sendIKBD
		bsr.w	flush

exit		clr.w	-(sp)
		trap	#1



; Subs
		include	'cry.s'		; CRY processing
		include	'c2p.s'		; chunky 2 planar conversion
		include	'atari.s'	; System related
		end