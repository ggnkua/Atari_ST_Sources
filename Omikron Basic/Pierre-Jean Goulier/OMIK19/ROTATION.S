;
; Basic Omikron & Assembleur.
; Routine effectuant une rotation de 90ø d'un bloc.
; ½ Start Micro & PJG / 1994.
;

intin	EQU	8
ptsin	EQU	12

	move	4(sp),d3	; Offset X
	move	6(sp),d4	; Offset Y
	move	d3,offx
	move	d4,offy
	move	8(sp),d3	; Largeur => D3.
	move	10(sp),d4	; Hauteur => D4.
	
	move	d3,d5		; D5 = Boucle X
	move	d4,d6		; D6 = Boucle Y
	DC.W	$A000		; Init Line A
	move.l	intin(a0),a3	; Tableau INITIN => A3.
	move	#1,(a3)		; Couleur = 1.
	move.l	ptsin(a0),a4	; Tableau PTSIN => A4.
l1:	move	d5,(a4)		; X => PTSIN(0).
	move	d6,2(a4)	; Y => PTSIN(1).
	DC.W	$A002		; Get Pixel.
	tst	d0		; Pixel = 1 ?
	beq	nul		; Non.
	move	d6,d0		; Sinon calcul rotation 90ø.
	add	offx,d0		; D0 = X.
	move	d3,d1
	add	offy,d1
	sub	d5,d1		; D1 = Y
	move	d0,(a4)		; X => PTSIN(0).
	move	d1,2(a4)	; Y => PTSIN(1).
	DC.W	$A001		; Put Pixel.
nul:	dbra	d6,l1		; Pour tous les Y...
	move	d4,d6
	dbra	d5,l1		; Et pour tous les X.
	rts
offx:	DC.W	0
offy:	DC.W	0