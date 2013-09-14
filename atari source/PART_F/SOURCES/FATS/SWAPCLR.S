*
*  Miscellaneous copy-box functions
*
*  Vertical & Horizontal Flip courtesy of Jim Eisenstein
*  Scale-down courtesy of Jim Eisenstein
*  Color swap routine courtesy of Dan Oliver
*
	.include	"fatequ.s"
	.globl	cpy_nxln
*
	.globl	swapclr
	.globl	vflip
	.globl	hflip
	.globl	back_splat
*
*  VFLIP for 4 planes: word aligned: interwoven planes
*
*  in:
*	a0	points to SRC form
*	a1	points to first word of DST buffer
*	a2	SRC form width (bytes)
*	a3	DST form width (bytes)
*
*	d0	SRC X
*	d1	SRC Y
*	d2	width of block in pixels
*	d3	height of block in pixels

vflip:

	add.w	d0,d2			; d2 <- Xmax
	subq.w	#1,d2			;  * adjust *
	and.l	#$FFF0,d0		; d0 <- Xmin mod16 (clr hi word)
	and.w	#$FFF0,d2		; d2 <- Xmax mod16
	sub.w	d0,d2			
	lsr.w	#4,d2			
	addq.w	#1,d2			; d2 <- SRC word span (one plane)

	add.w	d3,d1			; d1 <- SRC Ymax
	subq.w	#1,d1			; * adjust *
	move.w	a2,d4			; d4 <- src wrap
	mulu	d4,d1			; d1 <- y offset (bytes)
	lsr.w	#1,d0			; d0 <- x offset (bytes)
	add.l	d1,d0			; d0 <- offset to first word of SRC
	add.l	d0,a0			; a0 -> first SRC word of last line

	move.w	d2,d4			; span of one plane in words
	asl.w	#3,d4			; d4 <- width of block (bytes:4 planes)
	add.w	d4,a2			; a2 <- src wrap to previous line
	sub.w	d4,a3			; a3 <- dst wrap to next line

	bra.s	enter3


loop2:	move.l	(a0)+,(a1)+		; move a word from src to dst
	move.l	(a0)+,(a1)+

enter2:	dbra	d5,loop2		; d5 <- width counter

	sub.w	a2,a0			; a0 -> previous SRC line
	add.w	a3,a1			; a1 -> next DST line

enter3:	move.w	d2,d5			; d5 <- span count reinitialized
	dbra	d3,enter2		; d3 <- line counter

	rts
*
*
*
*
*
*  HFLIP for 4 planes: word aligned: interwoven planes
*
*  in:
*	a0	points to SRC form
*	a1	points to first word of DST buffer
*	a2	SRC form width (bytes)
*	a3	DST form width (bytes)
*
*	d0	SRC X
*	d1	SRC Y
*	d2	width of block in pixels
*	d3	height of block in pixels

hflip:

	add.w	d0,d2			; d2 <- Xmax
	subq.w	#1,d2			; * adjust *
	and.l	#$FFF0,d0		; d0 <- Xmin mod16 (clr hi word)
	and.w	#$FFF0,d2		; d2 <- Xmax mod16
	sub.w	d0,d2			
	lsr.w	#4,d2			
	addq.w	#1,d2			; d2 <- SRC word span (one plane)

	move.w	a2,d4			; d4 <- src wrap
	mulu	d4,d1			; d1 <- y offset (bytes)
	lsr.w	#1,d0			; d0 <- x offset (bytes)
	add.l	d1,d0			; d0 <- offset to first word of SRC
	add.l	d0,a0			; a0 -> first SRC word
	
*  a2	 wrap from end of one line to start of next    (SRC)
*  a3	 wrap from start of one line to end of next +8 (DST)

	move.w	d2,d4			; span of one plane in words
	asl.w	#3,d4			; d4 <- width of block (bytes:4 planes)
	sub.w	d4,a2			; a2 <- src wrap
	add.w	d4,a3			; a3 <- dst wrap

	add.w	d4,a1
	subq.w	#8,a1			; a1 -> last set of words on first line

	moveq.l	#14,d4			; d4 <- dst offset to previous word set
	moveq	#0,d7			;clear upper byte of low word

	bra.s	enter1



