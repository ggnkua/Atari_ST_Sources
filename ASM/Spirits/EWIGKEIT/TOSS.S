 TEXT 
Begin:
      PEA       L0000(PC) 
      MOVE.W    #$26,-(A7) 	;SUPEXEC
      TRAP      #$E 
L0000:LEA       L0000(PC),A6
      MOVE.L    A6,D0 
      LEA       L0066(PC),A0
      ADD.L     D0,(A0)+
      ADD.L     D0,(A0)+
      ADD.L     D0,(A0)+
      CLR.L     $FFFFFA06.W 
      LEA       dummy_rte(PC),A0
      MOVE.L    A0,$70.W
      LEA       $FFFF8800.W,A0
      MOVE.B    #$E,(A0)
      MOVE.B    (A0),D0 
      OR.B      #$10,D0 
      ADDQ.W    #2,A0 
      MOVE.B    D0,(A0) 
      AND.B     #-$11,D0
      MOVE.B    D0,(A0) 
      LEA       L0064(PC),A0
      MOVE.W    #$1FF,D0
L0001:MOVE.L    (A0),$FFFFA204.W
      ADDQ.W    #3,A0 
      DBF       D0,L0001
      LEA       L007C(PC),A0
      MOVEA.L   A0,A1 
      MOVEA.L   A0,A2 
      LEA       $404(A0),A3 
      MOVEQ     #0,D6 
      MOVEQ     #$7F,D7 
L0002:MOVE.L    D6,D5 
      MOVEQ     #8,D2 
L0003:MOVE.L    D2,D1 
      MOVE.L    D2,D0 
      ADDQ.W    #1,D0 
      MOVE.L    D6,D3 
L0004:MULU.L    D6,D4:D3
      ROL.L     #8,D3 
      ROL.L     #8,D4 
      MOVE.B    D3,D4 
      MOVE.L    D4,D3 
      MULU.L    D1,D0 
      SUBQ.W    #1,D1 
      BNE.S     L0004 
      DIVU.L    D0,D3 
      BTST      #1,D2 
      BEQ.S     L0005 
      NEG.L     D3
L0005:ADD.L     D3,D5 
      SUBQ.W    #2,D2 
      BNE.S     L0003 
      ASR.L     #1,D5 
      MOVE.L    D5,(A0)+
      MOVE.L    D5,-(A3)
      ADD.L     #$3243F,D6
      DBF       D7,L0002
      MOVE.L    #$7FFFFF,D0 
      MOVE.L    D0,-(A3)
      LEA       $200(A3),A3 
L0006:MOVE.L    (A1)+,(A3)
      NEG.L     (A3)
      CMP.L     (A3)+,D0
      BNE.S     L0006 
      BSR       L005A 
      LEA       L007E(PC),A0
      LEA       L0068(PC),A1
      CLR.W     D0
      MOVE.W    #$FF,D4 
L0007:MOVE.W    D0,D1 
      LSR.W     #4,D1 
      LEA       0(A1,D1.W),A2 
      MOVE.W    D0,D2 
      MOVEQ     #3,D3 
L0008:MOVE.B    (A2)+,D1
      EXT.W     D1
      ADD.W     D2,D1 
      BPL.S     L0009 
      CLR.W     D1
L0009:CMP.W     D4,D1 
      BLE.S     L000A 
      MOVE.W    D4,D1 
L000A:MOVE.W    D1,(A0)+
      DBF       D3,L0008
      ADDQ.B    #1,D0 
      BCC.S     L0007 
      LEA       L0069(PC),A1
      MOVEQ     #3,D4 
L000B:MOVEQ     #$F,D3
      MOVEM.W   (A1)+,D0-D2 
L000C:MOVE.W    D0,(A0)+
      MOVE.W    D0,(A0)+
      ADD.W     D2,D0 
      MOVE.W    D0,(A0)+
      MOVE.W    D0,(A0)+
      ADD.W     D1,D0 
      DBF       D3,L000C
      DBF       D4,L000B
      MOVEQ     #$F,D1
      LEA       L007F(PC),A0
L000D:ADD.W     D2,(A0)+
      ADDQ.W    #1,D2 
      DBF       D1,L000D
L000E:ADD.W     D2,(A0)+
      SUBQ.W    #1,D2 
      BNE.S     L000E 
      MOVEQ     #1,D0 
      BSR       send_dsp 
      LEA       L007E(PC),A0
      LEA       $FFFFA204.W,A4
      LEA       $FFFFA206.W,A5
      MOVEQ     #0,D0 
      MOVE.W    #$4FF,D1
L000F:MOVE.W    (A0)+,D0
      MOVE.L    D0,(A4) 
      DBF       D1,L000F
      LEA       L007D(PC),A0
      MOVEQ     #$58,D2 
      LSR.W     #8,D3 
L0010:MOVE.W    (A0),D0 
      MOVE.W    $200(A0),D1 
      MULS      D2,D0 
      MULS      D2,D1 
      SWAP      D0
      SWAP      D1
      MULS      #$64,D1 
      ADD.W     #$154A,D1 
      ADD.W     D0,D1 
      MOVE.L    D1,(A4) 
      ADDQ.W    #8,A0 
      DBF       D3,L0010
      LEA       L006B(PC),A0
      MOVEQ     #8,D2 
      MOVEQ     #$3E,D0 
L0011:MOVE.L    D0,(A0)+
      ADD.L     #$400040,D0 
      DBF       D2,L0011
      MOVE.W    D2,(A0)+
      MOVE.W    #$120,(A0)+ 
      MOVE.W    #-$8000,D3
      MOVEQ     #7,D2 
L0012:MOVE.W    D3,D0 
      MOVEQ     #$1F,D1 
L0013:MOVE.W    D0,(A0)+
      ADD.W     #$800,D0
      DBF       D1,L0013
      ADD.B     #$10,D3 
      DBF       D2,L0012
      MOVEQ     #0,D0 
      MOVEQ     #$1F,D1 
