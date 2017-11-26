* Sprite pre-shifter
* by James Ingram, March 1994

pre_shift:
* enter with:
* a0 = addr of sprite
* a1 = addr to put pre-shifted sprites
*	((whole sprite length +8)  * 16)
* d0 = no of words in sprite line
* d1 = sprite height

* first, copy original sprite to 1st sprite area
* but with blank words at right...

	move.l	a1,a2		; keep addr of 1st sprite

	move.w	d1,d6
	subq.w	#1,d6
.copyall:
	move.w	d0,d7
	subq.w	#1,d7
.copyline:
	move.w	(a0)+,(a2)+
	dbra	d7,.copyline
	
	clr.l	(a2)+
	clr.l	(a2)+

	dbra	d6,.copyall

* now a2 = addr of 2nd sprite
* a1 = addr of 1st sprite

* add 4 to d0 to include new blank words
	addq.w	#4,d0

* now I rotate 15 times

	moveq	#15-1,d7

.sprite:
* do all lines
	move.w	d1,d6
	subq.w	#1,d6

.line:
* do 1 line

	move.l	a2,a3		; keep start of line addr

* copy old line
	move.w	d0,d5
	subq.w	#1,d5
.ccc:
	move.w	(a1)+,(a2)+
	dbra	d5,.ccc

* now rotate it, plane by plane...
	moveq	#4-1,d5
.plane:
	move.l	a3,a4		; keep plane addr

	move.w	d0,d4		; no of words
	lsr.w	#2,d4		; /4 for no of words in plane
	subq.w	#1,d4

	moveq	#0,d3
.word:
	move.w	(a3),d2
	roxr.w	#1,d3		; get last word's bit
	roxr.w	#1,d2		; shift sprite word
	roxl.w	#1,d3		; keep the lost bit
	move.w	d2,(a3)		; put in new sprite word
	addq.l	#8,a3		; go to next word in plane

	dbra	d4,.word

* go back to start of sprite line
	addq.l	#2,a4		; next plane
	move.l	a4,a3

	dbra	d5,.plane

	dbra	d6,.line
	dbra	d7,.sprite

	rts


pre_shift_mask:
* a0 = mask address
* a1 = address to put preshifted mask
*	((whole mask length +2)  * 16)
* d0 = no of words in mask line
* d1 = mask height

* first, copy original mask to 1st mask area
* but with blank words at right...

	move.l	a1,a2		; keep addr of 1st mask

	move.w	d1,d6
	subq.w	#1,d6
.copyall:
	move.w	d0,d7
	subq.w	#1,d7
.copyline:
	move.w	(a0)+,(a2)+
	dbra	d7,.copyline
	
	clr.w	(a2)+

	dbra	d6,.copyall

* now a2 = addr of 2nd mask
* a1 = addr of 1st mask

* add 1 to d0 to include new blank word
	addq.w	#1,d0

* now I rotate 15 times

	moveq	#15-1,d7

.mask:
* do all lines
	move.w	d1,d6
	subq.w	#1,d6

.line:
* do 1 line

	move.l	a2,a3		; keep start of line addr

* copy old line
	move.w	d0,d5
	subq.w	#1,d5
.ccc:
	move.w	(a1)+,(a2)+
	dbra	d5,.ccc

* now rotate it - only 1 plane this time!
	moveq	#4-1,d5

	move.w	d0,d4		; no of words
	subq.w	#1,d4

	moveq	#0,d3
.word:
	move.w	(a3),d2
	roxr.w	#1,d3		; get last word's bit
	roxr.w	#1,d2		; shift mask word
	roxl.w	#1,d3		; keep the lost bit
	move.w	d2,(a3)+	; put in new mask word

	dbra	d4,.word


	dbra	d6,.line
	dbra	d7,.mask


	rts


