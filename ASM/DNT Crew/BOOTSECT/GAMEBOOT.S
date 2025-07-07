;                       Ze Cubik's Rub Boot-sector
;
;(C)oderight NulloS//DNT-Crew 1992
;
;Petit jeu nul en boot-sector. La chose la plus inutile depuis l'invention
;de l'acn‚e juv‚nile.
;
	OPT	o+
TEST	equ	1
LEVEL	equ	96
Forme	equ	5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Les diff‚rentes formes … obtenir, de la plus facile … la plus compliqu‚e.
;Faites un LEVEL equ 0 pour voir la forme avec vos yeux...
;Forme=0..... Stop
;      1..... Demi-portion !
;      2..... X-tasy
;      3..... Croix-Rouge
;      4..... Ca se corse
;      5..... Koiceca ?
;      6..... Arrˆtez, j'avoue tout!
;
	IFEQ	Forme
f1	equ	%11110000111100001111000011110000
f2	equ	%11110000111100001111000011110000
	ENDC
	IFEQ	Forme-1
f1	equ	%00000000000000000000000001111110
f2	equ	%01111110000000000000000000000000
	ENDC
	IFEQ	Forme-2
f1	equ	%10111101101111011011110111000011
f2	equ	%11000011101111011011110110111101
	ENDC
	IFEQ	Forme-3
f1	equ	%11100111111001111110011100000000
f2	equ	%00000000111001111110011111100111
	ENDC
	IFEQ	Forme-4
f1	equ	%01000010111111110100001001011010
f2	equ	%01011010010000101111111101000010
	ENDC
	IFEQ	Forme-5
f1	equ	%01111111001110010001100100001111
f2	equ	%00000111011000110110000100000000
	ENDC
	IFEQ	Forme-6
f1	equ	%10101010010101011010101001010101
f2	equ	%10101010010101011010101001010101
	ENDC

	
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
	RSRESET
cur_x	rs.w	1		;position curseur
cur_y	rs.w	1		;
damier	rs.b	8		;damier actuel
figure	rs.b	8		;figure de r‚f‚rence
dsize	rs.b	0		;

MAIN	tst.b	$44c.w		;r‚solution ok ?
	beq.s	M_ok		;
	rts			;

M_ok	pea	Welcome(pc)	;Un p'tit bonjours..
	move.w	#9,-(sp)		;Fonction Cconws
	trap	#1		;La pile est corrig‚e au finish

