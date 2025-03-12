*************************************************************************
*				P.O.V. 125				*
*				----------				*
*									*
* Coded by:	MAC SYS DATA						*
*									*
*									*
* Grafix by:	OZ							*
*									*
*									*
* Music by:	BIG ALEC (SID CHIP (C64) EMULATOR)			*
*									*
*									*
* Date:		27/12/92						*
*									*
*									*
* 			All code ½ P.O.V. 1992				*
*									*
*************************************************************************
*
* Revamped bob routine (only the second revision from my original code)
*
* I would have used a code generator but I use 3 different bobs and it
* would have made the menu 1 meg only.
*
*
*
****** DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
NO	equ	0
DOWNLOAD	equ	NO

		ifne	DOWNLOAD		;version 1 download code
		include	sttx1.s
		org	$1000

Code_Start
Exec_Addr
		ENDC
*************************************************************************



AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

FINAL=YES	;Final version (menu will NOT P_EXEC with this set to NO)
		;Final will also get rid of unneeded routines







****** MACROS ********************************
FADE_	macro
		REPT	8
		dc.l	4,check_fade
		ENDR
	ENDM
**********************************************
		ifeq	DOWNLOAD
*********************
   SECTION TEXT
*********************
		endc


BOB_DEPTH	equ	64
BOB_WIDTH	equ	4		;words

		ifeq	DOWNLOAD
		ifeq	AUTORUN4
begin		bra	start
		ds.l	100
ustack		ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec		pea	get_type
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp
		cmp.w	#"$$",type		;is GEM EXEC or D_CLICK?
		beq.s	.exit

.ss		lea	type(pc),a0
		move.l	#bssend-start,d0
.clear		clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.clear

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
.reset		move.l	4.w,-(sp)
		rts
.exit		clr.w	-(sp)
		trap	#1
type		dc.w	0
blank		dc.l	0
get_type	move.w	$200.w,type
		rts
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
		ENDC

		bra	msd
	dc.b	"   Well done hacker, you got past the shit protection (or "
	dc.b	"you've got a cartridge).    If you're desperate to rip code "
	dc.b	"why not write to me and I'll send the source code. Better still "
	dc.b	"look out for the source code disc I'll be releasing after this "
	dc.b	"disc....   MSD 29/12/92.   "
	even
msd
		bsr	clear_bss
		ifeq	DOWNLOAD
		bsr	set_super
		endc
		bset	#1,$ffff820a.w
		move.b	#$12,$fffffc02.w	;DI mouse
		bsr	get_screen_base
		bsr	get_old_palette

		bsr	sort_middle_text

		move.w	#-1,disc_enable
		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.b	$ffff8260.w,original_rez
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		clr.b	$ffff8260.w
		bsr	set_up
		jsr	save_isr

main_loop
		jsr	vsync
		bsr	set_screen	;screen flip
;		move.w	#$123,$ffff8240.w
		bsr	check_pipe
		bsr	bobs
		bsr	print_middle_text
;		move.w	pic+2,$ffff8240.w

		btst	#7,$fffffc02.w
		bne.s	main_loop

		moveq	#0,d0
		move.b	$fffffc02.w,d0

		ifeq	FINAL
		cmp.b	#01,d0		;escape
		beq.s	exit
		endc

		cmp.b	#$b,d0		;0 key
		beq	zero

		cmp.b	#$70,d0		;0 keypad
		beq	zero

		cmp.b	#$53,d0
		beq	do_reset

		lea	key_codes,a0
.next		move.w	(a0)+,d1
		bmi	main_loop
		cmp.b	d1,d0
		beq.s	.run
		bra.s	.next
.run		lsr.w	#8,d1
		and.w	#$f,d1
		lsl.w	#2,d1
		lea	filename_table,a0
		move.l	(a0,d1.w),a0
		lea	$200.w,a1
		REPT	4
		move.l	(a0)+,(a1)+
		ENDR

exit		jsr	stop_isr
		bsr	set_old_palette
		move.b	original_rez,$ffff8260.w

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		move.b	#$8,$fffffc02.w

		tst.w	hertz_switch
		beq.s	.hz50
		bclr	#1,$ffff820a.w
.hz50

		move.w	#11,-(sp)
		trap	#1
		addq.l	#2,sp
		tst.l	d0
		beq.s	.no
		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		bra.s	.hz50
.no

		ifeq	DOWNLOAD
		bsr	set_user
		endc

		ifeq	DOWNLOAD
		ifne	FINAL
		ifeq	AUTORUN4
		bra	exec
		endc
		elseif
		clr.w	-(sp)
		trap	#1
		endc
		endc

do_reset	move.l	4.w,a0
		jmp	(a0)

zero		tst.w	zero_counter
		bne	main_loop 
		eor.w	#$200,top_pal
		eor.w	#$ffff,hertz_switch
		move.w	#10,zero_counter
		bra	main_loop

*********************************************************************
scroll		move.l	scr_now,a1
		add.w	#(160*186)+6,a1
		lea	font_offsets,a2
		lea	font,a3
		move.l	scroll_pointer,a4
		move.l	a4,a5
		moveq	#0,d4
		moveq	#40,d5
		move.w	char_offset,d6
next_char	move.b	(a5),d7		;get a letter
		sub.b	#32,d7		;rid of ASCII
		ext.w	d7
		moveq	#0,d0
		move.l	a3,a0
		move.b	(a2,d7),d0
		mulu	#4*14,d0		;14 lines deep

		add.w	d0,a0
		move.w	d6,d0
		mulu	#14,d0			;14 lines deep
		add.w	d0,a0
.column
OFF	set	0
		REPT	14		;scroll font is 14 lines deep
		move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
		ENDR
		subq.w	#1,d5
		beq.s	.finish
		addq.w	#1,a1		;lower byte of word
		tst.w	d4
		beq.s	.skip		;if D4=0 then do next word
		addq.w	#6,a1		;else goto next word on screen
