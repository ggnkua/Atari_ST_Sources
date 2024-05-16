;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; TABLES.S : usefull tables
;  need	MATH.S
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; calc_tables : compute all tables
;-----------------------------------------------------------------------------

calc_tables:
	bsr			calc_yoff
	bsr			calc_xoff
	bsr			calc_xmsk
	bsr			calc_disk
	bsr			calc_color
	bsr			calc_rotate
	rts

;-----------------------------------------------------------------------------
; calc_yoff : compute y offset table [0-199]
;-----------------------------------------------------------------------------

calc_yoff:
	lea			yoff_table,		a0
	move.l		#455,			d0			; height
	moveq		#0,				d1			; offset
	move.l		#288,			d2			; offset incr
calc_yoff_0:
	move.l		d1,				(a0)+
	add.l		d2,				d1
	dbra		d0,calc_yoff_0
	rts

;-----------------------------------------------------------------------------
; calc_xoff : compute x offset table [0-319]
;-----------------------------------------------------------------------------

calc_xoff:
	lea			xoff2_table,	a0
	lea			xoff8_table,	a1
	moveq		#79,			d0			; width / 16
	moveq		#0,				d1			; offset * 2
	moveq		#0,				d2			; offset * 8
	move.l		#$20002,		d3			; offset incr * 2
	move.l		#$80008,		d4			; offset incr * 8
calc_xoff_0:
	moveq		#7,				d5
calc_xoff_1:
	move.l		d1,				(a0)+
	move.l		d2,				(a1)+
	dbra		d5,calc_xoff_1
	add.l		d3,				d1
	add.l		d4,				d2
	dbra		d0,calc_xoff_0
	rts

;-----------------------------------------------------------------------------
; calc_xmask : compute x mask tables [0-319]
;-----------------------------------------------------------------------------

calc_xmsk:
	lea			xlmsk_table,	a0
	lea			1280(a0),		a0			; end of left table
	lea			xrmsk_table,	a1
	lea			1280(a1),		a1			; end of right table
	lea			xmsk_table,		a2
	lea			2560(a2),		a2			; end of mixed table
	move.l		#639,			d0			; width
	move.w		#$FFFF,			d1			; full mask
	moveq		#$F,			d2			; index mask for shifting
calc_xmsk_0:
	move.w		d0,				d3
	and.w		d2,				d3
	move.w		d1,				d4
	lsr.w		d3,				d4
	move.w		d4,				-(a0)
	move.w		d4,				-(a2)
	not.w		d4
	move.w		d4,				-(a1)
	move.w		d4,				-(a2)
	dbra		d0,calc_xmsk_0
	rts

;-----------------------------------------------------------------------------
; calc_disk : compute disk table [0-255]
;-----------------------------------------------------------------------------

calc_disk:
	lea			disk_table,		a0
	lea			512(a0),		a0
	move.l		#255,			d1			; height
	move.l		#256,			d2          ; r
	mulu.w		d1,				d2			; r*r
calc_disk_0:
	move.l		d2,				d0          ; r*r
	move.l		d1,				d3          ; y
	mulu.w		d3,				d3          ; y*y
	sub.l		d3,				d0          ; (r*r)-(y*y)
	swap		d0
	bsr			fast_sqrt                   ; sqrt((r*r)-(y*y))
	move.w		d0,				-(a0)
	dbra		d1,calc_disk_0
	rts

;-----------------------------------------------------------------------------
; calc_color : compute color tables
;-----------------------------------------------------------------------------

calc_color:
	lea			blue_table,		a0
	lea			32(a0),			a0			; end of blue table
	lea			green_table,	a1
	lea			32(a1),			a1			; end of green table
	lea			red_table,		a2
	lea			32(a2),			a2			; end of red table
	moveq		#15,			d0
calc_color_0:
	move.w		d0,				d1
	lsr.w		#1,				d1
	bcc.s		calc_color_1
	addq.w		#8,				d1
calc_color_1:
	move.w		d1,				-(a0)		; blue
	lsl.w		#4,				d1
	move.w		d1,				-(a1)		; green
	lsl.w		#4,				d1
	move.w		d1,				-(a2)		; red
	dbra		d0,calc_color_0
	rts

;-----------------------------------------------------------------------------
; calc_rotate : compute color rotation table
;-----------------------------------------------------------------------------

calc_rotate:
	lea			cos_table,		a0
	lea			rotate_table,	a1
	move.l		#359,			d0
	move.w		#$1000,			d1
	moveq		#9,				d2
calc_rotate_0:
	move.w		(a0)+,			d3
	add.w		d1,				d3
	lsr.w		d2,				d3
	move.b		d3,				(a1)+
	dbra		d0,calc_rotate_0
	rts


;=============================================================================
				SECTION DATA
;=============================================================================


ste_colors:		dc.w			$0, $2, $4, $6, $8, $A, $C, $E
				dc.w			$1, $3, $5, $7, $9, $B, $D, $F


;=============================================================================
				SECTION BSS
;=============================================================================


disk_table:		ds.w			256			; y[0-255] : x

yoff_table:		ds.l			456			; y[0-455] : y*288

xoff2_table:	ds.w			1280		; x[0-1279] : (x/16)*2
xoff8_table:	ds.w			1280		; x[0-1279] : (x/16)*8
xlmsk_table:	ds.w			640			; x[0-639] : $FFFF>>(x%16)
xrmsk_table:	ds.w			640			; x[0-639] : ~($FFFF>>(x%16))
xmsk_table:		ds.l			640

rotate_table:	ds.b			360			; color rotation

red_table:		ds.w			16			;
green_table:	ds.w			16			; STE color ramps
blue_table:		ds.w			16			;


;=============================================================================
;				END OF FILE
;=============================================================================

