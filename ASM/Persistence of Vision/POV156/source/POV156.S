*************************************************************************
*			PERSISTENCE OF VISION 156			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music by:								*
*									*
*									*
* Grafix by: 	Machine System Data					*
*									*
*									*
* Date:		25th June 1993/Jan 97					*
*									*
*************************************************************************
* STE/STFM tracker menu
*
* To whom it may concern:
*
*	If you use this code credit me as I am fed up of people ripping
*	my code and saying they wrote it.
*

MVOL_STE	EQU	$80
FREQ_STE	EQU	2		; 0=6.259, 1=12.517, 2=25.036
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


;****** STFM BITS ***********
* Uses registers D5-D7/A6.
MVOL	EQU	$60			; >= $40 ($60 recommended)
FREQ	EQU	2			; 0=6.144, 1=8.192, 2=12.288
					; 3=16.384
	IFEQ FREQ
A_DATA	EQU 40				; 6.144
D_DATA	EQU 164
PARTS	EQU 3-1
LEN	EQU 41
INC	EQU $02469BC0			; 3579546/6144*65536
	ELSEIF
	IFEQ FREQ-1
A_DATA	EQU 30				; 8.192
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 41
INC	EQU $01B4F4D0			; 3579546/8192*65536
	ELSEIF
	IFEQ FREQ-2
A_DATA	EQU 20				; 12.288
D_DATA	EQU 82
PARTS	EQU 6-1
LEN	EQU 41
INC	EQU $01234DE0			; 3579546/12288*65536
	ELSEIF
	IFEQ FREQ-3
A_DATA	EQU 15				; 16.384
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 82
INC	EQU $00DA7A68			; 3579546/16384*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC
;***********************************************************************




YES=1
yes=YES
NO=0
no=NO


AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

FINAL=yes	;YES to remove escape to assembler code
		;NO to keep it on

DOWNLOAD=no

	opt	o+,w-

	ifne	DOWNLOAD
	include	"transmit.s"


	org	$20000

Code_Start
Exec_Addr

	endc


	ifeq	AUTORUN4
begin	bra	start
	ds.l	99
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

	jsr	clear_bss
	ifeq	DOWNLOAD
	jsr	set_super
	endc

	jsr	test_4_falcon
	jsr	set_up

	cmp.l	#"MSD!",$220.w	;this will prevent the 'stolen' bit showing everytime
	beq	no_advert
	move.l	#"MSD!",$220.w
	lea	stolen+34,a0
	move.l	present_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	lea	white,a1
	bsr	fade
	lea	stolen+2,a1
	bsr	fade

	move.w	#10000,d7
.delay_key
	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	bne.s	.get
	dbf	d7,.delay_key
	bra.s	.ok
.get	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
.ok

next
	lea	black,a1
	bsr	fade
	
	lea	cbr400+34,a0
	move.l	present_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	lea	white,a1
	bsr	fade
	lea	cbr400+2,a1
	bsr	fade

	move.w	#28000,d7
.delay_key
	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	bne.s	.get
	dbf	d7,.delay_key
	bra.s	.ok
.get	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
.ok
	lea	black,a1
	bsr	fade

no_advert
	cmp.l	#"PERS",check
	bne	reset
	bsr	show_pic
	tst.w	ste_flag
	bne.s	init_ste
	bsr	muson_stfm			; Install music
	jsr	set_new_palette
	move.l	#stfm_scroll,scroll_rout
	bra.s	main_loop
init_ste	move.l	#ste_scroll,scroll_rout
		bsr	muson_ste
		jsr	set_new_palette






main_loop	bsr	vsync
		bsr	flip_screen
;		move.w	#$123,$ffff8240.w
	bsr	flash
		move.l	scroll_rout,a0
		jsr	(a0)
;		clr.w	$ffff8240.w
		eor.w	#4,wave_number


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

exit		tst.w	ste_flag
		bne.s	.shut_down_ste
		bsr	musoff_stfm	; Restore system completely
		bra.s	.co
.shut_down_ste
		bsr	musoff_ste
.co		jsr	set_old_palette
		move.b	old_484,$484.w

		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp

	move.b	old_rez,$ffff8260.w

	move.l	old_base,a0	;put screen base back to original value
	bsr	set_screen

	ifeq	DOWNLOAD
	jsr	set_user
	endc

	ifeq	AUTORUN4
	bra	exec

	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC

		ifeq	FINAL
assem
	ifne	DOWNLOAD
	clr.l	$220.w
	move.l	4.w,-(sp)
	rts
	endc

		tst.w	ste_flag
		bne.s	.shut_down_ste
		bsr	musoff_stfm	; Restore system completely
		bra.s	.co
.shut_down_ste
		bsr	musoff_ste
.co		jsr	set_old_palette

		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp

		move.b	old_rez,$ffff8260.w

		move.l	old_base,a0
		bsr	set_screen		

		move.l	old_base,a0	;put screen base back to original value
		bsr	set_screen

		jsr	set_user

		clr.w	-(sp)
		trap	#1
		ENDC

zero		;flip hertz indicator...
		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$002,hertz_colour
		eor.w	#-1,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop


reset	move.l	4.w,-(sp)
	rts




stfm_scroll	move.w	wave_number,d0
		lea	old_wave_pointer,a1
		add.w	d0,a1
		move.l	(a1),a1
		move.w	#40-1,d0
		moveq	#0,d3
		move.w	d3,d2
		move.w	d3,d4	;clear byte eor offset reg
		move.l	present_base,a4
clear_loop	move.l	a4,a0
		move.w	(a1)+,d1
		add.w	d2,d1		;byte eor offset
		add.w	d1,a0
		lea	31-6*160(a0),a3
		REPT	6
		move.b	d3,(a0)
		move.b	d3,(a3)
		lea	160(a0),a0
		lea	160(a3),a3
		ENDR
		not.w	d4
		bpl.s	.word
		addq.w	#1,d2
		bra.s	.la
.word		addq.w	#7,d2
.la		move.l	a2,a0
		dbf	d0,clear_loop

**** now the print scroll routine ****
		move.l	present_base,a1
		cmp.l	#waves_end,wave_pointer
		blt.s	.no_reset
		move.l	#waves,wave_pointer
