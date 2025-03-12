* COFICA VERSION - AUG 92

;**** module d'initialisation utilise une seule fois puis ecrase ****


**** CA VIENT DE VR1 ****

         INCLUDE  "EQU.ASM"

         XREF     LOW,SCAFIL,ASCORES,SCRFIL,RSCORES     * VR1
         XREF     CRCOBJ,NEWGAM0,INIGAM

         XREF     JOY,ASCORE,MGAME
         XREF     ACTSCR,CURSCR
         XREF     MESSAG
         XREF     SYNC,OLDCOUNT,COPPER1,VR1VBL,VR2VBL,DUMMY,RTRES0
         XREF     INTER2,INTER3,INTER4,INTER6

         XREF     SETPALETTE,F1PAL
         
* References to Items in ITSL (Selection File)

*         XREF     FST,SND,TRD,FOTH,FITH,SITH,SETH,HETH,NITH,ALPHA
*         XREF     BOX,FULBOX,CLRBOX,OFFBOX
*         XREF     STARTER,ARCADE,RACING,TRAIN,DEMON
*         XREF     NOCOMM,LOCAL,MINITEL,MODEM
*         XREF     ALL,GP1,GP2,GP3,GP4,GP5,GP6
*         XREF     LAPS1,LAPS2,LAPS3,LAPS4,LAPS5,LAPS6,LAPS7,LAPS8,LAPS9,LAPS10 
*         XREF     MANUAL,AUTO,JOYS,MOUS
*         XREF     WORLD,DRIVERS,BEST,LAPL,GP,TOTAL,TOT
*         XREF     NO1,NO2,NO3,NO4,NO5,NO6
*         XREF     ALPMED1,ALPMED2,NUMMED1,NUMMED2
*         XREF     NUMSCO,NUMSCR,BESTS,LIBEL
         XREF     WING,STAR,LET1,LET2,LET3

* References to VR2

         XREF     CRCNUM,CRCMAX,MAXLAP,SAVLAP
         XREF     CAR1PAS,CAR2PAS
         XREF     GAME          - DM15JUL - Init Gaz in VR2

* References to SUBx

         XREF     CNVASCI,INIHBL,INIMHBL,EXIHBL,admodr
         XREF     AMIGA
         XREF     RD0FIL,RD1FIL,RD2FIL,RD0IMA,RD1IMA,WR1FIL
         XREF     TTNUM,TENUM,TIMNUM
         XREF     OCCUR,CARSRT
         XREF     COPSCR,ERASCR
         XREF     FLIPFLOP,SWPSCR
         XREF     DSPITN,DSPITN0
         XREF     SENDIR,DISCON,CONSLA,CONMAS,PNTRECE,BUFRECE  
         XREF     INISCL,INSADIG
         XREF     nolog,rdlog,tabobj,adhaut

         XREF     SYS_VAR,SAV_SYSTEME

PLANEQU  EQU      (ITDVLEN+ITSKLEN)/4

START
        LEA      SYS_VAR,A0     ;sauve vars systeme pour acces disk
        JSR      SAV_SYSTEME

*        MOVE.L  #INTER1,INTER1-4
*        MOVE.L  #FIFI,A0
*        MOVE.L  #INTER1-4,A1
*        MOVE.L  #TIMVBL,D1
*        SUB.L     #INTER1,D1
*        JSR     WR2FIL
*         MOVE.L   TABTAB,A0 
*         MOVE.L   #TCHAMP,A1     .
*         JSR      RD0FIL          .
*GUGU:        NOP
*        BRA.S   GUGU
*FIFI:   DC.B    'VRAMI.PRG',0,0,0
* Set "Unvisible" Screen to Screen #1

DEB     MOVE.L    #SCR1EQU,CURSCR
        CLR.L     ACTSCR

* Install communication + ECRAN + INTERRUP

         BSR      INICON

         MOVE     #-1,SYNC       Say not synchronized
         CLR      PNTRECE


* FORMULA 1 SCREEN AND FILE LOADING
***********************************

* Set Black Palette             COFICA

         LEA.L    F1PAL+2,A0    F1PAL est … 0
         MOVE.L   A0,-(A7)      *
         JSR      SETPALETTE    * CD29/07/91
         ADDQ     #4,A7         * CD29/07/91

* Read ACCID File into ACCEQU - COFICA 
                  
         MOVE.L   ACCFIL,A0      COFICA
         MOVE.L   #0,A1      
         MOVE.L   #ACCEQU,A2
         MOVE.L   #COMEQU,A3
         JSR      RD0IMA

         MOVE.L   #WRKEQU,A1    SCR1EQU
         MOVE.L   #ACCEQU,A5
         MOVE.L   #PLANEQU,D1
         JSR      AMIGA

* Read F1 File into Screen #2 (COFICA File into COFEQU)
                  
RCOF     MOVE.L   F1FIL,A0      COFICA
         LEA.L    F1PAL,A1      
         MOVE.L   #COFEQU,A2
         MOVE.L   #COMEQU,A3
         JSR      RD0IMA

         MOVE.L   #SCR1EQU,A1
         MOVE.L   #COFEQU,A5
         MOVE.L   #8000,D1
         JSR      AMIGA

* Read Score File into SCORES

         MOVE.L   SCAFIL,A0     Arcade
         LEA.L    ASCORES,A1
         MOVE.L   #108,D1
         JSR      RD1FIL

         MOVE.L   SCRFIL,A0     Racing
         LEA.L    RSCORES,A1
         MOVE.L   #154,D1        
         JSR      RD1FIL

* Read ROUTE Table File in JLLEQU and Initialisation 


         MOVE.L   ROTFIL,A0
         MOVE.L   #JLLEQU,A1
         JSR      RD0FIL
         MOVE.L   #JLLEQU+JLLEN1,admodr


        move.w  #1338,d0
        move.l  #JLLEQU+2050+8000,a0
        move.l  #JLLEQU+JLLEN1,a1
        move.l  #JLLEQU+JLLEN1+2678,a2
bi3v    move.w  (a0)+,d1
        lsr.w   #6,d1
        addq.w  #2,a0
        move.b  d1,(a1)+
        move.w  #256,d2
        sub.w   d1,d2
        cmp.w   #256,d2
        bne.s   sbi3v
        move.w  #255,d2
sbi3v   move.b  d2,-(a2)
        dbf     d0,bi3v


* Read COMMON ST Items

         MOVE.L   ITSTFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #ITSTEQU,A2
         MOVE.L   #COMEQU,A3
         JSR      RD0IMA

         JSR      INIOVR         Init front Cars over Retro

* Read Divers Objetcs File and Sky Objects

         MOVE.L   ITDVFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #ITDVEQU,A2
         MOVE.L   #COMEQU,A3
         JSR      RD0IMA

         MOVE.L   ITSKFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #ITSKEQU,A2
         MOVE.L   #COMEQU,A3
         JSR      RD0IMA

         MOVE.L   #BCKEQU,A1
         MOVE.L   #ITDVEQU,A5
         MOVE.L   #PLANEQU,D1
         JSR      AMIGA
         
* CALCUL MASK ITDV ET ITSK
         MOVE.L   #ITDVEQU,A0
         MOVE.L   #PLANEQU,D1
         LEA.L    0(A0,D1.W),A1
         LEA.L    0(A1,D1.W),A2
         LEA.L    0(A2,D1.W),A3
         LEA.L    0(A3,D1.W),A4
         LSR.W    #1,D1
         SUBQ.W   #1,D1
BCMADV:  MOVE.W   (A0)+,D0
         OR.W     (A1)+,D0
         OR.W     (A2)+,D0
         OR.W     (A3)+,D0
         MOVE.W   D0,(A4)+
         DBF      D1,BCMADV

* Read (FRONT CAR, Retro, Tiges) File

         MOVE.L   ITCRFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #BCKEQU,A2
         MOVE.L   #COMEQU,A3
         JSR      RD0IMA

* Read Tires File

         MOVE.L   ITTIFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #BCKEQU+ITCRLEN,A2
         MOVE.L   #COMEQU+30000,A3      Special!
         JSR      RD0IMA

* Init CAR/RERO/TIRES and TIGES 
* in ITCTEQU pointed by A4

         JSR      INICAR         Init Car/tires/Retro 
         JSR      meptig         Init Tiges


