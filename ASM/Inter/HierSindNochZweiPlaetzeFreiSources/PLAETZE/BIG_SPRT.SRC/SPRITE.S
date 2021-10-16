;
; Stax BIG sprite screen (Started: 1/10/93 - Completed: 11/10/93).
; - Screen created with Devpac Developer 1.07 -
;
; Credits:                   Code  : Bod
;                            Gfx   : Sodan
;                            Musix : TAO (ACF-Design Team)
;
; Contact Stax at:           Matthas Bock (Double dot over the 'o')
;                            Haherstr. 15
;                            46145 Oberhausen
;                            Germany.
;
; Contact United Forces at:  Stephen Jones
;                            94 Beaumont Road
;                            Halesowen
;                            West Midlands
;                            B62 9EX
;                            England
;
; Text buffer: 45kb, Assemble: 100kb, Tabs: 12
;
; External files neded...
;
;                premix.mus      - music file
;                font.fon        - 1 bitplane font
;                uf.dat          - large sprite (UF logo)
;                stax.dat        - small 4 bitplane sprites
;
; Demo features:     A 206 by 116 four bitplane sprite
;                    4 16 by 16 4 bitplane sprites
;                    A 1 bitplane four layer starfield (aroud 100 stars)
;                    A 1 bitplane scroller
;                    A 3 bitplane distorter
;                    And digi-drum music by TAO of the ACF-Design Team
;
	opt	o+,w-

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	lea	$fffff8240.w,a0
	moveq	#0,d0
	rept	8
	move.l	d0,(a0)+
	endr

clear_bss	lea	bss_start,a0
	lea	bss_end,a1
	moveq	#0,d0
.loop	cmp.l	a1,a0
	bge.s	.exit
	move.l	d0,(a0)+
	bra.s	.loop
.exit	lea	mystack,a7

	move.l	#screen_ram,d0
	clr.b	d0
	move.l	d0,screen1
	move.l	d0,oldsprite
	add.l	#32000+(160*40),d0
	move.l	d0,screen2
	lsr.l	#8,d0
	move.b	d0,$fffff8203.w
	lsr.w	#8,d0
	move.b	d0,$fffff8201.w

	bsr	silence
	moveq	#$12,d0
	bsr	ikbd
	moveq	#$1a,d0
	bsr	ikbd
	bsr	flush

	move.w	#$2700,sr
	move.l	$70.w,oldvbl
	move.l	$120.w,oldtb
	move.l	$118.w,oldkey
	move.b	$fffffa1b.w,mfp1
	move.b	$fffffa21.w,mfp2
	move.b	$fffffa07.w,mfp3
	move.b	$fffffa09.w,mfp4
	move.b	$fffffa13.w,mfp5
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	bclr	#6,$fffffa09.w
	move.l	#keyvector,$118.w
	bset	#6,$fffffa09.w
	move.l	#nulltb,$120.w
	move.l	#nullvbl,$70.w
	ori.b	#1,$fffffa07.w	
	ori.b	#1,$fffffa13.w
	clr.b	$fffffa1b.w	
	move.w	#$2300,sr

	moveq	#1,d0
	bsr	music

	bsr	pre_calc_dist
	bsr	make_object
	bsr	pre_work_ytable
	bsr	shift_big_sprite
	bsr	shift_small
	bsr	pre_calc_small_sprites
	bsr	setupstar
	bsr	intro_bit
	bsr	copy_dist_background
	bsr	vsync
	move.w	#$2700,sr
	move.l	#vbl,$70.w
	move.w	#$2300,sr	

loop	bsr	vsync
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	do_dist
	bsr	delete_stars
	bsr	draw_big_sprite
	bsr	plot_stars
	bsr	do_scroller
	bsr	flip
	movem.l	(sp)+,d0-d7/a0-a6
	cmp.b	#$39,kbuff
	bne.s	loop

	bsr	vsync

	moveq	#0,d0
	bsr	music

	move.w	#$2700,sr
	move.l	oldvbl,$70.w
	move.l	oldtb,$120.w
	move.l	oldkey,$118.w
	move.b	mfp1,$fffffa1b.w
	move.b	mfp2,$fffffa21.w
	move.b	mfp3,$fffffa07.w
	move.b	mfp4,$fffffa09.w
	move.b	mfp5,$fffffa13.w
	move.w	#$2300,sr

	lea	$fffff8240.w,a0
	moveq	#0,d0
	rept	8
	move.l	d0,(a0)+
	endr

	bsr	silence
	bsr	clearscreen

	moveq	#$16,d0
	bsr	ikbd
	moveq	#$8,d0
	bsr	ikbd

	bsr	flush

	clr.w -(sp)
	trap #1
	

vbl	clr.b	$ffffff8260.w
	move.b	#2,$fffff820a.w
	clr.b	$fffffa1b.w
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#lower_border,$120.w
	st	video
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	big_pal,d0-d7
	movem.l	d0-d7,$ffffff8240.w
	bsr	music+8
	movem.l	(sp)+,d0-d7/a0-a6
	rte

lower_border
	movem.l	a0/d0,-(sp)
	moveq	#0,d0
	lea	$ffffff8242.w,a0
	rept	7
	move.l	d0,(a0)+
	endr
	move.w	d0,(a0)+
	movem.l	(sp)+,a0/d0

	move.l	d0,-(sp)
	clr.b	$fffffa1b.w
	move.b	#223,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	$fffffa21.w,d0
.wait	cmp.b	$fffffa21.w,d0
	beq.s	.wait
	move.l	(sp)+,d0
	clr.b	$fffff820a.w
	rept	14
	nop
	endr
	move.b	#2,$ffff820a.w
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#timer_b1,$120.w
	bclr	#0,$fffffa0f.w
	rte

timer_b1	rept	32
	move.l	#$07000700,$fffff8240+16.w	;16
	move.l	#$07000700,$fffff8240+20.w	;20
	move.l	#$07000700,$fffff8240+24.w	;24
	move.l	#$07000700,$fffff8240+28.w	;28
	add.l	#48,$120.w
	bclr	#0,$fffffa0f.w
	rte
	endr

	movem.l	a0/d0,-(sp)
	lea	$fffff8240.w,a0
	moveq	#0,d0
	rept	8
	move.l	d0,(a0)+
	endr
	movem.l	(sp)+,a0/d0
	move.l	#nulltb,$120.w
nulltb	bclr	#0,$fffffa0f.w
	rte

intro_vbl	st	video
	clr.b	$fffff8260.w
	move.b	#2,$fffff820a.w
	movem.l	d0-d7/a0-a6,-(Sp)
	bsr	delete_small_sprites
	bsr	draw_small_sprites
	bsr	music+8
	movem.l	(sp)+,d0-d7/a0-a6
	rte

nullvbl	st	video
	clr.b	$fffff8260.w
	move.b	#2,$fffff820a.w
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	music+8
	movem.l	(sp)+,d0-d7/a0-a6
	rte

do_scroller	move.l	screen1,a1
	lea	160*201+6(a1),a1
	lea	8(a1),a0
x	set	0
	rept	32
	move.w	x(a0),x(a1)
	move.w	x+8(a0),x+8(a1)
	move.w	x+$10(a0),x+$10(a1)
	move.w	x+$18(a0),x+$18(a1)
	move.w	x+$20(a0),x+$20(a1)
	move.w	x+$28(a0),x+$28(a1)
	move.w	x+$30(a0),x+$30(a1)
	move.w	x+$38(a0),x+$38(a1)
	move.w	x+$40(a0),x+$40(a1)
	move.w	x+$48(a0),x+$48(a1)
	move.w	x+$50(a0),x+$50(a1)
	move.w	x+$58(a0),x+$58(a1)
	move.w	x+$60(a0),x+$60(a1)
	move.w	x+$68(a0),x+$68(a1)
	move.w	x+$70(a0),x+$70(a1)
	move.w	x+$78(a0),x+$78(a1)
	move.w	x+$80(a0),x+$80(a1)
	move.w	x+$88(a0),x+$88(a1)
	move.w	x+$90(a0),x+$90(a1)
	move.w	x+$98(a0),x+$98(a1)
