
		data		; End screen palette object
endingPalObj:
endingFade:	dc.w	1
		dc.l	greyPal

		dc.w	-1


******************************************************
*  void endingInit()
*
* End-screen initialization routine.
******************************************************

FNT8X8_WIDTH	=	320		; Font set pixel dimensions (4bpl)
FNT8X8_HEIGHT	=	48

CHARS_8X8_X     =	40	; Virtual textmode resolution
CHARS_8X8_Y	=	25	; in chars

MAX_Y		=	459

		text
endingInit:	move.l	#FNT8X8_WIDTH*FNT8X8_HEIGHT/2,d0
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,endingFontPtr

		lea.l	endingFontPak,a0	; Decrunch 8x8 pixel font
		move.l	d0,a1
		bsr.w	d_lz77

		move.l	endingFontPtr(pc),a0	; Convert font set into a move.l accesible format
						; (i.e. deinteleaved)
		move.w	#FNT8X8_WIDTH*FNT8X8_HEIGHT/16-1,d0

.conv_text_movep:
		movep.l	(a0),d1
		movep.l	1(a0),d2
		move.l	d1,(a0)+
		move.l	d2,(a0)+
		dbra	d0,.conv_text_movep

		lea.l	endingText,a0		; Expand text to 40 Chars per line
		lea.l	endingTextBuf,a1

.y_loop:
		moveq.l	#CHARS_8X8_X-1,d1
.x_loop:
		move.b	(a0)+,d2	; Get character
		cmpi.b	#-1,d2		; End of text?
		beq.s	.break
		cmpi.b	#13,d2		; Carriage return?
		beq.s	.x_trail

		move.b	d2,(a1)+	; Copy character
		dbra	d1,.x_loop

		addq.l	#1,a0
		bra.s	.cont

.x_trail:	move.b	#' ',(a1)+	; Fill up remaining columns with blanks
		dbra	d1,.x_trail

.cont:		addq.l	#1,a0
		bra.s	.y_loop

.break:		lea.l	endingPalObj,a0
		bra.w	installSplitPalette


******************************************************
*  void endingMain()
*
* End-text scroller.
******************************************************


		text
endingMain:     move.l	#endingFadeIn,VBLHookPtr

		bsr.w	wVBL

		lea.l	endingTextBuf,a0
		lea.l	.endingY(pc),a1
		adda.w	(a1),a0

		move.b	$fffffc02.w,d0
		cmpi.b	#$48,d0
		bne.s	.not_up

		tst.w	(a1)
		beq.s	.not_up
		subi.w	#CHARS_8X8_X,(a1)
.not_up:
		cmpi.b	#$50,d0
		bne.s	.not_down
		cmpi.w	#(MAX_Y-CHARS_8X8_Y)*CHARS_8X8_X,(a1)
		bhs.s	.not_down
		addi.w	#CHARS_8X8_X,(a1)
.not_down:
		movea.l	screen3(pc),a1
		movea.l	endingFontPtr(pc),a2



		moveq.l	#CHARS_8X8_Y-1,d0	; Draw one page of CHARS_X*CHARS_Y characters

.y_char_loop:	moveq.l	#CHARS_8X8_X-1,d1

		move.l	#$00070001,d4	; Interleave destination increment
		movea.l	a1,a4

.x_char_loop:	moveq.l	#0,d2
		move.b	(a0)+,d2	; Get one char from text file

		subi.b	#' ',d2
		move.w	#$f0,d3
		and.b	d2,d3		; Extract font set source position (16x5 chars)
		eor.b	d3,d2

		lsr.b	#4,d3
		mulu.w	#8*(FNT8X8_WIDTH/2),d3
		lea.l	(a2,d3.l),a3
;>		lsr.b	d2
;>		bcc.s	._even
;>		addq.l	#1,a3
;>._even:		lsl.w	#3,d2
		lsl.w	#2,d2
		adda.l	d2,a3

ofs	set	0			; Put 8x8 pixel character
	rept	8

;>		movep.l	ofs(a3),d2
	ifeq	ofs
		move.l	(a3),d2
	else
		move.l	ofs(a3),d2
	endc
		movep.l	d2,ofs(a4)

ofs	set	ofs+BYTESPERSCL
	endr

		adda.w	d4,a4		; Increment destination pointer
		swap.w	d4

		dbra	d1,.x_char_loop

		lea.l	BYTESPERSCL*8(a1),a1	; Add destination increment (8 pixel scanlines)
		dbra	d0,.y_char_loop

		bra.w	cycleScreens



.endingY:	dc.w	0		; Current Y pixel position


endingFontPtr:	ds.l	1

		bss
endingTextBuf:	ds.b	CHARS_8X8_X*MAX_Y	; Expanded text buffer
		even

		data
endingText:	incbin	'INVI2007.TXT'
		dc.b	-1
		even
endingFontPak:	incbin	'FNT8X8.LZ7'
		even


******************************************************
*  void interrupt endingFadeIn()
*
* End-screen fade in interrupt handler.
******************************************************

		text
endingFadeIn:	moveq.l	#3,d0
		and.l	$466.w,d0	; Fade every 4th VBL
		bne.s	.break

		moveq.l	#(1<<PHYS_BPP)-1,d0	; Max. brightness

		cmp.w	endingFade,d0		; Max. brightness approached yet?
		beq.s	.done

		addq.w	#1,endingFade

.break:		rts

.done:		clr.l	VBLHookPtr
		rts

		text