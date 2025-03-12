*************************************************************************
*				P.O.V. 105				*
*				----------				*
*									*
* Written by: MAC SYS DATA						*
* 	Date: 23-12-91							*
* Assemble with GENST2 version 2.08 or higher				*
*									*
* Amiga tracker menu with lower border code (STE compatable as well!)	*
*									*
* Files needed:								*
*		KGB15.MOD						*
*		10_KHZ.FRQ						*
*		348.FNT 						*
*		PRE_POV1.PI1						*
*		POV105.PI1						*
*									*
*************************************************************************


	SECTION	TEXT

	bsr	menu
	move.b	#$8,$fffffc02.w
	move.b	old484,$484.w
	tst.w	hertz_flag
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50	move.l	old_base,a0
	bsr	set_org_rez
	bsr	set_old_pal

	cmp.b	#-1,file_offset
	beq.s	exit

	moveq.l	#0,d0
	move.b	file_offset,d0
	lsl.w	#2,d0
	lea	filenames,a6
	add.w	d0,a6
	move.l	(a6),a6
	lea	$200.w,a0
	movem.l	(a6),d0-d3
	movem.l	d0-d3,(a0)

exit
	bsr	set_user
	clr.w	-(sp)
	trap	#1
*********** Valid keys for demos, disable any not used **********
key_codes
	dc.b	2,0	;key 1
	dc.b	3,1	;key 2
	dc.b	4,2	;key 3
;	dc.b	5,3	;key 4
;	dc.b	6,4	;key 5

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1	;keypad 2
	dc.b	$6f,2	;keypad 3
;	dc.b	$6a,3	;keypad 4
;	dc.b	$6b,3	;keypad 5
	dc.b	$ff
	even

filenames	dc.l	exec1,exec2,exec3

exec1	dc.b	"hackers.",0	;key 1
	even
exec2	dc.b	"$$filename.ext",0	;key 2
	even
exec3	dc.b	"COPIER.POV",0	;key 3
	even

menu	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,stack_save
	move.b	#2,$ffff820a.w	;50Hz
	move.b	#$12,$fffffc02.w

	move.b	$484.w,old484
	and.b	#$fe,$484.w
	bsr	get_old_pal
	bsr	get_screen_base
	bsr	get_org_rez
	bsr	set_low_rez
	bsr	do_intro
	bsr	set_up

	move.l	#font_offsets,store_a2

	lea	pic+2,a1
	bsr	fadein

	jsr	SAVE_INTERRUPTS(PC)
	jsr	main

* return to here from module when exit

	move.b	#$8,$fffffC02.w
	jsr	REINSTALL_INTERRUPTS
	rts

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

main	MOVE	#$2700,SR
	JSR	INIT_module(PC)
	JSR	PLAY_module(PC)
	JSR	REINSTALL_INTERRUPTS(PC)
	rts

INIT_module
	LEA	SEQ(PC),A0
	LEA	PAT(PC),A1
	LEA	NBR_INS(PC),A2
;	LEA	module,A3
	MOVE	#$1D8,(A0)
	MOVE	#$258,(A1)
	MOVE	#15,(A2)
;	CMP.L	#'M.K.',$438(A3)    ;don't need this as it is a M.K. mod
;	BNE.s	REAL_DOCs_MODULE
	MOVE	#$3B8,(A0)
	MOVE	#$43C,(A1)
	MOVE	#31,(A2)
REAL_DOCs_MODULE
	LEA	module,A0
	ADD	SEQ(PC),A0
	MOVE.L	#$80,D0
	MOVEQ	#0,D1
INIT_module1
	MOVE.L	D1,D2
	SUBQ	#1,D0
INIT_module2
	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	INIT_module1
	DBF	D0,INIT_module2
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	LEA	module,A0
	ADD	PAT,A0
	ADD.L	D2,A0
	LEA	20+module,A1
	LEA	16+INS(PC),A2
	MOVE	NBR_INS(PC),D0
	SUBQ	#1,D0
INIT_module3
	MOVE.L	A0,4(A2)
	MOVEQ	#0,D1
	MOVE	22(A1),D1
	LSL.L	#1,D1
	MOVE.L	D1,(A2)
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE	24(A1),D1
	BEQ.s	INIT_module4
	SUBQ	#1,D1
INIT_module4
	MOVE	D1,12(A2)
	MOVEQ	#0,D1
	MOVE	28(A1),D1
	LSL.L	#1,D1
	CMP.L	#2,D1
	BNE.s	INIT_module5
	MOVEQ	#0,D1
