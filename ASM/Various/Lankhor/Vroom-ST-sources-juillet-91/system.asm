         TTL - SYSTEM Routines (Transmit,Sound,HBL,Clavier) V11 - 1 JUN 91

         INCLUDE  'EQU.ASM'
*         INCLUDE  'TOS.ASM'   *CD29/07/91

*POUR SUB0
         XDEF     accid,adbon,adcri,adbrbl,ecvid,mot1,mot2
         XDEF     SENDIT,R1CIEV,tab_clav
         XDEF     FLGENV,COPPER1,OLDCOUNT,PBANN,PGAME,CH_RES
         XDEF     INTER2,INTER3,INTER4,INTER6
*
         XDEF     DISCON,SENDIR,CONMAS,CONSLA
         XDEF     PALSOMB,VR1VBL,VR2VBL,DUMMY,RTRES0
         XDEF     rapport,nouson,datvoit,pasfr
         XDEF     demson,coupson,rtsvoit
         XDEF     INIHBL,EXIHBL,INIMHBL
         XDEF     CNVASCI,CHRPAL
         XDEF     TIMVBL
         XDEF     BUFRECE,PNTRECE
         XREF     SYNC,MCOMM
         XREF     SP1D,XB,FROTT
         XREF     JOY,TOTTIM
         XREF     BANPAL,CRCPAL
         XREF     CARSRT,CRCLAP,Y1,F1SRT,OCCUR,PTTRBL

         XDEF     SETPALETTE,SETSCREEN,CH_SCR

BUG3C:          dc.w    0

VIT68K:  EQU    $C8

*****************************************************
*  GESTION DE LA COMMUNICATION - C. Droin  23-06-91 *
*****************************************************
* 2400  Bauds = 1472
* 19200 Bauds = 184
* CON/DISCON - Connect/Disconnect

DISCON:
         MOVE      #-1,SYNC
         CLR       FSLAMOD
         LEA       STRCONE+1(PC),A0     ;DECONNECTION SEND -1,-1
         MOVE.B    STRCONE(PC),D0
         BSR       SENDIR
DISCON3: TST       FLGENV
         BNE.S     DISCON3
         CMPI      #8,OLDCOM
         BNE.S     DISCON0
         MOVE.L    #150,D0
         BSR       WAITDCD
         LEA       STRCONB+1(PC),A0     ;DECONNECTION MODEM UNIQUEMENT
         MOVE.B    STRCONB(PC),D0
         BSR       SENDIR
         MOVE.L    #200,D0
         BSR       WAITDCD
         LEA       STRCONC+1(PC),A0
         MOVE.B    STRCONC(PC),D0
         BSR       SENDIR
DISCON2: TST       FLGENV
         BNE.S     DISCON2
DISCON0: CLR       OLDCOM
         RTS

* CONSLA - Tentative de connexion esclave

ECONSLA:    MOVE    OLDCOM(PC),D0
            CMP     MCOMM+2(PC),D0
            BEQ.S   ECONSLA1
            JSR     DISCON
            MOVE.L  #$FFFFFFFE,D0
            BRA     CONSLA1
ECONSLA1:   MOVEQ   #-1,D0
            BRA.S   CONSLA1

CONSLA:     MOVEM.L D1-D7/A0-A5,-(A7)
            TST     SYNC
            BGE.S   ECONSLA

            CMPI    #4,MCOMM+2
            BEQ.S   CSLALOC
            CMPI    #8,MCOMM+2
            BEQ.S   CSLAMOD
            CLR     OLDCOM
            TST     FSLAMOD
            BEQ.S   CONSLA01
            JSR     DISCON
CONSLA01:   MOVEQ   #0,D0
CONSLA1:    MOVEM.L (A7)+,D1-D7/A0-A5
            NOT.L   D0
            RTS
CSLALOC:    CMPI    #4,OLDCOM
            BEQ.S   CSLALOC1
            TST     FSLAMOD
            BEQ.S   CSLALOC01
            JSR     DISCON
CSLALOC01:  MOVE    #184,SERPER            ;19200 BAUDS
            MOVE    #4,OLDCOM
CSLALOC1:   BSR     FINDSTR
            TST     D0                     ;RECEIVE 'LOCAL MAS'
            BEQ.S   CSLALOC2
            MOVEQ   #0,D0
            BRA.S   CONSLA1
CSLALOC2:   LEA     STRCON2+1(PC),A0       ;SEND    'LOCAL  SLA'
            MOVE.B  STRCON2(PC),D0
            BSR     SENDIR
            MOVEQ   #-1,D0                 ;OK
            CLR     FSLAMOD
            BRA.S   CONSLA1

CSLAMOD:
            TST     FSLAMOD       ;BUGFREE  WAIT MESSAGE MASTER AND
            BNE.S   CSLALOC1      ;SEND MESSAGE SLAVE IF MODEM
            CMPI    #8,OLDCOM
            BEQ     CSLAMOD1
            TST     CMPCOM
            BGT.S   CSLAMOD8        ;ATTENT OK DE CONFIG
            BLT.S   CSLAMODA        ;ATTENT AVANT 'ATA'
            MOVE    #1472,SERPER           ;2400 BAUDS
            LEA     STRCONA+1(PC),A0       ;CONFIG MODEM
            MOVE.B  STRCONA(PC),D0
            BSR     SENDIR
            MOVE    #10,CMPCOM      ;WAIT 1 SECOND
            MOVE.L  TIMVBL(PC),TIMECOM
            ADDQ.L  #5,TIMECOM
            BRA     CSLAMOD7
CSLAMODA:   MOVE.L  TIMECOM(PC),D0
            CMP.L   TIMVBL(PC),D0
            BGE     CSLAMOD7
            MOVE.L  TIMVBL(PC),TIMECOM
            ADDQ.L  #5,TIMECOM
            ADDQ    #1,CMPCOM
            BNE     CSLAMOD7
            MOVE    #8,OLDCOM
            BRA     CSLAMOD6
CSLAMOD8:   MOVE.L  TIMECOM(PC),D0
            CMP.L   TIMVBL(PC),D0
            BGE     CSLAMOD7
            MOVE.L  TIMVBL(PC),TIMECOM
            ADDQ.L  #5,TIMECOM
            SUBQ    #1,CMPCOM
CSLAMODB:   BSR     FINDSTR
            CMPI    #6,D0                  ;IF 'OK'
            BNE     CSLAMOD7
            MOVE    #-10,CMPCOM            ;WAIT 1 SECOND
            MOVE.L  TIMVBL(PC),TIMECOM
            ADDQ.L  #5,TIMECOM
            BRA     CSLAMOD7
CSLAMOD1:   BSR     FINDSTR                ;ICI MODEM CONFIGURE
            CMPI    #2,D0
            BNE.S   CSLAMOD2
            MOVE    #1472*4,SERPER         ;CONNECT 300
            MOVE.L  #50,D0
            BSR     WAITDCD
            MOVE    #1,FSLAMOD             ;MOVEQ   #-1,D0
            MOVEQ   #0,D0
            BRA     CONSLA1
CSLAMOD2:   CMPI    #3,D0
            BNE.S   CSLAMOD3
            MOVE    #1472*2,SERPER         ;CONNECT 1200
            MOVE.L  #50,D0
            BSR     WAITDCD
            MOVE    #1,FSLAMOD             ;MOVEQ   #-1,D0
            MOVEQ   #0,D0
            BRA     CONSLA1
CSLAMOD3:   CMPI    #4,D0
            BNE.S   CSLAMOD4
            MOVE    #1472,SERPER           ;CONNECT 2400
            MOVE.L  #50,D0
            BSR     WAITDCD
            MOVE    #1,FSLAMOD             ;MOVEQ   #-1,D0
            MOVEQ   #0,D0
            BRA     CONSLA1
CSLAMOD4:   CMPI    #5,D0
            BEQ.S   CSLAMOD6               ;SI 'NO CARRIER'
            CMPI    #6,D0
            BNE.S   CSLAMOD7               ;OU 'OK'
CSLAMOD6:   MOVE.L  TIMVBL(PC),D0
            ADD.L   #60,D0
CSLAMODC:   CMP.L   TIMVBL(PC),D0
            BGT.S   CSLAMODC
            LEA     STRCON8+1(PC),A0       ;SEND 'ATD',$D
            MOVE.B  STRCON8(PC),D0
            BSR     SENDIR
CSLAMOD7:   MOVEQ   #0,D0
            BRA     CONSLA1
WAITDCD:
            ADD.L   TIMVBL(PC),D0
W0DCD:      CMP.L   TIMVBL(PC),D0
            BGT.S   W0DCD
            RTS

* CONMAS - Tentative de connexion du maitre

CONMAS: 
            MOVEM.L A0/A0,-(A7)
            CMPI    #4,MCOMM+2
            BEQ.S   CMASLOC             ;LOCAL SEND 'LOCAL MAS'
            TST     FSLAMOD
            BNE.S   CMASLOC             ;MODEM SEND 'LOCAL MAS'
            CMPI    #8,MCOMM+2
            BEQ.S   CMASMOD             ;MODEM TRY PHYSICAL CONNEXION
