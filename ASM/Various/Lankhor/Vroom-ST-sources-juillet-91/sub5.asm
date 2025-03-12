         TTL      SUB5 - Front Car and Cardots V15 - 26 JUL 91

*DM20JUL : DSPGAZ
*DM26JUL : DSPCUP

         INCLUDE  'EQU.ASM'

         XDEF     INIOVR,HAUT
         XDEF     INICAR,DSPCAR,DSPTIR,DSPRET
         XDEF     DSPNOR,DSPFIR,DSPREG,DSPGER,DSPGAZ,DSPVOY
         XDEF     DSPOLR,DSPORR,DSPCUP                          DM26JUL
         XDEF     LIBARC,LIBRAC,LIBQAL,LIBTRA,LIBDEM
         XDEF     BDOT,WDOT,RDOT
         XDEF     TTNUM,THNUM,HUNUM,TENUM,TIMNUM
         XDEF     OVPCAA,OVMCAA,OVRCAR       
         XDEF     NTIR,BTIR,TIRLIG,ENGLIG
         XDEF     PVOL,PANIM
         
         XREF     ACTSCR,SCRADR,CURSCR


* INICAR - Initialize Car, Retro, Tires
* 

HAUT:   DC.W    20
        DC.W    20
PANIM:  DC.W    0 
PVOL:   DC.W    0

ADVOIT: DC.L    0,0,0,0,0,0,0
ADRETG: DC.L    0
ADRETD: DC.L    0
ADPBAS: DC.L    0,0,0,0,0,0,0,0,0
ADPANA: DC.L    0,0,0,0,0,0,0,0,0
        DC.L    0,0,0,0,0,0,0,0,0
        DC.L    0,0,0,0,0,0,0,0,0
        DC.L    0,0,0,0,0,0,0,0,0
ADPCRA: DC.L    0,0,0,0,0,0,0
        DC.L    0,0,0,0,0,0,0
ADPING: DC.L    0
ADPIND: DC.L    0
OFVOIT: DC.W    4320,4368,4416,8800,8848,8896,13280
        DC.W    2064,4144     ;OFFSET RETRO
        DC.W    0,24,48,72,96,120,3200,3224,3248   ;OFF PNEU BASE
        DC.W    6400,10560,14720,18880  ;OFF PNEU ANIM
        DC.W    6424,10584,14744,18904
        DC.W    6448,10608,14768,18928
        DC.W    6472,8552,10632,12712
        DC.W    6496,8576,10656,12736
        DC.W    6520,8600,10680,12760
        DC.W    8480,12640,16800,20960
        DC.W    8504,12664,16824,20984
        DC.W    8528,12688,16848,21008
        DC.W    23040,27200           ;OFF PNEU CREV
        DC.W    23064,27224
        DC.W    23088,27248
        DC.W    23112,27272
        DC.W    23136,27296
        DC.W    23160,27320
        DC.W    25120,29280
        DC.W    14816,14792    ;PNEU INCLIN G ET D

INICAR   LEA.L    TINIV(PC),A3  Init Car
         MOVE.L   #BCKEQU,A0
         LEA.L    OFVOIT(PC),A2
         LEA.L    ADVOIT(PC),A5
         MOVE.L   #ITCTEQU,A4     
         MOVE.W   #6,D0
BINIV:   MOVE.L   A4,(A5)+
         MOVE.L   A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A3/A5/D0,-(SP)
         BSR      CHVOI
         MOVEM.L  (SP)+,A0/A2/A3/A5/D0
         DBF      D0,BINIV

         MOVE.L   A4,(A5)+      Init Retro G & D
         MOVE.L   A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A3/A5/D0,-(SP)
         BSR      INIRET1
         MOVEM.L  (SP)+,A0/A2/A3/A5/D0
         MOVE.L   A4,(A5)+
         MOVE.L   A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A3/A5/D0,-(SP)
         BSR      INIRET1
         MOVEM.L  (SP)+,A0/A2/A3/A5/D0

         MOVE.L   #BCKEQU+ITCRLEN,A0   Init Pneu
         MOVE.W   #9-1,D0
BINIPB:  MOVE.L   A4,(A5)+
         MOVE.L   A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A5/D0,-(SP)
         MOVE.W   #12-1,D0
         BSR      INIPN1
         MOVEM.L  (SP)+,A0/A2/A5/D0
         DBF      D0,BINIPB
         MOVE.W   #36-1,D0
BINIPA:  MOVE.L   A4,(A5)+
         MOVE.L   A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A5/D0,-(SP)
         MOVE.W   #13-1,D0
         BSR      INIPN1
         MOVEM.L  (SP)+,A0/A2/A5/D0
         DBF      D0,BINIPA
         MOVE.W   #14-1,D0
BINIPC:  MOVE.L   A4,(A5)+
         MOVE.L   A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A5/D0,-(SP)
         MOVE.W   #13-1,D0
         BSR      INIPCR
         MOVEM.L  (SP)+,A0/A2/A5/D0
         DBF      D0,BINIPC
         MOVE.W   #2-1,D0
BINIPI:  MOVE.L   A4,(A5)+
         MOVE.L   A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A5/D0,-(SP)
         MOVE.W   #20-1,D0
         BSR      INIPCR
         MOVEM.L  (SP)+,A0/A2/A5/D0
         DBF      D0,BINIPI
         RTS

CHVOI:   ;A4 ADR DE CHARG  A1 ADR ECRAN
         LEA.L    AFICAR(PC),A0
         MOVEQ    #28-1,D0
         MOVEQ    #0,D1
INIVOI2: MOVE     #2,D4
         MOVE.L   A1,A2
INIVOI3: LEA.L    2(A4),A5
         CLR.W    D7
         MOVE.L   (A2)+,D5
         MOVE.L   (A2)+,D6
         MOVE.L   D6,D2
         SWAP     D2
         OR.L     D6,D2
         MOVE.L   D5,D3
         SWAP     D3
         OR.L     D5,D3
         OR.L     D3,D2
         BEQ.S    INIVOI4
         MOVEQ    #1,D7
         NOT.L    D2
         BEQ.S    INIVO4B
         MOVEQ    #2,D7
         MOVE.L   D2,(A5)+
INIVO4B: MOVE.L   D5,(A5)+
         MOVE.L   D6,(A5)+
INIVOI4: MOVE.L   (A2)+,D5
         MOVE.L   (A2)+,D6
         MOVE.L   D6,D2
         SWAP     D2
         OR.L     D6,D2
         MOVE.L   D5,D3
         SWAP     D3
         OR.L     D5,D3
         OR.L     D3,D2
         BEQ.S    INIVOI5
         OR.W     #$4,D7
         NOT.L    D2
         BEQ.S    INIVO5B
         AND.W    #$3,D7
         OR.W     #$8,D7
         MOVE.L   D2,(A5)+
INIVO5B: MOVE.L   D5,(A5)+
         MOVE.L   D6,(A5)+
INIVOI5: LSL.W    #2,D7
         MOVE.L   0(A3,D7.W),D2
         ADD.L    D1,D2
         MOVEQ    #0,D1
         MOVE.L   D2,D3
         SUB.L    A0,D3
         MOVE.L   D2,A0
         MOVE.W   D3,(A4)
         MOVE.L   A5,A4
         DBF      D4,INIVOI3
         MOVE.L   #-2,D1
         LEA.L    -160(A1),A1
         DBF      D0,INIVOI2
         MOVE.L   #F_F,D2
         SUB.L    A0,D2
         MOVE.W   D2,(A4)+
         RTS

INIPN1: MOVEM.W (A1)+,D4-D7
        OR.W    D4,D5
        OR.W    D6,D5
        OR.W    D7,D5
        NOT.W   D5
        MOVE.W  D5,(A4)+
        MOVE.W  D4,(A4)+
        MOVE.W  D7,(A4)+
        MOVE.W  (A1)+,(A4)+
        ADDQ.W  #4,A1
        MOVE.W  (A1)+,(A4)+
        MOVEM.W (A1)+,D4-D7
        OR.W    D4,D5
        OR.W    D6,D5
        OR.W    D7,D5
        NOT.W   D5
        MOVE.W  D5,(A4)+
        MOVE.W  D4,(A4)+
        MOVE.W  D7,(A4)+
        LEA.L   160-24(A1),A1
        DBF     D0,INIPN1
        RTS
