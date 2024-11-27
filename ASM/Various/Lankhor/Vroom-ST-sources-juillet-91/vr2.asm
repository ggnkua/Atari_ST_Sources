         TTL      VR2 - Game Play - V15 - 26 Jul 91 

*DM20JUL : DSPGAZ 
*DM21JUL : JOYSTICK + PROSKY + NO BREAK IN 1 LANE
*DM26JUL : Allow Gazfil & Tirchg is ENDCRC Sequence
*          Pas de Pente en LOCK
*          
*DM27JUL : Cars Overpass like F1 & F2

         INCLUDE  "TOS.ASM"
         INCLUDE  "EQU.ASM"

         XDEF     GAME,DEMBLD
         XDEF     CRCNUM,CRCMAX,MAXLAP,SAVLAP,CRCLAP
         XDEF     CAR1PAS,CAR2PAS
         XDEF     OCCUR,Y1,XB,CARSRT,FEVTAD,F1SRT
         XDEF     RIGROD,LEFROD,ACCEL,RPMIN
         XDEF     JUMPE,CRASHE,SP1D,LAP,TIRUSE
        
         XREF     JOY,CRCPAL,CRCPIL0,BANPAL,BANPIL0,CARINI
         XREF     NEWGAM,NEWCRC,ARCSCR,RACSCR
         XREF     ASCORE,ASCODIG,PALSOMB,DCHAMP,MODTAB
         XREF     TOTTIM,LAPTIM,BSTTIM,TIMDIG
         XREF     INIBCK,PANBCK,RESKY,WRFIL
         XREF     DSPIS,DSPITN,DSPITN0
         XREF     SPRITE,INSADIG
         XREF     DSPTXT,DSPSPD,DSPLIG,COPSCR
         XREF     DSPCAR,DSPTIR,DSPRET,DSPNOR
         XREF     DSPOLR,DSPORR,DSPVOY
         XREF     BDOT,WDOT,RDOT,ININXT,INFTOP,UPDLAN
         XREF     TTNUM,THNUM,HUNUM,TIMNUM
         XREF     MOMTBL,GVVTBL,GVNTBL,GNNTBL,GAUTBL,GDNTBL
         XREF     OVRCAR,OVPCAA,OVMCAA
         XREF     DSPSCR,DSPTMR,DSPTMQ,DSPLAP,SWPSCR
         XREF     DSPFIR,DSPREG,DSPGER,DSPGAZ,DSPCUP     DM26JUL
         XREF     MGAME,MCOMM,MLAPS,MCONT,MGEAR
         XREF     demson,coupson
         XREF     SENDIR,BUFRECE,PNTRECE 
         XREF     SYNC,MASLAV
         XREF     degre,evnco,evnmo,esevt1,figam,vitco,topcod,tstcra
         XREF     haldco,decaco,mvtscrol,reste,volant,topvib,htprl
         XREF     CMPROD,DSPROD
         XREF     ACTSCR,SCRADR,CURSCR
         XREF     NTIR,BTIR,TIRLIG,ENGLIG
         XREF     PANIM,PVOL
         XREF     FROTT
         XREF     F1DEP
         XREF     MESSAG,MSGESC,MSGLOS

* XREF to Items

         XREF     ACCID1,ACCID2,SMOKE,TIRE            ITDV.ASM
         XREF     TIRMAN,GAZMAN                       "
         XREF     GAMOVR,NXTCRC,DEMONS,DEMOVR         "
         XREF     RACE,RACOVR,LIGHT                   "
         XREF     NUMSCR                              "
         XREF     ZEPLL,ZEPLR,PLANL,PLANR,BALL        ITSK.ASM
         XREF     FUJI,TOWER,DESERT,MOUNT             "
         XREF     CLOUD1,CLOUD2,CLOUD3,CLOUD4         "
         XREF     CLOUD5,CLOUD6                       "

* Start of Program

ER3C:   DC.W    0
GAME
         JSR      demson
         JSR      INSADIG

* Train Mode : MGAME = -16 Instead of 24
        
         CMPI.L   #24,MGAME
         BNE.S    INILIG
         MOVE.L   #-16,MGAME

* Light Initialization

INILIG   MOVE     #1,LIG         Say Red
         MOVE     #30,LIGCNT    
         MOVE     MGAME+2,D0     
         BLE.S    INILIGF        If LE, Arcade/Qualif/Train      
         MOVE     #-1,LIG        RACE/DEMO : Say Red 
         LEA.L    LIG,A0         Display Light Green OFF/Red ON/Yellow OFF
         LEA.L    LIGHT,A5       .
         JSR      DSPLIG         .
         MOVE     #1,LIG         Say Red
INILIGF

* Circuit Initialisation 

CINIT    MOVE.L   #CRCEVT,FEVTAD First Event Pointer Address (Pas sur!!!)
         MOVE.L   #CRCLON,A0     Circuit Length
         MOVE.L   (A0),CRCLAP    .
         MOVE.L   #CRCSCA,A0     Circuit Scale
         MOVE     (A0),CRCECH    .

* Road Initialisation

         CLR      evnmo          Init JLL Data
         CLR.L    degre          .
         CLR      vitco          .
         CLR.L    haldco         .
         CLR.L    decaco         .
         CLR      reste          .
         CLR.L    figam          .
         MOVE.L   #esevt1,figam+4 
         MOVE.L   #0,figam+8 .
         LEA.L    topcod,A0      Clear topcod
         CLR.L    (A0)+          and
         CLR.L    (A0)+          following
         CLR      (A0)           4 Words.

* Initialisation of Background 1/2 in Screens #1 and #2

         JSR      INIBCK         Init Background Pointers

* Joystick/Mouse Init

         CLR.L    JOY            
         CLR.L    JOY+4
         CLR      JOY+8
         CLR      FIRE
         CLR      AUTO

* Initial Screen Selection

         CLR.L    ACTSCR         Screen #1 Off/Active
         LEA.L    SCRADR,A0      Put Screen #1 address on Stack
         MOVE.L   (A0),CURSCR    .
         MOVE     #1,FIRST       Say First Loop

* Car Initialisation 
     
CRINIT   LEA.L    CARSRT,A0

         MOVEQ    #16-1,D0        
CRINIT0  MOVE.W   #-1,(A0)+      Inactive Cars
         DBF      D0,CRINIT0

         LEA.L    CARSRT,A0      
         LEA.L    CARINI,A2

         MOVEQ    #16-1,D0       Assume Racing
         MOVE.L   #150+15*600+2,D3
         TST      MGAME+2  
         BGT.S    CRINIT00       Race/Demo
         MOVE.B   #0,CAR1PAS     Here Arcade/Qualif/Train 
         TST      MCOMM+2
         BLE.S    CRINIT0A  
         MOVE.B   #1,CAR2PAS     Assume F1 Slave 
         MOVE.B   #0,CAR1PAS                     
         TST      MASLAV
         BEQ.S    CRINIT0A
         MOVE.B   #0,CAR2PAS     Say F1 Master
         MOVE.B   #1,CAR1PAS               
CRINIT0A MOVEQ    #7-1,D0        
         MOVE.L   #5376,D3       *** #VIEWLEN ***
CRINIT00 MOVEQ    #0,D2
         MOVE.B   CAR1PAS,D2     Init F1SRT
         SUB.L    D0,D2          .
         NEG.L    D2             .
         LSL.L    #1,D2          .
         MOVE.L   D2,F1SRT       .
         MOVE.W   #57,D2         Init X
         LEA.L    OCCUR+64,A1
         MOVE     #64,D7
         TST      MCOMM+2
         BLE.S    CRINIT1
         LEA.L    OCCUR+128,A1
         MOVE     #128,D7
CRINIT1  CLR      -(A7)
         CLR      -(A7)
         CLR.L    -(A7)
         CMP.B    CAR1PAS,D0     F1 Car
         BNE.S    CRINIT2        If NE, No

         MOVE.L   A1,(A7)        HERE F1
         MOVE     D7,4(A7)
         MOVE     D1,6(A7)
         MOVE     #1000,RPMIN    Init Round per Minute
         CLR.L    SP1D           Speed
         CLR.W    SAVSP1D       MODJLL
         CLR.L    GEAR           Gear & pgear
         CLR      GRDOWN
         CLR.L    volant
         CLR      WHLINC
         CLR      ACCEL
         LEA.L    OCCUR,A1
         MOVE     #0,D7
         MOVE.B   #-1,D1        -1=F1       
         MOVE     #0,D4         Nominal X
         MOVE.L   #0,D6   
         BRA.S    CRINIT3A

CRINIT2  TST      MCOMM+2         
         BLE.S    CRINIT3
         CMP.B    CAR2PAS,D0     F2 Car? 
         BNE.S    CRINIT3        If NE, No
         MOVE.L   A1,(A7)        HERE F2
         MOVE     D7,4(A7)
         MOVE     D1,6(A7)
         LEA.L    OCCUR+64,A1
         MOVE     #64,D7
         MOVE.B   #0,D1          0 = F2/Red
         MOVE     #0,D4          Nominal X
         MOVE.L   #0,D6   
         BRA.S    CRINIT3A

CRINIT3  MOVE     (A2)+,D1       HERE NORMAL
         TST      MCOMM+2
         BLE.S    CRINIT3B
         CMPI     #2,D1          Red Car in Comm
         BNE.S    CRINIT3B       Becomes Green
         MOVE     #4,D1
CRINIT3B MOVE     (A2)+,D4
         MOVE.L   (A2)+,D6        

CRINIT3A MOVE     D7,(A0)+       HERE COMMON TO F1, F2, NORMAL
         MOVE.L   A1,A3
         MOVE.B   D1,(A3)+       Event Number (-1=F1,0=F2,2,4,6)
CRINIT4  MOVE.B   #2,(A3)+

         TST.B    D1             F1?
         BPL      CRINIT4C       If PL, No
         MOVE.L   D3,-(A7)       Y F1 Car
         TST      MGAME+2        
         BGT      CRINIT4A       IF GT, Racing/Demo
         TST      MCOMM+2        Arcade/Train/Qualif      
         BLE.S    CRINIT4B
         MOVE.L   #400,D3        Assume F1 Master   
         TST      MASLAV
         BNE.S    CRINIT4A 
CRINIT4B MOVEQ    #2,D3          Say F1 Slave
CRINIT4A MOVE.L   D3,(A3)+       Store YF1
         DIVS     CRCECH,D3
         MOVE     D3,P1CRC       Position F1 
         MOVE     D3,P1CRC+4     .
         MOVE.L   (A7)+,D3
         BRA      CRINIT4E

CRINIT4C TST.B    D1             F2?
         BGT.S    CRINIT4G       If GT, No
         MOVE.L   D3,-(A7)
         TST      MGAME+2
         BGT      CRINIT4D       If GT, Racing/Demo
         MOVE.L   #400,D3        Assume F2 Master   
         TST      MASLAV
         BEQ.S    CRINIT4D 
         MOVEQ    #2,D3          Say F2 Slave
CRINIT4D MOVE.L   D3,(A3)+       Store YF2
         DIVS     CRCECH,D3
         MOVE     D3,P2CRC       Position F2
         MOVE     D3,P2CRC+4     .
         MOVE.L   (A7)+,D3
         BRA.S    CRINIT4E

CRINIT4G MOVE.L   D3,(A3)+       Normal and Racing/demo
CRINIT4E SUBI.L   #600,D3
         MOVE     D4,(A3)+       Nominal X
         NEG      D2
         SUBI     #132,D2
         MOVE     D2,(A3)+       Current X
         CLR      (A3)+          Lap #
         MOVE.L   D6,(A3)+       Max Speed
         MOVEQ    #0,D5          Assume Racing
         TST      MGAME+2          
         BGT.S    CRINIT7        IF GT, Racing/Demo
         TST.B    D1             Arcade/Qualif/Train and F1?
         BLT.S    CRINIT7        If LT, Yes
         MOVE.L   -4(A3),D5      
CRINIT7  MOVE.L   D5,(A3)+       Current Speed
         MOVE.B   D0,39(A3)      CARnPAS in 59
         MOVE.L   #0,40(A3)      
         MOVEM.L  D1-D3,-(A7)        
         JSR      ININXT
         MOVEM.L  (A7)+,D1-D3
         TST.L    (A7)
         BEQ.S    CRINIT8
         MOVE.L   (A7)+,A1
         MOVE     (A7)+,D7
         MOVE     (A7)+,D1
         BRA.S    CRINIT9
CRINIT8  ADDQ.L   #8,A7

         ADDA.L   #64,A1
         ADDI.L   #64,D7
CRINIT9  DBF      D0,CRINIT1
         MOVE     X1,D0         Initialize XB=-(X1+29+37)
         MOVE.W   D0,SAVX1      MODJLL
         NEG      D0            .
         SUBI     #29+37,D0     .
         MOVE     D0,XB         .
         EXT.L    D0
         ASL.L    #2,D0         
         MOVE.L   D0,decaco         
         MOVE     #0,DX1        and Delta X1
CRINITF

*INIT COMPORTEMENT         MOD1JL
         LEA.L    OCCUR+64(PC),A1
         MOVE.W   #14,D5
BINCOMP: CLR.B    44(A1)
         MOVE.W   MGAME+2(PC),D4
         BLE.S    SINCOMP
         MOVE.W   D5,D0
         LSL.W    #3,D0
         ADD.W    #50,D0
         MOVE.B   #4,44(A1)
         MOVE.B   D0,45(A1)
         MOVE.W   14(A1),D4
         MOVE.W   D4,48(A1)
         LSR.W    #3,D4
         ADD.W    D4,14(A1)         BOOST POUR DEMARR
         MOVE.W   #256,46(A1)
         SUB.W    D0,46(A1)
SINCOMP: LEA.L    64(A1),A1
         DBF      D5,BINCOMP

* Display F1 CarDot on Circuit

F1DI     MOVE.L   #CRCDRW,A1     Point to Circuit Drawing
         MOVE.L   ACTSCR,D5      Point to Position
         MOVE     P1CRC,D4       On Both Screens
         JSR      BDOT           Display Black Dot
         EORI.L   #4,D5
         MOVE     P1CRC+4,D4     
         JSR      BDOT

* Display F2 CarDot on Circuit
 
F2DI     TST      MCOMM+2
         BLE      F2DIF
         MOVE.L   #CRCDRW,A1     Point to Circuit Drawing
         MOVE.L   ACTSCR,D5      Point to Position
         MOVE     P2CRC,D4       on Both Screens         
         JSR      RDOT           Display Red Dot
         EORI.L   #4,D5
         MOVE     P2CRC+4,D4     
         JSR      RDOT
F2DIF

* Jump and Shake Initialisation

         MOVE     #-1,JUMPE      No Jump (DM)
         MOVE     #-1,JUMPE+2    No Jump (JLL)
         MOVE     #-1,CRASHE     No Crash (DM)
         MOVE     #-1,CRASHE+2   No Crash (JLL)
         MOVE     #-1,SHIFTE     No Shift

* Miscalleaneous Initialisations
        
         MOVE     #-1,DEMO                  
         CMPI     #16,MGAME+2    Demo mode
         BNE.S    MISC0          
         CLR      DEMO           Say Demo
*         MOVEQ    #2,D0          MODJLL
*         MOVE.W   D0,DCHAMP+2
*         JSR      MODTAB
MISC0    CLR      STEP           Say no Step Mode
         CLR.L    FROTT
         CLR      CAAPAS         
         CLR      ENDCRC
         CLR      ESCAP
         CLR      DELSCO
         CLR      RETFIR
         CLR      LOCK           Unlock Command
         CLR      F12END
         TST      MCOMM+2
         BLE.S    MISC1
         BSET     #4,LOCK
MISC1    CLR      BTIR           TIRES not Broken
         CLR      NTIR
         CLR      topvib
         CMPI     #8,MGAME+2     Racing
         BNE.S    MISC2
         MOVEQ    #0,D0
         MOVE     GAZ,D0
         BPL.S    MISC1A
         MOVE     #0,D0
MISC1A   MOVE     #-1,D1         DM20JUL
         JSR      DSPGAZ
MISC2    MOVE     #25599,GAZ     DM15JUL
         MOVE     #2048,TIRUSE   New Tires 
         CLR      TIRLIG         Green Tire Light
         MOVE     #2048,ENGUSE   New Engine
         CLR      ENGLIG         Green Engine Light
         MOVE     #-1,CHGTIR     Not Changing Tires
         MOVE     #-1,FILGAZ     Not Filling Gaz
         MOVE     #-128,htprl    Say Down
         CLR      LASTLAP        Last Lap for Racing if 1

* MAIN LOOP

MLOOP

* Joystick/Mouse Control 

JOYMOU   TST      LOCK           Commands are Locked?
         BNE      JOYMOUF        If NE, Yes
         TST.L    MCONT          Joystick Control?
         BGT      MAN            If GT, Yes

MOUS     MOVE     DEMO,D5
         BLT.S    MOUS0
         MOVE.L   #DEMEQU+2,A5
         MOVE.B   0(A5,D5),D1    Y
         EXT      D1
         CLR.W    D2
         MOVE.B   1(A5,D5),D2    X
         MOVE.B   2(A5,D5),D3    Fire or RAW
         BCLR     #4,D3
         BEQ.S    MOUSJLL
         ORI.W    #$FF00,D2    
MOUSJLL  ADD      #3,DEMO
         BRA.S    MOUS0A

MOUS0    MOVE     JOY+4,D1       
         MOVE     JOY+2,D2       
         MOVE.B   JOY+1,D3

MOUS0A   TST      D1             Here Mouse Y Control
         BEQ.S    MOUS3         
         BGT.S    MOUS1          If PL, Braking

         CMPI     #-94,D1        Accelerating
         BPL.S    MOUS3
         MOVE     #-94,D1
         BRA.S    MOUS2

MOUS1    CMPI     #94,D1         Braking
         BLE.S    MOUS3
         MOVE     #94,D1

MOUS2    MOVE     D1,JOY+4 
MOUS3    MOVE     D1,D0
         NEG      D0 
         MOVE     D0,ACCEL       0 to +-94

MOUS4A   TST      D2             Here Mouse X Control      
         BPL.S    MOUS6           
         CMPI     #-34*8,D2      
         BGT.S    MOUS7
         MOVE     #-34*8+1,D2    
         BRA.S    MOUS61
MOUS6    CMPI     #34*8,D2       
         BLT.S    MOUS7
         MOVE     #34*8-1,D2
MOUS61   MOVE     D2,JOY+2      
MOUS7    MOVE     D2,volant
     
MOUS30   TST.L    MGEAR          MOUSE GEAR CONTROL
         BGT      MOUF           If GT, Automatic Gear
         BTST     #1,D3          Gear Up?
         BEQ.S    MOUS31         If Eq, No
         TST      FIRE
         BNE      MOUF
         MOVE     #1,FIRE        Say Dead Point Up
         BRA.S    MOUS32
MOUS31   BTST     #0,D3          Gear Down
         BEQ      MOUS33         If Eq, No
         TST      FIRE
         BNE      MOUF
         MOVE     #-1,FIRE       Say Dead Point Down
MOUS32   MOVE     GEAR,PGEAR
         CLR      GEAR
         BRA      MOUF
MOUS33   TST      FIRE
         BEQ      MOUF
         BLT.S    MOUS34
         MOVE     PGEAR,D0       Here Changing Up
         ADDI     #1,D0          Inc Gear
         CMP      #6,D0          Test If Max Gear
         BLT.S    MOUS35
         MOVE     #6,D0
         BRA.S    MOUS35
MOUS34   MOVE     PGEAR,D0       Here Changing Down
         SUB      #1,D0
         TST      D0             Test Gear >0
         BPL.S    MOUS35
         CLR      D0
MOUS35   MOVE     D0,GEAR        Update Gear
         CLR      FIRE

MOUF     MOVE     DEMBLD,D5      Demo Build?
         BLT      JOYMOUF        If LT, No
         MOVE.L   #DEMEQU+2,A5   Put Move in DEMEQU
         MOVE.B   D1,0(A5,D5)    Y Mouse
         BTST     #15,D2        
         BEQ.S    MOUF1
         CMP.W    #-256,D2      
         BGE.S    ETJL1
         MOVE.W   #-256,D2
         MOVE.W   D2,volant
ETJL1    BSET     #4,D3
         BRA.S    ETJL2
MOUF1    CMP.W    #255,D2
         BLE.S    ETJL2
         MOVE.W   #255,D2
         MOVE.W   D2,volant
ETJL2    MOVE.B   D2,1(A5,D5)    X Mouse
         MOVE.B   D3,2(A5,D5)    Fire        
         ADD      #3,DEMBLD
         BRA      JOYMOUF

MAN      MOVEQ    #0,D0
         MOVE     JOY,D1         Mix Fire and Joystick
         BCLR     #0,D1          Erase Left Mouse Button
         LSL      #6,D1          .
         MOVE     JOY+8,D0       .
         OR       D1,D0          .
         TST.B    D0
         BPL.S    MAN6           If PL, No Fire
         ANDI.B   #$7F,D0        Clear Fire Bit
         TST.L    MGEAR          Automatic?
         BGT.S    MAN6           If GT, Yes
         TST      FIRE           First Time
         BNE.S    MAN7           If NE, No
         MOVE     #1,FIRE        Say Dead Point
         MOVE     GEAR,PGEAR     Save Previous Gear
         CLR      GEAR           .
         BRA.S    MAN7
MAN6     TST      FIRE
         BLE.S    MAN7
         MOVE     #-1,FIRE
         MOVE     PGEAR,GEAR     Restore Gear
MAN7     LSL      #3,D0          Build Pointer in JOYACT Table
         LEA.L    JOYACT,A0      .
         MOVE.L   0(A0,D0),A1    .
         JSR      (A1)           1st Action
         MOVE.L   4(A0,D0),A1
         JSR      (A1)           2nd Action
         BRA      JOYMOUF
 
JOYACT   DC.L     DUMMYA 0 No Action
         DC.L     DUMMYB

         DC.L     FAST    1 Speed Up
         DC.L     DUMMYB

         DC.L     SLOW    2 Speed Down
         DC.L     DUMMYB

         DC.L     DUMMYA  3 No Action
         DC.L     DUMMYB

         DC.L     DUMMYA  4 
         DC.L     LEFT      Left

         DC.L     FAST    5 Speed Up
         DC.L     LEFT      Left

         DC.L     SLOW    6 Speed Down
         DC.L     LEFT      Left

         DC.L     DUMMYA  7 No Action
         DC.L     DUMMYB

         DC.L     DUMMYA  8 
         DC.L     RIGHT     Right

         DC.L     FAST    9 Fast
         DC.L     RIGHT     Right

         DC.L     SLOW   10 Slow
         DC.L     RIGHT     Right

DUMMYA   TST      FIRE          No Action Fast/Slow
         BPL.S    DUMMYA0
         CLR      FIRE
DUMMYA0  MOVE     ACCEL(PC),D1
         BEQ.S    DUMMYAF   
         BLT.S    DUMMYA1
         SUBI     #0,D1         Pas de d‚cceleration
         BPL.S    DUMMYA4
         BRA.S    DUMMYA3
DUMMYA1  ADDI     #12,D1
         BLT.S    DUMMYB4
DUMMYA3  CLR      D1
DUMMYA4  MOVE     D1,ACCEL       
DUMMYAF  CLR      GRDOWN
         RTS

DUMMYB   CLR      WHLINC        No Action Right/Left
         MOVE     volant(PC),D1
         BEQ.S    DUMMYBF   
         BLT.S    DUMMYB1
         SUBI     #12,D1
         BPL.S    DUMMYB4
         BRA.S    DUMMYB3
DUMMYB1  ADDI     #12,D1
         BLT.S    DUMMYB4
DUMMYB3  CLR      D1
DUMMYB4  MOVE     D1,volant     
DUMMYBF  RTS

RIGHT    MOVE     volant(PC),D1      Going Right 
         BPL.S    RIGHT7                
         CMPI     #-50,D1
         BPL.S    RIGHT1
         MOVE     #-50,volant
         RTS
RIGHT1   MOVE     #0,volant
         RTS
RIGHT7   ADDI     #24,D1
         CMPI     #270,D1
         BLE.S    RIGHT8
         MOVE     #270,D1
RIGHT8   MOVE     D1,volant
         RTS

LEFT     MOVE     volant,D1      Going Left 
         BLE.S    LEFT7                
         CMPI     #50,D1
         BLE.S    LEFT1
         MOVE     #50,volant
         RTS
LEFT1    MOVE     #0,volant
         RTS
LEFT7    SUBI     #24,D1
         CMPI     #-270,D1
         BPL.S    LEFT8
         MOVE     #-270,D1
LEFT8    MOVE     D1,volant
         RTS

FAST     CLR      GRDOWN
         TST      FIRE
         BPL.S    FAST2
         MOVE     GEAR,D1        Here Changing
         ADDI     #1,D1          Inc Gear
         CMP      #6,D1          Test If Max Gear
         BLT.S    FAST1
         MOVE     #6,D1
FAST1    MOVE     D1,GEAR        Gear Up
         CLR      FIRE
         RTS
FAST2    MOVE     ACCEL,D1       
         BLT.S    FAST5        
         ADDI     #8,D1          Currently Accelerating
         TST      topvib 
         BEQ.S    FAST3 
         ADD      #6,D1          Currently Accelerating     
FAST3    CMPI     #96,D1         Accelerate 
         BLT.S    FAST9          Up to Max Accelerating
         MOVE     #88,D1         .
         BRA.S    FAST9
FAST5    MOVE     #0,D1          Stop Braking and Reaccelerate
FAST9    MOVE     D1,ACCEL       .
         RTS

SLOW     TST      FIRE
         BEQ.S    SLOW2
         BPL.S    SLOW5          If PL, Dead Point
         MOVE     GEAR,D1        Here Changing
         SUB      #1,D1
         TST      D1             Test Gear >0
         BPL.S    SLOW1
         CLR      D1
SLOW1    MOVE     D1,GEAR        Gear Down
         MOVE     #-5,GRDOWN     Prevent from Braking 1/2 Second
         CLR      FIRE
         RTS
SLOW2    TST      GRDOWN
         BPL.S    SLOW2A
         ADDI     #1,GRDOWN
SLOW2A   MOVE     ACCEL,D1       
         BGT.S    SLOW5          
         SUB      #6,D1          Currently Braking     
         CMPI     #-96,D1        Brake 
         BGT.S    SLOW9          Up to Max Braking
         MOVE     #-88,D1        .
         BRA.S    SLOW9
SLOW5    MOVE     #0,D1
SLOW9    MOVE     D1,ACCEL       .
         RTS

JOYMOUF

* KB Input

RAW      TST      MCOMM+2
         BLE.S    RAWCONF
         CLR      SNDBUF
         TST      SYNC           Comm Lost
         BLT      COMLOS         If GT, Yes 
RAWCONF  MOVE     DEMO,D5
         BLT.S    RAW1
         MOVE.L   #DEMEQU+2,A5
         MOVE.B   2(A5,D5),D3    RAW?
         BPL.S    RAW1           If PL, No
         CLR      D0
         MOVE.B   1(A5,D5),D0
         ADD      #3,DEMO
         BRA.S    RAW2
RAW1     MOVE     JOY+6,D0       Get Char
RAW2     CLR      JOY+6          .
         CLR      D2             ** Assume no Move????? **
         TST      STEP           Step Mode?
         BEQ.S    RAWNOR         If EQ, No
         TST      D0             Loop Until ...
         BEQ.S    RAW            ... Key Stroke
         BRA.S    RAWDB
RAWNOR   TST      D0
         BEQ      RAWF

RAWDB    MOVE     DEMBLD,D5      Demo Build?
         BLT.S    RAWESC         If LT, No
         MOVE.L   #DEMEQU+2,A5   Put Key in CRCDEM
         MOVE.B   #0,0(A5,D5)
         MOVE.B   D0,1(A5,D5)    Key Code
         MOVE.B   #-1,2(A5,D5)   Key Indicator = -1        
         ADD      #3,DEMBLD
RAWESC   CMPI     #$0001,D0      ESC?
         BNE.S    RAWF1
         TST      MCOMM+2
         BLE      ESCAPE
         BSET.B   #7,SNDBUF+1    Say F1 Has Escaped for SENDIR
         BSET     #5,LOCK        Lock
         BSET     #0,F12END      .
         MOVE     #1,ESCAP
         BRA      RAWF
         
RAWF1    CMPI     #$003B,D0      F1?
         BNE.S    RAWSPA
         JSR      coupson
         DC.W     $4AFC          Illegal
         
RAWSPA   CMPI     #$0039,D0      Space= Pause?
         BNE.S    RAWTAB
         LEA.L    STEP,A1
         EORI     #1,(A1)
         BEQ.S    SPAREC 
         MOVE.L   TOTTIM,STEP+2
         BRA      RAWF
SPAREC   MOVE.L   STEP+2(PC),TOTTIM
         BRA      RAWF

RAWTAB   CMPI     #$44,D0
         BNE.S    RAWDEM
         MOVE.W   DCHAMP+2,D0
         ADDQ.W   #1,D0
         AND.W    #$3,D0
         MOVE.W   D0,DCHAMP+2
         JSR      MODTAB
         BRA      RAWF

RAWDEM   CMPI     #$20,D0        End of Demo or Demo Build (D)?
         BNE.S    RAWTIR
         MOVEQ    #0,D1          Wash D1
         MOVE     DEMO,D1        End of Demo?
         BLT.S    RAWDEM1        If LT, No
         JMP      NXT            End of Demo Routine
RAWDEM1  MOVE     DEMBLD,D1      End of Demo Build
         BLT      RAWF           
         JMP      DEMWRT         Write back DEMO

RAWTIR   CMPI     #$0014,D0      T=Tire Change?
         BNE.S    RAWGAZ
         TST      CHGTIR         Already Changing?
         BPL      RAWF           If PL, Yes
         TST      FILGAZ         Filling Gaz?
         BPL      RAWF           If PL, Yes
         BSR      PITSTOP        Test in Pitstop?
         BEQ      RAWF           If EQ, Out
         BSET     #3,LOCK        Lock/Noshift Commands
         CLR      CHGTIR         Say Changing
         BRA      RAWF

RAWGAZ   CMPI     #$0022,D0      G=Gaz Filling?
         BNE.S    RAWTST
         TST      FILGAZ         Already Filling?
         BPL.S    RAWF           If PL, Yes
         TST      CHGTIR         Changing Tire?
         BPL.S    RAWF           If PL, Yes
         BSR      PITSTOP        Test in Pitstop
         BEQ.S    RAWF           If EQ, Out
         BSET     #2,LOCK        Lock/NoShift Commands
         CLR      FILGAZ         Say Filling
         BRA.S    RAWF

RAWTST   CMPI     #$006D,D0
         BNE.S    RAWF
         LEA.L    OCCUR,A1
         MOVE.L   76(A1),D2
         MOVE.L   140(A1),D1
         MOVE.L   D1,76(A1)
         MOVE.L   D2,140(A1)

RAWF     BRA.S    AUTOG

* Routine to Test in Pitstop Routine

PITSTOP   TST      SP1D+2         Speed=0?
          BNE.S    PITSTOP9       IF NE, leave
          MOVE     XB,D1          Get XB
          CMP      #-256,D1       Test in Pitstop       
          BPL.S    PITSTOP9       .
          CMP      #-512,D1       .
          BLT.S    PITSTOP9       .
          TST.W    FROTT
          BEQ.S    PITSTOP9
          CMP.W    #590,FROTT+6
          BNE.S    PITSTOP9
          MOVE     #1,D0          Say In
          RTS
PITSTOP9  CLR      D0             Say Out
                  RTS

* Automatic Gear Control 

AUTOG    TST.L    MGEAR          Automatic?
         BLE      AUTOGF         If LE, No
         TST      LOCK           Locked
         BNE      AUTOGF         If NE, Yes
         TST      LIG            Test Light
         BGE      AUTOGF         If GE, Reg and Orange
         TST      AUTO       
         BEQ.S    AUTOG0
*         BGT.S    AUTOGA
         ADDQ     #1,AUTO
         BLT      AUTOGF
         MOVE     PGEAR,GEAR
         SUBI     #1,GEAR
         BPL      AUTOGF
         CLR      GEAR
         BRA      AUTOGF
*AUTOGA   SUBI     #1,AUTO
*         BGT.S    AUTOGF
*         ADDI     #1,GEAR
*         BRA      AUTOGF         
AUTOG0   MOVEQ    #0,D3
         MOVE     GEAR,D3
         BNE.S    AUTOG1
         CMPI     #8500,RPMIN
         BLE.S    AUTOGF
         MOVE     #1,GEAR
         BRA.S    AUTOGF
AUTOG1   MOVE     SP1D+2,D0
         SUBQ     #1,D3          .
         LSL      #2,D3          Make it Pointer
         LEA.L    GAUTBL,A3      in GAUTBL
         ADDA.L   D3,A3
         CMP      (A3),D0        Compare Speed to Min
         BPL.S    AUTOG2
         MOVE     #-2,AUTO       Trigger Retrograder
         MOVE     GEAR,PGEAR     with 2 cycles Dead Point
         CLR      GEAR 
         BRA.S    AUTOGF
AUTOG2   CMP      2(A3),D0       Compare Speed to Max
         BLE.S    AUTOGF
         ADDQ     #1,GEAR        Increase Gear
AUTOGF

* Speed and Regime Computation (SP1D from 0 to 526)
*
SPEDC    CLR      TIRUSA         Cycle Tire Usage
         MOVE.L   SP1D,D0          
         TST      ENDCRC         End of Circuit Sequence?
         BEQ.S    SPEDC0         If EQ, No
         CLR      ACCEL
         SUBQ     #1,ENDCRC
         BNE.S    SPEDC0
         TST      MCOMM+2
         BGT      SPEDCA         
         TST      ESCAP          
         BEQ      NXT            
         BRA      ESCAPE         
SPEDCA   BSET     #7,SNDBUF+1    Say F1 Finished for SENDIR
         BSET     #5,LOCK
         BSET     #0,F12END      . 
SPEDC0   MOVEQ     #0,D7         Assume no Motor Moment
         MOVEQ     #0,D6         assume no Braking Moment
         MOVE      ACCEL,D2      Test Braking 
         BPL.S     SPEDC1
         NEG      D2             Compute Braking Moment
         MULU     D2,D2          Mb=Accel*Accel/16
         LSR      #4,D2
         MOVE     TIRUSE,D5      From 2048 to 0
         ADD      #2048,D5       From 4096 to 2048
         MULU     D5,D2          *(TIRUSE+2048)/4096
         MOVE.L   #12,D0         .
         LSR.L    D0,D2          .
         MOVE     D2,D6          .        
         SUBI     #1,TIRUSA      Usure pneu
SPEDC1   MOVE     SP1D+2,D5      Compute "Frottement Air" Moment in D5
         MULU     D5,D5          Mf=V*V/458 (**512**)
         DIVU     #468,D5        Well Tuned
         EXT.L    D5

* Compute Rolling Moment

SPEDC1A  MOVE     #10,D4         Assume Mr=10
         MOVE     topvib(PC),D0
         BEQ.S    SPEDC1D1       MODJLL
         CMPI     #2,D0          
         BEQ.S    SPEDC1C        If EQ, 1 on Stripe, 1 on Road 
         ADD      #198,D4        Well Tuned
         BRA.S    SPEDC1D
SPEDC1C  ADD      #100,D4
SPEDC1D  CMP.W    #80,SP1D+2
         BLT.S    SPEDC1D2
         MOVE.W   topvib+4(pc),D0
         BEQ.S    SPEDC1D2
         SUBQ.W   #1,TIRUSA
         BRA.S    SPEDC1D2
SPEDC1D1 TST      LOCK           DM26JUL
         BNE.S    SPEDC1D2       DM26JUL
         ADD.W    volant+2(PC),D4   moment du a la pente
SPEDC1D2
         TST      FROTT+2        Frottement pont et derrap
         BEQ.S    SPEDC1E
         SUBI     #1,TIRUSA      Usure Pneu
         ADD      #800,D4
SPEDC1E  TST      BTIR           Broken Tires
         BEQ.S    SPEDC1F
         SUBI     #1,TIRUSA      Usure Pneu
         MOVE     #1300,D4                
SPEDC1F

* Dispatch according to Engaged/Not Engaged 

         MOVE      GEAR,D0        Engaged?
         BEQ       SPEDC20        If EQ, Not Engaged
         SUBQ      #1,D0          Entry in GxxTBL Tables
         LSL       #1,D0          .
         CMPI      #-140,htprl    Down?
         BLT       SPEDC10        If LT, Up

