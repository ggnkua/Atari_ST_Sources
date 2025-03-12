*************************************************************************
*				ADRENALIN MENU				*
*				--------------				*
*									*
* Written by: 	MAC SYS DATA (Spaceman Spiff)				*
*									*
*									*
* Music by:	TAO (digi)						*
*									*
*									*
* Grafix by: 	Oz (Biofeedback)					*
*									*
*									*
* Date:		16/3/94							*
*									*
*			½ Persistence Of Vision 1994			*
*			     ½ Adrenalin UK 1994			*
*									*
*************************************************************************
	opt	o+,w-
yes=1
YES=yes
no=0
NO=no

AUTORUN4	equ	no
FINAL		equ	no


;***********************************************************************
		ifeq	AUTORUN4
begin		bra	start
		ds.l	100
ustack		ds.l	1

exec		pea	blank
		pea	blank
		pea	$200.w
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	reset_me(pc)
		move.w	#$26,-(sp)
		trap	#14
reset_me	move.l	4.w,-(sp)
		rts

blank		dc.l	0


start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		endc

		bsr	set_up
main_loop	move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync

		bsr	set_screen	;screen flip
;		move.w	#$123,$ffff8240.w
		bsr	text_printer
		bsr	scroll
		jsr	music+8
;		move.w	pic+2,$ffff8240.w

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

assem		move.w	#$2700,sr
		moveq	#0,d0
		jsr	music
		lea	storage,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa0f.w
		move.b	(a0)+,$fffffa11.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa1d.w
		move.b	(a0)+,$fffffa21.w
		lea	$ffff8800.w,a0
		move.b	#7,(a0)
		move.b	(a0),d1
		ori.b	#$3f,d1
		moveq.w	#$c,d0
.loop		move.b	d0,(a0)
		clr.b	2(a0)
		dbf	d0,.loop
		move.b	#7,(a0)
		move.b	d1,2(a0)
		move.w	#$2300,sr

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.w	original_rez,-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		move.b	#$8,$fffffc02.w

		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50
		bsr	set_user

		ifeq	FINAL
		clr.w	-(sp)
		trap	#1
		endc

		ifeq	AUTORUN4
		bra	exec
		elseif
		clr.w	-(sp)
		trap	#1
		endc

zero		;flip hertz indicator...
		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$002,pic+2
		eor.w	#-1,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts



*******************
* CUSTOM ROUTINES *
*******************
offset_down_scr	equ	160*3
depth		equ	16
text_printer	eor.w	#1,cursor
		bne	.do_cursor_only

		cmp.w	#1,enable_text
		blt	.do
		beq.s	.nearly
		sub.w	#1,enable_text
		rts
.nearly		clr.w	xpos
		clr.w	byte_offset
		sub.w	#1,enable_text
		move.l	scr_now,a0
		move.l	scr_other,a1
		lea	offset_down_scr(a0),a0
		lea	offset_down_scr(a1),a1
		moveq	#0,d0		;clear area of last text
		rept	80*depth
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		endr
		lea	160(a0),a0
		lea	160(a1),a1
		rept	80*depth
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		endr
		move.w	#1,cursor
		clr.w	ypos
		rts

.do		tst.w	delay_timer
		beq.s	.no_delay
		sub.w	#1,delay_timer
		rts
.no_delay	move.l	ascii_pos,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		cmp.b	#-1,d0
		bne.s	.no_restart
		lea	ascii,a0
		clr.w	xpos
		clr.w	byte_offset
		move.b	(a0)+,d0
.no_restart	cmp.b	#13,d0
		bne.s	.notcr
		move.w	#1,cursor
		bsr	.do_cursor_only
		move.w	#17*160,ypos
		clr.w	byte_offset
		clr.w	xpos
		move.l	a0,ascii_pos
		rts

.notcr		cmp.b	#15,d0
		bne.s	.not_end
		move.w	#100,enable_text
		move.l	a0,ascii_pos
		rts

.not_end	cmp.b	#11,d0		;delay
		bne.s	.no_set_delay
		move.w	#15,delay_timer
		move.l	a0,ascii_pos
		rts

.no_set_delay	cmp.b	#12,d0		;del
		bne	.ok
		move.l	scr_now,a1
		move.l	scr_other,a2
		add.w	ypos,a1
		add.w	ypos,a2
		add.w	byte_offset,a1
		add.w	byte_offset,a2
		move.w	xpos,d0		;clear char to right of cursor
		and.w	#$ff,d0
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		add.w	d0,a1
		add.w	d0,a2
		moveq	#0,d0
offset		set	offset_down_scr
		rept	16
		move.b	d0,offset(a1)
		move.b	d0,offset(a2)
offset		set	offset+160
		endr
		sub.w	#1,xpos
		eor.w	#1,byte_offset
		move.l	a0,ascii_pos
		rts

.ok		move.l	a0,ascii_pos
		cmp.b	#9,d0		;tab
		bne.s	.no_tab
		add.w	#8,xpos
		bra	.no_delay
.no_tab		sub.w	#32,d0
		mulu	#depth,d0
		lea	font,a0
		add.w	d0,a0
		move.w	xpos,d0
		and.w	#$ff,d0
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8 for words across screen
		add.w	byte_offset,d0
.no_add		move.l	scr_now,a1
		move.l	scr_other,a2
		add.w	ypos,a1
		add.w	ypos,a2
		add.w	d0,a1
		add.w	d0,a2
offset	set	offset_down_scr
		rept	16
		move.b	(a0),offset(a1)
		move.b	(a0)+,offset(a2)
offset	set	offset+160
		endr
		eor.w	#1,byte_offset
		add.w	#1,xpos
		rts

.do_cursor_only	move.w	xpos,d0
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		beq.s	.no_curs	;prevent cursor on top line when CR is met as 1st char
		add.w	byte_offset,d0
		move.l	scr_now,a1
		move.l	scr_other,a2
		add.w	ypos,a1
		add.w	ypos,a2
		add.w	d0,a1
		add.w	d0,a2
		eor.b	#-1,offset_down_scr+2240(a1)
		eor.b	#-1,offset_down_scr+2240(a2)
		eor.b	#-1,offset_down_scr+2400(a1)
		eor.b	#-1,offset_down_scr+2400(a2)
.no_curs	rts


SCROLL_DEPTH	equ	32
scroll		move.l	scr_now,a1
		add.l	#160*230,a1
		lea	font_offsets,a2		;font lookup table
		lea	scroll_font,a3		;font itself
		move.l	scroll_pointer,a4	;pointer into text
		move.l	a4,a5
		moveq	#40,d5			;40 words across screen
		move.w	char_offset,d6		;char offset is a toggle
						;for bytes/words
		moveq	#0,d4
next_char	move.b	(a5),d7			;get a letter
		sub.b	#32,d7			;rid of ASCII
		ext.w	d7
		moveq	#0,d0
		move.l	a3,a0
		move.b	(a2,d7),d0	;find correct offset
		mulu	#8*SCROLL_DEPTH,d0	;8 bytes wide * SCROLL_DEPTH
		add.w	d0,a0		;add to font start
		move.w	d6,d0		;char offset
		lsl.w	#5,d0		;*SCROLL_DEPTH
		add.w	d0,a0		;we now point to character in A0
.column
OFF	set	0
		REPT	SCROLL_DEPTH
		move.b	(a0)+,d3
		move.b	d3,OFF(a1)
OFF	set	OFF+1*160		;go down a line
		ENDR
		subq.w	#1,d5		;column value
		beq.s	.finish		;last column then finish
		addq.w	#1,a1		;lower byte of word
		tst.w	d4
		beq.s	.skip		;if D4=0 then do next byte
		add.w	#6,a1		;else goto next word on screen
.skip		not.w	d4
		addq.w	#1,d6		;character offset
		and.w	#7,d6
		bne	.column
		addq.w	#1,a5		;scroll pointer
		tst.b	(a5)		;is end of text?
		bpl	next_char	;NO!
		lea	scroll_text,a5	;do reset scrolline
		bra	next_char
.finish		addq.w	#1,char_offset
		and.w	#7,char_offset
		bne.s	.end
		addq.w	#1,a4
		tst.b	(a4)		;is scroll text end?
		bpl.s	.end		;NO!
		lea	scroll_text,a4	;reset scroll text
.end		move.l	a4,scroll_pointer
		rts




***********************
* SUBROUTINES SECTION *
***********************
set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts



set_up		lea	bss,a0
		move.l	#bssend-bss,d0
.clr		clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.clr

		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

		move.w	#1,cursor

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#49152,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		bsr	print_titles

		lea	pic+34,a0
		move.l	scr_now,a1
		lea	160*28(a1),a1
		move.l	a1,a2
		add.l	#49152,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

		move.w	#$2700,sr
		lea	storage,a0
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa0f.w,(a0)+
		move.b	$fffffa11.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa1d.w,(a0)+
		move.b	$fffffa21.w,(a0)+

		moveq	#1,d0
		jsr	music

		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w

 		bclr	#3,$fffffa17.w

		bset	#5,$fffffa09.w		;enable TIMERC for music

		move.l	#timerb_part1,$120.w
		move.l	#newvbl,$70.w
		move.l	#new_kbd,$118.w
		ori.b	#1,$fffffa07.w
		ori.b	#1,$fffffa13.w
		move.w	#$2300,sr

set_screen	move.l	scr_now,d6
		move.l	d6,scr_other
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
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


ENABLE_PLANE1	equ	yes
ENABLE_PLANE2	equ	no
ENABLE_PLANE3	equ	no
ENABLE_PLANE4	equ	no

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#160*54,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

		move.w	#16-1,d0	;max titles per menu
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





timerb_part1	clr.b	$fffffa1b.w
		move.l	#border_timerb,$120.w
		move.b	#1,$fffffa21.w
 		bclr	#5,$fffffa15.w		;disable TIMERC for music
		move.b	#8,$fffffa1b.w
		rte

** BLOODY HELL!!! New border code!!!!!!
border_timerb	or.w	#$700,sr
		clr.b	$fffffa1b.w
		movem.l	d0/a0,-(sp)
.wait		cmp.b	#$60,$ffff8209.w
		blo.s	.wait
		dbt	d0,*
		dbt	d0,*
		lea	.nops(pc),a0
		moveq	#0,d0
		move.b	$ffff8209.w,d0
		move.b	#228,$fffffa21.w
		sub.b	#$60,d0
		add.w	d0,a0
		jmp	(a0)
.nops		REPT	$60-2
		nop
		ENDR
		dbt	d0,*
		dbt	d0,*
		clr.b	$ffff820a.w	;60 hertz
		nop
		nop
		nop
		nop
		nop
		move.l	(sp)+,d0
		move.b	#2,$ffff820a.w

		lea	colours,a0
		rept	32
		move.w	(a0)+,$ffff8242.w
		dcb.w	124,$4e71
		endr
		move.l	(sp)+,a0
		clr.w	$ffff8242.w
		rte

newvbl		move.w	#$2700,sr

		bclr	#5,$fffffa15.w		;disable TIMERC for music

		movem.l	d0-d7,-(sp)
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7
		move.w	d0,-(sp)
		move.w	#$57e-2,d0
.aaa		dbf	d0,.aaa
		clr.b	$ffff820a.w
		moveq	#1,d0
.bbb		dbf	d0,.bbb
		move.b	#2,$ffff820a.w
		move.w	(sp)+,d0
		movem.l	d0-d7/a0-a6,-(sp)
		clr.w	vsync_flag
		clr.b	$fffffa1b.w
		move.l	#timerb_part1,$120.w
		move.b	#227,$fffffa21.w
		move.b	#8,$fffffa1b.w
		movem.l	(sp)+,d0-d7/a0-a5

		bset	#5,$fffffa15.w		;enable TIMERC for music

		lea	colours+(36*2),a6	;colour text printer in
		rept	35
		move.w	-(a6),$ffff8242.w
		dcb.w	124,$4e71
		endr
		move.l	(sp)+,a6
		move.w	pic+4,$ffff8242.w
		tst.w	hertz_delay
		bne.s	.dec
		rte
.dec		sub.w	#1,hertz_delay
		rte


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



*******************
   SECTION DATA
*******************
pic	incbin	"pic.pi1"


music	incbin	PREMIX.MUS



*************************************************************************

; 13=next line
; 15=end of line
; 12=del char
; 11=delay

;NOTE:   THE ROUTINE SUPPORTS TAB!!!
ascii_pos	dc.l	ascii

;                123456789012345678901234567890123456789	39 CHARS ONLY
ascii	dc.b	"	  ADRENALIN UK PRESENTS",13
	dc.b	"	  PUBLIC DOMAIN DISC 20",15
	dc.b	13,"	  CODED BY SPACEMAN SPLIFF",11,11,12,12,12,12,"IFF",15
	dc.b	"	 DISC PUT TOGETHER BY",11,11,13
	DC.B	"		MOONIE",11,12,12,12,"KIE",15
	DC.B	" ART BY LAZY GIT        ",12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12
	DC.B	"	    ART BY BIOFEEDBACK",15
	DC.B	"	    PRESS 1 FOR",13
	DC.B	"     PD MEGA INTERESTING TITLE 1",15

	DC.B	"	    PRESS 2 FOR",13
	DC.B	"     PD MEGA INTERESTING TITLE 2",15

	DC.B	"	    PRESS 3 FOR",13
	DC.B	"     PD MEGA INTERESTING TITLE 3",15

	DC.B	"	    PRESS 4 FOR",13
	DC.B	"     PD MEGA INTERESTING TITLE 4",15

	dc.b	"WARP................",12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,"RAP........",15

	dc.b	-1



*************************************************************************
screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                     aeeeeeeeeeeeeeeeeeb"
	dc.b	"                     g ADRENALIN PD 20 h"
	dc.b	"                     g                 h"
	dc.b	"                     g  1: PD TITLE 1  h"
	dc.b	"                     g  2: PD TITLE 2  h"
	dc.b	"                     g   3: PD DOCS    h"
	dc.b	"                     g    4: MORE?     h"
	dc.b	"                     g     5: NO!      h"
	dc.b	"                     g                 h"
	dc.b	"                     g                 h"
	dc.b	"                     g                 h"
	dc.b	"                     g                 h"
	dc.b	"                     g                 h"
	dc.b	"                     g                 h"
	dc.b	"                     g   0: 50/60 HZ   h"
	dc.b	"                     dfffffffffffffffffc"
	even
*************************************************************************

scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "                                  ADRENALIN PD DISC 20.   "
 DC.B "CREDITS FOR THIS DISK ARE AS FOLLOWS....   CODING BY   SPACEMAN SPIFF, "
 DC.B "   GRAFIX BY  BIOFEEDBACK,   MUSIC BY TAO, "
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
 DC.B "PERSISTENCE OF VISION (ESP. MAC SYS DATA WHO IS TRULY THE BEST MENU CODER SINCE SLICED BREAD AND BORIS),     "
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
 DC.B "      OH YEAH AND ALL THE DEAD PEOPLE WHO HAVE DESERTED THE ST.  "
 DC.B "                          "
 DC.B "                          "
 dc.b $ff
	even

font	incbin	compfont.dat
	even

