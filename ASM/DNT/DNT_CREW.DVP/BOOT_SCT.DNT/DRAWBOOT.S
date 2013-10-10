;                       Ze  LBQADMQT-Bootsector
;
;            (Le Boot Qui Affiche Des Machins Qui Tournent)
;                     (C)oderight NulloS//DNT 1992
;
	opt	o+
TEST	equ	1
	IFEQ	TEST
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)
	bsr.s	start
	trap	#1
	clr.w	(sp)
	trap	#1
	ENDC

NB_POINTS	equ	8
start	move.b	$44c.w,d0		;r‚solution...
	bne.s	ok_rezol1		;si non basse
	moveq	#1,d0		;gasp,on passe en moyenne
ok_rezol1	cmpi.b	#$02,d0		;moins que trois ?
	ble.s	*+4		;ouai,cool
	rts			;non,inconnu
	bne.s	ok_rezol2		;haute r‚solution ?
	lea	autodraw00(pc),a0	;oui,modifie les routines
	move.w	#$d040,autodraw4(a0)	;"add.w  d0,d0"
	move.w	#$5588,autodraw1(a0)	;"subq.l #2,a0"
	move.w	#$5588,autodraw2(a0)	;"subq.l #2,a0"
	move.w	#80,autodraw3(a0)	;ligne de 80 octets
	move.l	#$d281d683,(a0)	;double les y

ok_rezol2	move.w	d0,-(sp)		;fixe la r‚solution
	moveq	#-1,d0		;en passant par SetScreen
	move.l	d0,-(sp)		;pour que Cconws marche
	move.l	d0,-(sp)		;correctement...
	move.w	#5,-(sp)		;
	trap	#14		;hop
	movea.l	$44e.w,a4		;adresse ‚cran
	pea	message(pc)	;affiche le message
	move.w	#9,-(sp)		;
	trap	#1		;(pile r‚tablie + tard)
	move.l	#$030106ee,$ffff8240.w;nouvelles couleurs
	move.w	#$0766,$ffff8246.w	;
	moveq	#46,d7		;Compteur de VBL
aff_boucle	move.l	$466.w,d0		;compteur VBL systŠme
wvbl	cmp.l	$466.w,d0		;VSYNC ?
	bcc.s	wvbl		;pas encore

	moveq	#NB_POINTS-1,d6	;
	lea	coord+(NB_POINTS-1)*8(pc),a0;fin des coordonn‚es
aff_bcl1	movem.l	(a0),d0-3		;coordonn‚es de la droite
autodraw00	nop			;
	nop			;
	subq.l	#8,a0		;point suivant
	swap	d0		;r‚cupŠre les parties
	swap	d1		;entiŠres des diff‚rentes
	swap	d2		;coordonn‚es des points
	swap	d3		;
	bsr	DRAW		;
	dbf	d6,aff_bcl1	;En sortie,A0=coeff1

	moveq	#NB_POINTS-1,d6	;
	move.l	(a0)+,d5		;D1=h
	movea.l	a0,a1		;
	move.l	(a1)+,d1		;D5=acc‚l‚ration
aff_bcl0	movem.l	(a1),d2-4/a2	;D2-4/a2=(Xm,Ym,Xm+1,Ym+1)
	move.l	d4,d0		;
	sub.l	d2,d0		;
	bsr.s	ttsf_mul		;D0= h * ( Xm+1 - Xm )
	add.l	d0,(a1)+		;(a1)=Xm + h * ( Xm+1 - Xm )
	move.l	a2,d0		;
	sub.l	d3,d0		;
	bsr.s	ttsf_mul		;
	add.l	d0,(a1)+		;mˆme calcul sur Ym
	dbf	d6,aff_bcl0	;
	move.l	d5,d0		;acc‚lŠre le coeff h (pour ne
	bsr.s	ttsf_mul		;pas trop tasser les lignes)
	move.l	d0,(a0)+		;
	move.l	(a0)+,(a1)+	;duplique les 1Šres coorodnn‚es
	move.l	(a0)+,(a1)+	;
	dbf	d7,aff_boucle	;Jusqu'… entourer "DNT-CREW"

wait_more	tst.b	$fffffc02.w	;touche relach‚e ?
	ble.s	wait_more		;non,continue
The_End	trap	#1		;r‚affiche le message
	lea	18(sp),sp		;corrige la pile
	rts			;cassos

