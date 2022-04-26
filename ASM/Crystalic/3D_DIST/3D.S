*****************************************
*					*
*   3D - KUBEN AV FEAR OF C.A.C - 92    *  
*					*
*****************************************
	JSR	SETSCREEN
	dc.w	$A000
	move.l	d0,LINEA

	MOVE.W	#30,GRAD
LOOP:
	JSR	CLEAR
	JSR	READDATA
	ADDQ.W	#4,GRAD
	CMP.W	#359,GRAD
	BLE	LOOP
	MOVE.W	#0,GRAD
	JMP	LOOP

	CLR.W	-(SP)
	TRAP	#1
*****************************************		
SETSCREEN:
	MOVE.W	#0,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.W	#$5,-(SP)
	TRAP	#14
	ADD.L	#12,SP
	RTS
*****************************************		
CLEAR:
	MOVE.L	#$78000+160*50,A0
	MOVE.W	#100,D0
CLRLOOP:
	CLR.W	(A0)
	CLR.W	8(A0)
	CLR.W	16(A0)
	CLR.W	24(A0)
	CLR.W	32(A0)
	CLR.W	40(A0)
	CLR.W	48(A0)
	CLR.W	56(A0)
	CLR.W	64(A0)
	CLR.W	72(A0)
	CLR.W	80(A0)
	CLR.W	88(A0)
	CLR.W	96(A0)
	CLR.W	104(A0)
	CLR.W	112(A0)
	CLR.W	120(A0)
	CLR.W	128(A0)
	CLR.W	136(A0)
	CLR.W	144(A0)
	CLR.W	152(A0)
	ADD.W	#160,A0
	DBF.W	D0,CLRLOOP
	RTS
*****************************************		
READDATA:
	MOVE.W	GRAD,D7
	MULS	#16,D7
	MOVE.L	#LDATA,A6
READDATALOOP:
	MOVE.W	(A6)+,D1
	CMP.W	#-1,D1
	BEQ	READDATAWRAP
	MOVE.W	(A6)+,D2
	
	MOVE.L	#PDATA,A1
	ADD.W	D7,A1
	MOVE.L	A1,A2

	ADD.W	D1,A1		
	MOVE.W	(A1),X1
	MOVE.W	2(A1),Y1

	ADD.W	D2,A2
	MOVE.W	(A2),X2
	MOVE.W	2(A2),Y2		

	SUB.W	#160,X1
	SUB.W	#160,X2
	JSR	LINE
	JMP	READDATALOOP
READDATAWRAP:
	RTS		
*****************************************		
LINE:
	move.l	LINEA,a0
	move.w	X1,$26(a0)	x1
	move.w	Y1,$28(a0)	y1
	move.w	X2,$2A(a0)	x2
	move.w	Y2,$2C(a0)	y2
	move.w	#1,$18(a0)	bitplane 0
	move.w	#0,$1A(a0)	bitplane 1
	move.w	#0,$1C(a0)	bitplane 2
	move.w	#0,$1E(a0)	bitplane 3
	move.w	#$FFFF,$22(a0)	linepattern
	move.w	#0,$24(a0)	writemode, 0=replace
	dc.w	$a003
	rts
*****************************************		
READKEY:
 	MOVE.W	#8,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	RTS	
*****************************************		
LINEA:		DC.L	0
GRAD:		DC.W	0
X1:		DC.W	0
Y1:		DC.W	0
X2:		DC.W	0
Y2:		DC.W	0
		EVEN
LDATA:		DC.W	0,4,4,8,8,12,12,0
		DC.W	16,20,20,24,24,28,28,16
		DC.W	0,16,4,20,8,24,12,28
		DC.W	-1
		EVEN
PDATA:		INCLUDE	B:\KUB.DAT
*****************************************
