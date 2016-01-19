*************************************
*GOR INTRO... RIPPED BY ALCHEMY 1992*
*                                   *
* (BUT MENTOR GOT IT WORKING ...)   *
*************************************

;	opt	d+

      MOVEA.L   4(A7),A5
      MOVE.L    #$200,-(A7) 
      MOVE.L    A5,-(A7)
      PEA       $4A0000 
      TRAP      #1
      ADDA.L    #$C,A7

      CLR.L     -(A7) 		; into supervisor
      MOVE.W    #$20,-(A7)
      TRAP      #1
      ADDQ.L    #6,A7 
      MOVE.L    D0,old_sp

      MOVEA.L   $42E.L,A0	;
      LEA       -8(A0),A7 
      BSR       L0002 

      MOVE.L    old_sp,-(A7) 
      MOVE.W    #$20,-(A7)
      TRAP      #1
      ADDQ.L    #6,A7 

      PEA		null
      PEA		null
      MOVE.L	filename,-(SP)
      MOVE.W	#0,-(A7)
      MOVE.W	#$4B,-(A7)
      TRAP	#1
      ADDA.L	#$12,A7 

      MOVE.W    #$4C,-(A7) 	; quit menu (from wherever)
      TRAP      #1

null	dc.l	1
	even

filename	dc.l	1
	even

file1	dc.b	'',0
	even
file2	dc.b	'20second.src',0
	even
file3	dc.b	'm_vision.src',0
	even
file4	dc.b	'',0
	even
;file5	dc.b	'',0
;	even
;file6	dc.b	'',0
;	even

L0002:MOVE.L    $44E.L,old_scr
      MOVE.B    $FFFF8260.W,old_rez
      MOVE.B    $FFFF820A.W,old_scan
      MOVE.W    #$777,$FFFF8240.W
      MOVEM.L   $FFFF8240.W,D0-D7
      MOVEM.L   D0-D7,old_pal 
      LEA       $80000,A0 
      MOVE.L    (A0),D0 
      MOVE.L    #$4655434B,(A0) 
      CMPI.L    #$4655434B,(A0) 
      BNE.S     L0003 
      MOVE.L    #$F8000,L0041 
      MOVE.L    #$F0000,L0042 
      MOVE.L    #$F8000,L0043 
      MOVE.L    D0,(A0) 
L0003:SUBI.L    #$2800,L0043

      LEA       MUS_DATA,A6
      JSR       MUSIX
      MOVE.L    A6,MUS_VBL

      BSR       L001D 
      MOVEQ     #$12,D1 
      BSR       L001F 
      MOVE.L    L0043,D7
      BSR       L0022 
      MOVE.B    #0,$FFFF8260.W 	; Low rez
      MOVEA.L   L0043,A0
      BSR       L0026 
      MOVE.L    #font,D0 
      MOVEQ     #0,D1 
      LEA       L004A,A0
      MOVE.W    #3,D6 
L0004:MOVE.L    D0,D1 
      MOVE.W    #$27,D7 
L0005:MOVE.L    D1,(A0)+
      ADDQ.L    #1,D1 
      DBF       D7,L0005
      ADDI.L    #$140,D0
      DBF       D6,L0004
      CLR.W     L0048 
      MOVE.W    #$C8,L0049
      LEA       L0051,A6
      BSR       L0017 
      CLR.W     L0048 
      MOVE.W    #4,L0049
      BRA       L0008 

L0006:BSR       L0024 
      LEA       L0050,A0
      MOVEQ     #0,D0 
      MOVE.W    #$63,D7 
L0007:MOVEA.L   (A0)+,A1
      MOVE.L    D0,(A1) 
      DBF       D7,L0007
L0008:LEA       L004F,A0
      LEA       L0050,A1
      MOVE.W    #$63,D7 
L0009:MOVEQ     #1,D5 
      ADD.W     (A0),D5 
      MOVE.W    2(A0),D0
      ADD.W     (A0),D0 
      ADDQ.W    #1,D0 
      CMP.W     #$13F,D0
      BLT.S     L000A 
      SUBI.W    #$13F,D0
      SUBI.W    #$13F,2(A0) 
L000A:MOVE.W    D0,2(A0)
      MOVE.W    4(A0),D1
      ADDQ.W    #4,D1 
      BSR       L0014 
      ADDQ.L    #6,A0 
      MOVE.L    A6,(A1)+
      DBF       D7,L0009
      ADDQ.W    #1,L0058
      CMPI.W    #2,L0058
      BLT.S     L000D 
      CLR.W     L0058 
      EORI.W    #1,L0057
      BNE.S     L000C 
      MOVEA.L   L0054,A0
      MOVEQ     #0,D0 
      MOVE.B    (A0)+,D0
      TST.B     D0
      BNE.S     L000B 
      LEA       L0053,A0
      MOVE.B    (A0)+,D0
L000B:MOVE.L    A0,L0054
      MOVE.B    D0,L0052
      LEA       L0052,A6
      BSR       L0017 
      BRA       L000D 
L000C:MOVEA.L   L0056,A0
      MOVEQ     #0,D0 
      MOVE.B    D0,(A0) 
      MOVE.B    D0,160(A0)
      MOVE.B    D0,320(A0)
      MOVE.B    D0,480(A0)
      MOVE.B    D0,640(A0)
      MOVE.B    D0,800(A0)
      MOVE.B    D0,960(A0)
      MOVE.B    D0,1120(A0) 
L000D:LEA       L005D,A5
      MOVEA.L   L0043,A6
      ADDA.L    #$6D64,A6 
      MOVEQ     #7,D7 
L000E:MOVE.W    (A5),(A6) 
      MOVE.W    8(A5),8(A6) 
      MOVE.W    16(A5),16(A6) 
      MOVE.W    24(A5),24(A6) 
      MOVE.W    32(A5),32(A6) 
      MOVE.W    40(A5),40(A6) 
      MOVE.W    48(A5),48(A6) 
      MOVE.W    56(A5),56(A6) 
      MOVE.W    64(A5),64(A6) 
      MOVE.W    72(A5),72(A6) 
      MOVE.W    80(A5),80(A6) 
      MOVE.W    88(A5),88(A6) 
      MOVE.W    96(A5),96(A6) 
      MOVE.W    104(A5),104(A6) 
      MOVE.W    112(A5),112(A6) 
      MOVE.W    120(A5),120(A6) 
      MOVE.W    128(A5),128(A6) 
      MOVE.W    136(A5),136(A6) 
      MOVE.W    144(A5),144(A6) 
      MOVE.W    152(A5),152(A6) 
      LEA       168(A5),A5
      LEA       160(A6),A6
      DBF       D7,L000E
      ADDQ.W    #2,L005C
      CMPI.W    #8,L005C
      BLT.S     L0010 
      CLR.W     L005C 
      LEA       L005E,A6
      MOVEA.L   scrollp,A5
      MOVEQ     #0,D7 
      MOVE.B    (A5)+,D7
      TST.B     D7
      BPL.S     L000F 
      LEA       scrolly,A5
      MOVE.B    (A5)+,D7
L000F:MOVE.L    A5,scrollp
      SUBI.B    #$20,D7 
      LEA       L004A,A5
      LSL.W     #2,D7 
      MOVEA.L   0(A5,D7.W),A5 
      MOVE.B    (A5),(A6) 
      MOVE.B    40(A5),168(A6)
      MOVE.B    80(A5),336(A6)
      MOVE.B    120(A5),504(A6) 
      MOVE.B    160(A5),672(A6) 
      MOVE.B    200(A5),840(A6) 
      MOVE.B    240(A5),1008(A6)
      MOVE.B    280(A5),1176(A6)
L0010:BSR       L0012 
      BSR       L0012 
      MOVE.L    MUS_VBL,a6
      JSR       (A6)


try_f1	CMPI.B	#$3B,$FFFFFC02.W	; F1
	BNE.S	try_f2
	move.l	#file1,filename
	bra	exit

try_f2	CMPI.B	#$3C,$FFFFFC02.W	; F2
	BNE.S	try_f3
	move.l	#file2,filename
	bra	exit

try_f3	CMPI.B	#$3D,$FFFFFC02.W	; F3
	BNE.S	try_f4
	move.l	#file3,filename
	bra	exit

try_f4	CMPI.B	#$3E,$FFFFFC02.W	; F4
	BNE	L0006
	move.l	#file4,filename
;	bra	exit

;try_f5	CMPI.B	#$3F,$FFFFFC02.W	; F5
;	BNE.S	try_f6
;	move.l	#file5,filename
;	bra.s	exit
;
;try_f6	CMPI.B	#$40,$FFFFFC02.W	; F6
;	BNE	L0006
;	move.l	#file6,filename
;	bra.s	exit
;
;try_f7	CMPI.B	#$41,$FFFFFC02.W	; F7
;	BNE	L0006
;	move.l	#file7,filename

;	bra.s	exit

;try_sp	CMPI.B    #$39,$FFFFFC02.W	; space bar exits
;	BNE       L0006 

exit	MOVE.L    old_scr,D7
	BSR       L0022 
	MOVE.B    old_rez,$FFFF8260.W
	MOVEQ     #8,D1 
	BSR       L001F 
	BSR       L001E 

	LEA       $FFFF8800.W,A0	; kill soundchip
	MOVE.L    #$8080000,(A0)
	MOVE.L    #$9090000,(A0)
	MOVE.L    #$A0A0000,(A0)

      MOVE.W    #-1,$4EE.L
      MOVEM.L   old_pal,D0-D7 
      MOVEM.L   D0-D7,$FFFF8240.W	; reset palette
      MOVE.B    old_scan,$FFFF820A.W	; reset hertz

      MOVEA.L   old_scr,A0	; clear screen
      MOVE.W    #$1F3F,D7 
L0011:CLR.L     (A0)+ 
      DBF       D7,L0011
      RTS 

L0012:LEA       L005D,A5
      MOVEQ     #7,D7 
L0013:ROXL      160(A5) 
      ROXL      152(A5) 
      ROXL      144(A5) 
      ROXL      136(A5) 
      ROXL      128(A5) 
      ROXL      120(A5) 
      ROXL      112(A5) 
      ROXL      104(A5) 
      ROXL      96(A5)
      ROXL      88(A5)
      ROXL      80(A5)
      ROXL      72(A5)
      ROXL      64(A5)
      ROXL      56(A5)
      ROXL      48(A5)
      ROXL      40(A5)
      ROXL      32(A5)
      ROXL      24(A5)
      ROXL      16(A5)
      ROXL      8(A5) 
      ROXL      (A5)
      LEA       168(A5),A5
      DBF       D7,L0013
      RTS 
L0014:MULU      #$A0,D1 
      MOVE.W    D0,D2 
      ANDI.L    #-$10,D0
      LSR.W     #1,D0 
      ADD.L     D0,D1 
      ANDI.L    #$F,D2
      MOVE.W    #-$8000,D3
      LSR.W     D2,D3 
      MOVEA.L   L0043,A6
      ADDA.L    D1,A6 
      BTST      #0,D5 
      BEQ.S     L0015 
      OR.W      D3,(A6) 
L0015:BTST      #1,D5 
      BEQ.S     L0016 
      OR.W      D3,2(A6)
L0016:RTS 
L0017:MOVE.W    L0048,D0
      MOVE.W    L0049,D1
      MOVEQ     #0,D2 
      MOVE.B    (A6)+,D2
      ANDI.B    #$7F,D2 
      TST.B     D2
      BEQ.S     L001A 
      CMP.B     #$A,D2
      BNE       L0018 
      CLR.W     L0048 
      ADDI.W    #9,L0049
      BRA.S     L0019 
L0018:SUBI.B    #$20,D2 
      BSR       L001B 
      ADDQ.W    #8,L0048
L0019:TST.B     (A6)
      BNE       L0017 
L001A:RTS 
L001B:LEA       L004A,A1
      ANDI.L    #$FFF8,D0 
      MULU      #$140,D1
      ADD.L     D0,D1 
      LSR.L     #1,D1 
      ANDI.L    #$FFF8,D1 
      BTST      #3,D0 
      BEQ       L001C 
      ADDQ.W    #1,D1 
L001C:ADD.L     L0043,D1
      MOVEA.L   D1,A0 
      LSL.W     #2,D2 
      MOVEA.L   0(A1,D2.W),A1 
      ADDQ.L    #4,A0 
      MOVE.B    (A1),(A0) 
      MOVE.B    40(A1),160(A0)
      MOVE.B    80(A1),320(A0)
      MOVE.B    120(A1),480(A0) 
      MOVE.B    160(A1),640(A0) 
      MOVE.B    200(A1),800(A0) 
      MOVE.B    240(A1),960(A0) 
      MOVE.B    280(A1),1120(A0)
      ADDQ.L    #2,A0 
      MOVE.B    (A1),(A0) 
      MOVE.B    40(A1),160(A0)
      MOVE.B    80(A1),320(A0)
      MOVE.B    120(A1),480(A0) 
      MOVE.B    160(A1),640(A0) 
      MOVE.B    200(A1),800(A0) 
      MOVE.B    240(A1),960(A0) 
      MOVE.B    280(A1),1120(A0)
      MOVE.L    A0,L0056
      RTS 
L001D:MOVE      #$2700,SR 
      MOVE.B    $FFFA09.L,old_a09 
      MOVE.B    $FFFA07.L,old_a07 
      MOVE.B    $FFFA13.L,old_a13 
      CLR.B     $FFFA07.L 
      CLR.B     $FFFA09.L 
      MOVE.L    $120.L,old_120
      MOVE.L    $70.L,old_70 
      MOVE.L    #new_120,$120.L 
      MOVE.L    #new_70,$70.L
      BSET      #0,$FFFA07.L
      BSET      #0,$FFFA13.L
      MOVE      #$2300,SR 
      RTS 

L001E:MOVE      #$2700,SR 
      MOVE.B    old_a09,$FFFA09.L 
      MOVE.B    old_a07,$FFFA07.L 
      MOVE.B    old_a13,$FFFA13.L 
      MOVE.L    old_120,$120.L
      MOVE.L    old_70,$70.L 
      MOVE      #$2300,SR 
      RTS 

L001F:LEA       $FFFFFC00,A0
L0020:MOVE.B    (A0),D2 
      BTST      #1,D2 
      BEQ       L0020 
      MOVE.B    D1,2(A0)
      RTS 
      EORI.W    #1,L0044
      BNE       L0021 
      MOVE.L    L0042,D7
      MOVE.L    L0041,L0043 
      BRA       L0022 
L0021:MOVE.L    L0041,D7
      MOVE.L    L0042,L0043 
L0022:LSR.L     #8,D7 
      MOVE.B    D7,-$7DFD.W 
      LSR.L     #8,D7 
      MOVE.B    D7,-$7DFF.W 
      MOVE.W    L0038,D0
L0023:CMP.W     L0038,D0
      BEQ       L0023 
      RTS 
L0024:MOVE.W    L0039,D0
L0025:CMP.W     L0039,D0
      BEQ       L0025 
      RTS 
L0026:MOVE.W    #$293F,D0 
      MOVEQ     #0,D7 
L0027:MOVE.L    D7,(A0)+
      DBF       D0,L0027
      RTS 
L0028:CLR.B     $FFFA1B.L 
      MOVEM.L   A0-A6/D0-D7,-(A7) 
      MOVE      SR,-(A7)
      MOVE      #$2700,SR 
      LEA       L004E,A3
      ADDA.W    L004C,A3
      LEA       $FFFF8240.L,A4
      LEA       $FF8209.L,A5
      LEA       L002A,A6
      MOVEQ     #0,D0 
L0029:TST.B     (A5)
      BEQ.S     L0029 
      MOVE.B    (A5),D0 
      ADDA.L    D0,A6 
      JMP       (A6)
L002A REPT	172
      NOP 
      ENDR
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    (A3)+,(A4)
      MOVE.W    #0,(A4) 
      MOVE      (A7)+,SR
      MOVEM.L   (A7)+,A0-A6/D0-D7 
      CLR.B     $FFFA1B.L 
      MOVE.L    #L002B,$120.L 
      MOVE.B    #1,$FFFA21.L
      MOVE.B    #8,$FFFA1B.L
      BCLR      #0,$FFFA0F.L
      RTE 
L002B:CLR.B     $FFFA1B.L 
      MOVE.L    A0,-(A7)
      MOVEA.L   L005A,A0
      MOVE.L    (A0),$FFFF8248.W 
      MOVE.L    (A0)+,$FFFF824C.W
      MOVE.L    A0,L005A
      MOVEA.L   (A7)+,A0
      ADDQ.W    #1,L0059
      CMPI.W    #$BF,L0059
      BLT.S     L002C 
      MOVE.L    #L002D,$120.L 
L002C:BCLR      #0,$FFFA0F.L
      MOVE.B    #8,$FFFA1B.L
      RTE 
L002D:CLR.B     $FFFA1B.L 
      MOVEM.L   A0-A6/D0-D7,-(A7) 
      MOVE      SR,-(A7)
      MOVE      #$2700,SR 
      LEA       L004E,A3
      ADDA.W    L004D,A3
      LEA       $FFFF8240.L,A4
      LEA       $FF8209.L,A5
      LEA       L002F,A6
      MOVEQ     #0,D0 
L002E:TST.B     (A5)
      BEQ.S     L002E 
      MOVE.B    (A5),D0 
      ADDA.L    D0,A6 
      JMP       (A6)
L002F
      REPT	214
      NOP 
      ENDR
      REPT	42
      MOVE.W	(A3)+,(A4)
      ENDR
      MOVE.W    #0,(A4) 
      ADDQ.W    #1,L0039
      MOVE      (A7)+,SR
      MOVEM.L   (A7)+,A0-A6/D0-D7 
      BCLR      #0,$FFFA0F.L
      MOVE.L    #L0030,$120.L 
      MOVE.B    #1,$FFFA21.L
      MOVE.B    #8,$FFFA1B.L
      RTE 
L0030:CLR.B     $FFFA1B.L 
      MOVEM.L   A0/D0,-(A7) 
      LEA       $FFFA21.L,A0
      MOVE.B    #-$38,(A0)
      MOVE.B    #8,$FFFA1B.L
      MOVE.B    (A0),D0 
L0031:CMP.B     (A0),D0 
      BEQ       L0031 
      CLR.B     $FFFF820A.W
      MOVEQ     #3,D0 
L0032:NOP 
      DBF       D0,L0032
      MOVE.B    #2,$FFFF820A.W 
      MOVEM.L   (A7)+,A0/D0 
      BCLR      #0,$FFFA0F.L
      MOVE.B    #0,$FFFA1B.L
      MOVE.L    #L0033,$120.L 
      MOVE.B    #$A,$FFFA21.L 
      MOVE.B    #8,$FFFA1B.L
      RTE 
L0033:CLR.B     $FFFA1B.L 
      MOVE.L    A0,-(A7)
      MOVEA.L   L0061,A0
      MOVE.W    (A0)+,$FFFF8240.W
      MOVE.L    A0,L0061
      MOVEA.L   (A7)+,A0
      BCLR      #0,$FFFA0F.L
      MOVE.B    #1,$FFFA21.L
      MOVE.B    #8,$FFFA1B.L
      RTE 

new_120	CLR.B     $FFFA1B.L 
	MOVE.W    #7,$FFFF8240.W 
	BCLR      #0,$FFFA0F.L
	RTE 

new_70	ADDQ.W    #1,L0038
      MOVEM.L   A0-A6/D0-D7,-(A7) 
      CLR.B     $FFFA1B.L 
      MOVE.B    #1,$FFFA21.L
      MOVE.L    #L0028,$120.L 
      MOVE.B    #8,$FFFA1B.L
      CLR.W     L0059 
      MOVE.L    #L005B,L005A
      MOVE.L    #PAL_TAB,L0061
      ADDI.W    #2,L004C
      CMPI.W    #$190,L004C 
      BLT.S     L0036 
      CLR.W     L004C 
L0036:SUBI.W    #2,L004D
      TST.W     L004D 
      BPL.S     L0037 
      MOVE.W    #$18E,L004D 
L0037:MOVE.L    #$333,$FFFF8240.W
      MOVE.L    #$5550777,$FFFF8244.W
      LEA       $FFFF8250.W,A0 
      MOVE.L    #$7770777,D0
      MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      MOVEM.L   (A7)+,A0-A6/D0-D7 
      RTE 


	section	data

