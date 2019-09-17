
*		                  --
*		                PICPAC
*		             ------------
*		         By: M†rten Lindstr”m
*		      --------------------------

* This file contains the packing routines of the PICPAC library

***************************
*    IMGPAC    LBMPAC	Pack images to files of types
*~~~~~~~~~~~~~~~~~~~~~~~~~~	IMG and IFF ILBM
* IN:
*  A4 -> MFDB + extra parameters
*  A3 -> Space for file
*  D0  for LBM: Compression type (0-2),  for IMG: Pattern length (1 or 2)
*  D1: Length of destination memory block
* OUT:  D0: File length or -1 for error
*~~~~~~~~~~~~~~~~~~~~~~~~~~

___pac	cmpi.l	#1600,8(SP)	Make sure that destination
	bmi.s	._pacxit	memory block is at least 1600 bytes

	lea	20(A4),A0	READ PARAMETERS
	move.w	(A0)+,D6	D6: # of planes

	movea.l	(A4)+,A2	A2: Image data
	move.l	A2,D5
	ble.s	._pacxit

	move.w	(A4),D4
	addq.w	#7,D4
	lsr.w	#3,D4	D4: Image width in bytes
	moveq	#15,D5
	and.w	(A4),D3	Image width MOD 16
	move.l	(A4)+,D5	D5: Image height (and width in MSW)

	move.w	(A4),D1
	add.w	D1,D1	  Width in bytes evened up
* - - - - - - - - - - - - - clear any unused bits in form
	tst.w	D3
	beq.s	.wrdbnd
	moveq	#-1,D7
	clr.w	D7
	lsr.l	D3,D7	Mask - 1's = used, 0's unused
	lea	-2(A2),A5	last word before image
	move.w	D6,D2
	bra.s	.plnctrl
.clrbits	add.w	D1,A5	last word of line
	and.w	D7,(A5)
.linctrl	dbf	D3,.clrbits
.plnctrl	move.w	D5,D3
	dbf	D2,.linctrl
* - - - - - - - - - - - - - Calculate safety margin per line
.wrdbnd	moveq	#1,D7
	not.b	D7	#254
	add.w	D4,D7
	divu	#255,D7
	add.w	D7,D7
	add.w	D4,D7	D7: (1 + 2*(1/255 rounded up) ) *
	mulu	D6,D7	    *  # of planes = safety margin
* - - - - - - - - - - - - -
	move.w	(A4)+,D2	D2: Width in words
	tst.w	(A4)	Device independent format
	beq.s	._pacxit	No: error
	move.w	D1,D3
	mulu	D5,D1
	movea.l	D1,A5	A5: Bytes per plane
	mulu	D6,D3
	mulu	D5,D3
	movea.l	D3,A6	A6: Bytes of whole picture

	movem.l	(A0)+,D1/D3	D1: pixel dimensions
._pacxit	rts		D3: ?(reserved) (and start colour)
*			A0 -> #colours and palette
*==========================
IMGPAC	movem.l	D0-D7/A0-A6,-(SP)
	bsr.s	___pac	Read parameters
	bgt.s	imgpac2
imgpac0	subq.l	#2,SP
imgpac1	addq.l	#6,SP
	moveq	#-1,D0	Error: quick exit
	movem.l	(SP)+,D1-D7/A0-A6
	rts
* - - - - - - - - - - - - -
imgpac2	lea	(A3),A4
	sub.l	D7,A4
	move.l	#$10008,(A3)+  (File v1); Palette-less header: 8 words
	move.w	D6,(A3)+	# of planes
	move.w	D0,(A3)+	pattern length
	beq.s	imgpac0
	move.l	D1,(A3)+	Pixel dimensions
	move.l	D5,(A3)+	Image width and height

	move.w	(A0)+,D0	Number of colours
	beq.s	imgpac7
	movea.l	(A0),A0
