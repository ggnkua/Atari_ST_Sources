*************
* P.O.V. 63 *
*************

BUFFER_SIZE:	EQU	16*8
WIDTH:		EQU	16

	bsr	set_super
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	set_palette
	bsr	get_base
	lea	base,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_base
	move.l	d0,a0
	bsr	set_low_rez
	bsr	clear_below_screen
	bsr	show_pic

; BACH THE FUTURE
	move.b	$484,old484
	move.b	#2,$484		;no sound from IKBD

	move.l	#1,D0
	bsr	tune

	bsr	set_for_border

main_loop:
	bsr	vsync
;	move.w	#$070,$ffff8240.w
	bsr	scroll
	bsr	scroll2
	bsr	scroll
	bsr	scroll
	bsr	scroll2
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
	eor.w	#$2,border_col+2
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
scroll:	move.l	line_ptr,a0	;need a new letter?
	cmp.b	#$ff,(a0)
	bne	loop3
	lea	scroll_line,a0	;restart message
	move.l	a0,line_ptr
loop3:	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	moveq.l	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d0
	move.l	a0,line_ptr
	sub.w	#32,d0
	lsl.w	#5,d0	;*32
	lea	font,a0
	add.w	d0,a0	;letter address is in A0
;transfer letter into buffer
	lea	buffer,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)

loop2:	move.l	screen_base,a0
	add.l	#32480,a0
	move.l	a0,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#16-1,d1
loop:	roxl.w	(a1)
	move.w	(a1)+,d0
	and.w	#1,d0
	or.w	d0,(a2)
	add.w	#160,a2
	dbf	d1,loop

	move.w	#16-1,d0
loopy:	roxl.w	152(a0)
	roxl.w	144(a0)
	roxl.w	136(a0)
	roxl.w	128(a0)
	roxl.w	120(a0)
	roxl.w	112(a0)
	roxl.w	104(a0)
	roxl.w	96(a0)
	roxl.w	88(a0)
	roxl.w	80(a0)
	roxl.w	72(a0)
	roxl.w	64(a0)
	roxl.w	56(a0)
	roxl.w	48(a0)
	roxl.w	40(a0)
	roxl.w	32(a0)
	roxl.w	24(a0)
	roxl.w	16(a0)
	roxl.w	8(a0)
	move.w	(a0),d7
	and.w	#$7fff,d7
	roxl.w	#1,d7
	move.w	d7,(a0)
	add.w	#160,a0
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts

scroll2:
	move.l	line_ptr2,a0	;need a new letter?
	cmp.b	#$ff,(a0)
	bne	loop3b
	lea	scroll_line2,a0	;restart message
	move.l	a0,line_ptr2
loop3b:	tst.w	scroll_number2
	bne.s	loop2b
	move.w	#WIDTH,scroll_number2
	clr.l	d0
	move.b	(a0)+,d0
	move.l	a0,line_ptr2
	moveq	#0,d1
	sub.w	#32,d0
	lsl.w	#5,d0	;*32
	lea	font,a0
	add.w	d0,a0	;letter address is in A0
;transfer letter into buffer
	lea	buffer2,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)

loop2b:	move.l	screen_base,a0
	add.l	#32480+(18*160),a0
	move.l	a0,a2
	add.w	#152,a2
	lea	buffer2,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#16-1,d1
loopb:	roxl.w	(a1)
	move.w	(a1)+,d0
	and.w	#1,d0
	or.w	d0,(a2)
	add.w	#160,a2
	dbf	d1,loopb

	move.w	#16-1,d0
loopyb:	roxl.w	152(a0)
	roxl.w	144(a0)
	roxl.w	136(a0)
	roxl.w	128(a0)
	roxl.w	120(a0)
	roxl.w	112(a0)
	roxl.w	104(a0)
	roxl.w	96(a0)
	roxl.w	88(a0)
	roxl.w	80(a0)
	roxl.w	72(a0)
	roxl.w	64(a0)
	roxl.w	56(a0)
	roxl.w	48(a0)
	roxl.w	40(a0)
	roxl.w	32(a0)
	roxl.w	24(a0)
	roxl.w	16(a0)
	roxl.w	8(a0)
	move.w	(a0),d7
	and.w	#$7fff,d7
	roxl.w	#1,d7
	move.w	d7,(a0)
	add.w	#160,a0
	dbf	d0,loopyb
	sub.w	#1,scroll_number2
	rts

vsync	move.w	#-1,sync_flag
.sync	tst.w	sync_flag
	bne.s	.sync
	tst.w	zero_counter
	bne.s	dec_counter
	rts
dec_counter
	sub.w	#1,zero_counter
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
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
d_pic:	move.l	(a0)+,(a1)+
	dbf	d0,d_pic
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
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffc02.w,d0
	bra.s	flush
flush2	rts


*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	bsr	tune+8
	movem.l	(sp)+,d0-d7/a0-a6
	clr.w	sync_flag
	move.l	pic+2,$ffff8240.w
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
	clr.b	$fffffa21.w
	clr.b	$fffffa1B.w
border_col
	move.w	#$000,$ffff8240.w
	movem.l	d0/a0,-(sp)
	lea	border_cols,a0
	move.w	#35-1,d0
.loop	move.w	(a0)+,$ffff8242.w
	REPT	120
	nop
	ENDR
	dbf	d0,.loop
	movem.l	(sp)+,d0/a0
	rte

********
* Data *
********
	SECTION DATA
border_cols
	dc.w	$001,$002,$003,$004,$005,$006,$007,$017
	dc.w	$027,$037,$047,$057,$067,$077,$176,$275
	dc.w	0,0
	dc.w	$100,$200,$300,$400,$500,$600,$700,$710
	dc.w	$720,$730,$740,$750,$760,$770,$660,$550,$440
hertz_switch	dc.w	0
sync_flag	dc.w	0
screen_base	dc.l	0
old484:	dc.w	0
zero_counter	dc.w	0
scroll_number:	dc.w	16
scroll_number2:	dc.w	16
old_pal:	ds.b	32
stack_save:	dc.l	0
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.l	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
old_base:	dc.l	0
counter:	dc.w	0

line_ptr:	dc.l	scroll_line
line_ptr2:	dc.l	scroll_line2
buffer:		dcb.b	BUFFER_SIZE,0
buffer2:	dcb.b	BUFFER_SIZE,0

scroll_line:
 dc.b "PERSISTENCE OF VISION PACKED DEMO DISC 63!    "
 dc.b "THIS MENU IS FOR OZ OUR GRAFIX ARTIST WHO THINKS THE "
 DC.B "TWO SCROLLER MENUS ARE BRILLIANT.     "
 DC.B "OK I WILL QUICKLY DO THE CREDITS BEFORE I FORGET WHAT "
 DC.B "THE TUNE IS CALLED....    ALL CODING BY M.S.D., GRAFIX BY OZ AND "
 DC.B "MUSIC RIPPED FROM THE THALION TUNE DEMO - IT IS CALLED 'BACH THE FUTURE'. "
 DC.B "    THERE, THAT WASN'T TOO PAINFUL WAS IT?      "
 dc.b "IF YOU WANT TO FIND OUT WHAT DEMOS I'VE GOT LINED UP TO PACK "
 DC.B "THEN READ THE LOWER SCROLLER.  IF YOU'RE TV DOESN'T SCAN "
 DC.B "DOWN THAT FAR THEN TOUGH!!!        "
 DC.B "CAN ANYONE SEE THE TOP SCROLLER IN THE FAR UPPER BORDER?   "
 DC.B "     IF YOU CAN THEN YOU'RE TALKING CRAP 'CAUSE THERE ISN'T ONE!   HA-HA....."
 DC.B ".............  WEEEEHHHHHH.......   (SILLY MOOD AGAIN!).    "
 DC.B "      I WOULD TELL A JOKE BUT I CAN'T REMEMBER ANY.     "
 DC.B "        SMEG!      YEAH RED DWARF RULES.        "
 DC.B "WELL AS YOU CAN READ I AM IN A TOTALLY STUPID MOOD AND I "
 DC.B "DON'T CARE 'CAUSE I'M GOING OUT TO THE PUB (AGAIN).  HOW COME "
 DC.B "ON ABOUT 40 PERCENT OF P.O.V. MENUS I MENTION GOING TO THE "
 DC.B "PUB?   I DON'T GO TO THE PUB THAT MUCH (WELL ONLY 4 DAYS A WEEK) "
 DC.B "UNLESS BORIS IS HOME FROM UNIVERSITY IN WHICH CASE I GO TO THE "
 DC.B "PUB 7 DAYS A WEEK.              WELL I'LL WRAP THIS SCROLL "
 DC.B "UP HERE SO YOU CAN START READING THE LOWER ONE....  BYE.     "
 DC.B "                                                          "
 dc.b	$ff
	even
scroll_line2:
 dc.b "                                       "
 DC.B "1    2    3    TESTING....   CAN ANYBODY SEE THIS?   "
 DC.B "OH MY GOD IT'S ANOTHER SCROLLINE!       WHAT DOES IT SAY?       "
 DC.B "  BOTTOMS!        (ARF-ARF).        YES, IT'S MACHINE SYSTEM DATA "
 DC.B "HERE AGAIN STRUGGLING TO THINK OF SOMETHING TO WRITE. "
 DC.B "          IF YOU'VE JUST FINISHED READING "
 DC.B "THE UPPER SCROLLINE YOU WILL PROBABLY BE LOOKING FOR THE "
 DC.B "DEMO LIST.     WELL HERE IT IS.... THE FOLLOWING DEMOS ARE "
 DC.B "SITTING HERE WAITING TO BE PACKED ------------ "
 DC.B "INTO THE TRASHCAN,   SDLM90,   ANIMATE 3D (CRAP),   GREMLINS,   "
 DC.B "DISCOVERY PACK DEMO,   PSYCHO DEMO,   KIKKI DEE (ANGEL EYES),   "
 DC.B "STAR TREK,   NOD DEMO 2 (SLIDE SHOW),   NUMERO ONE,   "
 DC.B "BEST OF NOD,   JAG ENGINE ANIMATION (CRAP),   POSSE MIX,   "
 DC.B "SOUND CHAPPIN',   SKUNKS BIG STOS DEMO,   BLACK CATS 'YO',   "
 DC.B "SOME 3615/GEN 4 DEMOS,   ALF MEGA DEMO,   WHAT TIME IS IT,   "
 DC.B "THE BLACK DEMO,   BLOOD MONEY MUSIC,   WILD DEMO,   3 DIMENSIONS DEMO,   "
 DC.B "HEMOROIDS (3416/GEN4),   JOYSTICK DEMO,   SWS DEMO,   BACK TO THE "
 DC.B "FUTURE 2,   CIA ALPHA DEMO,   TOTAL REBATE,   SCOOBY DOO DEMO,   "
 DC.B "I MUST BE IN LOVE,   WIND HIM UP DEMO,   YAZZ - THE ONLY WAY IS UP,   "
 DC.B "CHINA IN YOUR HAND,   7 UP MENU 4,   7 UP MENU 3,   SIXTEENS DEMO,   "
 DC.B "V8 TUNE DEMO 2,   DELTA FORCE MUSIC DEMO,   ARCHIE'S MUSIC DEMO,   "
 DC.B "APRIL 1ST DEMO,   STAR TREKKIN',   KRAFTWERK,   MEDWAY BOYS "
 DC.B "STAR TREK DEMO,   THE LAST RUMBA BY J.M JARRE,   DEV CON 1 BY "
 DC.B "THE WATCHMEN (ACE!),   POWERSLAVE DEMO,   AXEL F,   NORWEGIAN DEMOS,   "
 DC.B "WRATH CHILD,    INXS 'KICK',   VIC DEMO 1,   VIC DEMO 2,   "
 DC.B "I.A.N. HOUSE ARREST,   MATTS MOOD,   FULL METAL JACKET,   "
 DC.B "3D SCROLL (STE ONLY),   MOVIE STE,   SOUNDOFF STE,   JUST FOR MONEY (PRETTY GOOD),   "
 DC.B "BOING STE AND FINALLY NEW KIDS ON THE BLOCK (COVER GIRL).       "
 DC.B "QUITE A LOT OF DEMO TO PACK, I MAY NOT PACK SOME AS THEY "
 DC.B "ARE STOS DEMOS WHICH POSE THE GREATEST PROBLEM AS I HAVE TO "
 DC.B "WADE THROUGH LOADS OF CODE TO FIND THE LOADERS.    I HAVE "
 DC.B "ALREADY PACKED THE FOLLOWING DEMOS....     "
 DC.B "BBC DIGI MUSIC DEMO 1,   SPACE ACE GAME DEMO,   CODERS 6,   "
 DC.B "POISON,   TRASH,   WHEN HARRY MET SALLY,   THUNDERBIRDS SOUNDTRACK,   "
 DC.B "FUJIBOINK - 512K VERSION,   MOTLEY CREW 'DR FEELGOOD',   PREDATOR,   "
 DC.B "NEW ORDER,   MEGAMIX,   ADAMSKI 'KILLER'   AND 6 SKUNK DEMOS... "
 DC.B "THUNDERBIRDS 25 YEAR VERSION,   U2 'SILVER AND GOLD',   "
 DC.B "BANDAID 2,   TEENAGE MUTANT HERO TURTLES,   PRISONER   AND   "
 DC.B "GOLDEN CHILD DEMO.   I DON'T KNOW WHAT IS ON THIS DISC SO "
 DC.B "I HAVE PROBABLY JUST TOLD YOU SOMETHING YOU ALREADY KNEW... "
 DC.B "     OK, THAT IS ALL FOR THE MO' SO TUNE IN SOON FOR ANOTHER "
 DC.B "THRILLING EPISODE OF      P.O.V. PACKED COMPILATION DEMO DISCS  "
 DC.B "    CHEERY-BYE!                            "
 dc.b $ff


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

font	incbin	med_font.dAT
	even
tune	incbin	bach.mus"
	even
pic	incbin	pov63.pi1"

filenames:
	dc.b	"WHMT.MSD",0,0,0,0,0,0,0,0
	dc.b	"MEGAMIX.MSD",0,0,0,0,0
	dc.b	"E2.PAK",0,0,0,0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0,0,0

	SECTION BSS
	ds.b	256
base	ds.b	32000
