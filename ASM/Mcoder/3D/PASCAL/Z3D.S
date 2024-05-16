	opt	o+,ow-
	output	z.prg

CENTRE_X	equ	320/2
FONT_LENGTH	equ	472+8
DEBUG	equ	0	;0=Debug on
NB_SCREENS	equ	3
NB_POINTS	equ	30	;25 si pas nscarre
NB_LINES	equ	200-8
DEPTH	equ	1
LEFT_CLIP	equ	1024
RIGHT_CLIP	equ	1024

	 ;#[ Short DATA Section:
;
; point de rotation : (0,0,100)
;
	Offset	$181c

Underflow:	ds.w	10
Mul160:	ds.w	NB_LINES
Overflow:	ds.w	10

Sync:	ds.w	1
Matrice:	ds.w	9
Pushcls:	ds.l	40
Finpush:
;
Ptwr:	ds.l	1
Ptrd:	ds.l	1
Dist:	ds.w	1

Planes:	ds.w	1
Palette:	ds.b	16*2
;
; variables pour scroller
;
Rotatex:	ds.b	1	;vitesse de rotation
Rotatey:	ds.b	1
Rotatez:	ds.b	1
;
; angles de rotation, etc...
;
Rotx:	ds.b	1
Roty:	ds.b	1
Rotz:	ds.b	1

	even

Segments:	ds.b	NB_POINTS*4
	 ;#] Short DATA Section:
	TEXT
	 ;#[ Installation:
	move	sr,d0
	and	#$2000,d0
	bne.s	Super
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
Super:	move	#$2700,sr
	lea	$80000,a7
	movem.l	Translate(pc),d0-d7
	movem.l	d0-d7,-(a7)
	lea	Top(pc),a0
	lea	Code,a1
	move	#(Bottom-Top)/4,d0
	jmp	(a7)
Translate:	move.l	(a0)+,(a1)+
	move	a1,$ffff8240.w
	dbf	d0,Translate
	jmp	Code
	 ;#] Installation:
	 ;#[ Initializations:
Top:
	org	$8000
Code:	move	#$2700,sr
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	move.b	#$40,$fffffa17.w
	move.l	#Hbl,$120.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w

	lea	Stack,a7		;Super stack
	lea	Storage,a6
	moveq	#NB_SCREENS-1,d0
	lea	$80000,a0
	lea	Ptrscr(a6),a1
	lea	Firstpal,a2
.Gen_it:	lea	-32000(a0),a0
	move.l	a0,(a1)+
	move	#160,(a1)
	move	(a1)+,(a1)+
	move	#NB_LINES/2,(a1)
	move	(a1)+,(a1)+
	move.l	a2,(a1)+
	lea	32(a2),a2
	clr	(a1)+
	dbf	d0,.Gen_it

.Oklin:	lea	Ptrscr(a6),a1
	move.l	a1,Ptwr.w
	lea	Ptrscr(a6),a1
	move.l	a1,Ptrd.w
	move.l	a0,Last_screen(a6)
	clr	Nbimages(a6)

	lea	$80000,a1
	moveq	#0,d1
.Cls:	move.l	d1,(a0)+
	cmp.l	a1,a0
	bcs.s	.Cls

	lea	(Mul160-20).w,a0
	move	#NB_LINES+20-1,d0
.Fil160:	move	#-1,(a0)+
	dbf	d0,.Fil160

	move	#NB_LINES-1,d0
	moveq	#0,d1
	lea	Mul160.w,a0
.Mul160:	move	d1,(a0)+
	add	#160,d1
	dbf	d0,.Mul160

	jsr	Gendraw
	jsr	Generate_line
	jsr	Generate_cls

	move.l	#Vbl,$70.w
	move	#$2300,sr
	clr	Sync.w
.Vbl1:	tst	Sync.w
	beq.s	.Vbl1
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	move.l	#Prg_sur_vbl,$70.w
	move.l	#Bugpal,Lastpal(a6)
	clr	Current_object(a6)
	clr.b	Latchkey(a6)
	clr.b	Cheat(a6)

	move.b	#50,Cptvbl(a6)
	clr.b	Numsec(a6)
	clr.b	Latchnum(a6)

DEFAULT	MACRO
	clr.b	Rotx.w
	clr.b	Roty.w
	clr.b	Rotz.w
	ENDM
	move.l	#Divs0,$14.w
	move.b	#1,Rotatex.w
	move.b	#2,Rotatey.w
	move.b	#3,Rotatez.w
	move	#$60,Dist.w
	DEFAULT
	 ;#] Initializations:
	 ;#[ Manager:
Demo:	clr	d0
	move.b	$fffffc02.w,d0

	IFEQ	DEBUG
	cmp.b	#$1d,Latchkey(a6)
	bne.s	.Paquit
	cmp.b	#$2e,d0
	bne.s	.Paquit
	clr.l	$426.w
	move.l	4.w,a0
	jmp	(a0)
.Paquit:
	ENDC

	cmp.b	#$24,Latchkey(a6)
	bne.s	.Nocheat
	cmp.b	#$2e,d0
	bne.s	.Nocheat
	st	Cheat(a6)
.Nocheat:	cmp.b	Latchkey(a6),d0
	bne.s	.Diffkey
	subq	#1,Repeat(a6)
	bne	.Nokey
	move	#4,Repeat(a6)
	bra.s	.Samekey
.Diffkey:	move	#10,Repeat(a6)
.Samekey:	move.b	d0,Latchkey(a6)
	bmi	.Nokey
	tst.b	Cheat(a6)
	beq	.Nokey
	cmp.b	#$4a,d0
	bne.s	.Notmoins
	tst	Current_object(a6)
	beq.s	.Notmoins
	sub	#12,Current_object(a6)
	DEFAULT
.Notmoins:	cmp.b	#$4e,d0
	bne.s	.Notplus
	cmp	#(Nbobjets-1)*12,Current_object(a6)
	bcc.s	.Notplus
	add	#12,Current_object(a6)
	DEFAULT
.Notplus:	cmp.b	#$e,d0
	bne.s	.0
	move.b	#1,Rotatex.w
	move.b	#2,Rotatey.w
	move.b	#3,Rotatez.w
	move	#$60,Dist.w
	DEFAULT
.0:	cmp.b	#$50,d0		;flŠche bas
	bne.s	.1
	addq.b	#1,Rotatex.w
	DEFAULT
.1:	cmp.b	#$48,d0		;flŠche haut
	bne.s	.2
	subq.b	#1,Rotatex.w
	DEFAULT
.2:	cmp.b	#$47,d0		;insert
	bne.s	.3
	subq.b	#1,Rotatez.w
	DEFAULT
.3:	cmp.b	#$52,d0		;clr-home
	bne.s	.4
	addq.b	#1,Rotatez.w
	DEFAULT
.4:	cmp.b	#$4b,d0		;flŠche gauche
	bne.s	.5
	subq.b	#1,Rotatey.w
	DEFAULT
.5:	cmp.b	#$4d,d0		;flŠche droite
	bne.s	.6
	addq.b	#1,Rotatey.w
	DEFAULT
.6:	cmp.b	#$62,d0		;help
	bne.s	.7
	cmp	#DEPTH,Dist.w
	bls.s	.7
	subq	#DEPTH,Dist.w
.7:	cmp.b	#$61,d0		;undo
	bne.s	.8
	addq	#DEPTH,Dist.w
.8:

.Nokey:	move.l	Ptwr.w,a0
	move.l	Rsecran(a0),a1
	tst	Nbimages(a6)
	beq.s	.Ok
	move	#$2700,sr
	cmp.l	Last_screen(a6),a1
	bne.s	.Ok2
	illegal
.Ok2:	moveq	#0,d0
	move.b	$ffff8201.w,d0
	swap	d0
	move.b	$ffff8203.w,d0
	asl	#8,d0
	cmp.l	d0,a1
	bne.s	.Ok3
	illegal
.Ok3:	moveq	#0,d0
	move.b	$ffff8205.w,d0
	swap	d0
	move.b	$ffff8207.w,d0
	asl	#8,d0
	move.b	$ffff8209.w,d0
	sub.l	a1,d0
	cmp.l	#32000,d0
	bcc.s	.Ok
	illegal
.Ok:	move	#$2300,sr
	move.l	a1,usp
	jsr	Cls
	lea	Storage,a6
	move	Current_object(a6),d0		;numero de l'objet*4
	lea	All_objects(pc),a0
	move.l	8(a0,d0),a4		;Palette
	movem.l	(a4)+,d1-d7/a1
	movem.l	d1-d7/a1,Palette.w
	move.l	0(a0,d0),a0		;adresse des points

	lea	Segments.w,a1

	cmp.b	#$39,$fffffc02.w
	bne.s	.No_CPU
	move	#$555,$ffff8240.w
.No_CPU:	jsr	Calcobj
	clr	$ffff8240.w

	move.l	Rsecran(a0),a1
	move.l	a1,usp
	lea	Storage,a6
	move	Current_object(a6),d0		;numero de l'objet*4
	lea	Drawline,a4		;optimisation !!!
	lea	All_objects(pc),a0
	move.l	4(a0,d0),a0		;routine de branchement
	clr	Planes.w
	jsr	(a0)
	lea	Storage,a6

	move.l	Ptwr.w,a0
	move	Planes.w,Rsplanes(a0)
	move.l	Rspal(a0),a1
	movem.l	Palette.w,d0-d7
	movem.l	d0-d7,(a1)

	tst.b	Cheat(a6)
	beq.s	.Nodisp
	move.l	usp,a1
	move.l	a1,a2
	move.b	Latchnum(a6),d7	;nb images par seconde
	bsr	Print
	lea	8*160(a2),a1
	move.b	Rotatex.w,d7
	bsr	Print
	lea	16*160(a2),a1
	move.b	Rotatey.w,d7
	bsr	Print
	lea	24*160(a2),a1
	move.b	Rotatez.w,d7
	bsr	Print
	lea	32*160(a2),a1
	move.b	Dist.w,d7
	bsr	Print
	move.b	Dist+1.w,d7
	bsr	Print

	IFEQ	1
	lea	40*160(a2),a1
	move.b	Rotx.w,d7
	bsr	Print
	lea	48*160(a2),a1
	move.b	Roty.w,d7
	bsr	Print
	lea	56*160(a2),a1
	move.b	Rotz.w,d7
	bsr	Print
	ENDC
.Nodisp:	move.l	Ptwr.w,a0
	lea	STRUCT_LENGTH(a0),a0
	cmp.l	#Storage+Finscr,a0
	bcs.s	.Lowup
	lea	Ptrscr(a6),a0
.Lowup:	move.l	a0,Ptwr.w
	addq	#1,Nbimages(a6)
	tst.b	Cheat(a6)
	beq.s	.Loop
	cmp.b	#1,$fffffc02.w
	bne.s	.Loop
	move	#$077,$ffff8240.w
.Loop:	cmp	#NB_SCREENS-3,Nbimages(a6)
	bcc.s	.Loop
	bra	Demo

Divs0:	addq	#DEPTH,Dist.w
	addq	#1,d4
	addq	#1,d5
	rte
Vbl:	addq	#1,Sync.w
	rte
	 ;#] Manager:
	 ;#[ Print:
Print:	bsr.w	.Digit
.Digit:	rol.b	#4,d7
	moveq	#$f,d0
	and	d7,d0
	asl	#3,d0
	lea	Fonte,a0
	add	d0,a0
x	set	6
	rept	8
	move.b	(a0)+,x(a1)
x	set	x+160
	endr
	addq	#1,a1
	move	a1,d0
	lsr	#1,d0
	bcs.s	.Pair
	addq	#6,a1
.Pair:	rts
	 ;#] Print:
	 ;#[ VBL irrupt:
Prg_sur_vbl:	movem.l	d0-a6,-(a7)
	lea	Storage,a6
	move.b	#NB_LINES,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	Lastpal(a6),a0
	movem.l	(a0),d0-d7
	move	d0,$ffff8242.w
	movem.l	d1-d7,$ffff8244.w
	tst	Nbimages(a6)
	beq.s	Novbl
	subq	#1,Nbimages(a6)
	clr	$ffff8240.w
	clr	d0
	moveq	#1,d1
	move.b	Numsec(a6),d0
	abcd	d1,d0
	subq.b	#1,Cptvbl(a6)
	bne.s	.Nodispx2
	move.b	#50,Cptvbl(a6)
	move.b	d0,Latchnum(a6)
	clr	d0
.Nodispx2	move.b	d0,Numsec(a6)
	move.l	Ptrd.w,a0
	move.l	Rsecran(a0),d0
	move.l	d0,Last_screen(a6)
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	move.l	Rspal(a0),Lastpal(a6)
	cmp.b	#$3b,$fffffc02.w
	bne.s	.Notf1
	move.l	#Bugpal,Lastpal(a6)
.Notf1:	lea	STRUCT_LENGTH(a0),a0
	cmp.l	#Storage+Finscr,a0
	bcs.s	1$
	lea	Ptrscr(a6),a0
1$	move.l	a0,Ptrd.w
	movem.l	(a7)+,d0-a6
	rte
Novbl:	subq.b	#1,Cptvbl(a6)
	bne.s	.Nodispx2
	move.b	#50,Cptvbl(a6)
	move.b	Numsec(a6),Latchnum(a6)
	clr.b	Numsec(a6)
.Nodispx2:	tst.b	Cheat(a6)
	beq.s	.No_CPU
	cmp.b	#$f,$fffffc02.w
	bne.s	.No_CPU
	add	#$333,$ffff8240.w	;indique quand passage en 2
.No_CPU:	movem.l	(a7)+,d0-a6
	rte
	 ;#] VBL irrupt:
	 ;#[ HBL irrupt:
Hbl:
;	move	#$222,$ffff8240.w
	move	#$044,1*2+$ffff8240.w
	move	#$055,2*2+$ffff8240.w
	move	#$066,4*2+$ffff8240.w
	move	#$077,8*2+$ffff8240.w
;	clr	$ffff8240.w
	clr.b	$fffffa1b.w
	rte
	 ;#] HBL irrupt:
	 ;#[ Make polygone:
TEST	MACRO

	;opt	ow-
	IFEQ	\1-\3+1
	movem	\1*4+Segments.w,d0/d1/d4/d5	;a/c
	ELSEIF
	movem	\1*4+Segments.w,d0/d1		;a
	movem	\3*4+Segments.w,d4/d5		;c
	ENDC
	move.l	\2*4+Segments.w,d2		;b
	;opt	ow+

	sub	d2,d5		;d5=yc-yb
	sub	d2,d1		;d1=ya-yb
	swap	d2

	sub	d2,d4		;d4=xc-xb
	sub	d2,d0		;d0=xa-xb

	muls	d1,d4		;d4=(ya-yb)*(xc-xb)
	muls	d0,d5		;d5=(xa-xb)*(yc-yb)

	sub.l	d4,d5
	bmi	\5		;invisible !!!

	ENDM

DRAW	MACRO
	;opt	ow-
	IFEQ	\1-\2+1
	movem	\1*4+Segments.w,d0/d1/d2/d3
	ELSEIF
	movem	\1*4+Segments.w,d0/d1
	movem	\2*4+Segments.w,d2/d3
	ENDC
	;opt	ow+
	lea	\@(pc),a1
	jmp	(a4)
\@
	ENDM
INITDRAW	MACRO
	moveq	#-1,d6		;y minimum
	moveq	#0,d7		;y maximum
	ENDM
;
; d6=ymin
; d7=ymax
;
AFFPOLY:	MACRO
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	\@		;clipp‚ ???
	lea	(Mul160).w,a6
	move.l	usp,a3
	add	0(a6,d6),a3
	IFNE	\1
	addq	#2*\1,a3
	ENDC
	IFEQ	\1
	or	#%0001*4,Planes.w
	IFNE	\2+1
	move	#\2,Palette+2.w	;couleur 2 change
	ENDC
	ENDC
	IFEQ	\1-1
	or	#%0010*4,Planes.w
	IFNE	\2+1
	move.l	#\2<<16+\2,Palette+4.w
	ENDC
	ENDC
	IFEQ	\1-2
	or	#%0100*4,Planes.w
	IFNE	\2+1
	move.l	#\2<<16+\2,d0
	move.l	d0,Palette+8.w
	move.l	d0,Palette+12.w
	ENDC
	ENDC
	IFEQ	\1-3
	or	#%1000*4,Planes.w
	IFNE	\2+1
	move.l	#\2<<16+\2,d0
	move.l	d0,Palette+16.w
	move.l	d0,Palette+20.w
	move.l	d0,Palette+24.w
	move.l	d0,Palette+28.w
	ENDC
	ENDC
	lea	Storage+Left_points,a2
	add	d6,a2			;ptr d‚but
	lea	Right_points-Left_points(a2),a6
	moveq	#-1,d5
	asl	#7,d7			;Hline2-Hline1 !!!
	lea	Fast_draw+(NB_LINES-1)*(Hline2-Hline1),a0
	sub.l	d7,a0

	lea	Left_offsets+LEFT_CLIP*4+CENTRE_X*4,a1
	lea	Right_offsets+(LEFT_CLIP-1)*4+CENTRE_X*4,a5
	jsr	(a0)
\@
	ENDM

AFF3	MACRO
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\3
	AFFPOLY	\1,\2
	ENDM

AFF4	MACRO
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\3
	AFFPOLY	\1,\2
	ENDM

FACE3	MACRO
	TEST	\3,\4,\5,-1,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\3
	AFFPOLY	\1,\2
\@
	ENDM
FACE4	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE5	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE6	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE7	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\9
	DRAW	\9,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE8	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\9
	DRAW	\9,\a
	DRAW	\a,\3
	AFFPOLY	\1,\2
\@
	ENDM

INV3	MACRO
	FACE3	\1,\2,\5,\4,\3
	ENDM
INV4	MACRO
	FACE4	\1,\2,\6,\5,\4,\3
	ENDM
INV5	MACRO
	FACE5	\1,\2,\7,\6,\5,\4,\3
	ENDM
INV6	MACRO
	FACE6	\1,\2,\8,\7,\6,\5,\4,\3
	ENDM
INV7	MACRO
	FACE7	\1,\2,\9,\8,\7,\6,\5,\4,\3
	ENDM
INV8	MACRO
	FACE8	\1,\2,\a,\9,\8,\7,\6,\5,\4,\3
	ENDM
	 ;#] Make polygone:
	 ;#[ Objects:
;
; structure utilis‚e :
;
;	0.l=liste des coordonn‚es
;	4.l=adresse routine affichage
;	8.l=Palette objet
;	12.l=fin
;
; … impl‚menter :
;	- sc‚nario (x,y,z) d‚part+arriv‚e+nb images
;	- zoom maximal … stocker
;
Nbobjets = 13+14
All_objects:	dc.l	Coords_spider,Spider,Palette1
	dc.l	Coords_cube,Cube,Palette2
	dc.l	Coords_tetra,Tetraedre,Palette3
	dc.l	Coords_grille,Grille,Palette4
	dc.l	Coords_spacecraft,Spacecraft,Palette5

	dc.l	Coords_cube2,Cube2,Palette6
	dc.l	Coords_cube3,Cube3,Palette7
	dc.l	Coords_pyramide,Pyramide,Palette8
	dc.l	Coords_carre,Carre,Palette1
	dc.l	Coords_alliance,Alliance,Palette2
	dc.l	Coords_craft,Craft,Palette3
	dc.l	Coords_dodecaedre,Dodecaedre,Palette4

	dc.l	Pspider2,Fspider2,Palette5
	dc.l	Pvcube,Fvcube,Palette6
	dc.l	Prcube,Frcube,Palette7
	dc.l	Pmine,Fmine,Palette8
	dc.l	Ptorus,Ftorus,Palette1
	dc.l	Pchiffre8,Fchiffre8,Palette2
	dc.l	Plettrea,Flettrea,Palette3
	dc.l	Pdalle,Fdalle,Palette4
	dc.l	Puncube,Funcube,Palette5
	dc.l	Pdeuxcube,Fdeuxcube,Palette6
	dc.l	Ppyramide,Fpyramide,Palette7
	dc.l	Pglider2,Fglider2,Palette8
	dc.l	Pdodecaedre,Fdodecaedre,Palette1
	dc.l	Pnscarre,Fnscarre,Palette2
	dc.l	Picosaedre,Ficosaedre,Palette3

Pspider2
	dc.w	12

	dc.w	-15,40,0
	dc.w	15,40,0
	dc.w	10,-20,0
	dc.w	-10,-20,0
	dc.w	-50,-30,-50
	dc.w	-50,-50,-50
	dc.w	50,-30,-50
	dc.w	50,-50,-50
	dc.w	5,-80,-20
	dc.w	-5,-80,-20
	dc.w	-10,40,-10
	dc.w	10,40,-10

Fspider2

;	ailes dessous

	INV4	0,-1,7,2,11,6
	INV4	0,-1,4,10,3,5

;	cotes

	INV3	1,-1,3,10,9
	INV3	1,-1,11,2,8

;	dessous

	INV4	2,-1,11,8,9,10

;	reacteurs

	INV4	1,-1,10,0,1,11
	INV3	2,-1,6,11,1
	INV3	2,-1,4,0,10

;	dessus

	INV4	2,-1,1,0,3,2

;	ailes dessus

	INV4	3,-1,6,1,2,7
	INV4	3,-1,3,0,4,5

;	cockpit

	INV4	3,-1,2,3,9,8
	rts

Pvcube:	dc.w	8
	dc.w	 40,-40,-40
	dc.w	 40, 40,-40
	dc.w	-40, 40,-40
	dc.w	-40,-40,-40
	dc.w	 40,-40, 40
	dc.w	 40, 40, 40
	dc.w	-40, 40, 40
	dc.w	-40,-40, 40

