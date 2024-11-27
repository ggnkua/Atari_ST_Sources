***             TRALALA V1. COFICA 29 AUG 92                   ***
*
                XDEF    RD0FIL,RD1FIL,RD2FIL,RD3FIL
                XDEF    WR1FIL,WR2FIL

                XDEF    SYS_VAR,SAV_SYSTEME

         INCLUDE  "EQU.ASM"

;***  Conserve anciens registres et vecteurs dans adr pointee par A0 ***

SAV_SYSTEME:
        LEA         $64,A1          ;vecteurs d'interruption
        MOVE.L      (A1)+,(A0)+
        MOVE.L      (A1)+,(A0)+
        MOVE.L      (A1)+,(A0)+
        MOVE.L      (A1)+,(A0)+
        MOVE.L      (A1)+,(A0)+
        MOVE.L      (A1)+,(A0)+

        MOVE        DMACONR,(A0)+   ;registres indispensables
        MOVE        INTENAR,(A0)+
        MOVE        INTREQR,(A0)+
        CLR         -2(A0)
        MOVE        ADKCONR,(A0)+

        MOVE        #$7fff,INTENA
        RTS

;***  Remet anciens registres et vecteurs a partir adr pointee par A0 ***

MET_SYSTEME:
        MOVE        #$7fff,DMACONW
        MOVE        #$7fff,INTENA
        MOVE        #$7fff,INTREQ
        MOVE        #$7fff,ADKCONW

        LEA         $64,A1          ;vecteurs d'interruption
        MOVE.L      (A0)+,(A1)+
        MOVE.L      (A0)+,(A1)+
        MOVE.L      (A0)+,(A1)+
        MOVE.L      (A0)+,(A1)+
        MOVE.L      (A0)+,(A1)+
        MOVE.L      (A0)+,(A1)+

        MOVE        (A0)+,D0
        BSET        #15,D0
        MOVE        D0,DMACONW
        MOVE        (A0)+,D0
        BSET        #15,D0
        MOVE        D0,INTENA
        MOVE        (A0)+,D0
        BSET        #15,D0
        MOVE        D0,INTREQ
        MOVE        (A0)+,D0
        BSET        #15,D0
        MOVE        D0,ADKCONW

        RTS

INITDOS:
        MOVEM.L     D0-D7/A0-A6,-(A7)

        LEA         GAME_VAR,A0         ;sauve variables du jeu
        BSR         SAV_SYSTEME

        LEA         SYS_VAR,A0          ;et remet variables systeme
        BSR         MET_SYSTEME

        TST         FLAGDOS
        BNE.S       IN0DOS
        MOVE        #1,FLAGDOS

        MOVE.L      EXECBASE,A6         ;ouvre librairie dos 
        LEA         DOSNAME,A1
        JSR         OLDOPENLIB(A6)
        MOVE.L      D0,DOSBASE

;        MOVE.L      EXECBASE,A6         ;allocation memoire
;        MOVE.L      #BUF_LEN,D0
;        MOVE.L      #MEMF_CHIP,D1
;        JSR         ALLOCMEM(A6)
;        MOVE.L      D0,XBUFFER
;        MOVE.L      DOSBASE,A6

IN0DOS: 
        MOVEM.L     (A7)+,D0-D7/A0-A6
        RTS

EXITDOS:
        MOVEM.L     D0-D7/A0-A6,-(A7)

        LEA         GAME_VAR,A0
        BSR         MET_SYSTEME

        MOVEM.L     (A7)+,D0-D7/A0-A6
        RTS

FLAGDOS:
        DC.W        0
SYS_VAR:
        DS.L        10
GAME_VAR:
        DS.L        10

;*** LECTURE OBJETS NORMAUX COMPRESSES HUFFMANN 1 PAR 1 ***
;***            A0 = NUM DE FICHIER
;***            A1 = ADR OU CHARGER
RD0FIL:
    MOVE.L  A0,D0
    LSL     #2,D0
    LEA     TABNOM,A0
    MOVE.L  0(A0,D0.W),D0
    MOVE.L  A1,adr_cur
    BSR     READ1FIC
    RTS

;*** LECTURE  FICHIERS NON COMPRESSES (SAUVEGARDES ET SCORES) ***
;***            A0 = NUM DE FICHIER
;***            A1 = ADR OU CHARGER
;***            D1 = LONGUEUR
RD1FIL:
    MOVE.L  A0,D0
    LSL     #2,D0
    LEA     TABNORM,A0
    MOVE.L  0(A0,D0.W),D0
    MOVE.L  A1,adr_cur
    MOVE.L  D1,src_len
    BSR     READ2FIC
    RTS

