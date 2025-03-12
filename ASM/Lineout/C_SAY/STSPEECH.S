TIMAVEC		equ	$0134
GISELECT	equ	$ffff8800
GIDATA		equ	$ffff8802
IPRA		equ	$fffffa0b
ISRA		equ	$fffffa0f
IMRA		equ	$fffffa13

 TEXT 
Begin:
; print title..
  PEA       L000A 
  MOVE.W    #9,-(A7)
  TRAP      #1
  ADDQ.L    #6,A7 

; main interpreter loop
INLUP:
; print prompt..
  PEA       L000B 
  MOVE.W    #9,-(A7)
  TRAP      #1
  ADDQ.L    #6,A7 

; get user input..
  MOVE.B    #$FE,L00E6
  PEA       L00E6 
  MOVE.W    #$A,-(A7) 
  TRAP      #1
  ADDQ.L    #6,A7 

; loop if the string is empty..
  LEA       L00E7,A1
  MOVEQ     #0,D0 
  MOVE.B    -1(A1),D0 
  BEQ.S     INLUP 

  CLR.B     0(A1,D0.W)
  MOVE.B    (A1),D0 
  CMPI.B    #$25,D0 ;#"%",d0
  BEQ.S     L0002   ; -> set rate
  CMPI.B    #$21,D0 ;#"!",d0
  BEQ.S     L0003   ; -> set pitch
  CMPI.B    #$2E,D0 ;#".",d0
  BEQ.S     L0004   ; -> toggle english/phoneme mode
  TST.B     L0011   ; test english/phoneme mode
  BPL.S     L0001 
; if in phonetic mode.. call speak directly..
  MOVEA.L   A1,A0 
  BSR       SPEAK 
  BRA.S     INLUP 

; translate english to phoneme..
L0001:
  BSR       TEXTIN
  PEA       L000D 
  MOVE.W    #9,-(A7)
  TRAP      #1
  ADDQ.L    #6,A7 

; echo translated text..
  PEA       PHOBUFF 
  MOVE.W    #9,-(A7)
  TRAP      #1
  ADDQ.L    #6,A7 
  LEA       PHOBUFF,A0
; ..and speak it..
  BSR       SPEAK 
  BRA       INLUP 

L0002:
  BSR       L0007 
  CMPI.B    #$14,D1 
  BLT.S     L0006 
  CMPI.B    #$C8,D1 
  BCC.S     L0006 
  MOVE.B    D1,SET_RATE 
  BRA       INLUP 

L0003:
  BSR       L0007 
  CMPI.B    #$14,D1 
  BLT.S     L0006 
  CMPI.B    #$C8,D1 
  BCC.S     L0006 
  MOVE.B    D1,SET_PITC 
  BRA       INLUP 

; toggle mode..
L0004:
  NOT.B     L0011 
  TST.B     L0011 
  BMI.S     L0005 
  PEA       L000F 
  MOVE.W    #9,-(A7)
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.B    #$3E,L000C
  BRA       INLUP 
L0005:
  PEA       L000E 
  MOVE.W    #9,-(A7)
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.B    #$3A,L000C
  BRA       INLUP 

L0006:
  LEA       L0010,A0
  BSR       SPEAK 
  BRA       INLUP 

L0007:
  ADDQ.L    #1,A1 
  MOVEQ     #0,D1 
L0008:
  MOVE.B    (A1)+,D0
  ANDI.W    #$7F,D0 
  SUBI.W    #$30,D0 
  BLT.S     L0009 
  CMPI.W    #9,D0 
  BGT.S     L0009 
  MULU      #$A,D1
  ADD.W     D0,D1 
  BRA.S     L0008 
L0009:
  RTS 

L000A:
  DC.B      'Atari 52'
  DC.B      '0ST spee'
  DC.B      'ch synth'
  DC.B      'esizer V'
  DC.B      '2.0',$0D,$0A
  dc.b      'hacked by earx 2006',$0D,$0A,$00 
L000B:
  DC.B      $0D,$0A 
L000C:
  DC.B      '>',$00 
L000D:
  DC.B      $0D,$0A,$00 
L000E:
  DC.B      'Phoneme '
  DC.B      'mode.',$0D,$0A,$00 
L000F:
  DC.B      'English '
  DC.B      'text mod'
  DC.B      'e.',$0D,$0A,$00
L0010:
  DC.B      'ehroh>r',$00 
L0011:
  DC.B      $00 

TEXTIN
  LEA       TYPETAB,A3
  LEA       L00E4,A0
  JSR       to_upper
  LEA       PHOBUFF,A2
CONVWORD
  LEA       L0044,A1
  MOVE.B    (A0),D0 
  BNE.S     MORETODO
  MOVE.L    #PHOBUFF,D0 
  RTS 
MORETODO
  EXT.W     D0
  BTST      #0,0(A3,D0.W) 
  BNE.S     L0015 
  MOVE.W    #$40,D0 
L0015:
  SUBI.W    #$40,D0 
  ADD.W     D0,D0 
  ADDA.W    0(A1,D0.W),A1 
  BRA.S     L0017 
NOMATCH:
  TST.B     (A1)+ 
  BNE.S     NOMATCH 
L0017:
  MOVEA.L   A0,A4 
L0018:
  TST.B     (A4)
  BEQ.S     NOMATCH 
  MOVE.B    (A1),D0 
  BCLR      #7,D0 
  CMP.B     (A4)+,D0
  BNE.S     NOMATCH 
  TST.B     (A1)+ 
  BPL.S     L0018 
  MOVEA.L   A0,A5 
L0019:
  MOVE.B    (A1),D0 
  BCLR      #7,D0 
  EXT.W     D0
  BEQ.S     L001B 
  CMPI.B    #9,D0 
  BGT.S     L001A 
  BSR       L0020 
  BEQ.S     NOMATCH 
  BRA.S     L001B 
L001A:
  CMP.B     -(A5),D0
  BNE.S     NOMATCH 
L001B:
  TST.B     (A1)+ 
  BPL.S     L0019 
  MOVEA.L   A4,A5 
L001C:
  MOVE.B    (A1),D0 
  BCLR      #7,D0 
  EXT.W     D0
  BEQ.S     L001E 
  CMPI.B    #9,D0 
  BGT.S     L001D 
  BSR       L002D 
  BEQ.S     NOMATCH 
  BRA.S     L001E 
L001D:
  CMP.B     (A5)+,D0
  BNE.S     NOMATCH 
L001E:
  TST.B     (A1)+ 
  BPL.S     L001C 
GOTMATCH
  MOVE.B    (A1)+,(A2)+ 
  BNE.S     GOTMATCH
  SUBQ.L    #1,A2 
  MOVEA.L   A4,A0 
  BRA       CONVWORD
L0020:
  MOVE.B    -(A5),D1
  EXT.W     D1
  SUBQ.B    #1,D0 
  BNE.S     L0021 
  BTST      #0,0(A3,D1.W) 
  EORI.B    #4,CCR
  RTS 
L0021:
  SUBQ.B    #1,D0 
  BNE.S     L0022 
  BTST      #1,0(A3,D1.W) 
  RTS 
L0022:
  SUBQ.B    #1,D0 
  BNE.S     L0023 
  BTST      #2,0(A3,D1.W) 
  RTS 
L0023:
  SUBQ.B    #1,D0 
  BNE.S     L0024 
  BTST      #4,0(A3,D1.W) 
  RTS 
L0024:
  SUBQ.L    #1,D0 
  BNE.S     L0028 
  BTST      #3,0(A3,D1.W) 
  BNE.S     L0026 
  CMPI.B    #$48,D1 
  BNE.S     L0027 
  MOVE.B    -(A5),D1
  CMPI.B    #$43,D1 
  BEQ.S     L0025 
  CMPI.B    #$53,D1 
  BNE.S     L0027 
L0025:
  MOVEQ     #$FFFFFFFF,D1 
L0026:
  RTS 
L0027:
  MOVEQ     #0,D1 
  RTS 
L0028:
  SUBQ.B    #1,D0 
  BNE.S     L0029 
  BTST      #5,0(A3,D1.W) 
  BNE.S     L0026 
  CMPI.B    #$48,D1 
  BNE.S     L0027 
  MOVE.B    -(A5),D1
  CMPI.B    #$43,D1 
  BEQ.S     L0025 
  CMPI.B    #$53,D1 
  BEQ.S     L0025 
  CMPI.B    #$54,D1 
  BEQ.S     L0025 
  BRA.S     L0027 
L0029:
  SUBQ.B    #1,D0 
  BNE.S     L002A 
  CMPI.B    #$45,D1 
  BEQ.S     L0025 
  CMPI.B    #$49,D1 
  BEQ.S     L0025 
  CMPI.B    #$59,D1 
  BEQ.S     L0025 
  BRA.S     L0027 
L002A:
  SUBQ.B    #1,D0 
  BNE.S     L002C 
  ADDQ.L    #1,A5 
L002B:
  MOVE.B    -(A5),D1
  EXT.W     D1
  BTST      #2,0(A3,D1.W) 
  BNE.S     L002B 
  ADDQ.L    #1,A5 
  BRA.S     L0025 
L002C:
  ILLEGAL 
L002D:
  MOVE.B    (A5)+,D1
  EXT.W     D1
  SUBQ.B    #1,D0 
  BNE.S     L002E 
  BTST      #0,0(A3,D1.W) 
  EORI.B    #4,CCR
  RTS 
L002E:
  SUBQ.B    #1,D0 
  BNE.S     L002F 
  BTST      #1,0(A3,D1.W) 
  RTS 
L002F:
  SUBQ.B    #1,D0 
  BNE.S     L0030 
  BTST      #2,0(A3,D1.W) 
  RTS 
L0030:
  SUBQ.B    #1,D0 
  BNE.S     L0031 
  BTST      #4,0(A3,D1.W) 
  RTS 
L0031:
  SUBQ.L    #1,D0 
  BNE.S     L0035 
  BTST      #3,0(A3,D1.W) 
  BNE.S     L0033 
  CMPI.B    #$48,D1 
  BNE.S     L0034 
  MOVE.B    (A5)+,D1
  CMPI.B    #$43,D1 
  BEQ.S     L0032 
  CMPI.B    #$53,D1 
  BNE.S     L0034 
L0032:
  MOVEQ     #$FFFFFFFF,D1 
L0033:
  RTS 
L0034:
  MOVEQ     #0,D1 
  RTS 
L0035:
  SUBQ.B    #1,D0 
  BNE.S     L0036 
  BTST      #5,0(A3,D1.W) 
  BNE.S     L0033 
  CMPI.B    #$48,D1 
  BNE.S     L0034 
  MOVE.B    (A5)+,D1
  CMPI.B    #$43,D1 
  BEQ.S     L0032 
  CMPI.B    #$53,D1 
  BEQ.S     L0032 
  CMPI.B    #$54,D1 
  BEQ.S     L0032 
  BRA.S     L0034 
L0036:
  SUBQ.B    #1,D0 
  BNE.S     L0037 
  CMPI.B    #$45,D1 
  BEQ.S     L0032 
  CMPI.B    #$49,D1 
  BEQ.S     L0032 
  CMPI.B    #$59,D1 
  BEQ.S     L0032 
  BRA.S     L0034 
L0037:
  SUBQ.B    #1,D0 
  BNE.S     L0039 
  SUBQ.L    #1,A5 
L0038:
  MOVE.B    (A5)+,D1
  EXT.W     D1
  BTST      #2,0(A3,D1.W) 
  BNE.S     L0038 
  SUBQ.L    #1,A5 
  BRA.S     L0032 
L0039:
  SUBQ.B    #1,D0 
  BNE       L002C 
  CMPI.B    #$49,D1 
  BNE.S     L003C 
  CMPI.B    #$4E,(A5)+
  BNE.S     L003B 
  CMPI.B    #$47,(A5)+
  BNE.S     L003B 
L003A:
  MOVEQ     #$FFFFFFFF,D1 
  RTS 
L003B:
  MOVEQ     #0,D1 
  RTS 
L003C:
  CMPI.B    #$45,D1 
  BNE.S     L003B 
  MOVE.B    (A5)+,D1
  CMPI.B    #$52,D1 
  BEQ.S     L003A 
  CMPI.B    #$53,D1 
  BEQ.S     L003A 
  CMPI.B    #$44,D1 
  BEQ.S     L003A 
  CMPI.B    #$4C,D1 
  BNE.S     L003D 
  CMPI.B    #$59,(A5)+
  BEQ.S     L003A 
  BRA.S     L003B 
L003D:
  CMPI.B    #$46,D1 
  BNE.S     L003B 
  CMPI.B    #$55,(A5)+
  BNE.S     L003B 
  CMPI.B    #$4C,(A5)+
  BEQ.S     L003A 
  BRA.S     L003B 

; uppercase conversion..
to_upper:
  MOVEM.L   A0-A1,-(A7) 
  MOVEQ     #0,D0 
  MOVE.B    #$20,L00E3
L003F:
  MOVE.B    (A1)+,D0
  ANDI.B    #$7F,D0 
  BEQ.S     L0041 
  CMPI.B    #$60,D0 
  BLT.S     L0040 
  ANDI.B    #$5F,D0 
L0040:
  TST.B     0(A3,D0.W)
  BEQ.S     L0042 
L0041:
  MOVE.B    D0,(A0)+
L0042:
  TST.B     D0
  BNE.S     L003F 
  MOVEM.L   (A7)+,A0-A1 
  RTS 