L0014:MOVE.W    D0,(A0)+
      ADDQ.B    #8,D0 
      BCC.S     L0014 
      LEA       L0065(PC),A0
      BSR.S     L0017 
      LEA       L006A(PC),A0
      BSR.S     L0017 
      MOVE.W    #1,L0078-L0000(A6)
      LEA       new_vbl(PC),A0
      MOVE.L    A0,$70.W
      CLR.L     $FFFF9800.W 
      MOVE.L    #$F000A,L0072-L0000(A6) 
      MOVE.W    #$100,$FFFF8266.W 
      LEA       $FFFF8282.W,A0
      MOVE.L    #$FE00B1,(A0)+
      MOVE.L    #$310010,(A0)+
      MOVE.L    #$B100D3,(A0)+
      LEA       $FFFF82A2.W,A0
      MOVE.L    #$2710211,(A0)+ 
      MOVE.L    #$810081,(A0)+
      MOVE.L    #$211026B,(A0)+ 
      MOVE.L    #$1820001,$FFFF82C0.W 
      MOVE.L    #$180,$FFFF820E.W 
L0015:BSR.S     L001C 
      MOVE.W    L0074(PC),D0
L0016:CMP.W     L0074(PC),D0
      BEQ.S     L0016 
      BRA.S     L0015 
L0017:MOVEQ     #2,D0 
      BSR       send_dsp 
      MOVE.W    (A0)+,D0
      BSR       send_dsp_word 
L0018:MOVE.W    (A0)+,D1
      BMI.S     L001A 
      MOVE.W    (A0)+,D2
      MOVE.W    D1,(A5) 
      MOVE.W    D2,(A5) 
L0019:MOVE.W    D1,(A5) 
      ADDQ.W    #2,D1 
      MOVE.W    D1,(A5) 
      CMP.W     D2,D1 
      BNE.S     L0019 
      BRA.S     L0018 
L001A:MOVE.W    (A0)+,D0
      BSR       send_dsp_word 
      SUBQ.W    #1,D0 
      LEA       L007D(PC),A3
      MOVEQ     #$F,D2
L001B:CLR.W     D3
      MOVE.B    (A0)+,D3
      MOVEQ     #-$31,D5
      MULS      (0.W,A3,D3.W*8),D5
      MOVE.W    ($200.W,A3,D3.W*8),D6 
      MOVE.W    D6,D7 
      MOVE.B    (A0)+,D3
      MULS      (0.W,A3,D3.W*8),D6
      MULS      ($200.W,A3,D3.W*8),D7 
      ASR.L     D2,D5 
      ASR.L     D2,D6 
      ASR.L     D2,D7 
      MULS      #$31,D6 
      MULS      #$31,D7 
      ASR.L     D2,D6 
      ASR.L     D2,D7 
      MOVE.L    D5,(A4) 
      MOVE.L    D6,(A4) 
      MOVE.L    D7,(A4) 
      DBF       D0,L001B
      RTS 
L001C:MOVE.W    L0078(PC),D0
      JMP       L001D(PC,D0.W*2) 
L001D:BRA.S     L001F 
      BRA.S     L0020 
      BRA.S     L001E 
      BRA.S     L0025 
      BRA.S     L0027 
L001E:SUBQ.W    #1,L007A-L0000(A6)
      BNE.S     L001F 
      MOVE.W    L0079(PC),L0078-L0000(A6) 
L001F:RTS 
L0020:MOVE.L    #$20003,L0078-L0000(A6) 
      MOVE.W    #$FA,L007A-L0000(A6)
      CLR.L     L0075-L0000(A6) 
      BSR.S     L0028 
      MOVE.L    #$12C00,L0073-L0000(A6) 
L0021:LEA       ($1444DA,A6.L),A1 
      BSR.S     L0022 
      LEA       ($169CDA,A6.L),A1 
L0022:LEA       L0080(PC),A0
      ADDA.L    L0073(PC),A1
      MOVEQ     #$63,D1 
L0023:LEA       $190(A1),A1 
      MOVEQ     #$16,D0 
L0024:MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      DBF       D0,L0024
      DBF       D1,L0023
      RTS 
L0025:ADDI.L    #$300,L0075-L0000(A6) 
      CMPI.L    #$12C00,L0075-L0000(A6) 
      BLT.S     L0026 
      CLR.L     L0073-L0000(A6) 
      BSR.S     L0021 
      MOVE.W    #4,L0078-L0000(A6)
L0026:RTS 
L0027:CLR.L     L0075-L0000(A6) 
      MOVE.L    #$12C00,L0073-L0000(A6) 
      MOVE.W    #1,L0078-L0000(A6)
      RTS 
L0028:DC.B      $A0,$00 			;call line a
      MOVEA.L   -$1C8(A0),A2
      MOVEA.L   $4C(A2),A2
      MOVEA.L   L0066(PC),A4			;current text ptr
      LEA       L0080(PC),A0
      LEA       $42D8(A0),A5
      MOVEQ     #0,D0 
      MOVE.W    #$8FB,D1
L0029:MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      DBF       D1,L0029
      MOVEA.L   A4,A0 
L002A:TST.W     (A0)
      BEQ.S     L002C 
      TST.B     (A0)+ 
      BNE.S     L002A 
      LEA       -$5C0(A5),A5
      BRA.S     L002A 
L002B:TST.B     (A4)
      BEQ.S     L002E 
      LEA       $B80(A5),A5 
L002C:MOVEA.L   A5,A3 
      MOVEA.L   A4,A0 
      CLR.W     D0
      MOVEQ     #$A,D4
L002D:MOVE.B    (A0)+,D0
      BEQ.S     L0031 
      CMP.W     D4,D0 
      BLE.S     L002D 
      SUBQ.W    #8,A3 
      BRA.S     L002D 
