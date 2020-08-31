; CLS
; a1 : adresse buffer o— d‚compresser
; a2 : palette : conversion 256 couleurs -> True Color
; a3 : adresse d'un tableau contenant les multiples de la largeur d'une
; ligne en octets ( longs mots )
; d1 : largeur
; d3 : hauteur
avi_black:
	move.w	d3,d4
	subq.w	#1,d4
	add.w	#15,d1
	and.w	#$fff0,d1
	move.w	d1,d2
	subq.w	#1,d2
	move.w	6(a3),d5
	sub.w	d1,d5
	sub.w	d1,d5
	move.w	(a2),d7	; couleur 0
.avi_black_bcl:
	move.w	d2,d6
.avi_black_line:
	move.w	d7,(a1)+
	dbf	d6,.avi_black_line
	add.w	d5,a1
	dbf	d4,.avi_black_bcl
	rts
