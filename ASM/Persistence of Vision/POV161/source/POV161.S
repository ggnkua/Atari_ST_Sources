*************************************************************************
*				P.O.V. 115/161				*
*				--------------				*
*									*
* Written by:	MAC SYS DATA						*
*									*
* Music from:	KIDNEY BEAN DEMO					*
*									*
* Grafix by:	OZ							*
*									*
*************************************************************************
;
; If you use this code then please give me credit.
;
; Mac Sys Data
; 2 Southbourne Ave,
; Poulton-Le-Fylde
; Lancs.,
; FY6 8AW
; ENGLAND
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; This menu uses approx 50% of CPU time but uses only 1 screen.
; If you wish to add loads more things then make it screen flip yourself!
;

* EQUATES AND BITS............
*
* At P.O.V. we use a program called AUTORUN which P_EXECs the program
* from a seperate program in the AUTO folder (after the menu).
* We use AUTORUN because it allows us to use our own GEM start and it
* ensures ALL 512K demos run in 512K and don't need not 1 meg.
*
* If you have a copy of AUTORUN and use it then set 'AUTORUN4' to YES
*
* If you want to P_EXEC the program from this menu then set AUTORUN4 to NO
*
*
*
YES=1
NO=0
yes=1
no=0

AUTORUN4=no	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here


******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
DOWNLOAD	equ	yes

	ifne	DOWNLOAD
	include	transmit.s
	org	$20000

Code_Start
Exec_Addr
	ENDC
***********************************************************************


	ifeq	DOWNLOAD
***************************
	SECTION TEXT
***************************
	endc


*~~~~~~~~~~~~~~~~~~~~~~~ HERE GOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
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
start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		ENDC

		bsr	clear_bss
		bsr	get_rez
	cmp.w	#2,d0
	beq	mono

		ifeq	DOWNLOAD
		bsr	set_super
		endc

		move.b	#$12,$fffffc02.w
		bsr	save_pal
		bsr	get_base
		bsr	calc_screen
		bsr	black_out
		move.l	screen_base,a0
		bsr	set_low_rez
		bsr	shift_logo
		bsr	shift_bobs
		move.b	$484.w,old484
		clr.b	$484.w


	bsr	intro		;rise POV out of sea, etc


		jsr	tune		;initalize tune

;set up distance between bobs
		move.w	#128,d0		;distance between bobs
		move.l	present_table,a1
		move.l	a1,bob_v_pos
		add.w	d0,a1
		move.l	a1,bob_o_pos
		add.w	d0,a1
		move.l	a1,bob_p_pos

		bsr	show_pic
		bsr	print_lower_border_grafic
		movem.l	logo+2,d0-d7
		movem.l	d0-d7,border_pal

		bsr	set_for_border
		bsr	set_palette
		bsr	flush

main_loop	bsr	vsync
	bsr	vu
;	move.w	#$123,$ffff8240.w
		bsr	bobs
;	move.w	#$004,$ffff8240.w
		bsr	rippler
;	move.w	#$600,$ffff8240.w
		bsr	scroll
;	move.w	pic+2,$ffff8240.w

		move.b	$fffffc02.w,d0

		cmp.b	#01,d0		;escape
		beq.s	exit

		cmp.b	#$b,d0		;0 key
		beq.s	zero

		cmp.b	#$70,d0		;0 keypad
		beq.s	zero

		cmp.b	#$53,d0
		beq	do_reset

		lea	key_codes,a0
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

exit		bsr	isr_off

		tst.w	hertz_switch
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50		move.l	old_base,a0
		bsr	set_org_rez
		bsr	restore_pal
		move.b	#8,$fffffc02.w
		move.b	old484,$484.w
	ifeq	DOWNLOAD
		bsr	user_mode
	endc

		ifeq	AUTORUN4
		bra	exec
		endc

		clr.w	-(sp)
		trap	#1


zero		tst.w	zero_counter
		bne	main_loop 
		eor.w	#$001,border_pal
		eor.w	#$ffff,hertz_switch
		move.w	#10,zero_counter
		bra	main_loop

do_reset	move.l	4.w,a0
		jmp	(a0)

***************
* Subroutines *
***************

vu	lea	$ffff8800.w,a1
	move.b	#8,(a1)
	move.b	(a1),d0
	and.w	#$f,d0
	lsl.w	#5,d0
	lea	vu_colours,a0
	add.w	d0,a0
	move.l	a0,vu_colour_pos

	move.b	#9,(a1)
	move.b	(a1),d0
	and.w	#$f,d0
	lsl.w	#5,d0
	lea	vu_colours2,a0
	add.w	d0,a0
	move.l	a0,vu_colour_pos2

	moveq	#0,d0
	move.b	#$a,(a1)
	move.b	(a1),d0
	and.w	#$f,d0
	lsl.w	#5,d0
	lea	vu_colours3,a0
	add.w	d0,a0
	move.l	a0,vu_colour_pos3

	rts











RIPPLER_WIDTH	equ	8
RIPPLER_DEPTH	equ	48

rippler		move.l	ripple_table_pos,a6
		cmp.l	#reset_ripple_flag,a6
		blt.s	.do_rout
		move.l	#ripple_table,ripple_table_pos
