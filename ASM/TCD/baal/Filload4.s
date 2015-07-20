****************************************************
*						   *
*	   	BAAL 				   *
*						   *
*        CRACKED, TRAINED FILED AND PACKED	   *
*						   *
*		 BY				   *
*						   *  
*	     BY DR.D OF T.C.D			   *
*						   *
****************************************************

;ENCRYPT 


;	LEA	CREDIT(PC),A0
;	MOVE.L	A0,A1
;	MOVE.L	#CREDEND-CREDIT,D0
;	MOVE.L	D0,D1
;ENC	NOT.B	(A0)+
;	DBF	D0,ENC

	OPT	O+,OW-

DEST=$80000
TEST=1


SUPER	PEA	0
	MOVE.W	#32,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	
	LEA	GEMHARD(PC),A1
	BSR	SAVEHARD

	BSR	MENU
	TST.L	D0
	BPL	MAGIC

	BCHG	#0,$484
	DC.W	$A009
	CLR.W	D7
	BSR	SETRES
	CLR.W	-(A7)
	TRAP	#1
		
NOALT	RTS


MAGIC	LEA	LOAD(PC),A0
	MOVE.L	A0,$A8		;INSTALL TRAP #10

	LEA	LOAD2(PC),A0
	MOVE.L	A0,$AC		;INSTALL TRAP #11

	LEA	SAVEPOS(PC),A0	;INSTALL TRAP #12
	MOVE.L	A0,$B0
	
	LEA	SAVESCORE(PC),A0;INSTALL TRAP #15
	MOVE.L	A0,$BC
	

	LEA	MAIN(PC),A0	;MAIN LOAD CODE
	LEA	$200+DEST,A1	;LOAD ADDRESS  ($200)
		
	BSR	DMA
	CMP.W	#$CD,D0
	BEQ	ERROR2

	MOVE.L	A1,A0		;UNPACK ADDRESS
	BSR	UNPACK

MODIFY	LEA	INFO+628(PC),A6
	BSR	PRINT
DOSPACE	BSR	WAITKEY
	CMP.B	#$39,D7
	BNE	DOSPACE

	MOVEM.L	D0-A6,-(A7)
	CLR.W	D7
	BSR	SETRES
	LEA	$FFFF8240,A0
	MOVEQ	#15,D7
CLR	CLR.L	(A0)+
	DBF	D7,CLR
	MOVEM.L	(A7)+,D0-A6

	MOVE.W	#$637,$FFFF8242
	ADD.L	D1,A1

	MOVE.L	#$294+DEST,D0
	MOVE.L	D0,$288+DEST

	BSR	CRACK

	IFEQ	TEST
	LEA	DEST+$288,A7
	LEA	DEST+$10A0,A0
	JMP	DEST+$1276	;OR JSR
	ENDC

	JMP	$200+DEST	

*************************************************************

UNPACK:	MOVE.W	UNPCOL(PC),6(A0)	;UNPACK COLOUR
	moveq	#0,d0
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
sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
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



*************************************************************
CRACK	MOVE.W	#$4E71,D1	;NOP
	MOVE.L	#$90404E71,D2	;SUB.W D0,D0 -  NOP
	
CART_CHECK	
	MOVE.W	D1,$1428+DEST
	MOVE.W	D1,$1430+DEST
	MOVE.W	D1,$14B8+DEST
	MOVE.W	D1,$14C0+DEST
	MOVE.W	D1,$190E+DEST
	MOVE.W	D1,$1916+DEST


ANY_WEAPON
	LEA	WEAPS(PC),A1
	CMP.B	#0,(A1)
	BEQ	NOWEAPS
	MOVE.W	D1,$8B78+DEST
NOWEAPS	NOP

INF_LIVES	CMP.B	#0,-6(A1)
	BEQ	NOLIVES
	MOVE.W	D1,$37D6+DEST
NOLIVES	NOP

INF_JETPACK_FUEL
	CMP.B	#0,-2(A1)
	BEQ	NOJFUEL
	MOVE.W	#$7001,DEST+$430C
NOJFUEL	NOP

INF_LASER_FUEL
	CMP.B	#0,-4(A1)
	BEQ	NOLFUEL

;	MOVE.W	D2,DEST+$412C
;	MOVE.W	D2,DEST+$412E
	MOVE.B	#$60,DEST+$4130
NOLFUEL	NOP

;NO_REFUEL	MOVE.W	D2,DEST+$8860	;PRESS 'R' REMOVED
;	MOVE.W	D2,DEST+$8862
	
CHECK_SUM	MOVE.L	D2,$6AD8+DEST
	MOVE.L	D2,$7922+DEST
	MOVE.L	D2,$8038+DEST

	MOVE.L	#$4E714E4A,D1	;NOP TRAP #10
	MOVE.L	#$4E714E71,D2	;NOP NOP

CHK_DISK1	MOVE.L	D2,DEST+$13B4
	
;	MOVE.L	D2,DEST+$1834
;	MOVE.W	D2,DEST+$1834+4
	
	MOVE.L	D2,DEST+$13E4
	MOVE.L	D2,DEST+$13E4+4
	MOVE.W	D2,DEST+$13E4+4+4
	
	MOVE.L	D2,DEST+$59CC
	MOVE.L	D2,DEST+$59CC+4
	
CHK_DISK2	MOVE.L	D2,DEST+$1324
	MOVE.W	D2,DEST+$1324+4

	MOVE.L	D2,DEST+$5E06
	MOVE.L	D2,DEST+$5E06+4

	MOVE.L	D2,DEST+$5E9A
	MOVE.L	D2,DEST+$5E9A+4
	

	MOVE.L	D2,DEST+$811A
	MOVE.W	D2,DEST+$811A+4

	MOVE.L	D2,DEST+$59D4	;DISK CHECK (WHEN REFUELLING!)


