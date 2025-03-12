         TTL   Circuit 2 - France - V15 - 15 APR 91

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
         DC.W   9,700,0         Cloud1
         DC.W   10,800,0        Cloud2
         DC.W   4,80+90,0       Ball

CUR      SET   0
DIS      SET   0

CEVT
         MTOP   5,8,36764,0,3                 Curve L (-20)
                                        
         MTOP   5,4,10504,0,3                 Curve D (20)

         MTOP   5,8,10505,0,3                 Curve L (-20)
                                        
         MTOP   5,4,10505,0,3                 Curve D (20)

         MTOP   4,4,10505,0,3                 Curve D (9)

         MTOP   3,8,9453,0,7                  Curve L (-7)

         MTOP   0,0,8403,0,0                  Straight (0)

         MTOP   3,4,8403,0,7                  Curve D (7)

         MTOP   0,0,24159,0,0                 Straight (0)

         MTOP   5,8,35714,0,0                 Curve L (-20)

         MTOP   0,0,12605,0,0                 Straight (0)

         MTOP   4,4,68277,0,7                 Curve D (10)

         MTOP   0,0,12605,0,0                 Straight (0)

         MTOP   4,4,30462,0,7                 Curve D (8)

         MTOP   0,0,30462,0,0                 Straight (0)

         MTOP   3,8,18907,0,7                 Curve L (-7)

         MTOP   4,4,22059,0,7                 Curve D (9)
         
         MTOP   0,0,16806,0,0                 Straight (0)

         MTOP   -1,-1,4202,0,0                End of Circuit

         DS.B  800*8-CUR

* YX Coordinates in Banner

CUR      SET   0
CLAP     DC.L  381300
CSCA     DC.W  381300/363

CDRW     YX    4160,39
         YX    4320,39
         YX    4320,40
         YX    4320,40
         YX    4320,41
         YX    4320,42
         YX    4480,42
         YX    4480,43
         YX    4480,43
         YX    4480,44
         YX    4480,45
         YX    4480,45
         YX    4640,46
         YX    4640,47
         YX    4640,47
         YX    4640,48
         YX    4640,48
         YX    4800,49
         YX    4800,50
         YX    4800,50
         YX    4800,51
         YX    4800,52
         YX    4800,52
         YX    4960,53
         YX    4960,53
         YX    4960,54
         YX    4960,55
         YX    4960,55
         YX    5120,56
         YX    5120,56
         YX    5120,57
         YX    5120,58
         YX    5120,58
         YX    5120,59
         YX    5280,60
*         YX    5280,60

         YX    5280,60
         YX    5280,61
         YX    5280,61
         YX    5280,62
         YX    5280,63
         YX    5280,63
         YX    5280,64
         YX    5280,65
         YX    5280,65
         YX    5280,66
*         YX    5280,67

         YX    5280,67
         YX    5280,67
         YX    5280,68
         YX    5280,68
         YX    5280,69
         YX    5280,70
         YX    5280,70
         YX    5280,71
         YX    5280,72
         YX    5280,72
*         YX    5280,73

         YX    5280,73
         YX    5280,74
         YX    5440,74
         YX    5440,75
         YX    5440,75
         YX    5440,76
         YX    5440,77
         YX    5440,77
         YX    5440,78
         YX    5440,79
*         YX    5280,79

         YX    5280,79
         YX    5280,80
         YX    5280,81
         YX    5280,81
         YX    5280,82
         YX    5280,83
         YX    5280,83
         YX    5280,84
         YX    5280,84
         YX    5280,85
*         YX    5440,86

         YX    5440,86
         YX    5440,86
         YX    5440,87
         YX    5600,87
         YX    5600,88
         YX    5760,88
         YX    5760,89
         YX    5920,89
         YX    5920,89
*         YX    6080,89

         YX    6080,89
         YX    6240,89
         YX    6240,89
         YX    6400,89
         YX    6400,90
         YX    6560,90
         YX    6560,91
         YX    6720,91
*         YX    6720,92

         YX    6720,92
         YX    6720,92
         YX    6880,93
         YX    6880,93
         YX    6880,94
         YX    6880,95
         YX    7040,95
         YX    7040,96
*         YX    7040,96

         YX    7040,96
         YX    7200,97
         YX    7200,97
         YX    7200,98
         YX    7360,98
         YX    7360,99
         YX    7520,99
         YX    7680,99
         YX    7680,99
         YX    7840,99
         YX    8000,99
         YX    8000,99
         YX    8160,98
         YX    8160,98
         YX    8320,97
         YX    8320,97
         YX    8320,96
         YX    8480,96
         YX    8480,95
         YX    8480,94
         YX    8480,94
         YX    8480,93
         YX    8320,93
*         YX    8320,92

         YX    8320,92
         YX    8320,91
         YX    8160,91
         YX    8160,90
         YX    8160,90
         YX    8000,89
         YX    8000,89
         YX    8000,88
         YX    7840,88
         YX    7840,87
         YX    7840,87
         YX    7680,86
         YX    7680,85
         YX    7680,85
         YX    7520,84
         YX    7520,84
         YX    7520,83
         YX    7360,83
         YX    7360,82
         YX    7360,82
         YX    7200,81
         YX    7200,81
         YX    7040,80
         YX    7040,80
         YX    7040,79
         YX    6880,78
         YX    6880,78
         YX    6880,77
         YX    6720,77
         YX    6720,76
         YX    6720,76
         YX    6560,75
         YX    6560,75
         YX    6560,74
