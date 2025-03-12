	OPT	L5
	opt	o+,C-	;ow-
	OPT	OW-
	nolist
MASQUES = 1		;0=masques g‚n‚r‚s quand pr‚d‚calage
NIVEAU = 5
DEBUG = 0		;0=d‚buggage
INFO = 1-DEBUG		;0=AFFICHE INFO
PRG=1			;0=.PRG
DOWNLOAD = 0		;0=downloading
typemus = 1		;1 … 6
;
; v‚rifier les blocages de scrolling
;  (‡a bugge au niveau 2!!!!)
;
; optimisation en taille :
;	aff_fast3 -> aff_fast2 pour les petites tailles
;	montant -> aff_fast3
; niveau 2 :
;	- pr‚d‚caler les bulles, les petits poissons et les
;	   petites tortues...
;
; bug :
;	chaussures avec les morts droite et gauche
;	centrage en Y des anims
;	r‚affichage ‚cran dans l'eau (r‚surrection)
;
; liste des bugs
;
;	- diagonale
;	- Kalgatrode (2Šme collision ne marche pas toujours)
;	- positions de Toki qui merdent sur Amiga
;
; CE QU'IL FAUT FAIRE :
;
;	- mettre maximum en Incbin (MOVEM.L)
;	- INTEGRER PACKER SPRITES
;	- am‚liorer MOULINETTE DE MAP
;		.B=TAILLE EN X
;		.B=TAILLE EN Y
;		.B=NB VIGNETTES-1
;	- SPRITES ZOOMANTS ???
;
; OPTIMISATIONS A FAIRE :
;
;	automodifier le DBRA dans SPRITE18/19
;	 -> gain de 8 cycles par ligne !!!
;	AMELIORER ROUTINE SPRITE 3 PLANS (APRES ROL.W)
;	AMELIORER LES MOVEM -D(AN) PAR DES SUBQ
;	AMELIORER DECALAGE DE 8 DANS LA ROUTINE DE SPRITES
;
;	output	a:\auto\toki.prg
	OUTPUT	A:TOKI1.PRG
offsety = 0		;Y du haut de l'‚cran
ecran0  = $80000-32000
ecran1  = ecran0-32000
ramtop  = ecran1
hauteur = 176
largeur = 224
basemfp = $40
;
CPU	MACRO
	tst.b	TAB.w
	beq.s	.\@
	move	#\1,$ffff8240.w
.\@
	ENDM

	IFEQ	PRG
	section	text
;
; d‚placement du programme en $800
;
	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	lea	code(pc),a0
	lea	$800.w,a1
	lea	fincode,a2

	lea	$80000,sp
	movem.l	moveit,d0-d7
	movem.l	d0-d7,-(sp)
	jmp	(sp)

moveit:	move.l	(a0)+,(a1)+
	cmp.l	a2,a1
	blo.s	moveit
	jmp	$800.w
	ENDC

	offset	$430
firstoffset:
touches		ds.b	$80-2
joystick0	ds.b	1
joystick1	ds.b	1
ecran:		ds.l	1
sync:		ds.w	1
etat_joy:	ds.w	1
posmapx:	ds.w	1
posmapy:	ds.w	1
lastmusic:	ds.w	1
TAB		ds.b	1
	even
mul160		ds.w	hauteur		;offsety*160+24
;
; variables scrolling
;
xscroll:ds.w	1
yscroll:ds.w	1

ptrbuf:	ds.l	1
ptrbuf2:ds.l	1
restey:	ds.w	1
ptrvert1:ds.l	1
ptrvert2:ds.l	1
ptrhaut:ds.l	1
ptrbas:	ds.l	1
;
; variables g‚n‚rales...
;
lastcentre:ds.w	1		;dernier centrage
lastcentre2:ds.w 1		;dernier centrage
limgau:	ds.w	1		;X gauche
limdro:	ds.w	1		;X droit
limhau:	ds.w	1		;Y haut
limbas:	ds.w	1		;Y bas
limgau2:ds.w	1		;X gauche
limdro2:ds.w	1		;X droit
limhau2:ds.w	1		;Y haut
limbas2:ds.w	1		;Y bas
curzone:ds.w	1		;zone courante
curzone2:ds.w	1		;zone courante

coords0:ds.w	8		;lastx,lasty bitmap 0 … 3
lastxscroll:ds.w	1	;inutiles ??? (xscroll)
lastyscroll:ds.w	1	;inutile ??? (yscroll)

x_block:ds.w	1
y_block:ds.w	1
debut_vign:ds.l	1
debut_map:ds.l	1
TAILLEXMAP:DS.W	1
TAILLEYMAP:DS.W	1

pointeur1:ds.l	1
pointeur2:ds.l	1
pointeur3:ds.l	1
pointeur4:ds.l	1
pointeur5:ds.l	1

sprite_decale:ds.b	1
	list

	nolist
lastoffset:
	section	text
code:
	org	$800
pile:

	move	#$2700,sr
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	lea	pile.w,sp

	lea	firstoffset,a0
	move	#lastoffset-firstoffset-1,d0
.clear:	clr.b	(a0)+
	dbra	d0,.clear

	move.l	#ecran0,d0
	move.l	d0,ecran.w
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	ifeq	DEBUG
	jsr	debugger
	endc

	bsr	initkbd
	clr.b	TAB.w
;
; initialisations avant lancement programme
;
	LEA	mul160.w,a0
	move	#offsety*160+24,d0
	move	#hauteur-1,d1
.mul160	move	d0,(a0)+
	add	#160,d0
	dbra	d1,.mul160

	move.l	#firstvbl,$70.w

	ifne	typemus
	moveq	#typemus,d0
	clr	lastmusic
	jsr	musique
	endc

	move	#$2300,sr

	lea	ramtop,a0
	lea	$80000,a1
	moveq	#0,d0
fill_mem:move.l	d0,(a0)+
	cmp.l	a1,a0
	blo.s	fill_mem

	bsr	afflogo

	MOVE	#NIVEAU,LEVEL
	BSR	FIRSTSCROLL
	bsr	INIT_GAME

	clr	sync.w
bc:	tst	sync.w
	beq.s	bc
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr	sync.w
	move.l	#vbl,$70.w
	move	#100,fade		;fade in
;
; pr‚d‚calage temps r‚el des sprites
;
.NONE	BRA.S	.NONE
	move	LEVEL,d0
	add	d0,d0
	add	d0,d0
	jmp	.decale-4(pc,d0.w)
.decale
	bra.w	predecalage1
	bra.w	predecalage2
	bra.w	predecalage3
	bra.w	predecalage3
	bra.w	predecalage3

predecalage1:
;
; pr‚d‚calage du MONTANT
;
	clr.b	sprite_decale.w
	lea	IMMONTANT,a5		;image … pr‚d‚caler
	lea	buffer_decalages,a4	;adresse buffer scratch‚
	move.l	a4,pointeur1.w
	moveq	#1,d0			;nb sprites
	moveq	#4,d1			;nb d‚calages
	bsr	predecale
;	move	#$2e,d6		;taille en X maximale
;	move	#$30,d7		;taille en Y maximale
;	bsr	genere_sprites

	move.b	#1,sprite_decale.w
	ifeq	DEBUG
	move	#20000,d0
.flk	move	d0,$ffff8240.w
	dbra	d0,.flk
	endc

waitzone2:cmp	#2,curzone.w
	bne.s	waitzone2

	clr.b	sprite_decale.w

	lea	IMGATE,a5		;image … pr‚d‚caler
	lea	buffer_decalages,a4	;adresse buffer scratch‚
	moveq	#1,d0			;nb sprites
	moveq	#4,d1			;nb d‚calages
	move.l	a4,pointeur1.w
	bsr	predecale_sans_mask
;
; pr‚d‚cale la balancoire
;
	move.l	a6,a4
	lea	IMGATE+1*8,A5
	moveq	#3,d0			;nb spr
	moveq	#4,d1			;nb d‚cal
	move.l	a4,pointeur2.w
	bsr	predecale_sans_mask
;
; pr‚d‚cale les tetes gauches
;
	move.l	a6,a4
	lea	IMGATE+4*8,A5
	moveq	#3,d0			;nb spr
	moveq	#4,d1			;nb d‚cal
	move.l	a4,pointeur3.w
	bsr	predecale_sans_mask
;
; pr‚d‚cale les tetes droites
;
	move.l	a6,a4
	lea	IMGATE+15*8,A5
	moveq	#3,d0			;nb spr
	moveq	#4,d1			;nb d‚cal
	move.l	a4,pointeur4.w
	bsr	predecale_sans_mask
;
; pr‚d‚cale les poings
;
	IFEQ	1
	move.l	a6,a4
	lea	IMGATE+26*8,A5
	moveq	#1,d0			;nb spr
	moveq	#4,d1			;nb d‚cal
	move.l	a4,pointeur5.w
;	bsr	predecale

;	move	#$e,d6		;taille en X maximale
;	move	#$14,d6		;taille X max=taille tetes
;	move	#$3e,d7		;taille en Y maximale
;	bsr	genere_sprites
	ENDC

	move.b	#2,sprite_decale.w

	ifeq	DEBUG
	move.l	a6,$300.w

	move	#20000,d0
.flk	move	d0,$ffff8240.w
	dbra	d0,.flk
	endc

waitzone6:cmp	#6,curzone.w
	bne.s	waitzone6

	clr.b	sprite_decale.w
;
; pr‚d‚cale la cascade
;
	lea	buffer_decalages,a4	;adresse buffer scratch‚
	lea	IMCASCA,A5
	moveq	#8,d0			;nb spr
	moveq	#4,d1			;nb d‚cal
	move.l	a4,pointeur1.w
	bsr	predecale_sans_mask

	move.b	#3,sprite_decale.w

	ifeq	DEBUG
	move.l	a6,$300.w

	move	#20000,d0
.flk	move	d0,$ffff8240.w
	dbra	d0,.flk
	endc
;
.boucle:bra.s	.boucle

predecalage2
;
; pr‚d‚calage des bulles
;
	clr.b	sprite_decale.w
	lea	IMBULLE,a5		;image … pr‚d‚caler
	lea	buffer_decalages,a4	;adresse buffer scratch‚
	move.l	a4,pointeur1.w
	moveq	#4,d0			;nb sprites
	moveq	#1,d1			;nb d‚calages
	bsr	predecale
; les petits poissons
	move.l	a6,a4
	lea	IMPOISSON,a5		;image … pr‚d‚caler
	move.l	a4,pointeur2.w
	moveq	#6,d0			;nb sprites
	moveq	#1,d1			;nb d‚calages
	bsr	predecale
; les petites tortues
	move.l	a6,a4
	lea	IMPMOTOI,a5		;image … pr‚d‚caler
	move.l	a4,pointeur3.w
	moveq	#6,d0			;nb sprites
	moveq	#1,d1			;nb d‚calages
	bsr	predecale

	move.b	#4,sprite_decale.w
	ifeq	DEBUG
	move	#20000,d0
.flk	move	d0,$ffff8240.w
	dbra	d0,.flk
	endc

.boucle:bra.s	.boucle

predecalage3
.boucle:bra.s	.boucle

FLAGPAUSE:DC.B	0
	EVEN
prg_sur_vbl:
	CLR	$FFFF8240.W
	tst.b	touches+$19.w
	bne.s	.touchep
	TST.B	FLAGPAUSE
	BEQ.S	.NOPAUSE
.pause	rts
.touchep
	clr.b	touches+$19.w
	not.b	FLAGPAUSE
	bne.s	.pause
.NOPAUSE
	move.l	ecran.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	eor.l	#ecran0^ecran1,ecran.w

	clr	etat_joy.w
	move.b	joystick1.w,d0
	btst	#2,d0
	bne.s	.gau
	tst.b	touches+$4b.w	;gauche
	beq.s	.notgau
.gau	or	#8,etat_joy.w
.notgau
	btst	#3,d0
	bne.s	.dro
	tst.b	touches+$4d.w	;droite
	beq.s	.notdro
.dro	or	#2,etat_joy.w
.notdro
	btst	#0,d0
	bne.s	.hau
	tst.b	touches+$48.w	;haut
	beq.s	.nothau
.hau	or	#1,etat_joy.w
.nothau
	btst	#1,d0
	bne.s	.bas
	tst.b	touches+$50.w	;bas
	beq.s	.notbas
.bas	or	#4,etat_joy.w
.notbas
	btst	#7,d0
	bne.s	.fire
	tst.b	touches+$39.w	;fire
	beq.s	.notfire
.fire	or	#$10,etat_joy.w
.notfire
	move etat_joy.w,d0
	bne.s ddty
	clr.b atreh
ddty:
	btst #1,d0
	bne.s dtty
	btst #3,d0
	bne.s dtty
	clr.b atregd
;--------------------------
dtty:
	bsr	gereall
	bsr	affichescore

	ifeq	DEBUG
	move.l	ecran.w,a6
	move	curzone,d0
;	clr	d0
;	move.b	localvar6,d0
;	move	lastcentre.w,d0
	bsr	print

	move.l	ecran.w,a6
	lea	8*160(a6),a6
;	move	limbas2.w,d0
	move	curzonemort,d0
	bsr	print

	move.l	ecran.w,a6
	lea	16*160(a6),a6
	move	limdro2.w,d0
	bsr	print

	move.l	ecran.w,a6
	lea	24*160(a6),a6
;	move	limbas,d0
	move	coordx,d0
	bsr	print

	move.l	ecran.w,a6
	lea	32*160(a6),a6
;	move	limdro,d0
	move	coordy,d0
	bsr	print
	endc

	ifeq	INFO
	move.l	ecran.w,a6
	move.l	#(ramtop-buffer_decalages)>>4,d0
	bsr	print
	endc
	rts			;fin programme sur vbl

toto:	dc.b	0
pushd0:	dc.b	0
	even

whatpal:
	move	LEVEL,D0
	ADD	D0,D0
	JMP	.zones-2(pc,d0.w)
.zones	bra.s	.lev1
	bra.s	.lev2
	bra.s	.lev3
	bra.s	.lev4
	bra.s	.lev5
.lev1
	cmp	#7,curzone.w
	bhs.s	.pal1
	lea	goodpalette1,a0
	rts
.pal1
	lea	goodpalette2,a0
	rts
.lev2
	cmp	#5,curzone.w
	bhs.s	.pal2
	lea	goodpalette3,a0
	rts
.pal2
	lea	goodpalette4,a0
	rts
.lev3	lea	goodpalette5,a0
	rts
.lev4	lea	goodpalette6,a0
	rts
.lev5
	cmp	#2,curzone.w
	bhs.s	.pal3
	lea	goodpalette7,a0
	rts
.pal3
	lea	goodpalette8,a0
	rts
firstvbl:
	addq	#1,sync.w
vbl:
	movem.l	d0-d7/a0-a6,-(sp)

	tst.b	touches+$1.w
	beq.s	.ohno
	move	#-100&$ff,fade
.ohno
	tst.b	fade+1
	beq	.nofader
	bmi.s	.dispar

	subq.b	#1,fade+1
	add.b	#256/3,fade
	bcc	.nofade
;
; apparition
;
	bsr	whatpal
	lea	palette,a1
	moveq	#16-1,d3
.fadein	move	(a1),d0
	move	(a0)+,d1
	sub	d0,d1
	cmp	#$100,d1
	blo.s	.nor
	add	#$100,d0
.nor	cmp.b	#$10,d1
	blo.s	.nov
	add	#$10,d0
.nov	moveq	#$f,d2
	and	d1,d2
	beq.s	.nob
	addq	#1,d0
.nob	move	d0,(a1)+
	dbra	d3,.fadein

	bra.s	.nofade

.dispar
	addq.b	#1,fade+1
	add.b	#256/3,fade
	bcc.s	.nofade
;
; disparition
;
	lea	palette,a0
	moveq	#16-1,d3
	clr	d2
.fadeout:move	(a0),d0
	cmp	#$100,d0
	blo.s	.nor2
	st	d2
	sub	#$100,d0
.nor2	cmp.b	#$10,d0
	blo.s	.nov2
	st	d2
	sub	#$10,d0
.nov2	moveq	#$f,d1
	and	d0,d1
	beq.s	.nob2
	st	d2
	subq	#1,d0
.nob2	move	d0,(a0)+
	dbra	d3,.fadeout
	tst	d2
	bne.s	.nofade
	move	#100,fade
.nofade
	movem.l	palette,d0-d7
	bra.s	.skipfade
.nofader
	bsr	whatpal
	movem.l	(a0),d0-d7
	movem.l	d0-d7,palette
.skipfade
	move	d0,$ffff8242.w
	movem.l	d1-d7,$ffff8244.w

	ifne	typemus
	moveq	#0,d0

	tst.b	touches+$3b
	beq.s	.paf1
	moveq	#1,d0
.paf1
	tst.b	touches+$3c
	beq.s	.paf2
	moveq	#2,d0
.paf2
	tst.b	touches+$3d
	beq.s	.paf3
	moveq	#3,d0
.paf3
	tst.b	touches+$3e
	beq.s	.paf4
	moveq	#4,d0
.paf4
	tst.b	touches+$3f
	beq.s	.paf5
	moveq	#5,d0
.paf5
	tst.b	touches+$40
	beq.s	.paf6
	moveq	#6,d0
.paf6
	tst.b	touches+$41
	beq.s	.paf7
	moveq	#7,d0
.paf7
	tst.b	touches+$42
	beq.s	.paf8
	moveq	#8,d0
.paf8
	tst.b	touches+$43
	beq.s	.paf9
	moveq	#9,d0
.paf9
	tst.b	touches+$44
	beq.s	.paf10
	moveq	#10,d0
.paf10
	cmp	lastmusic,d0
	beq.s	.same
	move	d0,lastmusic
	beq.s	.same
	jsr	musique
	bra.s	.notsame
.same
	jsr	musique+4
.notsame
	endc

	movem.l	(sp)+,d0-d7/a0-a6
	cmp.l	#firstvbl,$70.w
	beq.s	.novbl

	clr.b	$fffffa1b.w
	move.l	#hblf,basemfp+$20.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#176,$fffffa21.w
	move.b	#8,$fffffa1b.w
.novbl:
	rte
hblf
	pea	(a0)
	pea	(a1)
	lea	palbas+2,a0
	lea	$ffff8242.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	clr.b	$fffffa1b.w
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	tst	sync.w
	beq.s	.letsgo
	addq	#1,sync.w
	rte
.letsgo	addq	#1,sync.w
	move	#$2300,sr
	movem.l	d0-d7/a0-a6,-(sp)

	tst.b	touches+$f.w
	beq.s	.notab
	clr.b	touches+$f.w
	not.b	TAB.w
.notab
	ifeq	DEBUG
	tst.b	touches+$e.w
	beq.s	.noplantage
	dc.l	$4a780001
.noplantage
	endc
	bsr	prg_sur_vbl
	movem.l	(sp)+,d0-d7/a0-a6
	move	#$2700,sr		;‚vite bug

	tst.b	touches+$1d.w	;CTRL
	beq.s	.noreset
	tst.b	touches+$2e.w	;C
	beq.s	.noreset

	IFEQ	DOWNLOAD
	MOVE.L	#$06060000,$FFFF8800.W
	MOVE.L	#$08080000,$FFFF8800.W
	MOVE.L	#$09090000,$FFFF8800.W
	MOVE.L	#$0A0A0000,$FFFF8800.W
	JMP	UPLOAD
.NOUPL
	ELSE
	clr.l	$426.w
	move.l	4.w,a0
	jmp	(a0)
	ENDC
.noreset
	subq	#2,sync.w
	bgt.s	.not1
	CPU	$222
	rte
.not1
	move	d0,-(sp)
	ifeq	DEBUG
	move	#100,d0
.flash	move	d0,$ffff8240.w	;3 ou 4 VBLs !!!
	dbra	d0,.flash
	endc
	move	(sp)+,d0
	clr	sync.w
;	bra	.letsgo		;on retourne au prg
				;quand on d‚passe 2 VBLs !!!
	rte

