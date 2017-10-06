1000  MENUE:
1010  fullw 2: clearw 2:gosub RECHTECK: F$="#######,.##":
1020  gotoxy 11,1 : print"KAUF, VERKAUF UND RENTABILITAET"
1030  gotoxy 14,2 : print"VON WERTPAPIEREN"
1040  gotoxy 15,5 : print"* M E N U E *"
1050  gotoxy 12,7 : print"<K>  Kaufabrechnung"
1060  gotoxy 12,8 : print"<V>  Verkaufabrechnung"
1070  gotoxy 12,9 : print"<Z>  Effektive Verzinsung"
1080  gotoxy 12,10: print"<M>  Mindestverkaufskurs"
1090  gotoxy 12,11: print"<E>  Ende"
1100  gotoxy 13,15: input"Gewuenschte Funktion: ";ANT$
1110  if ANT$="K" or ANT$="k" then gosub KAUFABRECHNUNG
1120  if ANT$="V" or ANT$="v" then gosub VERKAUFABRECHNUNG
1130  if ANT$="Z" or ANT$="z" then gosub EFFEKTIVVERZINSUNG
1140  if ANT$="M" or ANT$="m" then gosub MINDESTVERKAUFSKURS
1150  if ANT$="E" or ANT$="e" then gosub ENDE
1160  goto MENUE
1170  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1180  KAUFABRECHNUNG:
1190  clearw 2: ZEICHEN$="+ "
1200  gotoxy  1,1 : print"KAUFABRECHNUNG"
1210  gosub EINGABEMASKE: gosub KAUFDATUM: gosub EINGABE
1220  gotoxy  8,1 : print" vom ";(KT);"-";(KM);"-";(KJ)
1230  EK=KURSWERT+SPESEN: SUMME=EK
1240  gosub ABRECHNUNG
1250  return
1260  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1270  VERKAUFABRECHNUNG:
1280  clearw 2: ZEICHEN$="- "
1290  gotoxy  1,1 : print"VERKAUFABRECHNUNG"
1300  gosub EINGABEMASKE: gosub VERKAUFSDATUM: gosub EINGABE
1310  gotoxy 10,1 : print" vom ";(VT);"-";(VM);"-";(VJ)
1320  VK=KURSWERT-SPESEN: SUMME=VK
1330  gosub ABRECHNUNG
1340  return
1350  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1360  EFFEKTIVVERZINSUNG:
1370  gosub KAUFABRECHNUNG
1380  clearw 2: GD=0: D=0: ZEICHEN$="- ": gosub EINGABEMASKE
1390  gotoxy  1,1 : print"VERKAUFABRECHNUNG"
1400  if V=0 then gosub VERKAUFSDATUM: goto 1420
1410  gotoxy  1,5 : print"Datum (TT,MM,JJ) :";VT;"-";VM;"-";VJ: V=0
1420  TAGE=(VJ-KJ)*360+(VM-KM)*30+VT-KT: if TAGE<=0 then goto FEHLER1
1430  gotoxy  4,6 : print NAME$: gotoxy 18,6: print ANZAHL
1440  gosub A1
1450  gotoxy 10,1 : print" vom ";(VT);"-";(VM);"-";(VJ)
1460  VK=KURSWERT-SPESEN: SUMME=VK
1470  gosub ABRECHNUNG: gosub SEITENKOPF
1480  for I = KJ to VJ step 1
1490  gotoxy 16,Z : print I;" : ";: input"",D
1500  GD=GD+D: Z=Z+1: if Z=15 then SEITENKOPF
1510  next I: Z=0
1520  GESAMT=VK-EK+GD*ANZAHL: ZINSSATZ=GESAMT*100*360/EK/TAGE
1530  clearw 2: gosub RECHTECK
1540  gotoxy 11,1 : print"* EFFEKTIVVERZINSUNG VON AKTIEN *"
1550  gotoxy 11,2 : X$=string$(33,"="): print X$
1560  gotoxy 12,4 : print"Verkaufspreis :   ";: print using F$;VK
1570  gotoxy 12,5 : print"Kaufpreis     :   ";: print using F$;EK
1580  gotoxy 12,6 : X$=string$(29,"-"): print X$
1590  gotoxy 12,7 : print"Kursgewinn    :   ";: print using F$;VK-EK
1600  gotoxy  6,10: print "Dividende fuer";ANZAHL;NAME$;"-Aktien :   ";
1610  print using F$;GD*ANZAHL
1620  gotoxy 10,14: print"Insgesamt             :   ";
1630  print using F$;GESAMT
1640  gotoxy 10,15: print"Effektiver Jahreszins :   ";
1650  print using F$;ZINSSATZ: gotoxy 17,18: input"<return>",ANT$
1660  return
1670  SEITENKOPF:
1680  clearw 2: gosub RECHTECK: Z=5
1690  gotoxy 12,2 : print"Bitte geben Sie die Dividende"
1700  gotoxy 12,3 : print"je Aktie fuer jedes Jahr ein!"
1710  return
1720  FEHLER1:
1730  clearw 2: gosub RECHTECK
1740  gotoxy 14,2 : print"! Achtung Fehler !"
1750  gotoxy  9,3 : print"Verkaufsdatum liegt vor dem Kaufdatum"
1760  gotoxy 19,5 : print"Kaufdatum    : ";KT;"-";KM;"-";KJ
1770  gotoxy 19,6 : print"Verkaufsdatum: ";VT;"-";VM;"-";VJ
1780  gotoxy  8,8 : print"<K> Eingabe Kaufdatum wiederholen"
1790  gotoxy  8,9 : print"<V> Eingabe Verkaufsdatum wiederholen"
1800  gotoxy 13,15: input"Gewuenschte Funktion:  ",ANT$
1810  if ANT$="K" or ANT$="k" then gosub KAUFDATUM: V=1: goto 1380
1820  if ANT$="V" or ANT$="v" then V=1: gosub VERKAUFSDATUM: goto 1380
1830  goto FEHLER1
1840  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1850  MINDESTVERKAUFSKURS:
1860  gosub KAUFABRECHNUNG
1870  KURS=(EK/((98.75-MC)/100))/ANZAHL
1880  KURS=KURS*100: KURS=int(KURS): KURS=KURS/100
1890  ANNAEHERUNGSVERFAHREN:
1900  gosub RECHNUNG: VK=KURSWERT-SPESEN:
1910  if VK >= EK then goto AUSDRUCK
1920  KURS=KURS + 0.01
1930  goto ANNAEHERUNGSVERFAHREN
1940  AUSDRUCK:
1950  clearw 2: gosub RECHTECK
1960  gotoxy 13,1 : print"* MINDESTVERKAUFSKURS *"
1970  gotoxy 10,4 : print ANZAHL;"STUECK ";NAME$;"-Aktien"
1980  gotoxy 11,6 : print"Einkaufspreis      :  ";:print using F$;EK
1990  gotoxy 11,9 : print"Verkaufspreis      :  ";:print using F$;VK
2000  gotoxy 11,10: print"bei einem Kurs von :  ";:print using F$;KURS
2010  gotoxy 11,11: print"Gewinn             :  ";:print using F$;VK-EK
2020  gotoxy  9,14: print"Bei Wiederveraeusserung der Aktien innerhalb"
2030  gotoxy 14,15: print"eines halben Jahres"
2040  gotoxy  8,16: print"ist zusaetzlich Spekulationssteuer zu bezahlen!"
2050  gotoxy 17,18:input"<return>",ANT$: return
2060  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2070  ENDE:
2080  clearw 2: gosub RECHTECK
2090  gotoxy  6,10
2100  input"Wollen Sie das Programm wirklich verlassen? (J/N)",ANT$
2110  if ANT$="J" or ANT$="j" then end
2120  return
2130  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2140  KAUFDATUM:
2150  gotoxy  1,5 : input"Datum (TT,MM,JJ) :",KT,KM,KJ
2160  if KT<1 or KT>31 or KM<1 or KM>12 then gosub FEHLER2: goto KAUFDATUM
2170  if KT=31 then KT=30
2180  return
2190  VERKAUFSDATUM:
2200  gotoxy 1,5+V: input"Datum (TT,MM,JJ) :",VT,VM,VJ
2210  if VT<1 or VT>31 or VM<1 or VM>12 then gosub FEHLER2: goto VERKAUFSDATUM
2220  if VT=31 then VT=30
2230  return
2240  FEHLER2:
2250  gotoxy  1,4 : input "etwas ist falsch! <return>";ANT$
2260  gotoxy  1,4 : print space$(27)
2270  gotoxy 9,5+V: print space$(13): return
2280  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2290  EINGABEMASKE:
2300  gosub RECHTECK
2310  gotoxy 13,2 : print "E I N G A B E M A S K E"
2320  gotoxy  1,6
2330  print "Name :                       Anzahl:          Stueckkurs:"
2340  gotoxy  1,8 : print ZEICHEN$+"Spesen"
2350  gotoxy  1,9 : print"Courtage (Maklergebuehr) in % :"
2360  gotoxy  1,10: print"Mindestgebuehr in DM . . . . .:"
2370  gotoxy  1,11: print"Provision in % . . . . . . . .: 1.00"
2380  gotoxy  1,12: print"Mindestprovision in DM . . . .: 5.00"
2390  gotoxy  1,13: print"Boersenumsatzsteuer in % . . .: 0.25"
2400  return
2410  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2420  EINGABE:
2430  gotoxy  4,6 : input"",NAME$
2440  gotoxy 18,6 : input"",ANZAHL
2450  A1:
2460  gotoxy 28,6 : input"",KURS
2470  gotoxy 16,9 : input"",CS
2480  gotoxy 16,10: input"",MCS
2490  RECHNUNG:
2500  KURSWERT=ANZAHL*KURS
2510  HILF=KURSWERT*CS/10 : gosub GEBUEHREN
2520  if HILF>MCS then COURTAGE=HILF else COURTAGE=MCS
2530  HILF=KURSWERT/10 : gosub GEBUEHREN
2540  if HILF>5 then PROVISION=HILF else PROVISION=5
2550  A=KURSWERT*0.25: B=int(A): C=A-B: C=C*10: C=cint(C)
2560  if C>0 then C=1
2570  BUST=(B+C)/100
2580  SPESEN=COURTAGE+PROVISION+BUST
2590  return
2600  GEBUEHREN:
2610  A=HILF: B=int(A): C=A-B: C=C*10: C=cint(C)
2620  if C>0 and C<5 then C=5
2630  if C>5 then C=10
2640  HILF=B/10 + C/100: return
2650  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2660  ABRECHNUNG:
2670  gotoxy  0,2 : print space$(78): gotoxy 0,5: print space$(78)
2680  gotoxy  0,6 : print space$(78):
2690  gotoxy  0,5 : print" ";ANZAHL;"Stueck ";NAME$;"-Aktien"
2700  print"  zum Kurs von ";KURS;"DM"
2710  gotoxy 27,6 : print using F$;KURSWERT;: print" DM"
2720  gotoxy 20,9 : print using"#####.##";COURTAGE;: print" DM"
2730  gotoxy 20,11: print using"#####.##";PROVISION;: print" DM"
2740  gotoxy 20,13: print using"#####.##";BUST;: print" DM"
2750  gotoxy 27,13: print using F$;SPESEN;:print" DM"
2760  X$=string$(70,"-"): print "  "+X$
2770  gotoxy  1,15: print"KAUFPREIS :"
2780  gotoxy 27,15: print using F$;SUMME;: print" DM"
2790  X$=string$(70,"="): print "  "+x$: gosub RECHTECK
2800  gotoxy 17,18: input"<RETURN>",ANT$
2810  return
2820  '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2830  RECHTECK:
2840  for J = 0 to 3
2850  linef 8+J,8+J,607-J,8+J: linef 8+J,8+J,8+J,333-J
2860  linef 607-J,333-J,8+J,333-J: linef 607-J,333-J,607-J,8+J
2870  next J: return
