*****************************************
*LITTLE SPRITES ROUT WITH THE BLITTER...*
*       by Cristalion/Hydroxid          *
*****************************************

*	opt	o+,d+,w+

	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	BSR	SAVE_BLITTER
	BSR	VBL
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR	VBL
	BSR	INITS
	BSR	CLS
	BSR	VBL
	BSR	BOUCLE
*****************************PART_PRINCIPALE***********************************
BOUCLE
	BSR	EFFA
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$AA,$FFFF9800
NO_ALT	BSR	VBL
	CLR.L	$FFFF9800
	CMPI.B	#57,$FFFFC02
	BNE	BOUCLE
	JMP	FIN
***************************INITIALISATIONS*********************************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	

	MOVE.L	#SCREEN,D0	
	ADD.L	#4000,D0
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000001100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	add.l	 #46080*2,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS
***********************************************************************************************
******************************SOUS ROUTINES****************************************************
***********************************************************************************************
SAVE_BLITTER
	MOVE.W	$FF8A36,SAV_8A36
	MOVE.W	$FF8A38,SAV_8A38
	MOVE.W	$FF8A20,SAV_8A20
	MOVE.W	$FF8A22,SAV_8A22
	MOVE.W	$FF8A28,SAV_8A28
	MOVE.W	$FF8A2A,SAV_8A2A
	MOVE.W	$FF8A2C,SAV_8A2C

	MOVE.L	$FF8A32,SAV_8A32
	MOVE.W	$FF8A2E,SAV_8A2E
	MOVE.W	$FF8A30,SAV_8A30
	MOVE.B	$FF8A3D,SAV_8A3D
	MOVE.B	$FF8A3A,SAV_8A3A
	RTS
RESTORE_BLITTER
	MOVE.W	SAV_8A36,$FF8A36
	MOVE.W	SAV_8A38,$FF8A38
	MOVE.W	SAV_8A20,$FF8A20
	MOVE.W	SAV_8A22,$FF8A22
	MOVE.W	SAV_8A28,$FF8A28
	MOVE.W	SAV_8A2A,$FF8A2A
	MOVE.W	SAV_8A2C,$FF8A2C

	MOVE.L	SAV_8A32,$FF8A32
	MOVE.W	SAV_8A2E,$FF8A2E
	MOVE.W	SAV_8A30,$FF8A30
	MOVE.B	SAV_8A3D,$FF8A3D
	MOVE.B	SAV_8A3A,$FF8A3A
	RTS
EFFA
	LEA	CLR,A0
	MOVE.L	WORKECR,A1
	MOVEQ	#0,D2
 	MOVE.B	#2,$FFFF8A3A		; coupe ram de demi teinte
	MOVE.B	#0,$FFFF8A3B		; operations logiques
	MOVE.W	#0,$FF8A22		; Increment Vertical Source
	MOVE.W	#0,$FF8A20		; distance entre un mot et le suivant
	MOVE.W	#24,$FF8A36		; taille d'une ligne en mots
	MOVE.W	#-1,$FF8A28		; 3 registres pour les masques
	MOVE.W	#-1,$FF8A2A		; (permet de gerer au pixel pres !!)	
	MOVE.W	#-1,$FF8A2C		
;dest
	MOVE.W	#16,$FFFF8A2E		; Increment Horizontal Destination
	MOVE.W	#16,$FFFF8A30		; IVD
*****PLAN-1***********
; source	
	MOVE.L	A0,$FF8A24		; addresse bloc a transferer
	MOVE.W	#240,$FF8A38		; taille verticale
; destination
	MOVE.L	A1,$FFFF8A32	
	MOVE.B	D2,$FFFF8A3D		; registre pour decalage vers la droite
;		  XXX-XXXX		; registre de controle
 	MOVE.B	#%11000000,$FF8A3C    	; si bit 6 a 0:PARTAGE DE BUS sinon 680*0 stoppe jusqu'a fin du transfert				
	RTS

VBL	MOVE.L	D3,-(SP)
	move.l	$466.w,d3
SYNC	cmp.l	$466.w,d3
	beq.s	SYNC
	MOVE.L	(SP)+,D3
	RTS
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	move.l workecr,a1
	MOVE.W	#23039,D0
	MOVEQ.L	#0,D1
OK
	MOVE.L	D1,(A0)+
	MOVE.L 	D1,(a1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
********************THE END*********************************
FIN	
*	CLR.L	$4D2
*	JSR	PLAYER+4
	BSR	RESTORE_BLITTER
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	BSR	VBL
	MOVE.W	#$777,$FFFF8240.W
	MOVE.W	#0,$FFFF8246.W
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

		SECTION	DATA
AFFECR:		DC.L 	0
WORKECR:	DC.L 	0
OLDXBIOS2:	DC.L	0
OLDMODECODE	DC.W	0
SCREEN_ADD	DC.L	0
SAV_8A36	DC.W	0
SAV_8A38	DC.W	0
SAV_8A20	DC.W	0
SAV_8A22	DC.W	0
SAV_8A28	DC.W	0
SAV_8A2A	DC.W	0
SAV_8A2C	DC.W	0
SAV_8A32	DC.L	0
SAV_8A2E	DC.W	0
SAV_8A30	DC.W	0
SAV_8A3D	DC.B	0
SAV_8A3A	DC.B	0
CLR		DCB.L	0
		SECTION	BSS
		DS.L	2000
PILE		DS.L	10
SCREEN		DS.W	100000
	END
 																								  																								 																								  																																								