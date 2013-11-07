******************************************************
**	BLOCK DRAW ROUT MADE BY MARTIN LIESEN 1990
**	WRITTEN FOR FUTURIA EDITOR
**	VERSION 2.0 AS VERSION 1.0 WERE DESTROYED
**	BEEING IN LOVE IS NOT ALWAYS EASY. HOW COULD I
**	POSSIBLE TEEL YOU ANNA. THE WORLD SUCKS....
**
**	HOW TO USE:
**		D0=NUMBER OF BLOCKS PER LINE
**		D1=LINES/16 TO DRAW
**		D2=FROM THIS NUMBER AND UP IS FAST BLOCK
**		
**		A0=ADDRESS TO FAST BLOCK (OR -1)
**		A1=ADDRESS TO NORMAL BLOCKS
**		A2=SCREEN ADDRESS TO START DRAWING AT
**		A3=MAP ADRESS TO START DRAWING FROM (LOWER RIGHT CORNER)
**
**	THE MAP GOES LEFT AND UPWARDS WITH THE INCREASE OF MEMORY
**	(BACKWARDS AS SCREEN COORDINATES)
*******************************************************
a:
begin:		movem.l	d0-d7/a0-a6,-(a7)
		moveq	#0,d3		; d3=bdelta
		moveq	#0,d4		; d4=sdelta
		cmp.w	#20,d0
		bhi.s	more_than_20		
		moveq	#20,d4		; less than equal 20 block per line
		sub.w	d0,d4
		lsl.w	#3,d4
		bra.s	delta_done
more_than_20:	move.w	d0,d3		; more than 20 blocks per line
		sub.w	#20,d3
		add.w	d3,d3
		moveq	#20,d0
delta_done:	move.w	d1,d5
		subq.w	#1,d5
		mulu	#16*160,d5
		add.w	#160-8,d5
		sub.w	d5,d4
		move.l	a0,a4		; a4 screen
		lea	(a4,d5.w),a4

		subq.w	#1,d1
		subq.w	#1,d0
all_lines:	swap	d1
		move.w	d0,d1
all_on_x:
		move.w	(a4)+,d5
		cmp.w	d2,d5
		bhs.L	fastblock

		mulu	#128,d5
		lea	(a1,d5.w),a5
		move.l	(a5)+,(a4)
		move.l	(a5)+,4(a4)
		move.l	(a5)+,160(a4)
		move.l	(a5)+,164(a4)
		move.l	(a5)+,320(a4)
		move.l	(a5)+,324(a4)
		move.l	(a5)+,480(a4)
		move.l	(a5)+,484(a4)
		move.l	(a5)+,640(a4)
		move.l	(a5)+,644(a4)
		move.l	(a5)+,800(a4)
		move.l	(a5)+,804(a4)
		move.l	(a5)+,960(a4)
		move.l	(a5)+,964(a4)
		move.l	(a5)+,1120(a4)
		move.l	(a5)+,1124(a4)
		move.l	(a5)+,1280(a4)
		move.l	(a5)+,1284(a4)
		move.l	(a5)+,1440(a4)
		move.l	(a5)+,1444(a4)
		move.l	(a5)+,1600(a4)
		move.l	(a5)+,1604(a4)
		move.l	(a5)+,1760(a4)
		move.l	(a5)+,1764(a4)
		move.l	(a5)+,1920(a4)
		move.l	(a5)+,1924(a4)
		move.l	(a5)+,2080(a4)
		move.l	(a5)+,2084(a4)
		move.l	(a5)+,2240(a4)
		move.l	(a5)+,2244(a4)
		move.l	(a5)+,2400(a4)
		move.l	(a5)+,2404(a4)

blockjoin:	subq.l	#8,a4
		dbf	d1,all_on_x
		swap	d1
		add.l	d3,a3
		sub.l	d4,a4
		dbf	d1,all_lines

		movem.l	(a7)+,d0-d7/a0-a6
		rts

*****************************************************
**	draw fast block
*****************************************************
fastblock:
		move.l	(a5)+,(a4)
		move.l	(a5)+,4(a4)
		move.l	(a5)+,d6
		move.l	(a5)+,d7
		move.l	d6,160(a4)
		move.l	d7,164(a4)
		move.l	d6,320(a4)
		move.l	d7,324(a4)
		move.l	d6,480(a4)
		move.l	d7,484(a4)
		move.l	d6,640(a4)
		move.l	d7,644(a4)
		move.l	d6,800(a4)
		move.l	d7,804(a4)
		move.l	d6,960(a4)
		move.l	d7,964(a4)
		move.l	d6,1120(a4)
		move.l	d7,1124(a4)
		move.l	d6,1280(a4)
		move.l	d7,1284(a4)
		move.l	d6,1440(a4)
		move.l	d7,1444(a4)
		move.l	d6,1600(a4)
		move.l	d7,1604(a4)
		move.l	d6,1760(a4)
		move.l	d7,1764(a4)
		move.l	d6,1920(a4)
		move.l	d7,1924(a4)
		move.l	d6,2080(a4)
		move.l	d7,2084(a4)
		move.l	d6,2240(a4)
		move.l	d7,2244(a4)
		move.l	(a5)+,2400(a4)
		move.l	(a5)+,2404(a4)
		bra.L	blockjoin
b:

