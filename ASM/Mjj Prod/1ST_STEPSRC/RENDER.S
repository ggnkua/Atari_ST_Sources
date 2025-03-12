;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; RENDER.S : rendering
;  need	TABLES.S
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================

;-----------------------------------------------------------------------------
; surf_clear : clear surface
;	args :	d0 = width in words
;			d1 = height
;			d2 = padding
;			a0 = ptr
;-----------------------------------------------------------------------------

surf_clear:
	movem.l		d3-d4/a1,		-(sp)
	lea			$FFFF8A20.W,	a1
	moveq		#2,				d3
	moveq		#-1,			d4
	move.w		d3,				(a1)+		; source X increment
	move.w		d3,				(a1)+		; source Y increment
	move.l		a0,				(a1)+		; source address
	move.l		d4,				(a1)+		; mask 1 & 2
	move.w		d4,				(a1)+		; mask 3
	move.w		d3,				(a1)+		; destination X increment
	add.w		d2,				d3
	move.w		d3,				(a1)+		; destination Y increment
	move.l		a0,				(a1)+		; destination address
	move.w		d0,				(a1)+		; surface width
	move.w		d1,				(a1)+		; surface height
	move.w		#$0200,			(a1)+		; mode
	move.w		#$C000,			(a1)		; start
	nop
	movem.l		(sp)+,			d3-d4/a1
	rts

;-----------------------------------------------------------------------------
; bplan_clear2 : clear bitplan
;	args :	d0 = width in words
;			d1 = height
;			d2 = padding
;			a0 = ptr
;-----------------------------------------------------------------------------

bplan_clear2:
	movem.l		d3-d4/a1,			-(sp)
	lea			$FFFF8A20.W,	a1
	moveq		#2,				d3
	moveq		#-1,			d4
	move.w		d3,				(a1)+		; source X increment
	move.w		d3,				(a1)+		; source Y increment
	move.l		a0,				(a1)+		; source address
	move.l		d4,				(a1)+		; mask 1 & 2
	move.w		d4,				(a1)+		; mask 3
	move.w		d3,				(a1)+		; destination X increment
	add.w		d2,				d3
	move.w		d3,				(a1)+		; destination Y increment
	move.l		a0,				(a1)+		; destination address
	move.w		d0,				(a1)+		; surface width
	move.w		d1,				(a1)+		; surface height
	move.w		#$0200,			(a1)+		; mode
	move.w		#$C000,			(a1)		; start
	nop
	movem.l		(sp)+,			d3-d4/a1
	rts

;-----------------------------------------------------------------------------
; bplan_clear8 : clear bitplan in surface
;	args :	d0 = width in words
;			d1 = height
;			d2 = padding
;			a0 = ptr
;-----------------------------------------------------------------------------

bplan_clear8:
	movem.l		d3-d4/a1,			-(sp)
	lea			$FFFF8A20.W,	a1
	moveq		#8,				d3
	moveq		#-1,			d4
	move.w		d3,				(a1)+		; source X increment
	move.w		d3,				(a1)+		; source Y increment
	move.l		a0,				(a1)+		; source address
	move.l		d4,				(a1)+		; mask 1 & 2
	move.w		d4,				(a1)+		; mask 3
	move.w		d3,				(a1)+		; destination X increment
	add.w		d2,				d3
	move.w		d3,				(a1)+		; destination Y increment
	move.l		a0,				(a1)+		; destination address
	move.w		d0,				(a1)+		; surface width
	move.w		d1,				(a1)+		; surface height
	move.w		#$0200,			(a1)+		; mode
	move.w		#$C000,			(a1)		; start
	nop
	movem.l		(sp)+,			d3-d4/a1
	rts

;-----------------------------------------------------------------------------
; bplan_copy : copy bitplan to bitplan
;	args :	d0 = width in words
;			d1 = height
;			d2 = padding
;			a0 = src
;			a1 = dst
;-----------------------------------------------------------------------------

