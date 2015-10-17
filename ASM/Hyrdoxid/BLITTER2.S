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
	BSR.	VBL
	BSR	INITS
	BSR	CLS
	PEA	NAIN+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP	
	BSR	BOUCLE
*****************************PART_PRINCIPALE***********************************
BOUCLE
	MOVE.W	#0,$FFFF8240
	BSR	INIT_BLITTER	
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.W	#5,$FFFF8240	
NO_ALT	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	BOUCLE
	JMP	FIN
***************************INITIALISATIONS*********************************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		*
	MOVE.W	#88,-(SP)		*
	TRAP	#14			*
	ADDQ.L	#4,SP			*
	MOVE.W	D0,OLDMODECODE		*

	MOVE.W	#0,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	subi.l #$7d00,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR

	MOVE.W	#0,-(SP)
	MOVE.L	AFFECR,-(SP)
	MOVE.L	AFFECR,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
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
INIT_BLITTER
****************
; source	
	MOVE.B	#3,$FF8A3A		; operations logiques
	MOVE.L	#NAIN+34,$FF8A24	; addresse bloc a transferer
	MOVE.W	#20,$FF8A36		; taille d'une ligne en mots
	MOVE.W	#200,$FF8A38		; taille verticale
	MOVE.W	#8,$FF8A20		; distance entre un mot et le suivant
	MOVE.W	#8,$FF8A22		; Increment Vertical Source
	MOVE.W	#-1,$FF8A28		; 3 registres pour les masques
	MOVE.W	#-1,$FF8A2A		; (permet de gerer au pixel pres !!)	
	MOVE.W	#-1,$FF8A2C		

; destination
	MOVE.L	WORKECR,A0		; addresse destination
	LEA	(A0),A0
	MOVE.L	A0,$FFFF8A32	
	MOVE.W	#8,$FFFF8A2E		; Increment Horizontal Destination
	MOVE.W	#8,$FFFF8A30		; IVD

;		  xf-rrrr
	move.b	#%00000000,$FFFF8A3D	; registre pour decalage vers la droite

;		  XXX-XXXX		; registre de controle
 	MOVE.B	#%11000000,$FF8A3C    	; si bit 6 a 0:PARTAGE DE BUS sinon 680*0 stoppe jusqu'a fin du transfert				
; bit 7 lance le transfert
****************
; source	
	MOVE.B	#3,$FF8A3A		; operations logiques
	MOVE.L	#NAIN+34+2,$FF8A24	; addresse bloc a transferer
	MOVE.W	#20,$FF8A36		; taille d'une ligne en mots
	MOVE.W	#200,$FF8A38		; taille verticale
	MOVE.W	#8,$FF8A20		; distance entre un mot et le suivant
	MOVE.W	#8,$FF8A22		; Increment Vertical Source
	MOVE.W	#-1,$FF8A28		; 3 registres pour les masques
	MOVE.W	#-1,$FF8A2A		; (permet de gerer au pixel pres !!)	
	MOVE.W	#-1,$FF8A2C		

; destination
	MOVE.L	WORKECR,A0		; addresse destination
	LEA	2(A0),A0
	MOVE.L	A0,$FFFF8A32	
	MOVE.W	#8,$FFFF8A2E		; Increment Horizontal Destination
	MOVE.W	#8,$FFFF8A30		; IVD

;		  xf-rrrr
	move.b	#%00000000,$FFFF8A3D	; registre pour decalage vers la droite

;		  XXX-XXXX		; registre de controle
 	MOVE.B	#%11000000,$FF8A3C    	; si bit 6 a 0:PARTAGE DE BUS sinon 680*0 stoppe jusqu'a fin du transfert				
; bit 7 lance le transfert
****************
; source	
	MOVE.B	#3,$FF8A3A		; operations logiques
	MOVE.L	#NAIN+34+4,$FF8A24	; addresse bloc a transferer
	MOVE.W	#20,$FF8A36		; taille d'une ligne en mots
	MOVE.W	#200,$FF8A38		; taille verticale
	MOVE.W	#8,$FF8A20		; distance entre un mot et le suivant
	MOVE.W	#8,$FF8A22		; Increment Vertical Source
	MOVE.W	#-1,$FF8A28		; 3 registres pour les masques
	MOVE.W	#-1,$FF8A2A		; (permet de gerer au pixel pres !!)	
	MOVE.W	#-1,$FF8A2C		

; destination
	MOVE.L	WORKECR,A0		; addresse destination
	LEA	4(A0),A0
	MOVE.L	A0,$FFFF8A32	
	MOVE.W	#8,$FFFF8A2E		; Increment Horizontal Destination
	MOVE.W	#8,$FFFF8A30		; IVD

;		  xf-rrrr
	move.b	#%00000000,$FFFF8A3D	; registre pour decalage vers la droite

;		  XXX-XXXX		; registre de controle
 	MOVE.B	#%11000000,$FF8A3C    	; si bit 6 a 0:PARTAGE DE BUS sinon 680*0 stoppe jusqu'a fin du transfert				
; bit 7 lance le transfert
****************
; source	
	MOVE.B	#3,$FF8A3A		; operations logiques
	MOVE.L	#NAIN+34+6,$FF8A24	; addresse bloc a transferer
	MOVE.W	#20,$FF8A36		; taille d'une ligne en mots
	MOVE.W	#200,$FF8A38		; taille verticale
	MOVE.W	#8,$FF8A20		; distance entre un mot et le suivant
	MOVE.W	#8,$FF8A22		; Increment Vertical Source
	MOVE.W	#-1,$FF8A28		; 3 registres pour les masques
	MOVE.W	#-1,$FF8A2A		; (permet de gerer au pixel pres !!)	
	MOVE.W	#-1,$FF8A2C		

; destination
	MOVE.L	WORKECR,A0		; addresse destination
	LEA	6(A0),A0
	MOVE.L	A0,$FFFF8A32	
	MOVE.W	#8,$FFFF8A2E		; Increment Horizontal Destination
	MOVE.W	#8,$FFFF8A30		; IVD

;		  xf-rrrr
	move.b	#%00000000,$FFFF8A3D	; registre pour decalage vers la droite

;		  XXX-XXXX		; registre de controle
 	MOVE.B	#%11000000,$FF8A3C    	; si bit 6 a 0:PARTAGE DE BUS sinon 680*0 stoppe jusqu'a fin du transfert				
; bit 7 lance le transfert

*	NOP
*RESTART
*	BTST	#7,$FF8A3C
*	NOP
*	BNE.S	RESTART
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
	MOVE.W	#7999,D0
	MOVEQ.L	#0,D1
OK
	MOVE.L	D1,(A0)+
	move.l 	D1,(a1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
*********************SECTION DATAS*************************************

AFFECR:		DC.L 	1
WORKECR:	DC.L 	1
OLDXBIOS2:	DC.L	1
OLDMODECODE	DC.W	1
SAV_8A36	DC.W	1
SAV_8A38	DC.W	1
SAV_8A20	DC.W	1
SAV_8A22	DC.W	1
SAV_8A28	DC.W	1
SAV_8A2A	DC.W	1
SAV_8A2C	DC.W	1
SAV_8A32	DC.L	1
SAV_8A2E	DC.W	1
SAV_8A30	DC.W	1
SAV_8A3D	DC.B	1
SAV_8A3A	DC.B	1
NAIN		INCBIN	"E:\GRAPHS\HYDROXID.PI1\NYTRIK\GROSNAIN.PI1"
	DS.L	2000
PILE	DS.L	10
	END
	  																											