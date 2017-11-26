fade_in_pal:
* a0 = original pal
* a1 = where to fade at!

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	move.l	a1,a0
	lea	32(a1),a1

* set up counter
	moveq	#15-1,d7	; max 16 palettes!

.fade_once:

	moveq	#16-1,d6	; no of colours
.fade_pal:
	move.w	(a0)+,d0

	move.w	d0,d1
	move.w	d0,d2
	and.w	#$00f,d0
	and.w	#$0f0,d1
	lsr.w	#4,d1
	lsr.w	#8,d2


fadin	macro
	btst	#3,\1
	bne.s	.\@add_it

	bset	#3,\1
	bra.s	.\@dun_it

.\@add_it:
	cmp.w	#$f,\1
	beq.s	.\@dun_it

	addq.w	#1,\1
	bclr	#3,\1

.\@dun_it:
	endm


	fadin	d0
	fadin	d1
	fadin	d2


	lsl.w	#4,d1
	lsl.w	#8,d2
	or.w	d2,d1
	or.w	d1,d0

	move.w	d0,(a1)+
	dbra	d6,.fade_pal

	dbra	d7,.fade_once
	rts

fade_a_pal:
* a0 = original pal
* a1 = where to fade at!

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)	; copy original palette
	move.l	a1,a0		; get addres of palette 1
	lea	32(a1),a1	; and palette 2

* set up counter
	moveq	#15-1,d7	; max 16 palettes!

.fade_once:

	moveq	#16-1,d6	; no of colours
.fade_pal:
	move.w	(a0)+,d0	; take colour to fade

	move.w	d0,d1
	move.w	d0,d2
	and.w	#$00f,d0
	and.w	#$0f0,d1
	lsr.w	#4,d1
	lsr.w	#8,d2		; seperate out RED GREEN and BLUE


fad	macro
	btst	#3,\1
	beq.s	.\@sub_it	; branch if STe bit not set

	bclr	#3,\1		; else clear it and finished
	bra.s	.\@dun_it

.\@sub_it:
	tst.w	\1
	beq.s	.\@dun_it	; branch if already 0

	subq.w	#1,\1		; else take off 1
	bset	#3,\1		; and set STe bit

.\@dun_it:
	endm


	fad	d0
	fad	d1
	fad	d2		; fade RED GREEN and BLUE


	lsl.w	#4,d1
	lsl.w	#8,d2
	or.w	d2,d1
	or.w	d1,d0		; combine them again

	move.w	d0,(a1)+	; store as new colour in next palette
	dbra	d6,.fade_pal	; fade all colours

	dbra	d7,.fade_once	; do all 16 palettes
	rts
