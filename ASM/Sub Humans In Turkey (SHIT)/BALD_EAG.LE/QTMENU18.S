;
;
;Super low border bouncy scroller
;      by Sub Humans In Turkey
;
;
vsync	equ 	$25
superx	equ	38
xbtimer	equ	31
jenabin	equ	27
jdisint	equ	26
c_conin	equ	1
c_conis	equ	11
vbl.vec	equ	$70
hbl.vec	equ	$120
tmrb.ctl equ 	$fffa1b
tmrb.dat equ 	$fffa21
mfp.ier	equ	$fffa07
mfp.imr	equ	$fffa13
;
;Go into supervisor mode for rest of program.
;Call main.program
;


	move.l $4(a7),a5
	move.l #$200,-(sp)
	move.l a5,-(sp)
	move.l #$4a0000,-(sp)
	trap #1
	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	move.l d0,ssp
	lea $12(a7),a7
	move.b $fffffa07.w,xa07
	move.b $fffffa0f.w,xa0f
	move.b $fffffa1b.w,xa1b
	move.l $44e.w,x44e
	move.l $45e.w,x45e
	move.b $fffffa13.w,xa13
	move.b $fffffa21.w,xa21
	clr.b $484.w
	clr.l d0
	clr.l d1
	clr.l d2
	clr.l d3
	clr.l d4
	clr.l d5
	clr.l d6
	clr.l d7

main.program
	lea	stack+512(pc),a7
	move.w #2,-(sp)
	trap #14
	move.l d0,scrn
	dc.w	$a00a	


	move.w	#4,-(sp)		;store current rez
	trap	#14			;
	move.w	d0,cur_rez		;
	
	clr.w	-(sp)		;set low rez
	move.l	#$76000,-(sp)		;
	move.l	(a7),-(sp)		;
	move.w	#5,-(sp)		;
	trap	#14			;
	lea 	$16(a7),sp			;
	
	movem.l	$ffff8240.w,d0-d7	;save colour registers
	movem.l	d0-d7,sav_cols
	
   	lea	picture+2,a0
	movem.l	(a0),d0-d7		;put picture colours in regs.
	movem.l	d0-d7,$ffff8240.w
	movem.l	d0-d7,old_colour
	
	move.w	#$a000,d0
	move.l	#$40000,a0
clear	clr.l	(a0)+
	dbf	d0,clear
	move.w	#$a000,d0
clear2	clr.l	(a0)+
	dbf	d0,clear2
	
	move.l	$462.w,d0			;wait on vblank
.wait2	cmp.l	$462.w,d0			;
	beq.s	.wait2			;

	bsr	enable.lowborder	;init HBL & VBL routines
	
picture_to_screen
	move.w	#$1f3f,d0
	lea	picture+34,a0
	lea	$76000,a1
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop	

play_music
	move.l	#vbl1,$4de.w
	moveq.l	#1,d0
	bsr	music1+$54
	move.l	scrbase,a1
	add.l	#200*160,a1		;
	move	#47*40,d0		;
.loop1	clr.l	(a1)+			;
	dbf	d0,.loop1		;
	
make 
	clr.l	d0
	lea 	$40000,a3
.ml1	lea 	charset+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml1
	clr.l	d0
.ml2	lea 	charset+(160*32)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml2
	clr.l	d0
.ml3	lea 	charset+(160*64)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml3
	clr.l	d0
.ml4	lea 	charset+(160*96)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml4
	clr.l	d0
.ml5	lea 	charset+(160*128)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#6,d0
	bne.s	.ml5

make2 
	clr.l	d0
.ml1	lea 	charset+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml1
	clr.l	d0
.ml2	lea 	charset+(160*32)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml2
	clr.l	d0
.ml3	lea 	charset+(160*64)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml3
	clr.l	d0
.ml4	lea 	charset+(160*96)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml4
	clr.l	d0
.ml5	lea 	charset+(160*128)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#6,d0
	bne.s	.ml5

make3 
	clr.l	d0
.ml1	lea 	charset+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml1
	clr.l	d0
.ml2	lea 	charset+(160*32)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml2
	clr.l	d0
.ml3	lea 	charset+(160*64)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml3
	clr.l	d0
.ml4	lea 	charset+(160*96)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml4
	clr.l	d0
