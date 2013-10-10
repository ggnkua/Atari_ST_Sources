*****************************************************************
*				POV 50				*
*				------				*
*								*
* Written by MAC SYS DATA					*
*								*
* Assemble with GENST 2.08 or higher				*
*								*
*****************************************************************
	opt	o+,w-
BOB_OFFSET	equ	40	;alters spacing between each bob
			;must be in steps of 4
			; eg 4,8,12,16,20,24,28,32,36,40,etc...

	bsr	set_super
	move.b	#$12,$fffffc02.w
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	calc_screen
	bsr	show_dhsr
	bsr	delayed_key
	cmp.l	#"MSD!",d0
	beq.s	part2
	bsr	black_out
	bsr	digit_rout
	bsr	black_out
	bsr	clear_screen

;************************************************************************
;*                          ARCHIPELAGOS                                *
;*                          ------------                                *
;* Stolen by: MAC SYS DATA of P.O.V. 26/11/89 12:04                     *
;*      From: MEDWAY BOYS disc 14                                       *
;* Include files:-                                                      *
;*                 ARCH.IMG into TUNE                                   *
;************************************************************************

	move.b	#2,$484		;off with keyclick/bell

;****************************************************************
; There is more than one tune in this code....
; 0=jingle 0
; 1=jingle 1
; 2=jingle 2
; 3=tune 3
; 4=tune 4 ;OK
; 5=tune 5
; 6=tune 6
; 7=tune 7
; 8=tune 8
; 9=tune 9
; A=tune 10
; B=tune 11
; C=tune 12
	move.l	#5,D0
	jsr	tune
	move.l	#tune+$e,$4da		;use VBL to play tune

	bsr	screen_rout
	bsr	endmus

***************************
*        P.O.V. 50 part 2 *
*        ---------        *
* WRITTEN BY MAC SYS DATA *
***************************
part2	jsr	black_out
	bsr	clear_below_screen
	bsr	flush
	move.b	$484,old484
	clr.b	$484

;set up bobs
	bsr	shift_bobs
	move.w	#BOB_OFFSET,d0
	lea	bob_5,a0
	move.l	present_table,a1
	move.l	a1,(a0)
	add.w	d0,a1
	move.l	a1,-6(a0)
	add.w	d0,a1
	add.w	d0,a1
	move.l	a1,-12(a0)
	add.w	d0,a1
	move.l	a1,-18(a0)
	add.w	d0,a1
	move.l	a1,-24(a0)

;************************************************************************
;*                         LEAVIN TERRAMIS                              *
;*                         ---------------                              *
;* Stolen by: MAC SYS DATA of P.O.V. 1/4/91 17:50                       *
;*      From: AUTOMATION disc 279                                       *
;* Include files:-                                                      *
;*                 terra.IMG into TUNE                                  *
;************************************************************************
; MAD MAXXXX!!!

;****************************************************************
; There is more than one tune in this code....
; 0=off with music
; 1=AUTOMATION 279

	move.l	#1,D0
	jsr	tune50

	bsr	bobs
	bsr	show_pov50_pic
	bsr	set_pov50_palette
	bsr	set_for_border
	bsr	flush
main_loop:
	bsr	flip_screen
;	move.w	#$123,$ffff8240.w
	bsr	scroll
;	move.w	#$3,$ffff8240.w
	bsr	return_bobs
;	move.w	#$40,$ffff8240.w
	bsr	bobs
;	move.w	pic+2,$ffff8240.w

	move.b	$fffffc02.w,d0

;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	beq.s	zero

car	cmp.b	#$53,d0
	beq	do_reset

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

zero	tst.w	zero_counter
	bne.s	car
	eor.w	#$4,fontpal
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra.s	main_loop

load	move.b	(a0),d0
	move.l	d0,-(sp)
	bsr	isr_off
	move.l	(sp)+,d0
	and.l	#$ff,d0
	lea	filenames,a6
	mulu	#16,d0
	add.w	d0,a6
	lea	$200,a0
	movem.l	(a6),d0-d3
	movem.l	d0-d3,(a0)
	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4,a0
	jmp	(a0)
exit	bsr	isr_off
	bsr	flush
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	bsr	user_mode
	clr.w	-(sp)
	trap	#1

