
	.global _sys_arch_chksum
	.text

_sys_arch_chksum:                  // <> lwip_standard_chksum Version C

	subq.l #8,SP
	move.l D4,-(SP)
	move.l D3,-(SP)
	move.l D2,-(SP)
	move.l 28(SP),D4      // len
	move.l 24(SP),A0      // dataptr
	clr.w 14(SP)          // t
	clr.l D2
	move.l A0,D3
	moveq #1,D1
	and.l D1,D3
	beq.s .chk9
	tst.l D4               // len
	ble.s .chk9
	move.b (A0)+,15(SP)    // t[1]
	subq.l #1,D4           // len-1
.chk9:
	move.l A0,D0
	moveq #3,D1
	and.l D1,D0            // dataptr & 3
	beq.s .chk6
	moveq #1,D0
	cmp.l D4,D0
	bge.s .chk6
	clr.l d2
	move.w (A0)+,D2
	subq.l #2,D4           // len-2
	bra.s .chk6
.chk4:
		move.l D2,D0
		add.l (A0)+,D0 // ping
		cmp.l D0,D2
		bls.s .chk5
		addq.l #1,D0 // add back carry
.chk5:
		move.l D0,D2
		add.l (A0)+,D2 // pong
		cmp.l D2,D0
		bls.s .chk6
		addq.l #1,D2 // add back carry
.chk6:
	subq.l #8,D4           // len
	bpl.s .chk4
	addq.l #8,D4
	clr.l D0
	move.w D2,D0           // make room in upper bits
	clr.w D2
	swap D2
	add.l D0,D2
	bra.s .chk8            // 16-bit aligned word remaining?
.chk7:
		move.w (A0)+,d0
		add.l d0,d2
.chk8:
	subq.l #2,D4
	bpl.s .chk7
	addq.l #2,D4           // dangling tail byte remaining?
	ble.s .chk10
	move.b (A0),14(SP)     // include odd byte
.chk10:
	clr.l D0
	move.w 14(SP),D0
	add.l D0,D2            // add end bytes
	move.l #0xffff,D1
	bra.s .chk2
.chk1:
		and.l D1,D2    // sum
		add.l D0,D2
.chk2:
		move.l D2,D0
		clr.w D0
		swap D0
	tst.l D0
	bne.s .chk1
	tst.l D3               // odd
	beq.s .chk3
	move.l D2,D1           // sum
	and.l #0xff,D1
	lsl.l #8,D1
	move.l D2,D0
	and.l #0xff00,D0
	lsr.l #8,D0
	move.l D1,D2
	or.l D0,D2             // sum
.chk3:
	clr.l D0
	move.w D2,D0
	move.l (SP)+,D2
	move.l (SP)+,D3
	move.l (SP)+,D4
	addq.l #8,SP
	rts