.skip		not.w	d4
		addq.w	#1,d6		;character offset
		and.w	#3,d6
		bne.s	.column
		addq.w	#1,a5		;scroll pointer
		tst.b	(a5)		;is end of text?
		bpl.s	next_char	;NO!
		lea	scroll_text,a5	;do reset scrolline
		bra.s	next_char
.finish		addq.w	#1,char_offset
		and.w	#3,char_offset
		bne.s	.end
		addq.w	#1,a4
		tst.b	(a4)
		bpl.s	.end
		lea	scroll_text,a4
.end		move.l	a4,scroll_pointer
		rts




print_middle_text
		tst.w	disc_enable
		beq.s	.do_stuff
		rts
.do_stuff	move.l	middle_text_pos,a1
		move.l	scr_now,a0
		move.l	scr_other,a3

		lea	48*160(a0),a0
		lea	48*160(a3),a3
.restart	moveq	#0,d1
		move.b	(a1)+,d1
		move.l	a1,middle_text_pos
		cmp.b	#"^",d1		;termintor
		bne.s	.do_text
		move.w	#-1,disc_enable
		clr.b	xpos
		clr.b	ypos
		clr.w	byte_offset
		rts
.do_text	cmp.b	#13,d1
		bne.s	.notcr
		clr.b	xpos
		clr.w	byte_offset
		bra.s	.restart
.notcr		cmp.b	#10,d1
		bne.s	.notlf
		addq.b	#1,ypos
		bra.s	.restart
.notlf		cmp.b	#9,d1		;HORIZONTAL TAB
		bne.s	.notab		;routine added 11/2/92 for print speed
		add.b	#8,xpos
		bra	.restart
.notab		sub.w	#32,d1
		mulu	#6,d1	;each char is 6 bytes long
		lea	minifont,a2
		add.w	d1,a2

		moveq	#0,d0
		move.b	ypos,d0
		mulu	#160*7,d0	;drop down 7 pixels...

		add.w	d0,a0
		add.w	d0,a3

		move.b	xpos,d0
		and.w	#$ff,d0
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		add.w	d0,a0
		add.w	d0,a3

		add.w	byte_offset,a0
		add.w	byte_offset,a3
		add.w	tab_offset,a0
		add.w	tab_offset,a3

		move.b	(a2),(a0)
		move.b	(a2),(a3)
		move.b	(a2),6(a0)
		move.b	(a2)+,6(a3)

		move.b	(a2),160(a0)
		move.b	(a2),160(a3)
		move.b	(a2),166(a0)
		move.b	(a2)+,166(a3)

		move.b	(a2),320(a0)
		move.b	(a2),320(a3)
		move.b	(a2),326(a0)
		move.b	(a2)+,326(a3)

		move.b	(a2),480(a0)
		move.b	(a2),480(a3)
		move.b	(a2),486(a0)
		move.b	(a2)+,486(a3)

		move.b	(a2),640(a0)
		move.b	(a2),640(a3)
		move.b	(a2),646(a0)
		move.b	(a2)+,646(a3)

		move.b	(a2),800(a0)
		move.b	(a2),800(a3)	;chars are 6 pixels high
		move.b	(a2),806(a0)
		move.b	(a2)+,806(a3)

		addq.b	#1,xpos
		eor.w	#1,byte_offset
		rts



sort_middle_text
		lea	middle_text,a0
		lea	disc_start_table,a1
		move.l	a0,(a1)+	;poke start of disc into lookup table
.loop		cmp.b	#$ff,(a0)	;is end of list???
		beq.s	.quit
		move.b	(a0)+,d0
		cmp.b	#'^',d0
		bne.s	.loop
		move.b	(a0)+,d0	;cr
		move.b	(a0)+,d0	;lf
		move.l	a0,(a1)+
		bra.s	.loop
.quit		rts


check_pipe	tst.w	general_timer
		beq.s	.do
		rts
.do		move.w	pipe_offset,d0
		lsl.w	#3,d0		;*8
		lea	pipe_seq,a0
		move.l	0(a0,d0.w),d1
		bpl.s	.no_reset

		moveq	#0,d0
		move.w	d0,pipe_offset
		move.l	0(a0,d0.w),d1
		move.l	#middle_text,middle_text_pos
		rts

.no_reset	move.w	d1,general_timer
		move.l	4(a0,d0.w),a0
		add.w	#1,pipe_offset
		jmp	(a0)

pipe_offset	dc.w	0
pipe_seq	dc.l	1,set_fade_up
		FADE_

		dc.l	200,null
		dc.l	1,set_fade_down
		FADE_

		dc.l	1,set_new_bob_path1
		dc.l	1,set_fade_up
		FADE_

		dc.l	700,null
		dc.l	1,set_fade_down
		FADE_


* start text writer
		dc.l	1,disable_bobs
		dc.l	1,do_clear		;clear bob area
		dc.l	1,set_white_pal
		FADE_
		dc.l	1,enable_type_writer
		dc.l	300,null

		dc.l	1,set_fade_down
		FADE_
		dc.l	1,do_clear		;clear bob area
		dc.l	1,enable_bobs
************************************************

		dc.l	1,set_new_bob_path2
		dc.l	1,set_fade_up
		FADE_

		dc.l	800,null
		dc.l	1,set_fade_down
		FADE_
		dc.l	1,set_new_pal1
		FADE_
		dc.l	700,null

* start text writer again *******************
		dc.l	1,set_fade_down
		FADE_
		dc.l	1,disable_bobs
		dc.l	1,do_clear
		dc.l	1,set_fade_up
		FADE_
		dc.l	1,enable_type_writer
		dc.l	500,null

