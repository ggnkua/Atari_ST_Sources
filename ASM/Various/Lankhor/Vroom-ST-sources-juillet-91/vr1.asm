         TTL      VROOM 1 - Initial Layout - V15 - 20 JuL 91 

*DM23JUL : Nouveau Tri selon Points + Classements
*DM25JUL : Save 3 Sky Events

         INCLUDE  "TOS.ASM"
         INCLUDE  "EQU.ASM"

         XDEF     START,JOY,CRCPAL,CRCPIL0,BANPAL,BANPIL0
         XDEF     NEWGAM,NEWCRC,ARCSCR,RACSCR
         XDEF     ASCORE,ASCODIG
         XDEF     TOTTIM,LAPTIM,BSTTIM,TIMDIG
         XDEF     MGAME,MCOMM,MPLAY,MLAPS,MCONT,MGEAR
         XDEF     ACTSCR,SCRADR,CURSCR
         XDEF     MESSAG,MSGESC,MSGLOS
         XDEF     SYNC,MASLAV
         
* References to Items in ITSL (Selection File)

         XREF     FST,SND,TRD,FOTH,FITH,SITH,SETH,HETH,NITH,ALPHA
         XREF     BOX,FULBOX,CLRBOX,OFFBOX
         XREF     STARTER,ARCADE,RACING,TRAIN,DEMON
         XREF     NOCOMM,LOCAL,MINITEL,MODEM
         XREF     ALL,GP1,GP2,GP3,GP4,GP5,GP6
         XREF     LAPS1,LAPS2,LAPS3,LAPS4,LAPS5,LAPS6,LAPS7,LAPS8,LAPS9,LAPS10 
         XREF     MANUAL,AUTO,JOYS,MOUS
         XREF     WORLD,DRIVERS,BEST,LAPL,GP,TOTAL,TOT
         XREF     NO1,NO2,NO3,NO4,NO5,NO6
         XREF     ALPMED1,ALPMED2,NUMMED1,NUMMED2
         XREF     NUMSCO,NUMSCR,BESTS,LIBEL
         XREF     WING,STAR,LET1,LET2,LET3

* References to VR2

         XREF     CRCNUM,CRCMAX,MAXLAP,SAVLAP,DEMBLD
         XREF     CAR1PAS,CAR2PAS
         XREF     GAME          - DM15JUL - Init Gaz in VR2

* References to SUBx

         XREF     INICLAV,CNVASCI,inison,INIHBL,INIMHBL,EXIHBL,admodr
         XREF     PANSCP,INTER,RDFIL,RDIMA,WRFIL,AMIGA
         XREF     TTNUM,TENUM,TIMNUM
         XREF     INICAR,INIOVR,OCCUR,CARSRT
         XREF     DSPPRO,DSPVRO,PRFCAR,VROOM,COPSCR,ERASCR
         XREF     DSPGRD,FLIPFLOP,SWPSCR
         XREF     DSPITN,DSPITN0,DSPSCO,DSPMED,DSPMSG,DSPLAP,DSPSTG
         XREF     LIBARC,LIBRAC,LIBQAL,LIBTRA,LIBDEM,CMPNXT,RDEVT
         XREF     DSPINI,INPINI,DSPDRV,INPDRV,DSPTIM,DSPTMR,DSPGP
         XREF     INICON
         XREF     SENDIR,DISCON,CONSLA,CONMAS,PNTRECE,BUFRECE  
         XREF     INISCL,INSADIG
         XREF     nolog,rdlog,tabobj,meptig,adhaut

PLANEQU  EQU      (ITDVLEN+ITSKLEN)/4

* Start of Program

NO3C     DC.W     0             DM23JUL

START

* Install communication + Set Supervisor Mode 

         JSR      INICON
         MOVE     #-1,SYNC       Say not synchronized
         MOVE     #0,PNTRECE

* Joystick & Mouse Trapping

         JSR      INICLAV

* Read Echantillon Base

         LEA.L    SMPFIL,A0      Read Sample File
         MOVE.L   #COMEQU,A1     .
         MOVE.L   #15000,D1      .
         JSR      RDFIL          .
         BMI      ERR

         LEA.L    TABTAB,A0      Read Sample File
         MOVE.L   #TCHAMP,A1     .
         MOVE.L   #4100,D1      .
         JSR      RDFIL          .
         BMI      ERR

* Sound Initialisation

         JSR      inison

* FORMULA 1 SCREEN AND FILE LOADING
***********************************

* Set "Unvisible" Screen to Screen #1
         
DEB     MOVE.L    #SCR1EQU,CURSCR
        CLR.L     ACTSCR

* Read F1 File into Screen #2 

RF1      LEA.L    F1FIL,A0
         LEA.L    F1PAL,A1
         MOVE.L   #SCR2EQU,A2
         MOVE.L   #32000,D2
         MOVE.L   #COMEQU,A3
         JSR      RDIMA
         BMI      ERR

* Set F1 Palette

         LEA.L    F1PAL0,A0     *
         MOVE.L   A0,-(A7)      *
         TOS      SETPALETTE,14 *
         ADDQ.L   #6,A7         *
*         MOVE.L   #F1PAL0,$45A   Set F1 Palette

* Set Low resolution

          BSR      LOW

* Set Screen Address to Visible Screen with F1 in Low Resolution

          MOVE     #-1,-(A7)      *
          MOVE.L   #SCR2EQU,-(A7) *
          MOVE.L   #SCR2EQU,-(A7) *
          TOS      SETSCREEN,14   *
          ADD.L    #12,A7         *
*         LEA.L    CURSCR,A0       .
*         MOVE.B   1(A0),$FFFF8201 .
*         MOVE.B   2(A0),$FFFF8203 .


* Read Score File into SCORES

         LEA.L    SCAFIL,A0     Arcade
         LEA.L    ASCORES,A1
         MOVE.L   #108,D1
         JSR      RDFIL
         BMI      ERR

         LEA.L    SCRFIL,A0     Racing
         LEA.L    RSCORES,A1
         MOVE.L   #154,D1        
         JSR      RDFIL
         BMI      ERR

* Read ROUTE Table File in JLLEQU and Initialisation 

         LEA.L    ROTFIL,A0
         MOVE.L   #JLLEQU,A1
         MOVE.L   #JLLEN1,D1     
         JSR      RDFIL
         BMI      ERR
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

         LEA.L    ITSTFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #ITSTEQU,A2
         MOVE.L   #ITSTLEN,D2
         MOVE.L   #COMEQU,A3
         JSR      RDIMA
         BMI      ERR

         JSR      INIOVR         Init front Cars over Retro

* Read Divers Objetcs File and Sky Objects

         LEA.L    ITDVFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #ITDVEQU,A2
         MOVE.L   #ITDVLEN,D2
         MOVE.L   #COMEQU,A3
         JSR      RDIMA
         BMI      ERR

         LEA.L    ITSKFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #ITSKEQU,A2
         MOVE.L   #ITSKLEN,D2
         MOVE.L   #COMEQU,A3
         JSR      RDIMA
         BMI      ERR

         MOVE.L   #BCKEQU,A1
         MOVE.L   #ITDVEQU,A5
         MOVE.L   #PLANEQU,D1
         JSR      AMIGA

* Read (FRONT CAR, Retro, Tiges) File

         LEA.L    ITCRFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #BCKEQU,A2
         MOVE.L   #ITCRLEN,D2
         MOVE.L   #COMEQU,A3
         JSR      RDIMA
         BMI      ERR

* Read Tires File

         LEA.L    ITTIFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #BCKEQU+ITCRLEN,A2
         MOVE.L   #ITTILEN,D2
         MOVE.L   #COMEQU+30000,A3      Special!
         JSR      RDIMA
         BMI      ERR

* Init CAR/RERO/TIRES and TIGES 
* in ITCTEQU pointed by A4

         JSR      INICAR         Init Car/tires/Retro 
         JSR      meptig         Init Tiges

* Read Script File

         LEA.L    ITSCFIL,A0
         MOVE.L   #0,A1
         MOVE.L   #ITSCEQU,A2
         MOVE.L   #ITSCLEN,D2
         MOVE.L   #COMEQU,A3
         JSR      RDIMA
         BMI      ERR

         MOVE.L   #ITSCEQU,A0    Interleave Script
         MOVE.L   CURSCR,A1      Working Zone (Other Screen)
         MOVE     #HSCPEQU,D1    # of Lines per Background
         MOVEQ    #4,D3
         JSR      INTER      
 
         MOVE.L   CURSCR,A1
         MOVE.L   #ITSCEQU,A5
         MOVE.L   #ITSCLEN/4,D1
         JSR      AMIGA

* Read Son
         MOVE.L   #COMEQU,CRCOBJ    MODJLL
         LEA.L    MUSGEN,A0
         MOVE.L   CRCOBJ,A1
         MOVE.L   #126261,D1
         JSR      RDFIL
*         BMI      ERR
         MOVE.L   CRCOBJ,A0   DEMAR MUS
         JSR      (A0)

* Copy "Visible" Screen into "Unvisible" Screen 

CPSCR    JSR      COPSCR

* Init Script Panning (in Both Screens)

         LEA.L    SCPSIM,A1      Init SCPEND with Pseudo Mem
         MOVE.L   A1,SCPEND      .
         MOVE.L   #ITSCEQU+0/4,SCPADR Init SCPADR with Top Address of Script
         CLR.W    SCPINC         Init SCPINC

* Wait Loop with Script Panning

WLOOP
         CLR      JOY
         MOVE     #4,D0          Init Loop Counters - DM14JUL
WLOOP0   MOVE     D0,-(A7)        
         MOVE     #$4F0,D1       1 Pan = $4F0 - DM14JUL
WLOOP1   MOVE     D1,-(A7)

* Pan Script at Bottom of Screen

PANS     LEA.L    SCPEND,A4      Get Pointer to END,BCK and INC
         MOVE.L   #TSCPEQU,A0    Pointer to Top of Script in Screen
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
         MOVE.L   CRCOBJ,A0      COUPE MUS
         JSR      4(A0)
         BSR      OBJBAS
         CLR.L    MESSAG
         BRA      NEWGAM0        Leave WLOOP

* Flip-Flop "Invisible"/"Visible" Screens

FLIP     JSR      FLIPFLOP

* End of WLOOP

         MOVE     (A7)+,D1
         DBF      D1,WLOOP1
         MOVE     (A7)+,D0
         DBF      D0,WLOOP0
         BSR      ACTDEM         
         MOVE.L   #16,MGAME      Say DEMO
         MOVE.L   CRCOBJ,A0      COUPE MUS
         JSR      4(A0)
         BSR      OBJBAS
         BRA      INIGAM         

* NEW GAME ENTRY (OR RE-ENTRY FROM GAME OVER)
*********************************************

         
NEWGAM   BSR      RDSEL
         JSR      SWPSCR
         BRA.S    NEWGAM1
NEWGAM0  BSR      RDSEL          Read Selection File
NEWGAM1  TST      MCOMM+2
         BLE.S    NEWGAM2
         TST      SYNC           Back from log 1 or log 2 
         BLE.S    NEWGAM2
         CLR.W    SYNC           Say Physically Connected Only
NEWGAM2  CLR.W    PNTRECE

* GAME OPTIONS SELECTION SCREEN
*******************************

         BSR      BLACK          Set Black Palette
         JSR      INIHBL         .
         
*  Erase (Black) "Invisible" Screen

         JSR      ERASCR

* Move 3 Lines in "Invisible" Screen
         
         MOVE.L   CURSCR,A0
         ADDA.L   #51*160,A0
         MOVE.L   #ITSLEQU+111*160/4+136/4,A1
         MOVE     #20-1,D0
LIN1     MOVE     (A1),(A0)+
         MOVE     1*PLANEQU(A1),(A0)+
         MOVE     2*PLANEQU(A1),(A0)+
         MOVE     3*PLANEQU(A1),(A0)+
         DBF      D0,LIN1
         ADDA.L   #40,A1
         MOVE     #20-1,D0
LIN2     MOVE     (A1),(A0)+
         MOVE     1*PLANEQU(A1),(A0)+
         MOVE     2*PLANEQU(A1),(A0)+
         MOVE     3*PLANEQU(A1),(A0)+
         DBF      D0,LIN2
         ADDA.L   #40,A1
         MOVE     #20-1,D0
LIN3     MOVE     (A1),(A0)+
         MOVE     1*PLANEQU(A1),(A0)+
         MOVE     2*PLANEQU(A1),(A0)+
         MOVE     3*PLANEQU(A1),(A0)+
         DBF      D0,LIN3

* Copy "Invisible" Screen to "Visible" Screen (Black + 3 Lines)
         
         EORI.L   #4,ACTSCR      Reverse "Visible"/"Invisible" for COPSCR
         JSR      COPSCR         Copy Screens
         EORI.L   #4,ACTSCR      Restore "Invisible" Screen

         JSR      EXIHBL        

* Set Select Scree n Palette

          LEA.L    SCOPAL0,A0     *
          MOVE.L   A0,-(A7)       *
          TOS      SETPALETTE,14  *
          ADDQ.L   #6,A7          *
