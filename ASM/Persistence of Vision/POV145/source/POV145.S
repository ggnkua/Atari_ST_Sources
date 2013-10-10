*************************************************************************
*			PERSISTENCE OF VISION 145			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music by:	Lotus of Eternity					*
*									*
*									*
* Grafix by: 	Machine System Data					*
*									*
*									*
* Date:		6-APR-1994						*
*									*
*									*
*			½ Persistence Of Vision 1994			*
*									*
*************************************************************************
yes=1
no=0
YES=yes
NO=no
		opt	o+,w-

AUTORUN4	equ	no
FINAL		equ	no
		ifne	FINAL
		opt	d-
		endc

;***********************************************************************
		ifeq	AUTORUN4
begin		bra	start
		ds.b	100
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

		move	#$ff,d0
		jsr	music
		jsr	music+22

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
offset_down_scr	equ	160*2
depth		equ	8
plane		equ	0		;0,1,2,3
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
		lea	(plane*2)+offset_down_scr(a0),a0
		moveq	#0,d0		;clear area of last text
		move.w	#3-1,d1	;number of lines of text
.clear		rept	depth
		move.w	d0,(a0)
		move.w	d0,8(a0)
		move.w	d0,16(a0)
		move.w	d0,24(a0)
		move.w	d0,32(a0)
		move.w	d0,40(a0)
		move.w	d0,48(a0)
		move.w	d0,56(a0)
		move.w	d0,64(a0)
		move.w	d0,72(a0)
		move.w	d0,80(a0)
		move.w	d0,88(a0)
		move.w	d0,96(a0)
		move.w	d0,104(a0)
		move.w	d0,112(a0)
		move.w	d0,120(a0)
		move.w	d0,128(a0)
		move.w	d0,136(a0)
		move.w	d0,144(a0)
		move.w	d0,152(a0)
		lea	160(a0),a0
		endr
		lea	160(a0),a0
		dbf	d1,.clear
		move.w	#1,cursor
		clr.l	ypos
		rts

.do		tst.w	delay_timer
		beq.s	.no_delay
		sub.w	#1,delay_timer
		rts
.no_delay	move.l	ascii_pos,a0
.rep		moveq	#0,d0
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
		add.l	#(depth+1)*160,ypos
		clr.w	byte_offset
		clr.w	xpos
		move.l	a0,ascii_pos
		rts

.notcr		cmp.b	#15,d0
		bne.s	.not_end
		moveq	#0,d0
		move.b	(a0)+,d0		;get delay length
		move.w	d0,enable_text
		move.l	a0,ascii_pos
		rts

.not_end	cmp.b	#11,d0		;delay
		bne.s	.no_set_delay
		move.w	#10,delay_timer
		move.l	a0,ascii_pos
		rts

.no_set_delay	cmp.b	#12,d0		;del
		bne	.ok
		move.l	scr_now,a1
		add.l	ypos,a1
		add.w	byte_offset,a1
		move.w	xpos,d0		;clear char to right of cursor
		and.w	#$ff,d0
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		add.w	d0,a1
		moveq	#0,d0
offset		set	(plane*2)+offset_down_scr
		rept	depth
		move.b	d0,offset(a1)
offset		set	offset+160
		endr
		sub.w	#1,xpos
		eor.w	#1,byte_offset
		move.l	a0,ascii_pos
		rts

.ok		move.l	a0,ascii_pos
		cmp.b	#9,d0		;tab
		bne.s	.no_tab
		move.w	xpos,d0		;get present position
		divu	#8,d0		;divide by 8 to get present tab
		add.w	#1,d0		;increase
		lsl.w	#3,d0		;*8
		move.w	d0,xpos		;bung it back
		clr.w	byte_offset
		bra	.rep

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
		add.l	ypos,a1
		add.w	d0,a1
offset	set	(plane*2)+offset_down_scr
		rept	depth
		move.b	(a0)+,offset(a1)
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
		add.l	ypos,a1
		add.w	d0,a1
		eor.b	#-1,(plane*2)+offset_down_scr+((depth-2)*160)(a1)
		eor.b	#-1,(plane*2)+offset_down_scr+((depth-1)*160)(a1)
