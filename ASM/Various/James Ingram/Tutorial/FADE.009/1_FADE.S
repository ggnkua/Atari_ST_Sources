* Fade to black
* by James Ingram, May 1994

	opt	x+,o-,ow-

speed	equ	2

	include	\includes\macros.s


	super_on
	bsr	initialise

	move.l	#pal,a0
	move.l	#new_pals,a1
	bsr	fade_a_pal


	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w
	
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	
	move.l	(a7)+,$70.w


	bsr	restore
	clr.w	-(a7)
	trap	#1


my_70:
* have I finished altogether?
	tst.w	finished_flag
	bne	no_fade		; branch if finished flag set

* do I pause or fade?
	subq.w	#1,fade_counter
	bne.s	no_fade		; branch if count <> 0

* FADE this time!
* restore the counter first!
	move.w	#speed,fade_counter

	movem.l	d0-7/a0,-(a7)

* get address of palette
	move.l	pal_addr,a0
	movem.l	(a0)+,d0-7	; get palette out

	movem.l	d0-7,$ffff8240.w	; put it in

	move.l	a0,pal_addr	; store next palette address

* I have done 1 more palette
	subq.w	#1,no_of_pals
	bne.s	.not_end

* done the last one!
	st	finished_flag

.not_end:
	movem.l	(a7)+,d0-7/a0

no_fade:
	rte

fade_a_pal:
* a0 = original pal
* a1 = where to fade at!

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)	; copy original palette
	move.l	a1,a0		; get addres of palette 1
	lea	32(a1),a1	; and palette 2

* set up counter
	moveq	#16-1,d7	; max 16 palettes!

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


	include	\includes\init.s

finished_flag	dc.w	0
fade_counter	dc.w	speed
pal_addr	dc.l	new_pals
no_of_pals	dc.w	16

	section	bss

new_pals	ds.b	32*16
