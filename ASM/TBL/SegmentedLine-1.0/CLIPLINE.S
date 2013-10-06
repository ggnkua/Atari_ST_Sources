
;-----------------------------------------------------------------------
; 2D line clipper
;  by Kalms/TBL
;
; This routine takes in the coordinates for a 2D line and clips it to the specified 2D rectangle.
; If any input coordinate is outside the (-2048, +2047) range then the entire line is rejected.

ClipLine_MinX	= 0
ClipLine_MinY	= 0
ClipLine_MaxX	= 319
ClipLine_MaxY	= 199


		section	text

;------------------------------------------------------------------------------
; 2D line clipper
;
; In	Non-clipped line vertices
;	d0.w	x0
;	d1.w	y0
;	d2.w	x1
;	d3.w	y1
; Out	Clipped line vertices
;	d0.w	x0
;	d1.w	y0
;	d2.w	x1
;	d3.w	y1
;	d4.l	0 = line is entirely outside screen [d0-d3 unchanged], 1 = line is partially on-screen
; Destroys
;	d5-d7

ClipLine
		; Calculate outcodes for vertex 0
		
		moveq	#0,d4
		cmp.w	#ClipLine_MaxY,d1
		sgt	d4
		add.w	d4,d4
		cmp.w	#ClipLine_MaxX,d0
		sgt	d4
		add.w	d4,d4
		cmp.w	#ClipLine_MinY,d1
		slt	d4
		add.w	d4,d4
		cmp.w	#ClipLine_MinX,d0
		slt	d4
		add.w	d4,d4
		bne.s	.clipNeeded0		; 76 if no clipping
		
		; Calculate outcodes for vertex 1

		moveq	#0,d5
		cmp.w	#ClipLine_MaxY,d3
		sgt	d5
		add.w	d5,d5
		cmp.w	#ClipLine_MaxX,d2
		sgt	d5
		add.w	d5,d5
		cmp.w	#ClipLine_MinY,d3
		slt	d5
		add.w	d5,d5
		cmp.w	#ClipLine_MinX,d2
		slt	d5
		add.w	d5,d5
		bne.s	.clipNeeded1		; 76 if no clipping

		; Line is entirely inside screen

		moveq	#1,d4
		rts

.rejectLine
		; Line is entirely outside screen

		moveq	#0,d4
		rts

.clipNeeded0
		; vertex 0 is outside

		; Calculate outcodes for vertex 1

		moveq	#0,d5
		cmp.w	#ClipLine_MaxY,d3
		sgt	d5
		add.w	d5,d5
		cmp.w	#ClipLine_MaxX,d2
		sgt	d5
		add.w	d5,d5
		cmp.w	#ClipLine_MinY,d3
		slt	d5
		add.w	d5,d5
		cmp.w	#ClipLine_MinX,d2
		slt	d5
		add.w	d5,d5

		move.w	d4,d6
		and.w	d5,d6
		bne.s	.rejectLine

		; both vertex 0 and vertex 1 are outside

.clipNeeded1

		; If any vertex coordinate is outside the (-2048, 2047) range, reject line

		move.w	#2048,d7
		add.w	d7,d0
		move.w	d0,d6
		sub.w	d7,d0
		add.w	d7,d1
		or.w	d1,d6
		sub.w	d7,d1
		add.w	d7,d2
		or.w	d2,d6
		sub.w	d7,d2
		add.w	d7,d3
		or.w	d3,d6
		sub.w	d7,d3
		cmp.w	#4096,d6
		bhs	.rejectLine

		; Calculate interpolation factor for vertex 0

		lsr.w	#8,d4
		add.w	d4,d4
		move.w	.clipVertex0_routines(pc,d4.w),d4
		jmp	.clipVertex0_routines(pc,d4.w)

.clipVertex0_routines
		dc.w	.clipVertex0_none-.clipVertex0_routines
		dc.w	.clipVertex0_minX-.clipVertex0_routines
		dc.w	.clipVertex0_minY-.clipVertex0_routines
		dc.w	.clipVertex0_minX_minY-.clipVertex0_routines
		dc.w	.clipVertex0_maxX-.clipVertex0_routines
		dc.w	.clipVertex0_illegal-.clipVertex0_routines
		dc.w	.clipVertex0_maxX_minY-.clipVertex0_routines
		dc.w	.clipVertex0_illegal-.clipVertex0_routines
		dc.w	.clipVertex0_maxY-.clipVertex0_routines
		dc.w	.clipVertex0_minX_maxY-.clipVertex0_routines
		dc.w	.clipVertex0_illegal-.clipVertex0_routines
		dc.w	.clipVertex0_illegal-.clipVertex0_routines
		dc.w	.clipVertex0_maxX_maxY-.clipVertex0_routines
		dc.w	.clipVertex0_illegal-.clipVertex0_routines
		dc.w	.clipVertex0_illegal-.clipVertex0_routines
		dc.w	.clipVertex0_illegal-.clipVertex0_routines

.clipVertex0_illegal
		illegal			; All illegal outcode combinations go here

.clipVertex0_none
		moveq	#0,d4
		bra	.clipVertex0_done

CLIPVERTEX_MINX MACRO	targetReg
		moveq	#0,\1
		move.w	#ClipLine_MinX,\1
		sub.w	d0,\1
		swap	\1
		asr.l	#2,\1
		move.w	d2,d6
		sub.w	d0,d6
		divs.w	d6,\1
		ENDM

CLIPVERTEX_MINY MACRO	targetReg
		moveq	#0,\1
		move.w	#ClipLine_MinY,\1
		sub.w	d1,\1
		swap	\1
		asr.l	#2,\1
		move.w	d3,d6
		sub.w	d1,d6
		divs.w	d6,\1
		ENDM

CLIPVERTEX_MAXX MACRO	targetReg
		moveq	#0,\1
		move.w	d0,\1
		sub.w	#ClipLine_MaxX,\1
		swap	\1
		asr.l	#2,\1
		move.w	d0,d6
		sub.w	d2,d6
		divs.w	d6,\1
		ENDM

CLIPVERTEX_MAXY MACRO	targetReg
		moveq	#0,\1
		move.w	d1,\1
		sub.w	#ClipLine_MaxY,\1
		swap	\1
		asr.l	#2,\1
		move.w	d1,d6
		sub.w	d3,d6
		divs.w	d6,\1
		ENDM

.clipVertex0_minX
		CLIPVERTEX_MINX	d4
		bra	.clipVertex0_done

.clipVertex0_minY
		CLIPVERTEX_MINY	d4
		bra	.clipVertex0_done

.clipVertex0_minX_minY
		CLIPVERTEX_MINX	d4
		CLIPVERTEX_MINY	d7
		cmp.w	d7,d4
		bhs	.clipVertex0_done
		move.w	d7,d4
		bra	.clipVertex0_done

.clipVertex0_maxX
		CLIPVERTEX_MAXX	d4
		bra	.clipVertex0_done

.clipVertex0_maxX_minY
		CLIPVERTEX_MAXX	d4
		CLIPVERTEX_MINY	d7
		cmp.w	d7,d4
		bhs	.clipVertex0_done
		move.w	d7,d4
		bra	.clipVertex0_done

.clipVertex0_maxY
		CLIPVERTEX_MAXY	d4
		bra	.clipVertex0_done

.clipVertex0_minX_maxY
		CLIPVERTEX_MINX	d4
		CLIPVERTEX_MAXY	d7
		cmp.w	d7,d4
		bhs	.clipVertex0_done
		move.w	d7,d4
		bra	.clipVertex0_done

.clipVertex0_maxX_maxY
		CLIPVERTEX_MAXX	d4
		CLIPVERTEX_MAXY	d7
		cmp.w	d7,d4
		bhs	.clipVertex0_done
		move.w	d7,d4

