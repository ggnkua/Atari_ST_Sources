         TTL   Circuit 3 - USA - V15 - 13 APR 91

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
         DC.W   7,80+233,0      Desert
         DC.W   3,0,2           Plan2
         DC.W  -1,0,0           Dum
         DS.W   SKYEQU-3

CUR      SET   0
DIS      SET   0

CEVT
         MTOP   4,4,37500,0,3           Curve D (9)    2
                                        
         MTOP   0,0,18000,0,0           Straight (0)   3

         MTOP   4,4,30000,0,7           Curve D (11)   4
                                        
         MTOP   3,4,21000,0,0           Curve D (7)    5

         MTOP   2,8,12000,0,7           Curve L (-6)   6

         MTOP   0,0,13500,0,0           Straight (0)   7

         MTOP   5,4,22500,0,3           Curve D (12)   8

         MTOP   0,0,15000,0,0           Straight (0)   9

         MTOP   3,4,105000,0,7          Curve D (7)    10

         MTOP   0,0,27000,0,0           Straight (0)   11

         MTOP   3,8,33000,0,7           Curve L (-7)   12
        
         MTOP   0,0,25500,0,0           Straight (0)   13

         MTOP   3,4,33000,0,7           Curve D (6)    14

         MTOP   0,0,27000,0,0           Straight (0)   15

         MTOP   3,4,60000,0,7           Curve D (6)    16

         MTOP   0,0,19500,0,0           Straight (0)   17

         MTOP   2,8,25500,0,7           Curve L (-6)   18

         MTOP   0,0,22500,0,0           Straight (0)   19

         MTOP   5,8,27000,0,1           Curve L (-7)   20

         MTOP   0,0,12000,0,0           Straight (0)   21

         MTOP   4,4,24000,0,7           Curve D (8)    22

         MTOP   0,0,18000,0,0           Straight (0)   23

         MTOP   -1,-1,12000,0,0         End of Circuit 

         DS.B  800*8-CUR


* XY Coordinates on Banner

CUR      SET   0
CLAP     DC.L  640500   
CSCA     DC.W  640500/427

CDRW     YX    8320,38
         YX    8320,37
         YX    8320,36
         YX    8320,36
         YX    8320,35
         YX    8320,34
         YX    8320,34
         YX    8320,33
         YX    8320,32
         YX    8320,32
         YX    8320,31
         YX    8160,30
         YX    8160,30
         YX    8160,29
         YX    8160,28
         YX    8160,28
         YX    8160,27
         YX    8160,26
         YX    8160,26
         YX    8160,25
         YX    8160,24
         YX    8160,24
         YX    8000,23
         YX    8000,22
         YX    8000,22
*         YX    8000,21

         YX    8000,21
         YX    8000,20
         YX    8000,20
         YX    8000,19
         YX    7840,19
         YX    7840,18
         YX    7680,18
         YX    7680,17
         YX    7520,17
         YX    7520,16
         YX    7360,16
         YX    7200,16
*         YX    7200,16

         YX    7200,16
         YX    7040,16
         YX    6880,16
         YX    6880,16
         YX    6720,16
         YX    6560,16
         YX    6560,15
         YX    6400,15
         YX    6240,15
         YX    6240,15
         YX    6080,15
         YX    5920,15
         YX    5920,15
         YX    5760,15
         YX    5600,15
         YX    5600,15
         YX    5440,15
         YX    5440,15
         YX    5280,15
         YX    5120,15
*         YX    5120,15

         YX    5120,15
         YX    4960,15
         YX    4800,15
         YX    4800,15
         YX    4640,15
         YX    4480,15
         YX    4480,15
         YX    4320,16
         YX    4160,16
         YX    4160,16
         YX    4000,17
         YX    4000,17
         YX    4000,18
         YX    3840,18
*         YX    3840,19

         YX    3840,19
         YX    3840,20
         YX    3840,20
         YX    3840,21
         YX    3840,22
         YX    3840,22
         YX    3840,23
         YX    4000,24
*         YX    4000,24

         YX    4000,24
         YX    4000,25
         YX    4160,25
         YX    4160,26
         YX    4160,26
         YX    4160,27
         YX    4160,28
         YX    4160,28
         YX    4000,29
