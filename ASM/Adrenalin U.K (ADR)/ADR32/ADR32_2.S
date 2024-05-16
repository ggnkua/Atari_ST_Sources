*************************************************************************
*			ADRENALIN MENU FOR 1 YEAR OLD			*
*			-----------------------------			*
*									*
*									*
*									*
* Written by:	SPACEMAN SPIFF						*
*									*
*									*
* Music from:	Excellence in art demo					*
*									*
*									*
* Art by:	Mac Sys Data of P.O.V. (digitized on Amiga A500)	*
*									*
* Version:	2 (AUTORUN4 EMULATION)					*
*									*
*									*
*									*
*************************************************************************


YES=1
yes=YES
NO=0
no=NO


AUTORUN4_EMU=NO		;YES to use POV AUTORUN 4 EMULATION
			;(No longer needs AUTORUN 4 unless for GFA shit)
			;NO to run program from here

FINAL=no	;YES to remove escape to assembler code
		;NO to keep it on










	opt	o+,w-
BOB_OFFSET	equ	40	;alters spacing between each bob
			;must be in steps of 4
			; eg 4,8,12,16,20,24,28,32,36,40,etc...


MulNops	MACRO
	REPT	\1
	nop
	ENDR
	ENDM

TBDR		equ	$fffffa21
TBCR		equ	$fffffa1b

begin		bra	start
		ds.l	100
ustack		ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec
		ifne	AUTORUN4_EMU
		pea	get_type
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp
		cmp.w	#"$$",file_type
		beq.s	.exit
		endc

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
blank		dc.l	0

		ifne	AUTORUN4_EMU
get_type	move.w	$200.w,file_type
		rts
file_type	dc.w	0
		endc

*******************************************************************
start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7

		bsr	clear_bss
		bsr	set_super
		move.b	#$12,$fffffc02.w
		bsr	get_screen_base
		bsr	get_old_palette
		bsr	get_original_rez
		bsr	calc_screen
		bsr	do_sequence
		bsr	black_out
		bsr	flush
		move.b	$484.w,old484
		clr.b	$484.w
		bsr	setup_bobs


* Excellence in art music
		moveq	#1,d0
		jsr	tune

		bsr	bobs	;creates old bob pos for flip scrn
		bsr	show_pic
		bsr	set_palette
		bsr	set_for_border
		bsr	flush
main_loop	bsr	flip_screen
;		move.w	#$123,$ffff8240.w
		bsr	scroll
;		move.w	#$300,$ffff8240.w
		bsr	return_bobs
;		move.w	#$040,$ffff8240.w
		bsr	bobs
;		move.w	pic+2,$ffff8240.w

		move.b	$fffffc02.w,d0

		ifeq	FINAL
		cmp.b	#01,d0		;escape
		beq	exit
		ENDC

		cmp.b	#$b,d0		;0 key
		beq.s	zero

		cmp.b	#$70,d0		;0 keypad
		beq.s	zero

		cmp.b	#$53,d0
		beq	do_reset

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

		bsr	isr_off

		tst.w	hertz_switch
		beq.s	hz50
		eor.b	#2,$ffff820a.w
hz50		move.b	#8,$fffffc02.w
		move.b	old484,$484.w
		bsr	restore_pal
		bsr	user_mode
		move.l	old_base,a0
		bsr	set_org_rez
		bra	exec

zero		tst.w	zero_key_delay
		bne	main_loop
		eor.w	#$4,font_pal
		eor.w	#$ffff,hertz_switch
		move.w	#10,zero_key_delay
		bra	main_loop

do_reset	move.l	4,a0
		jmp	(a0)

		ifeq	FINAL
exit		bsr	isr_off
		bsr	flush
		move.l	old_base,a0
		bsr	set_med_rez
		bsr	restore_pal
		move.b	#8,$fffffc02.w
		move.b	old484,$484.w
		bsr	user_mode
		clr.w	-(sp)
		trap	#1
		endc

***************
* Subroutines *
***************
scroll		move.l	present_base,a2
		lea	((160*200)+(230-6))(a2),a2
		move.l	scroll_pointer,a4
		lea	font_offsets,a3		;font lookup table
		move.w	char_offset,d7
		moveq	#0,d2
		moveq	#51,d1
.loop		moveq	#0,d0
		move.b	(a4),d6
		bpl.s	.cont
		lea	scroll_text,a4
		bra.s	.loop
