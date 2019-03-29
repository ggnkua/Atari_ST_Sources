DEBUT:
* AFFICHE LE MESSAGE

        PEA     TEXT
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP

* EXECUTE LA ROUTINE EN MODE
* SUPERVISEUR (POUR ACCEDER
* AUX REGISTRES DU RESET)

        PEA     INIT
        MOVE.W  #$26,-(SP)
        TRAP    #14
        ADDQ.L  #6,SP

* FIN DU PROGRAM EN RESERVEANT LA
* MEMOIRE (POUR QUE LE SYSTEM N'EF-
* FACE PAS NOTRE ROUTINE).

        MOVE.W  #0,-(SP)
        MOVE.L  #FIN-DEBUT+1024,-(SP)
        MOVE.W  #$31,-(SP)
        TRAP    #1

TEXT:   DC.B    "DEMO RESET INSTALLE !",13,10
        DC.B    "CODED BY FIRSTE FOR THE",13,10
        DC.B    "TOXIC MAG. (C) 1992",7,0
        EVEN
INIT:
* ADRESSE DU NOUVEAU RESET DANS SON VECTEUR
        LEA     RESET(PC),A0
        MOVE.L  A0,$42A
* VALIDATION DU NOUVEAU RESET AVEC LA VALEUR
* PI.
        MOVE.L  #$31415926,$426
        RTS
        



RESET:  
        MOVE.W  #$2700,SR
* ADRESSE DE L'ÇCRAN POUR MA
* DÇMO
        MOVE.L  #$78000,$44E
* DÇTRUIT LA ROUTINE RESET
        CLR.L   $426
* BIP CLAVIER
        CLR.B   $484.W
* REGISTRES DES TIMERS
        CLR.B   $FFFA1F
        CLR.B   $FFFA21
        CLR.B   $FFFA23
        CLR.B   $FFFA25
        CLR.B   $FFFA19
        CLR.B   $FFFA1B
        CLR.B   $FFFA1D
        CLR.B   $FFFA07
        CLR.B   $FFFA09
        CLR.B   $FFFA13
        CLR.B   $FFFA15
        CLR.B   $FFFA0F
        CLR.B   $FFFA11
        CLR.B   $FFFA17
* VECTEURS DES TIMERS
        CLR.L   $110
        CLR.L   $114
        CLR.L   $120
        CLR.L   $134
* INSTAURATION D'UNE PILE AVANT LA
* DEMO.
        LEA     DEMO(PC),A0
        SUB.L   #4,A0
        MOVE.L  A0,SP
* ECRAN NOIR
        MOVE.L  #$FFFF8240,A0
        CLR.L   (A0)+
        CLR.L   (A0)+
        CLR.L   (A0)+
        CLR.L   (A0)+
        CLR.L   (A0)+
        CLR.L   (A0)+
        CLR.L   (A0)+
        CLR.L   (A0)+
* BASSE RÇSOLUTION
* 50 HZ
* ADRESSE DE L'ÇCRAN POUR LE
* SHIFTER
        MOVE.B  #0,$FFFF8260
        MOVE.B  #2,$FFFF820A
        MOVE.B  #$07,$FFFF8201
        MOVE.B  #$80,$FFFF8203
* DÇCOMPACTAGE ( PACK ICE 2.4)  
        BSR     UNPACK
* EXECUTION DE LA DEMO
        BRA     DEMO

UNPACK:
        LEA     DEMO(PC),A0
;********************************************* UNPACKING ROUTINE OF PACK-ICE
; A0 = ADRESS OF PACKED DATA
; "BSR" OR "JSR" TO ICE_DECRUNCH_2 WITH REGISTER A0 PREPARED.
ICE_DECRUNCH_2:
        LINK    A3,#-120
        MOVEM.L D0-A6,-(SP)
        LEA     120(A0),A4
        MOVE.L  A4,A6
        BSR     .GETINFO
        CMPI.L  #'ICE!',D0
        BNE     .NOT_PACKED
        BSR.S   .GETINFO
        LEA.L   -8(A0,D0.L),A5
        BSR.S   .GETINFO
        MOVE.L  D0,(SP)
        ADDA.L  D0,A6
        MOVE.L  A6,A1

        MOVEQ   #119,D0
.SAVE:  MOVE.B  -(A1),-(A3)
        DBF     D0,.SAVE
        MOVE.L  A6,A3
        MOVE.B  -(A5),D7
        BSR.S   .NORMAL_BYTES
        MOVE.L  A3,A5


        BSR     .GET_1_BIT
        BCC.S   .NO_PICTURE
        MOVE.W  #$0F9F,D7
        BSR     .GET_1_BIT
        BCC.S   .ICE_00
        MOVEQ   #15,D0
        BSR     .GET_D0_BITS
        MOVE.W  D1,D7
.ICE_00:        MOVEQ   #3,D6
.ICE_01:        MOVE.W  -(A3),D4
        MOVEQ   #3,D5
.ICE_02:        ADD.W   D4,D4
        ADDX.W  D0,D0
        ADD.W   D4,D4
        ADDX.W  D1,D1
        ADD.W   D4,D4
        ADDX.W  D2,D2
        ADD.W   D4,D4
        ADDX.W  D3,D3
        DBRA    D5,.ICE_02
        DBRA    D6,.ICE_01
        MOVEM.W D0-D3,(A3)
        DBRA    D7,.ICE_00