.ml5	lea 	charset+(160*128)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#6,d0
	bne.s	.ml5

make4 
	clr.l	d0
.ml1	lea 	charset+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml1
	clr.l	d0
.ml2	lea 	charset+(160*32)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml2
	clr.l	d0
.ml3	lea 	charset+(160*64)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml3
	clr.l	d0
.ml4	lea 	charset+(160*96)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#10,d0
	bne.s	.ml4
	clr.l	d0
.ml5	lea 	charset+(160*128)+34,a2
 	move.l	d0,-(a7)
	mulu	#16,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#6,d0
	bne.s	.ml5
	bra	code_start

make_char
	moveq.w	#31,d1
.mc1	moveq.w 	#7,d2
.mc2	clr.l	d4
	move.w	(a2)+,d4
	swap	d4
	move.w	d4,8(a3)
	swap	d4
	or.w	d4,(a3)+
	dbf	d2,.mc2
	add.l	#144,a2
	addq.l	#8,a3
	dbf	d1,.mc1
	rts

make_char2
	moveq.w	#31,d1
.mc1	moveq.w 	#7,d2
.mc2	clr.l	d4
	move.w	(a2)+,d4
	swap	d4
	lsr.l	#4,d4
	move.w	d4,8(a3)
	swap	d4
	or.w	d4,(a3)+
	dbf	d2,.mc2
	add.l	#144,a2
	addq.l	#8,a3
	dbf	d1,.mc1
	rts

make_char3
	moveq.w	#31,d1
.mc1	moveq.w 	#7,d2
.mc2	clr.l	d4
	move.w	(a2)+,d4
	swap	d4
	lsr.l	#8,d4
	move.w	d4,8(a3)
	swap	d4
	or.w	d4,(a3)+
	dbf	d2,.mc2
	add.l	#144,a2
	addq.l	#8,a3
	dbf	d1,.mc1
	rts

make_char4
	moveq.w	#31,d1
.mc1	moveq.w 	#7,d2
.mc2	clr.l	d4
	move.w	(a2)+,d4
	swap	d4
	lsr.l	#8,d4
	lsr.l	#4,d4
	move.w	d4,8(a3)
	swap	d4
	or.w	d4,(a3)+
	dbf	d2,.mc2
	add.l	#144,a2
	addq.l	#8,a3
	dbf	d1,.mc1
	rts

display1
	rept	32
	movem.l	(a0),d0-d5
	movem.l	d2-d5,8(a1)
	or.l	d0,(a1)+
	or.l	d1,(a1)+
	add.l	#24,a0
	add.l	#152,a1	
	endr
	rts
display1_start
	rept	32
	movem.l	(a0),d0-d5
	movem.l	d0-d5,(a1)
	add.l	#24,a0
	add.l	#160,a1	
	endr
	rts
display1_end
	rept	32
	movem.l	(a0),d0-d5
	movem.l	d2-d3,8(a1)
	or.l	d0,(a1)+
	or.l	d1,(a1)+
	add.l	#24,a0
	add.l	#152,a1	
	endr
	rts
display2_start
	rept	32
	movem.l	(a0),d0-d5
	movem.l	d2-d5,8(a1)
	add.l	#24,a0
	add.l	#160,a1	
	endr
	rts
display2_end
	rept	32
	movem.l	(a0),d0-d5
	or.l	d0,(a1)+
	or.l	d1,(a1)+
	add.l	#24,a0
	add.l	#152,a1	
	endr
	rts
display3_start
	rept	32
	movem.l	(a0),d0-d5
	movem.l	d4-d5,16(a1)
	add.l	#24,a0
	add.l	#160,a1	
	endr
	rts
display3_end
	rept	32
	movem.l	(a0),d0-d5
	movem.l	d2-d3,8(a1)
	or.l	d0,(a1)+
	or.l	d1,(a1)+
	add.l	#24,a0
	add.l	#152,a1	
	endr
	rts

code_start
	move.l	#text,text_pos
	move.w	#0,scr_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	bsr	bounce_sub
scr_loop
	cmp.w	#0,scr_pos
	bne.s	.1
	bsr	scroll1
	bsr	wait_vbl
	bra	scr_end
.1	cmp.w	#1,scr_pos
	bne	.2
	bsr	scroll2
	bsr	wait_vbl
	bra.s	scr_end
.2	cmp.w	#2,scr_pos
	bne.s	.3
	bsr	scroll3
	bsr	wait_vbl
	bra.s	scr_end
.3	cmp.w	#3,scr_pos
	bne.s	.4
	bsr	scroll4
	bsr	wait_vbl
	bra.s	scr_end
.4	cmp.w	#4,scr_pos
	bne.s	.5
	bsr	scroll5
	bsr	wait_vbl
	bra.s	scr_end
.5	cmp.w	#5,scr_pos
	bne.s	.6
	bsr	scroll6
	bsr	wait_vbl
	bra.s	scr_end
.6	cmp.w	#6,scr_pos
	bne.s	.7
	bsr	scroll7
	bsr	wait_vbl
	bra.s	scr_end
.7	cmp.w	#7,scr_pos
	bne.s	scr_end
	bsr	scroll8
	bsr	wait_vbl
scr_end
	bra	keys
end_end
	cmp.w	#0,bounce_on
	beq.s	.text
	bsr	bounce_sub
.text	move.l	text_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	.0
	move.l	#text,text_pos		
.0	cmp.b	#$fe,(a0)
	bne.s	.1
	cmp.w	#5,scroll_speed
	bne.s	.1
	move.l	#text,text_pos
	move.w	#1,scroll_speed
	move.w	#1,old_speed
	move.w	#0,bounce_on
	move.w	#2,bounce_speed
.1	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	cmp.w	#1,scroll_speed
	bne.s	.5
	cmp.w	#7,scr_pos
	blt.s 	.next
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	bra	.7
.5	cmp.w	#2,scroll_speed
	bne.s	.6
	cmp.w	#6,scr_pos
	blt.s 	.next
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr.s	sort_char
	bra.s	.7
.6	cmp.w	#3,scroll_speed
	bne.s	.next
	cmp.w	#5,scr_pos
	blt.s 	.next
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr.s	sort_char
	bra.s	.7
.next	cmp.w	#5,scroll_speed
	bne.s	.7
	cmp.w	#2,scr_pos
	bgt.s 	.7
	sub.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr.s	sort_char
.7	move.w	scroll_speed,d0
	add.w	d0,scr_pos
.8	and.w	#7,scr_pos
	bra	scr_loop
	
sort_char
	cmp.w 	#32,d1
	bne 	.1
     	moveq.w 	#26,d1
     	bra 	.9
.1   	cmp.w 	#46,d1
     	bne 	.a
     	moveq.w 	#27,d1
     	bra 	.9
.a	cmp.w	#33,d1
	bne	.b
	moveq.w	#38,d1
	bra	.9	
.b	cmp.w	#91,d1
	bne	.c
	moveq.w	#39,d1
	bra	.9	
.c	cmp.w	#93,d1
	bne	.d
	moveq.w	#40,d1
	bra	.9	
.d	cmp.w	#44,d1
	bne	.e
	moveq.w	#41,d1
	bra	.9	
.e	cmp.w	#39,d1
	bne	.f
	moveq.w	#42,d1
	bra	.9	
.f	cmp.w	#63,d1
	bne	.g
	moveq.w	#43,d1
	bra	.9	
.g	cmp.w	#42,d1
	bne	.h
	moveq.w	#44,d1
	bra	.9	
.h	cmp.w	#45,d1
	bne	.2
	moveq.w	#45,d1
	bra	.9	
.2   	cmp.w 	#48,d1
     	blt 	.3
     	cmp.w 	#57,d1
     	bgt 	.3
     	add.w 	#45,d1
	bra	.5
.3   	cmp.w	#$ff,d1
	bne	.4
	moveq.w	#26,d1
	bra	.9
.4	cmp.w	#$fe,d1
	bne	.5
	moveq.w	#26,d1
	bra	.9
.5   	sub.w 	#65,d1
.9	move.w	d1,curr_char
	rts

bounce	dc.w	167,165,163,161,159,158,157,156,155
	dc.w	154,153,152,151,150,150,149,149,148
	dc.w	148,147,147,147,148,148,149,149,150
	dc.w	150,151,152,153,154,155,156,157,158
	dc.w	159,161,163,165,167
	even
	