.no_curs	rts





SCROLL_DEPTH	equ	32

scroll	move.l	scr_now,a1
	add.l	#160*229,a1
	lea	font_offsets,a2		;font lookup table
	lea	big_font,a3		;font itself
	move.l	scroll_pointer,a4	;pointer into text
	move.l	a4,a5

	moveq	#40,d5			;40 words across screen
	move.w	char_offset,d6		;char offset is a toggle
					;for bytes/words
	moveq	#0,d4
next_char
	move.b	(a5),d7			;get a letter
	sub.b	#32,d7			;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0	;find correct offset
	mulu	#8*SCROLL_DEPTH,d0	;8 bytes wide * DEPTH
	add.w	d0,a0		;add to font start
	move.w	d6,d0		;char offset
	lsl.w	#5,d0		;*DEPTH
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
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#7,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#7,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)		;is scroll text end?
	bpl.s	.end		;NO!
	lea	scroll_text,a4	;reset scroll text
.end	move.l	a4,scroll_pointer
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

		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		lea	black,a1
		bsr	fade

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		lsr.l	#8,d0
		lea	$ffff8201.w,a0
		movep.w	d0,(a0)


********* Do the intro ********************************
		moveq	#1,d0
		jsr	intro_music
		move.l	#intro_music+16,$4d2.w
		movem.l	inpic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		bsr	infinity_intro
		lea	black,a1
		bsr	fade
		lea	scrspc,a0
		move.l	#bssend-scrspc,d0
		lsr.w	#2,d0
.clear		clr.l	(a0)+
		sub.l	#1,d0
		bne.s	.clear
		clr.l	$4d2.w
		move.l	#$8080000,$ffff8800.w
		move.l	#$9090000,$ffff8800.w
		move.l	#$a0a0000,$ffff8800.w
*******************************************************

;init fade route by sorting pic to show and black pal
		movem.l	pic+2,d0-d7	;get pal
		movem.l	d0-d7,-(sp)	;store
		movem.l	black,d0-d7	;get black
		movem.l	d0-d7,pic+2	;make pic pal black
		movem.l	(sp)+,d0-d7	;get read pal off store
		movem.l	d0-d7,black	;put in black
; the fade rout later on will allow pic pal to fade in whilst isr's are running
;

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
		clr.b	$fffffa1d.w
		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w
		bclr	#3,$fffffa17.w

		MOVEQ	#0,D0
		jsr	music
		jsr	music+18

		move.l	#timerb_part1,$120.w
		move.l	#newvbl,$70.w
		move.l	#newkbd,$118.w
		ori.b	#1,$fffffa07.w
		ori.b	#1,$fffffa13.w
		move.w	#$2300,sr

		lea	pic+34,a0
		move.l	scr_now,a1
		lea	160*28(a1),a1
		move.l	a1,a2
		add.l	#49152,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show


		lea	black,a1
		move.w	#7,d6
		move.l	a1,a2
.next_value	lea	pic+2,a0
		move.w	#16-1,d7
.loop		bsr	modify
		add.w	#2,a0
		add.w	#2,a1
		dbf	d7,.loop
		move.w	#6-1,d2
.dosync		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		dbf	d2,.dosync
		move.l	a2,a1
		dbf	d6,.next_value

		lea	black,a0
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)
		rts


timerb_part1	clr.b	$fffffa1b.w
		move.l	#border_timerb,$120.w
		move.b	#1,$fffffa21.w
 		bclr	#5,$fffffa15.w		;disable TIMERC for music
		move.b	#8,$fffffa1b.w
		rte

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
		sub.b	#$62,d0
		add.w	d0,a0
		jmp	(a0)
.nops		REPT	$62
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

		lea	colours+2,a0
		rept	32
		move.w	(a0)+,$ffff8242.w
		dcb.w	124,$4e71
		endr
		move.l	(sp)+,a0
		clr.w	$ffff8242.w
		rte


