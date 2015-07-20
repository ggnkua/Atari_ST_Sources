; On entry to routine:	A0=points to filename
;			A1=address to load file to

;	org	$50000
	jmp	start_code
print	incbin	proprint.o

	even
mess1	dc.w	35,40,15
	dc.b	'             Zeppelin World Rugby',0
	dc.w	40,43,2
	dc.b	'            ------------------',0
	dc.w	49,19,1
	dc.b	'               Cracked By Skywalker',0
	dc.w	50,20,15
	dc.b	'               Cracked By Skywalker',0
	dc.w	65,0,15
	DC.B	'CYNIX',0
	dc.w	65,40,2
	DC.B	'present another hot new title!!! ',0
	dc.w	75,0,12
	DC.B	'Nice music from TAO.. Great conversion of Karsten',0
	dc.w	85,0,12
	DC.B	'   Obarski''s Sleepwalk...',0
	dc.w	100,0,15
	DC.B	'Greetings to . . .',0
	dc.w	110,0,2
	DC.B	'  Elite (Esp Sledge, Lethal & Magician), Replicants',0
	dc.w	120,0,2
	DC.B	'  Tristar/Red Sector (ST), The Nalpalm Soldiers,  ',0
	dc.w	130,0,2
	DC.B	'  Armada, Teddystacker, ACF (Esp Jacky & Pooky), ',0
	dc.w	140,0,2
	DC.B	'  Duckula, D-Bug, Ripped Off, and everyone else!',0
	dc.w	150,0,15
	DC.B	'  ',0
	dc.w	160,0,12
	DC.B	'Thanks to Quasar for supplying the Original..',0
	dc.w	186,0,14
	dc.b	'         Click here to continue -->',0
	even

mess2	

logos	incbin	graphics\cynix.log
pointer	incbin	graphics\pointer.log
;cross	incbin	graphics\cross.log
tick	incbin	graphics\tick.log
empty	incbin	graphics\blank.log
********************************************************
music	incbin	d:\musichak.mug\j_buggin\tao_digi.snd\sleep.mus
********************************************************
fade_in
	movem.l	d0-a6,-(a7)
	moveq	#7,d6
loop1
	lea	black,a0
	lea	logos+2,a1
	lea	temp_word,a3
	moveq	#15,d7
loop2
	clr.w	(a3)
	move.w	(a0),d0
	move.w	d0,d1
	move.w	d0,d2
	and.w	#$000F,d0
	and.w	#$00F0,d1
	and.w	#$0F00,d2
	move.w	(a1),d3
	move.w	d3,d4
	move.w	d3,d5
	and.w	#$000F,d3
	and.w	#$00F0,d4
	and.w	#$0F00,d5
	addq.w	#$001,d0
	cmp.w	d3,d0
	bgt.s	blue
	move.w	d0,(a3)
	bra.s	ba1
blue	move.w	d3,(a3)
ba1	add.w	#$010,d1
	cmp.w	d4,d1
	bgt.s	green
	or.w	d1,(a3)
	bra.s	ba2
green	or.w	d4,(a3)
ba2	add.w	#$100,d2
	cmp.w	d5,d2
	bgt.s	red
	or.w	d2,(a3)
	bra.s	ba3
red	or.w	d5,(a3)		
ba3	clr.w	(a0)
	move.w	(a3),(a0)
	addq.l	#2,a0
	addq.l	#2,a1
	dbf	d7,loop2

	move.l	$462.w,d0
wait1	cmp.l	$462.w,d0
	beq.s	wait1	
	move.l	$462.w,d0
wait2	cmp.l	$462.w,d0
	beq.s	wait2	
	move.l	$462.w,d0
wait3	cmp.l	$462.w,d0
	beq.s	wait3	
	move.l	$462.w,d0
wait4	cmp.l	$462.w,d0
	beq.s	wait4	

	lea	black,a0
	movem.l	(a0),d0-d3	
	movem.l	d0-d3,$ffff8240.w
	movem.l	16(a0),d0-d3	
	movem.l	d0-d3,$ffff8250.w

	dbf	d6,loop1

	movem.l	(a7)+,d0-a6
	rts	
********************************************************
fade_out
	movem.l	d0-a6,-(a7)
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,black
	lea	black,a0	
	moveq	#7,d6
loop1_o
	move.w	#15,d7