* Here Engaged and Down

         MOVE     ACCEL,D2       Accel
         BPL.S    SPEDC2
         CLR      D2

SPEDC2   MOVE     RPMIN,D3       Compute Motor Moment (Get N)
         CMPI     #13312,D3      Compare to Max
         BLE.S    SPEDC2A
         MOVE     #13312,D3      Limit to Max
SPEDC2A  LSR      #4,D3          Make it Entry in MOMTBL (13312/(16*2))
         LSL      #1,D3          .
         LEA.L    MOMTBL,A3      Get Motor Moment
         MOVE     0(A3,D3),D7    
         CMPI     #94,D2          Max accell
         BEQ.S    SPEDC2B         If EQ, Yes
         MULU     D2,D7
         DIVU     #94,D7         Mm in D7
SPEDC2B

         SUB       D6,D7          Ma=Mm-Mb
         SUB       D5,D7          -Mf     
         SUB       #10,D7         -Mt
         SUB       D4,D7          -Mr
         EXT.L     D7

         MOVE      SP1D+2,D4      Compute N(V0)=S*V0/256 
         LEA.L     GVNTBL,A0      
         MOVE      0(A0,D0),D6    Get S
         MULU      D4,D6          
         ASR.L     #8,D6          N(V0)
         CMPI      #13312,D6      Sur-regime after Retrograde 
         BPL       SPEDC5
         SUB       RPMIN,D6       N(V0)-N0 in D6
         MOVE      D6,D5
         BPL.S     SPEDC3        
         NEG       D5             and D5
SPEDC3   CMPI      #200,D5
         BPL       SPEDC4         If PL, NOT SYNCHRO       
 
         LEA.L     GNNTBL,A0      SYNCHRO : Compute DN=T*Ma/256
         MOVE      0(A0,D0),D4    .
         MULS      D7,D4          .
         ASR.L     #8,D4          DN + or -

         ADD       RPMIN,D4       Update N0(+-)DN
         MOVE      D2,D3          Compute Max
         BPL.S     SPEDC3E
         MOVEQ     #0,D3
         BRA.S     SPEDC3K
SPEDC3E  LSL       #7,D3          Nmax=128*Accel+1280
         ADDI      #1280,D3       .
SPEDC3K  CMP       D3,D4          Test Limit Max 
         BLT.S     SPEDC3C
         LEA.L     GDNTBL,A0      Add Frein Moteur
         SUB       0(A0,D0),D4    N0+DN-FM
         CMP       D3,D4          
         BPL.S     SPEDC3C        
         MOVE      D3,D4  
SPEDC3C  MOVE      D4,RPMIN       N1=N0+DN(-FM)
         BLT.S     SPEDC3M
         EXT.L     D4
         ASL.L     #8,D4          Compute V1=256*N1/S
         LEA.L     GVNTBL,A0
         MOVE      0(A0,D0),D3
         DIVU      D3,D4
         MOVE      D4,SP1D+2
         BRA       SPEDC40
SPEDC3M  MOVE      #1000,RPMIN    N1<=0
         MOVE      #0,SP1D+2
         MOVE      #0,GEAR
         MOVE      #0,PGEAR
         BRA       SPEDC40                           

SPEDC4   ASL.L     #8,D7         NOT SYNCHRO : Compute DV=256*Ma/R
         LEA.L     GVVTBL,A0     
         MOVE      0(A0,D0),D4
         DIVS      D4,D7         
         ADD       SP1D+2,D7        
         BLE.S     SPEDC3M  
         MOVE      D7,SP1D+2      V1=V0+DV     
         LEA.L     GVNTBL,A0      Compute N(V1)=S*V1/256
         MOVE      0(A0,D0),D4    Get S
         MULU      D7,D4          
         ASR.L     #8,D4          N(V1)
         MOVE      RPMIN,D5       N0         
         TST       D6             N(V0) - N
         BPL.S     SPEDC4B        N0<N(V0)        
         SUBI      #500,D5        N0>N(V0) N Tire V   
         CMP       D4,D5          Test Limit MIN = N(V1) 
         BPL.S     SPEDC4D
         BRA.S     SPEDC4C   
SPEDC4B  ADDI      #1000,D5       N0<N(V0) V Tire N
         CMP       D4,D5          Test Limit MAX = N(V1)
         BLE.S     SPEDC4D
SPEDC4C  MOVE      D4,D5          N1=N(V1)
SPEDC4D  MOVE      D5,RPMIN       N1
         BRA       SPEDC40

SPEDC5   SUBI      #1000,D6       N(V0)>13312 : Sur-Regime after Retrograde
         MOVE      D6,RPMIN       Compute N1=N(V0)-1000
         EXT.L     D6
         ASL.L     #8,D6          Compute V1=256*N1/S
         LEA.L     GVNTBL,A0
         MOVE      0(A0,D0),D3
         DIVU      D3,D6
         MOVE      D6,SP1D+2
         BRA       SPEDC40

* Here Engaged and Up
        
SPEDC10  MOVE      ACCEL,D2       Compute N
         BGT.S     SPEDC11        If GT, Accelerating
         MOVE      #1000,D3
         BRA.S     SPEDC13
SPEDC11  LSL       #3,D2          DN=16*Accel
         MOVE      D2,D3          
         LSL       #4,D3          NMAX=128*Accel+1280
         ADDI      #1280,D3       .
SPEDC12  CMP       RPMIN,D3       
         BEQ.S     SPEDC15        N=NMAX
         BLT.S     SPEDC13        
         ADD       D2,RPMIN       N<NMAX Increase N
         CMP       RPMIN,D3       NMAX-N
         BGT.S     SPEDC15
         MOVE      D3,RPMIN
         BRA.S     SPEDC15
SPEDC13  SUB       #1024,RPMIN    N>NMAX Decrease N
         CMP       RPMIN,D3       NMAX-N              
         BLT.S     SPEDC15        
         MOVE      D3,RPMIN       
SPEDC15  BRA       SPEDC30        Ma=-Mf (Compute V)
         
* Here Not Engaged 

SPEDC20  MOVE      ACCEL,D2       Compute N
         BGT.S     SPEDC21        If GT, Accelerating
         MOVE      #1000,D3
         BRA.S     SPEDC23
SPEDC21  LSL       #4,D2          DN=16*Accel
         MOVE      D2,D3          
         LSL       #3,D3          NMAX=128*Accel+1280
         ADDI      #1280,D3       .
SPEDC22  CMP       RPMIN,D3       
         BEQ.S     SPEDC24        N=NMAX
         BLT.S     SPEDC23        
         ADD       D2,RPMIN       N<NMAX Increase N
         CMP       RPMIN,D3       NMAX-N
         BGT.S     SPEDC24
         MOVE      D3,RPMIN
         BRA.S     SPEDC24
SPEDC23  SUB       #512,RPMIN     N>NMAX Decrease N
         CMP       RPMIN,D3       NMAX-N              
         BLT.S     SPEDC24        
         MOVE      D3,RPMIN       
SPEDC24           
         CMPI      #-140,htprl    Down?
         BLT.S     SPEDC30        If LT, Up

* Here Not Engaged and Down

         ADD       D6,D5          Ma=-Mb-Mf-Mr
         ADD       D4,D5         

* Here Not Engaged and Up

SPEDC30  NEG       D5             Compute V (Ma=-Mf)
         EXT.L     D5             Compute DV=Ma/128
         BLT.S     SPEDC31        DM13JUL
         LSR.L     #3,D5          DM13JUL
         BRA.S     SPEDC32        DM13JUL
SPEDC31  ASR.L     #7,D5
         BNE.S     SPEDC32
         MOVE      #-1,D5
SPEDC32  ADD       D5,SP1D+2
         BPL.S     SPEDC40
         CLR.L     SP1D

SPEDC40  MOVE.W   SP1D+2,D0
        LSR.W   #1,D0
        ADD.W   SP1D+2,D0
        cmp.w   #128+16,d0
        ble.s   mvtrm
        move.w  #128+16,d0
mvtrm:  add.w   d0,PANIM
        MOVE.L  SP1D,D0
        BEQ.S   SPEDCF

         TST      LIG            SPEED NE 0, Green Light?
         BLT.S    SPEDCF         If LT, Yes
         TST      MCOMM+2
         BLE      ESCAPE
         BSET.B   #7,SNDBUF+1    Say F1 Has Escaped for SENDIR
         BSET     #5,LOCK        Lock
         BSET     #0,F12END      .
         MOVE     #1,ESCAP
SPEDCF   

* Compute DX1 and X1 For F1 

XBCMP    MOVE     XB,D7  
         MOVE.W   #128,D3        MOD1JL
         TST      SHIFTE         Test Shift Phase
         BLT      XBCMP2         If LT, No
         MOVE     #-256,D2       Mock Volant
         TST      SHIFTE+2       Test Direction of Shift
         BLT.S    XBCMP1
         MOVE     #256,D2      
XBCMP1   MOVE     D2,volant
         TST      MGAME+2        
         BEQ      XBCMP4A        If EQ, Shift in Arcade

         MOVE.L   haldco(pc),D5      HERE Shift in Racing/Demo/Train/Qualif 
         BEQ.S    XBCMP1E
         BLT.S    XBCMP1C
         MOVE.L   #3000,D6
         SUB.L    D6,D5
         BGT.S    XBCMP1G
         BRA.S    XBCMP1E
XBCMP1C  MOVE.L   #-3000,D6
         SUB.L    D6,D5
         BLT.S    XBCMP1G
XBCMP1E  MOVE.L   D5,D6
         MOVEQ    #0,D5
XBCMP1G  MOVE.L   D6,DUMSCROL
         MOVE.L   D5,haldco

         BTST.B   #7,LANE     Pitstop?
         BEQ.S    TSHIFT1     If EQ, No
         TST      SHIFTE+2    Left Object    
         BPL.S    TSHIFT1     If PL, Yes
         CMPI     #80,X1      Back on Road? 
         BPL.S    XBCMP1H      If PL, No
         BRA      XBCMPF
TSHIFT1  TST      topvib      Still on Grass or Stripe?
         BEQ      XBCMPF      If NE, Yes
MVTSHIF  TST      SHIFTE+2    Original XB for Shift Direction
         BLT.S    XBCMP1H        
         SUB.L    #24,decaco
         BRA      XBCMPF
XBCMP1H  ADD.L    #24,decaco
         BRA      XBCMPF

XBCMP2   TST      MGAME+2        Test Mode 
         BNE      XBCMPF         Race/Demo/Qual/Tra : Ang Mode (JLL does it)

         MOVE.W   SP1D+2(PC),D3  Here Arcade/Parallel Mode
         BEQ      XBCMP10
XBCMP3   MOVE     volant,D2      1) INFLUENCE of Steering Wheel
****         TST      FROTT+2        Skipping?      MODJLL
****         BGE.S    XBCMP4         If EQ, NO
****         CLR      D2             If SKIP, Influence = 0
XBCMP4   TST      LOCK           Lock Command
         BEQ.S    XBCMP4A
         CLR      D2             If LOCK, Influence =0
XBCMP4A  NEG      D2
         MULS     D3,D2         MODJLL
         ASL.L    #5,D2
         SWAP     D2
         ADD      D2,D7          Add to New XB

         TST.B    evnco          .COURBE   MODJLL
         BEQ.S    XBCMP10        .
         MOVE     SP1D+2(PC),D3
         MOVE.B   evnco(PC),D2
         BPL.S    XBCMP40        .
         NEG      D3             .
XBCMP40  MOVEQ    #7,D2
         SUB.B    evnco+2(pc),D2
         MULS     D2,D3
         ASR.W    #6,D3
         ADD      D3,D7          Add Delta Cur to New XB

XBCMP10  MOVE     D7,XB
XBCMPF
         

* FIRST CARS BEHAVIOR LOOP 

         MOVE.L    SP1D,SP1DBIS         MODJLL
         MOVE.W    SAVSP1D(PC),SP1D+2

CARLOP   CLR      OVER
         CLR      OVER2
         LEA.L    CARSRT,A0      
         LEA.L    OCCUR,A1       

CARLOP0  MOVE     (A0)+,D0       Next CAR (From Ahead to Behind)
         BLT      CARLOPF        If LT, No More Active Cars
         EXT.L    D0             Car Offset in OCCUR

CARLOP1  TST.B    0(A1,D0)       Test Car Nature
         BEQ      CARLOP20       IF LT, F2
         BLT      CARLOP30       IF EQ, F1

* HERE NORMAL CAR 
* Input: A0 Points to CARSRT Entry +2
*        A1 Points to OCCUR
*        D0 Car Offset in  OCCUR 
*        D1 Car Ahead Offset in OCCUR (or -2 First Time)
*        Compute Behavior (X, Y, CURSPD) 
        
CARLOP10 TST      LIG            Green Light?         MOD1JL
         BPL      CARLOP0        If PL, No, Do not Modify Anything
*MODIF COMPORT    MODJL1
         CLR.W    D3
         MOVE.B   44(A1,D0.W),D3
         JMP      RTCOMP(PC,D3.W)
RTCOMP:  BRA.L    RC0      VIDE
         BRA.L    RC4      RACE
         NOP
RC4:     SUBQ.W   #1,46(A1,D0.W)
         BNE      RC0
         MOVE.B   45(A1,D0.W),47(A1,D0.W)
         LEA.L    OCCUR(PC),A4
         MOVE.W   MCOMM+2(PC),D3
         BLE.S    SRC4
         MOVE.B   59(A4),D3
         CMP.B    59+64(A4),D3
         BGT.S    SRC4
         LEA.L    64(A4),A4
SRC4:    MOVE.L   2(A4),D4
         MOVE.L   2(A1,D0.W),D2
         MOVE.W   10(A4),D1
         SUB.W    10(A1,D0.W),D1
         BEQ.S    S1RC4             MEME TOUR
         BLT.S    S0RC4             F1 DERRIERE
         ADD.L    CRCLAP(PC),D4     F1 DEVANT
         SUBQ.W   #1,D1
         BEQ.S    S1RC4
         ADD.L    CRCLAP(PC),D4
         BRA.S    S1RC4
S0RC4:   ADD.L    CRCLAP(PC),D2
         ADDQ.W   #1,D1
         BEQ.S    S1RC4
         ADD.L    CRCLAP(PC),D2
S1RC4:   SUB.L    D4,D2
         BLT      SNRC4
         LSL.L    #3,D2
         SWAP     D2
         TST.W    D2
         BEQ.S    ACC6
         CMP.W    #19,D2
         BLE.S    SXRC4
         MOVE.W   #19,D2
SXRC4:   CLR.W    D3
         MOVE.B   59(A1,D0.W),D3
         SUB.W    D3,D2
         BLT.S    FRC4
         CMP.W    #15,D2
         BLE.S    S2RC4
         MOVE.W   #15,D2
S2RC4:   LSR.W    #2,D2
         SUBQ.W   #4,D2
         NEG.W    D2
         MOVE.W   48(A1,D0.W),D3
         MOVE.W   D3,D4
         LSR.W    D2,D3
         SUB.W    D3,D4
         MOVE.W   D4,14(A1,D0.W)
         BRA      RC0
FRC4:    MOVE.W   48(A1,D0.W),14(A1,D0.W)
         BRA      RC0
ACC6:    MOVE.W   48(A1,D0.W),D3
         MOVE.W   D3,D4
         LSR.W    #4,D3
         ADD.W    D3,D4
         MOVE.B   59(A1,D0.W),D3
         ADD.W    D3,D4
         MOVE.W   D4,14(A1,D0.W)
         MOVE.W   8(A4),D3
         BLT.S    S3RC4
         CMP.W    #115,D3
         BLE.S    S4RC4
         MOVE.W   #115,D3
         BRA.S    S4RC4
S3RC4:   CMP.W    #-220,D3
         BGE.S    S4RC4
         MOVE.W   #-220,D3
S4RC4:   MOVE.W   D3,6(A1,D0.W)
         BRA      RC0
SNRC4:   NEG.L    D2
         LSL.L    #2,D2
         SWAP     D2
         CLR.W    D3
         MOVE.B   59(A1,D0.W),D3
         SUB.W    D3,D2
         SUBQ.W   #1,D2
         BLT.S    ACC12
         BEQ      FRC4
         CMP.W    #11,D2
         BLE.S    S5RC4
         MOVE.W   #11,D2
S5RC4:   LSR.W    #2,D2
         SUBQ.W   #4,D2
         NEG.W    D2
         MOVE.W   48(A1,D0.W),D3
         MOVE.W   D3,D4
         LSR.W    D2,D3
         SUB.W    D3,D4
         MOVE.W   D4,14(A1,D0.W)
         BRA      RC0
ACC12:   MOVE.W   48(A1,D0.W),D2
         MOVE.W   D2,D4
         LSR.W    #3,D2
         ADD.W    D2,D4
         ADD.W    D3,D4
         MOVE.W   D4,14(A1,D0.W)
         BRA      RC0
         NOP

RC0:     MOVE.L   16(A1,D0),D3   Get Temptative Speed
         MOVE.L   2(A1,D0),D2    Compute Temptative Y in D2.L
         ADD.L    D3,D2          .
         MOVE     8(A1,D0),D1    Get Temptative X in D1.W
         JSR      INFTOP         Curve/Lane Influence on X,Y & Speed
         TST.L    D3             Zero Speed?
         BEQ      CARLOP0        If EQ, Yes, Proceed with Next Car
         MOVE     D1,D2          Potential X After Topology (D3.L = P Speed)  
         TST      MGAME+2        
         BGT      CARLAPF        If GT, Racing/Demo
         
* ARCADE/QUALIF BEHAVIOR SCHEME
*
*                             I
*                     2     3 I 3'    1      2
* A Situation : ----------(---I---O------)----------
*                             I
*                             I
*                     2       I 2'    3      1    2
* B Situation : --------------I---(------O------)---
*                             I
*                             I
*                2    3     1 I 1'           2
* C Situation : ---(------O---I---)------------------
*                             I
*                             IDeparture Line
*

CARLAP   
         MOVE.L    2(A1,D0),D5   Get Front Car Y
         MOVE.L    D5,D4         D4=Yc
         MOVE.L    Y1,D1         D1=YF1
         SUB.L     D1,D5         D5=Yc-YF1
         CMPI.L    #VIEWLEN,D1   Establish F1 Situation
         BLT.S     CARLAP0       If LT, A Situation 
         MOVE.L    D1,D6
         SUB.L     CRCLAP,D6     YF1-CRCLAP
         CMPI.L    #-VIEWLEN,D6  
         BLT.S     CARLAP3       If LT, B Situation 
         BRA.S     CARLAP5              
