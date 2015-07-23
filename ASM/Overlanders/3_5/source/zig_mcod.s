;
; 3D demo part
;
; Please enjoy this little demo by moving the mouse.
;
; This mini-game has been coded very fastly (8 hours!) during the
; ST-News international coding convention by MCODER and Ziggy STARDUST
; for the 3.5 Kb mini demo challenge. Impressive, isn't it?
; Don't worry about the length of the file after assembling, because
; it packs very good with any packer like JEK packer.
; We are working on 3D routines since 6 months, that's why we have been
; able to recode some 3D (and quite bad) routines very quickly.
; Just before, we had to finish the European Demo and we worked all
; the night (we are always very tired...).
; Excuse us for the comments that are missing or the fact that the demo
; is not really finished...
; We let you the source of this demo to show you that a 3D demo is not
; as complicated as it looks and that fast coding is possible with it.
; We hope you don't think that these routines are not our real routines,
; in fact it is very fast recoded routines which are not our final routines
; (they are 4 times faster).
; The aim of this spreading is that we wanted to learn to everybody how
; to do 3D animations and we hope you'll much more appreciate the amount
; of work 3D needs.
; We want to greet a great friend of us who works with us on 3D and
; who couldn't come at the convention for personal reasons : ALGERNON.
; If you use any of the techniques described in this source, please
; mention us.
;
; We are so tired now that we have to sleep...
;  Hey, that's wrong, I want to code NOW! -Ziggy-
; 

	opt	o+
	
SOURIS	=	1
	
ECRAN	=	$f0000	; $70000 for a 520 ST
nbsinus	=	512
cos1	=	32766	;cos(2*pi/512)
sin1	=	402	;sin(2*pi/512)
;
; 1) g‚n‚rateur de sinus
;
cosa	equr	d0
sina	equr	d1
n	equr	d2
reg0	equr	d3
reg1	equr	d4
	section	text
