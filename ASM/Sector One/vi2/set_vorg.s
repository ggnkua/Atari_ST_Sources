; Routine de configuration des registres vid‚o du Falcon … partir de quelques
; paramŠtres r‚cup‚r‚e (juste pour comprendre le principe) dans le programme
; CONFIG.PRG de l'utilitaire BLOWUP40

; en entr‚e:
; d0 = nombre pixels/ligne (au format BlowUp, genre 2048 pour 832 pixels)
; d1 = r‚solution graphique horizontale en pixels (genre 832 pour 832 pixels)
; d2 = d‚calage horizontal en pixels BlowUp

; la pile:
; 16 .w r‚solution horizontale virtuelle en pixels
; 14 .w bit	0 : entrelac‚
;		1 : double ligne
;		2 : basse r‚solution
; 12 .w 0 = 25 MHz, 1 = 32 MHz
; 10 .w 0 = 2 couleurs, 1 = 16 couleurs, 2 = 256 couleurs
; 8 .w d‚calage vertical en lignes
; 6 .w r‚solution verticale en lignes
; 4 .w nombre de lignes / vbl

	movem.l	d3-d6,-(sp)	;ici sp se d‚cr‚mente de 16
	subq.w	#4,sp		;+ 4 = 20 -> les donn‚es commencent … $18(sp)
	move.w	$22(sp),d5	;les 3 bits de mode entr./dble ligne/basse r‚s.
	lea	edit,a0		;adr du tableau comprenant toutes les donn‚es
				;(nbre de cycles, r‚sos VDI, d‚calages etc...)
	move.b	$1E(sp),d6	;nombre de couleurs
	ext.w	d6
	tst.w	d6		;2 couleurs ?
	beq.s	coul_2

	subq.w	#1,d6		;16 couleurs ?
	beq.s	coul_16

	subq.w	#1,d6		;256 couleurs ?
	beq.s	coul_256
	bra.s	coul_ok

coul_2
	move.w	d1,d6		;d6 = r‚so x graphique
	ext.l	d6
	divs.w	#$20,d6
	swap	d6
	tst.w	d6		;teste si c'est un multiple de 32
	bne	error		;non -> erreur

	move.w	$24(sp),d6	;r‚solution virtuelle horizontale
	ext.l	d6
	divs.w	#$20,d6
	swap	d6
	tst.w	d6		;re-test de multiple de 32
	bne	error

	move.w	$24(sp),d6
	sub.w	d1,d6		;r‚so virtuelle - r‚so vid‚o
	ext.l	d6		; = nombre de pixels non visibles
	divs.w	#$10,d6		;division par 16 (on passe de pixels en mots)
	move.w	d6,vwrap	;$ff820e

	bra.s	coul_ok
coul_16
	move.w	$24(sp),d6
	sub.w	d1,d6
	ext.l	d6
	divs.w	#4,d6		;passage de pixels en mots
	move.w	d6,vwrap
	bra.s	coul_ok
coul_256
	move.w	$24(sp),d6
	sub.w	d1,d6
	ext.l	d6
	divs.w	#2,d6		;passage de pixels en mots
	move.w	d6,vwrap
coul_ok
	move.w	d0,d6		;nombre de pixels par ligne au format blowup
	ext.l	d6
	divs.w	#4,d6		;/4
	move.w	d6,d0
	move.w	d1,d6		;r‚so horizontale en pixels
	ext.l	d6
	divs.w	#4,d6		;/4 ‚galement
	move.w	d6,d1		;r‚so / 4
	move.w	d2,d6		;d‚calage horizontal
	ext.l	d6
	divs.w	#4,d6
	move.w	d6,d2
	moveq	#4,d6
	and.w	d5,d6		;test du bit basse r‚solution
	beq.s	hi_res
	move.w	d1,d6		;r‚so horizontale / 4
	add.w	d6,d6		;*2 = r‚so / 2
	move.w	d6,d1		;taille en pixels normale r‚solution
hi_res
	moveq	#2,d6
	and.w	d5,d6		;test du bit double ligne
	beq.s	no_dlin
	move.w	$1A(sp),d6
	add.w	d6,d6		;on double la r‚so verticale
	move.w	d6,$1A(sp)
