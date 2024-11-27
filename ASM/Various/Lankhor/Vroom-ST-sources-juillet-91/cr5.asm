         TTL   Circuit 5 - Japan - V15 - 13 APR 91

         INCLUDE    "EQU.ASM"

* Macros MTOP,TOP,EVT,YX
* Last MTOP/TOP Word filled by Program for Topology Events

MTOP     MACRO
         NOLIST
         DC.B  \1       Curve
         DC.B  (32*\5)!\2 Action + Bits
DIS      SET   DIS+\3
         DC.L  DIS      Y in cm
         DC.W  0        Filled by Program
CUR      SET   CUR+8
         LIST
         ENDM

YX       MACRO
         NOLIST
         DC.W  \1       Y
         DC.W  \2       X
CUR      SET   CUR+4
         LIST
         ENDM

* Events (Position on Circuit, Type,Speed, Initial Position)

SEVT
         DC.W   11,600,0        Cloud3
         DC.W   12,800,0        Cloud4
         DC.W   5,80+166,0      Fuji
         DS.W   SKYEQU-3

CUR      SET   0
DIS      SET   0

CEVT  
         MTOP   2,4,78072,0,7                 Curve R (5)      2
                                        
         MTOP   0,0,19518,0,0                 Straight (0)     3

         MTOP   7,8,31228,0,1                 Curve L (-20)    4
                                        
         MTOP   0,0,20819,0,0                 Straight (0)     5

         MTOP   6,4,13012,0,3                 Curve D (11)     6

         MTOP   0,0,33831,0,0                 Straight (0)     7

         MTOP   2,8,9108,0,7                  Curve L (-4)     8

         MTOP   0,0,13012,0,0                 Straight (0)     9

         MTOP   6,4,23421,0,3                 Curve D (20)     10

         MTOP   0,0,26024,0,0                 Straight (0)     11

         MTOP   6,4,13012,0,3                 Curve D (20)     12

         MTOP   0,0,35132,0,0                 Straight (0)

         MTOP   5,4,13012,0,3                 Curve D (16)

         MTOP   0,0,39036,0,0                 Straight (0)

         MTOP   -1,-1,67663,0,0                End of Circuit

         DS.B  800*8-CUR

* XY Coordinates on Top Circuit

CUR      SET   0
CLAP     DC.L  435900           Lap Length in cm
CSCA     DC.W  435900/335       Scale for CDRW

CDRW  

         YX    3520,58
         YX    3520,58
         YX    3520,59
         YX    3520,60
         YX    3520,60
         YX    3520,61
         YX    3520,62
         YX    3520,62
         YX    3520,63
         YX    3520,64
         YX    3520,64
         YX    3520,65
         YX    3520,66
         YX    3520,66
         YX    3520,67
         YX    3520,68
         YX    3520,68
         YX    3520,69
         YX    3520,70
         YX    3520,70
         YX    3520,71
         YX    3520,72
         YX    3520,72
         YX    3520,73
         YX    3520,74
         YX    3520,74
         YX    3520,75
         YX    3520,76
         YX    3520,76
         YX    3520,77
         YX    3520,78
         YX    3520,78
         YX    3520,79
         YX    3520,80
         YX    3520,80
         YX    3520,81
         YX    3520,82
         YX    3520,82
         YX    3520,83
         YX    3520,84
         YX    3520,84
         YX    3520,85
         YX    3520,86
         YX    3520,86
         YX    3520,87
         YX    3520,88
         YX    3520,88
         YX    3520,89
         YX    3520,90
         YX    3520,90
         YX    3520,91
         YX    3520,92
         YX    3520,92
         YX    3520,93
         YX    3520,94
         YX    3520,94
         YX    3520,95
         YX    3520,96
         YX    3520,96
         YX    3520,97
*         YX    3520,98

         YX    3520,98
         YX    3680,98
         YX    3680,99
         YX    3680,99
         YX    3840,100
         YX    3840,100
         YX    4000,101
         YX    4000,101
         YX    4160,101
         YX    4320,101
         YX    4320,101
         YX    4480,100
         YX    4480,100
         YX    4640,99
         YX    4640,99
*         YX    4640,98

         YX    4640,98
         YX    4640,97
         YX    4640,97
         YX    4640,96
         YX    4800,95
         YX    4800,95
         YX    4800,94
         YX    4800,93
         YX    4800,93
         YX    4800,92
         YX    4800,91
         YX    4800,91
         YX    4800,90
         YX    4800,89
         YX    4800,89
         YX    4960,88
         YX    4960,87
         YX    4960,87
         YX    4960,86
         YX    4960,85
         YX    4960,85
         YX    4960,84
         YX    4960,83
         YX    4960,83
*         YX    4960,82

         YX    4960,82
         YX    5120,81
         YX    5120,81
         YX    5120,80
         YX    5120,80
         YX    5120,79
         YX    5280,78
         YX    5280,78
         YX    5280,77
         YX    5440,77
         YX    5440,76
         YX    5440,76
         YX    5600,75
         YX    5600,75
         YX    5760,74
         YX    5760,74
*         YX    5920,73

         YX    5920,73
         YX    5920,73
         YX    6080,72
         YX    6080,72
         YX    6240,72
         YX    6240,71
         YX    6400,71
         YX    6560,70
         YX    6560,70
         YX    6720,70
