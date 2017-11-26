* FULL-SCREEN DEMO!
* by James Ingram, 1994


	opt	o-,ow-


first_fade_speed	equ	3
second_fade_speed	equ	3
last_fade_speed		equ	4

no_of_scrns	equ	5


spr_h	equ	75
spr_w	equ	160
words	equ	spr_w/16*4	; no of words in 1 line of sprite
spr_len	equ	(words+4)*2*spr_h	; length (in bytes) of sprite line + blank bit at right hand side


	include	\includes\macros.s

	jsr	do_loads

	super_on

	move.b	$484.w,-(a7)
	bclr	#0,$484.w	; key click off

	c_off
	move.b	$fffffa15.w,-(a7)	; keep interrupt mask B
	bclr	#6,$fffffa15.w		; keyboard interrupt off!

	jsr	initialise
	jsr	fades		; fade palettes


* Fade to black...
	clr.w	fade_flag
	move.w	#16,no_fades
	move.w	#first_fade_speed,fade_count
	move.l	#new_pals,pal_addr

	move.l	$70.w,-(a7)

	move.l	#fade_out,$70.w

	jsr	de_mus		; decompress music
	jsr	do_pre		; pre-shifts
	jsr	sine_longs	; sine data to LWs
	jsr	do_screens	; do screens

wait:
	tst.w	fade_flag
	beq.s	wait


* now start the demo itself!
	move.l	#sprite_pals+(15*32),pal_addr
	move.l	#font_pals+(15*32),font_pal_addr+4

	move.l	#my_70,$70.w

* do the fade-in!!!
	moveq	#15-1,d7	; perform 15 fades

* do the first fade...
.fade_in:
	sub.l	#32,pal_addr
	sub.l	#32,font_pal_addr+4
	move.w	#second_fade_speed,count_70

.wait_fade:
	tst.w	count_70
	bne.s	.wait_fade

	dbra	d7,.fade_in


.wait:
	cmp.b	#57,$fffffc02.w
	bne.s	.wait

* key pressed! start to fade to black!

	moveq	#15-1,d7	; perform 15 fades

* do the first fade...
.fade_out:
	add.l	#32,pal_addr
	add.l	#32,font_pal_addr+4
	move.w	#last_fade_speed,count_70

.wait_fade_2:
	tst.w	count_70
	bne.s	.wait_fade_2

	dbra	d7,.fade_out

	move.l	(a7)+,$70.w

* turn off sound!
	clr.b	vol1
	clr.b	vol2
	clr.b	vol3

	movem.l	vols,d0-2
	movem.l	d0-2,$ffff8800.w

	jsr	restore
	move.b	(a7)+,$fffffa15.w

	c_on

	move.b	(a7)+,$484.w	; restore keyclick original value
	super_off

	clr.w	-(a7)
	trap	#1

rte:
	rte


my_70:
* interrupts off

	move.w	sr,-(a7)
	or.w	#$0700,sr

	movem.l	d0-7/a0-6,-(a7)

* put in the correct palette!
	move.l	pal_addr,a0	; 20
	movem.l	(a0),d0-7	; 76
	movem.l	d0-7,$ffff8240.w ; 76


* put in correct screen address
	moveq	#0,d0		; 4
	move.w	scrn_no,d0	; 16

	add.w	d0,d0		; 4
	add.w	d0,d0		; 4

	move.l	#screens,a0	; 12
	add.l	d0,a0		; 6

	move.l	(a0),a6		; SCREEN TO WORK ON		12
	move.l	-8(a0),a5	; SCREEN FOR SCROLLING MESSAGE	16
	move.l	-4(a0),d0	; SCREEN TO DISPLAY		16

	pea	(a5)		; keep scrolling message screen address
	pea	(a6)		; keep this screen address

	clr.b	$ffff820d.w	; this clears the STe extra byte  8
	
	lsr.l	#8,d0		; 24
	move.b	d0,$ffff8203.w	; 12
	lsr.w	#8,d0		; 24
	move.b	d0,$ffff8201.w	; slap the screen address in!  12


