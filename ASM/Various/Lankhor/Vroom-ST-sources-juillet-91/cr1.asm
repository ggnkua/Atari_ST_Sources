         TTL   Circuit 1 Austria - V15 - 13 Apr 91

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

TOP      MACRO
         NOLIST
         DC.B  \1       Curve
         DC.B  (32*\5)!\2 Action + Bits
         DC.L  DIS+\3   Y in cm
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
         DC.W   8,80+272,0      Mount
         DC.W   1,0,1           Zepl2
         DC.W  -1,0,0           Dum
         DS.W   SKYEQU-3         

CUR      SET   0
DIS      SET   0

CEVT
            TOP   0,15,15000,0,0                3 Lanes 

            TOP   4,9,45000,0,0                Descente 
            TOP   4,5,46000,0,0                Montee
            TOP   4,9,48000,0,0                Descente
            TOP   4,1,49000,0,0                Plat
            TOP   0,31,90000,0,0               Back to 2 Lanes
                                             
      MTOP  5,8,98282,0,3                     Curve L (-40)

      MTOP  3,4,21060,0,7                    Curve D (10)
            TOP   4,5,10000,0,0               Up
            TOP   4,9,12000,0,0               Down
            TOP   4,5,16000,0,0               Up 
            TOP   4,1,18000,0,0               Flat       
            TOP   4,5,23000,0,0               Up
            TOP   4,9,24000,0,0               Down
            TOP   4,5,26000,0,0               Up 
            TOP   4,1,27000,0,0               Flat 
  
      MTOP  0,0,56161,0,0                    Straight (0)
            TOP   4,5,10000,0,0               Up
            TOP   4,9,11500,0,0               Down
            TOP   4,5,13000,0,0               Up 
            TOP   4,9,15500,0,0               Flat       
            TOP   4,5,18000,0,0               Up
            TOP   4,9,21500,0,0               Down
            TOP   4,1,25000,0,0               Up                                         
       
      MTOP  3,8,28080,0,7                    Curve L (-10)
            TOP   4,9,15500,0,0               Flat       
            TOP   4,5,20000,0,0               Up
            TOP   4,9,29000,0,0               Down
            TOP   4,1,33500,0,0               Up 
 
      MTOP  0,0,53353,0,0                    Straight (0)
            TOP   4,5,100,0,0                 Flat       
            TOP   4,1,7100,0,0                Up
            TOP   4,9,10100,0,0               Down
            TOP   4,5,11600,0,0               Up  
            TOP   4,9,13600,0,0               Up
         
      MTOP  4,4,14040,0,0                    Curve D (25)
            TOP   4,1,7060,0,0                Up
  
      MTOP  0,0,12636,0,0                    Straight (0)
            TOP   4,5,17000,0,0               Up
            TOP   4,9,27000,0,0               Down
            TOP   4,1,37000,0,0               Flat                          
 
      MTOP  2,4,39313,0,7                   Curve D (7)
            TOP   4,9,10000,0,0               Up
            TOP   4,5,11000,0,0               Down
            TOP   4,9,13000,0,0               Up 
            TOP   4,1,14000,0,0               Flat
         
      MTOP  0,0,26676,0,0                    Straight (0)
            TOP   4,9,10000,0,0               Up
            TOP   4,5,14000,0,0               Down
            TOP   4,9,22000,0,0               Up 
            TOP   4,1,26000,0,0               Flat
            TOP   0,11,30000,0,0              1 Lane ***********
            TOP   0,27,40000,0,0              Back to 2 Lanes **
 
      MTOP  3,4,84242,0,7                    Curve D (10)
 
      MTOP  0,0,14040,0,0                    Straight (0)
            TOP   4,5,5000,0,0                Down
            TOP   4,1,8000,0,0                Flat
            TOP   4,5,16000,0,0               Down
            TOP   4,9,22000,0,0               Up
            TOP   4,1,26000,0,0               Flat
            TOP   4,9,30000,0,0               Up
            TOP   4,1,35000,0,0               Flat
  
      MTOP  6,8,35100,0,0                    Curve L (-50)
         
      MTOP  3,4,49141,0,7                    Curve D (11)
 
      MTOP  0,0,47737,0,0                    Straight (0)
 
      MTOP  -1,-1,11239,0,0                 End of Circuit 

         DS.B  800*8-CUR

* XY Coordinates on Top Circuit


CUR      SET   0
CLAP     DC.L  591100           Lap Length in cm
CSCA     DC.W  591100/421       Scale for CDRW

CDRW     
         YX    2080,31
         YX    2240,31
         YX    2240,32
         YX    2240,32
         YX    2240,33
         YX    2240,34
         YX    2400,34
         YX    2400,35
         YX    2400,35
         YX    2400,36
         YX    2400,37
         YX    2400,37
         YX    2560,38
         YX    2560,39
         YX    2560,39
         YX    2560,40
         YX    2560,40
         YX    2720,41
         YX    2720,42
         YX    2720,42
         YX    2720,43
         YX    2720,44
         YX    2720,44
         YX    2880,45
         YX    2880,45
         YX    2880,46
         YX    2880,47
         YX    2880,47
         YX    3040,48
         YX    3040,48
         YX    3040,49
         YX    3040,50
         YX    3040,50
         YX    3040,51
         YX    3200,52
         YX    3200,52
         YX    3200,53
         YX    3200,53
         YX    3200,54
         YX    3360,55
         YX    3360,55
         YX    3360,56
         YX    3360,57
         YX    3360,57
         YX    3360,58
         YX    3520,58
         YX    3520,59
         YX    3520,60
         YX    3520,60
         YX    3520,61
         YX    3680,61
         YX    3680,62
         YX    3680,63
         YX    3680,63
         YX    3680,64
         YX    3680,65
         YX    3840,65
         YX    3840,66
         YX    3840,66
         YX    3840,67
         YX    3840,68
         YX    3840,68
         YX    4000,69
         YX    4000,70
         YX    4000,70
         YX    4000,71
         YX    4000,71
         YX    4160,72
         YX    4160,73
         YX    4160,73
*         YX    4160,74

         YX    4160,74
         YX    4160,74
         YX    4160,75
         YX    4320,76
         YX    4320,76
         YX    4320,77
         YX    4320,78
         YX    4320,78
         YX    4320,79
         YX    4320,80
         YX    4320,80
         YX    4320,81
         YX    4320,82
         YX    4320,82
*         YX    4320,83

         YX    4320,83
         YX    4320,83
         YX    4320,84
         YX    4320,85
         YX    4320,85
         YX    4480,86
         YX    4480,87
         YX    4480,87
         YX    4640,88
         YX    4640,88
         YX    4800,88
         YX    4800,89
         YX    4960,89
         YX    4960,89
         YX    5120,89
         YX    5280,90
         YX    5280,90
         YX    5440,90
         YX    5600,90
         YX    5600,89
         YX    5760,89
         YX    5760,89
         YX    5920,89
         YX    5920,88
         YX    6080,88
         YX    6080,87
         YX    6240,87
         YX    6240,86
         YX    6240,86
         YX    6400,85
         YX    6400,85
         YX    6400,84
         YX    6400,83
         YX    6400,83
         YX    6400,82
         YX    6400,81
         YX    6240,81
         YX    6240,80
         YX    6240,80
         YX    6080,79
*         YX    6080,79

         YX    6080,79
         YX    6080,78
         YX    5920,78
         YX    5920,77
         YX    5760,77
         YX    5760,76
         YX    5600,76
         YX    5600,75
         YX    5440,75
         YX    5440,75
         YX    5280,74
         YX    5280,74
         YX    5280,73
         YX    5120,73
         YX    5120,72
         YX    4960,72
         YX    4960,71
         YX    4800,71
         YX    4800,70
         YX    4640,70
*         YX    4640,70

         YX    4640,70
         YX    4480,69
         YX    4480,69
         YX    4480,68
         YX    4320,67
         YX    4320,67
         YX    4320,66
         YX    4320,66
         YX    4320,65
         YX    4320,64
         YX    4320,64
         YX    4320,63
         YX    4320,62
         YX    4480,62
         YX    4480,61
         YX    4640,61
         YX    4640,60
         YX    4640,60
         YX    4800,60
         YX    4960,59
         YX    4960,59
         YX    5120,59
         YX    5120,59
         YX    5280,59
         YX    5440,59
         YX    5440,59
         YX    5600,59
         YX    5760,59
         YX    5760,59
         YX    5920,59
         YX    5920,60
         YX    6080,60
         YX    6080,61
         YX    6240,61
         YX    6240,62
         YX    6240,62
         YX    6400,63
         YX    6400,63
*         YX    6400,64

         YX    6400,64
         YX    6400,65
         YX    6400,65
         YX    6400,66
         YX    6400,67
         YX    6400,67
         YX    6400,68
         YX    6400,69
         YX    6400,69
         YX    6560,70
*         YX    6560,71

         YX    6560,71
         YX    6560,71
         YX    6560,72
         YX    6560,72
         YX    6560,73
         YX    6560,74
         YX    6720,74
         YX    6720,75
         YX    6720,75
*         YX    6720,76

         YX    6720,76
         YX    6880,77
         YX    6880,77
         YX    6880,78
         YX    7040,78
         YX    7040,79
         YX    7040,79
         YX    7200,80
         YX    7200,81
         YX    7200,81
         YX    7200,82
         YX    7360,82
         YX    7360,83
         YX    7360,83
         YX    7520,84
         YX    7520,85
         YX    7520,85
         YX    7680,86
         YX    7680,86
         YX    7680,87
         YX    7840,87
         YX    7840,88
         YX    7840,89
         YX    7840,89
         YX    8000,90
         YX    8000,90
         YX    8000,91
         YX    8160,91
*         YX    8160,92

         YX    8160,92
         YX    8160,92
         YX    8320,93
         YX    8320,93
         YX    8480,94
         YX    8480,94
         YX    8640,94
         YX    8800,94
         YX    8800,94
         YX    8960,94
         YX    9120,94
         YX    9120,94
         YX    9280,93
         YX    9280,93
         YX    9440,93
         YX    9440,92
         YX    9440,91
         YX    9440,91
         YX    9440,90
*         YX    9440,89

         YX    9440,89
         YX    9440,89
         YX    9440,88
         YX    9440,88
         YX    9440,87
         YX    9440,86
         YX    9440,86
         YX    9440,85
         YX    9440,84
         YX    9440,84
         YX    9440,83
         YX    9440,82
         YX    9440,82
         YX    9440,81
         YX    9440,80
         YX    9440,80
         YX    9440,79
         YX    9440,79
         YX    9440,78
         YX    9440,77
         YX    9440,77
         YX    9440,76
         YX    9440,75
         YX    9440,75
         YX    9280,74
         YX    9280,73
         YX    9280,73
         YX    9280,72
         YX    9280,71
         YX    9280,71
         YX    9280,70
         YX    9280,70
         YX    9280,69
         YX    9280,68
         YX    9280,68
         YX    9280,67
         YX    9280,66
         YX    9280,66
         YX    9280,65
         YX    9280,64
         YX    9280,64
         YX    9280,63
         YX    9280,62
         YX    9280,62
         YX    9280,61
         YX    9280,61
         YX    9280,60
         YX    9120,59
         YX    9120,59
         YX    9120,58
         YX    9120,57
         YX    9120,57
         YX    9120,56
         YX    9120,55
         YX    9120,55
         YX    9120,54
         YX    9120,53
         YX    9120,53
         YX    9120,52
         YX    9120,52
*         YX    9120,51

         YX    9120,51
         YX    9120,50
         YX    9120,50
         YX    9120,49
         YX    8960,48
         YX    8960,48
         YX    8960,47
         YX    8800,47
         YX    8800,46
         YX    8640,46
*         YX    8640,46

         YX    8640,46
         YX    8480,45
         YX    8320,45
         YX    8320,45
         YX    8160,44
         YX    8160,44
         YX    8000,44
         YX    8000,43
         YX    7840,43
         YX    7840,43
         YX    7680,43
         YX    7520,42
         YX    7520,42
         YX    7360,42
         YX    7360,41
         YX    7200,41
         YX    7200,41
         YX    7040,40
         YX    6880,40
         YX    6880,40
         YX    6720,39
         YX    6720,39
         YX    6560,39
         YX    6560,38
         YX    6400,38
*         YX    6240,38

         YX    6240,38
         YX    6240,38
         YX    6080,37
         YX    6080,37
         YX    5920,37
         YX    5920,36
         YX    5760,36
         YX    5760,35
         YX    5600,35
         YX    5600,35
         YX    5440,34
         YX    5440,34
         YX    5280,33
         YX    5280,33
         YX    5120,32
         YX    5120,32
         YX    4960,31
         YX    4960,31
         YX    4960,31
         YX    4800,30
         YX    4800,30
         YX    4640,29
         YX    4640,29
         YX    4640,28
         YX    4480,27
         YX    4480,27
         YX    4480,26
         YX    4320,26
         YX    4320,25
         YX    4320,25
         YX    4160,24
         YX    4160,24
         YX    4160,23
         YX    4000,22
         YX    4000,22
*         YX    4000,21

         YX    4000,21
         YX    4000,21
         YX    3840,20
         YX    3840,19
         YX    3840,19
         YX    3680,18
         YX    3680,18
         YX    3520,18
         YX    3520,17
         YX    3360,17
         YX    3200,17
         YX    3200,17
         YX    3040,17
         YX    3040,17
         YX    2880,17
         YX    2720,17
         YX    2720,17
         YX    2560,17
         YX    2400,17
         YX    2400,18
         YX    2240,18
         YX    2240,18
         YX    2080,19
         YX    2080,19
         YX    1920,20
         YX    1920,20
         YX    1920,21
         YX    1920,21
         YX    1760,22
         YX    1760,23
         YX    1760,23
         YX    1760,24
         YX    1760,25
         YX    1760,25
*         YX    1920,26

         YX    1920,26
         YX    1920,26
         YX    1920,27
         YX    1920,28
         YX    1920,28
         YX    2080,29
         YX    2080,30
         YX    2080,30
*         YX    2080,31

         YX    -1,-1

         DS.B  500*4-CUR

CEND
         END
