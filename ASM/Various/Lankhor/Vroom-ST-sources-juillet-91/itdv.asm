         TTL   Items AMIGA DV - Items in ITDV - V15 - 24 Jun 91 

         INCLUDE  "EQU.ASM"

         XDEF  GAMOVR,NXTCRC,DEMONS,QUALIF,RACE,RACOVR,DEMOVR

         XDEF  LIGHT

         XDEF  NUMSCR

         XDEF  ACCID1,ACCID2,SMOKE,TIRE
         XDEF  TIRMAN,GAZMAN

* Item Table Entry Definition for Erasable Items (32 Bytes)
*
*        0     DC.L  Line Address Offset in Screen #1 (y)
*        4     DC.L  Line Address Offset in Screen #2 (y)
*        8     DC.L  Position in Line in Pixels on Screen #1 (x)
*        12    DC.L  Position in Line in Pixels on Screen #2 (x)
*        16    DC.L  End Position in Line (#) in Pixels (x)
*        20    DS.W  1 (Dummy)
*        22    DC.L  Item Address in Item Screen (Bottom Left)
*        26    DC.B  Width in Bytes (Multiple of 4*Words Units)
*        27    DC.B  Width in 4*Words Units
*        28    DC.W  Heigth-1 in # of Lines
*        30    DS.W  1 Dummy

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

GAMOVR   DC.W     7                 8-1 Letters

         DC.L     106*160           Screen Line Address Offset Screen #1 (G)
         DC.L     106*160           Screen Line Address Offset Screen #2
         DC.L     320               Position in Line on Screen #1 (320 to 80)
         DC.L     320               Position in Line on Screen #1 (320 to 80)
         DC.L     42                End Position in Line (in Pixels)
         DS.W     1
         DC.L     ITDVEQU+21*160/4+0/4 Number Address in Mem
         DC.B     16                Width in Bytes (Multiple of 4*W Units)
         DC.B     2                 Width in 4*Words Units
         DC.W     21                Heigth-1 in Lines
         DS.W     1                 Filler

         DC.L     106*160          (A)
         DC.L     106*160
         DC.L     320               From 320 to 69
         DC.L     320
         DC.L     69
         DS.W     1
         DC.L     ITDVEQU+21*160/4+16/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (M)
         DC.L     106*160
         DC.L     320               From 320 to 95
         DC.L     320
         DC.L     95
         DS.W     1
         DC.L     ITDVEQU+21*160/4+32/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (E)
         DC.L     106*160
         DC.L     320               From 320 to 124
         DC.L     320
         DC.L     124
         DS.W     1
         DC.L     ITDVEQU+21*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (O)
         DC.L     106*160
         DC.L     320               From 320 to 165
         DC.L     320
         DC.L     165
         DS.W     1
         DC.L     ITDVEQU+21*160/4+64/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (V)
         DC.L     106*160
         DC.L     320               From 320 to 191
         DC.L     320
         DC.L     191
         DS.W     1
         DC.L     ITDVEQU+21*160/4+80/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (E)
         DC.L     106*160
         DC.L     320               From 320 to 217
         DC.L     320
         DC.L     217
         DS.W     1
         DC.L     ITDVEQU+21*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (R)
         DC.L     106*160
         DC.L     320               From 320 to 238
         DC.L     320
         DC.L     238
         DS.W     1
         DC.L     ITDVEQU+21*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

DEMOVR   DC.W     7                 8-1 Letters

         DC.L     106*160           Screen Line Address Offset Screen #1 (D)
         DC.L     106*160           Screen Line Address Offset Screen #2
         DC.L     320               Position in Line on Screen #1 (320 to 80)
         DC.L     320               Position in Line on Screen #1 (320 to 80)
         DC.L     42                End Position in Line (in Pixels)
         DS.W     1
         DC.L     ITDVEQU+65*160/4+16/4 Number Address in Mem
         DC.B     16                Width in Bytes (Multiple of 4*W Units)
         DC.B     2                 Width in 4*Words Units
         DC.W     21                Heigth-1 in Lines
         DS.W     1                 Filler

         DC.L     106*160          (E)
         DC.L     106*160
         DC.L     320               From 320 to 69
         DC.L     320
         DC.L     69
         DS.W     1
         DC.L     ITDVEQU+21*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (M)
         DC.L     106*160
         DC.L     320               From 320 to 95
         DC.L     320
         DC.L     95
         DS.W     1
         DC.L     ITDVEQU+21*160/4+32/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (O)
         DC.L     106*160
         DC.L     320               From 320 to 124
         DC.L     320
         DC.L     124
         DS.W     1
         DC.L     ITDVEQU+21*160/4+64/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (O)
         DC.L     106*160
         DC.L     320               From 320 to 165
         DC.L     320
         DC.L     165
         DS.W     1
         DC.L     ITDVEQU+21*160/4+64/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (V)
         DC.L     106*160
         DC.L     320               From 320 to 191
         DC.L     320
         DC.L     191
         DS.W     1
         DC.L     ITDVEQU+21*160/4+80/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (E)
         DC.L     106*160
         DC.L     320               From 320 to 217
         DC.L     320
         DC.L     217
         DS.W     1
         DC.L     ITDVEQU+21*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (R)
         DC.L     106*160
         DC.L     320               From 320 to 238
         DC.L     320
         DC.L     238
         DS.W     1
         DC.L     ITDVEQU+21*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

NXTCRC   DC.W     10                11-1 Letters

         DC.L     106*160           Screen Line Address Offset Screen #1 (N)
         DC.L     106*160           Screen Line Address Offset Screen #2
         DC.L     320               Position in Line on Screen #1 (320 to 46)
         DC.L     320               Position in Line on Screen #1 (320 to 46)
         DC.L     34                End Position in Line (in Pixels)
         DS.W     1
         DC.L     ITDVEQU+21*160/4+112/4 Number Address in Mem
         DC.B     16                Width in Bytes (Multiple of 4*W Units)
         DC.B     2                 Width in 4*Words Units
         DC.W     21                Heigth-1 in Lines
         DS.W     1                 Filler

         DC.L     106*160          (E)
         DC.L     106*160
         DC.L     320               From 320 to 64
         DC.L     320
         DC.L     57
         DS.W     1
         DC.L     ITDVEQU+21*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (X)
         DC.L     106*160
         DC.L     320               From 320 to 82
         DC.L     320
         DC.L     79
         DS.W     1
         DC.L     ITDVEQU+21*160/4+128/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (T)
         DC.L     106*160
         DC.L     320               From 320 to 100
         DC.L     320
         DC.L     100
         DS.W     1
         DC.L     ITDVEQU+21*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (C)
         DC.L     106*160
         DC.L     320               From 320 to 136
         DC.L     320
         DC.L     143
         DS.W     1
         DC.L     ITDVEQU+43*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (I)
         DC.L     106*160
         DC.L     320               From 320 to 154
         DC.L     320
         DC.L     169
         DS.W     1
         DC.L     ITDVEQU+43*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     21
         DS.W     1

         DC.L     106*160          (R)
         DC.L     106*160
         DC.L     320               From 320 to 172
         DC.L     320
         DC.L     178
         DS.W     1
         DC.L     ITDVEQU+21*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (C)
         DC.L     106*160
         DC.L     320               From 320 to 192
         DC.L     320
         DC.L     200
         DS.W     1
         DC.L     ITDVEQU+43*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (U)
         DC.L     106*160
         DC.L     320               From 320 to 210
         DC.L     320
         DC.L     226
         DS.W     1
         DC.L     ITDVEQU+65*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (I)
         DC.L     106*160
         DC.L     320               From 320 to 228
         DC.L     320
         DC.L     250
         DS.W     1
         DC.L     ITDVEQU+43*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     21
         DS.W     1

         DC.L     106*160          (T)
         DC.L     106*160
         DC.L     320               From 320 to 246
         DC.L     320
         DC.L     259
         DS.W     1
         DC.L     ITDVEQU+21*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

DEMONS   DC.W     3                 4-1 Letters

         DC.L     106*160          (D)
         DC.L     106*160
         DC.L     320               From 320 to 97
         DC.L     320
         DC.L     97
         DS.W     1
         DC.L     ITDVEQU+65*160/4+16/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (E)
         DC.L     106*160
         DC.L     320               From 320 to 122
         DC.L     320
         DC.L     122
         DS.W     1
         DC.L     ITDVEQU+21*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (M)
         DC.L     106*160
         DC.L     320               From 320 to 144
         DC.L     320
         DC.L     144
         DS.W     1
         DC.L     ITDVEQU+21*160/4+32/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (O)
         DC.L     106*160
         DC.L     320               From 320 to 173
         DC.L     320
         DC.L     173
         DS.W     1
         DC.L     ITDVEQU+21*160/4+64/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

RACE     DC.W     3                4-1 Letters

         DC.L     106*160          (R)
         DC.L     106*160
         DC.L     320               From 320 to 238
         DC.L     320
         DC.L     97
         DS.W     1
         DC.L     ITDVEQU+21*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (A)
         DC.L     106*160
         DC.L     320               From 320 to 69
         DC.L     320
         DC.L     122
         DS.W     1
         DC.L     ITDVEQU+21*160/4+16/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (C)
         DC.L     106*160
         DC.L     320               From 320 to 192
         DC.L     320
         DC.L     148
         DS.W     1
         DC.L     ITDVEQU+43*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (E)
         DC.L     106*160
         DC.L     320               From 320 to 64
         DC.L     320
         DC.L     176
         DS.W     1
         DC.L     ITDVEQU+21*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

RACOVR   DC.W     7                8-1 Letter

         DC.L     106*160          (R)
         DC.L     106*160
         DC.L     320               From 320 to 238
         DC.L     320
         DC.L     46
         DS.W     1
         DC.L     ITDVEQU+21*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (A)
         DC.L     106*160
         DC.L     320               From 320 to 69
         DC.L     320
         DC.L     69
         DS.W     1
         DC.L     ITDVEQU+21*160/4+16/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (C)
         DC.L     106*160
         DC.L     320               From 320 to 192
         DC.L     320
         DC.L     95
         DS.W     1
         DC.L     ITDVEQU+43*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (E)
         DC.L     106*160
         DC.L     320               From 320 to 64
         DC.L     320
         DC.L     124
         DS.W     1
         DC.L     ITDVEQU+21*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (O)
         DC.L     106*160
         DC.L     320               From 320 to 165
         DC.L     320
         DC.L     165
         DS.W     1
         DC.L     ITDVEQU+21*160/4+64/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (V)
         DC.L     106*160
         DC.L     320               From 320 to 191
         DC.L     320
         DC.L     191
         DS.W     1
         DC.L     ITDVEQU+21*160/4+80/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (E)
         DC.L     106*160
         DC.L     320               From 320 to 217
         DC.L     320
         DC.L     217
         DS.W     1
         DC.L     ITDVEQU+21*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (R)
         DC.L     106*160
         DC.L     320               From 320 to 238
         DC.L     320
         DC.L     238
         DS.W     1
         DC.L     ITDVEQU+21*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

QUALIF   DC.W     5                6-1 lettres

         DC.L     106*160          (Q)
         DC.L     106*160
         DC.L     320               From 320 to 238
         DC.L     320
         DC.L     95
         DS.W     1
         DC.L     ITDVEQU+21*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1
                     
         DC.L     106*160          (U)
         DC.L     106*160
         DC.L     320               From 320 to 210
         DC.L     320
         DC.L     124
         DS.W     1
         DC.L     ITDVEQU+65*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (A)
         DC.L     106*160
         DC.L     320               From 320 to 69
         DC.L     320
         DC.L     144
         DS.W     1
         DC.L     ITDVEQU+21*160/4+16/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (L)
         DC.L     106*160
         DC.L     320               From 320 to 69
         DC.L     320
         DC.L     165
         DS.W     1
         DC.L     ITDVEQU+21*160/4+72/4
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     106*160          (I)
         DC.L     106*160
         DC.L     320               From 320 to 228
         DC.L     320
         DC.L     191
         DS.W     1
         DC.L     ITDVEQU+43*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     21
         DS.W     1

         DC.L     106*160          (F)
         DC.L     106*160
         DC.L     320               From 320 to 228
         DC.L     320
         DC.L     217
         DS.W     1
         DC.L     ITDVEQU+43*160/4+88/4
         DC.B     8
         DC.B     1
         DC.W     21
         DS.W     1

* LIGHTS

LIGHT
         DC.L     19*160            Red ON
         DC.L     19*160
         DS.W     1
         DC.L     113
         DC.L     113
         DS.W     2
         DC.L     ITDVEQU+31*160/4+24/4
         DC.B     8
         DC.B     1
         DC.W     9
         DS.W     1

         DC.L     19*160            Red OFF
         DC.L     19*160
         DS.W     1
         DC.L     113
         DC.L     113
         DS.W     2
         DC.L     ITDVEQU+34*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     9
         DS.W     1

         DC.L     37*160            Orange ON
         DC.L     37*160
         DS.W     1
         DC.L     113
         DC.L     113
         DS.W     2
         DC.L     ITDVEQU+44*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     9
         DS.W     1

         DC.L     37*160            Orange OFF
         DC.L     37*160
         DS.W     1
         DC.L     113
         DC.L     113
         DS.W     2
         DC.L     ITDVEQU+54*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     9
         DS.W     1

         DC.L     55*160            Green ON
         DC.L     55*160
         DS.W     1
         DC.L     113
         DC.L     113
         DS.W     2
         DC.L     ITDVEQU+64*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     9
         DS.W     1

         DC.L     55*160            Green OFF
         DC.L     55*160
         DS.W     1
         DC.L     113
         DC.L     113
         DS.W     2
         DC.L     ITDVEQU+41*160/4+24/4
         DC.B     8
         DC.B     1
         DC.W     9
         DS.W     1

NUMSCR
         DC.L     39*160            Screen Line address #1
         DC.L     39*160                                #2
         DS.W     1                Flag (Non Road)
         DC.L     0                 Position in Line in Pixels #1 (Filled)
         DC.L     0                 Position in Line           #2 (Filled)
         DS.W     2
         DC.L     ITDVEQU+26*160/4+104/4 Number Address in Mem
         DC.B     8                 Width in Bytes (Multiple of 4*W Units)
         DC.B     1                 Width in 4*Words Units
         DC.W     4                 Heigth-1 in Lines
         DS.W     1

         DC.L     39*160           (1)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+26*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160           (2)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+26*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160            (3)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+26*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160            (4)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+26*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160            (5)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+26*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160            (6)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+36*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160            (7)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+36*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160             (8)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+36*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160             (9)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+36*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160             (Space)
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+65*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160             '
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+36*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     39*160             "
         DC.L     39*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+36*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

* CRASH/JUMP/TIREMAN/GAZMAN

ACCID1
         DC.L     (174+8)*160           1=3
         DC.L     (174+8)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+81*160/4+88/4
         DC.B     8
         DC.B     1
         DC.W     15
         DS.W     1

         DC.L     (174+11)*160           2=4
         DC.L     (174+11)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+127*160/4+88/4
         DC.B     16
         DC.B     2
         DC.W     20
         DS.W     1

         DC.L     (174+16)*160           3=5
         DC.L     (174+16)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+123*160/4+64/4
         DC.B     24
         DC.B     3
         DC.W     24
         DS.W     1

         DC.L     (174+17)*160           4=6
         DC.L     (174+17)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+127*160/4+40/4
         DC.B     24
         DC.B     3
         DC.W     27
         DS.W     1

         DC.L     (174+16)*160           5=7
         DC.L     (174+16)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+98*160/4+64/4
         DC.B     24
         DC.B     3
         DC.W     30                     ** BUG 32 **
         DS.W     1

         DC.L     (174+17)*160           6=8
         DC.L     (174+17)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+99*160/4+40/4
         DC.B     24
         DC.B     3
         DC.W     33
         DS.W     1

         DC.L     (174+21)*160           7=9
         DC.L     (174+21)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+106*160/4+96/4
         DC.B     32
         DC.B     4
         DC.W     40
         DS.W     1

         DC.L     (174+21)*160           8=9
         DC.L     (174+21)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+106*160/4+96/4
         DC.B     32
         DC.B     4
         DC.W     40
         DS.W     1

         DC.L     (174+25)*160           9=10
         DC.L     (174+25)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+113*160/4+0/4
         DC.B     40
         DC.B     5
         DC.W     47
         DS.W     1

         DC.L     (174+25)*160           10=10
         DC.L     (174+25)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+111*160/4+0/4
         DC.B     40
         DC.B     5
         DC.W     45
         DS.W     1

         DC.L     (174+21)*160           11=9
         DC.L     (174+21)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+106*160/4+96/4
         DC.B     32
         DC.B     4
         DC.W     40
         DS.W     1

         DC.L     (174+21)*160           12=9
         DC.L     (174+21)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+106*160/4+96/4
         DC.B     32
         DC.B     4
         DC.W     4
         DS.W     1

         DC.L     (174+17)*160           13=8
         DC.L     (174+17)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+99*160/4+40/4
         DC.B     24
         DC.B     3
         DC.W     33
         DS.W     1

         DC.L     (174+16)*160           14=7
         DC.L     (174+16)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+98*160/4+64/4
         DC.B     24
         DC.B     3
         DC.W     32
         DS.W     1

         DC.L     (174+17)*160           15=6
         DC.L     (174+17)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+127*160/4+40/4
         DC.B     24
         DC.B     3
         DC.W     27
         DS.W     1

         DC.L     (174+16)*160           16=5  
         DC.L     (174+16)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+123*160/4+64/4
         DC.B     24
         DC.B     3
         DC.W     23
         DS.W     1

         DC.L     (174+8)*160            17=2
         DC.L     (174+8)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+127*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     15
         DS.W     1

         DC.L     (174+6)*160           18=1
         DC.L     (174+6)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+127*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     10
         DS.W     1

ACCID2
         DC.L     (174+11)*160           1
         DC.L     (174+11)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+176*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     18
         DS.W     1

         DC.L     (174+15)*160           2
         DC.L     (174+15)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+157*160/4+0/4
         DC.B     16
         DC.B     2
         DC.W     27
         DS.W     1

         DC.L     (174+18)*160           3
         DC.L     (174+18)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+176*160/4+16/4
         DC.B     24
         DC.B     3
         DC.W     35
         DS.W     1

         DC.L     (174+24)*160           4
         DC.L     (174+24)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+176*160/4+40/4
         DC.B     24
         DC.B     3
         DC.W     46
         DS.W     1

         DC.L     (174+24)*160           5
         DC.L     (174+24)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+176*160/4+64/4
         DC.B     24
         DC.B     3
         DC.W     48
         DS.W     1

         DC.L     (174+22)*160           6
         DC.L     (174+22)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+176*160/4+88/4
         DC.B     24
         DC.B     3
         DC.W     48
         DS.W     1

         DC.L     (174+20)*160           7
         DC.L     (174+20)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+176*160/4+112/4
         DC.B     24
         DC.B     3
         DC.W     48
         DS.W     1

         DC.L     (174+19)*160           8=9
         DC.L     (174+19)*160
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+176*160/4+136/4
         DC.B     24
         DC.B     3
         DC.W     44
         DS.W     1

SMOKE
         DC.L     187*160           1
         DC.L     187*160
         DS.W     1
         DC.L     111
         DC.L     111
         DS.W     2
         DC.L     ITDVEQU+125*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     10
         DS.W     1

         DC.L     187*160           2
         DC.L     187*160
         DS.W     1
         DC.L     111
         DC.L     111
         DS.W     2
         DC.L     ITDVEQU+127*160/4+32/4
         DC.B     8
         DC.B     1
         DC.W     14
         DS.W     1

         DC.L     187*160           3
         DC.L     187*160
         DS.W     1
         DC.L     111
         DC.L     111
         DS.W     2
         DC.L     ITDVEQU+127*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     16
         DS.W     1

         DC.L     187*160           4
         DC.L     187*160
         DS.W     1
         DC.L     111
         DC.L     111
         DS.W     2
         DC.L     ITDVEQU+100*160/4+88/4
         DC.B     8
         DC.B     1
         DC.W     18
         DS.W     1

         DC.L     187*160           5
         DC.L     187*160
         DS.W     1
         DC.L     111
         DC.L     111
         DS.W     2
         DC.L     ITDVEQU+127*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     20
         DS.W     1

TIRE
         DC.L     0           1
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+127*160/4+128/4
         DC.B     16
         DC.B     2
         DC.W     24
         DS.W     1

         DC.L     0           2
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+125*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     26
         DS.W     1

         DC.L     0           3
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+96*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     30
         DS.W     1

         DC.L     0           4
         DC.L     0
         DS.W     1
         DC.L     0
         DC.L     0
         DS.W     2
         DC.L     ITDVEQU+102*160/4+128/4
         DC.B     16
         DC.B     2
         DC.W     34
         DS.W     1


TIRMAN

         DC.L     199*160           Bas 1
         DC.L     199*160
         DS.W     1
         DC.L     240
         DC.L     240
         DS.W     2
         DC.L     ITDVEQU+65*160/4+80/4
         DC.B     24
         DC.B     3
         DC.W     13
         DS.W     1

         DC.L     (199-14)*160      Haut 1 
         DC.L     (199-14)*160
         DS.W     1
         DC.L     240
         DC.L     240
         DS.W     2
         DC.L     ITDVEQU+51*160/4+80/4
         DC.B     24
         DC.B     3
         DC.W     28
         DS.W     1

         DC.L     199*160           Bas 2
         DC.L     199*160
         DS.W     1
         DC.L     241
         DC.L     241
         DS.W     2
         DC.L     ITDVEQU+65*160/4+56/4
         DC.B     24
         DC.B     3
         DC.W     13
         DS.W     1

         DC.L     (199-14)*160      Haut 2
         DC.L     (199-14)*160
         DS.W     1
         DC.L     241
         DC.L     241
         DS.W     2
         DC.L     ITDVEQU+51*160/4+80/4
         DC.B     24
         DC.B     3
         DC.W     28
         DS.W     1

         DC.L     199*160           Bas 3   
         DC.L     199*160
         DS.W     1
         DC.L     250
         DC.L     250
         DS.W     2
         DC.L     ITDVEQU+65*160/4+56/4
         DC.B     24
         DC.B     3
         DC.W     13
         DS.W     1

         DC.L     (199-14)*160      Haut 3  
         DC.L     (199-14)*160
         DS.W     1
         DC.L     250
         DC.L     250
         DS.W     2
         DC.L     ITDVEQU+51*160/4+80/4
         DC.B     24
         DC.B     3
         DC.W     28
         DS.W     1

         DC.L     199*160           Pneu    
         DC.L     199*160
         DS.W     1
         DC.L     221
         DC.L     221
         DS.W     2
         DC.L     ITDVEQU+65*160/4+128/4
         DC.B     24
         DC.B     3
         DC.W     26
         DS.W     1

GAZMAN

         DC.L     199*160           Bas 1
         DC.L     199*160
         DS.W     1
         DC.L     241
         DC.L     241
         DS.W     2
         DC.L     ITDVEQU+43*160/4+32/4
         DC.B     24
         DC.B     3
         DC.W     20
         DS.W     1

         DC.L     (199-21)*160      Haut 1
         DC.L     (199-21)*160
         DS.W     1
         DC.L     236
         DC.L     236
         DS.W     2
         DC.L     ITDVEQU+49*160/4+56/4 
         DC.B     24
         DC.B     3
         DC.W     27
         DS.W     1

         DC.L     (199-9)*160        Gun
         DC.L     (199-9)*160
         DS.W     1
         DC.L     211
         DC.L     211
         DS.W     2
         DC.L     ITDVEQU+65*160/4+104/4 
         DC.B     16
         DC.B     2
         DC.W     21
         DS.W     1

         DC.L     (199-23)*160       Drop 1   
         DC.L     (199-23)*160
         DS.W     1
         DC.L     211
         DC.L     211
         DS.W     2
         DC.L     ITDVEQU+53*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     (199-13)*160        Drop 2 
         DC.L     (199-13)*160
         DS.W     1
         DC.L     211
         DC.L     211
         DS.W     2
         DC.L     ITDVEQU+53*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.L     199*160           Bas 2
         DC.L     199*160
         DS.W     1
         DC.L     239
         DC.L     239
         DS.W     2
         DC.L     ITDVEQU+65*160/4+32/4
         DC.B     24
         DC.B     3
         DC.W     20
         DS.W     1

         DC.L     (199-21)*160      Haut 2
         DC.L     (199-21)*160
         DS.W     1
         DC.L     234
         DC.L     234
         DS.W     2
         DC.L     ITDVEQU+49*160/4+56/4
         DC.B     24
         DC.B     3
         DC.W     27
         DS.W     1

         END