CONMAS1:    MOVEM.L (A7)+,A0/A0
            NOT.L   D0
            RTS
CMASACK:
            MOVE.L  TIMVBL(PC),D0        ;WAIT FOR NEW SPEED 
            ADD.L   #120,D0
CMASACK0:   CMP.L   TIMVBL(PC),D0
            BGE.S   CMASACK0
            MOVE    #1,FSLAMOD
CMASLOC:    LEA     STRCON1+1(PC),A0       ;SEND    'LOCAL MAS'
            MOVE.B  STRCON1(PC),D0
            BSR     SENDIR
            MOVE.L  TIMVBL(PC),D7
            ADD.L   #600,D7                ;TIMEOUT = 10 S
CMASLOC2:   CMP.L   TIMVBL(PC),D7
            BLT.S   CMASLOC1               ;ERREUR TIMOUT
            JSR     FINDSTR
            CMPI    #1,D0
            BNE.S   CMASLOC2
            CLR     FSLAMOD
            MOVEQ   #-1,D0                 ;CONNECTION OK
            BRA     CONMAS1
CMASLOC1:   MOVEQ   #0,D0
            BRA     CONMAS1
CMASMOD:    LEA     STRCOND+1(PC),A0       ;CLEAR 'ATA'
            MOVE.B  STRCOND(PC),D0
            BSR     SENDIR
            MOVE.L  #60,D0                 ;WAIT FOR NOTHING
            BSR     WAITDCD
            LEA     STRCON9+1(PC),A0       ;SEND    'ATD'
            MOVE.B  STRCON9(PC),D0
            BSR     SENDIR
            MOVE.L  TIMVBL(PC),D7
            ADD.L   #1200,D7             ;TIMEOUT = 10 S
CMASMOD2:   CMP.L   TIMVBL(PC),D7
            BLT.S   CMASMOD1            ;ERREUR TIMOUT
            JSR     FINDSTR
            CMPI    #2,D0
            BNE.S   CMASMOD3
            MOVE    #1472*4,SERPER  ;CONNECT 300
            BRA     CMASACK         ;BUG SEND MESSAGE MASTER
CMASMOD3:   CMPI    #3,D0
            BNE.S   CMASMOD4
            MOVE    #1472*2,SERPER  ;CONNECT 1200
            BRA     CMASACK         ;BUG SEND MESSAGE MASTER
CMASMOD4:   CMPI    #4,D0
            BNE.S   CMASMOD2
            MOVE    #1472,SERPER    ;CONNECT 2400
            BRA     CMASACK         ;BUG SEND MESSAGE MASTER
CMASMOD1:   MOVEQ   #0,D0
            BRA     CONMAS1 

* SENDIR - Direct Send 1 Character (During Initial Synchro)

SENDIR:     MOVEM.L  A0/A0,-(A7)
SENDIR4:    TST.W    FLGENV
            BNE.S    SENDIR4
            ANDI     #$FF,D0
            SUBQ     #1,D0
            BLT.S    SENDIR2
            MOVE     D0,PNTBUF
            MOVE.W   #1,FLGENV
            MOVE.B   (A0)+,D0
            MOVE.L   A0,TMPENV
            BSET     #8,D0
            MOVE     D0,SERDAT
SENDIR2:    MOVEM.L  (A7)+,A0/A0
            RTS

* SENDIT - SEND Interrupts

SENDIT:     MOVEM.L  A0/D0,-(A7)
            MOVE.W   INTENAR,D0
            BTST     #$E,D0
            BEQ.S    SENDIT0
            AND.W    INTREQR,D0
            BTST     #0,D0
            BEQ.S    SENDIT0
            MOVE.W   #$0001,INTREQ
            SUBQ.W   #1,PNTBUF
            BLT.S    SENDIT1
            MOVE.L   TMPENV(PC),A0
            MOVE     #$0100,D0
            MOVE.B   (A0)+,D0
            MOVE.L   A0,TMPENV
            MOVE     D0,SERDAT
SENDIT0:    MOVEM.L  (A7)+,A0/D0
            RTE
SENDIT1:    CLR.W    FLGENV
            MOVEM.L  (A7)+,A0/D0
            RTE

* R1CIEV - Reception sur buffer circulaire 64 octets
R1CIEV:
            MOVEM.L  A0/D0-D1,-(A7)
            MOVE.W   INTENAR,D0
            BTST     #$E,D0
            BEQ.S    R1CIEV4
            AND.W    INTREQR,D0
            BTST     #11,D0
            BEQ.S    R1CIEV4
            MOVE.B   SERDATR+1,D0
            MOVE.W   #$0800,INTREQ
            CMPI.W   #8,MCOMM+2         ;SI MODEM
            BNE.S    R1CIEV1
            TST      FSLAMOD            ;ET CONNEXION PHYSIQUE
            BNE.S    R1CIEV3
            TST      SYNC
            BLT.S    R1CIEV1
R1CIEV3:    BTST     #5,$BFD000
            BNE.S    R1CIEV2            ;PERTE DE PORTEUSE (DCD)
R1CIEV1:    MOVE     PNTRECE(PC),D1
            BCLR     #6,D1
            ADDQ     #1,D1
            MOVE     D1,PNTRECE
            LEA      BUFRECE-1(PC,D1.W),A0
            MOVE.B   D0,(A0)
R1CIEV4:    MOVEM.L  (A7)+,A0/D0-D1
            RTE
R1CIEV2:    MOVE     #-1,SYNC      ;PERTE DE DCD
            CLR      FSLAMOD       ; 
            MOVEM.L  (A7)+,A0/D0-D1
            RTE
BUFRECE:    DS.B     64
PNTRECE:    DC.W     0

FINDSTR:
            MOVE     #63,D4
            LEA      BUFRECE(PC),A0
FINDSTR2:   CMPI.B   #$D,0(A0,D4.W)
            BEQ.S    FINDSTR1
FINDSTR7:   SUBQ     #1,D4
            BGE.S    FINDSTR2
FINDSTR3:   MOVEQ    #-1,D0            ;PAS TROUVE
FINDSTR6:   RTS
FINDSTR1:   LEA      STATUSTR(PC),A2
            MOVEQ    #-1,D0
FINDSTR4:   ADDQ     #1,D0
            MOVE.L   (A2)+,D1
            BLT.S    FINDSTR7
            MOVE.L   D1,A1
            MOVEQ    #0,D1
            MOVE.B   (A1)+,D1
            MOVE.L   D1,D5             ;NOMBRE CARACTERES STRING POUR CLEARER
            LEA      0(A1,D1.W),A1     ;FIN + 1 STRING A COMPARER
            MOVE     D4,D2
            LEA      BUFRECE(PC),A0
FINDSTR5:   MOVE.B   -(A1),D3
            CMP.B    0(A0,D2.W),D3
            BNE.S    FINDSTR4
            SUBQ     #1,D1
            BEQ.S    FINDSTR8          ;STRING TROUVEE NUM DANS D0
            SUBQ     #1,D2
            BGE.S    FINDSTR5
            MOVE     #63,D2
            BRA.S    FINDSTR5
FINDSTR8:   LEA      0(A0,D2.W),A0
            SUBQ     #1,D5
FINDSTR9:   CLR.B    (A0)+             ;CLR 1ER OCTET STRING TROUVEE
            DBF      D5,FINDSTR9
            RTS
STATUSTR:   DC.L     STRCON1,STRCON2,STRCON3,STRCON4,STRCON5,STRCON6,STRCON7,-1

STRCON1:    DC.B     10,'LOCAL MAS',$D
STRCON2:    DC.B     10,'LOCAL SLA',$D
STRCON3:    DC.B     8,'CONNECT',$D
STRCON4:    DC.B     13,'CONNECT 1200',$D
STRCON5:    DC.B     13,'CONNECT 2400',$D
STRCON6:    DC.B     11,'NO CARRIER',$D
STRCON7:    DC.B     3,'OK',$D
* ECHO OFF/RESULT ON/WORD CODE/NO DIAL 2400/HP/DCD <-> CD/DTR OFF/
STRCON8:    DC.B    4,'ATD',$D
STRCON9:    DC.B    4,'ATA',$D
STRCONA:    DC.B    19,'ATX3E0Q0V1M1&C1&D0',$D
STRCONB:    DC.B    3,'+++'
STRCONC:    DC.B    4,'ATZ',$D
STRCOND:    DC.B    1,0
STRCONE:    DC.B    20,-1,-1
            CNOP    0,2
FLGENV:     DC.W     0
TMPENV:     DC.L     0              ;Tampon d'emission
PNTBUF:     DC.W     0              ;Conserve pour nombre octets emission
PNTSEND:    DC.W     0              ;Pointeur d'emission

CMPCOM:     DC.W    0
TIMECOM:    DC.L    0

***********************************
*  GESTION DU SON - J.L Langlois  *
***********************************

tailbd: equ     1538
tailcr: equ     2882
tailac: equ     7736
tailbb: equ     2654

vitcr:  equ     410
vitbd:  equ     531
vitac:  equ     450

