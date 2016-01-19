* Intro for Mug Uk
* Coded by ()rm of Digi Tallis of Humbug
* (C) Humbug 1993/1994/eternity

* The starfield rout may look like it can handle verticle starfields
* but it CAN'T! Horizontal only! This is cos I was blind drunk when
* I wrote the routine!  Usually the best way to code, but not this time..

* Right, here we go with the explanation

* If you whack space it will jump to QUIT_ALL. This is where you put your
* usual trainer code.
* I haven't made it so you include the game file. Either you do it, or you
* give it to M.S.D. But I've been too busy on a game. Soz 'bout that..
* BUT! You DO get a rather nice point plotter. By all means spread it..

* If you want to change then sprite..tough! ;) Nah, drop us an e-mail, 
* and I'll send you the creator..

* Change the stars? Again, drop us an e-mail..
* Change the textprint font. nope. nah nah nah.. 
* Change the scrolly font. As above.. e-mail us.

* Have fun matey, and I hope you like it. Would make a rather nice menu
* for Magic Sector if you don't use it!

	opt	x-,ow+


X_SPEED		equ	4		;change for sprite
Y_SPEED		equ	5		;change for sprite.
NUM_STARS	equ	130

	clr.l 	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,savesp	
	lea	$80000,sp	;whack the stack in free space


*	Main Branch Table!!		*

	bsr	screen_in
	bsr	store_p
	bsr	pal_in
	rept	2
	bsr	clear_base
	jsr	text_print
	bsr	flipper
	endr

	move.w	#1,d0
	jsr	music		;jess tune AHOY!

	bsr	save_othershit
	bsr	new_vecs	

**** You wanna wait a vbl? just JSR WAIT_VBL 
	

etern				
	jsr	wait_vbl

	move.l	old_old_sprite_x_pos,d0
	move.l	old_old_sprite_y_pos,d1
	jsr	clear_sprite

	jsr	calc_y_pos
	jsr	calc_x_pos
	move.l	sprite_x_pos,d0
	move.l	sprite_y_pos,d1
	jsr	draw_sprite

	move.l	old_sprite_x_pos,old_old_sprite_x_pos
	move.l	old_sprite_y_pos,old_old_sprite_y_pos
	move.l	sprite_x_pos,old_sprite_x_pos
	move.l	sprite_y_pos,old_sprite_y_pos

	jsr	scroll_rout
	jsr	copy_scroll

	jsr	clear_points
	jsr	do_starfield

	jsr	flipper
	bra	etern


quit_all 
	jsr	music+4
	bsr	bang_um_back
	bsr	pal_out
	bsr	screen_out

usr	move.l	savesp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	clr.w	-(sp)
	trap	#1

********* Insert Relocation Code Here !


********* Code from here on in..

screen_in	
	move.w	#0,-(sp)
	move.l	base,-(sp)
	move.l	base,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	add.w	#12,sp
	rts


screen_out 	
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	add.w	#12,sp
	rts


pal_in	move.l	#pal,-(sp)
	move.w	#$6,-(sp)
	trap	#14
	addq.w	#6,sp
	rts

pal_out	move.l	#gempal,-(sp)
	move.w	#$6,-(sp)
	trap	#14
	addq.w	#6,sp
	rts

store_p	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,gempal
	rts


clear_base
	move.l	base,a0
	move.w	#32000-1,d0
clear_it
	clr.b	(a0)+
	dbra	d0,clear_it
	rts


flipper	
	move.l	base,nxt_base
	add.l	#4,base_place
	lea	flipper_dat,a0
	add.l	base_place,a0
	cmpi.w	#$ffffffff,(a0)
	bne	go_flipper
	clr.l	base_place
	lea	flipper_dat,a0	
go_flipper
	move.l	(a0),base
flip_screens
	move	#$8201,a0
	move.l	base,d0
	lsr.l	#8,d0
	movep	d0,(a0)
	rts


save_othershit
	move.l	$70.w,old_vbl
	move.l	$120.w,old_hbl
	move.b	$fffffa1b,old_a1b
	move.b	$fffffa21,old_a21
	move.b	$fffffa07,old_a07
	move.b	$fffffa09,old_a09
	move.b	$fffffa13,old_a13
	move.b	$fffffa15,old_a15
	rts


