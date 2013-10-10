;
; Drapoints
; By Dumbo - XXäme siäcle
;
; NÇcessite DRAPOINT.D et TRASH.SPL
;

	TEXT

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea.l	cootable(pc),a5
	lea.l	cootable2(pc),a6
	move.w	#191,d7
copy_tab:	move.l	(a5)+,d0
	move.l	d0,(a6)+
	move.l	(a5)+,d0
	move.l	d0,(a6)+
	move.l	(a5)+,d0
	move.l	d0,(a6)+
	move.l	(a5)+,d0
	move.l	d0,(a6)+
	dbra	d7,copy_tab
	lea.l	ecran,a0
	move.l	a0,adrecr
	add.l	#40000,a0
	move.w	#499,d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
clrscr:	movem.l	d1-d5,-(a0)
	movem.l	d1-d5,-(a0)
	movem.l	d1-d5,-(a0)
	movem.l	d1-d5,-(a0)
	dbra	d0,clrscr
	lea	trash_sam(pc),a0
	move.l	a0,d0		; Adresse de dÇbut de replay
	move.b	d0,$ffff8907.w
	lsr.w	#8,d0
	move.b	d0,$ffff8905.w
	swap	d0
	move.b	d0,$ffff8903.w
	move.w	#fin_sam-trash_sam-1,d0
	moveq	#-128,d1
signe_sam:	add.b	d1,(a0)+		; Signe le sample
	dbra	d0,signe_sam
	subq.l	#2,a0		; Adresse de fin de replay
	move.l	a0,d0
	move.b	d0,$ffff8913.w
	lsr.w	#8,d0
	move.b	d0,$ffff8911.w
	swap	d0
	move.b	d0,$ffff890f.w
	move.b	#129,$ffff8921.w
	move.b	#3,$ffff8901.w	; Replay!
	movem.l	$ffff8240.w,d0-d7	; Sauve les couleurs
	movem.l	d0-d7,couleurs
	move.w	#4,-(sp)		; mode video ?
	trap	#14
	move.w	d0,vmode
	lea	ecran,a0
	clr.w	(sp)		; Basse rÇsolution
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
	lea.l	ecran+168*12+8,a0	; 1er point en (16,12)
	lea.l	cootable(pc),a1
	move.w	#5,d0		; d0 = nx
bouc1:	move.w	#43,d1		; d1 = ny
	move.l	a0,a2
	move.l	a1,a3
bouc2a:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc2a
	move.l	a0,a2
	add.w	#16,a1
	lea.l	4(a1),a3
	move.w	#43,d1
bouc2b:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc2b
	move.l	a0,a2
	add.w	#16,a1
	lea.l	8(a1),a3
	move.w	#43,d1
bouc2c:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc2c
	move.l	a0,a2
	add.w	#16,a1
	lea.l	12(a1),a3
	move.w	#43,d1
bouc2d:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc2d
	add.w	#16,a1
	addq.l	#8,a0
	dbra	d0,bouc1

	move.w	#5,d0		; d0 = nx
bouc3:	move.w	#43,d1		; d1 = ny
	move.l	a0,a2
	move.l	a1,a3