* demson - Demarre Son
*
demson   MOVE.W  #$F,DMACONW
         move.w  #$780,INTENA
         move.w  #$780,INTREQ   
         clr.w  nouson
         clr.w  anson
         clr.l  rapport
         clr.w  rapport+4
         clr.w  bcle
         clr.w  demmot
         clr.w  demint
         clr.w  ecmot
         clr.l  canal
         clr.l  canal+4
         MOVE.L   #INTAUDI,$70
         move.l   mot1(pc),AUD0LCH
         move.l   mot2(pc),AUD2LCH
         move.l   mot2(pc),AUD3LCH
         MOVE.W   #1166/2,AUD0LEN
         MOVE.W   #582/2,AUD2LEN
         MOVE.W   #582/2,AUD3LEN
         MOVE.W   #52,AUD0VOL   ;MODAMI
         CLR.W    AUD2VOL
         CLR.W    AUD3VOL
         MOVE.W   SNDEQU+8000,AUD0PER
         MOVE.W   #1999,AUD2PER
         MOVE.W   #1999,AUD3PER
         LEA.L    OCT(PC),A1
         CLR.W    (A1)+
         MOVE.L   mot1(pc),(a1)+
         move.w   #1166/2,(a1)+
         move.w   #500,(a1)+
         MOVE.L   mot2(pc),(a1)+
         move.w   #582/2,(a1)+
         move.w   #500,(a1)
         CLR.W    TRCOUR
         CLR.L    NIVINT
         CLR.L    NIVINT+4
        lea.l   datvoit(pc),a1
        move.l  #$fff8fff8,d3
        move.l  d3,(a1)
        move.l  d3,8(a1)
        move.l  d3,16(a1)
        move.l  d3,16+8(a1)
        clr.b   7(a1)
        clr.b   7+16(a1)
        MOVE.W    #$800D,DMACONW
        move.l #routvbl,VR2VBL+2    Say Sound VBL
        rts
* coupson - Coupe  Son
*
coupson: 
         move.l #DUMMY,VR2VBL+2   Restore DUMMY VBL
         MOVE.W  #$F,DMACONW
         move.w  #$780,INTENA
         move.w  #$780,INTREQ
         rts

* VBL Interrupt Routine
*
routvbl: 
        movem.l a0-a5/d0-d7,-(a7)
        move.w    demint(pc),d0
        beq.s     S0RTVB
        move.w    d0,INTREQ
        or.w      #$8000,d0
        move.w    d0,INTENA
        clr.w     demint
S0RTVB: MOVE.W    demmot(PC),D0
        BEQ.S     SRTVBL
        OR.W      #$8000,D0
        MOVE.W    D0,DMACONW
        CLR.W     demmot
SRTVBL: 
        tst.w   FROTT
        beq   trtbrb
        move.w  nouson(pc),d0
        blt   trtbrb
        MOVE.L  #FROTT+4,A4
        MOVE.W  XB,D1
        MOVE.W  D1,D0
        SUB.W   (A4)+,D0
        BGE.S   PAFR0
        CLR.W   D0
        BRA.S   FROTC
PAFR0:  SUB.W   (A4),D1
        NEG.W   D1
        BGE.S   FROTC
        CLR.W   D1
FROTC:  CMP.W   D0,D1
        BLE.S   FROTCC
        MOVE.W  D0,D1
FROTCC: move.w  SP1D+2,d0
        lsr.w   #3,d0
        move.w  d0,d3
        lsr.w   #3,d1
        sub.w   d1,d0
        add.w   #10,d0
        ble     fbrbl
        cmp.w   #60,d0
        ble.s   pvolm2
        move.w  #60,d0    ;volume
pvolm2: add.w   d3,d3
        add.w   #41,d3  ;freq init
        lsl.w   #4,d3
        lsl.w   #4,d0
        move.w  #-1,brbl
        move.w  d3,freco
        move.w  d0,volco
        move.b  #12,phase
        bra     phasc
trtbrb: move.w  brbl(pc),d0
        beq     pabrbl
        blt     brblco
;creat br blanc
        move.w  #-1,brbl
        move.w  SP1D+2,d0
        sub.w   #120,d0
        blt     fbrbl
        move.w  d0,d3
        move.w  d0,d4
        lsr.w   #1,d0
        move.w  d0,d2   ;delta freq 190
        lsr.w   #1,d0
        move.w  dist(pc),d1
        lsr.w   #3,d1
        sub.w   d1,d0
        move.w  volob(pc),d7
        move.b  tvolu(pc,d7.w),d7
        muls    d7,d0
        asr.w   #6,d0
        ble.L   fbrbl
        cmp.w   d7,d0
        ble.s   pvolma
        move.w  volob(pc),d0    ;volume max
        bra.s   pvolma
tvolu:  dc.b    10,11,12,14,16,18,21,24,27,31,35,40,45,51,58,63
pvolma: lsr.w   #4,d4
        neg.w   d4
        add.w   #24,d4
        move.w  d4,d1
        LSR.W   #2,D1
        ADD.W   #10,D1
        move.w  d1,d4
        lsr.w   #2,d4   ;t1
        sub.w   d4,d1
        lsr.w   #1,d1   ;t2
        exg     d1,d4
        lsr.w   #2,d3
        add.w   #15,d3
        move.w  d2,d7
        lsr.w   #1,d7
        add.w   d7,d3   ;freq   init

        subq.w  #8,d0
        bge.s   nnnn
        clr.w   d0
nnnn:   lsl.w   #4,d0
        lsl.w   #4,d2
        ext.l   d0
        ext.l   d2
        move.b  d4,tt1
        addq.w  #1,d1
        move.b  d1,tt2
        move.b  d4,stt
        divu    d4,d0   ;add vol
        addq.w  #1,d1
        divu    d1,d2   ;add frq
        move.w  d0,pasvo
        move.w  d2,pasfr
        move.w  #8*16,volco
        sub.w   d0,volco
        lsl.w   #4,d3
        move.w  d3,freco
        clr.b   phase
        bra.s   phas0
brblco: moveq   #0,d0
        move.b  phase(pc),d0
        jmp     tphas(pc,d0.w)
tphas:  bra.l   phas0
        bra.l   phas1
        bra.l   phas2
        bra.l   phas3
phas0:  subq.b  #1,stt
        bge.s   sphas0
        move.w  pasvo(pc),d0
        add.w   d0,volco
        move.b  #4,phase
        move.b  tt2(pc),stt
        bra.s   phas1
sphas0: move.w  pasvo(pc),d0
        add.w   d0,volco
        bra.s   phasc
phas1:  subq.b  #1,stt
        bge.s   sphas1
        move.w  pasfr(pc),d0
        sub.w   d0,freco
        move.b  #8,phase
        move.b  tt1(pc),stt
        bra.s   phas2
sphas1: move.w  pasfr(pc),d0
        sub.w   d0,freco
        bra.s   phasc
phas2:  subq.b  #1,stt
        blt.s   fbrbl
        move.w  pasvo(pc),d0
        sub.w   d0,volco
phasc:  move.w  brubco(pc),d0
        bne.s   sphasc
        bsr     crebb
        move.w  brubco(pc),d0
sphasc: move.l  #AUD0PER,a0
        lsl.w   #3,d0
        add.w   d0,a0
        move.w  freco(pc),d0
        lsr.w   #3,d0
        and.w   #$fffe,d0
        lea.l   SNDEQU+8000,a1
        move.w  0(a1,d0.w),(a0)+
        move.w  volco(pc),d0
        lsr.w   #4,d0
        move.w  d0,(a0)
        bra.s   pabrbl
phas3:  tst.w   FROTT
        bne.s   phasc
fbrbl:  clr.w   brbl
        clr.l   freco
        move.w  brubco(pc),d0
        beq     pabrbl
        bsr     coupca1
        clr.w   brubco
        bra.s   pabrbl
pasfr:  dc.w    0
pasvo:  dc.w    0
freco:  dc.w    0
volco:  dc.w    0
phase:  dc.b    0
stt:    dc.b    0
tt1:    dc.b    0
tt2:    dc.b    0
volob:  dc.w    0
dist:   dc.w    0
brbl:   dc.w    0
pabrbl: 
        move.w  nouson(pc),d0
        blt.s   pamoso
        move.w  #-1,nouson
        lsl.w   #4,d0
        move.w  anson(pc),d1
        lsl.w   #2,d1
        or.w    d1,d0
        jmp     tnous(pc,d0.w)
tnous:  bra.l   nornor
        bra.l   crinor
        bra.l   bonnor
        bra.l   accnor
        bra.l   norcri
        bra.l   cricri
        bra.l   frtvbl
        bra.l   acccri
        bra.l   norbon
        bra.l   cribon
        bra.l   bonbon
        bra.l   accbon
        bra.l   noracc
        bra.l   criacc
        bra.l   bonacc
        bra.l   accacc
pamoso: move.w  anson(pc),d0
        lsl.w   #2,d0
        jmp     tans(pc,d0.w)
tans:   bra.l   snorm
        bra.l   scris
        bra.l   sbond
        bra.l   sacci
snorm: 
scris:  bsr     mprin0
        lea.l   canal(pc),a5
        tst.w   4(a5)
        bne.s   scri1
        bsr     mvoi0
