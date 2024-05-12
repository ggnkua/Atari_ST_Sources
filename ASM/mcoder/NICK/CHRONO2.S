nbvbl = 5
;
; en sortie :
;	d6=nb de cycles de la routine
;	d7=nb d'it‚rations
;
; nb cycles	d7
;	0	800739
;	4-------667279
;	8	571959
;	12------500459
;	16	444859
;	20------400369
;	24	363972
;	28------333640
;	32	307972
;	36------285979
;	40	266914
;	44------250231
;	48	235511
;	52------222427
;	56	210720
;
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
	move.b	$ffff820a.w,savfreq

	moveq	#0,d7
	move.b	d7,$fffffa07.w
	move.b	d7,$fffffa09.w
	move.b	d7,$fffffa13.w
	move.b	d7,$fffffa15.w

	LEA	FREE,A6
	move	#nbvbl,trame
	move.l	#vbl1,$70.w
	moveq	#0,d7
	move	#$2300,sr
waitvbl:bra.s	waitvbl

vbl1:	move.b	#2,$ffff820a.w
	move.l	#vbl2,$70.w
	move.l	#exec,2(a7)
	rte
exec:
;
; ici on met le code qu'on veut chronom‚trer
;
; a6 pointe sur de la RAM unused
;
	addq.l	#1,d7		;8
	bra.s	exec		;12
vbl2:
	subq	#1,trame
	beq.s	nocnt
	rte
nocnt:
	move	#$2700,sr
	addq	#6,sp
	bsr	divide
	move.b	savfreq,$ffff820a.w
	move.b	sav68901,$fffffa07.w
	move.b	sav68901+1,$fffffa09.w
	move.b	sav68901+2,$fffffa13.w
	move.b	sav68901+3,$fffffa15.w
	move.b	#0,$fffffa0f.w
	move.b	#0,$fffffa11.w
	move.l	savvbl,$70.w
get:
	tst.b	$fffffc00.w
	bpl.s	finj
	tst.b	$fffffc02.w
	bra.s	get
finj:
	illegal
savvbl:	dc.l	0
sav68901:ds.b	4
savfreq:dc.b	0
	even
trame:	dc.w	0		;nb trames
;
; divise d6 par d7 r‚sultat dans d6
;
divide:
	move.l	#160256*nbvbl,d6
	moveq	#0,d0
	moveq	#32-1,d1
div1:
	add.l	d6,d6
	addx.l	d0,d0
	cmp.l	d7,d0
	blo.s	div2
	sub.l	d7,d0
	addq	#1,d6
div2:
	dbra	d1,div1
	sub.l	#20,d6
	rts
FREE:
