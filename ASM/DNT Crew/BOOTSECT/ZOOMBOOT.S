;                        Ze Text-Zoomer Boot-sector
;
;
;(C)oderight NulloS//DNT-Crew 1992
;
TEST	equ	01
	OPT	o+

	IFEQ	TEST		;si test depuis GENST
	clr.l	-(sp)		;superviseur
	move.w	#$20,-(sp)		;
	trap	#1		;
	move.l	d0,2(sp)		;

	moveq	#-1,d0		;
	clr.w	-(sp)		;passe en basse r‚solution
	move.l	d0,-(sp)		;
	move.l	d0,-(sp)		;
	move.w	#5,-(sp)		;
	trap	#14		;hop!
	addq.l	#8,sp		;r‚tablit en partie la pile
	move.l	$432.w,(sp)	;sauve _membot
	move.l	#buff,$432.w	;remplace par notre buffer
	movem.l	$ffff8240.w,d0-d7	;
	movem.l	d0-d7,-(sp)	;sauve la palette systŠme
	movem.l	standard(pc),d0-d7	;installe celle du boot
	movem.l	d0-d7,$ffff8240.w	;
	
	bsr.s	MAIN		;‚x‚cute

	movem.l	(sp)+,d0-d7	;Restitue tout !
	movem.l	d0-d7,$ffff8240.w	;
	move.l	(sp)+,$432.w	;

	trap	#1		;repasse en utilisateur
	clr.w	(sp)		;et cassos
	trap	#1		;

standard	dc.w	$fff,$f00,$0f0,$ff0,$00f,$f0f,$0ff,$555;palette au boot
	dc.w	$333,$f33,$3f3,$ff3,$33f,$f3f,$3ff,$000;
	ENDC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAIN	tst.b	$44c.w		;r‚solution ok ?
	beq.s	.M_ok		;
	rts			;

.GB_bcl	move.w	#$3144,(a1)+	;move.w d4,d(a0)
	move.w	d5,(a1)+		;
	addq.w	#8,d5		;avance dans la ligne
.GB_copy	dbf 	d4,.GB_bcl		;
	rts  			;

	RSRESET
ad_ecran1	rs.l	1
ad_ecran2	rs.l	1
swap	rs.w	1
code	rs.b	922
cls	rs.b	16002
dsize	rs.b	0

.M_ok	lea	VAR(pc),a6		;variables
	movea.l	$432.w,a5		;bss

	movea.l	a5,a0		;
	movea.l	$044E.w,a2		;‚cran1=‚cran systŠme
	move.l	a2,(a0)+		;
	lea	dsize+256(a5),a1	;‚cran2=dans la zone a5
	move.l	a1,d0		;
	clr.b	d0		;
	move.l	d0,(a0)+		;
	clr.w	(a0)+		;init le swapping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;G‚nŠre le code de remplissage. A0=adresse de g‚n‚ration
;En sortie, A1 pointe sur la fin du code
.Genere_Box
	lea	20*4(a0),a1	;20 adresses de routines
	move.l	#$81504E75,d7	;or.w d0,(a0)
	move.l	a1,(a0)+		;
	move.w	#$C041,(a1)+	;and.w d1,d0
	move.l	d7,(a1)+		;
	moveq	#18,d6		;encore 19 routines
.GB_0	move.l	a1,(a0)+		;
	moveq	#$8,d5		;offset ‚cran de d‚part
	moveq	#18,d4		;
	sub.w	d6,d4		;largeur ligne actuelle
	bsr.s	.GB_copy		;g‚nŠre ligne: move.w d4,d(a0)
	move.w	#$8368,(a1)+	;or.w d1,d(a0)
	move.w	d5,(a1)+		;
	move.l	d7,(a1)+		;puis or.w d0,(a0)
	dbf 	d6,.GB_0		;
	moveq.l	#0,d5		;commence au d‚but de l'‚cran
	move.w	#$0FA0,d4		;Tout l'‚cran en move.w d4,d(a0)
	bsr.s	.GB_copy		;cela donne un cls !
	move.w	d7,(a1)+		;ne pas oublier le RTS !!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	move.l	#$0008067F,$ffff8240.w;les couleurs 0&1 et 14&15
	move.l	#$046506FF,$ffff825c.w;sont les seules utilis‚es

	movea.l	d0,a3		;
	bsr.s	.M_end		;le texte … zoomer
	move.w	#$1F3F,d0		;recopier sur l'‚cran 2
