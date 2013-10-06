
;**************************************
;* reset_init_point
;**************************************

reset_init_point

		clr.w	ip_pos

		rts


;**************************************
;* paint_init_point10
;**************************************

paint_init_point10

		lea	ip_10(pc),a0
		move.w	(a0),d0
		subq.w	#1,d0
		bmi.s	pip10_now
		move.w	d0,(a0)

		rts


pip10_now
		move.w	#19,(a0)
		bsr	paint_init_point

		rts


;**************************************
;* paint_init_point
;**************************************

paint_init_point

		movem.l	d0-a6,-(sp)

		movea.l	screen_2,a0
		adda.l	#640*4,a0
		lea	ip_pos(pc),a1
		move.w	(a1),d0
		addi.w	#1,(a1)
		mulu	#10,d0
		adda.l	d0,a0

		moveq	#3,d0
		move.w	#%0111101111001111,d1
		move.w	#%0110101101001101,d2
		move.w	#%0101101011001011,d3
		move.w	#%0011100111000111,d4
pip_loop	move.w	d1,(a0)
		move.w	d2,640(a0)
		move.w	d3,1280(a0)
		move.w	d4,1920(a0)
		addq.l	#2,a0
		
		movem.l	d0-d4/a0,-(sp)
		btst	#0,d0
		beq.s	pip_skip
		jsr	vsync
pip_skip	movem.l	(sp)+,d0-d4/a0

		dbra	d0,pip_loop

		movem.l	(sp)+,d0-a6

		rts

;**************************************
;* clear_init_point
;**************************************

clear_init_point

		movem.l	d0-a6,-(sp)

		moveq	#7,d2
cip_loop1	moveq	#7,d0
		movea.l	screen_2,a0
		adda.l	#640,a0
cip_loop2	movea.l	a0,a1
		moveq	#79,d1
cip_loop3	move.w	(a1),-640(a1)
		move.w	2(a1),-638(a1)
		move.w	4(a1),-636(a1)
		move.w	6(a1),-634(a1)
		addq.w	#8,a1
		dbra	d1,cip_loop3
		lea	640(a0),a0
		dbra	d0,cip_loop2
		moveq	#2,d3
cip_loop4	movem.l	d2-d3/a0,-(sp)
		jsr	vsync
		movem.l	(sp)+,d2-d3/a0
		dbra	d3,cip_loop4
		dbra	d2,cip_loop1

		movem.l	(sp)+,d0-a6

		rts


;**************************************
;* variables
;**************************************

ip_pos		dc.w	0
ip_10		dc.w	0