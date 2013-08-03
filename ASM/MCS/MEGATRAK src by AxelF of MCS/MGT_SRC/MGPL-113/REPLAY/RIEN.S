		lea	Table,a0							* Code 68030
		move.l	60+48+48(a0),d4
		lsr.l	#8,d4
		
		moveq.l	#0,d0
		move.l	#428/2,d1
		divu.l	#50066,d1:d0
		mulu.l	#50066,d1:d0
		divu.l	d4,d1:d0
		lsr.l	#7,d0
		lsr.l	#8,d0
		swap.w	d0
		nop
		nop
		
		move.l	60+48+48(a0),d4				* Code 68000
		lsr.l	#8,d4
		move.l	#428/2,d0
		divu.w	#50066,d0
		;swap.w	d0
		divu.w	d4,d0
		swap.w	d0
		mulu.w	#50066,d0
		lsr.l	#1,d0
		lsr.l	#1,d0
		lsr.l	#1,d0
		lsr.l	#1,d0
		
Table		INCBIN	D:\BOSS\DATA\PERIODS.TAB