Fvcube:
	;faces internes

	INV4	0,-1,5,1,0,4
	INV4	0,-1,0,3,7,4
	INV4	1,-1,3,2,6,7
	INV4	1,-1,2,1,5,6

	;faces externes

	INV4	2,-1,5,4,0,1
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	3,-1,2,6,5,1
	rts

Prcube:	DC.W	8
	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40

Frcube:
	;faces externes

	INV4	0,-1,1,0,3,2
	INV4	1,-1,5,6,7,4
	INV4	2,-1,5,4,0,1
	INV4	0,-1,0,4,7,3
	INV4	1,-1,3,7,6,2
	INV4	2,-1,2,6,5,1
	RTS

BIG	MACRO
	DC.W	\1*2,\2*2,\3*2
	ENDM
Pmine:
	dc.w	9
	BIG	-10,20,0
	BIG	10,20,0
	BIG	20,10,0
	BIG	20,-10,0
	BIG	10,-20,0
	BIG	-10,-20,0
	BIG	-20,-10,0
	BIG	-20,10,0
	BIG	0,0,30
Fmine:
	INV3	0,-1,0,1,8
	INV3	1,-1,2,3,8
	INV3	0,-1,4,5,8
	INV3	1,-1,6,7,8
	INV3	2,-1,0,8,1
	INV3	3,-1,2,8,3
	INV3	2,-1,4,8,5
	INV3	3,-1,6,8,7
	rts

Ptorus:
	dc.w	24

	BIG	-10,20,5
	BIG	10,20,5
	BIG	20,10,5
	BIG	20,-10,5
	BIG	10,-20,5
	BIG	-10,-20,5
	BIG	-20,-10,5
	BIG	-20,10,5

	BIG	-15,35,0
	BIG	15,35,0
	BIG	35,15,0
	BIG	35,-15,0
	BIG	15,-35,0
	BIG	-15,-35,0
	BIG	-35,-15,0
	BIG	-35,15,0

	BIG	-10,20,-5
	BIG	10,20,-5
	BIG	20,10,-5
	BIG	20,-10,-5
	BIG	10,-20,-5
	BIG	-10,-20,-5
	BIG	-20,-10,-5
	BIG	-20,10,-5

Ftorus:

	;faces internes

	INV4	0,-1,16,0,7,23
	INV4	1,-1,17,1,0,16
	INV4	0,-1,18,2,1,17
	INV4	1,-1,19,3,2,18
	INV4	0,-1,20,4,3,19
	INV4	1,-1,21,5,4,20
	INV4	0,-1,22,6,5,21
	INV4	1,-1,23,7,6,22
	INV4	0,-1,16,0,7,23

	;faces dessus

	INV4	2,-1,0,1,9,8
	INV4	3,-1,1,2,10,9
	INV4	2,-1,2,3,11,10
	INV4	3,-1,3,4,12,11
	INV4	2,-1,4,5,13,12
	INV4	3,-1,5,6,14,13
	INV4	2,-1,6,7,15,14
	INV4	3,-1,7,0,8,15

	;faces dessous

	INV4	2,-1,9,17,16,8
	INV4	3,-1,10,18,17,9
	INV4	2,-1,11,19,18,10
	INV4	3,-1,12,20,19,11
	INV4	2,-1,13,21,20,12
	INV4	3,-1,14,22,21,13
	INV4	2,-1,15,23,22,14
	INV4	3,-1,8,16,23,15
	rts

Pchiffre8:
	dc.w	14

	BIG	-20,30,0
	BIG	20,30,0
	BIG	-10,20,0
	BIG	10,20,0
	BIG	-10,5,0
	BIG	10,5,0
	BIG	-20,0,0
	BIG	20,0,0
	BIG	-10,-5,0
	BIG	10,-5,0
	BIG	-10,-20,0
	BIG	10,-20,0
	BIG	-20,-30,0
	BIG	20,-30,0

Fchiffre8:
	INV4	0,-1,1,0,2,3
	INV4	0,-1,0,6,4,2
	INV4	0,-1,1,3,5,7
	INV6	0,-1,5,4,6,8,9,7
	INV4	0,-1,6,12,10,8
	INV4	0,-1,9,11,13,7
	INV4	0,-1,10,12,13,11
	rts

Plettrea:
	dc.w	11

	BIG	-5,20,5
	BIG	5,20,5
	BIG	0,10,5
	BIG	-8,-5,5
	BIG	8,-5,5
	BIG	-10,-10,5
	BIG	10,-10,5
	BIG	-25,-20,5
	BIG	-15,-20,5
	BIG	15,-20,5
	BIG	25,-20,5

Flettrea:
	INV4	0,-1,0,7,8,1
	INV4	0,-1,9,10,1,0
	INV4	0,-1,3,5,6,4

	INV4	1,-1,0,1,8,7
	INV4	1,-1,9,0,1,10
	INV4	1,-1,3,4,6,5
	rts

Pdalle:
	dc.w	4
	DC.W	50,50,0
	DC.W	50,-50,0
	DC.W	-50,-50,0
	DC.W	-50,50,0

Fdalle:
	INV4	0,-1,3,2,1,0
	INV4	1,-1,0,1,2,3
	rts

Puncube:
	dc.w	8

	DC.W	-35,35,15
	DC.W	-5,35,15
	DC.W	-5,5,15
	DC.W	-35,5,15
	DC.W	-35,35,-15
	DC.W	-5,35,-15
	DC.W	-5,5,-15
	DC.W	-35,5,-15

Funcube:
	INV4	0,-1,1,2,6,5
	INV4	1,-1,3,2,1,0
	INV4	0,-1,1,5,4,0
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	1,-1,4,5,6,7
	rts

Pdeuxcube:
	dc.w	16

	DC.W	-40,40,15
	DC.W	-10,40,15
	DC.W	-10,10,15
	DC.W	-40,10,15
	DC.W	-40,40,-15
	DC.W	-10,40,-15
	DC.W	-10,10,-15
	DC.W	-40,10,-15

	DC.W	10,40,15
	DC.W	40,40,15
	DC.W	40,10,15
	DC.W	10,10,15
	DC.W	10,40,-15
	DC.W	40,40,-15
	DC.W	40,10,-15
	DC.W	10,10,-15

Fdeuxcube:
	INV4	0,-1,1,2,6,5
	INV4	0,-1,8,12,15,11
	INV4	1,-1,3,2,1,0
	INV4	0,-1,1,5,4,0
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	0,-1,4,5,6,7		;6
	INV4	1,-1,11,10,9,8
	INV4	0,-1,9,13,12,8
	INV4	3,-1,11,15,14,10
	INV4	0,-1,12,13,14,15	;6
	INV4	0,-1,9,10,14,13
	rts

Ppyramide:
	dc.w	13

	DC.W	-30,30,0
	DC.W	30,30,0
	DC.W	30,-30,0
	DC.W	-30,-30,0
	DC.W	-20,20,20
	DC.W	20,20,20
	DC.W	20,-20,20
	DC.W	-20,-20,20
	DC.W	-15,15,30
	DC.W	15,15,30
	DC.W	15,-15,30
	DC.W	-15,-15,30
	DC.W	0,0,60

Fpyramide:

	INV4	0,-1,7,6,5,4
	INV4	0,-1,8,9,10,11
	INV4	1,-1,0,1,2,3
	INV3	2,-1,12,9,8
	INV4	2,-1,5,1,0,4
	INV3	3,-1,12,10,9
	INV4	3,-1,6,2,1,5
	INV3	1,-1,12,11,10	;4
	INV4	2,-1,7,3,2,6	;4
	INV3	3,-1,12,8,11	;4
	INV4	1,-1,4,0,3,7	;4
	rts

Pglider2:
	dc.w	8

	DC.W	-20,40,0
	DC.W	20,40,0
	DC.W	-40,-40,0
	DC.W	40,-40,0
	DC.W	-20,-40,10
	DC.W	20,-40,10
	DC.W	-20,-40,-10
	DC.W	20,-40,-10

Fglider2:
	INV4	0,-1,0,4,5,1
	INV3	1,-1,0,2,4
	INV3	1,-1,1,5,3
	INV4	2,-1,0,1,7,6
	INV3	3,-1,0,6,2
	INV3	3,-1,1,3,7
	INV6	2,-1,4,2,6,7,3,5
	rts

DODEC	MACRO
	DC.W	\1/6/2,\2/6/2,\3/6/2
	ENDM

Pdodecaedre:
	DC.W	20

	DODEC	283,631,390
	DODEC	458,631,-149
	DODEC	0,631,-482
	DODEC	-458,631,-149
	DODEC	-283,631,390
	DODEC	-458,149,631
	DODEC	0,-149,780
	DODEC	458,149,631
	DODEC	742,-149,241
	DODEC	742,149,-241
	DODEC	458,-149,-631
	DODEC	0,149,-780
	DODEC	-458,-149,-631
	DODEC	-742,149,-241
	DODEC	-742,-149,241
	DODEC	-283,-631,-390
	DODEC	-458,-631,149
	DODEC	0,-631,482
	DODEC	458,-631,149
	DODEC	283,-631,-390

Fdodecaedre:
	INV5	0,-1,0,1,2,3,4
	INV5	1,-1,0,4,5,6,7
	INV5	2,-1,0,7,8,9,1
	INV5	1,-1,1,9,10,11,2
	INV5	2,-1,2,11,12,13,3
	INV5	3,-1,3,13,14,5,4
	INV5	0,-1,12,15,16,14,13
	INV5	2,-1,14,16,17,6,5
	INV5	3,-1,6,17,18,8,7
	INV5	0,-1,8,18,19,10,9
	INV5	3,-1,11,10,19,15,12
	INV5	1,-1,17,16,15,19,18
	RTS

Pnscarre:
	DC.W	28

	DC.W	-10,10,-30
	DC.W	10,10,-30
	DC.W	10,-10,-30
	DC.W	-10,-10,-30

	DC.W	-20,20,-20
	DC.W	20,20,-20
	DC.W	20,-20,-20
	DC.W	-20,-20,-20

	DC.W	-30,30,-10
	DC.W	30,30,-10
	DC.W	30,-30,-10
	DC.W	-30,-30,-10

	DC.W	-40,40,0
	DC.W	40,40,0
	DC.W	40,-40,0
	DC.W	-40,-40,0

	DC.W	-30,30,10
	DC.W	30,30,10
	DC.W	30,-30,10
	DC.W	-30,-30,10

	DC.W	-20,20,20
	DC.W	20,20,20
	DC.W	20,-20,20
	DC.W	-20,-20,20

	DC.W	-10,10,30
	DC.W	10,10,30
	DC.W	10,-10,30
	DC.W	-10,-10,30

Fnscarre:
	INV4	0,-1,3,2,1,0
	INV4	1,-1,7,6,5,4
	INV4	2,-1,11,10,9,8
	INV4	3,-1,15,14,13,12
	INV4	2,-1,19,18,17,16
	INV4	1,-1,23,22,21,20
	INV4	0,-1,27,26,25,24

	;faces autre cote

	INV4	0,-1,24,25,26,27
	INV4	1,-1,20,21,22,23
	INV4	2,-1,16,17,18,19
	INV4	3,-1,12,13,14,15
	INV4	2,-1,8,9,10,11
	INV4	1,-1,4,5,6,7
	INV4	0,-1,0,1,2,3
	RTS