INIT_module5
	SWAP	D1
	MOVE.L	D1,8(A2)
	LEA	30(A1),A1
	LEA	16(A2),A2
	DBRA	D0,INIT_module3

	LEA	16+INS(PC),A0
	MOVEQ	#0,D0
	MOVE	4+SAVE_INT(PC),D0
	LSL.L	#8,D0
	SUB.L	#$8000,D0
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
	LEA		16(A0),A0
	DBRA	D0,REVERSE
	RTS

PLAY_module
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
	LEA	module,A0
	ADD	SEQ(PC),A0
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
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2

	BCLR	#3,$FFFFFA17.W
	move.B	#$21,$FFFFFA07.W
	move.b	#0,$fffa09
	move.B	#$21,$FFFFFA13.W
	move.b	#0,$FFFFFA15.W
	move.b	#$11,$FFFFFA19.W
	move.b	#$3c,$FFFFFA1f.W

	MOVE.L	#AMIGA,$134.W
	MOVE.L	#VBL,$70.W
	move.l	#new120,$120.w

	MOVE	#$2300,SR
	CLR.B	KEY_PRESS

* REGISTERS LEFT ARE D4-D5-D6-D7/A4-A5-A6
main_loop
	jsr	vsync
raster	move.w	#$0,$ffff8240.w
	bsr	scroll
	tst.w	raster+2
	beq.s	.no_raster
	move.w	font_pal,$ffff8240.w	;code to stop hertz indicator
.no_raster				;bar from flickering when raster
	tst.w	zero_counter		;is shown
	beq.s	.check
	subq.w	#1,zero_counter
.check
	tst.w	help_counter
	beq.s	.check2
	subq.w	#1,help_counter

.check2
	move.b	$fffffc02.w,d7

	cmp.b	#01,d7		;escape
	beq.s	set_exit

	cmp.b	#$b,d7		;0 key
	beq.s	zero

	cmp.b	#$70,d7		;0 keypad
	beq.s	zero

car	cmp.b	#$53,d7
	beq.s	do_reset

	cmp.b	#$62,d7
	beq.s	help

not_help
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
	eor.w	#-1,hertz_flag
	move.w	#10,zero_counter
	bra	main_loop

help	tst.w	help_counter
	bne.s	not_help
	eor.w	#$200,raster+2
	move.w	#10,help_counter
	bra	main_loop

set_exit
	move.b	#-1,file_offset
	bra	end_of_musix
load
	move.b	(a6),file_offset
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
	sub.b	#32,d7

	ext.w	d7

	move.l	d5,tmp1
	move.l	#font,store_a0

	move.l	a5,tmp2
	move.l	store_a2,a5
	move.b	(a5,d7),d5
	move.l	a5,store_a2
	move.l	tmp2,a5

	and.l	#$ff,d5
	mulu	#(31*4)*4,d5		;30 * 4 (4 planes)
	add.l	d5,store_a0

	move.w	d6,d5
	mulu	#(31*4),d5		;character depth * 4 (30*4)
	add.l	d5,store_a0
	move.l	tmp1,d5

	move.l	a4,tmp4
	move.l	store_a0,a4
.column
OFF	set	0
	REPT	31
	move.l	(a4)+,d4
	movep.l	d4,OFF(a6)
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

get_old_pal
	lea	$ffff8240.w,a0
	lea	old_palette,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

set_new_pal
	lea	pic+2,a0
	bra.s	set_pal
set_old_pal
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

get_org_rez:
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
set_rez:
	move.l	old_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
t	rts

set_up	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#39680,d1
	eor.l	d0,d1
	move.l	d1,scr_xor

	lea	pic+34,a0
	move.l	scr_now,a1
	move.l	a1,a2
	add.l	#39680,a2
	move.w	#32000/4-1,d0
sho	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,sho

	move.l	scr_now,a0
	add.w	#32000,a0
	move.l	a0,a1
	add.l	#39680,a1
	moveq	#0,d1
	move.w	#(160*45)/4,d0
.loop	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbf	d0,.loop
	bsr.s	set_screen
	nop

set_screen
	move.l	scr_now,d6
	move.l	scr_xor,d7
	eor.l	d7,d6
	move.l	d6,scr_now
	lsr.l	#8,d6
	lea	$ffff8201.w,a6
	movep.w	d6,(a6)
	rts