* Read Script File

         BRA      COFICA2
         
         MOVE.L   ITSCFIL,A0
         MOVE.L   #0,A1
         MOVE.L   CURSCR,A2
         MOVE.L   #COMEQU,A3
         JSR      RD0IMA

         MOVE.L   #ITSCEQU,A4    Interleave Script
         MOVE.L   CURSCR,A0
         JSR      INTER      
 
* Read Son

         MOVE.L   #COMEQU,CRCOBJ
         MOVE.L   MUSGEN,A0
         MOVE.L   #ITSCEQU+6400,A1      MODAMI
         JSR      RD0FIL
         MOVE.L   #ITSCEQU+6400,A0   DEMAR MUS MODAMI
         JSR      (A0)

* Copy "Visible" Screen into "Unvisible" Screen 

CPSCR    JSR      COPSCR

* Init Script Panning (in Both Screens)

         MOVE.L   #ITSCEQU+160,SCPADR Init SCPADR with Top Address of Script
         CLR.W    SCPINC         Init SCPINC

* Wait Loop with Script Panning

WLOOP
         CLR      JOY
         MOVE     #3,D0          Init Loop Counters - DM14JUL
WLOOP0   MOVE     D0,-(A7)        
         MOVE     #$4F0,D1       1 Pan = $4F0 - DM14JUL
WLOOP1   MOVE     D1,-(A7)

* Pan Script at Bottom of Screen

PANS     
         JSR      PANSCP         Pan Script
PANSF


* Twinckle Stars on VROOM

TWIN     
         LEA.L    TWINCKL1,A0
         MOVE.L   (A0),D0
         ROL.L    #1,D0
         MOVE.L   D0,(A0)
         BPL.S    TWIN1
         LEA.L    STAR,A5        Display Star if LT
         MOVE.L   #177,10(A5)
         MOVE.L   #177,14(A5)         
         JSR      DSPITN0        
         BRA.S    TWIN2 
TWIN1    LEA.L    LET1,A5        Display Letter 1 Otherwise
         JSR      DSPITN0 
TWIN2    LEA.L    TWINCKL2,A0
         MOVE.L   (A0),D0
         ROL.L    #1,D0
         MOVE.L   D0,(A0)
         BPL.S    TWIN3
         LEA.L    STAR,A5        Display Star if LT
         MOVE.L   #225,10(A5)
         MOVE.L   #225,14(A5)         
         JSR      DSPITN0        
         BRA.S    TWIN4 
TWIN3    LEA.L    LET2,A5        Display Letter 2 Otherwise
         JSR      DSPITN0
TWIN4    LEA.L    TWINCKL3,A0
         MOVE.L   (A0),D0
         ROL.L    #1,D0
         MOVE.L   D0,(A0)
         BPL.S    TWIN5
         LEA.L    STAR,A5        Display Star if LT
         MOVE.L   #298,10(A5)
         MOVE.L   #298,14(A5)         
         JSR      DSPITN0        
         BRA.S    TWINF 
TWIN5    LEA.L    LET3,A5        Display Letter 2 Otherwise
         JSR      DSPITN0
TWINF

* Display Wing on Script

WIN      LEA.L    WING,A5
         JSR      DSPITN0

* Joystick Input (Fire Button)

FEU      CLR      D3
         BTST     #$1,JOY+1      Fire?
         BEQ.S    FLIP           If EQ, Stay in WLOOP
         TST.L    (A7)+          Restore Stack
         MOVE.L   #ITSCEQU+6400,A0      MODAMI
         JSR      4(A0)
COFICA2  BSR      OBJBAS
         CLR.L    MESSAG
         BRA      NEWGAM0        Leave WLOOP

* Flip-Flop "Invisible"/"Visible" Screens

FLIP     JSR      FLIPFLOP

* End of WLOOP

         MOVE     (A7)+,D1
         DBF      D1,WLOOP1
         MOVE     (A7)+,D0
         DBF      D0,WLOOP0
*         JSR      ACTDEM         
         MOVE.L   #16,MGAME      Say DEMO
         MOVE.L   #ITSCEQU+6400,A0      MODAMI
         JSR      4(A0)
         BSR      OBJBAS
         BRA      INIGAM         

