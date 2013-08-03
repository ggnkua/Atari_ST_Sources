*
* This routine draws a true colour sprite. It draws both
* packed and unpacked sprites. Clipping isn't supported yet.
* The sprite must be created using the Spooky Sprites sprite creator.
*
* Made by Johan Karlsson (d92jk@efd.lth.se)
*
*
* In	a0.l=address to sprite file
*	a1.l=screenadr
*	d0.l=sprite nbr.
*	d1.l=xpos
*	d2.l=ypos
*	xres equ screenwidth in pixels
*	yres equ height of display
*	(destroys d0-d7/a0-a3)
*


@truespr	move.l	a0,a3
		add.l	#10,a0
		move	d0,d3
		asl	#3,d0
		add	d3,d0
		add	d3,d0
		add.l	d0,a0
	
		tst	d2
		blt	.minusy
		tst	d1
		blt	.minusx
		moveq	#0,d3
		move.b	(a0),d3
		add	d1,d3
		cmp	#xres,d3
		bgt	.plusx
		moveq	#0,d3
		move.b	1(a0),d3
		add	d2,d3
		cmp	#yres,d3
		bgt	.plusy
		
.noclip	
		ifeq	xres-768
		lsl.l	#8,d2
		add.l	d2,a1
		add.l	d2,a1
		lsl.l	#2,d2
		add.l	d2,a1
		endc
		ifne	xres-768
		mulu	#xres*2,d2
		add.l	d2,a1
		endc

		add.l	d1,a1
		add.l	d1,a1
	
		move.l	6(a0),a2
		tst.l	a2
		beq	.unpacked


.packed		add.l	a3,a2
		move	(a2)+,d3
		moveq	#0,d4
.loop1		move	(a2)+,d4
		add.l	d4,a1
		move	(a2)+,d5
.loop2		move	(a2)+,(a1)+
		dbra	d5,.loop2
		dbra	d3,.loop1
		rts
	
	
.unpacked
		moveq	#0,d3
		move.b	1(a0),d3
		subq	#1,d3
		moveq	#0,d4
		move.b	(a0),d4
		move.l	#xres*2,d7
		sub	d4,d7
		sub	d4,d7
		sub	#1,d4
		move.l	2(a0),a2	
		add.l	a3,a2
.loopen
		move	d4,d5
.loop		move	(a2)+,d6
		beq	.tran
		move	d6,(a1)+
		dbra	d5,.loop
		add.l	d7,a1
		dbra	d3,.loopen
		rts	
.tran		addq.l	#2,a1
		dbra	d5,.loop
		add.l	d7,a1
		dbra	d3,.loopen
		rts


.minusy		rts
.plusy		rts
.minusx		rts
.plusx		rts

