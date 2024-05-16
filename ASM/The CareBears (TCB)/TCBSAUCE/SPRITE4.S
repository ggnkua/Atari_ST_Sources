X:        BRA       MAIN


SETINTS:  MOVE.W    #$2700,SR
          MOVE.L    $70,OLDVSYNC
          MOVE.L    #VSYNC,$70
          MOVE.B    $FFFA07,MFPIEA
          MOVE.B    $FFFA09,MFPIEB
          MOVE.B    $FFFA1B,MFPTBC
          MOVE.B    $FFFA21,MFPTBD
          MOVE.L    $120,OLDTIMB

          MOVE.B    #0,$FFFA07
;          MOVE.B    #1,$FFFA07
;          MOVE.B    #1,$FFFA13
          MOVE.B    #0,$FFFA09
;          MOVE.L    #HSYNC,$120
;          MOVE.B    #1,$FFFA21
;          MOVE.B    #0,$FFFA1B
          MOVE.W    #$2300,SR
          RTS

RETINTS:  MOVE.W    #$2700,SR
          MOVE.L    OLDVSYNC,$70
          MOVE.B    MFPIEA,$FFFA07
          MOVE.B    MFPIEB,$FFFA09
          MOVE.B    MFPTBC,$FFFA1B
          MOVE.B    MFPTBD,$FFFA21
          MOVE.L    OLDTIMB,$120
          MOVE.W    #$2300,SR
          RTS


VSYN:     


VSYNC:    NOT.W     VANNAN
          BEQ       FORBIVS1
          ST        VFLAG
          MOVE.L    COUNT,SPRITECOUNT
          CLR.L     COUNT
          MOVE.L    #0,A3
          MOVE.L    #0,A2
          CLR.W     COLPEK
FORBIVS1: RTE




PALETTE:  DC.W      $0000,$0410,$0621,$0744,$0130,$0000,$0000,$0000
          DC.W      $0150,$0000,$0000,$0000,$0571,$0000,$0000,$0777

PALETTE2: DC.W      $000,$111,$222,$333,$444,$555,$666,$777,$700
          DC.W      $234,$345,$001,$456,$012,$567,$123



;D7 = SHIFTNING * 1024
;A6 = SPRITEPOINTER
;A5 = SCREENPOINTER
TANDSPRITE: 
          ADDA.L    D7,A6
          MOVEM.L   (A6)+,D0-D7

          OR.L      D0,(A5)
          OR.L      D0,2400(A5)
          OR.L      D1,8(A5)
          OR.L      D1,2408(A5)

          OR.L      D2,160(A5)
          OR.L      D2,2240(A5)
          OR.L      D3,168(A5)
          OR.L      D3,2248(A5)

          OR.L      D4,320(A5)
          OR.L      D4,2080(A5)
          OR.L      D5,328(A5)
          OR.L      D5,2088(A5)

          OR.L      D6,480(A5)
          OR.L      D6,1920(A5)
          OR.L      D7,488(A5)
          OR.L      D7,1928(A5)

          MOVEM.L   (A6),D0-D7

          OR.L      D0,640(A5)
          OR.L      D0,1760(A5)
          OR.L      D1,648(A5)
          OR.L      D1,1768(A5)

          OR.L      D2,800(A5)
          OR.L      D2,1600(A5)
          OR.L      D3,808(A5)
          OR.L      D3,1608(A5)

          OR.L      D4,960(A5)
          OR.L      D4,1440(A5)
          OR.L      D5,968(A5)
          OR.L      D5,1448(A5)

          OR.L      D6,1120(A5)
          OR.L      D6,1280(A5)
          OR.L      D7,1128(A5)
          OR.L      D7,1288(A5)

          RTS




SHIFTSPRITE:
          LEA       HALFBALL(PC),A0
          LEA       SHIFTEDBALLS(PC),A1
          MOVE.W    #0,SHIFT