newvbl		move.w	#$2700,sr
		bset	#5,$fffffa15.w		;enable TIMERC for music
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

		clr.w	vsync_flag
		clr.b	$fffffa1b.w
		move.l	#timerb_part1,$120.w
		move.b	#227,$fffffa21.w
		move.b	#8,$fffffa1b.w
		move.l	a0,-(sp)
.wait		cmp.b	#$10,$ffff8209.w
		blo.s	.wait
		dbt	d0,*
		dbt	d0,*
		lea	.nops(pc),a0
		moveq	#0,d0
		move.b	$ffff8209.w,d0
		sub.b	#$10,d0
		add.w	d0,a0
		jmp	(a0)
.nops		REPT	$5a
		nop
		ENDR
		dbt	d0,*
		dbt	d0,*

		move.l	a6,-(sp)
		lea	colours2,a6	;colour text printer in
		rept	27
		move.w	(a6)+,$ffff8242.w
		dcb.w	124,$4e71
		endr
		move.w	pic+4,$ffff8242.w
		move.l	(sp)+,a6
		move.l	(sp)+,a0
		move.w	(sp)+,d0

		movem.l	d0-a6,-(sp)
		bsr	text_printer
		bsr	scroll
		jsr	music+26
		movem.l	(sp)+,d0-a6
		tst.w	hertz_delay
		bne.s	.dec
		rte
.dec		sub.w	#1,hertz_delay
		rte


newkbd		movem.l	d0,-(sp)
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



;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade		move.w	#7,d6
		move.l	a1,a2
next_value	lea	$ffff8240.w,a0
		move.w	#16-1,d7
.loop		bsr	modify
		add.w	#2,a0
		add.w	#2,a1
		dbf	d7,.loop
		bsr	v_sync3
		bsr	v_sync3
		move.l	a2,a1
		dbf	d6,next_value
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
blue_dn		subq	#1,d4
blue_ok		move.w	d0,d2
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



*************************************************************************
* INFINITY DEVELOPMENTS intro.............
infinity_intro
		lea	routine_list,a0
do_routines	tst.l	(a0)
		bmi.s	.wait
		move.l	(a0)+,a1
		move.l	a0,-(sp)
		jsr	(a1)
		move.l	(sp)+,a0
		bra.s	do_routines
.wait		move.w	#5000,d7
.key		move.w	#$b,-(sp)
		trap	#1
		addq.l	#2,sp
		tst.l	d0
		bmi.s	.yes
		sub.l	#1,d7
		bne.s	.key
		bra.s	.ok
.yes		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		move.w	#$b,-(sp)
		trap	#1
		addq.l	#2,sp
		bmi.s	.yes
.ok		rts
show_twinkle	lea	dat1,a0
		move.w	#10-1,d0
.loop		bsr	v_sync3
		move.l	scr_now,a1
		add.w	#160*57+8,a1
		REPT	26
		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		lea	160(a1),a1
		ENDR
		dbf	d0,.loop
		move.w	#6,d0
.delay		bsr	v_sync2
		dbf	d0,.delay
		rts
draw_triangle	lea	triangle+8+(7*8*12),a0
		move.l	scr_now,a1
		add.w	#70*160+16,a1
		move.l	#%10000000000000001000000000000000,d7
		move.w	#16-1,d0
.bits		bsr	v_sync
		move.l	(a0),d1
		move.l	4(a0),d2
		and.l	d7,d1
		and.l	d7,d2
		move.l	d1,(a1)
		move.l	d2,4(a1)
		move.l	d7,d6
		lsr.l	#1,d7
		or.l	d6,d7
		dbf	d0,.bits
		add.w	#8,a0
		add.w	#8,a1
		move.w	#5-1,d5
.words		move.l	#%11000000000000001100000000000000,d7
		move.w	#8-1,d0