TYPETAB:
  DCB.W     16,0
  DC.B      '@@@@@@@@'
  DC.B      $00,$00,'@@@@@@'
  DC.B      $80,$80,$80,$80,$80,$80,$80,$80 
  DC.B      $80,$80,'@@@@@@'
  DC.B      '@',$03,$15,$0D,'5',$03,$05,$1D 
  DC.B      $05,$03,'=',$05,'%',$15,'5',$03 
  DC.B      $05,$05,'5-%',$03,$15,$15 
  DC.B      $0D,$03,'=',$00,$00,'@',$00,$00 
  DC.B      $A0,$80,$80,' ',$00,$A1,$80,$80 
  DC.B      '.',$00,$A2,$80,$81,'-AH' 
  DC.B      '1NKWOWT-'
  DC.B      $00,$A2,$80,$80,'KWOW'
  DC.B      '2T-',$00,$A3,$80,$80,' ' 
  DC.B      'NUH2MBER'
  DC.B      $00,$A4,$80,$80,' DOH'
  DC.B      '2LER',$00,$A5,$80,$80
  DC.B      ' PUHSEH2'
  DC.B      'NT',$00,$A6,$80,$80,' A' 
  DC.B      'END',$00,$27,$D3,$80,$81 
  DC.B      'Z',$00,$27,$CD,$80,$80,'M',$00 
  DC.B      $27,$C4,$80,$80,'D',$00,$A7,$80 
  DC.B      $80,$00,$AA,$80,$80,' AE' 
  DC.B      '2STERIHS'
  DC.B      'K',$00,$AB,$80,$80,' PL' 
  DC.B      'UH2S',$00,$AC,$80,$80
  DC.B      ',',$00,$AD,$81,$81,'-',$00,$AD 
  DC.B      $80,$80,$00,$AE,$81,$81,' P'
  DC.B      'OYNT',$00,$AE,$80,$80
  DC.B      '.',$00,$AF,$80,$80,' SL' 
  DC.B      'AE2SH',$00,'52'
  DC.B      '0S',$D4,$81,$81,'FAY'
  DC.B      'V TWEHNT'
  DC.B      'IY EHS T'
  DC.B      'IY',$00,'1040S'
  DC.B      $D4,$81,$81,'TEHN ' 
  DC.B      'FOHRTIY '
  DC.B      'EHS TIY',$00 
  DC.B      $B0,$80,$80,' ZIH2' 
  DC.B      'ROW',$00,'1S',$D4,$81
  DC.B      $80,'FER2ST',$00
  DC.B      '10T',$C8,$81,$80,'TE'
  DC.B      'H2NTH',$00,$B1,$80 
  DC.B      $80,' WAH2N',$00
  DC.B      '2N',$C4,$81,$80,'SEH'
  DC.B      '2KUND',$00,$B2,$80 
  DC.B      $80,' TUW2',$00,'3' 
  DC.B      'R',$C4,$81,$80,'THER'
  DC.B      '2D',$00,$B3,$80,$80,' T' 
  DC.B      'HRIY2',$00,$B4,$80 
  DC.B      $80,' FOH2R',$00
  DC.B      '5T',$C8,$81,$80,'FIH'
  DC.B      '2FTH',$00,$B5,$80,$80
  DC.B      ' FAY2V',$00,$B6
  DC.B      $80,$80,' SIH2K'
  DC.B      'S',$00,$B7,$80,$80,' SE' 
  DC.B      'H2VUN',$00,'8T'
  DC.B      $C8,$81,$80,'EY2TH' 
  DC.B      $00,$B8,$80,$80,' EY2'
  DC.B      'T',$00,$B9,$80,$80,' NA' 
  DC.B      'Y2N',$00,$BA,$80,$80,'.' 
  DC.B      $00,$BB,$80,$80,'.',$00,$BC,$80 
  DC.B      $80,' LEH2S ' 
  DC.B      'DHAEN',$00,$BD,$80 
  DC.B      $80,' IY2KWU' 
  DC.B      'LZ',$00,$BE,$80,$80,' G' 
  DC.B      'REY2TER '
  DC.B      'DHAEN',$00,$BF,$80 
  DC.B      $80,'?',$00,$C0,$80,$80,' A'
  DC.B      'E1T',$00,$DE,$80,$80,' ' 
  DC.B      'KAE2RUHT'
  DC.B      $00,'A',$AE,$81,$80,'EY1' 
  DC.B      ' ',$00,$C1,$81,$81,'AE1' 
  DC.B      $00,$C1,$80,$81,'UH1',$00 
  DC.B      'ANSWE',$D2,$81,$80 
  DC.B      'ARNSER',$00,'A'
  DC.B      'RCHI',$D6,$81,$80,'A'
  DC.B      'R1KAYV',$00,'A'
  DC.B      'LL',$D9,$08,$82,$80,'UL' 
  DC.B      'IY',$00,'A',$CC,$81,$82,'U'
  DC.B      'L',$00,'AR',$C5,$81,$81,'A'
  DC.B      'RR',$00,'A',$D2,$81,$CF,'A'
  DC.B      'XR',$00,'A',$D2,$80,$82,'E'
  DC.B      'H2R',$00,'A',$D3,$D6,$82 
  DC.B      'ARZ',$00,'A',$D3,$03,$81 
  DC.B      $82,'EY2S',$00,$C1,$80
  DC.B      'W',$C1,'AE',$00,'A',$D7,$80
  DC.B      $80,'AO1',$00,'AN',$D9
  DC.B      $08,$81,$80,'EH2NI' 
  DC.B      'Y',$00,'APR',$C9,$81,$80 
  DC.B      'EYPRIH',$00,$C1
  DC.B      $80,'C',$C5,'EY1',$00,$C1 
  DC.B      $80,$03,$07,$82,'EY1',$00 
  DC.B      'AGAI',$CE,$80,$80,'A'
  DC.B      'XGEH2N',$00,'A'
  DC.B      $C7,$08,$82,$C5,'IHJ',$00 
  DC.B      $C1,$80,$03,$89,'EY',$00,$C1
  DC.B      $80,$03,$07,$08,$82,'AE',$00
  DC.B      $C1,$08,$81,$03,$07,$81,'EY'
  DC.B      '2',$00,'AR',$D2,$81,$80,'A'
  DC.B      'XR',$00,'AR',$D2,$80,$80 
  DC.B      'AE2R',$00,'A',$D2,$03
  DC.B      $81,$81,'AA1R',$00,'A'
  DC.B      $D2,$80,$80,'AA1R',$00
  DC.B      'AI',$D2,$80,$80,'EH2'
  DC.B      'R',$00,'A',$C9,$80,$80,'EY'
  DC.B      '2',$00,'A',$D9,$80,$80,'EY'
  DC.B      '1',$00,'A',$D5,$80,$80,'AO'
  DC.B      '2',$00,'A',$CC,$08,$82,$81,'U' 
  DC.B      'L',$00,'AL',$D3,$08,$82,$81
  DC.B      'ULZ',$00,'AL',$CB,$80
  DC.B      $80,'AO2K',$00,'A',$CC
  DC.B      $80,$86,'AOL',$00,'A',$CC 
  DC.B      $80,$85,'AEL',$00,'A',$CC 
  DC.B      $80,$84,'AOL',$00,'A',$CC 
  DC.B      $80,$83,'AEL',$00,'AB'
  DC.B      'L',$C5,$08,$81,$80,'EY2' 
  DC.B      'BUL',$00,'ABL',$C5 
  DC.B      $80,$80,'AXBUL',$00 
  DC.B      $C1,$81,'VI',$C1,'EY1'
  DC.B      $00,$C1,$81,'VAE2',$00
  DC.B      $C1,$80,'V',$CF,'EY2',$00 
  DC.B      'AN',$C7,$80,$87,'EY2'
  DC.B      'NJ',$00,'ATAR',$C9 
  DC.B      $80,$80,'UHTAR1'
  DC.B      'RIY',$00,$C1,$80,'TO'
  DC.B      $CD,'AE',$00,$C1,$80,'TT' 
  DC.B      $82,'AE',$00,'A',$D4,$81,$81
  DC.B      'AET',$00,$C1,$81,$D4,'U' 
  DC.B      'H',$00,'AT',$C5,$80,$81,'E'
  DC.B      'Y1T',$00,$C1,$80,'PA'
  DC.B      $C2,'EY1',$00,$C1,$80,$80 
  DC.B      'AE',$00,$C2,$81,$81,'BI' 
  DC.B      'Y2',$00,'B',$C5,$81,$03,$82
  DC.B      'BIH',$00,'BEIN'
  DC.B      $C7,$80,$80,'BIY2I' 
  DC.B      'HNX',$00,'BOT',$C8 
  DC.B      $81,$81,'BOW2TH'
  DC.B      $00,'BU',$D3,$81,$82,'BI' 
  DC.B      'H2Z',$00,'BREA'
  DC.B      $CB,$80,$80,'BREY1' 
  DC.B      'K',$00,'BUI',$CC,$80,$80 
  DC.B      'BIH2L',$00,$C2,'M' 
  DC.B      $82,$81,$00,$C2,$C2,$80,$00,$C2 
  DC.B      $80,$80,'B',$00,$C3,$81,$81,'S' 
  DC.B      'IY2',$00,'CLIM'
  DC.B      $C2,$80,$80,'KLAYM' 
  DC.B      $00,$C3,$C3,$80,$00,'COV' 
  DC.B      $C5,$80,$81,'KOWV',$00
  DC.B      'C',$C8,$03,$82,$C9,'K',$00,'C' 
  DC.B      $C8,$81,$83,'K',$00,'C',$C8,'E' 
  DC.B      $83,$80,'K',$00,'CH',$C1,$80
  DC.B      'R',$82,'KEH1',$00,'C'
  DC.B      $C8,$80,$80,'CH',$00,'C',$C9
  DC.B      'S',$81,$82,'SAY2',$00
  DC.B      'C',$C9,$80,$C1,'SH',$00,'C'
  DC.B      $C9,$80,$CF,'SH',$00,'C',$C9
  DC.B      $80,'E',$CE,'SH',$00,'CI' 
  DC.B      'T',$D9,$80,$80,'SIHT'
  DC.B      'IY',$00,'C',$C5,$80,'D',$82
  DC.B      'SIY',$00,$C3,$80,$87,'S' 
  DC.B      $00,'C',$CB,$80,$80,'K',$00,'C' 
  DC.B      'OM',$C2,$80,$81,'KOW'
  DC.B      'M',$00,'COM',$C5,$80,$80 
  DC.B      'KUHM',$00,'CO',$D5 
  DC.B      $81,'R',$82,'KUH',$00,'C' 
  DC.B      'UI',$D4,$80,$80,'KIH'
  DC.B      'T',$00,'CREAT',$C5 
  DC.B      $80,$80,'KRIYEY'
  DC.B      'T',$00,'C',$C3,$80,$87,'KS'
  DC.B      $00,'CQ',$D5,$80,$80,'KW' 
  DC.B      $00,$C3,$80,$80,'K',$00,$C4,$81 
  DC.B      $81,'DIY2',$00,'DR' 
  DC.B      $AE,$81,$81,'DOHKT' 
  DC.B      'ER',$00,'DE',$C4,$08,$82 
  DC.B      $81,'DIHD',$00,'D',$C5
  DC.B      $81,'T',$82,'DIY',$00,'D' 
  DC.B      $CA,$80,$80,'J',$00,$C4,'E',$84 
  DC.B      $81,'D',$00,$C4,$C4,$80,$00,'D' 
  DC.B      $C5,$81,'L',$82,'DIH',$00 
  DC.B      'D',$CF,$81,$81,'DUW',$00 
  DC.B      'DOE',$D3,$81,$80,'DA'
  DC.B      'HZ',$00,'DON',$C5,$80
  DC.B      $81,'DAH1N',$00,'D' 
  DC.B      'OIN',$C7,$80,$80,'DU'
  DC.B      'W2IHNX',$00,'D'
  DC.B      'O',$D7,$81,$80,'DAW',$00 
  DC.B      $C4,$80,$80,'D',$00,$C5,$81,$81 
  DC.B      'IY2',$00,'ERRO'
  DC.B      $D2,$80,$80,'EHROH' 
  DC.B      '1R',$00,'ENGLA'
  DC.B      'N',$C4,$80,$80,'IH2N'
  DC.B      'XGLAEND',$00 
  DC.B      $C5,$D2,$85,'EH',$00,$C5,$08
  DC.B      $82,$81,$00,$C5,$08,$81,$81,'I' 
  DC.B      'Y',$00,'E',$C4,$82,$81,'D',$00 
  DC.B      $C5,$08,$82,'D',$81,$00,'E',$D6 
  DC.B      $80,'E',$D2,'EH2V',$00
  DC.B      'E',$D7,$D2,$81,'UW',$00,'E'
  DC.B      $D7,$D2,$89,'UW',$00,'E',$D7
  DC.B      $CC,$81,'UW',$00,'E',$D7,$CC
  DC.B      $89,'UW',$00,'E',$D7,$80,$81
  DC.B      'YUW',$00,'E',$D7,$80,$89 
  DC.B      'YUW',$00,$C5,$80,$03,$89 
  DC.B      'IY2',$00,'ER',$C9,$80
  DC.B      $82,'IY2RIY',$00
  DC.B      'ER',$C9,$80,$80,'EH2'
  DC.B      'RIH',$00,'ERAS'
  DC.B      $C5,$80,$80,'IHREY' 
  DC.B      '1S',$00,'E',$D2,$08,$82,$82
  DC.B      'ER',$00,'E',$D2,$80,$82,'E'
  DC.B      'HR',$00,'E',$D2,$80,$80,'E'
  DC.B      'R',$00,'EVE',$CE,$81,$80 
  DC.B      'IYVUHN',$00,'E'
  DC.B      $D7,$80,$80,'YUW',$00,$C5 
  DC.B      $80,$CF,'IY',$00,'E',$D3,$05
  DC.B      $08,$82,$81,'IHZ',$00,$C5 
  DC.B      $08,$82,'S',$81,$00,'EL',$D9
  DC.B      $08,$82,$81,'LIY',$00,'E' 
  DC.B      'MEN',$D4,$08,$82,$80,'M' 
  DC.B      'EHNT',$00,'EFU'
  DC.B      $CC,$80,$80,'FUHL',$00
  DC.B      'E',$C5,$80,$80,'IY2',$00 
  DC.B      'EAR',$CE,$80,$80,'ER'
  DC.B      '1N',$00,'EA',$D2,$81,$83 
  DC.B      'ER1',$00,'EA',$C4,$80
  DC.B      $80,'EHD',$00,'E',$C1,$08 
  DC.B      $82,$81,'IYAX',$00,'E'
  DC.B      $C1,$80,'S',$D5,'EH1',$00 
  DC.B      'E',$C1,$80,$80,'IY1',$00 
  DC.B      'EIG',$C8,$80,$80,'EY'
  DC.B      '2',$00,'E',$C9,$80,$80,'IY'
  DC.B      '2',$00,'EY',$C5,$81,$80,'A'
  DC.B      'Y2',$00,'E',$D9,$80,$80,'I'
  DC.B      'Y',$00,'E',$D5,$80,$80,'YU'
  DC.B      'W1',$00,'EQUA',$CC 
  DC.B      $80,$80,'IY2KWU'
  DC.B      'L',$00,$C5,$80,$80,'EH',$00
  DC.B      $C6,$81,$81,'EH2F',$00
  DC.B      'FRIEN',$C4,$80,$80 
  DC.B      'FREH1ND',$00 
  DC.B      'FATHE',$D2,$80,$80 
  DC.B      'FAA2DHER'
  DC.B      $00,$C6,$C6,$80,$00,$C6,$80,$80 
  DC.B      'F',$00,$C7,$81,$81,'JIY' 
  DC.B      '2',$00,'GI',$D6,$80,$80,'G'
  DC.B      'IH1V',$00,'GUR'
  DC.B      'E',$C4,$80,$81,'GERD'
  DC.B      $00,$C7,$81,'I',$83,'G',$00,'G' 
  DC.B      $C5,$80,$D4,'GEH1',$00
  DC.B      'GGE',$D3,'U',$D3,$80,'J' 
  DC.B      'IH2S',$00,'G',$C7,$80
  DC.B      $80,'G',$00,$C7,$02,'B',$81,$80 
  DC.B      'G',$00,$C7,$80,$87,'J',$00,'G' 
  DC.B      'REA',$D4,$80,$80,'GR'
  DC.B      'EY2T',$00,'GO',$CE 
  DC.B      $80,$C5,'GOH1N',$00 
  DC.B      'G',$C8,$82,$80,$00,'G',$CE,$81 
  DC.B      $80,'N',$00,$C7,$80,$80,'G',$00 
  DC.B      $C8,$81,$81,'/HEY2' 
  DC.B      'CH',$00,'HA',$D6,$81,$80 
  DC.B      '/HAE1V',$00,'H'
  DC.B      'ER',$C5,$81,$80,'/HI'
  DC.B      'YR',$00,'HOU',$D2,$81
  DC.B      $80,'AW1ER',$00,'H' 
  DC.B      'O',$D7,$80,$80,'/HAW'
  DC.B      $00,$C8,$80,$82,'/H',$00,$C8
  DC.B      $80,$80,$00,$C9,$81,$81,'AY'
  DC.B      '2',$00,$C9,'ME',$D3,$80,'I'
  DC.B      'Y',$00,$C9,'TNA',$81,$80 
  DC.B      'IY',$00,$C9,$80,'NDO'
  DC.B      $D7,'IH',$00,'INDL' 
  DC.B      'E',$81,$80,$80,'IH1N'
  DC.B      'DUL',$00,$C9,$83,'DE'
  DC.B      $CE,'IH',$00,'I',$CE,$81,$80
  DC.B      'IN',$00,$C9,$80,$81,'AY' 
  DC.B      $00,'IF',$D9,$80,$80,'IH' 
  DC.B      'FAY',$00,'I',$CE,$80,$C4 
  DC.B      'AY1N',$00,'IE',$D2 
  DC.B      $80,$80,'IYER',$00,'I'
  DC.B      'E',$C4,'R',$08,$82,$81,'IY'
  DC.B      'D',$00,'IE',$C4,$80,$81,'A'
  DC.B      'Y1D',$00,'IE',$CE,$80
  DC.B      $80,'IYEHN',$00,'I' 
  DC.B      $C5,$80,$D4,'AY2EH' 
  DC.B      $00,$C9,$08,$81,$03,$89,'AY'
  DC.B      '1',$00,'I',$C5,$08,$81,$81,'A' 
  DC.B      'Y2',$00,$C9,$80,$89,'IY' 
  DC.B      $00,'I',$C5,$80,$80,'IY2' 
  DC.B      $00,'IDE',$C1,$81,$80,'A' 
  DC.B      'YDIY1AH',$00 
  DC.B      'I',$C4,$81,$C5,'AYD',$00 
  DC.B      $C9,$80,$03,$07,$08,$82,'IH'
  DC.B      $00,'I',$D2,$80,$82,'AYR' 
  DC.B      $00,'I',$DA,$80,$89,'AYZ' 
  DC.B      $00,'I',$D3,$80,$89,'AYZ' 
  DC.B      $00,$C9,$03,$C9,$03,$82,'IH'
  DC.B      $00,'IL',$C5,$80,$80,'AY' 
  DC.B      'L',$00,$C9,$03,$08,$82,$03,$87 
  DC.B      'IH',$00,$C9,$08,$87,$03,$87
  DC.B      'AY',$00,$C9,$80,$03,$87,'A'
  DC.B      'Y',$00,'I',$D2,$80,$80,'ER'
  DC.B      $00,'IG',$C8,$80,$80,'AY' 
  DC.B      '2',$00,'IL',$C4,$80,$80,'A'
  DC.B      'Y1LD',$00,'IG',$CE 
  DC.B      $81,$80,'IHGN',$00,'I'
  DC.B      'G',$CE,$80,$81,'AY2N'
  DC.B      $00,'IG',$CE,$80,$83,'AY' 
  DC.B      '2N',$00,'IG',$CE,$80,$89 
  DC.B      'AY2N',$00,'ICR'
  DC.B      $CF,$80,$80,'AY2KR' 
  DC.B      'OH',$00,'IQU',$C5,$80
  DC.B      $80,'IY2K',$00,$C9,$80
  DC.B      $80,'IH',$00,$CA,$81,$81,'J'
  DC.B      'EY2',$00,'JUL',$D9 
  DC.B      $81,$80,'JUWLAY'
  DC.B      $00,$CA,$80,$80,'J',$00,$CB,$81 
  DC.B      $81,'KEY2',$00,$CB,$81
  DC.B      $CE,$00,$CB,$80,$80,'K',$00,$CC 
  DC.B      $81,$81,'EH2L',$00,'L'
  DC.B      $CF,$80,'C',$82,'LOW',$00 
  DC.B      'L',$C9,$81,'BR',$C1,'LA' 
  DC.B      'Y1',$00,'L',$C9,$81,'A',$C9
  DC.B      'LIY1',$00,'L',$C9,$81
  DC.B      $82,'LAY1',$00,$CC,$CC
  DC.B      $80,$00,$CC,$03,$08,$82,$89,'U' 
  DC.B      'L',$00,'L',$C5,$80,$81,'UL'
  DC.B      $00,'LEA',$C4,$80,$80,'L' 
  DC.B      'IYD',$00,'LAUG'
  DC.B      $C8,$81,$80,'LAE2F' 
  DC.B      $00,$CC,$80,$80,'L',$00,$CD,$81 
  DC.B      $81,'EH2M',$00,'M',$C5
  DC.B      $81,$81,'MIY2',$00,'M'
  DC.B      'R',$AE,$81,$81,'MIH2'
  DC.B      'STER',$00,'MS',$AE 
  DC.B      $81,$80,'MIH1Z',$00 
  DC.B      'MRS',$AE,$81,$81,'MI'
  DC.B      'H2SIXZ',$00,'M'
  DC.B      'O',$D6,$80,$80,'MUW2'
  DC.B      'V',$00,'MACHI',$CE 
  DC.B      $80,$80,'MAHSHI'
  DC.B      'Y1N',$00,$CD,$CD,$80,$00 
  DC.B      $CD,$80,$80,'M',$00,$CE,$81,$81 
  DC.B      'EH2N',$00,'N',$C7,$C5
  DC.B      $87,'NJ',$00,'N',$C7,$80,$D2
  DC.B      'NXG',$00,'N',$C7,$80,$82 
  DC.B      'NXG',$00,'NG',$CC,$80
  DC.B      $89,'NXGUL',$00,'N' 
  DC.B      'GU',$C5,$80,$80,'NX',$00 
  DC.B      'N',$C7,$80,$80,'NX',$00,'N'
  DC.B      $CB,$80,$80,'NXK',$00,'N' 
  DC.B      'O',$D6,$81,$80,'NAOV'
  DC.B      $00,'NO',$D7,$81,$81,'NA' 
  DC.B      'W2',$00,$CE,$CE,$80,$00,'N'
  DC.B      'ON',$C5,$80,$80,'NAH'
  DC.B      '2N',$00,$CE,$80,$80,'N',$00
  DC.B      $CF,$81,$81,'OW2',$00,'O' 
  DC.B      $C6,$80,$81,'OHV',$00,'O' 
  DC.B      'F',$C6,$80,$80,'OH1F'
  DC.B      $00,'O',$CB,$81,$81,'OWK' 
  DC.B      'EY1',$00,'O',$C8,$81,$81 
  DC.B      'OW1',$00,'OROU'
  DC.B      'G',$C8,$80,$80,'UHRU'
  DC.B      'H1',$00,'O',$D2,$08,$82,$81
  DC.B      'ER',$00,'OR',$D3,$08,$82 
  DC.B      $81,'ERZ',$00,'O',$D2,$80 
  DC.B      $80,'AOR',$00,'ON',$C5
  DC.B      $81,$80,'WAHN',$00,$CF
  DC.B      'R',$D0,'V',$C5,'UW2',$00 
  DC.B      'ON',$C5,$82,$81,'WAH'
  DC.B      'N',$00,'OV',$C5,'L',$81,$81
  DC.B      'UHV',$00,$CF,$80,$03,'E' 
  DC.B      'ÅOW1',$00,'O',$D7,$80
  DC.B      $80,'OW',$00,'OVE',$D2
  DC.B      $81,$80,'OW1VER'
  DC.B      $00,$CF,$80,$03,$89,'OW1' 
  DC.B      $00,'O',$D6,$80,$80,'AH2' 
  DC.B      'V',$00,$CF,$80,$03,'E',$CE,'O' 
  DC.B      'W',$00,$CF,$80,$03,'I',$C5,'A' 
  DC.B      'A1',$00,$CF,$80,$03,'I',$82
  DC.B      'OW1',$00,'O',$CC,$80,$C4 
  DC.B      'OW2L',$00,'OUG'
  DC.B      'H',$D4,$80,$80,'OH1R'
  DC.B      'T',$00,'OUG',$C8,$80,$80 
  DC.B      'OH1F',$00,'OUG'
  DC.B      $C8,'R',$81,$80,'UH1F'
  DC.B      $00,'OUG',$C8,'T',$81,$80 
  DC.B      'UH1F',$00,'OUG'
  DC.B      $C8,$80,$80,'OH1F',$00
  DC.B      'O',$D5,$81,$80,'AW',$00,'O'
  DC.B      $D5,$C8,'S',$82,'AW2',$00 
  DC.B      'OUS',$C5,$80,$80,'AW'
  DC.B      'S',$00,'OU',$D3,$80,$80,'A'
  DC.B      'XS',$00,'OU',$D2,'L',$C6 
  DC.B      $80,'AWER',$00,'OU' 
  DC.B      $D2,$C6,$80,'OH1R',$00
  DC.B      'OU',$D2,$80,$C3,'OH1'
  DC.B      'R',$00,'OU',$D2,$D4,$80,'U'
  DC.B      'W1R',$00,'OU',$D2,$D0
  DC.B      $80,'OH1R',$00,'OU' 
  DC.B      $D2,$D9,$80,'OH1R',$00
  DC.B      'OU',$D2,$80,$80,'ER1'
  DC.B      $00,'OUL',$C4,$CD,$80,'A' 
  DC.B      'O1LD',$00,'OUL'
  DC.B      $C4,$80,'E',$D2,'AO1L'
  DC.B      'D',$00,'OUL',$C4,$80,$80 
  DC.B      'UX1D',$00,'O',$D5,$80
  DC.B      $03,$CC,'AH1',$00,'OU'
  DC.B      $D0,$80,$80,'UW1P',$00
  DC.B      'O',$D5,$80,$80,'AW',$00,'O'
  DC.B      $D9,$80,$80,'OY',$00,'OI' 
  DC.B      'N',$C7,$C7,$80,'OW2I'
  DC.B      'HNX',$00,'OIN',$C7 
  DC.B      $80,$80,'OYNX',$00,'O'
  DC.B      'O',$D2,$80,$80,'OH1R'
  DC.B      $00,'OO',$CB,$80,$80,'UX' 
  DC.B      '1K',$00,'OO',$C4,$C6,$80 
  DC.B      'UW1D',$00,'OO',$C4 
  DC.B      $CC,$80,'UH1D',$00,'O'
  DC.B      'O',$C4,$CD,$80,'UW1D'
  DC.B      $00,'OO',$C4,$80,$80,'UX' 
  DC.B      '1D',$00,'OO',$D4,$C6,$80 
  DC.B      'UX1T',$00,'O',$CF,$80
  DC.B      $80,'UW1',$00,'O',$A7,$80 
  DC.B      $80,'OH',$00,'OE',$D5,$80 
  DC.B      $80,'UX1',$00,$CF,$80,$C5 
  DC.B      'OW',$00,$CF,$80,$81,'OW' 
  DC.B      $00,'OE',$D3,$80,$81,'OW' 
  DC.B      'Z',$00,'O',$C1,$80,$80,'OW'
  DC.B      '2',$00,'ONL',$D9,$81,$80 
  DC.B      'OW2NLIY',$00 
  DC.B      'ONC',$C5,$81,$80,'WA'
  DC.B      'H2NS',$00,'ON',$27 
  DC.B      $D4,$80,$80,'OW2NT' 
  DC.B      $00,$CF,$C3,$CE,'AA',$00,$CF
  DC.B      $80,'N',$C7,'OH',$00,$CF,$03
  DC.B      $08,$81,$CE,'OH',$00,'O',$CE
  DC.B      $C9,$80,'UN',$00,'O',$CE,$08
  DC.B      $82,$81,'UN',$00,'O',$CE,$03
  DC.B      $82,$80,'UN',$00,$CF,$80,'S'
  DC.B      'TÅOW',$00,'O',$C6,$80
  DC.B      $83,'AO2F',$00,'OT' 
  DC.B      'HE',$D2,$80,$80,'AH1'
  DC.B      'DHER',$00,$CF,$D2,$C2
  DC.B      'AA',$00,$CF,'R',$83,$08,$82
  DC.B      'OW1',$00,'OS',$D3,$80
  DC.B      $81,'AO1S',$00,'O',$CD
  DC.B      $03,$08,$82,$80,'AHM',$00 
  DC.B      $CF,$80,$80,'AA',$00,$D0,$81
  DC.B      $81,'PIY2',$00,'P',$C8
  DC.B      $80,$80,'F',$00,'PEOP'
  DC.B      $CC,$80,$80,'PIY1P' 
  DC.B      'UL',$00,'PO',$D7,$80,$80 
  DC.B      'PAW2',$00,'PU',$D4 
  DC.B      $80,$81,'PUHT',$00,$D0
  DC.B      $80,$D0,$00,$D0,$81,$D3,$00,$D0 
  DC.B      $81,$CE,$00,'PROF',$AE
  DC.B      $81,$80,'PROHFE'
  DC.B      'H2SER',$00,$D0,$80 
  DC.B      $80,'P',$00,$D1,$81,$81,'KY'
  DC.B      'UW2',$00,'QUA',$D2 
  DC.B      $80,$80,'KWOH1R'
  DC.B      $00,'QU',$C9,$80,'R',$C5,'K'
  DC.B      'WAY1',$00,'Q',$D5,$80
  DC.B      $80,'KW',$00,$D1,$80,$80,'K'
  DC.B      $00,$D2,$81,$81,'AA1R'
  DC.B      $00,'RHYM',$C5,$80,$80
  DC.B      'RAY1M',$00,'RU'
  DC.B      $CC,$81,$80,'RUX1L' 
  DC.B      $00,'R',$C5,$81,'T',$82,'RI'
  DC.B      'Y',$00,'ROUTIN'
  DC.B      $C5,$80,$80,'RUWTI' 
  DC.B      'Y1N',$00,$D2,$80,$D2,$00 
  DC.B      $D2,$80,$80,'R',$00,$D3,$81,$81 
  DC.B      'EH2S',$00,'S',$C8,$80
  DC.B      $80,'SH',$00,'SIO',$CE
  DC.B      $82,$80,'ZHUN',$00,'S'
  DC.B      'OM',$C5,$80,$80,'SAH'
  DC.B      'M',$00,'SU',$D2,$82,$82,'Z'
  DC.B      'HER',$00,'SU',$D2,$80
  DC.B      $82,'SHER',$00,'S',$D5
  DC.B      $82,$82,'ZHUW',$00,'S'
  DC.B      'S',$D5,$82,$82,'SHUW'
  DC.B      $00,'SE',$C4,$82,$81,'ZD' 
  DC.B      $00,$D3,$82,$82,'Z',$00,'SA'
  DC.B      'I',$C4,$80,$80,'SEHD'
  DC.B      $00,'SIO',$CE,$83,$80,'S' 
  DC.B      'HUN',$00,$D3,$80,$D3,$00 
  DC.B      $D3,$84,$81,'Z',$00,$D3,'E',$04 
  DC.B      $08,$82,$81,'Z',$00,$D3,$02,$03 
  DC.B      $08,$82,$81,'S',$00,$D3,$D5,$81 
  DC.B      'S',$00,$D3,$02,$08,$81,$81,'Z' 
  DC.B      $00,$D3,$02,$82,$81,'Z',$00,'S' 
  DC.B      'C',$C8,$81,$80,'SK',$00,$D3
  DC.B      $80,'C',$87,$00,'S',$CD,$82,$80 
  DC.B      'ZUM',$00,'SN',$27,$D4
  DC.B      $82,$80,'ZUNT',$00,'S'
  DC.B      'TL',$C5,$80,$80,'SUL'
  DC.B      $00,$D3,$80,$80,'S',$00,$D4,$81 
  DC.B      $81,'TIY2',$00,'TH' 
  DC.B      $C5,$81,$01,$82,'DHIY'
  DC.B      $00,'TH',$C5,$81,$81,'DH' 
  DC.B      'AX',$00,'T',$CF,$81,$81,'T'
  DC.B      'UX',$00,'T',$CF,'N',$02,$81
  DC.B      $81,'TUX',$00,'T',$CF,$81 
  DC.B      'G',$C5,'TUX',$00,'TO'
  DC.B      'M',$C2,$80,$80,'TUX1'
  DC.B      'M',$00,'T',$CF,$80,'NIG' 
  DC.B      'H',$D4,'TUX',$00,'T',$CF 
  DC.B      $80,$81,'TOW',$00,'TH'
  DC.B      'A',$D4,$81,$80,'DHAE'
  DC.B      'T',$00,'THI',$D3,$81,$81 
  DC.B      'DHIHS',$00,'TH'
  DC.B      'E',$D9,$81,$80,'DHEY'
  DC.B      $00,'THER',$C5,$81,$80
  DC.B      'DHEHR',$00,'TH'
  DC.B      'E',$D2,$80,$80,'DHER'
  DC.B      $00,'THEI',$D2,$80,$80
  DC.B      'DHEHR',$00,'TH'
  DC.B      'A',$CE,$81,$81,'DHAE'
  DC.B      'N',$00,'THE',$CD,$81,$81 
  DC.B      'DHEHM',$00,'TH'
  DC.B      'ES',$C5,$80,$81,'DHI'
  DC.B      'YZ',$00,'THE',$CE,$81
  DC.B      $80,'DHEHN',$00,'T' 
  DC.B      'HROUG',$C8,$80,$80 
  DC.B      'THRUW2',$00,'T'
  DC.B      'HOS',$C5,$80,$80,'DH'
  DC.B      'OHZ',$00,'THOU'
  DC.B      'G',$C8,$80,$81,'DHOW'
  DC.B      $00,'TODA',$D9,$80,$80
  DC.B      'TUXDEY',$00,'T'
  DC.B      'OM',$CF,$80,'RRO',$D7
  DC.B      'TUMAA1',$00,'T'
  DC.B      $CF,$80,'TA',$CC,'TOW'
  DC.B      '1',$00,'THU',$D3,$81,$80 
  DC.B      'DHAH2S',$00,'T'
  DC.B      $C8,$80,$80,'TH',$00,'TE' 
  DC.B      $C4,$08,$82,$81,'TIXD'
  DC.B      $00,'T',$C9,$D3,$02,$CE,'CH'
  DC.B      $00,'T',$C9,$80,$CF,'SH',$00
  DC.B      'T',$C9,$80,$C1,'SH',$00,'T'
  DC.B      'IE',$CE,$80,$80,'SHU'
  DC.B      'N',$00,'TU',$D2,$80,$82,'C'
  DC.B      'HER',$00,'T',$D5,$80,$C1 
  DC.B      'CHUW',$00,'TW',$CF 
  DC.B      $81,$80,'TUW',$00,$D4,$D4 
  DC.B      $80,$00,$D4,$80,'C',$C8,$00,$D4 
  DC.B      $85,'EN',$81,$00,$D4,$80,$80
  DC.B      'T',$00,$D5,$81,$81,'YUW' 
  DC.B      '2',$00,'UL',$CC,$C2,$80,'U'
  DC.B      'XL',$00,'UL',$CC,$84,$80 
  DC.B      'UHL',$00,'UL',$CC,$80
  DC.B      $80,'UXL',$00,'U',$CE,$83 
  DC.B      'EÅYUWN',$00,'U'
  DC.B      $CE,$81,'I',$CE,'UH',$00,'U'
  DC.B      $CE,$81,$C9,'YUWN',$00
  DC.B      'U',$CE,$81,$80,'AHN',$00 
  DC.B      'UPO',$CE,$81,$80,'AX'
  DC.B      'PAON',$00,'U',$D2,$86
  DC.B      $82,'UH2R',$00,'U',$D2
  DC.B      $80,$82,'YUH2R',$00 
  DC.B      'U',$D2,$80,$80,'ER',$00,'U'
  DC.B      $D9,$80,$80,'AY1',$00,$D5 
  DC.B      $80,$03,$81,'UH',$00,'UL' 
  DC.B      $C5,$80,$81,'YUWL',$00
  DC.B      $D5,$80,$03,$83,'AH1',$00 
  DC.B      $D5,'G',$81,$82,$00,$D5,$C7,$89 
  DC.B      $00,$D5,$C7,$82,'W',$00,$D5,'N' 
  DC.B      $82,$80,'YUW',$00,$D5,$86 
  DC.B      $80,'UW',$00,$D5,$80,$80,'Y'
  DC.B      'UW',$00,$D6,$81,$81,'VI' 
  DC.B      'Y2',$00,'VIE',$D7,$80
  DC.B      $80,'VYUW1',$00,'V' 
  DC.B      'AL',$D5,$80,$80,'VAE'
  DC.B      '1LYUW',$00,$D6,$80 
  DC.B      $80,'V',$00,$D7,$81,$81,'DA'
  DC.B      'H2BULYUW'
  DC.B      $00,'WER',$C5,$81,$80,'W' 
  DC.B      'ER',$00,'W',$C1,$80,'S',$C8
  DC.B      'WAA',$00,'W',$C1,$80,'S' 
  DC.B      $D4,'WEY',$00,'W',$C1,$80 
  DC.B      $D3,'WAH',$00,'W',$C1,$80 
  DC.B      $D4,'WAA',$00,'WHE' 
  DC.B      'R',$C5,$80,$80,'WEHR'
  DC.B      $00,'WHA',$D4,$80,$80,'W' 
  DC.B      'AHT',$00,'WHO',$CC 
  DC.B      $80,$80,'/HOWL',$00 
  DC.B      'WH',$CF,$80,$80,'/HU'
  DC.B      'W',$00,'W',$C8,$80,$80,'W',$00 
  DC.B      'WA',$D2,$80,$82,'WEH'
  DC.B      'R',$00,'WA',$D2,$80,$80,'W'
  DC.B      'AOR',$00,'WO',$D2,$80
  DC.B      $83,'WER',$00,'W',$D2,$80 
  DC.B      $80,'R',$00,'WO',$CD,$80,$C1
  DC.B      'WUHM',$00,'WO',$CD 
  DC.B      $80,$C5,'WUM',$00,'WE'
  DC.B      $C1,$80,$D2,'WEH',$00,'W' 
  DC.B      'AN',$D4,$80,$80,'WAA'
  DC.B      '1NT',$00,$D7,$80,$80,'W' 
  DC.B      $00,$D8,$81,$81,'EH2K'
  DC.B      'S',$00,$D8,$81,$80,'Z',$00,$D8 
  DC.B      $80,$80,'KS',$00,$D9,$81,$81
  DC.B      'WAY2',$00,'YOU'
  DC.B      'N',$C7,$80,$80,'YAHN'
  DC.B      'X',$00,'YOU',$D2,$81,$80 
  DC.B      'YOHR',$00,'YO',$D5 
  DC.B      $81,$80,'YUW',$00,'YE'
  DC.B      $D3,$81,$80,'YEHS',$00
  DC.B      $D9,$81,$80,'Y',$00,'YC',$C8
  DC.B      'S',$D0,$80,'AYK',$00,$D9 
  DC.B      $03,$08,$82,$81,'IY',$00,$D9
  DC.B      $03,$08,$82,$C9,'IY',$00,$D9
  DC.B      $08,$81,$81,'AY',$00,$D9,$08
  DC.B      $81,$82,'AY',$00,$D9,$08,$81
  DC.B      $03,$07,$08,$82,'IH',$00,$D9
  DC.B      $08,$81,$03,$82,'AY',$00,$D9
  DC.B      $C6,$80,'AY',$00,$D9,$80,$80
  DC.B      'IH',$00,$DA,$81,$81,'ZE' 
  DC.B      'H1D',$00,$DA,$80,$80,'Z' 
  DC.B      $00,$00 
