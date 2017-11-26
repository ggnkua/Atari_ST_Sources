* FUll screen scroller!
* by James Ingram, April 1994

	opt	x+
	opt	o-,ow-



no_of_screens	equ	3
intro_on	equ	1



	include	\includes\macros.s

	bsr	load_data
	jsr	de_mus
* get screen addresses
	move.l	#scrn,d0
	add.l	#255,d0
	clr.b	d0

	move.l	#screens,a0
	move.l	a0,a1

	moveq	#no_of_screens-1,d7
s:
	move.l	d0,(a0)+
	add.l	#37120,d0
	
	dbra	d7,s

	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)	; copy last 2 screens to start of list...


	super_on

	c_off

	jsr	initialise
	movem.l	pal,d0-7
	movem.l	d0-7,top_pal

	bsr	convert		; clear BLANK area AFTER this!
	bsr	clear_bss

	bsr	pre_fades

	calc_chars		; calculate font char addresses

	bsr	main
	
	jsr	restore
	
	c_on

	super_off

	clr.w	-(a7)
	trap	#1

load_data:
	move.l	#font_name,a0
	move.l	#font,a1
	move.l	#30720,d0
	jsr	load_file

	move.l	#pic_name,a0
	move.l	#pic,a1
	move.l	#32034,d0
	jsr	load_file

	rts


fade_a_pal:
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


fad	macro
	btst	#3,\1
	beq.s	.\@sub_it

	bclr	#3,\1
	bra.s	.\@dun_it

.\@sub_it:
	tst.w	\1
	beq.s	.\@dun_it

	subq.w	#1,\1
	bset	#3,\1

.\@dun_it:
	endm


	fad	d0
	fad	d1
	fad	d2


	lsl.w	#4,d1
	lsl.w	#8,d2
	or.w	d2,d1
	or.w	d1,d0

	move.w	d0,(a1)+
	dbra	d6,.fade_pal

	lea	-32(a1),a0

	dbra	d7,.fade_once
	rts

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

	lea	-32(a1),a0

	dbra	d7,.fade_once
	rts

pre_fades:
	move.l	#pal,a0
	move.l	#cur_pals,a1
	bsr	fade_a_pal

	move.l	#font_pal,a0
	move.l	#font_pals,a1
	bsr	fade_a_pal

	move.l	#font_pal,a0
	move.l	#font_pals_in,a1
	bsr	fade_in_pal

	move.l	#pic_pal,a0
	move.l	#pic_pals,a1
	bsr	fade_a_pal
	rts


clear_bss:
	move.l	#start_bss,a0
	move.w	#bss_len/4-1,d0

.clr:
	clr.l	(a0)+
	dbra	d0,.clr
	rts


convert:
* convert all pictures to correct format!
	move.l	#pic_list,a0
	
conv_loop:
	move.l	(a0)+,d0
	bne.s	.another
	rts

.another:
* convert picture at d0

	move.l	(a0)+,a2	; get area for full copy
	move.l	(a0)+,a6	; get addr of palette

	pea	(a2)

	move.l	d0,a1
	lea	34(a1),a1	; go to start of pic data
	move.l	a2,a3		; keep addr of full pic
	move.w	#32000/4-1,d7
.copy:
	move.l	(a1)+,(a2)+
	dbra	d7,.copy


	move.l	d0,a1
	movem.l	2(a1),d1-7/a1
	movem.l	d1-7/a1,(a6)	; palette to end of picture


	move.l	(a7)+,a3
	move.l	d0,a1
	move.w	#40-1,d5
	moveq	#1,d7
	moveq	#7,d6

.columns:
	move.w	#200-1,d4
	pea	(a3)
.rows:
	movep.l	(a3),d0
	move.l	d0,(a1)+
	lea	160(a3),a3
	dbra	d4,.rows

	move.l	(a7)+,a3
	add.l	d7,a3

	exg	d6,d7
	dbra	d5,.columns

	bra	conv_loop




main:
	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w
	
	jsr	inp
	
	move.l	(a7)+,$70
	rts


my_70:

	movem.l	d0-7/a0-6,-(a7)

* do music...
	move.l	music,a5

	move.l	#nos,a6
	move.b	(a5)+,2(a6)
	move.b	(a5)+,6(a6)
	move.b	(a5)+,$a(a6)
	move.b	(a5)+,$e(a6)
	move.b	(a5)+,$12(a6)
	move.b	(a5)+,$16(a6)
	move.b	(a5)+,$1a(a6)
	move.b	(a5)+,$1e(a6)
	move.b	(a5)+,$22(a6)
	move.b	(a5)+,$26(a6)
	move.b	(a5)+,$2a(a6)

	movem.l	(a6),d0-d7/a0-a2
	movem.l	d0-d7/a0-a2,$ffff8800.w

	subq.w	#1,mus_len
	bne.s	.not_repeat
	
	move.l	#music_data,a5
	move.w	#4098,mus_len

.not_repeat:

	move.l	a5,music

* put in current palette
	movem.l	top_pal,d0-7
	movem.l	d0-7,$ffff8240.w


* get screen address of screen to work on
* and screen which was last...

	move.l	#screens,a3
	moveq	#0,d0
	move.w	screen_no,d0
	
	add.w	d0,d0
	add.w	d0,d0
	add.l	d0,a3
	move.l	(a3),a6		; screen to work on
	move.l	-(a3),a4	; 1 screen back...
	move.l	-(a3),a5	; 2 screens back...

	move.l	a6,scrn_disp	; keep for changing regs...


* what am I doing????
	subq.w	#1,fx_count
	bne.s	not_new_fx

.new_fx:
* I am going to do a new FX!

	move.w	#1,counter

	move.l	fx_pos,a0	; get addr of FX list

.fx_loop:
	move.l	(a0)+,d0	; get next FX
	bpl.s	.good_fx

* end of FX list!
	move.l	#fx_loop,a0
	move.l	(a0)+,d0

.good_fx:
	move.l	d0,fx_addr


* get no of times to do it
	moveq	#0,d1
	move.w	(a0)+,d1

	move.w	d1,fx_count

	move.l	a0,first_data

	move.l	a0,fx_pos
	move.l	d0,a0
	jmp	(a0)

not_new_fx:
* keep doing the old FX!
	move.l	fx_addr,a0
	jmp	(a0)

init_scroll:
	move.l	#scroller,fx_addr
	move.l	fx_pos,a1
	move.l	(a1)+,a2	; get message addr
	move.l	a1,fx_pos
	move.l	a2,message_addr

scroller:
* first, move screen to the left...

	pea	(a6)

	bsr	move_left

	move.l	(a7)+,a0	; get screen address

	lea	68*160-8(a0),a0


