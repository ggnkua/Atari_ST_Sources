* LEM-LINK
* LINKFILER CODED BY PELE 20/5/93

;includes exec header (coded by Pompey Pirates)

pre_reg	equ	0	; Preserve registers
clr_bss	equ	1	; Clear BSS segment (see above)

	opt	w-,o+


BEGIN
	MOVE.L	A7,A5
;	LEA	$80000,A7
	MOVE.L	4(A5),A5
;	MOVE.L	$C(A5),D0
;	ADD.L	$14(A5),D0
;	ADD.L	$1C(A5),D0
	MOVE.L	#$100,D0
	ADD.L	#(start-BEGIN)+$7e10,D0
;	ADD.L	#$D8A08,D0
	MOVE.L	D0,-(A7)
	MOVE.L	A5,-(A7)
;	PEA	start
	CLR.W	-(A7)
	MOVE.W	#$4A,-(A7)
	TRAP	#1
	LEA	12(A7),A7

	CLR.W	-(A7)
	PEA	-1
	PEA	-1
	MOVE.W	#5,-(A7)
	TRAP	#14
	LEA	12(A7),A7

	PEA	INT0
	MOVE.W	#$26,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7

;	PEA	0
;	TRAP	#1	

	JMP	start
	
TERM	CLR.W	-(A7)
	MOVE.L	#(BUFR-BEGIN)+256,-(A7)
	MOVE.W	#$31,-(A7)
	TRAP	#1

PRINT	PEA	(A0)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	RTS

KEY	MOVE.W	#8,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	SWAP	D0
	RTS
	
;	CLR.W	-(A7)
;	PEA	$200000
;	TRAP	#1

INT0:
	LEA	OLDT1+2(pc),a0
	MOVE.L	$84,(a0)
	move.l	$84,$80
	LEA	HANDLER(PC),A0
	MOVE.L	A0,$84.W
;	LEA	HANDLER(PC),A0
;	MOVE.L	A0,$84.W
	CLR.W	$FFFF8240.W
	MOVE.W	#$077,$FFFF825E.W
	LEA	ME,A0
	BSR	PRINT
	BSR	KEY
	CMPI.B	#$14,D0
	BNE	CONT
	LEA	MEGA,A0
	BSR	PRINT	
	BSR	KEY
	CMPI.B	#$31,D0
	BEQ.S	NT1
	MOVE.W	#$4E71,LIVES
NT1	ST	D7
	LEA	M2,A0
	BSR	PRINT
	BSR	FIGS
	CMPI.B	#100,d7
	bge.s	NT2
	CMPI.B	#0,d7
	blt.s	NT2
	MOVE.W	D7,P1+2
	MOVE.W	D7,P2+2
	MOVE.W	#$4E71,PERC
NT2
;	ST	D7
;	LEA	M3,A0
;	BSR	PRINT
;	BSR	FIGS
;	CMPI.W	#60,D7
;	BGT.S	NT3
;	CMPI.B	#0,D7
;	BLE.S	NT3
;	MOVE.W	D7,L1+2
;	MOVE.W	D0,LL1+2
;	MOVE.W	#$4E71,LEVEL1
;NT3	ST	D7
;	LEA	M4,A0
;	BSR	PRINT
;	BSR	FIGS
;	MOVE.W	D7,L2+2
;	MOVE.W	D0,LL2+2
;	CMPI.W	#60,D7
;	BGT.S	CONT
;	CMPI.B	#0,D7
;	BLE.S	CONT
;	MOVE.W	#$4E71,LEVEL2

CONT	
	CMPI.L	#$80000,$42E
	BLE.S	HALFM
	MOVE.B	#13,NULL
HALFM	
	PEA	CREDZ
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	lea	packedfile,a0
	bsr	unpack
	RTS

FIGS	BSR	KEY
	SWAP	D0
	SUBI.B	#$30,D0
	BLt	retr
	CMPI.B	#10,D0
	BGE	retr
	MOVE.W	D0,D7
	BSR	KEY
	SWAP	D0
	SUBI.B	#$30,D0
	BLt	SINGLE
	CMPI.B	#10,D0
	BGE	SINGLE
	MULU	#10,D7
	ADD.W	D0,D7
