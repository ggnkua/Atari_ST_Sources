*	when calling terminal please note that d0 will
*	point to the entry to be displayed but at this
*	moment in time it will not. It does flip between
*	two screens though.




**	opt	o+,ow-
anim_offset	equ	16*3*0
anim_delay	equ	3
top_butt_1	equ	1+152
top_butt_2	equ	1+152+10
top_butt_3	equ	1+152+10+10	
top_butt_4	equ	1+152+10+10+10
top_butt_5	equ	1+152+10+10+10+10
mouse_height	equ	12
space_width	equ	6
font_height	equ	9
butt_width	equ	16
converse_text_offset	equ	320*153


conv_new4	movem.l	d0-a6,-(sp)
	Move.w	#0,Scr_Mod
	Move.w	#0,Scr_Del
	move.l	tv_addr1,-(sp)
	move.b	1(sp),$ffff8201.w		tv set up
	move.b	2(sp),$ffff8203.w		tv set up
	move.b	3(sp),$ffff820d.w
	addq.l	#4,sp
	
	addq.w	#1,clock
	lea	(atari_pal).w,a0
	lea	new_pal,a1
	move.w	#256-1,d0
.lp	move.l	(a1)+,(a0)+
	dbf	d0,.lp
	tst.b	running
	beq.s	.no_extras
	bsr	do_mouse
	bsr	update_mouse
.no_extras
	Jsr	Nt_Vbl
	Tst.b	Fucker
	Bne	.Hold
	Move.b	Key_Code,d0
	Cmp.b	#$39,d0
	Beq.s	.Hold
	Movem.l	(sp)+,d0-a6
	Rte
.Hold	Movem.l	(sp)+,d0-a6
	Move.l	#Fuck,2(sp)
	Rte

update_mouse
	lea	ikbd_buffer,a0
	move.b	(a0)+,mouse_left_pressed
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	move.w	d0,conv_mouse_x
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	move.w	d0,conv_mouse_y
	Jsr	read_mouse
	rts
	

do_buttons
	move.w	conv_mouse_y,d0
	
	cmp.w	#top_butt_1,d0
	blt.s	.no_choice
	cmp.w	#top_butt_2-1,d0
	blt.s	.choice_1
	cmp.w	#top_butt_3-1,d0
	blt.s	.choice_2
	cmp.w	#top_butt_4-1,d0
	blt.s	.choice_3
	cmp.w	#top_butt_5-1,d0
	blt.s	.choice_4
	move.w	#-1,button
	bra.s	.cont
.choice_4
	move.w	#0,button
	bra.s	.cont
.choice_3
	move.w	#1,button
	bra.s	.cont
.choice_2
	move.w	#2,button
	bra.s	.cont
.choice_1
	move.w	#3,button
	bra.s	.cont
.no_choice
	move.w	#-1,button
.cont	move.w	button,d0
	move.w	#3,d1
	lea	button_addrs,a0
.lp	move.l	(a0)+,a1
	lea	button_off_spr+8,a2
	cmp.w	d0,d1
	bne.s	.but_off
	lea	button_on_spr+8,a2
.but_off
	move.w	#font_height-1,d7
.lp2	movem.l	(a2)+,d4/d5/d6/a6
	movem.l	d4/d5/d6/a6,(a1)
	addq.l	#2,a2
	lea	320(a1),a1
	dbf	d7,.lp2
	dbf	d1,.lp
	rts
do_mouse
	tst.b	mouse_on
	bne.s	.ok
	tst.b	mouse_off
	bne.s	.ok1
	rts
.ok1	lea	mouse_hide_addr,a0
	move.l	(a0)+,a1
	moveq	#mouse_height-1,d0
.lp2	movem.l	(a0)+,d1-d7/a6
	movem.l	d1-d7/a6,(a1)
	lea	320(a1),a1
	dbf	d0,.lp2
	sf	mouse_on
	sf	mouse_off
	sf	mouse_hide
	rts
.ok	tst.b	mouse_hide
	beq.s	.no_hide
	lea	mouse_hide_addr,a0
	move.l	(a0)+,a1
	moveq	#mouse_height-1,d0
.lp	movem.l	(a0)+,d1-d7/a6
	movem.l	d1-d7/a6,(a1)
	lea	320(a1),a1
	dbf	d0,.lp
.no_hide	
	bsr	do_buttons
	st	mouse_hide
	moveq	#0,d0
	moveq	#0,d1
	move.w	conv_mouse_x,d0
	and.w	#$fff0,d0
	add.l	tv_addr1,d0
	move.w	conv_mouse_y,d1
	mulu	#320,d1
	add.l	d1,d0
	move.l	d0,a0
	lea	mouse_hide_addr,a5
	move.l	d0,(a5)+
	moveq	#mouse_height-1,d0
.lp1	movem.l	(a0),d1-d7/a6
	movem.l	d1-d7/a6,(a5)
	lea	320(a0),a0
	lea	32(a5),a5
	dbf	d0,.lp1
	move.l	mouse_hide_addr,a6
	move.w	conv_mouse_x,d0
	and.w	#$f,d0
	lea	mouse_spr+6,a2
	moveq	#mouse_height-1,d7
.lp3	moveq	#-1,d1
	move.w	(a2)+,d1
	ror.l	d0,d1
	and.w	d1,(a6)
	and.w	d1,2(a6)
	and.w	d1,4(a6)
	and.w	d1,6(a6)
	and.w	d1,8(a6)
	and.w	d1,10(a6)
	and.w	d1,12(a6)
	and.w	d1,14(a6)
	swap	d1
	and.w	d1,16(a6)
	and.w	d1,16+2(a6)
	and.w	d1,16+4(a6)
	and.w	d1,16+6(a6)
	and.w	d1,16+8(a6)
	and.w	d1,16+10(a6)
	and.w	d1,16+12(a6)
	and.w	d1,16+14(a6)
acid	set	0
	rept	8
	moveq	#0,d1
	move.w	(a2)+,d1
	ror.l	d0,d1
	or.w	d1,acid(a6)
	swap	d1
	or.w	d1,16+acid(a6)
acid	set	acid+2	
	endr
	lea	320(a6),a6
	dbf	d7,.lp3
	rts
	


enter_choice
	st	mouse_on
	sf	mouse_off
.loop	tst.b	mouse_left_pressed
	beq.s	.no_choice
	cmp.w	#-1,button
	beq.s	.no_choice
	sf	mouse_on
	st	mouse_off
	bsr	conv_wait_vbl
	rts
.no_choice
	bsr	conv_wait_vbl
	bra.s	.loop


conv_main
	
	movem.l	d0-a6,-(sp)
	move.l	$70.w,-(sp)
	move.l	#conv_new4,$70.w
	sf	mouse_on
	sf	mouse_off
	rept	2
	bsr	update_mouse
	bsr	conv_wait_vbl
	endr
	bsr	make_dialogue_screen
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	sr,-(sp)
	bsr	cls_conversation_screen	
	move.w	(sp)+,sr
	movem.l	(sp)+,d0-a6
	moveq	#4-1,d0
	lea	conversation_area,a6
	bsr	make_text
	move.l	a0,reply_addr
.loop	bsr	copy_con_text
	st	dialogue_on
	st	running
	bsr	enter_choice
	cmp.w	#0,button
	beq	.quit
	st	mouse_off
	bsr	conv_wait_vbl
	bsr	make_answer
	bsr	copy_ans_text
	move.w	#1,anim_timer
	bsr	see_reaction
	bra	.loop
.quit	bsr	fade_out_dialogue
	move.l	(sp)+,$70.w
	eor.w	#1,dialogue_number	switch	droog-sluge
	movem.l	(sp)+,d0-a6
	rts

see_reaction
**********************************
;d7-Ping PONG !  (SET -1 to do ping pong)
;a0-Points to start of anim file
;a1-Points to pallete dest
;a2-Points to screen1
;a3-Points to screen2
	
	moveq	#4,d0
	sub.w	button,d0
	subq.w	#1,d0
	and.w	#3,d0
	move.l	anim_addr,a0
	move.l	(a0,d0.w*4),a0
	Movem.l	d0-a6,-(sp)
	Bsr	Load_HD_File
	Movem.l	(sp)+,d0-a6
	Lea	Anim_Bufferr,a0
	moveq	#-1,d7
	move.l	tv_addr1,a3
	add.l	#64000+anim_offset,a3
	move.l	a3,a2
	add.l	#64000,a3
	movem.l	a2-a3,anim_screens
	lea	anim_pal,a1
	jsr	JINIT_ANIM
	bsr	copy_background_forward
	move.l	$70,-(sp)
	Sf	Now_Do_Pallete
	move.l	#my_anim_vbl,$70
	bsr	play_animation
	move.l	(sp)+,$70.w
	rts

Load_HD_File
	Lea	Anim_Bufferr,a1
	Movem.l	a0-a1,-(sp)
	Clr.w	-(sp)
	Pea	(a0)
	Move.w	#$3d,-(sp)
	Trap	#1
	Addq.l	#8,sp
	Movem.l	(sp)+,a0-a1
	Tst.l	d0
	Bmi	Fileerror
	Move.w	d0,Handle
	Pea	(a1)
	Move.l	#1200000-100,-(sp)
	Move.w	Handle,-(sp)
	Move.w	#$3f,-(sp)
	Trap	#1	
	Lea	12(sp),sp
	Tst.l	d0
	Bmi	Fileerror
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)
	Trap	#1
	Addq.l	#4,sp
	Bmi	Fileerror
	Rts
Fileerror	Eor.l	#$ff,Pal256
	Bra.s	Fileerror	

my_anim_vbl
	movem.l	d0-a6,-(sp)
	move.l	anim_screens+4,a0
	lea	-anim_offset(a0),a0
	pea	(a0)
	move.b	1(sp),$ffff8201.w		tv set up
	move.b	2(sp),$ffff8203.w		tv set up
	move.b	3(sp),$ffff820d.w
	addq.l	#4,sp
	Tst.b	Now_Do_Pallete
	Beq.s	.No
	Sf	Now_Do_Pallete
	jsr	COPY_JANIM_PALLETE
.No
	addq.w	#1,clock
	move.w	anim_timer,d0
	subq.w	#1,d0
	bne.s	.no_end
	move.w	#anim_delay,d0
	st	wait_a_while
.no_end	move.w	d0,anim_timer
	Jsr	Nt_Vbl
	Tst.b	Fucker
	Bne	.Hold
	Move.b	Key_Code,d0
	Cmp.b	#$39,d0
	Beq.s	.Hold
	Movem.l	(sp)+,d0-a6
	Rte
.Hold	Movem.l	(sp)+,d0-a6
	Move.l	#Fuck,2(sp)
	Rte

Now_Do_Pallete	Ds.w	1



play_animation
.lp	move.l	anim_screens,a1
	jsr	JANIM_VBL
	movem.l	anim_screens,d1-d2
	exg.l	d1,d2
	movem.l	d1-d2,anim_screens
	St	Now_Do_Pallete
	tst.w	d0
	bne.s	.quit
.wait	tst.b	wait_a_while
	beq.s	.wait
	sf	wait_a_while
	bra.s	.lp
.quit	rts	
	
	rept	100
	bsr	conv_wait_vbl
	endr
	rts

	
cls_conversation_screen	
	lea	conversation_area,a0
	lea	conversation_area_end,a1
.lp	clr.l	(a0)+
	cmp.l	a0,a1
	bne.s	.lp
	rts
cls_answer_screen	
	lea	answer_area,a0
	lea	answer_area_end,a1
.lp	clr.l	(a0)+
	cmp.l	a0,a1
	bne.s	.lp
	rts


copy_background_forward
	lea	answer_area,a0
	lea	answer_area_end,a1
	movem.l	anim_screens,a2-a3
	add.l	#converse_text_offset-anim_offset,a2
	add.l	#converse_text_offset-anim_offset,a3
.lp	
	rept	8
	move.l	(a0)+,d1
	move.l	d1,(a2)+
	move.l	d1,(a3)+
	endr
	cmp.l	a0,a1
	bne.s	.lp
	rts

make_dialogue_screen
	move.w	dialogue_number,d0
	lea	dialogue_addrs,a0
	move.l	4(a0,d0.w*8),piccy_addr	get the dialogue piccy_addr
	move.l	(a0,d0.w*8),a0
	move.l	a0,anim_addr
	lea	12(a0),a0
	move.l	a0,text_addr		get the dialogue text_addr
	move.l	#tv_screen,d0
	and.b	#%11111100,d0
	move.l	d0,tv_addr1
	add.l	#top_butt_1*320,d0
	lea	button_addrs,a1
	move.l	d0,(a1)+
	add.l	#(top_butt_2-top_butt_1)*320,d0
	move.l	d0,(a1)+
	add.l	#(top_butt_3-top_butt_2)*320,d0
	move.l	d0,(a1)+
	add.l	#(top_butt_4-top_butt_3)*320,d0
	move.l	d0,(a1)+
	move.l	tv_addr1,a0
	move.l	piccy_addr,a1
	move.w	#64000/4-1,d0
.lp	move.l	(a1)+,(a0)+		the piccy
	dbf	d0,.lp
	lea	col_pal,a0
	move.w	#256-1,d0
.lp1	move.l	(a1)+,(a0)+		the palette
	dbf	d0,.lp1
	bsr	fade_in_dialogue
	rts


copy_ans_text
	lea	answer_area,a0
	lea	answer_area_end,a1
	bra.s	copy_plus
copy_con_text
	lea	conversation_area,a0
	lea	conversation_area_end,a1
copy_plus
	move.l	tv_addr1,a2
	add.l	#converse_text_offset,a2
.lp	
	rept	8
	move.l	(a0)+,(a2)+
	endr
	cmp.l	a0,a1
	bne.s	.lp
	rts


make_answer
	bsr	cls_answer_screen
	move.l	reply_addr,a0
	move.w	button,d0
	eor.w	#3,d0
.lp1	bsr	find_a_sentence
	dbf	d0,.lp1
	moveq	#0,d0
	move.b	(a0)+,d0
	lea	answer_area,a6
	bra.s	make_text_1

find_a_sentence
	moveq	#0,d1
	move.b	(a0)+,d1
.lp	tst.b	(a0)+
	bne.s	.lp
	dbf	d1,.lp
	rts


make_text
	move.l	text_addr,a0
make_text_1
.loop	movem.l	d0/a6,-(sp)
	bsr	do_a_line
	movem.l	(sp)+,d0/a6
	lea	320*(font_height+1)(a6),a6
	dbf	d0,.loop
	rts

do_a_line
	clr.w	con_x_pos
.loop	moveq	#0,d0	
	move.b	(a0)+,d0
	bne.s	.not_eol
	rts
.not_eol
	cmp.b	#" ",d0
	bne.s	.no_space
	addq.w	#space_width,con_x_pos
	bra.s	.loop
.no_space
	cmp.b	#-1,d0
	bne.s	.no_button
	lea	button_off_spr,a2
	move.w	#font_height-1,d7
	bsr	conv_do_spr
	add.w	#butt_width,con_x_pos
	bra.s	.loop
.no_button	
	moveq	#font_height-1-1,d7
	lea	Ascii_To_Spr,a5
	move.b	(a5,d0.w),d0 from char get spr no.
	cmp.b	#-3,d0
	beq.s	.loop	invalid sprite
	lea	font,a2
	move.l	a2,a3
	add.l	(a3,d0.w*4),a2
	bsr	conv_do_spr
	lea	Fnt_Width,a5
	move.b	(a5,d0.w),d0
	and.w	#$ff,d0
	add.w	d0,con_x_pos	update x pos
	bra.s	.loop

conv_do_spr	movem.l	d0-a6,-(sp)
	addq.l	#6,a2		skip header
	move.w	con_x_pos,d0
	move.w	d0,d1
	and.w	#$f,d0		shift
	and.w	#$fff0,d1
	lea	(a6,d1.w),a6	get x pos
.lp	moveq	#-1,d1
	move.w	(a2)+,d1
	ror.l	d0,d1
	and.w	d1,(a6)
	and.w	d1,2(a6)
	and.w	d1,4(a6)
	and.w	d1,6(a6)
	and.w	d1,8(a6)
	and.w	d1,10(a6)
	and.w	d1,12(a6)
	and.w	d1,14(a6)
	swap	d1
	and.w	d1,16(a6)
	and.w	d1,16+2(a6)
	and.w	d1,16+4(a6)
	and.w	d1,16+6(a6)
	and.w	d1,16+8(a6)
	and.w	d1,16+10(a6)
	and.w	d1,16+12(a6)
	and.w	d1,16+14(a6)
acid	set	0
	rept	8
	moveq	#0,d1
	move.w	(a2)+,d1
	ror.l	d0,d1
	or.w	d1,acid(a6)
	swap	d1
	or.w	d1,16+acid(a6)
acid	set	acid+2
	endr
	lea	320(a6),a6
	dbf	d7,.lp
	movem.l	(sp)+,d0-a6
	rts
	




	
fade_out_dialogue
	moveq	#0,d7
	move.w	#128-1,d0		no times
	move.w	#255,d1			init value
	moveq	#-2,d2			increase
	bra.s	conv_fader
fade_in_dialogue
	moveq	#0,d7			fade speed
	move.w	#128-1,d0		no times
	moveq	#0,d1			init value
	moveq	#2,d2			increase
conv_fader	
.lp	move.w	#256-1,d3		do all colours
	lea	col_pal,a0
	lea	new_pal,a1
.lp1	moveq	#0,d4
	move.b	(a0)+,d4
	mulu	d1,d4
	lsr.w	#8,d4
	move.b	d4,(a1)+		red
	move.b	(a0)+,d4
	mulu	d1,d4
	lsr.w	#8,d4
	move.b	d4,(a1)+		green
	clr.b	(a1)+
	addq.l	#1,a0			skip byte
	move.b	(a0)+,d4
	mulu	d1,d4
	lsr.w	#8,d4
	move.b	d4,(a1)+		blue
	dbf	d3,.lp1
	add.w	d2,d1
	move.w	d7,d4
.lp2	bsr	conv_wait_vbl
	dbf	d4,.lp2
	dbf	d0,.lp
	rts
	
conv_wait_vbl
	move.l	d0,-(sp)
	move.w	clock,d0
.lp	cmp.w	clock,d0
	beq.s	.lp
	move.l	(sp)+,d0
	rts

con_x_pos	dc.w	0
interact_1	****	    12345678901234567890123456789012345678901234
		dc.l	i_1_0
		dc.l	i_1_1
		dc.l	i_1_2
		dc.b	-1,"Hi there man, that's my ship.....",0
		dc.b	-1,"Hey toadface, that's ma ship yer looting !",0
		dc.b	-1,"Did you find a data cart in my ship ?",0
		dc.b	-1,"Thanks, erm, but I'll be off now.......",0
		dc.b	0,0
		dc.b	0,"Thats' my ship now boy !",0
		dc.b	0,"Who are you calling toadface city boy",0
		dc.b	0,"Ain't no data cart in there boy",0
		
		even
interact_0	dc.l	i_0_0
		dc.l	i_0_1
		dc.l	i_0_2
		dc.b	-1,"Have you seen a ship called the Righteous Dub?",0
		dc.b	-1,"You look to be having a spot of bother.",0
		dc.b	-1,"What happened to you ?",0
		dc.b	-1,"Sorry to keep you hanging around !",0
		dc.b	0,0
		dc.b	0,"Yeah, It's over there, just over the bridge.",0
		dc.b	2,"Nothing to worry about. I'd much rather be up",0
		dc.b	"here than down there. With that psycho running",0
		dc.b	"around!",0
		dc.b	1,"What do you think happened Idiot! I was hung",0
		dc.b	"upside down",0
		
		even

		even		
still_0		incbin	F:\junk\main\conv\convdroo.pi0
still_1		incbin	F:\junk\main\conv\convslur.pi0
dialogue_addrs	dc.l	interact_0,still_0
		dc.l	interact_1,still_1

button_on_spr	incbin	F:\junk\main\conv\butt_on.spr
button_off_spr	incbin	F:\junk\main\conv\butt_off.spr
mouse_spr	incbin	F:\junk\main\conv\mouse.spr
		even

i_0_0	Dc.b 	"A\D1.Fan",0
	even
i_0_1	Dc.b 	"A\D2.Fan",0
	even
i_0_2	Dc.b 	"A\D3.Fan",0
	even

i_1_0	Dc.b 	"A\S1.Fan",0
	even
i_1_1	Dc.b 	"A\S2.Fan",0
	even
i_1_2	Dc.b 	"A\S3.Fan",0
	even
dialogue_number	dc.w	0
dialogue_lines	dc.w	0

Handle	Ds.l	1

	opt	c-
	include	janimrep.s
	opt	c+

	