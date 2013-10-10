;------------------------
;
;  68000 Opcodes
;

abs	=	$0ab5

abcd::	abcd	d1,d2
	abcd	-(a3),-(a4)
	nop

add::	add	d1,d2
	add	a2,d3
	add	(a3),d4
	add	(a4)+,d5
	add	-(a5),d6
	add	$1234(a6),d7
	add	$12(a1,a2),d2
	add	abs.w,d3
	add	abs,d4
	add	.1(pc),d5
	add	.1(pc,a2),d6
	add	#$1234,d7
.1:	nop

	add	d1,(a2)
	add	d2,(a3)+
	add	d3,-(a4)
	add	d4,$1234(a5)
	add	d5,$12(a6,a7)
	add	d6,abs.w
	add	d7,abs
	nop

adda::	add	d1,a2
	adda	d1,a2
	adda	a2,a3
	adda	(a3),a4
	adda	(a4)+,a5
	adda	-(a5),a6
	adda	$1234(a6),a7
	adda	$12(a1,a2),a2
	adda	abs.w,a3
	adda	abs,a4
	adda	.1(pc),a5
	adda	.1(pc,a2),a6
	adda	#$1234,a7
.1:	nop

addi::	add	#$1234,d1
	addi	#$1234,d1
	addi	#$1234,(a3)
	addi	#$1234,(a4)+
	addi	#$1234,-(a5)
	addi	#$1234,$1234(a6)
	addi	#$1234,$12(a1,a2)
	addi	#$1234,abs.w
	addi	#$1234,abs
.1:	nop

addq::	addq	#1,d1
	addq	#2,a2
	addq	#3,(a3)
	addq	#4,(a4)+
	addq	#5,-(a5)
	addq	#6,$1234(a6)
	addq	#7,$12(a1,a2)
	addq	#8,abs.w
	addq	#1,abs
.1:	nop

addx::	addx	d1,d2
	addx	d3,d4
	addx	-(a1),-(a2)
	addx	-(a3),-(a4)

and::	and	d1,d2
	and	(a3),d4
	and	(a4)+,d5
	and	-(a5),d6
	and	$1234(a6),d7
	and	$12(a1,a2),d2
	and	abs.w,d3
	and	abs,d4
	and	.1(pc),d5
	and	.1(pc,a2),d6
	and	#$1234,d7
.1:	nop

	and	d1,(a2)
	and	d2,(a3)+
	and	d3,-(a4)
	and	d4,$1234(a5)
	and	d5,$12(a6,a7)
	and	d6,abs.w
	and	d7,abs
	nop

andi::	and	#$1234,d1
	andi	#$1234,d1
	andi	#$1234,(a3)
	andi	#$1234,(a4)+
	andi	#$1234,-(a5)
	andi	#$1234,$1234(a6)
	andi	#$1234,$12(a1,a2)
	andi	#$1234,abs.w
	andi	#$1234,abs
.1:	nop

	andi	#$ff,ccr
	andi	#$ffff,sr

asl::	asl.b	d1,d2
	asl	d2,d3
	asl.w	d3,d4
	asl.l	d4,d5

	asl.b	#2,d1
	asl	#3,d2
	asl.w	#4,d3
	asl.l	#5,d4

	asl	d5
	asl	(a3)
	asl	(a4)+
	asl	-(a5)
	asl	$1234(a6)
	asl	$12(a1,a2)
	asl	abs.w
	asl	abs
.1:	nop

asr::	asr.b	d1,d2
	asr	d2,d3
	asr.w	d3,d4
	asr.l	d4,d5

	asr.b	#2,d1
	asr	#3,d2
	asr.w	#4,d3
	asr.l	#5,d4

	asr	d5
	asr	(a3)
	asr	(a4)+
	asr	-(a5)
	asr	$1234(a6)
	asr	$12(a1,a2)
	asr	abs.w
	asr	abs
.1:	nop

bra::	bra	targ1
	bcc	targ1
	bcs	targ1
	beq	targ1
	bge	targ1
	bgt	targ1
	bhi	targ1
	ble	targ1
	bls	targ1
	blt	targ1
	bmi	targ1
	bne	targ1
	bpl	targ1
	bvc	targ1
	bvs	targ1

	nop

	bra.s	targ1
	bcc.s	targ1
	bcs.s	targ1
	beq.s	targ1
	bge.s	targ1
	bgt.s	targ1
	bhi.s	targ1
	ble.s	targ1
	bls.s	targ1
	blt.s	targ1
	bmi.s	targ1
	bne.s	targ1
	bpl.s	targ1
	bvc.s	targ1
	bvs.s	targ1

	nop
targ1::	nop
	nop

	bra.s	targ1
	bcc.s	targ1
	bcs.s	targ1
	beq.s	targ1
	bge.s	targ1
	bgt.s	targ1
	bhi.s	targ1
	ble.s	targ1
	bls.s	targ1
	blt.s	targ1
	bmi.s	targ1
	bne.s	targ1
	bpl.s	targ1
	bvc.s	targ1
	bvs.s	targ1

	nop

	bra	targ1
	bcc	targ1
	bcs	targ1
	beq	targ1
	bge	targ1
	bgt	targ1
	bhi	targ1
	ble	targ1
	bls	targ1
	blt	targ1
	bmi	targ1
	bne	targ1
	bpl	targ1
	bvc	targ1
	bvs	targ1

	nop

	bra.w	targ1
	bcc.w	targ1
	bcs.w	targ1
	beq.w	targ1
	bge.w	targ1
	bgt.w	targ1
	bhi.w	targ1
	ble.w	targ1
	bls.w	targ1
	blt.w	targ1
	bmi.w	targ1
	bne.w	targ1
	bpl.w	targ1
	bvc.w	targ1
	bvs.w	targ1

bchg::	bchg	d1,d2
	bchg	d2,(a3)
	bchg	d3,(a4)+
	bchg	d4,-(a5)
	bchg	d5,$1234(a6)
	bchg	d6,$12(a1,a2)
	bchg	d7,abs.w
	bchg	d1,abs

	bchg	#1,d2
	bchg	#2,(a3)
	bchg	#3,(a4)+
	bchg	#4,-(a5)
	bchg	#5,$1234(a6)
	bchg	#6,$12(a1,a2)
	bchg	#7,abs.w
	bchg	#1,abs

bclr::	bclr	d1,d2
	bclr	d2,(a3)
	bclr	d3,(a4)+
	bclr	d4,-(a5)
	bclr	d5,$1234(a6)
	bclr	d6,$12(a1,a2)
	bclr	d7,abs.w
	bclr	d1,abs

	bclr	#1,d2
	bclr	#2,(a3)
	bclr	#3,(a4)+
	bclr	#4,-(a5)
	bclr	#5,$1234(a6)
	bclr	#6,$12(a1,a2)
	bclr	#7,abs.w
	bclr	#1,abs

bset::	bset	d1,d2
	bset	d2,(a3)
	bset	d3,(a4)+
	bset	d4,-(a5)
	bset	d5,$1234(a6)
	bset	d6,$12(a1,a2)
	bset	d7,abs.w
	bset	d1,abs

	bset	#1,d2
	bset	#2,(a3)
	bset	#3,(a4)+
	bset	#4,-(a5)
	bset	#5,$1234(a6)
	bset	#6,$12(a1,a2)
	bset	#7,abs.w
	bset	#1,abs

btst::	btst	d1,d2
	btst	d2,(a3)
	btst	d3,(a4)+
	btst	d4,-(a5)
	btst	d5,$1234(a6)
	btst	d6,$12(a1,a2)
	btst	d7,abs.w
	btst	d1,abs
	btst	d2,.1(pc)
	btst	d3,.1(pc,a3)
	btst	d4,#$12

	btst	#1,d2
	btst	#2,(a3)
	btst	#3,(a4)+
	btst	#4,-(a5)
	btst	#5,$1234(a6)
	btst	#6,$12(a1,a2)
	btst	#7,abs.w
	btst	#1,abs
	btst	#2,.1(pc)
	btst	#3,.1(pc,a3)
