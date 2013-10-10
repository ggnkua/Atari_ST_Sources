******************
* P.O.V. 96
*
* All code by MAC SYS DATA of P.O.V.
*
* 21/9/91
*
******************

	SECTION	TEXT

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,stack_save
	move.l	#go,$24.w
go	move.b	#2,$ffff820a.w	;50Hz
	move.b	#$12,$fffffc02.w

	move.b	$484.w,old484
	and.b	#$fe,$484.w
	bsr	get_old_pal
	bsr	black_out
	bsr	get_screen_base
	bsr	get_org_rez
	bsr	set_low_rez
	bsr	shift_bobs
	bsr	set_up

SPACING	equ	32
;set up bobs
	lea	bob_paths,a4
	move.l	a4,bob_5_pos
	add.w	#SPACING,a4
	move.l	a4,bob_4_pos
	add.w	#SPACING,a4
	move.l	a4,bob_3_pos
	add.w	#SPACING,a4
	move.l	a4,bob_2_pos
	add.w	#SPACING,a4
	move.l	a4,bob_1_pos

	move.l	#font_offsets,store_a2

	jsr	SAVE_INTERRUPTS(PC)

main	MOVE	#$2700,SR
	JSR	INIT_MUZEXX(PC)

	bsr	show_pic
	bsr	set_screen
	bsr	FADEIN

	JSR	PLAY_MUZEXX(PC)
	JSR	REINSTALL_INTERRUPTS(PC)

* module should have stopped now

	jsr	REINSTALL_INTERRUPTS

	moveq.l	#0,d0
	move.b	file_offset,d0
	cmp.b	#$ff,d0
	beq.s	exit

	lea	filenames,a6
	lsl.w	#2,d0	;*4
	add.w	d0,a6
	move.l	(a6),a6
	lea	$200.w,a0
	movem.l	(a6),d0-d3
	movem.l	d0-d3,(a0)

	move.b	#$8,$fffffc02.w
	move.b	old484,$484.w

	move.l	old_base,a0
	bsr	set_low_rez
	bsr	set_old_pal

	tst.w	hertz_toggle
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50	bsr.s	set_user
	clr.w	-(sp)
	trap	#1

exit	move.l	old_base,a0
	bsr	set_org_rez
	bsr	set_old_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	bsr.s	set_user
	clr.w	-(sp)
	trap	#1

set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

SAVE_INTERRUPTS
	MOVE	#$2700,SR
	move.b	$fffffa15.w,olda15
	move.b	$fffffa09.w,olda09
	LEA	SAVE_INT(PC),A1
	LEA	TIMERA(PC),A2
	LEA	$FFFFFA00.W,A0
	MOVEP	$7(A0),D0
	MOVE	D0,(A1)
	MOVE.B	$13(A0),(A2)
	MOVE.B	$19(A0),1(A2)
	MOVE.B	#0,$19(A0)
	MOVE.B	$1F(A0),2(A2)
	MOVE.B	1(A2),$19(A0)
	MOVE.B	$17(A0),3(A2)
	LEA	$FFFF8200.W,A0
	MOVEP	$1(A0),D0
	MOVE	D0,4(A1)
	MOVE.B	$A(A0),6(A1)
	MOVE.B	$60(A0),7(A1)
	MOVEM.L	$40(A0),D0-D7
	MOVEM.L	D0-D7,8(A1)
	MOVE.L	$68.W,40(A1)
	MOVE.L	$70.W,44(A1)
	MOVE.L	$114.W,48(A1)
	MOVE.L	$118.W,52(A1)
	MOVE.L	$11C.W,56(A1)
	MOVE.L	$120.W,60(A1)
	MOVE.L	$134.W,64(A1)
	MOVE	#$2300,SR
	RTS

REINSTALL_INTERRUPTS
	MOVE	#$2700,SR
	move.b	olda09,$fffffa09.w
	move.b	olda15,$fffffa15.w
	LEA	SAVE_INT(PC),A1
	LEA	TIMERA(PC),A2
	MOVE.L	40(A1),$68.W
	MOVE.L	44(A1),$70.W
	MOVE.L	48(A1),$114.W
	MOVE.L	52(A1),$118.W
	MOVE.L	56(A1),$11C.W
	MOVE.L	60(A1),$120.W
	MOVE.L	64(A1),$134.W
	LEA	$FFFFFA00.W,A0
	MOVE.B	3(A2),$17(A0)
	MOVE	(A1),D0
	MOVEP	D0,$7(A0)
	MOVE.B	#0,$19(A0)
	MOVE.B	2(A2),$1F(A0)
	MOVE.B	1(A2),$19(A0)
	MOVE.B	(A2),$13(A0)
	LEA	$FFFF8200.W,A0
	MOVE	4(A1),D0
	MOVEP	D0,$1(A0)
	MOVE.B	6(A1),d7		;preserve Hz when exit...
	and.b	#%11111101,d7
	or.b	d7,$A(A0)
	MOVE.B	7(A1),$60(A0)
	MOVEM.L	8(A1),D0-D7
	MOVEM.L	D0-D7,$40(A0)
	MOVE	#$2300,SR
	RTS


INIT_MUZEXX
	LEA	SEQ(PC),A0
	LEA	PAT(PC),A1
	LEA	NBR_INS(PC),A2
	LEA	MUZEXX,A3
	MOVE	#$1D8,(A0)
	MOVE	#$258,(A1)
	MOVE	#15,(A2)
	CMP.L	#'M.K.',$438(A3)    ;don't need this as it is a M.K. mod
	BNE.s	REAL_DOCs_MODULE
	MOVE	#$3B8,(A0)
	MOVE	#$43C,(A1)
	MOVE	#31,(A2)
REAL_DOCs_MODULE
	LEA	MUZEXX,A0
	ADD	SEQ(PC),A0
	MOVE.L	#$80,D0
	MOVEQ	#0,D1
INIT_MUZEXX1
	MOVE.L	D1,D2
	SUBQ	#1,D0
INIT_MUZEXX2
	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	INIT_MUZEXX1
	DBF	D0,INIT_MUZEXX2
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	LEA	MUZEXX,A0
	ADD	PAT,A0
	ADD.L	D2,A0
	LEA	20+MUZEXX,A1
	LEA	16+INS(PC),A2
	MOVE	NBR_INS(PC),D0
	SUBQ	#1,D0
INIT_MUZEXX3
	MOVE.L	A0,4(A2)
	MOVEQ	#0,D1
	MOVE	22(A1),D1
	LSL.L	#1,D1
	MOVE.L	D1,(A2)
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE	24(A1),D1
	BEQ.s	INIT_MUZEXX4
	SUBQ	#1,D1
INIT_MUZEXX4
	MOVE	D1,12(A2)
	MOVEQ	#0,D1
	MOVE	28(A1),D1
	LSL.L	#1,D1
	CMP.L	#2,D1
	BNE.s	INIT_MUZEXX5
	MOVEQ	#0,D1
