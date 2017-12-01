	text

protect	equ	0

	opt	d-

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	
	clr.b	$484.w

	jmp	test1
retour_jmp
	movem.l	zero,d0-d7/a0-a6
	movem.l	d0-d7,$ffff8240.w

	move.w	#$2700,sr
	lea	save,a0
	move.l	$70.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l	#reset_vbl,$70.w
	move.w	#$2300,sr

	moveq	#6,d6
	move.l	d6,d4
reset_shifter
	stop	#$2300
	move.b	#1,$ffff8260.w	* moyenne
	stop	#$2300
	move.b	#0,$ffff8260.w
	dbra	d6,reset_shifter

	move.w	#$2700,sr
	moveq	#0,d0
	moveq	#0,d2
	move.w	#127,d7
check_trace
	lea	pekm,a0
	move.w	(a0),d0
	add.w	#$200,d0
	cmp.w	#$6046,d0
	bne.s	ok
	move.w	#$5246,d0
ok
	cmp.w	#$6146,d0
	bne.s	ok2
	move.w	#$5346,d0
ok2
	eor.w	#$100,d0
	move.w	d0,(a0)
pekm
	addq	#1,d6
	dbra	d7,check_trace
	move.l	#vbl_depro,$70.w
	move.w	#$2300,sr
.stop
	bra.s	.stop
reset_vbl
	rte
test1
	link	a6,#-24
	jmp	test2
	illegal
fin_prog
	move.w	#$2700,sr
	lea	save,a0
	move.l	(a0)+,$70.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.w	#$2300,sr
	
	stop	#$2300
	stop	#$2300

	move.w	#$0,$ffff8240.w
	move.w	#$333,$ffff8246.w

	bsr	flush_keyboard

	ifeq	protect

	move.w	#0,-(sp)
	pea	fname
	move.w	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	move.w	d0,handle
	
	pea	code
	move.l	#fin_code-code,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq	#4,sp

	clr.l	-(sp)
	trap	#1
	else
	jmp	code
	endc

flush_keyboard
	lea	$fffc00,a0
re_flush
	btst	#0,(a0)
	beq.s	fin_flush
	move.b	2(a0),d1
	bra.s	re_flush
fin_flush
	rts
test3
	move.w	#$2700,sr	
	move.b	$fffffc02.W,d0
	eor.l	d0,d4
bcl1:	add.b	(a0)+,d0
	swap	d0
ici:	sub.l	#-1,d6
	muls	d6,d0
	abcd 	d0,d6
	lea	ici,a0
	eor.w	#$200,(a0)
	asr.l	#7,d3
	not 	d3
	move.l	sp,a6
	movem.l	d0-d4,-(sp)
	movem.l	(sp)+,a2-a6
	add.l	a0,d0
	add.l	a1,d6
	sub.l	d6,a2
	nbcd	d2
	sbcd	d0,d2
	cmp.w	#1,d4
	bne.s	pek_dbra
	move.w	#bcl2-pek_dbra-2,pek_dbra+2
pek_dbra
	dbra	d4,bcl1
	illegal
	rte
	dc.w	$7541
	dc.w	$7422
	dc.w	$1731
bcl2
	jmp	retour_jmp
vbl_depro
	move.w	#$2700,sr
	clr.b	$ffff8260.w
	cmp.b	#$39,$fffc02
	beq	fin_prog
	add.l	a5,a5
	lea	$9(a5),a4
	add.l	a4,a4
	add.l	a4,a4
	add.l	a5,a5
	add.l	a5,a4
	movem.l	(a5),d0-d2
	move.l	(a4),jmp+2
	move.l	#new_trace,(a4)

	lea	$ffff8209.w,a0
	move.b	(a0),d1
.sync
	cmp.b	(a0),d1
	beq.s	.sync

	moveq	#0,d0
	sub.b	(a0),d0
	lsr.l	d0,d0
	lea	$ffff8260.w,a1
pek_dec
	move.l	#code,a2

	move.w	#198,d7
	moveq	#0,d0
	move.w	d0,d5
	moveq	#2,d1

	dcb.w	52,$4e71
lig_f
	move.w	#$7,$ffff8240.w	* 4
	move.b	d1,(a1)		* 2
	move.b	(a0),d2		* 2
	move.b	d0,(a1)		* 2

	move	d4,d3		* 1
	muls	d3,d3		* 18

	move.l	(a5,d3.w),a3	* 4
	move.b	(a3,d5.w),d3	* 3
	addq	#1,d5		* 1
	and.w	#$7,d5		* 2
	eor.b	d3,d2		* 1
	eor.b	d6,d2

	move	d2,d3
	move	d3,d0
	tas	d3
	neg	d3
	roxr.l	d3

	dcb.w	5,$4e71

	sub.b	(a0),d2		* 2
	eor.b	d2,(a2)+		* 2

	move.w	#$0,$ffff8240.w	* 4

	dcb.w	128-55-3,$4e71

	dbra	d7,lig_f

	cmp.l	#fin_code,a2
	bge	fin_prog
	move.l	a2,pek_dec+2
	move.w	#$2300,sr
	rte
new_trace
	sub.l	#8,2(sp)
jmp
	jmp	$12345678

zero
	dcb.l	16,0
save
	ds.l	20
handle
	dc.w	0
fname
	dc.b	'testcode.bin',0
	even
test2
	moveq	#0,d1
	move.b	$ffff8209.w,d0
	ror	d0
	sub	d0,d1
	lsr.l	d1,d1
	unlk	a6
	move.l	#test3,(sp)
	sub.l	d0,d0
	rts
code
*	incbin	testcode.bin
	addq	#1,$ffff8240.w
	cmp.b	#$39,$fffc02
	bne.s	code
	clr.l	-(sp)
	trap	#1
fin_code