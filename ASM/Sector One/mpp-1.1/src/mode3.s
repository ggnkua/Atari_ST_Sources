;---------------------------------------------------------------------
;	Multipalette routine.
;	by Zerkman / Sector One
;	mode 3: 416x273, CPU based, displays 48+6 colors per scanline
;		with overscan and non-uniform repartition of color changes.
;---------------------------------------------------------------------

; Copyright (c) 2012-2013 Francois Galea <fgalea at free.fr>
; This program is free software. It comes without any warranty, to
; the extent permitted by applicable law. You can redistribute it
; and/or modify it under the terms of the Do What The Fuck You Want
; To Public License, Version 2, as published by Sam Hocevar. See
; the COPYING file or http://www.wtfpl.net/ for more details.

naupe	macro	1
	rept	\1/2
	or.l	d0,d0
	endr
	rept	\1%2
	nop
	endr
	endm

; Plugin header.
m3_begin:
	dc.w	416			; width
	dc.w	273			; height
	dc.w	48			; colors per scanline
	dc.w	48			; stored colors per scanline
	dc.w	230			; physical screen line size in bytes
	dc.w	97 			; timer A data
	dc.w	0			; default flags
m3_pal:	dc.l	0			; palette address
	bra.w	m3_init
	bra.w	m3_palette_unpack
m3_tab:	bra.w	m3_timera1


; Palette unpacking.
; a0: destination unpacked palette
; a5: get_color function
; d5-d7/a4-a6 : reserved for get_color function
m3_palette_unpack:
	move	#272,d2			; line counter
m3_pu_newline:
	moveq	#47,d1			; 48 colors per line
m3_pu_newcol:
	jsr	(a5)
	move	d0,(a0)+
	dbra	d1,m3_pu_newcol
	dbra	d2,m3_pu_newline
	rts

; Init routine.
; a0: file structure address
; a1: destination palette
m3_init:
	move.b	#2,$ffff820a.w
	clr.b	$ffff8260.w

	rts

m3_timera1:
	move	#$2100,sr
	stop	#$2100
	move	#$2700,sr

; top border HBL=33, LineCycles=452~460
	naupe	90
	clr.b	$ffff820a.w
	naupe	11
	move.b	#2,$ffff820a.w
	move.l	a7,usp

m3_tstsync0:
	move.b	$ffff8209.w,d0
	beq.s	m3_tstsync0
	neg.b	d0
	lsr.l	d0,d0

	move.l	m3_pal(pc),a0
	lea	$ffff8240.w,a1

	lea	$ffff820a.w,a2
	lea	$ffff8260.w,a3
	lea	$ffff824c.w,a7
	naupe	36
	movem.l	(a0)+,d1-d5
	movem.l	d1-d5,(a7)

	rept	227
	move	a3,(a3)		; LineCycles = 508 -> 4
	nop
	move.b	d0,(a3)		; LineCycles = 8 -> 16
	movem.l	(a0)+,d2-d7/a4-a5	; 19
	movem.l	d2-d7/a4-a5,(a1)	; 18
	movem.l	(a0)+,d0-d7/a4-a6	; 25
	movem.l	d0-d7,(a1)		; 18
	movem.l	a4-a6,(a1)		; 8
	moveq	#0,d0		; LineCycles = 368 -> 372
	move.b	d0,(a2)		; LineCycles = 372 -> 380
	move	a2,(a2)		; LineCycles = 380 -> 388
	movem.l	(a0)+,d1-d5	; 13
	move	a3,(a3)		; LineCycles = 440 -> 448
	nop
	move.b	d0,(a3)		; LineCycles = 452 -> 460
	movem.l	d1-d5,(a7)	; 12
	endr

	move	a3,(a3)		; LineCycles = 508 -> 4
	nop
	move.b	d0,(a3)		; LineCycles = 8 -> 16
	movem.l	(a0)+,d2-d7/a4-a5	; 19
	movem.l	d2-d7/a4-a5,(a1)	; 18
	movem.l	(a0)+,d0-d7/a4-a6	; 25
	movem.l	d0-d7,(a1)		; 18
	movem.l	a4-a6,(a1)		; 8
	moveq	#0,d0		; LineCycles = 368 -> 372
	move.b	d0,(a2)		; LineCycles = 372 -> 380
	move	a2,(a2)		; LineCycles = 380 -> 388
	movem.l	(a0)+,d1-d5	; 13
	move	a3,(a3)		; LineCycles = 440 -> 448
	nop
	move.b	d0,(a3)		; LineCycles = 452 -> 460
	move.b	d0,(a2)
	movem.l	d1-d3,(a7)	; 8
	move	a2,(a2)

	rept	44
	move	a3,(a3)		; LineCycles = 508 -> 4
	nop
	move.b	d0,(a3)		; LineCycles = 8 -> 16
	movem.l	(a0)+,d2-d7/a4-a5	; 19
	movem.l	d2-d7/a4-a5,(a1)	; 18
	movem.l	(a0)+,d0-d7/a4-a6	; 25
	movem.l	d0-d7,(a1)		; 18
	movem.l	a4-a6,(a1)		; 8
	moveq	#0,d0		; LineCycles = 368 -> 372
	move.b	d0,(a2)		; LineCycles = 372 -> 380
	move	a2,(a2)		; LineCycles = 380 -> 388
	movem.l	(a0)+,d1-d5	; 13
	move	a3,(a3)		; LineCycles = 440 -> 448
	nop
	move.b	d0,(a3)		; LineCycles = 452 -> 460
	movem.l	d1-d5,(a7)	; 12
	endr

	move	a3,(a3)		; LineCycles = 508 -> 4
	nop
	move.b	d0,(a3)		; LineCycles = 8 -> 16
	movem.l	(a0)+,d2-d7/a4-a5	; 19
	movem.l	d2-d7/a4-a5,(a1)	; 18
	movem.l	(a0)+,d0-d7/a4-a6	; 25
	movem.l	d0-d7,(a1)		; 18
	movem.l	a4-a6,(a1)		; 8
	moveq	#0,d0		; LineCycles = 368 -> 372
	move.b	d0,(a2)		; LineCycles = 372 -> 380
	move	a2,(a2)		; LineCycles = 380 -> 388
	naupe	4
	rept	3
	clr.l	(a1)+
	endr
	move	a3,(a3)		; LineCycles = 440 -> 448
	nop
	move.b	d0,(a3)		; LineCycles = 452 -> 460

	rept	5
	clr.l	(a1)+
	endr

	move.l	usp,a7
	move	#$2300,sr
	rts
