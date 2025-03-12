*************************************************************************
*			PERSISTENCE OF VISION 141			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music from:	Logical							*
*									*
*									*
* Grafix by: 	Machine System Data					*
*									*
*									*
* Date:		2/12/93							*
*									*
*									*
*			½ Persistence Of Vision 1993			*
*									*
*************************************************************************
YES	equ	1
yes	equ	YES
NO	equ	0
no	equ	NO

AUTORUN4=no	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here
FINAL=no	;Final version = yes for assembling to disc
		;Final version = no for assembling into memory for developing

****** DOWNLOAD DEVELOPMENT SWITCHES *********************************
DOWNLOAD=no	;Download to remote ST PDS?
		;This option is ½Leo + Boris.
		;It allows standard STs to download code to remote STs and
		;to run it whilst the source code remains safe on the local
		;machine.

		ifne	DOWNLOAD		;version 1 download code
		include	sttx1.s
		org	$2000
Code_Start
Exec_Addr
		ENDC


****** MACROS ********************************
FADE_TOP	macro
		REPT	8
		dc.l	5,check_fade_top
		ENDR
		ENDM
FADE_MIDDLE	macro
		REPT	8
		dc.l	5,check_fade_middle
		ENDR
		ENDM
**********************************************



		opt	o+,w-

		ifeq	DOWNLOAD
		ifeq	AUTORUN4
begin		bra	start
		ds.l	100
ustack		ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec		pea	blank
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

****************************************************************


		bsr	set_up
main_loop	move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync

		bsr	set_screen	;screen flip
;		move.w	#$123,$ffff8240.w
		bsr	check_pipe
		bsr	scroll
		bsr	print_middle_text
;		move.w	pic+2,$ffff8240.w


		move.w	key,d0
		ifeq	FINAL
		cmp.w	#1,d0
		beq	assem
		endc

		cmp.w	#11,d0		;0 keyboard
		beq	zero

		cmp.w	#$70,d0		;0 keypad
		beq	zero

		cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
		beq	reset

		lea	demo_keys,a0
.next		move.w	(a0)+,d1
		bmi.s	main_loop
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

		tst.w	middle_pal
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50		move.w	#$2700,sr
		lea	store,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa0d.w
		move.b	(a0)+,$fffffa11.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa15.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$fffffa1d.w
		move.b	old484,$484.w
		move.w	#$2300,sr

		moveq	#-1,d0
		jsr	music

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		move.b	org_rez,$ffff8260.w
		move.b	#$8,$fffffc02.w

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		ifne	DOWNLOAD		;always reset in download mode
		bra	reset
		endc

		bsr	set_user

		ifeq	FINAL
		clr.w	-(sp)
		trap	#1
		endc

		ifne	FINAL
		ifeq	AUTORUN4
		bra	exec
		elseif
		clr.w	-(sp)
		trap	#1
		endc
		endc


		ifeq	FINAL
assem		move.w	#$2700,sr
		move.w	#-1,d0
		jsr	music
		lea	store,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa0d.w
		move.b	(a0)+,$fffffa11.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa15.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$fffffa1d.w
		move.b	old484,$484.w
		move.w	#$2300,sr

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		move.b	org_rez,$ffff8260.w
		move.b	#$8,$fffffc02.w

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		bsr	set_user
		clr.w	-(sp)
		trap	#1
		endc

zero		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$002,middle_pal
		move.w	#10,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts



*******************
* CUSTOM ROUTINES *
*******************
scroll_depth	equ	30
scroll		tst.w	scroll_ena
		beq.s	.do_stuff
		rts
.do_stuff	move.w	wave_flip,d0
		and.w	#7,d0
		move.l	old_wave_pointer,a1
		move.l	(a1,d0.w),a1
		move.w	#40-1,d0
		moveq	#0,d2
		move.l	d2,d3
		move.w	d2,d4
scroll_loop	move.l	scr_now,a0
		move.w	(a1)+,d1
		move.l	a0,a2
		add.w	d1,a0
		move.l	a0,a4
		lea	(scroll_depth-8)*160(a0),a3
		add.w	d2,a0
		add.w	d2,a3
		REPT	8
		movep.l	d3,(a0)
		movep.l	d3,(a3)
		lea	160(a0),a0
		lea	160(a3),a3
		ENDR
		move.l	a4,a0

		not.w	d4
		bpl.s	.word
		addq.w	#1,d2
		bra.s	.la
.word		addq.w	#7,d2
.la		move.l	a2,a0
		dbf	d0,scroll_loop

;scroll routine
		move.l	scr_now,a1
		cmp.l	#waves_end,wave_pointer
		blt.s	.no_reset
		move.l	#waves,wave_pointer
.no_reset	move.l	wave_pointer,a6

		move.l	old_wave_pointer,a5
		move.w	wave_flip,d4
		and.w	#7,d4
		move.l	a6,(a5,d4.w)

		lea	font_offsets,a2
		move.l	scroll_pointer,a3
		move.l	a3,a5

		moveq	#0,d4
		moveq	#40,d5
		move.w	char_offset,d6
next_char	move.b	(a5),d2	;get a letter
		sub.b	#32,d2	;rid of ASCII
		ext.w	d2

		moveq	#0,d0
		move.l	#font,a0
		move.b	(a2,d2),d0
		mulu	#(scroll_depth*4*4),d0
		add.w	d0,a0
		move.w	d6,d0
		mulu	#scroll_depth*4,d0		;char depth scroll_depth deep
		add.w	d0,a0

.column		moveq	#0,d1
		move.w	(a6)+,d1
		move.l	a1,-(sp)
		add.w	d1,a1
OFF		set	0
		REPT	scroll_depth
		move.l	(a0)+,d3
		movep.l	d3,OFF(a1)
OFF		set	OFF+160
		ENDR
		move.l	(sp)+,a1

		subq.w	#1,d5
		beq.s	.finish

		addq.w	#1,a1		;lower byte of word
		tst.w	d4
		beq.s	.skip		;if D4=0 then do next word
		addq.w	#6,a1		;else goto next word on screen
.skip		not.w	d4
		addq.w	#1,d6		;character offset
		and.w	#3,d6
		bne	.column

		addq.w	#1,a5		;scroll pointer
		tst.b	(a5)		;is end of text?
		bpl	next_char	;NO!
		lea	scroll_text,a5	;do reset scrolline
		bra	next_char

.finish		addq.w	#1,char_offset
		and.w	#3,char_offset
		bne.s	.end
		addq.w	#1,a3
		tst.b	(a3)
		bpl.s	.end
		lea	scroll_text,a3
.end		move.l	a3,scroll_pointer
		addq.l	#4,wave_pointer
		add.w	#4,wave_flip
		rts



***** Middle text printer V1.1 - bug fixed for restart of text *****
*****           Now uses only text, no page lookup table       *****
print_middle_text
		tst.w	type_writer_enable
		beq.s	.do_stuff
		rts
.do_stuff	move.l	middle_text_pos,a1
		move.l	scr_now,a0
		move.l	scr_other,a3
		lea	60*160(a0),a0
		lea	60*160(a3),a3
.restart	moveq	#0,d1
		move.b	(a1)+,d1
		bpl.s	.no_reset
		lea	middle_text,a1
		move.b	(a1)+,d1
.no_reset	move.l	a1,middle_text_pos
		cmp.b	#"^",d1		;termintor
		blt.s	.do_text
		move.w	#-1,type_writer_enable
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
		mulu	#6*4,d1	;each char is 6*4 planes bytes long
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
offset		set	0
		rept	6	;chars are 6 lines deep
		move.b	(a2)+,d0	;8
		move.b	(a2)+,d1	;8
		move.b	(a2)+,d2	;8
		move.b	(a2)+,d3	;8
		move.b	d0,offset(a0)	;8
		move.b	d0,offset(a3)	;8
		move.b	d1,offset+2(a0)	;12
		move.b	d1,offset+2(a3)	;12
		move.b	d2,offset+4(a0)	;12
		move.b	d2,offset+4(a3)	;12
		move.b	d3,offset+6(a0)	;12
		move.b	d3,offset+6(a3)	;12	120 cycles
offset		set	offset+160
		endr
		addq.b	#1,xpos
		eor.w	#1,byte_offset
		rts



********** Pipe is a sequence of routines **********
* Routines have a run life specified in a value before the routines name
* the run life value is put in the general_timer variable. When the
* general_timer reaches 0, a new routine is taken from the pipe.
* It is possible to have 2 routines running simutaneously, e.g the fade
* routine runs at the same time as the scroller and text printer.
****************************************************
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