bplan_copy:
	movem.l		d3-d4/a2,			-(sp)
	lea			$FFFF8A20.W,	a2
	moveq		#2,				d3
	moveq		#-1,			d4
	move.w		d3,				(a2)+		; source X increment
	move.w		d3,				(a2)+		; source Y increment
	move.l		a0,				(a2)+		; source address
	move.l		d4,				(a2)+		; mask 1 & 2
	move.w		d4,				(a2)+		; mask 3
	move.w		d3,				(a2)+		; destination X increment
	add.w		d2,				d3
	move.w		d3,				(a2)+		; destination Y increment
	move.l		a1,				(a2)+		; destination address
	move.w		d0,				(a2)+		; surface width
	move.w		d1,				(a2)+		; surface height
	move.w		#$0203,			(a2)+		; mode
	move.w		#$C000,			(a2)		; start
	nop
	movem.l		(sp)+,			d3-d4/a2
	rts

;-----------------------------------------------------------------------------
; bplan_blit : copy bitplan to surface
;	args :	d0 = width in words
;			d1 = height
;			d2 = shift
;			d3 = mode
;			d4 = padding
;			a0 = src
;			a1 = dst
;-----------------------------------------------------------------------------

bplan_blit:
	movem.l		d5/a2-a4,		-(sp)
	lea			$FFFF8A20.W,	a2
	lea			xlmsk_table,	a3
	lea			xrmsk_table,	a4
	moveq		#2,				d5
	move.w		d5,				(a2)+		; source X increment
	move.w		d5,				(a2)+		; source Y increment
	move.l		a0,				(a2)+		; source address
	move.w		d2,				d5
	add.w		d5,				d5
	move.w		0(a3,d5.w),		(a2)+		; left mask
	move.w		#$FFFF,			(a2)+		; middle mask
	move.w		0(a4,d5.w),		(a2)+		; right mask
	moveq		#8,				d5
	move.w		d5,				(a2)+		; destination X increment
	move.w		d4,				(a2)+		; destination Y increment
	move.l		a1,				(a2)+		; destination address
	move.w		d0,				d5
	addq.w		#1,				d5
	move.w		d5,				(a2)+		; surface width
	move.w		d1,				(a2)+		; surface height
	move.w		d3,				(a2)+		; mode
	move.w		#$C040,			d5			; shift mode
	or.w		d2,				d5          ; shift
	move.w		d5,				(a2)		; start
	nop
	movem.l		(sp)+,			d5/a2-a4
	rts

;-----------------------------------------------------------------------------
; bplan_zoom : vert zoom a bitplan to surface ?
;	args :	d0 = width in words
;			d1 = dst height (src height = 256)
;			d2 = shift
;			d3 = mode
;			d4 = padding
;			a0 = src
;			a1 = dst
;-----------------------------------------------------------------------------

bplan_zoom:
	movem.l		d1-d7/a0-a6,	-(sp)
	lea			$FFFF8A20.W,	a2
	lea			xlmsk_table,	a3
	lea			xrmsk_table,	a4
	moveq		#2,				d5
	move.w		d5,				(a2)+		; source X increment
	move.w		d5,				(a2)+		; source Y increment
	
	move.l		a2,				a5			; a5 = source reg ptr
	addq.w		#4,				a2

	move.w		d2,				d5
	add.w		d5,				d5
	move.w		0(a3,d5.w),		(a2)+		; left mask
	move.w		#$FFFF,			(a2)+		; middle mask
	move.w		0(a4,d5.w),		(a2)+		; right mask
	moveq		#8,				d5
	move.w		d5,				(a2)+		; destination X increment
	move.w		d4,				(a2)+		; destination Y increment
	move.l		a1,				(a2)+		; destination address

	move.w		d0,				d4
	addq.w		#1,				d4
	swap		d4
	move.w		#1,				d4			; d4 = surface size
	move.l		a2,				a6			; a6 = surface size reg ptr
	addq.w		#4,				a2

	move.w		d3,				(a2)+		; mode
	move.w		#$C040,			d5			; shift mode
	or.w		d2,				d5          ; shift

	moveq		#1,				d6
	swap		d6							; 256 * 256
	divu.w		d1,				d6			; / height
	ext.l		d6
	moveq		#0,				d3
	moveq		#0,				d2
	moveq		#-32,			d7

	move.l		a0,				(a5)		; source
	move.l		d4,				(a6)		; size
	move.w		#6,				2(a6)
	move.w		d5,				(a2)		; start
	move.l		a0,				(a5)		; source
	move.l		d4,				(a6)		; size
	move.w		#5,				2(a6)
	move.w		d5,				(a2)		; start
	lea			288(a0),		a0
	
	tst.w		bubbles_inter
	beq.s		bplan_zoom_0
	add.w		d6,				d3
	lsr.w		#1,				d3
	move.w		d3,				d2
	lsr.w		#3,				d2
	and.w		d7,				d2

bplan_zoom_0:
	lea			0(a0,d2),		a1			; source
	move.l		a1,				(a5)
	move.l		d4,				(a6)		; size
	move.w		d5,				(a2)		; start
	add.w		d6,				d3
	move.w		d3,				d2
	lsr.w		#3,				d2
	and.w		d7,				d2
	dbra		d1,bplan_zoom_0

	lea			-288(a0),		a0
	move.l		a0,				(a5)		; source
	move.l		d4,				(a6)		; size
	move.w		#10,			2(a6)
	move.w		d5,				(a2)		; start
	move.l		a0,				(a5)		; source
	move.l		d4,				(a6)		; size
	move.w		#4,				2(a6)
	move.w		d5,				(a2)		; start

	movem.l		(sp)+,			d1-d7/a0-a6
	rts

;-----------------------------------------------------------------------------
; bplan_scroll : scroll bitplan to surface
;	args :	d0 = src padding
;			d1 = height
;			d2 = shift
;			d3 = mode
;			d4 = padding
;			a0 = src
;			a1 = dst
;-----------------------------------------------------------------------------

bplan_scroll:
	movem.l		d4-d5/a2-a4,	-(sp)
	lea			$FFFF8A20.W,	a2
	moveq		#2,				d5
	move.w		d5,				(a2)+		; source X increment
	move.w		d0,				(a2)+		; source Y increment
	move.l		a0,				(a2)+		; source address
	moveq		#-1,			d5
	move.l		#$FFFF,			(a2)+		; mask 1 & 2
	move.w		#$FFFF,			(a2)+		; mask 3
	moveq		#8,				d5
	move.w		d5,				(a2)+		; destination X increment
	move.w		#128,			(a2)+		; destination Y increment
	move.l		a1,				(a2)+		; destination address
	move.w		#21,			(a2)+		; surface width
	move.w		d1,				(a2)+		; surface height
	move.w		d3,				(a2)+		; mode
	move.w		#$C000,			d5			; shift mode
	moveq		#15,			d4
	sub.w		d2,				d4
	or.w		d4,				d5          ; shift
	move.w		d5,				(a2)		; start
	nop
	movem.l		(sp)+,			d4-d5/a2-a4
	rts

;-----------------------------------------------------------------------------
; bplan_stretch : stretch bitplan to surface
;	args :	d0 = width
;			d1 = height 1
;			d2 = height 2
;			d3 = height 3
;			d4 = padding
;			a0 = src
;			a1 = dst
;-----------------------------------------------------------------------------

bplan_stretch:
	movem.l		d5-d6/a2-a4,		-(sp)
	lea			$FFFF8A20.W,	a2
	moveq		#2,				d5
	moveq		#-1,			d6
	move.w		d5,				(a2)+		; source X increment
	sub.w		d0,				d5
	sub.w		d0,				d5
	move.l		a2,				a3			; * a3 = y incr
	move.w		d5,				(a2)+		; source Y increment
	move.l		a0,				(a2)+		; source address
	move.l		d6,				(a2)+		; mask 1 & 2
	move.w		d6,				(a2)+		; mask 3
	moveq		#8,				d5
	move.w		d5,				(a2)+		; destination X increment
	add.w		d4,				d5
	move.w		d5,				(a2)+		; destination Y increment
	move.l		a1,				(a2)+		; destination address
	move.l		a2,				a4			; * a4 = surf siz
	move.w		d0,				(a2)+		; surface width
	move.w		d1,				(a2)+		; surface height
	move.w		#$0203,			(a2)+		; mode
	tst.w		d1
	beq.s		bplan_strch_0
	move.w		#$C000,			(a2)		; start
	nop
