
x_size	equ	423
y_size	equ	188

ugh:		lea	logo,a0
		lea	dest,a6
		moveq	#0,d6			;remap color 1
		moveq	#1,d7			;remap color 2
		bsr	remap
		move.l	a6,a5

		lea	dest-4*4,a0		
		lea	logo+128,a1
		moveq	#4-1,d0
.lo:		move.w	(a1)+,d1
		move.w	(a1)+,d2
		move.w	(a1)+,d3
		lsr.w	#2,d1
		lsr.w	#2,d2
		lsr.w	#2,d3
		and.w	#%11111100,d1
		and.w	#%11111100,d2
		and.w	#%11111100,d3
		move.b	d1,(a0)+
		move.b	d2,(a0)+
		clr.b	(a0)+
		move.b	d3,(a0)+
		dbra	d0,.lo
	
		lea	dest-4*4,a0
		move.l	a5,a1
		
		nop
		illegal	

remap:		move.w	d6,d0
		move.w	d7,d1
		mulu	#6,d0
		mulu	#6,d1
		move.l	(128,a0,d0.w),d2
		move.l	(128,a0,d1.w),d3
		move.l	d2,(128,a0,d1.w)
		move.l	d3,(128,a0,d0.w)
		move.w	(128+4,a0,d0.w),d2
		move.w	(128+4,a0,d1.w),d3
		move.w	d2,(128+4,a0,d1.w)
		move.w	d3,(128+4,a0,d0.w)
		
		movem.w	6(a0),d0-d3
		mulu	#6,d0
		lea	(128,a0,d0.w),a0
		
		add.w	#15,d1
		lsr.w	#4,d1
		mulu	d2,d1
		lsl.l	d3,d1
		lsr.l	#2,d1
		move.l	d1,d0
		
		move.l	a0,-(sp)
		move.l	a6,-(sp)
		move.l	d0,-(sp)
		
.loop:		move.w	(a0)+,d1
		move.w	(a0)+,d2
		moveq	#0,d3
		moveq	#16-1,d4
.loop2:		add.w	d1,d1
		addx.l	d3,d3
		add.w	d2,d2
		addx.l	d3,d3				
		dbra	d4,.loop2								
		move.l	d3,(a6)+
		subq.l	#1,d0
		bne	.loop
		
		move.l	(sp),d4
		move.l	4(sp),a6
		move.l	8(sp),a0
			
.lop2:		move.l	(a6),d0
		moveq	#0,d1
		
		moveq	#16-1,d3
.lop:		rol.l	#2,d0
		rol.l	#2,d1
		move.w	d0,d2
		and.w	#%11,d2
		cmp.w	d6,d2
		bne.s	.nc1
		move.w	d7,d2
		bra.s	.nc2
.nc1:		cmp.w	d7,d2
		bne.s	.nc2
		move.w	d6,d2
.nc2:		or.w	d2,d1
		dbra	d3,.lop						
		move.l	d1,(a6)+
		subq.l	#1,d4
		bne.s	.lop2
		
		move.l	(sp)+,d0
		move.l	(sp)+,a6
		move.l	(sp)+,a0
		
.x2:		move.l	(a6),d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#16-1,d4
.x:		add.l	d1,d1
		addx.w	d2,d2
		add.l	d1,d1
		addx.w	d3,d3
		dbra	d4,.x
		move.w	d2,(a6)+
		move.w	d3,(a6)+
		subq.l	#1,d0
		bne.s	.x2
		
		rts
			
logo:		incbin	"e:\elite.3\graphics\elite.tpi"
		even

		ds.l	4
dest:		ds.b	dest-logo
dest2:		ds.b	dest-logo+4*4

		end				
		
		