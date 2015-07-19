	OPT	X+
CPU=1			;0=TPS CPU
largeur=320
hauteur=200

Vsync_no_interrupt	MACRO
.\@:	move.b	$ffff8205.w,d0
	cmp.b	$ffff8201.w,d0
	bne.s	.\@
	move.b	$ffff8207.w,d0
	cmp.b	$ffff8203.w,d0
	bne.s	.\@
	tst.b	$ffff8209.w
	bne.s	.\@
	ENDM
main:
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	move.l	#bufecran+255,d0
	clr.b	d0
	move.l	d0,ecran

	lea	mul160,a0
	moveq	#0,d0
.mul	move	d0,(a0)+
	add	#160,d0
	cmp	#160*hauteur,d0
	blo.s	.mul

	moveq	#1,d0
	lea	sprite1,a5
	lea	decale1,a4
	bsr	predecale
	cmp.l	#findecale1,a6
	beq.s	.ok
	illegal
.ok


	bsr.s	init

	move.l	ecran,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move.l	ecran,a0
	move	#32000/4-1,d0
	moveq	#0,d1
.cls	move.l	d1,(a0)+
	dbra	d0,.cls

;	lea	$e00000,a0
;	move.l	ecran,a1
;	move	#32000/4-1,d0
;.copy	move.l	(a0)+,(a1)+
;	dbra	d0,.copy

	bra	mainprg
fin:
	bsr	uninit

	move	#$300,sr
	clr	-(sp)
	trap	#1

init:
	move.b	$ffff8260.w,oldrez

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal

	move	#$2700,sr

	movem.l	$8.w,d0-d7
	movem.l	d0-d7,oldbomb

	lea	$8.w,a0	; Redirection des bombes
	move.l	#fin,d0
	REPT	8
	move.l	d0,(a0)+
	ENDR

	Vsync_no_interrupt
	clr.b	$ffff8260.w

	bsr	initmfp
	bsr	init_mouse
	move	#$2300,sr
	bsr	error_clavier

	rts
uninit:
	move	#$2700,sr

	movem.l	oldbomb,d0-d7
	movem.l	d0-d7,$8.w

	move.l	#$08000000,$ffff8800.w
	move.l	#$09000000,$ffff8800.w
	move.l	#$0a000000,$ffff8800.w

	bsr	finmfp

	Vsync_no_interrupt
	move.b	oldrez,$ffff8260.w
	move.l	$44e.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	bsr	error_clavier
	move	#$2300,sr

	bsr	waitc
	move.b	#$8,$fffffc02.w

	rts

initmfp:
	move	sr,-(a7)
	move	#$2700,sr

	move.b	$ffff820a.w,oldfreq

	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	moveq	#16,d0
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

	bsr	finmfp

	move.b	#$40,$fffffa17.w

	move.b	#%00000000,$fffffa07.w
	move.b	#%00000000,$fffffa13.w

	move.b	#%01000000,$fffffa09.w
	move.b	#%01000000,$fffffa15.w

	move.l	#vbl,$70.w
	move.l	#clavier,$118.w

; LANCEMENT MUSIQUE
	JSR	BASE+$564
	MOVE.L	#MUSIC,BASE+$34
	JSR	BASE+$5E6

	move	(a7)+,sr
	rts

PALETTE:dc.w	0
	dc.w	$700,$070,$007
	dcb.w	15,$555

vbl:
	addq	#1,sync
	movem.l	d0-a6,-(sp)

	MOVEM.L	PALETTE,D0-D7
	movem.l	d0-d7,$ffff8240.w

	BSR	BASE+$79A

	tst.b	display_mouse
	bne.s	.nodisp
	bsr	show_mouse
.nodisp

	tst	prgvbl
	bne.s	.novbl1
	move	#$2300,sr
	addq	#1,prgvbl
	IFEQ	CPU
	move	#$555,$ffff8240.w
	ENDC
;
; PROGRAMME SUR INTERRUPTION
;
	move.b	#$0d,$fffffc02.w ; Ask for mouse position

	IFEQ	CPU
	clr	$ffff8240.w
	ENDC
	clr	prgvbl
	bra.s	.novbl
.novbl1
	addq	#1,prgvbl
.novbl:
	tst.b	clav+$39
	bne	fin

	movem.l	(sp)+,d0-a6
	rte

finmfp:
	move	sr,-(a7)
	move	#$2700,sr

	bsr	waitc
	move.b	#$22,(a0)
	bsr	waitc
	move.b	#$f0,(a0)
	bsr	waitc
	move.b	#$00,(a0)

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	moveq	#16,d0
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

	and.b	#$8f,$fffffa1d.w
	move.b	#192,$fffffa23.w
	or.b	#%1010000,$fffffa1d.w	;/64

	move	(a7)+,sr
	rts