* - - - - - - - - - - - - - SKIP PALETTE FOR WHITE-BLACK IMG
	cmp.b	#2,D0	If # of colours is 2, a palette is
	bne.s	imgpac4	probably best left out of an
	lea	(A0),A1	IMG file
	addq.l	#3,A1
	move.b	(A1)+,D1
	or.b	(A1)+,D1
	or.b	(A1)+,D1
	beq.s	imgpac7	at least if 2nd colour is black
* - - - - - - - - - - - - - DO PALETTE
imgpac4	move.w	D0,D1
	add.w	D0,D1
	add.w	D0,D1	# of words in palette
	addq.w	#3,D1	+ XIMG palette header
	add.w	D1,-14(A3)	Add to file header length
	move.l	#'XIMG',(A3)+
	clr.w	(A3)+
	lea	(A3),A1
	bsr	TRU_VDI
	subq.w	#3,D1
	add.w	D1,D1	# of bytes in palette
	add.w	D1,A3
* - - - - - - - - - - - - -
imgpac7	move.l	(SP)+,D0
	sub.w	D4,A5	Plane size minus one line
	add.w	D2,D2
	sub.w	D2,A6	Image size minus one evened up line
	subq.w	#1,D6	# of planes -1
	subq.w	#1,D5	# of lines -1
	subq.w	#1,D4	# of bytes/line -1
	subq.l	#4,A4	(space for line repeat command)
	move.l	A4,-(SP)	Save last safe line output address
	move.w	D2,-(SP)	Save line offset within plane
	move.l	D4,A4
	subq.b	#2,D0
	bhi.s	imgpac1	Can't handle pattern length > 2
* - - - - - - - - - - - - - Check IMG line repeat
imgpac8	cmp.l	2(SP),A3
	bhi.s	imgpac1	Not enough memory
	lea	(A2),A0
	lea	(A2),A1
	add.w	(SP),A1
	move.w	D5,D7
	moveq	#1,D1
	bra.s	imgpac11

imgpac9	move.w	A4,D4
imgpac10	cmpm.b	(A0)+,(A1)+
	dbne	D4,imgpac10
	bne.s	imgpac12
	adda.l	A5,A0	Same line, next plane
	adda.l	A5,A1
	dbf	D2,imgpac9
	suba.l	A6,A0
	suba.l	A6,A1
	lea	(A0),A2
imgpac11	move.w	D6,D2
	addq.b	#1,D1
	dbcs	D7,imgpac9
imgpac12	subq.b	#2,D1
	beq.s	imgpac13	No repeat
	sub.w	D1,D5
	addq.b	#1,D1
	sf	(A3)+
	sf	(A3)+
	st	(A3)+
	move.b	D1,(A3)+
* - - - - - - - - - - - - -
imgpac13	move.w	D6,D2
imgpac14	move.w	A4,D4

imgpac15	lea	(A3),A1	A1 -> Start of literal sequence
	addq.l	#2,A3
	moveq	#0,D3	D3: Bytes in current sequence

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
imgpac16	move.b	D1,D7	LITERAL COPY RUN:
	move.b	(A2)+,D1

	beq.s	imgpac17	If D1 = %00000000
	cmp.b	#-1,D1	 or %11111111
	bne.s	imgpac18
imgpac17	tst.b	D3	and if current literal sequence
	beq.s	imgpac31	was just started
	cmp.b	D1,D7
	bne.s	imgpac18
	cmpi.b	#2,D3
	bcs.s	imgpac30
	tst.b	D4	or about to be finished
	beq.s	imgpac30
	cmp.b	(A2),D1	or if 3+ of 'solid' bytes
	beq.s	imgpac30	then use 'solid run'!

