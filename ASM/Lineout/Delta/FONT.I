; font library for delta demo
;
; dependencies:
; - fscr2.i
;
; The font is a nice century gothic with some antialias.
;

; Converts degas font to highcolor.
Font.init:
; Convert pal..
	lea	Font.degasPic+2,a1
	lea	Font.degasPal,a2
	moveq	#16-1,d7

.pal_loop:
	move.w	(a1)+,d0
	move.w	d0,d1
	move.w	d0,d2
	move.w	d0,d3
	clr.b	d0
	lsl.w	#5,d0
	bcc.s	.end_red
	bset	#$C,d0				; Set ls red bit.
.end_red:
; d0.w=highcol (red)
	lsl.w	#4,d1
	andi.w	#$0700,d1			; d1.w=green msbits
	andi.w	#$0080,d2			; d2.w=green lsbit
	or.w	d1,d0				; d0.w=red+(green msbits)
	or.w	d2,d0				; d0.w=red+green
; Do blue..
	move.w	d3,d1
	andi.w	#$0007,d1
	lsl.w	#2,d1				; d1.w=blue msbits
	or.w	d1,d0				; d0.w=red+green+(blue msbits)
	lsr.w	#3,d3
	andi.w	#1,d3				; d3.w=blue lsbit
	or.w	d3,d0				; d0.w=red+green+blue

	move.w	d0,(a2)+			; Store color.
	dbf	d7,.pal_loop

	lea	Font.pic,a0
	suba.w	#16*2,a2

; Convert pixels..
; a0: dst pic
; a1: pic data (32000 bytes)
; a2: pal
	moveq	#320/16,d0
	move.w	#200,d1
	moveq	#4,d2
	bra.l	Bitmap.convIBplToHC

; Paints text in highcolor. Also handles 'returns'.
; INPUT:
; d0.w=screenwidth (pixels)
; d1.w=x offset
; d2.w=y offset
; a0: screen (highcolor)
; a4: text (nullterminated)
Font.paintText:
	move.w	d0,.width
	mulu.w	d0,d2
	ext.l	d1
	add.l	d1,d2
	lea	(a0,d2.l*2),a0
	move.l	a0,d4
	lea	Font.pic,a1
	lea	Font.charTable,a3

.charloop:
	clr.l	d0
	move.b	(a4)+,d0
	beq.s	.end
	cmpi.w	#$0A,d0
	bne.s	.char
	move.w	#16*2,d3
	mulu.w	.width(pc),d3
	add.l	d3,d4
	movea.l	d4,a0
	bra.s	.charloop

.char:	subi.b	#32,d0
	mulu.w	#6,d0
	movem.w	(a3,d0.l),d0-d2
	mulu.w	#320,d0
	add.l	d1,d0
	move.w	d2,d5
	subq.w	#1,d5
	lea	(a1,d0.l*2),a2
	movea.w	.width(pc),a6
	movea.w	#320,a5
	suba.l	d2,a6
	suba.l	d2,a5
	adda.l	a6,a6
	adda.l	a5,a5
	moveq	#16-1,d7

.yloop:	move.w	d5,d6

.xloop:	move.w	(a2)+,d0
	bne.s	.paint
	addq	#2,a0
	dbf	d6,.xloop
	bra.s	.end_xloop

.paint:	move.w	d0,(a0)+
	dbf	d6,.xloop

.end_xloop:

	adda.l	a6,a0
	adda.l	a5,a2
	dbf	d7,.yloop
	
	move.w	.width(pc),d0
	mulu.w	#16*2,d0
	suba.l	d0,a0
	lea	2(a0,d2.l*2),a0

	bra.s	.charloop

.end:	rts

.width:	DC.W	0

; Paints text in highcolor. Also handles 'returns'.
; INPUT:
; d0.w=screenwidth (pixels)
; d1.w=x offset
; d2.w=y offset
; a0: screen (highcolor)
; a4: text (nullterminated)
Font.paintTextH:
	move.w	d0,.width
	mulu.w	d0,d2
	ext.l	d1
	add.l	d1,d2
	lea	(a0,d2.l*4),a0
	move.l	a0,d4
	lea	Font.pic,a1
	lea	Font.charTable,a3

.charloop:
	clr.l	d0
	move.b	(a4)+,d0
	beq.s	.end
	cmpi.w	#$0A,d0
	bne.s	.char
	addi.l	#16*160*4,d4
	movea.l	d4,a0
	bra.s	.charloop

.char:	subi.b	#32,d0
	mulu.w	#6,d0
	movem.w	(a3,d0.l),d0-d2
	mulu.w	#320,d0
	add.l	d1,d0
	move.w	d2,d5
	subq.w	#1,d5
	lea	(a1,d0.l*2),a2
	movea.w	.width(pc),a6
	movea.w	#320,a5
	suba.l	d2,a6
	suba.l	d2,a5
	adda.l	a6,a6
	adda.l	a6,a6
	adda.l	a5,a5
	moveq	#16-1,d7

.yloop:	move.w	d5,d6

.xloop:	move.w	(a2)+,d0
	bne.s	.paint
	addq	#4,a0
	dbf	d6,.xloop
	bra.s	.end_xloop

.paint:	move.w	d0,(a0)+
	move.w	d0,(a0)+
	dbf	d6,.xloop

.end_xloop:

	adda.l	a6,a0
	adda.l	a5,a2
	dbf	d7,.yloop
	
	move.w	.width(pc),d0
	mulu.w	#16*4,d0
	suba.l	d0,a0
	lea	4(a0,d2.l*4),a0

	bra.s	.charloop