SINGLE	CLR.L	D0
	CLR.L	D1
	MOVE.W	D7,D0
	MOVE.W	D7,D1
	ASR	#4,D0
	ADDI.B	#$30,D0
	ASL	#8,D0
	ANDI.L	#$F,D1
	ADDI.B	#$30,D1
	OR.w	D1,D0
retr	RTS	

LODIT
	CLR.W	-(A7)
	PEA	LINK
	MOVE.W	#$3D,-(A7)
	TRAP	#0
	ADDQ.L	#8,A7
	MOVE.W	D0,D7

	PEA	$80000
	PEA	500000
	MOVE.W	D7,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#0
	LEA	12(A7),A7
	
	MOVE.W	D7,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#0
	ADDQ.L	#4,A7
	ST	XRAM
	BRA	RAM

HANDLER
	LEA	SPSAVE+(14*4)+2(PC),A0
	MOVEM.L	D1-D7/A1-A6,-(A0)
	MOVE.W	(A7)+,D0
	MOVE.W	D0,-(A0)
	MOVE.L	(A7)+,-(A0)
	MOVE.L	A7,A2
	BTST	#13,D0
	BNE.S	SUPM
	MOVE.L	USP,A2
SUPM
	CMPI.W	#$3D,(A2)
	BEQ	NEWOPEN
	TST	PLFLAG
	BEQ.S	YER
	CMPI.W	#$3F,(A2)
	BEQ	NEWREAD
	CMPI.W	#$3E,(A2)
	BEQ	NEWCLOSE
YER	LEA	SPSAVE(PC),A0
	MOVE.L	(A0)+,-(A7)
	MOVE.W	(A0)+,-(A7)
	MOVEM.L	(A0)+,D1-D7/A1-A6	
OLDT1	JMP	0
ERE	LEA	SPSAVE(PC),A0
	MOVE.L	(A0)+,-(A7)
	MOVE.W	(A0)+,-(A7)
	MOVEM.L	(A0)+,D1-D7/A1-A6	
	RTE
myfile	ds.b	12
NEWOPEN
	MOVE.L	2(A2),A0	
	cmpi.b	#":",1(a0)
	bne.s	nosep
	ADDQ.L	#2,A0		;SKIP 'A:'
nosep
	LEA	myfile,a1
	moveq	#11,d0
sf	move.b	(a0)+,(a1)+
	dbf	d0,sf
	LEA	myfile,a0
	LEA	FPTR+2(PC),A1
	CLR.L	(A1)
	LEA	TABLE(PC),A1
	MOVE.L	#-4,D2
	MOVE.L	(A0),D0
FNCHK	CMP.L	(A1),D0
	BEQ	TSTALL
FNX	ADD.L	#16,D2
	LEA	16(A1),A1
	TST	(A1)
	BNE.S	FNCHK		
	BRA	YER
TSTALL	MOVE.L	A0,A2
	MOVE.L	A1,A3
TLOOP	MOVE.B	(A2)+,D1
	CMP.B	(A3)+,D1
	BNE.S	FNX
	TST.B	(A3)
	BNE.S	TLOOP
	LEA	TABLE(PC),A0
	LEA	(A0,D2.W),A1
	MOVE.L	(A1),D0
	LEA	FPTR+2(PC),A0
	MOVE.L	D0,(A0)
	MOVE.L	16(A1),D1
	SUB.L	D0,D1
	LEA	LENGTH+2(PC),A0
	MOVE.L	D1,(A0)
	MOVEQ	#6,D0
	ST	PLFLAG
	BRA	ERE

NEWREAD
	MOVE.L	8(A2),A6
	TST	XRAM
	BNE	RAM
	CMPI.L	#$80000,$42E
	BGT	LODIT

	CLR.W	-(A7)
	PEA	LINK(PC)
	MOVE.W	#$3D,-(A7)
	TRAP	#0
	ADDQ.L	#8,A7
	MOVE.W	D0,D7
	
	CLR.W	-(A7)
	MOVE.W	D7,-(A7)
FPTR	PEA	0
	MOVE.W	#$42,-(A7)
	TRAP	#0
	LEA	10(A7),A7
	
LODADR	PEA	(A6)
LENGTH	PEA	0
	MOVE.W	D7,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#0
	LEA	12(A7),A7

	MOVE.L	D0,-(A7)
	MOVE.W	D7,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#0
	ADDQ.L	#4,A7
	MOVE.L	(A7)+,D1