start:
	dc.w	$a00a
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	lea	pile(pc),a7
	
	move.l	#div0,$14.w
	
	movem.l	algernon(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	IFNE	SOURIS
	move	#34,-(a7)
	trap	#14
	addq	#2,a7
	move.l	d0,a0
	move.l	16(a0),-(a7)
	move.l	a0,-(a7)
	move.l	#mouse,16(a0)
	ENDC
	
	bsr	genere_sinus
	
	bra.s	mainloop
	
ang:	dc.w	0
vit:	dc.w	-20
obsx	dc.w	0
obsy	dc.w	-50
obsz	dc.w	0

MAXY	=	64
MAXX	=	64
	
mainloop:
	move	#nbsinus/2,angobx

	move	ym,d0
	cmpi	#MAXY,d0
	blt.s	.ok1
	move	#MAXY,d0
.ok1:
	cmpi	#-MAXY,d0
	bgt.s	.ok2
	move	#-MAXY,d0
.ok2:
	move	d0,ym
	addi	#32,d0	
	andi	#nbsinus-1,d0
	move	d0,angx

	move	xm,d0
	cmpi	#MAXX,d0
	blt.s	.ok3
	move	#MAXX,d0
.ok3:
	cmpi	#-MAXX,d0
	bgt.s	.ok4
	move	#-MAXX,d0
.ok4:
	move	d0,xm
	
	andi	#nbsinus-1,d0
	move	d0,angz
	move	xm,d0
	add	ang,d0
	move	d0,ang
	asr	#4,d0
	andi	#nbsinus-1,d0
	move	d0,angy
	
	lea	tabsinus(pc),a0
	asl	#2,d0
	movem	(a0,d0),d0-d1
	move	vit(pc),d2
	muls	d2,d0
	muls	d2,d1
	swap	d0
	swap	d1
	ext.l	d0
	ext.l	d1
	divs	#100,d0
	divs	#100,d1
	swap	d0
	swap	d1
	move	obsz,d2
	move	obsx,d3
	add	d0,d2
	add	d1,d3
	move	d2,obsz
	move	d3,obsx
	ext.l	d2
	ext.l	d3
	divs	#200,d2
	divs	#200,d3
	swap	d2
	swap	d3
	move	d2,transzobs
	move	d3,transxobs
	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	ec1(pc),a6
	lea	32000(a6),a6
	rept	571
	movem.l	d0-a5,-(a6)
	endr
	movem.l	d0-d5,-(a6)
	
	move	obsy(pc),d0
	move	d0,transyobs
	lea	damier(pc),a0
	bsr	projection
	lea	damier_face(pc),a0
	bsr	affpoly

	move	#500,d0
	add	obsx(pc),d0
	move	#0,d1
	add	obsy(pc),d1
	move	#500,d2
	add	obsz(pc),d2
	movem	d0-d2,transxobs

	lea	vaisseau2(pc),a0
	bsr	projection
	lea	vaisseau_face2(pc),a0
	bsr	affpoly

	move.l	ec1(pc),d0
	move.l	ec2(pc),ec1
	move.l	d0,ec2
	
	move	#-1,-(a7)
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move	#5,-(a7)
	trap	#14
	lea	12(a7),a7

	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	clr.b	$ffff8260.w
	
	move	#$b,-(a7)
	trap	#1
	addq	#2,a7
	tst	d0
	beq	mainloop
	
fin:
	move.b	#7,-(a7)
	trap	#1
	addq	#2,a7
	
	dc.w	$a009
	
	IFNE	SOURIS
	move.l	(a7)+,a0
	move.l	(a7)+,16(a0)
	ENDC

	clr	-(a7)
	trap	#1

ec1	dc.l	ECRAN
ec2	dc.l	ECRAN+32000
xm	dc.w	0
ym	dc.w	0
km	dc.w	0

	IFNE	SOURIS
mouse:
	movem.l	D0/D1/A1,-(A7)
	move.b	(A0),D0
	andi.b	#$f8,D0
	cmpi.b	#$f8,D0
	bne.s	exit
	move.b	(A0),D0
	andi.b	#3,D0
	move.b	D0,km
	move.b	1(A0),D0
	move.b	2(A0),D1
	ext.w	D0
	ext.w	D1
	add.w	D0,xm
	add.w	D1,ym
exit:
	movem.l	(A7)+,D0/D1/A1
	rts
	ENDC

affpoly:
	move	(a0)+,d4
	lea	pxy(pc),a1
	
.loop:
	moveq	#0,d6
	move	#199,d7
	
	pea	(a0)
.loop2:
	move	(a0)+,d2
	move	(a0),d3
	movem	(a1,d2),d0-d1
	movem	(a1,d3),d2-d3
	cmpi	#$8000,d0
	beq.s	.nopoly2
	cmpi	#$8000,d2
	beq.s	.nopoly2
	movem.l	a0/a1/d4,-(sp)
	bsr.s	calcline
	movem.l	(sp)+,d4/a0/a1
	
	tst	2(a0)
	bge.s	.loop2
	
	move.l	(sp)+,a2
	move	(a0)+,d2
	move	(a2),d3
	movem	(a1,d2),d0-d1
	movem	(a1,d3),d2-d3
	cmpi	#$8000,d0
	beq.s	.nopoly
	cmpi	#$8000,d2
	beq.s	.nopoly	
	movem.l	a0/a1/d4,-(sp)
	bsr.s	calcline
	movem.l	(sp)+,a0/a1/d4
	
	addq	#2,a0
	move	(a0)+,d5
	movem.l	a0/a1/d4,-(a7)
	move.l	ec1(pc),a6
	bsr	hline
	movem.l	(a7)+,a0/a1/d4

.jmp:
	dbra	d4,.loop

	rts
.nopoly2:
	addq	#4,a7

.nopoly:
	tst	(a0)+
	bge.s	.nopoly

	addq	#2,a0
	bra.s	.jmp
	
;
; la routine suivante doit etre appel‚e pour calculer les points d'un
;  polygone.
; les points du polygone doivent etre envoy‚s dans l'ordre
;
; entr‚e :
;	d0=x0
;	d1=y0
;	d2=x1
;	d3=y1
;
retline:
	rts
calcline:
	lea	points_gauche(pc),a0
	cmp	d1,d3
	bge.s	.y1supy0
	exg	d1,d3
	exg	d0,d2
	lea	points_droite(pc),a0
.y1supy0
	cmp	#200,d1
	blo.s	.noclipy0
	bge.s	retline
;
; clipping en haut
;
	muls	d3,d0
	move	d2,d4
	muls	d1,d4
	sub.l	d4,d0
	move	d3,d4
	sub	d1,d4
	divs	d4,d0
	clr	d1
.noclipy0
	move	d3,d4
	cmp	#200,d3
	blo.s	.noclipy1
	ble.s	retline
	move	#199,d3
.noclipy1
	cmp	d7,d1	;Ymin
	bge.s	.noymin
	move	d1,d7
.noymin
	cmp	d6,d3
	ble.s	.noymax
	move	d3,d6
.noymax:
	sub	d1,d3
	sub	d0,d2
	sub	d1,d4
	add	d1,d1
	add	d1,a0

	ext.l	d2
	asl.l	#8,d2
	divs	d4,d2
	ext.l	d2
	moveq	#16-8,d4
	asl.l	d4,d2

	neg	d3
	add	#199,d3
	asl	#3,d3
	swap	d0
	jmp	.fastline(pc,d3.w)
.low199
.fastline	rept	199
	add.l	d2,d0
	swap	d0
	move	d0,(a0)+
	swap	d0
	endr
	swap	d0
	move	d0,(a0)+
	rts
;
; Routine d'affichage de droites horizontales
;
; d5 : num‚ro de la couleur
; D6 : Y bas
; D7 : Y haut
; A6 : Adresse de l'ecran

rethline:
	rts
hline:
	cmp	d7,d6
	ble.s	rethline

	cmp	#200,d6
	blo.s	.1
	sge	d6
	ext	d6
	and	#199,d6
.1
	cmp	#200,d7
	blo.s	.2
	sge	d7
	ext	d7
	and	#199,d7
.2

	move.l	#$8b5e8b5e,d2
	move.l	#$8b5e8b5e,d3
	
	lsr	#1,d5
	subx.l	d0,d0
	bcs.s	.pl0
	eor.l	#$cf5e0000^$8b5e0000,d2
.pl0:
	lsr	#1,d5
	subx	d0,d0
	bcs.s	.pl1
	eor	#$cf5e^$8b5e,d2
.pl1:

	lsr	#1,d5
	subx.l	d1,d1
	bcs.s	.pl2
	eor.l	#$cf5e0000^$8b5e0000,d3
.pl2:
	lsr	#1,d5
	subx	d1,d1
	bcs.s	.pl3
	eor	#$cf5e^$8b5e,d3
.pl3:
	movem.l	d2/d3,.automodif1
	movem.l	d2/d3,.automodif2
	movem.l	d2/d3,.automodif3

	move	d7,d2

	sub	d7,d6
	
	mulu	#160,d2
	adda	d2,a6
	
	lea	points_gauche(pc),a0
	add	d7,d7
	adda	d7,a0
	lea	400(a0),a1
	
	move.l	a6,a5
	bra.s	.loopline

.littleline:
	bne.s	.noline
	moveq	#0,d5
	not	d7
	and	#$f,d7
	bset	d7,d5
	subq	#1,d5
	
	moveq	#0,d7
	not	d2
	and	#$f,d2
	bset	d2,d7
	subq	#1,d7
	not	d7
	and	d7,d5

	move	d5,d7
	not	d7
.automodif1:
	move	d7,(a6)+
	move	d7,(a6)+
	move	d7,(a6)+
	move	d7,(a6)+
.noline
	lea	160(a5),a5	;
	dbra	d6,.loopline
	
	rts
	
	
.loopline:
	move	(a0)+,d7
	cmp	#320,d7
	blo.s	.low320
	sge	d7
	ext	d7
	and	#319,d7
.low320
	move	(a1)+,d2

	cmp	#320,d2
	blo.s	.low321
	sge	d2
	ext	d2
	and	#319,d2
.low321
	moveq	#-16,d3
	and	d7,d3
	moveq	#-16,d4
	and	d2,d4

	asr	#1,d3
	asr	#1,d4

	move.l	a5,a6
	move	d3,d5
	adda	d3,a6
	sub	d4,d3
	bge.s	.littleline
	addq	#8,d3

	move	d3,d4
	sub	d5,d4
	addi	#160-16,d4
	asr	#1,d3
	
	moveq	#0,d5
	not	d7
	and	#$f,d7
	bset	d7,d5
	subq	#1,d5
	move	d5,d7
	not	d7
.automodif2:
	move	d7,(a6)+
	move	d7,(a6)+
	move	d7,(a6)+
	move	d7,(a6)+
	
	jmp	.jmp(pc,d3)
	
	rept	20
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	endr
.jmp:

	moveq	#0,d5
	not	d2
	and	#$f,d2
	bset	d2,d5
	subq	#1,d5
	move	d5,d7
	not	d5
.automodif3:
	move	d7,(a6)+
	move	d7,(a6)+
	move	d7,(a6)+
	move	d7,(a6)+

	lea	160(a5),a5
		
	dbra	d6,.loopline
	
	rts
	
;;;;;;;;;;;;---------------------------------
	
genere_sinus
	lea	tabsinus(pc),a0
	moveq	#nbsinus/4-1,d7
	move	#$7fff,cosa	;cos(0)=1
	clr	sina	;sin(0)=0
.loop
	move	cosa,(a0)+
	move	sina,(a0)+

	move	cosa,reg0
	muls	#cos1,reg0
	move	sina,reg1
	muls	#sin1,reg1
	
	muls	#cos1,sina
	muls	#sin1,cosa

	sub.l	reg1,reg0
	add.l	cosa,sina

	move.l	reg0,cosa

	add.l	cosa,cosa
	swap	cosa
	add.l	sina,sina
	swap	sina
	dbra	d7,.loop

	lea	tabsinus,a0
	moveq	#nbsinus/4-1,d2
.loop2
	move	(a0)+,d0
	move	(a0)+,d1
	move	d0,nbsinus*1/4*4-4+2(a0)
	neg	d0
	move	d0,nbsinus*2/4*4-4+0(a0)
	move	d0,nbsinus*3/4*4-4+2(a0)
	move	d1,nbsinus*3/4*4-4+0(a0)
	neg	d1
	move	d1,nbsinus*1/4*4-4+0(a0)
	move	d1,nbsinus*2/4*4-4+2(a0)
	
	dbra	d2,.loop2
	rts

xp	equr	d0
yp	equr	d1
zp	equr	d2

x	equr	d5
y	equr	d6
z	equr	d7

cosx	equr	d3
sinx	equr	a1
cosy	equr	a2
siny	equr	a3
cosz	equr	a4
sinz	equr	a5

;
; a0=ptr sur structure 3D
;
projection:
	move.l	#pxy,ptr
	move	(a0)+,-(sp)
.loop:
	lea	tabsinus(pc),a5
	move	angobx(pc),d0
	asl	#2,d0
	movem	(a5,d0.w),cosx/sinx
	move	angoby(pc),d0
	asl	#2,d0
	movem	(a5,d0.w),cosy/siny
	move	angobz(pc),d0
	asl	#2,d0
	movem	(a5,d0.w),cosz/sinz

; cosx,sinx,cosy,siny,cosz,sinz
	movem	(a0)+,x/y/z
	bsr.s	calcrot

; cosx,sinx,cosy,siny,cosz,sinz
	lea	tabsinus(pc),a5
	move	angx(pc),d0
	asl	#2,d0
	movem	(a5,d0.w),cosx/sinx
	move	angy(pc),d0
	asl	#2,d0
	movem	(a5,d0.w),cosy/siny
	move	angz(pc),d0
	asl	#2,d0
	movem	(a5,d0.w),cosz/sinz

	add	transxobs(pc),x
	add	transyobs(pc),y
	add	transzobs(pc),z
	bsr.s	calcrot

	tst	z
	blt.s	.clipz
	ext.l	x
	ext.l	y
	asl.l	#8,x
	asl.l	#8,y
	divs	z,x
	divs	z,y
	add	#160,x
	neg	y
	add	#100,y

	move.l	ptr(pc),a1
	move	x,(a1)+
	move	y,(a1)+
.jmp:
	move.l	a1,ptr

	subq	#1,(sp)
	bne	.loop
	addq	#2,sp

	rts
	
.clipz:
	move.l	ptr(pc),a1
	move.l	#$80008000,(a1)+
	bra.s	.jmp


mulsub	macro
	move	\2,\1
	muls	\3,\1
	move	\4,d4
	muls	\5,d4
	sub.l	d4,\1
	add.l	\1,\1
	swap	\1
	endm

muladd	macro
	move	\2,\1
	muls	\3,\1
	move	\4,d4
	muls	\5,d4
	add.l	d4,\1
	add.l	\1,\1
	swap	\1
	endm


calcrot:
	mulsub	xp,cosy,x,siny,z
	muladd	zp,siny,x,cosy,z
	move	xp,x
	move	zp,z

	mulsub	xp,cosz,x,sinz,y
	muladd	yp,sinz,x,cosz,y
	move	xp,x
	move	yp,y

	mulsub	yp,cosx,y,sinx,z	;xp=cosx*y+sinx*z
	muladd	zp,sinx,y,cosx,z
	move	yp,y
	move	zp,z

	rts
	
div0:	rte
	
	list
	
	nolist
	
Face3	MACRO
	dc.w	(\1)*4,(\2)*4,(\3)*4,-1,\4
	ENDM
	
Face4	MACRO
	dc.w	(\1)*4,(\2)*4,(\3)*4,(\4)*4,-1,\5
	ENDM

Facei3	MACRO
	dc.w	(\3)*4,(\2)*4,(\1)*4,-1,\4
	ENDM
	
Facei4	MACRO
	dc.w	(\4)*4,(\3)*4,(\2)*4,(\1)*4,-1,\5
	ENDM
	
vaisseau2:
	dc.w	14		;14 points.
*********************
	dc.w	-80,10,-100	;Points No 0
	dc.w	80,10,-100	;Points No 1
	dc.w	80,-8,-100	;Points No 2
	dc.w	-80,-8,-100	;Points No 3
	dc.w	-100,19,-80	;Points No 4
	dc.w	100,19,-80	;Points No 5
	dc.w	-100,-19,-80	;Points No 6
	dc.w	100,-19,-80	;Points No 7
	dc.w	-69,-8,30	;Points No 8
	dc.w	-69,8,30	;Points No 9
	dc.w	67,8,30	;Points No 10
	dc.w	67,-8,30	;Points No 11
	dc.w	-30,-2,86	;Points No 12
	dc.w	30,0,86	;Points No 13

vaisseau_face2:
	dc.w	12		;13 faces.
*********************
	Facei4	3,0,1,2,9
	Facei4	4,5,1,0,5
	Facei4	6,3,2,7,6
	Facei4	6,4,0,3,10
	Facei4	1,5,7,2,10
	Facei4	4,9,10,5,7
	Facei4	7,11,8,6,5
	Facei4	6,8,9,4,8
	Facei4	5,10,11,7,8
	Facei4	11,13,12,8,8
	Facei4	9,12,13,10,8
	Facei3	10,13,11,6
	Facei3	8,12,9,6

TAILDAMIER	=	11
	
damier:
	dc.w	TAILDAMIER*TAILDAMIER
N	set	-5*100
	REPT	TAILDAMIER
	dc.w	N,0,-4*100
	dc.w	N,0,-3*100
	dc.w	N,0,-2*100
	dc.w	N,0,-1*100
	dc.w	N,0,-0*100
	dc.w	N,0,+1*100
	dc.w	N,0,+2*100
	dc.w	N,0,+3*100
	dc.w	N,0,+4*100
	dc.w	N,0,+6*100
	dc.w	N,0,+7*100
N	set	N+100
	ENDR
	
damier_face:
	dc.w	5*10+0*(TAILDAMIER-1)*(TAILDAMIER-1)/4-1
N	set	0
	rept	5
	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+2
	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+2
	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+2
	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+2
	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+4

	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+2
	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+2
	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+2
	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+2
	Face4	N,N+1,N+TAILDAMIER+1,N+TAILDAMIER,1
N	set	N+2
	endr

pal:
algernon:	dc.w	$000
.Blue0:	dc.w	$023,$034,$045,$056
.Red0:	dc.w	$510,$720,$740,$760
.BlueBis:	dc.w	$013,$024,$035,$046
	dc.w	$047,$555,$777
	
	section	bss
	
tabsinus:
	ds.b	nbsinus*4
points_gauche:	ds.w	200
points_droite:	ds.w	200

angx:	ds.w	1
angy:	ds.w	1
angz:	ds.w	1

angobx:	ds.w	1
angoby:	ds.w	1
angobz:	ds.w	1

transxobs:	ds.w	1
transyobs:	ds.w	1
transzobs:	ds.w	1

ptr:	ds.l	1
pxy:	ds.l	128

	ds.b	2048
pile:
