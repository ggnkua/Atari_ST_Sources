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
;reserve memory
	move.l	4(a7),a5
	move.l	#$200,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	move.l	a5,cmdtail
	add.l	#$200,cmdtail
;
;Go into supervisor mode for rest of program.
;Call main.program
;
;
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq	#6,a7
	move.l d0,ssp
;
;main program start
;
;
;
main.program
	lea	stack+512(pc),a7
	move.b	#$12,$fffffc02.w
	
	move.w	#4,-(sp)		;store current rez
	trap	#14			;
	addq.w	#2,sp			;
	move.w	d0,cur_rez		;

	move.w	#2,-(sp)		;store current screen address
	trap	#14			;
	addq.w	#2,sp			;
	move.l	d0,cur_scradd		;
	
	clr.w	-(sp)			;set low rez
	pea	$76000			;
	pea	$76000			;
	move.w	#5,-(sp)		;
	trap	#14			;
	add.w	#12,sp			;
	
	movem.l	$ffff8240.w,d0-d7	;save colour registers
	movem.l	d0-d7,sav_cols
	
   	lea	picture+2,a0
	movem.l	(a0),d0-d7		;put picture colours in regs.
	movem.l	d0-d7,$ffff8240.w
	movem.l	d0-d7,old_colour
	
	lea	$34000,a0
	move.w	#$a000,d0
clear2	clr.l	(a0)+
	dbf	d0,clear2

pic_to_screen
	lea	picture+34,a0
	lea	$76000,a1
	lea	$6c000,a2
	move.w	#$1f3f,d0
.loop	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.loop

	move.l	$462.w,d0			;wait on vblank
.wait2	cmp.l	$462.w,d0			;
	beq.s	.wait2				;

	bsr	enable.lowborder	;init HBL & VBL routines
	
play_music
	lea	music1(pc),a0
	move.l	a0,mus_add
	move.l	#vbl1,$4de.w
	moveq	#4,d0			;TUNE NUMBER
	bsr	music1

	move.l	a0,a1			;blank low border
	move.l	scrbase(pc),a1
	add.l	#200*160,a1		;
	move	#47*40,d0		;
.loop1	clr.l	(a1)+			;
	dbf	d0,.loop1		;
	
make 
	clr.l	d0
	lea 	$34000,a3
.ml1	lea 	charset+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml1
	clr.l	d0
.ml2	lea 	charset+(160*16)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml2
	clr.l	d0
.ml3	lea 	charset+(160*32)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml3
	clr.l	d0
.ml4	lea 	charset+(160*48)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml4
	clr.l	d0
.ml5	lea	charset+(160*64)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml5
	clr.l	d0
.ml6	lea	charset+(160*80)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml6
	clr.l	d0
.ml7	lea	charset+(160*96)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml7
	clr.l	d0
.ml8	lea	charset+(160*112)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml8
	clr.l	d0
.ml9	lea	charset+(160*128)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml9


make2 
	clr.l	d0
.ml1	lea 	charset+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml1
	clr.l	d0
.ml2	lea 	charset+(160*16)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml2
	clr.l	d0
.ml3	lea 	charset+(160*32)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml3
	clr.l	d0
.ml4	lea 	charset+(160*48)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml4
	clr.l	d0
.ml5	lea	charset+(160*64)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml5
	clr.l	d0
.ml6	lea	charset+(160*80)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml6
	clr.l	d0
.ml7	lea	charset+(160*96)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml7
	clr.l	d0
.ml8	lea	charset+(160*112)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml8
	clr.l	d0
.ml9	lea	charset+(160*128)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char2
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml9

make3
	clr.l	d0
.ml1	lea 	charset+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml1
	clr.l	d0
.ml2	lea 	charset+(160*16)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml2
	clr.l	d0
.ml3	lea 	charset+(160*32)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml3
	clr.l	d0
.ml4	lea 	charset+(160*48)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml4
	clr.l	d0
.ml5	lea	charset+(160*64)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml5
	clr.l	d0