L0044:
  DC.B      $EC,$E6,$EE,$D7,$F0,$C1,$F1,'"' 
  DC.B      $F1,$FC,$F2,'{',$F4,$0E,$F4,'@' 
  DC.B      $F4,$B6,$F4,$F9,$F6,'j',$F6,$84 
  DC.B      $F6,$95,$F6,$F4,$F7,'S',$F7,$BE 
  DC.B      $FA,$A4,$FA,$F9,$FB,$27,$FB,'k' 
  DC.B      $FC,'4',$FD,$C8,$FE,'y',$FE,$A1 
  DC.B      $FF,'_',$FF,'s',$FF,$F1 

SPEAK:
; enable YM..
  BSR       L00B8 
; decode to phoneme structures..
  BSR       L0049 
  TST.L     D0
  BEQ.S     L0046 
  RTS 

  DC.B      'MC68000/'
  DC.B      'AY-3-891'
  DC.B      '0 SPEECH'
  DC.B      ' SYNTHER'
  DC.B      'SIZER V:'
  DC.B      '2.0',$0D,$0A,'Cop' 
  DC.B      'yright 1'
  DC.B      '986 A.D.'
  DC.B      'BEVERIDG'
  DC.B      'E & M.N.'
  DC.B      'DAY',$0D,$0A,'ALL' 
  DC.B      ' RIGHTS '
  DC.B      'RESERVED'
  DC.B      '.',$0D,$0A,$00 

; phoneme structure to soundwaves
L0046:
  LEA       TABSTART(PC),A1 
  LEA       L00DA(PC),A6
  BSR       L0057 
  BSR       L0065 
  BSR       L0069 
  BSR       L006D 
  BSR       L0073 
  BSR       L007B 
  BSR       L00B6 
  CLR.L     D0
  RTS 

L0047:
  CMPI.B    #$61,D0 
  BCS.S     L0048 
  CMPI.B    #$7B,D0 
  BCC.S     L0048 
  SUBI.B    #$20,D0 
L0048:
  RTS 

; decodes phonetic text to phoneme structure list
L0049:
  LEA       BUFFER(PC),A1 
L004A:
  MOVE.L    #$FFFFFFFF,(A1) 
  MOVE.B    (A0)+,D0
  BEQ       L0053 
  CMPI.B    #$31,D0 
  BCS.S     L004B 
  CMPI.B    #$3A,D0 
  BCC       L004B 
  SUBI.B    #$30,D0 
  TST.B     -2(A1)
  BNE.S     L0050 
  MOVE.B    D0,-2(A1) 
  BRA.S     L004A 
L004B:
  CMPI.B    #$3E,D0 
  BNE.S     L004C 
  TST.B     -2(A1)
  BNE.S     L0050 
  MOVE.B    #$80,-2(A1) 
  BRA.S     L004A 
L004C:
  CMPI.B    #$3C,D0 
  BNE.S     L004D 
  TST.B     -2(A1)
  BNE.S     L0050 
  MOVE.B    #$40,-2(A1) 
  BRA.S     L004A 
L004D:
  BSR.S     L0047 
  MOVE.B    D0,D1 
  MOVE.B    (A0),D0 
  BSR.S     L0047 
  LEA       TABSTART(PC),A2 
  MOVEQ     #0,D2 
L004E:
  CMP.B     0(A2,D2.W),D1 
  BNE.S     L004F 
  CMPI.B    #$20,1(A2,D2.W) 
  BEQ.S     L0052 
  CMP.B     1(A2,D2.W),D0 
  BEQ.S     L0051 
L004F:
  ADDI.W    #$22,D2 
  TST.B     0(A2,D2.W)
  BPL.S     L004E 
L0050:
  MOVEQ     #$FFFFFFFF,D0 
  RTS 
L0051:
  ADDQ.L    #1,A0 
L0052:
  MOVE.W    D2,(A1)+
  CLR.W     (A1)+ 
  CMPA.L    #L00DD,A1 
  BEQ.S     L0050 
  BRA       L004A 
L0053:
  MOVE.W    #$550,(A1)+ 
  CLR.W     (A1)+ 
  MOVE.L    #$FFFFFFFF,(A1)+
  MOVEQ     #0,D0 
  RTS 
L0054:
  MOVE.L    A1,-(A7)
  LEA       L00DC(PC),A1
L0055:
  CMPA.L    A0,A1 
  BEQ.S     L0056 
  MOVE.L    -(A1),4(A1) 
  BRA.S     L0055 
L0056:
  MOVE.W    D1,0(A0)
  MOVE.B    D2,2(A0)
  MOVE.B    D3,3(A0)
  MOVEA.L   (A7)+,A1
  RTS 
L0057:
  LEA       BUFFER(PC),A0 
L0058:
  MOVEQ     #0,D0 
  MOVE.W    (A0),D0 
  BMI       L0064 
  CMPI.W    #$8E6,D0
  BEQ       L0063 
  CMPI.W    #$8E6,D0
  BLE.S     L0059 
  MOVE.W    2(A1,D0.W),(A0) 
  MOVE.W    4(A1,D0.W),D1 
  MOVE.B    2(A0),D2
  MOVEQ     #0,D3 
  ADDQ.L    #4,A0 
  BSR.S     L0054 
  SUBQ.L    #4,A0 
  MOVE.W    (A0),D0 
L0059:
  CMPI.W    #$AA,D0 
  BGT.S     L005B 
  MOVE.W    #$110,D1
  CMPI.W    #$44,D0 
  BLE.S     L005A 
  MOVE.W    #$EE,D1 
L005A:
  MOVE.B    2(A0),D2
  MOVEQ     #0,D3 
  ADDQ.L    #4,A0 
  BSR.S     L0054 
  SUBQ.L    #4,A0 
  MOVE.W    (A0),D0 
L005B:
  CMPI.W    #$4EA,D0
  BNE.S     L005D 
  MOVE.W    -4(A0),D1 
  BMI       L0063 
  CMPI.W    #$2CA,D1
  BGT       L0063 
  MOVE.W    4(A0),D1
  BMI.S     L005C 
  CMPI.W    #$2CA,D1
  BLE       L0063 
L005C:
  MOVE.W    #$396,(A0)
  BRA       L0063 
L005D:
  CMPI.W    #$4C8,D0
  BNE.S     L005F 
  MOVE.W    -4(A0),D1 
  BMI       L0063 
  CMPI.W    #$2CA,D1
  BGT       L0063 
  MOVE.W    4(A0),D1
  BMI       L005E 
  CMPI.W    #$2CA,D1
  BLE       L0063 
L005E:
  MOVE.W    #$374,(A0)
  BRA.S     L0063 
L005F:
  CMPI.W    #$83C,D0
  BNE.S     L0063 
  CMPI.W    #$770,-4(A0)
  BNE.S     L0060 
  MOVE.W    #$462,(A0)
  BRA.S     L0063 
L0060:
  CMPI.W    #$2CA,8(A0) 
  BGT.S     L0063 
  CMPI.W    #$572,4(A0) 
  BNE.S     L0061 
  MOVE.W    #$6A4,4(A0) 
  BRA.S     L0063 
L0061:
  CMPI.W    #$5D8,4(A0) 
  BNE.S     L0062 
  MOVE.W    #$70A,4(A0) 
  BRA.S     L0063 
L0062:
  CMPI.W    #$63E,4(A0) 
  BNE.S     L0063 
  MOVE.W    #$770,4(A0) 
L0063:
  ADDQ.L    #4,A0 
  TST.W     (A0)
  BPL       L0058 
L0064:
  RTS 
L0065:
  LEA       BUFFER(PC),A0 
  MOVEQ     #0,D0 
L0066:
  MOVE.W    (A0),D0 
  BPL.S     L0067 
  RTS 
L0067:
  CMPI.W    #$2CA,D0
  BLE.S     L0068 
  CMPI.W    #$83C,D0
  BGE.S     L0068 
  MOVE.W    4(A0),D0
  BMI.S     L0068 
  CMPI.W    #$2CA,D0
  BGT.S     L0068 
  MOVE.B    6(A0),D0
  BEQ.S     L0068 
  MOVE.B    D0,2(A0)
L0068:
  ADDQ.L    #4,A0 
  BRA.S     L0066 
L0069:
  LEA       BUFFER(PC),A0 
L006A:
  MOVE.W    (A0),D0 
  BMI.S     L006C 
  BTST      #7,32(A1,D0.W)
  BEQ.S     L006B 
  MOVE.W    D0,D1 
  ADDI.W    #$22,D1 
  MOVE.B    2(A0),D2
  MOVEQ     #0,D3 
  ADDQ.L    #4,A0 
  BSR       L0054 
  BRA.S     L006A 
L006B:
  ADDQ.L    #4,A0 
  BRA.S     L006A 
L006C:
  RTS 
L006D:
  LEA       BUFFER(PC),A0 
  MOVEQ     #0,D0 
L006E:
  MOVE.W    (A0),D0 
  BPL.S     L006F 
  RTS 
L006F:
  MOVE.B    3(A1,D0.W),D1 
  MOVE.B    2(A0),D2
  BPL.S     L0070 
  MOVE.B    D1,D3 
  LSR.B     #1,D3 
  ADDQ.B    #1,D3 
  ADD.B     D3,D1 
  BRA.S     L0072 
