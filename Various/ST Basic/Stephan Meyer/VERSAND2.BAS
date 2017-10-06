10    '
20    '
30    '  ********************************************
40    '  *                                          *
50    '  *               Versanddruck               *
60    '  *        (c) 7/1984   by G.Stahl           *
70    '  *             fuer Atari ST                *
80    '  *               ergaenzt                   *
90    '  *  von Guenter Stahl & Angelika Schulte    *
100   ' *                03/1986                   *
110   ' *                                          *
120   ' ********************************************
130   '
135   dim a$(40),b$(40),c$(40),t$(40),bl$(10),ba$(40),ko$(40)
140   closew 0:closew 1:closew 3:fullw 2:clear:clearw 2
150   gosub init : gosub fullwind : gosub cleardesk
160   gosub textausgabe :clearw 2
162   for i=1 to 555:next i
164   gotoxy 9,10:print"****  ACHTUNG > DATENDISKETTE < einlegen  *****"
165   gotoxy 13,12:print"Bitte RETURN drÅcken"
168   a=inp(2):clearw 2
170   gotoxy 13,2:print"Versanddruck"
180   goto laden
220   ausgang:clearw 2
230   gotoxy 0,0:print"Geben Sie jetzt ein :"
240   gotoxy 2,2:line input"EmpfÑnger       :";d$
250   gotoxy 2,3:line input"Strasse         :";e$
260   gotoxy 2,4:line input"Plz Ort         :";f$
270   gotoxy 2,6:line input"Kontonr.        :";g$
280   gotoxy 2,8:line input"Bankleitzahl    :";bl1$
290   gotoxy 2,10:line input"Psch. Amt       :";h$
300   gotoxy 2,12:line input"Verwendung      :";i$
310   gotoxy 2,14:line input"Vermerk         :";j$
320   gotoxy 2,16:line input"Betrag          :";z$
330   gotoxy 2,18:line input"Summe(Buchstab.):";k$
340   gotoxy 8,19:print"(1) Zahlkarte oder  (2) Zahlscheinvordruck"
350   key1=inp(2):if key1< 49 or key2> 50 then 340 else goto 360
360   gotoxy 8,19:print"                                             "
370   gotoxy 13,19:print"Richtig j/n ?";
380   key=inp(2)
390   if key=74 or key=106 then 400 else goto ausgang
400   l=len(z$):if key1=49 then 410 else goto zahlscheina
410   '
420   lprint tab(39-l);z$;tab(42);g$;tab(68);j$
430   lprint tab(19);a$
440   lprint tab(19);b$
450   lprint
460   lprint tab(19);c$
470   lprint:lprint
480   lprint tab(14-l);z$;tab(32-l);z$;tab(73-l);z$
490   lprint :lprint g$;tab(20);k$;tab(62);d$
500   lprint
510   lprint a$;tab(20);d$;tab(62);e$
520   lprint b$;tab(20);e$;tab(45);g$
530   lprint tab(62);f$
540   lprint :lprint c$;tab(20);f$;tab(45);h$;tab(62);g$
550   lprint
560   lprint i$
570   lprint
580   gosub abfrage
590   goto menue
600   ende:clearw 2:end
610   menue:clearw 2
620   gosub druckint
630   gotoxy 9,4:print"-----------  Versanddruck  -----------"
640   gotoxy 13,6:print"1.) Ausgangszahlung"
650   gotoxy 13,8:print"2.) Eingangszahlung"
660   gotoxy 13,10:print"3.) Nachnahme-Post"
670   gotoxy 13,12:print"4.) Aufkleberdruck"
680   gotoxy 13,14:print"5.) Kurzbriefdruck"
690   gotoxy 13,16:print"6.) Programmende"
700   '
710   key=inp(2)
720   if key< 49 or key>54 then 710
730   on key-48 goto ausgang,eingang,nachnahme,aufkleber,kurzbrief,ende
740   eingang:clearw 2
750   gosub 950
760   l1=len(z1$)
770   if key2=49 then 780 else goto zahlscheine
780   lprint tab(39-l);z1$;tab(42);ko$;tab(68);j1$
790   lprint tab(19);d1$
800   lprint tab(19);e1$:lprint
810   lprint tab(19);f1$
820   lprint:lprint
840   lprint tab(14-l);z1$;tab(32-l);z1$;tab(73-l);z1$
850   lprint
860   lprint ko$;tab(20);k1$;tab(62);a$
870   lprint:lprint d1$;tab(20);a$;tab(62);b$
880   lprint e1$;tab(20);b$;tab(45);ko$
885   lprint tab(62);c$
886   lprint
890   lprint f1$;tab(20);c$;tab(45);ba$;tab(62);ko$
900   lprint
910   lprint i1$
920   lprint
930   gosub abfrage
940   goto menue
950   gotoxy 1,0:print"Bitte geben Sie ein :"
960   gotoxy 1,2:line input"Absender            :";d1$
970   gotoxy 1,4:line input"Strasse             :";e1$
980   gotoxy 1,6:line input"Plz Ort             :";f1$
990   gotoxy 1,8:line input"Verwendung          :";i1$
1000  gotoxy 1,10:line input"Vermerk             :";j1$
1010  gotoxy 1,12:line input"Betrag              :";z1$
1020  gotoxy 1,14:line input"Summe(Buchstaben)   :";k1$
1030  gotoxy 8,17:print"(1) Zahlkarte oder  (2) Zahlscheinvordruck"
1040  key2=inp(2):if key2< 49 or key2> 50 then 1030 else goto 1050
1050  gotoxy 10,19:print"Richtig (j/n) ?"
1060  key=inp(2):if key=74 or key=106 then 1070 else goto eingang
1070  '
1080  return
1090  kurzbrief:
1100  clearw 2:gotoxy 1,0:print"Kurzbriefdruck"
1110  gotoxy 1,1:print "Bitte geben Sie ein :"
1120  gotoxy 1,2:line input"Betrifft      :";be$
1130  gotoxy 1,4:line input"Nachricht vom :";y$
1140  gotoxy 1,6:line input"EmpfÑnger     :";x$
1150  gotoxy 1,8:line input"Strasse       :";x1$
1160  gotoxy 1,10:line input"Plz Ort       :";x2$
1170  gotoxy 1,12:line input"Datum         :";dat$
1180  gotoxy 0,13:print"          ............................"
1190  gotoxy 0,14:line input"Text 1   :";r1$
1200  gotoxy 0,15:line input"Text 2   :";r2$
1210  gotoxy 0,16:line input"Text 3   :";r3$
1220  gotoxy 0,17:line input"Text 4   :";r4$
1230  gotoxy 0,18:line input"Text 5   :";r5$
1240  gotoxy 10,19:print"Richtig j/n ?";
1250  key=inp(2):if key=74 or key=106 then 1260 else goto kurzbrief
1260  '
1270  lprint tab(18);a$;tab(50);be$
1300  lprint
1310  lprint tab(11);b$;tab(55);y$
1320  lprint tab(11);c$
1330  lprint
1340  lprint tab(13);t$
1350  lprint
1360  lprint
1370  lprint
1380  lprint tab(13);"Herrn/Frau/Firma"
1390  lprint
1400  lprint tab(13);x$;tab(45);r1$
1410  lprint
1420  lprint tab(13);x1$;tab(45);r2$
1430  lprint tab(45);r3$
1440  lprint tab(13);x2$
1450  lprint tab(45);r4$
1460  lprint tab(45);r5$
1470  lprint:lprint tab(30);dat$
1480  lprint
1490  lprint
1500  gosub abfrage:goto menue
1510  nachnahme:clearw 2
1520  gotoxy 1,0:print"Bitte geben Sie ein :"
1530  gotoxy 1,2:line input"Absender            :";d2$
1540  gotoxy 1,4:line input"Strasse             :";e2$
1550  gotoxy 1,6:line input"Plz Ort             :";f2$
1560  gotoxy 1,8:line input"Kontonr.            :";g2$
1570  gotoxy 1,10:line input"Bank                :";h$
1580  gotoxy 1,12:line input"Rechn.Nr.           :";i2$
1600  gotoxy 1,14:line input"Nachn. Betrag       :";z2$:z2=val(z2$)
1610  z3=z2+1.5:z3$=str$(z3)
1620  gotoxy 1,16:line input"Summe(Buchstaben)   :";k2$
1630  gotoxy 10,19:print"Richtig j/n ?"
1640  key=inp(2)
1650  if key=74 or key=106 then 1660 else goto nachnahme
1660  l2=len(z2$)
1670  lprint tab(38-l2);z2$;tab(42);g2$
1680  lprint:lprint
1690  lprint tab(18);d2$
1700  lprint tab(18);e2$
1710  lprint tab(18);f2$
1720  lprint:lprint
1730  lprint
1740  lprint tab(14-l2);z2$;tab(31-l2);z2$
1750  lprint g2$;tab(18);k2$:lprint
1760  lprint
1770  lprint d2$;tab(18);a$;tab(42);g2$
1780  lprint e2$;tab(18);b2$
1790  lprint
1800  lprint f2$;tab(18);c$;tab(42);h2$
1810  lprint:lprint
1820  lprint i2$
1830  '
1840  lprint
1850  lprint
1860  lprint
1870  lprint:lprint
1880  lprint
1890  lprint tab(20);a$
1900  '
1910  lprint tab(20);b$
1920  '
1930  lprint tab(20);c$
1940  lprint:lprint:lprint
1950  lprint
1960  lprint
1970  lprint
1980  lprint tab(32-l2);z3$
1990  lprint
2000  lprint
2010  lprint d2$;tab(30);d2$
2020  lprint
2030  lprint e2$;tab(30);e2$
2040  '
2050  lprint f2$
2060  '
2070  lprint tab(28);f2$
2080  lprint
2090  '
2100  gosub abfrage:goto menue
2110  aufkleber:clearw 2
2120  gotoxy 10,2:print"Postaufkleberdruck"
2130  gotoxy 1,4:line input"Begrenzung Drucken j/n ? :";j9$
2140  if j9$="j" or j9$="J" then 2150 else goto 2160
2150  lprint"----------------------------------------------------------"
2160  '
2190  gotoxy 1,6:line input"Versandart (max 12 Zeichen) : ";z9$
2200  l=len(z9$)/2
2210  clearw 2
2220  if z9$="Nachnahme" then 2230 else goto 2240
2230  gosub 2565
2240  gotoxy 1,8:line input"EmpfÑnger Name      :";z4$
2250  gotoxy 1,10:line input"Strasse             :";z5$
2260  gotoxy 1,12:line input"Postleitzahl        :";z6$:z6=len(z6$)
2270  gotoxy 1,14:line input"Ort                 :";z7$
2280  gotoxy 13,19:print "Richtig (j/n) ?";
2290  z8=inp(2):if z8=74 or z8=106 then 2310 else goto 2300
2300  clearw 2:goto 2190
2310  z11$="Herr/Frau/Firma"
2320  lprint
2330  lprint tab(4);a$
2340  '
2350  lprint tab(4);b$
2360  lprint
2370  lprint tab(4);c$
2380  lprint:lprint
2390  lprint chr$(14);:lprint tab(24-l);z9$:lprint chr$(20);:lprint
2400  lprint
2410  if z9$="Nachnahme" then 2420 else goto 2450
2420  lprint tab(4);Betrag DM ";q2$
2430  lprint tab(4);q3$;"  ";q1$
2440  goto 2460
2450  lprint:lprint
2460  lprint tab(35);z11$:lprint:lprint tab(35);z4$
2470  lprint
2480  lprint tab(35);z5$
2490  lprint
2500  lprint
2510  lprint chr$(14);
2520  lprint tab(4);z6;"";tab(19);z7$
2530  lprint chr$(20);:lprint:lprint
2540  if j9$="j" or j9$="J" then 2550 else goto 2560
2550  lprint"----------------------------------------------------------"
2560  goto 2600
2565  gotoxy 1,2:line input"Bank                :";q3$
2570  gotoxy 1,4:line input"Kontonr.            :";q1$
2580  gotoxy 1,6:line input"Endsumme            :";q2$
2590  return
2600  gosub abfrage:goto menue
2610  'namensabfrage
2620  gotoxy 2,4:print"Geben Sie die eigenen Daten ein"
2630  gotoxy 5,6:line input"Name           :";a$
2640  gotoxy 5,8:line input"Strasse        :";b$
2650  gotoxy 5,10:line input"Plz Ort        :";c$
2655  gotoxy 5,12:line input"Telefonnr.     :";t$
2656  gotoxy 5,14:line input"Bankleitz.     :";bl$
2657  gotoxy 5,16:line input"Bank           :";ba$
2658  gotoxy 5,18:line input"Kontonr.       :";ko$
2660  goto speicher
2670  abfrage:return
2680  druckint:
2690  'initialisierungsprogramm fuer brother m1009
2700  '
2710  'aufzurufen mit gosub druckint
2720  '
2730  lprint "@": rem drucker zuruecksetzen
2740  lprint chr$(27);"R";chr$(2);: rem deutscher Zeichensatz einrichten
2750  lprint chr$(27);chr$(56); :   rem Papiermangel uebergehen
2760  'lprint chr$(27);chr$(52); :   rem Kursivdruck einstellen
2770  'lprint chr$(27);chr$(53); :   rem Kursivdruck loeschen
2780  'lprint chr$(27);chr$(77); :   rem Elite Zeichengroeûe einstellen
2790  'lprint chr$(27);chr$(80); :   rem Elite Zeichengroeûe loeschen
2800  lprint chr$(27);chr$(69); :   rem Zeichenhervorhebung einstellen
2810  'lprint chr$(27);chr$(70); :   rem Zeichenhervorhebung loeschen
2820  'lprint chr$(20); :            rem Zeichenvergroeûerung loeschen
2830  'lprint chr$(14); :            rem Zeichenvergroeûerung einstellen
2840  'lprint chr$(15); :            rem Zeichenverdichtung einstellen
2850  'lprint chr$(18); :            rem Zeichenverdichtung loeschen
2860  return
2870  a=inp(2):stop
2880  fullwind:
2890  poke gintin,3
2900  poke gintin+2,5
2910  poke gintin+4,-1
2920  poke gintin+6,0
2930  poke gintin+8,660
2940  poke gintin+10,419
2950  gemsys 105
2960  return
2970  cleardesk:
2980  color 1,0,1 :
2990  xpos1=-1: xpos2=638:ypos1=-40:ypos2=-20
3000  gosub rechteck:color 1,1,1
3010  return
3020  init:
3030  aes#=gb
3040  control = peek(aes#)
3050  global  = peek(aes#+4)
3060  gintin  = peek(aes#+8)
3070  gintout = peek(aes#+12)
3080  addrin  = peek(aes#+16)
3090  addrout = peek(aes#+20)
3100  return
3110  rechteck:
3120  poke contrl   ,11
3130  poke contrl+2 ,2
3140  poke contrl+6 ,0
3150  poke contrl+10,1
3160  poke ptsin  ,xpos1 +1
3170  poke ptsin+2,ypos1 +38
3180  poke ptsin+4,xpos2 +1
3190  poke ptsin+6,ypos2 +38
3200  vdisys
3210  return
3220  textausgabe:width 80:clearw 2
3230  text$="Versanddruck   (c) 7/84 by GÅnter Stahl"
3240  xpos3=140: ypos3=-25
3250  for i=0 to len(text$)-1
3260  poke intin+i*2,asc(mid$(text$,i+1,1))
3270  next
3280  poke intin+i*2,0
3290  poke contrl,8
3300  poke contrl+2,1
3310  poke contrl+6,len(text$)+1
3320  poke ptsin  ,  xpos3+1
3330  poke ptsin+2,ypos3+38
3340  vdisys
3350  return
3360  zahlscheina:
3370  lprint:lprint:lprint
3380  lprint:lprint:lprint
3390  lprint tab(10);d$;" ";e$;" ";f$;tab(55);bl1$
3400  lprint
3410  lprint tab(10);g$;tab(25);h$
3420  lprint
3430  lprint
3440  lprint
3450  lprint
3460  lprint tab(10);i$;tab(55);z$
3470  lprint
3480  lprint tab(10);a$;" ";b$;" ";c$
3490  for i=1 to 9:lprint:next i
3500  gosub abfrage:goto menue
3510  zahlscheine:
3520  lprint:lprint:lprint
3530  lprint:lprint:lprint
3540  lprint tab(10);a$;" ";b$;" ";c$;tab(55);bl$
3550  lprint
3560  lprint tab(10);ko$;tab(25);ba$
3570  lprint
3580  lprint
3590  lprint
3600  lprint
3610  lprint tab(10);i1$;tab(55);z1$
3620  lprint
3630  lprint tab(10);d1$;" ";e1$;" ";f1$
3640  for i=1 to 9:lprint:next i
3650  gosub abfrage:goto menue
3660  end
4000  speicher:
4010  '
4020  open "O",#1,"versand.dat"
4030  print #1,a$
4035  print #1,b$
4040  print #1,c$
4045  print #1,t$
4050  print #1,bl$
4055  print #1,ba$
4060  print #1,ko$
4065  close #1
4070  goto menue
4080  laden:
4090  on error goto 5010
4100  open "I",#1,"versand.dat"
4110  on error goto 5010
4120  if eof(1) then goto 5000
4130  input #1,a$
4135  input #1,b$
4140  input #1,c$
4145  input #1,t$
4150  input #1,bl$
4155  input #1,ba$
4160  input #1,ko$
4170  goto 4120
5000  close #1:goto menue
5010  close #1:goto 2610
