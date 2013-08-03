*-------------------------------------------------------------------------*
*									  *
*	ROTATING SHADES PLAYER 						  *
*									  *
*	- CYBERNETICS 1992 -						  *
*									  *
*-------------------------------------------------------------------------*

	output	e:\code\effects.grx\relaps_f\shade.prg

	opt	o+

graves:		set 	10
aigus:		set 	8
cpu:		set	0
filelen:	set	300
nbetape:	equ	512
nbpal:		set	12
ncur:		set	13

MVOL	EQU $80
FREQ	EQU 2				; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)

	IFEQ FREQ
LEN	EQU 125
INC	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ-1
LEN	EQU 250
INC	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ-2
LEN	EQU 500
INC	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ-3
LEN	EQU 1000
INC	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC

*------------------------------------------------------------------------*
*
*	INITS
*
*------------------------------------------------------------------------*

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	move.b	#2,$ffff820a.w

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	move.l	#ecran2,d0	* Autre ecran
	sub.b	d0,d0
	add.w	#$200,d0
	move.l	d0,ecran2
	
	move.l	ecran2,d2
	lsr.w	#$8,d2
	move.b	d2,$ffff8203.w
	swap	d2
	move.b	d2,$ffff8201.w
	clr.b	$ffff820d.w

	bsr	initsound

	bsr	muson
		
	lea	$ffff8a00.w,a6		* Pointe sur adrs blit	
	move.l	#-1,$28(a6)		* Masque
	move.w	#-1,$2c(a6)

*------------------------------------------------------------------------*
*
*	MAIN LOOP
*
*------------------------------------------------------------------------*

main:
	move.w	#-1,vsync
sync:	tst.w	vsync
	bne.s	sync
	
	addq.w	#1,cpt			* Changement d'objet
	move.w	cpt,d0
	and.w	#512-1,d0
	bne	okobject	

	lea	palettes,a0		* Gestion Palette
	add.w	cptpal,a0
	lea	zero,a2
	moveq.l	#-1,d1
	bsr	light			* (fade)

	clr.w	on			* Anim off

	add.w	#32,cptpal
	cmp.w	#32*nbpal,cptpal
	bne.s	okpal
	clr.w	cptpal
okpal:
	
	bsr	initcurve		* Init courbe

	clr.w	cptfile			* Reset compteur file
	lea	file,a1			* Renit file
	move.w	#filelen-1,d0
fill:	move.l	#masque1,(a1)+
	move.l	#ecran2+32512,(a1)+
	clr.w	(a1)+
	dbra.w	d0,fill

	move.l	ecran2,a1		* Efface ecran
	move.w	#7999,d0
eff:	clr.l	(a1)+
	dbra.w	d0,eff

	lea	palettes,a0		* Fixe nouvelle palette
	add.w	cptpal,a0
	lea	$ffff8240.w,a1
	moveq.l	#7,d0	
copypl:	move.l	(a0)+,(a1)+
	dbra.w	d0,copypl

	clr.l	rotcpt			* Reset compteur rotation

	move.w	object,d0		* Gestion numero object
	lea	nbetap,a1
	add.w	d0,a1
	move.l	(a1),actetap
	lea	masque,a1
	add.w	d0,a1
	move.l	(a1),actmasque
	addq.w	#4,object
	cmp.w	#16,object
	bne.s	okobject
	clr.w	object
okobject:
	
	move.w	#-1,on			* Anim on
	cmp.b	#57,tch
	bne	main


*------------------------------------------------------------------------*
*
*	REINITS
*
*------------------------------------------------------------------------*

fin:	clr.w	on
	lea	$ffff8240.w,a0
	lea	palettes,a1
	moveq.l	#7,d0
copypl2:move.l	(a0)+,(a1)+
	dbra.w	d0,copypl2
	
	lea	palettes,a0
	lea	zero,a2
	moveq.l	#-1,d1
	bsr	light
	
	bsr	fadesound
	
	bsr	musoff

	move.w	#$777,$ffff8240.w
	move.b	#0,$ffff820a.w

	clr.w	-(sp)
	trap	#1			; Terminate

