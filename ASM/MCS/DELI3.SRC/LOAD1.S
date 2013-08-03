	;opt d+
	MOVE.L	#STACK,-(A7)
	MOVE.W	#$20,-(A7)
	TRAP 	#1
	ADDQ.L	#6,A7
	MOVE.W	#$4EF9,$8C
	LEA	DEBUT(PC),A0
	MOVE.L	A0,$8E
	BCLR.B	#0,$484
	move.w #0,-(a7)
	move.l #$78000,-(a7)
	move.l #$78000,-(a7)
	move.w #5,-(a7)
	trap #14
	add.l #12,a7

DEBUT
	move.b #0,$ff8265
	move.b #0,$ff820f	
	LEA	PALETTE,A0
	LEA	$FF8240,A1
	REPT 8
	MOVE.L	(A0)+,(A1)+
	ENDR
	MOVE.L	#TEXT1,SOURCE
	MOVE.W #$48,LS
	MOVE.W #$84,X
	MOVE.W #$37,Y
	bsr	blit_it
	JSR 	MOD
	BSR	RESTART
	MOVE.L	#0,MUSI
	MOVE.W		#1,$FF8920   
	MOVE.L		#MU,D0
	LEA		$FF8901,A0
	MOVEP.L	D0,(A0)
	MOVE.L 	#MUS_END,D0	
	MOVEP.L	D0,12(A0)	
	MOVE.L	#BEG,$4D2
DEB	MOVE.B	$FFFC02,D0
	CMP.B	#$6D,D0
	BEQ	SUIT1
	CMP.B	#$6E,D0
	BEQ	SUIT2
	CMP.B	#$6F,D0
	BEQ	SUIT3
	CMP.B  #1,D0
	BEQ	FIN
	BRA	DEB
SUIT1	LEA	$25000,A0
	MOVE.L	#223,D0
	MOVE.L	#488-223+1,D1
	MOVE.L	#4,D3
	MOVE.L	#ANIM1,$4D6
	BSR	LOAD
	TST.W D4
	BNE	SUIT1
	BRA	FINISH
SUIT2	LEA	$25000,A0
	MOVE.L #11,D0
	MOVE.L #221-11+1,D1
	MOVE.L	#4,D3
	MOVE.L	#ANIM1,$4D6
	BSR	LOAD
	TST.W D4
	BNE	SUIT2
	BRA	FINISH
SUIT3	LEA	$25000,A0
	MOVE.L	#461,D0
	MOVE.L	#611-461+1,D1
	MOVE.L	#4,D3
	MOVE.L	#ANIM1,$4D6
	BSR	LOAD
	TST.W D4
	BNE	SUIT3
FINISH	NOP
	MOVE.W #1,BLIT
BL	CMP.W #2,BLIT
	BNE	BL
	MOVE.W #0,BLIT	
	MOVE.L	#ANIM2,$4D6
	LEA	$25000,A0
	bsr	decrunch
	bsr	relok
	
	;MOVE.L	#$2501C,$24f24
	JMP	$25000
FIN	MOVE.L	#0,$4D2
	MOVE.L	#0,$4D6
	MOVE.W	#0,$FF8900
	CLR.W	-(A7)
	TRAP #1
SEARCH	MOVE.W $AA9A,D0
	MULU #6,D0
	LEA	DATAFILE,A0
	;LEA	$AA9C,A0
	ADD.L D0,A0
	MOVE.W (A0)+,D0
	MOVE.W (A0)+,D1
	MOVE.W (A0)+,D3
	RTS
loading equ $25000
relok
       move.l   start(pc),a6
       movea.l  loading+02,a0    * longueur du code
       adda.l   loading+06,a0    * + longueur des data
       move.l   a6,d1            * adresse de base de la relocation
       move.l   #loading+28,d2   * adresse de debut du prog
        
       movea.l  d2,a2       
       movea.l  d2,a3
       adda.l   a0,a3
       move.l   (a3)+,d0        * 1er offset sur un mot long
       beq      reloc3          * si = 0 alors pas de relocation
       clr.l    -4(a3)
reloc1 adda.l   d0,a2           * pointer sur la prochaine adresse a changer 
       moveq    #0,d0           
       add.l    d1,(a2)         * ajouter l'adresse de base
reloc2 move.b   (a3),d0      
       beq      reloc3          * si = 0 alors fin de la relocation
       clr.b    (a3)+
       cmp.b    #1,d0           * si = 1 alors saut de 254 octets
       bne      reloc1
       adda.l   #254,a2
       bra      reloc2
