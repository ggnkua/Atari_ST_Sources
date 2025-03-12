         TTL   ITEM3 - Car Items V10 - 05 Nov 89

         INCLUDE  "EQU.ASM"

         XDEF     CR1,CR2,CR3

* Road Dependant Item (V6)
*
*        0     DC.W  Width in Pixels
*        2     DC.W  Vertical Offset if Any (Ex: Start in Banner)
*        4     DC.W  Horizontal Offset if Any (Ex: STR in Banner)
*        6     DC.L  Item Address in Item Screen (Bottom Left)
*        10    DC.B  Width in Bytes (Multiple of 4*Words Units)
*        11    DC.B  Width in 4*Words Units
*        12    DC.W  Heigth-1 in # of Lines
*        14    DS.W  1

CR1      DC.W     1        1
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+199*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     1        2
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+199*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     1        3
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+199*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        4
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+198*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        5
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+198*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        6
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+198*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        7
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+198*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     4        8
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+197*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     4        9
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+197*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     5        10
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+199*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     5        11
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+199*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     6        12
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+196*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     6        13
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+196*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     7        14
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+197*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     7        15
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+197*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     10        16
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+78*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     10        17
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+78*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     12        18
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+82*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     12        19
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+82*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     14        20
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+86*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     14        21
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+86*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     15        22
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+91*160/4+40/4
         DC.B     16
         DC.B     2
         DC.W     4
         DS.W     1

         DC.W     15        23
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+91*160/4+40/4
         DC.B     16
         DC.B     2
         DC.W     4
         DS.W     1

         DC.W     18        24
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+96*160/4+40/4
         DC.B     16
         DC.B     2
         DC.W     4
         DS.W     1

         DC.W     20        25
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+102*160/4+40/4
         DC.B     16
         DC.B     2
         DC.W     5
         DS.W     1

         DC.W     22        26
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+110*160/4+40/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1

         DC.W     23        27
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+117*160/4+40/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1

         DC.W     26        28
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+125*160/4+32/4
         DC.B     16
         DC.B     2
         DC.W     7
         DS.W     1

         DC.W     28        29
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+133*160/4+32/4
         DC.B     16
         DC.B     2
         DC.W     7
         DS.W     1

         DC.W     29        30
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+142*160/4+32/4
         DC.B     16
         DC.B     2
         DC.W     8
         DC.W     47

         DC.W     32        31
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+152*160/4+32/4
         DC.B     24
         DC.B     3
         DC.W     9
         DC.W     47
                 
         DC.W     34        32
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+162*160/4+32/4
         DC.B     24
         DC.B     3
         DC.W     9
         DC.W     47
                 
         DC.W     39        33
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+174*160/4+32/4
         DC.B     24
         DC.B     3
         DC.W     11
         DC.W     48

         DC.W     42        34
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+186*160/4+32/4
         DC.B     24
         DC.B     3
         DC.W     11
         DC.W     48

         DC.W     45        35
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+199*160/4+32/4
         DC.B     24
         DC.B     3
         DC.W     12
         DC.W     48

         DC.W     49        36
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+194*160/4+0/4
         DC.B     32
         DC.B     4
         DC.W     13
         DC.W     49

         DC.W     51        37
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+180*160/4+0/4
         DC.B     32
         DC.B     4
         DC.W     14
         DC.W     49

         DC.W     56        38
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+165*160/4+0/4
         DC.B     32
         DC.B     4
         DC.W     15
         DC.W     49

         DC.W     60        39
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+149*160/4+0/4
         DC.B     32
         DC.B     4
         DC.W     16
         DC.W     49

         DC.W     64        40
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+132*160/4+0/4
         DC.B     32
         DC.B     4
         DC.W     17
         DC.W     50

         DC.W     69       41
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+114*160/4+0/4
         DC.B     40
         DC.B     5
         DC.W     18
         DC.W     50

         DC.W     75       42
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+95*160/4+0/4
         DC.B     40
         DC.B     5
         DC.W     20
         DC.W     50

         DC.W     81        43
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+74*160/4+0/4
         DC.B     48
         DC.B     6
         DC.W     22
         DC.W     51

         DC.W     89       44
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+51*160/4+0/4
         DC.B     48
         DC.B     6
         DC.W     24
         DC.W     51

         DC.W     95       45
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+26*160/4+0/4
         DC.B     48
         DC.B     6
         DC.W     26
         DC.W     51

         DC.W     95        46
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+26*160/4+0/4
         DC.B     48
         DC.B     6
         DC.W     26
         DC.W     51