INIPCR: MOVE.W  #2,D1
IPCR:   MOVEM.W (A1)+,D4-D7
        OR.W    D4,D5
        OR.W    D6,D5
        OR.W    D7,D5
        NOT.W   D5
        MOVE.W  D5,(A4)+
        MOVE.W  D4,(A4)+
        MOVE.W  D7,(A4)+
        DBF     D1,IPCR
        LEA.L   160-24(A1),A1
        DBF     D0,INIPCR
        RTS

INIRET1: LEA.L    AFICAR(PC),A0
         MOVEQ    #13-1,D0
         MOVEQ    #0,D1
INIRET2: MOVE.L   A1,A2
         LEA.L    2(A4),A5
         CLR.W    D7
         MOVE.L   (A2)+,D5
         MOVE.L   (A2)+,D6
         MOVE.L   D6,D2
         SWAP     D2
         OR.L     D6,D2
         MOVE.L   D5,D3
         SWAP     D3
         OR.L     D5,D3
         OR.L     D3,D2
         BEQ.S    INIRET4
         MOVEQ    #1,D7
         NOT.L    D2
         BEQ.S    INIRE4B
         MOVEQ    #2,D7
         MOVE.L   D2,(A5)+
INIRE4B: MOVE.L   D5,(A5)+
         MOVE.L   D6,(A5)+
INIRET4: MOVE.L   (A2)+,D5
         MOVE.L   (A2)+,D6
         MOVE.L   D6,D2
         SWAP     D2
         OR.L     D6,D2
         MOVE.L   D5,D3
         SWAP     D3
         OR.L     D5,D3
         OR.L     D3,D2
         BEQ.S    INIRET5
         OR.W     #$4,D7
         NOT.L    D2
         BEQ.S    INIRE5B
         AND.W    #$3,D7
         OR.W     #$8,D7
         MOVE.L   D2,(A5)+
INIRE5B: MOVE.L   D5,(A5)+
         MOVE.L   D6,(A5)+
INIRET5: LSL.W    #2,D7
         MOVE.L   0(A3,D7.W),D2
         ADD.L    D1,D2
         MOVEQ    #0,D1
         MOVE.L   D2,D3
         SUB.L    A0,D3
         MOVE.L   D2,A0
         MOVE.W   D3,(A4)
         MOVE.L   A5,A4
         MOVE.L   #-2,D1
         LEA.L    -160(A1),A1
         DBF      D0,INIRET2
         MOVE.L   #F_F,D2
         SUB.L    A0,D2
         MOVE.W   D2,(A4)+
         RTS
TINIV:  DC.L    V_V
        DC.L    P_V
        DC.L    T_V
        DC.L    0  
        DC.L    V_P
        DC.L    P_P
        DC.L    T_P
        DC.L    0
        DC.L    V_T
        DC.L    P_T
        DC.L    T_T

CHAXE:  MOVE.W  D6,D7
        NOT.W   D7
        AND.W   D7,160(A0)
        AND.W   D7,320(A0)
        OR.W    D6,(A0)+
        OR.W    D6,160(A0)
        OR.W    D6,320(A0)
        AND.W   D7,(A0)+
        OR.W    D6,160(A0)
        OR.W    D6,320(A0)
        AND.W   D7,(A0)+
        OR.W    D6,160(A0)
        AND.W   D7,320(A0)
        OR.W    D6,(A0)+
        CLR.W   D6
        RTS

* Display TIRE
*

DSPTIR  MOVE.W  BTIR(PC),D1
        BNE     PNINCL
        MOVE.W  NTIR(PC),D1
        BLT     PNCAC1
        LEA.L   ADPANA(PC),A2   ;PARTIE HAUTE GCH ANIM
        MOVE.W  PVOL(PC),D1
        ADDQ.W  #2,D1
        LSL.W   #4,D1
        MOVE.W  PANIM(PC),D2
        AND.W   #$FF,D2
        LSR.W   #6,D2
        ADD.W   D2,D2
        ADD.W   D2,D2
        ADD.W   D2,D1
        MOVE.L  0(A2,D1.W),A2
        MOVEQ   #12,D1
        MOVE.W  HAUT(PC),D2
        CMP.W   #13,D2
        BGE.S   HTENT
        MOVE.W  D2,D1
        SUBQ.W  #1,D1
HTENT:  SUBQ.W  #1,D2
        MULU    #160,D2
        MOVE.L  CURSCR(PC),A4
        ADD.W   #32000-160+56-24,A4
        SUB.W   D2,A4
        MOVEQ   #-1,D7
        BSR     AFIPN1
        LEA.L   ADPBAS(PC),A2   ;PARTIE BASSE GCH
        MOVE.W  PVOL(PC),D1
        ADDQ.W  #2,D1
        LSL.W   #2,D1
        MOVE.L  0(A2,D1.W),A2
        MOVE.W  HAUT(PC),D1
        SUBQ.W  #1,D1
        SUB.W   #13,D1
        BLT.S   PNCAC1
        BSR     AFIPN1
PNCAC1: MOVE.W  NTIR(PC),D1
        BGT     PNCAC2
        LEA.L   ADPANA(PC),A2   ;PARTIE HAUTE DRT ANIM
        LEA.L   AFIPN1(PC),A0
        MOVE.W  PVOL(PC),D1
        LSL.W   #4,D1
        MOVE.W  PANIM(PC),D2
        AND.W   #$FF,D2
        LSR.W   #6,D2
        MOVE.W  TIRLIG(PC),D0
        BGE.S   PCREV
        LEA.L   AFIPCR(PC),A0
        LEA.L   ADPCRA(PC),A2
        LSR.W   #1,D2
        LSR.W   #1,D1
PCREV:  ADD.W   D2,D2
        ADD.W   D2,D2
        ADD.W   D2,D1
        MOVE.L  0(A2,D1.W),A2
        MOVEQ   #12,D1
        MOVE.W  HAUT+2(PC),D2
        CMP.W   #13,D2
        BGE.S   HTENT1
        MOVE.W  D2,D1
        SUBQ.W  #1,D1
HTENT1: SUBQ.W  #1,D2
        MULU    #160,D2
        MOVE.L  CURSCR(PC),A4
        ADD.W   #32000-160+56+48,A4
        SUB.W   D2,A4
        MOVEQ   #-1,D7
        JSR     (A0)
        LEA.L   ADPBAS(PC),A2   ;PARTIE BASSE GCH
        MOVE.W  PVOL(PC),D1
        LSL.W   #2,D1
        MOVE.L  0(A2,D1.W),A2
        MOVE.W  HAUT+2(PC),D1
        SUBQ.W  #1,D1
        SUB.W   #13,D1
        BLT.S   PNCAC2
        BSR     AFIPN1
PNCAC2:
;AFFI AXES
        LEA.L   TCACH(PC),A3
        MOVE.W  NTIR(PC),D0
        BGT     AXGCH
        MOVE.L  CURSCR(PC),A0
        ADD.L   #32000-1280+56+40,A0
        MOVE.W  #$100,D4
        MOVEQ   #0,D1
        MOVE.W  HAUT+2(PC),D0
        SUB.W   #17,D0
        BLT.S   AXDI
        BGT.S   AXDS
        MOVE.W  #23,A2
        CLR.W   D2
        CLR.W   D0
        BRA.S   REPAXD
AXDI:   MOVE.W  #160,A1
        NEG.W   D0
        BRA.S   SAXD
AXDS:   MOVE.W  #-160,A1
SAXD:   MOVE.W  #24*16,D1
        ADDQ.W  #1,D0
        DIVU    D0,D1
        SUBQ.W  #1,D0
        MOVE.W  D1,D2
        LSR.W   #4,D1
        SUBQ.W  #1,D1
        AND.W   #$F,D2
        MOVE.W  D1,A2
REPAXD: MOVE.W  D2,D3
        CLR.W   D6
        MOVE.W  PVOL(PC),D1
        ADD.W   D1,D1
        MOVE.W  0(A3,D1.W),D1
        ADD.W   #23,D1
BAXD:   MOVE.W  A2,D5
        ADD.W   D2,D3
        BCLR    #4,D3
        BEQ.S   SBAXD
        ADDQ.W  #1,D5
SBAXD:  OR.W    D4,D6
        ROR.W   #1,D4
        BCC.S   S1BAXD
        BSR     CHAXE
        DBF     D1,CAX1
        BRA.S   AXGCH
CAX1:   DBF     D5,SBAXD
        BRA.S   S2BAXD
S1BAXD: DBF     D1,CAX2
        BSR     CHAXE
        BRA.S   AXGCH
CAX2:   DBF     D5,SBAXD
        BSR     CHAXE
        LEA.L   -8(A0),A0
S2BAXD: ADD.W   A1,A0
        DBF     D0,BAXD

AXGCH:  MOVE.W  NTIR(PC),D1
        BGE.S   AXGCHS
        RTS
AXGCHS: MOVE.L  CURSCR(PC),A0
        ADD.L   #32000-1280+56,A0
        MOVE.W  #$80,D4
        MOVEQ   #0,D1
        MOVE.W  HAUT(PC),D0
        SUB.W   #17,D0
        BLT.S   AXGI
        BGT.S   AXGS
        MOVE.W  #23,A2
        CLR.W   D2
        CLR.W   D0
        BRA.S   REPAXG
AXGI:   MOVE.W  #160,A1
        NEG.W   D0
        BRA.S   SAXG
AXGS:   MOVE.W  #-160,A1
SAXG:   MOVE.W  #24*16,D1
        ADDQ.W  #1,D0
        DIVU    D0,D1
        SUBQ.W  #1,D0
        MOVE.W  D1,D2
        LSR.W   #4,D1
        SUBQ.W  #1,D1
        AND.W   #$F,D2
        MOVE.W  D1,A2
REPAXG: MOVE.W  D2,D3
        CLR.W   D6
        MOVE.W  PVOL(PC),D1
        ADD.W   D1,D1
        MOVE.W  14(A3,D1.W),D1
        ADD.W   #23,D1
BAXG:   MOVE.W  A2,D5
        ADD.W   D2,D3
        BCLR    #4,D3
        BEQ.S   SBAXG
        ADDQ.W  #1,D5
SBAXG:  OR.W    D4,D6
        ROL.W   #1,D4
        BCC.S   S1BAXG
        BSR     CHAXE
        LEA.L   -16(A0),A0
        DBF     D1,CAX3
        RTS
CAX3:   DBF     D5,SBAXG
        BRA.S   S2BAXG
S1BAXG: DBF     D1,CAX4
        BSR     CHAXE
        RTS
CAX4:   DBF     D5,SBAXG
        BSR     CHAXE
        LEA.L   -8(A0),A0
S2BAXG: ADD.W   A1,A0
        DBF     D0,BAXG
        RTS
TCACH:  DC.W    0,0,-1,-2,-4,-6,-8  ;CACHE PNEU DRT
        DC.W    -8,-6,-4,-2,-1,0,0  ;CACHE PNEU GCH
PNINCL: MOVE.W  NTIR(PC),D1
        BLT.S   INCGC
        MOVE.L  ADPING(PC),A2   ;GCH INCLINEE
        MOVE.W  HAUT(PC),D1
        SUB.W   #20,D1
        ASR.W   #1,D1
        BLE.S   ZUZU
        CLR.W   D1
ZUZU:   ADD.W   #20,D1
        MOVE.W  D1,D2
        SUBQ.W  #1,D1
        SUBQ.W  #1,D2
        MULU    #160,D2
        MOVE.L  CURSCR(PC),A4
        ADD.W   #32000-160+56-24,A4
        SUB.W   D2,A4
        MOVEQ   #-1,D7
        BSR     AFIPCR
INCGC:  MOVE.W  NTIR(PC),D1
        BGT.S   INCDR
        MOVE.L  ADPIND(PC),A2   ;DRT INCLINEE
        MOVE.W  HAUT+2(PC),D1
        SUB.W   #20,D1
        ASR.W   #1,D1
        BLE.S   ZUZU1
        CLR.W   D1
ZUZU1:  ADD.W   #20,D1
        MOVE.W  D1,D2
        SUBQ.W  #1,D1
        SUBQ.W  #1,D2
        MULU    #160,D2
        MOVE.L  CURSCR(PC),A4
        ADD.W   #32000-160+56+48,A4
        SUB.W   D2,A4
        MOVEQ   #-1,D7
        BSR     AFIPCR
INCDR:  RTS
AFIPN1: MOVE.W  (A2)+,D0
        MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+
        NOT.W   D0
        OR.W    D0,(A4)+
        OR.W    D0,(A4)+
        NOT.W   D0
        MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+
        MOVE.W  (A2)+,(A4)+
        MOVE.L  D7,(A4)+
        MOVE.W  (A2)+,(A4)+
        MOVE.W  (A2)+,D0
        MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+
        NOT.W   D0
        OR.W    D0,(A4)+
        OR.W    D0,(A4)+
        NOT.W   D0
        MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+
        LEA.L   160-24(A4),A4
        DBF     D1,AFIPN1
        RTS
AFIPCR: MOVE.W  (A2)+,D0
        MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+
        NOT.W   D0
        OR.W    D0,(A4)+
        OR.W    D0,(A4)+
        NOT.W   D0
        MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+

        MOVE.W  (A2)+,D0
        BNE.S   PNMSK
        MOVE.W  (A2)+,(A4)+
        MOVE.L  D7,(A4)+
        MOVE.W  (A2)+,(A4)+
        BRA.S   SPNCR
PNMSK:  MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+
        NOT.W   D0
        OR.W    D0,(A4)+
        OR.W    D0,(A4)+
        NOT.W   D0
        MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+

SPNCR:  MOVE.W  (A2)+,D0
        MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+
        NOT.W   D0
        OR.W    D0,(A4)+
        OR.W    D0,(A4)+
        NOT.W   D0
        MOVE.W  (A4),D5
        AND.W   D0,D5
        OR.W    (A2)+,D5
        MOVE.W  D5,(A4)+
        LEA.L   160-24(A4),A4
        DBF     D1,AFIPCR
        RTS

BTIR:   DC.W    0
NTIR:   DC.W    0

* DSPCAR - Display Car and Retro

DSPCAR
AFICAR: LEA.L   ADVOIT(PC),A2
        MOVE.W  PVOL(PC),D0
        ADD.W   D0,D0
        ADD.W   D0,D0
        MOVE.L  0(A2,D0.W),A2
        LEA.L   AFICAR(PC),A0
        MOVE.L  CURSCR(PC),A4
        MOVE.W  #208,D0
        ADD.W   #32000-160+56,A4
        ADD.W   (A2)+,A0
        JMP     (A0)
DSPRET
AFIRET: MOVE.L  ADRETG(PC),A2
        LEA.L   AFICAR(PC),A0
        MOVE.L  CURSCR(PC),A4
        MOVE.W  #176,D0
        ADD.W   #32000-160+56-16,A4
        ADD.W   (A2)+,A0
        JSR     (A0)
        MOVE.L  ADRETD(PC),A2
        LEA.L   AFICAR(PC),A0
        MOVE.L  CURSCR(PC),A4
        ADD.W   #32000-160+56+48,A4
        ADD.W   (A2)+,A0
        JMP     (A0)

        SUB.W   D0,A4
V_V:    LEA.L   16(A4),A4
        ADD.W   (A2)+,A0
        JMP     (A0)

        SUB.W   D0,A4
V_P:    ADDQ.W  #8,A4
        MOVE.L  (A2)+,(A4)+
        MOVE.L  (A2)+,(A4)+
        ADD.W   (A2)+,A0
        JMP     (A0)

        SUB.W   D0,A4
V_T:    ADDQ.W  #8,A4
        MOVE.L  (A2)+,D2
        MOVE.L  (A4),D3
        AND.L   D2,D3
        OR.L    (A2)+,D3
        MOVE.L  D3,(A4)+
        MOVE.L  (A4),D3
        AND.L   D2,D3
        OR.L    (A2)+,D3
        MOVE.L  D3,(A4)+
        ADD.W   (A2)+,A0
        JMP     (A0)

        SUB.W   D0,A4
P_V:    MOVE.L  (A2)+,(A4)+
        MOVE.L  (A2)+,(A4)+
        ADDQ.W  #8,A4
        ADD.W   (A2)+,A0
        JMP     (A0)

        SUB.W   D0,A4
P_P:    MOVE.L  (A2)+,(A4)+
        MOVE.L  (A2)+,(A4)+
        MOVE.L  (A2)+,(A4)+
        MOVE.L  (A2)+,(A4)+
        ADD.W   (A2)+,A0
        JMP     (A0)

        SUB.W   D0,A4
P_T:    MOVE.L  (A2)+,(A4)+
        MOVE.L  (A2)+,(A4)+
        MOVE.L  (A2)+,D2
        MOVE.L  (A4),D3
        AND.L   D2,D3
        OR.L    (A2)+,D3
        MOVE.L  D3,(A4)+
        MOVE.L  (A4),D3
        AND.L   D2,D3
        OR.L    (A2)+,D3
        MOVE.L  D3,(A4)+
        ADD.W   (A2)+,A0
        JMP     (A0)

        SUB.W   D0,A4