OBJBAS:
* Read Echantillon Base

         MOVE.L   SMPFIL,A0      Read Sample File
         MOVE.L   #COMEQU,A1     .
         JSR      RD0FIL          .
* Sound Initialisation

         JSR      inison
        
         MOVE.L   TABTAB,A0 
         MOVE.L   #TCHAMP,A1     .
         JSR      RD0FIL          .

* Read Table Objets Logiques

         MOVE.L   LOGFIL,A0
         MOVE.L   #LOGEQU,A1
         JSR      RD0FIL

* Read Common Objects File

         MOVE.L   #COMEQU,adhaut
         MOVEQ    #0,D1
BCHOBI:  MOVE.W   D1,nolog
         MOVE.W   D1,-(A7)
         JSR      rdlog
         MOVE.W   (A7)+,D1
         ADDQ.W   #1,D1
         CMP.W    #23,D1
         BLT.S    BCHOBI
         MOVE.L   adhaut,CRCOBJ
         RTS

SMPFIL   DC.L     1

TABTAB   DC.L     2

F1FIL    DC.L     3             F1 File

ROTFIL   DC.L     4

ITSTFIL  DC.L     5             ST File (INIOVR Treatment)

ITDVFIL  DC.L     6             Divers Objects (ACCID) File (AMIGA Treatment)

ITSKFIL  DC.L     7             Sky  AMIGA File (AMIGA Treatment)

ITCRFIL  DC.L     8             Car/retro/tiges File (INICAR Treatment)

ITTIFIL  DC.L     9             Tires File (INICAR Treatment)

ITSCFIL  DC.L     10            Script File (INTER/AMIGA Treatment)

MUSGEN   DC.L     11

LOGFIL   DC.L     14

ACCFIL   DC.L     15

* F1PAL    DS.B     2              F1 Screen
F1PAL0   DS.B     32

* Script

SCPADR   DS.L     1     Pointer to Script
SCPINC   DC.W     0     Bit increment From SCRADR


TWINCKL1 DC.L  $7       Star 1 Twinckle
TWINCKL2 DC.L  $E000000 Star 2 Twinckle
TWINCKL3 DC.L  $E000    Star 3 Twinckle

**** CA VIENT DE SYSTEM ****

         XREF     SENDIT,R1CIEV,tab_clav
         XREF     FLGENV

INICON:
         MOVE.L   #DUMMY,VR2VBL+2
         MOVE.L   #RTRES0,VR1VBL+2
         CLR      FLGENV
         MOVE     #1472,SERPER    ;/1 start/8 donnees/1 stop/
         move.l   #JOY,tab_clav

                MOVE.W          #$03E0,DMACONW

                LEA             CUSTOM,A0
                MOVE.W          #$4200,BPLCON0(A0) ;4 plans lowrez
                MOVE.W          #$2C81,DIWSTRT(A0) ;
                MOVE.W          #$F4C1,DIWSTOP(A0) ;
                MOVE.W          #$0038,DDFSTRT(A0) ;data start
                MOVE.W          #$00D0,DDFSTOP(A0) ;data stop
                MOVE.W          #0,BPL1MOD(A0)     ;modulo
                MOVE.W          #0,BPL2MOD(A0)     ;modulo

                LEA             COPPER1+2,A1
                MOVE.L          #SCR2EQU,D0
                MOVE.W          D0,4(A1)
                SWAP            D0
                MOVE.W          D0,(A1)
                MOVE.L          #SCR2EQU+8000,D0
                MOVE.W          D0,4+8(A1)
                SWAP            D0
                MOVE.W          D0,8(A1)
                MOVE.L          #SCR2EQU+16000,D0
                MOVE.W          D0,4+16(A1)
                SWAP            D0
                MOVE.W          D0,16(A1)
                MOVE.L          #SCR2EQU+24000,D0
                MOVE.W          D0,4+24(A1)
                SWAP            D0
                MOVE.W          D0,24(A1)

                MOVE.L          #$DFF180,A0
                MOVE.W          #15,D0