CARLAP0  TST.L     D5            A Situation    
         BLE.S     CARLAPF       3' Position : Nothing
         CMPI.L    #VIEWLEN,D5   
         BLE.S     CARLAPF       1 Position : Nothing
         ADD.L     CRCLAP,D1     2 or 3 Position   
         BRA.S     CARLAP6       D1=YF1+CRCLAP
CARLAP3  TST.L     D5            Here B Situation            
         BLT.S     CARLAP6       Here 3 or 2' Position       
         CMPI.L    #VIEWLEN,D5   
         BLT.S     CARLAPF       1 Position : Nothing
         ADD.L     CRCLAP,D1     Here 2 Position
         BRA.S     CARLAP6
CARLAP5  TST.L     D5            Here C Situation
         BPL.S     CARLAPF       1 Position : Nothing 
         ADD.L     CRCLAP,D5     
         CMPI.L    #VIEWLEN,D5   
         BLT.S     CARLAPF       1' Position : Nothing  
CARLAP6  SUBI.L    #VIEWLEN,D1   3, 2 or 2' Position
*                                A2 : D1=YF1+CRCLAP-VIEWLEN
*                                B2 : D1=FF1+CRCLAP-VIEWLEN
*                                B2': D1=YF1-VIEWLEN
*                                C2 : D1=YF1-VIEWLEN
         CMP.L     D1,D4         
         BPL.S     CARLAPF       3 Position : Nothing 
         BTST      #0,15(A1,D0)  Here 2 or 2' 
         BEQ.S     CARLAP7       If NE, Max Speed is Odd
         SUB.L     #20,D3        Reduce Current Speed
         BGT.S     CARLAPF
         MOVE.L    #3,D3
         BRA.S     CARLAPF 
CARLAP7  ADDI.L    #30,D3        Increase Speed Dramatically
         ADD.L     D3,D4         .
         CMP.L     D1,D4         .
         BLT.S     CARLAPF       .
         MOVE.L    12(A1,D0),D3  Round Trip is done
CARLAPF

*********DM15JUL
         MOVEQ    #0,D7
         MOVE     #0,-(A7)       Not First Car         6(A7)
         MOVE     #0,-(A7)       Overpass Counter      4(A7)
         MOVE.L   #0,-(A7)       Pointer               0(A7)
CARLOP11 MOVE     -4(A0,D7),D1   Car Ahead Offset in OCCUR (or -2)
         EXT.L    D1             .
         BPL.S    CARLOP12       If PL, Not First Car
         BTST     #0,D1          Begining or End?
         BEQ.S    CARLOP1A       If EQ, -2, Begining
         SUBQ.L   #2,D7          -1 = End
         BRA.S    CARLOP11       Continue Scrutation
CARLOP1A ADDI.L   #17*2,D7       -2, Begining
         MOVE     #1,6(A7)        Mark First Car
         MOVE.L   CRCLAP,(A7)      
         BRA.S    CARLOP11      

CARLOP12 MOVE.L    2(A1,D1),D4   Get Car Ahead Position
         ADD.L     (A7),D4       .
         SUB.L     2(A1,D0),D4   .
         SUB.L     D3,D4         Compare with Potential Car Position
         BLT       CARLOP14      If LT, OVERPASSING - DM27JUL
         MOVE.L    16(A1,D1),D5  Get Car Ahead Speed (D4>0)
         SUB.L     D3,D5         Compare with Car Speed
         BLT.S     CARLOP1G      If LT, Faster
         BPL       CARLOP1R      If PL, Slower or Equal
CARLOP1G NEG.L     D5            Here Faster
         LSL.L     #7,D5         Shift Distance 
         CMP.L     D4,D5         Too Far?
         BLT       CARLOP1R      If LT, GE : Shifting

CARLOP1B CMPI.B    #1,58(A1,D0)  HERE SHIFTING :Current Car is in 1 Lane?
         BEQ       CARLOP1R      If EQ, Yes 
         CMPI.B    #1,58(A1,D1)  Car Ahead is in 1 Lane?
         BEQ       CARLOP1R      If EQ, Yes, Don't Shift
         MOVE      8(A1,D0),D2   Restore X before INFTOP          
         TST       4(A7)         Already Overpassed One?
         BNE       CARLOP1R      If NE,Yes (Don't Shift/Don't Reduce Speed)
         TST       D4            *** BUGDIV0 ***
         BEQ.S     BUGDIV0
         DIVU      D4,D5         (D4>0)
BUGDIV0  LSL       #1,D5         Compute Shift
         CMPI      #10,D5        .
         BPL.S     CARLOP1H      .
         CMPI.L    #600,D4       Close (<4m)
         BLE.S     CARLOP1H      If LE, Yes
         TST.L     16(A1,D1)     Car Ahead Speed = 0?
         BNE.S     CARLOP13      If NE, No
         TST.L     16(A1,D0)     Car has already Stopped?   DM19JUL
         BEQ       CARLOP1P      If EQ, Yes, Don't Shift/Keep Speed=0
CARLOP1H MOVE      #10,D5        Big Shift
CARLOP13 MOVE      8(A1,D1),D6   Get Car Ahead Xa
         CMPI      #-37,D6       On the Right?
         BPL.S     CARLOP1D      If PL, Yes
         SUB       D2,D6         Car Ahead is on The LEFT : Xa-Xc
         CMPI      #-160,D6      Already Shifted?
         BLT       CARLOP1R      If LT, Yes
         SUB       D5,D6
         NEG       D5
         ADDI      #160,D6
         BPL.S     CARLOP1E
         BRA.S     CARLOP1Z
CARLOP1D SUB       D2,D6         Car Ahead On The RIGHT : Xa-Xc
         CMPI      #160,D6       Already Shifted?
         BPL       CARLOP1R      If PL, Yes
         ADD       D5,D6
         SUBI      #160,D6       
         BLT.S     CARLOP1E
CARLOP1Z SUB       D6,D5         Adjust Shift up to +-160 
CARLOP1E TST.L     16(A1,D1)     Car Ahead Speed=0 and not Already Shifted?
         BNE.S     CARLOP1Q      If NE, No
         SUBI.L    #2,D3         Reduce Speed
         BPL.S     CARLOP1Q      .
         MOVE.L    #1,D3         .         
         BRA.S     CARLOP1Q
CARLOP1P MOVEQ     #0,D3         No Delta Spd DM19JUL
CARLOP1R MOVEQ     #0,D5         Already Shifted : No DX Adjustment
CARLOP1Q 
*SCRUTATION VOITURE SUIVANTE POUR RALENTISSEMENT EVENTUEL
         MOVE.L    D3,D6         Say DY = DV
         BRA       CARLOP1V

CARLOP14 MOVE      #0,D5         HERE OVERPASSING (Assume No Shift)
         MOVE      8(A1,D0),D2   Restore X
         CMPI.B    #1,58(A1,D1)  Car Ahead is in 1 Lane
         BEQ       CARLOP1L      If EQ, Yes
         MOVE      8(A1,D1),D6   Get Car Ahead Xa
         CMPI      #-37,D6       On the Right?
         BPL.S     CARLOP1K      If PL, Yes
         MOVEQ     #-10,D5       Shift
         SUB       D2,D6         Xa-Xc
         CMPI      #-150,D6      
         BLT.S     CARLOP17      If LT, Successful Overpassing
         BRA       CARLOP1L
CARLOP1K MOVE      #10,D5        Shift
         SUB       D2,D6         Xa-Xc
         CMPI      #150,D6
         BLE.S     CARLOP1L      If LE, Unsuccessful Overpassing

CARLOP17 TST       6(A7)         SUCCESSFUL OVERPASSING
         BNE       CARLOP1N      If NE, Crossing Line, Don't Overpass
         TST       MGAME+2       Arcade?
         BEQ.S     CRLOP17A      If EQ, Yes
         BLT.S     CARLOP19      If LT, Train/Qualif
         MOVE      MAXLAP,D5
         CMP       10(A1,D0),D5  Racing : Passed Arrival Line?
         BLT.S     CARLOP19      If GT, Yes 
         MOVE      10(A1,D0),D5  Compare Laps of Cars
         CMP       10(A1,D1),D5  .
         BNE.S     CARLOP19
         ADDI.B    #1,59(A1,D0)  Modify CARnPas of Both Cars
         SUBI.B    #1,59(A1,D1)  .
CRLOP17A TST.B     0(A1,D1)      Overpassing F1?
         BGT       CARLOP19      If GT, Normal
         BEQ.S     CARLOP18      If EQ, F2 
         SUBI      #1,OVER       Say F1 Overpassed
         BRA.S     CARLOP19
CARLOP18 SUBI      #1,OVER2      Say F2 Overpassed
CARLOP19 MOVE.L    D4,60(A1,D0)  Save Overpassed Car Delta (D4<=0)
         MOVE      4(A7),D5
         LSL       #1,D5
         NEG       D5
         MOVE      D0,-4(A0,D5.W) Swap in CARSRT if Overpassing 
         MOVE      D1,-2(A0,D5.W) .
         ADDQ      #1,4(A7)
         SUBQ      #2,D7          
         BRA       CARLOP11       
CARLOP1N MOVE.L    D3,D6         Successful & Cross Line D4<=0
         ADD.L     D4,D6         . 
         BRA.S     CARLOP1V      Reduce Y/Don't Reduce Speed
 
CARLOP1L TST       4(A7)         UNSUCCESFUL OVERPASSING : Overpassed one?
         BEQ.S     CARLOP1M      If EQ, No
         MOVEQ     #0,D5         No Shift
         MOVE.L    60(A1,D0),D4  Limit Y to Reach Overpassed Car Y only
         ADDI.L    #150,D4
CARLOP1M MOVE.L    D3,D6         Advance Y to Reach Ya-150
         ADD.L     D4,D6         
         SUBI.L    #150,D6
         MOVE.L    16(A1,D1),D3  Say Speed = Car Ahead Spead+1
****         ADDI.L    #1,D3     DM21JUL

CARLOP1V TST.L     D3            END TREATMENT : COMMON        
         BPL.S     CARLOP1W
         MOVEQ     #0,D3
CARLOP1W MOVE.L    D3,16(A1,D0)  Update Speed
         TST.L     D6
         BPL.S     CARLOP1Y      .
         MOVEQ     #0,D6         .
CARLOP1Y ADD.L     D6,2(A1,D0)   Update Y
*DMRABAT - TEST EPAISSEUR A FAIRE
*DMRABAT - TEST EPAISSEUR A FAIRE
CARLOP1F SUB       D5,D2         Update X
         MOVE      D2,8(A1,D0)   .  
         ADDQ.L    #8,A7         Restore Stack
         BRA       CARLOP0
*********DM15JUL

* HERE F2 CAR 
* Input: A0 Points to CARSRT Entry +2
*        A1 Points to OCCUR 
*        D0 Car Offset in OCCUR 
*        D1 Car Ahead Offset in OCCUR (or -2 First Time)
*        No Behavior Computation at all (Done on Other ST)

CARLOP20 
         CMP.W    #8,MCOMM+2
         BNE.S    PDSPNO2
         CMP.W    #1,FIRST
         BNE.S    PDSPNO3
         MOVE.W   #2,FIRST
         BRA.S    PDSPNO2
PDSPNO3  MOVEM.L  D0-D7/A0-A5,-(SP)
         BSR      DISPLAY
         MOVEM.L  (SP)+,D0-D7/A0-A5
PDSPNO2  MOVEQ     #0,D3      
CARLOP2A CMPI      #2,PNTRECE   
         BNE.S     CARLOP2A     
         MOVE.B    BUFRECE,D2    Get 2 Chars
         MOVE.B    BUFRECE+1,D3
         CLR.W     PNTRECE         JLLCOR
         BTST.B    #0,D2         Finished? 
         BEQ.S     CARLOP2B      If EQ, No
         BSET      #1,F12END     Say F2 has finished
CARLOP2B ASR.B     #1,D2
         EXT       D2
         ADD       D2,X2
         ADD       D3,D3
         MOVE.L    D3,SP2D      
         ADD.L     D3,Y2        New Y (Definitive for F2)

         MOVEQ     #0,D7
         MOVE      #0,-(A7)      Overpassed Counter
         MOVE.L    #0,-(A7)      
CARLOP21 MOVE     -4(A0,D7),D1   Car Ahead Offset in OCCUR (or -2)
         EXT.L     D1             .
         BPL.S     CARLOP22      if PL, Not First
         BTST      #0,D1         Begining or End?
         BNE.S     CARLOP25      If NE, -1 = End
         ADDI.L    #17*2,D7      -2, Begining
         MOVE.L    CRCLAP,(A7)      
         BRA.S     CARLOP21 
CARLOP22 MOVE.L    2(A1,D1),D3   Get Car Ahead Position
         ADD.L     (A7),D3       .
         SUB.L     Y2,D3         Compare F2 Position to Car Ahead
         BPL.S     CARLOP26
         TST       MGAME+2       OVERPASSING 
         BLT.S     CRLOP24A      If LT, Train or Qualif
         MOVE      MAXLAP,D5
         CMP       10(A1,D0),D5  OVERPASSING : Passed Arrival Line?
         BLT       CRLOP24A      If GT, Yes 
         MOVE      10(A1,D0),D5  Compare Laps of Cars
         CMP       10(A1,D1),D5  .
         BNE.S     CRLOP24A      If NE, Not Same Lap
         ADDI.B    #1,59(A1,D0)  Modify CARnPas of Both Cars
         SUBI.B    #1,59(A1,D1)  .
         TST.B     0(A1,D1)      Overpassing F1?
         BGT       CARLOP24      If GT, Normal
         SUB       #1,OVER       Say F1 Overpassed
CARLOP24 ADD       #1,OVER2
CRLOP24A MOVE      4(A7),D5
         LSL       #1,D5
         NEG       D5
         MOVE      D0,-4(A0,D5.W) Swap in CARSRT if overpassing
         MOVE      D1,-2(A0,D5.W) .
         ADDQ      #1,4(A7)
CARLOP25 SUBQ.L    #2,D7
         BRA       CARLOP21
CARLOP26 ADDA.L    #6,A7           Restore Stack

         MOVE.L   A1,-(A7)
         LEA.L    OCCUR+64,A1      Update Lane for F2         
         MOVEQ    #0,D0
         MOVE.L   Y2,D2
         MOVE.L   SP2D,D3 
         JSR      UPDLAN
         MOVE.L   (A7)+,A1

         BRA       CARLOP0

* HERE F1 CAR (With Previous X1 Value)
* Input: A0 Points to CARSRT Entry
*        A1 Points to OCCUR 
*        D0 Car Offset in OCCUR 
*        D1 Car Ahead Offset in OCCUR (or -2 First Time)
*        Possible Behavior due to Potential Crash (Y1 and SP1D)

CARLOP30 MOVEQ     #0,D2     
         MOVE.W    SAVX1(PC),X1         MODJLL
         MOVE.L    SP1DBIS(PC),SP1D      MODJLL
         BEQ       TSTCRHE1      
         MOVEQ     #0,D7                                   
         MOVE.L    Y1,D2         Get Previous Y1 Position
         ADD.L     SP1D,D2       Compute Potential Y1
         ADDI.L    #FRTCRH,D2    Add Front Car Distance (D2=Y1+FRT)
         MOVE.L    FEVTAD,A4     TEST F1 CRASH on VET
         SUBQ.L    #8,A4          
TSCRHV0  ADDQ.L    #8,A4         Next VET
TSCRHV0A CMPI      #-1,(A4)      Test End Circuit
         BNE.S     TSCRHV0B      If PL, No
         MOVE.L    CRCLAP,D7     Mark End of Circuit
         MOVE.L    #CRCEVT,A4    Back to Begining *****
         BRA.S     TSCRHV0A      Continue Scrutation
TSCRHV0B MOVE.L    D7,D3         
         ADD.L     2(A4),D3      Yv
         CMP.L     D3,D2         Compare Distances 
         BLT       TSCRHC        If LT, No Possible Crash on VET, See Cars
         MOVE.B    1(A4),D5      Test Topology
         ANDI.B    #3,D5         .
         CMP.B     #2,D5         .         
         BNE       TSCRHV0       Continue Scrutation if Topology
         MOVEM.L   D0-D3/D7/A0-A1,-(A7)
         JSR       tstcra        Test Crash
         TST       D7
         BNE.S     TSCRHV14      If NE, Yes
         MOVEM.L   (A7)+,D0-D3/D7/A0-A1
         BRA       TSCRHV0       Continue Scrutation

TSCRHV14 MOVE      D7,D5         Here CRASH 
         MOVEM.L   (A7)+,D0-D3/D7/A0-A1
         
         CMPI      #1,D5         Crash?
         BGT.S     TSCRHV17
TSCRHV15 MOVE.L    D7,D2         Update Y1 if Crash
         ADD.L     2(A4),D2      .
         MOVE      SP1D+2,D5
         CMPI      #90,D5       
         BLE.S     TSCRHV16
         BSR       CRASHJ        Big Crash
         BRA       TSTCRHE 
TSCRHV16 BSR       CRASHI        Small Crash
         BRA       TSTCRHE       End      
TSCRHV17 CMPI      #2,D5         Jump?
         BNE.S     TSCRHV18      If NE, No
         MOVE      SP1D+2,D5
         CMPI      #180,D5            
         BLE.S     TSCRHV15      Too slow, Crash             
         BSR       JUMPI         Jump (D3 = Yv) 
         BRA       TSCRHV0       Continue Scrutation
TSCRHV18 BSR       REDUI         Reduce Speed (D3=Yv)
         BRA       TSCRHV0       Continue Scrutation
  
TSCRHC   MOVEQ     #0,D7         TEST F1 CRASH ON CARS (D2.L = Yc + FRT)
         MOVE      #0,-(A7)      Not First Car      6(A7)
         MOVE      #0,-(A7)      Overpassed Counter 4(A7)
         MOVE.L    #0,-(A7)      Pointer            2(A7)
TSCRHC0  MOVE      -4(A0,D7),D1  Car Ahead Offset in OCCUR (or -2)
         EXT.L     D1            .
         BPL.S     TSCRHC3       If PL, Not First Car
         BTST      #0,D1         Begining or End?
         BNE       TSCRHC20      If NE, -1 = End
TSCRHC2  ADDI.L    #17*2,D7      -2 = Begining
         MOVE      #1,6(A7)      Make First Car - DM13JUL
         MOVE.L    CRCLAP,(A7)      
         BRA.S     TSCRHC0      
         
TSCRHC3  TST.B     0(A1,D1)      Car Ahead is F1 (Round Buffer)?
         BLT       TSCRHC22      If LT, Yes
         MOVE.L    2(A1,D1),D3   Car Ahead Ya         
         ADD.L     (A7),D3       .
         CMP.L     D3,D2         Compare (Y1+FRT) & Ya
         BLT       TSCRHC22      If LT, No Crash Possible
         MOVE      X1,D4         Here Possible CRASH
         MOVE      8(A1,D1),D5   Position in Pixels at Line 0 + Bits CE=0
         CMP       D4,D5         Xa-X1
         BLT.S     TSCRHC5       If LT, Car Ahead is on the Left
         ADDI      #132-3,D4     ON THE RIGHT : Point to Right Side of F1
         ADDI      #0,D5         Point to Left Side of Car
         SUB       D5,D4         Test Crash
         BLT       TSCRHC10      If LT, No
         LSR       #1,D4         Crash, Compute Crash Point
         SUBI      #66,D4        .
         NEG       D4
         BRA.S     TSCRHC6
TSCRHC5  ADDI      #0+3,D4       ON THE LEFT : Point to Left Side of F1
         ADDI      #132,D5       Point to Right Side of Car
         SUB       D5,D4         Test Crash
         BPL.S     TSCRHC10      If PL, No Crash
         ASR       #1,D4         Crash, Compute Crash Point
         ADDI      #66,D4
         NEG       D4

TSCRHC6  MOVE.L    16(A1,D1),D5  CRASH ON CAR : Get Car Ahead Speed
         SUB.L     SP1D,D5       Compute Speed Gap
         NEG       D5
         CMP       #105,D5               
         BPL.S     TSCRHC8     
         BSR       RED           Reduce Y
         BSR       CRASHCI       SMALL CRASH      
         BRA       TSCRHC22

TSCRHC7  BSR       RED           Reduce Y
         BSR       CRASHCJ       BIG CRASH
         BRA       TSCRHC22
         
RED      MOVE.L    D3,D2         Reduced Y to Ya 
         TST       8(A7)         Overpassed one?
         BEQ.S     RED7          If EQ, No
         MOVE.L    60(A1,D0),D3  Restore Ya'+FRTCRH of Last Overpassed Car
         CMP.L     D3,D2         
         BPL.S     RED7
         MOVE.L    D3,D2         Limit Y1 to Ya' of Overpassed Car
RED7     RTS

TSCRHC8  TST       D4        
         BPL.S     TSCRHC9       If PL, Right
         CMPI      #-40,D4       Left Tire Touch?
         BLT.S     TSCRHC9A
         BRA       TSCRHC7       BIG CRASH on Car
TSCRHC9  CMPI      #40,D4
         BLT       TSCRHC7       BIG CRASH on Car    
TSCRHC9A BSR       JUMPJ         Init JUMP on Car (D3=Ya)
TSCRHC10 MOVE.L    2(A1,D1),D3   OVERPASSING ? Car Ahead Back Position
         ADD.L     (A7),D3       .
         MOVE.L    D2,D6
         SUBI.L    #FRTCRH,D6
         CMP.L     D3,D6         Compare Positions (D3=Ya, D6=Yc)
         BLE.S     TSCRHC20      If LE, No Overpassing
 
         TST       6(A7)         OVERPASSING : Crossing Line? -DM13JUL
         BNE       TSCRHC21      If NE, Yes                    DM13JUL
         TST       MGAME+2       OVERPASSING
         BLT.S     TSCRHC1C      IF LT, Train/Qualif
         BEQ.S     TSCRHC1B      If LE, Arcade
         MOVE      MAXLAP,D5
         CMP       10(A1,D0),D5  Racing : Passed Arrival Line?
         BLT       TSCRHC1C      If LT, Yes  
         MOVE      10(A1,D0),D5  Compare Laps of Cars
         CMP       10(A1,D1),D5  .
         BNE.S     TSCRHC1C      If NE, Not Same Lap
         ADDI.B    #1,59(A1,D0)  Modify CARnPas of Both Cars
         SUBI.B    #1,59(A1,D1)  .
TSCRHC1B TST.B     0(A1,D1)      Overpassing F2?
         BGT       TSCRHC1A      If GT, Normal
         SUBI      #1,OVER2      Say F2 Overpassed
TSCRHC1A ADDI      #1,OVER
TSCRHC1C ADD.L     #FRTCRH,D3         
         MOVE.L    D3,60(A1,D0)  Save Ya+Frtcrh
         MOVE      4(A7),D3
         LSL       #1,D3
         NEG       D3
         MOVE      D0,-4(A0,D3.W) Swap in CARSRT if Overpassing 
         MOVE      D1,-2(A0,D3.W) .
TSCRHC11 ADD       #1,4(A7)
TSCRHC20 SUBQ      #2,D7          Continue Car Ahead Scrutation
         BRA       TSCRHC0

TSCRHC21 MOVE.L    2(A1,D1),D2   Make Y1 = Car Ahead Y - DM13JUL
         ADDI.L    #FRTCRH,D2    .                       DM13JUL

TSCRHC22 ADDQ      #8,A7          Restore Stack - DM13JUL

TSTCRHE  SUBI.L    #FRTCRH,D2    Update Y1
         SUB.L     Y1,D2
         BGT.S     TSTCRHE1
         MOVEQ     #0,D2
TSTCRHE1 TST       MCOMM+2
         BLE.S     TSTCRHE4
         BCLR.L    #0,D2
         ADD.L     D2,Y1
         MOVE      D2,F1DEP
         MOVE      D2,SP1D+2      
         LSR       #1,D2
         MOVEM.L   D0-D1/A0-A1,-(A7)
         LEA.L     SNDBUF,A0 
         MOVE.B    DX1+1,(A0)     Delta X1
         LSL       SNDBUF         Bit 7 Contains END Flag or 0
         MOVE.B    D2,1(A0)
         MOVE      #2,D0
         JSR       SENDIR    
         MOVEM.L   (A7)+,D0-D1/A0-A1
         BRA       TSTCRHF
TSTCRHE4 ADD.L     D2,Y1
         MOVE      D2,F1DEP      Update F1DEP for JLL 
         MOVE      D2,SP1D+2     
TSTCRHF  

* Compute New Lane configuration for F1 

         MOVEQ    #0,D0          A1 points to OCCUR
         MOVE.L   Y1,D2
         MOVE.L   SP1D,D3        
         JSR      UPDLAN

         BRA      CARLOP0

CARLOPF
         MOVE.W   SP1D+2(PC),SAVSP1D    MODJLL
         MOVE.L   SP1DBIS,SP1D   Restore Speed 
 
* SECOND CAR BEHAVIOR LOOPS (END OF LAP/RE-SORTING) 
*
CARLUP   CLR       LAP          
         LEA.L     CARSRT,A0      
         LEA.L     CARSRT,A1
         MOVEQ     #0,D1
         LEA.L     OCCUR,A2
         MOVE.L    A7,A4
CARLUP1  MOVE      (A0)+,D2
         BLT       CARLUP4
         EXT.L     D2
         MOVE.L    2(A2,D2),D3  Get New Y Position
         SUB.L     CRCLAP,D3    Passed Departure Line?
         BLT       CARLUP2      If LT, No 
         MOVE      D2,-(A7)     Passed Lap
         MOVE.L    D3,2(A2,D2)  Update Y
         ADDI      #1,10(A2,D2) Increment CarLap
         MOVE      MAXLAP,D5 
         CMP       10(A2,D2),D5 Finished?  
         BPL.S     CARLUP1A     If PL, Not Finished      
         TST.B     0(A2,D2)     Finished F1?
         BPL.S     CARLUP1D     IF GT, No
         MOVE      #1,LAP       Mark F1 Passed Lap
         TST       MGAME+2
         BLE.S     CARLUP1B
         MOVE      #1,LASTLAP           
CARLUP1B TST       ENDCRC       F1 Already In Escape Sequence?
         BGT       CARLUP1      If GT, Yes
         MOVE      #100,ENDCRC  End of Circuit Sequence 
         MOVE      #0,ESCAP
         BRA       CARLUP1
CARLUP1D TST       MGAME+2      Finished Fn       
         BLE       CARLUP1      If LE, Arcade/Train/Qualif
         MOVE      #1,LASTLAP   Say Last Lap for Others in Racing
CARLUP1E CLR.B     44(A2,D2.W)
         MOVE.L    #120,12(A2,D2) Reduce MaxSpeed in Racing
         BRA       CARLUP1

CARLUP1A TST.B     0(A2,D2)     Not Finished 
         BLT.S     CARLUP1C     If LT, F1
         TST       LASTLAP      Race Already Over in Racing?
         BNE.S     CARLUP1E     If NE, Yes
         BRA       CARLUP1    
CARLUP1C MOVE      #1,LAP       Mark F1 Passed LAP
         TST       LASTLAP      Race Already Over in Racing?
         BNE.S     CARLUP1B     If NE, Yes
         BRA       CARLUP1

CARLUP2  TST.B     0(A2,D2)     Not Passed 
         BPL.S     CARLUP3      If PL, Not F1
         MOVE.L    D1,F1SRT     F1 Update F1SRT  
CARLUP3  MOVE      D2,0(A1,D1)  Store Offset (0,64,...)
         ADDQ      #2,D1
         BRA       CARLUP1

CARLUP4  MOVEQ     #0,D0  
CARLUP5  CMP.L     A7,A4        Post Treatment if Lap Passed +? 
         BEQ.S     CARLUP7      If EQ, No
         ADDQ.L    #2,D0        
         MOVE      -(A4),D2
         TST.B     0(A2,D2)     F1?
         BPL.S     CARLUP6      If PL, No
         MOVE.L    D1,F1SRT     Update F1SRT 
CARLUP6  MOVE      D2,0(A1,D1)  Store Offset (0,64,...)
         ADDQ      #2,D1
         BRA.S     CARLUP5
CARLUP7  ADDA.L    D0,A7        Restore Stack

******** BUG TEST *************
         LEA.L    CARSRT,A0      
         LEA.L    OCCUR,A1       
         CLR      D5
CARLYP0  MOVE     (A0)+,D0       Next CAR (From Ahead to Behind)
         BLT      CARLYPF        If LT, No More Active Cars
         EXT.L    D0             Car Offset in OCCUR
         TST      D5
         BEQ      CARLYP2
         CMP.L    2(A1,D0),D5
         BPL      CARLYP2
         JSR      coupson
         DC.W     $4AFC
CARLYP2  MOVE.L   2(A1,D0),D5
         BRA.S    CARLYP0
CARLYPF    
*******************************
*                                        JLLCOR
*         LEA.L     OCCUR+5(PC),A0
*         MOVE.W    #15,D1
*BCORR:      
*         MOVEM.L   D0-D1/A0-A1,-(A7)
*         MOVEQ     #1,D0
*         JSR       SENDIR    
*         MOVEM.L   (A7)+,D0-D1/A0-A1
*         LEA.L    64(A0),A0
*         DBF      D1,BCORR
*         LEA.L     OCCUR+7(PC),A0
*         MOVE.W    #15,D1
*BCORRX:      
*         MOVEM.L   D0-D1/A0-A1,-(A7)
*         MOVEQ     #1,D0
*         JSR       SENDIR    
*         MOVEM.L   (A7)+,D0-D1/A0-A1
*         LEA.L    64(A0),A0
*         DBF      D1,BCORRX
*      
*B1CORR:  CMPI      #34,PNTRECE   
*         BNE.S     B1CORR
*         CLR.W     PNTRECE

*         LEA.L    BUFRECE+2,A0
*         MOVE.B   (A0)+,D0
*         CMP.B    OCCUR+64+5(PC),D0
*         BNE      PROBLEM
*         MOVE.B   (A0)+,D0
*         CMP.B    OCCUR+5(PC),D0
*         BNE      PROBLEM
*         MOVE.W   #13,D1
*         LEA.L    OCCUR+5+128(PC),A1
*B2CORR:  MOVE.B    (A0)+,D0
*         CMP.B    (A1),D0
*         BNE.S    PROBLEM
*         LEA.L    64(A1),A1
*         DBF      D1,B2CORR
*
*         MOVE.B   (A0)+,D0
*         CMP.B    OCCUR+64+7(PC),D0
*         BNE      PROBLEM
*         MOVE.B   (A0)+,D0
*         CMP.B    OCCUR+7(PC),D0
*         BNE      PROBLEM
*         MOVE.W   #13,D1
*         LEA.L    OCCUR+7+128(PC),A1
*B3CORR:  MOVE.B    (A0)+,D0
*         CMP.B    (A1),D0
*         BNE.S    PROBLEM
*         LEA.L    64(A1),A1
*         DBF      D1,B3CORR

*         BRA.S    FCORR
*PROBLEM: JSR      coupson
*        move.w  #1,-(sp)
*        move.l  #-1,-(sp)
*        move.l  #-1,-(sp)
*        move.w  #5,-(sp)
*        trap    #14
*        add.l   #12,sp
*        move.w  #$777,-(sp)
*        move.w  #3,-(sp)
*        move.w  #7,-(sp)
*        trap    #14
*        addq.l  #6,sp
*        move.w  #$000,-(sp)
*        move.w  #0,-(sp)
*        move.w  #7,-(sp)
*        trap    #14
*        addq.l  #6,sp

*         DC.W     $4AFC
*         nop
*FCORR:

* Erase/Display F1 CarDot on Circuit

F1ERDI   MOVE.L   #CRCDRW,A1     Point to Circuit Drawing
         MOVE.L   ACTSCR,D5      Point to Position
         LEA.L    P1CRC,A4       On this Screen
         MOVE     0(A4,D5),D4    Get Old P1CRC
         JSR      WDOT           Display White Dot
         MOVE.L   Y1,D4          Compute New Y1
         DIVU     CRCECH,D4      .
         MOVE     D4,0(A4,D5)    .
         JSR      BDOT           Display Black Dot
F1ERDIF

* Erase/Display F2 CarDot on Circuit

F2ERDI   TST      MCOMM+2
         BLE      F2ERDIF
         MOVE.L   #CRCDRW,A1     Point to Circuit Drawing
         MOVE.L   ACTSCR,D5      Point to Position
         LEA.L    P2CRC,A4       on this Screen         
         MOVE     0(A4,D5),D4    Get Old Y2
         JSR      WDOT           Display White Dot
         MOVE.L   Y2,D4          Compute New Y2
         MOVE     CRCECH,D1      .
         DIVS     D1,D4          .
         MOVE     D4,0(A4,D5)    .
         JSR      RDOT           Display Red Dot
F2ERDIF

* Progression in VET Events and Road Computation (JLL)
* SP1D can be reduced when Jumping
* CMPROD Computes adscroll & adsky

CMPRO    MOVE     XB(PC),DX1        
         JSR      CMPROD       
         MOVE     XB(PC),D7         Recompute X1 and DX1 from XB 
         SUB      D7,DX1           
         NEG      D7
         SUBI     #29+37,D7     X1=-XB-37-29
         MOVE     D7,SAVX1         Update X1 with New X1 MODJLL

         TST      SHIFTE         Test Shift Phase
         BLT.S    CMPROF         If LT, No
         TST      MGAME+2        
         BEQ.S    CMPROF         If EQ, Arcade/Paralle
         move.l   DUMSCROL,D7    Taken from SUB6 (JLL)
         move.w  reste,d5        *
         ext.l   d5              *
         add.l   d5,d7           *
         divs    DCHAMP,d7         *
         neg.w   d7              *
         move.w  d7,mvtscrol     ;****** move.w
         swap    d7              *
         move.w  d7,reste        *
CMPROF

* Background Pan Progression (Now done by JLL in mvtscrol)

* Sky Events Progression  (V10)

PROSKY   MOVE     mvtscrol,D7    Get Pan Value can be >+-16
         NEG      D7             .
         MOVEQ    #SKYEQU-1,D6
         MOVE.L   #CRCSKY,A0
PROSKY2  TST      (A0)           Inactive?
         BLT.S    PROSKYF        If LT, Yes
         MOVE     2(A0),D0       Get Position
         MOVE     4(A0),D4       Get Shift Speed (-1,0,1)
         MOVE     D7,D3
PROSKY5  SUB      D3,D4          Add (-) Pan to Shift
         ADD      D4,D0          New Position
         BPL.S    PROSKY6        Make it
         ADD      #1264,D0       Between
         BRA.S    PROSKY12       0
PROSKY6  CMPI     #1264,D0       and
         BLT.S    PROSKY12       1263
         SUBI     #1264,D0
PROSKY12 MOVE     D0,2(A0)       Update Position
PROSKY13 ADDA.L   #6,A0          Next Entry
         DBF      D6,PROSKY2     Next Event
PROSKYF

* Speed Digit Computation

CMPSPD   MOVE.L   SP1D,D0
         LSL.L    #1,D0          Actual Speed Km/h = 2/3*SP1D
         DIVU     #3,D0          .
         EXT.L    D0             .
         LEA.L    SPEDIG,A0
         JSR      HUNUM

* Tir Usage
 
TIRUS    TST      ENDCRC
         BGT      GAZCF         
         MOVE     TIRUSE,D0
         TST      SP1D+2        Influence of Brake 
         BEQ.S    TIRUS0        Vibration, Derapage, crissement
         ADD      TIRUSA,D0
         MOVE     D0,TIRUSE
TIRUS0   TST      D0
         BPL.S    TIRUS2 
         TST      MCOMM+2       
         BLE.S    TIRUS1     
         CMPI.B   #1,LANE
         BEQ.S    TIRUSF        Here Comm + 1 Lane : Don't Stop
TIRUS1   MOVE     #50,ENDCRC    Tire Burst, Say ENDCRC
         MOVE     #1,ESCAP
         MOVE     #-1,TIRLIG    Red Light
         BRA.S    TIRUSF
TIRUS2   CMPI     #512,TIRUSE   3/4 Usure
         BPL.S    TIRUSF      
         MOVE     #1,TIRLIG     Orange Light
TIRUSF         

* Engine Usage 

ENGUS    MOVE     RPMIN,D0      
         SUBI     #13280,D0
         BLE.S    ENGUS0
         LSR      #4,D0         DM14JUL
         SUB      D0,ENGUSE     
