
;Debug font

	SECTION	TEXT

;----------------------------------
;Draw font, pass a0.l as string, a1.l as screen
fontdraw
	lea		font,a2
	move.w	a1,d0							;Test if screen address is odd or even
	btst	#0,d0
	bne.s	.odd							;Start on odd byte
.loop
	moveq.w	#0,d0							;Draw 'even' character
	move.b	(a0)+,d0						;Read string character 0...255
	beq.s	.done							;End on '\0'
	sub.w	#32,d0							;Ignore character outside 32...128
	ble.s	.skipeven
	cmp.w	#128-32,d0
	bge.s	.skipeven
	lsl.w	#5,d0							;Each character is 32 bytes
	movem.l	(a2,d0.w),d0-d7					;Read 8 lines of font data
	movep.l	d0,(a1)
	movep.l	d1,160(a1)
	movep.l	d2,320(a1)
	movep.l	d3,480(a1)
	movep.l	d4,640(a1)
	movep.l	d5,800(a1)
	movep.l	d6,960(a1)
	movep.l	d7,1120(a1)
.skipeven
	addq.w	#1,a1							;Next character on screen

.odd
	moveq.w	#0,d0							;Draw 'odd' character
	move.b	(a0)+,d0
	beq.s	.done
	sub.w	#32,d0
	ble.s	.skipodd
	cmp.w	#128-32,d0
	bge.s	.skipodd
	lsl.w	#5,d0
	movem.l	(a2,d0.w),d0-d7
	movep.l	d0,(a1)
	movep.l	d1,160(a1)
	movep.l	d2,320(a1)
	movep.l	d3,480(a1)
	movep.l	d4,640(a1)
	movep.l	d5,800(a1)
	movep.l	d6,960(a1)
	movep.l	d7,1120(a1)
.skipodd
	addq.w	#7,a1							;Next character on screen
	bra.s	.loop
.done
	rts

;----------------------------------

	SECTION	DATA

font										;96 characters, each 8x8 or 16 bytes
	INCBIN	"\SRC\DATA\FONT.DAT"