.do_rout	lea	ripple_data,a4
		move.l	screen_base,a5
		add.w	#204*160,a5
		move.w	#RIPPLER_DEPTH-1,d7
.loop		move.w	d7,-(sp)
		move.b	(a6)+,d0
		move.b	(a6)+,d1
		move.l	a5,a1
		move.l	a4,a0
		and.l	#$ff,d0
		and.l	#$ff,d1
		lsl.w	#3,d0		;word offset *8
		mulu	#RIPPLER_WIDTH*4*RIPPLER_DEPTH,d1	;ripple number
		add.l	d1,a0
		add.w	d0,a1
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		add.w	#RIPPLER_WIDTH*4,a4
		lea	160(a5),a5
		move.w	(sp)+,d7
		dbf	d7,.loop
		addq.l	#2,ripple_table_pos
		rts


scroll		move.l	screen_base,a1		;single plane coloured with rasters
		lea	160(a1),a1
		lea	font_offsets,a2
		lea	font,a3
		move.l	scroll_pointer,a4
		move.l	a4,a5
		moveq	#40,d5
		move.w	char_offset,d6
		moveq	#0,d4
next_char	move.b	(a5),d7		;get a letter
		sub.b	#32,d7		;rid of ASCII
		ext.w	d7
		moveq	#0,d0
		move.l	a3,a0
		move.b	(a2,d7),d0
		mulu	#124,d0	;char depth * 4 *4
		add.w	d0,a0
		move.w	d6,d0
		mulu	#31,d0		;character depth * 4 (31*4)
		add.w	d0,a0
.column
OFF	set	0
		REPT	31
		move.b	(a0)+,OFF(a1)
OFF		set	OFF+160
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
		bne	.column
		addq.w	#1,a5		;scroll pointer
		tst.b	(a5)		;is end of text?
		bpl	next_char	;NO!
		lea	scroll_text,a5	;do reset scrolline
		bra	next_char
.finish		addq.w	#1,char_offset
		and.w	#3,char_offset
		bne.s	.end
		addq.w	#1,a4
		tst.b	(a4)
		bpl.s	.end
		lea	scroll_text,a4
.end		move.l	a4,scroll_pointer
		rts



bobs		move.w	last_p_pos,d0
		bsr	return_bob
		move.w	last_o_pos,d0
		bsr	return_bob
		move.w	last_v_pos,d0
		bsr	return_bob

		move.l	#bob_v_pos,a6
		lea	bob_shifts+(16*16*2),a1
		bsr.s	do_bobs
		move.l	#bob_o_pos,a6
		lea	bob_shifts+(16*16),a1
		bsr.s	do_bobs
		move.l	#bob_p_pos,a6
		lea	bob_shifts,a1

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
		and.w	#15,d2
		mulu	#16*6*16,d2
		add.w	d1,d0
		move.w	d0,4(a6)
		move.l	screen_base,a0
		add.w	d0,a0
		add.w	d2,a1
		lea	16*3*16(a1),a2
		REPT	16
		move.l	(a0),d0
		move.l	(a1)+,d1
		move.l	(a2)+,d2
		and.l	d0,d2
		or.l	d1,d2
		move.l	d2,(a0)
		move.l	4(a0),d0
		move.l	(a1)+,d1
		move.l	(a2)+,d2
		and.l	d0,d2
		or.l	d1,d2
		move.l	d2,4(a0)
		move.l	8(a0),d0
		move.l	(a1)+,d1
		move.l	(a2)+,d2
		and.l	d0,d2
		or.l	d1,d2
		move.l	d2,8(a0)
		move.l	12(a0),d0
		move.l	(a1)+,d1
		move.l	(a2)+,d2
		and.l	d0,d2
		or.l	d1,d2
		move.l	d2,12(a0)
		lea	160(a0),a0
		ENDR
		rts

return_bob	move.l	screen_base,a1
		add.w	d0,a1
		lea	pic+34,a0
		add.w	d0,a0
		REPT	16
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		move.l	8(a0),8(a1)
		move.l	12(a0),12(a1)
		lea	160(a0),a0
		lea	160(a1),a1
		ENDR
		rts


shift_logo	lea	ripple_data,a1
		move.w	#16-1,d1
.loop2		lea	logo+34,a0
		move.w	#RIPPLER_DEPTH-1,d0
OFF		set	0
.loop		REPT	RIPPLER_WIDTH
		move.l	OFF(a0),(a1)+
OFF		set	OFF+8
		ENDR
		lea	160(a0),a0
		dbf	d0,.loop

		lea	logo+34,a0
		move.w	#RIPPLER_DEPTH-1,d2
		sub.w	d0,d0		;clear carry flag before shifting
OFF		set	0
.scroll		REPT	RIPPLER_WIDTH
		roxr.w	OFF(a0)
OFF		set	OFF+8
		ENDR

OFF		set	2
		REPT	RIPPLER_WIDTH
		roxr.w	OFF(a0)
OFF		set	OFF+8
		ENDR

		lea	160(a0),a0
		dbf	d2,.scroll
		dbf	d1,.loop2
		rts



