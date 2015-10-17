	opt	o-

	PEA	0.W
	MOVE.W	#$20,-(A7)
	TRAP	#1
	
	move.w	#-1,-(a7)
	move.w	#88,-(a7)
	trap	#14
	addq.w	#4,a7
	move.w	d0,rezo
	
	btst	#4,d0
	beq.s	pasvga
	bset	#8,d0
	bra.s	bon
pasvga	bclr	#8,d0	
bon	bclr	#7,d0
	bclr	#6,d0
	bclr	#3,d0
	bset	#2,d0
	bclr	#1,d0
	bclr	#0,d0
	move.w	d0,-(a7)
	move.w	#1,-(a7)
	move.l	#$270000,-(a7)
	move.l	#$270000,-(a7)
	move.w	#5,-(a7)
	trap	#14
	add.w	#14,a7
	
	
	MOVE.L	$70,SA70+2	
	MOVE.L	#VBL,$70
	
WAIT	CMP.B	#$39,$FFFFFC02.W
	BNE.S	WAIT	
	
SA70	MOVE.L	#0,$70

	move.w	rezo,-(a7)
	move.w	#3,-(a7)
	move.l	#$270000,-(a7)
	move.l	#$270000,-(a7)
	move.w	#5,-(a7)
	trap	#14
	add.w	#14,a7
	
	CLR.L	-(A7)
	TRAP	#1
	
***************************************************************************
VBL	
	MOVE.L	#$FF,$FFFF9800
	MOVE.W	#7,$FFFF8240.W
	MOVEM.L	D0-A6,-(A7)
	
	LEA	ECRAN,A0
	LEA	ECRAN,A1
	LEA	ECRAN,A3
	MOVEQ	#1,D2
	MOVEQ	#1,D1
	MOVE.L	#132260/16,D0
	
ICI	REPT	16
	ADD.W	D1,D2
	ENDR
	
	DBF	D0,ICI
	
	MOVEM.L	(A7)+,D0-A6
	MOVE.L	#-1,$FFFF9800.W
	MOVE.W	#$FFF,$FFFF8240.W
	RTE
***************************************************************************
* EN 1 VBL 320*200*TC ON PEUT FAIRE (EN GROS ET SANS CACHE)
*  - 16000 MOVE.W (A0)+,10(A1)			* 16000 PTS*
*  - 11320 MOVE.L (A0)+,10(A1)			* 22640 PTS*
*  - 11000 MOVE.L #10,10(A1)			* 22000 PTS*
*  -  1170 MOVEM.L (A0)+,D0-D7/A2-A6		* 30420 PTS*
*          MOVEM.L D0-D7/A2-A6,10(A1)
*  - 22000 MOVE.L  D0,(A0)+			* 44000 PTS
*  - 14000 MOVE.W  (A0,D1.W),10(A1) = MOVE.W (A0,D1.L),10(A1)
*  - 12000 MOVE.L  (A0,D1.W),10(A1)		* 24000 PTS
*  - 58000 NOP

* EN 1 VBL 320*200*TC ON PEUT FAIRE (EN GROS ET AVEC CACHE)
*  - 19000 MOVE.W (A0)+,10(A1)			* 19000 PTS
*  - 14000 MOVE.L (A0)+,10(A1)			* 28000 PTS
*  - 19000 MOVE.L #0,10(A1)			* 36000 PTS
*  - 24000 CLR.L  10(A1)			* 48000 PTS
*  -  1300 MOVEM.L (A0)+,D1-D7/A2-A6		* 31200 PTS
*          MOVEM.L D1-D7/A2-A6,10(A1)
*  -  9000 MULU.W D0,D1  = MULS
*  -  5600 MULU.L D0,D1
*  -  8500 MULU.W #5,D1  = MULS
*  -  6000 DIVU.W D0,D1
*  -  5600 DIVU.W #5,D1
*  -  5000 DIVS.W D0,D1
*  -  5000 DIVS.W #5,D1
*  - 30000 LSR.L #5,D1
*  - 20000 AND.L D0,10(A1)
*  - 20000 OR.L D0,10(A1)
*  - 38500 NOP

* EN 1 VBL 320*200*TC ON PEUT FAIRE (EN GROS ,AVEC CACHE ET OPTIMISATION)
*  - 26500 MOVE.W  (A0)+,10(A1)			* 26500 PTS*
*  - 16300 MOVE.L  (A0)+,10(A1)			* 32600 PTS*
*  - 16350 MOVE.L  (A0)+,(A1)+			* 32700 PTS*
*  -  1300 MOVEM.L (A0)+,D1-D7/A2-A6		* 31200 PTS
*          MOVEM.L D1-D7/A2-A6,10(A1)
*  -  2700 MOVEM.L D1-D7/A1-A6,-(A0)		* 43200 PTS
*  - 32700 MOVE.L  D0,(A0)+ < MOVE.L D0,10(A0)	* 65400 PTS*
*  - 26000 CLR.L   (A0)+			* 52000 PTS
*  - 32300 CLR.L   10(A0)			* 64600 PTS*
*  - 29000 MOVE.W  (A0,D0.W),10(A1)		* 29000 PTS	
*  - 22550 MOVE.L  (A0,D0.W),10(A1)		* 45100 PTS*
*  - 26200 MOVE.L  (A0,D0.W),(A1)+		* 52400 PTS*
*  - 42580 MOVE.W  (A0,D1.W*2),D2		* 85160 PTS*
*  - 13350 MOVE.L  (A1)+,(A0,D0.W)		* 26700 PTS*
*  - 55200 ADD.W   D2,10(A0)    		*          *
*  - 27000 AND.L   D0,10(A1)  = OR.L
*  - 15500 AND.L   D0,(A1)+   = OR.L
*  - 11000 MULU.W  D0,D1
*  - 71780 LEA     4(A0),A0                     *          *
*  - 49500 ADD.W   #4,A0                        *          *
*  -132260 ADDQ.W  #4,A0                        *          *
*  -132260 ADDX.W  D1,D2                        *          *
*  -132260 ADD.W   D1,D2                        *          *
*  -150000 NOP                                  *          *
rezo	dc.w	0
ECRAN

