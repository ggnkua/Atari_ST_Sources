; Cache Control Register Equates (CACR)


		CLR.L -(SP)
		MOVE.W #$20,-(SP)	
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp

		MOVE #200-1,D7
lp		
		NOT.L $FFFF9800.W
		MOVE.W #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		NOT.L $FFFF9800.W
		MOVE.W #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		lea	$ffff8c00.w,a0
		movep.l	d0,1(a0)		; address
		move.l	#100,d0		
		movep.l	d0,9(a0)		; count

		

		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP	
		CLR -(SP)
		TRAP #1

oldsp		DC.L 0
		SECTION BSS
mem		DS.B 65536*2

