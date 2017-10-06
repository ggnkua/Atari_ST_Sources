10    REM****************************
20    REM*EST/LSTJA******************
30    REM*VON J.Hoefer **************
40    REM* TEL.02192/3368************
50    REM****************************
60    CLEAR
70    CLEARW 2:FULLW 2
80    DIM AG(40),AG$(40),EK(20)
90    GOTOXY 0,0:?"":CLEARW 2:GOTOXY 0,2
100   ?TAB(6) "EST/LST-PROGRAMME"
110   ?:?
120   ?"    EINKOMMENSTEUER-BERECHUNG ab 1984    = 1":PRINT
130   ?"    LOHNSTEUERJAHRESAUSGLEICH ab 1984    = 2"
140   ?:
150   ?"    EINKOMMENSTEUER-TABELLEN 1982 - 1988 = 3"
160   ?:?
170   INPUT "                                 EINGABE =  ";HH
180   IF HH <1 OR HH >3 THEN GOTO 170
190   CLEARW 2:GOTOXY 0,2
200   IF HH=1 THEN PRINT "    EINKOMMENSTEUER-BERECHNUNG":GOTO 240
210   IF HH=2 THEN PRINT "    LOHNSTEUER-JAHRESAUSGLEICH":GOTO 240
220   IF HH=3 THEN GOTO tabelle
230   REM***************************
240   ?:INPUT "    fuer Kalenderjahr 19",VZ
250   IF VZ<84 THEN GOTO 190
260   ?:
270   ?"  GRUNDANGABEN:"
280   ?:?
290   ?"  FAMILIENSTAND:"
300   ?"  LEDIG UND GETRENNTLEBEND = 1"
310   ?"               VERHEIRATET = 2"
320   ?:
330   INPUT "                   EINGABE = ";H
340   IF H <1 OR H>2 GOTO 330
350   ?:
360   INPUT "         ANZAHL DER KINDER = ";KX
370   INPUT "     ANZAHL DER ZAHLKINDER = ";KX2
380   CLEARW 2:GOTOXY 0,0
390   ?"  WEITERE GRUNDANGABEN
400   ?:?
410   ?"  PERSONENKREIS:"
420   ?:
430   ?"  BEAMTE UND SONSTIGE"
440   ?"  NICHT SOZ.VERS.PFLICHTIGE ARBEITNEHMER = 2"
450   ?:
460   ?"                   ALLE ANDEREN PERSONEN = 1"
470   ?:
480   INPUT "             EINGABE FUER STPFL./EHEMANN = ";PK1
490   IF PK1 <1 OR PK1 >2 GOTO 480
500   ?:
510   IF H=2 THEN INPUT "                    EINGABE FUER EHEFRAU = ";PK2
520   IF PK2 >2 THEN GOTO 510
530   ?:
540   INPUT "    GEBURTSDATUM STPFL./EHEMANN (TTMMJJ) = ";GBD1$
550   IF LEN(GBD1$)<>6 THEN GOTO 540
560   IF H=1 GOTO 600
570   ?:
580   IF H=2 THEN INPUT "           GEBURTSDATUM EHEFRAU (TTMMJJ) = ";GBD2$
590   IF LEN(GBD2$) <>6 THEN GOTO 580
600   REM KIRCHENSTEUER
610   CLEARW 2:GOTOXY 3,1
620   ? " Eingabe zur Kirchensteuerberecnung ":?
630   ? "                          ev = 1 "
640   ? "                          rk = 2 "
650   ? "         keine Kirchensteuer = 0 "
660   ?:
670   INPUT "  Eingabe fuer Stpl./Ehemann = ";KI1
680   ?:
690   IF PK2>0 THEN INPUT "             Eingabe Ehefrau = ";KI2
700   IF PK2=0 THEN KI2=KI1
710   REM*************************
720   REM EINGABE DER EINKUENFTE**
730   REM*************************
740   EK$(1)=" Gewinn aus Land- u. Forstwirtschaft"
750   EK$(2)=" Gewinn aus Gewerbebetrieb   "
760   EK$(3)=" Gewinn aus selbstaendiger Arbeit"
770   EK$(4)=" Nichtselbstaendige Einkuenfte"
780   EK$(5)=" Einkuenfte aus Kapitalvermoegen"
790   EK$(6)=" Einkuenfte aus Vermietung u. Verpachtung"
800   EK$(7)=" Renten u. sonstige Einkuenfte "
810   B1$=" Einkuenfte Stpfl./Ehemann :"
820   B2$=" Einkuenfte Ehefrau :"
830   REM***************************
840   ehemann:
850   REM***************************
860   P=0
870   REM LSTJA ******************************
880   IF HH=2 THEN GOSUB nichtselbst
890   IF HH=2 AND PK2=0 GOTO 930
900   CLEARW 2 :GOTOXY 0,3
910   IF HH=2 THEN INPUT " Erzielt die Ehefrau eigenen Arbeitslohn  Ja = J  ";LJ$
920   IF LJ$="J" OR LJ$="j" Then P=10:GOSUB nichtselbst
930   IF HH=2 THEN GOTO sonderausgaben
940   REM**************************************
950   GOSUB eingabe
960   CLEARW 2:GOTOXY 0,3
970   IF PK2=0 GOTO 1000
980   INPUT " Erzielt die Ehefrau eigene Einkuenfte ?  Ja=J ";EE$
990   IF EE$="J" OR EE$="j" THEN GOTO ehefrau
1000  GOTO sonderausgaben
1010  REM***************************************
1020  eingabe:
1030  JA$=" (JA=J) ? "
1040  FOR I=1 TO 7:X$(I)="":NEXT I
1050  FOR I=1 TO 7
1060  CLEARW 2:GOTOXY 0,2
1070  If  P<10 THEN ?" Erzielt der Stpfl./Ehemann":GOTO 1090
1080  ?" Erzielt die Ehefrau":?
1090  ?:? EK$(I);
1100  INPUT "  JA=J ";X$(I)
1110  IF X$(1)="J" OR X$(1)="j" THEN GOSUB lafo
1120  IF X$(2)="J" OR X$(2)="j" THEN GOSUB gewerbe
1130  IF X$(3)="J" OR X$(3)="j" THEN GOSUB selbst
1140  IF X$(4)="J" OR X$(4)="j" THEN GOSUB nichtselbst
1150  IF X$(5)="J" OR X$(5)="j" THEN GOSUB kapital
1160  IF X$(6)="J" OR X$(6)="j" THEN GOSUB verver
1170  IF X$(7)="J" OR X$(6)="j" THEN GOSUB renten
1180  NEXT I
1190  RETURN
1200  REM***************************************
1210  ehefrau: P=10:GOSUB eingabe:goto sonderausgaben
1220  REM*******************************************
1230  lafo:
1240  REM*******************************************
1250  CLEARW 2:GOTOXY 0,3
1260  IF P=0 THEN ? B1$ ELSE ? B2$
1270  ?:?
1280  ?EK$(1);
1290  INPUT " = DM ";G1:G1=INT(G1)
1300  IF P=0 THEN EK(1)=G1:G1=0
1310  IF P=10 THEN EK(11)=G1
1320  X$(I)=""
1330  RETURN
1340  REM**************************************
1350  gewerbe:
1360  REM**************************************
1370  CLEARW 2:GOTOXY 0,3
1380  IF P=0 THEN ? B1$ ELSE ? B2$
1390  ?:?
1400  ?EK$(2);
1410  INPUT " = DM ";G2:G2=INT(G2)
1420  IF P=O THEN GEW1=G2:G2=0
1430  IF P=10 THEN GEW2=G2
1440  EK(2)=GEW1:EK(12)=GEW2
1450  X$(I)=""
1460  RETURN
1470  REM**********************************
1480  selbst:
1490  REM**********************************
1500  CLEARW 2:GOTOXY 0,3
1510  IF P=0 THEN ? B1$ ELSE ? B2$
1520  ?:?
1530  INPUT " Gewinn aus freiberufl. Taetigkeit = DM ";G3:G3=INT(G3)
1540  IF G3=0 GOTO 1620
1550  IF P=0 THEN FF=G3:G3=0
1560  IF P=10 THEN FF1=G3
1570  ?:
1580  INPUT " Betriebseinnahmen aus freiberufl. Taetigkeit = DM ";GG3
1590  IF P=0 THEN FF2=GG3:GG3=0
1600  IF P=10 THEN FF3=GG3
1610  ?:
1620  INPUT " Gewinn aus sonstiger selbstaendiger Taetigkeit = DM ";G4:G4=INT(G4)
1630  IF P=0 THEN G5=G4:G4=0
1640  IF P=10 THEN P6=G4
1650  EK(3)=FF+G5:EK(13)=FF1+G6
1660  X$(I)=""
1670  RETURN
1680  REM*******************************************
1690  nichtselbst:
1700  REM*******************************************
1710  CLEARW 2:GOTOXY 0,2
1720  IF P=0 THEN ? B1$ ELSE ? B2$
1730  ?:?
1740  IF P=10 GOTO 1910
1750  ?" Brutto-Arbeitslohn lt. Steuerkarte"
1760  INPUT " (ohne Versorgungsbezuege)       = DM ";EN1:EN1=INT(EN1)
1770  ?:
1780  INPUT " Versorgungsbezuege z.B. Pensionen = DM ";EN2:EN2=INT(EN2)
1790  ?
1800  INPUT " Einbehaltene Lohnsteuer lt. St.Karte = DM.PF ";EN3
1810  ?
1820  IF KI1=1 OR KI2=1 THEN INPUT " Einbehaltene ev. Kirchensteuer = DM.PF ";EN4
1830  ?:
1840  IF KI1=2 OR KI2=2 THEN INPUT " Einbehaltene rk. Kirchensteuer = DM.PF ";EN5
1850  ?: ?" Einnahmen wie Schlechtwettergeld + Kurzarbeitergeld "
1860  INPUT "  + Arbeitslosengeld oder -hilfe  (brutto)  = DM ";BES6
1870  ?
1880  INPUT " Uebersteigen die Werbungskosten 564 DM   Ja = J ";WK$
1890  IF WK$="J" OR WK$="j" THEN GOSUB werbungskosten
1900  GOTO 2040
1910  ? " Brutto-Arbeitslohn lt. Steuerkarte"
1920  INPUT " (ohne Versogungsbezuege)           = DM ";EY1:EY1=INT(EY1)
1930  ?:
1940  INPUT " Versorgungsbezuege z.B.Pensionen = ";EY2:EY2=INT(EY2)
1950  ?
1960  INPUT " Einbehaltene Lohnsteuer lt. Karte  = DM.PF ";EY3:?
1970  IF KI1=1 OR KI2=1 THEN INPUT " Einbehaltene ev. Kirchensteuer = DM.PF ";EY4
1980  IF KI1=2 OR KI2=2 THEN INPUT " Einbehaltene rk. Kirchensteuer = DM.PF ";EY5
1990  ?:? " Einnahmen wie Schlechtwettergeld + Kurzarbeitergeld"
2000  INPUT " + Arbeitslosengeld oder -hilfe  (brutto)    = DM ";BES7
2010  ?
2020  INPUT " Uebersteigen die Werbungskosten 564 DM  Ja = J  ";WKY$
2030  IF WKY$="J" OR WKY$="j" THEN GOSUB werbungskosten
2040  REM******************************************** 
2050  REM BERECHNUNGEN nichtselbst EINKUENFTE
2060  REM********************************************
2070  V2=600:V3=480:VA=480:V22=600:IF EY1+EY2=0 THEN V22=0
2075  IF EN1+EN2=0 THEN V2=0
2080  REM VERSORGUNGS-FREIBETRAG
2090  W2=INT(.4*EN2):IF W2>4800 THEN W2=4800
2100  W3=INT(.4*EY2):IF W3>4800 THEN W3=4800
2110  E4=EN1+EN2-W2-V2
2120  IF E4<0 THEN E4=0
2130  E5=EY1+EY2-W3-V22
2140  IF E5<0 THEN E5=0
2150  IF V3>E4 THEN V3=E4
2160  IF VA>E5 THEN VA=E5
2170  E6=E4-V3:IF E6<0 THEN E6=0
2180  E7=E5-VA:IF E7<0 THEN E7=0
2190  WK=564
2200  IF WK>E6 THEN WK=E6
2210  IF WK2>WK THEN WK=WK2
2220  WKY=564 
2230  IF WKY>E7 THEN WKY=E7
2240  IF WK3>WKY THEN WKY=WK3
2250  EK(4)=E6-WK
2260  EK(14)=E7-WKY
2270  X$(I)=""
2280  RETURN
2290  REM *************************************************
2300  werbungskosten:
2310  REM *************************************************
2320  CLEARW 2:GOTOXY 0,2
2330  ? "  WERBUNGSKOSTEN :"
2340  ? 
2350  ? "  a) Fahrten mit Pkw zwischen Wohnung u. Betrieb"
2360  INPUT "     Entfernung in KM = ";KM
2370  IF KM=0 GOTO 2400
2380  ? 
2390  INPUT "     Anzahl der Arbeitstage = ";AT
2400  ?:?
2410  ? "  b) sonstige Werbungskosten"
2420  ? "     z.B. Arbeitsmittel"
2430  ? "          Verpflegungsmehraufwand"
2440  ? "          Gewerkschaftsbeitrag"
2450  ? "          doppelte Haushaltsfuehrung usw."
2460  ?:
2470  INPUT "              Sonstige Werbungskosten = DM ";SWK
2480  SWK=INT(SWK)
2490  KM1=INT(KM*AT*.36+.5)
2500  WK1=KM1+SWK:IF P=0 THEN WK2=WK1
2510  IF P=10 THEN WK3=WK1
2520  KM=0:AT=0:SWK=0:WK1=0
2530  RETURN
2540  REM ************************************
2550  kapital:
2560  REM ************************************
2570  CLEARW 2:GOTOXY 0,2
2580  IF P=0 THEN ? B1$ ELSE ? B2$
2590  ?:?
2600  ? EK$(5):?
2610  INPUT " Zinseinnahmen aus Sparguthaben usw. = DM ";ZE(1):ZE(1)=INT(ZE(1))
2620  INPUT " Einnahmen aus Dividenden            = DM ";ZE(2):ZE(2)=INT(ZE(2))
2630  ?:
2640  INPUT " Werbungskosten                      = DM ";ZE(3):ZE(3)=INT(ZE(3))
2650  ?:
2660  IF ZE(2)>0 THEN INPUT " Einbehaltene Kapitalertragsteuer (DM.PF)= ";ZE(4)
2670  IF ZE(2)>0 THEN INPUT " Einbehaltene Koerperschaftsteuer (DM.PF)= ";ZE(5)
2680  FOR B=1 TO 5
2690  IF P=0 THEN ZE1(B)=ZE(B):ZE(B)=0: GOTO 2710
2700  ZE2(B)= ZE(B)
2710  NEXT B:B=0
2720  B=0
2730  ZE3=ZE1(1)+ZE1(2)
2740  ZE4=ZE2(1)+ZE2(2)
2750  V6=100:V7=100:V8=300:V9=300
2760  IF PK2=0 THEN V7=0:V9=0
2770  IF PK2>0 THEN GOTO 2830
2780  IF V6>ZE3 THEN V6=ZE3
2790  IF ZE1(3)>V6 THEN V6=ZE1(3)
2800  IF V8>(ZE3-V6) THEN V8=(ZE3-V6)
2810  IF V8<0 THEN V8=0
2820  GOTO 3060
2830  ZZ=0:IF (ZE1(3)+ZE2(3))>(V6+V7) THEN V6=0:V7=0:ZZ=1:GOTO AAA
2840  ZW1=V7-ZE4
2850  ZW2=V6-ZE3
2860  IF ZW1<0 THEN ZW1=0
2870  IF ZW2<0 THEN ZW2=0
2880  V6=V6+ZW1
2890  IF V6>ZE3 THEN V6=ZE3
2900  V7=V7+ZW2
2910  IF V7>ZE4 THEN V7=ZE4
2920  AAA: ZW3=ZE3-V6
2930  IF ZZ=1 THEN ZW3=ZE3-ZE1(3):V6=ZE1(3)
2940  IF ZW3<0 THEN ZW3=0
2950  ZW4=ZE4-V7
2960  IF ZZ=1 THEN ZW4=ZE4-ZE2(3):V7=ZE2(3)
2970  IF ZW4<0 THEN ZW4=0
2980  ZW5=V9-ZW4
2990  IF ZW5<0 THEN ZW5=0
3000  ZW6=V8-ZW3
3010  IF ZW6<0 THEN ZW6=0
3020  V8=V8+ZW5
3030  IF V8>ZW3 THEN V8=ZW3
3040  V9=V9+ZW6
3050  IF V9>ZW4 THEN V9=ZW4
3060  EK(5)=ZE3-V6-V8
3070  EK(15)=ZE4-V7-V9
3080  X$(I)=""
3090  RETURN
3100  REM *****************************
3110  verver:
3120  REM *****************************
3130  CLEARW 2: GOTOXY 0,2
3140  IF P=0 THEN ? B1$ ELSE ?B2$
3150  ?:?
3160  ?EK$(6):?
3170  ? " Selbst genutztes Einfamilienhaus/Eigentumswohmung"
3180  INPUT " oder sonst. Anwendung des Par.21a EStG   JA=J  ";VV$
3190  IF VV$="J" OR VV$="j" THEN GOTO 3210
3200  GOTO 3300
3210  ?:
3220  INPUT " Einheitswert = ";VV1
3230  INPUT " Wohnzwecke in % = ";VV2:?
3240  INPUT " Selbstnutzung in Monaten = ";VV3
3250  ?" Zinsen oder andere Werbungskosten  v o r  Selbstnutzung sowie"
3260  INPUT " SONDER-ABZUG VON ZINSEN BIS 10.000 = DM ";VV4:?
3270  INPUT " Zinsen  n a c h  Selbstnutzung = DM ";VV5
3280  ?:
3290  INPUT " AFA (7b,82a) = ";VV6
3300  ?:
3310  INPUT " Sonstige Einkuenfte aus Vermietung u. Verpachtung = ";VV7
3320  VV8=INT(VV1*1.4/100*VV2/100*VV3/12)
3330  IF VV5>VV8 THEN VV5=VV8
3340  VV9=INT(VV8-VV4-VV5+VV7)
3350  IF P=10 THEN GOTO 3380
3360  EK(6)=VV9
3370  VV1=0:VV2=0:VV3=0:VV4=0:VV5=0:VV6=0:VV7=0:VV9=0:GOTO 3390
3380  EK(16)=VV9
3390  X$(I)=""
3400  IF VV1$="J" OR VV1$="j" THEN GOTO 3530
3410  REM PAR. 34f **************************
3420  CLEARW 2:GOTOXY 1,3
3430  ?" noch ";EK$(6)
3440  ?:?
3450  ?" Wurde erhoete AFA nach Par. 7b EStG beantragt"
3460  ?" u n d  war Bauantrag"
3470  ?"        oder Baubeginn"
3480  ?"        oder Erwerb   nach dem 29.7.1981"
3490  ?" u n d  war das Gebaeude selbst bewohnt ?"
3500  INPUT "                                     JA = J ";VV1$
3510  IF VV1$= "J" OR VV1$= "j" THEN KK2=KX-1
3520  IF KK2<=0 THEN KK2=0
3530  RETURN
3540  REM**********************************
3550  renten:
3560  REM**********************************
3570  CLEARW 2:GOTOXY 0,3
3580  IF P=0 THEN ? B1$ ELSE ? B2$
3590  ?:?
3600  ? EK$(7)
3610  ?:
3620  INPUT "  Renteneinnahmen = DM ";RE1
3630  IF RE1=0 GOTO 3690
3640  ?:
3650  INPUT "  Ertragsanteil in % = ";RE2
3660  ?:
3670  ?"  Werbungskosten"
3680  INPUT"   (wenn mehr als 200 DM) = DM ";RE3
3690  ?:?
3700  INPUT "  Sonstige Einkuenfte i.s. Par.22,23 u. 24 ESTG = DM ";RE4
3710  RE5=INT(RE1*RE2/100)
3720  RE6=200:IF RE6>RE5 THEN RE5=RE6
3730  IF RE3>RE6 THEN RE6=RE3
3740  RE7=RE5-RE6+RE4
3750  IF P=10 THEN GOTO 3780
3760  EK(7)=RE7:RENTE1=EK(7)-RE4
3770  RE1=0:RE2=0:RE3=0:RE4=0:RE5=0:RE6=O:RE7=0:GOTO 3790
3780  EK(17)=RE7:RENTE2=EK(17)-RE4
3790  X$(I)=""
3800  RETURN
3810  REM********************************
3820  sonderausgaben:
3830  REM********************************
3840  CLEARW 2:GOTOXY 0,2
3850  ?"     V o r s o r g e a u f w e n d u n g e n :"
3860  ?:
3870  IF EN1=0 AND EN2=0 THEN GOTO 3940
3880  ? " Arbeitnehmer-Anteil zur SOZIALVERSICHERUNG "
3890  INPUT " (Stpfl/Ehemann) = DM ";BAS1
3900  ?:
3910  ?" ArbeitGEBER-Anteil zur ges. Rentenversicherung (Stpfl/Ehemann)"
3920  ? " lt. Steuerkarte"
3930  Input " (bei Beamten oder bei Schaetzung = 1) = DM ";BAS2
3940  IF EY1=0 AND EY2=0 THEN GOTO 4010
3950  ?:
3960  ? " Arbeitnehmeranteil zur SOZIALVERSICHERUNG (Ehefrau)"
3970  INPUT " (Ehefrau)  = DM ";BAS3:?
3980  ? " ArbeitGEBER-Anteil zur Rentenversicherung (Ehefrau)"
3990  ? " lt. Steuerkarte"
4000  INPUT " (bei Beamten oder bei Schaetzung = 1)   = DM ";BAS4
4010  ?:
4020  IF PK2>0 THEN ? " fuer Ehegatten gemeinsam !"
4030  ?" Gezahlte Versicherungsbeitraege"
4040  ?"  z.B. Lebensversicherung"
4050  ?"       Krankenversicherung"
4060  ?"       Haftpflichtversicherung  usw.":?
4070  INPUT "            in einer Summe = DM ";BAS5
4080  ?
4090  INPUT " Beitraege an Bausparkassen = DM ";BAS6
4100  REM***********************************
4110  REM unbeschraenkt abzugsfaehige SA
4120  REM***********************************
4130  CLEARW 2:GOTOXY 0,2
4140  INPUT " Unbeschraenkt abzugsfaehige Sonderausgaben   Ja = J ";USA$
4150  IF USA$ = "J" OR USA$ = "j" THEN GOTO 4160 ELSE GOTO 4360
4160  ?"    Unbeschraenkt abzugsfaehige Sonderausgaben"
4170  ?:
4180  IF PK2>0 THEN ? " fuer Ehegatten gemeinsam"
4190  ?:?
4200  ?" Gezahlte Kirchensteuer"
4210  INPUT " (nach Abzug von Erstattungen) = DM ";USA1
4220  ?
4230  INPUT " Beitraege u. Spenden an politische Parteien = DM ";USA2
4240  ?:
4250  INPUT " Sonstige Spenden = DM ";USA3
4260  IF USA3=0 GOTO 4290
4270  ?" darin enthaltene Spenden fuer wissentschaftliche "
4280  INPUT "                      und kulturelle Zwecke = DM ";USA4
4290  CLEARW 2:GOTOXY 0,3 
4300  ? " Weitere unbeschraenkt abzugsfaehige Sonderausgaben"
4310  ? "    wie Verluste gem. Par. 10d EStG"
4320  ? "        Vermoegensteuer"
4330  ? "        Steuerberatungskosten"
4340  ? "        Renten u. dauernde Lasten"
4350  INPUT "                               usw. = DM ";USA5
4360  REM ****************************************** 
4370  REM AUSSERGWOEHNLICHE BELASTUNG
4380  REM ******************************************
4390  CLEARW 2:GOTOXY 0,2
4400  INPUT "  Aussergewoehnliche Belastung     Ja = J  ";AGB1$:?
4410  IF AGB1$= "J" OR AGB1$= "j" GOTO 4420 ELSE GOTO 4610
4420  ? " Kinderbetreuungskosten Alleinstehender gem. Par. 33c ESTG"
4430  ? " wegen Erwerbstaetigkeit"
4440  ? " fuer Kinder, die allein zum Haushalt des Stpfl. gehoeren"
4450  INPUT "     Entstandene Aufwendungen = DM ";AGB5
4460  IF AGB5=0 GOTO 4490
4470  INPUT "     Anzahl der Kinder bis 16 J. = ";KX1
4480  INPUT "     Zeitraum in Monaten = ";KB4
4490  ?:
4500  ? " Aužergewoehnliche Belastung gem. Par. 33 EStG"
4510  ? " wie Krankheitskosten"
4520  ? "     Beerdigungskskosten usw."
4530  INPUT "         tatsaechliche Aufwendungen = DM ";AGB1
4540  ?
4550  ? " Aussergewoehnliche Belastung gem. Par. 33a EStG"
4560  ? " wie Unterhaltsleistungen"
4570  ? "     Ausbildungsfreibetraege"
4580  ? "     Haushaltshilfen"
4590  INPUT "          abzugsfaehige Aufwendungen = DM ";AGB2
4600  CLEARW 2:GOTOXY O,3
4610  INPUT " Pauschbetrag for Koerperbehinderung  Ja = J  ";AGB2$
4620  IF AGB2$ =  "J" OR AGB2$= "j" GOTO 4630 ELSE GOTO 4690
4630  ?
4640  ? "  ERWERBSMINDERUNG IN % "
4650  INPUT "   (dauernd pflegebeduerftig = 300)   = % ";AGB3
4660  ?
4670  ? "  Erwerbsminderung fuer eine weitere Person"
4680  INPUT "                        (ggf=0) in % = ";AGB4
4690  REM  LSTJA ******************************************
4700  IF HH=2 GOTO berechnungen
4710  REM *************************************************
4720  REM Besondere Steuerermaessigungen und Abzugsbetraege
4730  REM *************************************************
4740  CLEARW 2:GOTOXY 0,3
4750  INPUT " Besondere Steuerermaessigungen und Abzugsbetraege  Ja = J ";BES$
4760  IF BES$ =  "J" OR BES$ =  "j" THEN GOTO 4770 ELSE GOTO berechnungen
4770  ?
4780  INPUT " Ermaessigungsbetrag gem. Par. 16,17 BerlinFG = DM ";BES1
4790  ?
4800  INPUT " Ermaessigungsbetrag gem. Par. 14 VermBG = DM ";BES2
4810  ?
4820  INPUT " Ausbildungsplatzfreibertrag gem. Par. 24 b EStG = DM ";BES3
4830  ?
4840  ?" In den Einkuenften sind Einkuenfte,die mit ermaessigtem "
4850  INPUT " Steuersatz versteuert werden (Par. 34 ff EStG) = DM ";BES4
4860  ?
4870  ? " Einkuenfte, die wegen des Progressionsvorbehalts bei der "
4880  ? " Berechnung der Einkommensteuer beruecksichtigt werden muessen"
4890  ? " ausser Schlechtwettergeld,Kurzarbeitergeld oder Arbeitslosenhilfe"
4900  INPUT "                                  DM = ";BES5
4910  ?
4920  ? " Erfinderverguetungen, die im Brutto-Arbeitslohn "
4930  INPUT "                             enthalten sind = DM ";BES8
4940  REM***********************************************
4950  berechnungen:
4960  REM***********************************************
4970  REM ALTER
4980  ALT1=VAL(RIGHT$(GBD1$ ,2)+MID$(GBD1$,3,2)+LEFT$(GBD1$,2))
4990  IF ALT1<(VZ*10000+102-640000) THEN ALTER1=7
5000  IF PK2=0 THEN GOTO 5030
5010  ALT2=VAL(RIGHT$ (GBD2$,2)+MID$(GBD2$,3,2)+LEFT$ (GBD2$,2))
5020  IF ALT2 <(VZ*10000+102-640000) THEN ALTER2=7
5030  IF ALTER1 = 7 OR ALTER2 = 7 THEN AFB= 720
5040  IF ALTER1 = 7 AND ALTER2 = 7 THEN AFB= 1440
5050  REM Summe der Einkuenfte
5060  Z=0:FOR Z = 1 TO 7
5070  SDE1=SDE1+EK(Z)
5080  SDE2=SDE2+EK(Z+10)
5090  AG(1)=SDE1+SDE2
5100  NEXT Z:Z=0
5110  REM ALTERSENRLASTUNGSBETRAG
5120  IF ALTER1<7 GOTO 5170
5130  AEB1=SDE1-EK(4)-RENTE1
5140  IF AEB1<0 THEN AEB1=0
5150  AEB1=INT((AEB1+EN1)*40/100)
5160  IF AEB1>3000 THEN AEB1=3000
5170  IF ALTER2<7 GOTO 5220
5180  AEB2=SDE2-EK(14)-RENTE2
5190  IF AEB2<0 THEN AEB2=0
5200  AEB2=INT((AEB2+EN2)*40/100)
5210  IF AEB2>3000 THEN AEB2=3000
5220  AG(2)=AEB1+AEB2
5230  REM*********************************
5240  REM AUSBILDUNGSPLATZFREIBETRAG
5250  AG(3)=INT(BES3+.5)
5260  REM FREIBETRAG LAF0
5270  FB=2000:IF PK2>0 THEN FB=4000
5280  IF FB>(EK(1)+EK(11)) THEN FB=EK(1)+EK(11)
5290  AG(4)=FB:FB=0
5300  REM GESAMTBETRAG DER EINKUENFTE
5310  AG(5)=AG(1)-AG(2)-AG(3)-AG(4)
5320  REM GEZAHLTE KIST
5330  AG6=USA1
5340  REM SPENDEN
5350  A=0:B=0:C=0:D=0:E=0:F=0
5360  A=5/100*AG(5)
5370  IF A<0 THEN A=0
5380  B=USA4:IF USA4>2*A THEN B=2*A
5390  C=1200:IF PK2>0 THEN C=2400
5400  D=USA2-C
5410  IF D<0 THEN D=0
5420  E=USA3-USA4+D
5430  IF E>A THEN E=A
5440  AG7= INT(B+E+.5)
5450  REM STEUERERM. FUER PARTEISPENDEN
5460  IF USA2>C THEN USA2=C
5470  STE= INT(USA2*50/100+.5)
5480  REM SONST. UNB.ABZF.SA
5490  F=270:IF H=2 THEN F=540
5500  AG8=USA5
5510  AG9=AG6+AG7+AG8
5520  IF AG9<F THEN AG9=F:AG(9)=AG9
5530  IF AG9>F THEN AG(6)=AG6:AG(7)=AG7:AG(8)=AG8
5540  A=0:B=0:C=0:D=0:E=0:F=0
5550  REM****************************
5560  REM SA-HOECHSTBETRAGSBERECHNUNG
5570  REM****************************
5580  A=2340:IF PK2>0 THEN A=4680
5590  B=1000:IF PK2>0 THEN B=2000
5600  C=600:IF VZ>85 THEN C=0
5610  UX=60000
5620  IF VZ=84 THEN UX=62400
5630  IF VZ=85 THEN UX=64800
5640  IF VZ=86 THEN UX=67200
5650  VW=3000: IF PK2>0 THEN VW=6000
5660  '
5670  VORSA=BAS1+BAS3+BAS5
5680  D=EN1:IF D>UX THEN D=UX
5690  E=EY1:IF E>UX THEN E=UX
5700  IF BAS2=1 THEN BAS2=INT (D*9/100)
5710  IF BAS4=1 THEN BAS4=INT (E*9/100)
5720  VW1=VW-(BAS2+BAS4):IF VW1<0 THEN VW1=0
5730  S1=VORSA-VW1
5740  IF S1<0 THEN S1=0
5750  FX=VW1
5760  IF VW1>VORSA THEN FX=VORSA
5770  S2=S1+BAS6
5780  GX1=A+KX*C+KX2*C*.5
5790  GX2=GX1
5800  IF GX1>S2 THEN GX2=S2
5810  S3=S2-GX1
5820  IF S3<0 THEN S3=0:GOTO 5870
5830  SX=INT (S3/2)
5840  SY=GX1/2
5850  IX=SX
5860  IF SX>SY THEN IX=SY
5870  S4=FX+GX2+IX
5880  AG10=S4
5890  '
5900  REM VORSORGEPAUSCHALE
5910  '
5920  GX=E4-AEB1
5930  IF GX>UX THEN GX=UX
5940  GY=E5-AEB2
5950  IF GY>UX THEN GY=UX
5960  JX=GX+GY
5970  MX=INT(JX*9/100)
5980  IF PK1<2 AND PK2<2 THEN GOTO 6020
5990  IF PK1+PK2=2 OR PK1+PK2=4 THEN GOTO 6090
6000  IF PK1+PK2=3 THEN GOTO 6190
6010  'AA
6020  LX=A+KX*C+KX2*C*.5
6030  L1=LX
6040  IF LX>MX THEN L1=MX
6050  M1=LX/2
6060  L2=MX:IF MX>M1 THEN L2=M1
6070  GOTO 6130
6080  ' BB
6090  LX=B+KX*C+KX2*C*.5
6100  L1=LX:IF LX>MX THEN L1=MX
6110  LX1=B+KX*C*.5+KX2*C*.25
6120  L2=MX:IF MX>LX1 THEN L2=LX1
6130  S5=L1+L2
6140  S5=INT(S5/54)*54
6150  IF S5<300 AND PK2=0 THEN S5=300
6160  IF S5<600 AND PK2>0 THEN S5=600
6170  AG11=S5:GOTO 6420
6180  'AB
6190  IF PK1=1 THEN OX=18/100*GX ELSE OX=18/100*GX
6200  IF PK1=2 THEN M2=9/100*GX ELSE M2=9/100*GY
6210  PX=1000+KX*C+KX2*C*.5
6220  O1=M2:IF M2>PX THEN O1=PX
6230  PY=1000+KX*.5*C+KX2*C*.25
6240  O2=M2:IF M2>PY THEN O2=PY
6250  S6=OX+O1+O2
6260  LX=A+KX*C+KX2*C*.5
6270  L3=S6:IF S6>LX THEN L3=LX
6280  NX=S6-LX:IF NX<=0 THEN L4=0:GOTO 6300
6290  L4=INT(NX/2):IF L4>(LX/2) THEN L4=LX/2
6300  S7=L3+L4
6310  '
6320  PX1=2000+KX*C+KX2*C*.5
6330  M3=M2:IF M2>PX1 THEN M3=PX1
6340  PY1=2000+KX*.5*C+KX2*C*.25
6350  M4=M2:IF M2>PY1 THEN M4=PY1
6360  S8=M3+M4
6370  VORP=S7:IF S8>S7 THEN VORP=S8
6380  VORP=INT(VORP/54)*54
6390  IF VORP<600 THEN VORP=600
6400  '
6410  AG11=VORP
6420  ABZ= AG10:IF AG11>AG10 THEN ABZ=AG11
6430  AG(12)=ABZ
6440  A=0:B=0:C=0:D=0:E=0:F=0
6450  REM**************************************************
6460  REM FREIBETRAG FUER FREIE BERUFE
6470  REM*******************************************
6480  IF FF>(SDE1-FF) THEN FFB1=INT(.05*FF2+.5)
6490  IF FFB1>1200 THEN FFB1=1200
6500  IF FF1>(SDE2-FF1) THEN FFB2 = INT(.05*FF3+.5)
6510  IF FFB2>1200 THEN FFB2=1200
6520  AG(13)=FFB1+FFB2
6530  REM******************************************
6540  REM PAR. 33 ESTG
6550  REM******************************************
6560  A=KX+KX2
6570  IF A=0 AND H=1 AND AG(5)<=30000 THEN B=5
6580  IF A=0 AND H=1 AND AG(5)>30000 THEN B=6
6590  IF A=0 AND H=1 AND AG(5) >100000 THEN B=7
6600  IF A=0 AND H=2 AND AG(5)<=30000 THEN B=4
6610  IF A=0 AND H=2 AND AG(5)>30000 THEN B=5
6620  IF A=0 AND H=2 AND AG(5)>100000 THEN B=6
6630  IF A<=2 AND A>0 AND AG(5)<=30000 THEN B=2
6640  IF A<=2 AND A>0 AND AG(5)>30000 THEN B=3
6650  IF A<=2 AND A>0 AND AG(5)>100000 THEN B=4
6660  IF A>2 AND AG(5)<=100000 THEN B=1
6670  IF A>2 AND AG(5)>100000 THEN B=2
6680  AGB7=B
6690  ZBE=INT(AG(5)*B/100)
6700  IF ZBE<0 THEN ZBE=0
6710  IF AGB5=0 GOTO 6790
6720  KB1=AGB5-ZBE
6730  IF KB1<0 THEN KB1=0
6740  KB2=4000+(KX1-1)*2000
6750  KB3=KX1*480
6760  IF KB1>KB2 THEN KB1=KB2
6770  IF KB1<KB3 THEN KB1=KB3
6780  KB5=INT(KB1*KB4/12+.99)
6790  RZBE=ZBE-AGB5
6800  IF RZBE<0 THEN RZBE=0
6810  AG14=AGB1-RZBE
6820  IF AG14<0 THEN AG14=0
6830  AG(14)=AG14+KB5
6840  A=0:B=0
6850  REM*************************************
6860  REM PAR. 33a
6870  REM*************************************
6880  AG(15)=AGB2
6890  REM*************************************
6900  REM PAUSCHBETRAG FUER KOERPERBEHINDERUNG
6910  REM*************************************
6920  A=AGB3:GOSUB prozent:C=B:B=0:A=AGB4:GOSUB prozent:D=B
6930  AG(16)=C+D:GOTO 7050
6940  prozent:
6950  IF A>=25 AND A<=34 THEN B=600
6960  IF A>=35 AND A<=44 THEN B=840
6970  IF A>=45 AND A<=54 THEN B=1110
6980  IF A>=55 AND A<=64 THEN B=1410
6990  IF A>=65 AND A<=74 THEN B=1710
7000  IF A>=75 AND A<=84 THEN B=2070
7010  IF A>=85 AND A<=90 THEN B=2400
7020  IF A>=91 AND A<=100 THEN B=2760
7030  IF A=300 THEN B=7200
7040  RETURN
7050  A=0:B=0:C=0:D=0
7060  REM***************************************
7070  REM EINKOMMEN
7080  REM***************************************
7090  EINK=AG(5)-AG(6)-AG(7)-AG(8)-AG(9)-AG(12)-AG(13)-AG(14)-AG(15)-AG(16)
7100  AG(17)=EINK
7110  REM***************************************
7120  REM ALTERSFREIBETRAG
7130  REM************************************
7140  AG(18)=AFB
7150  REM HAUSHALTSFREIBETRAG
7160  '
7170  IF PK2=0 AND H=1 AND KX>0 THEN HFB=4212
7180  IF PK2=0 AND H=1 AND VZ>85 AND KX>0  THEN HFB=4536
7190  AG(19)=HFB
7200  '
7210  'KINDERFREIBETRAG
7220  KFB=432:IF VZ>85 THEN KFB=2484
7230  AG(20)=KX*KFB+KX2*KFB*.5
7240  '
7250  ' HAERTEAUGLEICH
7260  '
7270  IF H=1 AND AG(17)>24000 THEN GOTO 7430
7280  IF H=2 AND AG(17)>48000 THEN GOTO 7430
7290  IF EK(4)+EK(14)<=0 THEN GOTO 7430
7300  A=.4*(EN1+EY1)
7310  B=AG(2)-A
7320  IF B<0 THEN B=0
7330  FR=SDE1+SDE2-EK(4)-EK(14)
7340  IF FR>0 AND FR<=800 THEN FS=FR
7350  IF FR>800 AND FR<1600 THEN FS=1600-FR
7360  C=.4*FS
7370  IF B>C THEN B=C
7380  FS=FS-B
7390  IF FS+AG(4)>FR THEN FS=FS-(FS+AG(4)-FR)
7400  IF FS<0 THEN FS=0
7410  AG(21)=FS
7420  A=0:B=0:C=0
7430  REM************************************
7440  REM ZU VERSTEUERNDES EINKOMMEN
7450  REM************************************
7460  ZVE=AG(17)-AG(18)-AG(19)-AG(20)-AG(21)
7470  AG(22)=ZVE
7480  E=ZVE
7490  REM************************************
7500  REM PROGRESSIONSVORBEHALT
7510  F=BES5+BES6+BES7
7520  REM ERAESS.STEUERSATZ
7530  G=BES4
7540  GOSUB tabelle
7550  AG(23)=T+U
7560  IF BES8>AG(5) THEN BES8=AG(5)
7570  AG(24)=INT(BES8*AG(23)/AG(5)/2+.99)
7580  IF AG(24)>AG(23) THEN AG(24) = AG(23)
7590  AG(25)=STE
7600  IF AG(25)>(AG(23)-AG(24)) THEN AG(25)=AG(23)-AG(24)
7610  IF BES1>(INT((AG(23)-AG(24))*.5)) THEN BES1=INT((AG(23)-AG(24))*.5)
7620  AG(26)=BES1+BES2
7630  IF AG(26)>(AG(23)-AG(24)-AG(25)) THEN AG(26)=AG(23)-AG(24)-AG(25)
7640  AG(27)=KK2*600
7650  IF AG(27)>(AG(23)-AG(24)-AG(25)) THEN AG(27)=AG(23)-AG(24)-AG(25)-AG(26)
7660  AG(28)=AG(23)-AG(24)-AG(25)-AG(26)-AG(27)
7670  AG(29)=INT(EN3+EY3+.99)
7680  AG(30)=INT(ZE1(4)+ZE2(4)+.99)
7690  AG(31)=INT(ZE1(5)+ZE2(5)+.99)
7700  AG(32)=AG(28)-AG(29)-AG(30)-AG(31)
7710  REM****************************************
7720  REM Kirchensteuer-Berechnung
7730  REM****************************************
7740  IF KX=1 THEN KI3 = 600
7750  IF KX=2 THEN KI3=1560
7760  IF KX>2 THEN KI3=1560+(KX-2)*1800
7770  IF VZ>85 THEN KI3=KX*600
7780  KIA=AG(28)-KI3
7790  IF KIA<=0 THEN KIA=0:AG(33)=0:AG(36)=0:GOTO KIKI
7800  IF KI1>0 AND KI2=0 OR KI1=0 AND KI2>0 GOTO KI
7810  IF KI1=KI2 AND KI1=1 THEN AG(33)=INT(.09*KIA)
7820  IF KI1=KI2 AND KI1=2 THEN AG(36)=INT(.09*KIA)
7830  IF KI1<>KI2 THEN AG(33)=INT(.09*KIA*.5*100)/100:AG(36)=INT(.09*KIA*50)/100
7840  GOTO KIKI
7850  KI:H9=H:T9=T:F9=F:G9=G:K9=K:U9=U:V9=V
7860  E=SDE1:T=0:G=0:F=0: H=1:GOSUB tabelle:KI5=T
7870  T=0:E=SDE2:GOSUB tabelle:KI6=T
7880  H=H9:T=T9:F=F9:G=G9:K=K9:U=U9:V=V9
7890  KIB=KI5:IF KI1=0 THEN KIB=KI6
7900  KIC=KI5+KI6
7910  KID=KIA*KIB/KIC
7920  IF KI1=1 OR KI2=1 THEN AG(33)=INT(.09*KID*100)/100
7930  IF KI1=2 OR KI2=2 THEN AG(36)=INT(.09*KID*100)/100
7940  KIKI:
7950  AG(34)=EN4+EY4
7960  AG(35)=INT(AG(33)-AG(34))
7970  IF AG(35)<0 THEN AG(35)=INT(AG(33)-AG(34)-.99)
7980  AG(37)=EN5+EY5
7990  AG(38)=INT(AG(36)-AG(37))
8000  IF AG(38)<0 THEN AG(38)=INT(AG(36)-AG(37)-.99)
8010  REM***************************************
8020  REM AUSGABETEXTE
8030  REM***************************************
8040  CLEARW 2:GOTOXY 0,1
8050  AG$(1)= " Se. der Einkuenfte            "
8060  AG$(2)= " -Altersentlastungsbetrag      "
8070  AG$(3)= " -Ausbildungsplatzfreibetrag   "
8080  AG$(4)= " -Freibetrag fuer Landwirte    "
8090  AG$(5)= " Gesamtbetrag der Einkuenfte   "
8100  AG$(6)= " -Gezahlte Kirchensteuer       "
8110  AG$(7)= " -Abzugsfaehige Spenden        "
8120  AG$(8)= " -Sonstige unbeschr. Sonderausg."
8130  AG$(9)= " -Pauschb. unbeschr. Sonderausg."
8140  AG$(12)= " -Sonderausgabenhoechstbetrag  "
8150  IF AG11>AG10 THEN AG$(12)=" -Vorsorgepauschale             "
8160  AG$(13)= " -Freibetr. fuer Freiberufler "
8170  AG$(14)= " -Ueberlastungsbetr. Par. 33/33c ESTG  "
8180  AG$(15)= " -Aufwand gem. Par.33a ESTG            "
8190  AG$(16)= " -Pauschbetrag fuer Koerperbehinderung "
8200  AG$(17)= " E i n k o m m e n                    "
8210  AG$(18)= " -Altersfreibetrag                    "
8220  AG$(19)= " -Haushaltsfreibetrag                 "
8230  AG$(20)= " -Kinderfreibetrag                    "
8240  AG$(21)= " -Haerteausgleich                     "
8250  AG$(22)= " zu versteuerndes Einkommen           "
8260  AG$(23)= " S t e u e r                          "
8270  AG$(24)= " -Seuererm. Erfinderverguetungen      "
8280  AG$(25)= " -Steuererm. aus Parteispenden        "
8290  AG$(26)= " -Steuerm. BerlinFG/VermBG            "
8300  AG$(27)= " -Steuererm. 34f/7b ESTG              "
8310  AG$(28)= " Festzusetzende  S t e u e r          "
8320  AG$(29)= " -Einbehaltene Lohnsteuer             "
8330  AG$(30)= " -Einbehaltene Kapitalertragsteuer    "
8340  AG$(31)= " -Anzurechnende Koerperschaftsteuer   "
8350  AG$(32)= " Verbleibende  S t e u e r s c h u l d"
8360  AG$(33)= " ev. Kirchensteuer                    "
8370  AG$(34)= " -Einbehaltene ev. Kirchensteuer      "
8380  AG$(35)= " Verbleibende ev. Kirchensteuer       "
8390  AG$(36)= " rk. Kirchensteuer                    "
8400  AG$(37)= " -Einbehaltene rk. Kirchensteuer      "
8410  AG$(38)= " Verbleibende rk. Kirchensteuer       "
8420  IF HH=2 AND AG(32)<0 THEN AG$(32)=" Erstattungsbetrag LST              "
8430  IF HH=2 AND AG(32)>0 THEN AG$(32)=" Nachforderung                  "
8440  REM**************************************************
8450  estdruck:
8460  REM**************************************************
8470  IF HH=1 THEN ? "          Einkommensteuerberechnung";VZ
8480  IF HH=2 THEN ? "          Lohnsteuerjahresausgleich";VZ
8490  ?
8500  I=0
8510  FOR I = 1 TO 3
8520  IF EK(I) <>0 OR EK(I+10)<>0 THEN ? EK$(I),EK(I),EK(I+10)
8530  NEXT I
8540  IF EN1>0 OR EY1>0 THEN ?:? " Brutto-Lohn                ",EN1,EY1
8550  IF EN2>0 OR EY2>0 THEN ? " Versorgungsbezuege         ",EN2,EY2
8560  IF W2>0 OR W3>0 THEN   ? " -Versorgungsfreibetrag      ",W2,W3
8570  IF V2>0 OR V22>0  THEN   ? " -Weihnachts-Freibetrag      ",V2,V22
8580  IF V3>0 OR VA>0 THEN   ? " -Arbeitnehmerfreibetrag     ",V3,VA
8590  IF WK>0 OR WKY>0 THEN  ? " -Werbungskosten             ",WK,WKY
8600  IF EN1>0 OR EY1>0 THEN ? " Nichtselbst. Einkuenfte    ",EK(4),EK(14)
8610  IF EN1>0 OR EY1>0 THEN ?
8620  FOR I=5 TO 7
8630  IF EK(I)<>0 OR EK(I+10) <>0 THEN ? EK$(I),EK(I),EK(I+10)
8640  NEXT I:I=0
8650  ?:
8660  ? " SUMME                      ",SDE1,SDE2
8670  WARTE = INP(2)
8680  FOR I = 1 TO 23
8690  IF AG(I)<>0 THEN ? AG$(I),AG(I)
8700  IF I=7 THEN WARTE = INP(2)
8710  IF I=14 THEN WARTE = INP(2)
8720  NEXT I
8730  IF AG(23)=0 THEN ? AG$(23)," 0 "
8740  ?:
8750  FOR I=24 TO 28
8760  IF AG(I)<>0 THEN ? AG$(I),AG(I)
8770  NEXT I
8780  IF AG(23)<>0 AND AG(28)=0 THEN ? AG$(28)," 0 "
8790  ?:
8800  WARTE=INP(2)
8810  FOR I=29 TO 32
8820  IF AG(I)<>0 THEN ? AG$(I),AG(I)
8830  NEXT I
8840  IF AG(28)<>0 AND AG(32)=0 THEN ? AG$(32)," 0 "
8850  ?:
8860  WARTE=INP(2)
8870  FOR I=33 TO 38
8880  IF AG(I)<>0 THEN ? AG$(I),AG(I)
8890  NEXT I
8900  ?
8910  INPUT " Erlaeuterungen und Kontrollwerte = J ";ERL$
8920  IF ERL$="J" OR ERL$="j" THEN GOSUB erlaeuterungen
8930  WARTE =INP(2)
8940  ?:?
8950  INPUT " Ausdrucken der Berechnung  = J ";DRUCK$
8960  IF DRUCK$="J" OR DRUCK$="j" THEN GOTO drucker
8970  GOTO ENDE
8980  REM**************************************
8990  erlaeuterungen:
9000  REM**************************************
9010  CLEARW 2:GOTOXY 0,1
9020  ?"         Erlaeuterungen und Kontrollwerte"
9030  ?:
9040  IF H=1 THEN ? " Tabelle = Grundtabelle "
9050  IF H=2 THEN ? " Tabelle = Splittingtabelle"
9060  ? " Kinder = ";KX
9070  ? " Zahlkinder = ";KX2
9080  ? " Geburtsdatum = ";GBD1$;" ";GBD2$
9090  ERL1=1: IF H<>0 OR F<>0 THEN GOSUB erl2
9100  IF AGB1>0 OR AGB5>0 THEN ? " Zumutb. Eigenbel.=";AGB7;"%v.";AG(5);"=";ZBE
9110  RETURN
9120  REM*****************************************
9130  REM EINKOMMENSTERTABELLEN 1982 - 1988
9140  REM*****************************************
9150  FULLW 2
9160  X=INT(X/D)*D:IF H=2 THEN X=.5*X
9170  IF X<M THEN S=.22*X-J:GOTO 9900
9180  IF VZ>85 THEN GOTO 9210
9190  IF X<N THEN Y=(X-M+1)/Q:GOTO 9820
9200  IF X<O THEN Z =(X-N)/Q:GOTO 9860
9210  IF X<N THEN Y=(X-18000)/Q:GOTO 9820
9220  IF X<O THEN Z=(X-80000)/Q:GOTO 9860
9230  S=.56*X-P: GOTO 9900
9240  X=INT(X/D)*D:RETURN
9250  C=(T-INT(.01*C))/(.01*D)
9260  RETURN
9270  X=X-D:GOSUB 9160:C=A:IF F<>0 THEN C=INT(100*Q*C)/(100*Q)
9280  RETURN
9290  REM***************************************************
9300  tabelle:
9310  IF PK1>0 THEN GOTO sprung1
9320  CLEAR:CLEARW 2:GOTOXY 0,1
9330  ? "             EINKOMMENSTEUERTABELLEN 1982 - 1988":?:?
9340  INPUT "  Veranlagungszeitraum 19",VZ
9350  IF VZ<81 THEN GOTO 9340
9360  ?:INPUT "  Zu versteuerndes Einkommen = DM ";E:?
9370  ? "  Grundtabelle          =1"
9380  INPUT "  Splittingtabelle     = 2     Eingabe = ";H
9390  IF H <1 OR H >2 GOTO 9380
9400  ?:?
9410  ?"  Einkuenfte,die wegen des Progressionsvorbehalts gem. Par:32b ESTG"
9420  ?"  bei der Errechnung der Steuer beruecksichtigt "
9430  INPUT "  werden muessen  (ggf.=0)      = DM ";F
9440  ?
9450  ?"  Einkuenfte mit ermaessigtem Steuersatz gem Par. 34(1),"
9460  ?"  die im zu versteuernden Einkommen enthalten sind"
9470  ?"  z. B. Stpfl. Anteil an Veraesserungsgewinnen"
9480  INPUT"                   usw.     (ggf = 0)         = DM ";G
9490  ?
9500  REM****************************************************
9510  sprung1:
9520  D=54:Q=10000:R=1000:P=0
9530  IF H=2 THEN D=2*D
9540  IF VZ<86 THEN M=18001:N=6*Q:O=13*Q:J=926:P=14837:GOTO 9580
9550  IF VZ>85 THEN M=18036:N=80028:O=130032:J=998:P=16433
9560  IF VZ<88 THEN GOTO 9580
9570  IF VZ>87 THEN P= 18502
9580  IF E<D+2 THEN K=E:GOTO 9950
9590  REM****************************************************
9600  C=J/.22:IF H=2 THEN C=2*C
9610  C=C+D-2:IF (E+F)<C THEN K=E:C=0:GOTO 9950
9620  REM****************************************************
9630  X=E+F:GOSUB 9160:T=S:V=A:K=E
9640  W=INT(100*A)/200:GOSUB 9270
9650  Z=C:GOSUB 9250:IF F=0 AND G=0 GOTO 9950
9660  REM****************************************************
9670  IF G>0 GOTO 9700
9680  X=E:GOSUB 9240:V=INT(100*Q*V)/(100*Q)
9690  T=INT(.01*V*X):C=Z:X=X-D:GOSUB 9250:GOTO 9950
9700  X=E+F-G:GOSUB 9160:V=A
9710  IF F<>0 THEN V=INT(100*Q*V)/(100*Q)
9720  IF (E-G)<1 THEN V=0:C=0:GOTO 9750
9730  GOSUB 9270
9740  REM********************************************
9750  X=E-G:GOSUB 9240
9760  K=X+D-1:L=E-K
9770  IF L<1 THEN L=1:K=E-1:X=INT((E-1)/D)*D
9780  REM********************************************
9790  U=INT(.01*L*W):T=INT(.01*X*V)
9800  IF F<>0 THEN T=INT(.01*X*V)
9810  X=X-D:GOSUB 9250:GOTO 9950
9820  IF VZ<86 THEN S=(((3.05*Y-73.76)*Y+695)*Y+2200)*Y+3034:GOTO 9900
9830  IF VZ>85 AND VZ<88 THEN S=(((2.10*Y-56.02)*Y+600)*Y+2200)*Y+2962:GOTO 9900
9840  IF VZ>87 THEN S=(((.79*Y-30.82)*Y+452)*Y+2200)*Y+2962:GOTO 9900
9850  REM********************************************
9860  IF VZ<86 THEN S=(((.09*Z-5.45)*Z+88.13)*Z+5040)*Z+20018:GOTO 9900
9870  IF VZ>85 AND VZ<88 THEN S=(42*Z+5180)*Z+29417:GOTO 9900
9880  IF VZ>87 THEN S=(60*Z+5000)*Z+27798
9890  REM********************************************
9900  IF S<1 THEN S=0:A=0:GOTO 9930
9910  S=INT(S):IF H=2 THEN S=2*S:X=2*X
9920  A=100*S/X
9930  RETURN
9940  REM*******************************************
9950  IF PK1>0 THEN RETURN
9960  ?
9970  erl2:
9980  ?" Steuer lt. Tabelle          = ";T
9990  IF G=0 GOTO 10060
10000 ?" Halbe Steuer                = ";U
10010 ?" Steuerschuld                = ";T+U
10020 ?
10030 ?" Halber Steuersatz           = ";W
10040 ?" Gerundete erm. Einkuenfte   = ";L
10050 ?" Tabelle bei Stufe           = ";K
10060 ? " Durchschnittssteuersatz     = ";V
10070 IF ERL1=1 THEN RETURN
10080 warte = inp(2):end
10090 REM************************************
10100 drucker:
10110 REM************************************
10120 IF HH=1 THEN LPRINT "           Einkommensteuerberechnung";VZ
10130 IF HH=2 THEN LPRINT "           Lohnsteuerjahresausgleich";VZ
10140 LPRINT:LPRINT
10150 I=0
10160 FOR I = 1 TO 3
10170 IF EK(I)<>0 OR EK(I+10)<>0 THEN LPRINT EK$(I),EK(I),EK(I+10)
10180 NEXT I
10190 LPRINT
10200 IF EN1>0 OR EY1>0 THEN LPRINT " Brutto-Lohn                  ",EN1,EY1
10210 IF EN2>0 OR EY2>0 THEN LPRINT " Versorgungsbezuege           ",EN2,EY2
10220 IF W2>0 OR W3>0 THEN LPRINT " -Versorgungsfreibetrag        ",W2,W3
10230 IF V2>0 OR V22>0 THEN LPRINT " -Weihnachts-Freibetrag        ",V2,V22
10240 IF V3>0 OR VA>0 THEN LPRINT " -Arbeitnehmerfreibetrag       ",V3,VA
10250 IF WK>0 OR WKY>0 THEN LPRINT " -Werbungskosten               ",WK,WKY
10260 IF EN1>0 OR EY1>0 THEN LPRINT " Nichtselbst. Einkuenfte     ",EK(4),EK(14)
10270 IF EN1>0 OR EY1>0 THEN LPRINT
10280 FOR I=5 TO 7
10290 IF EK(I)<>0 OR EK(I+10)<>0 THEN LPRINT EK$(I),EK(I),EK(I+10)
10300 NEXT I:I=0
10310 LPRINT
10320 LPRINT " Summe                       ",SDE1,SDE2
10330 LPRINT
10340 FOR I = 1 TO 23
10350 IF AG(I)<>0 THEN LPRINT AG$(I), AG(I)
10360 NEXT I
10370 IF AG(23)=0 THEN LPRINT AG$(23)," 0 "
10380 LPRINT
10390 FOR I = 24 TO 28
10400 IF AG(I)<>0 THEN LPRINT AG$(I),AG(I)
10410 NEXT I
10420 IF AG(23)<>0 AND AG(28)=0 THEN LPRINT AG$(28)," 0 "
10430 LPRINT
10440 FOR I = 29 TO 32
10450 IF AG(I) <>0 THEN LPRINT AG$(I),AG(I)
10460 NEXT I
10470 IF AG(28)<>0 AND AG(32)=0 THEN LPRINT AG$(32)," 0 "
10480 LPRINT
10490 FOR I=33 TO 38
10500 IF AG(I) <> 0 THEN LPRINT AG$(I),AG(I)
10510 NEXT I
10520 INPUT " Ausdruck von Erlaeuterungen und Kontrollwerten = J ";ERL3$
10530 IF ERL3$="J" OR ERL3$="j" GOTO 10550
10540 GOTO ENDE
10550 LPRINT
10560 LPRINT " Erlaeuterungen und Kontrollwerte :"
10570 LPRINT
10580 IF H=1 THEN LPRINT " Grundtabelle"
10590 IF H=2 THEN LPRINT " Splittingtabelle"
10600 LPRINT " Kinder = ";KX
10610 LPRINT " Zahlkinder = ";KX2
10620 LPRINT " Personenkreis = ";PK1;PK2
10630 LPRINT " Geburtsdatum = ";GBD1$;" ";GBD2$
10640 IF H=0 AND G=0 GOTO ENDE
10650 LPRINT " Steuer lt. Tabelle = ";T
10660 IF G=0 GOTO 10720
10670 LPRINT " Halbe Steuer       = ";U
10680 LPRINT " Steuerschuld       = ";T+U
10690 LPRINT " Halber Steuersatz  = ";W
10700 LPRINT " Gerundete erm. Einkuenfte = ";L
10710 LPRINT " Tabelle bei Stufe  = ";K
10720 LPRINT " Duchschnittssteuersatz = ";V
10730 IF AGB1>0 OR AGB5>0 THEN LPRINT " Zumutb. Eigenbel.=";AGB7;"%v.";AG(5);ZBE
10740 ENDE:
10750 I=0:FOR I = 1 TO 40
10760 AG(I)=0:AG$=""
10770 NEXT I:I=0
10780 FOR I = 1 TO 20
10790 EK(I)=0
10800 NEXT I:I=0
10810 FOR I = 1 TO 10
10820 EK$(I)="":X$(I)="":ZE(I)=0:ZE1(I)=0:ZE2(I)=0
10830 NEXT I
10840 END
