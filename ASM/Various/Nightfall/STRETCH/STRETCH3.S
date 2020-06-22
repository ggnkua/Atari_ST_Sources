**** Programme de test de routine de d‚formation en temps r‚el
**** Optimisation du code
**** Temps r‚el non encore atteint pour des images 320*240
**** Version 0.2 de la routine 13.6.94
**** ½Nightfall form Let There Be Light!
**** Routine de Stretch circulaire CircleStretch ajout‚e
**** Elle fonctionne parfaitement!


	section TEXT
*************************************************************************
StartProgram:
	clr.l	-(sp)		passage en mode superviseur
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)	on sauve la pile utilisateur

*	move.w	sr,-(sp)	on sauve le sr sur la pile
*	move.w	#$2700,sr	on stoppe toute les interrupts

	bsr	Install_Screen
	bsr	Init_Screen
	bsr	Program
	bsr	Program2
	bsr	Restore_Screen

; routine pour vider le buffer clavier
.kflush:
	btst.b	#0,$fffffc00.w
	beq.s	.kfok
	move.b	$fffffc02.w,d0
	bra.s	.kflush
.kfok:
*	move.w	(sp)+,sr	on restore le sr depuis la pile
EndProgram:
	move.w	#$20,-(sp)	passage en mode utilisateur
	trap	#1		(l'adresse est deja sur la pile)
	addq.l	#6,sp
	clr.w	-(sp)		on quitte le programme
	trap	#1

*************************************************************************
; Sauvegarde de la configuration de l'ecran et des variables associ‚es
Install_Screen:
	lea	Save_Zone2,a6
	move.w	#-1,-(sp)	VGetScreenMode
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,(a6)+	on sauve ScreenMode
	move.w	d0,d7		on le stocke
	move.w	#2,-(sp)	Xbios(2)
	trap	#14
	addq.l	#2,sp
	move.l	d0,(a6)+	on sauve pbase
;installe la configuration de l'ecran
		; XXXXXXXFSOPV8NNN
	and.w	#%1111111000110000,d7	on annule les bits BPS
	or.w	#%0000000100000100,d7	on installe le mode 256 colors

	movea.l	#screen,a1

	move.w	d7,-(sp)	SetScreen
	move.w	#3,-(sp)	
	move.l	a1,-(sp)
	move.l	a1,-(sp)
	move.w	#5,-(sp)	Xbios(5)
	trap	#14
	lea	14(sp),sp
	rts
*************************************************************************
; procedure qui r‚installe les variables concernant l'ecran
Restore_Screen:
	lea	Save_Zone2,a6
	move.w	(a6)+,-(sp)	OldScreenMode
	move.w	#3,-(sp)
	move.l	(a6),-(sp)	OldPbase
	move.l	(a6)+,-(sp)	OldPbase
	move.w	#5,-(sp)
	trap	#14		SetScreen (Xbios(5))
	lea	14(sp),sp
	rts

*************************************************************************
; routine qui efface l'ecran
Init_Screen:
	movea.l	#screen,a0
	move.w	#((320*240*2)/4)-1,d0
.cls	clr.l	(a0)+
	dbra	d0,.cls

	rts
*************************************************************************
; programme principal
Program2:
	move.w	#0,d0	
	move.w	#idx,d1
	move.w	#0,d2	
	move.w	#idy,d3
	move.w	#0,d4	
	move.w	#icy,d5
	move.w	#0,d6	
	move.w	#icx,d7

.wait

	movea.l	#screen,a0
	movea.l	#Block,a1
	adda.l	#18,a1

	move.w	#240-1,-(sp)
	sub.w	d2,(sp)
	move.w	#320-1,-(sp)
	sub.w	d0,(sp)
	move.w	d2,-(sp)
	move.w	d0,-(sp)

	move.w	#200-1,-(sp)
	sub.w	d4,(sp)
	move.w	#176-1,-(sp)
	sub.w	d6,(sp)
	move.w	d4,-(sp)
	move.w	d6,-(sp)

	bsr	RectStretch

	lea	16(sp),sp
	
	add.w	d1,d0
	tst.w	d0
	bgt.s	.pos
	neg.w	d1
	bra.s	.cont
.pos	cmp.w	#320-idx,d0
	blt.s	.cont
	neg.w	d1
.cont
	add.w	d3,d2
	tst.w	d2
	bgt.s	.pos2
	neg.w	d3
	bra.s	.cont2
.pos2	cmp.w	#240-idy,d2
	blt.s	.cont2
	neg.w	d3
