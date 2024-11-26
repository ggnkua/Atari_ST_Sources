* sample player for "Pixie" Dave
* by James Ingram, May 1994



click	equ	$484

;labels	equ	1

max_samples	equ	19

up_arrow	equ	$48
down_arrow	equ	$50


	ifd	labels
	opt	x+
	endc

	opt	o+,ow-


;link	equ	1


	ifd	link
	OPT	GST,CASE
	
	XREF	aes,print_line,to_lower,num_to_asc,conin_no_echo
	XREF	res_mem,rel_mem
	XREF	file_selector,load_a_file
	endc

	include	macros.s
	include	lens.i
	include	aes_defs.i
	include	gem_defs.i

label:
	include	proghead.s


	super_on
	move.b	click.w,old_click
	and.b	#%11111100,click.w
	super_off

* display MAIN screen
	bsr	main_screen

	super_on
	move.b	old_click,click.w
	super_off

	clr.w	-(a7)
	trap	#1


main_screen:
	print	main_top

	moveq	#-1,d0
	bsr	res_mem	
	bsr	num_to_asc
	bsr	print_line

	print	main_middle

	bsr	print_samples

wait_valid:
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7

got_a_key:
	bsr	to_lower

	cmp.b	#"r",d0
	beq	random_mode

	cmp.b	#"l",d0
	beq	load_one
	
	cmp.b	#"d",d0
	beq	delete_one

	cmp.b	#"p",d0
	beq	play_one
	
	cmp.b	#"q",d0
	beq	quit

	tst.w	d0
	bne	wait_valid

	swap	d0

	cmp.w	#up_arrow,d0
	beq	go_up

	cmp.w	#down_arrow,d0
	beq	go_down

	bra	wait_valid


random_mode:
* enter random mode!
	tst.w	no_loaded
	bne.s	.ok
	bra	main_screen


.ok:
	print	random
	print	stat

	print	loadi
	bsr	load_random

	print	waiting

.wait_key:
	move.w	#$ff,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq.l	#4,a7
	tst.w	d0
	bne.s	.keypress

	dc.w	$a000

	move.b	-348(a0),d0	; get mouse status
	btst	#0,d0
	beq.s	.wait_key

* mouse button pressed!
	print	playing
	bsr	play_it


	move.l	sam_addr,d0
	bsr	rel_mem

	print	loadi
	bsr	load_random

	print	waiting

	dc.w	$a000

.wait_mouse:
	move.b	-348(a0),d0
	btst	#0,d0
	bne.s	.wait_mouse


	bra	.wait_key

.keypress:
	cmp.w	#$1b,d0
	bne	.wait_key

	bra	main_screen


load_random:
* get random number
	move.w	#17,-(a7)
	trap	#14
	addq.l	#2,a7

	swap	d0
	clr.w	d0
	swap	d0


	divu	#max_samples-1,d0
	clr.w	d0
	swap	d0

	move.w	d0,selected
	bsr	sam_name

	tst.b	(a0)
	beq.s	load_random	; keep looking if null sample!

* got a sample!!!
	print	loadi

	bsr	load_it
	tst.l	d0
	bmi	load_random

	bsr	design
	rts


go_up:
* go to next sample up

	move.w	selected,d0
	subq.w	#1,d0
	bpl	.num_ok

	moveq	#0,d0

.num_ok:
	move.w	d0,selected
	bsr	print_samples

	bra	wait_valid



go_down:
* go to next sample down

	move.w	selected,d0
	addq.w	#1,d0
	cmp.w	#max_samples,d0
	bne.s	.num_ok

	subq.w	#1,d0

.num_ok:
	move.w	d0,selected
	bsr	print_samples
	bra	wait_valid



quit:
* QUIT SELECTED!
	alert	#1,quit_txt
	cmp.w	#1,d0
	beq	wait_valid

	rts

load_one:
* load a sample...
	
	lea	star(pc),a0
	bsr	file_selector

	tst.l	d0
	bmi	main_screen

* something loaded!
* address in d0
* len in d1
* a0 = filename
* a1 = pathname

* get sample number

	movem.l	a0-1/d0-1,-(a7)

	bsr	sam_name
	tst.b	(a0)
	beq.s	.no_sub

	subq.w	#1,no_loaded
.no_sub:
	movem.l	(a7)+,d0-1/a0-1

	addq.w	#1,no_loaded

	moveq	#0,d7
	move.w	selected,d7

