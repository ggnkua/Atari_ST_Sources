*************************************************************************
*			PERSISTENCE OF VISION 142			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music by:	OZ							*
*									*
*									*
* Grafix by: 	Machine System Data					*
*									*
*									*
* Date:		5/12/93							*
*									*
*									*
*			½ Persistence Of Vision 1993			*
*									*
*************************************************************************
*
* STE tracker menu
*
*	If you use this menu code then please credit me for my work
*	and don't claim you coded it - ta
*

* Protracker replay code, slightly optimised by MSD/POV
MVOL_STE	EQU	$80
FREQ_STE	EQU	1		; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)
	IFEQ FREQ_STE
PARTS_STE	EQU 5-1			; 6.259
LEN_STE	EQU 25
INC_STE	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ_STE-1
PARTS_STE	EQU 5-1			; 12.517
LEN_STE	EQU 50
INC_STE	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ_STE-2
PARTS_STE	EQU 5-1			; 25.035
LEN_STE	EQU 100
INC_STE	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ_STE-3
PARTS_STE	EQU 5-1			; 50.072
LEN_STE	EQU 200
INC_STE	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
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




YES=1
yes=YES
NO=0
no=NO


AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

FINAL=no	;YES to remove escape to assembler code
		;NO to keep it on


******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
DOWNLOAD	equ	no

	ifne	DOWNLOAD
	include	sttx1.s
	org	$1000

Code_Start
Exec_Addr
	ENDC
************************************************************************

B_DATA		equ	56
TBCR		equ	$fffffa1b	;TimerB Control Register
TBDR		equ	$fffffa21	;TimerB Data Register


	opt	o+,w-

	ifeq	DOWNLOAD
	ifeq	AUTORUN4
begin	bra	start
	ds.b	100
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

	jsr	clear_bss

over
********************************************************************

		ifeq	DOWNLOAD
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		move.w	#-1,-(sp)
		move.w	#$b,-(sp)
		trap	#13
		addq.w	#4,sp
		btst	#3,d0
		bne.s	forcestfm

		jsr	test_4_ste
forcestfm	jsr	set_up

	or.b	#%00000010,$ffff820a.w		;50Hz

	tst.w	ste_flag
	bne	init_ste
	jmp	stfm

init_ste
	jsr	depack_mod
	bsr	muson_ste

main_loop
	bsr	vsync
	jsr	set_screen
		bsr	check_pipe
		bsr	scroll
		bsr	print_middle_text
		bsr	do_vus
;	move.w	#$123,$ffff8240.w


	move.w	key,d0

	ifeq	FINAL
	cmp.w	#1,d0		;ESC
	beq	assem
	ENDC

	cmp.w	#11,d0		;0 keyboard
	beq	zero

	cmp.w	#$70,d0		;0 keypad
	beq	zero

	cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
	beq	reset

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


exit	;tst.w	ste_flag
	;bne.s	.shut_down_ste

.shut_down_ste
	bsr	musoff_ste
.co	movem.l	old_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	old_scr_base,d6
	lsr.l	#8,d6
	lea	$ffff8201.w,a6
	movep.w	d6,(a6)
	move.b	original_rez,$ffff8260.w


	ifeq	DOWNLOAD
	jsr	set_user
	endc

	ifne	DOWNLOAD
	move.l	4.w,-(sp)
	rts
	endc

	ifeq	DOWNLOAD
	ifeq	AUTORUN4
	bra	exec
	endc
	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC

	ifeq	FINAL

assem	;tst.w	ste_flag
	;bne.s	.shut_down_ste

;	bra.s	.co
.shut_down_ste
	bsr	musoff_ste

.co	movem.l	old_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	#1,$ffff8260.w
		move.l	old_scr_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

	jsr	set_user
	clr.w	-(sp)
	trap	#1
	ENDC


zero	;flip hertz indicator...
	tst.w	hertz_delay
	bne	main_loop
	eor.w	#$003,hertz_toggle
	move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
	bra	main_loop


reset	move.l	4.w,-(sp)
	rts




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
		cmp.b	#$ff,(a1)
		bne.s	.no_reset
		lea	middle_text,a1
.no_reset	move.b	(a1)+,d1
		move.l	a1,middle_text_pos
		cmp.b	#"^",d1		;termintor
		bne.s	.do_text
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
		mulu	#7*4,d1	;each char is 7*4 planes bytes long
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
		rept	7	;chars are 6 lines deep
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
;		move.l	#middle_text,middle_text_pos
		rts