.ml6	lea	charset+(160*80)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml6
	clr.l	d0
.ml7	lea	charset+(160*96)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml7
	clr.l	d0
.ml8	lea	charset+(160*112)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml8
	clr.l	d0
.ml9	lea	charset+(160*128)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char3
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml9

make4 
	clr.l	d0
.ml1	lea 	charset+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml1
	clr.l	d0
.ml2	lea 	charset+(160*16)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml2
	clr.l	d0
.ml3	lea 	charset+(160*32)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml3
	clr.l	d0
.ml4	lea 	charset+(160*48)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml4
	clr.l	d0
.ml5	lea	charset+(160*64)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml5
	clr.l	d0
.ml6	lea	charset+(160*80)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml6
	clr.l	d0
.ml7	lea	charset+(160*96)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml7
	clr.l	d0
.ml8	lea	charset+(160*112)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml8
	clr.l	d0
.ml9	lea	charset+(160*128)+34,a2
 	move.l	d0,-(a7)
	mulu	#8,d0
	add.l	d0,a2
	move.l	(a7)+,d0
	bsr	make_char4
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.ml9

	bra	code_start

make_char
	moveq	#15,d1
.mc1	moveq 	#3,d2
.mc2	clr.l	d4
	move.w	(a2)+,d4
	swap	d4
	move.w	d4,8(a3)
	swap	d4
	or.w	d4,(a3)+
	dbf	d2,.mc2
	add.l	#152,a2
	addq.l	#8,a3
	dbf	d1,.mc1
	rts

make_char2
	moveq	#15,d1
.mc1	moveq 	#3,d2
.mc2	clr.l	d4
	move.w	(a2)+,d4
	swap	d4
	lsr.l	#4,d4
	move.w	d4,8(a3)
	swap	d4
	or.w	d4,(a3)+
	dbf	d2,.mc2
	add.l	#152,a2
	addq.l	#8,a3
	dbf	d1,.mc1
	rts

make_char3
	moveq	#15,d1
.mc1	moveq 	#3,d2
.mc2	clr.l	d4
	move.w	(a2)+,d4
	swap	d4
	lsr.l	#8,d4
	move.w	d4,8(a3)
	swap	d4
	or.w	d4,(a3)+
	dbf	d2,.mc2
	add.l	#152,a2
	addq.l	#8,a3
	dbf	d1,.mc1
	rts
;VU-Meter routine.Ripped by the

make_char4
	moveq	#15,d1
.mc1	moveq 	#3,d2
.mc2	clr.l	d4
	move.w	(a2)+,d4
	swap	d4
	lsr.l	#8,d4
	lsr.l	#4,d4
	move.w	d4,8(a3)
	swap	d4
	or.w	d4,(a3)+
	dbf	d2,.mc2
	add.l	#152,a2
	addq.l	#8,a3
	dbf	d1,.mc1
	rts

display1
	rept	16
	movem.l	(a0),d0-d3
	movem.l	d2-d3,8(a1)
	or.l	d0,(a1)+
	or.l	d1,(a1)+
	add.l	#16,a0
	add.l	#152,a1	
	endr
	rts
display1_start
	rept	16
	movem.l	(a0),d0-d3
	movem.l	d0-d3,(a1)
	add.l	#16,a0
	add.l	#160,a1	
	endr
	rts
display1_end
	rept	16
	movem.l	(a0),d0-d3
	or.l	d0,(a1)+
	or.l	d1,(a1)+
	add.l	#16,a0
	add.l	#152,a1	
	endr
	rts
display2_start
	rept	16
	movem.l	(a0),d0-d3
	movem.l	d2-d3,8(a1)
	add.l	#16,a0
	add.l	#160,a1	
	endr
	rts
display2_end
	rept	16
	movem.l	(a0),d0-d3
	or.l	d0,(a1)+
	or.l	d1,(a1)+
	add.l	#16,a0
	add.l	#152,a1	
	endr
	rts
display3_start
	rept	16
	movem.l	(a0),d0-d3
	movem.l	d2-d3,8(a1)
	add.l	#16,a0
	add.l	#160,a1	
	endr
	rts