* x 128 for offset in names
	mulu	#128,d7
	move.l	#sample_names,a6
	add.l	d7,a6

	move.l	a6,a5		; keep address for later
	addq.l	#1,a5
	move.b	#":",(a5)+

* put in path
.path:
	move.b	(a1)+,(a5)+
	bne.s	.path

	subq.l	#1,a5
* put in filename
.name:
	move.b	(a0)+,(a5)+
	bne.s	.name

* put in drive
	move.w	#$19,-(a7)
	trap	#1
	addq.l	#2,a7

	add.b	#"A",d0
	move.b	d0,(a6)

	bra	main_screen


play_one:
* is it empty?
	bsr	sam_name
	tst.b	(a0)
	beq	wait_valid


	print	loading
	bsr	sam_name
	bsr	print_line
	bsr	load_it

	tst.l	d0
	bmi	main_screen

	bsr	design


play_loop:
	print	press_play

.invalid:
	wait_key

	cmp.b	#" ",d0
	beq.s	do_play

	cmp.w	#$1b,d0
	bne.s	.invalid

dun_with_sam:
* canceled!
	move.l	sam_addr,d0
	bsr	rel_mem


	bra	main_screen

sam_error:
	alert	#1,too_short
	bra.s	dun_with_sam


do_play:
	bsr	mouse_off
	bsr	play_it
	bsr	mouse_on
	bra	play_loop


design:
* de-sign sample!
	move.l	sam_addr,a0
	move.w	#128,a1

	move.l	sam_len,d0
	sub.l	a1,d0
	bmi	.rts
	beq	.rts

	add.l	a1,a0

.design:
	eor.b	#$80,(a0)+
	subq.l	#1,d0
	bne.s	.design

.rts:
	rts


load_it:
* load it in!
	bsr	sam_name
	moveq	#0,d0
	bsr	load_a_file

	move.l	d0,sam_addr
	move.l	d1,sam_len
	rts

rte:
	rte

play_it:
	super_on
	
	init_chip

	move.w	sr,-(a7)
*	or.w	#$0700,sr
	c_off
	move.l	$70.w,-(a7)
	move.l	#rte,$70.w

	move.l	sam_addr,a0
	move.l	sam_len,d0
	move.w	#128,a1
	add.l	a1,a0
	sub.l	a1,d0

	move.l	#sound,a5
	move.l	#table,a1
* do the play!
playit:
	moveq	#0,d7
	move.b	(a0)+,d7
	add.w	d7,d7
	add.w	d7,d7

	move.l	a1,a2
	add.l	d7,a2

	move.b	(a2)+,voice_a-sound(a5)
	move.b	(a2)+,voice_b-sound(a5)
	move.b	(a2)+,voice_c-sound(a5)

	movem.l	(a5),d2-4
	movem.l	d2-4,$ffff8800.w

* pause for a bit!
	move.w	#22,d7
.pause:
	dbra	d7,.pause


	subq.l	#1,d0
	bne	playit

	move.l	(a7)+,$70.w
	c_on
	move.w	(a7)+,sr


	clr.b	voice_a
	clr.b	voice_b
	clr.b	voice_c

	movem.l	sound,d4-6
	movem.l	d4-6,$ffff8800.w

	super_off

	rts



delete_one:
* is it empty?
	bsr	sam_name

	tst.b	(a0)
	beq	wait_valid


* confirm
	alert	#2,delete
	cmp.w	#2,d0
	bne	main_screen

* really delete it!
	bsr	sam_name
	clr.b	(a0)

	bra	main_screen

sam_name:
	moveq	#0,d0
	move.w	selected,d0
	mulu	#128,d0
	move.l	#sample_names,a0
	add.l	d0,a0
	rts


print_samples:
* go to correct screen position
	print	sample_pos

	moveq	#1,d7		; sample no 1
	
prt_loop:
* is it the selected one?
	move.w	d7,d0
	subq.w	#1,d0
	cmp.w	selected,d0
	bne.s	.not_selected

	print	invert


.not_selected:


	move.l	d7,d0
	bsr	num_to_asc
	bsr	print_line

	print	spaces

	move.l	d7,d0
	subq.l	#1,d0

	bsr	get_sample_name
	bsr	print_line

	print	new_line
	addq.w	#1,d7
	cmp.w	#max_samples+1,d7
	bne.s	prt_loop


	rts

