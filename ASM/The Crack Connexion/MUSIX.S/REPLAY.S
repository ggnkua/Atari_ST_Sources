*****************************************************************
*                      THE CRACK CONNEXION (C)                  *
*****************************************************************
*                                                               *
*  This source code replays Mad max tunes with vu bars          *
* this is just a typical 'MADMAX' replay so just assamble it    *
* and see for your self..........				*
* In the bottom of this routine i load a file under a (.MUS)    *
* file change the first name into any .mus song that is on this *
* disc................                                          *
*   Coding by MARVIN THE ROBOT AND THE EXORCIST .. 3RD NOV'90   *
*      A big hello to 'SHAOLIN MASTERS' esp,URBAN WARFARE AND   *
* BATMAN also to THE BALD EAGLE of AUTOMATION                   *
* Bye for now from -THE EXORCIST- 1ST OF FEBRUARY 1991          *
*****************************************************************     




	MOVE.W	#$20,-(SP)	
	TRAP	#1
	ADDQ.L	#2,SP

	MOVE.W	#3,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PHYS

	MOVE.B	#1,$FFF8260

	MOVEQ	#1,D0		
	JSR	MUSIC
	MOVE.L	#MUSIC+8,MUS

MAIN	BSR	SYNC
	BSR	KEY
	BSR	ZIC
	BSR	EQUA
	BSR	EQUA2
	BSR	EQUAX
	BSR	EQUA2X
	BRA	MAIN

ZIC	MOVE.L	MUS,A0
	JSR	(A0)
	RTS

SYNC	MOVE.W	#37,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	RTS

KEY	CMP.B	#$39,$FFFC02
	BEQ	FIN
	RTS

EQUA	MOVE.B	#8,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+92(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
FIRST	MOVE.B	#-1,(A0)
	LEA	-160(A0),A0
	DBF	D0,FIRST
SEC	CLR.B	(A0)
	LEA	-160(A0),A0
	DBF	D1,SEC

	MOVE.B	#9,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+80(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
THIRD	MOVE.B	#-1,(A0)
	LEA	-160(A0),A0
	DBF	D0,THIRD
FOUR	CLR.B	(A0)
	LEA	-160(A0),A0
	DBF	D1,FOUR

	MOVE.B	#10,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+68(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
FIVE	MOVE.B	#-1,(A0)
	LEA	-160(A0),A0
	DBF	D0,FIVE
SIX	CLR.B	(A0)
	LEA	-160(A0),A0
	DBF	D1,SIX
	RTS

EQUA2	MOVE.B	#8,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+93(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
FIRST2	MOVE.B	#-1,(A0)
	LEA	-160(A0),A0
	DBF	D0,FIRST2
SEC2	CLR.B	(A0)
	LEA	-160(A0),A0
	DBF	D1,SEC2

	MOVE.B	#9,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+81(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
THIRD2	MOVE.B	#-1,(A0)
	LEA	-160(A0),A0
	DBF	D0,THIRD2
FOUR2	CLR.B	(A0)
	LEA	-160(A0),A0
	DBF	D1,FOUR2

	MOVE.B	#10,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+69(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
FIVE2	MOVE.B	#-1,(A0)
	LEA	-160(A0),A0
	DBF	D0,FIVE2
SIX2	CLR.B	(A0)
	LEA	-160(A0),A0
	DBF	D1,SIX2
	RTS

EQUAX	MOVE.B	#8,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+92(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
FIRSTX	MOVE.B	#-1,(A0)
	LEA	160(A0),A0
	DBF	D0,FIRSTX
SECX	CLR.B	(A0)
	LEA	160(A0),A0
	DBF	D1,SECX

	MOVE.B	#9,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+80(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
THIRDX	MOVE.B	#-1,(A0)
	LEA	160(A0),A0
	DBF	D0,THIRDX
FOURX	CLR.B	(A0)
	LEA	160(A0),A0
	DBF	D1,FOURX

	MOVE.B	#10,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+68(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
FIVEX	MOVE.B	#-1,(A0)
	LEA	160(A0),A0
	DBF	D0,FIVEX
SIXX	CLR.B	(A0)
	LEA	160(A0),A0
	DBF	D1,SIXX
	RTS

EQUA2X	MOVE.B	#8,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+93(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
FIRST2X	MOVE.B	#-1,(A0)
	LEA	160(A0),A0
	DBF	D0,FIRST2X
SEC2X	CLR.B	(A0)
	LEA	160(A0),A0
	DBF	D1,SEC2X

	MOVE.B	#9,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+81(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
THIRD2X	MOVE.B	#-1,(A0)
	LEA	160(A0),A0
	DBF	D0,THIRD2X
FOUR2X	CLR.B	(A0)
	LEA	160(A0),A0
	DBF	D1,FOUR2X

	MOVE.B	#10,$FFF8800
	MOVE.B	$FFF8800,D0
	AND	#$FF,D0
	MULU	#2,D0
	MOVE.L	PHYS,A0
	LEA	160*70+69(A0),A0
	MOVE.W	#16*2,D1
	SUB.W	D0,D1
FIVE2X	MOVE.B	#-1,(A0)
	LEA	160(A0),A0
	DBF	D0,FIVE2X
SIX2X	CLR.B	(A0)
	LEA	160(A0),A0
	DBF	D1,SIX2X
	RTS

FIN	CLR.L	MUS
	CLR.L	-(SP)		
	TRAP	#1

MUS	DS.L	1
PHYS	DC.l	0
MUSIC	INCBIN	sowhat4.MUS		; CHANGE THIS FILE NAME TO:
;Any other mad max .mus file you want to hear
*******************************end of program****************************