*  NULL is a 'do-nothing' routine (used to allow other routines to run
*  before the general_timer runs out.
pipe_offset	dc.w	0
pipe_seq	dc.l	1,set_fade_top_up
		FADE_TOP
		dc.l	220,null

		dc.l	1,set_black_middle
		FADE_MIDDLE
		dc.l	1,disable_scroll
		dc.l	1,do_clear		;clear middle area
		dc.l	1,enable_type_writer
		dc.l	1,set_middle_pal1
		FADE_MIDDLE
		dc.l	50,null

		dc.l	1,set_new_pal1		;fade top logo
		FADE_TOP
		dc.l	250,null
		dc.l	1,set_black_middle
		FADE_MIDDLE

		dc.l	1,do_clear		;clear middle area
		dc.l	1,enable_scroll
		dc.l	1,set_middle_pal2
		FADE_MIDDLE

		dc.l	200,null

		dc.l	1,set_fade_top_up
		FADE_TOP

		dc.l	100,null

		dc.l	1,set_black_middle
		FADE_MIDDLE
		dc.l	1,disable_scroll
		dc.l	1,do_clear		;clear middle area
		dc.l	1,enable_type_writer
		dc.l	1,set_middle_pal2
		FADE_MIDDLE
		dc.l	500,null
		dc.l	1,set_black_middle
		FADE_MIDDLE

		dc.l	1,do_clear		;clear middle area
		dc.l	1,enable_scroll
		dc.l	1,set_middle_pal2
		FADE_MIDDLE
		dc.l	100,null
		dc.l	1,set_new_pal2
		FADE_TOP
		dc.l	100,null
		dc.l	1,set_middle_pal1
		FADE_MIDDLE
		dc.l	200,null
		dc.l	1,set_new_pal3
		FADE_TOP
		dc.l	200,null

		dc.l	1,set_black_middle
		FADE_MIDDLE
		dc.l	1,disable_scroll
		dc.l	1,do_clear
		dc.l	1,set_new_pal1
		FADE_TOP
		dc.l	1,set_middle_pal1
		FADE_MIDDLE
		dc.l	1,enable_type_writer

		dc.l	250,null
		dc.l	1,set_middle_pal2
		FADE_MIDDLE
		dc.l	250,null

		dc.l	1,set_black_middle
		FADE_MIDDLE
		dc.l	1,do_clear
		dc.l	1,enable_scroll
		dc.l	1,set_middle_pal2
		FADE_MIDDLE
		dc.l	300,null
		dc.l	1,set_new_pal2
		FADE_TOP
		dc.l	200,null

		dc.l	1,set_black_middle
		FADE_MIDDLE
		dc.l	8,null
		dc.l	1,disable_scroll
		dc.l	1,do_clear

		dc.l	1,set_middle_pal3
		FADE_MIDDLE
		dc.l	1,enable_type_writer
		dc.l	500,null
		dc.l	1,set_black_middle
		FADE_MIDDLE
		dc.l	1,do_clear

		dc.l	1,enable_scroll
		dc.l	1,set_middle_pal1
		FADE_MIDDLE
		dc.l	600,null

		dc.l	1,set_black_middle
		FADE_MIDDLE
		dc.l	1,disable_scroll
		dc.l	1,do_clear		;clear middle area
		dc.l	1,enable_type_writer
		dc.l	1,set_middle_pal3
		FADE_MIDDLE
		dc.l	400,null

		dc.l	1,set_black_middle
		FADE_MIDDLE
		dc.l	1,do_clear

		dc.l	1,enable_scroll
		dc.l	1,set_middle_pal1
		FADE_MIDDLE

		dc.l	-1,-1

null		rts

set_black_middle	movem.l	black,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_middle_ena
			rts
set_middle_pal1		movem.l	middle_pal1,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_middle_ena
			rts
set_middle_pal2		movem.l	middle_pal2,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_middle_ena
			rts
set_middle_pal3		movem.l	middle_pal3,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_middle_ena
			rts

set_new_pal1		movem.l	pal1,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_top_ena
			rts
set_new_pal2		movem.l	pal2,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_top_ena
			rts
set_new_pal3		movem.l	pal3,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_top_ena
			rts

enable_scroll		clr.w	scroll_ena
			rts

disable_scroll		move.w	#-1,scroll_ena
			rts

enable_type_writer	clr.w	type_writer_enable
			rts

set_fade_top_up		movem.l	pic+2,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_top_ena
			rts

do_clear		move.l	scr_now,a0	;clear middle area of screen
			move.l	scr_other,a3
			lea	59*160(a0),a0
			lea	59*160(a3),a3
			moveq	#0,d0
			move.w	#141-1,d2
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






check_fade_top		tst.w	fade_top_ena
			bne.s	.do
			rts
.do			lea	top_pal+2,a0
			lea	destin_pal+2,a1
			bsr	fade
			rts

check_fade_middle	tst.w	fade_middle_ena
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
set_screen	move.l	scr_now,d6		;screen flipper
		move.l	d6,scr_other
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts



set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

set_up		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
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

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base


		movem.l	middle_pal1,d0-d7
		movem.l	d0-d7,middle_pal
		clr.w	scroll_ena		;start scroller
		move.w	#-1,type_writer_enable
		move.w	#220,general_timer


		move.b	$ffff8260.w,org_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,destin_pal


		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		clr.b	$ffff8260.w

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor
		bsr	set_screen

		lea	pic+34,a0
		move.l	scr_now,a1
		bsr	set_screen
		move.l	scr_now,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

;save old settings
		move.b	$484.w,old484		;save keyboard click/speed, etc
		clr.b	$484.w			;disable repeat/click/bell
		lea	store,a0		;save mfp,vbl etc
		move.l	$70.w,(a0)+		
		move.l	$118.w,(a0)+		
		move.l	$120.w,(a0)+		
		move.b	$fffffa07.w,(a0)+	
		move.b	$fffffa09.w,(a0)+	
		move.b	$fffffa0d.w,(a0)+	
		move.b	$fffffa11.w,(a0)+	
		move.b	$fffffa13.w,(a0)+	
		move.b	$fffffa15.w,(a0)+
		move.b	$fffffa17.w,(a0)+
		move.b	$fffffa1d.w,(a0)+

		moveq	#1,d0
		jsr	music

* Now start ISRs
		move.w	#$2700,sr
		and.b	#$fe,$fffffa07.w
		and.b	#$df,$fffffa09.w
		move.l	#new_vbl,$70.w
		move.l	#new_key,$118.w
		move.l	#new_timerb,$120.w
		bset	#0,$fffffa07.w		;ena timerb
		bclr	#0,$fffffa0f.w		;ena timerb
		bset	#0,$fffffa13.w		;ena timerb
		bclr	#3,$fffffa17.w		;enable auto A-INTERRUPT IN SERVICE clear
		move.w	#$2300,sr
		rts				;ISRs are now running

new_key		movem.l	d0,-(sp)
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

new_vbl		movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
		movem.l	top_pal,d0-d7		;set colours after isr
		movem.l	d0-d7,$ffff8240.w

		jsr	music+8

		clr.w	vsync_flag		;own screen update rout
		tst.w	zero_counter
		beq.s	.clear
		sub.w	#1,zero_counter
.clear		movem.l	(sp)+,d0-d7/a0-a6
		clr.b	$fffffa1b.w
		move.b	#56,$fffffa21.w	;next interrupt to occur 199 lines down
		move.b	#8,$fffffa1b.w		;set interrupt method

		tst.w	general_timer
		bne.s	.dec

		tst.w	hertz_delay
		bne.s	.dec_hertz
		rte
.dec_hertz	sub.w	#1,hertz_delay
		rte

.dec		sub.w	#1,general_timer
		tst.w	hertz_delay
		bne.s	.dec_hertz2
		rte
.dec_hertz2	sub.w	#1,hertz_delay
		rte

new_timerb	move.l	middle_pal,$ffff8240.w
		clr.b	$fffffa1b.w
		movem.l	d0-d6,-(sp)
		movem.l	middle_pal+4,d0-d6
		movem.l	d0-d6,$ffff8244.w
		movem.l	(sp)+,d0-d6
		rte

		

	ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
	endc

pic	incbin	pic.pi1

scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "                     PERSISTENCE OF VISION DEMO COMPILATION 141.    "
 DC.B "  CODE BY MSD,  GRAPHICS BY OZ AND MAC SYS DATA,  MUSIC FROM LOGICAL.             "
 dc.b "        I MUST START OFF BY SAYING A BIG SORRY TO ALL YOU POV DISC "
 dc.b "COLLECTORS AS I MADE A MISTAKE.            YES I PUT ANIMAL MINE "
 dc.b "CARTOONTRO ON TWO MENUS, AS A RESULT POV 139 HAS BEEN RE-RELEASED WITH "
 dc.b "ANOTHER TITLE ON IT. I HAVE RELEASED TWO MENUS WITH DUPLICATED TITLES ON "
 dc.b "RECENTLY BUT WHEN YOU HAVE DONE SO MANY DISCS IT BECOMES HARD TO REMEMBER "
 DC.B "WHAT IS ON WHAT DISC.                 WELL TODAYS DATE IS THE 2ND OF DECEMBER "
 DC.B "1993 AND IT WILL SOON BE CHRISTMAS. THE TOY ADVERTS HAVE ALREADY STARTED "
 DC.B "AND SEVERAL TOWNS HAVE PUT UP THE CHRISTMAS LIGHTS. I WILL HAVE TO START "
 DC.B "BUYING PRESENTS SOON - BOOOOOO!    I HATE GOING ROUND THE BUSY SHOPS "
 DC.B "COS THERE ARE STUPID PEOPLE WHO STOP JUST INFRONT OF YOU FOR NO REASON "
 DC.B "AT ALL. I HATE IT WHEN I KNOW WHERE I WANT TO GO BUT CAN'T 'COS THERE "
 DC.B "ARE HUNDREDS OF PEOPLE ALL GOING MEGA SLOW  -  ARRGGHHHH!!            "
 dc.b "IF YOU ARE INTERESTED I WILL BE PUTTING THIS ON THE LONG AWAITED "
 DC.B "P.O.V. SOURCE CODE DISC.   I WILL SHORTLY BE CODING A NEW INTRO TO "
 DC.B "USE ON SEVERAL SOURCE CODE DISCS.   IF YOU ARE INTERESTED THEN KEEP "
 DC.B "A LOOKOUT IN PD LIBRARIES, THE FIRST TO GET THE SOURCE WILL BE OUR "
 DC.B "OFFICIAL OUTLET 'TOWER PD'.       I WILL INCLUDE MENUS FROM THE VERY "
 DC.B "EARLY DAYS OF P.O.V. RIGHT UPTO MODERN DAY MENUS. THE CODE WILL "
 DC.B "MAINLY BE IN DEVPAC FORMAT BUT SOME OF THE EARLY MENUS WERE CODED "
 DC.B "USING K-SEKA. THE EARLY MENUS WERE NOT TOO GOOD STRUCTURE WISE AND SO "
 DC.B "ARE HARD TO READ, MENUS FROM ABOUT DISC 10 HOWEVER ARE VERY READABLE AND "
 DC.B "HAVE PROVED VERY POPULAR WITH USERS WHO HAVE AQUIRED THEM SO FAR.     "
 DC.B "      NEARLY ALL P.O.V. MENUS HAVE BEEN CODED BY ME (MAC SYS DATA) SO I WILL "
 DC.B "ADD COMMENTS TO HELP YOU. ANYWAY KEEP A LOOK OUT FOR THESE SOURCE CODE DISCS AS "
 DC.B "THEY SHOULD BE AVAILABLE JUST AFTER CHRISTMAS.            "
 DC.B "       WELL IT MUST ABOUT TIME FOR THE GREETINGS.........       "
 DC.B "A BIG HELLO TO THE FOLLOWING...      "
 DC.B "ADRENALIN UK,     "
 DC.B "ANIMAL MINE,     "
 DC.B "BLIND BASTARD,     "
 DC.B "CYNIX,     "
 DC.B "D-BUG,     "
 DC.B "DEL (D.W.STABLES PD),     "
 DC.B "DR SYNE,     "
 dc.b "EDGE OF SANITY (ANNHILATOR),     "
 DC.B "ERIK PLANKTON,     "
 DC.B "ETERNITY (LORD),     "
 DC.B "GEORGE (BART),     "
 DC.B "MUG UK,     "
 DC.B "PURE ENERGY,     "
 DC.B "SYNERGY   AND   "
 DC.B "THE SYNDICATE.       "
 dc.b "IF I AIN'T GREETED YOU THEN GET IN TOUCH!             "
 DC.B "WHERE ARE ALL THE BIG GROUPS ON THE ST???      I HAVEN'T SEEN "
 DC.B "ANY DECENT NEW STUFF FOR AGES, IT HAS GOT SO BAD THAT I AM BUYING "
 DC.B "A SNES AT CHRISTMAS TIME.    I WOULD BUY A FALCON BUT I WANT A FASTER "
 DC.B "MACHINE (32MHZ) WITH A DECENT MEGA-ST STYLE CASE AND I STILL THINK "
 DC.B "IT IS TOO MUCH MONEY.                     WELL I CAN THING OF "
 DC.B "NOTHING ELSE TO SAY SO I'LL CATCH UP WITH YOU IN POV 142 (WHICH IS ALMOST "
 DC.B "READY!).                                              "
 DC.B "                                                      "
 DC.B "                                                      "
 dc.b $ff
		even
font		incbin	4plane.fnt
		even

wave_flip		dc.w	0
old_wave_pointer	dc.l	old_wave_1
old_wave_1		dc.l	waves
old_wave_2		dc.l	waves
wave_pointer		dc.l	waves
waves			incbin	sine1.dat
waves_end		incbin	sine1.dat
	even
font_offsets
;           !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	48,31,28,00,00,00,00,35,33,34,00,30,27,29,26,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	38,39,40,41,42,43,44,45,46,47,36,37,00,00,00,32,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	17,18,19,20,21,22,23,24,25,39,00,40,40,00,00,10,11,12

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30

;        v  w  x  y  z  {  |  }  ~  
 dc.b	31,32,33,34,35,00,00,00,00

	even

********** middle area fonts **************
middle_pal1	dc.w	$000,$ba0,$cb0,$dc0,$ed8,$fe8,$ff8,$b88
		dc.w	$c88,$d88,$e88,$f88,$fa8,$fb8,$fd8,$fff
middle_pal2	dc.w	$000,$032,$043,$054,$065,$076,$077,$003
		dc.w	$014,$025,$036,$047,$057,$067,$077,$fff
middle_pal3	dc.w	$000,$000,$000,$000,$073,$074,$075,$000
		dc.w	$020,$030,$040,$050,$060,$071,$072,$fff


pal1		dc.w	$000,$020,$030,$040,$150,$260,$370,$470
		dc.w	$570,$670,$770,$070,$000,$000,$000,$fff
pal2		dc.w	$000,$000,$000,$003,$004,$005,$006,$017
		dc.w	$027,$037,$047,$000,$000,$000,$000,$000
pal3		dc.w	$000,$000,$000,$030,$040,$050,$060,$071
		dc.w	$072,$073,$074,$003,$004,$005,$006,$000

middle_text_pos		dc.l	middle_text
middle_text		incbin	midl_txt.s
			dc.b	-1,-1
			even
minifont		incbin	font.dat
			even


demo_keys	dc.b	0, $02		;key 1
		dc.b	1, $03		;key 2
		dc.b	2, $04		;key 3
		dc.b	3, $05		;key 4
		dc.b	4, $06		;key 5
		dc.b	5, $07		;key 6
		dc.b	6, $08		;key 7
		dc.b	7, $09		;key 8
		dc.b	8, $0a		;key 9

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

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"smells",0
	even
exec2	dc.b	"admirabl",0
	even
exec3	dc.b	"abc17a",0
	even
exec4	dc.b	"the_ulti",0
	even
exec5	dc.b	"fanatic7",0
	even
exec6	dc.b	"w_intro2",0
	even
exec7	dc.b	"m_vision",0
	even
exec8	dc.b	"pe33",0
	even
exec9	dc.b	"copier.pov",0
	even

music		incbin logical.mus

	ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
	endc
bss_start
char_offset	ds.w	1
stack_save	ds.l	1
screen_base	ds.l	1
old_pal		ds.w	16
scr_now		ds.l	1
scr_other	ds.l	1
scr_xor		ds.l	1
vsync_flag	ds.w	1
zero_counter	ds.w	1
key		ds.w	1


************* middle text variables
tab_offset		ds.w	1
xpos			ds.b	1
ypos			ds.b	1
byte_offset		ds.w	1
type_writer_enable	ds.w	1
scroll_ena		ds.w	1
general_timer		ds.w	1
destin_pal		ds.w	16
top_pal			ds.w	16
middle_pal		ds.w	16
black			ds.w	16
fade_top_ena		ds.w	1
fade_middle_ena		ds.w	1

hertz_delay		ds.w	1
	even
***********************

store		ds.b	22
org_rez		ds.b	1
old484		ds.b	1

		ds.b	256
screens		ds.b	32000
		ds.b	32000
bss_end

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
