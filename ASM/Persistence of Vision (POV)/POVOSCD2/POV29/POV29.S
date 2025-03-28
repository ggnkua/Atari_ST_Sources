*************************************************************************
*			PERSISTENCE OF VISION 29			*
*			------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music from:	So-Watt demo						*
*									*
*									*
* Grafix by: 	Oz							*
*									*
*									*
* Date:				27-7-90					*
* Revised for this release:	8-7-94					*
*									*
*		½ Persistence Of Vision 1990/1994			*
*									*
*************************************************************************
*
* NOTE:	I have put MORE comments in here as ST-REVIEW complained the
*	first disk lacked enough.
*
*
* Note: You will need AUTORUN 4 to run programs from this menu.
*
*
		opt	o+,w-		;optimise, no warnings
yes=1
no=0

BUFFER_SIZE	EQU	30*8

DOWNLOAD=no


	ifne	DOWNLOAD
****************************************************************
* ST downloader test program.
	include	"transmit.s"
	org	$20000
Code_Start
Exec_Addr
		move.w	#$2700,sr		;enable all interrupts
****************************************************************
	endc


		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
clear_bss	clr.b	(a0)+
		sub.w	#1,d0
		bne.s	clear_bss

		bsr	init		;go setup

main_loop	bsr	vsync
;		move.w	#$070,$ffff8240.w
		bsr	scroll		;do it 4 times due to proportional
		bsr	scroll
		bsr	scroll
		bsr	scroll
;		move.w	pic+2,$ffff8240.w

		move.b	$fffffc02.w,d0

		cmp.b	#1,d0		;escape key
		beq	exit

		cmp.b	#$b,d0		;0 key
		beq	zero

		cmp.b	#2,d0		;1 key
		blt	main_loop

		cmp.b	#5,d0		;4 key
		bge	main_loop	

		move.l	d0,-(sp)
		bsr	isr_off
		move.l	(sp)+,d0

;key is in D0.L
		and.l	#$ff,d0		;mask off rubbish
		lea	filenames,a6	;get filenames
		sub.b	#2,d0		;rid of key offset
		mulu	#14,d0		;filenames are 14 characters long
		add.w	d0,a6		;point to filename

		tst.w	toggle		;has hertz been toggled?
		beq.s	hz50		;no
		eor.b	#2,$ffff820a.w	;go into 60 hz

hz50		move.l	old_base,d0	;screen_base
		move.w	old_rez,-(sp)	;set old rez
		move.l	d0,-(sp)	;screen base
		move.l	d0,-(sp)	;  "     "
		move.w	#5,-(sp)	;call 5 is set rez
		trap	#14		;call ROM
		add.l	#12,sp		;tidy stack

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.b	#8,$fffffc02.w	;enable mouse
		move.b	old484,$484.w

		lea	$ffff8240.w,a0	;clear colours
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+

		lea	$200.w,a0	;move filename to $200
		move.l	(a6)+,(a0)+
		move.l	(a6)+,(a0)+
		move.l	(a6)+,(a0)+
		move.l	(a6)+,(a0)+
		bsr	user_mode

		clr.w	-(sp)
		trap	#1

exit		bsr	isr_off
		move.l	old_base,d0	;screen_base
		move.w	old_rez,-(sp)	;set old rez
		move.l	d0,-(sp)	;screen base
		move.l	d0,-(sp)	;  "     "
		move.w	#5,-(sp)	;call 5 is set rez
		trap	#14		;call ROM
		add.l	#12,sp		;tidy stack

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.b	#8,$fffffc02.w

		move.b	old484,$484.w
		ifeq	DOWNLOAD
		bsr	user_mode
		endc
		clr.w	-(sp)
		trap	#1


zero		tst.w	zero_counter
		bne	main_loop
		eor.w	#$222,pic+2
		eor.l	#$02220222,border_backcol
		eor.w	#$222,border_backcol+4
		eor.w	#$ffff,toggle
		move.w	#10,zero_counter
		bra	main_loop