OMSS1:    MOVEQ     #0,D0
          MOVE.L    D0,D1
          MOVE.L    D0,D2
          MOVE.L    D0,D3
          MOVE.L    D0,D4
          MOVE.L    D0,D5
          MOVE.L    D0,D6
          MOVE.L    D0,D7
          MOVEM.W   (A0),D0-D7
          SWAP      D7
          MOVE.W    SHIFT,D7
          LSL.L     D7,D0
          LSL.L     D7,D1
          MOVE.W    D0,(A1)+
          MOVE.W    D1,(A1)+
          SWAP      D0
          SWAP      D1
          MOVE.W    D0,(A1)+
          MOVE.W    D1,(A1)+
          MOVE.W    #0,D7
          SWAP      D7
          MOVE.W    SHIFT,D0
          LSL.L     D0,D2
          LSL.L     D0,D3
          MOVE.W    D2,(A1)+
          MOVE.W    D3,(A1)+
          SWAP      D2
          SWAP      D3
          MOVE.W    D2,(A1)+
          MOVE.W    D3,(A1)+
          LSL.L     D0,D4
          LSL.L     D0,D5
          MOVE.W    D4,(A1)+
          MOVE.W    D5,(A1)+
          SWAP      D0
          SWAP      D1
          MOVE.W    D4,(A1)+
          MOVE.W    D5,(A1)+
          LSL.L     D0,D6
          LSL.L     D0,D7
          MOVE.W    D6,(A1)+
          MOVE.W    D7,(A1)+
          SWAP      D6
          SWAP      D7
          MOVE.W    D6,(A1)+
          MOVE.W    D7,(A1)+
          MOVEQ     #0,D0
          MOVE.L    D0,D1
          MOVE.L    D0,D2
          MOVE.L    D0,D3
          MOVE.L    D0,D4
          MOVE.L    D0,D5
          MOVE.L    D0,D6
          MOVE.L    D0,D7

          MOVEM.W   16(A0),D0-D7

          SWAP      D7
          MOVE.W    SHIFT,D7
          LSL.L     D7,D0
          LSL.L     D7,D1
          MOVE.W    D0,(A1)+
          MOVE.W    D1,(A1)+
          SWAP      D0
          SWAP      D1
          MOVE.W    D0,(A1)+
          MOVE.W    D1,(A1)+
          MOVE.W    #0,D7
          SWAP      D7
          MOVE.W    SHIFT,D0
          LSL.L     D0,D2
          LSL.L     D0,D3
          MOVE.W    D2,(A1)+
          MOVE.W    D3,(A1)+
          SWAP      D2
          SWAP      D3
          MOVE.W    D2,(A1)+
          MOVE.W    D3,(A1)+
          LSL.L     D0,D4
          LSL.L     D0,D5
          MOVE.W    D4,(A1)+
          MOVE.W    D5,(A1)+
          SWAP      D0
          SWAP      D1
          MOVE.W    D4,(A1)+
          MOVE.W    D5,(A1)+
          LSL.L     D0,D6
          LSL.L     D0,D7
          MOVE.W    D6,(A1)+
          MOVE.W    D7,(A1)+
          SWAP      D6
          SWAP      D7
          MOVE.W    D6,(A1)+
          MOVE.W    D7,(A1)+
          ADDQ.W    #1,SHIFT
          CMP.W     #16,SHIFT
          BLT       OMSS1

          RTS




SHIFTBALL:
          LEA       SHIFTEDBALLS(PC),A0
          LEA       HALFBALL(PC),A1
          MOVEQ.L   #15,D7
          MOVEQ     #0,D5
OMSB1:    MOVEQ     #7,D6
OMSB2:    MOVEQ     #0,D0
          MOVEQ     #0,D1
          MOVE.W    (A1)+,D0
          MOVE.W    (A1)+,D1
          SWAP      D0
          SWAP      D1
          LSR.L     D5,D0
          LSR.L     D5,D1


          SWAP      D0
          SWAP      D1
          MOVE.W    D0,(A0)+
          MOVE.W    D1,(A0)+
          SWAP      D0
          SWAP      D1
          MOVE.W    D0,(A0)+
          MOVE.W    D1,(A0)+
          DBRA      D6,OMSB2
          ADDQ.L    #1,D5
          LEA       HALFBALL(PC),A1
          DBRA      D7,OMSB1
          RTS




INITVARS: 
          MOVE.W    #4,-(SP)
          TRAP      #14
          ADDQ.L    #2,SP
          MOVE.W    D0,OLDRES
          MOVE.W    #2,-(SP)
          TRAP      #14
          ADDQ.L    #2,SP
          MOVE.L    D0,PHYSADDR
          MOVE.L    PHYSADDR,PHYSADD2
          SUB.L     #32000,PHYSADD2
          CLR.L     -(SP)
          MOVE.W    #$20,-(SP)
          TRAP      #1
          ADDQ.L    #6,SP
          MOVE.L    D0,SAVESTCK
          CLR.W     -(SP)
          MOVE.L    PHYSADDR,-(SP)
          MOVE.L    PHYSADDR,-(SP)
          MOVE.W    #5,-(SP)
          TRAP      #14
          ADDA.L    #12,SP
          MOVE.L    #SPALETTE,A0
          MOVEM.L   $FF8240,D0-D4/D6-D7/A1
          MOVEM.L   D0-D4/D6-D7/A1,(A0)
          MOVE.L    #PALETTE,A0
          MOVEM.L   (A0),D0-D4/D6-D7/A1
          MOVEM.L   D0-D4/D6-D7/A1,$FF8240
          MOVE.L    PHYSADDR,OLDPHYS



          LEA       TAB160,A0
          MOVEQ.L   #0,D1
          MOVE.L    #199,D0
MAKTAB:   MOVE.L    D1,(A0)+
          ADD.L     #160,D1
          DBRA      D0,MAKTAB

          BSR       SHIFTBALL
          BSR       SETINTS


          RTS
            
