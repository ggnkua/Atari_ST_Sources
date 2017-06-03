; This file contains objects and is seperated to keep "objects.q" smaller.

x****************************************************************************
* BASISOBJEKTE Teil 2 (um das andere File etwas kleiner zu halten.)         *
* Hier finden sich NUR die Rohdaten, die Pointer und defines sind im        *
* "objects.q"-File zu treffen (ohne Drinks...)                              *
*****************************************************************************

bigsphere:    DC.W      98,88
              DC.L      bigsphere_punkte
              DS.L      98,0
              DC.W      0,2,3,0,8,9,1,0,30,30,30,30
              DC.W      0,3,3,1,9,10,2,1,30,30,30,30
              DC.W      0,2,3,2,10,11,3,2,30,30,30,30
              DC.W      0,3,3,3,11,12,4,3,30,30,30,30
              DC.W      0,2,3,4,12,13,5,4,30,30,30,30
              DC.W      0,3,2,13,6,5,13,30,30,30
              DC.W      0,3,2,8,0,7,8,30,30,30
              DC.W      0,3,3,8,14,15,9,8,30,30,30,30
              DC.W      0,2,3,9,15,16,10,9,30,30,30,30
              DC.W      0,3,3,10,16,17,11,10,30,30,30,30
              DC.W      0,2,3,11,17,18,12,11,30,30,30,30
              DC.W      0,3,3,12,18,19,13,12,30,30,30,30
              DC.W      0,2,2,19,6,13,19,30,30,30
              DC.W      0,2,2,14,8,7,14,30,30,30
              DC.W      0,2,3,14,20,21,15,14,30,30,30,30
              DC.W      0,3,3,15,21,22,16,15,30,30,30,30
              DC.W      0,2,3,16,22,23,17,16,30,30,30,30
              DC.W      0,3,3,17,23,24,18,17,30,30,30,30
              DC.W      0,2,3,18,24,25,19,18,30,30,30,30
              DC.W      0,3,2,25,6,19,25,30,30,30
              DC.W      0,3,2,20,14,7,20,30,30,30
              DC.W      0,3,3,20,26,27,21,20,30,30,30,30
              DC.W      0,2,3,21,27,28,22,21,30,30,30,30
              DC.W      0,3,3,22,28,29,23,22,30,30,30,30
              DC.W      0,2,3,23,29,30,24,23,30,30,30,30
              DC.W      0,3,3,24,30,31,25,24,30,30,30,30
              DC.W      0,2,2,31,6,25,31,30,30,30
              DC.W      0,2,2,26,20,7,26,30,30,30
              DC.W      0,2,3,26,32,33,27,26,30,30,30,30
              DC.W      0,3,3,27,33,34,28,27,30,30,30,30
              DC.W      0,2,3,28,34,35,29,28,30,30,30,30
              DC.W      0,3,3,29,35,36,30,29,30,30,30,30
              DC.W      0,2,3,30,36,37,31,30,30,30,30,30
              DC.W      0,3,2,37,6,31,37,30,30,30
              DC.W      0,3,2,32,26,7,32,30,30,30
              DC.W      0,3,3,32,38,39,33,32,30,30,30,30
              DC.W      0,2,3,33,39,40,34,33,30,30,30,30
              DC.W      0,3,3,34,40,41,35,34,30,30,30,30
              DC.W      0,2,3,35,41,42,36,35,30,30,30,30
              DC.W      0,3,3,36,42,43,37,36,30,30,30,30
              DC.W      0,2,2,43,6,37,43,30,30,30
              DC.W      0,2,2,38,32,7,38,30,30,30
              DC.W      0,2,3,38,44,45,39,38,30,30,30,30
              DC.W      0,3,3,39,45,46,40,39,30,30,30,30
              DC.W      0,2,3,40,46,47,41,40,30,30,30,30
              DC.W      0,3,3,41,47,48,42,41,30,30,30,30
              DC.W      0,2,3,42,48,49,43,42,30,30,30,30
              DC.W      0,3,2,49,6,43,49,30,30,30
              DC.W      0,3,2,44,38,7,44,30,30,30
              DC.W      0,3,3,44,50,51,45,44,30,30,30,30
              DC.W      0,2,3,45,51,52,46,45,30,30,30,30
              DC.W      0,3,3,46,52,53,47,46,30,30,30,30
              DC.W      0,2,3,47,53,54,48,47,30,30,30,30
              DC.W      0,3,3,48,54,55,49,48,30,30,30,30
              DC.W      0,2,2,55,6,49,55,30,30,30
              DC.W      0,2,2,50,44,7,50,30,30,30
              DC.W      0,2,3,50,56,57,51,50,30,30,30,30
              DC.W      0,3,3,51,57,58,52,51,30,30,30,30
              DC.W      0,2,3,52,58,59,53,52,30,30,30,30
              DC.W      0,3,3,53,59,60,54,53,30,30,30,30
              DC.W      0,2,3,54,60,61,55,54,30,30,30,30
              DC.W      0,3,2,61,6,55,61,30,30,30
              DC.W      0,3,2,56,50,7,56,30,30,30
              DC.W      0,3,3,56,62,63,57,56,30,30,30,30
              DC.W      0,2,3,57,63,64,58,57,30,30,30,30
              DC.W      0,3,3,58,64,65,59,58,30,30,30,30
              DC.W      0,2,3,59,65,66,60,59,30,30,30,30
              DC.W      0,3,3,60,66,67,61,60,30,30,30,30
              DC.W      0,2,2,67,6,61,67,30,30,30
              DC.W      0,2,2,62,56,7,62,30,30,30
              DC.W      0,2,3,62,68,69,63,62,30,30,30,30
              DC.W      0,3,3,63,69,70,64,63,30,30,30,30
              DC.W      0,2,3,64,70,71,65,64,30,30,30,30
              DC.W      0,3,3,65,71,72,66,65,30,30,30,30
              DC.W      0,2,3,66,72,73,67,66,30,30,30,30
              DC.W      0,3,2,73,6,67,73,30,30,30
              DC.W      0,3,2,68,62,7,68,30,30,30
              DC.W      0,3,3,68,74,75,69,68,30,30,30,30
              DC.W      0,2,3,69,75,76,70,69,30,30,30,30
              DC.W      0,3,3,70,76,77,71,70,30,30,30,30
              DC.W      0,2,3,71,77,78,72,71,30,30,30,30
              DC.W      0,3,3,72,78,79,73,72,30,30,30,30
              DC.W      0,2,2,79,6,73,79,30,30,30
              DC.W      0,2,2,74,68,7,74,30,30,30
              DC.W      0,2,3,74,80,81,75,74,30,30,30,30
              DC.W      0,3,3,75,81,82,76,75,30,30,30,30
              DC.W      0,2,3,76,82,83,77,76,30,30,30,30
              DC.W      0,3,3,77,83,84,78,77,30,30,30,30
              DC.W      0,2,3,78,84,85,79,78,30,30,30,30
              DC.W      0,3,2,85,6,79,85,30,30,30
              DC.W      0,3,2,80,74,7,80,30,30,30
              DC.W      0,3,3,80,0,1,81,80,30,30,30,30
              DC.W      0,2,3,81,1,2,82,81,30,30,30,30
              DC.W      0,3,3,82,2,3,83,82,30,30,30,30
              DC.W      0,2,3,83,3,4,84,83,30,30,30,30
              DC.W      0,3,3,84,4,5,85,84,30,30,30,30
              DC.W      0,2,2,5,6,85,5,30,30,30
              DC.W      0,2,2,0,80,7,0,30,30,30