bounce_sub
	cmp.w	#0,bounce_speed
	beq.s	no_bounce
	clr.l	d1
	move.w	bounce_ctr,d6		
	move.w	bounce(pc,d6.w),d1	
	add.w	#55,d1
	mulu	#160,d1
	add.l	#$76000,d1
	move.l	d1,bounce_offset
	move.w	bounce_speed,d6		
	add.w	d6,bounce_ctr		
	cmp.w	#80,bounce_ctr		
	ble.s	end_bounce		
	move.w 	#0,bounce_ctr		
	bra.s	end_bounce
no_bounce
	move.l	#202,d1
	mulu	#160,d1
	add.l	#$76000,d1
	move.l	d1,bounce_offset	
end_bounce
	rts	

wait_vbl
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	rts

scroll1
	lea	$40000,a0
	move.w	curr_char,d0
	mulu	#$300,d0
	add.l	d0,a0
	lea	$0.w,a1
	add.l	bounce_offset,a1
	sub.l	#320,a1
	move.w	#19,d0
.clr	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	dbf	d0,.clr
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display1_start
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	moveq.w	#7,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display1_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos	
	rts
scroll2
	lea	$40000,a0
	add.w	#138,curr_char
	move.w	curr_char,d0
	mulu	#$300,d0
	add.l	d0,a0
	move.l	bounce_offset,a1
	sub.l	#320,a1
	moveq.w	#19,d0
.clr	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	dbf	d0,.clr
	subq.l	#8,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display2_start
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#138,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	moveq.w	#8,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#138,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display2_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos	
	rts
scroll3
	lea	$40000,a0
	add.w	#92,curr_char
	move.w	curr_char,d0
	mulu	#$300,d0
	add.l	d0,a0
	move.l	bounce_offset,a1
	sub.l	#320,a1
	moveq.w	#19,d0
.clr	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	dbf	d0,.clr
	subq.l	#8,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display2_start
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#92,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	moveq.w	#8,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#92,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display2_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos
	rts
scroll4
	lea	$40000,a0
	add.w	#46,curr_char
	move.w	curr_char,d0
	mulu	#$300,d0
	add.l	d0,a0
	move.l	bounce_offset,a1
	sub.l	#320,a1
	moveq.w	#19,d0
.clr	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	dbf	d0,.clr
	subq.l	#8,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display2_start
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#46,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	moveq.w	#8,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#46,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display2_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos
	rts
scroll5
	lea	$40000,a0
	move.w	curr_char,d0
	mulu	#$300,d0
	add.l	d0,a0
	move.l	bounce_offset,a1
	sub.l	#320,a1
	moveq.w	#19,d0
.clr	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	dbf	d0,.clr
	sub.l	#8,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display2_start
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	moveq.w	#8,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display2_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos	
	rts
scroll6
	lea	$40000,a0
	add.w	#138,curr_char
	move.w	curr_char,d0
	mulu	#$300,d0
	add.l	d0,a0
	move.l	bounce_offset,a1
	sub.l	#320,a1
	moveq.w	#19,d0
.clr	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	dbf	d0,.clr
	sub.l	#16,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display3_start
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#138,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	moveq.w	#8,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#138,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display3_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos
	rts
scroll7
	lea	$40000,a0
	add.w	#92,curr_char
	move.w	curr_char,d0
	mulu	#$300,d0
	add.l	d0,a0
	move.l	bounce_offset,a1
	sub.l	#320,a1
	moveq.w	#19,d0
.clr	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	dbf	d0,.clr
	sub.l	#16,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display3_start
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#92,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	moveq.w	#8,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#92,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display3_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos
	rts
scroll8
	lea	$40000,a0
	add.w	#46,curr_char
	move.w	curr_char,d0
	mulu	#$300,d0
	add.l	d0,a0
	move.l	bounce_offset,a1
	sub.l	#320,a1
	moveq.w	#19,d0
.clr	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	 clr.l	(a1)+
	dbf	d0,.clr
	sub.l	#16,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display3_start
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#46,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	moveq.w	#8,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#16,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr 	sort_char
	add.w	#46,d1
	lea	$40000,a0
	mulu	#$300,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display3_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos
	rts

keys
.getkey	move.l #$600ff,-(sp)		;check keyboard
	trap #1				;
	addq.l #4,a7			;
	tst.w d0			;anything happening ?
	beq endkey
	bra .39			;no - go back to loop
	cmp.b #$39,d0			;yes - is it a 1
	bne.s .34				;no - check 2
	move.w #2,bounce_speed		;yes - set bounce
	move.w #1,scroll_speed		;    - set speed
	move.w #1,old_speed		;    - set backup speed
	bra endkey			;    - go main loop
.34
	cmp.b #$38,d0			;is it a 2
	bne.s .35				;no - check 3
	move.w #4,bounce_speed		;yes - set bounce
	move.w #2,scroll_speed		;    - as above
	move.w #2,old_speed		;
	bra endkey			;
.35
	cmp.b #$37,d0			;is it a 3
	bne.s .36				;
	move.w #4,bounce_speed		;
	move.w #3,scroll_speed		;
	move.w #3,old_speed		;
	bra endkey			;
.36
	cmp.b #$36,d0			;is it a 4
	bne.s .37				;
	move.w #4,bounce_speed		;
	move.w #5,scroll_speed		;
	move.w #5,old_speed		;
	bra endkey			;
.37
	bra.s .38
.onoff	cmp.w #0,bounce_on
	beq.s .on
	move.w #0,bounce_on		
	bra endkey
.on	move.w #1,bounce_on		
	bra endkey			
.38
	cmp.b #$41,d0			;
	bcs.s .39		;
	cmp.b #$4a,d0			;
	bcc.s .39
	sub.b #$41,d0
	bra.s .dom
.39
	cmp.b #$61,d0			;
	bcs.s .40			;
	cmp.b #$6a,d0			;
	bcc.s .40
	sub.b #$61,d0
.dom	clr.l d1
	move.b d0,d1
	bra endkey
.40
	bra exit
endkey	bra	end_end			;no - shit, more to do

vbl1	movem.l d0-d7/a0-a6,-(sp)
	bsr music1+$176
ex1	movem.l (a7)+,d0-d7/a0-a6
	rts

norpal	dc.w	$777,$070,$700,$000,$007,$707,$000,$555,$333,$733
	dc.w	$373,$773,$337,$737,$377,$000


exit	cmp.b #$30,d0
	bne.s n0
	eor.b #2,hzfl
	eor.w #$777,$ffff8240.w
	bra.s endkey
n0	cmp.b #$31,d0
	bcs.s endkey
	cmp.b #$36,d0
	bcc.s endkey
	move.l d0,-(sp)
	clr.l $4d2.w
	bra.s exitq
hzfl	dc.w $200
clrsnd	clr.l $4de.w	
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	rts


exitq	bsr	disable.lowborder	;kill lowborder
	dc.w	$a009
	move.w #$2700,sr
	clr.l $4de.w	
	bsr.s	clrsnd
	move.b xa0f,$fffffa0f.w
	move.b xa07,$fffffa07.w
	move.b xa21,$fffffa21.w
	move.b xa1b,$fffffa1b.w
	MOVE.B xa13,$fffffa13.w
	move.w #$2300,sr

	move.l	x45e,$45e.w			;reset screen ptr
	move.l x44e,$44e.w	
	move.w	cur_rez,-(sp)		;reset rez
	move.l	scrn,-(sp)		;restore normal screen
	move.l	(a7),-(sp)		;
	move.w	#5,-(sp)		;
	trap	#14			;
	lea $c(a7),sp			;
	sub.l #8,scrn
	move.b hzfl,$ffff820a.w
	move.l (a7)+,d0
	move.l d0,savkey
	movem.l	norpal(pc),d0-d7	;restore colour palette
	movem.l	d0-d7,$ffff8240.w
	
	move.l ssp,-(sp)
	move.w #32,-(sp)
	trap #1
	addq.l #6,sp
	move.l scrn,a7
	move.l savkey,d0	
	cmp.b #$31,d0
	bne.s TRY2
	move.l #gam1,a0
	bra.s found
TRY2	CMP.B	#$32,D0
	BNE.S	TRY3
	move.l 	#gam2,a0
	BRa.s	desk
TRY3	cmp.b	#$33,d0
	bne.s	try4
	move.l	#gam3,a0
	bra.s	desk
try4	cmp.b	#$34,d0
	bne	endkey
	bra.s	desk
found	clr.l $60000
	pea $60000
	move.l (a7),-(sp)
	move.l a0,-(sp)
	move.l #$4b0000,-(sp)
	trap #1
	lea $10(a7),a7
open	move.w	#2,-(sp)

	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle
	
	
