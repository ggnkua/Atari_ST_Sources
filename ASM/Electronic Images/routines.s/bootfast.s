; Boot in 16mhz cached!

go		clr.l -(sp)
		move.w #$20,-(sp)
		trap #1
		addq.l #6,sp
		clr.w $446.w
		lea.l reshandler(pc),a0	
		move.l a0,$42a.w
		move.l #$31415926,$426.w
.forever	bra.s .forever

reshandler	move.b #$ff,$ffff8e21.w
		moveq #-1,d0
.lp		not.w $ffff8240.w
		dbf d0,.lp
		jmp $e0007e
