10    '*********************************************************
20    '* BIORHYTMUS ST.   von Wolfgang Wenk                    *
21    '* Hauptstr.22,2167 Himmelpforten, [04144/8678]          *
22    '* ----------> kopieren erlaubt <----------------------- *
29    '* INPUTFORM von M.Vagts, Stade                          *
30    '*********************************************************
31    '------------------------------------> init
35    clearw 2:fullw 2
40    pi =-2* 3.14159:r=8
50    dim monattage%(13), tagesname$(7)
60    for i = 1 to 13
70    read monattage%(i)
80    next
90    '
140   for i = 1 to 7
150   read tagesname$(i)
160   next
170   '
190   '---------------------------------> titelbild
200   dim xkoord(100),ykoord(100)
210   '
250   '
260   gosub INIT
270   gosub CLEARDESK
280   gosub FULLWIND
290   color 1,1,1,2,2
300   xpos1=0  :ypos1=-15:xpos2=640:ypos2=-38
310   gosub RECHTECK
320   text$=chr$(14)+chr$(15)+" BIORHYTHMUS "+chr$(14)+chr$(15)
330   xpos=230:ypos=-20:gosub TEXTAUSGABE
331   clearw 2
335   anfangsform=0:endform=1
336   gosub LINIENENDFORM
337   linef 200,150,450,150
340   xpos1=130:ypos1=15:xpos2=500:ypos2=250:fuell=0
350   gosub RECHTECKRUND
360   xpos1=132:ypos1=17:xpos2=502:ypos2=252:fuell=0
370   gosub RECHTECKRUND
380   groesse=18:gosub schriftgroesse
390   text$=chr$(14)+chr$(15)+" BIORHYTHMUS "+chr$(14)+chr$(15)
400   xpos=175:ypos=45
410   gosub textausgabe
420   groesse=9:gosub schriftgroesse
430   text$=chr$(189)+" W.Wenk 1986 "
440   xpos=260:ypos=55
450   gosub textausgabe
460   anzahl=30
470   for i = 0 to anzahl
480   xkoord(i)=230+i*200/anzahl
490   ykoord(i)= 80+rnd(1)*100
500   next
510   gosub POLYLINE
520   text$="ErklÑrung [J]"
530   xpos=148:ypos=230
540   gosub textausgabe
550   text$="oder kann ich mir das sparen ? [RETURN]"
560   xpos=148:ypos=240
570   gosub textausgabe
580   gosub normtext
590   out 2,7:a$=chr$(inp(2))
600   if asc(a$)=13 then goto DIAGRAMM
610   if asc(a$)=106 then goto INFO
620   if asc(a$)<> 13 or asc(a$)<>106 then 590
621   '
622   '---------------------------------> eingabe
623   '
630   DIAGRAMM:
640   clearw 2
650   groesse=19:gosub schriftgroesse
660   schrifttyp=1:gosub schriftart
670   text$="Klasse, ":xpos=50:ypos=40
680   gosub textausgabe
690   gosub normtext
700   text$="...dann kînnen wir ja loslegen:"
710   xpos=150:ypos=40:gosub textausgabe
720   color 1,1,1,1,1
730   xpos1=40:ypos1=45:xpos2=560:ypos2=80
740   gosub RECHTECK
750   color 1,1,0,0,0
760   xpos1=40:ypos1=81:xpos2=560:ypos2=350
770   gosub RECHTECK
780   text$=" Meine Fragen:":xpos=50:ypos=68
790   gosub textausgabe
800   text$=" Deine Antworten:":xpos=400:ypos=68
810   gosub textausgabe
820   out 2,7:text$="Dein Name:":xpos=45:ypos=100
825   gosub textausgabe
830   xpos=420:ypos=100:laenge=10:modus=3:groesse=10:gosub INPUTFORM
835   name$=key$
850   '
860   out 2,7:text$="..und Dein Geburtsdatum "+name$
870   xpos=45 :ypos=120:gosub textausgabe
875   xpos=45:ypos=138:text$="[z.B. 1.Aug.1960 = 01081960]":gosub textausgabe
878   xpos=420:ypos=138:text$="       ":gosub textausgabe
880   xpos=420:ypos=138:laenge=8 :modus=1:groesse=10:gosub INPUTFORM
885   gebdat$=key$
887   if len(gebdat$)<8 then goto 10000
888   if (val(mid$(gebdat$,3,2))>12) or(val(left$(gebdat$,2))>31) then goto 10000
890   if (val(mid$(gebdat$,3,2))<=0) or (val(left$(gebdat$,2))<=0) then goto 10000
891   '
892   '---------------------------------> wochentag der geburt
893   '
900   gebtag=val(left$(gebdat$,2))
910   gebmon=val(mid$(gebdat$,3,2))
920   gebjah=val(right$(gebdat$,4))
930   gebmon=int(gebmon)
940   gebtag=int(gebtag)
950   gebjah=int(gebjah)
960   tageab =int(gebtag+365.25 * gebjah+monattage% (gebmon) +.01 * gebmon - .03)
970   k=int(.6+(1/gebmon))
980   l=gebjah-k
990   o= gebmon + 12 * k
1000  p= l/100
1010  z1= int(p/4)
1020  z2= int (p)
1030  z3= int((5*l)/4)
1040  z4= int(13*(o+1)/5)
1050  z = z4 + z3 - z2 + z1 + gebtag - 1
1060  z = (z-(7*int(z/7)))+1
1080  out 2,7:text$="FÅr welchen Monat soll ich die Kurve berechnen? "
1090  xpos=45:ypos=180:gosub textausgabe
1100  text$="[z.B. MAI 1986 = 051986]"
1110  xpos=45:ypos=200:gosub textausgabe
1115  xpos=420:ypos=200:text$="        ":gosub textausgabe
1120  xpos=420:ypos=200:laenge=6 :modus=1:groesse=10:gosub INPUTFORM
1125  start$ ="01"+ key$
1126  if len(start$)<8 then goto 11010
1128  if (val(mid$(start$,3,2))>12) then goto 11010
1129  '
1130  '---------------------------------> gesamttage berechnen
1135  '
1140  bistag=val(left$(start$,2))
1150  bismon=val(mid$(start$,3,2))
1160  bisjah=val(right$(start$,4))
1170  bismon=int(bismon)
1180  bistag=int(bistag)
1190  bisjah=int(bisjah)
1200  tagebis=int(bistag+365.25 * bisjah+monattage%(bismon) +.01 * bismon - .03)
1210  altertage= tagebis - tageab
1230  xalt=55:yalt=220:breit1=40:hoch1=40
1240  xneu=55 :yneu=250:breit2=300:hoch2=100
1250  color 1,1,0,0,0
1270  xpos1=55 :ypos1=230:xpos2=540:ypos2=340
1280  gosub GROWBOX:gosub RECHTECK
1290  schrifttyp=16:gosub schriftart
1300  groesse=10:gosub schriftgroesse
1310  text$="Das erste Zwischenergebnis:
1320  xpos=53 :ypos=223:gosub textausgabe
1330  schrifttyp=17:gosub schriftart
1340  groesse= 9:gosub schriftgroesse
1350  text$="Du warst am Letzten des Vormonats"+str$(altertage)+" Tage"
1360  xpos=70 :ypos=260:gosub textausgabe
1370  text$="alt und bist an einem "+tagesname$(z)+" geboren !"
1380  xpos=70 :ypos=272:gosub textausgabe
1390  schrifttyp= 1:gosub schriftart
1400  text$="-----------------------------------------------------"
1410  xpos=70:ypos=290:gosub textausgabe
1420  text$="Wenn Du Dich Åber dieses Ergebnis genug gefreut hast,"
1430  xpos=70 :ypos=310:gosub textausgabe
1440  text$="drÅcke bitte eine Taste, damit's weitergeht !!"
1450  xpos=70 :ypos=319:gosub textausgabe
1460  out 2,7:  warte=inp(2)
1470  gosub SCHRUMPFBOX
1480  gosub normtext
1489  '
1490  '---------------------------------> berechnen kurvenfaktor
1491  '
1500  ps=23*(altertage/23-int(altertage/23)):'----> koerper (physisch)
1510  es=28*(altertage/28-int(altertage/28)):'----> gefuehl (emotion)
1520  is=33*(altertage/33-int(altertage/33)):'----> geist   (intellekt)
1521  '---------------------------------> bildschirm
1530  clearw 2
1540  xalt=8:yalt=150:breit1=140:hoch1=140
1550  xneu=8  :yneu=150:breit2=590:hoch2=150
1560  xpos1=8:ypos1=1:xpos2=590:ypos2=150
1570  color 1,1,1,1,2
1580  gosub GROWBOX:gosub RECHTECK
1581  xalt=8:yalt=570:breit1=140:hoch1=140
1582  xneu=158:yneu=350:breit2=590:hoch2=150
1590  xpos1=8:ypos1=150:xpos2=590:ypos2=300
1600  gosub GROWBOX:gosub RECHTECK
1610  groesse= 9:gosub schriftgroesse
1620  modus=1:gosub GRAFIKMODUS
1630  text$="1       5         10          15          20        25        30     34"
1640  xpos=12:ypos=295:gosub textausgabe
1645  modus=1:gosub GRAFIKMODUS
1650  '
1660  schrifttyp=16:gosub schriftart
1670  groesse=10:gosub schriftgroesse
1680  text$="fÅr "+name$
1690  xpos=10:ypos=-3 :gosub textausgabe
1700  text$="* "+left$(gebdat$,2)+"."+mid$(gebdat$,3,2)+"."+right$(gebdat$,4)
1710  xpos=470:ypos=-3 :gosub textausgabe
1720  groesse=19:gosub schriftgroesse
1730  text$="+":xpos=600:ypos=90 :gosub textausgabe
1740  text$="-":xpos=600:ypos=210:gosub textausgabe
1750  gosub normtext
1760  schrifttyp=8:gosub schriftart
1770  text$="Es bedeutet:":xpos=10 :ypos=320:gosub textausgabe
1780  gosub normtext
1790  text$=" * = physisch/Kîrper":xpos=105:ypos=320:gosub textausgabe
1800  text$=" + = Emotion/GefÅhl ":xpos=105:ypos=335:gosub textausgabe
1810  text$=" - = Intellekt/Geist":xpos=105:ypos=350:gosub textausgabe
1820  groesse=19:gosub schriftgroesse
1830  schrifttyp=16:gosub schriftart
1840  text$=str$(bismon)+"/"+str$(bisjah)
1850  xpos=330:ypos=320:gosub textausgabe
1860  gosub normtext
1870  groesse=9:gosub schriftgroesse
1880  text$="[RETURN] = neuer Monat "
1890  xpos=330:ypos=335:gosub textausgabe
1900  text$="[SPACE]  = neue Daten"
1910  xpos=330:ypos=344:gosub textausgabe
1920  text$=" * = FEIERABEND !!"
1930  xpos=335:ypos=353:gosub textausgabe
1940  gosub normtext
1950  modus=2:gosub GRAFIKMODUS
1960  '---------------------------------> physisch
1970  for kurve = 1 to 34
1980  p=r+r*sin((ps+kurve)*pi/23)+1.5
1990  gotoxy kurve,p:print "*"
2000  next
2020  '---------------------------------> emotion
2030  for kurve1= 1 to 34
2040  e=r+r*sin((es+kurve1)*pi/28)+1.5
2050  gotoxy kurve1,e:print "+"
2060  next
2080  '---------------------------------> intellekt
2090  for kurve2= 1 to 34
2100  i=r+r*sin((is+kurve2)*pi/33)+1.5
2110  gotoxy kurve2,i:print "-"
2120  next
2130  '
2140  modus=1:gosub GRAFIKMODUS
2150  out 2,7:a$=chr$(inp(2))
2160  if asc(a$)=13 then goto WEITER
2170  if asc(a$)=32 then goto DIAGRAMM
2180  if asc(a$)=42 then goto ENDE
2181  '
2182  '---------------------------------> ende
2183  '
2190  ENDE:
2200  clearw 2
2201  color 1,1,0,0,0
2202  xpos1=110:ypos1=80:xpos2=440:ypos2=220
2203  gosub RECHTECK
2204  xpos1=112:ypos1=82:xpos2=446:ypos2=226:gosub RECHTECK
2205  color 1,1,1,1,1
2208  xpos1=130:ypos1=100:xpos2=420:ypos2=200
2209  gosub RECHTECK
2210  color 1,1,1,9,2
2212  xpos=133:ypos=148:xpos2=423:ypos2=205
2215  gosub RECHTECK
2219  groesse=19:gosub schriftgroesse
2220  schrifttyp=1 :gosub schriftart
2230  text$=" T s c h Å û "
2240  xpos=160:ypos=150:gosub textausgabe
2250  out 2,7:
2260  gosub normtext
2270  warte=inp(2)
2280  end
2281  '
2282  '---------------------------------> info
2283  '
2290  INFO:
2300  clearw 2:gotoxy 0,0
2310  schrifttyp=24:gosub schriftart
2320  xpos=150:ypos=20:text$=" Was ist der BIORHYTHMUS ?? "
2330  gosub textausgabe
2340  gosub normtext
2350  schrifttyp=4:gosub schriftart
2360  text$="BIORHYTHMUS hat nichts mit Tanzen zu tun,wie Du vielleicht denkst."
2370  xpos=50 :ypos=40:gosub textausgabe
2380  text$="Schon die alten Griechen glaubten, daû das Leben in bestimmten   "
2390  xpos=50 :ypos=55 :gosub textausgabe
2400  text$="Zyklen ablÑuft. Die Zyklen beginnen bei der Geburt als Sinuskurve"
2410  xpos=50 :ypos=70 :gosub textausgabe
2420  text$="zu laufen:"
2430  xpos=50 :ypos=85 :gosub textausgabe
2440  text$="1. Der PHYSISCHE     Zyklus = 23 Tage  ( * )"
2450  xpos=100:ypos=115:gosub textausgabe
2460  text$="2. Der EMOTIONALE    Zyklus = 28 Tage  ( + )"
2470  xpos=100:ypos=130:gosub textausgabe
2480  text$="3. Der INTELEKTUELLE Zyklus = 33 Tage  ( - )"
2490  xpos=100:ypos=145:gosub textausgabe
2500  text$="Kritisch sind immer nur die Tage, an denen sich die Kurve mit der"
2510  xpos=50 :ypos=175:gosub textausgabe
2520  text$="Mittelachse kreuzt. Viele Leute glauben daran, daû man an diesen "
2530  xpos=50 :ypos=190:gosub textausgabe
2540  text$="Tagen hÑufiger Fehler macht, UnfÑlle passieren oder man kîrperlich"
2550  xpos=50 :ypos=205:gosub textausgabe
2560  text$="anfÑlliger ist. Sollte sich fÅr Dich ergeben, daû heute ein      "
2570  xpos=50 :ypos=220:gosub textausgabe
2580  text$="kritischer Tag ist, und Du machst keinen Fehler, Dir fÑllt kein  "
2590  xpos=50 :ypos=235:gosub textausgabe
2600  text$="Ziegelstein auf den Kopf oder Du hast keinen Nervenzusammenbruch,"
2610  xpos=50 :ypos=250:gosub textausgabe
2620  text$="mach' mich bitte nicht dafÅr verantwortlich!"
2630  xpos=50 :ypos=265:gosub textausgabe
2640  text$="Die Kurve zeichne ich Åbrigens fÅr 34 Tage ab 1. des jew.Monats !"
2650  xpos=50 :ypos=280:gosub textausgabe
2660  groesse=19:gosub schriftgroesse
2670  schrifttyp=16:gosub schriftart
2680  text$="Alles klar ???? "
2690  xpos=150:ypos=330:gosub textausgabe
2700  groesse=9:gosub schriftgroesse
2710  schrifttyp=0:gosub schriftart
2720  text$="Bitte irgendeine Taste drÅcken !"
2730  xpos=150:ypos=340
2740  gosub textausgabe
2750  a$=chr$(inp(2))
2760  gosub normtext
2770  goto DIAGRAMM
2780  data 0,31,59,90,120,151,181,212,243,273,304,334,365
2800  data Sonntag,Montag,Dienstag,Mittwoch,Donnerstag,Freitag,Samstag
2801  '
2802  '---------------------------------> naechster Monat
2803  '
2900  WEITER:
2910  bismon=bismon+1
2920  if bismon=13 then bismon=1:bisjah=bisjah+1
2930  goto 1170
2997  '
2998  '---------------------------------> gem-routinen
2999  '
3100  FULLWIND:
3110  poke  gintin,3
3120  poke  gintin+2,5
3130  poke  gintin+4,0
3140  poke  gintin+6,1
3150  poke  gintin+8,658
3160  poke  gintin+10,417
3170  gemsys 105
3180  return
3190  '----------------------------------------
3200  CLEARDESK:
3210  color 1,0,1 :
3220  xpos1=-1:xpos2=638:ypos1=-40:ypos2=-20
3230  gosub rechteck:color 1,1,1
3240  return
3250  '-------------------------------------
3260  SCHRUMPFBOX:
3270  schrumpf% = 1
3280  GROWBOX:
3290  poke control+2,8
3300  poke control+4,1
3310  poke gintin,   xalt
3320  poke gintin+2, yalt
3330  poke gintin+4, breit1
3340  poke gintin+6, hoch1
3350  poke gintin+8, xneu +1
3360  poke gintin+10,yneu +38
3370  poke gintin+12,breit2
3380  poke gintin+14,hoch2
3390  gemsys 73 + schrumpf%
3400  schrumpf% = 0
3410  return
3420  '---------------------------------
3440  INIT:
3450  aes#=gb
3460  control=peek(aes#)
3470  global =peek(aes#+4)
3480  gintin =peek(aes#+8)
3490  gintout=peek(aes#+12)
3500  addrin =peek(aes#+16)
3510  addrout=peek(aes#+20)
3520  return
3530  '--------------------
3540  RECHTECK:
3550  POKE CONTRL   ,11
3560  POKE CONTRL+2 ,2
3570  POKE CONTRL+6 ,0
3580  POKE CONTRL+10,1
3590  POKE PTSIN  ,XPOS1 +1
3600  POKE PTSIN+2,YPOS1 +38
3610  POKE PTSIN+4,XPOS2 +1
3620  POKE PTSIN+6,YPOS2 +38
3630  VDISYS
3640  RETURN
3650  '-----------------------------------
3660  RECHTECKRUND:
3670  POKE CONTRL   ,11
3680  POKE CONTRL+2 ,2
3690  POKE CONTRL+6 ,0
3700  IF FUELL=0 THEN POKE CONTRL+10,8 ELSE POKE CONTRL+10,9
3710  POKE PTSIN  ,XPOS1 +1
3720  POKE PTSIN+2,YPOS1 +38
3730  POKE PTSIN+4,XPOS2 +1
3740  POKE PTSIN+6,YPOS2 +38
3750  VDISYS
3760  RETURN
3770  '-----------------------------------
3780  LINIENENDFORM:
3790  POKE CONTRL   ,108
3800  POKE CONTRL+2 ,1
3810  POKE CONTRL+6 ,0
3820  POKE INTIN, ANFANGSFORM
3830  POKE INTIN+2, ENDFORM
3840  VDISYS
3850  RETURN
3860  '-----------------------------------
3870  SCHRIFTART:
3880  poke contrl  ,106
3890  poke contrl+2,0
3900  poke contrl+6,1
3910  poke intin ,schrifttyp
3920  vdisys
3930  return
3940  '---------------------------------------------
3950  SCHRIFTGROESSE:
3960  poke contrl  ,107
3970  poke contrl+2,0
3980  poke contrl+6,1
3990  poke intin ,groesse
4000  vdisys
4010  return
4020  '---------------------------------------------
4030  TEXTAUSGABE:
4040  for i=0 to len(text$)-1
4050  poke intin+i*2,asc(mid$(text$,i+1,1))
4060  next
4070  poke intin+i*2,0
4080  poke contrl,8
4090  poke contrl+2,1
4100  poke contrl+6,len(text$)+1
4110  poke ptsin , xpos+1
4120  poke ptsin+2,ypos+38
4130  vdisys
4140  return
4150  '---------------------------------------------
4160  GRAFIKMODUS:
4170  poke contrl,32
4180  poke contrl+2,0
4190  poke contrl+6,1
4200  poke intin,modus
4210  vdisys
4220  return
4230  '-------------------------------
4240  POLYLINE:
4250  poke contrl,6
4260  poke contrl+6,0
4270  poke contrl+2,anzahl
4280  for i = 0 to anzahl
4290  poke ptsin + i*4,xkoord(i)+1
4300  poke ptsin + 2+i*4,ykoord(i)+38
4310  next
4320  vdisys
4330  return
4340  '-------------------------------
4350  NORMTEXT:
4360  schrifttyp=0:gosub schriftart
4370  groesse=10  :gosub schriftgroesse
4380  modus=1:gosub grafikmodus
4390  return
4399  '
4410  '------------------------------> input
4411  '
4420  INPUTFORM:
4430  if groesse < 9 then space = 6
4440  if groesse = 9 then space = 8
4450  if groesse > 8 and groesse < 16 then space = 8
4460  if groesse > 15 and groesse < 18 then space = 12
4470  if groesse > 17 then space = 16
4480  gosub SCHRIFTGROESSE
4490  key$=""
4500  text$(1)="0123456789"
4510  text$(2)=text$(1)+"."
4520  text$(3)=" abcdefghijklmnopqrstuvwxyzÑîÅABCDEFGHIJKLMNOPQRSTUVWXYZéôöû"
4530  text$(4)=text$(1)+text$(3)
4540  text$(5)=text$(4)+"<>,;.:-_!›$%&/()=?`'^#*+@\[]{}~|"+chr$(34)
4550  text$(6)="jJnN"
4560  text$(7)="KANN NOCH FREI BELEGT WERDEN !"
4570  text$(8)="KANN NOCH FREI BELEGT WERDEN !"
4580  if modus <> 0 then text$(0) = text$(modus)
4590  text$=chr$(4):gosub textausgabe
4600  if laenge=0 and len(key$)=1 then gosub normtext:return
4610  key=inp(2)
4620  if key=8or key=127 then 4670
4630  if key = 13 then text$=" ":gosub textausgabe:gosub normtext:return
4640  if len(key$) = laenge and len(key$) >0 then out 2,7 : goto 4600
4650  if modus<9then if instr(0,text$(0),chr$(key))=0then out 2,7:goto 4600
4660  key$=key$+chr$(key):text$=chr$(key)+chr$(4):gosub textausgabe:xpos=xpos+space:goto 4600
4670  '********** Fehlerauswertung **************************
4680  if len(key$)=0 then out 2,7 : goto 4600
4690  key$=left$(key$,len(key$)-1)
4700  xpos=xpos-space : text$=chr$(4)+" " : gosub textausgabe
4710  goto 4600
4720  '********************************************************
9998  '
9999  '---------------------------------> falsches datum
10000 '
10015 modus=4:gosub grafikmodus
10020 xpos=270:ypos=138:text$="FALSCHES DATUM !!":gosub textausgabe
10025 out 2,7:out 2,7
10030 for w=1 to 2000: next w
10035 gosub normtext
10040 xpos=270:ypos=138:text$="                 ":gosub textausgabe
10050 goto 860
11010 modus=4:gosub grafikmodus
11020 xpos=250:ypos=200:text$="FALSCHES DATUM !!":gosub textausgabe
11025 out 2,7:out 2,7
11030 for w=1 to 2000: next w
11035 gosub normtext
11040 xpos=250:ypos=200:text$="                 ":gosub textausgabe
11050 goto 1080