EX1      DC.W     0        Explosion 1
         DC.W     0
         DC.W     4
         DC.L     IT4EQU+150*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     0
         DC.W     0
         DC.W     13
         DC.L     IT4EQU+150*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.W     0
         DC.W     0
         DC.W     20
         DC.L     IT4EQU+199*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.W     0
         DC.W     0
         DC.W     28
         DC.L     IT4EQU+192*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     9
         DS.W     1

         DC.W     0
         DC.W     0
         DC.W     36
         DC.L     IT4EQU+78*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     11
         DS.W     1

* Car Right

CR3
CR2      DC.W     1        1
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+84*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     1        2
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+84*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     1        3
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+84*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        4
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+85*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        5
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+85*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        6
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+85*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        7
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+85*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     4        8
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+86*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     4        9
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+86*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     5        10
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+120*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     5        11
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+120*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     6        12
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+122*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     6        13
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+122*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     7        14
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+125*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     7        15
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+125*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     10        16
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+129*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     10        17
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+129*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     11        18
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+134*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     11       19
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+134*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     14       20
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+138*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     14       21
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+138*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     15       22
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+142*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     15        23
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+142*160/4+48/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     18       24
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+199*160/4+56/4
         DC.B     16
         DC.B     2
         DC.W     4
         DS.W     1

         DC.W     20       25
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+103*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     5
         DS.W     1

         DC.W     22       26
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+117*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1

         DC.W     23       27
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+110*160/4+96/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1


         DC.W     26        28
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+125*160/4+88/4
         DC.B     16
         DC.B     2
         DC.W     7
         DS.W     1

         DC.W     28       29
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+133*160/4+88/4
         DC.B     16
         DC.B     2
         DC.W     7
         DS.W     1

         DC.W     29       30
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+142*160/4+88/4
         DC.B     16
         DC.B     2
         DC.W     8
         DC.W     47

         DC.W     32       31
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+152*160/4+88/4
         DC.B     16
         DC.B     2
         DC.W     9
         DC.W     47
                 
         DC.W     34       32
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+162*160/4+88/4
         DC.B     24
         DC.B     3
         DC.W     9
         DC.W     47
                 
         DC.W     39       33
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+174*160/4+88/4
         DC.B     24
         DC.B     3
         DC.W     11
         DC.W     48

         DC.W     42       34
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+186*160/4+88/4
         DC.B     24
         DC.B     3
         DC.W     11
         DC.W     48

         DC.W     45       35
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+199*160/4+88/4
         DC.B     24
         DC.B     3
         DC.W     12
         DC.W     48

         DC.W     49       36
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+194*160/4+56/4
         DC.B     32
         DC.B     4
         DC.W     13
         DC.W     49

         DC.W     52       37
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+180*160/4+56/4
         DC.B     32
         DC.B     4
         DC.W     14
         DC.W     49

         DC.W     56       38
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+165*160/4+56/4
         DC.B     32
         DC.B     4
         DC.W     15
         DC.W     49

         DC.W     60       39
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+149*160/4+56/4
         DC.B     32
         DC.B     4
         DC.W     16
         DC.W     49

         DC.W     64       40
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+132*160/4+56/4
         DC.B     32
         DC.B     4
         DC.W     17
         DC.W     50

         DC.W     69       41
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+114*160/4+56/4
         DC.B     40
         DC.B     5
         DC.W     18
         DC.W     50

         DC.W     75       42
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+95*160/4+56/4
         DC.B     40
         DC.B     5
         DC.W     20
         DC.W     50

         DC.W     81       43
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+74*160/4+48/4
         DC.B     48
         DC.B     6
         DC.W     22
         DC.W     51

         DC.W     89       44
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+51*160/4+48/4
         DC.B     48
         DC.B     6
         DC.W     24
         DC.W     51

         DC.W     95       45
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+26*160/4+48/4
         DC.B     48
         DC.B     6
         DC.W     26
         DC.W     51

         DC.W     95       46
         DC.W     0
         DC.W     0
         DC.L     IT4EQU+26*160/4+48/4
         DC.B     48
         DC.B     6
         DC.W     26
         DC.W     51

EX2      DC.W     0        Explosion 2
         DC.W     0
         DC.W     4
         DC.L     IT4EQU+150*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     0
         DC.W     0
         DC.W     13
         DC.L     IT4EQU+150*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.W     0
         DC.W     0
         DC.W     20
         DC.L     IT4EQU+199*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.W     0
         DC.W     0
         DC.W     28
         DC.L     IT4EQU+192*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     9
         DS.W     1

         DC.W     0
         DC.W     0
         DC.W     37
         DC.L     IT4EQU+78*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     11
         DS.W     1

         END