display3_end
	rept	16
	movem.l	(a0),d0-d3
	movem.l	d2-d3,8(a1)
	or.l	d0,(a1)+
	or.l	d1,(a1)+
	add.l	#16,a0
	add.l	#152,a1	
	endr
	rts

code_start


	move.l	#text,text_pos
sortar
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	cmp.w 	#32,d1		;space
	bne.s 	.1
     	move 	#152,d1
     	bra 	.9
.1   	cmp.w 	#46,d1		;full stop
     	bne.s 	.a2
     	moveq 	#43,d1
     	bra 	.9
.a2	cmp.b	#'-',d1		;dash
	bne	.a
	moveq	#44,d1
	bra	.9
.a	cmp.w	#33,d1		;exclamation mark
	bne.s	.bz
	moveq	#38,d1
	bra	.9	
.bz	cmp.w	#91,d1		;left square bracket
	bne.s	.c
	moveq	#36,d1
	bra	.9	
.c	cmp.w	#93,d1		;right square bracket
	bne.s	.d
	moveq	#37,d1
	bra.s	.9	
.d	cmp.w	#44,d1		;comma
	bne.s	.e
	moveq	#42,d1
	bra.s	.9	
.e	cmp.w	#34,d1		;double quotes
	bne.s	.f
	moveq	#39,d1
	bra.s	.9	
.f	cmp.w	#63,d1		;question mark
	bne.s	.g
	moveq	#41,d1
	bra.s	.9	
.g	cmp.w	#42,d1		;asterisk
	bne.s	.k
	moveq	#40,d1
	bra.s	.9	
.k   	cmp.w 	#100,d1		;SPECIAL CHARS		
     	blt.s 	.m 
     	cmp.w 	#233,d1
     	bgt.s 	.m
     	sub.w 	#55,d1
	bra.s	.9
.m   	cmp.w 	#48,d1		;numbers 0-9
     	blt.s 	.3
     	cmp.w 	#57,d1
     	bgt.s 	.3
     	sub.w 	#22,d1
	bra.s	.9
.3   	cmp.w	#$ff,d1
	bne.s	.4
	bra.s	.oot
.4	cmp.w	#$fe,d1
	bne.s	.5
	bra.s	.9
.5   	sub.w 	#65,d1
.9	move.b	d1,(a0)
	addq.l	#1,text_pos
	bra	sortar
.oot	
	move.l	#text,text_pos
	clr.w	scr_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	bsr	bounce_sub

scr_loop
	cmp.w	#0,scr_pos
	bne.s	.1
	bsr	scroll1
	bsr	swap_scr
	move.l	$462.w,d0
.wait1	cmp.l	$462.w,d0
	beq.s	.wait1	
	bra	scr_end
.1	cmp.w	#1,scr_pos
	bne.s	.2
	bsr	scroll2
	bsr	swap_scr
	move.l	$462.w,d0
.wait2	cmp.l	$462.w,d0
	beq.s	.wait2	
	bra	scr_end
.2	cmp.w	#2,scr_pos
	bne.s	.3
	bsr	scroll3
	bsr	swap_scr
	move.l	$462.w,d0
.wait3	cmp.l	$462.w,d0
	beq.s	.wait3	
	bra	scr_end
.3	cmp.w	#3,scr_pos
	bne.s	scr_end
	bsr	scroll4
	bsr	swap_scr
	move.l	$462.w,d0
.wait4	cmp.l	$462.w,d0
	beq.s	.wait4	
scr_end
	bra	keys
end_end
	move.l	text_pos,a0
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
.1	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	cmp.w	#1,scroll_speed
	bne.s	.5
	cmp.w	#3,scr_pos
	blt.s 	.next
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	bra	.7
.5	cmp.w	#2,scroll_speed
	bne.s	.6
	cmp.w	#2,scr_pos
	blt.s 	.next
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	bra.s	.7
.6	cmp.w	#3,scroll_speed
	bne.s	.next
	cmp.w	#1,scr_pos
	blt.s 	.next
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	bra.s	.7
.next	cmp.w	#5,scroll_speed
	bne.s	.7
	cmp.w	#2,scr_pos
	bgt.s 	.7
	sub.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
