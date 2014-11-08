*************************************************************************
*		Persistence Of Vision Compilation 164 Source 		*
*		--------------------------------------------		*
*									*
*									*
* Written by:	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
* 	Date:	April 1999						*
*									*
*									*
*									*
*									*
*									*
*									*
*************************************************************************
	opt	o+,w-
yes=1
YES=yes
no=0
NO=no

DOWNLOAD	equ	no
FINAL=yes
NO_BOBS=6

		ifne	DOWNLOAD
		include	TRANSMIT.S
		org	$20000
Code_Start
Exec_Addr
		endc

************************************************************************
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

	pea	reset
	move.w	#$26,-(sp)
	trap	#14

reset		move.l	4.w,-(sp)
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

		bsr	set_up

main_loop	bsr	vsync
		bsr	set_screen	;screen flip
;		move.w	#$321,$ffff8240.w

	bsr	bobs
	bsr	scroll

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

	tst.w	hertz_toggle
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50

assem
	move.w	#$2700,sr
	lea	storage,a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa13.w
	lea	$ffff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)	
	move.w	#$2300,sr

		bsr	set_old_palette

		move.w	original_rez,-(sp)
		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

	move.b	#$8,$fffffc02.w

		ifeq	DOWNLOAD
		bsr	set_user
		endc

		ifne	DOWNLOAD
		move.l	4.w,-(sp)
		rts
		endc

	ifne	FINAL
		bra	exec
	endc

	ifeq	FINAL
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






************************************************************************
bobs
		lea	last_bob_pos,a3
		add.w	donkey,a3
		move.l	scr_now,a6
		lea	pic+34,a5
		rept	NO_BOBS
		move.w	(a3)+,d0
		move.l	a6,a1
		add.w	d0,a1
		move.l	a5,a0
		add.w	d0,a0

;return space where bob last was
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1

		endr

		lea	last_bob_pos,a3
		add.w	donkey,a3
		rept	NO_BOBS
		lea	bobspace,a1
		bsr.s	do_bobs
		endr
		eor.w	#NO_BOBS*2,donkey
		move.w	bob_tab_offset,d0
		addq.w	#4,d0
		move.w	d0,bob_tab_offset
		move.w	d0,vbl_bob_tab_offset
		rts
do_bobs
		lea	bob_tables,a0
		move.w	vbl_bob_tab_offset,d1
		add.w	bob_spacing,d1
		move.w	d1,vbl_bob_tab_offset
		and.w	#4095,d1
		add.w	d1,a0	;a0 now points to position in sine wave table
		moveq	#0,d0
		move.l	d0,d1
		move.l	d1,d2
		move.w	(a0)+,d0	;x
		move.w	(a0)+,d1	;y
		move.w	d0,d2
		lsr.w	#1,d0
		and.w	#$1f8,d0
		and.w	#15,d2
		mulu	#31*32*2,d2
		add.w	d1,d0

		move.l	scr_now,a0
		add.w	d0,a0
		move.w	d0,(a3)+	;store bob pos for clearing later
		add.w	d2,a1
		lea	32*31(a1),a2
		REPT	31
		move.l	(a2)+,d3	;mask
		move.l	(a2)+,d4	;mask
		move.l	(a2)+,d5	;mask
		move.l	(a2)+,d6	;mask
		move.l	(a0),d0		;get scrn data
		and.l	d3,d0		;AND mask
		or.l	(a1)+,d0	;OR gfx
		move.l	d0,(a0)+	;put back to scrn
		move.l	(a0),d0
		and.l	d3,d0	;AND mask
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	d4,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	d4,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	d5,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	d5,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+

		move.l	(a0),d0
		and.l	d6,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		move.l	(a0),d0
		and.l	d6,d0
		or.l	(a1)+,d0
		move.l	d0,(a0)+
		lea	160-32(a0),a0
		ENDR
		rts



; 8 pixel every VBL scroller
scroll	move.l	scr_now,a1
	add.l	#160*201,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	moveq	#0,d4
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









***********************
* SUBROUTINES SECTION *
***********************
v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

vsync	move.w	#-1,vsync_flag
.tst	tst.w	vsync_flag
	bne.s	.tst
	rts