tch:	dc.w	0

;---------------------------------------------------- Interrupts on/off --
*
*	ZIK ON/OFF
*
*------------------------------------------------------------------------*
muson	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move.w	#$2700,sr
	move.b	$fffffa07.w,oldmfp1
	move.b	$fffffa09.w,oldmfp2
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l	$70.w,oldvbl
	move.l	#stereo,$70.w
	move.b	#FREQ+1,$FFFF8921.w	; Frequency
	lea	$FFFF8907.w,a0
	move.l	#sample1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	move.l	#sample1+LEN*4,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	move.b	#1,$FFFF8901.w		; Start DMA
	move	#$2300,sr

	rts

musoff:
	move	#$2700,sr
	move.l	oldvbl(pc),$70.w	; Restore everything
	move.b	oldmfp1,$fffffa07.w
	move.b	oldmfp2,$fffffa09.w
	clr.b	$FFFF8901.w		; Stop DMA
	move	#$2300,sr
	rts

oldvbl:		DC.L 0
oldmfp1:	DC.w 0
oldmfp2:	DC.w 0

;--------------------------------------------------------- Volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab	DS.B 65*256
vtabend

;------------------------------------------------------ Increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab:	DS.L $30
stab:	DS.L $03A0-$30
*-------------------------------------*
initsound:
	move.w		#$7ff,$ffff8924.w		* Init microwire
dmwr:	cmp.w		#$7ff,$ffff8924.w
	bne.s		dmwr
	move.w		#%10011101000,d0		* Volume max
	bsr		microwrite
	move.w		#%10010000000+aigus,d0		* Aigus 
	bsr		microwrite
	move.w		#%10001000000+graves,d0		* Graves
	bsr		microwrite
	rts

microwrite:
	move.w		d0,$ffff8922.w
	moveq.l		#127,d0
waitdma:dbra.w		d0,waitdma
	rts


fadesound:	
	moveq.l		#20,d0
temp2:	move.w		#$4c0,d2
	or.w		d0,d2
	add.w		#20,d2
	move.w		d2,$ffff8922.w
	move.w		#3000,d1
temp1:	move.l		4(sp),4(sp)
	dbra.w		d1,temp1
	dbra.w		d0,temp2
	rts
*----------------------------- FADE ROUTINE ------------------------------*
*	A0 = adr palette depart						  *
* 	A2 = adr palette arrivee					  *
* 	D1 = masque							  *
*-------------------------------------------------------------------------*
light:
	move.w		d1,a5			* Sauve le mot de test couleurs
	clr.w		rd4			* Compteur de boucles: nbre d'etapes
looplight:					* Boucle principale
	move.l		a0,a1			* Adresse palette
	move.l		a2,a3			* Adresse palette
	move.w		rd4(pc),d2		* Compteur boucle (‚tape fade)
	lsl.w		#8,d2			*
 	lsr.w		#4,d2			* Etape * 256 / nb etapes
	lea		$ffff8240.w,a4		* Adr palette
	move.w		a5,d1
	move.w		#15,rd6
	
light_colors:
	move.w  	(a1)+,d4		* Couleur de depart
	move.w		(a3)+,d5 		* Couleur d'arrivee
	
	add.w		d1,d1			* Test si il faut modifier
	bcc.s		nocol			* ce registre de couleur
	
	moveq.l		#0,d3			* Registre pour couleur finale
	moveq.l		#0,d0			* Indice boucle: 0-4-8 (decalage composante r-v-b)

