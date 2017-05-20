	.EXPORT	Power_pack,T_unpack

;
; PowerPacker Decrunch assembler subroutine V2.1
; New version by Pascal Lauly.
;
;  a0  : start of crunched file
;  a1  : just after last byte of crunched file
;  a2  : to memory block to decrunch in
;
; NOTE:
;    Decrunch a few bytes higher (safety margin) than the crunched file
;    to decrunch in the same memory space. (64 bytes suffice)
;

		text

T_unpack:	
		movem.l	d2-d7/a2-a6,-(a7)
		add.l	d0,a0
		move.l	-(a0),d0
		lsr.l	#8,d0
		movem.l	(a7)+,d2-d7/a2-a6
		rts

Power_pack:	
		movem.l	d0-d7/a0-a6,-(a7)
		move.l	a0,a1
		add.l	d0,a1
		move.l	a0,a2
		lea		128(a2),a2
		bsr.s	Decrunch_pp
		movem.l	(a7)+,d0-d7/a0-a6
		rts

Decrunch_pp:
	lea	crundat(pc),a4
	movem.l	a0-a2,(a4)

	move.l	#$00040206,d0
	move.l	#$01050307,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	move.l	d1,d7
	move.l	d0,a0
	move.l	d1,a1
	move.l	d0,a2
	move.l	d1,a3
	move.l	d0,a4
	move.l	d1,a5
	movem.l	d0-a5,-(sp)
	movem.l	d0-a5,-(sp)
	movem.l	d0-a5,-(sp)
	movem.l	d0-a5,-(sp)
	movem.l	d0-d7,-(sp)

	move.l	crundat(pc),a0	;adresse des data crunches
	move.l	4(a0),d0	;efficiency
	move.l	endcrum(pc),a0	;adresse de fin des data crunches
	move.l	buffer(pc),a1	;adresse ou decrunche les data

	moveq	#0,d6
	moveq	#1,d4
	moveq	#23,d3
	move.w	#3,a3
	lea		TABLE1(pc),a4
	lea		TABLE2(pc),a5	
	lea		myBitsTable1(PC),a2
	move.l	d0,(a2)
	subq.b	#1,(a2)
	subq.b	#1,1(a2)
	subq.b	#1,2(a2)
	subq.b	#1,3(a2)
	move.l	(a2),myBitsTable2
	move.l	a1,a2
	move.l	-(a0),d5
	moveq	#0,d1
	move.b	d5,d1
	lsr.l	#8,d5		;taille du fichier decompacte
	add.l	d5,a1
	move.l	-(a0),d5
	lsr.l	d1,d5
	moveq	#31,d7
	sub		d1,d7


Loop:	
	lsr.l	#1,d5		;boucle principale
	bcs		Crunb2
	dbf		d7,N32
	moveq	#31,d7
	move.l	-(a0),d5
N32:	
	subq	#2,d7
	bmi.s	infeq3
	move	d5,d2
	and		d4,d2
	lsr.l	#2,d5
	addx	d2,d2
	cmp.w	a3,d2
	bne		rnb_h3
	
	subq	#2,d7
	bmi		infeq5
	move.b	d5,d6
	and		d4,d6
	lsr.l	#2,d5
	addx	d6,d6
	add.w	d6,d2
	subq.b	#3,d6
	beq		R2BR

rnb_h4:
	subq	#7,d7			;4
	bmi		dblsym_h2		;8,10
	move.b	d5,d6			;4
	move.b	(a4,d6.w),-(a1)	;18
	lsr.l	#8,d5			;24
	dbf		d7,niet			;10,14
	moveq	#31,d7			;4
	move.l	-(a0),d5		;12
	dbf		d2,Rnb
	cmp.l	a1,a2
	bcs		CrunchedBytes
	lea		256(a7),a7
	rts

Tbl4:	dc.b	0,2,1,3

infeq3:
	addq	#1,d7
	beq.s	eql11
	move	d5,d2
	move.l	-(a0),d5
	lsr.l	#1,d5
	addx	d2,d2
	moveq	#30,d7
	cmp.w	a3,d2
	bne.s	rnb_h2
	
	subq	#2,d7
	bmi		infeq5
	move.b	d5,d6
	and		d4,d6
	lsr.l	#2,d5
	addx	d6,d6
	add.w	d6,d2
	subq.b	#3,d6
	beq.s	R2BR