loop0:	move.b	(a0)+,d7		; d7 <- src hi byte   (word 0)
	move.b	flip_tab(pc,d7.w),1(a1)	; save dst lo byte
	move.b	(a0)+,d7		; d7 <- src lo byte
	move.b	flip_tab(pc,d7.w),(a1)	; save dst hi byte
	addq.w	#2,a1			; a1 -> next dst word

	move.b	(a0)+,d7		; d7 <- src hi byte   (word 1)
	move.b	flip_tab(pc,d7.w),1(a1)	; save dst lo byte
	move.b	(a0)+,d7		; d7 <- src lo byte
	move.b	flip_tab(pc,d7.w),(a1)	; save dst hi byte
	addq.w	#2,a1			; a1 -> next dst word

	move.b	(a0)+,d7		; d7 <- src hi byte   (word 2)
	move.b	flip_tab(pc,d7.w),1(a1)	; save dst lo byte
	move.b	(a0)+,d7		; d7 <- src lo byte
	move.b	flip_tab(pc,d7.w),(a1)	; save dst hi byte
	addq.w	#2,a1			; a1 -> next dst word

	move.b	(a0)+,d7		; d7 <- src hi byte   (word 3)
	move.b	flip_tab(pc,d7.w),1(a1)	; save dst lo byte
	move.b	(a0)+,d7		; d7 <- src lo byte
	move.b	flip_tab(pc,d7.w),(a1)	; save dst hi byte

	sub.w	d4,a1			; a1 -> dst previous word set	

enter0:	dbra	d5,loop0		; d5 <- width counter

	add.w	a2,a0			; a0 -> next SRC line
	add.w	a3,a1			; a1 -> next DST line

enter1:	move.w	d2,d5			; d5 <- span count reinitialized
	dbra	d3,enter0		; d3 <- line counter

	rts



flip_tab:

	dc.b	$00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
	dc.b	$08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
	dc.b	$04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
	dc.b	$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
	dc.b	$02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
	dc.b	$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
	dc.b	$06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
	dc.b	$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
	dc.b	$01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
	dc.b	$09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
	dc.b	$05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
	dc.b	$0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
	dc.b	$03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
	dc.b	$0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
	dc.b	$07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
	dc.b	$0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF
*	
*
*
***************************************************************
*
* SWAPCLR.S			11/04/85 - 11/04/85	D Oliver
*
*
*BYT_LINE	= 160		;Number of bytes per scan line.
*
	.text
*
* ===========================================
*	Transform color indexes in low res
*	screen planes.
* ===========================================
*  IN:	a0 = pointer to 16 bytes of new color indexes.
*	a1 = address of memory block in the form of a low res screen.
*	d2 = x1.
*	d3 = y1.
*	d0 = width.
*	a2 = height.
*
* OUT:	Color indexes of 0 are changed to the value of the first given byte.
*	Color indexes of 1 are changed to the value of the second given byte.
*	Color indexes of 2 are changed to the value of the third given byte.
*	You get the idea.
*
*x1	= d2
*y1	= d3
*width	= d0
*height	= a2
*
*
swapclr:
*
* *** Adjust width and height ***********************************
*
*	tst.w	width
	tst.w	d0
	beq	exit100
*	cmp.w	#0,height
	cmp.w	#0,a2
	beq	exit100
*
*	sub.w	#1,width
	subq.w	#1,d0
*	sub.w	#1,height
	subq.w	#1,a2
*
* *** Set bit 7 of all indexes that do not need change **********
*
	move.l	#$0f,d4
lop100:
	cmp.b	0(a0,d4.w),d4
	bne.s	next100
*
		or.b	#$80,0(a0,d4.w)
next100:
	dbf	d4,lop100
*
*
* *** Compute starting place ************************************
*
*	move.w	y1,d4
	move.w	d3,d4
*	mulu	#BYT_LINE,d4
	mulu	cpy_nxln,d4
*
	add.l	d4,a1			;Starting line number.
*
*	move.w	x1,d4
	move.w	d2,d4
*
*Dave	lsr.w	#4,d4
*Dave	add.l	d4,a1			;Start word in starting line.
*
	lsr.w	#4,d4			;*Dave
	lsl.w	#3,d4			;*Dave
	adda.w	d4,a1			;*Dave
*
*	move.w	x1,d1
	move.w	d2,d1
*
	not.w	d1			;Starting pixel in starting word.
	andi.w	#$f,d1
*
	move.w	d1,a4			;Save.