*         YX    6720,69

         YX    6720,69
         YX    6880,69
         YX    6880,68
         YX    7040,68
         YX    7040,67
         YX    7040,67
         YX    7200,66
         YX    7200,66
         YX    7200,65
         YX    7200,64
         YX    7200,64
         YX    7200,63
         YX    7200,62
         YX    7200,62
         YX    7200,61
         YX    7200,60
         YX    7040,60
         YX    7040,59
         YX    6880,59
         YX    6880,58
         YX    6880,58
         YX    6720,57
         YX    6560,57
         YX    6560,57
         YX    6400,56
         YX    6400,56
*         YX    6240,56

         YX    6240,56
         YX    6080,56
         YX    6080,56
         YX    5920,56
         YX    5760,56
         YX    5760,56
         YX    5600,56
*         YX    5440,55

         YX    5440,55
         YX    5440,55
         YX    5280,55
         YX    5280,54
         YX    5120,54
         YX    5120,53
         YX    5120,53
         YX    5120,52
         YX    5120,51
         YX    5280,51
*         YX    5280,50

         YX    5280,50
         YX    5440,50
         YX    5600,50
         YX    5600,50
         YX    5760,49
         YX    5760,49
         YX    5920,49
         YX    6080,48
         YX    6080,48
         YX    6240,48
         YX    6240,47
         YX    6400,47
         YX    6400,47
         YX    6560,46
         YX    6720,46
         YX    6720,46
         YX    6880,45
         YX    6880,45
*         YX    7040,45

         YX    7040,45
         YX    7200,44
         YX    7200,44
         YX    7360,44
         YX    7360,43
         YX    7520,43
         YX    7520,42
         YX    7680,42
         YX    7680,41
         YX    7680,41
         YX    7840,40
         YX    7840,40
         YX    8000,39
         YX    8000,39
         YX    8000,38
         YX    8000,37
         YX    8160,37
         YX    8160,36
         YX    8160,35
         YX    8160,35
*         YX    8160,34

         YX    8160,34
         YX    8160,33
         YX    8160,33
         YX    8160,32
         YX    8160,31
         YX    8160,31
         YX    8160,30
         YX    8160,29
         YX    8160,29
         YX    8160,28
*         YX    8160,27

         YX    8160,27
         YX    8320,27
         YX    8320,26
         YX    8320,25
         YX    8160,25
         YX    8160,24
         YX    8160,23
         YX    8160,23
         YX    8160,22
         YX    8160,22
         YX    8000,21
         YX    8000,20
         YX    8000,20
         YX    7840,19
         YX    7840,19
         YX    7840,18
         YX    7680,18
         YX    7680,17
         YX    7520,17
         YX    7520,16
         YX    7360,16
         YX    7360,15
         YX    7200,15
         YX    7200,15
         YX    7040,14
         YX    6880,14
         YX    6880,14
*         YX    6720,14

         YX    6720,14
         YX    6560,13
         YX    6560,13
         YX    6400,13
         YX    6400,13
         YX    6240,13
         YX    6080,12
         YX    6080,12
         YX    5920,12
         YX    5760,12
*         YX    5760,12

         YX    5760,12
         YX    5600,11
         YX    5440,11
         YX    5440,11
         YX    5280,11
         YX    5120,11
         YX    5120,11
         YX    4960,11
         YX    4800,11
         YX    4800,12
         YX    4640,12
         YX    4640,12
         YX    4480,12
         YX    4320,13
         YX    4320,13
         YX    4160,13
         YX    4160,14
         YX    4000,14
         YX    4000,15
         YX    3840,15
         YX    3840,16
         YX    3840,16
         YX    3680,17
         YX    3680,17
         YX    3680,18
         YX    3520,19
         YX    3520,19
         YX    3520,20
         YX    3520,21
         YX    3520,21
*         YX    3520,22

         YX    3520,22
         YX    3520,23
         YX    3520,23
         YX    3520,24
         YX    3520,25
         YX    3520,25
         YX    3520,26
         YX    3520,27
         YX    3520,27
         YX    3520,28
         YX    3520,29
         YX    3520,29
         YX    3520,30
         YX    3520,31
         YX    3520,31
         YX    3520,32
         YX    3520,33
         YX    3520,33
         YX    3520,34
         YX    3520,35
         YX    3520,35
         YX    3520,36
         YX    3520,37
         YX    3520,37
         YX    3520,38
         YX    3520,39
         YX    3520,39
         YX    3520,40
         YX    3520,41
         YX    3520,41
         YX    3520,42
         YX    3520,43
         YX    3520,43
         YX    3520,44
         YX    3520,45
         YX    3520,45
         YX    3520,46
         YX    3520,47
         YX    3520,47
         YX    3520,48
         YX    3520,49
         YX    3520,49
         YX    3520,50
         YX    3520,51
         YX    3520,51
         YX    3520,52
         YX    3520,53
         YX    3520,53
         YX    3520,54
         YX    3520,55
         YX    3520,55
         YX    3520,56
*         YX    3520,57

         YX    -1,-1
         YX    -1,-1

         DS.B  500*4-CUR
CEND
         END