x	set	x+160
	endr
	cmp.b	#5-1,scroll_cnt
	bne.s	.n1
	clr.b	scroll_cnt
	move.l	scrollpos,a0
	cmp.l	#scrollend,a0
	bne.s	.no_reset
	lea	scrolltext,a0
.no_reset	moveq	#0,d0
	move.b	(a0)+,d0
	tst.b	d0
	bne.s	.skip1
	move.b	#"#",d0
.skip1	cmp.b	#$20,d0
	bne.s	.skip2
	move.b	#"#",d0
.skip2	move.l	a0,scrollpos
	sub.b	#$21,d0
	mulu	#32*5,d0
	lea	font,a0
	add.l	d0,a0
	move.l	a0,fontpos
	bra.s	.over
.n1	addq.b	#1,scroll_cnt
.over	move.l	fontpos,a0
	move.l	screen1,a1	
	lea	8*19+(160*201)+6(a1),a1
y	set	0
x	set	0
	rept	32
	move.b	y(a0),x(a1)
	move.b	y+1(a0),x+1(a1)
x	set	x+160
y	set	y+5
	endr
	addq.l	#1,fontpos
	rts

delete_stars
	moveq	#0,d1
	movea.l	#star_5,a4
	moveq	#$63,d0
s_1	movea.l	(a4),a6
	move.l	$190(a4),(a4)+
	move.w	d1,(a6)
	dbf	d0,s_1
	rts

plot_stars	move.l	star_d7,d7
	add.l	screen1,d7
	movea.l	#star_1,a0
	movea.l	#star_2,a1
	movea.l	#star_3,a2
	movea.l	#star_4,a3
	movea.l	#star_6,a5
	movea.l	#star_7,a4
	moveq	#$63,d0
s_2	moveq	#0,d2
	move.w	(a1),d1
	add.w	(a0)+,d1
	cmpi.w	#$1f,d1
	blt.s	s_3
	move.w	#0,d1
	addq.w	#8,(a2)
	cmpi.w	#$98,(a2)
	ble.s	s_3
	move.w	#0,(a2)
s_3	move.w	d1,(a1)
	moveq	#0,d1
	move.w	(a3)+,d1
	add.w	(a2)+,d1
	add.l	d7,d1
	movea.l	d1,a6
	move.l	d1,(a4)+
	move.w	(a1)+,d2
	move.w	0(a5,d2.w),d3
	or.w	d3,(a6)
	dbf	d0,s_2
	rts

	dc.b	" *** HELLO, MUTHAFUCKA'!!!     "
	dc.b	"I SEE YOU'RE A CURIOUS PERSON, THAT"
	dc.b	" IS OBVOIUSLY TRYING TO RIP OF MY ROUTINES."
	dc.b	" WHY DON'T YOU LEARN TO CODE YOUR OWN ROUTINES?"
	dc.b	" OR IS THIS BEYOND YOUR 'BASIC' ABILITIES?"
	dc.b	" MAY YOU'RE TESTICLES SHRIVEL AND DROP OFF! ***"
	even

setupstar	move.l	#$646,star_d7
	movea.l	#star_5,a2
	movea.l	#star_4,a1
	moveq	#0,d2
	moveq	#$31,d1
sup_1	move.l	screen1,$190(a2)
	move.l	screen1,(a2)+
	move.w	d2,(a1)+
	addi.w	#$140,d2
	dbf	d1,sup_1
	addi.l	#$fa0,d2
	moveq	#$31,d1
sup_2	move.l	screen1,$190(a2)
	move.l	screen1,(a2)+
	move.w	d2,(a1)+
	addi.w	#$a0,d2
	dbf	d1,sup_2
	rts

draw_big_sprite
	moveq	#0,d3
	move.l	d3,d1
	move.l	xpos,a0
	move.w	(a0)+,d3
	cmp.w	#-1,d3
	bne.s	.n1
	lea	xtab,a0
	move.w	(a0)+,d3
.n1	move.l	a0,xpos
	move.l	ypos,a0
	move.w	(a0)+,d1
	cmp.w	#-1,d1
	bne.s	.n2
	lea	ytab,a0
	move.w	(a0)+,d1
.n2	move.l	a0,ypos
	lea	spritetab,a3
	move.l	screen1,a4
	moveq	#0,d2
	divs	#16,d3
	move.w	d3,d2
	lsl.w	#3,d2
	swap	d3
	lsl.w	#2,d3
	move.l	(a3,d3.w),a3
	lea	(a4,d1.w),a4
	add.l	d2,a4
	move.l	a4,oldsprite
x	set	0
y	set	0
	rept	116
	movem.l	(a3)+,d2-d7
	movem.l	d2-d7,y+x(a4)
	move.l	(a3)+,d7
	move.l	d7,y+x+(4*6)(a4)
	movem.l	(a3)+,d2-d7
	movem.l	d2-d7,y+x+(28*1)(a4)
	move.l	(a3)+,d7
	move.l	d7,y+x+(4*6)+(28*1)(a4)
	movem.l	(a3)+,d2-d7
	movem.l	d2-d7,y+x+(28*2)(a4)
	move.l	(a3)+,d7
	move.l	d7,y+x+(4*6)+(28*2)(a4)
	movem.l	(a3)+,d2-d7
	movem.l	d2-d7,y+x+(28*3)(a4)
	move.l	(a3)+,d7
	move.l	d7,y+x+(4*6)+(28*3)(a4)
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,y+x+(28*4)(a4)
y	set	y+(28*4)
x	set	x+160-112
	endr
	move.l	oldsprite,a3
	moveq	#0,d3
x	set	-160+(4*12)
	rept	4
	move.l	d3,x(a3)
	move.l	d3,x+(4*1)(a3)
	move.l	d3,x+(4*2)(a3)
	move.l	d3,x+(4*3)(a3)
	move.l	d3,x+(4*4)(a3)
	move.l	d3,x+(4*5)(a3)
x	set	x-160
	endr
x	set	160*116+(4*8)
	rept	3
	move.l	d3,x(a3)
	move.l	d3,x+(4*1)(a3)
	move.l	d3,x+(4*2)(a3)
	move.l	d3,x+(4*3)(a3)
	move.l	d3,x+(4*4)(a3)
	move.l	d3,x+(4*5)(a3)
	move.l	d3,x+(4*6)(a3)
	move.l	d3,x+(4*7)(a3)
	move.l	d3,x+(4*8)(a3)
	move.l	d3,x+(4*9)(a3)
	move.l	d3,x+(4*10)(a3)
	move.l	d3,x+(4*11)(a3)
x	set	x+160
	endr
	rts

do_dist	lea	dist_pos,a3
	lea	timer_b1+2,a2
	moveq	#0,d0
	move.l	(a3),a1
	moveq	#4-1,d2
	lea	dist_buff,a0
	move.l	a0,a4
.loop2
x	set	0
y	set	0
	rept	8
	move.l	a4,a0
	move.w	(a1)+,d0
	add.w	d0,a0
	move.l	x(a0),y(a2)
	move.l	x+4(a0),y+8(a2)
	move.l	x+8(a0),y+16(a2)
	move.l	x+12(a0),y+24(a2)
x	set	x+14*5
y	set	y+48
	endr
	lea	48*8(a2),a2
	lea	(14*8)*5(a4),a4
	move.l	a4,a0
	dbf	d2,.loop2

	addq.l	#2,(a3)
	move.l	(a3),a0
	cmp.l	#dist_table_end,a0
	blt.s	.skip1
	lea	dist_table,a0
.skip1	move.l	a0,(a3)
	rts

shift_big_sprite
	lea	sprite,a0
	lea	shifted,a1
	move.w	#116-1,d7
	lea	newspr,a6
	movea.l	a6,a5
	move.w	d7,d6
.copy	rept	16-1
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	endr
	clr.l	(a6)+
	clr.l	(a6)+
	dbf	d6,.copy
	move.w	#16-1,d5
.loop0	movea.l	a5,a6
	move.w	d7,d6
.maskloop	rept	16
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	endr
	dbf	d6,.maskloop
	movea.l	a5,a6
	move.w	d7,d6
.shiftloop	lsr	(a6)
x	set	8
	rept	16-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	2(a6)
x	set	10
	rept	16-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	4(a6)
x	set	12	
	rept	16-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	6(a6)
x	set	14
	rept	16-1
	roxr	x(a6)
x	set	x+8
	endr
	lea	120+8(a6),a6
	dbf	d6,.shiftloop
	dbf	d5,.loop0
	rts

flip	move.l	screen1,d0
	move.l	screen2,d1
	exg	d0,d1
	move.l	d0,screen1
	move.l	d1,screen2
	lsr.l	#8,d1
	move.b	d1,$fffff8203.w
	lsr.w	#8,d1
	move.b	d1,$fffff8201.w
	rts

flush	btst.b	#0,$fffffc00.w
	beq.s	.out
	move.b	$fffffc02.w,d0
	bra.s	flush
.out	bset	#6,$fffffa09.w
	rts

clearscreen	move.l	screen1,a0
	move.l	screen2,a1
	move.w	#((32000+(160*40))/4)-1,d0
	moveq	#0,d1
.loop	move.l	d1,(a0)+	
	move.l	d1,(a1)+	
	dbf	d0,.loop
	rts

silence	lea	$fffff8800.w,a0
	move.l	#$700ff00,(a0)
	move.l	#$8000000,(a0)
	move.l	#$9000000,(a0)
	move.l	#$a000000,(a0)
	rts

keyvector	move.w	d2,-(sp)
	move.b	$fffffc00.w,d2
	btst	#7,d2
	beq.s	vectorend
	move.b	$fffffc02.w,d2
	move.b	d2,kbuff
	bclr	#6,$fffffa11.w
vectorend	move.w	(sp)+,d2
	rte

ikbd	lea	$fffffc00.w,a1
.lop	move.b	(a1),d1
	btst	#1,d1
	beq.s	.lop
	move.b	d0,2(a1)
	rts

copy_dist_background
	lea	dist_back_gfx,a0
	move.l	screen1,a1
	move.l	screen2,a2
	lea	160*201(a1),a1
	lea	160*201(a2),a2
	moveq	#32-1,d0
.loop
x	set	0
	rept	160/4
	move.l	x(a0),x(a1)
	move.l	x(a0),x(a2)
x	set	x+4
	endr
	lea	160(a1),a1
	lea	160(a2),a2
	dbf	d0,.loop
	rts

pre_calc_dist
	lea	dist_table,a0
	moveq	#0,d0
.make_even	cmp.l	#dist_end,a0
	bge.s	.all_done
	move.w	(a0),d0
	and.w	#%11111110,d0
	move.w	d0,(a0)+
	bra.s	.make_even
.all_done	rts

pre_work_ytable
	lea	ytab,a0
.loop	moveq	#0,d0
	move.w	(A0),d0
	cmp.w	#-1,d0
	beq.s	.exit
	mulu	#160,d0
	sub.w	#160*47,d0
	move.w	d0,(a0)+
	bra.s	.loop
.exit	rts

make_object	lea	dist_object,a0
	lea	dist_buff,a1
	moveq	#32-1,d1
.loop0	move.l	a0,a2
	moveq	#5-1,d0
.loop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.l	a2,a0
	dbf	d0,.loop
	lea	14(a0),a0
	dbf	d1,.loop0
	rts

intro_bit	bsr	clearscreen
	bsr.s	print
	bsr	draw_small_sprites

	move.w	#$2700,sr
	move.l	#intro_vbl,$70.w
	move.l	#nulltb,$120.w
	move.w	#$2300,sr

	bsr	fadein

.loop	cmp.b	#$39,kbuff
	bne.s	.loop
.loop2	cmp.b	#$39,kbuff
	beq.s	.loop2
	
	bsr	fadeout

	move.w	#$2700,sr
	move.l	#nullvbl,$70.w
	move.w	#$2300,sr

	bsr	flush

	bsr	clearscreen
	rts

print	lea	intro_text,a0
	move.l	screen2,a2
	move.l	a2,a4
	move.l	#$00010007,d1
.loop	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#0,d0
	bne.s	.n0
	moveq	#$20,d0
.n0	cmp.b	#-1,d0
	beq.s	.exit
	cmp.b	#13,d0
	bne.s	.n1
	lea	160*8(a4),a4
	move.l	a4,a2
	move.l	#$00010007,d1
	bra.s	.loop
.n1	sub.b	#$20,d0
	mulu	#8,d0
	lea	small_font,a6
	add.l	d0,a6
x	set	0
	rept	8
	move.b	(a6)+,x(a2)
x	set	x+160
	endr
	swap	d1
	add.w	d1,a2
	bra.s	.loop
.exit	rts
	
delete_small_sprites
	lea	old_x,a0
	bsr.s	del_small
	lea	old_a,a0
	bsr.s	del_small
	lea	old_t,a0
	bsr.s	del_small
	lea	old_s,a0
	bsr.s	del_small
	rts

del_small	move.l	(a0)+,a1
	rept	16
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	160-16(a1),a1
	endr
	rts

draw_small_sprites
	move.l	y1,a0
	cmp.l	#ytabend,a0
	bne.s	.n1
	lea	small_ytable,a0
.n1	moveq	#0,d1
	move.w	(a0)+,d1
	move.l	a0,y1
	move.l	x_1,a0
	cmp.l	#xtabend,a0
	bne.s	.skip1
	lea	small_xtable,a0
.skip1	moveq	#0,d0
	move.w	(a0)+,d0
	move.l	a0,x_1
	lea	old_s,a5
	lea	x_tab,a0
	bsr	.draw
	move.l	y2,a0
	cmp.l	#ytabend,a0
	bne.s	.n2
	lea	small_ytable,a0
.n2	moveq	#0,d1
	move.w	(a0)+,d1
	move.l	a0,y2
	move.l	x_2,a0
	cmp.l	#xtabend,a0
	bne.s	.skip2
	lea	small_xtable,a0
.skip2	moveq	#0,d0
	move.w	(a0)+,d0
	move.l	a0,x_2
	lea	old_t,a5
	lea	a_tab,a0
	bsr	.draw
	move.l	y3,a0
	cmp.l	#ytabend,a0
	bne.s	.n3
	lea	small_ytable,a0
.n3	moveq	#0,d1
	move.w	(a0)+,d1
	move.l	a0,y3
	move.l	x_3,a0
	cmp.l	#xtabend,a0
	bne.s	.skip3
	lea	small_xtable,a0
.skip3	moveq	#0,d0
	move.w	(a0)+,d0
	move.l	a0,x_3
	lea	old_a,a5
	lea	t_tab,a0
	bsr.s	.draw
	move.l	y4,a0
	cmp.l	#ytabend,a0
	bne.s	.n4
	lea	small_ytable,a0
.n4	moveq	#0,d1
	move.w	(a0)+,d1
	move.l	a0,y4
	move.l	x_4,a0
	cmp.l	#xtabend,a0
	bne.s	.skip4
	lea	small_xtable,a0