bplan_strch_0:
	move.w		(a3),			d5
	move.w		#2,				(a3)		; source Y increment
;	add.l		d0,				2(a3)
;	add.l		d0,				2(a3)
	move.w		d0,				(a4)		; surface width
	move.w		d2,				2(a4)		; surface height
	beq.s		bplan_strch_1
	move.w		#$C000,			6(a4)		; start
	nop
bplan_strch_1:
	move.w		d5,				(a3)		; source Y increment
	move.w		d0,				(a4)		; surface width
	move.w		d3,				2(a4)		; surface height
	beq.s		bplan_strch_2
	move.w		#$C000,			6(a4)		; start
	nop
bplan_strch_2:
	movem.l		(sp)+,			d5-d6/a2-a4
	rts

;-----------------------------------------------------------------------------
; draw_rect : draw a rectangle
;	args :	d0 = left
;			d1 = top
;			d2 = right
;			d3 = bottom
;			d4 = pitch
;			d5 = mode
;			a0 = dst
;-----------------------------------------------------------------------------

draw_rect:
	movem.l		d0-d7/a0-a4,	-(sp)
	lea			xlmsk_table,	a2
	lea			xrmsk_table,	a3
	lea			$FFFF8A20.W,	a4
	moveq		#8,				d6
	move.w		d6,				$00(a4)		; source X increment
	move.w		d6,				$02(a4)		; source Y increment
	move.l		a0,				$04(a4)		; source address
	move.w		#$FFFF,			$0A(a4)		; mask 2
	move.w		d6,				$0E(a4)		; destination X increment
	move.w		d5,				$1A(a4)		; mode
	move.w		d1,				d7
	sub.w		d1,				d3			; d3 = height
	lsl.w		#2,				d1
	lea			yoff_table,		a1
	adda.l		0(a1,d1.w),		a0			; a0 += y off
	add.w		d0,				d0
	lea			xoff8_table,	a1
	move.w		0(a1,d0.w),		d5			; d5 = x off
	adda.w		d5,				a0			; a0 += x off
	move.l		a0,				$12(a4)		; destination address
	add.w		d2,				d2
	move.w		0(a1,d2.w),		d6			; d6 = end off
	sub.w		d5,				d6			; d6 = width
	bne.s		rect_blit_0
	move.w		0(a2,d0.w),		d5
	and.w		0(a3,d2.w),		d5
	move.w		d5,				$08(a4)		; combined masks
	bra.s		rect_blit_1
rect_blit_0:
	move.w		0(a2,d0.w),		$08(a4)		; left mask
	move.w		0(a3,d2.w),		$0C(a4)		; right mask
	sub.w		d6,				d4			; d4 = y incr
	lsr.w		#3,				d6			; d6 = word count
rect_blit_1:
	addq.w		#1,				d6
	move.w		d4,				$10(a4)		; destination Y increment
	move.w		d6,				$16(a4)		; surface width
	move.w		d3,				$18(a4)		; surface height
	lsl.w		#8,				d7
	andi.w		#$0F00,			d7
	or.w		#$C000,			d7
	move.w		d7,				$1C(a4)		; start
	nop
	movem.l		(sp)+,			d0-d7/a0-a4
	rts

;-----------------------------------------------------------------------------
;				PALETTE
;-----------------------------------------------------------------------------
;   0 = 0                 + 00
;   1 = 1                 + 06
;   2 = 2                 + 12
;   3 = 2 + 1             + 18
;   4 = 3                 + 24
;   5 = 3 + 1             + 30
;   6 = 3 + 2             + 36
;   7 = 3 + 2 + 1         + 42
;   8 = 4                 + 48
;   9 = 4 + 1             + 54
;  10 = 4 + 2             + 60
;  11 = 4 + 2 + 1         + 66
;  12 = 4 + 3             + 72
;  13 = 4 + 3 + 1         + 78
;  14 = 4 + 3 + 2         + 84
;  15 = 4 + 3 + 2 + 1     + 90
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; pal_opaq : setup an opaq palette
;	args :	a0 = [5][r.w,g.w,b.w]
;-----------------------------------------------------------------------------