.1:	nop

chk::	chk	d1,d2
	chk	(a3),d4
	chk	(a4)+,d5
	chk	-(a5),d6
	chk	$1234(a6),d7
	chk	$12(a1,a2),d2
	chk	abs.w,d3
	chk	abs,d4
	chk	.1(pc),d5
	chk	.1(pc,a2),d6
	chk	#$1234,d7
.1:	nop

clr::	clr	d1
	clr	(a3)
	clr	(a4)+
	clr	-(a5)
	clr	$1234(a6)
	clr	$12(a1,a2)
	clr	abs.w
	clr	abs
	clr	a1
.1:	nop

cmp::	cmp	d1,d2
	cmp	a2,d3
	cmp	(a3),d4
	cmp	(a4)+,d5
	cmp	-(a5),d6
	cmp	$1234(a6),d7
	cmp	$12(a1,a2),d2
	cmp	abs.w,d3
	cmp	abs,d4
	cmp	.1(pc),d5
	cmp	.1(pc,a2),d6
	cmp	#$1234,d7
	cmp.w	a2,d3
	cmp.l	a2,d3
.1:	nop

cmpa::	cmpa	d1,a2
	cmpa	a2,a3
	cmpa	(a3),a4
	cmpa	(a4)+,a5
	cmpa	-(a5),a6
	cmpa	$1234(a6),a7
	cmpa	$12(a1,a2),a2
	cmpa	abs.w,a3
	cmpa	abs,a4
	cmpa	.1(pc),a5
	cmpa	.1(pc,a2),a6
	cmpa	#$1234,a7
.1:	nop

cmpi::	cmpi	#$1234,d1
	cmpi	#$1234,(a3)
	cmpi	#$1234,(a4)+
	cmpi	#$1234,-(a5)
	cmpi	#$1234,$1234(a6)
	cmpi	#$1234,$12(a1,a2)
	cmpi	#$1234,abs.w
	cmpi	#$1234,abs
.1:	nop

cmpm::	cmpm.b	(a1)+,(a2)+
	cmpm	(a3)+,(a4)+
	cmpm.w	(a5)+,(a6)+
	cmpm.l	(a7)+,(a0)+
	nop

dbcc::	dbcc	d1,targ2
	dbcs	d2,targ2
	dbeq	d3,targ2
	dbf	d4,targ2
	dbge	d5,targ2
	dbgt	d6,targ2
	dbhi	d1,targ2
	dble	d2,targ2
	dbls	d3,targ2
	dblt	d4,targ2
	dbmi	d5,targ2
	dbne	d6,targ2
	dbpl	d1,targ2
	dbt	d2,targ2
	dbvc	d3,targ2
	dbvs	d4,targ2
	dbra	d5,targ2

	nop
targ2::	nop
	nop

	dbcc	d1,targ2
	dbcs	d2,targ2
	dbeq	d3,targ2
	dbf	d4,targ2
	dbge	d5,targ2
	dbgt	d6,targ2
	dbhi	d1,targ2
	dble	d2,targ2
	dbls	d3,targ2
	dblt	d4,targ2
	dbmi	d5,targ2
	dbne	d6,targ2
	dbpl	d1,targ2
	dbt	d2,targ2
	dbvc	d3,targ2
	dbvs	d4,targ2
	dbra	d5,targ2
	nop

divs::	divs	d1,d2
	divs	(a3),d4
	divs	(a4)+,d5
	divs	-(a5),d6
	divs	$1234(a6),d7
	divs	$12(a1,a2),d2
	divs	abs.w,d3
	divs	abs,d4
	divs	.1(pc),d5
	divs	.1(pc,a2),d6
	divs	#$1234,d7