INIT_MUZEXX5
	SWAP	D1
	MOVE.L	D1,8(A2)
	LEA	30(A1),A1
	LEA	16(A2),A2
	DBRA	D0,INIT_MUZEXX3

	LEA	16+INS(PC),A0
	MOVEQ	#0,D0
	MOVE	4+SAVE_INT(PC),D0	;screen base
	LSL.L	#8,D0
	SUB.L	#$8000,D0		;make a 32K buffer for REVERSE
	MOVE.L	D0,A2
	MOVE	NBR_INS(PC),D0
	SUBQ	#1,D0
REVERSE
	MOVE.L	(A0),D1
	BEQ.s	END_REVERSE_THIS_INS
	SUBQ.L	#1,D1
	MOVE.L	D1,D2
	MOVE.L	4(A0),A3
REV_1
	MOVE.B	(A3)+,(A2)+
	DBRA	D1,REV_1
	MOVE.L	4(A0),A3
REV_2
	MOVE.B	-(A2),(A3)+
	DBRA	D2,REV_2
END_REVERSE_THIS_INS
	LEA	16(A0),A0
	DBRA	D0,REVERSE
	RTS

PLAY_MUZEXX
MFP_RESET
	MOVE.B	#0,$FFFFFA07.W
	MOVE.B	#0,$FFFFFA09.W
YAMAHA_RESET
	MOVE.B	#0,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#1,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#2,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#3,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#4,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#5,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#7,$FFFF8800.W
	MOVE.B	#$FF,$FFFF8802.W
	MOVE.B	#8,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#9,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#10,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W

ON	MOVE	#$2700,SR
	MOVE.b	#6,SPD+2
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA	MUZEXX,A0
	ADD.w	SEQ(PC),A0
	LEA	-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA	OFF2(PC),A0
	LEA	OFF2(PC),A1
	LEA	OFF2(PC),A2
	LEA	OFF2(PC),A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	move.l	d0,V0+2
	move.l	d0,V1+2
	move.l	d0,V2+2
	move.l	d0,V3+2
	move.l	d0,F0+2
	move.l	d0,F1+2
	move.l	d0,F2+2
	move.l	d0,F3+2

	BCLR	#3,$FFFFFA17.W
	move.B	#$21,$FFFFFA07.W
	move.b	#0,$fffffa09.w
	move.B	#$21,$FFFFFA13.W
	move.b	#0,$FFFFFA15.W
	move.b	#$11,$FFFFFA19.W
	move.b	#$3c,$FFFFFA1f.W

	MOVE.L	#AMIGA,$134.W
	MOVE.L	#startup_vbl,$70.W
	move.l	#null,$120.w	;prevent HBL occuring too early
 
	MOVE	#$2300,SR
	CLR.B	KEY_PRESS

* REGISTERS LEFT ARE D4-D5-D6-D7/A4-A5-A6
main_loop
	jsr	vsync
raster
;	move.w	#$123,$ffff8240.w

	bsr	bobs
	bsr	scroll

;	move.w	pic+2,$ffff8240.w

	tst.w	zero_counter		;is shown
	beq.s	.check
	subq.w	#1,zero_counter
.check
	move.b	$fffffc02.w,d7

;	cmp.b	#01,d7		;escape
;	beq.s	set_exit

	cmp.b	#$b,d7		;0 key
	beq.s	zero

	cmp.b	#$70,d7		;0 keypad
	beq.s	zero

car	cmp.b	#$53,d7
	beq.s	do_reset

	lea	key_codes,a6
.loop	cmp.b	#$ff,(a6)
	beq.s	main_loop
	cmp.b	(a6)+,d7
	beq.s	load
	move.b	(a6)+,d6
	bra.s	.loop
	bra.s	main_loop

zero	tst.w	zero_counter
	bne.s	car
	eor.w	#$3,font_pal
	move.w	#10,zero_counter
	eor.w	#-1,hertz_toggle
	bra	main_loop

set_exit
	move.b	#$ff,file_offset
	bra	end_of_musix

load	move.b	(a6),file_offset
	bra	end_of_musix


do_reset
	move.l	4.w,a0
	jmp	(a0)



scroll	move.l	scr_now,a6
	add.l	#160*201,a6
	move.l	scroll_pointer,a4
	move.l	a4,a5

	move.w	#0,byte_toggle
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.w	#32,d7

	ext.w	d7

	move.l	d5,tmp1
	move.l	#font,store_a0

	move.l	a5,tmp2
	move.l	store_a2,a5
	move.b	(a5,d7),d5
	move.l	a5,store_a2
	move.l	tmp2,a5

	and.l	#$ff,d5
	mulu	#(23*4)*2,d5		;23 * 4 (2 planes)
	add.l	d5,store_a0

	move.w	d6,d5
	mulu	#(23*2),d5		;character depth * 2 bytes (word wide)
	add.l	d5,store_a0
	move.l	tmp1,d5

	move.l	a4,tmp4
	move.l	store_a0,a4
.column
OFF	set	0
	REPT	23
	move.w	(a4)+,d4
	movep.w	d4,OFF(a6)
OFF	set	OFF+160
	ENDR
	subq.w	#1,d5
	beq.s	.finish

	addq.w	#1,a6		;lower byte of word
	tst.w	byte_toggle
	beq.s	.skip		;if byte_toggle=0 then do next word
	addq.w	#6,a6		;else goto next word on screen
.skip	not.w	byte_toggle
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	move.l	tmp4,a4

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	move.l	tmp4,a4
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts


* REGISTERS LEFT ARE D4-D5-D6-D7/A4-A5-A6
*
* BOBS are in memory in sequence...
*
* P O V M S D Z B R I .. --
* 0 1 2 3 4 5 6 7 8 9 10 11 12
bobs
	lea	last_1_pos,a6
	bsr	return_bob

	lea	last_2_pos,a6
	bsr	return_bob

	lea	last_3_pos,a6
	bsr	return_bob

	lea	last_4_pos,a6
	bsr	return_bob

	lea	last_5_pos,a6
	bsr	return_bob

	sub.w	#1,bob_countdown
	move.w	bob_countdown,d4
	bne.s	.no_change

; change the bob grafix...
	lea	bob_string_table,a4
	move.w	bob_string_offset,d4
	add.w	d4,a4
	tst.l	(a4)
	bpl.s	.no_reset
	lea	bob_string_table,a4
	moveq.l	#0,d4
	move.w	d4,bob_string_offset
.no_reset
	move.l	(a4),a5			;a5=bob string to use
	add.w	#4,bob_string_offset
	move.l	(a5)+,bob_string
	move.l	(a5)+,bob_string+4
	move.w	(a5)+,bob_string+8	;10 bytes for 5 bobs (word offsets)
	move.w	(a5),bob_countdown	;make bobs stay on for different lengths
					;of time...
.no_change
	lea	bob_5_pos,a6
	move.l	present_bob_grafic,a5

	move.w	bob_string+8,d4
	mulu	#16*8,d4
	add.l	d4,a5
	bsr	do_bobs


	lea	bob_4_pos,a6
	move.l	present_bob_grafic,a5
	move.w	bob_string+6,d4
	mulu	#16*8,d4
	add.l	d4,a5
	bsr	do_bobs


	lea	bob_3_pos,a6
	move.l	present_bob_grafic,a5
	move.w	bob_string+4,d4
	mulu	#16*8,d4
	add.l	d4,a5
	bsr	do_bobs


	lea	bob_2_pos,a6
	move.l	present_bob_grafic,a5
	move.w	bob_string+2,d4
	mulu	#16*8,d4
	add.l	d4,a5
	bsr	do_bobs


	lea	bob_1_pos,a6
	move.l	present_bob_grafic,a5
	moveq	#0,d4
	move.w	bob_string,d4
	mulu	#16*8,d4
	add.l	d4,a5
	bsr	do_bobs
	rts