.cont		lea	font,a0
		sub.b	#32,d6		;rid of ASCII
		ext.w	d6
		moveq	#0,d0
		move.b	(a3,d6),d0	;find correct offset

		mulu	#(31*4*4),d0
		add.w	d0,a0
		move.w	d7,d0
		mulu	#(31*4),d0
		add.w	d0,a0
OFF	set	6
		REPT	31
		move.l	(a0)+,d0
		movep.l	d0,OFF(a2)
OFF	set	OFF+230
		ENDR
		addq.w	#1,d7
		and.w	#3,d7
		bne.s	.ok
		addq.w	#1,a4
		tst.b	(a4)
		bpl.s	.ok
		lea	scroll_text,a4
.ok		addq.w	#1,a2
		move.w	a2,d0
		and.w	#1,d0
		bne.s	.next
		addq.w	#6,a2
.next		dbf	d1,.loop
		move.l	scroll_pointer,a4
		addq.w	#1,d7
		and.w	#3,d7
		move.w	d7,char_offset
		bne.s	.end
		addq.w	#1,a4
		tst.b	(a4)
		bpl.s	.end
		lea	scroll_text,a4
.end		move.l	a4,scroll_pointer
		rts



do_sequence	bsr	v_sync
		movem.l	animate_pal,d0-d7	;animation of ADRENALIN
		movem.l	d0-d7,$ffff8240.w
		move.w	#40-1,d7
.init_wait	bsr	v_sync
		dbf	d7,.init_wait
		move.w	#11-1,d7
		lea	grafix,a0
.loop		bsr	v_sync
		bsr	v_sync
		bsr	v_sync
		bsr	v_sync
		bsr	.do_single
		dbf	d7,.loop
		move.w	#50-1,d7
.wait		bsr	v_sync
		dbf	d7,.wait
		move.w	#(30-11)-1,d7
.loop2		bsr	v_sync
		bsr	v_sync
		bsr	v_sync
		bsr	v_sync
		bsr	.do_single
		dbf	d7,.loop2
		rts

.do_single	move.l	present_base,a1
		lea	80*160(a1),a1
		move.w	#29-1,d0
.do		REPT	20
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		ENDR
		dbf	d0,.do
		rts


v_sync		move.l	a0,-(sp)
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	(sp)+,a0
		rts



vsync		move.w	#$ffff,vsync_flag
.vs		tst.w	vsync_flag
		bne.s	.vs
		rts


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


get_old_palette	movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal
		rts


set_old_palette	lea	old_palette,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

get_screen_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base
		rts

get_original_rez
		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez
		rts

shift_bobs	lea	logo,a1
		move.w	#16-1,d7
.shift_loop	lea	bob_pic+34,a0
		move.w	#(16*7)-1,d2
.loop		move.l	8(a0),(a1)+
		move.l	12(a0),(a1)+
		move.l	16(a0),(a1)+
		move.l	20(a0),(a1)+
		add.w	#160,a0
		dbf	d2,.loop

		lea	bob_pic+34,a0
		add.w	#8*8,a0
		move.w	#(16*7)-1,d2
.loop2		move.l	8(a0),(a1)+
		move.l	12(a0),(a1)+
		move.l	16(a0),(a1)+
		move.l	20(a0),(a1)+
		add.w	#160,a0
		dbf	d2,.loop2

		lea	bob_pic+34,a0
		move.w	#12*16-1,d0
.shift
off	set	0
		rept	20
		roxr	off(a0)
off	set	off+8
		endr

off	set	2
		rept	20
		roxr	off(a0)
off	set	off+8
		endr

off	set	4
		rept	20
		roxr	off(a0)
off	set	off+8
		endr

off	set	6
		rept	20
		roxr	off(a0)
off	set	off+8
		endr

		lea	160(a0),a0
		dbf	d0,.shift
		dbf	d7,.shift_loop
		rts

black_out	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts


flush		btst.b	#0,$fffffC00.w	;flush keyboard
		beq.s	flush2
		move.b	$fffffc02.w,d0
		bra.s	flush
flush2		rts

user_mode	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

restore_pal	lea	old_pal,a0
		bra.s	set_p

set_palette	lea	pic+2,a0
set_p		lea	$ffff8240.w,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

calc_screen	move.l	#screen,d0
		clr.b	d0
		move.l	d0,present_base
		move.l	d0,screen_base
		move.l	#49152,screen_toggle
		move.l	d0,a0
		bsr	set_low_rez
		rts