*********************************************
		dc.l	1,set_fade_down
		FADE_
		dc.l	1,do_clear

		dc.l	1,enable_bobs
		dc.l	1,set_new_pal2
		FADE_

		dc.l	700,null
		dc.l	1,set_fade_down
		FADE_
		dc.l	1,set_new_pal3
		FADE_

		dc.l	700,null
		dc.l	1,set_fade_down
		FADE_

* start text writer again *******************
		dc.l	1,disable_bobs
		dc.l	1,do_clear
		dc.l	1,set_fade_up
		FADE_
		dc.l	1,enable_type_writer
		dc.l	600,null

*********************************************

		dc.l	1,set_fade_down
		FADE_
		dc.l	1,do_clear
		dc.l	1,enable_bobs

		dc.l	1,set_fade_up
		FADE_

		dc.l	300,null

		dc.l	1,set_new_pal1
		FADE_
		dc.l	1,set_new_pal2
		FADE_
		dc.l	1,set_new_pal3
		FADE_
		dc.l	1,set_fade_up
		FADE_

		dc.l	1,set_fade_down
		FADE_

* start text writer again *******************
		dc.l	1,disable_bobs
		dc.l	1,do_clear
		dc.l	1,set_fade_up
		FADE_
		dc.l	1,enable_type_writer
		dc.l	600,null
*********************************************
		dc.l	1,set_new_pal2
		FADE_

		dc.l	1,set_fade_down
		FADE_
		dc.l	1,do_clear
		dc.l	1,enable_bobs

		dc.l	-1,-1

null		rts

set_new_bob_path1	lea	sine2+8376,a0
			move.l	a0,v_table_pos2
			add.w	#4*20,a0
			move.l	a0,o_table_pos2
			add.w	#4*20,a0
			move.l	a0,p_table_pos2
			rts
set_new_bob_path2	lea	sine2+4*10,a0
			move.l	a0,v_table_pos2
			add.w	#4*10,a0
			move.l	a0,o_table_pos2
			add.w	#4*10,a0
			move.l	a0,p_table_pos2
			rts

set_white_pal		movem.l	white,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_ena
			rts
set_new_pal1		movem.l	pal1,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_ena
			rts
set_new_pal2		movem.l	pal2,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_ena
			rts
set_new_pal3		movem.l	pal3,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_ena
			rts

enable_bobs		clr.w	bobs_ena
			rts

disable_bobs		move.w	#-1,bobs_ena
			rts

enable_type_writer	clr.w	disc_enable
			rts

disable_type_writer	move.w	#-1,disc_enable
			rts

set_fade_up		movem.l	pic+2,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_ena
			rts
set_fade_down		movem.l	blank_middle_pal,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_ena
			rts

do_clear		move.l	scr_now,a0	;clear BOB area of screen
			move.l	scr_other,a3
			lea	46*160(a0),a0
			lea	46*160(a3),a3
			moveq	#0,d0
			move.w	#134-1,d2
.loop
OFF			set 0
			REPT 20
			move.l	d0,OFF(a0)
			move.l	d0,OFF+4(a0)
			move.l	d0,OFF(a3)
			move.l	d0,OFF+4(a3)
OFF		set	OFF+8
			ENDR
			lea	160(a0),a0
			lea	160(a3),a3
			dbf	d2,.loop
			rts


check_fade		tst.w	fade_ena
			bne.s	.do
			rts
.do			lea	middle_pal+2,a0
			lea	destin_pal+2,a1
			bsr	fade
			rts

fade		;A0=SOURCE PALETTE 	A1=TARGET PALETTE
		move.l	a1,a2
next_value	move.w	#15-1,d7
.loop		bsr	.modify
		addq.w	#2,a0
		addq.w	#2,a1
		dbf	d7,.loop
		move.l	a2,a1
		rts
.modify		move.w	(a0),d0		;get color value
		move.w	(a1),d1		;target pal
		move.w	d0,d4		;NEW COL
		move.w	d0,d2
		move.w	d1,d3
		and.w	#$7,d2
		and.w	#$7,d3
		cmp.w	d2,d3
		beq.s	MOK1
		bmi.s	MDN1
		addq.w	#1,d4
		bra.s	MOK1
MDN1		SUBQ #1,D4
MOK1		MOVE D0,D2
		MOVE D1,D3
		AND #$70,D2
		AND #$70,D3
		CMP D2,D3
		BEQ.S MOK2
		BMI.S MDN2
		ADD #$10,D4
		BRA.S MOK2
MDN2		SUB #$10,D4
MOK2		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3
		BEQ.S MOK3
		BMI.S MDN3
		ADD #$100,D4
		BRA.S MOK3
MDN3		SUB #$100,D4
MOK3		MOVE D4,(A0)
		RTS



***********************
* SUBROUTINES SECTION *
***********************
set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

get_old_palette	lea	$ffff8240.w,a0
		lea	old_palette,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

set_old_palette	lea	old_palette,a0
set_pal		lea	$ffff8240.w,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

get_screen_base	move.l	$44e.w,screen_base
		rts

set_up		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		bsr	do_pre_shift

		move.l	scr_now,a0
		add.w	#160*60,a0	
		move.l	a0,p_tab1
		move.l	a0,p_tab2
		move.l	a0,o_tab1
		move.l	a0,o_tab2
		move.l	a0,v_tab1
		move.l	a0,v_tab2

		move.w	#50,general_timer
		movem.l	blank_middle_pal,d0-d7
		movem.l	d0-d7,middle_pal

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
sho		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,sho

set_screen	move.l	scr_now,d6
		move.l	d6,scr_other
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		eor.w	#4,bob_xor
		rts

clear_bss	move.l	#bssend-bssstart,d0
		lea	bssstart,a0
.cb		clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.cb
		rts

do_pre_shift	lea	pov,a1
		move.w	#16-1,d7