do_intro
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	intro_pic+34,a0
	move.l	old_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	lea	intro_pic+2,a1
	bsr.s	fadein
	move.w	#5000,d7
.pau	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bmi.s	.ex
	dbf	d7,.pau
.ex	lea	black,a1
	bsr.s	fadein

	lea	pic+34,a0
	move.l	old_base,a1
	move.w	#32000/4-1,d0
.sho	move.l	(a0)+,(a1)+
	dbf	d0,.sho
	rts

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadein	move.w	#8-1,d6
	move.l	a1,a2
FADEIN1	lea	$ffff8240.w,a0	; TARGET IN A1
	move.w	#16-1,d7
FADEIN2	BSR.s	MODIFY
	addq.w	#2,a0
	addq	#2,a1
	dbf	d7,FADEIN2
	move.w	#4,d0
	BSR.s	WAIT
	move.l	a2,a1
	dbf	d6,FADEIN1
	rts

WAIT	bsr.s	v_sync
	DBRA D0,WAIT
	RTS

MODIFY	MOVE (A0),D0
	MOVE (A1),D1 ;TARGET
	MOVE D0,D4	;NEW COL
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

v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
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
WB	RTE				;20(5/0)

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


new120	clr.b	$fffffa1b.w	;stop another interrupt
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

	movem.l	a0/a1,-(sp)
	lea	font_pal+2,a0
	lea	$ffff8242.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	movem.l	(sp)+,a0/a1
	rte

VBL	MOVE	#$2700,SR
	clr.b	$fffffa1b.w
	SUBQ.B	#1,SPEED
	BEQ.S	PLAY
	JSR	EFFECT
END_VBL	ST	SWITCH
	lea	pic+2,a5
	lea	$ffff8240.w,a6
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
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
	BMI	RESTART
	MOVEQ	#0,D0
MUS	MOVE.B	$0,D0
	SWAP	D0
	LSR.L	#6,D0
	LEA	module,A0
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
	LEA	module,A5
	ADD	SEQ(PC),A5
	LEA	-1(A5),A5
	MOVE.B	#1,POS
	MOVE.L	A5,D0
	ADD.L	D1,D0
	MOVE.L	D0,MUS+2
	MOVE.B	-1(A5),D0
	SUB	D1,D0
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

PORTUP
	MOVEQ	#0,D4
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

RESTART
	MOVEM.L	(SP)+,D0-D1/A0-A5
	MOVE.b	#6,SPD+2 
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA	module,A0
	ADD	SEQ,A0
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

