***********************************
*              POV 32             *
*              ------             *
* Written by                      *
*           MAC SYS DATA          *
*             29-7-90             *
***********************************
; Special menu with ISR driven scrolline

	OPT	o+,w-
BUFFER_SIZE:	EQU	17*4
WIDTH:		EQU	23
	bsr	set_super
	bsr	hide_cursor
	bsr	save_pal
	bsr	set_palette
	bsr	get_base
	bsr	calc_new_base
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	move.b	$484,old484
	move.b	#2,$484
	moveq	#1,d0
	bsr	tune
	bsr	set_for_border
	bsr	vsync
	bsr	transfer
	clr.b	$fffffc02.w
	bsr	clear_key_buffer
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	vu
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero

	tst.w	zero_counter
	bne.s	aa
	eor.w	#$200,hz_col+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#6,d0		;5 key
	bge	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#16,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50:
	move.l	old_base,a0
	bsr	set_low_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484
	clr.w	$ffff8240.w

	lea	$200,a0		;AUTORUN 4 compatable
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	bsr	user_mode

	clr.w	-(sp)
	trap	#1
	addq.l	#2,sp
	clr.w	-(sp)
	trap	#1
	addq.l	#2,sp
	rts

exit:
	bsr	isr_off
	move.l	old_base,a0
	bsr	set_med_rez
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
scroll:	tst.w	delay
	beq.s	carry_on
	sub.w	#1,delay
	rts
carry_on:
	move.l	line_ptr,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay
	add.l	#1,line_ptr
	move.w	#80,delay
	rts
delay:	dc.w	0
no_delay:
	cmp.b	#$ff,(a6)
	bne	not_wrap_scroll
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr

not_wrap_scroll:
	tst.w	scroll_number
	bgt.s	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
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


loop2:
	move.l	screen_base,a6
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
	lea	160(a2),a2	;increase screen
	dbf	d2,loop
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
	lea	$ffff8240,a0
	move.w	#16-1,d0
save_p:
	move.w	(a0)+,(a1)+
	dbf	d0,save_p
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_palette:
	lea	pic+2,a0
set_p:	lea	$ffff8240,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

calc_new_base:
;calc new screen address from BSS
	lea	screen,a0	;get buffer of 32000
	move.l	a0,d0
	and.l	#$ffff00,d0	;mask off upper words so to get rid of
				;byte off=256 byte boundry!
	move.l	d0,screen_base	;save it
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
 	move.b	$fffffa13,olda13
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
	ori.w	#$700,SR
	CLR.B	$FFFF8260.W
	move.l	old120,$120
	move.l	old70,$70

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda13,$FFFFFA13
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	move.w	#$2300,sr
	rts


transfer:
	lea	pic+34,a0	;pic top left
	move.l	a0,a2
	add.w	#80,a0
	add.w	#72,a2		;pic top right
	move.l	screen_base,a1
	move.l	a1,a3
	add.w	#80,a1
	add.w	#72,a3
	move.w	#10-1,d5
words:	move.l	#%10000000000000001000000000000000,d1
	move.l	#%00000000000000010000000000000001,d2
	move.w	#16-1,d7
bit:
	bsr	vsync

	move.w	#199,d6
lines:	move.l	(a0),d0
	and.l	d1,d0
	move.l	d0,(a1)
	move.l	4(a0),d0
	and.l	d1,d0
	move.l	d0,4(a1)
	move.l	(a2),d0
	and.l	d2,d0
	move.l	d0,(a3)
	move.l	4(a2),d0
	and.l	d2,d0
	move.l	d0,4(a3)
	move.w	#160,d0	;smaller & faster using D0 then immediate data
	add.w	d0,a0
	add.w	d0,a1
	add.w	d0,a2
	add.w	d0,a3
	dbf	d6,lines
	move.w	#32000,d0
	sub.w	d0,a0
	sub.w	d0,a1
	sub.w	d0,a2
	sub.w	d0,a3
	move.l	d1,d0
	lsr.l	#1,d0
	or.l	d0,d1
	move.l	d2,d0
	lsl.l	#1,d0
	or.l	d0,d2
	dbf	d7,bit
	move.w	#8,d0
	add.w	d0,a0
	add.w	d0,a1
	sub.w	d0,a2
	sub.w	d0,a3
	dbf	d5,words
	rts
	
vsync:
	MOVE.W	#$FFFF,horiz_sync
sync:	tst.w	horiz_sync
	bne	sync
	rts

clear_key_buffer:
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	beq.s	exrout
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bra.s	clear_key_buffer
exrout:	rts
*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	clr.w	horiz_sync
	bsr	scroll
	bsr	tune+$8
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	pic+4,$ffff8242.w
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
hz_col	move.w	#0,$ffff8240.w
	lea	pal_table,a0
	move.w	#17-1,d0
col_loop:
	move.w	(a0)+,$ffff8242.w
	REPT 120
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	move.w	pic+2,$ffff8240.w
	bclr	#0,$fffa0f
	rte
pal_table:
	dc.w	$123
	dc.w	$124,$125,$126,$127,$137,$237,$247,$347
	dc.w	$357,$457,$467,$567,$577,$677,$777,$fff

vu:	move.w	vu_number,d0
	cmp.w	#24,d0
	ble.s	.no_reset
	moveq	#0,d0
	move.w	d0,vu_number
.no_reset
	add.w	#1,vu_number
	lsl.w	#1,d0
	lea	vu_table,a0
	add.w	d0,a0
	move.w	(a0),d7
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	#15,d1
	and.w	#15,d0
	sub.w	d0,d1
	move.l	screen_base,a0
	add.w	#(160*74)+4+8,a0
	bsr	draw

	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	#15,d1
	and.w	#15,d0
	sub.w	d0,d1
	add.w	#16,a0
	bsr	draw

	move.b	#$a,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	#15,d1
	and.w	#15,d0
	sub.w	d0,d1
	add.w	#16,a0
	bsr	draw
	rts

draw:
	move.l	a0,a2
	tst.w	d1
	beq.s	.loop2
.loop	clr.w	(a2)
	lea	320(a2),a2
	subq.w	#1,d1
	bne.s	.loop
	tst.w	d0
	beq.s	ez
.loop2	move.w	d7,(a2)
	lea	320(a2),a2
	subq.w	#1,d0
	bne.s	.loop2
ez	rts


********
* Data *
********
	SECTION DATA
screen_base:	dc.l	0
old484:	dc.w	0
scroll_number:	dc.w	16
stack_save:	dc.l	0
toggle:		dc.w	0	;hertz toggle
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.l	0
olda09:	dc.b	0
olda13:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0

ei_mouse:	dc.b	$14,8
di_mouse:	dc.b	$12,$1a

line_ptr:	dc.l	scroll_line
buffer:		dcb.b	BUFFER_SIZE,0

scroll_line:
 DC.B "WELCOME TO P.O.V. 32        ALL CODING BY MAC SYS DATA, "
 dc.b "GRAFIX BY OZ, MUSIC BY MAD MAX FROM THE SO WATT DEMO.      "
 dc.b "YIPPPEE HERE'S ANOTHER GREAT DISC FROM THE BEST DEMO PACKERS "
 DC.B "IN THE UK --- PERSISTENCE OF VISION ---      WE HAVE JUST RECEIVED "
 DC.B "A MASSIVE AMOUNT OF DEMOS (OVER 50 DISCS) WHICH MEANS WE WILL "
 DC.B "BE RELEASING DISCS EVEN QUICKER.     SEEING WE HAVE SEVERAL SOFTWARE "
 DC.B "SOURCES THAT NEVER GET A MENTION, HERE ARE SOME CREDITS FOR THOSE "
 DC.B "PEOPLE 'BEHIND THE SCENES'....  THE DEMO CLUB,    GEORGE,   MARTIAN   "
 DC.B "AND   THE LOST BOYS.      SPECIAL THANKS GOTO OUR OFFICIAL "
 DC.B "DISTRIBUTOR - THE DEMO CLUB.        "
 DC.B "WELL LETS HAVE THE GREETINGS - HELLO TO;- "
 DC.B "  THE MEDWAY BOYS,  THE POMPEY PIRATES,  AUTOMATION,   THE REPLICANTS,  "
 DC.B "EMPIRE,  NEW ORDER,  THE LOST BOYS,  SYNC,  TCB,  THE SKUNK,  "
 DC.B "DTB,  DR.SYNE,  MARTIAN,  THE DEMO CLUB,  "
 DC.B "ALAN R. AND NEIL OF CB.          "
 dc.b "THIS DISC WAS RELEASED RATHER LATE DUE TO SOME PROBLEMS WITH "
 DC.B "ONE OF OUR GRAFIC ARTISTS AND BORIS BEING A BIT SLOW.     "
 dc.b "AS THIS DISC IS A LATE RELEASE I DON'T KNOW WHAT TO SAY AS I "
 DC.B "MAY COVER SUBJECTS THAT IN THEORY HAVE NOT HAPPENED YET!! "
 DC.B "  I CAN TELL YOU A SNIPPET OF INFORMATION ABOUT P.O.V. THAT "
 DC.B "YOU MAY LIKE TO HEAR... WE HAVE COMPLETED 50 DISCS OF PACKED "
 DC.B "DEMOS AND LOOK LIKE WE WILL COMPLETE ANOTHER 10 BEFORE THE "
 DC.B "END OF JAN '91.  OUR SPEED OF DISC OUTPUT IS MAINLY RESTRICTED "
 DC.B "BY THE SUPPLY OF DEMOS BUT IN THE LAST WEEK IT HAS "
 DC.B "BECOME OBVIOUS THAT WE SERIOUSLY NEED TO SIT DOWN AND CODE "
 DC.B "SOME NEW MENUS BEFORE WE CAN RELEASE ANY MORE.   IF YOU WANT TO "
 DC.B "KNOW, TODAYS DATE IS 1/1/91 AND THIS DISC WAS RELEASED WITH DISCS "
 DC.B "40 AND 52.      I WOULD LIKE TO KNOW EXACTLY HOW FAR OUR DISCS "
 DC.B "HAVE TRAVELED AROUND THE WORLD, IF YOU LIVE OUTSIDE THE UK, CAN "
 DC.B "YOU PLEASE SEND A POSTCARD TO THE FOLLOWING ADDRESS...       "
 DC.B "THE DEMO CLUB,      23 ALMA PLACE,      SPILSBY,      LINCS.,      "
 DC.B "ENGLAND,      UK,      PE23 5LB        THE POSTCARD WILL BE FORWARDED "
 DC.B "TO US FROM THIS PD LIBRARY. IF YOU WOULD LIKE A PD CATALOGUE "
 DC.B "THEN A STAMPED SELF ADDRESSED ENVELOPE (BIG ENOUGH FOR ONE DISC) SHOULD "
 DC.B "BE SENT TO THE SAME ADDRESS.    YOU MAY THINK THAT BECAUSE WE "
 DC.B "ALWAYS GIVE THE DEMO CLUB'S ADDRESS AS OUR CONTACT ADDRESS "
 DC.B "THAT WE MUST LIVE THERE. WELL YOU'RE WRONG 'COS P.O.V. IS BASED "
 DC.B "MANY MILES AWAY IN THE BLACKPOOL AREA.   IF YOU DON'T KNOW WHERE "
 DC.B "BLACKPOOL IS (IF YOU'RE NOT FROM THE UK) YOU CAN FIND IT "
 DC.B "IN AN ATLAS ON THE WEST SIDE OF THE UK ABOUT HALF WAY UP. "
 DC.B "  IF YOU HAVE ANY PROBLEMS FINDING IT, SIMPLY FIND THE SMALL "
 DC.B "ISLAND BETWEEN ENGLAND AND IRELAND (ISLE OF MANN) THEN GO EAST AND YOU SHOULD "
 DC.B "ROUGHLY BE IN THE RIGHT AREA.     WELL I THINK THIS IS ENOUGH TEXT "
 DC.B "FOR A SCROLLTEXT SO IT'S TIME TO GO.     "
 DC.B "HERE WE GO AGAIN - RIM,  RAM,  ROM,  WRAP?                       "
 dc.b "                           "
 dc.b $ff
	even
font:	incbin	font.dat
	even
tune:	incbin	SOWHAT1.MUS
	even
pic	incbin	pov32.pi1

vu_number	dc.w	0
vu_table
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000001111000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000001111000000
	dc.w	%0000001111000000


filenames:	;filenames must be 16 characters long for AUTORUN 4
	dc.b	"tnt.MSD",0,0,0,0,0,0,0,0,0
	dc.b	"death.bos",0,0,0,0,0,0,0
	dc.b	"EQUINOX2.MSD",0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0,0,0

	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000