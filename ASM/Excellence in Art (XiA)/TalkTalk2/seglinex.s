
;-----------------------------------------------------------------------
; 1 bitplane linedrawing routine, uses DDA + pregenerated code segments
;  by Kalms/TBL
;
; This routine pregenerates code for drawing 16-pixel line segments in all possible directions.
; Pixels are plotted using a series of OR.W #$xxxx,$yyyy(a1) statements.
;
; During runtime, the line is rendered 16 pixels at a time by calling a suitable pregenerated
;  drawing routine. The final modulo-16 pixels are handled separately (those are plotted pixel-by-pixel).
;
; The resulting line is not perfect, but close to it. Looks worst for near-horizontal/near-vertical lines.
;
;
; To setup, call SegmentedLineSetup.
; All registers will get trashed.
;
; To draw a line, call SegmentedLine with the following arguments:
; 	a0.l = (x1.w,y1.w,x2.w,y2.w)
; 	a1.l = screen address
; All registers will get trashed.
;


SegmentedLine_Pitch		= 160				; Bytes per row in screenbuffer
SegmentedLine_Log2RunLength	= 4				; log2(Length of precomputed run)
SegmentedLine_RunLength	= (1<<SegmentedLine_Log2RunLength)	; Length of precomputed run

SegmentedLine_OR_W_IMM_D16_A1	= $0069				; or.w #$xxxx,$yyyy(a1)
SegmentedLine_JMP_A0		= $4ed0				; jmp (a0)
SegmentedLine_SUB_L_D6_D0	= $9086				; sub.l d6,d0
SegmentedLine_ADD_W_IMM_A1	= $d2fc				; add.w #imm,a1

		.text

SegmentedLineSetup::

; Compute 1/x table
; Table format is: shift factor, and then fixed-point representation of $10000/x
; When $10000/x goes below $200, then $10000 is shifted up and the shift-factor is increased
; (so precision of table result is always at least 9 bits)

		lea	SegmentedLine_ReciprocalMultiplyTable,a0
		clr.l	(a0)+
		clr.l	(a0)+
		moveq	#2,d0
.reciprocal:

		moveq	#-1,d1
		move.w	d0,d2
		subq.w	#1,d2
.reciprocal_shift:
		addq.w	#1,d1
		lsr.w	#1,d2
		bne.s	.reciprocal_shift

		sub.w	#6,d1
		bpl.s	.reciprocal_largeDivisor
		moveq	#0,d1
.reciprocal_largeDivisor:

		moveq	#0,d2
		bset	d1,d2
		swap	d2
		
		divu.w	d0,d2
		move.w	d1,(a0)+
		move.w	d2,(a0)+

		addq.w	#1,d0
		cmp.w	#320,d0
		bls.s	.reciprocal

; Generate rendering code for line segments
		
		lea	SegmentedLine_UpwardXMajor_GeneratedCodeOffsets,a0
		lea	SegmentedLine_GeneratedCodeBuffer,a2
		move.l	a2,a1
		move.l	a2,SegmentedLine_UpwardXMajor_GeneratedCodeBodies

		move.w	#0,d1
.upwardXMajor_x0:
		move.w	#0,d0
.upwardXMajor_dy:
		move.l	a2,a3
		sub.l	a1,a3
		move.w	a3,(a0)+

		moveq	#0,d6
		move.w	d0,d6
		swap	d6
		lsr.l	#SegmentedLine_Log2RunLength,d6
		move.l	#$8000,d5

		move.w	d1,d2
		eor.w	#$f,d2
		moveq	#0,d3
		bset	d2,d3

		moveq	#0,d2
		
		moveq	#0,d4
		moveq	#SegmentedLine_RunLength-1,d7
.upwardXMajor_pixel:

		or.w	d3,d2

		add.l	d6,d5
		cmp.l	#$10000,d5
		blo.s	.upwardXMajor_pixel_sameRow
		move.w	#SegmentedLine_OR_W_IMM_D16_A1,(a2)+
		move.w	d2,(a2)+
		move.w	d4,(a2)+
		moveq	#0,d2
		swap	d5
		clr.w	d5
		swap	d5
		add.w	#-SegmentedLine_Pitch,d4