.7	move.w	scroll_speed,d0
	add.w	d0,scr_pos
.8	and.w	#3,scr_pos
	bra	scr_loop
	

sort_char
   	cmp.w	#$ff,d1
	bne	.4
	move	#152,d1
	bra	.9
.4	cmp.w	#$fe,d1
	bne	.9
	move	#152,d1
.9	move.w	d1,curr_char
	rts

bounce_sub
	move.l	#207,d1
	mulu	#160,d1
	add.l	oldbase,d1
	move.l	d1,bounce_offset	
	rts	

scroll1
	lea	$34000,a0
	move.w	curr_char,d0
	mulu	#$100,d0
	add.l	d0,a0
	move.l	oldbase,a1
	add.l	#160*207,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display1_start
	movem.l	(a7)+,a1/d0
	add.l	#8,a1
	addq.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	lea	$34000,a0
	mulu	#$100,d1
	add.l	d1,a0
	moveq	#17,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#8,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	lea	$34000,a0
	mulu	#$100,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display1_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos	
	rts
scroll2
	lea	$34000,a0
	add.w	#540,curr_char
	move.w	curr_char,d0
	mulu	#$100,d0
	add.l	d0,a0
	move.l	oldbase,a1
	add.l	#160*207,a1
	sub.l	#8,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display2_start
	movem.l	(a7)+,a1/d0
	add.l	#8,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#540,d1
	lea	$34000,a0
	mulu	#$100,d1
	add.l	d1,a0
	moveq	#18,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#8,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#540,d1
	lea	$34000,a0
	mulu	#$100,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display2_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos	
	rts
scroll3
	lea	$34000,a0
	add.w	#360,curr_char
	move.w	curr_char,d0
	mulu	#$100,d0
	add.l	d0,a0
	move.l	oldbase,a1
	add.l	#160*207,a1
	sub.l	#8,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display2_start
	movem.l	(a7)+,a1/d0
	add.l	#8,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#360,d1
	lea	$34000,a0
	mulu	#$100,d1
	add.l	d1,a0
	moveq	#18,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#8,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#360,d1
	lea	$34000,a0
	mulu	#$100,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display2_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos
	rts
scroll4
	lea	$34000,a0
	add.w	#180,curr_char
	move.w	curr_char,d0
	mulu	#$100,d0
	add.l	d0,a0
	move.l	oldbase,a1
	add.l	#160*207,a1
	sub.l	#8,a1
	move.l	text_pos,-(a7)
	movem.l	a1/d0,-(a7)
	bsr	display2_start
	movem.l	(a7)+,a1/d0
	add.l	#8,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#180,d1
	lea	$34000,a0
	mulu	#$100,d1
	add.l	d1,a0
	moveq	#18,d0
.char
	movem.l	a1/d0,-(a7)
	bsr	display1
	movem.l	(a7)+,a1/d0
	add.l	#8,a1
	add.l	#1,text_pos
	move.l	text_pos,a0
	clr.l	d1
	move.b	(a0),d1
	bsr	sort_char
	add.w	#180,d1
	lea	$34000,a0
	mulu	#$100,d1
	add.l	d1,a0
	dbf	d0,.char
	movem.l	a1/d0,-(a7)
	bsr	display2_end
	movem.l	(a7)+,a1/d0
	move.l	(a7)+,text_pos
	rts

keys
.getkey	move.l #$600ff,-(sp)			;
	trap #1				;
	addq #4,a7			;
	tst.w d0			;anything happening ?
	beq .endkey			;no - go back to loop
	cmp.b #$39,d0			;yes - is it a 9
	bne.s .34			;no - check 8
	move.w #1,scroll_speed		;    - set speed
	bra .endkey			;    - go main loop
.34
	cmp.b #$38,d0			;is it a 8
	bne.s .35			;no - check 7
	move.w #2,scroll_speed		;    - as above
	bra .endkey			;
