	OPT	X+
;
; mettre recherche plus grande surface vide
;
; insolubles :
;
;	RND	nb cases non r‚solues
;	2	1
;	8	6
;	19	2
;	21	4
;	22	plus de 30
;	25	4
;	32	13
;	40	4
;	41	10
;	46	16
;	51	8
;	57	12
;	61	9
;	66	4
;	73	2
;
; trŠs durs : 30,37,56,71
;
RND=74
CPU=1			;0=TPS CPU
largeur=320
hauteur=200
TAILLEX=35
TAILLEY=21
NBBOMBES=100
TAILLEBLOC=9		;carr‚s 9*9
BORDER=12		;valeur case de bord

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
	bls.s	.ok
	illegal
.ok

	moveq	#13,d0
	lea	IMAGECASES,a5
	lea	decale_cases,a4
	bsr	predecale
	cmp.l	#fin_decale_cases,a6
	bls.s	.ok2
	illegal
.ok2

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


	bsr	hide_mouse
	bsr	initprg

	bsr	findmax		;joue la case qui prend le plus de 0
	bsr	show_mouse
	bra	mainprg
fin:
	bsr	uninit

	move	#$300,sr
;	illegal

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

PALETTE:
	DC.W	0,$112,$223,$334
	DC.W	$445,$556,$667,$600
	dc.w	$200
	DCB.W	6,$700
	DC.W	$555
;	DC.W	$50,$70,3,5
;	DC.W	7,$330,$550,$770

;	dc.w	0
;	dc.w	$700,$070,$007
;	dcb.w	15,$555

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
	move.b	$fffffc02.w,cxmouse

	move.l	#absolute_mouse_4,$118.w
	rte

absolute_mouse_4:
	btst	#0,$fffffc00.w
	beq	errclav
	move.b	$fffffc02.w,cxmouse+1

	move.l	#absolute_mouse_5,$118.w
	rte

absolute_mouse_5:
	btst	#0,$fffffc00.w
	beq	errclav
	move.b	$fffffc02.w,cymouse

	move.l	#absolute_mouse_6,$118.w
	rte

absolute_mouse_6:
	btst	#0,$fffffc00.w
	beq	errclav
	move.b	$fffffc02.w,cymouse+1

	move	cxmouse,xmouse
	move	cymouse,ymouse
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
cxmouse	dc.w	160
cymouse	dc.w	100
xmouse:	dc.w	160
ymouse:	dc.w	100
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
;	dc.l	IMAGE_SPRITE2,$0E0E0000

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


IMAGE_SPRITE2:
	dcb.w	4,%1000000000000100
	dcb.w	4,%0100000000001000
	dcb.w	4,%0010001100010000
	dcb.w	4,%0001010010100000
	dcb.w	4,%0000100001000000
	dcb.w	4,%0001010010100000
	dcb.w	4,%0010001100010000
	dcb.w	4,%0010001100010000
	dcb.w	4,%0001010010100000
	dcb.w	4,%0000100001000000
	dcb.w	4,%0001010010100000
	dcb.w	4,%0010001100010000
	dcb.w	4,%0100000000001000
	dcb.w	4,%1000000000000100


BASE:	INCBIN	MUSICLOG.BIN
MUSIC:	INCBIN	MUS2.LOG

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
	movem	xmouse,d1/d2
	tst.b	display_mouse
	bne.s	.new

	cmp	lastxmouse,d1
	bne.s	.new
	cmp	lastymouse,d2
	bne.s	.new
	rts
.new
	movem	d1/d2,lastxmouse

	clr.b	display_mouse
	moveq	#0,d0
	lea	decale1,a2

	moveq	#0,d3
	moveq	#0,d4
	move.b	sprite1+4,d3
	move.b	sprite1+5,d4

	subq	#7,d1
	subq	#7,d2

	lea	push_sprite1,a6
	bra	display_fast
hide_mouse:
	st	display_mouse
	lea	push_sprite1,a6
	bra	efface_fond

lastxmouse:dc.w	-1
lastymouse:dc.w	-1

display_mouse:
	dc.b	0
	even


; Pack de routines graphiques 4 plans:
;	-Boite,
;	-Ligne (Horizontale, verticale, quelconque),
;	-Caracteres affich‚s au pixel pres.
	
SetClip:
	move	d0,minx
	move	d1,miny
	move	d2,maxx
	move	d3,maxy
	rts

VLine:
	move	d3,d4
	move	d2,d3
	move	d0,d2
	bra.s	Box
HLine:
	move	d3,d4
	move	d1,d3
; Routine d'affichage d'une boite 4 plans
; D0: X
; D1: Y
; D2: XX
; D3: YY
; D4: Couleur
Box:
	movem.l	d0-a6,-(a7)
	move.l	ecran,a6
	move	d0,d7
	
	; Clipping
	cmp	minx(pc),d7
	bge.s	.1x
	move	minx(pc),d7
.1x:
	cmp	miny(pc),d1
	bge.s	.1
	move	miny(pc),d1
.1
	cmp	maxx(pc),d2
	blt.s	.2x
	move	maxx(pc),d2
.2x:
	cmp	maxy(pc),d3
	blt.s	.2
	move	maxy(pc),d3
.2
	cmp	d2,d7
	bgt	.retbox
	cmp	d3,d1
	bgt	.retbox

	sub	d1,d3	; --> Nbr de lignes
	muls	#160,d1
	adda.l	d1,a6

	; Couleur
	move.l	#$8b5e8b5e,d5
	move.l	#$8b5e8b5e,d6
	
	lsr	#1,d4
	subx.l	d0,d0
	bcs.s	.pl0
	eor.l	#$cf5e0000^$8b5e0000,d5
.pl0:
	lsr	#1,d4
	subx	d0,d0
	bcs.s	.pl1
	eor	#$cf5e^$8b5e,d5
.pl1:

	lsr	#1,d4
	subx.l	d1,d1
	bcs.s	.pl2
	eor.l	#$cf5e0000^$8b5e0000,d6
.pl2:
	lsr	#1,d4
	subx	d1,d1
	bcs.s	.pl3
	eor	#$cf5e^$8b5e,d6
.pl3:
	movem.l	d5/d6,.automodif1
	movem.l	d5/d6,.automodif2
	movem.l	d5/d6,.automodif3
	
	move	d3,d6
	
	moveq	#-16,d3
	and	d7,d3
	moveq	#-16,d4
	and	d2,d4

	asr	#1,d3
	asr	#1,d4

	move	d3,d5
	adda	d3,a6
	move.l	a6,a5
	sub	d4,d3
	bge	.littleline
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
	bset	d7,d5
	move	d5,d7
	not	d7

	moveq	#0,d4
	not	d2
	and	#$f,d2
	bset	d2,d4
	subq	#1,d4
	move	d4,d2
	not	d2
	
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

	exg	d2,d5
	exg	d4,d7
.automodif3:
	move	d7,(a6)+
	move	d7,(a6)+
	move	d7,(a6)+
	move	d7,(a6)+

	exg	d2,d5
	exg	d4,d7
	lea	160(a5),a5
	move.l	a5,a6
		
	dbra	d6,.automodif2
	
.retbox:
	movem.l	(a7)+,d0-a6
	rts

.littleline:
	moveq	#0,d5
	not	d7
	and	#$f,d7
	bset	d7,d5
	subq	#1,d5
	bset	d7,d5
	
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

	lea	160-8(a6),a6	;
	dbra	d6,.automodif1
	
	movem.l	(a7)+,d0-a6
	rts
	
;
; Affichage d'un caractere:	(Clipping a install‚)
;
;	A0: Adresse du jeu de caractere,
;	D0: X,
;	D1: Y,
;	D2: No de caractere,
;	D3: Couleur.
;

AffCar:
	movem.l	d0-a6,-(a7)
	
	addq	#7,d0
	move	(a0)+,d4
	muls	d4,d2	; Taille d'un caractere
	subq	#1,d4
	adda.l	d2,a0
	move.l	ecran,a6	; Adresse ‚cran
	move	d0,d2
	andi	#$fff0,d2
	asr	#1,d2
	adda	d2,a6
	muls	#160,d1
	adda.l	d1,a6
	
	move.l	#$8b5e8b5e,d5
	move.l	#$8b5e8b5e,d6
	
	lsr	#1,d3
	subx.l	d7,d7
	bcs.s	.pl0
	eor.l	#$cf5e0000^$8b5e0000,d5
.pl0:
	lsr	#1,d3
	subx	d7,d7
	bcs.s	.pl1
	eor	#$cf5e^$8b5e,d5
.pl1:

	lsr	#1,d3
	subx.l	d7,d7
	bcs.s	.pl2
	eor.l	#$cf5e0000^$8b5e0000,d6
.pl2:
	lsr	#1,d3
	subx	d7,d7
	bcs.s	.pl3
	eor	#$cf5e^$8b5e,d6
.pl3:
	movem.l	d5/d6,.automodif1
	movem.l	d5/d6,.automodif2
	movem.l	d5/d6,.automodif3
	
	andi	#$f,d0
	cmpi	#8,d0
	bge.s	.fastcar
	
	not	d0
	andi	#$f,d0
	subq	#8,a6
	
.loop1:
	moveq	#0,d7
	move.b	(a0)+,d7
	lsl.l	d0,d7
	move.l	d7,d5
	not.l	d7
	swap	d7
	swap	d5
.automodif1:
	or	d7,(a6)+
	or	d7,(a6)+
	or	d7,(a6)+
	or	d7,(a6)+
	swap	d5
	swap	d7
.automodif2:
	or	d7,(a6)+
	or	d7,(a6)+
	or	d7,(a6)+
	or	d7,(a6)+
	lea	160-16(a6),a6
	dbra	d4,.loop1
	
	movem.l	(a7)+,d0-a6
	rts

.fastcar:
	not	d0
	andi	#$f,d0
	
.loop2:
	clr	d7
	move.b	(a0)+,d7
	lsl	d0,d7
	move	d7,d5
	not	d7
.automodif3:
	or	d7,(a6)+
	or	d7,(a6)+
	or	d7,(a6)+
	or	d7,(a6)+
	lea	160-8(a6),a6
	dbra	d4,.loop2
	
	movem.l	(a7)+,d0-a6
	rts

	; Fenetre de clipping
minx	dc.w	0
miny	dc.w	0
maxx	dc.w	319
maxy	dc.w	199

initprg:
	ifeq	1
	moveq	#100,d1
	moveq	#7,d6
.nexty
	moveq	#7,d7
	moveq	#100,d0
.nextx
	movem	d0/d1,-(sp)

	move	d0,d2
	move	d1,d3
	addq	#8,d2
	addq	#8,d3
	moveq	#2,d4
	bsr	Box
	movem	(sp)+,d0/d1

	addq	#8,d0
	dbra	d7,.nextx
	addq	#8,d1
	dbra	d6,.nexty
	endc


	bsr	init_damier
	bsr	tire_damier

	lea	etat_damier,a0

	bsr	init_table

	move	xblock,d0
	mulu	#TAILLEBLOC,d0
	neg	d0
	add	#320,d0
	addq	#1,d0
	lsr	#1,d0
	move	d0,xwindow

	move	yblock,d0
	mulu	#TAILLEBLOC,d0
	neg	d0
	add	#192,d0
	addq	#1,d0
	lsr	#1,d0
	addq	#8,d0
	move	d0,ywindow


	move	xwindow,d0
	move	ywindow,d1

	move	ywindow,d2
	move	yblock,d6
	subq	#1,d6
.nexty
	move	xblock,d7
	subq	#1,d7
	move	xwindow,d1
.nextx
	movem	d1/d2/d6/d7,-(sp)

	moveq	#0,d0
	bsr	affiche_case

	movem	(sp)+,d1/d2/d6/d7

	add	#TAILLEBLOC,d1
	dbra	d7,.nextx
	add	#TAILLEBLOC,d2
	dbra	d6,.nexty
	rts

init_table:
	move.l	a0,a1
	moveq	#BORDER,d2
	moveq	#-1,d3
	move	xblock,d4

	move	d4,d0
.fil1	move.b	d2,(a0)+
	dbra	d0,.fil1

	move	yblock,d1
	subq	#1,d1
.fil2
	move.b	d2,(a0)+

	move	d4,d0
	subq	#1,d0
.fil3	move.b	d3,(a0)+
	dbra	d0,.fil3

	dbra	d1,.fil2

	addq	#1,d4
.fil4	move.b	d2,(a0)+
	dbra	d4,.fil4


	move.l	a0,d0
	sub.l	a1,d0

	cmp	taillemax,d0
	beq.s	.ok

	moveq	#-1,d0
.flash	move	d0,$ffff8240.w
	dbra	d0,.flash
.ok
	rts

xwindow:ds.w	1
ywindow:ds.w	1
xblock:	ds.w	1	;nb cases en X
yblock:	ds.w	1	;nb cases en Y

affiche_case
;
; d0=num‚ro de la case … afficher
; d1=X
; d2=Y
;
	lea	decale_cases,a2

	moveq	#TAILLEBLOC,d3
	moveq	#TAILLEBLOC,d4

	bra	aff_fast

	section	data
;$D($3A8)
IMAGECASES:
	DC.L	CASES+$0,$9090000
	DC.L	CASES+$48,$9090000
	DC.L	CASES+$90,$9090000
	DC.L	CASES+$D8,$9090000
	DC.L	CASES+$120,$9090000
	DC.L	CASES+$168,$9090000
	DC.L	CASES+$1B0,$9090000
	DC.L	CASES+$1F8,$9090000
	DC.L	CASES+$240,$9090000
	DC.L	CASES+$288,$9090000
	DC.L	CASES+$2D0,$9090000
	DC.L	CASES+$318,$9090000
	DC.L	CASES+$360,$9090000

CASES:	INCBIN	CASES.DAT

	section	bss
	even
decale_cases:	ds.b	$86e0
fin_decale_cases:

	section	text
mainprg:

	clr	sync
.wsync
	tst	sync
	beq.s	.wsync

	bsr	hide_mouse

	bsr	remet_case

	move.b	mousek,d0
	cmp.b	lastmousek,d0
	beq.s	.nochg
	tst.b	d0
	bne.s	.nochg2
