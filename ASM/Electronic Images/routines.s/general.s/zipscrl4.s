* Fast four pixel left scroller
* (C) SEPT 1989 Martin Griffiths	
* D0-D2/A0 smashed. 	   		

	clr -(sp)
	pea -1.w
	pea -1.w
	move.w #5,-(sp)
	trap #14
	add.w #12,sp
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	movem.l pic_buf+2,d0-d7
	movem.l d0-d7,$ffff8240.w



		BRA Test

scroll_l4	MOVE.L log_base(PC),A0
		LEA 32000(A0),A0
		MOVE #199,D1
		MOVEQ #4,D2
linesc_lp	MOVEQ #0,D0
		REPT 80
		MOVE -(A0),D0
		ROL.L D2,D0
		MOVE D0,(A0)
		ENDR
		DBF D1,linesc_lp
		RTS

Test		DC.W $A00A
		MOVE #3,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,log_base
		LEA pic_buf+34(PC),A0
		MOVE.L D0,A1
		MOVE #7999,D7
move_lp	MOVE.L (A0)+,(A1)+
		DBF D7,move_lp
		MOVEQ #49,D7
tst_lp	BSR scroll_l4
wait_vbl	DBF D7,tst_lp
		CLR -(SP)
		TRAP #1

log_base	DS.L 1
pic_buf	INCBIN c:\ic.pi1