compo:	move.w		d4,d7			* Color dep
	bsr		rol4bits		*  
	move.w		d7,d6			* => valeur composante de 0 … 15
	move.w		d5,d7			* Color arr
	bsr		rol4bits		* => valeur composante de 0 … 15
	sub.w		d6,d7			* delta composante: Dc
	muls.w		d2,d7			* Dc * 256 / nb ‚tape 
	asr.w		#8,d7			* Dc / 256
	add.w		d6,d7			* Dc + color dep 
	bsr		ror4bits		* composante de 0 … 15 => ste color 
	lsl.w		d0,d7
	or.w		d7,d3			* D3 : resultat couleur

	lsr.w		#4,d4			* Decalage pour composante
	lsr.w		#4,d5
	
	addq.w		#4,d0			* Boucle composante
	cmp.w		#12,d0
	bne.s		compo
	
	move.w		d3,(a4)			* Fixe couleur
nocol:	addq.w		#2,a4
	
	subq.w		#1,rd6			* Boucle couleur
	bge.s 		light_colors

	move.w	#2,d5
temp:	move.w	#-1,vsync
sync2:	tst.w	vsync
	bne.s	sync2
	dbra.w	d5,temp

	addq.w		#1,rd4			* Boucle etape
	cmp.w		#16,rd4
	bne		looplight

	rts

rd4:	dc.w	0
rd6:	dc.w	0


rol4bits:
	add.w		d7,d7		* D7: couleur shift‚e (selon Composante voulue)
	btst.l		#4,d7
	beq.s		nobit1_1
	or.w		#1,d7	
nobit1_1:
	and.w		#15,d7		* D7: compsante de 0 … 15
	rts

	
ror4bits:
	ror.w		#1,d7
	bcc.s		nobit1_2
	or.w		#8,d7
nobit1_2:
	and.w		#15,d7
	rts

*------------------------------------------------------------------------*
*
*	CALCUL COURBES
*
*------------------------------------------------------------------------*

initcurve:
	lea	curves,a0
	add.w	nbcurve,a0
	add.w	#30,nbcurve
	cmp.w	#30*ncur,nbcurve
	bne.s	okcur
	clr.w	nbcurve
okcur:	
	lea	curve,a1
	move.w	#30/2-1,d0
copycr:	move.w	(a0)+,(a1)+
	dbra.w	d0,copycr

	rts

vblcalc:
	tst.w	curve
	beq	nolisa
	
	lea	cosinus,a0			
	move.w	pcos,d0		* angle actuel 
	adda.w	d0,a0		* add. angle actuel
	add.w	pas,d0		* pas de l'angle
	andi.w	#nbetape*2-1,d0
	move.w	d0,pcos

	move.w	ray,d0		* calcule du 
	muls	(a0),d0		* cosinus
	add.l	d0,d0
	add.l	d0,d0
	sub.w	d0,d0
	swap	d0
	add.w	centx,d0	* ajoute coordonne en x du centre
	move.w	d0,x		* coordonne en x

	lea	sinus,a0
	move.w	psin,d0		* angle actuel 
	adda.w	d0,a0		* add. angle actuel
	add.w	pas2,d0		* pas de l'angle
	andi.w	#nbetape*2-1,d0
	move.w	d0,psin

	move.w	ray2,d0		* calcule du sinus
	muls	(a0),d0
	add.l	d0,d0
	add.l	d0,d0
	sub.w	d0,d0
	swap	d0
	add.w	centy,d0	* ajout de la coordonnes en y 
	move.w	d0,y		* coord. en y
	
	rts
	
nolisa:
	move.w	icx,d0			
	add.w	d0,x
	move.w	x,d0
	cmp.w	#4,d0
	bge.s	ok1
	neg.w	icx
ok1:	cmp.w	#316-48,d0
	ble.s	ok2
	neg.w	icx
ok2:	
	move.w	icy,d0
	add.w	d0,y
	move.w	y,d0
	cmp.w	#4,d0
	bge.s	ok3
	neg.w	icy
ok3:	cmp.w	#196-48,d0
	ble.s	ok4
	neg.w	icy
ok4:	

	rts

*------------------------------------------------------------------------*
*
*	SHADED DRAWER
*
*------------------------------------------------------------------------*