bouc3a:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,2(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc3a
	move.l	a0,a2
	add.w	#16,a1
	lea.l	4(a1),a3
	move.w	#43,d1
bouc3b:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,2(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc3b
	move.l	a0,a2
	add.w	#16,a1
	lea.l	8(a1),a3
	move.w	#43,d1
bouc3c:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,2(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc3c
	move.l	a0,a2
	add.w	#16,a1
	lea.l	12(a1),a3
	move.w	#43,d1
bouc3d:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,2(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc3d
	addq.l	#8,a0
	add.w	#16,a1
	dbra	d0,bouc3

	move.w	#5,d0		; d0 = nx
bouc4:	move.w	#43,d1		; d1 = ny
	move.l	a0,a2
	move.l	a1,a3
bouc5a:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	or.w	d3,2(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc5a
	move.l	a0,a2
	add.w	#16,a1
	lea.l	4(a1),a3
	move.w	#43,d1
bouc5b:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	or.w	d3,2(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc5b
	move.l	a0,a2
	add.w	#16,a1
	lea.l	8(a1),a3
	move.w	#43,d1
bouc5c:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	or.w	d3,2(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc5c
	move.l	a0,a2
	add.w	#16,a1
	lea.l	12(a1),a3
	move.w	#43,d1
bouc5d:	move.w	(a3)+,d2
	move.w	(a3)+,d3
	or.w	d3,(a2,d2.w)
	or.w	d3,2(a2,d2.w)
	add.w	#168*4,a2
	add.w	#12,a3
	dbra	d1,bouc5d
	add.w	#16,a1
	addq.l	#8,a0
	dbra	d0,bouc4

; Animation
	move.w	#9,d6
boouucle:
	lea.l	cootable(pc),a0
	move.w	#$5f,d7		; d7 = compteur d'images
looop:
; Changement de l'adresse Çcran
	move.l	adrecr(pc),a1	; a1 = adresse Çcran
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
	move.w	#43,d0		; d0 = nbr de lignes
lp_ef2_1:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,(a1,d1.w)
	add.w	#168*4,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_1
	sub.w	#168*4*44,a1	; Retour en haut de l'Çcran
	sub.w	#16*44-16-4,a0	; colonne suivante
	move.w	#43,d0		; d0 = nbr de lignes
lp_ef2_2:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,(a1,d1.w)
	add.w	#168*4,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_2
; Rajout de deux colonnes de bleu sur le blanc
	sub.w	#168*4*44-48,a1	; Retour en haut de l'Çcran
	sub.w	#16*(44-23)+4,a0	; avant-derniäre colonne bleue
	move.w	#43,d0		; d0 = nbr de lignes
lp_ef2_3:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,2(a1,d1.w)
	or.w	d2,(a1,d1.w)
	add.w	#168*4,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_3
	sub.w	#168*4*44,a1	; Retour en haut de l'Çcran
	sub.w	#16*44-16-4,a0	; colonne suivante
	move.w	#43,d0		; d0 = nbr de lignes
lp_ef2_4:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,2(a1,d1.w)
	or.w	d2,(a1,d1.w)
	add.w	#168*4,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_4
; Rajout de deux colonnes de blanc sur le rouge
	sub.w	#168*4*44-48,a1	; Retour en haut de l'Çcran
	sub.w	#16*(44-23)+4,a0	; avant-derniäre colonne blanche
	move.w	#43,d0		; d0 = nbr de lignes
lp_ef2_5:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,(a1,d1.w)
	add.w	#168*4,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_5
	sub.w	#168*4*44,a1	; Retour en haut de l'Çcran
	sub.w	#16*44-16-4,a0	; colonne suivante
	move.w	#43,d0		; d0 = nbr de lignes
lp_ef2_6:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	sub.w	d2,(a1,d1.w)
	add.w	#168*4,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_6
; Rajout de deux colonnes de rouge Ö droite
	sub.w	#168*4*44-48,a1	; Retour en haut de l'Çcran
	sub.w	#16*(44-23)+4,a0	; avant-derniäre colonne rouge
	move.w	#43,d0		; d0 = nbr de lignes
lp_ef2_7:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	or.w	d2,2(a1,d1.w)
	or.w	d2,(a1,d1.w)
	add.w	#168*4,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_7
	sub.w	#168*4*44,a1	; Retour en haut de l'Çcran
	sub.w	#16*44-16-4,a0	; colonne suivante
	move.w	#43,d0		; d0 = nbr de lignes
lp_ef2_8:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	or.w	d2,2(a1,d1.w)
	or.w	d2,(a1,d1.w)
	add.w	#168*4,a1
	add.w	#12,a0
	dbra	d0,lp_ef2_8

;	movem.l	d0-a6,-(sp)
;	move.w	#7,-(sp)
;	trap	#1
;	addq.l	#2,sp
;	movem.l	(sp)+,d0-a6

	lea.l	32(a6),a0		; Mouvement suivant
	dbra	d7,looop
	dbra	d6,boouucle

fin:
	move.w	#7,-(sp)
;	trap	#1
	clr.b	$ffff8901.w
	clr.b	$ffff820f.w
	clr.b	$ffff8265.w
	movem.l	couleurs,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	vmode,(sp)
	move.l	#-1,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#10,sp
	clr.w	(sp)
	trap	#1



	DATA

adrecr	DS.l	1		; Adresse de l'Çcran
cootable:	INCBIN	'DRAPOINT.D'	; PrÇcalcul de la courbe
cootable2:	DS.b	3072*2		; 2 x copie de cootable
				; doit suivre cootable
trash_sam:	INCBIN	'TRASH.SPL'	; ***Sample***
fin_sam:

	BSS

vmode:	DS.w	1		; Sauvegarde du mode
couleurs:	DS.w	16		; Sauvegarde des couleurs
ecran:	DS.b	40000		; Ecran virtuel