.no_reset	move.l	wave_pointer,a4
		lea	font_offsets,a2
		move.l	scroll_pointer,a3
		move.l	a3,a5
		move.w	wave_number,d1
		move.l	a5,-(sp)
		lea	old_wave_pointer,a5
		add.w	d1,a5
		move.l	0(a5),d4
		move.l	(sp)+,a5
		clr.w	byte_eor
		moveq	#40,d3
		move.w	char_offset,d2
next_char	move.w	d2,-(sp)
		move.b	(a5),d2		;get a letter
		sub.b	#32,d2		;rid of ASCII
		moveq	#0,d0
		lea	font,a0
		move.b	(a2,d2),d0
		move.w	(sp)+,d2
		lsl.w	#7,d0	;mulu 32*4 = 128
		add.w	d0,a0
		move.w	d2,d0
		lsl.w	#5,d0	;mulu 32 
		add.w	d0,a0
.column		moveq	#0,d1
		move.l	a1,-(sp)
		move.w	(a4)+,d1
		move.l	d4,a1
		move.w	d1,(a1)+
		move.l	a1,d4
		move.l	(sp),a1
		add.w	d1,a1
OFF	set	0
		REPT	31		;scroller depth
		move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
		ENDR
		add.w	#1,a0
		move.l	(sp)+,a1
		subq.w	#1,d3
		beq.s	.finish
		addq.w	#1,a1		;lower byte of word
		tst.w	byte_eor
		beq.s	.skip		;if byte_eor=0 then do next word
		addq.w	#6,a1		;else goto next word on screen
.skip		not.w	byte_eor
		addq.w	#1,d2		;character offset
		and.w	#3,d2
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
		rts

ste_scroll
**first clear above and below the old scroll (we don't have to clear
** the whole scroll area as we will overwrite the old area)
		move.w	wave_number,d0
		lea	old_wave_pointer,a1
		move.l	0(a1,d0.w),a1
		move.w	#40-1,d0
		moveq	#0,d2
		move.w	d2,d1
		move.w	d2,d3
		move.w	d2,d4
		move.l	present_base,a4
.clear_loop	move.l	a4,a0
		move.w	(a1)+,d1
		move.l	a0,a2
		add.w	d1,a0
		lea	23*160(a0),a3
		REPT	6
		move.b	d3,(a0,d2.w)
		move.b	d3,(a3,d2.w)
		lea	160(a0),a0
		lea	160(a3),a3
		ENDR
		not.w	d4
		bpl.s	.word
		addq.w	#1,d2
		bra.s	.la
.word		addq.w	#7,d2
.la		move.l	a2,a0
		dbf	d0,.clear_loop

**** now the print scroll routine ****
		move.l	present_base,a1
		cmp.l	#waves_end,wave_pointer
		blt.s	.no_reset
		move.l	#waves,wave_pointer
.no_reset	move.l	wave_pointer,a4
		lea	font_offsets,a2
		move.l	scroll_pointer,a3
		move.l	a3,a5

		move.w	wave_number,d1
		lea	old_wave_pointer,a6
		move.l	0(a6,d1.w),a6

		clr.w	d4
		moveq	#40,d3
		move.w	char_offset,d2
.next_char	move.b	(a5),d6		;get a letter
		sub.b	#32,d6		;rid of ASCII
		ext.w	d6

		moveq	#0,d0
		lea	font,a0
		move.b	(a2,d6),d0

		lsl.w	#7,d0	;mulu 32*4 = 128
		add.w	d0,a0

		move.w	d2,d0
		lsl.w	#5,d0	;mulu 32 
		add.w	d0,a0

.column		moveq	#0,d1
		move.w	(a4)+,d1
		move.l	a1,-(sp)

		move.w	d1,(a6)+	;store offset down screen for clearing

		add.w	d1,a1
OFF	set	0
		REPT	29		;scroller depth
		move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
		ENDR

	add.w	#2,a0

		move.l	(sp)+,a1

		subq.w	#1,d3
		beq.s	.finish

		addq.w	#1,a1		;lower byte of word
		tst.w	d4
		beq.s	.skip		;if d4=0 then do next word
		addq.w	#6,a1		;else goto next word on screen
.skip		not.w	d4
		addq.w	#1,d2		;character offset
		and.w	#3,d2
		bne	.column

		addq.w	#1,a5		;scroll pointer
		tst.b	(a5)		;is end of text?
		bpl	.next_char	;NO!
		lea	scroll_text,a5	;do reset scrolline
		bra	.next_char

.finish		addq.w	#1,char_offset
		and.w	#3,char_offset
		bne.s	.end
		addq.w	#1,a3
		tst.b	(a3)
		bpl.s	.end
		lea	scroll_text,a3
.end		move.l	a3,scroll_pointer
		addq.l	#4,wave_pointer
		rts





flash		sub.w	#1,flash_timer
		beq.s	.yes
		rts
.yes		move.w	#6,flash_timer
		tst.w	flash_counter
		beq.s	.do_flash
		rts
.do_flash	sub.w	#$111,flash_colour
		beq.s	.fin
		move.w	flash_colour,$ffff825c.w
		rts
.fin		move.w	#$777,flash_colour
		move.l	$462.w,d0
		asr.w	d6,d0
		and.w	#$7ff,d0
		move.w	d0,flash_counter
		move.w	pic+2,$ffff825c.w
		rts

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade		move.w	#7,d6
		move.l	a1,a2
next_value	lea	$ffff8240.w,a0
		move.w	#16-1,d7
.loop		bsr	modify
		add.w	#2,a0
		add.w	#2,a1
		dbf	d7,.loop

		move.w	#4,d3
.sync		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp		
		dbf	d3,.sync
		move.l	a2,a1
		dbf	d6,next_value
		rts

modify	move.w	(a0),d0		;get color value
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
grn_dn	sub.w	#$10,d4
grn_ok	move.w	d0,d2
	move.w	d1,d3
	and.w	#$700,d2
	and.w	#$700,d3
	cmp.w	d2,d3
	beq.s	red_ok
	bmi.s	red_dn
	add.w	#$100,d4
	bra.s	red_ok
red_dn	sub.w	#$100,d4
red_ok	move.w	d4,(a0)
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

calc_screen	;calc our own screen address...
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_1
	add.l	#32000,d0
	move.l	d0,screen_2
	rts



flip_screen	;flip between 2 screens to stop flickering
	move.l	present_base,last_base
	move.l	screen_1,a0
	move.w	screen_number,d0
	beq	.1
	move.l	screen_2,a0