;basemfp	equ	$40
;
; am‚liorations possible :
;	- mettre le tableau touches … une adresse multiple de 256
;	  (ca fait gagner l'empilement de a0)
;	- mettre ces routines dans le bas de la m‚moire
;	  (changement du vecteur par MOVE.W)
;	- d‚gager TST.B au d‚but
;	- enlever la routine JOYST0 !!!
;
;	offset	$100
;touches		ds.b	$80-2
;joystick0	ds.b	1
;joystick1	ds.b	1
;	section	text
;
; nouvelle routine de clavier (trŠs) optimis‚e
;
initkbd:
	move.b	#$10,$fffffa17.w

.videkey
	tst.b	$fffffc00.w
	bpl.s	.vide
	tst.b	$fffffc02.w
	bra.s	.videkey
.vide
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w

.wikbd	btst	#1,$fffffc00.w
	beq.s	.wikbd
	move.b	#$12,$fffffc02.w	;d‚sactiver souris

	move.l	#kbd,basemfp+$18.w
	or.b	#$40,$fffffa09.w
	or.b	#$40,$fffffa15.w

	lea	touches.w,a0
	moveq	#($80-2)/2-1,d0
	moveq	#0,d1
.clear	move	d1,(a0)+
	dbra	d0,.clear
	clr.b	joystick0.w
	clr.b	joystick1.w
	rts

keybug:	move	#$2700,sr
1$	addq	#7,$ffff8240.w
	bra.s	1$
kbd:
	tst.b	$fffffc00.w
	bpl.s	keybug
	move	d0,-(sp)
;	clr	d0
;	move.b	$fffffc02.w,d0
;	addq.b	#2,d0
	move	#2,d0
	add.b	$fffffc02.w,d0
	bcs.s	codefe
	pea	(a0)
	bclr	#7,d0
	movea	d0,a0
	seq	touches-2(a0)
	move.l	(sp)+,a0
	move	(sp)+,d0
	rte
codefe:
	bne.s	keyff
	move.l	#joyst0,basemfp+$18.w
	move	(sp)+,d0
	rte
keyff	move.l	#joyst1,basemfp+$18.w
	move	(sp)+,d0
	rte
joyst0:
	move.b	$fffffc02.w,joystick0.w
	move.l	#kbd,basemfp+$18.w
	rte
joyst1:
	move.b	$fffffc02.w,joystick1.w
	move.l	#kbd,basemfp+$18.w
	rte

	ifeq	DEBUG*INFO
print:
	moveq	#4-1,d7
hexa:	rol	#4,d0
	moveq	#$f,d1
	and	d0,d1
	asl	#3,d1
	lea	fonte,a0
	add	d1,a0

x	set	0
	rept	5
	move.b	(a0)+,x(a6)
x	set	x+160
	endr

	addq	#1,a6
	move	a6,d1
	lsr	#1,d1
	bcs.s	2$
	addq	#6,a6
2$
	dbra	d7,hexa
	rts
	endc
;
; recentre le sprite par rapport … la coordonn‚e de Toki par rapport … la map
;
const_haut = 64+16	;movey
const_bas = 32		;movey
const_gauche = 64-16	;movex
const_droite = 64	;movex
const_mil = 176/2-16
;
plante:	dc.l	$4a780001		;tst 1.w
changebox:dc.b	0
	even
nomodif:rts
GERE_COORDONNEES
	tst	lastcentre.w
	bne.s	.goodc
	move	#2*4,lastcentre.w
.goodc
	tst.b	fmort
	bne.s	nomodif
	clr.b	changebox
;
; gestion offset d‚placement en X
;  (lin‚aire pour Amiga, constant pour ST)
;
	lea	boxes1-10(pc),a6
	cmp	#1,LEVEL
	beq.s	.1
	lea	boxes2-10(pc),a6
	CMP	#2,LEVEL
	BEQ.S	.1
	lea	boxes3-10(pc),a6
	CMP	#3,LEVEL
	BEQ.S	.1
	lea	boxes4-10(pc),a6
	CMP	#4,LEVEL
	BEQ.S	.1
	lea	boxes5-10(pc),a6
.1
	move	coordx,d6
	move	coordy,d7
	ADDQ	#8,D6		;MILIEU TOKI
	and	#-4,d6		;arrondit en X
.no
	lea	10(a6),A6
.no2
	move	(a6)+,d4
	bmi.s	.centrage2
	movem	(a6)+,d0-d3
	cmp	d0,d6
	blt.s	.no
	cmp	d2,d6
	bgt.s	.no
	cmp	d1,d7
	blt.s	.no
	cmp	d3,d7
	bgt.s	.no
;
; d6=coordx,d7=coordy
; d4=type du scroll
;
	tst	d4
	beq.s	.rescussite

	move	d4,lastcentre.w
	ifeq	DEBUG
	cmp	#.fincentrage-.centrage+4,d4
	bhs	plante
	endc
	move	(a6)+,curzone.w
	move	(a6)+,limgau.w
	move	(a6)+,limhau.w
	move	(a6)+,limdro.w
	move	(a6)+,limbas.w
	beq	plante
.centrage2
	move	lastcentre.w,d4
	jmp	.centrage-4(pc,d4.w)

.rescussite
	move	(a6),d4
	cmp	curzonemort,d4
	bls.s	.no
	st	changebox
	move	d4,curzonemort
	move	2(a6),lastxmort
	move	4(a6),lastymort
	bra.s	.no

.centrage
	bra.w	.centregauche		;1
	bra.w	.centrebas		;2
	bra.w	.centredroit		;3
	bra.w	.centrehaut		;4
	bra.w	.centremilg		;5
.fincentrage

.centrehaut:
	move	d7,d5
	sub	#const_haut,d5
	move	limgau.w,d4		;X=X gauche
	bra.s	.clipy
.centrebas
	move	d7,d5
	sub	#hauteur-const_bas,d5
	move	limgau.w,d4		;X=X gauche
	bra.s	.clipy
.centredroit
	move	d6,d4
	sub	#largeur-const_droite,d4
	move	limhau.w,d5		;Y=Y haut
	bra.s	.clipx
.centregauche
	move	d6,d4
	sub	#const_gauche,d4
	move	limhau.w,d5		;Y=Y haut
	bra.s	.clipx
.centremilg
	move	d6,d4
	sub	#const_gauche,d4
	move	d7,d5
	sub	#const_mil,d5
.clipx
	cmp	limgau.w,d4
	bge.s	.cgg1
	move	limgau.w,d4
.cgg1
	move	limdro.w,d2
	sub	#largeur,d2
	cmp	d2,d4
	ble.s	.cgg2
	move	d2,d4
.cgg2

.clipy
	cmp	limhau.w,d5
	bge.s	.cntrb
	move	limhau.w,d5
.cntrb
	move	limbas.w,d2
	sub	#hauteur,d2

	cmp	d2,d5
	ble.s	.cntrb2
	move	d2,d5
.cntrb2

.calcy
;
; ici d4=xscroll, d5=yscroll
;
;
; 1) borner le d‚placement d'‚cran
;
	tst	lastxscroll.w
	bmi.s	.nomajx
	move	d4,d0
	sub	lastxscroll.w,d0
	addq	#4,d0
	cmp	#8,d0
	blo.s	.nomajx

	sge	d0
	ext	d0
	and	#8,d0
	subq	#4,d0
	add	lastxscroll.w,d0
	move	d0,d4
.nomajx
	tst	lastyscroll.w
	bmi.s	.nomajy
	move	d5,d0
	sub	lastyscroll.w,d0
	addq	#4,d0
	cmp	#8,d0
	blo.s	.nomajy
	sge	d0
	ext	d0
	and	#8,d0
	subq	#4,d0
	add	lastyscroll.w,d0
	move	d0,d5
.nomajy
;
; 2) borner les valeurs du scroll
;
	cmp	TAILLEXMAP.w,d4
	bls.s	.nox
	sge	d4
	ext	d4
	and	TAILLEXMAP.w,d4
.nox
	cmp	TAILLEYMAP.w,d5
	bls.s	.noy
	sge	d5
	ext	d5
	and	TAILLEYMAP.w,d5
.noy
	move	d4,xscroll.w
	move	d4,lastxscroll.w
	move	d5,yscroll.w
	move	d5,lastyscroll.w

	tst.b	changebox
	beq.s	.nochg
	move	lastcentre.w,lastcentre2.w
	move	limgau.w,limgau2.w
	move	limhau.w,limhau2.w
	move	limdro.w,limdro2.w
	move	limbas.w,limbas2.w
	move	curzone.w,curzone2.w
.nochg
	rts
;
; structure du scrolling :
;
;	type	contient le type du scrolling
;		0=centrage Toki bidon
;		1=centrage … gauche
;		2=centrage en bas
;		3=centrage … droite
;		4=centrage en haut
;	x0,y0,x1,y1 repr‚sentent les coordonn‚es haut-gauche et bas-droite
;		     du test de zones
;	lim1,lim2 sont les limites des scrollings
;
	IFEQ	1
DCSCR	MACRO
	DC.W	(\1)*4,\2*16,(33-\5)*16,\4*16,(33-\3)*16,\6*16,(33-\9)*16,\7*16,(33-\8)*16
	ENDM
;X_MAP	= $3c0
;Y_MAP	= $390
;
;
; zone de d‚but !!!
;
	DCSCR	1,0,0,$10,$b,0,$3C,0,$b			;zone 1
boxes:
	DCSCR	1,($2b-14),$2e,$2b,$39,($2b-14),$2B,($39-11),$39	;zone 12=big monster

;	DCSCR	2,X_MAP-largeur,$180,X_MAP,Y_MAP	;2Šme scroll
;	DCSCR	1,0,$2e0,X_MAP-largeur/2,Y_MAP		;1er scroll
;	DCSCR	0,$1D0,0,$1D0+largeur,hauteur		;8Šme=‚cran ennemi
;	DCSCR	3,$210,$180,X_MAP,$1b0			;3Šme scroll
;
;	DCSCR	1,0,0,$1D0+largeur,hauteur		;7Šme scroll
;	DCSCR	2,0,0,largeur,$2E0			;6Šme scroll
;
;;	DCSCR	2,X_MAP-largeur,$180,X_MAP,Y_MAP	;2Šme scroll
;	DCSCR	3,0,$230,$210+largeur,$2E0		;5Šme scroll
;	DCSCR	4,$210,$180,$210+largeur,$2e0		;4Šme scroll

;	DCSCR	1,$2e,6,$33,$b,0,$3C,0,$b		;zone 10 (ST seult)
	DCSCR	2,$30,0,$3B,1,($3c-14),$3c,0,$21	;zone 2
	DCSCR	2,$2E,$14,$3C,$1D,($3c-14),$3c,0,$21	;zone 3
	DCSCR	3,$2A,$1D,$3C,$21,$21,$3C,($21-11),$21	;zone 4
	DCSCR	4,$21,$17,$2A,$21,$21,($21+14),$B,$21	;zone 5
	DCSCR	3,$21,$B,$2E,$13,0,$2F,$b,($b+11)	;zone 6
;	DCSCR	2,0,$B,5,$13,0,(0+14),$B,$39		;zone 7
	DCSCR	2,5,$B,$a,($12-3),0,(0+14),$B,$39	;zone 7=11
	DCSCR	2,0,$30,5,$31,0,(0+14),$B,$39		;zone 8
	DCSCR	1,5,$32,9,$39,0,$2B,($39-11),$39	;zone 9

	dc.w	-1			;fin de table
	ENDC
;
RESU0:	MACRO
	dc.w	0,\1*16,(57-\4)*16,\3*16,(57-\2)*16
	dc.w	\5
	dc.w	\6,\7
	dc.b	'FUCK'
	ENDM

	IFEQ	1
	DC.W	0,$2E0,$3C0,$390,1				;,gauche+droite
boxes1:
	DC.W	1*4,$1D0+48,0,$2B0,$B0,$1D0,0,$2B0,$B0,8	;,0	;big monstre

	RESU0	$30,1,$3B,3,2,$350,$380
	RESU0	$2B,$1E,$2D,$21,4,$2A0,$1B0
	RESU0	$25,$11,$2B,$13,5,$250,$280
	dc.w	0*4,$50,$2a0,$90,$2e0,7,$60,$2C0,0,0
	DC.W	0*4,$60,0,$90,$70,10,$60,$70,0,0

	DC.W	2*4,$300,$380,$3B0,$390,$2E0,$180,$3C0,$390,2	;,haut+bas
	DC.W	2*4,$2E0,$1C0,$3C0,$250,$2E0,$180,$3C0,$390,2	;,haut+bas
	DC.W	3*4,$2A0,$180,$3C0,$1C0,$210,$180,$3C0,$230,3	;,gauche+droite
	DC.W	4*4,$210,$180,$2A0,$220,$210,$180,$2F0,$2E0,4	;,haut+bas
	DC.W	3*4,$210,$260,$2E0,$2E0,0,$230,$2F0,$2E0,5	;,gauche+droite
	DC.W	2*4,$50,$2A0,$A0,$2E0,0,0,$E0,$2E0,6		;,haut+bas
	DC.W	2*4,0,$80,$50,$90,0,0,$E0,$2E0,6		;,haut+bas
	DC.W	1*4,$50,0,$90,$70,0,0,$2B0,$B0,7		;,gauche+droite
;
; zones pour r‚surrection !!!
;
	RESU0	$18,3,$1A,$B,1,$180,$360	;ok
	RESU0	$34,$D,$37,$10,3,$340,$2c0	;ok
	RESU0	$13,$D,$15,$15,6,$130,$2c0

	RESU0	5,$13,7,$1A,8,$50,$260
	RESU0	7,$26,9,$2A,9,$70,$130
	RESU0	$D,$32,$F,$39,11,$D0,$70
	DC.W	-1
	ENDC

	dc.w	0,$2E0,$3C0,$390,1
boxes1:
	dc.w	1*4,$200,$000,$2B0,$0B0,8,$1D0,$000,$2B0,$0B0
	dc.w	0*4,$300,$360,$3B0,$380,2,$350,$380,$4655,$434B
	dc.w	0*4,$2B0,$180,$2D0,$1B0,4,$2A0,$1B0,$4655,$434B
	dc.w	0*4,$250,$260,$2B0,$280,5,$250,$280,$4655,$434B
	dc.w	0*4,$050,$2A0,$090,$2E0,7,$060,$2C0,$4655,$434B
	dc.w	0*4,$050,$000,$090,$070,10,$060,$070,$4655,$434B
	dc.w	2*4,$300,$380,$3B0,$390,2,$2E0,$180,$3C0,$390
	dc.w	2*4,$2E0,$1C0,$3C0,$250,2,$2E0,$180,$3C0,$390
	dc.w	3*4,$2A0,$180,$3C0,$1C0,3,$210,$180,$3C0,$230
	dc.w	4*4,$210,$180,$2A0,$220,4,$210,$180,$2F0,$2E0
	dc.w	3*4,$210,$260,$2E0,$2E0,5,$000,$230,$2F0,$2E0
	dc.w	2*4,$050,$2A0,$0A0,$2E0,6,$000,$000,$0E0,$2E0
	dc.w	2*4,$000,$080,$050,$090,6,$000,$000,$0E0,$2E0
	dc.w	1*4,$050,$000,$090,$070,7,$000,$000,$2B0,$0B0
	dc.w	0*4,$180,$2E0,$1A0,$360,1,$180,$360,$4655,$434B
	dc.w	0*4,$340,$290,$370,$2C0,3,$340,$2C0,$4655,$434B
	dc.w	0*4,$130,$240,$150,$2C0,6,$130,$2C0,$4655,$434B
	dc.w	0*4,$050,$1F0,$070,$260,8,$050,$260,$4655,$434B
	dc.w	0*4,$070,$0F0,$090,$130,9,$070,$130,$4655,$434B
	dc.w	0*4,$0D0,$000,$0F0,$070,11,$0D0,$070,$4655,$434B
	dcb.w	20,-1

DCSCR2	MACRO
	DC.W	\1*4,\2*16,(33-\5)*16,\4*16,(33-\3)*16
	dc.w	\A,\6*16,(33-\9)*16,\8*16,(33-\7)*16
	ENDM
RESU2:	MACRO
	dc.w	0,\1*16,(33-\4)*16,\3*16,(33-\2)*16
	dc.w	\5
	dc.w	\6*16,(33-\7)*16
	dc.b	'FUCK'
	ENDM

	DC.W	0*16,(33-$21)*16,$E*16,(33-0)*16,1
boxes2:
	DCSCR2	1,$8B,$16,$99,$21,$8B,$16,$99,$21,8	;Rambacho

	DCSCR2	2,$00,$15,$0D,$17,$00,$00,$0E,$21,1	;couloir vertical
	DCSCR2	1,$00,$1C,$04,$1E,0,22,$30,$21,2	;couloir horiz
	DCSCR2	1,$24,$1D,$26,$21,0,22,$30,$21,2	;sortie eau

	DCSCR2	5,$1C,$19,$30,$1C,$1B,$0B,$85,$21,3	;eau

	DCSCR2	5,$72,$10,$75,$13,$1B,$0B,$85,$21,3	;chgt palette
	DCSCR2	5,($75-5-2),$10,$78,$13,$1B,$0B,$85,$21,4	;chgt palette
	DCSCR2	5,$7C,$10,$7E,$13,$1B,$0B,$85,$21,5	;EAU

	DCSCR2	2,$7F,$10,$83,$13,$7C,$0E,$8A,$21,6	;VERTICAL
	DCSCR2	2,$7F,$17,$83,$18,$7C,$0E,$8A,$21,6	;VERTICAL
	DCSCR2	1,$7D,$1A,$7F,$1C,$77,22,$99,$21,7	;HORIZ

	DCSCR2	5,$64,$0B,$72,$17,$64,$0B,$72,$1A,4	;Neptune

	RESU2	$00,$0E,$0C,$0F,1,$08,$0E
	RESU2	$08,$1C,$09,$21,2,$09,$1C
	RESU2	$23,$1D,$24,$21,3,$23,$1D
	RESU2	$42,$11,$46,$14,4,$43,$12
	RESU2	$63,$16,$64,$21,5,$63,$17
	RESU2	$71,$10,$72,$13,6,$72,$11
	RESU2	$7F,$18,$83,$19,7,$7D,$1A

	DCB.W	20,-1

DCSCR3	MACRO
	DC.W	\1*4,\2*16,($58-\5)*16,\4*16,($58-\3)*16
	dc.w	\A,\6*16,($58-\9)*16,\8*16,($58-\7)*16
	ENDM
RESU3:	MACRO
	dc.w	0,\1*16,($58-\4)*16,\3*16,($58-\2)*16
	dc.w	\5
	dc.w	\6*16,($58-\7)*16
	dc.b	'FUCK'
	ENDM

	DC.W	$E*16,($58-$58)*16,$38*16,($58-$4D)*16,1
boxes3:
	DCSCR3	1,$8E,$00,$9A,$0B,$8C,$00,$9A,$0B,8	;blocage fin

	RESU3	$2B,$41,$30,$42,3,$2B,$43
	RESU3	$14,$12,$15,$16,8,$14,$12

	DCSCR3	4,$35,$50,$37,$52,$2A,$2C,$38,$58,2	;vertical

	DCSCR3	2,$30,$4B,$38,$4D,$2A,$42,$38,$4D,2	;blocage piaf 1
	DCSCR3	4,$2A,$40,$38,$42,$2A,$2C,$38,$58,2

	DCSCR3	4,$32,$31,$37,$33,$2A,$2C,$38,$58,2

	DCSCR3	3,$35,$2C,$37,$30,$00,$2C,$38,$37,3	;horiz
	DCSCR3	3,$06,$33,$08,$37,$00,$2C,$38,$37,3

	DCSCR3	4,$04,$31,$06,$33,$00,$0B,$0E,$37,4	;vertical

	DCSCR3	2,0,$14,6,$16,$00,$0B,$0E,$16,4		;blocage piaf 2

	DCSCR3	1,$0C,$0B,$0E,$16,$00,$0B,$1C,$16,5	;horiz

;	DCSCR3	1,$00,$11,$04,$15,$00,$0B,$1C,$16,5	;horiz
	DCSCR3	1,$13,$12,$15,$16,$00,$0B,$1C,$16,5

	DCSCR3	4,$16,$10,$1C,$11,$0E,$00,$1C,$16,6	;vertical

	DCSCR3	1,$0E,$04,$12,$05,$0E,$00,$9A,$0B,7	;horiz

	RESU3	$23,$4F,$24,$58,1,$24,$50
	RESU3	$33,$54,$34,$58,2,$33,$55
	RESU3	$34,$2C,$38,$2E,4,$35,$2D
	RESU3	$06,$31,$08,$37,5,$06,$33
	RESU3	$0B,$23,$0D,$24,6,$07,$24
	RESU3	$00,$17,$03,$18,7,$03,$1B
;	RESU3	$0F,$05,$12,$06,9,$12,$07
	RESU3	$26,$02,$28,$0B,10,$26,$02
	RESU3	$3B,$02,$3C,$0B,11,$3B,$02
	RESU3	$4F,$02,$50,$0B,12,$50,$02
	RESU3	$7F,$01,$80,$0B,13,$7F,$01
	dcb.w	20,-1

