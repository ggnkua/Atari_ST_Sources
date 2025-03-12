*************************************************************************
*			PERSISTENCE OF VISION 126			*
*			-------------------------			*
*									*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*		Spray routine based on one by Orion of Fuzion		*
*									*
*									*
* Music by: 	Scavenger of Synergy.			 		*
*		Tune ripped by Mac Sys Data				*
*									*
*									*
* Grafix by: 	Machine System Data & Ozymandias			*
*									*
*									*
*************************************************************************
*
* Note:	As usual this menu uses conditional assembly. To select the
*	options simply answer YES or NO to enable them.
*
*	I have included an additional option that allows you to use
*	a PDS system for ST-ST or ST-AMIGA. To use this option you will
*	need a special cable connecting your ST to another on parallel.
*	Finally you will need the transmitter and receiver software.
*
*
*
*
*
YES=1
NO=0

**************************************************************************
*************** ST-ST/AMIGA DOWNLOAD DEVELOPMENT SWITCH ******************
**************************************************************************
* The Development switch is only for use with the Leo PDS system/ I can
* guarentee that you will not have this so make the DOWNLOAD to NO.
*
* If you're interested it allows you to code on one machine and run the
* object code on another machine (ST/AMIGA). If the object code crashes
* you don't have to reboot your development machine.
*
**************************************************************************
DOWNLOAD	equ	YES


	ifne	DOWNLOAD
	include	transmit.s			;ST transmitter code
	org	$10000

Code_Start
Exec_Addr
	endc
*************************************************************************

AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from this menu.

	ifeq	DOWNLOAD
	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	tst.w	set_develop
	bne.s	.exit
	lea	start(pc),a0
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
	ENDC



		ifeq	DOWNLOAD	;if not download then setup SUPERX
		MOVE.L	sp,usp_save
		move.l	#stop,sp

		pea	menu(pc)
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp
		move.l	usp_save,sp
		endc

		ifeq	DOWNLOAD
		ifne	AUTORUN4
		clr.w	-(sp)
		trap	#1
		endc
		endc

		ifne	DOWNLOAD	;if download then just JSR as download runs in super mode
		jsr	menu
		move.l	4.w,a0		;reset for next download
		jmp	(a0)
		endc

		ifeq	DOWNLOAD
		ifeq	AUTORUN4
		bra	exec
		endc
		endc

	opt	o+,w-




*************************************************************************
**************** AT LAST THE MENU CODE ITSELF ***************************
*************************************************************************
menu		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
bssclear	clr.b	(a0)+
		sub.l	#1,d0
		bne.s	bssclear

		bsr	save_old

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,screen_base
		lsr.l	#8,d0
		lea	$ffff8201.w,a6
		movep.w	d0,(a6)

		move.b	$484.w,old484
		move.b	#$13,$fffffc02.w	;stop output of keyboard
		clr.b	$ffff8260.w
		move.w	#$2700,sr
		move.l	#_vbl,$70.w
		move.w	#$2300,sr

		clr.w	$ffff8240.w

		move.l	#buffer,font_table

		bsr	make_fonts
		bsr	timerb_code_gen
		bsr	make_random_stars
		bsr	sort_random

		lea	pic+34,a0		;show pic
		move.l	screen_base,a1
		move.w	#32000/4-1,d0
sho		move.l	(a0)+,(a1)+
		dbf	d0,sho

		bsr	start_main


.no_key		tst.w	key_found
		beq.s	.no_key
		bsr	shut_down

;check hertz before we leave
		tst.w	hertz
		beq.s	.hz50
		clr.b	$ffff820a.w
		bra.s	.hz60
.hz50		or.b	#2,$ffff820a.w
.hz60		rts

save_old	move.l	$44e.w,old_base
		move.b	$ffff8260.w,old_rez
		move.b	$ffff820a.w,old_hz
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		lea	$fffffa01.w,a0
		lea	old_mfp,a1
		moveq	#16-1,d0
.loop		move.b	(a0)+,(a1)+
		lea	1(a0),a0
		dbf	d0,.loop
		move.b	8(a0),(a1)+
		move.b	10(a0),(a1)+
		move.b	12(a0),(a1)+
		move.b	14(a0),(a1)+
		move.b	16(a0),(a1)+
		move.b	18(a0),(a1)+
		move.b	20(a0),(a1)+
		move.b	22(a0),(a1)+
		move.b	24(a0),(a1)+

		lea	$ffff8800.w,a0
		lea	old_psg,a1
		moveq	#16-1,d0
.loop2		move.b	d0,(a0)
		move.b	(a0),(a1)+
		dbf	d0,.loop2

		move.l	$70.w,old_vbl
		move.l	$120.w,old_timerb
		move.l	$110.w,old_timerd

		rts

start_main	move.w	#1,d7
		bsr	vsync

		move.w	#$2700,sr

		move.b	#1,$fffffa07.w
		clr.b	$fffffa09.w
		move.b	#1,$fffffa0b.w		;ena timerb
		clr.b	$fffffa0d.w
		move.b	#1,$fffffa13.w		;ena timerb
		clr.b	$fffffa15.w

		clr.b	$fffffa11.w

		bsr	init_music

		move.b	#$40,$fffffa17.w
		move.b	#$12,$fffffc02.w	;no mouse
		move.l	#main_vbl,$70.w
		move.w	#$2300,sr
		rts

shut_down	move.w	sr,-(sp)
		move.w	#$2700,sr
		lea	old_mfp,a0
		lea	$fffffa01.w,a1
		moveq	#16-1,d0
.loop		move.b	(a0)+,(a1)+
		lea	1(a1),a1
		dbf	d0,.loop
		move.b	(a0)+,8(a1)
		move.b	(a0)+,10(a1)
		move.b	(a0)+,12(a1)
		move.b	(a0)+,14(a1)
		move.b	(a0)+,16(a1)
		move.b	(a0)+,18(a1)
		move.b	(a0)+,20(a1)
		move.b	(a0)+,22(a1)
		move.b	(a0)+,24(a1)
		move.l	old_vbl,$70.w
		move.l	old_timerb,$120.w
		move.l	old_timerd,$110.w
		move.b	#$c0,$fffffa23.w		
		move.b	#8,$fffffc02.w
		move.b	old_hz,$ffff820a.w
		lea	$ffff8800.w,a0
		move.l	#$707ffff,(a0)
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)

		move.b	old_rez,$ffff8260.w
		move.l	old_base,d0
		lsr.l	#8,d0
		lea	$ffff8201.w,a6
		movep.w	d0,(a6)

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.b	old484,$484.w
		move.w	(sp)+,sr
		rts

init_music	moveq	#1,d0
		jsr	tune
		rts

vsync		clr.l	$466.w
.sync		cmp.l	$466.w,d7
		bne.s	.sync
		rts
_vbl		addq.l	#1,$466.w
		rte



make_fonts	lea	font,a0		;setup shift and shrunk chars
		move.l	font_table,a3
		move.l	#160*230,d0
		add.l	a3,d0
		move.l	d0,timerb

		moveq	#72-1,d0
.loop		lea	offset_tab,a1
		move.l	a1,a5
		moveq	#8,d7
		moveq	#1,d6
.loop2		moveq	#16-1,d1
		sub.b	d7,d1
		asl.w	#1,d1
		lea	0(a3,d1.l),a6
.loop3		move.l	a5,a2
		moveq	#0,d1
		move.b	(a1)+,d1
		asl.w	#1,d1
		lea	-2(a0,d1.l),a4
		move.w	(a4),d4
		moveq	#0,d5
		move.l	d7,d2
.loop4		moveq	#16,d3
		sub.b	(a2)+,d3
		btst	d3,d4
		beq.s	.no
		bset	d2,d5
.no		subq.b	#1,d2
		tst.b	(a2)
		bne.s	.loop4
		move.w	d5,(a6)+
		tst.b	(a1)
		bne.s	.loop3
		eor.b	#1,d6
		add.l	d6,d7
		lea	1(a1),a1
		move.l	a1,a5
		lea	32(a3),a3
		cmp.b	#$7f,(a1)
		bne.s	.loop2
		lea	32(a0),a0
		dbf	d0,.loop
		rts

make_random_stars
		move.l	star_tab,a6
		move.l	#10000,d0
		add.l	a6,d0
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
		add.w	#120,d6
		cmp.w	#320-1,d5
		bhi.s	.next
		cmp.w	#240,d6
		bhi.s	.next
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

timerb_code_gen	lea	stars_timerb_col,a0
		lea	vbl_pal+2,a1
		lea	timerb_col,a2
		move.l	timerb,a4
		move.l	#8000,d0
		add.l	a4,d0
		move.l	d0,star_tab
		move.w	#35-1,d0
		bsr	code_gen

		lea	spray_rasters,a1
		move.l	a1,a2
		move.w	#62,d0
		bsr	code_gen
		move.l	#set_timerb,-8(a4)
		move.l	a4,timerb_col_inst
		lea	set_timerb(pc),a5
		move.w	(a0)+,2(a5)
		move.w	(a1),8(a5)
		move.w	(a1)+,10(a5)
		move.w	(a2),16(a5)
		move.w	(a2),18(a5)
		move.w	(a2),24(a5)
		move.w	(a2)+,26(a5)
		lea	poke_col(pc),a5
		move.w	(a0)+,2(a5)
		move.w	(a1),8(a5)
		move.w	(a1)+,10(a5)
		move.w	(a2),16(a5)
		move.w	(a2),18(a5)
		move.w	(a2),24(a5)
		move.w	(a2)+,26(a5)
		move.w	#20,d0
		bsr	code_gen
		move.l	#instr_rte,-8(a4)
		rts

code_gen	move.w	#$31FC,(a4)+		;=move.w #0,(a5)+
		move.w	(a0)+,(a4)+
		move.w	#$8242,(a4)+		;ffff8242.w
		move.w	#$21FC,(a4)+		;move.l	#0,0.w
		move.w	(a1),(a4)+
		move.w	(a1)+,(a4)+
		move.w	#$8244,(a4)+		;colour for items
		move.w	#$21FC,(a4)+		;move.l	#0,0.w
		move.w	(a2),(a4)+
		move.w	(a2),(a4)+
		move.w	#$8248,(a4)+
		move.w	#$21FC,(a4)+		;move.l #0,0.w
		move.w	(a2),(a4)+
		move.w	(a2)+,(a4)+
		move.w	#$824C,(a4)+
		move.w	#$21FC,(a4)+		;move.l #0,0.w
		lea	8(a4),a5
		move.l	a5,(a4)+
		move.l	#$1204E73,(a4)+		;$120.w + rte
		dbf	d0,code_gen
		rts

set_timerb	move.w	#0,$ffff8242.w
		move.l	#0,$ffff8244.w
		move.l	#0,$ffff8248.w
		move.l	#0,$ffff824C.w
		clr.b	$fffffa1b.w
		move.b	#1,$fffffa21.w
		move.l	#timerb_isr,$120.w
		move.b	#8,$fffffa1b.w
		rte

timerb_isr	move.w	#$2700,sr
		movem.l	a0/d0,-(sp)
		lea	$fffffa21.w,a0	;timerb data
		clr.b	$fffffa1b.w	;stop timerb
		move.b	#2,(a0)		;setup every 2 lines
		move.b	#8,$fffffa1b.w	;start timerb
		move.b	(a0),d0		;get timerb data
.loop		cmp.b	(a0),d0		;is 0
		beq.s	.loop		;yeh
		clr.b	$ffff820a.w	;60 Hz
		rept	18
		nop
		endr

		move.b	#2,$ffff820a.w	;50 Hz
poke_col	move.w	#0,$ffff8242.w
		move.l	#0,$ffff8244.w
		move.l	#0,$ffff8248.w
		move.l	#0,$ffff824c.w
		clr.b	$fffffa1b.w
		move.b	#2,$fffffa21.w
		move.l	#0,$120.w
timerb_col_inst	EQU	*-6
		move.b	#8,$fffffa1b.w
		movem.l	(sp)+,a0/d0
		move.w	#$2300,sr
		rte
instr_rte	rte


main_vbl
;	move.w	#$123,$ffff8240.w
		bsr	check_space
		bsr	set_new_isr
		bsr	clear_sprayer
		bsr	spray_text
		bsr	stars
		bsr	calc_new_spray
		jsr	L00EA		;tune!
;	clr.w	$ffff8240.w
		rte

set_new_isr	lea	vbl_pal,a0
		lea	vbl_pal2,a1
		lea	$ffff8244.w,a2
		move.w	(a0),(a2)+
		move.w	(a0),(a2)+
		move.w	(a1),(a2)+
		move.w	(a1),(a2)+
		move.w	(a1),(a2)+
		move.w	(a1),(a2)+
		clr.b	$fffffa1b.w	;stop timerb
		move.b	#2,$fffffa21.w	;timerb data
		move.l	timerb,$120.w
		move.b	#8,$fffffa1b.w	;ei timerb
		rts