;*** ECRITURE FICHIERS NON COMPRESSES (SAUVEGARDES ET SCORES) ***
;***            A0 = NUM DE FICHIER
;***            A1 = ADR OU SAUVER
;***            D1 = LONGUEUR
WR1FIL:
    MOVE.L  A0,D0
    LSL     #2,D0
    LEA     TABNORM,A0
    MOVE.L  0(A0,D0.W),D0
    MOVE.L  A1,adr_cur
    MOVE.L  D1,src_len
    BSR     WRT2FIC
    RTS

;*** ECRITURE FICHIERS PROVISOIRE POUR DEMO ***
;***            A0 = NOM DE FICHIER
;***            A1 = ADR OU SAUVER
;***            D1 = LONGUEUR
WR2FIL:
    MOVE.L  A0,D0
    MOVE.L  A1,adr_cur
    MOVE.L  D1,src_len
    BSR     WRT2FIC
    RTS

;*** LECTURE CIRCUITS ***
;***            D0 = NUM DE CIRCUIT (0 -> 20 STEP 4)
;***            A0 = NUM DE OBJET   (0 -> 4)
;***            A1 = ADR CHARGE
RD2FIL:
    LEA     TABCRC(PC),A2
    MULU    #5,D0
    LEA     0(A2,D0.W),A2
    MOVE.L  A0,D0
    LSL     #2,D0
    MOVE.L  0(A2,D0.W),D0
    MOVE.L  A1,adr_cur
    BSR     READ1FIC
    RTS


;*** LECTURE OBJETS PHYSIQUES ***
;***            D0 = NUM OBJET
;***            A0 = ADR CHARGE
RD3FIL:
        lea.l   nob+1(pc),a1
        move.w  #2,d1
        jsr     ecrit
        move.l  #nob,D0
        MOVE.L  A0,adr_cur
        BSR     READ1FIC
        RTS

nob:    dc.b    "O***.PHY"
        dc.b    0
        CNOP    0,2
ecrit:  divu    #10,d0
        move.l  d0,d2
        swap    d2
        andi.l  #$0000ffff,d0
        addi.b  #48,d2
        move.b  d2,0(a1,d1.w)
        dbf     d1,ecrit
        rts


;*** LECTURE PROVISOIRE 1 ***
READ1FIC:
        MOVEM.L D0-D7/A0-A6,-(A7)

        BSR     INITDOS

        MOVE.L  DOSBASE,A6
        BSR     MAKEREP

        MOVE.L  #OLDMODE,D2
        JSR     OPEN(A6)
        MOVE.L  D0,src_hdl

        MOVE.L  src_hdl,D1
        MOVEQ   #0,D2
        MOVEQ   #1,D3
        JSR     LSEEK(A6)

        MOVE.L  src_hdl,D1
        MOVEQ   #0,D2
        MOVEQ   #-1,D3
        JSR     LSEEK(A6)
        MOVE.L  D0,src_len

        MOVE.L  src_hdl,D1
        MOVE.L  adr_cur,D2
        MOVE.L  src_len,D3
        JSR     READ(A6)

        MOVE.L  src_hdl,D1
        JSR     CLOSE(A6)

        BSR     EXITDOS

        MOVEM.L (A7)+,D0-D7/A0-A6
        RTS

;*** LECTURE PROVISOIRE 2 ***
READ2FIC:
        MOVEM.L D0-D7/A0-A6,-(A7)

        BSR     INITDOS

        MOVE.L  DOSBASE,A6
        BSR     MAKEREP
        
        MOVE.L  #OLDMODE,D2
        JSR     OPEN(A6)
        MOVE.L  D0,src_hdl

        MOVE.L  src_hdl,D1
        MOVE.L  adr_cur,D2
        MOVE.L  src_len,D3
        JSR     READ(A6)
    
        MOVE.L  src_hdl,D1
        JSR     CLOSE(A6)

        BSR     EXITDOS

        MOVEM.L (A7)+,D0-D7/A0-A6
        RTS

