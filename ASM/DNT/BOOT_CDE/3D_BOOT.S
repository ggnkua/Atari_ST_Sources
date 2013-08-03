;                           Ze 3D-bootsector
;                     (C)oderight NulloS//DNT 1992
;

TEST	equ	1
DEBUG	equ	1

	IFEQ	TEST
MAIN	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)
	move.l	$432.w,-(sp)
	move.l	#buffer,$432.w
	bsr.w	DEBUT
	move.l	(sp)+,$432.w
	trap	#1
	addq.l	#6,sp
	clr.w	(sp)
	trap	#1
	ENDC


DEBUT
	IFNE	TEST
	tst.b	$44c.w
	beq.s	boot_ok
	rts
	ENDC
boot_ok	move.l	$432.w,a5
	move.l	#$02010677,$ffff8240.w	

;G‚n‚ration du sinus/cosinus
;
	lea	sinus_tab(pc),a2
mak_sincos	lea	sincos+64(a5),a1	;
	movea.l	a1,a0		;
	moveq	#31,d7		;Recopier 32 valeurs
sin_bcl1	move.b	(a2)+,d5
	move.w	d5,-(a1)
	move.w	d5,(a0)+
	dbf	d7,sin_bcl1	;on a donc sin pour ]0..PI[
	movea.l	a1,a6		;conserve trace de la table
	moveq	#95,d7		;copie sur 64 valeurs (cf -^)
sin_bcl2	move.w	(a1)+,(a0)		;pour obtenir la seconde moiti‚.
	neg.w	(a0)+		;ca donne sin pour ]0..2PI[
	dbf	d7,sin_bcl2	;et dans la foul‚e,on rajoute skifo
				;pour le cosinus:cos(x)=sin(x+PI/2)

;Suite des initialisations...
;
	clr.w	(a5)+		;init rotation
	clr.w	(a5)+		;init le swapping
	move.l	$44e.w,d6		;adresse ‚cran
	move.l	d6,-(sp)		;conserve la
	move.l	d6,(a5)+		;un des deux ‚crans pour swapping
	clr.l	(a5)		;pas encore de sauvegarde
	bsr.s	aff_ecran		;efface l'ecran
	lea	2*SAV_SIZ*4+160*2+256(a5),a1 ;2Šme ‚cran
	move.l	a1,d6		;
	clr.b	d6		;multiple de 256
	move.l	d6,(SAV_SIZ-1)*4(a5)	;stocke
	clr.l	SAV_SIZ*4(a5)	;pas encore de sauvegarde
	bsr.s	aff_ecran		;efface
	IFEQ	TEST		;
	IFEQ	DEBUG		;si DEBUG=1,on affiche la
step	pea	wstep1(pc)		;rotation ‚tape par ‚tape
	move.w	#$2300,-(sp)
	bra	VBL
wstep1	tst.b	$fffffc02.w
	bmi.s	wstep1
wstep2	tst.b	$fffffc02.w
	bpl.s	wstep2
	bra.s	step
	ENDC
	ENDC
	move.l	$70.w,-(sp)	;
	pea	VBL(pc)		;adresse relatif PC !!
	move.l	(sp)+,$70.w	;ne pas oublier -^
wait	tst.b	$fffffc02.w	;sortie ‚cran ?
	ble.s	wait		;
	move.l	(sp)+,$70.w	;
	move.l	(sp)+,d6		;
aff_ecran	clr.w	-(sp)		;
	move.l	d6,-(sp)		;
	move.l	d6,-(sp)		;
	move.w	#5,-(sp)		;
	trap	#14		;
	lea	12(sp),sp		;
	rts			;
	

;A6:adresse de la table de sinus/cosinus...
COS	equ	64

VBL	movea.l	$432.w,a5		;buffer de variables
	addq.b	#2,(a5)		;avance dans le sinus
	moveq	#0,d7		;
	move.b	(a5)+,d7		;
	movea.l	a6,a0		;
	adda.w	d7,a0		;
	addq.b	#3,(a5)		;
	move.b	(a5)+,d7		;
	andi.w	#$00fe,d7		;
	movea.l	a6,a1		;
	adda.w	d7,a1		;



	lea	coord(pc),a3
	moveq	#NB_PTS,d6
calc_bcl	move.b	-(a3),d1		;x,y point courant.
	move.b	-(a3),d0		;
	ext.w	d0
	ext.w	d1

	move.w	d0,d2		;duplique pour le calcul
	muls.w	COS(a0),d0		;X"=X'=128*(Xcos-0sin)
	muls.w	(a0),d2		;Z'=128*(Xsin+0cos)
	asl.w	#7,d1		;Y'=128*Y

	move.w	d1,d3		;duplique pour calcul
	move.w	d2,d4		;
	muls.w	(a1),d4		;
	muls.w	COS(a1),d1		;Y"=16384*(Ycos-Zsin)
	sub.l	d4,d1		;
	muls.w	(a1),d3		;
	muls.w	COS(a1),d2		;Z"=16384*(Ysin+Zcos)
	add.l	d3,d2		;
	asr.l	#7,d1		;
	asr.l	#7,d2		;Ttes les coords sont *128

	moveq	#127,d4		;a peu prŠs 128...(1*128=127!)
	asr.w	#8,d2		;Z_point/(Z_fuite=256)
	sub.w	d2,d4		;Q=128*(1-Z_point/Z_fuite)
	divs	d4,d0		;X_ecr=X"/Q
	divs	d4,d1		;Y_ecr=Y"/Q
	addi.w	#160,d0		;centrage sur l'ecran
	addi.w	#100,d1		;voila c'est fait
	move.w	d1,-(sp)		;stocke (X_ecr,Y_ecr)
	move.w	d0,-(sp)		;dans la pile
	subq.w	#1,d6		;point suivant
	bne.s	calc_bcl		;en sortie,D6.L=0

	eori.w	#SAV_SIZ*4,(a5)	;swapping ecran
	adda.w	(a5)+,a5		;en deduire ecran1/save1 ou 2
	movea.l	(a5)+,a4		;recupere l'ecran
	movea.l	a5,a3		;conserve le buffer de sauvegarde
clr_bcl	move.l	(a3)+,d0		;encore une sauvegarde ?
	beq.s	line_show		;non
	movea.l	d0,a2		;si,adresse
	move.w	d6,(a2)		;on l'enleve
	bra.s	clr_bcl		;suite

line_show	move.l	a4,d5		;mettre l'ecran pour la
	lsr.w	#8,d5		;prochaine VBL
	move.l	d5,$ffff8200.w	;
	move.w	#LINE_SEQ,d6	;Ordre d'affichage des lignes
				;aprŠs le MOVE,on a C=0
				;...cf plus bas le add.w d6,d6
line_bcl	bcs.s	lbcl_0		;ligne de style DRAW TO X2,Y2 ?
	move.w	(sp)+,d0		;non,donc DRAW X1,Y1 TO X2,Y2
	move.w	(sp)+,d1		;donc recupŠre X1,Y1
lbcl_0	move.w	(sp)+,d2		;Recupere X2,Y2
	move.w	(sp)+,d3		;

DRAW	movem.w	d0-3/d6,-(sp)	;on les sauve
	move.l	d0,d4		;calcul Dx
	sub.w	d2,d4		;
	bpl.s	draw_00		;Si plus,ok
	neg.w	d4		;arg,inverse les points
	exg	d1,d3		;(affichage de droite …
	move.w	d2,d0		;gauche)
draw_00	move.w	#160,d6		;sens vertical
	sub.w	d1,d3		;Calcul Dy
	bpl.s	draw_01		;Ok
	neg.w	d3		;Ben bon,on remonte.
	neg.w	d6		;et on inverse donc le sens
draw_01	mulu.w	#160,d1		;calcul adresse du point
	move.l	a4,a0		;… l'ecran
	ror.l	#4,d0		;Ca,c'est plus court qu'un
	lsl.w	#3,d0		;andi.w #%111110000+lsr.w #1
	add.w	d0,d1		;
	adda.w	d1,a0		;hop
	rol.l	#4,d0
	not.w	d0		;maintenant,No de bit pour
	moveq	#0,d1		;1er pixel
	bset	d0,d1		;bingo
	swap	d1		;bicoze technique ror/rol
	cmp.w	d4,d3		;Dy>Dx ?
	bgt.s	draw_10		;Oui

	move.w	d4,d2		;Algorithme de Lucas.
	move.w	d4,d5		;C'est le + court.
	lsr.w	#1,d2
draw_1	or.w	d1,(a0)
	move.l	a0,(a5)+
	rol.w	#1,d1
	bcc.s	draw_2
	subq.l	#8,a0
draw_2	sub.w	d3,d2
	bgt.s	draw_3
	adda.w	d6,a0
	add.w	d4,d2
draw_3	subq.w	#1,d5
	bgt.s	draw_1
draw_end	movem.w	(sp)+,d0-3/d6	;
	move.w	d3,d1		;(X2,Y2)->(X1,Y1)
	move.w	d2,d0		;
	add.w	d6,d6		;continuit‚ des coordonn‚es
	bne.s	line_bcl		;encore des lignes?.CCR intact
	clr.l	(a5)		;non,arrˆte les sauvegardes
	rte			;retour

draw_10	move.w	d3,d2
	move.w	d3,d5
	lsr.w	#1,d2
draw_11	or.w	d1,(a0)
	move.l	a0,(a5)+
	adda.w	d6,a0
	sub.w	d4,d2
	bgt.s	draw_12
	add.w	d3,d2
	rol.w	#1,d1
	bcc.s	draw_12
	subq.l	#8,a0
draw_12	subq.w	#1,d5
	bpl.s	draw_11
	bra.s	draw_end

;Successivement,les lettres DNT puis le cadre.
;Le point de d‚part pour les formes ferm‚es est doubl‚ (comme un polyline
;en GFA ou en VDI).
;en face est not‚ l'ordre de ligne correspondant
NB_PTS	equ	20
debut_coord
	dc.b	-66,18	;0 (charge 2 points)
	dc.b	-66,-24	;. (rien,on a charg‚ 2 points !!)
	dc.b	-42,-24	;1 (charge le point)
	dc.b	-30,-12	;1
	dc.b	-30,6	;1
	dc.b	-42,18	;1
	dc.b	-66,18	;1

	dc.b	-18,18	;0
	dc.b	-18,-24	;.
	dc.b	18,18	;1
	dc.b	18,-24	;1

	dc.b	48,18	;0
	dc.b	48,-24	;.
	dc.b	30,-24	;1
	dc.b	66,-24	;1

	dc.b	-80,34	;0
	dc.b	80,34	;.
	dc.b	80,-40	;1
	dc.b	-80,-40	;1
	dc.b	-80,34	;1
coord
;D'ou l'ordre d'affichage des lignes,qui sera lu par rotation …
;droite (les derniers 0 sont l… pour meubler,mais sont essentiels)
;Le premier bit devrait etre … zero,mais on ne le fait pas car l'
;algo est tel qu'au depart il existe, et est nul.
;		-  D   |N |T | # -
LINE_SEQ	equ	%1111101101101111

sinus_tab
	dc.b	128,128,127,126,125,123,122,119
	dc.b	117,114,111,108,105,101,097,093
	dc.b	088,084,079,074,068,063,058,052
	dc.b	046,040,034,028,022,016,009,003
	

	RSRESET
x_rot	rs.b	1
y_rot	rs.b	1
swapping	rs.w	1

SAV_SIZ	equ	3001
ecran1	rs.l	1
save1	rs.l	SAV_SIZ-1

ecran2	rs.l	1
save2	rs.l	SAV_SIZ-1
sincos	rs.w	160

screen	rs.b	32256
FIN

	IFEQ	TEST
	SECTION	BSS
buffer	ds.l	40000
	ENDC