L0038	DC.W	0
L0039	DC.W	0
old_70	DS.L	1
old_120	DS.L	3 
old_a09	DC.B      0 
old_a07	DC.B      0 
old_a13	DC.B      0 
old_rez	DC.B	0 
old_sp	DS.L	1
L0041	DC.B      $00,$07,$80,$00
L0042	DC.B      $00,$07,$00,$00
L0043	DC.B      $00,$07,$80,$00
L0044	DC.W      0
old_scr	DS.L	1
old_pal	DS.W	32
old_scan	DS.W      3 
L0048	DC.W	0
L0049	DC.W	0
L004A	DS.W      320

font	incbin	'broadway.fnt'
	even

; Font Options:-
;
; BROADWAY	DATA	DESCEND	KEFREN
; LUSH		MOUSE	STONEY	TAIL

L004C	DC.W      $0000
L004D	DC.W      $00F0 
L004E	DS.W      64
	DC.B      $01,$01,$02,$02,$03,$03,$04,$04 
	DC.B      $05,$05,$06,$06,$07,$07,$07,$06 
	DC.B      $07,$05,$07,$04,$07,$03,$07,$02 
	DC.B      $07,$01,$07,$00,$07,$10,$07,' ' 
	DC.B      $07,'0',$07,'@',$07,'P',$07,'`' 
	DC.B      $07,'p',$07,'q',$07,'r',$07,'s' 
	DC.B      $07,'t',$07,'u',$07,'v',$07,'w' 
	DC.B      $07,'v',$07,'u',$07,'t',$07,'s' 
	DC.B      $07,'r',$07,'q',$07,'p',$07,'`' 
	DC.B      $07,'P',$07,'@',$07,'0',$07,' ' 
	DC.B      $07,$10,$07,$00,$07,$01,$07,$02 
	DC.B      $07,$03,$07,$04,$07,$05,$07,$06 
	DC.B      $07,$07,$06,$06,$05,$05,$04,$04 
	DC.B      $03,$03,$02,$02,$01,$01,$00,$00 
	DS.W      127 

L004F	DC.B      $00,$01,$00,$D8,$00,')',$00,$02 
	DC.B      $00,'9',$00,'b',$00,$01,$00,$9F 
	DC.B      $00,$06,$00,$00,$00,'~',$00,'$' 
	DC.B      $00,$00,$00,'N',$00,$B2,$00,$01 
	DC.B      $00,$FC,$00,'@',$00,$02,$00,$99 
	DC.B      $00,$B5,$00,$00,$00,$BD,$00,'\' 
	DC.B      $00,$02,$00,'`',$00,$8E,$00,$00 
	DC.B      $00,$FC,$00,'&',$00,$01,$00,'h' 
	DC.B      $00,'P',$00,$00,$00,$19,$00,$11 
	DC.B      $00,$02,$00,'G',$00,'J',$00,$02 
	DC.B      $00,'N',$00,$0D,$00,$02,$00,$B8 
	DC.B      $00,'F',$00,$00,$00,$C3,$00,'h' 
	DC.B      $00,$02,$00,$E8,$00,'(',$00,$00 
	DC.B      $00,$99,$00,';',$00,$00,$00,$E6 
	DC.B      $00,'/',$00,$00,$00,'m',$00,$12 
	DC.B      $00,$01,$01,'1',$00,$AE,$00,$00 
	DC.B      $00,':',$00,$AF,$00,$02,$00,$C9 
	DC.B      $00,$BE,$00,$01,$00,'h',$00,$8C 
	DC.B      $00,$02,$00,'3',$00,'Y',$00,$00 
	DC.B      $00,$EA,$00,$BB,$00,$02,$01,$27 
	DC.B      $00,'U',$00,$00,$00,$D6,$00,$9B 
	DC.B      $00,$01,$00,$09,$00,$82,$00,$02 
	DC.B      $01,'+',$00,'p',$00,$02,$00,$C9 
	DC.B      $00,$8F,$00,$00,$00,$98,$00,$00 
	DC.B      $00,$00,$00,$90,$00,'r',$00,$02 
	DC.B      $00,$00,$00,'I',$00,$02,$00,$8E 
	DC.B      $00,$96,$00,$01,$00,'I',$00,$08 
	DC.B      $00,$02,$00,'}',$00,$A6,$00,$02 
	DC.B      $00,$8D,$00,'`',$00,$01,$00,$8F 
      DC.B      $00,'j',$00,$00,$00,'G',$00,'U' 
      DC.B      $00,$02,$00,'"',$00,$96,$00,$01 
      DC.B      $00,'U',$00,'[',$00,$02,$00,$0B 
      DC.B      $00,'(',$00,$01,$00,'S',$00,$1F 
      DC.B      $00,$00,$01,$0D,$00,'d',$00,$00 
      DC.B      $00,$C9,$00,'_',$00,$02,$00,$A7 
      DC.B      $00,$BF,$00,$01,$00,$CD,$00,$AA 
      DC.B      $00,$01,$00,$FE,$00,$A0,$00,$02 
      DC.B      $00,$F8,$00,$0C,$00,$02,$00,$B7 
      DC.B      $00,'J',$00,$00,$00,'@',$00,'S' 
      DC.B      $00,$00,$01,'9',$00,',',$00,$02 
      DC.B      $00,$02,$00,$A5,$00,$01,$00,$98 
      DC.B      $00,'#',$00,$01,$01,')',$00,'O' 
      DC.B      $00,$01,$00,'M',$00,'M',$00,$02 
      DC.B      $01,'3',$00,'Q',$00,$02,$01,'"' 
      DC.B      $00,'C',$00,$00,$00,$8B,$00,'(' 
      DC.B      $00,$01,$00,$BD,$00,'P',$00,$02 
      DC.B      $00,$8A,$00,$B5,$00,$01,$00,$D9 
      DC.B      $00,$98,$00,$00,$00,'R',$00,$9E 
      DC.B      $00,$01,$00,$BE,$00,$AE,$00,$02 
      DC.B      $00,$B1,$00,'8',$00,$01,$00,$CD 
      DC.B      $00,'U',$00,$00,$00,$FD,$00,'"' 
      DC.B      $00,$02,$00,$98,$00,'C',$00,$01 
      DC.B      $00,$10,$00,$0F,$00,$01,$00,$EA 
      DC.B      $00,'>',$00,$01,$00,'r',$00,$05 
      DC.B      $00,$00,$00,'C',$00,$15,$00,$02 
      DC.B      $01,$1A,$00,'=',$00,$00,$01,$0A 
      DC.B      $00,'K',$00,$01,$00,$DA,$00,'P' 
      DC.B      $00,$02,$00,$E0,$00,$A0,$00,$00 
      DC.B      $00,$95,$00,$09,$00,$02,$01,'#' 
      DC.B      $00,'^',$00,$02,$00,$F5,$00,'N' 
      DC.B      $00,$02,$01,$1B,$00,'O',$00,$02 
      DC.B      $00,'s',$00,$B7,$00,$01,$00,$D1 
      DC.B      $00,'h',$00,$00,$01,'5',$00,'a' 
      DC.B      $00,$02,$00,'`',$00,'m',$00,$00 
      DC.B      $00,$0C,$00,$AB,$00,$02,$00,$A7 
      DC.B      $00,$A8,$00,$00,$00,$F3,$00,$0C 
      DC.B      $00,$02,$00,$A5,$00,$9C,$00,$00 
      DC.B      $00,'1',$00,$92,$00,$02,$01,'7' 
      DC.B      $00,'D',$00,$01,$00,$96,$00,'\' 
      DC.B      $00,$00,$00,$83,$00,'0',$00,$00 
      DC.B      $00,$89,$00,'+',$00,$01,$00,'H' 
      DC.B      $00,$84,$00,$01,$01,':',$00,$09 
      DC.B      $00,$02,$00,'E',$00,'p',$00,$00 
      DC.B      $00,$12,$00,'#',$00,$02,$01,$1A 
      DC.B      $00,$05,$00,$01,$00,'A',$00,$96 
L0050:DS.W      200 
L0051:DC.B      '      Release date: 9th June 1992',0,0
L0052:DC.W      0
L0053:DC.W      0

L0054:DC.L      L0055 
L0055	dc.b	'          The Source Menu 115',$a
	dc.b	'          -------------------',$a,$a
	dc.b	'    F1 - Son Et Lumiere by Paranoia',$a
	dc.b	'   F2 - 20 Seconds To Comply (1 Meg)',$a
	dc.b	'         F3 - Mad Vision Intro',$a
	dc.b	'    F4 - Insignia Tracker + Replay',$a,$a,$a

	dc.b	'               Credits:',$a
	dc.b	'               --------',$a,$a
	dc.b	'Coding: GOR+TUF     Menu Rip: Special FX',$a,$a
	dc.b	'  Music: Composed with the PSG Tracker',$a
	dc.b	'     (more available on Source 109)',$a
	dc.b	0

L0056:DS.W      2 
L0057:DC.B      $00,$01 
L0058:DC.B      $00,$00 
L0059:DC.B      $00,$00 
L005A:DC.L      L005B 

L005B:DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'f',$07,'f',$07,'U',$07,'U' 
      DC.B      $07,'D',$07,'D',$07,'3',$07,'3' 
      DC.B      $07,'"',$07,'"',$07,$11,$07,$11 
      DC.B      $07,$00,$07,$00,$06,$00,$06,$00 
      DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'f',$07,'f',$07,'U',$07,'U' 
      DC.B      $07,'D',$07,'D',$07,'3',$07,'3' 
      DC.B      $07,'"',$07,'"',$07,$11,$07,$11 
      DC.B      $07,$00,$07,$00,$06,$00,$06,$00 
      DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'f',$07,'f',$07,'U',$07,'U' 
      DC.B      $07,'D',$07,'D',$07,'3',$07,'3' 
      DC.B      $07,'"',$07,'"',$07,$11,$07,$11 
      DC.B      $07,$00,$07,$00,$06,$00,$06,$00 
      DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'f',$07,'f',$07,'U',$07,'U' 
      DC.B      $07,'D',$07,'D',$07,'3',$07,'3' 
      DC.B      $07,'"',$07,'"',$07,$11,$07,$11 
      DC.B      $07,$00,$07,$00,$06,$00,$06,$00 
      DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'f',$07,'f',$07,'U',$07,'U' 
      DC.B      $07,'D',$07,'D',$07,'3',$07,'3' 
      DC.B      $07,'"',$07,'"',$07,$11,$07,$11 
      DC.B      $07,$00,$07,$00,$06,$00,$06,$00 
      DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'f',$07,'f',$07,'U',$07,'U' 
      DC.B      $07,'D',$07,'D',$07,'3',$07,'3' 
      DC.B      $07,'"',$07,'"',$07,$11,$07,$11 
      DC.B      $07,$00,$07,$00,$06,$00,$06,$00 
      DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'f',$07,'f',$07,'U',$07,'U' 
      DC.B      $07,'D',$07,'D',$07,'3',$07,'3' 
      DC.B      $07,'"',$07,'"',$07,$11,$07,$11 
      DC.B      $07,$00,$07,$00,$06,$00,$06,$00 
      DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'f',$07,'f',$07,'U',$07,'U' 
      DC.B      $07,'D',$07,'D',$07,'3',$07,'3' 
      DC.B      $07,'"',$07,'"',$07,$11,$07,$11 
      DC.B      $07,$00,$07,$00,$06,$00,$06,$00 
      DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'f',$07,'f',$07,'U',$07,'U' 
      DC.B      $07,'D',$07,'D',$07,'3',$07,'3' 
      DC.B      $07,'"',$07,'"',$07,$11,$07,$11 
      DC.B      $07,$00,$07,$00,$06,$00,$06,$00 
      DC.B      $07,'w',$07,'w',$07,'f',$07,'f' 
      DC.B      $07,'U',$07,'U',$07,'D',$07,'D' 
      DC.B      $07,'3',$07,'3',$07,'"',$07,'"' 
      DC.B      $07,$11,$07,$11,$07,$00,$07,$00 
      DC.B      $06,$00,$06,$00,$07,'w',$07,'w' 
      DC.B      $07,'g',$07,'g',$07,'W',$07,'W' 
      DC.B      $07,'G',$07,'G',$07,'7',$07,'7' 
      DC.B      $07,$27,$07,$27,$07,$17,$07,$17 
      DC.B      $07,$07,$07,$07,$06,$06,$06,$06 

L005C	DC.W	0
L005D	DS.W      80
L005E	DS.W      592 
scrollp	dc.l	scrolly

scrolly	dc.b	'Oh Boy!  He is using this menu again ......'
	dc.b	'                                      '
	dc.b	'Welcome to another menu by MUG U.K(tm) for The Source !!  This is '
	dc.b	'"The Source Menu 115"          '

	dc.b	'What should every menu contain ???'
	dc.b	'                                      '
	dc.b	'The Credits !!'
	dc.b	'                                      '
	dc.b	'Credits to:-   Menu Coding by: GOR+TUF    Menu Ripping by: Alchemy of Special FX    '
	dc.b	'Music Composed With: PSG Tracker    Music Play Routine Ripped by: MSD of POV (with thanks '
	dc.b	'to Grazey of PHF for making it into an easy callable format) '
	dc.b	'and lastly, Menu Compilation: MUG U.K(tm)  !!     '

	dc.b	'Now for the details as towards the contents of this disk.  '
	dc.b	'                                      '
	
	dc.b	'First up we have a nice Quartet demo done by Paranoia.  The source code (Power BASIC format) is '
	dc.b	'on the disk as a self-extracting archive.  Also in this archive are the five documents that came with the '
	dc.b	'demo.  Drag this self-extracting arhive to another disk before un-archiving it !!  To depack the files in order '
	dc.b	'to use the source code, use my "Multi Depacker v1.0" !!  '
	dc.b	'Second on the list is a demo someone sent me a while ago and it was taking '
	dc.b	'up a bit of precious space on my hard-drive, so I decided to shove it on here !!  '
	dc.b	'The music (if you can call it that!) is a sample of "20 Seconds To Comply" by God Knows !!  '
	dc.b	'The last demo on this disk is a small, but nicely done, intro by Mad Vision.  Finally, I have put the '
	dc.b	'full version of the "Insignia Tri-Sound Sequencer" on the disk as a self-extracting archive.  I have also '
	dc.b	'put the replay source code and a small program that will convert your music files into 1 file with '
	dc.b	'a replay routine bolted on the front !!  So I expect to hear some good tunes coming from you all and if you '
	dc.b	'want to spread them about, send them to us !!  '
	dc.b	'I shall bid you farewell for now and I warn you all that I shall be hibernating again as PVK needs a hell '
	dc.b	'of a lot of work doing so I can get it released !!  Bye for now, and I leave you with the greetings .....'
	dc.b	'                                      '

	dc.b	'Before the general greetings section scrolls past you on this conveyor-message (?), I would like to '
	dc.b	'bore you to death with my own personal greetings ....................'
	dc.b	'                                      '
	
	dc.b	'MUG U.K sends his greetings to:  Other members of The Source (IWWWTTI, Speed, JJF, Mr.X and Egon), MSD of POV, '
	dc.b	'Slasher Bog (and everyone else in Special FX), TGA of NPG (nice bits & pieces you sent, keep them coming), '
	dc.b	'Mr.X (nice catalogue disk), Eddie of THB (hope "All Around The World" is a success !!), L.A.P.D., '
	dc.b	'Keith Frisby, Mark Matts, MSL, and finally Mat (of Untouchables).          '
	dc.b	'And this would not be a MUG U.K(tm) menu without lashings and lashings of sweet sticky greetings to '
	dc.b	"the girl in my life ......  CAZ (There can't be many girls who get a virus killer and every other "
	dc.b	"program I write dedicated to them !!)                "

	dc.b	'The Source greetings go to:      '
	
	dc.b	'The other demo CD makers:-  P.O.V    Ripped Off    NPG (Sadly no more ??)    Public Enemies (New to the scene are you ??'
	dc.b	'  Try packing the stuff when you put it on a menu !!)    Animal Mine (Nice Demo & Utility CDs)          '

	dc.b	'And now the other crews without whom we would probably have nothing to pack !!     '

	dc.b	'Aenigmatica    Agression    Avengers    Animal Mine    ACF    '
	dc.b	'(The German) Alliance    Axxis (or Aura ?)    Admirables    ALF    '
	dc.b	'ACO and Flair (Nice Cunning Demos)    '
	dc.b	'BMT    BBC    (The) Black Cats    (The) Bald Eagle    '
	dc.b	'Cybernetics (Synthy v2.25 is brilliant !!)    Cynix    Chaos    '
	dc.b	'D-Bug (Thanks for the greeting regards the music hacks on Menu 36 !!)    Delta Force    DNT    DBA (Thanks for Issue 5)    '
	dc.b	'Dal Snuffs    Dynamic Duo    '
	dc.b	'Electra    Electronic Images    Elite    Equinox    Electricity    The Empire    '
	dc.b	'Eternal    (The) Exterminators (nice Demo Ripper - any updates ready yet ??)    '
	dc.b	'Flytox (Nice TCB Tracker Replay program !!)    Frosty    '
	dc.b	'Fuzion (Is there an update to your Mega Ripper yet ?  I have lots of '
	dc.b	'music formats floating around my head if you want them !!)    Futur Minds    Factory    Fingerbobs    Flatliners    Firehawks    '
	dc.b	'Galtan 6    Genesis Inc.    G-Force    '
	dc.b	'Inner Circle (All members)    Impact    Imagina    '
	dc.b	'JSD    '
	dc.b	'Kruz    Kaos    '
	dc.b	'Light Team    Lord Hackbear (Nice CDs)    Lightnings    (The) Lost Boys    Legacy    '
	dc.b	'Mad Vision    MJJ    '
	dc.b	'Naos    NATO    Newline    NEXT    NPG (esp. TGA)    '
	dc.b	'Orion    Omega    Oxygen (nice "Genius" Demo)   '
	dc.b	'Paulo Simoes    Pompey Pirates    (The) Pixel Twins    Poltergeists    '
	dc.b	'Quartex    '
	dc.b	'Replicants    R.I.P    '
	dc.b	'Superior    ST Connexion    Stonaction    Special FX (Hi! Mentor)    (The) Syndicate (Blipblopper released yet ??)    '
	dc.b	'Slaytanic Cult    Sync    The Supervisors    Sentry    '
	dc.b	'TLS    TSB    TCB    THK (The Megatizer Is Brilliant - and it works on TOS v1.2 !!)    TVI    Torque    '
	dc.b	'ULM    Undead    Union (All members of this massive crew)    Untouchables    U-TOS    '
	dc.b	'V-Max    Vlad (of Lynx)    '
	dc.b	'(The) Watchmen    (The) Wild Boys    '
	dc.b	'Xenex    X-Tream'
	dc.b	'                                      '
	
	dc.b	'That is all the greetings for now, so I will see you all on the next Source Menu that '
	dc.b	'I compile !!  This is MUG U.K(tm) signing off .........'
	dc.b	'                                      '

	dc.b	'Now doing a wrap ... hold on tight ....................'
	dc.b	'                                      '

	dc.b	-1	; end of scrolltext marker


L0061	DC.L      PAL_TAB
PAL_TAB	DC.W      $0001,$0000,$0001,$0001 
	DC.W      $0002,$0001,$0002,$0002 
	DC.W      $0003,$0002,$0003,$0003 
	DC.W      $0004,$0003,$0004,$0004 
	DC.W      $0005,$0004,$0005,$0005 
	DC.W      $0006,$0005,$0006,$0006 
	DC.W      $0007,$0006,$0007,$0007 
	DC.W      $0117,$0007,$0117,$0117 
	DC.W      $0227,$0117,$0227,$0227 
	DC.W      $0337,$0227,$0337,$0337 
	DC.W      $0447,$0337,$0447,$0447 
	DC.W      $0557,$0447,$0557,$0557 

MUS_VBL	DC.L	0
MUSIX	INCBIN	"D:\MUSICHAK.MUG\PSG\PLAY_PSG.BIN"
	EVEN
MUS_DATA	INCBIN	"D:\MUSICHAK.MUG\PSG\NOWAYOUT.PSG"
	EVEN