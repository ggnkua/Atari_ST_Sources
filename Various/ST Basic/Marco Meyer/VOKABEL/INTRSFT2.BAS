10    '|=====================================================================|
20    '|   Vokabelprogramm                                    Version 1.0    |
30    '|                                                                     |
40    '|                                                                     |
50    '|     >>>>>>>>>>>>>>>>>>>>>>> INTERSOFT <<<<<<<<<<<<<<<<<<<<<<        |
60    '|                                                                     |
70    '|                           in April 1986                             |
80    '|                                                                     |
90    '|               ~ all rights reserved by Marco Meyer ~                |
91    '|                                                                     |
92    '|                                                                     |
93    '|=====================================================================|
94    clearw 2:?" Diese Version belegt ~30Kb!":? "...Gruesse von Intersoft!"
95    ?:?:?:?:?" Warten Sie bitte...":?:?"...tra la la laaaa..."
96    gosub full
97    for z=1 to 5000:next z
98    out 4,18
100   clearw 2
105   color 1,1,1,8,2
110   xp1=1-1:yp1=1-41+19:xp2=640+1:yp2=1-21+19:gosub re
135   option base 1
140   dim ev$(201),dv$(201)
150   for i=1 to 200:ev$(i)=" ":dv$(i)=" ":next i
170   gosub rahmen
175   color 1,1,1,0,0
180   g=9:gosub sg:xp=100:yp=355
190   md=3:gosub graphik
200   t$=" INTERSOFT"+chr$(190)+" alle Rechte vorbehalten bei Marco Meyer"
210   gosub ta:md=1:gosub graphik
220   color 1,1,1,4,2:xp1=1:yp1=1:xp2=616:yp2=345:gosub re
230   color 1,1,1,8,2:xp1=110:yp1=60 :xp2=510:yp2=260:gosub re
240   color 1,1,1,0,0:xp1=100:yp1=50 :xp2=500:yp2=250:gosub re
250   color 1,1,1,8,2:xp1=135:yp1=82:xp2=475:yp2=115:gosub re
260   color 1,1,1,2,2:xp1=130:yp1=77 :xp2=470:yp2=110:gosub re
270   g=20:gosub sg:xp=163:yp=105:t$=" VOKABELN LERNEN":gosub ta:g=10:gosub sg
280   st=4:gosub sa:xp=220:yp=160:t$="...mit INTERSOFT"+chr$(190)
290   gosub ta:st=0:gosub sa
300   color 1,1,1,8,2:xp1=133:yp1=203:xp2=473:yp2=220:gosub re
310   color 1,1,1,2,2:xp1=130:yp1=200:xp2=470:yp2=217:gosub re
320   xp=190:yp=214:t$=" CLICKEN SIE DIESEN BALKEN!":gosub ta
330   out 4,8
340   gosub zeiger
350   if x>130 and x<470 and y>199 and y<217 then gosub info else 340
352   out 4,18
355   linef 1,1,1,1
360   goto 660
370   '------------------------------------------
380   ve:
390   gosub hintergrund:t$=" VOKABELEINGABE":xp=240:yp=58:gosub ta
400   st=4:gosub sa
410   gotoxy 10,16:?"ZUM BEENDEN GEBEN SIE BITTE ...  #"
420   st=0:gosub sa
430   gotoxy 10,8:?"Deutsch :"
440   gotoxy 10,10:?"Englisch:"
450   color 1,1,1,0,0:xp1=337:yp1= 87:xp2=540:yp2= 97:gosub re
470   for i=anzahl+1 to 200
490   color 1,1,1,2,2:xp1=337:yp1= 87:xp2=338+i:yp2= 97:gosub re
500   g=3:gosub sg
510   gotoxy 30,4:?i-1
520   g=10:gosub sg
530   gotoxy 9 ,8:?"Deutsch:   "+chr$(3)+"                         "+chr$(4)
540   gotoxy 9 ,10:?"Englisch:  "+chr$(3)+"                         "+chr$(4)
550   gotoxy 15,8:line input dv$(i)
560   if left$(dv$(i),1)="#" then anzahl=i-1:goto 640
570   gotoxy 15,10:line input ev$(i)
580   next i
590   st=16:gosub sa:g=5:gosub sg
600   t$="VOKABELSPEICHER IST VOLL!":xp=340:yp=117:gosub ta
610   t$=". . . #!":xp=407:yp=137:gosub ta
620   st=0:gosub sa:g=10:gosub sg
630   gotoxy 15,8:line input a$:if left$(a$,1)<>"#" then 630
640   return
650   '------------------------------------------
660   color 1,1,1,4,2
690   xp1=1:yp1=1:xp2=615:yp2=345:gosub re
700   color 1,1,1,0,0
710   xp1=42:yp1=22:xp2=563:yp2=318:gosub re
720   xp1=45:yp1=25:xp2=560:yp2=315:gosub re
730   color 1,1,1,8,2
740   xp1=65:yp1=47:xp2=540:yp2=64:gosub re
750   color 1,1,1,2,2
760   xp1=62:yp1=44:xp2=537:yp2=61:gosub re
770   t$=" HAUPTMEN"+chr$(154)+" ":xp=250:yp=58:gosub ta
780   g=9:gosub sg
790   gotoxy  8,5:?chr$(17);"   -------------------> Vokabeleingabe....."
800   gotoxy  8,6:?chr$(18);"   -------------------> Vokabelausgabe....."
810   gotoxy  8,7:?chr$(19);"   -------------------> Vokabel drucken...."
820   gotoxy  8,8:?chr$(20);"   -------------------> Vokabel berichtigen"
830   gotoxy  8,9:?chr$(21);"   -------------------> Vokabel speichern.."
840   gotoxy  8,10:?chr$(22);"   -------------------> Vokabel laden......"
850   gotoxy  8,11:?chr$(23);"   -------------------> Datei loeschen....."
860   gotoxy  8,12:?chr$(24);"   -------------------> Vokabeln abfragen.."
870   gotoxy  8,13:?chr$(25);"   ------------------->         ENDE"
880   g=10:gosub sg
900   gotoxy 8,16:input"         Ihre Wahl :",wahl
910   on wahl gosub ve,va,vd,vb,vs,vl,dl,vf,e
920   if wahl <1 or wahl >9 then gotoxy 13,16:?"        ":goto 900
930   goto 660
940   '------------------------------------------
950   va:
960   gosub hintergrund:t$=" VOKABELAUSGABE":xp=240:yp=58:gosub ta
970   if anzahl/2<>int(anzahl/2) then ev$(anzahl+1)="":dv$(anzahl+1)=""
980   for i=1 to anzahl
990   q=q+1:if q>10 then q=1:for z=1 to 10:gotoxy 8,z+4:?spc(15):next z
1000  if z>9 then z=0:for z=1 to 10:gotoxy 20,z+4:?spc(15):next z
1010  if z>9 then z=0:for z=1 to 10:gotoxy 4,z+4:?spc(4):next z
1020  g=3:gosub sg:gotoxy 4,q+4:?i:g=10:gosub sg
1030  gotoxy 8,q+4:?dv$(i):gotoxy 20,q+4:?ev$(i)
1040  st=2:gosub sa
1050  if i=10+k then k=k+10:gotoxy 12,16:line input"Mehr Vokabeln mit <CR> ",a$
1060  z=0:st=0:gosub sa
1070  next i
1080  st=4:gosub sa
1090  gotoxy 11,16:input"ZurÅck ins Menu mit <CR> ",a$
1100  st=0:gosub sa
1110  k=0:q=0:return
1120  '------------------------------------------
1130  vd:
1140  gosub hintergrund:t$=" DRUCKEN FX-80":xp=245:yp=58:gosub ta
1150  st=4:gosub sa:gotoxy 12,16:?"ZurÅck ins Menu mit...#":st=0:gosub sa
1160  g=6:st=16:gosub sg:gosub sa
1170  xp=431:yp=107:t$="--.--.--":gosub ta
1180  st=0:gosub sa:g=10:gosub sg
1190  gotoxy 22,5:line input"Datum: ",a$
1200  g=6:st=16:gosub sg:gosub sa
1210  xp=240:yp=160:t$="-------------------------":gosub ta
1220  g=10:gosub sg:st=0:gosub sa
1230  gotoxy 8,8:line input"öberschrift: ",txt$
1240  if left$(txt$,1)="#" then goto 660
1250  lprint chr$(27);"C";chr$(72);
1260  lprint chr$(27);chr$(15);
1270  lprint"VOKABELN LERNEN MIT INTERSOFT!";
1280  lprint chr$(18);
1290  lprint
1300  lprint chr$(27);"E";txt$;"                      ";a$;:lprint chr$(27);"F";
1310  lprint
1320  for i=1 to anzahl
1330  lprint;
1340  if i<10 then lprint i;"     ";dv$(i)
1350  if i>=10 and i<100 then lprint i;"    ";dv$(i)
1360  if i>=100 then lprint i;"   ";dv$(i)
1370  lprint"        ";ev$(i)
1380  lprint chr$(27);"N";chr$(10);
1390  next i
1400  for i=1 to 5:next i
1410  lprint chr$(12);
1420  for i=1 to 10:lprint chr$(7);:next i
1430  return
1440  '--------------------------------------------
1450  vs:
1460  gosub hintergrund:t$=" AUF DISKETTE":xp=245:yp=58:gosub ta
1470  st=4:gosub sa:gotoxy 12,16:?"ZurÅck ins Menu mit...#":st=0:gosub sa
1480  g=6:st=16:gosub sg:gosub sa
1490  xp=225:yp=160:t$="--------.---":gosub ta
1500  g=10:st=0:gosub sg:gosub sa
1505  st=2:gosub sa:xp=287:yp=153:t$=".vok":gosub ta:st=0:gosub sa
1510  gotoxy 8,8:line input"Dateiname: ",dat$
1512  dat$=dat$+".vok"
1520  if left$(dat$,1)="#" then 660
1530  on error goto 1640
1540  open"O",#1,dat$
1550  on error goto 1640
1560  print#1,anzahl
1570  for i=1 to anzahl
1580  print#1,dv$(i)
1590  print#1,ev$(i)
1600  on error goto 1640
1610  next i
1620  close #1
1630  goto 660
1640  st=16:gosub sa:xp=130:yp=200:t$="E R R O R ! ! !  - N O C H M A L -"
1650  gosub ta:for i=1 to 3000:next:st=0:gosub sa:resume 1460
1660  return
1670  '-------------------------------------------
1680  vl:
1690  gosub hintergrund:t$=" VON DISKETTE":xp=245:yp=58:gosub ta
1700  g=9:gosub sg
1710  xp=110:yp=100:t$="VOKABELN IM SPEICHER WERDEN BEIM LADEN GELôSCHT!"
1720  gosub ta:g=10:gosub sg:st=4:gosub sa
1730  gotoxy 12,16:?"ZurÅck ins Menu mit...#":st=0:gosub sa
1740  g=6:st=16:gosub sg:gosub sa
1750  xp=305:yp=160:t$="--------.---":gosub ta
1752  g=10:st=0:gosub sg:gosub sa
1753  st=2:gosub sa:xp=367:yp=153:t$=".vok":gosub ta:st=0:gosub sa
1755  for i=1 to anzahl
1756  dv$(i)=" ":ev$(i)=" ":next i
1770  gotoxy 8,8:line input"gesuchter Dateiname: ",dat$
1775  dat$=dat$+".vok"
1780  if left$(dat$,1)="#" then 660
1790  on error goto 1920
1820  close:open"I",#1,dat$
1830  on error goto 1920
1840  input#1,anzahl
1850  u=u+1
1870  input#1,dv$(u)
1880  input#1,ev$(u)
1885  on error goto 1920
1890  if not eof(1) then goto 1850
1900  close #1
1905  u=0
1910  goto 660
1920  st=16:gosub sa:xp=150:yp=200:t$="E R R O R ! ! !  - N O C H M A L -"
1930  gosub ta:for i=1 to 3000:next i:st=0:gosub sa:resume 1690
1940  return
1950  '---------------------------------------
1960  e:
1965  out 4,8:linef 1,1,1,1
1970  gosub hintergrund:t$=" BEENDEN":xp=250:yp=58:gosub ta
1980  g=9:gosub sg
1990  xp=125:yp=100:t$="WENN SIE BEENDEN WOLLEN, DANN GEBEN SIE <JA>!"
2000  gosub ta:g=10:gosub sg
2010  st=4:gosub sa:gotoxy 12,16:?"ZurÅck ins Menu mit... #":st=0:gosub sa
2020  gotoxy 8,8:line input"Programmende: ",a$
2030  if left$(a$,2)="JA" or left$(a$,2)="ja" then end
2040  return
2050  '----------------------------------------
2060  vb:
2070  gosub hintergrund:t$=" VOKABEL éNDERN":xp=240:yp=58:gosub ta
2080  g=9:gosub sg:xp=80:yp=90
2090  t$="BEANTWORTEN SIE ALLE FRAGEN(!) MIT <JA> ODER MIT <NEIN>!":gosub ta
2100  g=10:gosub sg
2110  gotoxy 8,6:input"Zu Ñndernde Vokabelnummer: ",vokn
2120  if vokn<1 or vokn>anzahl then 2070
2130  st=2:gosub sa:gotoxy 8,8:?"Deutsch :  ";dv$(vokn)
2140  gotoxy 8,10:?"Englisch:  ";ev$(vokn):st=0:gosub sa
2150  gotoxy 23,8:input"---> éNDERN? ",ant$
2160  if ant$="NEIN" or ant$="nein" then 2200
2170  g=9:gosub sg
2180  st=4:gosub sa:gotoxy 8,9:input"Neue Vok:  ",dv$(vokn):st=0:gosub sa
2190  g=10:gosub sg
2200  gotoxy 23,10:input"---> éNDERN?: ",ant$
2210  if ant$="NEIN" or ant$="nein" then 2250
2220  g=9:gosub sg
2230  st=4:gosub sa:gotoxy 8,11:input"Neue Vok:  ",ev$(vokn):st=0:gosub sa
2240  g=10:gosub sg
2250  st=4:gosub sa:gotoxy 12,16:?"ZurÅck ins Menu mit ...# ":st=0:gosub sa
2260  gotoxy 8,13:input"Noch eine Vokabel Ñndern ... ",ant$
2270  if left$(ant$,1)="#" then return
2280  goto 2070
2290  '--------------------------------------------
2300  dl:
2310  gosub hintergrund:t$=" DATEI LôSCHEN":xp=245:yp=58:gosub ta
2320  g=6:st=16:gosub sg:gosub sa
2330  xp=336:yp=160:t$="--------.---":gosub ta
2340  st=0:g=10:gosub sa:gosub sg
2350  gotoxy 8,8:line input"Zu lîschender Dateiname: ",datn$
2360  st=4:gosub sa:gotoxy 10,16:?"Sie kînnen sich noch mit...# retten!"
2370  st=0:gosub sa
2380  gotoxy 8,9:?spc(50)
2390  gotoxy 8,8:line input"Sind Sie sich wirklich sicher... dann <CR> ",ant$
2400  if left$(ant$,1)="#" then 2510
2410  xp1=45:yp1=25:xp2=560:yp2=315:gosub re
2420  g=15:gosub sg:st=5:gosub sa
2430  xp=120:yp=200:t$="FILE """+datn$+""" WIRD VON DISKETTE GELôSCHT!":gosub ta
2440  g=10:gosub sg:st=0:gosub sa
2450  on error goto 2590
2460  kill datn$
2470  xp=120:yp=200:t$="FILE """+datn$+""" IST VON DISKETTE GELôSCHT! ":gosub ta
2480  st=4:gosub sa:gotoxy 12,16:input"ZurÅck ins Menu mit <CR> ",a$
2490  st=0:gosub sa
2500  goto 660
2510  qw=1:goto 3120
2520  qw=0:xp=245:yp=58:t$=" DATEI LôSCHEN":gosub ta
2530  gotoxy 12,8:?chr$(17);"  ZurÅck ins Menu......"
2540  gotoxy 12,10:?chr$(18);"  Doch noch lîschen...."
2550  gotoxy 14,16:input"Ihre Wahl: ",wahl
2560  if wahl=1 then return
2570  if wahl=2 then 2310
2580  goto 2550
2590  st=16:gosub sa:xp=120:yp=200:t$="   E R R O R !  - N O C H M A L -   "
2600  gosub ta:st=0:gosub sa:for i=1 to 3000:next i:resume 2310
2610  '---------------------------------------
2620  vf:
2630  gosub hintergrund:t$=" VOKABELN ABFRAGEN":xp=235:yp=58:gosub ta
2635  on error goto 10000
2640  gotoxy 11,8:?"A    DEUTSCH  ---> ENGLISCH "
2650  gotoxy 11,10:?"B    ENGLISCH --->  DEUTSCH "
2660  st=4:gosub sa:gotoxy 13,16:?"ZurÅck ins Menu mit... # ":st=0:gosub sa
2670  gotoxy 14,12:input"Ihre Wahl: ",wahl$
2680  f=0:r=0:eng=0:deu=0
2690  if wahl$="A" or wahl$="a" then deu=1:goto 2740
2700  if wahl$="B" or wahl$="b" then eng=1:goto 2740
2710  if wahl$="#" then return
2720  goto 2620
2730  st=4:gosub sa:gotoxy 12,16:?"ZurÅck ins Menu mit... #":st=0:gosub sa
2740  gotoxy 11,8:?spc(40):gotoxy 11,10:?spc(40):gotoxy 14,12:?spc(20)
2750  for p=1 to anzahl
2760  xp=250:yp=150:t$="        ":g=18:gosub sg:gosub ta:g=10:gosub sg
2770  gotoxy 3,9:?spc(63):gotoxy 7,11:?spc(50):gotoxy 7,13:?spc(50)
2780  g=3:gosub sg:gotoxy 4 ,4:?p;". VOKABEL":g=10:gosub sg
2790  if deu=1 then vok$=dv$(p):vok2$=ev$(p)
2800  if eng=1 then vok$=ev$(p):vok2$=dv$(p)
2810  st=2:gosub sa
2820  gotoxy 15,9 :?vok$:st=0:gosub sa
2830  gotoxy 15,11:line input af$
2840  gotoxy 15,9:?spc(35):gotoxy 15,11:?spc(35)
2850  if af$="#" then 2640
2860  if af$<>vok2$ then f=f+1:goto 2880
2870  xp=250:yp=150:t$="RICHTIG":g=18:gosub sg:gosub ta:r=r+1:goto 2900
2880  st=2:gosub sa
2890  gotoxy 4,9 :?"Falsch! Es hÑtte '";vok2$;"' heiûen mÅssen !!"
2900  st=0:gosub sa:g=9:gosub sg
2910  gotoxy 12,11:?"Bisher sind... ";int((r*100)/anzahl);"% richtig!"
2920  gotoxy 12,13:?"und........... ";int((f*100)/anzahl);"% falsch!"
2930  g=10:gosub sg:st=4:gosub sa
2940  gotoxy 8,16:input"NÑchste Vokabel und zur Auswertung mit <CR> ",c$
2950  st=0:gosub sa
2960  next p
2970  gosub hintergrund:xp=245:yp=58:t$=" AUSWERTUNG":gosub ta
2975  st=2:gosub sa
2980  gotoxy 10,7:?"Sie haben ";int((r*100)/anzahl);"% richtig gmacht!"
2990  gotoxy 10,9:?"      und ";int((f*100)/anzahl);"% falsch gemacht!"
3000  st=4:gosub sa:gotoxy 13,16:?"ZurÅck ins Menu mit ...# ":st=0:gosub sa
3010  gotoxy 8 ,13:line input"Na, sitzen alle Vokabeln oder nochmal... <CR> ",a$
3020  if a$="#" then return
3030  goto 2620
3040  '---------------------------------------
3050  hintergrund:
3060  color 1,1,1,4,2
3070  xp1=1:yp1=1:xp2=616:yp2=345
3080  gosub re
3090  color 1,1,1,0,0
3100  xp1=42:yp1=22:xp2=563:yp2=318
3110  gosub re
3120  xp1=45:yp1=25:xp2=560:yp2=315
3130  gosub re
3140  color 1,1,1,8,2
3150  xp1=65:yp1=47:xp2=540:yp2=64:gosub re
3160  color 1,1,1,2,2
3170  xp1=64:yp1=44:xp2=537:yp2=61:gosub re
3180  color 1,1,1,0,0
3190  if qw=1 then 2520
3200  return
3290  '-----------------------------------------
3300  sa:
3310  poke contrl,106
3320  poke contrl+2,0
3330  poke contrl+6,1
3340  poke intin,st
3350  vdisys
3360  return
3370  '-----------------------------------------
3380  sg:
3390  poke contrl,107
3400  poke contrl+2,0
3410  poke contrl+6,1
3420  poke intin,g
3430  vdisys
3440  return
3450  '------------------------------------
3460  ta:
3470  for l=0 to len(t$)-1
3480  poke intin+l*2,asc(mid$(t$,l+1,1))
3490  next l
3500  poke intin+l*2,0
3510  poke contrl,8
3520  poke contrl+2,1
3530  poke contrl+6,len(t$)+1
3540  poke ptsin,xp
3550  poke ptsin+2,yp+19
3560  vdisys
3570  return
3580  '------------------------------------
3590  re:
3600  poke contrl,11
3610  poke contrl+2,2
3620  poke contrl+6,0
3630  poke contrl+10,1
3640  poke ptsin,xp1
3650  poke ptsin+2,yp1+19
3660  poke ptsin+4,xp2
3670  poke ptsin+6,yp2+19
3680  vdisys
3690  return
3700  '------------------------------------
3710  zeiger:
3720  poke contrl,124:poke contrl+2,0:vdisys 0
3730  x=peek(ptsout):y=peek(ptsout+2)-19:t=peek(intout)
3740  if t=0 then goto zeiger
3750  return
3760  '-------------------------------------
3770  info:
3775  linef 1,1,1,1
3777  out 4,18
3780  gosub hintergrund:xp=260:yp=58:t$=" INFO":gosub ta
3790  gotoxy 8,5:?"Dieses Programm wurde entwickelt von..."
3800  gotoxy 15,8:?"INTERSOFT"+chr$(190)
3810  gotoxy 8,11:?"Die Grund-Algorythmen stammen aus der.."
3820  gotoxy 8,12:?"Computerzeitschrift ""ST-COMPUTER""......"
3830  gotoxy 8,13:?"Andere Programme und DIESES unter GEM.."
3840  gotoxy 5,15:?"MARCO MEYER,GERHARD-ROHLFS-STR. 54c,2820 BREMEN 70"
3850  st=4:gosub sa:gotoxy 12,17:input"Programmbeginn mit <CR> ",a$
3860  st=0:gosub sa
3870  return
3880  '------------------------------------
3890  graphik:
3900  poke contrl,32:poke contrl+2,0:poke contrl+6,1
3910  poke intin,md:vdisys
3920  return
3930  '-------------------------------------
4000  full:
4010  a#=gb
4020  control=peek(a#)
4030  global=peek(a#+4)
4040  gintin=peek(a#+8)
4050  gintout=peek(a#+12)
4060  addrin=peek(a#+16)
4070  addrout=peek(a#+20)
4080  poke gintin,3
4090  poke gintin+2,5
4100  poke gintin+4,-1
4110  poke gintin+6,0
4120  poke gintin+8,660
4130  poke gintin+10,419
4140  gemsys 105
4150  return
4160  '------------------------------------
4170  rahmen:
4180  fill 1,1
4190  return
4200  '------------------------------------
10000 leere:
10010 st=16:gosub sa:xp=150:yp=200:t$="K E I N E VOKABELN IM SPEICHER "+chr$(11)
10015 gosub ta:st=1:gosub sa:xp=160:yp=137:t$="            E R R O R !":gosub ta
10020 st=0:gosub sa:for z=1 to 5000:next z:resume 660