.1:	nop

divu::	divu	d1,d2
	divu	(a3),d4
	divu	(a4)+,d5
	divu	-(a5),d6
	divu	$1234(a6),d7
	divu	$12(a1,a2),d2
	divu	abs.w,d3
	divu	abs,d4
	divu	.1(pc),d5
	divu	.1(pc,a2),d6
	divu	#$1234,d7
.1:	nop

eor::	eor	d1,(a2)
	eor	d2,(a3)+
	eor	d3,-(a4)
	eor	d4,$1234(a5)
	eor	d5,$12(a6,a7)
	eor	d6,abs.w
	eor	d7,abs
	nop

eori::	eor	#$1234,d1
	eori	#$1234,d1
	eori	#$1234,(a3)
	eori	#$1234,(a4)+
	eori	#$1234,-(a5)
	eori	#$1234,$1234(a6)
	eori	#$1234,$12(a1,a2)
	eori	#$1234,abs.w
	eori	#$1234,abs
	eori	#$ff,ccr
	eori	#$ffff,sr
	nop

exg::	exg	d1,d2
	exg	d2,a3
	exg	a3,d4
	exg	a4,a5

ext::	ext.w	d1
	ext.l	d2

illegal::
	illegal

jmp::	jmp	(a1)
	jmp	$1234(a2)
	jmp	$12(a3,a4)
	jmp	abs.w
	jmp	abs
	jmp	$1234(pc)
	jmp	$12(pc,a3)
	jmp	targ3(pc)
	jmp	targ3(pc,a4)
	nop
targ3::	nop
	nop

jsr::	jsr	(a1)
	jsr	$1234(a2)
	jsr	$12(a3,a4)
	jsr	abs.w
	jsr	abs
	jsr	$1234(pc)
	jsr	$12(pc,a3)
	jsr	targ4(pc)
	jsr	targ4(pc,a4)
	nop
targ4::	nop
	nop

lea::	lea	(a1),a2
	lea	$1234(a2),a3
	lea	$12(a3,a5),a4
	lea	abs.w,a5
	lea	abs,a6
	lea	targ5(pc),a1
	lea	targ5(pc,a6),a2
targ5::	nop

link::	link	a1,#$1234
	link	a2,#-1
	link	a3,#$ffff
	link	a3,#0

lsl::	lsl.b	d1,d2
	lsl	d2,d3
	lsl.w	d3,d4
	lsl.l	d4,d5

	lsl.b	#2,d1
	lsl	#3,d2
	lsl.w	#4,d3
	lsl.l	#5,d4

	lsl	d5
	lsl	(a3)
	lsl	(a4)+
	lsl	-(a5)
	lsl	$1234(a6)
	lsl	$12(a1,a2)
	lsl	abs.w
	lsl	abs
.1:	nop

lsr::	lsr.b	d1,d2
	lsr	d2,d3
	lsr.w	d3,d4
	lsr.l	d4,d5

	lsr.b	#2,d1
	lsr	#3,d2
	lsr.w	#4,d3
	lsr.l	#5,d4

	lsr	d5
	lsr	(a3)
	lsr	(a4)+
	lsr	-(a5)
	lsr	$1234(a6)
	lsr	$12(a1,a2)
	lsr	abs.w
	lsr	abs
.1:	nop

move::	move	d1,d1
	move	a2,d2
	move	(a3),d3
	move	(a4)+,d4
	move	-(a5),d5
	move	$1234(a6),d6
	move	$12(a1,a2),d1
	move	abs.w,d2
	move	abs,d3
	move	.1(pc),d4
	move	.1(pc,a2),d5
	move	#$1234,d6
.1:	nop

	move	d1,(a1)
	move	a2,(a2)
	move	(a3),(a3)
	move	(a4)+,(a4)
	move	-(a5),(a5)
	move	$1234(a6),(a6)
	move	$12(a1,a2),(a1)
	move	abs.w,(a2)
	move	abs,(a3)
	move	.2(pc),(a4)
	move	.2(pc,a2),(a5)
	move	#$1234,(a6)
