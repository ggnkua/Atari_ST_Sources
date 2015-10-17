************************************************************
*TRUE RVB FADE  by Cristalion/Hydroxid finished the 7/06/93*
*        (my first real rout in ASM !!!!!!) 		   *	
************************************************************
;PARAMETRES A PASSER PAR LA -PILE- :
;1)  SUR UN LONG: ADDRESSE DE L'IMAGE A FADER
;2)  SUR UN BYTE: 0=FADE-IN
;  		  1=FADE-OUT
*	opt		o+,d+,w+

TRUE_FADE_OUT_NEW
	MOVEM.L		D0-D6/A0-A2,-(SP)	; save register
	MOVEQ.W		#7,D5			; init compteur pour les 7 pas de dec
	LEA		COLOR2_NEW,A2
	MOVEQ.W		#15,D6
	LEA		COLOR_NEW,A1		; addresse de stockage dans A1
	MOVE.L		46(SP),D0
	MOVE.L		D0,A0			;adresse image(saute BSR et sauvegarde des registres) 
	ADDQ.L		#2,A0			;saute l'en t‚te degas

SAUVE_PAL_DEPART_NEW
	MOVE.W	(A0)+,(A1)
	ANDI.W	#$777,(A1)+	
	DBF	D6,SAUVE_PAL_DEPART_NEW
	
FADE_NEW	
	MOVEQ.W		#15,D0			; init compteur
	LEA		COLOR_NEW,A1		; addresse de stockage dans A1
	MOVEQ.W		#15,D6			; compteur pour 16 colors

******************ROUT FADE*************************************
REPEAT_NEW
	MOVE.W		(A1),D0		 	; pointe sur color
	ANDI.W		#$F00,D0		; une seule composante
	ROR.W		#8,D0			; pour pointer sur R
; utilise registres d0-d1

	MOVE.W		(A1),D2			; pointe sur color
	ANDI.W		#$0F0,D2		; une seule composante
	ROR.W		#4,D2			; pour pointer sur V
; utilise registres d2-d3

	MOVE.W		(A1),D4			; pointe sur color 
	ANDI.W		#$00F,D4		; une seule composante B
; utilise registres d4
************************************				
	CLR		(A1)
	CMPI.B		#0,D0			; si color=0 on
	BEQ.S		RED_NEW			; va voir ailleur
	SUBQ.B		#1,D0			; dec R pour fade		
	ROL.W		#8,D0			; remet bits dans pos initiale
	OR.W		D0,(A1)			; sauve d1				

RED_NEW	CMPI.B		#0,D2
	BEQ.S		GREEN_NEW
	SUBQ.B		#1,D2			; dec V pour fade		
	ROL.W		#4,D2			; remet bits dans pos initiale
	OR.W		D2,(A1)			; sauve d3 sans ecraser (A1)				

GREEN_NEW	
	CMPI.B		#0,D4
	BEQ.S		BLUE_NEW
	SUBQ.B		#1,D4			; dec V pour fade		
	OR.W		D4,(A1)			; sauve d5 sans ecraser (A1) 				
BLUE_NEW
	MOVE.W		(A1)+,(A2)+
	DBF		D6,REPEAT_NEW		; fait les 16 color
	DBF		D5,FADE_NEW			; dec 7 fois	

	CMPI.W		#0,44(SP)		; si 0 fade_in
	BEQ.S		FADE_IN_NEW
	CMPI.W		#1,44(SP)
	BEQ.S		FADE_OUT_NEW		; si 1 fade_out

	JMP		SORTIE_NEW

***************FADE_OUT*******************
FADE_OUT_NEW
	MOVEQ.L		#7,D4		
	LEA		COLOR2_NEW,A1		; addresse colors stock‚es	
REAL_FADE_OUT_NEW
	MOVEQ.L		#14,D1			
	LEA		$FFFF8242.W,A0
	ADDQ.W		#2,A1
REAL_FADE1_NEW
	MOVE.W		(A1)+,(A0)+
	DBF		D1,REAL_FADE1_NEW		; fait les 16 colors
	BSR		VBL
	BSR		VBL
	BSR		VBL
	DBF		D4,REAL_FADE_OUT_NEW	; 7 pas du fade
	JMP		SORTIE_NEW
***************FADE_IN********************
FADE_IN_NEW	
	MOVEQ		#7,D4		
	LEA		COLOR2_NEW+256,A1		; addresse colors stock‚es
REAL_FADE_IN_NEW
	MOVEQ		#14,D1			
	LEA		$FFFF8242.W,A0
	LEA		30(A0),A0
REAL_FADE2_NEW
	MOVE.W		-(A1),-(A0)
	DBF		D1,REAL_FADE2_NEW	; fait les 16 colors
	BSR		VBL
	BSR		VBL
	BSR		VBL
	SUBQ.W		#2,A1
	DBF		D4,REAL_FADE_IN_NEW		; 7 pas du 0fade	

	MOVE.L		46(SP),D0
	MOVE.L		D0,A2			;adresse image(saute BSR et sauvegarde des registres) 
	ADDQ.L		#2,A2
	MOVE.L		A2,-(SP)	
	MOVE.W		#6,-(SP)
	TRAP		#14
	ADDQ.L		#6,SP
	
SORTIE_NEW
	MOVEM.L		(SP)+,D0-D6/A0-A2
	RTS
COLOR_NEW		DS.L		16	; stock colors
COLOR2_NEW		DS.L		512	