bang_um_back
	move.w	#$2700,sr
	move.l	old_vbl,$70.w
	move.l	old_hbl,$120.w
	move.b	old_a1b,$fffffa1b.w
	move.b	old_a21,$fffffa21.w
	move.b	old_a07,$fffffa07.w
	move.b	old_a09,$fffffa09.w
	move.b	old_a13,$fffffa13.w
	move.b	old_a15,$fffffa15.w
	move.w	#$2300,sr
	rts


new_vecs
	move.w	#$2700,sr	;tell everythinn to shut up
	move.l	#vbl,$70.w
	move.l	#hbl,$120.w
	clr.b	$fffffa09.w
	move.b	#1,$fffffa07
	move.b	#1,$fffffa13.w
	clr.b	$fffffa1b.w
	bclr.b	#6,$fffffa15	;take no stick
	move.w	#$2300,sr
	rts

wait_vbl
	cmp.b	#1,vbl_flag
	bne.s	wait_vbl
	clr.b	vbl_flag
	rts


vbl	
	cmpi.b	#185,$fffc02		;compare for space..
	bne.s	.no_space
	lea	quit_all,a0
	jmp	(a0)
.no_space
	clr.b	$fffffa1b.w		;stop b
	move.b	#2,$fffffa21		;timer b count
	lea	raster_cols,a6
	move.b	#8,$fffffa1b.w		;start b
	jsr	music+8		;yeah....
	move.b	#1,vbl_flag	;set it so other routs can go NOW!
	rte


hbl	
	move.w	(a6)+,$ff8240
	move.w	(a6),$ff8250		
	move.w	(a6),$ff8252
	move.w	(a6),$ff8254		
	move.w	(a6),$ff8256
	move.w	(a6),$ff8258
	move.w	(a6),$ff825a
	move.w	(a6)+,$ff825c		
	bclr	#0,$fffffa0f.w
	rte


raster_cols
		;first colour is the BACKGROUND colour
		;second is the text and scroller colours!
	rept	31		;text colours..
	dc.w	$0,$750	;a total of 93 colours.
	dc.w	$0,$720	;if you change them, you MUST have
	dc.w	$0,$600	;93 colours!
	endr

	dc.w	$0,$000	;must be black
	dc.w	$1,$322	;don't ask!
	dc.w	$3,$544	;scroller colours
	dc.w	$4,$777
	dc.w	$3,$544
	dc.w	$2,$322	
	dc.w	$0,$0
	even


*********** Whack all your CODE here!!

scroll_rout
	addq.w	#1,bit_count		;add 1 to rol counter
	cmpi.w	#9,bit_count		;compare it to end of word
	bne.s	scroll_main		;NOOO
	clr.w	bit_count	
scroll_update			
	addq.w	#1,letter	
	lea	text,a0		
	add.w	letter,a0	
	cmpi.b	#$ff,(a0)	
	bne.s	scroll_next_letter
	lea	text,a0			
	clr.w	letter			
scroll_next_letter			
	moveq.w	#0,d0			
	move.b	(a0)+,d0		
	sub.w	#32,d0			
	mulu.w	#16,d0			
	lea	font,a0			
	add.w	d0,a0			
	lea	temp_buffer,a1		
	rept	8			; Y        
	move.w	(a0)+,(a1)+	        
	endr		
scroll_main
	lea	scroll_buffer,a0
	add.l	#2*160,a0
	lea	temp_buffer,a1
	rept	8			; Y
	roxl	(a1)
	roxl.w	152(a0)
	roxl.w	144(a0)
	roxl.w	136(a0)
	roxl.w	128(a0)
	roxl.w	120(a0)
	roxl.w	112(a0)
	roxl.w	104(a0)
	roxl.w	96(a0)
	roxl.w	88(a0)
	roxl.w	80(a0)
	roxl.w	72(a0)
	roxl.w	64(a0)
	roxl.w	56(a0)
	roxl.w	48(a0)
	roxl.w	40(a0)
	roxl.w	32(a0)
	roxl.w	24(a0)
	roxl.w	16(a0)
	roxl.w	8(a0)
	roxl.w	(a0)
	lea	160(a0),a0
	addq.w	#2,a1
	endr
	rts
copy_scroll
	add.l	#4,scroll_place_y
	lea	scroll_place_data,a0
	add.l	scroll_place_y,a0
	cmpi.l	#$ffffffff,(a0)
	bne.s	.no_such_luck
	clr.l	scroll_place_y
	lea	scroll_place_data,a0
	add.l	scroll_place_y,a0
.no_such_luck
	move.l	nxt_base,a1
	move.l	(a0),d0
	mulu	#160,d0
	add.l	d0,a1
	add.l	#6,a1
	lea	scroll_buffer,a2
i	set	0
	rept	12*20		;copy_scroller
	move.w	i(a2),i(a1)
i	set	i+8
	endr
	rts

scroll_place_data
	dc.l	188,188,188,188,189,189
	dc.l	190,191,191,192,192,192,192
	dc.l	191,191,190,189,189

	dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	even
scroll_place_y
	dc.l	0
	even

	;pass in text location in a0
text_print
	clr.l	bit_place
	lea	test_text,a0
	move.l	x_text_pos,d0
	move.l	y_text_pos,d1
go_printer
	cmpi.b	#0,(a0)			;terminate text!!
	beq	quit_text_print
	cmpi.b	#13,(a0)		;return to beginning of line.
	beq	back_to_beginning
	cmpi.b	#10,(a0)		;down a line.
	beq	down_a_line

	cmp.b	#32,(a0)		;less than space
	blt	no_print
	cmp.b	#126,(a0)		;bigger than lower z	
	bgt	no_print

	move.l	base,a1			;\
	add.l	#4,a1
	add.l	d0,a1			;-get right place on screen!
	add.l	d1,a1			;/
	lea	text_font,a2
	moveq.l	#0,d2
	move.b	(a0)+,d2		;store letter in data reg!
	sub.b	#32,d2			;right in bank
	lsl.l	#3,d2			;mulu	#8,d2
	add.l	d2,a2

	rept	8
	move.b	(a2)+,d3
	or.b	d3,0(a1)
	or.b	d3,2(a1)
	lea	160(a1),a1
	endr

	cmp.l	#1,bit_place
	beq.s	second_8
	add.l	#1,bit_place
	addq.l	#1,d0	
	bra.s	compare_for_end
second_8
	move.l	#0,bit_place
	addq.l	#7,d0	
compare_for_end
	cmp.l	#160,d0
	beq.s	back_and_down	
	bra	go_printer
quit_text_print
	rts

back_and_down
	move.l	x_text_pos,d0
	move.l	#0,bit_place
	bra.s	down_a_line
	bra	go_printer	;security reasons!!! (ahah! lazy!)
back_to_beginning
	addq.l	#1,a0
	move.l	x_text_pos,d0
	move.l	#0,bit_place
	bra	go_printer
down_a_line
	addq.l	#1,a0
	add.l	#(160*6),d1
	cmp.l	#(180*160),d1
	bge.s	quit_text_print
	bra	go_printer
no_print
	addq.l	#1,a0
	bra	go_printer



calc_x_pos	
	move.l	x_sprite_add,d1
	add.l	d1,sprite_x_pointer
	cmpi.l	#(319*8),sprite_x_pointer
	ble.s	.ok_pointy
	sub.l	#(319*8),sprite_x_pointer
.ok_pointy
	move.w 	x_sprite_amplitude,amplitude
	move.l	sprite_x_pointer,pointer
	move.l	x_sprite_origin,origin
	jsr	sine_rout
	move.l	d0,sprite_x_pos
	rts	

calc_y_pos	
	move.l	y_sprite_add,d1
	add.l	d1,sprite_y_pointer
	cmpi.l	#(319*8),sprite_y_pointer
	ble.s	.ok_pointy
	sub.l	#(319*8),sprite_y_pointer
.ok_pointy
	move.w 	y_sprite_amplitude,amplitude
	move.l	sprite_y_pointer,pointer
	move.l	y_sprite_origin,origin
	jsr	sine_rout
	move.l	d0,sprite_y_pos
	rts	

sine_rout	
*********************************************************
*	sine calulator (un-optimised version 1)		*
*	amplitude	:amp of wave			*
*	pointer		:pointer into sine bank		*
*	result		:returned in d0			*
*	NB:- pointer = (deg*8) (can go by .5 degs)	*
*		Mag of Digi Tallis (HUMBUG)		*
*********************************************************
		lea	sine,a0
		moveq.l	#0,d0
		add.l	pointer,a0
		move.w	(a0)+,d1
		move.w	(a0)+,d0
		mulu.w	amplitude,d0
		asr.l	#8,d0
		cmpi.w	#1,d1
		bne.s	positive
		moveq.l	#0,d2
		sub.l	d0,d2
		move.l	d2,d0