reloc3 lea      -$100(a6),a6
       move.l   loading+2,$C(a6)    * long du texte
       move.l   loading+6,$14(a6)   * long des data
       move.l   loading+10,$1C(a6)  * long des BSS
       move.l   $8(a6),$10(a6)
       move.l   $C(a6),d0
       add.l    d0,$10(a6)         * adresse des DATA
       move.l   $10(a6),$18(a6)
       move.l   $14(a6),d0
       add.l    d0,$18(a6)         * adresse des BSS       
       
       movea.l #loading+28,a0
       movea.l a0,a1
       adda.l  #290000,a1
       movea.l start(pc),a2
rel1   move.l  (a0)+,(a2)+
       cmpa.l  a0,a1
       bge     rel1
	rts       
        move.l  start(pc),a0
        suba.l  #$100,a0
	move.l  a0,4(sp)       * adresse du header dans pile+4
	jmp     $100(a0)

start dc.l $25000

decrunch:	movem.l d0-a6,-(sp)		
		cmpi.l	#'Ice!',(a0)+		
		bne.s	ice2_07		
		move.l	(a0)+,d0		
		lea	-8(a0,d0.l),a5	
		move.l	(a0)+,(sp)
		lea	108(a0),a4
		movea.l a4,a6
		adda.l	(sp),a6
		movea.l a6,a3
		movea.l a6,a1			
		lea	ice2_21+120(pc),a2	
		moveq	#$77,d0		
ice2_00:	move.b	-(a1),-(a2)
		dbra	d0,ice2_00
		bsr	ice2_0c
		bsr.s	ice2_08
ice2_04:	move.l	(sp),d0		
		lea	-120(a4),a1		
ice2_05:	move.b	(a4)+,(a1)+
		dbra	d0,ice2_05
		subi.l	#$010000,d0
		bpl.s	ice2_05
		moveq	#$77,d0		
		lea	ice2_21+120(pc),a2
ice2_06:	move.b	-(a2),-(a3)
		dbra	d0,ice2_06
ice2_07:	
		movem.l (sp)+,d0-a6		
		rts
ice2_08:	bsr.s	ice2_10
		bcc.s	ice2_0b
		moveq	#0,d1
		bsr.s	ice2_10
		bcc.s	ice2_0a
		lea	ice2_1e(pc),a1
		moveq	#4,d3
ice2_09:	move.l	-(a1),d0
		bsr.s	ice2_13
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice2_09
		add.l	20(a1),d1
ice2_0a:	move.b	-(a5),-(a6)
		dbra	d1,ice2_0a
ice2_0b:	cmpa.l	a4,a6
		bgt.s	ice2_16
		rts
ice2_0c:	moveq	#3,d0
ice2_0d:	move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice2_0d
		rts
ice2_0e:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_0f
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice2_15
ice2_0f:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice2_15
ice2_10:	add.l	d7,d7
		beq.s	ice2_11
		rts
ice2_11:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_12
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice2_12:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice2_13:	moveq	#0,d1
ice2_14:	add.l	d7,d7
		beq.s	ice2_0e
ice2_15:	addx.w	d1,d1
		dbra	d0,ice2_14
		rts
ice2_16:	lea	ice2_1f(pc),a1
		moveq	#3,d2
ice2_17:	bsr.s	ice2_10
		dbcc	d2,ice2_17
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice2_18
		bsr.s	ice2_13
ice2_18:	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice2_1a
		lea	ice2_20(pc),a1
		moveq	#1,d2
ice2_19:	bsr.s	ice2_10
		dbcc	d2,ice2_19
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice2_13
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice2_1c
ice2_1a:	moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice2_10
		bcc.s	ice2_1b
		moveq	#8,d0
		moveq	#$40,d2
ice2_1b:	bsr.s	ice2_13
		add.w	d2,d1
ice2_1c:	lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice2_1d:	move.b	-(a1),-(a6)
		dbra	d4,ice2_1d
		bra	ice2_08
		dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
		dc.b $00,$07,$00,$02,$00,$03,$00,$01
		dc.b $00,$03,$00,$01
ice2_1e:	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
		dc.b $00,$00,$00,$07,$00,$00,$00,$04
		dc.b $00,$00,$00,$01
ice2_1f:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
		dc.b $01,$00
ice2_20:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
		dc.b $00,$20
ice2_21:	ds.w 60	
	even



LOAD  MOVE.W  D1,D2 
      SUBQ.W  #1,D2 
      BMI.S   L0003 
      EXT.L   D0
      DIVU    #$A,D0
      MOVE.L  D0,D1 
      SWAP    D1
      ADDQ.W  #1,D1 
      BSR     L001C 
