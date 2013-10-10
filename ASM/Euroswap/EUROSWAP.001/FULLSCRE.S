	opt	p+,o+
main:
	move.w	#$0,$ffff8240.w
	move.w	#$007,$ffff8244.w
	
	move.l	$70.w,a0
	lea	old(pc),a1
	move.l	a0,(a1)
	lea	reg(pc),a6
	
	MOVE.B	$FFFF8260.W,(A6)+	;RESO
	MOVE.B	$FFFF8201.W,(A6)+	;HIGH SCRADR BYTE
	MOVE.B	$FFFF8203.W,(A6)+	;LOW  SCRADR	BYTE
	move.b	$FFFF820A.W,(a6)+
	
	
	
	LEA	$FFFFFA00.W,A0
	movem.l	(a0)+,d0-d2
	movem.l	d0-d2,(a6)
		
	MOVE.W	#$2700,SR
	
	******adresse de l'ecran logique et physique*********
	
	lea	$609d4,a0

	moveQ	#16,d3		*16 lignes de motifs
		
motif:
	lea	sprite(pc),a1		*adresse sprite
	moveQ	#16,d0			*16 lignes a copier
	
ret:	
	moveQ	#8,d1			*8 motifs par ligne de motif
ligne 	
	move.w	(a1),2(a0)
	move.w	2(a1),10(a0)		*copie vers ecran
	move.w	4(a1),18(a0)
	lea	24(a0),a0		*48 pixels suivants
	dbra	d1,ligne
	
	lea	230-216(a0),a0		*ligne suivante
	lea	6(a1),a1
	dbra	d0,ret
	
	dbra	d3,motif		*ligne de motif suivante
	
	MOVE.L	#$609,D0		*envoie l'adresse pour le shifter
	
	LEA	$FFFF8200.w,A0
	MOVEP.W	D0,1(A0)
	LEA	VSYNC(PC),A0
	MOVE.L	A0,$70.W
	MOVEQ	#$0,D0
	LEA	$FFFFFA00.W,A0
	MOVEP.W	D0,7(A0)
	MOVEQ	#$2,D1
	LEA	$FFFF820A.W,A0
	LEA	$FFFF8260.W,A1
	MOVE.B	D1,(A0)
	MOVE.B	D0,(A1)
	STOP	#$2300
	STOP	#$2300
	MOVE.W	#$2700,SR
	MOVE.W	#$594,D4
FULLSCREEN:
	DBRA	D4,FULLSCREEN
	MOVE.B	D0,(A0)
	MOVEQ	#$1A,D4
	LSR.L	D4,D0
	MOVE.W	#$111,D3
	MOVE.B	D1,(A0)
	LSR.L	D4,D4
	MOVEQ	#24,D0
	SUB.B	$FFFF8209.W,D0
	LSR.L	D0,D0
	MOVEQ	#19,D4
SCANLINE:
	DBRA	D4,SCANLINE
	MOVE.B	D0,(A0)
	MOVEQ	#$2,D1
	MOVE.B	D1,(A0)
	CMP.W	#$3D,D3
	BEQ.S	SCANLINED4
	CMP.W	#$2D,D3
	BEQ.S	SCANLINEE4
	BRA.S	NORMALSCANLINE
SCANLINED4:
	LSR.L	#$4,D0
SCANLINEE4:
	MOVE.B	D0,(A0)
NORMALSCANLINE:
	NOP
	MOVE.B	D1,(A1)
	MOVEQ	#18,D4
	
	MOVE.B	D0,(A1)
	LSR.L	D4,D0
	MOVE.B	D1,(A1)
	MOVE.B	D1,(A0)
	MOVE.B	D0,(A1)
	LSR.L	D4,D0
	MOVEQ	#23,D4
	NOP
	DBRA	D3,SCANLINE
	MOVE.W	#1644,D4
	add.w	#$1,$ffff8244.w
	
	CMPI.B	#$39,$FFFFFC02.W
	beq.s	fin
	BRA.S	FULLSCREEN
VSYNC:
	RTE

fin:
	lea	reg(pc),a6
	
	MOVE.B	(a6)+,$FFFF8260.W	;RESO
	stop	#$2300
	
	MOVE.B	(a6)+,$FFFF8201.W	;HIGH SCRADR BYTE
	MOVE.B	(a6)+,$FFFF8203.W	;LOW  SCRADR	BYTE
	move.b	(a6)+,$FFFF820A.W
	
	LEA	$FFFFFA00.W,A0
	movem.l	(a6),d0-d2
	movem.l	d0-d2,(a0)
	 
	move.l	old(pc),$70.w
	
	move.w	#$fff,$ffff8240.w
	
	rts
	
sprite	incbin f:sprite.bin	
	
old	dc.l	0

reg	dcb.l	8,0
	