DPK	MOVE.L	A6,A0
	BSR	unpack
	TST.l	D0
	BNE.S	GD
	MOVE.l	d1,d0
GD	btst	#0,d0
	beq.s	even
	addq.l	#1,d0
even	
;	MOVE.L	D0,-(A7)
;	MOVE.W	#$2F,-(A7)
;	TRAP	#0
;	ADDQ.L	#2,A7
;	MOVE.L	D0,A0
;	MOVE.L	(A7)+,D0
;	MOVE.L	D0,26(A0)	
;	MOVE.L	D0,D7
	ADD.L	D0,FPTR+2
	BRA	ERE

RAM	LEA	$80000,A0
	LEA	FPTR+2(PC),A1
	ADD.L	(A1),A0
	LEA	LENGTH+2(PC),A1
	MOVE.L	(A1),D0
	MOVE.L	A6,A2
SBYT	MOVE.B	(A0)+,(A2)+
	SUBQ.L	#1,D0
	BNE.S	SBYT
	MOVE.L	(A1),D1
	BRA	DPK
		
NEWCLOSE	
	CLR.L	D0
	CLR	PLFLAG
	BRA	ERE
PLFLAG	DC.W	0
* UNPACK source for SPACKERv3	(C)THE FIREHAWKS'92
* -------------------------------------------------
* in	a0: even address start packed block
* out	d0: original length or 0 if not SPv3 packed
* =================================================
* Use AUTO_SP3.PRG for multiblk packed files

unpack:	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	sp3_02
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:	movem.l	(sp)+,d0-a6
	rts
sp3_03:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_04
	move.w	$FFFF8240.W,2(a6)
	btst	#1,$FFFF8260.W
	bne.s	sp3_04
	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_16
	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
	beq.s	sp3_23
	move.w	d5,$FFFF8240.W
sp3_23:
;	move.w	d4,d5
;	bsr	SETCOL
;	clr.w	d5
;	bsr	SETCOL
	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512

SETCOL	MOVEM.L	D0-D2/A0-A2,-(A7)
	move.W	d5,-(A7)
	clr.W	-(A7)
	MOVE.W	#7,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	clr.w	d5
	MOVEM.L	(A7)+,D0-D2/A0-A2
	RTS
	DC.L	0
TABLE	INCBIN	"BLOCK"
	DC.L	0
LINK	DC.B	"ST2.LNK",0
	EVEN
XRAM	DC.W	0
*                    123456789 123456789 123456789 123456789
CREDZ	DC.B	27,"E            PELE-LINK v1.0"
NULL	DC.B	0,10,13,10,13,10
	DC.B	"EXTRA RAM DETECTED...",13,10,13,10
	DC.B	"LOADING LINKFILE INTO HIGH MEMORY...",0
	EVEN
*                    123456789 123456789 123456789 123456789
ME	DC.B	27,"E             THE LEMMINGS",191,13,10
	DC.B	    "             ~~~~~~~~~~~~",13,10,13,10
	DC.B	    "                PRESENT",13,10,13,10
	DC.B	    "                MANIAX+",13,10
	DC.B	    "                -------",13,10,13,10
	DC.B        "PACKED, LINKED & MEGA-TRAINED BY PELE",13,10,13,10
	DC.B	    "ORIGINAL BY LG/BPS",13,10,13,10
	DC.B	    "PRESS 'T' FOR TRAINER",0
	EVEN
*                    123456789 123456789 123456789 1234567890
MEGA	DC.B	27,"E      PELE'S MEGA MANIAX TRAINER",13,10
	DC.B	    "      --------------------------",13,10,13,10
	DC.B	"INFINITE LIVES?",13,10,0
	EVEN
M2	DC.B	"CHOOSE THRESHOLDE (0-99%)",13,10,0
	EVEN
M3	DC.B	"CHOOSE PLAYER 1 START LEVEL (1-60)",13,10,0
	EVEN
M4	DC.B	"CHOOSE PLAYER 2 START LEVEL (1-60)",0	
	EVEN
SPSAVE:	DS.B	66	
BUFR	ds.b	256
start	move.l	#start,BUFR+8
	lea	BUFR,a5
	move.l	a5,4(a7)
	
	ifne	pre_reg
	movem.l	d0-d7/a0-a6,start-128
	endc
;	move.l	4(sp),a5		base page address

	lea	packedfile(pc),a0
	bsr	unpack	