clavier:
	btst	#0,$fffffc00.w
	beq.s	noclav

	move	d0,-(a7)

	clr	d0
	move.b	$fffffc02.w,d0
	cmp.b	#$f7,d0
	beq.s	absolute_mouse_1

	pea	(a0)
	bclr	#7,d0
	lea	clav(pc),a0
	seq	(a0,d0)
	move.l	(a7)+,a0

	move	(a7)+,d0
noclav
	rte

absolute_mouse_1:
	move.l	#absolute_mouse_2,$118.w
	move	(a7)+,d0
	rte

absolute_mouse_2:
	btst	#0,$fffffc00.w
	beq	errclav

	move	d0,-(a7)

	move.b	$fffffc02.w,d0
	btst	#0,d0
	beq.s	.er
	bset	#0,cmousek
.er:
	btst	#1,d0
	beq.s	.rr
	bclr	#0,cmousek
.rr:
	btst	#2,d0
	beq.s	.el
	bset	#1,cmousek
.el:
	btst	#3,d0
	beq.s	.rl
	bclr	#1,cmousek
.rl:

	move	(a7)+,d0

	move.l	#absolute_mouse_3,$118.w
	rte

absolute_mouse_3:
	btst	#0,$fffffc00.w
	beq	errclav
	move.b	$fffffc02.w,cmousex

	move.l	#absolute_mouse_4,$118.w
	rte

absolute_mouse_4:
	btst	#0,$fffffc00.w
	beq	errclav
	move.b	$fffffc02.w,cmousex+1

	move.l	#absolute_mouse_5,$118.w
	rte

absolute_mouse_5:
	btst	#0,$fffffc00.w
	beq	errclav
	move.b	$fffffc02.w,cmousey

	move.l	#absolute_mouse_6,$118.w
	rte

absolute_mouse_6:
	btst	#0,$fffffc00.w
	beq	errclav
	move.b	$fffffc02.w,cmousey+1

	move	cmousex,mousex
	move	cmousey,mousey
	move.b	cmousek,mousek

	move.l	#clavier,$118.w
	rte
errclav:
	addq	#7,$ffff8240.w
	bra.s	errclav


init_mouse:
	bsr.s	error_clavier
	lea	$fffffc02.w,a0

	bsr.s	waitc		; Set mouse limit
	move.b	#$09,(a0)
	bsr.s	waitc
	move.b	#320/256,(a0)
	bsr.s	waitc
	move.b	#320&255,(a0)

	bsr.s	waitc
	move.b	#200/256,(a0)
	bsr.s	waitc
	move.b	#200&255,(a0)

	bsr.s	waitc		; Set mouse position
	move.b	#$0e,(a0)
	bsr	waitc
	move.b	#0,(a0)
	bsr.s	waitc
	move.b	#0,(a0)
	bsr.s	waitc
	move.b	#160,(a0)
	bsr.s	waitc
	move.b	#0,(a0)
	bsr.s	waitc
	move.b	#100,(a0)
	rts

waitc:
	btst	#1,$fffffc00.w
	beq.s	waitc
	rts

error_clavier:
	moveq.l	#$a1,d0
	and.b	$fffffc00.w,d0
	beq.s	.noerror

	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:
	rts

	section	data
prgvbl:	dc.w	0
cmousex	dc.w	160
cmousey	dc.w	100
mousex:	dc.w	160
mousey:	dc.w	100
cmousek	dc.b	0
mousek	dc.b	0
	even

	section	bss

sync:	ds.w	1
clav	ds.b	128
oldvec	ds.l	24
oldmfp	ds.b	24

oldpal	ds.w	16

oldbomb	ds.l	8
oldrez	ds.b	1
oldfreq	ds.b	1
	even

ecran:	ds.l	1
mul160:	ds.w	200

bufecran:ds.b	32000+255

	SECTION	TEXT
mainprg:

	clr	sync
.wsync
	tst	sync
	beq.s	.wsync

	bra	mainprg

	movem	mousex,d0/d1

	cmp	#320,d0
	bhs.s	.noplot
	cmp	#200,d1
	bhs.s	.noplot

	move.l	ecran,a0
	moveq	#$f,d2
	eor	d2,d0
	and	d0,d2
	eor	d2,d0

	lsr	#1,d0
	add	d0,a0
	mulu	#160,d1
	add	d1,a0

	clr	d0
	bset	d2,d0

	moveq	#3,d1
	and.b	mousek,d1
	cmp.b	#3,d1
	bne.s	.no

;	btst	#1,mousek	;bit 0=bouton droit
;	beq.s	.no		;bit 1=bouton gauche
	addq	#2,a0
.no

	or	d0,(a0)
.noplot
	bra	mainprg