imgpac18	cmp.b	-4(A2),D7	Try possible pattern match: 1st
	bne.s	imgpac21
	cmp.b	-3(A2),D1	and 2nd byte.
	bne.s	imgpac21
	cmpi.b	#2,D3	At least 3 bytes must have preceded
	bls.s	imgpac21	for this to be valid
	cmp.b	(A2),D7	Try a further pattern repeat
	bne.s	imgpac21	(A pattern usually needs to be
	tst.b	D0
	bne.s	imgpac36  (1 byte pattern repeated 5 times)
	cmp.b	1(A2),D1	repeated 3 times to be economical)
	bne.s	imgpac21
	bsr.s	imgpac27	End literal copy sequence
	moveq	#1,D3	Include previous 2-byte pattern
	subq.l	#3,A3
	addq.w	#1,D4
	bra	imgpac48	To pattern run!

imgpac19	bsr.s	imgpac35
imgpac20	lea	(A3),A1	A1 -> Start of literal sequence
	addq.l	#2,A3
	moveq	#0,D3

imgpac21	move.b	D1,(A3)+
	addq.b	#1,D3
imgpac22	dbcs	D4,imgpac16	Next byte (LITERAL)
	bcs.s	imgpac23
	bsr.s	imgpac26
	bra	imgpac49

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Break off sequence at $7F/$FF bytes
imgpac23	subq.w	#1,D3	Back 1 byte to $FF
	bsr.s	imgpac26	End literal copy run
	subq.l	#1,A3
imgpac24	subq.l	#1,A2	Back 1 byte
imgpac25	bra.s	imgpac15	Skip dbf

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End literal copy sequence
imgpac26	addq.b	#3,D3	Include last bytes in sequence
imgpac27	subq.b	#2,D3	 or deduct three
imgpac28	subq.b	#1,D3	 or one
	bls.s	imgpac29	Cancel sequence if empty
	move.b	#$80,(A1)+
	move.b	D3,(A1)
	rts
imgpac29	subq.l	#2,A3
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Solid run
imgpac30	subq.l	#1,A3
imgpac31	bsr.s	imgpac28	End literal sequence
	move.b	D1,D7
	addq.b	#1,D3
	beq.s	imgpac33
	moveq	#1,D3
	bra.s	imgpac33

imgpac32	move.b	(A2)+,D1	SOLID RUN
	cmp.b	D1,D7
	bne.s	imgpac19
imgpac33	addq.b	#1,D3
	dbmi	D4,imgpac32	Next byte
	bmi.s	imgpac34	$80 bytes are more than allowed
	bsr.s	imgpac35
	bra.s	imgpac49

imgpac34	subq.w	#1,D3	Back 1 byte to $7F
	bsr.s	imgpac35
	bra.s	imgpac24

imgpac35	andi.b	#$80,D7	End solid run
	or.b	D7,D3
	move.b	D3,(A3)+
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Pattern run - 1-byte pattern
imgpac36	cmp.b	D1,D7
	bne.s	imgpac21
	bsr.s	imgpac27	End literal copy sequence
	moveq	#3,D3	Include previous 3 bytes
	subq.l	#3,A3
	bra.s	imgpac41

imgpac37	bsr.s	imgpac38
	bra.s	imgpac20

imgpac38	clr.b	(A3)+	End pattern run
	move.b	D3,(A3)+
	move.b	D7,(A3)+
	rts

imgpac39	subq.w	#1,D3	Back 1 pattern to $FF
	bsr.s	imgpac38	End pattern run
	bra.s	imgpac24

imgpac40	move.b	(A2)+,D1	1-BYTE PATTERN RUN
	cmp.b	D1,D7
	bne.s	imgpac37
imgpac41	addq.b	#1,D3
	dbcs	D4,imgpac40	Next byte
	bcs.s	imgpac39	$100 bytes are more than allowed
	bsr.s	imgpac38
	bra.s	imgpac49

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Pattern run - 2-byte pattern
imgpac42	subq.w	#1,D3	Back 1 pattern to $FF
	subq.l	#2,A2	= 2 bytes
	addq.w	#1,D4   Total 2 regained by adding 1 + skipping dbf
