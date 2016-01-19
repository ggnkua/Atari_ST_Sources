	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,rezstore

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)

	lea	$ff8240,a0
	lea	oldpal,a1
	rept	16
	move.w	(a0)+,(a1)+
	endr

	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	lea	$ff8240,a0
	lea	newpal,a1
	rept	8
	move.l	(a1)+,(a0)+
	endr

	pea	top
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	bottom
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	device
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

keyloop	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	keyloop

	swap	d0
	cmp.b	#$10,d0
	beq	exit
	cmp.b	#$1f,d0
	beq	screen
	cmp.b	#$19,d0
	beq	printer
	bra.s	keyloop

printer
	lea	doc,a6
loop	cmp.b	#0,(a6)
	beq	exitprint
	move.b	(a6),d0
	move.w	d0,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	addq.l	#1,a6
	clr.w	d0
	bra	loop

exitprint	move.w	#12,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	bra	exit

screen
	pea	clearquest
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	clearquit
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	pea	nextpage
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	overflow
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	bottom2
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	pagenumber
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	pea	posstart
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.b	line

	lea	doc,a0
ploop	cmp.b	#22,line
	beq	endpage
	move.b	(a0),d0
	cmp.b	#$d,d0
	beq	incline
	cmp.b	#0,d0
	beq	finished
preturn	move.l	a0,-(sp)
	move.w	d0,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	(sp)+,a0
	addq.l	#1,a0
	bra.s	ploop

incline	addq.b	#1,line
	bra.s	preturn

endpage
	addq.l	#1,a0
	move.l	a0,-(sp)
noback	move.w	#8,-(sp)
	trap	#1
	addq.l	#2,sp
	swap	d0
	cmp.b	#$10,d0
	beq	exit
	cmp.b	#$30,d0
	beq	ebpage
	pea	cltobot
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	bottom2
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	addq.b	#1,page
	pea	pagenumber
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	posstart
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.b	line
	move.l	(sp)+,a0
	bra	ploop

ebpage	move.l	(sp)+,a0
	cmp.b	#'1',page
	beq	noback1
	bra	bpage2

noback1	move.l	a0,-(sp)
	bra	noback

finished
	move.l	a0,-(sp)
	pea	nextpage
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
kloop	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	kloop
	swap	d0
	cmp.b	#$10,d0
	beq	exit
	cmp.b	#$30,d0
	bne	kloop
	pea	cltobot
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	bottom2
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	subq.b	#1,page
	pea	pagenumber
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	posstart
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.b	line
	move.l	(sp)+,a0
bpage	lea	doc,a0
	move.b	page,d0
	sub.b	#'1',d0
	move.w	#22,d1
	muls	d0,d1
floop	cmp.b	#$d,(a0)
	beq	gotone
	add.w	#1,a0
	bra	floop
gotone	add.w	#2,a0
	sub.b	#1,d1
	cmp.b	#0,d1
	bne	floop
	bra	ploop

bpage2
	move.l	a0,-(sp)
	pea	nextpage
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	cltobot
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	bottom2
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	subq.b	#1,page
	pea	pagenumber
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	posstart
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.b	line
	move.l	(sp)+,a0

	lea	doc,a0
	clr.l	d0
	move.b	page,d0
	sub.b	#'1',d0
	tst.b	d0
	beq	ploop
	move.w	#22,d1
	muls	d0,d1
floop2	cmp.b	#$d,(a0)
	beq	gotone2
	add.w	#1,a0
	bra	floop2
gotone2	add.w	#2,a0
	sub.b	#1,d1
	cmp.b	#0,d1
	bne	floop2
	bra	ploop

exit
	move.w	rezstore,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	lea	oldpal,a0
	lea	$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr

	jmp	$fc0020

	section	data
	even
rezstore	dc.w	0

oldpal	ds.w	16

newpal	dc.w	$003,$700,$070,$666,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000
	even

line	dc.b	0

top	dc.b	27,'Y',32,32,27,'p',27,'w',27,'f'
	dc.b	'               README FILE DISPLAYER WRITTEN BY KARL (THE C A M E L)                          ',27,'q',0
cltobot
	dc.b	27,'Y',33,32
	rept	22
	dc.b	27,'l'
	dc.b	$d,$a
	endr
	dc.w	0

bottom	dc.b	27,'Y',56,32,27,'p',27,'w'
	dc.b	'                                   <Q> QUITS                                         ',27,'q',27,'v',0

bottom2	dc.b	27,'Y',56,61,27,'p',27,'w'
	dc.b	'PAGE ?',27,'q',27,'v',0,0

pagenumber	dc.b	27,'Y',56,66,27,'p',27,'w'

page	dc.b	'1'
	dc.b	27,'v',27,'q',0

device	dc.b	27,'Y',45,45
	dc.b	'      WHICH DEVICE (P) FOR PRINTER OR (S) FOR SCREEN'
	dc.b	27,'Y',48,60
	dc.b	'Original Idea and Layout'
	dc.b	27,'Y',49,60
	dc.b	'  By Alien and Lawz of'
	dc.b	27,'Y',50,60
	dc.b	'   The POMPEY PIRATES',0

clearquest	dc.b	27,'Y',45,32,27,'l'
	dc.b	27,'Y',48,60,27,'l'
	dc.b	27,'Y',49,60,27,'l'
	dc.b	27,'Y',50,60,27,'l'
	dc.b	0

clearquit	dc.b	27,'p',27,'Y',56,67,'    ',27,'q',0,0

nextpage
	dc.b	27,'Y',56,40,27,'p',27,'w'
	dc.b	' <B> BACK ONE PAGE'
	DC.B	27,'Y',56,70
	DC.B	' <Q> QUITS'
	DC.B	27,'Y',56,82
	DC.B	' <F> FORWARD ONE PAGE         ',27,'v',0
cls	dc.b	27,'E',0
posstart	dc.b	27,'Y',33,32
overflow	dc.b	27,'v',0
doc	incbin	"source.lst"
	even


