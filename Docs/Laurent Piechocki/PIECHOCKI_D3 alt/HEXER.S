	
	*HEXER SPRITE DEMO, 12/88*
	
anz	equ	5

	pea	0
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ssp
	
	lea	stack,a7
	
	move.b	$ff8260,rezsave
	move.b	$ff820a,palsave
	movem.l	$ff8240,d0-d7
	movem.l  	d0-d7,palettesave
	
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldram
	
	bsr	vsync
	
	move.b	#0,$ff8260
	move.b	#2,$ff820a
	
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240
	
	move.l	#bildschirme+256,d0
	and.l	#$ffffff00,d0
	
	move.l	d0,vidram
	add.l	#32000,d0
	move.l	d0,logram
	bsr	setbild
	
	*effacer l'ecran *42
	
	moveq	#0,d1
	move.l	vidram,a0
	move	#15999,d0
	
clloop	move.l	d1,(a0)+
	dbra	d0,clloop
	
	*cylindres *49
	
gesamte_zeile	move.l	vidram,a0
	move.l	logram,a1
	add.l	#160*50,a0
	add.l	#160*50,a1
	moveq	#99,d7
	move.l	#$8787ffff,d0
	move.l	#$55556666,d1
bildinit_noch_eine_zeile	moveq	#19,d6
bildinit_gesamte_zeile	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a1)+
	move.l	d0,(a1)+
	dbra	d6,bildinit_gesamte_zeile
	swap	d0
	rol.w	#2,d0
	swap	d0		;d1 ??????
	rol.l	#2,d1
	dbra	d7,bildinit_noch_eine_zeile
	
******************************** 73

main:

	lea	sppuffer,a2
	lea	daten,a0
	lea	masken,a1
	move	#0,d7
	
spinitloop:

	movem.l	d7/a0-a2,-(sp)
	bsr	preshift
	movem.l	(sp)+,d7/a0-a2
	add.l	#6144,a2
	add.l	#128,a0
	add.l	#32,a1
	dbra	d7,spinitloop
	
	*99
	
	lea	savepuffer,a0
	move	#anz-1,d0
spcloop:
	clr.l	(a0)
	add.l	#262,a0
	clr.l	(a0)
	add.l	#262,a0
	dbra	d0,spcloop
	
	move	#anz-1,d4
	lea	x,a3
	lea	y,a4
	lea	xg,a5
	lea	yg,a6
kinitloop	move	#17,-(sp)
	trap	#14
	addq.l	#2,sp
	moveq	#0,d1
	move.w	d0,d1
	
	**** page 103
	*************
	
	divu	#336,d1
	swap	d1
	move.w	d1,(a3)+
	move.w	#17,-(sp)
	trap	#14
	addq.l	#2,sp
	moveq	#0,d1
	move.w	d0,d1
	divu	#216,d1
	swap	d1
	move.w	d1,(a4)+
	move	#17,-(sp)
	trap	#14
	addq.l	#2,sp
	move	d0,d1
	lsr	#1,d1
	and	#1,d0
	and	#1,d1
	tst	d0
	bne	xgi1
	move	#-1,d0
xgi1:
	tst	d1
	bne	ygi1
	move	#-1,d1
ygi1:
	move	d0,(a5)+
	move	d1,(a6)+
	dbra	d4,kinitloop
	
testloop:

	bsr	vsync
	lea	anz*262*2+savepuffer,a6
	move	#anz-1,d5
spundrawloop:
	sub.l	#524,a6
	move.l	a6,a0
	bsr	spriteundraw
	dbra	d5,spundrawloop
	
	*173
	
	lea	savepuffer,a3
	lea	x,a5
	lea	y,a6
	move	#anz-1,d7
stdrawloop:
	move	(a5)+,d0
	move	(a6)+,d1	*autre cote***********
	moveq	#0,d2
	move	d7,-(sp)
	
	move.l	a3,-(sp)
	bsr	sprite
	
	move.l	(sp)+,a3
	move	(sp)+,d7
	add.l	#524,a3
	dbra	d7,stdrawloop
	
	lea	x,a2
	lea	y,a3
	lea	xg,a4
	lea	yg,a5
	move	#anz-1,d7
kcalcloop:
	move	(a2),d0
	move	(a3),d1
	add	(a4),d0
	
	bpl	xok1
	neg.w	(a4)
	addq.w	#2,d0
xok1:
	add	(a5),d1
	bpl	yok1
	neg.w	(a5)
	addq.w	#2,d1
