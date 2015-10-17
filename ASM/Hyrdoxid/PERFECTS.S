* ROUT DE HARDSCROLL AVEC LE
* GENTIL PERFECT CELL DU DOC. GELOT !!!


	CLR.L	-(SP)
	MOVE	#32,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	BSR	CLS
	BSR	VBL
	BSR	INIT_RAST 
	MOVEM.L	COLOR,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	CLR.B	$FFFF8260.W
	MOVE.L	$44E.W,SAVE_XBIOS

	LEA	PIC+96034+(6240*3),A0
	MOVE.L	$44E.W,A1
	LEA	9280(A1),A1
	MOVE.L	#3200+160,D0
LOOP_PIC:
	MOVE.L	(A0)+,(A1)+
	DBF	D0,LOOP_PIC

	BSR	VBL
	MOVE.L	#PIC,-(SP)
	MOVE.W	#0,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP

	MOVEQ	#0,D7
WAIT:
	BSR	VBL
	ADDQ.B	#1,D7
	CMPI.B	#255,D7
	BNE.S	WAIT

	BSR	VBL
	MOVE.L	#PIC,-(SP)
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP

	BSR	CLS
* CLS PIC
	LEA	PIC+96034+(6240*3)-160,A0
	MOVE.L	#3200+160,D0
LOOP_PIC2:
	CLR.L	(A0)+
	DBF	D0,LOOP_PIC2

* BOUCLE PART
	BSR	VBL
	move	#51,$FFFF82A8.w	;OVER HAUT
	move	#609,$FFFF82AA.w	;BAS
	MOVE.L	#PIC+96034+(9280*2),XBIOS
	MOVE.B	XBIOS+1,$FFFF8201.W
	MOVE.B	XBIOS+2,$FFFF8203.W
	MOVE.B	XBIOS+3,$FFFF820D.W
	MOVEM.L	PIC+2,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W

	MOVEQ	#0,D2
**********
	MOVE.L	#TIMER,$4D2
BOUCLE:
	BSR	VBL
	ADDQ	#1,D2
	CMPI	#716,D2
	BEQ.S	BOUCLE2
	CMPI.B	#57,$FFFFC02
	BNE.S	BOUCLE
	CLR.L	$4D2

BOUCLE2:
	MOVE.B	SAVE_A09,$FFFFA09
	MOVE.B	SAVE_A07,$FFFFA07	
	MOVE.L	SAVE_HBL,$120.W
	MOVE.B	SAVE_A1B,$FFFFA1B	
	MOVE.B	SAVE_A21,$FFFFA21	
	MOVE.B	SAVE_A13,$FFFFA13	
	CLR.L	$4D2
BOUCLE22:
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE.S	BOUCLE22

	BSR	VBL
	MOVE.L	#PIC,-(SP)
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	
	BSR	VBL
	CLR.L	$4D2
	MOVE.B	SAVE_A09,$FFFFA09
	MOVE.B	SAVE_A07,$FFFFA07	
	MOVE.L	SAVE_HBL,$120.W
	MOVE.B	SAVE_A1B,$FFFFA1B	
	MOVE.B	SAVE_A21,$FFFFA21	
	MOVE.B	SAVE_A13,$FFFFA13	
	MOVE.B	#1,$FFFF8260.W
	MOVE	#$FFF,$FFFF8240.W
	CLR	$FFFF8246.W
	MOVE.L	SAVE_XBIOS,XBIOS
	MOVE	#111,$FF82A8
	MOVE	#511,$FF82AA
	MOVE.B	XBIOS+1,$FFFF8201.W
	MOVE.B	XBIOS+2,$FFFF8203.W
	MOVE.B	XBIOS+3,$FFFF820D.W
	BSR	CLS

	CLR.L	-(SP)
	MOVE	#32,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.L	-(SP)
	TRAP	#1
TIMER
	MOVE.L	#TIMER_B1,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFA1B
	RTS
TIMER_B1	
	MOVE.W	#$2700,SR
	SUB.L	#160,XBIOS
	move.b	XBIOS+1,$ffff8201.w	; Poids fort
	move.b	XBIOS+2,$ffff8203.w	; Poids moyen
	move.b	XBIOS+3,$ffff820d.w	; Poids faible
	CLR.B	$FFFFA21	
	CLR.B	$FFFFA1B
	BCLR	#0,$FFFFFA0F.W	
	MOVE.W	#$2300,SR	
	RTE
VBL:
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	RTS
INIT_RAST:
	move.l	$120.W,SAVE_HBL
	move.b	$ffffa1b,SAVE_A1B
	move.b	$ffffa09,SAVE_A09
	move.b	$ffffa21,SAVE_A21
	move.b	$ffffa07,SAVE_A07
	move.b	$ffffa13,SAVE_A13
	
	and.b	#$40,$fffa09
	or.b	#1,$fffa07
	or.b	#1,$fffa13	
	RTS

* ROUT DE FADE ...
TRUE_FADE_OUT:
	MOVEM.L		D0-D6/A0-A2,-(SP)	; save register
	MOVEQ.W		#7,D5		; init compteur pour les 7 pas de dec
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

GREEN	CMPI.B		#0,D4
	BEQ.S		BLUE
	SUBQ.B		#1,D4			; dec V pour fade		
	OR.W		D4,(A1)			; sauve d5 sans ecraser (A1) 				

BLUE	MOVE.W		(A1)+,(A2)+
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
	MOVEQ.L		#15,D1			
	LEA		$FFFF8240.W,A0
REAL_FADE1
	MOVE.W		(A1)+,(A0)+
	DBF		D1,REAL_FADE1		; fait les 16 colors
	BSR		VBL
	BSR		VBL
	BSR		VBL
	BSR		VBL
	DBF		D4,REAL_FADE_OUT	; 7 pas du fade
	JMP		SORTIE
***************FADE_IN********************
FADE_IN	
	MOVEQ.L		#7,D4		
	LEA		COLOR2,A1		; addresse colors stock‚es
	ADDA.L		#256,A1	
REAL_FADE_IN
	MOVEQ.L		#15,D1			
	LEA		$FFFF8240.W,A0
	ADDA.L		#32,A0
REAL_FADE2
	MOVE.W		-(A1),-(A0)
	DBF		D1,REAL_FADE2		; fait les 16 colors
	BSR		VBL
	BSR		VBL
	BSR		VBL
	BSR		VBL
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

CLS:
	MOVE.L	$44E.W,A0
	MOVE.L	#7999,D0
LOOP_CLS:
	CLR.L	(A0)+
	DBF	D0,LOOP_CLS
	RTS

   	SECTION	DATA

XBIOS:		DC.L	0
SAVE_XBIOS:	DC.L	0
VALEUR:		DC.B	0
SAVE_HBL:	DC.L	0
SAVE_A1B:	DC.B	0
SAVE_A21:	DC.B	0
SAVE_A07:	DC.B	0
SAVE_A09:	DC.B	0
SAVE_A13:	DC.B	0
SAVE_REZ:	DC.W	0
	EVEN
COLOR	DCB.B	32
PIC:	INCBIN a:PERFECT.DAT
PLUS:	DCB.B	32000

	SECTION	BSS
COLOR2	DS.L	64
	END		
						 																																																	  																									  																																								  																									  																																													 																																																	 
																									  																																								  																									  																																							