*         MOVE.L   #SCOPAL0,$45A  Set New Palette

* Message Processing
        
         MOVE.L   MESSAG,D0
         BEQ.S    MESF
         MOVE.L   D0,A0
         JSR      DSPMSG
         BSR      TEMPO
         LEA.L    MSGBLK,A0
         JSR      DSPMSG
MESF     CLR.L    MESSAG

* Display Panning Car (in Both Screens)

VROM
         MOVE.L   CRCOBJ,A1     .MODJLL
         ADD.L    #PLANEQU*5,A1
         JSR      (A1)          .

         LEA.L    PRFCAR,A5      Display Car 
         JSR      DSPPRO         .
         LEA.L    VROOM,A5       Display VROOM 
         JSR      DSPVRO         .

* Display Options in "Invisible" Screen 

         LEA.L    BOX,A5          START
         MOVE.L   CSTAR,D0
         SUBQ     #1,D0 
         MOVE.L   D0,10(A5)
         MOVE.L   D0,14(A5)
         MOVE.L   CSTAR+4,D0
         ADD.L    #160,D0
         MOVE.L   D0,(A5)
         MOVE.L   D0,4(A5)
         JSR      DSPITN0
         LEA.L    FULBOX,A5 
         MOVE.L   CSTAR,10(A5)
         MOVE.L   CSTAR,14(A5)
         MOVE.L   CSTAR+4,(A5)
         MOVE.L   CSTAR+4,4(A5)
         JSR      DSPITN0
         LEA.L    STARTER,A5      Start
         JSR      DSPITN0

         LEA.L    BOX,A5          GAME/RACING/TRAIN/DEMO
         MOVE.L   CGAME,D0
         SUBQ     #1,D0 
         MOVE.L   D0,10(A5)
         MOVE.L   D0,14(A5)
         MOVE.L   CGAME+4,D0
         ADD.L    #160,D0
         MOVE.L   D0,(A5)
         MOVE.L   D0,4(A5)
         JSR      DSPITN0
         LEA.L    CLRBOX,A5     
         MOVE.L   CGAME,10(A5)
         MOVE.L   CGAME,14(A5)
         MOVE.L   CGAME+4,(A5)
         MOVE.L   CGAME+4,4(A5)
         JSR      DSPITN0
         MOVE.L   MGAME,D0
         LEA.L    AGAME,A0      
         MOVE.L   4(A0,D0),A5
         JSR      DSPITN0

         LEA.L    BOX,A5          COMMS
         MOVE.L   CCOMM,D0
         SUBQ     #1,D0 
         MOVE.L   D0,10(A5)
         MOVE.L   D0,14(A5)
         MOVE.L   CCOMM+4,D0
         ADD.L    #160,D0
         MOVE.L   D0,(A5)
         MOVE.L   D0,4(A5)
         JSR      DSPITN0
         LEA.L    OFFBOX,A5
         TST.L    MCOMM
         BLT.S    CC1
         LEA.L    CLRBOX,A5     
CC1      MOVE.L   CCOMM,10(A5)
         MOVE.L   CCOMM,14(A5)
         MOVE.L   CCOMM+4,(A5)
         MOVE.L   CCOMM+4,4(A5)
         JSR      DSPITN0
         MOVE.L   MCOMM,D0
         ANDI.L   #$7FFFFFFF,D0
         LEA.L    ACOMM,A0      
         MOVE.L   4(A0,D0),A5
         JSR      DSPITN0

         LEA.L    BOX,A5          ALL/GP
         MOVE.L   CPLAY,D0
         SUBQ     #1,D0 
         MOVE.L   D0,10(A5)
         MOVE.L   D0,14(A5)
         MOVE.L   CPLAY+4,D0
         ADD.L    #160,D0
         MOVE.L   D0,(A5)
         MOVE.L   D0,4(A5)
         JSR      DSPITN0
         LEA.L    OFFBOX,A5
         TST.L    MPLAY
         BLT.S    CP1
         LEA.L    CLRBOX,A5     
CP1      MOVE.L   CPLAY,10(A5)
         MOVE.L   CPLAY,14(A5)
         MOVE.L   CPLAY+4,(A5)
         MOVE.L   CPLAY+4,4(A5)
         JSR      DSPITN0
         MOVE.L   MPLAY,D0
         ANDI.L   #$7FFFFFFF,D0
         LEA.L    APLAY,A0      
         MOVE.L   4(A0,D0),A5
         JSR      DSPITN0

         LEA.L    BOX,A5          LAPS
         MOVE.L   CLAPS,D0
         SUBQ     #1,D0 
         MOVE.L   D0,10(A5)
         MOVE.L   D0,14(A5)
         MOVE.L   CLAPS+4,D0
         ADD.L    #160,D0
         MOVE.L   D0,(A5)
         MOVE.L   D0,4(A5)
         JSR      DSPITN0
         LEA.L    OFFBOX,A5
         TST.L    MLAPS
         BLT.S    CL1
         LEA.L    CLRBOX,A5     
CL1      MOVE.L   CLAPS,10(A5)
         MOVE.L   CLAPS,14(A5)
         MOVE.L   CLAPS+4,(A5)
         MOVE.L   CLAPS+4,4(A5)
         JSR      DSPITN0
         MOVE.L   MLAPS,D0
         ANDI.L   #$7FFFFFFF,D0
         LEA.L    ALAPS,A0      
         MOVE.L   4(A0,D0),A5
         JSR      DSPITN0

         LEA.L    BOX,A5          JOYSTICK/MOUSE
         MOVE.L   CCONT,D0
         SUBQ     #1,D0 
         MOVE.L   D0,10(A5)
         MOVE.L   D0,14(A5)
         MOVE.L   CCONT+4,D0
         ADD.L    #160,D0
         MOVE.L   D0,(A5)
         MOVE.L   D0,4(A5)
         JSR      DSPITN0
         LEA.L    OFFBOX,A5
         TST.L    MCONT
         BLT.S    CJ1     
         LEA.L    CLRBOX,A5
CJ1      MOVE.L   CCONT,10(A5)
         MOVE.L   CCONT,14(A5)
         MOVE.L   CCONT+4,(A5)
         MOVE.L   CCONT+4,4(A5)
         JSR      DSPITN0
         MOVE.L   MCONT,D0
         ANDI.L   #$7FFFFFFF,D0
         LEA.L    ACONT,A0      
         MOVE.L   4(A0,D0),A5
         JSR      DSPITN0

         LEA.L    BOX,A5          AUTO/MANUAL
         MOVE.L   CGEAR,D0
         SUBQ     #1,D0 
         MOVE.L   D0,10(A5)
         MOVE.L   D0,14(A5)
         MOVE.L   CGEAR+4,D0
         ADD.L    #160,D0
         MOVE.L   D0,(A5)
         MOVE.L   D0,4(A5)
         JSR      DSPITN0
         LEA.L    CLRBOX,A5      ClrBox
         MOVE.L   CGEAR,10(A5)
         MOVE.L   CGEAR,14(A5)
         MOVE.L   CGEAR+4,(A5)
         MOVE.L   CGEAR+4,4(A5)
         JSR      DSPITN0
         MOVE.L   MGEAR,D0
         LEA.L    AGEAR,A0      
         MOVE.L   4(A0,D0),A5
         JSR      DSPITN0

* Display Boxes in Scrolling Mode in "Visible" Screen

DSPWT    LEA.L    ACTSCR,A5      Get "Invisible" Screen Address
         MOVE.L   (A5),D6        .
         MOVE.L   4(A5,D6),A0    .
         ADDA.L   #60*160,A0     .
         MOVE.L   D6,D7          Get "Visible" Screen Address
         EORI.L   #4,D7          .
         MOVE.L   4(A5,D7),A1    .
         ADDA.L   #60*160,A1     .
         MOVE     #140-1,D0 140-20 Lines
DSPWT0   MOVE     #40-1,D1
DSPWT1   MOVE.L   (A0)+,(A1)+    Display Lines
         DBF      D1,DSPWT1      Tempo
         MOVE     #3000,D2       .
DSPWT2   DBF      D2,DSPWT2
         DBF      D0,DSPWT0      Next Line

* Joystick Selection (Direct work in "Visible" Screen)

         JSR      SWPSCR         Reverse "Visible"/"Invisible" Screens
         MOVE     #-1,OSYNC      Assume Not yet Physically Connected 
         TST      SYNC
         BLT.S    SEL0   
         MOVE     #0,OSYNC       Say Physically Connected
SEL0     MOVE.L   #FSTAR,BOXI    Init BOXI

SEL      CLR      JOY+2
         CLR      JOY+4
SEL1     CLR.L    D0
         MOVE.L   BOXI,A0
         TST.B    JOY+1          Fire?
         BNE      FIR            
         TST      MCOMM+2        
         BLE.S    SEL4          
         TST      SYNC           Comm Mode
         BGT.S    SEL            Loop on Start if Logical Connect 1
         TST      OSYNC          Test If Comm Lost 
         BLT.S    SEL4           .
         TST      SYNC           .
         BLT      COMSET5A       If LT, Lost 
SEL4    
         MOVE     JOY+8,D0       Joystick Move
         BNE.S    SEL13          If NE, Yes
         CMPI     #35,JOY+2      Mouse X
         BPL.S    SEL5
         CMPI     #-35,JOY+2     
         BLT.S    SEL6     
         BRA.S    SEL7 
SEL5     ADD      #4,D0          
SEL6     ADD      #4,D0         
SEL7     CMPI     #35,JOY+4      Mouse Y
         BPL.S    SEL8
         CMPI     #-35,JOY+4
         BLT.S    SEL9
         BRA.S    SEL10
SEL8     ADD      #1,D0
SEL9     ADD      #1,D0
SEL10    TST      D0
         BNE      SEL13
         MOVE     #1,JOYMOU   
         BRA      SEL18
SEL13    MOVE     #0,JOYMOU
         MOVE.L   D0,D1          Select Joystick
         SUBQ     #1,D1
         LSL      #2,D1         
         ADDA.L   D1,A0
         TST.L    (A0)
         BEQ      SEL18
         MOVE.L   (A0),A2
         TST.L    48(A2)         Test for Locked
         BPL.S    SEL14          If PL, No
         MOVE.L   A2,A0
         BRA.S    SEL13
SEL14    MOVE.L   (A0),-(A7)     Save New BOXI
         LEA.L    CLRBOX,A5      clrBox
         MOVE.L   BOXI,A0
         MOVE.L   40(A0),10(A5)
         MOVE.L   40(A0),14(A5)
         MOVE.L   44(A0),(A5)
         MOVE.L   44(A0),4(A5)
         JSR      DSPITN0
         MOVE.L   BOXI,A0        Label in clrBox
         MOVE.L   48(A0),D0
         MOVE.L   56(A0,D0),A5
         JSR      DSPITN0
         MOVE.L   (A7)+,BOXI     Update BOXI
         LEA.L    FULBOX,A5      FulBox
         MOVE.L   BOXI,A0        
         MOVE.L   40(A0),10(A5)
         MOVE.L   40(A0),14(A5)
         MOVE.L   44(A0),(A5)
         MOVE.L   44(A0),4(A5)
         JSR      DSPITN0
         MOVE.L   BOXI,A0        Label in FulBox
         MOVE.L   48(A0),D0
         MOVE.L   56(A0,D0),A5 
         JSR      DSPITN0
SEL15    MOVE     #8,D1          Waiting Loop
SEL16    MOVE     #32000,D0
SEL17    DBF      D0,SEL17
         DBF      D1,SEL16
         MOVE     #0,JOYMOU
SEL18    JSR      CONSLA
         TST      D0
         BGT      COMSET0       Status = 1 Communication Aborted 
         BLT.S    SEL20         Status = -1
         TST      SYNC          Satus = 0 : Already Physically Connected?
         BNE.S    SEL19         If NE, No
         TST      PNTRECE       Already Physically Connected
         BEQ.S    SEL20         If EQ, No Char Received Yet
         BRA      COMSET4A
SEL19    MOVE     #0,SYNC       Yes, Say Physically Connected                  
         BRA      COMSET4       Slave : Go and Receive Config
SEL20    TST      JOYMOU
         BNE      SEL1    
         BRA      SEL
         
* Fire Input

FIR      MOVE.L   BOXI,A0
         CMPA.L   #FSTAR,A0      Fire to Start?
         BEQ      FIRSTA         If EQ, yes

         MOVE.B   JOY+1,-(A7)
         LEA.L    FULBOX,A5      FulBox 3
         MOVE.L   BOXI,A0
         MOVE.L   40(A0),10(A5)
         MOVE.L   40(A0),14(A5)
         MOVE.L   44(A0),(A5)
         MOVE.L   44(A0),4(A5)
         JSR      DSPITN0
         MOVE.L   BOXI,A0
         MOVE.L   48(A0),D0
         BTST     #1,(A7)+
         BNE.S    FIRUP
FIRDOWN  SUBQ.L   #4,D0
         MOVE.L   52(A0),D1
         BPL.S    FIR0
         SUBQ.L   #4,D0
FIR0     TST.L    D0
         BPL.S    FIR2
         ANDI.L   #$7FFFFFFF,D1
         MOVE.L   D1,D0
         BRA.S    FIR2
FIRUP    ADDQ     #4,D0
         MOVE.L   52(A0),D1
         BPL.S    FIR1
         ADDQ     #4,D0
         ANDI.L   #$7FFFFFFF,D1
FIR1     CMP.L    D1,D0
         BLE.S    FIR2
         MOVEQ    #0,D0
FIR2     MOVE.L   D0,-(A7)
         MOVE.L   D0,48(A0)     New label in FulBox
         MOVE.L   56(A0,D0),A5
         JSR      DSPITN0
         MOVE.L   (A7)+,D0
         MOVE.L   BOXI,A0
         TST      52(A0)
         BPL.S    FIR3
         MOVE.L   60(A0,D0),D1  Action Routine Address?
         BEQ.S    FIR3          If EQ, No
         MOVE.L   D1,A1         Yes
         JSR      (A1)          Execute Action
FIR3     BRA      SEL15

ACTARC  
         BSR      LOCCOM        
         BSR      LOCALL
         MOVE.L   #$80000010,MLAPS Lock on 5 Laps
         BSR      LOCLAP
         BSR      UNLMOU
         BSR      UNLMAN
         RTS

ACTRAC   BSR      UNLCOM            
         BSR      UNLALL
         MOVE.L   #$80000014,MLAPS Lock on 6 Laps
         BSR      LOCLAP
         BSR      LOCMOU
         BSR      UNLMAN
         RTS

ACTDEM   BSR       LOCCOM
         BSR       UNLALL
         MOVE.L    #$80000000,MLAPS Lock on 1 Lap
         BSR       LOCLAP
         BSR       LOCMOU
         BSR       LOCMAN
         RTS
      
ACTTRA   BSR       UNLCOM
         BSR       UNLALL
         BSR       UNLLAP
         BSR       LOCMOU
         BSR       UNLMAN
         RTS

UNLCOM   MOVE.L   #$0,MCOMM        Unlock on Nocomm
         LEA.L    CLRBOX,A5
         BRA.S    LOCCOM0
LOCCOM   MOVE.L   #$80000000,MCOMM Lock on No Comm
         LEA.L    OFFBOX,A5
LOCCOM0  MOVE.L   CCOMM,10(A5)
         MOVE.L   CCOMM,14(A5)
         MOVE.L   CCOMM+4,(A5)
         MOVE.L   CCOMM+4,4(A5)
         JSR      DSPITN0
         LEA.L    NOCOMM,A5    
         JSR      DSPITN0
         RTS

UNLALL   MOVE.L   #$0,MPLAY        Unlock on ALL
         LEA.L    CLRBOX,A5
         BRA.S    LOCALL0
LOCALL   MOVE.L   #$80000000,MPLAY Lock on ALL
         LEA.L    OFFBOX,A5
LOCALL0  MOVE.L   CPLAY,10(A5)
         MOVE.L   CPLAY,14(A5)
         MOVE.L   CPLAY+4,(A5)
         MOVE.L   CPLAY+4,4(A5)
         JSR      DSPITN0
         LEA.L    ALL,A5    
         JSR      DSPITN0
         RTS

UNLLAP   ANDI.L   #$7FFFFFFF,MLAPS  Unlock on Current Lap
         LEA.L    CLRBOX,A5
         BRA.S    LOCLAP0
LOCLAP   LEA.L    OFFBOX,A5         Lock on Lap
LOCLAP0  MOVE.L   CLAPS,10(A5)
         MOVE.L   CLAPS,14(A5)
         MOVE.L   CLAPS+4,(A5)
         MOVE.L   CLAPS+4,4(A5)
         JSR      DSPITN0
         MOVE.L   MLAPS,D0
         ANDI.L   #$7FFFFFFF,D0
         LEA.L    ALAPS,A0
         MOVE.L   4(A0,D0),A5
         JSR      DSPITN0
         RTS
      
UNLMOU   MOVE.L   #$0,MCONT        Unlock on Mouse
         LEA.L    CLRBOX,A5
         BRA.S    LOCMOU0   
LOCMOU   MOVE.L   #$80000000,MCONT Lock on Mouse
         LEA.L    OFFBOX,A5
LOCMOU0  MOVE.L   CCONT,10(A5)
         MOVE.L   CCONT,14(A5)
         MOVE.L   CCONT+4,(A5)
         MOVE.L   CCONT+4,4(A5)
         JSR      DSPITN0
         LEA.L    MOUS,A5    
         JSR      DSPITN0
         RTS

UNLMAN   MOVE.L   #$0,MGEAR        Unlock on Manual
         LEA.L    CLRBOX,A5
         BRA.S    LOCMAN0
LOCMAN   MOVE.L   #$80000000,MGEAR Lock on Manual
         LEA.L    OFFBOX,A5
LOCMAN0  MOVE.L   CGEAR,10(A5)
         MOVE.L   CGEAR,14(A5)
         MOVE.L   CGEAR+4,(A5)
         MOVE.L   CGEAR+4,4(A5)
         JSR      DSPITN0
         LEA.L    MANUAL,A5    
         JSR      DSPITN0
         RTS

FIRSTA

* Communication Establishment/Disconnect (After Fire)

COMSET   TST      MCOMM+2       Any Communication?
         BGT      COMSET1       If GT, Yes
         BRA      COMSETF
COMSET0  LEA.L    MSGABO,A0     Display "Communication Aborted"
         JSR      DSPMSG        DISCON + SYNC = -1 Done By C.Droin
         BSR      TEMPO
         MOVE.L   #0,MCOMM
         BRA      NEWGAM1
COMSET1  TST      SYNC          Comm : Already Established?
         BGT      COMSETF       If LT, Yes Logically 1
         BEQ      COMSET3A      If EQ, Yes Physically
         LEA.L    MSGCOM1,A0    No : Display "Establishing Communication"
         JSR      DSPMSG        .
         JSR      CONMAS        Connect Physically Master
         TST      D0 
         BLT      COMSET5       If LT, UnSuccessful Physical Connection 
         
*
* Succesful Physical Communication Established MASTER
*
COMSET3  MOVE     #0,SYNC       Say Physically Comm Established      
         LEA.L    MSGCOM2,A0    Display "Communication Established"
         JSR      DSPMSG        .             
         BSR      TEMPO
COMSET3A LEA.L    CONFIG,A0     Send Config Over The Net
         MOVE.L   MGAME,(A0)
         MOVE.L   MCOMM,4(A0)
         MOVE.L   MPLAY,8(A0)
         MOVE.L   MLAPS,12(A0)
         MOVE.L   MCONT,16(A0)
         MOVE     #20,D0
         JSR      SENDIR
         MOVE     #1,MASLAV     Say Master DM18JUL
         MOVE     #1,SYNC
         BRA      NEWGAM2
*
* Succesful Physical Communication Established SLAVE
*
COMSET4  MOVE     #0,PNTRECE
         MOVE     #0,SYNC       Say Comm Physically Established
         LEA.L    MSGCOM2,A0    Display "Communication Established"
         JSR      DSPMSG        .             
         BSR      TEMPO
COMSET4A TST      SYNC          Waiting Loop
         BLT      COMSET5A      Comm Lost
         CMPI     #20,PNTRECE   .
         BNE.S    COMSET4A      .
         LEA.L    BUFRECE,A0    Read Config
         CMPI     #-1,(A0)      Not a config? DM18JUL
         BNE.S    COMSET4C      DM18JUL
COMSET4B MOVE     #-1,SYNC      DM18JUL
         LEA.L    MSGAB1,A0     Display "Communication Aborted by Other"
         JSR      DSPMSG        DM18JUL
         BSR      TEMPO
         MOVE.L   #0,MCOMM      Say No Comm
         BRA      NEWGAM2
COMSET4C MOVE.L   (A0)+,MGAME
         MOVE.L   (A0)+,MCOMM
         MOVE.L   (A0)+,MPLAY
         MOVE.L   (A0)+,MLAPS
         MOVE.L   (A0)+,MCONT
         MOVE     #0,MASLAV     Say Slave 
         MOVE     #1,SYNC       Say Logically Connected
         BRA      NEWGAM2       Affichage/START ONLY
*
* Unsuccesful Physical & Logical Communication Established SLAVE/MASTER
*
COMSET5A LEA.L    MSGLOS,A0     Display "Comunication Lost
         MOVE.L   #0,MCOMM
         BRA.S    COMSET5B
COMSET5  LEA.L    MSGCOM3,A0    Display "Communication Failed"
COMSET5B MOVE     #-1,SYNC
         JSR      DSPMSG        .
         BSR      TEMPO
         JSR      SWPSCR        Restore "Invisible" Screen  ***BUG***???
         BRA      NEWGAM1       Restart Selection
COMSETF

* End Selection 

ENDSEL   JSR      SWPSCR        Restore "Invisible" Screens

************************* Special Code for Demo Build *****************
DEMB     MOVE     #-1,DEMBLD     Assume not Demo Build
         CMPI     #8,MGAME+2     Only Demo Build in Racing       
         BNE      DEMBF
         MOVE     JOY+6,D0       Get Char
         CLR      JOY+6
         MOVEQ    #6-1,D1
         LEA.L    TABLEC,A1
DEMB1    CLR      D2
         MOVE.B   0(A1,D1),D2
         CMP      D2,D0      
         BEQ.S    DEMB2          If EQ, 
         DBF      D1,DEMB1
         BRA.S    DEMBF
DEMB2    LSL      #2,D1          Compute CRCNUM (0 to 20)
         MOVE     D1,CRCNUM      .
         MOVE     D1,CRCMAX
         MOVE.B   #12,CAR1PAS    Say at Position 7 (16-9) 
         MOVE.L   #DEMEQU,A0     .
         MOVE.B   #12,(A0)       . 
         MOVE     #0,DEMBLD      Say Demo Build
         MOVE     #0,MAXLAP      (0,4,8,...)
         MOVE.L   #-1,TOTTIM     Clear (-1) Total Time
         CLR.L    LAPTIM         Clear Lap Time 
         MOVE.L   #360000,BSTTIM Biggest Best LAP Time  
*DM15JUL - Init Gaz in VR2
         BRA      BCKR

TABLEC   DC.B     $ED    1  0-->0
         DC.B     $EE    2  1-->4
         DC.B     $EF    3  2
         DC.B     $EA    4  3
         DC.B     $EB    5  4
         DC.B     $EC    6  5-->20
      
DEMBF
************************* End of Special code for Demo Build ********** 

* GAME INITIALIZATION (If Comms, SYNC=1)
*********************

INIGAM   CLR.L    ASCORE         Init Scores
         CLR.L    RSCORE         .
         CLR      RSCUPD         .
INIGAM2  MOVE     #20,CRCMAX     Say 6 Circuits
         MOVE     MPLAY+2,D0     ALL?
         BEQ.S    INIGAM5        If EQ, ALL 
         SUB      #4,D0          Compute CRCNUM
         MOVE     D0,CRCMAX      Say it is also CRCMAX
INIGAM5  MOVE     D0,CRCNUM      Set Circuit Number (0,4,...)
*DM15JUL - Init GAZ in VR2
         CMPI     #8,MGAME+2     Test if Racing Mode
         BNE      NEWCRC         If NO, No Arcade/Qualif/Demo/Train Mode

* RACING SELECTION SCREEN (If Comms, SYNC=1)
*************************

* Init Pilot Tables
                  
RACSEL   MOVE.L  #ME,A0         Clear Me and Him
         MOVEQ   #16-1,D0       
RACSEL1  MOVE.B  #-1,(A0)+      
         DBF     D0,RACSEL1     
         MOVE    #15,LASTPOS    
         MOVE    #-1,HIMPOS     
         MOVE    #0,DRVTOT+28   
         MOVE    #-1,DRVTOT+32  
RACSEL2  LEA.L   DRVPOS,A0      Reorder 15 Pilots from 1 to 15
         MOVEQ   #15-1,D0
         MOVE    #1,D1
RACSEL3  MOVE    D1,(A0)+
         ADDQ    #1,D1
         DBF     D0,RACSEL3
         MOVE    #-1,(A0)+
         LEA.L   DRVGP,A0
         MOVE    #6*17-1,D0
RACSEL4  MOVE    #-1,(A0)+
         DBF     D0,RACSEL4
         LEA.L   DRVTOT,A0
         MOVE    #16-1,D0
RACSEL5  MOVE    #0,(A0)+
         DBF     D0,RACSEL5
         MOVE    #-1,(A0)+
         MOVE    #32+16,MEPOS
         TST     MCOMM+2
         BLE.S   RACSEL5A       If EQ, No Comms
*         MOVE    #0,PNTRECE     Receive Name Pointer - DM18JUL
*         MOVE.B  #-1,BUFRECE    DM18JUL
         MOVE    #-1,LASTPOS
         MOVE    #32+15,HIMPOS
         MOVE    #-1,DRVTOT+28
         MOVE    #0,DRVTOT+32

* Display Racing Score Environment

RACSEL5A JSR      ERASCR        Erase "Invisible" Screen
         JSR      DSPGRD        Display Grid
         BSR      DSPLIB        Display Libelles
         BSR      DSPREC        Display Best Records
         BSR      DSPPIL        Display Pilots

