*************************************************************************
*			NOT BAD LOOKING ADR MENU			*
*			------------------------			*
*									*
* Written By: SPACEMAN SPIFF						*
*									*
*									*
* Date: 13th November 1992						*
*									*
*									*
*									*
*									*
*************************************************************************

TBDR	equ	$fffffa21		;TimerB Data Register
TBCR	equ	$fffffa1b		;TimerB Control Register


	opt	o+,w-


YES=1
yes=1
NO=0
no=0

AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here


******************************* LEO ST-ST/AMIGA PDS *********************
DOWNLOAD=NO
	ifne	DOWNLOAD
	include	sttx1.s
	org	$1000
Code_Start
Exec_Addr
	ENDC
*************************************************************************


	ifeq	DOWNLOAD
***************************
	SECTION TEXT
***************************



*~~~~~~~~~~~~~~~~~~~~~~~ HERE GOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

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
	endc

	bsr	clear_bss
	ifeq	DOWNLOAD
	bsr	set_super		;set supervisor mode
	endc

	move.b	#$12,$fffffc02.w	;Disable mouse
	bsr	save_pal		;save old palette
	move.l	$44e.w,old_base		;get present screen base
	move.b	$ffff8260.w,org_rez
	bsr	black_out		;make all colours black
	bsr	print_titles		;game titles
	bsr	calc_screen		;calc our own screen address
	move.l	screen_1,a0		;new screen base
	clr.b	$ffff8260.w		;go into low rez
	move.l	screen_1,present_base
	move.l	screen_2,last_base
	bsr	flip_screen

	move.b	$484.w,old484		;save keyboard click/speed, etc
	clr.b	$484.w			;disable repeat/click/bell

	bsr	save_all

*****************************************************************************
************************ Chronicle Musics Demo ****************************
*****************************************************************************
                lea     song,a6
                jsr     player
                move.l  a6,play_isr



	bsr	set_palette		;set new colours
	bsr	set_isr
	bsr	show_pic
	bsr	flush			;flush keyboard buffer
main_loop
	bsr	flip_screen
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	scroll
;	move.w	pic+2,$ffff8240.w

	moveq	#0,d0

	move.b	$fffffc02.w,d0		;OLD but trusty key routine

	cmp.w	#01,d0			;escape?
	beq	exit			;yes get out...

	cmp.w	#$b,d0			;0 key
	beq	zero

	cmp.w	#$70,d0			;0 keypad
	beq	zero

check_keys
	lea	key_codes,a5
.loop	cmp.w	#-1,(a5)	;end of table?
	beq.s	main_loop	;yes
	cmp.w	(a5)+,d0	;is key one we want?
	beq.s	load		;yes so load demo
	move.w	(a5)+,d6	;NO so get offset
	bra.s	.loop		;check another key code


load	move.w	(a5),d0
	and.l	#$f,d0
	lea	filename_table,a0
	lsl.w	#2,d0		;multiply D0 by 4 (one long word)
	add.w	d0,a0
	move.l	(a0),a1		;get filename address

*** now move filename into $200 for AUTORUN4 to find
	lea	$200.w,a0
	movem.l	(a1),d0/d1/d2/d3	;move 16 bytes
	movem.l	d0-d3,(a0)		;into $200


	bsr	vsync			;shut the interrupts down

	move.w	#$2700,sr		;quick before she blows up!!
	move.l	old70,$70.w
	move.l	old_timerb,$120.w


	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	move.b	olda0d,$fffffa0d.w
	move.b	save0f,$fffffa0f.w
	move.b	save11,$fffffa11.w
	move.b	save13,$fffffa13.w
	move.b	olda15,$fffffa15.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,TBCR.w
	move.b	olda1d,$fffffa1d.w
	move.b	olda21,TBDR.w
	move.w	#$2300,sr

	move.l	old_base,d0		;put screen back to original
	lsr.l	#8,d0
	lea	$fffff8201.w,a0
	movep.w	d0,(a0)
	move.b	org_rez,$ffff8260.w	;go org rez for assembler/desktop
	movem.l	old_pal,d0-d7		;restore colours
	movem.l	d0-d7,$ffff8240.w
	move.b	#8,$fffffc02.w		;mouse back on
	move.b	old484,$484.w		;keyclick, etc
	bsr	flush			;clear keyboard buffer

*** now check hertz and exit cleanly...
	tst.w	hertz_switch		;has hertz been pressed?
	beq.s	hz50			;no so it stays in 50Hz
	eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50	move.b	#8,$fffffc02.w		;mouse back on

	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp


	ifeq	DOWNLOAD
	ifeq	AUTORUN4
	bra	exec
	ELSEIF
	clr.w	-(sp)		;exit to desktop
	trap	#1
	ENDC
	endc


zero	tst.w	zero_counter
	bne	check_keys
	eor.w	#$102,pic+2		;show a hertz change
	eor.w	#$ffff,hertz_switch	;toggle a check
	move.w	#10,zero_counter	;delay in between hertz switches
	bra	main_loop

exit	bsr	vsync			;shut the interrupts down
	move.b	org_rez,$ffff8260.w	;go org rez for assembler/desktop
	move.w	#$2700,sr		;quick before she blows up!!
	move.l	old70,$70.w
	move.l	old_timerb,$120.w

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	move.b	olda0d,$fffffa0d.w
	move.b	save0f,$fffffa0f.w
	move.b	save11,$fffffa11.w
	move.b	save13,$fffffa13.w
	move.b	olda15,$fffffa15.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,TBCR.w
	move.b	olda1d,$fffffa1d.w
	move.b	olda21,TBDR.w
	move.w	#$2300,sr

	move.l	old_base,d0		;put screen back to original
	lsr.l	#8,d0
	lea	$fffff8201.w,a0
	movep.w	d0,(a0)
	movem.l	old_pal,d0-d7		;restore colours
	movem.l	d0-d7,$ffff8240.w
	move.b	#8,$fffffc02.w		;mouse back on
	move.b	old484,$484.w		;keyclick, etc
	bsr	flush			;clear keyboard buffer

	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)			;assembler/desktop
	trap	#1			;BYE!


***************
* Subroutines *
***************

DEPTH	equ	32

scroll	move.l	last_base,a1
	lea	160*203(a1),a1
	lea	font_offsets,a2		;font lookup table
	lea	font,a3			;font itself
	move.l	scroll_pointer,a4	;pointer into text
	move.l	a4,a5

	moveq	#40,d5			;40 words across screen
	move.w	char_offset,d6		;char offset is a toggle
					;for bytes/words
	moveq	#0,d4
next_char
	move.b	(a5),d7			;get a letter
	sub.b	#32,d7			;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0		;find correct offset
	mulu	#8*DEPTH*4,d0	;8 bytes wide * DEPTH
	add.l	d0,a0		;add to font start
	move.w	d6,d0		;char offset
	mulu	#DEPTH*4,d0	;*DEPTH
	add.l	d0,a0		;we now point to character in A0

.column
OFF	set	0
	REPT	DEPTH
	move.l	(a0)+,d3
	movep.l	d3,OFF(a1)
	movep.l	d3,160+OFF(a1)
OFF	set	OFF+2*160		;go down 2 lines
	ENDR

	subq.w	#1,d5		;column value
	beq.s	.finish		;last column then finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next byte
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#7,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#7,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)		;is scroll text end?
	bpl.s	.end		;NO!
	lea	scroll_text,a4	;reset scroll text
.end	move.l	a4,scroll_pointer
	rts



********************
* SERVICE ROUTINES *
********************

flip_screen
	move.l	present_base,last_base
	move.l	screen_1,a0
	move.w	screen_number,d0
	beq	.1
	move.l	screen_2,a0
.1	move.l	a0,present_base
	eor.w	#-1,screen_number
	move.l	a0,d0
	lsr.l	#8,d0
	lea	$fffff8201.w,a0
	movep.w	d0,(a0)
	rts


flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts


vsync	move.w	#-1,vsync_flag		;custom routine to wait
vs	tst.w	vsync_flag		;for screen refresh
	bne.s	vs
	rts


set_super
	move.l	d7,user_stack

	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts


save_pal			;save old colours
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


set_palette	lea	pic+2,a0
set_p		lea	$ffff8240.w,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts


calc_screen	;calc our own screen address...
		lea	screen,a0
		move.l	a0,d0
		clr.b	d0
		move.l	d0,screen_1
		add.l	#49152,d0
		move.l	d0,screen_2
		rts

show_pic	lea	pic+34,a0
		move.l	present_base,a1
		move.l	screen_2,a2		;for flip screen

**********************************************************
;extend length of pic to 160*228 if titles are lowered
**********************************************************
		move.w	#160*200/4-1,d1

.copy		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d1,.copy
		rts


black_out	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts


clear_bss	lea	bss_start,a0
.clear		clr.l	(a0)+
		cmp.l	#bss_end,a0
		blt.s	.clear
		rts


save_all	move.l	$70.w,old70
		move.l	$120.w,old_timerb
		move.b	$fffffa07.w,olda07
		move.b	$fffffa09.w,olda09
		move.b	$fffffa0d.w,olda0d
		move.b	$fffffa0f.w,save0f
		move.b	$fffffa11.w,save11
		move.b	$fffffa13.w,save13
		move.b	$fffffa15.w,olda15
	 	move.b	$fffffa17.w,olda17
		move.b	$fffffa1b.w,olda1b
		move.b	$fffffa1d.w,olda1d
		move.b	$fffffa21.w,olda21
		rts

set_isr		ori.w	#$700,sr
		clr.b	$fffffa1d.w
		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w
		move.l	#new_vbl,$70.w
		move.l	#new_timerb,$120.w
		or.b	#1,$fffffa07.w

		clr.b	$fffffa09.w

		ori.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w		;enable auto A-INTERRUPT IN SERVICE clear
		move.w	#$2300,sr
		rts



*************************************************************************
*	NEW PRINT TITLES ROUT - NOW MASKS TO KEEP 16 COLOUR PIC		*
*									*
* Revision:	1.1							*
* Date:		6/9/92							*
* By:		MSD 							*
*									*
* More comments added to allow others to understand			*
*									*
*************************************************************************
*
* Now is fully masking to give black line around letters.
*
* Here is a little option to allow you to print the titles in any colour
* simply enable the planes you require..
*
* If you disable them all the titles will be colour 0


ENABLE_PLANE1	equ	yes
ENABLE_PLANE2	equ	yes
ENABLE_PLANE3	equ	yes
ENABLE_PLANE4	equ	yes

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#160*30,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(60*9),a3

		move.w	#16-1,d0	;max titles per menu
.loop		move.w	#20-1,d6	;40 across each line (I know it says 20 but it's 20 words)
.loop2		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#9,d1		;chars are 9 bytes each

BYTE_OFF	set	0
LINE_OFF	set	0

		REPT	9
		move.b	BYTE_OFF(a2,d1.w),d5	;get char
		move.b	BYTE_OFF(a3,d1.w),d3	;get char mask

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ELSE	
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d3,d4			;and mask with scrn data
		or.b	d5,d4			;or char data into mask
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d3,d4			;use same mask calculated previously
		or.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ENDC
		ENDC


BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR


BYTE_OFF	set	0
LINE_OFF	set	0
		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#9,d1		;chars are 8 bytes each

		REPT	9
		move.b	BYTE_OFF(a2,d1.w),d5
		move.b	BYTE_OFF(a3,d1.w),d3

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ELSE
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ENDC
		ENDC

BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR

		addq.w	#8,a0

		dbf	d6,.loop2
		lea	160*10(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts

*********
* ISRs  *
*********
new_vbl		move.w	#$2700,sr		;stop ISRs
		movem.l	d0-d7,-(sp)
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7
		move.w	d0,-(sp)
		move.w	#$57e,d0
.aaa		dbf	d0,.aaa
		clr.b	$ffff820a.w
		moveq	#1,d0
.bbb		dbf	d0,.bbb
		move.b	#2,$ffff820a.w
		move.w	(sp)+,d0
		movem.l	d0-a6,-(sp)
		clr.w	vsync_flag
		clr.b	TBCR.w
		move.b	#200,TBDR.w
		move.l	#new_timerb,$120.w
		move.b	#8,TBCR.w
		jsr	$DEADFACE
play_isr	equ	*-4

;sort raster bar here to save time in timerb
		lea	colours(pc),a0
		move.w	colour_offset,d0
		and.w	#127,d0
		lea	raster,a1
		rept	34
		move.w	0(a0,d0.w),(a1)+
		add.w	#2,d0
		and.w	#127,d0
		endr
		add.w	#2,colour_offset
		movem.l	(sp)+,d0-d7/a0-a6
		tst.w	zero_counter
		bne.s	.dec
		rte
.dec		sub.w	#1,zero_counter
		rte


SCROLLER_COLOUR	equ	$ffff8242

new_timerb	move.w	#$2700,sr
		movem.l	d0-a2,-(sp)
		lea	$ffff8209.w,a0
		move.b	#16,d2
.wait1		move.b	(a0),d3
		beq.s	.wait1
		sub.b	d3,d2
		lsl.b	d2,d3
		moveq	#25,d3
.wait2		dbf	d3,.wait2
		nop

		lea	raster,a0
		lea	$ffff8240.w,a1
		rept	34
		move.w	(a0)+,(a1)
		endr
		movem.l	font_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	pic+2,$ffff8240.w

		move.l	#new_timerb_part2,$120.w
		movem.l	(sp)+,d0-a2
		clr.b	TBCR.w
		move.b	#26,TBDR.w
		move.b	#8,TBCR.w
		move.w	#$2300,sr
		rte

new_timerb_part2
		clr.b	TBCR.w

		move.l	d0,-(sp)
		move.l	a0,-(sp)
		dcb.w	70,$4e71	;wait a while

		lea	$ffff8209.w,a0
.loop		move.b	(a0),d0
		beq.s	.loop

		dcb.w	36,$4e71	;wait a while

		clr.b	$ffff820a.w	;60Hz
	
		dcb.w	10,$4e71	;wait a while

		move.b	#2,$ffff820a.w	;50Hz
		move.l	(sp)+,a0
		move.l	(sp)+,d0
		rte



	ifeq	DOWNLOAD
******************************
	SECTION DATA
******************************
	endc

colour_offset	dc.l	0

colours
 dc.w	$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f,$80f
 dc.w	$10f,$90f,$20f,$a0f,$30f,$b0f,$40f,$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f,$f07,$f0e
 dc.w	$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03,$f0a,$f02,$f09,$f01,$f08,$f00,$f80,$f10,$f90
 dc.w	$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$660,$550,$440,$330,$220,$110,$000


scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "           ADRENALIN COMPACT DISK 29.   "
 DC.B "CREDITS FOR THIS DISK ARE AS FOLLOWS....   CODING BY   SPACEMAN SPIFF, "
 DC.B "   GRAFIX BY  BIOFEEDBACK,   MUSIC FROM CHRONICLES MUSIC DEMO. "
 dc.b "      GREETINGS TO    "
 DC.B "ANIMAL MINE,     "
 DC.B "ADMIRABLES,     "
 DC.B "ANTHRAX,     "
 DC.B "BREAKPOINT SOFTWARE,     "
 DC.B "CYNIX,     "
 DC.B "CRACKDOWN (ESP. INSPIRAL),     "
 DC.B "CHRIS H (YORK),     "
 DC.B "CHRIS H (MID GLAM),     "
 DC.B "CHRIS H (STAFFS),     "
 DC.B "D-BUG,     "
 DC.B "ELITE,     "
 DC.B "THE EDGE,     "
 DC.B "(E) TRIPPER,     "
 DC.B "FUZION,     "
 DC.B "HOTLINE (ESP. SIDEWINDER),     "
 DC.B "KGB,      "
 DC.B "MAD VISION,     "
 DC.B "MUG U.K.,     "
 DC.B "MICRO MANIAC,     "
 DC.B "PERSISTENCE OF VISION (ESP. MAC SYS DATA AND BORIS),     "
 DC.B "POMPEY PIRATES,     "
 DC.B "PULSION,     "
 DC.B "PURE ENERGY,     "
 DC.B "REPLICANTS,     "
 DC.B "RIPPED OFF (ESP. STICK AND BILBO),     "
 DC.B "RED LICHTIE,     "
 DC.B "SYNDICATE,     "
 DC.B "SUPERIOR,     "
 DC.B "SPECIAL FX,     "
 DC.B "SAFARI (ESP. PANTHER AND RHINO),     "
 DC.B "SCANZ,     "
 DC.B "SONIC,     "
 DC.B "TIM,     "
 DC.B "UNTOUCHABLES (ESP. MAT)   AND   "
 DC.B "WILD! (ESP. SNAZ)     "
 DC.B "                          "
 DC.B "                          "
 dc.b $ff
	even


font_pal	dc.w	$000,$200,$300,$400,$510,$520,$620,$630
		dc.w	$730,$740,$750,$760,$770,$774,$776,$777

font	dcb.b	DEPTH*8*4,0
	incbin	big1.fnt
	incbin	big2.fnt

	even
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,46,48,00,00,00,00,48,41,42,44,00,27,43,28,45

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	31,32,33,34,35,36,37,38,39,40,30,29,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,41,00,42,00,00,48,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z
 dc.b	22,23,24,25,26

	even


****************************************************************
player	incbin	BLIPBLOP.ROT
	EVEN
song	incbin	SONG16
****************************************************************

	even

pic	incbin	pic.PI1			;main menu pic
	dcb.b	160*50,0


screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"        EXCELLENT COMPILATION 29        "
	dc.b	"                                        "
	dc.b	"        1: ASTEROIDS                    "
	dc.b	"        2:                              "
	dc.b	"        3:                              "
	dc.b	"        4:                              "
	dc.b	"        5:                              "
	dc.b	"        6:                              "
	dc.b	"        7:                              "
	dc.b	"        8:                              "
	dc.b	"              0: 50/60 HZ               "
	even

screen_titles_font
 dc.l	0,0,$1E1E,$1E1E001E,$1E000014,$14000000,0,$93F1212,$7F242400,$1C2A28
 dc.l	$1C0A2A1C,$113A,$1204050B,$100003C,$62386266,$663C0000,$C0C0000,0
 dc.l	$60C0C,$C0C0C06,$180C,$C0C0C0C,$18000000,$10543854,$10000000,$8083E
 dc.l	$8080000,0,$81800,0,$3C0000,0,$C,$C000000,$2040408,$8100000
 dc.l	$3C7E66,$66667E3C,$1838,$18181818,$1800003C,$7E060C18,$3E7E0000,$7E0C181C
 dc.l	$6463C00,$E1626,$467F0606,$7E60,$7C06467E,$3C00003C,$607C6666,$7E3C0000
 dc.l	$7E7E060C,$18181800,$3C7E66,$3C667E3C,$3C7E,$66663E06,$3C000000,$C0C000C
 dc.l	$C000000,$C0C00,$C0C1800,$60C18,$30180C06,$3F,$3F003F3F,$18
 dc.l	$C060306,$C180000,$3C460C18,$18001800,$3C425E,$725C403E,$3C7E,$667E7E66
 dc.l	$6600007C,$7E667C66,$7E7C0000,$3C7E6660,$667E3C00,$7C7E66,$66667E7C,$7E7E
 dc.l	$607C607E,$7E00007E,$7E607C7C,$60600000,$3C7E606E,$667E3C00
 dc.l	$66667E,$7E7E6666,$1818,$18181818,$18000006,$6060666,$7E3C0000,$666C7870
 dc.l	$786C6600,$606060,$60607E7E,$6377,$7F7F6B63,$63000066,$767E7E6E,$66660000
 dc.l	$3C7E6666,$667E3C00,$7C7E66,$667C6060,$3C7E,$6666666C,$3600007C,$7E667C7E
 dc.l	$66660000,$3C7E3018,$C7E3C00,$7E7E18,$18181818,$6666,$6666667E,$3C000066
 dc.l	$66666666,$7C780000,$5A5A5A5A,$5A7E7C00,$666666,$3C666666,$6666,$663C1818
 dc.l	$1800007E,$7E0C1830,$7E7E0000,0,0,$FFFFFFFF,$FFFFFFFF,$FFC0C0C0
 dc.l	$C0C0C0C0,$C0C0C1C1,$C1C1FFFF,$FFFFFFE0,$80808000,$8181,$C1808080,$80808080
 dc.l	$C1C48080,$80C0E0E0,$E0FC8100,0,$81E1,$E1E1E1FF,$FFFFFFFF,$F0E0E0E1
 dc.l	$E1E1E0E0,$F0C3C1C1,$E1E1E1C1,$C1C3FFC7,$1010101,$1C7FFFF
 dc.l	$E3E38080,$80E3E3FF,$FFFFFFFF,$E3C3C3C3,$FFFFFFFF,$818181FF
 dc.l	$FFFFFFFF,$FFFFE1E1,$E1E1FFF8,$F0F0E1E1,$C3C3C7FF,$81000000
 dc.l	0,$81C38383,$83C3C3C3,$C3C38100,$C080,0,$C1C0,$81,$E0C08000,$F0
 dc.l	$F0000000,0,$818101,$1000000,$8100,$C0,$C1C3C3C3,$81000000
 dc.l	0,$81810000,$80,$8081FFE1,$E1E1E1E1,$E1E1FFFF,$E1E1E1E1,$E1C1C1C3
 dc.l	$F0E0C081,$8381C0E0,$F0FF8080,$80808080,$80FFC3C1,$C0E0F0E0
 dc.l	$C0C1C381,$C1,$C3C3C3C3,$81000000,0,$80810000,0,$100,0,$181,0,$81
 dc.l	$1000000,0,$1000000,$10000,0,$101,$10F0F81,0,$81,0,0,$C3C3C3
 dc.l	$C3C3C3C3,$C3C3F0F0,$F0F00000,$8100,$103,$1000000,$F0F0F0F,$F000000
 dc.l	$80000,0,$8080000,0,$81,0,$81,$1000000,$10F,$F810000,0,$800100
 dc.l	0,$81,$81,$81,0,$C3C3C3C3,$C3000000,0,$810000,0,$10300,0,1,0,0,0
 dc.l	$81C3,$C3C30000,$8100,$FF,$FFFFFFFF,$FFFFFFFF
		even


	even
********** valid key press table
key_codes		;comment out keys you don't want to use
	dc.w	2,0	;key 1
	dc.w	3,1	;key 2
	dc.w	4,2	;key 3
	dc.w	5,3	;key 4
	dc.w	6,4	;key 5
	dc.w	7,5	;key 6
	dc.w	8,6	;key 7
	dc.w	9,7	;key 8
;	dc.w	10,8	;key 9

	dc.w	$6d,0	;keypad 1
	dc.w	$6e,1	;keypad 2
	dc.w	$6f,2	;keypad 3
	dc.w	$6a,3	;keypad 4
	dc.w	$6b,4	;keypad 5
	dc.w	$6c,5	;keypad 6
	dc.w	$67,6	;keypad 7
	dc.w	$68,7	;keypad 8
;	dc.w	$69,8	;keypad 9

	dc.w	-1	;end of table
	even


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5
		dc.l	filename6
		dc.l	filename7
		dc.l	filename8
;		dc.l	filename9


**** If using POV AUTORUN and you wish to exit to the desktop simply
**** start the filename off with $$
****

filename1	dc.b	"ISHAR.ADR",0
	even
filename2	dc.b	"$$ISHAR_CE.PRG",0
	even
filename3	dc.b	"\DOCS\1.ADR",0
	even
filename4	dc.b	"\DOCS\2.ADR",0
	even
filename5	dc.b	"\DOCS\3.ADR",0
	even
filename6	dc.b	"\DOCS\4.ADR",0
	even
filename7	dc.b	"\DOCS\5.ADR",0
	even
filename8	dc.b	"\DOCS\6.ADR",0
	even
;filename9	dc.b	"",0
;	even



	ifeq	DOWNLOAD
*************************
	SECTION BSS	
*************************
	endc

bss_start
user_stack	ds.l	1

old_base	ds.l	1		;old screen address
old484		ds.w	1
stack_save	ds.l	1

old_pal		ds.b	32		;old colours
raster		ds.w	34

zero_counter	ds.w	1
screen_number	ds.w	1
present_base	ds.l	1
last_base	ds.l	1
screen_1	ds.l	1
screen_2	ds.l	1
vsync_flag	ds.w	1
key		ds.w	1

*** store for old ISR data
old70		ds.l	1
old_timerb	ds.l	1
olda07		ds.b	1
olda09		ds.b	1
olda0d		ds.b	1
olda15		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda1d		ds.b	1
olda21		ds.b	1
save0f		ds.b	1
save11		ds.b	1
save13		ds.b	1
	even
black			ds.b	32	;32 bytes of nothing...

char_offset		ds.w	1

org_rez			ds.w	1	;original rez
hertz_switch		ds.w	1	;hertz toggle check



	ds.b	256		;workspace so screen in on 256 bytes boundry
screen	ds.b	49152		;two screens
	ds.b	49152
bss_end


	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
