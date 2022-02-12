#
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss

	.extern	__brksize
	.define	_alloca

	.sect	.text

_alloca:
	move.l	(sp)+,a0	! return address
#if defined(__MLONG__) || defined(SIZE_T_LONG)
	move.l	(sp),d0		! amount
#else
	clr.l	d0		! sweep reg
	move.w	(sp),d0		! amount
#endif /* __MLONG__ */
	bclr	#0,d0		! check alignement
	beq	allo10
	add.l	#2,d0
allo10:	move.l	d0,d1		! copy amount
	add.l	__brksize,d1	! check heap
	cmp.l	d1,sp
	ble	allo_err	! stack overruns heap
	sub.l	d0,sp		! set new stackpointer
	move.l	sp,d0		! return address of allocated memory
#if defined(__MLONG__) || defined(SIZE_T_LONG)
	sub.l	#4,sp		! for argument
#else
	sub.l	#2,sp		! for argument
#endif /* __MLONG__ || SIZE_T_LONG */
	jmp	(a0)
allo_err:
	clr.l	d0
	jmp	(a0)
