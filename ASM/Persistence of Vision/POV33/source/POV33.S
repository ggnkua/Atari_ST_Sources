*************************************************************************
*				POV 33					*
*				------					*
*									*
*									*
*									*
* Written by:	Mac Sys Data						*
*									*
* Date:		4-8-90							*
*									*
* Revisited code: 11-1-98						*
*									*
*									*
*									*
*									*
*									*
*									*
*************************************************************************
; Special menu with ISR driven scrolline

BUFFER_SIZE	EQU	17*4
WIDTH		EQU	24

******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
NO	equ	0
yes=YES
no=NO
DOWNLOAD	equ	no
	ifne	DOWNLOAD
	include	transmit.s
	org	$20000
Code_Start
Exec_Addr
	ENDC

AUTORUN4=no	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

	opt	o+,w-
	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset		;always reset on return from prog
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts

blank	dc.l	0

*******************************************************************
start	move.l	4(a7),a0
	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	ENDC



*first clear BSS as some packers do not do this.
		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
clearbss	clr.b	(a0)+
		sub.l	#1,d0
		bne.s	clearbss


		ifeq	DOWNLOAD
		bsr	set_super
		endc

		ifeq	DOWNLOAD
;set for reset pic
		move.l	$502.w,old502
		move.l	#null,$502.w
		move.l	#$31415926,$426.w
		move.l	#reset,$42a.w
		endc

		bsr	set_up

		lea	pic+34+(160*132)+128,a1
		bsr	pl		;put logo onto picture before showing pic
		bsr	transfer	;show screen

main_loop
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	clear_bouncer
	bsr	bouncer
;	move.w	pic+2,$ffff8240.w

	move.w	key,d0

	ifeq	DOWNLOAD
	cmp.w	#1,d0		;ESC
	beq	exit
	endc

	cmp.w	#11,d0		;0 keyboard
	beq	zero

	cmp.w	#$70,d0		;0 keypad
	beq	zero

	cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
	beq	reseta

	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	main_loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run	lsr.w	#8,d1
	and.w	#$f,d1
	lsl.w	#2,d1
	lea	filename_table,a0
	move.l	(a0,d1.w),a0
	lea	$200.w,a1
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

	tst.w	hertz_toggle
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50
exit
	move.w	#$2700,sr		;stop interrupts
	lea	storage,a0		;restore old settings
	move.l	(a0)+,$70.w		;vbl
	move.l	(a0)+,$118.w		;keyboard
	move.l	(a0)+,$120.w		;hbl
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
 	move.b	(a0)+,$fffffa1b.w
 	move.b	(a0)+,$fffffa21.w
	move.l	old502,$502.w
	clr.l	$426.w			;stop another reset
	clr.l	$42a.w

	lea	$ffff8800.w,a0	;turn sound chip off
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	move.w	#$2300,sr	;re-enable interrupts

	move.l	old_base,a0
	bsr	set_org_rez
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#$8,$fffffc02.w
	move.b	old484,$484.w

	ifeq	DOWNLOAD
	bsr	user_mode
	endc

	ifne	DOWNLOAD
	move.l	4.w,-(sp)
	rts
	endc

	ifeq	AUTORUN4
	bra	exec
	endc

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1

zero	;flip hertz indicator...
	tst.w	hertz_delay
	bne	main_loop
	eor.w	#$009,pic+2
	eor.w	#-1,hertz_toggle
	move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
	bra	main_loop


reseta	move.l	4.w,-(sp)
	rts



***************
* Subroutines *
***************
scroll		tst.w	delay
		beq.s	carry_on
		sub.w	#1,delay
		rts
carry_on	move.l	line_ptr,a6
		cmp.b	#$7f,(a6)
		bne.s	no_delay
		add.l	#1,line_ptr
		move.w	#80,delay
		rts
no_delay	cmp.b	#$ff,(a6)
		bne	not_wrap_scroll
		lea	scroll_line,a6	;restart message
		move.l	a6,line_ptr
not_wrap_scroll	tst.w	scroll_number
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
		rept	17
		move.l	(a6)+,(a1)+
		endr