BEFSC:          CLR.W           (A0)+
                DBF             D0,BEFSC

                MOVE.L          #COPPER1,COP1LCH
                MOVE.L          #-1,BLTAFWM+$DFF000
                MOVE.W          #$83C0,DMACONW
                MOVE.W          #$0400,DMACONW

INITINTER:
                MOVE.W  #$7FFF,INTENA
                MOVE.W  JOY0DAT,D0
                CLR.W   D1
                MOVE.B  D0,D1
                MOVE.W  D1,OLDCOUNT+2
                LSR.W   #8,D0
                MOVE.W  D0,OLDCOUNT
                LEA     $64,A1
                LEA     SENDIT,A0
                MOVE.L  A0,(A1)+
                LEA     INTER2,A0
                MOVE.L  A0,(A1)+
                LEA     INTER3,A0
                MOVE.L  A0,(A1)+
                LEA     INTER4,A0
                MOVE.L  A0,(A1)+
                LEA     R1CIEV,A0
                MOVE.L  A0,(A1)+
                LEA     INTER6,A0
                MOVE.L  A0,(A1)+
                MOVE.W  #$C819,INTENA
                RTS

***********************************
*  GESTION DU SON - J.L Langlois  *
***********************************

        XREF    ecvid,adcri,adbon,accid,adbrbl,mot1,mot2

fich:   equ     COMEQU
zone:   equ     SNDEQU
echbd:  equ     fich+5112
tailbd: equ     1538
echcr:  equ     fich+2112
tailcr: equ     2882
echac:  equ     fich+6712
tailac: equ     7736
tailbb: equ     2654
echbb:  equ     fich+6712+7736

echn:   equ     fich+912
tmot1:  equ     1166
tmot2:  equ     582

inison:
        move.l  #SNDEQU+8000,a1
;chargt table freq amiga
        move.w  #205,d0
        move.l  #fich,a0
bramig: move.w  (a0)+,(a1)+
        dbf     d0,bramig

;moteur1
        move.l  a1,mot1
        move.l  #echn,a0
        move.w  #tmot1-1,d0
bmot1:  move.b  (a0)+,(a1)
        bchg    #7,(a1)+
        dbf     d0,bmot1

;moteur2
        move.l  a1,mot2
        move.l  mot1,a0
        move.w  #tmot2-1,d0
bmot2:  move.b  (a0)+,(a1)+
        addq.w  #1,a0
        dbf     d0,bmot2

;echant vide
        move.l  a1,ecvid
        move.w  #49,d0
bvid:   clr.w   (a1)+
        dbf     d0,bvid

;criss
        move.l  #echcr,a0
        move.w  #tailcr,d0
        subq.w  #1,d0
        move.l  a1,adcri
bcri:   move.b  (a0)+,(a1)
        bchg    #7,(a1)+
        dbf     d0,bcri

;bond
        move.l  #echbd,a0
        move.w  #tailbd,d0
        subq.w  #1,d0
        move.l  a1,adbon
bbon:   move.b  (a0)+,(a1)
        bchg    #7,(a1)+
        dbf     d0,bbon

;accident
        move.l  #echac,a0
        move.w  #tailac,d0
        subq.w  #1,d0
        move.l  a1,accid
bacci:  move.b  (a0)+,(a1)
        bchg    #7,(a1)+
        dbf     d0,bacci

;bruit blanc
        move.l  #echbb,a0
        move.w  #tailbb,d0
        subq.w  #1,d0
        move.l  a1,adbrbl
bbrbl:  move.b  (a0)+,(a1)
        bchg    #7,(a1)+
        dbf     d0,bbrbl

        RTS

**** CA VIENT DE SUB1 ****
         
* INTER - Interleave Background for Panning
* INPUT : A0 Points to Source Zone
*         A4 Points to Target Zone

INTER:  MOVE.L  A0,A6
        MOVEQ   #3,D6
B0SCL:  MOVE.W  #8-1,D0   ;NB LIGNE
BINSCL: MOVE.L   A0,A2
        MOVE.W  #19,D1
B1SCL:  MOVE.W  (A2)+,(A4)+
        ADDQ.W  #6,A2
        DBF     D1,B1SCL
        LEA.L   160*7(A2),A2
        MOVE.W  #19,D1
