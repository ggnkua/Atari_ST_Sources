
Begin		move.l	a7,a5
		move.l	4(a5),a5
		move.l	12(a5),d0
		add.l	20(a5),d0
		add.l	28(a5),d0
		add.l	#$500,d0
		move.l	d0,d1
		add.l	a5,d1
		and.l	#$fffffffe,d1
		move.l	d1,a7
		move.l	d0,-(a7)
		move.l	a5,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7

		lea	bss_start(PC),a0
		lea	bss_end(PC),a1
.clear_bss	cmp.l	a0,a1
		ble.s	.bss_cleared
		clr.l	(a0)+
		bra.s	.clear_bss

.bss_cleared	bsr	L0037
		bsr	L0013
		tst.w	d0
		bmi.s	.exit
		bsr	DSETDTA
		bsr	main_loop
		bsr	L0014
.exit		clr.w	-(sp)
		trap	#1

main_loop	bsr	get_drive_path

		lea	main_menu_text(pc),a0
		bsr	print_a0

		lea	pack_which(pc),a0
		moveq	#1,d0
		bsr	FORM_ALERT
		move.w	d0,sam_or_mod

		cmp.w	#2,d0
		ble	L0005
		bsr	L000E
		bra	main_loop

L0004		lea	PACK_MORE(pc),a0
		moveq	#1,d0
		bsr	FORM_ALERT
		cmp.w	#1,d0
		beq.s	main_loop
		rts

L0005		bsr	L0012
		tst.w	d0
		beq.s	L0004
		bsr	L001B
		bsr	FSFIRST
L0006		tst.l	d0
		bmi.s	L0004

		lea	PACKING(pc),a0
		bsr	print_a0

		lea	L005B(pc),a0
		bsr	L0033

		lea	STATUS(pc),a0
		bsr	print_a0

		MOVE.L	L005A(PC),D0
		MOVE.L	D0,FILE_NAME
		MOVE.L	D0,D1
		LSR.L	#1,D1
		ADD.L	D1,D0
		ADDQ.L	#5,D0

		bsr	MALLOC
		tst.l	d0
		bmi	wot_mem
		add.w	#4,d0
bp		move.l	d0,FILE_START
		move.l	d0,a0
		move.b	#'M',(a0)+
		move.b	#'S',(a0)+
		move.b	#'D',(a0)+
		move.b	#'!',(a0)+

		BSR	L0021
		BSR	F_OPEN
		TST.W	D0
		BMI	L000C
		BSR	GET_FILE
		CMP.L	FILE_NAME(PC),D0
		BNE	L000C

		MOVE.L	FILE_START(PC),D0
		add.w	#4,d0
		MOVE.L	D0,L0069
		ADD.L	FILE_NAME(PC),D0
		MOVE.L	D0,L006A
		CMPI.W	#2,sam_or_mod
		BEQ.S	L0007
		MOVEA.L	FILE_START(PC),A0
		add.w	#4,a0

		CMPI.L	#'M.K.',1080(A0)	;is mod??? (M.K. only)
		BNE	L000D
		bsr	pack_mod

L0007		TST.W	L0058
		NOP
		MOVEA.L	L0069(PC),A0
		MOVEA.L	L006A(PC),A1
		MOVE.L	A1,D0
	SUB.L	A0,D0
	BSR	L003F
	MOVEA.L	L006A(PC),A0
	MOVEA.L	L0069(PC),A1
L0008:
	MOVE.B	(A0)+,(A1)+
	SUBQ.L	#1,D0
	BNE.S	L0008
	MOVE.L	FILE_START(PC),D0
	add.w	#4,d0
	SUBA.L	D0,A1
	MOVE.L	A1,FILE_NAME
	BSR	L0024
	BSR	F_CREATE
	TST.W	D0
	BMI.S	L000C
	BSR	F_WRITE
	CMP.L	FILE_NAME(PC),D0
	BMI.S	L000C
	BSR	F_CLOSE
	LEA	OK(PC),A0
	BSR	print_a0
L0009	MOVE.L	FILE_START(PC),D0
	add.w	#4,d0
	BSR	MFREE
L000A	BSR	FSNEXT
	BRA	L0006

wot_mem	LEA	OUT_MEM(PC),A0
	BSR	print_a0
	BRA.S	L000A
L000C	BSR	F_CLOSE
	LEA	FILE_ERROR(PC),A0
	BSR	print_a0
	BRA.S	L0009

L000D		lea	NOT_NOISE(pc),a0
		bsr	print_a0
		bra.s	L0009
L000E		lea	SET_UP_OPT(pc),a0
		moveq	#0,d0
		bsr	FORM_ALERT
		CMP.W	#1,D0
		BEQ.S	L000F
		CMP.W	#2,D0
		BEQ.S	L0010

		lea	FILE_OPT(pc),a0
		MOVEQ	#1,D0
		BSR	FORM_ALERT
		SUBQ.W	#1,D0
		MOVE.W	D0,L0057
		RTS

L000F		lea	PACK_DIRECTION(pc),a0
		moveq	#1,d0
		bsr	FORM_ALERT
		subq.w	#1,d0
		move.w	d0,L0056
		rts

L0010		lea	SAMPLE_OPT(pc),a0
		moveq	#2,d0
		bsr	FORM_ALERT
		subq.w	#1,d0
		move.w	d0,L0058
		rts

FORM_ALERT	LEA	L006C(PC),A1
	MOVE.W	#$34,(A1)+
	MOVE.W	#1,(A1)+
	MOVE.W	#1,(A1)+
	MOVE.W	#1,(A1)+
	CLR.W	(A1)
	MOVE.L	A0,L0077
	MOVE.W	D0,L0074
	MOVE.W	#$C8,D0
	MOVE.L	#L0047,D1
	TRAP	#2
	MOVE.W	L0075(PC),D0
	RTS
L0012:
	LEA	L006C(PC),A0
	MOVE.W	#$5A,(A0)+
	CLR.W	(A0)+
	MOVE.W	#2,(A0)+
	MOVE.W	#2,(A0)+
	CLR.W	(A0)
	LEA	L0077(PC),A0
	MOVE.L	#current_drive,(A0)+
	MOVE.L	#L0061,(A0)
	MOVE.W	#$C8,D0
	MOVE.L	#L0047,D1
	TRAP	#2
	MOVE.W	L0076(PC),D0
	RTS

L0013	LEA	L006C(PC),A0
	MOVE.W	#$A,(A0)+
	CLR.W	(A0)+
	MOVE.W	#1,(A0)+
	CLR.L	(A0)
	MOVE.W	#$C8,D0
	MOVE.L	#L0047,D1
	TRAP	#2
	MOVE.W	L0075(PC),D0
	RTS

L0014		LEA	L006C(PC),A0
		MOVE.W	#$13,(A0)+
		CLR.W	(A0)+
		MOVE.W	#1,(A0)+
		CLR.L	(A0)
		MOVE.W	#$C8,D0
		MOVE.L	#L0047,D1
		TRAP	#2
		RTS
;		MOVE.L	#L0047,D1
;		MOVE.W	#$C8,D0
;		TRAP	#2
;		RTS

L0015	move.l	#L0048,d1
	move.w	#$73,d0
	trap	#2
	rts

L0016	MOVE.W	#$7A,L006C
	MOVE.W	#0,L006D
	MOVE.W	#1,L006E
	MOVE.W	L0073,L006F
	MOVE.W	#0,L0074
	BSR	L0015
	RTS

L0017	MOVE.W	#$7B,L006C
	MOVE.W	#0,L006D
	MOVE.W	#0,L006E
	MOVE.W	L0073,L006F
	BSR	L0015
	RTS

get_drive_path	move.w	#$19,-(sp)	;get current drive
		trap	#1
		addq.l	#2,sp

		add.b	#'A',d0
		move.b	d0,current_drive

		move.b	#':',current_drive+1
		clr.w	-(sp)
		pea	current_path(pc)
		move.w	#$47,-(sp)
		trap	#1
		addq.l	#8,sp

		lea	current_drive(pc),a0
