size2:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	2
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	2
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt.s	fin2
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin2:		rts

********************

size3:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	3
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	3
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt.s	fin3
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin3:		rts

********************

size4:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	4
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	4
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin4
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin4:		rts

********************

size5:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	5
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	5
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin5
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin5:		rts

********************

size6:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	6
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	6
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin6
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin6:		rts

********************

size7:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	7
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	7
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin7
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin7:		rts

********************

size8:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	8
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	8
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin8
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin8:		rts

********************

size9:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	9
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	9
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin9
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin9:		rts

********************

size10:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	10
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	10
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin10
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin10:		rts

********************

size11:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	11
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	11
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin11
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin11:		rts

********************

size12:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	12
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	12
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin12
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin12:		rts

********************

size13:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	13
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	13
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin13
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin13:		rts

********************

size14:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	14
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	14
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin14
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin14:		rts

********************

size15:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	15
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	15
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin15
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin15:		rts

********************

size16:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	16
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	16
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin16
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin16:		rts

********************

size17:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	17
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	17
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin17
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin17:		rts

********************

size18:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	18
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	18
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin18
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin18:		rts

********************

size19:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	19
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	19
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin19
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin19:		rts

********************

size20:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	20
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	20
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin20
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin20:		rts

********************

size21:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	21
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	21
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin21
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin21:		rts

********************

size22:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	22
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	22
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin22
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin22:		rts

********************

size23:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	23
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	23
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin23
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin23:		rts

********************

size24:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	24
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	24
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin24
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin24:		rts

********************

size25:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	25
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	25
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin25
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin25:		rts

********************

size26:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	26
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	26
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin26
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin26:		rts

********************

size27:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	27
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	27
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin27
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin27:		rts

********************

size28:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	28
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	28
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin28
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin28:		rts

********************

size29:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	29
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	29
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin29
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin29:		rts

********************

size30:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	30
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	30
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin30
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin30:		rts

********************

size31:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	31
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	31
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin31
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin31:		rts

********************

size32:		
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	32
		move.w	d2,yoff(a1)
		move.w	d3,yoff+8(a1)
		move.w	d4,yoff+16(a1)
		move.w	d5,yoff+24(a1)
		move.w	d6,yoff+32(a1)
		move.w	d7,yoff+40(a1)
		move.w	a3,yoff+48(a1)
		move.w	a4,yoff+56(a1)
		move.w	a5,yoff+64(a1)
		move.w	a6,yoff+72(a1)
yoff		set	yoff+160
		endr
		movem.w	(a0)+,d2-d7/a3-a6
yoff		set	0
		rept	32
		move.w	d2,yoff+80(a1)
		move.w	d3,yoff+88(a1)
		move.w	d4,yoff+96(a1)
		move.w	d5,yoff+104(a1)
		move.w	d6,yoff+112(a1)
		move.w	d7,yoff+120(a1)
		move.w	a3,yoff+128(a1)
		move.w	a4,yoff+136(a1)
		move.w	a5,yoff+144(a1)
		move.w	a6,yoff+152(a1)
		subq.w	#1,d0
		blt	fin32
yoff		set	yoff+160
		endr
		lea	yoff(a1),a1
fin32:		rts

********************