.skip4	moveq	#0,d0
	move.w	(a0)+,d0
	move.l	a0,x_4
	lea	old_x,a5
	lea	s_tab,a0
	bsr.s	.draw
	rts

.draw	movem.l	d0-d7/a0-a6,-(sp)
	and.l	#$0000ffff,d0
	and.l	#$0000ffff,d1
	move.l	screen2,a1
	moveq	#0,d2
	divs	#16,d0
	move.w	d0,d2
	lsl.w	#3,d2
	swap	d0
	lsl.w	#2,d0
	move.l	(a0,d0.w),a0
	lea	(a1,d1.w),a1
	add.l	d2,a1
	move.l	a1,(a5)+
	move.w	#16-1,d0
.drawa	move.l	(a1),d4
	move.l	4(a1),d5
	move.l	8(a1),d6
	move.l	12(a1),d7
	move.l	d4,(a5)+
	move.l	d5,(a5)+
	move.l	d6,(a5)+
	move.l	d7,(a5)+
	movem.l	(a0)+,d1-d3
	and.l	d1,d4
	and.l	d1,d5
	or.l	d2,d4
	or.l	d3,d5
	movem.l	(a0)+,d1-d3
	and.l	d1,d6
	and.l	d1,d7
	or.l	d2,d6
	or.l	d3,d7
	move.l	d4,(a1)
	move.l	d5,4(a1)
	move.l	d6,8(a1)
	move.l	d7,12(a1)
	lea	160(a1),a1
	dbf	d0,.drawa
	movem.l	(sp)+,d0-d7/a0-a6
	rts

shift_small	bsr.s	s_s
	bsr	s_t
	bsr	s_a
	bsr	s_x
	rts

s_s	lea	small_sprs,a0
	lea	shift_s,a1
	move.w	#16-1,d7
	lea	new,a6
	movea.l	a6,a5
	move.w	d7,d6
.copy	rept	2-1
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	endr
	clr.l	(a6)+
	clr.l	(a6)+
	dbf	d6,.copy
	moveq	#16-1,d5
.loop0	movea.l	a5,a6
	move.w	d7,d6
.maskloop	rept	2
	move.w	(a6),d0
	or.w	2(a6),d0
	or.w	4(a6),d0
	or.w	6(a6),d0
	not.w	d0 
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	endr
	dbf	d6,.maskloop
	movea.l	a5,a6
	move.w	d7,d6
.shiftloop	lsr	(a6)
x	set	8
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	2(a6)
x	set	10
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	4(a6)
x	set	12
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	6(a6)
x	set	14
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lea	16(a6),a6
	dbf	d6,.shiftloop
	dbf	d5,.loop0
	rts

s_t	lea	small_sprs+((16*8)*1),a0
	lea	shift_t,a1
	move.w	#16-1,d7
	lea	new,a6
	movea.l	a6,a5
	move.w	d7,d6
.copy	rept	2-1
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	endr
	clr.l	(a6)+
	clr.l	(a6)+
	dbf	d6,.copy
	moveq	#16-1,d5
.loop0	movea.l	a5,a6
	move.w	d7,d6
.maskloop	rept	2
	move.w	(a6),d0
	or.w	2(a6),d0
	or.w	4(a6),d0
	or.w	6(a6),d0
	not.w	d0 
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	endr
	dbf	d6,.maskloop
	movea.l	a5,a6
	move.w	d7,d6
.shiftloop	lsr	(a6)
x	set	8
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	2(a6)
x	set	10
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	4(a6)
x	set	12
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	6(a6)
x	set	14
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lea	16(a6),a6
	dbf	d6,.shiftloop
	dbf	d5,.loop0
	rts

s_a	lea	small_sprs+((16*8)*2),a0
	lea	shift_a,a1
	move.w	#16-1,d7
	lea	new,a6
	movea.l	a6,a5
	move.w	d7,d6
.copy	rept	2-1
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	endr
	clr.l	(a6)+
	clr.l	(a6)+
	dbf	d6,.copy
	moveq	#16-1,d5
.loop0	movea.l	a5,a6
	move.w	d7,d6
.maskloop	rept	2
	move.w	(a6),d0
	or.w	2(a6),d0
	or.w	4(a6),d0
	or.w	6(a6),d0
	not.w	d0 
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	endr
	dbf	d6,.maskloop
	movea.l	a5,a6
	move.w	d7,d6
.shiftloop	lsr	(a6)
x	set	8
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	2(a6)
x	set	10
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	4(a6)
x	set	12
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	6(a6)
x	set	14
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lea	16(a6),a6
	dbf	d6,.shiftloop
	dbf	d5,.loop0
	rts

s_x	lea	small_sprs+((16*8)*3),a0
	lea	shift_x,a1
	move.w	#16-1,d7
	lea	new,a6
	movea.l	a6,a5
	move.w	d7,d6
.copy	rept	2-1
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	endr
	clr.l	(a6)+
	clr.l	(a6)+
	dbf	d6,.copy
	moveq	#16-1,d5
.loop0	movea.l	a5,a6
	move.w	d7,d6
.maskloop	rept	2
	move.w	(a6),d0
	or.w	2(a6),d0
	or.w	4(a6),d0
	or.w	6(a6),d0
	not.w	d0 
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	endr
	dbf	d6,.maskloop
	movea.l	a5,a6
	move.w	d7,d6
.shiftloop	lsr	(a6)
x	set	8
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	2(a6)
x	set	10
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	4(a6)
x	set	12
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lsr	6(a6)
x	set	14
	rept	2-1
	roxr	x(a6)
x	set	x+8
	endr
	lea	16(a6),a6
	dbf	d6,.shiftloop
	dbf	d5,.loop0
	rts

pre_calc_small_sprites
	lea	small_ytable,a0
.loop	moveq	#0,d0
	cmp.l	#ytabend,a0
	bge.s	.exit
	move.w	(A0),d0
	mulu	#160,d0
	sub.w	#4*160,d0
	move.w	d0,(a0)+
	bra.s	.loop
.exit	rts

vsync	sf	video
.wait	tst.b	video
	beq.s	.wait
	rts

fadein	lea	small_pal,a2
	moveq	#7-1,d3
.l21bf0	rept	4
	bsr.s	vsync
	endr
	lea	$ffff8240.w,a0
	movea.l	a2,a3
	moveq	#$f,d4
.l21bfa	move.w	(a0),d0
	and.w	#7,d0
	move.w	(a3),d5
	and.w	#7,d5
	cmp.w	d5,d0
	beq.s	.l21c0c
	addq.w	#1,d0
.l21c0c	move.w	(a0),d1
	and.w	#$70,d1
	move.w	(a3),d5
	and.w	#$70,d5
	cmp.w	d5,d1
	beq.s	.l21c20
	add.w	#$10,d1
.l21c20	move.w	(a0),d2
	and.w	#$700,d2
	move.w	(a3)+,d5
	and.w	#$700,d5
	cmp.w	d5,d2
	beq.s	.l21c34
	add.w	#$100,d2
.l21c34	move.w	d0,(a0)
	or.w	d1,(a0)
	or.w	d2,(a0)+
	dbf	d4,.l21bfa
	dbf	d3,.l21bf0
	rts

fadeout	moveq	#7-1,d3
.l21bb2	rept	4
	bsr.s	vsync
	endr
	lea	$ffff8240.w,a0
	moveq	#$f,d4
.l21bbc	move.b	(a0),d0
	and.w	#7,d0
	beq.s	.l21bc6
	subq.b	#1,d0
.l21bc6	move.w	(a0),d1
	and.w	#$70,d1
	beq.s	.l21bd2
	sub.b	#$10,d1
.l21bd2	move.w	(a0),d2
	and.w	#$700,d2
	beq.s	.l21bde
	sub.w	#$100,d2
.l21bde	move.w	d0,(a0)
	or.w	d1,(a0)
	or.w	d2,(a0)+
	dbf	d4,.l21bbc
	dbf	d3,.l21bb2
	rept	4
	bsr	vsync
	endr
	lea	$fffff8240.w,a0
	moveq	#0,d0
	rept	8
	move.l	d0,(a0)+
	endr
	rept	4
	bsr	vsync
	endr
	rts

small_pal	dc.w	0,$700,$FF8F,$FE8F,$FD8F,$FC8F,$FB8F,$FA8F
	dc.w	$F88F,$F88E,$F88D,$F88C,$FF8F,$F8F8,$F8F8,$F8F8
small_xtable
	dc.w	$a7,$b6,$c4
	dc.w	$d2,$df,$ec,$f8
	dc.w	$102,$10c,$115,$11d
	dc.w	$123,$128,$12c,$12e
	dc.w	$12e,$12e,$12c,$128
	dc.w	$123,$11d,$115,$10d
	dc.w	$103,$f8,$ec,$e0
	dc.w	$d2,$c5,$b6,$a8
	dc.w	$99,$8a,$7c,$6e
	dc.w	$60,$52,$46,$3a
	dc.w	$2f,$25,$1c,$15
	dc.w	$e,9,6,3
	dc.w	3,3,5,9
	dc.w	$e,$14,$1b,$24
	dc.w	$2e,$38,$44,$51
	dc.w	$5e,$6c,$7a,$89,$89+15
xtabend
small_ytable
	dc.w	$63,$67,$6C
	dc.w	$70,$75,$79,$7D
	dc.w	$81,$85,$89,$8D
	dc.w	$91,$95,$98,$9B
	dc.w	$9F,$A2,$A4,$A7
	dc.w	$AA,$AC,$AE,$B0
	dc.w	$B2,$B4,$B5,$B6
	dc.w	$B7,$B8,$B8,$B8
	dc.w	$B8,$B8,$B8,$B7
	dc.w	$B6,$B5,$B4,$B3
	dc.w	$B1,$AF,$AD,$AB
	dc.w	$A8,$A6,$A3,$A0
	dc.w	$9D,$9A,$96,$93
	dc.w	$8F,$8B,$87,$83
	dc.w	$7F,$7B,$77,$72
	dc.w	$6E,$69,$65,$61
	dc.w	$5C,$58,$53,$4F
	dc.w	$4A,$46,$42,$3E
	dc.w	$3A,$36,$32,$2E
	dc.w	$2A,$27,$23,$20
	dc.w	$1D,$1A,$17,$14
	dc.w	$12,$10,$E,$C
	dc.w	$A,9,7,6
	dc.w	6,5,5,5
	dc.w	5,5,5,6
	dc.w	7,8,$A,$B
	dc.w	$D,$F,$11,$13
	dc.w	$16,$19,$1C,$1F
	dc.w	$22,$25,$29,$2C
	dc.w	$30,$34,$38,$3C
	dc.w	$40,$44,$49,$4D
	dc.w	$52,$56,$5A,$5F
ytabend
y1	dc.l	small_ytable+8
y2	dc.l	small_ytable+16
y3	dc.l	small_ytable+24
y4	dc.l	small_ytable+32
x_1	dc.l	small_xtable+8
x_2	dc.l	small_xtable+16
x_3	dc.l	small_xtable+24
x_4	dc.l	small_xtable+32
s_tab	dc.l	s1,s2,s3,s4
	dc.l	s5,s6,s7,s8
	dc.l	s9,s10,s11,s12
	dc.l	s13,s14,s15,s16
t_tab	dc.l	t1,t2,t3,t4
	dc.l	t5,t6,t7,t8
	dc.l	t9,t10,t11,t12
	dc.l	t13,t14,t15,t16
a_tab	dc.l	a1,a2,a3,a4
	dc.l	a5,a6,a7,a8
	dc.l	a9,a10,a11,a12
	dc.l	a13,a14,a15,a16
x_tab	dc.l	x1,x2,x3,x4
	dc.l	x5,x6,x7,x8
	dc.l	x9,x10,x11,x12
	dc.l	x13,x14,x15,x16
small_sprs	incbin	e:\stax_den.tro\plaetze\big_sprt.src\stax.dat
	even
music	incbin          e:\stax_den.tro\plaetze\big_sprt.src\premix.mus
	even
dist_back_gfx
	dc.l	$ab5666cd,$1e3c0000
	dc.l	$ad5a9b36,$78f10000
	dc.l	$b56a6cd9,$e3c70000
	dc.l	$d5abb366,$8f1e0000
	dc.l	$56adcd9b,$3c780000
	dc.l	$5ab5366c,$f1e30000
	dc.l	$6ad5d9b3,$c78f0000
	dc.l	$ab5666cd,$1e3c0000
	dc.l	$ad5a9b36,$78f10000
	dc.l	$b56a6cd9,$e3c70000
	dc.l	$d5abb366,$8f1e0000
	dc.l	$56adcd9b,$3c780000
	dc.l	$5ab5366c,$f1e30000
	dc.l	$6ad5d9b3,$c78f0000
	dc.l	$ab5666cd,$1e3c0000
	dc.l	$ad5a9b36,$78f10000
	dc.l	$b56a6cd9,$e3c70000
	dc.l	$d5abb366,$8f1e0000
	dc.l	$56adcd9b,$3c780000
	dc.l	$5ab5366c,$f1e30000
		 ****************************************
intro_text	dc.b	13,13
	dc.b	"              HALELUJA!!!!",13
	dc.b	"             --------------",13
	dc.b	13
	dc.b	"AT LAST, HERE IS THE FIRST SCREEN DONE",13
	dc.b	"BY BOD OF STAX",13
	dc.b	13,13
	dc.b	"       IF YOU WANT TO CONTACT ME,     ",13
	dc.b	"PLEASE WRITE TO THE FOLLOWING ADDRESS:",13,13,13
	dc.b	"            BOD OF STAX,",13
	dc.b	"            94 BEAUMONT ROAD,",13
	dc.b	"            HALESOWEN,",13
	dc.b	"            WEST MIDLANDS,",13
	dc.b	"            B62 9EX.",13
	dc.b	"            ENGLAND.",13,13,13
	dc.b	"  NOW, HIT SPACE WHEN YOU'RE READY...",-1
	even
scrolltext	dc.b	"     HELLO, AND WELCOME TO THE FIRST SCREEN I'VE CODED AS A MEMBER"
	dc.b	" OF STAX OF UNITED FORCES...   I KNOW THIS SCREEN IS NOT TOTALLY AMAZING,"
	dc.b	" BUT I THINK IT'S PRETTY GOOD FOR A COUPLE OF DAYS WORK...   "
	dc.b	" TODAY'S DATE IS THE 21ST OCTOBER 1993 AND I HAVE TO SEND THIS SCREEN"
	dc.b	" TO MATT IN HALF AN HOUR IF IT'S TO GET TO HIM THIS WEEK (THE GERMAN"
	dc.b	" POSTAL SERVICE IS NOT VERY GOOD). IT WILL PROBLY BE A PART OF EITHER THE"
	dc.b	" FANTASIA DENTRO OR THE UNITED FORCES CONVENTION DEMO, BUT I AM UNSURE WHICH"
	dc.b	" IT WILL BE INCLUDED IN. AS I SAID EARLIER, THIS SCREEN IS FAR FROM AMAZING,"
	dc.b	" BUT IT DOES CONTAIN A 206 BY 116 FOUR BITPLANE SPRITE, A ONE BITPLANE, FOUR LAYER"
	dc.b	" STARFIELD, A ONE BITPLANE SCROLLER, A THREE BITPLANE DISTORTER, FOUR, FOUR BITPLANE"
	dc.b	" SPRITES (IN THE INTRO) AND A GREAT DIGI DRUM MUSIC. IF YOU WOULD LIKE TO CONTACT"
	dc.b	" UNITED FORCES THEN PLEASE WRITE TO THE ADDRESS IN THE INTRO SCREEN, OR IF YOU"
	dc.b	" MISSED IT, HERE IT IS AGAIN....    B O D  O F  S T A X  ,     9 4  B E A U M O N T  R D,"
	dc.b	"     H A L E S O W E N,     W E S T  M I D L A N D S,     B 6 2  9 E X.     E N G L A N D.    "
	dc.b	" I AM NOT INTERRESTED IN ILLEGAL SOFTWARE, JUST DEMOS 'N' STUFF...       "
	dc.b	" OK, NOW IT'S TIME TO TELL YOU WHO DID WHAT IN THIS SCREEN....     "
	dc.b	"GUILTY PARTIES:   BOD OF STAX - CODING, SODAN OF STAX - GRAPHICS AND TAO OF ACF - MUSIC.   "
	dc.b	" I SEND MY BEST REGARDS TO THE FOLLOWING PEOPLE:   ALL OTHER GUYS IN STAX,"
	dc.b	" THE NEW POWER GENERATION, TTK, ACF, INDEPENDANT, ANIMAL MINE, DARREN LOMAX, D.B.A,"
	dc.b	" THE CAREBEARS, THE LOST BOYS, UNLIMITED MATRICKS AND ZACK DE LA ROCHA, TOM MORELLO, BRAD WILK, TIMMY C. (AKA"
	dc.b	" RAGE AGAINST THE MACHINE)...    BECAUSE THIS SCREEN USES QUITE A LOT OF MEMORY I HAVE TO END THIS SCROLLTEXT"
	dc.b	" NOW.   SEE YA' IN ANOTHER SCREEN....          WRAP........                           "
scrollend	even
scrollpos	dc.l	scrolltext
font	incbin	e:\stax_den.tro\plaetze\big_sprt.src\font.fon
	even
scroll_cnt	dc.b	5-1
	even
small_font	dc.l	$00000000,$00000000,$00181818,$18001800,$00666666 
	dc.l	$00000000,$0066FF66,$66FF6600,$183E603C,$067C1800 
	dc.l	$00666C18,$30664600,$1C361C38,$6F663B00,$00181818 
	dc.l	$00000000,$000E1C18,$181C0E00,$00703818,$18387000 
	dc.l	$00663CFF,$3C660000,$0018187E,$18180000,$00000000 
	dc.l	$00181830,$0000007E,$00000000,$00000000,$00181800 
	dc.l	$00060C18,$30604000,$003C666E,$76663C00,$00183818 
	dc.l	$18187E00,$003C660C,$18307E00,$007E0C18,$0C663C00 
	dc.l	$000C1C3C,$6C7E0C00,$007E607C,$06663C00,$003C607C 
	dc.l	$66663C00,$007E060C,$18303000,$003C663C,$66663C00 
	dc.l	$003C663E,$060C3800,$00001818,$00181800,$00001818 
	dc.l	$00181830,$060C1830,$180C0600,$00007E00,$007E0000 
	dc.l	$6030180C,$18306000,$003C660C,$18001800,$003C666E 
	dc.l	$6E603E00,$00183C66,$667E6600,$007C667C,$66667C00 
	dc.l	$003C6660,$60663C00,$00786C66,$666C7800,$007E607C 
	dc.l	$60607E00,$007E607C,$60606000,$003E6060,$6E663E00 
	dc.l	$0066667E,$66666600,$007E1818,$18187E00,$00060606 
	dc.l	$06663C00,$00666C78,$786C6600,$00606060,$60607E00 
	dc.l	$0063777F,$6B636300,$0066767E,$7E6E6600,$003C6666 
	dc.l	$66663C00,$007C6666,$7C606000,$003C6666,$666C3600 
	dc.l	$007C6666,$7C6C6600,$003C603C,$06063C00,$007E1818 
	dc.l	$18181800,$00666666,$66667E00,$00666666,$663C1800 
	dc.l	$0063636B,$7F776300,$0066663C,$3C666600,$0066663C 
	dc.l	$18181800,$007E0C18,$30607E00,$001E1818,$18181E00 
	dc.l	$00406030,$180C0600,$00781818,$18187800,$00081C36 
	dc.l	$63000000,$00000000,$0000FF00,$00183C7E,$7E3C1800 
	dc.l	$00003C06,$3E663E00,$0060607C,$66667C00,$00003C60 
	dc.l	$60603C00,$0006063E,$66663E00,$00003C66,$7E603C00 
	dc.l	$000E183E,$18181800,$00003E66,$663E067C,$0060607C 
	dc.l	$66666600,$00180038,$18183C00,$00060006,$0606063C 
	dc.l	$0060606C,$786C6600,$00381818,$18183C00,$0000667F 
	dc.l	$7F6B6300,$00007C66,$66666600,$00003C66,$66663C00 
	dc.l	$00007C66,$667C6060,$00003E66,$663E0606,$00007C66 
	dc.l	$60606000,$00003E60,$3C067C00,$00187E18,$18180E00 
	dc.l	$00006666,$66663E00,$00006666,$663C1800,$0000636B 
	dc.l	$7F3E3600,$0000663C,$183C6600,$00006666,$663E0C78 
	dc.l	$00007E0C,$18307E00,$00183C7E,$7E183C00,$18181818 
	dc.l	$18181818,$007E787C,$6E660600,$08183878,$38180800 
	even
star_1	dc.b	0,2,0,4,0,8,0,2
	dc.b	0,4,0,$10,0,2,0,4
	dc.b	0,8,0,2,0,4,0,8
	dc.b	0,$10,0,4,0,8,0,2
	dc.b	0,4,0,8,0,2,0,4
	dc.b	0,8,0,2,0,$10,0,8
	dc.b	0,2,0,4,0,8,0,2
	dc.b	0,4,0,8,0,2,0,$10
	dc.b	0,8,0,2,0,4,0,8
	dc.b	0,2,0,4,0,8,0,2
	dc.b	0,4,0,$10,0,2,0,4
	dc.b	0,8,0,2,0,4,0,8
	dc.b	0,2,0,4,0,4,0,2
	dc.b	0,8,0,4,0,2,0,8
	dc.b	0,4,0,2,0,$10,0,4
	dc.b	0,2,0,8,0,4,0,2
	dc.b	0,4,0,2,0,8,0,$10
	dc.b	0,2,0,8,0,4,0,2
	dc.b	0,8,0,4,0,2,0,8
	dc.b	0,$10,0,2,0,8,0,4
	dc.b	0,2,0,8,0,4,0,2
	dc.b	0,8,0,4,0,$10,0,2
	dc.b	0,8,0,4,0,2,0,8
	dc.b	0,4,0,2,0,8,0,4
	dc.b	0,$10,0,8,0,4,0,2
	dc.b	0,8,0,4,0,2,0,$10
	dc.b	0,4,0,2,0,8,0,4
	dc.b	0,2