scri1:  tst.w   6(a5)
        bne     frtvbl
        bsr     mvo20
        bra     frtvbl
sacci:
sbond:  move.w  bruico(pc),d0
        lea.l   NIVINT(pc),a5
        tst.w   0(a5,d0.w)
        bge.s   scris
        bsr     coupcan
        clr.w   anson
        bra.s   scris

nornor: bsr     mprinc
        lea.l   canal(pc),a5
        tst.w   4(a5)
        bne.s   norno1
        bsr     movo1
norno1: tst.w   6(a5)
        bne     frtvbl
        bsr     movo2
        bra     frtvbl
crinor: move.w  bruico(pc),d0
        bsr     coupca1
        clr.w   anson
        bra.s   nornor
accnor:
bonnor: move.w  bruico(pc),d0
        lea.l   NIVINT(pc),a5
        tst.w   0(a5,d0.w)
        bge.s   nornor
        bsr     coupcan
        clr.w   anson
        bra.s   nornor
norcri: move.l  adcri(pc),d6
        move.w  #tailcr/2,d7
        move.w  #52,d5
        move.w  #vitcr,d4
        bsr     crecan
        move.w  #1,anson
cricri: bra     nornor
acccri: bra     frtvbl
norbon: move.l  adbon(pc),d6
        move.w  #tailbd/2,d7
        move.w  #38,d5
        move.w  #vitbd,d4
        bsr     creca1
        move.w  #2,anson
        bra     nornor
accbon:
cribon: move.w  bruico(pc),d0
        bsr     coupca1
        bra.s   norbon
accacc:
bonbon: bra     nornor
noracc: move.l  accid(pc),d6
        move.w  #tailac/2,d7
        move.w  #58,d5
        move.w  #vitac,d4
        bsr     creca1
        move.w  #3,anson
        bra     nornor
bonacc:
criacc: move.w  bruico(pc),d0
        bsr     coupca1
        bra.s   noracc

crecan: bsr     trvcan
        move.w  d0,bruico
        bsr     inson
        rts
creca1: bsr     trvcan
        move.w  d0,bruico
        lea.l   NIVINT(pc),a0
        clr.w   0(a0,d0.w)
        bsr     inson
        clr.w   d1
        addq.w  #7,d2
        bset    d2,d1
        move.w    d1,demint
        rts
crebb:  bsr     trvcan
        move.w  d0,brubco        
        move.w  demmot(pc),d1
        move.w  d0,d2
        lsr.w   #1,d2
        bset    d2,d1
        move.w  d1,demmot
        lsl.w   #3,d0
        lea.l   AUD0LCH,a0
        move.l  adbrbl(pc),0(a0,d0.w)
        move.w  #tailbb/2,4(a0,d0.w)
        rts
                
inson:  move.w  demmot(pc),d1
        move.w  d0,d2
        lsr.w   #1,d2
        bset    d2,d1
        move.w  d1,demmot
        lsl.w   #3,d0
        lea.l   AUD0LCH,a0
        move.l  d6,0(a0,d0.w)
        move.w  d7,4(a0,d0.w)
        move.w  d4,6(a0,d0.w)
        move.w  d5,8(a0,d0.w)
        rts
trvcan: lea.l   canal+2(pc),a5
        tst.w   (a5)
        bne.s   strvca
        moveq   #2,d0
        move.w  #1,(a5)
        rts
strvca: lea.l   datvoit(pc),a0
        tst.w   (a0)
        bge.s   strvcb
trcan2: moveq   #4,d0
        move.w  #1,2(a5)
        move.w  #$4,DMACONW
        move.w  #$200,INTENA
        move.w  #$200,INTREQ
        rts
strvcb: tst.w   16(a0)
        bge.s   strvcc
trcan3: moveq   #6,d0
        move.w  #1,4(a5)
        move.w  #$8,DMACONW
        move.w  #$400,INTENA
        move.w  #$400,INTREQ
        rts
strvcc: move.b  7(a0),d0
        cmp.b   7+16(a0),d0
        bge.s   trcan2
        bra.s   trcan3

coupca1:
        move.w  d0,d1
        clr.w   d2
        lsr.w   #1,d1
        bset    d1,d2
        move.w  d2,DMACONW
        lsl.w   #7,d2
        move.w  d2,INTENA
        move.w  d2,INTREQ
coupcan:
        lea.l   canal(pc),a5
        clr.w   0(a5,d0.w)
        subq.w  #4,d0
        blt.s   fcoupc
        move.w  demmot(pc),d1
        move.w  d0,d2
        lsr.w   #1,d2
        addq.w  #2,d2
        bset    d2,d1
        move.w  d1,demmot
        lsl.w   #3,d0
        lea.l   AUD2LCH,a0
        move.l  mot2(pc),0(a0,d0.w)
        move.w  #582/2,4(a0,d0.w)
        clr.w   8(a0,d0.w)
        lea.l   datvoit(pc),a0
        move.l  #$fff8fff8,0(a0,d0.w)
        move.l  #$fff8fff8,8(a0,d0.w)
        clr.b   7(a0,d0.w)
fcoupc: rts

mprinc: lea.l   rapport(pc),a3
        move.w  (a3),d7
        cmp.w   2(a3),d7
        beq.s   mprin1
        move.w  d7,2(a3)
        move.w  d7,10(a3)
        move.w  d7,d2
        sub.w   4(a3),d7
        bge.s   neg1
        subq.w  #1,d7
        asr.w   #2,d7
        addq.w  #1,d7
        bra.s   sneg1
neg1:   asr.w   #2,d7
sneg1:  sub.w   d7,d2
        move.w  d2,8(a3)
        sub.w   d7,d2
        move.w  d2,6(a3)
        sub.w   d7,d2
        move.w  d2,4(a3)
        bra.s   mprin2
mprin0: lea.l   rapport(pc),a3
mprin1: 
        move.w  2(a3),d7
        cmp.w   4(a3),d7
        beq     fmprin
        move.w  6(a3),4(a3)
        move.w  8(a3),6(a3)
        move.w  10(a3),8(a3)
mprin2: move.w  4(a3),d7
        lsr.w   #2,d7
*        eor.w   #2,vibprin
*        add.w   vibprin(pc),d7
        lea.l   SNDEQU+8000,a0
        MOVE.W  #1,TRCOUR
        MOVE.W  D7,D6
REPRIM  cmp.w   #205-67,d7
        ble.s   mprin3
        TST.W   ecmot
        bne.s   mmech0
        move.w  #8,OCT
        move.w  d7,d2
        cmp.w   #205,d7
        ble.s   octba
        move.w  #205,d7
octba:  add.w   d7,d7
        move.w  0(a0,d7.w),AUD0PER
        sub.w   #72,d2
        add.w   d2,d2
        move.w  0(a0,d2.w),TOCT+8+6
        move.w  #$80,INTREQ
        move.w  #$8080,INTENA
        bra.s   f0mpri
mmech0: sub.w   #72,d7
        add.w   d7,d7
        move.w  0(a0,d7.w),AUD0PER
        bra.s   f0mpri
mprin3: 
        TST.W   ecmot
        beq.s   mmech1
        clr.w   OCT
        move.w  d7,d2
        sub.w   #72,d7
        bge.s   octha
        clr.w   d7
octha:  add.w   d7,d7
        move.w  0(a0,d7.w),AUD0PER
        add.w   d2,d2
        move.w  0(a0,d2.w),TOCT+6
        move.w  #$80,INTREQ
        move.w  #$8080,INTENA
        bra.s   f0mpri
mmech1: add.w   d7,d7
        move.w  0(a0,d7.w),AUD0PER
f0mpri: clr.w   TRCOUR
fmprin: rts
        MOVE.W  D6,D7
        BRA     REPRIM
*vibprin: dc.w   0
*********
movo1:  lea.l   datvoit(pc),a3
        clr.w   d6
        tst.w   2(a3)
        bge.s   smov0
        moveq   #1,d6
smov0:  move.w  (a3),d7
        bge.s   smov1
        moveq   #1,d6
smov1:  cmp.w   2(a3),d7
        bne.s   mvoi1
        tst.w   d7
        blt     fmvoi1
        bgt   mvo1b
        subq.b  #1,6(a3)
        bge   mvo1b
        clr.w   d0
        move.b  5(a3),d0
        lea.l   sqarr(pc),a2
        move.b  0(a2,d0.w),d7
        lsl.w   #3,d7
        move.b  1(a2,d0.w),6(a3)
        addq.w  #2,d0
        and.w   #$3f,d0
        move.b  d0,5(a3)
        bra.s   rvoi1
mvoi1:  move.w  d7,2(a3)
rvoi1:  tst.w   d6
        beq.s   rvoi2
        move.w  d7,8(a3)
        bra.s   mvoi2
rvoi2:  move.w  d7,14(a3)
        move.w  d7,d2
        sub.w   8(a3),d7
        bge.s   neg4
        subq.w  #1,d7
        asr.w   #2,d7
        addq.w  #1,d7
        bra.s   sneg4
neg4:   asr.w   #2,d7
sneg4:  sub.w   d7,d2
        move.w  d2,12(a3)
        sub.w   d7,d2
        move.w  d2,10(a3)
        sub.w   d7,d2
        move.w  d2,8(a3)
        bra.s   mvoi2
mvoi0:  lea.l   datvoit(pc),a3
        clr.w   d6
mvo1b:  move.w  2(a3),d7
        cmp.w   8(a3),d7
        beq.s   mvoi2
        move.w  10(a3),8(a3)
        move.w  12(a3),10(a3)
        move.w  14(a3),12(a3)
mvoi2:  move.w  8(a3),d0
        blt.s   vide1
        and.w   #$fffe,d0
        lea.l   SNDEQU+8000,a0          ;+72
        move.w  0(a0,d0.w),AUD2PER
        MOVEQ   #40,D2
        sub.b   7(a3),d2
        MOVE.W  D2,AUD2VOL
        RTS
vide1:  clr.w   AUD2VOL
        move.w  #1999,AUD2PER
fmvoi1: rts

movo2:  lea.l   datvoit+16(pc),a3
        clr.w   d6
        tst.w   2(a3)
        bge.s   smov2
        moveq   #1,d6
smov2:  move.w  (a3),d7
        bge.s   smov3
        moveq   #1,d6
smov3:  cmp.w   2(a3),d7
        bne.s   mvo21
        tst.w   d7
        blt     fmvoi2
        bgt.s   mvo2b
        subq.b  #1,6(a3)
        bge.s   mvo2b
        clr.w   d0
        move.b  5(a3),d0
        lea.l   sqarr(pc),a2
        move.b  0(a2,d0.w),d7
        lsl.w   #3,d7
        move.b  1(a2,d0.w),6(a3)
        addq.w  #2,d0
        and.w   #$3f,d0
        move.b  d0,5(a3)
        bra.s   rvo21
mvo21:  move.w  d7,2(a3)
rvo21:  tst.w   d6
        beq.s   rvo22
        move.w  d7,8(a3)
        bra.s   mvo22
rvo22:  move.w  d7,14(a3)
        move.w  d7,d2
        sub.w   8(a3),d7
        bge.s   neg5
        subq.w  #1,d7
        asr.w   #2,d7
        addq.w  #1,d7
        bra.s   sneg5
neg5:   asr.w   #2,d7
sneg5:  sub.w   d7,d2
        move.w  d2,12(a3)
        sub.w   d7,d2
        move.w  d2,10(a3)
        sub.w   d7,d2
        move.w  d2,8(a3)
        bra.s   mvo22
mvo20:  lea.l   datvoit+16(pc),a3
        clr.w   d6
mvo2b:  move.w  2(a3),d7
        cmp.w   8(a3),d7
        beq.s   mvo22
        move.w  10(a3),8(a3)
        move.w  12(a3),10(a3)
        move.w  14(a3),12(a3)
mvo22:  move.w  8(a3),d0
        blt.s   vide2
        and.w   #$fffe,d0
        lea.l   SNDEQU+8000,a0
        move.w  0(a0,d0.w),AUD3PER
        MOVEQ   #40,D2
        sub.b   7(a3),d2
        MOVE.W  D2,AUD3VOL
        RTS
vide2:  CLR.W   AUD3VOL
        move.w  #1999,AUD3PER
fmvoi2: rts
frtvbl: movem.l (sp)+,d0-d7/a0-a5
        rts

INTERM: 
        MOVE.W  TRCOUR+2(PC),D0
        BEQ.S   PRMINTM
        MOVE.W  D1,INTENA
        MOVE.W  OCT(PC),D0
        MOVE.W  TOCT+6(PC,D0.W),AUD0PER
        MOVE.W  D0,ecmot
        CLR.W   TRCOUR+2
        MOVE.W  TRCOUR(PC),D0
        BEQ.S   FINTM
        MOVE.L  #fmprin+2,2+16(SP)
        BRA.S   FINTM
PRMINTM:
        MOVE.L  #AUD0LCH,a0
        MOVE.W  OCT(PC),D0
        LEA.L   TOCT(PC,D0.W),A1
        MOVE.L  (A1)+,(A0)+
        MOVE.W  (A1),(A0)
        MOVE.W  #1,TRCOUR+2        
FINTM:  movem.l (sp)+,A0-A1/d0-d1
        rte
TRCOUR: DC.W    0
NIVINT: DC.W    0,0,0,0
OCT:    DC.W    0
TOCT:   DC.L    0,0,0,0

INTERF:  LSR.W    #1,D0
         LEA.L    NIVINT(PC,D0.W),A0
         TST.W    (A0)
         BGT.S    SINTERF
         MOVE.W   #1,(A0)
         MOVE.L   #AUD0LCH,A0
         LSL.W    #3,D0
         MOVE.L   ecvid(PC),0(A0,D0.W)
         MOVE.W   #50,4(A0,D0.W)
         BRA.S    FINTERF
SINTERF: MOVE.W   D1,INTENA
         LSR.W    #7,D1
         MOVE.W   D1,DMACONW
         MOVE.W   #-1,(A0)
FINTERF: movem.l (sp)+,A0-A1/d0-d1
         rte
INTAUDI:
        MOVEM.L A0-A1/D0-D1,-(A7)
        MOVE.W  INTENAR,D0
        BTST    #$E,D0
        BEQ.S   FININTAU
        AND.W   INTREQR,D0
        LSR.W   #6,D0
        ANDI    #$1E,D0
        BEQ.S   FININTAU
        MOVE.W  TABINT(PC,D0.W),D0
        CLR.W   D1
        BSET    D0,D1
        MOVE.W  D1,INTREQ
        SUBQ    #7,D0
        LSL     #2,D0
        MOVE.L  TINT(PC,d0.w),a0
        jmp     (a0)
FININTAU:
        MOVEM.L (A7)+,A0-A1/D0-D1
        RTE  
TABINT:
        DC.W    0,7,8,8,9,9,9,9,10,10,10,10,10,10,10,10
TINT:    DC.L     INTERM
         DC.L     INTERF
         DC.L     INTERF
         DC.L     INTERF

rtsvoit:
        move.l  Y1,d7
        move.l  d7,d6
        lea.l   CARSRT,a0
        add.l   F1SRT,a0
        lea.l   2(a0),a1
        bsr     recdev
        move.w  d0,d1
        bsr     recder
        lea.l   OCCUR,a2
        move.l  a2,a3
        add.w   d1,a2
        add.w   d0,a3
        move.w  d0,d4
        move.l  2(a2),d2
        sub.l   d7,d2
        move.l  d6,d3
        sub.l   2(a3),d3
        cmp.l   d2,d3
        blt.s   fder
        bsr     recdev        ;d1 et d2 ok
        lea.l   OCCUR,a4
        add.w   d0,a4
        move.l  2(a4),d5
        sub.l   d7,d5
        cmp.l   d5,d3
        bge.s   votro        ;d0 et d5
        neg.l   d3
        move.l  d3,d5
        move.w  d4,d0
        bra.s   votro        ;d4 et d3
fder:   bsr     recder       ;d4 et d3 ok
        lea.l   OCCUR,a4
        add.w   d0,a4
        move.l  d6,d5
        sub.l   2(a4),d5
        cmp.l   d2,d5
        blt.s   fder1
        neg.l   d3      ;d1 et d2
        move.l  d3,d5
        move.w  d4,d0
        bra.s   votro
fder1:  neg.l   d5      ;d0 et d5
        neg.l   d3
        move.l  d3,d2
        move.w  d4,d1
votro:  lea.l   OCCUR,a0
        move.w  18(a0),d7
        move.w  18(a0,d1.w),d3
        move.w  18(a0,d0.w),d4
        lsr.w   #6,d1
        lsr.w   #6,d0
        lea.l   datvoit(pc),a1
        cmp.b   4(a1),d1
        bne.s   tes2
        lea.l   16(a1),a2
        bra.s   afson
tes2:   cmp.b   4+16(a1),d1
        bne.s   tes3
tes4:   move.l  a1,a2
        lea.l   16(a1),a1
        bra.s   afson
tes3:   cmp.b   4(a1),d0
        beq.s   tes4
        lea.l   16(a1),a2
afson:  tst.l   d2
        blt.s   son1n
        cmp.l   #12800,d2
        bgt.s   pason1
        move.b  d1,4(a1)
        move.w  d3,d6
        bsr     regmot
        sub.w   d7,d3
        asr.w   #5,d3
        cmp.w   #450,d2
        bgt.s   dop1
        asr.w   #1,d3
dop1:   sub.w   d3,d6
snoup:  bsr     verd6
        move.b  d3,7(a1)
        move.w  d6,(a1)
        bra.s   afso2
son1n:  cmp.l   #-12800,d2
        blt.s   pason1
        move.b  d1,4(a1)
        move.w  d3,d6
        bsr     regmot
        sub.w   d7,d3
        asr.w   #5,d3
        cmp.w   #-450,d2
        blt.s   dop2
        asr.w   #1,d3
dop2:   add.w   d3,d6
        neg.w   d2
        bra.s   snoup
