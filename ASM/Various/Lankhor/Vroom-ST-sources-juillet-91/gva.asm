* NORMAL CAR / SUCCESFULL OVERPASS

CARLOP17 TST.B     0(A1,D1)      SUCCESSFUL OVERPASSING : Overpassing F1?
         BPL.S     CARLOP18      If PL, No
         TST       MGAME+2       Arcade
         BEQ.S     CRLOP17A      If EQ, Yes
         MOVE      10(A1,D0),D5  Compare Laps car
         CMP       LAP1,D5       with F1 Lap
         BNE.S     CRLOP18A
CRLOP17A SUB       #1,OVER       Say F1 Overpassed
         BRA.S     CRLOP18A
CARLOP18 TST       MCOMM+2
         BLE.S     CRLOP18A
         TST.B     0(A1,D1)      Overpassing F2?
         BGT.S     CRLOP18A      If GT, No
         MOVE      10(A1,D0),D5  Compare Laps car
         CMP       LAP2,D5       with F2 Lap
         BNE.S     CRLOP18A
         SUB       #1,OVER2      Say F2 Overpassed
CRLOP18A MOVE.L    D4,60(A1,D0)  Save Overpassed Car Delta (D4<=0)
         MOVE      4(A7),D5
         LSL       #1,D5
         NEG       D5
         MOVE      D0,-4(A0,D5.W) Swap in CARSRT if Overpassing 
         MOVE      D1,-2(A0,D5.W) .
         ADDQ      #1,4(A7)
         SUBQ      #2,D7          
         BRA       CARLOP11       

* F2 CAR OVERPASSING

CARLOP22 MOVE.L    2(A1,D1),D3   Get Car Ahead Position
         ADD.L     (A7),D3       .
         SUB.L     Y2,D3         Compare F2 Position to Car Ahead
         BPL.S     CARLOP26
*         TST.B     0(A1,D1)      Overpassing F1?
*         BPL.S     CARLOP24      If PL, No
*         TST       MGAME+2         
*         BEQ.S     CARLOP23      If EQ, Arcade
*         MOVE      LAP1(PC),D3   
*         CMP       LAP2(PC),D3   Same Lap?
*         BNE.S     CARLOP24      If NE, No
*CARLOP23 SUB       #1,OVER       Say F1 Overpassed         
CARLOP24 ADDQ      #1,4(A7)
         MOVE      OVER2,D5
         LSL       #1,D5
         NEG       D5
         MOVE      D0,-4(A0,D5.W) Swap in CARSRT if overpassing
         MOVE      D1,-2(A0,D5.W) .
         ADD       #1,OVER2

* F1 OVERPASSING

TSCRHC10 MOVE.L    2(A1,D1),D3   OVERPASSING ? Car Ahead Back Position
         ADD.L     (A7),D3       .
         MOVE.L    D2,D6
         SUBI.L    #FRTCRH,D6
         CMP.L     D3,D6         Compare Positions (D3=Ya, D6=Yc)
         BLE.S     TSCRHC20      If LE, No Overpassing
         ADD.L     #FRTCRH,D3         
         MOVE.L    D3,60(A1,D0)  Save Ya+Frtcrh
         ADDQ      #1,4(A7)      Increment Overpassed Counter
         MOVE      OVER,D3
         LSL       #1,D3
         NEG       D3
         MOVE      D0,-4(A0,D3.W) Swap in CARSRT if Overpassing 
         MOVE      D1,-2(A0,D3.W) .
         TST       MGAME+2          
         BLT.S     TSCRHC20       IF LT, Qualif/Train
         BEQ.S     TSCRHC11       IF EQ, Arcade
         MOVE      10(A1,D0),D3   Racing/Demo
         CMP       10(A1,D1),D3   Same Lap?
         BNE.S     TSCRHC20       IF NE, No 
TSCRHC11 ADD       #1,OVER

* F1 Overpassing or Overpassed Display

PASS     MOVE     OVER,D0     Any Overpassing?
         BEQ      PASSF
         TST      MGAME+2     Mode?
         BLT      PASSF       If LT, Qualif/Train
         BGT.S    PASS4       If GT, Racing/Demo
         TST      D0          Arcade
         BGT.S    PASS3
PASS2    LEA.L    CAAPAS,A2
         JSR      OVMCAA      Display Car Min in Banner
         SUB.L    #500,DELSCO Update Score
         ADD      #1,OVER
         BNE.S    PASS2
         BRA.S    PASSF
PASS3    LEA.L    CAAPAS,A2
         JSR      OVPCAA      Display Car Plus in Banner
         ADD.L    #500,DELSCO Update Score
         SUB      #1,OVER
         BNE.S    PASS3
         BRA.S    PASSF
PASS4    TST      D0
         BGT.S    PASS6
PASS5    LEA.L    CAR1PAS,A2
         JSR      OVMCAR      Display Car Min in Banner
         ADD      #1,OVER
         BNE.S    PASS5
         BRA.S    PASSF
PASS6    LEA.L    CAR1PAS,A2
         JSR      OVPCAR      Display Car Plus in Banner
         SUB      #1,OVER
         BNE.S    PASS6
PASSF    CLR      OVER

* OVMCAR/OVPVAR ROUTINES

OVMCAR   MOVEQ    #0,D2       Minus
         MOVE     (A2),D2
         BEQ.S    OVMCARF
         MOVE.L   CARGREN,A4  Car Green
         LEA.L    CARPOSR,A3
         BSR      OVRCAR
         SUBQ     #1,D2
         MOVE     D2,(A2)
         MOVE.L   CARRED1,A4  Car Red1
         LEA.L    CARPOSR,A3
         BSR      OVRCAR
OVMCARF  RTS

OVPCAR   MOVEQ    #0,D2       Plus
         MOVE     (A2),D2
         CMPI     #15,D2
         BEQ.S    OVPCARF
         MOVE.L   CARGREN,A4  Car Green
         LEA.L    CARPOSR,A3
         BSR      OVRCAR         
         ADDQ     #1,D2
         ADDQ     #1,(A2)
         MOVE.L   CARRED1,A4  Car Red1
         LEA.L    CARPOSR,A3
         BSR      OVRCAR
OVPCARF  RTS

OVRCAR   MOVE     D2,D3
         LSL      #2,D3
         MOVE.L   0(A3,D3),A3
         ADDA.L   #SCR1EQU,A3       SCR1 Screen
         BSR      DSPCR            
         ADDA.L   #32000,A3         SCR2 Screen
         BSR      DSPCR
         RTS

CARERA   DC.L     ITSTEQU+29*160+88  Erase Car
CARYELL  DC.L     ITSTEQU+29*160+56  Car Blue
CARGREN  DC.L     ITSTEQU+29*160+64  Car Green
CARRED1  DC.L     ITSTEQU+29*160+72  Car Red1
CARRED2  DC.L     ITSTEQU+29*160+80  Car Red2
 