REM_WAIT	MOVE.L	D2,DEST+$130E	;NO WAIT FOR DISK CHANGE
	MOVE.W	D2,DEST+$1316	

REM_ILL	MOVE.W	#$7000,DEST+$1924
	MOVE.W	#$7000,DEST+$124C
	MOVE.W	#$7000,DEST+$1930

REM_CHECK	MOVE.W	D2,DEST+$13FC	;"TIMELORD" TEXT CHECK

;REM_LOAD	MOVE.L	D2,DEST+$8876			

	MOVE.L	D2,DEST+$5EB0

;REM_SAVE	MOVE.L	D2,DEST+$5CFC
;	MOVE.W	D2,DEST+$80DE
;	MOVE.L	D2,DEST+$886E


INST_SAVE	MOVE.L	#$4E4C4E75,DEST+$5E64	;TRAP #12 OR NOP
	MOVE.L	#$4E4F4E71,DEST+$8128	;TRAP #15 

INSTRAP	MOVE.L	D1,DEST+$134A	;USED ON DISK 1
	MOVE.L	D1,DEST+$136E
	MOVE.L	D1,DEST+$1390
	MOVE.L	D1,DEST+$139E
	MOVE.L	D1,DEST+$13AC

INSTRAP2	MOVE.L	#$4E4B4E75,D0	;TRAP #11 RTS
	MOVE.L	#$4E4B4E71,D1	;TRAP #11 NOP
	MOVE.L	D0,DEST+$175A
	MOVE.L	D0,DEST+$176E
	MOVE.L	D0,DEST+$1782	;USED ON DISK 2 SECTOR LOADER
	MOVE.L	D0,DEST+$1796
	MOVE.L	D0,DEST+$17AA
	MOVE.L	D0,DEST+$17BE
	MOVE.L	D0,DEST+$17D2
	MOVE.L	D0,DEST+$181A
	MOVE.L	D0,DEST+$182E
	MOVE.L	D0,DEST+$1842
	MOVE.L	D0,DEST+$1856
	MOVE.L	D0,DEST+$186A

	MOVE.L	D1,DEST+$187E
	MOVE.L	D1,DEST+$5EC2
	MOVE.L	D1,DEST+$17E6


	MOVE.W	D1,DEST+$807A	;BRANCH BACK (HANG UPS)
	MOVE.W	D1,DEST+$8154
	MOVE.W	D1,DEST+$8AA2
	MOVE.W	D1,DEST+$8B26

	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	RTS
	
*************************************************************

*************************************************************

LOAD  	MOVEM.L	D0-A6,-(A7)
	MOVE.L	A0,A4		;LOAD ADDRESS
	LEA	FCNT(PC),A3
	ADD.B	#1,(A3)
	LEA	FNAME(PC),A0	;ADDRESS OF FILE NAME TO LOAD
	MOVE.L	A4,A1		;LOAD ADDRESS
	BSR	DMA
	CMP.B	#$CD,D0
	BEQ	ERROR2
	MOVE.L	A1,A0		;UNPACK ADDRESS
	BSR	UNPACK
	MOVEM.L	(A7)+,D0-A6
	RTE

*************************************************************

LOAD2	MOVEM.L	D0-A6,-(A7)
	LEA	NAME2(PC),A6

	LEA	REGS(PC),A3
	MOVE.L	D0,(A3)
	MOVE.L	D1,4(A3)
	MOVE.L	A0,8(A3)
	MOVE.L	A1,12(A3)
	MOVE.W	#"  ",(A6)
	MOVE.L	D0,D3		;START TRACK
	MOVE.L	A0,A5		;LOAD ADDRESS
	CLR.L	D4
	CLR.L	D5
	LEA	ASCII(PC),A4
	MOVE.B	D3,D4
	DIVU	#16,D4	
	MOVE.W	D4,D5
	CLR.W	D4
	SWAP	D4
	MOVE.B	(A4,D5.W),(A6)
	MOVE.B	(A4,D4.W),1(A6)
	LEA	NAME2(PC),A0	;FILENAME TO LOAD
	MOVE.L	A5,A1		;LOAD ADDRESS
	BSR	DMA
	CMP.B	#$CD,D0
	BEQ	ERROR2
	MOVE.L	A1,A0		;UNPACK ADDRESS
	BSR	UNPACK
	MOVEM.L	(A7)+,D0-A6
	RTE
	
	
NAME2	DC.B	"  "
	DC.B	".DAT"
	DC.B	0,0
	EVEN
	

ASCII	DC.B	"0123456789ABCDEF"

REGS	DS.B	32

	RTE

*************************************************************
DMA   MOVEQ     #0,D0
      LEA       OTHER(PC),A2
      MOVEM.L   A0-A6/D1-D7,-(A7) 
      MOVE.L    D0,D6 
      MOVE.L    D1,D7 
      MOVEA.L   A0,A4 
      MOVEA.L   A1,A5 
      MOVEA.L   A2,A6 
      LEA       Z0031(PC),A0
      MOVE.L    A7,(A0) 
      BSR.S     Z0002 
      BSR.S     Z0005 
      TST.B     D6
      BNE.S     Z0000 
      BSR       Z0007 
      MOVE.L    D7,(A7) 
      BRA.S     Z0001 
Z0000:CMP.B     #5,D6 
      BNE.S     Z0001 
      MOVEQ     #0,D1 
      MOVEQ     #0,D2 
      MOVE.W    #-$8000,D3
      BSR       Z0030 
Z0001:MOVEA.L   Z0031(PC),A7
      MOVEM.L   (A7)+,A0-A6/D1-D7 
      RTS 