yok1:
	cmp	#336,d0
	bcs	xok2
	neg.w	(a4)
	subq	#2,d0
xok2:
	cmp	#216,d1
	bcs	yok2
	neg.w	(a5)
	subq	#2,d1
yok2:
	move	d0,(a2)+
	move	d1,(a3)+
	addq.l	#2,a4
	addq.l	#2,a5
	dbra	d7,kcalcloop
	
	bsr	bildchange
	not	saveindex
	
	move	#$b,-(sp)		*page	104***********
	trap	#1
	addq.l	#2,sp
	tst	d0
	beq	testloop
	
	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	
	bra	exit
	
	;*************************253
	
exit:
	bsr	vsync
	move.b	palsave,$ff820a
	move.b	rezsave,$ff8260
	movem.l	palettesave,d0-d7
	movem.l	d0-d7,$ff8240
	move.l	oldram,d0
	bsr	setbild
	
	move.l	ssp,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.W	-(sp)
	trap	#1
	
setbild:
	lsr.l	#8,d0
	move.b	d0,$ff8203
	lsr	#8,d0
	move.b	d0,$ff8201
	rts
	
bildchange:

	move.l	logram,d0
	move.l	vidram,logram
	move.l	d0,vidram
	bra	setbild
	
vsync:
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts
	
	************291
	
preshift:
	move	#15,d7
spinitloop0:
	moveq	#0,d0
	move.w	(a1),(a2)+
	move.w	(a1)+,(a2)+
	move.l	d0,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	dbra	d7,spinitloop0
	
	move	#14,d7
spinitloop1:
	lea	-384(a2),a3
	move	#15,d6
spinitloop2:
	move.w	(a3),d0
	swap	d0
	move.w	4(a3),d0
	lsr.l	#1,d0	*******a cote
	not.l	(a3)+
	not.l	(a3)+
	move.w	d0,4(a2)
	move.w	d0,6(a2)
	swap	d0
	move.w	d0,(a2)
	move.w	d0,2(a2)
	addq.l	#8,a2
	
	move.w	(a3),d0
	swap	d0
	move.w	8(a3),d0
	lsr.l	#1,d0
	move.w	d0,8(a2)
	swap	d0
	move.w	d0,(a2)
	addq.l	#2,a2	***335
	addq.l	#2,a3
	move.w	(a3),d0
	swap	d0
	move.w	8(a3),d0
	lsr.l	#1,d0
	move.w	d0,8(a2)
	swap	d0
	move.w	d0,(a2)
	addq.l	#2,a2
	addq.l	#2,a3
	move.w	(a3),d0
	swap	d0
	move.w	8(a3),d0
	lsr.l	#1,d0
	move.w	d0,8(a2)
	swap	d0
	move.w	d0,(a2)
	addq.l	#2,a2
	addq.l	#2,a3
	move.w	(a3),d0
	swap	d0	**356
	move.w	8(a3),d0
	lsr.l	#1,d0
	move.w	d0,8(a2)
	swap	d0
	move.w	d0,(a2)
	add.l	#10,a2
	add.l	#10,a3
	dbra	d6,spinitloop2
	dbra	d7,spinitloop1
	lea	-384(a2),a3
	move	#15,d0
	
nochinvertloop:
	not.l	(a3)
	not.l	4(a3)
	add.l	#24,a3
	dbra	d0,nochinvertloop
	rts
	
	*************** 376
	
sprite:
	tst	saveindex
	bpl	savep1
	add.l	#262,a3
savep1:
	addq	#1,d0
	move	d0,d4
	move	d1,d5
	lea	sppuffer,a0
	move	d0,d3
	and	#15,d3
	mulu	#384,d3
	mulu	#6144,d2
	add.l	d2,d3
	add.l	d3,a0
	
	*******page 105
	
	and	#$fff0,d0
	lsr	#1,d0
	mulu	#160,d1
	add	d0,d1
	sub	#2400+8,d1
	
	move.l	logram,a1
	add.w	d1,a1
	
	move	#15,d7
	
	move	d5,d6
	sub	#15,d6
	bpl	obenclipok
	add	d6,d7
	bmi	spabgang
	neg.w	d6
	move	d6,d0
	mulu	#24,d6
	
	add.l	d6,a0
	mulu	#160,d0
	add.l	d0,a1
	
obenclipok:
	move	#199,d6
	sub	d5,d6
	bpl	xclip
	add	d6,d7
	bmi	spabgang
	
xclip:
	cmp	#16,d4
	bcs	splinksclip
	cmp	#320,d4
	bcc	sprechtsclip
	
	move.l	#144,d6		*437
	
	move.l	a1,(a3)+
	move.w	d7,(a3)+
	
spritescanloop:
	move.l	(a1),(a3)+
	move.l	4(a1),(a3)+
	move.l	8(a1),(a3)+
	move.l	12(a1),(a3)+
	movem.l	(a0)+,d0-d5
	
	and.l	d0,(a1)
	
	and.l	d0,4(a1)
	and.l	d1,8(a1)
	and.l	d1,12(a1)
	
	or.l	d2,(a1)+
	or.l	d3,(a1)+
	
	or.l	d4,(a1)+
	or.l	d5,(a1)+
	
	add.l	d6,a1
	dbra	d7,spritescanloop
	rts
	
spabgang:
	clr.l	(a3)+
	clr.l	(a3)+
	rts
	
splinksclip:
	move.l	#152,d6
	addq.l	#8,a1
	
	move.l	a1,(a3)+
	move.w	d7,(a3)+
	bset	#7,-2(a3)
	
spritescanloop1:
	move.l	(a1),(a3)+
	move.l	4(a1),(a3)+
	movem.l	(a0)+,d0-d5
	and.l	d1,(a1)
	and.l	d1,4(a1)
	or.l	d4,(a1)+
	or.l	d5,(a1)+
	add.l	d6,a1
	dbra	d7,spritescanloop1
	rts
	
	*****cote suivant

sprechtsclip:
	cmp	#336,d4
	bcc	spabgang
	move.l	#152,d6
	
	move.l	a1,(a3)+
	move.w	d7,(a3)+
	bset	#7,-2(a3)
	
spritescanloopr:
	move.l	(a1),(a3)+
	move.l	4(a1),(a3)+
	movem.l	(a0)+,d0-d5
	and.l	d0,(a1)
	and.l	d0,4(a1)
	or.l	d2,(a1)+
	or.l	d3,(a1)+
	add.l	d6,a1
	dbra	d7,spritescanloopr
	rts
	
	***** 518
	
spriteundraw:
	tst	saveindex
	bpl	savep1und
	add.l	#262,a0
savep1und:
	tst.l	(a0)
	beq	noundraw
	move.l	(a0),a1
	clr.l	(a0)+
	move.w	(a0)+,d7
	bmi	halbundraw
	
	move.l	#160,d6
undrawloop:
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,(a1)
	add.l	d6,a1
	dbra	d7,undrawloop
noundraw:
	rts
	
halbundraw
	and	#255,d7
	move.l	#152,d6
halbundrawloop:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	add.l	d6,a1
	dbra	d7,halbundrawloop
	rts
	
palette	dc.w	$0,$700,$730,$750,$770,$470,$70,$75
	dc.w	$77,$111,$222,$333,$444,$555,$666,$777
	
daten:

	dc.w	$03C0,$07E0,$0000,$07E0,$0810,$1818,$07E0,$1FF8
	dc.w	$0000,$2004,$1FF8,$3FFC,$1310,$4C02,$3FFC,$7FFE
	dc.w	$4F12,$5C02,$3FFC,$7FFE,$0804,$9C09,$7FFE,$FFFF
	dc.w	$9411,$8805,$7FFE,$FFFF,$982B,$8005,$7FFE,$FFFF
	dc.w	$800B,$8005,$7FFE,$FFFF,$A155,$8009,$7FFE,$FFFF
	dc.w	$1994,$8009,$7FFE,$FFFF,$426A,$4012,$3FFC,$7FFE
	dc.w	$09D0,$4422,$3FFC,$7FFE,$0420,$23C4,$1FF8,$3FFC
	dc.w	$09D0,$1818,$07E0,$1FF8,$03C0,$07E0,$0000,$07E0

***** page 106
	
masken:


	dc.w	$07E0,$1FF8,$3FFC,$7FFE,$7FFE,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$7FFE,$7FFE,$3FFC,$1FF8,$07E0

	section	bss
	
ssp	ds.l	1
vidram	ds.l	1
logram	ds.l	1
oldram	ds.l	1

rezsave	ds.b	1
palsave	ds.b	1
palettesave	ds.w	16
		
		
x          ds.w	anz

	
y	ds.w	anz

xg	ds.w	anz


yg	ds.w	anz
	
	
	
saveindex	ds.w	1
	
	ds.l	200
	
stack	ds.l	4

bildschirme ds.b	64256



savepuffer  ds.b    262*anz*2



sppuffer:

	END
	

			