scroll_font	dcb.b	SCROLL_DEPTH*8,0
 dc.l	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 dc.l	$7FFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFEFEFE,-1,-1,$FFFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	-1,-1,$FF000000,-1,-1,$FF000000,0,0
 DC.L	-1,-1,$FF000000,-1,-1,$FF000000,0,0
 DC.L	-1,-1,$FF7F7F7F,-1,-1,$FF7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	$FEFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFF8F8FF,-1,-1,$F8F8FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FF0000FF,-1,-1,$0000FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FF0000FF,-1,-1,$0000FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FF1F1FFF,-1,-1,$1F1FFFFF,-1,$FFFFFF00
 DC.L	$FEFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFE00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$F8F8E0E0,$F8F8FEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	$7FFFFFFF,-1,-1,-1,-1,-1,-1,$FFFF7F00
 DC.L	-1,-1,$FFFFFFFE,$FEFEFEFE,$FEFEFEFE,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF8000,0,0,$80FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFE0000,0,0,$00FEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFEFE,$FEFEFEFE,$FEFEFEFE,$FEFFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0100,0,0,$01FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFF7F,$7F7F7F7F,$7F7F7F7F,-1,-1,$FFFFFF00
 DC.L	$FEFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFE00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	$7FFFFFFF,-1,-1,-1,-1,-1,-1,$FFFF7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF80FF,-1,-1,$80FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00F8,$F8F8F8F8,$F8F8F8F8,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFE0000,0,0,$00FEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,0,0,0,-1,-1,$FFFF00FF,-1,-1,0,0,0
 DC.L	-1,-1,$FFFF00F0,$F0F0F0F0,$F0F0F0F0,0,0,0
 DC.L	-1,-1,$FFFF0000,0,0,0,0,0
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFC0000,0,0,0,0,0
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,$FFFFFF3F,$3F0F0000
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFFFC,$FCFCFCFC,$FCFCFCFC,$FCFFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFC0000,$F0FCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFC00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFCFCFF,-1,-1,$FFFCFCFC,$FCFCFCFC,$FCFCFC00
 DC.L	0,0,$000000FF,-1,-1,$FF000000,0,0
 DC.L	0,0,$000000FF,-1,-1,$FF000000,0,0
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7FFF,-1,-1,$FF7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	0,0,0,0,0,0,0,0
 DC.L	$01010101,$01010101,$01000000,0,0,$00000101,$01010101,$01010100
 DC.L	-1,-1,$FF070707,$07070707,$07070707,$0707FFFF,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFF8F8F8,$F8F8F8F8,$F8F8F8F8,$F8F8FFFF,-1,$FFFFFF00
 DC.L	$E0E0E0E0,$E0E0E0E0,$E0000000,0,0,$0000E0E0,$E0E0E0E0,$E0E0E000
 DC.L	0,0,0,0,0,0,0,0
 DC.L	0,0,0,$00007F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	0,0,0,$0000FFFF,-1,-1,-1,$FFFF7F00
 DC.L	0,0,0,$0000FEFE,$FEFEFEFE,-1,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$80FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$01FFFFFF,-1,$FFFFFF00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFE00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,-1,$FFFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	0,0,$01071F7F,-1,$FF7F1F07,$01000000,0,0
 DC.L	0,$01071F7F,-1,-1,-1,$FF7F1F07,$01000000,0
 DC.L	$01071F7F,-1,-1,$FFFEF8FE,-1,-1,$FF7F1F07,$01000000
 DC.L	-1,-1,$FFFEF8E0,$80000000,$80E0F8FE,-1,-1,$FF7F1F00
 DC.L	$F8FEFEFE,$FEFEF8E0,$80000000,0,0,$80E0F8FE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$80E0F8FE,-1,-1,-1,$FFFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	0,$80E0F8FE,-1,-1,$FF7F1F07,$01000000,0,0
 DC.L	0,$01071F7F,-1,-1,$FFFEF8E0,$80000000,0,0
 DC.L	$01071F7F,-1,-1,-1,$FF7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$E0F8F8FE,-1,-1,-1,$FFFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	0,$80E0F8FE,-1,-1,$FF7F1F07,$01000000,0,0
 DC.L	0,0,$80E0F8FE,-1,-1,$FF7F1F07,$01000000,0
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,-1,-1,-1,$FF7F1F07,$01000000
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FF7F1F00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	$7FFFFFFF,-1,-1,-1,-1,-1,-1,$FFFF7F00
 DC.L	-1,-1,$FFFFFFFE,$FEFEFEFE,$FEFEFEFE,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF8000,0,0,$80FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0100,0,0,$01FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFF7F,$7F7F7F7F,$7F7F7F7F,-1,-1,$FFFFFF00
 DC.L	$FEFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFE00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFCFCFC,-1,-1,$FFFCFCFC,$FCFCFCFC,$FCFCFC00
 DC.L	-1,-1,$FF000000,-1,-1,$FF000000,0,0
 DC.L	-1,-1,$FF000000,-1,-1,$FF000000,0,0
 DC.L	-1,-1,-1,-1,-1,$FF000000,0,0
 DC.L	$FCFFFFFF,-1,-1,-1,-1,$FC000000,0,0
 DC.L	$00C0F0F0,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCF0F0C0,0,0,0
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,$FFFFFF3F,$3F0F0000
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFFFC,$FCFCFCFC,$FCFCFCFC,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00F3FCFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0300,0,$00030F3F,$FFFFFF3F,$CFF3FCFF,$FFFFFF00
 DC.L	-1,-1,-1,-1,$3FCFF3FC,-1,$FFFFFF3F,$CFF3FC00
 DC.L	$FCFFFFFF,-1,-1,-1,-1,$3FCFF3FC,-1,$FFFCF000
 DC.L	$00C0F0F0,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$3CCCF0C0,0
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFCFCFC,-1,-1,$FFFCFCFC,$FCFCFCFC,$FCFCFC00
 DC.L	-1,-1,$FF000000,-1,-1,$FF3F0F03,0,0
 DC.L	-1,-1,$FF000000,-1,-1,-1,$7F1F0701,0
 DC.L	-1,-1,$FF7F7F7F,-1,-1,-1,-1,$7F1F0700
 DC.L	$FEFFFFFF,-1,-1,-1,-1,$FEE0F8FE,-1,$FFFFFF00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEF8F8E0,0,$80E0F8FE,$FEFEFE00
 DC.L	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F1F1F07,$00007F7F,$7F7F7F7F,$7F7F7F00
 DC.L	$7FFFFFFF,-1,-1,-1,-1,$0000FFFF,-1,$FFFFFF00
 dc.l	-1,-1,-1,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF80FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$7F7FFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FE,-1,-1,-1,-1,$FFFFFE00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFE0000,$E0F8F8FE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F0000,0,0,0,0,0,-1,-1,$FFFF0000,0
 DC.L	0,0,0,0,-1,-1,$FFFF0707,$7070707,$7070707,$7070707
 DC.L	$7070707,$7070700,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,-1,-1,$FFFFF8F8,$F8F8F8F8,$F8F8F8F8,$F8F8F8F8
 DC.L	$F8F8F8F8,$F8F8F800,-1,-1,$FFFF0000,0,0,0,0,0
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFE0000,0,0,0,0,0,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000,-1,-1,-1,-1
 DC.L	-1,-1,-1,$FFFF7F00,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE
 DC.L	$FEFEFEFE,-1,-1,$FFFFFF00,0,0,0,0,0,$80FFFFFF
 DC.L	-1,$FFFFFF00,0,0,0,0,0,$1FFFFFF,-1,$FFFFFF00,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,-1,-1,$FFFFFF00,-1,-1
 DC.L	-1,-1,-1,-1,-1,$FFFFFE00,$FEFEFEFE,$FEFEFEFE
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F7F7F7F,$7F7F7F7F,$1F070100,0,0,0,-1,-1,-1,-1
 DC.L	$FFFFFF7F,$1F070100,0,0,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,-1,$FFFFFF7F
 DC.L	$1F070100,0,0,0,0,0,$80E0F8FE,-1,$FFFFFF7F,$1F070100,0,0,0,0
 DC.L	$1071F7F,-1,$FFFFFFFE,$F8E08000,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
 DC.L	-1,$FFFFFFFE,$F8E08000,0,-1,-1,-1,-1
 DC.L	$FFFFFFFE,$F8E08000,0,0,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$F8E08000,0
 DC.L	0,0,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFF,-1,-1,$FFFFFFFE,$F8E08000
 DC.L	0,0,1,$71F7FFF,-1,-1,$F8E08000,0,0,0,$80,$E0F8FEFF
 dc.L	-1,-1,$1F070100,0,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7FFF
 DC.L	-1,-1,$FFFFFF7F,$7F7F7F00,-1,-1,-1,-1
 DC.L	-1,-1,-1,$FFFFFF00,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00,$7F7F7F7F,$7F1F0701,0,0
 DC.L	0,$1071F7F,$7F7F7F7F,$7F7F1F00,-1,-1,$7F1F0701,0
 DC.L	$1071F7F,-1,-1,$FEF8E000,$E0F8FEFF,-1,-1,$7F1F1F7F
 DC.L	-1,-1,$FEF8E080,0,$80,$E0F8FEFF,-1,-1
 DC.L	-1,$FEF8E080,0,0,0,$1071FFF,-1,-1,-1,$7F1F0701
 DC.L	0,0,$1071F7F,-1,-1,$FFFEF8FE,-1,-1
 DC.L	$7F1F0701,0,-1,-1,$FFFEF8E0,$80000000,$80E0F8FE,-1
 DC.L	-1,$7F1F0700,$FEFEFEFE,$FEFEF8E0,$80000000,0,0,$80E0F8FE
 DC.L	$FEFEFEFE,$FEFEF800,$7F7F7F7F,$7F1F0701,0,0,0,0,0,0
 DC.L	-1,-1,$7F1F0701,0,0,0,0,0,$E0F8FEFF,-1
 DC.L	-1,$7F1F0707,$7070707,$7070707,$7070707,$7070700,$80,$E0F8FEFF
 DC.L	-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	0,$1071FFF,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$1071F7F,-1,-1,$FFFEF8F8,$F8F8F8F8,$F8F8F8F8,$F8F8F8F8,$F8F8F800
 DC.L	-1,-1,$FFFEF8E0,$80000000,0,0,0,0,$FEFEFEFE,$FEFEF8E0
 DC.L	$80000000,0,0,0,0,0,-1,-1,$FF000000,0,0,$30F
 DC.L	$3FFFFFFF,$FFFFFF00,-1,-1,$FF000000,0,$30F,$3FFFFFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FF000000,$30F,$3FFFFFFF,-1
 DC.L	-1,$FFFFFF00,-1,-1,$FF00030F,$3FFFFFFF,-1,-1
 DC.L	-1,$FFFFFF00,-1,-1,-1,-1,$FFFFFFFC,$F0C0FFFF
 DC.L	-1,$FFFFFF00,-1,-1,-1,$FFFFFFFC,$F0C00000,$FFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FFFFFFFC,$F0C00000,0,$FFFF
 DC.L	-1,$FFFFFF00,$FCFCFCFC,$FCFCFCFC,$F0C00000,0,0,$FCFC
 DC.L	$FCFCFCFC,$FCFCFC00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,$10101,$1010007,$7070700,0,0,0,0,0,$FFFFFF,$FFFF1FFF,$FFFFFF00
 DC.L	0,0,0,0,0,$FFFFFF,-1,$FFFE8000,0,0,0,0,0,$E0E0E0,$E0E0E0E0,$E0000000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,0,$10101,$1010101,$1010100,0,0,0,0,0,$FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$FFFFFF,-1,$FFFFFF00,0,0,0,0,0,$E0E0E0,$E0E0E0E0,$E0E0E000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	$1F1F1F,$1F1F1F1F,$1F000000,$707,$7070700,$1F1F1F1F,0,0,$FFFFFF,-1
 DC.L	$FF000000,$FFFF,$FFFFFF7F,$FFFFFFFE,0,0,$FFFFFF,-1,$FF000000,$FFFF
 DC.L	-1,$FFFFF800,0,0,$808080,$80808080,$80000000,$8080,$80808080,$80800000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	$1F1F1F,$1F1F1F1F,$1F000000,$1F1F,$1F1F1F1F,$1F1F0000,0,0,$FFFFFF,-1
 DC.L	$FF000000,$FFFF,-1,$FFFF0000,0,0,$FFFFFF,-1,$FF000000,$FFFF
 DC.L	-1,$FFFF0000,0,0,$E0E0E0,$E0E0E0E0,$E0000000,$E0E0,$E0E0E0E0,$E0E00000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


 DC.L	$F3F3F,-1,-1,-1,-1,-1,$FFFFFF3F,$3F0F0000,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,-1,-1,$FFFFFFFC,$FCFCFFFF,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF030F,$3FFFFFFF,-1,-1,-1,$FFFFFF00,-1,-1,-1,-1
 DC.L	$FFFFFFFC,$F3FFFFFF,-1,$FFFFFF00,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,$FCFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFC00
 DC.L	$C0F0F0,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCF0,$F0C00000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	$30F3F,-1,-1,$3030303,$3030303,$303FFFF,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFFFF,-1,$FFFFFF00,0,0,0,0,0,$F0F0
 DC.L	$F0F0F0F0,$F0F0F000,0,0,0,0,0,0,0,0,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F7F0000,$71F1F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	-1,-1,$FFFF007F,-1,-1,-1,-1,$FFFF7F00,-1,-1,$FFFF00FF,-1
 DC.L	-1,$FEFEFFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF1FFF,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1,-1,-1
 DC.L	$FFFFFFFE,$FFFF,-1,$FFFFFF00,$80F8FEFE,$FEFEFEFE
 DC.L	$FEFEFEFE,$FEFEFEFE,$F8F8E000,$FEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$3F3F3F3F,$3F3F3F3F,$3F3F0000,0,0,$3F3F3F,$3F3F3F3F,$3F3F3F00
 DC.L	-1,-1,$FFFF0000,0,0,$FFFFFF,-1,$FFFFFF00,-1,-1
 DC.L	$FFFF000F,$F0F0F0F,$F0F0F0F,$FFFFFF,-1,$FFFFFF00,-1,-1
 DC.L	$FFFF00FF,-1,-1,$FFFFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1
 DC.L	-1,$FFFFFF,-1,$FFFFFF00,-1,-1,$FFFF0FFF,-1,-1,$FFFFFFF
 DC.L	-1,$FFFFFF00,-1,-1,-1,-1,-1,-1,-1,$FFFFFF00,$F0FCFCFC,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCF00000
 DC.L	0,0,$30F3F3F,$3F3F3F3F,$3F3F3F3F,$3F000000,0,0,0,$30F3FFF
 DC.L	-1,-1,-1,$FF000000,0,0,$30F3FFF,-1,-1,-1,-1,$FF000000
 DC.L	0,0,-1,-1,$FFFCF0FF,-1,-1,$FF000000,0,0,-1,-1,$FF,-1
 DC.L	-1,$FF000000,0,0,-1,-1,$3F3F3FFF,-1,-1,$FF3F3F3F
 DC.L	$3F3F3F3F,$3F3F3F00,-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00,-1,-1,-1,-1,-1,$FFFF
 DC.L	-1,$FFFFFF00,-1,-1,-1,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1
 DC.L	-1,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$3F3FFFFF,-1,$FFFFFF00,-1,-1
 DC.L	$FFFF00FC,-1,-1,-1,-1,$FFFFFC00,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFC0000,$C0F0F0FC,$FCFCFCFC,$FCFCFCFC,$FCFCFCF0,$F0C00000
 DC.L	$F3F3F,-1,-1,-1,-1,-1,$FFFFFF3F,$3F0F0000,-1,-1,-1,-1
 DC.L	-1,-1,-1,$FFFFFF00,-1,-1,-1,-1,-1,$FCFCFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1
 DC.L	-1,$FFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$3F3FFFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FFFF00FC,-1,-1,-1,-1,$FFFFFC00
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFC0000,$C0F0F0FC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCF0,$F0C00000,$7F7F7F7F,$7F7F7F7F,$7F000000,0
 DC.L	0,$107,$1F7F7F7F,$7F7F7F00,-1,-1,$FF000000,0
 DC.L	$107,$1F7FFFFF,-1,$FFFFFF00,-1,-1,$FF000000,$107
 DC.L	$1F7FFFFF,-1,$FFFFFFFE,$F8E08000,-1,-1,$FF000107,$1F7FFFFF
 DC.L	-1,$FFFFFFFE,$F8E08000,0,-1,-1,$FF7FFFFF,-1
 DC.L	$FFFFFFFE,$F8E08000,0,0,-1,-1,-1,$FFFFFFFE,$F8E08000,0
 DC.L	0,0,-1,-1,$FFFFFFFE,$F8E08000,0,0,0,0,$FEFEFEFE,$FEFEFEFE
 DC.L	$F8E08000,0,0,0,0,0,$71F1F,$7F7F7F7F,$7F7F7F7F,$1F1F0707
 DC.L	$1F1F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000,$7FFFFFFF,-1
 DC.L	-1,-1,-1,-1,-1,$FFFF7F00,-1,-1,$FFFEFEFF,-1,-1,$FEFEFFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FF0000FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FF0000FF,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1
 DC.L	$FF1F1FFF,-1,-1,$1F1FFFFF,-1,$FFFFFF00,$FEFFFFFF,-1
 DC.L	-1,-1,-1,-1,-1,$FFFFFE00,$E0F8F8,$FEFEFEFE,$FEFEFEFE,$F8F8E0E0
 DC.L	$F8F8FEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000,$71F1F,$7F7F7F7F
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F1F1F07,0,0,0,$7FFFFFFF,-1,-1,-1
 DC.L	-1,$7F000000,0,0,-1,-1,$FFFEFEFF,-1,-1,$FF000000,0,0
 DC.L	-1,-1,$FF0000FF,-1,-1,$FF000000,0,0,-1,-1,$FF0000FF,-1
 DC.L	-1,$FF000000,0,0,-1,-1,$FF0F0FFF,-1,-1,$FF3F3F3F
 DC.L	$3F3F3F3F,$3F3F3F00,-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$F0FCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFC00,0,0,0,0,0,0,0,0,0,$3030303
 DC.L	$3030303,$3030303,$3030303,$3030303,$3030300,0
 DC.L	$33FFFFF,-1,-1,-1,-1,-1,-1,$FF3F0300,-1,-1,-1,-1
 DC.L	-1,-1,-1,$FFFFFF00,-1,-1,$FFFFFCF0,$F0F0F0F0,$F0F0F0F0,$FCFFFFFF
 DC.L	-1,$FFFFFF00,$FCFCFCFC,$FCFCFCFC,$FCFC0000,0,0,$FCFCFC
 DC.L	$FCFCFCFC,$FCFCFC00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,0,0,0,0,$3030303,$3030303,$3030000,0,0,$30303
 DC.L	$3030303,$3030300,-1,-1,$FFFF0300,0,0,$3FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00,$FCFFFFFF,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFC00,$C0F0F0,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFCFCF0,$F0C00000,0,0,0,0,0,0
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,$3F3F3F,$3F3F3F3F,0,0,0,0,0
 DC.L	0,$FFFFFF,-1,0,0,0,0,0,0,$FFFFFF,-1,0,0,0,0,0,0,$FFFFFF
 DC.L	-1,0,0,0,0,0,0,$FFFFFF,-1,0,0,0,0,0,0,$FFFFFF,-1,0
 DC.L	0,0,0,0,0,$FFFFFF,-1,0,0,0,0,0,0,$808080,$80808080,0
 DC.L	0,0,$1F7F7F7F,$7F1F0701,0,$1F7F7F,$7F7F7F1F,0
 DC.L	$1071F7F,$7F7F7F1F,$FEFFFFFF,-1,$7F1F0701,$FFFFFF
 DC.L	-1,$1071F7F,-1,$FFFFFFFE,$80E0F8,$FEFFFFFF,-1,$7FFFFFFF
 DC.L	-1,-1,$FFFFFFFE,$F8E08000,0,$80E0F9,-1,-1,-1,-1
 DC.L	$F9E08000,0,1,$71F7FFF,-1,-1,-1,-1,$FF7F1F07,$1000000
 DC.L	$71F7FFF,-1,$FFFFFEF8,$E0FFFFFF,-1,$F8FEFFFF,-1,$FF7F1F07
 DC.L	-1,$FFFFFEF8,$E0800000,$FFFFFF,-1,$80E0,$F8FEFFFF,-1
 DC.L	$80E0E0E0,$E0800000,0,$80E0E0,$E0E0E080,0,$80E0,$E0E0E080
 DC.L	0,0,0,0,1,$107071F,$1F7F7F7F,$7F7F7F1F,0,0,1,$107071F
 DC.L	$1F7F7FFF,-1,-1,$FFFEFEF8,1,$107071F,$1F7F7FFF,-1
 DC.L	-1,$FFFEFEF8,$F8E0E080,$80000000,$1F7F7FFF,-1,-1,$FFFEFEF8
 DC.L	$F8E0E080,$80000000,0,0,$F8FEFEFE,$FEFEFEF8,$F8E0E080,$80000000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,$71F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F1F1F07,$7F,$7F7F7F7F,$7F7F7F00,$7FFFFFFF,-1,-1,-1
 DC.L	-1,$7F0000FF,-1,$FFFFFF00,$80F8FEFE,-1,-1,-1,$FFFEFEF8,$800000FF
 DC.L	-1,$FFFFFF00,0,$80808080,$80808080,$80808080,$80000000,$80
 DC.L	$80808080,$80808000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1
 DC.L	$FFFF0000,$F3F3FFF,-1,$FFFF00FF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1
 DC.L	-1,$FFFF00FF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FCFC00F0
 DC.L	$F0F0F0F0,$F0F0F000,-1,-1,$FFFF00FF,-1,-1,0,0,0,-1,-1
 DC.L	$FFFF00FF,-1,-1,0,0,0,-1,-1,$FFFF3FFF,-1,-1,0,0,0
 DC.L	$FCFFFFFF,-1,-1,-1,$FFFFFFFC,0,0,0,$C0F0F0,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFCFC,$F0F0C000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,$F0F0F0F,$F003F3F,$3F3F0000,0,0,0,0,0,-1,-1
 DC.L	$FFFC0000,0,0,0,0,0,-1,-1,$F0000000,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

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

