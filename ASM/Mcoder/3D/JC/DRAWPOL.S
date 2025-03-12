;	OPT	P+
;
; Cher Philippe,
;
; Voici donc la routine tant demand‚e...
; ou plutot la fa‡on de l'utiliser
; (tu peux la bidouiller comme tu veux, notamment pour les EQUR)
;
; Pr‚cisions :
;
; 1) la coordonn‚e X=0 est au milieu de l'‚cran (fait gagner une addition)
;    et Y=0 en haut (pour clipping en Y)
; 2) le clipping en X est fait automatiquement avec une table de CLIPSIZE
;    pixels de chaque cot‚ de l'‚cran
;
; Utilisation :
;---------------
; 1) BSR INITPOLY afin de positionner les buffers
;---------------
; 2) BSR POLYGONE affiche le polygone que tu lui passes.
;   regarde les conditions d'entr‚e plus loin
;
; Ce programme doit pouvoir se mettre en INCBIN.
;
; Attention : Ceci n'est pas notre derniŠre routine d'affichage !!!
;  Claude en a ‚crite une plus compacte et plus rapide
;  et nous avons optimis‚ et d‚bugg‚ les routines de calcul de droite
;
; mais si tu trouves quelques astuces, fais-nous en part, ‡a peut
; etre utile.
; De toutes fa‡ons, je pense qu'en agenceant bien les EQUR, on dispose
; de beaucoup de registres de libres (surtout utiles pour ma d‚mo...)
;
; Voici une liste des derniŠres am‚liorations trouv‚es :
;	1) MACRO28 est devenu MACRO22 et maintenant on bat largement
;	    l'ancienne routine en MOVE.L
;	2) J'ai optimis‚ la routine drawline en modifiant l'ordre
;	   des instructions (vertline...) et je t'ai d‚bugg‚
;	   la routine (enfin, j'espŠre...) et tu ne devrait pas
;	   avoir trop de problŠmes d'arrondis...
;	3) pour gagner un pointeur dans la routine de polygone
;	    on pourrait stocker les facettes de cette fa‡on :
;	 triangle : dc.w Xa,Ya,Xb,Yb,Xc,Yc,Xa,Ya
;	  le dernier point est en double
;	4) la table de clipping en X prend 64K maintenant afin de pr‚venir
;	    tout risque de plantage
;	5) la fa‡on dont sont stock‚s les points permettrait de calculer
;	    les clippings avec Z ????
;	6) Claude a ajout‚ une routine d'affichage 1 plan avec ou sans trame
;	    ‡a lui permet de faire des objets avec des faces 'transparentes'
;	    en affichant dans le plan 3
;	   de plus, il a mis une routine de trac‚ de droite en couleur 15
;	7) j'ai d‚couvert une technique de tramage pour du 1 plan
;		- Claude utilise NOT.W D0
;		- on peut changer le motif avec SWAP D0 au lieu du NOT
;		- le motif peut faire 4 lignes de haut avec :
;			SWAP	D0
;			NOT	D0
;		- le motif peut faire 8 pixels de haut avec :
;			EXG	D0,D1
;			SWAP	D0
;			NOT	D0
;
;	7) il faudra impl‚menter les fonctions suivantes :
;		? routine de sprite normale
;		? routine de sprite zoomant en Y
;		- routine de cercle (Bresenham, encore...)
;		- routine d'ellipse
;		- affichage polygone tram‚ couleur 15
;		- affichage polygone tram‚ couleur 0
;		- affichage polygone Stencil (avec un motif … l'int‚rieur)
;		- affichage polygone tramage autre que 2 lignes
;
;
CLIPMAXY	equ	199		;nb lignes-1
CLIPSIZE	equ	2048		;largeur clipping

	SECTION TEXT


adresse_ecran:dc.l	$78000

**************** INITIALISATION DE LA TABLE DES POLYGONES **********

INITPOLY:
	LEA		llimit(PC),A0		
	MOVE		#CLIPSIZE-1,D0		;init limite gauche
RRLIMIT
	move.L		#-1,(A0)+
	CLR.L		(A0)+
	DBF		D0,RRLIMIT

	MOVEQ		#0,D0
	moveq	#0,d1
	moveq	#0,d2
RCLIMIT
	not d1
	MOVE		D1,(A0)+
	MOVE		D1,(A0)+
	not d1
	move.l	d2,(a0)+

	lsr	#1,d1
	or	#$8000,d1
	cmp	#-1,d1
	bne.s	.2
	clr	d1
	addq	#8,d2
.2

	ADDQ		#1,D0
	CMP		#319,D0
	BLE.S		RCLIMIT


	MOVE		#CLIPSIZE-1,D0
RLLIMIT
	clr.L		(A0)+		;init limite droite
	MOVE.L		#19*8,(A0)+
	DBF		D0,RLLIMIT

	RTS

***********************************************************************
*	routine d'affichage de polygones convexes                     *
*	avec clipping et pas de tramage			              *
*							              *
*	- calcul des droites dans une table 		              *
*	- remplissage par movem.l			              *
*							              *
***********************************************************************

;
; APPEL : en mode superviseur
;
; A6 -> ADRESSE DES DATAS 	(des points projetes)
; D6 -> NOMBRE DE POINTS  	(du polygone)
; D7 -> COULEUR * 8             (ATTENTION)
;
;
;------------- d‚finition des registres --------------------
;


MINY		equr		D6      ;r‚serv‚s dans tous le calcul

MAXY		equr		D7	

PTRTABLE	equr		A0

ECRAN		equr		A1

;------------- registres pour calcul lignes ------------------

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


;-------------- cas d'une ligne verticale -----------------------

retourvert
		JMP	(RETOUR)

vertline 
		; clipping

		CMP	#CLIPMAXY,YA
		BLS.S	YAsup0
		BGT.S	retourvert
		moveq	#0,YA
YAsup0
		CMP	#CLIPMAXY,YB
		BLS.S	YBinfmax
		BLT.S	retourvert
		MOVE	#CLIPMAXY,YB
YBinfmax		
		cmp	MAXY,YB		;tester maximum
		ble.s	.pasmaximum
		move	YB,MAXY
.pasmaximum
		cmp	MINY,YA		;tester minimum
		bgt.s	.pasminimum
		move	YA,MINY
.pasminimum
		SUB	YA,YB

		ADD	YA,YA
		ADD	YA,PTRY

		ADD	YB,YB
		NEG	YB
		ADD	#calcretour-calcretour2-2,YB
		JMP	calcretour2(PC,YB.W)
calcretour2
		REPT	200
		MOVE	XA,(PTRY)+	;mise en place nouveau points
		ENDR
calcretour				;fin du calcul des points
		jmp	(RETOUR)

;-------------- d‚but calcul d'une ligne -------------------------

calcline:
		lea	tableymax(PC),PTRY

		cmp	YA,YB

		beq.s	calcretour	;ligne horizontale

		bge.s	YBsupYA

		exg	XA,XB		;echange les points
		exg	YA,YB

		lea	tableymin-tableymax(PTRY),PTRY  ;c'est une ligne montante
YBsupYA
		sub	XA,XB		;DX		

		beq	vertline

		move	YB,REGDATA
		sub	YA,REGDATA	;DY


		ext.l	XB		;calcul de la pente
		asl.l	#7-3,XB		;DX*128
		divs	REGDATA,XB	;divise par DY
;		bvc.s	.nodeborde
;		addq	#7,$ffff8240.w
;.nodeborde

		ext.l	XB		

		CMP	#CLIPMAXY,YA
		BLS.S	.YAsup0
		BGT.S	calcretour
		muls	XB,YA
		lsr.l	#7-3,YA
		sub	YA,XA
		moveq	#0,YA
		move	YB,REGDATA
.YAsup0
		CMP	#CLIPMAXY,YB
		BLS.S	.YBinfmax
		BLT.S	calcretour
		MOVE	#CLIPMAXY,YB
		move	YB,REGDATA
		sub	YA,REGDATA	;DY
.YBinfmax		

		asl.l	#8,XB		;recuperation virgule 1/128eme
		asl.l	#1+3,XB


;------------ mise a jour des maximums et minimum ----------

		cmp	MAXY,YB		;tester maximum
		ble.s	pasmaximum
		move	YB,MAXY
pasmaximum
		cmp	MINY,YA		;tester minimum
		bgt.s	pasminimum
		move	YA,MINY
pasminimum

		add	YA,YA		 ;adresse tableau lignes
		add	YA,PTRY

		add	REGDATA,REGDATA  ;offset pour le saut
		add	REGDATA,REGDATA
		neg	REGDATA

		swap	XA
		move	XB,XA
		beq	lineentier
;		add	#$8000,XA
		swap	XA
		swap	XB		;poids fort = virgule
					;poids faible = partie entiere

	addq	#2,XA
		jmp	(JMPLINE,REGDATA.W)

		REPT	200
		MOVE	XA,(PTRY)+
		ADDX.L	XB,XA
		ENDR
jmpline
		MOVE	XA,(PTRY)


		jmp	(RETOUR)


nopoly		rts

;---------- cas d'une ligne … coefficient entier -----------
	
lineentier:	
		swap	XA
		swap	XB
		ADD	#.line2-.line1,REGDATA
		JMP	.line1(PC,REGDATA.W)
.line1
		REPT	200
		MOVE	XA,(PTRY)+
		ADD	XB,XA
		ENDR
.line2
		MOVE	XA,(PTRY)

		JMP	(RETOUR)
************************************************
*
* ROUTINE D'AFFICHAGE DE POLYGONE
*
************************************************
*
; entr‚e :
;	ne marche qu'en mode superviseur !!!!
;	MINY est le nombre de points de l'objet
;	MAXY est la couleur de l'objet
;	PTRSEGMENT pointe sur les coordonn‚es X,Y de chacun des points
;  ex: pour un triangle (A,B,C)
;	dc.w	Xa,Ya,Xb,Yb,Xc,Yc
;

RESULT		equr		D4	;registre de stockage temporaire
X0		equr		D5	
OFFDRO		equr		A6		
X1		equr		D3
OFFGAU		equr		D6

REG1		equr		D0
REG2		equr		D1
REG3		equr		D2
REG4		equr		A2
REG5		equr		A3	;registres utilis‚s dans movem
REG6		equr		A4

PTRCLIPX	equr		A5

POLYGONE:
		swap	MAXY			;mise … l'ecart du nombre de
		swap	MINY			;points et couleur

		clr	MAXY			;maxy=0
		move.w	#CLIPMAXY,MINY		;miny=y maximum

		swap	MINY			;miny est compteur de points

		move.l	PTRSEGMENT,COPPTRSEGMENT
		lea	lretjmp(PC),RETOUR	;adresse de retour
		lea	calcline(PC),JMP	;adresse du calcul de droite
		lea	jmpline(PC),JMPLINE
		subq	#1,MINY			;un point en moins
repline
		movem	(PTRSEGMENT),XA/YA/XB/YB ;lecture des points
		addq	#4,PTRSEGMENT		 ;passe droite suivante
		swap	MINY			 ;sauve compteur
		jmp	(JMP)			 ;calcul des points
lretjmp
		swap	MINY			 ;restore compteur
		subq	#1,MINY			 ;un point de moins
		bne.s   repline			 ;repeter...
		movem	(PTRSEGMENT),XA/YA	 ;derniŠre droite
		movem	(COPPTRSEGMENT),XB/YB
		lea	drawpolygone(PC),RETOUR
		swap	MINY
		jmp	(JMP)

;------------- remplissage du polygone -----------------------


drawpolygone:
		sub	MINY,MAXY		;calcul hauteur du polyg
		ble	nopoly			;si non affich‚ alors fin

		swap	MAXY			;lecture de la couleur
		lea	tableymax(PC),PTRTABLE

		movem.l	colors-tableymax(PTRTABLE,MAXY.W),REG1/REG2
		swap	MAXY

		move.l	REG1,REG3			;charge reg couleur
		move.l	REG2,REG4
		move.l	REG1,REG5
		move.l	REG2,REG6


		add	MINY,MINY			;MINY*2

		lea	muls160(PC),PTRCLIPX

		move.l	adresse_ecran(PC),ECRAN
		add	(PTRCLIPX,MINY.W),ECRAN

		add	MINY,PTRTABLE			;debut table

		lea	mlimit(PC),PTRCLIPX

dlrep
		MOVE.L	ECRAN,USP

		moveq	#-8,X0
		and	(PTRTABLE)+,X0
		MOVEM.L	(PTRCLIPX,X0.W),X0/OFFDRO
		ADD	OFFDRO,ECRAN

		moveq	#-8,X1
		and	200*2-2(PTRTABLE),X1		;X0
		MOVEM.L	(PTRCLIPX,X1.W),X1/OFFGAU

		SUB	OFFDRO,OFFGAU
		BGE.S	ONELONG

		move.l	(ECRAN),RESULT
		eor.l	REG1,RESULT
		and.l	X0,RESULT
		eor.l	REG1,RESULT
		move.l	RESULT,(ECRAN)+

		move.l	(ECRAN),RESULT
		eor.l	REG2,RESULT
		and.l	X0,RESULT
		eor.l	REG2,RESULT
		move.l	RESULT,(ECRAN)

		subq	#4,ECRAN		

		ADD	OFFGAU,OFFGAU
		ADD	OFFGAU,OFFGAU
		neg	OFFGAU
		jmp	ffill0-32(PC,OFFGAU.W)		;appel transfert par movem

ONELONG
		BNE.S	LSUIV

	not.l	X0
	and.l	X0,X1

	move.l	(ECRAN),RESULT
	eor.l	REG1,RESULT
	and.l	X1,RESULT
	eor.l	RESULT,(ECRAN)+
	move.l	(ECRAN),RESULT
	eor.l	REG2,RESULT
	and.l	X1,RESULT
	eor.l	RESULT,(ECRAN)
LSUIV
		move.l	USP,ECRAN
		lea	160(ECRAN),ECRAN
		dbf	MAXY,dlrep
		rts

MACRO28		MACRO
		move.l	-(ECRAN),RESULT
		eor.l	REG2,RESULT
		and.l	X1,RESULT
		eor.l	RESULT,(ECRAN)
		move.l	-(ECRAN),RESULT
		eor.l	REG1,RESULT
		and.l	X1,RESULT
		eor.l	RESULT,(ECRAN)

		move.l	USP,ECRAN
		lea	160(ECRAN),ECRAN
		dbf	MAXY,dlrep
		rts
		ENDM

ffill0
		MACRO28
		DS.B	4
;		bra	ffillfin
;		DS.B	32-4
ffill1
		movem.l	REG1/REG2,-(ECRAN)
		MACRO28
;		bra	ffillfin
;		DS.B	32-8
ffill2
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		MACRO28
;		bra	ffillfin		
;		DS.B	32-8
ffill3
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MACRO28
;		bra	ffillfin
;		DS.B	32-8
ffill4						 
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill5
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill6
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill7
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill8
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill9	
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill10
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
ffill11
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
ffill12
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
ffill13
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-24
ffill14
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-24
ffill15
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-24
ffill16
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-28
ffill17
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-28
ffill18
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-28
ffill19
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
ffillfin:
	MACRO28


muls160:
cpt		SET	0
		REPT	200
		DC.W	cpt
cpt		SET	cpt+160
		ENDR
colors:
		dc.l	$00000000,$00000000
		dc.l	$FFFF0000,$00000000
		dc.l	$0000FFFF,$00000000
		dc.l	$FFFFFFFF,$00000000
		dc.l	$00000000,$FFFF0000
		dc.l	$FFFF0000,$FFFF0000
		dc.l	$0000FFFF,$FFFF0000
		dc.l	$FFFFFFFF,$FFFF0000
		dc.l	$00000000,$0000FFFF
		dc.l	$FFFF0000,$0000FFFF
		dc.l	$0000FFFF,$0000FFFF
		dc.l	$FFFFFFFF,$0000FFFF
		dc.l	$00000000,$FFFFFFFF
		dc.l	$FFFF0000,$FFFFFFFF
		dc.l	$0000FFFF,$FFFFFFFF
		dc.l	$FFFFFFFF,$FFFFFFFF

tableymax:
		ds.w	200
tableymin:
		ds.w	200
************************************************************
    SECTION 	BSS
************************************************************

llimit:
	DS.L	CLIPSIZE*2
tlimit
	DS.L	160*2
mlimit
	DS.L	160*2
rlimit
	DS.L	CLIPSIZE*2