putter	macro
c	set	\1

	movem.l	(a1)+,d0-7/a2-5
	movep.l	d0,c(a0)
	movep.l	d0,c+160(a0)
	movep.l	d1,c+320(a0)
	movep.l	d1,c+480(a0)
	movep.l	d2,c+640(a0)
	movep.l	d2,c+800(a0)
	movep.l	d3,c+960(a0)
	movep.l	d3,c+1120(a0)
	movep.l	d4,c+1280(a0)
	movep.l	d4,c+1440(a0)
	movep.l	d5,c+1600(a0)
	movep.l	d5,c+1760(a0)
	movep.l	d6,c+1920(a0)
	movep.l	d6,c+2080(a0)
	movep.l	d7,c+2240(a0)
	movep.l	d7,c+2400(a0)

	move.l	a2,d2
	move.l	a3,d3
	move.l	a4,d4
	move.l	a5,d5

	movep.l	d2,c+2560(a0)
	movep.l	d2,c+2720(a0)
	movep.l	d3,c+2880(a0)
	movep.l	d3,c+3040(a0)
	movep.l	d4,c+3200(a0)
	movep.l	d4,c+3360(a0)
	movep.l	d5,c+3520(a0)
	movep.l	d5,c+3680(a0)

c	set	c+3840

* should use REPT here! But when I do, it messes the whole macro up!
* Why?  Ask HiSoft, I guess...

	movem.l	(a1)+,d0-7/a2-5
	movep.l	d0,c(a0)
	movep.l	d0,c+160(a0)
	movep.l	d1,c+320(a0)
	movep.l	d1,c+480(a0)
	movep.l	d2,c+640(a0)
	movep.l	d2,c+800(a0)
	movep.l	d3,c+960(a0)
	movep.l	d3,c+1120(a0)
	movep.l	d4,c+1280(a0)
	movep.l	d4,c+1440(a0)
	movep.l	d5,c+1600(a0)
	movep.l	d5,c+1760(a0)
	movep.l	d6,c+1920(a0)
	movep.l	d6,c+2080(a0)
	movep.l	d7,c+2240(a0)
	movep.l	d7,c+2400(a0)

	move.l	a2,d2
	move.l	a3,d3
	move.l	a4,d4
	move.l	a5,d5

	movep.l	d2,c+2560(a0)
	movep.l	d2,c+2720(a0)
	movep.l	d3,c+2880(a0)
	movep.l	d3,c+3040(a0)
	movep.l	d4,c+3200(a0)
	movep.l	d4,c+3360(a0)
	movep.l	d5,c+3520(a0)
	movep.l	d5,c+3680(a0)

c	set	c+3840


* done 24 LONGWORDs - just 8 more to do
	movem.l	(a1)+,d0-7
	movep.l	d0,c(a0)
	movep.l	d0,c+160(a0)
	movep.l	d1,c+320(a0)
	movep.l	d1,c+480(a0)
	movep.l	d2,c+640(a0)
	movep.l	d2,c+800(a0)
	movep.l	d3,c+960(a0)
	movep.l	d3,c+1120(a0)
	movep.l	d4,c+1280(a0)
	movep.l	d4,c+1440(a0)
	movep.l	d5,c+1600(a0)
	movep.l	d5,c+1760(a0)
	movep.l	d6,c+1920(a0)
	movep.l	d6,c+2080(a0)
	movep.l	d7,c+2240(a0)
	movep.l	d7,c+2400(a0)

	endm


* now put in the word at the right of the screen...
* values in font_counter are:
*	3 = do 1st & 2nd byte
*	2 = do 2nd and 3rd byte
*	1 = do 3rd and 4th byte
*	0 = do 4th byte and one new one!

	move.l	font_bit,a1

	move.w	font_counter,d0
	dbra	d0,not_4_1

* first, put in the 4th byte of the old char..

	lea	4*32*3(a1),a1	; goto 4th byte data

	putter	0


* Now I have to get the next char in the font

	move.l	message_addr,a2	; get address in list
	moveq	#0,d0
	move.b	(a2)+,d0
	bne.s	.not_zed

	move.w	#1,fx_count	; end this time!
	bra	do_scrn_add2

.not_zed:
	move.l	a2,message_addr


* If I _REALLY_ wanted to push processor time, I could replace
* this next small piece of code, by pre-calculating
* the end results of all message bytes.
* That is, I could go throught the message when initialising,
* subtract " " and multiply by 4.  I could then just lift out the offset
* which is required.  But since these 3 lines take only 16 cycles, 
* is it really worth it?

	sub.b	#" ",d0
	add.w	d0,d0
	add.w	d0,d0		; d0 is LW pointer

	move.l	#chars,a2
	move.l	(a2,d0.w),a1	; got address of char!

* a1 holds addr of the char I want!
* Finally!

* so now I have the address, keep it for next time.  I no longer need
* a buffer.. I can read from the font each time.

	move.l	a1,font_bit

* now put in the 1st byte of this char.

	putter	1


* finally, alter the counter, so we don't come back here
* again for another 4 times!

	move.w	#3,font_counter
	bra	dun_right


not_4_1:
	dbra	d0,not_3_4
* do 3rd and 4th bytes of char!

	lea	4*32*2(a1),a1	; goto 3rd byte data
	bra.s	do_right

not_3_4:
	dbra	d0,not_2_3
	
* do 2nd and 3rd bytes of char in font!

	lea	4*32(a1),a1	; go to 2nd byte data

not_2_3:
* do 1st and 2nd!!!

do_right:
	putter	0
	putter	1

	sub.w	#1,font_counter

dun_right:
	bra	do_scrn_add2


prepare_left_init:
	move.l	#prepare_left,fx_addr
	clr.l	prep_offset
	move.l	#blank,last_one

prepare_left:
* prepare a "square" screen to be scrolled left next time...

	move.l	prep_offset,a0
	add.l	a0,a4
	add.l	a0,a6

	moveq	#7,d6
	moveq	#1,d7

	add.l	d7,a4		; copy 1 byte from right...
	exg.l	d6,d7

	moveq	#50-1,d1
.lines:
	moveq	#39-1,d0
.cols:
	movep.l	(a4),d5
	movep.l	d5,(a6)

	add.l	d7,a4
	add.l	d6,a6
	exg.l	d6,d7

	dbra	d0,.cols

* do rightmost column...
	moveq	#0,d5
	movep.l	d5,(a6)
	add.l	d7,a4
	add.l	d6,a6
	exg.l	d6,d7

	dbra	d1,.lines

	lea	50*160(a0),a0
	move.l	a0,prep_offset

	move.w	counter,d0
	subq.w	#4,d0
	beq	do_scrn_add2
	jmp	end_int


in_fader:
	move.l	#fader,fx_addr
	move.l	fx_pos,a0
	move.w	(a0)+,d0	; get fade counter
	move.l	a0,fx_pos

	move.w	d0,fade_count

fader:
	move.l	a4,scrn_disp

* do I go this time???
	moveq	#0,d0
	moveq	#0,d1
	move.w	counter,d0
	move.w	fade_count,d1
	divu	d1,d0
	swap	d0
	tst.w	d0
	bne	.no_fade