loop2		move.l	screen_base,a6
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
loop		moveq	#0,d0	
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
		add.w	#160,a2	;increase screen
		dbf	d2,loop
null		rts


clear_bouncer	move.l	screen_base,a0
		lea	132*160+128(a0),a0
		move.w	#68-1,d0
		moveq	#0,d1
.loop		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		add.w	#160-32,a0
		dbf	d0,.loop
		rts

bouncer		move.l	bounce_pos,a0
		cmp.b	#-1,(a0)
		bne.s	.no_reset
		lea	bounce_table,a0
		move.l	a0,bounce_pos
.no_reset	moveq	#0,d0
		move.b	(a0)+,d0
		move.l	a0,bounce_pos
		mulu	#160,d0
		move.l	screen_base,a1
		add.w	d0,a1
		add.w	#128,a1
pl		lea	logo,a0
		move.w	#39-1,d0
.loop		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		add.w	#160-32,a1
		dbf	d0,.loop
		rts


set_up	move.b	#$12,$fffffc02.w	;disable mouse

	movem.l	$ffff8240.w,d0-d7	;save old palette
	movem.l	d0-d7,old_pal

	movem.l	pic+2,d0-d7		;set new palette
	movem.l	d0-d7,$ffff8240.w

	move.w	#3,-(sp)		get_base
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base

	move.w	#4,-(sp)		get_rez
	trap	#14
	addq.l	#2,sp
	move.w	d0,old_rez

	move.l	#screen,d0		;calc new screen address from BSS
	clr.b	d0
	move.l	d0,screen_base		;save it

	move.l	screen_base,a0		;go for low rez
	bsr	set_low_rez

	move.b	$484.w,old484		;store old keyboard info

	move.w	#16,scroll_number	;set up scroller

	ori.w	#$700,sr
	lea	storage,a0
	move.l	$70.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
 	move.b	$fffffa1b.w,(a0)+
 	move.b	$fffffa21.w,(a0)+
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w

	moveq	#1,d0			;init tune
	bsr	tune

	move.l	#new_vbl,$70.w
	move.l	#new_kbd,$118.w		;our new keyboard
	move.l	#horiz_isr,$120.w

	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	bclr	#3,$fffffa17.w		;auto ISR enable at RTE
	clr.b	$fffffa1b.w		;di timer B
	clr.b	$fffffa21.w		;clr timer B data
	move.w	#$2300,sr
	rts

set_super
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

user_mode
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


set_org_rez	move.w	old_rez,-(sp)
		bra.s	set_rez
set_low_rez	clr.w	-(sp)
set_rez		move.l	a0,-(sp)
		move.l	a0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

isr_off	move.w	#$2700,SR
	lea	storage,a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
 	move.b	(a0)+,$fffffa1b.w
 	move.b	(a0)+,$fffffa21.w
	move.l	old502,$502.w
	clr.l	$426.w	;stop another reset
	clr.l	$42a.w

	lea	$ffff8800.w,a0	;turn sound chip off
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	move.w	#$2300,sr	;re-enable interrupts
	rts


transfer
	lea	pic+34,a0	;pic top left
	move.l	a0,a2
	add.w	#80,a0
	add.w	#72,a2		;pic top right
	move.l	screen_base,a1
	move.l	a1,a3
	add.w	#80,a1
	add.w	#72,a3
	move.w	#10-1,d5
words	move.l	#%10000000000000001000000000000000,d1
	move.l	#%00000000000000010000000000000001,d2
	move.w	#16-1,d7
bit	bsr	vsync
	move.w	#199,d6
lines	move.l	(a0),d0
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
	
vsync	move.w	#-1,vsync_flag
.sync	tst.w	vsync_flag
	bne	.sync
	rts

*********
* ISRs  *
*********
new_kbd		move.l	d0,-(sp)		;new keyboard routine
		move.b	$fffffc02.w,d0
		cmp.b	#$1d,d0
		bne.s	.k1
		bset	#2,key
.k1		cmp.b	#$9d,d0
		bne.s	.k2
		bclr	#2,key
.k2		cmp.b	#$38,d0
		bne.s	.k3
		bset	#3,key
.k3		cmp.b	#$b8,d0
		bne.s	.k4
		bclr	#3,key