DIM	MACRO
	DC.W	\1/2,\2/2,\3/2
	ENDM

Picosaedre:
	DC.W	12

	DIM	89,0,44
	DIM	27,85,44
	DIM	-72,52,44
	DIM	-72,-52,44
	DIM	27,-85,44
	DIM	0,0,100
	DIM	0,0,-100
	DIM	72,52,-44
	DIM	-27,85,-44
	DIM	-89,0,-44
	DIM	-27,-85,-44
	DIM	72,-52,-44
;
; BUG ICOSAEDRE :
;	SOUSTRAIRE 1 A CHAQUE NUMERO DE SOMMET !!!!
;
FAC3	MACRO
	INV3	\1,\2,(\3-1),(\4-1),(\5-1)
	ENDM
Ficosaedre:
	FAC3	0,-1,1,2,6
	FAC3	1,-1,2,3,6
	FAC3	2,-1,3,4,6
	FAC3	3,-1,4,5,6
	FAC3	0,-1,5,1,6
	FAC3	1,-1,12,1,5
	FAC3	2,-1,12,8,1
	FAC3	3,-1,8,2,1
	FAC3	0,-1,9,2,8
	FAC3	1,-1,9,3,2
	FAC3	2,-1,9,10,3
	FAC3	3,-1,10,4,3
	FAC3	0,-1,10,11,4
	FAC3	1,-1,11,5,4
	FAC3	0,-1,11,12,5
	FAC3	1,-1,7,8,12
	FAC3	3,-1,7,9,8
	FAC3	0,-1,7,10,9
	FAC3	1,-1,7,11,10
	FAC3	2,-1,7,12,11
	RTS

Spider:	FACE3	0,-1,2,0,3
	FACE4	1,-1,0,1,4,3
	FACE3	2,-1,1,5,4
	FACE4	3,-1,2,3,7,6
	FACE4	0,-1,3,4,8,7
	FACE4	1,-1,4,5,9,8
	FACE3	2,-1,6,7,10
	FACE4	3,-1,7,8,11,10
	FACE3	0,-1,8,9,11
	FACE4	1,-1,12,0,2,14
	FACE4	2,-1,12,13,1,0
	FACE4	3,-1,5,1,13,15
	FACE4	0,-1,9,5,15,17
	FACE4	1,-1,11,9,17,19
	FACE4	2,-1,10,11,19,18
	FACE4	3,-1,6,10,18,16
	FACE4	0,-1,2,6,16,14
	FACE4	1,-1,20,21,13,12
	FACE3	2,-1,12,14,20
	FACE3	3,-1,20,14,16
	FACE3	0,-1,20,16,18
	FACE4	1,-1,18,19,21,20
	FACE3	2,-1,21,19,17
	FACE3	3,-1,15,21,17
	FACE3	0,-1,13,21,15
	RTS

Spacecraft:	FACE4	0,-1,0,1,4,3	;ABED
	FACE3	1,-1,1,5,4,-1	;BFE
	FACE3	1,-1,0,3,2,-1	;ADC
	FACE3	2,-1,5,1,7,-1	;FBH
	FACE3	2,-1,6,0,2,-1	;GAC
	FACE4	0,-1,6,7,1,0	;GHBA
	FACE4	3,-1,3,4,7,6	;DEHG
	FACE3	0,-1,2,3,6,-1	;CDG
	FACE3	0,-1,4,5,7,-1	;EFH
	RTS
;
; affichage d'un cube
;
Cube:
	TEST	0,1,2,3,Not0
	AFF4	0,$055,0,1,2,3
	bra	Not1
Not0:	FACE4	0,$022,7,6,5,4
Not1:	TEST	0,3,7,4,Not2
	AFF4	1,$066,0,3,7,4
	bra	Not3
Not2:	FACE4	1,$033,2,1,5,6
Not3:	TEST	3,2,6,7,Not4
	AFF4	2,$077,3,2,6,7
	bra	Not5
Not4:	FACE4	2,$044,0,4,5,1
Not5:	rts
;
; affichage d'un t‚traŠdre
;
Tetraedre:	FACE3	0,-1,0,2,1
	FACE3	1,-1,0,3,2
	FACE3	2,-1,0,1,3
	FACE3	3,-1,1,2,3
	rts
Grille:	INITDRAW
;	TEST	0,5,6,1,Laba0
	TEST	0,20,24,4,Laba0
;	AFF4	0,$700,0,20,24,4
	AFF4	0,$700,0,5,6,1
	AFF4	0,-1,8,13,14,9
	AFF4	0,-1,12,17,18,13
	AFF4	0,-1,16,21,22,17
	AFF4	1,$070,1,6,7,2
	AFF4	2,$007,2,7,8,3
	AFF4	3,$777,3,8,9,4
	AFF4	1,-1,5,10,11,6
	AFF4	2,-1,6,11,12,7
	AFF4	3,-1,7,12,13,8
	AFF4	2,-1,10,15,16,11
	AFF4	3,-1,11,16,17,12
	AFF4	1,-1,13,18,19,14
	AFF4	3,-1,15,20,21,16
	AFF4	1,-1,17,22,23,18
	AFF4	2,-1,18,23,24,19
	rts
Laba0:
;	AFF4	0,$777,0,4,24,20
	AFF4	0,$777,0,1,6,5
	AFF4	0,-1,8,9,14,13
	AFF4	0,-1,12,13,18,17
	AFF4	0,-1,16,17,22,21
	AFF4	1,$007,1,2,7,6
	AFF4	2,$070,2,3,8,7
	AFF4	3,$700,3,4,9,8
	AFF4	1,-1,5,6,11,10
	AFF4	2,-1,6,7,12,11
	AFF4	3,-1,7,8,13,12
	AFF4	2,-1,10,11,16,15
	AFF4	3,-1,11,12,17,16
	AFF4	1,-1,13,14,19,18
	AFF4	3,-1,15,16,21,20
	AFF4	1,-1,17,18,23,22
	AFF4	2,-1,18,19,24,23
	rts

RED	MACRO
	DC.W	\1/2,\2/2,\3/2
	ENDM
		* Exemple de forme 3D ---> un cube
Coords_cube2:
	dc.w	8
	RED	-100,-100,-100
	RED	100,-100,-100
	RED	100,100,-100
	RED	-100,100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,100,100
	RED	-100,100,100
Cube2:
	INV4	0,-1,4,5,6,7
	INV4	1,-1,7,6,2,3
	INV4	2,-1,0,1,5,4
	INV4	0,-1,4,7,3,0
	INV4	1,-1,1,2,6,5
	INV4	2,-1,3,2,1,0
	RTS

Coords_cube3:
	dc.w	8
	RED	-100,-100,-100
	RED	100,-100,-100
	RED	100,100,-100
	RED	-100,100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,100,100
	RED	-100,100,100
Cube3:
	INV4	0,-1,3,7,4,0
	INV4	1,-1,0,4,5,1
	INV4	0,-1,1,5,6,2
	INV4	1,-1,2,6,7,3
	INV4	2,-1,0,4,7,3
	INV4	3,-1,1,5,4,0
	INV4	2,-1,2,6,5,1
	INV4	3,-1,3,7,6,2
	RTS

Coords_pyramide:
	dc.w	5
	RED	0,150,0
	RED	-100,0,-100
	RED	100,0,-100
	RED	100,0,100
	RED	-100,0,100
Pyramide:
	INV3	0,-1,0,2,1
	INV3	1,-1,0,3,2
	INV3	2,-1,0,4,3
	INV3	3,-1,0,1,4
	INV4	0,-1,1,2,3,4
	RTS

Coords_carre:
	dc.w	4
	RED	-100,-100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,-100,-100
Carre:
	INV4	0,-1,0,1,2,3
	INV4	0,-1,3,2,1,0
	RTS

Coords_alliance:
	dc.w	22		;22 points.
	RED	-32,80,-32	;Points No 0
	RED	-32,80,32	;Points No 1
	RED	32,80,-32	;Points No 2
	RED	32,80,32	;Points No 3
	RED	112,-80,-32	;Points No 4
	RED	112,-80,32	;Points No 5
	RED	48,-80,-32	;Points No 6
	RED	48,-80,32	;Points No 7
	RED	32,-48,-32	;Points No 8
	RED	32,-48,32	;Points No 9
	RED	-32,-48,-32	;Points No 10
	RED	-32,-48,32	;Points No 11
	RED	-48,-80,-32	;Points No 12
	RED	-48,-80,32	;Points No 13
	RED	-112,-80,-32	;Points No 14
	RED	-112,-80,32	;Points No 15
	RED	-16,-16,-32	;Points No 16
	RED	-16,-16,32	;Points No 17
	RED	16,-16,-32	;Points No 18
	RED	16,-16,32	;Points No 19
	RED	0,16,-32	;Points No 20
	RED	0,16,32		;Points No 21

Alliance:
	INV4	0,-1,19,21,20,18
	INV4	1,-1,21,17,16,20
	INV4	0,-1,17,19,18,16
	INV4	1,-1,1,3,2,0
	INV4	1,-1,5,7,6,4
	INV4	1,-1,9,11,10,8
	INV4	1,-1,13,15,14,12
	INV4	0,-1,3,5,4,2
	INV4	0,-1,7,9,8,6
	INV4	0,-1,11,13,12,10
	INV4	0,-1,15,1,0,14
	INV4	2,-1,16,18,8,10
;	INV7	2,-1,0,2,20,16,10,12,14
	FACE7	2,-1,20,2,0,14,12,10,16

;	INV6	2,-1,2,4,6,8,18,20
	FACE6	2,-1,6,4,2,20,18,8

	INV4	3,-1,11,9,19,17
;	INV7	3,-1,1,15,13,11,17,21,3
	FACE7	3,-1,13,15,1,3,21,17,11

;	INV6	3,-1,7,5,3,21,19,9
	FACE6	3,-1,3,5,7,9,19,21
	RTS

Coords_craft:
	dc.w	14		;14 points.
	RED	0,0,100		;Points No 0
	RED	0,10,10		;Points No 1
	RED	0,-10,10	;Points No 2
	RED	-21,0,10	;Points No 3
	RED	19,0,10		;Points No 4
	RED	0,19,-21	;Points No 5
	RED	0,12,-100	;Points No 6
	RED	0,-6,-100	;Points No 7
	RED	-12,0,-100	;Points No 8
	RED	12,0,-100	;Points No 9
	RED	-165,0,-61	;Points No 10
	RED	-168,0,-85	;Points No 11
	RED	168,0,-85	;Points No 12
	RED	168,0,-61	;Points No 13