.1	move.l	a0,present_base
	eor.w	#-1,screen_number

set_screen	move.l	a0,d0
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		rts



************** STFM TIMER B (RASTER ISR) **************

stfm_timerb	move.l	a0,-(sp)		;stash these
		move.w	#0,a0
sraster		equ *-2
		clr.w	$ffff8240.w
       		move.w	a0,$ffff8242.w
		move.w	a0,$ffff8246.w
		move.w	a0,$ffff824a.w
		move.w	a0,$ffff824e.w
		move.w	a0,$ffff8252.w
		move.w	a0,$ffff8256.w
		move.w	a0,$ffff825a.w
		move.w	a0,$ffff825e.w
		clr.b	$fffffa1b.w		;stop
		move.l	srast_pos,a0		;get position in colour table
		move.w	(a0)+,sraster		;get colour
		move.l	a0,srast_pos		;store new pos
		move.l	(sp)+,a0		;regs
		move.b	#7,$fffffa21.w		;make timerB occur every xx lines
		move.b	#8,$fffffa1b.w		;reenable timer B
		rte				;get outta here



************** STE TIMER B (RASTER ISR) **************
ste_timerb	move.l	a0,-(sp)	;stash reg
		move.w	sraster,a0
		clr.w	$ffff8240.w
		move.w	a0,$ffff8242.w
		move.w	a0,$ffff8246.w
		move.w	a0,$ffff824a.w
		move.w	a0,$ffff824e.w
		move.w	a0,$ffff8252.w
		move.w	a0,$ffff8256.w
		move.w	a0,$ffff825a.w
		move.w	a0,$ffff825e.w
		clr.b	$fffffa1b.w	;stop timerb
		move.l	srast_pos,a0	;get position in colour table
		move.w	(a0)+,sraster	;get colour
		move.l	a0,srast_pos	;store new pos
		move.l	(sp)+,a0	;return to reg
		move.b	#7,$fffffa21.w	;make timerB occur every xx lines
		move.b	#8,$fffffa1b.w	;reenable timer B
		rte			;get outta here


test_4_falcon
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
	bne.s	.nofalcon

	pea	no_falcon
	move.w	#9,-(sp)
	trap	#1
	addq.w	#2,sp
.stopper	bra.s	.stopper
.nofalcon
.notdma
.nocookiejar
	rts

set_up
*************** mod packed with NPAKKER 0.3 *********************
;		lea	mod_data,a0
;		jsr	depack_module
*****************************************************************

		jsr	test_4_ste

		or.b	#%00000010,$ffff820a.w	;50Hz

		move.b	$484.w,old_484
		clr.b	$484.w			;no repeat/key click
		move.l	$44e.w,old_base		;get org screen address

		movem.l	$ffff8240.w,d0-d7	;save old pal
		movem.l	d0-d7,old_palette

		movem.l	black,d0-d7		;black out screen
		movem.l	d0-d7,$ffff8240.w

		move.b	$ffff8260.w,old_rez	;save old rez

		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp

		clr.b	$ffff8260.w		;go low rez

		bsr	calc_screen		;calc our own screen address

		move.l	screen_1,a0		;new screen base
		bsr	set_screen

		move.l	screen_1,present_base
		move.l	screen_2,last_base

		move.w	#$777,flash_colour
		move.w	#800,flash_counter
		move.w	#4,flash_timer
		rts

show_pic	clr.l	pic+30
		lea	pic+34,a0		;show picture
		move.l	present_base,a1
		move.l	last_base,a2
		move.w	#32000/4-1,d0
.sploop		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.sploop
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
	move.b	$fffffa0f.w,(a0)+
	move.b	$fffffa11.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	move.b	$fffffa1f.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	move.b	$fffffa25.w,(a0)

	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$120.w,old_timerb
	move.l	$70.w,oldvbl
	move.l	$118.w,oldkbd
	move.l	#ste_timerb,sm_timerb
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
;	move.l	#ste_timerb,$120.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#1,$fffffa21.w	;timer B data
;	move.b	#8,$fffffa1b.w		;ei timber B

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

		move.l	$134.w,oldtima
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


musoff_ste
	move	#$2700,sr

	clr.b	$FFFFFA19.w		; Stop timer A
	clr.b	$FFFFFA1b.w		; Stop timer B

	move.l	old_timerb,$120.w
	move.l	oldvbl,$70.w
	move.l	oldkbd,$118.w
	lea	store,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa0f.w
	move.b	(a0)+,$fffffa11.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1d.w
	move.b	(a0)+,$fffffa1f.w
	move.b	(a0)+,$fffffa21.w
	move.b	(a0),$fffffa25.w

	move.l	oldtima(pc),$134.w	; Restore everything

	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w

	clr.b	$FFFF8901.w		; Stop DMA

	lea	yesmouse,a0
	jsr	send_2_ik

	move	#$2300,sr
	rts

oldtima	DC.L 0

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


;-------------------------------------------------------- DMA interrupt --
stereo	move	#$2500,sr
	bclr	#5,$FFFFFA0F.w
	movem.l	d0-a6,-(sp)

	move.l	samp1_ste(pc),d0
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

.nomus	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v1_ste	movea.l	wiz2lc(pc),a0

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

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc

	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v2_ste	movea.l	wiz1lc(pc),a0

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

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
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
muson_stfm
	lea	nomouse,a0
	jsr	send_2_ik

	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables
	bsr	clearym			; Clear soundchip registers

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move	#$2700,sr

	lea	store,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa0f.w,(a0)+
	move.b	$fffffa11.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	move.b	$fffffa1f.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	move.b	$fffffa25.w,(a0)

;	move.b	$fffffa07.w,(a0)+
;	move.b	$fffffa09.w,(a0)+
;	move.b	$fffffa13.w,(a0)
;	move.l	$FFFFFA06.w,s06		; Save MFP registers
;	move.l	$FFFFFA12.w,s12
;	move.b	$FFFFFA1D.w,s1d

	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$120.w,old_timerb
	move.l	$118.w,oldkbd
	move.l	$70.w,oldvbl
	move.l	#stfm_timerb,sm_timerb
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#stfm_timerb,$120.w
	bclr	#3,$fffffa17.w		; Autovectors
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#1,$fffffa21.w	;timer B data
	move.b	#8,$fffffa1b.w		;ei timber B

	move.b	#$21,$fffffa07.w	0 0 1 0 0 0 0 1
				;           |         +---- Timer B $120 ena
				;           +-------------- Timer A $134
	move.b	#%01010000,$fffffa09.w	0 1 0 1 0 0 0 0
				;         |   +------------ $110 ena
				;         +---------------- MC6850 $118 ena
	move.b	#%01010000,$fffffa15.w	0 1 0 1 0 0 0 0
				;         |   +------------ $110 mask
				;         +---------------- MC6850 $118 mask
	move.b	#$21,$fffffa13.w	0 0 1 0 0 0 0 1
				;           |         +---- Timer B $120 mask
				;           +-------------- Timer A $134 mask

	clr.b	$fffffa1d.w		;stop timer C & D
	clr.b	$fffffa19.w		;stop timer A
	move.b	#A_DATA,$FFFFFA1F.w	;set timer A data
	move.b	#D_DATA,$FFFFFA25.w	;set timer D data
	move.b	#2,$FFFFFA19.w		;start timer A
	move.b	#6,$FFFFFA1D.w		;timer C & D control

	move.l	$110.w,oldtimd
	move.l	$134.w,oldtima
	move.l	#timerd,$110.w
	move.l	#playvec,$134.w

	lea	sample1(pc),a6
	move	#$2300,sr
	rts

newvbl		move.w	pic+4,$ffff8242.w
		move.w	hertz_colour,$ffff8240.w
		clr.w	vsyncflag
		move.w	srast,sraster
		move.l	#srast,srast_pos
		clr.b	$fffffa1b.w
		move.l	#0,$120.w	;self modified timerb rout
sm_timerb	equ	*-6
		move.b	#1,$fffffa21.w	;set init timerb data

		movem.l	d0/a0-a1,-(sp)
		move.w	scrcoloff,d0
		and.w	#255,d0
		lea	scroller_colours,a0
		add.w	d0,a0
		lea	srast,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0),(a1)
		movem.l	(sp)+,d0/a0-a1
		add.w	#2,scrcoloff
		move.b	#8,$fffffa1b.w		;ei timer b
		tst.w	hertz_delay
		bne.s	.dec_hertz
		tst.w	flash_counter
		bne.s	.dec_flash
		rte
.dec_flash	sub.w	#1,flash_counter
		rte
.dec_hertz	sub.w	#1,hertz_delay
		tst.w	flash_counter
		bne.s	.dec_flash
		rte




musoff_stfm	move	#$2700,sr

		move.l	oldkbd,$118.w
		move.l	oldvbl,$70.w
		move.l	oldtimd(pc),$110.w	; Restore vectors
		move.l	oldtima(pc),$134.w

;		move.l	s06(pc),$FFFFFA06.w
;		move.l	s12(pc),$FFFFFA12.w
;		move.b	s1d(pc),$FFFFFA1D.w

	lea	store,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa0f.w
	move.b	(a0)+,$fffffa11.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1d.w
	move.b	(a0)+,$fffffa1f.w
	move.b	(a0)+,$fffffa21.w
	move.b	(a0),$fffffa25.w

		bset	#3,$FFFFFA17.w		; Softvectors

		lea	yesmouse,a0
		jsr	send_2_ik

		move	#$2300,sr
		rts

s06	DC.L 0
s12	DC.L 0
s1d	DC.B 0
	EVEN

oldtimd	DC.L 0

;-------------------------------------------- Clear soundchip registers --
clearym	move	#$2700,sr

	moveq	#$0A,d0
._1	move.b	d0,$FFFF8800.w
	clr.b	$FFFF8802.w
	dbra	d0,._1			; Clear soundchip registers
	clr.b	$FFFF8800.w
	clr.b	$FFFF8802.w
	move.b	#7,$FFFF8800.w
	move.b	#$FF,$FFFF8802.w

	rts

;----------------------------------------------- Calculate volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	add.b	#$80,d2
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop
	rts



;-------------------------------------------- Calculate increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
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
	dbra	d0,recalc
	rts

itab	DS.L	$30
stab	DS.L	$3A0-$30

;---------------------------------------------------- Samplecalculating --
timerd	movea.l	samp1(pc),a6

	move	#$2300,sr
	movem.l	d0-d4/a0-a4,-(sp)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	move.l	samp2(pc),d0
	move.l	samp1(pc),samp2
	move.l	d0,samp1

	lea	itab(pc),a2
	lea	vtab(pc),a4
	moveq	#0,d1

v1	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d1
	move.w	wiz1frc(pc),d0

	move.w	aud1per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud1vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	REPT LEN
	add.w	d2,d0
	addx.w	d3,d1
	move.b	0(a0,d1.l),d4
	move.b	0(a1,d4.w),d4
	move.w	d4,(a3)+
	ENDR

	cmp.l	wiz1len(pc),d1
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d1

.ok1	move.w	d1,wiz1pos
	move.w	d0,wiz1frc


v2	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d1
	move.w	wiz2frc(pc),d0

	move.w	aud2per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud2vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr	v234

	cmp.l	wiz2len(pc),d1
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d1

.ok2	move.w	d1,wiz2pos
	move.w	d0,wiz2frc


v3	movea.l	wiz3lc(pc),a0

	move.w	wiz3pos(pc),d1
	move.w	wiz3frc(pc),d0

	move.w	aud3per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud3vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr.s	v234

	cmp.l	wiz3len(pc),d1
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d1

.ok3	move.w	d1,wiz3pos
	move.w	d0,wiz3frc


v4	movea.l	wiz4lc(pc),a0

	move.w	wiz4pos(pc),d1
	move.w	wiz4frc(pc),d0

	move.w	aud4per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud4vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr.s	v234

	cmp.l	wiz4len(pc),d1
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d1

.ok4	move.w	d1,wiz4pos
	move.w	d0,wiz4frc

	movem.l	(sp)+,d0-d4/a0-a4
	rte

v234	REPT LEN
	add.w	d2,d0
	addx.w	d3,d1
	move.b	0(a0,d1.l),d4
	move.b	0(a1,d4.w),d4
	add.w	d4,(a3)+
	ENDR

	rts

;-------------------------------------------- Hardware-registers & data --
count	DC.W PARTS

samp1	DC.L sample1
samp2	DC.L sample2

sample1	REPT	LEN
	DC.W	$200
	ENDR