.M_0	move.l	(a2)+,(a3)+	;
	dbf 	d0,.M_0		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Boucle principale d'affichage
;
.M_sync	move.w	#$0025,-(sp)	; Vsync
	trap	#14		; Xbios
	addq.l	#2,sp		;
	movea.l	ad_ecran1(a5),a0	;Prend l'‚cran virtuel
	moveq	#$00,d4		;on l'efface sauvagement
	jsr	cls(a5)		;A0=‚cran virtuel, maintenant
	movea.l	a6,a4		;
	bsr.s	Put_Car		;affiche premier caractŠre
	bsr.s	Put_Car		;et deuxiŠme dans la foul‚e

	movea.l	a5,a4		;procŠde au swapping ‚cran
	move.l	(a4)+,d0		;
	move.l	(a4),(a5)		;
	move.l	d0,(a4)+		;
	lsr.w	#8,d0		;l'‚cran logique devient
	move.l	d0,$ffff8200.w	;donc l'‚cran physyique.
	not.w	(a4)+		;nb d'affichage pair?
	beq.s	.M_sync		;oui, attendre
	cmpi.w	#12*8*160+103,goff2(a6);dernier caractŠre atteint ?
	sne	d0		;->non=$FF
	and.b	$fffffc02.w,d0	;clavier pas appuy‚->%10000000
	bmi.s	.M_sync		;=>
.M_end	pea	message(pc)	;
	move.w	#$0009,-(sp)	; Cconws
	trap	#1		; Gemdos
	addq.l	#6,sp		;
	rts  			;cassos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=adresse ‚cran virutel
;A4=lettre courante
;A5=variables inutilis‚es ici
;A6=paramŠtres globaux du texte
T_X	set	5280
SPEED	set	4

Put_Car	move.w	#160,d7		;160 est souvent utilis‚
	subq.w	#SPEED,(a4)	;avance sur Z
	bgt.s	.PC_ok		;pas encore fini
	lea	12(a4),a3		;si, 1er caractŠre sort
	movem.l	(a3),d0-d2		;de l'‚cran.Le 2Šme prend
	movem.l	d0-d2,(a4)		;sa place.
	move.w	#256,(a3)+		;repart du fond de l'‚cran
	addq.w	#1,(a3)		;avance de 8 pixels sur le gfx
	lsr	(a3)		;bit de parit‚
	bcs.s	.PC_0		;pair->impair:ok
	addq.w	#3,(a3)		;impair->pair:16 pixels + loin
.PC_0	roxl	(a3)+		;reprend bit de parit‚
	subi.w	#T_X,(a3)+		;translation modifi‚e
	addq.w	#8,(a3)		;X de base augment‚
	move.w	(a3)+,(a3)+	;realx initialis‚ avec cette
	clr.w	(a3)		;nouvelle base

.PC_ok	move.w	(a4)+,d6		;prend le Z de la lettre
	movea.w	(a4)+,a3		;emplacement de son
	adda.l	a0,a3		;graphisme
	asl.w	#7,d6		;Z->(coeff de profondeur/2)
	clr.l	-(sp)		;Y de d‚part
	subq.w	#4,(sp)		;
	movem.w	(a4)+,d0-d1	;D0=addx // D1=bazx (inutile)
	add.l	d0,(a4)		;translate la lettre sur X
	moveq	#$07,d5		;8 lignes de haut
.PC_y	move.l	(sp),d1		;prend le Y haut
	addq.w	#1,(sp)		;descend d'un cran
	move.l	(sp),d3		;ca donne le Y bas
	divs	d6,d1		;transform‚ directement
	divs	d6,d3		;en y ‚cran.
	asr.w	#1,d1		;corrige le coeff/2
	asr.w	#1,d3		;
	moveq	#100,d0		;centrage ‚cran
	add.w	d0,d1		;
	add.w	d0,d3		;
	moveq	#$07,d4		;8 pixels par ligne
.PC_x	move.l	(a4),d0		;X gauche
	addq.w	#1,(a4)		;avance d'un cran
	move.l	(a4),d2		;X droit
	btst	d4,(a3)		;le pixel existe ?
	beq.s	.PC_nx		;non,suivant
	divs	d6,d0		;oui, transforme les X
	divs	d6,d2		;en x ‚cran.
	asr.w	#1,d0		;corrige encore une fois
	asr.w	#1,d2		;le coeff/2
	movem.l	d0-d7/a0-a6,-(sp)	;sauve tout le monde
	add.w	d7,d0		;centrage ‚cran sur x
	add.w	d7,d2		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Affichage d'une boite (x0,y0)-(x1,y1) = (d0,d1)-(d2,d3)