SPRAYER_OFFSET_DOWN_SCREEN	equ	160*80+2
clear_sprayer	lea	spray_pos,a1
		move.l	screen_base,a2
		add.w	#SPRAYER_OFFSET_DOWN_SCREEN,a2
		moveq	#15-1,d0
.loop		move.l	(a1),d1
		lea	0(a2,d1.l),a3
		clr.w	0(a3)
		clr.w	8(a3)
		clr.w	160(a3)
		clr.w	168(a3)
		clr.w	320(a3)
		clr.w	328(a3)
		clr.w	480(a3)
		clr.w	488(a3)
		clr.w	640(a3)
		clr.w	648(a3)
		clr.w	800(a3)
		clr.w	808(a3)
		clr.w	960(a3)
		clr.w	968(a3)
		clr.w	1120(a3)
		clr.w	1128(a3)
		clr.w	1280(a3)
		clr.w	1288(a3)
		clr.w	1440(a3)
		clr.w	1448(a3)
		clr.w	1600(a3)
		clr.w	1608(a3)
		clr.w	1760(a3)
		clr.w	1768(a3)
		clr.w	1920(a3)
		clr.w	1928(a3)
		clr.w	2080(a3)
		clr.w	2088(a3)
		clr.w	2240(a3)
		clr.w	2248(a3)
		clr.w	2400(a3)
		clr.w	2408(a3)
		lea	10(a1),a1
		dbf	d0,.loop
		rts

spray_text	move.l	pos_in_pattern,a0
		lea	spray_count,a2
		cmp.l	#215,(a2)
		beq	.end
		add.l	(a2),a0
		addq.l	#1,(a2)
		lea	spray_pos,a1
		addq.l	#2,(a1)
		moveq	#0,d0
		move.b	15(a0),d0
		subq.b	#1,d0
		divu	#20,d0
		move.w	d0,d1
		sub.w	#5,d1
		swap	d0
		sub.w	#9,d0
		ext.l	d1
		mulu	#160,d1
		ext.l	d1
		move.l	#SPRAYER_OFFSET_DOWN_SCREEN+70,150(a1)
		move.b	#0,154(a1)
		move.b	d0,155(a1)
		move.l	d1,156(a1)
		move.l	spray_ascii_pos,d6
		move.l	screen_base,a2
		add.w	#SPRAYER_OFFSET_DOWN_SCREEN,a2
		move.l	font_table,a3
		moveq	#16-1,d7
.loop		moveq	#0,d0
		move.b	(a0)+,d0
		beq	.null
		exg.l	a0,d6
		move.b	-1(a0,d0.l),d0	;get char
		exg	a0,d6
		sub.b	#32,d0		;rid of ASCII
		mulu	#512,d0		;calc pos of letter
		move.l	d7,d1
		mulu	#32,d1
		add.l	d1,d0
		move.l	(a1),d1
		moveq	#0,d2
		move.b	4(a1),d2
		add.b	5(a1),d2
		tst.b	d2
		bge.s	.byte
		subq.w	#8,d1
		add.b	#16,d2
		bra.s	.word

.byte		cmp.b	#15,d2
		ble.s	.word
		addq.w	#8,d1
		sub.b	#16,d2
.word		add.l	6(a1),d1
		move.l	d1,-10(a1)
		move.b	d2,-6(a1)
		move.b	5(a1),-5(a1)
		move.l	6(a1),-4(a1)
		lea	0(a3,d0.l),a4
		lea	0(a2,d1.l),a5
		divu	#8,d2
		move.w	d2,d3
		mulu	#8,d3
		swap	d2

OFF	set	0
		rept	16
		moveq	#0,d0
		move.w	(a4)+,d0
		swap	d0
		lsr.l	d2,d0
		lsr.l	d3,d0
		or.w	d0,OFF+8(a5)
		swap	d0
		or.w	d0,OFF(a5)
OFF	set	OFF+160
		endr

.null		lea	10(a1),a1
		dbf	d7,.loop
.end		rts


calc_new_spray	lea	spray_count,a0	;have we sprayed all letters?
		cmp.l	#215,(a0)
		bne	.not_finished_spraying

		lea	stay_on_screen_timer,a1
		tst.w	(a1)		;has it run out?
		beq.s	.no		;yes
		subq.w	#1,(a1)
.not_finished_spraying
		rts

.no		lea	clear_text_line_offset,a2	;clear text routine....
		move.l	(a2),d1
		cmp.l	#79*160,d1	;top of spray area
		bne.s	cont_clearing
		move.l	#160*160,(a2)
		move.l	#160*160,4(a2)
		move.w	#300,(a1)	;set time to stay on screen

		clr.l	(a0)
		lea	page_no,a0
		move.l	no_pages,d0	;number of pages to spray
		cmp.l	(a0),d0		;compare present page with max
		bne.s	.no_reset
		clr.l	(a0)		;restart pages
.no_reset	move.l	(a0),d0
		mulu	#200,d0		;each page is 200 bytes long

		lea	spray_ascii,a1
		adda.l	d0,a1
		move.l	a1,spray_ascii_pos
		addq.l	#1,(a0)

		lea	present_spray_pattern,a0
		move.l	max_spray_patterns,d0
		cmp.l	(a0),d0			;have we reached the max
		bne.s	.no_pattern_reset	;no
		clr.l	(a0)
.no_pattern_reset
		move.l	(a0),d0
		mulu	#232,d0		;length of pattern

		lea	spray_patterns,a1
		add.l	d0,a1
		move.l	a1,pos_in_pattern
		addq.l	#1,(a0)		;increase present spray pattern
		rts