T_V:    MOVE.L  (A2)+,D2
        MOVE.L  (A4),D3
        AND.L   D2,D3
        OR.L    (A2)+,D3
        MOVE.L  D3,(A4)+
        MOVE.L  (A4),D3
        AND.L   D2,D3
        OR.L    (A2)+,D3
        MOVE.L  D3,(A4)+
        ADDQ.W  #8,A4
        ADD.W   (A2)+,A0
        JMP     (A0)

        SUB.W   D0,A4
T_P:    MOVE.L  (A2)+,D2
        MOVE.L  (A4),D3
        AND.L   D2,D3
        OR.L    (A2)+,D3
        MOVE.L  D3,(A4)+
        MOVE.L  (A4),D3
        AND.L   D2,D3
        OR.L    (A2)+,D3
        MOVE.L  D3,(A4)+
        MOVE.L  (A2)+,(A4)+
        MOVE.L  (A2)+,(A4)+
        ADD.W   (A2)+,A0
        JMP     (A0)

        SUB.W   D0,A4
T_T:    MOVEM.L (A4)+,D4-D7
        MOVE.L  (A2)+,D2
        AND.L   D2,D4
        OR.L    (A2)+,D4
        AND.L   D2,D5
        OR.L    (A2)+,D5
        MOVE.L  (A2)+,D2
        AND.L   D2,D6
        OR.L    (A2)+,D6
        AND.L   D2,D7
        OR.L    (A2)+,D7
        MOVEM.L D4-D7,-16(A4)
        ADD.W   (A2)+,A0
        JMP     (A0)

F_F:    RTS

* INIOVR - Init Overpassed Car in Retro XOR 
*        No Input
*
* DSPOLR/DSPORR - Display Overpassed Car in Retro
*
*        Input :  D0 Pointer in Table (Varies from 0 to 20)
*                 D1 Contains Car # (0,2,4,6)

* Car Over Retro

HRTEQU   EQU      8
LRTEQU   EQU      1
RLTEQU   EQU   196*160+40        Off : Start Addr of Bottom of Left Retro   
RRTEQU   EQU   196*160+112       Off : Start Addr of Bottom of Righ Retro

CR0      DC.L     C0R   BLUE
CR1      DC.L     C1R   GREEN
CR2      DC.L     C2R   RED

C0R      DC.L     C0R1  BLUE
         DC.L     C0R2
         DC.L     C0R3
         DC.L     C0R4
         DC.L     C0R5
         DC.L     C0R6
C1R      DC.L     C1R1  GREEN
         DC.L     C1R2
         DC.L     C1R3
         DC.L     C1R4
         DC.L     C1R5
         DC.L     C1R6
C2R      DC.L     C2R1  RED
         DC.L     C2R2
         DC.L     C2R3
         DC.L     C2R4
         DC.L     C2R5
         DC.L     C2R6

RETCAR
C0R1     DC.L     ITSTEQU+23*160+48      RED Over Retro 
         DC.L     0
C0R2     DC.L     ITSTEQU+23*160+56
         DC.L     0
C0R3     DC.L     ITSTEQU+23*160+64
         DC.L     0
C0R4     DC.L     ITSTEQU+23*160+72
         DC.L     0
C0R5     DC.L     ITSTEQU+23*160+80
         DC.L     0
C0R6     DC.L     ITSTEQU+23*160+88
         DC.L     0
C1R1     DC.L     ITSTEQU+23*160+96      GREEN Over Retro 
         DC.L     0
C1R2     DC.L     ITSTEQU+23*160+104
         DC.L     0
C1R3     DC.L     ITSTEQU+23*160+112
         DC.L     0
C1R4     DC.L     ITSTEQU+23*160+120
         DC.L     0
C1R5     DC.L     ITSTEQU+23*160+128
         DC.L     0
C1R6     DC.L     ITSTEQU+23*160+136
         DC.L     0
C2R1     DC.L     ITSTEQU+31*160+96      BLUE Over Retro 
         DC.L     0
C2R2     DC.L     ITSTEQU+31*160+104
         DC.L     0
C2R3     DC.L     ITSTEQU+31*160+112
         DC.L     0
C2R4     DC.L     ITSTEQU+31*160+120
         DC.L     0
C2R5     DC.L     ITSTEQU+31*160+128
         DC.L     0
C2R6     DC.L     ITSTEQU+31*160+136
         DC.L     0

INIOVR   LEA.L    RETCAR,A3
         MOVE     #17,D7         18 Cars Over Retros
         MOVE.L   #WRKOVR,A4
INIOVR1  MOVE.L   (A3),A1        Get Bottom Left Address in Mem
         MOVE.L   A4,4(A3)       Working Zone Pointer  
         MOVEQ    #HRTEQU-1,D0   Retro Heigth-1 in Lines
         MOVEQ    #LRTEQU-1,D1   Retro Width in Double Words (*16 pixels)
INIOVR2  MOVE     D1,D4          Save Width
         MOVE.L   A1,A2          Save Left Address in Line
INIOVR3  MOVE.L   (A2)+,D5       Get Low Double Word of 16 Pixels
         MOVE.L   (A2)+,D6       High
         MOVE.L   D6,D2          Compute Mask in High Word
         SWAP     D6             .
         OR.L     D6,D2          .
         MOVE.L   D5,D3          **
         SWAP     D5             **
         OR.L     D5,D3          **
         SWAP     D5             **
         OR.L     D3,D2          .
         BNE.S    INIOVR4        If EQ, Not All Black
         MOVEQ    #0,D2          All black D5=-1