.loop	move.w	(a0),d0
	and.w	#$007,d0
	cmp.w	#0,d0
	beq.s	.g
	subq.w	#$001,d0
.g	move.w	(a0),d1
	and.w	#$070,d1
	cmp.w	#0,d1
	beq.s	.r
	sub.w	#$010,d1
.r	move.w	(a0),d2
	and.w	#$700,d2
	cmp.w	#0,d2
	beq.s	.bx
	sub.w	#$100,d2
.bx	move.w	d0,(a0)
	or.w	d1,(a0)
	or.w	d2,(a0)+
	dbf	d7,.loop		

	move.l	$462.w,d0
.wait1	cmp.l	$462.w,d0
	beq.s	.wait1	
	move.l	$462.w,d0
.wait2	cmp.l	$462.w,d0
	beq.s	.wait2	
	move.l	$462.w,d0
.wait3	cmp.l	$462.w,d0
	beq.s	.wait3	
	move.l	$462.w,d0
.wait4	cmp.l	$462.w,d0
	beq.s	.wait4	

	lea	black,a0
	movem.l	(a0),d0-d3	
	movem.l	d0-d3,$ffff8240.w
	movem.l	16(a0),d0-d3	
	movem.l	d0-d3,$ffff8250.w
	dbf	d6,loop1_o

	movem.l	(a7)+,d0-a6
	rts	

temp_word	dc.l	0
black		ds.l	8
rotate		dc.w	0
vbl_flag	dc.w	0

******************************************************
** d0=x pos, d1=y pos : x = 0 to 18 : y = 0 to 183  **
******************************************************
put_boxes
	movem.l	d0-a6,-(a7)
.loop	move.w	(a0)+,d0
	bmi.s	.exit
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.l	a0,-(a7)
	bsr.s	put_box
	move.l	(a7)+,a0
	bra.s	.loop
.exit	movem.l	(a7)+,d0-a6
	rts
put_box
	cmp.w	#0,d2
	beq.s	put_empty
	cmp.w	#1,d2
	beq.s	put_tick
	cmp.w	#2,d2
	beq.s	put_cross
put_tick
	lea	tick(pc),a0
	bsr.s	put_box_on
	rts	
put_cross
;	lea	cross(pc),a0
;	bsr.s	put_box_on
;	rts
put_empty
	lea	empty(pc),a0
	bsr.s	put_box_on
	rts	
put_box_on
	move.l	$44e.w,a1
	ext.l	d0
	ext.l	d1
	mulu	#160,d1
	lsl.l	#3,d0
	add.l	d0,a1
	add.l	d1,a1

	move.w	#18,d0
.loop	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	lea	160(a1),a1
	dbf	d0,.loop	
	rts
	
*********************************************************
mouse_vbl
	cmp.w	#1,vbl_flag
	beq.s	.exit
	movem.l	d0-a6,-(a7)
	move.w	m_x,d0
	move.w	m_y,d1
	cmp.w	#304,d0
	blt.s	.ok
	move.w	#304,d0
.ok	move.l	d0,-(a7)
	move.l	d1,-(a7)
	move.w	d0,m_x
	move.w	d1,m_y
	move.l	$44e.w,a1
	mulu	#160,d1
	add.l	d1,a1
	move.l	d0,d1
	and.l	#$fff0,d1
	lsr	#1,d1
	add.w	d1,a1
	move.l	a1,a6
	bsr.s	restore_back
	bsr	save_new_back
	moveq.l	#0,d0
	move.l	(a7)+,d1
	move.l	(a7)+,d2
	bsr	put_pointer
	movem.l	(a7)+,d0-a6
.exit	rts

mouse_vbl2
	movem.l	d0-a6,-(a7)
	move.w	m_x,d0
	move.w	m_y,d1
	cmp.w	#304,d0
	blt.s	.ok
	move.w	#304,d0
.ok	move.l	d0,-(a7)
	move.l	d1,-(a7)
	move.w	d0,m_x
	move.w	d1,m_y
	move.l	$44e.w,a1
	mulu	#160,d1
	add.l	d1,a1
	move.l	d0,d1
	and.l	#$fff0,d1
	lsr	#1,d1
	add.w	d1,a1
	move.l	a1,a6
	bsr.s	save_new_back
	moveq.l	#0,d0
	move.l	(a7)+,d1
	move.l	(a7)+,d2
	bsr	put_pointer
	movem.l	(a7)+,d0-a6
	rts
	