vsync	SF	SWITCH
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
hertz_flag	dc.w	0
old484		dc.w	0
old_base	dc.l	0
stack_save	dc.l	0
old_palette	ds.w	16
zero_counter	dc.w	10
help_counter	dc.w	10
file_offset	dc.w	0
byte_toggle	dc.w	0
tmp1		dc.l	0
tmp2		dc.l	0
tmp4		dc.l	0
store_a0	dc.l	0
store_a2	dc.l	0
org_rez		dc.w	0
scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "                    "
 dc.b "PERSISTENCE OF VISION DEMO COMPILATION 105.               "
 DC.B "CODING - M.S.D,          "
 DC.B "GRAFIX - OZYMANDIAS,          "
 DC.B "MUSIC - RED MERCURY OF KGB (FRANCE),          "
 DC.B "THIS DISC WAS RELEASED ON 30-1-92.          "
 DC.B " PLEASE NOTE... THERE ARE SEVERAL CREWS NOW USING MENUS CODED "
 DC.B "BY MYSELF (MAC SYS DATA).  I HAVE SENT MENUS TO THE FOLLOWING "
 DC.B "CREWS.... NOW 5,  THE SOURCE,  ADRENALIN,  THE FORCE  AND  ELECTRONIC.   "
 DC.B "IF YOU SEE MENUS BY ME ON ANY OTHER CREWS DISCS THEN THEY HAVE "
 DC.B "BEEN PASSED MY CODE BY SOMEONE ELSE.   THE MENUS SENT OUT LOOK LIKE "
 DC.B "THIS (A PICTURE, LOWER BORDER AND NOISETRACKER MOD) THE OTHER MENU "
 DC.B "LOOKS LIKE POV 55 BUT WAS IN FACT COMPLETELY REWRITTEN.      IF YOU "
 DC.B "SEE ANY LAMERS CLAIMING TO HAVE WRITTEN THE MENU THEN TRASH "
 DC.B "THEIR DISCS AS THEY ARE OBVIOUSLY MEGA LAMERS.        "
 DC.B "    GREETINGS TO......       ABC CREW,      BBC,      "
 DC.B "BLACK CATS,      BLIND BASTARD,      DR. SYNE,      DEL,      "
 DC.B "ERIK PLANKTON,      EMPIRE,      "
 DC.B "EQUINOX,      GEORGE TOWER PD (BART!),      INNER CIRCLE,      "
 DC.B "KGB,     LOST BOYS,      MARTIAN,      MEDWAY BOYS,     OBERJE,      "
 DC.B "OVERLANDERS,      POMPEY PIRATES,      REPLICANTS,      SEWER SOFTWARE,      "
 DC.B "SLAYTANIC CULTS,      SOURCE,      ST CNX,      TEX,      "
 DC.B "TCB,     ELECTRONIC    AND    WATCHMEN      MEGA GREETINGS TO....... "
 DC.B "RIPPED OFF (BILBO AND STICK),      ADRENALIN,      BORIS,      "
 DC.B "PIXEL TWINS,      ROB POVEY,      "
 DC.B "AND    ALY.                                               "
 DC.B "                         RIGHT HERE ARE VIEWS BY MYSELF ABOUT THE "
 DC.B "'PD CONFEDERACY'....      "
 DC.B "WHY DO WE NEED THE 'PD CONFEDERATION?'      WHAT THE HELL IS IT "
 DC.B "MEANT TO BE?       IT APPEARS THAT IT IS A COUPLE OF LIBRARIES "
 DC.B "TRYING TO CLAIM THEY ARE THE BEST AND THAT ANY LIBRARY NOT IN "
 DC.B "THE FED IS CRAP.   WELL TELL ME, WHY IS SOUTH WEST SOFTWARE LIBRARY "
 DC.B "NOT IN 'CAUSE HE IS SHIT HOT?     WHAT ABOUT PDOM AND SOFTVILLE?   "
 DC.B "    IF PD LIBRARIES ARE FAST, EFFICIENT AND SUPPLY GOOD PD AT "
 DC.B "LOW PROCES THEN THEY WILL GET A GOOD REPUTATION AND LOTS OF TRADE. "
 DC.B "     SO TO ALL PEOPLE CLAIMING 'WE ARE IN THE FED SO WE MUST GOOD' I HAVE "
 DC.B "ONE MESSAGE 'F*** *** AND ..'    (DELETED AS IT MAY OFFEND).      "
 DC.B "           PLEASE CONTACT ME "
 DC.B "AND TELL ME WHAT THE AIM IS OF THE 'FED AND WHY IS ST-FORMAT NOW BIAS TOWARDS "
 DC.B "PD LIBRARIES IN THE 'FED.         "
 DC.B "MY PERSONAL FAVE PD LIBRARIES ARE -     SOUTH WEST SOFTWARE LIBRARY,     "
 DC.B "PDOM,     D.W. STABLES,   PROPHECY   AND   TOWER PD.   NOTE THAT THESE ARE "
 DC.B "MY CHOICE OF LIBRARIES AND NOT ALL POV MEMBERS (MSD).   "
 DC.B "    RIGHT THAT'S ENOUGH FOR NOW, I EXPECT TO BE BANNED FROM "
 DC.B "THE KEYBOARD FOR THE NEXT 6 MONTHS!     BYE.               "
 DC.B "                                                           "
 DC.B "                                                           "
 dc.b	$ff
	even
font_pal
	incbin	font.col


char_offset	dc.w	0
font		dcb.b	(31*4)*4,0
		incbin	ripp_off.fnt
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,01,07,00,00,00,00,07,08,09,00,00,12,13,14,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	16,17,18,19,20,21,22,23,24,25,26,27,00,00,00,31,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	50,51,52,53,54,55,56,57,58,40,00,00,00,00,00,33,34,35

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53

;        v  w  x  y  z
 dc.b	54,55,56,57,58

	even

intro_pic
	incbin	pov_pre1.pi1
pic	incbin	pov105.pi1
black	dcb.b	34,0
	even
scr_now	dc.l	0
scr_xor	dc.l	0

	ds.b	1024
screens	ds.b	39680
	ds.b	39680

module	incbin	kgb15.mod	;mod must be last thing in menu

	END