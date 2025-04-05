; Falcon demosystem
;
; fade.s
;
; Misc routines for use in bitplane modes


		section	text

;-----------------------------------------------------------------------
falcon_setpal:

; Falcon palette setter
;
; January 19, 2000
; Anders Eriksson
; ae@dhs.nu
;
; in:	a0 = address to palette in falcon rg-b format
;	d0.w = number of colours

		lea	$ffff9800.w,a1
		subq.w	#1,d0
.loop:		move.l	(a0)+,(a1)+
		dbra	d0,.loop
		rts


;-----------------------------------------------------------------------
falcon_fade:

; Falcon 18bit faderoutine
;
; January 19, 2000
; Anders Eriksson
; ae@dhs.nu
;
; in:	a0 = startpalette (falcon rg-b format)
;	a1 = endpalette (falcon rg-b format)
;	d0.w = number of colours
;
; out:	startpalette overwritten one step faded against endpalette

		move.w	d0,d7						;remove eventual 21/24bit
		move.l	a0,a2						;palette details
		move.l	a1,a3						;
 		move.l	#%11111100111111001111111111111100,d1		;
.mask:		and.l	d1,(a2)+					;
		and.l	d1,(a3)+					;
		dbra	d7,.mask					;

		move.w	d0,d7						;colours
		subq.w	#1,d7

		clr.l	d0						;clear dregs
		clr.l	d1
		clr.l	d2
		clr.l	d3
		clr.l	d4
		clr.l	d5

.colour:	move.b	(a0),d0						;source
		move.b	1(a0),d1					;
		move.b	3(a0),d2					;

		move.b	(a1)+,d3					;dest
		move.b	(a1)+,d4					;
		addq.l	#1,a1						;
		move.b	(a1)+,d5					;

.red:		cmp.l	d0,d3
		beq.s	.green
		bgt.s	.redadd
.redsub:	subq.b	#4,d0
		bra.s	.green
.redadd:	addq.b	#4,d0

.green:		cmp.l	d1,d4
		beq.s	.blue
		bgt.s	.greenadd
.greensub:	subq.b	#4,d1
		bra.s	.blue
.greenadd:	addq.b	#4,d1

.blue:		cmp.l	d2,d5
		beq.s	.mix
		bgt.s	.blueadd
.bluesub:	subq.b	#4,d2
		bra.s	.mix
.blueadd:	addq.b	#4,d2

.mix:		move.b	d0,(a0)+
		move.b	d1,(a0)+
		addq.l	#1,a0
		move.b	d2,(a0)+

		dbra	d7,.colour
		rts
		



;-----------------------------------------------------------------------
conv_apxpal_to_falcpal:

; Converts apex block palette format to falcon palette format
;
; January 19, 2000
; Anders Eriksson
; ae@dhs.nu
;
; in:	a0 = source apx palette (apx file +20)
;	a1 = dest buffer (1024 bytes)

		move.w	#256-1,d7
.loop:		move.w	(a0)+,(a1)
		move.b	(a0)+,3(a1)
		addq.l	#4,a1
		dbra	d7,.loop
		rts


;-----------------------------------------------------------------------
conv_tgapal_to_falcpal:

; Converts Targa 256-colour palette format to falcon palette format
;
; April 18, 2009
; Anders Eriksson
; ae@dhs.nu
;
; in:	a0 = source tga palette (tga file +18)
;	a1 = dest buffer (1024 bytes)

		move.w	#256-1,d7
.loop:	
		move.b	0(a0),3(a1)
		move.b	1(a0),1(a1)
		move.b	2(a0),0(a1)
		addq.l	#3,a0
		addq.l	#4,a1
		dbra	d7,.loop
		rts


;-----------------------------------------------------------------------
conv_bmppal_to_falcpal:

; Converts BMP 256-colour palette format to falcon palette format
;
; April 18, 2009
; Anders Eriksson
; ae@dhs.nu
;
; in:	a0 = source bmp palette (bmp file +54)
;	a1 = dest buffer (1024 bytes)

		move.w	#256-1,d7
.loop:	
		move.b	0(a0),3(a1)
		move.b	1(a0),1(a1)
		move.b	2(a0),0(a1)
		addq.l	#4,a0
		addq.l	#4,a1
		dbra	d7,.loop
		rts





;-----------------------------------------------------------------------
conv_apx8plane_to_falc8plane:

; Converts apex bitplane screen to falcon bitplanescreen
;
; January 19, 2000
; Anders Eriksson
; ae@dhs.nu
;
; in:	a0 = source of pic (apexpic+788)
;	d0.w = x pixels (even by 16)
;	d1.w = y lines

		lsr.w	#4,d0					;x/16
		subq.w	#1,d0					;x-1
		subq.w	#1,d1					;y-1

		move.l	a0,a1					;source=dest

.y:		move.w	d0,d2
.x:		addq.l	#2,a0					;s+2
		rept	4
		move.l	(a0)+,(a1)+				;16bytes
		endr
		dbra	d2,.x
		dbra	d1,.y
		rts

		section	text