close	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	clr.l	-(a7)
	trap	#1
	
desk	move.l	#screen,-(a7)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7

	clr.l	-(a7)
	trap	#1

screen	lea	picture_a+2,a0
	movem.l	(a0),d0-d7		;put picture colours in regs.
	movem.l	d0-d7,$ffff8240.w
pictureA_to_screen
	move.l	$462.w,d0			;wait on vblank
.wait2	cmp.l	$462.w,d0			;
	beq.s	.wait2			;

	move.w	#$1f3f,d0
	lea	picture_a+34,a0
	move.l	$44e,a1

.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop	

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l	norpal(pc),d0-d7	;restore colour palette
	movem.l	d0-d7,$ffff8240.w
	move.w	#32000,d0
	move.l	#0,a0
	move.l	$44e,a1
.loop2	move.l	(a0)+,(a1)+
	dbf	d0,.loop2	

	rts



handle	dc.w	0


savkey	dc.l 0
	even
x44e	dc.l 0
x45e	dc.l 0
xa1b	dc.b 0
xa07	dc.b 0
xa13	dc.b 0
xa0f	dc.b 0
xa21	dc.b 0,0

ssp		dc.l 0
scrn		dc.l 0



enable.lowborder
	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.l	#$fffa00,a0		Preserve and set IMR and IER
	movep.w	7(a0),d0
	move.w	d0,lb.old.ier
	movep.w	$13(a0),d0
	move.w	d0,lb.old.imr
	move.w	#$140,d0
	movep.w	d0,7(a0)
	movep.w	d0,$13(a0)
	move.l	#service.one,hbl.vec	Set up hbl vector
	move.l	vbl.vec,lb.old.vbl	Preserve old vbl vector
	move.l	#vsync.serv,vbl.vec
	move.l	$44e.w,lb.old.vbase	Preserve old base
	move.b	$ffff8260.w,lb.old.vmode	Preserve old mode
	rte				Restores sr as well!
disable.lowborder
	move.l	#$fffa00,a0
	move.w	lb.old.ier,d0
	movep.w	d0,7(a0)
	move.w	lb.old.imr,d0
	movep.w	d0,$13(a0)
	move.l	lb.old.vbase,$45e.w
	move.b	lb.old.vmode,$ffff8260.w
	move.l	lb.old.vbl,vbl.vec
	rts
vsync.serv
	movem.l	a0/a1/d2-d3,-(sp)
	move.w	#$2200,sr
	clr.b	tmrb.ctl
	move.l	#service.one,hbl.vec
	move.b	#198,tmrb.dat
	move.b	#8,tmrb.ctl
	lea	old_colour(pc),a0
	move.w	#$8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	movem.l	(sp)+,a0/a1/d2-d3
	move.l	lb.old.vbl,-(sp)
	rts
service.one
	clr.b	tmrb.ctl
	bclr.b	#0,$fffffa0f.w
	move.w	#$2200,sr
	move.l	#service.two,hbl.vec
	move.b	#1,tmrb.dat
	move.b	#8,tmrb.ctl
	st	lb.semaphore
.loop	tst.b	lb.semaphore
	bne.s	.loop
	rte
	
service.two
	clr.b	tmrb.ctl
	move.l	d0,-(sp)
	moveq.w	#$26,d0
.lp1	dbf	d0,.lp1
	move.b	#0,$ffff820a.w
	moveq.w	#$1,d0
.loop	dbf	d0,.loop
	move.b	#2,$ffff820a.w
	move.l	#service.three,hbl.vec
	moveq.w	#31,d0
.do	dbf	d0,.do
	move.b	#1,tmrb.dat
	move.b	#8,tmrb.ctl
	move.w	#0,$ffff8240.w
	sf	lb.semaphore
	bclr.b	#0,$fffffa0f.w
	move.l	(sp)+,d0
	rte
	
service.three
	movem.l	d0/a0/a1,-(a7)
	clr.b	tmrb.ctl
	lea	charset+2,a0
	lea	$fFFf8240.W,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	sf	lb.semaphore
	bclr.b	#0,$fFFffa0f.W
	movem.l	(a7)+,d0/a0/a1
	rte
	even

