************************************************************
*TRUE RVB FADE  by Cristalion/Hydroxid finished the 7/06/93*
*        (my first real rout in ASM !!!!!!) 		   *	
************************************************************
;PARAMETRES A PASSER PAR LA -PILE- :
;1)  SUR UN LONG: ADDRESSE DE L'IMAGE A FADER
;2)  SUR UN BYTE: 0=FADE-IN
;  		  1=FADE-OUT
*	opt		o+,d+,w+

TRUE_FADE_OUT
	MOVEM.L		D0-D6/A0-A2,-(SP)	; save register
	MOVEQ.W		#7,D5			; init compteur pour les 7 pas de dec
	LEA		COLOR2,A2
	MOVEQ.W		#15,D6
	LEA		COLOR,A1		; addresse de stockage dans A1
	MOVE.L		46(SP),D0
	MOVE.L		D0,A0			;adresse image(saute BSR et sauvegarde des registres) 
	ADDQ.L		#2,A0			;saute l'en t‚te degas

SAUVE_PAL_DEPART
	MOVE.W	(A0)+,(A1)
	ANDI.W	#$777,(A1)+	
	DBF	D6,SAUVE_PAL_DEPART
	
FADE	
	MOVEQ.W		#15,D0			; init compteur
	LEA		COLOR,A1		; addresse de stockage dans A1
	MOVEQ.W		#15,D6			; compteur pour 16 colors

******************ROUT FADE*************************************
REPEAT
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
	BEQ.S		RED			; va voir ailleur
	SUBQ.B		#1,D0			; dec R pour fade		
	MOVE.W		D0,D1			; sauve d0 dans d1
	ROL.W		#8,D1			; remet bits dans pos initiale
	OR.W		D1,(A1)			; sauve d1				

RED	CMPI.B		#0,D2
	BEQ.S		GREEN
	SUBQ.B		#1,D2			; dec V pour fade		
	MOVE.W		D2,D3			; sauve d2 dans d3
	ROL.W		#4,D3			; remet bits dans pos initiale
	OR.W		D3,(A1)			; sauve d3 sans ecraser (A1)				

GREEN	
	CMPI.B		#2,D4
	BEQ.S		BLUE2	
	CMPI.B		#2,D4
	BLT.S		BLUE
	SUBQ.B		#1,D4			; dec V pour fade		
	OR.W		D4,(A1)			; sauve d5 sans ecraser (A1) 				
	JMP		BLUE2
BLUE	ADDQ.B		#1,D4
BLUE2	OR.W		D4,(A1)

	MOVE.W		(A1)+,(A2)+
	DBF		D6,REPEAT		; fait les 16 color
	DBF		D5,FADE			; dec 7 fois	

	CMPI.W		#0,44(SP)		; si 0 fade_in
	BEQ.S		FADE_IN
	CMPI.W		#1,44(SP)
	BEQ.S		FADE_OUT		; si 1 fade_out

	JMP		SORTIE

***************FADE_OUT*******************
FADE_OUT
	MOVEQ.L		#7,D4		
	LEA		COLOR2,A1		; addresse colors stock‚es	
REAL_FADE_OUT
	MOVEQ.L		#14,D1			
	LEA		$FFFF8242.W,A0
	ADDQ.W		#2,A1
REAL_FADE1
	MOVE.W		(A1)+,(A0)+
	DBF		D1,REAL_FADE1		; fait les 16 colors
	BSR		VBL
	BSR		VBL
	BSR		VBL
	DBF		D4,REAL_FADE_OUT	; 7 pas du fade
	JMP		SORTIE
***************FADE_IN********************
FADE_IN	
	MOVEQ.L		#7,D4		
	LEA		COLOR2+256,A1		; addresse colors stock‚es
REAL_FADE_IN
	MOVEQ.L		#14,D1			
	LEA		$FFFF8242.W,A0
	ADDA.L		#30,A0
REAL_FADE2
	MOVE.W		-(A1),-(A0)
	DBF		D1,REAL_FADE2		; fait les 16 colors
	BSR		VBL
	BSR		VBL
	BSR		VBL
	SUBQ.W		#2,A1
	DBF		D4,REAL_FADE_IN		; 7 pas du fade	

	MOVE.L		46(SP),D0
	MOVE.L		D0,A2			;adresse image(saute BSR et sauvegarde des registres) 
	ADDQ.L		#2,A2
	MOVE.L		A2,-(SP)	
	MOVE.W		#6,-(SP)
	TRAP		#14
	ADDQ.L		#6,SP
	
SORTIE
	MOVEM.L		(SP)+,D0-D6/A0-A2
	RTS
COLOR		DS.L		16	; stock colors
COLOR2		DS.L		512	