*         YX    4000,30

         YX    4000,30
         YX    3840,30
         YX    3840,30
         YX    3840,31
         YX    3680,31
         YX    3680,32
         YX    3520,32
         YX    3520,33
         YX    3360,33
         YX    3360,34
         YX    3200,34
         YX    3200,35
         YX    3040,35
         YX    3040,36
         YX    3040,36
*         YX    2880,37

         YX    2880,37
         YX    2880,37
         YX    2720,38
         YX    2720,38
         YX    2720,39
         YX    2560,40
         YX    2560,40
         YX    2560,41
         YX    2560,42
         YX    2560,42
*         YX    2560,43

         YX    2560,43
         YX    2560,44
         YX    2560,44
         YX    2560,45
         YX    2560,46
         YX    2560,46
         YX    2560,47
         YX    2560,48
         YX    2560,48
         YX    2560,49
         YX    2720,50
         YX    2720,50
         YX    2720,51
         YX    2720,52
         YX    2720,52
         YX    2720,53
         YX    2720,54
         YX    2720,54
         YX    2720,55
         YX    2720,56
         YX    2720,56
         YX    2720,57
         YX    2720,58
         YX    2720,58
         YX    2720,59
         YX    2720,60
         YX    2720,60
         YX    2720,61
         YX    2880,62
         YX    2880,62
         YX    2880,63
         YX    2880,64
         YX    2880,64
         YX    2880,65
         YX    2880,66
         YX    2880,66
         YX    2880,67
         YX    2880,68
         YX    2880,68
         YX    2880,69
         YX    2880,70
         YX    2880,70
         YX    2880,71
         YX    2880,72
         YX    2880,72
         YX    2880,73
         YX    2880,73
         YX    3040,74
         YX    3040,75
         YX    3040,75
         YX    3040,76
         YX    3040,77
         YX    3040,77
         YX    3040,78
         YX    3040,79
         YX    3040,79
         YX    3040,80
         YX    3040,81
         YX    3040,81
         YX    3040,82
         YX    3040,83
         YX    3040,83
         YX    3040,84
         YX    3040,85
         YX    3040,85
         YX    3200,86
         YX    3200,87
         YX    3200,87
         YX    3200,88
         YX    3200,89
*         YX    3200,89

         YX    3200,89
         YX    3200,90
         YX    3200,91
         YX    3200,91
         YX    3360,92
         YX    3360,92
         YX    3520,93
         YX    3520,93
         YX    3680,93
         YX    3840,94
         YX    3840,94
         YX    4000,94
         YX    4160,94
         YX    4160,93
         YX    4320,93
         YX    4320,93
         YX    4480,92
         YX    4480,92
*         YX    4640,91

         YX    4640,91
         YX    4640,91
         YX    4640,90
         YX    4800,89
         YX    4800,89
         YX    4800,88
         YX    4800,88
         YX    4960,87
         YX    4960,87
         YX    4960,86
         YX    5120,85
         YX    5120,85
         YX    5120,84
         YX    5280,84
         YX    5280,83
         YX    5280,82
         YX    5440,82
         YX    5440,81
         YX    5440,81
         YX    5600,80
         YX    5600,79
         YX    5600,79
*         YX    5600,78

         YX    5600,78
         YX    5760,78
         YX    5760,77
         YX    5920,77
         YX    5920,76
         YX    6080,76
         YX    6240,76
         YX    6240,76
         YX    6400,76
         YX    6560,76
         YX    6560,76
         YX    6720,76
         YX    6720,77
         YX    6880,77
         YX    6880,78
         YX    7040,78
         YX    7040,79
*         YX    7040,79

         YX    7040,79
         YX    7040,80
         YX    7040,81
         YX    7200,81
         YX    7200,82
         YX    7200,83
         YX    7200,83
         YX    7200,84
         YX    7200,85
         YX    7200,85
         YX    7360,86
         YX    7360,87
         YX    7360,87
         YX    7360,88
         YX    7360,89
         YX    7360,89
         YX    7520,90
         YX    7520,90
         YX    7520,91
         YX    7520,92
         YX    7520,92
         YX    7520,93