pason1: move.w  #-8,(a1)
        move.b  #-1,4(a1)
afso2:  tst.l   d5
        blt.s   son2n
        cmp.l   #12800,d5
        bgt.s   pason2
        move.b  d0,4(a2)
        move.w  d4,d6
        bsr     regmot
        sub.w   d7,d4
        asr.w   #5,d4
        cmp.w   #450,d5
        bgt.s   dop3
        asr.w   #1,d4
dop3:   sub.w   d4,d6
        move.w  d5,d2
snoup2: bsr     verd6
        move.b  d3,7(a2)
        move.w  d6,(a2)
        bra.s   fafson
son2n:  cmp.l   #-12800,d5
        blt.s   pason2
        move.b  d0,4(a2)
        move.w  d4,d6
        bsr     regmot
        sub.w   d7,d4
        asr.w   #5,d4
        cmp.w   #-450,d5
        blt.s   dop4
        asr.w   #1,d4
dop4:   add.w   d4,d6
        move.w  d5,d2
        neg.w   d2
        bra.s   snoup2
pason2: move.w  #-8,(a2)
        move.b  #-1,4(a2)
fafson: rts
regmot: sub.w   #148,d6
        bge.s   sregmo
        add.w   #148,d6
        rts
sregmo: move.w  d0,-(sp)
        move.w  #730,d0
        sub.w   d6,d0
        mulu    d6,d0
        add.l   d0,d0
        rol.w   #6,d0
        and.w   #$3f,d0
        move.w  #28*4,d6
        add.w   d0,d6
        swap    d0
        lsl.w   #2,d0
        sub.w   d0,d6
        move.w  (sp)+,d0
        rts
verd6:  move.w  d0,-(sp)
        tst.w   d6
        bgt.s   sverd6
        clr.w   d6
        bra.s   verdis
sverd6: cmp.w   #42*4,d6
        ble.s   fverd6
        move.w  #42*4,d6
fverd6: add.w   d6,d6
verdis: move.w  #8000,d1
        moveq   #12,d3
bvdis:  cmp.w   d1,d2
        bgt.s   fvdis
        subq.w  #1,d3
        ble.s   fvdis
        move.w  d1,d0
        lsr.w   #2,d0
        sub.w   d0,d1
        bra.s   bvdis
fvdis:  move.w  d3,d0
        add.w   d3,d3
        add.w   d0,d3
        move.w  (sp)+,d0
        rts
recdev: move.w  -(a0),d0
        bge.s   pchtd
        lea.l   34(a0),a0
        sub.l   CRCLAP,d7
brpvd:  move.w  -(a0),d0
        blt.s   brpvd
pchtd:  rts
recder: move.w  (a1)+,d0
        bge.s   pchtr
        lea.l   CARSRT,a1
        add.l   CRCLAP,d6
        move.w  (a1)+,d0
pchtr:  rts

datvoit:
        dc.l    0,$ff000000,0,0,0,$ff2e0000,0,0
rapport:
        dc.l    0,0,0,0
canal:  dc.l    0,0
ecvid:  dc.l    0
mot1:   dc.l    0
mot2:   dc.l    0
adbon:  dc.l    0
accid:  dc.l    0
adcri:  dc.l    0
adbrbl: dc.l    0

sqarr:  dc.b    4,46,8,0,16,0,24,0,32,0,29,0,26,0,23,0,30,0,37,0,34,0
        dc.b    31,0,27,0,23,0,19,0,15,2,23,0,31,0,26,0,21,0,16,0,11,0
        dc.b    6,0,2,120,17,0,27,0,23,0,20,0,17,0,13,0,10,0,6,135

bcle:   dc.w    0
fiint:  dc.w    0
nouson: dc.w    0
anson:  dc.w    0
demmot: dc.w    0
demint:  dc.w     0
ecmot:  dc.w    0
bruico: dc.w      0
brubco: dc.w      0
* GESTION DES INTERRUPTIONS
INTER2:
                MOVEM.L A0/D0,-(A7)
                LEA             TABLEINTE(PC),A0
                MOVE.W          INTENAR,D0
                BTST            #$E,D0
                BEQ.S           FININTE2
                AND.W           INTREQR,D0
                BTST            #3,D0
                BEQ.S           FININTE2 ;CIA 8520
                MOVE.L          8(A0),A0
                JMP             (A0)
FININTE2:       MOVEM.L (A7)+,A0/D0
                RTE

INTER3:
                MOVEM.L A0/D0,-(A7)
                MOVE.W          INTENAR,D0
                BTST            #$E,D0
                BEQ.S           FININTE3
                AND.W           INTREQR,D0
                BTST            #6,D0
                BEQ.S           INTER31
                MOVE.L          A6,-(SP)
                MOVE.W          #$0040,INTREQ
                MOVE.L          PTTRBL,A0
                MOVE.L          (A0)+,A6
                JMP             (A6)            ;FIN BLITTER
INTER31:        BTST            #5,D0
                BEQ.S           INTER32
                LEA             TABLEINTE(PC),A0
                MOVE.W          #$0020,INTREQ
                MOVE.L          16(A0),A0
                JMP             (A0)            ;VBL
INTER32:        BTST            #4,D0
                BEQ.S           FININTE3
                LEA             TABLEINTE(PC),A0
                MOVE.W          #$0010,INTREQ
                MOVE.L          20(A0),A0
                JMP             (A0)            ;COPPER
FININTE3:       MOVEM.L (A7)+,A0/D0
                RTE
INTER4:
                MOVEM.L A0/D0,-(A7)
                LEA             TABLEINTE(PC),A0
                MOVE.W          INTENAR,D0
                BTST            #$E,D0
                BEQ.S           FININTE4
                AND.W           INTREQR,D0
                BTST            #7,D0
                BEQ.S           INTER41
                MOVE.W          #$0080,INTREQ
                MOVE.L          24(A0),A0
                JMP             (A0)
INTER41: BTST           #8,D0
                BEQ.S           INTER42
                MOVE.W          #$0100,INTREQ
                MOVE.L          28(A0),A0
                JMP             (A0)
INTER42: BTST           #9,D0
                BEQ.S           INTER43
                MOVE.W          #$0200,INTREQ
                MOVE.L          32(A0),A0
                JMP             (A0)
INTER43: BTST           #10,D0
                BEQ.S           FININTE4
                MOVE.W          #$0400,INTREQ
                MOVE.L          36(A0),A0
                JMP             (A0)
FININTE4:       MOVEM.L (A7)+,A0/D0
                RTE
INTER6:                 ;EXTERNE INUTILISE
                MOVEM.L A0/D0,-(A7)
                LEA             TABLEINTE(PC),A0
                MOVE.W          INTENAR,D0
                BTST            #$E,D0
                BEQ.S           FININTE6
                AND.W           INTREQR,D0
                BTST            #13,D0
                BEQ.S           FININTE6
                MOVE.W          #$2000,INTREQ
                MOVE.L          48(A0),A0
                JMP             (A0)
FININTE6:       MOVEM.L         (A7)+,A0/D0
                RTE
TABLEINTE:
                DC.L    SENDIT   ;EMISSION SERIE
                DC.L    INTEVIDE ;DATA DISQUE
                DC.L    ROUTCLAV ;CIA 8250
                DC.L    INTEVIDE ;FIN BLITTER
                DC.L    INTEVIDE ;VBL
                DC.L    INTERVBL ;COPPER
                DC.L    INTEVIDE ;AUDIO0
                DC.L    INTEVIDE ;AUDIO1
                DC.L    INTEVIDE ;AUDIO2
                DC.L    INTEVIDE ;AUDIO3
                DC.L    INTEVIDE ;SYNC DISK
                DC.L    R1CIEV   ;RECEPTION SERIE
                DC.L    INTETIME ;NIVEAU 8250
INTEVIDE:       MOVEM.L (A7)+,D0/A0
                RTE
INTETIME:
                MOVE.B        $BFDC00,D0
                MOVEM.L       (A7)+,D0/A0
                RTE

* ROUTINE CLAVIER (8250)
ROUTCLAV:
                MOVE.B          $BFED01,D0
                BTST            #3,D0
                BEQ             FRTCLAV
                MOVE.B          $BFEC01,D0
                not.b           d0
                ror.b           #1,d0
                or.B            #$40,$BFEE01  
                CMPI.B          #$E2,D0
                BEQ.S           AZERT                
                CMPI.B          #$62,D0              
                BEQ.S           QWERT                
                BRA.S           CARCLAV              
AZERT:                                               
                LEA             TASCII,A0          
                MOVE.B          #'A',$10(A0)          
                MOVE.B          #'Z',$11(A0)          
                MOVE.B          #'Q',$20(A0)          
                MOVE.B          #'W',$31(A0)          
                MOVE.B          #'M',$29(A0)         
                BRA             FRTCLAV              
QWERT:                                               
                LEA             TASCII,A0          
                MOVE.B          #'Q',$10(A0)
                MOVE.B          #'W',$11(A0)
                MOVE.B          #'A',$20(A0)
                MOVE.B          #'Z',$31(A0)
                MOVE.B          #'M',$37(A0)
                BRA             FRTCLAV
