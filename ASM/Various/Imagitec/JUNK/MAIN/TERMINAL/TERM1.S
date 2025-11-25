wait_0	equ	100
wait_1	equ	100
wait_2	equ	100

flash_on	equ	1
title_offset	equ	320*8+16
window_offset	equ	320*8+16*14
main_high	equ	128
window_high	equ	64
atari_Pal	equ	$fffff9800
static_colour	equ	atari_pal+255*4

term_program
	push
	move.l	#term_tv,d0
	and.b	#%11111100,d0
	move.l	d0,tv_addr1
	move.l	#$e00000,static_addr
	move.l	#col_pal_term,bar_base
	move.l	$70.w,-(sp)
	move.l	#term_new4,$70.w
	bsr	term_main
	move.l	(sp)+,$70.w
	pull
	rts

	even
smaskp	incbin	e:\junk\main\terminal\bit3.spa

smaskp1	dc.l	smaskp
	even
termfont
	incbin	e:\junk\main\terminal\5x5font.dat
	ds.b	30
	even


	include	e:\junk\main\terminal\bangfade.s


term_new4
	Move.w	#0,Scr_Del	
	Move.w	#0,Scr_Mod
	addq.w	#1,term_clock
	movem.l	d0-a6,-(sp)
	move.l	tv_addr1,-(sp)
	move.b	1(sp),$ffff8201.w		tv set up
	move.b	2(sp),$ffff8203.w		tv set up
	move.b	3(sp),$ffff820d.w
	addq.l	#4,sp
	lea	new_pal_term,a0
	lea	(atari_pal).w,a1
	move.w	#256-1,d0
.lp	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	bsr	do_bars
	tst.b	static_display
	bne	.do_static
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
	move.l	d0,atari_pal+(254*4)
	move.l	d1,atari_pal+(253*4)
	move.l	d2,atari_pal+(252*4)
	movem.l	d0-d2,-(sp)
	movem.l	(sp)+,d0-d2
.no_flicker
	move.l	d0,col_pal_term+(254*4)
	move.l	d1,col_pal_term+(253*4)
	move.l	d2,col_pal_term+(252*4)
	bra	.no_static
.do_static
	bsr	static_colours
	bsr	static_picture
.no_static
	Jsr	Nt_Vbl
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
	move.l	#col_pal_term,a6
	move.l	#atari_pal,a5
	moveq	#0,d7
	move.w	#128-1,d0		no times
	move.w	#255,d1			init value
	moveq	#-2,d2			increase
	bra.s	fader
fade_in_terminal
	move.l	#col_pal_term,a6
	move.l	#atari_pal,a5
	moveq	#0,d7			fade speed
	move.w	#128-1,d0		no times
	moveq	#0,d1			init value
	moveq	#2,d2			increase
fader	move.l	a6,bar_base
.lp	move.w	#256-1,d3		do all colours
	lea	col_pal_term,a0
	lea	new_pal_term,a1
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


copy_term
	lea	term_pic,a0
	move.l	#term_tv,d0
	and.b	#%11111100,d0
	move.l	d0,tv_addr1
	move.l	d0,a1
	move.w	#64000/4-1,d0
.lp	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	lea	col_pal_term,a1
	move.w	#256-1,d0
.lp1	move.l	(a0)+,(a1)+
	dbf	d0,.lp1
	rts
term_main	
	bsr	copy_term
	bsr	fade_in_terminal
	bsr	do_terminal
	bsr	fade_out_terminal
	rts

do_terminal
	clr.l	static_colour
	st	static_display
	st	static_fade_in
	bsr	stat_wait_0
	st	static_fade_out
	bsr	stat_wait_1
	sf	static_display
	
	bsr	term_wait_vbl
	bsr	cls_page
	bsr	term_wait_vbl
	bsr	cls_page
	st	piccy_start
	bsr	bang_fade_in
	st	flicker_on
	bsr	show_title
	bsr	wait_a_while
	bsr	bang_fade_out
	sf	flicker_on
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

