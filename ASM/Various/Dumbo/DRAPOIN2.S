;
; Drapoint
; By Dumbo - XXäme siäcle
;

	TEXT

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea.l	ecran(pc),a0
	move.l	a0,adrecr
	move.w	#9999,d0
clrscr:	clr.l	(a0)+
	dbra	d0,clrscr
	lea.l	ecran(pc),a0
	clr.w	-(sp)		; Basse rÇsolution
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	move.b	#4,$ffff820f.w
	move.b	#0,$ffff8265.w
	move.l	#$f,$ffff8240.w
	move.l	#$fff0f00,$ffff8244.w


; Initialisation de l'Çcran
	lea.l	ecran+168*12+8(pc),a0	; 1er point en (16,12)
	lea.l	cootable(pc),a1
	move.w	#5,d0		; d0 = nx
bouc1:	move.w	#87,d1		; d1 = ny
	move.l	a0,a2
	move.l	a1,a3
bouc2a:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc2a
	move.l	a0,a2
	add.w	#16,a1
	lea.l	4(a1),a3
	move.w	#87,d1
bouc2b:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc2b
	move.l	a0,a2
	add.w	#16,a1
	lea.l	8(a1),a3
	move.w	#87,d1
bouc2c:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc2c
	move.l	a0,a2
	add.w	#16,a1
	lea.l	12(a1),a3
	move.w	#87,d1
bouc2d:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc2d
	add.w	#16,a1
	addq.l	#8,a0
	dbra	d0,bouc1

	move.w	#5,d0		; d0 = nx
bouc3:	move.w	#87,d1		; d1 = ny
	move.l	a0,a2
	move.l	a1,a3
bouc3a:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,2(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc3a
	move.l	a0,a2
	add.w	#16,a1
	lea.l	4(a1),a3
	move.w	#87,d1
bouc3b:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,2(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc3b
	move.l	a0,a2
	add.w	#16,a1
	lea.l	8(a1),a3
	move.w	#87,d1
bouc3c:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,2(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc3c
	move.l	a0,a2
	add.w	#16,a1
	lea.l	12(a1),a3
	move.w	#87,d1
bouc3d:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,2(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc3d
	addq.l	#8,a0
	add.w	#16,a1
	dbra	d0,bouc3

	move.w	#5,d0		; d0 = nx
bouc4:	move.w	#87,d1		; d1 = ny
	move.l	a0,a2
	move.l	a1,a3
bouc5a:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	or.w	d3,2(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc5a
	move.l	a0,a2
	add.w	#16,a1
	lea.l	4(a1),a3
	move.w	#87,d1
bouc5b:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	or.w	d3,2(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc5b
	move.l	a0,a2
	add.w	#16,a1
	lea.l	8(a1),a3
	move.w	#87,d1
bouc5c:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	or.w	d3,2(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc5c
	move.l	a0,a2
	add.w	#16,a1
	lea.l	12(a1),a3
	move.w	#87,d1
bouc5d:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	or.w	d3,2(a2,d2.w)
	add.w	#168*2,a2
	add.w	#12,a3
	dbra	d1,bouc5d
	add.w	#16,a1
	addq.l	#8,a0
	dbra	d0,bouc4

; Animation
	move.w	#9,d6
boouucle:
	lea.l	cootable(pc),a0
	move.w	#$3f,d7		; d7 = compteur d'images
looop:
; Changement de l'adresse Çcran
	move.l	adrecr,a1		; a1 = adresse Çcran
	btst	#0,d7
	bne.s	change1
	addq.l	#8,a1
	move.l	a1,adrecr
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	move.w	#-1,-(sp)
	move.l	a1,-(sp)
	move.l	a1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	clr.b	$ffff8265.w
	move.b	#4,$ffff820f.w
	move.l	a0,a6		; Sauve le mouvement courant
	add.w	#168*12,a1		; a1 = adresse affichage
	addq.l	#8,a0
	bra.s	change2

change1:
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	(sp)+,a0
	move.l	(sp)+,a1
	move.b	#8,$ffff8265.w
	clr.b	$ffff820f.w
	add.w	#168*12+8,a1	; a1 = adresse affichage
	move.l	a0,a6		; Sauve le mouvement courant

change2:
; Effaáage des deux premiäres colonnes de points bleus
	move.w	#87,d0		; d0 = nbr de lignes
lp_ef2_1:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,(a1,d1.w)
	add.w	#168*2,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_1
	sub.w	#168*4*44,a1	; Retour en haut de l'Çcran
	sub.w	#16*88-16-4,a0	; colonne suivante
	move.w	#87,d0		; d0 = nbr de lignes
lp_ef2_2:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,(a1,d1.w)
	add.w	#168*2,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_2
; Rajout de deux colonnes de bleu sur le blanc
	sub.w	#168*4*44-48,a1	; Retour en haut de l'Çcran
	sub.w	#16*(88-23)+4,a0	; avant-derniäre colonne bleue
	move.w	#87,d0		; d0 = nbr de lignes
lp_ef2_3:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,2(a1,d1.w)
	or.w	d2,(a1,d1.w)
	add.w	#168*2,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_3
	sub.w	#168*4*44,a1	; Retour en haut de l'Çcran
	sub.w	#16*88-16-4,a0	; colonne suivante
	move.w	#87,d0		; d0 = nbr de lignes
lp_ef2_4:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,2(a1,d1.w)
	or.w	d2,(a1,d1.w)
	add.w	#168*2,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_4
; Rajout de deux colonnes de blanc sur le rouge
	sub.w	#168*4*44-48,a1	; Retour en haut de l'Çcran
	sub.w	#16*(88-23)+4,a0	; avant-derniäre colonne blanche
	move.w	#87,d0		; d0 = nbr de lignes
lp_ef2_5:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,(a1,d1.w)
	add.w	#168*2,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_5
	sub.w	#168*4*44,a1	; Retour en haut de l'Çcran
	sub.w	#16*88-16-4,a0	; colonne suivante
	move.w	#87,d0		; d0 = nbr de lignes
lp_ef2_6:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,(a1,d1.w)
	add.w	#168*2,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_6
; Rajout de deux colonnes de rouge Ö droite
	sub.w	#168*4*44-48,a1	; Retour en haut de l'Çcran
	sub.w	#16*(88-23)+4,a0	; avant-derniäre colonne rouge
	move.w	#87,d0		; d0 = nbr de lignes
lp_ef2_7:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	or.w	d2,2(a1,d1.w)
	or.w	d2,(a1,d1.w)
	add.w	#168*2,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_7
	sub.w	#168*4*44,a1	; Retour en haut de l'Çcran
	sub.w	#16*88-16-4,a0	; colonne suivante
	move.w	#87,d0		; d0 = nbr de lignes
lp_ef2_8:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	or.w	d2,2(a1,d1.w)
	or.w	d2,(a1,d1.w)
	add.w	#168*2,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_8

	lea.l	32(a6),a0		; Mouvement suivant
	dbra	d7,looop

	dbra	d6,boouucle

fin:
	move.w	#7,-(sp)
;	trap	#1
	addq.l	#2,sp
	clr.b	$ffff820f.w
	clr.b	$ffff8265.w
	clr.w	-(sp)
	trap	#1



	DATA

cootable:	INCBIN	'A:\DRAPOINT.D'

	BSS

ecran:	DS.b	40000	; Ecran virtuel
adrecr	DS.l	1	; Adresse de l'Çcran