L002E:ADDQ.W    #1,A4 
      TST.B     (A4)
      BNE.S     L002F 
      LEA       L003C(PC),A4			;reset text to start
L002F:MOVE.L    A4,L0066-L0000(A6)		;save new text ptr
      RTS 
L0030:MOVE.W    #3,L0077-L0000(A6)
      MOVE.L    #$96FFFF,L006F-L0000(A6)
L0031:CLR.W     D0
      MOVE.B    (A4)+,D0
      CMP.W     D4,D0 
      BLE.S     L0034 
      LEA       ($6DC.W,A2,D0.W),A0 
      MOVEA.L   A3,A1 
      MOVEQ     #7,D2 
L0032:MOVE.B    (A0),D0 
      MOVEQ     #7,D1 
L0033:ADD.B     D0,D0 
      SCS       D3
      EXT.W     D3
      MOVE.W    D3,(A1)+
      DBF       D1,L0033
      LEA       $160(A1),A1 
      LEA       $100(A0),A0 
      DBF       D2,L0032
      LEA       $10(A3),A3
      BRA.S     L0031 
L0034:JMP       L0035(PC,D0.W*2) 
L0035:BRA.S     L002B 
      BRA.S     L0039 
      BRA.S     L003A 
      BRA.S     L003B 
      BRA.S     L0030 
      BRA.S     L0038 
      BRA.S     L0037 
      BRA.S     L0036 
      MOVE.W    #$3E8,L007A-L0000(A6) 
      BRA.S     L0031 
L0036:MOVE.W    #-1,L0070-L0000(A6) 
      MOVE.W    #$1F,L0071-L0000(A6)
      BRA.S     L0031 
L0037:MOVE.W    #8,L0077-L0000(A6)
      MOVE.L    #$1F0001,L0072-L0000(A6)
      MOVE.W    #1,L0070-L0000(A6)
      CLR.W     L0071-L0000(A6) 
      BRA.S     L0031 
L0038:MOVE.W    #$2EE,L007A-L0000(A6) 
      BRA.S     L0031 
L0039:CLR.W     L0077-L0000(A6) 
      CLR.L     L0076-L0000(A6) 
      CLR.W     L0071-L0000(A6) 
      MOVE.L    #$320001,L006F-L0000(A6)
      MOVE.L    #$F000A,L0072-L0000(A6) 
      BRA       L0031 
L003A:MOVE.W    #1,L0077-L0000(A6)
      MOVE.W    #$80,L006E-L0000(A6)
      BRA       L0031 
L003B:MOVE.W    #2,L0077-L0000(A6)
      MOVE.L    #$2BC0001,L006F-L0000(A6) 
      CLR.W     L0071-L0000(A6) 
      BRA       L0031 
L003C:DC.B      $01,$00,$00,'but n' 
      DC.B      'ow ask t'
      DC.B      'he beast'
      DC.B      's',$00,'they s'
      DC.B      'hall tea'
      DC.B      'ch you',$00,'a'
      DC.B      'nd',$00,'the b'
      DC.B      'irds of '
      DC.B      'the air',$00 
      DC.B      'they sha'
      DC.B      'll teach'
      DC.B      ' you',$00,'or',$00 
      DC.B      'SPEAK TO'
      DC.B      ' THE EAR'
      DC.B      'TH',$00,'AND I'
      DC.B      'T SHALL '
      DC.B      'TEACH YO'
      DC.B      'U',$00,'and',$00,'th'
      DC.B      'e fishes'
      DC.B      ' of the '
      DC.B      'sea',$00,'shal'
      DC.B      'l declar'
      DC.B      'e to you'
      DC.B      ' :',$00,$00,'WHO ' 
      DC.B      'KNOWS NO'
      DC.B      'T',$00,' ',$00,'IN A'
      DC.B      'LL THESE'
      DC.B      $00,' ',$00,'THAT',$00
      DC.B      ' ',$00,'THE HA'
      DC.B      'ND OF TH'
      DC.B      'E LORD',$00,' '
      DC.B      $00,'HAS WOR' 
      DC.B      'KED THIS'
      DC.B      ' ?',$00,$00,'HEAV' 
      DC.B      'EN AND E'
      DC.B      'ARTH',$00,' ',$00,'w'
      DC.B      'ill pass'
      DC.B      ' away',$00,'bu'
      DC.B      't',$00,' ',$00,'MY W'
      DC.B      'ORDS',$00,' ',$00,'w'
      DC.B      'ill',$00,'by n'
      DC.B      'o means',$00 
      DC.B      'pass awa'
      DC.B      'y',$00,$00,$02,'for '
      DC.B      'god',$00,'so l'
      DC.B      'oved the'
      DC.B      ' world',$00,'t'
      DC.B      'hat he g'
      DC.B      'ave',$00,'his '
      DC.B      'only beg'
      DC.B      'otten so'
      DC.B      'n',$00,'that w'
      DC.B      'hoever',$00,'b'
      DC.B      'elieves '
      DC.B      'in him',$00,' '
      DC.B      $00,'SHOULD ' 
      DC.B      'NOT PERI'
      DC.B      'SH',$00,' ',$00,'but'
      DC.B      ' have',$00,' ',$00 
      DC.B      'EVERLAST'
      DC.B      'ING LIFE'
      DC.B      $00,$00,$05,$03,'and '
      DC.B      'i saw',$00,' ',$00 
      DC.B      'A NEW HE'
      DC.B      'AVEN',$00,'and'
      DC.B      $00,'A NEW E' 
      DC.B      'ARTH',$00,' ',$00,'f'
      DC.B      'or the f'
      DC.B      'irst hea'
      DC.B      'ven',$00,'and '
      DC.B      'the firs'
      DC.B      't earth',$00 
      DC.B      'had pass'
      DC.B      'ed away',$00 
      DC.B      'also the'
      DC.B      're was',$00,'n'
      DC.B      'o more s'
      DC.B      'ea',$00,$00,'and ' 
      DC.B      'god will'
      DC.B      $00,'wipe aw' 
      DC.B      'ay every'
      DC.B      ' tear',$00,'fr'
      DC.B      'om their'
      DC.B      ' eyes',$00,'th'
      DC.B      'ere shal'
      DC.B      'l be',$00,'no '
      DC.B      'more dea'
      DC.B      'th',$00,'nor s'
      DC.B      'orrow',$00,'no'
      DC.B      'r crying'
      DC.B      $00,'and the' 
      DC.B      're shall'
      DC.B      ' be',$00,'no m'
      DC.B      'ore pain'
      DC.B      $00,'for the' 
      DC.B      ' former '
      DC.B      'things',$00,'h'
      DC.B      'ave pass'
      DC.B      'ed away',$00 
      DC.B      $00,'but the' 
      DC.B      ' cowardl'
      DC.B      'y',$00,'unbeli'
      DC.B      'eving',$00,'ab'
      DC.B      'ominable'
      DC.B      $00,'murdere' 
      DC.B      'rs',$00,'sexua'
      DC.B      'l immora'
      DC.B      'l',$00,'sorcer'
      DC.B      'ers',$00,'idol'
      DC.B      'ators',$00,'an'
      DC.B      'd all li'
      DC.B      'ars',$00,' ',$00,'sh'
      DC.B      'all',$00,'have'
      DC.B      ' their p'
      DC.B      'art ...',$00 
      DC.B      $00,$04,'... in'
      DC.B      ' the lak'
      DC.B      'e',$00,'which '
      DC.B      'burns',$00,'wi'
      DC.B      'th',$00,'fire '
      DC.B      'and brim'
      DC.B      'stone',$00,' ',$00 
      DC.B      $AF,' where ' 
      DC.B      'their wo'
      DC.B      'rm ',$00,'does'
      DC.B      ' not die'
      DC.B      '   ',$00,'and '
      DC.B      'the fire'
      DC.B      '   ',$00,'  is'
      DC.B      ' not que'
      DC.B      'nched ',$AE,$00
      DC.B      $00,$05,'DO YOU'
      DC.B      ' KNOW',$00,'WH'
      DC.B      'AT HAPPE'
      DC.B      'NED',$00,'THES'
      DC.B      'E DAYS !'
      DC.B      '?',$00,$00,$08,$06,'THE' 
      DC.B      ' BIBLE',$00,' '
      DC.B      $00,'God',$27,'s l' 
      DC.B      'etter - '
      DC.B      'to YOU',$00,$00
      DC.B      ' ',$00,$00,$07,' ',$00,$00,$00 
L003D:TST.W     (A0)+ 
      BEQ.S     L003E 
      SUBQ.W    #1,-(A0)
      RTS 
L003E:MOVE.W    (A0)+,D0
      BEQ.S     L0041 
      SUBQ.W    #1,(A0) 
      BCC.S     L0041 
      MOVE.W    6(A0),(A0)+ 
      ADD.W     (A0)+,D0
      BPL.S     L003F 
      CLR.W     D0
L003F:CMP.W     (A0),D0 
      BLT.S     L0040 
      MOVE.W    (A0),D0 
      CLR.W     -6(A0)
L0040:MOVE.W    D0,-(A0)
L0041:RTS 
new_vbl:
      MOVEM.L   A0-A6/D0-D7,-(A7) 
      LEA       send_dsp_word(PC),A4
      LEA       send_dsp(PC),A5
      LEA       L006F-L0000(A6),A0
      BSR.S     L003D 
      LEA       L006C-L0000(A6),A0
      BSR.S     L003D 
      MOVEQ     #8,D0 
      JSR       (A5)
      LEA       L007B(PC),A0
      MOVE.W    #$1FF,D3
      ADDQ.W    #1,(A0)+
      ADDQ.W    #2,(A0)+
      ADDQ.W    #3,(A0)+
      MOVEM.W   -6(A0),D0-D2
      AND.W     D3,D0 
      AND.W     D3,D1 
      AND.W     D3,D2 
      LEA       L007C(PC),A0
      LEA       $FFFFA204.W,A1
      MOVE.L    (0.B,A0,D0.W*4),(A1)
      MOVE.L    ($200.W,A0,D0.W*4),(A1) 
      MOVE.L    (0.B,A0,D1.W*4),(A1)
      MOVE.L    ($200.W,A0,D1.W*4),(A1) 
      MOVE.L    (0.B,A0,D2.W*4),(A1)
      MOVE.L    ($200.W,A0,D2.W*4),(A1) 
      MOVEQ     #7,D0 
      JSR       (A5)
      MOVE.W    L0076(PC),D0
      JSR       (A4)
      MOVEQ     #9,D0 
      JSR       (A5)
      LEA       L006E(PC),A1
      LEA       L0071(PC),A2
      LEA       L0077(PC),A3
      MOVE.W    (A3),D0 
      JMP       L0043(PC,D0.W*2) 
L0043:BRA.S     L0044 
      BRA.S     L0046 
      BRA.S     L0047 
      BRA.S     L0048 
      BRA.S     L0049 
      BSR.S     L004A 
      BRA.S     L004C 
      BRA.S     L0045 
      BRA       L0052 
L0044:MOVEQ     #$A,D0
      JSR       (A5)
      MOVE.W    (A2),D0 
      JSR       (A4)
L0045:MOVEQ     #6,D0 
      JSR       (A5)
      MOVE.W    (A2),D0 
      LSL.W     #6,D0 
      JSR       (A4)
      MOVEQ     #5,D0 
      BRA.S     L004D 
L0046:MOVEQ     #6,D0 
      JSR       (A5)
      MOVE.W    (A1),D0 
      JSR       (A4)
      BRA.S     L004C 