restore_back
	move.l	a0,-(a7)
	lea	store_back(pc),a0
	move.w	#15,d0
	move.l	(a0)+,a1
.loop	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	lea	160(a1),a1 
	dbf	d0,.loop
	move.l	(a7)+,a0
	rts
save_new_back
	move.l	a0,-(a7)
	lea	store_back(pc),a1
	move.l	a6,a0
	move.w	#15,d0
	move.l	a0,(a1)+
.loop	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	lea	160(a0),a0
	dbf	d0,.loop
	move.l	(a7)+,a0
	rts

restore_button
	pea	mouse_params
	move.w	#1,-(a7)
	move.w	#25,-(a7)
	trap	#14
	addq.l	#8,a7
	rts

mouse_params	dc.b	$80,01

check_box
	move.l	d3,-(a7)
.loop	move.w	(a0)+,d0
	bmi.s	.out
	lsl.w	#4,d0
	move.w	d0,d1
	add.w	#22,d1
	move.w	(a0)+,d2
	move.w	d2,d3
	add.w	#18,d3
	move.w	(a0)+,d4
	move.w	(a0)+,d4
	move.w	m_x,d6
	move.w	m_y,d7
	cmp.w	d0,d6
	blt.s	.loop
	cmp.w	d1,d6
	bgt.s	.loop	
	cmp.w	d2,d7
	blt.s	.loop
	cmp.w	d3,d7
	bgt.s	.loop
	move.l	(a7)+,d3
	rts	
.out	moveq.l	#-1,d4
	move.l	(a7)+,d3
	rts

mod_table_fade
	move.l	a0,a1
	ext.l	d4
	subq.w	#1,d4
	lsl.l	#3,d4
	add.l	d4,a1
	move.w	d3,4(a1)
	move.w	#1,vbl_flag
	bsr	restore_back
	bsr	put_boxes
	bsr	mouse_vbl2
	bsr	fade_out
	move.w	#0,vbl_flag
	move.l	$462.w,d0
.wait	cmp.l	$462.w,d0
	beq.s	.wait
	rts

mod_table
	move.l	a0,a1
	ext.l	d4
	subq.w	#1,d4
	lsl.l	#3,d4
	add.l	d4,a1
	move.w	d3,4(a1)
	move.w	#1,vbl_flag
	bsr	restore_back
	bsr	put_boxes
	bsr	mouse_vbl2
	move.w	#0,vbl_flag
	move.l	$462.w,d0
.wait	cmp.l	$462.w,d0
	beq.s	.wait
	rts

make_16 
	move.w	#$1f3f,d0
	move.l	buff_space,a0
.loop	clr.l	(a0)+
	dbf	d0,.loop
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	move.l	buff_space,a3
	clr.w	rotate
.ml1	lea	pointer,a2
	move.w	rotate,d5
	bsr.s	make_char_16
	moveq.l	#0,d0
	addq.w	#1,rotate
	cmp.w	#16,rotate
	bne.s	.ml1
	rts

make_char_16
	moveq	#15,d1
.mc1	moveq 	#3,d2
	moveq.l	#0,d6
	moveq.l	#0,d7
.mc2	moveq.l	#0,d4
	move.w	(a2)+,d4
	swap	d4
	lsr.l	d5,d4
	move.w	d4,8(a3)
	or.w	d4,d7
	swap	d4
	or.w	d4,(a3)+
	or.w	d4,d6
	dbf	d2,.mc2
	not.w	d6
	move.w	d6,d4
	swap	d6
	move.w	d4,d6
	not.w	d7
	move.w	d7,d4
	swap	d7
	move.w	d4,d7
	move.l	d6,8(a3)
	move.l	d7,12(a3)
	addq.l	#8,a2
	lea	16(a3),a3
	dbf	d1,.mc1
	rts


;	d0 sprite #
;	d1 y position
;	d2 x position
put_pointer
	move.l	buff_space,a0
	move.l	$44e.w,a1
	mulu	#160,d1
	add.l	d1,a1
	move.l	d2,d1
	and.l	#$fff0,d1
	lsr	#1,d1
	add.w	d1,a1
	and.l	#$f,d2
	mulu	#384,d2
	add.l	d2,a0
	move.w	#15,d7