Craft:
	INV3	0,-1,3,1,5
	INV3	0,-1,1,4,5
	INV3	1,-1,3,0,1
	INV3	2,-1,0,4,1
	INV3	3,-1,2,0,3
	INV3	1,-1,2,4,0
	INV4	1,-1,8,3,5,6
	INV4	2,-1,4,9,6,5
	INV4	3,-1,7,2,3,8
	INV4	1,-1,4,2,7,9
	INV4	0,-1,9,7,8,6
	INV4	0,-1,3,8,11,10
	INV4	0,-1,4,13,12,9
	INV4	0,-1,10,11,8,3
	INV4	0,-1,9,12,13,4
	RTS

DODE	MACRO
	DC.W	\1/8/2,\2/8/2,\3/8/2
	ENDM

Coords_dodecaedre
	DC.W	20

	DODE	283,631,390
	DODE	458,631,-149
	DODE	0,631,-482
	DODE	-458,631,-149
	DODE	-283,631,390
	DODE	-458,149,631
	DODE	0,-149,780
	DODE	458,149,631
	DODE	742,-149,241
	DODE	742,149,-241
	DODE	458,-149,-631
	DODE	0,149,-780
	DODE	-458,-149,-631
	DODE	-742,149,-241
	DODE	-742,-149,241
	DODE	-283,-631,-390
	DODE	-458,-631,149
	DODE	0,-631,482
	DODE	458,-631,149
	DODE	283,-631,-390

Dodecaedre:
	INV5	0,-1,0,1,2,3,4
	INV5	1,-1,0,4,5,6,7
	INV5	2,-1,0,7,8,9,1
	INV5	3,-1,1,9,10,11,2
	INV5	0,-1,2,11,12,13,3
	INV5	1,-1,3,13,14,5,4
	INV5	2,-1,12,15,16,14,13
	INV5	3,-1,14,16,17,6,5
	INV5	0,-1,6,17,18,8,7
	INV5	1,-1,8,18,19,10,9
	INV5	2,-1,11,10,19,15,12
	INV5	3,-1,17,16,15,19,18
	RTS

;
NEWPAL	MACRO
	DC.W	$0,\1,\2,\2,\3,\3,\3,\3
	DCB.W	8,\4
	ENDM

Palette1:	NEWPAL	$756,$645,$534,$423
Palette2:	NEWPAL	$456,$345,$234,$123
Palette3:	NEWPAL	$565,$454,$343,$232
Palette4:	NEWPAL	$656,$545,$434,$323
Palette5:	NEWPAL	$067,$057,$047,$037
Palette6:	NEWPAL	$766,$755,$744,$733
Palette7:	NEWPAL	$762,$752,$742,$732
Palette8:	NEWPAL	$666,$555,$444,$333
Palette9:	NEWPAL	$457,$346,$235,$124

;Palette1:	DC.W	$000
;	DC.W	$700		;0001
;	DC.W	$070		;0010
;	DC.W	$770		;0011
;	DC.W	$007		;0100
;	DC.W	$707		;0101
;	DC.W	$077		;0110
;	DC.W	$777		;0111
;
;	DCB.W	8,$555

Bugpal:	DC.W	$000
	DC.W	$200		;0001
	DC.W	$020		;0010
	DC.W	$770		;0011
	DC.W	$002		;0100
	DC.W	$707		;0101
	DC.W	$077		;0110
	DC.W	$777		;0111

	dc.w	$222
	dcb.w	7,$555
	 ;#] Objects:
	 ;#[ Generate Filler:
Gendraw:	move	#NB_LINES-1,d7
	lea	Fast_draw,a6
1$	lea	Hline1(pc),a0
	move	#(Hline2-Hline1)/2-1,d0
2$	move	(a0)+,(a6)+
	dbf	d0,2$
	dbf	d7,1$
	move	#$4e75,(a6)+		;rts
	cmp.l	#Findraw,a6
	beq.s	.Ok
	illegal
.Ok:	rts
;
; registres utilis‚s :
;
PTRGAU	EQUR	a2		;points gauches
PTRDRO	EQUR	a6		;points droits

OFFGAU	EQUR	a1		;offsets gauches
OFFDRO	EQUR	a5		;offsets droits

ADECR	EQUR	a3		;offset ‚cran
SCRATCH	EQUR	a0
XGAU	EQUR	d0
XDRO	EQUR	d1
FFFF	EQUR	d5		;$FFFF
;
; la routine suivante doit faire exactement 128 octets !!!
;
Hline1:
	moveq	#-4,XGAU
	and	(PTRGAU)+,XGAU
	moveq	#-4,XDRO
	and	(PTRDRO)+,XDRO

	move.l	(OFFGAU,XGAU.w),XGAU
	move.l	(OFFDRO,XDRO.w),XDRO

	sub	XDRO,XGAU
	bge.s	.Little_line

	move.l	ADECR,SCRATCH
	add	XDRO,SCRATCH
	swap	XDRO
	or	XDRO,(SCRATCH)
	add	XGAU,SCRATCH
	asr	#1,XGAU
	jmp	.Loopline+4(pc,XGAU.w)

.Little_line:
	bne.s	.Nohline

	and.l	XDRO,XGAU
	swap	XGAU
	or	XGAU,(ADECR,XDRO.w)
	bra.s	.Nohline
x	set	18*8
	rept	18
	move	FFFF,x(SCRATCH)
x	set	x-8
	endr
.Loopline:
	swap	XGAU
	or	XGAU,(SCRATCH)
.Nohline:
	lea	160(ADECR),ADECR
Hline2:
	 ;#] Generate Filler:
	 ;#[ Matricial Node:
; PORTION DE CODE EffECTUANT LES PROJECTIONS DES POINTS

NXTANG	MACRO
	CLR	D0		;and 255
	MOVE.B	\1.W,D0
	ADD.B	\2.W,D0
	MOVE.B	D0,\2.W
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(a2,D0.W),\3
	ENDM
;
; CALCUL OPTIMISE DES POINTS PROJETES
;
; CALCUL DE LA MATRICE CONSTANTE DE PROJECTION
;
; CHANGE L'ANGLE DE ROTATION ET CALCULE LES SINUS ET COSINUS ASSOCIES
;
; SX=SIN/COS ANGLE X,SY=SIN/COS ANGLE Y,SZ=SIN/COS ANGLE Z
; L14=ANGLE ROT X,L16=ANGLE ROT Y,L3C=ANGLE ROT Z
; ROTX,ROTY,ROTZ=ANGLES COURANTS
;
sx	equr	d2
cx	equr	d3
sy	equr	d4
cy	equr	d5
sz	equr	d6
cz	equr	d7
;
; CHANGEMENT D'ANGLE DE ROTATION
;   (CONSTANTES POUR L'INSTANT)
;
Pushd0:	dc.w	0
Calcobj:
	move	(A0)+,Pushd0		;nb points

	LEA	Sincos(PC),a2
	NXTANG	Rotatex,Rotx,sx/cx	;x
	NXTANG	Rotatey,Roty,sy/cy	;y
	NXTANG	Rotatez,Rotz,sz/cz	;z
;
; CALCULE LA MATRICE DE PROJECTION
;
	lea	Matrice.w,a2
	move.l	a2,usp
	neg	sz		;rotation en z buggee !!!
	move	cy,d0
	muls	cz,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a2)+	;cy*cz
	move	cy,d0
	muls	sz,d0
	add.l	d0,d0
	swap	d0
	move	d0,a3
	muls	cx,d0
	move	sx,d1
	muls	sy,d1
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,(a2)+	;-(cy*sz*cx+sx*sy)
	move	a3,d0		;cy*sz
	muls	sx,d0
	move	sy,d1
	muls	cx,d1
	sub.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a2)+	;cy*sz*sx-sy*cx
	move	sz,(a2)+	;sz
	move	cz,d0
	muls	cx,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a2)+	;cx*cz
	move	cz,d0
	muls	sx,d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,(a2)+	;-sx*cz
	muls	sy,cz
	add.l	cz,cz
	swap	cz
	move	cz,(a2)+	;sy*cz
	muls	sz,sy
	add.l	sy,sy
	swap	sy
	move	cy,d0
	muls	sx,d0
	move	sy,d1
	muls	cx,d1
	sub.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a2)+	;cy*sx-sy*sz*cx
	muls	sy,sx
	muls	cy,cx
	add.l	sx,cx
	add.l	cx,cx
	swap	cx
	move	cx,(a2)+	;sy*sz*sx+cy*cx
	move	#320,a3		;xmin
	sub	a4,a4		;xmax
	move	#NB_LINES-1,a5	;ymin
	sub	a6,a6		;ymax
;
; a0=source
; a1=destination
; a2=ptr matrice
; a3=xmin
; a4=xmax
; a5=ymin
; a6=ymax
; usp=constante
; d0/d1/d2/d3/d6/d7 scratch‚s
; d4=zoom
; d5=non scratche !!!!
;
	move	Dist.w,d4
	move	Pushd0,d5
	subq	#1,d5
Calcul:	move.l	usp,a2
	movem	(a0)+,d1/d2/d3
	move	d1,d6
	muls	(a2)+,d6	;x
	move	d2,d0
	muls	(a2)+,d0
	add.l	d0,d6
	move	d3,d0
	muls	(a2)+,d0
	add.l	d0,d6

	move	d1,d7
	muls	(a2)+,d7	;y
	move	d2,d0
	muls	(a2)+,d0
	add.l	d0,d7
	move	d3,d0
	muls	(a2)+,d0
	add.l	d0,d7

	muls	(a2)+,d1	;z
	muls	(a2)+,d2
	add.l	d2,d1
	muls	(a2)+,d3
	add.l	d3,d1

	swap	d1
	sub	d4,d1

; mettre trapv ici !!!!
; ou ble.s bug

	IFEQ	1
	cmp	min,d1
	bge.s	.notmin
	move	d1,min
.Notmin:	cmp	max,d1
	ble.s	.notmax
	move	d1,max
.Notmax:
	ENDC

	asr.l	#8,d6		;x*4
	asr.l	#8,d7

	divs	d1,d6
	divs	d1,d7

	add	d6,d6
	add	d6,d6
	add	#NB_LINES/2,d7

	move	d6,(a1)+
	move	d7,(a1)+

	cmp	a3,d6		;xmin
	bge.s	.Noxn
	move	d6,a3
.Noxn:	cmp	a4,d6		;xmax
	ble.s	.Noxx
	move	d6,a4
.Noxx:	cmp	a5,d7		;ymin
	bge.s	.Noyn
	move	d7,a5
.Noyn:	cmp	a6,d7		;ymax
	ble.s	.Noyx
	move	d7,a6
.Noyx:	dbf	d5,Calcul
	move	a3,d0
	asr	#2,d0
	add	#CENTRE_X,d0
	bpl.s	.1
	clr	d0
.1:	move	d0,a3
	move	a4,d0
	asr	#2,d0
	add	#CENTRE_X,d0
	cmp	#320,d0
	blo.s	.2
	move	#320-1,d0
.2:	move	d0,a4
	move	a5,d0
	bpl.s	.3
	sub	a5,a5
.3:	cmp	#NB_LINES,a6
	blo.s	.4
	move	#NB_LINES-1,a6
.4:	move.l	Ptwr.w,a0
	movem	a3/a4/a5/a6,Rsxmin(a0)
	rts

;Min:	dc.w	$7fff
;Max:	dc.w	$8000

		;#[ Trigonometric Table:
Sincos:		;table de sinus/cosinus
	dc.w	$0000,$7fff,$0324,$7ff5,$0647,$7fd7,$096a,$7fa6
	dc.w	$0c8b,$7f61,$0fab,$7f08,$12c7,$7e9c,$15e1,$7e1c
	dc.w	$18f8,$7d89,$1c0b,$7ce2,$1f19,$7c29,$2223,$7b5c
	dc.w	$2527,$7a7c,$2826,$7989,$2b1e,$7883,$2e10,$776b
	dc.w	$30fb,$7640,$33de,$7503,$36b9,$73b5,$398c,$7254
	dc.w	$3c56,$70e1,$3f16,$6f5e,$41cd,$6dc9,$447a,$6c23
	dc.w	$471c,$6a6c,$49b3,$68a5,$4c3f,$66ce,$4ebf,$64e7
	dc.w	$5133,$62f1,$539a,$60eb,$55f4,$5ed6,$5842,$5cb3
	dc.w	$5a81,$5a81,$5cb3,$5842,$5ed6,$55f4,$60eb,$539a
	dc.w	$62f1,$5133,$64e7,$4ebf,$66ce,$4c3f,$68a5,$49b3
	dc.w	$6a6c,$471c,$6c23,$447a,$6dc9,$41cd,$6f5e,$3f16
	dc.w	$70e1,$3c56,$7254,$398c,$73b5,$36b9,$7503,$33de
	dc.w	$7640,$30fb,$776b,$2e10,$7883,$2b1e,$7989,$2826
	dc.w	$7a7c,$2527,$7b5c,$2223,$7c29,$1f19,$7ce2,$1c0b
	dc.w	$7d89,$18f8,$7e1c,$15e1,$7e9c,$12c7,$7f08,$fab
	dc.w	$7f61,$0c8b,$7fa6,$096a,$7fd7,$0647,$7ff5,$0324
	dc.w	$7fff,$0000,$7ff5,$fcdb,$7fd7,$f9b8,$7fa6,$f695
	dc.w	$7f61,$f374,$7f08,$f054,$7e9c,$ed38,$7e1c,$ea1e
	dc.w	$7d89,$e707,$7ce2,$e3f4,$7c29,$e0e6,$7b5c,$dddc
	dc.w	$7a7c,$dad8,$7989,$d7d9,$7883,$d4e1,$776b,$d1ef
	dc.w	$7640,$cf04,$7503,$cc21,$73b5,$c946,$7254,$c673
	dc.w	$70e1,$c3a9,$6f5e,$c0e9,$6dc9,$be32,$6c23,$bb85
	dc.w	$6a6c,$b8e3,$68a5,$b64c,$66ce,$b3c0,$64e7,$b140
	dc.w	$62f1,$aecc,$60eb,$ac65,$5ed6,$aa0b,$5cb3,$a7bd
	dc.w	$5a81,$a57e,$5842,$a34c,$55f4,$a129,$539a,$9f14
	dc.w	$5133,$9d0e,$4ebf,$9b18,$4c3f,$9931,$49b3,$975a
	dc.w	$471c,$9593,$447a,$93dc,$41cd,$9236,$3f16,$90a1
	dc.w	$3c56,$8f1e,$398c,$8dab,$36b9,$8c4a,$33de,$8afc
	dc.w	$30fb,$89bf,$2e10,$8894,$2b1e,$877c,$2826,$8676
	dc.w	$2527,$8583,$2223,$84a3,$1f19,$83d6,$1c0b,$831d
	dc.w	$18f8,$8276,$15e1,$81e3,$12c7,$8163,$0fab,$80f7
	dc.w	$0c8b,$809e,$096a,$8059,$0647,$8028,$0324,$800a
	dc.w	$0000,$8001,$fcdb,$800a,$f9b8,$8028,$f695,$8059
	dc.w	$f374,$809e,$f054,$80f7,$ed38,$8163,$ea1e,$81e3
	dc.w	$e707,$8276,$e3f4,$831d,$e0e6,$83d6,$dddc,$84a3
	dc.w	$dad8,$8583,$d7d9,$8676,$d4e1,$877c,$d1ef,$8894
	dc.w	$cf04,$89bf,$cc21,$8afc,$c946,$8c4a,$c673,$8dab
	dc.w	$c3a9,$8f1e,$c0e9,$90a1,$be32,$9236,$bb85,$93dc
	dc.w	$b8e3,$9593,$b64c,$975a,$b3c0,$9931,$b140,$9b18
	dc.w	$aecc,$9d0e,$ac65,$9f14,$aa0b,$a129,$a7bd,$a34c
	dc.w	$a57e,$a57e,$a34c,$a7bd,$a129,$aa0b,$9f14,$ac65
	dc.w	$9d0e,$aecc,$9b18,$b140,$9931,$b3c0,$975a,$b64c
	dc.w	$9593,$b8e3,$93dc,$bb85,$9236,$be32,$90a1,$c0e9
	dc.w	$8f1e,$c3a9,$8dab,$c673,$8c4a,$c946,$8afc,$cc21
	dc.w	$89bf,$cf04,$8894,$d1ef,$877c,$d4e1,$8676,$d7d9
	dc.w	$8583,$dad8,$84a3,$dddc,$83d6,$e0e6,$831d,$e3f4
	dc.w	$8276,$e707,$81e3,$ea1e,$8163,$ed38,$80f7,$f054
	dc.w	$809e,$f374,$8059,$f695,$8028,$f9b8,$800a,$fcdb
	dc.w	$8001,$ffff,$800a,$0324,$8028,$0647,$8059,$096a
	dc.w	$809e,$0c8b,$80f7,$0fab,$8163,$12c7,$81e3,$15e1
	dc.w	$8276,$18f8,$831d,$1c0b,$83d6,$1f19,$84a3,$2223
	dc.w	$8583,$2527,$8676,$2826,$877c,$2b1e,$8894,$2e10
	dc.w	$89bf,$30fb,$8afc,$33de,$8c4a,$36b9,$8dab,$398c
	dc.w	$8f1e,$3c56,$90a1,$3f16,$9236,$41cd,$93dc,$447a
	dc.w	$9593,$471c,$975a,$49b3,$9931,$4c3f,$9b18,$4ebf
	dc.w	$9d0e,$5133,$9f14,$539a,$a129,$55f4,$a34c,$5842
	dc.w	$a57e,$5a81,$a7bd,$5cb3,$aa0b,$5ed6,$ac65,$60eb
	dc.w	$aecc,$62f1,$b140,$64e7,$b3c0,$66ce,$b64c,$68a5
	dc.w	$b8e3,$6a6c,$bb85,$6c23,$be32,$6dc9,$c0e9,$6f5e
	dc.w	$c3a9,$70e1,$c673,$7254,$c946,$73b5,$cc21,$7503
	dc.w	$cf04,$7640,$d1ef,$776b,$d4e1,$7883,$d7d9,$7989
	dc.w	$dad8,$7a7c,$dddc,$7b5c,$e0e6,$7c29,$e3f4,$7ce2
	dc.w	$e707,$7d89,$ea1e,$7e1c,$ed38,$7e9c,$f054,$7f08
	dc.w	$f374,$7f61,$f695,$7fa6,$f9b8,$7fd7,$fcdb,$7ff5
		;#] Trigonometric Table:
	 ;#] Matricial Node:
	 ;#[ CLS:
Cls:	movem	Rsxmin(a0),d4-d7
;
; d4=xmin
; d5=xmax
; d6=ymin
; d7=ymax
	add	#15,d5
	moveq	#-16,d1
	and	d1,d5
	and	d4,d1
	sub	d1,d5		;d5=nb pixels … Effacer (multiple de 16)
	ble.s	.Nocls
	asr	#1,d1
	move.l	usp,a6
	add	d1,a6

	lea	Mul160.w,a1

	moveq	#0,d0
	lsr	#2,d5		;nbpixels … Effacer/4
	move	Rsplanes(a0),d1
	jmp	.Fcls(pc,d1.w)
.Fcls:
.Nocls:	rts
	nop
	bra.w	Plan0001	;ok
	bra.w	Plan0010	;ok
	bra.w	Plan0011	;ok
	bra.w	Plan0100	;ok
	bra.w	Plan0101	;ok
	bra.w	Plan0110	;ok
	bra.w	Plan0111	;ok
	bra.w	Plan1000	;ok
	bra.w	Plan1001
	bra.w	Plan1010	;ok
	bra.w	Plan1011	;ok
	bra.w	Plan1100	;ok
	bra.w	Plan1101	;ok
	bra.w	Plan1110	;ok
;	bra.w	Plan1111	;ok

Plan1001:
Plan0101:
Plan0111:
Plan1010:
Plan1011:
Plan1101:
Plan1110:
Plan1111:
	lea	(Pushcls-4).w,a0
	move.l	0(a0,d5),a0

	cmp	#240/4,d5
	bhs.s	.Fasteff

	sub	d6,d7

	add	d6,d6
	add	(a1,d6.w),a6

	add	d7,d7
	add	d7,d7
	pea	(a0,d7.w)

	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	rts

.Fasteff:	move	d7,d2
	add	d2,d2
	add	(a1,d2.w),a6
	lea	160(a6),a6

	sub	d6,d7
	add	d7,d7
	add	d7,d7
	pea	(a0,d7.w)

	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	rts

	;opt	ow-
Plan1000:	addq	#2,a6
Plan0100:	addq	#2,a6
Plan0010:	addq	#2,a6
Plan0001:
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	add	(a1,d6.w),a6
	jmp	.Oneplane-4(pc,d5.w)

.Oneplane:	bra.w	.Cls16
	bra.w	.Cls32
	bra.w	.Cls48
	bra.w	.Cls64
	bra.w	.Cls80
	bra.w	.Cls96
	bra.w	.Cls112
	bra.w	.Cls128
	bra.w	.Cls144
	bra.w	.Cls160
	bra.w	.Cls176
	bra.w	.Cls192
	bra.w	.Cls208
	bra.w	.Cls224
	bra.w	.Cls240
	bra.w	.Cls256
	bra.w	.Cls272
	bra.w	.Cls288
	bra.w	.Cls304
	bra.w	.Cls320
	dcb.w	10,$4afc
.Cls16:
	move	d0,(a6)
	lea	160(a6),a6
	dbf	d7,.Cls16
	rts
.Cls32:
	move	d0,(a6)
	move	d0,8(a6)
	lea	160(a6),a6
	dbf	d7,.Cls32
	rts
.Cls48:
x	set	0
	rept	3
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls48
	rts
.Cls64:
x	set	0
	rept	4
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls64
	rts
.Cls80:
x	set	0
	rept	5
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls80
	rts
.Cls96:
x	set	0
	rept	6
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls96
	rts