return_bob
	lea	pic+34,a4
	move.l	scr_now,a5

	move.l	4(a6),d6
	move.l	(a6),4(a6)
	add.l	d6,a5
	add.l	d6,a4

OFF	set 0
	REPT	16
	move.l	4+OFF(a4),4+OFF(a5)		;4 colour bob (2 plane)
	move.l	12+OFF(a4),12+OFF(a5)
OFF	set OFF+160
	ENDR
	rts


do_bobs
	move.l	(a6),a4
	cmp.l	#endbobs,a4
	blt.s	.no_reset
	lea	bob_paths,a4
.no_reset
	moveq	#0,d6
	move.l	d6,d5
	move.l	d5,d7

	move.w	(a4)+,d6	;get x
	move.w	(a4)+,d5	;get y
	move.w	d6,d7
	move.l	a4,(a6)

	lsr.w	#1,d6		;calc X offset
	and.w	#$1f8,d6

	add.w	d5,d6		;add Y offset
	move.l	d6,4(a6)	;save old bob pos...

	and.w	#15,d7		;calc which bob
	mulu	#16*8*13,d7	;16*8 * 12 bobs
	add.w	d7,a5
	lea	16*13*8*16(a5),a6	;mask pos

	move.l	scr_now,a4
	add.l	d6,a4

OFF	set 0
	REPT	16
	move.l	4+OFF(a4),d6		;1 plane
	move.l	(a5)+,d5		;grafic
	move.l	(a6)+,d7		;mask
	and.l	d6,d7
	or.l	d5,d7
	move.l	d7,4+OFF(a4)

	move.l	12+OFF(a4),d6		;2nd word
	move.l	(a5)+,d5
	move.l	(a6)+,d7
	and.l	d6,d7
	or.l	d5,d7
	move.l	d7,12+OFF(a4)

OFF	set	OFF+160
	ENDR
	rts


get_old_pal
	lea	$ffff8240.w,a0
	lea	old_palette,a1
_do	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

set_old_pal
	lea	old_palette,a0
	lea	$ffff8240.w,a1
	bra.s	_do

get_screen_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

get_org_rez
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,org_rez
	rts

set_org_rez
	move.w	org_rez,-(sp)
	bra.s	set_rez
set_low_rez
	clr.w	-(sp)
	bra.s	set_rez
set_med_rez
	move.w	#1,-(sp)
set_rez
	move.l	old_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

shift_bobs
	lea	logo,a1
	move.w	#16-1,d7
shift	lea	bob_pic+34,a0
	move.l	a0,a6
	add.w	#8,a0

	move.w	#(16*12)-1,d6		;12 BOBS LONG
.store	move.l	4(a0),(a1)+
	move.l	12(a0),(a1)+
	lea	160(a0),a0
	dbf	d6,.store

	moveq	#0,d1
	move.w	#(16*8)/4-1,d0
.fill2	move.l	d1,(a1)+
	dbf	d0,.fill2

	move.w	#2-1,d5		;2 planes to shift
	move.l	a6,a0
.shift2	move.w	#(16*12)-1,d6
.shift	roxr.w	6(a0)
	roxr.w	14(a0)
	roxr.w	22(a0)
	lea	160(a0),a0
	sub.w	d4,d4
	dbf	d6,.shift
	move.l	a6,a0
	sub.w	#2,a0
	dbf	d5,.shift2
	dbf	d7,shift


	move.w	#16-1,d7
shif	lea	bob_pic+34,a0
	add.w	#8*8,a0
	move.l	a0,a6
	add.w	#8,a0
	move.w	#(16*12)-1,d6		;12 BOBS LONG
.store	move.l	4(a0),(a1)+
	move.l	12(a0),(a1)+
	lea	160(a0),a0
	dbf	d6,.store

	move.l	#$ffffffff,d1
	move.w	#(16*8)/4-1,d0
.fill1	move.l	d1,(a1)+
	dbf	d0,.fill1


	move.w	#2-1,d5		;2 planes to shift
.shift2	move.l	a6,a0
	move.w	#(16*12)-1,d6
.shift	roxr.w	6(a0)
	roxr.w	14(a0)
	roxr.w	22(a0)
	lea	160(a0),a0
	sub.w	d4,d4
	dbf	d6,.shift
	subq.w	#2,a6
	dbf	d5,.shift2
	dbf	d7,shif
	rts


show_pic
	lea	pic+34,a0
	move.l	scr_now,a3
	move.l	a3,a2
	add.l	#39680,a2
	move.l	#(32000/4)-1,d0
sho	move.l	(a0),(a2)+
	move.l	(a0)+,(a3)+
	dbf	d0,sho

	move.l	scr_now,a0	;clear below screen
	add.w	#32000,a0
	move.l	a0,a1
	add.l	#39680,a1
	moveq	#0,d1
	move.w	#(160*45)/4,d0
.loop	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbf	d0,.loop
	rts

set_up	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#39680,d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

set_screen
	move.l	scr_now,d6
	move.l	scr_xor,d7
	eor.l	d7,d6
	move.l	d6,scr_now
	lsr.l	#8,d6
	lea	$ffff8201.w,a6
	movep.w	d6,(a6)
	rts


v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
FADEIN
	lea	pic+2,a1
	MOVE #7,D6
	MOVE.L A1,A2
FADEIN1	LEA	PALREG,A0	;LEA PALREG+2,A0; TARGET IN A1
	MOVE #15,D7
FADEIN2	BSR	MODIFY
	ADDQ #2,A0
	ADDQ #2,A1
	DBRA D7,FADEIN2
	MOVE #4,D0
	bsr.s	WAIT
	MOVE.L A2,A1
	DBRA D6,FADEIN1
	RTS

WAIT	BSR.S v_sync
	DBRA D0,WAIT
	RTS

PALREG	EQU $FF8240

MODIFY	MOVE (A0),D0 ;PALREG
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
MDN1	SUBQ #1,D4
MOK1	MOVE D0,D2
	MOVE D1,D3
	AND #$70,D2
	AND #$70,D3
	CMP D2,D3
	BEQ.S MOK2
	BMI.S MDN2
	ADD #$10,D4
	BRA.S MOK2
MDN2	SUB #$10,D4
MOK2	MOVE D0,D2
	MOVE D1,D3
	AND #$700,D2
	AND #$700,D3
	CMP D2,D3
	BEQ.S MOK3
	BMI.S MDN3
	ADD #$100,D4
	BRA.S MOK3
MDN3	SUB #$100,D4
MOK3	MOVE D4,(A0)
	RTS

	
black_out
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

L0	MOVE.L	#0,D0
F0	MOVE.L	#0,V0+2
	BRA.s	V1
L1	MOVE.L	#0,D1
F1	MOVE.L	#0,V1+2
	BRA.s	V2