L0070:
  BTST      #6,D2 
  BEQ.S     L0071 
  LSR.B     #1,D1 
  ADDQ.B    #1,D1 
  BRA.S     L0072 
L0071:
  TST.B     D2
  BEQ.S     L0072 
  MOVE.B    2(A1,D0.W),D1 
L0072:
  ANDI.W    #$3F,D2 
  MOVE.B    D2,2(A0)
  MOVE.B    D1,3(A0)
  ADDQ.L    #4,A0 
  BRA.S     L006E 
L0073:
  LEA       BUFFER(PC),A0 
  MOVEQ     #0,D0 
L0074:
  MOVE.W    (A0),D0 
  BMI.S     L007A 
  CMPI.W    #$83C,D0
  BLE.S     L0079 
  MOVEQ     #0,D4 
L0075:
  SUBQ.L    #4,D4 
  MOVE.W    0(A0,D4.W),D0 
  BMI.S     L0079 
  CMPI.W    #$83C,D0
  BGT.S     L0078 
  CMPI.W    #$2CA,D0
  BGT.S     L0075 
  BRA.S     L0078 
L0076:
  MOVE.W    0(A0,D4.W),D0 
  BTST      #5,32(A1,D0.W)
  BEQ.S     L0077 
  BTST      #6,32(A1,D0.W)
  BEQ.S     L0078 
L0077:
  MOVE.B    3(A0,D4.W),D1 
  LSR.B     #1,D1 
  ADDQ.B    #1,D1 
  ADD.B     D1,3(A0,D4.W) 
L0078:
  ADDQ.L    #4,D4 
  BNE.S     L0076 
L0079:
  ADDQ.L    #4,A0 
  BRA.S     L0074 
L007A:
  RTS 
L007B:
  TST.L     L00D5 
  BNE.S     L007B 
  LEA       BUFFER(PC),A0 
  LEA       SPCHBUFF(PC),A2 
  MOVEQ     #0,D0 
  MOVE.W    #$11F,D1
L007C:
  MOVE.L    D0,(A2)+
  MOVE.L    D0,(A2)+
  MOVE.L    D0,(A2)+
  MOVE.L    D0,(A2)+
  MOVE.L    D0,(A2)+
  MOVE.L    D0,(A2)+
  MOVE.L    D0,(A2)+
  MOVE.L    D0,(A2)+
  DBF       D1,L007C
  LEA       SPCHBUFF(PC),A2 
  MOVEQ     #0,D1 
  MOVE.B    D0,20(A6) 
  MOVE.B    D0,21(A6) 
L007D:
  MOVE.W    (A0),D0 
  BMI       L008C 
  MOVE.W    4(A1,D0.W),2(A6)
  MOVE.W    8(A1,D0.W),8(A6)
  MOVE.W    12(A1,D0.W),14(A6)
  MOVE.B    21(A1,D0.W),5(A6) 
  MOVE.B    23(A1,D0.W),11(A6)
  MOVE.B    25(A1,D0.W),17(A6)
  MOVE.B    27(A1,D0.W),19(A6)
  MOVEQ     #0,D4 
  MOVE.W    D4,24(A6) 
  MOVE.W    D4,26(A6) 
  MOVE.B    20(A6),D4 
  CMP.B     3(A0),D4
  BLE.S     L007E 
  MOVE.B    3(A0),20(A6)
L007E:
  MOVE.B    21(A6),D4 
  CMP.B     3(A0),D4
  BLE.S     L007F 
  MOVE.B    3(A0),21(A6)
L007F:
  BSR       L00A1 
  MOVE.B    20(A6),24(A6) 
  MOVE.B    21(A6),26(A6) 
  MOVE.W    2(A6),0(A6) 
  MOVE.W    8(A6),6(A6) 
  MOVE.W    14(A6),12(A6) 
  MOVE.B    5(A6),4(A6) 
  MOVE.B    11(A6),10(A6) 
  MOVE.B    17(A6),16(A6) 
  MOVE.B    19(A6),18(A6) 
  MOVE.W    4(A0),D1
  BMI       L008C 
  MOVE.B    16(A1,D0.W),D2
  CMP.B     16(A1,D1.W),D2
  BGE.S     L0080 
  MOVE.B    20(A1,D1.W),22(A6)
  MOVE.B    19(A1,D1.W),20(A6)
  MOVE.B    31(A1,D1.W),23(A6)
  MOVE.B    30(A1,D1.W),21(A6)
  EXG       D1,D0 
  BRA.S     L0081 
L0080:
  MOVE.B    20(A1,D0.W),20(A6)
  MOVE.B    19(A1,D0.W),22(A6)
  MOVE.B    31(A1,D0.W),21(A6)
  MOVE.B    30(A1,D0.W),23(A6)
L0081:
  MOVE.B    3(A0),D6
  CMP.B     20(A6),D6 
  BGE.S     L0082 
  MOVE.B    D6,20(A6) 
L0082:
  CMP.B     21(A6),D6 
  BGE.S     L0083 
  MOVE.B    D6,21(A6) 
L0083:
  CMPI.W    #$4EA,D1
  BNE.S     L0084 
  MOVEQ     #0,D2 
  BRA.S     L0085 
L0084:
  MOVE.W    4(A1,D1.W),D2 
  MOVE.B    17(A1,D0.W),D3
  BSR       L00B0 
L0085:
  ADD.W     6(A1,D0.W),D2 
  MOVE.W    D2,2(A6)
  MOVE.W    8(A1,D1.W),D2 
  MOVE.B    17(A1,D0.W),D3
  BSR       L00B0 
  ADD.W     10(A1,D0.W),D2
  MOVE.W    D2,8(A6)
  MOVE.W    12(A1,D1.W),D2
  MOVE.B    18(A1,D0.W),D3
  BSR       L00B0 
  ADD.W     14(A1,D0.W),D2
  MOVE.W    D2,14(A6) 
  MOVE.B    21(A1,D1.W),D2
  EXT.W     D2
  MOVE.B    29(A1,D0.W),D3
  BSR       L00B0 
  ADD.B     22(A1,D0.W),D2
  MOVE.B    D2,5(A6)
  MOVE.B    23(A1,D1.W),D2
  EXT.W     D2
  MOVE.B    29(A1,D0.W),D3
  BSR       L00B0 
  ADD.B     24(A1,D0.W),D2
  MOVE.B    D2,11(A6) 
  MOVE.B    25(A1,D1.W),D2
  EXT.W     D2
  MOVE.B    29(A1,D0.W),D3
  BSR       L00B0 
  ADD.B     26(A1,D0.W),D2
  MOVE.B    D2,17(A6) 
  MOVE.B    27(A1,D1.W),D2
  EXT.W     D2
  MOVE.B    29(A1,D0.W),D3
  BSR       L00B0 
  ADD.B     28(A1,D0.W),D2
  MOVE.B    D2,19(A6) 
  MOVEQ     #0,D2 
  MOVE.B    3(A0),D2
  SUB.B     24(A6),D2 
  SUB.B     20(A6),D2 
  BLE.S     L0088 
  MOVEQ     #0,D3 
  MOVE.B    24(A6),D3 
  MULU      #9,D3 
  BRA.S     L0087 
L0086:
  MOVE.W    0(A6),D7
  BSR       L00B3 
  MOVE.B    D7,3(A2,D3.W) 
  MOVE.W    6(A6),D7
  BSR       L00B3 
  MOVE.B    D7,5(A2,D3.W) 
  MOVE.W    12(A6),D7 
  BSR       L00B3 
  MOVE.B    D7,7(A2,D3.W) 
  ADDI.W    #9,D3 
  ADDQ.B    #1,24(A6) 
L0087:
  DBF       D2,L0086
L0088:
  MOVEQ     #0,D2 
  MOVE.B    3(A0),D2
  SUB.B     26(A6),D2 
  SUB.B     21(A6),D2 
  BLE.S     L008B 
  MOVEQ     #0,D3 
  MOVE.B    26(A6),D3 
  MULU      #9,D3 
  BRA.S     L008A 
L0089:
  MOVE.B    4(A6),D7
  BSR       L00B4 
  MOVE.B    D7,4(A2,D3.W) 
  MOVE.B    10(A6),D7 
  BSR       L00B4 
  MOVE.B    D7,6(A2,D3.W) 
  MOVE.B    16(A6),D7 
  BSR       L00B4 
  MOVE.B    D7,8(A2,D3.W) 
  MOVE.B    18(A6),D7 
  BSR       L00B4 
  MOVE.B    D7,1(A2,D3.W) 
  ADDI.W    #9,D3 
  ADDQ.B    #1,26(A6) 
L008A:
  DBF       D2,L0089
L008B:
  BSR       L00A1 
  MOVE.W    2(A6),0(A6) 
  MOVE.W    8(A6),6(A6) 
  MOVE.W    14(A6),12(A6) 
  MOVE.B    5(A6),4(A6) 
  MOVE.B    11(A6),10(A6) 
  MOVE.B    17(A6),16(A6) 
  MOVE.B    19(A6),18(A6) 
  MOVE.B    22(A6),20(A6) 
  MOVE.B    23(A6),21(A6) 
  MOVEQ     #0,D0 
  MOVE.B    3(A0),D0
  MULU      #9,D0 
  ADDA.L    D0,A2 
  ADDQ.L    #4,A0 
  BRA       L007D 
L008C:
  CLR.B     (A2)
  LEA       SPCHBUFF(PC),A2 
  LEA       BUFFER(PC),A0 
L008D:
  MOVE.W    (A0),D0 
  BMI.S     L0090 
  MOVEQ     #0,D1 
  MOVE.B    3(A0),D1
  MOVE.B    33(A1,D0.W),D2
  BRA.S     L008F 
L008E:
  MOVE.B    D2,2(A2)
  ADDA.W    #9,A2 
L008F:
  DBF       D1,L008E
  ADDQ.L    #4,A0 
  BRA.S     L008D 
L0090:
  LEA       BUFFER(PC),A0 
  LEA       SPCHBUFF(PC),A2 
  MOVEQ     #$42,D0 
  MOVEQ     #0,D2 
L0091:
  MOVE.W    (A0),D4 
  BMI       L00A0 
  MOVEQ     #0,D5 
  MOVE.B    3(A0),D5
  SUBQ.B    #1,D5 
  BLT.S     L0095 
  CMPI.W    #$8E6,D4
  BEQ.S     L0092 
  CMPI.W    #$83C,D4
  BGT.S     L0098 
  TST.B     2(A0) 
  BNE.S     L0096 
L0092:
  MOVE.B    D0,0(A2)
  CMPI.B    #$42,D0 
  BEQ.S     L0094 
  BLT.S     L0093 
  SUBQ.B    #1,D0 
  BRA.S     L0094 
L0093:
  ADDQ.B    #1,D0 
L0094:
  ADDA.W    #9,A2 
  DBF       D5,L0092
L0095:
  ADDQ.L    #4,A0 
  BRA.S     L0091 
L0096:
  MOVEQ     #0,D0 
  MOVE.B    2(A0),D0
  MOVE.B    D0,D7 
  ADD.B     D0,D0 
  ADD.B     D7,D0 
  NEG.B     D0
  ADDI.B    #$42,D0 
L0097:
  MOVE.B    D0,0(A2)
  ADDA.W    #9,A2 
  DBF       D5,L0097
  BRA.S     L0095 
L0098:
  MOVEQ     #$FFFFFFEC,D2 
  MOVEQ     #0,D3 
L0099:
  SUBI.W    #4,D3 
  TST.W     0(A0,D3.W)
  BMI.S     L009A 
  CMPI.W    #$83C,0(A0,D3.W)
  BGT.S     L009A 
  MOVEQ     #0,D4 
  ADD.B     3(A0,D3.W),D2 
  BLT.S     L0099 
  MOVEQ     #0,D2 
L009A:
  ADDI.B    #$14,D2 
  BEQ.S     L009F 
  CMPI.W    #$880,(A0)
  BNE.S     L009B 
  MOVEQ     #1,D1 
  BRA.S     L009D 
L009B:
  CMPI.W    #$8C4,(A0)
  BNE.S     L009C 
  MOVEQ     #$FFFFFFFF,D1 
  BRA.S     L009D 
L009C:
  MOVEQ     #1,D1 
  LSR.B     #1,D2 
  ADDQ.B    #1,D2 
L009D:
  EXT.W     D2
  MULS      #$FFF7,D2 
  MOVEQ     #0,D3 
L009E:
  ADD.B     D1,D3 
  ADD.B     D3,0(A2,D2.W) 
  ADDI.W    #9,D2 
  BLE.S     L009E 
L009F:
  MOVEQ     #$42,D0 
  BRA       L0092 
L00A0:
  RTS 
L00A1:
  MOVEM.L   D0-D7,-(A7) 
  MOVEQ     #0,D0 
  MOVE.B    24(A6),D0 
  MULU      #9,D0 
  LEA       0(A2,D0.W),A3 
  MOVE.W    0(A6),D0
  MOVE.W    2(A6),D1
  LEA       3(A3),A4
  MOVEQ     #0,D2 
  MOVE.B    20(A6),D2 
  BSR       L00A2 
  MOVE.W    6(A6),D0
  MOVE.W    8(A6),D1
  LEA       5(A3),A4
  MOVEQ     #0,D2 
  MOVE.B    20(A6),D2 
  BSR       L00A2 
  MOVE.W    12(A6),D0 
  MOVE.W    14(A6),D1 
  LEA       7(A3),A4
  MOVEQ     #0,D2 
  MOVE.B    20(A6),D2 
  BSR       L00A2 
  MOVEQ     #0,D0 
  MOVE.B    26(A6),D0 
  MULU      #9,D0 
  LEA       0(A2,D0.W),A3 
  MOVE.B    4(A6),D0
  MOVE.B    5(A6),D1
  LEA       4(A3),A4
  MOVEQ     #0,D2 
  MOVE.B    21(A6),D2 
  BSR       L00A9 
  MOVE.B    10(A6),D0 
  MOVE.B    11(A6),D1 
  LEA       6(A3),A4
  MOVEQ     #0,D2 
  MOVE.B    21(A6),D2 
  BSR       L00A9 
  MOVE.B    16(A6),D0 
  MOVE.B    17(A6),D1 
  LEA       8(A3),A4
  MOVEQ     #0,D2 
  MOVE.B    21(A6),D2 
  BSR       L00A9 
  MOVE.B    18(A6),D0 
  MOVE.B    19(A6),D1 
  LEA       1(A3),A4
  MOVEQ     #0,D2 
  MOVE.B    21(A6),D2 
  BSR       L00A9 
  MOVEM.L   (A7)+,D0-D7 
  RTS 
L00A2:
  TST.B     D2
  BEQ.S     L00A8 
  MOVE.W    D1,D3 
  SUB.W     D0,D3 
  EXT.L     D3
  DIVS      D2,D3 
  MOVE.W    D3,D4 
  ASR.W     #1,D4 
  ADD.W     D4,D0 
  BRA.S     L00A7 
L00A3:
  MOVE.W    D0,D7 
  BSR       L00B3 
  TST.B     (A4)
  BEQ.S     L00A5 
  TST.L     D3
  BMI.S     L00A4 
  CMP.B     (A4),D7 
  BGT.S     L00A5 
  BRA.S     L00A6 
L00A4:
  CMP.B     (A4),D7 
  BGE.S     L00A6 
L00A5:
  MOVE.B    D7,(A4) 
L00A6:
  ADD.W     D3,D0 
  ADDA.W    #9,A4 
L00A7:
  DBF       D2,L00A3
L00A8:
  RTS 
L00A9:
  TST.B     D2
  BEQ.S     L00AF 
  ANDI.L    #$FF,D0 
  MOVE.B    D1,D3 
  SUB.B     D0,D3 
  LSL.W     #8,D3 
  EXT.L     D3
  DIVS      D2,D3 
  EXT.L     D3
  LSL.L     #8,D3 
  MOVE.L    D3,D4 
  ASR.L     #1,D4 
  SWAP      D0
  ADD.L     D4,D0 
  SWAP      D0
  BRA.S     L00AE 
L00AA:
  MOVE.B    D0,D7 
  BSR       L00B4 
  TST.B     (A4)
  BEQ.S     L00AC 
  TST.L     D3
  BMI.S     L00AB 
  CMP.B     (A4),D7 
  BGT.S     L00AC 
  BRA.S     L00AD 
L00AB:
  CMP.B     (A4),D7 
  BGE.S     L00AD 
L00AC:
  MOVE.B    D7,(A4) 
L00AD:
  SWAP      D0
  ADD.L     D3,D0 
  SWAP      D0
  ADDA.W    #9,A4 
L00AE:
  DBF       D2,L00AA
L00AF:
  RTS 
L00B0:
  TST.B     D3
  BEQ.S     L00B2 
  SUBQ.B    #1,D3 
  BNE.S     L00B1 
  ASR.W     #1,D2 
L00B1:
  RTS 
L00B2:
  MOVEQ     #0,D2 
  RTS 
L00B3:
  ADDI.W    #$10,D7 
  LSR.W     #5,D7 
  RTS 
L00B4:
  MOVE.B    D7,D6 
  ADD.B     D6,D6 
  ADD.B     D6,D7 
  SUBI.B    #$59,D7 
  BPL.S     L00B5 
  MOVEQ     #0,D7 
L00B5:
  LSR.B     #2,D7 
  RTS 
L00B6:
  MOVE.W    #5,-(A7)
  MOVE.W    #$1A,-(A7)
  TRAP      #$E 
  ADDQ.L    #4,A7 
  MOVEQ     #0,D0 
  MOVEQ     #0,D1 
  MOVE.B    SET_PITC(PC),D0 
  MOVE.B    D0,USE_PITC 
  MOVE.B    SET_RATE(PC),D1 
  MULU      #$4D,D1 
  DIVU      D0,D1 
  MOVE.B    D1,USE_RATE 
  CLR.B     L00D6 
  LEA       SPCHBUFF(PC),A0 
  MOVE.L    A0,L00D5
  PEA       opwaves(PC) 
  MOVE.W    D0,-(A7)
  MOVE.W    #1,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #$1F,-(A7)
  TRAP      #$E 
  LEA       12(A7),A7 
  RTS 
L00B7:
  DCB.W     135,0 
  DC.B      $00,$01,$01,$01,$01,$01,$01,$01 
  DC.B      $01,$01,$01,$01,$01,$01,$01,$01 
  DC.B      $01,$01,$02,$02,$02,$02,$02,$02 
  DC.B      $02,$02,$02,$02,$02,$02,$02,$02 
  DC.B      $02,$02,$02,$02,$02,$02,$02,$02 
  DC.B      $02,$02,$02,$02,$02,$02,$02,$02 
  DC.B      $02,$02,$02,$02,$02,$02,$02,$02 
  DC.B      $02,$02,$02,$02,$02,$02,$02,$02 
  DC.B      $02,$02,$02,$02,$02,$02,$02,$02 
  DC.B      $02,$02,$02,$02,$02,$02,$02,$02 
  DC.B      $02,$02,$02,$01,$01,$01,$01,$01 
  DC.B      $01,$01,$01,$01,$01,$01,$01,$01 
  DC.B      $01,$01,$01,$01,$00,$00,$00,$00 
  DCB.W     12,0
  DC.B      $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF 
  DC.B      $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF 
  DC.B      $FF,$FF,$FE,$FE,$FE,$FE,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FF,$FF,$FF,$FF,$FF 
  DC.B      $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF 
  DC.B      $FF,$FF,$FF,$FF,$00,$00,$00,$00 
  DCB.W     9,0 
  DC.B      $01,$01,$01,$01,$01,$01,$01,$02 
  DC.B      $02,$02,$02,$02,$02,$02,$02,$03 
  DC.B      $03,$03,$03,$03,$03,$03,$03,$03 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$05,$05,$05 
  DC.B      $05,$05,$05,$05,$05,$05,$05,$05 
  DC.B      $05,$05,$05,$05,$05,$05,$05,$05 
  DC.B      $05,$05,$05,$05,$05,$05,$05,$05 
  DC.B      $05,$05,$05,$05,$05,$05,$05,$05 
  DC.B      $05,$05,$05,$05,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$03,$03,$03,$03,$03,$03,$03 
  DC.B      $03,$03,$02,$02,$02,$02,$02,$02 
  DC.B      $02,$02,$01,$01,$01,$01,$01,$01 
  DC.B      $01,$00,$00,$00,$00,$00,$00,$00 
  DCB.W     4,0 
  DC.B      $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE 
  DC.B      $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FD 
  DC.B      $FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD 
  DC.B      $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC 
  DC.B      $FC,$FC,$FC,$FC,$FC,$FB,$FB,$FB 
  DC.B      $FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB 
  DC.B      $FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB 
  DC.B      $FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB 
  DC.B      $FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB 
  DC.B      $FB,$FB,$FB,$FB,$FC,$FC,$FC,$FC 
  DC.B      $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC 
  DC.B      $FC,$FD,$FD,$FD,$FD,$FD,$FD,$FD 
  DC.B      $FD,$FD,$FE,$FE,$FE,$FE,$FE,$FE 
  DC.B      $FE,$FE,$FF,$FF,$FF,$FF,$FF,$FF 
  DC.B      $FF,$00,$00,$00,$00,$00,$00,$00 
  DCB.W     2,0 
  DC.B      $00,$01,$01,$01,$01,$01,$02,$02 
  DC.B      $02,$02,$02,$03,$03,$03,$03,$03 
  DC.B      $04,$04,$04,$04,$04,$04,$05,$05 
  DC.B      $05,$05,$05,$05,$06,$06,$06,$06 
  DC.B      $06,$06,$06,$06,$07,$07,$07,$07 
  DC.B      $07,$07,$07,$07,$07,$07,$08,$08 
  DC.B      $08,$08,$08,$08,$08,$08,$08,$08 
  DC.B      $08,$08,$08,$08,$08,$08,$08,$08 
  DC.B      $08,$08,$08,$08,$08,$08,$08,$08 
  DC.B      $08,$08,$08,$07,$07,$07,$07,$07 
  DC.B      $07,$07,$07,$07,$07,$06,$06,$06 
  DC.B      $06,$06,$06,$06,$06,$05,$05,$05 
  DC.B      $05,$05,$05,$04,$04,$04,$04,$04 
  DC.B      $04,$03,$03,$03,$03,$03,$02,$02 
  DC.B      $02,$02,$02,$01,$01,$01,$01,$01 
  DCB.W     4,0 
  DC.B      $00,$FF,$FF,$FF,$FF,$FF,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FD,$FD,$FD,$FD,$FD 
  DC.B      $FC,$FC,$FC,$FC,$FC,$FC,$FB,$FB 
  DC.B      $FB,$FB,$FB,$FB,$FA,$FA,$FA,$FA 
  DC.B      $FA,$FA,$FA,$FA,$F9,$F9,$F9,$F9 
  DC.B      $F9,$F9,$F9,$F9,$F9,$F9,$F8,$F8 
  DC.B      $F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8 
  DC.B      $F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8 
  DC.B      $F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8 
  DC.B      $F8,$F8,$F8,$F9,$F9,$F9,$F9,$F9 
  DC.B      $F9,$F9,$F9,$F9,$F9,$FA,$FA,$FA 
  DC.B      $FA,$FA,$FA,$FA,$FA,$FB,$FB,$FB 
  DC.B      $FB,$FB,$FB,$FC,$FC,$FC,$FC,$FC 
  DC.B      $FC,$FD,$FD,$FD,$FD,$FD,$FE,$FE 
  DC.B      $FE,$FE,$FE,$FF,$FF,$FF,$FF,$FF 
  DCB.W     4,0 
  DC.B      $01,$01,$01,$01,$02,$02,$02,$03 
  DC.B      $03,$03,$03,$04,$04,$04,$04,$05 
  DC.B      $05,$05,$05,$06,$06,$06,$06,$06 
  DC.B      $07,$07,$07,$07,$08,$08,$08,$08 
  DC.B      $08,$08,$09,$09,$09,$09,$09,$09 
  DC.B      $09,$0A,$0A,$0A,$0A,$0A,$0A,$0A 
  DC.B      $0A,$0A,$0A,$0B,$0B,$0B,$0B,$0B 
  DC.B      $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B 
  DC.B      $0B,$0B,$0B,$0B,$0B,$0B,$0A,$0A 
  DC.B      $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A 
  DC.B      $09,$09,$09,$09,$09,$09,$09,$08 
  DC.B      $08,$08,$08,$08,$08,$07,$07,$07 
  DC.B      $07,$06,$06,$06,$06,$06,$05,$05 
  DC.B      $05,$05,$04,$04,$04,$04,$03,$03 
  DC.B      $03,$03,$02,$02,$02,$01,$01,$01 
  DC.B      $01,$00,$00,$00,$00,$00,$00,$00 
  DC.B      $FF,$FF,$FF,$FF,$FE,$FE,$FE,$FD 
  DC.B      $FD,$FD,$FD,$FC,$FC,$FC,$FC,$FB 
  DC.B      $FB,$FB,$FB,$FA,$FA,$FA,$FA,$FA 
  DC.B      $F9,$F9,$F9,$F9,$F8,$F8,$F8,$F8 
  DC.B      $F8,$F8,$F7,$F7,$F7,$F7,$F7,$F7 
  DC.B      $F7,$F6,$F6,$F6,$F6,$F6,$F6,$F6 
  DC.B      $F6,$F6,$F6,$F5,$F5,$F5,$F5,$F5 
  DC.B      $F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5 
  DC.B      $F5,$F5,$F5,$F5,$F5,$F5,$F6,$F6 
  DC.B      $F6,$F6,$F6,$F6,$F6,$F6,$F6,$F6 
  DC.B      $F7,$F7,$F7,$F7,$F7,$F7,$F7,$F8 
  DC.B      $F8,$F8,$F8,$F8,$F8,$F9,$F9,$F9 
  DC.B      $F9,$FA,$FA,$FA,$FA,$FA,$FB,$FB 
  DC.B      $FB,$FB,$FC,$FC,$FC,$FC,$FD,$FD 
  DC.B      $FD,$FD,$FE,$FE,$FE,$FF,$FF,$FF 
  DC.B      $FF,$00,$00,$00,$00,$00,$00,$01 
  DC.B      $01,$01,$02,$02,$02,$03,$03,$03 
  DC.B      $04,$04,$04,$05,$05,$05,$06,$06 
  DC.B      $06,$06,$07,$07,$07,$08,$08,$08 
  DC.B      $08,$09,$09,$09,$0A,$0A,$0A,$0A 
  DC.B      $0A,$0B,$0B,$0B,$0B,$0B,$0C,$0C 
  DC.B      $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D 
  DC.B      $0D,$0D,$0D,$0D,$0D,$0D,$0E,$0E 
  DC.B      $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E 
  DC.B      $0E,$0E,$0E,$0D,$0D,$0D,$0D,$0D 
  DC.B      $0D,$0D,$0D,$0D,$0D,$0C,$0C,$0C 
  DC.B      $0C,$0C,$0C,$0B,$0B,$0B,$0B,$0B 
  DC.B      $0A,$0A,$0A,$0A,$0A,$09,$09,$09 
  DC.B      $08,$08,$08,$08,$07,$07,$07,$06 
  DC.B      $06,$06,$06,$05,$05,$05,$04,$04 
  DC.B      $04,$03,$03,$03,$02,$02,$02,$01 
  DC.B      $01,$01,$00,$00,$00,$00,$00,$FF 
  DC.B      $FF,$FF,$FE,$FE,$FE,$FD,$FD,$FD 
  DC.B      $FC,$FC,$FC,$FB,$FB,$FB,$FA,$FA 
  DC.B      $FA,$FA,$F9,$F9,$F9,$F8,$F8,$F8 
  DC.B      $F8,$F7,$F7,$F7,$F6,$F6,$F6,$F6 
  DC.B      $F6,$F5,$F5,$F5,$F5,$F5,$F4,$F4 
  DC.B      $F4,$F4,$F4,$F4,$F3,$F3,$F3,$F3 
  DC.B      $F3,$F3,$F3,$F3,$F3,$F3,$F2,$F2 
  DC.B      $F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2 
  DC.B      $F2,$F2,$F2,$F3,$F3,$F3,$F3,$F3 
  DC.B      $F3,$F3,$F3,$F3,$F3,$F4,$F4,$F4 
  DC.B      $F4,$F4,$F4,$F5,$F5,$F5,$F5,$F5 
  DC.B      $F6,$F6,$F6,$F6,$F6,$F7,$F7,$F7 
  DC.B      $F8,$F8,$F8,$F8,$F9,$F9,$F9,$FA 
  DC.B      $FA,$FA,$FA,$FB,$FB,$FB,$FC,$FC 
  DC.B      $FC,$FD,$FD,$FD,$FE,$FE,$FE,$FF 
  DC.B      $FF,$FF,$00,$00,$00,$00,$00,$01 
  DC.B      $01,$02,$02,$02,$03,$03,$04,$04 
  DC.B      $04,$05,$05,$06,$06,$06,$07,$07 
  DC.B      $08,$08,$08,$09,$09,$09,$0A,$0A 
  DC.B      $0A,$0B,$0B,$0B,$0C,$0C,$0C,$0C 
  DC.B      $0D,$0D,$0D,$0D,$0E,$0E,$0E,$0E 
  DC.B      $0E,$0F,$0F,$0F,$0F,$0F,$10,$10 
  DC.B      $10,$10,$10,$10,$10,$10,$10,$10 
  DC.B      $10,$10,$10,$10,$10,$10,$10,$10 
  DC.B      $10,$10,$10,$10,$10,$10,$10,$10 
  DC.B      $10,$10,$10,$0F,$0F,$0F,$0F,$0F 
  DC.B      $0E,$0E,$0E,$0E,$0E,$0D,$0D,$0D 
  DC.B      $0D,$0C,$0C,$0C,$0C,$0B,$0B,$0B 
  DC.B      $0A,$0A,$0A,$09,$09,$09,$08,$08 
  DC.B      $08,$07,$07,$06,$06,$06,$05,$05 
  DC.B      $04,$04,$04,$03,$03,$02,$02,$02 
  DC.B      $01,$01,$00,$00,$00,$00,$00,$FF 
  DC.B      $FF,$FE,$FE,$FE,$FD,$FD,$FC,$FC 
  DC.B      $FC,$FB,$FB,$FA,$FA,$FA,$F9,$F9 
  DC.B      $F8,$F8,$F8,$F7,$F7,$F7,$F6,$F6 
  DC.B      $F6,$F5,$F5,$F5,$F4,$F4,$F4,$F4 
  DC.B      $F3,$F3,$F3,$F3,$F2,$F2,$F2,$F2 
  DC.B      $F2,$F1,$F1,$F1,$F1,$F1,$F0,$F0 
  DC.B      $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0 
  DC.B      $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0 
  DC.B      $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0 
  DC.B      $F0,$F0,$F0,$F1,$F1,$F1,$F1,$F1 
  DC.B      $F2,$F2,$F2,$F2,$F2,$F3,$F3,$F3 
  DC.B      $F3,$F4,$F4,$F4,$F4,$F5,$F5,$F5 
  DC.B      $F6,$F6,$F6,$F7,$F7,$F7,$F8,$F8 
  DC.B      $F8,$F9,$F9,$FA,$FA,$FA,$FB,$FB 
  DC.B      $FC,$FC,$FC,$FD,$FD,$FE,$FE,$FE 
  DC.B      $FF,$FF,$00,$00,$00,$00,$00,$01 
  DC.B      $01,$02,$02,$03,$03,$04,$04,$05 
  DC.B      $05,$06,$06,$07,$07,$08,$08,$08 
  DC.B      $09,$09,$0A,$0A,$0B,$0B,$0B,$0C 
  DC.B      $0C,$0C,$0D,$0D,$0E,$0E,$0E,$0F 
  DC.B      $0F,$0F,$0F,$10,$10,$10,$11,$11 
  DC.B      $11,$11,$11,$12,$12,$12,$12,$12 
  DC.B      $12,$13,$13,$13,$13,$13,$13,$13 
  DC.B      $13,$13,$13,$13,$13,$13,$13,$13 
  DC.B      $13,$13,$13,$13,$13,$13,$13,$13 
  DC.B      $12,$12,$12,$12,$12,$12,$11,$11 
  DC.B      $11,$11,$11,$10,$10,$10,$0F,$0F 
  DC.B      $0F,$0F,$0E,$0E,$0E,$0D,$0D,$0C 
  DC.B      $0C,$0C,$0B,$0B,$0B,$0A,$0A,$09 
  DC.B      $09,$08,$08,$08,$07,$07,$06,$06 
  DC.B      $05,$05,$04,$04,$03,$03,$02,$02 
  DC.B      $01,$01,$00,$00,$00,$00,$00,$FF 
  DC.B      $FF,$FE,$FE,$FD,$FD,$FC,$FC,$FB 
  DC.B      $FB,$FA,$FA,$F9,$F9,$F8,$F8,$F8 
  DC.B      $F7,$F7,$F6,$F6,$F5,$F5,$F5,$F4 
  DC.B      $F4,$F4,$F3,$F3,$F2,$F2,$F2,$F1 
  DC.B      $F1,$F1,$F1,$F0,$F0,$F0,$EF,$EF 
  DC.B      $EF,$EF,$EF,$EE,$EE,$EE,$EE,$EE 
  DC.B      $EE,$ED,$ED,$ED,$ED,$ED,$ED,$ED 
  DC.B      $ED,$ED,$ED,$ED,$ED,$ED,$ED,$ED 
  DC.B      $ED,$ED,$ED,$ED,$ED,$ED,$ED,$ED 
  DC.B      $EE,$EE,$EE,$EE,$EE,$EE,$EF,$EF 
  DC.B      $EF,$EF,$EF,$F0,$F0,$F0,$F1,$F1 
  DC.B      $F1,$F1,$F2,$F2,$F2,$F3,$F3,$F4 
  DC.B      $F4,$F4,$F5,$F5,$F5,$F6,$F6,$F7 
  DC.B      $F7,$F8,$F8,$F8,$F9,$F9,$FA,$FA 
  DC.B      $FB,$FB,$FC,$FC,$FD,$FD,$FE,$FE 
  DC.B      $FF,$FF,$00,$00,$00,$00,$01,$01 
  DC.B      $02,$02,$03,$03,$04,$04,$05,$06 
  DC.B      $06,$07,$07,$08,$08,$09,$09,$0A 
  DC.B      $0A,$0B,$0B,$0C,$0C,$0D,$0D,$0D 
  DC.B      $0E,$0E,$0F,$0F,$10,$10,$10,$11 
  DC.B      $11,$11,$12,$12,$12,$13,$13,$13 
  DC.B      $13,$14,$14,$14,$14,$15,$15,$15 
  DC.B      $15,$15,$15,$16,$16,$16,$16,$16 
  DC.B      $16,$16,$16,$16,$16,$16,$16,$16 
  DC.B      $16,$16,$16,$16,$16,$16,$15,$15 
  DC.B      $15,$15,$15,$15,$14,$14,$14,$14 
  DC.B      $13,$13,$13,$13,$12,$12,$12,$11 
  DC.B      $11,$11,$10,$10,$10,$0F,$0F,$0E 
  DC.B      $0E,$0D,$0D,$0D,$0C,$0C,$0B,$0B 
  DC.B      $0A,$0A,$09,$09,$08,$08,$07,$07 
  DC.B      $06,$06,$05,$04,$04,$03,$03,$02 
  DC.B      $02,$01,$01,$00,$00,$00,$FF,$FF 
  DC.B      $FE,$FE,$FD,$FD,$FC,$FC,$FB,$FA 
  DC.B      $FA,$F9,$F9,$F8,$F8,$F7,$F7,$F6 
  DC.B      $F6,$F5,$F5,$F4,$F4,$F3,$F3,$F3 
  DC.B      $F2,$F2,$F1,$F1,$F0,$F0,$F0,$EF 
  DC.B      $EF,$EF,$EE,$EE,$EE,$ED,$ED,$ED 
  DC.B      $ED,$EC,$EC,$EC,$EC,$EB,$EB,$EB 
  DC.B      $EB,$EB,$EB,$EA,$EA,$EA,$EA,$EA 
  DC.B      $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA 
  DC.B      $EA,$EA,$EA,$EA,$EA,$EA,$EB,$EB 
  DC.B      $EB,$EB,$EB,$EB,$EC,$EC,$EC,$EC 
  DC.B      $ED,$ED,$ED,$ED,$EE,$EE,$EE,$EF 
  DC.B      $EF,$EF,$F0,$F0,$F0,$F1,$F1,$F2 
  DC.B      $F2,$F3,$F3,$F3,$F4,$F4,$F5,$F5 
  DC.B      $F6,$F6,$F7,$F7,$F8,$F8,$F9,$F9 
  DC.B      $FA,$FA,$FB,$FC,$FC,$FD,$FD,$FE 
  DC.B      $FE,$FF,$FF,$00,$00,$00,$01,$01 
  DC.B      $02,$03,$03,$04,$04,$05,$06,$06 
  DC.B      $07,$07,$08,$09,$09,$0A,$0A,$0B 
  DC.B      $0C,$0C,$0D,$0D,$0E,$0E,$0F,$0F 
  DC.B      $10,$10,$11,$11,$12,$12,$12,$13 
  DC.B      $13,$14,$14,$14,$15,$15,$15,$16 
  DC.B      $16,$16,$17,$17,$17,$17,$18,$18 
  DC.B      $18,$18,$18,$18,$19,$19,$19,$19 
  DC.B      $19,$19,$19,$19,$19,$19,$19,$19 
  DC.B      $19,$19,$19,$19,$19,$18,$18,$18 
  DC.B      $18,$18,$18,$17,$17,$17,$17,$16 
  DC.B      $16,$16,$15,$15,$15,$14,$14,$14 
  DC.B      $13,$13,$12,$12,$12,$11,$11,$10 
  DC.B      $10,$0F,$0F,$0E,$0E,$0D,$0D,$0C 
  DC.B      $0C,$0B,$0A,$0A,$09,$09,$08,$07 
  DC.B      $07,$06,$06,$05,$04,$04,$03,$03 
  DC.B      $02,$01,$01,$00,$00,$00,$FF,$FF 
  DC.B      $FE,$FD,$FD,$FC,$FC,$FB,$FA,$FA 
  DC.B      $F9,$F9,$F8,$F7,$F7,$F6,$F6,$F5 
  DC.B      $F4,$F4,$F3,$F3,$F2,$F2,$F1,$F1 
  DC.B      $F0,$F0,$EF,$EF,$EE,$EE,$EE,$ED 
  DC.B      $ED,$EC,$EC,$EC,$EB,$EB,$EB,$EA 
  DC.B      $EA,$EA,$E9,$E9,$E9,$E9,$E8,$E8 
  DC.B      $E8,$E8,$E8,$E8,$E7,$E7,$E7,$E7 
  DC.B      $E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7 
  DC.B      $E7,$E7,$E7,$E7,$E7,$E8,$E8,$E8 
  DC.B      $E8,$E8,$E8,$E9,$E9,$E9,$E9,$EA 
  DC.B      $EA,$EA,$EB,$EB,$EB,$EC,$EC,$EC 
  DC.B      $ED,$ED,$EE,$EE,$EE,$EF,$EF,$F0 
  DC.B      $F0,$F1,$F1,$F2,$F2,$F3,$F3,$F4 
  DC.B      $F4,$F5,$F6,$F6,$F7,$F7,$F8,$F9 
  DC.B      $F9,$FA,$FA,$FB,$FC,$FC,$FD,$FD 
  DC.B      $FE,$FF,$FF,$00,$00,$00,$01,$02 
  DC.B      $02,$03,$04,$04,$05,$06,$06,$07 
  DC.B      $08,$08,$09,$0A,$0A,$0B,$0C,$0C 
  DC.B      $0D,$0D,$0E,$0F,$0F,$10,$10,$11 
  DC.B      $11,$12,$13,$13,$14,$14,$14,$15 
  DC.B      $15,$16,$16,$17,$17,$17,$18,$18 
  DC.B      $18,$19,$19,$19,$1A,$1A,$1A,$1A 
  DC.B      $1B,$1B,$1B,$1B,$1B,$1B,$1C,$1C 
  DC.B      $1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C 
  DC.B      $1C,$1C,$1C,$1B,$1B,$1B,$1B,$1B 
  DC.B      $1B,$1A,$1A,$1A,$1A,$19,$19,$19 
  DC.B      $18,$18,$18,$17,$17,$17,$16,$16 
  DC.B      $15,$15,$14,$14,$14,$13,$13,$12 
  DC.B      $11,$11,$10,$10,$0F,$0F,$0E,$0D 
  DC.B      $0D,$0C,$0C,$0B,$0A,$0A,$09,$08 
  DC.B      $08,$07,$06,$06,$05,$04,$04,$03 
  DC.B      $02,$02,$01,$00,$00,$00,$FF,$FE 
  DC.B      $FE,$FD,$FC,$FC,$FB,$FA,$FA,$F9 
  DC.B      $F8,$F8,$F7,$F6,$F6,$F5,$F4,$F4 
  DC.B      $F3,$F3,$F2,$F1,$F1,$F0,$F0,$EF 
  DC.B      $EF,$EE,$ED,$ED,$EC,$EC,$EC,$EB 
  DC.B      $EB,$EA,$EA,$E9,$E9,$E9,$E8,$E8 
  DC.B      $E8,$E7,$E7,$E7,$E6,$E6,$E6,$E6 
  DC.B      $E5,$E5,$E5,$E5,$E5,$E5,$E4,$E4 
  DC.B      $E4,$E4,$E4,$E4,$E4,$E4,$E4,$E4 
  DC.B      $E4,$E4,$E4,$E5,$E5,$E5,$E5,$E5 
  DC.B      $E5,$E6,$E6,$E6,$E6,$E7,$E7,$E7 
  DC.B      $E8,$E8,$E8,$E9,$E9,$E9,$EA,$EA 
  DC.B      $EB,$EB,$EC,$EC,$EC,$ED,$ED,$EE 
  DC.B      $EF,$EF,$F0,$F0,$F1,$F1,$F2,$F3 
  DC.B      $F3,$F4,$F4,$F5,$F6,$F6,$F7,$F8 
  DC.B      $F8,$F9,$FA,$FA,$FB,$FC,$FC,$FD 
  DC.B      $FE,$FE,$FF,$00,$00,$00,$01,$02 
  DC.B      $03,$03,$04,$05,$06,$06,$07,$08 
  DC.B      $09,$09,$0A,$0B,$0B,$0C,$0D,$0E 
  DC.B      $0E,$0F,$10,$10,$11,$11,$12,$13 
  DC.B      $13,$14,$14,$15,$16,$16,$17,$17 
  DC.B      $18,$18,$19,$19,$19,$1A,$1A,$1B 
  DC.B      $1B,$1B,$1C,$1C,$1C,$1D,$1D,$1D 
  DC.B      $1D,$1E,$1E,$1E,$1E,$1E,$1E,$1E 
  DC.B      $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F 
  DC.B      $1F,$1E,$1E,$1E,$1E,$1E,$1E,$1E 
  DC.B      $1D,$1D,$1D,$1D,$1C,$1C,$1C,$1B 
  DC.B      $1B,$1B,$1A,$1A,$19,$19,$19,$18 
  DC.B      $18,$17,$17,$16,$16,$15,$14,$14 
  DC.B      $13,$13,$12,$11,$11,$10,$10,$0F 
  DC.B      $0E,$0E,$0D,$0C,$0B,$0B,$0A,$09 
  DC.B      $09,$08,$07,$06,$06,$05,$04,$03 
  DC.B      $03,$02,$01,$00,$00,$00,$FF,$FE 
  DC.B      $FD,$FD,$FC,$FB,$FA,$FA,$F9,$F8 
  DC.B      $F7,$F7,$F6,$F5,$F5,$F4,$F3,$F2 
  DC.B      $F2,$F1,$F0,$F0,$EF,$EF,$EE,$ED 
  DC.B      $ED,$EC,$EC,$EB,$EA,$EA,$E9,$E9 
  DC.B      $E8,$E8,$E7,$E7,$E7,$E6,$E6,$E5 
  DC.B      $E5,$E5,$E4,$E4,$E4,$E3,$E3,$E3 
  DC.B      $E3,$E2,$E2,$E2,$E2,$E2,$E2,$E2 
  DC.B      $E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1 
  DC.B      $E1,$E2,$E2,$E2,$E2,$E2,$E2,$E2 
  DC.B      $E3,$E3,$E3,$E3,$E4,$E4,$E4,$E5 
  DC.B      $E5,$E5,$E6,$E6,$E7,$E7,$E7,$E8 
  DC.B      $E8,$E9,$E9,$EA,$EA,$EB,$EC,$EC 
  DC.B      $ED,$ED,$EE,$EF,$EF,$F0,$F0,$F1 
  DC.B      $F2,$F2,$F3,$F4,$F5,$F5,$F6,$F7 
  DC.B      $F7,$F8,$F9,$FA,$FA,$FB,$FC,$FD 
  DC.B      $FD,$FE,$FF,$00,$00,$00,$01,$02 
  DC.B      $03,$04,$04,$05,$06,$07,$08,$09 
  DC.B      $09,$0A,$0B,$0C,$0D,$0D,$0E,$0F 
  DC.B      $10,$10,$11,$12,$12,$13,$14,$14 
  DC.B      $15,$16,$16,$17,$18,$18,$19,$19 
  DC.B      $1A,$1A,$1B,$1B,$1C,$1C,$1D,$1D 
  DC.B      $1D,$1E,$1E,$1F,$1F,$1F,'  '
  DC.B      '   !!!!!'
  DC.B      '!!!!!!!!'
  DC.B      '!!!!!!  '
  DC.B      '   ',$1F,$1F,$1F,$1E,$1E 
  DC.B      $1D,$1D,$1D,$1C,$1C,$1B,$1B,$1A 
  DC.B      $1A,$19,$19,$18,$18,$17,$16,$16 
  DC.B      $15,$14,$14,$13,$12,$12,$11,$10 
  DC.B      $10,$0F,$0E,$0D,$0D,$0C,$0B,$0A 
  DC.B      $09,$09,$08,$07,$06,$05,$04,$04 
  DC.B      $03,$02,$01,$00,$00,$00,$FF,$FE 
  DC.B      $FD,$FC,$FC,$FB,$FA,$F9,$F8,$F7 
  DC.B      $F7,$F6,$F5,$F4,$F3,$F3,$F2,$F1 
  DC.B      $F0,$F0,$EF,$EE,$EE,$ED,$EC,$EC 
  DC.B      $EB,$EA,$EA,$E9,$E8,$E8,$E7,$E7 
  DC.B      $E6,$E6,$E5,$E5,$E4,$E4,$E3,$E3 
  DC.B      $E3,$E2,$E2,$E1,$E1,$E1,$E0,$E0 
  DC.B      $E0,$E0,$E0,$DF,$DF,$DF,$DF,$DF 
  DC.B      $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF 
  DC.B      $DF,$DF,$DF,$DF,$DF,$DF,$E0,$E0 
  DC.B      $E0,$E0,$E0,$E1,$E1,$E1,$E2,$E2 
  DC.B      $E3,$E3,$E3,$E4,$E4,$E5,$E5,$E6 
  DC.B      $E6,$E7,$E7,$E8,$E8,$E9,$EA,$EA 
  DC.B      $EB,$EC,$EC,$ED,$EE,$EE,$EF,$F0 
  DC.B      $F0,$F1,$F2,$F3,$F3,$F4,$F5,$F6 
  DC.B      $F7,$F7,$F8,$F9,$FA,$FB,$FC,$FC 
  DC.B      $FD,$FE,$FF,$00,$00,$00,$01,$02 
  DC.B      $03,$04,$05,$06,$07,$08,$08,$09 
  DC.B      $0A,$0B,$0C,$0D,$0E,$0E,$0F,$10 
  DC.B      $11,$12,$12,$13,$14,$15,$15,$16 
  DC.B      $17,$18,$18,$19,$1A,$1A,$1B,$1B 
  DC.B      $1C,$1D,$1D,$1E,$1E,$1F,$1F,' ' 
  DC.B      '  !!""""'
  DC.B      '####$$$$'
  DC.B      '$$$$$$$$'
  DC.B      '$$$$$###'
  DC.B      '#""""!! '
  DC.B      '  ',$1F,$1F,$1E,$1E,$1D,$1D
  DC.B      $1C,$1B,$1B,$1A,$1A,$19,$18,$18 
  DC.B      $17,$16,$15,$15,$14,$13,$12,$12 
  DC.B      $11,$10,$0F,$0E,$0E,$0D,$0C,$0B 
  DC.B      $0A,$09,$08,$08,$07,$06,$05,$04 
  DC.B      $03,$02,$01,$00,$00,$00,$FF,$FE 
  DC.B      $FD,$FC,$FB,$FA,$F9,$F8,$F8,$F7 
  DC.B      $F6,$F5,$F4,$F3,$F2,$F2,$F1,$F0 
  DC.B      $EF,$EE,$EE,$ED,$EC,$EB,$EB,$EA 
  DC.B      $E9,$E8,$E8,$E7,$E6,$E6,$E5,$E5 
  DC.B      $E4,$E3,$E3,$E2,$E2,$E1,$E1,$E0 
  DC.B      $E0,$E0,$DF,$DF,$DE,$DE,$DE,$DE 
  DC.B      $DD,$DD,$DD,$DD,$DC,$DC,$DC,$DC 
  DC.B      $DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC 
  DC.B      $DC,$DC,$DC,$DC,$DC,$DD,$DD,$DD 
  DC.B      $DD,$DE,$DE,$DE,$DE,$DF,$DF,$E0 
  DC.B      $E0,$E0,$E1,$E1,$E2,$E2,$E3,$E3 
  DC.B      $E4,$E5,$E5,$E6,$E6,$E7,$E8,$E8 
  DC.B      $E9,$EA,$EB,$EB,$EC,$ED,$EE,$EE 
  DC.B      $EF,$F0,$F1,$F2,$F2,$F3,$F4,$F5 
  DC.B      $F6,$F7,$F8,$F8,$F9,$FA,$FB,$FC 
  DC.B      $FD,$FE,$FF,$00,$00,$00,$01,$02 
  DC.B      $03,$04,$05,$06,$07,$08,$09,$0A 
  DC.B      $0B,$0C,$0D,$0E,$0F,$10,$10,$11 
  DC.B      $12,$13,$14,$15,$16,$16,$17,$18 
  DC.B      $19,$19,$1A,$1B,$1C,$1C,$1D,$1E 
  DC.B      $1E,$1F,$1F,'  !""' 
  DC.B      '"##$$%%%'
  DC.B      '%&&&&',$27,$27,$27 
  DC.B      $27,$27,$27,$27,$27,$27,$27,$27 
  DC.B      $27,$27,$27,$27,'&&&&'
  DC.B      '%%%%$$##'
  DC.B      '"""!  ',$1F,$1F
  DC.B      $1E,$1E,$1D,$1C,$1C,$1B,$1A,$19 
  DC.B      $19,$18,$17,$16,$16,$15,$14,$13 
  DC.B      $12,$11,$10,$10,$0F,$0E,$0D,$0C 
  DC.B      $0B,$0A,$09,$08,$07,$06,$05,$04 
  DC.B      $03,$02,$01,$00,$00,$00,$FF,$FE 
  DC.B      $FD,$FC,$FB,$FA,$F9,$F8,$F7,$F6 
  DC.B      $F5,$F4,$F3,$F2,$F1,$F0,$F0,$EF 
  DC.B      $EE,$ED,$EC,$EB,$EA,$EA,$E9,$E8 
  DC.B      $E7,$E7,$E6,$E5,$E4,$E4,$E3,$E2 
  DC.B      $E2,$E1,$E1,$E0,$E0,$DF,$DE,$DE 
  DC.B      $DE,$DD,$DD,$DC,$DC,$DB,$DB,$DB 
  DC.B      $DB,$DA,$DA,$DA,$DA,$D9,$D9,$D9 
  DC.B      $D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9 
  DC.B      $D9,$D9,$D9,$D9,$DA,$DA,$DA,$DA 
  DC.B      $DB,$DB,$DB,$DB,$DC,$DC,$DD,$DD 
  DC.B      $DE,$DE,$DE,$DF,$E0,$E0,$E1,$E1 
  DC.B      $E2,$E2,$E3,$E4,$E4,$E5,$E6,$E7 
  DC.B      $E7,$E8,$E9,$EA,$EA,$EB,$EC,$ED 
  DC.B      $EE,$EF,$F0,$F0,$F1,$F2,$F3,$F4 
  DC.B      $F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC 
  DC.B      $FD,$FE,$FF,$00,$00,$01,$02,$03 
  DC.B      $04,$05,$06,$07,$08,$09,$0A,$0B 
  DC.B      $0C,$0D,$0E,$0F,$10,$11,$12,$13 
  DC.B      $14,$14,$15,$16,$17,$18,$19,$1A 
  DC.B      $1A,$1B,$1C,$1D,$1E,$1E,$1F,' ' 
  DC.B      ' !""##$$'
  DC.B      '%%&&',$27,$27,'((' 
  DC.B      '(())))**'
  DC.B      '********'
  DC.B      '***))))('
  DC.B      '(((',$27,$27,'&&%' 
  DC.B      '%$$##""!'
  DC.B      '  ',$1F,$1E,$1E,$1D,$1C,$1B
  DC.B      $1A,$1A,$19,$18,$17,$16,$15,$14 
  DC.B      $14,$13,$12,$11,$10,$0F,$0E,$0D 
  DC.B      $0C,$0B,$0A,$09,$08,$07,$06,$05 
  DC.B      $04,$03,$02,$01,$00,$FF,$FE,$FD 
  DC.B      $FC,$FB,$FA,$F9,$F8,$F7,$F6,$F5 
  DC.B      $F4,$F3,$F2,$F1,$F0,$EF,$EE,$ED 
  DC.B      $EC,$EC,$EB,$EA,$E9,$E8,$E7,$E6 
  DC.B      $E6,$E5,$E4,$E3,$E2,$E2,$E1,$E0 
  DC.B      $E0,$DF,$DE,$DE,$DD,$DD,$DC,$DC 
  DC.B      $DB,$DB,$DA,$DA,$D9,$D9,$D8,$D8 
  DC.B      $D8,$D8,$D7,$D7,$D7,$D7,$D6,$D6 
  DC.B      $D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6 
  DC.B      $D6,$D6,$D6,$D7,$D7,$D7,$D7,$D8 
  DC.B      $D8,$D8,$D8,$D9,$D9,$DA,$DA,$DB 
  DC.B      $DB,$DC,$DC,$DD,$DD,$DE,$DE,$DF 
  DC.B      $E0,$E0,$E1,$E2,$E2,$E3,$E4,$E5 
  DC.B      $E6,$E6,$E7,$E8,$E9,$EA,$EB,$EC 
  DC.B      $EC,$ED,$EE,$EF,$F0,$F1,$F2,$F3 
  DC.B      $F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB 
  DC.B      $FC,$FD,$FE,$FF 

