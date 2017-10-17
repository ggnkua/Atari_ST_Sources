; A0 = address of buffer to put cpu registers.

		text
get_cpuregs:	movem.l	d0-a6,-(sp)
		
		move.l	a0,.buffer
		
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,-(sp)

		move.l	.buffer(pc),a0

		movec	urp,d0
		move.l	d0,(a0)+
		movec	srp,d0
		move.l	d0,(a0)+
		movec	tc,d0
		move.l	d0,(a0)+
		movec	itt0,d0
		move.l	d0,(a0)+
		movec	dtt0,d0
		move.l	d0,(a0)+
		movec	itt1,d0
		move.l	d0,(a0)+
		movec	dtt1,d0
		move.l	d0,(a0)+
		movec	sfc,d0
		move.l	d0,(a0)+
		movec	dfc,d0
		move.l	d0,(a0)+
		movec	cacr,d0
		move.l	d0,(a0)+
		
		
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp)+,d0-a6
		rts
.buffer:	ds.l 1