.35
	cmp.b #$37,d0			;is it a 7
	bne.s .36			;
	move.w #3,scroll_speed		;
	bra .endkey			;
.36
	cmp.b #$36,d0			;is it a 6
	bne.s .38			;
	move.w #5,scroll_speed		;
	bra .endkey			;
.38
	cmp.b	#$30,d0
	bne.s	.39
	cmp.w	#$001,old_colour
	beq	.grey
	move.w	#$001,old_colour
	bra	.endkey
.grey	move.w	#$000,old_colour	
	bra	.endkey
.39
	cmp.b	#$31,d0
	beq.s .ld1
	cmp.b #$32,d0
	beq.s .ld2
	cmp.b #$33,d0
	beq.s .ld3
;	cmp.b	#$33,d0
	bne.s	.endkey
.ld2	lea gam2(pc),a0
	bra.s .ld
.ld3	lea gam3(pc),a0
	bra.s .ld
.ld4	lea gam4(pc),a0
	bra.s .ld
.ld1	lea gam1(pc),a0
.ld	move.l a0,.fadd+2
	bsr	exit
	move.l ssp,-(sp)
	move.w #32,-(sp)
	trap #1
	move.l cur_scradd,a7
	subq.l #8,a7
	clr.l $60000
	pea $60000
	move.l (a7),-(sp)
.fadd	move.l #0,-(sp)
	move.l #$4b0000,-(sp)
	trap #1
	lea $10(a7),a7
	clr.l	-(a7)
	trap	#1
.endkey	bra	end_end			;no - shit, more to do
ssp	dc.l 0	


vbl1	movem.l d0-d7/a0-a6,-(sp)
	move.l	mus_add,a0
	add.l	#8,a0
	jsr	(a0)
ex1	movem.l (a7)+,d0-d7/a0-a6
	rts


clrsnd	move.w #$2700,sr
	clr.l $4de.w
	move.l #$8080000,$ff8800
	move.l #$9090000,$ff8800
	move.l #$a0a0000,$ff8800
	move.w #$2300,sr
	rts

exit	bsr	disable.lowborder	;kill lowborder
	move.b	#$8,$fffffc02.w
	
	bsr.s	clrsnd

	cmp.w	#$001,old_colour
	bne	.next
	move.b	#0,$ff820a
	
.next	movem.l	sav_cols(pc),d0-d7	;restore colour palette
	movem.l	d0-d7,$ffff8240.w
	
	move.w	cur_rez,-(sp)		;reset rez
	move.l	cur_scradd,-(sp)		;restore normal screen
	move.l	cur_scradd,-(sp)		;
	move.w	#5,-(sp)		;
	trap	#14			;
	add.w	#12,sp			;
	
	rts	

swap_scr
	move.l	scrbase,tempbase
	move.l	oldbase,scrbase
	move.l	tempbase,oldbase
	move.l	scrbase,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	rts

	


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
	move.b	$ffff8260.w,lb.old.vmode	Preserve old mode
	rte				Restores sr as well!
disable.lowborder
	move.l	#$fffa00,a0
	move.w	lb.old.ier,d0
	movep.w	d0,7(a0)
	move.w	lb.old.imr,d0
	movep.w	d0,$13(a0)
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
	moveq.w	#$26,d0			****
.lp1	dbf	d0,.lp1
	move.b	#0,$ffff820a.w
	moveq.w	#$1,d0			****
.loop	dbf	d0,.loop
	move.b	#2,$ffff820a.w
	move.l	#service.three,hbl.vec
	moveq.w	#31,d0			****
.do	dbf	d0,.do
	move.b	#1,tmrb.dat
	move.b	#8,tmrb.ctl
	move.w	#0,$ffff8240.w		****
	sf	lb.semaphore
	bclr.b	#0,$fffffa0f.w
	move.l	(sp)+,d0
	rte
	
service.three
	movem.l	d0/a0/a1,-(a7)
	clr.b	tmrb.ctl
	lea	charset+2,a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	sf	lb.semaphore
	bclr.b	#0,$fffffa0f.w
	movem.l	(a7)+,d0/a0/a1
	rte
	even