.loop	movem.l	(a0),d0-d5
	and.l	d4,(a1)
	and.l	d4,4(a1)
	and.l	d5,8(a1)
	and.l	d5,12(a1)
	or.l	d0,(a1)
	or.l	d1,4(a1)
	or.l	d2,8(a1)
	or.l	d3,12(a1)
	add.l	#24,a0
	lea	160(a1),a1
	dbf	d7,.loop
	rts

vbl1	movem.l d0-d7/a0-a6,-(a7)
	JSR	music+8(pc)
	movem.l (a7)+,d0-d7/a0-a6
	rts

max_x	equ	319
max_y	equ	199

my118	move.w	#$2500,sr
	move.b	$fffffc02.w,key
	move.b	key,key2
	cmp.b	#$f8,key
	blt.s	.exit
	cmp.b	#$fb,key
	bgt.s	.exit
	and.b	#%11,key
	move.b	key(pc),buts
	clr.b	key
	move.l	#getx,$118.w
.exit	bclr	#6,$fffffa11.w
	rte
getx	move.w	#$2500,sr
	move.l	d0,-(a7)
	moveq	#0,d0
	move.b	$fffffc02.w,d0
	ext.w	d0
	add.w	d0,m_x
	move.w	m_x(pc),d0
	tst.w	d0
	bpl.s	.ok1
	clr.w	m_x
.ok1	cmp.w	#max_x,d0
	ble.s	.ok2
	move.w	#max_x,m_x
.ok2	move.l	(a7)+,d0
	move.l	#gety,$118.w
	bclr	#6,$fffffa11.w
	rte
gety	move.w	#$2500,sr
	move.l	d0,-(a7)
	moveq	#0,d0
	move.b	$fffffc02.w,d0
	ext.w	d0
	add.w	d0,m_y
	move.w	m_y(pc),d0
	tst.w	d0
	bpl.s	.ok1
	clr.w	m_y
.ok1	cmp.w	#max_y,d0
	blt.s	.ok2
	move.w	#max_y,m_y
.ok2	move.l	(a7)+,d0
	move.l	#my118,$118.w
	bclr	#6,$fffffa11.w
	rte

key		ds.b	1
key2		ds.b	1
buts		ds.b	1
m_x		dc.w	160
m_y		dc.w	100
buff_space	dc.l	0
store_back	ds.l	100
sav_4d6		dc.l	0
sav_4da		dc.l	0
sav_118		dc.l	0
sav_stk		dc.l	0
sav_sup		dc.l	0
sav_484		dc.w	0
sav_col		ds.l	8
stack		ds.l	100
stack_end

box_table_1	
;		dc.w	7,180,0,1 
		dc.w	15,180,0,1
		dc.w	-1,-1,-1,-1

box_table_2	
		dc.w	13,180,2,1
		dc.w	-1,-1,-1,-1
	even
****************************************************
start_code
;	move.l	a7,a5
;	move.l	a7,sav_stk
;	move.l	4(a5),a5
;	move.l	#$2000,d0
;	move.l	d0,-(a7)
;	move.l	a5,-(a7)
;	move.l	#$4a0000,-(a7)
;	trap	#1
;	add	#12,a7
;
;	dc.w	$a00a
;
;	clr.l	-(a7)
;	move.w	#32,-(a7)
;	trap	#1
;	addq.w	#6,a7
;	move.l	d0,sav_sup

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,sav_col

	move.l	a7,sav_stk

	lea	$50000,a7
;	move.l	#stack_end,a7

	move.l	$118.w,sav_118
	move.l	#my118,$118.w
	move.b	#2,$ffff820a.w

	move.l	$44e.w,a0
	sub.l	#$18000,a0
	move.l	a0,buff_space

	move.l	$44e.w,a0
	sub.l	#$10000,a0
	bsr	make_16

	clr.w	-(a7)
	move.l	a0,-(a7)
	move.l	a0,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7	

	clr.l	$ffff8240.w
	clr.l	$ffff8244.w
	clr.l	$ffff8248.w
	clr.l	$ffff824C.w
	clr.l	$ffff8250.w
	clr.l	$ffff8254.w
	clr.l	$ffff8258.w
	clr.l	$ffff825C.w
	move.w	$484.w,sav_484
	move.w	#0,$484.w
	move.l	$4d6.w,sav_4d6
	move.l	$4da.w,sav_4da

	clr.l	$30.w
	moveq.l	#1,d0
	bsr	music


mess_display
	clr.w	-(a7)
	pea	-1.w
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7