ENGUS0   MOVE     ENGUSE,D0
         BPL.S    ENGUS2      
         TST      MCOMM+2       
         BLE.S    ENGUS1     
         CMPI.B   #1,LANE
         BEQ.S    ENGUSF        Here Comm + 1 Lane : Don't Stop
ENGUS1   MOVE     #50,ENDCRC    Engine Burst, Say ENDCRC
         MOVE     #1,ESCAP
         MOVE     #-1,ENGLIG    Red Light
         BRA.S    ENGUSF
ENGUS2   CMPI     #512,ENGUSE
         BPL.S    ENGUSF      
         MOVE     #1,ENGLIG     Orange Light
ENGUSF         

* Gaz level Computation

GAZC     MOVE     RPMIN,D0      RPMIN/4096
         MOVE     #12,D1 
         LSR      D1,D0
         CMPI     #11000,RPMIN
         BLE.S    GAZC1
         ADDQ     #2,D0
GAZC1    SUB      D0,GAZ
         BPL      GAZCF
         TST      MCOMM+2       
         BLE.S    GAZC2     
         CMPI.B   #1,LANE
         BEQ.S    GAZCF         Here Comm + 1 Lane : Don't Stop                   
GAZC2    MOVE     #50,ENDCRC    Empty, Say ENDCRC             
         MOVE     #1,ESCAP
GAZCF           


* DISPLAY PART OF LOOP

* Traffic Lights

TLIG     MOVE     LIG,D0         Green?
         BLT.S    TLIGF          IF LT, Yes
         SUBQ     #1,LIG+2       Decrement Counter
         BNE.S    TLIGF
TLIG1    MOVE     #30,LIG+2
         LEA.L    LIG,A0         Display Light
         LEA.L    LIGHT,A5       .
         JSR      DSPLIG         .
         TST      LIG            Green?
         BPL.S    TLIGF          If LE, No
         BCLR     #4,LOCK        Unlock Potentially Departure Lock
         CLR.L    TOTTIM         Clear Total Time for Start to Increase
TLIGF

* F1 Overpassing or Overpassed Display in Banner 

PASS     TST      MGAME+2     Mode?
         BLT      PASSF       If LT, Qualif/Train
         BGT.S    PASS4       If GT, Racing/Demo
         MOVE.W   ENDCRC(PC),D0     MOD1JL
         BNE      PASSF
         MOVE     OVER,D0     Arcade : Any Overpassing?     
         BEQ      PASSF       If EQ, No 
         BGT.S    PASS3
PASS2    LEA.L    CAAPAS,A2   Overpassing in Arcade
         JSR      OVMCAA      Display Car Min in Banner
         SUB.L    #500,DELSCO Update Score
         ADD      #1,D0
         BNE.S    PASS2
         BRA.S    PASSF
PASS3    LEA.L    CAAPAS,A2
         JSR      OVPCAA      Display Car Plus in Banner
         ADD.L    #500,DELSCO Update Score
         SUB      #1,D0
         BNE.S    PASS3
         BRA.S    PASSF

PASS4    MOVE     OVER,D0     Overpassing in Racing/demo
         LEA.L    CAR1PAS,A0
         MOVE     OVER2,D1
         LEA.L    CAR2PAS,A1
         JSR      OVRCAR
PASSF

* F1 Lap Increment Display and Treatment

ADLAP    TST      LAP
         BEQ      ADLAPF
         CLR      LAP
         MOVE     LAP1,D5        Display LAP1
         MOVE.L   MGAME,D6       
         LEA.L    NUMSCR,A5      .
         JSR      DSPLAP         on Current Screen
         JSR      SWPSCR         Swap Screens
         MOVE     LAP1,D5        .
         MOVE.L   MGAME,D6
         LEA.L    NUMSCR,A5      .
         JSR      DSPLAP         and Previous Screen
         JSR      SWPSCR         Reset Screens
         TST      MGAME+2
         BGT.S    ADLAP3         Racing/Demo
         CMPI     #-16,MGAME+2   
         BNE      ADLAPF         If NE, Arcade/Qualif
         MOVE.L   TOTTIM,D0      Here, Train
         CLR.L    TOTTIM         .
         CMP.L    BSTTIM,D0      Best Lap?
         BGT      ADLAPF         If GT, No
         BRA.S    ADLAP3A
ADLAP3   MOVE.L   TOTTIM,D0      Here; Racing/Demo
         MOVE.L   LAPTIM,D1     
         MOVE.L   D0,LAPTIM      
         SUB.L    D1,D0      
         CMP.L    BSTTIM,D0      Best Lap?      
         BGT      ADLAPF         If GT, No
ADLAP3A  MOVE.L   D0,BSTTIM      Racing/Demo/Train : Update Best Lap Time
         LEA.L    TIMDIG,A0      
         JSR      TIMNUM 
         LEA.L    TIMDIG,A0      Display Best Lap Time       
         LEA.L    NUMSCR,A5      in Current Screen
         JSR      INSADIG
         MOVE.L   #43*160,D0
         TST      MGAME+2
         BGT.S    ADLAP4         If GT, Racing/Demo
         MOVE.L   #56*160,D0     Train
ADLAP4   JSR      DSPTMR         .
         JSR      SWPSCR         Swap Screens
         LEA.L    TIMDIG,A0      Display Best Lap Time       
         LEA.L    NUMSCR,A5      in Previous Screen
         MOVE.L   #43*160,D0
         TST      MGAME+2
         BGT.S    ADLAP5         If GT, Racing/Demo
         MOVE.L   #56*160,D0     Qualif/Train
ADLAP5   JSR      DSPTMR         .
         JSR      SWPSCR         Swap Screens + Beeeep!
         JSR      INSADIG
ADLAPF

* DM26JUL : Display Cup 

         TST      LASTLAP
         BEQ.S    CUPDSPF
         JSR      DSPCUP
CUPDSPF
*DM26JUL

         CMP.W    #8,MCOMM+2
         BEQ.S    PDSPNOW
         BSR      DISPLAY
PDSPNOW
         TST      MCOMM+2
         BLE      MLOOP     
         CMPI.B   #3,F12END
         BNE      MLOOP
         CMP.W    #8,MCOMM+2
         BNE.S    PDSPNO1
         BSR      DISPLAY
PDSPNO1
         TST      ESCAP          Escape/Anormal Finish
         BNE      ESCAPE         If NE, Yes      

* Next Circuit Condition

NXT      MOVE     CRCNUM,D0      Arcade/Train - Increment CRC #
         ADDQ     #4,D0          .
         CMP.W    #3,CAAPAS         MOD1JL   A CHANGER
         BLT      GOVR
         CMP      CRCMAX,D0      Compare to Max
         BGT      GOVR           Game Over
         MOVE     D0,CRCNUM
         LEA.L    DSPNXT,A0
         BRA      DISPAT

         DC.L     NXTTRA
         DC.L     NXTQAL
DSPNXT   DC.L     NXTARC
         DC.L     NXTRAC
         DC.L     NXTDEM

NXTTRA   MOVE.L   #24,MGAME
NXTARC   LEA.L    NXTCRC,A5      "Next Circuit"      
         BSR      FINAL
         JMP      NEWCRC
NXTQAL   SUBI     #4,CRCNUM      Qualif
OVRQAL   MOVE.B   #9,CAR1PAS     CALCUL CAR1PAS APRES QUALIF - JLL
*                                AVEC TOTTIM & CRCLAP
         BRA      ESCQAL0

NXTRAC   SUBI     #4,CRCNUM
         LEA.L    RACOVR,A5      "Race Over"
         BSR      FINAL
         JMP      RACSCR         
NXTDEM   LEA.L    DEMONS,A5      "Demo"
         BSR      FINAL
         JMP      NEWCRC
*
* Game Over (Last Circuit has been done)
*
GOVR     LEA.L    DSPOVR,A0
         BRA      DISPAT

         DC.L     OVRTRA
         DC.L     OVRQAL
DSPOVR   DC.L     OVRARC
         DC.L     OVRRAC
         DC.L     OVRDEM

OVRTRA   MOVE.L   #24,MGAME
         LEA.L    GAMOVR,A5        "Game Over"
         BSR      FINAL
         JMP      NEWGAM
OVRRAC   LEA.L    GAMOVR,A5        "Game Over"        
         BSR      FINAL
         JMP      RACSCR
OVRARC   LEA.L    GAMOVR,A5        "Game Over"   MOD1JL
         BSR      FINAL
         JMP      ARCSCR
OVRDEM   LEA.L    DEMOVR,A5        "Demo Over"
         BSR      FINAL
         JMP      NEWGAM           *PREVIEW =JMP NEWCRC
*
* Escape from Game
*
ESCAPE   LEA.L    DSPESC,A0
         BRA      DISPAT

         DC.L     ESCTRA
         DC.L     ESCQAL
DSPESC   DC.L     ESCARC
         DC.L     ESCRAC
         DC.L     ESCDEM

ESCTRA   MOVE.L   #24,MGAME
         LEA.L    MSGESC,A0
         MOVE.L   A0,MESSAG
         LEA.L    GAMOVR,A5      "Game Over"
         BSR      FINAL
         JMP      NEWGAM

ESCARC   LEA.L    MSGESC,A0         MOD1JL
         MOVE.L   A0,MESSAG
         LEA.L    GAMOVR,A5      "Game Over"
         BSR      FINAL
         JMP      ARCSCR

ESCQAL   MOVE.B   #0,CAR1PAS     16ieme 
ESCQAL0  MOVE     #0,PNTRECE
         LEA.L    RACE,A5        "Race"
         BSR      FINAL
         MOVE.L   #CRCDRW,A1     Point to Circuit Drawing
         MOVE.L   ACTSCR,D5      Point to Position
         MOVE     P1CRC,D4       On Both Screens
         JSR      WDOT           Display White F1 Dot
         EORI.L   #4,D5
         MOVE     P1CRC+4,D4     
         JSR      WDOT
         TST      MCOMM+2
         BLE      NEWCRC
         MOVE.L   #CRCDRW,A1     Point to Circuit Drawing
         MOVE.L   ACTSCR,D5      Point to Position
         MOVE     P2CRC,D4       on Both Screens         
         JSR      WDOT           Display White F2 Dot 
         EORI.L   #4,D5
         MOVE     P2CRC+4,D4     
         JSR      WDOT
         BSR      CARPAS         
         JMP      NEWCRC
         
ESCRAC   MOVE.L   #-1,TOTTIM
         TST      MCOMM+2        
         BLE.S    ESCRAC0        
         MOVE     LAP2,D0        
         CMP      MAXLAP,D0      
         BGT.S    ESCRAC0        IF GT, F2 did not Escaped
         MOVE.B   #-1,CAR2PAS    Say F2 Escaped DM13JUL
ESCRAC0  MOVE.B   #-1,CAR1PAS    Say F1 Escaped DM13JUL
         LEA.L    RACOVR,A5      "Race Over"
         BSR      FINAL
         TST      DEMBLD 
         BLT.S    ESCRAC1
         JMP      NEWGAM         
ESCRAC1  JMP      RACSCR
ESCDEM   LEA.L    MSGESC,A0
         MOVE.L   A0,MESSAG
         LEA.L    DEMOVR,A5      "Demo Over"
         BSR      FINAL
         JMP      NEWGAM

COMLOS   LEA.L    MSGLOS,A0
         MOVE.L   A0,MESSAG
         LEA.L    GAMOVR,A5      "Game Over"
         BSR      FINAL
         JMP      NEWGAM

DISPAT   MOVE.L   MGAME,D0
         ASR.L    #1,D0
         MOVE.L   0(A0,D0),A0
         JMP      (A0)

FINAL
         JSR      coupson      
         JSR      COPSCR         Copy Previous Screen in Current
         JSR      DSPTXT         Display "Next Circuit"
FINAL1   RTS

CARPAS   LEA.L    SNDBUF,A0
         MOVE.B   CAR1PAS,D0     
         EXT      D0             
         MOVE     D0,(A0)        
         MOVE     #2,D0
         JSR      SENDIR
CARPASA  CMPI     #2,PNTRECE     Read CAR2PAS
         BNE.S    CARPASA
         MOVE     BUFRECE,D0
         CMP.B    CAR1PAS,D0     Same Position
         BEQ.S    CARPAS0
         MOVE.B   D0,CAR2PAS     
         RTS
CARPAS0  CMPI     #0,D0          Both in Last Position?
         BNE.S    CARPAS1
         MOVE.B   #1,CAR1PAS     Both in Last
         MOVE.B   #0,CAR2PAS  
         TST      MASLAV         
         BNE      CARPASF
         MOVE.B   #0,CAR1PAS 
         MOVE.B   #1,CAR2PAS  
         BRA.S    CARPASF
CARPAS1  CMPI     #15,D0        Both in First Position?
         BNE.S    CARPAS3
         MOVE.B   #15,CAR1PAS   Both in First   
         MOVE.B   #14,CAR2PAS  
         TST      MASLAV
         BNE.S    CARPASF
         MOVE.B   #14,CAR1PAS
         MOVE.B   #15,CAR2PAS
         BRA.S    CARPASF
CARPAS3  TST      MASLAV        I am the Master?
         BNE      CARPAS4
         SUBI.B   #1,CAR2PAS 
         BRA.S    CARPASF
CARPAS4  SUBI.B   #1,CAR1PAS
CARPASF  RTS                       Not in Same Position
 
* Write Back Circuit to DEMO FILE (DEMn.DAT)

DEMWRT   JSR      coupson        
         MOVE     CRCNUM,D0       Compute ASCII 
         LSR      #2,D0           Circuit #
         ADD      #49,D0          .
         MOVE.B   D0,DMNUM
         LEA.L    DMFIL,A0        Create Demo File
         MOVE.L   #DEMEQU,A1      .
         MOVE.L   #DEMLEN,D1      .
         JSR      WRFIL           .
         BMI      ERR
         JMP      NEWGAM

ERR      TOS      TERM,1

DMFIL    DC.B     'DEM'
DMNUM    DC.B     0
         DC.B     '.DAT'
         DC.B     0
         CNOP     0,2

* LOCAL ROUTINES

DISPLAY           
* Pan Background

PANB     MOVEQ    #0,D7
         MOVE     mvtscrol,D7
         NEG      D7
         JSR      PANBCK         Pan Total Background

* Refresh Sky 

         JSR      RESKY

* Display Sky Events 

DSPSKY   MOVEQ    #SKYEQU-1,D7
         MOVE.L   #CRCSKY,A0     Point to Sky Entries
DSPSKY0  MOVEQ    #0,D5          Get Event #
         MOVE     (A0),D5        Inactive?      
         BLT.S    DSPSKYF        If LT, yes
         MOVE     2(A0),D0       Get X Position
         CMPI     #320+80,D0     Out of Screen?
         BPL.S    DSPSKY2        If PL, Yes
         LEA.L    SKYITM,A5      Get Event Item Address
         LSL      #2,D5          .
         MOVE.L   0(A5,D5),A5
         EXT.L    D0             Update position in Event Description
         MOVE.L   ACTSCR,D5
         SUBI.L   #80,D0         Patch V6
         MOVE.L   D0,10(A5,D5)   .
         MOVEM.L  D7/A0,-(A7)    Display Sky Event
         JSR      DSPIS
         MOVEM.L  (A7)+,D7/A0
DSPSKY2  ADDA.L   #6,A0
         DBF      D7,DSPSKY0
DSPSKYF

* Display Road

         JSR       DSPROD        JLL

* Sprite Items on Road (Cars, Obj,...)

         MOVE.L   usp,A5      Points to Entry
         JSR      SPRITE

* Action on Changing Tire

TIREC    MOVE     CHGTIR,D0
         BLT.S    TIRECF
         BSR      TIRCHG
TIRECF

* Display Voyants

         JSR      DSPVOY

* Crash/Shock/Jump/Shift

EVTP1    TST      CRASHE         Any Crash?
         BLT.S    EVTP3
         MOVE.L   CRASHE+8,A0
         JSR      (A0)          
EVTP3    TST      JUMPE          Any Jump?
         BLT.S    EVTPF
         BSR      JUMPA          Execute Eventual End of jump
EVTPF                      

* Display Tires

        MOVE.W  volant,D0
        ADD.W   #271,D0
        lsr.w   #3,d0
        lea.l   TABVOL(pc),a0
        move.b  0(a0,d0.w),d0
        MOVE.W  D0,PVOL
        JSR      DSPTIR
         
* Action on Filling Gaz

GAZF     MOVE     FILGAZ,D0
         BLT.S    GAZFF
         BSR      GAZFIL
GAZFF

* Display Retro

         JSR      DSPRET

* Display Retro Content

DSPRTR   MOVEQ    #0,D0          Display Normal Retro Content
         MOVE     XB,D0           
         JSR      DSPNOR         .
DSPRTRF

* Display Retro Cars (Only 2)

RETCAR   LEA.L    CARSRT,A0      Point to       
         ADDA.L   F1SRT,A0       First Car
         ADDQ.L   #2,A0          After F1
         MOVE     #0,D6
RETCAR0  CMPI     #$8001,D6      Already Dispalyed R & L
         BEQ      RETCARF        If EQ, Yes
         MOVE     (A0)+,D1       Next CAR (From Ahead to Behind)
         BLT      RETCARF        If LT, No More Active Cars
         LEA.L    OCCUR,A1
         EXT.L    D1             Car Offset in OCCUR
         MOVE.L   2(A1,D1),D0    Get Y Car
         SUB.L    Y1,D0          Compare Distance with F1
         CMPI.L   #-11000,D0   
         BLT.S    RETCARF        If PL, Not in Retro
         ADD.L    #11000,D0
         MOVE     #11,D3         0 
         LSR.L    D3,D0          To
         LSL.L    #2,D0          20
         MOVE     8(A1,D1),D2    Get Actual X 
         SUB      X1,D2          X-X1
         BPL.S    RETCAR4        If PL, Right of CE
         BTST     #15,D6         Already Displayed Retro L            
         BNE.S    RETCAR0        If LT, yes
         CMPI     #-20,D2        Just Behind?        
         BPL.S    RETCAR0        If PL, Yes Do not Display
         MOVEM.L  D6/A0,-(A7)
         MOVE.B   0(A1,D1),D1    Car # (0,1,2)
         JSR      DSPOLR         Display Left car in Retro
         MOVEM.L  (A7)+,D6/A0
         BSET     #15,D6         Remember display L
         BRA.S    RETCAR0
RETCAR4  BTST     #0,D6          Already Dispalyed Retro R            
         BNE.S    RETCAR0        If LT, yes
         CMPI     #20,D2         Just Behind?
         BLT.S    RETCAR0        If LT, Yes, Do not Display
         MOVEM.L  D6/A0,-(A7)
         MOVE.B   0(A1,D1),D1    Car # (0,1,2)
         JSR      DSPORR         Display Right Car in Retro
         MOVEM.L  (A7)+,D6/A0
         BSET     #0,D6          Remember display R
         BRA      RETCAR0
RETCARF

* Display Fire in Retro

FIRET    MOVE     ENGLIG,D0      For Fire in Retro if <0
         BPL.S    FIRETF
         JSR      DSPFIR         .
FIRETF

* Display Gaz level

DSPGZ    MOVEQ    #0,D0
         MOVE     GAZ,D0
         BLT.S    DSPGZF
         MOVE     #0,D1         DM20JUL
         JSR      DSPGAZ
DSPGZF

* Display Gear 

         MOVEQ    #0,D0
         MOVE     GEAR,D0
         JSR      DSPGER

* Display Regime

         MOVE     RPMIN,D0
         JSR      DSPREG

* Display Speed

         LEA.L    SPEDIG,A0
         JSR      DSPSPD

* Display Front Car