tst_key	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts


set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


set_old_palette
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts




***********************ISRs******************
vbl		movem.l	d0-d7/a0-a6,-(sp)
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		jsr	music+4
		movem.l	(sp)+,d0-d7/a0-a6
		clr.w	vsync_flag
		move.l	#colours,pal_pos
		clr.b	$fffffa1b.w
		move.l	#timerb,$120.w
		move.b	#198,$fffffa21.w
		move.b	#8,$fffffa1b.w
		tst.w	hertz_delay
		bne.s	.decdelay
		rte
.decdelay	sub.w	#1,hertz_delay
		rte
timerb		clr.b	$fffffa1b.w
		move.l	#border_timerb,$120.w
		move.b	#1,$fffffa21.w
; 		bclr	#5,$fffffa15.w		;disable TIMERC for music
		move.b	#8,$fffffa1b.w
		rte



border_timerb
		or.w	#$700,sr
		clr.b	$fffffa1b.w
		movem.l	d0/a0,-(sp)
.wait		cmp.b	#$60,$ffff8209.w
		blo.s	.wait
		dbt	d0,*
		dbt	d0,*
		lea	.nops(pc),a0
		moveq	#0,d0
		move.b	$ffff8209.w,d0
		sub.b	#$60,d0
		add.w	d0,a0
		jmp	(a0)
.nops		REPT	89
		nop
		ENDR
		dbt	d0,*
		dbt	d0,*
		clr.b	$ffff820a.w	;60 hertz
		nop
		move.b	#2,$ffff820a.w
		move.l	(sp)+,d0

		lea	colours+2,a0
		rept	24
		move.w	(a0)+,$ffff8242.w
		dcb.w	124,$4e71
		endr
		move.l	(sp)+,a0
		move.w	pic+36,$ffff8242.w
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







set_up
	lea	bssstart,a0
	move.l	#bssend-bssstart,d0
.clr	clr.b	(a0)+
	sub.l	#1,d0
	bne.s	.clr

		ifeq	DOWNLOAD
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		move.w	#$2700,sr

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette

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

;set up distance between bobs
		move.w	#48,bob_spacing	;distance between bobs
		move.l	scr_now,last_bob_pos

;pre shift bob
;now shift bob right by 1 pixel
		lea	bob,a0
		move.l	scr_now,a1
		move.w	#62-1,d0
.showme		move.l	(a0)+,(a1)
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
		dbf	d0,.showme

	move.l	scr_now,a6
	lea	bobspace,a1
	move.w	#16-1,d4
grab	move.l	a6,a0
	add.w	#8,a0
	move.w	#62-1,d1
her	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	move.l	16(a0),(a1)+
	move.l	20(a0),(a1)+
	move.l	24(a0),(a1)+
	move.l	28(a0),(a1)+
	lea	160(a0),a0
	dbf	d1,her

	move.l	a6,a0
	move.w	#62-1,d1	;32 deep
rotate
	sub.w	d0,d0
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)	;one extra as mask needs to be shifted into left of mask area
	sub.w	d0,d0

	roxr.w	2(a0)
	roxr.w	10(a0)
	roxr.w	18(a0)
	roxr.w	26(a0)
	roxr.w	34(a0)
	sub.w	d0,d0

	roxr.w	4(a0)
	roxr.w	12(a0)
	roxr.w	20(a0)
	roxr.w	28(a0)
	roxr.w	36(a0)
	sub.w	d0,d0
	roxr.w	6(a0)
	roxr.w	14(a0)
	roxr.w	22(a0)
	roxr.w	30(a0)
	roxr.w	38(a0)
	sub.w	d0,d0
	lea	160(a0),a0
	dbf	d1,rotate
	dbf	d4,grab

*now optimise the mask so we use the same mask for each word.
	lea	bobspace,a0
	move.w	#16-1,d0