;
; on a tout relach‚ -> clic
;
	movem	xmouse,d0/d1
	sub	xwindow,d0
	sub	ywindow,d1
	ext.l	d0
	ext.l	d1
	divu	#TAILLEBLOC,d0
	divu	#TAILLEBLOC,d1
	cmp	xblock,d0
	bhs.s	.relache
	cmp	yblock,d1
	bhs.s	.relache

	btst	#0,lastmousek
	bne.s	.droit

	bsr	valide

	bsr	reflechit

	bra.s	.relache
.droit
	bsr	bloque

.relache
	clr.b	lastmousek
	bra.s	.none
.nochg2
	move.b	d0,lastmousek
.nochg
	and.b	#3,d0
	beq.s	.none

	movem	xmouse,d0/d1
	sub	xwindow,d0
	sub	ywindow,d1
	ext.l	d0
	ext.l	d1
	divu	#TAILLEBLOC,d0
	divu	#TAILLEBLOC,d1
	cmp	xblock,d0
	bhs.s	.nocase
	cmp	yblock,d1
	bhs.s	.nocase
	bsr	new_case
.nocase

.none

	bsr	show_mouse
	bra	mainprg

	movem	xmouse,d0/d1
	or	d1,d0
	bne.s	.nobox

	moveq	#0,d0
	moveq	#0,d1
	moveq	#50,d2
	moveq	#50,d3
	moveq	#1,d4
	bsr	Box

	bra	mainprg
.nobox
	moveq	#0,d0
	moveq	#0,d1
	moveq	#50,d2
	moveq	#50,d3
	moveq	#0,d4
	bsr	Box

	bra	mainprg

	movem	xmouse,d0/d1

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
; d0/d1 num‚ro du block acc‚d‚
;
new_case:
	movem	d0/d1,lastcase

	move	xblock,d2
	addq	#1,d2
	mulu	d1,d2
	add	d0,d2
	add	xblock,d2
	addq	#2,d2
	lea	etat_damier,a0
	add	d2,a0

	mulu	#TAILLEBLOC,d0
	mulu	#TAILLEBLOC,d1
	add	xwindow,d0
	add	ywindow,d1

	move	d1,d2
	move	d0,d1
	moveq	#1,d0
	clr	d0
	move.b	(a0),d0
	bpl.s	.ok
	clr	d0
.ok
	addq.b	#1,d0	
	bra	affiche_case

lastcase:dc.l	-1
remet_case:

	movem	lastcase,d0/d1
	tst	d0
	bmi.s	.rien

	move.l	#-1,lastcase

	move	xblock,d2
	addq	#1,d2
	mulu	d1,d2
	add	d0,d2
	add	xblock,d2
	addq	#2,d2
	lea	etat_damier,a0
	add	d2,a0

	mulu	#TAILLEBLOC,d0
	mulu	#TAILLEBLOC,d1
	add	xwindow,d0
	add	ywindow,d1

	move	d1,d2
	move	d0,d1

	clr	d0
	move.b	(a0),d0
	addq.b	#1,d0
	bra	affiche_case
.rien
	rts

init_damier:
	move	#TAILLEX,xblock
	move	#TAILLEY,yblock

	move	xblock,d0
	addq	#1,d0
	move	yblock,d1
	addq	#2,d1
	mulu	d1,d0
	addq	#1,d0
	move	d0,taillemax

	lea	damier,a0
	bsr	init_table

	rts

taillemax:ds.w	1
lastmousek:dc.b	0
	even

	section	bss
	even
seed:	ds.l	1
etat_damier:
	ds.b	1000
fin_etat_damier
damier:
	ds.b	1000

	section	text

srand	MOVEQ	#0,D1
	MOVE	D0,D1
	MOVE.L	D1,seed
	RTS
rand	MOVE.L	seed,D0
	MOVE.L	D0,D1
	LSL.L	#2,D0
	ADD.L	D1,D0
	LSL.L	#2,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	ADD.L	D1,D0
	LSL.L	#2,D0
	ADD.L	D1,D0
	LSL.L	#3,D0
	ADD.L	D1,D0
	LSL.L	#2,D0
	ADD.L	D1,D0
	LSL.L	#3,D0
	SUB.L	D1,D0
	LSL.L	#4,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	ADD.L	D1,D0
	LSL.L	#2,D0
	ADD.L	D1,D0
	LSL.L	#2,D0
	ADD.L	D1,D0
	ADDQ.L	#1,D0
	MOVE.L	D0,seed
	SWAP	D0
	AND	#$7FFF,D0
	RTS

tire_damier:		;rnd damier
	moveq	#RND,d0
	bsr	srand

	move	#NBBOMBES,nb_bombes

	move	nb_bombes,d7
	subq	#1,d7