*
nextline:
	move.l	a1,a3			;Initialize word counter.
	move.w	d0,d7			;Initialize width counter.
*
	move.w	a4,d1			;Initialize starting pixel place.
*
nextword:
	movem.w	(a3)+,d2-d5		;Grab 16 pixels worth.
*
*
* *** Build pixel's index *************
*
nextpix:
	clr.w	d6
	btst.l	d1,d2
	beq.s	skip100
*
		or.w	#1,d6
skip100:
	btst.l	d1,d3
	beq.s	skip101
*
		or.w	#2,d6
skip101:
	btst.l	d1,d4
	beq.s	skip102
*
		or.w	#4,d6
skip102:
	btst.l	d1,d5
	beq.s	skip103
*
		or.w	#8,d6
skip103:
*
* *** Transform index ******************************************
*
* d6.w = pixel's index value.
*
	move.b	0(a0,d6.w),d6
	bmi.s	next101		;Does this index need changing?
*
	bclr.l	d1,d2
	bclr.l	d1,d3
	bclr.l	d1,d4
	bclr.l	d1,d5
	btst.l	#0,d6
	beq.s	skip105
*
		bset.l	d1,d2
skip105:
	btst.l	#1,d6
	beq.s	skip106
*
		bset.l	d1,d3
skip106:
	btst.l	#2,d6
	beq.s	skip107
*
		bset.l	d1,d4
skip107:
*Dave	btst.l	#4,d6
	btst.l	#3,d6		;*Dave
*
	beq.s	skip108
*
		bset.l	d1,d5
skip108:
*
* *** Next pixel, check if done with line, or need next word *******
*
next101:
	subq.w	#1,d7		;Width counter.
	bpl.s	ok100
*
		movem.w	d2-d5,-8(a3)	;Replace words.
		subq.l	#1,a2		;Done?
		cmpa.w	#-1,a2
		beq.s	exit100
*
*			add.w	#BYT_LINE,a1		;Next line.
			add.w	cpy_nxln,a1		;Next line.
			bra.s	nextline
*
ok100:
	dbf	d1,nextpix	;Decrement pixel counter within word.
*
	movem.w	d2-d5,-8(a3)	;Replace words.
	move.l	#15,d1		;Another word needed, reinitialize pixel count.
	bra.s	nextword
*
exit100:
	rts
*
*
*   background splat routine
*
*
* in:
*	a0	base of source form
*	a1	base of destination form
*
*	d4	Xmin
*	d5	Ymin
*	d6	width
*	d7	height
*
*	Forms are assumed to be screen width (160 bytes)
*
back_splat:

	mulu	#160,d5
	add.l	d5,a0
	add.l	d5,a1

	add.w	d4,d6
	subq.w	#1,d6			;*dave
	lsr.w	#4,d4
	lsr.w	#4,d6
	sub.w	d4,d6			; d6 <- inner loop dbra counter

	lsl.w	#3,d4			; d4 <- offset to X
	add.w	d4,a0			; a0 -> start of source
	add.w	d4,a1			; a1 -> start of destination

	move.w	d6,d5
	addq.w	#1,d5			; d5 <- width of splat words
	lsl.w	#3,d5

	move.w	#160,a2
	sub.w	d5,a2			; a2 <- form wrap
	
	move.w	d6,d5			; d6 <- inner loop dbra counter
	subq.w	#1,d7			; d7 <- outter loop dbra counter



splat_loop:

	move.l	(a0)+,d0		; d0 <- p0:p1
	move.l	(a0)+,d1		; d1 <- p2:p3
	move.l	d1,d2			; d2 <- p2:p3
	or.l	d0,d2			; d2 <- p2+p0:p3+p1
	move.l	d2,d3			; d3 <- p2+p0:p3+p1
	swap	d3			; d3 <- p3+p1:p2+p0
	or.l	d3,d2			; d2 <- p3+p2+p1+p0:p3+p2+p1+p0
	not.l	d2			; d2 <- AND mask
	and.l	d2,(a1)
	or.l	d0,(a1)+
	and.l	d2,(a1)
	or.l	d1,(a1)+

	dbra	d6,splat_loop

	move.w	d5,d6			; d6 <- inner loop counter
	add.w	a2,a0
	add.w	a2,a1
	dbra	d7,splat_loop

	rts
*
*
	.end