no_dlin
	moveq	#1,d6
	and.w	d5,d6		;test du bit d'entrela‡age
	beq.s	no_intr
	move.w	$1A(sp),d6
	ext.l	d6
	divs.w	#2,d6		;on divise la r‚so verticale par 2
	move.w	d6,$1A(sp)
no_intr
	move.w	d2,2(sp)	;HBE = d‚calage horizontal / 4 (en pixels)
	sub.w	d0,d2		;d‚calage - nombre de pixels / 4
	move.w	d1,d6		;r‚so en pixels / 4
	add.w	d6,d6		;* 2
	add.w	d6,d2		;+ d‚calage - nombre de pixels
	subq.w	#1,d2		;-1
	move.w	d2,(sp)		;donc HBB = HBE - npix/4 + r‚so/4*2 - 1
	cmp.w	d2,d0		;si nombre de pixels par ligne < HBB
	blt.s	error		;alors mode impossible
	move.w	d2,d4		;HBB
	move.w	2(sp),d3	;HBE
	add.w	d0,d3		;+ nombre de pixels / 4
	move.b	$1E(sp),d6	;nombre de couleurs
	ext.w	d6
	tst.w	d6		;2 couleurs
	beq.s	vec_2
	subq.w	#1,d6		;16 couleurs
	beq.s	vec_16
	subq.w	#1,d6		;256 couleurs
	beq.s	vec_256
	bra.s	vec_ok
vec_2
; ici on veut que d2 = ($20 - (xres & $1f)) & $1f
; un peu zarbi la routine, mais on ne lui en veut pas
; c'est g‚n‚r‚ par Pure C (on a vu bien pire)
	moveq	#$20,d2
	moveq	#$1F,d6
	and.w	d1,d6		;$1f & r‚so/4
	sub.w	d6,d2
	cmp.w	#$20,d2		;test si multiple de 32
	bne.s	vec_ok		;si non on continue
	bra.s	vec_256		;si oui on va effacer d2
vec_16
;ici : d2 = ($10 - (xres & $f)) & $f
	moveq	#$10,d2
	moveq	#$F,d6
	and.w	d1,d6
	sub.w	d6,d2
	cmp.w	#$10,d2
	bne.s	vec_ok
vec_256
;ici : d2 = 0
	clr.w	d2
vec_ok
	move.w	d2,d6
	add.w	d6,d6		;d2 * 2
	add.w	d6,d4		;+ HBB
	move.b	$1E(sp),d2	;nombre de couleurs
	ext.w	d2
	tst.w	d2		;2 couleurs
	beq.s	ts_2
	subq.w	#1,d2		;16 couleurs
	beq.s	ts_16
	subq.w	#1,d2		;256 couleurs
	beq.s	ts_256
	bra	ts_ok
ts_2
	sub.w	#$41,d4		;recalage des bordures de l'‚cran
	sub.w	#$69,d3		;
	moveq	#4,d2
	and.w	d5,d2
	beq.s	no_er1		; basse r‚s 2 couleurs impossible
error
	moveq	#-1,d0
	bra	exit
no_er1
	move.w	d1,d2		;r‚so en pixels / 4
	ext.l	d2
	divs.w	#4,d2		;divis‚e par 4 = xres / 16
	move.w	d2,$2C(a0)	;= largeur ‚cran en mots
	move.w	#$400,$2E(a0)	;mode monochrome
	bra.s	ts_ok
ts_16
	sub.w	#$11,d4		;recalage des bordures
	sub.w	#$39,d3		;
	moveq	#4,d2
	and.w	d5,d2
	beq.s	hres16		;si pas mode basse r‚s. on bouge

	sub.w	#$11,d4		;nouveaux d‚calages pour la basse r‚solution
	sub.w	#$19,d3		;
	move.w	d1,d6
	ext.l	d6
	divs.w	#2,d6		;r‚so horizontale / 8 (pour calcul des HBx/HDx)
	move.w	d6,d1
hres16
	move.w	d1,$2C(a0)	;largeur ‚cran en mots
	clr.w	$2E(a0)		;mode graphique 4 ou 16 couleurs
	bra.s	ts_ok
