*************************************************************************
*			Persistence Of Vision 150			*
*			-------------------------			*
*									*
*									*
* Written by:	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*	Date:	May 1997 - Nov 1997					*
*									*
*									*
*									*
*									*
*									*
*									*
*************************************************************************


yes=1
YES=yes
no=0
NO=no

DOWNLOAD	equ	no

		ifne	DOWNLOAD
		include	TRANSMIT.S
		org	$20000
Code_Start
Exec_Addr
		endc


	opt o+,w-


	ifeq	DOWNLOAD
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	lea	start(pc),a0
	move.l	#bssend-start,d0
.clr	clr.b	(a0)+
	sub.l	#1,d0
	bne.s	.clr
	pea	blank
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
.exit	clr.w	-(sp)
	trap	#1
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


		bsr	set_up
		bsr	set_screen	;screen flip

main_loop	bsr	vsync
;		bsr	set_screen	;screen flip
;		move.w	#$123,$ffff8240.w

	bsr	check_moves
	bsr	stars
	bsr	scroll
	bsr	check_col_change

;		move.w	pic+2,$ffff8240.w

	move.w	key,d0

	cmp.w	#1,d0		;ESC
	beq.s	exit

	cmp.w	#$48,d0
	beq	up

	cmp.w	#$50,d0
	beq	down

;	cmp.w	#11,d0		;0 keyboard
;	beq	zero

;	cmp.w	#$70,d0		;0 keypad
;	beq	zero

;	cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
;	beq	reset

	cmp.w	#$39,d0		;space bar has been pressed to init run
	beq	execute

		lea	demo_keys,a0
next		move.w	(a0)+,d1
		bmi.s	main_loop
		cmp.b	d1,d0
		beq.s	run
		bra.s	next


execute		move.w	position,d1
		bra.s	fix
run		lsr.w	#8,d1
fix		and.w	#$f,d1
		lsl.w	#2,d1
		lea	filename_table,a0
		move.l	(a0,d1.w),a0
		lea	$200.w,a1
		REPT	4
		move.l	(a0)+,(a1)+
		ENDR

;	tst.w	hertz_toggle
;	beq.s	hz50
;	and.b	#%11111101,$ffff820a.w	;60Hz
;hz50
exit
		tst.w	falcon_flag
		bne	do_shutdown_falcon

		move.w	#$2700,sr
		lea	storage,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa13.w
		move.w	#$2300,sr

		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)	

		bsr	set_old_palette

		move.w	original_rez,-(sp)
		move.l	screen_base,-(sp)	;reset old video pointer
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

finish		move.b	#$8,$fffffc02.w	;ena mouse

		ifeq	DOWNLOAD
		bsr	set_user
		bra	exec
		endc

		ifne	DOWNLOAD
		move.l	4.w,-(sp)
		rts
		endc


do_shutdown_falcon
		bsr	shutdown_falcon
		bra.s	finish





*this rout will check whether up and down moves are correct
NOOFMOVES	equ	7	;number of lines the selector moves
NOOFFILES	equ	5	;number of selectable items
check_moves	tst.w	upward
		beq.s	.noup
		sub.w	#1,upward
		add.w	#2,item_offset
		rts
.noup		tst.w	downward
		beq.s	.nodown
		sub.w	#1,downward
		sub.w	#2,item_offset
.nodown		rts
up		tst.w	upward
		beq.s	.ok
		bra	main_loop
.ok		tst.w	position
		beq.s	.no
		move.w	#NOOFMOVES,upward
		sub.w	#1,position
.no		bra	main_loop		
down		tst.w	downward
		beq.s	.ok
		bra	main_loop
.ok		cmp.w	#NOOFFILES,position	;max pos down 0-9 (10)
		bge.s	.no
		move.w	#NOOFMOVES,downward
		add.w	#1,position
.no		bra	main_loop






*********** SCROLLER **********************
DEPTH		EQU	7
WIDTH		EQU	8

scroll	move.l	line_ptr,a5
	tst.b	(a5)
	bpl	loop3
	lea	scroll_line,a5	;restart message
	move.l	a5,line_ptr
loop3	tst.w	scroll_number
	bne	loop2
	move.w	#WIDTH,scroll_number
	moveq	#0,d0
.get	move.b	(a5)+,d0

	move.l	a5,line_ptr
	sub.w	#32,d0
	mulu	#(DEPTH*2),d0
	lea	font,a5
	add.l	d0,a5	;letter address is in a5
;transfer letter into buffer

	lea	sbuffer+40,a1
off	set	0
	REPT	DEPTH
	move.w	(a5)+,off(a1)
off	set	off+42
	ENDR

loop2
	lea	sbuffer,a5
	move.w	#DEPTH-1,d0
loopy
	and.w	#%1111111111101111,SR		;clear X flag
	roxl.w	40(a5)
	roxl.w	38(a5)
	roxl.w	36(a5)
	roxl.w	34(a5)
	roxl.w	32(a5)
	roxl.w	30(a5)
	roxl.w	28(a5)
	roxl.w	26(a5)
	roxl.w	24(a5)
	roxl.w	22(a5)
	roxl.w	20(a5)
	roxl.w	18(a5)
	roxl.w	16(a5)
	roxl.w	14(a5)
	roxl.w	12(a5)
	roxl.w	10(a5)
	roxl.w	8(a5)
	roxl.w	6(a5)
	roxl.w	4(a5)
	roxl.w	2(a5)
	roxl.w	(a5)
	add.w	#42,a5
	dbf	d0,loopy



	move.l	scr_now,a5
	add.w	#160*66,a5
	lea	sbuffer,a4
	move.w	#DEPTH-1,d0
.loop
	move.w	(a4)+,(a5)
	move.w	(a4)+,8(a5)
	move.w	(a4)+,16(a5)
	move.w	(a4)+,24(a5)
	move.w	(a4)+,32(a5)
	move.w	(a4)+,40(a5)
	move.w	(a4)+,48(a5)
	move.w	(a4)+,56(a5)
	move.w	(a4)+,64(a5)
	move.w	(a4)+,72(a5)
	move.w	(a4)+,80(a5)
	move.w	(a4)+,88(a5)
	move.w	(a4)+,96(a5)
	move.w	(a4)+,104(a5)
	move.w	(a4)+,112(a5)
	move.w	(a4)+,120(a5)
	move.w	(a4)+,128(a5)
	move.w	(a4)+,136(a5)
	move.w	(a4)+,144(a5)
	move.w	(a4)+,152(a5)
	add.w	#2,a4
	add.w	#160,a5
	dbf	d0,.loop
	
	sub.w	#1,scroll_number
	rts


stars		move.l	star_pos,a0
		move.l	scr_now,a1
		add.w	#6*160,a1
		moveq	#0,d2
		move.l	#180-1,d0	;number of stars
.star_loop	move.l	(a0),a3
		move.w	(a3)+,d1
		move.w	(a3)+,d2
		lea	0(a1,d2.l),a2
	bclr	d1,2(a2)
		addq.l	#4,(a0)
		cmp.l	12(a0),a3
		bne.s	.clr
		move.l	4(a0),(a0)
		move.l	(a0),a3
.clr		move.w	(a3)+,d1
		move.w	(a3)+,d2
		lea	0(a1,d2.l),a2
	bset	d1,2(a2)
		addq.l	#8,a0
		dbf	d0,.star_loop
		rts


check_col_change
;first check for active fade
		tst.w	logofade
		beq	nofade
		sub.w	#1,vblcount
		bne	.qrts
		bsr	fade
		sub.w	#1,logofade
.qrts		rts
;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade		lea	temp_pal,a1
.next_value	lea	live_pal,a0

	move.w	#7,vblcount
		move.w	#16-1,d7
.loop		bsr	modify
		add.w	#2,a0
		add.w	#2,a1
		dbf	d7,.loop
		rts

modify		move.w	(a0),d0		;get color value
		move.w	(a1),d1		;target pal
		move.w	d0,d4		;NEW COL
		move.w	d0,d2
		move.w	d1,d3
		and.w	#7,d2
		and.w	#7,d3
		cmp.w	d2,d3
		beq.s	blue_ok
		bmi.s	blue_dn
		addq.w	#1,d4
		bra.s	blue_ok
blue_dn	subq	#1,d4
blue_ok	move.w	d0,d2
		move.w	d1,d3
		and.w	#$70,d2
		and	#$70,d3
		cmp.w	d2,d3
		beq.s	grn_ok
		bmi.s	grn_dn
		add.w	#$10,d4
		bra.s	grn_ok
grn_dn		sub.w	#$10,d4
grn_ok		move.w	d0,d2
		move.w	d1,d3
		and.w	#$700,d2
		and.w	#$700,d3
		cmp.w	d2,d3
		beq.s	red_ok
		bmi.s	red_dn
		add.w	#$100,d4
		bra.s	red_ok
red_dn		sub.w	#$100,d4
red_ok		move.w	d4,(a0)
		rts

nofade		sub.w	#1,col_countdown
		bne.s	nochange
		add.w	#2,rap
		move.w	#2000,col_countdown
		move.w	rap,d0
		and.l	#%111,d0
		lea	pals,a0
		mulu	#8,d0
		add.w	d0,a0
		movem.l	(a0),d0-d3
		movem.l	d0-d3,temp_pal+16
		move.w	#8,logofade
nochange	rts

















vsync	move.w	#-1,vsync_flag
.sync	tst.w	vsync_flag
	bne.s	.sync
	rts

***********************
* SUBROUTINES SECTION *
***********************
set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


set_old_palette
	lea	old_st_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts




set_up
		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
.clr		clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.clr

		ifeq	DOWNLOAD
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_st_palette

		bsr	print_titles

		bsr	test_for_ste
		bsr	test_for_falcon
		tst.w	falcon_flag
		bne	setup_falcon

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,live_pal
;set up colour changing logo
		movem.l	d4-d7,pal1
		move.w	#4000,col_countdown

		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

*set up star field
		bsr	make_random_stars
		bsr	sort_random

		jsr	music		;init music


*set up ISRs
		move.w	#$2700,sr
		lea	storage,a0
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#new_kbd,$118.w
		move.l	#timerb,$120.w
		move.l	#vbl,$70.w
		bclr	#3,$fffffa17.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		move.w	#$2300,sr


		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

setup_falcon
		lea	falcon_store,a0
		lea	$ffff8200.w,a1		; Videobase.
		move.w	$60(a1),(a0)+
		move.w	$66(a1),(a0)+
		move.l  $C0(a1),(a0)+
		move.w  $0A(a1),(a0)+
		move.w  $0E(a1),(a0)+
		move.w  $10(a1),(a0)+
		move.l  $82(a1),(a0)+
		move.l  $86(a1),(a0)+
		move.l  $8A(a1),(a0)+
		move.l  $A2(a1),(a0)+
		move.l  $A6(a1),(a0)+
		move.l  $AA(a1),(a0)+

.savefv		lea	FVbuffer1298,a1
		move.l	#'FVD2',(a1)+	4 bytes header
		move.b	$ff8006,(a1)+	monitor type
		move.b	$ff820a,(a1)+	sync
		move.l	$ff820e,(a1)+	offset & vwrap
		move.w	$ff8266,(a1)+	spshift
		move.l	#$ff8282,a0	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a0
		bne	.loop1
		move.l	#$ff82a2,a0	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a0
		bne	.loop2
		move	$ff82c2,(a1)+	video control
		move	$ff82c0,(a1)+	video clock
		move.b	$ff8260,(a1)+	shifter resolution
		move.b	$ff820a,(a1)+	video sync mode

		move.w	#-1,-(sp)
		move.w	#$58,-(sp)	;get_original_rez
		trap	#14
		addq.l	#4,sp
		move.w	d0,org_falcon_rez

		move.w	$ffff82aa.w,org_overscanbtm	;bottom overscan

;This bit will automatically set the falcon video res but it will
;preserve the RGB/VGA mode.
		and.w	#%00010000,d1	;keep vga/rgb-tv settings
		move.w	#%0000000010000010,d0
		or.w	d1,d0
;		move.w	d0,-(sp)
;		move.w	#$58,-(sp)
;		trap	#14
;		addq.l	#4,sp

;Word is made up like so :  X X X X X X X V S O P M 8 N N N
;	N  Bits per pixels :	4 -> 16 bits	65536 colours
;				3 -> 8  bits	256 colours
;				2 -> 4  bits	16 colours
;				1 -> 2  bits	1 colours
;				0 -> 1  bit     0 colours?????
;	8 Flag 80 columns  :	1 -> mode 80 columns
;				0 -> mode 40 columns
;	M Flag VGA         :	1 -> mode monitor VGA
;				0 -> mode TV/RGB
;	P Flag PAL         :	1 -> mode PAL
;				0 -> mode NTSC
;	O Flag Overscan    :	1 -> Overscan ON (not valid on VGA)
;				0 -> Overscan OFF
;   S ST compatibility flag:    1 -> Yes
;                               0 -> No
;       V Vertical flag    :    1 -> enable interlace mode on colour
;                                    monitor or double line mode on VGA
;
;       X Reserved         :    Reserved (set 0)

;		move.w	#48,$ffff82aa.w	;overscan bottom by x number of lines

		move.w	d0,-(sp)	;modecode
		move.w	#3,-(sp)	;mode
		move.l	#-1,-(sp)	;phys
		move.l	(sp),-(sp)	;log
		move.w	#5,-(sp)
		trap	#14
		add.l	#14,sp

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show
		bra	set_screen

shutdown_falcon	lea	falcon_store,a0
		lea	$ffff8200.w,a1	; Videobase.
		move.w	(a0)+,$60(A1)
		move.w	(a0)+,$66(A1)
		move.l  (a0)+,$C0(A1)
		move.w  (a0)+,$0A(A1)
		move.w  (a0)+,$0E(A1)
		move.w  (a0)+,$10(A1)
		move.l  (a0)+,$82(A1)
		move.l  (a0)+,$86(A1)
		move.l  (a0)+,$8A(A1)
		move.l  (a0)+,$A2(A1)
		move.l  (a0)+,$A6(A1)
		move.l  (a0)+,$AA(A1)

.restorefv	move.l	#FVbuffer1298,a0
		bsr	setfv

		move.w	org_falcon_rez,-(sp)	;mode
		move.w	#3,-(sp)		;modecode
		move.l	screen_base,-(sp)	;phys
		move.l	(sp),-(sp)		;log
		move.w	#5,-(sp)
		trap	#14
		add.l	#14,sp

		rts

setfv		cmp.l	#'FVD2',(a0)+	4 bytes header
		bne	.error
.ready		addq.l	#2,a0
		move.l	$70,-(sp)
		move	sr,-(sp)
		move.l	#.vbl,$70
		move	#$2300,sr
		
		move.l	$466,d0
.wait		cmp.l	$466,d0
		beq	.wait
		
		move.l	(a0)+,$ff820e	offset & vwrap
		move.w	(a0)+,$ff8266	spshift
		move.l	#$ff8282,a1	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a1
		bne	.loop1
		move.l	#$ff82a2,a1	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a1
		bne	.loop2
		move	(a0)+,$ff82c2	video control
		move	(a0)+,$ff82c0	video clock
		addq.l	#1,a0
		move.b	(a0)+,$ff820a	video sync mode
		move	(sp)+,sr
		move.l	(sp)+,$70
		moveq	#0,d0
		rts
.error		moveq	#-1,d0
		rts
.wrongmon	moveq	#-2,d0
		rts
.sm124		cmp.b	#0,(a0)
		bne	.wrongmon
		bra	.ready
.vga		cmp.b	#2,(a0)
		bne	.wrongmon
		bra	.ready
.vbl		addq.l	#1,$466
		rte
		



test_for_ste	lea	$ffff8205.w,a5
		move.b	(a5),d0		;get original value
		move.b	#-1,(a5)	;poke new value
		cmp.b	(a5),d0		;get value again, is it same?
		bne	.notSTE		;yes same so not ste
		move.b	d0,(a5)		;yes so poke original value back
.ste_found	move.w	#-1,ste_flag
.notSTE		rts

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



make_random_stars
		lea	stars_space,a6
		move.l	a6,d0
		move.l	d0,star_pos
		move.w	#1250-1,d7
.random_loop	move.w	#$11,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,(a6)+
		move.l	d1,(a6)+
		dbf	d7,.random_loop
		rts

sort_random	move.l	star_pos,a6
		move.l	#1449-1,a5
		add.l	a6,a5
		move.l	a5,star_null
		move.l	#180-1,d7
.sort_loop	move.w	#$11,-(sp)
		trap	#14
		addq.l	#2,sp
		swap	d0
		clr.w	d0
		swap	d0
		move.l	d0,d2
		divu	#120,d0
		swap	d0
		sub.w	#60,d0
		clr.w	d1
		swap	d1
		divu	#80,d1
		swap	d1
		sub.w	#40,d1
		tst.w	d0
		bne.s	.end_of_rand
		tst.w	d1
		beq.s	.sort_loop
.end_of_rand	cmp.w	#90,d7
		bgt.s	.bigger
		tst.w	d1
		bgt.s	.sort
		neg.w	d1
		bra.s	.sort
.bigger		tst.w	d1
		blt	.sort
		neg.w	d1
.sort		divu	#50,d2
		clr.w	d2
		swap	d2
		mulu	#4,d2
		move.l	a5,(a6)
		add.l	d2,(a6)+
		move.l	a5,(a6)+
		move.l	#256,d2
		ext.l	d0
		asl.w	#8,d0
		ext.l	d1
		asl.w	#8,d1
.make		move.l	d0,d5
		move.l	d1,d6
		divs	d2,d5
		divs	d2,d6
		subq.w	#3,d2
		add.w	#160,d5
		ext.l	d5
	add.w	#67,d6		;number of lines of starfield/2
		cmp.w	#320-1,d5
		bhi.s	.next
	cmp.w	#67*2,d6		;number of lines in starfield
		bhi.s	.next
	add.w	#61,d6
		mulu	#160,d6
		divu	#16,d5
		move.w	d5,d3
		clr.w	d5
		swap	d5
		divu	#8,d5
		add.w	d5,d6
		swap	d5
		neg.w	d5
		addq.w	#7,d5
		move.w	d5,(a5)+
		mulu	#8,d3
		add.w	d3,d6
		move.w	d6,(a5)+
		bra.s	.make
.next		dbf	d7,.sort_loop
		move.l	a5,(a6)+
		move.l	a5,(a6)+
		rts






*************************************************************************
*	NEW PRINT TITLES ROUT - NOW MASKS TO KEEP 16 COLOUR PIC		*
*									*
* Revision:	1.2 - now supports 6*6 font				*
* Date:		20/10/92						*
* By:		MSD 							*
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
ENABLE_PLANE4	equ	no

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#160*75,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

		move.w	#18-1,d0	;max titles per menu
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
		lea	160*7(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts





vbl	;$70
	clr.b	$fffffa1b.w	;timerb off
	move.b	#66,$fffffa21.w	;timerb data
	move.w	item_offset,colours_offset
	move.w	#7,scroll_ras
	clr.w	otherrasters
	move.l	#scroll_cols,scroll_raster
	move.l	#timerb,$120.w
	move.b	#8,$fffffa1b.w	;timerb on
	movem.l	d0-d7,-(sp)
	movem.l	live_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	jsr	music+8

	movem.l	(sp)+,d0-d7
	clr.w	vsync_flag
	rte

timerb	clr.b	$fffffa1b.w
	move.l	a0,-(sp)
	move.l	scroll_raster,a0
	move.w	(a0)+,$ffff8242.w
	move.l	a0,scroll_raster
	move.l	(sp)+,a0
	sub.w	#1,scroll_ras
	beq.s	.next_timerb
	move.b	#1,$fffffa21.w		;1 line of each colour.....
	move.b	#8,$fffffa1b.w
	rte
.next_timerb
	move.b	#2,$fffffa21.w		;2 lines to next timerb
	move.l	#timerb_part2,$120.w
	move.b	#8,$fffffa1b.w
	rte


timerb_part2
	move.w	#$dead,$ffff8240.w
smc	equ	*-4
	move.w	#$face,$ffff8244.w
smc2	equ	*-4
	move.w	#$dead,$ffff8248.w
smc3	equ	*-4

	clr.b	$fffffa1b.w

	move.l	a0,-(sp)	;$120
	move.w	d0,-(sp)
	lea	colours,a0
	move.w	colours_offset,d0
	add.w	d0,a0
	move.w	(a0),smc
	add.w	#2,colours_offset

	move.w	otherrasters,d0
	lea	stars_timerb_cols,a0
	add.w	d0,a0
	move.w	(a0),smc2

	lea	text_cols,a0
	add.w	d0,a0
	move.w	(a0),smc3
	add.w	#2,otherrasters

	move.w	(sp)+,d0
	move.l	(sp)+,a0
	move.b	#1,$fffffa21.w		;1 line of each colour.....
	move.b	#8,$fffffa1b.w
	rte






new_kbd
	movem.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$1d,d0
	bne.s	.k1
	bset	#2,key
.k1	cmp.b	#$9d,d0
	bne.s	.k2
	bclr	#2,key
.k2	cmp.b	#$38,d0
	bne.s	.k3
	bset	#3,key
.k3	cmp.b	#$b8,d0
	bne.s	.k4
	bclr	#3,key
.k4	move.b	d0,key+1
	bclr	#6,$fffffa11.w
	movem.l	(sp)+,d0
	rte

		ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
		endc


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
exec1	dc.b	"GRODEN.POV",0
	even
exec2	dc.b	"SHADEBOB.POV",0
	even
exec3	dc.b	"RAVE.POV",0
	even
exec4	dc.b	"UNLIMITD.POV",0
	even
exec5	dc.b	"INFO150.POV",0
	even
exec6	dc.b	"copier.pov",0
	even
exec7	dc.b	" ",0
	even
exec8	dc.b	" ",0
	even



pic		incbin	"main.pi1"
pals
pal1	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
pal2	dc.w	$002,$373,$003,$047,$036,$025,$014,$777
pal3	dc.w	$200,$063,$300,$400,$500,$600,$700,$777
pal4	dc.w	$020,$603,$030,$040,$050,$060,$070,$777

colours
 dcb.w	205,000
 dc.w	$777,$123,$234,$345,$456,$345,$234,$123,$777
 dcb.w	200,000

scroll_cols	dc.w	$200,$300,$400,$500,$400,$300,$200,$100
		dc.w	$000,$007,$006,$005,$004,$003,$002,$001

music		incbin "tsc_cred.thk"


item_offset	dc.w	(8*2)*24-12	;position down screen of demo delector

star_pos	dc.l	0
star_null	dc.l	0

stars_timerb_cols
	dc.w	$077,$077,$077,$077,$077,$077,$077,$077
	dc.w	$077,$077,$077,$077,$077,$077,$077,$077
	dc.w	$077,$077,$077,$077,$077,$077,$077,$077
	dc.w	$066,$066,$066,$066,$066,$066,$066,$066
	dc.w	$055,$055,$055,$055,$055,$055,$055,$055
	dc.w	$044,$044,$044,$044,$044,$044,$044,$044
	dc.w	$033,$033,$033,$033,$033,$033,$033,$033
	dc.w	$022,$022,$022,$022,$022,$022,$022,$022
	dc.w	$022,$022,$022,$022,$022,$022,$022,$022
	dc.w	$033,$033,$033,$033,$033,$033,$033,$033
	dc.w	$044,$044,$044,$044,$044,$044,$044,$044
	dc.w	$055,$055,$055,$055,$055,$055,$055,$055
	dc.w	$066,$066,$066,$066,$066,$066,$066,$066
	dc.w	$077,$077,$077,$077,$077,$077,$077,$077
	dc.w	$077,$077,$077,$077,$077,$077,$077,$077
	dc.w	$077,$077,$077,$077,$077,$077,$077,$077

text_cols
	dc.w	$070,$061,$052,$043,$034,$025
	dc.w	$300,$300,$300,$300,$300,$300,$300
	dc.w	$400,$400,$400,$400,$400,$400,$400
	dc.w	$500,$500,$500,$500,$500,$500,$500
	dc.w	$600,$600,$600,$600,$600,$600,$600
	dc.w	$700,$700,$700,$700,$700,$700,$700
	dc.w	$710,$710,$710,$710,$710,$710,$710
	dc.w	$720,$720,$720,$720,$720,$720,$720
	dc.w	$730,$730,$730,$730,$730,$730,$730
	dc.w	$740,$740,$740,$740,$740,$740,$740
	dc.w	$750,$750,$750,$750,$750,$750,$750
	dc.w	$760,$760,$760,$760,$760,$760,$760
	dc.w	$770,$770,$770,$770,$770,$770,$770
	dc.w	$670,$670,$670,$670,$670,$670,$670
	dc.w	$570,$570,$570,$570,$570,$570,$570
	dc.w	$470,$470,$470,$470,$470,$470,$470
	dc.w	$360,$360,$360,$360,$360,$360,$360
	dc.w	$250,$250,$250,$250,$250,$250,$250
	dc.w	$140,$140,$140,$140,$140,$140,$140

line_ptr	dc.l	scroll_line
scroll_line
 dc.b "PERSISTENCE OF VISION PRESENT DEMO COMPILATION 150.      "
 dc.b "RELEASE DATE 3 NOV 1997.            "
 dc.b "IT HAS BEEN A LONG TIME COMING (OO-ER) BUT IT IS FINALLY HERE. "
 DC.B "  THERE ARE PROBABLY ONLY A FEW THOUSAND PEOPLE WHO USE THEIR "
 DC.B "ATARI ST'S NOW BUT I DO NOT CARE.      I HAVE SPENT A LOT OF TIME "
 DC.B "COMPILING THIS DISC AND I FEEL IT WAS WORTH IT TO COMPLETE THE "
 DC.B "COLLECTION.                   "
 dc.b "PERSISTENCE OF VISION IS THE LONGEST RUNNING "
 DC.B "DEMO COMPILATION CREW EVER ON THE ST, WE ARE PROBABLY THE LONGEST RUNNING "
 DC.B "ACTIVE CREW ON THE WHOLE SCENE.               "
 dc.b "IN 1989 THE FIRST POV DISC WAS RELEASED, NOW 8 YEARS LATER THE "
 dc.b "LAST OFFICIAL DISC HAS BEEN RELEASED.            "
 DC.B "OVER THE YEARS WE HAVE HAD A TOTAL OF 5 MEMBERS, THREE MEMBERS HAD "
 DC.B "THEIR NAMES BLAZEN ON MOST DISCS BUT ONE MEMBER DID THE BULK OF THE "
 DC.B "WORK.               "
 dc.b "HERE IS A LIST OF PRESENT AND PAST MEMBERS (IN ORDER)...            "
 DC.B "1)  MAC SYS DATA (MSD) - HACKER/PACKER/MUSIC RIPPER/CODER   THIS KEY "
 DC.B "MEMBER VIRTUALLY RAN POV SINGLE HANDED AND HAS CONTRIBUTED A LOT OF WORK TO "
 DC.B "THE ST. MANY GAME AND DEMO PACKING CREWS OWE THEIR MENUS TO "
 DC.B "THIS GUY,          "
 DC.B "2) DR.SYNE - SUPPLIER/DISTRIBUTER - ORIGINAL MEMBER OF POV, "
 DC.B "HE AND MSD MET IN A COMPUTER SHOP IN 1988 WHEN MSD BOUGHT HIS FIRST "
 DC.B "ATARI STFM.  DR.SYNE WAS ALWAYS AROUND BUT TOOK A BACK SEAT AROUND "
 DC.B "POV 10.          "
 DC.B "3)  ALY  ARTIST - A PART TIME MEMBER WHO DREW THE ART WORK FOR EARLY POV'S, "
 DC.B "HE WAS RESPONSIBLE FOR GIVING MSD IDEAS AND WAS FAMOUS FOR SLEEPING. DUE TO "
 DC.B "OTHER INTERESTS ALY STOPPED DOING ART FOR POV BEFORE DISC 15.           "
 DC.B "4)  BORIS  CODER - VERY FEW MENUS WERE CODED BY BORIS BUT WHEN THEY "
 DC.B "DID APPEAR THEY WERE USUALLY PRETTY GOOD.   BORIS IS AN EXPERT CODER AND "
 DC.B "ALTHOUGH HE CONTRIBUTED LITTLE TO POV MENUS, HE AND MSD HAD IN DEPTH "
 DC.B "CONVERSATIONS ABOUT CODING AND SHARED IDEAS.   BORIS NOW WORKS FOR A "
 DC.B "SOFTWARE COMPANY IN AMERICA WHERE HE CO-WRITES GAMES.   HE WAS LAST "
 DC.B "HEARD OF WRITING A 3D ENGINE FOR THE PC.           "
 DC.B "5)  OZ  ARTIST/MUSICIAN -  OZ BASICALLY TOOK OVER FROM ALY AND SUPPLIED "
 DC.B "VIRTUALLY ALL THE ARTWORK FOR POV.   HE IS PROBABLY AS FAMOUS FOR HIS "
 DC.B "ORIGINAL MOD MUSIC AS HIS ART.   YOU CAN SEE A LOT OF HIS WORK ON THE "
 DC.B "POV OZ SLIDESHOW COMPILATIONS.   THERE ARE OVER 200 UNUSED PICTURES FROM "
 DC.B "OZ WAITING TO BE RELEASED TOGETHER WITH 8 CYBER SEQUENCES AND 6 MODULES.   "
 DC.B "OZ DISAPPEARED TO UNIVERSITY OVER 5 YEARS AGO AND DESPITE EFFORTS "
 DC.B "TO CONTACT HIM, NO FURTHER COMMUNICATION HAS BEEN MADE.                 "
 DC.B "IN ADDITION TO THIS LIST, THERE ARE TWO PEOPLE WHO WERE SO NEARLY "
 DC.B "MEMBERS OF POV.     THE FIRST WAS CALLED MARTIN, HE WAS SO DESPERATE "
 DC.B "TO JOIN POV THAT HE TRIED HIS HAND AT CODING, ART, MUSIC, CRACKING "
 DC.B "AND PACKING.  HE FINALLY GAVE UP HOPE AND DID SOME DISTRIBUTION. "
 DC.B "HIS ATTENTION DID NOT LAST AND HE DISAPPEARED WHEN MSD STARTED "
 DC.B "DEALING WITH PD LIBRARIES DIRECTLY.  "
 DC.B "THE SECOND 'NEARLY POV' MEMBER IS CALLED GEORGE AND RAN TOWER PD FOR SOME "
 DC.B "YEARS.   GEORGE PROUDLY DISTRIBUTED POV DISCS TO OTHER PD LIBRARIES AND TO "
 DC.B "INDIVIDUALS FOR NO PROFIT.   'TOWER PD' TOGETHER WITH 'D.W.STABLES PD' BASED "
 DC.B "IN BLACKPOOL, UK. WERE OUR MAIN DISTRIBUTION POINTS.            "
 DC.B "                          "
 DC.B "THE ONLY ACTIVE MEMBER OF POV IS NOW MAC SYS DATA, THIS HAS BEEN THE "
 DC.B "CASE FOR OVER 3 YEARS.   I WILL CONTINUE TO CODE AS LONG AS THERE IS "
 DC.B "INTEREST AND AS LONG I AM MENTALLY ABLE.                     "
 DC.B "I ADMIT TO OWNING A PC "
 DC.B "AND AM TOYING WITH LEARNING 'C' BUT I DO NOT POSSESS THE NECESSARY "
 DC.B "SKILLS TO KEEP UP WITH THE RECENT CODERS WHO WRITE 3D CODE WITH SUCH "
 DC.B "FLARE.                SOME NEW PC DEMOS SEEM ALMOST LIKE MOVIES "
 DC.B "EVEN THOUGH THEY ARE CALCULATED IN REAL TIME.                   "
 DC.B "                 "
 DC.B "OKAY HERE IT COMES... THE GREETINGS TO     "
 DC.B "ADRENALIN,   ANIMAL MINE,   BLACK CATS,   BLIND BASTARD,   "
 DC.B "CYNIX,   D-BUG,   DELTA FORCE,   DR SYNE,   ERIK PLANKTON,   "
 DC.B "EQUINOX,   FUSION,   GENESIS INC.,   GEORGE (BART),   "
 DC.B "INNER CIRCLE,   KGB,   MAD VISION,   MUG UK,   NEXT,   NOD,   "
 DC.B "PAL PD,   PIXEL TWINS,   POMPEY PIRATES,   PROPHECY PD,   "
 DC.B "PURE ENERGY,   REPLICANTS,   RIPPED OFF,   SEWER SOFTWARE,   "
 DC.B "SLAYTANIC CULT,   ST CNX,   STRANGER,   TCB,   THE SOURCE,   "
 DC.B "THE SYNDICATE,   UNITY,   UTOS   AND   WILD!             "
 DC.B "THERE ARE MANY MORE CREWS THAT APPEARED ON POV COMPILATIONS AND "
 DC.B "ON THE DEMO SCENE, WE APOLOGISE FOR NOT GREETING THEM AND ANY "
 DC.B "OTHERS WHO MAY HAVE CONTACTED US OVER THE YEARS.                "
 DC.B "               "
 DC.B "OKAY THAT'S THE END OF THIS SCROLLTEXT SO GET PRESSING THOSE "
 DC.B "KEYS.                               "
 dc.b	$ff
	even

font	dcb.b	DEPTH*2,0
	incbin	"8x8_font.dat"
	even

vblcount	dc.w	4


screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"****** PERSISTENCE OF VISION  150 ******"
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	" 1: GRODEN (POV STYLE) STE + 1 MEG ONLY "
	dc.b	"             2: SHADED BOBS             "
	dc.b	"      3: RAVE (DISK FILLER) - 1 MEG     "
	dc.b	"           4: UNLIMITED BOBS            "
	dc.b	"         5: POV INFORMATION 150         "
	dc.b	"               6: COPIER                "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"      MENU CODED BY SPACEMAN SPIFF      "
	dc.b	"               MUSIC BY ?               "
	dc.b	"         MENU COMPILED BY MSD           "
	dc.b	"aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"g  USE CURSOR KEYS TO SELECT ITEM AND  h"
	dc.b	"g           SPACE TO EXECUTE           h"
	dc.b	"dffffffffffffffffffffffffffffffffffffffc"

	even

screen_titles_font
	dc.l	0,0,$1818,$18001800,$66660000,$6cfe,$6cfe6c00,$3e583c1a,$7c00666c,$18326600
	dc.l	$1818,0,$c181818,$c003018,$18183000,$663cff3c,$66001818,$7e181800,0,$30600000
	dc.l	$7e000000,0,$1800060c,$18306000,$3c666e76,$3c001838,$18187e00,$3c660c18,$3e007e0c,$1c463c00
	dc.l	$1c3c6c7e,$c007e60,$7c067c00,$3c607c66,$3c007e0c,$18303000,$3c663c66,$3c003c66,$3e063c00,$180018
	dc.l	$18,$183000,$c183018,$c00007e,$7e0000,$30180c18,$30003c46,$c001800,$3e626c60,$7e003c66
	dc.l	$667e6600,$7c667c66,$7c003c66,$60663c00,$7c666666,$7c007e60,$7c607e00,$7e607c60,$60003e60,$6e663e00
	dc.l	$66667e66,$66003c18,$18183c00,$6060666,$3c006c78,$70786c00,$60606060,$7e00eefe,-$29393a00,$767e7e6e
	dc.l	$66003c66,$66663c00,$7c667c60,$60003c66,$666c3600,$7c667c6c,$66003c60,$3c063c00,$7e181818,$18006666
	dc.l	$66663e00,$66666624,$1800c6c6,-$29113a00,$663c183c,$66006666,$3c181800,$7e0c1830,$7e001e18,$18181e00
	dc.l	$6030180c,$6007818,$18187800,$386cc600,0,$fe00,-$3f9fd000,$ff80,-$7f7f7f80,-$fefeff
	dc.l	$1010101,$10101ff,-$7f7f7f80,-$7f000100,0,0,$ff8080,-$7f7f7f80,$1010101,$1010000
	dc.l	0,0,0,0,0,0,0,0,0
	dc.l	-1,-$3c3d,-$3c3c3c3d,$ff,-$10000,1,0,$10000,0,-1
	dc.l	-$3c3d,-$3c000001,-$3e3e3c3f,-$3e1e7c7d,-$3c7c7c79,0,$c300,$c3c3,-$79,$707ff00
	dc.l	$ffff,-$3d,-$3c3c1f40,-$7efcf8f1,0,$818383,-$7d000000,$80,-$7f800000,$81
	dc.l	-$7eff0000,$e10000,1,$1010000,$810000,-$7e7c7879,0,$810000,$808081,-$3c3c3c3d
	dc.l	-$3c003c3d,-$3c7c7c79,-$3e7e7c7f,-$3e1f0000,$ff,-$7c7e3e7f,-$7c790000,$c1c3c3,0
	dc.l	0,0,$10000,$81,0,$10000,$1000000,$101,$f0f0000,$80
	dc.l	0,$8181,-$3c7e7e7f,-$f100000,$810101,$3010101,$f0f0f00,0,$1010
	dc.l	0,$81,1,$f0f0000,$80,0,$101,$808081,$c3c3,-$3c3d0000
	dc.l	$80,0,-$7e3cf000,$10,$8100,0,$81c3c3,$8100,$c0c0,-$3c3f3f40
	dc.l	$70381c0,-$1f0ffcfd,-$3cfcfcfd,$1000010,-1,-$1000000,$f070787,-$ff81,$7f7f7fff,$fcfcfc
	dc.l	-$3000304,-$303ff01,$3f3f3f3f,$ffffff,-1,-1,$ff3f3f,$3f3f3fff,-$3030304,-$3000001
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1


position	dc.w	0
		dc.b	"msd!"

		ifeq	DOWNLOAD
*******************
;   SECTION BSS
*******************
		endc
bssstart
stack_save	ds.l	1
falcon_flag	ds.w	1
ste_flag	ds.w	1
screen_base	ds.l	1
original_rez	ds.w	1
old_st_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1

falcon_store	ds.b	38
falcon030	ds.w	1
org_overscanbtm	ds.w	1
org_falcon_rez	ds.w	1
FVbuffer1298	ds.w	24

storage		ds.w	12
vsync_flag	ds.w	1
key		ds.w	1
upward		ds.w	1
downward	ds.w	1
scroll_raster	ds.l	1
scroll_ras	ds.w	1
scroll_number	ds.w	1
logofade	ds.w	1
temp_pal	ds.w	16
live_pal	ds.w	16
rap		ds.w	1
col_countdown	ds.w	1
colours_offset	ds.w	1
otherrasters	ds.w	1

sbuffer		ds.b	42*DEPTH

		ds.b	256
screens		ds.b	32000
		ds.b	32000

stars_space	ds.w	1450
		ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
		endc
bssend