B2SCL:  MOVE.W  (A2)+,(A4)+
        ADDQ.W  #6,A2
        DBF     D1,B2SCL
        LEA.L   160*7(A2),A2
        MOVE.W  #19,D1
B3SCL:  MOVE.W  (A2)+,(A4)+
        ADDQ.W  #6,A2
        DBF     D1,B3SCL
        LEA.L   160*7(A2),A2
        MOVE.W  #19,D1
B4SCL:  MOVE.W  (A2)+,(A4)+
        ADDQ.W  #6,A2
        DBF     D1,B4SCL
        MOVE.L   A0,A2
        MOVE.W  #19,D1
B5SCL:  MOVE.W  (A2)+,(A4)+
        ADDQ.W  #6,A2
        DBF     D1,B5SCL
        LEA.L   160(A0),A0
        DBF     D0,BINSCL
        LEA.L   2(A6),A6
        MOVE.L  A6,A0
        DBF     D6,B0SCL
        RTS

* PANSCP- Pan Background Routine


PANSCP: LEA.L   SCPADR(PC),A5  ;Get Pointer to BCK and INC (2)
        MOVE.L  (A5),A1      ;Get SCPADR Content
        MOVEQ   #0,D5
        MOVE.W  4(A5),D5       ;Get SCPINC Content (0 TO 15)
        SUBQ.W    #1,D5
        BPL.S   PANBCK16
PANBCK13: LEA.L  2(A1),A1
        CMPA.L  #ITSCEQU+160,A1
        BLE.S   PANBCK14       ;If PL, No
        LEA.L   -160(A1),A1
PANBCK14: ADD    #16,D5

PANBCK16: MOVE.L    A1,(A5) 
        MOVE.W  D5,4(A5)

* Display
        MOVE.W  #8,D0
        LSL.W   #6,D0
        OR.W    #21,D0
        ROR.L   #4,D5
        OR.L    #$09F00000,D5
        MOVE.L    #TSCPEQU,A0
        LEA.L     280-2(A0),A0
        ADD.L     CURSCR,A0
        LEA.L     1400-2(A1),A1
        MOVE.L   #$DFF000,A6
        MOVE.W  #$8400,$96(A6)
R0B0:   BTST    #6,2(A6)
        BNE.S   R0B0
        MOVE.L  #-1,BLTAFWM(A6)
        MOVE.L  A1,BLTAPTH(A6)
        MOVE.L  A0,BLTDPTH(A6)
        MOVE.W  #-242,BLTAMOD(A6)
        MOVE.W  #-82,BLTDMOD(A6)
        MOVE.L  D5,BLTCON0(A6)
        MOVE.W  D0,BLTSIZE(A6)
        ADD.W   #200*8,A1
        LEA.L   8000(A0),A0
        
R0B1:   BTST    #6,2(A6)
        BNE.S   R0B1
        MOVE.L  A1,BLTAPTH(A6)
        MOVE.L  A0,BLTDPTH(A6)
        MOVE.W  D0,BLTSIZE(A6)
        ADD.W   #200*8,A1
        LEA.L   8000(A0),A0

R0B2:   BTST    #6,2(A6)
        BNE.S   R0B2
        MOVE.L  A1,BLTAPTH(A6)
        MOVE.L  A0,BLTDPTH(A6)
        MOVE.W  D0,BLTSIZE(A6)
        ADD.W   #200*8,A1
        LEA.L   8000(A0),A0
        
R0B3:   BTST    #6,2(A6)
        BNE.S   R0B3
        MOVE.L  A1,BLTAPTH(A6)
        MOVE.L  A0,BLTDPTH(A6)
        MOVE.W  D0,BLTSIZE(A6)
       
R0B4:   BTST    #6,2(A6)
        BNE.S   R0B4
        MOVE.W    #$400,96(A6)
        MOVE.L    #TSCPEQU,A0
        ADD.L     CURSCR,A0
        CLR.W     -(A0)
        CLR.W     8000(A0)
        CLR.W     16000(A0)
        CLR.W     24000(A0)

        RTS

**** CA VIENT DE SUB7 ****

        XREF    ttail,hgauch,tgauch,tgauch1,hdroit,tdroit,tdroit1
        XREF    lampa,lampaf,hpot,tpot

*INIT TIGE
meptig: lea.l   ttail,a0
        moveq   #0,d0
        moveq   #0,d3
        move.w  #15,d1
btail:  move.w  d3,(a0)+
        addq.w  #4,d0
        move.w  d0,d3
        add.w   -2(a0),d3
        dbf     d1,btail
        
        move.l  #BCKEQU+13440,a0    ;ecran voiture
        move.l  a4,a1   ;adr chrgt
        move.l  a1,hgauch
        move.w  #15,d0
btig1:  move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
        move.w  d0,d2
        eor.b   #$0f,d2
        move.w  d2,d3
        mulu    #160,d3
        add.l   d3,a2
atig1:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -160(a2),a2
        dbf     d2,atig1
        dbf     d0,btig1

        add.l   #160*16,a0
        move.l  a1,tgauch
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig2:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig2

        add.l   #160*1,a0
        move.l  a1,tgauch1
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig21: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig21

        add.l   #160*1,a0
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig22: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig22

        add.l   #160*1,a0
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig23: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig23

        add.l   #160*1,a0
        move.l  a1,hdroit
        move.w  #15,d0
btig3:  move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
        move.w  d0,d2
        eor.b   #$0f,d2
        move.w  d2,d3
        mulu    #160,d3
        add.l   d3,a2
atig3:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -160(a2),a2
        dbf     d2,atig3
        dbf     d0,btig3

        add.l   #160*16,a0
        move.l  a1,tdroit
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig4:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig4

        add.l   #160*1,a0
        move.l  a1,tdroit1
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig41: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig41

        add.l   #160*1,a0
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig42: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig42

        add.l   #160*1,a0
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig43: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig43

        add.l   #160*1,a0
        move.l  a1,lampa
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig5:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig5

        add.l   #160*1,a0
        move.l  a1,lampaf
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig5f: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig5f

        add.l   #160*1,a0
        move.l  a1,hpot
        move.w  #5,d0
btig6:  move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
        move.w  #5,d2
        sub.w   d0,d2
        move.w  d2,d3
        mulu    #160,d3
        add.l   d3,a2
atig6:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -160(a2),a2
        dbf     d2,atig6
        dbf     d0,btig6

        add.l   #160*6,a0
        move.l  a1,tpot
        move.w  #5,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig7:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig7
        rts

**** CA VIENT DE SUB5 ****

        XREF    RETCAR,AFICAR,ADVOIT
HRTEQU   EQU      8
LRTEQU   EQU      1

*
* INICAR - Initialize Car, Retro, Tires
* 

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

INICAR: MOVE.L  #TRACLI,A4
        MOVE.W  #27-1,D0
BTRA0:  CLR.L   (A4)+
        DBF     D0,BTRA0
        MOVE.W  #27-1,D0
BTRA1:  MOVE.L  #-1,(A4)+
        DBF     D0,BTRA1
        MOVE.W  #18-1,D0
BTRA2:  CLR.L   (A4)+
        DBF     D0,BTRA2
        MOVE.W  #18-1,D0
BTRA3:  MOVE.L  #-1,(A4)+
        DBF     D0,BTRA3
         MOVE.L #BCKEQU,A0
         LEA.L   OFVOIT(PC),A2
         LEA.L   ADVOIT,A5
         MOVE.W #6,D0
BINIV:   MOVE.L A4,(A5)+
         MOVE.L A0,A1
         ADD.W   (A2)+,A1
         LEA.L   -160*27(A1),A1
         MOVEM.L  A0/A2/A3/A5/D0,-(SP)
         BSR     CHVOI
         MOVEM.L  (SP)+,A0/A2/A3/A5/D0
         DBF     D0,BINIV
;*************INIT RETRO G ET D
         MOVE.L A4,(A5)+
         MOVE.L A0,A1
         ADD.W    (A2)+,A1
         LEA.L   -160*12(A1),A1
         MOVEM.L  A0/A2/A3/A5/D0,-(SP)
         BSR            INIRET1
         MOVEM.L  (SP)+,A0/A2/A3/A5/D0
         MOVE.L A4,(A5)+
         MOVE.L A0,A1
         ADD.W    (A2)+,A1
         LEA.L   -160*12(A1),A1
         MOVEM.L  A0/A2/A3/A5/D0,-(SP)
         BSR            INIRET1
         MOVEM.L  (SP)+,A0/A2/A3/A5/D0