* Switch to Grid Palettes

         JSR      INIMHBL

* Set Medium Resolution

         BSR      MED

* Flip-Flop "Invisible"/Visible"

         JSR      FLIPFLOP

* Me Name Selection (Direct work in "Visible" Screen)

         JSR      SWPSCR         Reverse "Visible/"Invisible" Screens

RACSEL6  MOVE.L   #ME,-(A7)      26 (Address to Store chars)
         TST.L    -(A7)          22 (Dummy)
         LEA.L    ALPMED2,A5     
         MOVE.L   A5,-(A7)       18 (Alphabet)
         ADDA.L   #26*32,A5
         MOVE.L   A5,-(A7)       14 (Space in Alphabet)
         CLR.L    -(A7)          10 (For 0/32 Flip-Flop)
         MOVE.L   #10,-(A7)      6  (initial Position in Line)
         MOVEQ    #16,D0         Position 16 in Race
         SUBQ.L   #1,D0          Compute Line from
         LSL.L    #3,D0          Position 16
         ADDI.L   #44,D0         in
         MULS     #160,D0        the Race
         MOVE.L   D0,-(A7)       2  (Line on Screen)
         MOVE     #400,-(A7)     0  (Counter for -/Space Flip-Flop)
         JSR      INPDRV         Input Driver Initials
         ADDA.L   #30,A7         Restore Stack

*DM14JUL   
         CMPI     #-21,D0        Test ESC by Other
         BEQ      RACEND2A       If EQ, Yes
         
         CMPI     #-12,D0        Test Fn by Other (Restore) 
         BGT.S    RACSEL7        If NE, No 
         CMPI     #-20,D0
         BLT.S    RACSEL7
         MOVE     D0,D1          *
         NEG      D1             *
         ADDI     #37,D1         *Make it ASCII
         MOVE.B   D1,SAVFIL0     *
         BRA      RACSEL6C
         
RACSEL7  CMPI     #-11,D0        Test ESC by Me
         BNE.S    RACSEL6A       If NE, No
         TST      MCOMM+2
         BLE      RACEND1A
         LEA.L    ME,A0          Send ESC to Other in Name Buffer
         MOVE.B   #-11,(A0)
         MOVE     #8,D0
         JSR      SENDIR
         BRA      RACEND1A

RACSEL6A CMPI     #-2,D0         Test Fn by Me (Restore) 
         BGT      RACSEL9        If NE, No 
         CMPI     #-10,D0
         BLT      RACSEL9
         MOVE     D0,D1          *
         NEG      D1             *
         ADDI     #47,D1         *Make it ASCII
         MOVE.B   D1,SAVFIL0     *
         TST      MCOMM+2      
         BEQ.S    RACSEL6C
         LEA.L    ME,A0          Send Fn to Other in Name Buffer
         MOVE.B   D0,(A0)
         MOVE     #8,D0
         JSR      SENDIR
RACSEL6C MOVE     #0,PNTRECE
         MOVE     #0,BUFRECE
         LEA.L    SAVFIL,A0      Read SAVN.DAT Game File
         LEA.L    SAVGAM,A1      .
         MOVE.L   #2+16+(17*14),D1 .
         JSR      RDFIL          .
         MOVE     SAVCRC,CRCNUM  Restore Circuit #
         BSR      ERAPIL         Erase Pilot Names 
         BSR      SRTPIL         Sort Pilots in DRVPOS
         BSR      DSPPIL         Display Pilot Names
         BSR      DSPTOT         Display Totals
         JSR      SWPSCR         Restore "Invisible" Screen         
         BRA      RACF1          and branch to continue Race
*DM14JUL

RACSEL9  TST      MCOMM+2
         BLE.S    RACSEL11
         LEA.L    ME,A0          Send My Name Over The Net
         MOVE     #8,D0
         JSR      SENDIR
RACSEL10 TST      SYNC           Waiting for Other Name
         BLT      RACEND3A       If LT, Comm Lost
         CMPI     #8,PNTRECE     .
         BNE.S    RACSEL10       .
         MOVE.L   BUFRECE,HIM    
         MOVE.L   BUFRECE+4,HIM+4           
         LEA.L    ALPMED2,A5     Display HIM once Received
         LEA.L    HIM,A0
         MOVEQ    #15,D0
         SUBQ     #1,D0
         LSL      #3,D0
         ADDI     #44,D0
         MULU     #160,D0
         MOVEQ    #3,D1
         JSR      DSPDRV

RACSEL11 JSR      SWPSCR         Restore "Invisible" Screen
RACSELF 

* CIRCUIT INITIALISATION
************************

NEWCRC   TST      MCOMM+2
         BLE.S    NEWCRC0
         MOVE     #2,SYNC        Say Connected Logically 2
         MOVE     #0,PNTRECE

NEWCRC0  LEA.L    DISGAM,A0      Dispatch According to MGAME
         MOVE.L   MGAME,D0
         ASR.L    #1,D0
         MOVE.L   0(A0,D0),A0
         JMP      (A0)

         DC.L     DISTRA
         DC.L     DISQAL
DISGAM   DC.L     DISARC
         DC.L     DISRAC
         DC.L     DISDEM
         DC.L     DISTRA

DISQAL   MOVE.L   #8,MGAME       Qualif, Say Racing
         MOVE.L   SAVLAP,MLAPS   Restore MLAPS
         MOVE     #3-1,D0        Restore 8 Sky Events positions         
         MOVE.L   #CRCSKY+2,A0   DM25JUL   
         LEA.L    SAVSKY,A1      DM25JUL
DISQAL0  MOVE     (A1)+,(A0)+    DM25JUL.
         ADDA.L   #4,A0          DM25JUL
         DBF      D0,DISQAL0     .
         BSR      INITIM
         BSR      INILAP
         BRA      DUSRAC
 
DISRAC   MOVE.L   #-8,MGAME      Racing, Say Qualif Mode
         MOVE.L   MLAPS,SAVLAP
         CLR.L    MLAPS          Say 1 Lap
DISTRA
DISDEM   BSR      INITIM   
DISARC   BSR      INILAP
         BRA.S    BCKR

INITIM   MOVE.L   #-1,TOTTIM     Clear (-1) Total Time
         CLR.L    LAPTIM         Clear Lap Time 
         MOVE.L   #360000,BSTTIM Biggest Best LAP Time
         RTS

INILAP   MOVE.L   MLAPS,D0       Init # of Laps
         LSR      #2,D0
         MOVE     D0,MAXLAP      (0,4,8,...)
         RTS

* Read Circuit BCK Graph File

BCKR     MOVE     CRCNUM,D0
         LEA.L    CRCGRA,A0      Point to Circuit Graph File Name
         MOVE.L   0(A0,D0),A0    .
         LEA.L    CRCPIL,A1      Read Circuit Palette
         MOVE.L   CRCOBJ,A2      Read Circuit BCK  
         MOVE.L   #BCKLEN,D2
         MOVE.L   CRCOBJ,A3
         ADDA.L   #12000,A3      Special!
         JSR      RDIMA
         BMI      ERR

         MOVE.L   CRCOBJ,A0      Init Scroll From CRCEQU
         MOVE.L   #BCKEQU,A4     to BCKEQU
         JSR      INISCL         .

* Read Circuit Data File

         MOVE     CRCNUM,D0      Point to Circuit Data File Name
         LEA.L    CRCDAT,A0      .
         MOVE.L   0(A0,D0),A0    .
         MOVE.L   #CRCEQU,A1     Circuit Data Address in WRKEQU
         MOVE.L   #CRCLEN,D1     Circuit Data Length
         JSR      RDFIL
         BMI      ERR

         JSR      CMPNXT         Compute Next Same type Event #

         CMPI     #-8,MGAME+2
         BNE.S    RDCRCF
         MOVE.L   #CRCSKY+2,A0   Save 8 Sky Events Positions
         LEA.L    SAVSKY,A1      .
         MOVEQ    #3-1,D0        DM25JUL
RDCR0    MOVE     (A0)+,(A1)+    DM25JUL
         ADDA.L   #4,A0          DM25JUL
         DBF      D0,RDCR0
RDCRCF
        
* Read Circuit Physical Objects from Circuit Logical Objects

         LEA.L    tabobj+60,A0
         MOVE.L   #113-1,D0
RDOBJ    CLR.L    (A0)+        
         DBF      D0,RDOBJ
         MOVE.L   CRCOBJ,adhaut
         JSR      RDEVT

* Read Circuit DEMO File (If Demo)

DEMR     CMPI     #16,MGAME+2    Demo?
         BNE.S    DEMRF          If NE, No
         MOVE     CRCNUM,D0      Point to Circuit Demo File Name
         LEA.L    CRCDEM,A0      .
         MOVE.L   0(A0,D0),A0    .
         MOVE.L   #DEMEQU,A1
         MOVE.L   #DEMLEN,D1
         JSR      RDFIL
         BMI      ERR
         MOVE.L   #DEMEQU,A1
         MOVE.B   (A1),CAR1PAS   Restore F1 Position
DEMRF

* Read Circuit Banner in Invisible Screen

         MOVE     CRCNUM,D0      Point to Circuit Graph File Name
         LEA.L    CRCBAN,A0      .
         MOVE.L   0(A0,D0),A0    .
         LEA.L    BANPIL,A1      Read Banner Palette
         MOVE.L   CURSCR,A2      Read Banner in "Invisible" Screen
         MOVE.L   #160*HBANEQU,D2
         MOVE.L   CURSCR,A3
         ADDA.L   #(70+20)*160,A3
         JSR      RDIMA
         BMI      ERR
 
* Set Up Banner properly

         MOVE.L   MPLAY,D7       Mange pas de pain???
         LEA.L    DUSGAM,A0      Dispatch According to MGAME
         MOVE.L   MGAME,D0
         ASR.L    #1,D0
         MOVE.L   0(A0,D0),A0
         JMP      (A0)

         DC.L     DUSTRA
         DC.L     DUSQAL
DUSGAM   DC.L     DUSARC
         DC.L     DUSRAC
         DC.L     DUSDEM
         DC.L     DUSTRA

DUSQAL   JSR      LIBQAL         Qualif Mode
         BRA      BAN4 
DUSRAC   TST      DEMBLD         Racing and Demo Build?
         BLT.S    BAN0           If LT, No
DUSDEM   JSR      LIBDEM         Demo
         BRA.S    BAN1
BAN0     MOVEQ    #0,D6 
         MOVE.B   CAR1PAS,D6
         MOVE     #-1,D7
         TST      MCOMM+2
         BLE.S    BAN0A
         MOVEQ    #0,D7 
         MOVE.B   CAR2PAS,D7
BAN0A    JSR      LIBRAC         Display Libelles
BAN1     JSR      INSADIG
         MOVEQ    #0,D0          0 Lap Time  
         LEA.L    TIMDIG,A0      
         JSR      TIMNUM 
         LEA.L    TIMDIG,A0      Display Best Lap Time       
         LEA.L    NUMSCR,A5      in Screen
         MOVE.L   #43*160,D0
         JSR      DSPTMR         .         
         BRA.S    BAN3           
DUSTRA   JSR      LIBTRA         Here Training
         JSR      INSADIG
         MOVEQ    #0,D0          0 Lap Time  
         LEA.L    TIMDIG,A0      
         JSR      TIMNUM 
         LEA.L    TIMDIG,A0      Display Best Lap Time       
         LEA.L    NUMSCR,A5      in Screen
         MOVE.L   #56*160,D0
         JSR      DSPTMR         .         
         BRA.S    BAN3
DUSARC   JSR      LIBARC         Arcade Mode
BAN3     MOVE.L   MGAME,D6
         MOVE     #0,D5
         LEA.L    NUMSCR,A5
         JSR      DSPLAP         Display Lap 0
BAN4     MOVE.L   MGAME,D6
         MOVE     CRCNUM,D5
         LSR      #2,D5
         ADDQ     #1,D5
         LEA.L    NUMSCR,A5
         JSR      DSPSTG         Display Stage/Circuit

* Restore HBL (After Grid)

         JSR      EXIHBL
         
* Set Black Palettes/Lowres during First Circuit Display

         BSR       BLACK        

* Set Low resolution (Necessary for Racing Mode)

         JSR      LOW

* Move Banner in the "Visible" Screen (With Black Palette) 

         LEA.L    ACTSCR,A5      Work in "Visible" Screen after Banner
         MOVE.L   (A5),D5
         MOVE.L   4(A5,D5),A0
         EORI.L   #4,D5
         MOVE.L   4(A5,D5),A1
         MOVE     #(HBANEQU)*40-1,D0
MOV1     MOVE.L   (A0)+,(A1)+    
         DBF      D0,MOV1

         JSR      INIHBL        
         JMP      GAME           In VR2

* Low/Medium Resolution

MED      MOVE     #1,-(A7)
         BRA.S    RES
LOW      MOVE     #0,-(A7)
RES      MOVE.L   #-1,-(A7)
         MOVE.L   #-1,-(A7)
         TOS      SETSCREEN,14
         ADD.L    #12,A7
         RTS

* Black Palette in Banner and Circuit

BLACK    LEA.L    BLKPAL,A0
         LEA.L    BANPAL,A1 
         MOVEQ    #7,D0
BPAL0    MOVE.L   (A0)+,(A1)+
         DBF      D0,BPAL0
         LEA.L    BLKPAL,A0
         LEA.L    CRCPAL,A1 
         MOVEQ    #7,D0
BPAL1    MOVE.L   (A0)+,(A1)+
         DBF      D0,BPAL1
         RTS

* ARCADE SCORE UPDATE
*********************

ARCSCR   BSR      RDSEL          Read Selection File
         
* Update 9 Best Scores (When Necessary)

         MOVE.L   #-1,SCOINS     Assume no Update      
         MOVE.L   ASCORE,D0      Get Score
         BEQ      SRTF           If EQ, No Update
         MOVE     CRCNUM,D3      Get Stage
         LSR      #2,D3          .
         ADDQ     #1,D3          .
         LEA.L    ASCORES,A0     Point to Tables
         LEA.L    STAGES,A1      .
         LEA.L    PLAYERS,A2     .
         LEA.L    DUPSCO,A3      .
         LEA.L    DUPSTA,A4      .
         LEA.L    DUPPLA,A5      .
         MOVEQ    #0,D2
         MOVEQ    #8,D1          9 Scores
SRT0     CMP.L    (A0),D0        To be Inserted
         BPL.S    SRT1           IF PL, Yes
         MOVE.L   (A0)+,(A3)+    Duplicate Score
         MOVE     (A1)+,(A4)+    Duplicate Stage
         MOVE     (A2)+,(A5)+    Duplicate Player
         MOVE     (A2)+,(A5)+    .
         MOVE     (A2)+,(A5)+    .
         ADDI.L   #1,D2          Advance Line on Screen
         BRA      SRT2
SRT1     MOVE.L   D0,(A3)+       Insert Score
         MOVE     D3,(A4)+       Insert Stage
         MOVE     #26,(A5)+      Clear Players Initials
         MOVE     #26,(A5)+      .
         MOVE     #26,(A5)+      .
         MOVE.L   D2,SCOINS      Set Line
         MOVEQ    #-1,D0         No more insert
SRT2     DBF      D1,SRT0
         LEA.L    ASCORES,A0
         LEA.L    STAGES,A1
         LEA.L    PLAYERS,A2
         LEA.L    DUPSCO,A3
         LEA.L    DUPSTA,A4
         LEA.L    DUPPLA,A5
         MOVEQ    #8,D0          9 Scores
SRT3     MOVE.L   (A3)+,(A0)+    Restore Score
         MOVE     (A4)+,(A1)+    Restore Stages
         MOVE     (A5)+,(A2)+    Restore Player
         MOVE     (A5)+,(A2)+    .
         MOVE     (A5)+,(A2)+    .
         DBF      D0,SRT3
SRTF

*  Erase (Black) "Invisible" Screen 

         JSR      ERASCR

* Display Libelles in Vroom Screen in "Invisible" Screen

         LEA.L    BESTS,A5        Best Arcade Scores
         JSR      DSPITN0
         LEA.L    LIBEL,A5        Libelles
         JSR      DSPITN0
         LEA.L    FST,A5          1st
         JSR      DSPITN0
         LEA.L    SND,A5          2nd
         JSR      DSPITN0
         LEA.L    TRD,A5          3rd
         JSR      DSPITN0
         LEA.L    FOTH,A5         4th
         JSR      DSPITN0
         LEA.L    FITH,A5         5th
         JSR      DSPITN0
         LEA.L    SITH,A5         6th
         JSR      DSPITN0
         LEA.L    SETH,A5         7th
         JSR      DSPITN0
         LEA.L    HETH,A5         8th
         JSR      DSPITN0
         LEA.L    NITH,A5         9th
         JSR      DSPITN0

* Display Best Scores in "Invisible" Screen

         MOVEQ    #8,D7          9 Scores
         MOVE     D7,-(A7)
         MOVE.L   #(190+9)*160,-(A7)
         LEA.L    ASCORES,A5
         MOVE.L   A5,-(A7)
SCOR     MOVE     D7,8(A7)
         MOVE.L   (A7),A5
         MOVE     D7,D5
         LSL      #2,D5
         MOVE.L   0(A5,D5),D0    Convert Score
         LEA.L    ASCODIG,A0     .
         JSR      TTNUM          (Then Thousand)
         MOVE.L   4(A7),D0
         LEA.L    ASCODIG,A0     Display Score
         LEA.L    NUMSCO,A5
         JSR      DSPSCO         .
         SUBI.L   #(20-2)*160,4(A7)
         MOVE     8(A7),D7
         DBF      D7,SCOR        Next Score
         ADDA.L   #10,A7         Restore Stack

* Display Stages in "Invisible" Screen

         MOVEQ    #8,D7          9 Stages
         MOVE     D7,-(A7)
         MOVE.L   #(190+9)*160,-(A7)
         LEA.L    STAGES,A5
         MOVE.L   A5,-(A7)
STAG     MOVE     D7,8(A7)
         MOVE.L   (A7),A5        Get Stage
         MOVEQ    #0,D5          .
         MOVE     D7,D5          .
         LSL      #1,D5          .
         MOVE     0(A5,D5),D5    .
         LSL      #5,D5          Display Stage
         LEA.L    NUMSCO,A5      .
         ADDA.L   D5,A5          .
         MOVE.L   ACTSCR,D3      .
         MOVE.L   #181,10(A5,D3) .
         MOVE.L   4(A7),0(A5,D3) .
         JSR      DSPITN0         .
         SUBI.L   #(20-2)*160,4(A7)
         MOVE     8(A7),D7
         DBF      D7,STAG        Next Stage
         ADDA.L   #10,A7         Restore Stack

* Display Players in "Invisible" Screen

         MOVEQ    #8,D7          9 Players
         MOVE     D7,-(A7)
         MOVE.L   #(190+9)*160,-(A7)
         LEA.L    PLAYERS,A0
         MOVE.L   A0,-(A7)
PLAY     MOVE     D7,8(A7)
         MOVE.L   (A7),A0
         CLR.L    D5
         MOVE     D7,D5          Point to Player Initials
         LSL      #1,D5          6*D5
         ADD      D7,D5          .
         LSL      #1,D5          .
         ADDA.L   D5,A0          .
         MOVE.L   4(A7),D0       Line
         LEA.L    ALPHA,A5       Display Initials
         JSR      DSPINI         .
         SUBI.L   #(20-2)*160,4(A7)
         MOVE     8(A7),D7
         DBF      D7,PLAY        Next Player
         ADDA.L   #10,A7

*  Erase (Black) "Visible" Screen 

         LEA.L    ACTSCR,A5
         MOVE.L   (A5),D5
         EORI.L   #4,D5
         MOVE.L   4(A5,D5),A0
         MOVE     #8000-1,D0    #-1 of Double Words
PRX      CLR.L    (A0)+
         DBF      D0,PRX

* Set Score Screen Palette

         JSR      EXIHBL         20 JUL 91
         LEA.L    SCOPAL0,A0     *
         MOVE.L   A0,-(A7)       *
         TOS      SETPALETTE,14  *
         ADDQ.L   #6,A7          *
*         MOVE.L   #SCOPAL0,$45A  Set New Palette

* Display Text in Scrolling Mode in "Visible" Screen

         LEA.L    ACTSCR,A5      Get "Invisible" Screen Address
DSPVT    MOVE.L   (A5),D6        .
         MOVE.L   4(A5,D6),A0    .
         MOVE.L   D6,D7          Get "Visible" Screen Address
         EORI.L   #4,D7          .
         MOVE.L   4(A5,D7),A1    .
         MOVE     #200-1,D0      200 Lines
DSPVT0   MOVE     #40-1,D1
DSPVT1   MOVE.L   (A0)+,(A1)+    Display Lines ("Invisible" to "Visible")
         DBF      D1,DSPVT1      Tempo
         MOVE     #3000,D2       .
DSPVT2   DBF      D2,DSPVT2
         DBF      D0,DSPVT0      Next Line

* Arcade Score Modification?

         MOVE.L   SCOINS,D2      To be modified?
         BPL.S    ENTINI         If PL, Yes
SOL      CLR.L    D0             Display Scores
         BTST     #1,JOY+1       Fire?
         BEQ.S    SOL 
         CLR.L    MESSAG
         BRA      NEWGAM1        Start New Game

* Enter Initials (Direct Work in "Visible" Screen)

ENTINI   JSR      SWPSCR         Reverse "Visible/Invisible" Screens
         LEA.L    PLAYERS,A3     Compute Address in Players
         MOVE.L   #6,D3          .
         MULS     D2,D3          .
         ADDA.L   D3,A3          .
         MOVE.L   A3,-(A7)       26
         TST.L    -(A7)          22 (Dummy)
         LEA.L    ALPHA,A5
         MOVE.L   A5,-(A7)       18
         ADDA.L   #26*32,A5
         MOVE.L   A5,-(A7)       14
         CLR.L    -(A7)          10
         MOVE.L   #236,-(A7)     6
         MOVE.L   #(20-2)*160,D0 Compute Line to Insert
         MULS     D2,D0          .
         ADDI.L   #(30+9+16)*160,D0 .
         MOVE.L   D0,-(A7)       2
         MOVE     #400,-(A7)     0
         JSR      INPINI         Input Initials
         ADDA.L   #30,A7         Restore Stack

         JSR      SWPSCR         Restore "Invisible" Screen

* Write Back Arcade Score File

         LEA.L    SCAFIL,A0      Create Arcade SCORE File
         LEA.L    ASCORES,A1     .
         MOVE.L   #108,D1        .
         JSR      WRFIL          .
         BMI      ERR
         CLR.L    MESSAG
         BRA      NEWGAM1        Start New Game

* RACING SCORE UPDATE (SYNC=2)
*********************

RACSCR   CLR      JOY+6         
         TST      MCOMM+2
         BLE.S    ALLOC
         MOVE     #0,PNTRECE    
         MOVE     #0,BUFRECE    2 Bytes

* Allocate Points to Pilots and Sort

ALLOC    MOVE     CRCNUM,D0     Point to DRVGP Entry
         LSR      #2,D0         .
         MULS     #34,D0        2*17
         LEA.L    DRVGP,A0      .
         ADDA.L   D0,A0         .
         LEA.L    DRVTOT,A2     Point to DRVTOT
         LEA.L    POINTS,A1     
         
         MOVE     #0,D2
ALLOC0   LEA.L    OCCUR,A4      Get Bigger Loop
         MOVEQ    #0,D4
         MOVE.B   #-3,D0       
ALLOC0A  MOVE.B   59(A4,D4),D1
         CMPI.B   #-2,D1        Already Treated?
         BEQ.S    ALLOC2        If EQ, Yes
ALLOC1   CMP.B    D0,D1
         BLT.S    ALLOC2 
         MOVE.B   D1,D0
         MOVE     D4,D5         Save Pointer
ALLOC2   ADDI.L   #64,D4 
         CMPI.L   #16*64,D4
         BLT.S    ALLOC0A
         
ALLOC4   CMPI.B   #-3,D0        All Treated?
         BEQ      ALLOCF        If EQ, Yes
         MOVE     D5,D4         Restore Pointer
         TST.B    0(A4,D5)      Normal Car.      
         BGT.S    ALLOC6        If GT, Yes
         BEQ.S    ALLOC5        If EQ, F2
         MOVE     #30,D4        F1
         BRA.S    ALLOC9
ALLOC5   MOVE     #32,D4        F2
         BRA.S    ALLOC9
ALLOC6   TST      MCOMM+2       Compute Pointer in DRVGP & DRVTOT
         BLE.S    ALLOC8        For Normal Car
         LSR      #5,D4         .
         SUBI     #4,D4         .
         BRA.S    ALLOC9        .
ALLOC8   LSR      #5,D4         .
         SUBI     #2,D4         .
ALLOC9   MOVE     0(A1,D2),D6   Get Points from Points
ALLOC10  ROL      #8,D6         DM23JUL
         MOVE     D6,0(A0,D4)   DM23JUL
         MOVE.B   59(A4,D5),D6  DM23JUL
         BPL.S    ALLOC11       DM23JUL
         CLR.B    D6            DM23JUL
ALLOC11  ADD      D6,0(A2,D4)   and DRVTOT
         ADDI     #2,D2         
         MOVE.B   #-2,59(A4,D5) Say treated 
         BRA      ALLOC0

ALLOCF   BSR      SRTPIL        Sort Pilots in DRVPOS

* Modify Best Lap and GP
    
BST      LEA.L    BSTLAP,A0     Best Lap
         MOVE     CRCNUM,D0
         EXT.L    D0
         ADDA.L   D0,A0
         MOVE.L   BSTTIM,D1
         TST.L    (A0)
         BEQ.S    BST0
         CMP.L    (A0),D1
         BGT.S    BST1 
BST0     MOVE.L   D1,(A0)
         LEA.L    BSTLAP+24,A0
         LSL      #1,D0
         LEA.L    ME,A1
         MOVE.L   (A1)+,0(A0,D0)         
         MOVE.L   (A1),4(A0,D0)
         MOVE     #1,RSCUPD