.clipVertex0_done

		; Calculate interpolation factor for vertex 1

		lsr.w	#8,d5
		add.w	d5,d5
		move.w	.clipVertex1_routines(pc,d5.w),d5
		jmp	.clipVertex1_routines(pc,d5.w)

.clipVertex1_routines
		dc.w	.clipVertex1_none-.clipVertex1_routines
		dc.w	.clipVertex1_minX-.clipVertex1_routines
		dc.w	.clipVertex1_minY-.clipVertex1_routines
		dc.w	.clipVertex1_minX_minY-.clipVertex1_routines
		dc.w	.clipVertex1_maxX-.clipVertex1_routines
		dc.w	.clipVertex1_illegal-.clipVertex1_routines
		dc.w	.clipVertex1_maxX_minY-.clipVertex1_routines
		dc.w	.clipVertex1_illegal-.clipVertex1_routines
		dc.w	.clipVertex1_maxY-.clipVertex1_routines
		dc.w	.clipVertex1_minX_maxY-.clipVertex1_routines
		dc.w	.clipVertex1_illegal-.clipVertex1_routines
		dc.w	.clipVertex1_illegal-.clipVertex1_routines
		dc.w	.clipVertex1_maxX_maxY-.clipVertex1_routines
		dc.w	.clipVertex1_illegal-.clipVertex1_routines
		dc.w	.clipVertex1_illegal-.clipVertex1_routines
		dc.w	.clipVertex1_illegal-.clipVertex1_routines

.clipVertex1_illegal
		illegal			; All illegal outcode combinations go here

.clipVertex1_none
		move.w	#$4000,d5
		bra	.clipVertex1_done

.clipVertex1_minX
		CLIPVERTEX_MINX	d5
		bra	.clipVertex1_done

.clipVertex1_minY
		CLIPVERTEX_MINY	d5
		bra	.clipVertex1_done

.clipVertex1_minX_minY
		CLIPVERTEX_MINX	d5
		CLIPVERTEX_MINY	d7
		cmp.w	d7,d5
		bls	.clipVertex1_done
		move.w	d7,d5
		bra	.clipVertex1_done

.clipVertex1_maxX
		CLIPVERTEX_MAXX	d5
		bra	.clipVertex1_done

.clipVertex1_maxX_minY
		CLIPVERTEX_MAXX	d5
		CLIPVERTEX_MINY	d7
		cmp.w	d7,d5
		bls	.clipVertex1_done
		move.w	d7,d5
		bra	.clipVertex1_done

.clipVertex1_maxY
		CLIPVERTEX_MAXY	d5
		bra	.clipVertex1_done

.clipVertex1_minX_maxY
		CLIPVERTEX_MINX	d5
		CLIPVERTEX_MAXY	d7
		cmp.w	d7,d5
		bls	.clipVertex1_done
		move.w	d7,d5
		bra	.clipVertex1_done

.clipVertex1_maxX_maxY
		CLIPVERTEX_MAXX	d5
		CLIPVERTEX_MAXY	d7
		cmp.w	d7,d5
		bls	.clipVertex1_done
		move.w	d7,d5

.clipVertex1_done

		cmp.w	d4,d5
		blo	.rejectLine

		; Calculate new vertices from the interpolation factors

		sub.w	d0,d2
		sub.w	d1,d3
		move.w	d2,d6
		move.w	d3,d7
		muls.w	d4,d6
		muls.w	d4,d7
		lsl.l	#2,d6
		lsl.l	#2,d7
		add.l	#$8000,d6
		add.l	#$8000,d7
		swap	d6
		swap	d7
		add.w	d0,d6
		add.w	d1,d7
		muls.w	d5,d2
		muls.w	d5,d3
		lsl.l	#2,d2
		lsl.l	#2,d3
		add.l	#$8000,d2
		add.l	#$8000,d3
		swap	d2
		swap	d3
		add.w	d0,d2
		add.w	d1,d3
		move.w	d6,d0
		move.w	d7,d1
		moveq	#1,d4
		rts
