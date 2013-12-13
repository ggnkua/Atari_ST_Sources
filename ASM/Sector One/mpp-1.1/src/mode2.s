;---------------------------------------------------------------------
;	Multipalette routine.
;	by Zerkman / Sector One
;	mode 2: 320x199, blitter based, displays 56 colors per scanline
;		with uniform repartition of color change positions.
;---------------------------------------------------------------------

; Copyright (c) 2012-2013 Francois Galea <fgalea at free.fr>
; This program is free software. It comes without any warranty, to
; the extent permitted by applicable law. You can redistribute it
; and/or modify it under the terms of the Do What The Fuck You Want
; To Public License, Version 2, as published by Sam Hocevar. See
; the COPYING file or http://www.wtfpl.net/ for more details.

; Plugin header.
m2_begin:
	dc.w	320			; width
	dc.w	199			; height
	dc.w	64			; colors per scanline
	dc.w	54			; stored colors per scanline
	dc.w	160			; physical screen line size in bytes
	dc.w	100			; timer A data
	dc.w	1			; STe only
m2_pal:	dc.l	0			; palette address
	bra.w	m2_init
	bra.w	m2_palette_unpack
m2_tab:	bra.w	m2_timera1


; Palette unpacking.
; a0: destination unpacked palette
; a5: get_color function
; d5-d7/a4-a6 : reserved for get_color function
m2_palette_unpack:
	move	#198,d2			; line counter
m2_pu_newline:
	clr	(a0)+			; set color 0 to black
	moveq	#54,d1			; 56 colors per line, -2 always black
m2_pu_newcol:
	cmp	#7,d1
	bne.s	m2_pu_no48
	clr	(a0)+			; set color 48 to black
	subq	#1,d1			; next color

m2_pu_no48:
	jsr	(a5)
	move	d0,(a0)+
	dbra	d1,m2_pu_newcol

	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d2,m2_pu_newline
	rts


; Init routine.
; a0: file structure address
; a1: destination palette
m2_init:
	move.b	#2,$ffff820a.w
	clr.b	$ffff8260.w

	move	#2,$ffff8a20.w		; source X increment
	move	#2,$ffff8a22.w		; source Y increment
	move	#-1,$ffff8a28.w	; Endmask 1 (first write of a line)
	move	#-1,$ffff8a2a.w	; Endmask 2 (all other writes of a line)
	move	#-1,$ffff8a2c.w	; Endmask 3 (last write of a line)
	move	#2,$ffff8a2e.w		; destination X increment
	move	#-30,$ffff8a30.w	; destination Y increment
	move	#16,$ffff8a36.w	; words per line in bit-block
	move.b	#2,$ffff8a3a.w		; halftone operation (2=source)
	move.b	#3,$ffff8a3b.w		; logical operation (3=source)
	move.b	#0,$ffff8a3d.w		; skew

	rts

m2_timera1:

m2_tstsync0:
	move.b	$ffff8209.w,d0
	beq.s	m2_tstsync0
	eor	#$f,d0
	lsr.l	d0,d0

	move.l	m2_pal(pc),$ffff8a24.w	; source address register
	move.l	#$ffff8240,$ffff8a32.w	; destination address register

	move	#1,$ffff8a38.w		; y count
	move.b	#$c0,$ffff8a3c.w	; line number register = busy, hog bus

	move.b	$ffff8209.w,d0
	cmp.b	#$90,d0
	beq.s	m2_ts0ste

; Mega STE blitter detected. Blitter must be started 4 cycles before STE timing.
	lea	m2_stetm(pc),a0
	move	#$4e71,(a0)		; change or.l (8 cycles) with nop (4 cycles)

m2_ts0ste:
	lea	m2_timer_a(pc),a0
	lea	m2_tab+2(pc),a1
	sub.l	a1,a0
	move.w	a0,(a1)
	rts

m2_timer_a:

m2_tstsync:
	move.b	$ffff8209.w,d0
	beq.s	m2_tstsync
	neg.b	d0
	lsr.l	d0,d0

	move.l	m2_pal(pc),$ffff8a24.w	; source address register
	move.l	#$ffff8240,$ffff8a32.w	; destination address register
m2_stetm:
	rept	20
	or.l	d0,d0
	endr
	move	#796,$ffff8a38.w	; y count (HBL=63, LineCycles=428)
	move.b	#$c0,$ffff8a3c.w	; line number register = busy, hog bus
	rts
