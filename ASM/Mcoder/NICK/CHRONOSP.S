	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	move.b	$fffffa07.w,sav68901
	move.b	$fffffa09.w,sav68901+1
	move.b	$fffffa13.w,sav68901+2
	move.b	$fffffa15.w,sav68901+3

	move.l	$70.w,savvbl
	move.b	$ffff8260.w,savrez
	move.b	$ffff820a.w,savfreq

	moveq	#0,d0
	move.b	d0,$fffffa07.w
	move.b	d0,$fffffa09.w
	move.b	d0,$fffffa13.w
	move.b	d0,$fffffa15.w

	move.l	#vbl1,$70.w
	clr.l	cycles

	LEA	$200.w,A0
	lea	$10000,a6

	move	#$2300,sr
waitvbl:
	bra.s	waitvbl
vbl1:
;	clr.b	$ffff820a.w
	clr.b	$ffff8260.w
	move.l	#vbl2,$70.w
	move.l	#exec,2(a7)
	rte
exec:
	lea	$30000,a0
	lea	$78000,a1
	moveq	#0,d1		;X
	moveq	#0,d2		;Y
	moveq	#24,d3		;nb octets largeur
	moveq	#32,d4
	jsr	$40000

	addq.l	#1,cycles
	bra.s	exec

ret:	rte
vbl2:
	subq	#1,trame
	bpl.s	ret
	move.b	savrez,$ffff8260.w
	move.b	savfreq,$ffff820a.w
	move	#$2700,sr
	addq	#6,sp

	move.b	sav68901,$fffffa07.w
	move.b	sav68901+1,$fffffa09.w
	move.b	sav68901+2,$fffffa13.w
	move.b	sav68901+3,$fffffa15.w
get:
	cmp.b	#$9c,$fffffc02.w
	bne.s	get
	move.b	#0,$fffffa0f.w
	move.b	#0,$fffffa11.w
	move.l	savvbl,$70.w
	move.l	cycles,d7
	illegal
cycles:	dc.l	0
savvbl:	dc.l	0
sav68901:blk.b	32
savrez:	dc.b	0
savfreq:dc.b	0
	even
trame:	dc.w	100-1		;nb trames