.loop		tst.b	(a0)+
		bne.s	.loop

		subq.l	#1,a0
		cmp.b	#'\',(a0)
		beq.s	.no_path

		move.b	#'\',(a0)+
		clr.b	(a0)+
.no_path	rts

L001B:
	LEA	current_drive(PC),A0
	MOVEA.L	A0,A1
	LEA	FSFIRST_ENV(PC),A2
L001C:
	TST.B	(A1)+
	BNE.S	L001C
L001D:
	CMPA.L	A0,A1
	BEQ.S	L001F
	CMPI.B	#$5C,-(A1)
	BNE.S	L001D
L001E:
	MOVE.B	(A0)+,(A2)+
	CMPA.L	A1,A0
	BGT.S	L001F
	BRA.S	L001E
L001F:
	MOVE.L	A1,L0064
	LEA	L0061(PC),A0
L0020:
	MOVE.B	(A0)+,(A2)+
	BNE.S	L0020
	RTS
L0021:
	LEA	current_drive(PC),A0
	MOVEA.L	L0064(PC),A1
	LEA	OUTPUT_FILE(PC),A2
L0022:
	MOVE.B	(A0)+,(A2)+
	CMPA.L	A1,A0
	BLE.S	L0022
	LEA	L005B(PC),A0
L0023:
	MOVE.B	(A0)+,(A2)+
	BNE.S	L0023
	RTS
L0024:
	TST.W	L0057
	BEQ.S	L0027

		lea	OUTPUT_FILE(pc),a0
L0025		tst.b	(a0)+
		bne.s	L0025
L0026		cmp.b	#'.',-(a0)
		bne.s	L0026
		addq.l	#1,a0
		move.b	#'N',(a0)+
		move.b	#'P',(a0)+
		move.b	#'K',(a0)+
		clr.b	(a0)
L0027		rts

DSETDTA		pea	our_dta(pc)
		move.w	#$1A,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

FSFIRST		CLR.W	-(A7)
		PEA	FSFIRST_ENV(PC)
		MOVE.W	#$4E,-(A7)
		TRAP	#1
		ADDQ.L	#8,A7
		RTS

FSNEXT		MOVE.W	#$4F,-(A7)
		TRAP	#1
		ADDQ.L	#2,A7
		RTS

MALLOC		move.l	d0,-(sp)
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

MFREE		MOVE.L	D0,-(A7)
		MOVE.W	#$49,-(A7)
		TRAP	#1
		ADDQ.L	#6,A7
		RTS

F_OPEN		CLR.W	-(A7)
		PEA	OUTPUT_FILE(PC)
		MOVE.W	#$3D,-(A7)
		TRAP	#1
		ADDQ.L	#8,A7
		MOVE.W	D0,HANDLE
		RTS

F_CREATE	CLR.W	-(A7)
		PEA	OUTPUT_FILE(PC)
		MOVE.W	#$3C,-(A7)
		TRAP	#1
		ADDQ.L	#8,A7
		MOVE.W	D0,HANDLE
		RTS

GET_FILE	MOVE.L	FILE_START(PC),a6
		add.w	#4,a6
		move.l	a6,-(A7)
		MOVE.L	FILE_NAME(PC),-(A7)
		MOVE.W	HANDLE(PC),-(A7)
		MOVE.W	#$3F,-(A7)
		TRAP	#1
		LEA	12(A7),A7
		RTS

F_WRITE		MOVE.L	FILE_START(PC),a6
		move.l	a6,-(A7)
		MOVE.L	FILE_NAME(PC),a6
		add.l	#4,a6
		move.l	a6,-(A7)
		MOVE.W	HANDLE(PC),-(A7)
		MOVE.W	#$40,-(A7)
		TRAP	#1
		LEA	12(A7),A7
		RTS