imgpac43	bsr.s	imgpac44
	bra.s	imgpac25

imgpac44	clr.b	(A3)+	End pattern run
	move.b	D3,(A3)+
	move.b	D7,(A3)+
	move.b	D1,(A3)+
	rts

imgpac45	subq.l	#1,A2
imgpac46	bsr.s	imgpac44
	move.b	-1(A2),D1
	bra	imgpac20

imgpac47	cmp.b	(A2)+,D7	PATTERN RUN: Compare 1st
	bne.s	imgpac46
	cmp.b	(A2)+,D1	and 2nd byte of pattern
	bne.s	imgpac45
imgpac48	addq.b	#1,D3
	bcs.s	imgpac42
	subq.w	#2,D4
	bhi.s	imgpac47	Next pattern
	beq.s	imgpac43
	bsr.s	imgpac44
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
imgpac49	adda.l	A5,A2	Same line, next plane
	dbf	D2,imgpac14
	suba.l	A6,A2
	dbf	D5,imgpac8
	addq.l	#6,SP
	move.l	A3,D0
	movem.l	(SP)+,D1-D7/A0-A6
	sub.l	A3,D0
	rts


*==========================
LBMPAC	movem.l	D0-D7/A0-A6,-(SP)
	lea	(A3),A1	A1 -> destination
	move.l	#'FORM',(A3)+
	addq.l	#4,A3
	move.l	#'ILBM',(A3)+
	move.l	#'BMHD',(A3)+
	moveq	#20,D1
	move.l	D1,(A3)+
	bsr	___pac	Read parameters
	bgt.s	lbmpac2
lbmpac1	addq.l	#4,SP
	moveq	#-1,D0	Error: quick exit
	movem.l	(SP)+,D1-D7/A0-A6
	rts
* - - - - - - - - - - - - -
lbmpac2	move.l	D5,(A3)+	Image width and height
	clr.l	(A3)+	Image X & Y offset
	move.b	D6,(A3)+	# of planes
	clr.b	(A3)+	No mask
	move.b	D0,(A3)+	Compression type
	clr.b	(A3)+	Reserved dummy byte
	clr.w	(A3)+	transparent colour
	bsr	WBRATIO	Make 2-word ratio fit in 2 bytes
	move.b	D0,(A3)+	Pixel width
	move.b	D1,(A3)+	Pixel height
	move.l	D5,(A3)+	Set page dimensions = image dim.
	move.w	(A0)+,D0	Number of colours
	beq.s	lbmpac5
	movea.l	(A0),A0
	move.l	#'CMAP',(A3)+
	move.w	D0,D1
	mulu	#3,D1
	move.l	D1,(A3)+
	subq.w	#1,D0
lbmpac4	move.b	(A0)+,(A3)+
	move.b	(A0)+,(A3)+
	move.b	(A0)+,(A3)+
	dbf	D0,lbmpac4
lbmpac5	move.l	#'BODY',(A3)+
	move.l	(SP)+,D0
	add.l	(SP),A1	A1 -> end of destination memory block
	addq.l	#4,A3
	pea	(A3)	Save address to BODY start

	subq.w	#1,D5	# of lines -1
	subq.w	#1,D6	# of planes -1

	subq.w	#2,D0
	bhi.s	lbmpac1
	beq	lbmpac27	2 = Vertical word compression

	suba.l	D7,A1	A1 -> last safe output line area
	add.w	D2,D2
	sub.w	D2,A6	Image size minus one evened up line-plane

	addq.w	#1,D0
	bne	lbmpac23	0 = No compression
	sub.w	D4,A5	Plane size minus one line
	subq.w	#1,D4	# of bytes/line -1
	move.w	D4,A4
*-------------------------- 1 = PACKBITS COMPRESSION
lbmpac6	cmpa.l	A1,A3
	bhi.s	lbmpac1	Not enough memory
	move.w	D6,D2