L2	MOVE.L	#0,D2
F2	MOVE.L	#0,V2+2
	BRA.s	V3
L3	MOVE.L	#0,D3
F3	MOVE.L	#0,V3+2
	BRA.s	OUT

;AMIGA SOUND CHIP
AMIGA					;44(5/3)
	MOVEM.L	D4-D5/A4,-(SP)		;8+3*8
	SWAP	D0			;4(1/0)
	SWAP	D1			;4(1/0)
	SWAP	D2			;4(1/0)
	SWAP	D3			;4(1/0)
V0	SUB.L	#0,D0			;16(3/0)
	BMI.S	L0			;8(1/0)10
V1	SUB.L	#0,D1			;16(3/0)
	BMI.S	L1			;8(1/0)10
V2	SUB.L	#0,D2			;16(3/0)
	BMI.S	L2			;8(1/0)10
V3	SUB.L	#0,D3			;16(3/0)
	BMI.S	L3			;8(1/0)10
OUT	SWAP	D0			;4(1/0)
	SWAP	D1			;4(1/0)
	SWAP	D2			;4(1/0)
	SWAP	D3			;4(1/0)
	MOVE.B	0(A0,D0),D4		;14(3/0)
	EXT.W	D4			;4(1/0)
	MOVE.B	0(A1,D1),D5		;14(3/0)
	EXT.W	D5			;4(1/0)
	ADD.W	D5,D4			;4(1/0)
	MOVE.B	0(A2,D2),D5		;14(3/0)
	EXT.W	D5			;4(1/0)
	ADD.W	D5,D4			;4(1/0)
	MOVE.B	0(A3,D3),D5		;14(3/0)
	EXT.W	D5			;4(1/0)
	ADD.W	D5,D4			;4(1/0)
	ADD.W	D4,D4			;4(1/0)
	AND.W	#$7F8,D4		;8(2/0)
	MOVE.L	SOUND(PC,D4),D5		;18(4/0)
	MOVE.W	SOUND+4(PC,D4),D4	;14(3/0)
	LEA	$FFFF8800.W,A4		;8(2/0)
	MOVEP.L	D5,(A4)			;24(2/4)
	MOVEP.W	D4,(A4)			;16(2/2)
	MOVEM.L	(SP)+,D4-D5/A4		;12+3*8
	RTE				;20(5/0)

SOUND	DC.W	$80C,$90B,$A09,0,$80C,$90B,$A09,0
	DC.W	$80D,$908,$A08,0,$80B,$90B,$A0B,0
	DC.W	$80D,$909,$A05,0,$80C,$90B,$A08,0
	DC.W	$80D,$909,$A02,0,$80D,$908,$A06,0
	DC.W	$80C,$90B,$A07,0,$80D,$907,$A07,0
	DC.W	$80C,$90B,$A06,0,$80C,$90A,$A09,0
	DC.W	$80B,$90B,$A0A,0,$80C,$90B,$A02,0
	DC.W	$80C,$90B,$A00,0,$80C,$90A,$A08,0
	DC.W	$80D,$906,$A04,0,$80D,$905,$A05,0
	DC.W	$80D,$905,$A04,0,$80C,$909,$A09,0
	DC.W	$80D,$904,$A03,0,$80B,$90B,$A09,0
	DC.W	$80C,$90A,$A05,0,$80B,$90A,$A0A,0
	DC.W	$80C,$909,$A08,0,$80B,$90B,$A08,0
	DC.W	$80C,$90A,$A00,0,$80C,$90A,$A00,0
	DC.W	$80C,$909,$A07,0,$80B,$90B,$A07,0
	DC.W	$80C,$909,$A06,0,$80B,$90B,$A06,0
	DC.W	$80B,$90A,$A09,0,$80B,$90B,$A05,0
	DC.W	$80A,$90A,$A0A,0,$80B,$90B,$A02,0
	DC.W	$80B,$90A,$A08,0,$80C,$907,$A07,0
	DC.W	$80C,$908,$A04,0,$80C,$907,$A06,0
	DC.W	$80B,$909,$A09,0,$80C,$906,$A06,0
	DC.W	$80A,$90A,$A09,0,$80C,$907,$A03,0
	DC.W	$80B,$90A,$A05,0,$80B,$909,$A08,0
	DC.W	$80B,$90A,$A03,0,$80A,$90A,$A08,0
	DC.W	$80B,$90A,$A00,0,$80B,$909,$A07,0
	DC.W	$80B,$908,$A08,0,$80A,$90A,$A07,0
	DC.W	$80A,$909,$A09,0,$80C,$901,$A01,0
	DC.W	$80A,$90A,$A06,0,$80B,$908,$A07,0
	DC.W	$80A,$90A,$A05,0,$80A,$909,$A08,0
	DC.W	$80A,$90A,$A02,0,$80A,$90A,$A01,0
	DC.W	$80A,$90A,$A00,0,$809,$909,$A09,0
	DC.W	$80A,$908,$A08,0,$80B,$908,$A01,0
	DC.W	$80A,$909,$A06,0,$80B,$907,$A04,0
	DC.W	$80A,$909,$A05,0,$809,$909,$A08,0
	DC.W	$80A,$909,$A03,0,$80A,$908,$A06,0
	DC.W	$80A,$909,$A00,0,$809,$909,$A07,0
	DC.W	$809,$908,$A08,0,$80A,$908,$A04,0
	DC.W	$809,$909,$A06,0,$80A,$908,$A01,0
	DC.W	$809,$909,$A05,0,$809,$908,$A07,0
	DC.W	$808,$908,$A08,0,$809,$909,$A02,0
	DC.W	$809,$908,$A06,0,$809,$909,$A00,0
	DC.W	$809,$907,$A07,0,$808,$908,$A07,0
	DC.W	$809,$907,$A06,0,$809,$908,$A02,0
	DC.W	$808,$908,$A06,0,$809,$906,$A06,0
	DC.W	$808,$907,$A07,0,$808,$908,$A04,0
	DC.W	$808,$907,$A06,0,$808,$908,$A02,0
	DC.W	$807,$907,$A07,0,$808,$906,$A06,0
	DC.W	$808,$907,$A04,0,$807,$907,$A06,0
	DC.W	$808,$906,$A05,0,$808,$906,$A04,0
	DC.W	$807,$906,$A06,0,$807,$907,$A04,0
	DC.W	$808,$905,$A04,0,$806,$906,$A06,0
	DC.W	$807,$906,$A04,0,$807,$905,$A05,0
	DC.W	$806,$906,$A05,0,$806,$906,$A04,0
	DC.W	$806,$905,$A05,0,$806,$906,$A02,0
	DC.W	$806,$905,$A04,0,$805,$905,$A05,0
	DC.W	$806,$905,$A02,0,$805,$905,$A04,0
	DC.W	$805,$904,$A04,0,$805,$905,$A02,0
	DC.W	$804,$904,$A04,0,$804,$904,$A03,0
	DC.W	$804,$904,$A02,0,$804,$903,$A03,0
	DC.W	$803,$903,$A03,0,$803,$903,$A02,0
	DC.W	$803,$902,$A02,0,$802,$902,$A02,0
	DC.W	$802,$902,$A01,0,$801,$901,$A01,0
	DC.W	$802,$901,$A00,0,$801,$901,$A00,0
	DC.W	$801,$900,$A00,0,$800,$900,$A00,0
	DC.W	$80E,$90D,$A0C,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90C,$A0C,0,$80E,$90D,$A00,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80D,$90D,$A0C,0,$80D,$90D,$A0C,0
	DC.W	$80E,$90C,$A09,0,$80E,$90C,$A09,0
	DC.W	$80E,$90C,$A05,0,$80E,$90C,$A00,0
	DC.W	$80E,$90C,$A00,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0A,0
	DC.W	$80E,$90B,$A0A,0,$80E,$90B,$A0A,0
	DC.W	$80D,$90D,$A0B,0,$80D,$90D,$A0B,0
	DC.W	$80D,$90D,$A0B,0,$80E,$90B,$A09,0
	DC.W	$80E,$90B,$A09,0,$80E,$90B,$A09,0
	DC.W	$80D,$90C,$A0C,0,$80D,$90D,$A0A,0
	DC.W	$80E,$90B,$A07,0,$80E,$90B,$A00,0
	DC.W	$80E,$90B,$A00,0,$80D,$90D,$A09,0
	DC.W	$80D,$90D,$A09,0,$80E,$90A,$A09,0
	DC.W	$80D,$90D,$A08,0,$80D,$90D,$A07,0
	DC.W	$80D,$90D,$A04,0,$80D,$90D,$A00,0
	DC.W	$80E,$90A,$A04,0,$80E,$909,$A09,0
	DC.W	$80E,$909,$A09,0,$80D,$90C,$A0B,0
	DC.W	$80E,$909,$A08,0,$80E,$909,$A08,0
	DC.W	$80E,$909,$A07,0,$80E,$908,$A08,0
	DC.W	$80E,$909,$A01,0,$80C,$90C,$A0C,0
	DC.W	$80D,$90C,$A0A,0,$80E,$908,$A06,0
	DC.W	$80E,$907,$A07,0,$80E,$908,$A00,0
	DC.W	$80E,$907,$A05,0,$80E,$906,$A06,0
	DC.W	$80D,$90C,$A09,0,$80E,$905,$A05,0
	DC.W	$80E,$904,$A04,0,$80D,$90C,$A08,0
	DC.W	$80D,$90B,$A0B,0,$80E,$900,$A00,0
	DC.W	$80D,$90C,$A06,0,$80D,$90C,$A05,0
	DC.W	$80D,$90C,$A02,0,$80C,$90C,$A0B,0
	DC.W	$80C,$90C,$A0B,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80C,$90C,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80D,$90B,$A09,0,$80D,$90B,$A09,0
	DC.W	$80D,$90A,$A0A,0,$80D,$90A,$A0A,0
	DC.W	$80D,$90A,$A0A,0,$80C,$90C,$A09,0
	DC.W	$80C,$90C,$A09,0,$80C,$90C,$A09,0
	DC.W	$80D,$90B,$A06,0,$80C,$90B,$A0B,0
	DC.W	$80C,$90C,$A08,0,$80D,$90B,$A00,0
	DC.W	$80D,$90B,$A00,0,$80C,$90C,$A07,0
	DC.W	$80C,$90C,$A06,0,$80C,$90C,$A05,0
	DC.W	$80C,$90C,$A03,0,$80C,$90C,$A01,0
	DC.W	$80C,$90B,$A0A,0,$80D,$90A,$A05,0
	DC.W	$80D,$90A,$A04,0,$80D,$90A,$A02,0
	DC.W	$80D,$909,$A08,0,$80D,$909,$A08,0


