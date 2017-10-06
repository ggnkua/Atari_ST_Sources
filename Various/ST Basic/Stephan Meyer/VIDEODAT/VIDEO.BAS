1     'a=inp(2):print a:goto 1
1000  dim ti$(200),bd$(200),ln$(200),fa$(200),ja$(200),hd$(200),ad$(200)
1010  dim s$(2,8),p$(10):width lprint 136:width 80:o$=string$(2,32)
1020  dn=1:de=200:l$=string$(55,32):goto 1440
1030  nr:restore 3660
1040  for po=1 to 4:read pd$:gotoxy 1,po+2:?pd$:next:return
1050  bild:restore 3730
1060  for i=1 to 80 step 4:read x1,y1,x2,y2:linef x1,y1,x2,y2:next
1070  restore 3720:for po=1 to 7:read po$:gotoxy 1,11+po:?po$:next:return
1080  clr:for j=2 to 9:gotoxy 2,j:print string$(71,32):next:return
1090  an:for j=1 to zi:read x,y,z$:gotoxy x,y:print z$:next:return
1100  sg:poke contrl,106:poke contrl+2,0:poke contrl+6,1:poke intin,4
1110  vdisys
1120  poke contrl,107:poke contrl+2,0:poke contrl+6,1:poke intin,18
1130  vdisys
1140  for i=1 to len(p$):poke intin+(i-1)*2,asc(mid$(p$,i,1)):next i
1150  poke intin+(i-1)*2,0:poke contrl,8:poke contrl+2,1
1160  poke contrl+6,len(p$)+1:poke ptsin,x:poke ptsin+2,y(2)/4
1170  vdisys
1180  goto 1220
1190  sc:poke contrl,106:poke contrl+2,0:poke contrl+6,1:poke intin,4
1200  vdisys
1210  return
1220  no:poke contrl,106:poke contrl+2,0:poke contrl+6,1:poke intin,0:h=10
1230  vdisys
1240  poke contrl,107:poke contrl+2,0:poke contrl+6,1:poke intin,h
1250  vdisys
1260  return
1270  tas:if i=199 then 3320:if i=225 then 1510
1280  if i=210 and lad=1 then 1860:return
1290  z$(0)="Honey ROM Software presents":x(0)=215:y(0)=120:v(0)=9
1300  z$(1)="V i d e o f i l m d a t e i":x(1)=92:y(1)=180:v(1)=20
1310  z$(2)=chr$(189)+" by  Ludger M"+chr$(132)+"sing":x(2)=168:y(2)=240
1320  z$(3)="Press any Key to start Program":x(3)=190:y(3)=350:v(3)=9
1330  z$(4)="Version  IV  23.12.85":x(4)=390:y(4)=270:v(4)=9:v(2)=18
1340  gosub sc:for anz=0 to 5:h=v(anz):gosub 1240
1350  for i=1 to len(z$(anz)):poke intin+(i-1)*2,asc(mid$(z$(anz),i,1)):next
1360  poke intin+(i-1)*2,0:poke contrl,8:poke contrl+2,1
1370  poke contrl+6,len(z$(anz))+1:poke ptsin,x(anz):poke ptsin+2,y(anz)
1380  vdisys
1390  next anz:gosub no:restore 3810
1400  for j=1 to 32 step 4:read x1,y1,x2,y2:linef x1,y1,x2,y2:next j:return
1410  '
1420  ' Hauptprogramm
1430  '
1440  fullw 2:clearw 2
1450  restore 3630:for po=1 to 10:read p$(po):next
1460  restore 3680:for p1=1 to 2:for p2=1 to 8:read i$:s$(p1,p2)=i$
1470  next p2:next p1:gosub 1290:gemsys(20):option base 1
1480  open "R",2,"A:VDAT.DAT",170
1490  field#2,45 as a$,6 as b$,18 as c$,35 as d$,4 as e$,50 as f$,12 as g$
1500  gosub 1660
1510  clearw 2:p$=p$(1):x=20:gosub sg
1520  p$=p$(2):x=350:gosub sg:gosub no:gosub sc
1530  gosub bild:restore 3340:zi=4:gosub an:gosub no
1540  yp=3:xp=3:xy=1:if lad=1 then xp=5
1550  gotoxy yp,xp:?chr$(3):i=inp(2):gotoxy yp,xp:?o$
1560  if i=200 then xp=xp-1:if xp<3 then xp=3:goto 1550
1570  if i=208 then xp=xp+1:if xp>6 then xp=6:goto 1550
1580  if i=203 then yp=3:xy=1:goto 1550
1590  if i=205 then yp=19:xy=2:goto 1550
1600  gosub tas:if i=226 then 1610 else 1550
1610  gosub clr:if xy*4-4+xp-2>1 and rec=0 and lad=0 then 1550
1620  v=1:on xy*4-4+xp-2 goto 1660,1750,1930,2310,2690,3010,3210,3320
1630  '
1640  ' Datei Laden
1650  '
1660  p$=p$(3):x=330:gosub sg:gosub no
1670  lad=1
1680  open "I",#1,"A:VREC.DAT":input #1,rec:close #1
1690  for v=1 to rec:get #2,v
1700  ti$(v)=a$:bd$(v)=b$:ln$(v)=c$:fa$(v)=d$:ja$(v)=e$:hd$(v)=f$:ad$(v)=g$
1710  next:return
1720  '
1730  ' Daten hinzufuegen
1740  '
1750  p$=p$(4):x=300:gosub sg:gosub no:gosub sc:gosub no:restore 3380
1760  zi=2:gosub an:gosub nr:gosub no
1770  v=rec+1:for v=v to de:lv=dn*de-de+v
1780  gotoxy 6,4:?using"####";v:gotoxy 6,5:? using "####";lv
1790  gotoxy 6,12:?l$:gotoxy 6,12:input ti$(v):if len(ti$(v))=0 then 1510
1800  if ti$(v)="+" then 1860
1810  gotoxy 6,13:?l$:gotoxy 6,13:input bd$(v):gotoxy 6,14:?l$
1820  gotoxy 6,14:input ln$(v):gotoxy 6,15:?l$:gotoxy 6,16:?l$
1830  gotoxy 6,15:input fa$(v):gotoxy 6,16:input ja$(v)
1840  gotoxy 6,17:?l$:gotoxy 6,17:input hd$(v):gotoxy 6,18:?l$
1850  gotoxy 6,18:input ad$(v):rec=rec+1:next
1860  open "O",1,"A:VREC.DAT",3:write #1,rec:close 1:for v=1 to rec
1870  lset a$=ti$(v):lset b$=bd$(v):lset c$=ln$(v):lset d$=fa$(v)
1880  lset e$=ja$(v):lset f$=hd$(v):lset g$=ad$(v):put #2,v:next
1890  goto 1510
1900  '
1910  ' Daten veraendern
1920  '
1930  p$=p$(5):x=300:gosub sg:gosub no:gosub sc:restore 3400
1940  zi=6:gosub an:gosub no:gosub nr:yp=18:xp=4
1950  gotoxy 1,9:?m$:if v<1 then v=1
1960  if v>rec then gosub 2020:v=v-1
1970  if mid$(ti$(v),1,5)=" "then gosub 2020:v=v-1:goto 2030 else 1980
1980  gotoxy 7,4:? using "####";dn*de-de+v:gotoxy 7,5:? using"####";v
1990  gotoxy 7,12:?ti$(v):gotoxy 7,13:?bd$(v):gotoxy 7,14:?ln$(v)
2000  gotoxy 7,15:?fa$(v):gotoxy 7,16:?ja$(v):gotoxy 7,17:?hd$(v)
2010  gotoxy 7,18:?ad$(v):goto 2030
2020  return
2030  gotoxy yp,xp:?chr$(3):i=inp(2):gotoxy yp,xp:?o$
2040  if i=200 then xp=xp-1:if xp<3 then xp=3:goto 2030
2050  if i=208 then xp=xp+1:if xp>8 then xp=8:goto 2030
2060  gosub tas:if i=226 then 2070 else 2030
2070  on xp-2 goto 2120,2110,2090,2130,1510,1860
2080  goto 2030
2090  gotoxy 6,9:input "Satz ";sa:gotoxy 6,9:?l$
2100  if sa>rec then 2090 else v=sa:goto 1950
2110  v=v+1:goto 1950
2120  v=v-1:goto 1950
2130  for d=3 to 8:gotoxy 23,d:?string$(25,32):next:gosub sc
2140  restore 3460:zi=6:gosub an:gosub no
2150  yp=18:xp=3
2160  gotoxy yp,xp:?chr$(3):i=inp(2):gotoxy yp,xp:?o$
2170  if i=200 then xp=xp-1:if xp<3 then xp=3:goto 2160
2180  if i=208 then xp=xp+1:if xp>8 then xp=8:goto 2160
2190  gosub tas:if i=226 then 2200 else 2160
2200  on xp-2 goto 2210,2220,2230,2240,2260,2270
2210  gotoxy 6,12:input ti$(v):gotoxy 6,12:?l$:goto 1930
2220  gotoxy 6,13:input bd$(v):gotoxy 6,13:?l$:goto 1930
2230  gotoxy 6,14:input ln$(v):gotoxy 6,14:?l$:goto 1930
2240  gotoxy 6,15:input fa$(v):gotoxy 6,15:?l$
2250  gotoxy 6,16:input ja$(v):gotoxy 6,16:?l$:goto 1930
2260  gotoxy 6,17:input hd$(v):gotoxy 6,17:?l$:goto 1930
2270  gotoxy 6,18:input ad$(v):gotoxy 6,18:?l$:goto 1930
2280  '
2290  ' Daten suchen
2300  '
2310  p$=p$(6):x=320:gosub sg:gosub no:gosub sc:restore 3480
2320  zi=6:gosub an:gosub no:yp=20:xp=3
2330  gotoxy yp,xp:?chr$(3):i=inp(2):gotoxy yp,xp:?o$
2340  if i=200 then xp=xp-1:if xp<3 then xp=3:goto 2330
2350  if i=208 then xp=xp+1:if xp>7 then xp=7:goto 2330
2360  gosub tas:if i=226 then 2370 else 2330
2370  if xp-1=6 then 1510
2380  if xp-1<>5 then 2480
2390  gosub clr:gosub sc:restore 3510:zi=8:gosub an:gosub no
2400  yp=3:xp=2:xy=1
2410  gotoxy yp,xp:?chr$(3):i=inp(2):gotoxy yp,xp:?o$
2420  if i=200 then xp=xp-1:if xp<2 then xp=2:goto 2410
2430  if i=208 then xp=xp+1:if xp>9 then xp=9:goto 2410
2440  if i=203 then yp=3:xy=1:goto 2410
2450  if i=205 then yp=19:xy=2:goto 2410
2460  gosub tas:if i=226 then 2470 else 2410
2470  j$=s$(xy,xp-1):xx=6:goto 2490
2480  xx=xp:gotoxy 5,9:?"gesucht wird :":gotoxy 13,09:input j$:gotoxy 5,9:?l$
2490  for v=1 to rec:on xx-2 goto 2500,2510,2520,2570
2500  if left$(j$,5)=left$(ti$(v),5) then 2620 else 2650
2510  if left$(j$,4)=left$(bd$(v),4)then 2620 else 2650
2520  l=instr(1,hd$(v),"  "):l=l-1:a$=left$(hd$(v),l)
2530  for h=1 to 5:f=instr(1,a$,"."):if f<=1 then 2650
2540  ah$=left$(a$,f-1):if ah$=j$ then 2620
2550  ai$=mid$(a$,f+1,l-f):a$=ai$
2560  next h:goto 2650
2570  z=instr(1,fa$(v)," "):z=z+1:zz=instr(1,fa$(v),"   ")
2580  on xp-1 goto 2600,2600,2610,2610,2600,2600,2600,2610
2590  on xp-1 goto 2600,2600,2610,2600,2600,2600,2600,2600
2600  if mid$(fa$(v),z,zz-z)=j$ then 2620 else 2650
2610  if left$(fa$(v),z-2)=j$ then 2620 else 2650
2620  gotoxy 6,12:?ti$(v):gotoxy 6,13:?bd$(v):gotoxy 6,14:?ln$(v)
2630  gotoxy 6,15:?fa$(v):gotoxy 6,16:?ja$(v):gotoxy 6,17:?hd$(v)
2640  gotoxy 6,18:? ad$(v):gemsys(20)
2650  next:gosub clr:goto 2310
2660  '
2670  ' Daten sortieren
2680  '
2690  p$=p$(7):x=300:gosub sg:gosub no:gosub sc:restore 3590
2700  zi=8:gosub an:gosub no:yp=22:xp=3
2710  gotoxy yp,xp:?chr$(3):i=inp(2):gotoxy yp,xp:?o$
2720  if i=200 then xp=xp-1:if xp<3 then xp=3:goto 2710
2730  if i=208 then xp=xp+1:if xp>9 then xp=9:goto 2710
2740  gosub tas:if i=226 then 2750 else 2710
2750  if xp-2=9 then 1510
2760  n=rec:gotoxy yp,xp:?chr$(3)
2770  m=n
2780  t=m/2:m=int(t):if m=0 then 1510
2790  k=n-m
2800  j=1
2810  i=j
2820  l=i+m
2830  on xp-2 goto 2840,2850,2860,2870,2880,2890
2840  if ti$(i)<=ti$(l) then 2970 else 2900
2850  if bd$(i)<=bd$(l) then 2970 else 2900
2860  if left$(ln$(i),4)<=left$(ln$(l),4) then 2970 else 2900
2870  if ja$(i)<=ja$(l) then 2970 else 2900
2880  if right$(ad$(i),3)<=right$(ad$(l),3) then 2970 else 2900
2890  if ad$(i)<=ad$(l) then 2970
2900  f$(1)=ti$(i):f$(2)=bd$(i):f$(3)=ln$(i)
2910  f$(4)=fa$(i):f$(5)=ja$(i):f$(6)=hd$(i):f$(7)=ad$(i)
2920  ti$(i)=ti$(l):bd$(i)=bd$(l):ln$(i)=ln$(l)
2930  fa$(i)=fa$(l):ja$(i)=ja$(l):hd$(i)=hd$(l):ad$(i)=ad$(l)
2940  ti$(l)=f$(1):bd$(l)=f$(2):ln$(l)=f$(3)
2950  fa$(l)=f$(4):ja$(l)=f$(5):hd$(l)=f$(6):ad$(l)=f$(7)
2960  i=i-m:if i>=1 then 2820
2970  j=j+1:if j>k then 2780 else 2810
2980  '
2990  ' Daten drucken
3000  '
3010  p$=p$(8):x=310:gosub sg:gosub no
3020  out 0,15 :out 0,27:out 0,65:out 0,12
3030  lprint tab(43);chr$(14);z$(1)
3040  for v=1 to rec step 3
3050  if (v-1)/21=int((v-1)/21) then 3060 else 3070
3060  out 0,10:s=s+1:lprint tab(50);chr$(14);"S e i t e  -";s;" -":out 0,10
3070  lprint tab(13);dn*de-de+v;tab(55);dn*de-de+v+1;tab(97);dn*de-de+v+2
3080  lprint tab(13);mid$(ti$(v),1,35);tab(55);mid$(ti$(v+1),1,35);
3090  lprint tab(97);mid$(ti$(v+2),1,35)
3100  lprint tab(13);bd$(v);tab(55);bd$(v+1);tab(97);bd$(v+2)
3110  lprint tab(13);ln$(v);tab(55);ln$(v+1);tab(97);ln$(v+2)
3120  lprint tab(13);fa$(v);tab(55);fa$(v+1);tab(97);fa$(v+2)
3130  lprint tab(13);ja$(v);tab(55);ja$(v+1);tab(97);ja$(v+2)
3140  lprint tab(13);left$(hd$(v),35);tab(55);left$(hd$(v+1),35);
3150  lprint tab(97);left$(hd$(v+2),35)
3160  lprint tab(13);ad$(v);tab(55);ad$(v+1);tab(97);ad$(v+2):out 0,10
3170  next:goto 1510
3180  '
3190  ' Daten anzeigen
3200  '
3210  p$=p$(9):x=300:gosub sg:gosub no:gosub nr
3220  for v=1 to rec
3230  gotoxy 6,4:?using"####";dn*de-de+v:gotoxy 6,5:?using"####";v
3240  gotoxy 6,12:?ti$(v):gotoxy 6,13:?bd$(v):gotoxy 6,14:?ln$(v)
3250  gotoxy 6,15:?fa$(v):gotoxy 6,16:?ja$(v):gotoxy 6,17:?hd$(v)
3260  gotoxy 6,18:?ad$(v)
3270  for i=1 to 10:next
3280  next:gemsys(20):goto 1510
3290  '
3300  ' Programm beenden
3310  '
3320  gosub no:clearw 2:close #2:end
3330  '---------------------------------------------------------------------
3340  data 04,03,1   --->  Datei laden             5  --->  Datei sortieren
3350  data 04,04,2   --->  Daten eingeben          6  --->  Daten drucken
3360  data 04,05,3   --->  Daten veraendern        7  --->  Daten anzeigen
3370  data 04,06,4   --->  Daten suchen            8  --->  Programm beenden
3380  data 12,03,Eingabe von Videofilmtitel Cassettennummer Laenge
3390  data 12,04,Filmart Jahr Hauptdarsteller Aufnahmedatum Sender
3400  data 19,3,'1' --->  blaettern rueckwaerts
3410  data 19,4,'2' --->  blaettern vorwaerts
3420  data 19,5,'3' --->  Datensatzvorwahl
3430  data 19,6,'4' --->  korrigieren
3440  data 19,7,'5' --->  Menue o. speichern
3450  data 19,8,'6' --->  Menue m. speichern
3460  data 23,3," Titel",23,4," Band",23,5," Laenge",23,6," Art"
3470  data 23,7," Hauptdarsteller",23,8," Datum"
3480  data 03,04,Wonach soll gesucht werden ?,22,03,'1' --->  Titel
3490  data 22,04,'2' --->  Band,22,05,'3' --->  Hauptdarsteller
3500  data 22,06,'4' --->  Art,22,07,'5' --->  Menue
3510  data 04,02,'1' --->  Abenteuerfilm           '1' --->  Katastrophenfilm
3520  data 04,03,'2' --->  Actionfilm              '2' --->  Maerchenfilm
3530  data 04,04,'3' --->  Dokumentarfilm          '3' --->  Musik
3540  data 04,05,'4' --->  Fernsehfilm             '4' --->  Musikfilm
3550  data 04,06,'5' --->  Filmkomoedie            '5' --->  Science Fiction
3560  data 04,07,'6' --->  Filmmusical             '6' --->  Spielfilm
3570  data 04,08,'7' --->  Heimatfilm              '7' --->  Thriller
3580  data 04,09,'8' --->  Historienfilm           '8' --->  Western
3590  data 02,05,Welches Feld soll sortiert werden ?
3600  data 23,03,'1' --->  Titel,23,04,'2' --->  Band,23,05,'3' --->  Laenge
3610  data 23,06,'4' --->  Jahr,23,07,'5' --->  Fernsehsender
3620  data 23,08,'6' --->  Aufnahmedatum,23,09,'7' --->  Menue
3630  data Videofilmdatei,M e n u e,Datei   laden,Daten   eingeben
3640  data Daten   veraendern,Daten   suchen,Daten   sortieren
3650  data Daten   drucken,Daten   anzeigen,Programm   beenden
3660  data +--------------------+,|  lfd nr.           |
3670  data |      nr.           |,+--------------------+
3680  data "Abenteuerfilm","Actionfilm","Dokumentarfilm","Fernsehfilm"
3690  data "Filmkomoedie","Filmmusical","Heimatfilm","Historienfilm"
3700  data "Katastrophenfilm","Maerchenfilm","Musik","Musikfilm"
3710  data "Science Fiction","Spielfilm","Thriller","Western"
3720  data Titel,Band,Laenge,Art,Jahr,Hdarst,Datum
3730  data 013,204,600,204,013,205,600,205,013,223,600,223
3740  data 013,240,600,240,013,257,600,257,013,274,600,274
3750  data 013,291,600,291,013,308,600,308,013,325,600,325
3760  data 013,326,600,326,012,204,012,326,013,204,013,326
3770  data 080,204,080,326,081,204,081,326,600,204,600,326
3780  data 601,204,601,326
3790  data 000,030,640,030,000,031,640,031,000,187,640,187
3800  data 000,188,640,188
3810  data 065,060,560,060,560,060,560,237,560,237,065,237
3820  data 065,237,065,060,062,057,563,057,563,057,563,240
3830  data 563,240,062,240,062,240,062,057