;*** SAUVEGARDE PROVISOIRE 2 ***
WRT2FIC:
        MOVEM.L D0-D7/A0-A6,-(A7)

        BSR     INITDOS

        MOVE.L  DOSBASE,A6
        BSR     MAKEREP

        MOVE.L  #OLDMODE,D2
        JSR     OPEN(A6)
        MOVE.L  D0,src_hdl

        MOVE.L  src_hdl,D1
        MOVE.L  adr_cur,D2
        MOVE.L  src_len,D3
        JSR     WRITE(A6)
    
        MOVE.L  src_hdl,D1
        JSR     CLOSE(A6)

        BSR     EXITDOS

        MOVEM.L (A7)+,D0-D7/A0-A6
        RTS

MAKEREP:
                movem.l a0-a1,-(a7)
                move.l  d0,a0
                lea     nomfichier(pc),a1
makerep0:       move.b  (a0)+,(a1)+
                bne.s   makerep0
                move.l  #repertoire,d1
                movem.l (a7)+,a0-a1
                rts

repertoire:     dc.b    'dH0:D_VROOM/'
nomfichier:     dc.b    '12345678.123',0
         CNOP     0,2
src_hdl:        dc.l    0
src_len:        dc.l    0
adr_cur:        dc.l    0
                  
TABNORM:
        DC.L    SCAFIL,SCRFIL,SAV1FIL,SAV2FIL,SAV3FIL,SAV4FIL,SAV5FIL
        DC.L    SAV6FIL,SAV7FIL,SAV8FIL,SAV9FIL
TABNOM:
        DC.L    0,SMPFIL,TABTAB,F1FIL,ROTFIL,ITSTFIL,ITDVFIL,ITSKFIL
        DC.L    ITCRFIL,ITTIFIL,ITSCFIL,MUSGEN,ITSLFIL,VROFIL,LOGFIL,ACCFIL
TABCRC:
        DC.L    CR1BCK,CR1DAT,CR1DEM,CR1BAN,CR1ADAT
        DC.L    CR2BCK,CR2DAT,CR2DEM,CR2BAN,CR2ADAT
        DC.L    CR3BCK,CR3DAT,CR3DEM,CR3BAN,CR3ADAT
        DC.L    CR4BCK,CR4DAT,CR4DEM,CR4BAN,CR4ADAT
        DC.L    CR5BCK,CR5DAT,CR5DEM,CR5BAN,CR5ADAT
        DC.L    CR6BCK,CR6DAT,CR6DEM,CR6BAN,CR6ADAT

SCAFIL   DC.B     'ARCADE.DAT'   Arcade Score
         DC.B     0
         CNOP     0,2

SCRFIL   DC.B     'RACING.DAT'   Racing Score
         DC.B     0
         CNOP     0,2

SAV1FIL  DC.B     'SAV1.DAT'     Save Racing
         DC.B     0
         CNOP     0,2
SAV2FIL  DC.B     'SAV2.DAT'     Save Racing
         DC.B     0
         CNOP     0,2
SAV3FIL  DC.B     'SAV3.DAT'     Save Racing
         DC.B     0
         CNOP     0,2
SAV4FIL  DC.B     'SAV4.DAT'     Save Racing
         DC.B     0
         CNOP     0,2
SAV5FIL  DC.B     'SAV5.DAT'     Save Racing
         DC.B     0
         CNOP     0,2
SAV6FIL  DC.B     'SAV6.DAT'     Save Racing
         DC.B     0
         CNOP     0,2
SAV7FIL  DC.B     'SAV7.DAT'     Save Racing
         DC.B     0
         CNOP     0,2
SAV8FIL  DC.B     'SAV8.DAT'     Save Racing
         DC.B     0
         CNOP     0,2
SAV9FIL  DC.B     'SAV9.DAT'     Save Racing
         DC.B     0
         CNOP     0,2

ROTFIL   DC.B     'ROUTE.DAT'
         DC.B     0
         CNOP     0,2

F1FIL    DC.B     'F1.DAT'      F1 File
         DC.B     0
         CNOP     0,2

ITSCFIL  DC.B     'ITSC.DAT'    Script File (INTER/AMIGA Treatment)
         DC.B     0
         CNOP     0,2

ITSLFIL  DC.B     'ITSL.DAT'    Selection (AMIGA Treatment)
         DC.B     0
         CNOP     0,2

ITSTFIL  DC.B     'ITST.DAT'    ST File (INIOVR Treatment)
         DC.B     0
         CNOP     0,2

ITDVFIL  DC.B     'ITDV.DAT'    Divers Objects (ACCID) File (AMIGA Treatment)
         DC.B     0
         CNOP     0,2