firstpart:
	lea	file,a3
	add.w	cptfile,a3

	bsr	vblcalc

	move.w	x,d0			* Coordonnees d'affichage
	move.w	d0,d1
	and.w	#15,d1
	move.b	d1,deca
	and.w	#$fff0,d0
	lsr.w	#1,d0
	move.w	d0,off

	move.w	y,d0
	move.w	d0,d1
	lsl.w	#7,d1
	lsl.w	#5,d0
	add.w	d1,d0
	add.w	d0,off
	
	move.l	actmasque,a1		* Deplacement,espacement & shiftage
	add.l	rotcpt,a1		* du masque
	moveq.l	#0,d0
	move.w	rotsnap,d0
	add.l	d0,rotcpt
	move.l	rotcpt,d0
	cmp.l	actetap,d0
	blt.s	okrot
	clr.l	rotcpt
okrot:
	move.l	a1,(a3)+

	lea	work,a2	
	move.l	a2,$32(a6)		* Adr dest
	move.b	#0,$3a(a6)
	move.l	#$30001,$36(a6)
	move.b	#%11000000,$3c(a6)	* Go

	move.l	a2,$32(a6)		* Adr dest
	move.l	#$20002,$20(a6)		* Inc x source	& inc y source
	move.l	#$80008,$2e(a6)		* Inc x dest & inc y dest
	move.l	a1,$24(a6)		* Adr source
	move.l	#48*4*65536+1,$36(a6)	* Taille vert & hori
	move.w	#$203,$3a(a6)		* Combi log & mode hog
	move.b	deca,$3d(a6)		* Decalage
	move.b	#%11000000,$3c(a6)	* Go
	
	move.l	ecran2,a1
	add.w	off,a1
	move.l	a1,(a3)+
	move.b	deca,(a3)+

*----------------------------------------------------------------------*
hauteur:	equ	48
largeur:	equ	4
*---------------------------recopie-----------------------------------*
	
	clr.b	$3d(a6)			* Decalage a zero
	move.l	#8*65536+168-2*4*largeur,$20(a6) * incs source
	move.l	#$80008,$2e(a6)		* x inc dest

var:	set     0
	rept	3
	move.l	a1,$24(a6)		* source
	add.l	#var,$24(a6)
var:	set 	var+2
	move.l	a2,$32(a6)		* destination
	add.l	#var,$32(a6)
	move.l	#largeur*65536+hauteur,$36(a6)  * tailles
	move.b	#3,$3b(a6)		* replace
	move.b	#$c0,$3c(a6)		* blitter on
	endr
*------------------------------------and----------------------------------*
	 	
	move.l	#$20004,$20(a6)		* incs source
	move.l	a2,$24(a6)		* source=masque
	move.l	#$20004,$2e(a6)		* incs dest
	move.l	a2,$32(a6)
	addq.l	#2,$32(a6)		* destination
	move.l	#$30000+largeur*hauteur,$36(a6)	* tailles 
	move.b	#1,$3b(a6)		* and
	move.b	#$c0,$3c(a6)		* blitter on

*-------------------------------xor---------------------------------------*
	move.l	#$20002,$20(a6)		* x inc source
	move.l	a2,$24(a6)		* source
	move.l	#$20000+162-2*4*largeur,$2e(a6) * incs dest
	move.l	a1,$32(a6)		* destination
	move.l	#largeur*4*65536+hauteur,$36(a6) * tailles 
	move.b	#6,$3b(a6)		* xor
	move.b	#$c0,$3c(a6)		* blitter on

	rts

*------------------------------------------------------------------------*
*
*	SHADED ERASER
*
*------------------------------------------------------------------------*

secondpart:
	
	lea	file,a3
	move.w	cptfile,d0
	add.w	#10,d0
	cmp.w	flen,d0
	blt.s	inf
	sub.w	flen,d0
inf:	add.w	d0,a3

	add.w	#10,cptfile
	move.w	flen,d0
	cmp.w	cptfile,d0
	bne.s	okfile
	clr.w	cptfile