.upwardXMajor_pixel_sameRow:

		ror.w	#1,d3
		bcc.s	.upwardXMajor_pixel_sameColumn
		tst.w	d2
		beq.s	.upwardXMajor_pixel_sameColumn_noPixelsToFlush
		move.w	#SegmentedLine_OR_W_IMM_D16_A1,(a2)+
		move.w	d2,(a2)+
		move.w	d4,(a2)+
		moveq	#0,d2
.upwardXMajor_pixel_sameColumn_noPixelsToFlush:
		addq.w	#8,d4
.upwardXMajor_pixel_sameColumn:

		dbf	d7,.upwardXMajor_pixel

		tst.w	d2
		beq.s	.upwardXMajor_pixel_noPixelsToFlush
		move.w	#SegmentedLine_OR_W_IMM_D16_A1,(a2)+
		move.w	d2,(a2)+
		move.w	d4,(a2)+
.upwardXMajor_pixel_noPixelsToFlush:

		move.w	#SegmentedLine_ADD_W_IMM_A1,(a2)+
		move.w	d4,(a2)+

		move.w	#SegmentedLine_JMP_A0,(a2)+
		
.upwardXMajor_skipRun:
		addq.w	#1,d0
		cmp.w	#SegmentedLine_RunLength,d0
		bls	.upwardXMajor_dy
		addq.w	#1,d1
		cmp.w	#16,d1
		blo	.upwardXMajor_x0


		lea	SegmentedLine_UpwardYMajor_GeneratedCodeOffsets,a0
		move.l	a2,a1
		move.l	a2,SegmentedLine_UpwardYMajor_GeneratedCodeBodies

		move.w	#0,d1
.upwardYMajor_x1:
		move.w	#0,d0
.upwardYMajor_x0:
		move.l	a2,a3
		sub.l	a1,a3
		move.w	a3,(a0)+

		move.w	d1,d6
		sub.w	d0,d6
		bmi.s	.upwardYMajor_skipRun
		cmp.w	#SegmentedLine_RunLength,d6
		bhi.s	.upwardYMajor_skipRun
		swap	d6
		clr.w	d6
		lsr.l	#SegmentedLine_Log2RunLength,d6
		move.w	d0,d5
		swap	d5
		move.w	#$8000,d5

		moveq	#0,d4
		moveq	#SegmentedLine_RunLength-1,d7
.upwardYMajor_pixel:

		move.w	#SegmentedLine_OR_W_IMM_D16_A1,(a2)+
		swap	d5
		move.w	d5,d2
		and.w	#$f,d2
		eor.w	#$f,d2
		moveq	#0,d3
		bset	d2,d3
		move.w	d3,(a2)+
		move.w	d5,d2
		and.w	#$fff0,d2
		lsr.w	#1,d2
		add.w	d4,d2
		move.w	d2,(a2)+
		swap	d5

		add.l	d6,d5
		add.w	#-SegmentedLine_Pitch,d4
		dbf	d7,.upwardYMajor_pixel

		move.w	#-SegmentedLine_Pitch*SegmentedLine_RunLength,d2

		cmp.w	#$10,d1
		blo.s	.upwardYMajor_sameWordAfterRun
		move.w	#SegmentedLine_SUB_L_D6_D0,(a2)+
		addq.w	#8,d2
.upwardYMajor_sameWordAfterRun:
		move.w	#SegmentedLine_ADD_W_IMM_A1,(a2)+
		move.w	d2,(a2)+

		move.w	#SegmentedLine_JMP_A0,(a2)+
		
.upwardYMajor_skipRun:
		addq.w	#1,d0
		cmp.w	#16,d0
		blo	.upwardYMajor_x0
		addq.w	#1,d1
		cmp.w	#16+SegmentedLine_RunLength,d1
		blo	.upwardYMajor_x1

		lea	SegmentedLine_DownwardXMajor_GeneratedCodeOffsets,a0
		move.l	a2,a1
		move.l	a2,SegmentedLine_DownwardXMajor_GeneratedCodeBodies

		move.w	#0,d1
.downwardXMajor_x0:
		move.w	#0,d0
.downwardXMajor_dy:
		move.l	a2,a3
		sub.l	a1,a3
		move.w	a3,(a0)+

		moveq	#0,d6
		move.w	d0,d6
		swap	d6
		lsr.l	#SegmentedLine_Log2RunLength,d6
		move.l	#$8000,d5

		move.w	d1,d2
		eor.w	#$f,d2
		moveq	#0,d3
		bset	d2,d3

		moveq	#0,d2
		
		moveq	#0,d4
		moveq	#SegmentedLine_RunLength-1,d7
.downwardXMajor_pixel:

		or.w	d3,d2

		add.l	d6,d5
		cmp.l	#$10000,d5
		blo.s	.downwardXMajor_pixel_sameRow
		move.w	#SegmentedLine_OR_W_IMM_D16_A1,(a2)+
		move.w	d2,(a2)+
		move.w	d4,(a2)+
		moveq	#0,d2
		swap	d5
		clr.w	d5
		swap	d5
		add.w	#SegmentedLine_Pitch,d4
.downwardXMajor_pixel_sameRow:

		ror.w	#1,d3
		bcc.s	.downwardXMajor_pixel_sameColumn
		tst.w	d2
		beq.s	.downwardXMajor_pixel_sameColumn_noPixelsToFlush
		move.w	#SegmentedLine_OR_W_IMM_D16_A1,(a2)+
		move.w	d2,(a2)+
		move.w	d4,(a2)+
		moveq	#0,d2
.downwardXMajor_pixel_sameColumn_noPixelsToFlush:
		addq.w	#8,d4
.downwardXMajor_pixel_sameColumn:

		dbf	d7,.downwardXMajor_pixel

		tst.w	d2
		beq.s	.downwardXMajor_pixel_noPixelsToFlush
		move.w	#SegmentedLine_OR_W_IMM_D16_A1,(a2)+
		move.w	d2,(a2)+
		move.w	d4,(a2)+
.downwardXMajor_pixel_noPixelsToFlush:

		move.w	#SegmentedLine_ADD_W_IMM_A1,(a2)+
		move.w	d4,(a2)+

		move.w	#SegmentedLine_JMP_A0,(a2)+
		
.downwardXMajor_skipRun:
		addq.w	#1,d0
		cmp.w	#SegmentedLine_RunLength,d0
		bls	.downwardXMajor_dy
		addq.w	#1,d1
		cmp.w	#16,d1
		blo	.downwardXMajor_x0


		lea	SegmentedLine_DownwardYMajor_GeneratedCodeOffsets,a0
		move.l	a2,a1
		move.l	a2,SegmentedLine_DownwardYMajor_GeneratedCodeBodies

		move.w	#0,d1
.downwardYMajor_x1:
		move.w	#0,d0
.downwardYMajor_x0:
		move.l	a2,a3
		sub.l	a1,a3
		move.w	a3,(a0)+

		move.w	d1,d6
		sub.w	d0,d6
		bmi.s	.downwardYMajor_skipRun
		cmp.w	#SegmentedLine_RunLength,d6
		bhi.s	.downwardYMajor_skipRun
		swap	d6
		clr.w	d6
		lsr.l	#SegmentedLine_Log2RunLength,d6
		move.w	d0,d5
		swap	d5
		move.w	#$8000,d5

		moveq	#0,d4
		moveq	#SegmentedLine_RunLength-1,d7
.downwardYMajor_pixel:

		move.w	#SegmentedLine_OR_W_IMM_D16_A1,(a2)+
		swap	d5
		move.w	d5,d2
		and.w	#$f,d2
		eor.w	#$f,d2
		moveq	#0,d3
		bset	d2,d3
		move.w	d3,(a2)+
		move.w	d5,d2
		and.w	#$fff0,d2
		lsr.w	#1,d2
		add.w	d4,d2
		move.w	d2,(a2)+
		swap	d5

		add.l	d6,d5
		add.w	#SegmentedLine_Pitch,d4
		dbf	d7,.downwardYMajor_pixel

		move.w	#SegmentedLine_Pitch*SegmentedLine_RunLength,d2

		cmp.w	#$10,d1
		blo.s	.downwardYMajor_sameWordAfterRun
		move.w	#SegmentedLine_SUB_L_D6_D0,(a2)+
		addq.w	#8,d2
.downwardYMajor_sameWordAfterRun:
		move.w	#SegmentedLine_ADD_W_IMM_A1,(a2)+
		move.w	d2,(a2)+

		move.w	#SegmentedLine_JMP_A0,(a2)+
		
.downwardYMajor_skipRun:
		addq.w	#1,d0
		cmp.w	#16,d0
		blo	.downwardYMajor_x0
		addq.w	#1,d1
		cmp.w	#16+SegmentedLine_RunLength,d1
		blo	.downwardYMajor_x1

		rts

;-----------------------------------------------------------------------
		
SegmentedLine::

; In: a0 - address to struct or words containing x1, y1, x2, y2
;     a1 - screen address
; Destroys:
;     d0-d7, a0-a6
; No clipping!

; a0.l = (x1.w,y1.w,x2.w,y2.w)
; a1.l = screen address

		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.w	(a0)+,d2
		move.w	(a0)+,d3

		cmp.w	d0,d2			; Swap endpoints if necessary, so line always goes left->right
		bpl.s	.leftToRight
		exg	d0,d2
		exg	d1,d3
.leftToRight:

		sub.w	d0,d2
		sub.w	d1,d3
		bpl	.downward

;------------------------- upward ---------------------------

.upward:
		neg.w	d3
		add.w	d1,d1			; make a1 point to the word containing first pixel to be drawn
		add.w	d1,d1
		lea	SegmentedLine_MulTable,a2
		add.l	(a2,d1.w),a1

		move.w	d0,d1
		and.w	#$f,d0
		eor.w	d0,d1
		lsr.w	#1,d1
		add.w	d1,a1

		cmp.w	d2,d3
		bhi	.upwardYMajor
		beq	.upwardDiagonal

.upwardXMajor:
		
;	d0	----XXXX	x0 & $f
;	d2	----XXXX	dx
;	d3	----YYYY	dy
;	a1			ptr to word containing first pixel

		lea	SegmentedLine_ReciprocalMultiplyTable,a2	; 12
		move.w	d2,d4						; 4
		add.w	d4,d4						; 4
		add.w	d4,d4						; 4
		move.l	(a2,d4.w),d4					; 16
		mulu.w	d4,d3						; 72
		swap	d4						; 4
		lsr.l	d4,d3						; 8+2n
									; 124+2n
		
		move.w	#$8000,d4

		sub.w	#SegmentedLine_RunLength,d2
		bmi.s	.upwardXMajor_noRuns

		moveq	#0,d1
		move.w	d3,d1
		lsl.l	#SegmentedLine_Log2RunLength,d1

		lea	SegmentedLine_UpwardXMajor_GeneratedCodeOffsets,a2
		move.w	d0,d5
		lsl.w	#SegmentedLine_Log2RunLength,d5
		add.w	d0,d5
		swap	d1
		add.w	d1,d5
		swap	d1
		add.w	d5,d5
		add.w	d5,a2
		move.l	SegmentedLine_UpwardXMajor_GeneratedCodeBodies,a3
		lea	.upwardXMajor_runDone(pc),a0
		
		moveq	#2,d5
.upwardXMajor_run:
		add.w	d1,d4
		subx.w	d6,d6
		and.w	d5,d6
		move.w	(a2,d6.w),d6
		jmp	(a3,d6.w)
		
.upwardXMajor_runDone:

		sub.w	#SegmentedLine_RunLength,d2
		bge.s	.upwardXMajor_run

.upwardXMajor_noRuns:

		add.w	#SegmentedLine_RunLength,d2
		bmi.s	.upwardXMajor_noSinglePixels

		moveq	#0,d5
		eor.w	#$f,d0
		bset	d0,d5

		move.w	#-SegmentedLine_Pitch,d0
		
.upwardXMajor_singlePixel:
		or.w	d5,(a1)
		add.w	d3,d4
		bcs.s	.upwardXMajor_singlePixel_newRow
		ror.w	#1,d5
		bcs.s	.upwardXMajor_singlePixel_sameRow_newHorizWord
		dbf	d2,.upwardXMajor_singlePixel
		rts
.upwardXMajor_singlePixel_sameRow_newHorizWord:
		addq.w	#8,a1
		dbf	d2,.upwardXMajor_singlePixel
		rts