text	dc.b	$fe
	DC.B	'       EAT MY SHORTS,  MAN!!!!         WELCOME TO QUARTET CD NUMBER 18. '
	DC.B	' WELL HERE I AM,  STRAX,   ONCE AGAIN AT THE CONTROLS OF THIS MENU.'
	DC.B	' LET ME WELCOME THE QUARTETS,  SHOULD THAT BE THE DECTETS?,  LATEST MEMBER '
	DC.B	'     BLOOD ANGEL     WHO HAPPENS TO BE A GREAT CODER.  HEY BLOOD ANGEL GET IN TOUCH WITH ME '
	DC.B	' TO GET SOME GREAT NEW SOURCE WRITTEN.   GREETINGS TO THE REST OF THE QUARTET WHO ARE    NIK   '
	DC.B	' MAN X    TROLL    EDITMAN    QUASAR    HUDS    ANDROID    AND PART TIME MEMBER PURSY. '
	DC.B	' OH NO I HAVE NOT GOT ANYTHING ELSE TO WRITE ON THIS SCROLLTEXT WHAT AM I GOING TO DO.....'
	DC.B	'.UM.........OH.........EM........ WELL AS 1990 DRAWS TO A CLOSE.   OK SO IT IS ONLY DEC 6TH! '
	DC.B	' MAY I BE THE FIRST TO SAY WHAT A YEAR THAT WAS    NO MORE MAGGIE!!!   NO MORE BSB!!!!  TOUGH SHIT SQUARIAL OWNERS! '
	DC.B	' THERE WERE A COUPLE OF BAD THINGS ABOUT 1990 THOUGH LIKE    GAZZA.....WHINGEING GET    THE RISE OF RAP  OR SHOULD THAT BE CRAP MUSIC!! '
	DC.B	' I MEAN WHO ARE THESE PEOPLE,  ERIK B   VANILLA ICE ETC  MAKES ME WANT TO PUKE.  BRING BACK PEOPLE WHO ACTUALLY PLAY ON THEIR OWN ALBUMS  JUST LIKE MILLI VANILLI!!! '
	DC.B	' I SUPPOSE I MUST BE GETTING OLD, NO WONDER RECORDS FROM TWENTY YEARS AGO MAKE NUMBER ONE WHEN THERE IS SO MUCH SHIT IN THE CHARTS NOWADAYS. '
	DC.B	' I BETTER WATCH MY BLOOD PRESSURE SO I BETTER STOP RANTING ON AND HOPEFULLY YOU WILL JOIN ME ONCE AGAIN PROBABLY AROUND CD 19 OR 20 OR EVEN 21. '
	DC.B	' BEFORE I GO I MUST GIVE OUT SOME GREETINGS...... HI TO AUTOMATION,    POMPEY PIRATES,    MEDWAY BOYS,   G-FORCE,    JUMPING JACK FLASH,    THE FOXX FROM EIRE AND ANY OTHER OF MY CONTACTS.....'

	DC.B	'       SAOR ALBA......INDEPENDENCE      STRAX.                   '
   
	dc.b	$ff
spacer	dc.b	'                '
	even
	
disablemouse	dc.b	$12
enablemouse  	dc.b	$80,$01
lb.old.vbase	dc.l	0
lb.old.vbl	dc.l	0
lb.old.ier	dc.w	0
lb.old.imr	dc.w	0
lb.old.vmode	dc.b	0
lb.semaphore	dc.b	0
	even
old_colour	ds.l	8
scrbase		dc.l	$76000
oldbase		dc.l	$6A000
curr_char	dc.w	0
sav_cols	ds.w	16
scroll_speed	dc.w	1
old_speed	dc.w	1
bounce_speed	dc.w	0
bounce_ctr	dc.w	0
bounce_offset	dc.l	0
bounce_on	dc.w	0
scr_pos		dc.w	0
mus_add		dc.l	0
text_pos	dc.l	0
screen_pos_x	dc.w	0
screen_pos_y	dc.w	0
cur_rez		dc.w	0
sav_484		dc.w	0
gam2		dc.b 	"no game",0  put your games in here 
gam1		dc.b 	"a:\vaxine.stx",0
gam3		dc.b	'no game',0
gam4		dc.b	'no game',0
	even
stack		ds.b	512
	even
music1		incbin  b:\menace.mus
picture		incbin  b:\menu18.pi1
charset		incbin	b:\redfont.pi1
picture_a	incbin	b:\menu11a.pi1
