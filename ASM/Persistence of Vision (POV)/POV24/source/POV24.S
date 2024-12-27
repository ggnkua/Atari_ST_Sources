**********
* POV 24 *
**********

	jmp	 skip_over
 dc.b "HELLO HACKER, I BET YOU'RE LOOKING FOR THE SOUND-TRACKER ROUTINE "
 DC.B "ARN'T YOU?   WELL FUCK OFF AND WRITE YOUR OWN OR GET IN CONTACT "
 DC.B "WITH EQUINOX.  IF YOU'RE ONLY AFTER SOME TRACKER MODULES THEN "
 DC.B "PHONE 0253-700382 AND ASK FOR MARK. I'LL SEE WHAT I CAN DO BUT "
 DC.B "YOU MUST CREDIT ME FOR THE AMIGA HACKING PART...  BYE.."
	EVEN
skip_over:
BUFFER_SIZE:	EQU	16*8
WIDTH:		EQU	16
BASE:		equ	$66000
go:

start:
	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	$C(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1C(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	set_super
wait_for_drive:
	tst.w	$43e
	clr.l	$24
	bne.s	wait_for_drive

	bsr	hide_cursor
	bsr	save_pal
	lea	intro_pic+2,a0
	bsr	set_palette
	bsr	get_base
	move.l	#BASE,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	lea	intro_pic+34,a0
	bsr	show_pic
	clr.l	$24

***********************
* SOUND TRACKER INTRO *
* ------------------- *
* Coded by            *
* MAC SYS DATA        *
*                     *
***********************
	clr.b	$fffa09
	lea	track_data,a0
	jsr	play
	move.l	$70,-(sp)
	move.l	#vbl,$70
att	cmp.b	#$39,$fffc02
	bne	att
	move.w	#$2700,sr
	move.l	(sp)+,$70
	jsr	play+8
	move.b	#$64,$fffa09
	move.W	#$2300,sr
	move	#4000,d0
wait_mfp	
	nop
	dbra	d0,wait_mfp
	bra.s	now
vbl	jsr	play+4
	rte
now:
	lea	pic+2,a0
	bsr	set_palette
	lea	pic+34,a0
	bsr	show_pic
	bsr	set_for_border
	clr.l	$24
*************************************************************************
* play RAMPAGE music (C) MSD 1989                                       *
* Other files needed;-                                                  *
*                     RAMPAGE.IMG into TUNE                             *
* Stolen from the GIGABYTE CREW in '88                                  *
*************************************************************************
* This tune is also on AUTOMATION 127                                   *
*************************************************************************
	lea	$24,a5
	move.b	$484,old484
	move.b	#2,$484		;no sound from IKBD
	move.l	#$68000,(a5)
	bsr	set_chip
; 0=normal tune
; 1=hi score?
	move.l	#0,D0
	bsr	tune

	move.w	#$ffff,horiz_sync
main_loop:
	tst.w	horiz_sync
	bne	main_loop
;	move.w	$ffff8240.w,-(sp)
;	move.w	#$070,$ffff8240.w
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	scroll2
	bsr	scroll2
;	move.w	(sp)+,$ffff8240.w
	MOVE.W	#$FFFF,horiz_sync
	move.b	$fffc02,d0
;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$111,pic+2
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
	cmp.b	#4,d0		;3 key
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
	mulu	#14,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	move.l	old_base,a0
	bsr	set_low_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484
	bsr	user_mode

	move.l	old_base,a0
	add.w	#160*199,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
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
scroll:	
	tst.w	delay
	beq.s	carry_on
	sub.w	#1,delay
	rts
carry_on:
	move.l	line_ptr,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay
	add.l	#1,line_ptr
	move.w	#320,delay
	rts
delay:	dc.w	0
no_delay:
	cmp.b	#$ff,(a6)
	bne	loop3
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr
loop3:	
	tst.w	scroll_number
	bne	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	lsl.w	#5,d0	;*32 (single plane char set)
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
	move.l	(a6),(a1)

loop2:	move.l	#BASE+32000+320,a6
	move.l	a6,a2
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

	add.w	#160,a6
	move.w	#15-1,d0
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
	move.w	(a6),d7
	and.w	#$3fff,d7
	roxl.w	#1,d7
	move.w	d7,(a6)
	add.w	#160,a6
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts

scroll2:	
	tst.w	delay2
	beq.s	carry_on2
	sub.w	#1,delay2
	rts
carry_on2:
	move.l	line_ptr2,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay2
	add.l	#1,line_ptr2
	move.w	#320,delay2
	rts
delay2:	dc.w	0
no_delay2:
	cmp.b	#$ff,(a6)
	bne	loop32
	lea	scroll_line2,a6	;restart message
	move.l	a6,line_ptr2
loop32:
	tst.w	scroll_number2
	bne	loop22
	move.w	#WIDTH,scroll_number2
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr2
	sub.w	#32,d0
	lsl.w	#5,d0	;*32 (single plane char set)
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
	lea	buffer2,a1
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6),(a1)

loop22:	move.l	#BASE+32000+(160*20),a6
	move.l	a6,a2
	add.w	#152,a2

	lea	buffer2,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#16-1,d1
.loop:	roxl.w	(a1)
	move.w	(a1)+,d0
	and.w	#1,d0
	or.w	d0,(a2)
	add.w	#160,a2
	dbf	d1,.loop

	add.w	#160,a6
	move.w	#15-1,d0
loopy2:	roxl.w	152(a6)
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
	move.w	(a6),d7
	and.w	#$3fff,d7
	roxl.w	#1,d7
	move.w	d7,(a6)
	add.w	#160,a6
	dbf	d0,loopy2
	sub.w	#1,scroll_number2
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

set_palette:
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
	move.l	#BASE,a1
	move.w	#32000/4-1,d0
d_pic:	move.l	(a0)+,(a1)+
	dbf	d0,d_pic
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
	move.l	#BASE+32000,a0
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


set_chip:
	move.w	#5,D0
	clr.w	D1
	lea	$FF8800,A0
.loop:	move.b	D1,(A0)
	move.b	#0,2(A0)
	sub.w	#1,D0
	bne.s	.loop
	move.b	#7,$FF8800
	move.b	$ff8802,D2
	and.b	#$C0,D2
	or.b	d1,d2
	move.b	D2,$FF8802
	move.b	#8,$FF8800
	move.b	#0,$FF8802
	move.b	#9,$FF8800
	move.b	#0,$FF8802
	move.b	#10,$FF8800
	move.b	#0,$FF8802
	rts

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	clr.w	horiz_sync
	bsr	tune+$106
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
	lea	pal_table,a0
	move.w	#45-1,d0
col_loop:
	move.w	(a0)+,$ff8242

	REPT 120
	nop
	ENDR

	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	bclr	#0,$fffa0f
	rte
pal_table:
	dc.w	$777
	dc.w	$777,$666,$555,$444,$333,$222,$111,$002
	dc.w	$003,$004,$005,$006,$007,$007,$000,$000
	dc.w	0,0,0
	dc.w	$100,$200,$300,$400,$500,$600,$700,$600
	dc.w	$500,$400,$300,$200,$100

	rte

********
* Data *
********
old484:	dc.w	0
scroll_number:	dc.w	16
scroll_number2:	dc.w	16
old_pal:	ds.b	32
stack_save:	dc.l	0
toggle:		dc.w	0	;hertz toggle
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.l	0
olda09:	dc.b	0
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
line_ptr2:	dc.l	scroll_line2
buffer:		dcb.b	0,BUFFER_SIZE
buffer2:	dcb.b	0,BUFFER_SIZE

scroll_line:
 dc.b "WELCOME TO POV 24.          WELL WE'RE BACK AGAIN TO BRING "
 DC.B "YOU SOME MORE PACKED DEMOS.      THIS MENU WAS AGAIN CODED BY "
 DC.B "MAC SYS DATA WITH MUSIC FROM RAMPAGE.     "
 dc.b "THIS DISC IS A WORLD FIRST, IT IS THE FIRST DEMO COMPILATION "
 DC.B "TO HAVE A SOUND TRACKER TUNE ON THE MENU.   THE TUNE WAS IN A "
 DC.B "DEMO ON THE AMIGA SO I DUG OUT MONAM2 AND DID MY FIRST PIECE "
 DC.B "OF AMIGA HACKING. FIRST OF ALL A QUICK HACK TO DEPACK THE FILE "
 DC.B "AND SAVE IT, NEXT A SEARCH FOR THE START OF A TRACKER. RIGHT, "
 DC.B "I'VE GOT IT, NOW WHERE THE HELL DOES IT END?    OH SOD IT I'LL SAVE "
 DC.B "180K, THAT SHOULD BE ENOUGH.  NOW LOAD KERMIT ON BOTH ST AND AMIGA.... "
 DC.B " HERE WE GO, 180K AT 150 BYTES A SECOND.. . . .. . . .. . . .. "
 DC.B "(SOME TIME LATER ON THE ST) WELL THE DATA IS ON THE ST BUT IT'S A BIT "
 DC.B "BIG, I KNOW I'LL HAVE A LOOK WITH MY GRAPHICS HACKER PROGRAM... "
 DC.B "HEY WOW! A LOAD OF CODE.......... HEY THERE'S SOME GRAPHICS HERE!       "
 DC.B "     RIGHT A CHOP AND CUT THERE AND I'LL SAVE THAT BIT....... "
 DC.B "      NOW WHERE'S THAT ASSEMBLER?   HERE WE GO... ALL LOADED. NOW TO RUN "
 DC.B "IT..... WELL F*CK ME! IT WORKS FIRST TIME.        IT WAS JUST LIKE THAT! "
 DC.B "    SO FOR ALL YOU BUDDING HACKERS, GET AN AMIGA AND AN RS232 LEAD AND HAVE "
 DC.B "A GO. (THE SOFTWARE YOU'LL NEED IS KERMIT - OR SIMILAR - AND THE EQUINOX TRACKER "
 DC.B "SOURCE CODE).            "
 dc.b "WHAT DO YOU THINK OF "
 DC.B "THE PIC?    I COPIED IT FROM ONE OF THOSE TEA CARDS THAT YOU GET "
 DC.B "OUT OF P.G. TIPS.    DR.SYNE HAS ALL THE SET SO WE HAVE ANOTHER "
 DC.B "24 PICTURES TO HAVE A GO AT.      WE ARE ALWAYS LOOKING FOR MORE GRAPHIX, SO "
 DC.B "IF YOU'VE DRAWN A GOOD PIC THEN GET IN TOUCH VIA 'THE DEMO CLUB' AND WE "
 DC.B "WILL PROBABLY USE IT.           NOW FOR THE MOST COMMONLY READ NAMES IN "
 DC.B "THE HISTORY OF COMPUTING......   HELLO TO;-   "
 DC.B "AUTOMATION,   THE REPLICANTS,   STEW,   THE MEDWAY BOYS,   THE POMPEY PIRATES,   "
 DC.B "TCB,   SEWER SOFT,   SLIPSTREAM (AMIGA),   THE LOST BOYS,   THE DEMO CLUB,   "
 DC.B "AN COOL (GREAT STE DEMO),   DYNAMIC DUO (I LIKE THE MESSAGE TO ALL HACKERS IN "
 DC.B "YOUR ULTIMATE DEMO),   OZ (ARE NEW ARTIST),   NIEL OF CB   AND  ALL THE GUYS "
 DC.B "AT THE BLACKPOOL CLUB (INCLUDING MARTIN).            BYE... MSD 4-7-90            "
 DC.B "          "
	dc.b	$ff,$ff,$ff,$ff
	even
scroll_line2:
 dc.b "             P.O.V. IS PRESENTLY MADE UP OF -     MAC SYS DATA    ",$7F
 DC.B "   DR.SYNE       ",$7F,"  ALY         ",$7F,"AND        BORIS.       ",$7F,"  THE ONLY ACTIVE MEMBER IS "
 DC.B "-  MAC SYS DATA.     I MAY SOON BE WEEDING OUT THE LAMER BORIS BECAUSE "
 DC.B "HE STILL HASN'T DONE DISC 7.   IF IT DOESN'T APPEAR IN THE NEXT 6 WEEKS "
 DC.B "THEN I'LL WRITE IT.         I SEE SEWER SOFT HAVE BEATEN ME TO GET A TEENAGE "
 DC.B "MUTANT HERO TURTLE PICTURE ONTO A MENU, I'VE DIGITIZED ONE BUT HAVN'T COLOURED "
 DC.B "IT IN YET.   I WONDER WHAT WILL BE THE NEXT CRAZE?       IF YOU ARE LOOKING FOR "
 DC.B "THE GREETINGS THEN YOU'LL HAVE A LONG WAIT 'COS THEY AREN'T IN THIS SCROLLINE. "
 DC.B "   IF YOU WISH TO HAVE A GREET THEN DO A DEMO OR GREET US FIRST.             "
 DC.B "RIGHT, WRAP TIME....        "
 dc.b $ff,$ff,$ff,$ff

font:	incbin	"med_font.dAT"
	even
tune:	Incbin	"rampage.IMG"
	even
pic	incbin	"pov24.PI1"
	even

****************
* Tracker data *
****************
play:	incbin	replay.bin
	even
track_data:
	incbin	b_storm.mod
	even
intro_pic:
	incbin	intro.pi1
	even
filenames:
	dc.b	"oxygen.msd",0,0,0,0
	dc.b	"MUZAKDEM.O",0,0,0,0
	even