; supexec of YM enable
L00B8:
  MOVEM.L   A0-A6/D0-D7,-(A7) 
  PEA       L00B9(PC) 
  MOVE.W    #$26,-(A7)
  TRAP      #$E 
  ADDQ.L    #6,A7 
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTS 

; enable YM..
L00B9:
  ORI.W     #$700,SR
  MOVE.B    #7,$FF8800.L
  MOVE.B    #$7F,$FF8802.L
  RTS 

L00BA:
  CLR.L     L00D5 
  BCLR      #5,$FFFA13.L
  BCLR      #5,$FFFA0B.L
  BCLR      #5,$FFFA0F.L
  MOVEM.L   A1-A2/D2,-(A7)
  MOVE.W    #5,-(A7)
  MOVE.W    #$1B,-(A7)
  TRAP      #$E 
  ADDQ.L    #4,A7 
  MOVEM.L   (A7)+,A1-A2/D2
  MOVE.W    (A7)+,D1
  MOVE.L    (A7)+,D0
  MOVEA.L   (A7)+,A0
  MOVE.B    #7,$FF8800.L
  MOVE.B    #$7F,$FF8802.L
  RTE 

	ifne	1

SMC:=	0

; basically, this does nothing (because all tone is mute) but waiting for
; this 'hiss' phoneme to end.
ophiss:	move.l	a0,-(a7)
	move.l	d0,-(a7)

	;subq.b	#1,P3ae6
	SUBQ.B	#1,L00D6

	bmi.s	L3144
	
	ifne	SMC
	lea	P20ca(pc),a0
L329a:	addi.b	#$00,L32b2+3
L32a2:	addi.b	#$00,L32b6+3
L32aa:	addi.b	#$00,L32ba+3
L32b2:	move.b	$1000(a0),d0
L32b6:	add.b	$1000(a0),d0
L32ba:	add.b	$1000(a0),d0
	andi.w	#$00ff,d0
	lsl.w	#3,d0
	lea	P32e2(pc),a0
	adda.w	d0,a0
	rept	2
	move.b	(a0)+,GISELECT.w
	move.b	(a0)+,GIDATA.w
	endr
	endc

	move.l	(a7)+,d0
	movea.l	(a7)+,a0
	bclr	#5,ISRA.w
	rte

opwaves:move.l	a0,-(a7)
	move.l	d0,-(a7)
L3144:	move.w	d1,-(a7)

	;subq.b	#1,P3ae6
	subq.b	#1,L00D6

	bpl	L3210

	;move.b	use_rate(pc),P3ae6
	move.b	USE_RATE(PC),L00D6

	;movea.l	P3ae2(pc),a0			; a0: speech buffer pointer
	MOVEA.L	L00D5(PC),A0

	;move.b	(a0)+,P3ae7
	MOVE.B	(A0)+,L00D7 

	;beq	L30f6
	beq	L00BA

	move.b	(a0)+,d0
	beq.s	L31cc
; set channel C amp..
	move.b	#$0a,GISELECT.w
	move.b	d0,GIDATA.w
; set noise frequency..
	move.b	#$06,GISELECT.w
	move.b	(a0)+,GIDATA.w

; arghl! this sets ophiss parameters!
	ifne	SMC
	move.b	(a0)+,L329a+3
	move.b	(a0)+,L32b2+2
	move.b	(a0)+,L32a2+3
	move.b	(a0)+,L32b6+2
	move.b	(a0)+,L32aa+3
	move.b	(a0)+,L32ba+2
	else
	addq	#6,a0	
	endc

	;move.l	a0,P3ae2
	MOVE.L	A0,L00D5

	move.l	#ophiss,TIMAVEC.w
; disable all PSG channels except noise channel C..
	move.b	#$07,GISELECT.w
	move.b	#$5f,GIDATA.w
	bra	L3278

L31cc:	addq.l	#1,a0

	ifne	SMC
	move.b	(a0)+,L3238+3	; set wave A step
	move.b	(a0)+,L3250+2	; set wave A amplitude
	move.b	(a0)+,L3240+3	; set wave B step
	move.b	(a0)+,L3254+2	; set wave B amplitude
	move.b	(a0)+,L3248+3	; set wave C step
	move.b	(a0)+,L3258+2	; set wave C amplitude
	else
	move.l	(a0)+,wave_params
	move.w	(a0)+,wave_params+4
	endc

	move.l	#opwaves,TIMAVEC.w
; disable all noise and tone PSG channels..
	move.b	#$07,GISELECT.w
	move.b	#$7f,GIDATA.w

	;move.l	a0,P3ae2
	MOVE.L	A0,L00D5

L3210:	;subq.b	#1,P3ae8
	SUBQ.B	#1,L00D8

	bpl.s	L3234

; reset wave positions
	;move.b	P3ae7(pc),P3ae8
	MOVE.B	L00D7(PC),L00D8 

	moveq	#$00,d0

	ifne	SMC
	move.b	d0,L3250+3
	move.b	d0,L3254+3
	move.b	d0,L3258+3
	else
	move.l	d0,wave_pos
	endc

L3234:	;lea	P20ca(pc),a0
	LEA	L00B7(PC),A0


	ifne	SMC

; step through the wave..
L3238:	addi.b	#$00,L3250+3
L3240:	addi.b	#$00,L3254+3
L3248:	addi.b	#$00,L3258+3
; mix 3 formants (waves)..
L3250:	move.b	$1000(a0),d0
L3254:	add.b	$1000(a0),d0
L3258:	add.b	$1000(a0),d0

	else

; step through the wave..
	move.b	wave_a_step(pc),d0
	add.b	d0,wave_a_pos
	move.b	wave_b_step(pc),d0
	add.b	d0,wave_b_pos
	move.b	wave_c_step(pc),d0
	add.b	d0,wave_c_pos
; mix 3 formants (waves)..
	move.b	wave_a_amp,d1
	lsl.w	#8,d1
	move.b	wave_a_pos,d1
	move.b	(a0,d1.w),d0
	move.b	wave_b_amp,d1
	lsl.w	#8,d1
	move.b	wave_b_pos,d1
	add.b	(a0,d1.w),d0
	move.b	wave_c_amp,d1
	lsl.w	#8,d1
	move.b	wave_c_pos,d1
	add.b	(a0,d1.w),d0

	endc

; d0.b=sample (signed)
	andi.w	#$ff,d0
	lsl.w	#3,d0			; $0000..$07F8

	;lea	P32e2(pc,d0.w),a0
	LEA	L00D4(PC,D0.W),A0 

	ifne	1

	movem.l	a1-a2,-(sp)
	lea	GISELECT.w,a1
	lea	GIDATA.w,a2
	rept	3
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	endr
	movem.l	(sp)+,a1-a2

	else

	move.l	(a0)+,d0
	move	(a0),d1
	lea	GISELECT.w,a0
	movep.l	d0,0(a0)
	movep.w	d1,0(a0)

	endc

L3278:	move.w	(a7)+,d1
	move.l	(a7)+,d0
	movea.l	(a7)+,a0
	bclr	#5,ISRA.w
	rte


	else

OPWAVES:
  MOVE.L    A0,-(A7)
  MOVE.L    D0,-(A7)
