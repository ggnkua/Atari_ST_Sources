10    '
20    ' *********************************************
30    ' *                                           *
40    ' *            ST-Lohnbuchhaltung             *
50    ' *             copyright 7/1984              *
60    ' *                   by                      *
70    ' *              GÅnter Stahl                 *
80    ' *      fÅr ATARI-ST umgeschrieben von       *
90    ' *      GÅnter Stahl & Angelika Schulte      *
100   '*                 04/1986                   *
110   '*                                           *
120   '*********************************************
130   '
140   closew 0:closew 1:closew 3:fullw 2:clearw 2:clear
150   gosub init:gosub fullwind:gosub cleardesk:gosub textausgabe
160   clearw 2
170   gotoxy 15,4:?"S T  -  L O H N"
180   gotoxy 13,10:?"(c) 1984 by GÅnter Stahl"
190   gotoxy  4,18:?"fuer Atari ST (c) 1986 by GÅnter Stahl & Angelika Schulte"
200   for i=1 to 7777:next i
210   clearw 2
220   gotoxy 14,0:?"S T  -  L o h n "
230   gotoxy 14,2:?"Datumeingabe"
240   gotoxy 2,6:line input"Monat (Text)     :",m$
250   gotoxy 2,8:line input"Jahr             :",j$
260   gotoxy 2,10:line input"Datum            :",dt$
270   goto menue
280   person:clearw 2
290   gotoxy 2,8:line input"Vorname Name     :",a$
300   gotoxy 2,10:line input"Strasse          :",a1$
310   gotoxy 2,12:line input"Plz Ort          :",a2$
320   gotoxy 2,14:line input"Bank             :",c$
330   gotoxy 2,16:line input"Kontonr.         :",c1$
340   gotoxy 2,18:line input"Blz.             :",c2$
350   clearw 2
360   gotoxy 8,0:?"eingabe der Personenbezogenen Lohndaten"
370   gotoxy 2,4:line input"Personalnr.        :",pn1$
380   pn1=val(pn1$)
390   gotoxy 2,6:line input"Abteilungsnr.      :",n1$
400   n1=val(n1$)
410   gotoxy 2,8:line input"Steuerklasse       :",n2$
420   n2=val(n2$)
430   gotoxy 2,10:line input"Kinderzahl         :",n3$
440   n3=val(n3$)
450   gotoxy 2,12:?"0=keine  1=ev  2=rk  3=sonst"
460   gotoxy 2,13:line input"Konfession        :",n4$
470   n4=val(n4$)
480   gotoxy 2,15:?"1=Aok 2=Bek 3=Dak 4=KKh 5=Tkk 6=Ikk"
490   gotoxy 2,16:line input"krankenvers.       :",n5$
500   n5=val(n5$)
510   goto menue
520   lohn:clearw 2
530   gotoxy 2,0:?"Eingabe der Lohndaten"
540   gotoxy 2,2:line input"Stundenlohn           :",stl$
550   stl=val(stl$)
560   gotoxy 2,4:line input"Anzahl der Stunden    :",as1$
570   as1=val(as1$)
580   gotoxy 2,6:line input"öberstunden 25%       :",ue1$
590   ue1=val(ue1$)
600   gotoxy 2,8:line input"öberstunden 50%       :",ue2$
610   ue2=val(ue2$)
620   gotoxy 2,10:line input"öberstunden 100%      :",ue3$
630   ue3=val(ue3$)
640   gotoxy 2,12:line input"öberstunden 200%      :",ue4$
650   ue4=val(ue4$)
660   gotoxy 2,14:line input"Urlaubslohn           :",ul$
670   ul=val(ul$)
680   gotoxy 2,16:line input"Urlaubsgeld           :",ug$
690   ug=val(ug$)
700   gotoxy 2,18:line input"Sonstiges             :",s$
710   s=val(s$)
720   gotoxy 20,0:?"Eingabe der AbzÅge"
730   gotoxy 20,5:line input"Lohnsteuer            :",ls$
740   ls=val(ls$):ls=(int(ls*100)/100)
750   gotoxy 20,7:line input"Pers.AbzÅge          :",pa$
760   pa=val(pa$):if pa <= 0 then pa=0
770   goto menue
780   berechnung:clearw 2
790   v=52:v=v+0.0001
800   lo=stl*as1
810   ustd1=(ue1*((stl/100)*25))
820   ustd2=(ue2*((stl/100)*50))
830   ustd3=(ue3*((stl/100)*100))
840   ustd4=(ue4*((stl/100)*200))
850   ustd=ustd1+ustd2+ustd3+ustd4:ustd=ustd+0.0001
860   ustd=(int(ustd*100)/100)
870   br=(lo+ustd+ul+ug+s+v):br=br+0.0001
880   on n5 gosub 2470,2480,2490,2500,2510,2520
890   ks=0:if n4=0 then goto 910
900   ks=(ls*8)/100:ks=(int(ks*100)/100)
910   av=((br*1.998)/100):av=(int(av*100)/100):ks=ks+0.0001
920   rv=((br/100)*9.59):rv=(int(rv*100)/100)
930   a=(ls+ks+kv+rv+av):rem abzuege
940   a1=(a+pa):rem gesamtabzuege
950   nv=(br-a):rem netto
960   az=(nv-pa):rem auszahlungsbetrag
970   az=az+0.0001:pa=pa+0.0001:n2$=str$(n2)
980   if n4=0 then rel$=" - "
990   if n4=1 then rel$="ev"
1000  if n4=2 then rel$="rk"
1010  if n4=3 then rel$="so"
1020  if n5=1 then kk$="Aok"
1030  if n5=2 then kk$="Bek"
1040  if n5=3 then kk$="Dak"
1050  if n5=4 then kk$="Kkh"
1060  if n5=5 then kk$="Tkk"
1070  if n5=6 then kk$="Ikk"
1080  ls=ls+0.0001:ustd=ustd+0.0001:lo=lo+0.0001:kv=kv+0.0001
1090  rv=rv+0.0001:av=av+0.0001
1100  return
1110  monitor:clearw 2
1120  gosub berechnung
1130  rem'gotoxy 13,0:?"S T  -  L o h n"
1140  gotoxy 13,0:?"Lohn- und Gehaltsabrechnung"
1150  gotoxy 0,1:?"Name              Stkl./Rel./Vers.        Datum   "
1160  gotoxy 0,2:print a$;tab(21);n2$;"   ";rel$;"   ";kk$;tab(43);m$;" ";j$
1170  gotoxy 15,3:print"DM";tab(18);"DM"
1180  gotoxy 1,4:print using"Grundgehalt             :#####.##";lo
1190  gotoxy 1,5:print using"öberstunden             :#####.##";ustd
1200  gotoxy 1,6:print using"Verm.W.Anlage           :#####.##";v
1210  gotoxy 1,7:print"Steuerbrutto             ";
1220  gotoxy 21,7:print using"#####.##";br
1230  gotoxy 1,8:print"Brutto                   ";
1240  gotoxy 21,8:print using"#####.##";br
1250  gotoxy 1,9:?"------------------------------------------------------------"
1260  gotoxy 1,10:print using"Lohnsteuer              :#####.##";ls
1270  gotoxy 1,11:print using"Kirchensteuer           :#####.##";ks
1280  gotoxy 1,12:print using"Krankenversicherung     :#####.##";kv
1290  gotoxy 1,13:print using"Rentenversicherung      :#####.##";rv
1300  gotoxy 1,14:print using"Arbeitsl.Vers.          :#####.##";av
1310  gotoxy 1,15:print using"Sonstige Abzuege        :#####.##";pa
1320  gotoxy 21,16:print using"#####.##";a1
1330  gotoxy 1,17:?"-----------------------------------------------------------"
1340  gotoxy 1,18:print "Auszahlungsbetrag";
1350  gotoxy 21,18:print using"#####.##";az
1360  sound 1,29,125,125,0:sound 1,0,0,0,0
1370  ta=inp(2)
1380  goto menue
1390  ende:end
1400  druck:clearw 2
1410  gosub berechnung:gosub druckprogramm
1420  goto menue
1430  personles:clearw 2:gotoxy 1,6:
1440  line input"Welche Personendatei wollen Sie einlesen ? :";ple$
1445  if ple$="" then goto 1440:resume 1440
1450  on error goto 1640
1460  open "I",#1,ple$:on error goto 1630 :resume 1630
1470  if eof(1) then close :goto menue
1480  input #1,a$                        
1490  input #1,a1$
1500  input #1,a2$
1510  input #1,c$
1520  input #1,c1$
1530  input #1,c2$
1540  input #1,pn1
1550  input #1,n1                     
1560  input #1,n2
1570  input #1,n3
1580  input #1,n4
1590  input #1,n5
1600  '
1610  '
1620  goto 1470
1630  close
1640  goto menue
1650  lohnles:clearw 2:gotoxy 1,6:
1660  line input"Welche Lohndatei wollen Sie einlesen ? :";lle$
1665  if lle$="" then goto 1660 :resume 1660
1670  on error goto 1640:open "I",#2,lle$:on error goto 1630 :resume 1630
1680  if eof(2) then close  :goto menue
1690  input #2,stl                               
1700  input #2,as1
1710  input #2,ul
1720  input #2,ug
1730  input #2,s
1740  input #2,v
1750  input #2,ue1
1760  input #2,ue2
1770  input #2,ue3
1780  input #2,ue4
1790  input #2,ls          
1800  input #2,pa
1810  '
1820  '
1830  goto 1680
1840  goto menue
1850  personspeich:clearw 2:gotoxy 1,6:
1860  line input"Welche Personendatei wollen Sie Speichern ? :";psp$
1870  open "O",#1,psp$
1880  print #1,a$                         
1890  print #1,a1$
1900  print #1,a2$
1910  print #1,c$
1920  print #1,c1$
1930  print #1,c2$
1940  print #1,pn1
1950  print #1,n1             
1960  print #1,n2
1970  print #1,n3
1980  print #1,n4
1990  print #1,n5
2000  close
2010  goto menue
2020  lohnspeich:clearw 2:gotoxy 1,6:
2030  line input"Welche Lohndatei wollen Sie Speichern ? :";lsp$
2040  open "O",#2,lsp$
2050  print #2,stl                               
2060  print #2,as1
2070  print #2,ul
2080  print #2,ug
2090  print #2,s
2100  print #2,v
2110  print #2,ue1
2120  print #2,ue2
2130  print #2,ue3
2140  print #2,ue4
2150  print #2,ls          
2160  print #2,pa
2170  '
2180  '
2190  close
2200  goto menue
2210  menue:clearw 2:close
2220  gotoxy 13,0:?"S T  -  L o h n"
2230  gotoxy 10,2:?"1.) Eingabe der Personendaten"
2240  gotoxy 10,4:?"2.) Eingabe der Lohndaten"
2250  gotoxy 10,6:?"3.) Einlesen der Personendaten"
2260  gotoxy 10,8:?"4.) Einlesen der Lohndaten"
2270  gotoxy 10,10:?"5.) Speichern der Personendaten"
2280  gotoxy 10,12:?"6.) Speichern der Lohndaten"
2290  gotoxy 10,14:?"7.) Ausgabe auf Monitor"
2300  gotoxy 10,16:?"8.) Ausgabe auf Drucker"
2310  gotoxy 10,18:?"9.) Programmende"
2320  '
2330  sound 1,29,125,125,0:sound 1,0,0,0,0
2340  ta=inp(2)
2350  if ta< 49 or ta> 57 then goto 2340
2360  if ta=49 then goto person
2370  if ta=50 then goto lohn
2380  if ta=51 then goto personles
2390  if ta=52 then goto lohnles
2400  if ta=53 then goto personspeich
2410  if ta=54 then goto lohnspeich
2420  if ta=55 then goto monitor
2430  if ta=56 then goto druck
2440  if ta=57 then goto ende
2450  goto 2340
2460  'berechnung der krankenkassenbeitraege
2470  kv=((br/100)*6.2435):goto 2530:rem aok
2480  kv=((br/100)*7):goto 2530:rem bek?
2490  kv=((br/100)*7):goto 2530:rem dak?
2500  kv=((br/100)*7):goto 2530:rem kkh?
2510  kv=((br/100)*7):goto 2530:rem tkk?
2520  kv=((br/100)*7):goto 2530:rem ikk?
2530  kv=(int(kv*100)/100)
2540  return
2550  druckprogramm:
2560  lprint chr$(27);"R";chr$(2);chr$(27);"E";chr$(27);chr$(56);
2570  lprint chr$(14);
2580  lprint tab(4);"Lohnabrechnung";chr$(15);tab(40);" Monat ";tab(50);"Jahr "
2590  lprint :lprint tab(14);a$;tab(54);m$;tab(66);j$
2600  lprint:gosub linie
2610  lprint tab(4);"Personal  Datum             Abtnr.    St.     Kinder    Rel.      Vers."
2620  lprint tab(4);"  Nr.                                 Kl.      zahl"
2630  gosub linie
2640  lprint tab(4);pn1;tab(14);dt$;tab(32);n1;tab(42);n2;tab(50);n3;tab(60);n4;tab(70);n5
2650  gosub linie
2660  lprint
2670  lprint tab(36);"Stunden";tab(48);Stundenlohn";tab(63);"Brutto-Betrag"
2680  lprint
2690  lprint using"   Arbeitslohn                   #####.##    #####.##         #####.##";as1,stl,lo
2700  lprint using"   öberstunden                   #####.##    #####.##         #####.##";ue,stl,ustd
2710  lprint using"   Verm.W.Anlage                                              #####.##";v
2720  lprint using"   Urlaubslohn                                                #####.##";ul
2730  lprint using"   Urlaubsgeld                                                #####.##";ug
2740  lprint using"   Sonstiges                                                  #####.##";s
2750  lprint:gosub linie
2760  lprint tab(62);"Gesamt-Brutto":lprint
2770  lprint using"                                                        DM    ####.##";br
2780  lprint:gosub linie
2790  lprint tab(4);"Steuer    Lohn      Kirchen Kranken Renten  Arbeits        Gesetzl.Abzuege"
2800  lprint tab(4);"Brutto   Steuer     Steuer   vers.   vers.  l.vers."
2810  lprint
2820  lprint using"    ####.##   ###.##    ###.##   ###.##  ###.##  ###.##   DM #####.##";br;ls;ks;kv;rv;av;a
2830  lprint:gosub linie
2840  lprint tab(62);"Netto-Verdienst"
2850  lprint 
2860  lprint using"                                                         DM   #####.##";nv
2870  lprint
2880  lprint tab(40);"----------------------------------------"
2890  lprint tab(10);a$;tab(44);"Netto - Abzuege"
2900  lprint
2910  lprint using"                                   Persoenliche Abzuege  DM   #####.##";pa
2920  lprint tab(10);a1$
2930  lprint
2940  lprint
2950  lprint tab(10);a2$
2960  lprint
2970  lprint
2980  lprint
2990  lprint
3000  lprint
3010  gosub linie
3020  lprint tab(60);"Auszahlungsbetrag"
3030  lprint
3040  lprint using"                                                              #####.##";az
3050  lprint tab(59);"=============="
3060  lprint
3070  gosub linie
3080  lprint tab(4);"Kontonr.";tab(30);"Bank";tab(60);"Blz"
3090  lprint
3100  lprint tab(4);c1$;tab(30);c$;tab(60);c2$
3110  lprint
3120  gosub linie
3130  lprint
3140  lprint
3150  lprint
3160  lprint
3170  goto menue
3180  linie:
3190  for i=1 to 80:lprint"-";:next i:return
3200  a=inp(2):stop
3210  fullwind:
3220  poke gintin,3
3230  poke gintin+2,5
3240  poke gintin+4,-1
3250  poke gintin+6,0
3260  poke gintin+8,660
3270  poke gintin+10,419
3280  gemsys 105
3290  return
3300  cleardesk:
3310  color 1,0,1 :
3320  xpos1=-1: xpos2=638:ypos1=-40:ypos2=-20
3330  gosub rechteck:color 1,1,1
3340  return
3350  init:
3360  aes#=gb
3370  control = peek(aes#)
3380  global  = peek(aes#+4)
3390  gintin  = peek(aes#+8)
3400  gintout = peek(aes#+12)
3410  addrin  = peek(aes#+16)
3420  addrout = peek(aes#+20)
3430  return
3440  rechteck:
3450  poke contrl   ,11
3460  poke contrl+2 ,2
3470  poke contrl+6 ,0
3480  poke contrl+10,1
3490  poke ptsin  ,xpos1 +1
3500  poke ptsin+2,ypos1 +38
3510  poke ptsin+4,xpos2 +1
3520  poke ptsin+6,ypos2 +38
3530  vdisys
3540  return
3550  textausgabe:width 80:clearw 2
3560  text$="ST-Lohnbuchhaltung (c) 7/84 by GÅnter Stahl"
3570  xpos3=125: ypos3=-25
3580  '
3590  for i=0 to len(text$)-1
3600  poke intin+i*2,asc(mid$(text$,i+1,1))
3610  next
3620  poke intin+i*2,0
3630  poke contrl,8
3640  poke contrl+2,1
3650  poke contrl+6,len(text$)+1
3660  poke ptsin , xpos3+1
3670  poke ptsin+2,ypos3+38
3680  vdisys
3690  return
