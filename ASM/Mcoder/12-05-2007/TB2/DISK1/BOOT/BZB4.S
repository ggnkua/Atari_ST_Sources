	* Belzebub's "Blobb Boot" (June 1990)
	* Blobb by ... Krazy Rex!
Main			Move.l	#$700CC,A2
			Move.w	#$115,D2
FillScreen		Moveq	#$1B,D1
DrawLine		Move.l	#$55553333,(A2)+
			dc.b	$67
			dc.b	$68
			dc.b	6
			dc.b	0
			dc.w	0
			Dc.w	$0A00,$0200
			Move.l	#$0F0F00FF,(A2)+
			Dbra	D1,DrawLine
			Addq.l	#6,A2
			Dbra	D2,FillScreen
			Lea	Blobb(PC),A0
			Moveq	#15,D3
			bra.s	DecrunchBlobb

DecrunchLine		Moveq	#$7,D5
DecrunchPixel		Rol.l	#$4,D0
			MOVEQ	#$F,D2
			AND.B	D0,D2
			Add.w	D2,D2
			Move.w	BlobbColors(PC,D2.W),-(A2)
			Dbra	D5,DecrunchPixel
			Rts
BlobbColors		Dc.w	$020,$030,$040,$050,$060
 			Dc.w	$310,$420,$530,$300,$600
NextSector		dc.w	0,2,0,0,1

DecrunchBlobb		Movem.l	(A0)+,D0/D1
			Bsr.s	DecrunchLine
			Move.l	D1,D0
			Bsr.s	DecrunchLine
			Movem.l	(A2),D4-D7/A3-A6
			Movem.l	D4-D7/A3-A6,-(A2)
			Dbra	D3,DecrunchBlobb
			Subq.l	#$2,A2
			Clr.l	$FFFFFA06.W
			Move.l	A0,$70.W
			Move.w	#$820A,A0
			Move.w	#$700,D0
			Movep.w	D0,-$9(A0)
			Moveq	#$2,D1
			Move.b	D1,(A0)
			Move.w	#$8260,A1
			Stop	#$2300
			Move.w	#$2700,SR
			Move.w	#$58E,D4
Fullscreen		Dbra	D4,Fullscreen
			Subq.l	#$4,A2
			Subq.b	#$2,(A2)
			Addq.b	#$3,-(A2)
			Subq.b	#$7,-(A2)
			Move.l	(A2)+,(A2)
			Addq.l	#$2,A2
			Move.b	D0,(A0)
			Moveq	#$1A,D4
			Lsr.l	D4,D0
			Move.w	#$111,D3
			Move.b	D1,(A0)
			Lsr.l	D4,D4
			Moveq	#$18,D0
			Sub.b	$FFFF8209.w,D0
			Lsr.w	D0,D0
ScanLine		Dbra	D4,ScanLine
			Move.b	(A2),D1
			Lsr.b	#$3,D1
			Move.b	SineWave(PC,D1.W),D1
			Add.b	D1,-(A2)
			Lsr.b	#1,D1
			Add.b	D1,-(A2)
			Move.b	(A2)+,D1
			Lsr.b	#$3,D1
			Move.b	SineWave(PC,D1.W),D1
			Move.b	(A2)+,D6
			And.w	#$F0,D6
			Add.w	D6,D6
			Add.w	D6,D1
			Add.w	D1,D1
			Addq.b	#$2,(A2)
			Movem.l	$2(A2,D1.W),D5-D7/A3-A7
			Move.b	D0,(A0)
			Moveq	#$2,D1
			Move.b	D1,(A0)
			Cmp.w	#$3D,D3
			Beq.s	ScanLineD4
			Cmp.w	#$2D,D3
			Beq.s	ScanLineE4
			Bra.s	NormalScanLine
SineWave		Dc.b	$1,$1,$2,$2,$3,$4,$6,$7
			Dc.b	$8,$A,$B,$D,$E,$F,$F,$10
			Dc.b	$10,$10,$F,$F,$E,$D,$B,$A
			Dc.b	$8,$7,$6,$4,$3,$2,$2,$1
ScanLineD4		Lsr.l	#$4,D0
ScanLineE4		Move.b	D0,(A0)
NormalScanLine		Nop
			Move.b	D1,(A1)
			Moveq	#$4,D4
			Move.b	D0,(A1)
			Movem.l	D5-D7/A3,$FFFF8240.w
			Move.b	D1,(A1)
			Move.b	D1,(A0)
			Move.b	D0,(A1)
			Movem.l	A4-A7,$FFFF8250.w
			Dbra	D3,ScanLine
			Clr.w	$FFFF8240.w
			Move.w	#$667,D4
			Cmp.b	#-$47,$FFFFFC02.w
			Bne	Fullscreen
			Moveq	#7,D7
Cls			Clr.l	-(A1)
			Dbra	D7,Cls
			Lea	NextSector(PC),A7
			clr.l	-(a7)
			Pea	Blobb(PC)
			Move.w	#8,-(A7)
			Trap	#14
Blobb
	DC.W	$A5AA,$AA00,$AAA,$A5AA
	DC.W	$A6AA,$A011,$AA,$A6AA
	DC.W	$57AA,$121,$100A,$A75A
	DC.W	$575A,$1222,$110A,$575A
	DC.W	$5760,$1232,$2100,$675A
	DC.W	$5675,$2343,$2215,$765A
	DC.W	$A572,$3343,$3211,$75AA
	DC.W	$A563,$3444,$3221,$65AA
	DC.W	$123,$4443,$3221,$100A
	DC.W	$123,$4444,$3221,$100A
	DC.W	$123,$3443,$3221,$100A
	DC.W	$22,$3333,$3221,$100A
	DC.W	$A011,$2223,$2211,$AA
	DC.W	$A001,$8822,$2881,$AA
	DC.W	$AA00,$8911,$1980,$AAA
	DC.W	$AA5A,0,$A,$5AAA

Vbl	Rte