L0047:CMPI.W    #$64,L006F-L0000(A6)
      BGE.S     L0046 
      TST.W     L006F-L0000(A6) 
      BNE.S     L004C 
      ADDQ.W    #5,(A3) 
      ADDQ.W    #5,L0076-L0000(A6)
      BRA.S     L004C 
L0048:TST.W     (A2)
      BNE.S     L0045 
      ADDQ.W    #1,L006D-L0000(A6)
      MOVE.L    #$1000A0,(A1) 
      ADDQ.W    #1,(A3) 
      BRA.S     L0044 
L0049:BSR.S     L004A 
      MOVE.L    #$1F40001,L006C-L0000(A6) 
      MOVE.W    #$FF,(A1) 
      BRA.S     L004C 
L004A:MOVEQ     #3,D0 
      JSR       (A5)
      MOVE.W    (A1)+,D0
      JSR       (A4)
      TST.W     L006D-L0000(A6) 
      BNE.S     L004B 
      ADDQ.W    #1,(A3) 
      RTS 
L004B:ADDQ.W    #4,A7 
L004C:MOVEQ     #4,D0 
L004D:JSR       (A5)
      BSR       read_dsp 
      BSR       screen_swap 
      LEA       $FFFFA206.W,A0
      MOVEQ     #$63,D2 
L004E:MOVEQ     #9,D1 
L004F:MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      MOVE.W    (A0),D0 
      MOVE.W    D0,(A1)+
      MOVE.W    D0,(A1)+
      DBF       D1,L004F
      LEA       $170(A1),A1 
      DBF       D2,L004E
L0050:LEA       $FFFF820D.W,A0
      MOVE.B    D3,D4 
      LSR.L     #8,D3 
      MOVEP.W   D3,-$C(A0)
      MOVE.B    D4,(A0) 
      MOVEM.L   (A7)+,A0-A6/D0-D7 
      ADDQ.W    #1,L0074-L0000(A6)
dummy_rte:
	addq.w	#1,$466.w
	RTE 
L0052:BSR.S     screen_swap 
      LEA       L0081,A0
      MOVEQ     #$1F,D0 
      SUB.W     L0071-L0000(A6),D0
      MULU      #-$63C0,D0
      ADDA.L    D0,A0 
      MOVEQ     #$63,D2 
L0053:MOVEQ     #9,D1 
L0054:MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      MOVE.L    (A0)+,(A1)+ 
      DBF       D1,L0054
      LEA       $170(A1),A1 
      DBF       D2,L0053
      BRA.S     L0050 
screen_swap:
      LEA       L0067(PC),A2		;physic/logic
      MOVEA.L   (A2)+,A0		;current physic
      MOVEA.L   (A2)+,A1		;current logic
      MOVE.L    A0,-(A2)		;new logic
      MOVE.L    A1,-(A2)		;new physic
      ADDA.L    L0075(PC),A1		;scroll offset
      MOVE.L    A1,D3 
      RTS 
read_dsp:
      BTST      #0,$FFFFA202.W
      BEQ.S     read_dsp 
      MOVE.L    $FFFFA204.W,D0
      RTS 
send_dsp:
      BTST      #3,$FFFFA202.W
      BEQ.S     send_dsp 
send_dsp_word:
      EXT.L     D0
L0059:BTST      #1,$FFFFA202.W
      BEQ.S     L0059 
      MOVE.L    D0,$FFFFA204.W
      RTS 
L005A:LEA       L0082,A2
      MOVEQ     #$31,D0 
      MOVEQ     #0,D4 
      MOVEQ     #0,D6 
L005B:BSR.S     L0060 
      SUBQ.W    #1,D0 
      ADD.W     #$841,D4
      BCC.S     L005B 
      CLR.W     D4
      MOVEQ     #$19,D0 
      CLR.W     D6
      BSR.S     L0060 
      LEA       -$2710(A2),A1 
      MOVEQ     #8,D0 
      BSR.S     L005E 
      LEA       -$C(A1),A1
      MOVEQ     #6,D0 
      BSR.S     L005E 
      LEA       $18(A1),A1
      MOVEQ     #5,D0 
      BSR.S     L005E 
      LEA       L0081,A0
      LEA       L0083,A1
      MOVE.L    #$975E0,D1
L005C:MOVE.W    (A0)+,D0
      BEQ.S     L005D 
      SUB.W     #$841,D0
      BCC.S     L005D 
      CLR.W     D0
L005D:MOVE.W    D0,(A1)+
      SUBQ.L    #1,D1 
      BNE.S     L005C 
      RTS 
L005E:MOVEA.L   A1,A0 
L005F:CLR.L     (A0)
      LEA       -$190(A0),A0
      SUBQ.W    #1,D0 
      BNE.S     L005F 
      LEA       $31C(A0),A0 
      CLR.L     (A0)+ 
      CLR.L     (A0)+ 
      CLR.L     (A0)+ 
      RTS 
L0060:LEA       L007D(PC),A0
      MOVEQ     #$F,D3
      MOVEQ     #$7F,D7 
L0061:MOVE.W    (A0),D1 
      MOVE.W    $200(A0),D2 
      MULS      D0,D1 
      MULS      D0,D2 
      ASR.L     D3,D1 
      ASR.L     D3,D2 
      MULS      #-$190,D1 
      BSR.S     L0062 
      NEG.L     D1
      BSR.S     L0062 
      ADDQ.W    #4,A0 
      DBF       D7,L0061
      RTS 
L0062:MOVE.W    D2,-(A7)
      ASL.W     D6,D2 
      LEA       (4.B,A2,D2.W*4),A1
      ADDA.L    D1,A1 
      ASL.W     #2,D2 
L0063:MOVE.W    D4,-(A1)
      DBF       D2,L0063
      MOVE.W    (A7)+,D2
      RTS 