.bits2		bsr	v_sync
		move.l	(a0),d1
		move.l	4(a0),d2
		and.l	d7,d1
		and.l	d7,d2
		move.l	d1,(a1)
		move.l	d2,4(a1)
		move.l	d7,d6
		lsr.l	#1,d7
		or.l	d6,d7
		lsr.l	#1,d7
		or.l	d6,d7
		dbf	d0,.bits2
		addq	#8,a0
		addq	#8,a1
		dbf	d5,.words
		lea	8*13(a1),a1
		bsr	v_sync2
		move.w	#3-1,d5
.x1		bsr	v_sync2
		REPT	7
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		ENDR
		lea	8*13(a1),a1
		dbf	d5,.x1
		move.w	#4-1,d5
.x2		bsr	v_sync2
		REPT	7
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		ENDR
 		lea	8*13(a1),a1
		REPT	7
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		ENDR
		lea	8*13(a1),a1
		dbf	d5,.x2
		move.w	#84/3-1,d0
.down		bsr	v_sync2
		REPT	3
		movem.l	(a0)+,d1-d7/a2-a6
		movem.l	d1-d7/a2-a6,(a1)
		lea	12*4(a1),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		lea	8*13(a1),a1
		ENDR
		dbf	d0,.down
		rts
split_triangle	lea	dat3,a0
		move.w	#9-1,d0		;9 frames
.loop		bsr	v_sync3
		move.l	scr_now,a1
		add.w	#160*58+40,a1
		REPT	60
		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		lea	160(a1),a1
		ENDR
		dbf	d0,.loop
		rts
bounce_ball	lea	bounce_table,a2
.bounce		bsr	v_sync
		lea	dat3+(8*24*60),a0
		move.l	scr_now,a1
		add.w	#160*58+40,a1
		REPT	8
		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		lea	160(a1),a1
		ENDR
		lea	inpic+34+(8*3)-160*6,a3
		lea	ball,a0
		move.l	scr_now,a1
		add.w	#8*3,a1
		sub.w	#39*160,a1
		move.w	(a2)+,d4
		bmi	.stop
		and.l	#$ff,d4
		mulu	#160,d4
		add.w	d4,a1
		add.w	d4,a3
		lea	ball,a0
		REPT	33
		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		lea	160(a1),a1
		ENDR
		REPT	12
		move.l	(a3),d1
		or.l	(a0)+,d1
		move.l	d1,(a1)
		move.l	4(a3),d1
		or.l	(a0)+,d1
		move.l	d1,4(a1)
		move.l	8(a3),d1
		or.l	(a0)+,d1
		move.l	d1,8(a1)
		move.l	12(a3),d1
		or.l	(a0)+,d1
		move.l	d1,12(a1)
		move.l	16(a3),d1
		or.l	(a0)+,d1
		move.l	d1,16(a1)
		move.l	20(a3),d1
		or.l	(a0)+,d1
		move.l	d1,20(a1)
		lea	160(a1),a1
		lea	160(a3),a3
		ENDR
		dbf	d0,.bounce
.stop		rts
flash_ball	lea	flash,a0
		lea	flash_pals,a3
		move.w	#4-1,d0
