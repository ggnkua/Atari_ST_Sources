antal = 20   ;1024*8
curves = 4

		move.w	#2,-(a7)
		trap	#14
		addq.l	#2,a7
		move.l	d0,screen

		pea	super(pc)
		move.w	#38,-(a7)
		trap	#14
		addq.l	#6,a7
		clr.w	-(a7)
		trap	#1

**********************************************

super:

drawloop:

		move.w	#37,-(a7)
		trap	#14
		addq.l	#2,a7
		move.w	#$700,$ffff8240.w

		moveq	#0,d2
		move.w	#antal-1,d7
		moveq	#0,d6

loop:

	
		lea	xtab(pc),a0
		moveq 	#0,d0
		moveq	#curves-1,d1
		bsr	bezier
		move.w	d3,d6

		lea	ytab(pc),a0
		moveq 	#0,d0
		moveq	#curves-1,d1
		bsr	bezier
		move.w	d3,d1
		move.w	d6,d0
		bsr.s	plot
		addq.w	#1,d6
		

		add.w	#$10000/antal,d2

		dbf	d7,loop

		move.w	#-1,$ffff8240.w

		cmp.b	#1+$80,$fffffc02.w
		bne.s	drawloop

		rts


plot:		movem.l	d0-a6,-(a7)
		move.l	screen(pc),a0
		mulu	#160,d1
		move.w	d0,d2
		and.w	#$f,d2
		sub.w	d2,d0
		lsr.w	#2,d0
		add.w	d0,d1
		moveq	#0,d0
		eor.w	#$f,d2
		bset	d2,d0
		or.w	d0,(a0,d1.w)
		movem.l	(a7)+,d0-a6
		rts

screen:		dc.l	0


xtab: dc.w 0,50,200,640
ytab: dc.w 0,199,100,0




* a0= address to P
* d0= i (point working on)
* d1= j (line segments in)
* d2= roh .l ($ffff-$0)
* out d3=answare

bezier:		movem.l	d0-d2/d4-a0,-(a7)

		cmp.w	#1,d1
		bne.s	not_outer

		move.w	d0,d6
		add.w	d6,d6
		move.w	(a0,d6.w),d3

		move.l	#$10000,d4
		sub.l	d2,d4
		ext.l	d3
		mulu	d3,d4
		cmp.w	#$8000,d4  (round)
		blo.s	rdown1
		add.l	#$10000,d4
rdown1:		swap	d4		D4=(1-roh)*P[i][0]
		
		move.w	d0,d6
		add.w	#1,d6
		add.w	d6,d6
		move.w	(a0,d6.w),d3    ! D3= roh*P[i+1][0]
		mulu	d2,d3
		cmp.w	#$8000,d3  (round)
		blo.s	rdown2
		add.l	#$10000,d3
rdown2:		swap	d3	

		ext.l	d3
		add.l	d4,d3

		movem.l	(a7)+,d0-d2/d4-a0
		rts


not_outer:
		move.l	d1,-(a7)
		subq.w	#1,d1
		bsr.s	bezier
		move.l	(a7)+,d1
		move.l 	#$10000,d4
		sub.l	d2,d4
		mulu	d3,d4

		cmp.w	#$8000,d4  (round)
		blo.s	rdown3
		add.l	#$10000,d4
rdown3:		swap	d4	    ; D4= (1-roh)*P[i][j-1]

		
		movem.l	d0-d1,-(a7)
		subq.w	#1,d1
		addq.w	#1,d0
		bsr.s	bezier
		movem.l	(a7)+,d0-d1
		mulu	d2,d3

		cmp.w	#$8000,d3  (round)
		blo.s	rdown4
		add.l	#$10000,d3
rdown4:		swap	d3

		add.w	d4,d3       ; d3=d4+roh*P[i+1][j-1]
		ext.l	d3

		movem.l	(a7)+,d0-d2/d4-a0
		rts
		
*****************************************

		cmp.w	#$8000,d3  (round)
		blo.s	rdown
		add.l	#$10000,d3
rdown:		swap	d3
		
