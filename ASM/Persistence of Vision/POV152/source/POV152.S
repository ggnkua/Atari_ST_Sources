*************************************************************************
*			PERSISTENCE OF VISION 152			*
*			-------------------------			*
*									*
*									*
*									*
* Written By: 	MAC SYSTEM DATA of PERSISTENCE OF VISION		*
*									*
*									*
* Date:		7th Feb 1994 for Pure Energy, revamped for POV March 96	*
*									*
*									*
* Music by: 	ISO of SENTRY						*
*									*
*									*
*									*
*		All code ½ P.O.V. 1992,1993,1994,1996			*
* 									*
*************************************************************************

	opt	o+,w-

yes=1
no=0
YES=yes
NO=no

AUTORUN4=no	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here
		;If AUTORUN4 is used you can exit to the desktop to
		;double click a program or use the POV autogem/d_click.prg

DOWNLOAD=no

FINAL=yes
		ifne	DOWNLOAD
		include	"transmit.s"
		org	$20000
Code_Start
Exec_Addr
		endc

		ifeq	AUTORUN4
begin		bra	start
		ds.l	100
ustack		ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec		pea	blank(pc)
		pea	blank(pc)
		pea	$200
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	.reset(pc)		;always reset on return from prog
		move.w	#$26,-(sp)
		trap	#14
.reset		move.l	4.w,-(sp)
		rts

blank		dc.l	0

*******************************************************************
start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		ENDC

		bsr	set_up

main_loop	bsr	vsync
		bsr	set_screen	;screen flip
;		move.w	#$123,$ffff8240.w
		jsr	music+2
		bsr	scroll
		bsr	rippler
;		move.w	pic+2,$ffff8240.w

		move.w	key,d0

		ifeq	FINAL
		cmp.w	#$01,d0
		beq	assem
		endc

		cmp.b	#$b,d0			;0 key
		beq	zero

check_keys	lea	key_codes,a6
.loop		cmp.b	#$ff,(a6)	;end of table?
		beq.s	main_loop	;yes
		cmp.b	(a6)+,d0	;is key one we want?
		beq.s	load		;yes so load demo
		move.b	(a6)+,d6	;NO so get offset
		bra.s	.loop		;check another key code

load		move.b	(a6),-(sp)
		bsr	shut_down
		moveq	#0,d0
		move.b	(sp)+,d0	;get key value off stack

		lea	filename_table,a0
		lsl.w	#2,d0		;multiply D0 by 4 (one long word)
		add.w	d0,a0
		move.l	(a0),a1		;get filename address

*** now move filename into $200 for AUTORUN4 to find
		lea	$200.w,a0
		movem.l	(a1),d0-d3	;move 16 bytes
		movem.l	d0-d3,(a0)		;into $200

*** now check hertz and exit cleanly...
		tst.w	hertz_switch		;has hertz been pressed?
		beq.s	hz50			;no so it stays in 50Hz
		eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50

		ifeq	DOWNLOAD
		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		endc

		ifeq	AUTORUN4
		bra	exec
		ELSE
		clr.w	-(sp)		;exit to desktop
		trap	#1
		ENDC

assem		bsr	shut_down
		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#8,sp
		clr.w	-(sp)
		trap	#1

zero		tst.w	zero_counter
		bne	check_keys
		eor.w	#$002,hertz_switch	;show a hertz change
		move.w	#10,zero_counter	;delay in between hertz switches
		bra	main_loop


*******************
* CUSTOM ROUTINES *
*******************
DEPTH	equ	32
WIDTH	equ	8
ANDVALUE	equ	WIDTH-1
scroll	move.l	scr_now,a1
	lea	64*160(a1),a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	moveq	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#WIDTH*DEPTH,d0
	add.w	d0,a0
	move.w	d6,d0
	mulu	#DEPTH,d0
	add.w	d0,a0

.column
OFF	set	0
	REPT	DEPTH
	move.b	(a0),OFF(a1)
	move.b	(a0)+,OFF+160(a1)
OFF	set	OFF+320
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#ANDVALUE,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#ANDVALUE,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts


RIPPLER_WIDTH	equ	12
RIPPLER_DEPTH	equ	50

rippler		move.l	ripple_table_pos,a3
		cmp.l	#reset_ripple_flag,a3
		blt.s	.do_rout
		move.l	#ripple_table,ripple_table_pos
.do_rout	lea	ripple_data,a4
		move.l	scr_now,a5	move.l	last_base,a5
		add.l	#160*140+2,a5
		move.w	#RIPPLER_DEPTH-1,d2
.loop		move.b	(a3)+,d0	;word offset
		move.b	(a3)+,d1	;pixel offset
		move.l	a5,a1
		move.l	a4,a0
		and.w	#$f,d0		;mask off word value
		lsl.w	#3,d0		;word offset *8
		and.w	#$f,d1		;mask off pixels value
		mulu	#RIPPLER_WIDTH*2*RIPPLER_DEPTH,d1	;ripple number
		add.w	d1,a0
		add.w	d0,a1
offset		set	0
		rept	RIPPLER_WIDTH
		move.w	(a0)+,offset(a1)
offset	set	offset+8
		endr
		add.w	#RIPPLER_WIDTH*2,a4
		lea	160(a5),a5
		dbf	d2,.loop
		addq.l	#2,ripple_table_pos
		rts




shift_logo	lea	ripple_data,a1
		move.w	#16-1,d1
.loop2		lea	pic+34+160*134,a0
		move.w	#RIPPLER_DEPTH-1,d0
OFF		set	0
.loop		REPT	RIPPLER_WIDTH
		move.w	OFF(a0),(a1)+
OFF		set	OFF+8
		ENDR
		lea	160(a0),a0
		dbf	d0,.loop

		lea	pic+34+160*134,a0
		move.w	#RIPPLER_DEPTH-1,d2
		sub.w	d0,d0		;clear carry flag before shifting
OFF		set	0
.scroll		REPT	RIPPLER_WIDTH
		roxr.w	OFF(a0)
OFF		set	OFF+8
		ENDR

		lea	160(a0),a0
		dbf	d2,.scroll
		dbf	d1,.loop2
		rts

clear_logo	lea	pic+34+160*134,a0
		move.w	#RIPPLER_DEPTH-1,d0
.clear
off	set	0
		rept	20
		clr.w	off(a0)		;use clr as code does not have to be fast
off	set	off+8
		endr
		lea	160(a0),a0
		dbf	d0,.clear
		rts


*************************************************************************
*	NEW PRINT TITLES ROUT - NOW MASKS TO KEEP 16 COLOUR PIC		*
*									*
* Revision:	1.2 - now supports 6*6 font				*
* Date:		20/10/92						*
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


ENABLE_PLANE1	equ	no
ENABLE_PLANE2	equ	no
ENABLE_PLANE3	equ	yes
ENABLE_PLANE4	equ	yes

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#160*(128),a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

		move.w	#12-1,d0	;max titles per menu
.loop		move.w	#20-1,d6	;40 across each line (I know it says 20 but it's 20 words)
.loop2		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#6,d1		;chars are 12 bytes each

BYTE_OFF	set	0
LINE_OFF	set	0

		REPT	6
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

		mulu	#6,d1		;chars are 6 bytes each

		REPT	6
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

		lea	8(a0),a0
		dbf	d6,.loop2
		lea	160*6(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts


***********************
* SUBROUTINES SECTION *
***********************
vsync		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		rts

set_up		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
.clr_bss	clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.clr_bss

		ifeq	DOWNLOAD
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		move.w	#$2300,sr

		move.b	#$12,$fffffc02.w	;DI mouse

		move.l	$44e.w,screen_base	;get screen base

		move.w	#4,-(sp)
		trap	#14
		addq.w	#2,sp
		move.w	d0,original_rez		;get_original_rez

		bsr	test_for_falcon
		tst.w	falcon_flag
		beq.s	.no_falcon

		move.w	#-1,-(sp)
		move.w	#$58,-(sp)	;get_original_rez
		trap	#14
		addq.l	#4,sp
		move.w	d0,org_falcon_rez

;This bit will automatically set the falcon video res but it will
;preserve the RGB/VGA mode.
;			  fedcba9876543210
;Octet de poids faible :   S O P V 8 N N N
		move.w	d0,d1
		and.w	#%00010000,d1
		move.w	#%0000000010100010,d0
		or.w	d1,d0
		move.w	d0,-(sp)
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp

;Octet de poids faible :    S O P V 8 N N N
;	N  Bits par pixels :	4 -> 16 bits	65536 colours
;				3 -> 8  bits	256 colours
;				2 -> 4  bits	16 colours
;				1 -> 2  bits	1 colours
;				0 -> 1  bit
;	8 Flag 80 colonnes :	1 -> mode 80 colonnes
;				0 -> mode 40 colonnes
;	V Flag VGA         :	1 -> mode moniteur VGA
;				0 -> mode TV
;	P Flag PAL         :	1 -> mode PAL
;				0 -> mode NTSC
;	O Flag Overscan    :	1 -> Overscan ON (impossible en VGA)
;				0 -> Overscan OFF

;Where 'mode' looks like this:-
;    bits            meaning
;    0-2             These bits form a value so that 2^X represents the 
;                    number of bits/pixel
;    3               80 coloun flag (if set, 80 columns, otherwise 40)
;    4               VGA Flag (if set, VGA mode, if not TV/RGB mode) 
;    5               PAL Flag (if set, PAL mode, otherwise NTSC)
;    6               Overscan Flag (not valid with VGA)
;    7               ST compatibility flag
;    8               Vertical flag (if set, enables interlace mode on a         
;                    colour monitor or double line mode on a VGA monitor)
;    9-15            Reserved (set 0)

	bra.s	.over


.no_falcon
		move.w	#3,-(sp)	;go for low rez
		move.w	#0,-(sp)
		move.l	#-1,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp
.over

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w	;set pal

		clr.w	$ffff8242.w		;fiddle it!!
		move.w	#$0777,$ffff8246.w

		move.w	#$25,-(sp)		;sync b 4 low rez
		trap	#14
		addq.w	#2,sp

		move.l	#screens,d0		;calc our screen addrs
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		bsr	shift_logo
		bsr	clear_logo

		bsr	print_titles		;print those stupid bits of text!

		lea	pic+34,a0		;show pic
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

		bsr	set_screen

		moveq	#1,d0			;init music
		jsr	music

		move.w	#$2700,sr		;store old regs
		lea	storage,a0
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa19.w,(a0)+
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#vbl,$70.w		;set new vbl
		move.l	#new_kbd,$118.w
		move.l	#timerb,$120.w		;set new timerb
		bclr	#3,$fffffa17.w		;set auto isr ena at rte
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		move.w	#$2300,sr		;start 'em up
		rts

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

shut_down	move.w	#$2700,sr
		lea	storage,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa19.w

		moveq	#0,d0
		jsr	music

		movem.l	old_palette,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	#$2300,sr
		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		move.b	#$8,$fffffc02.w

		tst.w	falcon_flag
		bne.s	.do_falcy_bit

		move.w	org_falcon_rez,-(sp)	;mode
		move.w	original_rez,-(sp)	;modecode
		move.l	screen_base,-(sp)	;phys
		move.l	(sp),-(sp)		;log
		move.w	#5,-(sp)
		trap	#14
		add.l	#14,sp

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		rts


.do_falcy_bit
		move.w	org_falcon_rez,-(sp)	;mode
		move.w	#3,-(sp)		;modecode
		move.l	screen_base,-(sp)	;phys
		move.l	(sp),-(sp)		;log
		move.w	#5,-(sp)
		trap	#14
		add.l	#14,sp

		rts


test_for_falcon
*** Detect Falcon computer code...
***
*** Written by MAC SYS DATA of PERSISTENCE OF VISION
***
***
; Execute in Supervisor mode
		move.l	$5a0,a0
		cmp.l	#0,a0
		beq.s	.nocookiejar
		move.l	$14(a0),d0	;get video shifter type?
		tst.l	d0
		beq.s	.notdma
		cmp.l	#$30000,d0
		beq.s	.yesfalcon
		rts
.yesfalcon	move.w	#-1,falcon_flag
		rts
.notdma
.nocookiejar	rts


* Interrupts *
vbl		clr.w	vsync_flag
		clr.b	$fffffa1b.w
		move.b	#63,$fffffa21.w
		move.w	colours_offset+2,colours_offset
		clr.w	timerb_counter
		move.l	#timerb,$120.w
		movem.l	d0-d7/a0,-(sp)
		lea	raster_sine,a0
		move.w	colours_offset+2,d0
		and.w	#255,d0
		move.b	(a0,d0.w),d0
		and.w	#%11111110,d0
		move.w	d0,colours_offset
		add.w	#1,colours_offset+2
		move.w	hertz_switch,$ffff8240.w
		move.l	pic+4,$ffff8242.w
		movem.l	pic+6,d0-d6
		movem.l	d0-d6,$ffff8244.w
		movem.l	(sp)+,d0-d7/a0
		move.b	#8,$fffffa1b.w
		tst.w	zero_counter
		bne.s	.dec
		rte
.dec		sub.w	#1,zero_counter
		rte

timerb		clr.b	$fffffa1b.w
		cmp.w	#64-1,timerb_counter
		beq.s	.set_timerb
		move.w	d0,-(sp)
		move.l	a0,-(sp)
		lea	colours,a0
		move.w	colours_offset,d0
		and.w	#255,d0
		add.w	d0,a0
		move.w	(a0),$ffff8242.w
		add.w	#2,colours_offset
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		move.l	(sp)+,a0
		move.w	(sp)+,d0
		add.w	#1,timerb_counter
		rte
.set_timerb	movem.l	d0-d7,-(sp)
		movem.l	lower_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7
		move.l	#timerb_part2,$120.w
		clr.w	colours_offset
		move.b	#8,$fffffa1b.w
		rte
timerb_part2	move.l	d1,-(sp)
		move.l	d0,-(sp)
		move.l	a0,-(sp)
		lea	colours+12,a0		;+12 cos it looks nice
		move.w	colours_offset,d0
		move.w	(a0,d0.w),d0
		move.w	d0,d1
		swap	d0
		move.w	d1,d0
		move.l	d0,$ffff8258.w
		move.l	d0,$ffff825c.w
		add.w	#2,colours_offset
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		move.l	(sp)+,a0
		move.l	(sp)+,d0
		move.l	(sp)+,d1
0		rte

new_kbd		movem.l	d0,-(sp)
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
		movem.l	(sp)+,d0
		rte

		ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
		endc
pic		incbin	"logo.pi1"


scroll_pointer:	dc.l	scroll_text
scroll_text:
 dc.b "                         "
 dc.b "          PERSISTENCE OF VISION PRESENTS COMPILATION 152.        "
 dc.b "ALL CODING AND GRAPHICS BY MAC SYS DATA "
 dc.b "AND MUSIC BY ISO OF SENTRY.       "
 dc.b "RELEASE DATE 23 MARCH 1996.         ANY POV COMPILATION AFTER "
 DC.B "DISC 150 IS NOT COUNTED IN THE OFFICIAL POV DISC LIST.     "
 DC.B "ALL DISCS AFTER 150 HAVE BEEN RELEASED AS I (MSD) HAVE LOADS OF "
 DC.B "DEMOS ALL PACKED AND READY TO GO.  I AM DOING THESE AS A HOBBY "
 DC.B "AND BECAUSE I CANNOT BE BOTHERED TO CODE ANYTHING NEW.     "
 DC.B "I WAS GOING TO WRITE A PLATFORM GAME BUT I HAVE NO DECENT GRAPHIC "
 DC.B "ARTIST AS OZ HAS DISAPPEARED.     POV IS ONLY A ONE MEMBER GROUP "
 DC.B "BUT WILL CEASE TO BE IN THE NEAR FUTURE AS THERE IS NO FUTURE IN "
 DC.B "THE ATARI ST/STE/FALCON.    I SHALL BE BUYING A PC SOON BUT I AM "
 DC.B "GIVING UP CODING AS IT IS TOO TIME CONSUMING.    I WILL FOLLOW THE "
 DC.B "PC CODING SCENE BUT WILL NOT GET INVOLVED EXCEPT FOR MY OWN PERSONAL "
 DC.B "USE.                  FOR THOSE PEOPLE WITH FALCONS OUT THERE, YOU WILL "
 DC.B "NOTICE THAT THIS MENU WORKS ON YOUR FALCON AND WORKS ON A VGA MONITOR. "
 DC.B "               A QUICK HELLO TO A FEW PEOPLE WHO I AM STILL IN CONTACT WITH.... "
 DC.B "  HI TO   DEL,  RICHARD (FELICE),  MARKO (TBB)   AND ALL WHO "
 DC.B "CONTACT ME VIA INTERNET MAIL AND ON C.I.X. (UK).        "
 DC.B "IF YOU WISH TO E-MAIL ME THEN WRITE TO........................."
 DC.B "........................       MRSD1@BNFL.CO.UK              "
 DC.B "   THAT WAS          M  R  S  D  1  @  B  N  F  L  "
 DC.B ".  C  O  .  U  K                  "
 DC.B "         WELL THAT'S ABOUT IT FOR THIS ONE, KEEP A LOOK OUT FOR "
 DC.B "ANOTHER POV SOON.         "
 DC.B "             BYE!                    "
 DC.B "                             "
 dc.b $ff
	even
char_offset	dc.w	0
font		dcb.b	DEPTH*WIDTH,0
		incbin	"new_font.fnt"
font_offsets:
;           !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	00,38,00,00,00,00,00,45,42,43,00,00,41,00,41,47
;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,39,44,00,00,00,37,46
;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17
;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `
 dc.b	18,19,20,21,22,23,24,25,26,00,00,00,00,00,00
;        a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17
;        r  s  t  u  v  w  x  y  z  {  |  }  ~ DEL
 dc.b	18,19,20,21,22,23,24,25,26,00,00,00,00,00

	even
music	incbin	hiyaplac.mus		;music by ISO

	even

colours
 dc.w	$080,$010,$090,$020,$0a0,$030,$0b0,$040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0
 dc.w	$8f0,$1f0,$9f0,$2f0,$af0,$3f0,$bf0,$4f0,$cf0,$5f0,$df0,$6f0,$ef0,$7f0,$ff0
 dc.w	$f70,$fe0,$f60,$fd0,$f50,$fc0,$f40,$fb0,$f30,$fa0,$f20,$f90,$f10,$f80,$f00
 dc.w	$708,$e01,$609,$d02,$50a,$c03,$40b,$b04,$30c,$a05,$20d,$906,$10e,$807,$00f
 dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
 dc.w	$8f7,$1fe,$9f6,$2fd,$af5,$3fc,$bf4,$4fb,$cf3,$5fa,$df2,$6f9,$ef1,$7f8,$ff0
 dc.w	$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0,$8f0,$0f0
 dc.w	$078,$0e1,$069,$0d2,$05a,$0c3,$04b,$0b4,$03c,$0a5,$02d,$096,$01e,$087,$00f
 dc.w	$007,$006,$005,$004,$003,$002,$001,$000


raster_sine	incbin	raster.dat

hertz_switch
lower_pal	dc.w	$000,$002,$003,$004,$005,$006,$007,$007
		dc.w	$700,$700,$700,$700,$700,$700,$700,$700

screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"g       PERSISTENCE OF VISION 152      h"
	dc.b	"g                                      h"
	dc.b	"g       1: A LITTLE BIT INSANE - STE   h"
	dc.b	"g                                      h"
	dc.b	"g       2: EPSS DEMO 2 - STE           h"
	dc.b	"g                                      h"
	dc.b	"g       3: ANTICHRIST SOUND CHIP DEMO  h"
	dc.b	"g                                      h"
	dc.b	"g       4: COPIER                      h"
	dc.b	"g                          0: 50/60 HZ h"
	dc.b	"dffffffffffffffffffffffffffffffffffffffc"
	even

screen_titles_font
	dc.l	0,$1818,$18001800,$66660000,$6cfe,$6cfe6c00,$3e583c1a
	dc.l	$7c00666c,$18326600,0,$1818,0,$c181818,$c003018
	dc.l	$18183000,$663cff3c,$66001818,$7e181800,0,$30600000,$7e000000
	dc.l	0,$1800060c,$18306000,$3c666e76,$3c001838,$18187e00,$3c660c18
	dc.l	$3e007e0c,$1c463c00,$1c3c6c7e,$c007e60,$7c067c00,$3c607c66,$3c007e0c
	dc.l	$18303000,$3c663c66,$3c003c66,$3e063c00,$180018,$18,$183000
	dc.l	$c183018,$c00007e,$7e0000,$30180c18,$30003c46,$c001800,$3e626c60
	dc.l	$7e003c66,$667e6600,$7c667c66,$7c003c66,$60663c00,$7c666666,$7c007e60
	dc.l	$7c607e00,$7e607c60,$60003e60,$6e663e00,$66667e66,$66003c18,$18183c00
	dc.l	$6060666,$3c006c78,$70786c00,$60606060,$7e00eefe,$d6c6c600,$767e7e6e
	dc.l	$66003c66,$66663c00,$7c667c60,$60003c66,$666c3600,$7c667c6c,$66003c60
	dc.l	$3c063c00,$7e181818,$18006666,$66663e00,$66666624,$1800c6c6,$d6eec600
	dc.l	$663c183c,$66006666,$3c181800,$7e0c1830,$7e001e18,$18181e00,$6030180c
	dc.l	$6007818,$18187800,$386cc600,0,$fe00,$c0603000,$ff80
	dc.l	$80808080,$ff010101,$1010101,$10101ff,$80808080,$80ffff00,0
	dc.l	0,$ff8080,$80808080,$1010101,$1010000,0,0
	dc.l	0,0,0,0,0,0,0
	dc.l	0,$ffffffff,$ffffc3c3,$c3c3c3c3,$ff,$ffff0000,1
	dc.l	0,$10000,0,$ffffffff,$ffffc3c3,$c3ffffff,$c1c1c3c1
	dc.l	$c1e18383,$c3838387,0,$c300,$c3c3,$ffffff87,$707ff00
	dc.l	$ffff,$ffffffc3,$c3c3e0c0,$8103070f,0,$818383,$83000000
	dc.l	$80,$80800000,$81,$81010000,$e10000,1,$1010000
	dc.l	$810000,$81838787,0,$810000,$808081,$c3c3c3c3,$c3ffc3c3
	dc.l	$c3838387,$c1818381,$c1e10000,$ff,$8381c181,$83870000,$c1c3c3
	dc.l	0,0,0,0,$10000,$81,0
	dc.l	$10000,$1000000,$101,$f0f0000,$80,0,$8181
	dc.l	$c3818181,$f0f00000,$810101,$3010101,$f0f0f00,0,$1010
	dc.l	0,0,$81,1,$f0f0000,$80,0
	dc.l	$101,$808081,$c3c3,$c3c30000,$80,0,$81c31000
	dc.l	$10,$8100,0,$81c3c3,$8100,$c0c0,$c3c0c0c0
	dc.l	$70381c0,$e0f00303,$c3030303,$1000010,$ffffffff,$ff000000,$f070787
	dc.l	$ffff007f,$7f7f7fff,$fcfcfc,$fcfffcfc,$fcfc00ff,$3f3f3f3f,$ffffff
	dc.l	$ffffffff,$ffffffff,$ff3f3f,$3f3f3fff,$fcfcfcfc,$fcffffff,$ffffffff
	dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff
	dc.l	$ffffffff,$ffffffff



ripple_table_pos	dc.l	init_ripple_table
init_ripple_table

ripple_table	incbin	sine1.dat
		incbin	sine1.dat
		incbin	sine2.dat
		incbin	sine3.dat
reset_ripple_flag
		incbin	sine1.dat



key_codes		;comment out keys you don't want to use
	dc.b	2,0	;key 1
	dc.b	3,1	;key 2
	dc.b	4,2	;key 3
	dc.b	5,3	;key 4
;	dc.b	6,4	;key 5
;	dc.b	7,5	;key 6
;	dc.b	8,6	;key 7
;	dc.b	9,7	;key 8
;	dc.b	10,8	;key 9

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1	;keypad 2
	dc.b	$6f,2	;keypad 3
	dc.b	$6a,3	;keypad 4
;	dc.b	$6b,4	;keypad 5
;	dc.b	$6c,5	;keypad 6
;	dc.b	$67,6	;keypad 7
;	dc.b	$68,7	;keypad 8
;	dc.b	$69,8	;keypad 9

	dc.b	$ff	;end of table
	even


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5
		dc.l	filename6
		dc.l	filename7
		dc.l	filename8
		dc.l	filename9


*** filenames must end in 0 and must be on an even address...
****
**** If using POV AUTORUN and you wish to exit to the desktop simply
**** start the filename off with $$
****

filename1	dc.b	"albi.prg",0
	even
filename2	dc.b	"goggdemo.prg",0
	even
filename3	dc.b	"antidem.prg",0
	even
filename4	dc.b	"copier.pov",0
	even
filename5	dc.b	"filename.ext",0
	even
filename6	dc.b	"filename.ext",0
	even
filename7	dc.b	"filename.ext",0
	even
filename8	dc.b	"filename.ext",0
	even
filename9	dc.b	"filename.ext",0
	even

		ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
		endc
bssstart
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
org_falcon_rez	ds.w	1
falcon_flag	ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1
key		ds.w	1
vsync_flag	ds.w	1
zero_counter	ds.w	1
timerb_counter	ds.w	1
colours_offset	ds.w	1
		ds.w	1
storage		ds.b	16

ripple_data		ds.b	(RIPPLER_WIDTH*2*RIPPLER_DEPTH)*16
ripple_end


		ds.b	256
screens		ds.b	32000
		ds.b	32000
bssend

		ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
		endc
