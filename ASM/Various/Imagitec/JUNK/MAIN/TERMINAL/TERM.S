;	opt	o+,ow-
anim_speed	equ	6
max_y_term	equ	20+6*18
wait_0	equ	100
wait_1	equ	100
wait_2	equ	80
wait_3	equ	200

inifite_loop	equ	1
flash_on	equ	1
title_offset	equ	320*8+16
window_offset	equ	320*8+16*14
main_high	equ	128
window_high	equ	64
atari_pal	equ	$ffff9800
static_colour	equ	atari_pal+255*4
new_mode	equ	$23


term_wait_vbl
	move.l	d0,-(sp)
	move.w	clock,d0
.lp	cmp.w	clock,d0
	beq.s	.lp
	move.l	(sp)+,d0
	rts

terminal_table
	dc.l	smaskp3,swamp_world_text
	dc.l	smaskp5,scene_6_text


clear_bss
	lea	term_clear_start,a0
	lea	term_clear_end,a1

.lp	clr.w	(a0)+
	cmp.l	a0,a1
	bne.s	.lp
	rts

term_program
	movem.l	d0-a6,-(sp)
	move.w	which_term,d0
	eor.w	#1,which_term
	bsr	clear_bss
	lea	terminal_table(pc),a0
	lea	(a0,d0.w*8),a0
	move.l	(a0)+,smaskp1
	move.l	(a0)+,terminal_text
	move.l	#$e00000,static_addr
	move.l	#col_pal,bar_base
	clr.w	clock
	move.l	$70.w,-(sp)
	move.l	#term_new4,$70.w
	bsr	term_main
	move.l	(sp)+,$70.w
	movem.l	(sp)+,d0-a6
	rts

terminal_end
	Move.w	#0,Scr_Mod
	Move.w	#0,Scr_Del
	move.l	$70.w,-(sp)
	move.l	#term_new4,$70.w
	bsr	end_screen
	move.l	(sp)+,$70.w
	movem.l	(sp)+,d0-a6
	rts

	even
smaskp3	incbin	Terminal\bit3.spa
smaskp5	incbin	Terminal\bit5.spa

smaskp1		dc.l	0
terminal_text	dc.l	0
	even
termfont	incbin	Terminal\5x5font.dat
	ds.b	30
	even


	include	Terminal\bangfade.s


term_new4
	Move.w	#0,Scr_Mod	
	Move.w	#0,Scr_Del	
	addq.w	#1,clock
	movem.l	d0-a6,-(sp)
	move.l	tv_addr1,-(sp)
	move.b	1(sp),$ffff8201.w		tv set up
	move.b	2(sp),$ffff8203.w		tv set up
	move.b	3(sp),$ffff820d.w
	addq.l	#4,sp
	lea	new_pal,a0
	lea	(atari_pal).w,a1
	move.w	#256-1,d0
.lp	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	bsr	do_bars
	tst.b	static_display
	bne.s	.do_static
	move.l	#$004f000f,d0
	move.l	#$7f000000,d1
	move.l	#$7f7f0000,d2
	IFNE	flash_on
	addq.b	#1,fgcol
	and.b	#1,fgcol
	beq.s	.ok
	move.l	#$007f001f,d0
	move.l	#$cf000000,d1
	move.l	#$cfcf0000,d2
	ENDC
.ok	tst.b	flicker_on
	beq.s	.no_flicker
	move.l	d0,atari_pal+254*4
	move.l	d1,atari_pal+253*4
	move.l	d2,atari_pal+252*4
.no_flicker
	move.l	d0,col_pal+(254*4)
	move.l	d1,col_pal+(253*4)
	move.l	d2,col_pal+(252*4)
	bra.s	.no_static
.do_static
	bsr.s	static_colours
	bsr.s	static_picture
.no_static
	jsr	nt_vbl
	movem.l	(sp)+,d0-a6
	rte

static_colours
	move.w	fade_index,d0
	tst.b	static_fade_out
	bne.s	.fade_out
	cmp.b	#-1,d0
	beq.s	.ok
	addq.w	#1,d0
	bra.s	.ok
.fade_out
	cmp.w	#0,d0
	beq.s	.ok
	subq.w	#1,d0
.ok
	move.w	d0,fade_index
	rept	4
	move.b	d0,d1
	lsl.l	#8,d1
	endr
	move.l	d1,fade_index
	rts




static_picture
	move.l	tv_addr1,a0
	lea	title_offset(a0),a0
	moveq	#main_high-1,d7
	move.l	static_addr,a1
.lp	
acid	set	0
	rept	12
	move.w	(a1)+,d0
	move.w	d0,a6
	swap	d0
	move.w	a6,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	movem.l	d0-d3,acid(a0)
acid	set	acid+16
	endr
	lea	320(a0),a0
	dbf	d7,.lp
	add.l	#554,static_addr
	move.l	tv_addr1,a0
	lea	window_offset(a0),a0
	moveq	#window_high-1,d7

.lp1	
acid	set	0
	rept	5
	move.w	(a1)+,d0
	move.w	d0,a6
	swap	d0
	move.w	a6,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	movem.l	d0-d3,acid(a0)
acid	set	acid+16
	endr
	lea	320(a0),a0
	dbf	d7,.lp1
	rts



fade_out_terminal
	move.l	#col_pal,a6
	move.w	#atari_pal,a5
	moveq	#0,d7
	move.w	#128-1,d0		no times
	move.w	#255,d1			init value
	moveq	#-2,d2			increase
	bra.s	fader
fade_in_terminal
	move.l	#col_pal,a6
	move.w	#atari_pal,a5
	moveq	#0,d7			fade speed
	move.w	#128-1,d0		no times
	moveq	#0,d1			init value
	moveq	#2,d2			increase
fader	move.l	a6,bar_base
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
.lp2	bsr	term_wait_vbl
	dbf	d4,.lp2
	dbf	d0,.lp
	move.l	a5,bar_base
	rts

end_vbl	addq.w	#1,clock
	Move.w	#0,Scr_Mod
	Move.w	#0,Scr_Del
	movem.l	d0-a6,-(sp)
	move.l	tv_addr1,-(sp)
	move.b	1(sp),$ffff8201.w		tv set up
	move.b	2(sp),$ffff8203.w		tv set up
	move.b	3(sp),$ffff820d.w
	addq.l	#4,sp
	lea	new_pal,a0
	lea	(atari_pal).w,a1
	move.w	#256-1,d0
.lp	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	jsr	nt_vbl
	movem.l	(sp)+,d0-a6
	rte


end_screen
	move.l	$70.w,-(sp)
	move.l	#end_vbl,$70.w
	bsr	copy_coming
	bsr	fade_in_terminal
	bsr	wait_end
	IFNE	inifite_loop
.lop	bra.s	.lop
	ELSE
	bsr	fade_out_terminal
	move.l	(sp)+,$70.w
	rts
	ENDC

copy_coming
	lea	coming_soon,a0
	bra.s	cont_copy
copy_term
	lea	term_pic,a0
cont_copy
	move.l	#term_tv,d0
	and.b	#%11111100,d0
	move.l	d0,tv_addr1
	move.l	d0,a1
	move.w	#64000/4-1,d0
.lp	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	lea	col_pal,a1
	move.w	#256-1,d0
.lp1	move.l	(a0)+,(a1)+
	dbf	d0,.lp1
	rts


term_main	bsr.s	copy_term
	bsr	fade_in_terminal
	bsr.s	do_terminal
	bsr	fade_out_terminal
	rts

do_terminal
	clr.l	(static_colour).w
	st	static_display
	st	static_fade_in
	bsr.s	stat_wait_0
	st	static_fade_out
	bsr.s	stat_wait_1
	sf	static_display
	
	bsr	term_wait_vbl
	bsr.s	cls_page
	bsr	term_wait_vbl
	bsr.s	cls_page
	st	piccy_start
	bsr	bang_fade_in
	st	flicker_on
	bsr	print_term
	bsr.s	wait_a_while
	bsr	bang_fade_out
	sf	flicker_on
	rts
wait_end
	move.w	#wait_3,d0
.lp	bsr	term_wait_vbl
	dbf	d0,.lp
	rts
	
stat_wait_0
	move.w	#wait_0,d0
.lp	bsr	term_wait_vbl
	dbf	d0,.lp
	rts
stat_wait_1
	move.w	#wait_1,d0
.lp	bsr	term_wait_vbl
	dbf	d0,.lp
	rts
wait_a_while
	move.w	#wait_2,d0
.lp	bsr	term_wait_vbl
	dbf	d0,.lp
	rts
cls_page
	moveq	#0,d0	1
	moveq	#0,d1	2
	moveq	#0,d2	3
	moveq	#0,d3	4
	moveq	#0,d4	5
	moveq	#0,d5	6
	moveq	#0,d6	7
	move.l	d6,a1	8
	move.l	d6,a2	8
	move.l	d6,a3	9
	move.l	d6,a4	10
	move.l	d6,a5	11
	move.l	d6,a6	12
	
	move.l	tv_addr1,a0
	lea	title_offset(a0),a0
	moveq	#main_high-1,d7
.lp	movem.l	d0-d6/a1-a6,(a0)
	movem.l	d0-d6/a1-a6,12*4(a0)
	movem.l	d0-d6/a1-a6,12*4*2(a0)
	movem.l	d0-d6/a1-a5,12*4*3(a0)
	lea	320(a0),a0
	dbf	d7,.lp
	move.l	tv_addr1,a0
	lea	window_offset(a0),a0
	moveq	#window_high-1,d7
.lp1	movem.l	d0-d6/a1-a6,(a0)
	movem.l	d0-d6/a1,12*4(a0)
	lea	320(a0),a0
	dbf	d7,.lp1
	rts

*************************************************
* Print routine for 5x5 font			*
*************************************************
scroll_term
	movem.l	d0-a6,-(sp)
	move.l	tv_addr1,a0
	lea	title_offset(a0),a0
	move.w	#main_high-1-6,d0
.loop	lea	6*320(a0),a1
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48*2(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48*3(a0)
	lea	320(a0),a0
	dbf	d0,.loop
	movem.l	(sp)+,d0-a6
	subq.w	#6,d1
	bra.s	scr_ret

print_term
	move.l	terminal_text(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move	d0,d2			;save xpos
term_loop
	cmp.w	#max_y_term,d1
	beq.s	scroll_term
scr_ret	move.b	(a0)+,d7
	beq	.next_line
	bmi	.exit
*********************************
* Special characters		*
*********************************
	cmp.b	#".",d7
	bne.s	.notdot
	moveq	#36,d7	
	bra.s	.print
.notdot
	cmp.b	#"-",d7
	bne.s	.notdash
	moveq	#37,d7	
	bra.s	.print
.notdash
	cmp.b	#"!",d7
	bne.s	.notexcl
	moveq	#38,d7	
	bra.s	.print
.notexcl
	cmp.b	#"?",d7
	bne.s	.notqm
	moveq	#39,d7	
	bra.s	.print
.notqm
*********************************
* Numbers			*
*********************************
	cmp.b	#"0",d7
	blt.s	.space
	cmp.b	#"9",d7
	bgt.s	.not_num
	sub	#"0",d7
	bra.s	.print
.not_num
*********************************
* Letters			*
*********************************
	cmp.b	#"a",d7
	blt.s	.space
	cmp.b	#"z",d7
	bgt.s	.space
	sub	#"a"-10,d7
	bra.s	.print
.space
	moveq	#41,d7
.print
	bsr	.print_it
	tst.b	(a0)
	beq.s	.skipc1
	movem.l	d0/d7,-(sp)
	moveq	#40,d7
	addq	#6,d0
	bsr	.print_it
	movem.l	(sp)+,d0/d7
.skipc1
	bsr	.print_it
	tst.b	(a0)
	beq.s	.skipc2
	movem.l	d0/d7,-(sp)
	moveq	#40,d7
	addq	#6,d0
	bsr	.print_it
	movem.l	(sp)+,d0/d7
.skipc2
	addq	#6,d0 
	bra	term_loop
.next_line
	move	d2,d0
	addq	#6,d1
	bra	term_loop
.exit
	cmp.b	#-2,d7
	bne.s	.not_colour
	move.b	(a0)+,colour
	move.b	(a0)+,colour+1
	bra	term_loop
.not_colour
	cmp.b	#-3,d7
	bne.s	.no_save_pointer
	move.b	d0,save_x
	move.b	d1,save_y
	bra	term_loop
.no_save_pointer
	cmp.b	#-4,d7
	bne.s	.no_restore
	move.b	save_x,d0
	move.b	save_y,d1
	bra	term_loop
.no_restore
	cmp.b	#-7,d7
	bne.s	.no_restore1
	move.b	save_x,d0
	move.b	save_y,d1
	subq.w	#6,d1
	bra	term_loop
.no_restore1
	cmp.b	#-5,d7
	bne.s	.no_pause
	move.l	d7,-(sp)
	move.b	(a0)+,d7
.llp	bsr	term_wait_vbl
	dbf	d7,.llp
	move.l	(sp)+,d7
	bra	term_loop
.no_pause
	cmp.b	#-6,d7
	bne.s	.no_anim_play
	moveq	#0,d7
	move.b	(a0)+,d7
	movem.l	d0-a6,-(sp)
	bsr	play_anim
	movem.l	(sp)+,d0-a6
	bra	term_loop
.no_anim_play
	rts
*************************************************
* Print the characters				*
* d0	-	xpos				*
* d1	-	ypos				*
* d7	-	char				*
*************************************************
.print_it
	movem.l	d0-a6,-(sp)
	lea	termfont,a2
	mulu	#5,d7
	add	d7,a2
	move.l	tv_addr1,a1
	mulu	#320,d1
	add.l	d1,a1
	move	d0,d1
	and	#$fff0,d1
	sub	d1,d0
	add	d1,a1
	move	colour,d3
	moveq	#5-1,d2
.hiloop
	move.l	#$ffff07ff,d1
	ror.l	d0,d1
	and	d1,(a1)
	and	d1,2(a1)
	and	d1,4(a1)
	and	d1,6(a1)
	and	d1,8(a1)
	and	d1,10(a1)
	and	d1,12(a1)
	and	d1,14(a1)
	swap	d1
	and	d1,16(a1)
	and	d1,18(a1)
	and	d1,20(a1)
	and	d1,22(a1)
	and	d1,24(a1)
	and	d1,26(a1)
	and	d1,28(a1)
	and	d1,30(a1)

	moveq	#0,d1
	move.b	(a2)+,d1
	lsl	#8,d1
	ror.l	d0,d1
	swap	d1
	move	d1,d4
	swap	d1
	btst	#0,d3
	beq.s	.nop0
	or	d1,(a1)
	or	d4,16(a1)
.nop0
	btst	#1,d3
	beq.s	.nop1
	or	d1,2(a1)
	or	d4,18(a1)
.nop1
	btst	#2,d3
	beq.s	.nop2
	or	d1,4(a1)
	or	d4,20(a1)
.nop2
	btst	#3,d3
	beq.s	.nop3
	or	d1,6(a1)
	or	d4,22(a1)
.nop3
	btst	#4,d3
	beq.s	.nop4
	or	d1,8(a1)
	or	d4,24(a1)
.nop4
	btst	#5,d3
	beq.s	.nop5
	or	d1,10(a1)
	or	d4,26(a1)
.nop5
	btst	#6,d3
	beq.s	.nop6
	or	d1,12(a1)
	or	d4,28(a1)
.nop6
	btst	#7,d3
	beq.s	.nop7
	or	d1,14(a1)
	or	d4,30(a1)
.nop7
	lea	320(a1),a1
	dbf	d2,.hiloop
	bsr	term_wait_vbl
	movem.l	(sp)+,d0-a6
	rts	

colour	dc.l	0
	dcb.l	10,0

do_bars
	cmp.w	#24,bar_val
	blt.s	.ok1
	move.w	#23,bar_val
	move.w	#-1,bar_vdir
.ok1
	tst.w	bar_val
	bpl.s	.ok2
	move.w	#0,bar_val
	move.w	#1,bar_vdir
.ok2
	move.w	bar_vdir,d0
	add.w	d0,bar_val


	move.w	bar_val,d0
	moveq	#24-1,d1
	lea	bar_colours(pc),a0
.loop
	move.l	(a0)+,a1
	add.l	bar_base,a1
	move.l	(a0)+,d2
	subq.w	#1,d0
	bpl.s	.ok3
	moveq	#0,d2
.ok3
	move.l	d2,(a1)
	dbf	d1,.loop
	rts
bar_vdir	
	dc.w	1
bar_val	
	dc.w	0
bar_colours
	dc.l	(80*4),$0f000000
	dc.l	(79*4),$1e000000
	dc.l	(78*4),$2d000000
	dc.l	(77*4),$3c000000
	dc.l	(76*4),$4b000000
	dc.l	(75*4),$58000000
	dc.l	(74*4),$69000000
	dc.l	(73*4),$78000000
	dc.l	(72*4),$87000000
	dc.l	(71*4),$96000000
	dc.l	(70*4),$a5000000
	dc.l	(69*4),$b4000000
	dc.l	(68*4),$c3000000
	dc.l	(67*4),$d2000000
	dc.l	(66*4),$e1000000
	dc.l	(65*4),$f0000000

	dc.l	(104*4),$d21f0000
	dc.l	(103*4),$b43e0000
	dc.l	(102*4),$965d0000
	dc.l	(101*4),$787c0000
	dc.l	(100*4),$589b0000
	dc.l	(99*4),$3cba0000
	dc.l	(98*4),$1ed90000
	dc.l	(97*4),$00f80000

play_anim
	sf	flicker_on
	move.w	d7,-(sp)
	bsr	fade_out_terminal
	move.w	(sp)+,d7
	lea	anim_addrs,a0
	move.l	(a0,d7.w*4),a0
	moveq	#0,d0
	bsr	hum_animplay
	bsr	fade_in_terminal
	st	flicker_on
	rts


	include	Terminal\decode.s

swamp_world_text
	dc.b	18,8,-2,0,$fc
	dc.b	"----- fed-net uplink on line   ",0
	dc.b	"point-counterpoint encyclopedia",0
	dc.b	"    of federation worlds       ",0
	dc.b	"entry no - 38g95-3554m4403d74  ",0
	dc.b	"system   - carrion             ",0
	dc.b	"world    - swampworld          ",0 
	dc.b	"-------------------------------",0
	dc.b	-3,-2,0,$fe
	dc.b	"ernie says - this valuable and ",0
	dc.b	"uninhabited world is a noted   ",0
	dc.b	"preserve for several species of",0
	dc.b	"rare wading birds. this is one ",0
	dc.b	"of the few unspoilt landscapes ",0
	dc.b	"of the federation and its      ",0
	dc.b	"beauty is unsurpassed.         ",0
	dc.b	-2,0,$fc
	dc.b	"----- click now.               ",0
	dc.b	-5,50
	dc.b	-4,-2,0,$fd
	dc.b	"wallace says - swampworld is a ",0
	dc.b	"disgusting stinking little hole",0
	dc.b	"with not one single redeeming  ",0
	dc.b	"feature. there are no bars. no ",0
	dc.b	"strip joints and the whole     ",0
	dc.b	"place is living evidence that  ",0
	dc.b	"mother nature is a bitch of the",0
	dc.b	"first degree.                  ",0
	dc.b	-2,0,$fc
	dc.b	"----- click now.               ",0
	dc.b	-5,50
	dc.b	-1
scene_6_text
	dc.b	18,8,-2,0,$fe
	dc.b	"    federation news service    ",0
	dc.b	"-------------------------------",0
	dc.b	"transmission 34-7785-t5-55-d367",0
	dc.b	"                               ",0
	dc.b	"subject - "
	dc.b	-3,-2,0,$fd
	dc.b	"spacejunk "
	dc.b	-2,0,$fe
	dc.b	"project....",0
	dc.b	"                               ",0
	dc.b	-3,-2,0,$fd
	dc.b	"spacejunk-",0
	dc.b	-2,0,$fe
	dc.b	"         what is it?           ",0
	dc.b	-2,0,$fc
	dc.b	"      where do i get it ?      ",0
	dc.b	-2,0,$fe
	dc.b	"      is it contagious ?       ",0
	dc.b	"                               ",0
	dc.b	"   these questions and others  ",0
	dc.b	" have been flying around the   ",0
	dc.b	"federation for months now......",0
	dc.b	"                               ",0
	dc.b	"but we at trans federation can ",0
	dc.b	"exclusively reveal to you the  ",0
	dc.b	"secret of this mysterious      ",0
	dc.b	"entity....                     ",0
	dc.b	"                               ",0
	dc.b	-3,-2,0,$fd
	dc.b	"spacejunk"
	dc.b	-2,0,$fe
	dc.b	" the game.           ",0
	dc.b	-2,0,$fc
	dc.b	"so good you will wet your pants",0
	dc.b	-2,0,$fe
	dc.b	"                               ",0
	dc.b	"  what more can we say. other  ",0
	dc.b	"than its                       ",0
	dc.b	-2,0,$fc
	dc.b	-3
	dc.b	"    a tale of treachary...     ",0
	dc.b	-6,0
	dc.b	"    a tale of revenge.....     ",0
	dc.b	-6,1
	dc.b	"    and a tale of exploding    ",0
	dc.b	"         jellyfish.....        ",0
	dc.b	-2,0,$fe
	dc.b	-6,2
	dc.b	"                               ",0
	dc.b	"so there you have it. "
	dc.b	-3,-2,0,$fd
	dc.b	"spacejunk",0
	dc.b	-2,0,$fe
	dc.b	" the game. better than sitting ",0
	dc.b	"  at home with your hand in a  ",0
	dc.b	"         blender....           ",0
	dc.b	-2,0,$fc
	dc.b	"----- click now.               ",0
	dc.b	-5,50
	dc.b	-1
	even
which_term	dc.w	0		;-----!!!!!!!!******
anim_addrs	dc.l	treachary_anim
		dc.l	revenge_anim
		dc.l	jellyfish_anim





 