.NO_PICTURE
        MOVEM.L (SP),D0-A3

.MOVE   MOVE.B  (A4)+,(A0)+
        SUBQ.L  #1,D0
        BNE.S   .MOVE
        MOVEQ   #119,D0
.REST   MOVE.B  -(A3),-(A5)
        DBF     D0,.REST
.NOT_PACKED:
        MOVEM.L (SP)+,D0-A6
        UNLK    A3
        RTS

.GETINFO: MOVEQ #3,D1
.GETBYTES: LSL.L        #8,D0
        MOVE.B  (A0)+,D0
        DBF     D1,.GETBYTES
        RTS

.NORMAL_BYTES:  
        BSR.S   .GET_1_BIT
        BCC.S   .TEST_IF_END
        MOVEQ.L #0,D1
        BSR.S   .GET_1_BIT
        BCC.S   .COPY_DIREKT
        LEA.L   .DIREKT_TAB+20(PC),A1
        MOVEQ.L #4,D3
.NEXTGB:        MOVE.L  -(A1),D0
        BSR.S   .GET_D0_BITS
        SWAP.W  D0
        CMP.W   D0,D1
        DBNE    D3,.NEXTGB
.NO_MORE: ADD.L 20(A1),D1
.COPY_DIREKT:   
        MOVE.B  -(A5),-(A6)
        DBF     D1,.COPY_DIREKT
.TEST_IF_END:   
        CMPA.L  A4,A6
        BGT.S   .STRINGS
        RTS     

.GET_1_BIT:
        ADD.B   D7,D7
        BNE.S   .BITFOUND
        MOVE.B  -(A5),D7
        ADDX.B  D7,D7
.BITFOUND:
        RTS     

.GET_D0_BITS:   
        MOVEQ.L #0,D1
.HOLE_BIT_LOOP: 
        ADD.B   D7,D7
        BNE.S   .ON_D0
        MOVE.B  -(A5),D7
        ADDX.B  D7,D7
.ON_D0: ADDX.W  D1,D1
        DBF     D0,.HOLE_BIT_LOOP
        RTS     


.STRINGS: LEA.L .LENGTH_TAB(PC),A1
        MOVEQ.L #3,D2
.GET_LENGTH_BIT:        
        BSR.S   .GET_1_BIT
        DBCC    D2,.GET_LENGTH_BIT
.NO_LENGTH_BIT: 
        MOVEQ.L #0,D4
        MOVEQ.L #0,D1
        MOVE.B  1(A1,D2.W),D0
        EXT.W   D0
        BMI.S   .NO_ÅBER
.GET_ÅBER:
        BSR.S   .GET_D0_BITS
.NO_ÅBER:       MOVE.B  6(A1,D2.W),D4
        ADD.W   D1,D4
        BEQ.S   .GET_OFFSET_2


        LEA.L   .MORE_OFFSET(PC),A1
        MOVEQ.L #1,D2
.GETOFFS: BSR.S .GET_1_BIT
        DBCC    D2,.GETOFFS
        MOVEQ.L #0,D1
        MOVE.B  1(A1,D2.W),D0
        EXT.W   D0
        BSR.S   .GET_D0_BITS
        ADD.W   D2,D2
        ADD.W   6(A1,D2.W),D1
        BPL.S   .DEPACK_BYTES
        SUB.W   D4,D1
        BRA.S   .DEPACK_BYTES


.GET_OFFSET_2:  
        MOVEQ.L #0,D1
        MOVEQ.L #5,D0
        MOVEQ.L #-1,D2
        BSR.S   .GET_1_BIT
        BCC.S   .LESS_40
        MOVEQ.L #8,D0
        MOVEQ.L #$3F,D2
.LESS_40: BSR.S .GET_D0_BITS
        ADD.W   D2,D1

.DEPACK_BYTES:
        LEA.L   2(A6,D4.W),A1
        ADDA.W  D1,A1
        MOVE.B  -(A1),-(A6)
.DEP_B: MOVE.B  -(A1),-(A6)
        DBF     D4,.DEP_B
        BRA     .NORMAL_BYTES


.DIREKT_TAB:
        DC.L $7FFF000E,$00FF0007,$00070002,$00030001,$00030001
        DC.L     270-1, 15-1,    8-1,    5-1,    2-1

.LENGTH_TAB:
        DC.B 9,1,0,-1,-1
        DC.B 8,4,2,1,0

.MORE_OFFSET:
        DC.B      11,   4,   7,  0      ; BITS LESEN
        DC.W    $11F,  -1, $1F  ; STANDARD OFFSET

ENDE_ICE_DECRUNCH_2:
;************************************************** END OF UNPACKING ROUTINE


* C'EST L'ESPACE POUR LA PILE
        DS.B    512
DEMO:
* LA DEMO EST ECRITE EN PC RELATIF POUR
* FACILITER SON INTEGRATION.
        INCBIN  A:\RESET\RESET.BIN
        DS.B    512
FIN: