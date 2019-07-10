;	mega reset

;
;set the system, before doing a TERM...
;
	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	pea.l	intro(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	
	
	move.w	#$2700,sr
	
	move.l	$426.w,rsm1
	move.l	$42a.w,rsm2
	move.l	#$31415926,$426.w
	lea.l	reset(pc),a0
	move.l	a0,$42a.w
	
	
	
	lea.l	vsys(pc),a0
	lea.l	$60.w,a1
	
	move.w	#$1a0/4-1,d0
c1:	
	move.l	(a1)+,(a0)+
	dbra	d0,c1

	lea.l	vect(pc),a0
	lea.l	$100.w,a1
	move.w	#15,d0
c4:	move.l	(a1)+,(a0)+
	dbra	d0,c4
	
	
	lea.l	mfp(pc),a0
	lea.l	$fffffa00.w,a1
	
	move.w	#$20/4-1,d0
c2:	
	move.l	(a1)+,(a0)+
	dbra	d0,c2
	
	
	
	
	lea.l	mem(pc),a0
	lea.l	$ffff8200.w,a1
	
	move.w	#$10/4-1,d0
c3:	
	move.l	(a1)+,(a0)+
	dbra	d0,c3

	lea.l	$ffff8800.w,a2
	move.b	#14,(a2)
	move.b	(a2),(a0)+
	move.b	#15,(a2)
	move.b	(a2),(a0)+
	move.b	#7,(a2)
	move.b	(a2),(a0)+
	
	lea.l	mem2(pc),a0
	;move.l	$452.w,(a0)+
	move.l	$476.w,(a0)+
	lea.l	$4ce.w,a1
	rept 8
	move.l	(a1)+,(a0)+
	endr
	

	
	
	;bra	*
	bra	suite
	
	
	
	
	
reset:	
	move.w	#$2700,sr
	moveq	#0,d0
	;move.l	d0,$fffffa06.w

	
	
	lea.l	pile(pc),sp
	lea.l	upile(pc),a0
	move.l	a0,usp

	lea.l	vsys(pc),a1
	lea.l	$60.w,a0
	
	move.w	#$20/4-1,d0
rc1:	
	move.l	(a1)+,(a0)+
	dbra	d0,rc1
	
	lea.l	vect(pc),a1
	lea.l	$100.w,a0
	move.w	#15,d0
rc4:	move.l	(a1)+,(a0)+
	dbra	d0,rc4
	
	
	lea.l	mfp(pc),a0
	lea.l	$fffffa00.w,a1
	
	move.w	#$20/4-1,d0
rc2:	
	move.l	(a0)+,(a1)+
	dbra	d0,rc2
	
	
	
	lea.l	mem(pc),a0
	lea.l	$ffff8200.w,a1
	
	move.w	#$10/4-1,d0
rc3:	
	move.l	(a0)+,(a1)+
	dbra	d0,rc3
	
	clr.l	$44e.w
	move.b	$ffff8201.w,$44f.w
	move.b	$ffff8203.w,$450.w
	
	lea.l	$ffff8800.w,a2
	move.b	#14,(a2)
	move.b	(a0)+,2(a2)
	move.b	#15,(a2)
	move.b	(a0)+,2(a2)
	move.b	#7,(a2)
	move.b	(a0)+,2(a2)
	
	
	;bra.s	suit
	lea.l	mem2(pc),a1
	;move.l	(a1)+,$452.w
	move.l	(a1)+,$476.w
	lea.l	$4ce.w,a0
	rept 8
	;move.l	(a1)+,(a0)+
	endr
suit:		
	
	move.w	#$80,$ffff8606.w
	moveq	#50,d1
rc5:	
	dbra	d1,*
	
	move.w	$ffff8604.w,d0
	moveq	#50,d1
	dbra	d1,*
	tst.b	d0
	blt.s	rc5
	
	lea.l	$ffff8800.w,a0
	move.b	#14,(a0)
	move.b	(a0),d0
	or.b	#7,d0
	move.b	d0,2(a0)
	
	move.b	$44c.w,$ffff8260.w
	clr.b	$ffff820a.w
	
		
	pea.l	texte(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	rept 0
w:	
	move.b	$fffffc02.w,d0
	cmp.b	#$39,d0
	beq.s	w
	cmp.b	#$13,d0
	beq.s	w
	endr
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w
	
	move.w	#$107,d0
	moveq	#$13,d1
	moveq	#$39,d2
	lea.l	$ffff8240.w,a0
	lea.l	$fffffc02.w,a1
b:	
	rept 115
	nop
	endr
	add.w	d0,(a0)
	move.b	(a1),d7
	cmp.b	d1,d7
	beq	quit
	cmp.b	d2,d7
	bne	b
	
wk:	
	move.b	(a1),d0
	btst.b	#0,-2(a1)
	bne.s	wk
	
	move.w	#$b99,$ffff8240.w
	move.w	#$bbf,$ffff8246.w
	move.w	#$bbf,$ffff825e.w
	
fin:	
	move.w	#$2300,sr
	clr.l	-(sp)
	trap	#1
	bra	reset
	
	
quit:
	move.l	rsm1(pc),$426.w
	move.l	rsm2(pc),$42a.w
	move.l	4.w,a0
	jmp	(a0)
	

intro:	
	dc.b	13,10,"CRAC-RESET OK",13,10,0

texte:	dc.b	27,"E",10,10,10,10,10,10,10,10
	dc.b	"******  CRAC-RESET  *****",13,10,10
	dc.b	"R = RESET,  [SPACE] = GEM",0
	
	
free:	ds.l	100
pile:	ds.l	100
upile:	ds.l	100

rsm1:	ds.l	1
rsm2:	ds.l	1
vect:	ds.l	16
mfp:	ds.l	8
mem:	ds.l	100
mem2:	ds.l	$80
vsys:	ds.l	$1a0/4
	
suite:	
	rept 3
	moveq	#-1,d7
	dbra	d7,*
	endr
	
	move.w	#$2300,sr
	clr.w	-(sp)
	move.l	#4500,-(sp)
	move.w	#$31,-(sp)
	trap	#1
	
	
	

	END
