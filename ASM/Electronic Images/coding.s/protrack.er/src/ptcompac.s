;******** EQUAL BYTES COMPACTER ********

Main	move.l	DataPtr(PC),a0	;From ptr.
	move.l	#$50000,a1	;To ptr.
	move.l	DataLen(PC),d7	;Length
	move.w	Lowest(PC),d3
	moveq	#0,d4		; Clear count

EqLoop	move.b	(a0)+,d0	; Get a byte
	cmp.b	d0,d3		; Same as compacter code?
	beq	JustCode	; Output JustCode
	cmp.l	#1,d7
	beq	endskip
	cmp.b	(a0),d0		; Same as previous byte?
	beq	Equal		; Yes, it was equal
endskip	tst.w	d4		; Not equal, any equal buffered?
	bne	FlushBytes	; Yes, output them
PutByte	move.b	d0,(a1)+	; output byte
	moveq	#0,d4
NextByte
	move.w	d0,$dff180	; Flash colors
	subq.l	#1,d7		; Subtract 1 from length
 	bne	EqLoop		; Loop until length = 0

	tst.w	d4		; Any buffered bytes?
	beq	endok		; No, goto end
	cmp.w	#3,d4		; More than 4?
	bhs	FourOrMore2	; Yes, skip
NotFour2
	move.b	d0,(a1)+	; Output byte
	dbf	d4,NotFour2	; Loop...
	bra	endok		; Goto end
FourOrMore2
	move.b	d3,(a1)+	; Output compacter code
	move.b	d4,(a1)+	; Output count
	move.b	d0,(a1)+	; Output byte
endok	sub.l	DataPtr(pc),a1	; Subtract start from end
	move.l	a1,d0		; Store compacted length
	move.l	DataLen,d1
	move.l	d1,d2
	sub.l	d0,d1
	mulu	#100,d1
	divu	d2,d1
	move.l	d2,$50000-4
	rts			; Return...

;-------------------------------

JustCode
	move.b	d3,(a1)+	; Output compacter code
	clr.b	(a1)+		; Output zero
	move.b	d3,(a1)+	; Output compacter code
	bra	NextByte	; Do next byte

Equal	move.b	d0,d1
	addq.w	#1,d4		; Add one to equal-count
	cmp.w	#255,d4		; 255 or more?
	bhs	FlushBytes	; Yes, flush buffer
	bra	NextByte	; Do next byte

FlushBytes
	cmp.w	#3,d4		; 4 or more
	bhs	FourOrMore	; Yes, output codes
NotFour	move.b	d1,(a1)+	; Output byte
	dbf	d4,NotFour	; Loop...
	moveq	#0,d4		; Zero count
	bra	NextByte	; Another byte
FourOrMore
	move.b	d3,(a1)+	; Output compacter code
	move.b	d4,(a1)+	; Output count
	move.b	d1,(a1)+	; Output byte
	moveq	#0,d4		; Zero count
	addq.b	#1,d0
	bra	NextByte	; Do next byte

DataPtr:	dc.l $40000
DataLen:	dc.l 8008
CompLen:	dc.l 0
Lowest:		dc.w 181

>extern "df1:raw/ptsetup2.raw",$40000