shift_loop	lea	bob_pic+34,a0
		add.w	#16,a0
		move.l	a0,a6

		move.w	#BOB_DEPTH*2-1,d2
.loop		move.l	0(a0),(a1)+
		move.l	4(a0),(a1)+
		move.l	8(a0),(a1)+
		move.l	12(a0),(a1)+
		move.l	16(a0),(a1)+
		move.l	20(a0),(a1)+
		move.l	24(a0),(a1)+
		move.l	28(a0),(a1)+
		lea	160(a0),a0
		dbf	d2,.loop
		lea	-BOB_DEPTH*2*160(a0),a0

		move.w	#BOB_DEPTH*2-1,d2
.takeo		move.l	48(a0),(a1)+
		move.l	52(a0),(a1)+
		move.l	56(a0),(a1)+
		move.l	60(a0),(a1)+
		move.l	64(a0),(a1)+
		move.l	68(a0),(a1)+
		move.l	72(a0),(a1)+
		move.l	76(a0),(a1)+
		lea	160(a0),a0
		dbf	d2,.takeo
		lea	-BOB_DEPTH*2*160(a0),a0

		move.w	#BOB_DEPTH*2-1,d2
.takev		move.l	96(a0),(a1)+
		move.l	100(a0),(a1)+
		move.l	104(a0),(a1)+
		move.l	108(a0),(a1)+
		move.l	112(a0),(a1)+
		move.l	116(a0),(a1)+
		move.l	120(a0),(a1)+
		move.l	124(a0),(a1)+
		lea	160(a0),a0
		dbf	d2,.takev
		lea	-BOB_DEPTH*2*160(a0),a0

		move.l	a6,a0
		move.w	#BOB_DEPTH-1,d6
.loop2		sub.w	d4,d4	
		roxr.w	(a0)
		roxr.w	8(a0)
		roxr.w	16(a0)
		roxr.w	24(a0)
		roxr.w	32(a0)
		roxr.w	40(a0)
		roxr.w	48(a0)
		roxr.w	56(a0)
		roxr.w	64(a0)
		roxr.w	72(a0)
		roxr.w	80(a0)
		roxr.w	88(a0)
		roxr.w	96(a0)
		roxr.w	104(a0)
		roxr.w	112(a0)
		roxr.w	120(a0)
		roxr.w	128(a0)
		roxr.w	136(a0)
		roxr.w	144(a0)
		roxr.w	152(a0)

		add.w	#2,a0
		sub.w	d4,d4
		roxr.w	(a0)
		roxr.w	8(a0)
		roxr.w	16(a0)
		roxr.w	24(a0)
		roxr.w	32(a0)
		roxr.w	40(a0)
		roxr.w	48(a0)
		roxr.w	56(a0)
		roxr.w	64(a0)
		roxr.w	72(a0)
		roxr.w	80(a0)
		roxr.w	88(a0)
		roxr.w	96(a0)
		roxr.w	104(a0)
		roxr.w	112(a0)
		roxr.w	120(a0)
		roxr.w	128(a0)
		roxr.w	136(a0)
		roxr.w	144(a0)
		roxr.w	152(a0)
		add.w	#2,a0
		sub.w	d4,d4
		roxr.w	(a0)
		roxr.w	8(a0)
		roxr.w	16(a0)
		roxr.w	24(a0)
		roxr.w	32(a0)
		roxr.w	40(a0)
		roxr.w	48(a0)
		roxr.w	56(a0)
		roxr.w	64(a0)
		roxr.w	72(a0)
		roxr.w	80(a0)
		roxr.w	88(a0)
		roxr.w	96(a0)
		roxr.w	104(a0)
		roxr.w	112(a0)
		roxr.w	120(a0)
		roxr.w	128(a0)
		roxr.w	136(a0)
		roxr.w	144(a0)
		roxr.w	152(a0)
		add.w	#2,a0
		sub.w	d4,d4
 		roxr.w	(a0)
		roxr.w	8(a0)
		roxr.w	16(a0)
		roxr.w	24(a0)
		roxr.w	32(a0)
		roxr.w	40(a0)
		roxr.w	48(a0)
		roxr.w	56(a0)
		roxr.w	64(a0)
		roxr.w	72(a0)
		roxr.w	80(a0)
		roxr.w	88(a0)
		roxr.w	96(a0)
		roxr.w	104(a0)
		roxr.w	112(a0)
		roxr.w	120(a0)
		roxr.w	128(a0)
		roxr.w	136(a0)
		roxr.w	144(a0)
		roxr.w	152(a0)
		addq.w	#2,a0
		subq.w	#8,a0
		lea	160(a0),a0
		dbf	d6,.loop2

		move.w	#BOB_DEPTH-1,d6