INIOVR4  NOT.L    D2             Not Any Black D5=0, Some Black D5 <>0
         MOVE.L   D2,(A4)+       Put in Working Area
         DBF      D4,INIOVR3     Advance 4*W in Line
         LEA.L    -160(A1),A1    (SUBA.L   #160,A1) Previous Line
         DBF      D0,INIOVR2
         ADDQ.L   #8,A3          Next Retro
         DBF      D7,INIOVR1
         RTS

WRKOVR   DS.L     HRTEQU*6*3     Working Area

DSPOLR   MOVE.L   #RLTEQU,A3     Offset Address on Screen of Left Retro 
         BRA.S    DSPOVR
DSPORR   MOVE.L   #RRTEQU,A3     Offset Address on Screen of Right Retro
DSPOVR   EXT      D1             0 ---> 0
         BEQ.S    DSPOVR1        2 ---> 0
         SUBQ     #2,D1          4 ---> 2
DSPOVR1  LSL      #1,D1          6 ---> 4
         LEA.L    CR0,A1         Point To Car
         MOVE.L   0(A1,D1),A0    .
         EXT.L    D0             .
         MOVE.L   0(A0,D0),A0
         MOVE.L   (A0),A1
         MOVE.L   4(A0),A5
         ADDA.L   CURSCR,A3      Address on Screen
         MOVEQ    #HRTEQU-1,D0   Retro Heigth-1 in Lines
         MOVEQ    #LRTEQU-1,D1   Retro Width in Double Words (*16 pixels)
DSPOVR3  MOVE     D1,D3
         MOVE.L   A1,A2
         MOVE.L   A3,A4
DSPOVR4  MOVE.L   (A2)+,D5       Get Car Low Double Word
         MOVE.L   (A2)+,D2       Get Car High Double Word
         MOVE.L   (A5)+,D7
         BEQ.S    DSPOVR6        If EQ, Not Any Black
         CMPI.L   #-1,D7         Test All Black
         BEQ.S    DSPOVR5        If EQ, All Black
         MOVE.L   (A4),D4        Get Screen Low Double Word
         MOVE.L   4(A4),D6       Merge Screen with Car
         AND.L    D7,D4          .
         AND.L    D7,D6          .
         OR.L     D5,D4          .
         OR.L     D2,D6          .
         MOVE.L   D4,(A4)+       .
         MOVE.L   D6,(A4)+       .
         BRA.S    DSPOVR7
DSPOVR5  ADDQ.L   #8,A4          All Black
         BRA.S    DSPOVR7
DSPOVR6  MOVE.L   D5,(A4)+       Not Any Balck
         MOVE.L   D2,(A4)+
DSPOVR7  DBF      D3,DSPOVR4     Advance 4*W in Line
         LEA.L    -160(A1),A1    (SUBA.L   #160,A1)
         LEA.L    -160(A3),A3    (SUBA.L   #160,A3)
         DBF      D0,DSPOVR3     Previous Line
         RTS

* DSPREG - Display Regime
*        Input :  A5 Points to Active Screen
*                 D0 Contains RPMIN (0 to 13008)

REGEQU   EQU      198*160+72        Regime
REGI     DC.L     ITSTEQU+35*160+104
         DC.L     ITSTEQU+35*160+120
         DC.L     ITSTEQU+35*160+136
         DC.L     ITSTEQU+37*160+104
         DC.L     ITSTEQU+37*160+120
         DC.L     ITSTEQU+37*160+136
         DC.L     ITSTEQU+39*160+104
         DC.L     ITSTEQU+33*160+0
         DC.L     ITSTEQU+33*160+16
         DC.L     ITSTEQU+33*160+32
         DC.L     ITSTEQU+33*160+48
         DC.L     ITSTEQU+33*160+64
         DC.L     ITSTEQU+33*160+80
         DC.L     ITSTEQU+33*160+96
         DC.L     ITSTEQU+33*160+112
         DC.L     ITSTEQU+33*160+128
         DC.L     ITSTEQU+33*160+144
         DC.L     ITSTEQU+51*160+0
         DC.L     ITSTEQU+51*160+16
         DC.L     ITSTEQU+51*160+32
         DC.L     ITSTEQU+51*160+48
         DC.L     ITSTEQU+51*160+64
         DC.L     ITSTEQU+51*160+80
         DC.L     ITSTEQU+51*160+96
         DC.L     ITSTEQU+51*160+112
         DC.L     ITSTEQU+51*160+128
         DC.L     ITSTEQU+51*160+144

DSPREG   MOVEQ    #9,D1
         LSR      D1,D0  
*         ADDQ     #1,D0   
         CMPI     #26,D0
         BLE.S    DSPREG0
         MOVE     #26,D0     
DSPREG0  LSL      #2,D0
DSPREG1  LEA.L    REGI,A0
         MOVE.L   0(A0,D0),A0    Point to Item
         MOVE.L   CURSCR,A5      Address on Screen
         LEA.L    REGEQU(A5),A5  .
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         MOVE.L   8(A0),8(A5)
         MOVE.L   12(A0),12(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         MOVE.L   8(A0),8(A5)
         MOVE.L   12(A0),12(A5)
         RTS

* DSPVOY - Display Voyants
*

VTIEQU   EQU      198*160+64          Voyant Pneu
VTIR     DC.L     ITSTEQU+24*160+144   R
         DC.L     ITSTEQU+18*160+144   G
         DC.L     ITSTEQU+21*160+144   O

VENEQU   EQU      198*160+88          Voyant Engine
VENG     DC.L     ITSTEQU+30*160+152   R
         DC.L     ITSTEQU+27*160+144   G
         DC.L     ITSTEQU+30*160+144   O

DSPVOY 
DSPVTI   MOVE     TIRLIG(PC),D0
         ADDQ     #1,D0
         LSL      #2,D0
         LEA.L    VTIR,A0
         MOVE.L   0(A0,D0),A0    Point to Item
         MOVE.L   CURSCR,A5      Address on Screen
         LEA.L    VTIEQU(A5),A5  .
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)      DM14JUL
         MOVE.L   4(A0),4(A5)    DM14JUL
DSPVEN   MOVE     ENGLIG(PC),D1
         ADDQ     #1,D1
         LSL      #2,D1
         LEA.L    VENG,A0
         MOVE.L   0(A0,D1),A0    Point to Item
         MOVE.L   CURSCR,A5      Address on Screen
         LEA.L    VENEQU(A5),A5  .
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)      DM14JUL
         MOVE.L   4(A0),4(A5)    DM14JUL
         RTS

TIRLIG   DC.W     0     0= Green, 1=Orange, -1=Red
ENGLIG   DC.W     0     0= Green, 1=Orange, -1=Red


* DSPNOR - Display Normal Retro (Left and Right) - Revised V10
*        Input :  D0 Contains XB 

* Normal Retro Content

RETL     DC.L     ITSTEQU+7*160+0 Retro Left
         DC.L     ITSTEQU+7*160+8
         DC.L     ITSTEQU+7*160+16
         DC.L     ITSTEQU+7*160+24
         DC.L     ITSTEQU+7*160+32
         DC.L     ITSTEQU+7*160+40
         DC.L     ITSTEQU+7*160+48
         DC.L     ITSTEQU+7*160+56
         DC.L     ITSTEQU+7*160+64
         DC.L     ITSTEQU+7*160+72
         DC.L     ITSTEQU+7*160+80
         DC.L     ITSTEQU+7*160+88
         DC.L     ITSTEQU+7*160+96
         DC.L     ITSTEQU+7*160+104
         DC.L     ITSTEQU+7*160+112
         DC.L     ITSTEQU+7*160+120
         DC.L     ITSTEQU+7*160+128
         DC.L     ITSTEQU+7*160+136
         DC.L     ITSTEQU+7*160+144
         DC.L     ITSTEQU+7*160+152
         DC.L     ITSTEQU+23*160+0

RETR     DC.L     ITSTEQU+15*160+0   Retro Right
         DC.L     ITSTEQU+15*160+8
         DC.L     ITSTEQU+15*160+16
         DC.L     ITSTEQU+15*160+24
         DC.L     ITSTEQU+15*160+32
         DC.L     ITSTEQU+15*160+40
         DC.L     ITSTEQU+15*160+48
         DC.L     ITSTEQU+15*160+56
         DC.L     ITSTEQU+15*160+64
         DC.L     ITSTEQU+15*160+72
         DC.L     ITSTEQU+15*160+80
         DC.L     ITSTEQU+15*160+88
         DC.L     ITSTEQU+15*160+96
         DC.L     ITSTEQU+15*160+104
         DC.L     ITSTEQU+15*160+112
         DC.L     ITSTEQU+15*160+120
         DC.L     ITSTEQU+15*160+128
         DC.L     ITSTEQU+15*160+136
         DC.L     ITSTEQU+15*160+144
         DC.L     ITSTEQU+15*160+152
         DC.L     ITSTEQU+23*160+8

DSPNOR   ADD      #430,D0        
         BPL.S    DSPNOR0        
         MOVEQ    #0,D0          .
         BRA.S    DSPNOR1        .
DSPNOR0  CMPI     #860,D0        .
         BLE.S    DSPNOR1        .
         MOVE     #860,D0        .
DSPNOR1  MOVE.W   D0,D6
         LSR.W    #1,D6
         ADD.W    D6,D0
         LSR      #6,D0
         LSL      #2,D0          Compute Entry in TBL
         LEA.L    RETL,A0
         MOVE.L   0(A0,D0),A0    Point to Item
         MOVE.L   CURSCR,A5      Address on Screen
         LEA.L    RLTEQU(A5),A5  .
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    RETR,A0
         MOVE.L   0(A0,D0),A0    Point to Item
         MOVE.L   CURSCR,A5      Address on Screen
         LEA.L    RRTEQU(A5),A5  .
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         RTS

* DSPFIR - Display Fire in Retro
*
*        Input :  No 

FLR      DC.L     FLR1     Fire Retro Left
         DC.L     FLR2
FRR      DC.L     FRR1     Fire Retro Right
         DC.L     FRR2

FIRE
FLR1     DC.L     ITSTEQU+23*160+16 Fire Retro Left
FLR2     DC.L     ITSTEQU+23*160+24
FRR1     DC.L     ITSTEQU+23*160+32 Fire Retro Right
FRR2     DC.L     ITSTEQU+23*160+40

DSPFIR
DSPFLR   LEA.L    FLR,A0
         LEA.L    DSPFLR2,A1
         EORI     #4,2(A1)
         NOP
DSPFLR2  MOVE.L   4(A0),A0
         MOVE.L   (A0),A0
         MOVE.L   CURSCR,A5      Address on Screen
         LEA.L    RLTEQU(A5),A5  .
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
DSPFRR   LEA.L    FRR,A0
         LEA.L    DSPFRR2,A1
         EORI     #4,2(A1)
         NOP
DSPFRR2  MOVE.L   4(A0),A0
         MOVE.L   (A0),A0 
         MOVE.L   CURSCR,A5      Address on Screen
         LEA.L    RRTEQU(A5),A5  .
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         MOVE.L   (A0),(A5)
         MOVE.L   4(A0),4(A5)
         LEA.L    -160(A0),A0    (SUBA.L   #160,A0)
         LEA.L    -160(A5),A5    (SUBA.L   #160,A5)
         RTS

* LIBARC-LIBRAC-LIBQAL-LIBTRA - Libelles in Banner ( in Invisible Screen)
*        LIBARC = Arcade
*        LIBRAC = Race/Demo
*        LIBQAL = Qualif
*        LIBTRA = Train
*        D6 Contains CARPAS1 (LIBRAC)
   
HAREQU   EQU      8              Heigth
SCOEQU   EQU      37*160+72      Addr of Bottom of Score
SCO      EQU      ITSTEQU+41*160+0
STAEQU   EQU      37*160+104     Adr of Bottom of Stage
STA      EQU      ITSTEQU+41*160+16
LAPEQU   EQU      37*160+128     Adr of Bottom of Lap
LAP      EQU      ITSTEQU+49*160+0
 
LIBARC   
         MOVE.L   #SCO,A1        Score
         MOVE.L   #SCOEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #1,D1          2
         BSR      DSPBOX
         MOVE.L   #STA,A1        Stage
         MOVE.L   #STAEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #2,D1          3
         BSR      DSPBOX
         MOVE.L   #LAP,A1        Lap
         MOVE.L   #LAPEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #1,D1          2
         BSR      DSPBOX
         RTS

QALEQU   EQU      39*160+88      Addr of Bottom of Qalification Session
QAL      EQU      ITSTEQU+49*160+88            
LAQEQU   EQU      54*160+72      Addr of Bottom of Qal Lap Time
LAQ      EQU      ITSTEQU+41*160+64
RAQEQU   EQU      54*160+112     Addr of Bottom of Qal Race
RAQ      EQU      ITSTEQU+49*160+64
POSEQU   EQU      54*160+136     Addr of Bottom of Position
POS      EQU      ITSTEQU+49*160+144 

LIBQAL   MOVE.L   #QAL,A1        Qualification Session
         MOVE.L   #QALEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #6,D1          7
         BSR      DSPBOX
         MOVE.L   #LAQ,A1        Lap Time
         MOVE.L   #LAQEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #1,D1          2
         BSR      DSPBOX
         MOVE.L   #RAQ,A1        Race
         MOVE.L   #RAQEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #1,D1          2
         BSR      DSPBOX
         MOVE.L   #POS,A1        Position
         MOVE.L   #POSEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #0,D1          1
         BSR      DSPBOX
         RTS

TOTEQU   EQU      37*160+72      Addr of Bottom of Tot Time
TOT      EQU      ITSTEQU+41*160+40
BSTEQU   EQU      45*160+72      Addr of Bottom of Bst Lap
BST      EQU      ITSTEQU+49*160+40
LAREQU   EQU      37*160+128     Addr of Bottom of Lap
LAR      EQU      ITSTEQU+41*160+64
RACEQU   EQU      45*160+128     Addr of Bottom of GP
RAC      EQU      ITSTEQU+49*160+64

DO1EQU   EQU      59*160+72
DO2EQU   EQU      52*160+136
DOT      EQU      ITSTEQU+25*160+152     

CUPEQU   EQU      60*160+144            
CUP      EQU      ITSTEQU+49*160+80

LIBRAC   MOVE.L   #SCR1EQU+61*160+72,A1  Erase Qualification Session
         MOVE.L   #QALEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #6,D1          7
         BSR      DSPBOX
         MOVE.L   #SCR1EQU+61*160+72,A1  Erase Lap Time/Race/Pos
         MOVE.L   #LAQEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #8,D1          9
         BSR      DSPBOX
LIBDEM   MOVE.L   #TOT,A1        Tot Time
         MOVE.L   #TOTEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #2,D1          3
         BSR      DSPBOX
         MOVE.L   #BST,A1        Best Lap
         MOVE.L   #BSTEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #2,D1          3
         BSR      DSPBOX
         MOVE.L   #LAR,A1        Lap
         MOVE.L   #LAREQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #1,D1          2
         BSR      DSPBOX
         MOVE.L   #RAC,A1        G.P.
         MOVE.L   #RACEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #1,D1          2
         BSR      DSPBOX
         MOVE.L   #DOT,A1        4 Dots
         MOVE.L   #DO1EQU,A3
         ADDA.L   CURSCR,A3
         MOVE.L   (A1),(A3)      ....
         MOVE.L   4(A1),4(A3)
         MOVE.L   #DO2EQU,A3
         ADDA.L   CURSCR,A3
         MOVE.L   (A1),(A3)      ....
         MOVE.L   4(A1),4(A3)
         MOVE.L   #CUP,A1        Cup 
         MOVE.L   #CUPEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #0,D1          1
         BSR      DSPBOX
         LSL      #2,D6          CAR1PAS*4
         ASL      #2,D7          CAR2PAS*4 or -1
         MOVEQ    #0,D5
LIBRAC3  CMPI     #64,D5         16 Green/Red Cars
         BEQ.S    LIBRAC6
         LEA.L    CARPOSR,A5
         MOVE.L   0(A5,D5),A3
         ADDA.L   CURSCR,A3
         MOVE.L   CARGREN,A4     Car Green 
         CMP      D6,D5
         BNE.S    LIBRAC4
         MOVE.L   CARRED1,A4     Car Red1
LIBRAC4  TST      D7
         BLT.S    LIBRAC5
         CMP      D7,D5
         BNE.S    LIBRAC5
         MOVE.L   CARRED2,A4     Car Red2   
LIBRAC5  ADDQ     #4,D5
         BSR      DSPCR          Display Small Car
         BRA.S    LIBRAC3
LIBRAC6  RTS

PRAEQU   EQU      38*160+88
PRA      EQU      ITSTEQU+41*160+80
SESEQU   EQU      38*160+120
SES      EQU      ITSTEQU+49*160+120
LTIEQU   EQU      50*160+72      Addr of Bottom of Lap Time
LTI      EQU      ITSTEQU+49*160+16
BSIEQU   EQU      58*160+72      Addr of Bottom of Bst Lap
BSI      EQU      ITSTEQU+49*160+40
LATEQU   EQU      50*160+128     Addr of Bottom of Lap
LAT      EQU      ITSTEQU+41*160+64
RATEQU   EQU      58*160+128     Addr of Bottom of GP
RAT      EQU      ITSTEQU+49*160+64

LIBTRA   MOVE.L   #PRA,A1        Practice
         MOVE.L   #PRAEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #2,D1          3
         BSR      DSPBOX 
         MOVE.L   #SES,A1        Session
         MOVE.L   #SESEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #2,D1          3
         BSR      DSPBOX 
         MOVE.L   #LTI,A1        Lap Time
         MOVE.L   #LTIEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #2,D1          3
         BSR      DSPBOX
         MOVE.L   #BSI,A1        Best Lap
         MOVE.L   #BSIEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #2,D1          3
         BSR      DSPBOX
         MOVE.L   #LAT,A1        Lap
         MOVE.L   #LATEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #1,D1          2
         BSR      DSPBOX
         MOVE.L   #RAT,A1        G.P.
         MOVE.L   #RATEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #1,D1          2
         BSR      DSPBOX
         RTS

DSPBOX   ADDA.L   CURSCR,A3
DSPBOX0  MOVE     D1,D2
         MOVE.L   A1,A2
         MOVE.L   A3,A4
DSPBOX1  MOVE.L   (A2)+,(A4)+    Display Line
         MOVE.L   (A2)+,(A4)+
         DBF      D2,DSPBOX1
         LEA.L    -160(A1),A1    (SUBA.L   #160,A1)
         LEA.L    -160(A3),A3    (SUBA.L   #160,A3)
         DBF      D0,DSPBOX0     Previous Line         
         RTS

* DSPGER - Display Gear
*        Input :  D0 Contains Gear

HGREQU   EQU      6               Gear Heigth
GEREQU   EQU      193*160+72      Addr of Bottom of Gear
GER      DC.L     ITSTEQU+29*160+0
         DC.L     ITSTEQU+29*160+8
         DC.L     ITSTEQU+29*160+16
         DC.L     ITSTEQU+29*160+24
         DC.L     ITSTEQU+29*160+32
         DC.L     ITSTEQU+29*160+40
         DC.L     ITSTEQU+29*160+48

DSPGER
         LSL      #2,D0
         LEA.L    GER,A0
         MOVE.L   0(A0,D0),A1
         MOVEQ    #HGREQU-1,D0   Gear Heigth-1 in Lines
         MOVE.L   #GEREQU,A3     Offset Address on Screen
         ADDA.L   CURSCR,A3      Address on Screen
DSPGER0  MOVE.L   (A1),(A3)
         MOVE.L   4(A1),4(A3)
         LEA.L    -160(A1),A1    (SUBA.L   #160,A1)
         LEA.L    -160(A3),A3    (SUBA.L   #160,A3)
         DBF      D0,DSPGER0     Previous Line
         RTS

* BDOT - Display Black Dot on Circuit
*        Input :  A1 Point to CnDRW
*                 D4 Position on Circuit

BDOT
         LEA.L    SCRADR,A0      Screen Address
         MOVE.L   0(A0,D5),A0    .
         LSL      #2,D4
         MOVEQ    #0,D2
         MOVEQ    #0,D0
         MOVE     0(A1,D4),D0    Get CnDRW Entry
         BLT.S    BDOTF
         ADDA.L   D0,A0          Point to Screen line
         MOVE     2(A1,D4),D0    Get Pixel position in Line
         MOVE     D0,D2
         LSR      #4,D2          Get 4*W Pointer
         MOVE     D2,D3          .
         LSL      #3,D2          .
         ADDA.L   D2,A0          Point to Word on Screen
         LSL      #4,D3
         SUB      D3,D0          Get Word Mask (0 to 15)
         SUB      #15,D0
         NEG      D0
         MOVE     #1,D3          .
         LSL      D0,D3
         NOT      D3
         MOVE     D3,D0
         SWAP     D0
         MOVE     D3,D0
         AND.L    D0,(A0)        Black Point
         AND.L    D0,4(A0)       .
BDOTF    RTS

* WDOT - Display White Dot on Circuit
*        Input :  A1 Point to CnDRW
*                 D4 Position on Circuit

WDOT
         LEA.L    SCRADR,A0      Screen Address
         MOVE.L   0(A0,D5),A0    .
         LSL      #2,D4
         MOVEQ    #0,D2
         MOVEQ    #0,D0
         MOVE     0(A1,D4),D0    Get CnDRW Entry
         BLT.S    WDOTF
         ADDA.L   D0,A0          Point to Screen line
         MOVE     2(A1,D4),D0    Get Pixel position in Line
         MOVE     D0,D2
         LSR      #4,D2          Get 4*W Pointer
         MOVE     D2,D3          .
         LSL      #3,D2          .
         ADDA.L   D2,A0          Point to Word on Screen
         LSL      #4,D3
         SUB      D3,D0          Get Word Mask (0 to 15)
         SUB      #15,D0
         NEG      D0
         MOVE     #1,D3          .
         LSL      D0,D3          .
         OR.W     D3,2(A0)       White Point (Banner Pal)
         OR.W     D3,4(A0)
         NOT      D3
         AND.W    D3,(A0)
         AND.W    D3,6(A0)
WDOTF    RTS

* RDOT - Display Red Dot on Circuit (Opponent Car)
*        Input :  A1 Point to CnDRW
*                 D4 Position on Circuit

RDOT
         LEA.L    SCRADR,A0      Screen Address
         MOVE.L   0(A0,D5),A0    .
         LSL      #2,D4
         MOVEQ    #0,D2
         MOVEQ    #0,D0
         MOVE     0(A1,D4),D0    Get CnDRW Entry
         BLT.S    RDOTF
         ADDA.L   D0,A0          Point to Screen line
         MOVE     2(A1,D4),D0    Get Pixel position in Line
         MOVE     D0,D2
         LSR      #4,D2          Get 4*W Pointer
         MOVE     D2,D3          .
         LSL      #3,D2          .
         ADDA.L   D2,A0          Point to Word on Screen
         LSL      #4,D3
         SUB      D3,D0          Get Word Mask (0 to 15)
         SUB      #15,D0
         NEG      D0
         MOVE     #1,D3          .
         LSL      D0,D3          .
         OR.W     D3,2(A0)       Red Point (Banner Pal)
         OR.W     D3,4(A0)
         OR.W     D3,6(A0)       
         NOT      D3
         AND.W    D3,(A0)
*         OR.W     D3,(A0)        
RDOTF    RTS

* TTNUM,THNUM,HUNUM,TENUM Digit Convert
*        Input    D0 = Number to Convert
*                 A0 = Number in Digits (TeTh,Th,Hu,Te,Un)
*
TTNUM    MOVE     #10,D1
         DIVU     #10000,D0
         BEQ.S    CPNUM0
         MOVE     D0,(A0)+
         CLR      D1
         BRA.S    CPNUM1
CPNUM0   MOVE     D1,(A0)+
CPNUM1   CLR      D0
         SWAP     D0
         BRA.S    CPNUM2
THNUM    MOVE     #10,D1
CPNUM2   DIVU     #1000,D0
         BEQ.S    CPNUM3
         MOVE     D0,(A0)+
         CLR      D1
         BRA.S    CPNUM4
CPNUM3   MOVE     D1,(A0)+
CPNUM4   CLR      D0
         SWAP     D0
         BRA.S    CPNUM5
HUNUM    MOVE     #10,D1
CPNUM5   DIVU     #100,D0
         BEQ.S    CPNUM6
         MOVE     D0,(A0)+
         CLR      D1
         BRA.S    CPNUM7
CPNUM6   MOVE     D1,(A0)+
CPNUM7   CLR      D0
         SWAP     D0
         BRA.S    CPNUM8
TENUM    MOVE     #10,D1
CPNUM8   DIVU     #10,D0
         BEQ.S    CPNUM9
         MOVE     D0,(A0)+
         CLR      D1
         BRA.S    CPNUM10
CPNUM9   MOVE     D1,(A0)+
CPNUM10  CLR      D0
         SWAP     D0
         MOVE     D0,(A0)+
         RTS

* TIMNUM - Time Digit Convert
*        Input    D0 = Number to Convert
*                 A0 = Points Number in Digits (MMSSCC)
*
TIMNUM   DIVU     #60000,D0
         BEQ.S    TIMNUM0
         MOVE     D0,(A0)+
         BRA.S    TIMNUM1
TIMNUM0  MOVE     #10,(A0)+
TIMNUM1  CLR      D0
         SWAP     D0
         DIVU     #6000,D0
         MOVE     D0,(A0)+
         CLR      D0
         SWAP     D0
         DIVU     #1000,D0
         MOVE     D0,(A0)+
         CLR      D0
         SWAP     D0
         DIVU     #100,D0
         MOVE     D0,(A0)+
         CLR      D0
         SWAP     D0
         DIVU     #10,D0
         MOVE     D0,(A0)+
         SWAP     D0
         MOVE     D0,(A0)+ 
         RTS

* OVPCAA - Plus  : Overpass Arcade
* OVMCAA - Minus : Being Overpassed Arcade
*        Input :  A2 points to CAAPAS or CARPAS

OVMCAA   MOVEQ    #0,D2       Minus
         MOVE     (A2),D2
         BEQ.S    OVMCAAF
         SUBQ     #1,D2
         MOVE     D2,(A2)
         MOVE.L   CARERA,A4
         LEA.L    CARPOSA,A3
         BSR      OVCAR
OVMCAAF  RTS

OVPCAA   MOVEQ    #0,D2       Plus
         MOVE     (A2),D2
         CMPI     #27,D2
         BEQ.S    OVPCAAF
         ADDQ     #1,(A2)
         MOVE.L   CARGREN,A4  Car Green
         LEA.L    CARPOSA,A3
         BSR      OVCAR
OVPCAAF  RTS

* OVRCAR - Overpass/Overpassesd Racing & Demo
*        Input :  D0 contains OVER
*                 A0 points to CAR1PAS (.B)
*                 D1 contains OVER2    
*                 A1 Points to CAR2PAS (.B)

OVRCAR   TST      D0          F1 Change? 
         BEQ.S    OVRCAR2     If EQ, No
         MOVE.B   (A0),D5     Get New F1
         MOVE.B   D5,D4       
         SUB.B    D0,D4       Get Old F1
         TST      D1          F2 Change? 
         BEQ.S    OVRCAR1     If EQ, F1_Yes & F2_No
         MOVE.B   (A1),D7     Get New F2  
         MOVE.B   D7,D6         
         SUB.B    D1,D6       Get Old F2 
         BRA.S    OVRCAR4
OVRCAR1  MOVE.B   D4,D2       HERE : F1_Yes & F2_no
         MOVE.L   CARGREN,A4  F1_Old Green
         LEA.L    CARPOSR,A3
         BSR      OVCAR
OVRCAR1A MOVE.B   D5,D2       
         MOVE.L   CARRED1,A4  F1_New Red1
         LEA.L    CARPOSR,A3
         BSR      OVCAR         
         RTS
OVRCAR2  TST      D1
         BEQ      OVRCARF     If EQ, F1_No & F2_no
         MOVE.B   (A1),D7     HERE : F1_No & F2_Yes 
         MOVE.B   D7,D6       Get New F2  
         SUB.B    D1,D6       Get Old F2
OVRCAR3  MOVE.B   D6,D2       
         MOVE.L   CARGREN,A4  F2_Old Green
         LEA.L    CARPOSR,A3
         BSR      OVCAR
OVRCAR3A MOVE.B   D7,D2
         MOVE.L   CARRED2,A4  F2_New Red2
         LEA.L    CARPOSR,A3
         BSR      OVCAR 
         RTS
OVRCAR4  CMP.B    D4,D7       HERE : F1_Yes & F2_Yes
         BEQ.S    OVRCAR6     If EQ, Old F1 = New F2
         CMP.B    D5,D6       
         BEQ.S    OVRCAR8     If EQ, New F1 = Old F2 and Old F1 =/= New F2
         BSR      OVRCAR1     Normal F1 Change 
         BSR      OVRCAR3     Normal F2 Change
         RTS
OVRCAR6  CMP.B    D5,D6       
         BNE.S    OVRCAR7
         BSR      OVRCAR1A    Swap F1 and F2
         BSR      OVRCAR3A
         RTS
OVRCAR7  BSR      OVRCAR3     Old F1 = New F2 and New F1 =/= Old F2
         BSR      OVRCAR1A
         RTS
OVRCAR8  BSR      OVRCAR1     Old F2 = New F1 and New F2 =/= Old F1
         BSR      OVRCAR3A
OVRCARF  RTS  
         
OVCAR    MOVE.B   D2,D3
         EXT      D3
         LSL      #2,D3
         MOVE.L   0(A3,D3),A3
         ADDA.L   #SCR1EQU,A3       SCR1 Screen
         BSR      DSPCR            
         ADDA.L   #32000,A3         SCR2 Screen
         BSR      DSPCR
         RTS

DSPCR    MOVE.L   (A4),(A3)         First Line (Car) 
         MOVE.L   4(A4),4(A3)
         MOVE.L   -160(A4),-160(A3) Second Line
         MOVE.L   -156(A4),-156(A3)
         MOVE.L   -320(A4),-320(A3) Third Line
         MOVE.L   -316(A4),-316(A3)
         MOVE.L   -480(A4),-480(A3) Fourth Line
         MOVE.L   -476(A4),-476(A3)
         MOVE.L   -640(A4),-640(A3) Fifth Line
         MOVE.L   -636(A4),-636(A3)
         MOVE.L   -800(A4),-800(A3) Fifth Line
         MOVE.L   -796(A4),-796(A3)
         RTS

CARERA   DC.L     ITSTEQU+29*160+88  Erase Car
CARYELL  DC.L     ITSTEQU+29*160+56  Car Blue
CARGREN  DC.L     ITSTEQU+29*160+64  Car Green
CARRED1  DC.L     ITSTEQU+29*160+72  Car Red1
CARRED2  DC.L     ITSTEQU+29*160+80  Car Red2

CARPOSA  DC.L     44*160+72 Car Positions Arcade
         DC.L     44*160+80 
         DC.L     44*160+88
         DC.L     44*160+96
         DC.L     44*160+104
         DC.L     44*160+112
         DC.L     44*160+120
         DC.L     44*160+128
         DC.L     44*160+136
         DC.L     52*160+72
         DC.L     52*160+80
         DC.L     52*160+88
         DC.L     52*160+96
         DC.L     52*160+104
         DC.L     52*160+112
         DC.L     52*160+120
         DC.L     52*160+128
         DC.L     52*160+136
         DC.L     60*160+72
         DC.L     60*160+80
         DC.L     60*160+88
         DC.L     60*160+96
         DC.L     60*160+104
         DC.L     60*160+112
         DC.L     60*160+120
         DC.L     60*160+128
         DC.L     60*160+136

CARPOSR  DC.L     53*160+72 Car Positions Race
         DC.L     53*160+80
         DC.L     53*160+88
         DC.L     53*160+96
         DC.L     53*160+104
         DC.L     53*160+112
         DC.L     53*160+120
         DC.L     53*160+128
         DC.L     60*160+80
         DC.L     60*160+88
         DC.L     60*160+96
         DC.L     60*160+104
         DC.L     60*160+112
         DC.L     60*160+120
         DC.L     60*160+128
         DC.L     60*160+136

* DSPCUP - Display Clignotante Cup

DSPCUP   MOVE.L   #CUP,A1        Assume Cup
         MOVE     CUPCNT,D0
         BPL.S    DSPCUP0
         MOVE.L   #ERA,A1
DSPCUP0  ADDI     #1,D0
         CMPI     #10,D0
         BLT.S    DSPCUP1
         MOVE     #-10,D0
DSPCUP1  MOVE     D0,CUPCNT
         MOVE.L   CURSCR,A3
         ADDA.L   #CUPEQU,A3 
         MOVEQ    #HAREQU-1,D0   Heigth-1
         MOVEQ    #0,D1          1
         BSR      DSPBOX0
         RTS
CUPCNT   DC.W     0
ERA      EQU      SCR1EQU+26*160+144

* DSPGAZ - Display Gazoline
*        Input :  D0 Contains Gaz level (25599 to 0)
*                 D1 = -1 Erase After Qualif

DSPGAZ   LSR      #7,D0          Divide By 1024 (7+3)
         LSR      #3,D0          .
         LSL      #2,D0          Point to Screen Position
         LEA.L    GAZPOS,A5      From 24 to 0
         MOVE.L   0(A5,D0),A5    .
         MOVE.L   A5,A4          On  SCR1 Screen
         ADDA.L   #32000,A4      And SCR2 Screen
         TST      D1
         BEQ.S    DSPGAZ1
         MOVE.L   GAZGG,A2
         BRA.S    DSPGAZ4
DSPGAZ1  MOVE.L   GAZRWR,A2      Assume Red/Black/Red
         CMPI     #28,D0
         BNE.S    DSPGAZ2
DSPGAZA  MOVE.L   GAZGWR,A2      Say Green/Black/red
         BRA.S    DSPGAZ4
DSPGAZ2  CMPI     #24,D0
         BEQ.S    DSPGAZA      
         BLT.S    DSPGAZ4
         MOVE.L   GAZGWG,A2      Say Green/Black/Green
DSPGAZ4 
         MOVE.L   (A2),(A5)      First Line
         MOVE.L   4(A2),4(A5)
         MOVE.L   (A2),(A4)
         MOVE.L   4(A2),4(A4)
         MOVE.L   -160(A2),-160(A5) Second Line
         MOVE.L   -156(A2),-156(A5)
         MOVE.L   -160(A2),-160(A4)
         MOVE.L   -156(A2),-156(A4)
         TST       D1
         BLT.S     DSPGAZF
         MOVE.L   -320(A2),-320(A5) Third Line
         MOVE.L   -316(A2),-316(A5)
         MOVE.L   -320(A2),-320(A4)
         MOVE.L   -316(A2),-316(A4)
DSPGAZF  RTS

GAZGWG   DC.L     ITSTEQU+18*160+152  Gaz Green/White/Green Address
GAZGWR   DC.L     ITSTEQU+21*160+152  Gaz Green/White/red Address
GAZRWR   DC.L     ITSTEQU+24*160+152  Gaz Red/White/Red Address
GAZGG    DC.L     ITSTEQU+19*160+152  Gaz Green  Fro After Qualif Erase
GAZPOS   DC.L     SCR1EQU+56*160+152  Gaz Pos on Screen (Bot)
         DC.L     SCR1EQU+55*160+152
         DC.L     SCR1EQU+54*160+152
         DC.L     SCR1EQU+53*160+152
         DC.L     SCR1EQU+52*160+152
         DC.L     SCR1EQU+51*160+152
         DC.L     SCR1EQU+50*160+152
         DC.L     SCR1EQU+49*160+152
         DC.L     SCR1EQU+48*160+152
         DC.L     SCR1EQU+47*160+152
         DC.L     SCR1EQU+46*160+152
         DC.L     SCR1EQU+45*160+152
         DC.L     SCR1EQU+44*160+152
         DC.L     SCR1EQU+43*160+152
         DC.L     SCR1EQU+42*160+152
         DC.L     SCR1EQU+41*160+152
         DC.L     SCR1EQU+40*160+152
         DC.L     SCR1EQU+39*160+152
         DC.L     SCR1EQU+38*160+152
         DC.L     SCR1EQU+37*160+152
         DC.L     SCR1EQU+36*160+152
         DC.L     SCR1EQU+35*160+152
         DC.L     SCR1EQU+34*160+152  
         DC.L     SCR1EQU+33*160+152
         DC.L     SCR1EQU+32*160+152 Top

         END

