; 16x16 pixel, 4bpl Font routines, ray//.tSCc. 2007

FONTPIC_X	=	320	; Fontset pixel dimensions
FONTPIC_Y	=	80

CHARS_X		=	20	; Chars per font line

CHAR_X		=	16	; Char pixel dimensions
CHAR_Y		=	16


		data
font16x16Pak:	incbin	'fnt16x16.lz7'	; Packed font bitmap
		even


******************************************************
*  void initFontLib()
*
* Init font library.
******************************************************

		text
initFontLib:	move.l	#FONTPIC_X*FONTPIC_Y,d0	; Deflate font set
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,font16x16Ptr

		lea.l	font16x16Pak,a0
		movea.l	d0,a1
		lea.l	FONTPIC_X*FONTPIC_Y/2(a1),a1
		bsr.w	d_lz77


; Compute pixel masks for faster font plotting

                movea.l	font16x16Ptr(pc),a1
                lea.l	FONTPIC_X*FONTPIC_Y/2(a1),a0
		move.w  #FONTPIC_X*FONTPIC_Y/16-1,d0

.pixelmsk_loop:	movem.w	(a0)+,d1-d4
		movem.w	d1-d4,8(a1)	; "or pattern" (4bpl)
		or.w	d4,d1
		or.w	d3,d1
		or.w	d2,d1
		not.w	d1
		move.w	d1,(a1)+	; "and pattern" (4bpl)
		move.w	d1,(a1)+
		move.w	d1,(a1)+
		move.w	d1,(a1)+
		addq.l	#8,a1		; Skip or pattern

		dbra	d0,.pixelmsk_loop

		rts


font16x16Ptr:	ds.l	1


******************************************************
*  void plotString(a0.l * srcStr, a1.l * dst, d0.w x, d1.w y)
*
* Plot the given string at the specified x, y position.
* NOTE: "x" must be a multiple of sixteen. The source
* string is assumed to be zero terminated.
******************************************************

plotString:	lsr.w	#4,d0		; Set destination pointer
		lsl.w	#3,d0
		adda.w	d0,a1

		mulu.w	#BYTESPERSCL,d1
		adda.l	d1,a1

		movea.l	font16x16Ptr(pc),a2

.read_str:      moveq.l	#0,d0   	; *srcStr++ == NULL?
		move.b	(a0)+,d0
		beq.w	.break

		subi.b	#' ',d0

		divu.w	#CHARS_X,d0	; Find source position in font bitmap
		move.w	d0,d1
		mulu.w	#2*BYTESPERSCL*CHAR_Y,d1
		lea.l	(a2,d1.l),a3

		swap.w	d0
		lsl.w	#4,d0
		adda.w	d0,a3

ofs	set	0     			; Plot char
	rept	CHAR_Y
	
	ifne	ofs
		movem.l	2*ofs(a3),d1-d4
		and.l	d1,ofs(a1)
		and.l	d2,ofs+4(a1)
		or.l	d3,ofs(a1)
		or.l	d4,ofs+4(a1)
	else
        	movem.l	(a3),d1-d4
		and.l	d1,(a1)
		and.l	d2,4(a1)
		or.l	d3,(a1)
		or.l	d4,4(a1)
	endc
ofs	set 	ofs+BYTESPERSCL
	endr
		addq.l	#CHAR_X/2,a1	; Advance to next char position

		bra.w	.read_str

.break:		rts