.loop
	lea	31*32(a0),a0	;mask space
	move.l	a0,a1
	rept	31
	move.l	(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	16(a0),(a1)+
	move.l	24(a0),(a1)+
	add.w	#32,a0
	endr
	dbf	d0,.loop

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#49152,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

		moveq	#1,d0		; initialise music
		jsr	music

;setup ISRs
	lea	storage,a0
	move.l	$70.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	bclr	#3,$fffffa17.w
	move.l	#timerb,$120.w
	move.l	#newkbd,$118.w
	move.l	#vbl,$70.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.w	#$2300,sr	;en ISRs

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

		ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
		endc
pic	incbin	"pov165.pi1"
bob	incbin	bob.dat

bob_spacing	dc.w	0

bob_tables
	incbin	bob1.dat
	incbin	bob2.dat
	incbin	bob3.dat
	incbin	bob4.dat
	incbin	bob5.dat
	incbin	bob1.dat
	incbin	bob6.dat

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7

	dc.b	0, $3b		;F1 key
	dc.b	1, $3c		;F2 key
	dc.b	2, $3d		;F3 key
	dc.b	3, $3e		;F4 key
	dc.b	4, $3f		;F5 key
	dc.b	5, $40		;F6 key
	dc.b	6, $41		;F7 key

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9,exec10
exec1	dc.b	"mario.prg",0
	even
exec2	dc.b	"dentro.prg",0
	even
exec3	dc.b	"siabtro.prg",0	;1 meg
	even
exec4	dc.b	"icsintro.prg",0
	even
exec5	dc.b	"eil99inv.prg",0
	even
exec6	dc.b	"pe_uti_5.prg",0
	even
exec7	dc.b	"copier.pov",0
	even
exec8	dc.b	"firework.n_c",0
	even
exec9	dc.b	"light.n_c",0
	even
exec10	dc.b	"end.n_c",0
	even

scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b	"                          "
 dc.b "PERSISTENCE OF VISION PRESENTS DISC 165.        "
 DC.B "RELEASED DATE: 19TH JUNE 1999.              "
 DC.B "HELLO DEMO FANS THIS IS MSD BACK WITH ANOTHER POV. YOU CAN READ THIS "
 DC.B "THEN YOU MUST BE USING A REAL ATARI OR AN EMULATOR. I HAVE FOUND OUT PACIFIST "
 DC.B "DOES NOT DISPLAY THIS SCROLLER AS IT IS IN THE LOWER BORDER. MAYBE THIS "
 DC.B "ONLY OCCURS ON MY CONFIGURATION OF PACIFIST.               "
 DC.B "I HAD AN EMAIL THE OTHER DAY FROM NONE OTHER THAN OZ OF POV!    HE SAW ONE "
 DC.B "OF MY POSTING ON THE NET AND SENT ME A MESSAGE. WHILST HE WAS AVAILABLE I GOT HIM "
 DC.B "TO DRAW A NEW POV LOGO FOR 99. THE NEW LOGO APPEARS ON MY POV WEB PAGE (DETAILS LATER).    "
 dc.b "I HAVE JUST DOWNLOADED LOADS OF DEMOS OVER THE INTERNET.  I HAD "
 DC.B "NOT SEEN THE EQUINOX VECTOR ESCAPE DEMO. THIS IS A DEMO FROM 1994 BUT "
 DC.B "IT IS SOOO COOL. THE INTRO HAS THE BEST MUSIC I HAVE HEARD FOR AGES.  "
 DC.B "THE DEMO IS A BOOT LOAD, IF I CAN I WILL RIP THE MUSIC AND PUT IT ON A "
 DC.B "POV MENU.                      "
 DC.B "WELL IT IS JUNE 1999 AND I'VE JUST COME BACK FROM THE CANARY ISLANDS AFTER MY SUMMER HOLIDAY. "
 DC.B "       THIS IS MY SECOND HOLIDAY THIS YEAR AS I WENT TO AMSTERDAM IN APRIL AND I WILL BE GOING "
 DC.B "TO EDINGURGH IN SEPTEMBER.        I CANNOT HAVE TIME OFF WORK AFTER OCTOBER 1999 UNTIL JAN 2000 AS "
 DC.B "I HAVE TO WORK ON THE COMPUTER SYSTEMS AT WORK TO MAKE SURE THEY DO NOT CRASH OVER THE YEAR END CHANGE. "
 DC.B "          AT HOME I HAVE AN NT4 SERVER AND WHEN I CAN GET ROUND TO IT I WILL HAVE A LINUX SERVER UP AND RUNNING. "
 DC.B "I HAVE A PENTIUM 75MHZ PC WAITING TO BE LOADED WITH LINUX BUT I CANNOT BE BOTHERED TO GET IT WORKING "
 DC.B "AS I HAVE MORE FUN CREATING MY WEB PAGES.        MY COMPUTER ROOM NOW HAS 5 MACHINES IN IT,    4 MEG STE,  4 MEG FALCON 030,  "
 DC.B "233MHZ PENTIUM  AND  120MHZ PENTIUM.     I ALSO HAVE A SCANNER,  LASER PRINTER  AND A COLOUR INKJET PRINTER. "
 DC.B "      MY 233MHZ PENTIUM IS MY MAIN MACHINE BUT I'LL UPGRADE TO A 450MHZ SOON.  THE 233MHZ PENTIUM "
 DC.B "PC HAS 14 GIG OF STORAGE,  A 40 SPEED CD-ROM,  A READ-WRITE CD WRITER,  A DAT DRIVE  AND A ZIP DRIVE ALL CRAMMED INTO IT.  "
 DC.B "OH YEAH AND A SCSI CARD AND 56K MODEM. MY MAIN MONITOR FOR THIS MACHINE IN A 17 INCH BELINEA MODEL 50 60 70. THE MONITOR "
 DC.B "HAS BUILT IN SPEAKERS IN ADDITION TO MY 200 WATT SPEAKERS!              "
 DC.B "                                  "
 dc.b "WELL AFTER POV 163 WE GOT A SLAGGING FROM UCM DISK MAG FOR NOT BEING "
 DC.B "VERY ORIGINAL, NOT PUTTING BRAND NEW UPTO THE MINUTE STUFF ON AND BASICALLY "
 DC.B "NOT BEING AS GOOD AS ANIMAL MINE COMPILATIONS.          WHAT CAN I SAY?        "
 DC.B "I'M NOT GOING TO START A SLAGGING MATCH BUT I WOULD LIKE TO POINT OUT THAT IF "
 DC.B "THERE ARE ALL THESE TOP DOG CREWS OUT THERE MAKING NEW STUFF THEN I NEVER SEE THEM ALSO "
 DC.B "WHY DID ANIMAL MINE ASK ME TO WRITE SOME MENUS FOR THEM WHEN THEY WERE ACTIVE?          "
 DC.B "        I WOULD LIKE TO SAY THAT UCM DISK MAGS DO NOT RUN PROPERLY ON MY FALCON BUT MAGGIE "
 DC.B "ALWAYS DOES (HI FELICE).                         "
 DC.B "                    WELL HERE COMES THE BORING BITS...    "
 dc.b "    CREDITS FOR THIS MENU GOTO......"
 dc.b "      CODING BY MAC SYS DATA OF P.O.V.,      "
 dc.b "ART BY OZ AND MSD.                  "
 DC.B "         IF YOU WANT TO CONTACT POV, PLEASE E-MAIL ME AT      "
 DC.B "    POV@FATAL-DESIGN.COM      OR      POV@TESCO.NET            "
 DC.B "                                    "
 DC.B "                                                "
 dc.b "                                                "
 dc.b "                                                "
 dc.b "                                                "
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
pal_pos	dc.l	colours
colours
	dc.w	$000,$222,$aaa,$333,$bbb,$444,$ccc,$555,$ddd,$666
	dc.w	$eee,$777,$fff,$fff,$777,$eee,$666,$ddd,$555,$ccc
	dc.w	$444,$bbb,$333,$aaa,$222

music	incbin "sanxmix.mus"		; hacked music file
	even

		ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
		endc
bssstart
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1
storage		ds.b	16
vsync_flag	ds.w	1
key		ds.b	1
	even
hertz_delay	ds.w	1
hertz_toggle	ds.w	1
donkey		ds.w	1
vbl_bob_tab_offset	ds.w	1
bob_tab_offset	ds.w	1	;offset into bob tables
last_bob_pos
	rept	NO_BOBS*2
	ds.w	1
	endr
bobspace	ds.b	1984*16	;bob+mask
		ds.b	256
screens		ds.b	49152
		ds.b	49152

bssend
		ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
		endc
