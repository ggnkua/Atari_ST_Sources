STARS_NUM = 127

;jsr initialise
; set supervisor
	clr.l -(a7)
	move.w #32,-(a7)
	trap #1
;	addq #6,a7

; save the screen address
	move.w #2,-(a7)
	trap #14
;	addq #2,a7
	move.l d0,a6

; change to low

	moveq.l #0,d1
	move.w d1,-(a7)
	subq.l #1,d1
	move.l d1,-(a7)
	move.l d1,-(a7)

	move.w #5,-(a7)		; change screen
	trap #14
;	add.l #12,a7

;jsr initStars

	move.l #starsPos,a5

initStars:
	move.l a5,a4
	moveq #STARS_NUM,d4
initStarsLoop:
	moveq #3,d6
XYZloop:
;jsr getRandomNum
	move.w #17,-(a7)
	trap #14
;	addq #2,a7

	move d0,d5
	and #255,d5

	cmp #1,d6
	beq lastIsZpos
	sub #128,d5
lastIsZpos:

	move d5,(a4)+
	subq #1,d6
	bne XYZloop

	subq #1,d4
	bne initStarsLoop


	move.l #$00000777,$ffff8240

mainloop:

	move.l #cleanArea1,a4

	move.l a5,a2
	move #STARS_NUM,d7
loopN:
	move.w (a2)+,d1
	move.w (a2)+,d0
	move.w (a2),d2

; move on Z
	subq #1,d2
	and #127,d2
	move.w d2,(a2)+

	or d2,d2
	beq skipStar

	ext.l d0
	ext.l d1
	asl.l #6,d0
	asl.l #6,d1

; projection
	divs d2,d0
	divs d2,d1

	add #160,d1
	add #100,d0

	cmp #320,d1
	bge skipStar
	cmp #0,d1
	ble skipStar
	cmp #200,d0
	bge skipStar
	cmp #0,d0
	ble skipStar

	;put pixel
	move.l a6,a0
	mulu #160,d0

	move d1,d3
	asr #4,d3
	asl #3,d3
	add d3,d0
	add.w d0,a0

	and #15,d1
	move.l #32768,d2
	asr.l d1,d2

	or.w d2,(a0)
	move.l a0,(a4)+	

skipStar:
	subq #1,d7
	bne loopN

; mark last point with zero
	move.l d7,(a4)+	

;jsr waitVBL
	move.w #37,-(a7)
	trap #14
;	addq #2,a7

;jsr dotsClean
	move.l #cleanArea1,a0
	moveq #0,d0
dotsCleanLoop:
	move.l (a0)+,a1
	cmp.l d0,a1	; is last point to clear?
	beq oof
	move.l d0,(a1)
	bra dotsCleanLoop
oof:


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

cleanArea1:
	ds.l 256
cleanArea2:
	ds.l 256
starsPos:
	ds.w 768 