***************
* Subroutines *
***************
scroll	move.l	present_base,a0
	add.l	#160*204,a0
	add.l	last_scroll,a0
	movem.l	black,d0-d7
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	add.w	#160*30,a0
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	move.w	sine_number,d0
	cmp.w	#54-1,d0
	blt.s	.no_reset
	moveq	#0,d0
	move.w	d0,sine_number
.no_reset
	add.b	d0,d0
	lea	sine_table,a1
	add.w	d0,a1
	move.w	(a1),d0
	lsl.l	#5,d0
	move.w	d0,d1
	lsl.l	#2,d0
	add.l	d1,d0
	add.w	#1,sine_number
	move.l	d0,last_scroll

	move.l	present_base,a1
	add.l	#160*204,a1
	add.w	d0,a1

	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#(30*4)*4,d0	;char depth * 4 *4
	add.w	d0,a0
	move.w	d6,d0
	mulu	#(30*4),d0		;character depth * 4 (30*4)
	add.w	d0,a0
.column
OFF	set	0
	REPT	30
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	add.w	#6,a1		;else goto next word on screen
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

vsync	move.w	#$ffff,vsync_flag
vs	tst.w	vsync_flag
	bne.s	vs
	rts

screen_rout
	lea	pic1,a0
	move.l	present_base,a1
	bsr	deice
	lea	pic_pal13,a1
	bsr	fadein
	bsr	delayed_key
	lea	black,a1
	bsr	fadein
	lea	pic2,a0
	move.l	present_base,a1
	bsr	deice
	lea	pic_pal13,a1
	bsr	fadein
	bsr	delayed_key
	lea	black,a1
	bsr	fadein

	lea	pic3,a0
	move.l	present_base,a1
	bsr	deice
	lea	pic_pal13,a1
	bsr	fadein
	bsr	delayed_key
	lea	black,a1
	bsr	fadein

	lea	pic4,a0
	move.l	present_base,a1
	bsr	deice
	lea	pic_pal4,a1
	bsr	fadein

	move.l	#1,D0
	jsr	tune
	bsr	delayed_key

	lea	black,a1
	bsr	fadein
	rts

v_sync25
	move.l	d7,-(sp)
	move.w	#25-1,d7
.loop	bsr	v_sync
	dbf	d7,.loop
	move.l	(sp)+,d7
	rts
v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

tst_key:
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

delayed_key
	move.w	#8000,d7
.loop	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bne.s	.return
	dbf	d7,.loop
	rts
.return	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	#"MSD!",d0
	rts

set_super:
	clr.l	-(sp)		;Set super stack equal
	move.w	#$20,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save	;save old supervisor stack value
	rts
set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack
	rts

get_old_palette:
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_pal
	rts

set_new_palette:
	lea	dhsr+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ffff8240.w,a1
	move.w	#8-1,d0
set_	move.l	(a0)+,(a1)+
	dbf	d0,set_
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

get_original_rez:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

show_dhsr
	lea	dhsr+34,a0
show_pic
	move.l	present_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

shift_bobs
	move.l	screen_base,a1
	lea	bob_grafix,a0
	move.w	#(16*10)-1,d2
.loop	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	move.l	(a0)+,16(a1)
	move.l	(a0)+,20(a1)
	add.w	#160,a1
	dbf	d2,.loop
	
	lea	logo,a1
	move.w	#16-1,d7
shift	move.l	screen_base,a0
	add.w	#8,a0
	move.w	#(16*10)-1,d2
.loop	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	add.w	#160,a0
	dbf	d2,.loop

	move.l	screen_base,a0
	move.w	#(16*10)-1,d2
.loop2	roxr.w	6(a0)
	roxr.w	14(a0)
	roxr.w	22(a0)
	add.w	#160,a0
	sub.w	d4,d4
	dbf	d2,.loop2

	sub.w	d4,d4
	move.l	screen_base,a0
	move.w	#(16*10)-1,d2
.loop3	roxr.w	4(a0)
	roxr.w	12(a0)
	roxr.w	20(a0)
	add.w	#160,a0
	sub.w	d4,d4
	dbf	d2,.loop3

	sub.w	d4,d4
	move.l	screen_base,a0
	move.w	#(16*10)-1,d2
.loop4	roxr.w	2(a0)
	roxr.w	10(a0)
	roxr.w	18(a0)
	add.w	#160,a0
	sub.w	d4,d4
	dbf	d2,.loop4

	sub.w	d4,d4
	move.l	screen_base,a0
	move.w	#(16*10)-1,d2
