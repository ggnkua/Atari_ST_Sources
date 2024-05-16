	; ------------------------------------------- ;
	;        The maxi-optimyzed 3D Z-rout	 ;
	; (C) 1989-90 Vincent PENNE (Ziggy STARDUST). ;
	; ------------------------------------------- ;
	
	output	3d1.tos
	opt	o+,ow-
	opt	m+
	
 ; #[ Constantes:

TRUE	=	-1
FALSE	=	0

; Parametre systeme
NECR	equ	8
DEBUG	equ	TRUE
BOMB	equ	FALSE

	ifne	DEBUG
	opt	x+
	elseif
	opt	d-,x-
	endc
	
; Variable pour les calculs 3D
TSINUS	equ	1024
DISTEC	equ	32

; Organisation de la palette (Pour l'instant 1 plan par couleur)
COLFOND	equ	$000
TAILPAL	equ	16 	; (Jusqu'a 512!!)
MINCOL	equ	0
MAXCOL	equ	3

; Parametre pour le tracage des lignes horizontales, configuration de l'ecran
NBLIG	equ	200
LECRAN	equ	320
DEPASSE	equ	512
MINX	equ	0
MAXX	equ	320

Vsync	macro
	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	endm

tstcol	macro
	ifne	DEBUG
	tst.b	tcol
	beq.s	nc\@
	move	#\1,$ffff8240.w
nc\@:
	endc
	endm
	
Print	macro
	pea	\1
	move	#9,-(a7)
	trap	#1
	addq	#6,a7	
	endm
	
Flab	macro
a\@:
	endm
	
 ; #] Constantes:
 ; #[ Debut:

debut:
	clr	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq.l	#4,a7
	
	bsr.s	init
	
	jmp	mainloop

 ; #] Debut:
 ; #[ Init:

	; #[ Init_system:
init:
	move.b	#2,$484.w

	bsr	init_hline
	bsr	genere_circle

	move.l	$44e.w,oldec
	
	move.l	#ecran+256,d0
	andi.l	#$ffff00,d0
	lea	ec,a0
	moveq	#NECR-1,d7
.loop:
	move.l	d0,NECR*4(a0)
	move.l	d0,(a0)+
	addi.l	#32000,d0
	dbra	d7,.loop
	move.l	ec,ec1
	
	move	#4,-(a7)
	trap	#14
	addq.l	#2,a7
	move	d0,oldrez
	
	move.b	$ffff8262.w,oldrez_tt

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	
	move	#$2700,sr
	ifne	BOMB
	movem.l	$8.w,d0-d7
	movem.l	d0-d7,oldbomb
	
	lea	$8.w,a0	; Redirection des bombes
	move.l	#fin,d0
	rept	8
	move.l	d0,(a0)+
	endr
	endc
	
	move.l	#trap3,$80+3*4

	bsr	initmfp
	bsr	initmouse
	move	#$2300,sr
	bsr	error_clavier
	
	move.b	ec1+3*4-4+1,$ffff8201.w
	move.b	ec1+3*4-4+2,$ffff8203.w
	
	rts
	
	; #] Init_system:
	; #[ Uninit:
uninit:
	move	#$2700,sr

	ifne	BOMB
	movem.l	oldbomb,d0-d7
	movem.l	d0-d7,$8.w
	endc
	
	move.l	#$08000000,$ffff8800.w
	move.l	#$09000000,$ffff8800.w
	move.l	#$0a000000,$ffff8800.w

	jsr	finmfp	
	
	move	#$2300,sr
	bsr	error_clavier
	
	move	#-1,-(a7)
	move.l	oldec,-(a7)
	move.l	oldec,-(a7)
	move	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	
	move	#$25,-(a7)
	trap	#14
	addq.l	#2,a7

	move.b	oldrez+1,$ffff8260.w
	move.b	oldrez_tt,$ffff8262.w
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.b	#$8,$fffffc02.w
	
	rts
	; #] Uninit:
	
 ; #] Init:
 ; #[ Init/reinstall interupt:
		
initmfp:
	move	sr,-(a7)
	move	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	move	#16,d0
	
savemfp:
	move.b	(a0),(a1)+
	addq.l	#2,a0

	dbra	d0,savemfp
	
	movem.l	$100.w,d0-d7		; On sauvegarde les vecteur MFP
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+$20
	movem.l	$58.w,d0-d7		; Et 68000...
	movem.l	d0-d7,oldvec+$40
	
	bsr.s	finmfp
	
	bclr	#3,$fffffa17.w
	
	move.b	#%00000000,$fffffa07.w
	move.b	#%00000000,$fffffa13.w
	
	move.b	#%01000000,$fffffa09.w
	move.b	#%01000000,$fffffa15.w
	
	move.l	#vbl,$70.w
	move.l	#clavier,$118.w
	
	move	(a7)+,sr
	rts

oldfreq	dc.w	0
	
finmfp:
	move	sr,-(a7)
	move	#$2700,sr

	move.b	$ffff820a.w,oldfreq

	moveq	#0,d1	; Ecran noir
	lea	$ffff8240.w,a0
	moveq	#16/2-1,d0
.noir:
	move.l	d1,(a0)+
	dbra	d0,.noir

	ifne	0
	bsr	waitc
	move.b	#$22,(a0)
	bsr	waitc
	move.b	#$f0,(a0)
	bsr	waitc
	move.b	#$00,(a0)

	reset
	dcb.w	50,$4e71
	tst.b	$fffffc00.w
	dcb.w	10,$4e71
	move.b	#2,$ffff820a.w

	lea	$fffffc02.w,a0
	
	move.b	#$03,$fffffc00.w
	move.b	#$96,$fffffc00.w
	
	move	#4-1,d0
.wait1:
	move	#20000-1,d1
.wait2:
	dbra	d1,.wait2
	dbra	d0,.wait1

	move.l	#$0700c000,$ffff8800.w	; Reinitialise drive
	move.l	#$0e000700,$ffff8800.w
	
	endc
	
	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	move	#16,d0
	
restmfp:

	move.b	(a0)+,(a1)
	addq.l	#2,a1

	dbra	d0,restmfp
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58.w

	btst.b	#1,oldfreq
	beq.s	.ok
	Vsync
	clr.b	$ffff820a.w
	Vsync
	move.b	#2,$ffff820a.w
.ok:

	move	(a7)+,sr
	rts
	
	section	bss
	
oldvec	ds.l	24
oldmfp	ds.b	24

	section	text
	
 ; #] Init/reinstall interupt:
 ; #[ Clavier interupt:

ABSOLUTE_MOUSE	=	TRUE
	; #[ Interuption:
clavier:
	btst	#0,$fffffc00.w
	beq.s	noclav
	
	move	d0,-(a7)

	clr	d0
	move.b	$fffffc02.w,d0
	
	ifne	ABSOLUTE_MOUSE
	cmpi.b	#$f7,d0
	beq.s	absolute_mouse_1
	endc
	
	move.l	a0,-(a7)
	bclr	#7,d0
	lea	clav(pc),a0
	seq	(a0,d0)
	move.l	(a7)+,a0

	move	(a7)+,d0
noclav:
	rte
	
	ifne	ABSOLUTE_MOUSE
absolute_mouse_1:
	move.l	#absolute_mouse_2,$118.w
	move	(a7)+,d0
	rte

absolute_mouse_2:
	btst	#0,$fffffc00.w
	beq.s	noclav
	
	move	d0,-(a7)
	
	move.b	$fffffc02.w,d0
	beq.s	.finclav
	
	btst	#0,d0
	beq.s	.er
	bset	#0,mousek
	bra.s	.finclav
.er:
	btst	#1,d0
	beq.s	.rr
	bclr	#0,mousek
	bra.s	.finclav
.rr:

	btst	#2,d0
	beq.s	.el
	bset	#1,mousek
	bra.s	.finclav
.el:
	btst	#3,d0
	beq.s	.rl
	bclr	#1,mousek
.rl:

.finclav:
	move	(a7)+,d0

	move.l	#absolute_mouse_3,$118.w
	rte
	
absolute_mouse_3:
	btst	#0,$fffffc00.w
	beq.s	noclav
	move.b	$fffffc02.w,cmousex

	move.l	#absolute_mouse_4,$118.w
	rte
	
absolute_mouse_4:
	btst	#0,$fffffc00.w
	beq	noclav
	move.b	$fffffc02.w,cmousex+1

	move.l	#absolute_mouse_5,$118.w
	rte
	
absolute_mouse_5:
	btst	#0,$fffffc00.w
	beq	noclav
	move.b	$fffffc02.w,cmousey

	move.l	#absolute_mouse_6,$118.w
	rte
	
absolute_mouse_6:
	btst	#0,$fffffc00.w
	beq	noclav
	move.b	$fffffc02.w,cmousey+1
	
	move	cmousex,mousex
	move	cmousey,mousey

	move.l	#clavier,$118.w
	rte
	endc
	; #] Interuption:
	; #[ Init mouse:

clav	ds.b	128
mouse_maxx	dc.w	MAXX
mouse_maxy	dc.w	NBLIG
cmousex	dc.w	0
cmousey	dc.w	0
mousex	dc.w	MAXX/2
mousey	dc.w	NBLIG/2
mousek	dc.b	0
	even
	
initmouse:
	lea	$fffffc02.w,a0

	ifne	ABSOLUTE_MOUSE
	bsr.s	waitc	; Set mouse limit
	move.b	#$09,(a0)
	bsr.s	waitc
	move.b	mouse_maxx,(a0)
	bsr.s	waitc
	move.b	mouse_maxx+1,(a0)
	
	bsr.s	waitc
	move.b	mouse_maxy,(a0)
	bsr.s	waitc
	move.b	mouse_maxy+1,(a0)
	
	bsr.s	waitc	; Set mouse position
	move.b	#$0e,(a0)
	bsr	waitc
	clr.b	(a0)
	bsr.s	waitc
	move.b	mousex,(a0)
	bsr.s	waitc
	move.b	mousex+1,(a0)
	bsr.s	waitc
	move.b	mousey,(a0)
	bsr.s	waitc
	move.b	mousey+1,(a0)
	
	elseif
	bsr.s	waitc
	move.b	#$08,(a0)
	
	endc
	
	bsr	error_clavier
	
	rts
	
waitc:
	btst	#1,$fffffc00.w
	beq.s	waitc
	rts
	
error_clavier:
	btst	#5,$fffffc00.w
	beq.s	.noerror
	
	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff
	
	tst.b	$fffffc02.w
	bra.s	error_clavier
.vidbuff:

	rts
	; #] Init mouse:
	; #[ Test touche:
	
Touche_objet	macro
	tst.b	\1(a0)
	beq.s	.\@
	
	move.l	\2,curobj
.\@
	endm
	
VITEZOOM	equ	2
	
test_touche:
	btst	#0,mousek
	beq.s	.no
	addi	#VITEZOOM,oz
.no:
	Flab
	btst	#1,mousek
	beq.s	.no
	subi	#VITEZOOM,oz
.no:
	
	lea	clav(pc),a0
	
	Flab
	tst.b	$4e(a0)	; '+'?
	beq.s	.no
	addi	#VITEZOOM,oz
.no:
	Flab
	tst.b	$4a(a0)	; '-'?
	beq.s	.no
	subi	#VITEZOOM,oz
.no:
	Flab
	tst.b	$72(a0)	; <Enter>?
	beq.s	.no
	addi	#VITEZOOM*10,oz
.no:
	Flab
	tst.b	$66(a0)	; '*'?
	beq.s	.no
	subi	#VITEZOOM*10,oz
.no:
	Flab
	tst.b	$1(a0)	; <Esc>?
	beq.s	.no
	illegal
.no:
	Flab
	tst.b	$39(a0)	; <Espace>?
	beq.s	.no
	jmp	fin
.no:
	Flab
	tst.b	59(a0)	; <F1>?
	beq.s	.no
	st	$f(a0)
.no:
	Flab
	tst.b	60(a0)	; <F2>?
	beq.s	.no
	st	qaffn
.no:
	Flab
	tst.b	61(a0)	; <F3>?
	beq.s	.no
	sf	qaffn
	move	#NECR,neffecr
.no:
	Flab
	sf	tcol
	tst.b	$f(a0)	; <Tab>?
	beq.s	.no

	st	tcol	
.no:

	Flab
	tst.b	$68(a0)	; "8"?
	beq.s	.no
	addq	#1,va
.no:
	Flab
	tst.b	$6E(a0)	; "2"?
	beq.s	.no
	subq	#1,va
.no:
	Flab
	tst.b	$6C(a0)	; "6"?
	beq.s	.no
	addq	#1,vb
.no:
	Flab
	tst.b	$6A(a0)	; "4"?
	beq.s	.no
	subq	#1,vb
.no:
	Flab
	tst.b	$69(a0)	; "9"?
	beq.s	.no
	addq	#1,vg
.no:
	Flab
	tst.b	$6D(a0)	; "1"?
	beq.s	.no
	subq	#1,vg
.no:
	Flab
	tst.b	$0E(a0)	; <Backspace>?
	beq.s	.no
	clr	va
	clr	vb
	clr	vg
.no:

	Touche_objet	2,#obj1
	Touche_objet	3,#obj2
	Touche_objet	4,#obj3
	Touche_objet	5,#obj4
	Touche_objet	6,#obj5
	Touche_objet	7,#obj6
	
	rts
	; #] Test touche:

 ; #] Clavier interupt:
 ; #[ Supervisor/User mode:
 
trap3:		; Pour passer en superviseur rapidement
	move	#$2300,(a7)
	rte
	
retour:
	move.l	oldpile(pc),a7
	trap	#3
	rts
	
oldpile	dc.l	0
	
 ; #] Supervisor/User mode:

 ; #[ Forme 3D:

	; #[ Datas:
		* Position de l'observateur --->
		
oa	dc.w	0	* Angle Alpha
ob	dc.w	0	* Beta
og	dc.w	0	* et Gamma...
oba	dc.w	0
obb	dc.w	0
obg	dc.w	0

ox	dc.w	0
oy	dc.w	0
oz	dc.w	-272
*cz	dc.w	800
cz	dc.w	0

va	dc.w	-3
vb	dc.w	6
vg	dc.w	-9
	
cab	ds.w	1
cbb	ds.w	1
cgb	ds.w	1
sab	ds.w	1
n2:
sbb	ds.w	1
sgb	ds.w	1

obx	ds.w	1
oby	ds.w	1
obz	ds.w	1

m1	ds.w	1
m2	ds.w	1
m3	ds.w	1
n1	ds.w	1
n3	ds.w	1
o1	ds.w	1
o2	ds.w	1
o3	ds.w	1

limx1	ds.w	1
limx2	ds.w	1
limy1	ds.w	1
limy2	ds.w	1

zoom	dc.w	192	* Valeur du zoom

ncplt	dc.w	1

table:
	incbin	table2
	even
	; #] Datas:
	; #[ Quelques macros...:
Tstx	macro

	cmpi	#-DEPASSE+1,\1
	bgt.s	.dep1\@

	move	#-DEPASSE+1,\1
.dep1\@:

	cmpi	#DEPASSE-1+LECRAN,\1
	blt.s	.dep2\@
	
	move	#DEPASSE-1+LECRAN,\1
.dep2\@:

	cmp	limx1(pc),\1
	bge.s	.l1\@
	move	\1,limx1
.l1\@:
	cmp	limx2(pc),\1
	ble.s	.l2\@
	move	\1,limx2
.l2\@:
	endm
	
Tsty	macro
	cmp	limy1(pc),\1
	bge.s	.l1\@
	move	\1,limy1
.l1\@:
	cmp	limy2(pc),\1
	ble.s	.l2\@
	move	\1,limy2
.l2\@:
	endm
	
Next	macro
	move.l	(a1)+,a0
	jmp	(a0)
	endm
	
	; #] Quelques macros...:

	even
afforme:
	tstcol	$500
	movem.l	d0-d7/a0-a6,-(a7)
	
	; #[ Init matrice:
	move	-12(a6),obx
	move	-10(a6),oby
	move	-8(a6),obz
	move	ox(pc),d0
	sub	d0,obx
	move	oy(pc),d0
	sub	d0,oby
	move	oz(pc),d0
	sub	d0,obz
	
	lea	table+TSINUS/2(pc),a1	; Table des sinus...
	lea	table(pc),a2		; et des cosinus
	
	move	-6(a6),d0
	add	d0,d0
	move	(a1,d0),sab
	move	(a2,d0),cab

	move	-4(a6),d0
	add	d0,d0
	move	(a1,d0),sbb
	move	(a2,d0),cbb

	move	-2(a6),d0
	add	d0,d0
	move	(a1,d0),sgb
	move	(a2,d0),cgb
	
			; Preparation matrice
	move	sab(pc),d0
	muls	cgb(pc),d0
	move	cab(pc),d1
	muls	sbb(pc),d1
	add.l	d1,d1
	swap	d1
	muls	sgb(pc),d1
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,m1
	
	move	cab(pc),d0
	muls	cbb(pc),d0
	add.l	d0,d0
	swap	d0
	move	d0,m2
	
	move	sab(pc),d0
	muls	sgb(pc),d0
	move	cab(pc),d1
	muls	sbb(pc),d1
	add.l	d1,d1
	swap	d1
	muls	cgb(pc),d1
	sub.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,m3
	
	move	cbb(pc),d0
	muls	sgb(pc),d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,n1
	
	move	cbb(pc),d0
	muls	cgb(pc),d0
	add.l	d0,d0
	swap	d0
	move	d0,n3
	
	move	cab(pc),d0
	muls	cgb(pc),d0
	move	sab(pc),d1
	muls	sbb(pc),d1
	add.l	d1,d1
	swap	d1
	muls	sgb(pc),d1
	sub.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,o1
	
	move	sab(pc),d0
	muls	cbb(pc),d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,o2
	
	move	cab(pc),d0
	muls	sgb(pc),d0
	move	sab(pc),d1
	muls	sbb(pc),d1
	add.l	d1,d1
	swap	d1
	muls	cgb(pc),d1
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,o3
	
	lea	plot,a0
	move.l	-16(a6),a1
	move	(a1)+,d0		; Nombre de points
	subq	#1,d0
	lea	tplot,a3
	; #] Init matrice:
	; #[ Calcul points 3d:
	move	max(pc),limx1
	move	mix(pc),limx2
	move	may(pc),limy1
	move	miy(pc),limy2
	
*	not	$ffff8240
	tstcol	$50
	
calcplot:
	movem	(a1)+,d2-d4
	
			; Rotation autour du centre de l'objet
	; Rotation X
	move	d2,d6
	muls	m1(pc),d6
	move	d3,d5
	muls	m2(pc),d5
	add.l	d5,d6
	move	d4,d5
	muls	m3(pc),d5
	add.l	d5,d6
	add.l	d6,d6
	swap	d6
	
	; Rotation Y
	move	d3,d7
	muls	n2(pc),d7
	move	d2,d5
	muls	n1(pc),d5
	add.l	d5,d7
	move	d4,d5
	muls	n3(pc),d5
	add.l	d5,d7
	add.l	d7,d7
	swap	d7

	; Rotation Z
	muls	o3(pc),d4
	move	d2,d5
	muls	o1(pc),d5
	add.l	d5,d4
	move	d3,d5
	muls	o2(pc),d5
	add.l	d5,d4
	add.l	d4,d4
	swap	d4
	
	move	d6,d2
	move	d7,d3
		
				; On ramene aux coordon‚e de l'obs	
	add	obx(pc),d2
	add	oby(pc),d3
	add	obz(pc),d4
	neg	d3
	
	move	d2,(a3)+
	move	d3,(a3)+
	move	d4,(a3)+
	
	cmpi	#DISTEC,d4	; Z inf‚rieur … DISTEC?
	bgt.s	ok3d		; Oui
	
	addq.l	#4,a0
	bra	c3d
	
ok3d:				; 3D vers 2D --->	
	; Avec ZOOM = 192
	; (X * ZOOM) / Z + CX
	
	ext.l	d2
	asl.l	#6,d2
	move.l	d2,d7
	add.l	d2,d7
	add.l	d7,d2
	divs	d4,d2
	add	cx,d2
	
	Tstx	d2
	move	d2,(a0)+
	
	
	; (Y * ZOOM) / Z + CY
	
	ext.l	d3
	asl.l	#6,d3
	move.l	d3,d7
	add.l	d3,d7
	add.l	d7,d3
	divs	d4,d3
	add	cy,d3
	move	d3,(a0)+
	
	cmp	ty1,d3
	bgt.s	.okty1
	
	move	d3,ty1
.okty1:

	cmp	ty2,d3
	blt.s	.okty2
	
	move	d3,ty2
.okty2:
	
	Tsty	d3
	
c3d:
	dbra	d0,calcplot
	; #] Calcul points 3d:

	lea	plot,a0

	move.l	(a1)+,a0
	jmp	(a0)

fin_afforme:
	; #[ Set limit and used plane:
	move.l	curlim,a0
	
	move	limx1,d0
	cmp	mix(pc),d0
	bge.s	.1
	move	mix(pc),d0
.1:
	move	d0,(a0)+
	
	move	limx2,d0
	cmp	max(pc),d0
	ble.s	.2
	move	max(pc),d0
.2:
	move	d0,(a0)+
	
	move	limy1,d0
	cmp	miy(pc),d0
	bge.s	.3
	move	miy(pc),d0
.3:
	move	d0,(a0)+
	
	move	limy2,d0
	cmp	may(pc),d0
	ble.s	.4
	move	may(pc),d0
.4:
	move	d0,(a0)+
	
	move.b	used_plane,(a0)+
	
	; #] Set limit and used plane:
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	
init_color:
	; #[ Init color:
	moveq	#MINCOL,d6
	lea	dispal(pc),a6
	rept	TAILPAL
	move.b	#-1,(a6)+
	endr
	move	ncplt(pc),d1
	lea	dispal(pc),a6
	adda	d1,a6
	sf	(a6)
	move.l	affpal(pc),a6
	move	#COLFOND,(a6)+	; Couleur 0 = couleur de fond
	move.l	curpal,a4
	add	d1,d1
	move	(a4,d1),(a6)+
	
	Next
	; #] Init color:

face1p:
	: #[ Init_face
	move	(a1)+,colorpoly ; Couleur de la face N
	blt	fin_face
	move.l	#,curline	 ; Type de remplissage face N
	
	Next
	
	; #] Init_face

vertices:
	; #[ Vertices:
	
	move.l	a1,a5
	lea	tplot,a4
	lea	pxy,a2
	moveq	#0,d7
	
		;#[ Get plot and test with screen:
.loop_plot:
	move	(a1)+,d0	; --> No points
	blt	.fin_plot
	move	d0,d3
	add	d0,d3
	add	d0,d3
	add	d3,d3	; No point * 6 dans D3
	
	cmpi	#DISTEC,4(a4,d3) ; Point derriere ecran?
	bgt	.okscreen	; Non
			; Oui --> calcul intersection
		;#[ Calcul screen intersection:	
	move	-4(a1),d4
	cmpa.l	a5,a1	; Premier point?
	bgt.s	.nofirstp	; Non
	
	move.l	a1,a3
.find_end:
	addq	#2,a3
	tst	(a3)
	bge.s	.find_end
	
	move	-2(a3),d4
.nofirstp:
	move	d4,d2
	add	d4,d2
	add	d4,d2
	add	d2,d2		; * 6
	cmpi	#DISTEC,4(a4,d2)
	ble	.badp1
	
		; cx + zoom * (x + ((xx - x) * (DISTEC - z)) / (zz - z)) / 10
	move	(a4,d3),d4
	sub	(a4,d2),d4
	move	#DISTEC,d5
	sub	4(a4,d2),d5
	muls	d5,d4
	move	4(a4,d3),d5
	sub	4(a4,d2),d5
	divs	d5,d4
	add	(a4,d2),d4
	muls	zoom,d4
	divs	#DISTEC,d4
	add	cx,d4
	
	Tstx	d4
	
	move	d4,(a2)+
		; cy + zoom * (y + ((yy - y) * (DISTEC - z) / (zz - z)) / 10
	move	2(a4,d3),d4
	sub	2(a4,d2),d4
	move	#DISTEC,d5
	sub	4(a4,d2),d5
	muls	d5,d4
	move	4(a4,d3),d5
	sub	4(a4,d2),d5
	divs	d5,d4
	add	2(a4,d2),d4
	muls	zoom,d4
	divs	#DISTEC,d4
	add	cy,d4
	
	Tsty	d4
	
	move	d4,(a2)+
	
	addq	#1,d7
	
.badp1:
	move	(a1),d5
	bgt.s	.nolastp		; Si dernier points
	move	(a5),d5
.nolastp:
	move	d5,d2
	add	d5,d2
	add	d5,d2
	lsl	#1,d2		; * 6
	cmpi	#DISTEC,4(a4,d2)
	ble	.badp2
	
		; cx + zoom * (x + ((xx - x) * (DISTEC - z)) / (zz - z)) / 10
	move	(a4,d3),d4
	sub	(a4,d2),d4
	move	#DISTEC,d5
	sub	4(a4,d2),d5
	muls	d5,d4
	move	4(a4,d3),d5
	sub	4(a4,d2),d5
	divs	d5,d4
	add	(a4,d2),d4
	muls	zoom,d4
	divs	#DISTEC,d4
	add	cx,d4
	
	Tstx	d4
	
	move	d4,(a2)+
		; cy + zoom * (y + ((yy - y) * (DISTEC - z) / (zz - z)) / 10
	move	2(a4,d3),d4
	sub	2(a4,d2),d4
	move	#DISTEC,d5
	sub	4(a4,d2),d5
	muls	d5,d4
	move	4(a4,d3),d5
	sub	4(a4,d2),d5
	divs	d5,d4
	add	2(a4,d2),d4
	muls	zoom,d4
	divs	#DISTEC,d4
	add	cy,d4
	
	Tsty	d4
	
	move	d4,(a2)+
	
	addq	#1,d7
	
.badp2:
	bra	.loop_plot
		;#] Calcul screen intersection:	
.okscreen:
	lsl	#2,d0
	move.l	(a0,d0),(a2)+
	addq	#1,d7

	bra	.loop_plot
.fin_plot:
		;#] Get plot and test with screen:

	Next
	; #] Vertices:

hide:
	; #[ Test face visibility:
	addq	#8,a1
	
	move.l	-4(a2),d2
	move	d2,d3
	swap	d2
	move.l	pxy,(a2)
	lea	pxy,a2
	move	d2,-4(a2)
	move	d3,-2(a2)

	move	-4(a2),d3
	move	4(a2),d1
	
	sub	(a2),d3
	sub	(a2),d1
	
	move	6(a2),d2
	sub	2(a2),d2
	muls	d2,d3
	
	move	-2(a2),d2
	sub	2(a2),d2
	muls	d2,d1
	
	cmp.l	d3,d1		; Face visible?
	bgt.s	.ok		; Non --> Ok

	addq	#2,a1
	Next
	
.ok:
	add	(a1),a1
	Next

	; #] Test face visibility:

set_color:
	; #[ Select color:
		
	move	colorpoly,d0
	lea	dispal(pc),a2
	tst.b	(a2,d0)
	bge.s	.okcol
	
	cmpi	#MAXCOL,d6
	blt.s	.nomaxcol
	
	move.b	#MAXCOL,(a2,d0)
	bra.s	.okcol
	
.nomaxcol:
	addq	#1,d6
	move.b	d6,(a2,d0)
	move	d6,d2
	
	cmpi.b	#4-1,d6
	bne.s	.col1
	move	#8-1,d2
.col1:
	
	cmpi.b	#3-1,d6
	bne.s	.col2
	move	#4-1,d2
.col2:

	move.l	curpal,a2
	move	d0,d3
	add	d3,d3
	move	(a2,d3),d3
.copal:
	move	d3,(a6)+
	dbra	d2,.copal
	
	lea	dispal(pc),a2
	
	move.b	(a2,d0),d2
	ext	d2
	move	d2,colorpoly
	bset	d2,used_plane
	
	Next
	
.okcol:
	move.b	(a2,d0),d2
	ext	d2
	move	d2,colorpoly
	
	Next
	
	; #] Select color:
	
call_poly:
	; #[ Affpoly:
	cmpi	#3,d7
	blt	loopface
	
	movem.l	d6/a0/a1/a3/a6,-(a7)
	lea	pxy,a6
	bsr	affpoly
	movem.l	(a7)+,d6/a0/a1/a3/a6
	
	; #] Affpoly:
	Next

 ; #] Forme 3D:
 ; #[ Affpoly:

	; #[ Datas:
		* Fenetre de clipping --->
mix	dc.w	MINX
miy	dc.w	0
max	dc.w	MAXX-1
may	dc.w	NBLIG-1

		* Centre de l'‚cran   --->
cx	dc.w	160
cy	dc.w	100-4

curcol	dc.w	0
curpal	dc.l	pal2
palette:
	incbin	palette.pal
pal2:
	dc.w	0,$333,$444,$555,$666,$330,$550,$770,$700,$500,$007,$005,$500,$700,$770
	;	0   1    2    3    4    5    6    7    8    9    10   11   12   13   14
	even
dispal	ds.b	TAILPAL
	even
affpal	dc.l	palette
	; #] Datas:

	; #[ Affpoly:
affpoly:
	tstcol	$5

	move	d7,d0
	move.l	a6,a0
	subq	#2,a0
	move	#32767,d1
	subq	#1,d0
searchight:
	addq.l	#4,a0
	cmp	(a0),d1
	blt.s	toolow
	move	d0,d6
	move	(a0),d1
toolow:
	dbra	d0,searchight
	
	neg	d6
	add	d7,d6		* Dans D6, No du point le plus haut.
	subq	#1,d6

	add	d6,d6	
	add	d6,d6
	move.l	a6,a0
	adda	d6,a0		* Dans A0, adresse du point le plus haut.
	move	2(a0),miny	* Dans miny, point le plus haut
	
	move	d7,d0
	add	d0,d0
	add	d0,d0
	move.l	a6,a5
	adda	d0,a5		* Dans A5, Adresse du dernier point.
	
	lea	tpxy1,a1		* tbxy1, table des points gauches.
	lea	tpxy2,a2		* tbxy1, table des points droits.
*	bra	rightplot.s
*leftplot:
*	lea	tpxy2,a1		* tbxy1, table des points droits.
*	lea	tpxy1,a2		* tbxy1, table des points gauches.
rightplot:

	move	#-32768,d1
	move.l	a0,a4
	move	d7,d6
copleft:
	move	(a4)+,(a2)+
	move	(a4)+,d0		* Valeur y du point.
	cmp	d1,d0
	blt.s	fcopleft
	move	d0,d1
	move	d0,(a2)+
	
	subq	#1,d6
	blt	nopoly
	cmp.l	a5,a4
	blt.s	copleft
	
	move.l	a6,a4
	
	bra.s	copleft
fcopleft:
	move	#32000,-2(a2)
	move	#32000,(a2)
	
	move	#-32767,d1
	lea	4(a0),a4
copright:
	move	-(a4),d0	* Valeur y du point.
	move	-(a4),(a1)+
	cmp	d1,d0
	blt.s	fcopright
	move	d0,d1
	move	d0,(a1)+
	
	cmp.l	a6,a4
	bgt.s	copright

	move.l	a5,a4
	
	bra.s	copright
	
fcopright:
	move	#32000,-2(a1)
	move	#32000,(a1)
	move	-4(a1),maxy
	
	lea	tpxy1,a0
	lea	tpxy2,a1
	
	move	miny,d0	; miny-->D0
	move	miy,d2	; miy-->D2
	cmp	d2,d0	; Miny plus petit que miy?
	bge.s	cnegaplot	; Non
	move	d2,d0
	move	d2,miny
	
cnegaplot:
	cmp	maxy,d0
	bge	nopoly

	move	d0,d7
	lsl	#1,d7
	lea	points_gauche,a2
	lea	(a2,d7),a2	; A2 = adresse du premier point gauche
	lea	points_droite,a3
	lea	(a3,d7),a3	; A3 = adresse du premier point droit
	move.l	a2,a4
	move.l	a3,a5
	move	may,d7
	cmp	miny,d7
	blt	nopoly
	
	bsr.s	new_plot

	move.l	a1,a0
	move.l	a3,a2
	move	miny,d0
	
	bsr.s	new_plot
	
	move	d0,d1
	move	miny,d0
	sub	d0,d1
	move	colorpoly,d2
	move.l	ec1,a6
	add	d2,d2
	adda	d2,a6
	
	tstcol	$050	

	move.l	curline,a0
	bsr	call_line

nopoly:
	tstcol	$500
	rts
	; #] Affpoly:
	; #[ Calcul plot:
new_plot:
	movem	(a0),d1-d4	; X1 Y1 X2 Y2
	add	d1,d1
	add	d1,d1
	add	d3,d3
	add	d3,d3
	addq	#4,a0
	cmp	d0,d4	; Y2 superieur a D0?
	blt.s	new_plot
	cmp	d4,d2	; Pour eviter la division par 0...
	bge.s	new_plot
	move	d4,d6
	cmp	d7,d6	; Point plus bas que may?
	blt.s	oklow	; Non
	move	d7,d6
	addq	#1,d6
oklow:
	cmpi	#32000,d4	; Dernier point?
	beq	fin_plot	; On sort
	cmp	d7,d0	; Depasser may?
	bgt	fin_plot	; On sort.
	
	sub	d1,d3
	sub	d2,d4

	move	d0,d5	; On cherche X de d‚part par rapport … D0
	sub	d2,d5
	cmp	miy(pc),d2
	bge.s	noclip
	muls	d3,d5
	divs	d4,d5
noclip:
	add	d5,d1

	ext.l	d3
	lsl.l	#5,d3
	divs	d4,d3
	ext.l	d3
	asl.l	#8,d3
	asl.l	#3,d3
	
	sub	d6,d0
	bge	nobord
	addi	#NBLIG,d0
	add	d0,d0	; * 4
	swap	d1
	move	d3,d1
	beq	fast_plot
	addi	#$8000,d1
	swap	d1
	swap	d3
	add	d0,d0
	jmp	calc_plot(pc,d0)
	
calc_plot:
	dcb.l	NBLIG-1,$34c1d383
;	rept	NBLIG-1
;	move	d1,(a2)+
;	addx.l	d3,d1
;	endr
	move	d1,(a2)+
	
	ifne	DEBUG*0
	cmp	(a0),d1
	bne.s	nobord
	
	not	$ffff8240
	endc
nobord:
	move	d6,d0
	
	bra	new_plot
	
fin_plot:
	rts
	
fast_plot:
	swap	d1
	swap	d3
	
	beq	very_fast_plot
	
	add	d0,d0
	jmp	calc_fplot(pc,d0)
	
calc_fplot:
	dcb.l	NBLIG,$34c1d243
;	rept	NBLIG
;	move	d1,(a2)+
;	add	d3,d1
;	endr
	
	move	d6,d0
	
	bra	new_plot
	
very_fast_plot:

	jmp	calc_fplot2(pc,d0)
	
calc_fplot2:
	dcb.w	NBLIG,$34c1
;	rept	NBLIG
;	move	d1,(a2)+
;	endr
	
	move	d6,d0
	
	bra	new_plot
	; #] Calcul plot:

 ; #] Affpoly:

 ; #[ Very fast horizontal line:
 
	; #[ Calling rout:

; ************************************************************************ ;
; 	     Appel routine de tracage horizontal		;
;	           (Gere le clipping en Y)		;
; ************************************************************************ ;
; A0 : Routine a appele
; A6 : Adresse ecran
; D0 : Position Y
; D1 : Nbr de ligne a afficher

curline	dc.l	hline_one_plane

call_line:
	tst	d1
	blt.s	.noaff

	tst	d0
	bge.s	.ok

	add	d0,d1
	tst	d1
	blt	.noaff
	
	clr	d0
.ok:

	move	d0,d2
	add	d1,d2
	cmpi	#NBLIG,d2
	blt.s	.ok2
	
	move	#NBLIG,d1
	sub	d0,d1
.ok2:

	move	d0,d3
	add	d3,d3
	lea	points_gauche,a4
	adda	d3,a4
	lea	points_droite,a5
	adda	d3,a5
	
	lsl	#4,d3
	move	d3,d2
	add	d3,d3
	add	d3,d3
	add	d2,d3
	adda	d3,a6
	move	d1,d7	; * 160
	
	jmp	(a0)
	
.noaff:
	rts
	
; ************************************************************************ ;
;	       Tracage de ligne horizontal 1 plan.		;
; ************************************************************************ ;
; A4: Table des points gauches
; A5:   "    "    "    droits
; A6: Adresse ecran
; D7: Nombre le ligne en hauteur

; ************ ;	
; Non tram‚es: ;
; ************ ;
hline_one_plane:
	moveq	#$ffffffff,d5
	lea	ldecal,a1
	lea	rdecal,a2
	lsl	#7,d7 ; La routine fait 128 octets
	neg	d7
	lea	phline2,a3
	jmp	(a3,d7)

; ******** ;
; tram‚es: ;
; ******** ;
hline_one_plane_tramed:
	move.l	#$aaaaaaaa,d5
	btst	#0,d0
	beq.s	.ok
	not	d5
.ok:
	lea	ldecal,a1
	lea	rdecal,a2
	lsl	#3,d7
	move	d7,d0
	lsl	#4,d7
	add	d0,d7 ; La routine fait 136 octets
	neg	d7
	lea	phlinet2,a3
	jmp	(a3,d7)
	; #] Calling rout:
	; #[ One plane:	(128 octets)
hline2:	
	moveq	#-4,d0
	and	(a4)+,d0
	moveq	#-4,d1
	and	(a5)+,d1
	
	move.l	(a1,d0),d0
	move.l	(a2,d1),d1
	
	sub	d1,d0
	bge.s	little_line

	move.l	a6,a0
	adda	d1,a0
	swap	d1
	or	d1,(a0)
	adda	d0,a0

	asr	#1,d0
	jmp	loopline+4(pc,d0)

little_line:
	bne.s	nohline
	
	and.l	d1,d0
	swap	d0
	or	d0,(a6,d1)
	bra.s	nohline
	
N	set	(LECRAN-32)/2
	rept	(LECRAN-32)/16
	move	d5,N(a0)
N	set	N-8
	endr

loopline:
	swap	d0
	or	d0,(a0)
nohline:
	lea	160(a6),a6
	
hline1:
	; #] One plane:
	; #[ One plane tramed:	(136 octets)
hline_tramed2:
	moveq	#-4,d0
	and	(a4)+,d0
	moveq	#-4,d1
	and	(a5)+,d1
	
	move.l	(a1,d0),d0
	move.l	(a2,d1),d1
	
	sub	d1,d0
	bge.s	.little_line

	move.l	a6,a0
	adda	d1,a0
	swap	d1
	and	d5,d1
	or	d1,(a0)
	adda	d0,a0

	asr	#1,d0
	jmp	.loopline+4(pc,d0)

.little_line:
	bne.s	.nohline
	
	and.l	d1,d0
	swap	d0
	and	d5,d0
	or	d0,(a6,d1)
	bra.s	.nohline
	
N	set	(LECRAN-32)/2
	rept	(LECRAN-32)/16
	move	d5,N(a0)
N	set	N-8
	endr

.loopline:
	swap	d0
	and	d5,d0
	or	d0,(a0)
.nohline:
	not	d5
	lea	160(a6),a6
	
hline_tramed1:
	; #] One plane tramed:
	; #[ Genere hline:
bord:
	dc	%111111111111111,%11111111111111,%1111111111111,%111111111111,%11111111111,%1111111111,%111111111,%11111111,%1111111,%111111,%11111,%1111,%111,%11,%1,0

init_hline:
	lea	phline,a1	; Pregenere les lignes 1 plan
	move	#NBLIG-1,d0
.lphline:
	lea	hline2,a0
	move	#(hline1-hline2)/2-1,d1
.lphline2:
	move	(a0)+,(a1)+

	dbra	d1,.lphline2

	dbra	d0,.lphline
	
	move	#$4e75,(a1)+

	Flab
	lea	phlinet,a1	; Pregenere les lignes 1 plan tram‚es
	move	#NBLIG-1,d0
.lphline:
	lea	hline_tramed2,a0
	move	#(hline_tramed1-hline_tramed2)/2-1,d1
.lphline2:
	move	(a0)+,(a1)+

	dbra	d1,.lphline2

	dbra	d0,.lphline
	
	move	#$4e75,(a1)+

	lea	ldecal,a0		; Precalcul le bord des lignes H
	lea	rdecal,a2
	move	#0,d2
	move	#0,d3
	move	#LECRAN/16-1,d0
decal1:
	lea	bord,a1
	move	#15,d1
decal2:
	move	(a1)+,d7
	move	d7,(a0)+
	move	d2,(a0)+
	
	not	d7
	bne.s	.pazero

	move	#-1,(a2)+
	subq	#8,d3
	move	d3,(a2)+
	addq	#8,d3
	bra.s	.zero
.pazero
	move	d7,(a2)+
	move	d3,(a2)+
.zero	
	dbra	d1,decal2
	addq	#8,d2
	addq	#8,d3

	dbra	d0,decal1
	
	lea	ldecal-DEPASSE*4,a0 ; Precalcul pour le cliping en X
	lea	rdecal-DEPASSE*4,a1
	move	#DEPASSE+MINX-1,d0
.ld:
	move.l	#$7fff0000+MINX/2,(a0)+
	move.l	#$7fff0000+MINX/2-8,(a1)+
	dbra	d0,.ld

	lea	rdecal+MAXX*4,a0
	lea	ldecal+MAXX*4,a1
	move	#DEPASSE+(LECRAN-MAXX)-1,d0
.rd:
	move.l	#$ffff0000+MAXX/2-8,(a0)+
	move.l	#$ffff0000+MAXX/2,(a1)+
	dbra	d0,.rd
	
	rts
	
	section	bss

phline:
	ds.b	(hline1-hline2)*NBLIG
phline2:
	ds	1	; Pour RTS
	even
	
phlinet:
	ds.b	(hline_tramed1-hline_tramed2)*NBLIG
phlinet2:
	ds	1	; Pour RTS
	even
	
	ds.l	DEPASSE
ldecal	ds.l	LECRAN
	ds.l	DEPASSE

	ds.l	DEPASSE
rdecal	ds.l	LECRAN
	ds.l	DEPASSE

	section	text
	
	; #] Genere hline:
	
 ; #] Very fast horizontal line:
 ; #[ Circle rout:

	; #[ Calling rout:
; ---------------------------------------------------------------------------- ;
;	Routine de cercle. (C) Copyright 1990 Ziggy STARDUST.	    ;
; ---------------------------------------------------------------------------- ;
; D1 = Rayon du cercle
; D2 = Position Y du centre du cercle
; D3 = Position X du centre du cercle

circle:
	move	#$0300,sr
	move.l	a7,oldpile
	
	move	d1,d7
	addq	#1,d1
	add	d2,d2
	
	lea	points_gauche,a0
	adda	d2,a0
	move.l	a0,a1
	move.l	a0,a4
	move.l	a0,a5
	
	lea	points_droite,a2
	adda	d2,a2
	move.l	a2,a3
	move.l	a2,a6
	move.l	a2,a7
	
	move	d1,d2
	add	d1,d2
	suba	d2,a4
	suba	d2,a6
	adda	d2,a5
	adda	d2,a7
	
	cmpi	#1,d7
	ble.s	.nocircle
	
	add	d3,d3
	add	d3,d3

	move	d1,d4	
	add	d4,d4
	add	d4,d4
	
	move	d3,d5
	sub	d4,d5
	add	d3,d4
	
	move	d1,d2
	asr	#1,d2

	neg	d7

	muls	#23170/2,d7
	asr.l	#6,d7
	asr.l	#8,d7
	
	add	d7,d7
	add	d7,d7
	move	d7,d0
	asl	#3,d7
	add	d0,d7	; * 36 octets

	clr	d0
	ext.l	d7
	move.l	#circle_rout,jmpcircle
	add.l	d7,jmpcircle
	move	d3,d6
	move	d3,d7

jmpcircle:	equ	*+2
	jmp	$0.l
	
.nocircle:
	moveq	#0,d0
	move	d0,-(a0)
	move	d0,(a1)+
	move	d0,-(a2)
	move	d0,(a3)+

	move.l	oldpile(pc),a7
	trap	#3
	
	rts
	
	; #] Calling rout:
	; #[ Initiale routine:	(36 octets...)
	
; D0 = Y
; D1 = X
; D2 = X2

circle1:
	add	d0,d2
	blt.s	.ok

.tst:
	subq	#1,d1
	subq	#4,d4
	addq	#4,d5
	
	move	d6,(a4)+
	move	d6,-(a5)
	move	d7,(a6)+
	move	d7,-(a7)

	sub	d1,d2
	bge.s	.tst
.ok:
	addq	#1,d0

	addq	#4,d6
	subq	#4,d7
	
	move	d4,-(a0)
	move	d4,(a1)+
	move	d5,-(a2)
	move	d5,(a3)+

circle2:
	; #] Initiale routine:
	; #[ Genere cercle:
genere_circle:
	lea	debut_circle_rout,a1
	move	#NBLIG*2-1,d0
	
.g_circle:
	lea	circle1(pc),a0
	move	#(circle2-circle1)/2-1,d1
	
.g_circle2:
	move	(a0)+,(a1)+

	dbra	d1,.g_circle2

	dbra	d0,.g_circle
	
	move	#$4ef9,(a1)+
	move.l	#retour,(a1)+	; --> Jmp	retour
	
	rts

	section	bss
	
debut_circle_rout:
	ds.b	(circle2-circle1)*NBLIG*2
circle_rout:
	ds.w	3
	
	section	text
	; #] Genere cercle:
	
 ; #] Circle rout:
 ; #[ Ellipse rout:	(en cours de developpement!)
	
	ifne	0
	; #[ Calling rout:
; ---------------------------------------------------------------------------- ;
;	Routine d'ellipse. (C) copyright 1990 Ziggy STARDUST.	    ;
; ---------------------------------------------------------------------------- ;
; A0 = Adresse de la table des points gauches au milieu du cercle
; A2 = Adresse de la table des points droits  au milieu du cercle
; D1 = Rayon X du cercle
; D2 = Rayon Y du cercle
; D3 = Position X du centre du cercle

ellipse:
	move	d1,d7
	addq	#1,d1
	move.l	a0,a1
	move.l	a2,a3
	
	add	d3,d3
	add	d3,d3

	move	d1,d4	
	add	d4,d4
	add	d4,d4
	
	move	d3,d5
	sub	d4,d5
	add	d3,d4
	
	move	d3,d6

	move	d1,d2
	asr	#1,d2

	neg	d7

	asl	#3,d7 ; 24 octets
	move	d7,d0
	add	d7,d7
	add	d0,d7

	clr	d0
	lea	ellipse_rout,a6
	jsr	(a6,d7)
	
	rts
	
	; #] Calling rout:
	; #[ Initiale routine:	(Je sais pas encore quel taille ca fera)
ellipse1:
	add	d0,d2
	blt.s	.ok

.tst:
	subq	#1,d1
	subq	#4,d4
	addq	#4,d5

	sub	d1,d2
	bge.s	.tst
.ok:
	addq	#1,d0

	move	d4,-(a0)
	move	d4,(a1)+
	move	d5,-(a2)
	move	d5,(a3)+

ellipse2:
	; #] Initiale routine:
	; #[ Genere ellipse:
genere_ellipse:
	lea	debut_ellipse_rout,a1
	move	#NBLIG*2-1,d0
	
.g_circle:
	lea	ellipse1(pc),a0
	move	#(ellipse2-ellipse1)/2-1,d1
	
.g_circle2:
	move	(a0)+,(a1)+

	dbra	d1,.g_circle2

	dbra	d0,.g_circle
	
	move	#$4e75,(a1)+
	
	rts

	section	bss
	
debut_ellipse_rout:
	ds.b	(circle2-circle1)*NBLIG*2
ellipse_rout:
	ds.w	1
	
	section	text
	; #] Genere ellipse:
	endc
	
 ; #] Ellipse rout:

 ; #[ Main programm:

qaffn	dc.b	0
	even
my	dc.w	0
rayon	dc.w	48
		
mainloop:
	tstcol	$000
	bsr	anime
	
;	move.l	ec1,a0
;	bsr	cls1plan
	tstcol	$700
	
	move	mousex,d0
	subi	#MAXX/2,d0
	neg	d0
	move	d0,ox
	
	move	mousey,d0
	subi	#NBLIG/2,d0
	move	d0,oy
	
	bsr	anime3d
	
	bra	mainloop

 ; #] Main programm:
 ; #[ Anime:

neffecr	dc	0

anime:

	ifne	DEBUG
	tst.b	qaffn
	beq.s	.no
	
	move	oz,d0
	move.l	ec1,a0
	lea	2*8*160(a0),a0
	bsr	affnr
.no:
	endc

.waitvbl:
	move.l	curec,a0
	sub.l	affec,a0
	cmpa.l	#NECR*4-1*4,a0
	bge.s	.waitvbl

	clr.b	used_plane	
	bsr	test_touche

	move.l	curec,a0
	addq.l	#4,a0
	cmpa.l	#ec+NECR*4*2,a0
	blt.s	okswap
	suba	#NECR*4,a0
	sub.l	#NECR*4,affec
	
okswap:
	move.l	(a0),ec1
	move.l	(NECR*2)*4*1(a0),curlim
	move.l	(NECR*2)*4*2(a0),affpal
	move.l	a0,curec
	
	move.l	ec1,a0
	move.l	curlim,a1
	movem	(a1),d0-d3
	move.b	8(a1),used_plane
	
	move.l	#.ret,retcls
	bra	cls
.ret:

	Flab
               tst	neffecr
               beq.s	.no
               subq	#1,neffecr
	move.l	ec1,a0
	bsr	cls1plan
.no:

	rts
	
anime3d:
	tst.b	clav+67	; <F9>?
	bne.s	.norot

	move	oba,d0
	add	va,d0
	andi	#TSINUS-1,d0
	move	d0,oba

	move	obb,d0
	add	vb,d0
	andi	#TSINUS-1,d0
	move	d0,obb
	
	move	obg,d0
	add	vg,d0
	andi	#TSINUS-1,d0
	move	d0,obg
.norot:

	move.l	curobj,a0
	move	oba,10(a0)
	move	obb,12(a0)
	move	obg,14(a0)
	
	lea	16(a0),a6
	jsr	afforme
	
	
	rts

 ; #] Anime:
 ; #[ Fin:
fin:
	tst.b	mousek
	bne.s	fin
	
	jsr	uninit

;	ifne	DEBUG	
;	illegal
;	elseif
	clr	-(a7)
	trap	#1
;	endc
	
 ; #] Fin:

 ; #[ Cls one plane:

cls1plan:
	moveq	#0,d0
	move	#NBLIG-1,d1
	
.loop:
N	set	0
	rept	20
	move	d0,N(a0)
N	set	N+8
	endr
	lea	160(a0),a0
	
	dbra	d1,.loop

	rts

 ; #] Cls one plane:
 ; #[ Cls a variable area and number of plane:

	; #[ Calling rout:
; Routine d'effacement
; D0: Min X
; D1: Max X
; D2: Min Y
; D3: Max Y
; A0: Adresse ecran
; retcls: Adresse retour du CLS

	section	bss
oa7	ds.l	1
used_plane	ds.b	1
	even
	section	text

cls:
	tst.b	clav+68	; <F10>?
	beq.s	.no
	move.b	#$0f,used_plane
.no:

	move	#$0300,sr
	move.l	a7,oa7
	move.l	a0,a7
	
	andi	#$fff0,d0
	addi	#16,d1
	andi	#$fff0,d1	; Multiple de 16 pixel
	move	d1,d5
	lsr	#1,d5
	
	sub	d0,d1	; Largeur
	lsr	#2,d1
	
	sub	d2,d3
	ble	cls0
	
	asl	#5,d2	; * 32
	move	d2,d4
	add	d2,d2
	add	d2,d2	; * 128
	add	d4,d2	; --> * 160
	
	add	d2,d5
	adda	d5,a7
	move	d3,d0
	
	moveq	#0,d7
	move.b	used_plane,d7
	add	d7,d7
	add	d7,d7
	jmp	.jmp_plane(pc,d7)
	
.jmp_plane:
	bra.w	fcls
	bra.w	plan0001
	bra.w	plan0010
	bra.w	plan0011
	bra.w	plan0100
	bra.w	plan0101
	bra.w	plan0110
	bra.w	plan0111
	bra.w	plan1000
	bra.w	plan1001
	bra.w	plan1010
	bra.w	plan1011
	bra.w	plan1100
	bra.w	plan1101
	bra.w	plan1110
	bra.w	plan1111
	; #] Calling rout:
	; #[ Four plane:	
plan1111:
plan1010:
plan0101:
plan1110:
plan1101:
plan1011:
plan0111:
	addq	#2,d1
	ble	cls0
	move	d1,.ajmp+2
	
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a0
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
	
.ajmp:
	bra.w	tcls
	
tcls:
	bra.w	cls0
	bra.w	cls1
	bra.w	cls2
	bra.w	cls3
	bra.w	cls4
	bra.w	cls5
	bra.w	cls6
	bra.w	cls7
	bra.w	cls8
	bra.w	cls9
	bra.w	cls10
	bra.w	cls11
	bra.w	cls12
	bra.w	cls13
	bra.w	cls14
	bra.w	cls15
	bra.w	cls16
	bra.w	cls17
	bra.w	cls18
	bra.w	cls19
	bra.w	cls20
	
cls1:
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	lea	160+8(a7),a7
	dbra	d0,cls1
	bra	fcls
	
cls2:
	movem.l	d1-d4,-(a7)
	lea	160+16(a7),a7
	dbra	d0,cls2
	bra	fcls
	
cls3:
	movem.l	d1-d6,-(a7)
	lea	160+24(a7),a7
	dbra	d0,cls3
	bra	fcls
	
cls4:
	movem.l	d1-a0,-(a7)
	lea	160+32(a7),a7
	dbra	d0,cls4
	bra	fcls
	
cls5:
	movem.l	d1-a2,-(a7)
	lea	160+40(a7),a7
	dbra	d0,cls5
	bra	fcls
	
cls6:
	movem.l	d1-a4,-(a7)
	lea	160+48(a7),a7
	dbra	d0,cls6
	bra	fcls
	
cls7:
	movem.l	d1-a6,-(a7)
	lea	160+56(a7),a7
	dbra	d0,cls7
	bra	fcls
	
cls8:
	movem.l	d1-a6,-(a7)
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	lea	160+64(a7),a7
	dbra	d0,cls8
	bra	fcls
	
cls9:
	movem.l	d1-a6,-(a7)
	movem.l	d1-d4,-(a7)
	lea	160+72(a7),a7
	dbra	d0,cls9
	bra.s	fcls
	
cls10:
	movem.l	d1-a6,-(a7)
	movem.l	d1-d6,-(a7)
	lea	160+80(a7),a7
	dbra	d0,cls10
	bra.s	fcls
	
cls11:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a0,-(a7)
	lea	160+88(a7),a7
	dbra	d0,cls11
	bra.s	fcls
	
cls12:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a2,-(a7)
	lea	160+96(a7),a7
	dbra	d0,cls12
	bra.s	fcls
	
cls13:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a4,-(a7)
	lea	160+104(a7),a7
	dbra	d0,cls13
	bra.s	fcls
	
cls14:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	lea	160+112(a7),a7
	dbra	d0,cls14
	bra.s	fcls
	
cls15:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	lea	160+120(a7),a7
	dbra	d0,cls15
;	bra.s	fcls
	
two_plane_cls0:
one_plane_cls0:
cls0:
fcls:
	move.l	oa7,a7
	trap	#3
	clr.b	used_plane
	dc	$4ef9	; --> Jmp
retcls	dc.l	0
	
cls16:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-d4,-(a7)
	lea	160+128(a7),a7
	dbra	d0,cls16
	bra.s	fcls
	
cls17:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-d6,-(a7)
	lea	160+136(a7),a7
	dbra	d0,cls17
	bra.s	fcls
	
cls18:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-a0,-(a7)
	lea	160+144(a7),a7
	dbra	d0,cls18
	bra.s	fcls
	
cls19:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-a2,-(a7)
	lea	160+152(a7),a7
	dbra	d0,cls19
	bra.s	fcls
	
cls20:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-a4,-(a7)
	lea	160+160(a7),a7
	dbra	d0,cls20
	bra	fcls
	
	; #] Four plane:	
	; #[ Two plane:
plan1001:	addq	#2,a7
plan1100:	addq	#2,a7
plan0110:	addq	#2,a7
plan0011:
	addq	#2,d1
	ble	fcls
	move	d1,.ajmp+2
	
	moveq	#0,d1
	
.ajmp:
	bra.w	two_plane_cls
	
two_plane_cls:
	bra.w	two_plane_cls0
	bra.w	two_plane_cls1
	bra.w	two_plane_cls2
	bra.w	two_plane_cls3
	bra.w	two_plane_cls4
	bra.w	two_plane_cls5
	bra.w	two_plane_cls6
	bra.w	two_plane_cls7
	bra.w	two_plane_cls8
	bra.w	two_plane_cls9
	bra.w	two_plane_cls10
	bra.w	two_plane_cls11
	bra.w	two_plane_cls12
	bra.w	two_plane_cls13
	bra.w	two_plane_cls14
	bra.w	two_plane_cls15
	bra.w	two_plane_cls16
	bra.w	two_plane_cls17
	bra.w	two_plane_cls18
	bra.w	two_plane_cls19
	bra.w	two_plane_cls20
	
Tpcls	macro
two_plane_loop\@:
	ifge	\1-1
	move.l	d1,-8(a7)
	endc
	ifge	\1-2
	move.l	d1,-16(a7)
	endc
	ifge	\1-3
	move.l	d1,-24(a7)
	endc
	ifge	\1-4
	move.l	d1,-32(a7)
	endc
	ifge	\1-5
	move.l	d1,-40(a7)
	endc
	ifge	\1-6
	move.l	d1,-48(a7)
	endc
	ifge	\1-7
	move.l	d1,-56(a7)
	endc
	ifge	\1-8
	move.l	d1,-64(a7)
	endc
	ifge	\1-9
	move.l	d1,-72(a7)
	endc
	ifge	\1-10
	move.l	d1,-80(a7)
	endc
	ifge	\1-11
	move.l	d1,-88(a7)
	endc
	ifge	\1-12
	move.l	d1,-96(a7)
	endc
	ifge	\1-13
	move.l	d1,-104(a7)
	endc
	ifge	\1-14
	move.l	d1,-112(a7)
	endc
	ifge	\1-15
	move.l	d1,-120(a7)
	endc
	ifge	\1-16
	move.l	d1,-128(a7)
	endc
	ifge	\1-17
	move.l	d1,-136(a7)
	endc
	ifge	\1-18
	move.l	d1,-144(a7)
	endc
	ifge	\1-19
	move.l	d1,-152(a7)
	endc
	ifge	\1-20
	move.l	d1,-160(a7)
	endc
	
	lea	160(a7),a7

	dbra	d0,two_plane_loop\@
	
	bra	fcls
	
	endm
	
two_plane_cls1		Tpcls	1
two_plane_cls2		Tpcls	2
two_plane_cls3		Tpcls	3
two_plane_cls4		Tpcls	4
two_plane_cls5		Tpcls	5
two_plane_cls6		Tpcls	6
two_plane_cls7		Tpcls	7
two_plane_cls8		Tpcls	8
two_plane_cls9		Tpcls	9
two_plane_cls10	Tpcls	10
two_plane_cls11	Tpcls	11
two_plane_cls12	Tpcls	12
two_plane_cls13	Tpcls	13
two_plane_cls14	Tpcls	14
two_plane_cls15	Tpcls	15
two_plane_cls16	Tpcls	16
two_plane_cls17	Tpcls	17
two_plane_cls18	Tpcls	18
two_plane_cls19	Tpcls	19
two_plane_cls20	Tpcls	20
	
	; #] Two plane:
	; #[ One plane:
plan1000:	addq	#2,a7
plan0100:	addq	#2,a7
plan0010:	addq	#2,a7
plan0001:
	addq	#2,d1
	ble	fcls
	move	d1,.ajmp+2
	
	moveq	#0,d1
	
.ajmp:
	bra.w	one_plane_cls
	
one_plane_cls:
	bra.w	one_plane_cls0
	bra.w	one_plane_cls1
	bra.w	one_plane_cls2
	bra.w	one_plane_cls3
	bra.w	one_plane_cls4
	bra.w	one_plane_cls5
	bra.w	one_plane_cls6
	bra.w	one_plane_cls7
	bra.w	one_plane_cls8
	bra.w	one_plane_cls9
	bra.w	one_plane_cls10
	bra.w	one_plane_cls11
	bra.w	one_plane_cls12
	bra.w	one_plane_cls13
	bra.w	one_plane_cls14
	bra.w	one_plane_cls15
	bra.w	one_plane_cls16
	bra.w	one_plane_cls17
	bra.w	one_plane_cls18
	bra.w	one_plane_cls19
	bra.w	one_plane_cls20
	
Opcls	macro
one_plane_loop\@:
	ifge	\1-1
	move	d1,-8(a7)
	endc
	ifge	\1-2
	move	d1,-16(a7)
	endc
	ifge	\1-3
	move	d1,-24(a7)
	endc
	ifge	\1-4
	move	d1,-32(a7)
	endc
	ifge	\1-5
	move	d1,-40(a7)
	endc
	ifge	\1-6
	move	d1,-48(a7)
	endc
	ifge	\1-7
	move	d1,-56(a7)
	endc
	ifge	\1-8
	move	d1,-64(a7)
	endc
	ifge	\1-9
	move	d1,-72(a7)
	endc
	ifge	\1-10
	move	d1,-80(a7)
	endc
	ifge	\1-11
	move	d1,-88(a7)
	endc
	ifge	\1-12
	move	d1,-96(a7)
	endc
	ifge	\1-13
	move	d1,-104(a7)
	endc
	ifge	\1-14
	move	d1,-112(a7)
	endc
	ifge	\1-15
	move	d1,-120(a7)
	endc
	ifge	\1-16
	move	d1,-128(a7)
	endc
	ifge	\1-17
	move	d1,-136(a7)
	endc
	ifge	\1-18
	move	d1,-144(a7)
	endc
	ifge	\1-19
	move	d1,-152(a7)
	endc
	ifge	\1-20
	move	d1,-160(a7)
	endc
	
	lea	160(a7),a7

	dbra	d0,one_plane_loop\@
	
	bra	fcls
	
	endm
	
one_plane_cls1		Opcls	1
one_plane_cls2		Opcls	2
one_plane_cls3		Opcls	3
one_plane_cls4		Opcls	4
one_plane_cls5		Opcls	5
one_plane_cls6		Opcls	6
one_plane_cls7		Opcls	7
one_plane_cls8		Opcls	8
one_plane_cls9		Opcls	9
one_plane_cls10	Opcls	10
one_plane_cls11	Opcls	11
one_plane_cls12	Opcls	12
one_plane_cls13	Opcls	13
one_plane_cls14	Opcls	14
one_plane_cls15	Opcls	15
one_plane_cls16	Opcls	16
one_plane_cls17	Opcls	17
one_plane_cls18	Opcls	18
one_plane_cls19	Opcls	19
one_plane_cls20	Opcls	20
	
	; #] One plane:
	
 ; #] Cls a variable area and number of plane:

 ; #[ Vbl:

	; #[ Datas:
curec	dc.l	ec+3*4
affec	dc.l	ec
cvbl	dc.w	0
cvbl1	dc.w	0
cvbl2	dc.w	0
cvbl3	dc.w	0
tcol	dc.w	0

ec1	ds.l	1
curlim	ds.l	1

ec:
	ds.l	NECR*2
	
tlim:
N	set	0
	rept	NECR
	dc.l	lim+N
N	set	N+10
	endr
N	set	0
	rept	NECR
	dc.l	lim+N
N	set	N+10
	endr
	
tpal:
N	set	0
	rept	NECR
	dc.l	pal+N
N	set	N+32
	endr
N	set	0
	rept	NECR
	dc.l	pal+N
N	set	N+32
	endr
	
lim:
	rept	NECR*2
	dc	10,30,20,30,0
	endr
	
	section	bss
	
pal:	ds	16*NECR
	
	section	text
	; #] Datas:
	
	; #[ Real_VBL:
vbl:
	move.l	#vbl2,$134.w
	clr.b	$fffffa19.w
	bset	#5,$fffffa07.w
	bset	#5,$fffffa13.w
	move.b	#200,$fffffa1f.w
	move.b	#7,$fffffa19.w
	
	clr.b	$ffff8260.w
	
	jsr	waitc
	move.b	#$0d,$fffffc02.w ; Ask for mouse position
	
	rte
	; #] Real_VBL:
	; #[ Timer_VBL:
	
FREQUENCE	=	50
	
vbl2:
;	move	#$005,$ffff8240
	movem.l	d0-a6,-(a7)
	
	addq	#1,cvbl
	addq	#1,cvbl1
	cmpi	#FREQUENCE,cvbl1
	blt.s	okcvbl
	
	move	cvbl2,cvbl3
	clr	cvbl1
	clr	cvbl2
okcvbl:

	ifne	DEBUG
	tst.b	qaffn
	beq.s	.no
	sub.l	a1,a1
	move	cvbl3,a1
	add	a1,a1
	add	a1,a1
	adda.l	#nombre,a1
	move.l	ec1,a0
	jsr	(a1)
.no:
	endc

	move.l	curec,a1
	sub.l	affec,a1
	cmpa.l	#2*4,a1
	blt.s	noswap
	
	addq	#1,cvbl2
	move.l	affec(pc),a0
	addq	#4,a0
	move.l	a0,affec
	move.b	1(a0),$ffff8201.w
	move.b	2(a0),$ffff8203.w
	move.l	NECR*2*4*2(a0),a0
	movem.l	(a0),d0-d7
;	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	
noswap:
	ifne	DEBUG
	tst.b	qaffn
	beq.s	.no
	adda.l	#nombre,a1
	move.l	ec1,a0
	lea	8*160(a0),a0
	jsr	(a1)
.no:
	endc
	
	movem.l	(a7)+,d0-a6
	clr.b	$fffffa19.w
	clr	$ffff8240.w
;	move	#$500,$ffff8240.w
	rte
	; #] Timer_VBL:

 ; #] Vbl:
 ; #[ Affn:

affnr:
	tst	d0
	bge.s	.ok

	neg	d0	
.ok:
	ext.l	d0
	divs	#100,d0
	add	d0,d0
	add	d0,d0
	jsr	nombre(pc,d0)
	
	swap	d0
	add	d0,d0
	add	d0,d0
	addq	#8,a0
	jmp	nombre(pc,d0)
	
nombre:
	incbin	zeroa99.bin
	even
	rts
	
affn:
	lea	num,a6
	
affn1:
	divs	#10,d7
	move.w	d7,-(a7)
	swap	d7
	addi.w	#'0',d7
	move.b	d7,-(a6)
	
	move.w	(a7)+,d7
	ext.l	d7
	bne.s	affn1
	
	Print	(a6)

	rts
	
 ; #] Affn:

 ; #[ 3D_Objects:

	; #[ Quelques macros:

Defplot	macro
	dc.l	defplot
	endm
	
Plot	macro
	dc.w	\1,\2,\3
	endm
	
Face1p	macro
	dc.l	face1p
	dc.w	\1
	endm
	
Face1pt	macro
	dc.l	face1pt
	dc.w	\1
	endm
	
Init_color	macro
	dc.l	init_color
	endm
	
Set_color	macro
	dc.l	set_color
	endm
	
Vertices	macro
	dc.l	vertices
	
	ifge	NARG-1
	dc.w	\1
	endc
	ifge	NARG-2
	dc.w	\2
	endc
	ifge	NARG-3
	dc.w	\3
	endc
	ifge	NARG-4
	dc.w	\4
	endc
	ifge	NARG-5
	dc.w	\5
	endc
	ifge	NARG-6
	dc.w	\6
	endc
	ifge	NARG-7
	dc.w	\7
	endc
	ifge	NARG-8
	dc.w	\8
	endc
	dc.w	-1
	
	endm
	
Hide	macro
	dc.l	test_visibility
	dc.w	\1-*
	endm
	
Affpoly	macro
	dc.l	call_poly
	endm
	
Fin	macro
	dc.l	fin_afforme
	endm
	
	; #] Quelques macros:

	; #[ Cube:
cube:
	Defplot
	Plot	-100,-100,-100	;0
	Plot	100,-100,-100	;1
	Plot	100,100,-100	;2
	Plot	-100,100,-100	;3
	Plot	-100,-100,100	;4
	Plot	100,-100,100	;5
	Plot	100,100,100	;6
	Plot	-100,100,100	;7
	
	Init_color
	
	Face1pt	2
	Vertices	3,2,1,0
	Hide	.next1
	Set_color
	Affpoly

.next1:
	Face1p	4
	Vertices	7,6,2,3
	Hide	.next2
	Set_color
	Affpoly
	
.next2:
	Face1p	2
	Vertices	4,7,3,0
	Hide	.next3
	Set_color
	Affpoly
	
.next3:
	Face1pt	2
	Vertices	4,5,6,7
	Hide	.next4
	Set_color
	Affpoly

.next4:
	Face1p	4
	Vertices	0,1,5,4
	Hide	.next5
	Set_color
	Affpoly
	
.next5:
	Face1p	2
	Vertices	1,2,6,5
	Hide	.next6
	Set_color
	Affpoly

	Fin	
	
	; #] Cube:
	; #[ Pyramide:
pyramide:
	dc.w	5
	Plot	0,150,0
	Plot	-100,0,-100
	Plot	100,0,-100
	Plot	100,0,100
	Plot	-100,0,100
	
	Face1p	8
	Vertices	0,2,1
	dc.l	-1,-1
	Face1p	11
	Vertices	0,3,2
	dc.l	-1,-1
	Face1p	9
	Vertices	0,4,3
	dc.l	-1,-1
	Face1p	11
	Vertices	0,1,4
	dc.l	-1,-1
	Face1p	4
	Vertices	1,2,3,4
	dc.l	-1,-1
	
	dc.w	-1
	
	; #] Pyramide:
	; #[ Alliance:
alliance:
	dc.w	22		;22 points.
	
	Plot	-32,80,-32	;0
	Plot	-32,80,32	;1
	Plot	32,80,-32	;2
	Plot	32,80,32	;3
	Plot	112,-80,-32	;4
	Plot	112,-80,32	;5
	Plot	48,-80,-32	;6
	Plot	48,-80,32	;7
	Plot	32,-48,-32	;8
	Plot	32,-48,32	;9
	Plot	-32,-48,-32	;10
	Plot	-32,-48,32	;11
	Plot	-48,-80,-32	;12
	Plot	-48,-80,32	;13
	Plot	-112,-80,-32	;14
	Plot	-112,-80,32	;15
	Plot	-16,-16,-32	;16
	Plot	-16,-16,32	;17
	Plot	16,-16,-32	;18
	Plot	16,-16,32	;19
	Plot	0,16,-32	;20
	Plot	0,16,32	;21


	Face1p	3		;8
	Vertices	17,19,18,16
	dc.l	-1,-1
	Face1pt	3		;9
	Vertices	19,21,20,18
	dc.l	-1,-1
	Face1pt	3		;10
	Vertices	21,17,16,20
	dc.l	-1,-1
	
	Face1p	3		;0
	Vertices	1,3,2,0
	dc.l	-1,-1
	Face1p	4		;1
	Vertices	3,5,4,2
	dc.l	-1,-1
	Face1pt	3		;2
	Vertices	5,7,6,4
	dc.l	-1,-1
	Face1p	3		;3
	Vertices	7,9,8,6
	dc.l	-1,-1
	Face1pt	3		;4
	Vertices	9,11,10,8
	dc.l	-1,-1
	Face1p	3		;5
	Vertices	11,13,12,10
	dc.l	-1,-1
	Face1pt	3		;6
	Vertices	13,15,14,12
	dc.l	-1,-1
	Face1p	4		;7
	Vertices	15,1,0,14
	dc.l	-1,-1

	Face1p	6		;11
	Vertices	16,18,8,10
	dc.l	-1,-1
	Face1p	6		;14
	Vertices	2,4,6,8,18,20
	dc.l	-1,-1
	Face1p	6		;13
	Vertices	0,2,20,16,10,12,14
	dc.l	-1,-1
	
	Face1p	5		;12
	Vertices	11,9,19,17
	dc.l	-1,-1
	Face1p	5		;15
	Vertices	1,15,13,11,17,21,3
	dc.l	-1,-1
	Face1p	5		;16
	Vertices	7,5,3,21,19,9
	dc.l	-1,-1
	
	dc.w	-1

	; #] Alliance:
	; #[ Dodecaedre:
dodecaedre
	dc.w	20

	Plot	283,631,390
	Plot	458,631,-149
	Plot	0,631,-482
	Plot	-458,631,-149
	Plot	-283,631,390
	Plot	-458,149,631
	Plot	0,-149,780
	Plot	458,149,631
	Plot	742,-149,241
	Plot	742,149,-241
	Plot	458,-149,-631
	Plot	0,149,-780
	Plot	-458,-149,-631
	Plot	-742,149,-241
	Plot	-742,-149,241
	Plot	-283,-631,-390
	Plot	-458,-631,149
	Plot	0,-631,482
	Plot	458,-631,149
	Plot	283,-631,-390

	Face1p	1
	Vertices	0,1,2,3,4
	dc.l	-1,-1
	Face1p	2
	Vertices	0,4,5,6,7
	dc.l	-1,-1
	Face1p	3
	Vertices	0,7,8,9,1
	dc.l	-1,-1
	Face1p	4
	Vertices	1,9,10,11,2
	dc.l	-1,-1
	Face1pt	1
	Vertices	2,11,12,13,3
	dc.l	-1,-1
	Face1pt	2
	Vertices	3,13,14,5,4
	dc.l	-1,-1
	Face1pt	3
	Vertices	12,15,16,14,13
	dc.l	-1,-1
	Face1pt	4
	Vertices	14,16,17,6,5
	dc.l	-1,-1
	Face1p	1
	Vertices	6,17,18,8,7
	dc.l	-1,-1
	Face1pt	2
	Vertices	8,18,19,10,9
	dc.l	-1,-1
	Face1p	3
	Vertices	11,10,19,15,12
	dc.l	-1,-1
	Face1p	4
	Vertices	17,16,15,19,18
	dc.l	-1,-1
	
	dc.w	-1
	
	; #] Dodecaedre:
	; #[ Boule:
boule:
	dc.w	42		;42 points.
*********************
	Plot	0,96,0	;0
	Plot	64,80,0	;1
	Plot	96,48,0	;2
	Plot	112,0,0	;3
	Plot	96,-48,0	;4
	Plot	64,-80,0	;5
	Plot	0,-98,0	;6
	Plot	45,80,45	;7
	Plot	67,48,67	;8
	Plot	79,0,79	;9
	Plot	67,-48,67	;10
	Plot	45,-80,45	;11
	Plot	0,80,64	;12
	Plot	0,48,96	;13
	Plot	0,0,112	;14
	Plot	0,-48,96	;15
	Plot	0,-80,64	;16
	Plot	-46,80,45	;17
	Plot	-68,48,67	;18
	Plot	-80,0,79	;19
	Plot	-68,-48,67	;20
	Plot	-46,-80,45	;21
	Plot	-64,80,0	;22
	Plot	-96,48,0	;23
	Plot	-112,0,0	;24
	Plot	-96,-48,0	;25
	Plot	-64,-80,0	;26
	Plot	-46,80,-46	;27
	Plot	-68,48,-68	;28
	Plot	-80,0,-80	;29
	Plot	-68,-48,-68	;30
	Plot	-46,-80,-46	;31
	Plot	0,80,-64	;32
	Plot	0,48,-96	;33
	Plot	0,0,-112	;34
	Plot	0,-48,-96	;35
	Plot	0,-80,-64	;36
	Plot	45,80,-46	;37
	Plot	67,48,-68	;38
	Plot	79,0,-80	;39
	Plot	67,-48,-68	;40
	Plot	45,-80,-46	;41

********************* Interieur
	Face1p	11	;0
	Vertices	7,12,0
	dc.l	.anti1,-1
	Face1p	11	;1
	Vertices	17,22,0
	dc.l	.anti2,-1
	Face1p	11	;2
	Vertices	27,32,0
	dc.l	.anti3,-1
	Face1p	11	;3
	Vertices	37,1,0
	dc.l	.anti4,-1
	Face1p	11	;4
	Vertices	2,8,7,1
	dc.l	.anti5,-1
	Face1p	11	;5
	Vertices	13,18,17,12
	dc.l	.anti6,-1
	Face1p	11	;6
	Vertices	23,28,27,22
	dc.l	.anti7,-1
	Face1p	11	;7
	Vertices	33,38,37,32
	dc.l	.anti8,-1
	Face1p	11	;8
	Vertices	9,14,13,8
	dc.l	.anti9,-1
	Face1p	11	;9
	Vertices	19,24,23,18
	dc.l	.anti10,-1
	Face1p	11	;10
	Vertices	29,34,33,28
	dc.l	.anti11,-1
	Face1p	11	;11
	Vertices	39,3,2,38
	dc.l	.anti12,-1
	Face1p	11	;12
	Vertices	4,10,9,3
	dc.l	.anti13,-1
	Face1p	11	;13
	Vertices	15,20,19,14
	dc.l	.anti14,-1
	Face1p	11	;14
	Vertices	25,30,29,24
	dc.l	.anti15,-1
	Face1p	11	;15
	Vertices	35,40,39,34
	dc.l	.anti16,-1
	Face1p	11	;16
	Vertices	11,16,15,10
	dc.l	.anti17,-1
	Face1p	11	;17
	Vertices	21,26,25,20
	dc.l	.anti18,-1
	Face1p	11	;18
	Vertices	31,36,35,30
	dc.l	.anti19,-1
	Face1p	11	;19
	Vertices	41,5,4,40
	dc.l	.anti20,-1
	Face1p	11	;20
	Vertices	6,11,5
	dc.l	.anti21,-1
	Face1p	11	;21
	Vertices	6,21,16
	dc.l	.anti22,-1
	Face1p	11	;22
	Vertices	6,31,26
	dc.l	.anti23,-1
	Face1p	11	;23
	Vertices	6,41,36
	dc.l	.anti24,-1
	
********************* Exterieur
.anti1:
	Face1p	13	;0
	Vertices	0,12,7
	dc.l	-1,-1
.anti2:
	Face1p	13	;1
	Vertices	0,22,17
	dc.l	-1,-1
.anti3:
	Face1p	13	;2
	Vertices	0,32,27
	dc.l	-1,-1
.anti4:
	Face1p	13	;3
	Vertices	0,1,37
	dc.l	-1,-1
.anti5:
	Face1p	14	;4
	Vertices	1,7,8,2
	dc.l	-1,-1
.anti6:
	Face1p	14	;5
	Vertices	12,17,18,13
	dc.l	-1,-1
.anti7:
	Face1p	14	;6
	Vertices	22,27,28,23
	dc.l	-1,-1
.anti8:
	Face1p	14	;7
	Vertices	32,37,38,33
	dc.l	-1,-1
.anti9:
	Face1p	13	;8
	Vertices	8,13,14,9
	dc.l	-1,-1
.anti10:
	Face1p	13	;9
	Vertices	18,23,24,19
	dc.l	-1,-1
.anti11:
	Face1p	13	;10
	Vertices	28,33,34,29
	dc.l	-1,-1
.anti12:
	Face1p	13	;11
	Vertices	38,2,3,39
	dc.l	-1,-1
.anti13:
	Face1p	14	;12
	Vertices	3,9,10,4
	dc.l	-1,-1
.anti14:
	Face1p	14	;13
	Vertices	14,19,20,15
	dc.l	-1,-1
.anti15:
	Face1p	14	;14
	Vertices	24,29,30,25
	dc.l	-1,-1
.anti16:
	Face1p	14	;15
	Vertices	34,39,40,35
	dc.l	-1,-1
.anti17:
	Face1p	13	;16
	Vertices	10,15,16,11
	dc.l	-1,-1
.anti18:
	Face1p	13	;17
	Vertices	20,25,26,21
	dc.l	-1,-1
.anti19:
	Face1p	13	;18
	Vertices	30,35,36,31
	dc.l	-1,-1
.anti20:
	Face1p	13	;19
	Vertices	40,4,5,41
	dc.l	-1,-1
.anti21:
	Face1p	14	;20
	Vertices	5,11,6
	dc.l	-1,-1
.anti22:
	Face1p	14	;21
	Vertices	16,21,6
	dc.l	-1,-1
.anti23:
	Face1p	14	;22
	Vertices	26,31,6
	dc.l	-1,-1
.anti24:
	Face1p	14	;23
	Vertices	36,41,6
	dc.l	-1,-1
	
	dc.w	-1
	
	; #] Boule:
	; #[ Vaisseau:
vaisseau:
	dc.w	8		;8 points.
*********************
	Plot	-200,100,-400		;0
	Plot	-500,00,-400		;1
	Plot	-200,-100,-400		;2
	Plot	200,-100,-400		;3
	Plot	200,100,-400		;4
	Plot	500,00,-400		;5
	Plot	200,00,400		;6
	Plot	-200,00,400		;7

*********************
	Face1p	2		;0
	Vertices	1,7,0
	dc.l	-1,-1

	Face1p	3		;1
	Vertices	0,7,6,4
	dc.l	-1,-1

	Face1p	2		;2
	Vertices	4,6,5
	dc.l	-1,-1

	Face1p	3		;4
	Vertices	2,7,1
	dc.l	-1,-1

	Face1p	3		;5
	Vertices	3,5,6
	dc.l	-1,-1

	Face1p	2		;6
	Vertices	2,3,6,7
	dc.l	-1,-1
	
	Face1pt	12		;3
	Vertices	1,0,4,5,3,2
	dc.l	-1,-1
	
	dc.w	-1

	; #] Vaisseau:
	
 ; #] 3D_Objects:
 ; #[ Objects_defs:
OBJET	MACRO
	dc.l	\1
	dc.w	\2,\3,\4,\5,\6,\7
	endm
	
obj1	OBJET	cube,0,0,30,0,0,0
obj2	OBJET	alliance,0,0,30,0,0,0
obj3	OBJET	dodecaedre,0,0,1975,0,0,0
obj4	OBJET	vaisseau,0,0,30,0,0,0
obj5	OBJET	boule,0,0,30,0,0,0
obj6	OBJET	pyramide,0,0,30,0,0,0

curobj	dc.l	obj1
	
	; #] Objects_defs:

 ; #[ Variables:
		
	section	bss
	
	; #[ Variables_systemes:
oldpal	ds.w	16

oldbomb	ds.l	8
oldrez	ds.w	1
oldrez_tt	ds.b	1
	even
oldec	ds.l	1
	; #] Variables_systemes:

	section	data

ty1	dc.w	32000
ty2	dc.w	0
hy	dc.w	0

	section	bss
	
colorpoly	ds.w	1		; couleur du polygone

maxy	ds.w	1
miny	ds.w	1

tplot	ds.w	128*3	* Table des points apres calcul 3D

plot	ds.l	128	* 128 points max dans une forme 3D
	ds.w	2
pxy	ds.l	16	* Tableau du polygone

tpxy1	ds.l	16	* 16 points maximum pour les polygone remplis.
tpxy2	ds.l	16

	ds.w	NBLIG*2
points_gauche	ds.w	NBLIG
	ds.w	NBLIG*2
points_droite	ds.w	NBLIG
	ds.w	NBLIG*2

num	ds.b	20

	ds.b	256
ecran	ds.b	32000*NECR+256
	even
 ; #] Variables:

