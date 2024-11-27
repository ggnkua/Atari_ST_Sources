* ORIGINES AND EQUIVALENCES - V15 - 13 JUL 91

* Offsets in Display Screen (Relative to Screen page Address)

BSCREQU  EQU   160*199                 Off : Start Addr of Bot Line of Screen
HBCKEQU  EQU   17                      Heigth of Background 2
TSKYEQU  EQU   160*68                  Off : start Addr of Top Line of Sky
HBANEQU  EQU   68                      Heigth of Top Banner, Incl Black Line 
HSCPEQU  EQU   8                       Script Heigth - DM13JUL
TSCPEQU  EQU   160*191                 DM13JUL - Off : Start Adrr of Top Line of Script

* MEMORY MAP

BOTEQU   EQU   $3E800                  256000 For SID

* Screens

SCR1EQU  EQU   BOTEQU                  Screen #1 Page Address
SCR2EQU  EQU   SCR1EQU+32000           Screen #2 Page Address

* General 

JLLEQU   EQU   SCR2EQU+32000
JLLLEN   EQU   20732
JLLEN1   EQU   18054                   Length to Read
RODEQU   EQU   JLLEQU+JLLLEN
RODLEN   EQU   2000
 
* Objets Communs 

ITSTEQU  EQU   RODEQU+RODLEN           ITST Objects ST 
ITSTLEN  EQU   8320                         ST File Decomp Length
ITDVEQU  EQU   ITSTEQU+ITSTLEN         ITDV Divers Objects AMIGA (Accid, ...)
ITDVLEN  EQU   28320                        Divers File Decomp Length
ITSKEQU  EQU   ITDVEQU+ITDVLEN         ITSK Sky Items AMIGA
ITSKLEN  EQU   6240                         Sky File Decomp Length      
ITCTEQU  EQU   ITSKEQU+ITSKLEN         ITCR Car, Retro, Tiges, Tires
ITCRLEN  EQU   21280                        Cars  File Decomp Length
ITTILEN  EQU   31360                        Tires File Decomp Length
ITCTLEN  EQU   27000                        Car + Tire Length after Treatment

* Son Space

SNDEQU   EQU   ITCTEQU+ITCTLEN
SNDLEN   EQU   60000

* Workspace 

WRKEQU   EQU   SNDEQU+SNDLEN
ITSCEQU  EQU   WRKEQU                  ITSC Script  
ITSCLEN  EQU   HSCPEQU*4*160           DM13JUL = 5120
ITSLEQU  EQU   WRKEQU                  ITSL Selection 
ITSLLEN  EQU   128+22720               (22848)

* Circuit Space

BCKEQU   EQU   WRKEQU                  Background Address
BCKLEN   EQU   4*160*HBCKEQU           Bck File Length
BCKLE1   EQU   10*160*HBCKEQU          Bck Memory Length
CRCEQU   EQU   BCKEQU+BCKLE1           Circuit Data File
SKYEQU   EQU   3                       Number of Sky Events per Circuit
CRCLEN   EQU   28+SKYEQU*6+800*8+4+2+500*4+8  Length of Circuit Data File
CRCBEG   EQU   CRCEQU                  Begining of Circuit Data File
CRCSKY   EQU   CRCBEG+28               Circuit Sky Events (3*6)
CRCEVT   EQU   CRCSKY+SKYEQU*6         Circuit Topology Address
CRCLON   EQU   CRCEVT+800*8            Circuit Lap Length (4)
CRCSCA   EQU   CRCLON+4                Circuit Scale (2)
CRCDRW   EQU   CRCSCA+2                Circuit YX Address

* Table Objets Logiques 

LOGEQU   EQU   CRCEQU+CRCLEN
LOGLEN   EQU   2000

* Physical Objects Common to All Circuits

COMEQU   EQU   LOGEQU+LOGLEN

* Circuit Unique Physical Objects
* Composed of First Plan and other Objects
* are Charged at CRCOBJ address

* Demo and Erase (Will be in First Part of VR.PRG)

PRGEQU   EQU   1000000-16000  
DEMEQU   EQU   PRGEQU                  Demo
TCHAMP   EQU   DEMEQU         MODJLL
DEMLEN   EQU   16000
ER1EQU   EQU   PRGEQU-3000   MODJLL          Erase Zone 2 
ERALEN   EQU   22*8*3
ER2EQU   EQU   ER1EQU+ERALEN           Erase Zone 1 

         LIST
