         TTL   Circuit 6 UK - V15 - 13 APR 91 91

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
         DC.W   6,80+640+109,0  Tower
         DC.W   0,320,-1        Zepl1
         DC.W  -1,0,0           Dum
         DS.W   SKYEQU-3

CUR      SET   0
DIS      SET   0

CEVT
      MTOP   4,4,29677,0,7                    Curve D (20)

      MTOP   0,0,22258,0,0                    Straight (0)

      MTOP   5,8,37096,0,3                    Curve L (-20)

      MTOP   0,0,10387,0,0                    Straight (0)

      MTOP   3,4,14838,0,7                    Curve D (20)
         
      MTOP   0,0,14838,0,0                    Straight (0)
  
      MTOP   3,8,14839,0,7                    Curve L -10)
 
      MTOP   0,0,10387,0,0                    Straight (0)
         
      MTOP   3,4,69741,0,7                    Curve D (10)
 
      MTOP   0,0,23742,0,0                    Straight (0)

      MTOP   3,4,44515,0,7                    Curve D (10)
  
      MTOP   0,0,17806,0,0                    Straight (0)
         
      MTOP   4,8,40064,0,1                    Curve L (-11)

      MTOP   0,0,10387,0,0                    Straight (0)

      MTOP   3,8,40064,0,7                    Curve L (-11)

      MTOP   0,0,4451,0,0                     Straight (0)

      MTOP   2,4,2968,0,7                     Curve D (11)

      MTOP   0,0,5935,0,0                     Straight (0)

      MTOP   3,4,26710,0,3                    Curve D (11)

      MTOP   0,0,20774,0,0                    Straight (0)

      MTOP   -1,-1,16323,0,0                  End of Circuit 

         DS.B  800*8-CUR

* XY Coordinates on Top Circuit

CUR      SET   0
CLAP     DC.L  477800           Lap Length in cm
CSCA     DC.W  477800/322       Scale for CDRW

CDRW     YX    7040,24
         YX    7040,23
         YX    6880,23
         YX    6880,23
         YX    6720,22
         YX    6560,22
         YX    6560,22
         YX    6400,22
         YX    6400,21
         YX    6240,21
         YX    6080,21
         YX    6080,20
         YX    5920,20
         YX    5920,20
         YX    5760,20
         YX    5600,19
         YX    5600,19
         YX    5440,19
         YX    5440,19
         YX    5280,18
*         YX    5120,18

         YX    5120,18
         YX    5120,18
         YX    4960,18
         YX    4800,17
         YX    4800,17
         YX    4640,17
         YX    4480,18
         YX    4480,18
         YX    4320,18
         YX    4320,18
         YX    4160,19
         YX    4160,19
         YX    4000,20
         YX    4000,20
         YX    3840,21
*         YX    3840,21

         YX    3840,21
         YX    3840,22
         YX    3840,23
         YX    3840,23
         YX    3680,24
         YX    3680,25
         YX    3680,25
         YX    3680,26
         YX    3520,26
         YX    3520,27
         YX    3520,28
         YX    3520,28
         YX    3520,29
         YX    3360,30
         YX    3360,30
         YX    3360,31
         YX    3360,32
         YX    3360,32
         YX    3200,33
         YX    3200,33
         YX    3200,34
         YX    3200,35
         YX    3040,35
         YX    3040,36
         YX    3040,37
*         YX    3040,37

         YX    3040,37
         YX    3040,38
         YX    2880,38
         YX    2880,39
         YX    2720,39
         YX    2720,40
         YX    2560,40
*         YX    2560,41

         YX    2560,41
         YX    2400,41
         YX    2400,41
         YX    2240,42
         YX    2240,42
         YX    2080,42
         YX    1920,43
         YX    1920,43
         YX    1760,43
         YX    1760,44
*         YX    1600,44

         YX    1600,44
         YX    1600,45
         YX    1440,45
         YX    1440,46
         YX    1280,46
         YX    1280,47
         YX    1280,47
         YX    1280,48
         YX    1280,49
         YX    1440,49
*         YX    1440,50

         YX    1440,50
         YX    1440,50
         YX    1600,51
         YX    1600,52
         YX    1760,52
         YX    1760,53
         YX    1760,53
         YX    1920,54
         YX    1920,54
         YX    2080,55
*         YX    2080,55

         YX    2080,55
         YX    2080,56
         YX    2240,56
         YX    2240,57
         YX    2240,58
         YX    2240,58
         YX    2240,59
