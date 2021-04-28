1     REM *****************************
2     REM *     ELECTION BAR CHART    *
3     REM *       ATARI ST USER       *
4     REM *         JUNE 1987         *
5     REM *   (c)1987 ATARI ST USER   *
6     REM *            1987           *
7     REM *****************************
8     REM
10    nme$="STATE OF THE PARTIES"+chr$(0)
20    POKE SYSTAB+24,1
30    a#=GB
40    GINTIN=PEEK(a#+8):POKE GINTIN,PEEK(SYSTAB+8)
50    POKE GINTIN+2,2:s#=GINTIN+4
60    POKE s#,VARPTR(nme$)
70    GEMSYS(105)
80    POKE SYSTAB+24,0
90    CLEARW 2:FULLW 2
100   PRINT "STATE OF THE pARTy"
110   PRINT "An Election Plotter"
120   FOR n=1 TO 9
130   READ i,r,g,b
140   POKE contrl,14
150   POKE contrl+2,0
160   POKE contrl+6,4
170   POKE contrl+12,2
180   POKE intin,i
190   POKE intin+2,r
200   POKE intin+4,g
210   POKE intin+6,b
220   VDISYS(1)
230   NEXT n
240   DATA 5,1000,0,1000,2,1000,0,0
250   DATA 4,0,0,1000,6,1000,500,0
260   DATA 0,0,0,0,1,1000,1000,1000
270   DATA 7,0,1000,0,3,500,500,1000
280   DATA 14,1000,900,0
290   POKE intin+10,1
300   POKE intin+12,1
310   POKE intin+14,1
320   hndl=2
330   contot=0:labtot=0:alltot=0:othtot=0
340   CLEARW 2:FULLW 2
350   COLOR 2
360   GOTOXY 3,0
370   PRINT "  Seats Declared"
380   COLOR 1
390   LINEF 220,0,220,80
400   GOSUB 1420
410   GOTOXY 5,7
420   PRINT "Projected Seats"
430   REM *** INPUT PANELS ***
440   x1=248:x2=298:y1=29:y2=44
450   COLOR 1,4
460   GOSUB 920
470   y1=47:y2=62:COLOR 1,2,2,2,1
480   GOSUB 920
490   y1=65:y2=80:COLOR 1,6,6,6,1
500   GOSUB 920
510   y1=83:y2=98:COLOR 1,7,7,7,1
520   GOSUB 920
530   COLOR 14
540   GOTOXY 28,1:PRINT "+CON-"
550   GOTOXY 28,3:PRINT "+LAB-"
560   GOTOXY 28,5:PRINT "+ALL-"
570   GOTOXY 28,7:PRINT "+OTH-"
580   REM *** TOTALS PANELS ***
590   y1=110:y2=125:COLOR 1,4,4,4,1
600   GOSUB 920
610   y1=128:y2=143:COLOR 1,2,2,2,1
620   GOSUB 920
630   y1=146:y2=161:COLOR 1,6,6,6,1
640   GOSUB 920
650   y1=164:y2=179:COLOR 1,7,7,7,1
660   GOSUB 920:REM BAR PLOT
670   GOSUB 1320
680   GOSUB 1910
690   GOSUB 1180
700   GOSUB 810
710   GOSUB 1420
720   GOSUB 1320
730   GOSUB 1650
740   POKE contrl,122
750   POKE contrl+2,0
760   POKE contrl+6,1
770   POKE contrl+12,hndl
780   POKE intin,0
790   VDISYS(1)
800   GOTO 690
810   REM *** KEEP SCORE ***
820   IF xloc<260 AND xloc>254 THEN posit=1 ELSE posit=0
830   IF posit=1 THEN 870
840   IF xloc<292 AND xloc>286 THEN posit=-1 ELSE posit=0
850   IF posit=0 THEN RETURN
860   IF yloc<31 OR yloc>97 THEN RETURN
870   IF yloc<42 AND yloc>31 THEN contot=contot+posit
880   IF yloc<61 AND yloc>48 THEN labtot=labtot+posit
890   IF yloc<78 AND yloc>67 THEN alltot=alltot+posit
900   IF yloc<97 AND yloc>84 THEN othtot=othtot+posit
910   RETURN
920   REM *** BAR PLOT ***
930   POKE contrl,11
940   POKE contrl+2,2
950   POKE contrl+6,0
960   POKE contrl+10,1
970   POKE contrl+12,hndl
980   POKE ptsin,X1
990   POKE ptsin+2,Y1
1000  POKE ptsin+4,X2
1010  POKE ptsin+6,Y2
1020  VDISYS(1)
1030  RETURN
1040  X3=X2+1:X4=X2+2
1050  COLOR 0
1060  POKE contrl,11
1070  POKE contrl+2,2
1080  POKE contrl+6,0
1090  POKE contrl+10,1
1100  POKE contrl+12,hndl
1110  POKE ptsin,x3
1120  POKE ptsin+2,y1
1130  POKE ptsin+4,x4
1140  POKE ptsin+6,y2
1150  VDISYS(1)
1160  COLOR 1
1170  RETURN
1180  REM *** READ INPUT ***
1190  POKE contrl,124
1200  POKE contrl+2,0
1210  POKE contrl+6,0
1220  POKE contrl+12,hndl
1230  butprs=PEEK(intout)
1240  xloc=PEEK(ptsout)
1250  yloc=PEEK(ptsout+2)
1260  VDISYS(1)
1270  IF butprs=0 THEN 1190
1280  POKE INTOUT,0
1290  SOUND 1,10,8,6,10
1300  SOUND 1,10,4,6,5:SOUND 1,0,0,0,0
1310  RETURN
1320  REM *** PRINT SCORE ***
1330  IF contot<0 THEN contot=0
1340  IF labtot<0 THEN labtot=0
1350  IF alltot<0 THEN alltot=0
1360  IF othtot<0 THEN othtot=0
1370  GOTOXY 28,10:PRINT contot
1380  GOTOXY 28,12:PRINT labtot
1390  GOTOXY 28,14:PRINT alltot
1400  GOTOXY 28,16:PRINT othtot
1410  RETURN
1420  REM *** ACTUAL SEATS ***
1430  IF contot<0 OR contot>365 THEN GOTO 1490
1440  x1=0:y1=35:y2=45
1450  x2=INT(contot/1.5)
1460  COLOR 1,4
1470  IF SGN(posit)=1 THEN GOSUB 920
1480  IF SGN(posit)=-1 THEN GOSUB 1040
1490  IF labtot<0 OR labtot>365 THEN GOTO 1540
1500  Y1=48:Y2=58:COLOR 1,2
1510  x2=INT(labtot/1.5)
1520  IF SGN(posit)=1 THEN GOSUB 920
1530  IF SGN(posit)=-1 THEN GOSUB 1040
1540  IF alltot<0 OR alltot>365 THEN GOTO 1590
1550  Y1=61:Y2=71:COLOR 1,6
1560  x2=INT(alltot/1.5)
1570  IF SGN(posit)=1 THEN GOSUB 920
1580  IF SGN(posit)=-1 THEN GOSUB 1040
1590  IF othtot<0 OR othtot>365 THEN GOTO 1640
1600  Y1=74:Y2=84:COLOR 1,7
1610  x2=INT(othtot/1.5)
1620  IF SGN(posit)=1 THEN GOSUB 920
1630  IF SGN(posit)=-1 THEN GOSUB 1040
1640  RETURN
1650  REM *** PROJECTIONS ***
1660  protot=contot+labtot+alltot+othtot
1670  IF protot=0 THEN RETURN
1680  prodiv=650/protot
1690  procon=INT(contot*prodiv)
1700  prolab=INT(labtot*prodiv)
1710  proall=INT(alltot*prodiv)
1720  prooth=650-(procon+prolab+proall)
1730  x1=0
1740  IF procon>365 THEN x2=INT(365/1.5) ELSE x2=INT(procon/1.5)
1750  y1=100:y2=110:x1=0:x3=x2+1:x4=INT(365/1.5)+1
1760  COLOR 1,4:GOSUB 920
1770  COLOR 1,0:x1=x3:x2=x4:GOSUB 920
1780  IF prolab>365 THEN x2=INT(365/1.5) ELSE x2=INT(prolab/1.5)
1790  y1=113:y2=123:x1=0:x3=x2+1
1800  COLOR 1,2:GOSUB 920
1810  COLOR 1,0:x1=x3:x2=x4:GOSUB 920
1820  IF proall>365 THEN x2=INT(365/1.5) ELSE x2=INT(proall/1.5)
1830  y1=126:y2=136:x1=0:x3=x2+1
1840  COLOR 1,6:GOSUB 920
1850  COLOR 1,0:x1=x3:x2=x4:GOSUB 920
1860  IF prooth>365 THEN x2=INT(365/1.5) ELSE x2=INT(prooth/1.5)
1870  y1=139:y2=149:x1=0:x3=x2+1
1880  COLOR 1,7:GOSUB 920
1890  COLOR 1,0:x1=x3:x2=x4:GOSUB 920
1900  COLOR 1,1
1910  COLOR 5
1920  GOTOXY 0,15:PRINT"Results In";protot;"  ";
1930  COLOR 3
1940  PRINT"To Come";650-protot
1950  COLOR 14:PRINT
1960  PRINT ;"       (c) ATARI ST USER";
1970  COLOR 1
1980  RETURN
