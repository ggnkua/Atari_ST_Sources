10    '  ###################################################################
15    '  ##                      ETIKETTENERSTELLUNG                      ##
20    '  ##                             ****                              ##
25    '  ##                           V1.8(GEM)                           ##
30    '  ##                             von                               ##
35    '  ##                        Gerald Richter                         ##
40    '  ##                        Hainleinstr.62                         ##
45    '  ##                       8721 Niederwerrn                        ##
50    '  ##                          (c) 1986                             ##
55    '  ###################################################################
60    '
65    xpos1=ypos1 =0:xpos2=344:xpos2=615:gosub clipping
70    mausnr=3:gosub mausform
75    on error goto normaleinstellung
80    '--------------------------------------------------------------
85    start:
90    clear:clearw 2:fullw 2:gosub hidemaus:color 1,1,1,2,2:modus=1:gosub            grafikmodus
95    xpos1=18:xpos2=615:ypos1=0:ypos2=-20:gosub rechteck:
100   text$=" Etikett.bas":xpos=280:ypos=-5:gosub textausgabe
105   gosub startmaske:gosub starttext
110   if halt=1 then goto normaleinstellung
115   eingabe:
120   gosub eingabemaske:gosub eingabetext
125   kontrolle:
130   gosub kontrollmaske
135   if halt=1 then goto normaleinstellung
140   if aendern=1 then gosub aenderung:goto kontrolle
145   modus=1:gosub grafikmodus:
150   clearw 2:gosub drucker
155   gosub schlusstext
160   if weiter = 1  then goto eingabe
165   Normaleinstellung:
170   groesse=10:schrifttyp=0:gosub schriftgroesse:gosub schriftart
175   modus=1:gosub grafikmodus:mausnr=0:gosub mausform
180   gosub showmaus
185   end
190   '#####################################################################
195   '====================== Hauptprogrammende ============================
200   '#####################################################################
205   startmaske:
210   xpos1=0:ypos1=0:xpos2=615:ypos2=344: color 1,1,1,11,2:fuell=1
215   gosub rechteck
220   color 1,1,1,0,2 :fuell = 1
225   xpos1=65:xpos2=xpos1+500:ypos1=20:ypos2=60:gosub rechteckrund
230   color 1,1,1,1,0 :fuell=1
235   xpos1=65:xpos2=xpos1+180:ypos1=105:ypos2=ypos1+145:gosub rechteckrund
240   for k=0 to 1
245   xpos1=300+k*150:xpos2=xpos1+78:ypos1=155:ypos2=155+28:fuell=1
250   gosub rechteck:color 1,1,1,1,0
255   xpos1=302+k*150:xpos2=xpos1+74:ypos1=157:ypos2=157+24:fuell=1
260   gosub rechteck
265   next
270   return
275   '====================================================================
280   starttext:
285   groesse=10:schrifttyp=16:gosub schriftart:gosub schriftgroesse
290   text$=" Etikettenerstellung V1.8 (c) G.Richter":xpos=105:ypos=46:
295   gosub textausgabe:schrifttyp=0:gosub schriftart
300   groesse=9:gosub schriftgroesse:ypos=120:xpos=73
305   wort$(1)="Dieses  Programm er-"
310   wort$(2)="stellt   auf   einem"
315   wort$(3)="Drucker, der  epson-"
320   wort$(4)="kompatibel ist,Disk-"
325   wort$(5)="etiketten.     Dabei"
330   wort$(6)="werden  die   beiden"
335   wort$(7)="ersten  Zeilen fett,"
340   wort$(8)="die  anderen  Zeilen"
345   wort$(9)="  klein  gedruckt.  "
350   for k= 1 to 9
355   text$=wort$(k):gosub textausgabe
360   ypos=ypos+15
365   next k:modus=3:gosub grafikmodus
370   text$="Weiter":xpos=316:ypos=171:gosub textausgabe
375   text$="Abbruch":xpos=462:ypos=171:gosub textausgabe
380   gosub showmaus
385   Mausauswertung:
390   gosub mausabfrage
395   if (xmaus>452 and xmausy<520 and ymaus>157 and ymaus<182)then halt=1                                                                    else halt=0
400   if halt=1 then gosub bestaetigung:goto 425
405   if (xmaus>302 and xmaus<375 and ymaus>157 and ymaus<182)then weiter=1                                                                  else weiter=0
410   if weiter=1 then gosub bestaetigung: goto 425
415   sound 1,15,10,6:wave 1,1,9,11000
420   goto Mausauswertung
425   groesse= 10:gosub schriftgroesse:modus=1:gosub grafikmodus
430   return
435   '======================================================================
440   eingabemaske:
445   modus=1:gosub grafikmodus
450   color 1,1,1,2,2:xpos1=18:xpos2=615:ypos1=-20:ypos2=0:gosub rechteck
455   text$=" EINGABE":xpos=280:ypos=-5:gosub textausgabe
460   gosub  hidemaus: clearw 2:color 1,1,1,1,2:fuell=1
465   '----------------------------------------------------------------------
470   '---> Maske Diskettennummer
475   xpos1=50:xpos2=xpos1+190:ypos1=30:ypos2=60:gosub rechteckrund
480   '----------------------------------------------------------------------
485   '---> Maske "___"
490   xpos1=255:xpos2=xpos1+55:ypos2=60: gosub rechteckrund
495   '----------------------------------------------------------------------
500   '---> Maske Programmname
505   xpos1=50:xpos2=xpos1+190:ypos1=80:ypos2=110:gosub rechteckrund
510   '----------------------------------------------------------------------
515   '---- Maske "-----------"
520   xpos1=255:xpos2=xpos1+130:ypos1=80:ypos2=130:gosub rechteckrund
525   '----------------------------------------------------------------------
530   '---- Maske "Bemerkungen"
535   xpos1=50:xpos2=xpos1+190:ypos1=150:ypos2=180:gosub rechteckrund
540   '----------------------------------------------------------------------
545   '---- Maske "_______ ..."
550   xpos1=255:xpos2=xpos1+343:ypos1=150:ypos2=243:gosub rechteckrund
555   '----------------------------------------------------------------------
560   '---Maske "laufende Disk Nr."
565   xpos1=50:xpos2=xpos1+190:ypos1=268:ypos2=298:gosub rechteckrund
570   '----------------------------------------------------------------------
575   '--->Maske "___"
580   xpos1=255:xpos2=xpos1+55:ypos1=268:ypos2=298:gosub rechteckrund
585   '----------------------------------------------------------------------
590   return
595   '======================================================================
600   eingabetext:
605   modus=1:gosub grafikmodus:groesse = 10:gosub schriftgroesse
610   schrifttyp=16:gosub  schriftart
615   text$=" Diskettennummer":xpos=62:ypos=50:gosub textausgabe
620   text$=" Programmname":xpos=80:ypos=100:gosub textausgabe
625   text$=" Bemerkungen":xpos =82:ypos=170:gosub textausgabe
630   text$=" Laufende DiskNr.":xpos=58:ypos=288:gosub textausgabe
635   schrifttyp=0:gosub schriftart:modus=1:gosub grafikmodus
640   groesse=18:gosub schriftgroesse
645   groesse=9:gosub schriftgroesse
650   modus=2:gosub grafikmodus
655   groesse=10:gosub schriftgroesse
660   gotoxy 16,2:?"___"
665   gotoxy 16,5:?"____________"
670   gotoxy 16,6:?"____________"
675   for k= 0 to 4
680   gotoxy 16,9+k:?"_______________________________________"
685   next k
690   gotoxy 16,16:?"___"
695   gotoxy 16,2: line input nrA$   :nr$=left$(nrA$,3)
700   gotoxy 16,5: line input nameA$ :name1$=left$(nameA$,12)
705   gotoxy 16,6: line input nameB$ :name2$=left$(nameB$,12)
710   for l=0 to 4
715   gotoxy 16,9+l:line input bemerkungen1$(l)
720   bemerkungen$(l)=left$(bemerkungen1$(l),39)
725   next l
730   gotoxy 16,16:line input "";diskette1$ :diskette$=left$(diskette1$,3)
735   groesse=10:gosub schriftgroesse
740   return
745   '==================================================================
750   kontrollmaske:
755   clearw 2
760   color 1,1,1,11,2
765   xpos1=0: ypos1=0:xpos2=614:ypos2=343:gosub rechteck
770   modus =1:gosub grafikmodus
775   color 1,1,1,2,2
780   xpos1=18:xpos2=615:ypos1=-20:ypos2=0:gosub rechteck
785   text$=" KONTROLLE":xpos=280:ypos=-5:gosub textausgabe:modus=1:gosub            grafikmodus
790   color 1,1,1,1,0:fuell=1
795   xpos1=187:xpos2=xpos1+274:ypos1=18:ypos2=262:gosub rechteckrund
800   xpos1=189:xpos2=xpos1+270:ypos1=20:ypos2=260:gosub rechteckrund
805   groesse=18:gosub schriftgroesse: schrifttyp=1:gosub schriftart
810   text$="_______________":xpos=203:ypos=40: gosub textausgabe
815   text$="_______________":xpos=203:ypos=70: gosub textausgabe
820   text$="_______________":xpos=203:ypos=250:gosub textausgabe
825   y=cint(220 -(10 * len(nr$))/2)
830   let  text$ = nr$:xpos=95+y :ypos=60:gosub textausgabe
835   text$= name1$:xpos=225:ypos=110:gosub textausgabe
840   text$= name2$:xpos=225:ypos=140:gosub textausgabe
845   text$="_______________":xpos=203:ypos=165:gosub textausgabe
850   groesse=3:gosub schriftgroesse:schrifttyp=0:gosub schriftart
855   for k= 0 to 4
860   text$ ="- "+ bemerkungen$(k)
865   xpos=200:ypos=185 + k*10:gosub textausgabe
870   next k
875   text$="- Disk Nr. "+diskette$ :xpos=200:ypos=235:gosub textausgabe
880   text$="SS/DS":xpos=413:ypos=235:gosub textausgabe
885   kontrollabfrage:
890   groesse=10:gosub schriftgroesse
895   for i=0 to 2
900   xpos1=130+i*150:xpos2=xpos1+78:ypos1=290:ypos2=ypos1+28:gosub rechteck
905   next i
910   for i=0 to 2
915   xpos1=132+i*150:xpos2=xpos1+74:ypos1=292:ypos2=ypos1+24:gosub rechteck
920   next i
925   word$(0)=" Žndern":word$(1)=" Drucken":word$(2)=" Abbruch":xpos=135
930   modus =3:gosub grafikmodus
935   for a= 0 to 2
940   ypos=310:text$ = word$(a) : gosub textausgabe
945   xpos=xpos+150
950   next a
955   gosub showmaus
960   mausauswertung.2:
965   gosub mausabfrage
970   if (ymaus>292 and ymaus<316) then abfrage.y=1 else abfrage.y=0
975   if (abfrage.y=1 and xmaus>132 and xmaus<206)then aendern=1 else aendern=0
980   if (abfrage.y=1 and xmaus>282 and xmaus<356)then drucken=1 else drucken=0
985   if (abfrage.y=1 and xmaus>432 and xmaus<506)then halt=1 else halt=0
990   if aendern=1 then goto 1015
995   if drucken=1 then goto 1015
1000  if halt=1 then goto 1015
1005  sound 1,15,10,6:wave 1,1,9,11000
1010  goto mausauswertung.2
1015  gosub hidemaus
1020  gosub bestaetigung.2
1025  return
1030  '====================================================================
1035  aenderung:
1040  modus=1:gosub grafikmodus:groesse=10:gosub schriftgroesse
1045  color 1,1,1,2,2:xpos1=18:xpos2=615:ypos1=0:ypos2=-20:gosub rechteck
1050  text$=" ŽNDERUNG":xpos=280:ypos=-5:gosub textausgabe
1055  modus=1:gosub grafikmodus
1060  schrifttyp=16:gosub schriftart
1065  color 1,1,1,1,2
1070  xpos1=69:xpos2=xpos1+496:ypos1=283:ypos2=ypos1+40:fuell=1
1075  gosub rechteckrund
1080  text$="  Was soll ge„ndert werden ? Bitte anklicken !":xpos=85:ypos=310
1085  gosub textausgabe
1090  groesse=9:schrifttyp=0:gosub schriftart:gosub schriftgroesse
1095  for k= 0 to 7
1100  color 1,1,1,1,0:fuell=0
1105  xpos1=23:xpos2=xpos1+148:ypos1=22+k*30:ypos2=ypos1+25 :gosub rechteck
1110  xpos1=25:xpos2=xpos1+144:ypos1=24+k*30:ypos2=ypos1+21 :gosub rechteck
1115  next k
1120  modus=3:gosub grafikmodus
1125  wort$(0)=" Diskettennummer"
1130  wort$(1)="   Programmname"
1135  wort$(2)="   Bemerkung  1"
1140  wort$(3)="   Bemerkung  2"
1145  wort$(4)="   Bemerkung  3"
1150  wort$(5)="   Bemerkung  4"
1155  wort$(6)="   Bemerkung  5"
1160  wort$(7)="   Lfd. Disk Nr."
1165  for k=0 to 7
1170  text$=wort$(k):xpos=28:ypos=37+k*30:gosub textausgabe
1175  next k
1180  modus=1:gosub grafikmodus
1185  mausauswertung.3:
1190  gosub showmaus
1195  gosub mausabfrage
1200  if (xmaus>25 and xmaus<169)then abfrage.x=1  else abfrage.x=0
1205  n=0
1210  if (abfrage.x=1 and ymaus>24 and ymaus<45)then n=1
1215  if (abfrage.x=1 and ymaus>54 and ymaus<75)then n=2
1220  if (abfrage.x=1 and ymaus>84 and ymaus<105)then n=3
1225  if (abfrage.x=1 and ymaus>114 and ymaus<135)then n=4
1230  if (abfrage.x=1 and ymaus>144 and ymaus<165) then n=5
1235  if (abfrage.x=1 and ymaus>174 and ymaus<195)then n=6
1240  if (abfrage.x=1 and ymaus>204 and ymaus<225)then n=7
1245  if (abfrage.x=1 and ymaus>234 and ymaus<255)then n=8
1250  if n=0 then sound 1,15,10,6:wave 1,1,9,11000 else goto 1260
1255  goto mausauswertung.3
1260  gosub hidemaus:gosub bestaetigung.3
1265  modus=1:gosub grafikmodus:clearw 2
1270  color 1,1,1,11,2:xpos1=0: ypos1=0:xpos2=615:ypos2=344:gosub rechteck
1275  color 1,1,1,2,2:fuell=1
1280  for k=0 to 1
1285  xpos1=90 :xpos2=xpos1+130:ypos1=62+k*102 :ypos2=ypos1+30
1290  gosub rechteckrund
1295  next k
1300  modus=1:gosub grafikmodus
1305  schrifttyp=16:groesse=18:gosub schriftart:gosub schriftgroesse
1310  text$=" Alt":xpos=110:ypos=82:gosub textausgabe
1315  text$=" Neu":xpos=110:ypos=185:gosub textausgabe
1320  schrifttyp=0:groesse=10:gosub schriftart:gosub schriftgroesse
1325  l=12
1330  if n=1  then l=2
1335  if n=8  then l=2
1340  if n=2  then l=5 :gosub maske.2:goto 1350
1345  gosub maske.1
1350  if n=1 then gotoxy 15,4:? nr$
1355  if n=1 then gotoxy 15,10:?"___"
1360  if n=1 then gotoxy 15,10 :line input "";nr1$ :nr$=left$(nr1$,3): goto 1400
1365  if n=2 then gotoxy 15,10:?"____________":gotoxy 15,11:?"____________"
1370  if n=2 then gotoxy 15,4:?name1$
1375  if n=2 then gotoxy 15,5:?name2$
1380  if n=2 then gotoxy 15,10:line input "";nameA$:name1$=left$(nameA$,12)
1385  if n=2 then gotoxy 15,11:line input "";nameB$:name2$=left$(nameB$,12):         goto 1400
1390  if n<>8 then gotoxy 15,10:?"_______________________________________"
1395  if n=3 then gotoxy 15,4:? bemerkungen$(0)
1400  if n=3 then gotoxy 15,10:line input bemerkungen1$(0)
1405  if n=4 then gotoxy 15,4:?bemerkungen$(1)
1410  if n=4 then gotoxy 15,10:line input bemerkungen1$(1)
1415  if n=5 then gotoxy 15,4:?bemerkungen$(2)
1420  if n=5 then gotoxy 15,10:line input bemerkungen1$(2)
1425  if n=6 then gotoxy 15,4:? bemerkungen$(3)
1430  if n=6 then gotoxy 15,10:line input bemerkungen1$(3)
1435  if n=7 then gotoxy 15,4:?bemerkungen$(4)
1440  if n=7 then gotoxy 15,10:line input bemerkungen1$(4)
1445  if n=8 then gotoxy 15,4:?diskette$:gotoxy 15,10:?"___"
1450  if n=8 then gotoxy 15,10:line input diskette1$:                                diskette$=left$(diskette1$,3)
1455  for p=0 to 4:bemerkungen$(p)=left$(bemerkungen1$(p),39):next p
1460  return
1465  '==================================================================
1470  schlusstext:
1475  modus=1:gosub grafikmodus
1480  gosub hidemaus
1485  color 1,1,1,1,0 :for p= 0 to 1:xpos1=190+p*150:xpos2=xpos1+100
1490  ypos1=275:ypos2=ypos1+30:gosub rechteck
1495  xpos1=192+p*150:xpos2=xpos1+96:ypos1=277:ypos2=ypos1+26
1500  gosub rechteck:next p :modus=3:gosub grafikmodus
1505  groesse=10:schrifttyp=0:gosub schriftart:gosub schriftgroesse
1510  text$="Abbruch":xpos=362:ypos=296:gosub textausgabe
1515  text$="Weiter" :xpos=220:ypos=296:gosub textausgabe
1520  mausauswertung.4:
1525  gosub showmaus
1530  gosub mausabfrage
1535  if (ymaus>277 and ymaus<303)then abfrage.y=1 else abfrage.y=0
1540  if (abfrage.y=1 and xmaus>192 and xmaus<288)then weiter=1 else weiter=0
1545  if (abfrage.y=1 and xmaus>342 and xmaus<438)then halt=1 else halt=0
1550  if halt=0 and weiter=0 then sound 1,15,10,6:wave 1,1,9,11000 else goto 1560
1555  goto mausauswertung.4
1560  gosub hidemaus: gosub bestaetigung.4
1565  'modus=1:gosub grafikmodus
1570  return
1575  '====================================================================
1580  drucker:
1585  modus=1:gosub grafikmodus:color 1,1,1,2,2
1590  xpos1=18:xpos2=615:ypos1=0:ypos2=-20:gosub rechteck
1595  text$=" DRUCKEN":xpos=280:ypos=-5:gosub textausgabe
1600  modus=1:gosub grafikmodus
1605  color 1,1,1,11,2:ypos1=0:xpos1=0:xpos2=615:ypos2=344:gosub rechteck
1610  color 1,1,1,8,2:fuell=1
1615  xpos1=126:xpos2=xpos1+378:ypos1= 96:ypos2=ypos1+154:gosub rechteckrund
1620  color 1,1,1,15,2:fuell=1
1625  xpos1=130:xpos2=xpos1+380:ypos1=100:ypos2=ypos1+150:gosub rechteckrund
1630  schrifttyp=16:groesse=18:gosub schriftart:gosub schriftgroesse
1635  text$=" Ich arbeite":xpos=200:ypos=180:gosub textausgabe
1640  lprint chr$(27);"W1";chr$(27);"x1";
1645  lprint "____________";chr$(10);
1650  y =  cint((12-len(nr$))/2)
1655  for l = 1 to y :lprint chr$(32);
1660  next l
1665  lprint nr$;chr$(13);
1670  lprint "____________";chr$(10);chr$(10);
1675  lprint name1$;chr$(10);
1680  lprint name2$;chr$(10);
1685  lprint "____________"; chr$(27);"W0";chr$(27);"x0";
1690  lprint chr$(27);"F"
1695  lprint chr$(27);"S0";chr$(15);chr$(27);"x1";
1700  lprint chr$(27);"1";chr$(10);
1705  for i=0 to 4
1710  lprint "- " bemerkungen$(i);chr$(10);
1715  next i
1720  q=26 - len(diskette$)
1725  lprint "- Disk Nr."   diskette$ ;
1730  for i=1 to q:lprint chr$(46);
1735  next i:  lprint "SS/DD";chr$(10);
1740  lprint chr$(27);"2";
1745  lprint chr$(27);"@";
1750  lprint chr$(27);"W1";chr$(27);"x1";
1755  lprint "____________";chr$(10);chr$(10);chr$(10);
1760  lprint chr$(27);"@";
1765  for p= 1 to 500 :next p
1770  text$=" Ich bin fertig !":xpos=160:ypos=180:gosub textausgabe
1775  sound 1,15,8,3:wave 1,1,9,20000
1780  return
1785  '=================================================================
1790  mausabfrage:
1795  gosub maus
1800  if key <>1 then goto 1790
1805  return
1810  '=================================================================
1815  bestaetigung:
1820  gosub hidemaus: color 1,1,1,8,2:fuell=1
1825  if weiter=1 then k=0 else k=1
1830  xpos1=302+k*150:xpos2=xpos1+74:ypos1=157:ypos2=181:gosub rechteck
1835  for c=0 to 250:next
1840  return
1845  '================================================================
1850  bestaetigung.2:
1855  color 1,1,1,8,2:fuell=1
1860  ypos1=292:ypos2=ypos1+24
1865  if halt=1    then xpos1=432
1870  if halt=1    then xpos2=506
1875  if drucken=1 then xpos1=282
1880  if drucken=1 then xpos2=xpos1+74
1885  if aendern=1 then xpos1=132
1890  if aendern=1 then xpos2=206
1895  gosub rechteck
1900  for m = 1 to 500:next m
1905  return
1910  '===================================================================
1915  bestaetigung.3:
1920  modus=3:gosub grafikmodus
1925  color 1,1,1,8,2:fuell=1
1930  xpos1=25:xpos2=xpos1+144
1935  if n=1 then ypos1=24
1940  if n=2 then ypos1=54
1945  if n=3 then ypos1=84
1950  if n=4 then ypos1=114
1955  if n=5 then ypos1=144
1960  if n=6 then ypos1=174
1965  if n=7 then ypos1=204
1970  if n=8 then ypos1=234
1975  ypos2=ypos1+21
1980  gosub rechteck
1985  for m=1 to 500:next m
1990  return
1995  '==================================================================
2000  bestaetigung.4:
2005  color 1,1,1,8,2
2010  ypos1=277:ypos2=303
2015  if halt =1 then xpos1=342 else xpos1=192
2020  xpos2=xpos1+96
2025  gosub rechteck
2030  for m=1 to 500:next m
2035  return
2040  '=====================================================================
2045  maske.1:
2050  for k= 0 to 1:fuell=1
2055  xpos1=240:xpos2=xpos1+l*28:ypos1=62:ypos2=ypos1+30:gosub rechteckrund
2060  xpos1=240:xpos2=xpos1+l*28:ypos1=164:ypos2=ypos1+30:gosub rechteckrund
2065  next k
2070  return
2075  '=====================================================================
2080  maske.2:
2085  fuell=1
2090  xpos1=240:xpos2=xpos1+l*28:ypos1=62:ypos2=ypos1+50:gosub rechteckrund
2095  xpos1=240:xpos2=xpos1+l*28:ypos1=164:ypos2=ypos1+50:gosub rechteckrund
2100  return
2105  '
2110  '
2115  '***************************************************************
2120  '******************** GEM-Routinen *****************************
2125  MAUS:
2130  poke contrl  ,124
2135  vdisys
2140  xmaus=peek(ptsout)-1
2145  ymaus=peek(ptsout + 2)-38
2150  key =peek(intout)
2155  return
2160  '---------------------------------------------------------------
2165  MAUSFORM:
2170  if mausnr > 7 then return
2175  add#=gb
2180  gintin=peek(add#+8)
2185  addrin=peek(add#+16)
2190  poke gintin,mausnr
2195  poke addrin,0
2200  gemsys(78)
2205  return
2210  '--------------------------------------------------------------
2215  showmaus:
2220  poke contrl,122
2225  poke intin,0
2230  vdisys
2235  return
2240  '--------------------------------------------------------------
2245  RECHTECK:
2250  POKE CONTRL ,11
2255  poke contrl+2,2
2260  poke contrl+6,0
2265  poke contrl+10,1
2270  poke ptsin ,xpos1 +1
2275  poke ptsin+2,ypos1 +38
2280  poke ptsin+4,xpos2 +1
2285  poke ptsin+6,ypos2 +38
2290  vdisys
2295  return
2300  '---------------------------------------------------------------
2305  RECHTECKRUND:
2310  poke contrl  ,11
2315  poke contrl+2,2
2320  poke contrl+6,0
2325  if fuell = 0 then poke contrl+10,8                                                          else poke contrl+10,9
2330  poke ptsin  ,xpos1 + 1
2335  poke ptsin+2,ypos1 + 38
2340  poke ptsin+4,xpos2 + 1
2345  poke ptsin+6,ypos2 + 38
2350  vdisys
2355  return
2360  '-----------------------------------------------------------------
2365  Schriftart:
2370  poke contrl  ,106
2375  poke contrl+2,0
2380  poke contrl+6,1
2385  poke intin ,schrifttyp
2390  vdisys
2395  return
2400  '-----------------------------------------------------------------
2405  schriftgroesse:
2410  poke contrl  ,107
2415  poke contrl+2,0
2420  poke contrl+6,1
2425  poke intin ,groesse
2430  vdisys
2435  return
2440  '----------------------------------------------------------------
2445  textausgabe:
2450  for i= 0 to len(text$)-1
2455  poke intin+i*2,asc(mid$(text$,i+1,1))
2460  next
2465  poke intin+i*2,0
2470  poke contrl,8
2475  poke contrl+2,1
2480  poke contrl+6,len(text$)+1
2485  poke ptsin , xpos+1
2490  poke ptsin+2,ypos+38
2495  vdisys
2500  return
2505  '---------------------------------------------------------------
2510  grafikmodus:
2515  poke contrl ,32
2520  poke contrl+2,0
2525  poke contrl+6,1
2530  poke intin ,modus
2535  vdisys
2540  return
2545  '---------------------------------------------------------------
2550  clipping:
2555  poke contrl, 129
2560  poke intin ,1
2565  poke ptsin ,xpos1
2570  poke ptsin+2,ypos1
2575  poke ptsin+4,xpos2
2580  poke ptsin+6,ypos2
2585  vdisys
2590  return
2595  '--------------------------------------------------------------
2600  zeichenhoch:
2605  poke contrl,12
2610  poke ptsin+2,zeichenhoehe
2615  vdisys
2620  return
2625  '--------------------------------------------------------------
2630  hidemaus:
2635  poke contrl,123
2640  vdisys
2645  return
2650  '--------------------------------------------------------------
2655  '                   !!!! GESCHAFFT !!!!
2670  '--------------------------------------------------------------
2675  '##############################################################
