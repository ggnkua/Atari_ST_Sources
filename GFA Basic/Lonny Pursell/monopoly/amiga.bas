1     GOTO 7900:REM  **** COMPUTER MONOPOLY ****  SOFTWARE COPYRIGHT <c> 1985    by David M. Addison
20    GOTO 10000:REM **** throw dice ****
30    RETURN:REM **** key press sound ****
40    REM **** graphic to build house ****
41    gshape(133,123), housepic%()
42    kk%=val(mid$(b$,8,1))-1:note1%=1900:note2%=1000:gosub 40000
44    gosub 41000:return
50    FOR u%=1 TO 4:IF d%(u%) < 2 THEN GOTO 58:REM **** SORT DEEDS ****
51    FOR v%=1 TO d%(u%)-1:FOR w%=1 TO d%(u%)-1:c$=STR$(p#(u%,w%)):b$=STR$(p#(u%,w%+1))
52    IF MID$(c$,2,2) = "23" OR MID$(c$,2,1) = "4" THEN y%=2-VAL(MID$(c$,2,1)):GOTO 54
53    y%=VAL(MID$(c$,4,2))
54    IF MID$(b$,2,2) = "23" OR MID$(b$,2,1) = "4" THEN x%=2-VAL(MID$(b$,2,1)):GOTO 56
55    x%=VAL(MID$(b$,4,2))
56    IF y% > x% THEN z#=p#(u%,w%):p#(u%,w%)=p#(u%,w%+1):p#(u%,w%+1)=z#
57    NEXT w%,v%
58    NEXT u%:RETURN
60    REM **** GRAPHIC TO BUILD HOTEL ****
62    gshape(108,111), hotelpic%()
64    kk%=5:note1%=5900:note2%=1500:gosub 40000
66    gosub 41000:return
70    gosub 36300:return:rem ****  GRAPHIC FOR POLICE  ****
80    RETURN:REM **** SOUND ****
90    yy%=126:xx%=215:j%=0:REM **** GRAPHIC FOR TRAIN ****
91    pena 1:draw (61,146 TO 240,146)
92    FOR i%=215 TO 61 STEP -1
93    j%=j%+1:IF j% > 4 THEN j% = 1
94    ON j% GOTO 95,96,97,98
95    gshape (i%,yy%),train1%():GOTO 99
96    gshape (i%,yy%),train2%():GOTO 99
97    gshape (i%,yy%),train3%():GOTO 99
98    gshape (i%,yy%),train4%()
99    SLEEP(50000):NEXT i%:RETURN
100   RETURN:REM **** SOUND ****
200   x%=VAL(MID$(b$,4,2)):REM **** FETCH PROPERTY NAME ****
210   a$=propname$(x%):pena propcolor%(x%):PRINT  a$;:pena maincolor%
220   RETURN
299   b$ = propdeed$(z%):RETURN:REM **** FETCH PROPERTY DEED ****
400   GOSUB 20000:GOSUB 460:REM **** MENU ****
401   ask MOUSE xx%,yy%,bb%:x% = pixel(xx%,yy%):IF bb%=0 THEN GOTO 401
402   IF x% = 27 THEN t%=4:GOSUB 20000:GOTO 1219
403   IF x% = 28 THEN GOTO 5000
404   IF x% = 29 THEN GOTO 401
405   if x% = 30 then gosub 3000:gosub 41000:goto 400
406   if x% = 25 then 410
409   goto 401
410   gosub 20000:?:?:? tab (14);"Are you SURE":? tab(12);"you want to QUIT!":gosub 1700
415   if x$="Y" then scnclr:chdir "/":end
420   goto 400
460   pena maincolor%:PRINT "          MENU"
462   peno 1:pena 25:CIRCLE ((14*8)-3,(9*8)-3),3:PAINT ((14*8)-3,(9*8)-3),0
464   pena 25:PRINT at(16*8,9*8);"= End"
466   pena 28:CIRCLE ((14*8)-3,(11*8)-3),3:PAINT ((14*8)-3,(11*8)-3),0
468   pena 22:PRINT at(16*8,11*8);"= Trade"
473   pena 30:circle ((14*8)-3,(13*8)-3),3:paint ((14*8)-3,(13*8)-3),0:pena 23:print at(16*8,13*8);"= Info."
475   pena 27:circle ((14*8)-3,(15*8)-3),3:paint ((14*8)-3,(15*8)-3),0:pena 26:? at(16*8,15*8);"= Play"
490   pena maincolor%:return
600   IF d%(t%)=0 THEN GOTO 1020:REM **** COMPUTER TRADE ****
610   u%=1
611   if u%=t% then 620
612   IF d%(u%)=0 THEN 620
613   v%=1
614   y%=0:b$=STR$(p#(u%,v%)):FOR w%=1 TO d%(t%):c$=STR$(p#(t%,w%)):IF MID$(b$,2,2)=MID$(c$,2,2) THEN y%=y%+1
616   NEXT w%:IF VAL(MID$(b$,2,1))=y%+1 AND b$<>"23" THEN 630
618   v%=v%+1:IF v%<=d%(u%) THEN 614
620   u%=u%+1:IF u%<4 THEN 611
621   GOTO 1003
630   x%=1
631   y%=0:c$=STR$(p#(t%,x%)):FOR z%=1 TO d%(u%):d$=STR$(p#(u%,z%)):IF MID$(c$,2,2)=MID$(d$,2,2) THEN y%=y%+1
632   NEXT z%:IF VAL(MID$(c$,2,1))=y%+1 THEN 640
634   x%=x%+1:IF x%<=d%(t%) THEN 631
635   GOTO 618
640   IF MID$(c$,2,2)=MID$(b$,2,2) THEN 634
650   d$=c$:y%=t%:t%=u%:GOSUB 6000:x%=z%:t%=y%:d$=b$:GOSUB 6000:y%=z%:z%=INT(y%-x%)/2:z%=100*INT(z%/100)
652   IF c%(t%)-z% < 0 OR c%(u%)+z% < 0 THEN GOTO 1003
660   w%=0:GOSUB 20000:pena 26:PRINT at (16*8,6*8);"HUMAN!"
661   w%=w%+1:SLEEP(200500):pena 1:PRINT at(16*8,6*8);"HUMAN!":SLEEP(200500):pena 26:PRINT at(16*8,6*8);"HUMAN!"
662   IF w% < 6 THEN 661
663   pena maincolor%:PRINT TAB(8);:GOSUB 4080:PRINT  " just traded ":d$=b$:b$=c$:PRINT TAB(8);:GOSUB 200
665   c%(t%)=c%(t%)-z%:c%(u%)=c%(u%)+z%
670   IF z% > 0 THEN PRINT tab(8); "and $";z%
680   PRINT tab(8); "and got ":b$=d$:? tab(8);:GOSUB 200
682   PRINT TAB(8);:IF z% < 0 THEN PRINT  "and $";ABS(z%);
684   PRINT  "from ";:y%=t%:t%=u%:GOSUB 4080:PRINT  "!"
690   PRINT TAB(8);:GOSUB 4080:PRINT  " has $";c%(u%);".":t%=y%:PRINT TAB(8);:GOSUB 4080:PRINT  " has $";c%(t%);"."
692   GOSUB 41000:GOSUB 20000:GOTO 5350
700   RETURN
1000  GOSUB 2400:IF t%=4 THEN GOTO 1003:REM **** MAIN LOOP ****
1001  GOTO 600
1003  IF d%(t%)=0 THEN GOTO 1020
1006  IF t% > 3 THEN GOTO 1009
1007  FOR s%=1 TO d%(t%):c$=STR$(p#(t%,s%)):IF mid$(c$,8,1)="0" or len(c$)>8 THEN GOSUB 1500
1008  NEXT s%
1009  IF t%=4 THEN GOSUB 1500
1020  GOSUB 1400:IF l%(t%) = 40 THEN 2900
1040  q%=0:GOSUB 20:PRINT at(48,80);" ";:GOSUB 4088:PRINT  " rolled ";
1045  IF d1%+d2%=8 OR d1%+d2%=11 THEN PRINT  "an";d1%+d2%:GOTO 1050
1046  PRINT  "a";d1%+d2%
1050  IF d1%<>d2% THEN GOTO 1100
1060  d3%=d3%+1:d%=d%+1
1061  if d%=3 then newxx%=40:gosub 31000:l%(t%)=40:?:? tab(8);"Three doubles...";:?:? tab(8);"GO TO JAIL!!":gosub 70:goto 1210
1100  GOSUB 30000:gosub 2780:gosub 20000:l%(t%)=l%(t%)+d1%+d2%:IF l%(t%) > 39 THEN l%(t%)=l%(t%)-40:GOSUB 4070
1110  z%=l%(t%):GOSUB 299:GOSUB 4080:PRINT  " landed on ":? tab(8);:GOSUB 200:PRINT  ".":GOSUB 80:GOSUB 700
1111  if mid$(b$,2,3)="502" then 47000
1112  IF MID$(b$,2,2)="60" THEN 3100
1113  IF MID$(b$,2,2)="70" THEN 4220
1114  IF MID$(b$,2,2)="80" THEN newxx%=40:gosub 31000:l%(t%)=40:gosub 70:goto 1210
1116  IF VAL(MID$(b$,2,1))>4 THEN GOSUB 2400:GOTO 1200
1120  FOR v%=1 TO 4:IF d%(v%)=0 THEN GOTO 1124
1121  FOR x%=1 TO d%(v%):c$=STR$(p#(v%,x%)):IF MID$(c$,1,3)=MID$(b$,1,3) THEN GOTO 1140
1122  NEXT x%
1124  NEXT v%
1125  IF t%<4 THEN GOTO 1300
1127  IF VAL(MID$(b$,2,1))<5 AND c%(4)< 20*fininfo%(8*VAL(MID$(b$,6,2))) THEN 1170
1130  ?:? tab(8);"You have $";c%(t%):?
1131  PRINT TAB(8);"Want to buy":? tab(8);:gosub 200
1133  ? tab(8);"for $";20*fininfo%(8*val(mid$(b$,6,2)));:pena 2:? "?":pena maincolor%:gosub 1700:if x$="N" then goto 1200
1136  GOSUB 2800:GOTO 1200
1140  IF v%<>t% THEN 1148
1141  IF t%=4 THEN ?:?:PRINT  TAB(8);"You own it.":GOTO 1200
1142  ?:?:PRINT  TAB(8);:GOSUB 4080:pena 2:PRINT  " owns it.":GOTO 1200
1148  IF MID$(c$,8,1)<>"0" THEN GOTO 1150
1149  PRINT  TAB(8);"No rent!":y%=t%:t%=v%:PRINT  TAB(8);:GOSUB 4080:t%=y%:PRINT tab(8); "mortgaged the property.":GOTO 1200
1150  PRINT  TAB(14);"PAY RENT!";:SLEEP(10500)
1152  pena 25:PRINT tab(14); "PAY RENT!";:pena maincolor%:SLEEP(10500):IF q%=82 THEN ?:PRINT tab(14); "(DOUBLED)"
1154  PRINT  TAB(8);:GOTO 2600
1170  IF d%(4)=0 THEN GOTO 1198
1172  z%=c%(4):FOR w%=1 TO d%(4):c$=STR$(p#(4,w%)):IF MID$(c$,8,1)="1" OR MID$(c$,8,1)="2" THEN z%=z%+10*fininfo%(8*VAL(MID$(c$,6,2)))
1174  NEXT w%:IF z%<20*fininfo%(8*VAL(MID$(b$,6,2))) THEN GOTO 1198
1176  PRINT  TAB(8);"You can raise an ":PRINT  TAB(8);"additional $";z%-c%(4);"cash ":PRINT  TAB(8);"by mortgaging ":PRINT  TAB(8);"undeveloped land."
1178  PRINT  TAB(8);"Want to mortgage land":PRINT  TAB(8);"and buy?":GOSUB 1700
1179  IF x$="N" THEN PRINT  TAB(8);"Not a gambler, eh? OK...":GOTO 1200
1186  u%=1
1187  GOSUB 2700:IF c%(4)>=20*fininfo%(8*VAL(MID$(b$,6,2))) THEN GOTO 1130
1188  u%=u%+1:IF u%<=d%(4) THEN 1187
1198  PRINT  TAB(8);"You don't have the":PRINT  TAB(8);"money to buy.":GOSUB 2780
1200  IF d3%=1 THEN gosub 41000:GOSUB 20000:GOSUB 4080:PRINT  " had doubles":d3%=0:gosub 2780:GOTO 1000
1210  d3%=0:d%=0:t%=t%+1:IF t%=5 THEN t%=1
1212  GOSUB 41000:IF j%(t%)=1000 THEN GOTO 1210
1218  IF t%=4 THEN GOTO 400
1219  goto 1223:if t%=4 then z%=l%(t%):gosub 299:gosub 20000:if z%=40 then ? "You are" else ? "You're on"
1220  if t%=4 then ? tab(8);:gosub 200:? " ":gosub 700:? tab(8);"You have $";c%(4)
1221  if t%<4 then gosub 20000:z%=t%:gosub 4080:z%=l%(t%):if z%=40 then ? " is" else ? " is on"
1222  if t%<4 then gosub 299:? tab(8);:gosub 200:gosub 700:? tab(8);:gosub 4088:? " has $";c%(t%)
1223  goto 1000
1300  REM **** WILL COMPUTER BUY ****
1301  x%=0:FOR v%=1 TO 4:x%=x%+35*h%(v%)+200*h1%(v%):NEXT v%:x%=x%-(h1%(t%)*200+h%(t%)*35):IF MID$(b$,2,2)<>"23" THEN 1314
1311  IF t%=3 AND RND>.5 THEN PRINT  TAB(8);"Utilities are so ":PRINT  TAB(8);"dull, he says.":GOSUB 1350:GOTO 1200
1312  IF c%(t%)< x%+100+50+t%*100 THEN GOSUB 1350:GOTO 1200
1313  GOSUB 2800:GOTO 1200
1314  IF MID$(b$,2,1)<>"4" THEN 1320
1315  IF t%=2 AND RND>.5 THEN PRINT  TAB(8);"Railroads are ickey,":PRINT  TAB(8);"says Betty.":GOSUB 1350:GOTO 1200
1316  y%=0:FOR v%=1 TO d%(t%)+1:IF INT(p#(t%,v%)/10^7)=10*INT(p#(t%,v%)/10^7)+4 THEN y%=y%+1
1317  NEXT v%:IF c%(t%)<500-100*y% THEN GOSUB 1350:GOTO 1200
1318  GOSUB 2800:GOTO 1200
1320  IF c%(t%)>x%+20*fininfo%(8*VAL(MID$(b$,6,2)))+10*3*t% THEN GOSUB 2800:GOTO 1200
1322  IF d%(t%)=0 THEN GOSUB 1350:GOTO 1200
1324  y%=0:FOR v%=1 TO d%(t%):c$=STR$(p#(t%,v%)):IF MID$(c$,2,2)=MID$(b$,2,2) THEN y%=y%+1
1326  NEXT v%:IF y%<>VAL(MID$(b$,2,1))-1 THEN GOSUB 1350:GOTO 1200
1330  IF c%(t%)=20*fininfo%(8*VAL(MID$(b$,6,2))) THEN GOSUB 2800:GOTO 1200
1336  IF d%(t%)=0 THEN GOSUB 1350:GOTO 1200
1340  x%=0:y%=0:FOR v%=1 TO d%(t%):c$=STR$(p#(t%,v%)):IF MID$(c$,8,1)="1" THEN x%=x%+10*fininfo%(8*VAL(MID$(c$,6,2)))
1342  NEXT v%:IF c%(t%)+x%<20*fininfo%(8*VAL(MID$(b$,6,2))) THEN GOSUB 1350:GOTO 1200
1344  IF c%(t%)>20*fininfo%(8*VAL(MID$(b$,6,2))) THEN GOSUB 2800:GOTO 1200
1345  GOSUB 2700:GOTO 1344
1350  REM **** REFUSE BUY ****
1351  ?:?:PRINT  TAB(8);:GOSUB 4080:PRINT  " saves ";:IF t%=2 THEN PRINT  "her";:GOTO 1353
1352  PRINT  "his";
1353  PRINT  " money.":RETURN
1400  REM **** DEVELOP HOUSES & HOTELS ****
1402  IF d%(t%)=0 THEN goto 1600
1404  z%=0:FOR v%=1 TO 4:z%=z%+35*h%(v%)+180*h1%(v%):NEXT v%:z%=z%+20-(h%(t%)*35+h1%(t%)*180):a%=1
1410  c$=STR$(p#(t%,a%)):IF MID$(c$,2,1)="4" OR MID$(c$,2,2)="23" THEN 1414
1411  IF VAL(MID$(c$,8,1))>1 AND VAL(MID$(c$,8,1))<7 THEN GOSUB 1485:ON y% GOTO 1428,1414
1414  a%=a%+1:IF a%>d%(t%) THEN gosub 2780:goto 1600
1416  GOTO 1410
1428  u%=VAL(MID$(c$,8,1))
1430  FOR w%=a% TO a%+VAL(MID$(c$,2,1))-1:b$=STR$(p#(t%,w%)):IF VAL(MID$(b$,8,1))>u% THEN 1436
1432  NEXT w%
1436  w%=w%-1:b$=STR$(p#(t%,w%)):y%=50*(1+INT(VAL(MID$(b$,4,2))/10))
1440  IF t%=4 AND c%(t%)<y% THEN GOSUB 2780:GOSUB 20000:PRINT  "You need another":PRINT  TAB(8);"$";y%-c%(t%);" to build.":sleep(500000):gosub 2780:goto 1600
1442  IF t%=4 THEN 1460
1443  IF c%(t%)<y%+z% AND l%(t%)=40 THEN gosub 2780:goto 1600
1444  IF c%(t%)<y%+z% THEN GOSUB 2780:goto 1600
1446  c%(t%)=c%(t%)-y%:p#(t%,w%)=p#(t%,w%)+1:GOSUB 20000:PRINT  "With $";c%(t%):? tab(8);"cash remaining,"
1447  PRINT  TAB(8);:GOSUB 4080:PRINT  " builds a ":? tab(8);:GOSUB 1478:PRINT  "$";y%;
1448  IF MID$(b$,8,1)="6" THEN h1%(t%)=h1%(t%)+1:h%(t%)=h%(t%)-4:pena 2:PRINT "Hotel":pena maincolor%:GOTO 1452
1450  h%(t%)=h%(t%)+1:PRINT  "House"
1452  PRINT  TAB(8);"on ";:GOSUB 200:PRINT  " ":IF MID$(b$,8,1)="6" THEN GOSUB 60:xx%=val(mid$(b$,4,2)):GOSUB 25000:GOSUB 20000:GOTO 1410
1459  xx%=val(mid$(b$,4,2)):GOSUB 25000:GOSUB 40:GOTO 1410
1460  gosub 20000:? "You have $";c%(t%):PRINT tab(8);"Want to build a ";:IF MID$(b$,8,1)="6" THEN PRINT  "Hotel on ":GOTO 1462
1461  PRINT :PRINT  TAB(8);:GOSUB 1478:PRINT  "House on"
1462  PRINT  TAB(8);:GOSUB 200:?:PRINT tab(8); "for $";y%;"?":GOSUB 1700
1463  IF x$="N" THEN GOSUB 20000:PRINT  "OK...":a%=a%+(VAL(MID$(c$,2,1))-VAL(MID$(c$,1,1))):GOTO 1414
1467  c%(t%)=c%(t%)-y%:p#(t%,w%)=p#(t%,w%)+1:c$=STR$(p#(t%,w%))
1468  IF MID$(c$,8,1)<"7" THEN h%(t%)=h%(t%)+1:GOSUB 40:GOSUB 20000:PRINT  "OK. Now you have $";c%(t%):GOTO 1471
1469  GOSUB 60:GOSUB 20000:PRINT  "OK.. ,Tycoon.":PRINT  TAB(8);"You have $";c%(t%):PRINT  TAB(8);"and a Hotel on ":PRINT  TAB(8);:GOSUB 200:PRINT  "!"
1470  GOSUB 27000:h%(t%)=h%(t%)-4:h1%(t%)=h1%(t%)+1:gosub 2780:gosub 2780:GOTO 1410
1471  IF  MID$(c$,8,1)="3" THEN PRINT  TAB(8);"and a house on":PRINT  TAB(8);:GOSUB 200:PRINT ".":GOSUB 27000:gosub 2780:gosub 2780:GOTO 1410
1472  PRINT  TAB(8);"and ";VAL(MID$(c$,8,1))-2;" houses on":PRINT  TAB(8);:GOSUB 200:PRINT " ":GOSUB 27000:gosub 2780:gosub 2780:GOTO 1410
1478  IF MID$(b$,8,1)="6" THEN RETURN
1480  pena 2:ON VAL(MID$(b$,8,1))-1 GOTO 1481,1482,1483,1484
1481  PRINT  "first ";:pena maincolor%:RETURN
1482  PRINT  "second ";:pena maincolor%:RETURN
1483  PRINT  "third ";:pena maincolor%:RETURN
1484  PRINT  "fourth ";:pena maincolor%:RETURN
1485  y%=1:w%=1
1486  d$=STR$(p#(t%,w%)):IF MID$(d$,2,2)=MID$(c$,2,2) AND MID$(d$,8,1)="0" THEN y%=2
1487  w%=w%+1:IF w%<=d%(t%) THEN 1486
1490  return
1500  REM **** UNMORTGAGE PROPERTY ****
1501  IF d%(t%)=0 THEN RETURN
1504  w%=1
1505  c$=STR$(p#(t%,w%)):IF LEN(c$)>8 THEN 1520
1506  w%=w%+1:IF w%<=d%(t%) THEN 1505
1510  w%=1
1512  c$=STR$(p#(t%,w%)):IF VAL(MID$(c$,8,1))>2 AND VAL(MID$(c$,8,1))<7 AND t%<4 THEN RETURN
1515  w%=w%+1:IF w%<=d%(t%) THEN 1512
1516  w%=1
1517  c$=STR$(p#(t%,w%)):IF MID$(c$,8,1)="0" THEN 1520
1518  w%=w%+1:IF w%<=d%(t%) THEN 1517
1519  RETURN
1520  y%=11*fininfo%(8*VAL(MID$(c$,6,2))):IF t%=4 THEN 1550
1522  IF c%(t%)<y%+z%+50*t% THEN RETURN
1524  c%(t%)=c%(t%)-y%:b$=c$:GOSUB 20000:GOSUB 4080:PRINT  " pays $";y%;",":PRINT
1525  PRINT  TAB(8);"including $";INT((1/11)*y%);"interest":PRINT :PRINT  TAB(8);"to remove the mortgage":PRINT
1526  ? TAB(8);"on ";:GOSUB 200:?:IF LEN(c$)>8 THEN p#(t%,w%)=VAL(MID$(c$,1,8))+2:tt%=t%:bb$=str$(p#(t%,w%)):GOSUB 19000:GOSUB 41000:GOSUB 20000:RETURN
1528  p#(t%,w%)=p#(t%,w%)+1:tt%=t%:bb$=str$(p#(t%,w%)):GOSUB 19000:GOSUB 41000:GOSUB 20000:GOTO 1504
1550  IF c%(t%)<y% THEN RETURN
1552  b$=c$:gosub 20000:? "You have $";c%(t%):?:? tab(8); "Want to pay $";y%:?  TAB(8);"to remove the mortgage":PRINT  TAB(8);"on ";:GOSUB 200:PRINT  "?"
1553  gosub 1700
1556  IF x$="N" THEN GOSUB 20000:RETURN
1560  c%(t%)=c%(t%)-y%:IF LEN(STR$(p#(t%,w%))) >8 THEN p#(t%,w%)=p#(t%,w%)+1/2
1562  p#(t%,w%)=p#(t%,w%)+1:GOSUB 20000:? "Mortgage removed.":? TAB(8);"You have $";c%(t%):tt%=t%:bb$=str$(p#(t%,w%)):GOSUB 19000:gosub 2780:GOTO 1504
1600  rem **** SHOW STUFF ****
1610  if t%=4 then z%=l%(t%):gosub 299:gosub 20000:if z%=40 then ? "You are" else ? "You're on"
1620  if t%=4 then ? tab(8);:gosub 200:? " ":gosub 700:? tab(8);"You have $";c%(4)
1630  if t%<4 then gosub 20000:z%=t%:gosub 4080:z%=l%(t%):if z%=40 then ? " is" else ? " is on"
1640  if t%<4 then gosub 299:? tab(8);:gosub 200:gosub 700:? tab(8);:gosub 4088:? " has $";c%(t%)
1650  return
1700  REM **** YES - NO ROUTINE ****
1702  sshape(91,150;210,162), oldyesno%()
1704  gshape(91,150), yesno%()
1706  ask mouse xxx%,yyy%,b%:sleep(10000):if b%=0 then 1706
1708  yn%=pixel(xxx%,yyy%)
1710  if yn%=8 then x$="Y":goto 1720
1712  if yn%=19 then x$="N":goto 1720
1714  goto 1706
1720  gshape(91,150), oldyesno%()
1730  return
2400  REM **** CHECK CASH LEVELS ****
2401  IF c%(t%) >= 0 THEN RETURN
2402  IF d%(t%) = 0 THEN z%=0:GOTO 2500
2403  u%=1
2404  GOSUB 2700:IF c%(t%) > 0 THEN RETURN
2406  u%=u%+1:IF u%<=d%(t%)+h%(t%)+h1%(t%) THEN 2404
2407  z%=0
2500  REM **** GO BUST, TAKE PROPERTY ****
2501  IF t%=4 THEN GOSUB 20000:PRINT  "  SORRY, YOU LOSE !!!!":gosub 41000:chdir "/":scnclr:end
2510  IF j%(1)+j%(2)+j%(3) >= 100*20 THEN GOSUB 20000:PRINT  "   YOU WIN, HUMAN!!!":gosub 41000:chdir "/":scnclr:end
2515  GOSUB 2780:GOSUB 20000:PRINT :PRINT :PRINT  TAB(12);:GOSUB 4080:PRINT  " is busted!!!":GOSUB 100:GOSUB 2780:GOSUB 20000
2520  newxx%=41:gosub 31000:l%(t%)=41:IF z%=1 OR z%=2 OR z%=3 OR z%=4 THEN GOTO 2527
2522  j%(t%)=1000:c%(t%)=0:FOR v%=1 TO d%(t%)
2523  if z%<1 or z%>4 then c$=str$(p#(t%,v%)):b=val(mid$(c$,4,2)):gshape (owner%(b,0),owner%(b,1)-6),blank%()
2525  p#(t%,v%)=0:next v%:d%(t%)=0:d%=0:d3%=0:gosub 50:return
2527  IF d%(t%)>0 THEN GOTO 2530
2528  GOSUB 20000:GOSUB 4080:PRINT  "'s $";c%(t%);" goes to":y%=t%:t%=z%:PRINT  TAB(8);:GOSUB 4080:t%=y%:PRINT  ".":c%(z%)=c%(z%)+c%(t%):GOSUB 2780:GOTO 2522
2530  FOR v%=d%(z%)+1 TO d%(z%)+d%(t%):p#(z%,v%)=p#(t%,v%-d%(z%)):GOSUB 18000:GOSUB 20000:GOSUB 2540
2531  NEXT v%:d%(z%)=v%-1
2532  GOSUB 2780:GOSUB 20000:IF z%=4 THEN PRINT  "You take ";:GOSUB 4080:PRINT  "'s land.":GOTO 2534
2533  x%=t%:t%=z%:GOSUB 4080:PRINT  " takes ":t%=x%:PRINT  TAB(8);:GOSUB 4080:PRINT  "'s property."
2534  IF c%(t%) > 0 THEN c%(z%)=c%(z%)+c%(t%):PRINT  TAB(8);"Also $";c%(t%);"in cash."
2535  GOSUB 100:GOTO 2522
2540  x1%=0:b$=STR$(p#(z%,v%)):y%=2*fininfo%(8*VAL(MID$(b$,6,2))):PRINT "Interest payable:":c%(z%)=c%(z%)-y%
2541  PRINT  TAB(8);"$";y%;"on ":? tab(8);:GOSUB 200:PRINT  ".":PRINT :gosub 41000
2542  w%=1
2543  c$=STR$(p#(z%,w%)):IF MID$(c$,2,2)=MID$(b$,2,2) THEN x1%=x1%+1:IF STR$(x1%)=MID$(b$,2,1) THEN 2548
2544  w%=w%+1:IF w%<=v% THEN 2543
2545  RETURN
2548  w%=1
2549  c$=STR$(p#(z%,w%)):IF MID$(c$,2,2)<>MID$(b$,2,2) THEN 2560
2550  IF LEN(c$)=8 AND MID$(c$,8,1)="0" THEN p#(z%,w%)=p#(z%,w%)+1/2
2552  IF MID$(c$,8,1)="1" THEN p#(z%,w%)=p#(z%,w%)+1
2560  w%=w%+1:IF w%<=v% THEN 2549
2561  RETURN
2600  REM **** PAY RENT ****
2601  z%=VAL(MID$(c$,8,1)):x%=t%
2608  IF MID$(c$,2,1)="4" THEN 2650
2609  IF MID$(c$,2,2)="23" THEN 2670
2610  GOSUB 4080:PRINT  " must pay ":t%=v%:PRINT TAB(8);:GOSUB 4080:PRINT  " $";
2612  IF z%>2 THEN 2620
2614  y%=fininfo%(8*VAL(MID$(b$,6,2))+z%-8):PRINT  y%
2616  IF z%=2 THEN PRINT  TAB(8);"(Doubled for monopoly)"
2618  GOTO 2630
2620  y%=10*fininfo%(8*VAL(MID$(b$,6,2))+z%-8):PRINT  y%:PRINT  TAB(8);"(Rent for ";:IF z%=7 THEN PRINT "HOTEL)":goto 2630
2622  PRINT  z%-2;:IF z%=3 THEN PRINT  " house)":GOTO 2630
2624  PRINT  " houses)"
2630  t%=x%:IF c%(x%)<y% THEN 2640
2632  c%(t%)=c%(t%)-y%:c%(v%)=c%(v%)+y%:IF t%=4 THEN PRINT  TAB(8);"You pay $";y%:GOTO 1200
2635  PRINT  TAB(8);:GOSUB 4088:PRINT  " pays $";y%;".";:GOTO 1200
2640  z%=v%:IF d%(t%)=0 THEN GOSUB 2500:GOTO 1200
2642  FOR u%=1 TO d%(t%)+h%(t%)+h1%(t%):z%=v%:gosub 2780:GOSUB 2700:v%=z%:IF c%(t%)>=y% THEN u%=0:GOTO 2632
2644  NEXT u%:GOSUB 2500:GOTO 1200
2650  u%=0:FOR w%=1 TO d%(v%):c$=STR$(p#(v%,w%)):IF MID$(c$,2,1)="4" THEN u%=u%+1
2652  NEXT w%:IF u%=1 THEN y%=25:GOTO 2658
2654  y%=50*INT((u%*u%)/4)
2658  IF q%=82 THEN y%=y%*2
2660  PRINT  TAB(8);:GOSUB 4080:IF t%=4 THEN PRINT  " owe ";
2661  IF t%<4 THEN PRINT  " owes ";
2662  x%=t%:t%=v%:GOSUB 4080:PRINT  " $";y%;".":IF u%>1 THEN PRINT  TAB(8);"(Rent with";u%;"Railroads)"
2663  GOTO 2630
2670  u%=0:FOR w%=1 TO d%(v%):c$=STR$(p#(v%,w%)):IF MID$(c$,2,2)="23" THEN u%=u%+1
2671  NEXT w%:y%=v%:GOSUB 2780:v%=y%:IF q%=82 THEN u%=2
2672  PRINT tab(8); "Rolling to pay rent..":GOSUB 10000:w%=d1%:z%=d2%
2674  PRINT  TAB(8);:GOSUB 4080:PRINT  " rolled a ";w%+z%:ON u% GOTO 2676,2678
2676  y%=4*(w%+z%):x%=t%:t%=v%:PRINT  TAB(8);"Pay ";:GOSUB 4080:PRINT  " 4 ";:GOTO 2680
2678  y%=10*(w%+z%):PRINT  TAB(8);"UTILITY MONOPOLY!":x%=t%:t%=v%:PRINT :PRINT  TAB(8);"Pay ";:GOSUB 4080:PRINT  " 10 ";
2680  PRINT  "times":PRINT  TAB(8);"the roll of the dice!":?:goto 2630
2700  REM ****  MORTGAGE PROPERTY ****
2705  IF d%(t%)=0 THEN RETURN
2709  v%=1
2710  c$=STR$(p#(t%,v%)):IF MID$(c$,2,1)<>"4" AND MID$(c$,8,1)="1" THEN 2722
2711  v%=v%+1:IF v%<=d%(t%) THEN 2710
2712  v%=1
2713  c$=STR$(p#(t%,v%)):IF MID$(c$,8,1)="1" THEN 2722
2714  v%=v%+1:IF v%<=d%(t%) THEN 2713
2716  FOR v%=1 TO d%(t%):c$=STR$(p#(t%,v%)):IF MID$(c$,8,1)="2" THEN w%=d%(t%)+1:GOTO 2718
2717  NEXT v%:GOTO 2730
2718  w%=w%-1:d$=STR$(p#(t%,w%)):IF MID$(d$,2,2)=MID$(c$,2,2) AND VAL(MID$(d$,8,1)) > 2 THEN 2730
2719  IF w%=1 THEN 2721
2720  GOTO 2718
2721  p#(t%,v%)=p#(t%,v%)-1/2
2722  p#(t%,v%)=p#(t%,v%)-1
2724  x%=10*fininfo%(8*VAL(MID$(c$,6,2)))
2725  c%(t%)=c%(t%)+x%:a$=b$:b$=c$:c$=a$
2726  gosub 2780:GOSUB 20000:GOSUB 4080:PRINT  " borrowed $";x%:PRINT  TAB(8);"on ";:GOSUB 200:PRINT  "."
2728  b$=c$:PRINT :PRINT tab(8); "Total cash: $";c%(t%):bb$=STR$(p#(t%,v%)):tt%=t%:GOSUB 19000:GOSUB 41000:gosub 20000:RETURN
2730  w%=8
2731  w%=w%-1:FOR v%=1 TO d%(t%):c$=STR$(p#(t%,v%)):IF MID$(c$,8,1)=STR$(w%) THEN 2750
2732  NEXT v%
2734  IF w%=3 THEN RETURN
2736  GOTO 2731
2750  p#(t%,v%)=p#(t%,v%)-1:x%=5*5*(1+INT(VAL(MID$(c$,4,2))/10)):IF w%=7 THEN h%(t%)=h%(t%)+4:h1%(t%)=h1%(t%)-1:GOTO 2760
2752  h%(t%)=h%(t%)-1
2760  b$=STR$(p#(t%,v%)):xx%=VAL(MID$(b$,4,2)):GOSUB 26000:c%(t%)=c%(t%)+x%:GOSUB 20000:GOSUB 4080:PRINT  " mortgaged":IF w%=7 THEN PRINT  TAB(8);"a hotel":GOTO 2762
2761  PRINT  TAB(8);"the ";:GOSUB 2770:PRINT  " house"
2762  w%=x%:PRINT  TAB(8);"on ";:b$=c$:GOSUB 200:PRINT  TAB(8);"for $";w%:PRINT :PRINT  TAB (8);"Total cash: $";c%(t%):GOSUB 41000:RETURN
2770  pena 2:IF w%=6 THEN PRINT  "fourth";
2771  IF w%=5 THEN PRINT  "third";
2772  IF w%=4 THEN PRINT  "second";
2773  IF w%=3 THEN PRINT  "first";
2774  pena maincolor%:RETURN
2780  REM **** DELAY ****
2785  rem gosub 1700
2786  rem RETURN
2790  SLEEP(1000000):RETURN
2800  REM **** BUY PROPERTY ****
2805  c%(t%)=c%(t%)-20*fininfo%(8*VAL(MID$(b$,6,2))):?:PRINT  TAB(8);:GOSUB 4080
2808  PRINT  " bought "
2813  PRINT  TAB(8);:GOSUB 200:PRINT  ".":IF t%=4 THEN PRINT  TAB(8);"You have";:GOTO 2815
2814  PRINT  TAB(8);:GOSUB 4088:PRINT  " has";
2815  PRINT  " $";c%(t%);"left.";:d%(t%)=d%(t%)+1:p#(t%,d%(t%))=VAL(b$)-7:bb$=STR$(p#(t%,d%(t%))):tt%=t%:GOSUB 19000
2824  x%=0:FOR v%=1 TO d%(t%):a$=STR$(p#(t%,v%)):IF MID$(a$,2,2)=MID$(b$,2,2) THEN x%=x%+1
2826  NEXT v%:IF x%<>VAL(MID$(b$,2,1)) THEN GOSUB 50:RETURN
2830  FOR v%=1 TO d%(t%):a$=STR$(p#(t%,v%)):IF MID$(a$,2,2)=MID$(b$,2,2) AND MID$(a$,8,1)="1" THEN p#(t%,v%)=p#(t%,v%)+1
2831  IF MID$(a$,2,2)=MID$(b$,2,2) AND MID$(a$,8,1)="0" THEN p#(t%,v%)=p#(t%,v%)+1/2
2832  NEXT v%:GOSUB 50:RETURN
2900  REM **** JAIL ****
2905  j%(t%)=j%(t%)+1
2910  IF t%<4 THEN 2945
2913  IF j%(t%)<100 THEN 2920
2915  PRINT :PRINT  TAB(8);"Want to use the":PRINT  TAB(8);"GET OUT OF JAIL card?":GOSUB 1700:IF x$="Y" THEN j%(t%)=0:newxx%=10:GOSUB 31000:l%(t%)=10:GOSUB 20000:GOTO 1219
2920  IF c%(t%)<50 THEN 2932
2922  PRINT  :PRINT  TAB(8);"Want to pay $50 and":PRINT  TAB(8);"get out now?":GOSUB 1700:IF x$="N" THEN 2932
2927  IF j%(t%)>100 THEN j%(t%)=100
2928  IF j%(t%)<100 THEN j%(t%)=0
2929  c%(t%)=c%(t%)-50:newxx%=10:GOSUB 31000:l%(t%)=10:GOSUB 100:GOTO 1219
2932  gosub 2780:GOSUB 20000:PRINT  "OK, let's roll...":GOSUB 10000:IF d1%<>d2% THEN 2938
2934  PRINT :PRINT :PRINT  TAB(8);"DOUBLES! Your out free!":GOSUB 2780:IF j%(t%)<100 THEN j%(t%)=0
2935  IF j%(t%)>100 THEN j%(t%)=100
2936  newxx%=10:GOSUB 31000:l%(t%)=10:d%=1:GOSUB 100:GOTO 1100
2938  IF j%(t%)=3 OR j%(t%)=103 THEN 2980
2939  PRINT :PRINT :PRINT  TAB(8);"You stay in jail.":GOTO 1210
2945  GOSUB 2780:z%=0:FOR v%=1 TO 4:z%=h1%(v%)+z%:NEXT v%:IF z%-h1%(t%)>6-t% THEN 2970
2947  FOR v%=1 TO 4:z%=h%(v%)+z%:NEXT v%:IF z%-(h1%(t%)+h%(t%))>10-t% THEN 2970
2948  IF d%(1)+d%(2)+d%(3)+d%(4)>27 THEN 2970
2949  IF j%(t%)<100 THEN 2952
2950  GOSUB 2780:j%(t%)=0:newxx%=10:GOSUB 31000:l%(t%)=10:GOSUB 20000:GOSUB 4080:PRINT  " used":PRINT  TAB(9);"`GET OUT OF JAIL FREE'"
2951  GOSUB 100:GOSUB 2780:GOTO 1000
2952  IF c%(t%)<150 THEN 2970
2954  c%(t%)=c%(t%)-50:newxx%=10:GOSUB 31000:l%(t%)=10:?:? tab(8);:GOSUB 4080:? " pays $50 to":?  TAB(8);"get out of jail.":?:?  TAB(8);:GOSUB 4088
2955  PRINT  " has $";c%(t%):GOSUB 100
2956  GOSUB 2780:j%(t%)=0:GOTO 1000
2970  GOSUB 10000:PRINT  :PRINT :PRINT  TAB(8);:GOSUB 4080:PRINT  " rolls a";d1%;"and a";d2%:PRINT  TAB(8);
2972  GOSUB 2780:IF d1%=d2% THEN PRINT  TAB(8);:GOSUB 4088:PRINT  " rolls doubles!":GOSUB 2780:j%(t%)=0:newxx%=10:GOSUB 31000:l%(t%)=10:d%=1:GOTO 1100
2974  IF j%(t%)=103 THEN 2950
2976  IF j%(t%)=3 THEN 2980
2978  PRINT  TAB(8);:GOSUB 4088:PRINT  " stays in jail.":GOTO 1210
2980  IF c%(t%)>50 THEN c%(t%)=c%(t%)-50:newxx%=10:GOSUB 31000:l%(t%)=10:j%(t%)=0:?:?:?:PRINT  TAB(8);"Jailkeeper pockets $50.":GOTO 1100
2982  IF d%(t%)=0 THEN z%=0:GOSUB 2500:GOTO 1100
2984  FOR u%=1 TO d%(t%)+h%(t%)+h1%(t%):GOSUB 2700:IF c%(t%)>50 THEN 2980
2985  NEXT u%:z%=0:GOSUB 2500:GOTO 1100
3000  REM ****  DISPLAY INFO  ****
3002  gosub 20000:? "Point to the property":? tab(8);"you want info on, and":? tab(8);"click left button."
3004  ask mouse xxx%,yyy%,b%:if b%=0 then 3004
3006  flag%=1:gosub 35000:if flag%=0 then ?:? tab(17);"HUH ???":gosub 2780:goto 3000
3008  x%=z%:gosub 20000:?:a$="":gosub 299:? at ((13-int((len(a$)/2)))*8,48);:gosub 200:?
3010  if mid$(b$,2,2)<>"23" then 3034
3031  ?:? tab(8);"To find rent, roll dice":?:? tab(14);"NO MONOPOLY!":? tab(14);"4 times roll"
3032  ?:? tab (16);"MONOPOLY!":? tab(14);"10 times roll"
3033  ?:?:goto 3076
3034  if freepark%=1 then if mid$(b$,2,3)="502" then ?:?:? tab(8);"$";parkmoney%;"from taxes!!":return
3035  if mid$(b$,2,2)="60" then return
3036  if mid$(b$,2,2)="70" then return
3037  if mid$(b$,2,2)="80" then return
3038  if mid$(b$,2,2)="50" then return
3040  if mid$(b$,2,2)="41" then 3080
3066  ?:? tab(8);"PRICE $";20*fininfo%(8*val(mid$(b$,6,2)))
3068  ? tab(8);"RENT  $";fininfo%(8*val(mid$(b$,6,2))+1-8):?
3070  ? tab(8);"With 1 house    $";10*fininfo%(8*val(mid$(b$,6,2))+3-8)
3071  vv%=2
3072  ? tab(8);"With";vv%;"houses   $";10*fininfo%(8*val(mid$(b$,6,2))+vv%+2-8):vv%=vv%+1:if vv%<5 then 3072
3074  ?:? tab(8);"With HOTEL      $";10*fininfo%(8*val(mid$(b$,6,2))-1)
3075  ? tab(8);"Houses cost $";50 *(1+int(val(mid$(b$,4,2))/10));"each."
3076  ? tab(8);"Mortgage Value  $";10*fininfo%(8*val(mid$(b$,6,2))):return
3080  ?:? tab(8);"RENT . . . . . . . $ 25":?
3081  vv%=2
3082  ? tab(8);"If";vv%;"RRs are owned $";50*int((vv%*vv%)/4):vv%=vv%+1:if vv%<5 then 3082
3084  ?:? tab(8);"Mortgage Value  $ 100":return
3100  REM  ****  PAY TAXES  ****
3101  IF MID$(b$,1,3)="160" THEN 3150
3102  IF c%(t%)>75 THEN c%(t%)=c%(t%)-75:PRINT :PRINT  TAB(8);"Pay $75, leaving $";c%(t%):parkmoney%=parkmoney%+75:GOTO 1200
3110  v%=1
3111  GOSUB 2700:IF c%(t%)>75 THEN 3102
3113  v%=v%+1:IF v%<4 THEN 3111
3115  z%=0:GOSUB 2500:GOTO 1210
3150  r%=0:y%=c%(t%):IF d%(t%)=0 THEN 3152
3151  FOR v%=1 TO d%(t%):c$=STR$(p#(t%,v%)):y%=y%+20*fininfo%(8*VAL(MID$(c$,6,2))):NEXT v%
3152  s%=INT(y%/10):IF s%>200 THEN s%=200
3153  IF c%(t%)>s% THEN 3160
3154  r%=r%+1:IF r%>d%(t%)+h%(t%)+h1%(t%) THEN z%=0:GOSUB 2500:GOTO 1210
3156  GOSUB 2700:GOTO 3153
3160  PRINT  :PRINT  TAB(8);"Pay $";s%;",":c%(t%)=c%(t%)-s%:PRINT tab(8); "leaving $";c%(t%):parkmoney%=parkmoney%+s%:GOTO 1200
4070  REM ****  PASS GO  ****
4071  c%(t%)=c%(t%)+200:IF t%=4 THEN PRINT "At GO you collect $200.":GOTO 4074
4072  PRINT "At GO ";:GOSUB 4080:PRINT " gets $200."
4074  REM **** PASS GO SOUND ****
4075  ? tab(8);:RETURN
4079  REM ****  PLAYERNAMES & PRONOUNS  ****
4080  ON t% GOTO 4081,4082,4083,4084
4081  pena 8:PRINT  p1$;:pena maincolor%:RETURN
4082  pena 3:PRINT  p2$;:pena maincolor%:RETURN
4083  pena 23:PRINT  p3$;:pena maincolor%:RETURN
4084  pena 5:PRINT  "You";:pena maincolor%:RETURN
4085  pena 23:PRINT  "He";:pena maincolor%:RETURN
4086  pena 3:PRINT  "She";:pena maincolor%:RETURN
4087  pena 8:PRINT  "He";:pena maincolor%:RETURN
4088  ON t% GOTO 4087,4086,4085,4084
4220  REM ****  CHANCE & COMMUNITY CHEST  ****
4221  gosub 2780
4222  if mid$(b$,1,1)="2" then 4225
4223  dk1%=dk1%+1:if dk1%>14 then gosub 42000:dk1%=0
4224  GOSUB 22000:ON deck1%(dk1%)+1 GOTO 4350,4360,4370,4380,4390,4400,4410,4420,4430,4440,4450,4460,4470,4480,4490
4225  dk2%=dk2%+1:if dk2%>14 then gosub 43000:dk2%=0
4226  GOSUB 21000:ON deck2%(dk2%)+1 GOTO 4230,4240,4250,4260,4270,4280,4290,4300,4310,4320,4330,4340,4350,4360,4370
4230  pena 30:PRINT  :PRINT :PRINT TAB(8);"Advance to Illinois Ave.":pena maincolor%
4232  IF l%(t%) < 24 THEN newxx%=24:GOSUB 31000:l%(t%)=24:gosub 41000:GOSUB 20000:GOTO 1110
4234  GOSUB 4900:?:? tab(8);:GOSUB 4070:newxx%=24:GOSUB 31000:l%(t%)=24:gosub 41000:GOSUB 20000:GOTO 1110
4240  pena 30:?:PRINT :PRINT TAB(8); "      Take a ride":PRINT  TAB(13);"on the Reading.":pena maincolor%
4242  IF l%(t%) < 5 THEN newxx%=5:GOSUB 31000:l%(t%)=5:GOSUB 90:GOSUB 2780:GOSUB 20000:GOTO 1110
4244  GOSUB 4900:? tab(8);:GOSUB 4070:newxx%=5:GOSUB 31000:l%(t%)=5:GOSUB 90:GOSUB 2780:GOSUB 20000:GOTO 1110
4250  pena 30:PRINT :PRINT :PRINT  TAB(9);" Go back three spaces.":pena maincolor%
4252  newxx%=l%(t%)-3:GOSUB 31000:l%(t%)=l%(t%)-3:gosub 2780:GOSUB 2780:GOSUB 20000:GOTO 1110
4260  pena 30:PRINT  :PRINT :PRINT TAB(8); " Advance to St. Charles":pena maincolor%
4262  IF l%(t%) < 11 THEN newxx%=11:GOSUB 31000:l%(t%)=11:gosub 41000:gosub 20000:GOTO 1110
4264  GOSUB 4900:?:? tab(8);:GOSUB 4070:newxx%=11:GOSUB 31000:l%(t%)=11:gosub 41000:GOSUB 20000:GOTO 1110
4270  pena 30:PRINT :PRINT  TAB(15);"Advance to":PRINT  TAB(12);"nearest utility.":PRINT  TAB(8);"(Rent is 10 times roll.)":pena maincolor%
4272  q%=82:IF l%(t%)=22 THEN newxx%=28:GOSUB 31000:l%(t%)=28:GOSUB 41000:GOSUB 20000:GOTO 1110
4274  IF l%(t%)=36 THEN GOSUB 4900:?:? tab(8);:GOSUB 4070
4276  newxx%=12:GOSUB 31000:l%(t%)=12:GOSUB 41000:GOSUB 20000:GOTO 1110
4280  pena 30:?:PRINT :PRINT  TAB(14);"Take a walk":PRINT  TAB(11);"on the Boardwalk.":pena maincolor%
4282  newxx%=39:GOSUB 31000:l%(t%)=39:gosub 41000:GOSUB 20000:GOTO 1110
4290  pena 30:PRINT :PRINT TAB(13);"You're elected":PRINT  TAB(9);"chairman of the board.":PRINT :PRINT  TAB(10);"Pay each player $50.":pena maincolor%
4292  FOR v%=1 TO 4:c%(v%)=c%(v%)+50:NEXT v%
4294  c%(t%)=c%(t%)-200:z%=0:GOTO 1116
4300  pena 30:PRINT :PRINT  TAB(15);"Advance to":PRINT  TAB(11);"nearest railroad.":PRINT :PRINT  TAB(13);"(Rent Doubled)":pena maincolor%
4302  q%=82:IF l%(t%)>35 THEN GOSUB 4900:?:? tab(8);:GOSUB 4070:newxx%=5:GOSUB 31000:l%(t%)=5:GOSUB 90:GOSUB 2780:GOSUB 20000:GOTO 1110
4304  FOR v%=5 TO 35 STEP 10:IF l%(t%) < v% THEN newxx%=v%:GOSUB 31000:l%(t%)=v%:v%=0:GOSUB 90:GOSUB 2780:GOSUB 20000:GOTO 1110
4306  NEXT v%:GOTO 1110
4310  pena 30:?:PRINT  TAB(12);"General Repairs":PRINT :PRINT  TAB(11);"Pay $25 per House":PRINT  TAB(12);"$100 per Hotel.":pena maincolor%
4312  IF h%(t%)+h1%(t%)=0 THEN GOSUB 4900:PRINT  TAB(15);"(No Charge.)":GOTO 1116
4314  c%(t%)=c%(t%)-(25*h%(t%)+100*h1%(t%)):GOSUB 4900:PRINT  TAB (8);:GOSUB 4080:IF t%=4 THEN PRINT  " pay $";
4316  IF t%<4 THEN PRINT  " pays $";
4318  PRINT  25*h%(t%)+100*h1%(t%);" !":GOTO 1116
4320  pena 30:PRINT :PRINT :PRINT  TAB(10);"Pay poor tax of $15.":pena maincolor%:parkmoney%=parkmoney%+15
4322  c%(t%)=c%(t%)-15:GOTO 1116
4330  pena 30:?:PRINT :PRINT  TAB(13);"Bank pays you":PRINT  TAB(12);"dividend of $50":pena maincolor%
4332  c%(t%)=c%(t%)+50:GOTO 1116
4340  pena 30:PRINT :PRINT  TAB(13);"Your building":PRINT  TAB(12);"and loan matures.":PRINT :PRINT  TAB(14);"Collect $150.":pena maincolor%
4342  c%(t%)=c%(t%)+150:GOTO 1116
4350  pena 30:?:PRINT  TAB(14);"GO TO JAIL!":PRINT  TAB(9);"GO DIRECTLY TO JAIL!!!"
4352  PRINT :PRINT  TAB(13);"Do not pass GO":PRINT  TAB(10);"Do not collect $200!":pena maincolor%
4354  newxx%=40:GOSUB 31000:l%(t%)=40:GOSUB 70:GOTO 1210
4360  pena 30:PRINT :PRINT :PRINT  TAB(9);"Get out of jail, FREE!":pena maincolor%
4362  j%(t%)=100:GOTO 1116
4370  pena 30:PRINT :PRINT :PRINT  TAB(13);"Advance to GO!":pena maincolor%
4372  GOSUB 4900:?:? tab(8);:GOSUB 4070:newxx%=0:GOSUB 31000:l%(t%)=0:GOSUB 80:GOTO 1116
4380  pena 30:?:PRINT  TAB(15);"Assessment":PRINT  TAB(10);"for street repairs."
4382  PRINT :PRINT  TAB(11);"Pay $40 per House":PRINT  TAB(12);"$115 per Hotel.":pena maincolor%
4384  GOSUB 4900:IF h%(t%)+h1%(t%)=0 THEN PRINT  TAB(14);"(No Charge.)":GOTO 1116
4386  c%(t%)=c%(t%)-(40*h%(t%)+115*h1%(t%)):PRINT  TAB (8);:GOSUB 4080:IF t%=4 THEN PRINT  " pay $";
4387  IF t%<4 THEN PRINT  " pays $";
4388  PRINT  40*h%(t%)+115*h1%(t%);" !":GOTO 1116
4390  pena 30:PRINT :PRINT :PRINT  TAB(10);"Doctor's fee pay $50.":pena maincolor%
4392  c%(t%)=c%(t%)-50:GOTO 1116
4400  pena 30:PRINT :PRINT :PRINT  TAB(12);"You inherit $100.":pena maincolor%
4402  c%(t%)=c%(t%)+100:GOTO 1116
4410  pena 30:PRINT :PRINT  TAB(12);"Win second prize":PRINT TAB(10);"in a beauty contest!"
4412  PRINT :PRINT  TAB(14);"Collect $10.":pena maincolor%
4414  c%(t%)=c%(t%)+10:GOTO 1116
4420  pena 30:?:PRINT :PRINT  TAB(11);"From sale of stock":PRINT  TAB(14);"you get $45.":pena maincolor%
4422  c%(t%)=c%(t%)+45:GOTO 1116
4430  pena 30:?:?:PRINT  TAB(11);"Pay Hospital $100.":pena maincolor%
4432  c%(t%)=c%(t%)-100:GOTO 1116
4440  pena 30:?:PRINT :PRINT  TAB(11);"Income tax refund.":PRINT :PRINT  TAB(14);"Collect $20.":pena maincolor%
4442  c%(t%)=c%(t%)+20:GOTO 1116
4450  pena 30:?:PRINT :PRINT  TAB(11);"$ 200 bank error":PRINT  TAB(12);"in your favor!":pena maincolor%
4452  c%(t%)=c%(t%)+200:GOTO 1116
4460  pena 30:PRINT :PRINT :PRINT  TAB(8);"Receive for services $25":pena maincolor%
4462  c%(t%)=c%(t%)+25:GOTO 1116
4470  pena 30:?:PRINT :PRINT  TAB(9);"Life insurance matures":PRINT :PRINT  TAB(14);"Collect $100.":pena maincolor%
4472  c%(t%)=c%(t%)+100:GOTO 1116
4480  pena 30:?:PRINT :PRINT  TAB(11);"Xmas fund matures":PRINT :PRINT  TAB(14);"Collect $100.":pena maincolor%
4482  c%(t%)=c%(t%)+100:GOTO 1116
4490  pena 30:PRINT :PRINT :PRINT  TAB(9);"Pay school tax of $150":pena maincolor%:parkmoney%=parkmoney%+150
4492  c%(t%)=c%(t%)-150:GOTO 1116
4900  jj%=1
4910  PRINT
4920  jj%=jj%+1:IF jj%<5 THEN 4910
4930  RETURN
5000  REM **** TRADE WITH COMPUTER ****
5002  t%=4:GOSUB 20000:PRINT "Who do you":PRINT  TAB(8);"want to trade with? "
5003  peno 1:pena 27:circle ((14*8)-3,(11*8)-3),3:paint ((14*8)-3,(11*8)-3),0:pena 8:? at(16*8,11*8);"= Andy"
5004  pena 28:circle ((14*8)-3,(13*8)-3),3:paint ((14*8)-3,(13*8)-3),0:pena 3:? at(16*8,13*8);"= Betty"
5005  pena 29:circle ((14*8)-3,(15*8)-3),3:paint ((14*8)-3,(15*8)-3),0:pena 23:? at(16*8,15*8);"= Chip"
5006  ask mouse xxx%,yyy%,b%:if b%=0 then 5006
5007  u%=pixel(xxx%,yyy%)-26
5008  if u%<1 or u%>3 then 5006
5009  IF j%(u%)>=1000 THEN y%=t%:t%=u%:GOSUB 20000:GOSUB 4080:PRINT  " is out of the game":GOSUB 41000:GOTO 400
5010  y%=t%:t%=u%:GOSUB 20000:PRINT  "Hi. I'm ";:GOSUB 4080:PRINT  "."
5011  IF d%(u%)=0 THEN PRINT :PRINT  TAB(8);"I don't have":PRINT  TAB(8);"any property.":GOSUB 41000:GOTO 400
5012  PRINT  TAB(8);"I have $";c%(u%)
5020  flag%=1:PRINT :PRINT  TAB(8);"What one of my":PRINT  TAB(8);"properties are you":PRINT  TAB(8);"interested in?"
5022  PRINT :PRINT  TAB(8);"Point to it with mouse":PRINT  TAB(8);"and click left button."
5024  ask MOUSE xxx%,yyy%,b%:IF b%=0 THEN 5024
5026  gosub 20000:GOSUB 35000:IF flag%=0 THEN PRINT :PRINT  TAB(17);"HUH ???":GOSUB 2780:GOSUB 20000:GOTO 5020
5028  FOR w%=1 TO d%(u%):b$=STR$(p#(u%,w%)):IF VAL(MID$(b$,4,2))=z% THEN 5035
5029  NEXT w%
5030  PRINT :PRINT  TAB(8);"Sorry! I don't own that.":GOSUB 41000:GOSUB 20000:GOTO 5020
5035  z%=w%:b$=STR$(p#(t%,z%)):PRINT :PRINT  TAB(8);"You want ":? tab(8);:GOSUB 200:PRINT  "!"
5050  t%=y%:IF d%(t%)=0 THEN PRINT :PRINT  TAB(8);"You have no property":PRINT  TAB(8);"to offer.":GOSUB 41000:GOTO 400
5060  IF VAL(MID$(b$,8,1)) > 1 OR LEN(b$) > 8 THEN PRINT :PRINT  TAB(8);"I bet you want it.":PRINT  TAB(8);"So do I.":GOSUB 41000:GOSUB 20000:GOTO 400
5110  y%=0:FOR v%=1 TO d%(t%):c$=STR$(p#(t%,v%)):IF MID$(c$,2,2)=MID$(b$,2,2) THEN y%=y%+1
5120  NEXT v%:IF VAL(MID$(b$,2,1))=y%+1 THEN PRINT  TAB(8);"It would":PRINT  TAB(8);"give you a monopoly!":GOTO 5200
5122  FOR w%=1 TO 3:IF w%=u% THEN 5128
5123  IF d%(w%)=0 THEN 5128
5124  y%=0:FOR v%=1 TO d%(w%):c$=STR$(p#(w%,v%)):IF MID$(c$,2,2)=MID$(b$,2,2) THEN y%=y%+1
5126  NEXT v%:IF VAL(MID$(b$,2,1))=y%+1 THEN z%=t%:t%=w%:PRINT :t%=z%:GOTO 5200
5128  NEXT w%
5200  z%=1
5205  y%=0:c$=STR$(p#(t%,z%)):FOR w%=1 TO d%(u%):a$=STR$(p#(u%,w%)):IF MID$(a$,2,2)=MID$(c$,2,2) THEN y%=y%+1
5212  NEXT w%:IF VAL(MID$(c$,2,1))=y%+1 AND MID$(c$,2,2)<>"23" THEN s%=1:ON ERROR GOTO 0:GOTO 5218
5214  z%=z%+1:IF z%<=d%(t%) THEN 5205 ELSE GOTO 5230
5215  GOTO 5200
5218  IF MID$(c$,2,2)=MID$(b$,2,2) THEN 5214
5220  GOTO 5280
5230  r%=1
5231  IF d%(r%)=0 THEN 5240
5232  IF r%=u% THEN 5240
5234  z%=1
5235  y%=0:d$=STR$(p#(r%,z%)):FOR w%=1 TO d%(u%):a$=STR$(p#(u%,w%)):IF MID$(a$,2,2)=MID$(d$,2,2) THEN y%=y%+1
5236  NEXT w%:IF VAL(MID$(d$,2,1))=y%+1 AND MID$(d$,2,2)<>"23" THEN y%=0:GOTO 5250
5238  z%=z%+1:IF z%<=d%(r%) THEN 5235
5240  IF r%>3 THEN 5242
5241  r%=r%+1:IF r%<4 THEN 5231
5242  PRINT :PRINT  TAB(8);"I don't think":PRINT  TAB(8);"we can do business.":GOSUB 41000:GOTO 400
5250  p%=1
5251  y%=0:c$=STR$(p#(t%,p%)):FOR q%=1 TO d%(r%):a$=STR$(p#(r%,q%)):IF MID$(a$,2,2)=MID$(c$,2,2) THEN y%=y%+1
5252  NEXT q%:IF VAL(MID$(c$,2,1))=y%+1 THEN s%=2:GOTO 5280
5254  p%=p%+1:IF p%<=d%(t%) THEN 5251 ELSE GOTO 5238
5280  PRINT :PRINT tab(8); "Willing to discuss":d$=b$:b$=c$:PRINT  TAB(8);:GOSUB 200:b$=d$:PRINT  "?";:n%=r%:GOSUB 1700:r%=n%
5284  IF x$="N" AND s%=1 THEN 5214
5285  IF x$="N" AND s%=2 THEN 5254
5288  GOSUB 20000:PRINT  "OK, let's":PRINT  TAB(8);"GET down TO business.":PRINT  TAB(8)
5300  d$=c$:y%=t%:t%=u%:GOSUB 6000:x%=z%:t%=y%:d$=b$:GOSUB 6000:y%=z%
5318  PRINT :PRINT  TAB(8);"Human, I'll give you"
5320  z%=INT(y%-x%)/2:IF z%>0 THEN 5400
5322  z%=ABS(z%):IF z%>400 THEN z%=400+(z%-200)*6/10
5324  IF z%>c%(u%)*8/10 THEN z%=c%(u%)*8/10
5325  z%=100*INT(z%/100):IF z%>0 THEN PRINT TAB(8); "$";z%;"and ";
5326  ? tab(8);:GOSUB 200:PRINT :PRINT  TAB(8);"for ";:d$=b$:b$=c$:GOSUB 200:b$=d$:PRINT  " ":PRINT
5330  PRINT :PRINT  TAB(8);"Is it a deal?":GOSUB 1700:IF x$="N" THEN PRINT :PRINT  TAB(8);"OK. You may regret it.":GOSUB 41000:GOTO 400
5340  c%(u%)=c%(u%)-z%:c%(4)=c%(4)+z%:GOSUB 100:GOSUB 2780:GOSUB 20000
5345  REM ****  PROCESS ALL TRADES  ****
5350  y%=0:FOR v%=1 TO d%(u%):d$=STR$(p#(u%,v%)):IF d$=b$ THEN p#(u%,v%)=VAL(c$):tt%=u%:bb$=c$:GOSUB 19000:d$=c$
5351  IF MID$(d$,2,2)=MID$(c$,2,2) THEN y%=y%+1
5352  NEXT v%:x%=0:FOR v%=1 TO d%(t%):d$=STR$(p#(t%,v%)):IF d$=c$ THEN p#(t%,v%)=VAL(b$):tt%=t%:bb$=b$:GOSUB 19000:d$=b$
5353  IF MID$(d$,2,2)=MID$(b$,2,2) THEN x%=x%+1
5354  NEXT v%:IF y%<>VAL(MID$(c$,2,1)) THEN 5360
5355  FOR v%=1 TO d%(u%):d$=STR$(p#(u%,v%)):IF MID$(d$,2,2)<>MID$(c$,2,2) THEN 5359
5356  IF MID$(d$,8,1)="0" THEN p#(u%,v%)=p#(u%,v%)+1/2:GOTO 5359
5358  p#(u%,v%)=p#(u%,v%)+1
5359  NEXT v%
5360  IF x%<>VAL(MID$(b$,2,1)) THEN 5370
5362  v%=1
5363  d$=STR$(p#(t%,v%)):IF MID$(d$,2,2)<>MID$(b$,2,2) THEN 5369
5364  IF MID$(d$,8,1)="1" THEN p#(t%,v%)=p#(t%,v%)+1:GOTO 5369
5365  p#(t%,v%)=p#(t%,v%)+1/2
5369  v%=v%+1:IF v%<=d%(t%) THEN 5363
5370  GOSUB 50:IF t%<>4 THEN GOTO 1003
5372  GOTO 400
5400  z%=z%*2:IF z%>500 THEN z%=500+(z%-500)*2/3
5402  z%=100+100*INT(z%/100)
5403  IF z%>c%(t%) THEN GOSUB 2780:GOSUB 20000:PRINT  "Wait...":PRINT  TAB(8);"You are $";z%-c%(t%);"short!":gosub 2780:GOSUB 2780:GOTO 400
5404  PRINT  TAB(8);:GOSUB 200:?:PRINT tab(8); "for $";z%;" and":d$=b$:b$=c$:PRINT  TAB(8);:GOSUB 200:b$=d$:PRINT  " ":PRINT :PRINT
5410  PRINT  TAB(8);"Is it a deal?";:GOSUB 1700
5415  IF x$="N" THEN s%=10:PRINT :PRINT  TAB(8);"Think you're":PRINT  TAB(8);"smarter'n me, huh?":gosub 2780:GOSUB 2780:GOTO 400
5418  c%(u%)=c%(u%)+z%:c%(4)=c%(4)-z%:GOSUB 100:GOSUB 20000:GOTO 5350
6000  REM ****  EVALUATE PROPERTIES FOR TRADING  ****
6001  IF MID$(d$,2,1)="4" THEN z%=400:RETURN
6004  IF MID$(d$,2,2)="23" THEN z%=0:RETURN
6005  z=0:FOR v%=1 TO 4:IF v%<>t% THEN z=z+35*h%(v%)+200*h1%(v%)
6006  NEXT v%:z=c%(t%)-z:z=z+120*h%(t%)+350*h1%(t%)
6008  z=(INT(z/(50+VAL(MID$(d$,4,1))*50)))/(VAL(MID$(d$,2,1))*5):IF z>1 THEN z=1
6009  IF z<2/10 THEN z=2/10
6010  z=z*VAL(MID$(d$,2,1))*10*fininfo%(8*VAL(MID$(d$,6,2))-3):z=z+20*VAL(MID$(d$,6,2)):IF d$=c$ AND s%=2 THEN z=0
6020  IF MID$(d$,8,1)="0" THEN z=z-11*fininfo%(8*VAL(MID$(d$,6,2)))
6025  IF z>1000 THEN z=1000
6030  z%=INT(z):RETURN
7000  GOTO 400
7900  REM ****  INITIALIZE VARIABLES & START PROGRAM  ****
7902  clr:chdir "monofiles/":SCREEN 0,5
7904  DIM regsave%(100),monopic%(10500):bload "monopoly_pic_dat",VARPTR(regsave%(0))
7906  z%=0:x%=0
7908  rgb x%,regsave%(z%),regsave%(z%+1),regsave%(z%+2):z%=z%+3
7909  x%=x%+1:IF x%<32 THEN 7908
7910  bload "monopoly_pic",VARPTR(monopic%(0))
7912  gshape (0,0),monopic%():ERASE monopic%
7914  DIM center%(4200),dice1%(200),dice2%(200),dice3%(200),dice4%(200),dice5%(200),dice6%(200),chest%(2600),chance%(2600)
7916  DIM player1%(60),player2%(60),player3%(60),player4%(60),train1%(170),train2%(170),train3%(170),train4%(170)
7918  DIM old1%(60),old2%(60),old3%(60),old4%(60),propname$(41),propdeed$(41),propcolor%(41),play1pos%(40,1)
7919  dim housepic%(300),hotelpic%(800),continue%(300),name$(200),blank%(60),deck1%(15),deck2%(15):dk1%=-1:dk2%=-1
7920  DIM play2pos%(41,1),play3pos%(41,1),play4pos%(41,1),hopos%(41,1),owner%(41,1),fininfo%(128)
7921  DIM lite1%(575),lite2%(575),lite3%(575),lite4%(575),lite5%(575),lite6%(575),lite7%(575),lite8%(575),yesno%(300),oldyesno%(300)
7922  DIM d%(4),c%(4),l%(4),j%(4),h%(4),h1%(4),p#(4,26),m%(7),sinewave%(11):restore 7923:for cx%=0 to 11:read sinewave%(cx%):next cx%
7923  data 100,90,60,100,90,60,-100,-90,-60,-100,-90,-60
7924  p1$="Andy":p2$="Betty":p3$="Chip":maincolor%=1
7926  bload "center_pic",VARPTR(center%(0))
7928  bload "dice1",VARPTR(dice1%(0)):bload "dice2",VARPTR(dice2%(0))
7930  bload "dice3",VARPTR(dice3%(0)):bload "dice4",VARPTR(dice4%(0))
7932  bload "dice5",VARPTR(dice5%(0)):bload "dice6",VARPTR(dice6%(0))
7934  bload "player1",VARPTR(player1%(0)):bload "player2",VARPTR(player2%(0))
7936  bload "player3",VARPTR(player3%(0)):bload "player4",VARPTR(player4%(0))
7938  bload "train1",VARPTR(train1%(0)):bload "train2",VARPTR(train2%(0))
7940  bload "train3",VARPTR(train3%(0)):bload "train4",VARPTR(train4%(0))
7942  bload "chest_pic",VARPTR(chest%(0)):bload "chance_pic",VARPTR(chance%(0))
7943  GOSUB 36000
7944  sshape (275,171;275+9,171+7),old1%()
7946  sshape (287,171;287+9,171+7),old2%()
7948  sshape (275,178;275+9,178+7),old3%()
7950  sshape (287,178;287+9,178+7),old4%()
7960  GOSUB 11000:GOSUB 12000:GOSUB 13000:GOSUB 14000:GOSUB 15000:GOSUB 16000:GOSUB 17000
7970  audio 15,1:wave 6,sinewave%
8100  REM **** BEGIN PLAY  ****
8102  gosub 42000:gosub 43000
8103  gosub 20000:? "   Do you want to put":? tab(15);"TAX money":? tab(12);"in FREE PARKING?"
8104  freepark%=0:gosub 1700:if x$="Y" then freepark%=1
8108  FOR v%=1 TO 4:l%(v%)=0:c%(v%)=1500:d%(v%)=0:h%(v%)=0:h1%(v%)=0:j%(v%)=0
8109  FOR x%=1 TO 25:p#(v%,x%)=0:NEXT x%:NEXT v%:newxx%=0:FOR t%=1 TO 4:GOSUB 31000:NEXT t%
8110  GOSUB 20000:randomize -1:randomize -1:t%=INT((4*RND)+1):IF t%=4 THEN ?  "You go first.":?  TAB(8);"You have $1500.":gosub 2780:GOTO 1000
8112  GOSUB 4080:PRINT  " goes first.":PRINT  TAB(8);:GOSUB 4088:PRINT  " has $1500.":gosub 2780:gosub 2780:GOTO 1000
9000  RETURN
9999  REM ****  DRAW DICE & ROLL  ****
10000 dy%=42
10010 j%=1
10020 if j% < 28 then d1%=INT((RND * 6)) +1:dx% = 192:ON d1% GOSUB 10100,10200,10300,10400,10500,10600
10030 SLEEP(60000):cx%=sound(1,1,3,40,int(rnd*700)+700):cx%=sound(2,1,3,40,int(rnd*1000)+1000):d2%=rnd:d2%=rnd
10040 d2%=INT((RND * 6) +1):dx% = 222:ON d2% GOSUB 10100,10200,10300,10400,10500,10600
10050 j%=j%+1:if j%<31 then 10020
10060 RETURN
10100 gshape (dx%,dy%),dice1%():RETURN
10200 gshape (dx%,dy%),dice2%():RETURN
10300 gshape (dx%,dy%),dice3%():RETURN
10400 gshape (dx%,dy%),dice4%():RETURN
10500 gshape (dx%,dy%),dice5%():RETURN
10600 gshape (dx%,dy%),dice6%():RETURN
11000 REM **** BUILD PROPNAME$ ****
11020 RESTORE 11100
11030 i%=0
11031 READ propname$(i%)
11032 i%=i%+1:IF i%<41 THEN 11031
11040 RETURN
11100 DATA Go,Mediterranean Ave,Community Chest,Baltic Ave,Income Tax,Reading RR,Oriental Ave
11110 DATA Chance,Vermont Ave,Connecticut Ave,Just Visiting,St. Charles Pl,Electric Co,States Ave
11120 DATA Virginia Ave,Pennsylvania RR,St. James Pl,Community Chest,Tennessee Ave,New York Ave,Free Parking
11130 DATA Kentucky Ave,Chance,Indiana Ave,Illinois Ave,B & O RR,Atlantic Ave,Ventnor Ave,Water Works
11140 DATA Marvin Gardens,Go to Jail!,Pacific Ave,N.Carolina Ave,Community Chest,Pennsylvania Ave,Short Line RR
11150 DATA Chance,Park Place,Luxury Tax,Boardwalk,in jail
12000 REM **** BUILD PROPDEED$ ****
12010 RESTORE 12100
12020 i%=0
12021 READ propdeed$(i%)
12022 i%=i%+1:IF i%<41 THEN 12021
12030 RETURN
12100 DATA 15000008,12101018,17002008,22103028,16004008,14105088,13106038,27007008,23108038,33109048
12110 DATA 25010008,13211058,12312058,23213058,33214068,24115088,13316078,17017008,23318078,33319088
12120 DATA 35020008,13421098,27022008,23423098,33424108,34125088,13526118,23527118,22328058,33529128
12130 DATA 18030008,13631138,23632138,17033008,33634148,44135088,27036008,12237158,26038008,22239168,00040008
13000 REM **** BUILD PROPCOLOR% ****
13010 RESTORE 13100
13020 i%=0
13022 READ propcolor%(i%)
13024 i%=i%+1:IF i%<41 THEN 13022
13030 RETURN
13100 DATA 0,21,0,21,0,0,22,0,22,22,0,23,0,23,23,0,24,0,24,24,0,25,0,25,25,0,26,26,0,26,0,27,27,0,27,0,0,28,0,28,0
14000 REM **** BUILD PLAYPOS% ****
14020 FOR i%=0 TO 40:READ play1pos%(i%,0):READ play1pos%(i%,1):NEXT i%
14030 FOR i%=0 TO 40:READ play2pos%(i%,0):READ play2pos%(i%,1):NEXT i%
14040 FOR i%=0 TO 40:READ play3pos%(i%,0):READ play3pos%(i%,1):NEXT i%
14050 FOR i%=0 TO 40:READ play4pos%(i%,0):READ play4pos%(i%,1):NEXT i%
14060 RETURN
14100 DATA 275,171,241,171,216,171,191,171,166,171,141,171,116,171,91,171,66,171,40,171,5,163,5,146,5,131,5,116,5,101,5,86,5,71,5,56,5,41,5,26,5,3
14110 DATA 40,3,66,3,91,3,116,3,141,3,166,3,191,3,216,3,241,3,275,3,275,26,275,41,275,56,275,71,275,86,275,101,275,116,275,131,275,146,19,161
14200 DATA 287,171,253,171,228,171,203,171,178,171,153,171,128,171,103,171,78,171,52,171,5,172,17,146,17,131,17,116
14205 DATA 17,101,17,86,17,71,17,56,17,41,17,26,17,3
14210 DATA 52,3,78,3,103,3,128,3,153,3,178,3,203,3,228,3,253,3,287,3,287,26,287,41,287,56,287,71,287,86,287,101,287,116,287,131,287,146,28,161
14300 DATA 275,178,241,178,216,178,191,178,166,178,141,178,116,178,91,178,66,178,40,178,16,177,5,153,5,138,5,123,5,108,5,93,5,78,5,63,5,48,5,33,5,10
14310 DATA 40,10,66,10,91,10,116,10,141,10,166,10,191,10,216,10,241,10,275,10,275,33,275,48,275,63,275,78,275,93,275,108,275,123,275,138,275,153,19,168
14400 DATA 287,178,253,178,228,178,203,178,178,178,153,178,128,178,103,178,78,178,52,178,27,177,17,153,17,138,17,123,17,108,17,93,17,78,17,63,17,48,17,33,17,10
14410 DATA 52,10,78,10,103,10,128,10,153,10,178,10,203,10,228,10,253,10,287,10,287,33,287,48,287,63,287,78,287,93,287,108,287,123,287,138,287,153,28,168
15000 REM **** BUILD HOPOS% ****
15010 RESTORE 15100
15020 i%=0
15022 READ hopos%(i%,0):READ hopos%(i%,1)
15024 i%=i%+1:IF i%<41 THEN 15022
15030 RETURN
15100 DATA 0,0,248,168,0,0,198,168,0,0,0,0,123,168,0,0,73,168,47,168,0,0,30,156,0,0,30,126,30,111,0,0,30,81,0,0,30,51,30,36,0,0
15110 DATA 47,24,0,0,98,24,123,24,0,0,173,24,198,24,0,0,248,24,0,0,265,36,265,51,0,0,265,81,0,0,0,0,265,126,0,0,265,156,0,0
16000 REM **** BUILD OWNER% ****
16010 RESTORE 16100
16020 i%=0
16022 READ owner%(i%,0):READ owner%(i%,1)
16024 i%=i%+1:IF i%<41 THEN 16022
16030 RETURN
16100 DATA 0,0,248,159,0,0,198,159,0,0,148,159,123,159,0,0,73,159,47,159,0,0,39,156,39,141,39,126,39,111,39,96,39,81,0,0,39,51,39,36,0,0
16110 DATA 47,32,0,0,98,32,123,32,148,32,173,32,198,32,223,32,248,32,0,0,255,36,255,51,0,0,255,81,255,96,0,0,255,126,0,0,255,156,0,0
17000 REM **** BUILD FININFO ****
17010 RESTORE 17100
17020 i%=1
17022 READ fininfo%(i%)
17024 i%=i%+1:IF i%<129 THEN 17022
17030 RETURN
17100 DATA 2,4,1,3,9,16,25,3,4,8,2,6,18,32,45,3,6,12,3,9,27,40,55,5,8,16,4,10,30,45,60,6,10,20,5,15,45,63,75,7,12,24,6,18,50,70,90,8,14,28,7,20,55,75,95,9,16,32,8,22,60,80,100,10,18,36,9,25,70,88,105,11
17110 DATA 20,40,10,30,75,93,110,12,22,44,11,33,80,98,115,13,24,48,12,36,85,103,120,14,26,52,13,39,90,110,128,15,28,56,15,45,100,120,140,16,35,70,18,50,110,130,150,17,50,100,20,60,140,170,200,20
18000 REM **** DRAW OWNER ****
18001 drawmode 1
18010 IF z%=1 THEN x1$="A":x2$="a":pena 8
18020 IF z%=2 THEN x1$="B":x2$="b":pena 3
18030 IF z%=3 THEN x1$="C":x2$="c":pena 23
18040 IF z%=4 THEN x1$="H":x2$="h":pena 5
18050 b$=STR$(p#(z%,v%)):b=VAL(MID$(b$,4,2))
18060 PRINT at(owner%(b,0),owner%(b,1));" "
18070 IF VAL(MID$(b$,8,1))=0 THEN PRINT at(owner%(b,0),owner%(b,1));x2$ ELSE PRINT at(owner%(b,0),owner%(b,1));x1$
18080 drawmode 0:pena maincolor%:RETURN
19000 REM
19001 drawmode 1
19010 IF tt%=1 THEN x1$="A":x2$="a":pena 8
19020 IF tt%=2 THEN x1$="B":x2$="b":pena 3
19030 IF tt%=3 THEN x1$="C":x2$="c":pena 23
19040 IF tt%=4 THEN x1$="H":x2$="h":pena 5
19050 b=VAL(MID$(bb$,4,2))
19060 PRINT at(owner%(b,0),owner%(b,1));" "
19070 IF VAL(MID$(bb$,8,1))=0 THEN PRINT at(owner%(b,0),owner%(b,1));x2$ ELSE PRINT at(owner%(b,0),owner%(b,1));x1$
19080 drawmode 0:pena maincolor%:RETURN
20000 REM **** DRAW CENTER ****
20010 gshape (50,34),center%()
20020 drawmode 0:graphic 1:PRINT at(48,48);" ";
20030 RETURN
21000 REM **** DRAW CHANCE ****
21005 gosub 20000
21010 gshape (50,34),chance%()
21020 drawmode 0:graphic 1:PRINT at(48,55);" ";
21030 RETURN
22000 REM **** DRAW COMMUNITY ****
22005 gosub 20000
22010 gshape (50,34),chest%()
22020 drawmode 0:graphic 1:PRINT at(48,55);" ";
22030 RETURN
25000 REM **** DRAW HOTELS & HOUSES ****
25010 pena propcolor%(xx%):PAINT (hopos%(xx%,0)+2,hopos%(xx%,1)),0:ON VAL(MID$(b$,8,1))-1 GOTO 25020,25030,25040,25050,25060
25020 pena 20:PRINT at(hopos%(xx%,0),hopos%(xx%,1));"1":GOTO 25070
25030 pena 20:PRINT at(hopos%(xx%,0),hopos%(xx%,1));"2":GOTO 25070
25040 pena 20:PRINT at(hopos%(xx%,0),hopos%(xx%,1));"3":GOTO 25070
25050 pena 20:PRINT at(hopos%(xx%,0),hopos%(xx%,1));"4":GOTO 25070
25060 pena 2:PRINT at(hopos%(xx%,0),hopos%(xx%,1));"H"
25070 pena maincolor%:RETURN
26000 xx%=VAL(MID$(b$,4,2)):pena propcolor%(xx%):PAINT (hopos%(xx%,0)+2,hopos%(xx%,1)),0
26005 IF VAL(MID$(b$,8,1))-2 <= 0 GOTO 26070
26010 ON VAL(MID$(b$,8,1))-2 GOTO 25020,25030,25040,25050,25060
26070 pena maincolor%:RETURN
27000 xx%=val(mid$(c$,4,2)):pena propcolor%(xx%):paint (hopos%(xx%,0)+2,hopos%(xx%,1)),0
27010 if val(mid$(c$,8,1))-2 <= 0 goto 27030
27020 on val(mid$(c$,8,1))-2 goto 25020,25030,25040,25050,25060
27030 pena maincolor%:return
30000 REM **** MOVE PLAYERS ****
30005 xx%=l%(t%)
30010 i%=1
30015 SLEEP(200000)
30020 ON t% GOSUB 30200,30300,30400,30500
30025 cx%=sound(1,1,2,60,7000):cx%=sound(2,1,2,60,7000)
30030 i%=i%+1:IF i%<=d1%+d2% THEN 30015
30050 sleep(400000):RETURN
30200 gshape (play1pos%(xx%,0),play1pos%(xx%,1)),old1%()
30210 xx%=xx%+1:IF xx%>39 THEN xx%=xx%-40
30220 sshape (play1pos%(xx%,0),play1pos%(xx%,1);play1pos%(xx%,0)+9,play1pos%(xx%,1)+7),old1%()
30230 gshape (play1pos%(xx%,0),play1pos%(xx%,1)),player1%()
30240 RETURN
30300 gshape (play2pos%(xx%,0),play2pos%(xx%,1)),old2%()
30310 xx%=xx%+1:IF xx%>39 THEN xx%=xx%-40
30320 sshape (play2pos%(xx%,0),play2pos%(xx%,1);play2pos%(xx%,0)+9,play2pos%(xx%,1)+7),old2%()
30330 gshape (play2pos%(xx%,0),play2pos%(xx%,1)),player2%()
30340 RETURN
30400 gshape (play3pos%(xx%,0),play3pos%(xx%,1)),old3%()
30410 xx%=xx%+1:IF xx%>39 THEN xx%=xx%-40
30420 sshape (play3pos%(xx%,0),play3pos%(xx%,1);play3pos%(xx%,0)+9,play3pos%(xx%,1)+7),old3%()
30430 gshape (play3pos%(xx%,0),play3pos%(xx%,1)),player3%()
30440 RETURN
30500 gshape (play4pos%(xx%,0),play4pos%(xx%,1)),old4%()
30510 xx%=xx%+1:IF xx%>39 THEN xx%=xx%-40
30520 sshape (play4pos%(xx%,0),play4pos%(xx%,1);play4pos%(xx%,0)+9,play4pos%(xx%,1)+7),old4%()
30530 gshape (play4pos%(xx%,0),play4pos%(xx%,1)),player4%()
30540 RETURN
31000 xx%=l%(t%)
31020 ON t% GOSUB 31200,31300,31400,31500
31025 cx%=sound(1,1,2,60,7000):cx%=sound(2,1,2,60,7000)
31050 RETURN
31200 gshape (play1pos%(xx%,0),play1pos%(xx%,1)),old1%()
31210 xx%=newxx%
31215 if xx%=41 then return
31220 sshape (play1pos%(xx%,0),play1pos%(xx%,1);play1pos%(xx%,0)+9,play1pos%(xx%,1)+7),old1%()
31230 gshape (play1pos%(xx%,0),play1pos%(xx%,1)),player1%()
31240 RETURN
31300 gshape (play2pos%(xx%,0),play2pos%(xx%,1)),old2%()
31310 xx%=newxx%
31315 if xx%=41 then return
31320 sshape (play2pos%(xx%,0),play2pos%(xx%,1);play2pos%(xx%,0)+9,play2pos%(xx%,1)+7),old2%()
31330 gshape (play2pos%(xx%,0),play2pos%(xx%,1)),player2%()
31340 RETURN
31400 gshape (play3pos%(xx%,0),play3pos%(xx%,1)),old3%()
31410 xx%=newxx%
31415 if xx%=41 then return
31420 sshape (play3pos%(xx%,0),play3pos%(xx%,1);play3pos%(xx%,0)+9,play3pos%(xx%,1)+7),old3%()
31430 gshape (play3pos%(xx%,0),play3pos%(xx%,1)),player3%()
31440 RETURN
31500 gshape (play4pos%(xx%,0),play4pos%(xx%,1)),old4%()
31510 xx%=newxx%
31515 if xx%=41 then return
31520 sshape (play4pos%(xx%,0),play4pos%(xx%,1);play4pos%(xx%,0)+9,play4pos%(xx%,1)+7),old4%()
31530 gshape (play4pos%(xx%,0),play4pos%(xx%,1)),player4%()
31540 RETURN
35000 REM ****  CHECK MOUSE FOR PROPERTY TO TRADE FOR ****
35001 IF yyy% > 25 THEN 35070
35010 IF xxx% < 1 OR xxx% > 264 THEN flag%=0:RETURN
35020 z%=20
35030 FOR xx%=38 TO 263 STEP 25
35040 IF xxx% <= xx% THEN RETURN
35050 z%=z%+1
35060 NEXT xx%
35070 IF yyy% > 161 THEN 35200
35080 IF xxx% > 38 AND xxx% < 263 THEN flag%=0:RETURN
35090 IF xxx% > 263 THEN 35150
35100 z%=19
35110 FOR xx%=40 TO 160 STEP 15
35120 IF yyy% <= xx% THEN RETURN
35130 z%=z%-1
35140 NEXT xx%
35150 z%=31
35160 FOR xx%=40 TO 160 STEP 15
35170 IF yyy% <= xx% THEN RETURN
35180 z%=z%+1
35190 NEXT xx%
35200 IF xxx% < 37 OR xxx% > 264 THEN flag%=0:RETURN
35210 z%=9
35220 FOR xx%=63 TO 263 STEP 25
35230 IF xxx% <= xx% THEN RETURN
35240 z%=z%-1
35250 NEXT xx%
35260 flag%=0:RETURN
36000 bload "lite1",VARPTR(lite1%(0))
36010 bload "lite2",VARPTR(lite2%(0))
36020 bload "lite3",VARPTR(lite3%(0))
36030 bload "lite4",VARPTR(lite4%(0))
36040 bload "lite5",VARPTR(lite5%(0))
36050 bload "lite6",VARPTR(lite6%(0))
36060 bload "lite7",VARPTR(lite7%(0))
36070 bload "lite8",VARPTR(lite8%(0))
36072 bload "house_pic",VARPTR(housepic%(0))
36074 bload "hotel_pic",VARPTR(hotelpic%(0))
36075 bload "yesno_pic",VARPTR(yesno%(0))
36078 bload "cont_pic",VARPTR(continue%(0))
36079 bload "blank_pic",VARPTR(blank%(0))
36080 RETURN
36300 REM ****  POLICE LIGHT  ****
36309 jj%=0:ii%=1
36310 jj%=jj%+1:IF jj%>8 THEN jj%=1
36320 ON jj% GOTO 36330,36340,36350,36360,36370,36375,36380,36390
36330 gshape (126,106),lite1%():GOTO 36400
36340 gshape (126,106),lite2%():GOTO 36400
36350 gshape (126,106),lite3%():GOTO 36400
36360 gshape (126,106),lite4%():GOTO 36400
36370 gshape (126,106),lite5%():GOTO 36400
36375 gshape (126,106),lite6%():GOTO 36400
36380 gshape (126,106),lite7%():GOTO 36400
36390 gshape (126,106),lite8%()
36400 SLEEP(65000):ii%=ii%+1:if ii%<88 then 36310
36405 RETURN
40000 rem ****  SOUND FOR HOUSES & HOTELS  ****
40010 jj%=65
40020 cx%=sound(1,1,5,jj%,note1%):cx%=sound(2,1,5,jj%,note2%)
40030 jj%=jj%-2:if jj%>0 then 40020
40040 kk%=kk%-1:if kk%>0 then 40010
40050 return
41000 REM  ****  CONTINUE  ****
41010 sshape(91,150;210,162), oldyesno%()
41020 gshape(91,150), continue%()
41030 ask mouse xxx%,yyy%,b%:sleep(10000):if b%=0 then 41030
41040 yn%=pixel(xxx%,yyy%)
41050 if yn%=8 then gshape(91,150),oldyesno%():return
41060 goto 41030
42000 rem **** SHUFFLE CHEST ****
42010 j%=0
42015 deck1%(j%)=j%:j%=j%+1:if j%<15 then 42015
42020 j%=14
42025 k%=int(rnd*(j%+1))
42030 temp%=deck1%(j%):deck1%(j%)=deck1%(k%):deck1%(k%)=temp%
42040 j%=j%-1:if j%>0 then 42025
42050 return
43000 rem **** SHUFFLE CHANCE ****
43010 j%=0
43015 deck2%(j%)=j%:j%=j%+1:if j%<15 then 43015
43020 j%=14
43025 k%=int(rnd*(j%+1))
43030 temp%=deck2%(j%):deck2%(j%)=deck2%(k%):deck2%(k%)=temp%
43040 j%=j%-1:if j%>0 then 43025
43050 return
47000 REM ****  FREE PARKING MONEY  ****
47005 if freepark%=0 then parkmoney%=0:goto 1116
47010 ?:?:? tab(8);:gosub 4088:if t%=4 then ? " collect $";parkmoney%:goto 47050
47020 ? " collects $";parkmoney%
47050 c%(t%)=c%(t%)+parkmoney%:parkmoney%=0:goto 1116
50000 RESUME NEXT
