         TTL   ITSL - Items in ITSL - V15 - 20 JUL 91

*       VROOM SELECTION/ARCADE SCORE/RACING SCORE

        INCLUDE  "EQU.ASM"

         XDEF  PRFCAR,VROOM
         XDEF  STARTER,ARCADE,RACING,TRAIN,DEMON
         XDEF  NOCOMM,LOCAL,MINITEL,MODEM
         XDEF  ALL,GP1,GP2,GP3,GP4,GP5,GP6
         XDEF  LAPS1,LAPS2,LAPS3,LAPS4,LAPS5,LAPS6,LAPS7,LAPS8,LAPS9,LAPS10
         XDEF  AUTO,MANUAL,JOYS,MOUS
         XDEF  BOX,CLRBOX,FULBOX,OFFBOX

         XDEF  NUMSCO
         XDEF  BESTS,LIBEL,FST,SND,TRD,FOTH,FITH,SITH,SETH,HETH,NITH,ALPHA

         XDEF  WORLD,DRIVERS,GP,NO1,NO2,NO3,NO4,NO5,NO6,TOT,TOTAL,BEST,LAPL
         XDEF  ALPMED1,ALPMED2,NUMMED1,NUMMED2


* Road Independant Item (32)
*        0     DC.L  Line Address Offset in Screen #1 (y)
*        4     DC.L  Line Address Offset in Screen #2 (y)
*        8     DS.W  1 (Dummy)
*        10    DC.L  Position in Line in Pixels on Screen #1 (x)
*        14    DC.L  Position in Line in Pixels on Screen #2 (x)
*        18    DS.W  2 (Dummy)
*        22    DC.L  Item Address in Item Screen (Bottom Left)
*        26    DC.B  Width in Bytes (Multiple of 4*Words Units)
*        27    DC.B  Width in 4*Words Units
*        28    DC.W  Heigth-1 in # of Lines + Square Bit 
*        30    DC.W  End of Line Position if Moving Item

* SELECTION SCREEN

VROOM
         DC.L     46*160
         DC.L     46*160
         DS.W     1
         DC.L     185
         DC.L     185
         DS.W     2
         DC.L     ITSLEQU+120*160/4+0/4
         DC.B     56
         DC.B     7
         DC.W     42
         DC.W     0             Width of Panning

PRFCAR
         DC.L     50*160         First part
         DC.L     50*160
         DS.W     1
         DC.L     320
         DC.L     320
         DS.W     2
         DC.L     ITSLEQU+106*160/4+56/4
         DC.B     64
         DC.B     8
         DC.W     $801D          Square+29 - DM31JUN
         DC.W     30             End of Line Position (Panning)

         DC.L     50*160         Second Part (Flip)
         DC.L     50*160
         DS.W     1
         DC.L     320+128
         DC.L     320+128
         DS.W     2
         DC.L     ITSLEQU+106*160/4+120/4
         DC.B     16
         DC.B     2
         DC.W     $001D          29 - DM31JUN
         DC.W     30+128

         DC.L     50*160         Second Part (Flop)
         DC.L     50*160
         DS.W     1
         DC.L     320+128
         DC.L     320+128
         DS.W     2
         DC.L     ITSLEQU+106*160/4+136/4
         DC.B     16
         DC.B     2
         DC.W     $001D          29 - DM31JUN
         DC.W     30+128

HC       SET      129           Start Col
LC       SET      73            Left Col
RC       SET      185           Right Col
HL       SET      75            Start Lin
FL       SET      102           First Lin
SL       SET      121           Second Lin
TL       SET      140           Third Lin

STARTER
         DC.L     (HL-1)*160
         DC.L     (HL-1)*160
         DS.W     1
         DC.L     HC+16
         DC.L     HC+16
         DS.W     2
         DC.L     ITSLEQU+6*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
ARCADE
         DC.L     (FL-1)*160
         DC.L     (FL-1)*160
         DS.W     1
         DC.L     LC+14
         DC.L     LC+14
         DS.W     2
         DC.L     ITSLEQU+6*160/4+16/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
RACING
         DC.L     (FL-1)*160
         DC.L     (FL-1)*160
         DS.W     1
         DC.L     LC+13
         DC.L     LC+13
         DS.W     2
         DC.L     ITSLEQU+6*160/4+40/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
TRAIN
         DC.L     (FL-1)*160
         DC.L     (FL-1)*160
         DS.W     1
         DC.L     LC+17
         DC.L     LC+17
         DS.W     2
         DC.L     ITSLEQU+6*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
DEMON
         DC.L     (FL-1)*160
         DC.L     (FL-1)*160
         DS.W     1
         DC.L     LC+17
         DC.L     LC+17
         DS.W     2
         DC.L     ITSLEQU+13*160/4+112/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
NOCOMM
         DC.L     (FL-1)*160
         DC.L     (FL-1)*160
         DS.W     1
         DC.L     RC+14
         DC.L     RC+14
         DS.W     2
         DC.L     ITSLEQU+6*160/4+64/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
LOCAL
         DC.L     (FL-1)*160
         DC.L     (FL-1)*160
         DS.W     1
         DC.L     RC+16
         DC.L     RC+16
         DS.W     2
         DC.L     ITSLEQU+6*160/4+88/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
MINITEL
         DC.L     (FL-1)*160
         DC.L     (FL-1)*160
         DS.W     1
         DC.L     RC+11
         DC.L     RC+11
         DS.W     2
         DC.L     ITSLEQU+6*160/4+104/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
MODEM
         DC.L     (FL-1)*160
         DC.L     (FL-1)*160
         DS.W     1
         DC.L     RC+16
         DC.L     RC+16
         DS.W     2
         DC.L     ITSLEQU+6*160/4+128/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
ALL
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     LC+23
         DC.L     LC+23
         DS.W     2
         DC.L     ITSLEQU+13*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
GP1
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     LC+18
         DC.L     LC+18
         DS.W     2
         DC.L     ITSLEQU+13*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
GP2
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     LC+18
         DC.L     LC+18
         DS.W     2
         DC.L     ITSLEQU+13*160/4+16/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
GP3
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     LC+18
         DC.L     LC+18
         DS.W     2
         DC.L     ITSLEQU+13*160/4+32/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
GP4
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     LC+18
         DC.L     LC+18
         DS.W     2
         DC.L     ITSLEQU+13*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
GP5
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     LC+18
         DC.L     LC+18
         DS.W     2
         DC.L     ITSLEQU+13*160/4+64/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
GP6
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     LC+18
         DC.L     LC+18
         DS.W     2
         DC.L     ITSLEQU+13*160/4+80/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
LAPS1
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+18
         DC.L     RC+18
         DS.W     2
         DC.L     ITSLEQU+20*160/4+64/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
LAPS2
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+14
         DC.L     RC+14
         DS.W     2
         DC.L     ITSLEQU+20*160/4+80/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
LAPS3
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+14
         DC.L     RC+14
         DS.W     2
         DC.L     ITSLEQU+20*160/4+104/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
LAPS4
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+13
         DC.L     RC+13
         DS.W     2
         DC.L     ITSLEQU+27*160/4+0/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
LAPS5
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+14
         DC.L     RC+14
         DS.W     2
         DC.L     ITSLEQU+27*160/4+24/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
LAPS6
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+14
         DC.L     RC+14
         DS.W     2
         DC.L     ITSLEQU+27*160/4+48/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
LAPS7
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+14
         DC.L     RC+14
         DS.W     2
         DC.L     ITSLEQU+27*160/4+72/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
LAPS8
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+14
         DC.L     RC+14
         DS.W     2
         DC.L     ITSLEQU+27*160/4+96/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
LAPS9
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+14
         DC.L     RC+14
         DS.W     2
         DC.L     ITSLEQU+27*160/4+120/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
LAPS10
         DC.L     (SL-1)*160
         DC.L     (SL-1)*160
         DS.W     1
         DC.L     RC+11
         DC.L     RC+11
         DS.W     2
         DC.L     ITSLEQU+20*160/4+128/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
AUTO
         DC.L     (TL-1)*160
         DC.L     (TL-1)*160
         DS.W     1
         DC.L     RC+20
         DC.L     RC+20
         DS.W     2
         DC.L     ITSLEQU+13*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
MANUAL
         DC.L     (TL-1)*160
         DC.L     (TL-1)*160
         DS.W     1
         DC.L     RC+15
         DC.L     RC+15
         DS.W     2
         DC.L     ITSLEQU+20*160/4+0/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
JOYS
         DC.L     (TL-1)*160
         DC.L     (TL-1)*160
         DS.W     1
         DC.L     LC+8
         DC.L     LC+8
         DS.W     2
         DC.L     ITSLEQU+20*160/4+24/4
         DC.B     24
         DC.B     3
         DC.W     6
         DS.W     1
MOUS
         DC.L     (TL-1)*160
         DC.L     (TL-1)*160
         DS.W     1
         DC.L     LC+16
         DC.L     LC+16
         DS.W     2
         DC.L     ITSLEQU+20*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
BOX
         DC.L     0*160
         DC.L     0*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+45*160/4+120/4
         DC.B     32
         DC.B     4
         DC.W     10
         DS.W     1
CLRBOX
         DC.L     0*160
         DC.L     0*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+36*160/4+0/4
         DC.B     32
         DC.B     4
         DC.W     8
         DS.W     1
FULBOX
         DC.L     0*160
         DC.L     0*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+36*160/4+64/4
         DC.B     32
         DC.B     4
         DC.W     8
         DS.W     1

OFFBOX
         DC.L     0*160
         DC.L     0*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+36*160/4+32/4
         DC.B     32
         DC.B     4
         DC.W     8
         DS.W     1

* ARCADE SCORE SCREEN

NUMSCO
         DC.L     0                 Screen Line address #1 (Filled)
         DC.L     0                                     #2 (Filled)
         DS.W     1                Flag (Non Road)
         DC.L     0                 Position in Line in Pixels #1 (Filled)
         DC.L     0                 Position in Line           #2 (Filled)
         DS.W     2
         DC.L     ITSLEQU+113*160/4+56/4 Number Address in Mem
         DC.B     8                 Width in Bytes (Multiple of 4*W Units)
         DC.B     1                 Width in 4*Words Units
         DC.W     6                 Heigth-1 in Lines
         DS.W     1

         DC.L     0                 (1)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+113*160/4+64/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                 (2)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+113*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                 (3)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+113*160/4+80/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                 (4)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+113*160/4+88/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                 (5)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+113*160/4+96/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                 (6)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+113*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                 (7)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+113*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                  (8)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+113*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                  (9)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+113*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                  (Space)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+120*160/4+64/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1


BESTS
         DC.L     17*160        Best Arcade Scores
         DC.L     17*160
         DS.W     1
         DC.L     80
         DC.L     80
         DS.W     2
         DC.L     ITSLEQU+120*160/4+72/4
         DC.B     80
         DC.B     10
         DC.W     6
         DS.W     1
LIBEL
         DC.L     (10+9+18)*160 Libelles
         DC.L     (10+9+18)*160
         DS.W     1
         DC.L     46
         DC.L     46
         DS.W     2
         DC.L     ITSLEQU+141*160/4+0/4
         DC.B     120
         DC.B     15
         DC.W     6
         DS.W     1
FST
         DC.L     (30+9+16)*160 1st
         DC.L     (30+9+16)*160
         DS.W     1
         DC.L     48
         DC.L     48
         DS.W     2
         DC.L     ITSLEQU+127*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
SND
         DC.L     (50+9+14)*160  2nd
         DC.L     (50+9+14)*160
         DS.W     1
         DC.L     48
         DC.L     48
         DS.W     2
         DC.L     ITSLEQU+127*160/4+16/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
TRD
         DC.L     (70+9+12)*160  3rd
         DC.L     (70+9+12)*160
         DS.W     1
         DC.L     48
         DC.L     48
         DS.W     2
         DC.L     ITSLEQU+127*160/4+32/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
FOTH
         DC.L     (90+9+10)*160  4th
         DC.L     (90+9+10)*160
         DS.W     1
         DC.L     48
         DC.L     48
         DS.W     2
         DC.L     ITSLEQU+127*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
FITH
         DC.L     (110+9+8)*160    5th
         DC.L     (110+9+8)*160
         DS.W     1
         DC.L     48
         DC.L     48
         DS.W     2
         DC.L     ITSLEQU+127*160/4+64/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
SITH
         DC.L     (130+9+6)*160    6th
         DC.L     (130+9+6)*160
         DS.W     1
         DC.L     48
         DC.L     48
         DS.W     2
         DC.L     ITSLEQU+127*160/4+80/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
SETH
         DC.L     (150+9+4)*160    7th
         DC.L     (150+9+4)*160
         DS.W     1
         DC.L     48
         DC.L     48
         DS.W     2
         DC.L     ITSLEQU+127*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
HETH
         DC.L     (170+9+2)*160    8th
         DC.L     (170+9+2)*160
         DS.W     1
         DC.L     48
         DC.L     48
         DS.W     2
         DC.L     ITSLEQU+127*160/4+112/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1
NITH
         DC.L     (190+9)*160    9th
         DC.L     (190+9)*160
         DS.W     1
         DC.L     48
         DC.L     48
         DS.W     2
         DC.L     ITSLEQU+127*160/4+128/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1



ALPHA
         DC.L     0              A
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0              B
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0              C
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0              D
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+24/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0              E
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+32/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               F
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               G
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               H
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+56/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               I
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+64/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               J
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               K
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+80/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               L
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+88/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               M
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+96/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               N
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               O
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               P
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               Q
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               R
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               S
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               T
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+134*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               U
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+141*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               V
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+141*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               W
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+141*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0               X
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+141*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                Y
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+141*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                Z
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+127*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                Space
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+120*160/4+64/4  
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.L     0                 -
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+120*160/4+56/4 
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1



* RACING SCORE (Medium Resolution Libelles)

