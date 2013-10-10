;
;		FIRST TRIDI BALL...
;		===================
;
;debut		: 14/08/91
;derniere modif	: 15/08/91
;
;fichiers a inclure	:-gfxboule.inc
;		 -cosin   .inc
;		 -graphchr.inc
;		 -prehi   .
;
;remarque:	il est possible de connaitre la qualite du rafraichisement 
;(50 Hz/25 Hz/16 Hz...) en definissant VBLTIM egal a 1 
; VBLTIM juste ici dessous:
;
VBLTIM	=	0
;
;	code de PrinST pour the MegaBusters
	opt	o+
;==========================================================================
;
;		   ici les "MACRO"
;	(ne pas oublier incbiner le fichier cosin.inc
;	          sous l'etiquette trigo...)
;
;==========================================================================
;====================================
;	rotation spaciales
;====================================
;
;	parametre:	d0: X spacial 
;		d1: Y spacial
;		d2: Z spacial
;		d3: Angle de rotation sur Z
;		d4: Angle de rotation sur Y
;		d5: Angle de rotation sur X
;
;	retour:	d0: coordonne X apres rotation
;		d1: coordonne Y apres rotation
;		d2: coordonne Z apres rotation
;
rot_3d	macro
	lea	trigo,a2
	lea	trigo+180,a3
	add	d3,d3		; ax*2
	add	d4,d4		; ay*2
	add	d5,d5		; az*2
;			rotation sur les Z
	move	d1,d6		; d6=Ys
	move	(a3,d3.w),d7	; d7=256*sin(Ax)
	muls	d7,d6		; d6=256*Ys*sin(Ax)
	move.l	d6,a0		; a0=256*Ys*sin(Ax)
	move	d0,d6		; d6=Xs
	move	(a2,d3.w),d7	; d7=256*cos(Ax)
	muls	d7,d6		; d6=256*Xs*cos(Ax)
	add.l	d6,a0	; a0=256(Ys*sin(Ax)+Xs*cos(Ax))
	move	d1,d6		; d6=Ys
	move	(a2,d3.w),d7	; d7=256*cos(Ax)
	muls	d7,d6		; d6=256*Ys*cos(Ax)
	move.l	d6,a1		; a1=256*Ys*cos(Ax)
	move	d0,d6		; d6=Xs
	move	(a3,d3.w),d7	; d7=256*sin(Ax)
	muls	d7,d6		; d6=256*Ys*sin(Ax) 
	sub.l	d6,a1	;a1=256(Ys*cos(Ax)-Xs*sin(Ax))
	move.l	a0,d0	;d0=256(Ys*sin(Ax)+Xs*cos(Ax)) 
	move.l	a1,d1	;d1=256(Ys*cos(Ax)-Xs*sin(Ax))
	lsr.l	#8,d0	;d0=(Ys*sin(Ax)+Xs*cos(Ax))
	lsr.l	#8,d1	;d1=(Ys*cos(Ax)-Xs*sin(Ax))
;			Pareil sur les Y
	sub.l	#400,d2
	move	d2,d6
	move	(a3,d4.w),d7
	muls	d7,d6
	move.l	d6,a0
	move	d0,d6
	move	(a2,d4.w),d7
	muls	d7,d6
	add.l	d6,a0
	move	d2,d6
	move	(a2,d4.w),d7
	muls	d7,d6
	move.l	d6,a1
	move	d0,d6
	move	(a3,d4.w),d7
	muls	d7,d6 
	sub.l	d6,a1
	move.l	a0,d0
	move.l	a1,d2
	lsr.l	#8,d0
	lsr.l	#8,d2
	add.l	#400,d2
;			Pareil sur les X
	sub.l	#400,d2
	move	d2,d6
	move	(a3,d4.w),d7
	muls	d7,d6
	move.l	d6,a0
	move	d1,d6
	move	(a2,d4.w),d7
	muls	d7,d6
	add.l	d6,a0
	move	d2,d6
	move	(a2,d4.w),d7
	muls	d7,d6
	move.l	d6,a1
	move	d1,d6
	move	(a3,d4.w),d7
	muls	d7,d6 
	sub.l	d6,a1
	move.l	a0,d1 
	move.l	a1,d2
	lsr.l	#8,d1
	lsr.l	#8,d2
	add.l	#400,d2
	endm
;===================================
;	transformation 3D->2D
;===================================
;
;	parametre:	d0: coordonne X spaciale
;		d1: coordonne Y spaciale
;		d2: coordonne Z spaciale
;	
;	retour:	d3: coordonne X plane
;		d4: coordonne Y plane
;
t3d2d	macro
XF	=	160-8
YF	=	100-8
ZF	=	800
	move	d0,d3
	move	d1,d4
	move	d2,d0
	add	#ZF,d0
	muls	d2,d3	;calcul de Xp
	divs	d0,d3
	add.l	#XF,d3
	muls	d2,d4	;calcul de Yp
	divs	d0,d4
	add.l	#YF,d4
	endm
;===================================
;	macro musique...
;===================================
INITMUS	macro
	moveq.l	#1,d0
	jsr	zic
	endm
;====================================
;	afficher 1 sprite
;====================================
;
;	parametre:	d0:coordonnee X
;		d1:coordonnee y
;		a0:adresse ecran
;		a1:adresse sprite
;		a5:adresse sauve adr
;
;	remarque: a0/a1/a5 entierment modifier...
;
sprite	macro
	movem.l	d0-d7,-(sp)
	mulu	#160,d1
	lea	(a0,d1.w),a0
	move	d0,d1
	and	#$f,d1
	lsr	#4,d0
	lsl	#3,d0
	lea	(a0,d0.w),a0
	move.l	a0,(a5)+
	lsl	#8,d1
	lea	(a1,d1.w),a1
	rept	7
	movem.l	(a1)+,d0-d7
	and.l	d0,(a0)
	or.l	d1,(a0)
	addq.l	#8,a0
	and.l	d2,(a0)
	or.l	d3,(a0)
	lea	152(a0),a0
	and.l	d4,(a0)
	or.l	d5,(a0)
	addq.l	#8,a0
	and.l	d6,(a0)
	or.l	d7,(a0)
	lea	152(a0),a0
	endr
	movem.l	(a1)+,d0-d7
	and.l	d0,(a0)
	or.l	d1,(a0)
	addq.l	#8,a0
	and.l	d2,(a0)
	or.l	d3,(a0)
	lea	152(a0),a0
	and.l	d4,(a0)
	or.l	d5,(a0)
	addq.l	#8,a0
	and.l	d6,(a0)
	or.l	d7,(a0)
	movem.l	(sp)+,d0-d7
	endm
;==========================================================================
;
;
	section text
;
;
;==========================================================================
;
;	programe user
;
	move	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	pea	prog
	move 	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr 	-(sp)
	trap	#1
prog	
;
;	programe superuser
;
	move	#$2700,sr
	move.l	$70.w,-(sp)		;init des IT:
	move.l	#vbl,$70.w		;  VBL
	move.l	$fffffa06.w,-(sp)	;   &
	clr.l	$fffffa06.w		;  MFP
	move.b	$fffa07,v_fffa07
	clr.b	$fffa07
	move.b	$fffa09,v_fffa09
	clr.b	$fffa09
	bset	#0,$fffa07	
	move.b	$fffa13,v_fffa13
	bset	#0,$fffa13	
	move.l	$120.w,v_120
	move.l	#hbl,$120.w	 
	move.b	$fffa1b,v_fffa1b
	move.b	#8,$fffa1b	
	move.b	$fffa21,v_fffa21
	move.b	#1,$fffa21          
	not.b	$fffffa01.w
	move	#$2300,sr
	INITMUS
;
;	init les 2 ecrans
;
	move.l	#trigo,adrmvt
	move.l	#last,adrmv2
	move.l	#objet1,adrobj
	lea	chr+("*"-32)*8,a0
	move.b	#%00010000,(a0)+	
	move.b	#%00111000,(a0)+	
	move.b	#%11111110,(a0)+	
	move.b	#%01111100,(a0)+	
	move.b	#%00111000,(a0)+	
	move.b	#%01101100,(a0)+	
	move.b	#%01000100,(a0)+	
	move.b	#%00000000,(a0)+	
	move.l	#objet1,adrobj
	lea	chr+("#"-32)*8,a0
	move.b	#%01101100,(a0)+	
	move.b	#%11111110,(a0)+	
	move.b	#%11111110,(a0)+	
	move.b	#%01111100,(a0)+	
	move.b	#%00111000,(a0)+	
	move.b	#%00010000,(a0)+	
	move.b	#%00010000,(a0)+	
	move.b	#%00000000,(a0)+	
	move.l	#text,adrtxt
	move.l	#screens,d0
	and	#$ff00,d0
	add.l	#256,d0
	move.l	d0,adrphy
	add.l	#32000,d0
	move.l	d0,adrlog
	move.l	adrphy,a0
	move	#7999,d0
efface	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,efface
	move.l	adrphy,d0
	lea	eff1,a0
	move	#512,d1
remp	move.l	d0,(a0)+
	dbra	d1,remp
	move.l	#eff1,adrefp
	move.l	#eff2,adrefl
	move.l	#raster,adrras
;
;	palette de couleur
;
	lea	$ffff8240.w,a0
	lea	palette,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	
	move.l	#$00000700,$ffff8240.w
	move.l	#$07330777,$ffff8244.w
	lea	$ffff8248.w,a0
	move.l	#$00700070,(a0)+
	move.l	#$00700070,(a0)+
	move.l	#$00700070,(a0)+
	move.l	#$00700070,(a0)+
	move.l	#$00000000,(a0)+
	move.l	#$00000000,(a0)+
	move.l	#atomic,adratm
;===================================
;	boucle principale
;===================================
boucle	
;
;	mouvement rotatif...
;
zadd	addq.l	#1,Zmvt
	cmp.l	#360,Zmvt
	blt.s	yadd
	sub.l	#360,Zmvt
yadd	addq.l	#1,Ymvt
	cmp.l	#360,Ymvt
	blt.s	xadd
	sub.l	#360,Ymvt
xadd	addq.l	#1,Xmvt
	cmp.l	#360,Xmvt
	blt.s	ok
	sub.l	#360,Xmvt
ok
;
;	cree la nouvelle table avec rotation spaciale
;
	lea	objetok,a5
	move.l	adrobj,a6
	move	(a6)+,d7
rotations	move	d7,-(sp)
	move.l	(a6)+,d0
	move.l	(a6)+,d1
	move.l	(a6)+,d2
	move.l	Xmvt,d3
	move.l	Ymvt,d4
	move.l	Zmvt,d5
	rot_3d
	move	d0,(a5)+
	move	d1,(a5)+
	move	d2,(a5)+
	move	(sp)+,d7
	dbra	d7,rotations
;
;	tri des boules
;
	move.l	adrobj,a0
	move	(a0),d7
	lea	objetok+4,a0
tri	lea	(a0),a1
	move	(a0),d0
	lea	(a0),a2
	move	d7,d6
tri2	move	(a1),d1
	cmp	d1,d0
	blt.s	tri3
	lea	(a1),a2
	move	(a1),d0
tri3	addq.l	#6,a1
	dbra	d6,tri2
	subq.l	#4,a0
	subq.l	#4,a2
	move	(a2),d0
	move	(a0),(a2)+
	move	d0,(a0)+
	move	(a2),d0
	move	(a0),(a2)+
	move	d0,(a0)+
	move	(a2),d0
	move	(a0),(a2)
	move	d0,(a0)
	addq.l	#6,a0
	dbra	d7,tri
;
;	affichage des boules
;
	lea	gfxboule,a2
	move.l	adrlog,a3
	lea	objetok,a4
	move.l	adrefl,a5
	move.l	adrobj,a0
	move	(a0),d7
affiche	move	(a4)+,d0
	move	(a4)+,d1
	move	(a4)+,d2
	t3d2d
	move.l	d3,d0
	move.l	d4,d1
	lea	(a3),a0
	lea	(a2),a1
	sprite
	dbra	d7,affiche
;
;	inverse ecran physique et logique
;
	move.l	adrlog,d0
	move.l	adrphy,adrlog
	move.l	d0,adrphy
	lsr	#8,d0
	move.l	d0,$ffff8200.w
;
;	attendre la synchro spot TV
;
	IFNE VBLTIM = 1
	move	nb2vbl,d0
	lsl	#4,d0
	move.l	adrphy,a0
	lea	vblcom,a1
	add	d0,a1
	move	(a1)+,(a0)
	move	(a1)+,160*1(a0)
	move	(a1)+,160*2(a0)
	move	(a1)+,160*3(a0)
	move	(a1)+,160*4(a0)
	move	(a1)+,160*5(a0)
	move	(a1)+,160*6(a0)
	move	(a1)+,160*7(a0)
	ENDC
	
	move.b	#$ff,vblflg
vsync	tst.b	vblflg
	bne.s	vsync
		
	IFNE VBLTIM	= 1
	clr	nb2vbl
	ENDC
;
;	effacer les boules...
;
	moveq	#0,d0
	move.l	adrobj,a0
	move	(a0),d7
	move.l	adrefp,a0
effacer	move.l	(a0)+,a1
	move.l	d0,160(a1)
	move.l	d0,160*2(a1)
	move.l	d0,160*3(a1)
	move.l	d0,160*4(a1)
	move.l	d0,160*5(a1)
	move.l	d0,160*6(a1)
	move.l	d0,160*7(a1)
	move.l	d0,160*8(a1)
	move.l	d0,160*9(a1)
	move.l	d0,160*10(a1)
	move.l	d0,160*11(a1)
	move.l	d0,160*12(a1)
	move.l	d0,160*13(a1)
	move.l	d0,160*14(a1)
	move.l	d0,160*15(a1)
	move.l	d0,8(a1)
	move.l	d0,160+8(a1)
	move.l	d0,8+160*2(a1)
	move.l	d0,8+160*3(a1)
	move.l	d0,8+160*4(a1)
	move.l	d0,8+160*5(a1)
	move.l	d0,8+160*6(a1)
	move.l	d0,8+160*7(a1)
	move.l	d0,8+160*8(a1)
	move.l	d0,8+160*9(a1)
	move.l	d0,8+160*10(a1)
	move.l	d0,8+160*11(a1)
	move.l	d0,8+160*12(a1)
	move.l	d0,8+160*13(a1)
	move.l	d0,8+160*14(a1)
	move.l	d0,8+160*15(a1)
	dbra	d7,effacer
	move.l	adrefp,d0
	move.l	adrefl,adrefp
	move.l	d0,adrefl
;
;	objet en mouvement?
;
	cmp.l	#objet6,adrobj
	bne.s	mvt1
	addq.l	#8,adrmvt
	cmp.l	#trigo+360*2,adrmvt
	bne.s	mvt2
	move.l	#trigo,adrmvt
mvt2	move.l	adrmvt,a0
	move	(a0),objet6+2+12*12+2+4
	bra	touch
mvt1	cmp.l	#objet8,adrobj
	bne.s	mvt3
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.l	#$f,d0
	lsl.l	#3,d0
	move.l	d0,objet8+2+4
	neg.l	d0
	move.l	d0,objet8+2+4+12
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.l	#$f,d0
	lsl.l	#3,d0
	move.l	d0,objet8+2+4+12*2
	neg.l	d0
	move.l	d0,objet8+2+4+12*3
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.l	#$f,d0
	lsl.l	#3,d0
	move.l	d0,objet8+2+4+12*4
	neg.l	d0
	move.l	d0,objet8+2+4+12*5
	bra	touch	
mvt3	cmp.l	#objet7,adrobj
	bne.s	mvt5
	add.l	#32,adratm
	cmp.l	#atomic+360*8,adratm
	bne.s	mvt4
	move.l	#atomic,adratm
mvt4	move.l	adratm,a0
	lea	objet7+2+6*12,a1
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	addq.l	#4,a1
	move.l	d1,(a1)+
	move.l	d0,(a1)+
	addq.l	#8,a1
	move.l	d0,(a1)+
	move.l	d1,(a1)
	add.l	#400,(a1)+
	addq.l	#4,a1
	move.l	d1,(a1)+
	move.l	d0,(a1)
	add.l	#400,(a1)+
	addq.l	#4,a1
	move.l	d0,(a1)+
	move.l	d1,(a1)
	add.l	#400,(a1)+
	move.l	d1,(a1)+
	addq.l	#4,a1
	move.l	d0,(a1)
	add.l	#400,(a1)+
mvt5	cmp.l	#objet10,adrobj
	bne.s	mvt7
	move.l	adrmv2,a0
	lea	objet10+2+9*12,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	cmp.l	#endlast,a0
	bne.s	mvt6
	lea	last,a0
mvt6	move.l	a0,adrmv2
mvt7
;
;	on change d'objet?
;
touch	move.b	-$3fe.w,d0
	cmp.b	#$3b,d0
	bne.s	touch1
	cmp.l	#objet1,adrobj
	beq.s	touch1
	move.l	#objet1,adrobj
	move	#$52b9,zadd
	move	#$52b9,yadd
	move	#$52b9,xadd
	bsr	cls
touch1	cmp.b	#$3c,d0
	bne.s	touch2
	cmp.l	#objet2,adrobj
	beq.s	touch2
	move.l	#objet2,adrobj
	move	#$52b9,zadd
	move	#$56b9,yadd
	move	#$54b9,xadd
	bsr	cls
touch2	cmp.b	#$3d,d0
	bne.s	touch3
	cmp.l	#objet3,adrobj
	beq.s	touch3
	move.l	#objet3,adrobj
	move	#$56b9,zadd
	move	#$52b9,yadd
	move	#$54b9,xadd
	bsr	cls
touch3	cmp.b	#$3e,d0
	bne.s	touch4
	cmp.l	#objet5,adrobj
	beq.s	touch4
	move.l	#objet5,adrobj
	move	#$52b9,zadd
	move	#$52b9,yadd
	move	#$56b9,xadd
	bsr	cls
touch4	cmp.b	#$3f,d0
	bne.s	touch5
	cmp.l	#objet4,adrobj
	beq.s	touch5
	move.l	#objet4,adrobj
	move	#$52b9,zadd
	move	#$56b9,yadd
	move	#$52b9,xadd
	bsr	cls
touch5	cmp.b	#$40,d0
	bne.s	touch6
	cmp.l	#objet6,adrobj
	beq.s	touch6
	move.l	#objet6,adrobj
	move	#$56b9,zadd
	move	#$52b9,yadd
	move	#$52b9,xadd
	bsr	cls
touch6	cmp.b	#$41,d0
	bne.s	touch7
	cmp.l	#objet7,adrobj
	beq.s	touch7
	move.l	#objet7,adrobj
	move	#$54b9,zadd
	move	#$54b9,yadd
	move	#$52b9,xadd
	bsr	cls
touch7	cmp.b	#$42,d0
	bne.s	touch8
	cmp.l	#objet8,adrobj
	beq.s	touch8
	move.l	#objet8,adrobj
	move	#$52b9,zadd
	move	#$52b9,yadd
	move	#$54b9,xadd
	bsr	cls
touch8	cmp.b	#$43,d0
	bne.s	touch9
	cmp.l	#objet10,adrobj
	beq.s	touch9
	move.l	#objet10,adrobj
	move	#$52b9,zadd
	move	#$52b9,yadd
	move	#$52b9,xadd
	bsr	cls
touch9	
;
;	espace? sinon on recomence!!!
;
	cmp.b	#$39,$fffffc02.w
	bne	boucle
;
;	programe fini ici
;
	move	#$2700,sr
	move.b	v_fffa21,$fffa21
	move.b	v_fffa1b,$fffa1b
	move.b	$fffa13,v_fffa13
	move.l	v_120,$120.w
	move.b	v_fffa09,$fffa09
	move.b	v_fffa07,$fffa07
	move.l	(sp)+,$fffffa06.w	; on rend les ITs...
	move.l	(sp)+,$70.w
	move.l	$44e.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	move	#$2300,sr
	lea	$ffff8240.w,a0
	lea	palette,a1
	rept	8
	move.l	(a1)+,(a0)+
	endr
	not	$ffff8240.w 
	move.b	#8,$ffff8800.w
	move.b	#0,$ffff8802.w
	move.b	#9,$ffff8800.w
	move.b	#0,$ffff8802.w
	move.b	#10,$ffff8800.w
	move.b	#0,$ffff8802.w
	rts
cls	moveq	#0,d1
	move	#399,d2
	move.l	#screens,d3
	and.l	#$00ffff00,d3
	add.l	#256,d3
	move.l	d3,a0	
effa	rept	20
	move.l	d1,(a0)
	addq.l	#8,a0
	endr
	dbra	d2,effa
	rts
;===================================
;	interruption VBL
;===================================
vbl	clr	$ffff8240.w
	movem.l	d0-a6,-(sp)
	jsr	zic+8
;
;	afficher le new caractere...
;
	tst.b	clavier
	beq.s	vbl1b
	move.b	clavier,d0
	cmp.b	-$3fe.w,d0
	bne	vbl8
	clr.b	clavier	
vbl1b	not.b	h25
	beq	vbl8
	move.l	adrtxt,a0
	move.l	adrphy,a1
	move.l	adrlog,a2
	lea	chr,a3
	move.l	Xc,d0
	move.l	Yc,d1
	mulu	#160*8,d1
	move.l	d0,d2
	lsr	d0
	lsl	#3,d0
	add.l	d0,d1
	addq.l	#6,d1
	btst	#0,d2
	beq.s	vbl2	
	addq.l	#1,d1
vbl2	lea	(a1,d1.l),a1
	lea	(a2,d1.l),a2
	clr.b	(a1)
	clr.b	(a2)
	clr.b	160(a1)
	clr.b	160(a2)
	clr.b	160*2(a1)
	clr.b	160*2(a2)
	clr.b	160*3(a1)
	clr.b	160*3(a2)
	clr.b	160*4(a1)
	clr.b	160*4(a2)
	clr.b	160*5(a1)
	clr.b	160*5(a2)
	clr.b	160*6(a1)
	clr.b	160*6(a2)
	clr.b	160*7(a1)
	clr.b	160*7(a2)

	moveq	#0,d0
	move.b	(a0)+,d0
	addq.l	#1,adrtxt
	cmp.l	#endtxt,adrtxt
	bne.s	vbl3
	clr.l	Xc
	clr.l	Yc
	move.l	#text,adrtxt
vbl3	cmp.b	#6,d0
	bne.s	vbl7
	clr.l	Xc
	addq.l	#1,Yc
	bra	vbl5
vbl7	cmp.b	#7,d0
	bne.s	vbl9
	clr.l	Xc
	clr.l	Yc
	bra	vbl5
vbl9	cmp.b	#1,d0
	bne.s	vbl10
	subq.l	#1,Yc
	bra	vbl5
vbl10	cmp.b	#2,d0
	bne.s	vbl11
	addq.l	#1,Yc
	bra	vbl5
vbl11	cmp.b	#3,d0
	bne.s	vbl12
	subq.l	#1,Xc
	bra	vbl5
vbl12	cmp.b	#4,d0
	bne.s	vbl13
	addq.l	#1,Xc
	bra	vbl5
vbl13	cmp.b	#8,d0
	bne.s	vbl14
	add.l	#10,Xc
	bra	vbl5
vbl14	cmp.b	#5,d0
	bne.s	vbl15
	move.b	(a0)+,Xc+3
	move.b	(a0),Yc+3
	addq.l	#2,adrtxt
	bra	vbl5
vbl15	cmp.b	#9,d0
	bne.s	vbl16
	move.b	#12,h25
	bra	vbl5
vbl16	cmp.b	#10,d0
	bne.s	vbl17
	clr.b	h25
	bra.s	vbl5
vbl17	tst.b	d0
	bne.s	vbl6
	move.b	(a0),clavier
	addq.l	#1,adrtxt
	bra.s	vbl5
vbl6	sub.l	#32,d0
	lsl.l	#3,d0
	lea	(a3,d0.w),a0
	move.b	(a0),-2(a1)
	move.b	(a0)+,-2(a2)
	move.b	(a0),160-2(a1)
	move.b	(a0)+,160-2(a2)
	move.b	(a0),160*2-2(a1)
	move.b	(a0)+,160*2-2(a2)
	move.b	(a0),160*3-2(a1)
	move.b	(a0)+,160*3-2(a2)
	move.b	(a0),160*4-2(a1)
	move.b	(a0)+,160*4-2(a2)
	move.b	(a0),160*5-2(a1)
	move.b	(a0)+,160*5-2(a2)
	move.b	(a0),160*6-2(a1)
	move.b	(a0)+,160*6-2(a2)
	move.b	(a0),160*7-2(a1)
	move.b	(a0)+,160*7-2(a2)
	addq.l	#1,Xc
	cmp.l	#39,Xc
	bne.s	vbl5
	clr.l	Xc
	addq.l	#1,Yc
vbl5	move.l	adrphy,a1
	move.l	adrlog,a2
	move.l	Xc,d0
	move.l	Yc,d1
	mulu	#160*8,d1
	move.l	d0,d2
	lsr	d0
	lsl	#3,d0
	add.l	d0,d1
	btst	#0,d2
	beq.s	vbl6b
	addq.l	#1,d1
vbl6b	lea	(a1,d1.w),a1
	lea	(a2,d1.w),a2
	move.b	#$ff,6(a1)
	move.b	#$ff,6(a2)
	move.b	#$ff,160+6(a1)
	move.b	#$ff,160+6(a2)
	move.b	#$ff,160*2+6(a1)
	move.b	#$ff,160*2+6(a2)
	move.b	#$ff,160*3+6(a1)
	move.b	#$ff,160*3+6(a2)
	move.b	#$ff,160*4+6(a1)
	move.b	#$ff,160*4+6(a2)
	move.b	#$ff,160*5+6(a1)
	move.b	#$ff,160*5+6(a2)
	move.b	#$ff,160*6+6(a1)
	move.b	#$ff,160*6+6(a2)
	move.b	#$ff,160*7+6(a1)
	move.b	#$ff,160*7+6(a2)
vbl8	movem.l	(sp)+,d0-a6
	move.l	#raster,adrras
	clr.b	vblflg
	IFNE VBLTIM	= 1
	addq	#1,nb2vbl
	ENDC
	move.l	#hbl2,$120.w
	move.b	#159,$fffffa21.w          
	rte
;===================================
;	interruption HBL
;===================================
hbl	move.l	a6,-(sp)
	addq.l	#2,adrras
	move.l	adrras,a6
	move	(a6),$ffff8240.w
	move.l	(sp)+,a6
	bclr	#0,$fffffa0f.w
	rte

hbl2	move.l	#hbl,$120.w
	move.b	#1,$fffffa21.w
	bclr	#0,$fffffa0f.w
	rte

;==========================================================================
;
;
	section data
;
;
;===========================================================================
objet1	dc.w	59-1
;	definition d'un objet tridimentionnel
; la table est forme comme suit:	
;	dc.w  nombre de boule -1
;	dc.l  X1,Y1,Z1 (premiere boule)
;	dc.l  X2,Y2,Z2 (deusieme boule)
;	dc.l  ....
;	dc.l  Xn,Yn,Zn (derniere boule)
;
Z	set	220
	rept	5
Z	set	Z+60
	dc.l	-120,-160,Z
	dc.l	-60,-160,Z
	dc.l	0,-160,Z
	dc.l	60,-160,Z
	dc.l	120,-160,Z
	endr
Z	set	220
	rept	5
Z	set	Z+60
	dc.l	-120,160,Z
	dc.l	-60,160,Z
	dc.l	0,160,Z
	dc.l	60,160,Z
	dc.l	120,160,Z
	endr
	dc.l	0,-200,400
	dc.l	0,-120,400
	dc.l	0,-80,400
	dc.l	0,-40,400
	dc.l	0,0,400
	dc.l	0,40,400
	dc.l	0,80,400
	dc.l	0,120,400
	dc.l	0,200,400
objet2	dc.w	25-1
Z	set	220
	rept	5
Z	set	Z+60
	dc.l	-120,0,Z
	dc.l	-60,0,Z
	dc.l	0,0,Z
	dc.l	60,0,Z
	dc.l	120,0,Z
	endr
objet3	dc.w	27-1
	dc.l	-200,0,400
	dc.l	-120,0,400
	dc.l	-40,0,400
	dc.l	40,0,400
	dc.l	80,0,400
	dc.l	120,0,400
	dc.l	160,0,400
	dc.l	-200,-40,400
	dc.l	-200,-80,400
	dc.l	-200,40,400
	dc.l	-200,80,400
	dc.l	-160,-40,400
	dc.l	-80,-40,400
	dc.l	-40,-80,400
	dc.l	-40,-40,400
	dc.l	-40,40,400
	dc.l	-40,80,400
	dc.l	40,-80,400
	dc.l	40,-40,400
	dc.l	40,40,400
	dc.l	40,80,400
	dc.l	80,-80,400
	dc.l	80,80,400
	dc.l	120,-80,400
	dc.l	120,80,400
	dc.l	160,-40,400
	dc.l	160,40,400
objet4	dc.w	23-1
	dc.l	-80,-120,400
	dc.l	-80,-80,400
	dc.l	-80,-40,400
	dc.l	-80,0,400
	dc.l	-80,40,400
	dc.l	-120,80,400
	dc.l	-160,120,400
	dc.l	-200,120,400
	dc.l	80,-120,400
	dc.l	80,-80,400
	dc.l	80,-40,400
	dc.l	80,0,400
	dc.l	80,40,400
	dc.l	120,80,400
	dc.l	160,120,400
	dc.l	200,120,400
	dc.l	0,-120,400
	dc.l	0,-80,400
	dc.l	0,-40,400
	dc.l	0,0,400
	dc.l	0,40,400
	dc.l	0,80,400
	dc.l	0,120,400
objet5	dc.w	17-1
	dc.l	0,80,400
	dc.l	40,40,400
	dc.l	80,0,400
	dc.l	120,-40,400
	dc.l	160,-80,400
	dc.l	120,-120,400
	dc.l	80,-160,400
	dc.l	40,-160,400
	dc.l	0,-120,400
	dc.l	-40,-160,400
	dc.l	-80,-160,400
	dc.l	-120,-120,400
	dc.l	-160,-80,400
	dc.l	-120,-40,400
	dc.l	-80,0,400
	dc.l	-40,40,400
	dc.l	0,80,400
objet6	dc.w	25-1
Z	set	220
	rept	5
Z	set	Z+60
	dc.l	-120,0,Z
	dc.l	-60,0,Z
	dc.l	0,0,Z
	dc.l	60,0,Z
	dc.l	120,0,Z
	endr
objet7	dc.w	12-1
	dc.l	0,0,400
	dc.l	0,0,425
	dc.l	-25,-25,375
	dc.l	-25,25,375
	dc.l	25,25,375
	dc.l	25,-25,375
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	
objet8	dc.w	20-1
	dc.l	-80,0,400
	dc.l	-80,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	80,0,400
	dc.l	80,0,400
	dc.l	-160,0,400
	dc.l	-160,-50,400
	dc.l	-160,-100,400
	dc.l	-160,-150,400
	dc.l	-160,50,400
	dc.l	-160,100,400
	dc.l	-160,150,400
	dc.l	160,0,400
	dc.l	160,-50,400
	dc.l	160,-100,400
	dc.l	160,-150,400
	dc.l	160,50,400
	dc.l	160,100,400
	dc.l	160,150,400
	
objet9	dc.w	81-1
Z	set	(400-(5*40))
	rept	9
Z	set	Z+40
	dc.l	-160,0,Z
	dc.l	-120,0,Z
	dc.l	-80,0,Z
	dc.l	-40,0,Z
	dc.l	0,0,Z
	dc.l	40,0,Z
	dc.l	80,0,Z
	dc.l	120,0,Z
	dc.l	160,0,Z
	endr

objet10	dc.w	21-1
	dc.l	30,-200,400
	dc.l	30,-150,400
	dc.l	30,-100,400
	dc.l	30,-50,400
	dc.l	30,0,400
	dc.l	30,50,400
	dc.l	30,100,400
	dc.l	30,150,400
	dc.l	30,200,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	dc.l	0,0,400
	
	IFNE VBLTIM = 1
vblcom	dc.w	%0000000000000000
	dc.w	%0111110001111100
	dc.w	%0100000010000010
	dc.w	%0100000010000010
	dc.w	%0111100010000010
	dc.w	%0000010010000010
	dc.w	%0000010010000010
	dc.w	%0111100001111100
	dc.w	%0000000000000000
	dc.w	%0111110001111110
	dc.w	%0000010001000000
	dc.w	%0000010001000000
	dc.w	%0111110001111100
	dc.w	%0100000000000010
	dc.w	%0100000000000010
	dc.w	%0111110001111100
	dc.w	%0000000000000000
	dc.w	%0001100001111110
	dc.w	%0010100001000000
	dc.w	%0100100001000000
	dc.w	%0000100001111110
	dc.w	%0000100001000010
	dc.w	%0000100001000010
	dc.w	%0000100001111110
	dc.w	%0000000000000000
	dc.w	%0001100001111110
	dc.w	%0010100000000010
	dc.w	%0010100000000010
	dc.w	%0100100001111110
	dc.w	%0000100001000000
	dc.w	%0000100001000000
	dc.w	%0000100001111110
	dc.w	%0000000000000000
	dc.w	%0001100001111110
	dc.w	%0010100001000010
	dc.w	%0100100001000010
	dc.w	%0000100001000010
	dc.w	%0000100001000010
	dc.w	%0000100001000010
	dc.w	%0000100001111110
	dc.w	%0000000000000000
	dc.w	%0000011111110000
	dc.w	%0000010000010000
	dc.w	%0000010000010000
	dc.w	%0000011111110000
	dc.w	%0000010000010000
	dc.w	%0000010000010000
	dc.w	%0000011111110000
	dc.w	%0000000000000000
	dc.w	%0000011111110000
	dc.w	%0000000000010000
	dc.w	%0000000000010000
	dc.w	%0000000111111100
	dc.w	%0000000000100000
	dc.w	%0000000001000000
	dc.w	%0000000001000000
	ENDC
raster	dc.w	1,1,1,2,2,2,2,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7,7,7

gfxboule	incbin	gfxboule.inc
trigo	incbin	cosin.inc
chr	incbin	graphchr.inc
zic	incbin	zik.mai
atomic	incbin	atomic.inc
last	incbin	last.inc
endlast
text	dc.b	" ************* Hummm.... ************",6
	dc.b	8,"YOU ARE WELCOME IN THE",6
	dc.b	8,"   TRIDI-BALL SCREEN",6,2,2
	dc.b	4,"  I Think you said: oh lamer that's",6
	dc.b	4," not a 50 Hz tridi animation in the",6
	dc.b	4," background...",6,2
	dc.b	4,"   Yes it's true, but,you can see",6
	dc.b	4," 61 BALLS,and that's not a lamer",6
	dc.b	4," precalculed animation(Press F1-F5).",6,2
	dc.b	4,"       i think that's i can make",6
	dc.b	4," better, 'cause my routine is not",6
	dc.b	4," optimised...",6,2,2
	dc.b	8,"-----------------",6,2
	dc.b	8,"   PrinST of great MB!!!",6
	dc.b	"   the 16/08/91... ",7
	dc.b	"*",2,3,"*",2,3,"*",2,3,"*",2,3
	dc.b	"*",2,3,"*",2,3,"*",2,3,"*",2,3
	dc.b	"*",2,3,"*",2,3,"*",2,3,"*",2,3
	dc.b	"*",2,3,"*",2,3,"*",2,3,"*",2,3
	dc.b	"*",2,3,"*",2,3,"*",2,3,"*",2,3
	dc.b	"*",2,3,"*",2,3,"*",2,3
	dcb.b	37,"*"
	dc.b	"*",1,3,"*",1,3,"*",1,3,"*",1,3
	dc.b	"*",1,3,"*",1,3,"*",1,3,"*",1,3
	dc.b	"*",1,3,"*",1,3,"*",1,3,"*",1,3
	dc.b	"*",1,3,"*",1,3,"*",1,3,"*",1,3
	dc.b	"*",1,3,"*",1,3,"*",1,3,"*",1,3
	dc.b	"*",1,3,"*",1,3,"*",1,3
	dc.b	"*",3,3,"*",3,3,"*",3,3,"*",3,3
	dc.b	"*",3,3,"*",3,3,"*",3,3,"*",3,3
	dc.b	"*",3,3,"*",3,3,"*",3,3,"*",3,3
	dc.b	"*",3,3,"*",3,3,"*",3,3,"*",3,3
	dc.b	"*",3,3,"*",3,3,"*",3,3,"*",3,3
	dc.b	"*",3,3,"*",3,3,"*",3,3,"*",3,3
	dc.b	"*",3,3,"*",3,3,"*",3,3,"*",3,3
	dc.b	"*",3,3,"*",3,3,"*",3,3,"*",3,3
	dc.b	"*",3,3,"*",3,3,"*",3,3,"*",3,3
	dc.b	"*",3,3
	dc.b	5,5,23," Press Return for next page "
	dc.b	5,10,24," or Space for quit! ",0,$1c,9,7
	dcb.b	39*25,32
	dc.b	7," Hehe!!! nono c pas fini mec!!!!",7
	dc.b	"                                ",6
	dc.b	10,2,2,"Please not quickly."
	dc.b	6,1,"                   ",7
	dc.b	5,3,15,"MegaBusters Rules!"
	dc.b	5,21,3,"MegaBusters Rules!"
	dc.b	5,1,10,"MegaBusters Rules!"
	dc.b	5,8,12,"MegaBusters Rules!"
	dc.b	5,16,8,"MegaBusters Rules!"
	dc.b	5,11,1,"MegaBusters Rules!"
	dc.b	5,1,13,"MegaBusters Rules!"
	dc.b	5,8,6,"MegaBusters Rules!"
	dc.b	5,14,17,"MegaBusters Rules!"
	dc.b	5,6,16,"MegaBusters Rules!"
	dc.b	5,19,18,"MegaBusters Rules!"
	dc.b	5,12,11,"MegaBusters Rules!"
	dc.b	5,19,2,"MegaBusters Rules!"
	dc.b	5,20,4,"MegaBusters Rules!"
	dc.b	5,2,5,"MegaBusters Rules!"
	dc.b	5,6,7,"MegaBusters Rules!"
	dc.b	5,13,23,"Press M",0,$27
	dc.b	5,13,23,"Press B!!!!",0,$30
	dc.b	5,13,23,"YYYEEEAAHHH!!!!!!"
	dc.b	7,9
	dcb.b	39*24,32
	dc.b	7
	dc.b	" have you press F6-F9?",6
	dc.b	"  that's some animat tridi balls...",6
	dc.b	" some comment about it:",6,6,6
	dc.b	"  F1)      Mega TRIDI 61 balls",6
	dc.b	"  F2)      50 Hz no precalculed balls",6
	dc.b	"  F3)      MB tridi logo",6
	dc.b	"  F4)      enjoy",6
	dc.b	"  F5)      Atari tridi logo",6
	dc.b	"  F6)      First surprise!!!!",6
	dc.b	"  F7)      Atomic think...",6
	dc.b	"  F8)      tridi vumetre  ",6
	dc.b	"  F9)     Last Object!!!!",6,6,6,6,6  
	dc.b	" You can press fonction keys anywhere",6
	dc.b	8,"for quit press space...",6
	dc.b	5,7,23," Press S for next page",0,$1f,7,9
	dcb.b	39*24,32
	dc.b	10,7,8,"Now some MEGA GREATING!!!",6,6,6
	dc.b	"to MB members:",6
	dc.b	" the graphixxmens:",6
	dc.b	" Wanted & Ultimazozore:",6
	dc.b	"  excuse me for don't use all your gfx",6,6
	dc.b	" Wasp & Moby dick:",6
	dc.b	"  realy great work,felicitation!!!",6,6
	dc.b	" Binouit & Grizzo:",6
	dc.b	"   thanks for your friendship...",6,6,6,6,6,6
	dc.b	8,"   Press S",0,$1f," ",6
	dcb.b	15,1
	dcb.b	14,2
	dc.b	"                             "
	dcb.b	29,3
	dcb.b	14,1
	dc.b	" the Coders      :",6
	dc.b	" DJB   ",3,3,3,3,3,"jaybee         :     ",6
	dc.b	"    you are realy good coder!!!       ",6,6
	dc.b	" Oxwald & Jaile  :",6
	dc.b	"  your last co-production is great!  ",6,6
	dc.b	" EverST          : ",6
	dc.b	"  hehe you make very delirious text",6,6
	dc.b	" Tronic          :",6
	dc.b	"  a man who have make 1 atari!!!",6,6
	dc.b	" PrinST          :",6
	dc.b	"  a lamers BOSS,excuse me,",6,"        that's difficult!",6,6
	dc.b	8,"   Press S",0,$1f,6
	dcb.b	15,1
	dcb.b	14,2
	dc.b	"                       "
	dcb.b	23,3
	dcb.b	17,1
	dc.b	"the soundtracker & moral support:",6
	dc.b	"THE IRONSIDE        :          ",6
	dc.b	" realy great work,sorry for don't use",6
	dc.b	"          it in this DEMO.......",6
	dcb.b	30,32
	dc.b	6,"Outlaw              :              ",6
	dc.b	"  if you don't help me,the MB reunion",6
	dc.b	"     was absolutly impossible....",6
	dcb.b	39*8,32
	dc.b	5,13,23," Press S",0,$1f
	dc.b	5,13,23," Press T!!!!!",0,$14,7,9
	dc.b	5,6,23,"  YYYYEEEEAAAAAHHHHHH!!!!! ",7
	dcb.b	39*24,32
	dc.b	7," I hope you like the tridi animated",6
	dc.b	" objects. but that's realy a lamers ",6
	dc.b	" screen ,for men who see the    ",6
	dc.b	" RED SECTOR screen...",6
	dc.b	"  ---------------------------------- ",6
	dc.b	6
	dc.b	" enjoy the SPACE DEMO",6
	dc.b	"and SEE YOU SOON in us next production",6,6,6,6
	dc.b	4,4,4,4,4,4
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	1,1,1,1,1,1,1,1,1,1
	dc.b	"*",2
	dc.b	"*",2
	dc.b	"*",2
	dc.b	"*",2
	dc.b	"*",2
	dc.b	"*",1
	dc.b	"*",1
	dc.b	"*",1
	dc.b	"*",1
	dc.b	"*",1
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	1,1,1,1,1,1,1,1,1,1
	dc.b	4,4,4,4,4,4
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3
	dc.b	"*",2,3,1
	dc.b	"*********",1
	dc.b	"*",1,3
	dc.b	"*",1,3
	dc.b	"*",1,3
	dc.b	"*",1,3
	dc.b	3,3,3,3,3,3,3,3,3
	dc.b	"*********",1
	dc.b	"*",1,3
	dc.b	"*",1,3
	dc.b	"*",1,3
	dc.b	3,3,3,3,3,3,3,3,3
	dc.b	"*********",1,4
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",2,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",3,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"#",1,3
	dc.b	"############################"
	dc.b	3,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,9
	dc.b	3,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,10
	dc.b	3,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,9
	dc.b	3,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,10
	dc.b	3,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,9
	dc.b	3,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,10
	dc.b	5,13,23,"HIT SPACE!!!",0,$62,"    ",7,9
	dcb.b	39*10,32
	dc.b	7," hehe!! ok,i give you my adresse:",6,6
	dc.b	"        GILLES GRIMAUD",6
	dc.b	"        VILLENEUVE DE POLIGNY",6
	dc.b	"        05500 ST BONNET (FRANCE)",6,6
	dc.b	"or CONTACT ME ON MINITEL (3615 RTEL)",6,6
	dc.b	" i swapp only publicals domains",6
	dc.b	"              THE END",6,5,13,23,"HIT SPACE!!!",0,$39," "
endtxt	dc.b	" "
;
;
;
	section bss
;
;
;
adrras	ds.l	1
adrphy	ds.l	1
adrlog	ds.l	1
adrefp	ds.l	1
adrefl	ds.l	1
adrtxt	ds.l	1
adrobj	ds.l	1
adrmvt	ds.l	1
adratm	ds.l	1
adrmv2	ds.l	1
X1	ds.l	1
X2	ds.l	1
Y1	ds.l	1
Y2	ds.l	1
Zmvt	ds.l	1
Ymvt	ds.l	1
Xmvt	ds.l	1
v_120	DS.l	1
Xc	ds.l	1
Yc	ds.l	1
objetok	ds.l	256*3
eff1	ds.l	256
eff2	ds.l	256

compt	ds.w	1
nb2vbl	ds.w	1
palette	ds.w	16

vblflg	ds.b	1
v_fffa07	DS.b 	1
v_fffa09	DS.b 	1
v_fffa1b	DS.b 	1
v_fffa21	DS.b 	1
v_fffa13	DS.b 	1
h25	ds.b	1
clavier	ds.b	1
;
;	les ecrans
;
screens	ds.b	64256