.loop5	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	add.w	#160,a0
	sub.w	d4,d4
	dbf	d2,.loop5
	dbf	d7,shift
	rts

black_out
	bsr	v_sync
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

digit_rout
	lea	digits,a0
	move.l	present_base,a1
	bsr	deice
	bsr	colour
	move.w	#30-1,d0
.loop	bsr	v_sync
	eor.w	#$700,$ffff8240.w
	dbf	d0,.loop
	rts
colour	move.w	#30-1,d7
.delay	bsr	v_sync
	dbf	d7,.delay
	move.w	colour_no,d0
	bne.s	.no_reset
	rts
.no_reset
	sub.w	#1,colour_no
	lea	$ffff8240.w,a1
	move.l	pal_pos,a0
	movem.w	(a0)+,d0-d7
	movem.w	d0-d7,(a1)
	move.l	a0,pal_pos
	bra.s	colour

endmus	clr.l	$4da
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

clear_screen
	move.l	present_base,a0
	moveq.l	#0,d1
	move.w	#32000/4-1,d0
.loop	move.l	d1,(a0)+
	dbf	d0,.loop
	rts

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadein	MOVE #8-1,d6
	MOVE.L A1,A2
FADEIN1:
	lea	$ffff8240.w,a0
	MOVE #16-1,D7
FADEIN2:
	bsr	modify
	ADDQ #2,A0
	ADDQ #2,A1
	DBRA D7,FADEIN2
	MOVE #4,D0
	bsr	sync
	MOVE.L A2,A1
	DBRA D6,FADEIN1
	RTS

sync	bsr	v_sync
	DBRA D0,sync
	RTS

modify	MOVE (A0),D0 ;PALREG
	MOVE (A1),D1 ;TARGET
	MOVE D0,D4 ;NEW COL
	MOVE D0,D2
	MOVE D1,D3
	AND #$7,D2
	AND #$7,D3
	CMP D2,D3
	BEQ.S MOK1
	BMI.S MDN1
	ADDQ #1,D4
	BRA.S MOK1
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


;***************************************************************************
; Unpacking source for Pack-Ice Version 2.1
; a0: Pointer on packed Data
; a1: Pointer on destination of unpacked data
deice		movem.l d0-a6,-(sp)
		cmpi.l	#'Ice!',(a0)+	; Is data packed?
		bne.s	ice_03		; no!
		move.l	(a0)+,d0	; read packed data
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		movea.l a1,a4
		movea.l a1,a6
		adda.l	(sp),a6
		movea.l a6,a3
		bsr.s	ice_08
		bsr.s	ice_04
		bsr	ice_0c		;; Picture decrunch!
		bcc.s	ice_03		;; These marked lines may be
		move.w	#$0f9f,d7	;; removed in your own sources
ice_00:		moveq	#3,d6		;; if you do not use the
ice_01:		move.w	-(a3),d4	;; additional algorithm.
		moveq	#3,d5		;;
ice_02:		add.w	d4,d4		;;
		addx.w	d0,d0		;;
		add.w	d4,d4		;;
		addx.w	d1,d1		;;
		add.w	d4,d4		;;
		addx.w	d2,d2		;;
		add.w	d4,d4		;;
		addx.w	d3,d3		;;
		dbra	d5,ice_02	;;
		dbra	d6,ice_01	;;
		movem.w d0-d3,(a3)	;;
		dbra	d7,ice_00	;;
ice_03:		movem.l (sp)+,d0-a6
		rts
ice_04:		bsr.s	ice_0c
		bcc.s	ice_07
		moveq	#0,d1
		bsr.s	ice_0c
		bcc.s	ice_06
		lea	ice_1a(pc),a1
		moveq	#4,d3
ice_05:		move.l	-(a1),d0
		bsr.s	ice_0f
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice_05
		add.l	20(a1),d1
ice_06:		move.b	-(a5),-(a6)
		dbra	d1,ice_06
ice_07:		cmpa.l	a4,a6
		bgt.s	ice_12
		rts
ice_08:		moveq	#3,d0
ice_09:		move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice_09
		rts
ice_0a:		move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0b
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice_11
ice_0b:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice_11
ice_0c:		add.l	d7,d7
		beq.s	ice_0d
		rts
ice_0d:		move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0e
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice_0e:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice_0f:		moveq	#0,d1
ice_10:		add.l	d7,d7
		beq.s	ice_0a
ice_11:		addx.w	d1,d1
		dbra	d0,ice_10
		rts
ice_12:		lea	ice_1b(pc),a1
		moveq	#3,d2
ice_13:		bsr.s	ice_0c
		dbcc	d2,ice_13
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice_14
		bsr.s	ice_0f
ice_14:		move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice_16
		lea	ice_1c(pc),a1
		moveq	#1,d2
ice_15:		bsr.s	ice_0c
		dbcc	d2,ice_15
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice_0f
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice_18
ice_16:		moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice_0c
		bcc.s	ice_17
		moveq	#8,d0
		moveq	#$40,d2
ice_17:		bsr.s	ice_0f
		add.w	d2,d1
ice_18:		lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice_19:		move.b	-(a1),-(a6)
		dbra	d4,ice_19
		bra	ice_04

		DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
		DC.B $00,$07,$00,$02,$00,$03,$00,$01
		DC.B $00,$03,$00,$01
ice_1a:		DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
		DC.B $00,$00,$00,$07,$00,$00,$00,$04
		DC.B $00,$00,$00,$01
ice_1b:		DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
		DC.B $01,$00
ice_1c:		DC.B $0b,$04,$07,$00,$01,$20,$00,$00
		DC.B $00,$20
;***************************************************************************

stack_save:	dc.l	0
original_rez:	dc.w	0
old_palette:	ds.w	16
black		dcb.b	32,0

	even

flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffc02.w,d0
	bra.s	flush
flush2	rts

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_pov50_palette:
	lea	pic+2,a0
set_p	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

calc_screen:
	move.l	#screen,d0
	clr.b	d0
	move.l	d0,present_base
	move.l	d0,screen_base
	move.l	#49152,screen_toggle
	move.l	d0,a0
	bsr	set_low_rez
	rts

set_med_rez:
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez:
	clr.w	-(sp)
set_rez:
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_pov50_pic:
	lea	pic+34,a0
	move.l	screen_base,a1
	move.l	a1,a2
	add.l	screen_toggle,a2
	move.w	#32000/4-1,d0
.loop	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.loop
	rts


wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive
	rts

clear_below_screen:
	move.l	present_base,a0
	add.w	#32000,a0
	move.l	a0,a1
	add.l	#49152,a1
	move.w	#20,d0
clr1	move.w	#8*40-1,d1
clr2	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts

set_for_border
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	MOVE.L	#vert_isr,$70.W
	MOVE.L	#horiz_isr,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
	MOVE.W	#$2300,SR
	rts


isr_off	bsr	vsync
	move.w	#$2700,sr
	move.l	old120,$120
	move.l	old70,$70
	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	MOVE.W	#$2300,SR
	bra	endmus


*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	tune50+8
	clr.w	vsync_flag
	tst.w	zero_counter
	beq.s	not_z
	sub.w	#1,zero_counter
not_z	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

horiz_isr
	clr.b	$fffffa1b.w	;DI all other interrupts
	REPT	100
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz
	REPT	32
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz

;now in lower border
	move.w	fontpal,$ffff8240.w
	movem.l	d0-d6,-(sp)
	movem.l	fontpal+2,d0-d6
	movem.l	d0-d6,$ffff8242.w
	movem.l	(sp)+,d0-d6
	bclr	#0,$fffffa0f.w
	rte

return_bobs
	move.w	s_last_1,d0
	bsr	return_bob
	move.w	s_last_2,d0
	bsr	return_bob
	move.w	s_last_3,d0
	bsr	return_bob
	move.w	s_last_4,d0
	bsr	return_bob
	move.w	s_last_5,d0
	bsr	return_bob
	rts
return_bob
	move.l	present_base,a1
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

bobs	move.w	last_5,s_last_5
	move.w	last_4,s_last_4
	move.w	last_3,s_last_3
	move.w	last_2,s_last_2
	move.w	last_1,s_last_1

	lea	bob_5,a6
	lea	logo+(16*16*4),a1
	bsr	do_bobs

	lea	bob_4,a6
	lea	logo+(16*16*3),a1
	bsr	do_bobs

	lea	bob_3,a6
	lea	logo+(16*16*2),a1
	bsr	do_bobs

	lea	bob_2,a6
	lea	logo+(16*16*1),a1
	bsr	do_bobs

	lea	bob_1,a6
	lea	logo,a1
	bsr	do_bobs
	rts