F_CLOSE		MOVE.W	HANDLE(PC),-(A7)
		MOVE.W	#$3E,-(A7)
		TRAP	#1
		ADDQ.L	#4,A7
		RTS

print_a0	pea	(a0)
		bsr	L0017
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		bsr	L0016
		rts

L0033	LEA	L0063(PC),A1
	MOVEA.L	A1,A2
	MOVEQ	#$E,D0
L0034:
	MOVE.B	#$20,(A1)+
	DBF	D0,L0034
	CLR.B	(A1)+
	LEA	-16(A1),A1
L0035:
	TST.B	(A0)
	BEQ.S	L0036
	MOVE.B	(A0)+,(A1)+
	BRA.S	L0035
L0036:
	MOVEA.L	A2,A0
	bsr	print_a0
	RTS

L0037	LEA	L0067(PC),A1
	MOVE.W	#$FF01,D0
L0038	LEA	L0045(PC),A0
	MOVEQ	#0,D1
L0039	CMP.W	(A0)+,D0
	BLE.S	L003A
	ADDQ.W	#1,D1
	CMP.W	#8,D1
	BNE.S	L0039
L003A	MOVE.B	D1,(A1)+
	ADDQ.W	#1,D0
	BNE.S	L0038
L003B	LEA	L0046(PC),A0
	MOVEQ	#$F,D1
L003C	MOVE.W	-2(A0),D2
	CMP.W	-(A0),D0
	BGE.S	L003D
	SUBQ.W	#1,D1
	CMP.W	#7,D1
	BNE.S	L003C
L003D	MOVE.B	D1,(A1)+
	ADDQ.W	#1,D0
	CMP.W	#$80,D0
	BNE.S	L003B
L003E	CLR.B	(A1)+
	ADDQ.W	#1,D0
	CMP.W	#$100,D0
	BNE.S	L003E
	RTS

L003F	LEA	L0068(PC),A2
	LEA	L0046(PC),A3
	ADDQ.L	#1,D0
	AND.B	#$FE,D0
	MOVE.L	D0,D7
	LSR.L	#1,D7
	MOVE.L	D7,-(A7)
	ADDA.L	D0,A0
	ADDA.L	D7,A1
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D6
L0040:
	MOVEQ	#0,D0
	MOVE.B	-(A0),D0
	ADD.B	#$80,D0
	SUB.W	D6,D0
	MOVE.B	0(A2,D0.W),D1
	ADD.B	0(A3,D1.W),D6
	LSL.B	#4,D1
	MOVEQ	#0,D0
	MOVE.B	-(A0),D0
	ADD.B	#$80,D0
	SUB.W	D6,D0
	MOVE.B	0(A2,D0.W),D2
	ADD.B	0(A3,D2.W),D6
	OR.B	D2,D1
	MOVE.B	D1,-(A1)
	SUBQ.L	#1,D7
	BNE.S	L0040
	MOVE.L	(A7)+,D0
	RTS

pack_mod	move.l	FILE_START(pc),a0
		add.w	#4,a0
		lea	952(a0),a1		;jump to samples
		moveq	#$7F,d0
		moveq	#0,d4
L0042		move.l	d4,d2
		subq.w	#1,d0
L0043		move.b	(a1)+,d4
		cmp.b	d2,d4
		bgt.s	L0042
		dbf	d0,L0043

	ADDQ.B	#1,D2
	ASL.L	#8,D2
	ASL.L	#2,D2
	ADD.L	#$43C,D2
	MOVE.L	D2,D1
	ADD.L	A0,D2
	MOVEA.L	D2,A2
	MOVE.L	A2,L0069
	MOVEQ	#$1E,D0
L0044:
	MOVEQ	#0,D4
	MOVE.W	42(A0),D4
	ADD.L	D4,D4
	ADDA.L	D4,A2
	ADDA.L	#$1E,A0
	DBF	D0,L0044
	MOVE.L	A2,L006A
	RTS

	SECTION DATA
