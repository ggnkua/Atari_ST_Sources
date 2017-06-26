; test for 3bpl c2p conversion..

		bsr	generate_3bpl_tab

		lea	screen,a0
		lea	chunky,a1

c2p3aloopstart:	movem.w	(a1)+,d0-d3		; 28

		lsl.w	#3,d0			; 12
		or.w	d1,d0			;  4
		move.w	(a2,d0.l),d0		; 14
c2p3aoffset1:	=	*+2
		movep.w	d0,0(a0)		; 16
		move.w	2(a2,d0.l),d0		; 12

		lsl.w	#3,d2			; 12
		or.w	d3,d2			;  4
		move.w	(a2,d2.l),d1		; 14
c2p3aoffset2:	=	*+2
		movep.w	d1,1(a0)		; 16
		move.b	2(a2,d2.l),d0		; 12

c2p3aoffset2a:	=	*+2
		move.w	d0,4(a0)		; 12
						; -- +
						;156
c2p3aloopend:

		clr.w	-(sp)
		trap	#1

generate_3bpl_tab:
	LEA	temp_buf+c2plookup,A6
	LEA	TAB1(pc),A0
	MOVEQ	#0,D3

.GENLOOP1:
	LEA	TAB3(pc),A2
	MOVEQ	#0,D4

.GENLOOP2:
	moveq	#4-1,d7

.GENLOOP2a:
	MOVEQ	#0,D5
	LEA	TAB2(pc),A1

.GENLOOP3:
	MOVEQ	#$8-1,D6
	LEA	TAB4(pc),A3
	MOVE.L  (A0),D2
	OR.L	(A1),D2
	OR.L	(A2),D2

.GENLOOP4:
	MOVE.L	D2,D0
	OR.L	(A3)+,D0
	MOVE.L  D0,(A6)+
	DBF	D6,.GENLOOP4

	ADDQ	#4,A1
	ADDQ.W  #4,D5
	CMP.B   #$20,D5
	BNE.S   .GENLOOP3

	dbf	d7,.GENLOOP2a

	ADDQ	#4,A2
	ADDQ.W  #4,D4
	CMP.B   #$20,D4
	BNE.S   .GENLOOP2

	ADDQ	#4,A0
	ADDQ.W  #4,D3
	CMP.B   #$20,D3
	BNE.S   .GENLOOP1
	rts


chunky:		dc.b	1,2,3,4,5,6,7,8
screen:		ds.b	8