cont_clearing	moveq	#0,d5
		move.l	4(a2),d2	;get clear area for lower screen
		move.l	screen_base,a3
		add.w	#4,a3
		lea	0(a3,d1.l),a4
		move.w	d5,0(a4)
		move.w	d5,8(a4)
		move.w	d5,16(a4)
		move.w	d5,24(a4)
		move.w	d5,32(a4)
		move.w	d5,40(a4)
		move.w	d5,48(a4)
		move.w	d5,56(a4)
		move.w	d5,64(a4)
		move.w	d5,72(a4)
		move.w	d5,80(a4)
		move.w	d5,88(a4)
		move.w	d5,96(a4)
		move.w	d5,104(a4)
		move.w	d5,112(a4)
		move.w	d5,120(a4)
		move.w	d5,128(a4)
		move.w	d5,136(a4)
		move.w	d5,144(a4)
		move.w	d5,152(a4)
		lea	0(a3,d2.l),a4
		move.w	d5,0(a4)
		move.w	d5,8(a4)
		move.w	d5,16(a4)
		move.w	d5,24(a4)
		move.w	d5,32(a4)
		move.w	d5,40(a4)
		move.w	d5,48(a4)
		move.w	d5,56(a4)
		move.w	d5,64(a4)
		move.w	d5,72(a4)
		move.w	d5,80(a4)
		move.w	d5,88(a4)
		move.w	d5,96(a4)
		move.w	d5,104(a4)
		move.w	d5,112(a4)
		move.w	d5,120(a4)
		move.w	d5,128(a4)
		move.w	d5,136(a4)
		move.w	d5,144(a4)
		move.w	d5,152(a4)
		sub.l	#160,(a2)
		add.l	#160,4(a2)
		rts

stars		move.l	star_pos,a0
		move.l	screen_base,a1
		moveq	#0,d2
		move.l	#180-1,d0
.star_loop	move.l	(a0),a3
		move.w	(a3)+,d1
		move.w	(a3)+,d2
		lea	0(a1,d2.l),a2
		bclr	d1,(a2)
		addq.l	#4,(a0)
		cmp.l	12(a0),a3
		bne.s	.clr
		move.l	4(a0),(a0)
		move.l	(a0),a3
.clr		move.w	(a3)+,d1
		move.w	(a3)+,d2
		lea	0(a1,d2.l),a2
		bset	d1,(a2)
		addq.l	#8,a0
		dbf	d0,.star_loop
		rts

check_space	move.b	$fffffc02.w,d0
		cmp.b	#$39,d0
		beq.s	.set_exit

		tst.w	hertz_change_delay
		beq.s	.cleared
		sub.w	#1,hertz_change_delay
.cleared	cmp.b	#$b,d0
		beq.s	zero
		cmp.b	#$70,d0
		beq.s	zero
		cmp.b	#$53,d0
		beq.s	reset
		lea	demo_keys,a0
.next		move.w	(a0)+,d1
		bmi.s	.no
		cmp.b	d1,d0
		beq.s	.run
		bra.s	.next
.run		lsr.w	#8,d1
		and.w	#$f,d1
		lsl.w	#2,d1
		lea	filename_table,a0
		move.l	(a0,d1.w),a0
			IFEQ	DOWNLOAD
		lea	$200.w,a1
		REPT	4
		move.l	(a0)+,(a1)+
		ENDR
			ENDC
		move.w	#1,key_found
.no		rts
.set_exit	move.w	#-1,key_found
		move.w	#-1,set_develop
		rts
zero		tst.w	hertz_change_delay
		beq.s	.ok
		rts
.ok		eor.w	#$004,$ffff8240.w
		eor.w	#-1,hertz
		move.w	#10,hertz_change_delay
		rts
reset		move.l	4.w,a0
		jmp	(a0)

***************** THE TUNE (INCLUDE DRIVER AS TUNE IS NOT RELOCATABLE) ***
tune	include	dba6_mus.s		;music driver

*************************************************************************
	even

	IFEQ	DOWNLOAD
	SECTION DATA
	ENDC

stars_timerb_col
	dc.w	$077,$077,$077,$077,$077,$077,$077,$077,$077,$077
	dc.w	$066,$066,$066,$066,$066,$066,$066,$066,$066,$066
	dc.w	$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
	dc.w	$044,$044,$044,$044,$044,$044,$044,$044,$044,$044
	dc.w	$033,$033,$033,$033,$033,$033,$033,$033,$033,$033
	dc.w	$022,$022,$022,$022,$022,$022,$022,$022,$022,$022
	dc.w	$022,$022,$022,$022,$022,$022,$022,$022,$022,$022
	dc.w	$033,$033,$033,$033,$033,$033,$033,$033,$033,$033
	dc.w	$044,$044,$044,$044,$044,$044,$044,$044,$044,$044
	dc.w	$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
	dc.w	$066,$066,$066,$066,$066,$066,$066,$066,$066,$066
	dc.w	$077,$077,$077,$077,$077,$077,$077,$077,$077,$077

vbl_pal	dc.w	$100
	dc.w	$081,$019,$092,$02a,$0a3,$03b,$0b4,$04c
	dc.w	$0c5,$05d,$0d6,$06e,$0e7,$07f,$0ff,$0f7
	dc.w	$0fe,$0f6,$0fd,$0f5,$0fc,$0f4,$0fb,$0f3
	dc.w	$0fa,$0f2,$0f9,$0f1,$0f8,$0f0,$0f0,$0f0

vbl_pal2
	dc.w	$070
	dc.w	$060,$050

timerb_col
	dc.w	$f11,$f12,$f22,$f23,$f33,$f34,$f44,$f45
	dc.w	$555,$556,$666,$667,$777,$777,$777,$777
	dc.w	$777,$777,$667,$666,$556,$555,$445,$444
	dc.w	$334,$333,$223,$222,$112,$111,$001,$000
	dc.w	$000,$000,$000

spray_rasters
	dc.w	$060,$0d0,$050,$0c0,$200,$a00,$300,$b00
	dc.w	$400,$c00,$500,$d00,$600,$e00,$700,$f00
	dc.w	$f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40
	dc.w	$fc0,$f50,$fd0,$f60,$fe0,$f70,$ff0,$ff0
	dc.w	$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0
	dc.w	$3f0,$af0,$2f0,$9f0,$1f0,$8f0,$0f8,$0f1
	dc.w	$0f9,$0f2,$0fa,$0f3,$0fb,$0f4,$0fc,$0f5
	dc.w	$0fd,$0f6,$0fe,$0f7,$0ff,$07f,$0ef,$06f
	dc.w	$0df,$05f,$0cf,$04f,$0bf,$03f,$0af,$02f
	dc.w	$09f,$01f,$08f,$00f,$007,$00e,$006,$00d
	dc.w	$005,$00c,$004,$00b,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000