.loop3		or.w	#5,sr
		roxr.w	(a0)
		roxr.w	8(a0)
		roxr.w	16(a0)
		roxr.w	24(a0)
		roxr.w	32(a0)
		roxr.w	40(a0)
		roxr.w	48(a0)
		roxr.w	56(a0)
		roxr.w	64(a0)
		roxr.w	72(a0)
		roxr.w	80(a0)
		roxr.w	88(a0)
		roxr.w	96(a0)
		roxr.w	104(a0)
		roxr.w	112(a0)
		roxr.w	120(a0)
		roxr.w	128(a0)
		roxr.w	136(a0)
		roxr.w	144(a0)
		roxr.w	152(a0)

		add.w	#2,a0
		or.w	#5,sr

		roxr.w	(a0)
		roxr.w	8(a0)
		roxr.w	16(a0)
		roxr.w	24(a0)
		roxr.w	32(a0)
		roxr.w	40(a0)
		roxr.w	48(a0)
		roxr.w	56(a0)
		roxr.w	64(a0)
		roxr.w	72(a0)
		roxr.w	80(a0)
		roxr.w	88(a0)
		roxr.w	96(a0)
		roxr.w	104(a0)
		roxr.w	112(a0)
		roxr.w	120(a0)
		roxr.w	128(a0)
		roxr.w	136(a0)
		roxr.w	144(a0)
		roxr.w	152(a0)
		add.w	#2,a0
		or.w	#5,sr

		roxr.w	(a0)
		roxr.w	8(a0)
		roxr.w	16(a0)
		roxr.w	24(a0)
		roxr.w	32(a0)
		roxr.w	40(a0)
		roxr.w	48(a0)
		roxr.w	56(a0)
		roxr.w	64(a0)
		roxr.w	72(a0)
		roxr.w	80(a0)
		roxr.w	88(a0)
		roxr.w	96(a0)
		roxr.w	104(a0)
		roxr.w	112(a0)
		roxr.w	120(a0)
		roxr.w	128(a0)
		roxr.w	136(a0)
		roxr.w	144(a0)
		roxr.w	152(a0)
		add.w	#2,a0
		or.w	#5,sr

 		roxr.w	(a0)
		roxr.w	8(a0)
		roxr.w	16(a0)
		roxr.w	24(a0)
		roxr.w	32(a0)
		roxr.w	40(a0)
		roxr.w	48(a0)
		roxr.w	56(a0)
		roxr.w	64(a0)
		roxr.w	72(a0)
		roxr.w	80(a0)
		roxr.w	88(a0)
		roxr.w	96(a0)
		roxr.w	104(a0)
		roxr.w	112(a0)
		roxr.w	120(a0)
		roxr.w	128(a0)
		roxr.w	136(a0)
		roxr.w	144(a0)
		roxr.w	152(a0)
		addq.w	#2,a0
		subq.w	#8,a0
		lea	160(a0),a0
		dbf	d6,.loop3
		dbf	d7,shift_loop
		rts


bobs		tst.w	bobs_ena
		beq.s	.yeah
		rts
.yeah		lea	p_tab1,a3
		move.w	bob_xor,d4
		move.l	0(a3,d4.w),d1
		move.l	d1,a3
		movem.l	black,d0-d7
		REPT	BOB_DEPTH
		movem.l	d0-d7,(a3)
		lea	160(a3),a3
		ENDR

		lea	o_tab1,a3
		move.w	bob_xor,d4
		move.l	0(a3,d4.w),d1
		move.l	d1,a3
		movem.l	black,d0-d7
		REPT	BOB_DEPTH
		movem.l	d0-d7,(a3)
		lea	160(a3),a3
		ENDR

		lea	v_tab1,a3
		move.w	bob_xor,d4
		move.l	0(a3,d4.w),d1
		move.l	d1,a3
		movem.l	black,d0-d7
		REPT	BOB_DEPTH
		movem.l	d0-d7,(a3)
		lea	160(a3),a3
		ENDR

		lea	pov+4*(BOB_DEPTH*(BOB_WIDTH*8)),a1
		lea	v_table_pos1,a6
		lea	v_table_pos2,a5
		lea	v_bob_print,a4
		bsr	.do

		lea	pov+2*(BOB_DEPTH*(BOB_WIDTH*8)),a1
		lea	o_table_pos1,a6
		lea	o_table_pos2,a5
		lea	o_bob_print,a4
		bsr	.do

		lea	pov,a1
		lea	p_table_pos1,a6
		lea	p_table_pos2,a5
		lea	p_bob_print,a4



.do		move.l	(a6),a0
		cmp.w	#-1,(a0)
		bne.s	.no_reset
		lea	sine1,a0
.no_reset	moveq.l	#0,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.w	(a0)+,d0	;word/offset
		move.w	(a0)+,d1	;y offset (post*160)
		move.l	a0,(a6)
		move.b	d0,d2
		move.w	d0,d5

		move.l	(a5),a0
		cmp.w	#-1,(a0)
		bne.s	.no_reset2
		lea	sine2,a0
.no_reset2	moveq.l	#0,d0
		move.w	(a0)+,d0	;word/offset
		add.w	(a0)+,d1	;y offset (post*160)
		move.l	a0,(a5)
		add.b	d0,d2
		add.w	d5,d0
		lsr.w	#4,d0		;word offset 
		lsl.w	#3,d0		;*8
		add.w	d1,d0		;add y to word offset

		move.l	scr_now,a0
		add.w	d0,a0		;get word/line pos on scrn

		and.w	#$f,d2		;mask off for bit shift

		mulu	#6*(BOB_DEPTH*(BOB_WIDTH*8)),d2
		add.l	d2,a1
		lea	BOB_DEPTH*(BOB_WIDTH*8)(a1),a2

		jsr	(a4)
		rts


p_bob_print	lea	p_tab1,a3
		move.w	bob_xor,d4
		move.l	a0,(a3,d4.w)

		REPT	4
		move.l	(a0),d0		;screen data
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		lea	160-32(a0),a0
		ENDR

		REPT	35

		move.l	(a0),d0		;screen data
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+

		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+

		lea	16(a2),a2

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		lea	160-32(a0),a0
		ENDR

		REPT	BOB_DEPTH-(35+4)

		move.l	(a0),d0		;screen data
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		lea	160-32(a0),a0
		ENDR
		rts

o_bob_print	lea	o_tab1,a3
		move.w	bob_xor,d4
		move.l	a0,(a3,d4.w)

		REPT	BOB_DEPTH
		move.l	(a0),d0		;screen data
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+

		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+

		lea	16(a2),a2
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		lea	160-32(a0),a0
		ENDR

		rts

v_bob_print	lea	v_tab1,a3	;get last pos table
		move.w	bob_xor,d4	;point to last screen
		move.l	a0,(a3,d4.w)	;alter for next VBL

		REPT	BOB_DEPTH

		move.l	(a0),d0		;screen data
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	(a2)+,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		lea	160-32(a0),a0
		ENDR
		rts