*         YX    2240,60

         YX    2240,60
         YX    2240,60
         YX    2240,61
         YX    2240,62
         YX    2240,62
         YX    2240,63
         YX    2240,64
         YX    2240,64
         YX    2240,65
         YX    2240,66
         YX    2240,66
         YX    2240,67
         YX    2240,68
         YX    2240,68
         YX    2240,69
         YX    2240,70
         YX    2240,70
         YX    2240,71
         YX    2240,72
         YX    2240,72
         YX    2240,73
         YX    2240,74
         YX    2240,74
         YX    2240,75
         YX    2240,76
         YX    2240,76
         YX    2240,77
         YX    2240,78
         YX    2240,78
         YX    2240,79
         YX    2240,80
         YX    2240,80
         YX    2240,81
         YX    2240,82
         YX    2240,82
         YX    2240,83
         YX    2240,84
         YX    2240,84
         YX    2240,85
         YX    2240,86
         YX    2240,86
         YX    2240,87
         YX    2240,88
         YX    2240,88
         YX    2240,89
         YX    2240,90
         YX    2240,90
*         YX    2240,91

         YX    2240,91
         YX    2240,92
         YX    2240,92
         YX    2400,93
         YX    2400,94
         YX    2400,94
         YX    2560,95
         YX    2560,95
         YX    2560,96
         YX    2720,96
         YX    2880,96
         YX    2880,97
         YX    3040,97
         YX    3040,97
         YX    3200,97
         YX    3360,97
*         YX    3360,97

         YX    3360,97
         YX    3520,97
         YX    3680,97
         YX    3680,97
         YX    3840,96
         YX    4000,96
         YX    4000,96
         YX    4160,96
         YX    4320,96
         YX    4320,96
         YX    4480,96
         YX    4640,95
         YX    4640,95
         YX    4800,95
         YX    4960,95
         YX    4960,95
         YX    5120,95
         YX    5280,95
         YX    5280,94
         YX    5440,94
         YX    5600,94
         YX    5600,94
         YX    5760,94
         YX    5760,94
         YX    5920,94
         YX    6080,94
         YX    6080,93
         YX    6240,93
         YX    6400,93
         YX    6400,93
*         YX    6560,93

         YX    6560,93
         YX    6720,93
         YX    6720,92
         YX    6880,92
         YX    6880,92
         YX    7040,91
         YX    7040,91
         YX    7200,90
         YX    7200,90
         YX    7200,89
         YX    7200,88
         YX    7200,88
*         YX    7200,87

         YX    7200,87
         YX    7200,86
         YX    7200,86
         YX    7200,85
         YX    7200,84
         YX    7200,84
         YX    7200,83
         YX    7200,82
         YX    7200,82
         YX    7040,81
         YX    7040,80
         YX    7040,80
         YX    7040,79
         YX    7040,78
         YX    7040,78
         YX    7040,77
         YX    7040,76
         YX    7040,76
         YX    7040,75
         YX    7040,74
         YX    6880,74
         YX    6880,73
         YX    6880,72
         YX    6880,72
         YX    6880,71
         YX    6880,70
         YX    6880,70
*         YX    6880,69

         YX    6880,69
         YX    6880,68
         YX    6880,68
         YX    6880,67
         YX    6880,66
         YX    6880,66
         YX    6880,65
*         YX    7040,65

         YX    7040,65
         YX    7040,64
         YX    7040,63
         YX    7040,63
         YX    7200,62
         YX    7200,62
         YX    7200,61
         YX    7360,60
         YX    7360,60
         YX    7360,59
         YX    7360,59
         YX    7520,58
         YX    7520,57
         YX    7520,57
         YX    7680,56
         YX    7680,56
         YX    7680,55
         YX    7840,54
         YX    7840,54
         YX    7840,53
         YX    7840,53
         YX    8000,52
         YX    8000,51
         YX    8000,51
         YX    8160,50
         YX    8160,50
         YX    8160,49
*         YX    8160,48

         YX    8160,49  **48**
         YX    8320,48
         YX    8320,48
*         YX    8480,48

         YX    8480,48
         YX    8640,48  
*         YX    8640,48

         YX    8640,49  **48**
         YX    8800,49  **48**
         YX    8960,48
         YX    8960,48  
*         YX    8960,47

         YX    8960,47  
         YX    8960,46
         YX    8960,46
         YX    8960,45
         YX    8960,44
         YX    8960,44
         YX    8960,43
         YX    8960,42
         YX    8960,42
         YX    8960,41
         YX    8960,40
         YX    8960,40
         YX    8960,39
         YX    8960,38
         YX    8960,38
         YX    8960,37
         YX    8960,36
         YX    8960,36
*         YX    8960,35

         YX    8960,35
         YX    8960,34
         YX    8800,34
         YX    8800,33
         YX    8800,32
         YX    8800,32
         YX    8800,31
         YX    8640,30
         YX    8640,30
         YX    8480,29
         YX    8480,29
         YX    8480,28
         YX    8320,28
         YX    8160,28
*         YX    8160,27

         YX    8160,27
         YX    8000,27
         YX    8000,27
         YX    7840,26
         YX    7840,26
         YX    7680,26
         YX    7520,25
         YX    7520,25
         YX    7360,25
         YX    7360,24
         YX    7200,24
*         YX    7040,24

         YX    -1,-1
         YX    -1,-1
         DS.B  500*4-CUR

CEND
         END
