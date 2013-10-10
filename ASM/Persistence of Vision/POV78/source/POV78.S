***************************
*        P.O.V. 78        *
*        ---------        *
* WRITTEN BY MAC SYS DATA *
***************************
;* Screen flipping menu
;* Present screen pointed to label PRESENT SCREEN

	bsr	set_super
	bsr	wait_for_drive
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	black_out
	move.l	screen_base,a0
	move.l	a0,present_base
	bsr	set_low_rez
	move.b	$484,old484
	clr.b	$484

;************************************************************************
;*                            MAD MAX 5                                 *
;*                            ---------                                 *
;************************************************************************

	move.l	#1,D0
	jsr	tune

	bsr	v_sync
	bsr	show_pic
	bsr	set_for_border
	bsr	set_palette
	bsr	set_bounce_count
	bsr	flush
main_loop
	bsr	flip_screen
;	move.w	#$123,$ffff8240.w
	bsr	print_head
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	beq.s	zero

	cmp.b	#$70,d0		;0 keypad
	beq.s	zero

car	cmp.b	#$53,d0
	beq	do_reset

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

zero	tst.w	zero_counter
	bne.s	car
	eor.w	#$4,fontpal
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra.s	main_loop

load	move.b	(a0),d0
	move.l	d0,-(sp)
	bsr	isr_off
	move.l	(sp)+,d0
bp	and.l	#$ff,d0
	lsl.w	#2,d0
	lea	filename_table,a6
	add.w	d0,a6
	move.l	(a6),a6
	lea	$200,a0
	movem.l	(a6),d0-d3
	movem.l	d0-d3,(a0)
	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	#$8,$fffffc02.w
	move.b	old484,$484
	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4,a0
	jmp	(a0)
exit	bsr	isr_off
	bsr	flush
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
print_head
	move.l	head_table_pos,a0
	move.w	(a0)+,d0
	cmp.l	#head_table_end,a0
	bne.s	.no_reset
	lea	head_table,a0
	move.w	(a0)+,d0
.no_reset
	move.l	a0,head_table_pos
	and.w	#$ff,d0
	mulu	#80*42,d0
	lea	heads,a0
	add.l	d0,a0
	move.l	present_base,a1
	add.l	#128*160,a1

	move.w	#42-1,d0
OFF	set 0
.loop	REPT	10
	move.l	(a0)+,OFF(a1)
	move.l	(a0)+,OFF+4(a1)
OFF	set OFF+8
	ENDR
	add.l	#160,a1
	dbf	d0,.loop
	rts


scroll	move.l	present_base,a6
	lea	160*204(a6),a6
	movem.l	black,d0-d7/a0-a5
OFF	set 0
	REPT	120
	movem.l	d0-d7/a0-a5,OFF(a6)
OFF	set	OFF+56
	ENDR

	move.w	sine_number,d0
	cmp.w	sine_count,d0
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
	add.w	#1,sine_number
	move.l	present_base,a1
	lea	160*204(a1),a1
	add.w	d0,a1
	move.l	a1,last_scroll
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#31*4*4,d0	;char depth * 4 *4
	add.w	d0,a0
	move.w	d6,d0
	mulu	#31*4,d0		;character depth * 4 (31*4)
	add.w	d0,a0
.column
OFF	set	0
	REPT	31
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char
.finish
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts

vsync:	move.w	#$ffff,vsync_flag
vs:	tst.w	vsync_flag
	bne.s	vs
	rts

flip_screen
	move.l	present_base,last_base
	eor.w	#-1,screen_toggle
	tst.w	screen_toggle
	bne.s	.no_reset
	clr.w	screen_toggle
.no_reset
	moveq.l	#0,d0
	move.l	screen_base,a0
	tst.w	screen_toggle
	beq.s	set
	add.l	#49152,a0
set	move.l	a0,present_base
	move.l	a0,d0
	lsr.l	#8,d0
	lea	$ffff8201,a0
	movep.w	d0,(a0)
	bsr	vsync
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
	lea	$ffff8240,a0
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

calc_screen:
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_base
	bsr	clear_below_screen
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

show_pic:
	move.l	screen_base,a1
	move.l	a1,a2
	add.l	#49152,a2
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,d2
	move.l	d2,(a1)+
	move.l	d2,(a2)+
	dbf	d0,.loop
	rts


wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive
	rts

v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

clear_below_screen:
	move.l	screen_base,a0
	add.w	#32000,a0
	move.w	#1005,d7
	movem.l	black,d0-d6/a1
.loop	movem.l	d0-d6/a1,(a0)
	movem.l	d0-d6/a1,32(a0)
	movem.l	d0-d6/a1,64(a0)
	movem.l	d0-d6/a1,96(a0)
	movem.l	d0-d6/a1,128(a0)
	lea	160(a0),a0
	dbf	d7,.loop
	rts

black_out
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

set_for_border:
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	MOVE.L	#vert_isr,$70.W
	MOVE.L	#horiz_isr,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts


isr_off	bsr	vsync
	move.w	#$2700,sr
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	MOVE.W	#$2300,SR

endmusic:
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

set_bounce_count
	lea	sine_table,a0
	moveq.l	#0,d0
.loop	add.w	#1,d0
	cmp.w	#-1,(a0)+
	bne.s	.loop
	sub.w	#1,d0
	move.w	d0,sine_count
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

*********
* ISRs  *
*********
vert_isr
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	tune+8
	clr.w	vsync_flag
	tst.w	zero_counter
	beq.s	not_z
	sub.w	#1,zero_counter
not_z	movem.l	(sp)+,d0-d7/a0-a6
	move.l	#horiz_isr,$120.W
	move.b	#110,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

horiz_isr
	clr.b	$fffffa1b.w	;DI all other interrupts
	movem.l	d0-d6,-(sp)
	movem.l	new_pal,d0-d6
	movem.l	d0-d6,$ffff8242.w
	movem.l	(sp)+,d0-d6
	move.l	#extended_scan,$120.W
	move.b	#199-110,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

extended_scan
	clr.b	$fffffa1b.w	;DI all other interrupts
	REPT	102
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz
	REPT	31
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz

	move.w	fontpal,$ffff8240.w
	movem.l	d0-d6,-(sp)
	movem.l	fontpal+2,d0-d6
	movem.l	d0-d6,$ffff8242.w
	movem.l	(sp)+,d0-d6
	bclr	#0,$fffffa0f.w
	rte

********
* Data *
********
	SECTION DATA
fontpal
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$012,$023,$034,$045,$056,$067,$077,$000

new_pal	dc.w	$100,$200,$710,$420,$530,$640,$750
	dc.w	$760,$774,$111,$222,$333,$444,$666,$777

zero_counter	dc.w	0
screen_base	dc.l	0
present_base	dc.l	0
last_base	dc.l	0
old484		dc.w	0
stack_save	dc.l	0
vsync_flag	dc.w	0
old70		dc.l	0
old120		dc.l	0
old118		dc.l	0
olda07		dc.b	0
olda09		dc.b	0
olda17		dc.b	0
olda1b		dc.b	0
olda21		dc.b	0
	even
screen_toggle	dc.w	0
old_base	dc.l	0
hertz_switch	dc.w	0

scroll_pointer	dc.l	init_scroll_text
init_scroll_text
 dc.b "         WELCOME TO PERSISTENCE OF VISION "
 DC.B "PACKED DEMO DISC 78.        "
 dc.b "GET BASHING!!!              "