.tire
	bsr	rand
	ext.l	d0
	divu	taillemax,d0
	swap	d0
	lea	damier,a0
	tst.b	(a0,d0.w)
	bpl.s	.tire

	move.b	#9,(a0,d0.w)
	dbra	d7,.tire

;
; comptage des cases
;
	lea	damier,a0
	move	taillemax,d7
	subq	#1,d7

	move	xblock,d0
	move	d0,d1
	neg	d0

.count
	tst.b	(a0)
	bpl.s	.deja

	moveq	#0,d6

	cmp.b	#9,-2(a0,d0.w)
	bne.s	.n1
	addq	#1,d6
.n1
	cmp.b	#9,-1(a0,d0.w)
	bne.s	.n2
	addq	#1,d6
.n2
	cmp.b	#9,(a0,d0.w)
	bne.s	.n3
	addq	#1,d6
.n3

	cmp.b	#9,-1(a0)
	bne.s	.n4
	addq	#1,d6
.n4
	cmp.b	#9,1(a0)
	bne.s	.n5
	addq	#1,d6
.n5

	cmp.b	#9,(a0,d1.w)
	bne.s	.n6
	addq	#1,d6
.n6
	cmp.b	#9,1(a0,d1.w)
	bne.s	.n7
	addq	#1,d6
.n7
	cmp.b	#9,2(a0,d1.w)
	bne.s	.n8
	addq	#1,d6
.n8
	move.b	d6,(a0)

.deja
	addq	#1,a0
	dbra	d7,.count
	rts

nb_bombes:ds.w	1

;
bloque:			;d0/d1=coordonn‚es case … cliquer
	move	xblock,d2
	addq	#1,d2
	mulu	d1,d2
	add	d0,d2
	add	xblock,d2
	addq	#2,d2

	lea	etat_damier,a1

	clr	d0
	move.b	(a1,d2.w),d0

	cmp.b	#-1,d0
	bne.s	.notv
	moveq	#10,d0
	bra.s	.ok
.notv:
	cmp.b	#10,d0
	bne.s	.notc
	moveq	#11,d0
	bra.s	.ok
.notc
	cmp.b	#11,d0
	bne.s	.notd
	moveq	#-1,d0
.notd
.ok
	move.b	d0,(a1,d2.w)

	move	d2,d0
	bsr	display_it		;affiche case jou‚e

	rts

;
; offset contient l'offset de la case jou‚e
;
valide:			;d0/d1=coordonn‚es case … cliquer
	move	xblock,d2
	addq	#1,d2
	mulu	d1,d2
	add	d0,d2
	add	xblock,d2
	addq	#2,d2
	move	d2,d0
valide2:
	lea	damier,a0
	lea	etat_damier,a1

	tst.b	(a1,d0.w)
	bpl.s	.deja

	move.b	(a0,d0.w),(a1,d0.w)
	bsr	display_it		;affiche case jou‚e

	tst.b	(a1,d0.w)
	bne.s	.pasvide
	bsr	remplit
.pasvide
.deja
	rts
;
; d2=offset
;
push:	macro
	tst.b	(a1,d0.w)
	bpl.s	.b\@

	tst.b	(a0,d0.w)
	bne.s	.a\@
	move	d0,-(sp)
.a\@
	move.b	(a0,d0.w),(a1,d0.w)
	bsr	display_it	;affiche la case … jouer
.b\@
	endm

remplit:
	clr	-(sp)
	move	d0,-(sp)

	lea	damier,a0
	lea	etat_damier,a1
.loop
	move	(sp)+,d2
	beq	.fini

	move	d2,d0
	sub	xblock,d0
	subq	#2,d0
	push
	move	d2,d0
	sub	xblock,d0
	subq	#1,d0
	push
	move	d2,d0
	sub	xblock,d0
	push

	move	d2,d0
	subq	#1,d0
	push
	move	d2,d0
	addq	#1,d0
	push

	move	d2,d0
	add	xblock,d0
	push
	move	d2,d0
	add	xblock,d0
	addq	#1,d0
	push
	move	d2,d0
	add	xblock,d0
	addq	#2,d0
	push

	bra	.loop

.fini
	rts

display_it:
;
; d0=offset case … afficher
;
	movem.l	d0-d7/a0-a6,-(sp)

	move	xblock,d2
	addq	#1,d2
	move	d0,d1
	ext.l	d1
	sub	xblock,d1
	subq	#2,d1
	divu	d2,d1		;d1.w=coord Y
				;d1.h=coord X

	move	d1,d2
	swap	d1
	mulu	#TAILLEBLOC,d1
	mulu	#TAILLEBLOC,d2
	add	xwindow,d1
	add	ywindow,d2

	lea	etat_damier,a0
	add	d0,a0
	clr	d0
	move.b	(a0),d0
	addq.b	#1,d0
	bsr	affiche_case


	movem.l	(sp)+,d0-d7/a0-a6
