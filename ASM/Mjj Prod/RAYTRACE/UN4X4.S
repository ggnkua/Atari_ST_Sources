;------------------------------------------------------------------------------
; UN4X4.S : 4X4 image unpacker routine, optimised for size
;------------------------------------------------------------------------------
; Tobe / MJJ Prod 2005
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
unpack_4x4:
;------------------------------------------------------------------------------
;	a0 = source     : packed data    (pal[32] + colors[8000] + pixels[16000])
;	a1 = destination: picture buffer (planar[32000])
;------------------------------------------------------------------------------

	movem.l		d0-d7/a0-a6,	-(sp)

	lea			32(a0),			a0			; skip palette
	lea			8000(a0),		a2			; a0 = colors, a2 = pixels
	lea			16000(a2),		a3			; end of 200 lines

	movea.l		sp,				a6
	lea			-320(sp),		sp			; buffer for 80 blocs of colors

	moveq		#3,				d0			; mask for pixel extraction
	moveq		#0,				d2
	moveq		#0,				d3

.four_lines:
	lea			-320(a6),		a6			; first bloc of colors
	moveq		#79,			d1			; blocs of colors count

.color_bloc:
	moveq		#0,				d4
	move.b		(a0)+,			d4			; $000000AB
	lsl.w		#4,				d4			; $00000AB0
	lsr.b		#4,				d4			; $00000A0B
	swap						d4			; $0A0B0000
	move.b		(a0)+,			d4			; $0A0B00CD
	lsl.w		#4,				d4			; $0A0B0CD0
	lsr.b		#4,				d4			; $0A0B0C0D
	move.l		d4,				(a6)+
	dbra		d1,.color_bloc

	lea			4(a2),			a4			; end of 4 lines

.one_line:
	lea			-320(a6),		a6			; first bloc of colors
	lea			320(a2),		a5			; end of line

.four_blocs:
	moveq		#0,				d4			; bp1
	moveq		#0,				d5			; bp2
	moveq		#0,				d6			; bp3
	moveq		#0,				d7			; bp4
	moveq		#3,				d1			; 4 blocs = 16 pixels

.one_bloc:
	move.b		(a2),			d2			; 3-2-1-0
	move.b		d2,				d3
	and.b		d0,				d2			; 0
	move.b		0(a6,d2.w),		d2			; color[0]
	lsr.b		#1,				d2
	addx.w		d4,				d4
	lsr.b		#1,				d2
	addx.w		d5,				d5
	lsr.b		#1,				d2
	addx.w		d6,				d6
	add.w		d7,				d7
	add.w		d2,				d7
	lsr.b		#2,				d3
	move.b		d3,				d2
	and.b		d0,				d3			; 1
	move.b		0(a6,d3.w),		d3			; color[1]
	lsr.b		#1,				d3
	addx.w		d4,				d4
	lsr.b		#1,				d3
	addx.w		d5,				d5
	lsr.b		#1,				d3
	addx.w		d6,				d6
	add.w		d7,				d7
	add.w		d3,				d7
	lsr.b		#2,				d2
	move.b		d2,				d3
	and.b		d0,				d2			; 2
	move.b		0(a6,d2.w),		d2			; color[2]
	lsr.b		#1,				d2
	addx.w		d4,				d4
	lsr.b		#1,				d2
	addx.w		d5,				d5
	lsr.b		#1,				d2
	addx.w		d6,				d6
	add.w		d7,				d7
	add.w		d2,				d7
	lsr.b		#2,				d3			; 3
	move.b		0(a6,d3.w),		d3			; color[3]
	lsr.b		#1,				d3
	addx.w		d4,				d4
	lsr.b		#1,				d3
	addx.w		d5,				d5
	lsr.b		#1,				d3
	addx.w		d6,				d6
	add.w		d7,				d7
	add.w		d3,				d7
	addq.w		#4,				a2
	addq.w		#4,				a6
	dbra		d1,.one_bloc				; next bloc

	movem.w		d4-d7,			(a1)		; draw pixels
	addq.w		#8,				a1
	cmpa.l		a5,				a2			; next four blocs
	bne.s		.four_blocs

	lea			-319(a2),		a2
	cmpa.l		a4,				a2			; next line
	bne			.one_line

	lea			316(a2),		a2
	cmpa.l		a3,				a2			; next four lines
	bne			.four_lines

	lea			320(sp),		sp
	movem.l		(sp)+,			d0-d7/a0-a6
	rts

