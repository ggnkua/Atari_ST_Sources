*************************************************************************
*
* Adrenalin menu coded by MAC SYS DATA of POV
*
* Credit me if ya use it. MSD 4th Sept 1992
*
*
*
*
*
*
*
*
*
*
*
*
**************************************************************************

sort_plasma	MACRO
	move.w	(a2)+,d0
	lsl.w	d0,d0		;dummy instr for timing
	move.l	(a0)+,a4
	add.w	(a1)+,a4
	nop			;4 cycles
	move.w	(a2)+,d0
	lsl.w	d0,d0		;dummy instr for timing
	ENDM

move_plasma	MACRO
	dcb.w	37,$369c	;move.w	(a4)+,(a3)
	ENDM



	pea	menu(PC)
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	clr.w	-(sp)
	trap	#1

menu	move.b	#$12,$fffffc02.w	
	jsr	save_all
	JSR	SET_REZ
	JSR	GET_SCREEN_ADRS
	JSR	BLACK
	JSR	CLEAR_SCREENS

	JSR	print_titles

	MOVE.L	#$FB,D7
L0782:	JSR	CALCUL_WAVE
	DBF	D7,L0782
	JSR	INIT

space	move.w	#-1,vsync_flag
.main	tst.w	vsync_flag
	bne.s	.main

;	move.w	#$123,$ffff8240.w

	tst.w	KEY_FLAG
	bne	space
	MOVE.W	#4,KEY_FLAG
;	clr.w	$ffff8240.w

	move.b	$fffffc02.w,d0


	cmp.b	#1,d0			;ESCape key (remove in final)
	beq.s	ex

		cmp.w	#$b,d0			;0 key
		beq	zero

		cmp.w	#$70,d0			;0 keypad
		beq	zero

		cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
		beq	reset

		lea	demo_keys,a0
.next		move.w	(a0)+,d1
		bmi.s	space
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


ex	JSR	RESTORE_CONFIGUR

*** now check hertz and exit cleanly...
		tst.w	hertz_switch		;has hertz been pressed?
		beq.s	hz50			;no so it stays in 50Hz
		eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50		move.b	#8,$fffffc02.w		;mouse back on

	MOVE.B	#8,$FFFFFC02.W
	MOVE.W	#1,-(A7)
	PEA	$FFFFFFFF.L
	PEA	$FFFFFFFF.L
	MOVE.W	#5,-(A7)
	TRAP	#$E
	ADDA.L	#$C,A7
	RTS

reset		move.l	4.w,-(sp)
		rts

zero		eor.w	#$003,$ffff8240.w	;show a hertz change
		eor.w	#$ffff,hertz_switch	;toggle a check
		bra	space

save_all	move.w	#$2700,sr		;off isrs
		lea	storage,a0
		movem.l	$ffff8240.w,d0-d7	;save pal
		movem.l	d0-d7,(a0)
		add.w	#32,a0
		move.b	$ffff8260.w,(a0)+	;save rez
		move.b	$ffff820a.w,(a0)+	;save hz
		move.l	$ffff8200.w,(a0)+	;save scrn base
		move.l	$68.w,(a0)+		;save HBL
		move.l	$70.w,(a0)+		;save VBL
		move.l	$110.w,(a0)+		;save timerD
		move.l	$114.w,(a0)+		;save timerC
		move.l	$118.w,(a0)+		;save keyboard/midi
		move.l	$120.w,(a0)+		;save timerB
		move.l	$134.w,(a0)+		;save timerA
		lea	$fffffa06.w,a1
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.b	$fffffa19.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa1d.w,(a0)+
		move.b	$fffffa1f.w,(a0)+
		move.b	$fffffa21.w,(a0)+	;save timerB data
		move.b	$fffffa25.w,(a0)+
		move.b	$fffffa17.w,(a0)+	;save vector base
		move.b	$484.w,(a0)+
		move.w	#$2300,sr
		rts