;Multiplication en virgule fixe (16,16) bits (pr‚cision : 1.5E-5)
;La d‚tection des d‚passements de capacit‚ a ‚t‚ vir‚e, mais l'arrondi
;de la 17Šme d‚cimale est conserv‚ (inutile, m'enfin bon...)
ttsf_mul	movem.l	d1-d5,-(sp)
	move.l	d0,d5
	bpl.s	ttsfm_0
	neg.l	d0
ttsfm_0	eor.l	d1,d5
	tst.l	d1
	bpl.s	ttsfm_1
	neg.l	d1
ttsfm_1	move.w	d0,d2		;d0|d2
	move.w	d1,d3		;d1|d3
	swap	d0
	swap	d1
	move.w	d0,d4
	mulu.w	d1,d0		;d0=d0*d1
	mulu.w	d3,d4		;d4=   d0*d3
	mulu.w	d2,d3		;d3=      d3*d2
	mulu.w	d1,d2		;d2=   d1*d2
	add.l	d4,d2		;Add les parties 16bits,16bits
	swap	d3		;r‚cupŠre d‚cimales "fortes"
	bpl.s	*+4		;17Šme d‚cimale ? (2^-17)
	addq.l	#1,d2		;oui,arrondir
	swap	d0		;formatte les entiers
	move.w	d3,d0		;combine le tout
	add.l	d2,d0		;additionne le tout
	tst.l	d5		;signe r‚sultat
	bpl.s	ttsfm_3
	neg.l	d0
ttsfm_3	movem.l	(sp)+,d1-d5
	rts
	

;Tracage de ligne sans sauvegarde du fond.Algo de Lucas
;
;A4=ecran (D0,D1)-(D2-D3)=(X0,Y0)-(X1,Y1)
DRAW	movem.l	d0-6/a0,-(sp)	;on les sauve
	move.w	d0,d4		;calcul Dx
	sub.w	d2,d4		;
	bpl.s	draw_00		;Si plus,ok
	neg.w	d4		;arg,inverse les points
	exg	d1,d3		;(affichage de droite …
	move.w	d2,d0		;gauche)
autodraw3	equ	*-autodraw00+2
draw_00	move.w	#160,d6		;sens vertical
	sub.w	d1,d3		;Calcul Dy
	mulu	d6,d1		;offset du point [Conserve X]
	roxr.w	#1,d2		;r‚cupŠre X [D2 inutilis‚]
	bpl.s	draw_01		;Le signe de Dy correct
	neg.w	d3		;Ben bon,on remonte.
	neg.w	d6		;et on inverse donc le sens
draw_01	move.l	a4,a0		;
	move.w	d0,d2		;
	lsr.w	#4,d0		;divise par 16

autodraw4	equ	*-autodraw00
	lsl.w	#2,d0		;*4 ou *2 selon r‚solution

	add.w	d0,d1		;
	adda.w	d1,a0		;hop
	not.w	d2		;maintenant,No de bit pour
	andi.w	#$0f,d2		;le 1er pixel
	moveq	#0,d1		;
	bset	d2,d1		;bingo
	cmp.w	d4,d3		;Dy>Dx ?
	bgt.s	draw_10		;Oui


	move.w	d4,d2		;Algorithme de Lucas.
	move.w	d4,d5		;C'est le + court.
	lsr.w	#1,d2
draw_1	or.w	d1,(a0)
	rol.w	#1,d1
	bcc.s	draw_2
autodraw1	equ	*-autodraw00	;‚tiquette de modification
	subq.l	#4,a0		;4 ou 2 selon les r‚solutions
draw_2	sub.w	d3,d2
	bgt.s	draw_3
	adda.w	d6,a0
	add.w	d4,d2
draw_3	subq.w	#1,d5
	bgt.s	draw_1
draw_end	movem.l	(sp)+,d0-6/a0
	rts

draw_10	move.w	d3,d2
	move.w	d3,d5
	lsr.w	#1,d2
draw_11	or.w	d1,(a0)
	adda.w	d6,a0
	sub.w	d4,d2
	bgt.s	draw_12
	add.w	d3,d2
	rol.w	#1,d1
	bcc.s	draw_12
autodraw2	equ	*-autodraw00	;‚tiquette de modification
	subq.l	#4,a0
draw_12	subq.w	#1,d5
	bpl.s	draw_11
	bra.s	draw_end

coeff1	dc.l	$00010c59
coeff2	dc.l	$00000a23
coord	dc.l	$00c80000,$00000000
	dc.l	$00320000,$00420000
	dc.l	$024d0000,$00420000
	dc.l	$01b70000,$00000000
	dc.l	$01b70000,$00c70000
	dc.l	$024d0000,$00840000
	dc.l	$00320000,$00840000
	dc.l	$00c80000,$00c70000
	dc.l	$00c80000,$00000000	;copie des 1Šres coordonn‚es


message	dc.b	$1b,$45,$1b,$59,32+12,32+35
	dc.b	"!DNT-CREW!"
	dc.b	$0d,$0a,$00