SC_bigsphere  EQU       40
bigsphere_punkte:
              DS.W      8
              DC.W      1747/SC_bigsphere,0/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      3155/SC_bigsphere,0/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      3940/SC_bigsphere,0/SC_bigsphere,895/SC_bigsphere,0
              DC.W      3940/SC_bigsphere,0/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      3155/SC_bigsphere,0/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      1747/SC_bigsphere,0/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      0/SC_bigsphere,0/SC_bigsphere,-4046/SC_bigsphere,0
              DC.W      0/SC_bigsphere,0/SC_bigsphere,4046/SC_bigsphere,0
              DC.W      1569/SC_bigsphere,750/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      2839/SC_bigsphere,1366/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      3542/SC_bigsphere,1705/SC_bigsphere,895/SC_bigsphere,0
              DC.W      3542/SC_bigsphere,1705/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      2839/SC_bigsphere,1366/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      1569/SC_bigsphere,750/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      1081/SC_bigsphere,1357/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      1964/SC_bigsphere,2458/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      2451/SC_bigsphere,3074/SC_bigsphere,895/SC_bigsphere,0
              DC.W      2451/SC_bigsphere,3074/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      1964/SC_bigsphere,2458/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      1081/SC_bigsphere,1357/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      387/SC_bigsphere,1697/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      692/SC_bigsphere,3074/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      872/SC_bigsphere,3834/SC_bigsphere,895/SC_bigsphere,0
              DC.W      872/SC_bigsphere,3834/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      692/SC_bigsphere,3074/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      387/SC_bigsphere,1697/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      -387/SC_bigsphere,1697/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      -692/SC_bigsphere,3074/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      -872/SC_bigsphere,3834/SC_bigsphere,895/SC_bigsphere,0
              DC.W      -872/SC_bigsphere,3834/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      -692/SC_bigsphere,3074/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      -387/SC_bigsphere,1697/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      -1081/SC_bigsphere,1357/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      -1964/SC_bigsphere,2458/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      -2451/SC_bigsphere,3074/SC_bigsphere,895/SC_bigsphere,0
              DC.W      -2451/SC_bigsphere,3074/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      -1964/SC_bigsphere,2458/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      -1081/SC_bigsphere,1357/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      -1569/SC_bigsphere,750/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      -2839/SC_bigsphere,1366/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      -3542/SC_bigsphere,1705/SC_bigsphere,895/SC_bigsphere,0
              DC.W      -3542/SC_bigsphere,1705/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      -2839/SC_bigsphere,1366/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      -1569/SC_bigsphere,750/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      -1747/SC_bigsphere,0/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      -3155/SC_bigsphere,0/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      -3940/SC_bigsphere,0/SC_bigsphere,895/SC_bigsphere,0
              DC.W      -3940/SC_bigsphere,0/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      -3155/SC_bigsphere,0/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      -1747/SC_bigsphere,0/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      -1569/SC_bigsphere,-750/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      -2839/SC_bigsphere,-1366/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      -3542/SC_bigsphere,-1705/SC_bigsphere,895/SC_bigsphere,0
              DC.W      -3542/SC_bigsphere,-1705/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      -2839/SC_bigsphere,-1366/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      -1569/SC_bigsphere,-750/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      -1081/SC_bigsphere,-1357/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      -1964/SC_bigsphere,-2458/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      -2451/SC_bigsphere,-3074/SC_bigsphere,895/SC_bigsphere,0
              DC.W      -2451/SC_bigsphere,-3074/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      -1964/SC_bigsphere,-2458/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      -1081/SC_bigsphere,-1357/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      -387/SC_bigsphere,-1697/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      -692/SC_bigsphere,-3074/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      -872/SC_bigsphere,-3834/SC_bigsphere,895/SC_bigsphere,0
              DC.W      -872/SC_bigsphere,-3834/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      -692/SC_bigsphere,-3074/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      -387/SC_bigsphere,-1697/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      387/SC_bigsphere,-1697/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      692/SC_bigsphere,-3074/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      872/SC_bigsphere,-3834/SC_bigsphere,895/SC_bigsphere,0
              DC.W      872/SC_bigsphere,-3834/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      692/SC_bigsphere,-3074/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      387/SC_bigsphere,-1697/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      1081/SC_bigsphere,-1357/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      1964/SC_bigsphere,-2458/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      2451/SC_bigsphere,-3074/SC_bigsphere,895/SC_bigsphere,0
              DC.W      2451/SC_bigsphere,-3074/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      1964/SC_bigsphere,-2458/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      1081/SC_bigsphere,-1357/SC_bigsphere,-3641/SC_bigsphere,0
              DC.W      1569/SC_bigsphere,-750/SC_bigsphere,3641/SC_bigsphere,0
              DC.W      2839/SC_bigsphere,-1366/SC_bigsphere,2514/SC_bigsphere,0
              DC.W      3542/SC_bigsphere,-1705/SC_bigsphere,895/SC_bigsphere,0
              DC.W      3542/SC_bigsphere,-1705/SC_bigsphere,-895/SC_bigsphere,0
              DC.W      2839/SC_bigsphere,-1366/SC_bigsphere,-2514/SC_bigsphere,0
              DC.W      1569/SC_bigsphere,-750/SC_bigsphere,-3641/SC_bigsphere,0