*         YX    6400,74

         YX    6400,74
         YX    6400,73
         YX    6400,72
         YX    6240,72
         YX    6240,71
         YX    6240,71
         YX    6240,70
         YX    6240,69
         YX    6080,69
         YX    6080,68
         YX    6080,67
         YX    6080,67
*         YX    6080,66

         YX    6080,66
         YX    6080,66
         YX    6080,65
         YX    6080,64
         YX    6080,64
         YX    6080,63
         YX    6080,62
         YX    6080,62
         YX    6080,61
         YX    6080,60
         YX    6080,60
         YX    6080,59
         YX    6080,58
         YX    6240,58
         YX    6240,57
         YX    6240,57
         YX    6240,56
         YX    6240,55
         YX    6240,55
         YX    6240,54
         YX    6240,53
         YX    6240,53
         YX    6240,52
         YX    6240,51
         YX    6240,51
         YX    6240,50
         YX    6240,49
         YX    6240,49
         YX    6240,48
         YX    6240,47
         YX    6240,47
         YX    6240,46
         YX    6240,46
         YX    6240,45
         YX    6240,44
         YX    6240,44
         YX    6240,43
         YX    6240,42
         YX    6240,42
         YX    6240,41
         YX    6240,40
         YX    6240,40
         YX    6240,39
         YX    6240,38
         YX    6240,38
         YX    6240,37
         YX    6240,37
         YX    6240,36
         YX    6240,35
         YX    6240,35
         YX    6240,34
         YX    6240,33
         YX    6240,33
         YX    6240,32
         YX    6240,31
         YX    6240,31
         YX    6240,30
         YX    6240,29
         YX    6240,29
         YX    6240,28
         YX    6240,27
         YX    6240,27
         YX    6240,26
         YX    6240,26
         YX    6240,25
*         YX    6400,24

         YX    6400,24
         YX    6240,24
         YX    6240,23
         YX    6240,22
         YX    6240,22
         YX    6240,21
         YX    6080,21
         YX    6080,20
         YX    6080,20
         YX    5920,19
         YX    5920,19
         YX    5760,18
*         YX    5760,18

         YX    5760,18
         YX    5600,18
         YX    5440,18
         YX    5440,17
         YX    5280,17
         YX    5280,17
         YX    5120,17
         YX    4960,16
         YX    4960,16
         YX    4800,16
         YX    4800,16
         YX    4640,15
         YX    4480,15
         YX    4480,15
         YX    4320,15
         YX    4320,14
         YX    4160,14
         YX    4000,14
         YX    4000,14
         YX    3840,13
         YX    3840,13
         YX    3680,13
         YX    3680,13
         YX    3520,12
         YX    3360,12
         YX    3360,12
         YX    3200,12
         YX    3200,11
         YX    3040,11
*         YX    2880,11

         YX    2880,11
         YX    2880,11
         YX    2720,10
         YX    2560,10
         YX    2560,10
         YX    2400,11
         YX    2400,11
         YX    2240,11
         YX    2080,11
         YX    2080,12
         YX    1920,12
         YX    1920,13
         YX    1920,13
         YX    1760,14
         YX    1760,14
         YX    1760,15
         YX    1760,16
         YX    1760,16
         YX    1760,17
         YX    1920,18
         YX    1920,18
         YX    1920,19
         YX    2080,19
         YX    2080,20
         YX    2240,20
         YX    2240,20
         YX    2400,21
         YX    2400,21
         YX    2560,21
*         YX    2720,21

         YX    2720,21
         YX    2720,21
         YX    2880,21
         YX    3040,21
         YX    3040,21
         YX    3200,20
         YX    3360,20
         YX    3360,20
         YX    3520,20
         YX    3680,20
         YX    3680,20
         YX    3840,20
         YX    3840,20
         YX    4000,20
         YX    4160,20
         YX    4160,20
         YX    4320,20
         YX    4480,20
*         YX    4480,20

         YX    4480,20
         YX    4640,20
         YX    4800,20
         YX    4800,20
         YX    4960,20
         YX    4960,21
         YX    5120,21
         YX    5120,22
         YX    5280,22
         YX    5280,23
         YX    5280,23
         YX    5280,24
         YX    5280,25
         YX    5280,25
         YX    5280,26
         YX    5280,26
         YX    5120,27
         YX    5120,27
         YX    4960,28
         YX    4960,28
         YX    4800,28
*         YX    4800,29

         YX    4800,29
         YX    4640,29
         YX    4480,29
         YX    4480,29
         YX    4320,30
         YX    4320,30
         YX    4160,31
         YX    4160,31
         YX    4160,32
         YX    4160,32
         YX    4000,33
         YX    4000,34
         YX    4000,34
         YX    4000,35
         YX    4000,36
         YX    4000,36
*         YX    4160,37

         YX    4160,37
         YX    4160,37
         YX    4160,38
         YX    4320,39
*         YX    4320,39

         YX    -1,-1
         YX    -1,-1
         DS.B  500*4-CUR

CEND

         END
