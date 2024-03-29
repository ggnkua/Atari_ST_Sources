          BRA       MAIN

LOADFIL:  MOVE.W    #0,-(SP)
          MOVE.L    D0,-(SP)
          MOVE.W    #$3D,-(SP)
          TRAP      #1
          ADDQ.L    #8,SP
          MOVE.W    D0,HANDLE
          MOVE.L    D1,-(SP)
          MOVE.L    D2,-(SP)
          MOVE.W    HANDLE,-(SP)
          MOVE.W    #$3F,-(SP)
          TRAP      #1
          ADD.L     #12,SP
          MOVE.W    HANDLE,-(SP)
          MOVE.W    #$3E,-(SP)
          TRAP      #1
          ADDQ.L    #4,SP
          RTS

LOADFILS: MOVE.L    #PICNAME,D0
          MOVE.L    #PIC,D1
          MOVE.L    #32128,D2
          JSR       LOADFIL
          RTS


SAVEFIL:  MOVE.W    #1,-(SP)
          MOVE.L    D0,-(SP)
          MOVE.W    #$3D,-(SP)
          TRAP      #1
          ADDQ.L    #8,SP
          MOVE.W    D0,HANDLE
          MOVE.L    D1,-(SP)
          MOVE.L    D2,-(SP)
          MOVE.W    HANDLE,-(SP)
          MOVE.W    #$40,-(SP)
          TRAP      #1
          ADD.L     #12,SP
          MOVE.W    HANDLE,-(SP)
          MOVE.W    #$3E,-(SP)
          TRAP      #1
          ADDQ.L    #4,SP
          RTS

SAVEFILS: MOVE.L    #FPICNAM,D0
          MOVE.L    #FPIC,D1
          MOVE.L    #27648,D2
          JSR       SAVEFIL
          RTS





SUPER:    MOVE.L    #0,-(SP)
          MOVE.W    #$20,-(SP)
          TRAP       #1
          ADDQ.L    #6,SP
          MOVE.L    D0,SAVESTCK

          RTS
           
USER:     MOVE.L    SAVESTCK,-(SP)
          MOVE.W    #$20,-(SP)
          TRAP      #1
          ADDQ.L    #6,SP
            

          RTS

            
            
MAIN:     JSR       SUPER




          JSR       LOADFILS

          MOVE.L    #14840,LAGGTILL


          MOVEA.L   #PIC,A0
          ADDA.L    LAGGTILL,A0
          MOVEA.L   #FPIC,A1
          MOVEQ.L   #2,D7
BLOOP:    ADD.L     #16,LAGGTILL
          MOVEQ.L   #0,D2
TILLBAK:  MOVEA.L   #PIC,A0
          ADD.L     LAGGTILL,A0
          MOVE.L    #23,D0
SRUNT:    MOVE.L    #2,D1
LRUNT:    MOVEQ.L   #0,D3
          MOVE.W    (A0),D3
          LSR.L     D2,D3
          MOVEQ.L   #16,D4
          SUB.L     D2,D4
          MOVEQ.L   #0,D5
          MOVE.W    16(A0),D5
          LSL.L     D4,D5
          OR.W      D5,D3
          MOVE.W    D3,(A1)
          MOVEQ.L   #0,D3
          MOVEQ.L   #0,D5
          MOVE.W    2(A0),D3
          LSR.L     D2,D3
          MOVE.W    18(A0),D5
          LSL.L     D4,D5
          OR.W      D5,D3
          MOVE.W    D3,2(A1)
          MOVEQ.L   #0,D3
          MOVEQ.L   #0,D3
          MOVE.W    4(A0),D3
          LSR.L     D2,D3
          MOVE.W    20(A0),D5
          LSL.L     D4,D5
          OR.W      D5,D3
          MOVE.W    D3,4(A1)
          MOVEQ.L   #0,D3
          MOVEQ.L   #0,D5
          MOVE.W    6(A0),D3
          LSR.L     D2,D3
          MOVE.W    22(A0),D5
          LSL.L     D4,D5
          OR.W      D5,D3
          MOVE.W    D3,6(A1)
          ADDA.L    #8,A1
          ADDA.L    #8,A0
          DBRA      D1,LRUNT
          ADDA.L    #136,A0
          DBRA      D0,SRUNT
          ADDQ.L    #1,D2
          CMP.L     #16,D2
          BLT       TILLBAK
          DBRA      D7,BLOOP

          JSR       SAVEFILS



          MOVE.W    #0,-(SP)
          MOVE.L    #-1,-(SP)
          MOVE.L    #-1,-(SP)
          MOVE.W    #5,-(SP)
          TRAP      #14
          ADDA.L    #12,SP

          MOVE.L    #PALETTE,-(SP)
          MOVE.W    #6,-(SP)
          TRAP      #14
          ADDQ.L    #6,SP

          MOVE.W    #2,-(SP)
          TRAP      #14
          ADDQ.L    #2,SP
          MOVE.L    D0,PHYSADDR

          MOVEA.L   #FPIC,A0
          MOVEA.L   A0,A3
          ADDA.L    #27648,A3

          MOVE.L    #100,D7
LOOP:     CMP.L     A3,A0

          MOVE.L    #FPIC,A0
          MOVEQ.L   #47,D0
VIDARE:   MOVE.L    PHYSADDR,A1
          MOVEM.L   D0-A6,-(SP)
          MOVE.W    #37,-(SP)
          TRAP      #14
          ADDQ.L    #2,SP
          MOVEM.L   (SP)+,D0-A6
          MOVE.L    D0,-(SP)
          MOVE.L    #23,D0
UT:       MOVEM.L   (A0),D1-D4/A4-A5
          MOVEQ.L   #7,D5
          MOVE.L    A1,A2
UT2:      MOVEM.L   D1-D4/A4-A5,8(A2)
          MOVEM.L   D1-D4/A4-A5,32(A2)
          MOVEM.L   D1-D4/A4-A5,56(A2)
          MOVEM.L   D1-D4/A4-A5,80(A2)
          MOVEM.L   D1-D4/A4-A5,104(A2)
          MOVEM.L   D1-D4/A4-A5,128(A2)
          ADDA.L    #3840,A2
          DBRA      D5,UT2

          ADDA.L    #24,A0
          ADDA.L    #160,A1
          DBRA      D0,UT
          MOVE.W    #0,$FF8240
          MOVE.L    (SP)+,D0
          DBRA      D0,VIDARE
          DBRA      D7,LOOP


          MOVE.W    #1,-(SP)
          MOVE.L    #-1,-(SP)
          MOVE.L    #-1,-(SP)
          MOVE.W    #5,-(SP)
          TRAP      #14
          ADDA.L    #12,SP


          JSR       USER
 
          RTS


PICNAME:  DC.B      '\BACK2.NEO',0,0
FPICNAM:  DC.B      '\RUTOR',0,0
PIC:      DS.L      8032
FPIC:     DS.L      23041
SAVESTCK: DS.L      1
HANDLE:   DS.L      1
PHYSADDR: DS.L      1
PALETTE:  DC.W      $0,$777,$777,$777,$444,$555,$666,$777,$110,$220,$330,$440,$550,$660,$770,$777
LAGGTILL: DS.L      1
          END
 