* play music...

	move.l	mus_addr,a0	; get address of data    20
	move.l	#nos,a1		; and numbers for chip   12

	move.b	(a0)+,2(a1)	; put data into correct positions
	move.b	(a0)+,6(a1)
	move.b	(a0)+,$a(a1)
	move.b	(a0)+,$e(a1)
	move.b	(a0)+,$12(a1)
	move.b	(a0)+,$16(a1)
	move.b	(a0)+,$1a(a1)
	move.b	(a0)+,$1e(a1)
	move.b	(a0)+,$22(a1)
	move.b	(a0)+,$26(a1)
	move.b	(a0)+,$2a(a1)	; 16 x 11 = 176

	move.l	a0,mus_addr	; 20


	movem.l	(a1),a0-2/d0-7	; slap all data into sound chip  100
	movem.l	a0-2/d0-7,$ffff8800.w	; 100


* ---
* 816
* ---

* do some of the sine-wobbler
	move.l	sine_pointer,a0		; 20 
	addq.l	#8,sine_pointer		; 12

	lea	160+72(a6),a6

* a0 will hold the positions of each line of the sprite
	moveq	#0,d1		; this will be the line offset    4

	move.l	#230,d0		; next line on screen   12

	move.l	#(words+4)*2,d2	; next line in sprite addon  12

* --
* 60
* --

	rept	25
	move.l	(a0)+,a4	; get position as LW offset  12
	move.l	(a0)+,d7	; and offset on screen       12

	move.l	a6,a5		; copy screen address        4
	add.l	d7,a5		; move to correct place on screen   6

	add.l	d1,a4		; correct line in sprite...       6


* now we have to slap in an entire line from this sprite...
* but blank out to the left and the right

	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d7,a1		; 4 x 6 = 24

	movem.l	d3-7/a1,-24(a5)	; 60
	movem.l	d3-7/a1,88(a5)	; 60


	movem.l	(a4)+,d3-7/a1-3	; 76
	movem.l	d3-7/a1-3,(a5)	; 76
	
	movem.l	(a4)+,d3-7/a1-3	; 76
	movem.l	d3-7/a1-3,32(a5) ;76

	movem.l	(a4)+,d3-7/a1	; 60
	movem.l	d3-7/a1,64(a5)	; 60

* we've done a whole line!

* goto next line on screen
	add.l	d0,a6		; 6

* and next line in sprite
	add.l	d2,d1		; 6

* ----
* 620 (each line)
* ----
	endr
end_sine:

	rept	132
	nop
	endr

* into 60 Hz
	eor.b	#2,$ffff820a.w

	rept	8
	nop
	endr

* back into 50 Hz
	eor.b	#2,$ffff820a.w


	move.w	#$8209,a2	; Hz
	move.w	#$8260,a1	; resolution
	moveq	#0,d6
	moveq	#16,d7
	moveq	#2,d3
	moveq	#0,d4



.wait:
	move.b	(a2),d6
	beq.s	.wait

	sub.w	d6,d7
	lsl.w	d7,d6

	move.w	#$820a,a2	; sync modus

	rept	95
	nop
	endr

	rept	50

* LEFT HAND BORDER!
	move.b	d3,(a1)		; to monochrome
	move.b	d4,(a1)		; to lo-res
********
* d3 d4 a1 a2
* MUST NOT BE CHANGED!
* or must be changed back before used!

	move.l	(a0)+,a4	; get position as LW offset  12
	move.l	(a0)+,d7	; and offset on screen       12

	move.l	a6,a5		; copy screen address        4
	add.l	d7,a5		; move to correct place on screen   6

	add.l	d1,a4		; correct line in sprite...       6

	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d7,a3		; 4 x 4 = 16

	movem.l	d4-7/a3,-24(a5)	; 52
	movem.l	d4-7/a3,88+4(a5)	; 52

	move.l	d7,-4(a5)	; 16
	move.l	d7,88(a5)	; 16