put_logo
	lea	logos+34(pc),a0
	move.l	$44e.w,a1
	move.w	#(34*40)-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop	

	move.w	#0,$32.w	
message1
	lea	mess1(pc),a0
	moveq.l	#15,d5
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
.loop	move.w	(a0)+,d1
	move.w	(a0)+,d0
	move.w	(a0)+,d2
	bsr	print
	move.l	a0,d0
	and.l	#$ffff,d0
	btst	#0,d0
	beq.s	.next
	addq.l	#1,a0
.next	dbf	d5,.loop
	
	lea	box_table_1,a0
	bsr	put_boxes
	
	move.l	$44e.w,a6
	add.l	#(92*160)+152,a6
	bsr	save_new_back
 

	bsr	fade_in
	move.l	#mouse_vbl,$4d6.w
	move.l	#vbl1,$4da.w

.read_key
	move.b	buts,d0
	cmp.b	#2,d0
	beq.s	.box
	move.b	key2,d0
	cmp.b	#$39,d0
	bne	.read_key
	bra	.nocheat
.box	lea	box_table_1,a0
	bsr	check_box
;	cmp.w	#1,d4 
;	beq.s	.help
	cmp.w	#1,d4
	beq.s	.nocheat
	bra.s	.read_key
.help
;	lea	box_table_1,a0
;	moveq.l	#1,d3
;	bsr	mod_table_fade
;	bra	nocheat
.trainer
;	lea	box_table_1,a0
;	moveq.l	#1,d3
;	bsr	mod_table_fade
;	bra.s	trainer
.nocheat
	lea	box_table_1,a0
	moveq.l	#1,d3
	bsr	mod_table_fade
	bra	nocheat

trainer	
;	bra	nocheat
;	clr.w	-(a7)
;	pea	-1.w
;	move.l	(a7),-(a7)
;	move.w	#5,-(a7)
;	trap	#14
;	lea	12(a7),a7
;
;.put_logo
;	move.w	#1,vbl_flag
;	lea	logos+34(pc),a0
;	move.l	$44e.w,a1
;	move.w	#(34*40)-1,d0
;.loop	move.l	(a0)+,(a1)+
;	dbf	d0,.loop	
;
;m2	
;	lea	mess2(pc),a0
;	moveq.l	#26,d5
;.loop	move.w	(a0)+,d1
;	;move.w	(a0)+,d0
;	move.w	(a0)+,d2
;	bsr	print
;	move.l	a0,d0
;	btst	#0,d0
;	beq.s	.nextl
;	addq.l	#1,a0
;.nextl	dbf	d5,.loop
;	
;	lea	box_table_2,a0
;	bsr	put_boxes
;	bsr	mouse_vbl2
;	move.w	#0,vbl_flag
;	bsr	fade_in
;
;.read_key
;	move.b	buts,d0
;.left	cmp.b	#2,d0
;	bne.s	.read_key
;	moveq.l	#2,d3
;.next	lea	box_table_2,a0
;	bsr	check_box
;	cmp.w	#1,d4
;	beq.s	.exit
;	bra.s	.read_key

.exit
	lea	box_table_2,a0
nocheat
	moveq.l	#1,d3
	bsr	mod_table_fade

	clr.l	$ffff8240.w
	clr.l	$ffff8244.w
	clr.l	$ffff8248.w
	clr.l	$ffff824C.w
	clr.l	$ffff8250.w
	clr.l	$ffff8254.w
	clr.l	$ffff8258.w
	clr.l	$ffff825C.w

;	movem.l	sav_col,d0-d7
;	movem.l	d0-d7,$ffff8240.w

	moveq.l	#0,d0
	bsr	music

	move.w	sav_484,$484.w
	move.l	sav_4d6,$4d6.w
	move.l	sav_4da,$4da.w
	move.l	sav_118,$118.w

	move.l	#$8080000,$ffff8800.W
	move.l	#$9090000,$ffff8800.W
	move.l	#$A0A0000,$ffff8800.W

	bsr	restore_button
	move.l	sav_stk,a7

L0000:
  MOVE.W    L0001(PC),D0
  MOVE.W    L0002(PC),D1
  MOVE.W    L0003(PC),D2
  MOVEA.L   $432.L,A0 
  BSR       L0004 
  BNE.S     L0000 
  LSL.L     #8,D2 
  ADD.L     D2,D2 
  ADDA.L    D2,A0 
  MOVE.W    L0001(PC),D0
  MOVEQ     #0,D1 
  MOVEQ     #1,D2 
  BSR       L0004 
	add.l	#$958,$432
  MOVE.L    $432.L,-(A7)
  MOVE.L    A0,$432.L 
  RTS 
L0001:
  DC.B      $00,$00 
L0002:
  DC.B      $02,$BC 
L0003:
  DC.B      $00,$27 
L0004:
  MOVEM.L   A0-A1/D1-D4,-(A7) 
  LINK      A6,#-$1C
  MOVE.W    D0,D4 
  ANDI.W    #1,D4 
  MOVE.W    D4,-28(A6)
  MOVE.W    D1,-22(A6)
  MOVE.W    D2,-18(A6)
  MOVE.L    A0,-12(A6)
  ROR.L     #3,D0 
  ANDI.W    #1,D0 
  EORI.B    #1,D0 
  ADDQ.B    #1,D0 
  MOVE.W    D0,-16(A6)
  CLR.W     D0
  ROL.L     #1,D0 
  MOVE.W    D0,-14(A6)
  MOVEQ     #$15,D0 
  ANDI.L    #$FFFF,D1 
  ADD.W     D1,D2 
  CMP.W     #$640,D2
  BGT.S     L0008 
  DIVU      #$A,D1
  CMPI.B    #1,-15(A6)
  BEQ.S     L0005 
  ADD.W     D1,D1 
L0005:
  MOVE.W    D1,-26(A6)
  SWAP      D1
  ADDQ.W    #1,D1 
  MOVE.W    D1,-24(A6)
L0006:
  MOVE.W    -24(A6),D0
  MOVEQ     #$B,D1
  SUB.W     D0,D1 
  CMP.W     -18(A6),D1
  BLE.S     L0007 
  MOVE.W    -18(A6),D1
L0007:
  MOVE.W    D1,-20(A6)
  BSR       L000B 
  BNE.S     L0008 
  MOVE.W    -18(A6),D0
  SUB.W     -20(A6),D0
  BEQ.S     L0008 
  MOVE.W    D0,-18(A6)
  MOVE.W    -20(A6),D0
  LSL.L     #8,D0 
  ADD.L     D0,D0 
  ADD.L     D0,-12(A6)
  MOVE.W    #1,-24(A6)
  MOVE.W    -16(A6),D0
  ADD.W     D0,-26(A6)
  BRA.S     L0006 
L0008:
  TST.L     D0
  BEQ.S     L000A 
  MOVEQ     #0,D2 
  MOVE.W    -26(A6),D2
  CMPI.W    #1,-16(A6)
  BEQ.S     L0009 
  LSR.W     #1,D2 
L0009:
  MULU      #$A,D2
  MOVE.L    D2,32(A7) 
L000A:
  UNLK      A6
  TST.L     D0
  MOVEM.L   (A7)+,A0-A1/D1-D4 
  RTS 
L000B:
  MOVEM.L   A0/D2-D6,-(A7)
  MOVEQ     #1,D6 
L000C:
  MOVE.W    -28(A6),D0
  MOVE.W    -26(A6),D1
  ANDI.W    #1,D1 
  CMPI.B    #1,-15(A6)
  BEQ.S     L000D 
  MOVE.W    -14(A6),D1
L000D:
  MOVE.W    -26(A6),D2
  LSR.W     #1,D2 
  MOVE.W    -24(A6),D3
  MOVE.W    -20(A6),D4
  MOVEA.L   -12(A6),A0
  BSR       L000E 
  DBEQ      D6,L000C
  MOVEM.L   (A7)+,A0/D2-D6
  RTS 
L000E:
  MOVEM.L   A0-A2/D1-D4,-(A7) 
  MOVE.W    D4,-(A7)
  MOVE.W    D1,-(A7)
  MOVE.W    D2,-(A7)
  MOVE.W    D3,-(A7)
  MOVE.W    D0,-(A7)
  CLR.L     -(A7) 
  MOVE.L    A0,-(A7)
  MOVE.W    #8,-(A7)
  TRAP      #$E 
  LEA       20(A7),A7 
  TST.L     D0
  MOVEM.L   (A7)+,A0-A2/D1-D4 
  RTS 

;	illegal

;	move.l	sav_sup,-(a7)
;	move.w	#32,-(a7)
;	trap	#1
;	addq.w	#6,a7
;	
;	clr.l	-(a7)
;	trap	#1