* get addr of next palette
	move.l	fx_pos,a0
	move.l	(a0)+,a1
	move.l	a0,fx_pos

	movem.l	(a1),d0-7
	movem.l	d0-7,top_pal
.no_fade:
	jmp	end_int


print_it:
* print font text direct to screen.

	move.l	fx_pos,a1	; get addr of message
	move.l	(a1)+,a0
	move.l	a1,fx_pos

line_loop:
	moveq	#0,d0
	move.b	(a0)+,d0	; get height
	mulu	#160,d0

	moveq	#0,d1
	move.b	(a0)+,d1	; and no of bytes in
	move.w	d1,d7

	lsr.w	#1,d1		; ignore bit 0
	mulu	#8,d1		; correct word offset

	move.l	scrn_disp,a6		; get original screen position!
	add.l	d0,a6
	add.l	d1,a6		; go to correct screen position!

	move.w	#7,a4
	move.w	#1,a5

	btst	#0,d7
	beq.s	.even

* odd start address!
	add.l	a5,a6
	exg.l	a5,a4

.even:


char_loop:
	moveq	#0,d0
	move.b	(a0)+,d0	; get char to print
	beq	do_scrn_add2	; branch if finished

	cmp.b	#$ff,d0
	beq.s	line_loop	; start new line if flag

* do this char!
	sub.b	#" ",d0
	lsl.w	#8,d0
	lsl.w	#1,d0		; correct offset ( x 512)

	add.l	#font,d0
	move.l	d0,a1

	moveq	#4-1,d7

columns:


c	set	0
	rept	4

	movem.l	(a1)+,d0-6/a2
	movep.l	d0,c(a6)
	movep.l	d0,c+160(a6)
	movep.l	d1,c+320(a6)
	movep.l	d1,c+480(a6)
	movep.l	d2,c+640(a6)
	movep.l	d2,c+800(a6)
	movep.l	d3,c+960(a6)
	movep.l	d3,c+1120(a6)
	movep.l	d4,c+1280(a6)
	movep.l	d4,c+1440(a6)
	movep.l	d5,c+1600(a6)
	movep.l	d5,c+1760(a6)
	movep.l	d6,c+1920(a6)
	movep.l	d6,c+2080(a6)
	move.l	a2,d0
	movep.l	d0,c+2240(a6)
	movep.l	d0,c+2400(a6)
c	set	c+2560
	endr


	add.l	a5,a6		; go to next screen column...
	exg.l	a4,a5
	dbra	d7,columns


	bra	char_loop


do_scrn_add2:
	jmp	do_scrn_add


copy:
* copy a full screen

* a6 = screen displayed next


	move.l	fx_pos,a0
	move.l	(a0)+,a5
	move.l	a0,fx_pos



coun	set	0
	rept	615

	movem.l	(a5)+,d0-7/a0-4
	movem.l	d0-7/a0-4,coun(a6)

coun	set	coun+52
	endr

	movem.l	(a5)+,d1-5
	movem.l	d1-5,coun(a6)


	bra	do_scrn_add

blank_ur:
* a5 = get from screen addr
* a6 = put to screen addr

	lea	160*10(a5),a5	; start 10 lines down...(2 screens ago)
	lea	-160*10(a6),a6
	jsr	move_right+(32*10)

	lea	160*10(a6),a6	; TL of screen again

* blank the entire left hand column...
	move.l	#1,blank_off
	move.l	#5*4,col_off
	bsr	do_blank
	bsr	blank_bot
	bsr	put_bot

	bra	do_scrn_add

in_scroll_ur:
	move.l	#blank,last_one
	move.l	#scroll_ur,fx_addr

scroll_ur:
* a5 = get from screen addr
* a6 = put to screen addr

	lea	160*10(a5),a5	; start 10 lines down...(2 screens ago)
	lea	-160*10(a6),a6
	jsr	move_right+(32*10)

* Shifted the whole lot!
* get column addresses
	move.l	fx_pos,a1
	move.l	(a1)+,a2
	move.l	a1,fx_pos
	move.l	last_one,a3	; get last column done
	move.l	a2,last_one	; keep addr of last column

* now slap in left hand side!
* complex!
* 1st time do only bottom 5
* then bottom 10
* then bottom 15... etc

	lea	160*10(a6),a0

* a0 = addr to put on screen at
* how many to do?
	moveq	#0,d0
	move.w	counter,d0	; get counter
	mulu	#48,d0		; times len of code for 5 lines
	move.l	#end_cols2,a6
	sub.l	d0,a6
	jsr	(a6)
	

* now fill in bottom part of screen!
* a0 still points to TL, whatever!

	move.l	first_data,a6	; get addr of list of column addrs

* go to bottom on screen
	lea	30408(a0),a0
	moveq	#0,d0
	move.w	counter,d0
	subq.w	#3,d0
	bmi.s	.nothing	; branch if 1st 2 screens...

	bclr	#0,d0
	lsl.w	#2,d0		; d0 x 8 = correct word no
	add.l	d0,a0		; a0 points to rightmost column


	move.l	(a6),a1		; get addr of 40th column in pic
	move.w	counter,d0
	subq.w	#2,d0
	mulu	#5*4,d0		; get addon for height within column
	add.l	d0,a1


	move.w	counter,d0
	btst	#0,d0
	beq.s	.not_odd

* we have to put in column 40 in an odd position!
	bsr	do_odd_40

.not_odd:
* now do the rest of the columns...
* a0 = correct column addr on screen
* a1 = correct column addr in pic

	moveq	#0,d0
	move.w	counter,d0
	subq.w	#4,d0
	bmi.s	.nothing	; don't do a full column 1st time!

	addq.w	#2,d0		; like sub #2!
	lsr.w	#1,d0		; 1 more column every 2 times!

	mulu	#100,d0
	move.l	#end_rest,a6
	sub.l	d0,a6
	jsr	(a6)



.nothing:

	bra	do_scrn_add


blank_dr:
* a5 = get from screen addr
* a6 = put to screen addr

	bsr	move_right+(32*10)


* blank the entire left hand column...
	move.l	#160*5+1,blank_off
	clr.l	col_off
	bsr	do_blank
	bsr	blank_top
	bsr	put_top

	bra	do_scrn_add

in_scroll_dr:
	move.l	#blank,last_one
	move.l	#scroll_dr,fx_addr

scroll_dr:
* a5 = get from screen addr
* a6 = put to screen addr

* don't alter either screen address!
	bsr	move_right+(32*10)

* Shifted the whole lot!
* get column addresses
	move.l	fx_pos,a1
	move.l	(a1)+,a2
	move.l	a1,fx_pos
	move.l	last_one,a3	; get last column done
	move.l	a2,last_one	; keep addr of last column

	lea	780(a2),a2
	lea	780(a3),a3	; point to bottom of column