.loop		bsr	v_sync3
		move.l	(a3)+,$ffff8240+2.w
		move.l	(a3)+,$ffff8240+6.w
		move.l	(a3)+,$ffff8240+10.w
		move.l	(a3)+,$ffff8240+14.w
		move.l	scr_now,a1
		add.w	#2*8,a1
		REPT	65
		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,28(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,36(a1)
		lea	160(a1),a1
		ENDR
		dbf	d0,.loop
		move.l	inpic+4,$ffff8240+2.w
		move.l	inpic+8,$ffff8240+6.w
		move.l	inpic+12,$ffff8240+10.w
		move.l	inpic+16,$ffff8240+14.w
		rts
fade_infinity	lea	infinity_text,a0
		move.w	#6-1,d0
.loop		bsr	v_sync3
		move.l	scr_now,a1
		lea	160*92+(8*8)(a1),a1
		REPT	54
		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,28(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,36(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,44(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,52(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,60(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,68(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,76(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,84(a1)
		lea	160(a1),a1
		ENDR
		dbf	d0,.loop
		rts
v_sync3		bsr	v_sync
v_sync2		bsr	v_sync
v_sync		movem.l	d0-d3/a0-a3,-(sp)
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		movem.l	(sp)+,d0-d3/a0-a3
		rts
routine_list	dc.l	show_twinkle
		dc.l	draw_triangle
		dc.l	split_triangle
		dc.l	bounce_ball
		dc.l	flash_ball
		dc.l	fade_infinity
		dc.l	-1

*******************
   SECTION DATA
*******************

intro_music	incbin	bioload.mus	;blip blopper music by OZ of POV
inpic		incbin	in.pi1
dat1		incbin	1.dat
triangle	incbin	2.dat
dat3		incbin	3.dat
ball		incbin	ball.dat
bounce_table	dc.w	0,1,2,4,6,8,10,12,14,17,20,23,27,30,33,36
		dc.w	40,44,48,52,56,60,64,60,56,52,48,44,40,36
		dc.w	33,30,27,24,21,18,16,14,12,10,8,7,6,5,4,3,2,2,3
		dc.w	4,5,6,8,10,12,14,17,20,23,27,30,33,36
		dc.w	40,44,48,52,56,60,64,60,56,52,48,45,42,40
		dc.w	38,37,36,35,34,34,34,34,35,35,36,37,38,40
		dc.w	42,44,48,52,56,60,64,61,58,56,54,53,52,51,50
		dc.w	49,48,47
		dc.w	-1
flash		incbin	flash.dat
flash_pals	dc.w	$666,$666,$666,$666,$666,$667,$767,$767
		dc.w	$545,$545,$546,$656,$656,$657,$767,$767
		dc.w	$334,$434,$435,$535,$546,$647,$757,$757
		dc.w	$213,$313,$314,$425,$536,$637,$747,$757
infinity_text	incbin	in_fade1.dat
		incbin	In_fade2.dat






pic	incbin	"pic.pi1"

music	incbin	bubble.mus



; 13=next line
; 15,xx=end of line,xx=delay length
; 12=del char
; 11=delay

;NOTE:   THE ROUTINE SUPPORTS TAB!!!
ascii_pos	dc.l	init_ascii
;                123456789012345678901234567890123456789	39 CHARS ONLY
init_ascii
	dc.b	13,"     INFINITY DEVELOPMENTS PRESENTS"
		dc.b	12,12,12,12,12,12,12,12,12,12,12,12,12,12,12
		dc.b	12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12
ascii	dc.b	   13,"     PERSISTENCE OF VISION PRESENTS",15,100

	dc.b	" abbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc",13
	dc.b	" h      DEMO COMPILATION DISC 145     d",13
	dc.b	" gffffffffffffffffffffffffffffffffffffe",15,100
	dc.b	"	   CODED BY MAC SYS DATA",13
	dc.b	"	  ART BY OZ USING HIS MAC",13
	dc.b	"	       MUSIC BY LOTUS",15,100,13
	dc.b	"  1: COREFLAKES DEMO (PARTS STE ONLY)",13
	dc.b	" NEEDS 1 MEG RAM AND NO SOUND ON STFM.",15,200
	dc.b	"DUE TO A BUG IN THE ORIGINAL COREFLAKE",13
	DC.B	"  DEMO YOU COULD NOT RUN THE END PART",13
	DC.B	"    UNLESS YOU HAD MORE THAN 1 MEG.",15,100
	DC.B	" TO GET AROUND THIS PROBLEM 1 HAVE MADE",13
	DC.B	"   IT POSSIBLE TO SEE ALL PARTS OF THE",13
	DC.B	" DEMO BY PRESSING F1-F5. THIS INCLUDES",15,100
	DC.B	"ALL THE HIDDEN SCREENS. THE ONLY DRAW",13
	DC.B	" BACK IS THAT YOUR ST MAY RESET AFTER",13
	DC.B	" EACH PART. IF ANY PART FAILS TO LOAD",15,100,13
	DC.B	"  SIMPLY TURN YOUR ST OFF/ON AND TRY",13
	DC.B	"	  AGAIN FROM THIS MENU.",15,100
	dc.b	"F1=MAIN MENU     F2=COLOR HIDDEN SCREEN",13
	dc.b	"       F3=FIREWORK HIDDEN SCREEN",13
	dc.b	"F4=LIGHT HIDDEN SCREEN      F5=END PART",15,200,13,13
	dc.b	"	    2: T.R.S.I INTRO",15,200,13,13
	dc.b	"	     3: ZUUL MENU 69",15,200,13,13
	dc.b	"	  4: PURE ENERGY MENU 36",15,200,13,13
	dc.b	"		5: COPIER",15,100,13
	dc.b	"            WARP................",12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,"RAP.......",13
	dc.b	"iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii",15,100

	dc.b	-1
		even

font	incbin	8X8_comp.FNT




scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "                                                 "
 dc.b "PERSISTENCE OF VISION DISK 145.       "
 DC.B "READ THE TOP TEXT FOR SOME IMPORTANT INFO REGARDING THE COREFLAKE DEMO.         "
 DC.B "CREDITS FOR THIS DISK ARE AS FOLLOWS....   CODING BY MAC SYS DATA, "
 DC.B "   GRAFIX BY  OZ (DRAW ON MAC LC 2),   MUSIC BY LOTUS OF ETERNITY.       "
 dc.b "    PLEASE NOTE:   DO NOT SEND ANY MAIL TO THE POV PO BOX AS IT "
 DC.B "IS TO BE DISCONTINUED VERY SOON.             "
 DC.B "I MAY AS WELL TELL YOU NOW THAT PERSISTENCE OF VISION COMPILATIONS "
 DC.B "ARE SLOWLY TO BE PHASED OUT, YES WE (WELL I MAC SYS DATA) HAVE "
 DC.B "FINALLY DECIDED TO GIVE THE DEMO COMPILATION DISC MAKING UP.  AFTER "
 DC.B "7 YEARS OF DISC MAKING I FEEL IT IS TIME TO STOP. THE ST SCENE "
 DC.B "IS NOW DIED, ALL OF THE ORIGINAL CREWS HAVE ALREADY LEFT FOR "
 DC.B "THE SUNNIER AMIGA/SNES/FALCON SCENE AND SO WE WILL RELUCTANTLY "
 DC.B "FOLLOW.  POV DISC 150 WILL BE OUR LAST MAIN STREAM DISC, I WILL "
 DC.B "CONTINUE TO RELEASE SOME POOR QUALITY COMPILATIONS TO USE UP "
 DC.B "THE DEMOS I HAVE ALREADY PACKED, SOME OF THEM WERE PACKING IN "
 DC.B "1991!!!!      I WILL STILL SUPPORT ALL MY CONTACT BUT WON'T "
 DC.B "BE ABLE TO SEND ANY MORE POV COMPILATIONS.          I AM "
 DC.B "STARTING TO DO MORE WORK ON THE AMIGA SO YOU MAY SEE A POV "
 DC.B "INTRO APPEARING SOON.      BORIS OF POV HAS ALREADY WRITTEN "
 DC.B "SEVERAL COMMERCIAL GAMES ON THE AMIGA BUT IS NOW WORKING ON "
 DC.B "THE SNES, MEGADRIVE AND MEGA-CD.  IN THE NEAR FUTURE I "
 DC.B "WILL BE BUYING A DECENT 486 PC SO I TOO CAN START USING "
 DC.B "SNASM AND THE PDS SYSTEM TO WRITE FOR THE SNES.  "
 DC.B "I WILL HAVE TO RELEASE A FEW MORE OZ SLIDESHOWS AS I HAVE "
 DC.B "2.7 MEG OF PC1 PICTURES ALL DRAWN BY OZ, SOME OF THE PICTURES "
 DC.B "ALSO DATE BACK TO 1990!   I ALSO HAVE 1.2 MEG OF MODULES WRITTEN "
 DC.B "BY OZ SO LOOK FORWARD TO SOME SERIOUS MOD/PICTURE DISCS!!! "
 DC.B "    WELL ENOUGH OF THIS SAD TALK, LETS GO FOR IT.....   YES THE GREETINGS!   "
 dc.b "      GREETINGS TO    "
 DC.B "ANIMAL MINE (DEAD OR WHAT?),     "
 DC.B "MUG U.K. (HOW'S THE AMIGA AND PC? WHERE ARE MY HD DISCS??,     "
 DC.B "PURE ENERGY (MORE MENU CODING TIME FOR YOU BOYS!!),     "
 DC.B "DIGIT OF TSN,     "
 DC.B "ANNHILATOR/EDGE OF SANITY,     "
 DC.B "SERENADE,     "
 DC.B "ADRENALIN UK (WHERE ARE THE MOD DISCS BOYS?)     "
 DC.B "AND    ALL MY CONTACT AND FRIENDS.                  "
 dc.b "WHEN YOU RUN THE COREFLAKES DEMO, TRY PRESSING THE C KEY AND "
 DC.B "CONTROL KEY. AT THE END OF THE DEMO IT WILL GOTO A COUPLE OF "
 DC.B "HIDDEN SCREENS.          "
 DC.B "IF YOU WANT TO CONTACT ME (MAC SYS DATA) PLEASE DO NOT WRITE TO THE "
 DC.B "PO BOX BUT WRITE TO TOWER PD AT HIS HOME ADDRESS. I WILL RELEASE MY "
 DC.B "HOME ADDRESS NEAR IN THE FUTURE AS SOON AS I MOVE INTO MY NEW "
 DC.B "HOUSE.                  OH WELL MUST GO, I HAVE TO START THINGING "
 DC.B "OF IDEAS FOR POV 150........      BYE  MSD 6-APR-1994 (MY BIRTHDAY - "
 dc.b "I'M 27 YEARS OLD!!!!).           "
 DC.B "                                                                 "
 DC.B "                                                           WRAP           "
 dc.b $ff
	even


big_font	incbin	big_font.fnt

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


colours2
 dc.w	0
 dc.w	$f0f,$70f,$e0f,$60f,$d0f,$51f,$c9f,$42f,0,$baf,$33f,$abf,$24f,$9cf,$15f,$8df,$06f
 dc.w	0,$0ef,$07f,$0ff,$077,$0ee,$066,$0dd,$055


demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5

	dc.b	5, $3b		;F1 key
	dc.b	6, $3c		;F2 key
	dc.b	7, $3d		;F3 key
	dc.b	8, $3e		;F4 key
	dc.b	9, $3f		;F5 key

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9,exec10
exec1	dc.b	"shrimp",0
	even
exec2	dc.b	"T_R_S_I",0
	even
exec3	dc.b	"ZUUL_69",0
	even
exec4	dc.b	"pe36",0
	even
exec5	dc.b	"copier.pov",0
	even
exec6	dc.b	"shrimp",0
	even
exec7	dc.b	"color.n_c",0
	even
exec8	dc.b	"firework.n_c",0
	even
exec9	dc.b	"light.n_c",0
	even
exec10	dc.b	"end.n_c",0
	even



*******************
   SECTION BSS
*******************
bss
hertz_toggle	ds.w	1
char_offset	ds.w	1
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_pal		ds.w	16
scr_now		ds.l	1
black		ds.w	16

xpos		ds.w	1
ypos		ds.l	1
byte_offset	ds.w	1
cursor		ds.w	1
enable_text	ds.w	1
delay_timer	ds.w	1
hertz_delay	ds.w	1
storage		ds.b	20
vsync_flag	ds.w	1
key		ds.b	1
	even
scrspc		ds.b	256
		ds.b	160*39
screens		ds.b	49152
bssend