offset_tab
	dc.b	8
	dc.b	0,1,8,16
	dc.b	0,1,4,8,16
	dc.b	0,1,4,8,12,16
	dc.b	0,1,2,4,8,12,16
	dc.b	0,1,2,4,8,12,14,16
	dc.b	0,1,2,4,6,8,12,14,16
	dc.b	0,1,2,4,6,8,10,12,14,16
	dc.b	0,1,2,3,4,6,8,10,12,14,16
	dc.b	0,1,2,3,4,6,8,10,12,14,15,16
	dc.b	0,1,2,3,4,5,6,8,10,12,14,15,16
	dc.b	0,1,2,3,4,5,6,8,10,12,13,14,15,16
	dc.b	0,1,2,3,4,5,6,7,8,10,12,13,14,15,16
	dc.b	0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,16
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
	dc.b	0,127,0

present_spray_pattern	dc.l	1
max_spray_patterns	dc.l	8

pos_in_pattern	dc.l	spray_patterns

;   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20
;  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40
;  41  42  43  44  45  46  47  48  49  50  51  52  53  54  55  56  57  58  59  60
;  61  62  63  64  65  66  67  68  69  70  71  72  73  74  75  76  77  78  79  80
;  81  82  83  84  85  86  87  88  89  90  91  92  93  94  95  96  97  98  99 100
; 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120
; 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140
; 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160
; 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180
; 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200


