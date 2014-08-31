10    REM lineare Regression
20    CLEAR:GOSUB 410:REM Initialisierung
30    WHILE:REM HauptmenÅ
40      CLS:USING:USING$:PRINT cur_off$
50      PRINT '      ' rev_on$ ' lineare Regression ' rev_off$
60      PRINT '            V. 1.00'
70      PRINT '     ' CHR$($BD)' J.Starzynski 1990/93'
80      PRINT:PRINT:PRINT
90      PRINT '  ' rev_on$ 'R' rev_off$ 'egressionsart: ';art$(m)
100     PRINT '  ' rev_on$ 'E' rev_off$ 'ingabe der Werte: ';z;'Werte'
110     PRINT '  ' rev_on$ 'S' rev_off$ 'ichern der Werte'
120     PRINT '  ' rev_on$ 'L' rev_off$ 'esen der Werte'
130     PRINT '  ' rev_on$ 'W' rev_off$ 'ertebereich: ',anfw+1,'- ',endw
140     PRINT '  ' rev_on$ 'A' rev_off$ 'usgeben der Ergebnisse'
150     PRINT '  ' rev_on$ 'D' rev_off$ 'ateiausgabe der Ergebnisse'
160     PRINT '  ' rev_on$ 'K' rev_off$ 'orrektur'
170     PRINT '  ' rev_on$ 'U' rev_off$ 'nterprogramm, Zeile: ',rechen
180     PRINT '  ' rev_on$ 'P' rev_off$ 'lot'
190     PRINT '  ' rev_on$ 'Q' rev_off$ 'uit'
200     PRINT cur_on$
210     PRINT 'Ihre Wahl: ';:GOSUB transform
220     WHILE:answer$=INKEY$:WEND answer$<>''
230     PRINT answer$
240     IF answer$='r' OR answer$='R' THEN GOSUB 540
250     IF answer$='e' OR answer$='E' THEN GOSUB 610
260     IF answer$='s' OR answer$='S' THEN GOSUB 1100
270     IF answer$='l' OR answer$='L' THEN GOSUB 840
280     IF answer$='w' OR answer$='W' THEN GOSUB 2260
290     IF answer$='a' OR answer$='A' THEN GOSUB 1550:GOSUB 1790
300     IF answer$='d' OR answer$='D' THEN GOSUB 940
310     IF answer$='u' OR answer$='U' THEN GOSUB 1330
320     IF answer$='k' OR answer$='K' THEN GOSUB 1150
330     IF answer$='p' OR answer$='P' THEN GOSUB 2070
340     IF answer$<>'q' AND answer$<>'Q' THEN 380
350     PRINT:PRINT 'Wirklich Schluû? ' rev_on$ 'Y' rev_off$ '/N ';
360     WHILE:answer$=INKEY$:WEND answer$<>''
370     IF answer$<>'n' AND answer$<>'N' THEN CLS:END
380   WEND:REM HauptmenÅ
390   REM
400   REM Initialisierungen
410   CLS:FCLOSE
420   listval=LABEL 1030:waitk=LABEL 580:transform=LABEL 1900
430   esc$=CHR$(27):cur_off$=esc$+'f':cur_on$=esc$+'e'
440   rev_off$=esc$+'q':rev_on$=esc$+'p'
450   maxanz=100:INPUT 'max. Wertezahl (100): ';maxanz_$
460   IF maxanz_$<>'' THEN maxanz=VAL(maxanz_$)
470   DIM xw(maxanz-1):DIM yw(maxanz-1)
480   DIM xwt(maxanz-1):DIM ywt(maxanz-1)
490   DIM art$(2):art$(0)='Y=a*X+b':art$(1)='Y=a*X mittl.'
500   art$(2)='Y=a*X beste'
510   RETURN
520   REM
530   REM Umschalten der Regressionsart
540   m=m+1:IF m>2 THEN m=0
550   RETURN
560   REM
570   REM waitk: warten auf Tastendruck
580   PRINT cur_off$:PRINT '  Bitte eine Taste drÅcken!';
590   WHILE:WEND INKEY$<>'':PRINT cur_on$:RETURN
600   REM
610   REM die Eingabe-Routine
620   CLS:PRINT:PRINT '  Werte-Eingabe':PRINT:PRINT '  Ende mit Q, Korrektur mit K':PRINT
630   USING 0,1:oldz=z
640   WHILE z<maxanz:REM Werteeingabe
650     PRINT 'X';z+1;
660     INPUT ': ';aa$:IF aa$='' THEN 650
670     l$=MID$(aa$,1,1)
680     IF l$='q' OR l$='Q' OR l$='e' OR l$='E' THEN 800
690     IF l$<>'k' AND l$<>'K' THEN 720
700     IF z>0 THEN z=z-1
710     GOTO 650
720     PRINT 'Y';z+1;
730     INPUT ': ';ba$:IF ba$='' THEN 720
740     l$=MID$(ba$,1,1)
750     IF l$='q' OR l$='Q' OR l$='e' OR l$='E' THEN 800
760     IF l$='k' OR l$='K' THEN 650
770     a=VAL aa$:b=VAL ba$:xw(z)=a:yw(z)=b
780     z=z+1
790   WEND:REM Werteeingabe
800   IF oldz=endw THEN endw=z
810   changed=1:RETURN
820   REM
830   REM Maschinelles Einlesen der Werte
840   file$=FSEL$ '*.TXT'
850   IF file$='' THEN RETURN
860   CLS:PRINT 'Lese Datei':PRINT file$:FOPEN file$
870   FOR z=0 TO maxanz-1
880     FINPUT a,b:xw(z)=a:yw(z)=b
890     IF ERRNO<>0 THEN 910
900   NEXT z
910   FCLOSE:anfw=0:endw=z:changed=1:RETURN
920   REM
930   REM die Dateiausgabe
940   file$=FSEL$ '*.TXT':IF file$='' THEN RETURN
950   PRINT 'Ausgabe der Ergebnisse in die Datei':PRINT file$
960   fileflag=1:FOPEN file$
970   FPRINT:FPRINT '    x           y'
980   anfang=anfw:outanz=endw-1:GOSUB listval
990   GOSUB 1550:GOSUB 1790
1000  fileflag=0:FCLOSE:RETURN
1010  REM
1020  REM die Ausgabe der Werte
1030  CLS:USING 6,12:FPRINT
1040  FOR i=anfang TO outanz
1050    IF i<z THEN FPRINT xw(i),yw(i)
1060  NEXT i
1070  RETURN
1080  REM
1090  REM sichern der Werte in Datei
1100  CLS:file$=FSEL$ '*.TXT':IF file$='' THEN RETURN
1110  PRINT 'Sichern in Datei':PRINT file$:FOPEN file$
1120  anfang=0:outanz=z-1:GOSUB listval:FCLOSE:RETURN
1130  REM
1140  REM korrektur der Werte
1150  CLS:USING$:changed=0
1160  FOR j=0 TO z-1
1170    USING:PRINT j+1,': ',:USING 6,10:PRINT xw(j),yw(j):USING
1180    IF(j+1)MOD 15<>0 AND j+1<>z THEN 1300
1190    PRINT cur_off$,rev_on$ 'Q' rev_off$ 'uit ' rev_on$ 'K' rev_off$ 'orrektur oder mehr'
1200    WHILE:wait$=INKEY$:WEND wait$<>''
1210    IF wait$='q' OR wait$='Q' THEN 1310
1220    IF wait$<>'k' AND wait$<>'K' THEN 1290
1230    WHILE
1240      PRINT cur_on$:INPUT 'Welchen Wert korrigieren: ';k
1250    WEND k<=z AND k>0
1260    k=k-1:INPUT 'x: ';a;'y: ';b:xw(k)=a:yw(k)=b
1270    changed=1
1280    j=j-16:IF j<-1 THEN j=-1
1290    CLS
1300  NEXT j
1310  PRINT cur_on$:RETURN
1320  REM
1330  CLS:PRINT:PRINT '  In welchem Unterprogramm soll'
1340  PRINT '  transformiert werden?'
1350  PRINT:PRINT '  jetzt Zeile: ',rechen:PRINT
1360  INPUT '  Zeile: ' rechen
1370  changed=1:RETURN
1380  REM
1390  REM Unterprogramm
1400  z=z-2:GOSUB 1430:z=z+2:RETURN
1410  REM
1420  REM Unterprogramm
1430  IF z<31 THEN c=z:GOTO 1470
1440  RESTORE 1450
1450  DATA 40,50,60,80,100,200,500,1000
1460  FOR c=30 TO 37:READ a:IF z>a THEN NEXT c
1470  RESTORE 1480
1480  DATA 12.706,4.303,3.182,2.776,2.571,2.447,2.365,2.306,2.262,2.228
1490  DATA 2.201,2.179,2.16,2.145,2.131,2.12,2.11,2.101,2.093,2.086
1500  DATA 2.08,2.074,2.069,2.064,2.06,2.056,2.048,2.045,2.042
1510  DATA 2.021,2.009,2,1.99,1.984,1.972,1.965,1.96
1520  FOR a=1 TO c:READ d:NEXT a:RETURN
1530  REM 
1540  REM der Rechen- und Ausgabeteil
1550  u=0:v=0:w=0:x=0:y=0:num=endw-anfw
1560  FOR i=anfw TO endw-1
1570    a=xwt(i):b=ywt(i)
1580    IF m=1 THEN a=b/a
1590    u=u+SQU b:v=v+b:w=w+a*b:x=x+SQU a:y=y+a
1600  NEXT i
1610  b=0
1620  ON m GOTO 1690,1720
1630  GOSUB 1400
1640  a=(num*w-y*v)/(num*x-SQU y):b=(v-a*y)/num
1650  c=x-SQU y/num:c=SQRT((u-SQU v/num-SQU a*c)/c/(num-2))*d:d=c*SQRT(x/num)
1660  f=0:IF d<>0 THEN f=ABS(d/b*100)
1670  GOTO 1750
1680  REM m=1
1690  GOSUB 1430:a=y/num:c=SQRT((x-SQU y/num)/(SQU num-num))*d
1700  GOTO 1750
1710  REM m=2
1720  GOSUB 1400:a=w/x
1730  c=y/x*SQRT(u-SQU w/x)/(num-2)*d
1740  REM
1750  e=0:IF c<>0 THEN e=ABS(c/a*100)
1760  RETURN
1770  REM
1780  REM Ausgabe der Regressionsergebnisse
1790  CLS:FPRINT:FPRINT '  Regressionsart: ',art$(m):FPRINT
1800  FPRINT '  a=    ';a
1810  IF m=0 THEN FPRINT '  b=    ';b
1820  FPRINT '  Sa=   ';c
1830  IF m=0 THEN FPRINT '  Sb=   ';d
1840  FPRINT '  Sa/a= ';e;'%'
1850  IF m=0 THEN FPRINT '  Sb/b= ';f;'%'
1860  IF m<>1 THEN FPRINT '  r=    ';(num*w-y*v)/SQRT((num*x-SQU y)*(num*u-SQU v))
1870  IF fileflag=0 THEN GOTO waitk ELSE RETURN
1880  REM
1890  REM transformiere, ermittle Maximum und Minimum in x und y
1900  IF changed=0 THEN RETURN
1910  maxx=anfw:minx=anfw:maxy=anfw:miny=anfw
1920  a=xw(anfw):b=yw(anfw)
1930  IF rechen<>0 THEN GOSUB rechen
1940  xwt(anfw)=a:ywt(anfw)=b
1950  maxxv=a:minxv=a:maxyv=b:minyv=b
1960  FOR i=anfw+1 TO endw-1
1970    a=xw(i):b=yw(i)
1980    IF rechen<>0 THEN GOSUB rechen
1990    xwt(i)=a:ywt(i)=b
2000    IF a>maxxv THEN maxx=i:maxxv=a
2010    IF b>maxyv THEN maxy=i:maxyv=b
2020    IF a<minxv THEN minx=i:minxv=a
2030    IF b<minyv THEN miny=i:minyv=b
2040  NEXT
2050  changed=0:RETURN
2060  REM
2070  REM Plotten der Werte
2080  CLS:USING$:USING:ausg=3:g1x=255-ausg:g1y=175-ausg:GOSUB 1550
2090  IF a<0 THEN GOTOXY 0,20
2100  PRINT cur_off$,'X: ',xw(minx),'- ',xw(maxx)
2110  PRINT 'Y: ',yw(miny),'- ',yw(maxy);
2120  diffx=maxxv-minxv:diffy=maxyv-minyv
2130  IF diffx=0 OR diffy=0 THEN GOTO waitk
2140  gax=(g1x-ausg)/diffx:gay=(g1y-ausg)/diffy
2150  gbx=(ausg*maxxv-g1x*minxv)/diffx
2160  gby=(ausg*maxyv-g1y*minyv)/diffy
2170  FOR i=anfw TO endw-1:REM Punkte plotten
2180    gx=gax*xwt(i)+gbx:gy=gay*ywt(i)+gby:CIRCLE gx,gy,2
2190  NEXT
2200  REM jetzt die Regressionsgerade ausgeben
2210  y1=-a*gbx/gax+b:y2=a*(255-gbx)/gax+b
2220  y1=gay*y1+gby:y2=gay*y2+gby
2230  LINE 0,y1,255,y2
2240  WHILE:WEND INKEY$<>'':PRINT cur_on$:RETURN
2250  REM
2260  IF z<=0 THEN GOTO waitk
2270  anfw=anfw+1:CLS:USING 0,0:USING$
2280  PRINT '  Welche Werte sollen':PRINT '  berÅcksichtigt werden?':PRINT
2290  WHILE
2300    PRINT 'von ( ',anfw;')';:INPUT ': ',aa$
2310    IF aa$<>'' THEN changed=1:anfw=VAL(aa$)
2320  WEND anfw>=1 AND anfw<=z
2330  WHILE
2340    PRINT 'bis ( ',endw;')';:INPUT ': ',aa$
2350    IF aa$<>'' THEN changed=1:endw=VAL(aa$)
2360  WEND endw>=anfw AND endw<=z
2370  anfw=anfw-1:RETURN
