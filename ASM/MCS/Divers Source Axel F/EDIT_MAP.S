	PEA	0.W
	MOVE.W	#$20,-(A7)
	TRAP	#1
	
	MOVE.L	#ECRAN1,D0
	AND.L	#-8,D0
	MOVE.L	D0,SCREEN1
	MOVE.L	#ECRAN2,D0
	AND.L	#-8,D0
	MOVE.L	D0,SCREEN2
	
	move	#2,-(a7)
	trap	#14
	addq	#2,a7
	move.l	d0,PHYSIQUE
	
	move.w	#-1,-(a7)
	move.w	#88,-(a7)
	trap	#14
	addq.w	#4,a7
	MOVE.W	D0,OLD_REZ
	
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
	move.w	#3,-(a7)
	move.l	SCREEN1,-(a7)
	move.l	SCREEN1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	add.w	#14,a7
	
	
	LEA	FILENAME1,A0
	BSR	LOAD_PNT
	LEA	FILENAME2,A0
	BSR	LOAD_PNT
	LEA	FILENAME3,A0
	BSR	LOAD_PNT
	
	CLR.L	-(A7)
	TRAP	#1
***************************************************************************
LOAD_PNT
	BSR	FOPEN
	MOVE.L	ADDFIN,A0
	MOVE.L	#129000,D0
	BSR	FREAD
	BSR	FCLOSE
	MOVE.L	ADDFIN,A0
	BSR	DEL_128
	RTS
***************************************************************************
DEL_128 MOVE.L	A0,A1
	LEA	128(A0),A0
	MOVE.L	#(122880/32)-1,D0
	
COP1	REPT	8
	MOVE.L	(A0)+,(A1)+
	ENDR
	DBF	D0,COP1
	MOVE.L	A1,ADDFIN
	RTS
***************************************************************************
FCREATE	MOVE.W	#$0,-(A7)
	MOVE.L	A0,-(A7)
	MOVE.W	#$3C,-(A7)
	TRAP	#1
	ADDQ.W	#8,A7
	MOVE.W	D0,HANDLE
	RTS

***************************************************************************
FOPEN	MOVE.W	#$2,-(A7)
	MOVE.L	A0,-(A7)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.W	#8,A7
	MOVE.W	D0,HANDLE
	RTS
	
***************************************************************************
FREAD	MOVE.L	A0,-(A7)
	MOVE.L	D0,-(A7)
	MOVE.W	HANDLE,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADD.W	#12,A7
	RTS
	
***************************************************************************
FWRITE	MOVE.L	A0,-(A7)
	MOVE.L	D0,-(A7)
	MOVE.W	HANDLE,-(A7)
	MOVE.W	#$40,-(A7)
	TRAP	#1
	ADD.W	#12,A7
	RTS
	
***************************************************************************
FCLOSE	MOVE.W	HANDLE,-(A7)	
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.W	#4,A7
	RTS
***************************************************************************
FILENAME1	DC.B	"D:\DESSIN\TRUEPAIN.T\DEC1.TPI",0
FILENAME2	DC.B	"D:\DESSIN\TRUEPAIN.T\DEC2.TPI",0
FILENAME3	DC.B	"D:\DESSIN\TRUEPAIN.T\DEC3.TPI",0
		EVEN
ADDFIN		DC.L	ECRAN2+4
ADDMAP		DC.L	MAP
***************************************************************************
	SECTION	BSS
PHYSIQUE	DS.L	1
OLD_REZ		DS.W	1
HANDLE		DS.W	1
MAP		DS.L	10*100	
SCREEN1		DS.L	1
SCREEN2		DS.L	1
ECRAN1		DS.W	320*200
ECRAN2		DS.W	320*200