rnb_h3:
	subq	#7,d7			;4
	bmi.s	dblsym_h2		;8,10
	move.b	d5,d6			;4
	move.b	(a4,d6.w),-(a1)	;18
	lsr.l	#8,d5			;24
	dbf		d7,niet			;10,14
	moveq	#31,d7			;4
	move.l	-(a0),d5		;12
	dbf		d2,Rnb
	cmp.l	a1,a2
	bcs		CrunchedBytes
	lea		256(a7),a7
	rts

eql11:
	clr		d2
	move.b	Tbl4(pc,d5.w),d2
	moveq	#31,d7
	move.l	-(a0),d5
	cmp.w	a3,d2
	bne.s	rnb_h

R2BR:	
	subq	#2,d7
	bmi.s	infeq5
	move.b	d5,d6
	and		d4,d6
	lsr.l	#2,d5
	addx	d6,d6
	add.w	d6,d2
	subq.b	#3,d6
	beq.s	R2BR

rnb_h2:
	subq	#7,d7			;4
	bmi.s	dblsym_h2		;8,10
	move.b	d5,d6			;4
	move.b	(a4,d6.w),-(a1)	;18
	lsr.l	#8,d5			;24
	dbf		d7,niet			;10,14
	moveq	#31,d7			;4
	move.l	-(a0),d5		;12
	dbf		d2,Rnb
	cmp.l	a1,a2
	bcs		CrunchedBytes
	lea		256(a7),a7
	rts

dblsym_h2:	
	move.b	(a4,d5.w),d1	;14
	move.l	-(a0),d5		;12
	move.b	d5,d6			;4
	neg		d7				;4
	lsr.l	d7,d5			;8+2p  p<8  p=8-n
	neg		d7				;4
	addq	#8,d7			;4
	lsl.b	d7,d6			;6+2n  n<8
	or.b	(a4,d6.w),d1	;14
	add		d3,d7			;4
	move.b	d1,-(a1)		;8
	dbf		d2,Rnb
	cmp.l	a1,a2
	bcs		CrunchedBytes
	lea		256(a7),a7
	rts

Tbl6:	dc.b	0,2,1,3

infeq5:
	addq	#1,d7
	beq.s	sam
	move.b	d5,d6
	move.l	-(a0),d5
	lsr.l	#1,d5
	addx	d6,d6
	moveq	#30,d7
	add.w	d6,d2
	subq.b	#3,d6
	beq.s	R2BR

rnb_h:
	subq	#7,d7			;4
	bmi.s	dblsym			;8,10
	move.b	d5,d6			;4
	move.b	(a4,d6.w),-(a1)	;18
	lsr.l	#8,d5			;24
	dbf		d7,niet			;10,14
	moveq	#31,d7			;4
	move.l	-(a0),d5		;12
	dbf		d2,Rnb
	cmp.l	a1,a2
	bcs		CrunchedBytes
	lea		256(a7),a7
	rts

sam:
	move.b	Tbl6(pc,d5.w),d6
	moveq	#31,d7
	move.l	-(a0),d5
	add.w	d6,d2
	subq.b	#3,d6
	beq		R2BR	

Rnb:	
	subq	#7,d7			;4
	bmi.s	dblsym			;8,10
	move.b	d5,d6			;4
	move.b	(a4,d6.w),-(a1)	;18
	lsr.l	#8,d5			;24
	dbf		d7,niet			;10,14
	moveq	#31,d7			;4
	move.l	-(a0),d5		;12
niet:	
	dbf		d2,Rnb
	cmp.l	a1,a2
	bcs		CrunchedBytes
	lea		256(a7),a7
	rts
	
dblsym:	
	move.b	(a4,d5.w),d1	;14
	move.l	-(a0),d5		;12
	move.b	d5,d6			;4
	neg		d7				;4
	lsr.l	d7,d5			;8+2p  p<8  p=8-n
	neg		d7				;4
	addq	#8,d7			;4
	lsl.b	d7,d6			;6+2n  n<8
	or.b	(a4,d6.w),d1	;14
	add		d3,d7			;4
	move.b	d1,-(a1)		;8
	dbf		d2,Rnb
	cmp.l	a1,a2
	bcs		CrunchedBytes
	lea		256(a7),a7
	rts