Z0002:CMPI.B    #$3A,1(A4)
      BNE.S     Z0004 
      MOVE.B    (A4)+,D0
      SUBQ.B    #1,D0 
      ANDI.B    #$F,D0
      LEA       Z0035(PC),A0
      MOVE.B    D0,(A0) 
Z0003:ADDQ.W    #1,A4 
      CMPI.B    #$5C,(A4) 
      BEQ.S     Z0003 
Z0004:RTS 
Z0005:MOVEQ     #0,D0 
      BSR       Z002D 
      LEA       Z0032(PC),A0
      MOVE.B    17(A6),D0 
      MOVE.L    D0,(A0)+
      MOVE.B    22(A6),D0 
      MOVE.L    D0,(A0)+
      MOVE.B    24(A6),D0 
      MOVE.W    D0,(A0)+
      MOVE.W    (A0),D0 
      BCLR      #3,D0 
      CMPI.B    #1,26(A6) 
      BEQ.S     Z0006 
      BSET      #3,D0 
Z0006:MOVE.W    D0,(A0)+
      MOVEQ     #0,D1 
      MOVE.B    20(A6),D1 
      LSL.W     #8,D1 
      MOVE.B    19(A6),D1 
      MOVEQ     #0,D0 
      BSR       Z0022 
      SUB.L     D0,D1 
      LSR.L     #1,D1 
      MOVE.L    D1,(A0)+
      RTS 
Z0007:BSR.S     Z000F 
      BNE.S     Z000E 
      MOVE.L    D2,D7 
      MOVE.L    D2,D4 
      MOVE.L    D1,D3 
Z0008:MOVE.L    D3,D0 
      BSR       Z0022 
      MOVE.L    D0,D1 
      MOVE.L    D3,D0 
      MOVEQ     #0,D2 
Z0009:BSR       Z0023 
      ADDQ.L    #2,D2 
      ADDQ.L    #1,D3 
      CMP.L     D0,D3 
      BEQ.S     Z0009 
      MOVE.L    D0,D3 
      MOVE.L    D4,D0 
      LSR.L     #8,D0 
      LSR.L     #1,D0 
      BEQ.S     Z000B 
      MOVEQ     #0,D5 
      CMP.L     D2,D0 
      BGE.S     Z000A 
      MOVE.L    D0,D2 
      MOVEQ     #-1,D5
Z000A:MOVEA.L   A5,A0 
      BSR       Z002E 
      ADD.L     D2,D1 
      MOVE.L    D2,D0 
      LSL.L     #8,D0 
      ADD.L     D0,D0 
      ADDA.L    D0,A5 
      SUB.L     D0,D4 
      BEQ.S     Z000D 
      TST.L     D5
      BEQ.S     Z0008 
Z000B:MOVE.L    D1,D0 
      BSR       Z002D 
Z000C:MOVE.B    (A6)+,(A5)+ 
      SUBQ.W    #1,D4 
      BNE.S     Z000C 
Z000D:MOVEQ     #0,D0 
Z000E:RTS 
Z000F:MOVE.L    A4,-(A7)
      MOVEQ     #0,D0 
      MOVEQ     #0,D1 
      MOVEQ     #0,D2 
      MOVEQ     #0,D3 
      MOVEQ     #0,D4 
      MOVE.L    Z0033(PC),D5
      ADD.L     D5,D5 
      ADDQ.L    #1,D5 
      MOVE.L    Z0032(PC),D6
      LSR.L     #4,D6 
      TST.B     (A4)
      BEQ       Z0018 
      BSR       Z0019 
      MOVE.L    D5,D1 
Z0010:MOVE.L    D1,D0 
      BSR       Z002D 
      BSR       Z002A 
      MOVEA.L   A6,A0 
      MOVEQ     #$F,D0
Z0011:BTST      #3,11(A0) 
      BNE.S     Z0015 
      MOVEA.L   A0,A1 
      LEA       Z0038(PC),A2
      MOVEQ     #$A,D2
Z0012:CMPM.B    (A1)+,(A2)+ 
      BNE.S     Z0013 
      DBF       D2,Z0012
      MOVE.L    D1,D3 
      MOVE.W    26(A0),D1 
      ROL.W     #8,D1 
      MOVE.L    28(A0),D2 
      ROL.W     #8,D2 
      SWAP      D2
      ROL.W     #8,D2 
      MOVEQ     #0,D4 
      MOVEQ     #0,D0 
      TST.B     (A4)
      BEQ.S     Z0018 
      BTST      #4,11(A0) 
      BEQ.S     Z0017 
      BSR.S     Z0019 
      MOVEQ     #0,D3 
      MOVE.L    D1,D4 
      MOVE.L    D1,D5 
      MOVE.L    D1,D0 
      BRA.S     Z0016 
Z0013:TST.B     (A0)
      BEQ.S     Z0014 
      CMPI.B    #-$1B,(A0)
      BNE.S     Z0015 
Z0014:TST.L     D3
      BNE.S     Z0015 
      MOVEA.L   A0,A3 
      MOVE.L    D1,D3 
Z0015:LEA       32(A0),A0 
      DBF       D0,Z0011
      ADDQ.L    #1,D1 
      SUBQ.L    #1,D6 
      BNE.S     Z0010 
      MOVE.L    D4,D0 
      BEQ.S     Z0017 
      BSR       Z0023 
Z0016:CMP.W     #$FFF,D0
      BEQ.S     Z0017 
      MOVE.L    D0,D4 
      BSR       Z0022 
      MOVE.L    D0,D1 
      MOVEQ     #2,D6 
      BRA       Z0010 
Z0017:MOVE.L    #$CC,D0 
      TST.B     (A4)
      BNE.S     Z0018 
      MOVEA.L   A3,A0 
      MOVEQ     #0,D1 
      MOVEQ     #0,D2 
      MOVE.L    #$CD,D0 
