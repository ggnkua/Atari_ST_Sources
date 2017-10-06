
	far	data

ISZ	equ	32
ISM	equ ((ISZ-1)*2)


	public	_findpacket
_findpacket
	movem.l	a0/a1/d0,-(sp)
	move.w	isct,d0		;get count of events in buffer
	cmp.w	#ISZ,d0		;if max'd out return early
	beq		zpack
	addq.w	#1,d0		;inc and store event count
	move.w	d0,isct
	move.l	#is,a1		;get event buffer
	move.w	iswr,d0		;and write index
	add.w	d0,a1		;write place in event buffer
	add.w	#2,d0		;update read pointer
	and.w	#ISM,d0		
	move.w	d0,iswr
	addq	#1,a0		;skip over which joystick byte
	move.b	(a0)+,(a1)+	;copy joy0 to buffer
	move.b	(a0)+,(a1)+	;copy joy1 to buffer
zpack movem.l	(sp)+,a0/a1/d0
	rts

	near data

	public _readjoy
_readjoy
	move.w	isct,d0
	beq	zread
	subq.w	#1,isct
	move.l	#is,a0
	move.w	isrd,d0
	add.w	d0,a0
	add.w	#2,d0
	and.w	#ISM,d0
	move.w	d0,isrd
	move.b	(a0)+,__ljoy
	move.b	(a0)+,__rjoy
zread	rts

	dseg
	public __ljoy
	public __rjoy
	public __bjoy

__bjoy
__ljoy	dc.b	0
__rjoy	dc.b	0

	bss	is,ISZ*2
	bss	isct,2
	bss	isrd,2
	bss	iswr,2