* 176 cycles
* 164 to play with
	movem.l	(a4)+,d3-7/a3	; 60
	movem.l	d3-7/a3,(a5)	; 60

	moveq	#0,d4
	moveq	#2,d3		; 4 x 2 = 8

	movem.l	(a4)+,d5-7	; 36

	dcb.w	1,$4e71


* RIGHT AGAIN...
	move.b	d4,(a2)
	move.b	d3,(a2)

	movem.l	d5-7,24(a5)	; 36

	dcb.w	4,$4e71

* EXTRA!
	move.b	d3,(a1)
	nop
	move.b	d4,(a1)

	movem.l	(a4)+,d5-7	; 36

	dcb.w	3,$4e71

* LEFT HAND BORDER!
	move.b	d3,(a1)		; to monochrome
	move.b	d4,(a1)		; to lo-res

	movem.l	d5-7,36(a5)	; 36

	movem.l	(a4)+,d3-7/a3	; 60
	movem.l	d3-7/a3,48(a5)	; 60

	movem.l	(a4)+,d3-6	; 44
	movem.l	d3-6,72(a5)	; 44

	moveq	#0,d4
	moveq	#2,d3		; 4 x 2 = 8

* slapped a whole line in!
* goto next line on screen
	add.l	d0,a6		; 6

* and next line in sprite
	add.l	d2,d1		; 6


	dcb.w	23,$4e71

* RIGHT AGAIN...
	move.b	d4,(a2)
	move.b	d3,(a2)

	dcb.w	13,$4e71

* EXTRA!
	move.b	d3,(a1)
	nop
	move.b	d4,(a1)

	dcb.w	12,$4e71

	endr

***** 100 scanlines down now... *****

******************************
******** do ball! ************
******************************

* LEFT HAND BORDER!
	move.b	d3,(a1)		; to monochrome
	move.b	d4,(a1)		; to lo-res

* get screen address again
	move.l	(a7),a6		; 12

* get address in list
	move.l	ball_pos,a3	; 20
	movem.l	(a3)+,d5/a4-5	; 36
	move.l	a3,ball_pos	; 20

* get correct abs address on screen
	add.l	d5,a6		; 6

* a6 = screen addr
* a4 = sprite addr
* a5 = mask addr

* --
* 94
* --
	exg.l	d6,d7

	dcb.w	64,$4e71

* RIGHT AGAIN...
	move.b	d4,(a2)
	move.b	d3,(a2)

	dcb.w	13,$4e71

* EXTRA!
	move.b	d3,(a1)
	nop
	move.b	d4,(a1)

	dcb.w	12,$4e71

***********************
**** MAIN BALL BIT ****
***********************

	rept	31
* LEFT HAND BORDER!
	move.b	d3,(a1)		; to monochrome
	move.b	d4,(a1)		; to lo-res

* get mask LW
	move.l	(a4)+,d7	; 12

* get screen words
	move.l	(a6)+,d5	; 12
	move.l	(a6)+,d6	; 12

* use MASK
	and.l	d7,d5		; 6
	and.l	d7,d6		; 6

* put in sprite...
	or.l	(a5)+,d5	; 10
	or.l	(a5)+,d6	; 10

* slap onto screen
	movem.l	d5-6,-8(a6)	; 28

* ---
* 96
* ---
******************* 2nd word ****************

* get mask LW
	move.l	(a4)+,d7	; 12

* get screen words
	move.l	(a6)+,d5	; 12
	move.l	(a6)+,d6	; 12

* use MASK
	and.l	d7,d5		; 6
	and.l	d7,d6		; 6

* put in sprite...
	or.l	(a5)+,d5	; 10
	or.l	(a5)+,d6	; 10

* slap onto screen
	movem.l	d5-6,-8(a6)	; 28

* ---
* 96
* ---

*************** 3rd word *******************

* get mask LW
	move.l	(a4)+,d7	; 12

* get screen words
	move.l	(a6)+,d5	; 12
	move.l	(a6)+,d6	; 12