pal_opaq:
	movem.l		d0-d1/a0-a1,	-(sp)
	lea			split_pal,		a1
	move.l		(a0)+,			(a1)+		; 0 1
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			d0			; 2
	move.w		(a0)+,			d1
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		(a0)+,			d0			; 3
	move.w		(a0)+,			d1
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		(a0)+,			d0			; 4
	move.w		(a0)+,			d1
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	movem.l		(sp)+,			d0-d1/a0-a1
	rts

;-----------------------------------------------------------------------------
; pal_over : setup a weird palette :)
;	args :	a0 = [5][r.w,g.w,b.w]
;-----------------------------------------------------------------------------

pal_over:
	movem.l		d0-d1/a0-a1,	-(sp)
	lea			split_pal,		a1
	move.l		(a0)+,			d0
	move.l		d0,				(a1)+		; 0 1 2
	move.w		(a0),			d1
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.w		(a0)+,			(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		(a0)+,			(a1)+		; 3
	move.w		(a0)+,			(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		(a0)+,			(a1)+		; 4
	move.w		(a0)+,			(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	move.l		d0,				(a1)+
	move.w		d1,				(a1)+
	movem.l		(sp)+,			d0-d1/a0-a1
	rts

;-----------------------------------------------------------------------------
; pal_mix : setup a mixed palette
;	args :	a0 = ptr to [5][r.w,g.w,b.w]
;-----------------------------------------------------------------------------

pal_mix:
	move.l		a1,				-(sp)
	lea			col_mix(pc),	a1
	bsr.s		pal_fn
	move.l		(sp)+,			a1
	rts

;-----------------------------------------------------------------------------
; pal_add : setup a additive palette
;	args :	a0 = ptr to [5][r.w,g.w,b.w]
;-----------------------------------------------------------------------------

pal_add:
	move.l		a1,				-(sp)
	lea			col_add(pc),	a1
	bsr.s		pal_fn
	move.l		(sp)+,			a1
	rts

;-----------------------------------------------------------------------------
; pal_fn : setup a palette
;	args :	a0 = ptr to [5][r.w,g.w,b.w]
;			a1 = fn
;-----------------------------------------------------------------------------

pal_fn:
	movem.l		d0-d1/a0-a5,	-(sp)
	moveq		#0,				d1			; for rounding
	lea			split_pal,		a2
	move.l		a2,				a5
	move.l		(a0)+,			(a5)+		; 0 1 2
	move.l		(a0)+,			(a5)+
	move.l		(a0)+,			(a5)+
	move.l		(a0)+,			(a5)+
	move.w		(a0)+,			(a5)+
	lea			06(a2),			a3			; 2 + 1
	lea			12(a2),			a4
	jsr			(a1)
	move.l		(a0)+,			(a5)+		; 3
	move.w		(a0)+,			(a5)+
	lea			06(a2),			a3			; 3 + 1
	lea			24(a2),			a4
	jsr			(a1)
	lea			12(a2),			a3			; 3 + 2
	lea			24(a2),			a4
	jsr			(a1)
	lea			06(a2),			a3			; 3 + 2 + 1
	lea			36(a2),			a4
	jsr			(a1)
	move.l		(a0)+,			(a5)+		; 4
	move.w		(a0)+,			(a5)+
	lea			06(a2),			a3			; 4 + 1
	lea			48(a2),			a4
	jsr			(a1)
	lea			12(a2),			a3			; 4 + 2
	lea			48(a2),			a4
	jsr			(a1)
	lea			18(a2),			a3			; 4 + 2 + 1
	lea			48(a2),			a4
	jsr			(a1)
	lea			24(a2),			a3			; 4 + 3
	lea			48(a2),			a4
	jsr			(a1)
	lea			30(a2),			a3			; 4 + 3 + 1
	lea			48(a2),			a4
	jsr			(a1)
	lea			36(a2),			a3			; 4 + 3 + 2
	lea			48(a2),			a4
	jsr			(a1)
	lea			42(a2),			a3			; 4 + 3 + 2 + 1
	lea			48(a2),			a4
	jsr			(a1)
	movem.l		(sp)+,			d0-d1/a0-a5
	rts

;-----------------------------------------------------------------------------
; col_mix : mix 2 colors
;	args :	a2 = color 1 ptr
;			a3 = color 2 ptr
;			a4 = result ptr
;-----------------------------------------------------------------------------

col_mix:
	move.w		(a3)+,			d0
	add.w		(a4)+,			d0
	lsr.w		#1,				d0
	addx.w		d1,				d0
	move.w		d0,				(a5)+
	move.w		(a3)+,			d0
	add.w		(a4)+,			d0
	lsr.w		#1,				d0
	addx.w		d1,				d0
	move.w		d0,				(a5)+
	move.w		(a3)+,			d0
	add.w		(a4)+,			d0
	lsr.w		#1,				d0
	addx.w		d1,				d0
	move.w		d0,				(a5)+
	rts

;-----------------------------------------------------------------------------
; col_add : add 2 colors, clamp result
;	args :	a2 = color 1 ptr
;			a3 = color 2 ptr
;			a4 = result ptr
;-----------------------------------------------------------------------------

col_add:
	move.w		(a3)+,			d0
	add.w		(a4)+,			d0
	btst		#4,				d0
	beq.s		col_add_0
	moveq		#15,			d0
col_add_0:
	move.w		d0,				(a5)+
	move.w		(a3)+,			d0
	add.w		(a4)+,			d0
	btst		#4,				d0
	beq.s		col_add_1
	moveq		#15,			d0
col_add_1:
	move.w		d0,				(a5)+
	move.w		(a3)+,			d0
	add.w		(a4)+,			d0
	btst		#4,				d0
	beq.s		col_add_2
	moveq		#15,			d0
col_add_2:
	move.w		d0,				(a5)+
	rts

;-----------------------------------------------------------------------------
; pal_draw : setup palette registers
;-----------------------------------------------------------------------------

pal_draw:
	movem.l		d0-d3/a0-a5,	-(sp)
	lea			split_pal,		a1
	lea			$FFFF8240.W,	a2
	lea			red_table,		a3
	lea			green_table,	a4
	lea			blue_table,		a5
	moveq		#15,			d1
pal_draw_0:
	move.w		(a1)+,			d2
	add.w		d2,				d2
	move.w		0(a3,d2.w),		d3
	move.w		(a1)+,			d2
	add.w		d2,				d2
	or.w		0(a4,d2.w),		d3
	move.w		(a1)+,			d2
	add.w		d2,				d2
	or.w		0(a5,d2.w),		d3
	move.w		d3,				(a2)+
	dbra		d1,pal_draw_0
	movem.l		(sp)+,			d0-d3/a0-a5
	rts

;-----------------------------------------------------------------------------
; pal_blend : setup & blend palette registers
;	args :	d0 = inverse factor [0-255]
;			a0 = color [r.w,g.w,b.w] * factor
;-----------------------------------------------------------------------------

pal_blend:
	movem.l		d0-d7/a0-a5,	-(sp)
	lea			split_pal,		a1
	lea			$FFFF8240.W,	a2
	lea			red_table,		a3
	lea			green_table,	a4
	lea			blue_table,		a5
	move.w		(a0)+,			d4
	move.w		(a0)+,			d5
	move.w		(a0)+,			d6
	moveq		#0,				d7
	moveq		#15,			d1
pal_blend_0:

	move.w		(a1)+,			d2
	mulu.w		d0,				d2
	add.w		d4,				d2
	lsr.w		#8,				d2
	addx.w		d7,				d2
	add.w		d2,				d2
	move.w		0(a3,d2.w),		d3

	move.w		(a1)+,			d2
	mulu.w		d0,				d2
	add.w		d5,				d2
	lsr.w		#8,				d2
	addx.w		d7,				d2
	add.w		d2,				d2
	or.w		0(a4,d2.w),		d3

	move.w		(a1)+,			d2
	mulu.w		d0,				d2
	add.w		d6,				d2
	lsr.w		#8,				d2
	addx.w		d7,				d2
	add.w		d2,				d2
	or.w		0(a5,d2.w),		d3

	move.w		d3,				(a2)+
	dbra		d1,pal_blend_0
	movem.l		(sp)+,			d0-d7/a0-a5
	rts

;-----------------------------------------------------------------------------
; pal_rotate : setup palette registers
;	args :	d0, d1, d2 = angles
;			a0 = src [5][r.w,g.w,b.w]
;			a1 = dst [5][r.w,g.w,b.w]
;-----------------------------------------------------------------------------

pal_rotate:
	movem.l		d3-d6/a0-a2,	-(sp)
	lea			rotate_table,	a2
	moveq		#0,				d4
	move.w		#360,			d5
	moveq		#4,				d6
pal_rotate_0:

	move.w		(a0),			d3
	add.w		d0,				d3
	cmp.w		d5,				d3
	blt.s		pal_rotate_1
	sub.w		d5,				d3
pal_rotate_1:
	move.w		d3,				(a0)+
	move.b		0(a2,d3.w),		d4
	move.w		d4,				(a1)+

	move.w		(a0),			d3
	add.w		d1,				d3
	cmp.w		d5,				d3
	blt.s		pal_rotate_2
	sub.w		d5,				d3
pal_rotate_2:
	move.w		d3,				(a0)+
	move.b		0(a2,d3.w),		d4
	move.w		d4,				(a1)+

	move.w		(a0),			d3
	add.w		d2,				d3
	cmp.w		d5,				d3
	blt.s		pal_rotate_3
	sub.w		d5,				d3
pal_rotate_3:
	move.w		d3,				(a0)+
	move.b		0(a2,d3.w),		d4
	move.w		d4,				(a1)+

	dbra		d6,pal_rotate_0
	movem.l		(sp)+,			d3-d6/a0-a2
	rts


;-----------------------------------------------------------------------------
; pal_rotate2 : setup palette registers
;	args :	a0 = src [5][r.w,g.w,b.w]
;			a1 = dst [5][r.w,g.w,b.w]
;			a2 = rot [5][r.w,g.w,b.w]
;-----------------------------------------------------------------------------

pal_rotate2:
	movem.l		d0-d6/a0-a3,	-(sp)
	lea			rotate_table,	a3
	moveq		#0,				d4
	move.w		#360,			d5
	moveq		#4,				d6
pal_rotate2_0:
	move.w		(a2)+,			d0
	move.w		(a2)+,			d1
	move.w		(a2)+,			d2

	move.w		(a0),			d3
	add.w		d0,				d3
	cmp.w		d5,				d3
	blt.s		pal_rotate2_1
	sub.w		d5,				d3
pal_rotate2_1:
	move.w		d3,				(a0)+
	move.b		0(a3,d3.w),		d4
	move.w		d4,				(a1)+

	move.w		(a0),			d3
	add.w		d1,				d3
	cmp.w		d5,				d3
	blt.s		pal_rotate2_2
	sub.w		d5,				d3
pal_rotate2_2:
	move.w		d3,				(a0)+
	move.b		0(a3,d3.w),		d4
	move.w		d4,				(a1)+

	move.w		(a0),			d3
	add.w		d2,				d3
	cmp.w		d5,				d3
	blt.s		pal_rotate2_3
	sub.w		d5,				d3
pal_rotate2_3:
	move.w		d3,				(a0)+
	move.b		0(a3,d3.w),		d4
	move.w		d4,				(a1)+

	dbra		d6,pal_rotate2_0
	movem.l		(sp)+,			d0-d6/a0-a3
	rts


;=============================================================================
				SECTION BSS
;=============================================================================


split_pal:		ds.w			48


;=============================================================================
;				END OF FILE
;=============================================================================