myBitsTable2:	dc.b $09,$0a,$0b,$0b

ReadOffset:
	moveq	#0,d0
	move.b	myBitsTable2(pc,d2.w),d0
	subq	#7,d0
	bmi.s	perte
	subq	#7,d7			;4
	bmi.s	dblsyR			;8,10
	move.b	d5,d6			;4
	move.b	(a4,d6.w),d1	;18
	lsr.l	#8,d5			;24
	dbf		d7,N32fin		;10,14
	moveq	#31,d7			;4
	move.l	-(a0),d5		;12
	dbf		d0,RdBfin
	move.b	(a1,d1.w),-(a1)
	move.b	(a1,d1.w),-(a1)
	dbf		d2,DecrB
	cmp.l	a1,a2
	bcs		Loop
	lea		256(a7),a7
	rts
	
dblsyR:	
	move.b	(a4,d5.w),d1	;14
	move.l	-(a0),d5		;12
	move.b	d5,d6			;4
	neg		d7				;4
	lsr.l	d7,d5			;8+2p  p<8  p=8-n
	neg		d7				;4
	addq	#8,d7			;4
	lsl.b	d7,d6			;6+2n  n<8
	or.b	(a4,d6.w),d1	;14
	add		d3,d7			;4
	dbf		d0,RdBfin
	move.b	(a1,d1.w),-(a1)
	move.b	(a1,d1.w),-(a1)
	dbf		d2,DecrB
	cmp.l	a1,a2
	bcs		Loop
	lea		256(a7),a7
	rts
perte:
	addq	#7,d0
RdBfin:	
	lsr.l	#1,d5
	addx.w	d1,d1
	dbf		d7,N32fin
	moveq	#31,d7
	move.l	-(a0),d5
N32fin:	
	dbf		d0,RdBfin
	move.b	(a1,d1.w),-(a1)
DecrB:	
	move.b	(a1,d1.w),-(a1)
	dbf		d2,DecrB
	cmp.l	a1,a2
	bcs		Loop
	lea		256(a7),a7
	rts

Crunb2:
	dbf		d7,CrunchedBytes
	moveq	#31,d7
	move.l	-(a0),d5

CrunchedBytes:
	moveq	#0,d1
	subq	#2,d7		 ;4
	bmi.s	infeq4		 ;8,10
	move	d5,d2		 ;4
	and		d4,d2		 ;4
	lsr.l	#2,d5		 ;12
	addx	d2,d2		 ;4
	cmp.w	a3,d2
	bne		ReadOffset
	lsr.l	#1,d5
	bcs		LongBlockOffset
	dbf		d7,BK2
	moveq	#31,d7
	move.l	-(a0),d5
	bra.s	BK2
Tbl5:
	dc.b	0,2,1,3
infeq4:
	addq	#1,d7		 ;4
	beq.s	eql12		 ;8,10
	move	d5,d2		 ;4
	move.l	-(a0),d5	 ;12
	lsr.l	#1,d5		 ;10
	addx	d2,d2		 ;4
	moveq	#30,d7		 ;4
	cmp.w	a3,d2
	bne		ReadOffset
	lsr.l	#1,d5
	bcs		LongBlockOffset
	dbf		d7,BK2
	moveq	#31,d7
	move.l	-(a0),d5

	subq	#6,d7			;4
	bmi.s	dblsym2			;8,10
	move.b	d5,d6			;4
	move.b	(a5,d6.w),d1	;14
	lsr.l	#7,d5			;22
	dbf		d7,niet6
	moveq	#31,d7
	move.l	-(a0),d5
	bra.s	niet6

eql12:
	clr		d2		 		;4
	move.b	Tbl5(pc,d5.w),d2 ;14
	moveq	#31,d7		 ;4
	move.l	-(a0),d5	 ;12
	cmp.w	a3,d2
	bne		ReadOffset
	lsr.l	#1,d5
	bcs		LongBlockOffset
	dbf		d7,BK2
	moveq	#31,d7
	move.l	-(a0),d5

BK2:	
	subq	#6,d7			;4
	bmi.s	dblsym2			;8,10