Z0018:MOVEA.L   (A7)+,A4
      RTS 
Z0019:MOVE.L    D1,-(A7)
      LEA       Z0038(PC),A0
      MOVEQ     #$A,D0
Z001A:MOVE.B    #$20,(A0)+
      DBF       D0,Z001A
      LEA       Z0038(PC),A0
      MOVEQ     #7,D1 
      BSR.S     Z001C 
      TST.B     D0
      BEQ.S     Z001B 
      CMP.B     #$2E,D0 
      BNE.S     Z001B 
      LEA       Z0039(PC),A0
      MOVEQ     #2,D1 
      BSR.S     Z001C 
Z001B:MOVE.L    (A7)+,D1
      RTS 
Z001C:MOVE.B    (A4),D0 
      BEQ.S     Z001D 
      ADDQ.W    #1,A4 
      BSR.S     Z001E 
      BEQ.S     Z001D 
      BSR.S     Z0020 
      MOVE.B    D0,(A0)+
      DBF       D1,Z001C
      MOVE.B    (A4),D0 
      BEQ.S     Z001D 
      BSR.S     Z001E 
      BNE.S     Z001D 
      ADDQ.W    #1,A4 
Z001D:RTS 
Z001E:TST.B     D0
      BEQ.S     Z001F 
      CMP.B     #$2E,D0 
      BEQ.S     Z001F 
      CMP.B     #$5C,D0 
Z001F:RTS 
Z0020:CMP.B     #$41,D0 
      BLT.S     Z0021 
      CMP.B     #$7A,D0 
      BGT.S     Z0021 
      ANDI.B    #-$21,D0
Z0021:RTS 
Z0022:MOVE.L    D1,-(A7)
      MOVE.L    Z0032(PC),D1
      LSR.L     #4,D1 
      ADD.L     Z0033(PC),D1
      ADD.L     Z0033(PC),D1
      SUBQ.L    #3,D1 
      ADD.L     D0,D0 
      ADD.L     D1,D0 
      MOVE.L    (A7)+,D1
      RTS 
Z0023:MOVEM.L   D1-D3,-(A7) 
      MOVE.L    D0,D3 
      BSR.S     Z0026 
      BSR       Z002B 
      MOVE.L    D1,D0 
      MOVE.B    0(A6,D0.W),D1 
      BSR.S     Z0028 
      MOVE.B    0(A6,D0.W),D2 
      BTST      #0,D3 
      BNE.S     Z0024 
      ANDI.W    #$FF,D1 
      ANDI.W    #$F,D2
      LSL.W     #8,D2 
      BRA.S     Z0025 
Z0024:ANDI.W    #$F0,D1 
      ANDI.W    #$FF,D2 
      LSL.W     #4,D2 
      LSR.W     #4,D1 
Z0025:OR.W      D2,D1 
      MOVEQ     #0,D0 
      MOVE.W    D1,D0 
      MOVEM.L   (A7)+,D1-D3 
      RTS 
Z0026:MOVE.L    D2,-(A7)
      MOVE.L    D0,D1 
      LSR.L     #1,D0 
      ADD.L     D1,D0 
      MOVE.L    D0,D1 
      ANDI.L    #$1FF,D1
      LSR.L     #8,D0 
      LSR.L     #1,D0 
      MOVE.L    Z0033(PC),D2
      CMP.B     #9,D2 
      BNE.S     Z0027 
      ADD.W     D2,D0 
Z0027:ADDQ.W    #1,D0 
      MOVE.L    (A7)+,D2
      RTS 
      LEA       Z0037(PC),A0
      MOVE.W    #-1,(A0)
Z0028:ADDQ.W    #1,D0 
      CMP.W     #$200,D0
      BLT.S     Z0029 
      MOVE.L    Z0036(PC),D0
      ADDQ.L    #1,D0 
      BSR.S     Z002B 
      MOVEQ     #0,D0 
Z0029:RTS 
Z002A:LEA       Z0036(PC),A0
      CLR.L     (A0)+ 
      CLR.W     (A0)
      RTS 
Z002B:MOVE.L    D1,-(A7)
      MOVE.L    Z0036(PC),D1
      CMP.L     D0,D1 
      BEQ.S     Z002C 
      BSR.S     Z002D 
      BSR.S     Z002D 
      LEA       Z0036(PC),A0
      MOVE.L    D0,(A0) 
Z002C:MOVE.L    (A7)+,D1
      RTS 
Z002D:MOVEM.L   A0/D0-D3,-(A7)
      MOVEQ     #0,D3 
      MOVE.L    D0,D1 
      BSR.S     Z002F 
      MOVEM.L   (A7)+,A0/D0-D3
      RTS 
Z002E:MOVE.L    D3,-(A7)
      MOVEQ     #0,D3 
      BSR.S     Z0030 
      MOVE.L    (A7)+,D3
      RTS 
Z002F:MOVEQ     #1,D2 
      MOVEA.L   A6,A0 
Z0030:MOVE.L    Z0034(PC),D0
      BSR.S     Z003A 
      BNE       Z0001 
      RTS 
Z0031:DS.W      2 
Z0032:DS.W      2 
Z0033:DS.W      2 
Z0034:DC.B      $00,$00,$00 
Z0035:DC.B      $00,$00,$00,$00,$00 
Z0036:DS.W      2 
Z0037:DC.B      $00,$00 
Z0038:DS.W      4 
Z0039:DS.W      2 
Z003A:MOVEM.L   A0-A1/D1-D4,-(A7) 
      LINK      A6,#-$1E
      MOVE.L    D0,D4 
      ANDI.W    #1,D0 
      MOVE.W    D0,-28(A6)
      SWAP      D0
      CMP.W     #9,D0 
      BLT.S     Z003B 
      CMP.W     #$B,D0
      BLE.S     Z003C 