sample2	REPT	LEN
	DC.W	$200
	ENDR

;--------------------------------------------------- Playback-interrupt --
playvec	move.w	(a6)+,d7
	lsl.w	#4,d7
	movem.l	snd_tab(pc,d7.w),d5-d7
	movem.l	d5-d7,$FFFF8800.w
	rte

;--------------------------------------------- Sound data for soundchip --
snd_tab	REPT 384
	DC.L $08000F00,$09000A00,$0A000000,0
	ENDR

	DC.L $08000F00,$09000A00,$0A000000,0
	DC.L $08000F00,$09000A00,$0A000000,0
	DC.L $08000F00,$09000900,$0A000900,0
	DC.L $08000F00,$09000900,$0A000900,0
	DC.L $08000F00,$09000900,$0A000800,0
	DC.L $08000F00,$09000900,$0A000800,0
	DC.L $08000F00,$09000800,$0A000700,0
	DC.L $08000F00,$09000800,$0A000700,0
	DC.L $08000E00,$09000B00,$0A000D00,0
	DC.L $08000E00,$09000B00,$0A000D00,0
	DC.L $08000E00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000A00,$0A000D00,0
	DC.L $08000E00,$09000A00,$0A000D00,0
	DC.L $08000E00,$09000C00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000C00,0
	DC.L $08000E00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000D00,$0A000800,0
	DC.L $08000E00,$09000D00,$0A000800,0
	DC.L $08000E00,$09000D00,$0A000700,0
	DC.L $08000E00,$09000D00,$0A000700,0
	DC.L $08000E00,$09000D00,$0A000000,0
	DC.L $08000E00,$09000D00,$0A000000,0
	DC.L $08000B00,$09000E00,$0A000C00,0
	DC.L $08000B00,$09000E00,$0A000C00,0
	DC.L $08000E00,$09000B00,$0A000C00,0
	DC.L $08000E00,$09000B00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000B00,0
	DC.L $08000E00,$09000C00,$0A000B00,0
	DC.L $08000A00,$09000E00,$0A000C00,0
	DC.L $08000A00,$09000E00,$0A000C00,0
	DC.L $08000E00,$09000A00,$0A000C00,0
	DC.L $08000E00,$09000A00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000A00,0
	DC.L $08000E00,$09000C00,$0A000A00,0
	DC.L $08000E00,$09000900,$0A000C00,0
	DC.L $08000E00,$09000900,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000900,0
	DC.L $08000E00,$09000C00,$0A000900,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000700,0
	DC.L $08000E00,$09000C00,$0A000700,0
	DC.L $08000E00,$09000C00,$0A000600,0
	DC.L $08000E00,$09000C00,$0A000300,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000B00,$0A000A00,0
	DC.L $08000E00,$09000B00,$0A000A00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000D00,$0A000A00,0
	DC.L $08000D00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000D00,$09000D00,$0A000900,0
	DC.L $08000D00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000A00,$0A000900,0
	DC.L $08000E00,$09000A00,$0A000900,0
	DC.L $08000D00,$09000D00,$0A000800,0
	DC.L $08000D00,$09000D00,$0A000700,0
	DC.L $08000D00,$09000D00,$0A000600,0
	DC.L $08000D00,$09000D00,$0A000600,0
	DC.L $08000E00,$09000900,$0A000900,0
	DC.L $08000E00,$09000900,$0A000900,0
	DC.L $08000E00,$09000800,$0A000900,0
	DC.L $08000E00,$09000800,$0A000900,0
	DC.L $08000E00,$09000900,$0A000800,0
	DC.L $08000E00,$09000900,$0A000800,0
	DC.L $08000E00,$09000700,$0A000900,0
	DC.L $08000E00,$09000900,$0A000700,0
	DC.L $08000E00,$09000900,$0A000700,0
	DC.L $08000E00,$09000900,$0A000600,0
	DC.L $08000E00,$09000900,$0A000600,0
	DC.L $08000E00,$09000800,$0A000700,0
	DC.L $08000E00,$09000800,$0A000700,0
	DC.L $08000E00,$09000800,$0A000600,0
	DC.L $08000E00,$09000800,$0A000600,0
	DC.L $08000E00,$09000800,$0A000400,0
	DC.L $08000E00,$09000800,$0A000400,0
	DC.L $08000E00,$09000700,$0A000500,0
	DC.L $08000E00,$09000700,$0A000400,0
	DC.L $08000E00,$09000700,$0A000300,0
	DC.L $08000E00,$09000600,$0A000400,0
	DC.L $08000E00,$09000600,$0A000300,0
	DC.L $08000E00,$09000500,$0A000400,0
	DC.L $08000E00,$09000500,$0A000200,0
	DC.L $08000E00,$09000400,$0A000200,0
	DC.L $08000E00,$09000300,$0A000200,0
	DC.L $08000E00,$09000000,$0A000000,0
	DC.L $08000D00,$09000B00,$0A000A00,0
	DC.L $08000D00,$09000B00,$0A000A00,0
	DC.L $08000A00,$09000C00,$0A000C00,0
	DC.L $08000A00,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000A00,$0A000C00,0
	DC.L $08000D00,$09000900,$0A000B00,0
	DC.L $08000D00,$09000900,$0A000B00,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000A00,$0A000A00,0
	DC.L $08000D00,$09000A00,$0A000A00,0
	DC.L $08000900,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000800,$09000C00,$0A000C00,0
	DC.L $08000800,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000C00,$0A000800,0
	DC.L $08000C00,$09000C00,$0A000800,0
	DC.L $08000D00,$09000B00,$0A000400,0
	DC.L $08000D00,$09000B00,$0A000400,0
	DC.L $08000C00,$09000C00,$0A000700,0
	DC.L $08000C00,$09000C00,$0A000600,0
	DC.L $08000C00,$09000C00,$0A000600,0
	DC.L $08000C00,$09000C00,$0A000500,0
	DC.L $08000D00,$09000A00,$0A000700,0
	DC.L $08000D00,$09000A00,$0A000600,0
	DC.L $08000D00,$09000A00,$0A000600,0
	DC.L $08000D00,$09000A00,$0A000500,0
	DC.L $08000D00,$09000900,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000900,0
	DC.L $08000B00,$09000B00,$0A000B00,0
	DC.L $08000D00,$09000800,$0A000800,0
	DC.L $08000D00,$09000800,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000800,0
	DC.L $08000D00,$09000900,$0A000500,0
	DC.L $08000D00,$09000900,$0A000400,0
	DC.L $08000D00,$09000800,$0A000600,0
	DC.L $08000C00,$09000B00,$0A000700,0
	DC.L $08000D00,$09000700,$0A000700,0
	DC.L $08000C00,$09000B00,$0A000600,0
	DC.L $08000B00,$09000B00,$0A000A00,0
	DC.L $08000800,$09000A00,$0A000C00,0
	DC.L $08000C00,$09000B00,$0A000200,0
	DC.L $08000C00,$09000A00,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000000,0
	DC.L $08000D00,$09000600,$0A000400,0
	DC.L $08000D00,$09000500,$0A000500,0
	DC.L $08000C00,$09000900,$0A000900,0
	DC.L $08000D00,$09000500,$0A000400,0
	DC.L $08000B00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000400,$0A000300,0
	DC.L $08000B00,$09000A00,$0A000A00,0
	DC.L $08000C00,$09000A00,$0A000500,0
	DC.L $08000C00,$09000900,$0A000800,0
	DC.L $08000B00,$09000B00,$0A000800,0
	DC.L $08000C00,$09000A00,$0A000000,0
	DC.L $08000C00,$09000A00,$0A000000,0
	DC.L $08000C00,$09000900,$0A000700,0
	DC.L $08000B00,$09000B00,$0A000700,0
	DC.L $08000C00,$09000900,$0A000600,0
	DC.L $08000B00,$09000A00,$0A000900,0
	DC.L $08000B00,$09000B00,$0A000600,0
	DC.L $08000A00,$09000A00,$0A000A00,0
	DC.L $08000B00,$09000B00,$0A000500,0
	DC.L $08000B00,$09000A00,$0A000800,0
	DC.L $08000B00,$09000B00,$0A000200,0
	DC.L $08000C00,$09000700,$0A000700,0
	DC.L $08000C00,$09000800,$0A000400,0
	DC.L $08000C00,$09000700,$0A000600,0
	DC.L $08000B00,$09000900,$0A000900,0
	DC.L $08000A00,$09000A00,$0A000900,0
	DC.L $08000C00,$09000600,$0A000600,0
	DC.L $08000C00,$09000700,$0A000300,0
	DC.L $08000B00,$09000A00,$0A000500,0
	DC.L $08000B00,$09000900,$0A000800,0
	DC.L $08000B00,$09000A00,$0A000300,0
	DC.L $08000A00,$09000A00,$0A000800,0
	DC.L $08000B00,$09000A00,$0A000000,0
	DC.L $08000B00,$09000900,$0A000700,0
	DC.L $08000B00,$09000800,$0A000800,0
	DC.L $08000A00,$09000900,$0A000900,0
	DC.L $08000A00,$09000A00,$0A000700,0
	DC.L $08000C00,$09000100,$0A000100,0
	DC.L $08000A00,$09000A00,$0A000600,0
	DC.L $08000B00,$09000800,$0A000700,0
	DC.L $08000A00,$09000A00,$0A000500,0
	DC.L $08000A00,$09000900,$0A000800,0
	DC.L $08000A00,$09000A00,$0A000400,0
	DC.L $08000A00,$09000A00,$0A000300,0
	DC.L $08000A00,$09000A00,$0A000200,0
	DC.L $08000900,$09000900,$0A000900,0
	DC.L $08000A00,$09000800,$0A000800,0
	DC.L $08000B00,$09000800,$0A000100,0
	DC.L $08000A00,$09000900,$0A000600,0
	DC.L $08000B00,$09000700,$0A000400,0
	DC.L $08000A00,$09000900,$0A000500,0
	DC.L $08000900,$09000900,$0A000800,0
	DC.L $08000A00,$09000900,$0A000300,0
	DC.L $08000A00,$09000800,$0A000600,0
	DC.L $08000900,$09000900,$0A000700,0
	DC.L $08000A00,$09000900,$0A000000,0
	DC.L $08000900,$09000800,$0A000800,0
	DC.L $08000A00,$09000800,$0A000400,0
	DC.L $08000900,$09000900,$0A000600,0
	DC.L $08000A00,$09000800,$0A000100,0
	DC.L $08000900,$09000900,$0A000500,0
	DC.L $08000900,$09000800,$0A000700,0
	DC.L $08000800,$09000800,$0A000800,0
	DC.L $08000900,$09000800,$0A000600,0
	DC.L $08000900,$09000900,$0A000200,0
	DC.L $08000900,$09000700,$0A000700,0
	DC.L $08000900,$09000900,$0A000000,0
	DC.L $08000800,$09000800,$0A000700,0
	DC.L $08000900,$09000700,$0A000600,0
	DC.L $08000800,$09000800,$0A000600,0
	DC.L $08000900,$09000800,$0A000200,0
	DC.L $08000900,$09000600,$0A000600,0
	DC.L $08000800,$09000700,$0A000700,0
	DC.L $08000800,$09000800,$0A000400,0
	DC.L $08000800,$09000700,$0A000600,0
	DC.L $08000800,$09000800,$0A000200,0
	DC.L $08000700,$09000700,$0A000700,0
	DC.L $08000800,$09000600,$0A000600,0
	DC.L $08000800,$09000700,$0A000400,0
	DC.L $08000700,$09000700,$0A000600,0
	DC.L $08000800,$09000600,$0A000500,0
	DC.L $08000800,$09000600,$0A000400,0
	DC.L $08000700,$09000600,$0A000600,0
	DC.L $08000700,$09000700,$0A000400,0
	DC.L $08000800,$09000500,$0A000400,0
	DC.L $08000600,$09000600,$0A000600,0
	DC.L $08000700,$09000600,$0A000400,0
	DC.L $08000700,$09000500,$0A000500,0
	DC.L $08000600,$09000600,$0A000500,0
	DC.L $08000600,$09000600,$0A000400,0
	DC.L $08000600,$09000500,$0A000500,0
	DC.L $08000600,$09000600,$0A000200,0
	DC.L $08000600,$09000500,$0A000400,0
	DC.L $08000500,$09000500,$0A000500,0
	DC.L $08000600,$09000500,$0A000200,0
	DC.L $08000500,$09000500,$0A000400,0
	DC.L $08000500,$09000400,$0A000400,0
	DC.L $08000500,$09000500,$0A000200,0
	DC.L $08000400,$09000400,$0A000400,0
	DC.L $08000400,$09000400,$0A000300,0
	DC.L $08000400,$09000400,$0A000200,0
	DC.L $08000400,$09000300,$0A000300,0
	DC.L $08000300,$09000300,$0A000300,0
	DC.L $08000300,$09000300,$0A000200,0
	DC.L $08000300,$09000200,$0A000200,0
	DC.L $08000200,$09000200,$0A000200,0
	DC.L $08000200,$09000200,$0A000100,0
	DC.L $08000100,$09000100,$0A000100,0
	DC.L $08000200,$09000100,$0A000000,0
	DC.L $08000100,$09000100,$0A000000,0
	DC.L $08000100,$09000000,$0A000000,0
	DC.L $08000000,$09000000,$0A000000,0

	REPT 384
	DC.L $08000000,$09000000,$0A000000,0
	ENDR

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