colours
 dc.w	0
 dc.w	$708,$f00,$f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60
 dc.w	$fe0,$f70,$ff0,$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0
 dc.w	$9f0,$1f0,$0f0,$070

 dc.w	$0e0,$060,$0d0,$050,$0c0,$040



screen_titles_font
 DC.L	$00000000,$00001818,$18001800,$66660000,$00006CFE
 DC.L	$6CFE6C00,$3E583C1A,$7C00666C,$18326600,$00000000
 DC.L	$00001818,$00000000,$0C181818,$0C003018,$18183000
 DC.L	$663CFF3C,$66001818,$7E181800,$00000000,$30600000
 DC.L	$7E000000,$00000000,$1800060C,$18306000,$3C666E76
 DC.L	$3C001838,$18187E00,$3C660C18,$3E007E0C,$1C463C00
 DC.L	$1C3C6C7E,$0C007E60,$7C067C00,$3C607C66,$3C007E0C
 DC.L	$18303000,$3C663C66,$3C003C66,$3E063C00,$00180018
 DC.L	$00000018,$00183000,$0C183018,$0C00007E,$007E0000
 DC.L	$30180C18,$30003C46,$0C001800,$3E626C60,$7E003C66
 DC.L	$667E6600,$7C667C66,$7C003C66,$60663C00,$7C666666
 DC.L	$7C007E60,$7C607E00,$7E607C60,$60003E60,$6E663E00
 DC.L	$66667E66,$66003C18,$18183C00,$06060666,$3C006C78
 DC.L	$70786C00,$60606060,$7E00EEFE,$D6C6C600,$767E7E6E
 DC.L	$66003C66,$66663C00,$7C667C60,$60003C66,$666C3600
 DC.L	$7C667C6C,$66003C60,$3C063C00,$7E181818,$18006666
 DC.L	$66663E00,$66666624,$1800C6C6,$D6EEC600,$663C183C
 DC.L	$66006666,$3C181800,$7E0C1830,$7E001E18,$18181E00
 DC.L	$6030180C,$06007818,$18187800,$386CC600,$00000000
 DC.L	$0000FE00,$C0603000,$0000FF80,$80808080,$FF010101
 DC.L	$01010101,$010101FF,$80808080,$80FFFF00,$00000000
 DC.L	$00000000,$00FF8080,$80808080,$01010101,$01010000
 DC.L	$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L	$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L	$FFFFFFFF,$FFFFC3C3,$C3C3C3C3,$000000FF,$FFFF0000
 DC.L	$00000001,$00000000,$00010000,$00000000,$FFFFFFFF
 DC.L	$FFFFC3C3,$C3FFFFFF,$C1C1C3C1,$C1E18383,$C3838387
 DC.L	$00000000,$0000C300,$0000C3C3,$FFFFFF87,$0707FF00
 DC.L	$0000FFFF,$FFFFFFC3,$C3C3E0C0,$8103070F,$00000000
 DC.L	$00818383,$83000000,$00000080,$80800000,$00000081
 DC.L	$81010000,$00E10000,$00000001,$01010000,$00810000
 DC.L	$81838787,$00000000,$00810000,$00808081,$C3C3C3C3
 DC.L	$C3FFC3C3,$C3838387,$C1818381,$C1E10000,$000000FF
 DC.L	$8381C181,$83870000,$00C1C3C3,$00000000,$00000000
 DC.L	$00000000,$00000000,$00010000,$00000081,$00000000
 DC.L	$00010000,$01000000,$00000101,$0F0F0000,$00000080
 DC.L	$00000000,$00008181,$C3818181,$F0F00000,$00810101
 DC.L	$03010101,$0F0F0F00,$00000000,$00001010,$00000000
 DC.L	$00000000,$00000081,$00000001,$0F0F0000,$00000080
 DC.L	$00000000,$00000101,$00808081,$0000C3C3,$C3C30000
 DC.L	$00000080,$00000000,$81C31000,$00000010,$00008100
 DC.L	$00000000,$0081C3C3,$00008100,$0000C0C0,$C3C0C0C0
 DC.L	$070381C0,$E0F00303,$C3030303,$01000010,$FFFFFFFF
 DC.L	$FF000000,$0F070787,$FFFF007F,$7F7F7FFF,$00FCFCFC
 DC.L	$FCFFFCFC,$FCFC00FF,$3F3F3F3F,$00FFFFFF,$FFFFFFFF
 DC.L	$FFFFFFFF,$00FF3F3F,$3F3F3FFF,$FCFCFCFC,$FCFFFFFF
 DC.L	$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
 DC.L	$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF



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
exec1	dc.b	"cartoon",0
	even
exec2	dc.b	"abc13",0
	even
exec3	dc.b	"hmd_tbc",0
	even
exec4	dc.b	"hmd_bobs",0
	even
exec5	dc.b	"reps",0
	even
exec6	dc.b	"dynamite",0
	even
exec7	dc.b	"dns",0
	even
exec8	dc.b	"tsc99_11",0
	even
exec9	dc.b	"copier.pov",0
	even



*******************
   SECTION BSS
*******************
bss
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_pal		ds.w	16
scr_now		ds.l	1
scr_other	ds.l	1
scr_xor		ds.l	1

xpos		ds.w	1
ypos		ds.w	1
byte_offset	ds.w	1
cursor		ds.w	1
enable_text	ds.w	1
delay_timer	ds.w	1

char_offset	ds.w	1		;scroller offset

hertz_delay	ds.w	1
hertz_toggle	ds.w	1

storage		ds.b	20
vsync_flag	ds.w	1
key		ds.w	1


		ds.b	256
screens		ds.b	49152
		ds.b	49152
bssend