L0064 EQU       *-1 
      DC.B      $0C,$00,'@',$00,$00,$00,$00,$00 
      DCB.W     92,0
      DC.B      ' ',$00,$13,$05,$F4,' ',$FF,$FF 
      DC.B      $FF,$05,$00,$B9,$08,$CC,'>',$08 
      DC.B      $F4,$BF,$00,$0C,$00,$08,$F4,$A0 
      DC.B      $00,$00,$01,$08,$F4,$A8,$00,$00 
      DC.B      $0C,$00,$00,$BA,$04,'a',$A0,$04 
      DC.B      'b',$A0,$04,'c',$A0,$04,'d',$A0 
      DC.B      $04,'e',$A0,'E',$F4,$00,$00,'@' 
      DC.B      $00,'!',$90,$00,$06,$C5,' V'
      DC.B      'X',$00,$0A,$A9,'$',$0A,$A9,$80 
      DC.B      $00,$00,'W',$08,'X+`',$F4 
      DC.B      $00,$00,$00,'^',$0A,$A9,$04,$0B 
      DC.B      $E8,$80,$0C,$00,'V',$0C,$00,'p' 
      DC.B      $0C,$01,$90,$0C,$00,$C2,$0C,$00 
      DC.B      $86,$0C,$00,$B5,$0C,$01,'x',$0C 
      DC.B      $00,'i',$0C,$01,$0D,$0C,$01,'H' 
      DC.B      $0C,$00,$AC,'V',$F4,$00,$00,' ' 
      DC.B      $00,$0D,$00,$82,' ',$00,'@',$07 
      DC.B      'p',$8C,$00,$01,$A8,$00,$00,$0C 
      DC.B      '`',$F4,$00,$00,$01,$AC,'D',$F4 
      DC.B      $00,$00,$04,$00,$0D,$00,'|`'
      DC.B      $F4,$00,$00,$00,$00,'D',$F4,$00 
      DC.B      $00,$01,$00,$0D,$00,'|`',$F4
      DC.B      $00,$00,' ',$0F,$06,$C4,$00,$00 
      DC.B      $00,$80,$0A,$A9,$80,$00,$00,'~' 
      DC.B      $08,'X',$EB,$00,$00,$0C,$0A,$A9 
      DC.B      $80,$00,$00,$82,$08,'D+',$00
      DC.B      $00,$0C,'0',$00,$00,'2c',$00
      DC.B      '"',$11,$00,'t',$F4,$00,$00,$01 
      DC.B      $AC,'"',$15,$00,'e',$F4,$00,$00 
      DC.B      $00,$00,'E',$DA,$00,'F',$DA,$00 
      DC.B      'G',$DA,$00,'D',$D8,'a ',$C5
      DC.B      '@ ',$E6,'`G',$DA,'p!'
      DC.B      $D4,$00,$0A,$A9,$81,$00,$00,$96 
      DC.B      'm',$EC,$00,'W',$F4,$00,$00,$27 
      DC.B      $10,'eY',$00,$06,$CF,$00,$00
      DC.B      $00,$A7,'D',$D8,'a ',$C5,'@'
      DC.B      ' ',$E6,'PG',$DA,'p!',$D4 
      DC.B      $00,$08,$E5,$EB,'m',$EC,$00,$0A 
      DC.B      $A9,$81,$00,$00,$A5,'eY',$00
      DC.B      ' ',$00,$13,$06,'d',$A0,'Ty'
      DC.B      $00,$00,$00,$0C,'`',$F4,$00,$00 
      DC.B      ' ',$0F,$0D,$00,$82,$06,$00,$81 
      DC.B      $00,$00,$B3,'i',$D8,$00,$00,$00 
      DC.B      $00,'Da',$00,$00,$00,$0C,'D'
      DC.B      $F4,$00,$00,$00,$00,' ',$90,$00 
      DC.B      'E',$F4,$00,$00,$27,$10,$06,$C5 
      DC.B      $00,$00,$00,$C0,$0A,$A9,$81,$00 
      DC.B      $00,$BC,'a',$E0,$00,'DX',$00
      DC.B      $08,$D1,'+',$00,$00,$0C,$0D,$00 
      DC.B      $82,$07,$F0,$8C,$00,$00,$D7,'U' 
      DC.B      $F4,$00,$FF,$FF,$FC,'F',$F4,'H' 
      DC.B      $00,$05,$E8,'`',$F4,$00,$00,'&' 
      DC.B      $AC,'8',$01,$00,$06,'d',$80,$00 
      DC.B      $00,$D3,' ',$00,'7',$0E,$80,$D2 
      DC.B      'UXP',$0C,$00,$D3,'DX'
      DC.B      'T',$00,$00,$00,$07,'p',$8C,$00 
      DC.B      $00,$D7,$00,$00,$0C,'ZcM' 
      DC.B      ' ',$00,$13,' ',$00,$1B,' ',$CF 
      DC.B      'A ',$00,'e',$0E,$90,$E1,' '
      DC.B      $A4,$00,'!',$C5,$00,' ',$E6,$00 
      DC.B      '!',$E7,$00,'p',$F4,'q',$00,$00 
      DC.B      'd ',$00,'U',$0E,$10,$E7,'p'
      DC.B      $F4,$00,$FF,$FF,$9C,'G',$F4,'y' 
      DC.B      $00,$00,'2 ',$00,$B0,'!',$0C
      DC.B      '\ ',$00,'@!',$D0,'a '
      DC.B      $00,'D ',$00,'&!',$D2,'.' 
      DC.B      '!',$F3,$0D,$0E,$10,$FE,'"E'
      DC.B      $09,'"d6F',$F4,'"',$00
      DC.B      $00,$01,' ',$00,'X',$06,$CD,$00 
      DC.B      $00,$00,$FC,'aX@',$0E,$B0 
      DC.B      $FC,' Hd',$00,$00,$00,$00 
      DC.B      $00,$0C,'"D',$01,'"e6'
      DC.B      $0E,$A1,$0B,'F',$F4,'"',$00,$00 
      DC.B      $01,' ',$00,'X',$06,$CD,$00,$00 
      DC.B      $01,$09,'aH@',$0E,$B1,$09 
      DC.B      ' Xd',$00,$00,$00,$00,$00 
      DC.B      $0C,'a`',$00,$00,$00,$0C,'`'
      DC.B      $F4,$00,$00,$01,$10,'D',$F4,$00 
      DC.B      $00,$00,$06,$0D,$00,'|`',$F4
      DC.B      $00,$00,$01,$00,'L',$F0,$00,$00 
      DC.B      $01,$13,'O',$F0,$00,$00,$01,$15 
      DC.B      ' ',$00,$C0,'\X',$00,'M',$F0
      DC.B      $00,$00,$01,$14,' ',$00,$A0,'\' 
      ADDQ.B    #4,D0 
      JMP       0(A0,D0.W)
      DC.B      $01,$12,'NX',$00,'L',$F0,$00
      DC.B      $00,$01,$10,' ',$00,$D4,'!',$86 
      DC.B      $00,' ',$00,$B0,'L',$F0,$00,$00 
      DC.B      $01,$11,' ',$00,$A6,'\X',$00
      DC.B      ' ',$00,$E0,' ',$00,$C2,'\X'
      DC.B      $00,'N',$F0,$00,$00,$01,$10,'M' 
      DC.B      $F0,$00,$00,$01,$13,' ',$00,$E0 
      DC.B      '\X',$00,'M',$F0,$00,$00,$01
      DC.B      $12,' ',$00,$A4,'!',$86,$00,' ' 
      DC.B      $00,$B0,'L',$F0,$00,$00,$01,$10 
      DC.B      'M',$F0,$00,$00,$01,$14,' ',$00 
      DC.B      $A2,'\X',$00,' ',$00,$E0,' '
      DC.B      $00,$C6,'\X',$00,'L',$F0,$00
      DC.B      $00,$01,$11,'M',$F0,$00,$00,$01 
      DC.B      $13,' ',$00,$A0,'\X',$00,$00
      DC.B      $00,$0C,$07,$F0,$94,$00,$01,$A8 
      DC.B      '<',$02,$00,'g',$F4,$00,$00,$01 
      DC.B      $00,$04,'L',$14,$05,$08,$A7,'h' 
      DC.B      $DC,$00,'L',$DC,$00,'i',$DC,$00 
      DC.B      $06,$C4,$00,$00,$01,'vL',$D8
      DC.B      $00,'M',$D8,$00,'N',$D8,$00,'O' 
      DC.B      $DF,$00,'O',$DF,$C0,'O',$DF,$F2 
      DC.B      'O',$DF,$B3,$07,'p',$8C,$00,$01 
      DC.B      $AB,'O',$DF,$C0,'O',$DF,$F2,'O' 
      DC.B      $DF,$B3,'O',$DF,$C8,'O',$DF,$FA 
      DC.B      'D',$F4,$BB,$00,$00,$E0,' ',$00 
      DC.B      'H!',$A5,$00,$07,$F0,$84,$00
      DC.B      $01,$AB,'!',$86,$00,'D',$F4,$A0 
      DC.B      $00,$00,'2F',$F4,$E8,$00,$00
      DC.B      '6!',$0C,$00,'!-',$00,'!' 
      DC.B      '-"',$06,$08,$A0,' ',$00,'"'
      DC.B      ' ',$00,'@',$06,$09,$A0,' ',$00 
      DC.B      '*\YX]Y',$00,$00
      DC.B      $00,$0C,$0A,$A9,$80,$00,$01,'x' 
      DC.B      $07,$F0,$90,$00,$01,$A8,'8',$04 
      DC.B      $00,$08,'\+m',$E8,$00,'l' 
      DC.B      $D8,$00,'L',$D8,$00,'"',$B6,$00 
      DC.B      $06,$C4,$00,$00,$01,'Ž}',$DC
      DC.B      $00,'~',$DC,$00,$04,'M',$10,$04 
      DC.B      'N',$11,'L',$D8,$00,'N',$D8,$00 
      DC.B      'M',$D9,$00,'O',$D9,$00,'#',$91 
      DC.B      $00,$0D,$00,$D8,$00,$00,$00,$00 
      DC.B      $00,$0C,$07,$F0,$91,$00,$01,$A9 
      DC.B      $07,$F0,$90,$00,$01,$AA,'hY'
      DC.B      $00,$0D,$00,$82,'LY',$00,$0D
      DC.B      $00,'|',$0D,$00,'|hY',$00 
      DC.B      $0D,$00,$82,'LY',$00,$0D,$00
      DC.B      '|',$0D,$00,'|',$0D,$00,'|h'
      DC.B      'Y',$00,'"',$0C,$00,' ',$00,'@' 
      DC.B      ' ',$00,'@',$07,'p',$8C,$00,$01 
      DC.B      $AA,$07,'p',$91,$00,$01,$A9,$00 
      DC.B      $00,$0C,$00,' ',$00,$00,' ',$00 
      DC.B      $00,'!',$0F,$00,$00,$00 
L0065:DC.B      $00,$C2,$00,$00,$00,$16,$00,$18 
      DC.B      $00,'0',$00,'2',$00,$9A,$00,$9C 
      DC.B      $00,$C4,$00,$C6,$00,$DA,$00,$DC 
      DC.B      $01,'Z',$01,'\',$01,'f',$01,'h' 
      DC.B      $01,'n',$01,'p',$01,$82,$FF,$FF 
      DC.B      $00,$C2,$11,$F5,$18,$FA,$15,$15 
      DC.B      $07,$1E,$07,'#',$FA,$1B,$F5,$1D 
      DC.B      $F1,$12,$E7,$11,$E7,$0C,$03,$07 
      DC.B      $03,$F8,$D8,$D1,$D8,$CE,$E3,$CB 
      DC.B      $F3,$CE,$FC,$C5,$00,$C7,$05,$D5 
      DC.B      $03,$DA,$FB,$E7,$F4,$E4,$EE,$DC 
      DC.B      $E4,$D6,$DD,$D1,'.',$82,'/',$8D 
      DC.B      '0',$8C,'0',$9F,'0',$AE,'0',$B8 
      DC.B      '3',$BC,',',$C0,$27,$C5,'$',$C7 
      DC.B      '(',$C9,',',$C8,'+',$CE,'*',$D1 
      DC.B      $27,$D7,'#',$D5,'!',$CC,'!',$D1 
      DC.B      $1D,$CB,$16,$C6,$11,$C6,$15,$C4 
      DC.B      $15,$BD,$11,$BA,$0D,$BB,$0D,$BF 
      DC.B      $0F,$C1,$0B,$C3,$08,$C4,$07,$C3 
      DC.B      $09,$C0,$0B,$BC,$0B,$B8,$0E,$B4 
      DC.B      $12,$B3,$17,$AF,$15,$AE,$10,$B1 
      DC.B      $13,$B0,$13,$AE,$17,$AC,$1B,$A7 
      DC.B      '!',$A7,'$',$A4,$27,$A3,')',$9C 
      DC.B      ')',$93,')',$92,$27,$90,'(',$90 
      DC.B      '(',$8C,',',$89,'-',$8A,$F8,'e' 
      DC.B      $F2,'h',$F0,'j',$EC,'m',$E7,'k' 
      DC.B      $E4,'g',$E4,'e',$E6,'a',$E6,'a' 
      DC.B      $E7,'`',$E9,'\',$E7,'X',$E7,'S' 
      DC.B      $E8,'Q',$EE,'P',$F1,'U',$F3,'W' 
      DC.B      $F6,'Z',$F7,']',$F7,'`',$F3,'c' 
      DC.B      '$',$01,'$',$FD,'#',$FB,'$',$FD 
      DC.B      '&',$FC,$27,$FD,'(',$FB,')',$FD 
      DC.B      '(',$FE,$27,$FE,'%',$01,$19,$FB 
      DC.B      $1A,$F9,$1C,$F9,$1E,$FC,' ',$FE 
      DC.B      '#',$FE,'$',$02,'&',$03,'(',$05 
      DC.B      '(',$07,'&',$07,$27,$0F,')',$11 
      DC.B      '*',$11,',',$0F,'/',$10,'+',$0C 
      DC.B      '(',$0B,')',$07,')',$03,'.',$08 
      DC.B      '1',$0E,'1',$17,'/',$1B,'-',$18 
      DC.B      '0',$1E,'1*31J6'
      DC.B      '3d1',$7F,'.',$7F,'*s'
      DC.B      '$n+r',$27,'`',$1E,'`'
      DC.B      $18,'Y',$15,'U',$0D,'J',$05,'J' 
      DC.B      $05,'G',$05,'E',$0F,'@',$07,'8' 
      DC.B      $0E,'3',$11,'(',$11,'$',$0A,$27 
      DC.B      $0F,$1C,$18,$18,$1A,$19,$1A,$15 
      DC.B      $1D,$12,$1A,$11,$1C,$0E,$1F,$0A 
      DC.B      $1F,$08,$1D,$0C,$1C,$0A,$1F,$05 
      DC.B      $1E,$02,$1C,$00,$1A,$FE,$1D,$18 
      DC.B      $1D,$15,$1E,$13,$1F,$18,' ',$19 
      DC.B      $1E,$1D,$1B,$27,$1B,'"',$1E,'"' 
      DC.B      ' ',$27,$CE,'x',$CA,$95,$CA,$B1 
      DC.B      $CA,$CE,$C7,$D5,$C7,$F8,$C7,$15 
      DC.B      $C7,'1',$C7,'N',$C7,'j' 
L0066:DC.B      $00,$00,$04,'b' 
L0067:DC.B      $00,$14,$44,$DA,
	dc.b	$00,$16,$9C,$DA 
L0068:DC.B      $FF,$FF,$FC,$FC,$FC,$FC,$03,$03 
      DC.B      $F6,$F6,$09,$0B,$F6,$F6,$09,$0B 
      DC.B      $F6,$F6,$09,$0B,$F6,$F6,$09,$0B 
      DC.B      $F7,$F7,$09,$0A,$F8,$F8,$08,$09 
      DC.B      $F9,$F9,$07,$08,$FA,$FA,$06,$07 
      DC.B      $FB,$FB,$05,$06,$FC,$FC,$04,$05 
      DC.B      $FD,$FD,$03,$04,$FD,$FD,$02,$03 
      DC.B      $F7,$F7,$F7,$F7,$E0,$E0,$E0,$D0 
L0069:DC.B      $00,$00,$08,$00,$00,$00,$80,$00 
      DC.B      $08,' ',$00,' ',$FC,$00,$00,'!' 
      DC.B      $00,' ',$FF,$F0,$00,$01,$00,$00 
L006A:DC.B      $01,' ' 
 BSS
L006B:DS.B      1578
L006C:DS.W      1 
L006D:DS.L      1 
L006E:DS.B      6 
L006F:DS.W      1 
L0070:DS.L      1 
L0071:DS.W      1 
L0072:DS.B      8 
L0073:DS.L      1 
L0074:DS.W      1 
L0075:DS.L      1 
L0076:DS.L      1 
L0077:DS.W      1 
L0078:DS.W      1 
L0079:DS.W      1 
L007A:DS.L      1 
L007B:DS.B      6 
L007C:DS.B      1 
L007D:DS.B      2559
L007E:DS.B      2048
L007F:DS.B      512 
L0080:DS.B      36800 
L0081:DS.B      20200 
L0082:DS.B      19800 
L0083:DS.B      1854414 
ZUEND: END
