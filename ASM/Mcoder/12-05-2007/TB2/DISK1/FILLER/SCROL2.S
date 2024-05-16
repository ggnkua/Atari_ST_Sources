SCROLLER_SPEED=2

INIT:
	lea	mess1,a0
	move.l	A0,ptrmess
	move.l	A0,debutmess
convert:
	clr	d0
	move.b	(a0),d0
	bmi.s	.fini

	lea	.alphabet(pc),a1
.search	move.b	(a1)+,d1
	bmi.s	.space
	cmp.b	d1,d0
	bne.s	.search
	move.l	a1,d0
	sub.l	#.alphabet+1,d0
	move.b	d0,(a0)+
	bra.S	convert
.space	clr.b	(a0)+
	bra.S	convert
.alphabet
	dc.b	" ![]"
	dc.b	"'(),.:;?0123456789"
	dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ-"
	DC.B	-1
	EVEN
.fini
	clr	shift
	clr	cptbuf

	illegal
;
; SCROLLER 8*8 MINIMUM
;
scroller
	move	shift,d7
	lea	buffer,a0
	move	d7,d0
	mulu	#8*40*2/SCROLLER_SPEED,d0
	add	d0,a0
	add	cptbuf,a0

	move.l	ec1,a1
	lea	192*160+3*2(a1),a1
	moveq	#8-1,d0
afflig:
	rept	20
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	addq	#8-2,a1
	endr
	lea	40(a0),a0
	dbra	d0,afflig

	move.l	ptrmess,a6
	clr	d0
	move.b	(a6)+,d0
	asl	#3,d0
	lea	fonte,a4
	add	d0,a4		;a4=caractäre Ö gauche

	clr	d0
	lea	fonte,a5
	move.b	(a6),d0
	bpl.s	.ok
	move.l	debutmess,a6
	move.b	(a6),d0
.ok
	asl	#3,d0
	add	d0,a5		;a5=caractäre Ö droite

	move	shift,d7
	lea	buffer,a0
	move	d7,d0
	mulu	#8*40*2/SCROLLER_SPEED,d0
	add	d0,a0
	add	cptbuf,a0

x	set	0
y	set	0
	rept	8
	movep	x(a5),d0
	move.b	(a4)+,d0
	rol	d7,d0
	move.b	d0,y(a0)
	move.b	d0,y+40(a0)
x	set	x+1
y	set	y+80
	endr

	addq	#SCROLLER_SPEED,shift
	and	#7,shift
	bne.s	no16

	move.l	a6,ptrmess

	addq	#1,cptbuf
	cmp	#40,cptbuf
	blo.s	no16
	clr	cptbuf
no16:
	rts

mess1:
	DC.B	"              PLEASE WAIT A WHILE, I'M LOADING AND DEPACKING THE MAIN-MENU. "
	DC.B	"PRESS THE SPACE BAR WHEN [LOADED] APPEARS. "
	DC.B	"THIS LITTLE LOADER-SCREEN HAS BEEN "
	DC.B	"CODED AND DESIGNED BY XERCES (FROM [GENESIS]) "
	DC.B	"AND MCODER (FROM [THE LONELY CODER]), AND THE MUSIC IS "
	DC.B	"FROM MADMAX. "
	DC.B	"OTHER CREDITS : THE INTRODUCTION SCREEN WAS CODED BY TERENCE (FROM [THE PENDRAGONS]), "
	DC.B	"GRAPHICS BY THE SERGEANT (FROM [THE BUSHWACKERS]) AND BY KRAZY REX (FROM [ST CONNEXION]) "
	DC.B	"AND MUSIC BY THE BIG ALEC "
	DC.B	"(FROM [OFF-BEAT]). THE MAIN-MENU WAS MADE BY THE OVERLANDERS, READ ITS SCROLLER "
	DC.B	"FOR MORE INFORMATIONS... "
	DC.B	"ALL THE SCROLLERS IN THE LOADER WERE WRITTEN BY MCODER "
	DC.B	"AND INVOLVE ONLY ME (I'M REFERING TO THE FACT THAT I KNOW "
	DC.B	"ONLY A FEW GROUPS WHO PARTICIPATED IN THIS DISK...). "
	DC.B	-1
	even

fonte:	incbin	newfnt8.bin
	DC.B	0,0,0,%1111100,0,0,0,0


buffer:	ds.b	40*2*8*8/SCROLLER_SPEED

sync:	ds.w	1
shift:	ds.w	1
cptbuf:	ds.w	1
ptrmess:ds.l	1
debutmess:ds.l	1