;Pour am‚lior‚ vitesse et rendu, comme les X droits et Y bas deviennent
;X gauches et Y haut, ils sont en commun … deux boites successives
;correspondants … deux pixels de suite => on d‚cr‚mente x1,y1 pour
;‚viter cela.
.Put_Box	subq.w	#1,d2		;X droit dans l'‚cran ?
	bmi.s	.PB_end		;
	subq.w	#1,d3		;et Y bas ?
	bmi.s	.PB_end		;
	move.w	#319,d4		;servent plusieurs fois
	move.w	#199,d5		;
	cmp.w	d4,d0		;X gauche dans l'‚cran ?
	bgt.s	.PB_end		;
	cmp.w	d5,d1		;
	bgt.s	.PB_end		;et Y haut ?

	tst.w	d0		;X gauche d‚borde l'‚cran ?
	bpl.s	*+4		;
	moveq	#0,d0		;oui, alors corrige
	tst.w	d1		;Tests similaires
	bpl.s	*+4		;sur les autres coordonn‚es
	moveq	#$00,d1		;
	cmp.w	d4,d2		;
	ble.s	*+4		;
	move.w	d4,d2		;
	cmp.w	d5,d3		;
	ble.s	*+4		;
	move.w	d5,d3		;
	moveq	#15,d4		;
	moveq	#15,d5		;m‚thode la plus courte
	and.w	d0,d4		;modulo 16 des deux x
	and.w	d2,d5		;
	sub.w	d4,d0		;=>No du groupe de 16
	sub.w	d5,d2		;pixels des deux x
	sub.w	d0,d2		;largeur box en groupe de
	lsr.w	#1,d0		;16 pixels // offset ‚cran x
	sub.w	d1,d3		;hauteur de la box
	mulu	d7,d1		;offset ‚cran y
	add.w	d1,d0		;cumule les deux
	adda.w	d0,a0		;hop, adresse ‚cran kivabien
	moveq	#-1,d0		;calcule les masques gauche
	move.w	#-$8000,d1		;et droit d'affichage
	lsr.w	d4,d0		;
	asr.w	d5,d1		;
	asr.w	#2,d2		;largeur r‚duite … un
	bmi.s	.PB_end		;multiple de 4. largeur <0 ??
	moveq	#-1,d4		;remplissage de tous les bits
	movea.l	code(a5,d2.w),a1	;adresse de la routine
.PB_bcl	jsr	(a1)		;go!
	adda.w	d7,a0		;ligne suivante
	dbf 	d3,.PB_bcl		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.PB_end	movem.l	(sp)+,d0-d7/a0-a6	;restitue tout le monde
.PC_nx	dbf 	d4,.PC_x		;pixel suivant
	subq.w	#8,(a4)		;revient en d‚but de ligne
	adda.w	d7,a3		;ligne graphique suivante
	dbf 	d5,.PC_y		;hop
	addq.l	#4,a4		;saute sur le caractŠre
	addq.l	#4,sp		;suivant,r‚tablit la pile
	rts  			;bye bye
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	DATA
message	dc.b	27,'E',27,'Y',32+12,32+16,"DNT",240,"Crew",$d,$a,0
	EVEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	RSRESET			;structure paramŠtres
z1	rs.w	1		;z courant de la lettre
goff1	rs.w	1		;offset graphique de la lettre
addx1	rs.w	1		;translation courante
bazx1	rs.w	1		;position X de base
realx1	rs.l	1		;et X courant dans une lettre

z2	rs.w	1		;Y'a deux lettres...
goff2	rs.w	1		;
addx2	rs.w	1		;
bazx2	rs.w	1		;
realx2	rs.l	1		;

VAR	dc.w	1024>>3,12*8*160+63
	dc.w	T_X*9/2,-(5*8*8>>3)
	dc.l	-(5*8*8<<13)
	
	dc.w	2048>>3,12*8*160+70
	dc.w	T_X*7/2,-(4*8*8>>3)
	dc.l	-(4*8*8<<13)

	IFEQ	TEST
	EVEN
	SECTION	BSS
buff	ds.b	40000
	ENDC