* now slap in left hand side!
* complex!
* 1st time do only bottom 5
* then bottom 10
* then bottom 15... etc

	move.l	a6,a0

* a0 = addr to put on screen at
* how many to do?
	moveq	#0,d0
	move.w	counter,d0	; get counter
	mulu	#54,d0		; times len of code for 5 lines
	move.l	#end_cols_down,a5
	sub.l	d0,a5
	move.l	#160*5,d5
	jsr	(a5)
	
	move.l	a6,a0

* now fill in top part of screen!
* a0 still points to TL, whatever!

	move.l	first_data,a6	; get addr of list of column addrs

* go to 2nd word on screen
	addq.l	#8,a0
	moveq	#0,d0
	move.w	counter,d0
	subq.w	#3,d0
	bmi.s	.nothing	; branch if 1st 2 screens...

	bclr	#0,d0
	lsl.w	#2,d0		; d0 x 8 = correct word no
	add.l	d0,a0		; a0 points to rightmost column


	move.l	(a6),a1		; get addr of 40th column in pic
	move.w	counter,d0
	subq.w	#2,d0
	mulu	#5*4,d0		; get addon for height within column
	add.l	#760,a1
	sub.l	d0,a1


	move.w	counter,d0
	btst	#0,d0
	beq.s	.not_odd

* we have to put in column 40 in an odd position!
	bsr	do_odd_40

.not_odd:
* now do the rest of the columns...
* a0 = correct column addr on screen
* a1 = correct column addr in pic

	moveq	#0,d0
	move.w	counter,d0
	subq.w	#4,d0
	bmi.s	.nothing	; don't do a full column 1st time!

	addq.w	#2,d0		; like sub #2!
	lsr.w	#1,d0		; 1 more column every 2 times!

	mulu	#100,d0
	move.l	#end_rest,a6
	sub.l	d0,a6
	jsr	(a6)



.nothing:

	bra	do_scrn_add

blank_dl:
* a5 = get from screen addr
* a6 = put to screen addr

	addq.l	#8,a5
	subq.l	#8,a6
	bsr	move_right+(32*10)

	lea	160(a6),a6
* blank the entire right hand column...
	move.l	#160*5,blank_off
	clr.l	col_off
	bsr	do_blank

	lea	-160(a6),a6
	bsr	blank_top
	bsr	put_top_left

	bra	do_scrn_add

in_scroll_dl:
	move.l	#blank,last_one
	move.l	#scroll_dl,fx_addr

scroll_dl:
* a5 = get from screen addr
* a6 = put to screen addr

* don't alter either screen address!
	addq.l	#8,a5
	subq.l	#8,a6

	bsr	move_right+(32*10)

* Shifted the whole lot!
* get column addresses
	move.l	fx_pos,a1
	move.l	(a1)+,a2
	move.l	a1,fx_pos
	move.l	last_one,a3	; get last column done
	move.l	a2,last_one	; keep addr of last column

	lea	780(a2),a2
	lea	780(a3),a3	; point to bottom of column

* now slap in right hand side!
* complex!
* 1st time do only bottom 5
* then bottom 10
* then bottom 15... etc

	lea	152+8(a6),a0

* a0 = addr to put on screen at
* how many to do?
	moveq	#0,d0
	move.w	counter,d0	; get counter
	mulu	#54,d0		; times len of code for 5 lines
	move.l	#end_cols_down_left,a5
	sub.l	d0,a5
	move.l	#160*5,d5
	jsr	(a5)
	
	lea	152(a6),a0

* now fill in top part of screen!
* a0 still points to TR, whatever!

	move.l	first_data,a6	; get addr of list of column addrs

* go to 2nd word back
	moveq	#0,d0
	move.w	counter,d0
	subq.w	#3,d0
	bmi.s	.nothing	; branch if 1st 2 screens...

	bclr	#0,d0
	lsl.w	#2,d0		; d0 x 8 = correct word no
	sub.l	d0,a0		; a0 points to rightmost column


	move.l	(a6),a1		; get addr of 40th column in pic
	move.w	counter,d0
	subq.w	#2,d0
	mulu	#5*4,d0		; get addon for height within column
	add.l	#760,a1
	sub.l	d0,a1


	move.w	counter,d0
	btst	#0,d0
	beq.s	.not_odd

* we have to put in column 40 in an odd position!
	bsr	do_odd_1

.not_odd:
* now do the rest of the columns...
* a0 = correct column addr on screen
* a1 = correct column addr in pic

	moveq	#0,d0
	move.w	counter,d0
	subq.w	#4,d0
	bmi.s	.nothing	; don't do a full column 1st time!

	addq.w	#2,d0		; like sub #2!
	lsr.w	#1,d0		; 1 more column every 2 times!

	mulu	#100,d0
	move.l	#end_left_rest,a6
	sub.l	d0,a6
	jsr	(a6)



.nothing:

	bra	do_scrn_add


blank_bot:
	lea	190*160(a6),a6	; goto bottom of screen
blank_top:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7

	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5




coun	set	8
	rept	10

	movem.l	d0-7/a0-5,coun(a6)
	movem.l	d0-7/a0-5,coun+56(a6)
	movem.l	d0-7/a0-1,coun+112(a6)

coun	set	coun+160
	endr

	rts


put_top:
	move.l	last_one,a1	; get addr of last column done
	lea	800(a1),a1	; 2nd column in (1st in side)
	lea	160*5(a6),a6	; put it 5 lines down!
	bra.s	do_put

put_bot:
	move.l	last_one,a1	; get addr of last column done
	lea	195*4+800(a1),a1	; bottom 5 rows in 2nd column!

do_put:
* am I on the first time around?
	move.w	counter,d0
	subq.w	#1,d0
	bne	not_first2

* on the first time around... so I have to put in bottom 10 lines!
	lea	8(a6),a0


coun	set	0	; start on 39th column!
cc	set	0

	rept	19
	movem.l	coun(a1),d0-4		; get all 5 lines to slap in...
	movep.l	d0,cc(a0)
	movep.l	d1,cc+160(a0)
	movep.l	d2,cc+320(a0)
	movep.l	d3,cc+480(a0)
	movep.l	d4,cc+640(a0)


coun	set	coun+800	; next column

	movem.l	coun(a1),d0-4		; get all 5 lines to slap in...
	movep.l	d0,cc+1(a0)
	movep.l	d1,cc+161(a0)
	movep.l	d2,cc+321(a0)
	movep.l	d3,cc+481(a0)
	movep.l	d4,cc+641(a0)

coun	set	coun+800
cc	set	cc+8
	endr

not_first2:
	rts

put_top_left:
	move.l	last_one,a1	; get addr of last column done
	lea	-800(a1),a1	; top 5 rows in 2nd last column
	lea	160*6(a6),a6	; put it 5 lines down!
	bra.s	do_top_left

put_bot_left:
	move.l	last_one,a1	; get addr of last column done
	lea	195*4-800(a1),a1	; bottom 5 rows in 2nd last column

do_top_left:
* am I on the first time around?
	move.w	counter,d0
	subq.w	#1,d0
	bne	not_first2

* on the first time around... so I have to put in bottom 10 lines!
	lea	-8(a6),a0


coun	set	0	; start on 39th column!
cc	set	0

	rept	19
	movem.l	coun(a1),d0-4		; get all 5 lines to slap in...
	movep.l	d0,cc+1(a0)
	movep.l	d1,cc+161(a0)
	movep.l	d2,cc+321(a0)
	movep.l	d3,cc+481(a0)
	movep.l	d4,cc+641(a0)


coun	set	coun-800	; next column

	movem.l	coun(a1),d0-4		; get all 5 lines to slap in...
	movep.l	d0,cc(a0)
	movep.l	d1,cc+160(a0)
	movep.l	d2,cc+320(a0)
	movep.l	d3,cc+480(a0)
	movep.l	d4,cc+640(a0)

coun	set	coun-800
cc	set	cc-8
	endr

	rts


do_blank:
	moveq	#0,d0
	moveq	#0,d1



coun	set	0
	rept	200

	movem.l	d0-1,coun(a6)

coun	set	coun+160
	endr


* am I on the first time around?
	move.w	counter,d0
	subq.w	#1,d0
	bne	not_first

* first time around!
* put in the last column again (to get rid of flickering border bug)

	move.l	last_one,a5	; get column addr
	add.l	col_off,a5

	add.l	blank_off,a6


coun	set	0
	rept	15
	movem.l	(a5)+,d0-7/a0-4
	movep.l	d0,coun(a6)
	movep.l	d1,coun+160(a6)
	movep.l	d2,coun+320(a6)
	movep.l	d3,coun+480(a6)
	movep.l	d4,coun+640(a6)
	movep.l	d5,coun+800(a6)
	movep.l	d6,coun+960(a6)
	movep.l	d7,coun+1120(a6)

	move.l	a0,d0
	move.l	a1,d1
	move.l	a2,d2
	move.l	a3,d3
	move.l	a4,d4
	movep.l	d0,coun+1280(a6)
	movep.l	d1,coun+1440(a6)
	movep.l	d2,coun+1600(a6)
	movep.l	d3,coun+1760(a6)
	movep.l	d4,coun+1920(a6)

coun	set	coun+2080
	endr

	sub.l	blank_off,a6

not_first:
	rts


blank_ul:
* a5 = get from screen addr
* a6 = put to screen addr

	lea	160*10+8(a5),a5	; start 10 lines down...(2 screens ago)
	lea	-160*10-8(a6),a6
	jsr	move_right+(32*10)

	lea	160*10+8+152(a6),a6

* blank the entire right hand column...
	clr.l	blank_off
	move.l	#5*4,col_off
	bsr	do_blank
	lea	-160(a6),a6
	bsr	blank_bot

	lea	160(a6),a6
	bsr	put_bot_left

	bra	do_scrn_add


in_scroll_ul:
	move.l	#blank,last_one
	move.l	#scroll_ul,fx_addr
scroll_ul:
* a5 = get from screen addr
* a6 = put to screen addr

	lea	160*10+8(a5),a5	; start 10 lines down...(2 screens ago)
	lea	-160*10-8(a6),a6
	jsr	move_right+(32*10)

* Shifted the whole lot!
* get column addresses
	move.l	fx_pos,a1
	move.l	(a1)+,a2
	move.l	a1,fx_pos
	move.l	last_one,a3	; get last column done
	move.l	a2,last_one	; keep addr of last column

* now slap in right hand side!
* complex!
* 1st time do only bottom 5
* then bottom 10
* then bottom 15... etc

	lea	160*10+8+152(a6),a0

* a0 = addr to put on screen at
* how many to do?
	moveq	#0,d0
	move.w	counter,d0	; get counter
	mulu	#48,d0		; times len of code for 5 lines
	move.l	#end_left_cols,a6
	sub.l	d0,a6
	jsr	(a6)
	

* now fill in bottom part of screen!
* a0 still points to TR, whatever!

	move.l	first_data,a6	; get addr of list of column addrs

* go to bottom on screen
	lea	30400-8(a0),a0
	moveq	#0,d0
	move.w	counter,d0
	subq.w	#3,d0
	bmi.s	.nothing	; branch if 1st 2 screens...

	bclr	#0,d0
	lsl.w	#2,d0		; d0 x 8 = correct word no
	sub.l	d0,a0		; a0 points to leftmost column


	move.l	(a6),a1		; get addr of 1st column in pic
	move.w	counter,d0
	subq.w	#2,d0
	mulu	#5*4,d0		; get addon for height within column
	add.l	d0,a1


* now do the rest of the columns...
* a0 = correct column addr on screen
* a1 = correct column addr in pic


	move.w	counter,d0
	btst	#0,d0
	beq.s	.not_odd

* we have to put in column 1 in an odd position!
	bsr	do_odd_1

.not_odd:
	moveq	#0,d0
	move.w	counter,d0
	subq.w	#4,d0
	bmi.s	.nothing	; don't do a full column 1st time!

	addq.w	#2,d0		; like sub #2!
	lsr.w	#1,d0		; 1 more column every 2 times!

	mulu	#100,d0
	move.l	#end_left_rest,a6
	sub.l	d0,a6
	jsr	(a6)

.nothing:
	bra	do_scrn_add

do_rest:

* a0 = correct column addr on screen
* a1 = correct addr of column in pic


coun	set	-18*1600
cc	set	-18*8

	rept	19
	movem.l	coun-800(a1),d0-7/a2-3
	movep.l	d0,cc(a0)
	movep.l	d1,cc+160(a0)
	movep.l	d2,cc+320(a0)
	movep.l	d3,cc+480(a0)
	movep.l	d4,cc+640(a0)
	movep.l	d5,cc+800(a0)
	movep.l	d6,cc+960(a0)
	movep.l	d7,cc+1120(a0)

	move.l	a2,d0
	move.l	a3,d1
	movep.l	d0,cc+1280(a0)
	movep.l	d1,cc+1440(a0)

	movem.l	coun(a1),d0-7/a2-3
	movep.l	d0,cc+1(a0)
	movep.l	d1,cc+161(a0)
	movep.l	d2,cc+321(a0)
	movep.l	d3,cc+481(a0)
	movep.l	d4,cc+641(a0)
	movep.l	d5,cc+801(a0)
	movep.l	d6,cc+961(a0)
	movep.l	d7,cc+1121(a0)

	move.l	a2,d0
	move.l	a3,d1
	movep.l	d0,cc+1281(a0)
	movep.l	d1,cc+1441(a0)


coun	set	coun+1600
cc	set	cc+8
	endr

end_rest:
	rts

do_left_rest:

* a0 = correct column addr on screen
* a1 = correct addr of column in pic


coun	set	18*1600
cc	set	18*8

	rept	19
	movem.l	coun(a1),d0-7/a2-3
	movep.l	d0,cc(a0)
	movep.l	d1,cc+160(a0)
	movep.l	d2,cc+320(a0)
	movep.l	d3,cc+480(a0)
	movep.l	d4,cc+640(a0)
	movep.l	d5,cc+800(a0)
	movep.l	d6,cc+960(a0)
	movep.l	d7,cc+1120(a0)

	move.l	a2,d0
	move.l	a3,d1
	movep.l	d0,cc+1280(a0)
	movep.l	d1,cc+1440(a0)

	movem.l	coun+800(a1),d0-7/a2-3
	movep.l	d0,cc+1(a0)
	movep.l	d1,cc+161(a0)
	movep.l	d2,cc+321(a0)
	movep.l	d3,cc+481(a0)
	movep.l	d4,cc+641(a0)
	movep.l	d5,cc+801(a0)
	movep.l	d6,cc+961(a0)
	movep.l	d7,cc+1121(a0)

	move.l	a2,d0
	move.l	a3,d1
	movep.l	d0,cc+1281(a0)
	movep.l	d1,cc+1441(a0)


coun	set	coun-1600
cc	set	cc-8
	endr

end_left_rest:
	rts


do_odd_40:
* a0 = correct column addr on screen
* a1 = correct addr of column in pic

	movem.l	(a1),d0-7/a2-3
	movep.l	d0,(a0)
	movep.l	d1,160(a0)
	movep.l	d2,320(a0)
	movep.l	d3,480(a0)
	movep.l	d4,640(a0)
	movep.l	d5,800(a0)
	movep.l	d6,960(a0)
	movep.l	d7,1120(a0)

	move.l	a2,d0
	move.l	a3,d1
	movep.l	d0,1280(a0)
	movep.l	d1,1440(a0)


* now adjust screen address
	subq.l	#8,a0
* adjust column address
	lea	-800(a1),a1
	rts

do_odd_1:
* a0 = correct column addr on screen
* a1 = correct addr of column in pic

	movem.l	(a1),d0-7/a2-3

	movep.l	d0,1(a0)
	movep.l	d1,161(a0)
	movep.l	d2,321(a0)
	movep.l	d3,481(a0)
	movep.l	d4,641(a0)
	movep.l	d5,801(a0)
	movep.l	d6,961(a0)
	movep.l	d7,1121(a0)

	move.l	a2,d0
	move.l	a3,d1
	movep.l	d0,1281(a0)
	movep.l	d1,1441(a0)

* now adjust screen address
	addq.l	#8,a0
* adjust column address
	lea	800(a1),a1

	rts




new_cols_down:
* a0 = addr to put on screen at
* a2 = addr of 1st pic column start
* a3 = addr of 2nd pic column start
* d5 MUST BE 160*5!


coun	set	-780

	rept	40
	movem.l	coun(a2),d0-4
	movep.l	d0,(a0)
	movep.l	d1,160(a0)
	movep.l	d2,320(a0)
	movep.l	d3,480(a0)
	movep.l	d4,640(a0)

	movem.l	coun(a3),d0-4
	movep.l	d0,1(a0)
	movep.l	d1,161(a0)
	movep.l	d2,321(a0)
	movep.l	d3,481(a0)
	movep.l	d4,641(a0)

	add.l	d5,a0

coun	set	coun+20
	endr

end_cols_down:
	rts

new_cols_down_left:
* a0 = addr to put on screen at
* a2 = addr of 1st pic column start
* a3 = addr of 2nd pic column start
* d5 MUST BE 160*5!


coun	set	-780

	rept	40
	movem.l	coun(a2),d0-4
	movep.l	d0,1(a0)
	movep.l	d1,161(a0)
	movep.l	d2,321(a0)
	movep.l	d3,481(a0)
	movep.l	d4,641(a0)

	movem.l	coun(a3),d0-4
	movep.l	d0,(a0)
	movep.l	d1,160(a0)
	movep.l	d2,320(a0)
	movep.l	d3,480(a0)
	movep.l	d4,640(a0)

	add.l	d5,a0

coun	set	coun+20
	endr

end_cols_down_left:
	rts


new_cols2:
* a0 = addr to put on screen at
* a2 = addr of 1st pic column start
* a3 = addr of 2nd pic column start


sc	set	0

	rept	40
	movem.l	(a2)+,d0-4
	movep.l	d0,sc(a0)
	movep.l	d1,sc+160(a0)
	movep.l	d2,sc+320(a0)
	movep.l	d3,sc+480(a0)
	movep.l	d4,sc+640(a0)

	movem.l	(a3)+,d0-4
	movep.l	d0,sc+1(a0)
	movep.l	d1,sc+161(a0)
	movep.l	d2,sc+321(a0)
	movep.l	d3,sc+481(a0)
	movep.l	d4,sc+641(a0)

sc	set	sc+800
	endr

end_cols2:
	rts

left_cols2:
* a0 = addr to put on screen at
* a2 = addr of 1st pic column start
* a3 = addr of 2nd pic column start


sc	set	0

	rept	40
	movem.l	(a2)+,d0-4
	movep.l	d0,sc+1(a0)
	movep.l	d1,sc+161(a0)
	movep.l	d2,sc+321(a0)
	movep.l	d3,sc+481(a0)
	movep.l	d4,sc+641(a0)

	movem.l	(a3)+,d0-4
	movep.l	d0,sc(a0)
	movep.l	d1,sc+160(a0)
	movep.l	d2,sc+320(a0)
	movep.l	d3,sc+480(a0)
	movep.l	d4,sc+640(a0)

sc	set	sc+800
	endr

end_left_cols:
	rts


scroll_down:
* a5 = get from
* a6 = screen to put on!

	move.l	#blank,last_one	; clear last_one buffer!

	move.l	a6,a0
	lea	5*160(a6),a6	; put in 5 lines down screen
	move.l	a4,a5		; the same - get from the top!

* a0 = where to put new stuff
* a5 = where to copy from
* a6 = where to copy to

	move.l	fx_pos,a2
	move.l	(a2)+,a1	; get the area to take from
	move.l	a2,fx_pos

	bsr	up_new
	bsr	up_copy

	bra	do_scrn_add


scroll_up:
* a5 = get from
* a6 = screen to put on!

	move.l	#blank,last_one	; clear last_one buffer!


* first, put in the bottom area!
	lea	195*160(a6),a0	; go to bottom lines for put in
	lea	5*160(a4),a5	; get from a few lines down

* a0 = where to put new stuff
* a5 = where to copy from
* a6 = where to copy to

	move.l	fx_pos,a2
	move.l	(a2)+,a1	; get the area to take from
	move.l	a2,fx_pos

	bsr	up_new
	bsr	up_copy

	bra	do_scrn_add


up_copy:
* from a5
* to a6


* now do 195 lines!
* 31200 bytes!
* 7800 registers!


coun	set	0

	rept	600
	movem.l	(a5)+,d0-7/a0-4
	movem.l	d0-7/a0-4,coun(a6)

coun	set	coun+52
	endr

	rts


up_new:
* a1 = picture data addr (correct pos in leftmost column)
* a0 = new screen


cc	set	0
coun	set	0
	rept	20

	movem.l	cc(a1),d1-5		; get 5 whole columns of data
	movep.l	d1,coun(a0)
	movep.l	d2,coun+160(a0)
	movep.l	d3,coun+320(a0)
	movep.l	d4,coun+480(a0)
	movep.l	d5,coun+640(a0)

cc	set	cc+800
	movem.l	cc(a1),d1-5		; get 5 whole columns of data
	movep.l	d1,coun+1(a0)
	movep.l	d2,coun+161(a0)
	movep.l	d3,coun+321(a0)
	movep.l	d4,coun+481(a0)
	movep.l	d5,coun+641(a0)

cc	set	cc+800

coun	set	coun+8
	endr

	rts



move_left:
	addq.l	#8,a5
	subq.l	#8,a6

move_right:


coun	set	8

	rept	200

	movem.l	(a5)+,d0-7/a0-4
	movem.l	d0-7/a0-4,coun(a6)

	movem.l	(a5)+,d0-7/a0-4
	movem.l	d0-7/a0-4,coun+52(a6)

	movem.l	(a5)+,d0-7/a0-3
	movem.l	d0-7/a0-3,coun+104(a6)

	addq.l	#8,a5		; a5 to next line down

coun	set	coun+160
	endr

	rts

in_scroll_right:
	move.l	#blank,last_one
	move.l	#scroll_right,fx_addr

scroll_right:
	bsr	move_right

	move.l	a6,a0

* get column addresses
	move.l	fx_pos,a1
	move.l	(a1)+,a2
	move.l	a1,fx_pos
	move.l	last_one,a3	; get last column done
	move.l	a2,last_one	; keep addr of last column

* now slap in left hand side!
	bsr	new_cols
	bra	do_scrn_add

in_scroll_left:
	move.l	#blank,last_one
	move.l	#scroll_left,fx_addr

scroll_left:
	bsr	move_left


*  first, go to the right!!!
	lea	160(a6),a0


* take 2 columns from a1 and slap them in!
* get column addresses
	move.l	fx_pos,a1
	move.l	(a1)+,a3
	move.l	a1,fx_pos
	move.l	last_one,a2	; get last column done
	move.l	a3,last_one	; keep addr of last column
	

	bsr	new_cols

do_scrn_add:

	move.l	scrn_disp,d0

	clr.b	$ffff820d.w	; this clears the STe extra byte
				; which otherwise could cause the
				; screen to look very odd on STes
	
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w	; slap the screen address in!
				; only those bytes are needed...


	move.l	#screen_no,a0
	addq.w	#1,(a0)
	cmp.w	#no_of_screens,(a0)
	bne.s	.not_last
	
	clr.w	(a0)
.not_last:
end_int:

	addq.w	#1,counter

	movem.l	(a7)+,d0-7/a0-6
	rte

new_cols:
* a0 = addr to put on screen at
* a2 = addr of 1st pic column start
* a3 = addr of 2nd pic column start


sc	set	0

	rept	25
	movem.l	(a2)+,d0-7
	movep.l	d0,sc(a0)
	movep.l	d1,sc+160(a0)
	movep.l	d2,sc+320(a0)
	movep.l	d3,sc+480(a0)
	movep.l	d4,sc+640(a0)
	movep.l	d5,sc+800(a0)
	movep.l	d6,sc+960(a0)
	movep.l	d7,sc+1120(a0)

	movem.l	(a3)+,d0-7
	movep.l	d0,sc+1(a0)
	movep.l	d1,sc+161(a0)
	movep.l	d2,sc+321(a0)
	movep.l	d3,sc+481(a0)
	movep.l	d4,sc+641(a0)
	movep.l	d5,sc+801(a0)
	movep.l	d6,sc+961(a0)
	movep.l	d7,sc+1121(a0)

sc	set	sc+1280
	endr
	

	rts


change_pal:
	move.l	fx_pos,a0
	move.l	(a0)+,a1
	move.l	a0,fx_pos
	movem.l	(a1),d0-7
	movem.l	d0-7,top_pal
	bra	end_int


pause:
	move.l	a4,scrn_disp
	bra	end_int

	include	\includes\misc.s
	include	\includes\init.s
	include	\includes\load.s
	include	\includes\de_mus.s




	section	data

left_list	macro
offset	set	0

	rept	\2

	dc.l	\1+offset
offset	set	offset+800
	endr

	endm

right_list	macro
offset	set	31200

	rept	\2

	dc.l	\1+offset
offset	set	offset-800
	endr

	endm



up_list	macro
offset	set	0

	rept	\2
	dc.l	\1+offset
offset	set	offset+5*4
	endr
	
	endm

down_list	macro
offset	set	800

	rept	\2
	dc.l	\1+offset
offset	set	offset-5*4
	endr
	
	endm



left	macro
	dc.l	in_scroll_left
	dc.w	40

	left_list	\1,40
	endm

lleft	macro
	dc.l	scroll_left
	dc.w	40

	left_list	\1,40
	endm


blank_left	macro

	dc.l	scroll_left
	dc.w	42

	rept	42
	dc.l	blank
	endr

	endm

right	macro
	dc.l	in_scroll_right
	dc.w	40
	
	right_list	\1,40
	endm

rright	macro
	dc.l	scroll_right
	dc.w	40
	
	right_list	\1,40
	endm

blank_right	macro

	dc.l	scroll_right
	dc.w	42

	rept	42
	dc.l	blank
	endr

	endm

ul	macro
	dc.l	in_scroll_ul
	dc.w	40
	left_list	\1,40
	
	endm

blank_ul	macro

	dc.l	blank_ul
	dc.w	42

	endm


dl	macro
	dc.l	in_scroll_dl
	dc.w	40
	left_list	\1,40
	endm

blank_dl	macro

	dc.l	blank_dl
	dc.w	42

	endm


ur	macro
	dc.l	in_scroll_ur
	dc.w	40
	right_list	\1,40
	
	endm

blank_ur	macro

	dc.l	blank_ur
	dc.w	42

	endm

dr	macro
	dc.l	in_scroll_dr
	dc.w	40
	right_list	\1,40
	
	endm

blank_dr	macro

	dc.l	blank_dr
	dc.w	42

	endm

up	macro
	dc.l	scroll_up
	dc.w	40

	up_list	\1,40
	endm

blank_up	macro
	dc.l	scroll_up
	dc.w	42
	
	rept	42
	dc.l	blank
	endr

	endm

down	macro
	dc.l	scroll_down
	dc.w	40

	down_list	\1,40
	endm

blank_down	macro
	dc.l	scroll_down
	dc.w	42

	rept	42
	dc.l	blank
	endr

	endm

prep_l	macro
	dc.l	prepare_left_init
	dc.w	4
	endm


pause	macro
	dc.l	pause
	dc.w	\1
	endm


fade_out	macro
	dc.l	in_fader
	dc.w	\2*16

	dc.w	\2	; speed of fade (bigger = slower)

c	set	0

	rept	16
	dc.l	\1+c
c	set	c+32

	endr
	endm

fade_in	macro
	dc.l	in_fader
	dc.w	\2*16

	dc.w	\2	; speed of fade (bigger = slower)
	
c	set	32*15

	rept	16
	dc.l	\1+c
c	set	c-32

	endr
	endm


pal	macro
	dc.l	change_pal
	dc.w	1
	dc.l	\1
	endm

print	macro
	pal	all_white

	dc.l	print_it
	dc.w	1
	dc.l	\1

	fade_in	font_pals_in,3

	pause	\2

	endm

print_in	macro
	pal	font_pals+(32*15)
	
	dc.l	print_it
	dc.w	1
	dc.l	\1

	fade_in	font_pals,2

	pause	\2

	endm

mes	macro

	pal	font_pal

	dc.l	init_scroll
	dc.w	10000
	
	dc.l	\1
	
	dc.l	init_scroll
	dc.w	10000
	dc.l	spaces

	pal	pic_pal

	endm



fx_addr		ds.l	1

fx_pos		dc.l	fx_list
fx_count	dc.w	1
column_no	dc.w	0

fx_list:
	blank_left
	fade_out	cur_pals,1


fx_loop:
	IFD	intro_on
	pause	50
	print	intro,50
	blank_up

	print	intro2,50
	blank_down

	print	intro3,100
	blank_up

	print	intro4,100
	blank_down
	ENDC


	mes	so

	up	pic
	blank_up
	pause	25

	mes	and_this

	down	pic
	blank_down
	pause	25

	mes	what_about

	dl	pic
	blank_dl
	pause	25

	mes	or

	dr	pic
	blank_dr
	pause	25

	mes	or

	ur	pic
	blank_ur
	pause	25

	mes	final_or

	ul	pic
	blank_ul
	pause	25

	mes	left_right

	left	pic
	lleft	pic
	lleft	pic
	blank_left
	pause	25

	right	pic
	rright	pic
	rright	pic
	blank_right
	pause	25

	left	pic
	blank_left
	pause	25
	
	right	pic
	blank_right
	pause	25

	left	pic
	pause	10
	blank_up

	pause	25

	down	pic
	pause	10
	prep_l
	blank_left

	pause	25

	mes	last

	pal	pic_pal

	left	pic
	blank_left

	right	pic
	blank_right
	
	up	pic
	blank_down
	
	down	pic
	blank_up

	left	pic
	lleft	pic
	lleft	pic
	pause	25
	lleft	pic
	lleft	pic
	lleft	pic
	pause	25
	blank_down


	right	pic
	rright	pic
	rright	pic
	pause	25
	rright	pic
	rright	pic
	rright	pic
	pause	25
	blank_up

	left	pic
	blank_left
	
	right	pic
	blank_right

	up	pic
	pause	25
	prep_l
	blank_left

	right	pic
	blank_right


	pal	pic_pal
	ur	pic
	blank_ur
	
	up	pic
	blank_up
	
	ul	pic
	blank_ul
	
	left	pic
	blank_left
	
	dl	pic
	blank_dl
	
	down	pic
	blank_down
	
	dr	pic
	blank_dr

	right	pic
	pause	100

	fade_out	pic_pals,5
	blank_left



	print_in	theend,300
	fade_out	font_pals,2
	blank_left
	

	pause	150

	dc.l	-1

all_white:
	dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff
	dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff


spaces:
	DC.B	"          ",0

so:
	dc.b	"SO...             YOU'VE SEEN THIS BEFORE ? ",0
and_this:
	dc.b	"AND YOU MUST HAVE SEEN THIS... ",0

what_about:
	dc.b	"BUT WHAT ABOUT THIS ? ",0
or:
	dc.b	"OR THIS... ",0

final_or:
	dc.b	"WHAT ABOUT THIS ? ",0

left_right:
	DC.B	"NOT IMPRESSED ?  COULD IT BE FAKED FULL-SCREEN SCROLLING ?   NO. "
	dc.b	0

last:
	DC.B	"SEE DOC FILES FOR DETAILS ON HOW TO GET THE SOURCE CODE "
	DC.B	"FOR THIS DEMO, PLUS FULL D.I.Y. GUIDE TO DEMO PROGRAMMING... "
	DC.B	0




intro:
	dc.b	36,10,"JAMES",$ff
	dc.b	100,8,"INGRAM",0
intro2:
	dc.b	68,5,"PRESENTS",0
intro3:
	dc.b	36,14,"THE",$ff
	dc.b	100,7,"ALL-NEW",0

intro4:
	dc.b	36,12,"FULL",$ff
	dc.b	100,7,"SCROLL!",0

theend:
	dc.b	68,4,"THE END?",0



font_name	dc.b	"\includes\font.dat",0
pic_name	dc.b	"\includes\pic.pi1",0
	even

nos:	DC.B	0,0,$3E,0
	dc.b	1,1,1,0
	DC.B	2,2,$EE,0
	dc.b	3,3,0,0
	DC.B	4,4,$59,0
	dc.b	5,5,2,0
	DC.B	6,6,7,0
	dc.b	7,7,$F8,$FF
vols:
	DC.B	8,8
vol1	dc.b	$E,0
	DC.B	9,9
vol2	dc.b	$E,0
	DC.B	$A,$A
vol3	dc.b	$F,0



music	dc.l	music_data
mus_len	dc.w	4098


	
last_one	dc.l	blank
font_bit	dc.l	font


screen_no	dc.w	0

pic_list:
	dc.l	pic,pic_norm,pic_pal
	dc.l	0

font_pal	incbin	\includes\font_pal.dat

	section	bss

font	ds.b	30720
pic	ds.b	32034
pic_pal	equ	pic+32000
pic_norm	ds.b	32000


	ds.l	1
	ds.l	1
screens	ds.l	no_of_screens+1

start_bss:

scrn	ds.b	256
	ds.b	37120*no_of_screens

blank	ds.b	32000

bss_len	equ	*-start_bss

scrn_disp	ds.l	1

counter	ds.w	1
first_data	ds.l	1

blank_off	ds.l	1
col_off		ds.l	1

cur_pals	ds.b	32*16
font_pals	ds.b	32*16
font_pals_in	ds.b	32*16
pic_pals	ds.b	32*16

fade_count	ds.w	1

prep_offset	ds.l	1
chars	ds.l	60		; 60 chars in font - need address for each!
font_counter	ds.w	1
message_addr	ds.l	1

top_pal	ds.b	32

music_data	ds.b	4098*13