L00BC:
  MOVE.W    D1,-(A7)
  SUBQ.B    #1,L00D6
  BPL       L00BE 
  MOVE.B    USE_RATE(PC),L00D6
  MOVEA.L   L00D5(PC),A0
  MOVE.B    (A0)+,L00D7 
  BEQ.S     L00BA 
  MOVE.B    (A0)+,D0
  BEQ       L00BD 
  MOVE.B    #$A,$FF8800.L 
  MOVE.B    D0,$FF8802.L
  MOVE.B    #6,$FF8800.L
  MOVE.B    (A0)+,$FF8802.L 
  MOVE.B    (A0)+,L00CB 
  MOVE.B    (A0)+,L00CE 
  MOVE.B    (A0)+,L00CC 
  MOVE.B    (A0)+,L00D0 
  MOVE.B    (A0)+,L00CD 
  MOVE.B    (A0)+,L00D2 
  MOVE.L    A0,L00D5
  MOVE.L    #OPHISS,$134.W
  MOVE.B    #7,$FF8800.L
  MOVE.B    #$5F,$FF8802.L
  BRA       L00C9 
L00BD:
  ADDQ.L    #1,A0 
  MOVE.B    (A0)+,L00C0 
  MOVE.B    (A0)+,L00C3 
  MOVE.B    (A0)+,L00C1 
  MOVE.B    (A0)+,L00C5 
  MOVE.B    (A0)+,L00C2 
  MOVE.B    (A0)+,L00C7 
  MOVE.L    #opwaves,$134.W 
  MOVE.B    #7,$FF8800.L
  MOVE.B    #$7F,$FF8802.L
  MOVE.L    A0,L00D5
L00BE:
  SUBQ.B    #1,L00D8
  BPL.S     L00BF 
  MOVE.B    L00D7(PC),L00D8 
  MOVEQ     #0,D0 
  MOVE.B    D0,L00C4
  MOVE.B    D0,L00C6
  MOVE.B    D0,L00C8
L00BF:
  LEA       L00B7(PC),A0
  ADDI.B    #0,L00C4
L00C0             EQU       *-5 
  ADDI.B    #0,L00C6
L00C1             EQU       *-5 
  ADDI.B    #0,L00C8
L00C2             EQU       *-5 
  MOVE.B    4096(A0),D0 
L00C3             EQU       *-2 
L00C4             EQU       *-1 
  ADD.B     4096(A0),D0 
L00C5             EQU       *-2 
L00C6             EQU       *-1 
  ADD.B     4096(A0),D0 
L00C7             EQU       *-2 
L00C8             EQU       *-1 
  ANDI.W    #$FF,D0 
  LSL.W     #3,D0 
  LEA       L00D4(PC,D0.W),A0 
  MOVE.L    (A0)+,D0
  MOVE.W    (A0),D1 
  LEA       $FF8800.L,A0
  MOVEP.L   D0,0(A0)
  MOVEP.W   D1,0(A0)
L00C9:
  MOVE.W    (A7)+,D1
  MOVE.L    (A7)+,D0
  MOVEA.L   (A7)+,A0
  BCLR      #5,$FFFA0F.L
  RTE 

OPHISS
  MOVE.L    A0,-(A7)
  MOVE.L    D0,-(A7)
  SUBQ.B    #1,L00D6
  BMI       L00BC 
  LEA       L00B7(PC),A0
  ADDI.B    #0,L00CF
L00CB             EQU       *-5 
  ADDI.B    #0,L00D1
L00CC             EQU       *-5 
  ADDI.B    #0,L00D3
L00CD             EQU       *-5 
  MOVE.B    4096(A0),D0 
L00CE             EQU       *-2 
L00CF             EQU       *-1 
  ADD.B     4096(A0),D0 
L00D0             EQU       *-2 
L00D1             EQU       *-1 
  ADD.B     4096(A0),D0 
L00D2             EQU       *-2 
L00D3             EQU       *-1 
  ANDI.W    #$FF,D0 
  LSL.W     #3,D0 
  LEA       L00D4(PC,D0.W),A0 
  MOVE.L    (A0)+,D0
  LEA       $FF8800.L,A0
  MOVEP.L   D0,0(A0)
  MOVE.L    (A7)+,D0
  MOVEA.L   (A7)+,A0
  BCLR      #5,$FFFA0F.L
  RTE 

	endc

L00D4:
  DC.B      $08,$0C,$09,$0B,$0A,$09,$00,$00 
  DC.B      $08,$0C,$09,$0B,$0A,$09,$00,$00 
  DC.B      $08,$0D,$09,$08,$0A,$08,$00,$00 
  DC.B      $08,$0B,$09,$0B,$0A,$0B,$00,$00 
  DC.B      $08,$0D,$09,$09,$0A,$05,$00,$00 
  DC.B      $08,$0C,$09,$0B,$0A,$08,$00,$00 
  DC.B      $08,$0D,$09,$09,$0A,$02,$00,$00 
  DC.B      $08,$0D,$09,$08,$0A,$06,$00,$00 
  DC.B      $08,$0C,$09,$0B,$0A,$07,$00,$00 
  DC.B      $08,$0D,$09,$07,$0A,$07,$00,$00 
  DC.B      $08,$0C,$09,$0B,$0A,$06,$00,$00 
  DC.B      $08,$0C,$09,$0A,$0A,$09,$00,$00 
  DC.B      $08,$0B,$09,$0B,$0A,$0A,$00,$00 
  DC.B      $08,$0C,$09,$0B,$0A,$02,$00,$00 
  DC.B      $08,$0C,$09,$0B,$0A,$00,$00,$00 
  DC.B      $08,$0C,$09,$0A,$0A,$08,$00,$00 
  DC.B      $08,$0D,$09,$06,$0A,$04,$00,$00 
  DC.B      $08,$0D,$09,$05,$0A,$05,$00,$00 
  DC.B      $08,$0D,$09,$05,$0A,$04,$00,$00 
  DC.B      $08,$0C,$09,$09,$0A,$09,$00,$00 
  DC.B      $08,$0D,$09,$04,$0A,$03,$00,$00 
  DC.B      $08,$0B,$09,$0B,$0A,$09,$00,$00 
  DC.B      $08,$0C,$09,$0A,$0A,$05,$00,$00 
  DC.B      $08,$0B,$09,$0A,$0A,$0A,$00,$00 
  DC.B      $08,$0C,$09,$09,$0A,$08,$00,$00 
  DC.B      $08,$0B,$09,$0B,$0A,$08,$00,$00 
  DC.B      $08,$0C,$09,$0A,$0A,$00,$00,$00 
  DC.B      $08,$0C,$09,$0A,$0A,$00,$00,$00 
  DC.B      $08,$0C,$09,$09,$0A,$07,$00,$00 
  DC.B      $08,$0B,$09,$0B,$0A,$07,$00,$00 
  DC.B      $08,$0C,$09,$09,$0A,$06,$00,$00 
  DC.B      $08,$0B,$09,$0B,$0A,$06,$00,$00 
  DC.B      $08,$0B,$09,$0A,$0A,$09,$00,$00 
  DC.B      $08,$0B,$09,$0B,$0A,$05,$00,$00 
  DC.B      $08,$0A,$09,$0A,$0A,$0A,$00,$00 
  DC.B      $08,$0B,$09,$0B,$0A,$02,$00,$00 
  DC.B      $08,$0B,$09,$0A,$0A,$08,$00,$00 
  DC.B      $08,$0C,$09,$07,$0A,$07,$00,$00 
  DC.B      $08,$0C,$09,$08,$0A,$04,$00,$00 
  DC.B      $08,$0C,$09,$07,$0A,$06,$00,$00 
  DC.B      $08,$0B,$09,$09,$0A,$09,$00,$00 
  DC.B      $08,$0C,$09,$06,$0A,$06,$00,$00 
  DC.B      $08,$0A,$09,$0A,$0A,$09,$00,$00 
  DC.B      $08,$0C,$09,$07,$0A,$03,$00,$00 
  DC.B      $08,$0B,$09,$0A,$0A,$05,$00,$00 
  DC.B      $08,$0B,$09,$09,$0A,$08,$00,$00 
  DC.B      $08,$0B,$09,$0A,$0A,$03,$00,$00 
  DC.B      $08,$0A,$09,$0A,$0A,$08,$00,$00 
  DC.B      $08,$0B,$09,$0A,$0A,$00,$00,$00 
  DC.B      $08,$0B,$09,$09,$0A,$07,$00,$00 
  DC.B      $08,$0B,$09,$08,$0A,$08,$00,$00 
  DC.B      $08,$0A,$09,$0A,$0A,$07,$00,$00 
  DC.B      $08,$0A,$09,$09,$0A,$09,$00,$00 
  DC.B      $08,$0C,$09,$01,$0A,$01,$00,$00 
  DC.B      $08,$0A,$09,$0A,$0A,$06,$00,$00 
  DC.B      $08,$0B,$09,$08,$0A,$07,$00,$00 
  DC.B      $08,$0A,$09,$0A,$0A,$05,$00,$00 
  DC.B      $08,$0A,$09,$09,$0A,$08,$00,$00 
  DC.B      $08,$0A,$09,$0A,$0A,$02,$00,$00 
  DC.B      $08,$0A,$09,$0A,$0A,$01,$00,$00 
  DC.B      $08,$0A,$09,$0A,$0A,$00,$00,$00 
  DC.B      $08,$09,$09,$09,$0A,$09,$00,$00 
  DC.B      $08,$0A,$09,$08,$0A,$08,$00,$00 
  DC.B      $08,$0B,$09,$08,$0A,$01,$00,$00 
  DC.B      $08,$0A,$09,$09,$0A,$06,$00,$00 
  DC.B      $08,$0B,$09,$07,$0A,$04,$00,$00 
  DC.B      $08,$0A,$09,$09,$0A,$05,$00,$00 
  DC.B      $08,$09,$09,$09,$0A,$08,$00,$00 
  DC.B      $08,$0A,$09,$09,$0A,$03,$00,$00 
  DC.B      $08,$0A,$09,$08,$0A,$06,$00,$00 
  DC.B      $08,$0A,$09,$09,$0A,$00,$00,$00 
  DC.B      $08,$09,$09,$09,$0A,$07,$00,$00 
  DC.B      $08,$09,$09,$08,$0A,$08,$00,$00 
  DC.B      $08,$0A,$09,$08,$0A,$04,$00,$00 
  DC.B      $08,$09,$09,$09,$0A,$06,$00,$00 
  DC.B      $08,$0A,$09,$08,$0A,$01,$00,$00 
  DC.B      $08,$09,$09,$09,$0A,$05,$00,$00 
  DC.B      $08,$09,$09,$08,$0A,$07,$00,$00 
  DC.B      $08,$08,$09,$08,$0A,$08,$00,$00 
  DC.B      $08,$09,$09,$09,$0A,$02,$00,$00 
  DC.B      $08,$09,$09,$08,$0A,$06,$00,$00 
  DC.B      $08,$09,$09,$09,$0A,$00,$00,$00 
  DC.B      $08,$09,$09,$07,$0A,$07,$00,$00 
  DC.B      $08,$08,$09,$08,$0A,$07,$00,$00 
  DC.B      $08,$09,$09,$07,$0A,$06,$00,$00 
  DC.B      $08,$09,$09,$08,$0A,$02,$00,$00 
  DC.B      $08,$08,$09,$08,$0A,$06,$00,$00 
  DC.B      $08,$09,$09,$06,$0A,$06,$00,$00 
  DC.B      $08,$08,$09,$07,$0A,$07,$00,$00 
  DC.B      $08,$08,$09,$08,$0A,$04,$00,$00 
  DC.B      $08,$08,$09,$07,$0A,$06,$00,$00 
  DC.B      $08,$08,$09,$08,$0A,$02,$00,$00 
  DC.B      $08,$07,$09,$07,$0A,$07,$00,$00 
  DC.B      $08,$08,$09,$06,$0A,$06,$00,$00 
  DC.B      $08,$08,$09,$07,$0A,$04,$00,$00 
  DC.B      $08,$07,$09,$07,$0A,$06,$00,$00 
  DC.B      $08,$08,$09,$06,$0A,$05,$00,$00 
  DC.B      $08,$08,$09,$06,$0A,$04,$00,$00 
  DC.B      $08,$07,$09,$06,$0A,$06,$00,$00 
  DC.B      $08,$07,$09,$07,$0A,$04,$00,$00 
  DC.B      $08,$08,$09,$05,$0A,$04,$00,$00 
  DC.B      $08,$06,$09,$06,$0A,$06,$00,$00 
  DC.B      $08,$07,$09,$06,$0A,$04,$00,$00 
  DC.B      $08,$07,$09,$05,$0A,$05,$00,$00 
  DC.B      $08,$06,$09,$06,$0A,$05,$00,$00 
  DC.B      $08,$06,$09,$06,$0A,$04,$00,$00 
  DC.B      $08,$06,$09,$05,$0A,$05,$00,$00 
  DC.B      $08,$06,$09,$06,$0A,$02,$00,$00 
  DC.B      $08,$06,$09,$05,$0A,$04,$00,$00 
  DC.B      $08,$05,$09,$05,$0A,$05,$00,$00 
  DC.B      $08,$06,$09,$05,$0A,$02,$00,$00 
  DC.B      $08,$05,$09,$05,$0A,$04,$00,$00 
  DC.B      $08,$05,$09,$04,$0A,$04,$00,$00 
  DC.B      $08,$05,$09,$05,$0A,$02,$00,$00 
  DC.B      $08,$04,$09,$04,$0A,$04,$00,$00 
  DC.B      $08,$04,$09,$04,$0A,$03,$00,$00 
  DC.B      $08,$04,$09,$04,$0A,$02,$00,$00 
  DC.B      $08,$04,$09,$03,$0A,$03,$00,$00 
  DC.B      $08,$03,$09,$03,$0A,$03,$00,$00 
  DC.B      $08,$03,$09,$03,$0A,$02,$00,$00 
  DC.B      $08,$03,$09,$02,$0A,$02,$00,$00 
  DC.B      $08,$02,$09,$02,$0A,$02,$00,$00 
  DC.B      $08,$02,$09,$02,$0A,$01,$00,$00 
  DC.B      $08,$01,$09,$01,$0A,$01,$00,$00 
  DC.B      $08,$02,$09,$01,$0A,$00,$00,$00 
  DC.B      $08,$01,$09,$01,$0A,$00,$00,$00 
  DC.B      $08,$01,$09,$00,$0A,$00,$00,$00 
  DC.B      $08,$00,$09,$00,$0A,$00,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0C,$00,$00 
  DC.B      $08,$0F,$09,$03,$0A,$00,$00,$00 
  DC.B      $08,$0F,$09,$03,$0A,$00,$00,$00 
  DC.B      $08,$0F,$09,$03,$0A,$00,$00,$00 
  DC.B      $08,$0F,$09,$03,$0A,$00,$00,$00 
  DC.B      $08,$0F,$09,$03,$0A,$00,$00,$00 
  DC.B      $08,$0F,$09,$03,$0A,$00,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0C,$00,$00 
  DC.B      $08,$0E,$09,$0D,$0A,$00,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0D,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0D,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0D,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0D,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0D,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0D,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$0A,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0C,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0C,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$09,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$09,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$05,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$00,$00,$00 
  DC.B      $08,$0E,$09,$0C,$0A,$00,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$0A,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$09,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$09,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$09,$00,$00 
  DC.B      $08,$0D,$09,$0C,$0A,$0C,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$07,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$00,$00,$00 
  DC.B      $08,$0E,$09,$0B,$0A,$00,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$09,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$09,$00,$00 
  DC.B      $08,$0E,$09,$0A,$0A,$09,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$08,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$07,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$04,$00,$00 
  DC.B      $08,$0D,$09,$0D,$0A,$00,$00,$00 
  DC.B      $08,$0E,$09,$0A,$0A,$04,$00,$00 
  DC.B      $08,$0E,$09,$09,$0A,$09,$00,$00 
  DC.B      $08,$0E,$09,$09,$0A,$09,$00,$00 
  DC.B      $08,$0D,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$09,$0A,$08,$00,$00 
  DC.B      $08,$0E,$09,$09,$0A,$08,$00,$00 
  DC.B      $08,$0E,$09,$09,$0A,$07,$00,$00 
  DC.B      $08,$0E,$09,$08,$0A,$08,$00,$00 
  DC.B      $08,$0E,$09,$09,$0A,$01,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$0C,$00,$00 
  DC.B      $08,$0D,$09,$0C,$0A,$0A,$00,$00 
  DC.B      $08,$0E,$09,$08,$0A,$06,$00,$00 
  DC.B      $08,$0E,$09,$07,$0A,$07,$00,$00 
  DC.B      $08,$0E,$09,$08,$0A,$00,$00,$00 
  DC.B      $08,$0E,$09,$07,$0A,$05,$00,$00 
  DC.B      $08,$0E,$09,$06,$0A,$06,$00,$00 
  DC.B      $08,$0D,$09,$0C,$0A,$09,$00,$00 
  DC.B      $08,$0E,$09,$05,$0A,$05,$00,$00 
  DC.B      $08,$0E,$09,$04,$0A,$04,$00,$00 
  DC.B      $08,$0D,$09,$0C,$0A,$08,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$0B,$00,$00 
  DC.B      $08,$0E,$09,$00,$0A,$00,$00,$00 
  DC.B      $08,$0D,$09,$0C,$0A,$06,$00,$00 
  DC.B      $08,$0D,$09,$0C,$0A,$05,$00,$00 
  DC.B      $08,$0D,$09,$0C,$0A,$02,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$0B,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$0A,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$0A,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$0A,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$0A,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$0A,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$0A,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$0A,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$09,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$09,$00,$00 
  DC.B      $08,$0D,$09,$0A,$0A,$0A,$00,$00 
  DC.B      $08,$0D,$09,$0A,$0A,$0A,$00,$00 
  DC.B      $08,$0D,$09,$0A,$0A,$0A,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$09,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$09,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$09,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$06,$00,$00 
  DC.B      $08,$0C,$09,$0B,$0A,$0B,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$08,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$00,$00,$00 
  DC.B      $08,$0D,$09,$0B,$0A,$00,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$07,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$06,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$05,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$03,$00,$00 
  DC.B      $08,$0C,$09,$0C,$0A,$01,$00,$00 
  DC.B      $08,$0C,$09,$0B,$0A,$0A,$00,$00 
  DC.B      $08,$0D,$09,$0A,$0A,$05,$00,$00 
  DC.B      $08,$0D,$09,$0A,$0A,$04,$00,$00 
  DC.B      $08,$0D,$09,$0A,$0A,$02,$00,$00 
  DC.B      $08,$0D,$09,$09,$0A,$08,$00,$00 
  DC.B      $08,$0D,$09,$09,$0A,$08,$00,$00 
L00D5:
  DCB.W     2,0 
L00D6:
  DC.B      $00 
L00D7:
  DC.B      $00 
L00D8:
  DC.B      $00,$00 
