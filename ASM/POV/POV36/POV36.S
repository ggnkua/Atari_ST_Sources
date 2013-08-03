*********************************
* Persistence Of Vision menu 36 *
* ----------------------------- *
*                               *
* (c) Copyright MSD 1990        *
* Assemble with GENST 2.08 or > *
*********************************

BUFFER_SIZE:	EQU	17*4
WIDTH:		EQU	24

	bsr	set_super
wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive

	bsr	hide_cursor
	bsr	save_pal
	bsr	set_palette
	bsr	get_base
	bsr	calc_screen
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	move.b	$484,old484
;switch blade tunme
	moveq	#0,D0
	bsr	tune

	bsr	set_for_border
	bsr	show_pic
	move.b	#0,$fffffc02.w
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	scroll
;	move.w	pic+34,$ffff8240.w
	move.b	$fffffc02.w,d0
;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$53,d0
	beq	reset
	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$222,pic+2
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#6,d0		;5 key
	bge.s	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	cmp.b	#28,d0
	beq.s	brain
cont_p	lea	$ffff8240.w,a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	tst.w	zero_counter
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	move.l	old_base,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.w	(a6),(a0)

	bsr	user_mode
	clr.w	-(sp)
	trap	#1
brain	pea	brainmess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bra.s	cont_p

reset	move.l	4,a0
	jmp	(a0)
exit:
	bsr	isr_off
	move.l	old_base,a0
	bsr	set_med_rez
;	bsr	set_low_rez

	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484
	bsr	user_mode

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************
* Subroutines *
***************
scroll:
	move.l	line_ptr,a6
	cmp.b	#$ff,(a6)
	bne	not_wrap_scroll
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr
not_wrap_scroll:
	tst.w	scroll_number
	bgt.s	loop2
	move.w	#WIDTH,scroll_number
	moveq	#0,d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	mulu	#68,d0
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
	lea	buffer,a1
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6),(a1)	;68 bytes each char

loop2:	move.l	screen_base,a6
	add.w	#32000+480,a6
	move.l	a6,a2

	move.w	#4,d3		;scroll 4 bits per VBL
	sub.w	d3,scroll_number

	moveq	#0,d1
OFF	set	(160*16)+152

	REPT	(17*20)
	moveq	#0,d0
	move.w	OFF(a6),d0
	lsl.l	d3,d0
	or.w	d1,d0
	move.w	d0,OFF(a6)
	swap	d0
	move.w	d0,d1
OFF	set	OFF-8
	ENDR

	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#17-1,d2
loop	moveq	#0,d0	
	move.w	2(a1),d0
	lsl.l	d3,d0
	move.w	d0,2(a1)

	swap	d0
	move.w	d0,d1

	moveq	#0,d0	
	move.w	(a1),d0
	lsl.l	d3,d0
	or.w	d1,d0
	move.w	d0,(a1)

	swap	d0
	moveq	#0,d1
	move.w	#$000f,d1
	and.w	d1,d0		;mask data coming onto screen
	eor.w	#$ffff,d1	;invert mask
	and.w	d1,(a2)		;mask data already on screen to prevent wrap
	or.w	d0,(a2)		;or coming on over already there!

	addq.w	#4,a1
	add.w	#160,a2
	dbf	d2,loop
	rts

vsync:	move.w	#$ffff,vsync_flag
vs:	tst.w	vsync_flag
	bne.s	vs
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
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
set_p:	lea	$ffff8240.w,a1
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
	lea	masks,a2
	move.w	#11-1,d3	;11 masks
.loop1:
	move.l	screen_base,a1
	lea	pic+34,a0

	move.w	#10-1,d2
.loop2:
	move.w	#20-1,d1
.loop3:
	move.w	#20-1,d0
.loop4:
	move.w	(a2),d4
	move.w	(a0),d5
	and.w	d4,d5
	move.w	d5,(a1)

	move.w	(a2),d4
	move.w	2(a0),d5
	and.w	d4,d5
	move.w	d5,2(a1)

	move.w	(a2),d4
	move.w	4(a0),d5
	and.w	d4,d5
	move.w	d5,4(a1)

	move.w	(a2),d4
	move.w	6(a0),d5
	and.w	d4,d5
	move.w	d5,6(a1)

	add.w	#2,a2
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop4
	sub.w	#20*2,a2

	sub.w	#160*20,a0
	sub.w	#160*20,a1

	add.w	#8,a0
	add.w	#8,a1
	dbf	d1,.loop3

	add.w	#19*160,a0
	add.w	#19*160,a1
	dbf	d2,.loop2

	add.w	#20*2,a2
	dbf	d3,.loop1
	rts

v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#1
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

hide_cursor:
	pea	di_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

show_cursor:
	pea	ei_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

clear_below_screen:
	move.l	screen_base,a0
	add.w	#32000,a0
	move.w	#20,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
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


isr_off:
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
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

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	bsr	tune+$4
	clr.w	vsync_flag
	move.w	pic+4,$ffff8242.w
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#8,$fffffa1b.w
	move.b	#3,$fffffa21.w
	rte

horiz_isr:
	move.b	#4,$fffffa21.w	;4 lines per isr 
	move.l	#go_border,$120.w
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan:
	REPT	98
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz
	REPT	31
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz
	move.l	#lower_border,$120.w
	rte

lower_border:
	clr.b	$fffa1b		;DI all other interrupts
	movem.l	d0/a0,-(sp)
	move.w	pic+2,$ffff8240.w
	lea	pal_table,a0
	move.w	#17-1,d0
col_loop:
	move.w	(a0)+,$ffff8242.w
	REPT 120
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	clr.w	$ffff8240.w
	bclr	#0,$fffa0f
	rte
pal_table:
	dc.w	$200
	dc.w	$300,$400,$510,$620,$730,$740,$750,$760
	dc.w	$770,$760,$750,$740,$730,$620,$510,$400

********
* Data *
********
	SECTION DATA
screen_base:	dc.l	0
old484:	dc.w	0
scroll_number:	dc.w	WIDTH
stack_save:	dc.l	0
vsync_flag:	dc.w	0
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.b	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
old_base:	dc.l	0
counter:	dc.b	0
	even
ei_mouse:	dc.b	$14,8
di_mouse:	dc.b	$12,$1a

line_ptr:	dc.l	scroll_line
scroll_line:
 dc.b "PERSISTENCE OF VISION DISC 36.     "
 dc.b "CODED BY M.S.D., MUSIC FROM SWITCHBLADE, ART BY OZ.       "
 DC.B "WOW!  ANOTHER DEMO COMPILATION BY THE BEST IN THE U.K. "
 DC.B "  THIS DISC WAS RELEASED ON 14-10-90, DISC 37 SHOULD BE "
 DC.B "FINISHED IN 3 DAYS!    OK, WE'VE HAD ENOUGH OF THE "
 DC.B "SLAGGING SKUNK OFF SO WE HAVE CALLED AN END TO IT AND "
 DC.B "SHALL NOW GREET HIM.    HEY SKUNK, I SEE YOU'VE "
 DC.B "JOINED WITH SOMEBODY ELSE AND YOU'VE BEEN BUSY DOING "
 DC.B "DEMOS, YOU SHOULD SEE YOUR WORK ON P.O.V. 38 REAL SOON. "
 DC.B "ONE SUGGESTION I HAVE IS FOR YOU TO ALTER YOUR STOS TO "
 DC.B "MOVE THE SCROLLINE A BIT 'COS ALL YOUR DEMOS LOOK THE SAME "
 DC.B "APART FROM A DIFFERENT PICTURE AND SAMPLE (NOW WHERE HAVE I HEARD "
 DC.B "THAT BEFORE?).        "
 dc.b "RIGHT HERE'S THE GREETINGS.... HI TO TCB, "
 dc.b "GEORGE (GREAT WORK, KEEP IT UP), THE LOST BOYS, "
 dc.b "AUTOMATION, MEDWAY BOYS, POMPEY PIRATES, DR.SYNE (OF P.O.V. FAME), "
 dc.b "SEWER SOFTWARE, THE SKUNK, TRAX AND NEW ORDER.        "
 dc.b "NO GREETINGS TO .....  ALL LAMERS WHO CAN'T "
 dc.b "DO ANYTHING WITH A COMPUTER BUT SLAG OFF EVERYBODY WHO CAN.             "
 dc.b "     P.O.V. THE WORLDS BEST DEMO HACKERS/PACKERS (WELL WE ARE!!!!).      "
 dc.b "            WRAP IT UP NOW.              "
 dc.b $ff
	even
brainmess
	dc.b	27,'E'
	dc.b	"Note: BRAINPOWER demo will not work",13,10
	dc.b	"      correctly on an STE as the",13,10
 	dc.b	"      lower scroll will be corrupt",13,10,10
	dc.b	"      PRESS A KEY TO CONTINUE",13,10
	dc.b	0
font:	incbin	font.dat
	even
tune:	Incbin	s_blade.img
	even
pic	incbin	pov36.PI1

masks:
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000001111000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000
	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0001111111111000
	dc.w	%0001111111111000
	dc.w	%0001111111111000
	dc.w	%0001111111111000
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0011111111111100
	dc.w	%0011111111111100
	dc.w	%0011111111111100
	dc.w	%0011111111111100
	dc.w	%0011111111111100
	dc.w	%0011111111111100
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0000000110000000
	dc.w	%0000000000000000

	dc.w	%0000000110000000
	dc.w	%0011111111111100
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0011111111111100
	dc.w	%0000000110000000

	dc.w	%0011111111111100
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0011111111111100

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

filenames:
	dc.b	"IM.MSD",0,0,0,0,0,0,0,0
	dc.b	"AMIGA.MSD",0,0,0,0,0
	dc.b	"BP.MSD",0,0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0

	SECTION BSS
old_pal:	ds.b	32

buffer:	ds.b	BUFFER_SIZE
	ds.b	256
screen:	ds.b	32000