get_sample_name:
* returns:
* a0 = sample name or "EMPTY"
* d0 = 0 if found, -1 if empty

	mulu	#128,d0
	move.l	#sample_names,a0
	add.l	d0,a0

* is it null?
	tst.b	(a0)
	beq.s	.null
	moveq	#0,d0	; no error
	rts

.null:
	lea	empty(pc),a0
	moveq	#-1,d0

	rts


mouse_off:
* turn off the mouse
	move.w	#34,-(a7)
	trap	#14		; get table
	addq.l	#2,a7
	
	move.l	d0,a0
	move.l	16(a0),mouse_vec	; store mouse vector

	pea	0.w
	pea	0.w
	pea	0.w
	trap	#14		; mouse off
	lea	12(a7),a7
	rts
mouse_vec	dc.l	0

mouse_on:
	move.l	mouse_vec,-(a7)
	pea	mouse_params(pc)
	move.w	#1,-(a7)
	clr.w	-(a7)
	trap	#14		; turn mouse on
	lea	12(a7),a7

* send message to keyboard to wake mouse up!!!
	pea	mousey(pc)
	move.w	#0,-(a7)
	move.w	#25,-(a7)
	trap	#14
	addq.l	#8,a7

	rts

mousey:
	dc.b	$11,0

mouse_params:
	dc.b	0,1,1,1


main_top:
	dc.b	27,"ESAMPLE PLAYER by James Ingram, May 1994 for Dave",10,13
	dc.b	10,13
	dc.b	"Free Memory: ",0

main_middle:
	dc.b	10,13,10
	dc.b	"L = LOAD SAMPLE     D = DELETE SAMPLE    "
	dc.b	"P = PLAY SAMPLE     Q = QUIT",10,13
	dc.b	"                            R = RANDOM MODE"

new_line:	dc.b	27,"q",10,13,0

invert:	dc.b	27,"p",0

sample_pos:	dc.b	27,"Y",32+5,32,0

spaces:
	dc.b	"    ",0
empty:
	dc.b	"*** EMPTY ***",0

loading:
	dc.b	27,"E"
	dc.b	27,"q *** LOADING *** ",27,"q",10,13,0

press_play:
	dc.b	27,"E"
	dc.b	"Press SPACE to play sample",10,13
	dc.b	"or ESC to cancel",10,13,0

too_short:
	exclam
	dc.b	"[This is not a sample!  |"
	dc.b	"It is too short!]"
	dc.b	"[Ah.]",0


quit_txt:
	stopp
	dc.b	"[Do you really want to QUIT??  ]"
	dc.b	"[No|YES]",0

delete:
	stopp
	dc.b	"[Really delete this sample?  ]"
	dc.b	"[No|YES]",0

out_mem:
	exclam
	dc.b	"[Out of memory!  ]"
	dc.b	"[BUM.]",0

random:
	dc.b	27,"E"
	dc.b	"RANDOM PLAYING MODE",10,13,10
	dc.b	"Press left mouse button to play random sample.",10,13
	dc.b	"Press <ESCAPE> for main menu",10,13,10,13,10,0

stat:
	dc.b	27,"Y",32+10,32,"Status:",0

loadi:
	dc.b	27,"Y",32+10,32+10,"Loading ",0

playing:
	dc.b	27,"Y",32+10,32+10,"Playing ",0

waiting:
	dc.b	27,"Y",32+10,32+10,"Waiting...",0

star:
	dc.b	"*.AVR",0


	even

	ifnd	link
	include	gem_shel.s
	include	aes_shel.s
	include	maths.s
	include	bits.s
	include	files.s
	endc

selected	dc.w	0
no_loaded	dc.w	0

sound:
	dc.b	8,8
voice_a	dc.b	0,0
	dc.b	9,9
voice_b	dc.b	0,0
	dc.b	10,10
voice_c	dc.b	0,0


table	incbin	sound.bin


	section	bss

mem_len		ds.l	1
mem_free	ds.l	1
mem_addr	ds.l	1

sample_names:
	ds.b	max_samples*128
	even

sam_addr	ds.l	1
sam_len		ds.l	1


	ds.b	5000
stack:

	old

finished_flag:
	ds.w	1



mouse_stat	ds.w	1
old_click	ds.w	1