Z003B:MOVE.W    #$A,D0
Z003C:MOVE.W    D0,-30(A6)
      MOVE.W    D1,-22(A6)
      MOVE.W    D2,-18(A6)
      MOVE.W    D3,-8(A6) 
      MOVE.L    A0,-12(A6)
      ROR.L     #3,D4 
      ANDI.W    #1,D4 
      EORI.B    #1,D4 
      ADDQ.B    #1,D4 
      MOVE.W    D4,-16(A6)
      CLR.W     D4
      ROL.L     #1,D4 
      MOVE.W    D4,-14(A6)
      MOVEQ     #$15,D0 
      ADD.W     D1,D2 
      MOVE.W    -30(A6),D3
      MULU      #$A0,D3 
      CMP.W     D3,D2 
      BGT       Z0041 
      EXT.L     D1
      DIVU      -30(A6),D1
      CMPI.W    #1,-16(A6)
      BEQ.S     Z003D 
      ADD.W     D1,D1 
Z003D:MOVE.W    D1,-26(A6)
      SWAP      D1
      ADDQ.W    #1,D1 
      MOVE.W    D1,-24(A6)
      BSR       Z0051 
Z003E:MOVE.W    -24(A6),D0
      MOVE.W    -30(A6),D1
      ADDQ.W    #1,D1 
      SUB.W     D0,D1 
      CMP.W     -18(A6),D1
      BLE.S     Z003F 
      MOVE.W    -18(A6),D1
Z003F:MOVE.W    D1,-20(A6)
      BSR.S     Z0042 
      BNE.S     Z0040 
      MOVE.W    -18(A6),D0
      SUB.W     -20(A6),D0
      BEQ.S     Z0040 
      MOVE.W    D0,-18(A6)
      MOVE.W    #1,-24(A6)
      MOVE.W    -16(A6),D0
      ADD.W     D0,-26(A6)
      MOVE.W    -20(A6),D0
      LSL.L     #8,D0 
      ADD.L     D0,D0 
      ADD.L     D0,-12(A6)
      BRA.S     Z003E 
Z0040:MOVE.L    D0,D1 
      BEQ.S     Z0041 
      ANDI.B    #$58,D0 
      MOVEQ     #$1C,D1 
      CMP.B     #$40,D0 
      BEQ.S     Z0041 
      MOVEQ     #$19,D1 
      CMP.B     #8,D0 
      BEQ.S     Z0041 
      MOVEQ     #$18,D1 
      CMP.B     #$18,D0 
      BEQ.S     Z0041 
      MOVEQ     #$15,D1 
      CMP.B     #$10,D0 
      BEQ.S     Z0041 
      MOVEQ     #-1,D1
Z0041:BSR       Z0053 
      UNLK      A6
      MOVE.L    D1,D0 
      MOVEM.L   (A7)+,A0-A1/D1-D4 
      RTS 
Z0042:BSR       Z0055 
      MOVE.W    #2,D3 
      BRA.S     Z0044 
Z0043:CMP.B     #$10,D0 
      BNE.S     Z0045 
      BSR       Z004F 
Z0044:MOVE.W    -26(A6),D0
      LSR.W     #1,D0 
      BSR       Z004D 
Z0045:MOVEA.L   -12(A6),A0
      MOVE.W    -24(A6),D1
      MOVE.W    -20(A6),D2
      BSR.S     Z0047 
      TST.W     D0
      BEQ.S     Z0046 
      CMP.B     #$40,D0 
      DBEQ      D3,Z0043
      TST.W     D0
Z0046:RTS 
Z0047:BSR       Z004C 
      MOVE.W    #$90,-$79FA.W
      MOVE.W    #$190,-$79FA.W
      MOVE.W    #$90,-$79FA.W 
      MOVEQ     #0,D0 
      MOVE.W    D2,D0 
      BSR       Z0060 
      LSL.L     #8,D0 
      ADD.L     D0,D0 
      MOVEA.L   A0,A1 
      ADDA.L    D0,A1 
      MOVE.W    #$80,-$79FA.W 
      MOVE.W    #$90,D0 
      BSR       Z0060 
      MOVE.L    #$40000,D0
      CLR.L     -4(A6)
Z0048:BTST      #5,-$5FF.W
      BEQ.S     Z0049 
      SUBQ.L    #1,D0 
      BEQ.S     Z004A 
      MOVE.B    -$79F7.W,-3(A6) 
      MOVE.B    -$79F5.W,-2(A6) 
      MOVE.B    -$79F3.W,-1(A6) 
      CMPA.L    -4(A6),A1 
      BGT.S     Z0048 
      BSR       Z005D 
Z0049:MOVE.W    #$90,-$79FA.W 
      MOVE.W    -$79FA.W,D0 
      BTST      #0,D0 
      BEQ.S     Z004B 
      BSR       Z005E 
      ANDI.B    #$18,D0 
      RTS 
Z004A:BSR       Z005D 
Z004B:MOVEQ     #-1,D0
      RTS 
Z004C:MOVE.L    A0,D0 
      MOVE.B    D0,-$79F3.W 
      LSR.L     #8,D0 
      MOVE.B    D0,-$79F5.W 
      LSR.L     #8,D0 
      MOVE.B    D0,-$79F7.W 
      MOVE.W    #$84,-$79FA.W 
      MOVE.W    D1,D0 
      BRA       Z0060 
Z004D:TST.W     D0
      BEQ.S     Z004F 
      MOVE.W    #$86,-$79FA.W 
      BSR       Z0060 
      MOVE.W    #$10,D0 
      BSR       Z005A 
      BMI.S     Z004E 
      MOVEQ     #0,D0 
