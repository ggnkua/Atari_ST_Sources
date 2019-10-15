begin:	lea	stackend,sp
	move.l	sp,d0
	subi.l	#begin-$0120,d0
	move.l	d0,-(sp)
	pea	begin-$0100(pc)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	adda.w	#$0c,sp
	bsr.s	ice3_04
	move.l	$84.w,ice3_08+2
	move.l	#ice3_06,$84.w
	bsr.s	ice3_05
	pea	ice3_02(pc)
	pea	ice3_02(pc)
	pea	filename(pc)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	bsr.s	ice3_04
	move.l	ice3_08+2(pc),$84.w
	bsr.s	ice3_05
	clr.w	-(sp)
	trap	#1

ice3_02:dc.l 0
filename: dc.b 'resource.del',0
	even

ice3_04:clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7
	rts
ice3_05:move.l	d7,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
ice3_06:movea.l	sp,a0
	btst	#$0d-8,(sp)
	bne.s	ice3_07
	move	usp,a0
	subq.l	#6,a0
ice3_07:addq.l	#6,a0
	cmpi.w	#$3f,(a0)
	beq.s	ice3_0a
ice3_08:jmp	$00.l
ice3_0a:move.l	8(a0),loadadr
	move.l	2(sp),ice3_0c+2
	move.l	#ice3_0b,2(sp)
	bra.s	ice3_08
ice3_0b:tst.w	2(sp)
	bmi.s	ice3_0c
	movea.l	loadadr(pc),a0
	bsr.s	ice3_0e
ice3_0c:jmp	$00.l

ice3_0e:include	ice_unp2.s

	bss
loadadr:ds.l	1
	ds.b	500
stackend:
	ds.b	10