.upwardXMajor_singlePixel_newRow:
		ror.w	#1,d5
		bcs.s	.upwardXMajor_singlePixel_newRow_newHorizWord
		add.w	d0,a1
		dbf	d2,.upwardXMajor_singlePixel
		rts
.upwardXMajor_singlePixel_newRow_newHorizWord:
		add.w	d0,a1
		addq.w	#8,a1
		dbf	d2,.upwardXMajor_singlePixel
.upwardXMajor_noSinglePixels:
		rts
		
.upwardDiagonal:

;	d0	----XXXX	x0 & $f
;	d2	----XXXX	dx
;	d3	----YYYY	dy
;	a1			ptr to word containing first pixel

		eor.w	#$f,d0
		moveq	#0,d4
		bset	d0,d4

		move.w	#-SegmentedLine_Pitch,d1
		move.w	#-SegmentedLine_Pitch+8,d2

.upwardDiagonal_singlePixel:
		or.w	d4,(a1)
		ror.w	#1,d4
		bcs.s	.upwardDiagonal_singlePixel_nextWord
		add.w	d1,a1
		dbf	d3,.upwardDiagonal_singlePixel
		rts

.upwardDiagonal_singlePixel_nextWord:
		add.w	d2,a1
		dbf	d3,.upwardDiagonal_singlePixel
		rts

.upwardYMajor:

;	d0	----XXXX	x0 & $f
;	d2	----XXXX	dx
;	d3	----YYYY	dy
;	a1			ptr to word containing first pixel

		lea	SegmentedLine_ReciprocalMultiplyTable,a2	; 12
		move.w	d3,d4						; 4
		add.w	d4,d4						; 4
		add.w	d4,d4						; 4
		move.l	(a2,d4.w),d4					; 16
		mulu.w	d4,d2						; 72
		swap	d4						; 4
		lsr.l	d4,d2						; 8+2n
									; 124+2n

		swap	d0
		move.w	#$8000,d0

		sub.w	#SegmentedLine_RunLength,d3
		bmi.s	.upwardYMajor_noRuns

		moveq	#0,d1
		move.w	d2,d1
		lsl.l	#SegmentedLine_Log2RunLength,d1

		lea	SegmentedLine_UpwardYMajor_GeneratedCodeOffsets,a2
		move.l	SegmentedLine_UpwardYMajor_GeneratedCodeBodies,a3
		lea	.upwardYMajor_runDone(pc),a0

		moveq	#$10,d6
		swap	d6
		
.upwardYMajor_run:
		move.l	d0,d4
		add.l	d1,d0
		move.l	d0,d5
		swap	d4
		swap	d5

		lsl.w	#4,d5
		or.w	d5,d4
		add.w	d4,d4
		move.w	(a2,d4.w),d4
		jmp	(a3,d4.w)
		
.upwardYMajor_runDone:

		sub.w	#SegmentedLine_RunLength,d3
		bge.s	.upwardYMajor_run

.upwardYMajor_noRuns:
		moveq	#0,d4
		swap	d0
		eor.w	#$f,d0
		bset	d0,d4
		swap	d0

		move.w	#-SegmentedLine_Pitch,d1

		add.w	d3,d3
		move.w	.upwardYMajor_singlePixelsJumpTable(pc,d3.w),d3
		jmp	.upwardYMajor_singlePixels(pc,d3.w)

		
macro .upwardYMajor_singlePixel   ; 14 bytes
		or.w	d4,(a1)
		add.w	d1,a1
		add.w	d2,d0
		bcc.s	.upwardYMajor_singlePixel_sameWord\~
		ror.w	#1,d4
		bcc.s	.upwardYMajor_singlePixel_sameWord\~
		addq.w	#8,a1
.upwardYMajor_singlePixel_sameWord\~:
		endm

CNTR		SET	16*14
		REPT	17
		dc.w	CNTR
CNTR		SET	CNTR-14
		ENDR
.upwardYMajor_singlePixelsJumpTable:

.upwardYMajor_singlePixels:
  rept 16
		.upwardYMajor_singlePixel
  endr
  rts

;------------------------- downward ---------------------------