set_org_rez	move.w	original_rez,-(sp)
		bra.s	set_rez
set_med_rez	move.w	#1,-(sp)
		bra.s	set_rez
set_low_rez	clr.w	-(sp)
set_rez		move.l	a0,-(sp)
		move.l	a0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

show_pic	lea	pic+34,a0
		move.l	screen_base,a1
		move.l	a1,a2
		add.l	screen_toggle,a2
		move.w	#32000/4-1,d0
.loop		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.loop
		rts



set_for_border	move.w	#$2700,sr
		move.l	$70.w,old70
		move.l	$120.w,old120
		move.b	$fffffa07.w,olda07
		move.b	$fffffa09.w,olda09
 		move.b	$fffffa17.w,olda17
		move.b	TBCR.w,olda1b
		move.b	TBDR.w,olda21

		move.l	#new_vbl,$70.w
		move.l	#timerb,$120.w

		move.b	#1,$fffffa07.w
		clr.b	$fffffa09.w
		bclr	#0,$fffffa0f.w
		bset	#0,$fffffa13.w
		bclr	#3,$fffffa17.w	;auto isr ena
		move.w	#$2300,sr
		rts


isr_off		bsr	vsync
		jsr	tune+4
		move.w	#$2700,sr
		move.l	old120,$120.w
		move.l	old70,$70.w
		move.b	olda07,$fffffa07.w
		move.b	olda09,$fffffa09.w
		move.b	olda17,$fffffa17.w
		move.b	olda1b,TBCR.w
		move.b	olda21,TBDR.w
		move.w	#$2300,sr
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		rts



return_bobs	move.w	s_last_1,d0
		bsr	return_bob
		move.w	s_last_2,d0
		bsr	return_bob
		move.w	s_last_3,d0
		bsr	return_bob
		move.w	s_last_4,d0
		bsr	return_bob
		move.w	s_last_5,d0
		bsr	return_bob
		move.w	s_last_6,d0
		bsr	return_bob
		move.w	s_last_7,d0
		bsr	return_bob
		move.w	s_last_8,d0
		bsr	return_bob
		move.w	s_last_9,d0
	
return_bob	move.l	present_base,a1
		add.w	d0,a1
		lea	pic+34,a0
		add.w	d0,a0
line_offset	set	0
		REPT	16
		movem.l	line_offset(a0),d0/d1/d2/d3
		movem.l	d0/d1/d2/d3,line_offset(a1)
line_offset	set	line_offset+160
		ENDR
		rts

bobs		move.w	last_9,s_last_9
		move.w	last_8,s_last_8
		move.w	last_7,s_last_7
		move.w	last_6,s_last_6
		move.w	last_5,s_last_5
		move.w	last_4,s_last_4
		move.w	last_3,s_last_3
		move.w	last_2,s_last_2
		move.w	last_1,s_last_1

		move.l	present_base,a4
		lea	bob_9,a6	;N
		lea	logo+(16*16*4),a1
		bsr	do_bobs

		lea	bob_8,a6	;I
		lea	logo+(16*16*6),a1
		bsr	do_bobs

		lea	bob_7,a6	;L
		lea	logo+(16*16*5),a1
		bsr	do_bobs

		lea	bob_6,a6	;A
		lea	logo,a1
		bsr	do_bobs

		lea	bob_5,a6	;N
		lea	logo+(16*16*4),a1
		bsr	do_bobs

		lea	bob_4,a6	;E
		lea	logo+(16*16*3),a1
		bsr	do_bobs

		lea	bob_3,a6	;R
		lea	logo+(16*16*2),a1
		bsr	do_bobs

		lea	bob_2,a6	;D
		lea	logo+(16*16*1),a1
		bsr	do_bobs

		lea	bob_1,a6	;A
		lea	logo,a1


do_bobs		move.l	(a6),a0
		cmp.l	end_of_table,a0
		bne.s	.no_reset
		move.l	present_table,a0
.no_reset	moveq	#0,d0
		move.l	d0,d1
		move.l	d1,d2
		move.w	(a0)+,d0	;x
		move.w	(a0)+,d1	;y
		move.w	d0,d2
		move.l	a0,(a6)

		lsr.w	#1,d0
		and.w	#$1f8,d0

		add.w	d1,d0
		move.w	d0,4(a6)		;save pos of bob

		move.l	a4,a0
		add.w	d0,a0

		and.w	#15,d2
		mulu	#16*14*16,d2

		add.l	d2,a1
		lea	16*7*16(a1),a2		;mask position