;********* INIT PNEU
         MOVE.L #BCKEQU+ITCRLEN,A0
         MOVE.W #9-1,D0
BINIPB: MOVE.L  A4,(A5)+
         MOVE.L A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A5/D0,-(SP)
         MOVE.W #12-1,D0
         BSR            INIPCR
         MOVEM.L  (SP)+,A0/A2/A5/D0
         DBF            D0,BINIPB
         MOVE.W #36-1,D0
BINIPA: MOVE.L  A4,(A5)+
         MOVE.L A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A5/D0,-(SP)
         MOVE.W #13-1,D0
         BSR            INIPCR
         MOVEM.L  (SP)+,A0/A2/A5/D0
         DBF            D0,BINIPA
         MOVE.W #14-1,D0
BINIPC: MOVE.L  A4,(A5)+
         MOVE.L A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A5/D0,-(SP)
         MOVE.W #13-1,D0
         BSR            INIPCR
         MOVEM.L  (SP)+,A0/A2/A5/D0
         DBF            D0,BINIPC
         MOVE.W #2-1,D0
BINIPI: MOVE.L  A4,(A5)+
         MOVE.L A0,A1
         ADD.W    (A2)+,A1
         MOVEM.L  A0/A2/A5/D0,-(SP)
         MOVE.W #20-1,D0
         BSR            INIPCR
         MOVEM.L  (SP)+,A0/A2/A5/D0
         DBF            D0,BINIPI
        RTS

CHVOI:   ;A4 ADR DE CHARG  A1 ADR ECRAN
         MOVEQ    #28-1,D0
INIVOI2:  MOVEQ #5,D4
INIVOI3:  MOVE.W          (A1)+,D5
         MOVE.W  D5,(A4)
         MOVE.W  (A1),12*28(A4)
         OR.W     (A1)+,D5
         MOVE.W  (A1),24*28(A4)
         OR.W     (A1)+,D5
         MOVE.W  (A1),36*28(A4)
         OR.W     (A1)+,D5
         NOT.W    D5
         MOVE.W  D5,48*28(A4)
         ADDQ.W  #2,A4
         DBF      D4,INIVOI3
         LEA.L    112(A1),A1
         DBF      D0,INIVOI2
         LEA.L    48*28(A4),A4
         RTS

INIPCR: MOVE.W  D0,D2
        ADDQ.W  #1,D2
        MULU    #6,D2
        MOVE.W  D2,D3
        ADD.W   D3,D3
INIPC0: MOVEQ   #2,D1
IPCR:   MOVEM.W (A1)+,D4-D7
        OR.W    D4,D5
        OR.W    D6,D5
        OR.W    D7,D5
        NOT.W   D5
        MOVE.W  D5,0(A4,D3.W)
        MOVE.W  D7,0(A4,D2.W)
        MOVE.W  D4,(A4)+
        DBF     D1,IPCR
        LEA.L   160-24(A1),A1
        DBF     D0,INIPC0
        ADD.W   D3,A4
        RTS

INIRET1:  ;A4 ADR DE CHARG  A1 ADR ECRAN
         MOVEQ    #13-1,D0
INIRET2:  MOVEQ #1,D4
INIRET3:  MOVE.W          (A1)+,D5
         MOVE.W  D5,(A4)
         MOVE.W  (A1),4*13(A4)
         OR.W     (A1)+,D5
         MOVE.W  (A1),8*13(A4)
         OR.W     (A1)+,D5
         MOVE.W  (A1),12*13(A4)
         OR.W     (A1)+,D5
         NOT.W    D5
         MOVE.W  D5,16*13(A4)
         ADDQ.W  #2,A4
         DBF      D4,INIRET3
         LEA.L    144(A1),A1
         DBF      D0,INIRET2
         LEA.L    16*13(A4),A4
         RTS
         
* INIOVR - Init Overpassed Car in Retro XOR 
*        No Input
*
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

        END