ts_256
	sub.w	#9,d4		;recalage des bordures
	sub.w	#$31,d3		;
	moveq	#4,d2
	and.w	d5,d2
	beq.s	hres256

	sub.w	#9,d4		;nouveaux recalages basse r‚solution
	sub.w	#$11,d3
	move.w	d1,d6
	ext.l	d6
	divs.w	#2,d6		;x res / 2
	move.w	d6,d1
hres256
	move.w	d1,d2
	add.w	d2,d2		;r‚so / 4 * 2
	move.w	d2,$2C(a0)	; = largeur ‚cran en mots
	move.w	#$10,$2E(a0)	;mode 256 couleurs
ts_ok
	cmp.w	d3,d0		;si le futur HDB (=HBE+dec) >= npix / 4
	bge.s	sup_eg		;rien … faire de plus
	move.w	d3,d1
	sub.w	d0,d1
	subq.w	#1,d1
	move.w	d1,d3		;HDB = HBE+decal-1
	bra.s	inf
sup_eg	add.w	#$200,d3	;HDB = HBE+decal+npix/4+$200
inf	moveq	#-1,d1
	add.w	d0,d1
	move.w	d1,$30(a0)	;HHT = nombre de pixels / 4 - 1
	move.w	(sp),$32(a0)	;HBB
	move.w	2(sp),$34(a0)	;HBE
	move.w	d3,$36(a0)	;HDB
	move.w	d4,$38(a0)	;HDE
	moveq	#-$30,d2
	add.w	d0,d2
	move.w	d2,$3A(a0)	;HSS = npix/4 - $30
	move.w	$18(sp),d0	;nombre de lignes/VBL
	add.w	d0,d0
	subq.w	#1,d0
	move.w	d0,$3C(a0)	;VFT = nlin*2-1
	move.w	$1C(sp),d3	;d‚calage vertical
	add.w	$1A(sp),d3	;r‚so Y
	add.w	d3,d3		;*2
	addq.w	#1,d3		;+1
	move.w	d3,$3E(a0)	;VBB = (d‚calage Y + r‚so Y) * 2 + 1
	move.w	$1C(sp),d4
	add.w	d4,d4
	addq.w	#1,d4
	move.w	d4,$40(a0)	;VBE = d‚calage Y * 2 + 1
	move.w	d4,$42(a0)	;VDB = VBE
	move.w	d3,$44(a0)	;VDE = VBB
	move.w	$18(sp),d6
	add.w	d6,d6
	subq.w	#7,d6
	move.w	d6,$46(a0)	;VSS = nlin * 2 - 7 = VFT - 6
	move.b	$20(sp),d1	;fr‚quence Videl
	ext.w	d1
	tst.w	d1
	beq.s	mhz_25
	subq.w	#1,d1
	beq.s	mhz_32
	bra.s	mhz_ok
mhz_25
	move.w	#$186,$48(a0)	;RCO = $186
	bra.s	mhz_ok
mhz_32
	move.w	#$182,$48(a0)	;RCO = $182
mhz_ok
	moveq	#4,d0
	and.w	d5,d0
	beq.s	hres2		;branche si haute r‚s.
	move.w	#4,$4A(a0)	;VCO = 4 (double pixels)
	bra.s	lres2
hres2
	move.w	#8,$4A(a0)
lres2
	moveq	#1,d0
	and.w	d5,d0
	beq.s	nointr2		;branche si entrelac‚
	subq.w	#1,$3C(a0)	;VFT = VFT - 1
	addq.w	#1,$3E(a0)	;VBB = VBB + 1
	subq.w	#1,$40(a0)	;VBE = VBE - 1
	subq.w	#1,$42(a0)	;VDB = VDB - 1
	subq.w	#1,$44(a0)	;VDE = VDE - 1
	ori.w	#2,$4A(a0)	;VCO & 2 (bit interlace)
nointr2
	moveq	#2,d0
	and.w	d5,d0
	beq.s	nodbl2		;branche si double ligne
	ori.w	#1,$4A(a0)	;fixe le bit double ligne … 1 dans VCO
nodbl2	clr.w	d0		;pas d'erreur
exit	addq.w	#4,sp
	movem.l	(sp)+,d3-d6
	rts