spray_patterns
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;15 nulls
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
 dc.b	40,60,80,100,120,140,160,180,200,199,198,197,196
	DC.B	$C3,$C2,$C1,$C0,$BF,$BE,$BD,$BC
	DC.B	$BB,$BA,$B9,$B8,$B7,$B6,$B5,$A1
	DC.B	$8D,$79,$65,$51,$3D,$29,$15,$16
	DC.B	$17,$18,$19,$1A,$1B,$1C,$1D,$1E
	DC.B	$1F,$20,$21,$22,$23,$24,$25,$26
	DC.B	$27,$3B,$4F,$63,$77,$8B,$9F,$B3
	DC.B	$B2,$B1,$B0,$AF,$AE,$AD,$AC,$AB
	DC.B	$AA,$A9,$A8,$A7,$A6,$A5,$A4,$A3
	DC.B	$A2,$8E,$7A,$66,$52,$3E,$2A,$2B
	DC.B	$2C,$2D,$2E,$2F,$30,$31,$32,$33
	DC.B	$34,$35,$36,$37,$38,$39,$3A,$4E
	DC.B	$62,$76,$8A,$9E,$9D,$9C,$9B,$9A
	DC.B	$99,$98,$97,$96,$95,$94,$93,$92
	DC.B	$91,$90,$8F,$7B,$67,$53,$3F,$40
	DC.B	$41,$42,$43,$44,$45,$46,$47,$48
	DC.B	$49,$4A,$4B,$4C,$4D,$61,$75,$89
	DC.B	$88,$87,$86,$85,$84,$83,$82,$81
	DC.B	$80,$7F,$7E,$7D,$7C,$68,$54,$55
	DC.B	$56,$57,$58,$59,$5A,$5B,$5C,$5D
	DC.B	$5E,$5F,$60,$74,$73,$72,$71,$70
	DC.B	$6F,$6E,$6D,$6C,$6B,$6A,$69,$C9
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;end in 16 nulls


	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;15 null start
	dc.b	1,21,41,61,$51,$65,$79,$8D,$A1
	dc.b	$B5,$B6,$A2,$8E,$7A,$66,$52,$3E
	dc.b	$2A,$16,2,3,$17,$2B,$3F,$53
	dc.b	$67,$7B,$8F,$A3,$B7,$B8,$A4,$90
	DC.B	$7C,$68,$54,$40,$2C,$18,4,5
	DC.B	$19,$2D,$41,$55,$69,$7D,$91,$A5
	DC.B	$B9,$BA,$A6,$92,$7E,$6A,$56,$42
	DC.B	$2E,$1A,6,7,$1B,$2F,$43,$57
	DC.B	$6B,$7F,$93,$A7,$BB,$BC,$A8,$94
	DC.B	$80,$6C,$58,$44,$30,$1C,8,9
	DC.B	$1D,$31,$45,$59,$6D,$81,$95,$A9
	DC.B	$BD,$BE,$AA,$96,$82,$6E,$5A,$46
	DC.B	$32,$1E,$A,$B,$1F,$33,$47,$5B
	DC.B	$6F,$83,$97,$AB,$BF,$C0,$AC,$98
	DC.B	$84,$70,$5C,$48,$34,$20,$C,$D
	DC.B	$21,$35,$49,$5D,$71,$85,$99,$AD
	DC.B	$C1,$C2,$AE,$9A,$86,$72,$5E,$4A
	DC.B	$36,$22,$E,$F,$23,$37,$4B,$5F
	DC.B	$73,$87,$9B,$AF,$C3,$C4,$B0,$9C
	DC.B	$88,$74,$60,$4C,$38,$24,$10,$11
	DC.B	$25,$39,$4D,$61,$75,$89,$9D,$B1
	DC.B	$C5,$C6,$B2,$9E,$8A,$76,$62,$4E
	DC.B	$3A,$26,$12,$13,$27,$3B,$4F,$63
	DC.B	$77,$8B,$9F,$B3,$C7,$C8,$B4,$A0
	DC.B	$8C,$78,$64,$50,$3C,$28,$14,$C9
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	1,2,3,4,5,6,7,8,9,$A,$B,$C,$D,$E,$F,$10,$11
	DC.B	$12,$13,$14,$28,$27,$26,$25,$24
	DC.B	$23,$22,$21,$20,$1F,$1E,$1D,$1C
	DC.B	$1B,$1A,$19,$18,$17,$16,$15,$29
	DC.B	$2A,$2B,$2C,$2D,$2E,$2F,$30,$31
	DC.B	$32,$33,$34,$35,$36,$37,$38,$39
	DC.B	$3A,$3B,$3C,$50,$4F,$4E,$4D,$4C
	DC.B	$4B,$4A,$49,$48,$47,$46,$45,$44
	DC.B	$43,$42,$41,$40,$3F,$3E,$3D,$51
	DC.B	$52,$53,$54,$55,$56,$57,$58,$59
	DC.B	$5A,$5B,$5C,$5D,$5E,$5F,$60,$61
	DC.B	$62,$63,$64,$78,$77,$76,$75,$74
	DC.B	$73,$72,$71,$70,$6F,$6E,$6D,$6C
	DC.B	$6B,$6A,$69,$68,$67,$66,$65,$79
	DC.B	$7A,$7B,$7C,$7D,$7E,$7F,$80,$81
	DC.B	$82,$83,$84,$85,$86,$87,$88,$89
	DC.B	$8A,$8B,$8C,$A0,$9F,$9E,$9D,$9C
	DC.B	$9B,$9A,$99,$98,$97,$96,$95,$94
	DC.B	$93,$92,$91,$90,$8F,$8E,$8D,$A1
	DC.B	$A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9
	DC.B	$AA,$AB,$AC,$AD,$AE,$AF,$B0,$B1
	DC.B	$B2,$B3,$B4,$C8,$C7,$C6,$C5,$C4
	DC.B	$C3,$C2,$C1,$C0,$BF,$BE,$BD,$BC
	DC.B	$BB,$BA,$B9,$B8,$B7,$B6,$B5,$C9
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	$5a,$5B,$5C,$5D,$5E,$5F,$60,$61,$62
	DC.B	$63,$64,$78,$8C,$A0,$B4,$C8,$C7
	DC.B	$C6,$C5,$C4,$C3,$C2,$C1,$C0,$BF
	DC.B	$BE,$BD,$BC,$BB,$BA,$B9,$B8,$B7
	DC.B	$B6,$B5,$A1,$A2,$A3,$A4,$A5,$A6
	DC.B	$A7,$A8,$A9,$AA,$AB,$AC,$AD,$AE
	DC.B	$AF,$B0,$B1,$B2,$B3,$9F,$9E,$9D
	DC.B	$9C,$9B,$9A,$99,$98,$97,$96,$95
	DC.B	$94,$93,$92,$91,$90,$8F,$8E,$8D
	DC.B	$79,$7A,$7B,$7C,$7D,$7E,$7F,$80
	DC.B	$81,$82,$83,$84,$85,$86,$87,$88
	DC.B	$89,$8A,$8B,$77,$76,$75,$74,$73
	DC.B	$72,$71,$70,$6F,$6E,$6D,$6C,$6B
	DC.B	$6A,$69,$68,$67,$66,$65,$51,$52
	DC.B	$53,$54,$55,$56,$57,$58,$59,$45
	DC.B	$44,$43,$42,$41,$40,$3F,$3E,$3D
	DC.B	$29,$2A,$2B,$2C,$2D,$2E,$2F,$30
	DC.B	$31,$1D,$1C,$1B,$1A,$19,$18,$17
	DC.B	$16,$15,1,2,3,4,5,6
	DC.B	7,8,9,$A,$B,$C,$D,$E
	DC.B	$F,$10,$11,$12,$13,$14,$28,$3C
	DC.B	$50,$4F,$4E,$4D,$4C,$4B,$4A,$49
	DC.B	$48,$47,$46,$32,$33,$34,$35,$36
	DC.B	$37,$38,$39,$3A,$3B,$27,$26,$25
	DC.B	$24,$23,$22,$21,$20,$1F,$1E,$C9
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	1,$16,$2B,$40,$55,$6A,$7F,$94,$A9
	DC.B	$BE,$AB,$98,$85,$72,$5F,$4C,$39
	DC.B	$26,$13,$28,$3B,$4E,$61,$74,$87
	DC.B	$9A,$AD,$C0,$96,$81,$6C,$57,$42
	DC.B	$2D,$18,3,$29,$3E,$53,$68,$7D
	DC.B	$92,$A7,$BC,$83,$70,$5D,$4A,$37
	DC.B	$24,$11,$50,$63,$76,$89,$9C,$AF
	DC.B	$C2,$6E,$59,$44,$2F,$1A,5,$51
	DC.B	$66,$7B,$90,$A5,$BA,$5B,$48,$35
	DC.B	$22,$F,$78,$8B,$9E,$B1,$C4,$46
	DC.B	$31,$1C,7,$79,$8E,$A3,$B8,$33
	DC.B	$20,$D,$A0,$B3,$C6,$1E,9,$A1
	DC.B	$B6,$B,$C8,$B4,$9F,$8A,$75,$60
	DC.B	$4B,$36,$21,$C,$1F,$32,$45,$58
	DC.B	$6B,$7E,$91,$A4,$B7,$A2,$8D,$7A
	DC.B	$67,$54,$41,$2E,$1B,8,$1D,$47
	DC.B	$5C,$71,$86,$9B,$B0,$C5,$B2,$8C
	DC.B	$77,$62,$4D,$38,$23,$E,$34,$5A
	DC.B	$6D,$80,$93,$A6,$B9,$8F,$65,$52
	DC.B	$3F,$2C,$19,6,$30,$6F,$84,$99
	DC.B	$AE,$C3,$9D,$64,$4F,$3A,$25,$10
	DC.B	$49,$82,$95,$A8,$BB,$7C,$3D,$2A
	DC.B	$17,4,$43,$97,$AC,$C1,$88,$3C
	DC.B	$27,$12,$5E,$AA,$BD,$69,$15,2
	DC.B	$56,$BF,$73,$14,$A,$B5,$C7,$C9
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	1,$15,$29,$3D,$51,$65,$79,$8D,$A1
	DC.B	$B5,$B7,$A3,$8F,$7B,$67,$53,$3F
	DC.B	$2B,$17,3,5,$19,$2D,$41,$55
	DC.B	$69,$7D,$91,$A5,$B9,$BB,$A7,$93
	DC.B	$7F,$6B,$57,$43,$2F,$1B,7,9
	DC.B	$1D,$31,$45,$59,$6D,$81,$95,$A9
	DC.B	$BD,$BF,$AB,$97,$83,$6F,$5B,$47
	DC.B	$33,$1F,$B,$D,$21,$35,$49,$5D
	DC.B	$71,$85,$99,$AD,$C1,$C3,$AF,$9B
	DC.B	$87,$73,$5F,$4B,$37,$23,$F,$11
	DC.B	$25,$39,$4D,$61,$75,$89,$9D,$B1
	DC.B	$C5,$C7,$B3,$9F,$8B,$77,$63,$4F
	DC.B	$3B,$27,$13,$14,$28,$3C,$50,$64
	DC.B	$78,$8C,$A0,$B4,$C8,$C6,$B2,$9E
	DC.B	$8A,$76,$62,$4E,$3A,$26,$12,$10
	DC.B	$24,$38,$4C,$60,$74,$88,$9C,$B0
	DC.B	$C4,$C2,$AE,$9A,$86,$72,$5E,$4A
	DC.B	$36,$22,$E,$C,$20,$34,$48,$5C
	DC.B	$70,$84,$98,$AC,$C0,$BE,$AA,$96
	DC.B	$82,$6E,$5A,$46,$32,$1E,$A,8
	DC.B	$1C,$30,$44,$58,$6C,$80,$94,$A8
	DC.B	$BC,$BA,$A6,$92,$7E,$6A,$56,$42
	DC.B	$2E,$1A,6,4,$18,$2C,$40,$54
	DC.B	$68,$7C,$90,$A4,$B8,$B6,$A2,$8E
	DC.B	$7A,$66,$52,$3E,$2A,$16,2,$C9
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	$65,$79,$8D,$A1,$B5,$B6,$A2,$8E,$7A
	DC.B	$66,$67,$7B,$8F,$A3,$B7,$B8,$A4
	DC.B	$90,$7C,$68,$69,$7D,$91,$A5,$B9
	DC.B	$BA,$A6,$92,$7E,$6A,$6B,$7F,$93
	DC.B	$A7,$BB,$BC,$A8,$94,$80,$6C,$6D
	DC.B	$81,$95,$A9,$BD,$BE,$AA,$96,$82
	DC.B	$6E,$6F,$83,$97,$AB,$BF,$C0,$AC
	DC.B	$98,$84,$70,$71,$85,$99,$AD,$C1
	DC.B	$C2,$AE,$9A,$86,$72,$73,$87,$9B
	DC.B	$AF,$C3,$C4,$B0,$9C,$88,$74,$75
	DC.B	$89,$9D,$B1,$C5,$C6,$B2,$9E,$8A
	DC.B	$76,$77,$8B,$9F,$B3,$C7,$C8,$B4
	DC.B	$A0,$8C,$78,$64,$50,$3C,$28,$14
	DC.B	$13,$27,$3B,$4F,$63,$62,$4E,$3A
	DC.B	$26,$12,$11,$25,$39,$4D,$61,$60
	DC.B	$4C,$38,$24,$10,$F,$23,$37,$4B
	DC.B	$5F,$5E,$4A,$36,$22,$E,$D,$21
	DC.B	$35,$49,$5D,$5C,$48,$34,$20,$C
	DC.B	$B,$1F,$33,$47,$5B,$5A,$46,$32
	DC.B	$1E,$A,9,$1D,$31,$45,$59,$58
	DC.B	$44,$30,$1C,8,7,$1B,$2F,$43
	DC.B	$57,$56,$42,$2E,$1A,6,5,$19
	DC.B	$2D,$41,$55,$54,$40,$2C,$18,4
	DC.B	3,$17,$2B,$3F,$53,$52,$3E,$2A
	DC.B	$16,2,1,$15,$29,$3D,$51,$C9
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	$b5,$A1,$B6,$B7,$A2,$8D,$79,$8E,$A3
	DC.B	$B8,$B9,$A4,$8F,$7A,$65,$51,$66
	DC.B	$7B,$90,$A5,$BA,$BB,$A6,$91,$7C
	DC.B	$67,$52,$3D,$29,$3E,$53,$68,$7D
	DC.B	$92,$A7,$BC,$BD,$A8,$93,$7E,$69
	DC.B	$54,$3F,$2A,$15,1,$16,$2B,$40
	DC.B	$55,$6A,$7F,$94,$A9,$BE,$BF,$AA
	DC.B	$95,$80,$6B,$56,$41,$2C,$17,2
	DC.B	3,$18,$2D,$42,$57,$6C,$81,$96
	DC.B	$AB,$C0,$C1,$AC,$97,$82,$6D,$58
	DC.B	$43,$2E,$19,4,5,$1A,$2F,$44
	DC.B	$59,$6E,$83,$98,$AD,$C2,$C3,$AE
	DC.B	$99,$84,$6F,$5A,$45,$30,$1B,6
	DC.B	7,$1C,$31,$46,$5B,$70,$85,$9A
	DC.B	$AF,$C4,$C5,$B0,$9B,$86,$71,$5C
	DC.B	$47,$32,$1D,8,9,$1E,$33,$48
	DC.B	$5D,$72,$87,$9C,$B1,$C6,$C7,$B2
	DC.B	$9D,$88,$73,$5E,$49,$34,$1F,$A
	DC.B	$B,$20,$35,$4A,$5F,$74,$89,$9E
	DC.B	$B3,$C8,$B4,$9F,$8A,$75,$60,$4B
	DC.B	$36,$21,$C,$D,$22,$37,$4C,$61
	DC.B	$76,$8B,$A0,$8C,$77,$62,$4D,$38
	DC.B	$23,$E,$F,$24,$39,$4E,$63,$78
	DC.B	$64,$4F,$3A,$25,$10,$11,$26,$3B
	DC.B	$50,$3C,$27,$12,$13,$28,$14,$C9
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


page_no		dc.l	1 
spray_ascii_pos	dc.l	spray_ascii 
no_pages	dc.l	11		;number of screens to spray
spray_ascii
	DC.B	'....................'
	dc.b	'.                  .'
	dc.b	'.                  .'
	DC.B	'. PPP   OOO  V   V .'
	DC.B	'. P  P O   O V   V .'
	dc.b	'. PPP  O   O V   V .'
	DC.B	'. P    O   O  V V  .'
	DC.B	'. P     OOO    V   .'
	DC.B	'.                  .'
	dc.b	'....................'

	dc.b	'````````````````````'
	dc.b	'`                  `'
	DC.B	'`  1  22222 66666  `'
	dc.b	'` 11      2 6      `'
	dc.b	'`  1  22222 66666  `'
	dc.b	'`  1  2     6   6  `'
	DC.B	'` 111 22222 66666  `'
	dc.b	'` ---------------  `'
	DC.B	'`                  `'
	dc.b	'````````````````````'

	dc.b	'\\\\\\\\\\\\\\\\\\\\'
	dc.b	'\     MUSIC BY     \'
	DC.B	'\     SCAVENGER    \'
	dc.b	'\    OF SYNERGY    \'
	DC.B	'\                  \'
	dc.b	'\    RIPPED FROM   \'
	dc.b	'\  DBA MAGAZINE 6  \'
	DC.B	'\  BY MAC SYS DATA \'
	dc.b	'\                  \'
	DC.B	'\\\\\\\\\\\\\\\\\\\\'

	dc.b	'********************'
	dc.b	'*                  *'
	dc.b	'*     CREDITS      *'
	dc.b	'*                  *'
	dc.b	'*  MENU CODED BY:  *'
	dc.b	'*      M.S.D.      *'
	dc.b	'*                  *'
	dc.b	'* BASED ON WORK BY *'
	dc.b	'*  ORION OF FUZION *'
	dc.b	'********************'
 
	dc.b	'````````````````````'
	dc.b	'`P.O.V. MEMBERS ARE`'
	dc.b	'`                  `'
	dc.b	'`   MAC SYS DATA   `'
	dc.b	'`                  `'
	dc.b	'`    OZYMANDIAS    `'
	dc.b	'`                  `'
	dc.b	'`      BORIS       `'
	dc.b	'`                  `'
	dc.b	'````````````````````'

	dc.b	'[[[[[[[[[[[[[[[[[[[['
	dc.b	'[                  ['
	dc.b	'[      ART BY:     ['
	dc.b	'[    OZYMANDIAS    ['
	dc.b	'[                  ['
	dc.b	'[                  ['
	dc.b	'[  RELEASE DATE:   ['
	dc.b	'[  20TH DEC 1992   ['
	dc.b	'[                  ['
	dc.b	'[[[[[[[[[[[[[[[[[[[['

	dc.b	'\\\\\\\\\\\\\\\\\\\\'
	DC.B	'\     GREETS TO:   \'
	dc.b	'\                  \'
	DC.B	'\ FUZION, SYNERGY  \'
	dc.b	'\  BBC, ADR, KGB   \'
	dc.b	'\ SYNDICATE, CHAOS \'
	DC.B	'\ TOWER PD, TNC PD \'
	DC.B	'\ DEL, NEXT, MUG UK\'
	dc.b	'\ DF, PIXEL TWINS  \'
	DC.B	'\\\\\\\\\\\\\\\\\\\\'

	dc.b	'********************'
	dc.b	'* INNER CIRCLE,NOD *'
	dc.b	'*INSOMNIA, DR SYNE *'
	dc.b	'*PROPHECY PD (RIP) *'
	dc.b	'*ROGGIE, REPLICANTS*'
	dc.b	'* EQUINOX, EMPIRE  *'
	dc.b	'* EP+BLIND BASTARD *'
	dc.b	"*  DIAMOND DESIGN  *"
	dc.b	'* THE SOURCE (RIP) *'
	DC.B	'********************'
 
	dc.b	'*\*\*\*\*\*\*\*\*\*\'
	dc.b	'\                  *'
	dc.b	'*  PAL PD,  OBERJE \'
	dc.b	'\ STAX, PURE ENERGY*'
	dc.b	'* UTOS, ANIMAL MINE\'
	dc.b	'\RIPPED OFF, GRAZEY*'
	dc.b	'* TED WEBB AND ALL \'
	dc.b	"\ THE REST I KNOW  *"
	dc.b	"*  I'VE FORGOTTEN! \"
	dc.b	'\*\*\*\*\*\*\*\*\*\*'

	dc.b	'````````````````````'
	dc.b	'` CONTACT P.O.V. AT`'
	dc.b	'`                  `'
	dc.b	'`      P.O.V       `'
	dc.b	'`   P.O. BOX 40    `'
	dc.b	'`THORNTON-CLEVELEYS`'
	dc.b	'`    LANCASHIRE    `'
	dc.b	'`     ENGLAND      `'
	dc.b	'`     FY5 3PH      `'
	dc.b	'````````````````````'

	dc.b	'\\\\\\\\\\\\\\\\\\\\'
	DC.B	'\  IF YOU ARE A PD \'
	DC.B	'\ LIBRARY IN NEED  \'
	DC.B	'\  OF P.O.V. DISCS \'
	DC.B	'\ THEN WRITE TO THE\'
	DC.B	'\  SAME PO BOX BUT \'
	DC.B	'\   ADDRESS IT TO  \'
	DC.B	"\   'GEORGE'  AT   \"
	DC.B	"\    'TOWER PD'    \"
	DC.B	'\\\\\\\\\\\\\\\\\\\\'

usp_save	dc.l	0 	;keep in data seg not bss

clear_text_line_offset
	dc.l	160*160
	dc.l	161*160

stay_on_screen_timer	dc.w	65		;length of time text stays on screen

spray_count	dc.l	0
font_table	dc.l	0
star_tab	dc.l	0
star_pos	dc.l	0
star_null	dc.l	0
timerb	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0

spray_pos	dcb.w	80,0

demo_keys
	dc.b	0, $02	;keybd	1
	dc.b	1, $03	;	2
	dc.b	2, $04	;	3
	dc.b	3, $05	;	4
	dc.b	4, $06	;	5
	dc.b	5, $07	;	6
	dc.b	6, $08	;	7
;	dc.b	7, $09	;	8
;	dc.b	8, $0a	;	9

	dc.b	0, $6d	;keypad 1
	dc.b	1, $6e	;	2
	dc.b	2, $6f	;	3
	dc.b	3, $6a	;	4
	dc.b	4, $6b	;	5
	dc.b	5, $6c	;	6
	dc.b	6, $67	;	7
;	dc.b	7, $68	;	8
;	dc.b	8, $69	;	9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7	;,exec8,exec9
exec1	dc.b	"FROG",0
	even
exec2	dc.b	"PURE.DAT",0
	even
exec3	dc.b	"extream",0
	even
exec4	dc.b	"madvis",0
	even
exec5	dc.b	"fanatics",0
	even
exec6	dc.b	"PUL167",0
	even
exec7	dc.b	"copier.pov",0
	even
;exec8	dc.b	"copier.pov",0
;	even
;exec9	dc.b	"copier.pov",0
;	even

font		incbin	med_font.dat

pic		incbin	logo.pi1


		ds.b	1000
stop		ds.l	1		;leave this in data as stack will get wiped out

	IFEQ	DOWNLOAD
	SECTION BSS
	ENDC

bssstart

old_rez		ds.b	1
old_base	ds.l	1
old_hz		ds.b	1
old484		ds.b	1
	even
hertz			ds.w	1
hertz_change_delay	ds.w	1
key_found	ds.w	1
set_develop	ds.w	1
old_pal		ds.b	32
old_mfp		ds.b	30
old_psg		ds.b	16
old_vbl		ds.l	1
old_timerb	ds.l	1
old_timerd	ds.l	1

black		ds.b	32
screen_base	ds.l	1

		ds.b	256
screens	
		ds.b	160*248
buffer		ds.b	160*248

		ds.b	512*215

bssend

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