.no_reset	move.w	d1,general_timer
		move.l	4(a0,d0.w),a0
		add.w	#1,pipe_offset
		jmp	(a0)

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
		dc.l	300,null
		dc.l	1,set_black_middle
		FADE_MIDDLE
		dc.l	1,do_clear

		dc.l	1,enable_scroll
		dc.l	1,set_middle_pal1
		FADE_MIDDLE
		dc.l	-1,-1

null		rts
;eor_red		eor.w	#$700,middle_pal
;		rts


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

;disable_type_writer	move.w	#-1,type_writer_enable
;			rts

set_fade_top_up		movem.l	pic+2,d0-d7
			movem.l	d0-d7,destin_pal
			move.w	#8-1,fade_top_ena
			rts
set_fade_top_black	movem.l	black,d0-d7
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
			bsr	fade_msd
			rts

check_fade_middle	tst.w	fade_middle_ena
			bne.s	.do
			rts
.do			lea	middle_pal+2,a0
			lea	destin_pal+2,a1
			bsr	fade_msd
			rts

fade_msd	;A0=SOURCE PALETTE 	A1=TARGET PALETTE
		move.l	a1,a2
.next_value	move.w	#15-1,d7
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
		beq.s	.MOK1
		bmi.s	.MDN1
		addq.w	#1,d4
		bra.s	.MOK1
.MDN1		SUBQ #1,D4
.MOK1		MOVE D0,D2
		MOVE D1,D3
		AND #$70,D2
		AND #$70,D3
		CMP D2,D3
		BEQ.S .MOK2
		BMI.S .MDN2
		ADD #$10,D4
		BRA.S .MOK2
.MDN2		SUB #$10,D4
.MOK2		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3
		BEQ.S .MOK3
		BMI.S .MDN3
		ADD #$100,D4
		BRA.S .MOK3
.MDN3		SUB #$100,D4
.MOK3		MOVE D4,(A0)
		RTS









do_vus	move.l	scr_now,a0
	add.l	#(160*238),a0
	move.l	a0,a4
	moveq	#0,d2
	moveq	#-1,d3

	lea	voice1,a1
	lea	vus+0,a3
	bsr	vu
	lea	40(a4),a0

	lea	voice4,a1
	lea	vus+2,a3
	bsr	vu
	lea	48+40(a4),a0

	lea	voice2,a1
	lea	vus+4,a3
	bsr	vu
	lea	40+48+40(a4),a0

	lea	voice3,a1
	lea	vus+6,a3

vu	move.w	(a1),d0		;get chan data from tracker
	beq.s	.lower		;if no sample has been played this is 0 so
				;value is not higher than last

	move.w	#30,(a3)	;a sample has been played so make vu hit top
	bra.s	.over		;max value of vu then skip smaller check

.lower	tst.w	(a3)		;is value 0?
	beq.s	.over		;yes so don't decrease are vu height value

	subq.w	#2,(a3)		;decrease vu height

.over	move.w	(a3),d0		;get vu height
	and.w	#31,d0		;mask off so max 32 lines high
	move.w	#30,d1
	sub.w	d0,d1
	tst.w	d0		;if fill value is 0 then skip to clear rout
	ble.s	.clear
.loop	move.w	d3,(a0)	;fill in
	move.w	d3,8(a0)
	move.w	d3,16(a0)
	move.w	d3,24(a0)
	lea	-160(a0),a0
	sub.w	#1,d0
	bne.s	.loop
.clear	move.w	d2,(a0)		;clear above vu level (wipes old vu grafix)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	move.w	d2,24(a0)
	lea	-160(a0),a0
	dbra	d1,.clear
	rts


clear_bss	lea	bssstart,a0		;clear BSS 'cause most packers don't
.clear		clr.b	(a0)+
		cmp.l	#eobss,a0
		bne.s	.clear
		rts


new_kbd	movem.l	d0,-(sp)
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

vsync	move.w	#-1,vsyncflag
.ss	tst.w	vsyncflag
	bne.s	.ss
	rts






muson_ste
	bsr	vol_ste			; Calculate volume tables
	bsr	incrcal_ste		; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	lea	nomouse,a0
	jsr	send_2_ik

	move	#$2700,sr
	lea	store,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)

	clr.b	TBCR.w		;stop timerb
	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$70.w,oldvbl
	move.l	$118.w,oldkbd
	move.l	$120.w,old_timerb
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#timerb_ste,$120.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#B_DATA,TBDR.w	;timer B data
	move.b	#8,TBCR.w		;ei timber B

	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w


