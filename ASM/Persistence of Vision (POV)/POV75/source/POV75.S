****************
* P.O.V. 75    *
****************
	OPT	o+
	SECTION TEXT

	bsr	set_super
	bsr	wait_for_drive
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	black_out
	clr.w	zero_counter

	move.l	scr_now,a0	;screen_base
	bsr	set_low_rez

	bsr	clear_below_screen

	clr.w	off_ptr
	lea	offsets,a0
clr	clr.b	(a0)+
	eor.w	#$700,$ffff8240.w
	cmp.l	#s,a0
	bne.s	clr
	move.l	#160*204,last_scroll
	move.b	$484.w,old484
	clr.b	$484.w

;************************************************************************
;*                           NORTHSTAR                                  *
;*                           ---------                                  *
;* Stolen by: MAC SYS DATA of P.O.V. 29/07/90 16:48                     *
;*      From: POMPEY PIRATES 32                                         *
;* Include files:-                                                      *
;*                 NORTH.IMG into TUNE                                  *
;************************************************************************

;****************************************************************
; There is more than one tune in this code....
; 0=tune 0 -main theme
; 1=tune 1
; 2=Pompey pirates 32
 
	moveq	#0,D0
	jsr	tune

	bsr	v_sync
	bsr	set_palette
	bsr	set_for_border
	bsr	show_pic

	bsr	flush
main_loop
	bsr	vsync
	bsr	set_screen
;	move.w	#$123,$ffff8240.w

	eor.w	#(21*2),off_ptr
	lea	offsets,a6
	add.w	off_ptr,a6
	bsr	restore_sprites

	bsr	display_sprites
	bsr	scroll

;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	beq	zero

	cmp.b	#$70,d0		;keypad 0
	beq	zero
	
	tst.w	zero_counter
	beq.s	car
aa:	subq.w	#1,zero_counter

car:	cmp.b	#$53,d0
	beq	do_reset

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

load	move.b	(a0),d0
	move.l	d0,-(sp)
	bsr	isr_off
	move.l	(sp)+,d0
	and.l	#$ff,d0
	lea	filename_table,a6
	and.l	#$f,d0
	lsl.w	#2,d0
	add.w	d0,a6
	move.l	(a6),a1
	lea	$200.w,a0
	movem.l	(a1),d0-d3
	movem.l	d0-d3,(a0)
	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	old484,$484.w
	move.b	#8,$fffffc02.w
	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

zero	tst.w	zero_counter
	bne	aa
	eor.w	#$012,font_pal
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra	main_loop

do_reset
	move.l	4.w,a0
	jmp	(a0)

exit	bsr	isr_off
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	bsr	user_mode
	clr.w	-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************
* Subroutines *
***************
WIDTH=5
DEPTH=32
scroll	move.l	scr_now,a0
	lea	202*160(a0),a0
	add.l	last_scroll,a0
	movem.l	black,d0-d7
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	lea	160*DEPTH(a0),a0
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	move.w	sine_number,d0
	cmp.w	#54-1,d0
	blt.s	.no_reset
	moveq	#0,d0
	move.w	d0,sine_number
.no_reset
	add.w	d0,d0
	lea	sine_table,a1
	add.w	d0,a1
	move.w	(a1),d0
	lsl.l	#5,d0
	move.w	d0,d1
	lsl.l	#2,d0
	add.l	d1,d0
	addq.w	#1,sine_number
	and.l	#$ffff,d0
	move.l	d0,last_scroll

	move.l	scr_now,a1
	lea	202*160(a1),a1
	add.l	d0,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5
	moveq	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#(DEPTH*WIDTH)*4,d0
	add.l	d0,a0
	move.w	d6,d0
	mulu	#(DEPTH*4),d0
	add.l	d0,a0
.column
OFF	set	0
	REPT	DEPTH
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish		;have we done 40 columns?

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	addq.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	cmp.w	#WIDTH,d6
	blt	.column

	clr.w	d6

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
;we have done 40 columns so now check for end of letter...
	addq.w	#1,char_offset
	cmp.w	#WIDTH,char_offset
	blt.s	.end

	clr.w	char_offset

	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts

display_sprites
	lea	path,a3
	lea	sprite_pos+(21*2),a4
	lea	sprite_nums+(21*2),a5
	moveq	#21-1,d7
.loop
	move.w	-(a5),d0
	move.w	-(a4),d4

	move.l	scr_now,a0
	lea	sprite_data,a1
	lea	sprite_mask,a2
	lsl.w	#6,d0
	add.w	d0,a1
	add.w	d0,a2
	move.w	(a3,d4),d1
	move.w	2(a3,d4),d2
	add.w	d2,a1
	add.w	d2,a2
	move.w	d1,(a6)+
	add.w	d1,a0
	and.w	#1,d1
	beq	.even
	REPT	8
	movep.l	(a0),d0
	and.l	(a2)+,d0
	or.l	(a1)+,d0
	movep.l	d0,(a0)
	movep.l	7(a0),d0
	and.l	(a2)+,d0
	or.l	(a1)+,d0
	movep.l	d0,7(a0)
	lea	160(a0),a0
	ENDR
	bra	.cont
.even
	REPT	8
	movep.l	(a0),d0
	and.l	(a2)+,d0
	or.l	(a1)+,d0
	movep.l	d0,(a0)
	movep.l	1(a0),d0
	and.l	(a2)+,d0
	or.l	(a1)+,d0
	movep.l	d0,1(a0)
	lea	160(a0),a0
	ENDR

.cont	addq.w	#4,d4
	and.w	#$ffc,d4
	move.w	d4,(a4)
	dbf	d7,.loop
	rts

restore_sprites
	move.l	a6,-(sp)
	move.l	scr_now,a2
	lea	pic+34,a3
	moveq	#21-1,d7
.loop
	move.l	a2,a0
	move.l	a3,a1
	move.w	(a6)+,d0
	add.w	d0,a0
	add.w	d0,a1
	and.w	#1,d0
	beq	.even
	REPT	8
	movep.l	(a1),d0
	movep.l	d0,(a0)
	movep.l	7(a1),d0
	movep.l	d0,7(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR
	bra	.cont
.even
	REPT	8
	movep.l	(a1),d0
	movep.l	d0,(a0)
	movep.l	1(a1),d0
	movep.l	d0,1(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR
.cont	dbf	d7,.loop
	move.l	(sp)+,a6
	rts

vsync	move.w	#$ffff,vsync_flag
vs	tst.w	vsync_flag
	bne.s	vs
	rts

flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffc02.w,d0
	bra.s	flush
flush2	rts

set_super:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_palette:
	lea	pic+2,a0
set_p	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

calc_screen
	move.l	#screen,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#46080,d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

set_screen
	move.l	scr_now,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,scr_now
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	rts

set_med_rez:
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez:
	clr.w	-(sp)
set_rez:
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_pic
	lea	pic+34,a0	;pic top left
	move.l	scr_now,a1
	move.w	#20-1,d5
words:	move.l	#%10000000000000001000000000000000,d1
	move.w	#16-1,d7
bit:	move.w	#199,d6
lines:	move.l	(a0),d0
	and.l	d1,d0
	move.l	d0,(a1)
	move.l	4(a0),d0
	and.l	d1,d0
	move.l	d0,4(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	move.w	#7,d2
.loop	dbf	d2,.loop
	dbf	d6,lines
	lea	-32000(a0),a0
	lea	-32000(a1),a1
	move.l	d1,d0
	lsr.l	#1,d0
	or.l	d0,d1
	dbf	d7,bit
	addq.w	#8,a0
	addq.w	#8,a1
	dbf	d5,words
	move.l	scr_now,a0
	move.l	a0,a1
	add.l	#46080,a1
	move.w	#32000/4-1,d0
.loop2	move.l	(a0)+,(a1)+
	dbf	d0,.loop2
	rts

v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

clear_below_screen:
	lea	s+(160*42),a0
	move.l	#(46080+46080)/4,d0
.clr	clr.l	(a0)+
	subq.l	#1,d0
	bne.s	.clr
	rts

black_out
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

set_for_border
	ori.w	#$700,sr
	move.l	$70.w,old70
	move.l	$120.w,old120
	move.b	$fffffa07.w,olda07
	move.b	$fffffa09.w,olda09
 	move.b	$fffffa0f.w,olda0f
 	move.b	$fffffa13.w,olda13
 	move.b	$fffffa17.w,olda17
	move.b	$fffffa1b.w,olda1b
	move.b	$fffffa21.w,olda21

	MOVE.L	#vert_isr,$70.W
	MOVE.L	#border,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W	;enable AUTO ISR enable after RTE
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts


isr_off:
	bsr	vsync
	move.w	#$2700,sr
	move.l	old120,$120.w
	move.l	old70,$70.w

	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda0f,$FFFFFA0f.w
	MOVE.B	olda13,$FFFFFA13.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w
	MOVE.W	#$2300,SR

endmusic:
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

wait_for_drive
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive
	rts

*********
* ISRs  *
*********
vert_isr
	clr.b	$fffffa1b.w
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#199,$fffffa21.w

;***** tune isr ****
	Jsr	tune+4
	tst.b	tune+8
	bmi.s	exisr
	addq.w	#1,count
	cmpi.w	#$24,count	;make countdown between two tunes
	bne.s	exisr
	moveq	#0,d0		;restart tune with tune 0
	move.w	d0,count
	move.b	tune+$dc7,d0
	jsr	tune
exisr	clr.w	vsync_flag
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#8,$fffffa1b.w
	move.b	#199,$fffffa21.w
	rte

border	clr.b	$fffffa1b.w
	movem.l	d0-d6/a0-a1,-(sp)
	lea	$ffff8240.w,a1
	lea	$ffff8209.w,a0
	moveq	#0,d0
	move.b	(a0),d0
	sub.b	#92,d0
	jmp	nops(pc,d0)
nops
	REPT	78
	nop
	ENDR
	clr.b	$ffff820a.w
	REPT	31-26
	nop
	ENDR
	movem.l	font_pal+4,d0-d6	;72
	move.b	#2,$ffff820a.w		;8
	move.l	font_pal,(a1)
	movem.l	d0-d6,4(a1)
	movem.l	(sp)+,d0-d6/a0-a1
	rte


********
* Data *
********
	SECTION DATA
font_pal
	dc.w	$000,$700,$007,$707,$010,$120,$130,$241
	dc.w	$320,$430,$540,$650,$760,$770,$773,$777

scr_now		dc.l	0
scr_xor		dc.l	0
old484		dc.w	0
stack_save	dc.l	0
vsync_flag	dc.w	0
old70		dc.l	0
old120		dc.l	0
olda07		dc.b	0
olda09		dc.b	0
olda0f		dc.b	0
olda13		dc.b	0
olda17		dc.b	0
olda1b		dc.b	0
olda21		dc.b	0
	even
old_base	dc.l	0
hertz_switch	dc.w	0

scroll_pointer		dc.l	init_scroll_text+7
init_scroll_text	dc.b	"                          "
 dc.b "  WELL IT'S LATE AND I KNOW IT BUT YES THIS IS IT, THE ONE "
 DC.B "YOU'VE ALL BEEN WAITING FOR...          "
scroll_text
 dc.b "PERSISTENCE OF VISION 75.     "
 dc.b "CODED BY MAC SYS DATA AND BORIS,   "
 DC.B "GRAPHICS BY OZYMANDIAS,  "
 DC.B "MUSIC RIPPED FROM NORTHSTAR BY MAC SYS DATA.       "
 DC.B "AS YOU CAN SEE THIS IS NOT THE BEST MENU WE HAVE EVER "
 DC.B "WRITTEN BUT WHO CARES, IF YOU WANT WICKED MENUS THEN "
 DC.B "LOOK AT P.O.V. 80 ONWARDS.....     THE 'WHAT TIME IS "
 DC.B "IT DEMO' HAS IT'S OWN MENU-SELECTOR SO THIS MENU WAS "
 DC.B "PURPOSELY WRITTEN TO BE SHORT AND SIMPLE SO YOU CAN "
 DC.B "GET TO THE SELECTOR QUICKLY.      THE 'WHAT TIME IS IT "
 DC.B "DEMO' WAS ORIGINALLY PACKED WITH A LZH PACKER BUT I DEPACKED "
 DC.B "IT, ALL 900K AND PACKED IT WITH ICE 2.31 SO NOW IT'S "
 DC.B "SOME 440K.     HEY OFFBEAT, IT WAS VERY LAME PROTECTION!    "
 DC.B "    AS THIS DISC HAS AN INFO PROGRAM ON IT I WON'T GO INTO "
 DC.B "THINGS TOO DEEPLY BUT I WILL GET THE GREETINGS OUT OF THE "
 DC.B "WAY     "
 DC.B "PERSONAL GREETINGS TO...    "
 DC.B "GEORGE (TOWER PD),      DR.SYNE,      BILBO FROM RIPPED OFF"
 DC.B "      AND      STEVE G.        THIS DISC IS 80 TRACK, 10 SECTORS, "
 DC.B "DOUBLE SIDED AND PUBLIC DOMAIN SO YOU CAN COPY IT UNTIL YOUR "
 DC.B "DISC DRIVE DIES.         "
 DC.B "RIGHT, I AIN'T SAYING NO MORE SO LOAD SOMETHING.      "
 dc.b "                                   "
	dc.b $ff
	even

char_offset	dc.w	0
font	dcb.b	WIDTH*DEPTH*4,0
	incbin	lander_1.fnt
font_offsets:
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,29,43,00,00,00,00,41,00,00,45,00,26,46,27,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	40,31,32,33,34,35,36,37,38,39,28,00,00,00,00,44,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,23,11,12,13,14,15,16

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	17,18,19,20,21,22,00,24,25,40,00,41,00,47,00,48,49,50

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	even
last_scroll	dc.l	0
sine_number	dc.w	0
sine_table
	dc.w	0,0,0,0,0,0,0
	dc.w	1,1,1,1,1,1
	dc.w	2,2,2,2,2
	dc.w	3,3,3,3
	dc.w	4,4,4
	dc.w	5,5
	dc.w	6,7,8,10,8,7,6
	dc.w	5,5,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1

black	dcb.b	34,0

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 4

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6B,4	;keypad 5
	dc.b	$ff
	even

;*************************
count	dc.w	0
tune	incbin	north.img
pic	incbin	pov_angl.PI1
	even

sprite_data	incbin	"SPRITES.DAT"
sprite_mask	incbin	"SPRITES.MSK"

sprite_nums
	dc.w	0,1,2,3,4,3,5,1,6,7,1,8,9,10,8,11,4,3,4,9,6
path	incbin	"PATH.DAT"
sprite_pos
NUM	set	(22*12)
	REPT	21
	dc.w	NUM
NUM	set	NUM-12
	ENDR

filename_table
	dc.l	filename1
	dc.l	filename2
	dc.l	filename3
	dc.l	filename4
	dc.l	filename5

filename1	dc.b	"$$menu.prg",0
	even
filename2	dc.b	"EXPORT.PRG",0
	even
filename3	dc.b	"WIZARD.PRG",0
	even
filename4	dc.b	"INFO75.POV",0
	even
filename5	dc.b	"COPIER.POV",0
	even

	SECTION BSS
zero_counter	ds.w	1
old_pal	ds.b	32
off_ptr	ds.w	1
offsets	ds.w	(21*2)
s	ds.b	256
screen	ds.b	46080
	ds.b	46080