.2:	nop

	move	d1,(a1)+
	move	a2,(a2)+
	move	(a3),(a3)+
	move	(a4)+,(a4)+
	move	-(a5),(a5)+
	move	$1234(a6),(a6)+
	move	$12(a1,a2),(a1)+
	move	abs.w,(a2)+
	move	abs,(a3)+
	move	.3(pc),(a4)+
	move	.3(pc,a2),(a5)+
	move	#$1234,(a6)+
.3:	nop

	move	d1,-(a1)
	move	a2,-(a2)
	move	(a3),-(a3)
	move	(a4)+,-(a4)
	move	-(a5),-(a5)
	move	$1234(a6),-(a6)
	move	$12(a1,a2),-(a1)
	move	abs.w,-(a2)
	move	abs,-(a3)
	move	.4(pc),-(a4)
	move	.4(pc,a2),-(a5)
	move	#$1234,-(a6)
.4:	nop

	move	d1,$1234(a1)
	move	a2,$1234(a2)
	move	(a3),$1234(a3)
	move	(a4)+,$1234(a4)
	move	-(a5),$1234(a5)
	move	$1234(a6),$1234(a6)
	move	$12(a1,a2),$1234(a1)
	move	abs.w,$1234(a2)
	move	abs,$1234(a3)
	move	.5(pc),$1234(a4)
	move	.5(pc,a2),$1234(a5)
	move	#$1234,$1234(a6)
.5:	nop

	move	d1,$12(a1,a5)
	move	a2,$12(a2,a5)
	move	(a3),$12(a3,a5)
	move	(a4)+,$12(a4,a5)
	move	-(a5),$12(a5,a5)
	move	$1234(a6),$12(a6,a5)
	move	$12(a1,a2),$12(a1,a5)
	move	abs.w,$12(a2,a5)
	move	abs,$12(a3,a5)
	move	.6(pc),$12(a4,a5)
	move	.6(pc,a2),$12(a5,a5)
	move	#$1234,$12(a6,a5)
.6:	nop

	move	d1,abs.w
	move	a2,abs.w
	move	(a3),abs.w
	move	(a4)+,abs.w
	move	-(a5),abs.w
	move	$1234(a6),abs.w
	move	$12(a1,a2),abs.w
	move	abs.w,abs.w
	move	abs,abs.w
	move	.7(pc),abs.w
	move	.7(pc,a2),abs.w
	move	#$1234,abs.w
.7:	nop

	move	d1,abs
	move	a2,abs
	move	(a3),abs
	move	(a4)+,abs
	move	-(a5),abs
	move	$1234(a6),abs
	move	$12(a1,a2),abs
	move	abs.w,abs
	move	abs,abs
	move	.8(pc),abs
	move	.8(pc,a2),abs
	move	#$1234,abs
.8:	nop


_ccr::	move	d1,ccr
	move	(a3),ccr
	move	(a4)+,ccr
	move	-(a5),ccr
	move	$1234(a6),ccr
	move	$12(a1,a2),ccr
	move	abs.w,ccr
	move	abs,ccr
	move	.1(pc),ccr
	move	.1(pc,a2),ccr
	move	#$1234,ccr
.1:	nop

_sr::	move	sr,d1
	move	sr,(a2)
	move	sr,(a3)+
	move	sr,-(a4)
	move	sr,$1234(a5)
	move	sr,$12(a6,a3)
	move	sr,abs.w
	move	sr,abs
	nop

	move	d1,sr
	move	(a3),sr
	move	(a4)+,sr
	move	-(a5),sr
	move	$1234(a6),sr
	move	$12(a1,a2),sr
	move	abs.w,sr
	move	abs,sr
	move	.1(pc),sr
	move	.1(pc,a2),sr
	move	#$1234,sr