Z004E:RTS 
Z004F:MOVEQ     #0,D0 
      BSR       Z005A 
      BMI.S     Z0050 
      EORI.B    #4,D0 
      BTST      #2,D0 
      BNE.S     Z0050 
      MOVEQ     #0,D0 
Z0050:RTS 
Z0051:MOVE.W    $43E.W,-6(A6) 
      ST        $43E.W
      BSR.S     Z0055 
      MOVE.W    -28(A6),D0
      ADD.W     D0,D0 
      MOVE.W    #$82,-$79FA.W 
      LEA       ZUEND+0(PC),A0
      MOVE.W    0(A0,D0.W),D0 
      LSR.W     #1,D0 
      BSR       Z0060 
      CMP.W     #$A0,D0 
      BLT.S     Z0052 
      BSR.S     Z004F 
Z0052:RTS 
Z0053:MOVEM.L   D0-D1,-(A7) 
      MOVE.W    -28(A6),D0
      ADD.W     D0,D0 
      LEA       ZUEND+0(PC),A0
      MOVE.W    -26(A6),D1
      MOVE.W    D1,0(A0,D0.W) 
      TST.W     -8(A6)
      BPL.S     Z0054 
      MOVE.L    #$C3500,D0
      BSR       Z0062 
Z0054:MOVEQ     #7,D0 
      BSR.S     Z0059 
      MOVE.W    -6(A6),$43E.W 
      MOVEM.L   (A7)+,D0-D1 
      RTS 
Z0055:MOVE.W    D0,-(A7)
      MOVE.W    -28(A6),D0
      ANDI.W    #1,D0 
      ADDQ.B    #1,D0 
      ADD.B     D0,D0 
      MOVE.W    D0,-(A7)
      BSR.S     Z0056 
      OR.W      (A7)+,D0
      EORI.B    #7,D0 
      ANDI.B    #7,D0 
      BSR.S     Z0059 
      MOVE.W    (A7)+,D0
      RTS 
Z0056:MOVE.W    -16(A6),D0
      CMP.W     #1,D0 
      BEQ.S     Z0057 
      MOVE.W    -14(A6),D0
      BRA.S     Z0058 
Z0057:MOVE.W    -26(A6),D0
      ANDI.W    #1,D0 
Z0058:RTS 
Z0059:MOVE      SR,-(A7)
      ORI.W     #$700,SR
      MOVE.B    #$E,-$7800.W
      MOVE.B    -$7800.W,D1 
      ANDI.B    #-8,D1
      OR.B      D0,D1 
      MOVE.B    D1,-$77FE.W 
      MOVE      (A7)+,SR
      RTS 
Z005A:CMP.B     #-$80,D0
      BCC.S     Z005B 
      ORI.B     #3,D0 
Z005B:MOVE.W    #$80,-$79FA.W 
      BSR.S     Z0060 
      MOVE.L    #$60000,D0
Z005C:BTST      #5,-$5FF.W
      BEQ.S     Z005E 
      SUBQ.L    #1,D0 
      BNE.S     Z005C 
      BSR.S     Z005D 
      MOVEQ     #-1,D0
      RTS 
Z005D:MOVE.W    #$80,-$79FA.W 
      MOVE.W    #$D0,D0 
      BSR.S     Z0060 
      MOVEQ     #$F,D0
      BSR.S     Z0062 
      BRA.S     Z005E 
      MOVE.W    #$180,-$79FA.W
      BRA.S     Z005F 
Z005E:MOVE.W    #$80,-$79FA.W 
Z005F:BSR.S     Z0061 
      MOVE.W    -$79FC.W,D0 
      ANDI.L    #$FF,D0 
      BRA.S     Z0061 
Z0060:BSR.S     Z0061 
      MOVE.W    D0,-$79FC.W 
Z0061:MOVE      SR,-(A7)
      MOVE.W    D0,-(A7)
      MOVEQ     #$18,D0 
      BSR.S     Z0062 
      MOVE.W    (A7)+,D0
      MOVE      (A7)+,SR
      RTS 
Z0062:	SUBQ.L	#1,D0
	BNE	Z0062
	RTS

ERROR2	MOVE.W	D0,$FFFF8240
	ADD.W	#$123,D0
	BRA	ERROR2


ERROR	MOVE.L	#-1,D0
	RTS

RES	MOVE.W	#$777,$FFFF8240
	MOVE.W	#0,$FFFF8246
	CLR.W	-(A7)
	TRAP	#1

	;---- BAAL TRAINER MENU BY DR.D ----;
	
	
MENU	DC.W	$A00A		;HIDE MOUSE
	BCHG	#0,$484		;CLICK OFF
	BSR	SETMED		;MEDIUM RES

	MOVE.L	$42E,D0
	CMP.L	#$100000,D0
	BGE	MEGOK
	
	LEA	NOMEG(PC),A6
	BSR	PRINT
AAA	BSR	WAITKEY
	CMP.B	#$39,D7
	BNE	AAA
	MOVEQ	#-1,D0
	RTS

MEGOK	LEA	NOALT(PC),A0
	MOVE.L	A0,$502
	BSR	SETPAL		;WHITE ON BLACK

	LEA	CREDIT(PC),A0
	MOVEQ	#104,D0
DEC1	NOT.B	(A0)+
	DBF	D0,DEC1

	LEA	INFO(PC),A0
	MOVE.L	#656,D0
DEC2	NOT.B	(A0)+
	DBF	D0,DEC2

	BSR	DOCREDIT		;PRINT CREDITS
	BSR	DO_OPTIONS	;PRINT MENU OPTIONS
NEXT	BSR	WAITKEY		;WAIT FOR FKEY PRESSED

;--------------------------------------
	LEA	YOFF(PC),A0
	MOVE.L	#"NO  ",D0
	MOVE.L	#"YES ",D1	