CARCLAV:                                             
                MOVE.L          tab_clav(pc),A0
                MOVE.B          D0,7(A0)
                CMP.B           #$4E,D0
                BNE.S           T4F
                CMP.W           #3,VITMOUSX
                BGE.S           FRTCLAV
                ADDQ.W          #1,VITMOUSX
                BRA.S           FRTCLAV
T4F:            CMP.B           #$4F,D0
                BNE.S           T4C
                TST.W           VITMOUSX
                BLE.S           FRTCLAV
                SUBQ.W          #1,VITMOUSX
                BRA.S           FRTCLAV
T4C:            CMP.B           #$4C,D0
                BNE.S           T4D
                CMP.W           #3,VITMOUSX+2
                BGE.S           FRTCLAV
                ADDQ.W          #1,VITMOUSX+2
                BRA.S           FRTCLAV
T4D:            CMP.B           #$4D,D0
                BNE.S           FRTCLAV
                TST.W           VITMOUSX+2
                BLE.S           FRTCLAV
                SUBQ.W          #1,VITMOUSX+2
FRTCLAV:         
                CLR.B           $BFEC01
                MOVE.W          VIT68K,D0
TMPCLAV:                        
                NOP             
                DBF             D0,TMPCLAV
                ANDI.B          #$BF,$BFEE01
                MOVE.W          #$0008,INTREQ
                MOVEM.L         (A7)+,D0/A0
                RTE
tab_clav:     dc.l    0  

****************************************************************
* INIHBL/EXIHBL - HBL Routines - POUR PHASE DE JEU -  C Droin  *
****************************************************************

INIHBL  MOVE.W  #8,CH_RES
        RTS

EXIHBL  CLR.W   CH_RES
        RTS

INIMHBL MOVE.W  #4,CH_RES
        RTS

RTRES0: MOVE.W   CH_RES(PC),D0
        BLT.S    RTRES02
        MOVE.W   #-1,CH_RES
        LEA.L    TRESOL(PC),A0
        MOVE.L   0(A0,D0.W),VR1VBL+2
        MOVE.L   CH_RES+2(PC),D1
        BGE.S    RTRES01
        MOVE.W   COPPER1+2(PC),D1
        SWAP     D1
        MOVE.W   COPPER1+6(PC),D1
RTRES01:
        MOVE.L   #-1,CH_RES+2
        MOVE.L   12(A0,D0.W),A1
        JMP      (A1)
RTRES02:
        MOVE.L   CH_SCR(PC),D1
        BLT.S    FRTRES0
        LEA.L    COPPER1+2(PC),A1
        MOVEQ    #3,D0
        MOVE.L   #8000,D3
        BSR      CHADSCR
        MOVE.L   #-1,CH_SCR
FRTRES0 RTS

RTRES4: MOVE.W   CH_RES(PC),D0
        BLT.S    RTRES42
        MOVE.W   #-1,CH_RES
        LEA.L    TRESOL(PC),A0
        MOVE.L   0(A0,D0.W),VR1VBL+2
        MOVE.L   CH_RES+2(PC),D1
        BGE.S    RTRES41
        MOVE.W   COPPER2+2(PC),D1
        SWAP     D1
        MOVE.W   COPPER2+6(PC),D1
RTRES41:
        MOVE.L   #-1,CH_RES+2
        MOVE.L   12(A0,D0.W),A1
        JMP      (A1)
RTRES42:
        MOVE.L   CH_SCR(PC),D1
        BLT.S    FRTRES4
        LEA.L    COPPER2+2(PC),A1
        MOVEQ    #1,D0
        MOVE.L   #16000,D3
        BSR      CHADSCR
        MOVE.L   #-1,CH_SCR
FRTRES4 RTS

RTRES8: TST.W    TOTTIM+4                 Time Counter
        BLT.S    VBLHBL1
        ADDQ.L   #2,TOTTIM
VBLHBL1 MOVE.W   CH_RES(PC),D0
        BLT.S    RTRES82
        MOVE.W   #-1,CH_RES
        LEA.L    TRESOL(PC),A0
        MOVE.L   0(A0,D0.W),VR1VBL+2
        MOVE.L   CH_RES+2(PC),D1
        BGE.S    RTRES81
        MOVE.W   COPPER3+2(PC),D1
        SWAP     D1
        MOVE.W   COPPER3+6(PC),D1
RTRES81:
        MOVE.L   #-1,CH_RES+2
        MOVE.L   12(A0,D0.W),A1
        JSR      (A1)
        BRA.S    RTRES83
RTRES82:
        MOVE.L   CH_SCR(PC),D1
        BLT.S    RTRES83
        LEA.L    COPPER3+2(PC),A1
        MOVEQ    #3,D0
        MOVE.L   #8000,D3
        BSR      CHADSCR
        MOVE.L   #-1,CH_SCR
RTRES83:
        MOVE.L   CHRPAL(PC),D0
        BLT.S    FRTRES8
        MOVE.L   CHRPAL+4(PC),CHRPAL
        MOVE.L   #-1,CHRPAL+4
        MOVE.L   D0,A0
        LEA.L    PGAME+2(PC),A1
        MOVEQ    #14,D0
BPRES8: MOVE.W   (A0)+,(A1)
        ADDQ.W   #4,A1
        DBF      D0,BPRES8 
FRTRES8 RTS

CHADSCR MOVE.L   D1,D2
        MOVE.W   D2,4(A1)
        SWAP     D2
        MOVE.W   D2,(A1)
        ADDQ.W   #8,A1
        ADD.L    D3,D1
        DBF      D0,CHADSCR
        RTS

CHRES0: MOVEQ    #3,D0
        MOVE.L   #8000,D3
        LEA.L    COPPER1+2(PC),A1
        BSR      CHADSCR
        BSR      LOW
        MOVE.L   #COPPER1,COP1LCH
        RTS

CHRES4: MOVEQ    #1,D0
        MOVE.L   #16000,D3
        LEA.L    COPPER2+2(PC),A1
        BSR      CHADSCR
        BSR      MED
        MOVE.L   #COPPER2,COP1LCH
        RTS

CHRES8: MOVEQ    #3,D0
        MOVE.L   #8000,D3
        LEA.L    COPPER3+2(PC),A1
        BSR      CHADSCR
        BSR      LOW
        MOVE.L   #COPPER3,COP1LCH
        RTS

LOW:            LEA             CUSTOM,A0
                MOVE.W          #$4200,BPLCON0(A0) ;4 plans lowrez
*                MOVE.W          #$2C81,DIWSTRT(A0) ;
*                MOVE.W          #$F4C1,DIWSTOP(A0) ;
                MOVE.W          #$0038,DDFSTRT(A0) ;data start
                MOVE.W          #$00D0,DDFSTOP(A0) ;data stop
*                MOVE.W          #0,BPL1MOD(A0)     ;modulo
*                MOVE.W          #0,BPL2MOD(A0)     ;modulo
                RTS

MED:            LEA             CUSTOM,A0
                MOVE.W          #$A200,BPLCON0(A0) ;4 plans lowrez
*                MOVE.W          #$2C81,DIWSTRT(A0) ;
*                MOVE.W          #$F4C1,DIWSTOP(A0) ;
                MOVE.W          #$003C,DDFSTRT(A0) ;data start
                MOVE.W          #$00D4,DDFSTOP(A0) ;data stop
*                MOVE.W          #0,BPL1MOD(A0)     ;modulo
*                MOVE.W          #0,BPL2MOD(A0)     ;modulo
                RTS

TRESOL: DC.L    RTRES0
        DC.L    RTRES4
        DC.L    RTRES8
        DC.L    CHRES0
        DC.L    CHRES4
        DC.L    CHRES8

* ROUTINE SOURIS ET VBL

DUMMY    RTS
INTERVBL:
                MOVEM.L         A1/D1/D2/D3,-(A7)
                ADDQ.L   #1,TIMVBL
                
            TST      $3A
            BEQ.S    NOFLOP
            BLT.S    DSFLOP
            SUBQ     #1,DEFLOP
            BGE.S    NOFLOP
            LEA      $BFD100,A0
            ORI.B    #$F8,(A0)
            ANDI.B   #$87,(A0)
            ORI.B    #$F8,(A0)
            CLR      $3A
            BRA.S    NOFLOP
DSFLOP:     MOVE     #50*3,DEFLOP
            NEG      $3A
NOFLOP:
            CMPI.W   #8,OLDCOM         ;SI MODEM
            BNE.S    VRM0VBL
            TST      FSLAMOD            ;ET CONNEXION PHYSIQUE
            BNE.S    VRM1VBL
            TST      SYNC
            BLT.S    VRM0VBL
VRM1VBL:    BTST     #5,$BFD000
            BEQ.S    VRM0VBL            ;PERTE DE PORTEUSE (DCD)
            MOVE     #-1,SYNC
            CLR      OLDCOM
            CLR      FSLAMOD
VRM0VBL:
VR1VBL:   jsr      $12345678
VR2VBL:   jsr      $12345678

                MOVE.L          tab_clav(PC),A0
                CLR.W           (A0)
                BTST    #2,$DFF016
                BNE.S   PCLDRT
                BSET    #1,1(A0)