positive	add.l	origin,d0
		rts
*****************************************
*	   data for sinerout		*
*****************************************
amplitude	dc.w	0
		even
origin		dc.l	0
sine		rept	2
		incbin	sine.bin	
		endr
		even
pointer		dc.l	0
		even
*****************************************



draw_sprite	;d0 = X   d1 = Y
	mulu	#160,d1		;down screen
	move.l	d0,d2
	and.l	#$f,d2		;frame numba
	sub.l	d2,d0		;down to 16
	lsr.l	#1,d0		;down to 8
	mulu	#3800,d2	;to get correct place
	move.l 	nxt_base,a0
	add.l	#2,a0
	add.l	d1,a0		;down screen
	add.l	d0,a0		;across screen
	lea	mug_sprite,a1
	add.l	d2,a1
i	set	0
	rept	95
	move.l	(a1)+,i(a0)
	move.l	(a1)+,i+8(a0)
	move.l	(a1)+,i+16(a0)
	move.l	(a1)+,i+24(a0)
	move.l	(a1)+,i+32(a0)
	move.l	(a1)+,i+40(a0)
	move.l	(a1)+,i+48(a0)
	move.l	(a1)+,i+56(a0)
	move.l	(a1)+,i+64(a0)
	move.l	(a1)+,i+72(a0)
i	set	i+160
	endr
	rts

clear_sprite	;d0 = X   d1 = Y
	mulu	#160,d1		;down screen
	move.l	d0,d2
	and.l	#$f,d2		;frame numba
	sub.l	d2,d0		;down to 16
	lsr.l	#1,d0		;down to 8
	mulu	#3800,d2	;to get correct place
	move.l 	nxt_base,a0
	add.l	#2,a0
	add.l	d1,a0		;down screen
	add.l	d0,a0		;across screen
	lea	mug_sprite,a1
	add.l	d2,a1
	moveq.l	#0,d0
i	set	0
	rept	95
	move.l	d0,i(a0)
	move.l	d0,i+8(a0)
	move.l	d0,i+16(a0)
	move.l	d0,i+24(a0)
	move.l	d0,i+32(a0)
	move.l	d0,i+40(a0)
	move.l	d0,i+48(a0)
	move.l	d0,i+56(a0)
	move.l	d0,i+64(a0)
	move.l	d0,i+72(a0)
i	set	i+160
	endr
	rts

point_plot
	opt	o+,w-		;LEAVE THIS IN! To get the extra 10!
		;d0=x d1=y
		;910 1 colour points per frame
		;If you use this, PLEASE credit me..cheers..
		;(C) ()rm of Digi Tallis of Humbug
		;(C) Humbug 1993/1994/eternity
	move.l	nxt_base,a0			;screen
	lsl.l	#2,d1			;mulitply by 4
	add.l	mulu_table(pc,d1.l),a0	;add right multiple of 160
	lea	point_data,a1		;The actual point plot
	lsl.l	#3,d0			;multiply by 8
	jmp	(a1,d0.l)		;jmp da fnuker
mulu_table
i	set	0
	rept	200
	dc.l	i*160
i	set	i+1
	endr
	even
point_data
i	set	0
	rept	40
	or.w	#32768,i(a0)
	rts
	or.w	#16384,i(a0)
	rts
	or.w	#8192,i(a0)
	rts
	or.w	#4096,i(a0)
	rts
	or.w	#2048,i(a0)
	rts
	or.w	#1024,i(a0)
	rts
	or.w	#512,i(a0)
	rts
	or.w	#256,i(a0)
	rts
	or.w	#128,i(a0)
	rts
	or.w	#64,i(a0)
	rts
	or.w	#32,i(a0)
	rts
	or.w	#16,i(a0)
	rts
	or.w	#8,i(a0)
	rts
	or.w	#4,i(a0)
	rts
	or.w	#2,i(a0)
	rts
	or.w	#1,i(a0)
	rts
i	set	i+8
	endr
	opt	o-,w+		;LEAVE THIS IN!


clear_points
	lea	star_y,a3
	moveq.w	#0,d1
	move.l	#NUM_STARS-1,d5
.loop
	move.l	(a3)+,d0
	mulu	#160,d0	;down screen

	move.l	nxt_base,a0
	add.l	d0,a0

