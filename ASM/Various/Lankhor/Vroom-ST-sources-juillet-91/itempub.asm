         TTL   Item 1 - Road Items (PB1,PB2,PB3,CVR) V10 - 05 Nov 89

         INCLUDE  "EQU.ASM"

         XDEF     PB1,PB2,PB3,CRV

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

PB1      DC.W     2
         DC.W     0                 No Vertical Offset
         DC.W     0                 No Horizontal Offset
         DC.L     IT2EQU+123*160/4+0/4  Item Address (Bottom Left)
         DC.B     8                 Width in Bytes (Multiple of 4*W Units)
         DC.B     1                 Width in 4*Words units
         DC.W     1                 Heigth-1 in # of Lines
         DS.W     1                 Single Item

         DC.W     2        2
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+123*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     2        3
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+123*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     3        4
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+121*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     3        5
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+121*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     3        6
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+121*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     4        7
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+118*160/4+0/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     5        8
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+119*160/4+8/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.W     6        9
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+120*160/4+16/4
         DC.B     8
         DC.B     1
         DC.W     5
         DS.W     1

         DC.W     7        10
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+121*160/4+24/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.W     9        11
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+121*160/4+32/4
         DC.B     8
         DC.B     1
         DC.W     7
         DS.W     1

         DC.W     10        12
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+122*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     10
         DS.W     1

         DC.W     13       13
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+123*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     13
         DS.W     1

         DC.W     15       14
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+95*160/4+56/4
         DC.B     8
         DC.B     1
         DC.W     14
         DS.W     1

         DC.W     20       15
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+17*160/4+24/4
         DC.B     16
         DC.B     2
         DC.W     17
         DS.W     1

         DC.W     22       16
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+37*160/4+24/4
         DC.B     16
         DC.B     2
         DC.W     19
         DS.W     1

         DC.W     24       17
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+124*160/4+40/4
         DC.B     16
         DC.B     2
         DC.W     21            
         DS.W     1

         DC.W     30       18
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+124*160/4+72/4
         DC.B     16
         DC.B     2
         DC.W     28
         DS.W     1
                 
         DC.W     34       19
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+34*160/4+0/4
         DC.B     24
         DC.B     3
         DC.W     34
         DS.W     1

         DC.W     40       20
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+39*160/4+40/4
         DC.B     24
         DC.B     3
         DC.W     39
         DS.W     1

         DC.W     47       21
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+47*160/4+64/4
         DC.B     24
         DC.B     3
         DC.W     47
         DS.W     1

         DC.W     58       22
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+54*160/4+88/4
         DC.B     32
         DC.B     4
         DC.W     54
         DS.W     1

         DC.W     75       23
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+76*160/4+120/4
         DC.B     40
         DC.B     5
         DC.W     76
         DS.W     1

PB2      DC.W     2                
         DC.W     0                 No Vertical Offset
         DC.W     0                 No Horizontal Offset
         DC.L     IT2EQU+118*160/4+112/4 Item Address (Bottom Left)
         DC.B     8                 Width in Bytes (Multiple of 4*W Units)
         DC.B     1                 Width in 4*Words units
         DC.W     1                 Heigth-1 in # of Lines
         DS.W     1                 Single Item

         DC.W     2       2
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+118*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     2       3
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+118*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     3       4
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+116*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     3       5
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+116*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     3       6
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+116*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     4       7
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+113*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     5       8
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+122*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.W     6       9
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+117*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     5
         DS.W     1

         DC.W     7       10
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+120*160/4+64/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.W     9       11
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+121*160/4+56/4
         DC.B     8
         DC.B     1
         DC.W     7
         DS.W     1

         DC.W     10       12
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+122*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     10
         DS.W     1

         DC.W     13      13
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+123*160/4+96/4
         DC.B     8
         DC.B     1
         DC.W     13
         DS.W     1

         DC.W     15      14
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+179*160/4+40/4
         DC.B     8
         DC.B     1
         DC.W     14
         DS.W     1

         DC.W     19      15
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+113*160/4+56/4
         DC.B     16
         DC.B     2
         DC.W     17
         DS.W     1

         DC.W     21      16
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+124*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     19
         DS.W     1

         DC.W     24      17
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+102*160/4+40/4
         DC.B     16
         DC.B     2
         DC.W     22
         DS.W     1

         DC.W     30      18
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+104*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     27
         DS.W     1

         DC.W     34      19
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+111*160/4+120/4
         DC.B     24
         DC.B     3
         DC.W     34
         DS.W     1

         DC.W     40      20
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+79*160/4+40/4
         DC.B     24
         DC.B     3
         DC.W     39
         DS.W     1

         DC.W     47      21
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+95*160/4+64/4
         DC.B     24
         DC.B     3
         DC.W     47
         DS.W     1

         DC.W     58      22
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+109*160/4+88/4
         DC.B     32
         DC.B     4
         DC.W     54
         DS.W     1

         DC.W     75      23
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+114*160/4+0/4
         DC.B     40
         DC.B     5
         DC.W     76
         DS.W     1

