	MOVE.W #6,-(A7)	* 6 SECTEURS
	MOVE.W #1,-(A7)	* FACE 1
	MOVE.W #0,-(A7)	* PISTE 0
   	MOVE.W #2,-(A7)	* SECTEUR 2
	MOVE.W #0,-(A7) 	* UNITE A
	CLR.L -(A7)
	MOVE.L	#ICI,-(A7)
	MOVE.W #9,-(A7)
	TRAP #14
	ADD.L #20,A7

	CLR.W -(A7)
	TRAP #1

ICI	LEA	TAMPON(PC),A0
	MOVE.L	A0,-(A7)
	MOVE.W #0,-(A7)
	TRAP #13
	ADDQ.L #6,A7
	LEA	TAMPON(PC),A0
	MOVE.L (A0),A0
	CMP.L	#$80000,8(A0)
	BGT	MEGA
M520	MOVE.W	#$520,$AA9A
	BRA	LOADBOOTSCREEN
MEGA	MOVE.W	#$1040,$AA9A
LOADBOOTSCREEN
	MOVE.W	#0,$AA9C
	MOVE.W	#0,$AA9E
	MOVE.W	#0,$AAA0
	MOVE.W	#0,$AAA2
	LEA	$AAA4,A0
	LEA	DATAFILE(PC),A1
	MOVE.W #9*6,D0
COPY	MOVE.B (A1)+,(A0)+
	DBF	D0,COPY
	lea	$ff8240,a0
	MOVE.W	#0,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	MOVE.W	#$407,(a0)+
	PEA	TXT(pc)
	MOVE.W	#9,-(A7)
	TRAP #1
	ADDQ.L	#6,A7

RECOM	MOVE.L	START(PC),A0
	MOVE.L	DEBUT(PC),D0
	MOVE.L	LONG(PC),D1
	MOVE.L	FACE(PC),D3
	BSR	LOAD
	TST.W	D4
	BNE	RECOM
	PEA	TXT2(pc)
	MOVE.W	#9,-(A7)
	TRAP #1
	ADDQ.L	#6,A7
	BSR	DECRUNCH
	BSR	RELOK
	JMP	$25000

START	DC.L $25000
LOADING DC.L $25000
DEBUT	DC.L 11
LONG	DC.L 298-11+1
FACE	DC.L 1		* =A			

	     * DC.W DEBUT,LONGEUR,FACE
DATAFILE	
		DC.W 505,715-505+1,1	* MAIN MENU
		DC.W 11,298-11+1,1	* MCS8 (INTRO)
		DC.W 449,600-449+1,0	* BOB DEMO
		DC.W 601,803-601+1,0	* GREET DEMO
		DC.W 11,209+11+1,0	* BEAST FOOD
		DC.W 211,447-211+1,0	* FIND THE BEAST
		DC.W 463,503-463+1,1	* MUSIC 520
		DC.W 397,462-397+1,1	* MUSIC 1040
		DC.W 299,395-299+1,1	* LOAD1 (LOADER)
RELOK
       move.l   START(pc),a6
       move.l   START(pc),a5
       movea.l  2(a6),a0    * longueur du code
       adda.l   6(a6),a0    * + longueur des data
       move.l   a6,d1            * adresse de base de la relocation
       move.l   a6,d2   * adresse de debut du prog
	add.l	#28,d2        
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
       move.l   2(a5),$C(a6)    * long du texte
       move.l   6(a5),$14(a6)   * long des data
       move.l   10(a5),$1C(a6)  * long des BSS
       move.l   $8(a6),$10(a6)
       move.l   $C(a6),d0
       add.l    d0,$10(a6)         * adresse des DATA
       move.l   $10(a6),$18(a6)
       move.l   $14(a6),d0
       add.l    d0,$18(a6)         * adresse des BSS       
       
       move.l #$25000+28,A0
       movea.l a0,a1
       adda.l  #290000,a1
       movea.l START(pc),a2
rel1   move.l  (a0)+,(a2)+
       cmpa.l  a0,a1
       bge     rel1
	MOVE.L	$AA9A,$24
	rts       


DECRUNCH	movem.l d0-a6,-(sp)		
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
		MOVE.L	$AA9A,$24
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
		bsr	ice2_13
		move.b #$e,$ff8800
		bchg.b #2,$ff8802
		bchg.b #1,$ff8802
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
	MOVE.L	$AA9A,$24
      TST.W   D4
      RTS 
L0003:MOVEQ   #-1,D4
      RTS 
L0004:LEA	L3B12(PC),A3
	MOVE.W  #2,(A3)
	LEA	L3B10(PC),A3
      TST.W   (A3) 
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
	LEA	L3B12(PC),A3
      SUBQ.W  #1,(A3)
      BEQ.S   L0005 
      BCC.S   L0007 
L000A:RTS 
L000B:MOVE.W  #$90,(A6) 
      MOVE.W  (A6),D4 
      NOT.W   D4
      ANDI.W  #1,D4 
      BNE.S   L000C 
	LEA	L3B08(PC),A3
      ADDI.L  #$200,(A3)
      TST.W   D4
L000C:RTS 
L000D:MOVEQ   #$A,D7
L000E:DBF     D7,L000E
      RTS 

L001C:LEA     -$79FA.W,A6 
      LEA     -$79FC.W,A5 
      BSR.S   L001D 
	LEA	L3B08(PC),A3
      MOVE.L  A0,(A3)
      RTS 
L001D:MOVE.W  L0032(PC),D6
      ADDQ.B  #1,D6 
      LSL.B   #1,D6 
      OR.W    L3B0E(PC),D6
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
L0027:
	LEA	L3B10(PC),A3
	MOVE.W  D0,(A3)
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
	LEA	L3B10(PC),A3
      CLR.W   (A3)
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
TXT	DC.B $1B,"E",$D,$A,$D,$A,$D,$A,$D,$A,$D,$A,$D,$A,$D,$A
	DC.B "              Don't worry",$d,$a
	dc.b "              I'm Loading",$d,$a,$d,$a
	dc.b "          The Delirious  2.75",0
	even
TXT2	DC.B $1B,"E",$D,$A,$D,$A,$D,$A,$D,$A,$D,$A,$D,$A,$D,$A
	DC.B "              Don't worry",$d,$a
	dc.b "              I'm Loading",$d,$a,$d,$a
	dc.b "    Or perhaps is it the Delirious 3",$d,$a
	dc.b "         but  I don't remember",0
	even
TAMPON	DS.L 5
