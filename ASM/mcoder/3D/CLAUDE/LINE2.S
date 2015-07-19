;------------- d‚finition des registres -------------------------

MINY		equr		D6      ;r‚serv‚s dans tous le calcul
MAXY		equr		D7	
PTRTABLE	equr		A0	;pointeur table des MINX-MAXX
ECRAN		equr		A1	;adresse ecran

;------------- registres pour calcul lignes ---------------------

XA		equr		D0	;extremit‚s de la droite
YA		equr		D1
XB		equr		D2
YB		equr		D3

PTRSEGMENT	equr		A6	;pointeur sur segment
COPPTRSEGMENT	equr		A0	;copie pointeur sur segment

JMPLINE		equr		A3	;adresse routine de droite
RETOUR		equr		A1	;adresse de retour droite

PTRY		equr		A2	;pointeur tabley

DY		equr		D4

REGDATA		equr		D5

JMP		equr		A5	;adresse debut du saut
					;pour calcul des points


;-------------- calcul et clipping d'une ligne verticale ---------------

CALCRETOUR2
		REPT	200
		MOVE.W	XA,(PTRY)+	;mise en place 2 nouveaux points
		ENDR
RETOURVERT
		JMP	(RETOUR)	;ligne verticale invisible
VERTLINE 
		CMP	#CLIPMAXY,YA	;clipping
		BLS.S	YASUPZERO
		BGT.S	RETOURVERT
		MOVEQ	#0,YA
YASUPZERO
		CMP	#CLIPMAXY,YB
		BLS.S	YBINFMAX
		BLT.S	RETOURVERT
		MOVE	#CLIPMAXY,YB
YBINFMAX		
		CMP	MAXY,YB		;tester maximum
		BLE.S	.PASMAXIMUM
		MOVE	YB,MAXY
.PASMAXIMUM
		CMP	MINY,YA		;tester minimum
		BGT.S	.PASMINIMUM
		move	YA,MINY
.PASMINIMUM
		SUB	YA,YB		;YB=DY
		ADD	YA,YA		
		ADD	YA,PTRY		;DEBUT TABLE

		ADD	YB,YB		;DY*2
		NEG	YB
;		ADD	#CALCRETOUR-CALCRETOUR2-2,YB
		JMP	RETOURVERT-2(PC,YB.W)

CALCRETOUR				;fin du calcul des points
		JMP	(RETOUR)

;-------------- d‚but calcul des points d'une ligne -----------------

CALCLINE:
		LEA	TABLEYMAX(PC),PTRY
		CMP	YA,YB		;c'est un ligne montante ?
		BEQ.S	CALCRETOUR	;ligne horizontale -> fin

		BGE.S	YBSUPYA

		EXG	XA,XB		;‚change les points
		EXG	YA,YB
		LEA	400(PTRY),PTRY  ;c'est une ligne montante
YBSUPYA
		SUB	XA,XB		;DX		

		BEQ.S	VERTLINE	;c'est une ligne verticale

		MOVE	YB,REGDATA	;pr‚pare calcul du DY
		SUB	YA,REGDATA	;DY

		EXT.L	XB		;calcul de la pente
		ASL.L	#4,XB		;DX*16 (et *8)
		DIVS	REGDATA,XB	;divise par DY

;		BVC.S	.NODEBORDE	;controle d‚bordement
;		ADD	#$70,$ffff8240.w
;.NODEBORDE

		EXT.L	XB		;extention du r‚sultat
		
		CMP	#CLIPMAXY,YA	;clipping haut
		BLS.S	.YASUP0
		BGT.S	CALCRETOUR	;ligne invisible
		MULS	XB,YA		;clipping
		LSR.L	#4,YA		;divise par 16
		SUB	YA,XA		;addition … XA
		MOVEQ	#0,YA		;YA=0
		MOVE	YB,REGDATA	;nombre de ligne=YB
.YASUP0
		CMP	#CLIPMAXY,YB
		BLS.S	.YBINFMAX
		BLT.S	CALCRETOUR
		MOVE	#CLIPMAXY,YB	;moins de lignes
		MOVE	YB,REGDATA	;
		SUB	YA,REGDATA	;calcul DY
.YBINFMAX		


;------------ mise a jour des maximums et minimum ----------

		CMP	MAXY,YB		;tester maximum
		BLE.S	PASMAXIMUM
		MOVE	YB,MAXY
PASMAXIMUM
		CMP	MINY,YA		;tester minimum
		BGT.S	PASMINIMUM
		MOVE	YA,MINY
PASMINIMUM

		ADD	YA,YA		 ;adresse tableau lignes
		ADD	YA,PTRY

		ADD	REGDATA,REGDATA  ;offset pour le saut
		ADD	REGDATA,REGDATA
		NEG	REGDATA

		SWAP	XB
		ASR.L	#4,XB
		SWAP	XA
		MOVE	XB,XA
		BEQ.S	LINEENTIER	;coef de pente entier
		ADD	#$8000,XA	;ajout de 0.5
		SWAP	XA
		SWAP	XB		
		JMP	(JMPLINE,REGDATA.W)


;---------- cas d'une ligne … coefficient entier -----------
	
LINEENTIER:	
		SWAP	XA
		SWAP	XB
		ADD	#.LINE2-.LINE1,REGDATA
		JMP	.LINE1(PC,REGDATA.W)
.LINE1
		REPT	200
		MOVE	XA,(PTRY)+	;stocke point
		ADD	XB,XA		;calcul avec coef entier
		ENDR
.LINE2
		MOVE	XA,(PTRY)	;plot dernier point 
		JMP	(RETOUR)	;fin de calcul

;-------------- cas d'une droite coeficient fractionnaire ----

		REPT	200
		MOVE	XA,(PTRY)+	;stocke point 
		ADDX.L	XB,XA		;ajout pente
		ENDR
AJMPLINE
		MOVE	XA,(PTRY)	;stocke dernier points
		JMP	(RETOUR)	;fin calcul