sym2:	
	move.b	d5,d6			;4
	move.b	(a5,d6.w),d1		;14
	lsr.l	#7,d5			;22
	dbf		d7,niet6
	moveq	#31,d7
	move.l	-(a0),d5
niet6:	
	lea		1(a1,d1.w),a6
	subq	#3,d7
	bmi.s	cas2_h
	move.b	d5,d6
	move.b	(a7,d6.w),d6
	lsr.l	#3,d5
	add.w	d6,d2
	subq.b	#7,d6
	beq.s	bK_h	
	move.b	-(a6),-(a1)
	move.b	-(a6),-(a1)
	dbf		d2,DcB_h
	cmp.l	a1,a2
	bcs		Loop
	bra		gainplace2

dblsym2:	
	move.b	(a5,d5.w),d1		;14
	move.l	-(a0),d5		;12
	move.b	d5,d6			;4
	neg		d7			;4
	lsr.l	d7,d5			;8+2p  p<7  p=7-n
	neg		d7			;4
	addq	#7,d7			;4
	lsl.b	d7,d6			;6+2n  n<7
	or.b	(a5,d6.w),d1		;14
	addi	#24,d7			;8
	
Bki_h:	lea	1(a1,d1.w),a6
bK_h:	
	subq	#3,d7
	bmi.s	cas2_h
	move.b	d5,d6
	move.b	(a7,d6.w),d6
	lsr.l	#3,d5
	add.w	d6,d2
	subq.b	#7,d6
	beq.s	bK_h	
	move.b	-(a6),-(a1)
DcB_h:	
	move.b	-(a6),-(a1)
	dbf		d2,DcB_h
	cmp.l	a1,a2
	bcs		Loop
	bra.s	gainplace2
tblu:	dc.b	0,2,1,3
cas2_h:	
	addq	#2,d7
	bmi.s	cas0_h
	bgt.s	caseq_h
	move.b	tblu(pc,d5.w),d6
	move.l	-(a0),d5
	moveq	#30,d7
	lsr.l	#1,d5
	addx	d6,d6
	add		d6,d2
	subq.b	#7,d6
	beq.s	bK_h
	move.b	-(a6),-(a1)
	move.b	-(a6),-(a1)
	dbf		d2,DcB_h
	cmp.l	a1,a2
	bcs		Loop
	bra.s	gainplace2
cas0_h:	
	move.b	d5,d6
	move.l	-(a0),d5
	lsr.l	#1,d5
	addx	d6,d6
	lsr.l	#1,d5
	addx	d6,d6
	moveq	#29,d7
	add.w	d6,d2
	subq.b	#7,d6
	beq.s	bK_h
	move.b	-(a6),-(a1)
	move.b	-(a6),-(a1)
	dbf		d2,DcB_h
	cmp.l	a1,a2
	bcs		Loop
	bra.s	gainplace2
caseq_h:	
	move.b	(a7,d5.w),d6
	move.l	-(a0),d5
	moveq	#31,d7
	add		d6,d2
	subq.b	#7,d6
	beq.s	bK_h
	move.b	-(a6),-(a1)
	move.b	-(a6),-(a1)
	dbf		d2,DcB_h
	cmp.l	a1,a2
	bcs		Loop
gainplace2:
	lea		256(a7),a7
	rts

perte2:
	addq	#7,d0
	bra	Rrr3

myBitsTable1:	dc.b $09,$0a,$0b,$0b

LongBlockOffset:
	moveq	#0,d0
	move.b	myBitsTable1(pc,d2.w),d0
	dbf		d7,NGH
	moveq	#31,d7
	move.l	-(a0),d5
NGH:
	subq	#7,d0
	bmi.s	perte2
	subq	#7,d7			;4
	bmi.s	dblsyZ			;8,10
	move.b	d5,d6			;4
	move.b	(a4,d6.w),d1		;18
	lsr.l	#8,d5			;24
	dbf		d7,NK7			;10,14
	moveq	#31,d7			;4
	move.l	-(a0),d5		;12

	dbf		d0,Rrr3
	lea		1(a1,d1.w),a6
	subq	#3,d7
	bmi		cas2
	move.b	d5,d6
	move.b	(a7,d6.w),d6
	lsr.l	#3,d5
	add.w	d6,d2
	subq.b	#7,d6
	beq.s	Bk	
	move.b	-(a6),-(a1)
	move.b	-(a6),-(a1)
	dbf		d2,DcB
	cmp.l	a1,a2
	bcs		Loop
	bra		gainplace