.downward:
		add.w	d1,d1			; make a1 point to the word containing first pixel to be drawn
		add.w	d1,d1
		lea	SegmentedLine_MulTable,a2
		add.l	(a2,d1.w),a1

		move.w	d0,d1
		and.w	#$f,d0
		eor.w	d0,d1
		lsr.w	#1,d1
		add.w	d1,a1

		cmp.w	d2,d3
		bhi	.downwardYMajor
		beq	.downwardDiagonal

.downwardXMajor:
		
;	d0	----XXXX	x0 & $f
;	d2	----XXXX	dx
;	d3	----YYYY	dy
;	a1			ptr to word containing first pixel

		lea	SegmentedLine_ReciprocalMultiplyTable,a2	; 12
		move.w	d2,d4						; 4
		add.w	d4,d4						; 4
		add.w	d4,d4						; 4
		move.l	(a2,d4.w),d4					; 16
		mulu.w	d4,d3						; 72
		swap	d4						; 4
		lsr.l	d4,d3						; 8+2n
									; 124+2n

		move.w	#$8000,d4

		sub.w	#SegmentedLine_RunLength,d2
		bmi.s	.downwardXMajor_noRuns

		moveq	#0,d1
		move.w	d3,d1
		lsl.l	#SegmentedLine_Log2RunLength,d1

		lea	SegmentedLine_DownwardXMajor_GeneratedCodeOffsets,a2
		move.w	d0,d5
		lsl.w	#SegmentedLine_Log2RunLength,d5
		add.w	d0,d5
		swap	d1
		add.w	d1,d5
		swap	d1
		add.w	d5,d5
		add.w	d5,a2
		move.l	SegmentedLine_DownwardXMajor_GeneratedCodeBodies,a3
		lea	.downwardXMajor_runDone(pc),a0

		moveq	#2,d5
.downwardXMajor_run:
		add.w	d1,d4
		subx.w	d6,d6
		and.w	d5,d6
		move.w	(a2,d6.w),d6
		jmp	(a3,d6.w)
		
.downwardXMajor_runDone:

		sub.w	#SegmentedLine_RunLength,d2
		bge.s	.downwardXMajor_run

.downwardXMajor_noRuns:

		add.w	#SegmentedLine_RunLength,d2
		bmi.s	.downwardXMajor_noSinglePixels

		moveq	#0,d5
		eor.w	#$f,d0
		bset	d0,d5

		move.w	#SegmentedLine_Pitch,d0
		
.downwardXMajor_singlePixel:
		or.w	d5,(a1)
		add.w	d3,d4
		bcs.s	.downwardXMajor_singlePixel_newRow
		ror.w	#1,d5
		bcs.s	.downwardXMajor_singlePixel_sameRow_newHorizWord
		dbf	d2,.downwardXMajor_singlePixel
		rts
.downwardXMajor_singlePixel_sameRow_newHorizWord:
		addq.w	#8,a1
		dbf	d2,.downwardXMajor_singlePixel
		rts
.downwardXMajor_singlePixel_newRow:
		ror.w	#1,d5
		bcs.s	.downwardXMajor_singlePixel_newRow_newHorizWord
		add.w	d0,a1
		dbf	d2,.downwardXMajor_singlePixel
		rts
.downwardXMajor_singlePixel_newRow_newHorizWord:
		add.w	d0,a1
		addq.w	#8,a1
		dbf	d2,.downwardXMajor_singlePixel
.downwardXMajor_noSinglePixels:
		rts
		
.downwardDiagonal:

;	d0	----XXXX	x0 & $f
;	d2	----XXXX	dx
;	d3	----YYYY	dy
;	a1			ptr to word containing first pixel

		eor.w	#$f,d0
		moveq	#0,d4
		bset	d0,d4

		move.w	#SegmentedLine_Pitch,d1
		move.w	#SegmentedLine_Pitch+8,d2

.downwardDiagonal_singlePixel:
		or.w	d4,(a1)
		ror.w	#1,d4
		bcs.s	.downwardDiagonal_singlePixel_nextWord
		add.w	d1,a1
		dbf	d3,.downwardDiagonal_singlePixel
		rts

.downwardDiagonal_singlePixel_nextWord:
		add.w	d2,a1
		dbf	d3,.downwardDiagonal_singlePixel
		rts