.k4		move.b	d0,key+1
		bclr	#6,$fffffa11.w
		move.l	(sp)+,d0
		rte






new_vbl
	clr.b	$fffffa1b.w
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	clr.w	vsync_flag
	bsr	scroll
	bsr	tune+$8
	movem.l	(sp)+,d0-d7/a0-a6

	move.l	#horiz_isr,$120.w
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w

	tst.w	hertz_delay
	bne.s	dec_hertz
	rte
dec_hertz
	subq.w	#1,hertz_delay
	rte

horiz_isr	clr.b	$fffffa1b.w
		move.l	d0,-(sp)
		REPT	50
		nop
		ENDR
		moveq	#0,d0
.loop		cmp.b	$ffff8209.w,d0
		bne.s	.loop
		clr.b	$ffff820a.w	;60 hertz
		REPT	22
		nop
		ENDR
		move.b	#2,$ffff820a.w	;back to 50 hertz

		move.w	pic+2,$ffff8240.w

		move.l	a0,-(sp)
		lea	pal_table,a0
		move.w	#22-1,d0
col_loop	move.w	(a0)+,$ffff8242.w
		REPT 120
		nop
		ENDR
		dbf	d0,col_loop
		move.l	(sp)+,a0
		move.l	(sp)+,d0
		rte

;reset routine
reset		move.w	#$2700,sr
		move.l	storage,$70.w
		move.l	storage+4,$118.w
		move.l	storage+8,$120.w
		move.l	#tune+8,$4da
		lea	$80000,sp
		move.b	#7,$ffff8201	;set screen address to $70000
		move.b	#0,$ffff8203
		move.b	#0,$ffff8260	;low rez
		movem.l	reset_pic+2,d0-d7	;set palette
		movem.l	d0-d7,$ffff8240.w
		lea	reset_pic+34,a0
		lea	$70000,a1
		move.w	#32000/4-1,d0
hi		move.l	(a0)+,(a1)+
		dbf	d0,hi
		move.b	#2,$ffff820a.w	;50hz
		move.w	#$2300,sr
		clr.l	$426.w	;stop another reset
		clr.l	$42a.w
here		bra.s	here

	ifeq	DOWNLOAD
*************************************
	SECTION DATA
*************************************
	endc

pal_table
	dc.w	0,0,0
	dc.w	$123
	dc.w	$124,$125,$126,$127,$137,$237,$247,$347
	dc.w	$357,$457,$467,$567,$577,$677,$777,$fff

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"demo1.prg",0
	even
exec2	dc.b	"GALTAN09.DMC",0
	even
exec3	dc.b	"DEAD",0
	even
exec4	dc.b	"PHF",0
	even
exec5	dc.b	"ST_CNX",0
	even
exec6	dc.b	"M_CODER",0
	even
exec7	dc.b	"POWER",0
	even
exec8	dc.b	"copier.pov",0
	even





line_ptr	dc.l	scroll_line
buffer		dcb.b	BUFFER_SIZE,0

scroll_line
 dc.b "HELLO FANS, MAC SYS DATA HERE WITH P.O.V. 33.    "
 dc.b "GREETINGS TO... THE REPLICANTS,   AN-COOL (PLEASE TAKE "
 DC.B "THE BUGS OUT OF YOUR TRACKER),   THE LOST BOYS,   "
 DC.B "DTB,   DR.SYNE   AND   THE DEMO CLUB.     "
 DC.B "ALL CODING BY M.S.D., MUSIC BY MAD THE ACE MAX FROM SO-WATT, "
 DC.B "GFX BY OZ.       P.O.V. CONSISTS OF M.S.D. (CODER/HACKER/PACKER),   "
 DC.B "BORIS (CODER),   OZ (GRAPHIX)   AND   ALY (GRAPHIX PART TIMER).   "
 DC.B "BORING SCROLLER THIS ONE - I CAN'T BE BOTHERED TO TYPE MUCH "
 DC.B "TODAY SO YOU CAN LISTEN TO THE TUNE AND WATCH SOME DOTS....."
 DC.B "........................................."
 DC.B "........................................."
 DC.B "    OR MAYBE SOME MINUS SIGNS ----------------"
 DC.B "-----  HAD ENOUGH?      YEH SO HAVE I.      "
 dc.b "RIGHT A QUICK TALK ON THE SUBJECT OF SOUNDTRACKERS... "
 DC.B "THESE PROGRAMS HAVE STORMED THE ST WITH THE MOST FAMOUS "
 DC.B "BEING THE TCB TRACKER (FULL OF BUGS!!!) BUT THERE ARE OTHER "
 DC.B "TRACKERS AROUND. THE ORIGINAL WAS OF COURSE QUARTET WHICH IS "
 DC.B "NOT BAD BUT IT MAKES THINGS SOUND TINNY, THE OTHER ONE YOU "
 DC.B "WILL HAVE HEARD OF IS THE ST CONNEXIONS SOUND TRACKER (DEMO VERSION ON POV 22). "
 DC.B "THE SOUND QUALITY IS VERY GOOD BUT AT PRESENT YOU "
 DC.B "CANNOT MAKE YOUR OWN MODULES 'COS THE TRACKER PROGRAM HASN'T BEEN RELEASED YET!   "
 DC.B "ONE LAST ONE TO MENTION IS THE EQUINOX TRACKER, THE TRACKER "
 DC.B "PROGRAM ISN'T OUT YET BUT WHO NEEDS IT WHEN THE EQUINOX "
 DC.B "TRACKER WILL PLAY AMIGA MODULES DIRECTLY WITHOUT ANY MODIFICATIONS? "
 DC.B "  P.O.V. HAVE WRITTEN A MENU PROGRAM USING THE EQUINOX REPLAY "
 DC.B "ROUTINE (DIRECT COPY OF THE AMIGA REPLAY ROUTINE WITH A COUPLE "
 DC.B "OF REWRITTEN BITS 'COS WE AIN'T GOT THE AGNES CHIP!).  THE RESULTS "
 DC.B "CAN BE SEEN BY GETTING THE SOUNDTRACKER DISCS FROM THE 'DEMO CLUB' "
 DC.B "AT  23 ALMA PLACE,   SPILSBY,   LINCS.    'THE DEMO CLUB' IS A "
 DC.B "PD LIBRARY AND THE OFFICIAL DISTRIBUTOR OF P.O.V. DISCS. BOTH "
 DC.B "JOHN AT THE DEMO CLUB AND I (MAC SYS DATA) OWN AMIGAS SO WE "
 DC.B "CAN STEAL MODULES AND PORT THEM OVER TO THE ST USING THE RS232. "
 DC.B "IF YOU WISH TO HEAR A SOUNDTRACKER THEN GET P.O.V. 24 'COS "
 DC.B "I BOLTED A MODULE TO THE MENU.    "
 DC.B "WELL SOD THIS 'COS IT'S GETTING LATE AND I'M OFF OUT TO THE PUB "
 DC.B "ON MY MOTORCYCLE (WHICH I FIXED YESTERDAY AFTER 4 WEEKS OFF "
 DC.B "THE ROAD)  "
 DC.B "BYE - TIME TO WRAP.                                  "
	dc.b	$ff
	even

bounce_pos
	dc.l	bounce_table
bounce_table
	dc.b	132,132,132,133,135,137,140,144,149,155,161
	dc.b	155,149,144,140,137,135,133,$ff	
	even
font	incbin	font.dat
	even
tune	incbin	SOWHAT.MUS
	even
pic	incbin	pov33.PI1
	even
logo	incbin	pov.dat
	even

reset_pic	incbin	nose_tad.pi1
	even

	ifeq	DOWNLOAD
	SECTION BSS
	endc
bssstart
old_pal		ds.b	32
vsync_flag	ds.w	1
screen_base	ds.l	1
old484		ds.w	1
scroll_number	ds.w	1
stack_save	ds.l	1
hertz_toggle	ds.w	1	;hertz toggle
old502		ds.l	1
storage		ds.b	16
	even
old_base	ds.l	1
old_rez		ds.w	1
key		ds.w	1
hertz_delay	ds.w	1
delay		ds.w	1

	ds.b	256
screen	ds.b	32000

bssend
	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
