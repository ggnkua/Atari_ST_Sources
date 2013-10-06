* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991 systm_05.s				*
* 		routines for Chapter 12				*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	include	systm_02.s
	include	systm_03.s
	include	systm_04.s
init_vars:
* set up the screens
	bsr	set_up
* set the view point
	move.w	#100,oposx
	clr.w	oposy
	clr.w	oposz
* and the clip frame
	move.w	#50,xmin
	move.w	#270,xmax
	move.w	#30,ymin
	move.w	#170,ymax
* Set up view frame base vectors
* 1. iv
	lea	iv,a0		align 
	move.w	#16384,(a0)+	view
	move.w	#0,(a0)+		frame
	move.w	#0,(a0)		axes
* 2. jv
	lea	jv,a0		with
	clr.w	(a0)+		the
	move.w	#16384,(a0)+	world
	clr.w	(a0)		frame
* 3. kv
	lea	kv,a0		axes
	move.w	#0,(a0)+
	clr.w	(a0)+
	move.w	#16384,(a0)
flg_init:
* Initialize flags and other variables
	clr.w	speed 		start off at rest
	clr.w	screenflag	0=screen 1 draw, 1=screen 2 draw
	clr.w	viewflag
* Move the view point to -300 on the view frame z axis
	lea	persmatx,a0
	move.w	#300,d0
	move.w	d0,(a0)
	move.w	d0,10(a0)
	move.w	d0,30(a0)
	rts
swap_scn:
	tst.w	screenflag	screen 1 or screen2?
	beq	screen_1	draw on screen 1, display screen2
	bsr	draw2_disp1	draw on screen 2, display screen1
	bsr	clear2		but first wipe it clean
	clr.w	screenflag	and set the flag for next time
	bra	screen_2
screen_1:
	bsr	draw1_disp2	draw on 1, display 2
	bsr	clear1		but first wipe it clean
	move.w	#1,screenflag	and set the flag for next time
screen_2:
	rts

	