BST1     LEA.L    TOTLAP,A0     Best Gp
         MOVE     CRCNUM,D0
         EXT.L    D0
         ADDA.L   D0,A0
         MOVE.L   TOTTIM,D1
         BPL.S    BSTA          ******
         MOVE.L   #360000,D1    ******
BSTA     TST.L    (A0)
         BEQ.S    BST2
         CMP.L    (A0),D1
         BGT.S    BST3 
BST2     MOVE.L   D1,(A0)
         LEA.L    TOTLAP+24,A0
         LSL      #1,D0
         LEA.L    ME,A1
         MOVE.L   (A1)+,0(A0,D0)         
         MOVE.L   (A1),4(A0,D0)
         MOVE     #1,RSCUPD
BST3         

* End of Game Score Update

BST4     TST     MPLAY+2        All Circuits
         BNE.S   BSTF           If NE, No
         MOVE    CRCNUM,D0      Increment CRC #
         CMP     CRCMAX,D0      Last Circuit in Racing 
         BNE.S   DSPTBL         If NE, No  
         MOVE    TOTPNT,D0
         LEA.L   DRVTOT,A1
         MOVE    30(A1),D1
         LSR     #8,D1          DM23JUL
         CMP     D0,D1
         BLE.S   DSPTBL 
         MOVE    D1,TOTPNT
         LEA.L   ME,A1
         MOVE.L  (A1)+,TOTPNT+2         
         MOVE.L  (A1),TOTPNT+6
         MOVE    #1,RSCUPD     
BSTF

* Display Racing Score Environment

DSPTBL   BSR      RDSEL         Read Selection File
         JSR      ERASCR        Erase "Invisible" Screen
         JSR      DSPGRD        Display Grid
         BSR      DSPLIB        Display Libelles
         BSR      DSPREC        Display Best Records
         BSR      DSPPIL        Display Pilots
         BSR      DSPTOT        Display Totals

* Switch to Grid Palette

         JSR      EXIHBL        Exit from Game HBL
         JSR      INIMHBL       Init Grid HBL

* Set Medium Resolution

         MOVE     #1,-(A7)
         MOVE.L   #-1,-(A7)
         MOVE.L   #-1,-(A7)
         TOS      SETSCREEN,14
         ADD.L    #12,A7

* Flip-Flop "Invisible"/Visible"

         JSR      FLIPFLOP

* Fire Input or F1 (Save)
                                
RACF1    MOVE     JOY+6,D0      Get Char
         CLR      JOY+6         
 
         TST      MCOMM+2       
         BLE      RACF2         

RACF0    CMPI     #1,PNTRECE    
         BLT.S    RACF2         
         BEQ.S    RACF0         

         CMPI     #-21,BUFRECE  Test ESC by Other
         BEQ      RACEND3
         
         CMPI     #-12,BUFRECE  Test Fn by Other (Save) 
         BGT      RACF2         If GT, No 
         CMPI     #-20,BUFRECE
         BLT      RACF2
         MOVE     BUFRECE,D1     *
         NEG      D1             *
         ADDI     #37,D1         *Make it ASCII
         MOVE.B   D1,SAVFIL0     * 
         LEA.L    MSGSAV1,A0     Message "Game Saved By Other"
         BRA      RACF4A   
 
RACF2    CMPI     #$0001,D0     ESC by Me?
         BNE.S    RACF3
         TST      MCOMM+2
         BLE      RACEND1
         LEA.L    BUFESC,A0     Send Escape Over the Net
         MOVE     #2,D0
         JSR      SENDIR
         BRA      RACEND1

RACF3    CMPI     #$003B,D0     Test Fn by Me (Save)
         BLT      RACF11        If LT, No
         CMPI     #$0043,D0     
         BGT      RACF11        If GT, No
         TST      MPLAY+2       All Circuits?
         BNE      RACF1         If NE, No, Do not Save
         MOVE     CRCNUM,D1
         CMP      CRCMAX,D1     at end of Race?
         BEQ      RACF11        If EQ, Yes, Do not Save 
         MOVE     D1,SAVCRC     Save Circuit #
         MOVE     D0,D1         *Make it ASCII
         SUBI     #$A,D1        *
         MOVE.B   D1,SAVFIL0    *
         TST      MCOMM+2
         BLE.S    RACF4   
         LEA.L    BUFFN,A0      Send FN over the Net
         SUBI     #71,D0        Make it -12 to -21
         MOVE     D0,(A0)
         MOVE     #2,D0
         JSR      SENDIR
RACF4    LEA.L    MSGSAV,A0     Message "Game Saved"
RACF4A   MOVE.L   A0,MESSAG
         LEA.L    SAVFIL,A0     Save SAVN.DAT on Disk
         LEA.L    SAVGAM,A1     .
         MOVE.L   #2+16+(17*14),D1 .
         JSR      WRFIL         .
         TST      RSCUPD        Test Score to Update
         BEQ      RACEND4       If No
         LEA.L    SCRFIL,A0     Update Racing Score/Record File
         LEA.L    RSCORES,A1    .
         MOVE.L   #154,D1       .
         JSR      WRFIL
         BMI      ERR
         CLR      RSCUPD
         BRA      RACEND4

RACF11   BTST     #1,JOY+1      Fire?
         BEQ      RACF1         .
         
         TST      MCOMM+2         
         BLE.S    RACF13              
         LEA.L    BUFIR,A0      Send Fire Over the Net
         MOVE     #2,D0
         JSR      SENDIR 
RACF12   TST      SYNC          Waiting For Fire from Other
         BLT      RACEND3       If LT, Comm Lost
         CMPI     #2,PNTRECE    .
         BNE.S    RACF12        .
         MOVE     BUFRECE,D0    Get 2 Chars

         CMPI     #-21,D0       Test ESC by Other
         BEQ      RACEND3
         
         CMPI     #-12,D0       Test Fn by Other (Save) 
         BGT      RACF13        If GT, No 
         CMPI     #-20,D0
         BLT      RACF13
         MOVE     D0,D1         *
         NEG      D1            *
         ADDI     #37,D1        *Make it ASCII
         MOVE.B   D1,SAVFIL0    * 
         LEA.L    MSGSAV1,A0    Message "Game Saved By Other"
         BRA      RACF4A   
        
RACF13   
                            
* Test End of Game/Circuit : Write Back Score

RACEND   TST     RSCUPD         Test Score to Update
         BEQ.S   RACEND0        If No
         LEA.L   SCRFIL,A0      Update Racing Score/Record File
         LEA.L   RSCORES,A1     .
         MOVE.L  #154,D1        .
         JSR     WRFIL          .
         BMI     ERR
         CLR     RSCUPD
RACEND0  MOVE    CRCNUM,D0      Increment CRC #
         ADDQ    #4,D0          .
         MOVE    D0,CRCNUM      .
         CMP     CRCMAX,D0      Last Circuit in Racing 
         BLE     NEWCRC         If LT, No  
         BRA     RACEND5
         
RACEND1  JSR     SWPSCR
RACEND1A LEA.L   MSGESC,A0      Message "Game Escaped"  
         MOVE.L  A0,MESSAG         
         BRA.S   RACEND6

RACEND2  JSR     SWPSCR
RACEND2A LEA.L   MSGESC1,A0     Message "Game Escaped By Other"  
         MOVE.L  A0,MESSAG         
         BRA.S   RACEND6

RACEND3  JSR     SWPSCR
RACEND3A LEA.L   MSGLOS,A0      Message "Communication Lost"
         MOVE.L  A0,MESSAG
         BRA.S   RACEND6

RACEND4  JSR     SWPSCR         Message "Game Saved/By Other"" from RACF4
         BRA.S   RACEND6

RACEND5  JSR     SWPSCR
         CLR.L   MESSAG         No Message

RACEND6  JSR      EXIHBL        
         MOVE     #0,-(A7)      Set Low Resolution
         MOVE.L   #-1,-(A7)     
         MOVE.L   #-1,-(A7)
         TOS      SETSCREEN,14
         ADD.L    #12,A7
         BRA      NEWGAM1       Start New Game

ERR      TOS      TERM,1

* Tempo

TEMPO    MOVE.W   #10,D1
TEMPO1   MOVE.W   #32000,D0     Tempo
TEMPO2   DBF      D0,TEMPO2
         DBF      D1,TEMPO1
         RTS

OBJBAS:
* Read Table Objets Logiques

         LEA.L    LOGFIL,A0
         MOVE.L   #LOGEQU,A1
         MOVE.L   #LOGLEN,D1
         JSR      RDFIL
         BMI      ERR

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

* RDSEL Read Selection File 

RDSEL    LEA.L    ITSLFIL,A0
         LEA.L    SCOPAL,A1
         MOVE.L   #ITSLEQU,A2
         MOVE.L   #ITSLLEN-128,D2
         MOVE.L   CRCOBJ,A3
         JSR      RDIMA
         BMI      ERR

         MOVE.L   CRCOBJ,A1      Workspace 
         MOVE.L   #ITSLEQU,A5
         MOVE.L   #PLANEQU,D1    **** ATTENTION ****
         JSR      AMIGA

         LEA.L    VROFIL,A0      Read Sample File MODJLL
         MOVE.L   CRCOBJ,A1     .
         ADD.L    #PLANEQU*5,A1
         MOVE.L   #21000,D1      .
         JSR      RDFIL          .
         BMI      ERR
         RTS

* DSPLIB - Display Libelles in Grid
*
DSPLIB   LEA.L    WORLD,A5           Title   
         JSR      DSPMED    
         LEA.L    DRIVERS,A5         Drivers
         JSR      DSPMED
         LEA.L    GP,A5              GP #1
         MOVE.L   #33*160,(A5)
         MOVE.L   #33*160,4(A5)
         MOVE.L   #100,10(A5)
         MOVE.L   #100,14(A5)
         JSR      DSPMED
         LEA.L    NO1,A5
         MOVE.L   #120,10(A5)
         MOVE.L   #120,14(A5)
         JSR      DSPMED
         LEA.L    GP,A5              GP #2
         MOVE.L   #180,10(A5)
         MOVE.L   #180,14(A5)
         JSR      DSPMED
         LEA.L    NO2,A5
         MOVE.L   #200,10(A5)
         MOVE.L   #200,14(A5)
         JSR      DSPMED
         LEA.L    GP,A5              GP #3
         MOVE.L   #260,10(A5)
         MOVE.L   #260,14(A5)
         JSR      DSPMED
         LEA.L    NO3,A5
         MOVE.L   #280,10(A5)
         MOVE.L   #280,14(A5)
         JSR      DSPMED
         LEA.L    GP,A5              GP #4
         MOVE.L   #340,10(A5)
         MOVE.L   #340,14(A5)
         JSR      DSPMED
         LEA.L    NO4,A5
         MOVE.L   #360,10(A5)
         MOVE.L   #360,14(A5)
         JSR      DSPMED
         LEA.L    GP,A5              GP #5
         MOVE.L   #420,10(A5)
         MOVE.L   #420,14(A5)
         JSR      DSPMED
         LEA.L    NO5,A5
         MOVE.L   #440,10(A5)
         MOVE.L   #440,14(A5)
         JSR      DSPMED
         LEA.L    GP,A5              GP #6
         MOVE.L   #500,10(A5)
         MOVE.L   #500,14(A5)
         JSR      DSPMED
         LEA.L    NO6,A5
         MOVE.L   #520,10(A5)
         MOVE.L   #520,14(A5)
         JSR      DSPMED
         LEA.L    TOTAL,A5       TOTAL
         MOVE.L   #33*160,(A5)         
         MOVE.L   #33*160,4(A5)
         JSR      DSPMED
         LEA.L    BEST,A5        BEST LAP
         MOVE.L   #181*160,(A5)         
         MOVE.L   #181*160,4(A5)
         MOVE.L   #10,10(A5)
         MOVE.L   #10,14(A5)
         JSR      DSPMED
         LEA.L    LAPL,A5
         JSR      DSPMED
         LEA.L    BEST,A5        BEST GP
         MOVE.L   #195*160,(A5)         
         MOVE.L   #195*160,4(A5)
         MOVE.L   #10,10(A5)
         MOVE.L   #10,14(A5)
         JSR      DSPMED
         LEA.L    GP,A5
         MOVE.L   #195*160,(A5)         
         MOVE.L   #195*160,4(A5)
         MOVE.L   #50,10(A5)
         MOVE.L   #50,14(A5)
         JSR      DSPMED
         LEA.L    BEST,A5        BEST TOT
         MOVE.L   #181*160,(A5)         
         MOVE.L   #181*160,4(A5)
         MOVE.L   #570,10(A5)
         MOVE.L   #570,14(A5) 
         JSR      DSPMED
         LEA.L    TOT,A5
         JSR      DSPMED
         RTS

* DSPREC - Display Records (Best Laps Times and Names)
*
DSPREC   MOVE     MPLAY+2,D0
         LSR      #2,D0
         SUBQ     #1,D0
         MOVE     D0,-(A7)
         MOVEQ    #5,D7          6 GPs
         MOVE     D7,-(A7)
         MOVE.L   #490,-(A7)
         LEA.L    BSTLAP,A5
         MOVE.L   A5,-(A7)