;*****************************************************
;* Okay all you STE freaks here is the important bit...
;*
;* I've put loads of comments in to help you change the settings
;* The BASS and TREBLE bit has a FULL breakdown of what bits do what
;* so you have no excuse for not changing them.
;*
;* MAC SYS DATA 18/7/92
;*
;*****************************************************

		lea	setsam_dat(pc),a0
		move.w	#6-1,d0
mwwrite		move.w	#$07ff,$ffff8924.w	;MICROWIRE mask register
mwwrite2	cmp.w	#$07ff,$ffff8924.w	;wait for write state
		bne.s	mwwrite2
		move.w	(a0)+,$ffff8922.w	;MICROWIRE data register - make new values...
		dbf	d0,mwwrite
*------------------------------------------------------------------


		clr.b	$FFFFFA19.w		;stop timer A
		move.b	#1,$FFFFFA1F.w		;timer A data
		move.b	#8,$FFFFFA19.w		;start timer A

		move.l	$134.w,old_timera
		move.l	#stereo,$134.w

		move.b	#FREQ_STE,$FFFF8921.w	; Frequency

		lea	$ffff8907.w,a0

		move.l	#sample1_ste,d0
		move.b	d0,(a0)
		lsr.w	#8,d0
		move.l	d0,-5(a0)

		move.l	#sample1_ste+LEN_STE*2,d0
		move.b	d0,12(a0)
		lsr.w	#8,d0
		move.l	d0,7(a0)

		move.b	#3,$ffff8901.w		; Start DMA/repeat 4 ever

		move	#$2300,sr		; Start isr's
		rts


setsam_dat
;this is complex but I'll try to make it simple....
;
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;The VOLUME bit is already taken care of by the rest of the code
; but I've set it anyway... (MSD)
;
;Volume/Tone data values:
;
;Master Volume:      0 - 40 (0 = -80dB, 40 = 0dB)
;Left/Right Volume:  0 - 20 (0 = -80dB, 20 = 0dB)
;Treble/Bass:        0 - 12 (0 = -12dB, 6 = 0dB, 12 = +12dB)
;
;
;                     dd = always 10 cos that's the device output for GI tone chip
;                     ||xxx=master volume (%011 or can be left %101 or right %100)
;                     |||||yyyyyy=volume setting 000000 -80dB (sound off)
;                     |||||||||||                010100 -40dB
;                     |||||||||||                101???   0dB (??? doesn't matter but it don't seem to work if 000)
	dc.w	%0000010011101111		;master


;			   yyyyyy=volume setting 000000 -40dB
;			   ||||||                001010 -20dB
;			   ||||||                0101??   0dB (??? doesn't matter but it don't seem to work if 000)
	dc.w	%0000010101010111		;left
	dc.w	%0000010100010111		;right


;base + treble
;       zzzz
;	0000 -12 dB
;	0110   0 dB
;	1100 +12 dB
;                     xx = always 10 cos that's the device output for GI tone chip
;                     ||yyy = define BASS (001) or TREBLE (010)
;                     |||||@@=don't matter
;                     |||||||zzzz=+12,0,-12Db (see table above)
;                     |||||||||||
	dc.w	%0000010010001100	*treble  (+12 dB) 
	dc.w	%0000010001000110	*bass    (  0 dB)
	dc.w	%0000000000000010	*mixer	01=mix sound chip
					*       10=do not mix
					*       11=reserved


musoff_ste	bsr	vsync
		move	#$2700,sr

		clr.b	$FFFFFA19.w	; Stop timer A
		clr.b	$FFFFFA1F.w	; timer A data
		clr.b	TBCR.w		; Stop timer B

		move.l	oldvbl,$70.w
		move.l	oldkbd,$118.w
		move.l	old_timerb,$120.w
		lea	store,a0
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0),$fffffa13.w

		move.l	old_timera,$134.w	; Restore everything

		clr.b	$FFFF8901.w		; Stop DMA
		bset	#3,$fffffa17.w
		lea	yesmouse,a0
		jsr	send_2_ik

		move	#$2300,sr
		rts


;--------------------------------------------------------- Volume table --
vol_ste	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL_STE,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop
	rts