do_bobs	move.l	(a6),a0
	cmp.l	end_of_table,a0
	bne.s	.no_reset
	move.l	present_table,a0
.no_reset
	moveq	#0,d0
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

	move.l	present_base,a0
	add.w	d0,a0

	and.w	#15,d2
	mulu	#16*10*16,d2

	add.l	d2,a1
	lea	16*5*16(a1),a2		;mask position
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

flip_screen
	move.l	present_base,last_base
	bsr	vsync
	move.l	screen_base,d0
	eor.l	#49152,screen_toggle
	add.l	screen_toggle,d0
	move.l	d0,present_base
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	rts

********
* Data *
********
	SECTION DATA
fontpal	dc.w	$000,$002,$067,$025,$077,$003,$004,$005
	dc.w	$006,$007,$027,$037,$047,$057,$067,$777

zero_counter	dc.w	0
hertz_switch	dc.w	0

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                        "
 dc.b "PERSISTENCE OF VISION PACKED DEMO DISC 50.    "
 dc.b "CODE, BOBS AND FONT BY MAC SYS DATA, OTHER GRAFIX BY OZ, MUSIC RIPPED FROM LEAVIN' "
 dc.b "TERRAMIS BY MAC SYS DATA.      "
 dc.b "OK, I KNOW THE INTRO DOES NOT REALLY FIT THE MENU BUT WHO CARES?      "
 dc.b "IF YOU WANT TO SKIP THE INTRO SIMPLY PRESS ANY KEY WHEN THE "
 DC.B "'DID HE SAY RIPPED OFF' SCREEN APPEARS.      "
 DC.B "I APOLOGIZE FOR THIS DISC BEING LATE BUT THE CAUSE OF THE DELAY "
 DC.B "WAS BEYOND MY POWER -- BORIS WAS VERY SLOW AT DOING THE "
 DC.B "INFO FILE (WAS THAT A SLAGGING?            NO!)    "
 DC.B "    I'LL GET THE GREETINGS OVER A.S.A.P. SO HERE THEY ARE...."
 DC.B "  HI TO   AUTOMATION,   "
 DC.B "INNER CIRCLE,   THE REPLICANTS,   SEWER SOFTWARE,   THE LOST BOYS,   "
 DC.B "THE CAREBEARS,   AN COOL,   THE MEDWAY BOYS,   THE POMPEY PIRATES,   "
 DC.B "ERIK PLANKTON,   AXE OF DELIGHT,   THE EMPIRE,   ST CNX,   "
 DC.B "SWSL,   THE DEMO CLUB,   DR.SYNE,   MARTIAN   AND   THE SKUNK."
 dc.b "        THE ACE PIC WAS DIGITIZED USING MY AMIGA AND PORTED OVER TO THE ST FOR "
 DC.B "OZ TO COLOUR - TURNED OUT QUITE NICE DIDN'T IT?   "
 dc.b "THIS DISC HAS BEEN PRODUCED AFTER DISC 76 SO I MAY SAY THINGS "
 DC.B "THAT SEEM A BIT OUT OF SYNC WITH THE OTHERS....       "
 DC.B "BEFORE I WAFFLE ON I THINK I MUST APPOLOGIZE TO ALL THE "
 DC.B "PD LIBRARIES THAT HAVE BEEN WAITING FOR THIS DISC, WE "
 DC.B "WILL TRY TO KEEP IN SEQUENCE WITH THE NEXT 50 OR SO DISCS "
 DC.B "(IGNORE DISC 75 'CAUSE THAT'S ALREADY LATE!!!!).       "
 DC.B "YESTERDAY THE 7TH OF JUNE 1991 I ARRIVED BACK FROM THE "
 DC.B "ISLE OF MAN AFTER THE TT RACES FINISHED, ONE THING THAT "
 DC.B "WAS VERY APPARENT IN THE I.O.M. WAS THE FACT THE PLACE WAS "
 DC.B "CRAWLING WITH GERMANS.    I HOPE I NEVER SEE ONE AGAIN 'CAUSE "
 DC.B "THEY WERE THE MOST NOISY,  UGLY,  STUPID  AND OVERALL "
 DC.B "DUMBEST PEOPLE I HAVE EVER COME ACROSS.         "
 dc.b "TO DATE P.O.V. HAS PACKED 74 DEMOS ONTO DISCS 50-76 AND "
 DC.B "I HAVE A FURTHER 43 DEMOS ALL PACKED AND WAITING FOR A MENU OR TWO, "
 DC.B "IF THIS IS YOUR FIRST P.O.V. DISC AND YOU LIKE IT THEN "
 DC.B "YOU BETTER GET SOME BLANKS AND GET THE REST BEFORE WE REACH DISC 100. "
 dc.b "       OK, I THINK THIS SCROLL TEXT IS LONG ENOUGH SO I'LL "
 DC.B "WRAP IT UP HERE, IF YOU WANT MORE SCROLL TEXT TO READ THEN "
 DC.B "LOAD THE INFO PROGRAM.....        ONE LAST WORD IS TO DAVE AT D.W. STABLES IN BLACKPOOL.... "
 DC.B "HELLO!!!!            BYE...      P.O.V.,   P.O. BOX 40,   THORNTON,   CLEVELEYS,   "
 DC.B "BLACKPOOL,   LANCS,   FY5 4PH.         "
 DC.B "                                                       "
 dc.b $ff
	even