* use MASK
	and.l	d7,d5		; 6
	and.l	d7,d6		; 6

* put in sprite...
	or.l	(a5)+,d5	; 10
	or.l	(a5)+,d6	; 10

* slap onto screen
	movem.l	d5-6,-8(a6)	; 28

* ---
* 96
* ---


************* end of sprite line!

	add.l	#230-24,a6	; 14


	dcb.w	2,$4e71


* RIGHT AGAIN...
	move.b	d4,(a2)
	move.b	d3,(a2)

	dcb.w	13,$4e71

* EXTRA!
	move.b	d3,(a1)
	nop
	move.b	d4,(a1)

	dcb.w	12,$4e71

	endr


***** 132 scanlines down now... *****

* scrolling message
* set up registers...
* LEFT HAND BORDER!
	move.b	d3,(a1)		; to monochrome
	move.b	d4,(a1)		; to lo-res

	move.l	(a7)+,a6	; screen to put to	12
	move.l	(a7)+,a5	; screen to grab from	12

bottom	equ	160+(230*227)+8

	move.l	#bottom,d0	; 12
	add.l	d0,a6		; 6
	add.l	d0,a5		; 6
	addq.l	#8,a5		; 8


	move.w	d3,d0		; 4
	move.w	d4,d1		; 4

	move.l	a1,a0		; 4
	move.l	a2,a1		; 4

	dcb.w	71,$4e71

* RIGHT AGAIN...
	move.b	d4,(a1)
	move.b	d3,(a1)

	dcb.w	13,$4e71

* EXTRA!
	move.b	d3,(a0)
	nop
	move.b	d4,(a0)

	dcb.w	12,$4e71


***** 133 scanlines down now... *****


scroller_code:
coun	set	0
	rept	32

* LEFT HAND BORDER!
	move.b	d0,(a0)		; to monochrome
	move.b	d1,(a0)		; to lo-res

	movem.l	(a5)+,d2-7/a0/a2-4	; 92
	movem.l	d2-7/a0/a2-4,coun(a6) ; 92

coun	set	coun+40

	movem.l	(a5)+,d2-7/a2-4	; 84
	movem.l	d2-7/a2-4,coun(a6) ; 84

coun	set	coun+36

* ---
* 352
* ---

	dcb.w	2,$4e71


* RIGHT AGAIN...
	move.b	d1,(a1)
	move.b	d0,(a1)

	movem.l	(a5)+,d2-5	; 44

	move.w	#$8260,a0	; resolution   4


* EXTRA!
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)

	movem.l	d2-5,coun(a6)	; 44
coun	set	coun+16

	nop


* 92 bytes shifted!
* 100 to do!
* LEFT HAND BORDER!
	move.b	d0,(a0)		; to monochrome
	move.b	d1,(a0)		; to lo-res

	movem.l	(a5)+,d2-7/a0/a2-4	; 92
	movem.l	d2-7/a0/a2-4,coun(a6) ; 92

coun	set	coun+40

	movem.l	(a5)+,d2-7/a2-4	; 84
	movem.l	d2-7/a2-4,coun(a6) ; 84

coun	set	coun+36

* ---
* 352
* ---

	move.w	#$8260,a0	; resolution   4



* RIGHT AGAIN...
	move.b	d1,(a1)
	move.b	d0,(a1)

	movem.l	(a5)+,d2-5	; 44

	lea	230-184(a5),a5	; a5 points to start of next scanline!  8

* EXTRA!
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)

	movem.l	d2-5,coun(a6)	; 44
coun	set	coun+16
coun	set	coun+230-184

	nop

* 184 bytes shifted!
* all done!

	endr

***** 197 scanlines down now... *****


do_cols	macro
* set up regs for putting in word of scrolline
* and do 1st few lines of 1st byte...

* LEFT HAND BORDER!
	move.b	d0,(a0)		; to monochrome
	move.b	d1,(a0)		; to lo-res

	move.l	\1,a5		; get addr of column data 20

	movem.l	(a5)+,d2-7	; get some column data	60