vtab	DS.B 65*256
vtabend

incrcal_ste
	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC_STE,d2

recalc_ste
	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc_ste
	rts

itab	DS.L	$30
stab	DS.L	$3A0-$30


;-------------------------------------------------------- DMA interrupt --
stereo		move	#$2500,sr
		bclr	#5,$FFFFFA0F.w
		movem.l	d0-a6,-(sp)

		move.l	samp1_ste(pc),d0
		move.l	d0,d1
		move.l	samp2_ste(pc),samp1_ste
		move.l	d0,samp2_ste

		lea	$FFFF8907.w,a0
		move.l	samp1_ste(pc),d0
		move.b	d0,(a0)
		lsr.w	#8,d0
		move.l	d0,-5(a0)

		move.l	samp1_ste(pc),d0
		add.l	#LEN_STE*2,d0
		move.b	d0,12(a0)
		lsr.w	#8,d0
		move.l	d0,7(a0)

		subq.w	#1,count_ste
		bpl.s	.nomus

		move.w	#PARTS_STE,count_ste
		bsr	music

.nomus		lea	itab(pc),a5
		lea	vtab(pc),a3
		moveq	#0,d0
		moveq	#0,d4

v1_ste		movea.l	wiz2lc(pc),a0

		move.w	wiz2pos(pc),d0
		move.w	wiz2frc(pc),d1

		move.w	aud2per(pc),d7
		add.w	d7,d7
		add.w	d7,d7
		move.w	0(a5,d7.w),d2

		movea.w	2(a5,d7.w),a4

		move.w	aud2vol(pc),d7
		asl.w	#8,d7
		lea	0(a3,d7.w),a2

		movea.l	wiz3lc(pc),a1

		move.w	wiz3pos(pc),d4
		move.w	wiz3frc(pc),d5

		move.w	aud3per(pc),d7
		add.w	d7,d7
		add.w	d7,d7
		move.w	0(a5,d7.w),d6
		movea.w	2(a5,d7.w),a5

		move.w	aud3vol(pc),d7
		asl.w	#8,d7
		lea	0(a3,d7.w),a3

		movea.l	samp1_ste(pc),a6
		moveq	#0,d3

		REPT LEN_STE
		add.w	a4,d1
		addx.w	d2,d0
		add.w	a5,d5
		addx.w	d6,d4
		move.b	0(a0,d0.l),d3
		move.b	0(a2,d3.w),d7
		move.b	0(a1,d4.l),d3
		add.b	0(a3,d3.w),d7
		move.w	d7,(a6)+
		ENDR

		cmp.l	wiz2len(pc),d0
		blt.s	.ok2
		sub.w	wiz2rpt(pc),d0

.ok2		move.w	d0,wiz2pos
		move.w	d1,wiz2frc

		cmp.l	wiz3len(pc),d4
		blt.s	.ok3
		sub.w	wiz3rpt(pc),d4

.ok3		move.w	d4,wiz3pos
		move.w	d5,wiz3frc

		lea	itab(pc),a5
		lea	vtab(pc),a3
		moveq	#0,d0
		moveq	#0,d4

v2_ste		movea.l	wiz1lc(pc),a0

		move.w	wiz1pos(pc),d0
		move.w	wiz1frc(pc),d1

		move.w	aud1per(pc),d7
		add.w	d7,d7
		add.w	d7,d7
		move.w	0(a5,d7.w),d2
		movea.w	2(a5,d7.w),a4

		move.w	aud1vol(pc),d7
		asl.w	#8,d7
		lea	0(a3,d7.w),a2

		movea.l	wiz4lc(pc),a1

		move.w	wiz4pos(pc),d4
		move.w	wiz4frc(pc),d5

		move.w	aud4per(pc),d7
		add.w	d7,d7
		add.w	d7,d7
		move.w	0(a5,d7.w),d6
		movea.w	2(a5,d7.w),a5

		move.w	aud4vol(pc),d7
		asl.w	#8,d7
		lea	0(a3,d7.w),a3

		movea.l	samp1_ste(pc),a6
		moveq	#0,d3

		REPT LEN_STE
		add.w	a4,d1
		addx.w	d2,d0
		add.w	a5,d5
		addx.w	d6,d4
		move.b	0(a0,d0.l),d3
		move.b	0(a2,d3.w),d7
		move.b	0(a1,d4.l),d3
		add.b	0(a3,d3.w),d7
		move.b	d7,(a6)
		addq.w	#2,a6
		ENDR

		cmp.l	wiz1len(pc),d0
		blt.s	.ok1
		sub.w	wiz1rpt(pc),d0

.ok1		move.w	d0,wiz1pos
		move.w	d1,wiz1frc

		cmp.l	wiz4len(pc),d4
		blt.s	.ok4
		sub.w	wiz4rpt(pc),d4

.ok4		move.w	d4,wiz4pos
		move.w	d5,wiz4frc

		movem.l	(sp)+,d0-a6
		rte

;-------------------------------------------- Hardware-registers & data --
count_ste	DC.W PARTS_STE

wiz1lc	DC.L sample1_ste
wiz1len	DC.L 320
wiz1rpt	DC.W 320
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1_ste
wiz2len	DC.L 320
wiz2rpt	DC.W 320
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1_ste
wiz3len	DC.L 320
wiz3rpt	DC.W 320
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1_ste
wiz4len	DC.L 320
wiz4rpt	DC.W 320
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W	0
	DS.W	3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0
dummy	DC.L 0

samp1_ste	DC.L sample1_ste
samp2_ste	DC.L sample2_ste

sample1_ste	DS.W LEN_STE
sample2_ste	DS.W LEN_STE

;---------------------------------------------------- Interrupts on/off --
newvbl		movem.l	d0-d7,-(sp)
		movem.l	top_pal,d0-d7		;set colours after isr
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7
		clr.w	vsyncflag
		clr.b	TBCR.w
		move.b	#B_DATA,TBDR.w	;set init timerb data
		move.l	#timerb_ste,$120.w
		move.b	#8,TBCR.w		;ei timer b
		tst.w	hertz_delay
		bne.s	.dec_hertz

		tst.w	general_timer
		bne.s	.dec
		rte
.dec		sub.w	#1,general_timer
		rte
.dec_hertz	sub.w	#1,hertz_delay
		tst.w	general_timer
		bne.s	.dec
		rte


timerb_ste	clr.b	TBCR.w		;DI all other interrupts
		move.l	middle_pal,$ffff8240.w
		move.l	#timerb_ste_part2,$120.w
		move.b	#142,TBDR.w
		move.b	#8,TBCR.w
		movem.l	d0-d6,-(sp)
		movem.l	middle_pal+4,d0-d6
		movem.l	d0-d6,$ffff8244.w
		movem.l	(sp)+,d0-d6
		rte

timerb_ste_part2
		clr.b	TBCR.w
		move.l	#border_ste,$120.w
		move.b	#1,TBDR.w
		move.b	#8,TBCR.w
		rte

border_ste	clr.b	TBCR.w
		REPT 64				;wait for 1/2 a screen width
		nop
		ENDR
.loop		tst.b	$ffff8209.w		;check low video pos
		bne.s	.loop
		clr.b	$ffff820a.w		;60Hz
		move.w	#$007,$ffff8242.w
		REPT	22-4
		nop
		ENDR
		MOVE.B	#2,$FFFF820A.W
		move.w	hertz_toggle,$ffff8240.w
		rte


;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	mod_data,a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7
roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep


repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	move.w	#$700,$ffff8240.w
	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	mod_data,a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	lea	mod_data,a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3



arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp2	move.w	$10(a4),d2

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	mod_data+$043C,a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.w	d0,dmacon		clr.w	dmacon
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	moveq	#0,d3		;speed increase by MSD of POV

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	move.w	d3,wiz1pos		;;speed increase

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	move.w	d3,wiz2pos		;;speed increase

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	move.w	d3,wiz3pos		;;speed increase


wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	move.w	d3,wiz4pos		;;speed increase

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	move.w	d3,pattpos		;speed increase
	move.b	d3,break		;speed increase
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	mod_data+$03B6,d1
	bne.s	endr
	move.b	mod_data+$03B7,songpos
endr	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	3(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#2,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$F,d0
	mulu	d0,d2
	lsr.w	#6,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,6(a3)
	move.b	$1A(a4),d0
	lsr.w	#2,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#4,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W	6
counter	DC.W	0
songpos	DC.B	0
break	DC.B	0
pattpos	DC.W	0

dmacon		DC.W	0
samplestarts	DS.L	$1F

voice1	DS.W	10
	DC.W	1
	DS.W	3
voice2	DS.W	10
	DC.W	2
	DS.W	3
voice3	DS.W	10
	DC.W	4
	DS.W	3
voice4	DS.W	10
	DC.W	8
	DS.W	3

set_up		move.b	#$12,$fffffc02.w	;DI mouse

		move.l	$44e.w,old_scr_base

		move.b	$ffff8260.w,original_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette

		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,destin_pal

		tst.w	ste_flag
		bne.s	aste
		movem.l	d0-d7,$ffff8240.w
aste		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		clr.b	$ffff8260.w

		movem.l	middle_pal1,d0-d7
		movem.l	d0-d7,middle_pal
		clr.w	scroll_ena		;start scroller
		move.w	#-1,type_writer_enable
		move.w	#210,general_timer

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#160*256,d1
		eor.l	d0,d1
		move.l	d1,scr_xor
		bsr	set_screen

		tst.w	ste_flag
		beq.s	notste

		lea	chip+34,a0
		move.l	scr_now,a1
		move.w	#32000/4-1,d0
.show_chip	move.l	(a0)+,(a1)+
		dbf	d0,.show_chip

		movem.l	chip+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.w	#13000,d7	;delay for chip pic on screen
.get_key	move.w	#$b,-(sp)
		trap	#1
		addq.l	#2,sp
		tst.l	d0
		bmi.s	.yes
		dbf	d7,.get_key
		bra.s	.fin_setup
.yes		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
.fin_setup	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
notste
		bsr	set_screen
		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#160*256,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show
		rts

set_screen	move.l	scr_now,d6
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
		trap	#1		;back to user
		addq.l	#6,sp		;correct stack
		rts





;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade		move.w	#7,d6
		move.l	a1,a2
.next_value	lea	$ffff8240.w,a0
		move.w	#16-1,d7
.loop		bsr	.modify
		add.w	#2,a0
		add.w	#2,a1
		dbf	d7,.loop
		move.w	#4,d0
		bsr	.vbl
		move.l	a2,a1
		dbf	d6,.next_value
		rts

.vbl		movem.l	d0-d3/d7/a0-a3,-(sp)
		move.l	d0,d7
.loop2		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		dbf	d7,.loop2
		movem.l	(sp)+,d0-d3/d7/a0-a3
		rts

.modify		move.w	(a0),d0		;get color value
		move.w	(a1),d1		;target pal
		move.w	d0,d4		;NEW COL
		move.w	d0,d2
		move.w	d1,d3
		and.w	#$7,d2
		and.w	#$7,d3
		cmp.w	d2,d3
		beq.s	.mok1
		bmi.s	.mdn1
		addq.w	#1,d4
		bra.s	.mok1
.mdn1		SUBQ #1,D4
.mok1		MOVE D0,D2
		MOVE D1,D3
		AND #$70,D2
		AND #$70,D3
		CMP D2,D3
		BEQ.S .mok2
		BMI.S .mdn2
		ADD #$10,D4
		BRA.S .mok2
.mdn2		SUB #$10,D4
.mok2		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3
		BEQ.S .mok3
		BMI.S .mdn3
		ADD #$100,D4
		BRA.S .mok3
.mdn3		SUB #$100,D4
.mok3		MOVE D4,(A0)
		rts


black_out	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts


send_2_ik	move.l	a0,-(sp)
		move.w	#2-1,-(sp)
		move.w	#$19,-(sp)
		trap	#14
		addq.l	#8,sp
		rts

; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.
test_4_ste	move.w	#$2300,sr
		lea	$ffff8205.w,a5
		move.b	(a5),d7
		move.b	#'M',(a5)	;poke new value
		cmp.b	(a5),d7		;get value again, is it same?
		beq	.notSTE	;yes same so not ste
		move.b	d7,(a5)
		move.w	#-1,ste_flag
.notSTE		rts




depack_mod
; #############################################################################
; depack routine for module packer
; In :
; a0 = Pointer on module
		lea	mod_data,a0

		bsr	analyse_module		; find sample start/end
		bsr	init_depack

		movea.l	sample_start(PC),A0	; packed sample
		move.l	sample_end(PC),D0
		sub.l	A0,D0			; unpacked length

		move.l	D0,-(A7)
		bsr	depack_sample		; depack over source
		move.l	(A7)+,D0
		rts

; a0=module address

analyse_module:	move.l	A0,-(A7)

		lea	$3b8(A0),A1

		moveq	#$7f,D0
		moveq	#0,D4
mt_loop		move.l	D4,D2
		subq.w	#1,D0
mt_lop2		move.b	(A1)+,D4
		cmp.b	D2,D4
		bgt.s	mt_loop
		dbra	D0,mt_lop2
		addq.b	#1,D2

		asl.l	#8,D2
		asl.l	#2,D2
		add.l	#$043c,D2
		move.l	D2,D1
		add.l	A0,D2
		movea.l	D2,A2

		move.l	A2,sample_start

		moveq	#$1e,D0
mt_lop3		moveq	#0,D4
		move.w	42(A0),D4
		add.l	D4,D4
		adda.l	D4,A2
		adda.l	#$1e,A0
		dbra	D0,mt_lop3

		move.l	A2,sample_end

		movea.l	(A7)+,A0

		rts

; a0=packed sample (also destination)
; d0=unpacked length

depack_sample	lea	depack_hi(PC),A2
		lea	depack_lo(PC),A3

		addq.l	#1,D0
		and.b	#-2,D0			; round length up
		move.l	D0,D7
		lsr.l	#1,D7			; sample length in words

		lea	0(A0,D0.l),A1		; destination end
		adda.l	D7,A0			; source end

		move.w	#128,D0			; last byte
		moveq	#0,D1			; clear temp

depack_loop	move.b	-(A0),D1		; get 2 distances
		add.b	0(A2,D1.w),D0
		move.b	D0,-(A1)
		add.b	0(A3,D1.w),D0
		move.b	D0,-(A1)

		subq.l	#1,D7
		bne.s	depack_loop

		rts

init_depack	lea	depack_lo(PC),A1
		move.w	#15,D7
init1		lea	power_bytes(PC),A0
		move.w	#15,D6
init2		move.b	(A0)+,(A1)+
		dbra	D6,init2
		dbra	D7,init1

		lea	power_bytes(PC),A0
		lea	depack_hi(PC),A1
		move.w	#15,D7
init3		move.w	#15,D6
		move.b	(A0)+,D0
init4		move.b	D0,(A1)+
		dbra	D6,init4
		dbra	D7,init3
		rts


power_bytes	DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64

sample_start	DC.L 0
sample_end	DC.L 0

depack_lo	DS.B 256
depack_hi	DS.B 256


stfm		lea	stfmdata,a0
		move.l	#stfmdataend-stfmdata,d0
		move.l	old_scr_base,a1
		sub.l	d0,a1
		move.l	a1,a2
		move.l	d0,d1
.loop		move.b	(a0)+,(a1)+
		sub.l	#1,d0
		bne.s	.loop

		lea	mover(pc),a0
		move.l	a2,a1
		move.l	#moverend-mover,d0
		sub.l	d0,a1
		move.l	a1,a3
.loop2		move.b	(a0)+,(a1)+
		sub.l	#1,d0
		bne.s	.loop2
		jmp	(a3)

mover		lea	$10000,a1
		move.l	a2,a0
		bsr	depack
		jmp	$10000

;ATOMIK DECRUNCH SOURCE CODE v3.5

;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.

;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
             
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

;call it by BSR DEPACK or JSR DEPACK but call it!

MODE:		EQU	0
PIC_ALGO:	EQU	1
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	0

depack:	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	MODE
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	MODE
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	RESTORE_SPACE
buff_marg:	dcb.b	$90+DEC_SPACE+$C
	endc

moverend

stfmdata	incbin	stfm.dat
stfmdataend



	ifeq	DOWNLOAD
*****************************
	SECTION DATA
*****************************
	endc

mod_data	INCBIN	zzazzpak.mod

mod_stop
	ds.b	83872-(mod_stop-mod_data)

	DS.B	16330			; Workspace
workspc	DS.W	1

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
;	dc.b	4, $06		;key 5
;	dc.b	5, $07		;key 6
;	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
;	dc.b	4, $6b		;keypad 5
;	dc.b	5, $6c		;keypad 6
;	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"km.msd",0
	even
exec2	dc.b	"paralax1.ste",0
	even
exec3	dc.b	"paralax2.ste",0
	even
exec4	dc.b	"copier.pov",0
	even
exec5	dc.b	"filename.ext",0
	even
exec6	dc.b	"filename.ext",0
	even
exec7	dc.b	"filename.ext",0
	even
exec8	dc.b	"filename.ext",0
	even
exec9	dc.b	"filename.ext",0
	even


pic		incbin	pic.pi1

nomouse		dc.b	$12,$1a
yesmouse	dc.b	$14,$08
line_ptr	dc.l	scroll_text



scroll_pointer	dc.l	init_scroll_text

init_scroll_text

scroll_text
 dc.b "           WELCOME TO ANOTHER P.O.V. 'OH NOT THAT MENU AGAIN' COMPILATION "
 DC.B "DISC.      YES THIS MENU WAS RELEASED ON P.O.V 141 BUT THIS TIME IT "
 DC.B "IS PLAYING A MODULE AT 12.5 KHZ AND IT ONLY WORKS ON AN STE.   IF YOU "
 DC.B "WANT TO SEE THE OTHER VERSION OF THIS MENU (THE STFM VERSION) YOU CAN "
 DC.B "HOLD ALTERNATE DOWN WHILST THE MENU IS INITIALISING OR RUN THIS ON AN STFM. "
 dc.b "     THIS MENU WAS RELEASED ON 16TH JAN 1994 BY MAC SYS DATA.  WE SHOULD "
 DC.B "SEE ANOTHER MENU BY BORIS SOON AS HE IS SUPPOSED TO BE CODING A MENU.      "
 DC.B "IF YOU LIKE CODING OR WANT TO SEE HOW I PUT MENUS TOGETHER THEN GET HOLD "
 DC.B "OF THE FIRST PERSISTENCE OF VISION OFFICIAL SOURCE CODE DISC OUT NOT. IT "
 DC.B "IS FULL OF SOURCE CODE FOR YOU TO USE OR ABUSE. FURTHER DISCS WILL BE "
 DC.B "RELEASED AS AND WHEN I GET TIME. SOME MENUS CANNOT BE RELEASED IN THEIR "
 DC.B "ORIGINAL FORM AS THEY ARE NOT COMPLETELY RELOCATABLE MOSTLY DUE "
 DC.B "TO THE TUNES BUT I HAVE CONVERTED SOME USING GRAZEY'S RELOCATOR.    "
 DC.B "I WILL RELEASE SOME OF THE MORE INTERESTING MENUS ON ABOUT DISC "
 DC.B "THREE. ALL YOU NEED TO USE THE SOURCE CODE IS GENST V2.08 OR HIGHER. "
 DC.B " I PERSONNALLY USE DEVPAC DEVELOPER AS IT IS NICE AND FRIENDLY UNLIKE "
 DC.B "DEVPAC 3 WHICH IS SLOW AND A PAIN TO USE.              "
 DC.B "WELL THERE IS NO MORE TEXT AS I CANNOT BE BOTHERED TO DO IT.       "
 DC.B "                     WRAP. "
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
 dc.b	17,18,19,20,21,22,23,24,25,39,00,40,40,00,00,00,01,02

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20

;        v  w  x  y  z  {  |  }  ~  
 dc.b	21,22,23,24,25,00,00,00,00

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
			dc.b	$ff
			even
minifont		incbin	font.dat
			even


chip		incbin	chip.pi1

	ifeq	DOWNLOAD
	SECTION BSS
	endc
bssstart


************* middle text variables
char_offset	ds.w	1
hertz_toggle	ds.w	1
tab_offset	ds.w	1
xpos		ds.b	1
ypos		ds.b	1
byte_offset	ds.w	1
type_writer_enable	ds.w	1
scroll_ena	ds.w	1
general_timer	ds.w	1
destin_pal		ds.w	16
top_pal			ds.w	16
middle_pal		ds.w	16
black			ds.w	16
fade_top_ena		ds.w	1
fade_middle_ena		ds.w	1



old_timerb	ds.l	1
old_timera	ds.l	1
store		ds.l	1
scroll_number	ds.w	1
oldkbd		ds.l	1
key		ds.w	1
ste_flag	ds.w	1
hertz_delay	ds.w	1
oldvbl		ds.l	1
old_palette	ds.w	16
stack_save	ds.l	1
old_scr_base	ds.l	1
screen_base	ds.l	1
original_rez	ds.b	1

	even

scr_now		ds.l	1
scr_xor		ds.l	1
scr_other	ds.l	1

vus	ds.w	1		;last recorded level of VUs
	ds.w	1
	ds.w	1
	ds.w	1

vsyncflag	ds.w	1

	ds.b	256
screens	ds.b	160*256
	ds.b	160*256
eobss


	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