ENDP:     TST.B     VFLAG
          BEQ       ENDP
      
          BSR       RETINTS

          MOVE.W    OLDRES,-(SP)
          MOVE.L    OLDPHYS,-(SP)
          MOVE.L    OLDPHYS,-(SP)
          MOVE.W    #5,-(SP)
          TRAP      #14
          ADD.L     #12,SP

          MOVE.L    #$FF8240,A0
          MOVE.L    #SPALETTE,A2
          MOVEM.L   (A2),D0-D7
          MOVEM.L   D0-D7,(A0)
            
            
            
          MOVE.L    SAVESTCK,-(SP)
          MOVE.W    #$20,-(SP)
          TRAP      #1
          ADDQ.L    #6,SP
            

          RTS


MAIN:     BSR       INITVARS
          MOVE.L    PHYSADDR,A4
          LEA       JUMPTAB(PC),A6
          MOVE.L    #0,D6
          MOVEQ     #16,D4
          MOVEQ     #0,D7
          MOVE.W    #0,A3
          MOVE.W    #0,A2
          CLR.W     COLPEK
MLOOP:    
          MOVEQ     #0,D7
          MOVE.L    PHYSADDR,A5
          LEA       BALLXDAT(PC),A4
          MOVE.W    (A4,A3.w),D7
          MOVE.L    D7,D6
          LSR.L     #1,D6
          AND.L     #$FFFFFFF8,D6
          ADD.L     D6,A5
          AND.L     #$F,D7
          LSL.L     #6,D7
          LEA       BALLYDAT(PC),A4
          MOVEQ     #0,D6
          MOVE.W    (A4,A2.W),D6
          ADDA.L    D6,A5
          MOVE.W    COLPEK,D0
          LEA       COLTAB(PC),A4
          MOVEQ     #0,D1
          MOVE.W    (A4,D0.W),D1
          ADDA.L    D1,A5
          LEA       SHIFTEDBALLS(PC),A6
          BSR       TANDSPRITE
          ADDQ.W    #2,COLPEK
          ADDQ.W    #2,A3
          CMP.L     #36,A3
          BLT       FORBIM1
          MOVE.W    #0,A3
          ADDQ.W    #2,A2
          CMP.W     #20,A2
          BLT       FORBIM1
;          MOVE.W    #$333,$FF8240
          CMP.B     #185,$FFFC02
          BEQ       UTM1
OMM1:     TST.B     VFLAG
          BEQ       OMM1
          CLR.B     VFLAG
          MOVE.W    #0,$FF8240


FORBIM1:  
          ADDQ.L    #1,COUNT
          CMP.B     #185,$FFFC02
          BNE       MLOOP

UTM1:     BSR       ENDP

          MOVE.L    SPRITECOUNT,D4
          RTS



PIXTAB:   DS.L      1024
JUMPTAB:  DC.L      0
VFLAG:    DC.W      0
SPRITECOUNT: 
          DC.L      0
COUNT:    DC.L      0

PHYSADDR: DC.L      0
PHYSADD2: DC.L      0


BALLXDAT: DC.W      7,24,41,58,75,92,109,126,143,160,177,194,211,228,245,262,279,296
BALLYDAT: DC.W      0,2720,5440,8160,10880,13600,16320,19040,21760,24480,27200

COLTAB:   DC.W      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          DC.W      4,4,4,4,4,4,0,0,4,4,4,0,0,4,4,0,0,0
          DC.W      4,4,4,4,4,4,0,4,4,0,4,4,0,4,0,4,0,0
          DC.W      0,0,4,4,0,0,4,0,0,0,0,0,0,4,4,0,0,0
          DC.W      0,0,4,4,0,0,4,0,0,0,0,0,0,4,0,4,0,0
          DC.W      0,0,4,4,0,0,0,4,4,0,4,4,0,4,0,4,0,0
          DC.W      0,0,4,4,0,0,0,0,4,4,4,0,0,4,4,0,0,0
          DC.W      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          DC.W      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          DC.W      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          DC.W      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

COLPEK:   DC.W      0

HALFBALL:

          DC.W      $07E0,$0000,$1EF8,$0100
          DC.W      $3BBC,$0440,$5C36,$23C8
          DC.W      $72CA,$0D74,$D41F,$2FE0
          DC.W      $E9A3,$177C,$A3D7,$5FE8



VANNAN:   DC.L      0
HANDLE:   DC.L      0
OLDVSYNC: DC.L      0
MFPIEA:   DC.W      0
MFPIEB:   DC.W      0
MFPTBC:   DC.W      0
MFPTBD:   DC.W      0
OLDTIMB:  DC.L      0

SPALETTE: DS.L      8

SHIFT:    DC.L      0
OLDPHYS:  DC.L      0
OLDRES:   DC.W      0
SAVESTCK: DC.L      0

TAB160:   DS.L      200
SHIFTEDBALLS:
          DS.L      4096

          END
 
