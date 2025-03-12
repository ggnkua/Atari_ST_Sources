;	opt	l5
	output	presente.prg
	opt	o+,ow2-
;
; pr‚sentation de Toki
;
; 25/04/90 la routine de sprite est g‚n‚r‚e par programme
;
; registres en entr‚e :
;	d0=level
;	a0=ecran 1
;	a1=ecran 2
;	a2=replay
;	a3=floplock
;	a4=touches
;	a5=registre a5
;
FINAL=0			;0=FINAL (pas d'init)
PRG=1			;0=.PRG
DOWNLOAD=1-PRG		;0=down load
DEBUG=1			;0=debug on
ylogo=40
basemfp=$40
CPU	MACRO
	IFNE	FINAL
	tst.b	TAB.W
	beq.s	.\@
	move	#\1,$ffff8240.w
.\@
	ENDC
	ENDM
nbspr=4			;nb sprites maximum
XSORCIER=176
nbvbl=1
	IFNE	FINAL
ecran1=$80000-32000
ecran0=ecran1-32000
ramtop=ecran0
	ELSEIF
ramtop=$80000-64000
	ENDC
hauteur=176
largeur=224
offsety=0
	ifne	DOWNLOAD
	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	lea	$80000,sp
	movem.l	mover(pc),d0-d7
	movem.l	d0-d7,-(sp)
	lea	code(pc),a0
	LEA	STARTCODE,A1
	LEA	FINCODE,A2
	jmp	(sp)
mover:
	move.l	(a0)+,(a1)+
	move	a1,$ffff8240.w
	cmp.l	a2,a1
	blo.s	mover
	JMP	STARTCODE
code:
	endc

	IFNE	FINAL
	offset	$100
touches		ds.b	$80-2
joystick0	ds.b	1
joystick1	ds.b	1
TAB		ds.b	1
	ENDC

	section	text
	org	$30000
stack:
STARTCODE
	bra	skipvar
ecran:		ds.l	1

fade:		ds.w	1	;0=no fade
				;1=fade in
				;-1=fade out
tint:		ds.w	1	;0=couleur d‚part
countfade:	ds.w	1
ptrpal:		ds.l	1
effacelogo:	ds.w	1
ptr1		ds.l	1
ptr2		ds.l	1
buffer1:	ds.b	6*nbspr+4
buffer2:	ds.b	6*nbspr+4

anim:		dc.w	0

modesorc:	dc.w	0
xsorc:		dc.w	0
numsorc:	dc.w	0
cptsorc:	dc.w	0
flagsorc:	dc.w	0

ptrfemme:	dc.w	0
numfemme:	dc.w	0
cptfemme:	dc.w	0

xhomme:		dc.w	0
numhomme:	dc.w	0
cpthomme:	dc.w	0

xtir:		dc.w	0
numtir:		dc.w	0
cpttir:		dc.w	0

flagfemme:	dc.b	0
flagroc:	dc.b	0	;si roc … afficher
restart:	dc.b	0
		even

ptronde:	dc.w	0
nbplan:		ds.w	1
onemore:	ds.w	1
palette		ds.w	16

		IFEQ	FINAL
LEVEL:		DS.W	1
ecran2:		ds.l	1	;ok
replay:		ds.l	1	;ok
floplock:	ds.l	1
touches:	ds.l	1
		ENDC

skipvar:
	IFNE	FINAL
	move	#$2700,sr
	lea	stack,sp	;superstack
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	IFEQ	DEBUG
	jsr	debugger
	ENDC

	clr.b	TAB.W
	bsr	initkbd

	move.l	#vbl,$70.w

	move	#$2300,sr

	move.l	#vbl2,$70.w
	ELSEIF

	move.l	a0,ecran
	move.l	a1,ecran2
	move.l	a2,replay
	move.l	a3,floplock
	move.l	a4,touches
	move.l	#vbl,$70.w
	ENDC

	IFEQ	FINAL
	move.l	ecran(pc),a5
	ELSEIF
	lea	ecran0,a5
	ENDC
	bsr	copyscreen
	IFEQ	FINAL
	move.l	ecran2(pc),a5
	ELSEIF
	lea	ecran1,a5
	ENDC
	bsr	copyscreen

;	move.l	#ecran0,d0
;	lsr	#8,d0
;	move.l	d0,$ffff8200.w

	lea	buffer1(pc),a0
	move.l	a0,ptr1
	lea	buffer2(pc),a0
	move.l	a0,ptr2

	IFEQ	FINAL
;	move.l	replay(pc),a1
;	lea	musique(pc),a0
;	jsr	(a1)
	ELSEIF
	bsr	musique
	ENDC

	IFNE	FINAL
	move.l	#ecran1,ecran
	ENDC

	move.l	#prgvbl,$70.w

;	clr	effacelogo
rejoue:
	move	#6,anim
	move.l	#realpalette,ptrpal
	move	#$1,fade
.wfa
	move	fade(pc),d0
	bne.s	.wfa

	clr.b	flagfemme
	clr	anim
;
; g‚n‚ration de la femme en pr‚d‚cal‚
;
	moveq	#2,d0
	lea	IMAGEFEMME,A5
	LEA	FASTFEMME,A4
	IFNE	FINAL
	move.l	a4,$200.w
	ENDC
	bsr	predecale
	IFNE	FINAL
	move.l	a6,$204.w
	CMP.L	#FINBUFFERFEMME,A6
	BEQ.S	.goodgen
;	dc.l	$4a780001
	moveq	#-1,d0
.flash	move	d0,$ffff8240.w
	dbra	d0,.flash
.goodgen
	ENDC
	st	flagfemme
.wait2
	move.b	flagfemme(pc),d0 ;attend la fin d'utilisation de la femme
	bne.s	.wait2

	moveq	#2,d0		;les 2 boules de feu
	lea	IMAGERAYON,A5
	LEA	FASTRAYON,A4
	IFNE	FINAL
	move.l	a4,$208.w
	ENDC
	bsr	predecale
	IFNE	FINAL
	move.l	a6,$20c.w
	ENDC

	st	flagfemme
.wait3
	IFEQ	FINAL
	move	LEVEL(pc),d0
	bne.s	quit
	ENDC
	move.b	flagfemme(pc),d0
	bne.s	.wait3

	moveq	#1,d0		;le logo
	lea	IMAGELOGO,A5
	LEA	FASTLOGO,A4
	IFNE	FINAL
	move.l	a4,$210.w
	ENDC
	bsr	predecale_logo
	IFNE	FINAL
	move.l	a6,$214.w
	ENDC

	clr.b	restart
.loop
	IFEQ	FINAL
	move	LEVEL(pc),d0
	bne.s	quit
	ENDC
	move.b	restart(pc),d0
	beq.s	.loop

.wfade
	IFEQ	FINAL
	move	LEVEL(pc),d0
	bne.s	quit
	ENDC
	move	fade(pc),d0
	bne.s	.wfade

	bra	rejoue
	IFEQ	FINAL
quit:
	st	restart
	move	#-1,fade
.ww	move	fade(pc),d1
	bne.s	.ww
	rts
	ENDC
copyscreen:
;	move.l	a5,a0
	moveq	#0,d0
	move	#32000/4-1,d1
clrmem:
	move.l	d0,(a5)+
	dbra	d1,clrmem

	lea	FOND,a6
	lea	-32000+24(a5),a5

	move	#176-1,d7
1$
;	move.l	a5,a0
	moveq	#224/2/4-1,d0
2$
	move.l	(a6)+,(a5)+
	dbra	d0,2$
	lea	160-224/2(a5),a5
	dbra	d7,1$
	rts

	IFNE	FINAL
vbl2:
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
vbl:
	rte
	ENDC

	IFNE	FINAL
;
; am‚liorations possible :
;	- mettre le tableau touches … une adresse multiple de 256
;	  (ca fait gagner l'empilement de a0)
;	- mettre ces routines dans le bas de la m‚moire
;	  (changement du vecteur par MOVE.W)
;	- d‚gager TST.B au d‚but
;	- enlever la routine JOYST0 !!!
;
;
; nouvelle routine de clavier (trŠs) optimis‚e
;
initkbd:
	move.b	#$10,$fffffa17.w
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w

.wikbd	btst	#1,$fffffc00.w
	beq.s	.wikbd
	move.b	#$12,$fffffc02.w	;d‚sactiver souris

	move.l	#kbd,basemfp+$18.w
	or.b	#$40,$fffffa09.w
	or.b	#$40,$fffffa15.w

	lea	touches\w,a0
	moveq	#($80-2)/2-1,d0
	moveq	#0,d1
.clear	move	d1,(a0)+
	dbra	d0,.clear
	clr.b	joystick0.w
	clr.b	joystick1.w
	rts

bug:	move	#$2700,sr
1$	addq	#7,$ffff8240.w
	bra.s	1$
kbd:
	tst.b	$fffffc00.w
	bpl.s	bug
	move	d0,-(sp)
	clr	d0
	move.b	$fffffc02.w,d0
	addq.b	#2,d0
	bcs.s	codefe

	pea	(a0)
	lea	touches\w,a0
	bclr	#7,d0
	seq	-2(a0,d0.w)
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
	ifeq	DEBUG
	move	#$070,$ffff8240.w
	endc
	move.b	$fffffc02.w,joystick0.w
	move.l	#kbd,basemfp+$18.w
	ifeq	DEBUG
	clr	$ffff8240.w
	endc
	rte
joyst1:
	ifeq	DEBUG
	move	#$007,$ffff8240.w
	endc
	move.b	$fffffc02.w,joystick1.w
	move.l	#kbd,basemfp+$18.w
	ifeq	DEBUG
	clr	$ffff8240.w
	endc
	rte
	ENDC			;FINAL

prgvbl:
	clr.b	$fffffa1b.w
	move.l	#hbl,basemfp+$20.w
	IFNE	FINAL
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	ENDC
	move.b	#176,$fffffa21.w
	move.b	#8,$fffffa1b.w
	IFEQ	FINAL
vbl:
	ENDC
	movem.l	d0-d7/a0-a6,-(sp)
;
; fade
;
	move	fade(pc),d0
	beq.s	.nofondu

	add	#65536/4,countfade	;toutes les 2 VBL
	bcc.s	.nofondu

	move	tint(pc),d1
	tst	d0
	bmi.s	.fadein
	eor	#7,d1
.fadein
	move.l	ptrpal(pc),a0
	lea	palette(pc),a1
	moveq	#16-1,d0
.loop
	move	(a0)+,d2

	moveq	#$7,d3
	and	d2,d3

FADE	MACRO
	sub	d1,\1
	bhs.s	.\@
	clr	\1
.\@
	ENDM

	FADE	D3
	lsr	#4,d2
	moveq	#$7,d4
	and	d2,d4
	FADE	D4
	lsr	#4,d2
	and	#$7,d2
	FADE	D2
	asl	#4,d2
	add	d4,d2
	asl	#4,d2
	add	d3,d2

	move	d2,(a1)+

	dbra	d0,.loop

	addq	#1,tint
	cmp	#8,tint
	blo.s	.nofondu
	clr	fade
	clr	tint
	clr	countfade
.nofondu:
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	touches(pc),a0
	moveq	#1,d0
	tst.b	$7e(a0)		;fire joystick
	bmi.s	.sort
	tst.b	$7f(a0)		;fire joystick
	bmi.s	.sort
	tst.b	$39(a0)		;SPACE
	bne.s	.sort

	tst.b	$3b(a0)		;F1
	bne.s	.sort
	moveq	#2,d0
	tst.b	$3c(a0)		;F2
	bne.s	.sort
	moveq	#3,d0
	tst.b	$3d(a0)		;F3
	bne.s	.sort
	moveq	#4,d0
	tst.b	$3e(a0)		;F4
	bne.s	.sort
	moveq	#5,d0
	tst.b	$3f(a0)		;F5
	beq.s	.pasort
.sort:
	move	d0,LEVEL
.pasort
	movem.l	(sp)+,d0-d7/a0-a6
	rte

hbl:
	clr.b	$fffffa1b.w
	IFNE	FINAL
	clr	$ffff8240.w
	ENDC
	move	#$2300,sr

	movem.l	d0-d7/a0-a6,-(sp)

	move.l	ecran(pc),d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move.l	ptr2(pc),a0	;swappe les pointeurs d'effacement
	move.l	ptr1(pc),ptr2
	move.l	a0,ptr1
	IFEQ	FINAL
	move.l	ecran2(pc),d0
	move.l	ecran(pc),ecran2
	move.l	d0,ecran
	ELSEIF
	eor.l	#ecran0^ecran1,ecran
	ENDC

	IFNE	FINAL
	tst.b	touches+$f.w
	beq.s	.nocpu
	clr.b	touches+$f.w
	not.b	TAB.W
.nocpu

	tst.b	touches+$e.w
	beq.s	.nodel
	dc.l	$4a780001
.nodel

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
	ENDC

	IFEQ	FINAL
	move.l	replay(pc),a0
	jsr	4(a0)
	ELSEIF
	bsr	musique+4
	ENDC
;
; effacement des sprites
;
	move.l	ptr1(pc),a6
.bcl
	move	(a6)+,d0		;largeur/2
	beq.s	.fini
	move	(a6)+,d7		;hauteur-1

	lea	FOND,a0
	move.l	ecran(pc),a1
	moveq	#0,d2
	move	(a6)+,d2		;offset
	add	d2,a1
	sub	#24,d2
	divu	#160,d2
	moveq	#224/2,d3
	mulu	d2,d3
	swap	d2
	add	d2,d3
	add	d3,a0

	jsr	.eff-4(pc,d0.w)
	bra.s	.bcl
.eff
	bra.w	neff16		;4
	bra.w	neff32		;8
	bra.w	neff48		;12
	bra.w	neff64		;16
	bra.w	neff80		;20
	dc.l	$4a780001
.fini
	move	effacelogo(pc),d0
	beq.s	.nologo
	subq	#1,effacelogo
	CPU	$077
	move.l	ecran(pc),a5
	lea	FOND+ylogo*224/2,a6

	lea	ylogo*160+24(a5),a5
	moveq	#64-1,d0
.efflogo
	movem.l	(a6)+,d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,(a5)
	movem.l	(a6)+,d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,48(a5)
	movem.l	(a6)+,d1-d4
	movem.l	d1-d4,96(a5)
	lea	160(a5),a5
	dbra	d0,.efflogo
.nologo
	clr.b	flagroc

	CPU	$300
	move.l	ptr1(pc),a6		;pour pusher les sprites
	bsr	demo
	clr.l	(a6)
	CPU	$333

	move.b	flagroc(pc),d0
	beq	noroc
	move.l	ecran(pc),a6
	lea	(176-$91-16+4+1)*160+24(a6),a6
;
; affichage du rocher
;
	MOVE.L	#$FFE3FFFF,(A6)+
	MOVE.L	#$FFFF007D,(A6)+
	MOVE.L	#$EDFE9FFE,(A6)+
	MOVE.L	#$FFFFF65F,(A6)+
	MOVE.L	#$181F3C07,(A6)+
	MOVEM.L	L512CA(PC),D0-7/A0-3
	MOVE.L	A0,(A6)+
	AND.L	D0,(A6)
	OR.L	D1,(A6)+
	OR.L	D2,(A6)+
	LEA	$80(A6),A6
	MOVE.L	A1,(A6)+
	MOVE.L	#$FFFF003C,(A6)+
	MOVE.L	#$FCF8CFF8,(A6)+
	MOVE.L	#$FFFFF73F,(A6)+
	MOVE.L	#$381F1807,(A6)+
	MOVE.L	A0,(A6)+
	OR	D3,(A6)
	AND.L	D4,(A6)+
	OR.L	D2,(A6)+
	LEA	$80(A6),A6
	MOVE.L	A1,(A6)+
	MOVE.L	#$FFFF001C,(A6)+
	MOVE.L	#$FFF4FFFC,(A6)+
	MOVE.L	#$FFFF677F,(A6)+
	MOVE.L	#$3C1F1C07,(A6)+
	MOVE.L	A0,(A6)+
	AND.L	D0,(A6)
	OR.L	D5,(A6)+
	OR.L	D2,(A6)+
	LEA	$80(A6),A6
	MOVE.L	A1,(A6)+
	MOVE.L	#$FFFF019C,(A6)+
	MOVE.L	#$FFF2FFEE,(A6)+
	MOVE.L	#$FFFF067F,(A6)+
	MOVE.L	#$2E7F163F,(A6)+
	MOVE.L	#$FFFFFFC3,(A6)+
	AND.L	D0,(A6)+
	OR.L	D2,(A6)+
	LEA	$80(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	#$FFFF0180,(A6)+
	MOVE.L	#$FFF9FFC7,(A6)+
	MOVE.L	D6,(A6)+
	MOVE.L	#$3F7F077E,(A6)+
	MOVE.L	#$FFFFFF87,(A6)+
	OR	D1,(A6)
	AND.L	#$8FFF0FFF,(A6)+
	OR.L	D2,(A6)+
	LEA	$80(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	A3,(A6)+
	MOVE.L	#$FFDFFC3,(A6)+
	MOVE.L	#$FFFFF07E,(A6)+
	MOVE.L	#$BFDF83DA,(A6)+
	MOVE.L	#$FFFFFF27,(A6)+
	OR	D3,(A6)
	AND.L	D4,(A6)+
	OR.L	D2,(A6)+
	LEA	$80(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	A3,(A6)+
	MOVE.L	#$CFFF3FCF,(A6)+
	MOVE.L	#$FFFFF07F,(A6)+
	MOVE.L	#$7F93C311,(A6)+
	MOVE.L	#$FFFFBFEF,(A6)+
	OR	D2,(A6)+
	AND	D0,(A6)+
	OR.L	D2,(A6)+
	LEA	$80(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	A3,(A6)+
	MOVE.L	#$FFFE0FFF,(A6)+
	MOVE.L	#$FFFFF07F,(A6)+
	MOVE.L	#$BE117E10,(A6)+
	MOVE.L	#$FFFFCFFF,(A6)+
	OR	D3,(A6)+
	AND	#$1FFF,(A6)
	OR.L	D3,(A6)+
	OR	D3,(A6)+
	LEA	$80(A6),A6
	MOVE.L	#$FF3FFFFF,(A6)+
	MOVE.L	#$FFFF03C1,(A6)+
	MOVE.L	#$FFE40FE3,(A6)+
	MOVE.L	#$FFFFF03F,(A6)+
	MOVE.L	#$7C083C10,(A6)+
	MOVE.L	#$FFFFDFFF,(A6)+
	MOVEM.L	L512FA(PC),D0-1/D3-4/A0-1/A3
	AND.L	D3,(A6)+
	OR.L	D5,(A6)+
	LEA	$80(A6),A6
	MOVE.L	#$FF3DFFFF,(A6)+
	MOVE.L	#$FFFF03C3,(A6)+
	MOVE.L	#$FDA40E62,(A6)+
	MOVE.L	#$FFFFF3FF,(A6)+
	MOVE.L	#$78083800,(A6)+
	MOVE.L	#$FFFFF7FF,(A6)+
	AND.L	#$3FFF3FFF,(A6)+
	OR.L	D1,(A6)+
	LEA	$80(A6),A6
	MOVE.L	#$FF39FFFF,(A6)+
	MOVE.L	#$FFFF03C7,(A6)+
	MOVE.L	#$FCD40E32,(A6)+
	MOVE.L	#$FFFFF3FF,(A6)+
	MOVE.L	#$78047800,(A6)+
	MOVE.L	#$FFFFE7FF,(A6)+
	AND.L	#$3FFF3FFF,(A6)+
	OR.L	D1,(A6)+
	LEA	$80(A6),A6
	MOVE.L	#$FF31FFFF,(A6)+
	MOVE.L	#$FFFF03CF,(A6)+
	MOVE.L	#$FC6EFC1A,(A6)+
	MOVE.L	#$FFFFF7FF,(A6)+
	MOVE.L	#$60007C00,(A6)+
	MOVE.L	#$FFFFDFFF,(A6)+
	AND.L	#$3FFF3FFF,(A6)+
	OR.L	D1,(A6)+
	LEA	$80(A6),A6
	MOVE.L	#$FF33FFFF,(A6)+
	MOVE.L	#$FFFF03CF,(A6)+
	MOVE.L	#$FC37FC0F,(A6)+
	MOVE.L	#$FFFFF7F9,(A6)+
	MOVE.L	#$F0009E00,(A6)+
	MOVE.L	A2,(A6)+
	AND.L	D3,(A6)+
	OR.L	D5,(A6)+
	LEA	$80(A6),A6
	MOVE.L	#$FF7FFFFF,(A6)+
	MOVE.L	#$FFFF03CE,(A6)+
	MOVE.L	#$F83FF80E,(A6)+
	MOVE.L	#$FFFF07F7,(A6)+
	MOVE.L	#$F8000F00,(A6)+
	MOVE.L	A2,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FF7FFFFF,(A6)+
	MOVE.L	#$FFFF038C,(A6)+
	MOVE.L	#$BC3ECC0E,(A6)+
	MOVE.L	#$FFFF73F7,(A6)+
	AND.L	#$30003,(A6)
	OR.L	#$FC000780,(A6)+
	OR.L	#$FFFCFFFC,(A6)+
	LEA	$88(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	#$FFFF0380,(A6)+
	MOVE.L	#$9E3EC60E,(A6)+
	MOVE.L	#$FFFF79F7,(A6)+
	AND.L	#$70007,(A6)
	OR.L	#$7F400380,(A6)+
	OR.L	#$FFF8FFF8,(A6)+
	LEA	$88(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	#$FFFF0300,(A6)+
	MOVE.L	#$8F3EC30E,(A6)+
	MOVE.L	#$FFFF7CF7,(A6)+
	AND.L	#$F000F,(A6)
	OR.L	#$3F0003F0,(A6)+
	OR	#$FFF0,(A6)+
	AND	#$F,(A6)
	OR	#$FDF0,(A6)+
	LEA	$88(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	#$FFFF0300,(A6)+
	MOVE.L	#$87C2E3FE,(A6)+
	MOVE.L	#$FFFF7C3F,(A6)+
	AND.L	#$1F001F,(A6)
	OR.L	#$1BC00600,(A6)+
	OR	#$FFE0,(A6)+
	AND	#$1F,(A6)
	OR	#$FDE0,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FFC7FFFF,(A6)+
	MOVE.L	#$FFFF0438,(A6)+
	MOVE.L	#$C7C0F3F0,(A6)+
	MOVE.L	#$FFFF3C3F,(A6)+
	AND.L	#$1F001F,(A6)
	OR.L	#$34000C00,(A6)+
	OR	#$FFE0,(A6)+
	AND	#$1F,(A6)
	OR	#$FBE0,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FBC7FFFF,(A6)+
	MOVE.L	#$FFFF0C78,(A6)+
	MOVE.L	#$E3C0FE70,(A6)+
	MOVE.L	#$FFFF1DBF,(A6)+
	AND.L	#$1F001F,(A6)
	OR.L	#$68001800,(A6)+
	OR	#$FFE0,(A6)+
	AND	#$1F,(A6)
	OR	#$F7E0,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FBC5FFFE,(A6)+
	MOVE.L	#$FFFF0CFF,(A6)+
	MOVE.L	#$21C0F070,(A6)+
	MOVE.L	#$FFFFDFBF,(A6)+
	AND.L	#$3F003F,(A6)
	OR.L	#$D0003000,(A6)+
	OR	#$FFC0,(A6)+
	AND	#$3F,(A6)
	OR	#$EFC0,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FBC5FFFE,(A6)+
	MOVE.L	#$FFFF0CFF,(A6)+
	MOVE.L	#$A1DF7060,(A6)+
	MOVE.L	#$FFFFDFBF,(A6)+
	AND.L	#$7F007F,(A6)
	OR.L	#$A0006000,(A6)+
	OR	#$FF80,(A6)+
	AND	D6,(A6)
	OR	#$DF80,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FFFDFFFE,(A6)+
	MOVE.L	#$FFFF18FF,(A6)+
	MOVE.L	#$A3FF73FF,(A6)+
	MOVE.L	#$FFFFDC0F,(A6)+
	MOVEP.L	D7,0(A6)
	LEA	$90(A6),A6
	MOVE.L	#$FFFDFFFE,D7
	MOVE.L	D7,(A6)+
	MOVE.L	#$FFFF1807,(A6)+
	MOVE.L	#$BFFF7FFF,(A6)+
	MOVE.L	#$FFFFCDFF,(A6)+
	MOVEP.L	D4,0(A6)
	LEA	$90(A6),A6
	MOVE.L	#$FFFCFFFF,(A6)+
	MOVE.L	#$FFFF1007,(A6)+
	MOVE.L	#$7F01C601,(A6)+
	MOVE.L	#$FFFFBDFF,(A6)+
	MOVEP.L	D4,0(A6)
	LEA	$90(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	#$FFFF0007,D4
	MOVE.L	D4,(A6)+
	MOVE.L	#$8F00C600,(A6)+
	MOVE.L	A0,(A6)+
	MOVEP.L	D0,0(A6)
	LEA	$90(A6),A6
	MOVE.L	#$FF9FFFFF,(A6)+
	MOVE.L	#$FFFF00E0,(A6)+
	MOVE.L	#$8FC0C7E0,(A6)+
	MOVE.L	#$FFFF7C7F,(A6)+
	MOVE.L	#$1FF01FF,D0
	MOVE.L	#$FE00FE00,D4
	AND.L	D0,(A6)
	OR.L	#$1E007000,(A6)+
	OR.L	D4,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FF1FFFFC,(A6)+
	MOVE.L	A1,(A6)+
	MOVE.L	#$8E00C710,(A6)+
	MOVE.L	A0,(A6)+
	AND.L	D3,(A6)+
	OR.L	D5,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FF3FFFDC,(A6)+
	MOVE.L	A1,(A6)+
	MOVE.L	#$8E08E700,(A6)+
	MOVE.L	A0,(A6)+
	AND.L	D3,(A6)+
	OR.L	D5,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FF7CFF9F,(A6)+
	MOVE.L	A1,(A6)+
	MOVE.L	#$8600FF80,(A6)+
	MOVE.L	A0,(A6)+
	AND.L	D3,(A6)+
	OR.L	D5,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$FFFFFF1F,(A6)+
	MOVE.L	#$FFFF11E0,(A6)+
	MOVE.L	#$C600FFC0,(A6)+
	MOVE.L	#$FFFF3DFF,(A6)+
	AND.L	D3,(A6)+
	OR.L	D5,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$E7FFFF38,(A6)+
	MOVE.L	#$FFFF19E7,(A6)+
	MOVE.L	#$FF007FE0,(A6)+
	MOVE.L	#$FFFF80FF,(A6)+
	AND.L	D3,(A6)+
	OR.L	D5,(A6)+
	LEA	$88(A6),A6
	MOVE.L	#$E7F1FFF0,(A6)+
	MOVE.L	#$FFFF19CF,(A6)+
	MOVE.L	#$FF807FF0,(A6)+
	MOVE.L	#$FFFF807F,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F7E1FFE0,(A6)+
	MOVE.L	#$FFFF199F,(A6)+
	AND.L	#$10001,(A6)
	OR.L	#$FFC27F7C,(A6)+
	OR	D7,(A6)+
	AND	#1,(A6)
	OR	#$80BE,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFC3FFC0,(A6)+
	MOVE.L	#$FFFF183F,(A6)+
	AND.L	#$F000F,(A6)
	OR.L	#$EFF06330,(A6)+
	OR	#$FFF0,(A6)+
	AND	#$F,(A6)
	OR	#$9CF0,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF87FFC0,(A6)+
	MOVE.L	D6,(A6)+
	AND.L	#$3F003F,(A6)
	OR.L	#$E740E100,(A6)+
	OR	#$FFC0,(A6)+
	AND	#$3F,(A6)
	OR	#$3FC0,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF87FFC1,(A6)+
	MOVE.L	#$FFFF007E,(A6)+
	AND.L	#$7F007F,(A6)
	OR.L	#$E300A100,(A6)+
	OR	#$FF80,(A6)+
	AND	D6,(A6)
	OR	#$7F80,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF87FFE1,(A6)+
	MOVE.L	#$FFFF007E,(A6)+
	MOVEM.L	L51316(PC),D3/D6-7/A0
	MOVEP.L	D6,0(A6)
	LEA	$98(A6),A6
	MOVE.L	#$FF87F9F1,(A6)+
	MOVE.L	#$FFFF1E7E,(A6)+
	AND.L	D0,(A6)
	OR.L	#$68009800,(A6)+
	OR.L	D4,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFD7F9F9,(A6)+
	MOVE.L	#$FFFF1E3E,(A6)+
	AND.L	D0,(A6)
	OR.L	#$30008C00,(A6)+
	OR.L	D4,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F9F1FFFF,(A6)+
	MOVE.L	#$FFFF1E9E,(A6)+
	AND.L	D0,(A6)
	OR.L	#$18008600,(A6)+
	OR.L	D4,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F9B1FFFF,(A6)+
	MOVE.L	#$FFFF0ECE,(A6)+
	MOVE.L	#$3FF03FF,D6
	AND.L	D6,(A6)
	OR.L	#$C008000,(A6)+
	OR.L	D7,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF9FFFFF,(A6)+
	MOVE.L	#$FFFF20E0,(A6)+
	AND	D6,(A6)+
	OR.L	D7,(A6)+
	OR	D7,(A6)+
	LEA	$90(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	#$FFFF3C00,(A6)+
	AND	D6,(A6)+
	OR.L	D7,(A6)+
	OR	D7,(A6)+
	LEA	$90(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	#$FFFF3C00,(A6)+
	OR.L	#$F800F800,(A6)+
	OR	#$F800,(A6)+
	AND	#$7FF,(A6)
	OR	#$1800,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$E3FFFFFF,(A6)+
	MOVE.L	#$FFFF3CFF,(A6)+
	AND.L	#$7FF07FF,(A6)
	OR.L	D2,(A6)+
	OR	#$F800,(A6)+
	AND	#$7FF,(A6)
	OR	#$B800,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$E3C3FF81,(A6)+
	MOVE.L	#$FFFF3DFF,(A6)+
	AND.L	D6,(A6)
	OR.L	D3,(A6)+
	OR	D7,(A6)+
	AND	D6,(A6)
	OR	#$7C00,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$E7C5FF83,(A6)+
	MOVE.L	#$FFFF39FE,(A6)+
	AND.L	D0,(A6)
	OR.L	D1,(A6)+
	OR.L	D4,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$EFFFFF87,(A6)+
	MOVE.L	#$FFFF31FC,(A6)+
	AND.L	D0,(A6)
	OR.L	#$C000E000,(A6)+
	OR	D4,(A6)+
	AND	D0,(A6)
	OR	#$7E00,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFEFFFF,(A6)+
	MOVE.L	#$FFFF0003,(A6)+
	OR	#$1000,(A6)
	AND.L	#$11FF01FF,(A6)+
	OR.L	D4,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFEFFFF,(A6)+
	MOVE.L	A0,(A6)+
	AND.L	D6,(A6)+
	OR.L	D7,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFEFC1F,(A6)+
	MOVE.L	#$FFFF07E7,(A6)+
	AND.L	#$7FF07FF,(A6)+
	OR.L	#$F800F800,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFEFC1F,(A6)+
	MOVE.L	A3,(A6)+
	MOVEM.L	L51326(PC),D0/D4/D6-7
	AND	D4,(A6)+
	OR.L	D2,(A6)+
	OR	D2,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FE1FFC1F,(A6)+
	MOVE.L	#$FFFF0FE3,(A6)+
	OR.L	D1,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FE1BFC1C,(A6)+
	MOVE.L	A3,(A6)+
	OR	D1,(A6)
	AND.L	D0,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FC1BFFFC,(A6)+
	MOVE.L	A3,(A6)+
	OR	D5,(A6)
	AND.L	D4,(A6)+
	OR.L	D2,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFF8FFFE,(A6)+
	MOVE.L	A0,(A6)+
	AND.L	D7,(A6)+
	OR.L	D2,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFCFE0F,(A6)+
	MOVE.L	#$FFFF01FB,(A6)+
	AND.L	D7,(A6)+
	OR.L	D2,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FE3EFE1F,(A6)+
	MOVE.L	#$FFFF01F3,(A6)+
	AND	D4,(A6)+
	AND	D4,(A6)
	OR.L	#$8000F000,(A6)+
	OR	D2,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FE3FFE39,(A6)+
	MOVE.L	A1,(A6)+
	AND	D4,(A6)+
	AND	D4,(A6)
	OR.L	#$C000F000,(A6)+
	OR	D2,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF7FFF70,(A6)+
	MOVE.L	#$FFFF11AF,(A6)+
	AND.L	D7,(A6)
	OR.L	D6,(A6)+
	OR.L	D2,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF6BFFF0,(A6)+
	MOVE.L	#$FFFF30BF,(A6)+
	MOVE.L	#$7FFF7FFF,D2
	MOVE.L	#$3FFF3FFF,D4
	MOVE.L	#$FFFF001F,A1
	AND.L	D4,(A6)
	OR.L	#$80004000,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFE1FFF0,(A6)+
	MOVE.L	A1,(A6)+
	OR	D1,(A6)+
	AND	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$E7E0FFF0,(A6)+
	MOVE.L	#$FFFF185F,(A6)+
	OR	D3,(A6)+
	AND	D0,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$E760FFF0,(A6)+
	MOVE.L	#$FFFF18DF,(A6)+
	OR	#$6000,(A6)
	AND.L	#$7FFF1FFF,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$E661FFF3,(A6)+
	MOVE.L	#$FFFF19DF,(A6)+
	AND	D0,(A6)
	OR.L	#$C000E000,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFFFFFE,(A6)+
	MOVE.L	#$FFFF801F,(A6)+
	OR	D3,(A6)+
	AND	D0,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$7FFFFE3C,(A6)+
	MOVE.L	#$FFFFC1C7,(A6)+
	OR	D3,(A6)+
	AND	D0,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$3FFCFC1C,(A6)+
	MOVE.L	#$FFFFE3E7,(A6)+
	AND.L	#$1FFF1FFF,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$1C7CFC0C,(A6)+
	MOVE.L	#$FFFFE7F7,(A6)+
	AND.L	#$1FFF1FFF,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$3C3CFC0C,(A6)+
	MOVE.L	#$FFFFCFF7,(A6)+
	AND.L	#$1FFF1FFF,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FC0CFC3C,(A6)+
	MOVE.L	#$FFFF0FF7,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FC1CFFFF,(A6)+
	MOVE.L	A3,(A6)+
	AND	D2,(A6)+
	OR.L	D5,(A6)+
	OR	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F83FFFFF,(A6)+
	MOVE.L	#$FFFF0FCF,(A6)+
	LEA	$98(A6),A6
	AND.L	#$10001,(A6)
	OR.L	#$FFC0FFF0,(A6)+
	OR	#$FFFE,(A6)+
	AND	#1,(A6)
	OR	#$3E,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$FFC0FFF0,(A6)+
	MOVE.L	#$FFFF003F,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$FE60FFF8,(A6)+
	MOVE.L	#$FFFF07BF,(A6)+
	AND.L	D2,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFB0FE7C,(A6)+
	MOVE.L	#$FFFF07DF,(A6)+
	AND.L	D2,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFF8FE1E,(A6)+
	MOVE.L	#$FFFF07EF,(A6)+
	AND.L	D2,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$1FFEFFFF,(A6)+
	MOVE.L	#$FFFFE7F7,(A6)+
	AND	D2,(A6)+
	OR.L	D5,(A6)+
	OR	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$1FF7FFF8,(A6)+
	MOVE.L	#$FFFFE01F,(A6)+
	OR.L	D5,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$7FF99FF1,(A6)+
	MOVE.L	#$FFFFE01F,(A6)+
	OR	D5,(A6)
	AND.L	#$BFFF3FFF,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$7FFF983E,(A6)+
	MOVE.L	#$FFFFEFC7,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$78FE9830,(A6)+
	MOVE.L	#$FFFFEFDF,(A6)+
	OR	#$4000,(A6)
	AND.L	#$7FFF3FFF,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F8FC9860,(A6)+
	MOVE.L	#$FFFF6FBF,(A6)+
	OR	D5,(A6)+
	AND	D2,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F8E1FFE0,(A6)+
	MOVE.L	#$FFFF0F7F,(A6)+
	OR.L	D5,(A6)+
	OR	D5,(A6)+
	AND	D2,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F9E3FFE1,(A6)+
	MOVE.L	#$FFFF0E7E,(A6)+
	OR.L	D5,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFE3FFFF,(A6)+
	MOVE.L	#$FFFFC07D,(A6)+
	OR	D5,(A6)+
	AND	D2,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFC7DFFE,(A6)+
	MOVE.L	#$FFFFE07B,(A6)+
	OR	D5,(A6)
	AND.L	#$BFFF3FFF,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFFDC7C,(A6)+
	MOVE.L	#$FFFFEF87,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$DCFEFC38,(A6)+
	MOVE.L	#$FFFF6FC7,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FC78FC18,(A6)+
	MOVE.L	#$FFFF0FEF,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FC3FFC5F,(A6)+
	MOVE.L	#$FFFF0FEF,(A6)+
	OR.L	D1,(A6)+
	OR	D1,(A6)+
	AND	D4,(A6)
	OR	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FE5FFE5F,(A6)+
	MOVE.L	#$FFFF07EF,(A6)+
	MOVE.L	#$1FFF1FFF,D2
	MOVE.L	#$FFFF01DF,A3
	AND.L	D2,(A6)
	OR.L	D5,(A6)+
	OR	D3,(A6)+
	AND	D0,(A6)
	OR	#$6000,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$EF5FFFDF,(A6)+
	MOVE.L	#$FFFF3BE0,(A6)+
	AND.L	D7,(A6)
	OR.L	D5,(A6)+
	OR	#$F000,(A6)+
	AND	D7,(A6)
	OR	#$7000,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$E796FF99,(A6)+
	MOVE.L	#$FFFF3CEF,(A6)+
	AND.L	D7,(A6)
	OR.L	D5,(A6)+
	OR	#$F000,(A6)+
	AND	D7,(A6)
	OR	#$7000,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$E396FF99,(A6)+
	MOVE.L	#$FFFF3DEF,(A6)+
	AND.L	D7,(A6)
	OR.L	#$90008000,(A6)+
	OR	#$F000,(A6)+
	AND	D7,(A6)
	OR	#$7000,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF90FFFF,(A6)+
	MOVE.L	#$FFFF3DEF,(A6)+
	AND	D0,(A6)
	OR.L	D6,(A6)+
	OR	D3,(A6)+
	AND	D0,(A6)
	OR	#$6000,(A6)+
	LEA	$90(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	#$FFFF3C67,(A6)+
	OR.L	D1,(A6)+
	OR	D1,(A6)+
	AND	D4,(A6)
	OR	#$4000,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFCFFF0C,(A6)+
	MOVE.L	#$FFFF01F3,(A6)+
	OR	D3,(A6)+
	AND	D0,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF8EFF08,(A6)+
	MOVE.L	#$FFFF01F7,(A6)+
	AND.L	D2,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF1CE318,(A6)+
	MOVE.L	#$FFFF7FEF,(A6)+
	AND.L	D2,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFCE3F8,(A6)+
	MOVE.L	#$FFFF7E1F,(A6)+
	AND.L	D2,(A6)+
	OR.L	D3,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FE38E33F,(A6)+
	MOVE.L	#$FFFF7FDF,(A6)+
	AND	D4,(A6)+
	OR.L	D1,(A6)+
	OR	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FE3FE33F,(A6)+
	MOVE.L	#$FFFF7FDF,(A6)+
	OR.L	D5,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$C2FFFF3F,(A6)+
	MOVE.L	#$FFFF7FC0,(A6)+
	OR.L	D5,(A6)+
	OR	D5,(A6)+
	MOVE.L	#$10001,D2
	MOVE.L	#$7FFF7FFF,D7
	AND	D7,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFE0FFF0,(A6)+
	MOVE.L	A3,(A6)+
	AND	D4,(A6)+
	AND	D4,(A6)
	OR.L	#$4000C000,(A6)+
	OR	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFE0F1F8,(A6)+
	MOVE.L	#$FFFF3E3F,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFF0F99C,(A6)+
	MOVE.L	#$FFFF1E7F,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFFFF8F,(A6)+
	MOVE.L	#$FFFF0EFF,(A6)+
	OR.L	D1,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF9FFF87,(A6)+
	MOVE.L	#$FFFF00FF,(A6)+
	OR.L	D5,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F18FFF87,(A6)+
	MOVE.L	#$FFFF1EFD,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$F98FF18E,(A6)+
	MOVE.L	#$FFFF1EFB,(A6)+
	OR	D5,(A6)
	AND.L	#$BFFF3FFF,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F9FFF1FC,(A6)+
	MOVE.L	#$FFFF1EF7,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFCF1FC,(A6)+
	MOVE.L	#$FFFF1EE7,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFF8F7FF,(A6)+
	MOVE.L	#$FFFF1E07,(A6)+
	AND	D7,(A6)+
	OR.L	D5,(A6)+
	OR	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F7D8FE1F,(A6)+
	MOVE.L	#$FFFF1BE7,(A6)+
	AND	D7,(A6)+
	OR.L	D5,(A6)+
	OR	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FF9FFE1F,(A6)+
	MOVE.L	#$FFFF03E1,(A6)+
	AND	D7,(A6)+
	OR.L	D5,(A6)+
	OR	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FE16FE1F,(A6)+
	MOVE.L	#$FFFF03E9,(A6)+
	AND.L	D7,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$9E17FFFA,(A6)+
	MOVE.L	#$FFFF63ED,(A6)+
	AND.L	D7,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$DC13FFF9,(A6)+
	MOVE.L	#$FFFF63EE,(A6)+
	OR.L	D5,(A6)+
	OR	D5,(A6)+
	AND	D7,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$DFF1FFF8,(A6)+
	MOVE.L	#$FFFF600F,(A6)+
	OR.L	D5,(A6)+
	OR	D5,(A6)+
	AND	D7,(A6)+
	LEA	$90(A6),A6
	AND	D2,(A6)
	OR.L	#$FFD0FFFE,(A6)+
	OR	#$FFFE,(A6)+
	AND	D2,(A6)
	OR	#$6E,(A6)+
	LEA	$98(A6),A6
	AND.L	D2,(A6)
	OR.L	#$FFEEFFDE,(A6)+
	OR	#$FFFE,(A6)+
	AND	D2,(A6)
	OR	#$76,(A6)+
	LEA	$98(A6),A6
	AND.L	D2,(A6)
	OR.L	#$F1F4FFCC,(A6)+
	OR	#$FFFE,(A6)+
	AND	D2,(A6)
	OR	#$3F7E,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$FFE8F0D8,(A6)+
	MOVE.L	#$FFFF3F7F,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$F1D0F0F0,(A6)+
	MOVE.L	#$FFFF3F7F,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$F1E0F8F0,(A6)+
	MOVE.L	#$FFFF1F7F,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$F9E0FCF0,(A6)+
	MOVE.L	#$FFFF2F7F,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$DDE0FEF0,(A6)+
	MOVE.L	#$FFFF377F,(A6)+
	LEA	$98(A6),A6
	AND.L	D2,(A6)
	OR.L	#$CFE0FFF0,(A6)+
	OR	#$FFFE,(A6)+
	AND	D2,(A6)
	OR	#$3B7E,(A6)+
	LEA	$98(A6),A6
	AND.L	#$30003,(A6)
	OR.L	#$DFE0EFF0,(A6)+
	OR	#$FFFC,(A6)+
	AND	#3,(A6)
	OR	#$307C,(A6)+
	LEA	$98(A6),A6
	AND.L	#$70007,(A6)
	OR.L	#$DFE0FFF0,(A6)+
	OR	#$FFF8,(A6)+
	AND	#7,(A6)
	OR	#$2038,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$F9FFFE7C,(A6)+
	MOVE.L	#$FFFF0797,(A6)+
	LEA	$98(A6),A6
	MOVE.L	#$F3FEFCF8,(A6)+
	MOVE.L	#$FFFF0F0F,(A6)+
	AND.L	D7,(A6)+
	OR.L	D5,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F7FCF9F0,(A6)+
	MOVE.L	#$FFFF0E1F,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFF8FFF0,(A6)+
	MOVE.L	A1,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFF0FFF0,(A6)+
	MOVE.L	A1,(A6)+
	AND.L	D4,(A6)+
	OR.L	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FEF0FF3F,(A6)+
	MOVE.L	A3,(A6)+
	AND	D4,(A6)+
	OR.L	D1,(A6)+
	OR	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FEE0FF3F,(A6)+
	MOVE.L	A3,(A6)+
	AND	D4,(A6)+
	OR.L	D1,(A6)+
	OR	D1,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FE7FFFBF,(A6)+
	MOVE.L	#$FFFF01C0,(A6)+
	OR.L	D3,(A6)+
	OR	D3,(A6)+
	AND	D0,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F73FFFF8,(A6)+
	MOVE.L	#$FFFF08CF,(A6)+
	AND.L	#$3FF03FF,(A6)
	OR.L	#$E0002000,(A6)+
	OR	#$FC00,(A6)+
	AND	#$3FF,(A6)
	OR	#$DC00,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$F3FCFFFC,(A6)+
	MOVE.L	#$FFFF0C0F,(A6)+
	AND.L	#$1FF01FF,(A6)
	OR.L	#$60002000,(A6)+
	OR	#$FE00,(A6)+
	AND	#$1FF,(A6)
	OR	#$DE00,(A6)+
	LEA	$90(A6),A6
	MOVE.L	#$FFFEFFFE,(A6)+
	MOVE.L	A0,(A6)+
	MOVE.L	#$6123FFDF,D0
	MOVEP.L	D0,0(A6)
	LEA	$98(A6),A6
	MOVE.L	A2,(A6)+
	MOVE.L	#$FFFF0013,(A6)+
	AND.L	#$7F007F,(A6)
	OR.L	#$63002600,(A6)+
	OR	#$FF80,(A6)+
	AND	#$7F,(A6)
	OR	#$DD80,(A6)+
noroc:
	CPU	$222
	movem.l	(sp)+,d0-d7/a0-a6
	rte
;
; routines d'affichage pour chaque sprite...
;
; (m‚morisent les coordonn‚es et les tailles pour l'effacement)
;
affiche_sorcier
	CPU	$070		;vert
	move	xsorc(pc),d1
	move	#hauteur/2-2+80-1,d2	;Y
	lea	IMAGESORCIER,a5
	move	numsorc(pc),d0	;num‚ro de sprite
	asl	#3,d0
	clr	d3
	move.b	5(a5,d0.w),d3
	sub	d3,d2
	lsr	#3,d0
	bra	bob
;
; entr‚e : d1=X,d2=Y
;
affiche_femme
	CPU	$700		;rouge
	lea	IMAGEFEMME,a5
	lea	FASTFEMME,A0
	move	numfemme(pc),d0	;num‚ro de sprite
	moveq	#-1,d5		;n'arrondit pas en X
	bra	fast_bob

affiche_homme:
	CPU	$007		;bleu
	move	#hauteur/2-2+80-1,d2	;Y
	lea	IMAGECOURSE,a5
	move	xhomme(pc),d1
	move	numhomme(pc),d0		;num‚ro de sprite
	asl	#3,d0
	clr	d3
	move.b	5(a5,d0.w),d3
	sub	d3,d2
	lsr	#3,d0
	bra	bob

affiche_trans:
	CPU	$007		;bleu
	move	#hauteur/2-2+80-1,d2	;Y
	lea	IMAGETRANS,a5
	move	xhomme(pc),d1
	move	numhomme(pc),d0		;num‚ro de sprite
	asl	#3,d0
	clr	d3
	move.b	5(a5,d0.w),d3
	sub	d3,d2
	lsr	#3,d0
	bra	bob

affiche_tir
	CPU	$700		;rouge
	move	xtir(pc),d1
	move	#hauteur/2-2+80-64-1-8,d2
	lea	IMAGERAYON,a5
	lea	FASTRAYON,A0
	move	numtir(pc),d0	;num‚ro de sprite
	moveq	#-1,d5		;n'arrondit pas en X
	bra	fast_bob
;
; entr‚e : d1=X logo
;
	ifeq	1
affiche_logo
	CPU	$700		;rouge
	move	#hauteur/2-2+80-64-1-50,d2
	lea	IMAGELOGO,a5
	lea	FASTLOGO,A0
	CLR	D0		;num‚ro de sprite
	moveq	#-1,d5		;n'arrondit pas en X
	bra	fast_bob
	endc

demo:
	move	anim(pc),d0
	add	d0,d0
	add	d0,d0
	jmp	test(pc,d0.w)
test:	bra.w	initanim	;0
	bra.w	anim0		;1
	bra.w	anim1		;2
	bra.w	anim2		;3
	bra.w	anim3		;4
	bra.w	anim4		;5
	rts			;6=rien

initanim:
	move	#6-1,cptsorc
	move	#largeur,xsorc
	move	#3,numsorc
	clr	modesorc

	clr	ptrfemme
	clr	numfemme
	move	#16-1,cptfemme
	addq	#1,anim
	rts

anim0:
	bsr	gere_sorcier
	bsr	affiche_sorcier

	move.b	flagfemme(pc),d0
	bne.s	.goodmeuf
	rts
.goodmeuf
	subq	#1,cptfemme
	bge.s	.bob
	move	#16-1,cptfemme
	eor	#1,numfemme
.bob
	move	ptrfemme(pc),d0
	lea	coords(pc),a0
	add	d0,a0
	addq	#4,d0
	cmp	#fincoords-coords,d0
	blo.s	.okcoords
	clr	d0
	addq	#1,anim
	clr.b	flagfemme
	move	#-30,xhomme
	clr	cpthomme
	clr	numhomme
.okcoords
	move	d0,ptrfemme

	clr	d1
	move.b	(a0)+,d1
	addq	#2,d1		;X
	clr	d2
	move.b	(a0)+,d2
	sub	#100,d2		;Y
	bra	affiche_femme

anim1:
	bsr	gere_sorcier
	bsr	affiche_sorcier
	bsr	gere_homme
	bra	affiche_homme

anim2:
	bsr	gere_sorcier
	bsr	affiche_sorcier
	bsr	gere_homme
	bsr	affiche_homme

	subq	#3,xtir
	move	xhomme(pc),d0
	add	#32,d0
	sub	xtir(pc),d0
	blt.s	.goodx
	addq	#1,anim
	move	#10-1,cpthomme	;transformation
	clr	numhomme
	clr	flagsorc
	clr.b	flagfemme
.goodx
	subq	#1,cpttir
	bge.s	.bob
	move	#2-1,cpttir
	eor	#1,numtir
.bob
	bra	affiche_tir

anim3:
	bsr	gere_sorcier
	add	#65536/3,flagsorc
	bcs.s	1$
	bsr	affiche_sorcier
1$
	subq	#1,cpthomme
	bpl.s	.nonew
	move	#5-1,cpthomme
	cmp	#15,numhomme
	bne.s	.nobob
	addq	#1,anim
	clr	ptronde
	bra.s	.nonew
.nobob
	addq	#1,numhomme
.nonew
	bra	affiche_trans
anim4:
	move	ptronde(pc),d0
	lea	ondes(pc),a0
	add	d0,a0
	cmp.l	#finondes-2*64,a0
	blo.s	.good

	lea	finondes-2*64,a0
	move.b	restart(pc),d0
	bne.s	.good
	st	restart
	move	#-1,fade
.good
	addq	#6,ptronde
	move	#2,effacelogo
	pea	(a6)
	bsr	distort_logo
	move.l	(sp)+,a6
	rts

gere_sorcier:
	move	modesorc(pc),d0
	add	d0,d0
	add	d0,d0
	jmp	gestsorci(pc,d0.w)
gestsorci:
	bra.w	sorcier0
	bra.w	sorcier1
	bra.w	sorcier2

sorcier0:
	cmp	#XSORCIER,xsorc
	bgt.s	.newx1
	cmp	#3,numsorc
	bne.s	.newx1
	addq	#1,modesorc
	clr	numsorc		;reset anim sorcier
	move	#150-1,cptsorc
	rts
.newx1
	subq	#1,cptsorc
	bpl.s	.new1
	move	#6-1,cptsorc

	addq	#1,numsorc
	cmp	#7,numsorc
	blo.s	.new1
	move	#3,numsorc
.new1
	cmp	#XSORCIER,xsorc
	ble.s	.newx
	subq	#1,xsorc
.newx
	rts
sorcier1:
	subq	#1,cptsorc
	bpl.s	.finanim
	move	#20-1,cptsorc
	cmp	#2,numsorc
	blo.s	.bob2
	addq	#1,anim
	move	xsorc(pc),xtir	;tir du sorcier
	sub	#16,xtir
	clr	numtir		;initialise le tir
	addq	#1,modesorc
	move	#2-1,cpttir
	bra.s	.finanim
.bob2
	addq	#1,numsorc
.finanim
	rts
sorcier2:
	subq	#1,cptsorc
	bge.s	.finanim
	move	#20-1,cptsorc
	move	numsorc(pc),d0
	beq.s	.finanim
	subq	#1,numsorc
.finanim
	rts

gere_homme:
	addq	#1,xhomme
	subq	#1,cpthomme
	bge.s	.bob
	move	#7-1,cpthomme
	addq	#1,numhomme
	cmp	#6,numhomme
	blo.s	.bob
	clr	numhomme
.bob
	rts

cliproc:
	cmp	#32+16,d1
	bge.s	1$
	st	flagroc
	CPU	$700
1$	rts

fast_bob:
	asl	#3,d0		;num‚ro spr*8
	clr	d3
	move.b	6(a5,d0.w),d3
	add	d3,d1
	and	d5,d1
	clr	d4
	move.b	4(a5,d0.w),d3
	move.b	5(a5,d0.w),d4

	bsr.s	cliproc

	add	d0,d0		;num‚ro spr*16
	moveq	#$f,d5
	and	d1,d5
	add	d5,d0		;+d‚calage=ptr sprite
	asl	#2,d0
	move.l	(a0,d0.w),a0
	bra	aff_fast
bob:
	asl	#3,d0		;*8
	add	d0,a5
	move.l	(a5)+,a0	;adresse image

	clr	d3
	move.b	(a5)+,d3	;taille x
	clr	d4
	move.b	(a5)+,d4	;taille Y

	move.b	(a5)+,d0	;calage en X
	ext	d0
	add	d0,d1
	move.b	(a5)+,d0	;calage en Y
	ext	d0
	add	d0,d2

	bsr.s	cliproc
;
; a0=d‚but du sprite
;
; d0=num‚ro du sprite ???
; a0=d‚but du bitmap du sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
;
; nouvelle routine de sprite d‚calant
;
; a0=d‚but du bitmap du sprite
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
;	A0=adresse Bitmap du sprite
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
	add	d2,a0
	moveq	#offsety*160+24,d2
	bra.s	.noclipbas
.cliphau
	move	d2,d0
	add	d4,d0

	mulu	#160,d2
	add	#offsety*160+24,d2	;offset ‚cran

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
	add	a3,a0
	or.b	#$40,d0		;indique clipping … gauche
	bra.s	.noclipdro
.clipgau
	sub.l	a3,a3
	add	d1,d2		;offset Y
	add	d3,d1
	sub	#largeur/2,d1	;>nb plans dans une ligne ?
	blo.s	.noclipdro
	tas	d0		;indique clipping … droite
	sub	d1,d3		;calcul nb plans restants
	move	d1,a3
	clr	d5		;aucun pixel ne d‚passe … droite
	bra.s	.pacl
.noclipdro
	cmp	#16,d5
	bhs.s	.pacl
	tas	d0
	clr	d5		;aucun pixel ne d‚passe … droite
.pacl
	move.l	ecran(pc),a1
	add	d2,a1

	move	#160,a2
	sub	d3,a2
;
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;	d5=nb pixels de plus … droite
;
	and	#-16,d5
	lsr	#1,d5
	add	d3,d5

	subq	#1,d4

	lsr	#1,d5
	move	d5,(a6)+	;largeur/2
	move	d4,(a6)+	;hauteur-1
	move	d2,(a6)+	;offset

	lsr	#3,d3
;
; entr‚e :
;	d3=nb plans … afficher
;	d4=nb lignes … afficher
;	a0=ptr bitmap sprite
;	a1=ptr bitmap ‚cran
;	a2=incr‚ment pour ‚cran
;	a3=incr‚ment pour sprite
;
	LEA	newsprite,a4
	jmp	(a4,d0.w)
.retsp
	rts	
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
predecale
	move	d0,-(sp)
	asl	#6,d0
	MOVE.L	A4,A6
	ADD.L	D0,A6
decale
	moveq	#0,d6
1$
	move.l	a6,(a4)+	;poke pointeur bitmap

	move.l	(a5),a3

	moveq	#15,d0
	add.b	4(a5),d0

	moveq	#$f,d2
	and	d0,d2		;nb pixels … droite

	clr	d1
	move.b	5(a5),d1

	lsr	#4,d0

	move	d0,nbplan	;nbplan=d0

	clr	onemore
	add	d6,d2		;nb pixels aprŠs d‚calage=nb pixels+d‚calage
	cmp	#16,d2		;est-ce que ‡a rajoute un plan ??
	blo.s	7$
	st	onemore
	addq	#1,d0
7$
;
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes
;
const	equr	d2
reste1	equr	d4
reste2	equr	d5
cptplan	equr	d7

	lea	planes(pc),a1
	move	d6,const
	add	const,const
	add	const,const
	move.l	(a1,const.w),const

	subq	#2,nbplan

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

	move	nbplan(pc),cptplan
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
	move	onemore(pc),d0
	beq.s	5$

	swap	reste1
	swap	reste2

	move.l	reste1,(a6)+
	move.l	reste2,(a6)+
5$
	subq	#1,d1		;dec nblig
	bne.s	2$

	addq	#1,d6
	cmp	#16,d6
	blo	1$

	addq	#8,a5
	subq	#1,(sp)
	bne	decale
	addq	#2,sp
	rts

predecale_logo
	lea	4*16(a4),a6
	moveq	#0,d6
1$
	move.l	a6,(a4)+	;poke pointeur bitmap

	move.l	(a5),a3

	moveq	#15,d0
	add.b	4(a5),d0

	moveq	#$f,d2
	and	d0,d2		;nb pixels … droite

	clr	d1
	move.b	5(a5),d1

	lsr	#4,d0

	subq	#2,d0
	move	d0,nbplan	;nbplan=d0 et nblig=d1
;
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes
;
	lea	planes(pc),a1
	move	d6,const
	add	const,const
	add	const,const
	move.l	(a1,const.w),const

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

	move	nbplan(pc),cptplan
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
	move.l	reste1,d0
	or.l	reste2,d0
	swap	reste1
	swap	reste2
	or.l	reste1,d0
	or.l	reste2,d0
	not.l	d0
	move.l	d0,(a6)+
	move.l	reste1,(a6)+
	move.l	reste2,(a6)+

	subq	#1,d1		;dec nblig
	bne.s	2$

	addq	#1,d6
	cmp	#16,d6
	blo	1$
	rts
;
; entr‚e :
;	a0 pointe sur la table de d‚formation
;
distort_logo:
	CPU	$770
	moveq	#64-1,d7
	move.l	ecran(pc),a6
	lea	ylogo*160+24(a6),a6
	moveq	#0,d6
	lea	FASTLOGO,A4
.ligne
	move.l	a6,a2
	move	(a0)+,d0	;X

	moveq	#15,d1
	and	d0,d1
	eor	d1,d0

	add	d1,d1
	add	d1,d1
	move.l	(a4,d1.w),a1
	add.l	d6,a1

	cmp	#224-192,d0
	blo.s	.pasclip
	bge.s	.clipgauche
;
; on doit clipper … gauche
;
	neg	d0
	cmp	#192,d0		;d0=nb pixels … clipper
	bhs	.noaff

	lsr	#1,d0
	move	d0,d1
	lsr	#1,d0
	add	d1,d0
	add	d0,a1
	jmp	.noclip(pc,d0.w)
.clipgauche
	cmp	#224,d0
	bhs	.noaff
;
; on doit clipper … droite
;
	lsr	#1,d0
	add	d0,a2		;offset horizontal
	lea	.aff(pc),a3
	sub	#224/2,d0	;d0=-(nb plans … afficher*8)
	add	d0,a3
	asr	#1,d0
	add	d0,a3
	jmp	(a3)
.pasclip
	lsr	#1,d0
	add	d0,a2
.noclip
	rept	192/16
	movem.l	(a1)+,d0-d2
	and.l	d0,(a2)
	or.l	d1,(a2)+
	and.l	d0,(a2)
	or.l	d2,(a2)+
	endr
.aff
.noaff
	lea	160(a6),a6
	add	#192/8*12/2,d6
	dbra	d7,.ligne
	rts
;
; affichage d'un sprite clipp‚ pr‚d‚cal‚
;
; entr‚e :
;	a0=d‚but bitmap sprite
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;	a6=m‚mo effacement sprite
;
fin_fast:rts
aff_fast:
;	moveq	#15,d5
;	add	d5,d3
;	and	d3,d5
;	sub	d5,d3
;
;	lsr	#1,d3		;d3=nboctets/ligne … afficher

	moveq	#$f,d5
	and	d1,d5
	add	d5,d3		;nb pixels de largeur
	eor	d5,d1

	add	#15,d3
	and	#$FFF0,d3
	lsr	#1,d3		;d3=nboctets/ligne … afficher

	cmp	#hauteur,d2
	blo.s	1$
	bge.s	fin_fast

	neg	d2
	sub	d2,d4
	bls.s	fin_fast
	mulu	d3,d2
	add	d2,a0
	moveq	#offsety*160+24,d2
	bra.s	2$
1$
	move	d2,d0
	add	d4,d0

	mulu	#160,d2
	add	#offsety*160+24,d2	;offset ‚cran

	sub	#hauteur,d0
	bls.s	2$
	sub	d0,d4
2$
	asr	#1,d1
	cmp	#largeur/2,d1
	blo.s	3$
	bge.s	fin_fast
	neg	d1
	sub	d1,d3
	bls.s	fin_fast
	move	d1,a3		;coefficient de clipping
	add	a3,a0		;+1/2 pour mask
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
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
;	cmp	#8,d3
;	bne.s	.no
;	dc.l	$4a780001
;.no
	subq	#1,d4

	lsr	#1,d3
	move	d3,(a6)+	;largeur/2
	move	d4,(a6)+	;hauteur-1
	move	d2,(a6)+	;offset

	move.l	ecran(pc),a1
	add	d2,a1		;adresse ‚cran

	jmp	.sprites-4(pc,d3.w)
.sprites:
	bra.w	nspr16
	bra.w	nspr32
	bra.w	nspr48
	bra.w	nspr64
	bra.w	nspr80
	dc.l	$4a780001
;
;	LA ROUTINE DE SPRITES !!!!
;
; toujours le meme principe...
;
msk	macro
	move.l	(a0)+,\1
	move.l	(a0)+,\2
	move.l	\2,d6
	or.l	\1,d6
	move.l	d6,d7
	swap	d7
	or.l	d6,d7
	not.l	d7
	move.l	d7,d6
	and.l	(a1)+,d6
	add.l	d6,\1
	and.l	(a1)+,d7
	add.l	d7,\2
	endm
nspr16					;sprite 16 de large
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	dbra	d4,nspr16
	rts
nspr32					;sprite 32 de large
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	dbra	d4,nspr32
	rts
nspr48					;sprite 48 de large
	msk	d0,d1
	msk	d2,d3
	msk	d5,a4
	movem.l	d0-d3/d5/a4,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	dbra	d4,nspr48
	rts

nspr64					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d5,a4
	movem.l	d0-d3/d5/a4,-24(a1)
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-24(a1),a1
	dbra	d4,nspr64
	rts

nspr80					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d5,a4
	movem.l	d0-d3/d5/a4,-24(a1)
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-24(a1),a1
	dbra	d4,nspr80
	rts

source=224/2
neff16
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	source-8(a0),a0
	lea	160-8(a1),a1
	dbra	d7,neff16
	rts
neff32
	movem.l	(a0),d0-d3
	movem.l	d0-d3,(a1)
	lea	source(a0),a0
	lea	160(a1),a1
	dbra	d7,neff32
	rts
neff48
	movem.l	(a0),d0-d5
	movem.l	d0-d5,(a1)
	lea	source(a0),a0
	lea	160(a1),a1
	dbra	d7,neff48
	rts
neff64
	movem.l	(a0),d0-d6/a2
	movem.l	d0-d6/a2,(a1)
	lea	source(a0),a0
	lea	160(a1),a1
	dbra	d7,neff64
	rts
neff80
	movem.l	(a0),d0-d6/a2/a3/a4
	movem.l	d0-d6/a2/a3/a4,(a1)
	lea	source(a0),a0
	lea	160(a1),a1
	dbra	d7,neff80
	rts

newsprite:incbin SPRITE18.BIN
	IFEQ	FINAL
;musique:incbin	e:\includes\mus1.bin
	ELSEIF
musique:incbin	e:\includes\replay8.bin
	ENDC

L512CA	DC.L	$FFF0FFF,$C0008000,$F000F000,$8000E000
	DC.L	$EFFF0FFF,$80008000,$FFFF007F,$C0C0FFFF
	DC.L	$FFFFEFFB,$FFF3FFFF,$FFFFFFFF,$FFFF0000
L512FA	DC.L	$8FF8FFFF,$C000C000,$7FFF7FFF,$80C0FF7F
	DC.L	$FFFF7DFF,$FFFF01E7,$FFFF0FE7
L51316	DC.L	$E000E000,$50B1FFFF,$FC00FC00,$FFFF0007
L51326	DC.L	$DFFF1FFF,$8FFF0FFF,$8000E000,$FFF0FFF
planes	DC.L	$00000000,$80008000,$C000C000,$E000E000
	DC.L	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	DC.L	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	DC.L	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE
realpalette:
	DC.W	$000,$027,$037,$047,$414,$765,$400,$000
	DC.W	$040,$150,$314,$030,$643,$631,$520,$300
coords:
	dc.b	1,172,2,172
	dc.b	3,172,4,172,5,172,6,172,7,172,9,172
	dc.b	10,171,11,171,13,171,14,171,15,171,17,171
	dc.b	18,171,20,170,21,170,22,170,24,170,25,169
	dc.b	27,169,29,169,30,168,32,168,33,168,35,167
	dc.b	37,167,38,167,40,166,42,166,43,166,45,165
	dc.b	47,165,48,164,50,163,52,163,54,162,55,162
	dc.b	57,161,59,161,61,160,62,159,64,159,66,158
	dc.b	68,158,69,157,71,156,73,155,74,155,76,154
	dc.b	78,153,79,152,81,152,83,151,84,150,86,149
	dc.b	88,149,89,148,91,147,92,146,94,145,95,144
	dc.b	97,144,98,143,100,142,101,141,103,140,104,139
	dc.b	105,139,107,138,108,137,109,136,110,135,112,134
	dc.b	113,134,114,133,115,132,116,131,117,130,118,130
	dc.b	119,129,120,128,121,127,122,126,123,126,124,125
	dc.b	125,124,125,123,126,123,127,122,128,121,128,120
	dc.b	129,120,129,119,130,118,130,117,131,117,131,116
	dc.b	132,115,132,115,132,114,133,114,133,113,133,112
	dc.b	133,112,134,111,134,111,134,110,134,110,134,109
	dc.b	134,108,134,108,134,108,134,107,134,107,134,106
	dc.b	133,106,133,105,133,105,133,104,133,104,132,104
	dc.b	132,104,132,103,131,103,131,103,131,103,130,102
	dc.b	130,102,129,102,129,102,128,102,128,101,127,101
	dc.b	127,101,126,101,126,101,125,101,125,101,124,101
	dc.b	124,101,123,101,123,101,122,101,121,101,121,101
	dc.b	120,102,120,102,119,102,118,102,118,102,117,102
	dc.b	117,103,116,103,115,103,115,103,114,104,114,104
	dc.b	113,104,113,105,112,105,112,106,111,106,111,107
	dc.b	110,107,110,107,109,108,109,109,108,109,108,110
	dc.b	108,110,107,111,107,111,107,112,106,112,106,113
	dc.b	106,114,106,114,105,115,105,115,105,116,105,117
	dc.b	105,118,105,118,105,119,105,119,105,120,105,121
	dc.b	105,122,105,123,105,123,105,124,105,125,106,126
	dc.b	106,126,106,127,107,128,107,129,107,129,108,130
	dc.b	108,131,109,132,109,132,110,133,110,134,111,135
	dc.b	112,136,112,137,113,137,114,138,115,139,115,140
	dc.b	116,140,117,141,118,142,119,143,120,143,121,144
	dc.b	122,145,123,146,124,146,125,147,126,148,128,149
	dc.b	129,149,130,150,131,151,132,151,134,152,135,153
	dc.b	136,153,138,154,139,154,141,155,142,156,143,156
	dc.b	145,157,147,157,148,158,150,159,151,159,153,159
	dc.b	154,160,156,161,157,161,159,161,161,162,162,162
	dc.b	164,163,165,163,167,163,169,164,170,164,172,164
	dc.b	174,165,175,165,177,165,179,165,180,165,182,166
	dc.b	184,166,185,166,187,166,189,166,190,166,192,166
	dc.b	194,166,195,166,197,167,198,167,200,167,201,167
	dc.b	203,167,204,166,206,166,207,166,209,166,210,166
	dc.b	211,166,213,166,214,166,215,166,217,165,218,165
	dc.b	219,165,220,165,222,164,223,164,224,164,225,163
fincoords:
	dc.b	1,172
	even
ondes:
	DC.W	$27,$14,2,$FFF0
	DC.W	$FFDF,$FFCE,$FFBD,$FFAD
	DC.W	$FF9D,$FF8E,$FF7F,$FF71
	DC.W	$FF63,$FF56,$FF4A,$FF3E
	DC.W	$FF33,$FF28,$FF1E,$FF15
	DC.W	$FF0C,$FF04,$FEFD,$FEF6
	DC.W	$FEF1,$FEEC,$FEE7,$FEE4
	DC.W	$FEE1,$FEDF,$FEDD,$FEDD
	DC.W	$FEDC,$FEDD,$FEDF,$FEE1
	DC.W	$FEE3,$FEE7,$FEEB,$FEEF
	DC.W	$FEF4,$FEFA,$FF00,$FF07
	DC.W	$FF0F,$FF16,$FF1F,$FF28
	DC.W	$FF31,$FF3A,$FF44,$FF4F
	DC.W	$FF59,$FF64,$FF70,$FF7B
	DC.W	$FF87,$FF93,$FF9F,$FFAB
	DC.W	$FFB7,$FFC4,$FFD0,$FFDD
	DC.W	$FFE9,$FFF6,2,$E
	DC.W	$1A,$27,$32,$3E
	DC.W	$4A,$55,$60,$6B
	DC.W	$76,$80,$8A,$93
	DC.W	$9D,$A5,$AE,$B6
	DC.W	$BE,$C5,$CC,$D2
	DC.W	$D8,$DE,$E3,$E7
	DC.W	$EC,$EF,$F2,$F5
	DC.W	$F7,$F9,$FB,$FB
	DC.W	$FC,$FC,$FB,$FA
	DC.W	$F9,$F7,$F5,$F2
	DC.W	$EF,$EC,$E8,$E4
	DC.W	$DF,$DB,$D6,$D0
	DC.W	$CA,$C4,$BE,$B8
	DC.W	$B1,$AA,$A3,$9C
	DC.W	$94,$8D,$85,$7D
	DC.W	$76,$6E,$66,$5E
	DC.W	$56,$4E,$46,$3E
	DC.W	$36,$2E,$27,$1F
	DC.W	$17,$10,9,2
	DC.W	$FFFB,$FFF4,$FFEE,$FFE8
	DC.W	$FFE1,$FFDC,$FFD6,$FFD1
	DC.W	$FFCC,$FFC7,$FFC2,$FFBE
	DC.W	$FFBA,$FFB6,$FFB3,$FFB0
	DC.W	$FFAD,$FFAA,$FFA8,$FFA6
	DC.W	$FFA4,$FFA3,$FFA2,$FFA1
	DC.W	$FFA1,$FFA1,$FFA1,$FFA1
	DC.W	$FFA2,$FFA3,$FFA4,$FFA5
	DC.W	$FFA7,$FFA9,$FFAB,$FFAE
	DC.W	$FFB0,$FFB3,$FFB6,$FFBA
	DC.W	$FFBD,$FFC1,$FFC4,$FFC8
	DC.W	$FFCC,$FFD1,$FFD5,$FFD9
	DC.W	$FFDE,$FFE3,$FFE7,$FFEC
	DC.W	$FFF1,$FFF6,$FFFB,0
	DC.W	5,9,$E,$13
	DC.W	$18,$1D,$22,$26
	DC.W	$2B,$30,$34,$39
	DC.W	$3D,$41,$45,$49
	DC.W	$4D,$50,$54,$57
	DC.W	$5A,$5E,$60,$63
	DC.W	$66,$68,$6A,$6C
	DC.W	$6E,$70,$71,$72
	DC.W	$74,$74,$75,$76
	DC.W	$76,$76,$76,$76
	DC.W	$76,$75,$75,$74
	DC.W	$73,$72,$71,$6F
	DC.W	$6E,$6C,$6A,$68
	DC.W	$66,$64,$62,$60
	DC.W	$5E,$5B,$59,$56
	DC.W	$53,$51,$4E,$4B
	DC.W	$48,$45,$43,$40
	DC.W	$3D,$3A,$37,$34
	DC.W	$31,$2F,$2C,$29
	DC.W	$27,$24,$21,$1F
	DC.W	$1C,$1A,$18,$15
	DC.W	$13,$11,$F,$D
	DC.W	$B,$A,8,6
	DC.W	5,4,2,1
	DC.W	0,$FFFF,$FFFE,$FFFE
	DC.W	$FFFD,$FFFC,$FFFC,$FFFC
	DC.W	$FFFC,$FFFB,$FFFB,$FFFB
	DC.W	$FFFC,$FFFC,$FFFC,$FFFD
	DC.W	$FFFD,$FFFE,$FFFE,$FFFF
	DC.W	0,1,2,3
	DC.W	4,5,6,8
	DC.W	9,$A,$B,$D
	DC.W	$E,$10,$11,$13
	DC.W	$14,$15,$17,$18
	DC.W	$1A,$1B,$1D,$1E
	DC.W	$20,$21,$22,$24
	DC.W	$25,$26,$28,$29
	DC.W	$2A,$2B,$2D,$2E
	DC.W	$2F,$30,$31,$31
	DC.W	$32,$33,$34,$35
	DC.W	$35,$36,$36,$37
	DC.W	$37,$38,$38,$38
	DC.W	$38,$39,$39,$39
	DC.W	$39,$39,$39,$39
	DC.W	$38,$38,$38,$38
	DC.W	$37,$37,$37,$36
	DC.W	$36,$36,$35,$35
	DC.W	$34,$34,$33,$32
	DC.W	$32,$31,$31,$30
	DC.W	$30,$2F,$2E,$2E
	DC.W	$2D,$2D,$2C,$2C
	DC.W	$2B,$2B,$2A,$2A
	DC.W	$29,$29,$28,$28
	DC.W	$27,$27,$27,$26
	DC.W	$26,$26,$25,$25
	DC.W	$25,$25,$24,$24
	DC.W	$24,$24,$24,$24
	DC.W	$24,$24,$24,$24
	DC.W	$24,$24,$24,$24
	DC.W	$24,$24,$24,$25
	DC.W	$25,$25,$25,$25
	DC.W	$25,$26,$26,$26
	DC.W	$26,$26,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27,$27,$27
	DC.W	$27,$27
finondes:
;
IMAGELOGO:
	dc.l	LOGO+0,$AD400000

IMAGERAYON:
	dc.l	RAYON+0,$10400000+1*256
	dc.l	RAYON+$200,$10400000
	dc.l	RAYON+$400,$260B0000
	dc.l	RAYON+$508,$2C0C0000
	dc.l	RAYON+$628,$300C0000
	dc.l	RAYON+$748,$2F0A0000

IMAGESORCIER:
	dc.l	SORCIER+0,$1C3F0000+4*256
	dc.l	SORCIER+$3F0,$1D3F0000+3*256
	dc.l	SORCIER+$7E0,$20490000+0*256
	dc.l	SORCIER+$C70,$1D3F0000+3*256
	dc.l	SORCIER+$1060,$1C3F0000+4*256
	dc.l	SORCIER+$1450,$1B400000+5*256
	dc.l	SORCIER+$1850,$1C3F0000+4*256
IMAGETRANS:
	dc.l	TRANS+0,$315B0000
	dc.l	TRANS+$B60,$2F5A0000
	dc.l	TRANS+$13D0,$305A0000
	dc.l	TRANS+$1C40,$31510000
	dc.l	TRANS+$2660,$30520000
	dc.l	TRANS+$2E10,$304F0000
	dc.l	TRANS+$3578,$30430000
	dc.l	TRANS+$3BC0,$38460000
	dc.l	TRANS+$4480,$303C0000
	dc.l	TRANS+$4A20,$2F3F0000
	dc.l	TRANS+$5008,$30370000
	dc.l	TRANS+$5530,$33370000
	dc.l	TRANS+$5C10,$2B310000
	dc.l	TRANS+$60A8,$2C310000
	dc.l	TRANS+$6540,$2B300000
	dc.l	TRANS+$69C0,$2A300000

IMAGEFEMME:
	dc.l	FEMME+0,$3F660000+1*256
	dc.l	FEMME+$CC0,$40620000
IMAGECOURSE:
	dc.l	COURSE+0,$244F0000+7*256
	dc.l	COURSE+$768,$24500000+4*256
	dc.l	COURSE+$EE8,$304A0000+2*256
	dc.l	COURSE+$15D8,$204F0000+8*256
	dc.l	COURSE+$1AC8,$26500000+5*256
	dc.l	COURSE+$2248,$304B0000+0*256
IMAGEFOND:
	dc.l	FOND+0,$E0B00000

TRANS:	INCBIN	TRANS.DAT
LOGO:	INCBIN	LOGO.DAT
RAYON:	INCBIN	RAYON.DAT
SORCIER:INCBIN	SORCIER.DAT

COURSE:	INCBIN	HOMME.DAT
FEMME:	INCBIN	FEMME.DAT
FOND:	INCBIN	FOND.DAT

	IFNE	FINAL
	IFEQ	DEBUG
debugger:incbin	E:\INCLUDES\debugger.bin
	ENDC
	IFEQ	DOWNLOAD
UPLOAD:	INCBIN	E:\INCLUDES\REMOTE.BIN
	ENDC
	ENDC

	list

FASTFEMME:EQU	ramtop-147520			;calcul‚ … l'octet prŠs
FINBUFFERFEMME:EQU	FASTFEMME+125712	;calcul‚ … l'octet prŠs
FASTRAYON:EQU	FASTFEMME
FASTLOGO:EQU	FASTFEMME
FINCODE:
	nolist