L0000
	BSR     L0004 
      TST.W   D4
      BNE.S   L0002 
      ADDQ.W  #1,D1 
      CMP.W   #$A,D1
      BLE.S   L0001 
      MOVEQ   #1,D1 
      ADDQ.W  #1,D0 
L0001:DBF     D2,L0000
L0002:BSR     L001F 
      TST.W   D4
      RTS 
L0003:MOVEQ   #-1,D4
      RTS 
L0004:MOVE.W  #2,L3B12
      TST.W   L3B10 
      BPL.S   L0006 
L0005:BSR     L0029 
L0006:CMP.W   L0033(PC),D0
      BEQ.S   L0007 
      BSR     L0025 
L0007:MOVE.B  L0031(PC),-$79F3.W
      MOVE.B  L0030(PC),-$79F5.W
      MOVE.B  L002F(PC),-$79F7.W
      MOVE.W  #$84,(A6) 
      MOVE.W  D1,(A5) 
      BSR.S   L000A 
      MOVE.W  #$90,(A6) 
      MOVE.W  #$190,(A6)
      MOVE.W  #$90,(A6) 
      MOVE.W  #1,(A5) 
      MOVE.W  #$80,(A6) 
      MOVE.W  #$80,(A5) 
      BSR.S   L000D 
      MOVEQ   #4,D4 
      SWAP    D4
L0008:BTST    #5,-$5FF.W
      BEQ.S   L0009 
      SUBQ.L  #1,D4 
      BNE.S   L0008 
      BSR     L002D 
      MOVEQ   #-1,D4
      RTS 
L0009:MOVE.W  (A5),D4 
      ANDI.W  #$18,D4 
      BEQ.S   L000B 
      SUBQ.W  #1,L3B12
      BEQ.S   L0005 
      BCC.S   L0007 
L000A:RTS 
L000B:MOVE.W  #$90,(A6) 
      MOVE.W  (A6),D4 
      NOT.W   D4
      ANDI.W  #1,D4 
      BNE.S   L000C 
      ADDI.L  #$200,L3B08 
      TST.W   D4
L000C:RTS 
L000D:MOVEQ   #$A,D7
L000E:DBF     D7,L000E
      RTS 

L001C:LEA     -$79FA.W,A6 
      LEA     -$79FC.W,A5 
      BSR.S   L001D 
      MOVE.L  A0,L3B08
      RTS 
L001D:MOVE.W  L0032(PC),D6
      ADDQ.B  #1,D6 
      LSL.B   #1,D6 
      OR.W    L3B0E,D6
      EORI.B  #7,D6 
      ANDI.B  #7,D6 
      BSR.S   L0023 
      MOVE.W  #$82,(A6) 
      MOVE.W  L0033(PC),(A5)
      BSR     L001E 
L001E:RTS 
L001F:MOVE.W  #$1C2,D6
L0020:MOVE.W  #$1000,D7 
L0021:DBF     D7,L0021
      BSR     L0024 
      BEQ.S   L0022 
      SUBQ.W  #1,D6 
      BNE.S   L0020 
      BSR     L002D 
L0022:MOVEQ   #7,D6 
L0023:MOVE    SR,-(A7)
      ORI.W   #$700,SR
      MOVE.B  #$E,-$7800.W
      MOVE.B  -$7800.W,D7 
      MOVE.B  D3,D7 
      NOP 
      MOVE.B  D7,-$77FE.W 
      MOVE    (A7)+,SR
      RTS 
L0024:MOVE    SR,-(A7)
      ORI.W   #$700,SR
      MOVE.W  #$80,(A6) 
      MOVE.W  (A5),D7 
      MOVE    (A7)+,SR
      BTST    #7,D7 
      RTS 
L0025:MOVE.W  #$86,(A6) 
      MOVE.W  D0,(A5) 
      BSR.S   L0028 
      MOVE.W  #$80,(A6) 
      MOVE.W  #$13,(A5) 
      BSR     L000D 
      MOVEQ   #8,D4 
      SWAP    D4
L0026:BTST    #5,-$5FF.W
      BEQ.S   L0027 
      SUBQ.L  #1,D4 
      BNE.S   L0026 
      BSR     L002D 
      MOVEQ   #-1,D4
      RTS 
L0027:MOVE.W  D0,L3B10
      MOVE.W  (A5),D4 
      ANDI.W  #$10,D4 
L0028:RTS 
L0029:MOVE.W  #$80,(A6) 
      MOVE.W  #3,(A5) 
      BSR     L000D 
L002A:BTST    #5,-$5FF.W
      BNE.S   L002A 
