	opt	alink

* assembler code to check read/write ability on RAM address

********************************************
********* REQUIRES Devpac Developer ********
********************************************

	xdef	_check_ram

* C interface to below routine. Passed long, returns char of 0 if failed, non-zero if true
* does not require supervisor mode
_check_ram
	move.l	4(sp),-(sp)			the address
	pea	check_rw_long(pc)
	move.w	#$26,-(sp)
	trap	#14
	lea	10(sp),sp
	rts

* given a0 and supervisor mode, see if we can read and write
* in supervisor mode without bus errors
* uses d0-d2/a0-a1
check_rw_long
	move.l	8(sp),a0			get param off stack
* before performing this check, ensure it doesnt crap on our code or stack!
	cmp.l	#.START,a0
	blt.s	.notcode
	cmp.l	#.END,a0
	blt.s	.reteq				if in this code
.notcode
	moveq	#-20,d0
	add.l	sp,d0				base of sp area
	cmp.l	d0,a0
	blt.s	.test
	cmp.l	sp,a0
	bgt.s	.test
.reteq	moveq	#1,d0				assume we can r/w
	rts
.test	move.w	sr,-(sp)
	or.w	#$0700,sr			dont interrupt me
	move.l	sp,d1
	lea	8.w,a1
	tst.w	$59e.w
	beq.s	.novbr
	OPT	P=68010
	movec	vbr,a1
	addq.w	#8,a1
	OPT	P=68000
.novbr	move.l	(a1),d2
	move.l	#.bad,(a1)
.START	move.l	#'AMP!',d0			scientific test pattern
	move.l	(a0),-(sp)			remember old contents
	move.l	d0,(a0)
	cmp.l	(a0),d0
	bne.s	.bad
	move.l	(sp)+,(a0)			restore if OK
	moveq	#1,d0
	bra.s	.done
.bad	moveq	#0,d0
.done	move.l	d2,(a1)				restore handler
.END	move.l	d1,sp				and SSP
	move.w	(sp)+,sr
	rts