RESTORE_CONFIGUR
	MOVE	#$2700,SR
	lea	$ffff8800.w,a0
	MOVE.L	#$1010000,(a0)
	MOVE.L	#$2020000,(a0)
	MOVE.L	#$3030000,(a0)
	MOVE.L	#$4040000,(a0)
	MOVE.L	#$5050000,(a0)
	MOVE.L	#$6060000,(a0)
	MOVE.L	#$707FFFF,(a0)
	MOVE.L	#$8080000,(a0)
	MOVE.L	#$9090000,(a0)
	MOVE.L	#$A0A0000,(a0)
	lea	storage,a0
	lea	$ffff8240.w,a1
	MOVE.L	(a0)+,(a1)+
	MOVE.L	(a0)+,(a1)+
	MOVE.L	(a0)+,(a1)+
	MOVE.L	(a0)+,(a1)+
	MOVE.L	(a0)+,(a1)+
	MOVE.L	(a0)+,(a1)+
	MOVE.L	(a0)+,(a1)+
	MOVE.L	(a0)+,(a1)+
	MOVE.B	(a0)+,$FFFF8260.W
	MOVE.B	(a0)+,$FFFF820A.W
	MOVE.L	(a0)+,$FFFF8200.W
	MOVE.L	(a0)+,$68.W
	MOVE.L	(a0)+,$70.W
	MOVE.L	(a0)+,$110.W
	MOVE.L	(a0)+,$114.W
	MOVE.L	(a0)+,$118.W
	MOVE.L	(a0)+,$120.W
	MOVE.L	(a0)+,$134.W
	MOVE.L	(a0)+,$FFFFFA06.W
	MOVE.L	(a0)+,$FFFFFA0A.W
	MOVE.L	(a0)+,$FFFFFA0E.W
	MOVE.L	(a0)+,$FFFFFA12.W
	MOVE.B	(a0)+,$FFFFFA19.W
	MOVE.B	(a0)+,$FFFFFA1B.W
	MOVE.B	(a0)+,$FFFFFA1D.W
	MOVE.B	(a0)+,$FFFFFA1F.W
	MOVE.B	(a0)+,$FFFFFA21.W
	MOVE.B	#$C0,$FFFFFA23.W
	MOVE.B	(a0)+,$FFFFFA25.W
	MOVE.B	(a0)+,$FFFFFA17.W
	move.b	(a0)+,$484.w
	move.w	#$2300,sr
	rts

GET_SCREEN_ADRS
	LEA	SCR_ADR,A0
	MOVE.L	#SCREEN,D0
	ADDI.L	#$100,D0
	ANDI.L	#$FFFF00,d0
	MOVE.L	D0,(A0)
	RTS

BLACK	LEA	$FFFF8240.W,A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	RTS

CLEAR_SCREENS	LEA	SCREEN,A0
	MOVE.L	#$AF7,D0
	moveq	#0,d1
L078B	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	DBF	D0,L078B
	RTS
SET_REZ	PEA	VBL_REZ
	MOVE.L	(A7)+,$70.W
	MOVEQ	#$F,D7
L078D	STOP	#$2300
	DBF	D7,L078D
	PEA	WIDE_IT
	MOVE.L	(A7)+,$70.W
	RTS
WIDE_IT	RTE
	RTS
	MOVEQ	#3,d0
	LEA	$FFFF820F.W,A0
	MOVE.B	#$50,(A0)
	CMPI.B	#$50,(A0)
	BEQ.S	L078F
	MOVEQ	#1,d0
L078F	CLR.B	(A0)
	RTS
VBL_REZ	MOVE.B	#0,$FFFF8260.W
	MOVE.B	#0,$FFFF820A.W
	MOVE.L	#$7CF,D1
L0791:	DBF	D1,L0791
	MOVE.B	#0,$FFFF8260.W
	MOVE.B	#2,$FFFF820A.W
	RTE
INIT	CLR.B	$484.W
	BCLR	#3,$FFFFFA17.W
	MOVE.L	#0,$FFFFFA06.W
	MOVE.L	#0,$FFFFFA12.W
	PEA	NEW_HBL
	MOVE.L	(A7)+,$68.W
	PEA	NEW_VBL
	MOVE.L	(A7)+,$70.W
	rts

NEW_VBL	MOVE.W	#32,HBL_COUNTER
	MOVE	#$2100,SR
	clr.w	vsync_flag
	movem.l	d0-a6,-(sp)
	LEA	MY_PAL,A0
	LEA	$FFFF8240.W,A1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	MOVE.L	SCR_ADR,D0
	LSR.W	#8,d0
	MOVE.L	D0,$FFFF8200.W

	JSR	CALCUL_WAVE
	JSR	BO_PLASMA

;	move.w	#$0f0,$ffff8240.w
	JSR	ZIK+$98