* and slap it in...

coun	set	192-8+\2
	movep.l	d2,coun(a6)	; 24
coun	set	coun+230
	movep.l	d3,coun(a6)	; 24
coun	set	coun+230
	movep.l	d4,coun(a6)	; 24
coun	set	coun+230
	movep.l	d5,coun(a6)	; 24
coun	set	coun+230
	movep.l	d6,coun(a6)	; 24
coun	set	coun+230
	movep.l	d7,coun(a6)	; 24
coun	set	coun+230

* ---
* 224
* ---
	movem.l	(a5)+,d2-7	; get some column data	60

	movep.l	d2,coun(a6)	; 24
coun	set	coun+230
	movep.l	d3,coun(a6)	; 24
coun	set	coun+230
	movep.l	d4,coun(a6)	; 24
coun	set	coun+230

* ---
* 356
* ---

	dcb.w	1,$4e71

* RIGHT AGAIN...
	move.b	d1,(a1)
	move.b	d0,(a1)


	movep.l	d5,coun(a6)	; 24
coun	set	coun+230
	movep.l	d6,coun(a6)	; 24
coun	set	coun+230

* --
* 48
* --
	dcb.w	1,$4e71

* EXTRA!
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)

	movep.l	d7,coun(a6)	; 24
coun	set	coun+230

	dcb.w	6,$4e71

* do rest of 1st column...
* 20 lines still to do...
* so do 2 lots of 10 (to make it simpler)

	rept	2
* LEFT HAND BORDER!
	move.b	d0,(a0)		; to monochrome
	move.b	d1,(a0)		; to lo-res

	movem.l	(a5)+,d2-7	; get some column data	60

* and slap it in...
	movep.l	d2,coun(a6)	; 24
coun	set	coun+230
	movep.l	d3,coun(a6)	; 24
coun	set	coun+230
	movep.l	d4,coun(a6)	; 24
coun	set	coun+230
	movep.l	d5,coun(a6)	; 24
coun	set	coun+230
	movep.l	d6,coun(a6)	; 24
coun	set	coun+230
	movep.l	d7,coun(a6)	; 24
coun	set	coun+230

* ---
* 204
* ---
	movem.l	(a5)+,d2-6	; get some column data	52

	movep.l	d2,coun(a6)	; 24
coun	set	coun+230
	movep.l	d3,coun(a6)	; 24
coun	set	coun+230
	movep.l	d4,coun(a6)	; 24
coun	set	coun+230
	movep.l	d5,coun(a6)	; 24
coun	set	coun+230

* ---
* 352
* ---
	nop
	nop


* RIGHT AGAIN...
	move.b	d1,(a1)
	move.b	d0,(a1)

	movep.l	d6,coun(a6)	; 24
coun	set	coun+230

* --
* 24
* --
	dcb.w	7,$4e71

* EXTRA!
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)

	dcb.w	12,$4e71
	endr
	endm

* do left hand border!
	do_cols	left_col,0

* then right hand border
	do_cols	right_col,1

* we have used up 6 scanlines doing that...

***** 203 scanlines down now... *****


	rept	24
* LEFT HAND BORDER!
	move.b	d0,(a0)		; to monochrome
	move.b	d1,(a0)		; to lo-res

	dcb.w	90,$4e71

* RIGHT AGAIN...
	move.b	d1,(a1)
	move.b	d0,(a1)

	dcb.w	13,$4e71

* EXTRA!
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)

	dcb.w	12,$4e71
	endr


* FINAL LINE
* LEFT HAND BORDER!
	move.b	d0,(a0)		; to monochrome
	move.b	d1,(a0)		; to lo-res

font_pal_addr:
	movem.l	font_pals,d2-7/a3-4	; get font palette   84

	dcb.w	50,$4e71

	movem.l	d2-7/a3-4,$ffff8240.w	; 76

* RIGHT AGAIN...
	move.b	d1,(a1)
	move.b	d0,(a1)

	dcb.w	13,$4e71