shift_bobs	;use space in LOGO.PI1 to pre-shift bobs
		lea	bob_grafix,a0
		lea	logo+34+(160*100),a6
		move.l	a6,a1
		move.w	#(16*6)-1,d0
.loop		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		lea	160(a1),a1
		dbf	d0,.loop

		lea	bob_shifts,a1
		move.w	#16-1,d7
shift		move.l	a6,a0
		addq.w	#8,a0
		move.w	#(16*6)-1,d0
.s		move.l	(a0),(a1)+
		move.l	4(a0),(a1)+
		move.l	8(a0),(a1)+
		move.l	12(a0),(a1)+
		lea	160(a0),a0
		dbf	d0,.s

		moveq.l	#0,d6
		move.w	#4-1,d5
.loop		move.l	a6,a0
		move.w	#(16*6)-1,d0
.sh2		roxr.w	0(a0,d6.w)
		roxr.w	8(a0,d6.w)
		roxr.w	16(a0,d6.w)
		lea	160(a0),a0
		sub.w	d4,d4
		dbf	d0,.sh2
		addq.w	#2,d6
		dbf	d5,.loop
		dbf	d7,shift
		rts



print_lower_border_grafic
		lea	logo+34+(50*160),a0
		move.l	screen_base,a1
		lea	160*204(a1),a1
		move.w	#38-1,d0
.loop		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,(a1)
		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,32(a1)
		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,64(a1)
		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,96(a1)
		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,128(a1)	;160 bytes
		lea	160(a1),a1
		dbf	d0,.loop
		rts




wait_for_drive	move.w	$ffff8604.w,d0
		btst	#7,d0
		bne.s	wait_for_drive
		rts

vsync		move.w	#$ffff,vsync_flag
.vs		tst.w	vsync_flag
		bne.s	.vs
		rts

flush		btst.b	#0,$fffffc00.w	;flush keyboard
		beq.s	flush2
		move.b	$fffffc02.w,d0
		bra.s	flush
flush2		rts

set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		rts

user_mode	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

save_pal	lea	old_pal,a1
		lea	$ffff8240.w,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

restore_pal	lea	old_pal,a0
		bra.s	set_p

set_palette	lea	pic+2,a0
set_p		lea	$ffff8240.w,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

get_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base
		rts

get_rez		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,org_rez
		rts

calc_screen	move.l	#screen,d0
		clr.b	d0
		move.l	d0,screen_base
		rts

set_org_rez	move.w	org_rez,-(sp)
		bra.s	set_rez

set_low_rez	clr.w	-(sp)
set_rez		move.l	a0,-(sp)
		move.l	a0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

show_pic	bsr.s	v_sync
		move.l	screen_base,a1
		lea	pic+34,a0
		move.w	#32000/4-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop
		rts


v_sync		movem.l	d0-d3/a0-a3,-(sp)
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		movem.l	(sp)+,d0-d3/a0-a3
		rts

black_out	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts


clear_bss	lea	bss_start,a0
.loop		clr.l	(a0)+
		cmp.l	#bss_end,a0
		blt.s	.loop
		rts




set_for_border	;set up then start border code
		ori.w	#$700,sr
		move.l	$70.w,old70
		move.l	$120.w,old120
		move.b	$fffffa07.w,olda07
		move.b	$fffffa09.w,olda09
		move.b	$fffffa1b.w,olda1b
		move.b	$fffffa21.w,olda21

		move.l	#new_70,$70.w
		move.l	#new_120,$120.w

		move.b	#1,$fffffa07.w
		bset	#0,$fffffa13.w
		clr.b	$fffffa09.w
		bclr	#3,$fffffa17.w		;auto ISR enable at RTE
		clr.b	$fffffa1b.w		;di timer B
		clr.b	$fffffa21.w		;clr timer B data
		move.w	#$2300,sr
		rts


isr_off		bsr	vsync
		move.w	#$2700,sr
		move.l	old120,$120.w
		move.l	old70,$70.w
		move.b	olda07,$fffffa07.w
		move.b	olda09,$fffffa09.w
		move.b	olda1b,$fffffa1b.w
		move.b	olda21,$fffffa21.w
		move.w	#$2300,sr

endmusic	moveq.l	#0,d0
		jsr	tune
		rts



*********
* ISRs  *
*********
new_70	clr.b	$fffffa1b.w
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	#new_120,$120.W
	jsr	tune+8
	clr.w	vsync_flag

	move.w	#16,raster_counter
	move.w	#16,vu_count2
	move.w	#16,vu_count3
	move.l	#scroll_colours,scroll_colour_pos
	move.l	#$00000110,col+2

	tst.w	zero_counter
	bne.s	dec_hertz
	movem.l	(sp)+,d0-d7/a0-a6

	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

dec_hertz
	subq.w	#1,zero_counter
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

new_120	clr.b	$fffffa1b.w
col	move.l	#$00000000,$ffff8240.w

	subq.w	#1,raster_counter
	tst.w	raster_counter
	beq.s	.set

	move.l	a0,-(sp)
	move.l	scroll_colour_pos,a0
	move.w	(a0)+,col+4
	move.l	a0,scroll_colour_pos

	move.l	vu_colour_pos,a0
	move.w	(a0)+,col+2
	move.l	a0,vu_colour_pos

	move.l	(sp)+,a0
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte
.set	move.l	pic+2,$ffff8240.w
	clr.l	col+2
	clr.b	$fffffa1b.w
	move.l	#vu_2,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

vu_2
col2	move.w	#$0000,$ffff8240.w
	sub.w	#1,vu_count2
	tst.w	vu_count2
	beq.s	.set
	move.l	a0,-(sp)
	move.l	vu_colour_pos2,a0
	move.w	(a0)+,col2+2
	move.l	a0,vu_colour_pos2
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte
.set	clr.w	col2+2
	move.l	#vu_3,$120.w
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

vu_3
col3	move.w	#$0000,$ffff8240.w
	sub.w	#1,vu_count3
	tst.w	vu_count3
	beq.s	.set
	move.l	a0,-(sp)
	move.l	vu_colour_pos3,a0
	move.w	(a0)+,col3+2
	move.l	a0,vu_colour_pos3
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte
.set	move.w	pic+2,$ffff8240.w
	clr.w	col3+2
	clr.b	$fffffa1b.w
	move.b	#199-31-31-31,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#border,$120.w
	rte


border	clr.b	$fffffa1b.w
	move.w	d0,-(sp)
	REPT	60
	nop
	ENDR
	moveq	#0,d0
.loop	cmp.b	$ffff8209.w,d0
	bne.s	.loop

	clr.b	$ffff820a.w	;60 hertz
	REPT	22
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz
	move.w	border_pal,$ffff8240.w
	move.w	(sp)+,d0
	move.l	border_pal+2,$ffff8240+2.w
	move.l	border_pal+6,$ffff8240+6.w
	move.l	border_pal+10,$ffff8240+10.w
	move.l	border_pal+14,$ffff8240+14.w
	move.l	border_pal+18,$ffff8240+18.w
	move.l	border_pal+22,$ffff8240+22.w
	move.l	border_pal+26,$ffff8240+26.w
	rte




mono	pea	mono_message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
.stop	bra.s	.stop



intro
;************************************************************************
;*                            UNKNOWN                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 29/09/90 13:53                     *
;*      From: AUTOMATION disc 289                                       *
;* Include files:-                                                      *
;*                 AUTO289.IMG into TUNE                                *
;************************************************************************

;****************************************************************
; There is only one tune in this code....
; 0=chip sound off
; 1=Automation 289

	moveq	#1,D0
	BSR	intro_tune
	move.l	#intro_tune+8,$4da.w		;use VBL to play tune

	bsr	black_out

	bsr	clear_screen
	bsr	set_rasters

no_fin	cmp.w	#6,ss+2		;wait for raster to be started (but not finished)
	bne.s	no_fin

****************************
******** MAIN LOOP *********
****************************

wait	bsr	vsync
	bsr	sea_ripple
	bsr.s	do_routines
	bsr	tst_key
	tst.l	d0
	bne.s	.getoutahere
	tst.w	valid_exit
	beq.s	wait

.no	bsr	vsync
	bsr	sea_ripple
	subq.w	#1,intro_countdown
	tst.w	intro_countdown
	beq.s	.getoutahere
	bsr	tst_key
	tst.l	d0
	beq.s	.no
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

.getoutahere
	bsr	intro_isr_off

	clr.l	$4da.w
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	bsr	black_out
	rts


*******************
* CUSTOM ROUTINES *
*******************
do_routines
	moveq	#0,d0
	move.w	routine_increment,d0
	lsl.w	#2,d0
	lea	routine_table,a0
	move.l	0(a0,d0.w),a0
	jmp	(a0)

	
pov_sea	cmp.w	#60,logo_offset+2
	blt.s	.do
	addq.w	#1,routine_increment
	bra.s	do_routines

.do	move.l	screen_base,a0
	add.w	#168*160+64,a0
	add.w	logo_offset,a0
	move.w	logo_offset+2,d0
	sub.w	#160,logo_offset
	addq.w	#1,logo_offset+2
	lea	intro_logo,a1
OFF	set	0
.loop	REPT	5
	move.l	OFF(a1),OFF(a0)
	move.l	OFF+4(a1),OFF+4(a0)
OFF	set	OFF+8
	ENDR
	lea	40(a1),a1
	lea	160(a0),a0
	dbf	d0,.loop
	rts

pov_rise
	move.w	logo_pos,d0
	cmp.w	#64,d0		;64 bytes across screen and none down
	bne.s	.do_it
	addq.w	#1,routine_increment
	rts
.do_it	move.l	screen_base,a0
	add.w	d0,a0
	lea	intro_logo,a1
	move.w	#61-1,d0
OFF	set	0
.loop	REPT	5
	move.l	OFF(a1),OFF(a0)
	move.l	OFF+4(a1),OFF+4(a0)
OFF	set	OFF+8
	ENDR
	lea	40(a1),a1
	lea	160(a0),a0
	dbf	d0,.loop
	sub.w	#160,logo_pos
	rts


init_demo_sea
	move.w	#160,logo_offset
	move.w	#1,logo_offset+2		;length of logo
	addq.w	#1,routine_increment
	bra	do_routines

