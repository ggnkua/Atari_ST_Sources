
	opt	o+

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
	LEA	DBSS,A0
	lea	FBSS,a1
.loop1:
	move.b	#0,(a0)+
	cmp.l	a1,a0
	bne.s	.loop1

	move.l	$44e.w,oldecr

	move.l	#ecrans,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,log

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol

	movem.l	ecrans,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w

	vsync
	move.b	#0,$ffff8260.w
	vsync

	move.w	#$2700,sr
	bsr	init_mfp

	bsr	make_fond

	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#hbl,$68.w
	move.l	#vbl,$70.w

	move.w	#$2300,sr

	lea	texte1,a0
	bsr	affiche

	lea	texte2,a0
	bsr	affiche

	lea	texte3,a0
	bsr	affiche

	lea	texte4,a0
	bsr	affiche



	move.w	#$2700,sr
	bsr	fin_mfp
	move.w	#$2300,sr

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

	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	vsync


	clr.w	-(sp)
	trap	#1

hbl:	rte


vbl:
	rte

make_fond:
	move.l	log,a1
	lea	haut,a0
	move.w	#(43*40)-1,d0
.loop1:
	move.l	(a0)+,(a1)+
	dbf	d0,.loop1

	move.l	log,a1
	lea	(200-15)*160(a1),a1
	lea	bas,a0
	move.w	#(15*40)-1,d0
.loop2:
	move.l	(a0)+,(a1)+
	dbf	d0,.loop2
	rts

init_mfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	move.w	#16,d0
	
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

	bclr	#3,$fffffa17.w
	
	clr.b	$fffffa19.w 	    Arret Timer A (Reg control)
	clr.b	$fffffa1b.w 	    Arret Timer B (Reg control)

	move.b	#%00000000,$fffffa07.w
	move.b	#%00000000,$fffffa13.w
	
	move.b	#%00000000,$fffffa09.w
	move.b	#%00000000,$fffffa15.w

	rte
	
fin_mfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	move.w	#16,d0
	
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

	rte
	
affiche:
	move.l	a0,$300.w

	move.l	log,a1
	move.l	#51*160,d1

	lea	table,a2
	lea	font,a3

.loop:
	moveq	#0,d0
	move.b	(a0)+,d0
	blt	.sortie
	cmp.b	#$0d,d0
	bne.s	.pas_return

	
	divu	#160,d1
	add.w	#10,d1
	mulu	#160,d1
	
	addq.l	#1,a0
	bra	.next

.pas_return:
	sub.b	#32,d0
	blt	.next
	move.b	(a2,d0.w),d0
	lsl.w	#5,d0		* code fois 8
	lea	(a3,d0.w),a4	* a4 = source font

	lea	(a1,d1.w),a5	* a5 = dest sur ecran

st	set	0
	rept	8
	move.b	(a4)+,st(a5)
	move.b	(a4)+,st+2(a5)
	move.b	(a4)+,st+4(a5)
	move.b	(a4)+,st+6(a5)
st	set	st+160
	endr

	btst	#0,d1
	bne.s	.plus_7
.plus_1:
	addq.w	#1,d1
	bra.s	.ok1
.plus_7:
	addq.w	#7,d1

.ok1:
.next:
	bra	.loop

.sortie:

.main:	cmp.b	#$62,$fffffc02.w
	bne.s	.main

.vide:
	move.b	$fffffc02.w,d0
	cmp.b	#$62,d0
	beq.s	.vide

	move.l	log,a0
	lea	51*160(a0),a0
	moveq	#0,d1
	move.w	#(133*40)-1,d0
.loopc:
	move.l	d1,(a0)+
	dbf	d0,.loopc
	

	rts

	section	data

table:
	dc.b	51,28,33,51,51,51,51,32,34,35,51
	dc.b	40,31,30,26,36,50,41,42,43,44,45,46,47,48,49
	dc.b	27,51,38,51,37,29,51
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
	dc.b	51,51,51,39
	

texte1:
	incbin	"infotex1.s"
	dc.b	-1

texte2:
	incbin	"infotex2.s"
	dc.b	-1
texte3:
	incbin	"infotex3.s"
	dc.b	-1
texte4:
	incbin	"infotex4.s"
	dc.b	-1

log:	dc.l	$f8000+2

haut:
	incbin	"a:\info\haut"
	even

bas:	
	incbin	"a:\info\bas"
	even

font:	incbin	"a:\info\fnt"
	even

pal:

	DC.W	$000,$223,$334,$445
	DC.W	$6C7,$526,$405,$304
	DC.W	$310,$532,$640,$753
	DC.W	$112,$556,$667,$777


	section	bss

DBSS:
oldecr:	ds.l	1
savcol:	ds.w	16

oldmfp	ds.b	24
oldvec	ds.l	24

ecrans:	ds.b	256
	ds.b	32000
FBSS:
	end