M_game	lea	$ffff8240.w,a0	;
	move.w	#$001,(a0)+	;Fond bleu (mega-classe !)
	move.l	#$04100621,(a0)+	;installe les couleurs
	move.l	#$0f430444,(a0)+	;qui vont bien
	move.w	#$0555,6(a0)	;
	st	14(a0)		;
	st	20(a0)		;Texte en blanc

	movea.l	$432.w,a6		;adresse variables
	movea.l	a6,a5		;adresse du damier
	clr.l	(a5)+		;curseur en 0,0

	move.l	#f1,d6		;la forme d‚sir‚e..
	move.l	#f2,d7		;
	move.l	d6,d4		;On initialise les tableaux
	move.l	d7,d5		;figure (l'original)
	movem.l	d4-d7,(a5)		;et damier (l'aire de jeu)

	IFNE	LEVEL		;Si niveau d‚fini..
	moveq	#LEVEL-1,d6	;Selon le niveau de jeu
.M_shaker	move.w	#17,(sp)		;tire un nombre au hasard
	trap	#14		;
	move.l	d0,d7		;
	swap	d7		;On se sert des r‚sultats
	moveq	#7,d3		;pour construire D0,D1
	and.w	d3,d0		;coordonn‚es, et D7 commande
	and.w	d3,d1		;de rotation
	bsr	Rotate_Damier	;
	dbf	d6,.M_shaker	;
	ENDC			;

.M_reaff	moveq	#7,d0		;8 lignes de damier
.M_line	move.b	0(a5,d0.w),d3	;r‚cupŠre la ligne courante
	moveq	#7,d1		;(= 1 octet). 8 jetons dedans
.M_col	moveq	#0,d2		;offset ‚cran pour rouge/bleu
	lsl.b	#1,d3		;fait sortir un bit (l'ordre
	addx.w	d2,d2		;des bits est l'inverse de l'
	lsl.w	#2,d2		;ordre d'affichage !!).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;D0=No de ligne du damier
;D1=No de colonne du damier
;D2=offset couleur (0 pour boule blanche, 4 pour boule rouge)
.Put_Boule	movem.l	d0-a6,-(sp)	;
	bsr.s	.Centrage		;
	lea	Boule(pc),a1	;adresse boule
	moveq	#13,d0		;14 lignes/boule
.PB_bcl	clr.l	(a0)+		;commence par effacer
	clr.l	(a0)+		;l'emplacement de la boule
	move.l	(a1)+,-8(a0,d2.w)	;puis on l'affiche
	lea	160-8(a0),a0	;
	dbf	d0,.PB_bcl		;
	movem.l	(sp)+,d0-a6	;
	dbf	d1,.M_col		;colonne suivante.
	dbf	d0,.M_line		;ligne suivante.

	movem.w	(a6),d0-d1		;emplacement pointeur
	bsr.s	.Centrage		;on l'affiche oukifo
	moveq	#15,d0		;
	ror.w	#2,d0		;D0=$0000c003
	or.l	d0,2(a0)		;go !
	or.l	d0,13*160+2(a0)	;

	IFEQ	LEVEL		;Si voir seulement, alors
	bra.s	.WaitKey		;pas de test "fin de partie"
	ELSE
.TestDamier
	movem.l	(a5),d0-d3		;on compare le damier …
	cmp.l	d2,d0		;la r‚f‚rence.
	bne.s	.WaitKey		;Si pas ‚gal, alors
	cmp.l	d3,d1		;attend des ordres.
	bne.s	.WaitKey		;
	moveq	#-1,d0		;Solution trouv‚e !!!
.Yeah	addi.w	#1,$ffff8240.w	;petit slide de couleurs
	subq.w	#1,d0		;boucle lente pour qu'on
	bne.s	.Yeah		;ait le temps de voir qqch!!
	bra	M_game		;recommencer depuis le d‚but
	ENDC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Centrage ‚cran selon D0-D1 coordonn‚es damier
.Centrage	mulu	#160*16,d0		;position ‚cran selon ligne
	lsl.w	#3,d1		;et colonne du damier
	add.w	d1,d0		;
	movea.w	d0,a0		;
	adda.l	$44e.w,a0		;hop, sur l'‚cran
	lea	41*160+6*8(a0),a0	;centrage...
	rts			;Ce RTS sert aussi … sortir
				;du boot...

.WaitKey	move.w	#7,(sp)		;Attendre une touche
	trap	#1		;
	move.l	d0,d7		;conserve en D7
	move.l	#$000bffff,(sp)	;puis demande l'‚tat shift
	trap	#13		;
	swap	d7		;r‚cupŠre le scan-code
	subq.w	#1,d7		;Escape ?
	bne.s	.TstArrows		;non, alors keltouche ?
	addq.l	#6,sp		;r‚tablit la pile (enfin !!)
	rts			;et hop.

.TstArrows	subi.w	#$47,d7		;Fleche haute ?
	beq.s	.M_10		;-> d7=%10
	subq.w	#3,d7		;Fleche gauche ?
	beq.s	.M_00		;-> d7=%00
	subq.w	#2,d7		;  "    droite ?
	beq.s	.M_01		;-> d7=%01
	subq.w	#3,d7		;  "    bas ?
	bne.s	.WaitKey		;-> d7=%11

.M_11	addq.w	#1,d7		;Selon la flŠche...
.M_10	addq.w	#1,d7		;
.M_01	addq.w	#1,d7		;
.M_00	lsl.b	#7,d0		;bit1 devient C, bit0 devient N
	bcs.s	.M_rot		;
	bmi.s	.M_rot		;Si C=1 ou N=1 alors shift

.M_dep	lea	cur_x(a6),a0	;par d‚faut,d‚p. sur ligne 
	lsl.b	#7,d7		;effectiement sur ligne ??
	bcs.s	.M_dep0		;
	addq.l	#2,a0		;non, colonne (conserve CCR)
.M_dep0	bmi.s	.M_dep1		;faut avancer ?
	subq.w	#2,(a0)		;non, recule
.M_dep1	addq.w	#1,(a0)		;avance par d‚faut
	andi.w	#7,(a0)		;clipping final.
	bra	.M_reaff		;r‚affichage..

.M_rot	movem.w	cur_x(a6),d0-d1	;prendre coord curseur
	bsr.s	Rotate_Damier	;et rotation comme d‚sir‚.
	bra	.M_reaff		;raffraichit le damier
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;D0=No de ligne du damier
;D1=No de colonne du damier
;D7=type de rotation du damier: bit1=ligne/colonne
;                               bit0=(gauche-droite)/(haut-bas)
; Ne pas oublier que l'on voit … l'‚cran les boules de gauche … droite
;dans l'ordre des bits faibles … fort, donc la repr‚sentation binaire
;est sym‚triquement inverse de ce que l'on voit.Donc la case la plus
;… gauche (colonne 0) correspond au bit 0 (d'o— le bset, plus bas).
;Et si on demande de tourner graphiquement … gauche, il faut faire
;une rotation … droite (d'o— le ror.b).
;Seul D6 est sauvegard‚ car Rotate_damier est appel‚ juste avant le
;r‚affichage (aucun registre n'a besoin d'ˆtre sauvegard‚), et pendant
;le brassage au hasard du damier (d6 sert de compteur).
Rotate_Damier
	move.l	d6,-(sp)		;
	moveq	#1,d5		;rotations par d‚faut
	moveq	#6,d6		;sur les lignes et colonnes
	lsl.b	#7,d7		;vers la droite et le haut
	bcs.s	.RD_col		;

.RD_line	bpl.s	.RD_l0		;sens inverse ?
	moveq	#8-1,d5		;alors rotation … gauche
.RD_l0	lea	0(a5,d0.w),a0	;ligne voulue, puis procŠde …
	move.b	(a0),d0		;la rotation (si d5=1, rotation
	ror.b	d5,d0		;… droite,si d5=8-1 rotation …
	move.b	d0,(a0)		;gauche...si si,v‚rifiez!)
	bra.s	.RD_end		;cassos

.RD_col	bmi.s	.RD_c0		;sens inverse ?
	moveq	#0,d6		;alors rotation vers le bas
.RD_c0	movem.l	(a5),d3-d4		;r‚cupŠre les octets du damier
	moveq	#0,d0		;
	bset	d1,d0		;fixe le bit de la colonne
	ror.w	#8,d0		;dans chaque octet de d0
	bset	d1,d0		;
	move.w	d0,d1		;
	swap	d0		;
	move.w	d1,d0		;
	and.l	d0,d3		;isole ce bit de colonne dans
	and.l	d0,d4		;les octets du damier
	not.l	d0		;inverse le masque
	and.l	d0,(a5)+		;=>mise … z‚ro de la colonne
	and.l	d0,(a5)+		;dans les 8 octets
.RD_c1	rol.l	#8,d3		;rotation … gauche:
	rol.l	#8,d4		;D3=(b0:b1:b2:b3)(b1:b2:b3:b0)
	eor.b	d3,d4		;D4=(b4:b5:b6:b7)(b5:b6:b7:b4)
	eor.b	d4,d3		;puis ‚change l'octet bas
	eor.b	d3,d4		;ce qui donne en D3-D4:
	dbf	d6,.RD_c1		;(b1:b2:b3:b4)-(b5:b6:b7:b0)
	or.l	d4,-(a5)		;aprŠs d6 rotations … gauche,
	or.l	d3,-(a5)		;fixe les bits colonne comifo
.RD_end	move.l	(sp)+,d6		;
	rts	
	SECTION	TEXT

Boule	dc.w	%0000001111000000,%0000001110000000
	dc.w	%0000111000110000,%0000111111000000
	dc.w	%0001100000001000,%0001111111110000
	dc.w	%0011000000000100,%0011111111111000
	dc.w	%0010000000000100,%0011111111111000
	dc.w	%0110000000000110,%0111111111111000
	dc.w	%0100000000000110,%0111111111111000
	dc.w	%0100000000000110,%0111111111111000
	dc.w	%0100000000001110,%0011111111110000
	dc.w	%0010000000001100,%0001111111110000
	dc.w	%0010000000011100,%0001111111100000
	dc.w	%0001000001111000,%0000111110000000
	dc.w	%0000111111110000,%0000000000000000
	dc.w	%0000001111000000,%0000000000000000

Welcome	dc.b	"¾DNT 92"
	dc.b	27,'Y',32+1,32+13,"Ze Cubik's Rub"
	dc.b	$d,$a,0



	IFEQ	TEST
	SECTION	BSS
	EVEN
buff	ds.b	40000
	ENDC