demo_sea		;rise word DEMO out of sea......
	cmp.w	#17,logo_offset+2	;DEMO is 17 lines deep
	blt.s	.do
	addq.w	#1,routine_increment
	bra	do_routines
.do	move.l	screen_base,a0
	lea	168*160+56(a0),a0
	add.w	logo_offset,a0
	move.w	logo_offset+2,d0
	sub.w	#160,logo_offset
	addq.w	#1,logo_offset+2
	lea	demo,a1
OFF	set	0
.loop	REPT	6
	move.l	OFF(a1),OFF(a0)
	move.l	OFF+4(a1),OFF+4(a0)
OFF	set OFF+8
	ENDR
	lea	6*8(a1),a1
	lea	160(a0),a0
	dbf	d0,.loop
	rts

init_demo_rise
	move.w	#153*160+56,logo_pos
	addq.w	#1,routine_increment
	bra	do_routines

demo_rise
	move.w	logo_pos,d0
	cmp.w	#56+(160*80),d0	;line on screen to stop scrolling up + across screen offset
	bne.s	.do_it
	addq.w	#1,routine_increment
	rts
.do_it	move.l	screen_base,a0
	add.w	d0,a0
	lea	demo,a1
OFF	set 0
	move.w	#18-1,d0
.loop
	REPT	6
	move.l	OFF(a1),OFF(a0)
	move.l	OFF+4(a1),OFF+4(a0)
OFF	set OFF+8
	ENDR
	lea	6*8(a1),a1
	lea	160(a0),a0
	dbf	d0,.loop
	sub.w	#160,logo_pos
	rts

init_comp_sea
	move.w	#160,logo_offset
	move.w	#1,logo_offset+2		;length of logo
	addq.w	#1,routine_increment
	bra	do_routines

comp_sea		;rise word COMPILATION out of sea......
	cmp.w	#17,logo_offset+2	;DEMO is 17 lines deep
	blt.s	.do
	addq.w	#1,routine_increment
	bra	do_routines
.do	move.l	screen_base,a0
	lea	168*160+16(a0),a0
	add.w	logo_offset,a0
	move.w	logo_offset+2,d0
	sub.w	#160,logo_offset
	addq.w	#1,logo_offset+2
	lea	comp,a1
OFF	set	0
.loop	REPT	17
	move.l	OFF(a1),OFF(a0)
	move.l	OFF+4(a1),OFF+4(a0)
OFF	set OFF+8
	ENDR
	lea	17*8(a1),a1
	lea	160(a0),a0
	dbf	d0,.loop
	rts

init_comp_rise
	move.w	#153*160+16,logo_pos
	addq.w	#1,routine_increment
	bra	do_routines

comp_rise
	move.w	logo_pos,d0
	cmp.w	#16+(160*112),d0	;line on screen to stop scrolling up + across screen offset
	bne.s	.do_it
	addq.w	#1,routine_increment
	rts
.do_it	move.l	screen_base,a0
	add.w	d0,a0
	lea	comp,a1
OFF	set 0
	move.w	#18-1,d0
.loop
	REPT	17
	move.l	OFF(a1),OFF(a0)
	move.l	OFF+4(a1),OFF+4(a0)
OFF	set OFF+8
	ENDR
	lea	17*8(a1),a1
	lea	160(a0),a0
	dbf	d0,.loop
	sub.w	#160,logo_pos
	rts



init_L115_sea
	move.w	#160,logo_offset
	move.w	#1,logo_offset+2		;length of logo
	addq.w	#1,routine_increment
	bra	do_routines

L115_sea		;rise word  115  out of sea......
	cmp.w	#17,logo_offset+2	;DEMO is 17 lines deep
	blt.s	.do
	addq.w	#1,routine_increment
	bra	do_routines
.do	move.l	screen_base,a0
	lea	168*160+56(a0),a0
	add.w	logo_offset,a0
	move.w	logo_offset+2,d0
	sub.w	#160,logo_offset
	addq.w	#1,logo_offset+2
	lea	L115,a1
OFF	set	0
.loop	REPT	5
	move.l	OFF(a1),OFF(a0)
	move.l	OFF+4(a1),OFF+4(a0)
OFF	set OFF+8
	ENDR
	lea	5*8(a1),a1
	lea	160(a0),a0
	dbf	d0,.loop
	rts

init_L115_rise
	move.w	#153*160+56,logo_pos
	addq.w	#1,routine_increment
	bra	do_routines

L115_rise
	move.w	logo_pos,d0
	cmp.w	#56+(160*144),d0	;line on screen to stop scrolling up + across screen offset
	bne.s	.do_it
	addq.w	#1,routine_increment
	rts
.do_it	move.l	screen_base,a0
	add.w	d0,a0
	lea	L115,a1
OFF	set 0
	move.w	#18-1,d0
.loop
	REPT	5
	move.l	OFF(a1),OFF(a0)
	move.l	OFF+4(a1),OFF+4(a0)
OFF	set OFF+8
	ENDR
	lea	5*8(a1),a1
	lea	160(a0),a0
	dbf	d0,.loop
	sub.w	#160,logo_pos
	rts

set_valid_exit
	move.w	#-1,valid_exit
	addq.w	#1,routine_increment
	rts

null_routine	rts

routine_table
	dc.l	pov_sea
	dc.l	pov_rise
	dc.l	init_demo_sea
	dc.l	demo_sea
	dc.l	init_demo_rise
	dc.l	demo_rise
	dc.l	init_comp_sea
	dc.l	comp_sea
	dc.l	init_comp_rise
	dc.l	comp_rise
	dc.l	init_L115_sea
	dc.l	L115_sea
	dc.l	init_L115_rise
	dc.l	L115_rise
	dc.l	set_valid_exit
	dc.l	null_routine

routine_increment	dc.w	0

sea_ripple
	move.l	screen_base,a0
	lea	170*160(a0),a0
	move.l	a0,a2
	move.l	sea_wave_pointer,a1
	move.w	#30-1,d7		;ripple length
.loop
	movem.l	(a2),d0-d6/a3-a5
	movem.l	d0-d6/a3-a5,(a0)
	movem.l	40(a2),d0-d6/a3-a5
	movem.l	d0-d6/a3-a5,40(a0)
	movem.l	80(a2),d0-d6/a3-a5
	movem.l	d0-d6/a3-a5,80(a0)
	movem.l	120(a2),d0-d6/a3-a5
	movem.l	d0-d6/a3-a5,120(a0)

	move.w	(a1)+,d0
	bpl.s	.no_reset
	move.l	#sea_waves,sea_wave_pointer
	move.w	(a1)+,d0
.no_reset
	sub.w	d0,a2
	lea	160(a0),a0
	dbf	d7,.loop
	addq.l	#2,sea_wave_pointer
	rts


**************************
*	Interrupts       *
**************************
set_rasters
	move.w	#$2700,sr
	move.l	$120.w,old120
	move.l	$70.w,old70
	move.b	$fffffa07.w,olda07
	move.b	$fffffa09.w,olda09
	move.b	$fffffa13.w,olda13
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	#intro_120,$120.w
	move.l	#intro_70,$70.w
	bclr	#3,$fffffa17.w		set AEI mode
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	clr.l	$4da.w
	move.w	#$2300,sr
	rts

intro_120
	move.l	a0,-(sp)
	move.l	rasters_sea_position,a0
	move.w	(a0)+,$ffff8240.w
	move.l	a0,rasters_sea_position
	move.l	(sp)+,a0
	move.b	#0,$fffffa1b.w
ss	move.b	#20,$fffffa21.w		;1 line of each colour.....
	move.b	#8,$fffffa1b.w
	rte

intro_70
	move.l	#rasters_sea,rasters_sea_position
	clr.w	vsync_flag
	subq.w	#1,sea_toggle
	bpl.s	.do

	cmp.w	#1,ss+2
	beq.s	.do
	move.w	#4,sea_toggle
	subq.w	#1,ss+2
.do	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	logo_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	intro_tune+8
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#0,$fffffa1b.w	;timer B
	move.b	#170,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

sea_toggle	dc.w	5

intro_isr_off
	move.w	#$2700,sr
	move.l	old70,$70.w
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	old120,$120.w
	move.b	olda07,$fffffa07.w
	move.b	olda09,$fffffa09.w
	move.b	olda13,$fffffa13.w
	move.w	#$2300,sr
	rts






clear_screen
	move.l	screen_base,a0
	move.w	#32000/4-1,d0
	moveq	#0,d1
.loop	move.l	d1,(a0)+
	dbf	d0,.loop
	rts

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade	move.w	(a1)+,delay_time
	move.w	#7,d6
	move.l	a1,a2
next_value
	lea	$ffff8240.w,a0

	move.w	#16-1,d7
.loop	bsr.s	modify
	addq.w	#2,a0
	addq.w	#2,a1
	dbf	d7,.loop

	move.w	#4,d0
	bsr.s	vbl
	move.l	a2,a1
	dbf	d6,next_value
	rts

vbl	movem.l	d0-d3/d7/a0-a3,-(sp)
	move.l	d0,d7
.loop	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	dbf	d7,.loop
	movem.l	(sp)+,d0-d3/d7/a0-a3
	rts

PALREG:	EQU $FF8240


modify	move.w	(a0),d0		;get color value
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
 MDN1:	SUBQ #1,D4
 MOK1:	MOVE D0,D2
	MOVE D1,D3
	AND #$70,D2
	AND #$70,D3
	CMP D2,D3
	BEQ.S MOK2
	BMI.S MDN2
	ADD #$10,D4
	BRA.S MOK2
 MDN2:	SUB #$10,D4
 MOK2:	MOVE D0,D2
	MOVE D1,D3
	AND #$700,D2
	AND #$700,D3
	CMP D2,D3
	BEQ.S MOK3
	BMI.S MDN3
	ADD #$100,D4
	BRA.S MOK3
 MDN3:	SUB #$100,D4
 MOK3:	MOVE D4,(A0)
	RTS


delay_	move.w	delay_time,d7
.loop	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bmi.s	.yes
	dbf	d7,.loop
	rts
.yes	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

tst_key	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

	ifeq	DOWNLOAD
****************
 SECTION DATA
****************
	endc
olda13		dc.b	0
	even
delay_time	dc.w	5000