TIM      MOVE     D7,8(A7)
         TST      10(A7)
         BLT.S    TIM0    
         CMP      10(A7),D7
         BNE.S    TIM1
TIM0     MOVE.L   (A7),A5
         MOVE     D7,D5
         LSL      #2,D5
         MOVE.L   0(A5,D5),D0    Point to Time
         BEQ.S    TIM1
         LEA.L    TIMDIG,A0      Convert Time
         JSR      TIMNUM         .
         LEA.L    TIMDIG,A0
         MOVE.L   #177*160,D0    Line
         MOVE.L   4(A7),D1       Col
         LEA.L    NUMMED1,A5     .
         JSR      DSPTIM         .
TIM1     SUBI.L   #80,4(A7)
         MOVE     8(A7),D7
         DBF      D7,TIM         Next Time
         ADDA.L   #10,A7         Restore Stack

         MOVEQ    #5,D7         6 GPs
         MOVE     D7,-(A7)
         MOVE.L   #490,-(A7)    Position in Line
         LEA.L    BSTLAP+24,A0
         MOVE.L   A0,-(A7)
DRIV     MOVE     D7,8(A7)
         TST      10(A7)
         BLT.S    DRIV0
         CMP      10(A7),D7
         BNE.S    DRIV1
DRIV0    MOVE.L   (A7),A0
         TST.B    (A0)
         BLT.S    DRIV1
         CLR.L    D5
         MOVE     D7,D5         Point to Driver Initials
         LSL      #3,D5         8*D5
         ADDA.L   D5,A0         .
         MOVE.L   4(A7),D1      Column
         MOVE.L   #183*160,D0   Line
         LEA.L    ALPMED2,A5    
         JSR      DSPDRV        Display Driver Name
DRIV1    SUBI.L   #80,4(A7)     Backward in Line
         MOVE     8(A7),D7
         DBF      D7,DRIV       Next GP
         ADDA.L   #10,A7

* Display Total Times and Names in "Invisible" Screen

         MOVEQ    #5,D7          6 GPs
         MOVE     D7,-(A7)
         MOVE.L   #490,-(A7)
         LEA.L    TOTLAP,A5
         MOVE.L   A5,-(A7)
TOM      MOVE     D7,8(A7)
         TST      10(A7)
         BLT.S    TOM0
         CMP      10(A7),D7
         BNE.S    TOM1
TOM0     MOVE.L   (A7),A5
         MOVE     D7,D5
         LSL      #2,D5
         MOVE.L   0(A5,D5),D0    Point to Time
         BEQ.S    TOM1
         LEA.L    TIMDIG,A0      Convert Time
         JSR      TIMNUM         .
         LEA.L    TIMDIG,A0
         MOVE.L   #191*160,D0    Line
         MOVE.L   4(A7),D1       Col
         LEA.L    NUMMED1,A5     .
         JSR      DSPTIM         .
TOM1     SUBI.L   #80,4(A7)
         MOVE     8(A7),D7
         DBF      D7,TOM         Next Time
         ADDA.L   #10,A7         Restore Stack

         MOVEQ    #5,D7         6 GPs
         MOVE     D7,-(A7)
         MOVE.L   #490,-(A7)    Position in Line
         LEA.L    TOTLAP+24,A0
         MOVE.L   A0,-(A7)
DROV     MOVE     D7,8(A7)
         TST      10(A7)
         BLT.S    DROV0
         CMP      10(A7),D7
         BNE.S    DROV1
DROV0    MOVE.L   (A7),A0
         TST.B    (A0)
         BLT.S    DROV1
         CLR.L    D5
         MOVE     D7,D5         Point to Driver Initials
         LSL      #3,D5         8*D5
         ADDA.L   D5,A0         .
         MOVE.L   4(A7),D1      Column
         MOVE.L   #197*160,D0   Line
         LEA.L    ALPMED2,A5    
         JSR      DSPDRV        Display Driver Name
DROV1    SUBI.L   #80,4(A7)     Backward in Line
         MOVE     8(A7),D7
         DBF      D7,DROV       Next GP
         ADDA.L   #12,A7        10+2

* Display Total Points and Name in "Invisible" Screen

TUT      TST      MPLAY+2        All Circuits?
         BNE.S    TUT1
         MOVE     TOTPNT,D0      Point to Total
         BEQ.S    TUT1
         EXT.L    D0            
         LEA.L    DSPTOT5,A0     Convert Total in DSPTOT5
         JSR      TENUM          .
         MOVE.L   #191*160,D0    Line
         MOVE.L   #590,D1        Col
         LEA.L    NUMMED1,A5     .
         LEA.L    DSPTOT5,A0     .
         JSR      DSPGP          Display GP Total
         LEA.L    TOTPNT+2,A0
         TST.B    (A0)
         BLT.S    TUT1
         MOVE.L   #570,D1        Column
         MOVE.L   #197*160,D0    Line
         LEA.L    ALPMED2,A5 
         JSR      DSPDRV         Display Driver Name
TUT1     RTS

* ERAPIL - Erase Pilot Names
*      
   
ERAPIL   MOVEQ    #16-1,D2
         MOVE     #1,-(A7)
ERAPIL1  MOVE     D2,-(A7)
         MOVE.L   #EFF,A0       Point to Blank Driver Name
         MOVEQ    #0,D0
         MOVE     2(A7),D0      Get Position
         ADDI     #1,2(A7)
         EXT.L    D0
         SUBQ.L   #1,D0         Compute Line from
         LSL.L    #3,D0         Position
         ADDI.L   #44,D0        in
         MULS     #160,D0       the Race
         MOVE.L   #3,D1         Position in Line
         LEA.L    ALPMED1,A5
         JSR      DSPDRV        Display Blank Name
ERAPIL3  MOVE     (A7)+,D2
         DBF      D2,ERAPIL1
         ADDA.L   #2,A7
         RTS

* DSPPIL - Display Pilot Names
*      
   
DSPPIL   MOVEQ    #17-1,D2
         MOVE.L   #DRVPOS,-(A7)
         MOVE.L   #DRIVER,-(A7)
DSPPIL1  MOVE.L   D2,-(A7)
         MOVE.L   4(A7),A0      Point to Driver Name
         ADDI.L   #8,4(A7)      Point to Next Driver
         MOVEQ    #0,D0
         MOVE.L   8(A7),A2
         MOVE     (A2)+,D0      Get Position
         MOVE.L   A2,8(A7)
         EXT.L    D0
         BLT.S    DSPPIL3       Do not Display if Neg
         LEA.L    ALPMED1,A5    Assume Not Player
         BTST     #5,D0         Test Player (Bit 32)
         BEQ.S    DSPPIL2       If EQ, No
         BCLR     #5,D0
         LEA.L    ALPMED2,A5    Say Player
DSPPIL2  SUBQ.L   #1,D0         Compute Line from
         LSL.L    #3,D0         Position
         ADDI.L   #44,D0        in
         MULS     #160,D0       the Race
         MOVE.L   #3,D1         Position in Line
         JSR      DSPDRV        Display Name
DSPPIL3  MOVE.L   (A7)+,D2
         DBF      D2,DSPPIL1
         ADDA.L   #8,A7
         RTS

* SRTPIL - Sort Pilots from DRVTOT in DRVPOS
*
SRTPIL   MOVEQ    #17-1,D2
         LEA.L    DRVPOS,A0     
SRTPIL0  MOVE     #$8000,D0
         BTST     #5,1(A0)      Player?
         BEQ.S    SRTPILA       If EQ, No
         MOVE     #$8020,D0     Say Player
SRTPILA  MOVE     D0,(A0)+ 
         DBF      D2,SRTPIL0
          
         MOVE     #0,D4
SRTPIL1  MOVE.L   #DRVPOS,A0
         MOVE.L   #DRVTOT,A1
         MOVE     #0,D0
         MOVE     #-1,D1
         MOVEQ    #17-1,D2
SRTPIL2  TST      (A0)          Already Sorted
         BPL      SRTPIL3       If PL, Yes
         CMP      (A1),D1       Bigger Total Than Previous
         BPL.S    SRTPIL3       If PL, No
         MOVE     (A1),D1       Save Max Total
         MOVE     D0,D3         Save max Position
SRTPIL3  ADDQ     #2,D0
         TST      (A0)+
         TST      (A1)+
         DBF      D2,SRTPIL2
         TST      D1            Test All Sorted?
         BLT.S    SRTPILF       If LT, Yes
         ADDQ     #1,D4
         BCLR     #5,D4
         LEA.L    DRVPOS,A0     
         BTST     #5,1(A0,D3)   Player?
         BEQ.S    SRTPIL4       If EQ, No
         BSET     #5,D4         Say Player
SRTPIL4  MOVE     D4,0(A0,D3)   Store Position
         BRA      SRTPIL1
SRTPILF  RTS    

* DSPTOT - Display 6*GPs and Total
*
DSPTOT   MOVE     MPLAY+2,D0
         LSR      #2,D0
         SUBQ     #1,D0
         MOVE     D0,-(A7)
         MOVEQ    #7-1,D3
         MOVE.L   #590,DSPTOT6
DSPTOT0  MOVE.L   D3,-(A7)
         MOVE.L   #DRVGP,A2    Point to GP Column
         MOVE.L   D3,D2        . 
         MULU     #34,D2       .
         ADDA.L   D2,A2        .
         MOVE.L   A2,-(A7)     .      
         TST      8(A7)
         BLT.S    DSPTOT0A
         CMP      8(A7),D3
         BNE      DSPTOT4
DSPTOT0A MOVEQ    #17-1,D2      
         MOVE.L   #DRVPOS,-(A7)
DSPTOT1  MOVE.L   D2,-(A7)
         MOVE.L   8(A7),A0      Point to Driver GP Total
         MOVE     (A0),D0       Get Total
         BLT      DSPTOT3       If LT, Do not Display if Total is Neg
         LSR      #8,D0         DM23JUL
         EXT.L    D0            
         LEA.L    DSPTOT5,A0    Convert Total in DSPTOT5
         JSR      TENUM         .
         MOVEQ    #0,D0
         MOVE.L   4(A7),A2      Get Position
         MOVE     (A2),D0       .
         EXT.L    D0
         BLT.S    DSPTOT3       Do not Display if Pos is Neg
         LEA.L    NUMMED1,A5    Assume Not Player
         BTST     #5,D0         Test Player (Bit 32)
         BEQ.S    DSPTOT2       If EQ, No
         BCLR     #5,D0
         LEA.L    NUMMED2,A5    Say Player
DSPTOT2  SUBQ.L   #1,D0         Compute Line from
         LSL.L    #3,D0         Position
         ADDI.L   #44,D0        in
         MULS     #160,D0       the Race
         MOVE.L   DSPTOT6,D1    Position in Line
         LEA.L    DSPTOT5,A0    .
         JSR      DSPGP         Display GP Total
DSPTOT3  ADDI.L   #2,8(A7)      Point to Next Driver GP Total 
         ADDI.L   #2,4(A7)      Point to Next Position  
         MOVE.L   (A7)+,D2       
         DBF      D2,DSPTOT1    Next Line
         ADDA.L   #4,A7         Pos
DSPTOT4  SUBI.L   #80,DSPTOT6   Advance Column
         ADDA.L   #4,A7         Gp
         MOVE.L   (A7)+,D3
         DBF      D3,DSPTOT0    Next Line
         ADDA.L   #2,A7         Mplay
         RTS
DSPTOT5  DC.W     0             Tens
         DC.W     0             Units
DSPTOT6  DC.L     0             Position in Line

* Mouse and Joystick Control Routine

JOY      DC.W     0              Boutons (0, 1=Mouse L, 2=Mouse R/Fire)
         DC.W     0              Xm
         DC.W     0              Ym
         DC.W     0              ScanCode KB
         DC.W     0              Joystick
         DC.W     0              Unused

* Miscalleanous

MESSAG   DC.L  0        Message Processing Indicator
SAVSKY   DS.W  3        Save 3 Sky Events Positions-DM25JUL
TWINCKL1 DC.L  $7       Star 1 Twinckle
TWINCKL2 DC.L  $E000000 Star 2 Twinckle
TWINCKL3 DC.L  $E000    Star 3 Twinckle
MASLAV   DC.W  0        Master/Slave
SYNC     DC.W  0        Communication (-1 = No, 0= Pys, 1=Log1, 2=Log2)
OSYNC    DC.W  0        Old Sync
JOYMOU   DC.W  0        Joy/Mouse in Selection Screen

BUFESC   DC.W  -21
BUFFN    DC.W  0       (-12 to -20)
BUFIR    DC.W  -1
CONFIG   DS.L  5

* Arcade Score

ASCORES  DS.L     9     Nine Best
STAGES   DS.W     9
PLAYERS  DS.W     9*3

DUPSCO   DS.L     9
DUPSTA   DS.W     9
DUPPLA   DS.W     9*3

ASCORE   DC.L     0     Score (Long Word but Limited to 99999)
ASCODIG  DC.W     0     Ten Thousands
         DC.W     0     Thousands
         DC.W     0     Hundreds
         DC.W     0     Tens
         DC.W     0     Units