L002B:MOVE.W  (A5),D4 
      BCHG    #2,D4 
      ANDI.W  #4,D4 
      MOVE.W  #$82,(A6) 
      CLR.W   (A5)
      BSR.S   L002C 
      CLR.W   L3B10 
      TST.W   D4
L002C:RTS 
L002D:MOVE.W  #$80,(A6) 
      MOVE.W  #$D0,(A5) 
      MOVEQ   #$20,D4 
L002E:DBF     D4,L002E
      MOVE.W  (A5),D4 
      RTS 
L3B08	DC.L 0
L3B0E	DC.W 0
L3B10	DC.W 0
L3B12	DC.W 0
L3B16	DC.W 0
ZUEND DCB.W 8,0
L002F EQU L3B08+1 
L0030 EQU L3B08+2 
L0031 EQU L3B08+3 
L0032 EQU ZUEND+4 
L0033 EQU ZUEND+8
	EVEN	

MOD	BSR	INIT_MUZEXX
	BRA	PLAY_MUZEXX
	BRA	PLAY_MUZ

INIT_MUZEXX
	LEA		SEQ(PC),A0
	LEA		PAT(PC),A1
	LEA		NBR_INS(PC),A2
	LEA		MUZEXX,A3
	MOVE	#$1D8,(A0)
	MOVE	#$258,(A1)
	MOVE	#15,(A2)
	CMP.L	#'M.K.',$438(A3)
	BNE		REAL_DOCs_MODULE
	MOVE	#$3B8,(A0)
	MOVE	#$43C,(A1)
	MOVE	#31,(A2)
REAL_DOCs_MODULE

	LEA		MUZEXX(PC),A0
	ADD		SEQ(PC),A0
	MOVE.L	#$80,D0
	MOVEQ	#0,D1
INIT_MUZEXX1
	MOVE.L	D1,D2
	SUBQ	#1,D0
INIT_MUZEXX2
	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	INIT_MUZEXX1
	DBF		D0,INIT_MUZEXX2
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	LEA		MUZEXX(PC),A0
	ADD		PAT,A0
	ADD.L	D2,A0
	LEA		20+MUZEXX(PC),A1
	LEA		16+INS(PC),A2
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
	BEQ		INIT_MUZEXX4
	SUBQ	#1,D1
INIT_MUZEXX4
	MOVE	D1,12(A2)
	MOVEQ	#0,D1
	MOVE	28(A1),D1
	LSL.L	#1,D1
	CMP.L	#2,D1
	BNE		INIT_MUZEXX5
	MOVEQ	#0,D1
INIT_MUZEXX5
	SWAP	D1
	MOVE.L	D1,8(A2)
	LEA		30(A1),A1
	LEA		16(A2),A2
	DBRA	D0,INIT_MUZEXX3


	LEA 		MU,A0
	MOVE.W		#2520,D0
CCLR	MOVE.L 	#0,(A0)+
	DBF		D0,CCLR
 	

	MOVE.L		#$33fc0003,rt
	MOVE.L		#$00ff8900,rt+4	
	RTS

PLAY_MUZEXX
ON	
	MOVE	#6,SPD+2
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA		MUZEXX(PC),A0
	ADD		SEQ(PC),A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF(PC),A0
	LEA		OFF(PC),A1
	LEA		OFF(PC),A2
	LEA		OFF(PC),A3
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
	MOVE.W	#$7FF,$FFFF8924
	MOVE.W	#$48C,$FFFF8922
	RTS


MUSC		DC.L	MU,MU+504,MU+1008,MU+1512,MU+2016,MU+2520,MU+3024
		DC.L	MU+3528,MU+4032,MU+4536,MU+5040,MU+5544,MU+6046
		DC.L	MU+6550,MU+7054,MU+7558,MU+8062,MU+8566,MU+9070
		DC.L	MU+9574

AMIGA	
	MOVE.B		MUSI,D7
	ADDQ.B		#4,D7
	CMP.B		#80,D7
	BNE.S		AM3
	MOVEQ.B	#0,D7
AM3
	MOVE.B		D7,MUSI
	MOVE.L		MUSC(PC,D7.W),A4
AMM
	MOVEQ		#0,D7
	MOVE.W		#252,D6
AM2
	SWAP		D0					
	SWAP		D1					
	SWAP		D3					
V0	SUB.L		#0,D0					
	BMI.S		L0					
V1	SUB.L		#0,D1					
	BMI.S		L1					

V3	SUB.L		#0,D3					
	BMI.S		L3					
