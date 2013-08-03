	OPT	D+
	MOVEQ	#9-1,D2
LOOP
	BSR	LOAD
	lea ecran+128,a0
	lea ecran2,a1
	ADD.L	X,A1
	ADD.L	Y,A1
	move.w #199,d0
cop2
	move.w #159,d1
cop1
	move.b (a0)+,(a1)+
	dbf d1,cop1
	add.l #160*2,a1
	dbf d0,cop2

	ADD.L	#160,X
	CMP.L	#160*3,X
	BNE	SUIT1
	MOVE.L	#0,X
	;lea ecran2,a2
	;SUB.L	A2,A1
	;sub.l	#160,a1
	;MOVE.L	A1,Y
	ADD.L	#160*200*3,Y
SUIT1	DBF	D2,LOOP
	BSR	SAVE
	CLR.W -(A7)
	TRAP #1

X	DC.L 0
Y	DC.L 0
LOAD
	MOVEM.L	D0-D7/A0-A6,-(A7)
	ADD.L	#1,NBR
	MOVE.L	NBR,D4
	MULU #2,D4
	LEA	FILE,A0
	ADD.L	D4,A0
	MOVE.W	#2,-(SP)	
	MOVE.L A0,-(A7)
	MOVE.W	#$3D,-(SP)	
	TRAP	#1		
	ADDA.L	#8,SP		
	MOVE.W	D0,D7		
	PEA	ecran
	MOVE.L	#32128,-(A7)
	MOVE.W	D0,-(SP)	
	MOVE.W	#$3F,-(SP)	
	TRAP	#1		
	ADDA.L	#$C,SP		
	MOVE.W	D7,-(SP)	
	MOVE.W	#$3E,-(SP)	
	TRAP	#1		
	ADDA.L	#4,SP	
	MOVEM.L	(A7)+,D0-D7/A0-A6	
	RTS
NBR	DC.L	0
SAVE
 lea text,a0
 move.l a0,a5
 lea endtext,a1
 move.l a1,d0
 sub.l a0,d0
 move.l d0,d5
 clr.w -(sp)
 pea filename
 move.W #$3c,-(sp)
 trap #1
 add.l #8,sp
 move.w d0,d3
 move.l a5,-(sp)
 move.l d5,-(sp)
 move.w d3,-(sp)
 move.w #$40,-(sp)
 trap #1
 add.l #12,sp
 move.w d3,-(sp)
 move.w #$3e,-(sp)
 trap #1
 addq.l #4,sp
 clr.w -(sp)
 trap #1 
filename:
 dc.B 'main.ste',0
 even
FILE
 dc.b '0 1 2 3 4 5 6 7 8 9',0
 even
	SECTION BSS
ecran	dcb.b	32128
ecran2 
text:
	dcb.b 32000*9
endtext

