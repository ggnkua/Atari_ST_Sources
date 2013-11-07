**** Shell for Sprite rout, so that the C: command can be used instead.
*    
*  C:sprite%(l:v:sprite$,l:xbios(2),x,y)


Start:	
	lea	4(a7),a6
	move.l	(a6)+,a0
	move.l	(a6)+,a1
	move.w	(a6)+,d0
	move.w	(a6)+,d1
	bsr.s	begin
	rts



*********************************************************************
**	sprite rout for gfa basic
**	 100% pc-relative
**	made by Martin Liesen 1990
**	this programm is made for Futuria and dedicated
**	to Linda.
**
**	in:	a0=address to a sprite data
**		   could be explained like this:
**		   1  Get x1,y1,x2,y2,sp$
**		   2  a%=varptr(sp$)
**		   a% „r det v„rde som skall ligga i a0
**		   +0 bredd
**		   +2 h”jd
**		   +4 bitplanes
**		   +6 image data ((bredd/16)*8*h”jd*2*bitplanes) bytes
**		a1=address to screen that this sprite rout should use.
**		d0=x-pos
**		d1=y-pos
**
**
**	 out:		a sprite on the screen
**
**	observe:	this routin does not clip the sprites, does
**			not check the coordinates for stupid
**			coordinates or odd addresses
**			this routine thinks that the screen is
**			four bitplanes, althought it ain't.
********************************************************************
begin:		movem.l	d0-d7/a0-a6,-(a7)
		mulu	#160,d1
		move.w	d0,d2
		and.w	#$FFF0,d2
		lsr.w	#3,d2
		mulu	4(a0),d2
		add.w	d2,d1
		lea	(a1,d1.w),a2		; a2=address to draw sprite at
		and.w	#$F,D0			; d0=x rotate

		move.w	#319,d7
		sub.w	(a0),d7
		and.w	#$fff0,d7		; d0=add x
		lsr.w	#1,d7
		swap	d0
		move.w	d7,d0
		swap	d0

		move.w	2(a0),d1		; lines-1
		lea	6(a0),a3
loopline:
		move.w	(a0),d2
		add.w	#15,d2
		and.w	#$fff0,d2		; width/16 round up
		lsr.w	#4,d2
		subq.w	#1,D2

loopwordpar:
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		move.w	(A3)+,D3
		move.w	(A3)+,D4
		move.w	(A3)+,D5
		move.w	(A3)+,D6

		ror.l	d0,d3
		ror.l	d0,d4
		ror.l	d0,d5
		ror.l	d0,d6

		move.l	d3,d7
		or.l	d4,d7
		or.l	d5,d7
		or.l	d6,d7
		not.l	d7

		and.w	d7,(a2)
		and.w	d7,2(a2)
		and.w	d7,4(a2)
		and.w	d7,6(a2)
		or.w	d3,(a2)+
		or.w	d4,(a2)+
		or.w	d5,(a2)+
		or.w	d6,(a2)+

		swap	d3
		swap	d4
		swap	d5
		swap	d6
		swap	d7

		and.w	d7,0(a2)
		and.w	d7,2(a2)
		and.w	d7,4(a2)
		and.w	d7,6(a2)
		or.w	d3,(a2)
		or.w	d4,2(a2)
		or.w	d5,4(a2)
		or.w	d6,6(a2)

		dbf	d2,loopwordpar

		swap	d0
		lea	(a2,d0.w),a2
		swap	d0
		dbf	d1,loopline
		movem.l	(a7)+,d0-d7/a0-a6
		rts