OUT	SWAP		D0					
	SWAP		D1					
	SWAP		D3					
	MOVE.B		0(A0,D0),D4				
	MOVE.B		0(A1,D1),D5				
	ADD.B		0(A3,D3),D5					
	MOVE.B		D4,(A4)+			
	MOVE.B		D5,(A4)+
	DBF D6,AM2						
rt	MOVE.W 	#3,$FF8900
	MOVE.W		#$4E75,rt
	RTS	
	
V2	SUB.L		#0,D2					
	;BMI.S		L2					
L0	MOVE.L		#0,D0
F0	MOVE.L		#0,V0+2
	BRA		V1
L1	MOVE.L		#0,D1
F1	MOVE.L		#0,V1+2
	BRA		V3
L2	MOVE.L		#0,D2
F2	MOVE.L		#0,V2+2
	BRA		V3
L3	MOVE.L		#0,D3
F3	MOVE.L		#0,V3+2
	BRA		OUT
	
BEG	MOVE.L	D0,-(A7)
	MOVE.L	#IMG,D0
	ADD.L	#34,D0
	MOVE.B	D0,$FF8209
	LSR.W	#8,D0
	MOVE.B D0,$FF8207
	MOVE.B	D0,$FF8203
	SWAP	D0
	MOVE.B	D0,$FF8205
	MOVE.B	D0,$FF8201
	MOVE.L	(A7)+,D0

PLAY_MUZ
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEM.L	REGIS,D0-D6/A0-A6
	JSR		AMIGA
	SUBQ.B	#1,SPEED
	BEQ.S	PLAY
	JSR		EFFECT
END_VBL
	MOVEM.L	D0-D6/A0-A6,REGIS
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
BLIT	DC.W 0


PLAY
NO_KEYBOARD1
	MOVEM.L	D0-D1/A0-A5,-(SP)
SPD	MOVE.B	#6,SPEED
	SUBQ.B	#1,POS
	BNE		NO_NEW_PATTERN
	MOVE.B	#64,POS
	ADDQ.L	#1,MUS+2
	SUBQ.B	#1,TRK
	BMI		RESTART
	MOVEQ	#0,D0
MUS	MOVE.B	$0,D0
	SWAP	D0
	LSR.L	#6,D0
	LEA		MUZEXX(PC),A0
	ADD		PAT(PC),A0
	ADD.L	D0,A0
	MOVE.L	A0,ADD_IN_PAT
NO_NEW_PATTERN
	MOVE.L	ADD_IN_PAT(PC),A0
	LEA		FRQ(PC),A1
	LEA		INS(PC),A2
	LEA		COMMAND(PC),A3
	LEA		VOICE0(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE1(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE2(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE3(PC),A4
	BSR		LOAD_VOICE
	MOVE.L	A0,ADD_IN_PAT
	MOVEM.L	(SP)+,D0-D1/A0-A5
	MOVEM.L	D4/A5,-(SP)
	LEA		VOICE0(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT0
	MOVE.L	(A5),D0
	MOVE.L	4(A5),A0
	MOVE.L	8(A5),D4
	MOVE.L	D4,L0+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V0+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F0+2
CONT0
	CLR.B	20(A5)
	LEA		VOICE1(PC),A5
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
	LEA		VOICE2(PC),A5
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
	LEA		VOICE3(PC),A5
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

	BRA		END_VBL

LOAD_VOICE
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE	D0,30(A4)
	MOVE	(A0)+,D0
	BEQ.S	COMMAND?
	BTST	#12,D0
	BEQ.S	CONT_FRQ
	AND		#$FFF,D0
	MOVE	#$100,D1
CONT_FRQ
	MOVE.B	#1,20(A4)
	MOVE	D0,24(A4)
	ADD		D0,D0
	ADD		D0,D0
	MOVE.L	(A1,D0.W),D0
	MOVE.L	D0,12(A4)
	TST.L	16(A4)
	BEQ.S	CONT_LOAD_FRQ
	MOVE.L	D0,16(A4)
CONT_LOAD_FRQ
	OR.B	(A0),D1
	AND		#$FF0,D1
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
	AND		#$F00,D0
	LSR		#6,D0
	MOVE.L	(A3,D0.W),A5
	JMP		(A5)

NO_COMMAND
	RTS

ARPEGGIO
	TST.B	D1
	BEQ.S	NO_ARPEGGIO
	MOVE.B	#0,22(A4)
	MOVE.B	D1,23(A4)
	MOVE.B	#1,21(A4)		
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
	LEA		MUZEXX(PC),A5
	ADD		SEQ(PC),A5
	LEA		-1(A5),A5
	MOVE.B	#1,POS
	MOVE.L	A5,D0
	ADD.L	D1,D0
	MOVE.L	D0,MUS+2
	MOVE.B	-1(A5),D0
	SUB		D1,D0
	MOVE.B	D0,TRK
	RTS

SET_VOLUME
	TST.B	D1
	BNE.S	NO_CHANGE		
	CLR.L	12(A4)			
	MOVE.B	#1,20(A4)		
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

EFFECT
	MOVEM.L	D4-D6/A4-A6,-(SP)
	LEA		FRQ(PC),A5
	LEA		VOICE0(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT1
	BSR		DO_EFFECT
	MOVE.L	26(A6),V0+2
	TST.L	F0+2
	BEQ.S	CONT_EFFECT1
	MOVE.L	26(A6),F0+2
CONT_EFFECT1
	LEA		VOICE1(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT2
	BSR		DO_EFFECT
	MOVE.L	26(A6),V1+2
	TST.L	F1+2
	BEQ.S	CONT_EFFECT2
	MOVE.L	26(A6),F1+2
CONT_EFFECT2
	LEA		VOICE2(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT3
	BSR		DO_EFFECT
	MOVE.L	26(A6),V2+2
	TST.L	F2+2
	BEQ.S	CONT_EFFECT3
	MOVE.L	26(A6),F2+2
CONT_EFFECT3
	LEA		VOICE3(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT4
	BSR		DO_EFFECT
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
	SUB		D4,D5
	CMP		#$71,D5
	BPL.S	OK_PORTUP
	MOVEQ	#$71,D5
OK_PORTUP
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

PORTDOWN
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	ADD		D4,D5
	CMP		#$358,D5
	BMI.S	OK_PORTDOWN
	MOVE	#$358,D5
OK_PORTDOWN
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
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
	ADD		D4,D4
	MOVE	24(A6),D5
	LEA		ARPEGGIO_DATA(PC),A4
ARP_LOOP
	CMP		(A4),D5
	BEQ.S	END_ARP_ROUT1
	LEA		2(A4),A4
	BRA.S	ARP_LOOP
END_ARP_ROUT1
	MOVE	(A4,D4),D6
END_ARP_ROUT2
	ADD		D6,D6
	ADD		D6,D6
	MOVE.L	(A5,D6),26(A6)
	ADDQ.B	#1,21(A6)
	RTS

RESTART
	MOVE	#6,SPD+2 
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA		MUZEXX,A0
	ADD		SEQ,A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF,A0
	LEA		OFF,A1
	LEA		OFF,A2
	LEA		OFF,A3
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
	RTS
END_OF_MUZEXX
	RTS
ANIM1	
	MOVEM.L	A0-A6/D0,-(A7)
	addq.B	#1,WAIT
	cmp.B	#7,WAIT
	bne	SUITE
	move.B	#0,WAIT
	lea HEAD,a0
	add.l POSH,a0
	cmp.b #-1,(a0)
	bne HEADSUIT
	lea HEAD,a0
	move.l #0,POSH
HEADSUIT
	add.l #4,POSH
	move.l (a0),a0
	lea	IMG+34,a1
	add.l	#80*160+11*8,a1
o	set 0
N	set 0
	rept 63
	movem.l N(a0),a2-a6/d0
	movem.l a2-a6/d0,o(a1)
o	set o+160
N	set N+24
	endr
	CMP.W #1,BLIT
	BNE	SUITE
	MOVE.L	#TEXT2,SOURCE
	MOVE.W #$40,LS
	MOVE.W #$7F+2,X
	MOVE.W #$38,Y
	BSR	blit_it
	move.w #2,BLIT
SUITE	MOVEM.L	(A7)+,A0-A6/D0
	RTS
WAIT	DC.W 0
HEAD	;DC.L	LL7,LL7,LL7,LL7,LL7,LL7,LL7,LL7,LL7,LL7,LL7,LL7,LL7
	DC.L	BLOP1,BLOP2,BLOP3
	DC.L	-1
POSH	DC.L	0

ANIM2	
	MOVEM.L	A0-A6/D0-D2,-(A7)
	addq.B	#1,WAIT
	cmp.B	#7,WAIT
	bne	SUITE2
	move.B	#0,WAIT
	lea HEAD2,a0
	add.l POSH2,a0
	cmp.b #-1,(a0)
	bne HEADSUIT2
	lea HEAD2,a0
	move.l #0,POSH2
HEADSUIT2
	add.l #4,POSH2
	move.l (a0),a0
	lea	IMG+34,a1
	add.l	#80*160+9*8,a1
o	set 0
N	set 0
	rept 63
	movem.l N(a0),a2-a6/d0-D2
	movem.l a2-a6/d0-D2,o(a1)
o	set o+160
N	set N+32
	endr
SUITE2	MOVEM.L	(A7)+,A0-A6/D0-D2
	RTS
HEAD2	DC.L	LL1,LL1
	DC.L	LL2,LL3,LL2,LL3,LL2,LL3,LL2,LL3,LL2,LL3,LL2,LL3
	DC.L	LL2,LL3,LL2,LL3,LL2,LL3,LL2,LL3,LL2,LL3,LL2,LL3
	DC.L	LL1,LL1
	DC.L	LL4,LL4,LL5,LL5,LL4,LL4,LL5,LL5,LL4,LL4,LL5,LL5
	DC.L	LL6,LL6,LL6,LL6,LL6,LL6,LL5,LL5
	DC.L	-1
POSH2	DC.L	0

BLITTER        equ       $FF8A00
demiteinte     equ       0         
Src_Xinc       equ       32        
Src_Yinc       equ       34        
Src_Addr       equ       36        
Endmask1       equ       40        
Endmask2       equ       42        
Endmask3       equ       44        
Dst_Xinc       equ       46        
Dst_Yinc       equ       48        
Dst_Addr       equ       50        
largeur        equ       54        
hauteur        equ       56        
HOP            equ       58        
OP             equ       59        
Line_Num       equ       60        
Oblique        equ       61        
fHOP_Source   	equ       1
fHOP_demiteinte  	equ       0
fObliqueFXSR      	equ       7
fObliqueNFSR      	equ       6
fLineBusy      	equ       7
fLineHog       	equ       6
fLineSmudge    	equ       5
mHOP_Source    	equ       $02
mHOP_demiteinte  	equ       $01
mObliqueFXSR      	equ       $80
mObliqueNFSR      	equ       $40
mLineBusy      	equ       $80
mLineHog       	equ       $40
mLineSmudge    	equ       $20
lf_endmask
     dc.w      $FFFF
rt_endmask
     dc.w      $7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF			
     dc.w      $00FF,$007F,$003F,$001F,$000F,$0007,$0003,$0001,0			
blit_it:
	movem.l a0-a6/d0-d7,-(a7)
     lea       BLITTER,a5       
     lea	 PARA,a4
     move.w    WIDTH(a4),d6
     subq.w    #1,d6            
     move.w    SRC_XMIN(a4),d0  
     move.w    d0,d1            
     add.w     d6,d1            
     move.w    DST_XMIN(a4),d2  
     move.w    d2,d3            
     add.w     d6,d3            
     moveq     #$0F,d6          
     move.w    d2,d4            
     and.w     d6,d4            
     add.w     d4,d4            
     move.w    lf_endmask(pc,d4.w),d4
     move.w    d3,d5            
     and.w     d6,d5            
     add.w     d5,d5            
     move.w    rt_endmask(pc,d5.w),d5
     not.w     d5               
     move.w    d2,d7            
     and.w     d6,d7            
     and.w     d0,d6            
     sub.w     d6,d7            
     clr.w     d6               
     addx.w    d6,d6            
     lsr.w     #4,d0            
     lsr.w     #4,d1            
     sub.w     d0,d1            
     lsr.w     #4,d2            
     lsr.w     #4,d3            
     sub.w     d2,d3            
     bne       set_endmasks     
     and.w     d5,d4            
     addq.w    #4,d6            
set_endmasks:
     move.w    d4,Endmask1(a5)  
     move.w    #$FFFF,Endmask2(a5)
     move.w    d5,Endmask3(a5)  
     cmp.w     d1,d3            
     bne       set_count        
     addq.w    #2,d6            
set_count:
     move.w    d3,d4
     addq.w    #1,d4            
     move.w    d4,largeur(a5)   
     move.l    SRC_BASE(a4),a0  
     move.w    SRC_YMIN(a4),d4  
     move.w    SRC_NXLN(a4),d5  
     mulu      d5,d4            
     add.l     d4,a0            
     move.w    SRC_NXWD(a4),d4  
     move.w    d4,Src_Xinc(a5)  
     mulu      d4,d0            
     add.l     d0,a0            
     mulu      d4,d1            
     sub.w     d1,d5            
     move.w    d5,Src_Yinc(a5)  
     move.l    DST_BASE(a4),a1  
     move.w    DST_YMIN(a4),d4  
     move.w    DST_NXLN(a4),d5  
     mulu      d5,d4            
     add.l     d4,a1            
     move.w    DST_NXWD(a4),d4  
     move.w    d4,Dst_Xinc(a5)  
     mulu      d4,d2            
     add.l     d2,a1            
     mulu      d4,d3            
     sub.w     d3,d5            
     move.w    d5,Dst_Yinc(a5)  
     and.b     #$0F,d7          	       
     or.b      Oblique_flags(pc,d6.w),d7  
     move.b    d7,Oblique(a5)      	
     move.b    #mHOP_Source,HOP(a5)	
     move.b	 FONC,d6
     move.b    d6,OP(a5)        		
     lea       Line_Num(a5),a2  		
     move.b    #6,d2    		
     move.w    PLANES(a4),d7    		
     bra       begin
Oblique_flags:
     dc.b      mObliqueNFSR        
     dc.b      mObliqueFXSR        
     dc.b      0                   
     dc.b      mObliqueNFSR+mObliqueFXSR 
     dc.b      0                
     dc.b      mObliqueFXSR     
     dc.b      0                
     dc.b      0                
next_plane:
     move.l    a0,Src_Addr(a5)  		
     move.l    a1,Dst_Addr(a5)  		
     move.w    HEIGHT(a4),hauteur(a5)	
     move.b    #mLineBusy,(a2)  		
     add.w     SRC_NXPL(a4),a0  		
     add.w     DST_NXPL(a4),a1  		
restart:
     bset.b    d2,(a2)          
     nop                        
     bne       restart          
begin:
     dbra      d7,next_plane    
	movem.l (a7)+,a0-a6/d0-d7
     rts
SRC_BASE       equ       0
SRC_NXWD       equ       4
SRC_NXLN       equ       6
SRC_NXPL       equ       8
SRC_XMIN       equ      10
SRC_YMIN       equ      12
DST_BASE       equ      14
DST_NXWD       equ      18
DST_NXLN       equ      20
DST_NXPL       equ      22
DST_XMIN       equ      24
DST_YMIN       equ      26
WIDTH          equ      28
HEIGHT         equ      30
PLANES         equ      32
PARA	
SOURCE	dc.l	TEXT2
	dc.w	8
LS	dc.w   $40
	dc.w   2
XS	dc.w  	0
YS	dc.w	0

DEST	dc.l	IMG+34
	dc.w	8
LD	dc.w	160
	dc.w	2
XD	dc.w	86
YD	dc.w	6

X	dc.w	$7f+2
Y	dc.w	$38
PLAN	dc.w	4
FONC	dc.b	3
	even
OFF			DC.L	0
SPEED			DC.B	0
POS			DC.B	0
TRK			DC.B	0
SEQ			DS.W	1
PAT			DS.W	1
NBR_INS		DS.W	1
FRQ			incbin '12_5KHZ.FRQ',0
ARPEGGIO_DATA	DC.W	$0358,$0328,$02FA,$02D0,$02A6,$0280,$025C
				DC.W	$023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D
				DC.W	$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0
				DC.W	$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097
				DC.W	$008F,$0087,$007F,$0078,$0071,$0000,$0000,$0000

VOICE0			DS.L	8
VOICE1			DS.L	8
VOICE2			DS.L	8
VOICE3			DS.L	8
ADD_IN_PAT		DS.L	1
REGIS			DS.L	14
MU			DS.W	5040
MUS_END		DS.L	0
MUSI			DS.L	0
INS			DS.L	32*4
MUZEXX	INCBIN	LOAD.MUS
	EVEN
PALETTE	DC.W $0,$205,$315,$426,$547,$777,$766
		DC.W $643,$531,$421,$020,$040,$666,$555,$333,$557
IMG	INCBIN	LOADER.PI1
LL1	INCBIN	L1
LL2	INCBIN	L2
LL3	INCBIN	L3
LL4	INCBIN	L4
LL5	INCBIN	L5
LL6	INCBIN	L6
LL7	INCBIN	L7
TEXT1	INCBIN	TEXT1.Z
TEXT2	INCBIN	TEXT2.Z
BLOP1	INCBIN	BLOP1.Z
BLOP2	INCBIN	BLOP2.Z
BLOP3	INCBIN	BLOP3.Z
	     * DC.W DEBUT,LONGEUR,FACE
DATAFILE	DC.W 0,0,5		* MAIN MENU
		DC.W 416,659-416+1,5	* SCREEN 1
		DC.W 210,415-210+1,5	* SCREEN 2
		DC.W 0,0,5		* SCREEN 3
		DC.W 0,0,5		* SCREEN 4
		DC.W 0,0,5		* SCREEN 5
		DC.W 0,0,5		* SCREEN 6
	DS.B 500
STACK