scroll_text
 dc.b "THIS MENU WAS CODED BY MAC SYS DATA, GRAFIX BY OZ AND MUSIC BY MAD MAX. "
 dc.b "RELEASE DATE - 4-8-91.    "
 DC.B "      HERE ARE THE GREETINGS    HI TO    "
 DC.B "DR.SYNE,   MARTIAN,   THE MEDWAY BOYS,   THE REPLICANTS,   EMPIRE,   "
 DC.B "POMPEY PIRATES,   AXE OF DELIGHT,   EQUINOX,   AUTOMATION,   "
 DC.B "SEWER SOFTWARE,   THE SOURCE,   CARTER U.S.M.,   OBERJE,   RIPPED OFF,   "
 DC.B "GEORGE (TOWER PD!),   G-FORCE   KGB   AND   TELESCAN PD (AMIGA).          "
 DC.B "WELL EVENTUALLY I GOT IT OUT (OO-ER), THE GRAFIX FOR THIS MENU "
 DC.B "HAVE BEEN ON MY HARD DISC FOR ABOUT 6 MONTHS. I KEPT PUTTING "
 DC.B "THE MENU OFF BECAUSE I HAD TO MESS AROUND WITH THE PALETTES "
 DC.B "AND THINGS BUT WHEN I GOT DOWN TO IT (ARF, ARF) IT WAS "
 DC.B "ONE OF THE EASIEST MENUS I'VE CODED FOR AGES.   THIS MENU HAS "
 DC.B "A SPLIT SCREEN, THAT IS TO SAY THAT THE  'P.O.V' AT THE TOP "
 DC.B "IS IN 16 COLOURS USING PALETTE 1, THE SKUNK AND GLOVE ARE IN "
 DC.B "16 COLOURS USING PALETTE 2 AND THE FONT USES ANOTHER PALETTE WHICH "
 DC.B "MEANS THAT THERE ARE 16+16+16 COLOURS ON THIS SCREEN (THAT'S 48 BUT "
 DC.B "YOU CAN'T TELL CAN YOU?).        I MUST SAY HELLO TO BILBO AND STICK "
 DC.B "FROM 'RIPPED OFF' - NICE TALKING TO YOU BOYS, KEEP UP THE COMPETITION! "
 dc.b "   THE RED BLOBS THAT APPEAR WHEN THE GLOVE HITS SKUNKY IS "
 DC.B "SUPPOSED TO BE BLOOD I THINK. I HAD FINISHED THIS MENU WHEN "
 DC.B "SOME BRIGHT SPARK (MARTIAN) SAID THE SKUNK SHOULD DO "
 DC.B "SOMETHING WHEN HE GOT HIT SO I SENT THE GRAFIX BACK TO OZ FOR "
 DC.B "A TOUCH-UP.  OZ WAS ON HOLIDAY AT THE TIME SO IT TOOK A FURTHER "
 DC.B "TWO WEEKS TO GET THEM BACK IN THE MEAN TIME I HAD CODED UP "
 DC.B "SEVERAL OTHER MENUS AND RELEASED ABOUT 8 DISCS... "
 DC.B "     HAVE ANY OF YOU BEEN INTO TANDY LATELY?      I GOT "
 DC.B "A CATALOGUE SENT TO ME FROM THEM RECENTLY, INSIDE THEY HAD "
 DC.B "THE USUAL REALISTIC CRAP BUT I NOTICED THEY STOCKED A SMALL "
 DC.B "FAN THAT CLIPS ONTO A DESK OR SHELF OR WHATEVER YOU CAN FIND. "
 DC.B "  I POPPED INTO MY LOCAL TANDY SHOP AND SPENT "
 DC.B "15 QUID ON ONE.    THE FAN IS ONLY 6 INCHES IN DIAMETER BUT "
 DC.B "IT DOESN'T HALF BLOW AIR ABOUT EVEN ON THE LOW SETTING.    IF YOU "
 DC.B "LIKE ME SPEND HOURS ON YOUR COMPUTER IN A VERY WARM BEDROOM THEN "
 DC.B "I WOULD ADVISE YOU TO GET ONE AS THEY ARE BRILLIANT.  THE FAN NOT "
 DC.B "ONLY WAFTS AIR ONTO ME BUT IT CREATES AN AIR-FLOW AROUND MY "
 DC.B "STE/HARD DISC AND MONITOR WHICH KEEPS IT COOL.            "
 DC.B "WELL THAT'S IT FOR THIS ONE, WATCH OUT FOR P.O.V. 80 AS IT "
 DC.B "IS BRILLIANT!!!    BYE. "
 DC.B "                                                       "
 DC.B "                                                       "
 DC.B "                                                       "
 DC.B "                                                       "
 dc.b $ff
	even
char_offset	dc.w	0
font		dcb.b	31*4*4,0
		incbin	348.fnt
font_offsets:
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,39,43,00,00,00,00,43,40,41,45,48,42,46,28,47

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	29,30,31,32,33,34,35,36,37,38,00,00,00,00,00,44,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,47,00,48,49,50

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	even
last_scroll	dc.l	0
sine_count	dc.w	0
sine_number	dc.w	0
sine_table
	dc.w	0,0,0,0,0,0,0,0,0
	dc.w	1,1,1,1,1,1
	dc.w	2,2,2,2,2
	dc.w	3,3,3
	dc.w	4,4
	dc.w	5
	dc.w	6
	dc.w	8
	dc.w	10
	dc.w	8
	dc.w	6,5
	dc.w	4,4
	dc.w	3,3,3
	dc.w	2,2,2,2,2
	dc.w	1,1,1,1,1,1
	dc.w	$ffff
black	dcb.b	64,0

;*************************
tune	incbin	max5.mus
pic	incbin	pov78.PI1
head_table_pos
	dc.l	init_head_table
init_head_table
	dcb.w	340,8
	dc.w	7,6,5,4,3,2,1
head_table	dc.w	0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1
head_table_end
heads	incbin	head1.dat
	incbin	head2.dat
	incbin	head3.dat
	even

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5
	dc.b	7,5	;key 6

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
	dc.b	$6c,5	;keypad 6
	dc.b	$ff
	even

filename_table
	dc.l	demo1
	dc.l	demo2
	dc.l	demo3
	dc.l	demo4
	dc.l	demo5
	dc.l	demo6

demo1	dc.b	"TURTLES.MSD",0
	even
demo2	dc.b	"$$U2.BIZ",0
	even
demo3	dc.b	"$$1.PRG",0
	even
demo4	dc.b	"$$2.PRG",0
	even
demo5	dc.b	"$$3.PRG",0
	even
demo6	dc.b	"COPIER.POV",0
	even

	SECTION BSS
old_pal	ds.b	32
	ds.b	256
screen	ds.b	46000
