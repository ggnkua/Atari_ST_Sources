***************************************************************************
*               TERMINATOR of NOW 5 Fullscreen Version 1.0                *
***************************************************************************

start		clr.l	-(sp)       
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack 	save stack
	        movem.l	$ffff8240.w,d0-d7	save palette
         	movem.l	d0-d7,palette 
         	move.l	$44e.w,old44e
		dc.w	$a00a		mouse off
		move.w	#15754,D0   	loop counter:screen size
 		lea	$78000+160,A0 	Address of screen +160 
*		 			for Top border blank	
		lea	fullpic+34,A1 	Source fullpic
drawfull	move.l	(A1)+,(A0)+	Draw the screen
		dbf	D0,drawfull
		movem.l	fullpic+2,D0-D7		Get palette
		movem.l	D0-D7,$ffff8240.w	Set palette
		move.b	#7,$ffff8201.w		Set screen Address

		jsr	Fullscreen

		move.l	#$8080000,$ffff8800.w
		move.l	#$9090000,$ffff8800.w
		move.l	#$a0a0000,$ffff8800.w

		movem.l	palette,d0-d7
		movem.l	d0-d7,$ffff8240.w
	
		move.l	old44e,$44e.w
	
		move.l	stack,-(sp)
		move.w	#32,-(sp)
		trap	#1
		lea	6(sp),sp

		clr.w	-(sp)
		trap	#1
 		
Fullscreen	dc.w	$a00a
		lea	$fffffa13.w,a6
		move.b	(a6),d7
		move.b	2(a6),d6
		clr.b	(a6)
		clr.b	2(a6)
		lea	$ffff8260.w,a0
		lea	$ffff820a.w,a1
		lea	$ffff8209.w,a2
		move.b	(a1),d5
		clr.b	d0
		moveq.w	#2,d1
		lea	$70.w,a5	vertical blank
		movea.l	(a5),a4		save in a4
		lea	Fullblank,a3	get address of my vbl
		move.l	a3,(a5)		install
		
		move.b	#$39,d4		wait for space
		lea	$fffffC02.W,a3
waitspace	cmp.b	(a3),d4
		bne.s	waitspace
		
		move.l	a4,(a5)		restore vectors
		move.b	d5,(a1)
		move.b	d6,2(a6)
		move.b	d7,(a6)
		rts
		
Fullblank	dcb.w	4311,$4e71	Top Border Pause
		move.b	#16,d2		sync data
		move.b	d0,(a1)		60Hz
		dcb.w	8,$4e71
		move.b	d1,(a1)		50Hz
syncscan	move.b	(a2),d3		get scanline data
		beq.s	syncscan	sync
		sub.b	d3,d2
		lsl.b	d2,d3
		
		dcb.w	97,$4e71
* Scanline 1,2nd line 1st 'Fulline'
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 2	 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 3
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 4		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 5
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 6
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 7	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 8	 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 9
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 10		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 11
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 12	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 13	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 14		 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 15
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 16		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 17
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 18	 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 19
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 20	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 21
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 22
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 23 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 24 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 25
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 26		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 27
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 28	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 29	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 30		 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 31
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 32		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 33
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 34 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 35
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 36	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 37
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 38
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 39 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 40 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 41
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 42		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 43
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
	 	
