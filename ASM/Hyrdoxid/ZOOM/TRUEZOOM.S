************************************
* ZOOMER ROUTINE IN TRUE COLOR !!! *
*               by                 *
*        Cristalion/Hydroxid       *
*           the 14/01/94	  *
************************************


largeur=	319
hauteur=	29

	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	BSR	VBL
	clr.w	$fffff8240
	MOVE.B	#18,$FFFFC02
	move.l	$70.w,OLD_VBL
	move.l	#NEW_VBL,$70.w
	move.b	$ffffa09,OLD_A09
	move.b	#$40,$ffffa09
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
	MOVE.L	AFFECR,A2
*******
LOOP
	CLR.L	$FFFF9800
	BSR	ZOOMMM
	CMPI.W	#318,XFACTEUR
	BHI.S	BIG
	ADDQ.W	#2,XFACTEUR
	ADDQ.W	#2,YFACTEUR
BIG
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
*******
	BRA	FIN	
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
INITS
	MOVEC	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$3111,D0		; cache on ... 
	MOVEC	D0,CACR			

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
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000000100100,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	add.l	 #128000,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	MOVE.L	A1,AFFINIT
	MOVE.L	A2,WORKINIT
	RTS

****************************SOUS ROUTINES***************************************************
NEW_VBL
	addq	#1,$466.w
	rte
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d7/a0-a6
	rts
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	move.l 	workecr,a1
	MOVE.W	#31999,D0
OK
	CLR.L	(A0)+
	CLR.L 	(A1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
*********************
RESTORE_SCREEN
	MOVE.L	WORKINIT,WORKECR
	MOVE.L	AFFINIT,AFFECR
	RTS
********************ZZZOOOOOOOOOOOOOOOOOOOOOOOMMMMMMMMMMMMMMMMMM**********************************
ZOOMMM
;on prend les addresses de base(A5,A6,D1,D2)
	LEA	IMAGE+128,A5
	MOVE.L	WORKECR,A6
	MOVE.W	Xfacteur,D1	;D1 compteur pour x
	MOVE.W	Yfacteur,D2	;D2 compteur pour y
	MOVE.W	#largeur,D3	;D3 fait les 320 pix
	MOVE	#hauteur,D4	;D4 fait 40 lignes
	MOVEQ	#0,D5		;D5 compteur pour numero du pts image
	move.w	XFACTEUR,d7
	move.w	YFACTEUR,d5
;centre /x
	MOVE	#320,d6
	SUB.W	d7,D6
	ADD.W	D6,A6
;centre /y
;on fait le zoom
	MOVE.L	#$3111,D0		; cache on ... 
	MOVEC	D0,CACR			
ZOOMER_Y
	ADD.W	d5,D2	
	MOVE.W	#largeur,D3	;D3 fait les 320 pix
 	CMPI.W	#320,D2
	BLE.S	ZOOMER_X1
	LEA	640(A6),A6	;ligne ecran suivante
	SUB.W	#320,D2
	MOVEM.L	A5-A6,-(SP)	
ZOOMER_X
	ADD.W	d7,D1	
	CMPI.W	#320,D1		;si facteur>320 affiche le point
	BLE.S	NO_POINT
	MOVE.W	(A5),(A6)+
	SUB.W	#320,D1
NO_POINT
	ADDQ.W	#2,A5
	DBF	D3,ZOOMER_X
	MOVEM.L	(SP)+,A5-A6
ZOOMER_X1
	MOVE	#320,d6		;centre les /x
	SUB.W	d7,D6
	LEA	640(A5),A5	;ligne image suivante
	DBF	D4,ZOOMER_Y
	MOVE.L	#$2510,D0		; cache on ... 
	MOVEC	D0,CACR			
	RTS
**************************************************************************************************
*******************c'est FI-NI********************************************************************
**************************************************************************************************

FIN	
	move.l	OLD_VBL,$70.w
	move.b	OLD_A09,$ffffa09	
	MOVE.L	OLD_CACR,D0
	MOVEC	D0,CACR
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#8,$FFFFC02
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

***********************************************************************
***********************************************************************
		SECTION DATA
OLD_VBL		DC.L	0
OLD_A09		DC.B	0
XFACTEUR		DC.W	2
YFACTEUR		DC.W	2
OLD_CACR		DC.L	0
AFFECR:		DC.L 	0
WORKECR:		DC.L 	0
AFFINIT:		DC.L 	0
WORKINIT:		DC.L 	0
OLDXBIOS2:		DC.L	0
OLDMODECODE	DC.W	0
SCREEN_ADD		DC.L	0
IMAGE		INCBIN	"E:\GRAPHS\TGA\BEAST.TPI"
		SECTION BSS
CLR		DS.L	20
SAVE_POINT		DS.W	1000
		DS.L	2000
PILE		DS.L	10
		DS.L	2000
SCREEN		DS.W	260000
	END
	 																																																																						 	 				 																																																																						 	 				 																																																																						 	 			 															
								 																								