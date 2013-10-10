*************************************************************************
*				P.O.V. 82				*
*				---------				*
*									*
* Written by								*
*		MAC SYS DATA						*
*		15-6-91 						*
*									*
*************************************************************************

	opt	o+
BUFFER_SIZE:	EQU	30*8

	bsr	set_super
	bsr	wait_for_drive
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	set_palette
	bsr	get_base
	bsr	calc_screen
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	bsr	set_for_border

	move.b	$484.w,old484
	move.b	#2,$484.w		;no sound from IKBD

	moveq	#1,d0		;start tune
	bsr	tune
	bsr	transfer
	bsr	flush
main_loop
	bsr	vsync
;	move.w	#$070,$ffff8240.w
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	scroll
;	move.w	pic+2,$ffff8240.w

	move.b	$fffffc02.w,d0

;	cmp.b   #01,d0	  ;escape ********************
;	beq	  exit

	tst.w	 zero_counter	 ;if zero counter <>0 then don't
	bne.s	 .di_zero	 ;check for the zero keys

	cmp.b	 #$b,d0 	 ;0 key
	beq.s	 zero

	cmp.b	 #$70,d0	 ;0 keypad
	beq.s	 zero

.di_zero
	cmp.b	 #$53,d0
	beq.s	 do_reset

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

zero	eor.w	#$111,col_+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra.s	main_loop

do_reset
	move.l	4.w,a0
	jmp	(a0)

load	move.b	(a0),d0
	move.l	d0,-(sp)
	bsr	isr_off
	move.l	(sp)+,d0
	and.l	#$ff,d0
	lea	filenames,a6
	mulu	#16,d0
	add.w	d0,a6
	lea	$200.w,a0
	movem.l (a6),d0-d3
	movem.l d0-d3,(a0)
	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	#$8,$fffffc02.w
	move.b	old484,$484.w
	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

exit	bsr	isr_off
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	bsr	user_mode
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1


***************
* Subroutines *
***************
scroll	tst.w	delay
	beq.s	carry_on
	subq.w	#1,delay
	rts
carry_on:
	move.l	line_ptr,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay
	addq.l	#1,line_ptr
	move.w	#320,delay
	rts
delay:	dc.w	0
no_delay:
	cmp.b	#$ff,(a6)
	bne.s	not_wrap_scroll
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr

not_wrap_scroll:
	tst.w	scroll_number
	bne.s	loop2
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	lea	width_table,a5
	add.w	d0,a5
	moveq	#0,d4
	move.b	(a5),d4
	move.w	d4,scroll_number
	mulu	#30*6,d0
	lea	font,a6
	add.l	d0,a6	;letter address is in a6

;transfer letter into buffer
	lea	buffer,a1
	move.w	#30-1,d0
.loop:	move.w	(a6)+,(a1)+
	move.w	(a6)+,(a1)+
	move.w	(a6)+,(a1)+
	dbf	d0,.loop

loop2:	move.l	screen_base,a6
	add.l	#32000+480,a6
	move.l	a6,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#30-1,d1
loop
	roxl.w	4(a1)	;scroll
	roxl.w	2(a1)	;scroll
	roxl.w	(a1)	;letter
	move.w	sr,d0	;get the X flag (extra bit scrolled from letter)
	and.w	#1,d0	;mask off lowest bit
	or.w	d0,(a2) ;put onto screen
	sub.w	d4,d4	;clear carry flag to prevent crap appearing at top of letters
	addq.w	#6,a1	;increase buffer position
	add.w	#160,a2 ;increase screen
	dbf	d1,loop

	move.w	#30-1,d0
loopy:	roxl.w	152(a6)
	roxl.w	144(a6)
	roxl.w	136(a6)
	roxl.w	128(a6)
	roxl.w	120(a6)
	roxl.w	112(a6)
	roxl.w	104(a6)
	roxl.w	96(a6)
	roxl.w	88(a6)
	roxl.w	80(a6)
	roxl.w	72(a6)
	roxl.w	64(a6)
	roxl.w	56(a6)
	roxl.w	48(a6)
	roxl.w	40(a6)
	roxl.w	32(a6)
	roxl.w	24(a6)
	roxl.w	16(a6)
	roxl.w	8(a6)
	roxl.w	(a6)
	sub.w	d4,d4	;clear X flag to stop wrapping.
	add.w	#160,a6
	dbf	d0,loopy
	subq.w	#1,scroll_number
	rts

vsync	move.w	#$ffff,vsync_flag
.v	tst.w	vsync_flag
	bne.s	.v
	rts

flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts

set_super:
	clr.l	-(sp)
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

save_pal
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_palette:
	lea	pic+2,a0
set_p:	lea	$ffff8240.w,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	rts

get_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

calc_screen
	move.l	#screen,d0
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

clear_below_screen
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
	move.l	$70.w,old70
	move.l	$120.w,old120
	move.b	$fffffa07.w,olda07
	move.b	$fffffa09.w,olda09
	move.b	$fffffa13.w,olda13

	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w

	MOVE.L	#vert_isr,$70.W
	MOVE.L	#extended_scan,$120.W

	or.b	#1,$FFFFFA07.w
	or.b	#1,$FFFFFA13.w
	MOVE.W	#$2300,SR
	rts


isr_off:
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
	move.l	old120,$120.w
	move.l	old70,$70.w

	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda13,$FFFFFA13.w

	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

transfer:
	lea	pic+32034,a0	;Clear data at end of a DEGAS pic
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	screen_base,a0
	lea	pic+34,a1
	move.w	#200-1,d0
.loop1	bsr	vsync
	bsr.s	display_all
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop1
	rts

display_all
	movem.l d0-d7/a0-a6,-(sp)
	move.w	#160/4-1,d0
.loop1	move.l	(a1)+,(a0)+
	dbf	d0,.loop1
	lea	offset_table,a2
	move.w	#31,d0
.loop2	move.w	(a2)+,d2
	move.l	a1,a3
	add.w	d2,a3
	move.w	#160/4-1,d1
.loop3	move.l	(a3)+,(a0)+
	dbf	d1,.loop3
	dbf	d0,.loop2
	movem.l (sp)+,d0-d7/a0-a6
	rts

wait_for_drive:
wfd:	tst.w	$43e.w
	bne.s	wfd
get:	move.w	$ff8604,d0
	btst	#7,d0
	bne.s	get
	rts

*********
* ISRs	*
*********
vert_isr:
	movem.l d0-d7/a0-a6,-(sp)	;preserve regs
	clr.w	vsync_flag
	bsr	tune+8
	movem.l pic+2,d0-d7
	movem.l d0-d7,$ffff8240.w
	movem.l (sp)+,d0-d7/a0-a6
	tst.w	zero_counter
	beq.s	.zero
	subq.w	#1,zero_counter
.zero	move.w	pic+4,$ffff8242.w
	move.b	#199,$fffffa21.w
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

	movem.l d0/a0,-(sp)
	move.w	#26+34,d0
.lo	nop
	dbf	d0,.lo

col_	move.w	#$010,$ffff8240.w
	lea	pal_table,a0
	move.w	#32-1,d0
col_loop
	move.w	(a0)+,$ffff8242.w
	REPT 120
	nop
	ENDR
	dbf	d0,col_loop
	movem.l (sp)+,d0/a0
	move.w	pic+2,$ffff8240.w
	bclr	#0,$fffffa0f.w
	rte


	SECTION DATA

pal_table
	DC.w	$000,$100,$200,$300
	dc.w	$400,$500,$600,$700,$710,$720,$730,$740
	dc.w	$750,$760,$770,$670
	dc.w	$570,$470,$370,$270,$170,$071,$072,$073,$074,$075
	dc.w	$076,$077,$177,$277,$377,$477

********
* Data *
********
screen_base	dc.l	0
zero_counter	dc.w	0	;used as a delay for 50/60 hertz
old484		dc.w	0
scroll_number	dc.w	10
stack_save	dc.l	0
toggle		dc.w	0
vsync_flag	dc.w	0
old_base	dc.l	0

;Font - \=OZ   [=POV
line_ptr	dc.l	scroll_line
scroll_line
 DC.B "       PERSISTENCE OF VISION DISC 82     MENU CODED BY MAC SYS DATA,  "
 DC.B "ART BY \,  MUSIC BY MAD MAX.         'AY UP A RE-CYCLED MENU FROM "
 DC.B "SOME 12 MONTHS AGO (P.O.V. 29), WELL IT MAKES A CHANGE TO HAVE A SCROLLER THAT "
 DC.B "IS SLOW ENOUGH TO READ!      IF YOU HADN'T NOTICED OR NEVER SAW "
 DC.B "THE FIRST EDITION OF THIS MENU, I'LL REMIND YOU THAT THIS "
 DC.B "SCROLLER IS PROPORTIONAL........... (SEE).     IF YOU DON'T "
 DC.B "KNOW WHAT PROPORTIONAL MEANS THEN I'LL TELL YOU.... THE "
 DC.B "LETTERS ARE DIFFERENT WIDTHS - LOOK OUT FOR THE LETTER 'I' AND "
 DC.B "FOR PUNCTUATION MARKS AS THESE ARE NOT AS WIDE AS STANDARD "
 DC.B "ALPHANUMERIC CHARACTERS.       RIGHT HERE WE GO AGAIN, ROLL "
 DC.B "GREETINGS ---- YO AND HEAVE-HO TO ..       "
 DC.B "AUTOMATION,    ABC CREW,    DR.SYNE,    ERIK PLANKTON,    "
 DC.B "EMPIRE,    EQUINOX,    GEORGE,    INNER CIRCLE,    LOST BOYS,    "
 DC.B "MARTIAN,    MEDWAY BOYS,    POMPEY PIRATES,    REPLICANTS,    "
 DC.B "RIPPED OFF,    SEWER SOFTWARE,    ST CNX,    TCB    AND    WATCHMEN.    "
 DC.B "      I THINK IT'S ABOUT TIME TO GIVE SOME PD LIBRARIES "
 DC.B "A LITTLE FAME, HERE IS A LIST OF LIBRARIES DISTRIBUTING "
 DC.B "P.O.V. DISCS (IF I MISS YOU OFF THEN BLAME MARTIAN 'CAUSE HE "
 DC.B "GAVE ME THIS LIST).......      B-SOFT,    CALEDONIA PDL,    "
 DC.B "D.W. STABLES,    EMPDL,    EUPD,    LAPD,    METROPOLIS PD,    MPH,    "
 DC.B "MT SOFTWARE,    NBS,    PARADISE COMPUTERS,    PD.ST,    "
 DC.B "RIVERVIEW PD,    SOLENT SOFTWARE,    SOUTHWEST PD,    "
 DC.B "SOUTHWEST SOFTWARE LIBRARY,    ST CLUB,    STAR PD,    "
 DC.B "TOWER PD,    TRUST PD    AND    WIZARD PD.      "
 DC.B "I HAVE MISSED TWO SOURCES OFF FROM OUR ORIGINAL LIST AS "
 DC.B "MR GOODMAN HAS BACKED OUT (HA-HA-HA) AND THE DEMO CLUB SEEMS "
 DC.B "TO HAVE FOLDED WHICH IS A SHAME AS HE WAS OUR FIRST "
 DC.B "'OFFICIAL' DISTRIBUTOR OF P.O.V. AND WE WROTE "
 DC.B "A P.O.V./DEMO CLUB SOUNDTRACKER FOR HIM.        "
 DC.B "FOR ABOUT THE FOURTH TIME I AM THINKING OF RELEASING "
 DC.B "THE SOURCE CODE FOR SOME OF THESE MENUS. IF I DO THEN I "
 DC.B "THINK I'LL PUT THEM ON A SINGLE SIDED DISC AND FLOG THEM "
 DC.B "OFF TO A SPECIFIC LIBRARY AND MAKE SURE I GET 50 PENCE "
 DC.B "ROYALTIES FOR EACH DISC SOLD..... BUT THEN AGAIN I MAY NOT! "
 DC.B "      TODAY'S DATE IS 16-6-91 AND 12 MONTHS AGO I WAS CODING "
 DC.B "P.O.V. 22!     OTHER BITS OF INFORMATION ARE..... BORIS HAS "
 DC.B "FINISHED HIS COMPUTER SCIENCE DEGREE AND IS GOING FOR A "
 DC.B "PROGRAMMERS JOB. HE HAS AN INTERVIEW NEXT WEEK, IF HE GETS IT "
 DC.B "THEN HE'LL BE WORKING ON THE SEGA MEGADRIVE.    HEY, I "
 DC.B "DON'T THINK WE HAVE EVER TOLD YOU THAT BORIS ONCE WROTE A "
 DC.B "GAME ON THE ELECTRON CALLED WAREHOUSE. THE GAME WAS MARKETED "
 DC.B "AND HE GOT A RIDICULOUSLY SMALL AMOUNT OF MONEY FOR IT. "
 DC.B "   WHEN HE WROTE THE GAME HE AND A FRIEND WERE CALLED 'PILLAR GRAFICS'."
 DC.B "    I STARTED ON A SPECTRUM CONVERSION OF THE GAME BUT GOT "
 DC.B "FED UP WITH TRYING TO WORK ON THE SMALLER SPECTRUM SCREEN "
 DC.B "LAYOUT AND THEN GAVE UP AS I BOUGHT MY FIRST ST.      "
 DC.B "ANY OF YOU OUT THERE WITH A MEMORY LIKE AN ELEPHANT MAY "
 DC.B "REMEMBER THAT I ORDERED ANOTHER HARD DISC MECHANISM SOME "
 DC.B "TIME AGO FROM 'THIRD COAST TECHNOLOGIES'. WELL IT STILL "
 DC.B "HASN'T ARRIVED AND IF IT IS NOT HERE BY THE 22ND OF JUNE "
 DC.B "I AM TAKING THEM TO COURT.  A WORD OF WARNING... NEVER GO "
 DC.B "TO THIRD COAST AS THEY ARE SH*T. IF YOU WANT AN ICD HARD DISC "
 DC.B "THEN GOTO SILICA. EVEN IF SILICA CAN'T GET WHAT YOU WANT THEY "
 DC.B "WILL TELL YOU WHERE TO GET IT FROM.       RIGHT THAT'S IT FOR "
 DC.B "THIS ONE AS I'M RUNNING OUT OF DISC SPACE SO IT'S GOODNIGHT "
 DC.B "FROM ME AND IT'S GOODNIGHT FROM HIM.                    "
 DC.B "                                       WRAP. " 
 dc.b $ff
	even
buffer	dcb.b	BUFFER_SIZE,0
	even
font	incbin	font1.dat"
	incbin	font2.dat"
	even
tune	incbin max16.mus
	even

width_table
	dc.b	24,6,14,18,22,14,16,14,15,15,18,14,14,24,14,14
	dc.b	32,9,26,23,25,23,24,27,24,24,14,14,18,22,18
	dc.b	23,22,33,25,29,24,24,24,31,26,6,24,27,24,48
	dc.b	24,32,23,34,23,24,30,26,33,48,33,27,32,32,32

	even
offset_table
	dc.w	160*($28+62),160*($28+56)
	dc.w	160*($28+52),160*($28+49)
	dc.w	160*($28+46),160*($28+44)
	dc.w	160*($28+42),160*($28+40)
	dc.w	160*($28+39),160*($28+38)
	dc.w	160*($28+37),160*($28+36)
	dc.w	160*($28+35),160*($28+34)
	dc.w	160*($28+33),160*($28+32)
	dc.w	160*($28+31),160*($28+30)
	dc.w	160*($28+29),160*($28+28)
	dc.w	160*($28+27),160*($28+26)
	dc.w	160*($28+25),160*($28+24)
	dc.w	160*($28+23),160*($28+21)
	dc.w	160*($28+19),160*($28+17)
	dc.w	160*($28+14),160*($28+11)
	dc.w	160*($28+7),160*($28+1)


key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
	dc.b	$ff
	even

filenames
	dc.b	"FULL.",0,0,0,0,0,0,0,0,0,0,0
	dc.b	"TWIST.PRG",0,0,0,0,0,0,0
	dc.b	"$$SPRITES.PRG",0,0,0
	dc.b	"$$MINIDIST.PRG",0,0
	dc.b	"COPIER.POV",0,0
	even
pic	incbin	pov82.PI1
	dcb.w	160*65,0

	SECTION BSS
old70	ds.l    1
old120	ds.l    1
olda07	ds.l    1
olda09	ds.b    1
olda13	ds.b    1
old_pal ds.b	32
	ds.b	256
screen	ds.b	32000