new120
	clr.b	$fffffa1b.w	;stop another interrupt
	REPT	60
	nop
	ENDR
.not	tst.b	$ffff8209.w	;wait for raster to get to right hand side
	bne.s	.not

	clr.b	$ffff820a.w
	REPT	22
	nop
	ENDR
	move.b	#2,$ffff820a.w
	move.w	font_pal,$ffff8240.w
	move.l	font_pal+2,$ffff8240+2.w
	move.w	font_pal+6,$ffff8240+6.w
null	rte

startup_vbl
	clr.b	$fffffa1b.w
	move.l	#new120,$120.w
	move.l	#main_vbl,$70.w
	move.l	pic+2,$ffff8240.w
	move.l	pic+6,$ffff8240+4.w
	move.b	#198,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

main_vbl
	MOVE	#$2700,SR
	clr.b	$fffffa1b.w
	SUBQ.B	#1,SPEED
	BEQ.S	PLAY
	JSR	EFFECT
END_VBL	ST	SWITCH
	move.l	pic+2,$ffff8240.w
	move.l	pic+6,$ffff8240+4.w
	move.b	#198,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte




PLAY	BTST	#7,$FFFFFC00.W
	BEQ.S	NO_KEYBOARD1
	MOVE.L	D7,-(SP)
	MOVEQ	#0,D7
	move.b	$fffffc02.w,d7
	BTST	#7,D7
	BEQ.S	NO_KEYBOARD2
	AND	#$7F,D7
	MOVE.B	D7,KEY_PRESS
	MOVE.L	#AMIGA,$134.W
NO_KEYBOARD2
	MOVE.L	(SP)+,D7
NO_KEYBOARD1
	MOVEM.L	D0-D1/A0-A5,-(SP)
SPD	MOVE.B	#6,SPEED
	SUBQ.B	#1,POS
	BNE.s	NO_NEW_PATTERN
	MOVE.B	#64,POS
	ADDQ.L	#1,MUS+2
	SUBQ.B	#1,TRK
	bmi	RESTART
	MOVEQ	#0,D0
MUS	MOVE.B	$0,D0
	SWAP	D0
	LSR.L	#6,D0
	LEA	MUZEXX,A0
	ADD	PAT(PC),A0
	ADD.L	D0,A0
	MOVE.L	A0,ADD_IN_PAT
NO_NEW_PATTERN
	MOVE.L	ADD_IN_PAT(PC),A0
	LEA	FRQ(PC),A1
	LEA	INS(PC),A2
	LEA	COMMAND(PC),A3
	LEA	VOICE0(PC),A4
	BSR	LOAD_VOICE
	LEA	VOICE1(PC),A4
	BSR	LOAD_VOICE
	LEA	VOICE2(PC),A4
	BSR	LOAD_VOICE
	LEA	VOICE3(PC),A4
	BSR	LOAD_VOICE
	MOVE.L	A0,ADD_IN_PAT
	MOVEM.L	(SP)+,D0-D1/A0-A5