*         YX    7520,94

         YX    7520,94
         YX    7680,94
         YX    7680,95
         YX    7680,95
         YX    7840,96
         YX    7840,96
         YX    8000,97
         YX    8160,97
         YX    8160,97
         YX    8320,97
         YX    8480,97
         YX    8480,96
         YX    8640,96
         YX    8640,96
         YX    8800,95
         YX    8800,94
         YX    8800,94
         YX    8800,93
*         YX    8800,93

         YX    8800,93
         YX    8800,92
         YX    8800,91
         YX    8800,91
         YX    8800,90
         YX    8800,89
         YX    8800,89
         YX    8800,88
         YX    8800,87
         YX    8800,87
         YX    8800,86
         YX    8800,85
         YX    8800,85
         YX    8800,84
         YX    8800,83
         YX    8640,83
         YX    8640,82
         YX    8640,81
         YX    8640,81
         YX    8640,80
         YX    8640,79
         YX    8640,79
         YX    8640,78
         YX    8640,77
         YX    8640,77
         YX    8640,76
         YX    8640,75
         YX    8640,75
         YX    8640,74
         YX    8640,73
         YX    8640,73
         YX    8640,72
         YX    8640,71
         YX    8480,71
         YX    8480,70
         YX    8480,69
         YX    8480,69
         YX    8480,68
         YX    8480,67
         YX    8480,67
*         YX    8480,66

         YX    8480,66
         YX    8480,65
         YX    8480,65
         YX    8320,64
         YX    8320,64
         YX    8320,63
         YX    8160,63
         YX    8000,62
         YX    8000,62
         YX    7840,62
         YX    7680,62
         YX    7680,63
         YX    7520,63
*         YX    7520,63

         YX    7520,63
         YX    7360,64
         YX    7360,64
         YX    7200,64
         YX    7040,65
         YX    7040,65
         YX    6880,66
         YX    6880,66
         YX    6720,67
         YX    6720,67
         YX    6560,67
         YX    6560,68
         YX    6400,68
         YX    6400,69
         YX    6240,69
         YX    6240,69
         YX    6080,70
*         YX    6080,70

         YX    6080,70
         YX    5920,71
         YX    5920,71
         YX    5760,71
         YX    5600,71
         YX    5600,71
         YX    5440,71
         YX    5280,71
         YX    5280,70
         YX    5120,70
         YX    5120,69
         YX    5120,69
         YX    4960,68
         YX    4960,67
         YX    4960,67
*         YX    4960,66

         YX    4960,66
         YX    5120,66
         YX    5120,65
         YX    5120,64
         YX    5120,64
         YX    5120,63
         YX    5120,62
         YX    5280,62
         YX    5280,61
         YX    5280,60
         YX    5280,60
         YX    5280,59
         YX    5280,58
         YX    5280,58
         YX    5440,57
         YX    5440,56
         YX    5440,56
         YX    5440,55
*         YX    5440,55

         YX    5440,55
         YX    5600,54
         YX    5600,53
         YX    5600,53
         YX    5760,52
         YX    5760,52
         YX    5920,52
         YX    5920,51
*         YX    6080,51

         YX    6080,51
         YX    6240,51
         YX    6240,51
         YX    6400,51
         YX    6560,51
         YX    6560,51
         YX    6720,50
         YX    6880,50
         YX    6880,50
         YX    7040,50
         YX    7200,50
         YX    7200,50
         YX    7360,50
         YX    7520,50
         YX    7520,49
         YX    7680,49
*         YX    7840,49

         YX    7840,49
         YX    7840,49
         YX    8000,49
         YX    8000,49
         YX    8160,48
         YX    8160,48
         YX    8320,47
         YX    8320,47
         YX    8320,46
         YX    8480,45
         YX    8480,45
         YX    8480,44
*         YX    8480,43

         YX    8480,43
         YX    8480,43
         YX    8480,42
         YX    8480,41
         YX    8480,41
         YX    8480,40
         YX    8320,39
         YX    8320,39
*         YX    8320,38

         YX    -1,-1
         YX    -1,-1
         DS.B  500*4-CUR
CEND
         END