.end:	rts

.width:	DC.W	0

; Paints text in highcolor. Also handles 'returns'.
; INPUT:
; d0.w=screenwidth (pixels)
; d1.w=x offset
; d2.w=y offset
; a0: screen (highcolor)
; a4: text (nullterminated)
Font.paintTextV:
	move.w	d0,.width
	mulu.w	d0,d2
	add.l	d2,d2
	ext.l	d1
	add.l	d1,d2
	lea	(a0,d2.l*2),a0
	move.l	a0,d4
	lea	Font.pic,a1
	lea	Font.charTable,a3

.charloop:
	clr.l	d0
	move.b	(a4)+,d0
	beq.s	.end
	cmpi.w	#$0A,d0
	bne.s	.char
	addi.l	#32*160*2,d4
	movea.l	d4,a0
	bra.s	.charloop

.char:	subi.b	#32,d0
	mulu.w	#6,d0
	movem.w	(a3,d0.l),d0-d2
	mulu.w	#320,d0
	add.l	d1,d0
	move.w	d2,d5
	subq.w	#1,d5
	lea	(a1,d0.l*2),a2
	movea.w	.width(pc),a6
	move.l	a6,d3
	adda.l	a6,a6
	movea.w	#320,a5
	suba.l	d2,a6
	suba.l	d2,a5
	adda.l	a6,a6
	adda.l	a5,a5
	moveq	#16-1,d7

.yloop:	move.w	d5,d6

.xloop:	move.w	(a2)+,d0
	bne.s	.paint
	addq	#2,a0
	dbf	d6,.xloop
	bra.s	.end_xloop

.paint:	move.w	d0,(a0,d3.l*2)
	move.w	d0,(a0)+
	dbf	d6,.xloop

.end_xloop:

	adda.l	a6,a0
	adda.l	a5,a2
	dbf	d7,.yloop
	
	move.w	.width(pc),d0
	mulu.w	#32*2,d0
	suba.l	d0,a0
	lea	2(a0,d2.l*2),a0

	bra.s	.charloop

.end:	rts

.width:	DC.W	0

;= data section ============================================================

	data

Font.degasPic:
	INCBIN	INTRO2.PI1

; ASCII lookup table.
; Starts at char $20, control codes left out.
Font.charTable:
	DC.W	50,0,4				; y, x, w ' '
	DC.W	50,5,3				; '!'
	DC.W	50,0,4				; '"' (not present)
	DC.W	50,14,9				; '#'
	DC.W	50,24,8				; '$'
	DC.W	50,32,14			; '%'
	DC.W	50,46,10			; '&'
	DC.W	50,0,4				; "'" (not present)
	DC.W	50,61,6				; '('
	DC.W	50,67,6				; ')'
	DC.W	50,74,6				; '*'
	DC.W	50,80,10			; '+'
	DC.W	50,90,4				; ','
	DC.W	50,96,4				; '-'
	DC.W	50,101,4			; '.'
	DC.W	50,106,7			; '/'
	DC.W	50,113,9			; '0'
	DC.W	50,123,5			; '1'
	DC.W	50,131,8			; '2'
	DC.W	50,140,9			; '3'
	DC.W	50,148,10			; '4'
	DC.W	50,158,8			; '5'
	DC.W	50,167,8			; '6'
	DC.W	50,176,8			; '7'
	DC.W	50,185,9			; '8'
	DC.W	50,194,8			; '9'
	DC.W	50,203,3			; ':'
	DC.W	50,207,4			; ';'
	DC.W	50,212,9			; '<'
	DC.W	50,221,9			; '='
	DC.W	50,231,9			; '>'
	DC.W	50,241,8			; '?'
; uppercase 
	REPT	32
	DC.W	50,0,4				; uppercase shit, todo?
	ENDR
; lowercase
	DC.W	50,0,4				; '`' not present
	DC.W	90,0,10				; 'a'
	DC.W	90,11,10			; 'b'
	DC.W	90,22,9				; 'c'
	DC.W	90,32,9				; 'd'
	DC.W	90,42,10			; 'e'
	DC.W	90,52,5				; 'f'
	DC.W	90,57,10			; 'g'
	DC.W	90,68,8				; 'h'
	DC.W	90,77,3				; 'i'
	DC.W	90,84,5				; 'j'
	DC.W	90,94,8				; 'k'
	DC.W	90,108,3			; 'l'
	DC.W	90,112,13			; 'm'
	DC.W	90,127,8			; 'n'
	DC.W	90,137,9			; 'o'
	DC.W	90,147,9			; 'p'
	DC.W	90,157,10			; 'q'
	DC.W	90,168,4			; 'r'
	DC.W	90,173,6			; 's'
	DC.W	90,179,5			; 't'
	DC.W	90,185,9			; 'u'
	DC.W	90,194,8			; 'v'
	DC.W	90,203,12			; 'w'
	DC.W	90,221,8			; 'x'
	DC.W	90,233,9			; 'y'
	DC.W	90,248,7			; 'z'
	DC.W	90,255,6			; '{'
	DC.W	90,263,2			; '|'
	DC.W	90,269,7			; '}'
	DC.W	50,0,4				; '~' not present
	DC.W	50,0,4				; '' not present

;= bbs section =============================================================

	bss

Font.pic:
	DS.W	320*200
Font.degasPal:
	DS.W	16
