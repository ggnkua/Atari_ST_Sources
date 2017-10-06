10    '-----------------------------------------------
20    '          KASSETTENLAYOUT ATARI ST
30    '        (C) 05.1986  BY  RAINER DUDA
40    '        Version 3.01  (complete version)
50    '-----------------------------------------------
60    '
70    START:
80    clear
90    dim a$(2,40),pret$(2,40),count$(2,40),al(40)
100   for i=1 to 36:' Anzahl der Lieder
110   for t=1 to 2 :' Anzahl der Seiten
120   a$(t,i)="...":pret$(t,i)="...":count$(t,i)="...":al(i)=0
130   next t,i
140   td=0
150   fullw 2:clearw 2:width 80:gotoxy 0,0:restore
160   out 2,27:out 2,69:out 2,27:out 2,89:out 2,46:out 2,71:out 2,27:out 2,102
170   '
180   '*******************************************
190   '  Unter ta$-tf$ kann die Ausdruckart,
200   '  die man am hÑufigsten benutzt, fest
210   '  eingestellt werden.
220   '*******************************************
230   '
240   ta$="STEREO"
250   tb$="DOLBY C"
260   tc$="CHROM "
270   td$="MIT "
280   te$="MIT "
290   tf$="ZWEISEITIG"
300   '
310   '-------------------------------------------
320   '   MENUEPUNKT   HAUPTMENUE
330   '
340   groesse=10:gosub SCHRIFTGROESSE:' Normalgrîûe
350   schrifttyp=4:gosub SCHRIFTART:' verzerrte Schrift
360   '
370   '+++++++++++++++++++++++++++++++
380   'Zeichenroutine fÅr weiûe Felder
390   '
400   color 1,1,1,0,0
410   for draw=1 to 4
420   if draw = 1 then color 1,1,1,1,1 else color 1,1,1,0,0
430   read xpos1,ypos1,xpos2,ypos2:
440   gosub RECHTECK:'Rechteckroutine aufrufen
450   next draw
460   '
470   '+++++++++++++++++++++++++++++++
480   groesse=19:gosub SCHRIFTGROESSE:'Schriftgrîûe groû
490   xpos=50:ypos= 5:text$=" K A S S E T T E N - L A Y O U T"
500   gosub TEXTAUSGABE
510   schrifttyp=16:gosub SCHRIFTART
520   xpos= 40:ypos=30:groesse=16:gosub SCHRIFTGROESSE
530   text$="(c) 1986 AUF  ATARI ST BY RAINER DUDA "
540   gosub TEXTAUSGABE
550   groesse=10:gosub SCHRIFTGROESSE:schrifttyp=0:gosub SCHRIFTART
560   modus=1:gosub GRAFIKMODUS
570   '
580   '++++++++++++++++++++++++++++++
590   'Zeichenroutine fÅr dunkle Hintergrundfelder
600   '
610   color 1,1,1,4,2
620   for draw=1 to 4
630   read xpos1,ypos1,xpos2,ypos2:
640   gosub RECHTECK
650   next draw
660   '
670   '++++++++++++++++++++++++++++++
680   'Zeichenroutine fÅr Texthintergrund
690   '
700   color 1,1,1,1,2
710   for draw = 1 to 9
720   read xpos1,ypos1,xpos2,ypos2:
730   gosub RECHTECK
740   next draw
750   '
760   '+++++++++++++++++++++++++++++++
770   ' -- Textausgabe im Menue --
780   '
790   modus=2 :gosub GRAFIKMODUS
800   gotoxy 32,5:print"       "
810   gotoxy 32,7:print"  E "
820   gotoxy 32,8:print"  I     L"
830   gotoxy 32,9:print"  N     A"
840   gotoxy 32,10:print"  G     D"
850   gotoxy 32,11:print"  A     E"
860   gotoxy 32,12:print"  B     N"
870   gotoxy 32,13:print"  E "
880   gotoxy 3,5:print" MONO   "
890   gotoxy 3,6:print" STEREO "
900   gotoxy 3,8:print" INTERPRET"
910   gotoxy 3,9:print" ZéHLER  "
920   gotoxy 13,5:print" NORMAL"
930   gotoxy 13,6:print" DOLBY B"
940   gotoxy 13,7:print" DOLBY C"
950   gotoxy 13,8:print" HIGHCOM"
960   gotoxy 23,5:print" NORMAL"
970   gotoxy 23,6:print" CHROM "
980   gotoxy 23,7:print" METALL"
990   gotoxy 23,9:print" EINSEITIG"
1000  gotoxy 23,10:print" ZWEISEITIG"
1010  gotoxy 33,18:print" HILFE"
1020  gotoxy 3,12:print" B I T T E     W é H L E N     S I E"
1030  modus=1:gosub GRAFIKMODUS
1040  goto AUSGABE
1050  '
1060  '-------------------------------------------------------
1070  '
1080  ABFRAGE:
1090  gosub MAUS
1100  gosub SHOWMAUS
1110  if key<>1 then ABFRAGE
1120  if xmaus<50 or xmaus>58 then goto L3
1130  if ymaus >89 and ymaus<100 then ta$="MONO  "
1140  if ymaus >105 and ymaus<117 then ta$="STEREO"
1150  if ymaus >140 and ymaus<152 then goto L1
1160  if ymaus >157 and ymaus<168 then goto L2
1170  goto AUSGABE
1180  '
1190  L1:
1200  if left$(td$,1)="M"then td$="OHNE" else td$="MIT "
1210  goto AUSGABE
1220  '
1230  L2:
1240  if left$(te$,1)="M"then te$="OHNE" else te$="MIT "
1250  goto AUSGABE
1260  '
1270  '--------------------------------------------
1280  '
1290  L3:
1300  if xmaus<220 or xmaus>229 then goto L4
1310  if ymaus >89 and ymaus<100 then tb$="NORMAL "
1320  if ymaus >105 and ymaus<117 then tb$="DOLBY B"
1330  if ymaus >122 and ymaus<134 then tb$="DOLBY C"
1340  if ymaus >140 and ymaus<152 then tb$="HIGHCOM"
1350  goto AUSGABE
1360  '
1370  '--------------------------------------------
1380  '
1390  L4:
1400  if xmaus<388 or xmaus>398 then goto L5
1410  if ymaus >89 and ymaus<100 then tc$="NORMAL"
1420  if ymaus >105 and ymaus<117 then tc$="CHROM "
1430  if ymaus >122 and ymaus<134 then tc$="METALL"
1440  if ymaus >157 and ymaus<168 then tf$="EINSEITIG "
1450  if ymaus >173 and ymaus<185 then tf$="ZWEISEITIG"
1460  goto AUSGABE
1470  '
1480  '--------------------------------------------
1490  '
1500  L5:
1510  if xmaus <558 then goto AUSGABE
1520  if ymaus >89 and ymaus<100 and xmaus <600 then goto EINGABE
1530  if ymaus >300 then goto HILFE
1540  if xmaus >600 then goto LADEN
1550  '
1560  '--------------------------------------------
1570  '
1580  AUSGABE:
1590  gotoxy 1,15
1600  print"AUFNAHMEART: "ta$;"      SYSTEM: "tb$;"     BANDART: "tc$
1610  gotoxy 1,18:print"AUSGABE "td$;" INTERPRET UND "te$;" ZéHLER"
1620  gotoxy 21,18:print "AUSDRUCK: "tf$
1630  goto ABFRAGE
1640  '
1650  '--------------------------------------------
1660  '
1670  EINGABE:
1680  '
1690  ' Bestimmung der Abfrage-und Ausdruckart (td=0-3)
1700  '
1710  gosub MAUSAUS
1720  td=0:tz=7:tm=18:restore L7
1730  if left$(td$,1)="M"then td=1:tz=6:tm=9:restore L6
1740  if left$(te$,1)="M"then td=2:tz=7:tm=18:restore L7
1750  if left$(td$,1)="M" and left$(te$,1)="M" then td=3:tz=6:tm=9:restore L6
1760  if left$(tf$,1)="Z" then tm=tm*2
1770  clearw 2:gotoxy 0,0:out 2,27:out 2,69
1780  color 1,1,1,4,2
1790  xpos1=5:ypos1=45:xpos2=610:ypos2=280:gosub RECHTECK
1800  '
1810  '++++++++++++++++++++++++++++++++
1820  ' Eingabefelder bestimmen und auf Bildschirm auswerfen
1830  '
1840  color 1,1,1,0,0
1850  for draw = 1 to tz
1860  read xpos1,ypos1,xpos2,ypos2:
1870  gosub RECHTECK
1880  next draw
1890  '+++++++++++++++++++++++++++++++
1900  '
1910  if td=0 or td=2 then restore L8 else restore L9:' Verzweigung
1920  '
1930  for draw=1 to 4
1940  read xpos1,ypos1,xpos2,ypos2
1950  linef xpos1,ypos1,xpos2,ypos2
1960  next draw
1970  '++++++++++++++++++++++++++++++
1980  groesse=19:gosub SCHRIFTGROESSE
1990  schrifttyp=4:gosub SCHRIFTART
2000  xpos=200:ypos=23:text$="LIEDEINGABE:":gosub TEXTAUSGABE
2010  groesse=17:gosub SCHRIFTGROESSE
2020  xpos=30:ypos=70:text$="SEITE :":gosub TEXTAUSGABE
2030  xpos=330:ypos=70:text$="LIED NR.: ":gosub TEXTAUSGABE
2040  groesse=10:gosub SCHRIFTGROESSE
2050  schrifttyp=0:gosub SCHRIFTART
2060  modus=2:gosub GRAFIKMODUS
2070  '+++++++++++++++++++++++++++++++++++
2080  '
2090  ' Verzweigung fÅr Eingabe
2100  '
2110  if td=0 or td=2 then goto A1
2120  '
2130  '+++++++++++++++++++++++++++++++++++
2140  '
2150  gotoxy 2,5:print"Eingabe Titel:"
2160  gotoxy 16,5:print"Eingabe Interpret:"
2170  gotoxy 32,5:print" ZÑhler"
2180  '
2190  '------------------------------------
2200  ' Eingabe der Lieder im Modus 1 und 3
2210  '------------------------------------
2220  '
2230  for k=1 to 2: ' Seitenbestimmung
2240  '
2250  A5:
2260  yp=0
2270  modus=1:gosub GRAFIKMODUS
2280  xpos=150:ypos=70:text$=str$(k):gosub TEXTAUSGABE
2290  '
2300  t=0
2310  restore K4:color 1,1,1,0,0
2320  for draw=1 to 3:read xpos1,ypos1,xpos2,ypos2:gosub RECHTECK
2330  next draw
2340  while t<>tm
2350  t=t+1
2360  modus=1:gosub GRAFIKMODUS
2370  if t/10=int(t/10)then yp=0 else goto K5
2380  restore K4: color 1,1,1,0,0
2390  for draw=1 to 3:read xpos1,ypos1,xpos2,ypos2:gosub RECHTECK
2400  next draw
2410  '
2420  K5:
2430  yp=yp+1
2440  xpos=500:ypos=70:text$=str$(t):gosub TEXTAUSGABE
2450  '
2460  modus=2:gosub GRAFIKMODUS
2470  gotoxy 0,yp+6:input a$(k,t):' Eingabe Lied
2480  if len(a$(k,t))<1 then a$(k,t)="..."
2490  a$(k,t)=left$(a$(k,t),28)
2500  '
2510  if a$(k,t)="..."then goto A2
2520  modus=2:gosub GRAFIKMODUS
2530  gotoxy 14,yp+6:input pret$(k,t):' Eingabe Interpret
2540  pret$(k,t)=left$(pret$(k,t),33)
2550  if len(pret$(k,t))<1 then pret$(k,t)="..."
2560  '
2570  if td=1 then count$(k,t)="...":goto A2
2580  '
2590  modus=2:gosub GRAFIKMODUS
2600  gotoxy 32,yp+6:input count$(k,t):' Eingabe BandzÑhlwerk
2610  if len(count$(k,t))<1 then count$(k,t)="..."
2620  count$(k,t)=left$(count$(k,t),4)
2630  '
2640  A2:
2650  if a$(k,t)="..."then for s=t to 36:a$(k,t)="..."next s:t=tm
2660  wend
2670  gotoxy 1,17:input " Eingaben richtig (j/n)";ei$
2680  if ei$="n"or ei$="N"then goto A5
2690  t=0: next k
2700  goto AUSDRUCK
2710  '
2720  '------------------------------------------------------------------------
2730  '
2740  A1:
2750  gotoxy 2,5:print"Eingabe Titel:"
2760  gotoxy 19,5:print" Eingabe Titel:"
2770  '
2780  for k=1 to 2
2790  '
2800  A6:
2810  yp=0:xp=0
2820  modus=1:gosub GRAFIKMODUS
2830  xpos=150:ypos=70:text$=str$(k):gosub TEXTAUSGABE
2840  '
2850  t=0
2860  restore K3:color 1,1,1,0,0
2870  for draw=1 to 4: read xpos1,ypos1,xpos2,ypos2:gosub RECHTECK
2880  next draw
2890  while t<>tm
2900  t=t+1
2910  modus=1:gosub GRAFIKMODUS
2920  if t=10 or t=28 then yp=0:xp=18
2930  if t=19 then yp=0:xp=0 else goto J4
2940  restore K3:color 1,1,1,0,0
2950  for draw=1 to 4:read xpos1,ypos1,xpos2,ypos2:gosub RECHTECK
2960  next draw
2970  '
2980  J4:
2990  yp=yp+1
3000  xpos=500:ypos=70:text$=str$(t):gosub TEXTAUSGABE
3010  '
3020  modus=2:gosub GRAFIKMODUS
3030  gotoxy xp,yp+6:input a$(k,t)
3040  if len(a$(k,t))<1 then a$(k,t)="..."
3050  a$(k,t)=left$(a$(k,t),28)
3060  if a$(k,t)="..."then goto A3
3070  '
3080  if td=0 then count$(k,t)="...":goto A3
3090  '
3100  modus=2:gosub GRAFIKMODUS
3110  gotoxy 14+xp,yp+6:input count$(k,t)
3120  if len(count$(k,t))<1 then count$(k,t)="..."
3130  count$(k,t)=left$(count$(k,t),4)
3140  '
3150  A3:
3160  if a$(k,t)="..."then for s=t to 36:a$(k,s)="...":next s:t=tm
3170  wend
3180  gotoxy 1,17:input " Eingaben richtig (j/n)";ei$
3190  if ei$="n"or ei$="N"then goto A6
3200  t=0: next k
3210  '
3220  '---------------------------------------------------
3230  '
3240  AUSDRUCK:
3250  '
3260  clearw 2:gotoxy 0,0
3270  color 1,1,1,4,2
3280  xpos1=5:ypos1=100:xpos2=595:ypos2=210:gosub RECHTECK
3290  xpos1=5:ypos1=220:xpos2=595:ypos2=280:gosub RECHTECK
3300  color 1,1,1,0,0
3310  xpos1=5:ypos1=5:xpos2=595:ypos2=50:gosub RECHTECK
3320  xpos1=5:ypos1=55:xpos2=595:ypos2=95:gosub RECHTECK
3330  xpos1=10:ypos1=115:xpos2=400:ypos2=145:gosub RECHTECK
3340  xpos1=10:ypos1=165:xpos2=400:ypos2=195:gosub RECHTECK
3350  linef 190,115,190,145
3360  linef 190,165,190,195
3370  '++++++++++++++++++++++++++++++
3380  groesse=19:gosub SCHRIFTGROESSE
3390  xpos=80:ypos=35:text$=" ö B E R S C H R I F T E N ":gosub TEXTAUSGABE
3400  groesse=10:gosub SCHRIFTGROESSE
3410  gotoxy 2,4
3420  print"AUFNAHMEART: "ta$;"      SYSTEM: "tb$;"     BANDART: "tc$
3430  modus=2:gosub GRAFIKMODUS
3440  gotoxy 1,7:print" SEITE 1: ":gotoxy 12,7:print xa$
3450  gotoxy 1,10:print" SEITE 2: "
3460  gotoxy 10,7:input xa$
3470  if len(xa$)<1 then xa$="-"
3480  xa$=left$(xa$,25)
3490  modus=2:gosub GRAFIKMODUS
3500  gotoxy 10,10:input xb$
3510  if len(xb$)<1 then xb$="-"
3520  xb$=left$(xb$,25)
3530  color 1,1,1,0,0
3540  xpos1=10:ypos1=230:xpos2=180:ypos2=270:gosub RECHTECK
3550  xpos1=200:ypos1=230:xpos2=370:ypos2=270:gosub RECHTECK
3560  xpos1=420:ypos1=230:xpos2=590:ypos2=270:gosub RECHTECK
3570  gotoxy 1,14:print"   NEUSTART "
3580  gotoxy 13,14:print"   AUSDRUCK "
3590  gotoxy 26,14:print"   SICHERN "
3600  gosub MAUSAN
3610  A7:
3620  gosub MAUS
3630  gosub SHOWMAUS
3640  if key<>1 then goto A7
3650  if ymaus <243 and ymaus>254 then goto A7
3660  if xmaus >24 and xmaus<32 then goto START
3670  if xmaus >227 and xmaus<237 then goto A8
3680  if xmaus >420 then goto ABSICHERN
3690  goto A7
3700  '---------------------------------------------------
3710  A8:
3720  ' Druckroutine
3730  '
3740  '1/8" Zeilenabstand
3750  lprint:lprint chr$(27);"4";
3760  '
3770  'Alternativzeichensatz
3780  lprint chr$(15);
3790  '
3800  'gedehnte Schrift
3810  lprint chr$(14);
3820  '
3830  for i=1 to 33:lprint "_";:next i:lprint "_"
3840  lprint chr$(14);chr$(27);"-";chr$(1);
3850  lprint "Seite 1: " xa$
3860  lprint chr$(14);chr$(27);"-";chr$(0);
3870  lprint "Seite 2: " xb$
3880  lprint chr$(14);
3890  for i=1 to 33:lprint chr$(141);:next i:lprint chr$(141)
3900  '
3910  'Schmalschrift
3920  lprint chr$(27);"0";
3930  '
3940  for i= 1 to 68
3950  lprint"=";
3960  next i
3970  '
3980  lprint tab(5)"BANDART :"tc$;tab (25)"NOISE RED.:"tb$;tab (55) ta$
3990  '
4000  for i= 1 to 68
4010  lprint"-";
4020  next i
4030  '
4040  lprint tab (5)" S E I T E   1";tab(40)" S E I T E   2"
4050  '
4060  for i= 1 to 67
4070  lprint"=";
4080  next i:lprint"="
4090  '
4100  kks=0
4110  for t = 1 to tm
4120  kks=kks+1
4130  if a$(1,t)="..."then a$(1,t)=""
4140  if a$(2,t)="..."then a$(2,t)=""
4150  if count$(1,t)="..."then count$(1,t)=""
4160  if count$(2,t)="..."then count$(2,t)=""
4170  lprint a$(1,t);tab(30) count$(1,t);tab(36) a$(2,t);tab(65) count$(2,t)
4180  if td=0 or td=2 then goto A4
4190  if pret$(1,t)="..."then pret$(1,t)=""
4200  if pret$(2,t)="..."then pret$(2,t)=""
4210  lprint pret$(1,t);tab(36) pret$(2,t)
4220  kks=kks+1
4230  A4:
4240  if kks = 16 then for i=1 to 67:lprint chr$(133);:next i:lprint chr$(133)
4250  next t
4260  '
4270  for i= 1 to 68
4280  lprint"=";
4290  next i
4300  '
4310  end
4320  '----------------------------------------------------
4330  data  10,-30,630, 55, 20,-20,620, 45, 10,250,530,285
4340  data  10,300,530,330
4350  data  10, 75,530,193,540, 75,635,285, 10,195,530,235
4360  data 540,295,635,340
4370  data  20, 80,180,130,190, 80,350,160,590, 80,630,280
4380  data 360, 80,520,145, 20,200,520,230,545, 80,585,280
4390  data  20,135,180,175,360,155,520,190,545,300,630,335
4400  data -1
4410  '-----------------------------------------
4420  L6:
4430  data  5,  5,610, 30, 10, 50,305, 80,310, 50,605, 80
4440  data 20, 85,250,275,260, 85,530,275,545, 85,605,275
4450  data -1
4460  '-----------------------------------------
4470  L7:
4480  data   5,  5,610, 30, 10, 50,305, 80,310, 50,605, 80
4490  data  20, 85,250,275,260, 85,300,275,320, 85,555,275
4500  data 565, 85,605,275
4510  data -1
4520  '------------------------------------------
4530  L8:
4540  data  20,110,250,110,260,110,300,110,320,110,555,110
4550  data 565,110,605,110
4560  '------------------------------------------
4570  L9:
4580  data  20,110,250,110,260,110,530,110,545,110,605,110
4590  data 560,110,560,275
4600  '------------------------------------------
4610  K2:
4620  data   5,100,595,210,  5,220,595,280,  5,  5,595, 50
4630  data   5, 55,595, 95, 10,115,400,145, 10,165,400,195
4640  '------------------------------------------
4650  K3:
4660  data  20,110,250,275,260,110,300,275,320,110,555,275
4670  data 565,110,605,275
4680  '------------------------------------------
4690  K4:
4700  data  20,110,250,275,260,110,530,275,560,110,605,275
4710  '------------------------------------------
4720  MAUS:
4730  poke contrl,124
4740  vdisys
4750  xmaus=peek(ptsout)-1
4760  ymaus=peek(ptsout +2)-38
4770  key=peek(intout)
4780  return
4790  '-----------------------------------
4800  SHOWMAUS:
4810  poke contrl,122
4820  poke intin,0
4830  vdisys
4840  return
4850  '--------------------------
4860  RECHTECK:
4870  poke contrl ,11
4880  poke contrl+2,2
4890  poke contrl+6,0
4900  poke contrl+10,1
4910  poke ptsin,xpos1+1
4920  poke ptsin+2,ypos1+38
4930  poke ptsin+4,xpos2+1
4940  poke ptsin+6,ypos2+38
4950  vdisys
4960  return
4970  '---------
4980  SCHRIFTART:
4990  poke contrl ,106
5000  poke contrl+2,0
5010  poke contrl+6,1
5020  poke intin,schrifttyp
5030  vdisys
5040  return
5050  '-------------------
5060  SCHRIFTGROESSE:
5070  poke contrl ,107
5080  poke contrl+2,0
5090  poke contrl+6,1
5100  poke intin,groesse
5110  vdisys
5120  return
5130  '--------------------
5140  TEXTAUSGABE:
5150  for i=0 to len(text$)-1
5160  poke intin+i*2,asc(mid$(text$,i+1,1))
5170  next
5180  poke intin+i*2,0
5190  poke contrl,8
5200  poke contrl+2,1
5210  poke contrl+6,len(text$)+1
5220  poke ptsin,xpos+1
5230  poke ptsin+2,ypos+38
5240  vdisys
5250  return
5260  '-----
5270  GRAFIKMODUS:
5280  poke contrl ,32
5290  poke contrl+2,0
5300  poke contrl+6,1
5310  poke intin,modus
5320  vdisys
5330  return
5340  '--------
5350  MAUSAUS:
5360  poke contrl,123:poke contrl+2,0:poke contrl+6,0:vdisys
5370  return
5380  '--------
5390  MAUSAN:
5400  poke contrl,122:poke contrl+2,0:poke contrl+6,1:poke intin,0:vdisys
5410  return
5420  '--------
5430  '
5440  HILFE:
5450  '
5460  clearw 2:gosub MAUSAUS:' Maus ausschalten
5470  out 2,2:out 2,69
5480  '
5490  ' Bildschirmaufbau
5500  '
5510  color 1,1,1,4,2:xpos1=0:ypos1=-40:xpos2=640:ypos2=360:gosub RECHTECK
5520  color 1,1,1,1,2:xpos1=20:ypos1=-20:xpos2=600:ypos2=20:gosub RECHTECK
5530  color 1,1,1,0,0:xpos1=20:ypos1=30:xpos2=600:ypos2=340:gosub RECHTECK
5540  groesse=17:gosub SCHRIFTGROESSE:schrifttyp=4:gosub SCHRIFTART
5550  modus=2:gosub GRAFIKMODUS
5560  xpos=150:ypos=5:text$="P R O G R A M M     H I L F E":gosub TEXTAUSGABE
5570  groesse=10:gosub SCHRIFTGROESSE:schrifttyp=0:gosub SCHRIFTART
5580  gotoxy 2,2:print" 'KASSETTENLAYOUT'  (c) 1986  by  Rainer Duda "
5590  print tab(6)" ---------------------------------------------"
5600  print tab(6)" Dieses Programm dient zum Ausdrucken von Inhaltsverzeichnissen"
5610  print tab(6)" einer Musik-Kassette. Durch die Menuesteuerung ist es relativ leicht"
5620  print tab(6)" zu bedienen. Das entsprechende Feld () wird einfach mit der Maus "
5630  print tab(6)" angeklickt und der Befehl wird ausgefÅhrt."
5640  print tab(6)" Folgende Mîglichkeiten hat man im Programm :"
5650  print
5660  print tab(6)" 1. Auswahl im Hauptmenue :"
5670  print tab(6)"    a) Auswahl der Aufnahmeart ( Mono / Stereo )
5680  print tab(6)"    b) Auswahl der RauschunterdrÅckung ( Normal - Highcom )
5690  print tab(6)"    c) Auswahl der Bandart ( Normal - Metall )
5700  print tab(6)"    d) Auswahl des Ausdruckes ( Interpret / Counter / Seitenanzahl )"
5710  print tab(6)"    e) abgespeicherte Datei kann geladen werden"
5720  print tab(6)"    f) diese ErklÑrung kann aufgerufen werden"
5730  print tab(6)"    g) mit 'EINGABE' wird zur Titeleingabe verzweigt."
5740  print tab(6)"    Die Punkte a-d werden im weiûen Sichtfenster angezeigt."
5750  out 2,7:f=inp(2)
5760  modus=1:gosub GRAFIKMODUS
5770  color 1,1,1,0,0:xpos1=20:ypos1=30:xpos2=600:ypos2=340:gosub RECHTECK
5780  modus=2:gosub GRAFIKMODUS
5790  gotoxy 2,2
5800  print"  2. Im Lademenue kann eine Datei geladen, geÑndert und ausgedruckt"
5810  print tab(6)"    werden."
5820  print
5830  print tab(6)" 3. Bei der Liedeingabe kann die Eingabe vorzeitig durch RETURN"
5840  print tab(6)"    abgebrochen werden. "
5850  out 2,7:f=inp(2)
5860  modus=1:gosub GRAFIKMODUS:gosub MAUSAN:goto START
5870  '
5880  '-----------------------------------------
5890  LADEN:
5900  '
5910  clearw 2:gosub MAUSAUS
5920  out 2,2:out 2,69
5930  color 1,1,1,4,2:xpos1=0:ypos1=-40:xpos2=640:ypos2=360:gosub RECHTECK
5940  color 1,1,1,1,2:xpos1=20:ypos1=-20:xpos2=600:ypos2=20:gosub RECHTECK
5950  xpos1=20:ypos1=295:xpos2=600:ypos2=335:gosub RECHTECK
5960  color 1,1,1,0,0:xpos1=20:ypos1=30:xpos2=600:ypos2=290:gosub RECHTECK
5970  modus=2:gosub GRAFIKMODUS
5980  gotoxy 3,18:print"   NEUSTART         AUSDRUCK          éNDERN";
5990  print"         SICHERN "
6000  linef 20,55,600,55
6010  groesse=17:gosub SCHRIFTGROESSE:schrifttyp=4:gosub SCHRIFTART
6020  xpos=150:ypos=5:text$="  D A T E N   L A D E N  ":gosub TEXTAUSGABE
6030  groesse=10:gosub SCHRIFTGROESSE:schrifttyp=0:gosub SCHRIFTART
6040  gotoxy 2,2:input"Name der Datei ";name$
6050  if len(name$)<1 then 6040
6060  modus=1:gosub GRAFIKMODUS
6070  name$=name$+".DAT"
6080  '----------------------
6090  ' Laden einer Datei
6100  open "I",#1,name$
6110  input#1,tm
6120  input#1,td
6130  input#1,td$
6140  input#1,te$
6150  input#1,tf$
6160  input#1,xa$
6170  input#1,xb$
6180  for k=1 to 2
6190  for t=1 to 36
6200  input#1,a$(k,t)
6210  input#1,pret$(k,t)
6220  input#1,count$(k,t)
6230  next t:next k
6240  '-------------------
6250  ' Ausgabe auf Bildschirm
6260  for k=1 to 2
6270  groesse=8:gosub SCHRIFTGROESSE:xpos=30:ypos=70
6280  text$="ANZAHL:"+str$(tm)+"  "+td$+" INTERPRET & "+te$+" ZAEHLER  "
6290  text$=text$+"AUSDRUCK:"+tf$+"   KASS.-SEITE:"+str$(k)
6300  gosub TEXTAUSGABE
6310  ypos=ypos+10
6320  for t=1 to tm
6330  if a$(k,t)="..."then goto J5
6340  if t=19 then ypos=80
6350  xpos=30:text$=str$(t):gosub TEXTAUSGABE
6360  xpos=60:text$=a$(k,t):gosub TEXTAUSGABE
6370  xpos=300:text$=pret$(k,t):gosub TEXTAUSGABE
6380  xpos=550:text$=count$(k,t):gosub TEXTAUSGABE
6390  ypos=ypos+7
6400  '
6410  J5:
6420  next t:out 2,7:f=inp(2)
6430  color 1,1,1,0,0:xpos1=20:ypos1=55:xpos2=600:ypos2=290:gosub RECHTECK
6440  next k:groesse=10:gosub SCHRIFTGROESSE:gosub MAUSAN:goto J1
6450  '--------------------------------------
6460  J1:
6470  gosub MAUS
6480  gosub SHOWMAUS
6490  if key<>1 then goto J1
6500  if ymaus<310 or ymaus>320 then goto J1
6510  if xmaus >58 and xmaus<66 then goto START
6520  if xmaus >209 and xmaus<219 then goto A8
6530  if xmaus >362 and xmaus<371 then goto AENDERN
6540  if xmaus >489 and xmaus<499 then goto J3
6550  goto J1
6560  '---------------------------------------
6570  AENDERN:
6580  '
6590  gosub MAUSAUS
6600  modus=1:gosub GRAFIKMODUS
6610  gotoxy 2,2:input"Welche Seite Ñndern ";k
6620  if k<1 or k>2 then goto AENDERN
6630  groesse=8:gosub SCHRIFTGROESSE
6640  ypos=80
6650  ' Ausgabe der zu Ñndernden Seite
6660  for t=1 to tm
6670  if a$(k,t)="..."then goto J6
6680  if t=19 then ypos=80
6690  xpos=30:text$=str$(t):gosub TEXTAUSGABE
6700  xpos=60:text$=a$(k,t):gosub TEXTAUSGABE
6710  xpos=300:text$=pret$(k,t):gosub TEXTAUSGABE
6720  xpos=550:text$=count$(k,t):gosub TEXTAUSGABE
6730  ypos=ypos+7
6740  '
6750  J6:
6760  next t:
6770  groesse=10:gosub SCHRIFTGROESSE
6780  '
6790  J2:
6800  '
6810  gotoxy 2,2:print"Kassettenseite :"k;:input"   Welche Liednummer ";t
6820  if t<1 or t>tm then goto J2
6830  color 1,1,1,0,0:xpos1=20:ypos1=55:xpos2=600:ypos2=290:gosub RECHTECK
6840  modus=2:gosub GRAFIKMODUS
6850  gotoxy 2,4:print"Alte Eintragung: "
6860  print tab(4) " Lied     : "a$(k,t)
6870  if left$(td$,1)<>"M"then goto J7
6880  print tab(4) " Interpret: "pret$(k,t)
6890  '
6900  J7:
6910  if left$(te$,1)<>"M"then goto J8
6920  print tab(4) " Counter  : "count$(k,t)
6930  modus=2:gosub GRAFIKMODUS
6940  '
6950  J8:
6960  gotoxy 2,10:print"Neue Eintragung: "
6970  print tab(4);:input" Lied      : ";a$(k,t)
6980  if len(a$(k,t))<1 then goto J8
6990  a$(k,t)=left$(a$(k,t),28)
7000  modus=2:gosub GRAFIKMODUS
7010  if left$(td$,1)<>"M"then goto J9
7020  print tab(4);:input" Interpret : ";pret$(k,t)
7030  if len(pret$(k,t))<1 then pret$(k,t)="-"
7040  pret$(k,t)=left$(pret$(k,t),33)
7050  modus=2:gosub GRAFIKMODUS
7060  '
7070  J9:
7080  if left$(te$,1)<>"M"then goto K1
7090  print tab(4);:input" Counter   : ";count$(k,t)
7100  if len(count$(k,t))<1 then count$(k,t)="...."
7110  count$(k,t)=left$(count$(k,t),4)
7120  '
7130  K1:
7140  modus=2:gosub GRAFIKMODUS:print:print tab(4) " Weitere énderungen ";:input f$
7150  modus=1:gosub GRAFIKMODUS
7160  color 1,1,1,0,0:xpos1=20:ypos1=55:xpos2=600:ypos2=290:gosub RECHTECK
7170  gotoxy 2,2:print"                                              "
7180  if f$="j" or f$="J" then goto AENDERN else goto J1
7190  '---------------------------------------
7200  ABSICHERN:
7210  '
7220  gosub MAUSAUS
7230  gotoxy 2,17:input "Abspeichern unter welchem Namen ";name$
7240  if len(name$)<1 then goto ABSICHERN
7250  name$=name$+".DAT"
7260  '----------------
7270  J3:
7280  open "O",#1,name$
7290  print#1,tm
7300  print#1,td
7310  print#1,td$
7320  print#1,te$
7330  print#1,tf$
7340  print#1,xa$
7350  print#1,xb$
7360  for k=1 to 2
7370  for t=1 to 36
7380  print#1,a$(k,t)
7390  print#1,pret$(k,t)
7400  print#1,count$(k,t)
7410  next t:next k
7420  close #1
7430  gosub MAUSAN:end
7440  '----------------
