;---------------------------------------------------------------------
;	Multipalette routine.
;	by Zerkman / Sector One
;	mode 1: 320x199, CPU based, displays 48 colors per scanline
;		with uniform repartition of color change positions.
;---------------------------------------------------------------------

; Copyright (c) 2012-2013 Francois Galea <fgalea at free.fr>
; This program is free software. It comes without any warranty, to
; the extent permitted by applicable law. You can redistribute it
; and/or modify it under the terms of the Do What The Fuck You Want
; To Public License, Version 2, as published by Sam Hocevar. See
; the COPYING file or http://www.wtfpl.net/ for more details.

; Plugin header.
m1_begin:
	dc.w	320			; width
	dc.w	199			; height
	dc.w	48			; colors per scanline
	dc.w	46			; stored colors per scanline
	dc.w	160			; physical screen line size in bytes
	dc.w	100			; timer A data
	dc.w	0			; default flags
m1_pal:	dc.l	0			; palette address
	bra.w	m1_init
	bra.w	m1_palette_unpack
m1_tab:	bra.w	m1_timera1


; Palette unpacking.
; a0: destination unpacked palette
; a5: get_color function
; d5-d7/a4-a6 : reserved for get_color function
m1_palette_unpack:
	move	#198,d2			; line counter
m1_pu_newline:
	clr	(a0)+			; set color 0 to black
	moveq	#46,d1			; 48 colors per line, -2 always black
m1_pu_newcol:
	cmp	#15,d1
	bne.s	m1_pu_no48
	clr	(a0)+			; set color 32 to black
	subq	#1,d1			; next color

m1_pu_no48:
	jsr	(a5)
	move	d0,(a0)+
	dbra	d1,m1_pu_newcol
	dbra	d2,m1_pu_newline
	rts


; Init routine.
; a0: file structure address
; a1: destination palette
m1_init:
	move.b	#2,$ffff820a.w
	clr.b	$ffff8260.w

	rts

m1_timera1:
m1_tstsync0:
	move.b	$ffff8209.w,d0
	beq.s	m1_tstsync0
	neg.b	d0
	lsr.l	d0,d0

	move.l	m1_pal(pc),a0
	lea	$ffff8240.w,a1
	move	#198,d0

	rept	43
	nop
	endr

m1_spcbcl:
	move.l	a1,a2		; 4
	move.l	a1,a3		; 4
	move.l	a1,a4		; 4
	rept	8
	move.l	(a0)+,(a2)+	; 20*8 = 160
	endr
	rept	8
	move.l	(a0)+,(a3)+	; 20*8 = 160
	endr
	rept	8
	move.l	(a0)+,(a4)+	; 20*8 = 160
	endr
	rept	2
	nop			; 2*2 = 4
	endr

	dbra	d0,m1_spcbcl

	rts
