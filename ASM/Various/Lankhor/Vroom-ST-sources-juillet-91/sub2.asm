         TTL - SUBROUTINES 2 (Background) - V15 - 3 Apr 91

         INCLUDE  'EQU.ASM'

         XDEF     INISCL,INIBCK,PANBCK

         XREF     CURSCR,adscrol,adsky

* INISCL - Initialize Scrolling
* INPUT : A0 Points to Source Zone
*         A4 Points to Target Zone

INISCL  MOVE.W  #HBCKEQU-1,D0  
        ADDA.L  #160*(HBCKEQU-1),A0
BINSCL: MOVE.L  A0,A2
        LEA.L   8(A2),A3
        MOVE.W  #18,D1
B1SCL:  BSR     PDBL
        DBF     D1,B1SCL
        LEA.L   160*HBCKEQU(A0),A3
        BSR     PDBL
* 2EME BLOC
        LEA.L   -8(A3),A2
        MOVE.W  #18,D1
B2SCL:  BSR     PDBL
        DBF     D1,B2SCL
        LEA.L   320*HBCKEQU(A0),A3
        BSR     PDBL
* 3EME BLOC
        LEA.L   -8(A3),A2
        MOVE.W  #18,D1
B3SCL:  BSR     PDBL
        DBF     D1,B3SCL
        LEA.L   480*HBCKEQU(A0),A3
        BSR     PDBL
* 4EME BLOC DE 17
        LEA.L   -8(A3),A2
        MOVE.W  #17,D1          BUG AFFIC
B4SCL:  BSR     PDBL
        DBF     D1,B4SCL
        MOVE.L  A0,A3
        BSR     PDBL
* RETOUR BLOC DEBUT
        LEA.L   -8(A3),A2
        MOVE.W  #18,D1
B5SCL:  BSR     PDBL
        DBF     D1,B5SCL
        LEA.L   2720(A0),A3
        BSR     PDBL
        BSR     PDBL            BUG AFFIC
        LEA.L   -160(A0),A0
        DBF     D0,BINSCL
        RTS

PDBL    MOVE.W  (A2)+,(A4)+
        MOVE.W  (A3)+,(A4)+
        MOVE.W  (A2)+,(A4)+
        MOVE.W  (A3)+,(A4)+
        MOVE.W  (A2)+,(A4)+
        MOVE.W  (A3)+,(A4)+
        MOVE.W  (A2)+,(A4)+
        MOVE.W  (A3)+,(A4)+
        RTS

* INIBCK - Init Background

INIBCK   MOVE.L   #BCKEQU,BCKADR   Init BCKADR with Top Address
         CLR.W    BCKINC           Init BCKINC
         RTS

* PANBCK - Pan Background Routine
*        Input : D7 Contains # of Bits to Shift R/L + Sign
*                D7 Can be Greater than 16


PANBCK   LEA.L    BCKADR(PC),A5  ;Get Pointer to BCK and INC (2)
         MOVE.L   (A5),A1        ;Get BCKADR Content
         MOVE.W   4(A5),D5       ;Get BCKINC Content (0 TO 15)
         TST      D7             ;Test for R/L Move              
         BMI.S    PANBCK12

         ADD      D7,D5          ;Here D7 >=0
PANBCK1  CMPI     #16,D5
         BLT.S    PANBCK16
         LEA.L    16(A1),A1
         CMPA.L   #BCKEQU+1264,A1 ;End of Mem Right?
         BLE.S    PANBCK2
         LEA.L    -1264(A1),A1    ;NB BLOC *320
PANBCK2  SUB      #16,D5
         BRA.S    PANBCK1

PANBCK12 ADD      D7,D5          ;Here D7 <0
         BPL.S    PANBCK16
PANBCK13 LEA.L   -16(A1),A1
         CMPA.L   #BCKEQU,A1
         BGE.S    PANBCK14       ;If PL, No
         LEA.L    1264(A1),A1     ;NB BLOC *320
PANBCK14 ADD      #16,D5
         BLT.S    PANBCK13

PANBCK16 MOVE.L   A1,(A5)        ;Update BCKADR
         MOVE.W   D5,4(A5)       ;Update BCKINC (0 to 15)
        
* Test for Display or Not 

         MOVE.L   adscrol(PC),A0 Point to top of Road in Proper Screen
         CMPA.L   #32000,A0  Below Screen?      
         BLT.S    PANBCKA        If LT, No     
         RTS                                   
PANBCKA 
         MOVE.L   #160*HBCKEQU,D0
         MOVE.L   A0,D1
         SUB.L    adsky,D1
         SUB.L    D1,D0
         BGT.S    PANBCKB
         RTS    
PANBCKB  
         MOVE.L   A0,D7
         SUBA.L   D1,A0
         ADD.W    D1,D1
         ADD.W    D1,A1
         LSL.W    #2,D1
         ADD.W    D1,A1
         SUB.L    D0,adsky

         SUB.L    #TSKYEQU+160*HBCKEQU,D7
         BPL.S    PANBCKD
         ADD.L    D7,D0
         BGT.S    PANBCKD
         RTS           
PANBCKD  DIVU     #160,D0
         SUBQ     #1,D0          .
         ADD.L    CURSCR,A0

* Display

         SWAP     D0
         MOVE     D5,D0          ;D0 from 0 to 15
         CMPI     #8,D0
         BLT.S    PLBCK3         ;Low
         SUB      #16,D0         ;High : D1 From 16 to 1
         NEG      D0
         BRA      PHBCK3 
       
PLBCK2: SWAP    D0
PLBCK3: MOVEM.L 292(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 264(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 236(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 208(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 180(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 152(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 124(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 96(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 68(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 40(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 12(A1),D1-D7
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        LSL.L   D0,D4
        LSL.L   D0,D5
        LSL.L   D0,D6
        LSL.L   D0,D7
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        SWAP    D5
        SWAP    D6
        SWAP    D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L (A1),D1-D3
        LSL.L   D0,D1
        LSL.L   D0,D2
        LSL.L   D0,D3
        SWAP    D1
        SWAP    D2
        SWAP    D3
        MOVEM.W D1-D3,-(A0)
        LEA.L   1600(A1),A1     NB BLOC+1*320
        SWAP    D0 
        DBF     D0,PLBCK2
        RTS   

PHBCK2: SWAP    D0
PHBCK3: MOVEM.L 292(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 264(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 236(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 208(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 180(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 152(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 124(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 96(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 68(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 40(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L 12(A1),D1-D7
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        LSR.L   D0,D4
        LSR.L   D0,D5
        LSR.L   D0,D6
        LSR.L   D0,D7
        MOVEM.W D1-D7,-(A0)
        MOVEM.L (A1),D1-D3
        LSR.L   D0,D1
        LSR.L   D0,D2
        LSR.L   D0,D3
        MOVEM.W D1-D3,-(A0)
        LEA.L   1600(A1),A1     NB BLOC+1*320
        SWAP    D0 
        DBF     D0,PHBCK2
        RTS

* Background Pointers

BCKADR  DC.L     0     ;Pointer to Background 2
BCKINC  DC.W     0     ;Bit increment From BCKADR2

         END