.Cls112:
x	set	0
	rept	7
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls112
	rts
.Cls128:
x	set	0
	rept	8
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls128
	rts
.Cls144:
x	set	0
	rept	9
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls144
	rts
.Cls160:
x	set	0
	rept	10
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls160
	rts
.Cls176:
x	set	0
	rept	11
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls176
	rts
.Cls192:
x	set	0
	rept	12
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls192
	rts
.Cls208:
x	set	0
	rept	13
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls208
	rts
.Cls224:
x	set	0
	rept	14
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls224
	rts
.Cls240:
x	set	0
	rept	15
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls240
	rts
.Cls256:
x	set	0
	rept	16
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls256
	rts
.Cls272:
x	set	0
	rept	17
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls272
	rts
.Cls288:
x	set	0
	rept	18
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls288
	rts
.Cls304:
x	set	0
	rept	19
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls304
	rts
.Cls320:
x	set	0
	rept	20
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls320
	rts

Plan1100:
;	bra	Plan1111
	cmp	#128/4,d5
	blo	Plan1111
	addq	#4,a6
	bra.s	Plan00111
Plan0110:
;	bra	Plan1111
	cmp	#128/4,d5
	blo	Plan1111
	addq	#2,a6
	bra.s	Plan00111
Plan0011:
;	bra	Plan1111
	cmp	#128/4,d5
	blo	Plan1111
Plan00111:
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	add	0(a1,d6),a6
	jmp	.Twoplanes-4(pc,d5)
.Twoplanes:
	bra.w	.Cls16
	bra.w	.Cls32
	bra.w	.Cls48
	bra.w	.Cls64
	bra.w	.Cls80
	bra.w	.Cls96
	bra.w	.Cls112
	bra.w	.Cls128
	bra.w	.Cls144
	bra.w	.Cls160
	bra.w	.Cls176
	bra.w	.Cls192
	bra.w	.Cls208
	bra.w	.Cls224
	bra.w	.Cls240
	bra.w	.Cls256
	bra.w	.Cls272
	bra.w	.Cls288
	bra.w	.Cls304
	bra.w	.Cls320
	dcb.w	10,$4afc
.Cls16
	move.l	d0,(a6)
	lea	160(a6),a6
	dbf	d7,.Cls16
	rts
.Cls32
	move.l	d0,(a6)
	move.l	d0,8(a6)
	lea	160(a6),a6
	dbf	d7,.Cls32
	rts
.Cls48
x	set	0
	rept	3
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls48
	rts
.Cls64
x	set	0
	rept	4
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls64
	rts
.Cls80
x	set	0
	rept	5
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls80
	rts
.Cls96
x	set	0
	rept	6
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls96
	rts
.Cls112
x	set	0
	rept	7
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls112
	rts
.Cls128
x	set	0
	rept	8
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls128
	rts
.Cls144
x	set	0
	rept	9
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls144
	rts
.Cls160
x	set	0
	rept	10
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls160
	rts
.Cls176
x	set	0
	rept	11
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls176
	rts
.Cls192
x	set	0
	rept	12
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls192
	rts
.Cls208
x	set	0
	rept	13
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls208
	rts
.Cls224
x	set	0
	rept	14
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls224
	rts
.Cls240
x	set	0
	rept	15
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls240
	rts
.Cls256
x	set	0
	rept	16
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls256
	rts
.Cls272
x	set	0
	rept	17
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls272
	rts
.Cls288
x	set	0
	rept	18
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls288
	rts
.Cls304
x	set	0
	rept	19
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls304
	rts
.Cls320
x	set	0
	rept	20
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbf	d7,.Cls320
	rts
	;opt	ow+

Generate_cls:
	lea	Pushcls.w,a3
	lea	Storage+Fastcls,a6

	lea	Cls16(pc),a0
	lea	Cls161(pc),a1
	lea	Cls162(pc),a2
	bsr	Geneff

	lea	Cls32(pc),a0
	lea	Cls321(pc),a1
	lea	Cls322(pc),a2
	bsr	Geneff

	lea	Cls48(pc),a0
	lea	Cls481(pc),a1
	lea	Cls482(pc),a2
	bsr	Geneff

	lea	Cls64(pc),a0
	lea	Cls641(pc),a1
	lea	Cls642(pc),a2
	bsr	Geneff

	lea	Cls80(pc),a0
	lea	Cls801(pc),a1
	lea	Cls802(pc),a2
	bsr	Geneff

	lea	Cls96(pc),a0
	lea	Cls961(pc),a1
	lea	Cls962(pc),a2
	bsr	Geneff

	lea	Cls112(pc),a0
	lea	Cls1121(pc),a1
	lea	Cls1122(pc),a2
	bsr	Geneff

	lea	Cls128(pc),a0
	lea	Cls1281(pc),a1
	lea	Cls1282(pc),a2
	bsr	Geneff

	lea	Cls144(pc),a0
	lea	Cls1441(pc),a1
	lea	Cls1442(pc),a2
	bsr	Geneff

	lea	Cls160(pc),a0
	lea	Cls1601(pc),a1
	lea	Cls1602(pc),a2
	bsr	Geneff

	lea	Cls176(pc),a0
	lea	Cls1761(pc),a1
	lea	Cls1762(pc),a2
	bsr	Geneff

	lea	Cls192(pc),a0
	lea	Cls1921(pc),a1
	lea	Cls1922(pc),a2
	bsr	Geneff

	lea	Cls208(pc),a0
	lea	Cls2081(pc),a1
	lea	Cls2082(pc),a2
	bsr	Geneff

	lea	Cls224(pc),a0
	lea	Cls2241(pc),a1
	lea	Cls2242(pc),a2
	bsr	Geneff

	lea	Cls240(pc),a0
	lea	Cls2401(pc),a1
	bsr	Geneff

	lea	Cls256(pc),a0
	lea	Cls2561(pc),a1
	bsr	Geneff

	lea	Cls272(pc),a0
	lea	Cls2721(pc),a1
	bsr	Geneff

	lea	Cls288(pc),a0
	lea	Cls2881(pc),a1
	bsr	Geneff

	lea	Cls304(pc),a0
	lea	Cls3041(pc),a1
	bsr	Geneff

	lea	Cls320(pc),a0
	lea	Cls3201(pc),a1
	bsr	Geneff

	cmp.l	#Finpush,a3
	bls.s	.Good2
	illegal
.Good2	cmp.l	#Storage+Finfastcls,a6
	bls.s	.Ok
	illegal
.Ok
	rts

Cls16:	movem.l	d0-d1,2(a6)
Cls161:	movem.l	d0-d1,(a6)
Cls162:
Cls32:	movem.l	d0-d3,2(a6)
Cls321:	movem.l	d0-d3,(a6)
Cls322:
Cls48:	movem.l	d0-d5,2(a6)
Cls481:	movem.l	d0-d5,(a6)
Cls482:
Cls64:	movem.l	d0-d7,2(a6)
Cls641:	movem.l	d0-d7,(a6)
Cls642:
Cls80:	movem.l	d0-d7/a0-a1,2(a6)
Cls801:	movem.l	d0-d7/a0-a1,(a6)
Cls802:
Cls96:	movem.l	d0-d7/a0-a3,2(a6)
Cls961:	movem.l	d0-d7/a0-a3,(a6)
Cls962:
Cls112:	movem.l	d0-d7/a0-a5,2(a6)
Cls1121:	movem.l	d0-d7/a0-a5,(a6)
Cls1122:
Cls128:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d1,2(a6)
Cls1281:	movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d1,2(a6)
Cls1282:
Cls144:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d3,2(a6)
Cls1441:	movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d3,2(a6)
Cls1442:
Cls160:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d5,2(a6)
Cls1601:	movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d5,2(a6)
Cls1602:
Cls176:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7,2(a6)
Cls1761:	movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7,2(a6)
Cls1762:
Cls192:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a1,2(a6)
Cls1921:	movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a1,2(a6)
Cls1922:
Cls208:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a3,2(a6)
Cls2081:	movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a3,2(a6)
Cls2082:
Cls224:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a5,2(a6)
Cls2241:	movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a5,2(a6)
Cls2242:
Cls240:	lea	-40(a6),a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d1,-(a6)
Cls2401:
Cls256:	lea	-32(a6),a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d3,-(a6)
Cls2561:
Cls272:
	lea	-24(a6),a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d5,-(a6)
Cls2721:
Cls288:	lea	-16(a6),a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7,-(a6)
Cls2881:
Cls304:	subq	#8,a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a1,-(a6)
Cls3041:
Cls320:
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a3,-(a6)
Cls3201:
Geneff:	move.l	a6,(a3)+
	move	#NB_LINES-2,d7
.Gen1:	move.l	#$60000000,(a6)+
	dbf	d7,.Gen1
	move.l	a6,a5

	cmp.l	#Cls240,a0
	bhs.s	Gen240
	move	#NB_LINES*160,d7
	bra.s	.Gen8
.Gen2:	subq	#2,a5
	move.l	a6,d0
	sub.l	a5,d0
	move	d0,(a5)
	subq	#2,a5
.Gen8:	sub	#160,d7
	beq.s	.Retgen
	move	d7,d6

	move.l	a0,a4
.Gen3:	move	(a4)+,d0
	cmp	#2,d0
	bne.s	.Genok
	move	d6,d0
	add	#14*4,d6
.Genok:	move	d0,(a6)+
	cmp.l	a1,a4
	blo.s	.Gen3
	bra.s	.Gen2
.Retgen:	move	#14*4,d6
.Gen6:	move	(a1)+,d0
	cmp	#2,d0
	bne.s	.Gen7
	move	d6,d0
	add	#14*4,d6
.Gen7:	move	d0,(a6)+
	cmp.l	a2,a1
	blo.s	.Gen6
	move	#$4e75,(a6)+
	rts
Gen240:	move	#NB_LINES-1,d7
	bra.s	.Gen8
.Gen2:	subq	#2,a5
	move.l	a6,d0
	sub.l	a5,d0
	move	d0,(a5)
	subq	#2,a5
.Gen8:	move.l	a0,a4
.Gen3:	move	(a4)+,(a6)+
	cmp.l	a1,a4
	blo.s	.Gen3
	dbf	d7,.Gen2
	move	#$4e75,(a6)+
	rts
	 ;#] CLS:
	 ;#[ Polygone Drawer:
;
; routine de calcul des points d'un polygone !!!!
;
miny	equr	d6	;r‚serv‚s dans tous le calcul
maxy	equr	d7
xa	equr	d0	;extremit‚s de la droite
ya	equr	d1
xb	equr	d2
yb	equr	d3
retour	equr	a1	;adresse de retour droite
ptry	equr	a0	;pointeur tabley
regdata	equr	d4
dx	equr	d5

;-------------- cas d'une ligne verticale -----------------------


	rept	NB_LINES
	move	xa,(ptry)+	;mise en place nouveau points
	endr
Affvert:
Retourvert:	jmp	(retour)

Vertline:	; clipping
	cmp	#NB_LINES,ya
	blo.s	.Yasup0
	bge.s	Retourvert
	moveq	#0,ya
.Yasup0:	cmp	#NB_LINES,yb
	blo.s	.Ybinfmax
	blt.s	Retourvert
	move	#NB_LINES-1,yb
.Ybinfmax:	cmp	miny,ya		;tester minimum
	bhs.s	.Pasminimum
	move	ya,miny
.Pasminimum:	cmp	maxy,yb		;tester maximum
	bls.s	.Pasmaximum
	move	yb,maxy
.Pasmaximum:	sub	ya,yb
	add	ya,ya
	add	ya,ptry
	add	yb,yb
	neg	yb
;	add	#Calcretour-Calcretour2-2,yb
;	jmp	Calcretour2(pc,yb.w)
;	add	#Calcretour-Calcretour2-2,yb
	jmp	Affvert-2(pc,yb.w)
Calcretour:	jmp	(retour)
				;fin du calcul des points

;-------------- d‚but calcul d'une ligne -------------------------

Drawline:	lea	Storage+Left_points,ptry
;	clr	$144.w		;flag clipping y
;	movem	xa/ya/xb/yb,$146.w

	cmp	ya,yb
	beq.s	Calcretour		;ligne horizontale
	bge.s	.Ybsupya
	exg	xa,xb		;echange les points
	exg	ya,yb
	lea	NB_LINES*2(ptry),ptry	;c'est une ligne montante
.Ybsupya:
;	move	xb,$142.w		;x arriv‚e !!!
	sub	xa,xb		;dx
	beq.s	Vertline
	move	yb,regdata
	sub	ya,regdata		;dy
	move	xb,dx
	ext.l	xb		;calcul de la pente
	asl.l	#8-2,xb		;dx*256

	divs	regdata,xb		;divise par dy
	bvc.s	.Nodeborde
	asr.l	#6,xb
	divs	regdata,xb
	bvc.s	.Okdeb
	addq	#7,$ffff8240.w
.Okdeb:	swap	xb
	clr	xb
	bra.s	.Skipex
.Nodeborde:	ext.l	xb
	asl.l	#8,xb		;recuperation virgule 1/256eme
	add.l	xb,xb
	add.l	xb,xb
.Skipex:	cmp	#NB_LINES,ya
	blo.s	.Yasup0
	bge.s	Calcretour
	muls	dx,ya
	divs	regdata,ya
	sub	ya,xa
	moveq	#0,ya
	move	yb,regdata
;	addq	#1,$144.w
.Yasup0:	cmp	#NB_LINES,yb
	blo.s	.Ybinfmax
	blt.s	Calcretour
	move	#NB_LINES-1,yb
	move	yb,regdata
	sub	ya,regdata	;dy
;	addq	#1,$144.w
.Ybinfmax:
;------------ mise a jour des maximums et minimum ----------

	cmp	miny,ya		;tester minimum
	bhs.s	.Pasminimum
	move	ya,miny
.Pasminimum:	cmp	maxy,yb		;tester maximum
	bls.s	.Pasmaximum
	move	yb,maxy
.Pasmaximum:	add	ya,ya		;adresse tableau lignes
	add	ya,ptry
	add	regdata,regdata	;offset pour le saut
	add	regdata,regdata
	neg	regdata

	swap	xa
	move	xb,xa
	beq	Lineentier
	add	#.Jmpline2-.Jmpline1,regdata

	swap	xa
	swap	xb	;poids fort = virgule*4
			;poids faible = partie entiere*4
	addq	#2,xa	;x+1/2

	jmp	.Jmpline1(pc,regdata.w)
.Jmpline1:	rept	NB_LINES-1
	move	xa,(ptry)+
	addx.l	xb,xa
	endr
.Jmpline2:
Jmpline:	move	xa,(ptry)

;	tst	$144.w
;	bne.s	.Ok
;	move	$142.w,ya
;	eor	xa,ya
;	and	#-4,ya
;	beq.s	.Ok
;	addq	#7,$ffff8240.w
;.Ok
	jmp	(retour)

;---------- cas d'une ligne … coEfficient entier -----------

Lineentier:	swap	xa
	swap	xb
	add	#.Lineent3-.Lineent2,regdata
	jmp	.Lineent2(pc,regdata.w)
.Lineent2:	rept	NB_LINES-1
	move	xa,(ptry)+
	add	xb,xa
	endr
.Lineent3	move	xa,(ptry)
	jmp	(retour)


Generate_line:	lea	Left_offsets,a0
	move	#LEFT_CLIP-1,d0
.Fil1:	move.l	#$ffff0000,(a0)+
	dbf	d0,.Fil1

Left_clip:	moveq	#0,d6
.Genleft1:	moveq	#-1,d7
.Genleft2:	move	d7,(a0)+
	move	d6,(a0)+
	lsr	#1,d7
	bne.s	.Genleft2	;ou bcs
	addq	#8,d6
	cmp	#160,d6
	blo.s	.Genleft1
	move	#RIGHT_CLIP-1,d0
.Fil2:	move.l	#$00000000+160,(a0)+	;pour empecher tout affichage !!!
	dbf	d0,.Fil2
	lea	Right_offsets,a0
	move	#LEFT_CLIP-1,d0
.Fil1:	move.l	#$fffffff8,(a0)+	;pour empecher tout affichage !!!
	dbf	d0,.Fil1

Right_clip:	moveq	#0,d6
.Genrgt1:	move	#$8000,d7
.Genrgt2:	move	d7,(a0)+
	move	d6,(a0)+
	asr	#1,d7
	bcc.s	.Genrgt2
	addq	#8,d6
	cmp	#160,d6
	blo.s	.Genrgt1

	move	#RIGHT_CLIP-1,d0
.Fil2:	move.l	#$ffff0000+160-8,(a0)+
	dbf	d0,.Fil2
	rts
	 ;#] Polygone Drawer:
	 ;#[ DATA Section:
	DATA
XYZ	MACRO
	dc.w	\1*10,\2*10,\3*20
	ENDM

Coords_spacecraft:
	dc.w	8
	XYZ	-2,5,0
	XYZ	2,5,0
	XYZ	-6,-5,0
	XYZ	-2,-5,1
	XYZ	2,-5,1
	XYZ	6,-5,0
	XYZ	-2,-5,-1
	XYZ	2,-5,-1

Coords_spider:
	dc.w	22
	dc.w	-15,  25,  0
	dc.w	 25,  30,  0
	dc.w	-65,  10,  0
	dc.w	-15,  10,  5
	dc.w	 25,  10,  5
	dc.w	 40,  10,  0
	dc.w	-65, -10,  0
	dc.w	-15, -10,  5
	dc.w	 25, -10,  5
	dc.w	 40, -10,  0
	dc.w	-15, -25,  0
	dc.w	 25, -30,  0
	dc.w	-15,  25, -5
	dc.w	 25,  30, -5
	dc.w	-75,   5, -5
	dc.w	 40,  10, -5
	dc.w	-75,  -5, -5
	dc.w	 40, -10, -5
	dc.w	-15, -25, -5
	dc.w	 25, -30, -5
	dc.w	-10,   0,-15
	dc.w	 20,   0,-15

Coords_cube:	dc.w	8
	dc.w	-50,50,-50	;1
	dc.w	-50,-50,-50	;2
	dc.w	50,-50,-50	;3
	dc.w	50,50,-50	;4

	dc.w	-50,50,50	;5
	dc.w	-50,-50,50	;6
	dc.w	50,-50,50	;7
	dc.w	50,50,50	;8

Coords_tetra:	dc.w	4
	dc.w	0,50,0
	dc.w	43,-25,0
	dc.w	-43,-25,0
	dc.w	0,0,50

;	dc.w	0,50,0
;	dc.w	-50,-50,-50
;	dc.w	50,-50,-50
;	dc.w	0,-50,50

;	dc.w	50,0,0
;	dc.w	-25,37,-22
;	dc.w	-26,-37,21
;	dc.w	0,0,-50

;	dc.w	100/2,0,0
;	dc.w	14/2,-99/2,0
;	dc.w	-7/2,-99/2,12/2
;	dc.w	-7/2,-99/2,-12/2

;	dc.w	0,50,0
;	dc.w	-43,-25,-25
;	dc.w	43,-25,-25
;	dc.w	0,-25,25

Coords_grille:	dc.w	25
	dc.w	-50,-50,0
	dc.w	-25,-50,0
	dc.w	0,-50,0
	dc.w	25,-50,0
	dc.w	50,-50,0
	dc.w	-50,-25,0
	dc.w	-25,-25,0
	dc.w	0,-25,0
	dc.w	25,-25,0
	dc.w	50,-25,0
	dc.w	-50,0,0
	dc.w	-25,0,0
	dc.w	0,0,0
	dc.w	25,0,0
	dc.w	50,0,0
	dc.w	-50,25,0
	dc.w	-25,25,0
	dc.w	0,25,0
	dc.w	25,25,0
	dc.w	50,25,0
	dc.w	-50,50,0
	dc.w	-25,50,0
	dc.w	0,50,0
	dc.w	25,50,0
	dc.w	50,50,0

Fonte:	incbin	Fonte3.img

	 ;#] DATA Section:
	 ;#[ BSS Section:
	BSS
Top_of_stack:		ds.l	50
Stack:
Firstpal:		ds.b	32*NB_SCREENS
Fast_draw:		ds.b	(Hline2-Hline1)*NB_LINES+2
Findraw:
Left_offsets		ds.l	LEFT_CLIP
		ds.l	320
		ds.l	RIGHT_CLIP
Right_offsets:		ds.l	LEFT_CLIP
		ds.l	320
		ds.l	RIGHT_CLIP
Bottom:
Storage:
		BSS
	Offset 0
Repeat:		ds.w	1
Latchkey:		ds.b	1
Latchnum:		ds.b	1
Numsec:		ds.b	1
Cheat:		ds.b	1
Cptvbl:		ds.b	1
	even
Current_object:	ds.w	1
Nbimages:		ds.w	1
Last_screen:		ds.l	1
Lastpal:		ds.l	1
Left_points:		ds.w	NB_LINES
Right_points:		ds.w	NB_LINES

; Structure :
;	0.L=adresse ‚cran
;	4.W=xmin
;	6.W=xmax
;	8.W=ymin
;	10.W=ymax
;	12.L=adresse palette … afficher
;	16.W=plans … effacer
;
	rsreset
Rsecran:		rs.l	1
Rsxmin:		rs.w	1
Rsxmax:		rs.w	1
Rsymin:		rs.w	1
Rsymax:		rs.w	1
Rspal:		rs.l	1
Rsplanes:		rs.w	1
STRUCT_LENGTH		equ	(__RS+1)&-2

Ptrscr:	ds.b	STRUCT_LENGTH*NB_SCREENS
Finscr:

Fastcls:		ds.b	56764	;62720
Finfastcls:
	 ;#] BSS Section:

