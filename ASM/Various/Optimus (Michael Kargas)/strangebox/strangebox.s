nframe:

; set supervisor
	clr.l -(a7)
	move.w #32,-(a7)
	trap #1

; save the screen address
	move.w #2,-(a7)
	trap #14
	move.l d0,a6	;a6 = vram start


mainloop:

	move nframe,d2
	addq #1,nframe
	lsr #2,d2

	moveq #0,d3
	move.l a6,a0
	move.w #$ff00,d0
	move.b #$ff,d3
	and.b #15,d2
	cmp.b #8,d2
	blt skipit
	move.b d2,d4
	moveq #16,d2
	sub.b d4,d2
skipit:

	lsr.w d2,d0
	lsl.w d2,d3
	moveq #19,d1
ribbon:
	move.l d0,(a0)+
	move.l d3,(a0)+
	dbra d1,ribbon

; expects a6 = vram start
;copyLineToScreen:
	movem.l d0-d7/a0-a6,-(a7)
	;move.l a6,d0

	move.l a6,a0
	move #3,d2
copyLineLoop:
	addq #8,a0
	move.l #49,d0
nerocopy:
	movem.l (a0)+,d3-d7/a1-a5
	move.l #3,d1
kopaniera:
		movem.l d3-d7/a1-a5,(a6)
		add.l #160,a6
	dbra d1,kopaniera

	dbra d0,nerocopy

	add.l #-200*160+40,a6

	dbra d2,copyLineLoop

	;move.l d0,a6
	movem.l (a7)+,d0-d7/a0-a6


;jsr waitVBL
	move.w #37,-(a7)
	trap #14

; check for space key
;	cmp.b #$39,$fffc02
;	bne mainloop

; Clean exit
;	clr.l -(a7)
;	trap #1


	bra mainloop



cleanAreaList:

	section data

	section bss