star_2	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
star_3	dc.b	0,$20,0,$28,0,$68,0,8
	dc.b	0,$58,0,$60,0,$7a,0,$80
	dc.b	0,$78,0,8,0,0,0,$40
	dc.b	0,$70,0,$88,0,$18,0,$48
	dc.b	0,$68,0,$48,0,$68,0,0
	dc.b	0,$70,0,$38,0,$40,0,0
	dc.b	0,$78,0,8,0,$38,0,$10
	dc.b	0,$30,0,$70,0,$50,0,$18
	dc.b	0,$30,0,$70,0,$60,0,$78
	dc.b	0,$20,0,$38,0,$10,0,0
	dc.b	0,$50,0,$78,0,$28,0,$48
	dc.b	0,$10,0,$80,0,$18,0,$68
	dc.b	0,0,0,$60,0,$60,0,0
	dc.b	0,$68,0,$18,0,$80,0,$10
	dc.b	0,$48,0,$28,0,$78,0,$50
	dc.b	0,0,0,$10,0,$38,0,$20
	dc.b	0,$78,0,$60,0,$70,0,$30
	dc.b	0,$18,0,$50,0,$70,0,$30
	dc.b	0,$10,0,$38,0,8,0,$78
	dc.b	0,0,0,$40,0,$38,0,$70
	dc.b	0,0,0,$68,0,$48,0,$68
	dc.b	0,$48,0,$18,0,$88,0,$70
	dc.b	0,$40,0,0,0,8,0,$78
	dc.b	0,$80,0,$7a,0,$60,0,$58
	dc.b	0,8,0,$68,0,$28,0,$20
star_4	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
star_5	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
star_7	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
star_6	dc.b	$80,0,$40,0,$20,0,$10,0
	dc.b	8,0,4,0,2,0,1,0
	dc.b	0,$80,0,$40,0,$20,0,$10
	dc.b	0,8,0,4,0,2,0,1
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,$37,$8a,3,0
	dc.b	0,1,$8d,$8a,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,$ff,$ff
	dc.b	0,0,0,3,0,2,$a3,$c0
	dc.b	0,2,$98,$ec,0,2,$20,$86
	dc.b	0,0,0,$2e,0,$4a,0,0
	dc.b	0,2,$17,0,0,2,$2e,$b0
ypos	dc.l	ytab
xpos	dc.l	xtab
ytab	dc.w	$5b,$5c,$5d
	dc.w	$5f,$60,$61,$63
	dc.w	$64,$65,$67,$68
	dc.w	$69,$6a,$6b,$6d
	dc.w	$6e,$6f,$70,$71
	dc.w	$72,$73,$74,$75
	dc.w	$76,$77,$78,$79
	dc.w	$79,$7a,$7b,$7c
	dc.w	$7c,$7d,$7e,$7e
	dc.w	$7f,$7f,$80,$80
	dc.w	$80,$81,$81,$81
	dc.w	$81,$81,$81,$81
	dc.w	$81,$81,$81,$81
	dc.w	$81,$81,$81,$80
	dc.w	$80,$80,$7f,$7f
	dc.w	$7e,$7e,$7d,$7c
	dc.w	$7c,$7b,$7a,$79
	dc.w	$79,$78,$77,$76
	dc.w	$75,$74,$73,$72
	dc.w	$71,$70,$6f,$6e
	dc.w	$6c,$6b,$6a,$69
	dc.w	$68,$66,$65,$64
	dc.w	$63,$61,$60,$5f
	dc.w	$5d,$5c,$5b,$59
	dc.w	$58,$57,$55,$54
	dc.w	$53,$51,$50,$4f
	dc.w	$4e,$4c,$4b,$4a
	dc.w	$49,$47,$46,$45
	dc.w	$44,$43,$42,$41
	dc.w	$40,$3f,$3e,$3d
	dc.w	$3c,$3b,$3a,$39
	dc.w	$39,$38,$37,$37
	dc.w	$36,$35,$35,$34
	dc.w	$34,$33,$33,$33
	dc.w	$32,$32,$32,$32
	dc.w	$32,$32,$32,$32
	dc.w	$32,$32,$32,$32
	dc.w	$32,$32,$33,$33
	dc.w	$34,$34,$34,$35
	dc.w	$36,$36,$37,$37
	dc.w	$38,$39,$3a,$3b
	dc.w	$3b,$3c,$3d,$3e
	dc.w	$3f,$40,$41,$42
	dc.w	$43,$44,$46,$47
	dc.w	$48,$49,$4a,$4c
	dc.w	$4d,$4e,$4f,$51
	dc.w	$52,$53,$55,$56
	dc.w	$57,$59
	dc.w	-1
	even
xtab	dc.w	$34,$36,$39
	dc.w	$3b,$3e,$40,$42
	dc.w	$45,$47,$49,$4b
	dc.w	$4d,$50,$51,$53
	dc.w	$55,$57,$58,$5a
	dc.w	$5b,$5d,$5e,$5f
	dc.w	$60,$61,$62,$62
	dc.w	$63,$63,$63,$63
	dc.w	$63,$63,$63,$63
	dc.w	$62,$62,$61,$60
	dc.w	$5f,$5e,$5d,$5c
	dc.w	$5b,$59,$58,$56
	dc.w	$54,$52,$50,$4e
	dc.w	$4c,$4a,$48,$46
	dc.w	$44,$41,$3f,$3c
	dc.w	$3a,$38,$35,$33
	dc.w	$30,$2e,$2b,$29
	dc.w	$26,$24,$22,$1f
	dc.w	$1d,$1b,$19,$16
	dc.w	$14,$12,$11,$f
	dc.w	$d,$b,$a,8
	dc.w	7,6,5,4
	dc.w	3,2,1,1
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	1,2,2,3
	dc.w	4,5,6,8
	dc.w	9,$b,$c,$e
	dc.w	$10,$12,$14,$16
	dc.w	$18,$1a,$1c,$1e
	dc.w	$21,$23,$25,$28
	dc.w	$2a,$2d,$2f,$2f+3
	dc.w	-1
	even
big_pal	dc.w	$000,$203,$313,$423,$533,$412,$753,$421
	dc.w	$777,$643,$754,$310,$512,$623,$734,$632
spritetab	dc.l	sprite1,sprite2,sprite3,sprite4
	dc.l	sprite5,sprite6,sprite7,sprite8
	dc.l	sprite9,sprite10,sprite11,sprite12
	dc.l	sprite13,sprite14,sprite15,sprite16
sprite	incbin	e:\stax_den.tro\plaetze\big_sprt.src\uf.dat
	even
dist_table	dc.w	$1E,$1F,$20
	dc.w	$21,$22,$23,$24
	dc.w	$25,$26,$27,$28
	dc.w	$29,$2A,$2B,$2C
	dc.w	$2D,$2E,$2E,$2F
	dc.w	$30,$31,$31,$32
	dc.w	$33,$34,$34,$35
	dc.w	$35,$36,$37,$37
	dc.w	$38,$38,$39,$39
	dc.w	$39,$3A,$3A,$3A
	dc.w	$3B,$3B
	dc.w	$3A,$3A,$3A,$39
	dc.w	$39,$39,$38,$38
	dc.w	$37,$37,$36,$35
	dc.w	$35,$34,$34,$33
	dc.w	$32,$31,$31,$30
	dc.w	$2F,$2E,$2D,$2D
	dc.w	$2C,$2B,$2A,$29
	dc.w	$28,$27,$26,$25
	dc.w	$24,$23,$22,$21
	dc.w	$20,$1F,$1E,$1D
	dc.w	$1C,$1B,$1A,$19
	dc.w	$18,$17,$16,$16
	dc.w	$15,$14,$13,$12
	dc.w	$11,$10,$F,$E
	dc.w	$D,$D,$C,$B
	dc.w	$A,9,9,8
	dc.w	7,7,6,5
	dc.w	5,4,4,3
	dc.w	3,2,2,2
	dc.w	1,1,1
	dc.w	0,0,0,1
	dc.w	1,1,2,2
	dc.w	3,3,3,4
	dc.w	4,5,6,6
	dc.w	7,8,8,9
	dc.w	$A,$A,$B,$C
	dc.w	$D,$E,$F,$F
	dc.w	$10,$11,$12,$13
	dc.w	$14,$15,$16,$17
	dc.w	$18,$19,$1A,$1B
	dc.w	$1C
