
;'Flappybird' title screen

	SECTION	TEXT
	
;----------------------------------
;Initialise 'Flappybird' screen
titleinit
	moveq.w	#0,d0
	move.w	d0,titlewavebasey
	move.w	d0,titlewave
	rts
	
;----------------------------------
;Reset for 'Flappybird' screen
titlereset
	bsr		birdreset						;Reset bird
	move.w	#144,birdx
	moveq.w	#82,d0
	move.w	d0,birdy
	move.w	d0,titlewavebasey
	moveq.w	#0,d0
	move.w	d0,titlewave
	move.w	d0,exitcount
	bra		birdrandompalette				;(does RTS)

;----------------------------------
;Repair screen after exit
titlerepaironexit
	move.l	#160*81+72,d0					;Screen offset
	bra		titleclearbird					;(does RTS)
	
;----------------------------------
;'Flappybird' screen handler
titlehandler
	move.w	#RASTERSET_TITLE,nextrasterset

	bsr		titledrawflappybird
	bsr		titleanimbird
	move.l	#160*81+72,d0					;Screen offset
	bsr		titleclearbird
	bsr		birddraw
	bsr		floorupdate

	move.w	flapbutton,d0					;Read input
	beq.s	.noinput
	lea		gameoversfx,a0
	bsr		soundplay0
	bsr		getreadyreset
	move.l	#getreadyhandler,handler
.noinput
	rts

;----------------------------------
;Draw 'Flappybird' logo
titledrawflappybird					;6064 cycles, 11.8 rasters
	lea		flappybirdimg,a0		;12
	move.l	offscreenbse,a1			;20
	lea		160*38+48(a1),a1		;8

	moveq.w	#32-1,d7				;4
.loop
	movem.l	(a0)+,d0-d6/a2			;76		;Planes 1+2 for 128 pixels
	move.l	d0,(a1)					;8
	move.l	d1,8(a1)				;12
	move.l	d2,16(a1)				;12
	move.l	d3,24(a1)				;12
	move.l	d4,32(a1)				;12
	move.l	d5,40(a1)				;12
	move.l	d6,48(a1)				;12
	move.l	a2,56(a1)				;12
	lea		160(a1),a1				;8		;Next screen line
	dbra.w	d7,.loop				;10/14
	rts

;----------------------------------
;Clear background behind animating bird, pass d0.w as screen offset
titleclearbird						;840  cycles, 1.6 rasters
	move.l	offscreenbse,a0			;20
	add.w	d0,a0					;8		;Offset to screen

	move.l	#$ffff0000,d0			;12		;Sky, colour index 1
	moveq.l	#0,d1					;4
	move.l	d0,d2					;4
	move.l	d1,d3					;4
	
	movem.l	d0-d3,(a0)				;40		;Clear 18 lines
	movem.l	d0-d3,160(a0)			;44
	movem.l	d0-d3,320(a0)
	movem.l	d0-d3,480(a0)
	movem.l	d0-d3,640(a0)
	movem.l	d0-d3,800(a0)
	movem.l	d0-d3,960(a0)
	movem.l	d0-d3,1120(a0)
	movem.l	d0-d3,1280(a0)
	movem.l	d0-d3,1440(a0)
	movem.l	d0-d3,1600(a0)
	movem.l	d0-d3,1760(a0)
	movem.l	d0-d3,1920(a0)
	movem.l	d0-d3,2080(a0)
	movem.l	d0-d3,2240(a0)
	movem.l	d0-d3,2400(a0)
	movem.l	d0-d3,2560(a0)
	movem.l	d0-d3,2720(a0)
	rts
	
;----------------------------------
;Animate bird
titleanimbird
	move.w	titlewave,d0					;Increment sine wave index
	addq.w	#1,d0
	move.w	d0,titlewave
	lea		titlewavey,a0					;Set bird Y for sine wave
	and.w	#$3e,d0
	move.w	titlewavebasey,d1
	add.w	titlewavey(pc,d0.w),d1
	move.w	d1,birdy
	bra		birdanim						;(does RTS)

;----------------------------------

titlewavey
	dc.w	0,+1,+1,+2,+2,+2,+3,+3,+3,+3,+3,+2,+2,+2,+1,+1
	dc.w	0,-1,-1,-2,-2,-2,-3,-3,-3,-3,-3,-2,-2,-2,-1,-1

;----------------------------------

	SECTION	BSS

titlewavebasey		ds.w	1				;Base Y sine wave
titlewave			ds.w	1				;Index for Y sine wave