F1	CMP.B	#$3B,D7
	BNE	F2
	MOVE.B	#32+10,(A0)
	LEA	LIVES(PC),A1
	BSR	GETYN
	BRA	NEXT
			
F2	CMP.B	#$3C,D7
	BNE	F3
	MOVE.B	#32+12,(A0)
	LEA	LFUEL(PC),A1
	BSR	GETYN
	BRA	NEXT
		
F3	CMP.B	#$3D,D7
	BNE	F4
	MOVE.B	#32+14,(A0)
	LEA	JFUEL(PC),A1
	BSR	GETYN
	BRA	NEXT
	
F4	CMP.B	#$3E,D7
	BNE	F5
	MOVE.B	#32+16,(A0)
	LEA	WEAPS(PC),A1
	BSR	GETYN
	BRA	NEXT


F5	CMP.B	#$3F,D7
	BNE	NEXT
	
EXIT	LEA	INFO(PC),A6
	BSR	PRINT
	MOVEQ	#0,D0
	RTS

;--------------------------------------------------------
GETYN	LEA	YN(PC),A2

	TST.B	1(A1)	;IS IT 0
	BNE	STY	;IF NOT SET TO NO
	BRA	SETYES
	
STY	MOVE.B	#0,(A1)
	MOVE.L	D0,(A2)	;SET TO NO
	CLR.B	1(A1)	
	LEA	COL(PC),A0
	MOVE.B	#1,(A0)
	BRA	DO_OPTS

SETYES	MOVE.L	D1,(A2)
	MOVE.B	#1,(A1)	;SET TRAINER OPTION TO YES
	MOVE.B	#1,1(A1)
	LEA	COL(PC),A0
	MOVE.B	#2,(A0)
	
DO_OPTS	BSR	UPDATE
	RTS
	

;-----------------------------

WAITKEY	MOVE.W	#7,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	SWAP	D0
	MOVE.L	D0,D7
	RTS

;-----------------------------
PRINT	MOVE.L	A6,-(A7)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	RTS	
;-----------------------------

DOCREDIT	LEA	CREDIT(PC),A6
	BSR	PRINT	
	RTS
;-----------------------------

DO_OPTIONS	
	LEA	OPTIONS(PC),A6
	BSR	PRINT

	LEA	YOFF(PC),A5
	LEA	YN(PC),A3
	MOVE.L	#"NO  ",(A3)
	LEA	LIVES(PC),A4
	CLR.L	(A4)
	CLR.L	4(A4)
	ADD.B	#10,(A5)
	BSR	UPDATE
	ADD.B	#2,(A5)
	BSR	UPDATE
	ADD.B	#2,(A5)
	BSR	UPDATE
	ADD.B	#2,(A5)
	BSR	UPDATE

	RTS
;-----------------------------

UPDATE	LEA	YESNO(PC),A6
	BSR	PRINT
	LEA	YN(PC),A6
	BSR	PRINT
	RTS
;-----------------------------

SETMED	MOVE.W	#1,D7
	BSR	SETRES
	RTS

SETLOW	CLR.W	D7
	BSR	SETRES
	RTS
	
SETRES	MOVE.W	D7,-(A7)
	PEA	-1
	PEA	-1
	MOVE.W	#5,-(A7)
	TRAP	#14
	ADD.L	#12,A7
	RTS
;-----------------------------

SETPAL	PEA	PAL(PC)
	MOVE.W	#6,-(A7)
	TRAP	#14
	ADD.L	#6,A7
	RTS


***********************************************

;	00.DAT = SAVED POSITION
;	01.DAT = HI SCORES

SAVEPOS	MOVEM.L	D0-A6,-(A7)

;	LEA	REGS(PC),A3
;	MOVE.L	D0,(A3)
;	MOVE.L	D1,4(A3)
;	MOVE.L	A0,8(A3)
;	MOVE.L	A1,12(A3)

	MOVE.L	A0,A4		;SAVE ADDRESS
	LEA	GAMEHARD(PC),A1	;SAVE GAMES HARDWARE ADDRESSES
	BSR	SAVEHARD
	LEA	GEMHARD(PC),A0
	BSR	RESTHARD		;RESTORE GEM HARDWARE ADDRESSES
	MOVE.L	#5120,D7		;LENGTH TO SAVE
	LEA	POSITION(PC),A5	;FILE NAME
	BSR	CREATE
	LEA	GAMEHARD(PC),A0	;RESTORE GAMES HARDWARE ADDRESSES
	BSR	RESTHARD
EXIT2	MOVEM.L	(A7)+,D0-A6
	RTE

SAVESCORE	MOVEM.L	D0-A6,-(A7)
	MOVE.L	A0,A4
	LEA	GAMEHARD(PC),A1	;SAVE GAMES HARDWARE ADDRESSES
	BSR	SAVEHARD
	LEA	GEMHARD(PC),A0
	BSR	RESTHARD		;RESTORE GEM HARDWARE ADDRESSES
	MOVE.L	#1200,D7		;LENGTH TO SAVE
	LEA	SCORES(PC),A5	;FILE NAME
	BSR	CREATE
	LEA	GAMEHARD(PC),A0	;RESTORE GAMES HARDWARE ADDRESSES
	BSR	RESTHARD
	MOVEM.L	(A7)+,D0-A6
	RTE

	
SAVEHARD	LEA	8,A0
	MOVEQ	#9,D0
H1	MOVE.L	(A0)+,(A1)+
	DBF	D0,H1
	LEA	$80,A0
	MOVEQ	#9,D0
H2	MOVE.L	(A0)+,(A1)+
	DBF	D0,H2
	LEA	$100,A0
	MOVEQ	#15,D0