dist_table_end
	dc.w	$1E,$1F,$20
	dc.w	$21,$22,$23,$24
	dc.w	$25,$26,$27,$28
	dc.w	$29,$2A,$2B,$2C
	dc.w	$2D,$2E,$2E,$2F
	dc.w	$30,$31,$31,$32
	dc.w	$33,$34,$34,$35
	dc.w	$35,$36,$37,$37
	dc.w	$38,$38,$39,$39
	dc.w	$39,$3A,$3A,$3A
	dc.w	$3B,$3B,$3B,$3B
	dc.w	$3A,$3A,$3A,$39
	dc.w	$39,$39,$38,$38
	dc.w	$37,$37,$36,$35
	dc.w	$35,$34,$34,$33
	dc.w	$32,$31,$31,$30
	dc.w	$2F,$2E,$2D,$2D
	dc.w	$2C,$2B,$2A,$29
	dc.w	$28,$27,$26,$25
	dc.w	$24,$23,$22,$21
	dc.w	$20,$1F,$1E,$1D
	dc.w	$1C,$1B,$1A,$19
	dc.w	$18,$17,$16,$16
	dc.w	$15,$14,$13,$12
	dc.w	$11,$10,$F,$E
	dc.w	$D,$D,$C,$B
	dc.w	$A,9,9,8
	dc.w	7,7,6,5
	dc.w	5,4,4,3
	dc.w	3,2,2,2
	dc.w	1,1,1,0
	dc.w	0,0,0,0
	dc.w	0,0,0,1
	dc.w	1,1,2,2
	dc.w	3,3,3,4
	dc.w	4,5,6,6
	dc.w	7,8,8,9
	dc.w	$A,$A,$B,$C
	dc.w	$D,$E,$F,$F
	dc.w	$10,$11,$12,$13
	dc.w	$14,$15,$16,$17
	dc.w	$18,$19,$1A,$1B
	dc.w	$1C
dist_end
dist_pos	dc.l	dist_table
dist_object	dc.w	$001,$002,$003,$004,$005,$006,$777	;s
	dc.w	$001,$222,$333,$444,$555,$666,$777
	dc.w	$001,$222,$333,$444,$555,$666,$777
	dc.w	$001,$002,$003,$004,$005,$006,$777
	dc.w	$111,$222,$333,$444,$555,$006,$777
	dc.w	$111,$222,$333,$444,$555,$006,$777
	dc.w	$001,$002,$003,$004,$005,$006,$777
	dc.w	$111,$222,$333,$444,$555,$666,$777

	dc.w	$001,$002,$003,$004,$005,$006,$777	;t
	dc.w	$111,$222,$333,$004,$555,$666,$777
	dc.w	$111,$222,$333,$004,$555,$666,$777
	dc.w	$111,$222,$333,$004,$555,$666,$777
	dc.w	$111,$222,$333,$004,$555,$666,$777
	dc.w	$111,$222,$333,$004,$555,$666,$777
	dc.w	$111,$222,$333,$004,$555,$666,$777
	dc.w	$111,$222,$333,$444,$555,$666,$777

	dc.w	$001,$002,$003,$004,$005,$006,$777	;a
	dc.w	$001,$222,$333,$444,$555,$006,$777
	dc.w	$001,$222,$333,$444,$555,$006,$777
	dc.w	$001,$002,$003,$004,$005,$006,$777
	dc.w	$001,$222,$333,$444,$555,$006,$777
	dc.w	$001,$222,$333,$444,$555,$006,$777
	dc.w	$001,$222,$333,$444,$555,$006,$777
	dc.w	$111,$222,$333,$444,$555,$666,$777

	dc.w	$001,$222,$333,$444,$555,$006,$777	;x
	dc.w	$111,$002,$333,$444,$005,$666,$777
	dc.w	$111,$222,$003,$004,$555,$666,$777
	dc.w	$111,$222,$333,$004,$555,$666,$777
	dc.w	$111,$222,$003,$004,$555,$666,$777
	dc.w	$111,$002,$333,$444,$005,$666,$777
	dc.w	$001,$222,$333,$444,$555,$006,$777
	dc.w	$111,$222,$333,$444,$555,$666,$777
dist_ob_end
dist_copy	equ	(dist_ob_end-dist_object)*5

	section	bss

bss_start	ds.l	250
mystack	ds.l	1
fontpos	ds.l	1
oldsprite	ds.l	1
screen1	ds.l	1
screen2	ds.l	1
star_d7	ds.l	1
kbuff	ds.w	1
oldkey	ds.l	1
oldvbl	ds.l	1
oldtb	ds.l	1
mfp1	ds.b	1
mfp2	ds.b	1
mfp3	ds.b	1
mfp4	ds.b	1
mfp5	ds.b	1
video	ds.b	1
	even
dist_buff	ds.b	dist_copy
	even
newspr	ds.b	14848
	even
shifted	ds.b	14848*16
sprite1	equ	shifted
sprite2	equ	sprite1+14848
sprite3	equ	sprite2+14848
sprite4	equ	sprite3+14848
sprite5	equ	sprite4+14848
sprite6	equ	sprite5+14848
sprite7	equ	sprite6+14848
sprite8	equ	sprite7+14848
sprite9	equ	sprite8+14848
sprite10	equ	sprite9+14848
sprite11	equ	sprite10+14848
sprite12	equ	sprite11+14848
sprite13	equ	sprite12+14848
sprite14	equ	sprite13+14848
sprite15	equ	sprite14+14848
sprite16	equ	sprite15+14848
	even
old_s	ds.b	1024
old_t	ds.b	1024
old_a	ds.b	1024
old_x	ds.b	1024
new	ds.b	256
shift_s	ds.b	384*16
	even
s1	equ	shift_s
s2	equ	s1+384
s3	equ	s2+384
s4	equ	s3+384
s5	equ	s4+384
s6	equ	s5+384
s7	equ	s6+384
s8	equ	s7+384
s9	equ	s8+384
s10	equ	s9+384
s11	equ	s10+384
s12	equ	s11+384
s13	equ	s12+384
s14	equ	s13+384
s15	equ	s14+384
s16	equ	s15+384
shift_t	ds.b	384*16
	even
t1	equ	shift_t
t2	equ	t1+384
t3	equ	t2+384
t4	equ	t3+384
t5	equ	t4+384
t6	equ	t5+384
t7	equ	t6+384
t8	equ	t7+384
t9	equ	t8+384
t10	equ	t9+384
t11	equ	t10+384
t12	equ	t11+384
t13	equ	t12+384
t14	equ	t13+384
t15	equ	t14+384
t16	equ	t15+384
shift_a	ds.b	384*16
	even
a1	equ	shift_a
a2	equ	a1+384
a3	equ	a2+384
a4	equ	a3+384
a5	equ	a4+384
a6	equ	a5+384
a7	equ	a6+384
a8	equ	a7+384
a9	equ	a8+384
a10	equ	a9+384
a11	equ	a10+384
a12	equ	a11+384
a13	equ	a12+384
a14	equ	a13+384
a15	equ	a14+384
a16	equ	a15+384
shift_x	ds.b	384*16
	even
x1	equ	shift_x
x2	equ	x1+384
x3	equ	x2+384
x4	equ	x3+384
x5	equ	x4+384
x6	equ	x5+384
x7	equ	x6+384
x8	equ	x7+384
x9	equ	x8+384
x10	equ	x9+384
x11	equ	x10+384
x12	equ	x11+384
x13	equ	x12+384
x14	equ	x13+384
x15	equ	x14+384
x16	equ	x15+384
	even
	ds.b	256
screen_ram
	ds.b 64500
bss_end	end