wait_for_piccy
show_title
	lea	swamp_world_text,a0
	moveq	#18,d0
	moveq	#8,d1
	bsr	print_term
	rts

*************************************************
* Print routine for 5x5 font			*
* D0 - start xpos				*
* d1 - Start ypos				*
* a0 - Text address				*
*************************************************
print_term
	move	d0,d2			;save xpos
.loop
	move.b	(a0)+,d7
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
	blt	.space
	cmp.b	#"z",d7
	bgt	.space
	sub	#"a"-10,d7
	bra.s	.print
.space
	moveq	#41,d7
.print
	bsr	.print_it
	tst.b	(a0)
	beq	.skipc1
	movem.l	d0/d7,-(sp)
	moveq	#40,d7
	addq	#6,d0
	bsr	.print_it
	movem.l	(sp)+,d0/d7
.skipc1
	bsr	.print_it
	tst.b	(a0)
	beq	.skipc2
	movem.l	d0/d7,-(sp)
	moveq	#40,d7
	addq	#6,d0
	bsr	.print_it
	movem.l	(sp)+,d0/d7
.skipc2
	addq	#6,d0 
	bra	.loop
.next_line
	move	d2,d0
	addq	#6,d1
	bra	.loop
.exit
	cmp.b	#-2,d7
	bne.s	.not_colour
	move.b	(a0)+,colour
	move.b	(a0)+,colour+1
	bra	.loop
.not_colour
	cmp.b	#-3,d7
	bne.s	.no_save_pointer
	move.b	d0,save_x
	move.b	d1,save_y
	bra	.loop
.no_save_pointer
	cmp.b	#-4,d7
	bne.s	.no_restore
	move.b	save_x,d0
	move.b	save_y,d1
	bra	.loop
.no_restore
	cmp.b	#-5,d7
	bne.s	.no_pause
	move.l	d7,-(sp)
	moveq	#0,d7
	move.b	(a0)+,d7
.llp	bsr	term_wait_vbl
	dbf	d7,.llp
	move.l	(sp)+,d7
	bra	.loop
.no_pause
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
	beq	.nop0
	or	d1,(a1)
	or	d4,16(a1)
.nop0
	btst	#1,d3
	beq	.nop1
	or	d1,2(a1)
	or	d4,18(a1)
.nop1
	btst	#2,d3
	beq	.nop2
	or	d1,4(a1)
	or	d4,20(a1)
.nop2
	btst	#3,d3
	beq	.nop3
	or	d1,6(a1)
	or	d4,22(a1)
.nop3
	btst	#4,d3
	beq	.nop4
	or	d1,8(a1)
	or	d4,24(a1)
.nop4
	btst	#5,d3
	beq	.nop5
	or	d1,10(a1)
	or	d4,26(a1)
.nop5
	btst	#6,d3
	beq	.nop6
	or	d1,12(a1)
	or	d4,28(a1)
.nop6
	btst	#7,d3
	beq	.nop7
	or	d1,14(a1)
	or	d4,30(a1)
.nop7
	lea	320(a1),a1
	dbf	d2,.hiloop
	bsr	term_wait_vbl
	movem.l	(sp)+,d0-a6
	rts	

colour	ds.l	1
	ds.l	10

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
	lea	bar_colours,a0
.loop
	move.l	(a0)+,a1
	add.l	bar_base,a1
	move.l	(a0)+,d2
	subq.w	#1,d0
	bpl.s	.ok3
	move.l	#0,d2
.ok3
	move.l	d2,(a1)
	dbf	d1,.loop
	rts

term_wait_vbl
	move.l	d0,-(sp)
	move.w	term_clock,d0
.lp	cmp.w	term_clock,d0
	beq.s	.lp
	move.l	(sp)+,d0
	rts

bar_vdir	
	dc.w	1
bar_val	
	ds.w	1
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


swamp_world_text
	dc.b	-2,0,$fc
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

term_pic	incbin	e:\junk\main\terminal\terminal.spa
