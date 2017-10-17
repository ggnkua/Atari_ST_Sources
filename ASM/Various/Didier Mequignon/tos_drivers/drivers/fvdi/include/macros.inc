//  ifb	stack
	.global	stack_address
	.global	vdi_stack
//  endc

#undef special_stack
#define SPECIAL_STACK_SIZE	512

//  ifnb	xbra_chain
	.global	vdi_address
//  endc

//  ifnb	_stand_alone
	.global	_stand_alone
//  endc


	.macro	save_regs
	movem.l	a1-a2,-(a7)
	.endm

	.macro	uses_d1
  #ifdef	transparent
	move.l	d1,-(a7)
  #endif
	.endm

	.macro	used_d1
  #ifdef	transparent
	move.l	(a7)+,d1
  #endif
  	.endm

	.macro	restore_regs
	movem.l	(a7)+,a1-a2
	.endm

	.macro	return
	local	do_rte
  #ifdef	special_stack
	move.l	(a7)+,a7
	add.l	#SPECIAL_STACK_SIZE,stack_address
#undef special_stack
  #endif
	restore_regs
  #ifdef transparent
	tst.w	_stand_alone
	bne	.&do_rte
	moveq	#$73,d0
	move.l	vdi_address(pc),-(a7)
	rts
.&do_rte:
	rte
  #else
	rte
  #endif
	.endm

	.macro	real_return
  #ifdef	special_stack
	move.l	(a7)+,a7
	add.l	#SPECIAL_STACK_SIZE,stack_address
#undef special_stack
  #endif
	restore_regs
	rte
	.endm

	.macro	done_return
  #ifdef	only_fvdi
	real_return
  #else
	return
  #endif
	.endm

	.macro	use_special_stack
	local	ok
#define special_stack
	move.w	sr,d0
	or.w	#$700,sr
	move.l	stack_address,a2
	cmp.l	#vdi_stack,a2
	beq	.&ok
	illegal
.&ok:
	move.l	a7,-(a2)
	move.l	a2,a7
	sub.w	#SPECIAL_STACK_SIZE-4,a2
	move.l	a2,stack_address
	move.w	d0,sr
	.endm

	.macro	ijsr indirect
  #ifdef mc68000
	local	return
	pea	.&return
	move.l	\indirect,-(a7)
	rts
.&return:
  #else
	jsr	([\indirect])
  #endif
	.endm

	.macro	ijmp indirect
  #ifdef mc68000
	move.l	\indirect,-(a7)
	rts
  #else
	jmp	([\indirect])
  #endif
  	.endm

#if 0
	.macro	label name,number
name:
	.endm

	.macro	l.name number
name:
	.endm
#endif

	.macro	lbra name,number
	bra	\name
	.endm
	
	.macro	lbeq name,number
	beq	\name
	.endm

	.macro	lbne name,number
	bne	\name
	.endm

	.macro	lbge name,number
	bge	\name
	.endm

	.macro	lbgt name,number
	bgt	\name
	.endm

	.macro	lble name,number
	ble	\name
	.endm

	.macro	lblt name,number
	blt	\name
	.endm

	.macro	lbhi name,number
	bhi	\name
	.endm

	.macro	lbls name,number
	bls	\name
	.endm

	.macro	lblo name,number
	blo	\name
	.endm

	.macro	lbcc name,number
	bcc	\name
	.endm

	.macro	lbcs name,number
	bcs	\name
	.endm

	.macro	ldbra reg,name,number
	dbra	\reg,\name
	.endm

	.macro	lbpl name,number
	bpl	\name
	.endm

	.macro	lbmi name,number
	bmi	\name
	.endm

	.macro	ldbeq reg,name,number
	dbeq	\reg,\name
	.endm
	