sea_depth	dc.w	0
rasters_sea_position	dc.l	rasters_sea
rasters_sea
	dc.w	$008,$001,$009,$003,$002,$003,$00b,$004
	dc.w	$006,$005,$007,$006,$00e,$007,$00f
	dc.w	$00f,$006,$00f,$00f,$006,$00f,$006,$00f
	dc.w	$00f,$00f,$00f,$00f,$00f,$00f,$006,$00f

valid_exit	dc.w	0
intro_countdown	dc.w	500
************************
****** LOGO BITS *******
************************
logo_pal	dc.w	$000,$002,$024,$135,$347,$750,$740,$730
		dc.w	$720,$710,$500,$200,$000,$000,$000,$777
intro_logo	incbin	logo.dat
	dcb.b	40,0
logo_pos	dc.w	110*160+64
logo_offset	dc.w	160
		dc.w	1

demo		incbin	demo.dat
	dcb.b	48,0
comp		incbin	comp.dat
	dcb.b	17*8,0
L115		incbin	115.dat
	dcb.b	5*8,0



*************************************
************ SEA EFFECT *************
*************************************
sea_wave_pointer	dc.l	sea_waves
sea_waves
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	320
	dc.w	320
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	0
	dc.w	0
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	640
	dc.w	640
	dc.w	640
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	160
	dc.w	160
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	320
	dc.w	320
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	480
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	0
	dc.w	0
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	160
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	320
	dc.w	-1

intro_tune	incbin	auto289.img

mono_message	dc.b	27,'E'
		dc.b	27,'Y',32+13,32+13,"I'm sorry this P.O.V. menu does not support MONOCHROME"
		dc.b	0

		even

vu_colour_pos	dc.l	vu_colours
vu_colours
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$000,$001,$002,$001,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$001,$001,$002,$001,$001,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$001,$002,$003,$002,$001,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$001,$002,$002,$003,$002,$002,$001,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$001,$002,$003,$004,$003,$002,$001,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$001,$002,$003,$003,$004,$003,$003,$002,$001,$000,$000,$000,0
	dc.w	$000,$000,$000,$001,$002,$003,$004,$005,$004,$003,$002,$001,$000,$000,$000,0
	dc.w	$000,$000,$001,$002,$003,$004,$004,$005,$004,$004,$003,$002,$001,$000,$000,0
	dc.w	$000,$000,$001,$002,$003,$004,$005,$006,$005,$004,$003,$002,$001,$000,$000,0
	dc.w	$000,$001,$002,$003,$004,$005,$005,$006,$005,$005,$004,$003,$002,$001,$000,0
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,0
	dc.w	$001,$002,$003,$004,$005,$006,$006,$007,$006,$006,$005,$004,$003,$002,$001,0
	dc.w	$001,$002,$003,$004,$005,$006,$007,$00f,$007,$006,$005,$004,$003,$002,$001,0


vu_colour_pos2	dc.l	vu_colours2
vu_colours2
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$000,$000,$011,$000,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$000,$000,$011,$000,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$000,$011,$022,$011,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$011,$011,$022,$011,$011,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$011,$022,$033,$022,$011,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$011,$022,$022,$033,$022,$022,$011,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$011,$022,$033,$044,$033,$022,$011,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$011,$022,$033,$033,$044,$033,$033,$022,$011,$000,$000,$000,0
	dc.w	$000,$000,$000,$011,$022,$033,$044,$055,$044,$033,$022,$011,$000,$000,$000,0
	dc.w	$000,$000,$011,$022,$033,$044,$044,$055,$044,$044,$033,$022,$011,$000,$000,0
	dc.w	$000,$000,$011,$022,$033,$044,$055,$066,$055,$044,$033,$022,$011,$000,$000,0
	dc.w	$000,$011,$022,$033,$044,$055,$055,$066,$055,$055,$044,$033,$022,$011,$000,0
	dc.w	$000,$011,$022,$033,$044,$055,$066,$077,$066,$055,$044,$033,$022,$011,$000,0
	dc.w	$011,$022,$033,$044,$055,$066,$066,$077,$066,$066,$055,$044,$033,$022,$011,0
	dc.w	$011,$022,$033,$044,$055,$066,$077,$0ff,$077,$066,$055,$044,$033,$022,$011,0

vu_colour_pos3	dc.l	vu_colours3
vu_colours3
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$000,$000,$101,$000,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$000,$000,$101,$000,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$000,$101,$202,$101,$000,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$101,$101,$202,$101,$101,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$000,$101,$202,$303,$202,$101,$000,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$101,$202,$202,$303,$202,$202,$101,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$000,$101,$202,$303,$404,$303,$202,$101,$000,$000,$000,$000,0
	dc.w	$000,$000,$000,$101,$202,$303,$303,$404,$303,$303,$202,$101,$000,$000,$000,0
	dc.w	$000,$000,$000,$101,$202,$303,$404,$505,$404,$303,$202,$101,$000,$000,$000,0
	dc.w	$000,$000,$101,$202,$303,$404,$404,$505,$404,$404,$303,$202,$101,$000,$000,0
	dc.w	$000,$000,$101,$202,$303,$404,$505,$606,$505,$404,$303,$202,$101,$000,$000,0
	dc.w	$000,$101,$202,$303,$404,$505,$505,$606,$505,$505,$404,$303,$202,$101,$000,0
	dc.w	$000,$101,$202,$303,$404,$505,$606,$707,$606,$505,$404,$303,$202,$101,$000,0
	dc.w	$101,$202,$303,$404,$505,$606,$606,$707,$606,$606,$505,$404,$303,$202,$101,0
	dc.w	$101,$202,$303,$404,$505,$606,$707,$f0f,$707,$606,$505,$404,$303,$202,$101,0