;	clr.w	$ffff8240.w

	tst.w	KEY_FLAG
	beq.s	.clear
	sub.w	#1,KEY_FLAG
.clear	movem.l	(sp)+,d0-a6
	RTE

NEW_HBL	SUBQ.W	#1,HBL_COUNTER
	RTE


newkey	movem.l	d0,-(sp)
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

BO_PLASMA
	lea	PLASMA_TAB,a0
	MOVEA.L	OFFSET_ADR,a1
	MOVEA.L	DECAL_ADR,a2
	LEA	$FFFF8240.W,a3
	MOVEA.L	(A0)+,a4
	ADDA.W	(A1)+,a4
	LEA	$FFFF8209.W,a6
	MOVEQ	#0,d6
	STOP	#$2100

L0796	TST.W	HBL_COUNTER
	BPL.S	L0796
	STOP	#$2100
	MOVE	#$2300,SR
	MOVEQ	#$15,d3
L0797:	DBF	D3,L0797
	CLR.B	$FFFF820A.W
	MOVEQ	#8,d3
L0798:	DBF	D3,L0798
	MOVE.B	#2,$FFFF820A.W
L0799:	MOVE.B	(A6),d6
	BEQ.S	L0799
	NEG.W	D6
	LSL.L	D6,d6
	MOVEQ	#$16,d6
L079A:	DBF	D6,L079A
	NOP
	NOP
	MOVE.W	(A2)+,D0
	LSL.W	D0,d0

	REPT	227
	move_plasma
	sort_plasma
	ENDR

	REPT	34
	move.w	(a4)+,(a3)	;short move for allow for border knock out
	ENDR

	move.w	(a2)+,d0
	lsl.w	d0,d0		;dummy inst for timing
	move.l	(a0)+,a4
	move.b	#0,$ffff820a.w	;flip hertz to 60Hz
	add.w	(a1)+,a4
	move.w	(a2)+,d0
	lsl.w	d0,d0		;another dummy inst for timing
	nop			;wait 8 cycles
	nop
	move.b	#2,$ffff820a.w	;go 50 Hz

	REPT	23
	move_plasma
	sort_plasma
	ENDR
	move_plasma

	move.w	(a2)+,d0
	lsl.w	d0,d0
	move.l	(a0)+,a4
	add.w	(a1)+,a4
	nop
	clr.w	(a3)		;clear colour 0
	rts



CALCUL_WAVE	lea	OFFSET_TAB,a0
		move.l	OFFSET_OFF,d0
		add.l	d0,a0
		MOVE.L	a0,OFFSET_ADR
		lea	DECAL_TAB,a0
		move.l	DECAL_OFF,d0
		add.l	d0,a0
		move.l	a0,DECAL_ADR
		move.l	OFFSET_OFF,d0
		add.w	#2,d0

	cmp.l	#508,d0

	BLT.S	L07A9
	MOVEQ	#2,d0

L07A9	MOVE.L	D0,OFFSET_OFF
	MOVE.L	DECAL_OFF,D0
	ADDI.L	#4,d0

	cmp.l	#1016,d0

	BLT.S	L07AA
	MOVEQ	#4,d0
L07AA	MOVE.L	D0,DECAL_OFF
	MOVEA.L	OFFSET_ADR,a1
	MOVEA.L	DECAL_ADR,a2

	lea	COS_TAB,a3
	moveq	#0,d0
	moveq	#0,d1
	moveq	#10,d2
	move.w	ANG,d0
	MOVE.W	AMP,D1
	MOVE.W	0(A3,D0.W),d0
	MULS	D1,d0
	add.l	#$30000,D0
	LSR.L	D2,d0
	EXT.L	D0
	MOVE.L	D0,d1
	DIVU	#12,D1
	MOVE.L	D1,d2
	EXT.L	D1
	LSL.W	#1,d1
	MOVE.W	D1,-2(A1)
	MOVE.W	D1,504(A1)
	MOVE.L	D1,d4
	SWAP	D2
	EXT.L	D2
	ANDI.L	#$FFFFFFFC,d2
	LSR.L	#2,d2
	SUBQ.W	#1,d2
	TST.W	D2
	bpl.s	GO_ON
	moveq	#1,d1
	BRA.S	OPPOSITE_DECAL
GO_ON	MOVEQ	#-1,d1
SET_DEC_VALUE
	ADDQ.W	#2,d1
	DBF	D2,SET_DEC_VALUE