H3	MOVE.L	(A0)+,(A1)+
	DBF	D0,H3
	MOVE.L	$70,(A1)+
	MOVE.L	$118,(A1)+
	MOVE.B	$FFFFFA07,(A1)+
	MOVE.B	$FFFFFA09,(A1)+
	MOVE.B	$FFFFFA13,(A1)+
	MOVE.B	$FFFFFA15,(A1)+
	RTS


RESTHARD	LEA	8,A1
	MOVEQ	#9,D0
S1	MOVE.L	(A0)+,(A1)+
	DBF	D0,S1
	LEA	$80,A1
	MOVEQ	#9,D0
S2	MOVE.L	(A0)+,(A1)+
	DBF	D0,S2
	LEA	$100,A1
	MOVEQ	#15,D0
S3	MOVE.L	(A0)+,(A1)+
	DBF	D0,S3
	MOVE.L	(A0)+,$70
	MOVE.L	(A0)+,$118
	MOVE.B	(A0)+,$FFFFFA07
	MOVE.B	(A0)+,$FFFFFA09
	MOVE.B	(A0)+,$FFFFFA13
	MOVE.B	(A0)+,$FFFFFA15
	RTS
	
CREATE	CLR.W	-(A7)		;R/W STATUS
	MOVE.L	A5,-(A7)	;FILE NAME
	MOVE.W	#$3C,-(A7)	;CREATE
	TRAP	#1
	ADDQ.L	#8,A7
	TST.L	D0
	BMI	ER
	MOVE.W	D0,D6
	
WRITE	MOVE.L	A4,-(A7)	;SAVE ADDRESS
	MOVE.L	D7,-(A7)	;LENGTH TO WRITE
	MOVE.W	D6,-(A7)	;HANDLE
	MOVE.W	#$40,-(A7)
	TRAP	#1
	ADD.L	#12,A7
	TST.L	D0
	BMI	ER
	
CLOSE	MOVE.W	D6,-(A7)	;HANDLE
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	TST.L	D0
	BMI	ER

	RTS

ER	MOVEM.L	(A7)+,D0-A6
	LEA	DEST+$DC2,A0
	MOVE.L	#-1,(A0)
	MOVEM.L	(A7)+,A0-A6
	RTS
		

POSITION	DC.B	"00.DAT",0
	EVEN

SCORES	DC.B	"01.DAT",0
	EVEN


	
GEMHARD	DS.B	256

GAMEHARD	DS.B	256
******************************************************	


;-----------------------------

	DATA

CREDIT	;INCBIN	"CREDIT.DAT"

;	DC.B	27,"E"
;	DC.B	27,"Y",32+0,32+30,"* ---    BAAL    --- *"
;	DC.B	27,"Y",32+2,32+35,"1 MEG VERSION"	
;	DC.B	27,"Y",32+5,32+25,"CRACKED, TRAINED, FILED & PACKED"
;	DC.B	27,"Y",32+7,32+33,"BY DR.D of T.C.D"
;	DC.B	0

CREDEND	DC.W	0
	EVEN
	
	
OPTIONS	DC.B	27,"Y",32+10,32+26,"[F1]  INFINITE LIVES"
	DC.B	27,"Y",32+12,32+26,"[F2]  INFINITE LASER FUEL"
	DC.B	27,"Y",32+14,32+26,"[F3]  INFINITE JETPACK FUEL"
	DC.B	27,"Y",32+16,32+26,"[F4]  ALL WEAPONS (Keys 1-4)"
	DC.B	27,"Y",32+18,32+26,"[F5]  LOAD GAME"
	DC.B	0

	EVEN

YESNO	DC.B	27,"Y"
YOFF	DC.B	32
	DC.B	32+26+30
	DC.B	27,"b"
COL	DC.B	1,0
YN	DC.B	"NO  "
	DC.B	0
	
	EVEN	

INFO	;INCBIN	"INFO.DAT"

;	DC.B	27,"E"
;	DC.B	27,"b",3
;	DC.B	27,"Y",32+1,32+16,"------=======> BAAL GAME INFO <=======------"
;	DC.B	27,"Y",32+4,32+10,"This game is from 1988 and was a bastard to crack and file."
;	DC.B	27,"Y",32+6,32+17,"The game was on 2 raw data non-dos disks."
;	DC.B	27,"Y",32+7,32+10,"Tracks 0-41, 42-61 and 62-79 were all different formats."
;	DC.B	27,"Y",32+9,32+10,"I have kept the save game and positon option so make sure"
;	DC.B	27,"Y",32+10,32+10,"the write protect is left off or the game will hang up!!"
;	DC.B	27,"Y",32+13,32+18,"Send this disk to the following address:"
;	DC.B	27,"Y",32+15,32+10,"Wayne Smithson, 24 Coal Hill Green, Bramley, Leeds, England"
;	DC.B	27,"Y",32+17,32+24,"HE'S THE AUTHOR OF THE GAME!"
;	DC.B	27,"Y",32+22,32+26,"PRESS SPACE TO CONTINUE"
;	DC.B	0

INFEND	DC.W	0
	EVEN

NOMEG	DC.B	27,"E"
	DC.B	27,"Y",32+10,32+16
	DC.B	"THIS VERSION OF BAAL REQUIRES 1 MEG TO RUN"
	DC.B	0
	EVEN

	
MAIN	DC.B	"TIMELORD.DAT",0
	EVEN
	
FNAME	DC.B	"1"
FCNT	DC.B	"0"		;CHANGES FOR FILE NAME TO LOAD
	DC.B	".DAT",0
	EVEN

PAL	DC.W	$000,$700,$070,$777

UNPCOL	DC.W	$666

	BSS

LIVES	DS.B	2
LFUEL	DS.B	2
JFUEL	DS.B	2
WEAPS	DS.B	2
	


TRAINER	DS.W	1

	EVEN

OTHER	DS.B	2000


BUFFER

ZUEND

