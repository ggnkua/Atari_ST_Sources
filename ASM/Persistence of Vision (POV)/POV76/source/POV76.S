***************************
*        P.O.V. 76        *
*        ---------        *
* WRITTEN BY MAC SYS DATA *
***************************

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
;*             GIGA-DIST TUNE FROM INNER CIRCLE DECADE DEMO             *
;*             --------------------------------------------             *
;* Stolen by: MAC SYS DATA of P.O.V. 11/05/91 18:00                     *
;*      From: DECADE DEMO                                               *
;* Include files:-                                                      *
;*                 GIGADIST.IMG into TUNE                               *
;************************************************************************
;* tune by Count Zero
;* Nic Alderton
;* 16 Redington road
;* London
;* NW3 7RG
;*
;* Tel: 071-431-4915
;
;****************************************************************
; Only one tune.....
; 0=Sound off
; 1=tune

	moveq	#1,D0
	jsr	tune

	bsr	draw_sprites
	bsr	v_sync
	bsr	show_pic
	bsr	set_for_border
	bsr	set_palette
	bsr	flush
main_loop:
	bsr	flip_screen
;	move.w	#$123,$ffff8240.w
	bsr	clear_sprites
;	move.w	#$200,$ffff8240.w
	bsr	draw_sprites
;	move.w	#$020,$ffff8240.w
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
	and.l	#$ff,d0
	lea	filenames,a6
	mulu	#16,d0
	add.w	d0,a6
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
scroll	move.l	present_base,a6
	lea	160*204(a6),a6
	movem.l	black,d0-d7/a0-a5
OFF	set 0
	REPT	120
	movem.l	d0-d7/a0-a5,OFF(a6)
OFF	set	OFF+56
	ENDR

	move.l	bounce_pos,a6
	cmp.l	#bounce_end,a6
	blt.s	.no_reset
	lea	bounce_start,a6
	move.l	a6,bounce_pos
.no_reset
	move.l	present_base,a1
	lea	160*204(a1),a1
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
	mulu	#25*4*4,d0	;char depth * 4 *4
	add.w	d0,a0
	move.w	d6,d0
	mulu	#25*4,d0	;character depth * 4 (31*4)
	add.w	d0,a0

.column
	move.l	a1,store1
	moveq	#0,d1
	move.w	(a6)+,d1
	add.w	d1,a1

OFF	set	0
	REPT	25
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	move.l	store1,a1
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
	add.l	#4,bounce_pos
	rts

store1	dc.l	0




clear_sprites
	lea	sprite_positions,a3
	lea	old_store,a2
	move.l	present_base,a6
	add.w	#56,a6
	lea	pic+34,a5
	add.w	#56,a5
	move.w	#11-1,d7
.loop	add.w	(a3),a6
	move.l	a6,a1
	add.w	(a3)+,a5
	move.l	a5,a0
	move.l	(a2)+,d0
	add.l	d0,a0
	add.l	d0,a1
OFF	set 0
	REPT	18
	move.l	OFF(a0),d0
	move.l	OFF+4(a0),d1
	move.l	d0,OFF(a1)
	move.l	d1,OFF+4(a1)
OFF	set OFF+160
	ENDR
	dbf	d7,.loop
	rts

draw_sprites
	lea	store,a5
	move.l	a5,pos_store
	movem.l	(a5)+,d0-d7/a0-a2
	movem.l	d0-d7/a0-a2,(a5)
	move.l	sine_pos,a5
	cmp.l	#end_sines,a5
	bne.s	.no_reset
	lea	sines,a5
	move.l	a5,sine_pos
.no_reset
	add.l	#2,sine_pos
	lea	sprite_positions,a3
	lea	sprite_numbers,a4

	move.l	present_base,a6
	add.w	#56,a6

	move.w	#11-1,d7		;11-1
.loop
OFF	set	0
	lea	pov_store,a0	;graphics
	lea	10*18*8(a0),a2	;masks
	moveq	#0,d5
	move.w	(a5)+,d5
	add.w	(a3)+,a6
	move.l	a6,a1
	move.w	(a4)+,d4
	and.l	#$ff,d4
	mulu	#18*8,d4
	add.w	d4,a0
	add.w	d4,a2
	add.w	d5,a1

	move.l	a2,-(sp)
	move.l	pos_store,a2
	move.l	d5,(a2)+	;store offset to sprites from screen base
	move.l	a2,pos_store
	move.l	(sp)+,a2

	REPT	18
	move.l	OFF(a1),d0
	move.l	OFF+4(a1),d1
	move.l	(a2)+,d2
	move.l	(a2)+,d3
	and.l	d2,d0
	and.l	d3,d1
	or.l	(a0)+,d0
	or.l	(a0)+,d1
	move.l	d0,OFF(a1)
	move.l	d1,OFF+4(a1)
OFF	set OFF+160
	ENDR
	dbf	d7,.loop
	rts


vsync	move.w	#$ffff,vsync_flag
vs	tst.w	vsync_flag
	bne.s	vs
	rts

flip_screen
	bsr	vsync
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


isr_off:
	bsr	vsync
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

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	clr.w	vsync_flag
	jsr	tune+2
	tst.w	zero_counter
	beq.s	not_z
	sub.w	#1,zero_counter
not_z	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#8,$fffffa1b.w
	move.b	#3,$fffffa21.w
	rte

horiz_isr:
	move.b	#4,$fffffa21.w	;4 lines per isr 
	move.l	#go_border,$120.w
	rte

go_border
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan
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
	move.w	fontpal,$ffff8240.w
	movem.l	fontpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr.b	$fffffa1b.w	;DI all other interrupts
	bclr	#0,$fffa0f
	rte

********
* Data *
********
	SECTION DATA
zero_counter	dc.w	0
screen_base	dc.l	0
present_base	dc.l	0
last_base	dc.l	0
old484		dc.w	0
stack_save	dc.l	0
vsync_flag	dc.w	0
old70		dc.l	0
old120		dc.l	0
olda07		dc.b	0
olda09		dc.b	0
olda17		dc.b	0
olda1b		dc.b	0
olda21		dc.b	0
	even
screen_toggle	dc.w	0
old_base	dc.l	0
counter		dc.w	0
hertz_switch	dc.w	0

scroll_pointer	dc.l	scroll_text+7
scroll_text
 dc.b "                    PERSISTENCE OF VISION PACKED DEMO DISC 76.    "
 dc.b "ALL CODE BY MAC SYS DATA, GRAFIX BY OZ AND MUSIC RIPPED BY "
 dc.b "MAC SYS DATA FROM THE INNER CIRCLE "
 dc.b "DECADE DEMO GIGADIST SCREEN.      "
 dc.b "RIGHT, THIS IS THE THIRD (YES 3RD) MENU IN 1 WEEK DUE TO ME "
 DC.B "CODING A FEW MENUS IN ONE GO.       I EXPECT THIS DISC WILL "
 DC.B "GO OUT BEFORE DISC 75 'CAUSE I'LL HAVE TO WAIT FOR THE INFO "
 DC.B "PROGRAM FROM BORIS (MENU 75 HAS BEEN FINISHED AND IT'S BRILLIANT)."
 DC.B "      WELL TODAY IS TUESDAY THE 28TH OF MAY 1991 AND I'VE JUST "
 DC.B "REPLACED THE TOP YOKE ON MY BIKE AND BLED THE BRAKES. THE YOKE "
 DC.B "WASN'T TOO BAD, JUST A BIT TIME CONSUMING BECAUSE I HAD TO "
 DC.B "REMOVE THE HEADLAMP AND SPEEDO AND REV COUNTER ASSEMBLY. THE BRAKES "
 DC.B "ON THE OTHER HAND WERE A BITCH.    THE BRAKES HAVE BEEN A LITTLE "
 DC.B "SPONGY FOR A WHILE SO I THOUGHT I'D BLEED THEM BEFORE GOING TO "
 DC.B "THE TT, EASY ENOUGH I THOUGHT JUST SLACKEN THE BLEED NIPPLE "
 DC.B "AND PUMP THE BRAKES..... THE RIGHT HAND SIDE WAS EASY SO I "
 DC.B "STARTED ON THE LEFT.     FIRST SLACKEN THE BLEED NIPPLE.... "
 DC.B "GOD IT'S TIGHT,     CRACK!     OH, SH*T THE BLEED NIPPLE "
 DC.B "HAS JUST SHEARED OFF,    ER,    WHAT NOW?      I CAN'T "
 DC.B "DRILL THE NIPPLE OUT 'CAUSE I MAY NOT HAVE TIME BEFORE "
 DC.B "GOING AWAY....     WELL?    WHAT DO I DO?                      "
 DC.B "OK, I'LL TELL YOU WHAT....... LEAVE THE NIPPLE IN THERE 'CAUSE "
 DC.B "IT ISN'T LEAKING OIL, I'LL FIX IT WHEN I COME BACK!    "
 DC.B "I CARRIED ON BLEEDING THE BRAKES BY SLACKENING THE "
 DC.B "BANJO BOLTS OFF AND USING THEM AS AN ESCAPE ROUTE FOR THE "
 DC.B "AIR-OIL.    THE RESULT IS A SLIGHTLY SPONGY BRAKE BUT "
 DC.B "THEY DO STOP ME NOW.   WHEN I COME BACK I'LL REPLACE THE OIL "
 DC.B "IN THE SYSTEM AND FIX THE BRAKE CALIPER BLEED NIPPLE.          "
 DC.B "THIS MORNING THE POSTMAN BROUGHT ME A LETTER "
 DC.B "FROM RACHEL IN NEWCASTLE (YEH), IN THE PACKAGE WAS A CASSETTE WITH "
 DC.B "A RECORDING BY A GROUP CALLED 'VIOLENT FEMMES'.   YEH I HADN'T "
 DC.B "HEARD OF THEM BEFORE AND I DON'T WANT TO HEAR THEM AGAIN "
 DC.B "'CAUSE THEY ARE BIZZ!   THE OTHER SIDE OF THE CASSETTE HAS THE "
 DC.B "LP 'THE LION AND THE COBRA' BY SINEAD O'CONNER AND THAT IS "
 DC.B "MUCH BETTER (I'VE HEARD IT BEFORE LOADS OF TIMES).        "
 DC.B "RIGHT, TIME FOR THE GREETS, HELLO TO THE FOLLOWING.....   "
 DC.B "AUTOMATION,   ABC CREW,   BLACK CATS,   DR SYNE,   ERIK PLANKTON,   "
 DC.B "EMPIRE,   EQUINOX,   GEORGE (TOWER PD),   INNER CIRCLE,   "
 DC.B "LOST BOYS,   MARTIAN,   MEDWAY BOYS,   OBERJE,   POMPEY PIRATES,   "
 DC.B "REPLICANTS,   SEWER SOFTWARE,   SLAYTANIC CULTS,   ST CNX,   "
 DC.B "TEX,   TCB,   AND   WATCHMEN.                        "
 dc.b "HELLO, IT IS NOW THE 29TH OF MAY AND I'VE JUST BOUGHT A NEW "
 DC.B "RUCKSACK AND A WAD OF BUNGY STRAPS. I'VE DUG OUT MY BROTHERS "
 DC.B "OLD TENT AND FIXED IT SO IT'S USABLE, MY MATE 'STRANGE ANDY' "
 DC.B "HAS GIVEN ME A HAND TO PACK ALL MY GEAR AND WE HAVE JUST "
 DC.B "THIS MINUTE FINISHED STRAPPING IT ALL TO MY Z650 MOTOR BIKE. "
 DC.B "  IN LESS THAN 3 HOURS I WILL BE RIDING TO LIVERPOOL AND BOARDING "
 DC.B "THE MANX FERRY FOR THE 4 HOUR JOURNEY.   THE BOAT ACTUALLY "
 DC.B "DEPARTS AT 1:30 IN THE MORNING BUT THEY START LOADING AT 23:00. "
 DC.B " ONE PROBLEM WITH THE LOADING TIME IS THAT I'LL HAVE NO TIME TO "
 DC.B "GO TO THE PUB FOR A BEER OR TWO   -   OH WELL, I CAN ALWAYS "
 DC.B "GET ONE ON THE BOAT!          RIGHT, IT IS NOW 18:17 AND TIME "
 DC.B "FOR MY TEA SO I'M GOING TO LEAVE YOU LOOK AT THE CRAPPY DEMOS "
 DC.B "ON THIS DISC - UNTIL NEXT TIME IT'S M.S.D. THE MAD MOTORCYCLE "
 DC.B "MAN GOING BREAKER-BREAK............ ME GONE! "
  dc.b "                                        "
 dc.b $ff
	even
char_offset	dc.w	0
font		incbin	font.fnt
	even
font_offsets:
 dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 dc.b	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
 dc.b	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58
 dc.b	59,60,61,62,63
	even
last_scroll	dc.l	0
bounce_pos	dc.l	bounce_start
bounce_start
	incbin	sine1.dat
	incbin	sine2.dat
	incbin	sine3.dat
	incbin	sine4.dat
bounce_end
	incbin	sine1.dat

black	dcb.b	64,0

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$ff
	even

;*************************
fontpal
	dc.w	$000,$750,$760,$640,$530,$420,$310,$004
	dc.w	$100,$200,$300,$400,$500,$600,$700,$777

pic	incbin	pov76.PI1

pov_store	incbin	sprites.dat

sprite_numbers
	dc.w	0,1,2,1,3,4,5,6,7,8,9
;               P . O . V D I S C 7 6
sprite_positions
	dc.w	0,8,8,8,8,16,8,8,8,16,8
;               P . O . V  D I S C  7  6

pos_store	dc.l	store
store	dc.l	0	;P
	dc.l	0	;.
	dc.l	0	;O
	dc.l	0	;.
	dc.l	0	;V
	dc.l	0	;D
	dc.l	0	;I
	dc.l	0	;S
	dc.l	0	;C
	dc.l	0	;7
	dc.l	0	;6

old_store
	dc.l	0	;P
	dc.l	0	;.
	dc.l	0	;O
	dc.l	0	;.
	dc.l	0	;V
	dc.l	0	;D
	dc.l	0	;I
	dc.l	0	;S
	dc.l	0	;C
	dc.l	0	;7
	dc.l	0	;6

sine_pos	dc.l	sines
sines	incbin	sprites1.dat
	incbin	sprites2.dat
	incbin	sprites3.dat
	incbin	sprites4.dat
	incbin	sprites5.dat
	incbin	sprites6.dat
	incbin	sprites7.dat
	incbin	sprites8.dat
	incbin	sprites9.dat
	incbin	spritesa.dat
	incbin	spritesb.dat
end_sines
	incbin	sprites1.dat

	even
tune	incbin	gigadist.img
	even
filenames:
	dc.b	"FINAL.EXE",0,0,0,0,0,0,0
	dc.b	"COLD.EXE",0,0,0,0,0,0,0,0
	dc.b	"C",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	49152
