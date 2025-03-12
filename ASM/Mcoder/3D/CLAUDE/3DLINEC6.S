	opt	o+
	ifeq	1
attention bricolage de derniŠre minute

il est 23:30 (i'm tired)


L'affichage des "sous-polygone"
d'une facette n'est pas g‚r‚ et
diminuerait le temps par 2 (surtout
pour la disquette)

Par contre l'algo de test des faces
cach‚es ne prend que 2 muls


Ce source est bouillon mais je
n'ai pas le temps le modifier
pour l'instant.

	endc

; ALGORITHME 3D PAR FACETTES + CLIPPING 
;
;	sys_scr1	: ‚cran visualis‚
;	sys_scr2	: ‚cran pret a etre
;			  visualis‚
;	sys_scr3

CPUAFF		equ	0
CALAFF		equ	0
PRJAFF		equ	0

VBL_MEMO	equ	$452		;adresse de memorisation compteur VBL
VBL_COUNT	equ	$466		;adresse du compteur VBL



	SECTION TEXT

***********************************************************
*		programme principal :			  *
*		- basse resolution			  *
*		- sauvegarde de la palette		  *
*		- installation nouvelle VBL		  *
***********************************************************
start:

	move.l	4(a7),a3		base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1				shrink memory
	lea	12(sp),sp
	*--------------- mode superviseur -----------
	clr.l	-(SP)			
	move.w	#$20,-(SP)
	trap	#1
	addq.l	#6,SP
	move.l	D0,userstack
	*-------------- sauve resolution ------------
	move.w	#4,-(SP)		
	trap	#14				
	addq.l	#2,SP
	move.w	D0,sys_rez
	*-------------- passage basse resolution ----
	clr.w	-(SP)		
    	move.l	#-1,-(SP)	
    	move.l	#-1,-(SP)
    	move.w	#5,-(SP)
    	trap	#14
    	lea	12(SP),SP
	*------------- adresse de l'ecran -----------    
	move.w	#3,-(SP)		
	trap	#14				
	addq.l	#2,SP
	move.l	D0,sys_screen	sauvegarde
	
	*------------- adresses ecran 1,2,3 ---------
		
	move.l	D0,sys_scr1		=adresse ecran visualis‚
	move.l	#screen2,D0		adresse de l'ecran2 dans
	add.l	#255,D0			le buffer 2
	clr.b   D0		
	move.l	D0,sys_scr2
	add.l	#32000,D0
	move.l	D0,sys_scr3

	bsr	save_pal		sauve la palette courante

	move.l	$70.w,sys_vbl		sauve adresse IT VBL
	move.l  #new_vbl,$70.w		nouvelle vbl	

	jsr	main(PC)

	move.l	sys_vbl,$70.w		restauration vbl systeme

	bsr	rest_pal		restore la palette courante

	move.w	sys_rez,-(SP)		resolution d'origine
    	move.l	sys_screen,-(SP)	et ecran d'origine
    	move.l	sys_screen,-(SP)
    	move.w	#5,-(SP)
    	trap	#14
    	lea	12(SP),SP

	move.l	userstack,-(SP)		mode utilisateur
	move.w	#$20,-(SP)
	trap	#1
	addq.l	#6,SP
	
bye:
	clr.w	-(SP)			fin du programme
	move.w	#$4C,-(SP)	
	trap	#1			

COTES	EQU	5
CARRE	DS.L	COTES
;
; LISTE DES AMELIORATIONS POSSIBLES :
;
; - QUAND LES 2 Y SONT HORS DE L'ECRAN, INUTILE DE CALCULER QUOI
;      QUE CE SOIT
; - AMELIORER PLOT SUIVANT LE CAS
; - TRAVAILLER SUR L'AFFICHAGE
;
; algorithme de remplissage de polygones convexes
;
; version 1.0
;  le 06/04/89 par M‚m‚ l'Optimiseur Fou
;   (incompr‚hensible n'est-ce pas ??)
;
; entr‚e :
;
; avant d'utiliser polyfill,
;   il faut faire bsr initpoly une fois au d‚but du programme !!!
;
; A0=pointe sur les coordonn‚es des segments
; D0.w=nb de points
; D0.h=couleur du polygone
;
; liste des  registres utilis‚s !!!
;
ylow	equ	0
yhigh	equ	199

coords		equr	a0
ptr1		equr	a1
ptr2		equr	a2
maxy		equr	a3
miny		equr	a4
bufcor		equr	a5

ecran		equr	a6
raster		equr	a4
masques		equr	a5
plan1		equr	a2

nbpoints	equr	d0	;sert pour comptage de segments
x0		equr	d1
y0		equr	d2	;nb points … afficher
x1		equr	d3
y1		equr	d4
residu		equr	d5	;r‚sidu pour algorithme de Bresenham
pasx		equr	d6	;pas en x quand pente<90
const		equr	d7

coef1		equr	d5
coef2		equr	d6
borne		equr	d7

scratch		equr	d5
plan2		equr	d6
bit4		equr	d0
;
; routine de stockage de la coordonn‚e x0,y0/2
;
plot	macro
	move	(ptr2),coordy2-coordy1(ptr2)
	move	x0,(ptr2)+
;	cmp	(ptr2)+,const
;	beq.s	\@1		;si bit 15=1 -> pas de coord m‚moris‚e
;	move	x0,coordy2-coordy1-2(ptr2)
;	bra.s	\@2
;\@1	move	x0,-2(ptr2)	;m‚morise le premier point
;\@2
	endm

plot2	macro
	move	-(ptr2),coordy2-coordy1(ptr2)
	move	x0,(ptr2)
;	cmp	-(ptr2),const
;	beq.s	\@1		;si bit 15=1 -> pas de coord m‚moris‚e
;	move	x0,coordy2-coordy1(ptr2)
;	bra.s	\@2
;\@1	move	x0,(ptr2)	;m‚morise le premier point
;\@2
	endm

initpoly
	moveq	#200/2-1,d0
	move.l	#$80008000,d1
	lea	coordy1(PC),a0	;efface coordy1 et coordy2
clrpoly	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,clrpoly
	rts
onepoint
	move	(coords)+,x0
	cmp	#320,x0
	bhs.s	nopoint
	move	(coords),y0
	cmp	#200,y0
	bhs.s	nopoint

	add	y0,y0
	add	y0,y0
	add	y0,ecran
	asl	#5,y0
	add	y0,ecran

	move	x0,scratch
	and	#$0F,x0
	eor	x0,scratch
	lsr	#1,scratch
	add	scratch,ecran

	ADD	x0,x0
	ADD	x0,x0
	lea	masks(PC),masques
	MOVE.L	mskpoint-masks(masques,x0.w),x0

;	eor	bit4,x0
;	moveq	#-1,scratch
;	bclr	x0,scratch
;	move	scratch,x0
;	swap	x0
;	move	scratch,x0

	and.l	x0,(ecran)
	and.l	x0,4(ecran)
	not.l	x0
	move.l	plan1,scratch
	and.l	x0,scratch
	or.l	scratch,(ecran)+
	and.l	plan2,x0
	or.l	x0,(ecran)+
nopoint
finpoly
nothing
	rts

polyfill
	tst	nbpoints
	beq.s	nothing		;si aucun point … afficher -> on sort

	subq	#1,nbpoints	;-1 pour dbra
	beq.s	onepoint	;si 0 -> un seul point … afficher

	move	#-1,maxy	;on fixe le Ymax et le Ymin
	move	#199,miny	; en dehors de l'‚cran
	move	#$8000,const
	lea	coordy1(pc),ptr1

	move.l	coords,bufcor
	subq	#1,nbpoints
	beq.s	oneseg
;
; premiŠre phase : calcul des coordonn‚es
;
boucle
	movem	(coords),x0/y0/x1/y1	;on lit les deux premiers points
	bsr	drawlin
oneseg
	addq	#4,coords		;saute le premier point
	dbra	nbpoints,boucle
;
; traitement du dernier segment
;
	move	(coords)+,x0
	move	(coords),y0
	move	(bufcor)+,x1
	move	(bufcor),y1
	bsr	drawlin
;
; deuxiŠme phase : affichage des lignes et effacement du buffer
;
	move	maxy,y0
	bmi.s	finpoly

	sub	miny,y0
	bmi.s	finpoly

	swap	nbpoints
	lsr	#1,nbpoints
	subx.l	x0,d0
	lsr	#1,nbpoints
	subx	x0,x0
	move.l	x0,plan1
	lsr	#1,nbpoints
	subx.l	plan2,plan2
	lsr	#1,nbpoints
	subx	plan2,plan2

	move	miny,nbpoints
	add	nbpoints,nbpoints
	add	nbpoints,ptr1
	asl	#4,nbpoints		;(y*32)
	add	nbpoints,ecran
	add	nbpoints,nbpoints	;+(y*128)
	add	nbpoints,nbpoints
	add	nbpoints,ecran		;=y*160
	moveq	#$0F,bit4		;ici bit4=$000F (ruse)
	lea	masks(pc),masques
nxtlin
	move	(ptr1),x0
	move	const,(ptr1)+		;efface les flags
	move	coordy2-coordy1-2(ptr1),x1
	cmp	const,x1
	beq	hplot
	move	const,coordy2-coordy1-2(ptr1)
;
; HLINE
;
	moveq	#0,scratch
	cmp	#320,x0
	blo.s	x0320
	slt	x0
	ext	x0
	and	#319,x0
	moveq	#1,scratch
x0320
	cmp	#320,x1
	blo.s	x1320
	slt	x1
	ext	x1
	and	#319,x1
	tst	scratch
	beq.s	x1320
	cmp	x0,x1
	beq	nohline
x1320
	sub	x0,x1
	bge.s	paswap
	add	x1,x0
	neg	x1
paswap
;
; x1 devient … partir de maintenant deltax
;
	move	x0,scratch
	and	bit4,x0
	eor	x0,scratch
	lsr	#1,scratch
	move.l	ecran,raster
	add	scratch,raster
	add	x0,x1
	add	x0,x0
	add	x0,x0
	move.l	mskgau-masks(masques,x0.w),x0
	cmp	bit4,x1
	bls.s	onelong
	and.l	x0,(raster)
	and.l	x0,4(raster)
	not.l	x0
	move.l	plan1,scratch
	and.l	x0,scratch
	or.l	scratch,(raster)+
	and.l	plan2,x0
	or.l	x0,(raster)+
	move	x1,x0
	and	bit4,x1
	eor	x1,x0
	lsr	#2,x0
	neg	x0
	jmp	fastfill+20*4(pc,x0.w)
fastfill
	rept	19
	move.l	plan1,(raster)+
	move.l	plan2,(raster)+
	endr
	moveq	#0,x0
onelong	add	x1,x1
	add	x1,x1
	or.l	mskdro-masks(masques,x1.W),x0
	and.l	x0,(raster)
	and.l	x0,4(raster)
	not.l	x0
	move.l	plan1,scratch
	and.l	x0,scratch
	or.l	scratch,(raster)+
	and.l	plan2,x0
	or.l	x0,(raster)+
nohline
	lea	160(ecran),ecran
	dbra	y0,nxtlin
	rts
hplot
	cmp	#320,x0
	bhs.s	point0

	move	x0,scratch
	and	bit4,x0
	eor	x0,scratch
	lsr	#1,scratch
	move.l	ecran,raster
	add	scratch,raster

	ADD	x0,x0
	ADD	x0,x0
	MOVE.L	mskpoint-masks(masques,x0.w),x0

;	eor	bit4,x0
;	moveq	#-1,scratch
;	bclr	x0,scratch
;	move	scratch,x0
;	swap	x0
;	move	scratch,x0

	and.l	x0,(raster)
	and.l	x0,4(raster)
	not.l	x0
	move.l	plan1,scratch
	and.l	x0,scratch
	or.l	scratch,(raster)+
	and.l	plan2,x0
	or.l	x0,(raster)+

point0
	lea	160(ecran),ecran
	dbra	y0,nxtlin
	rts
;
; cas deltax n‚gatif et deltax>deltay
;
; donc deltax<>0
;
cas2
	ext.l	x1		;efface les bits 16 … 31 (bit 15=0)
	divu	y1,x1
	move	x1,pasx		;pasx=int(deltay/deltax)
	swap	x1		;x1=reste de la division
; ici x1<y1
	move	y1,residu
	lsr	#1,residu
cas20
	plot
	sub	x1,residu
	bhi.s	cas21
	add	y1,residu
	subq	#1,x0
cas21
	sub	pasx,x0
	dbra	y0,cas20
	rts
drawlin
	cmp	#200,y0
	bhs	clip1
	cmp	#200,y1
	bhs	clip1
noclip
	cmp	y0,y1		;si les 2 Y sont ‚gaux,
	beq.s	ploton		; on n'affiche que le point (x0,y0)

	cmp	maxy,y0
	ble.s	drawl1
	move	y0,maxy
drawl1	cmp	miny,y0
	bgt.s	drawl2
	move	y0,miny
drawl2
;
; … partir d'ici x1 et y1 repr‚sentent deltax et deltay
;  (grosse ruse !!!!)
;
	sub	y0,y1		;calcule valeur absolue de deltay
	blt	setdy		;ici y1 est diff‚rent de 0 !!!!

	add	y0,y0
	move.l	ptr1,ptr2
	add	y0,ptr2

	move	y1,y0		;nb de points … calculer
	subq	#1,y0		;(on n'affiche pas le dernier point !!!)
	beq.s	plotone

	sub	x0,x1		;calcule valeur absolue de deltax
	bge.s	positif
;
; cas deltax n‚gatif
;
	neg	x1		;abs(deltax)
	cmp	y1,x1
	bhi.s	cas2
;
; cas deltax n‚gatif et deltay>=deltax
;
cas1
; ici x1<=y1
	move	y1,residu
	lsr	#1,residu
cas10
	plot
	sub	x1,residu
	bhi.s	cas11
	add	y1,residu
	subq	#1,x0
cas11
	dbra	y0,cas10
	rts
ploton	add	y0,y0
	move.l	ptr1,ptr2
	add	y0,ptr2
plotone
	plot
	rts
plotone2
	plot2
	rts
positif
;
; cas deltax positif
;
	cmp	y1,x1
	bhi.s	cas4
;
; cas deltax positif et deltay>=deltax
;
cas3
	move	y1,residu
	lsr	#1,residu
; ici x1<=y1
cas30
	plot
	sub	x1,residu
	bhi.s	cas31
	add	y1,residu
	addq	#1,x0
cas31
	dbra	y0,cas30
	rts
;
; cas deltax positif et deltax>deltay
;
; donc deltax<>0
;
cas4
	ext.l	x1		;voir plus haut
	divu	y1,x1
	move	x1,pasx		;pasx=int(deltay/deltax)
	swap	x1		;x1=reste de la division

	move	y1,residu
	lsr	#1,residu
; ici x1<y1
cas40
	plot
	sub	x1,residu
	bhi.s	cas41
	add	y1,residu
	addq	#1,x0
cas41
	add	pasx,x0
	dbra	y0,cas40
	rts
;
; cas deltax n‚gatif et deltax>deltay
;
; donc deltax<>0
;
cas6
	ext.l	x1		;efface les bits 16 … 31 (bit 15=0)
	divu	y1,x1
	move	x1,pasx		;pasx=int(deltay/deltax)
	swap	x1		;x1=reste de la division

	move	y1,residu
	lsr	#1,residu
; ici x1<y1
cas60
	plot2
	sub	x1,residu
	bhi.s	cas61
	add	y1,residu
	subq	#1,x0
cas61
	sub	pasx,x0
	dbra	y0,cas60
	rts
;
;
setdy
	neg	y1		;inverse le signe de deltay
	add	y0,y0
	lea	2(ptr1,y0.w),ptr2

	move	y1,y0		;nb de points … calculer
	subq	#1,y0		;(on n'affiche pas le dernier point !!!)
	beq.s	plotone2

	sub	x0,x1		;calcule valeur absolue de deltax
	bge.s	negatif
;
; cas deltax n‚gatif
;
	neg	x1		;abs(deltax)
	cmp	y1,x1
	bhi.s	cas6
;
; cas deltax n‚gatif et deltay>=deltax
;
cas5
	move	y1,residu
	lsr	#1,residu
; ici x1<=y1
cas50
	plot2
	sub	x1,residu
	bhi.s	cas51
	add	y1,residu
	subq	#1,x0
cas51
	dbra	y0,cas50
	rts
negatif
;
; cas deltax positif
;
	cmp	y1,x1
	bhi.s	cas8
;
; cas deltax positif et deltay>=deltax
;
cas7
	move	y1,residu
	lsr	#1,residu
; ici x1<=y1
cas70
	plot2
	sub	x1,residu
	bhi.s	cas71
	add	y1,residu
	addq	#1,x0
cas71
	dbra	y0,cas70
	rts
;
; cas deltax positif et deltax>deltay
;
; donc deltax<>0
;
cas8
	ext.l	x1		;voir plus haut
	divu	y1,x1
	move	x1,pasx		;pasx=int(deltay/deltax)
	swap	x1		;x1=reste de la division

	move	y1,residu
	lsr	#1,residu
; ici x1<y1
cas80
	plot2
	sub	x1,residu
	bhi.s	cas81
	add	y1,residu
	addq	#1,x0
cas81
	add	pasx,x0
	dbra	y0,cas80
	rts

	SECTION	BSS
coordy1	ds.w	200	;ces 2 buffers doivent se suivre !!!
coordy2	ds.w	200

	SECTION	TEXT

mskpoint
	dc.l	$7FFF7FFF,$BFFFBFFF,$DFFFDFFF,$EFFFEFFF
	dc.l	$F7FFF7FF,$FBFFFBFF,$FDFFFDFF,$FEFFFEFF
	dc.l	$FF7FFF7F,$FFBFFFBF,$FFDFFFDF,$FFEFFFEF
	dc.l	$FFF7FFF7,$FFFBFFFB,$FFFDFFFD,$FFFEFFFE
masks
mskgau	dc.l	$00000000,$80008000,$C000C000,$E000E000
	dc.l	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	dc.l	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	dc.l	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE
mskdro	dc.l	$7FFF7FFF,$3FFF3FFF,$1FFF1FFF,$0FFF0FFF
	dc.l	$07FF07FF,$03FF03FF,$01FF01FF,$00FF00FF
	dc.l	$007F007F,$003F003F,$001F001F,$000F000F
	dc.l	$00070007,$00030003,$00010001,$00000000

nodraw	
	move	#$8000,const
nodraw2
	rts
clip1
	cmp	y0,y1
	beq.S	nodraw2
	moveq	#ylow,borne
	cmp	borne,y0
	bge.s	clip3
	cmp	borne,y1
	blt.s	nodraw
	neg	y0
	move	borne,coef2
	add	y0,coef2
	add	y1,y0
	move	x1,coef1
	sub	x0,coef1
	muls	coef1,coef2
	divs	y0,coef2
	add	coef2,x0
	move	borne,y0
	bra.s	clip2
clip3	cmp	borne,y1
	bge.s	clip2
	neg	y1
	move	borne,coef2
	add	y1,coef2
	add	y0,y1
	move	x0,coef1
	sub	x1,coef1
	muls	coef1,coef2
	divs	y1,coef2
	add	coef2,x1
	move	borne,y1
clip2	move	#yhigh,borne
	cmp	borne,y0
	ble.s	clip4
	cmp	borne,y1
	bgt.s	nodraw
	neg	y0
	move	borne,coef2
	add	y0,coef2
	add	y1,y0
	move	x1,coef1
	sub	x0,coef1
	muls	coef1,coef2
	divs	y0,coef2
	add	coef2,x0
	move	borne,y0
	bra.s	clip5
clip4	cmp	borne,y1
	ble.s	clip5
	neg	y1
	move	borne,coef2
	add	y1,coef2
	add	y0,y1
	move	x0,coef1
	sub	x1,coef1
	muls	coef1,coef2
	divs	y1,coef2
	add	coef2,x1
	move	borne,y1
clip5	move	#$8000,const
	bra	noclip








*****************************************************************
*	macro de swapping des 2 ecrans 				*
*****************************************************************

SWAPPER MACRO
	move.b	(VBL_MEMO).w,D0
	IFEQ	CPUAFF-1
	move.w	#$400,$FFFF8240.W
	ENDC
vbl_wait:
	cmp.b	(VBL_COUNT).w,D0
	beq.s	vbl_wait
	IFEQ	CPUAFF-1
	clr.w	$FFFF8240.W
	ENDC


	move.l	sys_scr3,D0
	move.l	sys_scr2,sys_scr3
	move.l	sys_scr1,sys_scr2
	move.l	D0,sys_scr1
	lsr.w	#8,D0
	move.l	D0,$FFFF8200.W
	move.b	(VBL_COUNT).w,(VBL_MEMO).w
	ENDM

*****************************************************************
*	programme principal					*
*****************************************************************
main:
	BSR	initpoly

	clr.w	$FFFF8240.W

	move.w	#$026,$FFFF8242.W
	move.w	#$013,$FFFF8244.W
	move.w	#$141,$FFFF8246.W
	move.w	#$555,$FFFF8248.W
	move.w	#$770,$FFFF824A.W
	move.w	#$050,$FFFF824C.W
	move.w	#$033,$FFFF824E.W
	move.w	#$115,$FFFF8250.W
	move.w	#$077,$FFFF8252.W
	move.w	#$055,$FFFF8254.W
	move.w	#$033,$FFFF8256.W
	move.w	#$700,$FFFF8258.W
	move.w	#$500,$FFFF825A.W
	move.w	#$300,$FFFF825C.W
	move.w	#$050,$FFFF825E.W

repeat
	move.b	$ffFFFC02.w,D0
	cmp.b	#$4B,D0
	bne.s	pasgauche
	addq.w	#1,vtheta
	bra.s	pasdroite	
pasgauche:
	cmp.b	#$4D,D0
	bne.s	pasdroite
	subq.w	#1,vtheta
pasdroite:

	cmp.b	#$48,D0
	bne.s	pashaut
	addq.w	#1,vphi
	bra.s	pasbas
pashaut:
	cmp.b	#$50,D0
	bne.s	pasbas
	subq.w	#1,vphi
pasbas:

	cmp.b	#$61,D0
	bne.s	pasundo
	clr.w	vphi
	clr.w	vtheta
pasundo:
	cmp.b	#$62,D0
	bne.s	pashelp
	move.w	#256+128,theta
	move.w	#128,phi
pashelp:
	cmp.b	#$4A,D0
	bne.s	pasmoins
	subq.w	#4,distance
pasmoins:
	cmp.b	#$4E,D0
	bne.s	pasplus
	addq.w	#4,distance
pasplus:
	cmp.b	#$F,D0
	bne.s	pastab
	move.w	#$FFFF,visible
pastab:
	cmp.b	#$10,D0
	bne.s	pasa
	clr.w	visible
pasa:

	jsr	ffastcls(PC)
	jsr	projection(PC)

	SWAPPER

	cmp.b	#$39,$FFFC02
	bne	repeat
	
	rts

projection:

	ifeq	PRJAFF-1
	move.w	#$222,$FFFF8240.W
	endc



	*----------- calcul des paramŠtres de la projection ---------

	lea	sinus(PC),A0		;A0->table des sinus

	move.w	theta(PC),D7		;D7=theta
	add.w	vtheta(PC),D7
	and.w	#$1FF,D7
	move.w	D7,theta
	add.w	D7,D7
	move.w	(A0,D7.W),D0		;D0=sin(theta)
	add.w	#$100,D7
	and.w	#$3FF,D7
	move.w	(A0,D7.W),D1		;D1=cos(theta)

	move.w	phi(PC),D7		;D7=phi
	add.w	vphi(PC),D7
	and.w	#$1FF,D7
	move.w	D7,phi
	add.w	D7,D7
	move.w	(A0,D7.W),D2		;D2=sin(phi)
	add.w	#$100,D7
	and.w	#$3FF,D7
	move.w	(A0,D7.W),D3		;D3=cos(phi)

	move.w	D2,D4
	muls	D1,D4			;D4=cos(theta)sin(phi)
	add.l	D4,D4
	move.w	D0,D4

	move.w	D2,D5
	muls	D0,D5			;D5=sin(theta)sin(phi)
	add.l	D5,D5
	move.w	D1,D5

	move.w	D3,D6
	muls	D1,D6			;D6=cos(theta)cos(phi)
	add.l	D6,D6
	move.w	D2,D6

	move.w	D3,D7
	muls	D0,D7			;D7=sin(theta)cos(phi)
	add.l	D7,D7
	move.w	D3,D7


	ifeq	PRJAFF-1
	clr.w	$FFFF8240.W
	endc


	ifeq	CALAFF-1
	move.w	#$030,$FFFF8240.W
	endc

	*-------------- calcul des points projet‚s ---------------

	lea	pcube(PC),A0		;A0->table des points 
	lea	ppoints(PC),A1		;A1->table des points projet‚s

prj_rep1:
	move.w	(A0)+,D0		;D0=X
	beq.s	prj_frep1		;si dernier point

	neg.w	D0			;D0=-X
	move.w	D0,A2			;A2=-X(L)
	muls	D4,D0			;D0=-X sin(theta)
	move.w	(A0)+,D1		;D1=Y
	move.w	D1,D3			;D3=Y(L)
	neg.w	D3
	muls	D5,D1			
	add.l	D1,D0			;D0=XO

	move.w	A2,D1			;D1=-X(L)
	swap	D4
	muls	D4,D1			;D1=-X cos(theta)sin(phi)
	swap	D4
	move.w	D3,D2			;D2=-Y(L)
	swap	D5
	muls	D5,D2
	swap	D5			;D2=-Y * sin(theta)sin(phi)
	add.l	D2,D1			
	move.w	(A0)+,D2		;D2=Z
	move.w	D2,A3
	muls	D7,D2
	add.l	D2,D1			;D1=YO

	swap	D7
	muls	D7,D3
	swap	D7			;D3=-Y sin(theta)cos(phi)
	move.w	A2,D2			;D2=-X(L)
	swap	D6
	muls	D6,D2
	swap	D6			;D2=-X * cos(theta)cos(phi)
	add.l	D3,D2
	move.w	A3,D3
	neg.w	D3
	muls	D6,D3
	add.l	D3,D2
	swap	D2

	add.w	distance(PC),D2

	asr.l	#7,D0
	asr.l	#7,D1

	divs	D2,D0
	divs	D2,D1

 	add.w	#160,D0
	swap	D0
	move.w	#100,D0
	sub.w	D1,D0

	move.l	D0,(A1)+
	
	bra.s	prj_rep1


prj_frep1:


	ifeq	CALAFF-1
	clr.w	$FFFF8240.W
	endc


	*------------- affichage des facettes ------------

	lea	ppoints(PC),A2
	lea	fcube(PC),A3


prj_rep2:
	clr.w	D7
	move.b	(A3)+,D7

	beq	prj_frep2

	add.w	D7,D7
	add.w	D7,D7
	movem	(A2,D7.W),D0/D1		;XA,YA

	clr.w	D7
	move.b	(A3)+,D7
	add.w	D7,D7
	add.w	D7,D7
	move.w	(A2,D7.W),A4		;XB
	move.w	2(A2,D7.W),D3		;YB

	clr.w	D7
	move.b	(A3)+,D7
	add.w	D7,D7
	add.w	D7,D7
	move.w	(A2,D7.W),A6		;XC
	move.w	2(A2,D7.W),A5		;YC

	move.w	D0,D2
	sub.w	A4,D2
	move.w	D3,D5
	sub.w	A5,D5
	muls	D2,D5

	move.w	A6,D2
	sub.w	A4,D2
	move.w	D1,D4
	sub.w	D3,D4
	muls	D2,D4

	add.l	D5,D4

	bgt.s	prj_visible
	
	addq.l	#2,A3		
	bra.s	prj_rep2	

prj_visible:

	lea	CARRE(PC),A0

	move.w	D0,(A0)+
	move.w	D1,(A0)+

	move.w	A4,(A0)+
	move.w	D3,(A0)+

	move.w	A6,(A0)+
	move.w	A5,(A0)+


	move.w	#3,D0

	clr.w	D7
	move.b	(A3)+,D7
	beq.s	prj_pas4l	

	add.w	D7,D7
	add.w	D7,D7
	move.w	(A2,D7.W),D2
	move.w	2(A2,D7.W),D3

	move.w	D2,(A0)+
	move.w	D3,(A0)+

	move.w	#4,D0


prj_pas4l:

	swap	D0
	move.b	(A3)+,D0
	and.w	#$F,D0
	swap	D0


	LEA	CARRE(PC),A0
	move.l	sys_scr3(PC),A6

	movem.l	a2/a3,-(SP)
	move	#$555,$ffff8240.w
	BSR	polyfill
	clr	$ffff8240.w
	movem.l	(SP)+,a2/a3

	bra	prj_rep2
prj_frep2:

	rts


ffastcls:
	movem.l		D0-D7/A0-A6,-(SP)

	move.l		sys_scr3(PC),A0
	lea		32000(A0),A0

	moveq.l		#0,D0
	move.l		D0,D1
	move.l		D0,D2
	move.l		D0,D3
	move.l		D0,D4
	move.l		D0,D5
	move.l		D0,D6
	move.l		D0,D7
	move.l		D0,A1
	move.l		D0,A2
	move.l		D0,A3
	move.l		D0,A4
	move.l		D0,A5
	move.l		D0,A6

x	set	0
	REPT		571
	movem.l		D0-D7/A1-A6,-(A0)
x	set	x+14*4
	ENDR
	movem.l	d0-d5,-(a0)
x	set	x+6*4
	ifne	x-32000
	list
	dc.w	32000-x
	nolist
	endc
	movem.l		(SP)+,D0-D7/A0-A6
	rts
	
*------------- interruption vbl ----------------------------
new_vbl:
	addq.b	#1,VBL_COUNT\w
	rte

*------------- sauve le palette ----------------------------

save_pal:
	move.l	#$FF8240,A0
	lea	sys_palette,A1
	bra.s	copy_pal		
rest_pal:
	lea	sys_palette,A0
	lea	$FFFF8240.w,A1
copy_pal:
	rept	8
	move.l	(A0)+,(A1)+
	endr
	rts

************************************************************
	SECTION DATA
************************************************************

nbs:	dc.w	90

*---------- table des n x 160 ------------------------------
sys_mul160:
cpt	set 	0
	REPT	200
	dc.w	cpt
cpt	set		cpt+160	
	ENDR

*--------- table des sinus,cosinus -------------------------

sinus:
      DC.W      $0,$192,$324,$4B6            	  ;0
      DC.W      $647,$7D9,$96A,$AFB            	  ;4
      DC.W      $C8B,$E1B,$FAB,$1139               ;8
      DC.W      $12C7,$1455,$15E1,$176D            ;12
      DC.W      $18F8,$1A82,$1C0B,$1D93            ;16
      DC.W      $1F19,$209F,$2223,$23A6            ;20
      DC.W      $2527,$26A7,$2826,$29A3            ;24
      DC.W      $2B1F,$2C98,$2E10,$2F87            ;28
      DC.W      $30FB,$326E,$33DE,$354D            ;32
      DC.W      $36B9,$3824,$398C,$3AF2            ;36
      DC.W      $3C56,$3DB7,$3F17,$4073            ;40
      DC.W      $41CD,$4325,$447A,$45CC            ;44
      DC.W      $471C,$4869,$49B3,$4AFB            ;48
      DC.W      $4C3F,$4D81,$4EBF,$4FFB            ;52
      DC.W      $5133,$5268,$539A,$54C9            ;56
      DC.W      $55F5,$571D,$5842,$5964            ;60
      DC.W      $5A82,$5B9C,$5CB3,$5DC7            ;64
      DC.W      $5ED7,$5FE3,$60EB,$61F0            ;68
      DC.W      $62F1,$63EE,$64E8,$65DD            ;72
      DC.W      $66CF,$67BC,$68A6,$698B            ;76
      DC.W      $6A6D,$6B4A,$6C23,$6CF8            ;80
      DC.W      $6DC9,$6E96,$6F5E,$7022            ;84
      DC.W      $70E2,$719D,$7254,$7307            ;88
      DC.W      $73B5,$745F,$7504,$75A5            ;92
      DC.W      $7641,$76D8,$776B,$77FA            ;96
      DC.W      $7884,$7909,$7989,$7A05            ;100
      DC.W      $7A7C,$7AEE,$7B5C,$7BC5            ;104
      DC.W      $7C29,$7C88,$7CE3,$7D39            ;108
      DC.W      $7D89,$7DD5,$7E1D,$7E5F            ;112
      DC.W      $7E9C,$7ED5,$7F09,$7F37            ;116
      DC.W      $7F61,$7F86,$7FA6,$7FC1            ;120
      DC.W      $7FD8,$7FE9,$7FF5,$7FFD            ;124
      DC.W      $7FFF,$7FFD,$7FF5,$7FE9            ;128
      DC.W      $7FD8,$7FC1,$7FA6,$7F86            ;132
      DC.W      $7F61,$7F37,$7F09,$7ED5            ;136
      DC.W      $7E9C,$7E5F,$7E1D,$7DD5            ;140
      DC.W      $7D89,$7D39,$7CE3,$7C88            ;144
      DC.W      $7C29,$7BC5,$7B5C,$7AEE            ;148
      DC.W      $7A7C,$7A05,$7989,$7909            ;152
      DC.W      $7884,$77FA,$776B,$76D8            ;156
      DC.W      $7641,$75A5,$7504,$745F            ;160
      DC.W      $73B5,$7307,$7254,$719D            ;164
      DC.W      $70E2,$7022,$6F5E,$6E96            ;168
      DC.W      $6DC9,$6CF8,$6C23,$6B4A            ;172
      DC.W      $6A6D,$698B,$68A6,$67BC            ;176
      DC.W      $66CF,$65DD,$64E8,$63EE            ;180
      DC.W      $62F1,$61F0,$60EB,$5FE3            ;184
      DC.W      $5ED7,$5DC7,$5CB3,$5B9C            ;188
      DC.W      $5A82,$5964,$5842,$571D            ;192
      DC.W      $55F5,$54C9,$539A,$5268            ;196
      DC.W      $5133,$4FFB,$4EBF,$4D81            ;200
      DC.W      $4C3F,$4AFB,$49B3,$4869            ;204
      DC.W      $471C,$45CC,$447A,$4325            ;208
      DC.W      $41CD,$4073,$3F17,$3DB7            ;212
      DC.W      $3C56,$3AF2,$398C,$3824            ;216
      DC.W      $36B9,$354D,$33DE,$326E            ;220
      DC.W      $30FB,$2F87,$2E10,$2C98            ;224
      DC.W      $2B1F,$29A3,$2826,$26A7            ;228
      DC.W      $2527,$23A6,$2223,$209F            ;232
      DC.W      $1F19,$1D93,$1C0B,$1A82            ;236
      DC.W      $18F8,$176D,$15E1,$1455            ;240
      DC.W      $12C7,$1139,$FAB,$E1B              ;244
      DC.W      $C8B,$AFB,$96A,$7D9                ;248
      DC.W      $647,$4B6,$324,$192                ;252
      DC.W      $0,$FE6D,$FCDB,$FB49               ;256
      DC.W      $F9B8,$F826,$F695,$F504            ;260
      DC.W      $F374,$F1E4,$F054,$EEC6            ;264
      DC.W      $ED38,$EBAA,$EA1E,$E892            ;268
      DC.W      $E707,$E57D,$E3F4,$E26C            ;272
      DC.W      $E0E6,$DF60,$DDDC,$DC59            ;276
      DC.W      $DAD8,$D958,$D7D9,$D65C            ;280
      DC.W      $D4E0,$D367,$D1EF,$D078            ;284
      DC.W      $CF04,$CD91,$CC21,$CAB2            ;288
      DC.W      $C946,$C7DB,$C673,$C50D            ;292
      DC.W      $C3A9,$C248,$C0E8,$BF8C            ;296
      DC.W      $BE32,$BCDA,$BB85,$BA33            ;300
      DC.W      $B8E3,$B796,$B64C,$B504            ;304
      DC.W      $B3C0,$B27E,$B140,$B004            ;308
      DC.W      $AECC,$AD97,$AC65,$AB36            ;312
      DC.W      $AA0A,$A8E2,$A7BD,$A69B            ;316
      DC.W      $A57D,$A463,$A34C,$A238            ;320
      DC.W      $A128,$A01C,$9F14,$9E0F            ;324
      DC.W      $9D0E,$9C11,$9B17,$9A22            ;328
      DC.W      $9930,$9843,$9759,$9674            ;332
      DC.W      $9592,$94B5,$93DC,$9307            ;336
      DC.W      $9236,$9169,$90A1,$8FDD            ;340
      DC.W      $8F1D,$8E62,$8DAB,$8CF8            ;344
      DC.W      $8C4A,$8BA0,$8AFB,$8A5A            ;348
      DC.W      $89BE,$8927,$8894,$8805            ;352
      DC.W      $877B,$86F6,$8676,$85FA            ;356
      DC.W      $8583,$8511,$84A3,$843A            ;360
      DC.W      $83D6,$8377,$831C,$82C6            ;364
      DC.W      $8276,$822A,$81E2,$81A0            ;368
      DC.W      $8163,$812A,$80F6,$80C8            ;372
      DC.W      $809E,$8079,$8059,$803E            ;376
      DC.W      $8027,$8016,$800A,$8002            ;380
      DC.W      $8001,$8002,$800A,$8016            ;384
      DC.W      $8027,$803E,$8059,$8079            ;388
      DC.W      $809E,$80C8,$80F6,$812A            ;392
      DC.W      $8163,$81A0,$81E2,$822A            ;396
      DC.W      $8276,$82C6,$831C,$8377            ;400
      DC.W      $83D6,$843A,$84A3,$8511            ;404
      DC.W      $8583,$85FA,$8676,$86F6            ;408
      DC.W      $877B,$8805,$8894,$8927            ;412
      DC.W      $89BE,$8A5A,$8AFB,$8BA0            ;416
      DC.W      $8C4A,$8CF8,$8DAB,$8E62            ;420
      DC.W      $8F1D,$8FDD,$90A1,$9169            ;424
      DC.W      $9236,$9307,$93DC,$94B5            ;428
      DC.W      $9592,$9674,$9759,$9843            ;432
      DC.W      $9930,$9A22,$9B17,$9C11            ;436
      DC.W      $9D0E,$9E0F,$9F14,$A01C            ;440
      DC.W      $A128,$A238,$A34C,$A463            ;444
      DC.W      $A57D,$A69B,$A7BD,$A8E2            ;448
      DC.W      $AA0A,$AB36,$AC65,$AD97            ;452
      DC.W      $AECC,$B004,$B140,$B27E            ;456
      DC.W      $B3C0,$B504,$B64C,$B796            ;460
      DC.W      $B8E3,$BA33,$BB85,$BCDA            ;464
      DC.W      $BE32,$BF8C,$C0E8,$C248            ;468
      DC.W      $C3A9,$C50D,$C673,$C7DB            ;472
      DC.W      $C946,$CAB2,$CC21,$CD91            ;476
      DC.W      $CF04,$D078,$D1EF,$D367            ;480
      DC.W      $D4E0,$D65C,$D7D9,$D958            ;484
      DC.W      $DAD8,$DC59,$DDDC,$DF60            ;488
      DC.W      $E0E6,$E26C,$E3F4,$E57D            ;492
      DC.W      $E707,$E892,$EA1E,$EBAA            ;496
      DC.W      $ED38,$EEC6,$F054,$F1E4            ;500
      DC.W      $F374,$F504,$F695,$F826            ;504
      DC.W      $F9B8,$FB49,$FCDB,$FE6D            ;508


theta:	DC.W	128
phi:	DC.W	0

vtheta:	DC.W	2
vphi:	DC.W	3



tobjets:
	DC.L	ospider
ospider:
	DC.W	100		;X
	DC.W	50		;Y
	DC.W	-50		;Z
	DC.W	40		;theta
	DC.L	pspider
	
	DC.L	fspider

pspider:
	DC.W	-15,  25,  0
	DC.W	 25,  30,  0
	DC.W	-65,  10,  0
	DC.W	-15,  10,  5
	DC.W	 25,  10,  5
	DC.W	 40,  10,  0
	DC.W	-65, -10,  0
	DC.W	-15, -10,  5
	DC.W	 25, -10,  5
	DC.W	 40, -10,  0
	DC.W	-15, -25,  0
	DC.W	 25, -30,  0
	DC.W	-15,  25, -5
	DC.W	 25,  30, -5
	DC.W	-75,   5, -5
	DC.W	 40,  10, -5
	DC.W	-75,  -5, -5
	DC.W	 40, -10, -5
	DC.W	-15, -25, -5
	DC.W	 25, -30, -5
	DC.W	-10,   0,-15
	DC.W	 20,   0,-15
	DC.W	 0
fspider:
	DC.B	2,0,3,0,1
	DC.B	4,3,0,1,2
	DC.B	1,5,4,0,3
	DC.B	2,3,7,6,4
	DC.B	3,4,8,7,5
	DC.B	4,5,9,8,6
	DC.B	6,7,10,0,7
	DC.B	7,8,11,10,8
	DC.B	8,9,11,0,9
	DC.B	12,0,2,14,10
	DC.B	1,0,12,13,11
	DC.B	5,1,13,15,12
	DC.B	9,5,15,17,13
	DC.B	11,9,17,19,14
	DC.B	10,11,19,18,15
	DC.B	6,10,18,16,1
	DC.B	2,6,16,14,2
	DC.B	13,12,20,21,3
	DC.B	12,14,20,0,4
	DC.B	20,14,16,0,5
	DC.B	20,16,18,0,6
	DC.B	20,18,19,21,7
	DC.B	21,19,17,0,8
	DC.B	15,21,17,0,9
	DC.B	13,21,15,0,10
	DC.B	0
	EVEN
pdisk:
	DC.W	 -45,45,4
	DC.W	45,45,4
	DC.W	45,-50,4
	DC.W	-45,-50,4
	DC.W	 -45,45,0
	DC.W	45,45,0
	DC.W	45,-50,0
	DC.W	-45,-50,0
pdiskf:
	DC.W	-35,45,4
	DC.W	35,45,4
	DC.W	35,-10,4
	DC.W	-35,-10,4
	DC.W	-25,-20,4
	DC.W	25,-20,4
	DC.W	25,-50,4
	DC.W	-25,-50,4
	DC.W	35,-20,4
	DC.W	35,-50,4
	DC.W	-15,-25,4
	DC.W	-5,-25,4
	DC.W	-5,-45,4
	DC.W	-15,-45,4
	DC.W	37,40,4
	DC.W	42,40,4
	DC.W	42,36,4
	DC.W	37,36,4
pdiskd:
	DC.W	37,40,0
	DC.W	42,40,0
	DC.W	42,36,0
	DC.W	37,36,0
	DC.W	-35,45,0
	DC.W	35,45,0
	DC.W	35,32,0
	DC.W	-35,32,0
	DC.W	1,15,0
	DC.W	11,11,0
	DC.W	15,0,0
	DC.W	11,-11,0
	DC.W	1,-15,0
	DC.W	-11,-11,0
	DC.W	-15,0,0
	DC.W	-11,11,0
	DC.W	-25,-20,0
	DC.W	25,-20,0
	DC.W	25,-50,0
	DC.W	-25,-50,0
	DC.W	35,-20,0
	DC.W	35,-50,0
	DC.W	-15,-25,0
	DC.W	-5,-25,0
	DC.W	-5,-45,0
	DC.W	-15,-45,0
	DC.W	0
pcaisse:
	DC.W	-10,10,0
	DC.W	10,10,0
	DC.W	10,-10,0
	DC.W	-10,-10,0

	DC.W	-15,15,5
	DC.W	15,15,5
	DC.W	15,-15,5
	DC.W	-15,-15,5

	DC.W	-15,15,25
	DC.W	15,15,25
	DC.W	15,-15,25
	DC.W	-15,-15,25

	DC.W	-10,10,30
	DC.W	10,10,30
	DC.W	10,-10,30
	DC.W	-10,-10,30

	DC.W	0
pcube:
pchar:
	DC.W	-30,25,0
	DC.W	30,25,0
	DC.W	30,-25,0
	DC.W	-30,-25,0
	DC.W	-40,25,10
	DC.W	40,25,10
	DC.W	40,-25,10
	DC.W	-40,-25,10
	DC.W	-40,25,20
	DC.W	40,25,20
	DC.W	40,-25,20
	DC.W	-40,-25,20
	DC.W	-20,20,25
	DC.W	10,20,25
	DC.W	10,-20,25
	DC.W	-20,-20,25
	DC.W	0
pmonolyte:
	DC.W	-20,-5,0
	DC.W	20,-5,0
	DC.W	20,5,0
	DC.W	-20,5,0
	DC.W	-20,-5,90
	DC.W	20,-5,90
	DC.W	20,5,90
	DC.W	-20,5,90
	DC.W	0
pde:
	DC.W	-20,-20,-20
	DC.W	20,-20,-20
	DC.W	20,20,-20
	DC.W	-20,20,-20
	DC.W	-20,-20,20
	DC.W	20,-20,20
	DC.W	20,20,20
	DC.W	-20,20,20
	DC.W	0
pcone:
	DC.W	-15,35,0
	DC.W	15,35,0
	DC.W	35,15,0
	DC.W	35,-15,0
	DC.W	15,-35,0
	DC.W	-15,-35,0
	DC.W	-35,-15,0
	DC.W	-35,15,0
	DC.W	1,0,100
	DC.W	0
pplaque:
	DC.W	-30,-30,0
	DC.W	30,-30,0
	DC.W	30,30,0
	DC.W	-30,30,0
	DC.W	0
ptriangle:
	DC.W	1,0,30
	DC.W	1,22,0
	DC.W	20,-13,0
	DC.W	-20,-13,0
	DC.W	0
pmaison:
	DC.W	-50,-50,-50
	DC.W	 50,-50,-50
	DC.W	 50, 50,-50
	DC.W	-50, 50,-50	
	DC.W	-50,-50,  0
	DC.W	 50,-50,  0
	DC.W	 50, 50,  0
	DC.W	-50, 50,  0	
	DC.W	  1,  0, 80  
	DC.W	  0

fdisk:
	DC.B	2,3,0,1,1
	DC.B	7,6,5,4,1
	DC.B	1,5,6,2,2
	DC.B	2,6,7,3,2
	DC.B	7,4,0,3,2
	DC.B	1,0,4,5,2
fdiskf:
	DC.B	8,9,10,11,3
	DC.B	12,13,14,15,4
	DC.B	13,16,17,14,5
	DC.B	18,19,20,21,6
	DC.B	22,23,24,25,7
fdiskd:
	DC.B	29,28,27,26,3
	DC.B	33,32,31,30,4
	DC.B	34,41,40,35,5
	DC.B	35,40,39,36,6
	DC.B	36,39,38,37,7
	DC.B	43,42,45,44,8
	DC.B	46,43,44,47,9
	DC.B	49,48,51,50,10

	DC.B	0
fcube:
fchar:
;	DC.B	3,0,1,2,5
	DC.B	1,2,6,5,2
	DC.B	7,3,0,4,3
	DC.B	5,4,0,1,9
	DC.B	7,6,2,3,5
	DC.B	9,8,4,5,6
	DC.B	8,11,7,4,7
	DC.B	11,10,6,7,8
	DC.B	10,9,5,6,9
	DC.B	12,8,9,13,10
	DC.B	13,9,10,14,11
	DC.B	14,10,11,15,12
	DC.B	15,11,8,12,13
	DC.B	12,13,14,15,14
	DC.B    0
fde:
	DC.B	2,3,0,1
	DC.B	7,6,5,4
	DC.B	1,5,6,2
	DC.B	4,0,3,7
	DC.B	5,1,0,4
	DC.B	7,3,2,6
	DC.B	0
fcone:
	DC.B	7,0,8,0
	DC.B	8,0,1,0
	DC.B	1,2,8,0
	DC.B	8,2,3,0
	DC.B	3,4,8,0
	DC.B	8,4,5,0
	DC.B	5,6,8,0
	DC.B	8,6,7,0
	DC.B	7,0,8,0
	DC.B	0
fplaque:
	DC.B	2,3,0,1
	DC.B	1,0,3,2
	DC.B	0
ftriangle:
	DC.B	1,2,0,0
	DC.B	1,0,3,0
	DC.B	2,3,0,0
	DC.B	3,2,1,0
	DC.B	0
fmaison:
	DC.B	2,3,0,1,1
	DC.B	2,6,7,3,2
	DC.B	5,1,0,4,3
	DC.B	5,6,2,1,4
	DC.B	4,0,3,7,5
	DC.B	7,8,4,0,6
	DC.B	4,8,5,0,7
	DC.B	5,8,6,0,8
	DC.B	6,8,7,0,9	
	DC.B	0
	even

distance:	DC.W	200	
sys_minx:	DC.W	0
sys_maxx:	DC.W	319
sys_miny:	DC.W	0
sys_maxy:	DC.W	199
	

************************************************************
    SECTION 	BSS
************************************************************
ppoints:
	DS.W	2*128
visible:
	ds.w	1
sys_vbl:
	ds.l	1		;adresse ancienne vbl
sys_rez:
 	ds.w	1		;resolution systŠme
sys_palette:
	ds.w	16		;couleurs du systŠme
sys_screen:
	ds.l	1		;adresse ecran systŠme
sys_scr1:
	ds.l	1		;adresse ecran visualis‚
sys_scr2:
	ds.l	1		;adresse ecran a visualiser
sys_scr3:
	ds.l	1
screen2:	
	ds.b	64256	;buffer ecran 2
userstack:
	ds.l	1	
endstack:
	ds.l	100
mystack:		
    