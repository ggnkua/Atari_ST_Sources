		.xdef	init_linea,get_planes,qmove,qfill,get_timer,crc
		.xdef	getit
		
get_planes:
		movem.l	a2,-(a7)
		.dc.w	$a000
		move.w	(a0),d0
		movem.l	(a7)+,a2
		rts
		
qmove:	subq.w	#1,d0
qml:	move.l	(a0)+,(a1)+
		dbra	d0,qml
		rts
qfill:	subq.w	#1,d0
qfl:	move.b	d1,(a0)+
		dbra	d0,qfl
		rts

get_timer:
		pea		_gt(pc)
		move.w	#38,-(a7)
		trap	#14
		addq.l	#6,a7
		rts
_gt:	move.l	$4ba,d0
		rts

crc:	movem.l d3-d7,-(a7)
		move.w  d0,d6 
		clr.w   d7
		bra     lx1
lx2:	move.w  d7,d0 
		move.b  (a0)+,d1
		ext.w   d1
		asl.w   #8,d1 
		eor.w   d1,d0 
		move.w  d0,d7 
		clr.w   d5
		bra     lx6
lx3:	move.w  d7,d0 
		and.w   #$8000,d0 
		beq     lx4
		move.w  d7,d0 
		asl.w   #1,d0 
		move.w  #$1021,d3 
		eor.w   d3,d0 
		move.w  d0,d7 
		bra     lx5
lx4:	move.w  d7,d0 
		asl.w   #1,d0 
		move.w  d0,d7 
lx5:	addq.w  #1,d5 
lx6:	cmpi.w  #8,d5 
		blt     lx3
lx1:	subq.w  #1,d6 
		move.w  d6,d0 
		cmpi.w  #0,d0 
		bge     lx2
		move.w  d7,d0 
		and.w   #$FFFF,d0 
		bra     lx7
lx7:	movem.l (a7)+,d3-d7
		rts 

		.end