PB3      DC.W     2
         DC.W     0                 No Vertical Offset
         DC.W     0                 No Horizontal Offset
         DC.L     IT2EQU+171*160/4+120/4 Item Address (Bottom Left)
         DC.B     8                 Width in Bytes (Multiple of 4*W Units)
         DC.B     1                 Width in 4*Words units
         DC.W     1                 Heigth-1 in # of Lines
         DS.W     1                 Single Item

         DC.W     2       2
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+171*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     2       3
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+171*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     3       4
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+169*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     3       5
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+169*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     3       6
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+169*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     4       7
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+166*160/4+120/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     5       8
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+167*160/4+128/4
         DC.B     8
         DC.B     1
         DC.W     4
         DS.W     1

         DC.W     6       9
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+168*160/4+136/4
         DC.B     8
         DC.B     1
         DC.W     5
         DS.W     1

         DC.W     7       10
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+169*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     6
         DS.W     1

         DC.W     9       11
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+170*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     7
         DS.W     1

         DC.W     10       12
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+180*160/4+144/4
         DC.B     8
         DC.B     1
         DC.W     10
         DS.W     1

         DC.W     13      13
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+184*160/4+152/4
         DC.B     8
         DC.B     1
         DC.W     13
         DS.W     1

         DC.W     15      14
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+187*160/4+64/4
         DC.B     8
         DC.B     1
         DC.W     14
         DS.W     1

         DC.W     20      15
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+142*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     17
         DS.W     1

         DC.W     22      16
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+162*160/4+144/4
         DC.B     16
         DC.B     2
         DC.W     18
         DS.W     1

         DC.W     24      17
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+193*160/4+72/4
         DC.B     16
         DC.B     2
         DC.W     20
         DS.W     1

         DC.W     30      18
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+193*160/4+48/4
         DC.B     16
         DC.B     2
         DC.W     28
         DS.W     1
                 
         DC.W     34      19
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+159*160/4+120/4
         DC.B     24
         DC.B     3
         DC.W     34
         DS.W     1

         DC.W     40      20
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+164*160/4+40/4
         DC.B     24
         DC.B     3
         DC.W     39
         DS.W     1

         DC.W     47      21
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+172*160/4+64/4
         DC.B     24
         DC.B     3
         DC.W     47
         DS.W     1

         DC.W     58      22
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+178*160/4+88/4
         DC.B     32
         DC.B     4
         DC.W     54
         DS.W     1

         DC.W     75      23
         DC.W     0
         DC.W     0
         DC.L     IT2EQU+199*160/4+0/4
         DC.B     40
         DC.B     5
         DC.W     75
         DS.W     1

CRV      DC.W     1               
         DC.W     0                 No Vertivcal Offset
         DC.W     0                 No Horizontal Offset
         DC.L     IT6EQU+161*160/4+104/4  Item Address (Bottom Left)
         DC.B     8                 Width in Bytes (Multiple of 4*W Units)
         DC.B     1                 Width in 4*Words units
         DC.W     0                 Heigth-1 in # of Lines
         DS.W     1                 Filler

         DC.W     1        2
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+161*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     1        3
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+161*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        4
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+149*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        5
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+149*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     3        6
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+149*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     5        7
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+148*160/4+72/4
         DC.B     8
         DC.B     1
         DC.W     0
         DS.W     1

         DC.W     5        8
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+149*160/4+80/4
         DC.B     8
         DC.B     1
         DC.W     1
         DS.W     1

         DC.W     8        9
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+123*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     2
         DS.W     1

         DC.W     10        10
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+124*160/4+112/4
         DC.B     8
         DC.B     1
         DC.W     3
         DS.W     1

         DC.W     15       11
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+160*160/4+104/4
         DC.B     8
         DC.B     1
         DC.W     5
         DS.W     1

         DC.W     17       12
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+154*160/4+88/4
         DC.B     16
         DC.B     2
         DC.W     5
         DS.W     1

         DC.W     19       13
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+161*160/4+88/4
         DC.B     16
         DC.B     2
         DC.W     6
         DS.W     1

         DC.W     21       14
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+162*160/4+112/4
         DC.B     16
         DC.B     2
         DC.W     7
         DS.W     1

         DC.W     24       15
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+148*160/4+88/4
         DC.B     16
         DC.B     2
         DC.W     8
         DS.W     1

         DC.W     28       16
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+120*160/4+104/4
         DC.B     16
         DC.B     2
         DC.W     9
         DS.W     1

         DC.W     32       17
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+110*160/4+104/4
         DC.B     16
         DC.B     2
         DC.W     11
         DS.W     1

         DC.W     37       18
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+154*160/4+104/4
         DC.B     24
         DC.B     3
         DC.W     13
         DS.W     1
                 
         DC.W     43       19
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+140*160/4+104/4
         DC.B     24
         DC.B     3
         DC.W     15
         DS.W     1

         DC.W     50       20
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+165*160/4+128/4
         DC.B     32
         DC.B     4
         DC.W     18
         DS.W     1

         DC.W     56       21
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+145*160/4+128/4
         DC.B     32
         DC.B     4
         DC.W     20
         DS.W     1

         DC.W     65       22
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+124*160/4+120/4
         DC.B     40
         DC.B     5
         DC.W     23
         DS.W     1

         DC.W     75       23
         DC.W     0
         DC.W     0
         DC.L     IT6EQU+100*160/4+120/4
         DC.B     40
         DC.B     5
         DC.W     27
         DS.W     1

         END