SCOINS   DC.L     0     Insert Line for New Score (110*160,...,190*160)

* Racing Score

CSCORES  DS.W    16*(6+1) Championship Scores (Not Recorded)

RSCORES  
BSTLAP   DS.L    6      Minutes/Sec/Cent - Best Lap
         DS.B    8*6    Names

TOTLAP   DS.L    6      Minutes/Sec/cent - Best Total Time
         DS.B    8*6    Names
 
TOTPNT   DS.W    1      Best Total Points
         DS.B    8      Name

RSCUPD   DC.W    0      Racing Score Update Indicator (1=Write)
RSCORE   DC.W    0      Racing Score
TOTTIM   DC.L    0      Total Time in Circuit
LAPTIM   DC.L    0      Lap time in Circuit
BSTTIM   DC.L    0      Best Lap Time in Circuit

TIMDIG   DC.W    0      Ten Minutes 
         DC.W    0      Minutes
         DC.W    0      Ten Seconds
         DC.W    0      Seconds
         DC.W    0      Dixiemes
         DC.W    0      Centiemes

DRVPOS   DC.W    2
         DC.W    1
         DC.W    3
         DC.W    4
         DC.W    5
         DC.W    6
         DC.W    7
         DC.W    8
         DC.W    9
         DC.W    10
         DC.W    11
         DC.W    12
         DC.W    13
         DC.W    14
LASTPOS  DC.W    15             -1 if Comms
MEPOS    DC.W    32+16
HIMPOS   DC.W    -1             not -1 if Comms

EFF      DC.B    26,26,26,26,26,26,26,-1        Efface Driver
DRIVER
         DC.B    15,17,14,18,08,19,-1,-1        PROSIT
         DC.B    18,04,12,12,00,-1,-1,-1        SEMMA
         DC.B    01,20,17,06,04,17,-1,-1        BURGER
         DC.B    11,00,19,17,04,25,04,-1        LATREZE
         DC.B    12,00,13,18,00,08,11,-1        MANSAIL
         DC.B    15,14,02,10,04,19,-1,-1        POCKET
         DC.B    12,00,17,22,08,02,10,-1        MARWICK
         DC.B    00,11,01,14,17,00,19,14        ALBORATO
         DC.B    01,17,00,13,03,11,04,03        BRANDLED
         DC.B    01,00,11,12,04,17,-1,-1        BALMER
         DC.B    13,00,13,02,08,13,08,-1        NANCINI
         DC.B    01,14,14,19,18,14,13,-1        BOOTS0N
         DC.B    00,11,11,04,25,24,-1,-1        ALLEZY
         DC.B    18,20,25,20,12,00,-1,-1        SUZUMA
         DC.B    12,14,17,04,13,00,-1,-1        MORENA

* Saved Part
SAVGAM
ME       DC.B    -1,-1,-1,-1,-1,-1,-1,-1        Me
HIM      DC.B    -1,-1,-1,-1,-1,-1,-1,-1        Him (Communication)

DRVGP    DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #1
         DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #2
         DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #3
         DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #4
         DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #5
         DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #6
DRVTOT   DC.W    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1                 Total
SAVCRC   DC.W     0                                 
* End of Saved Part

POINTS   DC.W     10,6,4,3,2,1,0,0,0,0,0,0,0,0,0,0,-1

* Screen Addresses

ACTSCR   DC.L     0
SCRADR   DC.L     SCR1EQU
         DC.L     SCR2EQU
CURSCR   DC.L     0      

* Select Boxes

HC       SET      129           Start Col
LC       SET      73            Left Col
RC       SET      185           Right Col
HL       SET      75            Start Lin
FL       SET      102           First Lin
SL       SET      121           Second Lin
TL       SET      140           Third Lin

BOXI     DC.L     FSTAR

FSTAR    DC.L     0     1 From START
         DC.L     FGAME 2
         DC.L     0     3
         DC.L     FGAME 4
         DC.L     0     5
         DC.L     0     6
         DC.L     0     7
         DC.L     FCOMM 8
         DC.L     0     9
         DC.L     0     10
CSTAR    DC.L     HC     X
         DC.L     HL*160 Y
MSTAR    DC.L     0     Always 0
ASTAR    DC.L     0
         DC.L     STARTER
         DC.L     0

FGAME    DC.L     FSTAR 1 From START
         DC.L     FPLAY 2
         DC.L     0     3
         DC.L     FCOMM 4
         DC.L     0     5
         DC.L     0     6
         DC.L     0     7
         DC.L     FCOMM 8
         DC.L     0     9
         DC.L     0     10
CGAME    DC.L     LC     X
         DC.L     FL*160 Y
MGAME    DC.L     0             Arcade (-8=Q 0=A, 8=R, 16=D, 24/-16=T)
AGAME    DC.L     $80000018     Action Mode
         DC.L     ARCADE
         DC.L     ACTARC        Action on Arcade
         DC.L     RACING
         DC.L     ACTRAC        Action on Racing
         DC.L     DEMON
         DC.L     ACTDEM        Action on Demonstration
         DC.L     TRAIN
         DC.L     ACTTRA        Action on Training


FCOMM    DC.L     FSTAR 1 
         DC.L     FLAPS 2
         DC.L     0     3
         DC.L     FGAME 4
         DC.L     0     5
         DC.L     0     6
         DC.L     0     7
         DC.L     FGAME 8
         DC.L     0     9
         DC.L     0     10
CCOMM    DC.L     RC     X
         DC.L     FL*160 Y
MCOMM    DC.L     $80000000 Locked on NOCOMM   
ACOMM    DC.L     8      (12)
         DC.L     NOCOMM        
         DC.L     LOCAL
         DC.L     MODEM
         DC.L     MINITEL

FPLAY    DC.L     FGAME 1 
         DC.L     FCONT 2
         DC.L     0     3
         DC.L     FLAPS 4
         DC.L     0     5
         DC.L     0     6
         DC.L     0       7
         DC.L     FLAPS 8
         DC.L     0     9
         DC.L     0     10
CPLAY    DC.L     LC     X
         DC.L     SL*160 Y
MPLAY    DC.L     $80000000     Lock on ALL       
APLAY    DC.L     24            Action Mode
         DC.L     ALL           
         DC.L     GP1           
         DC.L     GP2
         DC.L     GP3
         DC.L     GP4
         DC.L     GP5
         DC.L     GP6

FLAPS    DC.L     FCOMM 1 
         DC.L     FGEAR 2
         DC.L     0     3
         DC.L     FPLAY 4
         DC.L     0     5
         DC.L     0     6
         DC.L     0     7
         DC.L     FPLAY 8
         DC.L     0     9
         DC.L     0     10
CLAPS    DC.L     RC     X
         DC.L     SL*160 Y
MLAPS    DC.L     $80000010     Locked on LAPS5 (0,4,8,A,10,...)
ALAPS    DC.L     36
         DC.L     LAPS1
         DC.L     LAPS2
         DC.L     LAPS3 
         DC.L     LAPS4
         DC.L     LAPS5
         DC.L     LAPS6
         DC.L     LAPS7
         DC.L     LAPS8
         DC.L     LAPS9
         DC.L     LAPS10

FCONT    DC.L     FPLAY 1 
         DC.L     FSTAR 2
         DC.L     0     3
         DC.L     FGEAR 4
         DC.L     0     5
         DC.L     0     6
         DC.L     0     7
         DC.L     FGEAR 8
         DC.L     0     9
         DC.L     0     10
CCONT    DC.L     LC     X
         DC.L     TL*160 Y
MCONT    DC.L     0       
ACONT    DC.L     4
         DC.L     MOUS
         DC.L     JOYS

FGEAR    DC.L     FLAPS 1 
         DC.L     FSTAR 2
         DC.L     0     3
         DC.L     FCONT 4
         DC.L     0     5
         DC.L     0     6
         DC.L     0     7
         DC.L     FCONT 8
         DC.L     0     9
         DC.L     0     10
CGEAR    DC.L     RC     X
         DC.L     TL*160 Y
MGEAR    DC.L     0       
AGEAR    DC.L     4
         DC.L     MANUAL
         DC.L     AUTO

* Messages

MSGCOM1  DC.B     04,18,19,00,01,11,08,18,07,08,13,06    Establishing
         DC.B     26,02,14,12,12,20,13,08,02,00,19,08,14,13 Communication
         DC.B     -1
         CNOP     0,2
MSGCOM2  DC.B     02,14,12,12,20,13,08,02,00,19,08,14,13 Communication
         DC.B     26,04,18,19,00,01,11,08,18,07,04,03    Established
         DC.B     -1
         CNOP     0,2
MSGCOM3  DC.B     02,14,12,12,20,13,08,02,00,19,08,14,13 Communication
         DC.B     26,05,00,08,11,04,03                   Failed
         DC.B     -1
         CNOP     0,2
MSGLOS   DC.B     02,14,12,12,20,13,08,02,00,19,08,14,13 Communication
         DC.B     26,11,14,18,19                            Lost
         DC.B     -1
         CNOP     0,2         
MSGABO   DC.B     02,14,12,12,20,13,08,02,00,19,08,14,13 Communication
         DC.B     26,00,01,14,17,19,04,03                Aborted
         DC.B     -1
         CNOP     0,2            
MSGAB1   DC.B     02,14,12,12,20,13,08,02,00,19,08,14,13 Communication
         DC.B     26,00,01,14,17,19,04,03                Aborted DM18JUL
         DC.B     26,01,24,26,14,19,07,04,17             By Other
         DC.B     -1
         CNOP     0,2    
MSGESC   DC.B     06,00,12,04                            Game 
         DC.B     26,04,18,02,00,15,04,03                Escaped
         DC.B     -1
         CNOP     0,2
MSGESC1  DC.B     06,00,12,04                            Game 
         DC.B     26,04,18,02,00,15,04,03                Escaped
         DC.B     26,01,24,26,14,19,07,04,17             By Other
         DC.B     -1
         CNOP     0,2
MSGSAV   DC.B     06,00,12,04                            Game 
         DC.B     26,18,00,21,04,03                      Saved 
         DC.B     -1
         CNOP     0,2
MSGSAV1  DC.B     06,00,12,04                            Game 
         DC.B     26,18,00,21,04,03                      Saved
         DC.B     26,01,24,26,14,19,07,04,17             By Other
         DC.B     -1
         CNOP     0,2
MSGBLK   DC.B     26,26,26,26,26,26,26,26,26,26,26,26,26 Blank
         DC.B     26,26,26,26,26,26,26,26,26,26,26,26,26 Message
         DC.B     -1
         CNOP     0,2

* Script

SCPEND   DS.L     1     Pointer in Pseudo Script
SCPADR   DS.L     1     Pointer to Script
SCPINC   DC.W     0     Bit increment From SCRADR

* Pseudo Script in MEM (V5)

         DC.W     $FFFF      For End of Mem Test
SCPSIM   DS.B     160
         DC.L     $FFFF      For End Of Mem Test

* Files

HDL      DC.W     1

SCAFIL   DC.B     'ARCADE.DAT'   Arcade Score
         DC.B     0
         CNOP     0,2

SCRFIL   DC.B     'RACING.DAT'   Racing Score
         DC.B     0
         CNOP     0,2

SAVFIL   DC.B     'SAV'          Save Racing
SAVFIL0  DC.B     0
         DC.B     '.DAT'    
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

MUSGEN   DC.B     'GENERI.DAT'
         DC.B     0
         CNOP     0,2

CRCOBJ   DC.L     0             Loading Ad for Objetcs Unique to Circuit

CRCGRA   DC.L     CR1BCK
         DC.L     CR2BCK
         DC.L     CR3BCK
         DC.L     CR4BCK
         DC.L     CR5BCK
         DC.L     CR6BCK

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

CRCBAN   DC.L     CR1BAN
         DC.L     CR2BAN
         DC.L     CR3BAN
         DC.L     CR4BAN
         DC.L     CR5BAN
         DC.L     CR6BAN

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

CRCDAT   DC.L     CR1DAT
         DC.L     CR2DAT
         DC.L     CR3DAT
         DC.L     CR4DAT
         DC.L     CR5DAT
         DC.L     CR6DAT

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

CRCDEM   DC.L     CR1DEM
         DC.L     CR2DEM
         DC.L     CR3DEM
         DC.L     CR4DEM
         DC.L     CR5DEM
         DC.L     CR6DEM

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

* Palettes

F1PAL    DS.B     2              F1 Screen
F1PAL0   DS.B     32

SCOPAL   DS.B     2              Score Screen
SCOPAL0  DS.B     32

CRCPAL   DS.B     32             For Circuit

CRCPIL   DS.B     2             
CRCPIL0  DS.B     32
         
BANPAL   DS.B     32             For Banner

BANPIL   DS.B     2
BANPIL0  DS.B     32

BLKPAL   DS.B     32             Black Palette

GRDPAL   DC.W     $0000          Medium Palette : Noir
         DC.W     $0000                           Noir (Effacage)
         DC.W     $0700                           Rouge
         DC.W     $0774                           Beige
         DS.W     12             Useless
         DS.B     2         


         END
