
*   Cet ecran a pour but de faire comprendre comment mesurer le temps
*   machine pris par une routine : 
*   en changeant de couleur au debut de votre routine vous visualisez
*   a l'ecran le debut de cette routine
*   en changeant une seconde fois de couleurs a la fin de votre routine
*   vous viualisez la fin de la routine , et donc ainsi vous pouvez
*   mesurer le temps pris par la routine par rapport au temps VBL
*   disponible qui represente lui les 313 lignes de l'ecran.




vsync:	macro
	move.l	$466.w,d0
.\@l1:
	cmp.l	$466.w,d0
	beq.s	.\@l1
	endm

	move.w	sr,d0
	btst	#13,d0
	bne.s	yeah

	clr.	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

yeah:
	move.l	$44e,oldecr

	move.l	#ecrans,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,log

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol

	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w

	vsync
	move.b	#0,$ffff8260.w
	vsync

	movem.l	image+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	image+34,a0
	move.l	log,a1
	move.w	#7999,d0
looping:
	move.l	(a0)+,(a1)+
	dbf	d0,looping

	lea	zik,a0
	lea	$60000,a1
	lea	fzik,a2
.loop1:
	move.b	(a0)+,(a1)+
	cmp.l	a2,a0
	blt.s	.loop1

	jsr	$6f104

	move.l	$70.w,savvbl
	move.l	#vbl,$70.w

main:
	vsync
	cmp.b	#$39,$fffffc02.w
	bne.s	main

	move.l	savvbl,$70.w

	jsr	$6f108

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
	movem.l	savcol,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w

	clr.w	-(sp)
	trap	#1

	

vbl:
	move.w	#1780,d0
w:
	dbf	d0,w
	move.w	#$700,$ffff8240.w
	movem.l	d0-a6,-(sp)
	jsr	$6f100
	movem.l	(sp)+,d0-a6
	addq.l	#1,$466.w
	move.w	#$00,$ffff8240.w
	rte

	section	data

log:	dc.l	$f8000+2

image:
	incbin	"a:\sources\cpu.s\cpu.pi1"		* nom du fichier .pi1
	even

zik:
	incbin	"a:\sources\cpu.s\ninja.mus"
fzik:	even

	section	bss

oldecr:	ds.l	1

savvbl:	ds.l	1

savcol:	ds.w	16

ecrans:	ds.b	256
	ds.b	32000

	end

	