* Scanline 44	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 45	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 46		 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 47
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 48		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 49
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 50	 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 51
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 52	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 53
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 54
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 55 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 56 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 57
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 58		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 59
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 60	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 61	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 62		 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 63
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 64		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 65
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 66
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 67	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 68 
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 69
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 70
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w	$4e71
		endr
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 72
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 73
	 	move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 74
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 75
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 76
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 77 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 78
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 79	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 80
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 81
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 82 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 83 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 84
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 85		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 86
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 87	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 88	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 89		 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 90
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 91		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 92
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 93	 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 94
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 95	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 96
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 97
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 98 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 99 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 100
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 101	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 102
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 103 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 104
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 105	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 106
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 107	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 108
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 109
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 110
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 111
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 112
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 113
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 114	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 115
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 116
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 117	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 118
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 119 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 120
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 121	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 122
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 123	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 124
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 125 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 126
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 127
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 128
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 129
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 130	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 131
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 132
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 133	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 134
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 135 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 136
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 137	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 138
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 139	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 140
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 141
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 142 	
	 	move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 143
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 144
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 145
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 146
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w	$4e71
		endr
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 147
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 148
	 	move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 149
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 150
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 151
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 152
	 	move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 153
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 154
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 155
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	89
		dc.w $4e71
		endr
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w $4e71
		endr
		move.b	d1,(a0)		
		dc.w $4e71			
		move.b	d0,(a0)		
		rept	12
		dc.w $4e71
		endr
* Scanline 156
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 157 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 158
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 159	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 160
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 161
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 162 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 163 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 164
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 165	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 166
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 167 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 168
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 169	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 170
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 171	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 172
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 173 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 174
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 175
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 176
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 177
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 178	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 179
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 180
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 181	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 182
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
	 	
* Scanline 183 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 184
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 185	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 186
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 187	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 188
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 189
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 190
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 191
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 192
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 193
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 194	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 195
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 196
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 197	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 198
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 199 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 200
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 201	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 202
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 203		
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 204
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 205 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 206
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 207
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 208
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 209
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 210	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 211
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 212
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 213	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 214
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 215 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 216
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 217	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 218
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 219	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 220
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 221
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 222 	
	 	move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 223
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 224
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 225
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 226
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w	$4e71
		endr
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 227
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		rept	13
		dc.w	$4e71
		endr
		move.b	d1,(a0)		
		dc.w	$4e71			
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Bottom Border 228
	 	move.b	d1,(a0)		High Res
	 	dc.w $4e71
	 	move.b	d0,(a0)		Low Res
	 	rept	89
	 	dc.w $4e71
	 	endr
	 	move.b	d0,(a1)		60 hz
	 	move.b	d1,(a1)		50 hz
	 	rept	13
	 	dc.w $4e71
	 	endr
	 	move.b	d1,(a0)		High Res
	 	dc.w $4e71
	 	move.b	d0,(a0)		Low Res
	 	dc.w $4e71
	 	move.b	d0,(a1)		60 hz
	 	rept	7
	 	dc.w $4e71
	 	endr
	 	move.b	d1,(a1)		50 hz
* Scanline 229
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 230 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 231
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 232	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 233
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 234
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 235 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 236 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 237
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 238	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 239
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 240 	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 241
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 242	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 243
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 244	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 245
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 246 
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 247
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 248
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 249
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 250
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 251	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 252
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 253
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 254	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 255
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 256 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 257
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 258	 	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 259
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 260	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 261
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
	 	dcb.w	12,$4e71
* Scanline 262
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 263
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 264
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 265
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 266
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 267	
	 	move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 268
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 269
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
* Scanline 270	
		move.b	d1,(a0)		
		dc.w	$4e71
		move.b	d0,(a0)		
		dcb.w	89,$4e71
		move.b	d0,(a1)		
		move.b	d1,(a1)		
		dcb.w	13,$4e71
		move.b	d1,(a0)		
		dc.w	$4e71	
		move.b	d0,(a0)		
		dcb.w	12,$4e71
		
		bsr	music
		
		rte
		
music		movem.l	d0-d7/a0-a6,-(sp)
		move.b	#$7,$ffff8800.w
		move.b	#%11111000,$ffff8802.w
		cmp.b	#1,fl
		beq.s	ppp
		bsr	sset
ppp		lea	_note0,a0
		lea	_note1,a1
		lea	_note2,a2
chan0    	move.w	pnt0,d0 
		add.w	d0,a0
		move.l	(a0),d1       *get note 0 & duration   
		cmp.w	#$ffff,d1
		bne.s	con2
		clr.w	pnt0                *reset to start
		move.l	_note0,d1
con2		sub.w	#1,np0
		bne.s	stillon
		move.l	d1,tmp0          *d1.w is duration
		move.w	tmp0,tmp00
		move.b	#15,vol0
		move.w	d1,np0             *set new duration
		add.w	#4,pnt0             *& inc pointer
stillon		cmp.w	#0,tmp00
		bne.s	rff 
		move.w	tmp0,tmp00
rff		cmp.b	#0,vol0
		beq.s	nv0
		sub.b	#1,vol0+1
		bne.s	nv0
		sub.b	#1,vol0
		move.b	#5,vol0+1
nv0		move.b	#8,$ffff8800.w
		move.b	vol0,$ffff8802.w
		move.b	#0,$ffff8800.w
		move.b	tmp00+1,$ffff8802.w
		move.b	#1,$ffff8800.w
		move.b	tmp00,$ffff8802.w
chan1		move.w	pnt1,d0
		add.w	d0,a1
		move.l	(a1),d1       *get note 1 & duration   
		cmp.w	#$ffff,d1
		bne.s	bon3
		clr.w	pnt1                *reset to start
		move.l _note1,d1
bon3 		sub.w	#1,np1
		bne.s	still
		move.l	d1,tmp1          *d1.w is duration
		move.b	#14,vol1
		move	d1,np1             *set new duration
		add.w	#4,pnt1             *& inc pointer
still		cmp.b	#0,vol1
		beq.s	nv1
		sub.b	#1,vol1+1
		bne.s	nv1
		sub.b	#1,vol1
		move.b	#3,vol1+1
nv1		move.b	#9,$ffff8800.w
		move.b	vol1,$ffff8802.w
		move.b	#2,$ffff8800.w
		move.b	tmp1+1,$ffff8802.w
		move.b	#3,$ffff8800.w
		move.b	tmp1,$ffff8802.w
		move.b	#6,$ffff8800.w
		move.b	tmp1+1,d0
		lsr.b	#1,d0
		move.b	d0,$ffff8802.w
chan2		move.w	pnt2,d0 
		add.w	d0,a2
		move.l	(a2),d1       *get note 1 & duration   
		cmp.w	#$ffff,d1
		bne.s	con3
		clr.w	pnt2                *reset to start
		move.l	_note2,d1
con3 		sub.w	#1,np2
		bne.s	sti              
		move.l	d1,tmp2          *d1.w is duration
		move.b	#15,vol2
		move.w	d1,np2             *set new duration
		add.w	#4,pnt2             *& inc pointer
sti 		cmp.b	#0,vol2
		beq.s	nnn
		sub.b	#1,vol2+1
		bne.s	nnn
		sub.b	#1,vol2
		move.b	#11,vol2+1
nnn		move.w	vib2+2,d0
		add.w	d0,vib2
		cmp.w	#2,vib2
		bne.s	dd
		neg.w	vib2+2
dd		cmp.w	#-2,vib2
		bne.s	nv
		neg.w	vib2+2
nv 		move.w	tmp2,tmp22
		move.w	vib2,d0
		add.w	d0,tmp22
		move.b	#10,$ffff8800.w
		move.b	vol2,$ffff8802.w
		move.b	#4,$ffff8800.w
		move.b	tmp22+1,$ffff8802.w
		move.b	#5,$ffff8800.w
		move.b	tmp22,$ffff8802.w
cd		movem.l (sp)+,d0-d7/a0-a6
		rts

sset		move _note0+2,np0
		move _note1+2,np1
		move _note2+2,np2
		move.b #1,fl
		rts

		section	data