PCLDRT          BTST    #6,$BFE001
                BNE.S   PCLGCH
                BSET    #0,1(A0)
PCLGCH          BTST    #7,$BFE001
                BNE.S   TSTMOUS
                BSET    #1,1(A0)
TSTMOUS:
                MOVE.W          JOY0DAT,D0
                CLR.W           D1
                MOVE.B          D0,D1
                LSR.W           #8,D0
                MOVE.L          OLDCOUNT(PC),D2
                MOVE.W          D0,OLDCOUNT
                MOVE.W          D1,OLDCOUNT+2
                SUB.W           D1,D2           ;YCOUNT
                CMPI.W          #127,D2
                BLT.S           OVMOUS1
                SUB.W           #255,D2
OVMOUS1:        CMPI.W          #-127,D2
                BGT.S           OVMOUS2
                ADD.W           #255,D2
OVMOUS2:        MOVE.W          VITMOUSX(PC),D3
                ASR.W           D3,D2
                SUB.W           D2,2(A0)
                SWAP            D2
                SUB.W           D0,D2
                CMPI.W          #127,D2
                BLT.S           OVMOUS3
                SUB.W           #255,D2
OVMOUS3:        CMPI.W          #-127,D2
                BGT.S           OVMOUS4
                ADD.W           #255,D2
OVMOUS4:        MOVE.W          VITMOUSX+2(PC),D3
                ASR.W           D3,D2
                SUB.W           D2,4(A0)
CLMOUS4:        
                MOVE.W      JOY1DAT,D0      ;JOYSTICK SUR PORT 1
                MOVE.W      D0,D1
                LSR.W       #8,D1
                ANDI.W      #$03,D0
                ANDI.W      #$03,D1
                MOVE.B      CONVJOY(PC,D0.W),D0   ;TAB[4] = DIRECTION JOYSTICK
                OR.B        CONVJOY+4(PC,D1.W),D0
                MOVE.B      D0,9(A0)
                MOVEM.L         (A7)+,A1/D1/D2/D3
                MOVEM.L         (A7)+,D0/A0
                RTE
DEFLOP:         DC.W        0
CONVJOY:                            ;COMPATIBILITE ST
        DC.B        0,2,10,8,0,1,5,4
VITMOUSX:       DC.W            1,1          ;X,Y
OLDCOUNT:       DC.L            0

PALSOMB:
        MOVEM.L D0-D3/A0-A2,-(SP)
        MOVE.L  #CRCPAL+2,A0
        MOVE.L  A0,CHRPAL
        MOVE.L  A0,CHRPAL+4
        MOVE.W  #14,D0
        LEA.L   ADSOMB(PC),A1
        LEA.L   30(A1),A2
BSOMB:  MOVE.W  (A0)+,D1
        MOVE.W  D1,(A2)+
        MOVE.W  D1,D2
        AND.W   #$F,D2
        CMP.W   #2,D2
        BLE.S   SPAL0
        SUBQ.W  #2,D2
SPAL0:  MOVE.W  D1,D3
        LSR.W   #4,D3
        AND.W   #$F,D3
        CMP.W   #2,D3
        BLE.S   SPAL1
        SUBQ.W  #2,D3
SPAL1:  LSR.W   #8,D1
        AND.W   #$F,D1
        CMP.W   #2,D1
        BLE.S   SPAL2
        SUBQ.W  #2,D1
SPAL2:  LSL.W   #8,D1
        LSL.W   #4,D3
        OR.W    D1,D2
        OR.W    D3,D2
        MOVE.W  D2,(A1)+
        DBF     D0,BSOMB
        MOVE.W  4(A1),D1
        MOVE.W  D1,D2
        AND.W   #$F,D2
        CMP.W   #2,D2
        BLE.S   SPAL3
        SUBQ.W  #2,D2
SPAL3:  
        LSR.W   #4,D1
        AND.W   #$F,D1
        CMP.W   #2,D1
        BLE.S   SPAL4
        SUBQ.W  #2,D1
SPAL4:  LSL.W   #4,D1
        OR.W    D1,D2
        MOVE.B  D2,5(A1)
        MOVEM.L (SP)+,D0-D3/A0-A2
        RTS

***********************************
* TRAPS USUELS
***********************************

SETSCREEN:
        MOVE.W  12(A7),D0
        BGE.S   S0SCR
        MOVE.L  4(A7),CH_SCR
        RTS
S0SCR:  MOVE.W  D0,CH_RES
        MOVE.L  4(A7),CH_RES+2
        RTS

SETPALETTE:
        MOVEM.L A0-A1/D0-D1,-(A7)
        MOVE.L  20(A7),A0
        LEA     $DFF180,A1
        MOVEQ   #15,D0
S0PAL:  MOVE.W  (A0)+,D1
        AND.W   #$0777,D1
        ADD.W   D1,D1
        MOVE.W  D1,(A1)+
        DBF     D0,S0PAL
        MOVEM.L (A7)+,A0-A1/D0-D1
        RTS
CH_RES: DC.W    -1
        DC.L    -1
CH_SCR: DC.L    -1
COPPER1:                ;SELECTION
        DC.W    $00E0,$0000,$00E2,$0000                 ;BITPLANE 0
        DC.W    $00E4,$0000,$00E6,$0000
        DC.W    $00E8,$0000,$00EA,$0000
        DC.W    $00EC,$0000,$00EE,$0000
        DC.W    $2C00+$C701,$FF00
        DC.W    $009C,$8010
        DC.W    $FFFF,$FFFE                             ;END OF COPPER LIST

COPPER2:                ;MOYENNE RESOLUTION
        DC.W    $00E0,$0000,$00E2,$0000                 ;BITPLANE 0
        DC.W    $00E4,$0000,$00E6,$0000
        DC.W    $0180,$0000,$0182,$0235*2
        DC.W    $0184,$0720*2,$0186,$0455*2
        DC.W    $2C00+$1101,$FF00
        DC.W    $0182,$0000
        DC.W    $2C00+$A901,$FF00
        DC.W    $0182,$0455*2
        DC.W    $0186,$0235*2
        DC.W    $2C00+$C701,$FF00
        DC.W    $009C,$8010
        DC.W    $FFFF,$FFFE                             ;END OF COPPER LIST

COPPER3:                ;GAME
        DC.W    $00E0,$0000,$00E2,$0000                 ;BITPLANE 0
        DC.W    $00E4,$0000,$00E6,$0000
        DC.W    $00E8,$0000,$00EA,$0000
        DC.W    $00EC,$0000,$00EE,$0000
PBANN:
        DC.W    $0180,$0000,$0182,$0000
        DC.W    $0184,$0000,$0186,$0000
        DC.W    $0188,$0000,$018A,$0000
        DC.W    $018C,$0000,$018E,$0000
        DC.W    $0190,$0000,$0192,$0000
        DC.W    $0194,$0000,$0196,$0000
        DC.W    $0198,$0000,$019A,$0000
        DC.W    $019C,$0000,$019E,$0000
        DC.W    $2C00+$4301,$FF00
PGAME:
        DC.W    $0182,$0000
        DC.W    $0184,$0000,$0186,$0000
        DC.W    $0188,$0000,$018A,$0000
        DC.W    $018C,$0000,$018E,$0000
        DC.W    $0190,$0000,$0192,$0000
        DC.W    $0194,$0000,$0196,$0000
        DC.W    $0198,$0000,$019A,$0000
        DC.W    $019C,$0000,$019E,$0000
        DC.W    $2C00+$C701,$FF00
        DC.W    $009C,$8010
        DC.W    $FFFF,$FFFE        ;END OF COPPER LIST

palban: dc.l    BANPAL+2
palgam: dc.l    CRCPAL+2
CHRPAL: DC.L    -1
        DC.L    -1
ADSOMB: DS.W    15*2

TIMVBL   DC.L     0
FSLAMOD:    DC.W    0
OLDCOM:     DC.W    0
*********************
*  GESTION CLAVIER  *
*********************
*
* Buffer Clavier
*
* 0 = bouton  (0=Rien, 1=Souris G, 2=Souris D ou Fire, 3=1+2)
* 2 = X Mouse
* 4 = Y Mouse
* 6 = ScanCode Clavier 
* 8 = Joystick 
* 10= N/A
* 12= flag pour souris lente

* CNVACSI - Convert to ASCII Routine
* Input :        D0.W Contains ScanCode

CNVASCI MOVEQ    #0,D6
        move.l   #TASCII,A0
        btst     #7,D0
        bne.s    CNVASC1
        move.b   0(A0,D0),D6
CNVASC1 rts

TASCII
        DC.B    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
        DC.B    'A','Z','E','R','T','Y','U','I','O','P',' ',' ',' ',' ',' ',' '
        DC.B    'Q','S','D','F','G','H','J','K','L','M',' ',' ',' ',' ',' ',' '
        DC.B    ' ','W','X','C','V','B','N',' ',' ',' ',' ',' ',' ',' ',' ',' '
        DC.B    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
        DC.B    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
        DC.B    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
        DC.B    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '

              END   
