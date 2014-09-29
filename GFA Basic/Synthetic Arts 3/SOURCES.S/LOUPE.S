	move.l		4(sp),a0
	move.l		8(sp),a1

	move.w		#14,d3

loop:

	move.w		#1,d5

loop2:
     Move.l           (a0),d0
  Clr.l   d2
   Move.l            d0,d1
   And.l           #-2147450880,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #1073758208,d1
    Lsr.l             #3,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #536879104,d1
    Lsr.l             #6,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #268439552,d1
    Lsr.l             #8,d1
    Lsr.l             #1,d1
    Or.l              d1,d2
    Move.l            d2,24(a0)

  Clr.l   d2
   Move.l            d0,d1
   And.l           #134219776,d1
    Lsl.l             #4,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #67109888,d1
    Lsl.l             #1,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #33554944,d1
    Lsr.l             #2,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #16777472,d1
    Lsr.l             #5,d1
    Or.l              d1,d2
    Move.l            d2,32(a0)

  Clr.l   d2
   Move.l            d0,d1
   And.l           #8388736,d1
    Lsl.l             #8,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #4194368,d1
    Lsl.l             #5,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #2097184,d1
    Lsl.l             #2,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #1048592,d1
    Lsr.l             #1,d1
    Or.l              d1,d2
    Move.l            d2,40(a0)

  Clr.l   d2
   Move.l            d0,d1
   And.l           #524296,d1
    Lsl.l             #8,d1
    Lsl.l             #4,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #262148,d1
    Lsl.l             #8,d1
    Lsl.l             #1,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #131074,d1
    Lsl.l             #6,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #65537,d1
    Lsl.l             #3,d1
    Or.l              d1,d2
    Move.l            d2,48(a0)



     Move.l           8(a0),d0
  Clr.l   d2
   Move.l            d0,d1
   And.l           #-2147450880,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #1073758208,d1
    Lsr.l             #3,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #536879104,d1
    Lsr.l             #6,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #268439552,d1
    Lsr.l             #8,d1
    Lsr.l             #1,d1
    Or.l              d1,d2
    Move.l            d2,56(a0)

  Clr.l   d2
   Move.l            d0,d1
   And.l           #134219776,d1
    Lsl.l             #4,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #67109888,d1
    Lsl.l             #1,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #33554944,d1
    Lsr.l             #2,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #16777472,d1
    Lsr.l             #5,d1
    Or.l              d1,d2
    Move.l            d2,64(a0)

  Clr.l   d2
   Move.l            d0,d1
   And.l           #8388736,d1
    Lsl.l             #8,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #4194368,d1
    Lsl.l             #5,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #2097184,d1
    Lsl.l             #2,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #1048592,d1
    Lsr.l             #1,d1
    Or.l              d1,d2
    Move.l            d2,72(a0)

  Clr.l   d2
   Move.l            d0,d1
   And.l           #524296,d1
    Lsl.l             #8,d1
    Lsl.l             #4,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #262148,d1
    Lsl.l             #8,d1
    Lsl.l             #1,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #131074,d1
    Lsl.l             #6,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #65537,d1
    Lsl.l             #3,d1
    Or.l              d1,d2
    Move.l            d2,80(a0)



     Move.l           16(a0),d0
  Clr.l   d2
   Move.l            d0,d1
   And.l           #-2147450880,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #1073758208,d1
    Lsr.l             #3,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #536879104,d1
    Lsr.l             #6,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #268439552,d1
    Lsr.l             #8,d1
    Lsr.l             #1,d1
    Or.l              d1,d2
    Move.l            d2,88(a0)

  Clr.l   d2
   Move.l            d0,d1
   And.l           #134219776,d1
    Lsl.l             #4,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #67109888,d1
    Lsl.l             #1,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #33554944,d1
    Lsr.l             #2,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #16777472,d1
    Lsr.l             #5,d1
    Or.l              d1,d2
    Move.l            d2,96(a0)

  Clr.l   d2
   Move.l            d0,d1
   And.l           #8388736,d1
    Lsl.l             #8,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #4194368,d1
    Lsl.l             #5,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #2097184,d1
    Lsl.l             #2,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #1048592,d1
    Lsr.l             #1,d1
    Or.l              d1,d2
    Move.l            d2,104(a0)

  Clr.l   d2
   Move.l            d0,d1
   And.l           #524296,d1
    Lsl.l             #8,d1
    Lsl.l             #4,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #262148,d1
    Lsl.l             #8,d1
    Lsl.l             #1,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #131074,d1
    Lsl.l             #6,d1
    Or.l              d1,d2
   Move.l            d0,d1
   And.l           #65537,d1
    Lsl.l             #3,d1
    Or.l              d1,d2
    Move.l            d2,112(a0)

	addq.l	#4,a0

	dbra.w	d5,loop2
	
	add.l	#16,a0

  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+
  Move.l          (a0),d1
  Move.l          d1,d0
  lsr.l           #1,d1
  or.l            d1,d0
  lsr.l           #1,d0
  or.l          d0,(a0)+


	 add.l   #40,a0

	dbra.w	d3,loop

	sub.l	#2400,a0

	or.l	#$00110011,1184(a0)
	or.l	#$00110011,1188(a0)

	move.w	#14,d0

loop3:	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+

	movem.l	(a0)+,d1-d7/a2-a6		
	movem.l	d1-d7/a2-a6,(a1)
	movem.l	d1-d7/a2-a6,160(a1)
	movem.l	d1-d7/a2-a6,320(a1)
	
	movem.l	(a0),d1-d7/a2-a6		
	movem.l	d1-d7/a2-a6,48(a1)
	movem.l	d1-d7/a2-a6,208(a1)
	movem.l	d1-d7/a2-a6,368(a1)

	add.l	#88,a0
	add.l	#640,a1	

	dbra.w	d0,loop3




	sub.l	#9496,a1
	add.l	#4000,a0

	clr.l	d0
	clr.l	d1

	move.w	12(sp),d0
	move.w	14(sp),d1

t	macro 
	rept	7
	move.w	(a2),(a1)+
	move.w	(a2),(a1)+
	move.w	(a2),(a1)+
	move.w	(a2)+,(a1)
	add.l	#154,a1
	endr

	move.l	a0,a2
	sub.l	#1112,a1
	clr.l	d2
	
	endm	


	move.l	a0,a2
	clr.l	d2

	divu.w	#100,d0
	move.w	d0,d2	
	lsl.w	#4,d2	
	add.l	d2,a2	
	
	t

	swap	d0
	and.l	#$ffff,d0
	divu.w	#10,d0
	move.w	d0,d2
	lsl.w	#4,d2
	add.l	d2,a2	

	t

	swap	d0
	and.l	#$ffff,d0
	move.w	d0,d2
	lsl.w	#4,d2
	add.l	d2,a2
	
	t

	addq.l	#8,a1

	divu.w	#100,d1
	move.w	d1,d2	
	lsl.w	#4,d2	
	add.l	d2,a2	
	
	t

	swap	d1
	and.l	#$ffff,d1
	divu.w	#10,d1
	move.w	d1,d2
	lsl.w	#4,d2
	add.l	d2,a2	

	t	

	swap	d1
	and.l	#$ffff,d1
	move.w	d1,d2
	lsl.w	#4,d2
	add.l	d2,a2
	
	t


	rts