WORLD    DC.L     14*160
         DC.L     14*160
         DS.W     1
         DC.L     80
         DC.L     80
         DS.W     2
         DC.L     ITSLEQU+51*160/4+0/4
         DC.B     120
         DC.B     15
         DC.W     14
         DS.W     1

DRIVERS  DC.L     33*160
         DC.L     33*160
         DS.W     1
         DC.L     10
         DC.L     10
         DS.W     2
         DC.L     ITSLEQU+34*160/4+112/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1

GP       DC.L     0
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+27*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

NO1      DC.L     33*160
         DC.L     33*160
         DS.W     1
         DC.L     120
         DC.L     120
         DS.W     2
         DC.L     ITSLEQU+41*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

NO2      DC.L     33*160
         DC.L     33*160
         DS.W     1
         DC.L     200
         DC.L     200
         DS.W     2
         DC.L     ITSLEQU+34*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

NO3      DC.L     33*160
         DC.L     33*160
         DS.W     1
         DC.L     280
         DC.L     280
         DS.W     2
         DC.L     ITSLEQU+34*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

NO4      DC.L     33*160
         DC.L     33*160
         DS.W     1
         DC.L     360
         DC.L     360
         DS.W     2
         DC.L     ITSLEQU+34*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

NO5      DC.L     33*160
         DC.L     33*160
         DS.W     1
         DC.L     440
         DC.L     440
         DS.W     2
         DC.L     ITSLEQU+34*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

NO6      DC.L     33*160
         DC.L     33*160
         DS.W     1
         DC.L     520
         DC.L     520
         DS.W     2
         DC.L     ITSLEQU+48*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

TOTAL    DC.L     33*160
         DC.L     33*160
         DS.W     1
         DC.L     580
         DC.L     580
         DS.W     2
         DC.L     ITSLEQU+34*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1

TOT      DC.L     181*160
         DC.L     181*160
         DS.W     1
         DC.L     608
         DC.L     608
         DS.W     2
         DC.L     ITSLEQU+52*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

BEST     DC.L     182*160
         DC.L     182*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+20*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

LAPL     DC.L     181*160
         DC.L     181*160
         DS.W     1
         DC.L     50
         DC.L     50
         DS.W     2
         DC.L     ITSLEQU+27*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1


ALPMED1
         DC.L     0              A
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0              B
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0              C
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0              D
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+24/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0              E
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+32/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               F
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               G
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               H
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+56/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               I
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+64/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               J
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               K
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+80/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               L
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+88/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               M
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+96/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               N
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               O
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               P
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               Q
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               R
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               S
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               T
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+57*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               U
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               V
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               W
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               X
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+24/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                Y
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+32/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                Z
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                Space
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+56/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                 -
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

NUMMED1
         DC.L     0                 Screen Line address #1
         DC.L     0                                     #2
         DS.W     1                 Flag (Non Road)
         DC.L     0                 Position in Line in Pixels #1 (Filled)
         DC.L     0                 Position in Line           #2 (Filled)
         DS.W     2
         DC.L     ITSLEQU+62*160/4+64/4 Number Address in Mem
         DC.B     8                 Width in Bytes (Multiple of 4*W Units)
         DC.B     1                 Width in 4*Words Units
         DC.W     4                 Heigth-1 in Lines
         DS.W     1

         DC.L     0                (1)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                (2)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+80/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (3)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+88/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (4)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+96/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (5)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                (6)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (7)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (8)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                (9)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                Space
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+56/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                 '
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                 "
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+62*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

ALPMED2
         DC.L     0              A
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0              B
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0              C
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0              D
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+24/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0              E
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+32/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               F
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               G
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               H
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+56/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               I
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+64/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               J
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               K
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+80/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               L
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+88/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               M
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+96/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               N
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               O
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               P
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               Q
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               R
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               S
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               T
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+67*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               U
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               V
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               W
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               X
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+24/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                Y
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+32/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                Z
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                Space
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+56/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                 -
         DC.L     0
         DS.W     1                
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1


NUMMED2
         DC.L     0                 Screen Line address #1
         DC.L     0                                     #2
         DS.W     1                 Flag (Non Road)
         DC.L     0                 Position in Line in Pixels #1 (Filled)
         DC.L     0                 Position in Line           #2 (Filled)
         DS.W     2
         DC.L     ITSLEQU+72*160/4+64/4 Number Address in Mem
         DC.B     8                 Width in Bytes (Multiple of 4*W Units)
         DC.B     1                 Width in 4*Words Units
         DC.W     4                 Heigth-1 in Lines
         DS.W     1

         DC.L     0                (1)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                (2)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+80/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (3)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+88/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (4)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+96/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (5)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                (6)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (7)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0               (8)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                (9)
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                Space
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+56/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                 '
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     0                 "
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITSLEQU+72*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         END
