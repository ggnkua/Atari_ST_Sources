10    rem #####################################################################
20    rem #                                                                   #
30    rem #                           Farb - Editor                           #
40    rem #                           -------------                           #
50    rem #                    LEVEL 16           Public Domain               #
60    rem #                                                                   #
70    rem # written by :  Sven KrÅppel, Linderner Str.29, 5138 Heinsberg      #
80    rem #                                                                   #
90    rem #####################################################################
100   if peek(systab)<>4 then ?"Falsche Bildschirmauflîsung":end
110   option base 0
120   dim farbe(15,2),p(5),x(2),y(2)
130   sm=peek(&h44e)*65536+abs(peek(&h450))
140   gosub startcolor:gosub fread
150   rem ############# Layout ##############################
160   layout:
170   fullw 2:clearw 2:out 2,27:out 2,69:gosub mausaus
180   gosub titel
190   color 1,2,2,0,0:x(1)=0:y(1)=24:x(2)=319:y(2)=186:gosub recht
200   x(1)=1:x(2)=120:f=0
210   for y=25 to 165 step 20:y(1)=y:y(2)=y(1)+20:color 1,f,1,1,1:gosub recht
220   f=f+1:next:x(1)=200:x(2)=318
230   for y=25 to 165 step 20:y(1)=y:y(2)=y(1)+20:color 1,f,1,1,1:gosub recht
240   color 1,1,2:f=f+1:next:p(1)=2:y(1)=25:y(2)=185:x(1)=120:x(2)=120
250   gosub polyline:x(1)=200:x(2)=200:gosub polyline
260   y(1)=35:y(2)=125:for f=2 to 4:color 1,1,1,0,0:x(1)=f*20+90:x(2)=x(1)+19
270   gosub recht:next
280   y(1)=35:y(2)=45:for f=2 to 4:color 1,f,f,0,0:x(1)=f*20+90:x(2)=x(1)+19
290   gosub recht:next
300   p(1)=1:gosub effekt:y(1)=43:x(1)=135:t$="R":color 2:gosub text:x(1)=155
310   t$="G":color 3:gosub text:x(1)=175:t$="B":color 4:gosub text
320   x(1)=130:x(2)=190:y(1)=145:y(2)=155:color 1,1,1,0,0:gosub recht:y(1)=165
330   y(2)=175:gosub recht:color 2:x(1)=135:y(1)=153:p(1)=1:p(2)=1:p(3)=50
340   t$="save":gosub text:y(1)=173:color 4:t$="Quit":gosub text
350   p(1)=0:gosub effekt
360   rem ################# Hauptprogramm ###################
370   main:
380   f=0:y=0:gosub set
390   gosub mausan:gosub maus:if button=0 then 390
400   x=int(xmaus/10):y=int((ymaus-25)/10)
410   if x>12 and x<19 and y=14 then end
420   if x>12 and x<19 and y=12 then gosub speichern:goto 390
430   gosub mausaus
440   if x<12 or x>19 or y<1 or y>9 then 460
450   gosub loesch:gosub stell:gosub set:goto 390
460   rem ################# Farbe auswÑhlen #################
470   gosub loesch:f=int(y/2):if x>16 then f=f+8
480   gosub set:goto 390
490   rem ################ Farben einstellen ###############
500   loesch:
510   color 0,0:x(1)=131:x(2)=148:y(1)=farbe(f,0)*10+46:y(2)=y(1)+8:gosub recht
520   x(1)=151:x(2)=168:y(1)=farbe(f,1)*10+46:y(2)=y(1)+8:gosub recht
530   x(1)=171:x(2)=188:y(1)=farbe(f,2)*10+46:y(2)=y(1)+8:gosub recht
540   t$=" ":if f>7 then 560
550   y(1)=f*20+37:x(1)=121:gosub text:goto 570
560   y(1)=(f-8)*20+37:x(1)=191:gosub text
570   return
580   set:
590   color 1,2,2,1,1:x(1)=131:x(2)=148:y(1)=farbe(f,0)*10+46:y(2)=y(1)+8
600   gosub recht
610   color 1,3,3,1,1:x(1)=151:x(2)=168:y(1)=farbe(f,1)*10+46:y(2)=y(1)+8
620   gosub recht
630   color 1,4,4,1,1:x(1)=171:x(2)=188:y(1)=farbe(f,2)*10+46:y(2)=y(1)+8
640   gosub recht:color 1
650   if f>7 then 670
660   t$=chr$(4):y(1)=f*20+37:x(1)=121:gosub text:goto 680
670   t$=chr$(3):y(1)=(f-8)*20+37:x(1)=191:gosub text
680   return
690   rem ############# Farbwerte einstellen ###############
700   stell:
710   if x=13 or x=14 then farbe(f,0)=y-2
720   if x=15 or x=16 then farbe(f,1)=y-2
730   if x=17 or x=18 then farbe(f,2)=y-2
740   poke contrl,14:poke contrl+2,0:poke contrl+6,4:poke intin,f
750   poke intin+2,farbe(f,0)*140:poke intin+4,farbe(f,1)*140
760   poke intin+6,farbe(f,2)*140:vdisys
770   return
780   rem ############# abspeichern ########################
790   speichern:
800   open "O",#1,"color.bas",128:z=20000
810   ?#1,z;"data";:for i=0 to 2:for c=0 to 2:?#1,farbe(i,c);",";:next c,i
820   ?#1,farbe(3,0);",";farbe(3,1);",";farbe(3,2):z=z+10
830   ?#1,z;"data";:for i=4 to 6:for c=0 to 2:?#1,farbe(i,c);",";:next c,i
840   ?#1,farbe(7,0);",";farbe(7,1);",";farbe(7,2):z=z+10
850   ?#1,z;"data";:for i=8 to 10:for c=0 to 2:?#1,farbe(i,c);",";:next c,i
860   ?#1,farbe(11,0);",";farbe(11,1);",";farbe(11,2):z=z+10
870   ?#1,z;"data";:for i=12 to 14:for c=0 to 2:?#1,farbe(i,c);",";:next c,i
880   ?#1,farbe(15,0);",";farbe(15,1);",";farbe(15,2):z=z+10
890   ?#1,z;"restore 20000":z=z+10
900   ?#1,z;"poke contrl,14:poke contrl+2,0:poke contrl+6,4":z=z+10
910   ?#1,z;"for f=0 to 15:poke intin,f:for c=0 to 2:read farbe":z=z+10
920   ?#1,z;"poke intin+c*2+2,farbe*140:next:vdisys":z=z+10:?#1,z;"next"
930   close #1:return
940   rem ############# Titel ##############################
950   titel:
960   y(1)=20:gosub groesse:p(1)=5:gosub effekt
970   color 11:t$="LEVEL 16":x(1)=10:y(1)=20:p(1)=1:p(2)=1:p(3)=110:gosub text
980   p(1)=17:gosub effekt
990   color 13:t$="FARB-EDITOR":x(1)=140:y(1)=20:p(3)=170:gosub text
1000  y(1)=4:gosub groesse:p(1)=5:gosub effekt
1010  for i=sm to sm+3998 step 8:poke i,not peek(i):next
1020  for i=sm+29760 to sm+32000 step 8:poke i,not peek(i):next
1030  y(1)=6:gosub groesse:p(1)=0:gosub effekt:return
1040  rem ########## Text ausgeben ########################
1050  text:
1060  poke contrl,11:poke contrl+2,2:poke contrl+6,len(t$)+2:poke contrl+10,10
1070  poke intin,p(1):poke intin+2,p(2)
1080  for vdi=1 to len(t$):poke intin+2+vdi*2,asc(mid$(t$,vdi,1)):next
1090  poke ptsin,x(1):poke ptsin+2,y(1):poke ptsin+4,p(3):vdisys
1100  return
1110  rem ########## Text-Effekte ###########################
1120  effekt:
1130  poke contrl,106:poke contrl+2,0:poke contrl+6,1:poke intin,p(1):vdisys
1140  return
1150  rem ########### Text-Grîûe ############################
1160  groesse:
1170  poke contrl,12:poke contrl+2,1:poke contrl+6,0:poke ptsin,0
1180  poke ptsin+2,y(1):vdisys
1190  return
1200  rem ########## Rechteck zeichnen #######################
1210  recht:
1220  poke contrl,11:poke contrl+2,2:poke contrl+6,0:poke contrl+10,1
1230  poke ptsin,x(1):poke ptsin+2,y(1):poke ptsin+4,x(2):poke ptsin+6,y(2)
1240  vdisys
1250  return
1260  rem ########## Polygon zeichnen #########################
1270  polyline:
1280  poke contrl,6:poke contrl+2,p(1):poke contrl+6,0
1290  for vdi=1 to p(1):poke ptsin+(vdi-1)*4,x(vdi):poke ptsin+vdi*4-2,y(vdi)
1300  next:vdisys
1310  return
1320  rem ################## Maus-Abfrage ####################
1330  maus:
1340  poke contrl,124:poke contrl+2,0:poke contrl+6,0:vdisys
1350  xmaus=peek(ptsout):ymaus=peek(ptsout+2):button=peek(intout)
1360  return
1370  rem ################# Maus anschalten ##################
1380  mausan:
1390  poke contrl,122:poke contrl+2,0:poke contrl+6,1:poke intin,0:vdisys
1400  return
1410  rem ################# Maus ausschalten #################
1420  mausaus:
1430  poke contrl,123:poke contrl+2,0:poke contrl+6,0:vdisys
1440  return
1450  rem ########### Farbwerte ermitteln ####################
1460  fread:
1470  poke contrl,26:poke contrl+2,0:poke contrl+6,2:poke intin+2,0
1480  for f=0 to 15:poke intin,f:vdisys
1490  for c=0 to 2
1500  if peek(intout+2*c+2)<71 then farbe(f,c)=0:goto 1580
1510  if peek(intout+2*c+2)<214 then farbe(f,c)=1:goto 1580
1520  if peek(intout+2*c+2)<357 then farbe(f,c)=2:goto 1580
1530  if peek(intout+2*c+2)<500 then farbe(f,c)=3:goto 1580
1540  if peek(intout+2*c+2)<643 then farbe(f,c)=4:goto 1580
1550  if peek(intout+2*c+2)<786 then farbe(f,c)=5:goto 1580
1560  if peek(intout+2*c+2)<929 then farbe(f,c)=6:goto 1580
1570  farbe(f,c)=7
1580  next:next:return
1590  rem ######### Standardfarben setzen #############
1600  startcolor:
1610  data 7 , 7 , 7 , 0 , 0 , 0 , 7 , 0 , 0 , 0 , 7 , 0 
1620  data 0 , 0 , 7 , 0 , 0 , 5 , 5 , 2 , 0 , 0 , 5 , 0 
1630  data 5 , 5 , 5 , 2 , 2 , 2 , 0 , 7 , 7 , 0 , 5 , 5 
1640  data 7 , 0 , 7 , 5 , 0 , 5 , 7 , 7 , 0 , 5 , 5 , 0 
1650  restore 1610
1660  poke contrl,14:poke contrl+2,0:poke contrl+6,4
1670  for f=0 to 15:poke intin,f:for c=0 to 2:read farbe
1680  poke intin+c*2+2,farbe*140:next:vdisys
1690  next:return
