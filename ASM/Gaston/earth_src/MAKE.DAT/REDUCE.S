; Ce programme reduit le nombre de lignes de l'image pour qu'il corresponde
; avec celui de la sphere qui va etre affichee : ca evite de perdre de la
; place inutile. On n'enleve pas les lignes Ö la fin de l'image, mais en
; plein milieu : on fait comme un mapping vertical de la sphere pour savoir
; quelles sont les lignes a garder ...
; Mettre entre les 2 ;***** le nom de l'image source et celui de l'image
; destination ...

TAILLE	=	192
	opt	x+

***************************************************************************

js	equr	d7
compt	equr	d6
a	equr	d5
j	equr	d3
comptpas	equr	d2
Offset	equr	d6
ray	equr	d5
Y1	equr	d4
Largeur_Ligne	equr	d3
x	equr	d2
Total	equr	d1
buff	equr	a5
Y2	equr	a3
gen	equr	a2
adrgen	equr	a1
buff2	equr	a0
Hautbande	equ	384
Xrsl	equ	384
Largimage	equ	640+640

***************************************************************************

	***** CALCULE LES LARGEURS DE CHAQUE LIGNE *****
	move.w	#TAILLE,-(sp)
	bsr	CALC_LARGEUR	
	addq.w	#2,sp
	
	include	..\genere.t

***************************************************************************
BEGIN:
	lea	image,a1
	lea	image2,a2
	lea	BUFFER2+2,A3

	move.w	#TAILLE-1,d1
earthgenere:
	move.l	a1,a4
	move.w	#640-1,d0
copi:	move.b	(a4)+,(a2)+
	dbra	d0,copi

	move.w	(a3)+,d0
	mulu	#640,d0
	lea	(a1,d0.l),a1	; saute des lignes

	dbra	d1,earthgenere

***************************************************************************
SAUVE:	nop

	include	h:\demos\earth\make.dat\fichiers.t
	save	nom,image2,#640*192	;640*320

	clr.w	(sp)
	trap	#1

***************************************************************************

	include	..\calclarg.t

	section data

;*****
image:	incbin	..\earth.xga	
finimage:
nom:	dc.b	"..\earth2.xga",0
;*****

degrade:	incbin	degrade.rip

***************************************************************************

	section bss

reajuste:	ds.w	1

generejsr:	ds.b	10*220 ; si la boule fait 220 de diamätre
genere:	ds.b	40000
adrgenere:	ds.b	220*4

buffer:	ds.b	500
buffer2:	ds.b	500
sbuffer2:	ds.w	1
	even

image2:	ds.b	640*320*2	