DCSCR4	MACRO
	DC.W	\1*4,\2*16,($21-\5)*16,\4*16,($21-\3)*16
	dc.w	\A,\6*16,($21-\9)*16,\8*16,($21-\7)*16
	ENDM
RESU4:	MACRO
	dc.w	0,\1*16,($21-\4)*16,\3*16,($21-\2)*16
	dc.w	\5
	dc.w	\6*16,($21-\7)*16
	dc.b	'FUCK'
	ENDM

	DC.W	0*16,($21-$B)*16,$2A*16,($21-0)*16,1
boxes4:
	DCSCR4	1,$64,$0B,$66,$16,$62,$0B,$70,$16,10	;blocage scroll

	DCSCR4	1,$22,$02,$24,$07,$00,$00,$2A,$0B,1	;horiz

	DCSCR4	2,$24,$04,$26,$06,$1C,$00,$2A,$21,2	;vert
	DCSCR4	2,$1D,$17,$1F,$19,$1C,$00,$2A,$21,2	;vert

	DCSCR4	1,$1F,$19,$21,$21,$1C,$16,$54,$21,3	;horiz

	DCSCR4	4,$50,$1B,$52,$1D,$46,$0B,$54,$21,4	;vert

	DCSCR4	3,$50,$14,$52,$16,$29,$0B,$54,$16,5	;horiz

	DCSCR4	4,$2B,$12,$2D,$13,$29,$00,$37,$16,6	;vert
	DCSCR4	4,$2B,$0B,$2D,$0C,$29,$00,$37,$16,6	;vert

	DCSCR4	5,$2B,$0A,$2D,$0B,$29,$00,$62,$0B,7	;horiz
	DCSCR4	5,$55,$02,$58,$07,$29,$00,$62,$0B,7	;horiz

	DCSCR4	2,$59,$04,$5D,$07,$54,$00,$62,$16,8	;vert
	DCSCR4	2,$55,$12,$58,$13,$54,$00,$62,$16,8	;vert

	DCSCR4	1,$58,$13,$5A,$16,$54,$0B,$70,$16,9	;horiz

	dcb.w	20,-1

DCSCR5	MACRO
	DC.W	\1*4,\2*16,($4d-\5)*16,\4*16,($4d-\3)*16
	dc.w	\A,\6*16,($4d-\9)*16,\8*16,($4d-\7)*16
	ENDM
RESU5:	MACRO
	dc.w	0,\1*16,($4D-\4)*16,\3*16,($4D-\2)*16
	dc.w	\5
	dc.w	\6*16,($4D-\7)*16
	dc.b	'FUCK'
	ENDM

	DC.W	0*16,($4d-$B)*16,$a8*16,($4d-0)*16,1
boxes5:
	DCSCR5	1,$80,$00,$81,$0B,$00,$00,$A8,$0B,1	;HORIZ
	DCSCR5	1,$81,$00,$82,$0B,$00,$00,$A8,$0B,2

	DCSCR5	1,$9B,$02,$9C,$0D,$00,$00,$A8,$0B,2
	DCSCR5	2,$9D,$02,$9F,$04,$9A,$00,$A8,$16,3	;VERT
	DCSCR5	2,$9D,$0C,$A0,$0D,$9A,$00,$A8,$16,3

	DCSCR5	1,$A0,$0E,$A1,$15,$9A,$0B,$B6,$16,4	;HORIZ
	DCSCR5	1,$B2,$0C,$B4,$0F,$9A,$0B,$B6,$16,4

	DCSCR5	2,$B2,$0F,$B5,$10,$A8,$0B,$B6,$4D,5	;VERT
	DCSCR5	2,$A9,$43,$B0,$44,$A8,$0B,$B6,$4D,5	;VERT

	DCSCR5	1,$A9,$44,$B0,$45,$A8,$42,$E0,$4D,6	;HORIZ
	dcb.w	20,-1

lastxmort:dc.w	0
lastymort:dc.w	0
curzonemort:dc.w 0

FIRSTSCROLL:
	clr	curzonemort
	move	#$10,lastxmort
	move	#$370,lastymort
	move	#1*4,lastcentre2.w
	lea	boxes1-10,a0
	CMP	#1,LEVEL
	BEQ	.X1
	move	#3*16,lastxmort
	move	#($21-1)*16,lastymort
	MOVE	#2*4,lastcentre2.w
	LEA	boxes2-10,a0
	cmp	#2,LEVEL
	beq.s	.x1
	move	#$f*16,lastxmort
	move	#($58-$50)*16,lastymort
	MOVE	#1*4,lastcentre2.w
	LEA	boxes3-10,a0
	CMP	#3,LEVEL
	BEQ.S	.X1
	move	#2*16,lastxmort
	move	#($21-3)*16,lastymort
	MOVE	#1*4,lastcentre2.w
	LEA	boxes4-10,a0
	CMP	#4,LEVEL
	BEQ.S	.X1
	move	#2*16,lastxmort
	move	#($4d-2)*16,lastymort
	MOVE	#1*4,lastcentre2.w
	LEA	boxes5-10,a0
.X1
	move	(a0)+,limgau2.w
	move	(a0)+,limhau2.w
	move	(a0)+,limdro2.w
	move	(a0)+,limbas2.w
	move	(a0)+,curzone2.w
	RTS

INITSCROLL:
	move	lastcentre2.w,lastcentre.w
	move	limgau2.w,limgau.w
	move	limhau2.w,limhau.w
	move	limdro2.w,limdro.w
	move	limbas2.w,limbas.w
	beq	plante
	move	curzone2.w,curzone.w
	clr.b	fmort
	move	lastymort,coordy
	move	lastxmort,coordx

	lea	coords0.w,a0
	moveq	#8-1,d0
.filit	move	#-1,(a0)+		;$8000
	dbra	d0,.filit
;
	ifeq	DEBUG
	lea	bitmap,a0
	lea	endbitmap,a1
	moveq	#0,d0
clear_it:move.l	d0,(a0)+
	cmp.l	a1,a0
	blo.s	clear_it
	endc
;
; rafraichissement des vignettes
;
	move	lastcentre.w,d0
	jmp	.centrage-4(pc,d0.w)
.centrage
	bra.w	.centregauche		;1
	bra.w	.centrebas		;2
	bra.w	.centredroit		;3
	bra.w	.centrehaut		;4
	bra.w	.centremilg		;5
.centregauche
	move	lastxmort,d0
	move	limhau.w,d1
	sub	#const_gauche,d0
	bra.s	.set
.centredroit
	move	lastxmort,d0
	move	limhau.w,d1
	sub	#largeur-const_droite,d0
	bra.s	.set
.centrebas
	move	limgau.w,d0
	move	lastymort,d1
	sub	#hauteur-const_bas,d1
	bra.s	.set
.centrehaut
	move	limgau.w,d0
	move	lastymort,d1
	sub	#const_haut,d1
	bra.s	.set

.centremilg
	move	lastxmort,d4
	sub	#const_gauche,d4
	move	lastymort,d5
	sub	#const_mil,d5

.set
	cmp	limgau.w,d0
	bge.s	.set0
	move	limgau.w,d0
.set0
	move	limdro.w,d2
	sub	#largeur,d2
	cmp	d2,d0
	ble.s	.set1
	move	d2,d0
.set1
	cmp	limhau.w,d1
	bge.s	.set3
	move	limhau.w,d1
.set3
	move	limbas.w,d2
	sub	#hauteur,d2
	cmp	d2,d1
	ble.s	.set2
	move	d2,d1
.set2

	move	d0,.lim
	add	#largeur+28,d0
	move	d0,xscroll.w
	move	d1,yscroll.w
.refresh:
	BSR	CALCPTRSCROLL
	BSR	REFRESHX
	BSR	REFRESHY

	MOVE	xscroll.w,d0
	cmp	.lim,d0
	beq.s	.okx
	subq	#4,xscroll.w
	bra.s	.refresh
.okx
	move	#-1,lastxscroll.w
	move	#-1,lastyscroll.w
	RTS
.lim	dc.w	0
;
; animation d'un ‚cran largeur*hauteur
;
MOVESCROLL:
	BSR.S	CALCPTRSCROLL
	BSR	REFRESHX
	BSR	REFRESHY

	move.l	ecran.w,a0
	lea	(hauteur-1)*160+largeur/2+24+offsety*160(a0),a0
	move.l	a0,usp
;
; affichage du bas
;
	move	restey.w,d0
	sub	#16,d0
	bls.s	.not2
	move.l	ptrhaut.w,a6
	lea	endscroller(pc),a0
	asl	#3,d0			;*24
	sub	d0,a0
	add	d0,d0
	sub	d0,a0
	move.l	#.retour2,$10.w
	move	#$300,sr		;gain=8 cycles
	jmp	(a0)
.retour2:
	addq	#6,sp
.not2
	cmp	#16,restey.w
	bhi.s	1$
	move	#hauteur,d0
	bra.s	2$
1$
	move	#hauteur+16,d0
	sub	restey.w,d0			;nb lignes en bas
2$
	move.l	ptrbuf.w,a6
	lea	endscroller(pc),a0
	asl	#3,d0			;*24
	sub	d0,a0
	add	d0,d0
	sub	d0,a0

	move.l	#.retour1,$10.w
	move	#$300,sr		;gain=8 cycles
	jmp	(a0)
.retour1:
	addq	#6,sp
	RTS

ymod:	dc.w	0
;
CALCPTRSCROLL:
	bsr.s	CALCNEWPTR

	move	restey.w,d0
	mulu	#(largeur+16)/2,d0
	move.l	a6,ptrhaut.w		;ptr pour afficheur
	move.l	a6,a0
	add.l	d0,a0
	move.l	a0,ptrbuf.w		;ptr pour afficheur
	RTS
;
; calcul des pointeurs de rafraichissement pour le scroller
;  multidirectionnel !!!
;
; retourne a6=d‚but pointeur bitmap d‚cal‚
;
CALCNEWPTR
	moveq	#$f&-4,d1
	and	xscroll.w,d1		;d1=d‚calage
	lsr	#2,d1
	mulu	#bitmap1-bitmap0,d1

	moveq	#-16,d0
	and	xscroll.w,d0
	lsr	#1,d0			;xscroll/16*8

	lea	bitmap,a6
	add.l	d1,a6
	add	d0,a6

	MOVEQ	#0,D0
	move	yscroll.w,d0
	divu	#hauteur+16,d0
	swap	d0
	move	d0,restey.w

	moveq	#-16,d7
	and	restey.w,d7
	mulu	#(largeur+16)/2,d7
	move.l	a6,a0
	add.l	d7,a0
	move.l	a0,ptrbuf2.w
	lea	(largeur+16)*(hauteur+16)/2(a6),a0
	move.l	a0,ptrbas.w

adjust1	equ	16
adjust2	equ	0

	move.l	d7,d0
	add.l	#(largeur+16)*(hauteur+adjust1)/2,d0
	cmp.l	#(largeur+16)*(hauteur+16)/2,d0
	blo.s	3$
	sub.l	#(largeur+16)*(hauteur+16)/2,d0
3$
	move.l	a6,a0
	add.l	d0,a0
	move.l	a0,ptrvert1.w

	move.l	d7,d0
	add.l	#(largeur+16)*(hauteur-adjust2)/2,d0
	cmp.l	#(largeur+16)*(hauteur+16)/2,d0
	blo.s	2$
	sub.l	#(largeur+16)*(hauteur+16)/2,d0
2$
	move.l	a6,a0
	add.l	d0,a0
	move.l	a0,ptrvert2.w
	RTS

INIT_MAP:
	move.l	blocks,a0
	move	(a0)+,D0
	ADD	D0,D0
	MOVE	D0,x_block.w	;nb blocks en X
	ASL	#4-1,D0
	SUB	#largeur,d0
	MOVE	D0,TAILLEXMAP.w
	move	(a0)+,D0
	MOVE	D0,y_block.w	;nb blocks en Y
	ASL	#4,D0
	SUB	#hauteur,d0
	MOVE	D0,TAILLEYMAP.w
	moveq	#0,d0
	move.L	(a0)+,d0
	move.l	a0,debut_vign.w	;adresse base des vignettes
	add.l	d0,a0
	move.l	a0,debut_map.w	;adresse base de map
	rts
REFRESHX:
	moveq	#$f&-4,d1
	and	xscroll.w,d1		;d1=d‚calage
	lea	coords0.w,a0
	add	d1,a0

	moveq	#-4,d7
	and	xscroll.w,d7
	cmp	(a0),d7
	beq	samecoord
	move	d7,d0
	sub	(a0),d7
	move	d0,(a0)
	lsr	#4,d0			;xscroll/16

	moveq	#0,d2
	move	yscroll.w,d2
	lsr	#4,d2
	mulu	x_block.w,d2

	move.l	debut_map.w,a4
	add	d0,a4			;pointeur map
	add	d0,a4			;pointeur map
	add.l	d2,a4

	move.l	ptrbas.w,d6
	move.l	ptrbuf2.w,a6

	tst	d7
	bmi.s	.left2
	lea	largeur/16*2(a4),a4
	lea	largeur/2(a6),a6
	add.l	#largeur/2,d6
.left2	tst	d1			;shift=0 ?
	beq.s	.left
	subq	#8,a6
	subq.l	#8,d6
.left
	lsr	#1,d1

	lea	shifter,a2
	add	(a2,d1.w),a2
	move.l	(a2)+,a0
	move.l	(a2)+,a1

shifte	macro
	lea	.\@(pc),a3
	jmp	(a2)
.\@
	cmp.l	d6,a6
	blo.s	\@1
	lea	-(largeur+16)*(hauteur+16)/2(a6),a6
\@1
	endm

	move.l	debut_vign.w,d7

;
; d5-d7/a2-a4 non utilis‚s dans shift.bin
;
	move	x_block.w,d5

	rept	(hauteur+16)/16
	MOVEQ	#0,D0
	MOVE	(A4),D0		;d‚j… *128
	add	d5,a4
	move.l	d7,a5
	add.l	D0,A5		;a5=source bitmap
	shifte
	endr
samecoord:
	rts

local_y:dc.w	0
REFRESHY:
	clr	local_y
	moveq	#-16,d7
	and	yscroll.w,d7
.reref
	moveq	#$f&-4,d1
	and	xscroll.w,d1		;d1=d‚calage
	lea	coords0+2.w,a0
	add	d1,a0

	cmp	(a0),d7
	bne.s	.diff
	addq	#4,xscroll.w		;rafraichissement next scroll
	addq	#4,local_y
	cmp	#4*4,local_y
	bne.s	.reref
.ret	move	local_y,d0
	sub	d0,xscroll.w
	rts
.diff
	move	d7,d0
	sub	(a0),d7
	move	d0,(a0)
	move	xscroll.w,d0	;correction bug scrolling diagonal !!!!
	and	#-4,d0		;28/03/90
	cmp	-2(a0),d0
	beq.s	.goodx
	sub	#16,local_y
	sub	#16,xscroll.w
	sub	#16,d0
	cmp	-2(a0),d0
	beq.s	.goodx
	move	d0,-2(a0)
	add	#16,xscroll.w
	add	#16,local_y
	ifeq	DEBUG
	move	#$8000,d0
.flash	move	d0,$ffff8240.w		;jamais ???
	dbra	d0,.flash
	endc
.goodx
	tst	local_y
	beq.s	.shift0
	move	d1,-(sp)
	move	d7,-(sp)

	bsr	CALCNEWPTR

	move	(sp)+,d7
	move	(sp)+,d1
.shift0
	moveq	#0,d2
	move	yscroll.w,d2
	lsr	#4,d2
	mulu	x_block.w,d2

	moveq	#0,d0
	move	xscroll.w,d0
	lsr	#4,d0			;xscroll/16

	move.l	debut_map.w,a4
	add	d0,a4			;pointeur map
	add	d0,a4			;pointeur map
	add.l	d2,a4

	move.l	ptrvert1.w,a6		;pointeur buffer
	tst	d7
	bmi.s	.left
	move	x_block.w,d0
	mulu	#hauteur/16,d0
	add	d0,a4
	move.l	ptrvert2.w,a6
.left
	tst	d1
	beq.s	.up
	subq	#8,a6
.up
	lsr	#1,d1

	lea	shifter,a2
	add	(a2,d1.w),a2
	move.l	(a2)+,a0
	move.l	(a2)+,a1

	move.l	debut_vign.w,d7

shifte2	macro
	lea	.\@(pc),a3
	jmp	12(a2)
.\@
	endm
shifte3	macro
	lea	.\@(pc),a3
	jmp	(a2)
.\@
	endm

	MOVEQ	#0,D0
	MOVE	(A4)+,D0	;d‚j… *128
	move.l	d7,a5
	ADD.L	D0,A5		;a5=source bitmap
	lea	-12(a2),a2
	shifte2
	lea	-(largeur+16)*16/2+8(a6),a6
	rept	(largeur+16)/16-2
	MOVEQ	#0,D0
	MOVE	(A4)+,D0	;d‚j… *128
	move.l	d7,a5
	ADD.L	D0,A5		;a5=source bitmap
	shifte3
	lea	-(largeur+16)*16/2+8(a6),a6
	endr
	MOVEQ	#0,D0
	MOVE	(A4)+,D0	;d‚j… *128
	move.l	d7,a5
	ADD.L	D0,A5		;a5=source bitmap
	shifte2
	lea	-(largeur+16)*16/2+8(a6),a6

	move	local_y,d0
	sub	d0,xscroll.w
	rts
;
; affichage du bloc en bas
;
afflogo:
	lea	ecran0+(200-24)*160+24,a1
	lea	logo,a0
	moveq	#24-1,d7
.loopy	moveq	#224/8-1,d6
	lea	ecran1-ecran0(a1),a2
.loopx	move.l	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	dbra	d6,.loopx
	lea	(320-224)/2(a1),a1
	dbra	d7,.loopy
	rts

fastscroller
;
; la routine suivante fait 24 octets par ligne
;
x	set	hauteur*(largeur+16)/2
	rept	hauteur
