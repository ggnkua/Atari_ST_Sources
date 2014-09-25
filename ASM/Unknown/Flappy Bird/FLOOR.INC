
;Scrolling floor

	SECTION	TEXT

;----------------------------------
;Initialise floor scroller
floorinit
	move.w	#0,floorx
	rts

;----------------------------------
;Scroll floor offset by a pixel
floorupdate							;52-58 cycles
	move.w	floorx,d0				;16		;Increment floor X scroll, wrap 0...12
	addq.w	#1,d0					;4
	cmp.w	#12,d0					;8
	bgt.s	.wrap					;10/8
	move.w	d0,floorx				;16
	rts
	
.wrap
	move.w	#0,floorx				;20		;Wrap
	rts

;----------------------------------
;Draw line of floor to screen, 320 cycles
FLOORDRAWLINE	MACRO
	move.w	(a0)+,\1(a1)			;16		;Copy line to Plane 1
	move.w	(a0)+,\1+8(a1)					;This is faster than using MOVEM
	move.w	(a0)+,\1+16(a1)
	move.w	(a0)+,\1+24(a1)
	move.w	(a0)+,\1+32(a1)
	move.w	(a0)+,\1+40(a1)
	move.w	(a0)+,\1+48(a1)
	move.w	(a0)+,\1+56(a1)
	move.w	(a0)+,\1+64(a1)
	move.w	(a0)+,\1+72(a1)
	move.w	(a0)+,\1+80(a1)
	move.w	(a0)+,\1+88(a1)
	move.w	(a0)+,\1+96(a1)
	move.w	(a0)+,\1+104(a1)
	move.w	(a0)+,\1+112(a1)
	move.w	(a0)+,\1+120(a1)
	move.w	(a0)+,\1+128(a1)
	move.w	(a0)+,\1+136(a1)
	move.w	(a0)+,\1+144(a1)
	move.w	(a0)+,\1+152(a1)
	ENDM

;----------------------------------
;Draw floor to Plane 1 (Plane 4 is already set giving colours 8+9)
floordraw							;2008 cycles, 3.9 rasters
	lea		flooranimimg,a0			;12
	move.l	offscreenbse,a1			;20

	move.w	floorx,d0				;16		;Read floor X scroll
	lsl.w	#3,d0					;12		;*8
	move.w	d0,d1					;4
	lsl.w	#2,d0					;12		;*32
	add.w	d1,d0					;4		;=*40
	add.w	d0,a0					;8		;Source of floor animation
	
	FLOORDRAWLINE	160*162			;320
	FLOORDRAWLINE	160*163
	FLOORDRAWLINE	160*164
	FLOORDRAWLINE	160*165
	FLOORDRAWLINE	160*166
	FLOORDRAWLINE	160*167
	rts

;----------------------------------

	SECTION	BSS

floorx			ds.w	1					;Floor X scroll position