.cont2
	add.w	d5,d4
	tst.w	d4
	bgt.s	.pos3
	neg.w	d5
	bra.s	.cont3
.pos3	cmp.w	#200-icy,d4
	blt.s	.cont3
	neg.w	d5
.cont3
	add.w	d6,d7
	tst.w	d6
	bgt.s	.pos4
	neg.w	d7
	bra.s	.cont4
.pos4	cmp.w	#176-icx,d6
	blt.s	.cont4
	neg.w	d7
.cont4
	cmp.b	#$39,$fffffc02.w
	bne	.wait

	rts
*************************************************************************
Program:
	movea.l	#screen,a0
	movea.l	#Block,a1
	adda.l	#18,a1

idx	equ	1
idy	equ	2
icx	equ	2
icy	equ	4

	move.w	#0,d0	
	move.w	#idx,d1
	move.w	#0,d2	
	move.w	#idy,d3
	move.w	#0,d4	
	move.w	#icy,d5
	move.w	#0,d6	
	move.w	#icx,d7

.wait
	move.w	#10,-(sp)
	add.w	d2,(sp)
	move.w	#120,-(sp)
	move.w	#64,-(sp)
	add.w	d0,(sp)
	sub.w	d1,(sp)
	move.w	d4,-(sp)
	move.w	#75,-(sp)
	add.w	d4,(sp)

	bsr	CircleStretch

	lea	10(sp),sp

	add.w	d1,d0
	tst.w	d0
	bgt.s	.pos
	neg.w	d1
	bra.s	.cont
.pos	cmp.w	#192-idx,d0
	blt.s	.cont
	neg.w	d1
.cont
	add.w	d3,d2
	tst.w	d2
	bgt.s	.pos2
	neg.w	d3
	bra.s	.cont2
.pos2	cmp.w	#88-idy,d2
	blt.s	.cont2
	neg.w	d3
.cont2
	add.w	d5,d4
	tst.w	d4
	bgt.s	.pos3
	neg.w	d5
	bra.s	.cont3
.pos3	cmp.w	#100-icx,d4
	blt.s	.cont3
	neg.w	d5
.cont3
	cmp.b	#$39,$fffffc02.w
	bne	.wait

	rts
*************************************************************************
*************************************************************************
* CircleStretch remplit un disque avec rectangle bitmap
CircleStretch:
; en entr‚e:
;	a0	ecran destination
;	a1	ecran source
SBMINX	equ	4+32
SBMAXX	equ	6+32
xc	equ	8+32
yc	equ	10+32
r	equ	12+32

	movem.l	d0-d7,-(sp)

	move.w	r(sp),d0	p=r
	move.w	d0,d3		y=0
	lsl.w	#1,d0
	neg.w	d0
	add.w	#3,d0		p=3-(r<<1)
	clr.w	d2		x=0


.while	cmp.w	d2,d3		x<y?
	blt	.wend
		
	swap	d0		on stocke p
	move.w	xc(sp),d0
	move.w	yc(sp),d1
	move.w	r(sp),d4
	move.w	d1,d7
	add.w	d2,d7		yc+x
	move.w	d4,d6
	add.w	d2,d6		r+x
	move.w	d1,d5
	sub.w	d2,d5		yc-x
	sub.w	d2,d4		r-x
	move.w	d0,d1
	sub.w	d3,d0		xc-y
	add.w	d3,d1		xc+y
	swap	d2		on stocke x
	swap	d3		on stocke y
	move.w	SBMINX(sp),d2
	move.w	SBMAXX(sp),d3

	bsr	Stretch2Lines

	swap	d2
	swap	d3
	swap	d0
	
.if	tst.w	d0
	bge	.else
	addq.w	#6,d0
	move.w	d2,d1
	lsl.w	#2,d1
	add.w	d1,d0		p=p+6+(x<<2)
	bra	.endif
.else
	swap	d0		on stocke p
	move.w	xc(sp),d0
	move.w	yc(sp),d1
	move.w	r(sp),d4
	move.w	d1,d7
	add.w	d3,d7		yc+y
	move.w	d4,d6
	add.w	d3,d6		r+y
	move.w	d1,d5
	sub.w	d3,d5		yc-y
	sub.w	d3,d4		r-y
	move.w	d0,d1
	sub.w	d2,d0		xc-x
	add.w	d2,d1		xc+x
	swap	d2		on stocke x
	swap	d3		on stocke y
	move.w	SBMINX(sp),d2
	move.w	SBMAXX(sp),d3

	bsr	Stretch2Lines

	swap	d2
	swap	d3
	swap	d0

	add.w	#10,d0
	move.w	d2,d1
	sub.w	d3,d1		x-y	
	lsl.w	#2,d1
	add.w	d1,d0		p=p+10+((x-y)<<2)
	subq.w	#1,d3		dec y