.1:	nop

_usp::	move	usp,a1
	move	usp,a2
	move	a3,usp
	move	a4,usp

movea::	move	d1,a2
	move	a2,a3
	move	(a3),a4
	move	(a4)+,a5
	move	-(a5),a6
	move	$1234(a6),a1
	move	$12(a1,a2),a2
	move	abs.w,a3
	move	abs,a4
	move	.0(pc),a5
	move	.0(pc,a2),a6
	move	#$1234,a7
.0:	nop

movem::	movem	d1-d6/a3-a7,(a1)
	movem	d1-d6/a3-a7,-(a2)
	movem	d1-d6/a3-a7,$1234(a3)
	movem	d1-d6/a3-a7,$12(a4,a5)
	movem	d1-d6/a3-a7,abs.w
	movem	d1-d6/a3-a7,abs
	nop
	movem	(a1),d1-d6/a3-a7
	movem	(a2)+,d1-d6/a3-a7
	movem	$1234(a3),d1-d6/a3-a7
	movem	$12(a4,a5),d1-d6/a3-a7
	movem	abs.w,d1-d6/a3-a7
	movem	abs,d1-d6/a3-a7
	nop
	nop
	movem.w	d1-d6/a3-a7,(a1)
	movem.w	d1-d6/a3-a7,-(a2)
	movem.w	d1-d6/a3-a7,$1234(a3)
	movem.w	d1-d6/a3-a7,$12(a4,a5)
	movem.w	d1-d6/a3-a7,abs.w
	movem.w	d1-d6/a3-a7,abs
	nop
	movem.w	(a1),d1-d6/a3-a7
	movem.w	(a2)+,d1-d6/a3-a7
	movem.w	$1234(a3),d1-d6/a3-a7
	movem.w	$12(a4,a5),d1-d6/a3-a7
	movem.w	abs.w,d1-d6/a3-a7
	movem.w	abs,d1-d6/a3-a7
	nop
	nop
	movem.l	d1-d6/a3-a7,(a1)
	movem.l	d1-d6/a3-a7,-(a2)
	movem.l	d1-d6/a3-a7,$1234(a3)
	movem.l	d1-d6/a3-a7,$12(a4,a5)
	movem.l	d1-d6/a3-a7,abs.w
	movem.l	d1-d6/a3-a7,abs
	nop
	movem.l	(a1),d1-d6/a3-a7
	movem.l	(a2)+,d1-d6/a3-a7
	movem.l	$1234(a3),d1-d6/a3-a7
	movem.l	$12(a4,a5),d1-d6/a3-a7
	movem.l	abs.w,d1-d6/a3-a7
	movem.l	abs,d1-d6/a3-a7
	nop

movep::	movep	d1,$1234(a2)
	movep	d2,(a3)
	movep	$1234(a3),d4
	movep	(a4),d5

	movep.w	d1,$1234(a2)
	movep.w	d2,(a3)
	movep.w	$1234(a3),d4
	movep.w	(a4),d5

	movep.l	d1,$1234(a2)
	movep.l	d2,(a3)
	movep.l	$1234(a3),d4
	movep.l	(a4),d5

moveq::	moveq	#0,d0
	moveq	#$ff,d0
	moveq	#$7f,d0
	moveq	#1,d0

muls::	muls	d1,d2
	muls	(a3),d4
	muls	(a4)+,d5
	muls	-(a5),d6
	muls	$1234(a6),d7
	muls	$12(a1,a2),d2
	muls	abs.w,d3
	muls	abs,d4
	muls	.1(pc),d5
	muls	.1(pc,a2),d6
	muls	#$1234,d7
.1:	nop

mulu::	mulu	d1,d2
	mulu	(a3),d4
	mulu	(a4)+,d5
	mulu	-(a5),d6
	mulu	$1234(a6),d7
	mulu	$12(a1,a2),d2
	mulu	abs.w,d3
	mulu	abs,d4
	mulu	.1(pc),d5
	mulu	.1(pc,a2),d6
	mulu	#$1234,d7