i	set	8
	rept	18
	move.w	d1,i(a0)
i	set	i+8
	endr

	dbf	d5,.loop
	rts

move_stars
	lea	star_x,a2
	lea	star_speed,a3
	move.l	#NUM_STARS-1,d5
.loop
	move.l	(a2),d4
	add.l	(a3)+,d4
	cmp.l	#300,d4
	blt	.nope
	move.w	#20,d4
.nope
	move.l	d4,(a2)+
	dbf	d5,.loop
	rts

do_starfield
	lea	star_x,a2
	lea	star_y,a3
	move.l	#NUM_STARS-1,d5			;num of stars
.loop
	move.l	(a2)+,d0
	move.l	(a3)+,d1
	jsr	point_plot
	dbf	d5,.loop
	jsr	move_stars
	rts


*****************************************************************
*  data 							*
*****************************************************************


vbl_flag	dc.b	0
savesp		dc.l	0
pal		dc.w	$000,$070,$666,$666,$444,$444,$222,$222,$000,$000,$000,$000,$000,$000,$000,$000
gempal		ds.w	16
base		dc.l	$70000
nxt_base	dc.l	$78000
flipper_dat	dc.l	$70000,$78000,$ffffffff
base_place	dc.l	0		
old_vbl		dc.l	0
old_hbl		dc.l	0
old_a1b		dc.b	0
old_a21		dc.b	0
old_a07		dc.b	0
old_a09		dc.b	0
old_a13		dc.b	0
old_a15		dc.b	0
old_x_positions		ds.l	NUM_STARS
old_y_positions		ds.l	NUM_STARS
old_old_x_positions	ds.l	NUM_STARS
old_old_y_positions	ds.l	NUM_STARS
x_text_pos		dc.l	0
y_text_pos		dc.l	1*160
bit_place		dc.l	0
scroll_buffer		ds.w	160*12
bit_count		dc.w	0
temp_buffer		ds.w	32
letter			dc.w	0	
sprite_x_pos		dc.l	0
old_sprite_x_pos	dc.l	0
old_old_sprite_x_pos	dc.l	0
x_sprite_add		dc.l	X_SPEED*4
sprite_x_pointer	dc.l	0
x_sprite_amplitude	dc.w	80
x_sprite_origin		dc.l	96
sprite_y_pos		dc.l	0
old_sprite_y_pos	dc.l	0
old_old_sprite_y_pos	dc.l	0
y_sprite_add		dc.l	Y_SPEED*4
sprite_y_pointer	dc.l	0
y_sprite_amplitude	dc.w	47
y_sprite_origin		dc.l	51
get_pos			dc.l	0

test_text
	dc.b	" __     __   __ __   _____    __  __ __",13,10
	dc.b	"/  \   /  \ / I I \ /  _  I  / I I I/ /",13,10
	dc.b	"I   \_/   I I I_I I I I_I I  I I_I   ( ",13,10
	dc.b	"I  I\_/I  I I_____I \____ I  I     I\ I",13,10
	dc.b	"I  I   I  I  _          I I  \_____/I I",13,10
	dc.b	"I  I   I  I / \_________/ /         I I",13,10
	dc.b	"\__)   (__/ \____________/          I_/",13,10
        dc.b	"                                    ()rm",13,10
	dc.b	13,10,13,10
	dc.b	"Yup. Thats right, its an 8 * 6 font!",13,10
	dc.b	"So that means more text on screen",13,10
	dc.b	"than usual...   nice huh?",13,10
	dc.b	13,10,13,10
	dc.b	"All code by ()rm of Digi Tallis",13,10
	dc.b	"(C) Humbug 1994/eternity",13,10

	dc.b	0,0,0,0,0,0,0,0
	even

text	
	dc.b	"        A-one-two-three-four....  HURL!  "
	dc.b	"     Yup. Another intro for somebody else!  "
	dc.b	"      All code by ()rm of Digi Tallis of Humbug"
	dc.b	"      (C) Humbug 1994/eternity             "
	dc.b	"                         "
	dc.b	$ff,$ff,$ff
	even


font		incbin	smallfnt.bin
		even
music		incbin	jess1.mus
		even
star_x		incbin	star_x.bin
		even
star_y		incbin	star_y.bin
		even
star_speed	incbin	star_spd.bin
		even
mug_sprite	incbin	mug_uk.spr
		even
text_font	incbin	win_fnt.bin
		even
	even



