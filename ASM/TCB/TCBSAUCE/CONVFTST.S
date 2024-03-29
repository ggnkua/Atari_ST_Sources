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


SAVEFIL:  MOVE.W    #0,-(SP)
          MOVE.L    D0,-(SP)
          MOVE.W    #$3C,-(SP)
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
          MOVE.L    #336,D2
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

          MOVEA.L   #BPIC,A0
          MOVEA.L   #FPIC,A1
          MOVEQ.L   #40,D0
OMM1:     MOVEQ.L   #0,D2
          MOVE.B    (A0),D2
          MOVE.B    D2,(A1)+
          MOVE.B    160(A0),D2
          MOVE.B    D2,(A1)+
          MOVE.B    320(A0),D2
          MOVE.B    D2,(A1)+
          MOVE.B    480(A0),D2
          MOVE.B    D2,(A1)+
          MOVE.B    640(A0),D2
          MOVE.B    D2,(A1)+
          ADDQ.L    #8,A0
          DBRA      D0,OMM1


          MOVEA.L   #BPIC,A0
          ADDA.L    #800,A0
          MOVEQ.L   #25,D0
OMM2:     MOVEQ.L   #0,D2
          MOVE.B    (A0),D2
          MOVE.B    D2,(A1)+
          MOVE.B    160(A0),D2
          MOVE.B    D2,(A1)+
          MOVE.B    320(A0),D2
          MOVE.B    D2,(A1)+
          MOVE.B    480(A0),D2
          MOVE.B    D2,(A1)+
          MOVE.B    640(A0),D2
          MOVE.B    D2,(A1)+
          ADDQ.L    #8,A0
          DBRA      D0,OMM2

          MOVE.W    #0,-(SP)
          MOVE.L    #-1,-(SP)
          MOVE.L    #-1,-(SP)
          MOVE.W    #5,-(SP)
          TRAP      #14
          ADDA.L    #12,SP


          MOVE.W    #$0,$FF8240
          MOVE.W    #$777,$FF8242


          MOVE.W    #2,-(SP)
          TRAP      #14
          ADDQ.L    #2,SP
          MOVE.L    D0,PHYSADDR




          MOVE.W    #30,D0
          MOVEA.L   #FPIC,A0
          MOVEA.L   PHYSADDR,A1
OMMM1:    MOVE.B    (A0)+,(A1)
          MOVE.B    (A0)+,160(A1)
          MOVE.B    (A0)+,320(A1)
          MOVE.B    (A0)+,480(A1)
          MOVE.B    (A0)+,640(A1)
          ADDA.L    #8,A1
          DBRA      D0,OMMM1


          JSR       USER
 
          RTS


PICNAME:  DC.B      '\MINIFONT.NEO',0
FPICNAM:  DC.B      '\MINIFONT.FNT',0
PIC:      DS.B      128
BPIC:     DS.L      8000
FPIC:     DS.B      336
SAVESTCK: DS.L      1
HANDLE:   DS.L      1
PHYSADDR: DS.L      1
PALETTE:  DC.W      $0,$777,$777,$777,$444,$555,$666,$777,$110,$220,$330,$440,$550,$660,$770,$777
LAGGTILL: DS.L      1
          END
 