;	clr.w	-(sp)
;	pea	$200000
;	trap	#1
;	move.l	d0,2(sp)



sort_it_out

;	ifne	flash
;	move.w	store(pc),$ff8240
;	endc

;	trap	#1		; user mode
;	addq.l	#6,sp

	lea	packedfile,a3	; start of packed file in a3
	
* a3 is pointing to start of depacked program

	move.l	2(a3),a0		text segment
	add.l	6(a3),a0		+ data segment
	add.l	14(a3),a0		+ symbol table
	lea	28(a0),a0		+ header
	add.l	a3,a0		+ start of program
* a0 now points to relocation table
	move.l	8(a5),d0		d0 points to TEXT
	lea	28(a3),a3		a3 points to program
	move.l	a3,a6
	tst.l	(a0)		zero 1st relocation?
	beq.s	done_reloc

	moveq	#0,d1
	add.l	(a0)+,a3		+ offset
relocate	add.l	d0,(a3)		relocate it
add_no_reloc	move.b	(a0)+,d1		next byte
	beq.s	done_reloc		zero is end
	cmp.b	#1,d1		1 is add 254, but
	bne.s	not1		don't relocate
	lea	254(a3),a3
	bra.s	add_no_reloc
not1	add.l	d1,a3		+ offset
	bra.s	relocate

done_reloc	lea	packedfile+2(pc),a2	past $601a
	move.l	(a2),12(a5)		write real TEXT len
	add.l	(a2),d0		TEXT len + TEXT addr
	move.l	d0,16(a5)		write real DATA addr
	move.l	4(a2),20(a5)		write real DATA len
	add.l	4(a2),d0		+ DATA len
	move.l	d0,24(a5)		write real BSS addr
	move.l	8(a2),28(a5)		write real BSS len

* now move code somewhere safe
	move.l	sp,a0
	lea	-256(a0),a0
	pea	(a0)
	lea	mover(pc),a1
	moveq	#(endofmover-mover)/2-1,d0
copy_mover	move.w	(a1)+,(a0)+
	dbf	d0,copy_mover
	rts

* move the program down to the correct address
mover	move.l	12(a5),d0		TEXT len
	add.l	20(a5),d0		+ DATA len
	lsr.l	#1,d0		divide by 2
	addq.l	#1,d0		one for luck
	move.l	8(a5),a4		pointer to TEXT addr
	pea	(a4)		run address
copydown	move.w	(a6)+,(a4)+
	subq.l	#1,d0
	bne.s	copydown
	ifne	clr_bss
* clear the BSS
	move.l	28(a5),d1
	add.l	#(packedfile-start)+28,d1
	lsr.l	#2,d1		bug fixed...!
	addq.l	#1,d1
clrbss	move.l	d0,(a4)+
	subq.l	#1,d1
	bne.s	clrbss
	endc
* if you wish to modify part of your program file, but don't wish to repack
* it, you can put a piece of code like this at this point:
	move.l	8(a5),a5	a5 now points to TEXT area of prog.
	move.w	#$4280,$28(a5)
LIVES	BRA.S	PERC
	MOVE.W	#$4E71,$3B14(A5)
PERC	BRA.S	LEVEL1
P1	MOVE.W	#$4B,$3938(A5)
P2	MOVE.W	#$4B,$3986(A5)
LEVEL1	BRA.S	LEVEL2
L1	MOVE.W	#0,$B32(A5)
LL1	MOVE.W	#$3031,$B22(A5)
LEVEL2	BRA.S	CUN
L2	MOVE.W	#0,$B3A(A5)
LL2	MOVE.W	#$3031,$B2A(A5)
CUN			
;	move.w	#$6002,$45d4(a5)
;	ADD.L	#$9BCC,A5
;	MOVE.W	#$6022,(A5)
* now you can carry out modifications off (a5), etc. such as:
*	move.w	#$4e71,20(a5)
* or whatever you want!
	ifne	pre_reg
	movem.l	start-128,d0-d7/a0-a6
	movem.l	d0-d7/a0-a6,-(sp)
	lea	start-128,a0
	moveq	#15-1,d0
clregs	clr.l	(a0)+
	dbf	d0,clregs
	movem.l	(sp)+,d0-d7/a0-a6
	endc
	rts			run the program
endofmover

;
; the packed exec file goes here
;
packedfile	incbin	"maniax.sp3"
endoffile