lbmpac7	move.w	A4,D4
	move.b	(A2)+,D1
	bra.s	lbmpac18
*ßßßßßßßßßßßßßßßßßßßßßßßßßß
lbmpac8	move.b	D1,D7
	move.b	(A2)+,D1
	cmp.b	D1,D7
	bne.s	lbmpac19
	cmp.b	(A2),D7	You usually need three bytes in a
	bne.s	lbmpac19	repeat seq. to make it economical
	tst.b	D3
	beq.s	lbmpac19
*ßßßßßßßßßßßßßßßßßßßßßßßßßß When a byte = previous (and subsequent) byte:
	bsr.s	lbmpac12
	moveq	#1,D3
lbmpac9	addq.b	#1,D3
	dbmi	D4,lbmpac17
	bmi.s	lbmpac14
	bsr.s	lbmpac10
	bra.s	lbmpac21

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End repeat sequence
lbmpac10	subq.b	#1,D3
	neg.b	D3
	move.b	D3,-1(A3)
	move.b	D7,(A3)+
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End literal sequence
lbmpac11	addq.b	#1,D3	Include last byte in sequence
lbmpac12	subq.b	#2,D3	 or don't (and subtract 1 for dbf)
	bmi.s	lbmpac13	Cancel sequence if empty
	move.b	D3,(A0)
	rts
lbmpac13	subq.l	#1,A3
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Cut sequence at $80 bytes
lbmpac14	bsr.s	lbmpac10
	bra.s	lbmpac16
lbmpac15	bsr.s	lbmpac11
lbmpac16	lea	(A3),A0	A0 -> Start of literal sequence
	addq.l	#1,A3
	moveq	#0,D3
	bra.s	lbmpac20
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷

lbmpac17	move.b	(A2)+,D1
	cmp.b	D1,D7
	beq.s	lbmpac9
*ßßßßßßßßßßßßßßßßßßßßßßßßßß When a byte <> previous byte:
	bsr.s	lbmpac10
lbmpac18	lea	(A3),A0	A0 -> Start of literal sequence
	addq.l	#1,A3
	moveq	#0,D3	D3: Bytes in current sequence
lbmpac19	move.b	D1,(A3)+
	addq.b	#1,D3
lbmpac20	dbmi	D4,lbmpac8
	bmi.s	lbmpac15
	bsr.s	lbmpac11
*ßßßßßßßßßßßßßßßßßßßßßßßßßß
lbmpac21	adda.l	A5,A2	Same line, next plane
	dbf	D2,lbmpac7
	suba.l	A6,A2
	dbf	D5,lbmpac6

*-------------------------- Packing done
lbmpac22	move.l	(SP)+,A0	Start of BODY
	move.l	A3,D0
	suba.l	A0,A3
	move.l	A3,-(A0)	Length of BODY chunk
	movem.l	(SP)+,D1-D7/A0-A6
	sub.l	A3,D0
	subq.l	#8,D0
	move.l	D0,4(A3)	Length of whole ILBM FORM
	addq.l	#8,D0	Length of file
	rts
*-------------------------- 0 = UNCOMPRESSED IFF ILBM
lbmpac23	sub.w	D2,A5	Plane size minus one evened up line
	subq.w	#1,D4
	lsr.w	#1,D4	D4: # of words/line -1
lbmpac24	cmpa.l	A1,A3
	bhi	lbmpac1	Not enough memory
	move.w	D6,D2	plane counter
lbmpac25	move.w	D4,D1	word counter
lbmpac26	move.w	(A2)+,(A3)+
	dbf	D1,lbmpac26
	adda.l	A5,A2	Same line, next plane
	dbf	D2,lbmpac25
	suba.l	A6,A2
	dbf	D5,lbmpac24	Next line
	bra.s	lbmpac22
