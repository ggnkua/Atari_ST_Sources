5     '**********************************************************************
10    '*                                                                    *
20    '*                         H a B u  ST                                *
30    '*                     (c)1986 by WINSOFT                             *
40    '*                  written by Hartmut G”tze                          *
50    '*           Postfach 5135,  5227 Windeck/Schladern                   *
60    '*               Telefon 92293/2016 ab 17.00 Uhr                      *
70    '*                                                                    *
80    '**********************************************************************
90    '
100   clear
110   '
120   on error goto 4810
130   '
140   goto start
150   '
160   ' Variablen dimensionieren und Werte Rcksetzen oder Einlesen
170   init:
180   dim char(255),kn$(100),rc$(100),js$(100),s(100),ms$(13),ms(13),mt$(12)
190   dim mo(13)
200   ' nochmal alles zurcksetzen da bei einem zweiten start clear nicht
210   ' richtig arbeitet
220   kn=0:ka=0:for i=1 to 13:ms(i)=0:ms$(i)="":mo(i)=0:next i:
230   for i=1 to 12:mt$(i)="":next i:for i=1 to 100:kn$(i)="":rc$(i)=""
240   s(i)=0:js$(i)="":next i:text$="":ms$=""
250   'monatsnamen einlesen
260   for q=1 to 12: read mt$(q):next
270   data "Januar   ","Februar  ","Maerz   ","April    ","Mai      "
280   data "Juni     ","Juli     ","August  ","September","Oktober  "
290   data "November ","Dezember "
300   '
310   aes#=gb:control=peek(aes#):global=peek(aes#+4):gintin=peek(aes#+8)
320   gintout=peek(aes#+12):addrin=peek(aes#+16):addrout=peek(aes#+20)
330   for i=o to 255:char(i)=0:next:char(27)=1:char(13)=2:char(200)=3
340   char(208)=4:char(8)=5:char(127)=5:for i=32 to 165:char(i)=6:next
350   return
360   'grafikmodus w„hlen, weiže schrift schwarzer grund
370   modus:
380   poke contrl,32:poke contrl+2,0:poke contrl+6,1:poke intin,modi
390   vdisys
400   return
410   '
420   rechteck:
430   poke contrl,11:poke contrl+2,2:poke contrl+6,0:poke contrl+10,1
440   poke ptsin,xpos1:poke ptsin+2,ypos1 :poke ptsin+4,xpos2
450   poke ptsin+6,ypos2
460   vdisys
470   return
480   'hoehe der auszugebenden schrift einstellen
490   schrift:
500   poke contrl,107:poke contrl+2,0:poke contrl+6,1
510   poke intin,hoehe:vdisys
520   return
530   'schriftart einstellen
540   art:
550   poke contrl,106:poke contrl+2,0:poke contrl+6,1
560   poke intin, typ
570   vdisys
580   return
590   'textausgabe an beliebiger stelle und in gew.gr”že und art
600   textout:
610   for i=0 to len(text$)-1:poke intin+i*2,asc(mid$(text$,i+1,1))
620   next
630   poke intin+i*2,0
640   poke contrl,8:poke contrl+2,1:poke contrl+6,len(text$)+1
650   poke ptsin,xpos:poke ptsin+2,ypos:vdisys
660   return
670   'rechteck verschwinden lasse
680   schrumpf:
690   kleiner%=1
700   ' rechteck einblenden
710   grossbox:
720   poke contrl+2,8:poke contrl+4,1:poke gintin,xalt:poke gintin+2,yalt
730   poke gintin+4,breit1:poke gintin+6,hoch1:poke gintin+8,xneu
740   poke gintin+10,yneu:poke gintin+12,breit2:poke gintin+14,hoch2
750   gemsys 73+kleiner%
760   kleiner%=0:return
770   'konten bei erststart anlegen
780   anlegen:
790   open "O",#1,"konten.seq"
800   for x=1 to 100:kn$(x)="*":print #1,kn$(x):next x
810   ka=0: close 1
820   '
830   reloff:
840   open "O",#2,"daten.seq"
850   for y=1 to 100:rc$(y)=string$(120,"+")
860   print #2,rc$(y)
870   next y:close 2:merker=0:return
880   '
890   'generator zur texterfassung
900   '
910   aus:
920   poke contrl,8:poke contrl+2,1:poke contrl+6,1:poke ptsin,(sp-1)*8
930   poke ptsin+2,ze*16+19:poke intin,zei:vdisys
940   return
950   antwort:
960   text$=text1$:gosub stringout
970   if len(text2$)>la then text2$=left$(text2$,la)
980   text$=text2$+string$(la-len(text2$),"_")
990   sp=sp+len(text1$):gosub stringout
1000  sp=sp+len(text2$)
1010  nextchar:
1020  zei=95:gosub aus
1030  zei=inp(2)
1040  on char(zei) goto 1060,1090,1100,1110,1120,1150
1050  goto nextchar
1060  sp=sp-len(text2$):text2$=""
1070  text$=string$(la,"_"):gosub stringout
1080  goto nextchar
1090  ba=0:goto jumpb
1100  ba=-1:goto jumpb
1110  ba=1:goto jumpb
1120  if len (text2$)=0 then goto nextchar
1130  text2$=left$(text2$,len(text2$)-1)
1140  sp=sp-1:goto nextchar
1150  if len(text2$)=la then goto nextchar
1160  text2$=text2$+chr$(zei)
1170  gosub aus
1180  sp=sp+1:goto nextchar
1190  jumpb:
1200  return
1210  '
1220  'normal grossen text ausgeben in zeile und spalte
1230  stringout:
1240  poke contrl,8:poke contrl+2,1:poke contrl+6,len(text$)
1250  poke ptsin,(sp-1)*8:poke ptsin+2,ze*16+19
1260  for ta=0 to len(text$)-1:poke intin+ta*2,asc(mid$(text$,ta+1,1))
1270  next ta:vdisys
1280  return
1290  '
1300  'zu buchenden monat angeben
1310  monate:
1320  xneu=5:yneu=315:breit2=250:hoch2=40:xpos1=xneu:ypos1=yneu
1330  xpos2=xneu+breit2:ypos2=yneu+hoch2:color 1,1
1340  gosub grossbox:gosub rechteck:xpos1=xpos2:xpos2=xpos1+25:gosub rechteck
1350  xpos=262:ypos=335:text$=chr$(1):gosub textout
1360  ypos=350:text$=chr$(2):gosub textout
1370  if noch=1 then 1400
1380  mo=0
1390  mo=mo+1
1400  ze=20:sp=2:text$=" Monat :  "+mt$(mo):gosub stringout
1410  w=inp(2)
1420  if w=13 then return
1430  if w=200 then mo=mo+1:if mo=13 then mo=1
1440  if w=200 then goto 1400
1450  if w=208 then mo=mo-2:if mo <=0 then mo=0
1460  if w=208 then goto 1390
1470  end
1480  '
1490  'gewuenschtes konto angeben
1500  konten:
1510  xneu=300:yneu=315:breit2=300:hoch2=40:xpos1=xneu:ypos1=yneu
1520  xpos2=xneu+breit2:ypos2=yneu+hoch2:color 1,1
1530  gosub grossbox:gosub rechteck
1540  xpos1=xpos2:xpos2=xpos1+25:ypos2=ypos2:gosub rechteck
1550  xpos=605:ypos=335:text$=chr$(1):gosub textout
1560  ypos=350:text$=chr$(2):gosub textout
1570  if noch=1 then 1600
1580  kn=0
1590  kn=kn+1
1600  ze=20:sp=40:text$="Kontoname: "+left$(kn$(kn),20)
1610  gosub stringout
1620  w=inp(2):if w=13 then return
1630  if w=200 then kn=kn+1:if kn$(kn)="*" then kn=1
1640  if w=200 then goto 1600
1650  if w=208 then kn=kn-2:if kn <=0 then kn=0
1660  if w=208 then goto 1590
1670  goto 1620
1680  '
1690  '
1700  ' monatssumme ermitteln
1710  mosum:
1720  if len(rc$(kn))<120 then rc$(kn)=" "+rc$(kn):goto 1720
1730  ms$=mid$(rc$(kn),(mo*10-9),10)
1740  if right$(ms$,1)="+" then ms$="      0.00"
1750  ms=val(ms$):return
1760  '
1770  ' summe in string bringen
1780  einf:
1790  ms$=str$(ms):gosub nullen
1800  bu$=string$(10," ")
1810  mid$(bu$,11-len(ms$),len(ms$))=ms$
1820  mid$(rc$(kn),mo*10-9,len(bu$))=bu$
1830  return
1840  '
1850  schreiben:
1860  open "O",#1,"daten.seq"
1870  for y=1 to 100
1880  print #1,rc$(y)
1890  next y
1900  close 1:return
1910  '
1920  'rem mit nullen
1930  nullen:
1940  for h=2 to len(ms$):if mid$(ms$,h,1)="." then vl=h:goto 1960
1950  next h:ms$=ms$+".00":return
1960  if len(ms$) <vl+2 then ms$=ms$+"0":goto 1960
1970  'for h=1 to len(ms$):if mid$(ms$,h,1)="." then vl=x:goto 1660
1980  'next:ms$=ms$+".00":return
1990  'if len(ms$)<vl+1 then ms$=ms$+"0":goto 1660
2000  return
2010  '
2020  ' felder loeschen
2030  nochmal:
2040  color 1,0:gosub rechteck:gosub schrumpf
2050  xneu=100:yneu=80:breit2=400:hoch2=200:xpos1=xneu:ypos1=yneu
2060  xpos2=xneu+breit2:ypos2=yneu+hoch2:gosub rechteck:gosub schrumpf
2070  xneu=300:yneu=315:breit2=325:hoch2=40:xpos1=xneu:ypos1=yneu
2080  xpos2=xneu+breit2:ypos2=yneu+hoch2:gosub rechteck:gosub schrumpf
2090  xneu=5:yneu=315:breit2=275:hoch2=40:xpos1=xneu:ypos1=yneu
2100  xpos2=xneu+breit2:ypos2=yneu+hoch2:gosub rechteck:gosub schrumpf
2110  return
2120  '
2130  'ausgabe drucker oder bildschrim
2140  druckbild:
2150  xneu=525:yneu=80:breit2=100:hoch2=45:xpos1=xneu:ypos1=yneu
2160  xpos2=xneu+breit2:ypos2=yneu+hoch2:color 1,1
2170  gosub grossbox:gosub rechteck
2180  ze=5:sp=67:text$="Drucker  [d]":gosub stringout
2190  ze=6:text$="Monitor  [m]":gosub stringout
2200  wa=inp(2)
2210  if wa=109 then druck=0:return
2220  if wa=100 then druck=1:return
2230  goto 2200
2240  '
2250  ' haubtfeld aufbauen
2260  feldweg:
2270  color 1,0
2280  feldauf:
2290  xneu=100:yneu=80:breit2=400:hoch2=200:xpos1=xneu:ypos1=yneu
2300  xpos2=xneu+breit2:ypos2=yneu+hoch2
2310  if lo=1 then gosub rechteck:gosub schrumpf:lo=0:return
2320  gosub grossbox:gosub rechteck:ypos2=110:gosub rechteck
2330  '
2340  typ=16:gosub art:text$=t$:xpos=120:ypos=100:gosub textout
2350  typ=0:gosub art
2360  return
2370  '
2380  ' druckbild entfernen
2390  druckweg:
2400  xneu=525:yneu=80:breit2=100:hoch2=45:xpos1=xneu:ypos1=yneu
2410  xpos2=xneu+breit2:ypos2=yneu+hoch2
2420  color 1,0:gosub rechteck:gosub schrumpf:return
2430  '
2440  start:
2450  gosub init:color 1,1,1,8,2:fullw 2:clearw 2:out 2,27:out 2,69
2460  xpos1=0:ypos1=0:xpos2=639:ypos2=40:gosub rechteck
2470  modi=3:gosub modus
2480  hoehe=20:gosub schrift:typ=20:gosub art
2490  text$="WINSOFT":xpos=5:ypos=30:gosub textout
2500  typ=0:gosub art:hoehe=5:gosub schrift
2510  text$="Computer":xpos=150:ypos=10:gosub textout
2520  text$="Programm":ypos=20:gosub textout
2530  text$="Service":ypos=30:gosub textout
2540  hoehe=10:gosub schrift:typ=4:gosub art
2550  text$="Pr"+chr$(132)+"sentiert :":xpos=300:ypos=10:gosub textout
2560  hoehe=18:gosub schrift:typ=1:gosub art
2570  text$="H a  B u   ST":xpos=240:ypos=30:gosub textout
2580  hoehe=8:gosub schrift:typ=0:gosub art
2590  text$=chr$(189)+" 1986":xpos=550:ypos=10:gosub textout
2600  text$="by":xpos=550:ypos=20:gosub textout
2610  text$="Hartmut G"+chr$(148)+"tze":xpos=550:ypos=30:gosub textout
2620  hoehe=10:gosub schrift:modi=1:gosub modus
2630  xpos1=0:ypos1=360:xpos2=639:ypos2=399:gosub rechteck
2640  modi=3:gosub modus:hoehe=9:gosub schrift
2650  t$(1)=" F1 Konten"
2660  t$(2)=" F2 Konten"
2670  t$(3)=" F3 Konto-"
2680  t$(4)=" F4 Monats-"
2690  t$(5)=" F5 Jahres-"
2700  t$(6)=" F10 Programm"
2710  xpos=0:ypos=380
2720  for x=1 to 6
2730  text$=t$(x):gosub textout:xpos=xpos+105
2740  next
2750  t$(1)=" Anlegen":t$(3)=" "+chr$(129)+"bersicht"
2760  t$(4)=" "+chr$(129)+"bersicht":t$(2)=" buchen"
2770  t$(5)=" "+chr$(129)+"bersicht":t$(6)=" beenden"
2780  xpos=0:ypos=398
2790  for x=1 to 6:text$=t$(x):gosub textout:xpos=xpos+105
2800  next:hoehe=10:gosub schrift
2810  modi=1:gosub modus
2820  xalt=0:yalt=30:breit1=40:hoch1=60:xneu=230:yneu=200:breit2=200
2830  hoch2=60
2840  color 1,1,0,0,0:xpos1=xneu:ypos1=yneu:xpos2=xneu+breit2
2850  ypos2=yneu+hoch2
2860  gosub grossbox:gosub rechteck
2870  Text$="Datendiskette Einlegen":xpos=238:ypos=225:gosub textout
2880  Text$="Mit Return Best"+chr$(132)+"tigen"
2890  xpos=238:ypos=245:gosub textout
2900  warte=inp(2):if warte<>13 then 2900
2910  color 1,0:gosub rechteck:gosub schrumpf
2920  open"I",#1,"konten.seq"
2930  if merker=0 then goto 3100
2940  xneu=150:yneu=90:breit2=320:hoch2=200:xpos1=xneu:ypos1=yneu
2950  xpos2=xneu+breit2:ypos2=yneu+hoch2:color 1,1
2960  gosub grossbox:gosub rechteck
2970  text$="Auf der eingelegten Diskette befinden":xpos=160:ypos=120
2980  gosub textout
2990  text$="sich nicht die f"+chr$(129)+"r das Programm"
3000  ypos=140:gosub textout
3010  text$="erforderlichen Dateien !":ypos=160:gosub textout
3020  text$="F1 ERSTSTART Dateien anlegen  ":ypos=200:gosub textout
3030  text$="F2 DISK GEWECHSELT   ":ypos=250:gosub textout
3040  text$="   nochmals Lesen":ypos=270:gosub textout
3050  wahl=inp(2):if wahl =27 then end
3060  if wahl <187 or wahl >188 then goto 3050
3070  color 1,0:gosub rechteck:gosub schrumpf
3080  if wahl=188 then close 1:merker=0:goto 2920
3090  if wahl=187 then close 1:gosub anlegen:goto 3230
3100  x=0
3110  if eof(1)=-1 then close 1:goto 3140
3120  x=x+1:input#1,kn$(x)
3130  goto 3110
3140  for i=1 to 100:if kn$(i)="*" then ka=i-1:i=100
3150  next i
3160  open "I",#1,"daten.seq"
3170  x=0
3180  if eof(1)=-1 then close 1:goto haubtabfrage
3190  x=x+1:input#1,rc$(x)
3200  goto 3180
3210  '
3220  haubtabfrage:
3230  xneu=250:yneu=150:breit2=120:hoch2=50:xpos1=xneu:ypos1=yneu:color 1,1
3240  xpos2=xneu+breit2:ypos2=yneu+hoch2:gosub grossbox:gosub rechteck
3250  xpos=270:ypos=180:text$="Ihre Wahl ?":gosub textout
3260  '
3270  wahl=inp(2):if wahl=27 then end
3280  if wahl =196 then end
3290  if wahl <187 or wahl >191 then goto haubtabfrage
3300  on wahl-186 gosub kontoan,kontobuch,konto,monat,jahr
3310  goto haubtabfrage
3320  'konten anlegen
3330  kontoan:
3340  t$="Konten Anlegen":color 1,1:gosub feldauf
3350  text$="Konto Nr.:":xpos=350:gosub textout
3360  schleife:
3370  ka=ka+1:text$=str$(ka):xpos=440:ypos=100:gosub textout
3380  ze=9:sp=16:la=20:text1$="Kontoname:":kn$(ka)="":text2$=kn$(ka)
3390  gosub antwort:if text2$="" or ba >0 then kn$(ka)="*":ka=ka-1:goto 3480
3400  kn$(ka)=text2$
3410  if ba=-1 then 3380
3420  ze=11:sp=16:la=3:text1$="Kontoart :":ka$="aus":text2$=ka$
3430  gosub antwort:ka$=text2$
3440  if ba=-1 then 3380
3450  help$=kn$(ka)+string$(20-len(kn$(ka))," "):kn$(ka)=help$
3460  kn$(ka)=kn$(ka)+ka$
3470  goto schleife
3480  ypos2=280:lo=1:gosub feldweg
3490  xneu=180:yneu=140:breit2=230:hoch2=90:xpos1=xneu:ypos1=yneu
3500  xpos2=xneu+breit2:ypos2=yneu+hoch2:color 1,1
3510  gosub grossbox:gosub rechteck
3520  text$="Die angelegten Konten":xpos=210:ypos=170:gosub textout
3530  text$="werden nun auf der":ypos=190:gosub textout
3540  text$="Diskette gesichert.":ypos=210:gosub textout
3550  ' daten sequentiell abspeichern
3560  open "O",#1,"konten.seq"
3570  for i=1 to 100:print#1,kn$(i):next i:close 1
3580  '
3590  color 1,0:gosub rechteck:gosub schrumpf:goto haubtabfrage
3600  'konten buchen
3610  kontobuch:
3620  gosub monate:gosub konten
3630  t$="Konten Buchen":color 1,1:gosub feldauf
3640  '
3650  xpos=350:text$="Konto Nr.:":gosub textout
3660  xpos=440:text$=str$(kn):gosub textout
3670  ms=0:bt=0
3680  gosub mosum
3690  ze=16:sp=16:text$="Summe: "+ms$:gosub stringout
3700  ze=9:sp=16:la=10:text1$="Betrag: ":bt$="":text2$=bt$
3710  gosub antwort
3720  if text2$="" then end
3730  bt$=text2$:bt=val(bt$)
3740  ze=11:sp=16:la=5:text1$="Plus/Minus: ":pm$="":text2$="plus"
3750  gosub antwort
3760  if ba=-1 then goto 3700
3770  pm$=text2$
3780  'if pm$<>"plus" and pm$<>"minus" and pm$<>"+" and pm$<>"-" then goto 7180
3790  if pm$="plus" or pm$="+" then ms=ms+bt:goto 3810
3800  ms=ms-bt
3810  gosub einf:text$=""
3820  ze=13:sp=16:text$="Gebuchter Betrag: "+ms$:gosub stringout
3830  xneu=360:yneu=210:breit2=122:hoch2=25:xpos1=xneu:ypos1=yneu
3840  xpos2=xneu+breit2:ypos2=yneu+hoch2
3850  gosub grossbox:color 1,1:gosub rechteck
3860  sp=47:ze=13:text$="Nochmal j/n ? ":gosub stringout
3870  wa=inp(2)
3880  if wa=106 then gosub nochmal:noch=1:goto kontobuch
3890  if wa=110 then noch=0:goto 3910
3900  if wa=27 then end
3910  close 1:close 2:gosub nochmal:gosub schreiben:gosub haubtabfrage
3920  '
3930  ' uebersicht ueber ein einzelnes konto
3940  konto:
3950  gosub konten:gosub druckbild:if noch=1 then goto 3970
3960  t$="Konto"+chr$(129)+"bersicht":color 1,1:gosub feldauf
3970  ze=8
3980  for i=1 to 6
3990  mo=i:gosub mosum
4000  sp=15:ze=ze+1:text$=mt$(mo):gosub stringout
4010  sp=(36-len(ms$)):text$=ms$:gosub stringout
4020  next i
4030  ze=8
4040  for i=7 to 12
4050  mo=i:gosub mosum
4060  sp=40:ze=ze+1:text$=mt$(mo):gosub stringout
4070  sp=(62-len(ms$)):text$=ms$:gosub stringout
4080  next i
4090  sp=25:ze=ze+2:text$="Noch ein Konto ? j/n":gosub stringout
4100  wa=inp(2)
4110  if wa= 106 then noch=1:goto 4150
4120  if wa=110 then noch=0:goto 4180
4130  goto 4100
4140  ' kein weiteres konto
4150  xneu=110:yneu=120:breit2=380:hoch2=157:xpos1=xneu:ypos1=yneu
4160  xpos2=xneu+breit2:ypos2=yneu+hoch2:color 1,0
4170  gosub rechteck
4180  color 1,0:xneu=300:yneu=315:breit2=330:hoch2=40:xpos1=xneu:ypos1=yneu
4190  xpos2=xneu+breit2:ypos2=yneu+hoch2
4200  gosub rechteck:gosub schrumpf
4210  gosub druckweg
4220  if noch=1 then goto konto
4230  lo=1:gosub feldweg
4240  goto haubtabfrage
4250  '
4260  ' uebersicht ueber einen bestimmten monat
4270  monat:
4280  gosub monate:gosub druckbild
4290  t$="Monats"+chr$(129)+"bersicht":color 1,1:gosub feldauf
4300  '
4310  moein=0:moaus=0:sp=18:ze=6
4320  for x=1 to ka:kn=x
4330  gosub mosum:if right$(kn$(x),1)="n" then moein=moein+ms
4340  if right$(kn$(x),1)="s" then moaus=moaus+ms
4350  ze=ze+1:text$=kn$(x)+"     "+ms$:gosub stringout
4360  if x=8 then ze=ze+2:text$="Taste":sp=38:gosub stringout:a=inp(2)
4370  if x=8 then xneu=110:yneu=120:breit2=380:hoch2=157:xpos1=xneu:ypos1=yneu
4380  if x=8 then xpos2=xneu+breit2:ypos2=yneu+hoch2:color 1,0:gosub rechteck
4390  if x=8 then ze=6:sp=18
4400  next x
4410  ms$=str$(moein):gosub nullen:me$=ms$:ms$=""
4420  ms$=str$(moaus):gosub nullen:ma$=ms$:ms$=""
4430  ze=ze+2:text$="Einnahmen: "+me$+"  Ausgaben: "+ma$:gosub stringout
4440  a=inp(2):gosub druckweg
4450  gosub nochmal:goto haubtabfrage
4460  jahr:
4470  ' jahresuebersicht der einzelnen konten
4480  xneu=250:yneu=150:breit2=120:hoch2=50:xpos1=xneu:ypos1=yneu:color 1,1
4490  xpos2=xneu+breit2:ypos2=yneu+hoch2:gosub grossbox:gosub rechteck
4500  xpos=270:ypos=180:text$="Ich Rechne!":gosub textout
4510  '
4520  mo=0
4530  for x=1 to ka :kn=x
4540  for y=1 to 12:mo=y:gosub mosum:s(x)=s(x)+ms
4550  next y
4560  next x
4570  for x=1 to ka
4580  if right$(kn$(x),1)="n" then je=je+s(x)
4590  if right$(kn$(x),1)="s" then ja=ja+s(x)
4600  next x
4610  ms$=str$(je):gosub nullen:je$=ms$:ms$=""
4620  ms$=str$(ja):gosub nullen:ja$=ms$:ms$=""
4630  for x=1 to ka
4640  ms$=str$(s(x)):gosub nullen:js$(x)=ms$:ms$=""
4650  next x
4660  gosub druckbild
4670  color 1,1:t$="Jahres"+chr$(129)+"bersicht":gosub feldauf
4680  sp=18
4690  for x=1 to ka:kn=x
4700  ze=ze+1:text$=kn$(x):gosub stringout:text$=js$(x)
4710  sp=(60-len(js$(x))):gosub stringout:sp=18
4720  if x=8 then ze=ze+2:text$="Taste":sp=38:gosub stringout:a=inp(2)
4730  if x=8 then xneu=110:yneu=120:breit2=380:hoch2=157:xpos1=xneu:ypos1=yneu
4740  if x=8 then xpos2=xneu+breit2:ypos2=yneu+hoch2:color 1,0:gosub rechteck
4750  if x=8 then ze=6:sp=18
4760  next x
4770  sp=24:ze=ze+1:text$="Jahreseinnahmen: "+je$:gosub stringout
4780  ze=ze+1:      text$="Jahresausgaben : "+ja$:gosub stringout
4790  w=inp(2):lo=1:gosub feldweg:gosub druckweg
4800  for i=1 to 100:s(i)=0:js$(i)="":next:je=0:ja=0:goto haubtabfrage
4805  '
4810  zeile=erl
4820  if err=53 then merker=1:resume 2930
4830  end