obj_fo_pl1:   DC.W      2,6
              DC.L      obj_fo_pnts,0,0
              DC.W      0,0,3,0,1,2,3,0,30,30,10,10
              DC.W      0,1,3,3,2,1,0,3,10,10,30,30
obj_fo_pl2:   DC.W      2,6
              DC.L      obj_fo_pnts,0,0
              DC.W      0,1,3,0,1,2,3,0,30,30,10,10
              DC.W      0,0,3,3,2,1,0,3,10,10,30,30
SC_FO_PL      EQU       2
obj_fo_pnts:  DS.W      8,0
              DC.W      150/SC_FO_PL,-150/SC_FO_PL,0,0
              DC.W      -150/SC_FO_PL,-150/SC_FO_PL,0,0
              DC.W      -150/SC_FO_PL,150/SC_FO_PL,0,0
              DC.W      150/SC_FO_PL,150/SC_FO_PL,0,0

kan_pfeil:    DC.L      fla_pfeil
              DC.W      7,2
              DC.W      2,1,0,2,2,1
              DC.W      2,3,2,2,4,3
              DC.W      2,5,4,2,6,5
              DC.W      2,0,6

obj_pfeil:    DC.W      11,14+2
              DC.L      pnt_pfeil
              DS.L      11

              DC.W      0,3,2,0,1,6,0,30,10,10
              DC.W      0,3,3,2,3,4,5,2,10,30,30,10
fla_pfeil:    DS.W      14+12
              DS.W      7*14

SC_EPF        EQU       2
pnt_pfeil:    DS.W      8
              DC.W      0/SC_EPF,-100/SC_EPF,0/SC_EPF,0
              DC.W      75/SC_EPF,-25/SC_EPF,0/SC_EPF,0
              DC.W      25/SC_EPF,-25/SC_EPF,0/SC_EPF,0
              DC.W      25/SC_EPF,100/SC_EPF,0/SC_EPF,0
              DC.W      -25/SC_EPF,100/SC_EPF,0/SC_EPF,0
              DC.W      -25/SC_EPF,-25/SC_EPF,0/SC_EPF,0
              DC.W      -75/SC_EPF,-25/SC_EPF,0/SC_EPF,0
              DS.W      7*4

ayc_1         EQU       BLUE
ayc_2         EQU       YELLOW
ayc_3         EQU       CYAN
are_you_cube1:
              DC.W      24,14+2
              DC.L      are_you_pnts1
              DS.L      24

              DC.W      0,ayc_1,3-1,06,07,00,06,1,1,30
              DC.W      0,ayc_1,3-1,07,08,00,07,1,1,30
              DC.W      0,ayc_1,3-1,09,00,08,09,1,30,1
              DC.W      0,ayc_1,3-1,06,00,09,06,1,30,1
              DC.W      0,ayc_1,3-1,07,12,01,07,1,1,30
              DC.W      0,ayc_1,3-1,12,11,01,12,1,1,30
              DC.W      0,ayc_1,3-1,08,01,11,08,1,30,1
              DC.W      0,ayc_1,3-1,07,01,08,07,1,30,1
              DC.W      0,ayc_1,3-1,12,13,02,12,1,1,30
              DC.W      0,ayc_1,3-1,13,10,02,13,1,1,30
              DC.W      0,ayc_1,3-1,11,02,10,11,1,30,1
              DC.W      0,ayc_1,3-1,12,02,11,12,1,30,1
              DC.W      0,ayc_1,3-1,13,06,03,13,1,1,30
              DC.W      0,ayc_1,3-1,06,09,03,06,1,1,30
              DC.W      0,ayc_1,3-1,10,03,09,10,1,30,1
              DC.W      0,ayc_1,3-1,13,03,10,13,1,30,1
              DC.W      0,ayc_1,3-1,13,12,04,13,1,1,30
              DC.W      0,ayc_1,3-1,12,07,04,12,1,1,30
              DC.W      0,ayc_1,3-1,06,04,07,06,1,30,1
              DC.W      0,ayc_1,3-1,13,04,06,13,1,30,1
              DC.W      0,ayc_1,3-1,09,08,05,09,1,1,30
              DC.W      0,ayc_1,3-1,08,11,05,08,1,1,30
              DC.W      0,ayc_1,3-1,10,05,11,10,1,30,1
              DC.W      0,ayc_1,3-1,09,05,10,09,1,30,1

are_you_cube2:
              DC.W      24,14+2
              DC.L      are_you_pnts
              DS.L      24

              DC.W      0,ayc_2,3-1,06,07,00,06,1,1,30
              DC.W      0,ayc_2,3-1,07,08,00,07,1,1,30
              DC.W      0,ayc_2,3-1,09,00,08,09,1,30,1
              DC.W      0,ayc_2,3-1,06,00,09,06,1,30,1
              DC.W      0,ayc_2,3-1,07,12,01,07,1,1,30
              DC.W      0,ayc_2,3-1,12,11,01,12,1,1,30
              DC.W      0,ayc_2,3-1,08,01,11,08,1,30,1
              DC.W      0,ayc_2,3-1,07,01,08,07,1,30,1
              DC.W      0,ayc_2,3-1,12,13,02,12,1,1,30
              DC.W      0,ayc_2,3-1,13,10,02,13,1,1,30
              DC.W      0,ayc_2,3-1,11,02,10,11,1,30,1
              DC.W      0,ayc_2,3-1,12,02,11,12,1,30,1
              DC.W      0,ayc_2,3-1,13,06,03,13,1,1,30
              DC.W      0,ayc_2,3-1,06,09,03,06,1,1,30
              DC.W      0,ayc_2,3-1,10,03,09,10,1,30,1
              DC.W      0,ayc_2,3-1,13,03,10,13,1,30,1
              DC.W      0,ayc_2,3-1,13,12,04,13,1,1,30
              DC.W      0,ayc_2,3-1,12,07,04,12,1,1,30
              DC.W      0,ayc_2,3-1,06,04,07,06,1,30,1
              DC.W      0,ayc_2,3-1,13,04,06,13,1,30,1
              DC.W      0,ayc_2,3-1,09,08,05,09,1,1,30
              DC.W      0,ayc_2,3-1,08,11,05,08,1,1,30
              DC.W      0,ayc_2,3-1,10,05,11,10,1,30,1
              DC.W      0,ayc_2,3-1,09,05,10,09,1,30,1

are_you_cube3:
              DC.W      24,14+2
              DC.L      are_you_pnts
              DS.L      24

              DC.W      0,ayc_3,3-1,06,07,00,06,1,1,30
              DC.W      0,ayc_3,3-1,07,08,00,07,1,1,30
              DC.W      0,ayc_3,3-1,09,00,08,09,1,30,1
              DC.W      0,ayc_3,3-1,06,00,09,06,1,30,1
              DC.W      0,ayc_3,3-1,07,12,01,07,1,1,30
              DC.W      0,ayc_3,3-1,12,11,01,12,1,1,30
              DC.W      0,ayc_3,3-1,08,01,11,08,1,30,1
              DC.W      0,ayc_3,3-1,07,01,08,07,1,30,1
              DC.W      0,ayc_3,3-1,12,13,02,12,1,1,30
              DC.W      0,ayc_3,3-1,13,10,02,13,1,1,30
              DC.W      0,ayc_3,3-1,11,02,10,11,1,30,1
              DC.W      0,ayc_3,3-1,12,02,11,12,1,30,1
              DC.W      0,ayc_3,3-1,13,06,03,13,1,1,30
              DC.W      0,ayc_3,3-1,06,09,03,06,1,1,30
              DC.W      0,ayc_3,3-1,10,03,09,10,1,30,1
              DC.W      0,ayc_3,3-1,13,03,10,13,1,30,1
              DC.W      0,ayc_3,3-1,13,12,04,13,1,1,30
              DC.W      0,ayc_3,3-1,12,07,04,12,1,1,30
              DC.W      0,ayc_3,3-1,06,04,07,06,1,30,1
              DC.W      0,ayc_3,3-1,13,04,06,13,1,30,1
              DC.W      0,ayc_3,3-1,09,08,05,09,1,1,30
              DC.W      0,ayc_3,3-1,08,11,05,08,1,1,30
              DC.W      0,ayc_3,3-1,10,05,11,10,1,30,1
              DC.W      0,ayc_3,3-1,09,05,10,09,1,30,1

AYC_SC        EQU       4
are_you_pnts: DS.W      8
              DC.W      0/AYC_SC,0/AYC_SC,170/AYC_SC,0  ; 00  : Mittelpunkt Fl„che 1
              DC.W      170/AYC_SC,0/AYC_SC,0/AYC_SC,0  ; 01  :         "      2
              DC.W      0/AYC_SC,0/AYC_SC,-170/AYC_SC,0 ; 02  :     "      3
              DC.W      -170/AYC_SC,0/AYC_SC,0/AYC_SC,0 ; 03  :     "      4
              DC.W      0/AYC_SC,-170/AYC_SC,0/AYC_SC,0 ; 04  :     "      5
              DC.W      0/AYC_SC,170/AYC_SC,0/AYC_SC,0  ; 05  :     "      6

              DC.W      -100/AYC_SC,-100/AYC_SC,100/AYC_SC,0    ; 06
              DC.W      100/AYC_SC,-100/AYC_SC,100/AYC_SC,0 ; 07
              DC.W      100/AYC_SC,100/AYC_SC,100/AYC_SC,0  ; 08
              DC.W      -100/AYC_SC,100/AYC_SC,100/AYC_SC,0 ; 09

              DC.W      -100/AYC_SC,100/AYC_SC,-100/AYC_SC,0    ; 10
              DC.W      100/AYC_SC,100/AYC_SC,-100/AYC_SC,0 ; 11
              DC.W      100/AYC_SC,-100/AYC_SC,-100/AYC_SC,0    ; 12
              DC.W      -100/AYC_SC,-100/AYC_SC,-100/AYC_SC,0   ; 13

AYC_SC1       EQU       2
are_you_pnts1:
              DS.W      8
              DC.W      0/AYC_SC1+52,0/AYC_SC1+52,217/AYC_SC1,0 ; 00  : Mittelpunkt Fl„che 1
              DC.W      217/AYC_SC1+52,0/AYC_SC1+52,0/AYC_SC1,0 ; 01  :         "      2
              DC.W      0/AYC_SC1+52,0/AYC_SC1+52,-217/AYC_SC1,0    ; 02  :     "      3
              DC.W      -217/AYC_SC1+52,0/AYC_SC1+52,0/AYC_SC1,0    ; 03  :     "      4
              DC.W      0/AYC_SC1+52,-217/AYC_SC1+52,0/AYC_SC1,0    ; 04  :     "      5
              DC.W      0/AYC_SC1+52,217/AYC_SC1+52,0/AYC_SC1,0 ; 05  :     "      6

              DC.W      -124/AYC_SC1+52,-124/AYC_SC1+52,124/AYC_SC1,0   ; 06
              DC.W      124/AYC_SC1+52,-124/AYC_SC1+52,124/AYC_SC1,0    ; 07
              DC.W      124/AYC_SC1+52,124/AYC_SC1+52,124/AYC_SC1,0 ; 08
              DC.W      -124/AYC_SC1+52,124/AYC_SC1+52,124/AYC_SC1,0    ; 09

              DC.W      -124/AYC_SC1+52,124/AYC_SC1+52,-124/AYC_SC1,0   ; 10
              DC.W      124/AYC_SC1+52,124/AYC_SC1+52,-124/AYC_SC1,0    ; 11
              DC.W      124/AYC_SC1+52,-124/AYC_SC1+52,-124/AYC_SC1,0   ; 12
              DC.W      -124/AYC_SC1+52,-124/AYC_SC1+52,-124/AYC_SC1,0  ; 13
              