save_isr	move.w	#$2700,sr	;DI isr's
		lea	storage,a0
		move.l	$120.w,(a0)+
		move.l	$110.w,(a0)+
		move.l	$70.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa15.w,(a0)+
		move.b	$fffffa17.w,(a0)+
		move.b	$fffffa19.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa1d.w,(a0)+
		move.b	$fffffa23.w,(a0)+
		move.b	$fffffa25.w,(a0)+

		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w

; Musics done by BIG ALEC of DF
		moveq	#1,d0
		jsr	tune

		move.l	#new_120,$120.w
		move.l	#new_70,$70.w
		bclr	#3,$fffffa17.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		move.w	#$2300,sr
		rts


**** Due to the tune using TIMERD I cause TIMERB to interrupt 1 line
**** earlier so I can disable TIMERD. The reason for this is to stop
**** the rasters on TIMERB flickering. Once I've changed the raster
**** colour I re-enable TIMERD so the tune doesn't screw up.
****
**** Note: I turn TIMERD off each time I want a change of colour on
****       the raster. If a different tune is used the TIMERD bit can
****       be removed but the TIMERB DATA REG (fffffa21.b) and routines
****       will need altering accordingly.
****
****       If you haven't got a f**kin' clue what I'm talking about
****       simply bolt a normal tune in 'cos it'll still work!

new_120	bclr	#4,$fffffa15.w		;STOP TIMERD - SID chip emulator
	clr.b	$fffffa1b.w
	move.l	#new_120a,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

new_120a
	not.w	$ffff8240.w
	clr.b	$fffffa1b.w
	move.w	middle_pal+2,$ffff8242.w
	movem.l	d0-d6,-(sp)
	movem.l	middle_pal+4,d0-d6
	movem.l	d0-d6,$ffff8244.w
	movem.l	(sp)+,d0-d6
	move.l	#new_120_part2,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bset	#4,$fffffa15.w		;start TIMERD - tune!!!!
	rte

new_120_part2
	move.w	#$002,$ffff8240.w
	clr.b	$fffffa1b.w
	move.l	#new_120_part3,$120.w
 	move.b	#133,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

new_120_part3
	clr.b	$fffffa1b.w
	move.l	#new_120_part3a,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#4,$fffffa15.w		;stop timerd
	rte

new_120_part3a
	move.w	#-1,$ffff8240.w
	clr.b	$fffffa1b.w
	move.l	#new_120_part4,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bset	#4,$fffffa15.w		;start timerd
	rte

new_120_part4
	clr.b	$fffffa1b.w		;leave with timerB disabled
	move.l	lower_pal,$ffff8240.w
	movem.l	d0-d6,-(sp)
	movem.l	lower_pal+4,d0-d6
	movem.l	d0-d6,$ffff8244.w
	movem.l	(sp)+,d0-d6
	rte


new_70		clr.b	$fffffa1b.w	;di timer B
		clr.w	vsync_flag
		movem.l	d0-a6,-(sp)
		movem.l	top_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		jsr	tune+8
		bsr	scroll
		movem.l	(sp)+,d0-a6
		move.l	#new_120,$120.w
		move.b	#44,$fffffa21.w
		move.b	#8,$fffffa1b.w
		tst.w	zero_counter
		beq.s	.zero
		sub.w	#1,zero_counter
.zero		tst.w	general_timer
		bne.s	.dec
		rte
.dec		sub.w	#1,general_timer
		rte

vsync		move.w	#-1,vsync_flag
.vsyn		tst.w	vsync_flag
		bne.s	.vsyn
		rts

stop_isr	bsr	vsync

		moveq	#0,d0
		jsr	tune

		move.w	#$2700,sr
		lea	storage,a0
		move.l	(a0)+,$120.w
		move.l	(a0)+,$110.w
		move.l	(a0)+,$70.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa15.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$fffffa19.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa1d.w
		move.b	(a0)+,$fffffa23.w
		move.b	(a0)+,$fffffa25.w

		move.b	#$e0,$fffffa23.w	;reset keyboard repeat!

		lea	$ffff8800.w,a0
		move.l	#$0707ffff,(a0)
		move.l	#$08080000,(a0)
		move.l	#$09090000,(a0)
		move.l	#$0a0a0000,(a0)
		ifeq	DOWNLOAD
		move.w	#$2300,sr
		endc
		rts


	ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
	endc

pic		incbin	main.pi1
bob_pic		incbin	bobs.pi1

	
black		dcb.b	32,0

sine1		incbin	sine1.dat
		dc.w	-1,-1
		even
sine2		incbin	sine2.dat
		dc.w	-1,-1
		even

v_table_pos1	dc.l	sine1
v_table_pos2	dc.l	sine2

o_table_pos1	dc.l	sine1
o_table_pos2	dc.l	sine2+(4*10)

p_table_pos1	dc.l	sine1
p_table_pos2	dc.l	sine2+(4*20)


bobs_ena	dc.w	0
p_tab1		dc.l	0
p_tab2		dc.l	0

o_tab1		dc.l	0
o_tab2		dc.l	0

v_tab1		dc.l	0
v_tab2		dc.l	0

bob_xor		dc.w	4


top_pal		dc.w	$000,$670,$570,$470,$360,$150,$040,$030
		dc.w	$700,$020,$010,$530,$223,$122,$111,$770


tune	incbin	reality.mus

blank_middle_pal	dcb.w	16,$002
lower_pal		incbin	lowerpal.col
pal1			incbin	pal1.col
pal2			incbin	pal2.col
pal3			incbin	pal3.col
white			dc.w	0
			dcb.w	30,-1

middle_text_pos		dc.l	middle_text
middle_text		incbin	midl_txt.s
			dc.b	$ff
			even
minifont		incbin	font.dat
			even

scroll_pointer	dc.l	scroll_text
scroll_text
 DC.B "                                                 "
 dc.b "VISIONS COME AND GO BUT SOME VISIONS LINGER.......           "
 DC.B "        PERSISTENCE OF VISIONS IS BACK TO HAUNT YOU "
 DC.B "WITH P.O.V. DEMO COMPILATION 125.       "
 DC.B "HERE ARE THE CREDITS:    "
 DC.B "ALL CODE BY MAC SYS DATA,      "
 DC.B "GRAFICS BY OZ,      "
 DC.B "MUSIC BY BIG ALEC OF DELTA FORCE (NEW SID CHIP ROUTINE) RIPPED BY MUG UK.        "
 DC.B "RELEASE DATE: 29TH DECEMBER 1992 (ONLY 2 MONTHS LATER THAN I EXPECTED - "
 DC.B "BLAME MUG UK FOR MAKING ME WORK ON THE LINK FILER!).     THE REAL "
 DC.B "REASON FOR THE DISC BEING LATE IS BECAUSE I'VE WRITTEN SEVERAL INTROS "
 DC.B "FOR PD LIBRARIES AND CODED BOTH POV 126 AND 127 MENUS.            IF YOU "
 DC.B "WENT TO THE 'RIPPED OFF' CODING PARTY IN SEPTEMBER 1992 YOU MAY HAVE "
 DC.B "SEEN THE START OF THIS MENU, MOST OF IT WAS WRITTEN THE WEEK "
 DC.B "AFTER THE PARTY AND HAS BEEN GATHERING DUST SINCE.          "
 DC.B "AS THIS IS ONE OUR ANIVERSARY DISCS WE HAVE INCLUDED THE "
 DC.B "HIGHLY INTERESTING (NOT!) INFORMATION LIST SO ALL YOU POV COLLECTORS "
 DC.B "CAN SEE WHAT YOU'VE NOT GOT OR WHAT SHOULD BE ON THE ONES YOU HAVE. "
 DC.B "     THE LIST IS 100 PERCENT ACCURATE SO IF YOU HAVE A POV DISC WITH DIFFERENT "
 DC.B "TITLES ON YOU SHOULD CONTACT YOUR PD SUPPLIER FOR A NEW COPY. "
 DC.B "ALTERNATIVELY YOU CAN WRITE TO THE POV P.O. BOX BUT ADDRESS IT "
 DC.B "TO TOWER PD WHO WILL GIVE DETAILS OF HOW TO COMPLETE YOUR COLLECTION."
 DC.B "      IF YOU HAVE A POV DISC AND THE THING DOESN'T WORK YOU SHOULD GET "
 DC.B "A NEW COPY, PREFERABLE FROM A MAJOR PD LIBRARY LIKE TOWER PD.  IF IT "
 DC.B "STILL DOESN'T WORK THEN SEND DETAILS OF YOUR ATARI SETUP AND GIVE "
 DC.B "EXPLICIT DETAILS OF WHAT HAPPENS SO I CAN FIX THE BUG.  IF IT'S "
 DC.B "ONE OF THE DEMOS THAT DOESN'T WORK I SUGGEST YOU FIRST TEST IT ON "
 DC.B "YOUR MATES MACHINE TO ENSURE IT ISN'T YOU TRYING TO RUN A 1 MEG "
 DC.B "DEMO ON YOUR HALF MEG MACHINE.      WE DO OCCASIONALLY RELEASE "
 DC.B "A DODGY DISC (PRETTY RARELY) BUT WE ARE HUMAN AND DO MAKE MISTAKES "
 DC.B "SO YOUR PROBLEM MAY WELL BE GENUINE AND WE WILL FIX IT A.S.A.P.   "
 dc.b "             SORRY THAT THIS MENU IS SO BORING, IT LOOKED GOOD "
 DC.B "WHEN I STARTED BUT IT SOON LOOKED BORING.    I DID "
 DC.B "ADD RASTERS AND A LITTLE COPPER EFFECT BUT IT MADE THE MENU 1 "
 DC.B "MEG ONLY SO I HAD TO REVERT BACK TO THIS VERSION.           "
 DC.B "         A NOTE TO MOOKIE OF ADRENALIN UK - HEY THE "
 dc.b "MENU WASN'T DODGY, IT WAS THE DOWNLOAD CODE SCREWING UP AGAIN!!!!                    "
 dc.b "         THIS IS VERSION 6 OF THIS MENU AS THE GAMEBOY EMULATOR "
 DC.B "KEPT SCREWING UP ON MY HALF MEG ST AND HALF THE PROGRAMS I ORIGINALLY "
 DC.B "PUT ON THE DISC KNACKERED UP AS THEY WERE 1 MEG.          "
 DC.B "    YOU CAN CONTACT POV AT OUR USUAL P.O BOX, SIMPLY WRITE "
 DC.B "TO THE FOLLOWING ADDRESS......            "
 DC.B "P.O.V.,        P.O. BOX 40,        THORNTON-CLEVELEYS,        "
 DC.B "BLACKPOOL,        LANCS.,         FY5 3PH.        ENGLAND.        "
 DC.B "          OKAY HERE THEY COME - THE GREETIGNS.   "
 DC.B "      POV SENDS REGARDS TO:       "
 DC.B "ADRENALIN,     ANIMAL MINE,     BLIND BASTARD,     "
 DC.B "CHAOS (ESP. BEN),     CYNIX,     D-BUG,     DEL (D.W.STABLES PD),     "
 DC.B "DELTA FORCE,     DR SYNE,     ERIK PLANKTON,     EQUINOX,     "
 DC.B "FUZION,     GEORGE (BART),     INNER CIRCLE,     INSOMNIA,     "
 DC.B "KGB,     MAD VISION,     MUG UK,     NEXT,     PAL PD,     "
 DC.B "PIXEL TWINS,     POMPEY PIRATES,     PURE ENERGY,     "
 DC.B "REPLICANTS,     RIPPED OFF,     STAX,     STRANGER,     "
 DC.B "SYNERGY,     THE SYNDICATE (FRANCE AND SWEDEN),     TNC PD,     UNITY,     UTOS,     "
 DC.B "WILD!          WELL THAT'S ALL FOR THIS DISC, THERE ARE SOME "
 DC.B "STE GOODIES ON DISC 127 SO GO GET IT!                        "
 DC.B "                                                 "
 DC.B "                                                 "
 DC.B "                                                 "
 DC.B "                                                 "
 dc.b "                                                 "
 dc.b "                                                 "
 dc.b "                                                 "
 dc.b "                                                 "
 dc.b "                                    WRAP         "
 dc.b "VISIONS COME AND GO BUT SOME VISIONS LINGER.......           "
 DC.B "           WELL IF YOU HAVE ALREADY SEEN POV 127 "
 DC.B "(IT WAS RELEASED BEFORE THIS DISC) YOU MAY HAVE SOME TEXT "
 DC.B "REFERING TO 'JENNY'.       WELL SHE PHONED ME LAST "
 DC.B "NIGHT (FOR THE FIRST TIME) AND WE CHATTED FOR A WHILE. I HAVE "
 DC.B "BEEN ORDERED TO CALL HER AT THE WEEKEND SO I SUPPOSE I WILL.   "
 DC.B "   ONE GOOD THING SHE DOESN'T KNOW ABOUT THOUGH...... AT WORK "
 DC.B "I HAVE A SYSTEM PRIVILEGE ACCOUNT AND SO CAN READ ANY FILE "
 DC.B "ON THE SYSTEM AS IF IT WAS MY OWN.  AFTER SHE PHONED I PHONED "
 DC.B "WORK ON MY DIAL UP MODEM AND SET HER MAIL DIRECTORY AS MINE THEN "
 DC.B "PROCEEDED TO READ ALL HER MAIL..... I WON'T TELL YOU WHAT WAS "
 DC.B "THERE BUT.....       ENOUGH OF THIS DRIBBLE.       THE COPIER "
 DC.B "ON THIS DISC IS AN UPDATED VERSION AND IS SLIGHTLY FASTER (SLIGHTLY) "
 DC.B "BUT AS I NOW HAVE THE SOURCE CODE I CAN PUT SOME NEW TUNES IN "
 DC.B "OR CHANGE THE HORRIBLE SNOT COLOURED RASTERS!            "
 DC.B "WELL THIS REALLY IS THE END AS I'M NOT FEELING TOO WELL (I'VE "
 DC.B "GOT FLU) SO UNTIL DISC 128........                   WRAP-ERTY-WRAP!         "
 DC.B "               "
 dc.b $ff
 DC.B "   HELLO HACKER WHAT THE FUCK DO YOU WANT?   "
	even
char_offset	dc.w	0
font	dcb.b	14*4,0
	incbin	"1plane.fnt"
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,00,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,00,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,41,00,42,00,42,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;	 v  w  x  y  z
 dc.b	22,23,24,25,26
	even

key_codes
	dc.b	0, $02		;keyboard 1
	dc.b	1, $03		;keyboard 2
	dc.b	2, $04		;keyboard 3
	dc.b	3, $05		;keyboard 4
	dc.b	4, $06		;keyboard 5
	dc.b	5, $07		;keyboard 6
	dc.b	6, $08		;keyboard 7
	dc.b	7, $09		;keyboard 8
	dc.b	8, $0A		;keyboard 9

	dc.b	9, $3b		;F1
	dc.b	10,$3c		;F2
	dc.b	11,$3d		;F3
	dc.b	12,$3e		;F4

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
	dc.b	7, $68		;keypad 8
	dc.b	8, $69		;keypad 9
	dc.b	-1, -1
	even

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
		dc.l	exec9,exec10,exec11,exec12,exec13
exec1		dc.b	"beachtro",0
	even
exec2		dc.b	"ta",0
	even
exec3		dc.b	"chronicl",0
	even
exec4		dc.b	"trek.msd",0
	even
exec5		dc.b	"kgbintro",0
	even
exec6		dc.b	"pp_gameb.oy",0
	even
exec7		dc.b	"sigma5",0
	even
exec8		dc.b	"info_125.pov",0
	even
exec9		dc.b	"copier.pov",0
	even
exec10		dc.b	"who",0
	even
exec11		dc.b	"big",0
	even
exec12		dc.b	"lem",0
	even
exec13		dc.b	"ebk",0
	even





	ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
	endc
bssstart
middle_pal	ds.w	16
destin_pal	ds.w	16
fade_ena	ds.w	1
general_timer	ds.w	1

storage		ds.b	28

vsync_flag	ds.w	1
zero_counter	ds.w	1
hertz_switch	ds.w	1

stack_save	ds.l	1
screen_base	ds.l	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_other	ds.l	1
scr_xor		ds.l	1

tab_offset	ds.w	1
xpos		ds.b	1
ypos		ds.b	1
original_rez	ds.b	1
		even
byte_offset	ds.w	1
disc_enable	ds.w	1
disc_start_table	ds.l	30	;1 long word for each page
	even

pov
		rept	16
		ds.b	(BOB_DEPTH*2)*(BOB_WIDTH*8)
		ds.b	(BOB_DEPTH*2)*(BOB_WIDTH*8)
		ds.b	(BOB_DEPTH*2)*(BOB_WIDTH*8)
		endr


		ds.b	256
screens		ds.b	32000
		ds.b	32000
bssend



	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
