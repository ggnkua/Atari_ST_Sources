10    ' TITELBLATT
20    dim tagzahl(13)
30    tagzahl(1)=31:tagzahl(2)=28:tagzahl(3)=31:tagzahl(4)=30
40    tagzahl(5)=31:tagzahl(6)=30:tagzahl(7)=31:tagzahl(8)=31
50    tagzahl(9)=30:tagzahl(10)=31:tagzahl(11)=30:tagzahl(12)=31
60    dim korx(500),kory(500),seey(500),geiy(500)
70    dim dkorx(500),dkory(500),dseey(500),dgeiy(500)
80    fullw 2:clearw 2
90    gotoxy 0,4
100   ?tab(28);"B I O R H Y T H M U S":?:?
110   linef 203, 59,395, 59
120   linef 203, 59,203, 98
130   linef 395, 59,395, 98
140   linef 203, 98,395, 98
160   dk$="Desk  File  Run  Edit  Debug                             "
165   de$=chr$(189)+" Dietmar Schell"
170   ?tab(30);de$
175   ?tab(21);"Gabriel-Biel-Str. 5, 7400 TÅbingen":?
180   ?tab(15);"Das Programm stellt die drei Biorhythmus-Zyklen":?
190   ?tab(29);"den Kîrperzyklus,"
200   ?tab(29);"den Seelenzyklus und"
210   ?tab(29);"den Geistzyklus":?
220   ?tab(15);"fÅr einen gewÅnschten Zeitraum graphisch dar. Die"
230   ?tab(15);"Graphik kann mit einem Nadeldrucker als Hardcopy mit"
240   ?tab(15);"den Befehlstasten ALTERNATE + HELP ausgedruckt werden."
250   w=inp(2)
255   ' ---------------------------------------------------------
260   ' EINGABE DER DATEN
270   desk$=dk$+de$
272   gosub ZEILE
275   clearw 2
280   gotoxy 0,3
290   ?"         Bitte geben Sie Ihren Namen ein:"
300   line input "         ",name$
310   if len(name$)>24 then gosub NAMEKORR
320   ?
330   input"         Bitte geben Sie Ihr Geburtsjahr ein (vierstellig)  ",jahr
340   if jahr<1850 goto 330
350   input"         Bitte geben Sie Ihren Geburtsmonat ein (als Zahl)  ",monat
360   if monat>12 goto 350
370   input"         Bitte geben Sie Ihren Geburtstag ein               ",tag
380   if tag>31 goto 370
390   ?:?:?"         Ab wann soll der BIORHYTHMUS dargestellt werden":?
400   input"         Bitte das Jahr eingeben (vierstellig)              ",biojahr
410   if biojahr<jahr goto 400
420   input"         Bitte den Monat eingeben (als Zahl)                ",biomonat
430   if biomonat>12 goto 420
440   if biojahr=jahr and biomonat<monat goto 420
450   input"         Bitte den Tag eingeben                             ",biotag
460   if biotag>31 goto 450
470   if biojahr=jahr and biomonat=monat and biotag<tag goto 450
475   ' ---------------------------------------------------------
480   ' AUSDRUCK GEBURTSTAG USW VORBEREITEN
490   monat$=right$(str$(monat),4)
500   biomonat$=right$(str$(biomonat),2)
510   tag$=right$(str$(tag),2)
520   biotag$=right$(str$(biotag),2)
530   jahr$=right$(str$(jahr),4)
540   biojahr$=right$(str$(biojahr),4)
550   geburt$=tag$+"."+monat$+"."+jahr$
560   biorh$=biotag$+"."+biomonat$+"."+biojahr$
565   ' ---------------------------------------------------------
570   ' ALTER IM GEBURTSJAHR
580   if biojahr>jahr then gosub GJAHR
590   if biojahr=jahr then gosub NEUGEB
595   ' ---------------------------------------------------------
600   ' AUSDRUCK DES ALTERS VORBEREITEN
610   alter$=right$("     "+str$(alter),6)
615   ' ---------------------------------------------------------
620   ' BERECHNUNG DER ANFANGSPUNKTE DER ZYKLEN
630   korper=(alter)mod(23)
640   seele =(alter)mod(28)
650   geist =(alter)mod(33)
655   ' ---------------------------------------------------------
656   ' MENUE
660   clearw 2
670   gotoxy 0,4
680   ?"         WÅnschen Sie einen Monats-BIORHYTHMUS      1"
690   ?"         oder  einen   Drei-Monats-BIORHYTHMUS      2":?
700   ?"         Neue Daten eingeben                        3":?
710   ?"         Programm beenden                           4":?:?
720   linef 57,59,57,180
730   linef 57,59,435,59
740   linef 57,180,435,180
750   linef 435,59,435,180
760   ?:input"         Bitte wÑhlen:                              ";wahl
770   on wahl gosub MOBIO,DREIBIO,275,790
780   goto 660
790   desk$=dk$+"                "
792   gosub ZEILE
793   end
795   ' ---------------------------------------------------------
800   GJAHR:
810   ' ALTER IM GEBURTSMONAT
820   alter=tagzahl(monat)-tag
825   ' ---------------------------------------------------------
830   ' ALTER IM GEBURTSJAHR
840   mhilf=monat+1
850   for x=mhilf  to 12
860   alter=alter+tagzahl(x)
870   next x
875   ' ---------------------------------------------------------
880   ' ALTER IM GEBURTSJAHR BEI SCHALTJAHR
890   if (jahr)mod(4)=0 and jahr<>1900 and monat<=2 then alter=alter+1
895   ' ---------------------------------------------------------
900   ' ALTER DER GANZEN JAHRE
910   alter=alter+(biojahr-jahr-1)*365
915   ' ---------------------------------------------------------
920   ' SCHALTJAHRE DER GANZEN JAHRE
930   for y=jahr+1 to biojahr-1
940   if (y)mod(4)=0 then alter=alter+1
950   next x
960   if jahr<1900 then alter=alter-1
965   ' ---------------------------------------------------------
970   ' ALTER IM BIORHYTHMUSJAHR
980   for x=1 to biomonat-1
990   alter=alter+tagzahl(x)
1000  next x
1010  alter=alter+biotag
1015  ' ---------------------------------------------------------
1020  ' ALTER IM BIORHYTHMUSJAHR BEI SCHALTJAHR
1030  if biomonat>2 and (biojahr)mod(4)=0 then alter=alter+1
1040  return
1045  ' ---------------------------------------------------------
1050  NEUGEB:
1060  alter=tagzahl(monat)-tag
1070  mhilf=monat+1
1080  for x=mhilf to biomonat-1
1090  alter=alter+tagzahl(x)
1100  next x
1110  alter=alter+biotag
1115  ' ---------------------------------------------------------
1120  ' KEIN SCHALTJAHR 1900
1130  if jahr=1900 goto 1160
1135  ' ---------------------------------------------------------
1140  ' SCHALTJAHR
1150  if (jahr)mod(4)=0 and monat<=2 and biomonat>2 then alter=alter+1
1160  if monat=biomonat then alter=biotag-tag
1170  return
1175  ' ---------------------------------------------------------
1180  MOBIO:
1190  clearw 2
1200  gotoxy 0,2
1205  gosub WEISS
1210  ?tab(12);"BIORHYTHMUS von ";name$;tab(53);"ab dem ";biorh$
1220  ?tab(12);"geboren am ";geburt$;"     Alter am ";biorh$;" :";alter$;" Tage"
1230  ?tab(12);"K =                 S =                 G ="
1240  rem DATUMZEILE BERECHNEN
1250  ?:?:?:?:?:?:?:?:?:?:?:?:?"       ";
1260  for y=biotag to tagzahl(biomonat) step 2
1270  print using "  ##";y;
1280  next y
1290  yhilf=1
1300  taghilf=tagzahl(biomonat)-biotag
1310  if (taghilf)mod(2)=0 then yhilf=2
1320  for y=yhilf to 31-taghilf step 2
1330  print using "  ##";y;
1340  next y
1345  ?
1346  linef 0,0,0,340
1350  linef 72,310,568,310
1360  linef 568,28,568,310
1370  linef 72,310,72,28
1380  linef 568,28,72,28
1390  linef 72,289,568,289
1400  linef 72,190,568,190
1410  linef 72, 91,568, 91
1420  linef 120, 78,168, 78
1430  linef 280, 78,328, 78
1440  linef 440, 78,488, 78
1450  circle 128, 78,1
1460  circle 144, 78,1
1470  circle 160, 78,1
1480  circle 288, 78,2
1490  circle 304, 78,2
1500  circle 320, 78,2
1510  for x=88 to 552 step 16
1520  linef x, 91,x,289
1530  next x
1540  pi=3.14159
1550  for k=0 to 496 step 8
1560  korx(k)=k+72
1570  kory(k)=190-50*sin(pi*2/496*k*31/23-pi/23+pi*2*korper/23)
1580  seey(k)=190-50*sin(pi*2/496*k*31/28-pi/28+pi*2*seele /28)
1590  geiy(k)=190-50*sin(pi*2/496*k*31/33-pi/33+pi*2*geist /33)
1600  next k
1610  for k=8 to 496 step 8
1620  linef korx(k-8),kory(k-8),korx(k),kory(k)
1630  linef korx(k-8),seey(k-8),korx(k),seey(k)
1640  linef korx(k-8),geiy(k-8),korx(k),geiy(k)
1650  next k
1660  for k=8 to 496 step 16
1670  circle korx(k),kory(k),1
1680  circle korx(k),seey(k),2
1690  next k
1700  w=inp(2)
1705  gosub ZEILE
1710  return
1715  ' ---------------------------------------------------------
1720  DREIBIO:
1730  clearw 2
1740  gotoxy 0,2
1745  gosub WEISS
1750  ?tab(12);"BIORHYTHMUS von ";name$;tab(53);"ab dem ";biorh$
1760  ?tab(12);"geboren am ";geburt$;"     Alter am ";biorh$;" :";alter$;" Tage"
1770  ?tab(12);"K =                 S =                 G ="
1780  ?:?:?:?:?:?:?:?:?:?:?:?
1790  ?tab(12);"Tages-, Wochen- und Monatslinien ab dem ";biorh$
1795  linef 0,0,0,340
1800  linef 72,310,562,310
1810  linef 562,28,562,310
1820  linef 72,310,72,28
1830  linef 562,28,72,28
1840  linef 72,289,562,289
1850  linef 72,190,562,190
1860  linef 72, 91,562, 91
1870  linef 120, 78,168, 78
1880  linef 280, 78,328, 78
1890  linef 440, 78,488, 78
1900  circle 128, 78,1
1910  circle 144, 78,1
1920  circle 160, 78,1
1930  circle 288, 78,2
1940  circle 304, 78,2
1950  circle 320, 78,2
1960  ' TAGESLINIEN
1970  for x= 77 to 562 step  5
1980  linef x,188,x,192
1990  next x
2000  ' WOCHENLINIEN
2010  for x=107 to 562 step 35
2020  linef x,185,x,195
2030  next x
2040  ' MONATSLINIEN
2050  zhilf=(tagzahl(biomonat)+1-biotag)*5+72
2060  if biomonat=2 and (biojahr)mod(4)=0 then zhilf=zhilf+5
2070  linef zhilf, 91,zhilf,289
2080  for zz=biomonat+1 to biomonat+3
2090  if zz=2 and (biojahr)mod(4)=0 then zhilf=zhilf+5
2100  if zz=14 and (biojahr+1)mod(4)=0 then zhilf=zhilf+5
2105  ztag=zz
2110  if zz>12 then ztag=zz-12
2120  zhilf=zhilf+tagzahl(ztag)*5
2130  if zhilf<562 then linef zhilf, 91,zhilf,289
2140  next zz
2150  pi=3.14159
2160  for k=0 to 490 step 5
2170  dkorx(k)=k+72
2180  dkory(k)=190-50*sin(pi*2/496*k*99.2/23-pi/23+pi*2*korper/23)
2190  dseey(k)=190-50*sin(pi*2/496*k*99.2/28-pi/28+pi*2*seele /28)
2200  dgeiy(k)=190-50*sin(pi*2/496*k*99.2/33-pi/33+pi*2*geist /33)
2210  next k
2220  for k=5 to 490 step 5
2230  linef dkorx(k-5),dkory(k-5),dkorx(k),dkory(k)
2240  linef dkorx(k-5),dseey(k-5),dkorx(k),dseey(k)
2250  linef dkorx(k-5),dgeiy(k-5),dkorx(k),dgeiy(k)
2260  next k
2270  for k=5 to 485 step 10
2280  circle dkorx(k),dkory(k),1
2290  circle dkorx(k),dseey(k),2
2300  next k
2310  w=inp(2)
2315  gosub ZEILE
2320  return
2325  ' ---------------------------------------------------------
2330  NAMEKORR:
2340  clearw 2
2350  gotoxy 0,4
2360  ?"         Der eingegebene Name ist zu lang! Bitte geben"
2370  ?"         Sie Ihren Namen neu ein, so daû er die Strich-
2380  ?"         leiste nicht Åberschreitet.":?
2385  gotoxy 0,8
2390  ?"         ________________________                                    "
2395  gotoxy 0,8
2400  line input"         ",name$
2410  if len(name$)>24 goto 2385
2420  return
2425  ' ---------------------------------------------------------
64000 WEISS:
64010 color 1,1,1,1,5
64020 poke contrl   ,11
64030 poke contrl+2 ,2
64040 poke contrl+6 ,0
64050 poke contrl+10,1
64060 poke ptsin  ,1
64070 poke ptsin+2,0
64080 poke ptsin+4,639
64090 poke ptsin+6,399
64100 vdisys
64110 return
64115 ' ---------------------------------------------------------
65200 ZEILE:
65231 for i=0 to 72
65232 poke intin+i*2,asc(mid$(desk$,i+1,1))
65234 next
65240 poke intin+i*2,0
65250 poke contrl, 8
65260 poke contrl+2,1
65270 poke contrl+6,74
65281 poke ptsin, 24
65286 poke ptsin+2, 14
65290 vdisys
65300 return
