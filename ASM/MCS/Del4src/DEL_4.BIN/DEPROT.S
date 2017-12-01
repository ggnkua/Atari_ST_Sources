	text

protect	equ	0

	opt	d+

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	
	clr.b	$484.w

	movem.l	zero,d0-d7/a0-a6
	movem.l	d0-d7,$ffff8240.w

	move.w	#$2700,sr
	ifeq	protect
	move.l	sp,save_sp
	move.l	$70.w,s_70
	move.b	$fffffa07.w,s_07
	move.b	$fffffa09.w,s_09
	endc
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
	move.l	#vbl_depro,$70.w
	move.w	#$2300,sr
.stop
	bra.s	.stop
reset_vbl
	rte
fin_prog
	ifeq	protect
	move.w	#$2700,sr
	move.l	s_70,$70.w
	move.b	s_07,$fffffa07.w
	move.b	s_09,$fffffa09.w
	move.l	save_sp,sp
	move.w	#$2300,sr

	stop	#$2300
	stop	#$2300

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

	move.w	#$2700,sr

	lea	code,a0
	lea	fin_code,a1
	lea	$4000,a2
reloc_code
	move.l	(a0)+,(a2)+
	cmp.l	a0,a1
	bge.s	reloc_code

	move.w	#$0,$ffff8240.w
	move.w	#$333,$ffff8246.w

	jmp	$4000
	endc
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
	move.w	#195,d7
	moveq	#0,d0
	move.w	d0,d5
	moveq	#2,d1

	dcb.w	52,$4e71
lig_f
	move.w	#$7,$ffff8240.w	* 4
	move.b	d1,(a1)		* 2
	move.b	(a0),d2		* 2
	move.b	d0,(a1)		* 2

	move	d4,d6		* 1
	muls	d6,d6		* 18

	move.l	(a5,d6.w),a3	* 4
	move.b	(a3,d5.w),d3	* 3
	addq	#1,d5		* 1
	and.w	#$7,d5		* 2
	eor.b	d3,d2		* 1

	dcb.w	12,$4e71		* 12 = 48

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
code
	incbin	new_debu.bin
fin_code
	ifeq	protect
s_70
	ds.l	1
s_07
	ds.b	1
s_09
	ds.b	1
save_sp
	endc