* EXTRA!
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)

* BUST BOTTOM BORDER...
	dcb.w	8,$4e71
	move.b	d1,(a1)
	move.b	d0,(a1)

* BOTTOM BORDER LEFT & RIGHTS!
bot_lines	equ	32
	rept	bot_lines
* LEFT HAND BORDER!
	move.b	d0,(a0)		; to monochrome
	move.b	d1,(a0)		; to lo-res

	dcb.w	90,$4e71

* RIGHT AGAIN...
	move.b	d1,(a1)
	move.b	d0,(a1)

	dcb.w	13,$4e71

* EXTRA!
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)

	dcb.w	12,$4e71


	endr

* now do the things which will make decisions...

* music first...
	subq.w	#1,mus_count
	bne.s	.not_music

* loop back to start of sound!
	move.l	#music_data,mus_addr
	move.w	#$1002,mus_count

.not_music:

* now screen number
	move.l	#scrn_no,a0
	addq.w	#1,(a0)
	cmp.w	#no_of_scrns,(a0)
	bne.s	.not_scrn

	clr.w	(a0)
.not_scrn:

	move.l	#sine_count,a0
	subq.w	#1,(a0)
	bne.s	.not_sine

	move.l	#offsets,sine_pointer
	move.w	#sine_len-spr_h,(a0)
.not_sine:
* now the ball list...
	subq.w	#1,ball_count
	bne.s	.not_ball

	move.l	#ball_offsets,ball_pos
	move.w	#ball_dat_len/3,ball_count
.not_ball:
* now the scrolly message updates...
	move.l	right_col,left_col  ; right column is left column next time
	add.l	#128,right_col	    ; right column is next column next time!

	subq.w	#1,font_counter
	bne.s	.not_font

	move.w	#4,font_counter
* calculate the next character's address!
	move.l	font_pos,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.s	.not_zed

* re-start message
	move.l	#message,a0
	move.b	(a0)+,d0

.not_zed:
	move.l	a0,font_pos
	sub.b	#" ",d0

	mulu	#512,d0		; offset of character data
	add.l	#font_data,d0
	move.l	d0,right_col
.not_font:

	subq.w	#1,count_70

	movem.l	(a7)+,d0-7/a0-6
	move.w	(a7)+,sr
	rte


fade_out:
	tst.w	fade_flag
	bne	.no_fade

	subq.w	#1,fade_count
	bne	.no_fade

	move.w	#first_fade_speed,fade_count

	movem.l	d0-7/a0,-(a7)
* do a fade!!!
	move.l	pal_addr,a0
	movem.l	(a0)+,d0-7
	movem.l	d0-7,$ffff8240.w
	move.l	a0,pal_addr

* have I done the last one?
	subq.w	#1,no_fades
	bne.s	.no_end

* yup!
	st	fade_flag

.no_end:
	movem.l	(a7)+,d0-7/a0

.no_fade:
	rte


sine_longs:
* convert bytes in sine-wave data to longword offsets
* NOW, to save time on the routine.

	move.l	#sine_list,a0
	move.l	#offsets,a1

	move.w	#sine_len-1,d0
convert:

	move.b	(a0)+,d7
	ext.w	d7		; as a word
	
	moveq	#0,d6
	move.w	d7,d6

	and.w	#$f,d6		; d6 holds pixels in we need to go
	asr.w	#1,d7
	and.b	#$f8,d7		; equivalent to d7/16*8
				; don't believe me?
				; try it on paper!

	subq.l	#8,d7		; go 2 LWs back (for CLR.L in routine)
	
* d7 now holds no of words we need to go from the centre of the screen
	ext.l	d7

	mulu	#spr_len,d6	; multiply pixel in by length of sprite
	add.l	#sprites,d6	; get abs addr of sprite line!


	move.l	d6,(a1)+
	move.l	d7,(a1)+

	dbra	d0,convert

* now we are at the end of the list.  It now holds a lot of Longwords
* all of 0.  This is not good.  They are meant to be the screen
* offset-8 and the sprite address.  So fill them in!

	moveq	#-8,d7
	move.l	#sprites,d6
	moveq	#rest_len-1,d0
.fill:
	move.l	d6,(a1)+
	move.l	d7,(a1)+
	dbra	d0,.fill

* now do the ball lorenz attractor co-ords to LW screen offset
* sprite address and mask address

	move.l	#ball_dat,a0
	move.l	#ball_offsets,a1
	move.w	#ball_dat_len/3-1,d7

conv_ball:
* get an x co-ord!
	moveq	#0,d0
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0

	move.l	d0,d1
	and.w	#$f,d0		; d0 = co-ord number
	lsr.w	#1,d1
	and.w	#$fff8,d1	; equivalent to d1/16*8

* d1 holds word no on screen...

* get the y co-ord
	moveq	#0,d2
	move.b	(a0)+,d2

	move.l	#160+(230*75),d3 ; skip first line & big sprite 75 lines
	mulu	#230,d2
	add.l	d2,d3

	add.l	d1,d3
	move.l	d3,(a1)+	; give screen offset

* now work out sprite & mask addresses
	move.l	d0,d1

	mulu	#pre_mask_len,d0
	add.l	#pre_masks,d0
	move.l	d0,(a1)+	; mask address

	mulu	#pre_ball_len,d1
	add.l	#pre_balls,d1
	move.l	d1,(a1)+	; sprite address

	dbra	d7,conv_ball


	rts


do_pre:
* pre-shift the sprites

	move.l	#sprite,a0
	move.l	#sprites,a1
	moveq	#words,d0
	moveq	#spr_h,d1
	jsr	pre_shift

	move.l	#ball,a0
	move.l	#pre_balls,a1
	moveq	#8,d0
	moveq	#31,d1
	jsr	pre_shift


	move.l	#mask,a0
	move.l	#pre_masks,a1
	moveq	#2,d0
	moveq	#31,d1
	jsr	pre_shift_mask

* now double the ball masks form WORDS to LONGWORDS for extra speed
	move.l	#pre_masks+(tot_mask_len),a0
	move.l	#pre_masks+(tot_mask_len/2),a1
	move.w	#tot_mask_len/4-1,d0

.double:
	move.w	-(a1),d1
	move.w	d1,-(a0)
	move.w	d1,-(a0)
	dbra	d0,.double


	rts

fades:
	move.l	#pal,a0
	move.l	#new_pals,a1
	jsr	fade_a_pal

	move.l	#sprite_pal,a0
	move.l	#sprite_pals,a1
	jsr	fade_a_pal

	move.l	#font_pal,a0
	move.l	#font_pals,a1
	jsr	fade_a_pal

	rts


do_screens:
	move.l	#scrns,d0
	add.l	#255,d0
	clr.b	d0

* make screen list
	move.l	#screens,a0
	move.l	a0,a1

	moveq	#no_of_scrns-1,d7
.list:
	move.l	d0,(a0)+
	add.l	#59904,d0
	add.l	#255,d0
	clr.b	d0

	dbra	d7,.list

	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)

	rts


do_loads:
* load in sprite data, font data, etc etc

	move.l	#file_names,a6
	move.l	#file_lens,a5
	move.l	#file_addrs,a4

.loop:
	move.l	(a4)+,a1
	move.l	(a5)+,d0
	move.l	a6,a0
	bsr	load_file

* get next filename
.get:
	tst.b	(a6)+
	bne.s	.get

* end of list?
	tst.b	(a6)
	bne.s	.loop

	rts

file_names:
	dc.b	"\includes\font.dat",0
	dc.b	"\includes\sprite.dat",0
	dc.b	"\all.010\big_s.dat",0
	dc.b	"\all.010\big_l.dat",0
	dc.b	0
	even

font_len	equ	30720
sprite_len	equ	6000
big_s_len	equ	1894
big_l_len	equ	8076

file_lens:
	dc.l	font_len
	dc.l	sprite_len
	dc.l	big_s_len
	dc.l	big_l_len

file_addrs:
	dc.l	font_data
	dc.l	sprite
	dc.l	sine_list+75
	dc.l	ball_dat

	include	\includes\load.s


sprite_pal:
	incbin	\includes\spr_pal.dat


sine_pointer	dc.l	offsets
sine_count	dc.w	sine_len-spr_h



* ball sprite
ball:
	incbin	\includes\ball.dat
ball_len	equ	*-ball

mask:
	incbin	\includes\ballmas2.dat
mask_len	equ	*-mask

ball_pos	dc.l	ball_offsets
ball_count	dc.w	ball_dat_len/3


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


mus_addr	dc.l	music_data
mus_count	dc.w	$1002

scrn_no	dc.w	0

* the 2 columns to put in at the right hand word
* (they start at the SPACE!)

left_col	dc.l	font_data
right_col	dc.l	font_data

font_pal:
	incbin	\includes\font_pal.dat

font_counter	dc.w	1
font_pos	dc.l	message

message:
	DC.B	"       JAMES INGRAM PRESENTS A FULL-SCREEN DEMO.   "
	DC.B	"NOT TOO IMPRESSIVE, BUT THERE'S A LOT OF PROCESSOR TIME LEFT OVER THAT I DIDN'T USE.  "
	DC.B	'THIS SCREEN IS ONE OF 2 SCREENS WHICH ARE THE ULTIMATE PRODUCT OF MY "INTRODUCTION TO DEMO CODING" DOCUMENTS.  '
	DC.B	"TO SEE HOW TO GET HOLD OF THESE DOCUMENTS, SEE THE DOC FILE WITH THIS DEMO, OR SEND A 5 PUND CHQUE TO:-    JAMES INGRAM      C/O CHRIS     84 NORTH STREET     RUSHDEN     NORTHAMPTONSHIRE     NN10 9BU          "
	DC.B	"CHEQUES ONLY, PLEASE - NO CASH OR POSTAL ORDERS.       NO CASH!!!    NO CASH!!!              NO CASH!!!       (GET THE MESSAGE?)            NO CASH!!!!!!             "
	DC.B	0

	even

	include	\includes\init.s
	include	\includes\fades.s
	include	\includes\pre_shft.s
	include	\includes\de_mus.s


	section	bss

count_70	ds.w	1


*** FADE VARIABLES ***
fade_count	ds.w	1
no_fades	ds.w	1
fade_flag	ds.w	1
pal_addr	ds.l	1
***

sprite_pals	ds.b	16*32
new_pals	ds.b	16*32
font_pals	ds.b	16*32



*** BIG SPRITE PRE-SHIFTED
sprites:
	ds.w	words*spr_h*16	; sprites
	ds.b	spr_h*8*16	; blanks at right

*** SCREEN AREA
scrns:
	ds.b	256
	ds.b	no_of_scrns*60928
sc_len	equ	*-scrns

	ds.l	2
screens:
	ds.l	no_of_scrns


****

music_data	ds.b	45078

*** ball data

pre_balls	ds.b	(ball_len+(8*31))*16
pre_ball_len	equ	(*-pre_balls)/16

pre_masks	ds.b	(mask_len+(2*31))*16*2
pre_mask_len	equ	(*-pre_masks)/16
tot_mask_len	equ	*-pre_masks

font_data	ds.b	font_len

sprite		ds.b	sprite_len

* the SINE list...
sine_list
	ds.b	75
	ds.b	big_s_len
	ds.b	75
sine_len	equ	*-sine_list
	even

*** LIST OF LW OFFSETS FOR SINE-WOBBLER
offsets	ds.l	sine_len*2
rest
	ds.l	spr_h*2
rest_len	equ	(*-rest)/8	; the number of positions in the trailing part of the list


* the BALL list...
ball_dat:
	ds.b	big_l_len
ball_dat_len	equ	*-ball_dat
	even


ball_offsets	ds.l	ball_dat_len



