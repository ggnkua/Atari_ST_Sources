*************************************************************************
*			Persistence Of Vision 162			*
*			-------------------------			*
*									*
*									*
* Written by;-	Machine System Data of Persistence Of Vision		*
*									*
*									*
* Date:		April 1998						*
*									*
* E-mail:	pov@tesco.net						*
*									*
*************************************************************************
*
*
*
******* POV DOWNLOAD DEVELOPMENT SWITCHES *****************************
YES	equ	1
NO	equ	0
yes=YES
no=NO
DOWNLOAD	equ	NO YES
	ifne	DOWNLOAD
	include	transmit.s
	org	$20000
Code_Start
Exec_Addr
	ENDC
***********************************************************************

	OPT	o+,w-

begin	bra	start
mystack	ds.w	512
; filename has already been stored in $200 so we can now P_EXEC
exec
	move.l	#mystack,sp
	cmp.w	#"$$",d7
	beq.s	.gemexec
	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	clr.l	-(sp)		;reset!
	move.w	#$20,-(sp)
	trap	#1
	move.l	4.w,-(sp)
	rts
.gemexec	clr.w	-(sp)
		trap	#1
blank	dc.l	0

*******************************************************************
start	move.l	4(a7),a0
;	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

	lea	bssstart,a0
	move.l	#bssend-bssstart,d0
clearbss	clr.b	(a0)+
	sub.l	#1,d0
	bne.s	clearbss

	bsr	set_up
	bsr	sort_isr			;start interrupts, etc.
	bsr	show_pic
	bsr	flush				;empty keyboard buffer

main_loop
	bsr	vsync				;sync to our new VBL
	bsr	set_screen			;flip screen

	bsr	siner

	bsr	clear_spec			;clear old spec anal
	bsr	calc_spec			;calc and print new one
	bsr	scroll				;do the scroll
;	move.w	#$123,$ffff8240.w

	move.w	key,d0

	ifne	DOWNLOAD
	cmp.w	#1,d0		;ESC
	bne.s	assem
	move.l	4.w,-(sp)
	rts
	endc
assem
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

	bsr	isr_off

	moveq	#0,d0
	jsr	music

	move.l	old_base,a0	;screen_base
	bsr	set_low_rez

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	#8,$fffffc02.w

	move.w	$200.w,d7

	ifeq	DOWNLOAD
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	else
	move.l	4.w,-(sp)
	rts
	endc

	bra	exec


reset	move.l	4.w,-(sp)
	rts


exit	bsr	isr_off

	move.l	old_base,a0
	bsr	set_med_rez

	bsr	restore_pal

	move.b	#8,$fffffc02.w
	
	bsr	user_mode

	clr.w	-(sp)
	trap	#1





zero	tst.w	zero_counter
	bne	main_loop

	eor.w	#$001,pic+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra	main_loop


do_reset
	move.l	4.w,a0
	jmp	(a0)







siner	move.l	screen_base,a0
	lea	85*160(a0),a0
	moveq	#0,d0
	rept	90
	move.w	d0,(a0)
	lea	160(a0),a0
	endr

	lea	pov162,a0
	move.l	screen_base,a3
	add.w	#24,a3

	moveq	#0,d0
	lea	table,a1
	move.w	table_offset,d4

	bsr	putchar2	;p
	add.w	#8,a3
	bsr	putchar1	;e
	bsr	putchar2	;r
	add.w	#8,a3
	bsr	putchar1	;s
	bsr	putchar2	;i
	add.w	#8,a3
	bsr	putchar1	;s
	bsr	putchar2	;t
	add.w	#8,a3
	bsr	putchar1	;e
	bsr	putchar2	;n
	add.w	#8,a3
	bsr	putchar1	;c
	bsr	putchar2	;e
	add.w	#8,a3
	bsr	putchar2	;o
	add.w	#8,a3
	bsr	putchar1	;f
	add.w	#8,a3
	bsr	putchar1	;v
	bsr	putchar2	;i
	add.w	#8,a3
	bsr	putchar1	;s
	bsr	putchar2	;i
	add.w	#8,a3
	bsr	putchar1	;o
	bsr	putchar2	;n
	add.w	#8,a3
	bsr	putchar2	;1
	add.w	#8,a3
	bsr	putchar1	;6
	bsr	putchar2	;2
	rts

putchar1
offset1	set	0
	move.l	a3,a4

	add.w	#2,d4	;y offset
	and.w	#255,d4
	add.w	0(a1,d4.w),a3

	clr.b	offset1-640(a3)
	clr.b	offset1-480(a3)
	clr.b	offset1-320(a3)
	clr.b	offset1-160(a3)

	rept	16
	move.b	(a0)+,offset1(a3)
offset1	set	offset1+160
	endr
	clr.b	offset1(a3)
	clr.b	offset1+160(a3)
	clr.b	offset1+320(a3)
	clr.b	offset1+480(a3)
	move.l	a4,a3
	rts

putchar2
offset	set	1

	move.l	a3,a4

	add.w	#2,d4	;y offset
	and.w	#255,d4
	add.w	0(a1,d4.w),a3

	clr.b	offset-640(a3)
	clr.b	offset-480(a3)
	clr.b	offset-320(a3)
	clr.b	offset-160(a3)

	rept	16
	move.b	(a0)+,offset(a3)
offset	set	offset+160
	endr
	clr.b	offset(a3)
	clr.b	offset+160(a3)
	clr.b	offset+320(a3)
	clr.b	offset+480(a3)
	move.l	a4,a3
	rts





******************************
*                            *
* Spectrum Analyser routines *
*                            *
******************************

MAX_BARS	equ	80
AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

clear_spec
	move.l	screen_base,a1
	add.w	#115*160+2,a1
	moveq	#0,d0
	REPT	(20*26)
	move.w	d0,(a1)
	addq.w	#8,a1
	ENDR
	rts

calc_spec
	lea	spec_values,a0
	moveq	#(MAX_BARS-1),d0
.cnt_down
	tst.w	(a0)+
	beq.s	.next
	subq.w	#1,-2(a0)
.next
	dbf	d0,.cnt_down

	lea	$ffff8800.w,a1
	lea	spec_values,a2
	lea	spec_data,a3
	moveq	#12,d2

	move.b	#AAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	bchan
	moveq	#0,d0
	move.b	#ACOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	bchan

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	bchan
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************
bchan
	move.b	#BAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	cchan
	moveq	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	cchan

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	cchan
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************
cchan
	move.b	#CAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	ps
	moveq	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	ps

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	ps
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************** print speccy *******************
ps
	move.l	screen_base,a0
	add.w	#127*160+2,a0

	lea	spec_values,a2
	moveq	#(80/4)-1,d1
.loop
	move.w	(a2)+,d0
	beq.s	.nib2
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%11100000,d2
.loop1	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2
	move.w	(a2)+,d0
	beq.s	.nib3
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3
	move.w	(a2)+,d0
	beq.s	.nib4
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%11100000,d2
.loop3	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4
	move.w	(a2)+,d0
	beq.s	.nonib
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%00001110,d2
.loop4	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4

.nonib	addq.w	#8,a0
	dbf	d1,.loop
	rts




; 8 pixel every VBL scroller
scroll	move.l	screen_base,a1
	add.l	#160*177,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	move.w	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#23*4,d0
	add.w	d0,a0
	move.w	d6,d0
	mulu	#23,d0		;character depth * 4 bytes (word wide)
	add.w	d0,a0

.column
OFF	set	0
	REPT	23
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if byte_toggle=0 then do next word
	addq.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts



vu	movem.l	d5-d7/a3-a6,-(sp)
	move.b	#AAMP,$ffff8800.w	;chan A
	move.b	$ffff8800.w,d7
	move.l	screen_base,a6
	add.w	#85*160+2+8,a6	;screen always in A6
	bsr.s	METER
	move.b	#BAMP,$ffff8800.w	;chan B
	move.b	$ffff8800.w,d7
	add.w	#160*5,a6
	bsr.s	METER
	move.b	#CAMP,$ffff8800.w	;chan C
	move.b	$ffff8800.w,d7
	add.w	#160*5,a6
	bsr.s	METER
;flash the disc drive light
	move.b	#BAMP,$ffff8800.w
	move.b	$ffff8800.w,d7
	cmp.b	#15,d7
	blt.s	no_flash
	move.b	#14,$ffff8800.w
	bclr	#1,$ffff8802.w
	bra.s	asdf
no_flash
	move.b	#14,$ffff8800.w
	or.b	#%00000010,$ffff8802.w
asdf	movem.l	(sp)+,d5-d7/a3-a6
	rts