OPPOSITE_DECAL
	MOVEQ	#6,d3
	SUB.W	D1,d3
	SWAP	D3
	MOVE.W	D1,d3
	MOVE.L	D3,-4(A2)
	MOVE.L	D3,1008(A2)
	SUBQ.W	#1,PAS_FLAG
	BPL	NO_NEW_PAS
	MOVEA.L	ADR_PAS,A0
	MOVE.W	(A0)+,PAS_FLAG
	MOVE.W	(A0)+,PAS
	TST.W	(A0)
	BPL.S	.no_reset
	LEA	TAB_PAS,A0
.no_reset
	move.l	a0,ADR_PAS
NO_NEW_PAS
	moveq	#0,d0
	move.l	d0,d1
	MOVE.W	ANG,D0
	MOVE.W	PAS,D1
	add.w	D1,d0
	and.w	#$3ff,d0
	move.w	d0,ANG
	rts


print_titles
	moveq	#0,d5
	move.l	SCR_ADR,d6
	add.l	#480,d6
	lea	ascii,a1
	moveq	#0,d0
prt_loop
	lea	char_offset,a3
.loop	moveq	#0,d7
	move.b	(a1)+,d7
	cmp.b	#1,d7
	bne.s	.no_inverse
	moveq	#-1,d5
	bra.s	.loop
.no_inverse
	cmp.b	#2,d7
	bne.s	.no_normal
	moveq	#0,d5
	bra.s	.loop
.no_normal
	cmp.b	#13,d7
	bne.s	.no_crlf
	add.l	#160*8,d0
	bra.s	prt_loop

.no_crlf
	cmp.b	#4,d7
	BNE.S	.no_under
	MOVEQ	#1,d5
	BRA.S	.loop
.no_under
	TST.B	D7
	BMI.S	.last
	SUBI.B	#32,d7
	LSL.W	#3,d7
	lea	font,a2
	ADDA.W	D7,A2
	MOVEA.L	D6,A0
	ADDA.W	(A3)+,A0
	ADDA.L	D0,A0
	TST.L	D5
	BMI.S	.inverse
	BEQ.S	.normal
	BPL.S	.underline		;underlined
.ex	swap	d1
	bra.s	.loop
.last	rts

.normal	move.b	(a2)+,0(a0)
	move.b	(a2)+,160(a0)
	move.b	(a2)+,320(a0)
	move.b	(a2)+,480(a0)
	move.b	(a2)+,640(a0)
	move.b	(a2)+,800(a0)
	move.b	(a2)+,960(a0)
	move.b	(a2)+,1120(a0)
	BRA	.ex

.inverse
	move.b	(a2)+,0(a0)
	not.b	0(a0)
	move.b	(a2)+,160(a0)
	not.b	160(a0)
	move.b	(a2)+,320(a0)
	not.b	320(a0)
	move.b	(a2)+,480(a0)
	not.b	480(a0)
	move.b	(a2)+,640(a0)
	not.b	640(a0)
	move.b	(a2)+,800(a0)
	not.b	800(a0)
	move.b	(a2)+,960(a0)
	not.b	960(a0)
	move.b	(a2)+,1120(a0)
	not.b	1120(a0)
	BRA	.ex

.underline
	move.b	(a2)+,0(a0)
	move.b	(a2)+,160(a0)
	move.b	(a2)+,320(a0)
	move.b	(a2)+,480(a0)
	move.b	(a2)+,640(a0)
	move.b	(a2)+,800(a0)
	move.b	(a2)+,960(a0)
	move.b	(a2)+,1120(a0)
	move.b	#$FF,1120(a0)
	bra	.ex

ANG		dc.w	0
PAS		dc.w	12
AMP		dc.w	192
PAS_FLAG	dc.w	0000
ADR_PAS		dc.l	TAB_PAS
TAB_PAS
OFF1	set	56
OFF2	set	6
	REPT	10
	dc.w	OFF1,OFF2
OFF1	set	OFF1+28
OFF2	set	OFF2+2
	ENDR
	dc.w	$FFFF,$FFFF

SCR_ADR		DC.L	SCREEN
OFFSET_ADR	DC.L	OFFSET_TAB
OFFSET_OFF	dc.l	2
DECAL_ADR	DC.L	DECAL_TAB
DECAL_OFF	dc.l	4

MY_PAL		dc.w	$000,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF
		dc.w	$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF

KEY_FLAG	dc.w	0
HBL_COUNTER	dc.w	0

plasma1	;80 byte long table
 dc.w	$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333

plasma2
 dc.w	$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444

plasma3
 dc.w	$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555

plasma4
 dc.w	$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666

plasma5
 dc.w	$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$006,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777

plasma6
 dc.w	$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$005,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666

plasma7
 dc.w	$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$004,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555

plasma8
 dc.w	$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$003,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444

plasma9
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$002,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333

plasma10
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$001,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222

plasma11
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$888,$111

plasma12
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$888

plasma13
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001

plasma14
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001

plasma15
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001

plasma16
 dc.w	$111,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222
 dc.w	$111,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222
 dc.w	$111,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

plasma17
 dc.w	$222,$111,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333
 dc.w	$222,$111,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333
 dc.w	$222,$111,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

plasma18
 dc.w	$333,$222,$111,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444
 dc.w	$333,$222,$111,$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444
 dc.w	$333,$222,$111,$000,$000,$000,$000,$000,$000,$000,$000,$000

plasma19
 dc.w	$444,$333,$222,$111,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555
 dc.w	$444,$333,$222,$111,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$888,$111,$222,$333,$444,$555,$666,$777,$666,$555
 dc.w	$444,$333,$222,$111,$000,$000,$000,$000,$000,$000,$000,$000

plasma20
 dc.w	$555,$444,$333,$222,$111,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$888,$111,$222,$333,$444,$555,$666,$777,$666
 dc.w	$555,$444,$333,$222,$111,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$888,$111,$222,$333,$444,$555,$666,$777,$666
 dc.w	$555,$444,$333,$222,$111,$000,$000,$000,$000,$000,$000,$000

plasma21
 dc.w	$666,$555,$444,$333,$222,$111,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$888,$111,$222,$333,$444,$555,$666,$777
 dc.w	$666,$555,$444,$333,$222,$111,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$888,$111,$222,$333,$444,$555,$666,$777
 dc.w	$666,$555,$444,$333,$222,$111,$000,$000,$000,$000,$000,$000

plasma22
 dc.w	$777,$666,$555,$444,$333,$222,$111,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$888,$111,$222,$333,$444,$555,$666
 dc.w	$777,$666,$555,$444,$333,$222,$111,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$888,$111,$222,$333,$444,$555,$666
 dc.w	$777,$666,$555,$444,$333,$222,$111,$000,$000,$000,$000,$000

plasma23
 dc.w	$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$888,$111,$222,$333,$444,$555
 dc.w	$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$888,$111,$222,$333,$444,$555
 dc.w	$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$000,$000

plasma24
 dc.w	$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$888,$111,$222,$333,$444
 dc.w	$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$888,$111,$222,$333,$444
 dc.w	$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000,$000

plasma25
 dc.w	$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$888,$111,$222,$333
 dc.w	$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$888,$111,$222,$333
 dc.w	$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000

plasma26
 dc.w	$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$888,$111,$222
 dc.w	$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$888,$111,$222
 dc.w	$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000

plasma27
 dc.w	$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$888,$111
 dc.w	$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$888,$111
 dc.w	$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111

plasma28
 dc.w	$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$888
 dc.w	$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001,$000,$000,$000,$888
 dc.w	$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222



ZIK		incbin	RALPH_N4.MUX
		even

COS_TAB	incbin	cos.dat

