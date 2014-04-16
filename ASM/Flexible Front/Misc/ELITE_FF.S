SCRST=$78000
FINI:
       PEA       PROGRAMSTART
       MOVE.W    #38,-(SP)
       TRAP      #14
       ADDQ.L    #6,SP
       BRA       EXIT
LEXIT:
 CLR.L -(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADD.L #6,SP

 BSR VOL0

 CLR.L -(SP)
 MOVE.W #21,-(SP)
 TRAP #14
 ADDQ.L #6,SP

 CLR.W -(SP)
 PEA LOADFIL
 MOVE.W #$3D,-(SP)
 TRAP #1
 ADDQ.L #8,SP
 MOVE.W D0,D7

 PEA $11E00
 MOVE.L #100000,-(SP)
 MOVE.W D7,-(SP)
 MOVE.W #$3F,-(SP)
 TRAP #1
 ADD.L #12,SP

 MOVE.W D7,-(SP)
 MOVE.W #$3E,-(SP)
 TRAP #1
 ADDQ.L #4,SP

 JMP $11E00
PROGRAMSTART:
       BSR       LOWRES
     BCLR #0,$484
     LEA $FF8240,A0
     LEA COLORS2+32,A1
     MOVEM.L (A0)+,D0-D7
     MOVEM.L D0-D7,-(A1)
       LEA       COLORS1,A0
     LEA $FF8240+32,A1
     MOVEM.L (A0)+,D0-D7
     MOVEM.L D0-D7,-(A1)
       BSR       PREFONT
     BSR SETLOGO
     CLR.L D0
     JSR LEATH+28
       MOVE.L    $70,VBLV

 LEA MESSAGE,A0
CRYP:
 MOVE.B (A0),D0
 TST.B D0
 BEQ FINCRYP
 NOT.B D0
 MOVE.B D0,(A0)+
 BRA CRYP
FINCRYP:
 NOT.B D0
 MOVE.B D0,(A0)
       LEA       ATTRIBUTE,A1
       LEA       MESSAGE,A2
       MOVE.L    #TEXTSCROLL,$70
       MOVE.W    #$2300,SR
AGAIN: MOVE.B    $FFFC02,D0
       CMP.B     #$39,D0
       BNE       AGAIN
; **********  DISABLE INTS.  **********
       MOVE.W    #$2700,SR
       MOVE.L    VBLV,$70
       MOVE.W    #$2400,SR    ;ENABLE  INTS.
       RTS

SETLOGO:
 LEA GRAFIX,A0
 LEA SCRST+3200+32,A1
 BSR SUBLOG
 LEA SCRST+3200+32+32,A1
 BSR SUBLOG
 LEA SCRST+3200+64+32,A1
 BSR SUBLOG
 LEA SCRST+13440+32,A1
 BSR SUBLOG
 LEA SCRST+13440+64,A1
 BSR SUBLOG
 LEA SCRST+13440+96,A1
 BSR SUBLOG
 LEA SCRST+23680+64,A1
 BSR SUBLOG
 RTS
SUBLOG:
 ADDQ.W #2,A1
 MOVE.W #63,D0
SUB1:
 MOVE.L (A0)+,(A1)+
 MOVE.W (A0)+,(A1)+
 ADD.W #2,A1
 MOVE.L (A0)+,(A1)+
 MOVE.W (A0)+,(A1)+
 ADD.W #2,A1
 MOVE.L (A0)+,(A1)+
 MOVE.W (A0)+,(A1)+
 ADD.W #2,A1
 MOVE.L (A0)+,(A1)+
 MOVE.W (A0)+,(A1)+
 ADD.W #130,A1
 DBRA D0,SUB1
 RTS
TEXTSCROLL:
DUMP:  LEA       SCRST+21760,A0
       MOVE.W    #0,D0
       MOVE.W    #63,D1
CLEAR: MOVE.W    D0,(A0)
       MOVE.W    D0,8(A0)
       MOVE.W    D0,16(A0)
       MOVE.W    D0,24(A0)
       MOVE.W    D0,32(A0)
       MOVE.W    D0,40(A0)
       MOVE.W    D0,48(A0)
       MOVE.W    D0,56(A0)
       MOVE.W    D0,64(A0)
       MOVE.W    D0,72(A0)
       MOVE.W    D0,80(A0)
       MOVE.W    D0,88(A0)
       MOVE.W    D0,96(A0)
       MOVE.W    D0,104(A0)
       MOVE.W    D0,112(A0)
       MOVE.W    D0,120(A0)
       MOVE.W    D0,128(A0)
       MOVE.W    D0,136(A0)
       MOVE.W    D0,144(A0)
       MOVE.W    D0,152(A0)
       ADD.W     #160,A0
       DBRA      D1,CLEAR
       TST.W     INDEX
       BNE       NO2
       MOVE.W    #15104,INDEX
       ADDQ.W    #1,A2
NO2:   SUB.W     #3776,INDEX
       CMPI.L    #$FFFFFFFF,(A1)
       BNE       NO1
         LEA       ATTRIBUTE,A1
NO1:   MOVE.L    A1,D4              ;SAVE A1 REG !!!
       ADDQ.L    #8,D4
       MOVE.L    (A1)+,A4           ;A4=ADRESS OF Y-COORD
       MOVE.L    (A1),A1            ;A1=ADRESS OF SPINN
       CMPI.B    #$FF,20(A2)
       BNE       FIRST
         LEA       MESSAGE,A2
FIRST: CLR.L     D0           ;COPY FIRST CHARACTER TO SCREEN
       LEA       SCRST+21760,A3     ;SCREENSTART+150 ROWS
       ADD.W     (A4)+,A3           ;ADD Y COORDINATE
       MOVE.B    (A2)+,D0        ;CHARACTER INDEX
       SUB.W     #$20,D0
       LSL.W     #6,D0           ;4*2 CHAR (64 BYTES=6 SHIFTS)
       LEA       FONT+2,A0       ;FONT ADRESS
       ADD.W     INDEX,A0        ;  ----
       ADD.W     D0,A0
       CLR.W     D1
       MOVE.B    (A1)+,D1           ;ATTRIBUTE BYTE
       MOVE.W    (A0,D1),D2
       OR.W      D2,0(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,160(A3)
       MOVE.B    (A1)+,D1
       MOVE.W    (A0,D1),D2
       OR.W      D2,320(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,480(A3)
       MOVE.B    (A1)+,D1           ;ATTRIBUTE BYTE
       MOVE.W    (A0,D1),D2
       OR.W      D2,640(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,800(A3)
       MOVE.B    (A1)+,D1
       MOVE.W    (A0,D1),D2
       OR.W      D2,960(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,1120(A3)
       MOVE.B    (A1)+,D1           ;2ND HALF
       MOVE.W    (A0,D1),D2
       OR.W      D2,1280(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,1440(A3)
       MOVE.B    (A1)+,D1
       MOVE.W    (A0,D1),D2
       OR.W      D2,1600(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,1760(A3)
       MOVE.B    (A1)+,D1           ;ATTRIBUTE BYTE
       MOVE.W    (A0,D1),D2
       OR.W      D2,1920(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,2080(A3)
       MOVE.B    (A1)+,D1
       MOVE.W    (A0,D1),D2
       OR.W      D2,2240(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,2400(A3)
       MOVE.W    #18,D3
DMP:   LEA       SCRST+21760,A3     ;SCREENSTART+150 ROWS
       ADD.W     (A4)+,A3           ;ADD Y COORDINATE
       CLR.L     D0
       MOVE.B    (A2)+,D0    ;CHARACTER INDEX
       SUB.W     #$20,D0
       LSL.W     #6,D0       ;4*2 CHAR (64 BYTES=6 SHIFTS)
       LEA       FONT,A0           ;FONT ADRESS
       ADD.W     INDEX,A0          ;  ----
       ADD.W     D0,A0
       SUB.W     #16,A1
       CLR.W     D1
       MOVE.B    (A1)+,D1           ;ATTRIBUTE BYTE
       MOVE.L    (A0,D1),D2
       OR.W      D2,8(A3)
       SWAP      D2
       OR.W      D2,0(A3)
        MOVE.B    (A1)+,D1
        MOVE.L    (A0,D1),D2
        OR.W      D2,168(A3)
        SWAP      D2
        OR.W      D2,160(A3)
       MOVE.B    (A1)+,D1
       MOVE.L    (A0,D1),D2
       OR.W      D2,328(A3)
       SWAP      D2
       OR.W      D2,320(A3)
        MOVE.B    (A1)+,D1
        MOVE.L    (A0,D1),D2
        OR.W      D2,488(A3)
        SWAP      D2
        OR.W      D2,480(A3)
       MOVE.B    (A1)+,D1           ;ATTRIBUTE BYTE
       MOVE.L    (A0,D1),D2
       OR.W      D2,648(A3)
       SWAP      D2
       OR.W      D2,640(A3)
        MOVE.B    (A1)+,D1
        MOVE.L    (A0,D1),D2
        OR.W      D2,808(A3)
        SWAP      D2
        OR.W      D2,800(A3)
       MOVE.B    (A1)+,D1
       MOVE.L    (A0,D1),D2
       OR.W      D2,968(A3)
       SWAP      D2
       OR.W      D2,960(A3)
        MOVE.B    (A1)+,D1
        MOVE.L    (A0,D1),D2
        OR.W      D2,1128(A3)
        SWAP      D2
        OR.W      D2,1120(A3)
       MOVE.B    (A1)+,D1           ;2ND HALF
       MOVE.L    (A0,D1),D2
       OR.W      D2,1288(A3)
       SWAP      D2
       OR.W      D2,1280(A3)
        MOVE.B    (A1)+,D1
        MOVE.L    (A0,D1),D2
        OR.W      D2,1448(A3)
        SWAP      D2
        OR.W      D2,1440(A3)
       MOVE.B    (A1)+,D1
       MOVE.L    (A0,D1),D2
       OR.W      D2,1608(A3)
       SWAP      D2
       OR.W      D2,1600(A3)
        MOVE.B    (A1)+,D1
        MOVE.L    (A0,D1),D2
        OR.W      D2,1768(A3)
        SWAP      D2
        OR.W      D2,1760(A3)
       MOVE.B    (A1)+,D1           ;ATTRIBUTE BYTE
       MOVE.L    (A0,D1),D2
       OR.W      D2,1928(A3)
       SWAP      D2
       OR.W      D2,1920(A3)
        MOVE.B    (A1)+,D1
        MOVE.L    (A0,D1),D2
        OR.W      D2,2088(A3)
        SWAP      D2
        OR.W      D2,2080(A3)
       MOVE.B    (A1)+,D1
       MOVE.L    (A0,D1),D2
       OR.W      D2,2248(A3)
       SWAP      D2
       OR.W      D2,2240(A3)
        MOVE.B    (A1)+,D1
        MOVE.L    (A0,D1),D2
        OR.W      D2,2408(A3)
        SWAP      D2
        OR.W      D2,2400(A3)
       ADDQ.W    #8,DMP+4
       DBRA      D3,DMP
       MOVE.L    #SCRST+21760,DMP+2
LAST:  CLR.L     D0          ;COPY LAST CHARACTER TO SCREEN
      LEA       SCRST+21912,A3     ;SCREENSTART+150 ROWS
      ADD.W     (A4)+,A3           ;ADD Y COORDINATE
       MOVE.B    (A2)+,D0    ;CHARACTER INDEX
       SUB.W     #21,A2      ;RESET INDEX VALUE
       SUB.W     #$20,D0
       LSL.W     #6,D0       ;4*2 CHAR (64 BYTES=6 SHIFTS)
       LEA       FONT,A0           ;FONT ADRESS
       ADD.W     INDEX,A0          ;  ----
       ADD.W     D0,A0
       SUB.W    #16,A1
       CLR.W     D1
       MOVE.B    (A1)+,D1           ;ATTRIBUTE BYTE
       MOVE.W    (A0,D1),D2
       OR.W      D2,0(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,160(A3)
       MOVE.B    (A1)+,D1
       MOVE.W    (A0,D1),D2
       OR.W      D2,320(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,480(A3)
       MOVE.B    (A1)+,D1           ;ATTRIBUTE BYTE
       MOVE.W    (A0,D1),D2
       OR.W      D2,640(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,800(A3)
       MOVE.B    (A1)+,D1
       MOVE.W    (A0,D1),D2
       OR.W      D2,960(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,1120(A3)
       MOVE.B    (A1)+,D1           ;2ND HALF
       MOVE.W    (A0,D1),D2
       OR.W      D2,1280(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,1440(A3)
       MOVE.B    (A1)+,D1
       MOVE.W    (A0,D1),D2
       OR.W      D2,1600(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,1760(A3)
       MOVE.B    (A1)+,D1           ;ATTRIBUTE BYTE
       MOVE.W    (A0,D1),D2
       OR.W      D2,1920(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,2080(A3)
       MOVE.B    (A1)+,D1
       MOVE.W    (A0,D1),D2
       OR.W      D2,2240(A3)
        MOVE.B    (A1)+,D1
        MOVE.W    (A0,D1),D2
        OR.W      D2,2400(A3)
       MOVE.L    D4,A1              ;RESTORE A1 REG !!!
       MOVEM.L D0-D7/A0-A6,-(SP)
       JSR LEATH+294
       MOVEM.L (SP)+,D0-D7/A0-A6
       RTE

PALETTE:
       MOVE.L    A0,-(SP)
       MOVE.W    #6,-(SP)
       TRAP      #14
       ADDQ.L    #6,SP
       RTS
PREFONT:
       LEA       FONT,A0
       LEA       FONT+3776,A1
       LEA       FONT+3776,A2
       BSR       CFONT
       BSR       RFONT
       BSR       CFONT
       BSR       RFONT
       BSR       CFONT
       BSR       RFONT
       RTS

CFONT:
       MOVE.W    #58,D0
UP:    MOVEM.L   (A0)+,A3-A6/D3-D6
       MOVEM.L   A3-A6/D3-D6,(A1)
       MOVEM.L   (A0)+,A3-A6/D3-D6
       MOVEM.L   A3-A6/D3-D6,32(A1)
       ADD.W     #64,A1
       DBRA      D0,UP
       RTS

RFONT:
       MOVE.W    #472,D0
UP1:   AND.B     #%11101110,CCR
       ROXR.W    (A2)
       ROXR.W    2(A2)
       AND.B     #%11101110,CCR
       ROXR.W    (A2)
       ROXR.W    2(A2)
       AND.B     #%11101110,CCR
       ROXR.W    (A2)
       ROXR.W    2(A2)
       AND.B     #%11101110,CCR
       ROXR.W    (A2)+
       ROXR.W    (A2)+
       AND.B     #%11101110,CCR
       ROXR.W    (A2)
       ROXR.W    2(A2)
       AND.B     #%11101110,CCR
       ROXR.W    (A2)
       ROXR.W    2(A2)
       AND.B     #%11101110,CCR
       ROXR.W    (A2)
       ROXR.W    2(A2)
       AND.B     #%11101110,CCR
       ROXR.W    (A2)+
       ROXR.W    (A2)+
       DBRA      D0,UP1
       RTS

LOWRES:
       MOVE.W    #0,-(SP)
       MOVE.L    #SCRST,-(SP)
       MOVE.L    #SCRST,-(SP)
       MOVE.W    #5,-(SP)
       TRAP      #14
       ADD.L     #12,SP
       RTS

EXIT:
       LEA       COLORS2,A0
       BSR       PALETTE
       MOVE.W    #1,-(SP)
       MOVE.L    #SCRST,-(SP)
       MOVE.L    #SCRST,-(SP)
       MOVE.W    #5,-(SP)
       TRAP      #14
       ADD.L     #12,SP

       BRA LEXIT
       DS.B 550
VOL0:
 LEA $FF8800,A0
 MOVE.B #8,(A0)
 CLR.B 2(A0)
 MOVE.B #9,(A0)
 CLR.B 2(A0)
 MOVE.B #10,(A0)
 CLR.B 2(A0)
 RTS
ATTRIBUTE:
       DC.L      S25,R0,S26,R0,S27,R0,S28,R0,S29,R0,S30,R0
       DC.L      S31,R0,S32,R0,S33,R0,S34,R0,S35,R0,S36,R0
       DC.L      S37,R0,S38,R0,S39,R0,S40,R0,S41,R0,S42,R0
       DC.L      S43,R0,S44,R0,S45,R0,S46,R0,S47,R0,S48,R0
       DC.L      S49,R0,S50,R0,S51,R0,S52,R0,S53,R0,S54,R0
       DC.L      S55,R0,S56,R0,S57,R0,S58,R0,S59,R0,S60,R0
       DC.L      S61,R0,S62,R0,S63,R0,S64,R0,S65,R0,S66,R0
       DC.L      S67,R0,S68,R0,S69,R0,S70,R0,S71,R0,S72,R0
       DC.L      S73,R0,S74,R0,S75,R0,S76,R0,S77,R0,S78,R0
       DC.L      S79,R0,S80,R0,S81,R0,S82,R0,S83,R0,S84,R0
       DC.L      S85,R0,S86,R0,S87,R0,S88,R0,S89,R0,S90,R0
       DC.L      S91,R0,S92,R0,S93,R0,S94,R0,S95,R0,S96,R0
       DC.L      S1,R0,S2,R0,S3,R0,S4,R0,S5,R0,S6,R0
       DC.L      S7,R0,S8,R0,S9,R0,S10,R0,S11,R0,S12,R0
       DC.L      S13,R0,S14,R0,S15,R0,S16,R0,S17,R0,S18,R0
       DC.L      S19,R0,S20,R0,S21,R0,S22,R0,S23,R0,S24,R0
       DC.L      S25,R0,S26,R0,S27,R0,S28,R0,S29,R0,S30,R0
       DC.L      S31,R0,S32,R0,S33,R0,S34,R0,S35,R0,S36,R0
       DC.L      S37,R0,S38,R0,S39,R0,S40,R0,S41,R0,S42,R0
       DC.L      S43,R0,S44,R0,S45,R0,S46,R0,S47,R0,S48,R0
       DC.L      S49,R0,S50,R0,S51,R0,S52,R0,S53,R0,S54,R0
       DC.L      S55,R0,S56,R0,S57,R0,S58,R0,S59,R0,S60,R0
       DC.L      S61,R0,S62,R0,S63,R0,S64,R0,S65,R0,S66,R0
       DC.L      S67,R0,S68,R0,S69,R0,S70,R0,S71,R0,S72,R0
       DC.L      S73,R0,S74,R0,S75,R0,S76,R0,S77,R0,S78,R0
       DC.L      S79,R0,S80,R0,S81,R0,S82,R0,S83,R0,S84,R0
       DC.L      S85,R0,S86,R0,S87,R0,S88,R0,S89,R0,S90,R0
       DC.L      S91,R0,S92,R0,S93,R0,S94,R0,S95,R0,S96,R0
       DC.L      S1,R0,S2,R0,S3,R0,S4,R0,S5,R0,S6,R0
       DC.L      S7,R0,S8,R0,S9,R0,S10,R0,S11,R0,S12,R0
       DC.L      S13,R0,S14,R0,S15,R0,S16,R0,S17,R0,S18,R0
       DC.L      S19,R0,S20,R0,S21,R0,S22,R0,S23,R0,S24,R0

       DC.L      H24,R0,H26,R0,H27,R0,H29,R0,H30,R0,H32,R0,H34,R0,H35,R0,H36,R0,H38,R0,H39,R0,H40,R0,H42,R0,H43,R0,H44,R0
       DC.L      H45,R0,H45,R0,H46,R0,H47,R0,H47,R0,H47,R0,H48,R0,H48,R0,H48,R0
       DC.L      H48,R0,H48,R0,H48,R0,H47,R0,H47,R0,H47,R0,H46,R0,H45,R0,H45,R0,H44,R0,H43,R0,H42,R0,H40,R0,H39,R0,H38,R0
       DC.L      H36,R0,H35,R0,H34,R0,H32,R0,H30,R0,H29,R0,H27,R0,H26,R0,H24,R0
       DC.L      H22,R0,H21,R0,H19,R0,H18,R0,H16,R0,H14,R0,H13,R0,H12,R0,H10,R0,H9,R0,H8,R0,H6,R0,H5,R0,H4,R0,H3,R0,H3,R0,H2,R0
       DC.L      H1,R0,H1,R0,H1,R0,H0,R0,H0,R0,H0,R0,H0,R0,H0,R0,H0,R0,H1,R0,H1,R0,H1,R0,H2,R0,H3,R0,H3,R0,H4,R0,H5,R0,H6,R0
       DC.L      H8,R0,H9,R0,H10,R0,H12,R0,H13,R0,H14,R0,H16,R0,H18,R0,H19,R0,H21,R0,H22,R0
       DC.L      H24,R0,H26,R0,H27,R0,H29,R0,H30,R0,H32,R0,H34,R0,H35,R0,H36,R0,H38,R0,H39,R0,H40,R0,H42,R0,H43,R0,H44,R0
       DC.L      H45,R0,H45,R0,H46,R0,H47,R0,H47,R0,H47,R0,H48,R0,H48,R0,H48,R0
       DC.L      H48,R0,H48,R0,H48,R0,H47,R0,H47,R0,H47,R0,H46,R0,H45,R0,H45,R0,H44,R0,H43,R0,H42,R0,H40,R0,H39,R0,H38,R0
       DC.L      H36,R0,H35,R0,H34,R0,H32,R0,H30,R0,H29,R0,H27,R0,H26,R0,H24,R0
       DC.L      H22,R0,H21,R0,H19,R0,H18,R0,H16,R0,H14,R0,H13,R0,H12,R0,H10,R0,H9,R0,H8,R0,H6,R0,H5,R0,H4,R0,H3,R0,H3,R0,H2,R0
       DC.L      H1,R0,H1,R0,H1,R0,H0,R0,H0,R0,H0,R0,H0,R0,H0,R0,H0,R0,H1,R0,H1,R0,H1,R0,H2,R0,H3,R0,H3,R0,H4,R0,H5,R0,H6,R0
       DC.L      H8,R0,H9,R0,H10,R0,H12,R0,H13,R0,H14,R0,H16,R0,H18,R0,H19,R0,H21,R0,H22,R0

       DC.L      H24,R0,H24,R1,H25,R2,H25,R3,H26,R4,H26,R5
       DC.L      H27,R6,H27,R7,H28,R8,H28,R9,H29,R10,H29,R11
       DC.L      H30,R12,H30,R13,H31,R14,H31,R15,H32,R16,H32,R17
       DC.L      H33,R18,H33,R19,H34,R20,H34,R21,H35,R22,H35,R23
       DC.L      H36,R24,H36,R25,H37,R26,H37,R27,H38,R28,H38,R29
       DC.L      H39,R30,H39,R31,H40,R32,H40,R32,H39,R31,H39,R30
       DC.L      H38,R29,H38,R28,H37,R27,H37,R26,H36,R25,H36,R24
       DC.L      H35,R23,H35,R22,H34,R21,H34,R20,H33,R19,H33,R18
       DC.L      H32,R17,H32,R16,H31,R15,H31,R14,H30,R13,H30,R12
       DC.L      H29,R11,H29,R10,H28,R9,H28,R8,H27,R7,H27,R6
       DC.L      H26,R5,H26,R4,H25,R3,H25,R2,H24,R1,H24,R0

       DC.L      H24,R0,H24,R1,H23,R2,H23,R3,H22,R4,H22,R5
       DC.L      H21,R6,H21,R7,H20,R8,H20,R9,H19,R10,H19,R11
       DC.L      H18,R12,H18,R13,H17,R14,H17,R15,H16,R16,H16,R17
       DC.L      H15,R18,H15,R19,H14,R20,H14,R21,H13,R22,H13,R23
       DC.L      H12,R24,H12,R25,H11,R26,H11,R27,H10,R28,H10,R29
       DC.L      H9,R30,H9,R31,H8,R32,H8,R32,H9,R31,H9,R30
       DC.L      H10,R29,H10,R28,H11,R27,H11,R26,H12,R25,H12,R24
       DC.L      H13,R23,H13,R22,H14,R21,H14,R20,H15,R19,H15,R18
       DC.L      H16,R17,H16,R16,H17,R15,H17,R14,H18,R13,H18,R12
       DC.L      H19,R11,H19,R10,H20,R9,H20,R8,H21,R7,H21,R6
       DC.L      H22,R5,H22,R4,H23,R3,H23,R2,H24,R1,H24,R0
       DC.L      $FFFFFFFF
DT:  IBYTES    BANANA.DAT
S1 EQU DT
S2 EQU DT+42
S3 EQU DT+84
S4 EQU DT+126
S5 EQU DT+168
S6 EQU DT+210
S7 EQU DT+252
S8 EQU DT+294
S9 EQU DT+336
S10 EQU DT+378
S11 EQU DT+420
S12 EQU DT+462
S13 EQU DT+504
S14 EQU DT+546
S15 EQU DT+588
S16 EQU DT+630
S17 EQU DT+672
S18 EQU DT+714
S19 EQU DT+756
S20 EQU DT+798
S21 EQU DT+840
S22 EQU DT+882
S23 EQU DT+924
S24 EQU DT+966
S25 EQU DT+1008
S26 EQU DT+1050
S27 EQU DT+1092
S28 EQU DT+1134
S29 EQU DT+1176
S30 EQU DT+1218
S31 EQU DT+1260
S32 EQU DT+1302
S33 EQU DT+1344
S34 EQU DT+1386
S35 EQU DT+1428
S36 EQU DT+1470
S37 EQU DT+1512
S38 EQU DT+1554
S39 EQU DT+1596
S40 EQU DT+1638
S41 EQU DT+1680
S42 EQU DT+1722
S43 EQU DT+1764
S44 EQU DT+1806
S45 EQU DT+1848
S46 EQU DT+1890
S47 EQU DT+1932
S48 EQU DT+1974
S49 EQU DT+2016
S50 EQU DT+2058
S51 EQU DT+2100
S52 EQU DT+2142
S53 EQU DT+2184
S54 EQU DT+2226
S55 EQU DT+2268
S56 EQU DT+2310
S57 EQU DT+2352
S58 EQU DT+2394
S59 EQU DT+2436
S60 EQU DT+2478
S61 EQU DT+2520
S62 EQU DT+2562
S63 EQU DT+2604
S64 EQU DT+2646
S65 EQU DT+2688
S66 EQU DT+2730
S67 EQU DT+2772
S68 EQU DT+2814
S69 EQU DT+2856
S70 EQU DT+2898
S71 EQU DT+2940
S72 EQU DT+2982
S73 EQU DT+3024
S74 EQU DT+3066
S75 EQU DT+3108
S76 EQU DT+3150
S77 EQU DT+3192
S78 EQU DT+3234
S79 EQU DT+3276
S80 EQU DT+3318
S81 EQU DT+3360
S82 EQU DT+3402
S83 EQU DT+3444
S84 EQU DT+3486
S85 EQU DT+3528
S86 EQU DT+3570
S87 EQU DT+3612
S88 EQU DT+3654
S89 EQU DT+3696
S90 EQU DT+3738
S91 EQU DT+3780
S92 EQU DT+3822
S93 EQU DT+3864
S94 EQU DT+3906
S95 EQU DT+3948
S96 EQU DT+3990
H0:    DS.W      21,0
H1:    DS.W      21,160
H2:    DS.W      21,320
H3:    DS.W      21,480
H4:    DS.W      21,640
H5:    DS.W      21,800
H6:    DS.W      21,960
H7:    DS.W      21,1120
H8:    DS.W      21,1280
H9:    DS.W      21,1440
H10:   DS.W      21,1600
H11:   DS.W      21,1760
H12:   DS.W      21,1920
H13:   DS.W      21,2080
H14:   DS.W      21,2240
H15:   DS.W      21,2400
H16:   DS.W      21,2560
H17:   DS.W      21,2720
H18:   DS.W      21,2880
H19:   DS.W      21,3040
H20:   DS.W      21,3200
H21:   DS.W      21,3360
H22:   DS.W      21,3520
H23:   DS.W      21,3680
H24:   DS.W      21,3840
H25:   DS.W      21,4000
H26:   DS.W      21,4160
H27:   DS.W      21,4320
H28:   DS.W      21,4480
H29:   DS.W      21,4640
H30:   DS.W      21,4800
H31:   DS.W      21,4960
H32:   DS.W      21,5120
H33:   DS.W      21,5280
H34:   DS.W      21,5440
H35:   DS.W      21,5600
H36:   DS.W      21,5760
H37:   DS.W      21,5920
H38:   DS.W      21,6080
H39:   DS.W      21,6240
H40:   DS.W      21,6400
H41:   DS.W      21,6560
H42:   DS.W      21,6720
H43:   DS.W      21,6880
H44:   DS.W      21,7040
H45:   DS.W      21,7200
H46:   DS.W      21,7360
H47:   DS.W      21,7520
H48:   DS.W      21,7680
R0:    DC.B      0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60
R1:    DC.B      0,4,8,12,16,20,24,28,32,36,40,44,48,52,60,0
R2:    DC.B      0,0,4,8,12,16,20,28,32,36,40,44,48,52,60,0
R3:    DC.B      0,0,4,8,12,20,24,28,32,40,44,48,52,60,0,0
R4:    DC.B      0,0,0,4,12,16,20,28,32,36,44,48,52,56,0,0
R5:    DC.B      0,0,0,4,12,16,24,28,36,40,48,52,60,0,0,0
R6:    DC.B      0,0,0,0,8,12,20,28,32,40,44,52,60,0,0,0
R7:    DC.B      0,0,0,0,8,16,24,28,36,44,52,60,0,0,0,0
R8:    DC.B      0,0,0,0,4,12,20,28,36,44,52,60,0,0,0,0
R9:    DC.B      0,0,0,0,0,4,12,20,32,40,48,60,0,0,0,0
R10:   DC.B      0,0,0,0,0,4,16,28,36,48,60,0,0,0,0,0
R11:   DC.B      0,0,0,0,0,0,8,20,32,44,60,0,0,0,0,0
R12:   DC.B      0,0,0,0,0,0,12,28,44,60,0,0,0,0,0,0
R13:   DC.B      0,0,0,0,0,0,0,16,36,60,0,0,0,0,0,0
R14:   DC.B      0,0,0,0,0,0,0,28,60,0,0,0,0,0,0,0
R15:   DC.B      0,0,0,0,0,0,0,0,60,0,0,0,0,0,0,0
R16:   DS.B      16,0
R17:   DC.B      0,0,0,0,0,0,0,60,0,0,0,0,0,0,0,0
R18:   DC.B      0,0,0,0,0,0,0,60,28,0,0,0,0,0,0,0
R19:   DC.B      0,0,0,0,0,0,60,36,16,0,0,0,0,0,0,0
R20:   DC.B      0,0,0,0,0,0,60,44,28,12,0,0,0,0,0,0
R21:   DC.B      0,0,0,0,0,60,44,32,20,8,0,0,0,0,0,0
R22:   DC.B      0,0,0,0,0,60,48,36,28,16,4,0,0,0,0,0
R23:   DC.B      0,0,0,0,60,48,40,32,20,12,4,0,0,0,0,0
R24:   DC.B      0,0,0,0,60,52,44,36,28,20,12,4,0,0,0,0
R25:   DC.B      0,0,0,0,60,52,44,36,28,24,16,8,0,0,0,0
R26:   DC.B      0,0,0,60,52,44,40,32,28,20,12,8,0,0,0,0
R27:   DC.B      0,0,0,60,52,48,40,36,28,24,16,12,4,0,0,0
R28:   DC.B      0,0,56,52,48,44,36,32,28,20,16,12,4,0,0,0
R29:   DC.B      0,0,60,52,48,44,40,32,28,24,20,12,8,4,0,0
R30:   DC.B      0,60,52,48,44,40,36,32,28,20,16,12,8,4,0,0
R31:   DC.B      0,60,52,48,44,40,36,32,28,24,20,16,12,8,4,0
R32:   DC.B      60,56,52,48,44,40,36,32,28,24,20,16,12,8,4,0
MEM: DC.L 0
VBLV:  DC.L      0
INDEX: DC.W      0
NULL: DC.W 0
LOADFIL:
 DC.B 'LOADER.IMG',0
 ALIGN.W
COLORS2: DS.W 16,0
COLORS1: DC.W $000,$707,$222,$222,$444,$444,$770,$770,$750
         DC.W $750,$530,$530,$777,$777,$700,$700
MESSAGE:
 IBYTES ELITE_TX.B
 ALIGN.W
GRAFIX:
 IBYTES ELITELG.DAT
 ALIGN.W
LEATH: IBYTES L.*
 ALIGN.W
FONT:  IBYTES FATFONT.DAT
 ALIGN.W
 END

 