.endif
	addq.w	#1,d2		inc x
	bra	.while
.wend
	cmp.w	d2,d3		d2<>d3?
	bne	.fin
**** Stretch
	swap	d0		on stocke p
	move.w	xc(sp),d0
	move.w	yc(sp),d1
	move.w	r(sp),d4
	move.w	d1,d7
	add.w	d3,d7		yc+y
	move.w	d4,d6
	add.w	d3,d6		r+y
	move.w	d1,d5
	sub.w	d3,d5		yc-y
	sub.w	d3,d4		r-y
	move.w	d0,d1
	sub.w	d2,d0		xc-x
	add.w	d2,d1		xc+x
	swap	d2		on stocke x
	swap	d3		on stocke y
	move.w	SBMINX(sp),d2
	move.w	SBMAXX(sp),d3

	bsr	Stretch2Lines

	swap	d2
	swap	d3
	swap	d0

.fin	movem.l	(sp)+,d0-d7
	rts
*************************************************************************
**** Stretch2Lines stretches two source lines with same lenght and
**** different y-coordinates onto two destination lines with same
**** lenght and different y-coordinates. Used by CircleStretch.
Stretch2Lines:
; en entr‚e:
;	d0	x1
;	d1	x2
;	d2	y1
;	d3	y2
;	d4	yr1
;	d5	yw1
;	d6	yr2
;	d7	yw2

Lsource	equ	176*2
Ldest	equ	320*2

	mulu	#Ldest,d5
	mulu	#Ldest,d7
	mulu	#Lsource,d4
	mulu	#Lsource,d6
	movea.l	a1,a2		source
	movea.l	a1,a3
	movea.l	a0,a4		dest
	movea.l	a0,a5
	lea	(a2,d4.l),a2	source 1
	lea	(a3,d6.l),a3	source 2
	lea	(a4,d5.l),a4	dest 1
	lea	(a5,d7.l),a5	dest 2

	sub.w	d0,d1		x2-x1
	sub.w	d2,d3		y2-y1
	move.w	#1,d4		sx
	move.w	#1,d5		sy
	
	tst.w	d1
	bge	.sign2
	neg.w	d4		sx=sign(x2-x1)=-1
.sign2	tst.w	d3
	bge	.abs1
	neg.w	d5		sy=sign(y2-y1)=-1
.abs1	tst.w	d1
	bge	.abs2
	neg.w	d1
.abs2	tst.w	d3
	bge	.cont
	neg.w	d3
.cont
	move.w	d1,d6		dx2=dx
	lsl.w	#1,d6		dx2=2*dx2
	lsl.w	#1,d3		dy=2*dy
	move.w	d3,d7		e=2*dy
	sub.w	d1,d7		e=(2*dy)-dx
.for
	swap	d6		on stocke les valeurs
	swap	d7

	move.w	d0,d6		x1
	lsl.w	#1,d6
	move.w	d2,d7		y1
	lsl.w	#1,d7
	move.w	(a2,d7.w),(a4,d6.w)
	move.w	(a3,d7.w),(a5,d6.w)

	swap	d6
	swap	d7
	

.while	tst.w	d7
	bmi	.wend
	add.w	d5,d2		x1+=sy=y1
	sub.w	d6,d7		e-=dx2
	bra	.while
.wend	add.w	d4,d0		xd1+=sx=x1
	add.w	d3,d7		e+=dy

	dbra	d1,.for
.next
	rts

*************************************************************************
*************************************************************************
*************************************************************************
*RectStretch ‚largit ou r‚trŠcit un rectangle source vers un rectangle
*destination. La source est s‚l‚ctionn‚e par deux points (xs1,ys1) et
*(xs2,ys2), et la destination par (xd1,yd1) et (xd2,yd2).
RectStretch:
; en entr‚e:
;	a1	ecran source
;	a0	ecran destination
;		l'‚cran source peut avoir des dimensions quelquonques
;		l'‚cran destination est large comme un ‚cran standart
;	0(sp)	xs1.w
;	2(sp)	ys1.w
;	4(sp)	xs2.w
;	6(sp)	ys2.w
;	8(sp)	xd1.w
;	10(sp)	yd1.w
;	12(sp)	xd2.w
;	14(sp)	yd2.w