.none
	rts
;
; algo de r‚solution du d‚mineur
;
; 1Šre passe...
;
scan:	macro
	move.b	(a0,d0.w),d0
	cmp.b	#-1,d0
	bne.s	.a\@
	addq	#1,d2		;nblibres
.a\@
	cmp.b	#9,d0
	bne.s	.b\@
	addq	#1,d1		;nbbombes
.b\@
	endm
;
; d‚but algo
;
algo1:
	clr.b	modifie
.loop
	clr.b	coupjoue
	moveq	#0,d7		;i
	lea	etat_damier,a0
	move	xblock,d6
.bcl1:
	cmp.b	#BORDER,(a0,d7.w)
	beq	.next
	cmp.b	#-1,(a0,d7.w)
	beq	.next

;	addq	#7,$ffff8240.w

	clr	d1		;nbbombes
	clr	d2		;nblibres

	move	d7,d0
	sub	d6,d0
	subq	#2,d0
	scan
	move	d7,d0
	sub	d6,d0
	subq	#1,d0
	scan
	move	d7,d0
	sub	d6,d0
	scan

	move	d7,d0
	subq	#1,d0
	scan
	move	d7,d0
	addq	#1,d0
	scan

	move	d7,d0
	add	d6,d0
	scan
	move	d7,d0
	add	d6,d0
	addq	#1,d0
	scan
	move	d7,d0
	add	d6,d0
	addq	#2,d0
	scan

	cmp.b	(a0,d7.w),d1
	bne.s	.notv
;
; toutes les cases autour sont vides !!!
;
	move	d7,d0
	sub	d6,d0
	subq	#2,d0
	bsr	jouec
	move	d7,d0
	sub	d6,d0
	subq	#1,d0
	bsr	jouec
	move	d7,d0
	sub	d6,d0
	bsr	jouec

	move	d7,d0
	subq	#1,d0
	bsr	jouec
	move	d7,d0
	addq	#1,d0
	bsr	jouec

	move	d7,d0
	add	d6,d0
	addq	#2,d0
	bsr	jouec
	move	d7,d0
	add	d6,d0
	addq	#1,d0
	bsr	jouec
	move	d7,d0
	add	d6,d0
	bsr	jouec
	bra.s	.next
.notv
	move	d2,d0
	add	d1,d0
	cmp.b	(a0,d7.w),d0
	bne.s	.next
;
; toutes les cases autour sont des bombes
;
	move	d7,d0
	sub	d6,d0
	subq	#2,d0
	bsr	placebombe
	move	d7,d0
	sub	d6,d0
	subq	#1,d0
	bsr	placebombe
	move	d7,d0
	sub	d6,d0
	bsr	placebombe

	move	d7,d0
	subq	#1,d0
	bsr	placebombe
	move	d7,d0
	addq	#1,d0
	bsr	placebombe

	move	d7,d0
	add	d6,d0
	addq	#2,d0
	bsr	placebombe
	move	d7,d0
	add	d6,d0
	addq	#1,d0
	bsr	placebombe
	move	d7,d0
	add	d6,d0
	bsr	placebombe

.next
	addq	#1,d7
	cmp	taillemax,d7
	blo	.bcl1

	tst.b	coupjoue
	bne	.loop

	rts

jouec:
	cmp.b	#-1,(a0,d0.w)
	bne.s	.nojoue

	st	coupjoue
	st	modifie
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	valide2
	movem.l	(sp)+,d0-d7/a0-a6
.nojoue
	rts
placebombe:
	cmp.b	#-1,(a0,d0.w)
	bne.s	.nobombe
	st	coupjoue
	move.b	#9,(a0,d0.w)
	bsr	display_it
.nobombe
	rts
coupjoue:ds.b	1
modifie:ds.b	1
	even

scan2:	macro
	move.b	(a0,d0.w),d0
	cmp.b	#9,d0
	bhs.s	.a\@
	addq	#1,d1
.a\@
	endm

FLASH:	MACRO
.\@	ADDQ	#7,$FFFF8240.W
	BRA.S	.\@
	ENDM

algo2:
	clr.b	modifie
;
; recherche exhaustive quand tout est bloqu‚...
;
	clr	nbcases
	moveq	#0,d7
	lea	etat_damier,a0
	lea	etat,a1
	lea	liste,a2
.for
	cmp.b	#-1,(a0,d7.w)
	bne	.next
;
; on dresse une liste des cases … d‚terminer
;
	moveq	#0,d1		;nb libres

	move	d7,d0
	sub	d6,d0
	subq	#2,d0
	scan2
	move	d7,d0
	sub	d6,d0
	subq	#1,d0
	scan2
	move	d7,d0
	sub	d6,d0
	scan2

	move	d7,d0
	subq	#1,d0
	scan2
	move	d7,d0
	addq	#1,d0
	scan2

	move	d7,d0
	add	d6,d0
	scan2
	move	d7,d0
	add	d6,d0
	addq	#1,d0
	scan2
	move	d7,d0
	add	d6,d0
	addq	#2,d0
	scan2

	tst	d1
	beq.s	.next
	cmp	#8,d1
	beq.s	.next

	clr.b	(a1)+
	move	d7,(a2)+
	addq	#1,nbcases
;	addq	#7,$ffff8240.w
.next
	addq	#1,d7
	cmp	taillemax,d7
	blo	.for

	tst	nbcases
	beq.s	.fini

	clr	nbsol

	moveq	#0,d7
	lea	etat_damier,a0
	lea	liste,a1
	bsr	devine

	tst	nbsol
	beq	bigbug

	moveq	#0,d7
.for2
	lea	etat,a0
	clr	d0
	move.b	(a0,d7.w),d0
	add	d0,d0
	jmp	.choice(pc,d0.w)
.choice:
	bra.s	.bug
	bra.s	.type1
	bra.s	.type2
	bra.s	.type3

.type1
	move	d7,d0
	add	d0,d0
	lea	liste,a0
	move	(a0,d0.w),d0
	lea	etat_damier,a0
	bsr	placebombe
	bra.s	.next2

.type2
	move	d7,d0
	add	d0,d0
	lea	liste,a0
	move	(a0,d0.w),d0
	lea	etat_damier,a0
	bsr	jouec
.type3
.next2
	addq	#1,d7
	cmp	nbcases,d7
	blo.s	.for2
.fini
	rts
.bug
	illegal
bigbug
	addq	#7,$ffff8240.w
	bra.s	bigbug
;
; sous-programme de recherche exhaustive
;
; entr‚e : d7=num‚ro de la case hypothŠse
;
devine:
	cmp	nbcases,d7
	bhs.s	.solution

	move	(a1),d6		;c

	cmp.b	#-1,(a0,d6.w)
	bne.s	.bug
;
; 1) on met une bombe
;
	move.b	#9,(a0,d6.w)

	bsr	test_legal
	bne.s	.illegal1

	addq	#1,d7
	addq	#2,a1
	bsr	devine
	subq	#1,d7
	move	-(a1),d6
.illegal1
	cmp.b	#9,(a0,d6.w)
	bne.s	.bug
;
; 2) on met une case vide
;
	move.b	#11,(a0,d6.w)

	bsr	test_legal
	bne.s	.illegal2

	addq	#1,d7
	addq	#2,a1
	bsr	devine
	subq	#1,d7
	move	-(a1),d6
.illegal2
	move.b	#-1,(a0,d6.w)
	rts
.bug
	illegal
.solution
	movem.l	d0-d7/a0-a6,-(sp)
	addq	#1,nbsol

	lea	etat,a2
	moveq	#0,d7
	lea	liste,a1
	lea	etat_damier,a0
.for
	move	(a1)+,d0
	move.b	(a0,d0.w),d0

	cmp.b	#9,d0
	bne.s	.not9

	or.b	#1,(a2)+
	bra.s	.next
.not9
	cmp.b	#11,d0
	bne.s	.bug
	or.b	#2,(a2)+
.next
	addq	#1,d7
	cmp	nbcases,d7
	blo.s	.for

	movem.l	(sp)+,d0-d7/a0-a6
	rts

test_legal:
	move	d6,d0
	bsr	test
	bne.s	.rts

	move	d6,d0
	sub	xblock,d0
	subq	#2,d0
	bsr	test
	bne.s	.rts
	move	d6,d0
	sub	xblock,d0
	subq	#1,d0
	bsr	test
	bne.s	.rts
	move	d6,d0
	sub	xblock,d0
	bsr	test
	bne.s	.rts

	move	d6,d0
	subq	#1,d0
	bsr	test
	bne.s	.rts
	move	d6,d0
	addq	#1,d0
	bsr	test
	bne.s	.rts

	move	d6,d0
	add	xblock,d0
	bsr	test
	bne.s	.rts
	move	d6,d0
	add	xblock,d0
	addq	#1,d0
	bsr	test
	bne.s	.rts
	move	d6,d0
	add	xblock,d0
	addq	#2,d0
	bsr	test
.rts	rts


compte:	macro
	move.b	(a0,d1.w),d1
	cmp.b	#9,d1
	bne.s	.a\@
	addq	#1,d2		;nb bombes
	bra.s	.b\@
.a\@
	cmp.b	#-1,d1
	beq.s	.b\@
	addq	#1,d3		;nb libres
.b\@
	endm

test:
	move.b	(a0,d0.w),d1
	ext	d1
	add	d1,d1
	jmp	.tbl(pc,d1.w)
.bug
	illegal
.zero:
;
; on ne peut tester la l‚galit‚...
;
	moveq	#0,d0
	rts

	bra.s	.zero		;-1
.tbl
	bra.s	.bug		;0
	bra.s	.count		;1
	bra.s	.count		;2
	bra.s	.count		;3
	bra.s	.count		;4
	bra.s	.count		;5
	bra.s	.count		;6
	bra.s	.count		;7
	bra.s	.count		;8
	bra.s	.test9		;9
	bra.s	.zero		;10
	bra.s	.zero		;11

	bra.s	.zero		;12

.test9
;
; autour d'une bombe il n'y a pas de case 0
;
	move	d0,d1
	sub	xblock,d1
	tst.b	-2(a0,d1.w)
	beq.s	.err
	tst.b	-1(a0,d1.w)
	beq.s	.err
	tst.b	0(a0,d1.w)
	beq.s	.err

	tst.b	-1(a0,d0.w)
	beq.s	.err
	tst.b	1(a0,d0.w)
	beq.s	.err

	move	d0,d1
	add	xblock,d1
	tst.b	0(a0,d1.w)
	beq.s	.err
	tst.b	1(a0,d1.w)
	beq.s	.err
	tst.b	2(a0,d1.w)
	beq.s	.err
	moveq	#0,d0
	rts
.err
	movem.l	d0-d7/a0-a7,pushregs


	FLASH
	illegal

	moveq	#1,d0
	rts
.count
;
; la l‚galit‚ est test‚e en comptant le nombre de bombes
; autour de la case
;
	clr	d2	;nb bombes
	clr	d3	;nb libres

	move	d0,d1
	sub	xblock,d1
	subq	#2,d1
	compte
	move	d0,d1
	sub	xblock,d1
	subq	#1,d1
	compte
	move	d0,d1
	sub	xblock,d1
	compte

	move	d0,d1
	subq	#1,d1
	compte
	move	d0,d1
	addq	#1,d1
	compte

	move	d0,d1
	add	xblock,d1
	compte
	move	d0,d1
	add	xblock,d1
	addq	#1,d1
	compte
	move	d0,d1
	add	xblock,d1
	addq	#2,d1
	compte

	cmp.b	(a0,d0.w),d2
	bhi.s	.err2
	move	d2,d1
	add	d3,d1
	cmp	#8,d1
	bne.s	.not8
	cmp.b	(a0,d0.w),d2
	bne.s	.err2
.not8	moveq	#0,d0
	rts
.err2	moveq	#1,d0
	rts

	section	bss
	even
nbsol:	ds.w	1
nbcases:ds.w	1
nbcases2:ds.w	1
etat:	ds.b	1000
liste:	ds.w	1000
pushregs:ds.l	16

	section	text


findmax:
	lea	maxvide,a0
	bsr	init_table

	moveq	#0,d4
	lea	damier,a0
	lea	maxvide,a1
	moveq	#0,d6		;record
	moveq	#-1,d5		;meilleure case
.loop
	tst.b	(a0,d4.w)
	bne.s	.not0
	tst.b	(a1,d4.w)
	beq.s	.deja

	move	d4,d0
	bsr	remplit_vide
	cmp	d6,d7
	bls.s	.parec
	move	d7,d6
	move	d4,d5
.parec
.not0
.deja
	addq	#1,d4
	cmp	taillemax,d4
	blo.s	.loop

	move	d5,d0
	bsr	valide2
	rts


push2:	macro
	tst.b	(a1,d0.w)
	bpl.s	.b\@

	tst.b	(a0,d0.w)
	bne.s	.a\@
	move	d0,-(sp)
	addq	#1,d7			;comptage cases vides
.a\@
	move.b	(a0,d0.w),(a1,d0.w)
.b\@
	endm

remplit_vide:
	moveq	#0,d7
	clr	-(sp)
	move	d0,-(sp)

;	lea	damier,a0
;	lea	maxvide,a1
	move.b	(a0,d0.w),(a1,d0.w)
.loop
	move	(sp)+,d2
	beq	.fini

	move	d2,d0
	sub	xblock,d0
	subq	#2,d0
	push2
	move	d2,d0
	sub	xblock,d0
	subq	#1,d0
	push2
	move	d2,d0
	sub	xblock,d0
	push2

	move	d2,d0
	subq	#1,d0
	push2
	move	d2,d0
	addq	#1,d0
	push2

	move	d2,d0
	add	xblock,d0
	push2
	move	d2,d0
	add	xblock,d0
	addq	#1,d0
	push2
	move	d2,d0
	add	xblock,d0
	addq	#2,d0
	push2

	bra	.loop

.fini
	rts

reflechit:
.recalc:
	bsr	algo1
	bsr	algo2

	tst.b	modifie
	bne.s	.recalc
	rts

	section	bss
maxvide:ds.b	1000