.downwardYMajor:

;	d0	----XXXX	x0 & $f
;	d2	----XXXX	dx
;	d3	----YYYY	dy
;	a1			ptr to word containing first pixel

		lea	SegmentedLine_ReciprocalMultiplyTable,a2	; 12
		move.w	d3,d4						; 4
		add.w	d4,d4						; 4
		add.w	d4,d4						; 4
		move.l	(a2,d4.w),d4					; 16
		mulu.w	d4,d2						; 72
		swap	d4						; 4
		lsr.l	d4,d2						; 8+2n
									; 124+2n

		swap	d0
		move.w	#$8000,d0

		sub.w	#SegmentedLine_RunLength,d3
		bmi.s	.downwardYMajor_noRuns

		moveq	#0,d1
		move.w	d2,d1
		lsl.l	#SegmentedLine_Log2RunLength,d1

		lea	SegmentedLine_DownwardYMajor_GeneratedCodeOffsets,a2
		move.l	SegmentedLine_DownwardYMajor_GeneratedCodeBodies,a3
		lea	.downwardYMajor_runDone(pc),a0

		moveq	#$10,d6
		swap	d6
		
.downwardYMajor_run:
		move.l	d0,d4
		add.l	d1,d0
		move.l	d0,d5
		swap	d4
		swap	d5

		lsl.w	#4,d5
		or.w	d5,d4
		add.w	d4,d4
		move.w	(a2,d4.w),d4
		jmp	(a3,d4.w)
		
.downwardYMajor_runDone:

		sub.w	#SegmentedLine_RunLength,d3
		bge.s	.downwardYMajor_run

.downwardYMajor_noRuns:

		moveq	#0,d4
		swap	d0
		eor.w	#$f,d0
		bset	d0,d4
		swap	d0

		move.w	#SegmentedLine_Pitch,d1

		add.w	d3,d3
		move.w	.downwardYMajor_singlePixelsJumpTable(pc,d3.w),d3
		jmp	.downwardYMajor_singlePixels(pc,d3.w)

macro .downwardYMajor_singlePixel			; 14 bytes
		or.w	d4,(a1)
		add.w	d1,a1
		add.w	d2,d0
		bcc.s	.downwardYMajor_singlePixel_sameWord\~
		ror.w	#1,d4
		bcc.s	.downwardYMajor_singlePixel_sameWord\~
		addq.w	#8,a1
.downwardYMajor_singlePixel_sameWord\~:
		ENDM

CNTR		SET	16*14
		REPT	17
		dc.w	CNTR
CNTR		SET	CNTR-14
		ENDR
.downwardYMajor_singlePixelsJumpTable:
		
.downwardYMajor_singlePixels:
		REPT	16
		.downwardYMajor_singlePixel
		ENDR

		rts


		.data

SegmentedLine_MulTable:
CNTR	SET		0
		REPT	200
		dc.l	CNTR
CNTR	SET		CNTR+SegmentedLine_Pitch
		ENDR

		.bss

SegmentedLine_UpwardXMajor_GeneratedCodeOffsets:
		ds.w	16*(SegmentedLine_RunLength+1)
SegmentedLine_UpwardYMajor_GeneratedCodeOffsets:
		ds.w	16*(16+SegmentedLine_RunLength+16)
SegmentedLine_DownwardXMajor_GeneratedCodeOffsets:
		ds.w	16*(SegmentedLine_RunLength+1)
SegmentedLine_DownwardYMajor_GeneratedCodeOffsets:
		ds.w	16*(16+SegmentedLine_RunLength+16)
SegmentedLine_UpwardXMajor_GeneratedCodeBodies:
		ds.l	1
SegmentedLine_UpwardYMajor_GeneratedCodeBodies:
		ds.l	1
SegmentedLine_DownwardXMajor_GeneratedCodeBodies:
		ds.l	1
SegmentedLine_DownwardYMajor_GeneratedCodeBodies:
		ds.l	1

;SegmentedLine_GeneratedCodeBuffer
;		ds.b	90000	; Buffer for generated code, about 89000 bytes used in practice

SegmentedLine_ReciprocalMultiplyTable:
		ds.l	321