arp2	move.w	$10(a4),d2
	bra.s	arp4

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

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	mod_data+$043C,a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

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
	move.w	d3,wiz1pos	;;speed increase

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
	move.w	d3,wiz2pos	;;speed increase

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
	move.w	d3,wiz3pos	;;speed increase


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
	move.w	d3,wiz4pos	;;speed increase

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
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

tst_key		move.w	#11,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

get_key		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

set_super	clr.l	-(sp)		;Set super stack equal
		move.w	#$20,-(sp)	; to user stack before call
		trap	#1
		addq.l	#6,sp		;correct stack
		move.l	d0,stack_save	;save old supervisor stack value
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp		;correct stack
		rts


set_new_palette	lea	pic+2,a0
		bra	set_pal
set_old_palette	lea	old_palette,a0
set_pal		lea	$ffff8240.w,a1
		REPT	8
		move.l 	(a0)+,(a1)+
		ENDR
		rts









clear_bss	lea	bssstart,a0		;clear BSS 'cause most packers don't
.clear		clr.b	(a0)+
		cmp.l	#eobss,a0
		bne.s	.clear
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


; #############################################################################
; depack routine for module packer
; In :
; a0 = Pointer on module

depack_module:

                bsr     analyse_module       ; find sample start/end

                bsr     init_depack

                movea.l sample_start(PC),A0  ; packed sample
                move.l  sample_end(PC),D0
                sub.l   A0,D0                ; unpacked length

                move.l  D0,-(A7)
                bsr     depack_sample        ; depack over source
                move.l  (A7)+,D0
                rts

