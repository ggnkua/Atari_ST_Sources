         TTL   SKY Items  - Items in ITSK - V15 - 25 JUL 91

*DM25JUL

         INCLUDE  "EQU.ASM"

         XDEF   WING,STAR,LET1,LET2,LET3

         XDEF  FUJI,DESERT,MOUNT
         XDEF  ZEPLL,ZEPLR,PLANL,PLANR,BALL,TOWER
         XDEF  CLOUD1,CLOUD2,CLOUD3,CLOUD4,CLOUD5,CLOUD6

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
*        28    DC.W  Heigth-1 in # of Lines
*        30    DC.W  End of Line Position if Moving Item


Y        EQU      177

WING     DC.L     193*160           Wing of Car
         DC.L     193*160
         DS.W     1
         DC.L     165
         DC.L     165
         DS.W     2
         DC.L     ITDVEQU+(Y+5)*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     5
         DS.W     1

STAR     DC.L     18*160           Twinckling Star
         DC.L     18*160
         DS.W     1
         DC.L     0
         DC.L     0     
         DS.W     2
         DC.L     ITDVEQU+(Y+8)*160/4+32/4
         DC.B     8
         DC.B     1
         DC.W     8
         DS.W     1

LET1     DC.L     18*160           Twinckling Star 1
         DC.L     18*160
         DS.W     1
         DC.L     177
         DC.L     177   
         DS.W     2
         DC.L     ITDVEQU+(Y+8)*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     8
         DS.W     1

LET2     DC.L     18*160           Twinckling Star 2
         DC.L     18*160
         DS.W     1
         DC.L     225
         DC.L     225   
         DS.W     2
         DC.L     ITDVEQU+(Y+8)*160/4+24/4
         DC.B     8
         DC.B     1
         DC.W     8
         DS.W     1

LET3     DC.L     18*160           Twinckling Star 3
         DC.L     18*160
         DS.W     1
         DC.L     298
         DC.L     298   
         DS.W     2
         DC.L     ITDVEQU+(Y+8)*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     8
         DS.W     1

ZEPLL    DC.L     -13*160         -10  Zeppelin Left
         DC.L     -13*160         -10  Relative to top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+19)*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     10
         DS.W     1

ZEPLR    DC.L     -10*160           Zeppelin Right
         DC.L     -10*160           Relative to top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+19)*160/4+16/4
         DC.B     16
         DC.B     2
         DC.W     10
         DS.W     1

*DM25JUL
PLANL    DC.L     -10*160           Plane Left
         DC.L     -10*160           Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+9)*160/4+40/4
         DC.B     32
         DC.B     4
         DC.W     8
         DS.W     1

PLANR    DC.L     -14*160           Plane Right
         DC.L     -14*160           Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+9)*160/4+72/4
         DC.B     32
         DC.B     4
         DC.W     7
         DS.W     1
*DM25JUL

BALL     DC.L     -10*160           Balloon
         DC.L     -10*160           Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+19)*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     19
         DS.W     1

TOWER    DC.L     -1*160            Tower (UK)
         DC.L     -1*160            Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+33)*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     12
         DS.W     1

FUJI     DC.L     -1*160            Fujiyama (JAPAN)
         DC.L     -1*160            Relative to top of Back?? (117)
         DS.W     1
         DC.L     0                 Fixed
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+38)*160/4+40/4
         DC.B     40
         DC.B     5
         DC.W     15
         DS.W     1

DESERT   DC.L     -1*160            Desert Mountain (USA)
         DC.L     -1*160            Relative to top of Back?? (117)
         DS.W     1
         DC.L     0                 Fixed
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+26)*160/4+128/4
         DC.B     24
         DC.B     3
         DC.W     15       
         DS.W     1

MOUNT    DC.L     -1*160            Mountain (Autriche)
         DC.L     -1*160            Relative to top of Back?? (117)
         DS.W     1
         DC.L     0                 Fixed
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+26)*160/4+104/4
         DC.B     24
         DC.B     3
         DC.W     13
         DS.W     1

CLOUD1   DC.L     -10*160           Cloud 1
         DC.L     -10*160           Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+19)*160/4+64/4
         DC.B     32
         DC.B     4
         DC.W     $8003
         DS.W     1

CLOUD2   DC.L     -16*160           Cloud 2
         DC.L     -16*160           Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+15)*160/4+64/4
         DC.B     40
         DC.B     5
         DC.W     $8005
         DS.W     1

CLOUD3   DC.L     -10*160           Cloud 3
         DC.L     -10*160           Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+19)*160/4+32/4
         DC.B     32
         DC.B     4
         DC.W     $8009
         DS.W     1

CLOUD4   DC.L     -10*160           Cloud 4
         DC.L     -10*160           Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+38)*160/4+112/4
         DC.B     40
         DC.B     5
         DC.W     $800B
         DS.W     1

CLOUD5   DC.L     -16*160           Cloud 5
         DC.L     -16*160           Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+38)*160/4+80/4
         DC.B     32
         DC.B     4
         DC.W     $800B
         DS.W     1

CLOUD6   DC.L     -10*160           Cloud 6
         DC.L     -10*160           Relative to Top of Back?? (108)
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+(Y+37)*160/4+0/4
         DC.B     40
         DC.B     5
         DC.W     $8011
         DS.W     1

         END
