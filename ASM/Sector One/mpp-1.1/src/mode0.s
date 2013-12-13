;---------------------------------------------------------------------
;	Multipalette routine.
;	by Zerkman / Sector One
;	mode 0: 320x199, CPU based, displays 54 colors per scanline
;		with non-uniform repartition of color change positions.
;---------------------------------------------------------------------

; Copyright (c) 2012-2013 Francois Galea <fgalea at free.fr>
; This program is free software. It comes without any warranty, to
; the extent permitted by applicable law. You can redistribute it
; and/or modify it under the terms of the Do What The Fuck You Want
; To Public License, Version 2, as published by Sam Hocevar. See
; the COPYING file or http://www.wtfpl.net/ for more details.

; Plugin header.
m0_begin:
	dc.w	320			; width
	dc.w	199			; height
	dc.w	54			; colors per scanline
	dc.w	52			; stored colors per scanline
	dc.w	160			; physical screen line size in bytes
	dc.w	100			; timer A data
	dc.w	0			; default flags
m0_pal:	dc.l	0			; palette address
	bra.w	m0_init
	bra.w	m0_palette_unpack
m0_tab:	bra.w	m0_timera1


; Palette unpacking.
; a0: destination unpacked palette
; a5: get_color function
; d5-d7/a4-a6 : reserved for get_color function
m0_palette_unpack:
	move	#198,d2			; line counter
m0_pu_newline:
	clr	(a0)+			; set color 0 to black
	moveq	#51,d1			; 54 colors per line, -2 always black
m0_pu_newcol:
	cmp	#36,d1
	bne.s	m0_no16			; start 16th color at position 22
	lea	12(a0),a0
m0_no16:
	cmp	#4,d1
	bne.s	m0_pu_no48
	lea	-64-12(a0),a0
	clr	(a0)+			; set color 32 to black

m0_pu_no48:
	jsr	(a5)
	move	d0,(a0)+
	dbra	d1,m0_pu_newcol
	lea	64(a0),a0
	dbra	d2,m0_pu_newline
	rts


; Init routine.
; a0: file structure address
; a1: destination palette
m0_init:
	move.b	#2,$ffff820a.w
	clr.b	$ffff8260.w

	rts

m0_timera1:
m0_tstsync0:
	move.b	$ffff8209.w,d0
	beq.s	m0_tstsync0
	neg.b	d0
	lsr.l	d0,d0

	move.l	m0_pal(pc),a0
	lea	$ffff8240.w,a1
	move	#198,d0

	rept	23+8
	nop
	endr

m0_spcbcl:
	movem.l	(a0)+,d2-d7/a2-a6	; 12+11*8 = 100
	movem.l	d2-d7/a2-a3,(a1)	; 8+8*8 = 72
	movem.l	(a0)+,d2-d7/a2-a3	; 12+8*8 = 76
	movem.l	d2-d7/a2-a3,(a1)	; 8+8*8 = 72
	movem.l	(a0)+,d2-d7/a2-a3	; 12+8*8 = 76
	movem.l	d2-d7/a2-a3,(a1)	; 8+8*8 = 72
	movem.l	a4-a6,(a1)		; 8+3*8 = 32  = 500 (54 colors)

	dbra	d0,m0_spcbcl

	rts