; a0=module address

analyse_module: move.l  A0,-(A7)

                lea     $03b8(A0),A1

                moveq   #$7f,D0
                moveq   #0,D4
mt_loop:        move.l  D4,D2
                subq.w  #1,D0
mt_lop2:        move.b  (A1)+,D4
                cmp.b   D2,D4
                bgt.s   mt_loop
                dbra    D0,mt_lop2
                addq.b  #1,D2

                asl.l   #8,D2
                asl.l   #2,D2
                add.l   #$043c,D2
                move.l  D2,D1
                add.l   A0,D2
                movea.l D2,A2

                move.l  A2,sample_start

                moveq   #$1e,D0
mt_lop3:
                moveq   #0,D4
                move.w  42(A0),D4
                add.l   D4,D4
                adda.l  D4,A2
                adda.l  #$1e,A0
                dbra    D0,mt_lop3

                move.l  A2,sample_end

                movea.l (A7)+,A0

                rts

; a0=packed sample (also destination)
; d0=unpacked length

depack_sample:
                lea     depack_hi(PC),A2
                lea     depack_lo(PC),A3

                addq.l  #1,D0
                and.b   #-2,D0               ; round length up
                move.l  D0,D7
                lsr.l   #1,D7                ; sample length in words

                lea     0(A0,D0.l),A1        ; destination end
                adda.l  D7,A0                ; source end

                move.w  #128,D0              ; last byte
                moveq   #0,D1                ; clear temp

depack_loop:    move.b  -(A0),D1             ; get 2 distances
                add.b   0(A2,D1.w),D0
                move.b  D0,-(A1)
                add.b   0(A3,D1.w),D0
                move.b  D0,-(A1)

                subq.l  #1,D7
                bne.s   depack_loop

                rts

init_depack:

                lea     depack_lo(PC),A1
                move.w  #15,D7
init1:          lea     power_bytes(PC),A0
                move.w  #15,D6
init2:          move.b  (A0)+,(A1)+
                dbra    D6,init2
                dbra    D7,init1

                lea     power_bytes(PC),A0
                lea     depack_hi(PC),A1
                move.w  #15,D7
init3:          move.w  #15,D6
                move.b  (A0)+,D0
init4:          move.b  D0,(A1)+
                dbra    D6,init4
                dbra    D7,init3

                rts


power_bytes:    DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64

sample_start:   DC.L 0
sample_end:     DC.L 0

depack_lo:      DS.B 256
depack_hi:      DS.B 256

; DEPACK END


****************
* DATA SECTION *
****************
	DC.B	"**HELLO HACKER THIS MOD HAS BEEN PACKED WITH N_PACKER 0.3**"
	EVEN
mod_start
mod_data	INCBIN	streetj.mod
	dc.b	"**HELLO HACKER AGAIN - THE MOD ENDS HERE**"
	even
mod_end
;	ds.b	117450-(mod_end-mod_start)	;original mod length space area

		ds.b	13440		; Workspace
workspc		ds.w	1

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
	dc.b	7, $09		;key 8
	dc.b	8, $0a		;key 9
	dc.b	9, $2e		;key C

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

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9,exec10
exec1		dc.b	"sequence.prg",0	;mst demo
		even
exec2		dc.b	"fuz157.prg",0		;fuzion 157
		even
exec3		dc.b	"fuz160.prg",0		;fuzion 160
		even
exec4		dc.b	"fuz161.prg",0		;fuzion 161
		even
exec5		dc.b	"ics_sote.prg",0
		even
exec6		dc.b	"air_buck.prg",0
		even
exec7		dc.b	"impact83.prg",0
		even
exec8		dc.b	"intro5.prg",0
		even
exec9		dc.b	"PSG_DEMO.prg",0
		even
exec10		dc.b	"copier.pov",0
		even


pic		incbin	pic.pi1

no_falcon	dc.b	13,10,10,10,10,10,10
		dc.b	"SORRY THIS MENU DOES NOT WORK ON THE",13,10
		dc.b	"ATARI FALCON",13,10,0
		even