METER	tst.b	d7
	blt	exit_vu		;less than no volume!
	and.w	#$ff,d7
	cmp.w	#15,d7
	bgt	exit_vu
	move.l	a6,a4
	add.w	#80,a4
	mulu	#16,d7
	lea	vu_block,a3
	add.w	d7,a3
	lea	vu2,a5
	add.w	d7,a5
	move.w	(a5),(a6)
	move.w	(a5),160(a6)
	move.w	(a5)+,320(a6)
	move.w	(a3),(a4)
	move.w	(a3),160(a4)
	move.w	(a3)+,320(a4)
	move.w	(a5),8(a6)
	move.w	(a5),168(a6)
	move.w	(a5)+,328(a6)
	move.w	(a3),8(a4)
	move.w	(a3),168(a4)
	move.w	(a3)+,328(a4)
	move.w	(a5),16(a6)
	move.w	(a5),160+16(a6)
	move.w	(a5)+,320+16(a6)
	move.w	(a3),16(a4)
	move.w	(a3),160+16(a4)
	move.w	(a3)+,320+16(a4)
	move.w	(a5),24(a6)
	move.w	(a5),160+24(a6)
	move.w	(a5)+,320+24(a6)
	move.w	(a3),24(a4)
	move.w	(a3),160+24(a4)
	move.w	(a3)+,320+24(a4)
	move.w	(a5),32(a6)
	move.w	(a5),160+32(a6)
	move.w	(a5)+,320+32(a6)
	move.w	(a3),32(a4)
	move.w	(a3),160+32(a4)
	move.w	(a3)+,320+32(a4)
	move.w	(a5),40(a6)
	move.w	(a5),160+40(a6)
	move.w	(a5)+,320+40(a6)
	move.w	(a3),40(a4)
	move.w	(a3),160+40(a4)
	move.w	(a3)+,320+40(a4)
	move.w	(a5),48(a6)
	move.w	(a5),160+48(a6)
	move.w	(a5)+,320+48(a6)
	move.w	(a3),48(a4)
	move.w	(a3),160+48(a4)
	move.w	(a3)+,320+48(a4)
	move.w	(a5),56(a6)
	move.w	(a5),160+56(a6)
	move.w	(a5),320+56(a6)
	move.w	(a3),56(a4)
	move.w	(a3),160+56(a4)
	move.w	(a3),320+56(a4)
exit_vu	rts

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
ENABLE_PLANE2	equ	yes
ENABLE_PLANE3	equ	no
ENABLE_PLANE4	equ	no

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	pic+34,a0	;alter this to move the titles down the screen
		add.w	#160*145,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

		move.w	#9-1,d0		;max titles per menu
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

********
* ISRs *
********
new_kbd	;new keyboard handler - returns GEM VDI low byte in key.w
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


new_70
	clr.b	counter		;set up raster counter
	sub.w	#2,table_offset	;raster offset
	move.l	#colours,colourspos	;reset rasters to be same every VBL
	clr.w	vsync_flag
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	music+8			;do tune
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	bsr	vu
	tst.w	zero_counter		;prevent 0 being pressed too fast
	beq.s	.no
	subq.w	#1,zero_counter
.no	clr.b	$fffffa1b.w		;stop timer B
	move.b	#80,$fffffa21.w		;start rasters on line 36
	move.l	#timerb,$120.w
	move.b	#8,$fffffa1b.w		;restart timer B
	rte


timerb
	clr.b	$fffffa1b.w		;stop timerb
	move.l	#timerb2,$120.W		;new timerb
	move.b	#3,$fffffa21.w		;do it every 3 lines
	move.b	#8,$fffffa1b.w		;restart timer B
	rte

timerb2
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.l	colourspos,a0
	move.l	col_diff,d0
	move.w	(a0,d0.l),$ffff8244.w
	move.w	(a0),$ffff8246.w
	move.w	(a0)+,$ffff8242.w	;sine wave logo and scroller
	move.l	a0,colourspos
	move.l	(sp)+,d0
	move.l	(sp)+,a0
	add.b	#1,counter
	cmp.b	#31,counter
	beq.s	.set
	rte

.set	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w	;now increase the number of times the colours change
	clr.b	counter
	move.b	#8,$fffffa1b.w
	rte



isr_off	ORI.W	#$700,SR
	move.l	old120,$120.w
	move.l	old118,$118.w
	move.l	old70,$70.w
	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda13,$FFFFFA13.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w
	MOVE.W	#$2300,SR
	rts



vsync	move.w	#-1,vsync_flag
.no	tst.w	vsync_flag
	bne.s	.no
	rts


flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts



set_up
	bsr	set_super
	bsr	save_pal
	move.b	#$12,$fffffc02.w		;no mouse
	bsr	get_base			;get screen

;remove Persistence of vision from picture
	lea	pic+34,a0
	lea	8(a0),a2
	lea	pov162,a1
	rept	11*16
	move.b	(a0),(a1)+
	clr.b	(a0)
	lea	160(a0),a0
	endr
	rept	11*16
	move.b	(a2),(a1)+
	clr.b	(a2)
	lea	160(a2),a2
	endr