DSPFCR   MOVEQ    #0,D0
         JSR      DSPCAR
         MOVE     volant,D0
         BNE      DSPFCRF
         MOVE.L   CURSCR,A5         3 red Points on Steering Wheel
         LEA.L    160*175+80(A5),A5 (ADDA.L   #160*175+80,A5)
         AND.L    #$7FFF7FFF,(A5)
         AND.L    #$7FFF7FFF,4(A5)
         OR.L     #$00008000,(A5)
         OR.L     #$00008000,4(A5)
         LEA.L    160(A5),A5        (ADDA.L   #160,A5)
         AND.L    #$7FFF7FFF,(A5)
         AND.L    #$7FFF7FFF,4(A5)
         OR.L     #$00008000,(A5)
         OR.L     #$00008000,4(A5)
         LEA.L    160(A5),A5        (ADDA.L   #160,A5)
         AND.L    #$7FFF7FFF,(A5)
         AND.L    #$7FFF7FFF,4(A5)
         OR.L     #$00008000,(A5)
         OR.L     #$00008000,4(A5)
DSPFCRF

* Display Brake and Accelerator

BRAC     MOVE     PVOL,D0            Do not display for extreme
         BEQ.S    BRACF
         CMPI     #6,D0
         BEQ.S    BRACF
         MOVE.L   CURSCR,A4
         ADDA.L   #193*160+72,A4 Brake 
         MOVE.L   A4,A5         
         ADDQ.L   #8,A5         Accel
         MOVE     ACCEL,D0
         ASR      #3,D0 
         MULS     #160,D0
         BEQ.S    BRAC4         If EQ, No Accel/No Brake
         BLT.S    BRAC3
         SUBA.L   D0,A5
         BRA.S    BRAC4
BRAC3    ADDA.L   D0,A4
BRAC4    ANDI.L   #$FFF9FFF9,(A4) Display Brake
         ORI.L    #$00060000,(A4)+
         ANDI.L   #$FFF9FFF9,(A4)   
         ORI.L    #$00000006,(A4)
         ANDI.L   #$3FFF3FFF,(A5) Display Accel
         ORI.L    #$C0000000,(A5)+
         ANDI.L   #$3FFF3FFF,(A5)
         ORI.L    #$0000C000,(A5)
BRACF

* Compute and Display Score
         TST      MGAME+2           MOD1JL
         BNE      SCOR5
         MOVE.L   ASCORE,D0
         TST      ENDCRC         End of Circuit Sequence
         BNE.S    SCOR0          If NEQ, YES
         MOVE.W   SP1D+2(PC),D1
         SUB.W    #300,D1
         BLT.S    SCORV
         ADDQ.L   #1,D0
         CMP.W    #100,D1
         BLT.S    SCORV
         ADDQ.L   #1,D0
         CMP.W    #150,D1
         BLT.S    SCORV
         ADDQ.L   #1,D0
         CMP.W    #175,D1
         BLT.S    SCORV
         ADDQ.L   #1,D0
         CMP.W    #187,D1
         BLT.S    SCORV
         ADDQ.L   #1,D0
SCORV    ADD.L    DELSCO(PC),D0      Add Delta
         BPL.S    SCOR1
         MOVEQ    #0,D0
SCOR1    MOVE.L   D0,ASCORE      .
SCOR0    CLR.L    DELSCO         Clear Delta
         LEA.L    ASCODIG,A0     .
         JSR      TTNUM          (Then Thousand)
         LEA.L    ASCODIG,A0     Display ARCADE Score
         LEA.L    NUMSCR,A5      in Current
         JSR      DSPSCR         .
         BRA      SCORF
SCOR5    MOVE.L   TOTTIM,D0      RACING/QUALIF/DEMO/TRAIN
         BPL.S    SCOR6
         MOVEQ    #0,D0
SCOR6   
        MOVE.L  Y1,D0   VIRER   MODJLL
         LEA.L    TIMDIG,A0      
        DIVU    #10,D0          MODJLL
        AND.L   #$FFFF,D0
         JSR      TTNUM        MODJLL  TIMNUM
         LEA.L    TIMDIG,A0      Display RACING SCORE       
         LEA.L    NUMSCR,A5      in Current
         MOVE.L   #35*160,D0     Assume Racing/Demo         
         TST      MGAME+2
         BGT.S    SCOR8          If GT, Racing/Demo Score
         MOVE.L   #52*160,D0     Qualif/Train
         CMPI     #-16,MGAME+2   
         BEQ.S    SCOR7          If EQ, Train
         JSR      DSPTMQ         .
         BRA      SCORF
SCOR7    MOVE.L   #48*160,D0     Train 
SCOR8    JSR      DSPTMR         .

        MOVE.L  Y1+64,D0        VIRER   MODJLL
        LEA.L   TIMDIG,A0
        DIVU    #10,D0          MODJLL
        AND.L   #$FFFF,D0
        JSR     TTNUM          TIMNUM  MODJLL
        JSR     INSADIG
        LEA.L   TIMDIG,A0
        LEA.L   NUMSCR,A5
        MOVE.L  #43*160,D0
        JSR     DSPTMR
        MOVE.L  Y1+128,D0       VIRER   MODJLL
        LEA.L   TIMDIG,A0
        DIVU    #10,D0          MODJLL
        AND.L   #$FFFF,D0
        JSR     TTNUM
        JSR     INSADIG
        LEA.L   TIMDIG,A0
        LEA.L   NUMSCR,A5
        MOVE.L  #51*160,D0
        JSR     DSPTMR
        JSR     INSADIG         VIRER MODJLL
SCORF

* Flip-Flop Screens

FLIP     MOVE     FIRST,D0       Test First Time
         BEQ.S    FLIP0
         CLR      FIRST          Say no Longer First
         LEA.L    BANPIL0,A0     Set Banner Palette 
         LEA.L    BANPAL,A1 
         MOVEQ    #7,D0
BPAL0    MOVE.L   (A0)+,(A1)+
         DBF      D0,BPAL0
         LEA.L    CRCPIL0,A0     Set Circuit Palette
         LEA.L    CRCPAL,A1 
         MOVEQ    #7,D0
BPAL1    MOVE.L   (A0)+,(A1)+
         DBF      D0,BPAL1
         JSR      PALSOMB
FLIP0    
         LEA.L    CURSCR,A0       Set New Screen Address
         MOVEQ    #0,D0         MODJLL
         MOVE.B   1(A0),D0
         SWAP     D0
         MOVE.B   2(A0),D0
         MOVE.W   #$8200,A0
         MOVE.L   D0,(A0)
*         MOVE.B   1(A0),$FFFF8201 .
*         MOVE.B   2(A0),$FFFF8203 .
         JSR      SWPSCR         Swap Screens
         RTS

* Action on Tire Changing

TIRCHG   CLR      ENDCRC     DM26JUL
         CLR      volant     Say Straight Wheels
         CLR      WHLINC
         CMPI     #30,D0
         BPL.S    TIRCHG1
TIRCHG0  MOVE     D0,D1
         ANDI     #$4,D1
         BNE.S    TIRCHG9
         MOVEQ    #0,D5       Display Tire man (Bot 1)
         LEA.L    TIRMAN,A5
         JSR      DSPITN
         MOVEQ    #1,D5       Display Tire man (Top 1)
         LEA.L    TIRMAN,A5
         JSR      DSPITN
         BRA      TIRCHG3
TIRCHG9  MOVEQ    #2,D5       Display Tire man (Bot 2)
         LEA.L    TIRMAN,A5
         JSR      DSPITN
         MOVEQ    #3,D5       Display Tire man (Top 1)
         LEA.L    TIRMAN,A5
         JSR      DSPITN
         BRA      TIRCHG3
TIRCHG1  CMPI     #50,D0
         BPL.S    TIRCHG2
         MOVEQ    #4,D5       Display Tire man (Bot 3)
         LEA.L    TIRMAN,A5
         JSR      DSPITN
         MOVEQ    #5,D5       Display Tire man (Top 3)
         LEA.L    TIRMAN,A5
         JSR      DSPITN
         MOVEQ    #6,D5       Display Tire man (Tire)
         LEA.L    TIRMAN,A5
         JSR      DSPITN
         MOVE     #1,NTIR     Say No Tire Right
         BRA.S    TIRCHG3
TIRCHG2  CMPI     #80,D0
         BPL.S    TIRCHG4
         CLR      NTIR
         BRA      TIRCHG0
TIRCHG3  ADDQ     #1,CHGTIR
         RTS
TIRCHG4  BCLR     #3,LOCK
         MOVE     #2048,TIRUSE Say New Tire
         MOVE     #0,TIRLIG    .
         MOVE     #-1,CHGTIR   .
         RTS

* Action on Filling Gaz

GAZFIL   CLR      ENDCRC      DM26JUL
         CLR      volant      Say Straight Wheels
         CLR      WHLINC
         CMPI     #15,D0
         BPL.S    GAZFIL1
         MOVEQ    #0,D5       Display Gaz Man (Bot)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
         MOVEQ    #1,D5       Display Gaz Man (Top)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
         MOVEQ    #2,D5       Display Gaz Man (Gun)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
         BRA      GAZFIL4
GAZFIL1  MOVE     GAZ,D1
         ADDI     #300,D1
         CMPI     #25600,D1
         BPL.S    GAZFIL2
         MOVE     D1,GAZ      Filling Gaz
         MOVEQ    #5,D5       Display Gaz Man (Bot)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
         MOVEQ    #6,D5       Display Gaz Man (Top)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
         BRA      GAZFIL5
GAZFIL2  CMPI     #30,D0
         BPL      GAZFIL9
         MOVEQ    #0,D5       Display Gaz Man (Bot)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
         MOVEQ    #1,D5       Display Gaz Man (Top)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
         MOVEQ    #2,D5       Display Gaz Man (Gun)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
         MOVE     FILGAZ,D0
         CMPI     #20,D0
         BNE.S    GAZFIL3
         MOVEQ    #3,D5       Display Gaz Man (Drop1)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
         BRA.S    GAZFIL4
GAZFIL3  CMPI     #21,D0
         BNE.S    GAZFIL4
         MOVEQ    #4,D5       Display Gaz Man (Drop2)
         LEA.L    GAZMAN,A5
         JSR      DSPITN      .
GAZFIL4  ADDQ     #1,FILGAZ
GAZFIL5  RTS
GAZFIL9  BCLR     #2,LOCK
         MOVE     #-1,FILGAZ
         RTS


* Events Action Routines  (A0,D1 should be preserved)
* Input : A0 points to 32 Bytes Entry

DUMMY    RTS
         
* CRASH - Crash Synchronous Routines

* Normal Crash on Object (I=Init, A=Action)
*

CRASHI   MOVE.L   #CRASHB,CRASHE+8 SMALL CRASH 
         SUBI     #10,TIRUSE
         BRA.S    CRASHI1
CRASHJ   MOVE.L   #CRASHA,CRASHE+8 BIG CRASH
         SUBI     #100,TIRUSE
         CLR      CRASHE+2     Say Crash for JLL
         MOVE     SP1D+2,CRASHE+4 Save Crash Speed for JLL
CRASHI1  BSET     #0,LOCK
         CLR      CRASHE       Say Crash for DM
         MOVE     D4,CRASHE+6  Save Crash Position
         MOVE     #1000,RPMIN  Clear Regime
         CLR.L    SP1DBIS      Clear Speed 
         CLR.L    GEAR         Clear GEAR + PGEAR
         CLR      ACCEL        Clear ACCELL
         CLR.L    JOY+2        RAZ Xm & Ym
CRASHIF  RTS

CRASHA   CMPI     #35,CRASHE   BIG CRASH V>60 (JLL is Crashing)
         BEQ      CRASHF
         CMPI     #17,CRASHE   Crash 0 to 17
         BPL      CRASH4
         MOVE     #1,D4        Assume Right
         MOVE     CRASHE+6,D6  Get Accident Position
         BPL.S    CRASH2       If PL, Right
         NEG      D6           Left
         MOVE     #-1,D4       Say left
CRASH2   CMPI     #40,D6       Tire Jump?
         BLT.S    CRASH3       If LT, No
         MOVE     D4,NTIR      Say No Tire
         MOVEQ    #0,D3        Display Jumping Tire
         MOVE     CRASHE,D3    0 to 17
         LEA.L    POSTIR,A3    Compute #,DX,Y of Tire from Table
         LSL      #4,D3        Point to Entry in POSTIR
         MOVE.L   #160,D6      Compute X=160+-DX
         TST      D4           .
         BPL.S    CRASH22      .
         SUB.L    4(A3,D3),D6  .
         SUB.L    4(A3,D3),D6  .
         SUB.L    #16,D6
CRASH22  ADD.L    4(A3,D3),D6  .
         LEA.L    TIRE,A5      Point to Tire Item
         ADDA.L   0(A3,D3),A5  .
         MOVE.L   ACTSCR,D5
         MOVE.L   D6,10(A5,D5) Put X in Item
         MOVE.L   8(A3,D3),0(A5,D5) Put Y0
         MOVEM.L  D1/A0,-(A7)
         JSR      DSPITN0      Display Tire
         MOVEM.L  (A7)+,D1/A0
CRASH3   MOVEQ    #0,D5        Display Accident
         MOVE     CRASHE,D5    0 to 17
         LSL      #5,D5        .
         LEA.L    ACCID1,A5    .
         ADDA.L   D5,A5        .
         MOVE     CRASHE+6,D6  Compute Position of Accident
         ADD      #160,D6      .
         CLR      D5           .
         MOVE.B   27(A5),D5    .
         LSL      #4,D5        .
         LSR      #1,D5        .
         SUB      D5,D6        .
         EXT.L    D6           .
         MOVE.L   ACTSCR,D5    Put it in
         MOVE.L   D6,10(A5,D5) Accid
         MOVEM.L  D1/A0,-(A7)
         JSR      DSPITN0      Display it
         MOVEM.L  (A7)+,D1/A0
CRASH4   ADDQ     #1,CRASHE    Increment Accident Action 
         RTS

CRASHB   CMPI     #1,CRASHE
         BEQ.S    CRASHF
         BSR      SHOCKA      Shock Display
         ADDQ     #1,CRASHE

CRASHF   CLR      NTIR        Say Tire Again (if Necessary)
SHIFTA   TST      SHIFTE      Already Shifting
         BEQ.S    SHIFTA0
         CLR      SHIFTE      Say SHIFT
         MOVE     X1,SHIFTE+2 Shift Direction
         NEG      SHIFTE+2    ***
SHIFTA0  TST.L    haldco      Parralel?
         BNE.S    SHIFTAF     If NE, No     
         BTST.B   #7,LANE     Pitstop?
         BEQ.S    SHIFTA1     If EQ, No
         TST      SHIFTE+2    Left Object    
         BPL.S    SHIFTA1     If PL, Yes
         CMPI     #80,X1      Back on Road? 
         BPL.S    SHIFTAF     If PL, No
         BRA.S    SHIFTA2      
SHIFTA1  TST      topvib      Still on Grass or Stripe?
         BNE.S    SHIFTAF     If NE, Yes
SHIFTA2  BCLR     #0,LOCK     Unlock Commands
         CLR      volant      Put Wheels/Steering Straight
         CLR      WHLINC
         MOVE     #-1,SHIFTE  No More SHIFT
         MOVE     #-1,CRASHE  Clear CRASH Condition
SHIFTAF  RTS

*
*        Crash on Car (D4 = Position of Crash)
*        (I=Init A= Action)
*

CRASHCI  TST       JUMPE+2       SMALL CRASH : Currently Jumping (Jll en L'air)?
         BLE.S     CRASHCI0      If LE, No
         CMPI      #-188,htprl   test height
         BPL.S     CRASHCI0
         RTS                     Don't Crash, Too High    
CRASHCI0 SUBI.L    #75,SP1DBIS   SMALL SHOCK :Decrease Speed by 50 
         BPL.S     CRASHCI3
         CLR.L     SP1DBIS       
CRASHCI3 MOVE.L    #CRASHCB,CRASHE+8 SHOCK Action Routine
         SUBI      #10,TIRUSE 
         MOVE      D4,CRASHE+6   Save Shock Position   
         CLR       CRASHE        Say DM Crash   
         RTS

CRASHCB  BSR      SHOCKA      SMALL CRASH ACTION : Shock Display
         MOVE     #-1,CRASHE  Clear Crash Condition
         RTS         

SHOCKA   LEA.L    ACCID1,A5   Display First Position of Accident
         MOVE     CRASHE+6,D6 Compute Position of Accident
         ADD      #160,D6     .
         CLR      D5          .
         MOVE.B   27(A5),D5   .
         LSL      #4,D5       .
         LSR      #1,D5       .
         SUB      D5,D6       .
         EXT.L    D6          .
         MOVE.L   ACTSCR,D5
         MOVE.L   D6,10(A5,D5) In Item
         MOVEM.L  D1/A0,-(A7)
         JSR      DSPITN0
         MOVEM.L  (A7)+,D1/A0
         RTS

CRASHCJ  TST       JUMPE+2       BIG CRASH : Currently Jumping (Jll en L'air)?
         BLE.S     CRASHCJ0      If LE, No
         CMPI      #-188,htprl   test height
         BPL.S     CRASHCJ0
         RTS                     Don't Crash, Too High   
CRASHCJ0 LSL       #1,D5         Double Speed Gap (*** BUG ***)
         MOVE.L    #CRASHCA,CRASHE+8 Action Routine
         SUBI      #100,TIRUSE
         CLR       CRASHE        Say Crash for DM
         CLR       CRASHE+2      Say Crash for JLL
         MOVE.L    16(A1,D1),SP1DBIS Set Speed to Car Ahead Speed
         LSL       #1,D5         Double Speed Gap (*** BUG ***)
         MOVE      D5,CRASHE+4   Save Delta Speed for JLL 
         MOVE      D4,CRASHE+6   Save Crash Position
         SUBI.L    #75,SP1DBIS   Decrease Speed by 50 
         BPL.S     CRASHCJ3
         CLR.L     SP1DBIS       
CRASHCJ3 MOVE      #1000,RPMIN   Clear Regime
         CLR.L     GEAR          Clear GEAR+PGEAR
         CLR       ACCEL         Clear Acceleration
         CLR.L     JOY+2         RAZ Xm & Ym
CRASHCI4 RTS

CRASHCA  CMPI     #16,CRASHE  BIG CRASH ACTION   
         BEQ      CRASHCA5
         MOVEQ    #0,D5       Display Accident
         MOVE     CRASHE,D5   0 to 16
         LSR      #1,D5
         LSL      #5,D5       .
         LEA.L    ACCID2,A5   .
         ADDA.L   D5,A5       .
         MOVE     CRASHE+6,D6 Compute Position of Accident
         ADD      #160,D6     .
         CLR      D5          .
         MOVE.B   27(A5),D5   .
         LSL      #4,D5       .
         LSR      #1,D5       .
         SUB      D5,D6       .
         EXT.L    D6          .
         MOVE.L   ACTSCR,D5    Put it in
         MOVE.L   D6,10(A5,D5) Accid
         MOVEM.L  D1/A0,-(A7)
         JSR      DSPITN0     Display it
         MOVEM.L  (A7)+,D1/A0
         ADDQ     #1,CRASHE   Increment Accident Action 
         RTS
CRASHCA5 TST      CRASHE+2    JLL has finished?
         BLT.S    CRASHCAF    If LT, Yes
         SUBI     #30,SP1D+2  Decrease Speed by 20 Km/h
         BPL.S    CRASHCA6
         CLR.L    SP1D
CRASHCA6 RTS
CRASHCAF MOVE     #-1,CRASHE  Clear Crash Condition  
         RTS

*
* JUMP Routines (I=Init, A=Action) 
*
JUMPI    MOVE     SP1D+2,D5   JUMP ON OBJECT
         TST      CRASHE      Currently Crashing?
         BPL      JUMPIF      If PL, Yes, Don't Jump
         TST      JUMPE       Currently Jumping?
         BLT.S    JUMPI1      If LT, No
         CMPI     #-188,htprl Possible Crash
         BLT.S    JUMPIF      If LT, No, Don't Jump
         BRA      CRASHI      Go & Crash on Object (no Y Reduction/too Late)

JUMPJ    LSL       #1,D5      JUMP ON CAR : Double Speed Gap (*** BUG ***)
         TST      CRASHE      Currently Crashing?
         BPL      JUMPIF      If PL, Yes (Don't Jump)  (**BPL      CRASHCI3)
         TST      JUMPE       Currently Jumping?
         BLT.S    JUMPI1      If LT, No
         CMPI     #-188,htprl Possible Crash
         BLT.S    JUMPIF      If LT, No
         BRA      CRASHCJ     Go & Crash on Car (No Y reduction/too Late)        
JUMPI1   MOVE.L   D3,D2       Create Condition so as not to Crash on the
         ADD.L    #FRTCRH+2,D2 Same Object (D3=Yv) or Car Next Cycle (D3=Ya)
         TST      MGAME+2     Arcade?
         BNE.S    JUMPI2
         BSET     #1,LOCK 
JUMPI2   SUBI     #10,TIRUSE
         CLR      JUMPE       Say Jumping for DM
         CLR      JUMPE+2     Say Jumping for JLL
         MOVE     D5,JUMPE+4  Save Crash Delta Speed for JLL
JUMPIF   RTS 

JUMPA    TST      BTIR
         BNE      JUMPA31
         CMPI     #3,JUMPE+2  JLL has touched the ground?
         BPL.S    JUMPA3      If PL, Yes
         RTS
JUMPA3   BEQ      JUMPA7      If EQ, No Broken Tires, No Shift
         SUBI     #90,TIRUSE  
         BSET     #1,LOCK     Keep Commands locked
         MOVE     #1,BTIR     Say Broken Tires
         CLR      volant      Wheels/Steering Wheel Straight
         CLR      WHLINC
         MOVE     #1000,RPMIN
         CLR.L    GEAR        Clear GEAR+PGEAR
         CLR      ACCEL       Clear ACCEL
         CLR.L    JOY+2       Clear Xm andm 
JUMPA31  TST      SP1D+2      Wait Until SP1D=0 (From Frottement Sol)
         BEQ.S    JUMPA4
         RTS
JUMPA4   MOVE     JUMPE,D5
         CMPI     #10,D5
         BPL.S    JUMPA5
         EXT.L    D5          Display Smokes from 0 to 9
         LSR      #1,D5       .
         LSL      #5,D5       .
         LEA.L    SMOKE,A5    .
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D5   Smoke Left
         MOVE.L   #111,10(A5,D5)
         MOVE.L   A5,-(A7)    .
         JSR      DSPITN0     .
         MOVE.L   (A7)+,A5
         MOVE.L   ACTSCR,D5   Smoke Right
         MOVE.L   #199,10(A5,D5)
         JSR      DSPITN0     .
JUMPA5   ADDQ     #1,JUMPE
         MOVE     JUMPE,D5
         CMPI     #40,D5      Wait Until 50 Cycles
         BPL.S    JUMPA6
         RTS
JUMPA6   CLR      BTIR        No More Broken Tires
JUMPA7   BCLR     #1,LOCK     If Necessary
         MOVE     #-1,JUMPE   Clear Jump Position
         RTS

*
* REDUCE Routines (I=Init and action) 
*
REDUI    MOVE.L   D3,D2        Create Condition so as not to Crash
         ADD.L    #FRTCRH+2,D2 on the Same Object or Car Next Cycle
         SUBI.L   #60,SP1DBIS  Decrease Speed 
         BPL.S    REDUI2
         CLR.L    SP1DBIS      
REDUI2   RTS

* LOCAL VARIABLES AND TABLES

* For Circuit

CRCNUM   DC.W     0     Circuit #
CRCMAX   DC.W     0     Max Circuit #
CRCECH   DC.W     0     Circuit Scale for Drawing
CRCLAP   DC.L     0     Circuit Lap Length

P1CRC    DC.W     0     Position of F1 on Circuit 1
         DC.W     0     Dummy
         DC.W     0     "           F1            2 
         DC.W     0     Dummy
P2CRC    DC.W     0     Position of F2 (Opponent) on Circuit 1
         DC.W     0     Dummy
         DC.W     0     "           F2                       2
         DC.W     0     Dummy

* Some Equivalences

FRTCRH   EQU      64    Front Crash Position (Adjusted 15 Jan 91)                           
VIEWLEN  EQU      20000 Champ de Vision

* Road Variables

LEFROD   DC.W     256   Left Road Width in Pixel at Line 0
RIGROD   DC.W     256   Right Road Width in Pixel at Line 0
XB       DC.W       0   Actual X Botoom of Road (-X1)
DX1      DC.B       0   DX1 for Communication to F2   
         DC.B       0
SAVX1    DC.W       0
SAVSP1D  DC.W       0
SP1DBIS  DC.L       0   
         
* F1 Variables (Position, Speed and Gear)

ACCEL    DC.W     0
WHLINC   DC.W     0     Joystick Mocking Mouse
SPEDIG   DC.W     0     Hundreds in Km/h
         DC.W     0     Tens        "
         DC.W     0     Units       "
RPMIN    DC.W     0     Round per Minute
SKPSPD   DC.W     0     Skip Speed for Other cars
GEAR     DC.W     0     Gear (including dead Point)
PGEAR    DC.W     0     Previous Gear
GRDOWN   DC.W     0     No Braking After Gear Down (-5 to 0)
GAZ      DC.W     0     Gaz Level (4475 to 0,-1 = Empty)
RETFIR   DC.W     0     Fire in Retro
TIRUSE   DC.W     0     Tire Usage (2048 to 0)
TIRUSA   DC.W     0     Cycle Tire Usage (0 or -)
ENGUSE   DC.W     0     Engine Usage
LAP      DC.W     0     Pass Lap Indicator (0 or 1)
OVER     DC.W     0     Pass/passed Car Indicator (-1,0,1)
OVER2    DC.W     0

* Miscalleneous

FIRE     DC.W     0     Fire Indicator (Joystick/Mouse)
FIRST    DC.W     0     First Loop Indicator
LIG      DC.W     0     Light (1 = Red, 0 = Orange, -1 = Green)
LIGCNT   DC.W     0     Light Count (From 25 to 0)
STEP     DC.W     0     Step Mode
         DC.L     0     SAVE TIME FOR PAUSE
DEMO     DC.W     0     Demo Indicator
DEMBLD   DC.W     0     Demo Build Indicator
*NOISE    DC.W     0     Noise from Grass or Stripe     MOD1JL
CAAPAS   DC.W     0     Overpassed Cars Counter (ARCADE)
MAXLAP   DC.W     0     Max Laps per Circuit
SAVLAP   DC.L     0     Save MLAPS for Qualif
LASTLAP  DC.W     0     Last Lap For Racing if 1
ENDCRC   DC.W     0     Finish Circuit Sequence (0, 50 to 0)
LOCK     DC.W     0     Lock Commands Indic Bit 0 = Crash Obj Lock
*                                           Bit 1 = Jump Lock
*                                           Bit 2 = Gaz Lock
*                                           Bit 3 = Tire Lock
*                                           Bit 4 = Depart Lock in Comm
*                                           Bit 5 = Escape Lock in Com
CHGTIR   DC.W     -1    Tire Changing Indicator
FILGAZ   DC.W     -1    Filling Gaz Indicator
DELSCO   DC.L     0     Delta of Score during Loop
DUMSCROL DC.L     0     Dummy Scrolling when shifting
AUTO     DC.W     0     Automatic Point Mort 2 Cycles
SNDBUF   DC.W     0     Buffer for SENDIR

F12END   DC.B     0     F1/F2 Finished
         DC.B     0
ESCAP    DC.W     0     F1 Escaped

* topvib   .W           Vibration (0, 1=Grass, 2=Stripes)
* mvtscrol .W           Pan Value >+-16
* decaco   .L           XB in Cm
* haldco   .L           Angular Value (0 if //)
* 
* Events Pointers

FEVTAD   DC.L     0     Next Event Pointer Address 

* OCCUR Car Occurence Buffer for 16 Car Events
*
* Fisrt Entry  = F1
* Second Entry = F2 if Comm
*
* 0  B   Evt # (-1 F1, 0 = F2, 1,2) 
* 1  B   8 Bits
* 2  L   Y in cm  
* 6  W   Initial X in Pixels on Line 0 + Bits (LE/CE/RI)
* 8  W   Actual  X in Pixels on line 0
* 10 W   Lap #  
* 12 L   MaxSpd (a la SP1D)
* 16 L   Curspd (SP1D for F1)

*        Curve
* 20 W   Next Curve Event # 
* 22 L   Next Curve Distance
* 26 B   Current Curve Type (0,-1 to -8, 1 to 8) 
* 27 B   Anticipated Curve Type (0,-1 to -8, 1 to 8) 
* 28 W   Current Curve Max Speed
* 30 W   Re Acceleration Distance in Current Curve
* 32 L   Next Anticipated Curve Distance
* 36 W   Next Anticipated Maxspd
* 38 W   Speed Reduction in Anticipation (a or 0)
* 40 L   Braking Distance for Anticipation
*        Relief
* 44 W   Next Relief Event # 
* 46 L   Next Relief Distance
* 50 B   Curr Relief Type (0,-m,m)
* 51 B   Dummy
*        Lane
* 52 W   Next Lanes Event # 
* 54 L   Next Lanes Distance
* 58 B   Curr Lanes Type (Idem Mask)
* 59 B   CARnPAS  
* 
* 60 L   Reserved for Overpassing

OCCUR    DC.B     -1    First Entry is F1 Car
         DC.B     0     Flag
Y1       DC.L     0     Current Y
         DC.W     0     Max X (Dummy)
X1       DC.W     0     Current X
LAP1     DC.W     0     Lap
         DC.L     0     Max Spd (Dummy)
SP1D     DC.L     0     Current Spd
         DS.B     6
CURV     DC.B     0     Current Curve Type (S=0, R=1 to 8, L=-1 to -8) 
         DS.B     23    
RELF     DC.B     0     Current Relief
         DS.B     3  
NLAN     DC.L     0     Next Lane Distance
LANE     DC.B     0     Current Lane Configuration 
CAR1PAS  DC.B     0
         DS.B     4

         DS.B     2     Second Entry is F2 Car (If Comm)
Y2       DC.L     0
         DC.W     0     Max X (Dummy)
X2       DC.W     0     Current X
LAP2     DC.W     0
         DC.L     0
SP2D     DC.L     0
         DS.B     39
CAR2PAS  DC.B     0
         DS.B     4
         
         DS.B     64*14 Other 14 Entries

         DC.W     -2    Begining of Sorting Buffer
CARSRT   DS.W     16    Car Sorting Buffer
         DC.W     -1    End of Sorting Buffer

F1SRT    DC.L     0     F1 Offset in CARSRT
              
CARITM   DC.L     0     CR1   Car 1
         DC.L     0     CR2   Car 2
         DC.L     0     CR3   Car 3  (Second Player)
*
* Sky Events
*

SKYITM   DC.L     ZEPLL Sky Events
         DC.L     ZEPLR
         DC.L     PLANL
         DC.L     PLANR
         DC.L     BALL
         DC.L     FUJI
         DC.L     TOWER
         DC.L     DESERT
         DC.L     MOUNT
         DC.L     CLOUD1
         DC.L     CLOUD2
         DC.L     CLOUD3
         DC.L     CLOUD4
         DC.L     CLOUD5
         DC.L     CLOUD6

* J.L. Langlois Entries for VET

*  0 W Event # + 8 bits
*  2 B RAPPORT JLL
*  3 B Line #                                 
*  4 B # of non displayable lines 
*  5 B Dummy            
*  6 W Actual DX in Pixels                    
*
*  8 Bits for Curve
*       
*    000000000 = Straight
*    Crv 00100 = Right
*    Crv 01000 = Left
*
*  8 Bits for Relief
*
*    000000001 = Flat
*    000000101 = Up
*    000001001 = Down
*
*  8 Bits for Lane :
*
*    000011111 = 1F = 2L after 3L
*    000001111 =  F = 3L
*    000011011 = 1B = 2L after 1L
*    000001011 =  B = 1L

* Actions on Vertical Events 
* 0= No action
* 1= Crash Normal 
* 2= Jump
* 3= Feuillage

EVTACT   DC.L     DUMMY    
         DC.L     CRASHI
         DC.L     JUMPI   
         DC.L     REDUI
         DC.L     0
         DC.L     0

* Slope & Shake Definition

JUMPE    DC.W     -1    DM  Jump Indicator (-1 = No Jump, 0 to n)
         DC.W     -1    JLL Jump Indicator  -1= Not Jump or finished
*                                            0= DM says JUMP to JLL
*                                            1= Going up
*                                            2= Going Down
*                                            3= Touch Ground/No Broken tires
*                                            4= Touch Ground/Broken Tires
         DC.W      0    JLL Jump Speed

CRASHE   DC.W     -1    DM  Crash Indicator (-1 = No Crash,0 to n)
         DC.W     -1    JLL Crash Indicator (-1= No Crash, ...)
         DC.W      0    JLL Crash Delta Speed 
         DC.W      0    DM  Crash Position 
         DC.L      0    DM  Crash Routine

SHOCKE   DC.W     -1    DM  Shock Indicator (-1 = No Shock, 0 to 0)
         DC.W      0    DM  Shock Position

SHIFTE   DC.W     -1    Shift Indicator
         DC.W      0    Shift Direction
   
TABVOL  dc.b    0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    1,1,1,1,1,1,1,1,1,1,1,1,1,1
        dc.b    2,2,2,2,2,2
        dc.b    3,3
        dc.b    4,4,4,4,4,4
        dc.b    5,5,5,5,5,5,5,5,5,5,5,5,5,5
        dc.b    6,6,6,6,6,6,6,6,6,6,6,6,6

* Positions of Jumping Tire

POSTIR
         DC.L     0
         DC.L     216-160
         DC.L     179*160
         DC.L     0

         DC.L     0
         DC.L     221-160
         DC.L     167*160
         DC.L     0

         DC.L     0
         DC.L     227-160
         DC.L     147*160
         DC.L     0

         DC.L     0
         DC.L     233-160
         DC.L     134*160
         DC.L     0

         DC.L     32
         DC.L     241-160
         DC.L     121*160
         DC.L     0

         DC.L     32
         DC.L     247-160
         DC.L     111*160
         DC.L     0

         DC.L     32
         DC.L     254-160
         DC.L     106*160
         DC.L     0

         DC.L     32
         DC.L     260-160
         DC.L     103*160
         DC.L     0

         DC.L     32
         DC.L     266-160
         DC.L     100*160
         DC.L     0

         DC.L     64
         DC.L     273-160
         DC.L     103*160
         DC.L     0

         DC.L     64
         DC.L     279-160
         DC.L     106*160
         DC.L     0

         DC.L     64
         DC.L     285-160
         DC.L     111*160
         DC.L     0

         DC.L     64
         DC.L     291-160
         DC.L     121*160
         DC.L     0

         DC.L     96
         DC.L     298-160
         DC.L     134*160
         DC.L     0

         DC.L     96
         DC.L     304-160
         DC.L     147*160
         DC.L     0

         DC.L     96
         DC.L     310-160
         DC.L     167*160
         DC.L     0

         DC.L     96
         DC.L     317-160
         DC.L     179*160
         DC.L     0

         DC.L     96
         DC.L     325-160
         DC.L     205*160
         DC.L     0

         END