ITSKFIL  DC.B     'ITSK.DAT'    Sky  AMIGA File (AMIGA Treatment)
         DC.B     0
         CNOP     0,2

ITCRFIL  DC.B     'ITCR.DAT'    Car/retro/tiges File (INICAR Treatment)
         DC.B     0
         CNOP     0,2

ITTIFIL  DC.B     'ITTI.DAT'    Tires File (INICAR Treatment)
         DC.B     0
         CNOP     0,2

SMPFIL   DC.B     'ECVR.DAT'
         DC.B     0
         CNOP     0,2

TABTAB   DC.B     'MODTAB.DAT'
         DC.B     0
         CNOP     0,2

VROFIL   DC.B     'VROO.DAT'    MODJLL
         DC.B     0
         CNOP     0,2

LOGFIL   DC.B     'OBJ.LOG'
         DC.B     0
         CNOP     0,2

ACCFIL   DC.B     'ACCID.DAT'
         DC.B     0
         CNOP     0,2
         
MUSGEN   DC.B     'GENERI.DAT'
         DC.B     0
         CNOP     0,2

CRCOBJ   DC.L     0             Loading Ad for Objetcs Unique to Circuit

CR1BCK   DC.B     'BCK1.DAT'
         DC.B     0
         CNOP     0,2

CR2BCK   DC.B     'BCK2.DAT'
         DC.B     0
         CNOP     0,2

CR3BCK   DC.B     'BCK3.DAT'
         DC.B     0
         CNOP     0,2

CR4BCK   DC.B     'BCK4.DAT'
         DC.B     0
         CNOP     0,2

CR5BCK   DC.B     'BCK5.DAT'
         DC.B     0
         CNOP     0,2

CR6BCK   DC.B     'BCK6.DAT'
         DC.B     0
         CNOP     0,2

CR1BAN   DC.B     'BAN1.DAT'
         DC.B     0
         CNOP     0,2

CR2BAN   DC.B     'BAN2.DAT'
         DC.B     0
         CNOP     0,2

CR3BAN   DC.B     'BAN3.DAT'
         DC.B     0
         CNOP     0,2

CR4BAN   DC.B     'BAN4.DAT'
         DC.B     0
         CNOP     0,2

CR5BAN   DC.B     'BAN5.DAT'
         DC.B     0
         CNOP     0,2

CR6BAN   DC.B     'BAN6.DAT'
         DC.B     0
         CNOP     0,2

CR1DAT   DC.B     'CRC1.DAT'
         DC.B     0
         CNOP     0,2

CR2DAT   DC.B     'CRC2.DAT'
         DC.B     0
         CNOP     0,2

CR3DAT   DC.B     'CRC3.DAT'
         DC.B     0
         CNOP     0,2

CR4DAT   DC.B     'CRC4.DAT'
         DC.B     0
         CNOP     0,2

CR5DAT   DC.B     'CRC5.DAT'
         DC.B     0
         CNOP     0,2

CR6DAT   DC.B     'CRC6.DAT'
         DC.B     0
         CNOP     0,2


CR1ADAT  DC.B     'CRC1A.DAT'
         DC.B     0
         CNOP     0,2

CR2ADAT  DC.B     'CRC2A.DAT'
         DC.B     0
         CNOP     0,2

CR3ADAT  DC.B     'CRC3A.DAT'
         DC.B     0
         CNOP     0,2

CR4ADAT  DC.B     'CRC4A.DAT'
         DC.B     0
         CNOP     0,2

CR5ADAT  DC.B     'CRC5A.DAT'
         DC.B     0
         CNOP     0,2

CR6ADAT  DC.B     'CRC6A.DAT'
         DC.B     0
         CNOP     0,2

CR1DEM   DC.B     'DEM1.DAT'
         DC.B     0
         CNOP     0,2

CR2DEM   DC.B     'DEM2.DAT'
         DC.B     0
         CNOP     0,2

CR3DEM   DC.B     'DEM3.DAT'
         DC.B     0
         CNOP     0,2

CR4DEM   DC.B     'DEM4.DAT'
         DC.B     0
         CNOP     0,2

CR5DEM   DC.B     'DEM5.DAT'
         DC.B     0
         CNOP     0,2

CR6DEM   DC.B     'DEM6.DAT'
         DC.B     0
         CNOP     0,2

DOSNAME:        DC.B            'dos.library',0
         CNOP     0,2
DOSBASE:        DC.L            0
        END