xs1	equ	0+4+32
ys1	equ	2+4+32
xs2	equ	4+4+32
ys2	equ	6+4+32
xd1	equ	8+4+32
yd1	equ	10+4+32
xd2	equ	12+4+32
yd2	equ	14+4+32

	movem.l	d0-d7,-(sp)
	move.w	#1,d2		sign(yd2-yd1)=1
	move.w	#1,d3		sign(ys2-ys1)=1
	move.w	yd2(sp),d0
	sub.w	yd1(sp),d0	dx=yd2-yd1
	move.w	ys2(sp),d1
	sub.w	ys1(sp),d1	dy=ys2-ys1
	tst.w	d0
	bge	.sign2
	neg.w	d2		sx=sign(yd2-yd1)=-1
.sign2	tst.w	d1
	bge	.abs1
	neg.w	d3		sy=sign(ys2-ys1)=-1
.abs1	tst.w	d0
	bge	.abs2
	neg.w	d0
.abs2	tst.w	d1
	bge	.cont
	neg.w	d1

.cont	move.w	d0,d5		dx2=dx
	lsl.w	#1,d5		dx2=2*dx2
	lsl.w	#1,d1		dy=2*dy
	move.w	d1,d4		e=2*dy
	sub.w	d0,d4		e=(2*dy)-dx

	move.w	ys1(sp),d6
	move.w	yd1(sp),d7

	bra	.start
.for	tst.w	d4
	bmi	.copy
.while	tst.w	d4
	bmi	.wend
	add.w	d3,d6		ys1+=sy
	sub.w	d5,d4		e-=dx2
	bra	.while
.wend	add.w	d2,d7		yd1+=sx
	add.w	d1,d4		e+=dy
.start	
	bsr	Stretch

	dbra	d0,.for
	bra.s	.next
.copy	bsr	CopyLine
	add.w	d2,d7		yd1+=sx
	add.w	d1,d4		e+=dy

	dbra	d0,.for

.next	movem.l	(sp)+,d0-d7
	rts	

*************************************************************************
* Copie d'une ligne horizontale stretch‚e Utilis‚ par RectStretch
CopyLine:
	rts
*************************************************************************
*Stretch une ligne horizontale. Utilis‚ par RectStretch
Stretch:
	movem.w	d0-d7,-(sp)

	move.w	#1,d2		sign(xd2-xd1)=1
	move.w	#1,d3		sign(xs2-xs1)=1
	move.w	xd2+20(sp),d0
	sub.w	xd1+20(sp),d0	dx=xd2-xd1
	move.w	xs2+20(sp),d1
	sub.w	xs1+20(sp),d1	dy=xs2-xs1
	tst.w	d0
	bge	.sign2
	neg.w	d2		sx=sign(xd2-xd1)=-1
.sign2	tst.w	d1
	bge	.abs1
	neg.w	d3		sy=sign(xs2-xs1)=-1
.abs1	tst.w	d0
	bge	.abs2
	neg.w	d0
.abs2	tst.w	d1
	bge	.cont
	neg.w	d1

.cont	move.w	d0,d5		dx2=dx
	lsl.w	#1,d5		dx2=2*dx2
	lsl.w	#1,d1		dy=2*dy
	move.w	d1,d4		e=2*dy
	sub.w	d0,d4		e=(2*dy)-dx

	mulu	#352,d6
	movea.l	a1,a2
	adda.l	d6,a2
	mulu	#640,d7
	movea.l	a0,a3
	adda.l	d7,a3

	move.w	xs1+20(sp),d6	y1
	move.w	xd1+20(sp),d7	x1

.for
	swap	d4
	swap	d5
	move.w	d6,d4
	lsl.w	#1,d4
	move.w	d7,d5
	lsl.w	#1,d5
	move.w	(a2,d4.w),(a3,d5.w)
	swap	d4
	swap	d5
	

.while	tst.w	d4
	bmi	.wend
	add.w	d3,d6		xs1+=sy=y1
	sub.w	d5,d4		e-=dx2
	bra	.while
.wend	add.w	d2,d7		xd1+=sx=x1
	add.w	d1,d4		e+=dy

	dbra	d0,.for
	
.next	movem.w	(sp)+,d0-d7
	rts	
*************************************************************************
*************************************************************************
		DATA
		even
Block		incbin	'elise.tg1'

		BSS
Save_Zone2:	ds.l	24		place pour les variables screens

*************************************************************************
; debut de l'ecran de scroll
screen:
		ds.b	320*240*2

		END