*-------------------------- 2 = VERTICAL WORD COMPRESSION
lbmpac27	subq.l	#8,A1  4 bytes for following "VDAT", 2 for instr. word
	sub.w	D5,A1	and 2 + 2*D5 for one column
	sub.w	D5,A1	A1 -> last safe column output area

	move.w	D2,D4
	add.w	D4,D4	Image width in bytes evened up
	subq.w	#1,D2

	move.l	A5,D7
	addq.l	#5,D7	Calculate worst case space needed
	divs	#3,D7	for control bytes
	bvc.s	lbmpac28
	moveq	#-1,D7	Max. =
lbmpac28	andi.w	#$7FFE,D7	   32K - 2

	subq.w	#2,A5	# of bytes/plane - 2

	movem.w	D2/D7,-(SP)

*>>>>>>>>>>>>>>>>>>>>>>>>>> VDAT
lbmpac29	movem.w	(SP),D2/A4	#words/line, space for ctrl bytes
	move.l	#"VDAT",(A3)+
	move.l	A3,-(SP)
	addq.l	#6,A3	A3 -> control bytes
	adda.l	A3,A4	A4 -> word data
	move.l	A4,-(SP)
	move.w	D5,-(SP)	Save line count
	cmp.l	A1,A4
	bls.s	lbmpvok
lbmpverr	lea	10(SP),SP
	bra	lbmpac1
lbmpvok	move.w	(A2),D1	Read first word
	bra.s	lbmpac45

*ßßßßßßßßßßßßßßßßßßßßßßßßßß Literal copy loop
lbmpac30	suba.l	A5,A2	Move A2 to next column start
lbmpac31	move.w	D1,D7	D7: previous word
	adda.w	D4,A2
	move.w	(A2),D1	Read word
	cmp.w	D1,D7
	bne.s	lbmpac46	Write it if previous word <> it
	tst.w	D3
	beq.s	lbmpac46	... or not valid
*ßßßßßßßßßßßßßßßßßßßßßßßßßß When a word = previous word:
	bsr.s	lbmpac35	End literal sequence and start
	moveq	#1,D3	repeat seq. counted from prev. word
lbmpac32	addq.w	#1,D3
	dbcs	D5,lbmpac44	Next word (REPEAT)
	bcs.s	lbmpac40	At $10000 words, cut sequence
	move.w	(SP),D5
	cmpa.l	A1,A4
	dbhi	D2,lbmpac43	Next column (REPEAT)
	tst.w	D2
	bgt.s	lbmpverr
	bsr.s	lbmpac33
	bra.s	lbmpac48

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End repeat sequence
lbmpac33	cmp.w	#128,D3
	bhs.s	lbmpac34	If count > 127: word format
	move.b	D3,(A3)+
	rts

lbmpac34	move.b	#1,(A3)+	Repeated word, count in word format
	move.w	D3,-2(A4)	Count
	move.w	D7,(A4)+	and data word
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End literal sequence
lbmpac35	subq.w	#1,D3	Prev. word to new repeat sequence
lbmpac36	beq.s	lbmpac37	Exit if no words in old sequence
	cmp.w	#128,D3	
	bhi.s	lbmpac38	If count > 128: word format
	neg.b	D3
	move.b	D3,(A3)+
lbmpac37	rts

lbmpac38	clr.b	(A3)+	Literal run, count in word format
	addq.l	#2,A4
	lea	(A4),A0
	move.w	D3,D0
lbmpac39	move.w	-4(A0),-(A0)	Move whole sequence one word ...
	dbf	D0,lbmpac39
	move.w	D3,(A6)	... so that count can be inserted
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Cut sequence at $10000 words
lbmpac40	bsr.s	lbmpac34
	bra.s	lbmpac42
lbmpac41	bsr.s	lbmpac38
lbmpac42	lea	(A4),A6	A6 -> Start of literal sequence
	bra.s	lbmpac47
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷

lbmpac43	suba.l	A5,A2  Repeat loop	New column (REPEAT)
lbmpac44	adda.w	D4,A2	New word (REPEAT)
	cmp.w	(A2),D7
	beq.s	lbmpac32
*ßßßßßßßßßßßßßßßßßßßßßßßßßß When a word <> previous word:
	move.w	(A2),D1
	bsr.s	lbmpac33	End repeat sequence and start
lbmpac45	moveq	#0,D3	literal seq. counted from this word
	lea	(A4),A6	A6 -> Start of literal sequence
lbmpac46	move.w	D1,(A4)+	Write word
	addq.w	#1,D3
lbmpac47	dbcs	D5,lbmpac31	Next word (LITERAL)
	bcs.s	lbmpac41	At $10000 words, cut sequence
	move.w	(SP),D5
	cmpa.l	A1,A4
	dbhi	D2,lbmpac30	Next column (LITERAL)
	tst.w	D2
	bgt	lbmpverr

	tst.w	D3
	bsr.s	lbmpac36
*ßßßßßßßßßßßßßßßßßßßßßßßßßß End of literal copy
lbmpac48	move.l	A3,D1	D1 -> End of control bytes
	addq.l	#1,D1	rounded up
	andi.b	#-2,D1
	movea.l	D1,A3

	move.w	(SP)+,D5
	move.l	(SP)+,A0	Move all data words back to
lbmpac49	move.w	(A0)+,(A3)+	where control bytes end
	cmpa.l	A0,A4
	bne.s	lbmpac49

	move.l	(SP)+,A0
	addq.l	#4,A0	A0 -> VDAT start (excl header)
	move.l	A3,D0	D0 -> VDAT end
	sub.l	A0,D0	Length of VDAT chunk
	sub.l	A0,D1	Offset to data words
	move.w	D1,(A0)
	move.l	D0,-(A0)

	addq.l	#2,A2	A2 -> Next source plane
	dbf	D6,lbmpac29
*>>>>>>>>>>>>>>>>>>>>>>>>>>
	addq.l	#4,SP
	bra	lbmpac22


***************************
*	WBRATIO		Called by LBMPAC
* translates two-WORD ratio into an approximately equivalent two-BYTE ratio
* (May seem a big routine for a small task, but I thought it necessary)
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN:  D1 MSW: Width, LSW: Height.  OUT:  D0.B: Width, D1.B: Height
*~~~~~~~~~~~~~~~~~~~~~~~~~~
WBRATIO	movem.l	D2-D7,-(SP)	Make 2-word ratio fit in 2 bytes
	move.w	D1,D3	D3: Height
	beq.s	wbratio4
	swap	D1
	moveq	#0,D2
	move.w	D1,D2	D2: Width
	beq.s	wbratio4
	move.w	D2,D7
	sub.w	D3,D7
	bpl.s	wbratio1
	exg	D2,D3	D2:max D3:min
wbratio1	moveq	#1,D0	First try 1 for out-component 1
wbratio2	move.w	D0,D4
	mulu	D3,D4	In2*Out1
	move.l	D2,D5
	lsr.w	#1,D5
	move.l	D5,D6
	add.l	D4,D5
	divu	D2,D5	/In1
	move.w	D5,D1	=Out2
	swap	D5
	sub.w	D5,D6
	bpl.s	wbratio3
	neg.w	D6
wbratio3	lsl.l	#8,D6
	cmp.l	D4,D6
	bcs.s	wbratio5	Acceptable match
	addq.b	#1,D0	Try other out-component 1
	bcc.s	wbratio2
wbratio4	moveq	#1,D0	Default: 1 for both width
	moveq	#1,D1	and height
wbratio5	tst.w	D7
	bpl.s	wbratio6
	exg	D0,D1
wbratio6	movem.l	(SP)+,D2-D7
	rts