line_off	set	0
		REPT	16
		move.l	line_off(a0),d0
		move.l	(a1)+,d1
		move.l	(a2)+,d2
		and.l	d0,d2
		or.l	d1,d2
		move.l	d2,line_off(a0)

		move.l	line_off+4(a0),d0
		move.l	(a1)+,d1
		move.l	(a2)+,d2
		and.l	d0,d2
		or.l	d1,d2
		move.l	d2,line_off+4(a0)

		move.l	line_off+8(a0),d0
		move.l	(a1)+,d1
		move.l	(a2)+,d2
		and.l	d0,d2
		or.l	d1,d2
		move.l	d2,line_off+8(a0)

		move.l	line_off+12(a0),d0
		move.l	(a1)+,d1
		move.l	(a2)+,d2
		and.l	d0,d2
		or.l	d1,d2
		move.l	d2,line_off+12(a0)
line_off	set	line_off+160
		ENDR
		rts


flip_screen	move.l	present_base,last_base
		bsr	vsync
		move.l	screen_base,d0
		eor.l	#49152,screen_toggle
		add.l	screen_toggle,d0
		move.l	d0,present_base
		lsr.l	#8,d0
		lea	$ffff8201.w,a0
		movep.w	d0,(a0)
		rts


clear_bss	lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
		lsr.w	#2,d0
.clear		clr.l	(a0)+
		sub.l	#1,d0
		bne.s	.clear
		rts


setup_bobs	bsr	shift_bobs
		move.w	#BOB_OFFSET,d0
		lea	bob_9,a0
		move.l	present_table,a1
		move.l	a1,(a0)
		add.w	d0,a1
		move.l	a1,-6(a0)
		add.w	d0,a1
		move.l	a1,-12(a0)
		add.w	d0,a1
		move.l	a1,-18(a0)
		add.w	d0,a1
		move.l	a1,-24(a0)
		add.w	d0,a1
		move.l	a1,-30(a0)
		add.w	d0,a1
		move.l	a1,-36(a0)
		add.w	d0,a1
		move.l	a1,-42(a0)
		add.w	d0,a1
		move.l	a1,-48(a0)
		rts




*********
* ISRs  *
*********
new_vbl		movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		jsr	tune+8
		clr.w	vsync_flag
		clr.b	TBCR.w
		move.l	#timerb,$120.w

		tst.w	zero_key_delay
		beq.s	not_z
		sub.w	#1,zero_key_delay
not_z		movem.l	(sp)+,d0-d7/a0-a6
		move.b	#199,TBDR.w
		move.b	#8,TBCR.w
		rte



timerb		move.w	#$2700,sr
		rept	50
		nop
		endr
		clr.b	$fffffa1b.w
		movem.l	d0/a0,-(sp)
		lea	$ffff8209.w,a0
		moveq	#0,d0
		move.b	(a0),d0
		sub.b	#$60,d0
		jmp	nops(pc,d0)
nops
		MulNops	97
		move.b	#0,$ffff820A.w
		move.b	#2,$ffff8260.w
		move.b	#0,$ffff8260.w
		move.b	#2,$ffff820A.w

		move.l	font_pal,$ffff8240.w	;scroller font colours
		move.l	font_pal+4,$ffff8244.w
		move.l	font_pal+8,$ffff8248.w
		move.l	font_pal+12,$ffff824c.w
		move.l	font_pal+16,$ffff8250.w
		move.l	font_pal+20,$ffff8254.w
		move.l	font_pal+24,$ffff8258.w
		move.l	font_pal+28,$ffff825c.w

		MulNops	83-48-16		;-48 for colour changes
		move.b	#0,$ffff820A.w
		move.b	#2,$ffff820A.w		;-16 for scroll pal MOVE.Ls
		MulNops	8
		move.b	#1,$ffff8260.w
		move.b	#0,$ffff8260.w
		MulNops	8
		moveq	#31-1,d0
.line		move.b	#2,$ffff8260.w
		move.b	#0,$ffff8260.w
		MulNops	87
		move.b	#0,$ffff820A.w
		move.b	#2,$ffff820A.w
		MulNops	8
		move.b	#1,$ffff8260.w
		move.b	#0,$ffff8260.w
		MulNops	6
		dbf	d0,.line
		MulNops	35
		movem.l	(sp)+,d0/a0
		rte


