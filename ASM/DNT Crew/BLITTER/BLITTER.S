;Source d'exploitation du blitter.
;Ceux qui ont des yeux remarqueront que c'est une repompe assez totale
;du source paru chez MicroApp dans "Le livre du d‚veloppeur"...
;Mais avec un bug en moins.En fait,j'ai pas le temps d'en faire un
;maintenant, donc je ne fais que le reprendre, en modifiant certaines
;choses pour s'accorder avec les explications de l'article.
;
;Pour bien montrer la puissance d'utilisation du blitter, on va se servir
;d'une image IFF compact‚e en ByteRun1 (attention, le d‚compacteur IFF de
;ce source est rudimentaire,il ne traite QUE le ByteRun1 (option … droite
;dans le selecteur de compactage de DPAINT ST), 320*200 16 couleurs sans
;masque (= pochoir dans le menu "info" du fichier image, sous DPAINT ST)).
;Le blitter va se demerder tout seul pour faire les conversions de ce format
;IFF au format ST.Faites donc une routine qui en fasse autant (n'importe
;quel format source … n'importe quelle coordonn‚e, n'importe quel format
;arriv‚e … n'importe quelle coordonn‚e),ce qui est d‚j… pas facile, mais
;en plus qui aille plus vite que le blitter...

;Le fichier IFF contient le bloc et son masque, que l'on ne construit donc
;pas "… la main".Il doit ˆtre de couleur 15 et repr‚senter la forme exacte
;du bloc (son ombre,donc).Rien ne vous empŠche de le construire avec le
;blitter.A vous de jouer...
;
;(C)oderigth NulloS//DNT 1992
;
CHANGE_REZ	MACRO
	move.w	\1,-(sp)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	ENDM

	SECTION	TEXT

	clr.l	-(sp)		;Passe en superviseur
	move.w	#$20,-(sp)		;
	trap	#1		;hop
	move.l	d0,2(sp)		;range la pile systŠme
				;… port‚e de main...

	move.w	#4,-(sp)		;Sauve l'ancienne r‚solution
	trap	#14		;
	move.w	d0,(sp)		;

	CHANGE_REZ	#0		;passe en basse r‚solution

	lea	Image(pc),a0	;Decompacte l'image IFF
	lea	buffer(pc),a1	;dans le buffer et fixe les
	bsr	Depack_IFF		;couleurs.

	move.w	#2,-(sp)		;
	trap	#14		;adresse ‚cran.
	addq.l	#2,sp		;
	lea	param(pc),a0	;adresse structure pour BitBlt

;Fixe les paramŠtres ‚crans (basse r‚solution 320*200 4 plans entrelac‚s)
	move.l	d0,dst_adr(a0)	;destination=ecran
	move.w	#8,dst_xinc(a0)	;cf article blitter:entrelacement
	move.w	#160,dst_width(a0)	;taille d'une ligne ‚cran
	move.w	#2,dst_nxpl(a0)	;les plans se suivent

;Fixe les paramŠtres IFF.Chaque ligne est non-entrelac‚e,cad que ses 4
;plans sont r‚unis.Donc au lieu d'avoir (X1)(Y1)(Z1)(T1)....(Xn)(Yn)(Zn)(Tn)
;comme d'habitude, on a (X1)...(Xn)(Y1)...(Yn)(Z1)...(Zn)(T1)...(Tn)
;D'o— les paramŠtres qui suivent...
	move.l	#buffer,src_adr(a0)	;destination=IFF d‚compact‚e
	move.w	#2,src_xinc(a0)	;pas d'entrelacement
	move.w	#160,src_width(a0)	;toujours 160 octets de large
;(pour passer d'une ligne … la suivante, il faut toujours sauter ses 4
;bitplanes !)
	move.w	#40,src_nxpl(a0)	;les plans sont s‚par‚s.
;Pour passer d'un plan … l'autre, il faut en sauter un entier, et non
;pas un seul mot...

	move.w	#75,obj_width(a0)	;le bloc fait 75 pixels de large
	move.w	#69,obj_height(a0)	;sur 69 lignes de haut
	move.w	#04,obj_nplane(a0)	;et il est en 4 bitplanes.
	moveq	#20,d2		;intervalle de positionnement
	moveq	#20,d3		;sur X et Y

	moveq	#0,d1		;Y ‚cran
Put_Bcl0	moveq	#0,d0		;X ‚cran
Put_Bcl1	move.w	d0,dst_xmin(a0)	;c'est … ces coordonn‚es que l'on
	move.w	d1,dst_ymin(a0)	;veut afficher le bloc
	move.w	#113,src_xmin(a0)	;coordonn‚es du masque (qui est,
	move.w	#5,src_ymin(a0)	;et doit ˆtre de couleur 15)
	move.w	#4,blit_op(a0)	;on fait (NOT masque) AND dest
				;pour trouer le fond (phase 1)
	bsr	BitBlt		;pose le masque

	move.w	#5,src_xmin(a0)	;puis on s'occupe du bloc lui
	move.w	#5,src_ymin(a0)	;mˆme, il est situ‚ en (5,5)
	move.w	#7,blit_op(a0)	;Ce coup ci, bloc OR dest
				;pour mettre le sprite (phase 2)
	bsr	BitBlt

	add.w	d2,d0		;augmente X
	cmpi.w	#(320-75),d0	;fin de l'‚cran ?
	ble.s	Put_Bcl1		;pas encore
	add.w	d3,d1		;augmente Y
	addq.w	#8,d3		;augmente son intervalle
	addq.w	#7,d2		;ainsi que celui de X
	cmpi.w	#(200-69),d1	;fin de l'‚cran ?
	ble.s	Put_Bcl0

	move.w	#7,-(sp)		;attendre une touche
	trap	#1		;
	addq.l	#2,sp		;

	CHANGE_REZ	(sp)		;restitue l'ancienne resolution
	addq.l	#2,sp		;cassos
	trap	#1		;repasse en utilisateur
	clr.w	(sp)		;fin du programme
	trap	#1		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=adresse IFF  A1=adresse d‚compactage
;Fixe la palette en mˆme temps,au fait.
;En retour: Z=1 si tout va bien
;Attention, n'est trait‚ que le 320*200 en 16 couleurs...
Depack_IFF
	cmpi.l	#"FORM",(a0)	;Fichier IFF ?
	beq.s	*+4		;oui
	rts			;non,gasp
	cmpi.l	#"ILBM",8(a0)	;Image IFF ?
	beq.s	*+4		;oui
	rts			;non,gasp
	movem.l	d0-a6,-(sp)	;sauve registres
	move.l	4(a0),d0		;taille fichier-8
	lea	8(a0,d0.l),a6	;adresse fin fichier
	lea	12(a0),a0		;Va sur le 1er Chunck
	moveq	#0,d7		;par d‚faut,pas de compression
DIFF_bcl	cmpi.l	#"BMHD",(a0)	;Chunck BitMap Header ?
	beq	DIFF_BMHD		;ouaip
	cmpi.l	#"CMAP",(a0)	;Couleurs ?
	beq	DIFF_CMAP		;
	cmpi.l	#"BODY",(a0)	;corps de l'image ?
	beq	DIFF_BODY		;
DIFF_end	adda.l	4(a0),a0		;Chunck suivant
	addq.l	#8,a0		;
	cmpa.l	a6,a0		;fin du fichier ?
	blt.s	DIFF_bcl		;non
	moveq	#0,d0		;Z=1,tout va bien
	movem.l	(sp)+,d0-a6	;
	rts			;

DIFF_BMHD	move.b	10+8(a0),d7	;type de compression
	bra.s	DIFF_end		;c'est tout !!

DIFF_CMAP	lea	$ffff8240.w,a3	;fixe les couleurs
	moveq	#15,d2		;16 couleurs RGB
	lea	8(a0),a4		;
DC_bcl0	moveq	#0,d1		;
	move.b	(a4)+,d1		;
	lsl.w	#4,d1		;format R
	move.b	(a4)+,d1		;prendre G
	andi.w	#$ff0,d1		;
	move.b	(a4)+,d0		;isole B
	lsr.b	#4,d0		;
	or.b	d0,d1		;combine le tout
	move.w	d1,d0		;
	andi.w	#$eee,d0		;format STE/STF
	andi.w	#$111,d1		;
	lsl.w	#3,d1		;
	lsr.w	#1,d0		;
	or.w	d0,d1		;
	move.w	d1,(a3)+		;
	dbf	d2,DC_bcl0		;couleur suivante
	bra.s	DIFF_end		;

DIFF_BODY	lea	4(a0),a2		;
	move.l	(a2)+,d2		;taille donn‚es
	tst.w	d7		;compactage ?
	beq.s	DB_copie		;non !
	cmpi.w	#1,d7		;ByteRun1 ?
	beq.s	*+8		;ouai
	movem.l	(sp)+,d0-a6	;non,cassos
	rts			;
DB_unpack	subq.l	#1,d2		;on va lire un octet de plus
	bmi.s	DIFF_end		;travail fini
	moveq	#0,d0		;
	move.b	(a2)+,d0		;octet de control x
	bpl.s	DB_bloc		;si x>=0 alors copier bloc
	neg.b	d0		;inverse si x<0
	bvs.s	DB_unpack		;x=$80 (=debordement):rien
	move.b	(a2)+,d1		;sinon x+1 fois l'octet suivant
	subq.l	#1,d2		;(une lecture suppl‚mentaire)
DB_byte	move.b	d1,(a1)+		;hop
	dbf	d0,DB_byte		;copier x+1 fois
	bra.s	DB_unpack		;
	
DB_bloc	sub.l	d0,d2		;on lit x+1 octets
	move.b	(a2)+,(a1)+	;
	dbf	d0,DB_bloc+2	;
	subq.l	#1,d2		;
	bra.s	DB_unpack		;

DB_copie	move.b	(a2)+,(a1)+	;non compact‚e, donc recopie
	subq.l	#1,d2		;simplement l'image
	bne.s	DB_copie		;
	bra.s	DB_unpack		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BLIT_base       equ     $ffff8a00
b_raster        equ     $0         ;16 mots de grille
b_src_xinc      equ     $20        ;1 mot
b_src_yinc      equ     $22        ;1 mot
b_src_adr       equ     $24        ;1 mot-long
b_mask1         equ     $28        ;1 mot
b_mask2         equ     $2a        ;1 mot
b_mask3         equ     $2c        ;1 mot
b_dst_xinc      equ     $2e        ;1 mot
b_dst_yinc      equ     $30        ;1 mot
b_dst_adr       equ     $32        ;1 mot-long
b_x_count       equ     $36        ;1 mot
b_y_count       equ     $38        ;1 mot
b_hop           equ     $3a        ;1 octet
b_op            equ     $3b        ;1 octet
b_ctrl          equ     $3c        ;1 octet
b_mode          equ     $3d        ;1 octet


;Structure d‚crivant l'‚cran source, l'‚cran destination, et l'objet
;… d‚placer.
	RSRESET		;Structure qui d‚crit le transfert
src_adr	rs.l	1	;adresse ‚cran source
src_xmin	rs.w	1	;point de d‚part de l'objet graphique
src_ymin	rs.w	1	;dans cet ‚cran source
src_xinc	rs.w	1	;espacement des bitplans
src_width	rs.w	1	;largeur d'une ligne de l'‚cran source
src_nxpl	rs.w	1	;espace entre 2 bitplans (2 octets sur
			;ST,mais plus pour des images IFF)

dst_adr	rs.l	1	;idem, pour les destinations
dst_xmin	rs.w	1	;
dst_ymin	rs.w	1	;
dst_xinc	rs.w	1	;
dst_width	rs.w	1	;
dst_nxpl	rs.w	1	;

obj_width	rs.w	1	;largeur de l'objet graphique
obj_height	rs.w	1	;hauteur
obj_nplane	rs.w	1	;nombre de bitplans de l'objet.
blit_op	rs.w	1	;op‚ration … effectuer

struc_size	rs.w	0	;taille totale.

fxsr	equ	$80	;
nfsr	equ	$40	;
rien	equ	$00	;

_1_1_1	equ	rien	;les 8 diff‚rents cas possibles.
_1_1_2	equ	rien	;ces num‚ros correspondent … ceux pr‚sents
_1_2_1	equ	rien	;dans l'article sur le blitter,pour vous
_1_2_2	equ	fxsr	;faciliter la lecture.
_2_1_1	equ	rien	;
_2_1_2	equ	nfsr	;
_2_2_1	equ	nfsr+fxsr	;
_2_2_2	equ	fxsr	;

left_endmask
	dc.w	%1111111111111111	;masques d'extr‚mit‚s de
right_endmask			;ligne.
	dc.w	%0111111111111111
	dc.w	%0011111111111111
	dc.w	%0001111111111111
	dc.w	%0000111111111111
	dc.w	%0000011111111111
	dc.w	%0000001111111111
	dc.w	%0000000111111111
	dc.w	%0000000011111111
	dc.w	%0000000001111111
	dc.w	%0000000000111111
	dc.w	%0000000000011111
	dc.w	%0000000000001111
	dc.w	%0000000000000111
	dc.w	%0000000000000011
	dc.w	%0000000000000001
	dc.w	%0000000000000000
;
;Nb:dans l'article, j'ai not‚ (a,b) pour (src_xmin,src_ymin)
;                             (c,d) pour (src_xmax,src_ymax)
;                             (x,y) pour (dst_xmin,dst_ymin)
;                             (z,t) pour (dst_xmax,dst_ymax)
;Les notations utilis‚es ici le sont pour des raisons de lisibilit‚.
;
BitBlt	movem.l	d0-a6,-(sp)	;A0=ADRESSE DE LA STRUCTURE
	movea.l	a0,a4		;
	lea	BLIT_base.w,a5	;adresse des registres blitter

	move.w	obj_width(a4),d6	;avec la largeur de l'objet
	subq.w	#1,d6		;
	move.w	src_xmin(a4),d0	;et xmin=a,on calcul 
	move.w	d0,d1		;l'objet est donc le cadre
	add.w	d6,d1		;(xmin=a,ymin=b)-(xmax=c,ymax=d)
	move.w	dst_xmin(a4),d2	;On fait pareil pour sa position
	move.w	d2,d3		;dans la destination
	add.w	d6,d3		;

	moveq	#$0f,d6		;masque pour modulo 16
	move.w	d2,d4		;dst_xmin MOD 16
	and.w	d6,d4		;
	add.w	d4,d4		;on r‚cupŠre le masque de
	move.w	left_endmask(pc,d4.w),d4 ;d‚but de ligne
	move.w	d3,d5		;(cad les pixels … prot‚ger
	and.w	d6,d5		;dans la zone destination)
	add.w	d5,d5		;pareil pour dst_xmax
	move.w	right_endmask(pc,d5.w),d5 ;ca donne le masque de fin
	not.w	d5		;de ligne

	move.w	d2,d7		;calcul de (a MOD 16)-(x MOD 16)
	and.w	d6,d7		;Si (a MOD 16)-(x MOD 16)<0
	and.w	d0,d6		;<=>(a MOD 16)<(x MOD 16)
	sub.w	d6,d7		;Alors X=1
	moveq	#1,d6		;par d‚faut, N=1
	addx.w	d6,d6		;R‚cupŠre X
	add.w	d6,d6		;d‚calage … gauche
;D6 sert … rep‚rer les cas NFSR et FXSR (cf article).Ses diff‚rents bits
;signifient:
;          bit 2 :  0 si N=1
;                   1 si N>1
;
;          bit 1 :  0 si (a MOD 16) <= (x MOD 16)
;                   1 si (a MOD 16) >  (x MOD 16)
;
;          bit 0 :  0 si N=M
;                   1 si N<>M
;
;Je rappelle que M=INT(c/16)-INT(a/16)+1
;    et          N=INT(z/16)-INT(x/16)+1
;
	lsr.w	#4,d0		;a/16
	lsr.w	#4,d1		;c/16
	sub.w	d0,d1		;M-1
	lsr.w	#4,d2		;x/16
	lsr.w	#4,d3		;z/16
	sub.w	d2,d3		;N-1
	bne.s	*+6		;Si N=1
	and.w	d5,d4		;   alors combiner les masques
	subq.w	#4,d6		;   et signaler que N=1

	move.w	d4,b_mask1(a5)	;charge les masques de d‚but
	move.w	#$ffff,b_mask2(a5)	;de milieu et de fin de
	move.w	d5,b_mask3(a5)	;ligne.

	cmp.w	d1,d3		;
	beq.s	*+4		;Si N<>M
	addq.w	#1,d6		;   signale le dans d6

	move.w	d3,d4		;
	addq.w	#1,d4		;(N-1)+1=N
	move.w	d4,b_x_count(a5)	;taille de l'objet en groupe
				;de 16 pixels dans la destination
	move.w	src_ymin(a4),d4	;
	move.w	src_width(a4),d5	;
	mulu	d5,d4		;calcul la position (en adresse)
	add.l	src_adr(a4),d4	;de l'objet dans l'‚cran source
	movea.l	d4,a0		;en fonction de ymin=b

	move.w	src_xinc(a4),d4	;et de xmin=a
	move.w	d4,b_src_xinc(a5)	;
	mulu	d4,d0		;
	adda.l	d0,a0		;adresse finale du source
	mulu	d4,d1		;largeur de l'objet dans la zone
	sub.w	d1,d5		;source, retranch‚e … la largeur
	move.w	d5,b_src_yinc(a5)	;de la source=>yinc

	move.w	dst_ymin(a4),d4	;mˆme calcul pour la destination
	move.w	dst_width(a4),d5	;
	mulu	d5,d4		;
	add.l	dst_adr(a4),d4	;
	movea.l	d4,a1		;
	move.w	dst_xinc(a4),d4	;
	move.w	d4,b_dst_xinc(a5)	;
	mulu	d4,d2		;
	adda.l	d2,a1		;
	mulu	d4,d3		;
	sub.w	d3,d5		;
	move.w	d5,b_dst_yinc(a5)	;

	andi.w	#$000f,d7		;D7=(a MOD 16)-(x MOD 16)
	or.b	mode_flags(pc,d6.w),d7;combine avec FXSR/NFSR
	move.b	d7,b_mode(a5)	;
	move.b	#2,b_hop(a5)	;pas d'op‚ration de grille
	move.b	blit_op+1(a4),b_op(a5);op‚ration demand‚e ?
	lea	b_ctrl(a5),a2	;
	move.w	obj_nplane(a4),d7	;Nombre de bitplan de l'objet
	bra	BB_go		;

mode_flags	dc.b	_1_1_1
	dc.b	_1_1_2
	dc.b	_1_2_1
	dc.b	_1_2_2
	dc.b	_2_1_1
	dc.b	_2_1_2
	dc.b	_2_2_1
	dc.b	_2_2_2

BB_next	move.l	a0,b_src_adr(a5)	;charge les adresses de
	move.l	a1,b_dst_adr(a5)	;d‚part
	move.w	obj_height(a4),b_y_count(a5);le nombre de ligne
	move.b	#$80,(a2)		;lance le blitter
	adda.w	src_nxpl(a4),a0	;passe au bitplan suivant
	adda.w	dst_nxpl(a4),a1	;dans source et destination
BB_wait	tas.b	(a2)		;relance&scrute le blitter
	bmi.s	BB_wait		;pas fini...
BB_go	dbf	d7,BB_next		;bitplan suivant
	movem.l	(sp)+,d0-a6	;
	rts			;

	SECTION	DATA
Image	incbin	blitter.iff
	EVEN

	SECTION	BSS
param	ds.b	struc_size
buffer	ds.b	32000