PLASMA_TAB
	REPT	9
	DC.L	plasma2
	DC.L	plasma4
	DC.L	plasma6
	DC.L	plasma8
	DC.L	plasma10
	DC.L	plasma12
	DC.L	plasma14
	DC.L	plasma16
	DC.L	plasma18
	DC.L	plasma20
	DC.L	plasma22
	DC.L	plasma24
	DC.L	plasma26
	DC.L	plasma28
	DC.L	plasma27
	DC.L	plasma26
	DC.L	plasma25
	DC.L	plasma24
	DC.L	plasma23
	DC.L	plasma22
	DC.L	plasma21
	DC.L	plasma20
	DC.L	plasma19
	DC.L	plasma18
	DC.L	plasma17
	DC.L	plasma16
	DC.L	plasma15
	DC.L	plasma14
	DC.L	plasma13
	DC.L	plasma12
	dc.l	plasma11
	dc.l	plasma10
	dc.l	plasma9
	DC.L	plasma8
	DC.L	plasma7
	DC.L	plasma6
	DC.L	plasma5
	DC.L	plasma4
	DC.L	plasma3
	DC.L	plasma2
	DC.L	plasma1
	DC.L	plasma2
	DC.L	plasma3
	DC.L	plasma4
	DC.L	plasma5
	DC.L	plasma6
	DC.L	plasma7
	DC.L	plasma8
	DC.L	plasma9
	DC.L	plasma10
	DC.L	plasma11
	DC.L	plasma12
	DC.L	plasma13
	DC.L	plasma14
	DC.L	plasma15
	DC.L	plasma16
	DC.L	plasma17
	DC.L	plasma18
	DC.L	plasma19
	DC.L	plasma20
	DC.L	plasma21
	DC.L	plasma22
	DC.L	plasma22
	DC.L	plasma21
	DC.L	plasma20
	DC.L	plasma19
	DC.L	plasma18
	DC.L	plasma17
	DC.L	plasma16
	DC.L	plasma15
	DC.L	plasma14
	DC.L	plasma13
	DC.L	plasma12
	DC.L	plasma11
	DC.L	plasma10
	DC.L	plasma9
	DC.L	plasma8
	DC.L	plasma7
	DC.L	plasma6
	DC.L	plasma5
	DC.L	plasma4
	DC.L	plasma3
	DC.L	plasma2
	DC.L	plasma1
	ENDR


OFFSET_TAB	dcb.w	506,0
DECAL_TAB	dcb.w	1012,0

char_offset
OFFSET	set	0
	REPT	134
	dc.w	OFFSET
	dc.w	OFFSET+1
OFFSET	set OFFSET+8
	ENDR

font	incbin	screen.fnt

;4=UNDERLINE
;13=LF,CR
;2=NORMAL
;1=INVERSE
ascii
 dc.b	"             {     {{{{{    {{{{{",13
 dc.b	"            { {     {   {   {    {",13
 dc.b	"           {   {    {   {   {    {",13
 dc.b	"          {     {   {   {   {{{{{",13
 dc.b	"          {{{{{{{   {   {   {   {",13
 dc.b	"          {     {  {{{{{    {    {",13,13
 dc.b	"                  ADRENALIN UK ",13,13
 dc.b	'                    presents',13,13,13
 dc.b	"                    Menu 23",13,13
 dc.b	"Menu coded by MAC SYS DATA based on one",13
 dc.b	"     coded by MIKE of DNT CREW",13,13
 dc.b	"         1: Mega demo A",13,13
 dc.b	"         2: Demo B",13,13
 dc.b	"     Greetings to;- ",13,13
 dc.b	"POV!",13,13,13
 DC.B	$FF,$00 
	even


********** valid key press table
demo_keys	dc.b	0, $02		;key 1
		dc.b	1, $03		;key 2
		dc.b	2, $04		;key 3
		dc.b	3, $05		;key 4
		dc.b	4, $06		;key 5
		dc.b	5, $07		;key 6
;		dc.b	6, $08		;key 7
;		dc.b	7, $09		;key 8
;		dc.b	8, $0a		;key 9

		dc.b	0, $6d		;keypad 1
		dc.b	1, $6e		;keypad 2
		dc.b	2, $6f		;keypad 3
		dc.b	3, $6a		;keypad 4
		dc.b	4, $6b		;keypad 5
		dc.b	5, $6c		;keypad 6
;		dc.b	6, $67		;keypad 7
;		dc.b	7, $68		;keypad 8
;		dc.b	8, $69		;keypad 9
		dc.b	-1, -1


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5
		dc.l	filename6
		dc.l	filename7
		dc.l	filename8
		dc.l	filename9


**** If using POV AUTORUN and you wish to exit to the desktop simply
**** start the filename off with $$
****

filename1	dc.b	"1.MSD",0
	even
filename2	dc.b	"2.PRG",0
	even
filename3	dc.b	"3.PRG",0
	even
filename4	dc.b	"4.PRG",0
	even
filename5	dc.b	"5.PRG",0
	even
filename6	dc.b	"6.POV",0
	even
filename7	dc.b	"filename.ext",0
	even
filename8	dc.b	"filename.ext",0
	even
filename9	dc.b	"filename.ext",0
	even


	SECTION BSS
hertz_switch	ds.w	1
vsync_flag	ds.w	1
key		ds.w	1
storage		ds.b	90
SCREEN		ds.b	45056