******************************
	SECTION DATA
******************************

font_pal	dc.w	$000,$222,$333,$444,$555,$666,$777,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$00


scroll_pointer	dc.l	scroll_text+7
scroll_text
 dc.b "                        "
 dc.b "ADRENALIN PRESENTS DISC 32.    "
 dc.b "MENU CODED BY SPACEMAN SPIFF,     GRAFIX BY ???,     "
 DC.B "MUSIC FROM EXCELLENCE IN ART DEMO RIPPED BY MUG UK.      "
 dc.b " yo boys, this is spaceman spiff on the keys with a quick "
 dc.b "message to all the people who said we were gonna disappear.... "
 dc.b "suck my fuckin dick - we are not dead, we are the best british "
 dc.b "compilation crew.     we may not have the best coders, artist or "
 dc.b "hackers but at least all our stuff works and was done by us unlike "
 dc.b "other british crews who release duff cracks time after time and use "
 dc.b "other peoples code all the time.              "
 DC.B "                                                       "
 dc.b $ff
	even
char_offset	dc.w	0
font		incbin	font.fnt

font_offsets
;           !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	50,51,52,53,54,55,56,57,58,59,60,61,62,63,00,33,34,35

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53

;        v  w  x  y  z  {  |  }  ~
 dc.b	54,55,56,57,58,29,00,30,00
	even



;*************************
tune	incbin	offbeat.eia
pic	incbin	pic.pi1
	even

end_of_table	dc.l	endbobs
present_table	dc.l	bob1

tables	dc.l	bob1
	dc.l	endbobs

bob1	incbin	bob2.dat
	incbin	bob3.dat
	incbin	bob4.dat
	incbin	bob5.dat
	incbin	bob6.dat
	incbin	bob7.dat
endbobs
	even

bob_pic		incbin	bobs.pi1
*******************************

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
exec1	dc.b	"crystal.ste",0
	even
exec2	dc.b	"groove.meg",0
	even
exec3	dc.b	"dba_mag6.meg",0
	even
exec4	dc.b	"imag_inv.meg",0
	even
exec5	dc.b	"dentro.am",0
	even
exec6	dc.b	"lynx.bbs",0
	even
exec7	dc.b	"tsc.94",0
	even
exec8	dc.b	"copier.pov",0
	even


logo		;use old space from animation for pre-shifted bobs
		;otherwise menu is 473000 bytes and would be 1 meg.

grafix		incbin	sequence.adr
animate_pal	dc.w	$000,$076,$074,$273,$370,$360,$350,$450
		dc.w	$000,$111,$222,$333,$444,$555,$666,$777


******************************
	SECTION BSS
******************************
bss_start
stack_save	ds.l	1
old_base	ds.l	1
present_base	ds.l	1
last_base	ds.l	1
screen_toggle	ds.l	1
screen_base	ds.l	1
old484		ds.w	1
vsync_flag	ds.w	1
old70		ds.l	1
old120		ds.l	1
olda07		ds.b	1
olda09		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
	even
original_rez	ds.w	1
old_palette	ds.w	16
black		ds.w	16
zero_key_delay	ds.w	1
hertz_switch	ds.w	1

bob_1	ds.l	1	;A
last_1	ds.w	1
bob_2	ds.l	1	;D
last_2	ds.w	1
bob_3	ds.l	1	;R
last_3	ds.w	1
bob_4	ds.l	1	;E
last_4	ds.w	1
bob_5	ds.l	1	;N
last_5	ds.w	1
bob_6	ds.l	1	;A
last_6	ds.w	1
bob_7	ds.l	1	;L
last_7	ds.w	1
bob_8	ds.l	1	;I
last_8	ds.w	1
bob_9	ds.l	1	;N
last_9	ds.w	1

s_last_1	ds.w	1	;last but 1 screen pos of bob for clearing
s_last_2	ds.w	1
s_last_3	ds.w	1
s_last_4	ds.w	1
s_last_5	ds.w	1
s_last_6	ds.w	1
s_last_7	ds.w	1
s_last_8	ds.w	1
s_last_9	ds.w	1

old_pal		ds.b	32
		ds.b	256
screen		ds.b	49152		;these can be reduced if mem if short
		ds.b	49152
bss_end