* ADDRESS ALL 4 VOICES
	MOVEM.L	D4/A5,-(SP)
	LEA	VOICE0(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT0
	MOVE.L	(A5),D0
	MOVE.L	4(A5),A0
	MOVE.L	8(A5),D4
	MOVE.L	D4,L0+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V0+2
	MOVE.L	16(A5),D4
CONT0
	CLR.B	20(A5)
	LEA	VOICE1(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT1
	MOVE.L	(A5),D1
	MOVE.L	4(A5),A1
	MOVE.L	8(A5),D4
	MOVE.L	D4,L1+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V1+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F1+2
CONT1
	CLR.B	20(A5)
	LEA	VOICE2(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT2
	MOVE.L	(A5),D2
	MOVE.L	4(A5),A2
	MOVE.L	8(A5),D4
	MOVE.L	D4,L2+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V2+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F2+2
CONT2
	CLR.B	20(A5)
	LEA	VOICE3(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT3
	MOVE.L	(A5),D3
	MOVE.L	4(A5),A3
	MOVE.L	8(A5),D4
	MOVE.L	D4,L3+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V3+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F3+2
CONT3
	CLR.B	20(A5)
	MOVEM.L	(SP)+,D4/A5

	BRA	END_VBL

LOAD_VOICE
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE	D0,30(A4)
	MOVE	(A0)+,D0
	BEQ.S	COMMAND?
	BTST	#12,D0
	BEQ.S	CONT_FRQ
	AND	#$FFF,D0
	MOVE	#$100,D1
CONT_FRQ
	MOVE.B	#1,20(A4)
	MOVE	D0,24(A4)
	ADD	D0,D0
	ADD	D0,D0
	MOVE.L	(A1,D0.W),D0
	MOVE.L	D0,12(A4)
	TST.L	16(A4)
	BEQ.S	CONT_LOAD_FRQ
	MOVE.L	D0,16(A4)
CONT_LOAD_FRQ
	OR.B	(A0),D1
	AND	#$FF0,D1
	BEQ.S	COMMAND?
	MOVE.L	12(A4),16(A4)
	MOVE.L	0(A2,D1.W),(A4)
	MOVE.L	4(A2,D1.W),4(A4)
	MOVE.L	8(A2,D1.W),8(A4)
	BNE.S	REPEAT
	CLR.L	16(A4)
REPEAT
COMMAND?
	MOVE	(A0)+,D0
	MOVE.B	D0,D1
	AND	#$F00,D0
	LSR	#6,D0
	MOVE.L	(A3,D0.W),A5
	JMP	(A5)

NO_COMMAND
	RTS

ARPEGGIO
	TST.B	D1
	BEQ.S	NO_ARPEGGIO
	MOVE.B	#0,22(A4)
	MOVE.B	D1,23(A4)
	MOVE.B	#1,21(A4)		*ARPEGGIO COUNTER
	MOVE	#1,30(A4)
NO_ARPEGGIO
	RTS

PORTAMENTO_UP
	MOVE.B	#1,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

PORTAMENTO_DOWN
	MOVE.B	#2,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

POSITION_JUMP
	LEA	MUZEXX,A5
	ADD	SEQ(PC),A5
	LEA	-1(A5),A5
	MOVE.B	#1,POS
	MOVE.L	A5,D0
	ADD.L	D1,D0
	MOVE.L	D0,MUS+2
	MOVE.B	-1(A5),D0
	sub.w	D1,D0
	MOVE.B	D0,TRK
	RTS

SET_VOLUME
	TST.B	D1
	BNE.S	NO_CHANGE		*NO REAL TIME VOLUME VARIATION
	CLR.L	12(A4)			*IN THIS VERSION! MAYBE
	MOVE.B	#1,20(A4)		*SOME OTHER DAY...
NO_CHANGE
	RTS

PATTERN_BREAK
	MOVE.B	#1,POS
	RTS

SET_FILTER
	RTS

SET_SPEED
	MOVE.B	D1,SPD+3
	MOVE.B	D1,SPEED
	RTS

COMMAND		DC.L	ARPEGGIO,PORTAMENTO_UP,PORTAMENTO_DOWN,NO_COMMAND
		DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,NO_COMMAND
		DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,POSITION_JUMP
		DC.L	SET_VOLUME,PATTERN_BREAK,SET_FILTER,SET_SPEED

EFFECT	MOVEM.L	D4-D6/A4-A6,-(SP)
	LEA	FRQ(PC),A5
	LEA	VOICE0(PC),A6
	TST	30(A6)
	BEQ.S	CONT_EFFECT1
	BSR	DO_EFFECT
	MOVE.L	26(A6),V0+2
	TST.L	F0+2
	BEQ.S	CONT_EFFECT1
	MOVE.L	26(A6),F0+2
CONT_EFFECT1
	LEA	VOICE1(PC),A6
	TST.w	30(A6)
	BEQ.S	CONT_EFFECT2
	BSR.s	DO_EFFECT
	MOVE.L	26(A6),V1+2
	TST.L	F1+2
	BEQ.S	CONT_EFFECT2
	MOVE.L	26(A6),F1+2
CONT_EFFECT2
	LEA	VOICE2(PC),A6
	TST	30(A6)
	BEQ.S	CONT_EFFECT3
	BSR.s	DO_EFFECT
	MOVE.L	26(A6),V2+2
	TST.L	F2+2
	BEQ.S	CONT_EFFECT3
	MOVE.L	26(A6),F2+2
CONT_EFFECT3
	LEA	VOICE3(PC),A6
	TST	30(A6)
	BEQ.S	CONT_EFFECT4
	BSR.s	DO_EFFECT
	MOVE.L	26(A6),V3+2
	TST.L	F3+2
	BEQ.S	CONT_EFFECT4
	MOVE.L	26(A6),F3+2
CONT_EFFECT4
	MOVEM.L	(SP)+,D4-D6/A4-A6
	RTS

DO_EFFECT
	MOVE.B	22(A6),D4
	BEQ.S	ARPEGGIO_ROUT
	CMP.B	#1,D4
	BEQ.S	PORTUP
	CMP.B	#2,D4
	BEQ.S	PORTDOWN
	RTS

PORTUP	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	SUB	D4,D5
	CMP	#$71,D5
	BPL.S	OK_PORTUP
	MOVEQ	#$71,D5
OK_PORTUP
	MOVE	D5,24(A6)
	ADD	D5,D5
	ADD	D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

PORTDOWN
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	ADD	D4,D5
	CMP	#$358,D5
	BMI.S	OK_PORTDOWN
	MOVE	#$358,D5
OK_PORTDOWN
	MOVE	D5,24(A6)
	ADD.w	D5,D5
	ADD.w	D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

ARPEGGIO_ROUT
	MOVE.B	21(A6),D4
	CMP.B	#1,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#2,D4
	BEQ.S	ARP_ROUT2
	CMP.B	#3,D4
	BEQ.S	ARP_ROUT3
	CMP.B	#4,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#5,D4
	BEQ.S	ARP_ROUT2
	RTS

ARP_ROUT1
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	LSR.B	#4,D4
	BRA.S	ARP_ROUT
ARP_ROUT2
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	AND.B	#$0F,D4
	BRA.S	ARP_ROUT
ARP_ROUT3
	MOVE	24(A6),D6
	BRA.S	END_ARP_ROUT2
ARP_ROUT
	ADD	D4,D4
	MOVE	24(A6),D5
	LEA	ARPEGGIO_DATA(PC),A4
ARP_LOOP
	CMP	(A4),D5
	BEQ.S	END_ARP_ROUT1
	LEA	2(A4),A4
	BRA.S	ARP_LOOP
END_ARP_ROUT1
	MOVE	(A4,D4),D6
END_ARP_ROUT2
	ADD	D6,D6
	ADD	D6,D6
	MOVE.L	(A5,D6),26(A6)
	ADDQ.B	#1,21(A6)
	RTS

RESTART	MOVEM.L	(SP)+,D0-D1/A0-A5
	MOVE.b	#6,SPD+2 
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA	MUZEXX,A0
	ADD.w	SEQ(pc),A0
	LEA	-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA	OFF2,A0
	LEA	OFF2,A1
	LEA	OFF2,A2
	LEA	OFF2,A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2
	BRA	PLAY

end_of_musix
	MOVE	#$2700,SR
	RTS

vsync	SF		SWITCH
WAIT_VBL
	TST.B	SWITCH
	BEQ.S	WAIT_VBL
	bsr	set_screen
	RTS


****************
* DATA SECTION *
****************

	SECTION	DATA

OFF2		DC.L	0
SPEED		DC.B	0
POS		DC.B	0
TRK		DC.B	0
SEQ		DS.W	1
PAT		DS.W	1
NBR_INS		DS.W	1
FRQ		INCBIN	10_KHZ.FRQ
ARPEGGIO_DATA	DC.W	$0358,$0328,$02FA,$02D0,$02A6,$0280,$025C
		DC.W	$023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D
		DC.W	$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0
		DC.W	$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097
		DC.W	$008F,$0087,$007F,$0078,$0071,$0000,$0000,$0000


SAVE_INT	DS.L	17
TIMERA		DS.L	1
SWITCH		DS.W	1
KEY_PRESS	DS.W	1
VOICE0		DS.L	8
VOICE1		DS.L	8
VOICE2		DS.L	8
VOICE3		DS.L	8
ADD_IN_PAT	DS.L	1
INS		DS.L	32*4

olda09	dc.b	0
olda15	dc.b	0
old484		dc.w	0
hertz_toggle	dc.w	0
old_base	dc.l	0
stack_save	dc.l	0
org_rez		dc.w	0
old_palette	ds.w	16
zero_counter	dc.w	10
file_offset	dc.w	0
byte_toggle	dc.w	0
tmp1		dc.l	0
tmp2		dc.l	0
tmp4		dc.l	0
store_a0	dc.l	0
store_a2	dc.l	0
scroll_pointer	dc.l	init_scroll_text
init_scroll_text
	dc.b	"                         .    .   .  .  . ."
	dc.b	"..........................................."
scroll_text
 dc.b "PERSISTENCE OF VISION DISC 96.        "
 DC.B "RELEASED DATE: 12/10/91          "
 dc.b "         CREDITS FOR THIS MENU GOTO......"
 dc.b "      CODING BY MAC SYS DATA,   AMAZING GRAFIX BY OZ   AND   AMIGA SOUNDTRACKER MOD "
 dc.b "STOLEN BY MAC SYS DATA FROM KEFRENS MEGADEMO 8.          "
 DC.B "ANY LAMERS OUT THERE WHO THINK THIS MENU IS A BIT "
 DC.B "BARE, THINK AGAIN.     THIS IS A NOISE TRACKER MODULE NOT SOME HISSY "
 DC.B "TCB TRACKER THING.          YEAH! WATCH THOSE BOBS GO......   "
 DC.B "      THIS DISC IS PUBLIC DOMAIN. COPY IT 80 TRACKS, 10 SECTORS AND "
 DC.B "DOUBLE SIDED.         "
 DC.B "WELL, AT LAST I RECEIVED SOME NEW DEMOS. IT APPEARS THAT OUR NAME "
 DC.B "IS SPREADING A LITTLE, WE HAVE HAD GREETS FROM 7 GROUPS NOW (WOW!).   "
 DC.B "  THE LATEST CREW TO GREET US IS CALLED 'THE STUDS' AND THEY WRITE CRAP "
 DC.B "MASTERSOUND DEMOS.   LOOK GUYS, YOU'D BETTER GET A GRAFIX ARTIST "
 DC.B "SOON 'CAUSE MY 10 YEAR OLD NEPHEW CAN DO BETTER GRAFIX.   "
 DC.B "        IF YOU HAVE GREETED US AND WE HAVN'T MENTIONED YOU "
 DC.B "THEN IT'S PROBABLY BECAUSE WE HAVN'T SEEN YOUR STUFF.  IF YOU WANT "
 DC.B "TO SEND YOUR DEMOS, ETC. TO US FOR ME TO PACK OR JUST FOR "
 DC.B "US TO SEE YOUR GREETS THEN SENT IT TO..        MAC SYS DATA,        "
 DC.B "P.O. BOX 40,        THORNTON-CLEVELEYS,        BLACKPOOL,        "
 DC.B "FY5 3PH.            OR PHONE BORIS ON  0532 ......        (NO, I'D BETTER NOT!!!)."
 DC.B "          RIGHT, HERE WE GO WITH THE MASSIVE GREETING LIST (WELL "
 DC.B "IT'S NOT THAT BIG).            SUPER GREETS TO THE FOLLOWING "
 DC.B "GROUPS WHO HAVE GREETED US...          RIPPED OFF,        "
 DC.B "THE SOURCE,        HIDDEN STRENGTH,        THE STUDS,        "
 DC.B "NORTH SIDE,       DTB     AND     NOW 5.   (I'M SURE THERE IS "
 DC.B "MORE THAN THIS BUT I CANNOT REMEMBER WHO.....)       NORMAL "
 DC.B "GREETS TO THE FOLLOWING WHOSE WORK WE SEE QUITE REGULARLY....   "
 DC.B "  AUTOMATION,        MEDWAY BOYS,        REPLICANTS,        "
 DC.B "POMPEY PIRATES,        LOST BOYS,        SEWER SOFTWARE,        EMPIRE    "
 DC.B "AND    SLAYTANIC CULT.          NO GREETS 'CAUSE YOU NEVER GREETED US TO... "
 DC.B "     ER,    EVERYONE ELSE!!!           FINALLY, FRIENDLY GREETS TO PEOPLE WHO "
 DC.B "WE HAVE REGULAR CONTACTS WITH...     DEL (AT D.W. STABLES),"
 DC.B "        GEORGE S. (AT TOWER PD),        "
 DC.B "ANDREW (AT PDOM)    AND    "
 DC.B "MARTYN (AT SWSL).          "
 DC.B "      HAVE YOU NOTICED HOW MANY DEMO PACKING CREWS "
 DC.B "HAVE SUDDENLY STARTED UP?        I RECEIVED ABOUT 4 DISCS FROM "
 DC.B "DIFFERENT GROUPS WHO ALL PROCLAIM THEY ARE GOING TO TAKE OVER THE "
 DC.B "ST!        ONE GROUP WHO HAVE STARTED PACKING DEMOS IS 'NOW 5'.   HEY BOYS IF YOU WANT TO COMPETE GET IN TOUCH AND "
 DC.B "I'LL SEND YOU SOME MENU SOURCE CODE   (THANKS FOR THE "
 DC.B "MENTION ON DISC 3!).             QUITE A FEW OF THE GROUPS WHO "
 DC.B "HAVE STARTED UP HAVE MENTIONED P.O.V. ON THE SCROLL TEXT AND THAT WE "
 dc.b "HAD BETTER WATCH OUT 'CAUSE THEY ARE GOING TO WALK ALL OVER US. I GUESS "
 DC.B "THAT THIS MEANS THEY RECOGNISE US AS THE BEST DEMO COMPILATION GROUP. "
 DC.B "     I THINK IT'S GREAT THAT PEOPLE ARE LOOKING UP TO US AND TRYING "
 DC.B "TO EQUAL US IN STYLE AND QUALITY! ( YEAH!!! ).          "
 DC.B "IN THE LAST BATCH I GOT A 'PROJECT A' DISC AND I "
 DC.B "LAUGHED MY SOCKS OFF - HEY GUYS, YOU REALLY MUST PACK THE DATA FILES "
 DC.B "TO COMPETE.  IF YOU CHECK OUT LATER P.O.V. MENUS YOU WILL FIND "
 DC.B "I'VE PACKED YOUR DISC AND PUT IT ON ONE OF OURS  ( NICE AND SMALL "
 DC.B "IT IS TOO ).        HEY BILBO, I'VE PACKED RIPPED OFF 83 AND SAVED "
 DC.B "OVER 75K!!!!   WHY DID ROGGIE NOT PACK THE TRACKER.ROT FILES????   "
 DC.B "        I THINK I MAY BE MAKING ENEMIES BY PACKING OTHER GROUPS "
 DC.B "STUFF SMALLER BUT SO WHAT?       THE SOURCE PROCLAIMED THEY COULD "
 DC.B "PACK DEMOS SMALLER THAN ANY OTHER GROUP...... WELL, I "
 DC.B "UNPACKED SOME OF THEIR DEMOS FROM DISC 56 AND REPACKED THEM AND "
 DC.B "..... OH DEAR THEY GOT SMALLER....  SORRY GUYS BUT YOU'RE LAMERS!!! "
 DC.B "       YO, WITH SCROLL TEXT LIKE THIS I THINK I MUST CHANGE MY NAME "
 DC.B "TO THE 'ALIEN'!!!!! (POMPEY PIRATE FANS WILL KNOW WHAT I MEAN).   "
 DC.B "       ( NOT THAT WE ARE FANS BY THE WAY! ).             "
 DC.B "I MUST MENTION THAT THE 'HIDDEN STRENGTH' SCREEN ON THIS DISC WAS "
 DC.B "ACTUALLY CODED BY 'NINJA'.  THE SCREEN WENT ONTO THE 'STATE OF THE ART' MEGADEMO "
 DC.B "BY THE WILD BOYS.   SHORTLY AFTER THIS 'HIDDEN STRENGTH' SPLIT UP "
 DC.B "AND NINJA IS NOW A MEMBER OF 'THE ENTERPRISE', THE CONTACT ADDRESS "
 DC.B "IN THE S.O.T.A. SCREEN IS STILL THE SAME BUT ADDRESS IT TO 'THE ENTERPRISE' "
 DC.B "AND NOT 'HIDDEN STRENGTH'   OKAY?        RIGHT, I THINK THAT'S "
 DC.B "IT FOR NOW SO I'LL BOG OFF AND GET SOME MORE WORK DONE AS I'VE DONE "
 DC.B "BUGGER ALL LATELY ON P.O.V. DISCS AS THE NEW GIRL IN MY LIFE  ( DAWN )  IS "
 DC.B "TAKING ALL MY TIME UP.   SO UNTIL WE MEET AGAIN IT'S CHEERY-BYE FROM MAC SYS DATA. "
 dc.b "                                                "
 dc.b "                                                "
 dc.b "                                                "
 DC.B $ff
	even
font_pal
	dc.w	$000,$230,$450,$670

char_offset	dc.w	0
font		dcb.b	23*(4*2),0
		incbin	font.dat
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,44,43,00,45,00,42,51,46,47,00,00,49,00,48,29

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	41,31,32,33,34,35,36,37,38,39,59,58,00,00,00,43,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,11,12,13,14,15,16,17,18

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	19,21,22,23,24,25,26,27,28,40,00,41,00,47,00,48,49,50

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	even




bob_1_pos	dc.l	0	;position in table
last_1_pos	dc.l	0	;last offset in screen position
		dc.l	0	;second to last offset in screen pos
bob_2_pos	dc.l	0
last_2_pos	dc.l	0
		dc.l	0
bob_3_pos	dc.l	0
last_3_pos	dc.l	0
		dc.l	0
bob_4_pos	dc.l	0
last_4_pos	dc.l	0
		dc.l	0
bob_5_pos	dc.l	0
last_5_pos	dc.l	0
		dc.l	0


bob_paths
	incbin	bob_paths.dat
endbobs

bob_pic	incbin	bob_pic.pi1
pic	incbin	pic.pi1
	ds.b	160*45

black	dcb.b	34,0
	even

scr_now	dc.l	0
scr_xor	dc.l	0

bob_countdown	dc.w	255

bob_string	dc.w	11,11,11,11,11	;'LIVE' values table used by BOB routine


bob_string_offset	dc.w	4
bob_string_table
	dc.l	pov_string
	dc.l	msd_string
	dc.l	oz_string
	dc.l	boris_string
	dc.l	fade_1_string
	dc.l	fade_2_string
	dc.l	mixed_string
	dc.l	combin_string
	dc.l	-1

P	equ	0
O	equ	1
V	equ	2
M	equ	3
S	equ	4
D	equ	5
Z	equ	6
B	equ	7
R	equ	8
I	equ	9
MIN	equ	10
DOT	equ	11


pov_string	dc.w	P,DOT,O,DOT,V	;P.O.V.
		dc.w	255			;length of 1/50 before change
msd_string	dc.w	M,DOT,S,DOT,D	;M.S.D.
		dc.w	400
oz_string	dc.w	O,Z,MIN,O,Z	;OZ-OZ
		dc.w	200
boris_string	dc.w	B,O,R,I,S	;BORIS
		dc.w	400
fade_1_string	dc.w	MIN,MIN,MIN,MIN,MIN	;-----
		dc.w	200
fade_2_string	dc.w	DOT,DOT,DOT,DOT,DOT	;.....
		dc.w	100
mixed_string	dc.w	MIN,DOT,MIN,DOT,MIN	-.-.-
		dc.w	250
combin_string	dc.w	MIN,P,O,V,MIN
		dc.w	400

present_bob_grafic
	dc.l	logo

logo	REPT	16
	ds.b	8*16*12		;width*depth*no.bobs
	ENDR

	REPT	16
	ds.b	8*16
	ENDR

	REPT	16
	ds.b	8*16*12		;width*depth*no.bobs
	ENDR

	REPT	16
	ds.b	8*16
	ENDR


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

filenames
	dc.l	file1
	dc.l	file2
	dc.l	file3
	dc.l	file4
	dc.l	file5
	dc.l	file6

file1	dc.b	"MONEY.MSD",0
	even
file2	dc.b	"$$CULT6.MSD",0
	even
file3	dc.b	"SOTA.POV",0
	even
file4	dc.b	"ANCOOL.POV",0
	even
file5	dc.b	"EPSIDEMO.POV",0
	even
file6	dc.b	"COPIER.POV",0
	even


	ds.b	1024
screens	ds.b	39680
	ds.b	39680

MUZEXX	incbin	rot.mod
	END