***************
* Subroutines *
***************
scroll
do_scroll	move.l	line_ptr,a6	;position in ascii
		cmp.b	#$7f,(a6)	;is pause character?
		bne.s	.no_delay	;no so don't init delay
		add.l	#1,line_ptr	;add 1 to ascii position
		move.w	#320,delay	;length of delay into a variable
		rts
.no_delay	cmp.b	#$ff,(a6)	;is end of ascii?
		bne	.not_wrap_scroll	;no
		lea	scroll_line,a6	;restart message
		move.l	a6,line_ptr	;

.not_wrap_scroll
		tst.w	scroll_number	;check to see if we need a new letter
		bne	.just_scroll		;no
		moveq	#0,d0		;clear D0 quickly
		move.b	(a6)+,d0	;get ascii
		move.l	a6,line_ptr	;update pointer into ascii
		sub.w	#32,d0		;rid of ascii bonds to get offset
		lea	width_table,a5	;yes a propotional scroller
		add.w	d0,a5		;add character offset into table
		moveq	#0,d4
		move.b	(a5),d4		;get width of letter
		move.w	d4,scroll_number	;put width into store
		mulu	#30*6,d0	;calc char in font data DEPTH*3 words
		lea	font,a6
		add.l	d0,a6		;position of letter is in a6

;transfer letter into buffer
		lea	buffer,a1
		move.w	#30-1,d0	;depth of character is 30 lines
.loop		move.w	(a6)+,(a1)+
		move.w	(a6)+,(a1)+
		move.w	(a6)+,(a1)+
		dbf	d0,.loop

.just_scroll	move.l	screen_base,a6
		add.l	#32000+480,a6	;point to area in border
		move.l	a6,a2
		add.w	#152,a2		;right hand side of screen
		lea	buffer,a1	;buffer of part scrolled character
;scroll buffer into right pixel of screen ready for scrolling
		move.w	#30-1,d1
loop		roxl.w	4(a1)	;scroll
		roxl.w	2(a1)	;scroll
		roxl.w	(a1)	;letter
		move.w	sr,d0	;get the X flag (extra bit scrolled from letter)
		and.w	#1,d0	;mask off lowest bit
		or.w	d0,(a2)	;put onto screen
		sub.w	d4,d4	;clear carry flag to prevent crap appearing at top of letters
		add.w	#6,a1	;increase buffer position
		add.w	#160,a2	;increase screen
		dbf	d1,loop

		move.w	#30-1,d0
.scroll_loop	roxl.w	152(a6)		;shift screen
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
		dbf	d0,.scroll_loop
		sub.w	#1,scroll_number
		rts


user_mode	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

init
		ifeq	DOWNLOAD
		clr.l	-(sp)		;set supervisor mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		move.b	#$12,$fffffc02.w	;disable mouse

		movem.l	$ffff8240.w,d0-d7	;save old palette
		movem.l	d0-d7,old_pal

		movem.l	pic+2,d0-d7		;set new palette
		movem.l	d0-d7,$ffff8240.w

		move.w	#3,-(sp)		;get old screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base

		move.w	#4,-(sp)		;get old screen rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,old_rez

		move.l	#screens,d0		;calculate new screen base
		clr.b	d0			;make on 256 byte boundary
		move.l	d0,screen_base		;store the new base

		clr.w	-(sp)		;set low rez
		move.l	d0,-(sp)	;screen base
		move.l	d0,-(sp)	;  "     "
		move.w	#5,-(sp)	;call 5 is set rez
		trap	#14		;call ROM
		add.l	#12,sp		;tidy stack

		move.b	$484.w,old484	;save state of keyboard click, bell, etc.
		move.b	#2,$484.w	;no sound from keyboard

		moveq	#1,d0		;start tune
		bsr	tune

		ori.w	#$700,sr	;turn ALL interrupts off
		lea	storage_space,a0	;save old interrupt states
		move.l	$70.w,(a0)+	;old VBL
		move.l	$120.w,(a0)+	;old timerB (raster timer)
; If you don't understand then don't worry!
		move.b	$fffffa07.w,(a0)+	;isr enable A
		move.b	$fffffa09.w,(a0)+	;isr enable B
	 	move.b	$fffffa17.w,(a0)+	;MFP vector base
		move.b	$fffffa1b.w,(a0)+	;timer B control
		move.b	$fffffa21.w,(a0)+	;timer B data

		move.l	#new_vbl,$70.w		;make VBL point to ours
		move.l	#timerb,$120.W		;make Timerb point to ours

		clr.b	$fffffa1b.w		;stop Timerb
		clr.b	$fffffa21.w		;clear timerb data
		move.b	#1,$fffffa07.w		;enable timerb
		clr.b	$fffffa09.w
		bclr	#0,$fffffa0f.w
		bset	#0,$fffffa13.w
		bclr	#3,$fffffa17.w		;auto ISR enable at RTE
		move.b	#199,$fffffa21.w	;timerb to start at line 199 
		move.b	#8,$fffffa1b.w		;start timerb

		move.w	#$2300,sr		;enable all interrupts

;Show picture on roll out

		lea	pic+32034,a0	;Clear data at end of a DEGAS pic
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		move.l	screen_base,a0	;get screen base
		lea	pic+34,a1	;start of picture data
		move.w	#200-1,d0	;200 lines per screen
.loop1		bsr	vsync		;sync to VBL
		bsr	display_all	;draw the barrel
		lea	160(a0),a0	;drop down a line in pic
		lea	160(a1),a1	;drop down a line on screen
		dbf	d0,.loop1	;go loop
		rts
display_all	movem.l	d0-d7/a0-a6,-(sp)	;draw the barrel - save regs to stack
		move.w	#160/4-1,d0		;160 bytes per line on screen
.loop1		move.l	(a1)+,(a0)+		;move 4 bytes at once
		dbf	d0,.loop1
		lea	offset_table,a2		;get barrel look-up table
		move.w	#32-1,d0		;barrel is 32 bytes deep
.loop2		move.w	(a2)+,d2		;get offset
		move.l	a1,a3			;copy screen address
		add.w	d2,a3			;add offset
		move.w	#160/4-1,d1		;move 1 screen line
.loop3		move.l	(a3)+,(a0)+
		dbf	d1,.loop3
		dbf	d0,.loop2		;do rest of barrel
		movem.l	(sp)+,d0-d7/a0-a6	;get regs off stack
		rts				;return to where we was called from

vsync		move.w	#-1,vsync_flag
.vs		tst.w	vsync_flag
		bne.s	.vs
		rts

isr_off
		ORI.W	#$700,SR

		lea	storage_space,a0	;save old interrupt states
		move.l	(a0)+,$70.w		;old VBL
		move.l	(a0)+,$120.w		;old timerB (raster timer)
		move.b	(a0)+,$fffffa07.w	;isr enable A
		move.b	(a0)+,$fffffa09.w	;isr enable B
	 	move.b	(a0)+,$fffffa17.w	;MFP vector base
		move.b	(a0)+,$fffffa1b.w	;timer B control
		move.b	(a0)+,$fffffa21.w	;timer B data

		move.w	#$2300,sr

		lea	$ffff8800.w,a0		;turn sound chip off
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		rts



*********
* ISRs  *
*********
;**** VBL interrupt occurs every screen update, this code is run when the
;**** raster gets to the top of the screen
;****
new_vbl		movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
		clr.w	vsync_flag		;clear our sync flag
		bsr	tune+8			;play the tune
		movem.l	pic+2,d0-d7		;reset colours
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7/a0-a6	;get back regs from stack
		move.b	#8,$fffffa1b.w		;start timerb again (disabled at start of timerb code)
		tst.w	zero_counter		;check for delay on hertz key
		bne.s	.dec			;not zero so decrease it
		rte				;we, we're free of the isr!!
.dec		sub.w	#1,zero_counter		;dec it here
		rte				;get out of the isr!

;**** Timerb is run at whatever time we decide, in this menu it is called
;**** at line 199 of the screen.
;****
timerb		clr.b	$fffffa1b.w	;disable timerb
		movem.l	d0/a0/a1,-(sp)
		lea	pal_table,a0
		lea	border_backcol,a1
		REPT	60		;wait until raster is at right of scrn
		nop
		ENDR
.wait		move.b	$ffff8209.w,d0	;wait for raster....
		bne.s	.wait
		clr.b	$ffff820a.w	;60 hertz
		move.w	#32,d0
		REPT	19
		nop
		ENDR
		move.b	#2,$ffff820a.w	;back to 50 hertz
col_loop	move.w	(a0)+,$ffff8242.w	;change colours
		move.w	(a1)+,$ffff8240.w
		REPT 117	;wait for next screen line
		nop
		ENDR
		dbf	d0,col_loop
		movem.l	(sp)+,d0/a0/a1
		move.w	pic+2,$ffff8240.w
		rte

	ifeq	DOWNLOAD
	SECTION DATA
	endc
;Font - \=OZ   [=POV
line_ptr	dc.l	scroll_line
scroll_line
 DC.B "HELLO EVERYBODY, YES IT'S     [ 29     ",$7F,"MENU CODED BY MAC SYS DATA,  "
 DC.B "ART BY \,  MUSIC BY MAD MAX.        WELL WHAT DO YOU THINK OF THIS "
 DC.B "PROPORTIONAL SCROLLER?   I HAD TO WRITE ONE BECAUSE \ DESIGNED THIS "
 DC.B "FONT AND EVERY LETTER IS A DIFFERENT SIZE (THANKS \!!!!)     "
 dc.b "I MUST APOLOGISE TO HALF MEG OWNERS FOR PUTTING ANOTHER 1 MEG ONLY "
 DC.B "DEMO ON THIS DISC.  IF I HAD SOME 1/2 MEG DEMOS THEN I'D PACK THEM "
 DC.B "AND PUT THEM ON A MENU IN RECORD TIME.    AS WE HAVE NOT BEEN SENT "
 DC.B "ANY 1/2 MEG DEMOS, BORIS IS NOW WRITING SOME (AREN'T YOU BORIS?).   "
 DC.B "WELL I'M BUSY DOING MENUS AND PACKING,   BORIS IS WRITING DEMOS,   "
 DC.B "\ IS BUSY DOING GRAFIX,   DR.SYNE IS BUSY PLAYING GAMES   AND ALY IS "
 DC.B "BUSY DOING NOTHING AT ALL.     "
 DC.B "WELL I'LL LEAVE THE GREETINGS FOR ANOTHER "
 DC.B "TIME SO YOU MAY AS WELL GET PRESSING SOME KEYS.......          BYE "
 DC.B "               5        4        3        2        1        "
 dc.b	$ff,$ff
	even
buffer		dcb.b	BUFFER_SIZE,0
	even
font		incbin	font.dat
	even
tune	Incbin "sowhat4.mus"
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

filenames
;*** filenames should be 14 bytes long so pad out with zeros
		dc.b	"PSB",0,0,0,0,0,0,0,0,0,0,0
		dc.b	"LOADER.MSD",0,0,0,0
		dc.b	"COPIER.POV",0,0
		even
pic		incbin	"pov29.PI1"
		dcb.w	160*65,0

pal_table
	dc.w	$100,$200,$300,$400,$500,$600,$700,$710,$720,$730,$740
	dc.w	$750,$760,$770,$670,$570,$470,$370,$270,$170,$071,$072
	dc.w	$073,$074,$075,$076,$077,$177,$277,$377,$477,$577,$677

border_backcol	dc.w	0,0,0
		dcb.w	30,$022

	ifeq	DOWNLOAD
	SECTION BSS
	endc
bssstart
screen_base	ds.l	1	;our screen
old_rez		ds.w	1
old_pal		ds.b	32
old_base	ds.l	1
storage_space	ds.b	14	;isr data,etc.
delay		ds.w	1
zero_counter	ds.w	1	;used as a delay for 50/60 hertz
old484		ds.w	1
scroll_number	ds.w	1
stack_save	ds.l	1
toggle		ds.w	1	;hertz toggle
vsync_flag	ds.w	1

		ds.b	256
screens		ds.b	32000
		ds.b	160*48
bssend

	ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	endc