.1:	nop

nbcd::	nbcd	d1
	nbcd	(a3)
	nbcd	(a4)+
	nbcd	-(a5)
	nbcd	$1234(a6)
	nbcd	$12(a1,a2)
	nbcd	abs.w
	nbcd	abs
	nop

neg::	neg	d1
	neg	(a3)
	neg	(a4)+
	neg	-(a5)
	neg	$1234(a6)
	neg	$12(a1,a2)
	neg	abs.w
	neg	abs
	nop

negx::	negx	d1
	negx	(a3)
	negx	(a4)+
	negx	-(a5)
	negx	$1234(a6)
	negx	$12(a1,a2)
	negx	abs.w
	negx	abs
	nop

nop::	nop
	nop

not::	not	d1
	not	(a3)
	not	(a4)+
	not	-(a5)
	not	$1234(a6)
	not	$12(a1,a2)
	not	abs.w
	not	abs
	nop

or::	or	d1,d2
	or	(a3),d4
	or	(a4)+,d5
	or	-(a5),d6
	or	$1234(a6),d7
	or	$12(a1,a2),d2
	or	abs.w,d3
	or	abs,d4
	or	.1(pc),d5
	or	.1(pc,a2),d6
	or	#$1234,d7
.1:	nop

	or	d1,(a2)
	or	d2,(a3)+
	or	d3,-(a4)
	or	d4,$1234(a5)
	or	d5,$12(a6,a7)
	or	d6,abs.w
	or	d7,abs
	nop

ori::	ori	#$1234,d1
	ori	#$1234,(a3)
	ori	#$1234,(a4)+
	ori	#$1234,-(a5)
	ori	#$1234,$1234(a6)
	ori	#$1234,$12(a1,a2)
	ori	#$1234,abs.w
	ori	#$1234,abs
	nop
	or	#$1234,d1
	or	#$1234,(a3)
	or	#$1234,(a4)+
	or	#$1234,-(a5)
	or	#$1234,$1234(a6)
	or	#$1234,$12(a1,a2)
	or	#$1234,abs.w
	or	#$1234,abs
	nop

	or	#$ff,ccr
	or	#$ffff,sr
	ori	#$ff,ccr
	ori	#$ffff,sr
	nop

pea::	pea	(a3)
	pea	$1234(a6)
	pea	$12(a1,a2)
	pea	abs.w
	pea	abs
	pea	.0(pc)
	pea	.0(pc,a2)
.0:	nop

reset::	reset
	nop

rol::	rol.b	d1,d2
	rol	d2,d3
	rol.w	d3,d4
	rol.l	d4,d5

	rol.b	#2,d1
	rol	#3,d2
	rol.w	#4,d3
	rol.l	#5,d4

	rol	d5
	rol	(a3)
	rol	(a4)+
	rol	-(a5)
	rol	$1234(a6)
	rol	$12(a1,a2)
	rol	abs.w
	rol	abs
.1:	nop

ror::	ror.b	d1,d2
	ror	d2,d3
	ror.w	d3,d4
	ror.l	d4,d5

	ror.b	#2,d1
	ror	#3,d2
	ror.w	#4,d3
	ror.l	#5,d4

	ror	d5
	ror	(a3)
	ror	(a4)+
	ror	-(a5)
	ror	$1234(a6)
	ror	$12(a1,a2)
	ror	abs.w
	ror	abs
.1:	nop

roxl::	roxl.b	d1,d2
	roxl	d2,d3
	roxl.w	d3,d4
	roxl.l	d4,d5

	roxl.b	#2,d1
	roxl	#3,d2
	roxl.w	#4,d3
	roxl.l	#5,d4

	roxl	d5
	roxl	(a3)
	roxl	(a4)+
	roxl	-(a5)
	roxl	$1234(a6)
	roxl	$12(a1,a2)
	roxl	abs.w
	roxl	abs
.1:	nop

roxr::	roxr.b	d1,d2
	roxr	d2,d3
	roxr.w	d3,d4
	roxr.l	d4,d5

	roxr.b	#2,d1
	roxr	#3,d2
	roxr.w	#4,d3
	roxr.l	#5,d4

	roxr	d5
	roxr	(a3)
	roxr	(a4)+
	roxr	-(a5)
	roxr	$1234(a6)
	roxr	$12(a1,a2)
	roxr	abs.w
	roxr	abs
.1:	nop

rte::	rte
rtr::	rtr
rts::	rts
	nop

sbcd::	sbcd	d1,d2
	sbcd	d3,d4
	sbcd	-(a1),-(a2)
	sbcd	-(a3),-(a4)

scc::	scc	d1
	scs	(a2)
	seq	(a3)+
	sf	-(a4)
	sge	$1234(a5)
	sgt	$12(a6,a1)
	shi	abs.w
	sle	abs
	sls	d1
	slt	(a2)
	smi	(a3)+
	sne	-(a4)
	spl	$1234(a5)
	st	$12(a6,a2)
	svc	abs.w
	svs	abs
	nop

stop::	stop	#$1234
	stop	#$2700
	stop	#$0000
	nop

sub::	sub	d1,d2
	sub	a2,d3
	sub	(a3),d4
	sub	(a4)+,d5
	sub	-(a5),d6
	sub	$1234(a6),d7
	sub	$12(a1,a2),d2
	sub	abs.w,d3
	sub	abs,d4
	sub	.1(pc),d5
	sub	.1(pc,a2),d6
	sub	#$1234,d7
.1:	nop

	sub	d1,(a2)
	sub	d2,(a3)+
	sub	d3,-(a4)
	sub	d4,$1234(a5)
	sub	d5,$12(a6,a7)
	sub	d6,abs.w
	sub	d7,abs
	nop

suba::	sub	d1,a2
	suba	d1,a2
	suba	a2,a3
	suba	(a3),a4
	suba	(a4)+,a5
	suba	-(a5),a6
	suba	$1234(a6),a7
	suba	$12(a1,a2),a2
	suba	abs.w,a3
	suba	abs,a4
	suba	.1(pc),a5
	suba	.1(pc,a2),a6
	suba	#$1234,a7
.1:	nop

subi::	sub	#$1234,d1
	subi	#$1234,d1
	subi	#$1234,(a3)
	subi	#$1234,(a4)+
	subi	#$1234,-(a5)
	subi	#$1234,$1234(a6)
	subi	#$1234,$12(a1,a2)
	subi	#$1234,abs.w
	subi	#$1234,abs
.1:	nop

subq::	subq	#1,d1
	subq	#2,a2
	subq	#3,(a3)
	subq	#4,(a4)+
	subq	#5,-(a5)
	subq	#6,$1234(a6)
	subq	#7,$12(a1,a2)
	subq	#8,abs.w
	subq	#1,abs
.1:	nop

subx::	subx	d1,d2
	subx	d3,d4
	subx	-(a1),-(a2)
	subx	-(a3),-(a4)
	nop

swap::	swap	d1
	swap	d2
	swap	d3
	swap	d7
	nop

tas::	tas	d1
	tas	(a3)
	tas	(a4)+
	tas	-(a5)
	tas	$1234(a6)
	tas	$12(a1,a2)
	tas	abs.w
	tas	abs
	nop

trap::	trap	#1
	trap	#2
	trap	#15
	trap	#$f
	nop

trapv::	trapv

tst::	tst	d1
	tst	(a3)
	tst	(a4)+
	tst	-(a5)
	tst	$1234(a6)
	tst	$12(a1,a2)
	tst	abs.w
	tst	abs
	nop

unlk:	unlk	a1
	unlk	a2
	unlk	a6
	unlk	a7