okfile:
	lea	work,a2	
	move.l	a2,$32(a6)		* Adr dest
	move.b	#0,$3a(a6)
	move.l	#$30001,$36(a6)
	move.b	#%11000000,$3c(a6)	* Go

	move.l	a2,$32(a6)		* Adr dest
	move.l	#$20002,$20(a6)		* Inc x source	& inc y source
	move.l	#$80008,$2e(a6)		* Inc x dest & inc y dest
	move.l	(a3),$24(a6)		* Adr source
	move.l	#48*4*65536+1,$36(a6)	* Taille vert & hori
	move.w	#$203,$3a(a6)		* Combi log & mode hog
	move.b	8(a3),$3d(a6)		* Decalage
	move.b	#%11000000,$3c(a6)	* Go
	
	move.l	4(a3),a1

*---------------------------recopie-----------------------------------*
	
	clr.b	$3d(a6)			* Decalage a zero
	move.l	#8*65536+168-2*4*largeur,$20(a6) * incs source
	move.l	#$80008,$2e(a6)		* x inc dest

var:	set     0
	rept	3
	move.l	a1,$24(a6)		* source
	add.l	#var,$24(a6)
var:	set 	var+2
	move.l	a2,$32(a6)		* destination
	add.l	#var,$32(a6)
	move.l	#largeur*65536+hauteur,$36(a6)  * tailles
	move.b	#3,$3b(a6)		* replace
	move.b	#$c0,$3c(a6)		* blitter on
	endr
*------------------------------------and----------------------------------*
	 	
	move.l	#$20004,$20(a6)		* incs source
	move.l	a2,$24(a6)		* source=masque
	move.l	#$20004,$2e(a6)		* incs dest
	move.l	a2,$32(a6)
	addq.l	#2,$32(a6)		* destination
	move.l	#$30000+largeur*hauteur,$36(a6)	* tailles 
	move.b	#2,$3b(a6)		* and not destination
	move.b	#$c0,$3c(a6)		* blitter on

*-------------------------------xor---------------------------------------*
	move.l	#$20002,$20(a6)		* x inc source
	move.l	a2,$24(a6)		* source
	move.l	#$20000+162-2*4*largeur,$2e(a6) * incs dest
	move.l	a1,$32(a6)		* destination
	move.l	#largeur*4*65536+hauteur,$36(a6) * tailles 
	move.b	#6,$3b(a6)		* xor
	move.b	#$c0,$3c(a6)		* blitter on
*-----------
	
	rts
	
;-------------------------------------------------------- DMA interrupt --
*
*	SOUNDTRACKER ROUT
*
*------------------------------------------------------------------------*

stereo:	
	move.b	#1,$FFFF8901.w		; Start DMA
	clr.w	vsync
	
	move.b	$fffffc02.w,tch

	ifne	cpu
	move.w	#$30,$ffff8240.w
	endc
	
	movem.l	d0-a6,-(sp)
	
	tst.w	on
	beq.s	noanim1
	jsr	firstpart
noanim1:

	ifne	cpu
	move.w	#$3,$ffff8240.w
	endc

	move.l	a6,-(sp)

	move.l	samp1(pc),d0
	move.l	samp2(pc),samp1
	move.l	d0,samp2

	lea	$FFFF8907.w,a0

	move.l	samp1(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	
	move.l	samp1,d0
	add.l	#LEN*4,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	
	jsr	music

	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v1:	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz3lc(pc),a1

	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5

	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud3vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6

	bsr	calc			* <----------------

	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc

	lea	itab,a5
	lea	vtab,a3
	moveq	#0,d0
	moveq	#0,d4

v2	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	asl.w	#8,d7 
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	addq.w	#1,a6
	
	bsr	calc		* <--------------

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	move.l	(sp)+,a6

	ifne	cpu
	move.w	#$300,$ffff8240.w
	endc

	tst.w	on
	beq.s	noanim2
	jsr	secondpart
noanim2:
	movem.l	(sp)+,d0-a6

	ifne	cpu
	move.w	#0,$ffff8240.w
	endc

	rte

calc:	moveq.l	#0,d3
	move.w	#$2700,sr
	exg.l	sp,a6
	
	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(sp)+
	move.b	d7,(sp)+
	ENDR

	exg.l	a6,sp
	move.w	#$2500,sr

	rts

;-------------------------------------------- Hardware-registers & data --
wiz1lc	DC.L sample1
wiz1len	DC.L 0
wiz1rpt	DC.W 0
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1
wiz2len	DC.L 0
wiz2rpt	DC.W 0
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1
wiz3len	DC.L 0
wiz3rpt	DC.W 0
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1
wiz4len	DC.L 0
wiz4rpt	DC.W 0
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0

dummy	DC.L 0

samp1	DC.L sample1
samp2	DC.L sample2

sample1	DS.W 		LEN*2
sample2	DS.W	        LEN*2

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	data,a1			; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320*5,d1		; Must be > 320
	blt.s	toosmal

	move.w	#320*5/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	data,a0
	lea	$03B8(a0),a1

	moveq.l	#$7F,d0
	moveq.l	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra.w	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq.l	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra.w	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	lea	data,a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	data+$043C,a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	data+$03B6,d1
	bne.s	endr
	move.b	data+$03B7,songpos
endr:	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop:	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3

	Section	data

vsync:		dc.w	0
on:		dc.w	0
cptfile:	dc.w	0

off:		dc.w	0
deca:		dc.w	0			* OBJET

cpt:		dc.w	-1
object:		dc.w	0
actetap:	dc.l	120*48*8
actmasque:	dc.l	masque1
rotcpt:		dc.l	0
nbcurve:	dc.w	0
cptpal:		dc.w	-32

curve:		dc.w	1
x:		dc.w	160			* DEPLACEMENT	
y:		dc.w	100
icx:		dc.w	1
icy:		dc.w	1	
flen:		dc.w	200*10
rotsnap:	dc.w	48*8*8
centx:		dc.w	160
centy:		dc.w	100
pas:		dc.w	2
pas2:		dc.w	2
ray:	 	dc.w	100
ray2:	 	dc.w	50
pcos:		dc.w	0
psin:	 	dc.w	0

curves:		include	curves.s

zero:		rept	8
		dc.l	0
		endr
palettes:	incbin	e:\code\effects.grx\shade\pal1.pal
		incbin	e:\code\effects.grx\shade\pal2.pal
		incbin	e:\code\effects.grx\shade\pal11.pal
		incbin	e:\code\effects.grx\shade\pal3.pal
		incbin	e:\code\effects.grx\shade\pal4.pal
		incbin	e:\code\effects.grx\shade\pal5.pal
		incbin	e:\code\effects.grx\shade\pal6.pal
		incbin	e:\code\effects.grx\shade\pal7.pal
		incbin	e:\code\effects.grx\shade\pal8.pal
		incbin	e:\code\effects.grx\shade\pal9.pal
		incbin	e:\code\effects.grx\shade\pal10.pal
		incbin	e:\code\effects.grx\shade\pal12.pal

nbetap:		dc.l	120*48*8
		dc.l	90*48*8
		dc.l	72*48*8		
		dc.l	60*48*8

masque:		dc.l	masque1
		dc.l	masque2
		dc.l	masque3
		dc.l	masque4

cosinus:	incbin	youpi1.kra
sinus:		incbin	youpi2.kra

masque1:	incbin	rot3.dat
masque2:	incbin	rot4.dat
masque3:	incbin	rot5.dat
masque4:	incbin	rot6.dat

file:		rept	filelen
		dc.l	masque1
		dc.l	ecran2+32256
		dc.w	0
		endr

data:	INCBIN d:\sndtrack\modules\tcn\delos\delos_0c.MOD

	Section 	bss

	DS.b	86000			; Workspace
workspc	DS.W	1

work:		ds.b	32*48
ecran2:		ds.b	32256