text		dc.b	$fe		
		dc.b '                                        D.R.S.                     '

		DC.B 32,115,116,117,118,119,120,121,122,123,124,32
		dc.b	"                           D.R.S.                      "

		DC.B	" WELCOME TO ANOTHER"
		DC.B 32,115,116,117,118,119,120,121,122,123,124,32
		dc.b	"COMPACT DISK DONE BY THE D.R.S.                   THIS TIME ITS NUMBER 385 [LOOK WE HAVE NUMBERS IN THE FONT MAP FOR A CHANGE].                    "
		DC.B	"THIS IS MY SECOND SCROLLTEXT IN LESS THAN THIRTY MINUTES,   SO I AM NOT DOING ANYTHING ELSE BUT THE GREETS.                    "
		dc.b	"GREETZ TO"
		dc.b	" ALL OTHER "
		DC.B 32,115,116,117,118,119,120,121,122,123,124,32
		dc.b	" MEMBERS AND THERE CONTACTS.          DEREK M.D AND BECKY          THE MEDWAY BOYS          THE POMPEY PIRATES          THE EMPIRE          THE REPLICANTS          "
		dc.b	"THE ST AMIGOS          THE B.B.C          FLAME OF FINLAND          AND ANYBODY ELSE THAT WE HAVE FORGOTTEN.          "
		dc.b	"            THIS IS THE D.R.S. SIGNING OFF............................................................................................"
		DC.B	"LETS WRAP BROTHER.                         "
		DC.B	""
 
	dc.b	$ff
spacer	dc.b	152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152
	even

*[] = unflasing ()    l = smiley  * = :

*VAPOUR
	DC.B 32,109,110,111,112,113,114,32
*AUTOMATION
	DC.B 32,115,116,117,118,119,120,121,122,123,124,32
*SHARAZ JEK
	DC.B 32,125,126,127,128,129,130,131,132,133,134,32
*THE UN-NAMEABLES
	DC.B 32,135,136,137,138,139,140
	DC.B 141,142,143,144,145,146,147,148,149,150,32
*THE SUB HUMANS IN TURKEY
	DC.B 32,152,153,154,32,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,32
*OZZWALD
	DC.B 32,175,176,177,178,179,180,181,32
*GUARDIANS OF LOGIK
	DC.B 32,182,183,184,185,186,187,188,189,190,191,32
*PYROTECHNICS
	DC.B 32,195,196,197,198,199,200,201,202,203,204,205,206,32
*THE BBC
	DC.B 32,208,209,210,211,212,213,214,32
*NEIL OF COR BLIMEY
	DC.B 32,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,32
	EVEN
	
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
oldbase		dc.l	$6c000
tempbase	dc.l	0
save78		dc.l	0
save70		dc.l	0
savbuff		dc.l	0
data_pos	dc.l	0
sprite_rout	dc.l	0
counter		dc.w	0
curr_char	dc.w	0
sav_cols	ds.w	16
char_num	dc.w	0
scroll_speed	dc.w	1
old_speed	dc.w	0
bounce_speed	dc.w	0
bounce_ctr	dc.w	0
bounce_offset	dc.l	0
bounce_on	dc.w	0
scr_pos		dc.w	0
mus_add		dc.l	0
text_pos	dc.l	0
rotate		dc.w	0
screen_pos_x	dc.w	0
screen_pos_y	dc.w	0
cmdtail		dc.l	0
cur_scradd	dc.l	0
cur_rez		dc.w	0
sav_484		dc.w	0
	even
stack		ds.b	512
gam1		dc.b	'M1_TANK.drs',0
gam2		dc.b	'F_FIRE.drs',0
gam3		dc.b	'VAXINE.DRS',0
gam4		dc.b	'',0
	even
music1		incbin  \codes.tbe\muzak\jambala2.jh
picture		incbin  \codes.tbe\piccies.pi1\382.pi1
charset		incbin	\codes.tbe\fonts\logo2.pi1
