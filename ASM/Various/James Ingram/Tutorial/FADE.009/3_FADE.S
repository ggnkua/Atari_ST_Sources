* fade from white DOWN to colours
* by James Ingram, May 1994

	opt	x+,o-,ow-


	include	\includes\macros.s


	super_on
	bsr	initialise

	move.l	#pal,a0
	move.l	#new_pals,a1
	bsr	fade_a_pal

	move.l	#pic+2,a0
	move.l	#new_my_pals,a1
	bsr	fade_in_pal

* set up screen!
	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,a0

	move.l	#pic+34,a1
	move.w	#32000/4-1,d0
copy:
	move.l	(a1)+,(a0)+
	dbra	d0,copy


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
	movem.l	d0-7/a0-1,-(a7)

	tst.w	finished_flag
	bne	done_fade


* am I pausing or fading?
	subq.w	#1,fade_counter
	bne	done_fade


* am I doing a palette?
	subq.w	#1,no_of_pals
	bne.s	doing

* no!  reset counter for whole of a fade
	move.w	#16,no_of_pals

* get next palette details from list
	move.l	fx_addr,a0

	move.l	(a0)+,d0	; get address of palette
	bpl.s	.not_end

* end of list!
	st	finished_flag
	bra	done_fade


.not_end:
	move.l	d0,pal_addr

* get addon out
	move.l	(a0)+,pal_add

* get palette speed out
	move.w	(a0)+,d0
	move.w	d0,fade_counter
	move.w	d0,fade_speed

	move.l	a0,fx_addr

doing:
	move.w	fade_speed,fade_counter	; restore counter

	move.l	pal_addr,a0
	movem.l	(a0),d0-7
	movem.l	d0-7,$ffff8240.w

* do add on
	add.l	pal_add,a0
	move.l	a0,pal_addr



done_fade:
	movem.l	(a7)+,d0-7/a0-1

	rte




fade_in_pal:
* a0 = original pal
* a1 = where to fade at!

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	move.l	a1,a0
	lea	32(a1),a1

* set up counter
	moveq	#16-1,d7	; max 16 palettes!

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

fx_list:
* fade from original palette to black...
	dc.l	new_pals,32
	dc.w	2	; SLOW

* pause for a bit
	dc.l	new_pals+15*32,0
	dc.w	2


* fade DOWN from white to font colours
	dc.l	new_my_pals+15*32,-32
	dc.w	1	; FAST!

* pause for a bit
	dc.l	new_my_pals,0
	dc.w	2


	dc.l	-1

fx_addr	dc.l	fx_list

fade_counter	dc.w	1
fade_speed	dc.w	0

pal_addr	dc.l	0
pal_add	ds.l	1
no_of_pals	dc.w	1

finished_flag	dc.w	0


pic	incbin	\includes\font.pi1

	section	bss

new_pals	ds.b	32*16
new_my_pals	ds.b	32*16