;
; routine efficace de pr‚d‚calage de sprites...
;
; entr‚e :
;	d0=nb sprites … pr‚d‚caler
;	a5=adresse ptr table … pr‚d‚caler
;	a4=m‚mo des pointeurs (taille X,taille Y,bitmap)
;	   suivis du bitmap des sprites
;
const	equr	d2
reste1	equr	d4
reste2	equr	d5
cptplan	equr	d7

predecale
	move	d0,-(sp)
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

	addq	#1,d6
	cmp	#16,d6
	blo	1$

	addq	#8,a5
	subq	#1,(sp)
	bne	decale
	addq	#2,sp
	rts

planes	DC.L	$00000000,$80008000,$C000C000,$E000E000
	DC.L	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	DC.L	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	DC.L	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE
nbplan:	ds.w	1
nblig:	ds.w	1
onemore:ds.w	1
;
;
; routine d'affichage de sprite
;
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
;	a2=adresse d‚but stockage des sprites
;	d0=num‚ro du sprite
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;	a6=adresse buffer stockage fond
;
display_fast:
	movem	d0/d1/d2/d3/d4,-(sp)
	bsr	efface_fond
	movem	(sp)+,d0/d1/d2/d3/d4

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
	lsr	#1,d2
	add	d2,a2		;+1/2 pour les masques
	move	mul160,d2
	bra.s	2$
.fin_fast2:
;	clr	(a6)
	rts
1$
	move	d2,d0
	add	d4,d0

	lea	mul160,a1
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
	move.l	ecran,a1
	add	d2,a1		;adresse ‚cran

	lsr	#1,d3
	SUBQ	#1,D4

	bsr	store_fond

	lea	newfast(pc),a6
	jmp	(a6,d3.w)

aff_fast:
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
	lsr	#1,d2
	add	d2,a2		;+1/2 pour les masques
	move	mul160,d2
	bra.s	2$
.fin_fast2:rts
1$
	move	d2,d0
	add	d4,d0

	lea	mul160,a1
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
	move.l	ecran,a1
	add	d2,a1		;adresse ‚cran

	lsr	#1,d3
	SUBQ	#1,D4

	jmp	newfast(pc,d3.w)

newfast
	dc.l	$4a780001
	bra.w	.spr16
	bra.w	.spr32
	bra.w	.spr48
	dcb.l	8,$4a780001
.spr16					;sprite 16 de large
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	DBRA	D4,.spr16
	rts
.spr32					;sprite 32 de large
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	DBRA	D4,.spr32
	rts
.spr48					;sprite 48 de large
	msk	d0,d1
	msk	d2,d3
	msk	d6,d7
	movem.l	d0-d3/D6/D7,-(a1)
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	DBRA	D4,.spr48
	rts

sprite1:
	dc.l	IMAGE_SPRITE1,$0F0F0000

IMAGE_SPRITE1:
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000000000000
	dcb.w	4,%1111110001111110
	dcb.w	4,%0000000000000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000
	dcb.w	4,%0000000100000000

BASE:	INCBIN	MUSICLOG.BIN
MUSIC:	INCBIN	MUS3.LOG

	section	bss
	even
decale1:
	ds.b	$1558
findecale1:

push_sprite1:
	ds.b	1000

	section	text
;
; effa‡age du fond
;
;	a6=adresse m‚mo
;
efface_fond:
	move.l	a6,a0
	move	(a0)+,d0	;largeur/2
	beq.s	.fini
	move	(a0)+,d1	;hauteur-1

	move.l	ecran(pc),a1
	add	(a0)+,a1	;offset ‚cran

	lea	.neff0(pc),a3
	sub	d0,a3
	add	d0,d0

.neff1:	jmp	(a3)

	rept	20
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
.neff0:
	sub	d0,a1
	lea	160(a1),a1
	dbra	d1,.neff1
	clr	(a6)
.fini
	rts
;
; empilement du fond d'un sprite
;
;	a0=adresse m‚mo
;
store_fond:
	move	d3,(a6)+	;largeur
	move	d4,(a6)+	;hauteur-1
	move	d2,(a6)+	;offset ‚cran
;
;	a1=adresse ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
	pea	(a1)

	move	d3,d0

	lea	.neff0(pc),a4
	sub	d0,a4
	add	d0,d0
	move	d4,d1

.neff1:	jmp	(a4)

	rept	20
	move.l	(a1)+,(a6)+
	move.l	(a1)+,(a6)+
	endr
.neff0:
	sub	d0,a1
	lea	160(a1),a1
	dbra	d1,.neff1
	move.l	(sp)+,a1

	rts
show_mouse:
	clr.b	display_mouse
	moveq	#0,d0
	lea	decale1,a2

	movem	mousex,d1/d2
	moveq	#15,d3
	moveq	#15,d4

	subq	#7,d1
	subq	#7,d2

	lea	push_sprite1,a6
	bra	display_fast
hide_mouse:
	st	display_mouse
	lea	push_sprite1,a6
	bra	efface_fond

display_mouse:
	dc.b	0
	even