nomouse		dc.b	$12,$1a
yesmouse	dc.b	$14,$08

scroll_pointer	dc.l	init_scroll_text

init_scroll_text

scroll_text
 dc.b "                                                                "
 dc.b "                                                                "
check
 DC.B "PERSISTENCE OF VISION 156.   RELEASE DATE 1-2-1997.          "
 dc.b "         WELL AS YOU HAVE ALREADY READ I HAVE HAD MY NEW MOTORCYCLE "
 DC.B "STOLEN.    THE BASTARDS BROKE MY GARAGE DOOR OPEN BETWEEN 23:00 AND 23:20 AND "
 DC.B "TOOK IT.  THE THEIVES MUST HAVE PICKED THE BIKE UP AND PUT IT IN THE BACK "
 DC.B "OF A VAN AS THE NEIGHBOURS HEARD NOTHING.           "
 DC.B "THE POLICE SAID THERE IS PROBABLY NO CHANCE OF GETTING IT BACK. "
 DC.B "         I HOPE THEY GET CAUGHT, THE BIKE HAS BEEN DATA-TAGGED WHICH MEANS "
 DC.B "THAT MOST PARTS OF THE BIKE ARE IDENTIFIABLE EVEN IF IT IS SPLIT INTO "
 DC.B "BITS TO SELL AS PARTS.                               "
 DC.B "      NOT MANY DEMOS FOR THE ST OR FALCON COMING OUT THESE DAYS.    "
 DC.B "  I HAVE A PENTIUM PC AS WELL AS MY STE AND FALCON, THERE ARE SOME EXCELLENT "
 DC.B "DEMOS ON THE PC.    THE SPEED OF THE 3D ROUTINES ARE AMAZING.  "
 DC.B "                        "
 dc.b "THE DEMOS ON THIS DISC ARE QUITE OLD AND SOME MAY NOT WORK ON STFM OR STE WITH "
 DC.B "LESS THAN 1 MEG, THIS IS BECAUSE I CANNOT TEST THE DEMOS AS I DO NOT "
 DC.B "OWN AN STFM ANY MORE AND MY STE HAS 4 MEG OF MEMORY.               "
 DC.B "                       "
 DC.B "GREETS TO    DEL,    DR SYNE,    GEORGE (BART)     AND     "
 DC.B "MUG UK (CHUBBY BROWN OF PROFANITY ON PC).           "
 dc.b "CREDITS:   CODING AND ART BY [\], "
 DC.B "MUSIC (25KHZ STE, 12KHZ STFM) RIPPED FROM AMIGA.          "
 DC.B "                                                     "
 dc.b $ff
	even

font		dcb.b	31*4,0
		dc.b	0,0
		incbin	1plane.fnt
		even


old_wave_pointer	dc.l	clear_waves1
			dc.l	clear_waves2

wave_pointer	dc.l	waves
waves		incbin	sine1.dat
waves_end	incbin	sine1.dat

	even
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,00,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,00,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,48,49,50,00,00,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z  {  |  }  ~
 dc.b	22,23,24,25,26,44,41,45,00

	even


;scroller rasters follow
srast_pos	dc.l	srast
srast		dcb.w	29,0
		dc.w	0

scroller_colours
		dc.w	$800,$100,$900,$200,$a00,$300,$b00,$400
		dc.w	$c00,$500,$d00,$600,$e00,$700,$f00,$f80
		dc.w	$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0
		dc.w	$f50,$fd0,$f60,$fe0,$f70,$ff0,$7f0,$ef0
		dc.w	$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0
		dc.w	$2f0,$9f0,$1f8,$8f1,$0f9,$0f2,$0fa,$0f3
		dc.w	$0fb,$0f4,$0fc,$0f5,$0fd,$0f6,$0fe,$0f7
		dc.w	$0ff,$07f,$0ef,$06f,$0df,$05f,$0cf,$04f
		dc.w	$0bf,$03f,$0af,$02f,$09f,$01f,$08f,$00f
		dc.w	$80f,$10f,$90f,$20f,$a0f,$30f,$b0f,$40f
		dc.w	$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f,$f07
		dc.w	$f0e,$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03
		dc.w	$f0a,$f02,$f09,$f01,$f08,$f00,$f88,$f11
		dc.w	$f99,$f22,$faa,$f33,$fbb,$f43,$fca,$f52
		dc.w	$fd9,$f61,$fe8,$770,$ee0,$660,$dd0,$550
		dc.w	$cc0,$440,$bb0,$330,$aa0,$220,$990,$110

;28 colour wrap over tail
		dc.w	$800,$100,$900,$200,$a00,$300,$b00,$400
		dc.w	$c00,$500,$d00,$600,$e00,$700,$f00,$f80
		dc.w	$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0
		dc.w	$f50,$fd0,$f60,$fe0


stolen		incbin	"stolen.pi1"
cbr400		incbin	"cbr400.pi1"

white		dc.w	$000,$777,$777,$777,$777,$777,$777,$777
		dc.w	$777,$777,$777,$777,$777,$777,$777,$777


	ifeq	DOWNLOAD
	SECTION BSS
	endc

bssstart
wave_number	ds.w	1
old_timerb	ds.l	1
store		ds.l	5
oldkbd		ds.l	1
oldvbl		ds.l	1
stack_save	ds.l	1
old_base	ds.l	1
present_base	ds.l	1
last_base	ds.l	1
screen_1	ds.l	1
screen_2	ds.l	1
scroll_rout	ds.l	1

scroll_number	ds.w	1
key		ds.w	1
ste_flag	ds.w	1
hertz_delay	ds.w	1
hertz_toggle	ds.w	1
hertz_colour	ds.w	1
flash_counter	ds.w	1
flash_colour	ds.w	1
flash_timer	ds.w	1
screen_number	ds.w	1
scrcoloff	ds.w	1
vsyncflag	ds.w	1
byte_eor	ds.w	1
char_offset	ds.w	1
old_palette	ds.w	16
clear_waves1	ds.w	40
clear_waves2	ds.w	40
old_484		ds.w	1
black		ds.b	32
old_rez		ds.b	1
		even

		ds.b	256		;workspace so screen in on 256 bytes boundry
screen		ds.b	32000		;two screens
		ds.b	32000
eobss

	ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	endc