char_offset	dc.w	0
font		incbin	pp43.fnt
font_offsets:
 dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 dc.b	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
 dc.b	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58
 dc.b	59,60,61,62,63
	even
last_scroll	dc.l	0
sine_number	dc.w	0
sine_table
	dc.w	0,0,0,0,0,0,0
	dc.w	1,1,1,1,1,1
	dc.w	2,2,2,2,2
	dc.w	3,3,3,3
	dc.w	4,4,4
	dc.w	5,5
	dc.w	6,7,8,10,8,7,6
	dc.w	5,5,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1

;*************************
tune50:	incbin	TERRAMIS.img
pic	incbin	pov50.PI1
	even

bob_grafix	incbin	shifted.dat
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

bob_1	dc.l	0
last_1	dc.w	0
bob_2	dc.l	0
last_2	dc.w	0
bob_3	dc.l	0
last_3	dc.w	0
bob_4	dc.l	0
last_4	dc.w	0
bob_5	dc.l	0
last_5	dc.w	0

s_last_1	dc.w	0
s_last_2	dc.w	0
s_last_3	dc.w	0
s_last_4	dc.w	0
s_last_5	dc.w	0

********* digit data **********
colour_no	dc.w	10
pal_pos	dc.l	pals
pals	dc.w	$000,$700,$700,$700,$700,$000,$700,$700  9
	dc.w	$000,$700,$700,$700,$700,$700,$700,$700  8
	dc.w	$000,$700,$700,$700,$000,$000,$000,$000  7
	dc.w	$000,$700,$000,$700,$700,$700,$700,$700  6
	dc.w	$000,$700,$000,$700,$700,$000,$700,$700  5
	dc.w	$000,$000,$700,$700,$000,$000,$700,$700  4
	dc.w	$000,$700,$700,$700,$700,$000,$000,$700  3
	dc.w	$000,$700,$700,$000,$700,$700,$000,$700  2
	dc.w	$000,$000,$700,$700,$000,$000,$000,$000  1
	dc.w	$000,$700,$700,$700,$700,$700,$700,$000  0

*******************************
pic_pal13
	dc.w	$000,$123,$124,$134,$234,$235,$245,$345
	dc.w	$346,$356,$456,$457,$557,$567,$677,$777
pic_pal4
	dc.w	$000,$007,$027,$137,$247,$357,$467,$577
	dc.w	$700,$210,$320,$430,$540,$650,$760,$666
dhsr	incbin	dhsr.pi1
digits	incbin	digit.dat
tune	incbin	arch.img
pic1	incbin	pov1.dat
pic2	incbin	pov2.dat
pic3	incbin	pov3.dat
pic4	incbin	pov4.dat
	even

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5
	dc.b	7,5	;key 6

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
	dc.b	$6c,5	;keypad 6
	dc.b	$ff
	even

filenames:
	dc.b	"TCB2.50",0,0,0,0,0,0,0,0,0
	dc.b	"BATMAN.50",0,0,0,0,0,0,0
	dc.b	"HEADBANG.50",0,0,0,0,0
	dc.b	"RETURN.50",0,0,0,0,0,0,0
	dc.b	"INFO50.POV",0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

	SECTION BSS
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
logo	ds.b	40960

old_pal	ds.b	32
	ds.b	256
screen	ds.b	49152
	ds.b	46000