x	set	x-(largeur+16)/2
	movem.l	x+56(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	movem.l	x(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	lea	-160+largeur/2(a7),a7
	endr
	illegal
endscroller

affichescore:
	lea	plus1+4(pc),a0
	lea	score+4(pc),a1
	sub	d0,d0
	abcd	-(a0),-(a1)
	abcd	-(a0),-(a1)
	abcd	-(a0),-(a1)
	abcd	-(a0),-(a1)
	lea	chiffres(pc),a0
	move.l	score(pc),d0
	move.l	#$0f0f0f0f,d1
	and.l	d0,d1
	eor.l	d1,d0
	lsr.l	#1,d0
	asl.l	#3,d1
	movep.l	d0,0(a0)
	movep.l	d1,1(a0)

	move.l	ecran.w,a6
	lea	(200-6)*160+128-8(a6),a6
	lea	chiffres(pc),a0
	lea	minifonte4(pc),a5
	clr	d0
	moveq	#2-1,d1
.affiche:
	move.l	a5,a1
	lea	minifonte0-minifonte4(a5),a2
	move.l	a1,a3
	move.l	a2,a4

	move.b	(a0)+,d0
	add	d0,a1
	move.b	(a0)+,d0
	add	d0,a2
	move.b	(a0)+,d0
	add	d0,a3
	move.b	(a0)+,d0
	add	d0,a4

	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,(a6)+
	move.b	(a3)+,d0
	or.b	(a4)+,d0
	move.b	d0,(a6)+
	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,160-2(a6)
	move.b	(a3)+,d0
	or.b	(a4)+,d0
	move.b	d0,160-1(a6)
	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,160*2-2(a6)
	move.b	(a3)+,d0
	or.b	(a4)+,d0
	move.b	d0,160*2-1(a6)
	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,160*3-2(a6)
	move.b	(a3)+,d0
	or.b	(a4)+,d0
	move.b	d0,160*3-1(a6)
	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,160*4-2(a6)
	move.b	(a3)+,d0
	or.b	(a4)+,d0
	move.b	d0,160*4-1(a6)

	addq	#6,a6
	dbra	d1,.affiche
	rts

plus1:	dc.l	1
score:	dc.l	0
chiffres:ds.b	8
minifonte0:
 dc.b $7,$5,$5,$5,$7,0,0,0 	;0
 dc.b $2,$6,$2,$2,$7,0,0,0 	;1
 dc.b $7,$1,$7,$4,$7,0,0,0 	;2
 dc.b $7,$1,$7,$1,$7,0,0,0 	;3
 dc.b $4,$5,$7,$1,$1,0,0,0	;4
 dc.b $7,$4,$7,$1,$7,0,0,0 	;5
 dc.b $7,$4,$7,$5,$7,0,0,0 	;6
 dc.b $7,$1,$1,$1,$1,0,0,0 	;7
 dc.b $7,$5,$7,$5,$7,0,0,0	;8
 dc.b $7,$5,$7,$1,$7,0,0,0	;9
minifonte4
 dc.b $70,$50,$50,$50,$70,0,0,0 ;0
 dc.b $20,$60,$20,$20,$70,0,0,0 ;1
 dc.b $70,$10,$70,$40,$70,0,0,0 ;2
 dc.b $70,$10,$70,$10,$70,0,0,0 ;3
 dc.b $40,$50,$70,$10,$10,0,0,0 ;4
 dc.b $70,$40,$70,$10,$70,0,0,0 ;5
 dc.b $70,$40,$70,$50,$70,0,0,0 ;6
 dc.b $70,$10,$10,$10,$10,0,0,0 ;7
 dc.b $70,$50,$70,$50,$70,0,0,0 ;8
 dc.b $70,$50,$70,$10,$70,0,0,0 ;9
;
; routine d'affichage des sprites
;
pasaffbob:
	bclr	#7,28(a0)
	rts

bob:
	tst.b 24(a0)		;si type = 0
	beq.s pasaffbob		;pas afficher sprite

	movem.w xmap(a0),d0-d1
	sub posmapx.w,d0			;pour X
	sub posmapy.w,d1
	add #176,d1
	movem.w d0-d1,(a0)

	move.l 20(a0),a5		;init source image
	moveq #0,d0
	move.b 8(a0),d0
	subq.b #1,d0
	lsl #3,d0			;*8
	add	d0,a5
	move.l (a5)+,a2			;adresse image

	clr	d1
	move.b	(a5)+,d1
	move	d1,4(a0)		;tail x
	move.b	(a5)+,d1
	move	d1,6(a0)		;tail y
	move 6(a0),d0
	sub d0,2(a0)			;y bas

	move.b	(a5)+,d1		;d‚calage en X
	ext	d1
	add	(a0),d1
	move.b	(a5),d2
	ext	d2
	add	2(a0),d2
	bra.s	skip_bob
aff_bob:
;	move	6(a0),d0
;	sub	d0,2(a0)	;correction Y
aff_bob2:
	move	(a0),d1
	move	2(a0),d2
skip_bob
;
; 0(a0)=X ‚cran
; 2(a0)=Y ‚cran
; 4(a0)=largeur
; 6(a0)=hauteur
; a2=d‚but du sprite
;
	move	4(a0),d3
	move	6(a0),d4

	tst.b	sprite_decale.w
	beq.s	aff_normal
	btst	#5,24(a0)	;types = 16 … 31 ???
	bne	aff_fast	;type=affichage rapide
aff_normal:
	move.l	a2,a6
;
; nouvelle routine de sprite d‚calant
;
; A6=d‚but du bitmap du sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;

	moveq	#15,d5
	add	d5,d3
	and	d3,d5
	sub	d5,d3

	lsr	#1,d3		;d3=nboctets/ligne … afficher
;
; registres en entr‚e :
;
;	a6=adresse Bitmap du sprite
;	A1=adresse base ‚cran
;	D1=coordonn‚e X haut gauche
;	D2=coordonn‚e Y haut gauche
;	D3=nb octets de largeur=((largeur en pixels+15)and $FFF0)/2
;	D4=hauteur du sprite
;
	cmp	#hauteur,d2
	blo.s	.cliphau
	bge	.retsp		;trop en bas
	neg	d2
	sub	d2,d4
	bls	.retsp
	mulu	d3,d2
	add	d2,a6
	move	mul160.w,d2
	bra.s	.noclipbas
.cliphau
	move	d2,d0
	add	d4,d0

	add	d2,d2
	lea	mul160.w,a1
	move	(a1,d2.w),d2	;d2=offset ‚cran

	sub	#hauteur,d0
	bls.s	.noclipbas
	sub	d0,d4
.noclipbas

	moveq	#$F,d0		;isole d‚calage et efface flags clipping
	and	d1,d0
	add	d0,d5

	sub	d0,d1
	add	d0,d0		;*4
	add	d0,d0

	asr	#1,d1		;(X and $FFF0)/2
	cmp	#largeur/2,d1	;<160 ?
	blo.s	.clipgau
	bge.s	.retsp		;sprite trop … droite
	neg	d1
	sub	d1,d3		;calcule nb plans restants
	blo.s	.retsp
	move	d1,a3
	add	a3,a6
	or.b	#$40,d0		;indique clipping … gauche
	bra.s	.pacl
.clipgau
	sub.l	a3,a3
	add	d1,d2		;offset Y
	add	d3,d1
	sub	#largeur/2,d1	;>nb plans dans une ligne ?
	blo.s	.noclipdro
	tas	d0		;indique clipping … droite
	sub	d1,d3		;calcul nb plans restants
	move	d1,a3
	bra.s	.pacl
.noclipdro
	cmp	#16,d5
	bhs.s	.pacl
	tas	d0
.pacl
	move.l	ecran.w,a1
	add	d2,a1

	move	#160,a2
	sub	d3,a2
	subq	#1,d4
	lsr	#3,d3
;
; entr‚e :
;	d3=nb plans … afficher
;	d4=nb lignes … afficher
;	a6=ptr bitmap sprite
;	a1=ptr bitmap ‚cran
;	a2=incr‚ment pour ‚cran
;	a3=incr‚ment pour sprite
;
	bset	#7,28(a0)
	LEA	newsprite,a4
	bclr	#6,24(a0)
	beq.s	.noblc
	lea	newblanc,a4
.noblc
	JMP	(a4,d0.w)
.retsp
	bclr	#7,28(a0)
	rts
aff_3plans
;
; 0(a0)=X ‚cran
; 2(a0)=Y ‚cran
; 4(a0)=largeur
; 6(a0)=hauteur
; a2=d‚but du sprite
;
	move	(a0),d1
	move	2(a0),d2
	move	4(a0),d3
	move	6(a0),d4

	move.l	a2,a6

	MOVEQ	#15,D5
	ADD	D5,D3
	AND	D3,D5
	SUB	D5,D3
	lsr	#1,d3		;d3=nboctets/ligne … afficher
;
; registres en entr‚e :
;
;	a6=adresse Bitmap du sprite
;	A1=adresse base ‚cran
;	D1=coordonn‚e X haut gauche
;	D2=coordonn‚e Y haut gauche
;	D3=nb octets de largeur=((largeur en pixels+15)and $FFF0)/2
;	D4=hauteur du sprite
;
	sub.l	a3,a3

	cmp	#hauteur,d2
	blo.s	.1
	bge	.retsp		;trop en bas
	neg	d2
	sub	d2,d4
	bls	.retsp
	mulu	d3,d2
	add	d2,a6

	lsr	#2,d2		;3 plans
	sub	d2,a6

	move	mul160.w,d2
	bra.s	.noclipbas
.1
	move	d2,d0
	add	d4,d0

	add	d2,d2
	lea	mul160.w,a1
	move	(a1,d2.w),d2	;d2=offset ‚cran

	sub	#hauteur,d0
	bls.s	.noclipbas
	sub	d0,d4
.noclipbas

	move	#160,a2
	moveq	#$F,d0		;isole d‚calage et efface flags clipping
	and	d1,d0
	ADD	D0,D5

	sub	d0,d1
	add	d0,d0		;*4
	add	d0,d0

	asr	#1,d1		;(X and $FFF0)/2
	cmp	#largeur/2,d1	;<160 ?
	blo.s	.clipgau
	bge.s	.retsp		;sprite trop … droite
	neg	d1
	sub	d1,d3		;calcule nb plans restants
	blo.s	.retsp

	move	d1,a3

	lsr	#2,d1		;3 plans
	sub	d1,a3

	add	a3,a6

	or.b	#$40,d0		;indique clipping … gauche
	bra.s	.pacl
.clipgau
	add	d1,d2		;offset Y
	add	d3,d1
	sub	#largeur/2,d1	;>nb plans dans une ligne ?
	blo.s	.noclipdro
	tas	d0		;indique clipping … droite
	sub	d1,d3		;calcul nb plans restants
	move	d1,a3

	lsr	#2,d1		;3 plans
	sub	d1,a3
	bra.s	.pacl
.noclipdro
;
;	d4=nb lignes
;
	cmp	#16,d5
	bhs.s	.pacl
	tas	d0
.pacl
	move.l	ecran.w,a1
	add	d2,a1

	sub	d3,a2
	subq	#1,d4
	lsr	#3,d3
;
; entr‚e :
;	d3=nb plans … afficher
;	d4=nb lignes … afficher
;	a6=ptr bitmap sprite
;	a1=ptr bitmap ‚cran
;	a2=incr‚ment pour ‚cran
;	a3=incr‚ment pour sprite
;
	LEA	newsprite2,a4
	JMP	(a4,d0.w)
.retsp
	rts
affichetoki:
	lea	bobtoki,a0
	movem	xmap(a0),d0-d1
	sub	posmapx.w,d0	;pour X
	sub	posmapy.w,d1
	add	#176,d1
	movem	d0-d1,(a0)

	tst.b	toto.W
	bne.s	.no0
	move.b	#90,toto.W
.no0
	tst.b	touches+$61.w
	beq.s	.no61
	clr.b	touches+$61.w
	addq.b	#1,toto.W
.no61
	tst.b	touches+$62.w
	beq.s	.no62
	clr.b	touches+$62.w
	subq.b	#1,toto.W
.no62
	cmp.b	#90,toto.W
	bhi.s	.no1
	clr.b	toto.W
.no1
	cmp.b	#$BD,toto.W
	blo.s	.goodtoto
	clr.b	toto.W
.goodtoto
	clr	d0
	move.b	toto.W,d0
	bne.s	.takeit

	clr	d0
	move.b	8(a0),d0	;numero anim
.takeit
	add	d0,d0
	add	d0,d0
	lea	pstoki-4,a5	;positionstoki
	add	d0,a5

	clr	d0
	move.b	(a5)+,d0	;numero corps
	move.b	d0,localvar6
	asl	#3,d0
	lea	imagecorps-8,a6
	add	d0,a6
	move.l	(a6),localvar1	;ptr bitmap sprite
	clr.l 4(a0)
	move.b 4(a6),5(a0)
	move.b 5(a6),7(a0)

	move.b 6(a6),d0
	ext	d0
	add d0,(a0)
	move.b	7(a6),d0
	ext	d0
	add	d0,2(a0)

	clr	d2
	move.b	(a5)+,d2	;numero de la tete
	move.b	d2,localvar2

	beq.s	affnotete

	add.b	d2,d2
	add	d2,d2
	add	d2,d2
	lea	imagetetes-8,a4
	add	d2,a4
	move.l	(a4),localvar3
	clr.l	bobtete+4
	move.b	4(a4),bobtete+5
	move.b	5(a4),bobtete+7

	lea	bobtoki,a0
	move	(a0),d0	;X ecran
	move.b	(a5)+,d1
	ext	d1
	add	d1,d0		;+decalage->X gauche de la tete
	move	d0,bobtete+0
	move	2(a0),d0	;Y ecran
	sub	6(a0),d0	;-taille Y
	move.b	(a5)+,d1
	ext	d1
	add	d1,d0		;+decalage->Y haut de la tete
	add	6(a4),d0	;+hauteur de la tete
	move	d0,bobtete+2	;->Y bas de la tete
affnotete:
;
; affiche la tete avant le corps si bit 7=1
;
	tst.b	touches+3.w
	bne.s	notete1
	tst.b	localvar2
	bpl.s	notete1
	lea	bobtete,a0
	move.l	localvar3,a2	;adresse image
	bsr	aff_3plans
notete1:
;
; affiche corps de Toki
;
	lea	bobtoki,a0
	move.l	localvar1,a2	;adresse image
	move	6(a0),d0
	sub	d0,2(a0)
	bsr	aff_3plans
;
; affiche la tete aprs le corps si bit 7=0 et si <>0
;
	tst.b	touches+2.w
	bne.s	notete2
	tst.b	localvar2
	ble.s	notete2
	lea	bobtete,a0
	move.l	localvar3,a2	;adresse image
	bsr	aff_3plans
notete2:
	bsr	affcasque

	IFEQ	1
	tst.b	toto
	beq.s	.fini
	moveq	#0,d0
	move.b	localvar6,d0
	mulu	#3,d0
	lea	nikes-3,a1
	add	d0,a1
	clr	d0
	move.b	(a1)+,d0
	beq.s	.fini
;	move.b	d0,localvar6	;debug
	asl	#3,d0
	lea	imagenike-8,a4
	add	d0,a4
	move.l	(a4)+,a2	;ptr bitmap
	lea	bobnike,a0
	move.b	(a4)+,5(a0)	;taille X
	move.b	(a4)+,7(a0)	;taille Y

	move.b	(a1)+,d0	;ajustement en X
	ext	d0
	add	bobtoki,d0	;X casque+correction
;	add	bobtoki+4,d0
	move	d0,(a0)
	move.b	(a1)+,d0	;ajustement en X
	ext	d0
	add	bobtoki+2,d0	;Y haut casque+correction
	add	bobtoki+6,d0
	sub	6(a0),d0
	move	d0,2(a0)
	tst.b	touches+1	;ESC ?
	bne.s	.nonike
	bsr	aff_bob
.nonike
	ENDC
.fini

	tst.b	localvar2
	beq.s	notete3
	move	bobtoki+2,d0
	sub	bobtete+2,d0
	add	bobtoki+6,d0
	cmp	bobtoki+6,d0
	ble.s	notete3
	move	d0,bobtoki+6
notete3

	rts
affcasque:
	tst.b	flcsq
	beq.s	.nocasque
	moveq	#$7f,d0
	and.b	localvar2,d0
	beq.s	.casquesurcorps
	mulu	#3,d0
	lea	casques-3,a1
	add	d0,a1
	clr	d0
	move.b	(a1)+,d0	;num‚ro casque
	beq	.nocasque
	asl	#3,d0
	lea	imcasque-8,a4
	add	d0,a4
	move.l	(a4)+,a2	;ptr bitmap
	lea	bobcasque,a0
	move.b	(a4)+,5(a0)	;taille X
	move.b	(a4)+,7(a0)	;taille Y

	move.b	(a1)+,d0	;ajustement en X
	ext	d0
	add	bobtete,d0	;X casque+correction
	move	d0,(a0)
	move.b	(a1)+,d0	;ajustement en X
	ext	d0
	add	bobtete+2,d0	;Y haut casque+correction
	move	d0,2(a0)
	bsr	aff_bob
.nocasque:
	rts
.casquesurcorps
	lea	casquescorps-3(pc),a1
	move.b	localvar6,d0
.search
	addq	#3,a1
	move.b	(a1)+,d1
	bmi.s	.nocasque
	cmp.b	d0,d1
	bne.s	.search

	clr	d0
	move.b	(a1)+,d0	;num‚ro casque
	add	d0,d0
	add	d0,d0
	add	d0,d0
	lea	imcasque-8,a4
	add	d0,a4
	move.l	(a4)+,a2	;ptr bitmap
	lea	bobcasque,a0
	move.b	(a4)+,5(a0)	;taille X
	move.b	(a4)+,7(a0)	;taille Y

	move.b	(a1)+,d0	;ajustement en X
	ext	d0
	add	bobtoki,d0	;X casque+correction
	move	d0,(a0)
	move.b	(a1)+,d0	;ajustement en X
	ext	d0
	add	bobtoki+2,d0	;Y haut casque+correction
	move	d0,2(a0)
	bsr	aff_bob
	rts

casques:
	dc.b	5,-1,-4		;1 ok
	dc.b	5,-1,-1		;2 ok
	dc.b	5,0,-4		;3 ok
	dc.b	6,-3,-4		;4 ok
	dc.b	6,-3,-1		;5 ok
	dc.b	6,-2,-4		;6 ok
	dc.b	4,-4,-2		;7 ok
	dc.b	7,-5,-2		;8 ok
	dc.b	3,-1,-2		;9 ok
	dc.b	3,-4,-2		;10 ok
	dc.b	3,-4,-2		;11 ok
	dc.b	8,-1,-2		;12 ok
	dc.b	8,1,-2		;13 ok
	dc.b	8,1,-2		;14 ok
	dc.b	2,-2,-4		;15 ok
	dc.b	2,-2,-4		;16 ok
	dc.b	9,-2,-3		;17 ok
	dc.b	9,-1,-3		;18 ok
	dc.b	1,0,0		;19 ok
	dc.b	1,0,0		;20 ok
	dc.b	10,-1,0		;21 ok
	dc.b	10,-3,0		;22 ok
	dc.b	3,-1,-2		;23 ok
	dc.b	3,-4,-2		;24 ok
	dc.b	3,-4,-2		;25 ok
	dc.b	8,-1,-2		;26 ok
	dc.b	8,1,-2		;27 ok
	dc.b	8,1,-2		;28 ok
	dc.b	4,-1,-2		;29 ok
	dc.b	7,-5,-2		;30 ok
	even
;
; structure du tableau
;
;	1er octet=num‚ro du corps
;	2Šme octet=num‚ro du casque
;	3Šme octet=dX
;	4Šme octet=dY
;
casquescorps:
	dc.b	38,7,15,-3
	dc.b	39,7,15,-3
	dc.b	40,4,-2,-3
	dc.b	41,4,-4,-3
	dc.b	45,11,6,0
	dc.b	47,10,4,14
	dc.b	48,10,2,15
	dc.b	49,1,0,15
	dc.b	50,1,-1,14
	dc.b	51,9,8,6
	dc.b	52,9,7,5
	dc.b	53,2,-2,4
	dc.b	54,2,-2,4
	dc.b	63,8,13,2
	dc.b	64,8,12,-2
	dc.b	65,3,-3,-2
	dc.b	66,3,-3,2
	dc.b	75,4,-4,-3
	dc.b	76,4,-4,-3
	dc.b	77,4,-1,-2
	dc.b	78,7,-3,-3
	dc.b	79,7,-4,-2
	dc.b	80,7,-3,-2
	dc.b	81,9,11,-4
	dc.b	82,9,11,-3
	dc.b	83,9,11,-3
	dc.b	84,2,-2,-4
	dc.b	85,2,-2,-4
	dc.b	86,2,-4,-4
	dc.b	87,3,-4,-2
	dc.b	88,3,-4,-2
	dc.b	89,3,-2,-2
	dc.b	90,8,10,-3
	dc.b	91,8,8,-3
	dc.b	92,8,9,-2
	dc.b	-1
	even

	ifeq	1
nikes:
	dc.b	1,0,0
	dc.b	2,0,0
	dc.b	3,0,0
	dc.b	4,-1,0
	dc.b	5,0,0
	dc.b	6,1,0
	dc.b	27,0,0
	dc.b	28,1,0
	dc.b	29,0,0
	dc.b	30,0,0
	dc.b	31,0,0
	dc.b	32,0,0
	dc.b	37,7,0
	dc.b	38,4,0
	dc.b	41,2,0
	dc.b	42,3,0
	dc.b	43,1,0
	dc.b	44,2,1
	dc.b	45,4,0
	dc.b	46,0,0
	dc.b	53,1,0
	dc.b	54,1,0
	dc.b	55,-1,0
	dc.b	56,-2,0
	dc.b	57,-1,0
	dc.b	12,0,0
	dc.b	13,-1,0
	dc.b	14,0,0
	dc.b	15,0,0
	dc.b	16,0,0
	dc.b	17,18,0
	dc.b	18,9,0
	dc.b	19,15,0
	dc.b	20,19,0
	dc.b	21,16,0
	dc.b	12,0,0
	dc.b	21,17,0
	dc.b	12,0,0
	dc.b	12,0,0
	dc.b	21,28,0
	dc.b	21,25,0
	dc.b	9,2,0
	dc.b	25,4,0
	dc.b	7,2,0
	dc.b	10,3,0
	dc.b	11,4,0
	dc.b	7,0,0
	dc.b	7,0,0
	dc.b	26,7,0
	dc.b	26,8,0
	dc.b	7,3,0
	dc.b	7,3,0
	dc.b	26,4,0
	dc.b	26,5,0
	dc.b	26,4,0
	dc.b	7,3,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	0,0,0
	dc.b	33,5,-1
	dc.b	33,4,-1
	dc.b	33,8,-1
	dc.b	34,9,-1
	dc.b	34,9,-1
	dc.b	34,9,-1
	dc.b	35,6,0
	dc.b	35,6,0
	dc.b	35,6,0
	dc.b	36,18,0
	dc.b	36,18,0
	dc.b	36,18,0
	dc.b	39,9,0
	dc.b	39,9,0
	dc.b	39,13,0
	dc.b	40,11,0
	dc.b	40,11,0
	dc.b	40,11,0
	dc.b	63,3,0
	dc.b	62,0,0
	dc.b	61,4,0
	dc.b	60,2,0
	dc.b	59,0,0
	dc.b	47,1,0
	dc.b	48,0,0
	dc.b	49,0,1
	dc.b	50,-1,0
	dc.b	51,0,0
	dc.b	52,0,0
	dc.b	8,2,0

	dc.b	0,0,0		;les 2 morts !!!
	dc.b	0,0,0
	even
	endc

bobtete: dc.w	0	;X
	 dc.w	0	;Y
	 dc.w	0	;taille X
	 dc.w	0	;taille Y
	dcb.b 24-8,0
	 dc.b 1
		even
bobcasque: dc.w	0	;X
	 dc.w	0	;Y
	 dc.w	0	;taille X
	 dc.w	0	;taille Y
	dcb.b 24-8,0
	 dc.b 1
		even
	ifeq	1
bobnike: dc.w	0	;X
	 dc.w	0	;Y
	 dc.w	0	;taille X
	 dc.w	0	;taille Y
	dcb.b 24-8,0
	 dc.b 1
		even
	endc

localvar1:dc.l	0
localvar3:dc.l	0
localvar2:dc.b	0
localvar6:dc.b	0
		even
;
; routine efficace de pr‚d‚calage de sprites...
;
; entr‚e :
;	d0=nb sprites … pr‚d‚caler
;	d1=nb d‚calages d‚sir‚s
;	a5=adresse ptr table … pr‚d‚caler
;	a4=m‚mo des pointeurs (taille X,taille Y,bitmap)
;	   suivis du bitmap des sprites
;
const	equr	d2
reste1	equr	d4
reste2	equr	d5
cptplan	equr	d7

nbdecale:dc.w	0
predecale
	ifne	MASQUES
	bra	predecale_sans_mask
	elseif
	move	d0,-(sp)
	move	d1,nbdecale
	MULU	#4*16,D0
	MOVE.L	A4,A6
	ADD.L	D0,A6
decale
	moveq	#0,d6
1$
	move.l	a6,(a4)+	;poke pointeur bitmap

	move.l	(a5),a3
	move.b	4(a5),d2
	subq.b	#1,d2
	and	#$f,d2		;nb pixels … droite
	clr	d0
	move.b	4(a5),d0
	clr	d1
	move.b	5(a5),d1

	add	#15,d0
	lsr	#4,d0

	movem	d0-d1,nbplan	;nbplan=d0 et nblig=d1

	clr	onemore
	add	d6,d2		;nb pixels aprŠs d‚calage=nb pixels+d‚calage
	cmp	#16,d2		;est-ce que ‡a rajoute un plan ??
;	shs	onemore
	blo.s	7$
	st	onemore
	addq	#1,d0
7$
;
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes
;
	lea	planes(pc),a1
	move	d6,const
	add	const,const
	add	const,const
	move.l	(a1,const.w),const

	subq	#2,nbplan

	move	nblig,d1
2$
	addq	#4,a6

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+
	move.l	d0,d3

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+
	or.l	d3,d0
	move.l	d0,d3
	swap	d0
	or.l	d3,d0
	not.l	d0
	move.l	d0,-12(a6)

	move	nbplan,cptplan
	bmi.s	4$
3$
	swap	reste1
	swap	reste2

	addq	#4,a6

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste1,d0
	eor.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+
	move.l	d0,d3

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste2,d0
	eor.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+
	or.l	d3,d0
	move.l	d0,d3
	swap	d0
	or.l	d3,d0
	not.l	d0
	move.l	d0,-12(a6)

	dbra	cptplan,3$
4$
	tst	onemore
	beq.s	5$

	swap	reste1
	swap	reste2

	move.l	reste1,d0
	or.l	reste2,d0
	move.l	d0,d3
	swap	d0
	or.l	d3,d0
	not.l	d0
	move.l	d0,(a6)+
	move.l	reste1,(a6)+
	move.l	reste2,(a6)+
5$
	subq	#1,d1		;dec nblig
	bne	2$

	move	nbdecale,d1
.zero	addq	#1,d6
	cmp	#16,d6
	bhs.s	.xx
	subq	#1,d1
	beq	1$
	move.L	-4(a4),(a4)+
	bra.s	.zero
.xx
	addq	#8,a5
	subq	#1,(sp)
	bne	decale
	addq	#2,sp
	rts
	endc

planes	DC.L	$00000000,$80008000,$C000C000,$E000E000
	DC.L	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	DC.L	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	DC.L	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE
nbplan:	ds.w	1
nblig:	ds.w	1
onemore:ds.w	1
;
; routine efficace de pr‚d‚calage de sprites...
;	sans calcul de masque
;
; entr‚e :
;	d0=nb sprites … pr‚d‚caler
;	d1=nb d‚calages d‚sir‚s
;	a5=adresse ptr table … pr‚d‚caler
;	a4=m‚mo des pointeurs (taille X,taille Y,bitmap)
;	   suivis du bitmap des sprites
;
predecale_sans_mask
	move	d0,-(sp)
	move	d1,nbdecale
	MULU	#4*16,D0
	MOVE.L	A4,A6
	ADD.L	D0,A6
decale2
	moveq	#0,d6
1$
	tst	d6
	bne.s	.nostock
	move.l	(a5),(a4)+	;pointeur bitmap quand d‚calage de 0 !!!!
	bra	.optim
.nostock
	move.l	a6,(a4)+	;poke pointeur bitmap

	move.l	(a5),a3
	move.b	4(a5),d2
	subq.b	#1,d2
	and	#$f,d2		;nb pixels … droite
	clr	d0
	move.b	4(a5),d0
	clr	d1
	move.b	5(a5),d1

	add	#15,d0
	lsr	#4,d0

	movem	d0-d1,nbplan	;nbplan=d0 et nblig=d1

	clr	onemore
	add	d6,d2		;nb pixels aprŠs d‚calage=nb pixels+d‚calage
	cmp	#16,d2		;est-ce que ‡a rajoute un plan ??

;	shs	onemore
	blo.s	7$
	st	onemore
	addq	#1,d0
7$
;
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes
;
	lea	planes(pc),a1
	move	d6,const
	add	const,const
	add	const,const
	move.l	(a1,const.w),const

	subq	#2,nbplan

	move	nblig,d1
2$
	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+

	move	nbplan,cptplan
	bmi.s	4$
3$
	swap	reste1
	swap	reste2

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste1,d0
	eor.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste2,d0
	eor.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+

	dbra	cptplan,3$
4$
	tst	onemore
	beq.s	5$

	swap	reste1
	swap	reste2

	move.l	reste1,(a6)+
	move.l	reste2,(a6)+
5$
	subq	#1,d1		;dec nblig
	bne.s	2$
.optim
	move	nbdecale,d1
.zero	addq	#1,d6
	cmp	#16,d6
	bhs.s	.xx
	subq	#1,d1
	beq	1$
	move.L	-4(a4),(a4)+
	bra.s	.zero
.xx
	addq	#8,a5
	subq	#1,(sp)
	bne	decale2
	addq	#2,sp
	rts
;
;	LA ROUTINE DE SPRITES !!!!
;
; toujours le meme principe...
;
msk	macro
	move.l	(a2)+,\1
	move.l	\1,\2
	and.l	(a1)+,\1
	or.l	(a2)+,\1
	and.l	(a1)+,\2
	or.l	(a2)+,\2
	endm
;
; affichage d'un sprite clipp‚ pr‚d‚cal‚
;
; entr‚e :
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;
aff_fast:
	moveq	#$f,d0
	and.b	24(a0),d0
	add	d0,d0
	add	d0,d0
	jmp	affichers(pc,d0.w)
affichers
	bra.w	aff_montant	;16=montant pr‚d‚cal‚ (ok)
	bra.w	aff_gateplein	;17=gate plein (ok)
	bra.w	aff_gate	;18=gate (ok)
	bra.w	aff_cascade	;19=cascade (ok)
	bra.w	aff_bulles	;20=bulles
	bra.w	aff_poisson	;21=petit poisson
	bra.w	aff_tortue	;22=petite tortue

;	bra.w	aff_fast2	;pr‚d‚cal‚ avec masque en .L
;	bra.w	aff_fast3	;plein sans masque
;	bra.w	aff_fast4	;pr‚d‚cal‚ sans masque
;				;pr‚d‚cal‚ avec masque en .W
	dc.l	$4a780001

aff_cascade:
	cmp.b	#3,sprite_decale.w
	bne	aff_normal
	clr	d0
	move.b	8(a0),d0
	subq.b	#1,d0
	move.l	pointeur1.w,a2
	bra	aff_fast4

aff_montant:
	move.l	pointeur1.w,a3
	clr	d0
;	addq	#3,d1
	and	#-4,d1		;arrondit en X !!!
	bra.s	aff_fast2
aff_bulles:
	move.l	pointeur1.w,a3
	clr	d0
	move.b	8(a0),d0
	subq.b	#1,d0
	bra.s	aff_fast2
aff_poisson:
	move.l	pointeur2.w,a3
	clr	d0
	move.b	8(a0),d0
	subq.b	#1,d0
	bra.s	aff_fast2
aff_tortue:
	move.l	pointeur3.w,a3
	clr	d0
	move.b	8(a0),d0
	subq.b	#1,d0
	bra.s	aff_fast2

aff_gate:
	move.l	pointeur1.w,a3
	clr	d0
	move.b	8(a0),d0
	subq.b	#1,d0
	beq.s	.ok		;corps gates

	move.l	pointeur2.w,a3
	subq.b	#1,d0
	cmp.b	#3,d0
	blo.s	.ok		;balan‡oire

	move.l	pointeur3.w,a3
	subq.b	#5-2,d0
	cmp.b	#3,d0
	blo.s	.ok		;tetes gauches
	move.l	pointeur4.w,a3
	sub.b	#16-5,d0
	cmp.b	#3,d0
	blo.s	.ok
;	move.l	pointeur5.w,a3
;	sub.b	#27-16,d0	;poing
;	beq.s	.ok
	bra	aff_normal
.ok
	move.l	a3,a2
	bra	aff_fast4
;
; affichage d'un sprite clipp‚ pr‚d‚cal‚
;
; entr‚e :
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;
aff_fast2:

	ifne	MASQUES
	bra	aff_fast4
	elseif
	asl	#6,d0
	move.l	a3,a2
	add	d0,a2

	moveq	#$f,d5
	and	d1,d5
	eor	d5,d1
	add	d5,d3		;nb pixels de largeur

	add	d5,d5
	add	d5,d5
	move.l	(a2,d5.w),a2	;a2=d‚but bitmap

	add	#15,d3
	and	#$FFF0,d3
	lsr	#1,d3		;d3=nboctets/ligne … afficher

	cmp	#hauteur,d2
	blo.s	1$
	bge.s	.fin_fast2

	neg	d2
	sub	d2,d4
	bls.s	.fin_fast2
	mulu	d3,d2
	add	d2,a2
	lsr	#1,d2
	add	d2,a2		;+1/2 pour les masques
	move	mul160.w,d2
	bra.s	2$
.fin_fast2:rts
1$
	move	d2,d0
	add	d4,d0

	lea	mul160.w,a1
	add	d2,d2
	move	(a1,d2.w),d2

	sub	#hauteur,d0
	bls.s	2$
	sub	d0,d4
2$
	asr	#1,d1
	cmp	#largeur/2,d1
	blo.s	3$
	bge.s	.fin_fast2
	neg	d1
	sub	d1,d3
	bls.s	.fin_fast2
	move	d1,a3		;coefficient de clipping
	lsr	#1,d1
	add	d1,a3		;a3=multiple de 12 !!!
	add	a3,a2		;+1/2 pour mask
	bra.s	4$
3$
	add	d1,d2		;offset ‚cran
	add	d3,d1
	sub.l	a3,a3
	sub	#largeur/2,d1
	blo.s	4$
	move	d1,a3
	sub	d1,d3
	lsr	#1,d1
	add	d1,a3		;a3=multiple de 12 !!!
4$
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
	move.l	ecran.w,a1
	add	d2,a1		;adresse ‚cran

	bclr	#6,24(a0)
	bne	newfastblanc
	lsr	#1,d3
	jmp	newfast(pc,d3.w)

newfast
	dc.l	$4a780001
	bra.w	.spr16
	bra.w	.spr32
	bra.w	.spr48
	bra.w	.spr64
	bra.w	.spr80
	bra.w	.spr96
	bra.w	.spr112
	bra.w	.spr128
	bra.w	.spr144
	bra.w	.spr160
	bra.w	.spr176
	bra.w	.spr192
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001
.spr16					;sprite 16 de large
	SUBQ	#1,D4
.1
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	DBRA	D4,.1
	rts
.spr32					;sprite 32 de large
	SUBQ	#1,D4
.2
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	DBRA	D4,.2
	rts
.spr48					;sprite 48 de large
	SUBQ	#1,D4
.3
	msk	d0,d1
	msk	d2,d3
	msk	d6,d7
	movem.l	d0-d3/D6/D7,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	DBRA	D4,.3
	rts
.spr64					;sprite 64 de large
	move	d4,-(sp)
.4
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	.4
	addq	#2,sp
	rts
.spr80					;sprite 64 de large
	move	d4,-(sp)
.5
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160-32(a1),a1
	subq	#1,(sp)
	bne.s	.5
	addq	#2,sp
	rts

.spr96					;sprite 64 de large
	move	d4,-(sp)
.6
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160-32(a1),a1
	subq	#1,(sp)
	bne.s	.6
	addq	#2,sp
	rts

.spr112					;sprite 64 de large
	move	d4,-(sp)
.7
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	movem.l	d0-d5,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160-32(a1),a1
	subq	#1,(sp)
	bne.s	.7
	addq	#2,sp
	rts

.spr128					;sprite 64 de large
	move	d4,-(sp)
.8
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160-32(a1),a1
	subq	#1,(sp)
	bne.s	.8
	addq	#2,sp
	rts

.spr144					;sprite 64 de large
	move	d4,-(sp)
.9
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160-64(a1),a1
	subq	#1,(sp)
	bne	.9
	addq	#2,sp
	rts

.spr160					;sprite 64 de large
	move	d4,-(sp)
.10
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160-64(a1),a1
	subq	#1,(sp)
	bne	.10
	addq	#2,sp
	rts

.spr176					;sprite 64 de large
	move	d4,-(sp)
.11
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	movem.l	d0-d5,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160-64(a1),a1
	subq	#1,(sp)
	bne	.11
	addq	#2,sp
	rts

.spr192					;sprite 64 de large
	move	d4,-(sp)
.12
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160-64(a1),a1
	subq	#1,(sp)
	bne	.12
	addq	#2,sp
	rts

msk2	macro
	move.l	(a2)+,\1
	move.l	\1,\2
	or.l	(a1)+,\1
	or.l	(a1)+,\2
	addq	#8,a2
	endm
newfastblanc
	move	#160,a5
	sub	d3,a5
	lsr	#3,d3
	mulu	#(.bl2-.bl1)/(128/8),d3
	lea	.bl2(pc),a4
	sub	d3,a4
	subq	#1,d4
.bl0
	jmp	(a4)
.bl1
	rept	128/8
	move.l	(a2)+,d0
	not.l	d0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	addq	#8,a2
	endr
.bl2
	add.l	a3,a2			;clippe en X
	add.l	a5,a1
	dbra	d4,.bl0
	rts
	endc
;
; affichage d'un sprite clipp‚ pr‚d‚cal‚
;
; entr‚e :
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;
; affichage d'un sprite plein avec masquage sur les cot‚s
;
fin_fast3:rts
aff_gateplein:
	lea	buffer_decalages,a2
aff_fast3:
;	addq	#3,d1
	and	#-4,d1		;shifting de 4 en 4 !!!!

	moveq	#$f,d5
	and	d1,d5
	eor	d5,d1
	add	d5,d3		;nb pixels de largeur

	add	d5,d5
	add	d5,d5
	move.l	(a2,d5.w),a2	;a2=d‚but bitmap

	add	#15,d3
	and	#$FFF0,d3
	lsr	#1,d3		;d3=nboctets/ligne … afficher

	cmp	#hauteur,d2
	blo.s	1$
	bge.s	fin_fast3

	neg	d2
	sub	d2,d4
	bls.s	fin_fast3
	mulu	d3,d2
	add	d2,a2
	move	mul160.w,d2
	bra.s	2$
1$
	move	d2,d0
	add	d4,d0

	lea	mul160.w,a1
	add	d2,d2
	move	(a1,d2.w),d2

	sub	#hauteur,d0
	bls.s	2$
	sub	d0,d4
2$
	asr	#1,d1
	cmp	#largeur/2,d1
	blo.s	3$
	bge.s	fin_fast3
	neg	d1
	sub	d1,d3
	bls.s	fin_fast3
	move	d1,a3		;coefficient de clipping
	add	a3,a2		;+1/2 pour mask
	bra.s	4$
3$
	add	d1,d2		;offset ‚cran
	add	d3,d1
	sub.l	a3,a3
	sub	#largeur/2,d1
	blo.s	4$
	move	d1,a3
	sub	d1,d3
4$
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
	move.l	ecran.w,a1
	add	d2,a1		;adresse ‚cran

	move.l	(a2),d0
	or.l	4(a2),d0
	move.l	d0,d1
	swap	d0
	or.l	d1,d0
	not.l	d0		;d0=masque gauche

	move.l	-8(a2,d3.w),d1
	or.l	-4(a2,d3.w),d1
	move.l	d1,d2
	swap	d1
	or.l	d2,d1
	not.l	d1		;d1=masque droit

	lsr	#1,d3
	subq	#1,d4
	jmp	newfast2(pc,d3.w)

movem1:	reg	d2/d3
movem2:	reg	d2/d3/d5/d6
movem3:	reg	d2/d3/d5/d6/d7/a4
movem4:	reg	d2/d3/d5/d6/d7/a4/a5/a6

newfast2
	dc.l	$4a780001
	bra.w	.spr16
	bra.w	.spr32
	bra.w	.spr48
	bra.w	.spr64
	bra.w	.spr80
	bra.w	.spr96
	bra.w	.spr112
	bra.w	.spr128
	bra.w	.spr144
	bra.w	.spr160
	bra.w	.spr176
	bra.w	.spr192
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001
	dc.l	$4a780001

MASQUE	MACRO
	move.l	(a1),d7
	and.l	\1,d7
	or.l	(a2)+,d7
	move.l	d7,(a1)+
	move.l	(a1),d7
	and.l	\1,d7
	or.l	(a2)+,d7
	move.l	d7,(a1)+
	ENDM

.spr16					;sprite 16 de large
.1
	MASQUE	D0
	add.l	a3,a2			;clippe en X
	lea	160-8(a1),a1
	dbra	d4,.1
	rts
.spr32					;sprite 32 de large
.2
	MASQUE	D0
	MASQUE	D1
	add.l	a3,a2			;clippe en X
	lea	160-16(a1),a1
	dbra	d4,.2
	rts
.spr48					;sprite 48 de large
.3
	MASQUE	D0
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-24(a1),a1
	dbra	d4,.3
	rts
.spr64					;sprite 64 de large
.4
	MASQUE	D0
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-32(a1),a1
	dbra	d4,.4
	rts
.spr80					;sprite 64 de large
.5
	MASQUE	D0
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-40(a1),a1
	dbra	d4,.5
	rts

.spr96					;sprite 64 de large
.6
	MASQUE	D0
	movem.l	(a2)+,movem4
	movem.l	movem4,(a1)
	lea	4*8(a1),a1
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-48(a1),a1
	dbra	d4,.6
	rts

.spr112					;sprite 64 de large
.7
	MASQUE	D0
	movem.l	(a2)+,movem4
	movem.l	movem4,(a1)
	lea	4*8(a1),a1

	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-56(a1),a1
	dbra	d4,.7
	rts

.spr128					;sprite 64 de large
.8
	MASQUE	D0
	movem.l	(a2)+,movem4
	movem.l	movem4,(a1)
	lea	4*8(a1),a1

	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-64(a1),a1
	dbra	d4,.8
	rts

.spr144					;sprite 64 de large
.9
	MASQUE	D0
	movem.l	(a2)+,movem4
	movem.l	movem4,(a1)
	movem.l	(a2)+,movem3
	movem.l	movem3,4*8(a1)
	lea	7*8(a1),a1
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-72(a1),a1
	dbra	d4,.9
	rts

.spr160					;sprite 64 de large
.10
	MASQUE	D0
	movem.l	(a2)+,movem4
	movem.l	movem4,(a1)
	movem.l	(a2)+,movem4
	movem.l	movem4,4*8(a1)
	lea	8*8(a1),a1
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-80(a1),a1
	dbra	d4,.10
	rts

.spr176					;sprite 64 de large
.11
	MASQUE	D0
	movem.l	(a2)+,movem4
	movem.l	movem4,(a1)
	movem.l	(a2)+,movem4
	movem.l	movem4,4*8(a1)
	lea	8*8(a1),a1
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-88(a1),a1
	dbra	d4,.11
	rts

.spr192					;sprite 64 de large
.12
	MASQUE	D0
	movem.l	(a2)+,movem4
	movem.l	movem4,(a1)
	movem.l	(a2)+,movem4
	movem.l	movem4,4*8(a1)
	lea	8*8(a1),a1

	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	MASQUE	D1

	add.l	a3,a2			;clippe en X
	lea	160-96(a1),a1
	dbra	d4,.12
	rts
;
; affichage d'un sprite clipp‚ pr‚d‚cal‚ sans masque
;
; entr‚e :
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;
aff_fast4:
;	addq	#3,d1
	and	#-4,d1		;shifting de 4 en 4 !!!!

	asl	#6,d0
	add	d0,a2

	moveq	#$f,d5
	and	d1,d5
	eor	d5,d1
	add	d5,d3		;nb pixels de largeur

	add	d5,d5
	add	d5,d5
	move.l	(a2,d5.w),a2	;a2=d‚but bitmap

	add	#15,d3
	and	#$FFF0,d3
	lsr	#1,d3		;d3=nboctets/ligne … afficher

	cmp	#hauteur,d2
	blo.s	1$
	bge.s	.fin_fast2

	neg	d2
	sub	d2,d4
	bls.s	.fin_fast2
	mulu	d3,d2
	add	d2,a2
	move	mul160.w,d2
	bra.s	2$
.fin_fast2:rts
1$
	move	d2,d0
	add	d4,d0

	lea	mul160.w,a1
	add	d2,d2
	move	(a1,d2.w),d2

	sub	#hauteur,d0
	bls.s	2$
	sub	d0,d4
2$
	asr	#1,d1
	cmp	#largeur/2,d1
	blo.s	3$
	bge.s	.fin_fast2
	neg	d1
	sub	d1,d3
	bls.s	.fin_fast2
	move	d1,a3		;coefficient de clipping
	add	a3,a2
	bra.s	4$
3$
	add	d1,d2		;offset ‚cran
	add	d3,d1
	sub.l	a3,a3
	sub	#largeur/2,d1
	blo.s	4$
	move	d1,a3
	sub	d1,d3
4$
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
	move	#160,a5
	sub	d3,a5
	lsr	#3,d3

	move.l	ecran.w,a1
	add	d2,a1		;adresse ‚cran

	subq	#1,d4

	bclr	#6,24(a0)
	bne	newfast4blanc
newfast4
	mulu	#26,d3
	lea	.spr01(pc),a4
	sub	d3,a4
.sprite00
	jmp	(a4)
.spr0
	rept	128/8		;max=128 pixels
	move.l	(a2)+,d0
	move.l	(a2)+,d1
	move.l	d0,d6
	or.l	d1,d6
	move.l	d6,d7
	swap	d6
	or.l	d7,d6
	not.l	d6

	and.l	d6,(a1)
	or.l	d0,(a1)+
	and.l	(a1),d6
	or.l	d1,d6
	move.l	d6,(a1)+
	endr
.spr01
	add	a3,a2
	add	a5,a1
	dbra	d4,.sprite00
	rts

newfast4blanc
	mulu	#14,d3
	lea	.spr01(pc),a4
	sub	d3,a4
.sprite00
	jmp	(a4)
.spr0
	rept	128/8		;max=128 pixels
	move.l	(a2)+,d0
	or.l	(a2)+,d0
	move.l	d0,d1
	swap	d0
	or.l	d1,d0

	or.l	d0,(a1)+
	or.l	d0,(a1)+
	endr
.spr01
	add	a3,a2
	add	a5,a1
	dbra	d4,.sprite00
	rts

	INCLUDE	MICHEL20.S
FINTEXT:
	section	data
	ORG	FINTEXT
LEVEL:	dc.w	1
fade:	dc.w	0		;1er byte=diviseur,2eme byte=afficheur
palette:
	dcb.w	16,0

goodpalette1:
	DC.W	$000,$630,$521,$740
	DC.W	$700,$047,$036,$025
	DC.W	$131,$141,$151,$410
	DC.W	$532,$642,$750,$664
goodpalette2:
	DC.W	$000,$630,$521,$740
	DC.W	$700,$467,$157,$147
	DC.W	$131,$141,$151,$410
	DC.W	$532,$642,$750,$664
goodpalette3:
	DC.W	$000,$630,$521,$740
	DC.W	$700,$047,$036,$025
	DC.W	$030,$040,$050,$410
	DC.W	$532,$642,$750,$664
goodpalette4:
	DC.W	$000,$630,$521,$740
	DC.W	$700,$047,$036,$025
	DC.W	$321,$430,$540,$410
	DC.W	$532,$642,$750,$664
goodpalette5:
	DC.W	$000,$354,$500,$730
	DC.W	$700,$047,$037,$025
	DC.W	$021,$132,$243,$410
	DC.W	$532,$642,$750,$664
goodpalette6:
	DC.W	$000,$060,$077,$057
	DC.W	$700,$047,$037,$025
	DC.W	$030,$040,$050,$410
	DC.W	$532,$642,$750,$775
goodpalette7:
;	DC.W	$000,$050,$521,$630
;	DC.W	$700,$445,$334,$223
;	DC.W	$020,$030,$040,$410
;	DC.W	$532,$642,$750,$664
	DC.W	$000,$050,$521,$630
	DC.W	$445,$700,$334,$223
	DC.W	$020,$030,$040,$410
	DC.W	$532,$642,$750,$664
goodpalette8:
	DC.W	$000,$050,$556,$630
	DC.W	$445,$700,$334,$223
	DC.W	$020,$030,$040,$410
	DC.W	$532,$642,$750,$664

palbas:
	DC.W	$000,$666,$760,$750
	DC.W	$036,$741,$630,$410
	DC.W	$621,$070,$070,$070
	DC.W	$321,$333,$432,$542

	IFEQ	DOWNLOAD
UPLOAD:	INCBIN	E:\INCLUDES\REMOTE.BIN
	ENDC
	ifeq	DEBUG
debugger:incbin	E:\INCLUDES\debugger.bin
	endc
	ifeq	DEBUG*INFO
fonte:	incbin	E:\INCLUDES\fonte.img
	endc
shifter:incbin	E:\INCLUDES\shift5.bin
newsprite
	incbin	E:\INCLUDES\sprite.bin
newsprite2
	INCBIN	E:\INCLUDES\3PLANS4.BIN
newblanc
	INCBIN	E:\INCLUDES\BLANC.BIN

	ifne	typemus
musique:
	bra.w	initmus
	bra.w	playmus
initmus:
	lea	musique1,a0
	cmp	#1,d0
	beq.s	.ok
	lea	musique2,a0
	cmp	#2,d0
	beq.s	.ok
	lea	musique3,a0
	cmp	#3,d0
	beq.s	.ok
	lea	musique4,a0
	cmp	#4,d0
	beq.s	.ok
	lea	musique5,a0
.ok
	move.l	a0,playermus
	jmp	(a0)
playmus:
	move.l	playermus,a0
	jmp	4(a0)
playermus:dc.l	0
musique1:incbin	E:\INCLUDES\TOKI1.BIN
musique2:incbin	E:\INCLUDES\TOKI3.BIN
musique3:incbin	E:\INCLUDES\TOKI4.BIN
musique4:incbin	E:\INCLUDES\TOKI5.BIN
musique5:incbin	E:\INCLUDES\TOKI6.BIN

	ENDC
logo	incbin	E:\INCLUDES\LOGO.IMG

bobtoki:
xtoki	dc.w 30			;pos x
ytoki	dc.w 106		;pos y
	dc.w 32			;tail x
	dc.w 38			;tail y
	dc.b 0,0,0,0		;no image corp,tete,decalx,decaly
	dc.w 0,0		;cpt animation
coordx:	dc.w 40
coordy:	dc.w 880		;xmap,ymap
	dc.l 0		;imagetoki	;ptr sur animation
	dc.b 1			;type de sprite
	even

;
; sprites 1er niveau
;
HERBAMO:EQU	0
TORPEDO:EQU	0
KILLER:	EQU	0
FLYING:	EQU	0
KALGATRO:EQU	0
BLASTUM:EQU	0
GARNIGAR:EQU	0
WEBSTAMI:EQU	0
WOBALIN:EQU	0
GEES:	EQU	0
GEES1:	EQU	0
PIQUE:	EQU	0
BOULE:	EQU	0
REBORD:	EQU	0
MONTANT:EQU	0
ROCHER:	EQU	0
TIRWEBST:EQU	0
TREMPLIN:EQU	0
SHARTOES:EQU	0
CASCADE:EQU	0
TIMAGON:EQU	0
GATE:	EQU	0
GATE1:	EQU	GATE+6272
BIGCORP1:EQU	0
BIGTETE1:EQU	0
;$A
IMHERBAMO:
	DC.L	HERBAMO+$0,$1D160000
	DC.L	HERBAMO+$160,$1D170000
	DC.L	HERBAMO+$2D0,$1E160000
	DC.L	HERBAMO+$430,$1F170000
	DC.L	HERBAMO+$5A0,$1F160000
	DC.L	HERBAMO+$700,$1F160000
	DC.L	HERBAMO+$860,$1D160200
	DC.L	HERBAMO+$9C0,$1D170200
	DC.L	HERBAMO+$B30,$1E160100
	DC.L	HERBAMO+$C90,$1F170000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$6
IMTORPEDO:
	DC.L	TORPEDO+$0,$2F1A0100+7
	DC.L	TORPEDO+$270,$2E130100
	DC.L	TORPEDO+$438,$2D1A0200
	DC.L	TORPEDO+$6A8,$1E221100
	DC.L	TORPEDO+$8C8,$16181100
	DC.L	TORPEDO+$A48,$12101400
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMKILLER:
	DC.L	KILLER+$0,$1E1B0000+2
	DC.L	KILLER+$1B0,$1D0E0000
	DC.L	KILLER+$290,$1E110000+3
	DC.L	KILLER+$3A0,$1D170000
	DC.L	KILLER+$510,$18180200
	DC.L	KILLER+$690,$17160200
	DC.L	KILLER+$7F0,$16140300
	DC.L	KILLER+$930,$1E1B0000+2
	DC.L	KILLER+$AE0,$1D0E0100
	DC.L	KILLER+$BC0,$1E110000+3
	DC.L	KILLER+$CD0,$1D170100
	DC.L	KILLER+$E40,$18180100
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$C
IMFLYING:
	DC.L	FLYING+$0,$181E0000
	DC.L	FLYING+$1E0,$1D0D0000
	DC.L	FLYING+$2B0,$1E120000+5
	DC.L	FLYING+$3D0,$1C1E0000+$11
	DC.L	FLYING+$5B0,$21170000
	DC.L	FLYING+$7D8,$20170100
	DC.L	FLYING+$948,$181E0600
	DC.L	FLYING+$B28,$1D0D0100
	DC.L	FLYING+$BF8,$1E120000+5
	DC.L	FLYING+$D18,$1C1E0200+$11
	DC.L	FLYING+$EF8,$21170300
	DC.L	FLYING+$1120,$20170200
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$16
IMKALGATRO:
	DC.L	KALGATRO+$0,$1A250C00
	DC.L	KALGATRO+$250,$19260C00
	DC.L	KALGATRO+$4B0,$1C250C00
	DC.L	KALGATRO+$700,$19300C00
	DC.L	KALGATRO+$A00,$24270100
	DC.L	KALGATRO+$DA8,$22260300
	DC.L	KALGATRO+$1138,$19240C00
	DC.L	KALGATRO+$1378,$1B200B00
	DC.L	KALGATRO+$1578,$18170E00
	DC.L	KALGATRO+$16E8,$1B100C00
	DC.L	KALGATRO+$17E8,$19050C00
	DC.L	KALGATRO+$1838,$1A250200
	DC.L	KALGATRO+$1A88,$19260300
	DC.L	KALGATRO+$1CE8,$1C250000
	DC.L	KALGATRO+$1F38,$19300300
	DC.L	KALGATRO+$2238,$24270300
	DC.L	KALGATRO+$25E0,$22260300
	DC.L	KALGATRO+$2970,$19240300
	DC.L	KALGATRO+$2BB0,$1B200200
	DC.L	KALGATRO+$2DB0,$18170200
	DC.L	KALGATRO+$2F20,$1B100100
	DC.L	KALGATRO+$3020,$19050300
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$A
IMBLASTUM:
	DC.L	BLASTUM+$0,$20170000
	DC.L	BLASTUM+$170,$1D170000
	DC.L	BLASTUM+$2E0,$20190000
	DC.L	BLASTUM+$470,$1D180000
	DC.L	BLASTUM+$5F0,$14150000
	DC.L	BLASTUM+$740,$20170000
	DC.L	BLASTUM+$8B0,$1D170300
	DC.L	BLASTUM+$A20,$20190000
	DC.L	BLASTUM+$BB0,$1D180300
	DC.L	BLASTUM+$D30,$14150C00
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$11
IMGARNIGAR:
	DC.L	GARNIGAR+$0,$1F170700
	DC.L	GARNIGAR+$170,$1F170600
	DC.L	GARNIGAR+$2E0,$24160000
	DC.L	GARNIGAR+$4F0,$25160800
	DC.L	GARNIGAR+$700,$1F170800
	DC.L	GARNIGAR+$870,$1F170700
	DC.L	GARNIGAR+$9E0,$1F1B0600
	DC.L	GARNIGAR+$B90,$171F0300
	DC.L	GARNIGAR+$D80,$171F0300
	DC.L	GARNIGAR+$F70,$16240400
	DC.L	GARNIGAR+$11B0,$16250400
	DC.L	GARNIGAR+$1400,$171F0300
	DC.L	GARNIGAR+$15F0,$171F0000
	DC.L	GARNIGAR+$17E0,$171F0000
	DC.L	GARNIGAR+$19D0,$16240000
	DC.L	GARNIGAR+$1C10,$16250000
	DC.L	GARNIGAR+$1E60,$171F0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$7
IMWEBSTAMI:
	DC.L	WEBSTAMI+$0,$1C170200
	DC.L	WEBSTAMI+$170,$1C170200
	DC.L	WEBSTAMI+$2E0,$1C180300
	DC.L	WEBSTAMI+$460,$1C180100
	DC.L	WEBSTAMI+$5E0,$1E180000
	DC.L	WEBSTAMI+$760,$20160400
	DC.L	WEBSTAMI+$8C0,$170C0400
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$8
IMWOBALIN:
	DC.L	WOBALIN+$0,$F100800
	DC.L	WOBALIN+$80,$1F180000
	DC.L	WOBALIN+$200,$201C0300
	DC.L	WOBALIN+$3C0,$20210300
	DC.L	WOBALIN+$5D0,$201B0300
	DC.L	WOBALIN+$780,$1A180300
	DC.L	WOBALIN+$900,$17160500
	DC.L	WOBALIN+$A60,$4150000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$A
IMGEES:
	DC.L	GEES+$0,$181C0000
	DC.L	GEES+$1C0,$1C180000
	DC.L	GEES+$340,$181C0000
	DC.L	GEES+$500,$1C180000
	DC.L	GEES+$680,$1D1B0000
	DC.L	GEES+$830,$1D1B0000
	DC.L	GEES+$9E0,$181C0000
	DC.L	GEES+$BA0,$1C180000
	DC.L	GEES+$D20,$181C0000
	DC.L	GEES+$EE0,$1C180000
;$2
IMGEES1:
	DC.L	GEES1+$0,$1A1C0200
	DC.L	GEES1+$1C0,$1A1C0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$3
IMPIQUE:
	DC.L	PIQUE+$0,$20300000
	DC.L	PIQUE+$300,$1C2D0000
	DC.L	PIQUE+$5D0,$192C0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$2
IMBOULE:
	DC.L	BOULE+$0,$F0F0000
	DC.L	BOULE+$78,$D0D0100+$FF		;MICHEL
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$1
IMREBORD:
	DC.L	REBORD+$0,$1B0F0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$1
IMMONTANT:
	DC.L	MONTANT+$0,$2E300100
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$1
IMROCHER:
	DC.L	ROCHER+$0,$201C0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$4
IMTWEBSTAMI:
	DC.L	TIRWEBST+$0,$7080100
	DC.L	TIRWEBST+$40,$8080000
	DC.L	TIRWEBST+$80,$7080000
	DC.L	TIRWEBST+$C0,$8080000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$3
IMTREMPLIN:
	DC.L	TREMPLIN+$0,$19160000
	DC.L	TREMPLIN+$160,$400D0000
	DC.L	TREMPLIN+$300,$400D0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$10
IMSHARTOES:
	DC.L	SHARTOES+$0,$1B070000+5
	DC.L	SHARTOES+$70,$1C0E0000+6
	DC.L	SHARTOES+$150,$1D0E0000+6
	DC.L	SHARTOES+$230,$1B070000+3
	DC.L	SHARTOES+$2A0,$1D0D0000+6
	DC.L	SHARTOES+$370,$1D0E0000+6
	DC.L	SHARTOES+$450,$1D0E0000
	DC.L	SHARTOES+$530,$1D0E0000
	DC.L	SHARTOES+$610,$1B070200+5
	DC.L	SHARTOES+$680,$1C0E0100+6
	DC.L	SHARTOES+$760,$1D0E0000+6
	DC.L	SHARTOES+$840,$1B070200+3
	DC.L	SHARTOES+$8B0,$1D0D0000+6
	DC.L	SHARTOES+$980,$1D0E0000+6
	DC.L	SHARTOES+$A60,$1D0E0000
	DC.L	SHARTOES+$B40,$1D0E0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC

IMCASCA:
	dc.l	CASCADE+0,$30590000
	dc.l	CASCADE+$858,$30590000
	dc.l	CASCADE+$10B0,$30580000
	dc.l	CASCADE+$18F0,$30590000
	dc.l	CASCADE+$2148,$30070000
	dc.l	CASCADE+$21F0,$30090000
	dc.l	CASCADE+$22C8,$30070000
	dc.l	CASCADE+$2370,$30080000
	dc.l	CASCADE+$2430,$30210000		;$3029
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMGATE:
	dc.l	GATE+0,$6B700000
	DC.L	GATE1+$0,$35230000
	DC.L	GATE1+$460,$35230000
	DC.L	GATE1+$8C0,$35230000
	DC.L	GATE1+$D20,$141A0000
	DC.L	GATE1+$EC0,$141A0000
	DC.L	GATE1+$1060,$141A0000
	DC.L	GATE1+$1200,$7081C00
	DC.L	GATE1+$1240,$13091000
	DC.L	GATE1+$12D0,$230C0000
	DC.L	GATE1+$13F0,$230A0000
	DC.L	GATE1+$14E0,$230B0000
	DC.L	GATE1+$15E8,$230A0000
	DC.L	GATE1+$16D8,$20080000
	DC.L	GATE1+$1758,$14050500
	DC.L	GATE1+$17A8,$141A0000
	DC.L	GATE1+$1948,$141A0000
	DC.L	GATE1+$1AE8,$141A0000
	DC.L	GATE1+$1C88,$7080000
	DC.L	GATE1+$1CC8,$13090000
	DC.L	GATE1+$1D58,$230C0000
	DC.L	GATE1+$1E78,$230A0000
	DC.L	GATE1+$1F68,$230B0000
	DC.L	GATE1+$2070,$230A0000
	DC.L	GATE1+$2160,$20080300
	DC.L	GATE1+$21E0,$14050A00
	DC.L	GATE1+$2230,$E3E0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$1A
IMTIMAGON:
	DC.L	TIMAGON+$0,$1F1D0000
	DC.L	TIMAGON+$1D0,$1F1C0000
	DC.L	TIMAGON+$390,$1F1B0000
	DC.L	TIMAGON+$540,$1F1D0000
	DC.L	TIMAGON+$710,$1C1E0000
	DC.L	TIMAGON+$8F0,$271C0000
	DC.L	TIMAGON+$B90,$1F1C0000
	DC.L	TIMAGON+$D50,$1E1C0000
	DC.L	TIMAGON+$F10,$161E0000
	DC.L	TIMAGON+$10F0,$1F1D0800
	DC.L	TIMAGON+$12C0,$1F1D0800
	DC.L	TIMAGON+$1490,$1F1C0800
	DC.L	TIMAGON+$1650,$1F1B0800
	DC.L	TIMAGON+$1800,$1C1E0B00
	DC.L	TIMAGON+$19E0,$271C0000
	DC.L	TIMAGON+$1C80,$1F1C0900
	DC.L	TIMAGON+$1E40,$1E1C0A00
	DC.L	TIMAGON+$2000,$161E1200
	DC.L	TIMAGON+$21E0,$15190100
	DC.L	TIMAGON+$2370,$17170000
	DC.L	TIMAGON+$24E0,$F170000
	DC.L	TIMAGON+$2598,$11160000
	DC.L	TIMAGON+$26F8,$E0A0000
	DC.L	TIMAGON+$2748,$E0A0000
	DC.L	TIMAGON+$2798,$C100300
	DC.L	TIMAGON+$2818,$B0E0200
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC

IMBCORP1:
	DC.L	BIGCORP1+$0,$1E2B0000
	DC.L	BIGCORP1+$2B0,$1E2B0000
	DC.L	BIGCORP1+$560,$1E300000
	DC.L	BIGCORP1+$860,$1E300000
	DC.L	BIGCORP1+$B60,$1E2D0000
	DC.L	BIGCORP1+$E30,$1E2D0000
	DC.L	BIGCORP1+$1100,$2C310000
	DC.L	BIGCORP1+$1598,$2C310000
	DC.L	BIGCORP1+$1A30,$12140000
	DC.L	BIGCORP1+$1B70,$12140000
	DC.L	BIGCORP1+$1CB0,$19160000
	DC.L	BIGCORP1+$1E10,$19160000
	DC.L	BIGCORP1+$1F70,$1A160000
	DC.L	BIGCORP1+$20D0,$1A160000
	DC.L	BIGCORP1+$2230,$1E0F0000
	DC.L	BIGCORP1+$2320,$1E0F0000
	DC.L	BIGCORP1+$2410,$11150000
	DC.L	BIGCORP1+$2560,$11150000
	DC.L	BIGCORP1+$26B0,$15160000
	DC.L	BIGCORP1+$2810,$15160000
	DC.L	BIGCORP1+$2970,$1C160000
	DC.L	BIGCORP1+$2AD0,$1C160000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMBTETE1:
	DC.L	BIGTETE1+$0,$272D0000
	DC.L	BIGTETE1+$438,$282B0000
	DC.L	BIGTETE1+$840,$292B0000
	DC.L	BIGTETE1+$C48,$292B0000
	DC.L	BIGTETE1+$1050,$282B0000
	DC.L	BIGTETE1+$1458,$272D0000
	DC.L	BIGTETE1+$1890,$E0C0000
	DC.L	BIGTETE1+$18F0,$E0C0000
	DC.L	BIGTETE1+$1950,$1A080000
	DC.L	BIGTETE1+$19D0,$1A080000
	DC.L	BIGTETE1+$1A50,$18080000
	DC.L	BIGTETE1+$1AD0,$18080000
	DC.L	BIGTETE1+$1B50,$8080000
	DC.L	BIGTETE1+$1B90,$8080000
	DC.L	BIGTETE1+$1BD0,$9090000
	DC.L	BIGTETE1+$1C18,$9090000
	DC.L	BIGTETE1+$1C60,$B090000
	DC.L	BIGTETE1+$1CA8,$B090000
	DC.L	BIGTETE1+$1CF0,$8080000
	DC.L	BIGTETE1+$1D30,$8080000
	DC.L	BIGTETE1+$1D70,$B050000
	DC.L	BIGTETE1+$1D98,$B050000
	DC.L	BIGTETE1+$1DC0,$B050000
	DC.L	BIGTETE1+$1DE8,$B050000
	DC.L	BIGTETE1+$1E10,$141E0000
	DC.L	BIGTETE1+$1FF0,$141E0000
	DC.L	BIGTETE1+$21D0,$9090000
	DC.L	BIGTETE1+$2218,$9090000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;
; ENNEMIS LEVEL 2
;
BOMBE= 0
CUPPER= 0
POISSON= 0
GABANA= 0
PMOTOI= 0
GMOTOI= 0
MINIFLY:EQU	0
SHOSHI:	EQU	0
NEPTUNE:EQU	0
RAMBACHO:EQU	0

IMBOMBE:
	DC.L	BOMBE+$0,$D0D0600+$FF
	DC.L	BOMBE+$68,$E0E0500
	DC.L	BOMBE+$D8,$F0E0500
	DC.L	BOMBE+$148,$19150000+3
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMCUPPER:
	DC.L	CUPPER+$0,$361B0100
	DC.L	CUPPER+$360,$2F170600+$FF
	DC.L	CUPPER+$588,$32180500
	DC.L	CUPPER+$888,$35180100+$FD
	DC.L	CUPPER+$B88,$33170000+$FF
	DC.L	CUPPER+$E68,$30170000+$FF
	DC.L	CUPPER+$1090,$29160000+$FE
	DC.L	CUPPER+$12A0,$1C110000+$FB
	DC.L	CUPPER+$13B0,$29160E00+$FE
	DC.L	CUPPER+$15C0,$30170700+$FF
	DC.L	CUPPER+$17E8,$33170400+$FF
	DC.L	CUPPER+$1AC8,$35180100+$FD
	DC.L	CUPPER+$1DC8,$32180000
	DC.L	CUPPER+$20C8,$2F170200+$FF
	DC.L	CUPPER+$22F0,$361B0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMGABANA:
	DC.L	GABANA+$0,$1D170200
	DC.L	GABANA+$170,$1D190200+2
	DC.L	GABANA+$300,$1F1B0100
	DC.L	GABANA+$4B0,$1B180000
	DC.L	GABANA+$630,$130F0500
	DC.L	GABANA+$720,$D0A0600
	DC.L	GABANA+$770,$1D190000+2
	DC.L	GABANA+$900,$1D170000
	DC.L	GABANA+$A70,$1C1B0000
	DC.L	GABANA+$C20,$1B1C0000
	DC.L	GABANA+$DE0,$1B1C0000
	DC.L	GABANA+$FA0,$1C1B0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMGMOTOI:
	DC.L	GMOTOI+$0,$24130200+$FF
	DC.L	GMOTOI+$1C8,$26140100
	DC.L	GMOTOI+$3A8,$27100000+$FC
	DC.L	GMOTOI+$528,$221B0600+4
	DC.L	GMOTOI+$7B0,$1E110800+$FC
	DC.L	GMOTOI+$8C0,$170D0A00+$F9
	DC.L	GMOTOI+$990,$20160600+2
	DC.L	GMOTOI+$AF0,$1F0E0700+$FA
	DC.L	GMOTOI+$BD0,$1E110700+$FB
	DC.L	GMOTOI+$CE0,$1F160700+$FE
	DC.L	GMOTOI+$E40,$21180400
	DC.L	GMOTOI+$1080,$1F190700+1
	DC.L	GMOTOI+$1210,$21180700
	DC.L	GMOTOI+$1450,$24130100+$FF
	DC.L	GMOTOI+$1618,$26140000
	DC.L	GMOTOI+$17F8,$27100000+$FC
	DC.L	GMOTOI+$1978,$211B0000+4
	DC.L	GMOTOI+$1C00,$20160000+$0602
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMPMOTOI:
	DC.L	PMOTOI+$0,$130A0100
	DC.L	PMOTOI+$A0,$15080000+$FE
	DC.L	PMOTOI+$120,$100A0300
	DC.L	PMOTOI+$170,$D070400+$FE
	DC.L	PMOTOI+$1A8,$130A0000
	DC.L	PMOTOI+$248,$15080000+$01FE
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMPOISSON:
	DC.L	POISSON+$0,$F0F0000
	DC.L	POISSON+$78,$100D0000+$FF
	DC.L	POISSON+$E0,$F0A0000
	DC.L	POISSON+$130,$D0A0000
	DC.L	POISSON+$180,$F0F0000
	DC.L	POISSON+$1F8,$100D0000+$FF
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMMNFLY:
	DC.L	MINIFLY+$0,$D0F0000+8
	DC.L	MINIFLY+$78,$D0F0000
	DC.L	MINIFLY+$F0,$D0E0000
	DC.L	MINIFLY+$160,$D0D0100
	DC.L	MINIFLY+$1C8,$D0F0000+8
	DC.L	MINIFLY+$240,$D0F0000
	DC.L	MINIFLY+$2B8,$D0E0000
	DC.L	MINIFLY+$328,$D0D0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMSHOSHI:
	DC.L	SHOSHI+$0,$2F2A0000
	DC.L	SHOSHI+$3F0,$2F2A0000
	DC.L	SHOSHI+$7E0,$2F2A0000
	DC.L	SHOSHI+$BD0,$2F2A0000
	DC.L	SHOSHI+$FC0,$2A2F0000
	DC.L	SHOSHI+$1428,$2A2F0000
	DC.L	SHOSHI+$1890,$2A2F0000
	DC.L	SHOSHI+$1CF8,$2A2F0000
	DC.L	SHOSHI+$2160,$1A240000
	DC.L	SHOSHI+$23A0,$1A240000
	DC.L	SHOSHI+$25E0,$1C260000
	DC.L	SHOSHI+$2840,$18251100
	DC.L	SHOSHI+$2A90,$131A1100
	DC.L	SHOSHI+$2C30,$D0E1500
	DC.L	SHOSHI+$2CA0,$18250500
	DC.L	SHOSHI+$2EF0,$1C261200
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMNEPTUNE:
	dc.l	NEPTUNE+$1588,$45510000	;1
	dc.l	NEPTUNE+$2230,$45510000	;2
	dc.l	NEPTUNE+$3AB8,$4D570000+$F801	;3
	dc.l	NEPTUNE+$4850,$51680000+$F503	;4
	dc.l	NEPTUNE+$5BD0,$33440000+$04FE	;5
	dc.l	NEPTUNE+$6450,$26260000+$08F8	;6
	dc.l	NEPTUNE+$67E0,$10200000+$10F0	;7
	dc.l	NEPTUNE+$3120,$27200000	;8
	dc.l	NEPTUNE+$3420,$331C0000	;9
	dc.l	NEPTUNE+$37A0,$21210000	;10
	dc.l	NEPTUNE+$2ED8,$120C0000	;11
	dc.l	NEPTUNE+$2F98,$F310000	;12
	dc.l	NEPTUNE+0,$6D140000	;13
	dc.l	NEPTUNE+$A70,$4D470000	;14
	dc.l	NEPTUNE+$460,$16610000	;15
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC


;$1F($6E72)
IMAGERAMBACHO:
	DC.L	RAMBACHO+$0,$3E280100
	DC.L	RAMBACHO+$500,$3E270100
	DC.L	RAMBACHO+$9E0,$2C200900
	DC.L	RAMBACHO+$CE0,$2C200900
	DC.L	RAMBACHO+$FE0,$2C200900
	DC.L	RAMBACHO+$12E0,$2C200900
	DC.L	RAMBACHO+$15E0,$2C200900
	DC.L	RAMBACHO+$18E0,$2C200900
	DC.L	RAMBACHO+$1BE0,$2C200900
	DC.L	RAMBACHO+$1EE0,$2C200900
	DC.L	RAMBACHO+$21E0,$2C200900
	DC.L	RAMBACHO+$24E0,$2C200900
	DC.L	RAMBACHO+$27E0,$2C200900
	DC.L	RAMBACHO+$2AE0,$2C200900
	DC.L	RAMBACHO+$2DE0,$2C200900
	DC.L	RAMBACHO+$30E0,$40390000
	DC.L	RAMBACHO+$3800,$3F3F0100
	DC.L	RAMBACHO+$3FE0,$403C0000
	DC.L	RAMBACHO+$4760,$3C3F0100
	DC.L	RAMBACHO+$4F40,$403C0000
	DC.L	RAMBACHO+$56C0,$3C3F0300
	DC.L	RAMBACHO+$5EA0,$201F0F00
	DC.L	RAMBACHO+$6090,$1D1E1100
	DC.L	RAMBACHO+$6270,$171B0300
	DC.L	RAMBACHO+$6420,$1B1B0100
	DC.L	RAMBACHO+$65D0,$1B150100
	DC.L	RAMBACHO+$6720,$1B110100
	DC.L	RAMBACHO+$6830,$1C1B0000
	DC.L	RAMBACHO+$69E0,$17190200
	DC.L	RAMBACHO+$6B70,$15180200
	DC.L	RAMBACHO+$6CF0,$17180000

	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;
; SPRITES NIVEAU 3
;
MOGCORP:EQU	0
MOGBRAS:EQU	0
MOGJAMBE:EQU	0
BURP:	EQU	0
KARTURA:EQU	0
PIQUE2:	EQU	0
PIQUE3:	EQU	0
FLAMME:	EQU	0
IVOR:	EQU	0
REBORDL3:EQU	0

;$10($1A52)
IMAGEBURP:
	DC.L	BURP+$0,$11190400
	DC.L	BURP+$190,$131A0300
	DC.L	BURP+$330,$161D0200
	DC.L	BURP+$500,$191D0000
	DC.L	BURP+$6D0,$14180300
	DC.L	BURP+$850,$15190300
	DC.L	BURP+$9E0,$181B0200
	DC.L	BURP+$B90,$1A1C0000
	DC.L	BURP+$D50,$14180500
	DC.L	BURP+$ED0,$141A0400
	DC.L	BURP+$1070,$171C0400
	DC.L	BURP+$1230,$1B1B0000
	DC.L	BURP+$13E0,$11180500
	DC.L	BURP+$1560,$161A0200
	DC.L	BURP+$1700,$181A0200
	DC.L	BURP+$18A0,$1B1B0000
;$17($2652)
IMKARTURA:
	DC.L	KARTURA+$0,$50C0E00+$fc
	DC.L	KARTURA+$60,$A110C00+$fd
	DC.L	KARTURA+$E8,$181B0500
	DC.L	KARTURA+$298,$17200500
	DC.L	KARTURA+$498,$1F230200
	DC.L	KARTURA+$6C8,$20230100
	DC.L	KARTURA+$8F8,$20230000
	DC.L	KARTURA+$B28,$30270000+9
	DC.L	KARTURA+$ED0,$341E0000+1
	DC.L	KARTURA+$1290,$2F280000+2
	DC.L	KARTURA+$1650,$30270400+9
	DC.L	KARTURA+$19F8,$341E0000+1
	DC.L	KARTURA+$1DB8,$2F280400+2

	DC.L	KARTURA+$2178,$9100000
	DC.L	KARTURA+$21F8,$9100000
	DC.L	KARTURA+$2278,$6120000
	DC.L	KARTURA+$2308,$6110000
	DC.L	KARTURA+$2390,$E0E0000
	DC.L	KARTURA+$2400,$E0E0000
	DC.L	KARTURA+$2470,$E0E0000
	DC.L	KARTURA+$24E0,$E0E0000
	DC.L	KARTURA+$2550,$9100000
	DC.L	KARTURA+$25D0,$9100000
;$3($842)
IMPIQUE2:
	DC.L	PIQUE2+$0,$18300000
	DC.L	PIQUE2+$300,$162A0200
	DC.L	PIQUE2+$5A0,$142A0400
;$3($842)
IMPIQUE3:
	DC.L	PIQUE3+$0,$18300000+$0500
	DC.L	PIQUE3+$300,$162A0000+$0500
	DC.L	PIQUE3+$5A0,$142A0000+$0500
;$E($A0A)
IMFLAMME:
	DC.L	FLAMME+$0,$E020100
	DC.L	FLAMME+$10,$E020100
	DC.L	FLAMME+$20,$E030100
	DC.L	FLAMME+$38,$E040100
	DC.L	FLAMME+$58,$E060100
	DC.L	FLAMME+$88,$10070000
	DC.L	FLAMME+$C0,$E0E0100
	DC.L	FLAMME+$130,$E170100
	DC.L	FLAMME+$1E8,$E1D0100
	DC.L	FLAMME+$2D0,$E230100
	DC.L	FLAMME+$3E8,$F280100
	DC.L	FLAMME+$528,$F2D0100
	DC.L	FLAMME+$690,$F350100
	DC.L	FLAMME+$838,$E3A0100
;$A($16B2)
IMIVOR:
	DC.L	IVOR+$0,$28180000
	DC.L	IVOR+$240,$28170000
	DC.L	IVOR+$468,$29190000
	DC.L	IVOR+$6C0,$28180000
	DC.L	IVOR+$900,$28190100
	DC.L	IVOR+$B58,$27190000
	DC.L	IVOR+$DB0,$28180000
	DC.L	IVOR+$FF0,$28190000
	DC.L	IVOR+$1248,$28170000
	DC.L	IVOR+$1470,$28180000
;$2($1E2)
IMREBORDL5:
IMREBORDLV3:
	DC.L	REBORDL3+$0,$1B0F0000
	DC.L	REBORDL3+$F0,$1B0F0000

IMAGEMOGULVAR:
IMAGEMOGUL1:
	dc.l	MOGCORP+0,$42480000		;1
	dc.l	MOGCORP+$B40,$42480000
	dc.l	MOGCORP+$1680,$42420000
	dc.l	MOGCORP+$20D0,$423A0000
	dc.l	MOGCORP+$29E0,$3C3B0000
	dc.l	MOGCORP+$3140,$45140000
	dc.l	MOGCORP+$3460,$58090000		;7
IMAGEMOGUL2:
	dc.l	MOGBRAS+0,$15370000		;8
	dc.l	MOGBRAS+$370,$150F0000
	dc.l	MOGBRAS+$460,$132A0000
	dc.l	MOGBRAS+$700,$10120000
	dc.l	MOGBRAS+$790,$D130000
	dc.l	MOGBRAS+$828,$1D100000
	dc.l	MOGBRAS+$928,$101F0000
	dc.l	MOGBRAS+$A20,$F270000
	dc.l	MOGBRAS+$B58,$192D0000
	dc.l	MOGBRAS+$E28,$160E0000
	dc.l	MOGBRAS+$F08,$18240000
	dc.l	MOGBRAS+$1148,$1B1F0000
	dc.l	MOGBRAS+$1338,$11270000
	dc.l	MOGBRAS+$15A8,$400D0000		;21
IMAGEMOGUL3:
	dc.l	MOGJAMBE+0,$1F060000		;22
	dc.l	MOGJAMBE+$60,$1F060000
	dc.l	MOGJAMBE+$C0,$1C130000
	dc.l	MOGJAMBE+$1F0,$1C130000
	dc.l	MOGJAMBE+$320,$C120000		;26
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;
; SPRITES NIVEAU 4
;
GALARTOR=0
GLACE=0
PVIPUS=0
TIRGAL1=0
TIRGAL2=$140
VIPUS=0
IMTGALARTOR:
	DC.L	TIRGAL1+$0,$1B0A0000
	DC.L	TIRGAL1+$A0,$1B0A0000
	DC.L	TIRGAL2+$0,$1B0A0000
	DC.L	TIRGAL2+$A0,$1B0A0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$10($5162)
IMGALARTOR:
	DC.L	GALARTOR+$0,$2B310900+$03
	DC.L	GALARTOR+$498,$2B2E0900
	DC.L	GALARTOR+$8E8,$2B350900
	DC.L	GALARTOR+$DE0,$2C2E0900
	DC.L	GALARTOR+$1230,$33300000
	DC.L	GALARTOR+$1830,$33300000
	DC.L	GALARTOR+$1E30,$33300000
	DC.L	GALARTOR+$2430,$2A300900
	DC.L	GALARTOR+$28B0,$2A300200
	DC.L	GALARTOR+$2D30,$33300200
	DC.L	GALARTOR+$3330,$33300200
	DC.L	GALARTOR+$3930,$33300200
	DC.L	GALARTOR+$3F30,$2C2E0000
	DC.L	GALARTOR+$4380,$2B350100
	DC.L	GALARTOR+$4878,$2B2E0100
	DC.L	GALARTOR+$4CC8,$2B310100+$03
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$3($272)
IMPVIPUS:
	DC.L	PVIPUS+$0,$1E0D0000
	DC.L	PVIPUS+$D0,$1F0D0100
	DC.L	PVIPUS+$1A0,$1D0D0300
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$B($2FDA)
IMVIPUS:
	DC.L	VIPUS+$0,$3E330200
	DC.L	VIPUS+$660,$40320000
	DC.L	VIPUS+$CA0,$402B0000
	DC.L	VIPUS+$1200,$3F2A0100
	DC.L	VIPUS+$1740,$392A0700
	DC.L	VIPUS+$1C80,$2F251100+$fb
	DC.L	VIPUS+$1FF8,$3D360300+$03
	DC.L	VIPUS+$26B8,$31250F00
	DC.L	VIPUS+$2B58,$20212000
	DC.L	VIPUS+$2D68,$17142900
	DC.L	VIPUS+$2EA8,$11132900
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$5($1C2)
IMGLACE:
	DC.L	GLACE+$0,$8080000
	DC.L	GLACE+$40,$8080000
	DC.L	GLACE+$80,$8080000
	DC.L	GLACE+$C0,$8080000
	DC.L	GLACE+$100,$1B0C0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
ZORZA=0
DEFENSE=3560
TROMPE=3560+2688
imzorma:
	dc.l	ZORZA+0,$50590000
	DC.L	DEFENSE+$0,$20240000
	DC.L	DEFENSE+$240,$24200000
	DC.L	DEFENSE+$540,$20240500
	DC.L	DEFENSE+$780,$24200100
	DC.L	TROMPE+$0,$8080000
	DC.L	TROMPE+$40,$7070000
	DC.L	TROMPE+$78,$5050000

	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;
; sprites niveau 5
;
BASHTAR=0
COEUR=0+14896	;
CATECO=0
CHENILLE=0
KATYEROW=0

IMBASHTAR:
	DC.L	BASHTAR+$0,$2D230200
	DC.L	BASHTAR+$348,$372C0200
	DC.L	BASHTAR+$8C8,$3E390200
	DC.L	BASHTAR+$FE8,$2D231100
	DC.L	BASHTAR+$1330,$372C0700
	DC.L	BASHTAR+$18B0,$3E390000
	DC.L	BASHTAR+$1FD0,$2D241100
	DC.L	BASHTAR+$2330,$362D0800
	DC.L	BASHTAR+$28D0,$3E390000
	DC.L	BASHTAR+$2FF0,$3B290000
	DC.L	BASHTAR+$3510,$3B290000

	DC.L	COEUR+$0,$19150500
	DC.L	COEUR+$150,$1D190300
	DC.L	COEUR+$2E0,$211C0100
	DC.L	COEUR+$580,$231C0000
	DC.L	COEUR+$820,$201D0300
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMCATECO:
	DC.L	CATECO+$0,$1A080300
	DC.L	CATECO+$80,$1C100100
	DC.L	CATECO+$180,$1F190000
	DC.L	CATECO+$310,$20190000
	DC.L	CATECO+$4A0,$151C0400
	DC.L	CATECO+$660,$181B0300
	DC.L	CATECO+$810,$1B150000
	DC.L	CATECO+$960,$1E1E0000
	DC.L	CATECO+$B40,$181C0400
	DC.L	CATECO+$D00,$181C0400
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMCHENILLE:
	DC.L	CHENILLE+$0,$1A1A0100
	DC.L	CHENILLE+$1A0,$1A1A0000
	DC.L	CHENILLE+$340,$1A1A0000
	DC.L	CHENILLE+$4E0,$1A1A0100
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
IMKATY:
	DC.L	KATYEROW+$0,$C0B0E00
	DC.L	KATYEROW+$58,$B0B0F00
	DC.L	KATYEROW+$B0,$F110E00
	DC.L	KATYEROW+$138,$D180F00
	DC.L	KATYEROW+$1F8,$17270800
	DC.L	KATYEROW+$468,$2D3F0000
	DC.L	KATYEROW+$A50,$F0E0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;
; SPRITES TOUS NIVEAUX
;
IMAGECORPS:
	DC.L	SPR1+$0,$121E0000	;1
	DC.L	SPR1+$168,$E1F0100
	DC.L	SPR1+$222,$10200200
	DC.L	SPR1+$2E2,$131E0000
	DC.L	SPR1+$44A,$D200200
	DC.L	SPR1+$50A,$12200200
	DC.L	SPR1+$68A,$12200600
	DC.L	SPR1+$80A,$D200B00
	DC.L	SPR1+$8CA,$131E0700
	DC.L	SPR1+$A32,$10200800
	DC.L	SPR1+$AF2,$E1F0B00	;11
	DC.L	SPR1+$BAC,$121E0800
	DC.L	SPR1+$D14,$15250000
	DC.L	SPR1+$ED0,$15250000
	DC.L	SPR1+$108C,$11220200+12
	DC.L	SPR1+$1224,$D240400+10
	DC.L	SPR1+$12FC,$10230000+6		;BUG AMIGA <>
	DC.L	SPR1+$13CE,$13230100+13
	DC.L	SPR1+$1572,$D260300+10
	DC.L	SPR1+$1656,$F230100+7
	DC.L	SPR1+$1728,$101F0100+7	;21
	DC.L	SPR1+$17E2,$D1F0200+9
	DC.L	SPR1+$189C,$E1F0200+12
	DC.L	SPR1+$1956,$131F0000+12
	DC.L	SPR1+$1ACA,$E1F0100+9
	DC.L	SPR1+$1B84,$1F180300
	DC.L	SPR1+$1CA4,$1A1A0800
	DC.L	SPR1+$1DDC,$1B170500
	DC.L	SPR1+$1EF0,$1E160300
	DC.L	SPR1+$1FF8,$1B170700
	DC.L	SPR1+$210C,$1B170600	;31
	DC.L	SPR1+$2220,$1E160700
	DC.L	SPR1+$2328,$1B170800
	DC.L	SPR1+$243C,$1A1A0600
	DC.L	SPR1+$2574,$1F180600
	DC.L	SPR1+$2694,$20180300
	DC.L	SPR1+$27B4,$20180500
	DC.L	SPR1+$28D4,$281D0000
	DC.L	SPR1+$2ADE,$2B1E0000
	DC.L	SPR1+$2CFA,$2B1E0000
	DC.L	SPR1+$2F16,$281D0300	;41

	DC.L	SPR42+$0,$17330000
	DC.L	SPR42+$264,$1B280000+$ff00	;...$ff00
	DC.L	SPR42+$444,$17330000+$0200+2
	DC.L	SPR42+$6A8,$1D250000
	DC.L	SPR42+$864,$19140000
	DC.L	SPR42+$954,$1B360000+$0400+2
	DC.L	SPR42+$BDC,$1A360000+$0400+2
	DC.L	SPR42+$E64,$1A360000+$fB00
	DC.L	SPR42+$10EC,$1B360000+$fA00
	DC.L	SPR42+$1374,$1B330000+$0100+2	;51
	DC.L	SPR42+$15D8,$1A330000+$0100+2
	DC.L	SPR42+$183C,$1A330000+$fE00
	DC.L	SPR42+$1AA0,$1B330000+$fD00
	DC.L	SPR42+$1D04,$1A330000+$fE00
	DC.L	SPR42+$1F68,$1A330000+$0100+2
	DC.L	SPR42+$21CC,$1C2E0000+$ec00-3	;MICHEL
	DC.L	SPR42+$23F4,$10310C00+$ec00	;MICHEL
	DC.L	SPR42+$251A,$17301000+$ec00-1	;MICHEL
	DC.L	SPR42+$275A,$1730f7ff		;MICHEL $0200
	DC.L	SPR42+$299A,$10310300	;MICHEL ($0d00);61
	DC.L	SPR42+$2AC0,$1C2E0300-3	;MICHEL ($0d00)
	DC.L	SPR42+$2CE8,$202F0000
	DC.L	SPR42+$2F1C,$202D0000
	DC.L	SPR42+$3138,$202D0000
	DC.L	SPR42+$3354,$202F0000

	DC.L	SPR67+$0,$28140000+$0003	;$43
	DC.L	SPR67+$168,$1D160000+$fb05	;$44
	DC.L	SPR67+$270,$26100000+$f200	;$45
	DC.L	SPR67+$390,$1A150000+$0004	;$46

	DC.L	SPR67+$48C,$1A150000+$0604	;71
	DC.L	SPR67+$588,$26100000+$0800	;$48
	DC.L	SPR67+$6A8,$1D160000+$0805	;$49
	DC.L	SPR67+$7B0,$28140000+$f803	;$4a

	DC.L	SPR75+$0,$161C0300
	DC.L	SPR75+$150,$151C0400
	DC.L	SPR75+$2A0,$191C0000
	DC.L	SPR75+$3F0,$191C0000+8+$FA06
	DC.L	SPR75+$540,$151C0000+8+$FA06
	DC.L	SPR75+$690,$161C0000+8+$FA06
	DC.L	SPR75+$7E0,$1E1B0000	;81
	DC.L	SPR75+$924,$1E1C0000
	DC.L	SPR75+$A74,$1E1B0000
	DC.L	SPR75+$BB8,$1E1B0200+$f20A
	DC.L	SPR75+$CFC,$1E1C0200+$f20A
	DC.L	SPR75+$E4C,$1E1B0200+$f20A
	DC.L	SPR75+$F90,$1C190000
	DC.L	SPR75+$10BC,$1C1A0000
	DC.L	SPR75+$11F4,$201A0000+$FC00
	DC.L	SPR75+$132C,$201A0000
	DC.L	SPR75+$1464,$1C1A0000	;91
	DC.L	SPR75+$159C,$1C190000
	DC.L	SPR93+$0,$E1F0400+$02	;MICHEL
	DC.L	SPR93+$BA,$131F0000+$02	;MICHEL
	DC.L	SPR93+$22E,$E1F0300+$02	;MICHEL
	DC.L	SPR93+$2E8,$D1F0400+$02	;MICHEL
	DC.L	SPR93+$3A2,$101F0200+$02 ;MICHEL
	DC.L	SPR93+$45C,$F230400+$02	;MICHEL
	DC.L	SPR93+$52E,$D260400+$02	;MICHEL
	DC.L	SPR93+$612,$13230000+$02 ;MICHEL
	DC.L	SPR93+$7B6,$10230400+$02 ;MICHEL
	DC.L	SPR93+$888,$D240300+$02	;MICHEL
	DC.L	SPR93+$960,$11220100+$02 ;MICHEL
	DC.L	SPR93+$AF8,$1B280000+$ff00+$ff	;...
	DC.L	MORT+$0,$1B1B0000
	DC.L	MORT+$144,$1B1B0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC

IMAGETETES:
	DC.L	TETES2+$0,$16110000
	DC.L	TETES2+$CC,$15170000
	DC.L	TETES2+$1E0,$16140000
	DC.L	TETES2+$2D0,$16140000
	DC.L	TETES2+$3C0,$15170000
	DC.L	TETES2+$4D4,$16110000
	DC.L	TETES2+$5A0,$14110000
	DC.L	TETES2+$66C,$14110000
	DC.L	TETES2+$738,$17150000
	DC.L	TETES2+$834,$14160000
	DC.L	TETES2+$93C,$12140000
	DC.L	TETES2+$A2C,$12140000
	DC.L	TETES2+$B1C,$14160000
	DC.L	TETES2+$C24,$17150000
	DC.L	TETES2+$D20,$12170000
	DC.L	TETES2+$E34,$11140000
	DC.L	TETES2+$F24,$11140000
	DC.L	TETES2+$1014,$12170000
	DC.L	TETES2+$1128,$14170000
	DC.L	TETES2+$123C,$16130000
	DC.L	TETES2+$1320,$16130000
	DC.L	TETES2+$1404,$14170000
	DC.L	TETES2+$1518,$17150000
	DC.L	TETES2+$1614,$14160000
	DC.L	TETES2+$171C,$12140000
	DC.L	TETES2+$180C,$12140000
	DC.L	TETES2+$18FC,$14160000
	DC.L	TETES2+$1A04,$17150000
	DC.L	TETES2+$1B00,$17120000
	DC.L	TETES2+$1BD8,$17120000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$8
IMTTOKI:
	DC.L	TIRTOKI+$0,$7070000
	DC.L	TIRTOKI+$38,$7070000
	DC.L	TIRTOKI+$70,$B0B0000
	DC.L	TIRTOKI+$C8,$B0B0000
	DC.L	TIRTOKI+$120,$181A0000+6
	DC.L	TIRTOKI+$2C0,$12130400+4
	DC.L	TIRTOKI+$3F0,$E100600+2
	DC.L	TIRTOKI+$470,$8090900
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$10($BFA)
IMICON:
	DC.L	ICONES+$0,$D1D0300
	DC.L	ICONES+$E8,$101D0100
	DC.L	ICONES+$1D0,$101D0000
	DC.L	ICONES+$2B8,$D1D0300
	DC.L	ICONES+$3A0,$F1B0000
	DC.L	ICONES+$478,$101B0000
	DC.L	ICONES+$550,$D1B0000
	DC.L	ICONES+$628,$D1A0000
	DC.L	ICONES+$6F8,$20100000
	DC.L	ICONES+$7F8,$20100000
	DC.L	ICONES+$8F8,$10100000
	DC.L	ICONES+$978,$10100000
	DC.L	ICONES+$9F8,$10100000
	DC.L	ICONES+$A78,$10100000
	DC.L	ICONES+$AF8,$10100000
	DC.L	ICONES+$B78,$10100000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$4
IMPIECE:
	DC.L	PIECE+$0,$F0F0000
	DC.L	PIECE+$78,$D0F0100
	DC.L	PIECE+$F0,$40F0500
	DC.L	PIECE+$168,$D0F0100
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;$4($1E2)
IMBULLE:
	DC.L	BULLES+$0,$E0A0100+$FB
	DC.L	BULLES+$50,$C0E0100+$FF
	DC.L	BULLES+$C0,$E0E0000
	DC.L	BULLES+$130,$110B0000+$FD
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
;
; NON TESTES
;
IMCASQUE:
	DC.L	CASQUE+$0,$18170000
	DC.L	CASQUE+$170,$141D0000
	DC.L	CASQUE+$340,$17180000
	DC.L	CASQUE+$4C0,$1D140000
	DC.L	CASQUE+$600,$19170000
	DC.L	CASQUE+$770,$19170000
	DC.L	CASQUE+$8E0,$1D140000
	DC.L	CASQUE+$A20,$17180000
	DC.L	CASQUE+$BA0,$141D0000
	DC.L	CASQUE+$D70,$18170000
	DC.L	CASQUE+$EE0,$F050000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
	ifeq	1
IMAGENIKE:
	DC.L	NIKE+$0,$12070000
	DC.L	NIKE+$70,$E090000
	DC.L	NIKE+$B8,$11080000
	DC.L	NIKE+$138,$15080000
	DC.L	NIKE+$1B8,$C0A0000
	DC.L	NIKE+$208,$11070000
	DC.L	NIKE+$278,$130D0000
	DC.L	NIKE+$348,$15080000
	DC.L	NIKE+$3C8,$130D0000
	DC.L	NIKE+$498,$130D0000
	DC.L	NIKE+$568,$E080000
	DC.L	NIKE+$5A8,$F050000
	DC.L	NIKE+$5D0,$8050000
	DC.L	NIKE+$5F8,$C060000
	DC.L	NIKE+$628,$15060000
	DC.L	NIKE+$688,$9060000
	DC.L	NIKE+$6B8,$9060000
	DC.L	NIKE+$6E8,$15060000
	DC.L	NIKE+$748,$C060000
	DC.L	NIKE+$778,$8050000
	DC.L	NIKE+$7A0,$F050000
	DC.L	NIKE+$7C8,$E080000
	DC.L	NIKE+$808,$130D0000
	DC.L	NIKE+$8D8,$130D0000
	DC.L	NIKE+$9A8,$15080000
	DC.L	NIKE+$A28,$130D0000
	DC.L	NIKE+$AF8,$11070000
	DC.L	NIKE+$B68,$C0A0000
	DC.L	NIKE+$BB8,$15080000
	DC.L	NIKE+$C38,$11080000
	DC.L	NIKE+$CB8,$E090000
	DC.L	NIKE+$D00,$12070000
	DC.L	NIKE+$D70,$8070000
	DC.L	NIKE+$DA8,$8070000
	DC.L	NIKE+$DE0,$6050000
	DC.L	NIKE+$E08,$6050000
	DC.L	NIKE+$E30,$A090000
	DC.L	NIKE+$E78,$A090000
	DC.L	NIKE+$EC0,$8050000
	DC.L	NIKE+$EE8,$8050000
	DC.L	NIKE+$F10,$F120000
	DC.L	NIKE+$FA0,$A0E0000
	DC.L	NIKE+$1010,$100A0000
	DC.L	NIKE+$1060,$11160000
	DC.L	NIKE+$11C0,$90F0000
	DC.L	NIKE+$1238,$E090000
	DC.L	NIKE+$1280,$E090000
	DC.L	NIKE+$12C8,$90F0000
	DC.L	NIKE+$1340,$11160000
	DC.L	NIKE+$14A0,$100A0000
	DC.L	NIKE+$14F0,$A0E0000
	DC.L	NIKE+$1560,$F120000
	DC.L	NIKE+$15F0,$F070000
	DC.L	NIKE+$1628,$A080000
	DC.L	NIKE+$1668,$B070000
	DC.L	NIKE+$16A0,$150E0000
	DC.L	NIKE+$1780,$C080000
	DC.L	NIKE+$17C0,$C0A0000
	DC.L	NIKE+$1810,$F070000
	DC.L	NIKE+$1848,$A080000
	DC.L	NIKE+$1888,$B070000
	DC.L	NIKE+$18C0,$150E0000
	DC.L	NIKE+$19A0,$C080000
	DC.L	NIKE+$19E0,$C0A0000
	IFEQ	DEBUG
	dc.l	-1,0
	ENDC
	endc

TETES2:	INCBIN	E:\INCLUDES\TETES2.DAT
SPR1:	INCBIN	E:\INCLUDES\SPR1.DAT
SPR42:	INCBIN	E:\INCLUDES\SPR42.DAT
SPR67:	INCBIN	E:\INCLUDES\SPR67.DAT
SPR75:	INCBIN	E:\INCLUDES\SPR75.DAT
SPR93:	INCBIN	E:\INCLUDES\SPR93.DAT
MORT:	INCBIN	E:\INCLUDES\MORT.DAT
CASQUE:	INCBIN	E:\INCLUDES\CASQUE.DAT
	ifeq	1
NIKE:	INCBIN	E:\INCLUDES\NIKE.DAT
	endc
PIECE:	INCBIN	E:\INCLUDES\PIECE.DAT
TIRTOKI:INCBIN	E:\INCLUDES\TIRTOKI.DAT
BULLES:	INCBIN	E:\INCLUDES\BULLES.DAT
ICONES:	INCBIN	E:\INCLUDES\ICONES.DAT


	ifeq	1
blocks:
	IFEQ	NIVEAU-1
	incbin	E:\INCLUDES\LEVEL1.MAP
	ds.w	$3c			;sinon bug rafraichissement !!!
	ENDC
	IFEQ	NIVEAU-2
	incbin	E:\INCLUDES\LEVEL2.MAP
	ds.w	$FF			;sinon bug rafraichissement !!!
	ENDC
	IFEQ	NIVEAU-3
	incbin	E:\INCLUDES\LEVEL3.MAP
	ds.w	$FF			;sinon bug rafraichissement !!!
	ENDC
	IFEQ	NIVEAU-4
	incbin	E:\INCLUDES\LEVEL4.MAP
	ds.w	$FF			;sinon bug rafraichissement !!!
	ENDC
	IFEQ	NIVEAU-5
	incbin	E:\INCLUDES\LEVEL5.MAP
	ds.w	$FF			;sinon bug rafraichissement !!!
	ENDC
	endc
fin:
	ifeq	NIVEAU-1
	incbin	e:\includes\merge1.bin
	endc
	ifeq	NIVEAU-2
	incbin	e:\includes\merge2.bin
	endc
	ifeq	NIVEAU-3
	incbin	e:\includes\merge3.bin
	endc
	ifeq	NIVEAU-4
	incbin	e:\includes\merge4.bin
	endc
	ifeq	NIVEAU-5
	incbin	e:\includes\merge5.bin
	endc

FINDATA:
	section	bss
	ORG	FINDATA
fincode:
	ds.b	16
bitmap:
bitmap0:ds.b	(largeur+16)*(hauteur+16)/2		;d‚calage=0
	ds.b	16
bitmap1:ds.b	(largeur+16)*(hauteur+16)/2		;d‚calage=4
	ds.b	16
bitmap2:ds.b	(largeur+16)*(hauteur+16)/2		;d‚calage=8
	ds.b	16
bitmap3:ds.b	(largeur+16)*(hauteur+16)/2		;d‚calage=12
	ds.b	16
endbitmap:
	ds.b	$FF*16/2	;LARGEUR MAXIMALE EN X
	list
buffer_decalages
