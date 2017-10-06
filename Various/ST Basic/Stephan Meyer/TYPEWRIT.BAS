5     openw 3,610,380,gx,gy
10    openw 2,0,1,660,420: clearw 2
20    for i = 1 to 7
30    ?tab(34);"TIPE  W  RITE": next i
40    ?tab(34);"****  *  ****"
50    ?tab(34);"****  *  ****"
60    ?tab(34);"****  F  ****"
70    ?tab(32);"******  O  ******"
80    ?tab(31);"*******  R  *******"
90    ?tab(29);"*DESIGNED  *  DESIGNED*"
100   ?tab(27);"***********  A  ***********"
110   ?tab(23);"****** B Y ****  T  **** B Y ******"
120   ?tab(20);"*****************   A   *****************
130   ?tab(16);"*** W E R N E R ****    R    **** W E R N E R ***"
140   ?tab(13);"**********************     I     **********************"
150   ?tab(10);"*** T S C H E R N E ***       *       *** T S C H E R N E ***"
160   ?TAB(8);"**********************          S          **********************";
170   ?TAB(8);"* A L T E N *******             T             ******* R H E I N *";
180   color 1,0,1: linef 306,0,306,360: linef 325,0,325,360
190   color 1,0,1: linef 304,0,304,360: linef 327,0,327,360
200   sound 1,0,1,1,199
205   timer = &H4BC
210   clearw 2 : gotoxy 10,10
220   ?chr$(189)"  by Werner Tscherne, Altenrhein
230   ?:?spc(32)"Switzerland
240   sound 1,0,0,0,60
250   dim wt$(100),dt$(100),tw$(100)
260   wt$(0)=" ":tw$(0)=" "
270   'zeichen einlesen
280   for a = 1 to 28
290   read a1$
300   wt$(a)=wt$(a-1)+a1$
310   tw$(a)=a1$
320   next a
330   data "f","j","d","k","s","l","t","z","r"
340   data "u","e","i","w","o","q","p","v","n"
350   data "c","m","x",",","y",".","g","h","a","b"
360   clearw 2 : gosub 6180
370   gotoxy  24,2:? "A U S W A H L"
380   ?tab(52);"*************
390   gotoxy 20,5:?"F  Fingeruebung"
400   gotoxy 18,7:?"S  Schreibuebung"
410   gotoxy 16,9:?"W  Wortuebung"
420   gotoxy 14,11:?"E  E n d e" : gosub 6110
430   color 1,0,1: circle 343,95,9 : circle 343,95,10: circle 343,95,11
440   color 1,0,1: circle 310,129,9: circle 310,129,10: circle 310,129,11
450   color 1,0,1: circle 276,163,9: circle 276,163,10: circle 276,163,11
460   color 1,0,1: circle 241,197,9: circle 241,197,10: circle 241,197,11
470   gotoxy 9,15 :?"I h r e  W a h l :";:qw$ = chr$(inp(2))
480   if qw$ <> "f" and qw$ <> "s" and qw$ <> "w" and qw$ <> "e" then 490 else 500
490   ?" *FALSCHE WAHL*":?chr$(7):sound 1,0,0,0,59: goto 470
500   if qw$ = "f" goto Fingeruebung
510   if qw$ = "s" goto Schreibuebung
520   if qw$ = "w" goto Wortuebung
530   if qw$ = "e" then goto 2100
540   FINGERUEBUNG:
550   ?" F I N G E R U E B U N G  "
560   ?:?
570   ?spc(50)"---  1 - fj"
580   ?spc(48)"---  2 - fjdk
590   ?spc(46)"---  3 - fjdksl
600   ?spc(44)"---  4 - fjdksltz
610   ?spc(42)"---  5 - fjdksltzru
620   ?spc(40)"---  6 - fjdksltzruei
630   ?spc(38)"---  7 - fjdksltzrueiwo
640   ?spc(36)"---  8 - fjdksltzrueiwoqp
650   ?spc(34)"---  9 - fjdksltzrueiwoqpvn
660   ?spc(32)"--- 10 - fjdksltzrueiwoqpvncm
670   ?spc(30)"--- 11 - fjdksltzrueiwoqpvncmx,
680   ?spc(28)"--- 12 - fjdksltzrueiwoqpvncmx,y.
690   ?spc(26)"--- 13 - fjdksltzrueiwoqpvncmx,y.gh
700   ?spc(24)"--- 14 - fjdksltzrueiwoqpvncmx,y.ghab
710   ?
720   ?spc(24)"=====================================
730   'color 1,0,1: linef 0,20,620,20: linef 0,22,620,22
740   gotoxy 11,5:?"                         "
750   gotoxy 11,5:input"Welche Tasten ";wa$: wa=val(wa$)
760   if wa<1 or wa>14 then ? "Bitte nur Zahlen 1-14":?chr$(7):goto 740
770   gotoxy 11,7:input"Wie oft ";ma$: ma = val(ma$): if ma = 0 goto 770
780   clearw 2
790   gotoxy 10,5:?"Benutze diese Tasten :";wt$(2*wa)
800   for k = 1 to ma
810   gotoxy 15,10:?;
820   for an = 1 to 14
830   randomize 0
840   x = int(rnd(1)*2*wa+1)
850   dt$(an) = tw$(x)
860   if int(an/5) = an/5 then dt$(an)  =" "
870   ?dt$(an);
880   next an
890   gotoxy 0,11:?
900   ?spc(32);
910   gosub ABFRAGE :'der Vorlage
920   clearw 2
930   next k
940   FEHLERAUSWERTUNG:
950   clearw 2
960   gotoxy 14,5:?"Von"ma*14"Zeichen"f"Fehler !"
970   di = f/ma
980   if di<1.5 then gotoxy 15,7:?"Uebung bestanden !"
990   if di>=1.5 then gotoxy 13,7:?"Uebung leider nicht bestanden..."
1000  if wu > 10 then gotoxy 10,15: ?"Training beendet !": goto 2100
1010  gotoxy 16,12: ? "Nochmal (j/n) "; : input ja$
1020  if ja$ ="j" then 1030 else 1040
1030  f = 0: wu = wu+1: goto 780
1040  goto 360
1050  ABFRAGE:'der Vorlage
1060  for an = 1 to 14
1070  i$ = chr$(inp(2))
1080  if i$<>dt$(an) then f = f+1: goto 1070
1090  if dt$(an) =" " then dt$(an) ="-"
1100  ?dt$(an);
1110  next an
1120  return
1130  SCHREIBUEBUNG:
1140  ?" S C H R E I B U E B U N G "
1150  clearw 2
1160  gotoxy 12,5:?"Alle Tasten sind gefragt !"
1170  gotoxy 12,6:?"--------------------------"
1180  for k = 1 to 3
1190  gotoxy 15,10:?;
1200  for an = 1 to 14
1210  randomize 0
1220  x = int(rnd(1)*(28+1))
1230  dt$(an) = tw$(x)
1240  ?dt$(an);
1250  next an
1260  gotoxy 0,11:?
1270  ?spc(32);
1280  gosub ABFRAGE:'der Vorlage
1290  clearw 2
1300  next k
1310  SCHREIBAUSWERTUNG:
1320  clearw 2 : gotoxy 0,4:?"Sie
1330  gotoxy 4,6:?"haben
1340  gotoxy 10,8:?f
1350  gotoxy 4,10:?"Fehler
1360  gotoxy 0,12:?"getippt :
1370  if f<=1 then gotoxy 14,8:?"Note: sehr gut!": for b = 85 to 89 step 2 :   for h = 13 to 17 step 2: color 1,0,1: ellipse 290,147,b,h: ?chr$(7): next h:    next b
1380  if f=2 then gotoxy 14,8:?"Note: gut!"
1390  if f=3 then gotoxy 14,8:?"Note: befriedigend"
1400  if f=4 then gotoxy 14,8:?"Note: ausreichend":?chr$(7)
1410  if f=5 then gotoxy 14,8:?"Note: mangelhaft":?chr$(7):?chr$(7)
1420  if f>=6 then gotoxy 14,8:?"Note: ungenuegend":?chr$(7):?chr$(7):?chr$(7)
1430  gotoxy 14,15:?"Nochmal (j/n)";:input ja$
1440  if ja$="j" then f=0: goto SCHREIBUEBUNG
1450  if ja$<> "j" then goto 360
1460  WORTUEBUNG:
1470  dim da$(200)
1475  'gosub 6180
1480  ?" W O R T U E B U N G "
1490  ?:?spc(19)"Welche Schwierigkeitsstufe (1-12) ";:input sw$
1500  sw=val(sw$): if sw=0 then 1490
1510  for r = 1 to sw*12
1520  read da$(r)
1530  next r
1545  zeit1 = peek(timer)
1550  fe = 0: zl =0
1560  for k = 1 to 20
1570  randomize 0
1580  x = int(rnd(1)*sw*12)+1 : clearw 2 : gotoxy 15,10
1590  ?da$(x)
1600  gotoxy 15,12:?;
1610  for g = 1 to len(da$(x))
1620  i$ = chr$(inp(2))
1630  if i$<>mid$(da$(x), g, 1) then fe = fe+1 : goto 1620
1640  if i$=mid$(da$(x),g,1) then ?i$;: zl= zl+1
1650  next g
1660  gotoxy 15,10:?;
1670  next k
1680  AUSWERTUNG:
1685  gosub 6110
1690  clearw 2 : gotoxy 13,5
1700  ?"A U S W E R T U N G :"
1710  zeit2 = peek(timer)
1720  ti = zeit2 - zeit1
1730  ti=(ti*5/1000)-.8495
1740  ?:?spc(15)"Zeit f"chr$(129)"r 20 W"chr$(148)"rter = "fix(ti)" Sekunden !"
1750  ?:?"     Von "zl" Zeichen "fe" Fehler : "; :?;
1760  di = (fe*100)/zl
1770  if di<=4.5 then?" U E B U N G  B E S T A N D E N ! !": goto 1790
1780  ?"Uebung leider nicht gelungen..."
1790  gotoxy 13,18 : input"N O C H M A L  (j/n)";l$
1800  if l$ = "j" then restore 1820: goto 1475
1810  ? "OK, Schluss fuer Heute !" :sound 1,0,0,0,59 : goto 2100
1820  'Speicherung der Woerter
1830  data "ja","All","Jaffa","als","Saal","Fall","Alaska","falls","Falk","Skala"
1840  data "des","elf","Adel","dieses","edel","Diele","Diesel"
1850  data "jede","Elise","alles"
1860  data "Lauer","sauer","Feier","Rede","darauf","der","du"
1870  data "drei","Ausfall","Frau"
1880  data "helle","Griff","hellere","Herr","Jahre","heraus","rege"
1890  data "hier","gar","ihre"
1900  data "mir","Leim","immer","Verkehrsregel","Vase","Saum","dem","verlassen"
1910  data "viel","Vers","Meer","Versicherung"
1920  data "altes","sagte","und","nun","nehmen","ein","uns"
1930  data "Tag","sagten","hatten","fragten","raten"
1940  data "Zebra","Zeile","ab","zuziehen","Beruf","sitzt","zu","Systemanalyse"
1950  data "zur","zum","zahle"
1960  data "Tasche","Fritz","decken","dick","Nachnahme","Nachname","Eck","mich"
1970  data "dich","ich","sich"
1980  data "wie","war","wo","Westen","wohl","Osten","widerwillig","Widder"
1990  data "woher","Olaf","so","Sonne","Wonne"
2000  data "Einwohnerzahl","max.","bzw.","Texte","im","usw.","z.B."
2010  data "ca.","inkl.","Wiederholung","Zuwiderhandlung","Dialog"
2020  data "Export","bequem","Pappenstiel","parkieren","Qual"
2030  data "Pole","Quarten","Papierwaren","Quinten","Quote","Quatsch"
2040  data "diszipliniert","Exporteur","Expropriation"
2050  data "Flexette","Commodore","poke","Picknick","print","input"
2060  data "Victor","Quelle","Jana","Kurt","Volker","Vulkan"
2070  data "Gerda","Zoo","Hansli","Margrit","Zurbriggen"
2080  data "Cathomen","Zeitverzoegerung","Atari ST","Riteman F"
2090  clearw 2: goto 360
2100  'DISPLAY RECHTECKE MIT MUSTERN
2110  color 1,0,1,1,1:fullw 2: clearw 2
2120  if peek(systab)=1 then 2150
2130  if peek(systyb)=2 then 2160
2140  goto 2170
2150  x=102:y=56:a=28:b=308:c=56:d=51:e=640:f=102:goto 2180
2160  x=102:w=28:a=14:b=154:c=28:d=51:e=640:f=102:goto 2180
2170  x=51:y=28:a=14:b=154:c=28:d=25:e=320:f=51
2180  for x=f to e-d step f
2190  linef x,0,x,400
2200  next x
2210  for y=c to b-a step c
2220  linef 0,y,615,y
2230  next y
2240  i=2:p=1
2250  for y=a to b step c
2260  for x=d to e step f
2270  color 1,1,1,p,i:fill x,y,1
2280  p=p+1:if p=25 then p=1:i=i+1
2290  if i=4 then end
2300  next x,y
2310  gotoxy 11,10:?"                             "
2320  gotoxy 11,10:?"Danke fuer den guten Einsatz!"
2330  gotoxy 11,15:?"                             "
2340  gotoxy 11,15:?"Ihr Trainer : Werner Tscherne"
2350  sound 1,0,0,0,100
2360  end
6110  poke contrl   ,106
6120  poke contrl+ 2,0
6130  poke contrl+6 ,1
6140  poke intin    ,0
6150  vdisys
6160  return
6180  poke contrl   ,106
6190  poke contrl+ 2,0
6200  poke contrl+6 ,1
6210  poke intin    ,16
6220  vdisys
6230  return