pnt0		dc.w	0
pnt1		dc.w	0
pnt2		dc.w	0
tmp0		dc.l	0
tmp1		dc.l	0
tmp2		dc.l	0
tmp22		dc.w	0
tmp00		dc.w	0
np0		dc.w	0
np1		dc.w	0
np2		dc.w	0
fl		dc.b	0   
		dc.b	0  
		dc.b	2,0
vol0		dc.b	15,3
vol1		dc.b	15,4
vol2		dc.b	15,2
vib2		dc.w	0,1
*	Data for Music
*	note 1st word	duration 2nd word 
*	start data with	0,1
*	data with	$ffff,$ffff,0

_note0		dc.w	0,1
		dc.w	108*4,12,108*4,06,108*4,06
		dc.w	108*4,12,108*4,06,108*4,06
		dc.w	108*4,12,162*4,12,128*4,12
		dc.w	108*4,12,121*4,12,121*4,06
		dc.w	121*4,06,121*4,12,121*4,06
		dc.w	121*4,06,121*4,12,182*4,12
		dc.w	144*4,12,121*4,12,108*4,12
		dc.w	108*4,06,108*4,06,108*4,12
		dc.w	108*4,06,108*4,06,108*4,12
		dc.w	096*4,12,091*4,12,081*4,12
		dc.w	091*4,12,108*4,12,121*4,12
		dc.w	144*4,12,162*4,24,162*4,24
		dc.w	108*4,24,108*4,18,108*4,06
		dc.w	108*4,12,162*4,12,128*4,12
		dc.w	108*4,12,121*4,24,121*4,18
		dc.w	121*4,06,121*4,12,182*4,12
		dc.w	144*4,12,121*4,12,108*4,24
		dc.w	108*4,18,108*4,06,108*4,12
		dc.w	096*4,12,091*4,12,081*4,12
		dc.w	091*4,12,108*4,12,121*4,12
		dc.w	144*4,12,162*4,24,162*4,24
		dc.w	$ffff,$ffff,0

_note1		dc.w	0,1
		dc.w	108*1,12,096*1,12,108*1,12
		dc.w	114*1,12,108*1,48,121*1,12
		dc.w	108*1,12,121*1,12,128*1,12
		dc.w	121*1,48,108*1,12,096*1,12
		dc.w	108*1,12,114*1,12,108*1,48
		dc.w	121*1,12,144*1,12,162*1,12
		dc.w	182*1,12,162*1,24,162*1,24
		dc.w	108*2,12,096*2,12,108*2,12
		dc.w	114*2,12,108*2,48,121*2,12
		dc.w	108*2,12,121*2,12,128*2,12
		dc.w	121*2,48,108*2,12,096*2,12
		dc.w	108*2,12,114*2,12,108*2,48
		dc.w	121*2,12,144*2,12,162*2,12
		dc.w	182*2,12,162*2,12,217*2,12
		dc.w	162*2,24
		dc.w	$ffff,$ffff,0
		
_note2		dc.w	0,1
		dc.w	108*8,12,108*16,12,162*8,24
		dc.w	108*8,24,162*8,24,121*8,12
		dc.w	121*16,12,182*8,24,121*8,24
		dc.w	182*8,24,108*8,12,108*16,12
		dc.w	162*8,24,108*8,12,108*8,12
		dc.w	162*8,24,121*8,12,121*8,12
		dc.w	182*8,24,162*8,24,162*8,24
		dc.w	108*8,12,108*16,12,162*8,24
		dc.w	108*8,24,162*8,24,121*8,12
		dc.w	121*16,12,182*8,24,121*8,24
		dc.w	182*8,24,108*8,12,108*16,12
		dc.w	162*8,24,108*8,24,162*8,24
		dc.w	121*8,12,81*8,12,182*8,12
		dc.w	121*8,12,162*8,24,162*8,24
		dc.w	$ffff,$ffff,0
		
fullpic		incbin	"apresent.kid"
		section bss
		
palette		ds.w	16
old44e		ds.l	1
		ds.l	200
stack		ds.l	2