TABSTART
  DC.B      'EY',$0E,$0D,$02,'b',$01,','
  DC.B      $09,$06,$04,'~',$0B,'@',$05,$A0 
  DC.B      $02,$01,$01,$05,$05,'0',$18,'0' 
  DC.B      $18,'*',$15,$00,$00,$01,$05,$05 
  DC.B      '@',$00,'AY',$0F,$0C,$03,'f'
  DC.B      $01,$AE,$04,$E2,$02,'l',$0B,$04 
  DC.B      $05,$82,$02,$01,$01,$05,$05,'2' 
  DC.B      $19,'/',$17,$1F,$0F,$00,$00,$01 
  DC.B      $05,$05,'@',$00,'OY',$0F,$0C
  DC.B      $02,$A8,$01,'T',$03,$E8,$01,$F4 
  DC.B      $0B,$04,$05,$82,$02,$01,$01,$05 
  DC.B      $05,'2',$19,'-,',$1E,$0F,$00
  DC.B      $00,$01,$05,$05,'@',$00,'AW'
  DC.B      $0F,$0C,$03,'f',$01,$AE,$05,'d' 
  DC.B      $02,$B2,$0B,$04,$05,$82,$02,$01 
  DC.B      $01,$05,$05,'2',$19,'/',$17,$1F 
  DC.B      $0F,$00,$00,$01,$05,$05,'@',$00 
  DC.B      'OW',$0E,$0E,$02,'D',$01,'"'
  DC.B      $03,$C0,$01,$E0,$0B,$04,$05,$82 
  DC.B      $02,$01,$01,$04,$04,'2',$19,'-' 
  DC.B      $16,$1E,$0F,$00,$00,$01,$05,$05 
  DC.B      '@',$00,'UW',$0E,$09,$01,$A4
  DC.B      $00,$D2,$04,'B',$02,$1C,$0A,'F' 
  DC.B      $05,$1E,$02,$01,$01,$04,$04,'/' 
  DC.B      $17,'(',$14,$1E,$0F,$00,$00,$01 
  DC.B      $05,$05,'@',$00,'AR',$0F,$0F
  DC.B      $03,$16,$01,$9A,$03,'p',$01,$D6 
  DC.B      $09,$C4,$04,$C4,$02,$01,$01,$04 
  DC.B      $04,'2',$18,'1',$18,$1D,$0E,$00 
  DC.B      $00,$01,$04,$04,'@',$00,'WX'
  DC.B      $08,$08,$01,$A4,$00,$D2,$03,$A2 
  DC.B      $01,$CC,$0A,$00,$05,$00,$05,$01 
  DC.B      $01,$04,$04,'/',$17,'(',$14,$1E 
  DC.B      $0F,$00,$00,$01,$04,$04,'@',$00 
  DC.B      'YX',$08,$07,$01,$E0,$00,$F0
  DC.B      $08,$A2,$04,'L',$0B,$A4,$05,$D2 
  DC.B      $05,$01,$01,$04,$04,'0',$18,'-' 
  DC.B      $16,$27,$13,$00,$00,$01,$04,$04 
  DC.B      '@',$00,'AE',$0E,$08,$03,$16
  DC.B      $01,$9A,$06,$F4,$03,$B6,$09,$C4 
  DC.B      $04,$C4,$02,$01,$01,$04,$04,'2' 
  DC.B      $18,'/',$18,'&',$11,$00,$00,$01 
  DC.B      $04,$04,'@',$00,'IY',$0B,$08
  DC.B      $00,$FA,$00,'n',$09,$10,$04,$A6 
  DC.B      $0C,$94,$06,',',$02,$01,$01,$04 
  DC.B      $04,'2',$18,'!',$11,'$',$11,$00 
  DC.B      $00,$01,$04,$04,'@',$00,'ER'
  DC.B      $0E,$0B,$02,'D',$01,'"',$05,$8C 
  DC.B      $02,$C6,$09,$C4,$04,$C4,$05,$01 
  DC.B      $01,$04,$04,'2',$18,'-',$15,'!' 
  DC.B      $11,$00,$00,$01,$04,$04,'@',$00 
  DC.B      'AO',$10,$0C,$01,$EA,$00,$E6
  DC.B      $03,'4',$01,$D6,$09,$C4,$04,$C4 
  DC.B      $02,$01,$01,$04,$04,'2',$18,'-' 
  DC.B      $15,$16,$0A,$00,$00,$01,$04,$04 
  DC.B      '@',$00,'UX',$0C,$0A,$01,$C2
  DC.B      $00,$DC,$04,$88,$02,'D',$0A,'F' 
  DC.B      $05,$1E,$02,$01,$01,$04,$04,'2' 
  DC.B      $18,'&',$11,$11,$07,$00,$00,$01 
  DC.B      $04,$04,'@',$00,'UH',$0C,$0A
  DC.B      $02,$BC,$01,'^',$05,'P',$02,$C6 
  DC.B      $09,$C4,$04,$C4,$02,$01,$01,$04 
  DC.B      $04,'2',$18,'+',$15,$1F,$0E,$00 
  DC.B      $00,$01,$04,$04,'@',$00,'AH'
  DC.B      $0B,$06,$02,$E4,$01,'r',$05,$82 
  DC.B      $02,$E4,$0A,$E6,$05,'<',$02,$01 
  DC.B      $01,$04,$04,'2',$18,'-',$16,$1F 
  DC.B      $0E,$00,$00,$01,$04,$04,'@',$00 
  DC.B      'AA',$0F,$0B,$02,'b',$01,'"'
  DC.B      $03,'p',$01,$D6,$09,$C4,$04,$C4 
  DC.B      $02,$01,$01,$04,$04,'2',$18,'/' 
  DC.B      $18,$16,$0A,$00,$00,$01,$04,$04 
  DC.B      '@',$00,'OH',$0E,$0A,$02,'D'
  DC.B      $01,$04,$03,$C0,$02,$08,$0B,$04 
  DC.B      $05,'n',$0A,$01,$01,$04,$04,'2' 
  DC.B      $18,'/',$18,$1E,$0E,$00,$00,$01 
  DC.B      $04,$04,'@',$00,'AX',$06,$05
  DC.B      $01,$EA,$00,$E6,$05,$C8,$02,$C6 
  DC.B      $09,$C4,$04,$C4,$02,$01,$01,$04 
  DC.B      $04,'2',$18,'2',$18,'!',$11,$00 
  DC.B      $00,$01,$04,$04,'@',$00,'IX'
  DC.B      $06,$05,$01,$C2,$00,$D2,$09,'$' 
  DC.B      $04,'`',$0B,$A4,$05,$AA,$05,$01 
  DC.B      $01,$04,$04,'/',$16,',',$15,'&' 
  DC.B      $14,$00,$00,$01,$04,$04,'@',$00 
  DC.B      'IH',$09,$08,$01,$90,$00,$AA
  DC.B      $08,' ',$04,'.',$0A,$00,$05,'<' 
  DC.B      $02,$01,$01,$04,$04,'2',$18,'$' 
  DC.B      $11,'#',$11,$00,$00,$01,$04,$04 
  DC.B      '@',$00,'EH',$0B,$08,$02,$80
  DC.B      $01,'^',$07,$E4,$04,'.',$09,$C4 
  DC.B      $04,$C4,$02,$01,$01,$04,$04,'2' 
  DC.B      $18,'*',$15,'&',$11,$00,$00,$01 
  DC.B      $04,$04,'@',$00,'DH',$06,$06
  DC.B      $01,$18,$00,$AA,$06,'@',$04,$A6 
  DC.B      $0A,$00,$00,$00,$14,$01,$02,$03 
  DC.B      $02,$1D,$00,$1F,$00,$1A,$00,'(' 
  DCB.W     2,0 
  DC.B      '`',$10,'ZH',$06,$06,$01,$18
  DC.B      $00,$AA,$07,$E4,$04,$A6,$0A,$00 
  DC.B      $00,$00,$14,$01,$02,$03,$02,$1D 
  DC.B      $00,$1A,$00,'$',$00,'(',$00,$00 
  DC.B      $00,$00,'`',$10,'CH',$06,$06
  DC.B      $00,$BE,$00,'n',$06,$F4,$03,$B6 
  DC.B      $0A,'x',$0A,'x',$17,$01,$00,$02 
  DCB.W     6,0 
  DC.B      $A0,$00,'CH',$07,$07,$01,$90
  DC.B      $00,$AA,$07,$E4,$04,$A6,$0A,$00 
  DC.B      $00,$00,$16,$01,$02,$03,$01,$00 
  DC.B      $00,$1F,$00,'*',$00,',',$00,$00 
  DC.B      $00,$00,' ',$14,'LX',$0B,$09
  DC.B      $02,$08,$01,$04,$04,$A6,$02,'N' 
  DC.B      $0D,$C0,$06,$E0,$08,$01,$01,$03 
  DC.B      $02,'/',$00,'(',$00,$1F,$00,$00 
  DCB.W     2,0 
  DC.B      '@',$00,'RX',$0A,$07,$02,'D'
  DC.B      $01,'"',$06,'h',$03,'4',$07,$C6 
  DC.B      $03,$DE,$02,$01,$01,$03,$03,'/' 
  DC.B      $00,'-',$00,$27,$00,$00,$00,$00 
  DC.B      $00,$00,'@',$00,'SH',$0A,$0A
  DC.B      $01,$90,$00,$AA,$07,$E4,$04,$A6 
  DC.B      $0A,$00,$00,$00,$12,$01,$02,$03 
  DC.B      $01,$00,$00,$1F,$00,'(',$00,'*' 
  DCB.W     2,0 
  DC.B      ' ',$11,'NX',$08,$07,$01,'6'
  DC.B      $00,'n',$03,'4',$06,$0E,$0A,$F0 
  DC.B      $06,',',$08,$01,$01,$02,$01,'2' 
  DC.B      $00,'!',$00,$1C,$00,$00,$00,$00 
  DC.B      $00,$00,'@',$00,'TH',$0A,$0A
  DC.B      $01,$90,$00,$AA,$06,$F4,$04,$A6 
  DC.B      $0A,'x',$0A,'x',$12,$01,$00,$03 
  DC.B      $01,$00,$00,$1A,$00,$1C,$00,'*' 
  DCB.W     2,0 
  DC.B      ' ',$10,'/H',$07,$07,$01,$EA
  DC.B      $00,$00,$05,$C8,$00,$00,$09,$C4 
  DC.B      $00,$00,$1E,$02,$02,$00,$04,$1F 
  DC.B      $F2,' ',$F2,$16,$F9,',',$00,$02 
  DC.B      $00,$07,$00,$1A,'V ',$08,$07
  DC.B      $01,$18,$00,$AA,$05,$8C,$01,'^' 
  DC.B      $0A,$00,$03,$D4,$14,$01,$01,$03 
  DC.B      $02,$1B,$00,'&',$00,'"',$00,'(' 
  DCB.W     2,0 
  DC.B      '`',$10,'Z ',$06,$06,$01,$18
  DC.B      $00,$AA,$06,$B8,$03,$B6,$0A,$00 
  DC.B      $00,$00,$14,$01,$02,$03,$02,$1D 
  DC.B      $00,$18,$00,$18,$00,',',$00,$00 
  DC.B      $00,$00,'`',$0E,'J ',$04,$04
  DC.B      $00,$C8,$00,'n',$08,'H',$04,'L' 
  DC.B      $0F,'(',$0F,'(',$1A,$01,$00,$02 
  DC.B      $00,$1F,$00,$00,$00,$00,$00,$00 
  DCB.W     2,0 
  DC.B      $C0,$00,'J ',$06,$06,$00,$A0
  DC.B      $00,'n',$09,$E2,$05,$1E,$0C,$A8 
  DC.B      $00,$00,$19,$01,$02,$03,$01,',' 
  DC.B      $00,'$',$00,$1F,$00,'+',$00,$00 
  DC.B      $00,$00,'@',$12,'L ',$09,$06
  DC.B      $01,$C2,$00,$DC,$03,$C0,$01,$B8 
  DC.B      $0D,$C0,$06,$A4,$09,$01,$01,$03 
  DC.B      $02,'/',$00,'(',$00,$1F,$00,$00 
  DCB.W     2,0 
  DC.B      '@',$00,'R ',$0B,$0B,$01,$EA
  DC.B      $00,$00,$04,$9C,$02,'N',$06,'@' 
  DC.B      $02,$E4,$0A,$01,$01,$03,$02,'*' 
  DC.B      $15,'#',$11,'#',$11,$00,$00,$01 
  DC.B      $05,$05,'@',$00,'W ',$08,$08
  DC.B      $01,'h',$00,'d',$03,$02,$01,'^' 
  DC.B      $0B,'@',$05,'d',$08,$01,$01,$03 
  DC.B      $02,'/',$17,'(',$14,'(',$14,$00 
  DC.B      $00,$01,$02,$03,'@',$00,'Y '
  DC.B      $07,$07,$00,$FA,$00,'n',$09,$C4 
  DC.B      $04,$A6,$0B,$A4,$05,$B4,$0A,$01 
  DC.B      $01,$04,$04,'2',$18,'!',$11,'&' 
  DC.B      $11,$00,$00,$01,$04,$04,'@',$00 
  DC.B      'Q ',$05,$05,$00,$00,$00,$00
  DCB.W     4,0 
  DC.B      $1D,$00,$00,$00,$00,$00,$F6,$00 
  DC.B      $F6,$00,$F6,$00,$00,$02,$03,$00 
  DC.B      $00,$00,'P ',$08,$08,$00,$BE
  DC.B      $00,'n',$02,$F8,$01,'^',$09,$C4 
  DC.B      $00,$00,$17,$01,$02,$02,$02,$00 
  DCB.W     5,0 
  DC.B      $80,$00,'P ',$01,$01,$00,$BE
  DC.B      $00,$00,$02,$F8,$00,$00,$09,$C4 
  DC.B      $00,$00,$1D,$00,$00,$00,$00,$18 
  DC.B      $00,'(',$00,'$',$00,'-',$00,$00 
  DC.B      $00,$00,$80,$14,'P ',$02,$02
  DC.B      $00,$BE,$00,'n',$02,$F8,$01,'^' 
  DC.B      $09,$C4,$00,$00,$17,$01,$02,$02 
  DC.B      $02,$15,$00,'#',$00,$1E,$00,'+' 
  DCB.W     2,0 
  DC.B      $00,$18,'T ',$06,$04,$00,$BE
  DC.B      $00,'n',$06,$F4,$03,$B6,$0A,'x' 
  DC.B      $0A,'x',$17,$01,$00,$02,$02,$00 
  DCB.W     5,0 
  DC.B      $80,$00,'T ',$01,$01,$00,$BE
  DC.B      $00,$00,$06,$F4,$00,$00,$0A,'x' 
  DC.B      $00,$00,$1D,$00,$00,$00,$00,$00 
  DC.B      $00,$00,$00,'&',$00,'-',$00,$00 
  DC.B      $00,$00,$80,$08,'T ',$02,$02
  DC.B      $00,$BE,$00,'n',$06,$F4,$03,$B6 
  DC.B      $0A,'x',$0A,'x',$17,$01,$00,$02 
  DC.B      $01,$00,$00,$00,$00,$1C,$00,'+' 
  DCB.W     2,0 
  DC.B      $00,$0A,'K ',$07,$06,$00,$BE
  DC.B      $00,'n',$05,$C8,$06,$0E,$0A,'<' 
  DC.B      $06,',',$17,$01,$01,$03,$03,$00 
  DCB.W     5,0 
  DC.B      $80,$00,'K ',$02,$01,$01,'@'
  DC.B      $00,$00,$0A,$C8,$00,$00,$0C,$A8 
  DC.B      $00,$00,$1D,$00,$00,$00,$00,'-' 
  DC.B      $00,'+',$00,'&',$00,'-',$00,$00 
  DC.B      $00,$00,$80,$08,'K ',$04,$04
  DC.B      $00,$BE,$00,'n',$05,$C8,$06,$0E 
  DC.B      $0A,'<',$06,',',$17,$01,$01,$03 
  DC.B      $02,$00,$00,$00,$00,$00,$00,$00 
  DCB.W     3,0 
  DC.B      'B ',$08,$06,$00,$BE,$00,'n'
  DC.B      $02,$F8,$01,'^',$09,$C4,$00,$00 
  DC.B      $1A,$01,$02,$02,$02,$18,$00,$00 
  DCB.W     4,0 
  DC.B      $C0,$00,'B ',$02,$01,$00,$BE
  DC.B      $00,$00,$02,$F8,$00,$00,$09,$C4 
  DC.B      $00,$00,$1D,$00,$00,$00,$00,$18 
  DC.B      $00,'.',$00,'(',$00,$00,$00,$00 
  DC.B      $00,$00,$C0,$00,'B ',$01,$01
  DC.B      $00,$BE,$00,'n',$02,$F8,$01,'^' 
  DC.B      $09,$C4,$00,$00,$1B,$01,$02,$02 
  DC.B      $00,$18,$00,$18,$00,$18,$00,$00 
  DCB.W     2,0 
  DC.B      '@',$00,'D ',$07,$05,$00,$BE
  DC.B      $00,'n',$06,$F4,$03,$B6,$0A,'x' 
  DC.B      $0A,'x',$1A,$01,$00,$02,$02,$1F 
  DCB.W     5,0 
  DC.B      $C0,$00,'D ',$02,$01,$00,$BE
  DC.B      $00,$00,$06,$F4,$00,$00,$0A,'x' 
  DC.B      $00,$00,$1D,$00,$00,$00,$00,'&' 
  DC.B      $00,'&',$00,'#',$00,$00,$00,$00 
  DC.B      $00,$00,$C0,$00,'D ',$01,$01
  DC.B      $00,$BE,$00,'n',$06,$F4,$03,$B6 
  DC.B      $0A,'x',$0A,'x',$1B,$01,$00,$03 
  DC.B      $01,'&',$00,$1C,$00,$18,$00,$00 
  DCB.W     2,0 
  DC.B      '@',$00,'G ',$07,$06,$00,$BE
  DC.B      $00,'n',$05,$C8,$06,$0E,$0A,'<' 
  DC.B      $06,',',$1A,$01,$01,$02,$02,' ' 
  DCB.W     5,0 
  DC.B      $C0,$00,'G ',$02,$01,$00,$BE
  DC.B      $00,$00,$05,$C8,$00,$00,$0A,'<' 
  DC.B      $00,$00,$1D,$00,$00,$00,$00,'"' 
  DC.B      $00,'(',$00,'$',$00,$00,$00,$00 
  DC.B      $00,$00,$C0,$00,'G ',$02,$02
  DC.B      $00,$BE,$00,'n',$05,$C8,$06,$0E 
  DC.B      $0A,'<',$06,',',$1B,$01,$01,$04 
  DC.B      $01,$00,$00,$00,$00,$00,$00,$00 
  DCB.W     2,0 
  DC.B      '@',$00,'M ',$08,$07,$00,$BE
  DC.B      $00,'n',$03,$E8,$01,'^',$08,$98 
  DC.B      $00,$00,$08,$01,$02,$01,$01,'-' 
  DC.B      $00,$13,$00,$1A,$00,$00,$00,$00 
  DC.B      $00,$00,'@',$00,'N ',$08,$07
  DC.B      $00,$BE,$00,'n',$05,$14,$03,$B6 
  DC.B      $0A,'<',$0A,'x',$08,$01,$00,$02 
  DC.B      $01,'-',$00,$13,$00,$1A,$00,$00 
  DCB.W     2,0 
  DC.B      '@',$00,'F ',$0A,$0A,$01,$90
  DC.B      $00,$AA,$05,$8C,$01,'^',$0A,$00 
  DC.B      $03,$D4,$12,$01,$01,$03,$01,$00 
  DC.B      $00,' ',$00,$1E,$00,'*',$00,$00 
  DC.B      $00,$00,' ',$0A,'S ',$0C,$0C
  DC.B      $01,$90,$00,$AA,$06,$B8,$03,$B6 
  DC.B      $0A,'<',$00,$00,$12,$01,$02,$03 
  DC.B      $01,$00,$00,$1C,$00,$1C,$00,',' 
  DCB.W     2,0 
  DC.B      ' ',$07,'- ',$08,$08,$00,$00
  DCB.W     5,0 
  DC.B      $1F,$00,$00,$00,$00,$00,$F6,$00 
  DC.B      $F6,$00,$F6,$00,$00,$01,$03,$00 
  DC.B      $00,$00,'. ',$12,$12,$00,$00
  DCB.W     5,0 
  DC.B      $1F,$00,$00,$00,$00,$00,$F6,$00 
  DC.B      $F6,$00,$F6,$00,$00,$01,$03,$00 
  DC.B      $00,$00,', ',$0E,$0E,$00,$00
  DCB.W     5,0 
  DC.B      $1F,$00,$00,$00,$00,$00,$F6,$00 
  DC.B      $F6,$00,$F6,$00,$00,$01,$03,$00 
  DC.B      $00,$00,'? ',$12,$12,$00,$00
  DCB.W     5,0 
  DC.B      $1F,$00,$00,$00,$00,$00,$F6,$00 
  DC.B      $F6,$00,$F6,$00,$00,$01,$03,$00 
  DC.B      $00,$00,'  ',$00,$00,$00,$00
  DCB.W     5,0 
  DC.B      $1F,$00,$00,$00,$00,$00,$F6,$00 
  DC.B      $F6,$00,$F6,$00,$00,$01,$03,$00 
  DC.B      $00,$00,'UL',$02,'d',$04,$C8
  DCB.W     14,0
  DC.B      'UM',$02,'d',$07,$D6,$00,$00
  DCB.W     13,0
  DC.B      'UN',$02,'d',$07,$F8,$00,$00
  DCB.W     13,0
  DC.B      'IL',$02,$86,$04,$C8,$00,$00
  DCB.W     13,0
  DC.B      'IM',$02,$86,$07,$D6,$00,$00
  DCB.W     13,0
  DC.B      'IN',$02,$86,$07,$F8,$00,$00
  DCB.W     13,0
  DC.B      $FF,$FF,$FF,$FF 
L00DA:
  DCB.W     14,0
  DC.B      $FF,$FF,$FF,$FF 
BUFFER
  DCB.W     510,0 
L00DC:
  DCB.W     2,0 
L00DD:
  DC.B      $FF,$FF,$FF,$FF 
SPCHBUFF
  DCB.W     4608,0
SET_RATE
  DC.B      'O' 
SET_PITC
  DC.B      'M' 
USE_RATE
  DC.B      'O' 
USE_PITC
  DC.B      'M',$00,$00 

 BSS

wave_params:
wave_a_step:
	ds.b	1
wave_a_amp:
	ds.b	1
wave_b_step:
	ds.b	1
wave_b_amp:
	ds.b	1
wave_c_step:
	ds.b	1
wave_c_amp:
	ds.b	1

wave_pos:
wave_a_pos:
	ds.b	1
wave_b_pos:
	ds.b	1
wave_c_pos:
	ds.b	1
	ds.b	1			A,B,C positions

hiss_params:
hiss_a_step:
	ds.b	1
hiss_a_amp:
	ds.b	1
hiss_b_step:
	ds.b	1
hiss_b_amp:
	ds.b	1

hiss_a_pos:
	ds.b	1
hiss_b_pos:
	ds.b	1

L00E3:
  DS.B      1 
L00E4:
  DS.B      256 
PHOBUFF:
  DS.B      257 
L00E6:
  DS.W      1 
L00E7:
  DS.B      256 
ZUEND: END