dblsyZ:	
	move.b	(a4,d5.w),d1		;14
	move.l	-(a0),d5		;12
	move.b	d5,d6			;4
	neg		d7			;4
	lsr.l	d7,d5			;8+2p  p<8  p=8-n
	neg		d7			;4
	addq	#8,d7			;4
	lsl.b	d7,d6			;6+2n  n<8
	or.b	(a4,d6.w),d1		;14
	add		d3,d7			;4

	dbf		d0,Rrr3
	lea		1(a1,d1.w),a6
	subq	#3,d7
	bmi.s	cas2
	move.b	d5,d6
	move.b	(a7,d6.w),d6
	lsr.l	#3,d5
	add.w	d6,d2
	subq.b	#7,d6
	beq.s	Bk	
	move.b	-(a6),-(a1)
	move.b	-(a6),-(a1)
	dbf		d2,DcB
	cmp.l	a1,a2
	bcs		Loop
	bra	gainplace

Rrr3:	
	lsr.l	#1,d5
	addx.w	d1,d1
	dbf		d7,NK7
	moveq	#31,d7
	move.l	-(a0),d5
NK7:	
	dbf		d0,Rrr3

Bki:	
	lea		1(a1,d1.w),a6
Bk:	subq	#3,d7
	bmi.s	cas2
	move.b	d5,d6
	move.b	(a7,d6.w),d6
	lsr.l	#3,d5
	add.w	d6,d2
	subq.b	#7,d6
	beq.s	Bk	
	move.b	-(a6),-(a1)
DcB:	
	move.b	-(a6),-(a1)
	dbf		d2,DcB
	cmp.l	a1,a2
	bcs		Loop
	bra.s	gainplace

tbl2:	dc.b	0,2,1,3
cas2:	
	addq	#2,d7
	bmi.s	cas0
	bgt.s	caseq
	move.b	tbl2(pc,d5.w),d6
	move.l	-(a0),d5
	moveq	#30,d7
	lsr.l	#1,d5
	addx	d6,d6
	add		d6,d2
	subq.b	#7,d6
	beq.s	Bk
	move.b	-(a6),-(a1)
	move.b	-(a6),-(a1)
	dbf		d2,DcB
	cmp.l	a1,a2
	bcs		Loop
	bra.s	gainplace
cas0:	
	move.b	d5,d6
	move.l	-(a0),d5
	lsr.l	#1,d5
	addx	d6,d6
	lsr.l	#1,d5
	addx	d6,d6
	moveq	#29,d7
	add.w	d6,d2
	subq.b	#7,d6
	beq.s	Bk
	move.b	-(a6),-(a1)
	move.b	-(a6),-(a1)
	dbf		d2,DcB
	cmp.l	a1,a2
	bcs		Loop
	bra.s	gainplace
caseq:	
	move.b	(a7,d5.w),d6
	move.l	-(a0),d5
	moveq	#31,d7
	add		d6,d2
	subq.b	#7,d6
	beq.s	Bk
	move.b	-(a6),-(a1)
	move.b	-(a6),-(a1)
	dbf		d2,DcB
	cmp.l	a1,a2
	bcs		Loop
gainplace:
	lea		256(a7),a7
	rts
	
TABLE1:	
	DC.B	0,$80,$40,$C0,$20,$A0,$60,$E0
	DC.B	$10,$90,$50,$D0,$30,$B0,$70,$F0
	DC.B	8,$88,$48,$C8,$28,$A8,$68,$E8
	DC.B	$18,$98,$58,$D8,$38,$B8,$78,$F8
	DC.B	4,$84,$44,$C4,$24,$A4,$64,$E4
	DC.B	$14,$94,$54,$D4,$34,$B4,$74,$F4
	DC.B	$C,$8C,$4C,$CC,$2C,$AC,$6C,$EC
	DC.B	$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
	DC.B	2,$82,$42,$C2,$22,$A2,$62,$E2
	DC.B	$12,$92,$52,$D2,$32,$B2,$72,$F2
	DC.B	$A,$8A,$4A,$CA,$2A,$AA,$6A,$EA
	DC.B	$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
	DC.B	6,$86,$46,$C6,$26,$A6,$66,$E6
	DC.B	$16,$96,$56,$D6,$36,$B6,$76,$F6
	DC.B	$E,$8E,$4E,$CE,$2E,$AE,$6E,$EE
	DC.B	$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
	DC.B	1,$81,$41,$C1,$21,$A1,$61,$E1
	DC.B	$11,$91,$51,$D1,$31,$B1,$71,$F1
	DC.B	9,$89,$49,$C9,$29,$A9,$69,$E9
	DC.B	$19,$99,$59,$D9,$39,$B9,$79,$F9
	DC.B	5,$85,$45,$C5,$25,$A5,$65,$E5
	DC.B	$15,$95,$55,$D5,$35,$B5,$75,$F5
	DC.B	$D,$8D,$4D,$CD,$2D,$AD,$6D,$ED
	DC.B	$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
	DC.B	3,$83,$43,$C3,$23,$A3,$63,$E3
	DC.B	$13,$93,$53,$D3,$33,$B3,$73,$F3
	DC.B	$B,$8B,$4B,$CB,$2B,$AB,$6B,$EB
	DC.B	$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
	DC.B	7,$87,$47,$C7,$27,$A7,$67,$E7
	DC.B	$17,$97,$57,$D7,$37,$B7,$77,$F7
	DC.B	$F,$8F,$4F,$CF,$2F,$AF,$6F,$EF
	DC.B	$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF


TABLE2:	
	DC.B	0,$40,$20,$60,$10,$50,$30,$70
	DC.B	8,$48,$28,$68,$18,$58,$38,$78
	DC.B	4,$44,$24,$64,$14,$54,$34,$74
	DC.B	$C,$4C,$2C,$6C,$1C,$5C,$3C,$7C
	DC.B	2,$42,$22,$62,$12,$52,$32,$72
	DC.B	$A,$4A,$2A,$6A,$1A,$5A,$3A,$7A
	DC.B	6,$46,$26,$66,$16,$56,$36,$76
	DC.B	$E,$4E,$2E,$6E,$1E,$5E,$3E,$7E
	DC.B	1,$41,$21,$61,$11,$51,$31,$71
	DC.B	9,$49,$29,$69,$19,$59,$39,$79
	DC.B	5,$45,$25,$65,$15,$55,$35,$75
	DC.B	$D,$4D,$2D,$6D,$1D,$5D,$3D,$7D
	DC.B	3,$43,$23,$63,$13,$53,$33,$73
	DC.B	$B,$4B,$2B,$6B,$1B,$5B,$3B,$7B
	DC.B	7,$47,$27,$67,$17,$57,$37,$77
	DC.B	$F,$4F,$2F,$6F,$1F,$5F,$3F,$7F
	DC.B	0,$40,$20,$60,$10,$50,$30,$70
	DC.B	8,$48,$28,$68,$18,$58,$38,$78
	DC.B	4,$44,$24,$64,$14,$54,$34,$74
	DC.B	$C,$4C,$2C,$6C,$1C,$5C,$3C,$7C
	DC.B	2,$42,$22,$62,$12,$52,$32,$72
	DC.B	$A,$4A,$2A,$6A,$1A,$5A,$3A,$7A
	DC.B	6,$46,$26,$66,$16,$56,$36,$76
	DC.B	$E,$4E,$2E,$6E,$1E,$5E,$3E,$7E
	DC.B	1,$41,$21,$61,$11,$51,$31,$71
	DC.B	9,$49,$29,$69,$19,$59,$39,$79
	DC.B	5,$45,$25,$65,$15,$55,$35,$75
	DC.B	$D,$4D,$2D,$6D,$1D,$5D,$3D,$7D
	DC.B	3,$43,$23,$63,$13,$53,$33,$73
	DC.B	$B,$4B,$2B,$6B,$1B,$5B,$3B,$7B
	DC.B	7,$47,$27,$67,$17,$57,$37,$77
	DC.B	$F,$4F,$2F,$6F,$1F,$5F,$3F,$7F

crundat:		dc.l	0
endcrum:		dc.l	0
buffer: 		dc.l	0