scroll_colour_pos	dc.l	scroll_colours
scroll_colours
	dc.w	$220,$330,$440,$550,$660,$770,$f70
	dc.w	$f60,$f50,$f40,$f30,$f20,$f10,$f00
border_pal
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000


scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "                    PERSISTENCE OF VISION PACKED DEMO DISC 161.    "
 dc.b "release date 19th dec 1997.      ALL CODE BY MAC SYS DATA WITH "
 dc.b "GRAFIX BY OZ AND MUSIC FROM "
 dc.b "KIDNEY BEAN DEMO (RIPPED BY MUG UK).          "
 dc.b "                                                          "
 dc.b "THE DEMOS ON THIS DISK ARE RATHER OLD BUT AT LEAST NOW YOU "
 DC.B "CAN SEE THEM ON A COMPILATION WITH OTHER MENUS AND INTROS.       "
 DC.B "I HAVE LOADS OF OTHER DEMOS ALREADY PACKED, MOSTLY ARE OLD AND "
 DC.B "HARDLY WORTH RELEASING. I WILL DELETE THE REALLY BAD ONES "
 DC.B "AND PUT THE REST ONTO A FUTURE DISC.            "
 DC.B "      IF YOU WISH TO CONTACT POV, YOU CAN E-MAIL ME AT "
 DC.B "     POV@FATAL-DESIGN.COM             "
 DC.B "RIGHT THAT IS ALL THERE IS.......        "
 DC.B "                                         "
 DC.B "                                         "
 DC.B "                                                          "
 dc.b "                                                          "
 dc.b "                                                          "
 dc.b $ff
	even


font		dcb.b	31*4,0
		incbin	font.fnt"
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,45,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,25,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,47,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z  {  |  }  ~
 dc.b	22,23,24,25,26,40,00,41,00
		even

tune		incbin	kidney6.thk

		even

pic		incbin	moon.PI1

logo		incbin	logo.pi1


ripple_table_pos	dc.l	init_ripple_table
init_ripple_table
	dcb.w	200,$0702
ripple_table
	incbin	sine1.dat
	incbin	sine1.dat
	incbin	sine2.dat
	incbin	sine3.dat
	incbin	sine5.dat
	incbin	sine3.dat
	incbin	sine7.dat
	incbin	sine8.dat
	incbin	sine9.dat
reset_ripple_flag
	incbin	sine1.dat

	even

end_of_table	dc.l	endbobs
present_table	dc.l	bob1

bob1	incbin	bob1.dat
	incbin	bob2.dat
	incbin	bob3.dat
	incbin	bob4.dat
endbobs

bob_grafix	incbin	pov.dat
	even
key_codes
	dc.b	0, $02		;keyboard 1
	dc.b	1, $03		;keyboard 2
	dc.b	2, $04		;keyboard 3
	dc.b	3, $05		;keyboard 4
	dc.b	4, $06		;keyboard 5
	dc.b	5, $07		;keyboard 6
	dc.b	6, $08		;keyboard 7
;	dc.b	7, $09		;keyboard 8

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
	dc.b	-1, -1
	even

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1		dc.b	"maddog.PRG",0
	even
exec2		dc.b	"t2intro.prg",0
	even
exec3		dc.b	"stax30.prg",0
	even
exec4		dc.b	"t_s_c_95.PRG",0
	even
exec5		dc.b	"elite.prg",0
	even
exec6		dc.b	"pe53.prg",0
	even
exec7		dc.b	"copier.pov",0
	even
exec8		dc.b	"copier.pov",0
	even



	ifeq	DOWNLOAD
****************************
	SECTION BSS
****************************
	endc
bss_start

raster_counter		ds.w	1
vu_count2		ds.w	1
vu_count3		ds.w	1
old_pal			ds.b	32
old_base		ds.l	1
org_rez			ds.w	1
screen_base		ds.l	1
stack_save		ds.l	1
vsync_flag		ds.w	1
old70			ds.l	1
old120			ds.l	1
old118			ds.l	1
olda07			ds.b	1
olda09			ds.b	1
olda1b			ds.b	1
olda21			ds.b	1
old484			ds.b	1
	even
hertz_switch		ds.w	1

char_offset		ds.w	1

bob_p_pos		ds.l	1
last_p_pos		ds.w	1
bob_o_pos		ds.l	1
last_o_pos		ds.w	1
bob_v_pos		ds.l	1
last_v_pos		ds.w	1

zero_counter		ds.w	1

black			ds.b	32


bob_shifts		ds.b	((16*16)*6)*16

ripple_data		ds.b	(RIPPLER_WIDTH*4*RIPPLER_DEPTH)*16
ripple_end


			ds.b	256
screen			ds.b	32000+(160*48)

bss_end


	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