L0045	DC.B	$FF,$80,$FF,$C0,$FF,$E0,$FF,$F0
	DC.B	$FF,$F8,$FF,$FC,$FF,$FE,$FF,$FF
	DC.B	$00,$00,$00,$01,$00,$02,$00,$04
	DC.B	$00,$08,$00,$10,$00,' ',$00,'@'
L0046:
	DC.B	$80,$C0,$E0,$F0,$F8,$FC,$FE,$FF
	DC.B	$00,$01,$02,$04,$08,$10,' @'
L0047:
	DC.L	L006C
	DC.L	L0070
	DC.L	L0074
	DC.L	L0075
	DC.L	L0077
	DC.L	L0078

L0048	DC.L	L006C
	DC.L	L0074
	DC.L	L0071
	DC.L	L0075
	DC.L	L0072

main_menu_text
	dc.b	$1B,'E ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	dc.b	'~',$D,$A
	dc.b	$A,' | Version 0.31                                               RADICAL SYSTEMS |',$D
	dc.b	$A
	dc.b	$A,' |                           N O I S E P A K K E R                            |',$D
	dc.b	$A
	dc.b	$A,' |                                                                            |',$D
	dc.b	$A
	dc.b	$A,' |            written by Karl and New Mode of DELTA FORCE, (C) 1992           |',$D
	dc.b	$A
	dc.b	$A,' |            header added by Mac Sys Data of Persistence Of Vision           |',$D
	dc.b	$A
	dc.b	$A,' | Release Date : 05/17/92 & 10/5/93                             (PRERELEASE) |',$D
	dc.b	$A
	dc.b	$A,' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',$D
	dc.b	$A
	dc.b	0
PACKING		dc.b	$D,$A,'Packing: ',0
STATUS		dc.b	'Status: ',$00
OUT_MEM		dc.b	7,'OUT OF MEMORY!',0
FILE_ERROR	dc.b	7,'A FILE ERROR HAS OCCURED!',0
NOT_NOISE	dc.b	7,'THIS IS NO NOISETRACKER MODULE!',0
OK		dc.b	'OK!',$00

pack_which	dc.b	'[2][What do you wish to pack?|  - Noisetracker modules|  - Raw sample data|  - Set preferences][MODU'
		dc.b	'LES|SAMPLES|SETUP]'

SET_UP_OPT	dc.b	'[2][What do you want to set up?|  - Packing direction|  - Sampleformat|  - Output to which file][DIR'
		dc.b	'|FORMAT|FILE]',0
PACK_DIRECTION	dc.b	'[2][Files will be packed ?][BACKWARDS|FORWARDS]',0
SAMPLE_OPT	dc.b	'[2][Samples are stored in|the following format:| - ST ($00 is lowest)| - AMIGA ($80 is lowest)][ATAR'
		dc.b	'I|AMIGA]'
FILE_OPT	dc.b	'[2][Packed files will be saved to?|  - same file name|  - extension .npk][SAME|NEW]',0
PACK_MORE	dc.b	'[2][Do you wish to pack|more files?][Yes|No]',0

L0056		dc.w	1
L0057		dc.w	0
L0058		dc.w	1


	SECTION BSS
bss_start
our_dta		ds.b	26

L005A		ds.l	1
L005B		ds.b	14
FILE_START	ds.l	1
HANDLE		ds.w	1
current_drive	ds.b	2

current_path	ds.b	254

L0061		ds.b	16
FSFIRST_ENV	ds.b	256
L0063		ds.b	16
L0064		ds.l	1
FILE_NAME	ds.l	1
OUTPUT_FILE	ds.b	256
L0067		ds.b	255
L0068		ds.b	257
L0069		ds.l	1
L006A		ds.l	1
sam_or_mod	ds.w	1
L006C		ds.w	1
L006D		ds.l	1
L006E		ds.b	6
L006F		ds.b	10
L0070		ds.b	28
L0071		ds.b	512
L0072		ds.b	256
L0073		ds.w	1
L0074		ds.b	256
L0075		ds.w	1
L0076		ds.b	254
L0077		ds.b	256
L0078		ds.b	256
bss_end