;print software titles
	bsr	print_titles

	move.l	#screens,d0
	clr.b	d0
	move.l	d0,screen_base
	move.l	d0,d1
	add.l	#41984,d1
	eor.l	d0,d1
	move.l	d1,scr_xor

	move.l	screen_base,a0		;go for low rez
	bsr	set_low_rez
	bsr	set_screen		;set screen to new position

	rts


set_screen
	lea	screen_base,a6
	move.l	(a6),d6
	move.l	d6,4(a6)
	move.l	scr_xor,d0
	eor.l	d0,d6
	move.l	d6,screen_base
	lsr.l	#8,d6
	lea	$ffff8201.w,a5
	movep.w	d6,(a5)
	rts


set_super
	ifeq	DOWNLOAD
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	endc
	rts


show_pic
	lea	pic+34,a0
	move.l	screen_base,a1
	move.l	screen_base+4,a2
	move.w	#32000/4-1,d0
.loop	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.loop
	rts


user_mode
	ifeq	DOWNLOAD
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	endc
	rts


save_pal
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


restore_pal
	lea	old_pal,a0
	bra.s	set_p

set_palette
	lea	pic+2,a0
set_p	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


get_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts


set_med_rez
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez
	clr.w	-(sp)
set_rez
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts


sort_isr
	ori.w	#$700,sr
	move.l	$70.w,old70
	move.l	$118.w,old118
	move.l	$120.w,old120
	move.b	$fffffa07.w,olda07
	move.b	$fffffa09.w,olda09
 	move.b	$fffffa13.w,olda13
 	move.b	$fffffa17.w,olda17
	move.b	$fffffa1b.w,olda1b
	move.b	$fffffa21.w,olda21

	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w

;************************************************************************
; CRUSADE5.MUS  -  Roller Coaster Screen in Imagination Demo
;************************************************************************
	moveq	#1,d0
	jsr	music

	move.l	#new_70,$70.W
	move.l	#new_kbd,$118.w
	move.l	#timerb,$120.W

	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	clr.b	$fffffa1b.w
	clr.b	$fffffa21.w
	move.w	#$2300,sr
	rts


	ifeq	DOWNLOAD
**************************
	SECTION DATA
**************************
	endc

vu_block
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fe00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fe00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fe00,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fe00,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fe00,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fe00,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fe00,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fe00

vu2	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$007f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$007f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$007f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$007f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$007f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$007f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$007f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$007f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f

toggle		dc.w	0	;50/60 hertz


screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"        1: SLAYTANIC CULT 5             "
	dc.b	"        2: FLIGHT - ST/STE/FALCON       "
	dc.b	"        3: WILDFIRE STE SCREEN          "
	dc.b	"        4: PHF INTRO                    "
	dc.b	"        5: DBA 7 INTRO                  "
	dc.b	"        6: DING-O BY DUNE               "
	dc.b	"        7: EDGE                         "
	dc.b	"                                        "
	dc.b	"              0: 50/60 HZ               "
	even

screen_titles_font	incbin	6x6_font.dat

table	incbin	sine.dat

	even

col_diff	dc.l	vu_colours-colours

colourspos	dc.l	colours
colours
	dc.w	$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006
	dc.w	$00e,$007,$00f,$08f,$01f,$09f,$02f,$0af,$03f
	dc.w	$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
	dc.w	$0f7,$0fe,$0f6
	dc.w	0,0	;gap between middle sine wave and scroller
	dc.w	$300,$400,$500,$600,$700,$710
	dc.w	$720,$730,$740,$750,$760,$ff0,$ff0,$671,$572
	dc.w	$473,$374,$275,$176,$077,$167,$257,$347

vu_colours	;colours for VU meters
	dc.w	$570,$570
	dc.w	$650,$650
	dc.w	$730,$730

spec_cols	;spectrum analyzer colours...
	dc.w	0,0,0,0
	dc.w	$012,$023,$034,$045,$056,$56,$045,$034,$023,$012
;titles colours
	dc.w	$020,$030,$040,$050,$060,$070,$072,$073,$074,$075
	dc.w	$076,$077,$067,$057,$046,$037,$027,$017,$007,$107
	dc.w	$206,$305,$404,$503,$602,$701
	dcb.w	12,0



	
*******************************
* scroller variables and data *
*******************************

scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b	"                          "
 dc.b "PERSISTENCE OF VISION PRESENTS DISC 162.        "
 DC.B "RELEASED DATE: 02/05/98              "
 dc.b "         CREDITS FOR THIS MENU GOTO......"
 dc.b "      CODING BY MAC SYS DATA OF P.O.V.,      MUSIC RIPPED "
 dc.b "FROM ROLLER COASTER SCREEN IN IMAGINATION DEMO BY CRUSADERS AND "
 dc.b "WAS RIPPED BY MUG UK IN JULY 1992,    ART BY OZ AND MSD.                         "
 DC.B "IF YOU ARE WATCHING THIS USING PACIFIST, THEN I WOULD LIKE "
 DC.B "TO POINT OUT THAT THIS MENU IS BEST VIEWED USING THE LINE ORIENTATED "
 DC.B "RENDER MODE.   TRY PRESSING THE KEY ABOVE THE TAB THEN PRESS F1 UNTIL "
 DC.B "THE WORD   LINE   IS HIGH LIGHTED.  NOW PRESS   G   AND HIT   RETURN.       "
 dc.b "THE SCROLLER IS NICE AND SMOOTH ON THE ST BUT LOOKS JERKY ON MY PENTIUM 133. "
 dc.b "      I HOPE YOU ALL APPRECIATE THE DEMOS ON THIS DISK.  AS ALWAYS THE ROGGIE "
 DC.B "DEMOS ARE ALWAYS FILLED WITH GOOD MUSIC.    I HAVE PUT A COUPLE OF SINGLE "
 DC.B "SCREENS ON HERE AS I DO NOT THINK MANY PEOPLE WILL HAVE SEEN THEM.      "
 DC.B "         IF YOU WANT TO WRITE TO POV, PLEASE E-MAIL ME AT      "
 DC.B "    POV@FATAL-DESIGN.COM               "
 DC.B "WELL I HAVE NOTHING ELSE TO SAY SO PRESS ONE OF THOSE KEYS..... "
 DC.B "                                          "
 DC.B "                                                "
 dc.b "                                                "
 DC.B $ff
	even

char_offset	dc.w	0
font	dcb.b	23*4,0
	incbin	font.dat

*
* This FONT_OFFSET refers to the FONT.PI1 pic.
* Each line in the PIC has 10 characters on it numbered
*  1-10
* 11-20
* 21-30
* 31-40
*     The table below set the ASCII character to the position
*     on the pic. It allows you to have the FONT.PI1 in any order.
*
*     Use the NIK_FONT.S to remove the font from the FONT.PI1
*
*	Using the table you can also have characters pointing to
*	more than one character, e.g. ALL brackets ()[]{} point to ( and )
*
*	OR you can draw a logo in the FONT.PI1 and make some characters
*	point to the logo, e.g xyz (lower case)...
*
*			All 0 make character a space.
*

font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,44,43,00,45,00,42,51,46,47,00,00,49,52,48,29

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	41,31,32,33,34,35,36,37,38,39,59,58,00,00,00,43,53

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,11,12,13,14,15,16,17,18

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	19,21,22,23,24,25,26,27,28,46,00,47,00,47,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,11,12,13,14,15,16,17,18,19,21,22,23

;        v  w  x  y  z  {  |  }  ~
 dc.b	24,25,26,27,28,46,00,47,00

	even
music	incbin crusade5.mus
pic	incbin	pov162.PI1

spec_data	incbin	SPECTRUM.DAT
spec_values	dcb.w	MAX_BARS,0

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"$$cult5.prg",0
	even
exec2	dc.b	"flight.prg",0
	even
exec3	dc.b	"ste.prg",0
	even
exec4	dc.b	"phfintro.prg",0
	even
exec5	dc.b	"dba7.prg",0
	even
exec6	dc.b	"ding_o.prg",0
	even
exec7	dc.b	"edge.prg",0
	even
exec8	dc.b	"copier.pov",0
	even
exec9	dc.b	"filename.ext",0
	even


	ifeq	DOWNLOAD
	SECTION BSS
	endc
bssstart

screen_base	ds.l	1
		ds.l	1
scr_xor		ds.l	1
stack_save	ds.l	1
old70		ds.l	1
old118		ds.l	1
old120		ds.l	1
olda07		ds.l	1
zero_counter	ds.w	1
key		ds.w	1
olda09		ds.b	1
olda13		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
counter		ds.b	1
table_offset	ds.w	1
black_pal	ds.w	16
vsync_flag	ds.w	1
old_base	ds.l	1
old_pal		ds.b	32

pov162		ds.b	16*22

	ds.l	100
ustack	ds.l	1

	ds.b	256
screens	ds.b	32000
	ds.b	32000


bssend

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
