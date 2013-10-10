
*********************inits********************
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PHYSIC
	MOVE.W	#3,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,LOGIC
	MOVE.W	#4,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.W	D0,REZ
	MOVE.W	#-1,-(SP)
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	MOVE.W	D0,MODE
;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000010100010,-(SP)	
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	BSR	CLS
	BSR	PALETTE

******************************printer***************************
	
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,XB			; prend addresse ecran

	bsr.s	init_blitter
	
	
	
LOOP
	BSR.S	INIT_BLITTER
RESTART	MOVE.B	#$80,$FF8A3C		; lance le blitter
	NOP
	BSET	#7,$FF8A3C
	NOP
	BNE.S	RESTART
	CMPI.B	#57,$FFFFC02
	BEQ	SORTIE
	BRA.S	LOOP

*****************ROUTS DIVERSES******************************
CLS:
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,A5	
	MOVE.L	#$3800,D0
SCREEN	
	CLR.L	(A5)+
	DBF	D0,SCREEN
	RTS

PALETTE
	MOVE.L	FONTE+2,-(SP)
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	RTS	

VSYNC	MOVE.L	D3,-(SP)
	move.l	$466.w,d3
SYNC	cmp.l	$466.w,d3
	beq.s	SYNC
	MOVE.L	(SP)+,D3
	RTS

init_blitter
; source	
	MOVE.L	FONTE+34,$FF8A24	; addresse bloc a transferer
	MOVE.W	#1,$FF8A36		; taille d'une ligne en mots
	MOVE.W	#$F,$FF8A38		; taille verticale
	MOVE.W	#8,$FF8A20		; distance entre un mot et le suivant
	MOVE.W	#160,$FF8A22		; Increment Vertical Source
	MOVE.W	#$FFFF,$FF8A28		; 3 registres pour les masques
	MOVE.W	#$FFFF,$FF8A2A		; (permet de gerer au pixel pres !!)	
	MOVE.W	#$FFFF,$FF8A2C		

; destination
	MOVE.L	XB,$FF8A32		; addresse destination
	MOVE.W	#8,$FFFF8A2E		; Increment Horizontal Destination
	MOVE.W	#160,$FFFF8A30		; IVD
	MOVE.B	#3,$FF8A3A		; registre pour tests logiques
	
;		  xf-rrrr
	MOVE.B	#%00000000,$FF8A3D	; registre pour decalage vers la droite
	MOVE.B	#2,$FF8A3A		; ram de demi teinte(annulee)
	RTS 		 		

*****************FIN ET SHITS********************************

SORTIE	bsr	cls
	MOVE.W	MODE,-(SP)
	MOVE.W	#3,-(SP)
	MOVE.L	PHYSIC,-(SP)
	MOVE.L	LOGIC,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP
	
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	CLR.L	-(SP)
	TRAP	#1
	
	SECTION DATA

FONTE:	INCBIN	f:npg_fnt2.pi1
	
XB:	DC.L	0
PHYSIC:	DC.L	0
LOGIC:	DC.L	0
REZ:	DC.W	0
MODE:	DC.W	0

