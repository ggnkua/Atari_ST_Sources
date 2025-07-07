100   '
110   '
120   ' **********************************************************************
130   ' **********************************************************************
140   ' ****                                                              ****
150   ' ****                   3 D - I R R G A R T E N                    ****
160   ' ****                   ------------------------                   ****
170   ' ****                                                              ****
180   ' ****   Ein Spiel fÅr Computer der Atari-ST-Serie mit S/W Monitor  ****
190   ' ****                 Geschrieben in ATARI-ST-BASIC                ****
200   ' ****    Speicherbedarf: ca. 60K ohne REMs bzw. ca.70K mit REMs    ****
210   ' ****           ProgrammlÑnge : 31520 Bytes (mit REMs)             ****
220   ' ****                                                              ****
230   ' ****                (C) 1986 by Jens Fangmeier                    ****
240   ' ****                                                              ****
250   ' ****                                         Hamburg, den 8.4.86  ****
260   ' **********************************************************************
270   ' **********************************************************************
280   '
290   '
300   defint a-u,x,y:lo2!=log(2):pi!=atn(1)*4:closew 0
310   poke contrl,123:poke intin,0:vdisys ' Hide Maus
320   a$=chr$(189)+" by Jens Fangmeier"+chr$(0):def seg=1
330   v=ptsin-21820:for i=1 to len(a$):poke i+v,asc(mid$(a$,i,1)):next i:def seg=0
340   dim srl(3,15),srr(3,15),a$(99),g(7),rx(8),ry(8),i(10),f(17),z$(15)
350   dim l(17),r(17) ' Speicher, ob Links o. Rechts eine Wand(1) ist
360   randomize peek(1124) ' Zufallsgenerator nach ZÑhler(sec.1/256 sec.) setzen
370   ' ****   Die Adressen von Zeile 370-420 beziehen sich auf die Tos-   ****
380   ' ****  Version vom 22.11.85. Bei anderen TOS-Versionen mÅssen hier  ****
390   ' ****     andere  Adressen angebeben werden (evtl. ausprobieren)    ****
400   poke 1156,512 ' Tastaturklicken aus
410   tb=3512 ' Tastaturbufferzeigeradresse
420   ta=3088 ' begin Tastaturbuffer
430   jo=3592 ' Joystick (1=hoch 2=runter 4=links 8=rechts)
440   mj=9958 ' Joystick Knopf(1=Maus links 2=Maus rechts oder Joystick)
450   ti=3640 ' Code der im Augendblick gedrÅckten Taste
460   poke systab+24,1:on error goto 3730' Gemfalg aus, siehe Basic-Handbuch
470   def fnr$(x)=right$(str$(x),log10(x)+1)'Str$ ohne Leerstell
480   for a=1 to 4:g(a)=1:next a 'Zum Anfang alle Instrument ein.
490   def fndig$(x)=chr$(16+int(x/10)-16*(x<10))+chr$(16+(x mod 10))
500   def fndig3$(x)=chr$(16+int(x/100)-16*(x<100))+                              chr$(16+int((x mod 100)/10)-16*(x<10))+chr$(16+(x mod 10))
510   'Zahlen in Siebensegementzahlen-String umwandeln
520   'a$=fndig$(x) :Wandelt eine 2 stellige Zahl um,fndig3$ in eine 3 stellige
530   for a=0 to 15:srl(0,a)=a:srr(0,a)=a:next a:t1=(peek(tb)+4)and 255
540   for a=1 to 3:for b=0 to 15:srl(a,b)=(srl(a-1,b)*2+int(srl(a-1,b)/8)and 15)     :next b,a:for a=1 to 3:for b=0 to 15:srr(4-a,b)=srl(a,b):next b,a:erase srl
550   '<< 4-Bit bit-rotierung, fÅr verschieben der WÑnde bei Verschiedenen            Blickrichtungen                                                                Format: c=srl(a,b):Zahl b rotiert um a stellen nach links
560   gosub auswahl ' Grîûen- und GerÑteauswahl
570   ' ******************** Berechnen des Irrgartens **************************
580   ' << Aufbau der Bildschirm-Maske >>
590   a=0:b=75:c=640:d=340:color 0,0,0:gosub boxa:'Lîshcen des MenÅ-Fensters
600   a=4:gosub modus'Invers-M.,damit die Kanten d. Rechtecks nicht sichtbar sind
610   a=0:color 1,1,1,4,2:gosub boxa:'Grauen Hintergrundes
620   a=1:gosub modus:color 1,1,1,0,0:a=5:gosub lstaerke
630   a=100:b=100:C=540:D=300:gosub prbox:gosub rbox'Abgerundetes Fenster
640   a=1:b=18:c=1:gosub schrift:a=125:b=150:d=3'Groûe Schrift
650   a$="BERECHNEN DES IRRGARTENS":gosub texta:a$="BITTE WARTEN":a=220:b=210
660   gosub texta:a=170:b=250:c=470:d=266:color 1,1,1,0,0:gosub boxa
670   a=0:b=0:c=1:gosub schrift:a=172
680   a$="0   10   20   30   40   50   60   70   80   90  100":b=275:gosub text
690   for a=0 to 17:f(a)=INT(95*.8^a)*2:next a:a=10:gosub sgroesse
700   ' Umrechnen der 3D-Koordinaten. f(z) gibt den Abstand vom Mittelpunkt an.        durch verkleiner des Faktor .8 wird die Sicht gestreckt,d.h jedes Wand-        Teil wirkt lÑnger. Beim Vergrîûern wird das Bild tiefer.
710   i(0)=2:i(1)=3:i(2)=0:i(3)=1 'Winkel Umkehren
720   ry(0)=-1:rx(0)=0:ry(1)=0:rx(1)=-1:ry(2)=1:rx(2)=0:ry(3)=0:rx(3)=1              :for e=4 to 7:rx(e)=rx(e-4):ry(e)=ry(e-4):i(e)=i(e-4):next e                   ' Umrechnung des Winkels [0..7] in XY-Fakoren(Eine Einheit ensrpicht 90¯)
730   color 1,1,1,2,2:a=170:b=250:c=170:d=266:gosub boxa ' Anzeigestreifen
740   a=(ly+ly)/4+5 ' MaximallÑnge eines Ganges bei einem Rechenschritt
750   for e=1 to ly+2:a$(e)=string$(lX,15):next e ' Irrgarten nur aus WÑnden
760   b=lx*ly:z=100/b:for e=1 to 15:z$(e)="":next e'Zugspeicher leeren
770   b$=chr$(15):c=1:d=1:e=1:f=1:I=-1:j=0 'Startkoordinaten
780   '<< Irrgarten-Algorithmus >>
790   m=int(rnd*4):n=m+3
800   m=m-((m and 3)=i):g=e+rx(m):h=f+ry(m):if g<1 or h<1 or g>lx or h>ly then 870
810   if asc(mid$(a$(h),g,1))<>15 then 870
820   ' Wenn durch das NachbarkÑstchen ein Weg fÅhrt, dann nÑchstes prÅfen
830   w=w+z:if w>1 then poke ptsin+4,170+(101-z*b)*3:w=0:vdisys 'Anzeigestreifen
840   a$=mid$(a$(f),e,1):mid$(a$(f),e,1)=chr$(asc(a$)-(asc(a$)and 2^(m and 3)))
850   a$=mid$(a$(h),g,1):i=i(m):mid$(a$(h),g,1)=chr$(asc(a$)-(asc(a$)and 2^i))       ' Wand bei beiden KÑstchen lîschen
860   b=b-1:f=h:e=g:j=j+1:if j>a then 880 else 790'MaximallÑnge
870   if m<n then m=m+1:goto 800'NÑchstes NachbarkÑstchen
880   j=0:if b<2 then 960' Wenn alle KÑstchen
890   d=int(rnd*ly)+1:if instr(a$(d),b$)=0 then 890 else a$=a$(d)
900   c=int(rnd*lx)+1:if c+d<3 or mid$(a$,c,1)<>b$ then 900
910   e=c:f=d:k=int(rnd*4)and 3:for m=k to k+3:g=e+rx(m):h=f+ry(m)
920   if g<1 or h<1 or g>lx or h>ly or g+h=2 then 940 'Wenn ausserhalb
930   if asc(mid$(a$(h),g,1))<>15 then swap e,g:swap f,h:m=i(m):goto 830            'Wenn durch das NachbarkÑstchen ein Weg fÅhrt,dann Abzweigug zum                Aktuellen KÑstchen einbauen
940   next m:goto 890 'NÑchstes NachbarkÑstchen prÅfen, Neues KÑstechen
950   ' < UnberÅhrtes Kastchen suchen
960   '************************ Bildaufbau ***************************************
970   ' << Irrgarten-Window >>
980   color 1,1,1,1,1:a=0:b=0:c=640:d=400:gosub boxa ' Bildschrim schwarz
990   a=0:b=0:gosub lform:a=1:gosub modus:a=10:b=9:c=392:d=391:color 1,1,1,1,2
1000  gosub boxa:a=2:gosub modus:a=7:b=6:c=395:d=394:color 1,0,0,0,0:gosub boxa
1010  a=1:gosub modus:restore 1080:for i=1 to 4:read wf(i),wm(i),wi(i):next i
1020  ' Farben und FÅllmuster der WÑnde. Hierbei gilt:
1030  ' wf(x): Farbe des Teile wm(x)=FÅllmuster (Index) wi(x)=FÅllstil (2 o.3)
1040  ' x=1: Boden
1050  ' x=2: Decke(Bei Decke und Boden gibt es mit anderen Muster Schwierigkeiten)
1060  ' x=3: Wand links u. Rechts
1070  ' x=4:Hintere Wand,Wand bei Abzweigungen
1080  data 1,6,2,1,4,2,1,2,2,1,3,2
1090  ' << WÑnde >>
1100  a=3:a(3)=201:b(3)=200:a(2)=11:b(2)=390:a(1)=391:b(1)=390
1110  color 1,wf(1),wf(1),wm(1),wi(1):gosub polygon:b(2)=10:b(1)=10
1120  color 1,wf(2),wf(2),wm(2),wi(2):gosub polygon:b(1)=390:a(1)=11
1130  color 1,wf(3),wf(3),wm(3),wi(3):gosub polygon:a(2)=391:a(1)=391
1140  gosub polygon:a=5:gosub lstaerke:e=3:if g(3)=0 then 1190
1150  ' << GedÑchnis Window >>
1160  a=405:b=340:c=636:d=390:gosub rboxb:a=4:b=18:c=2:gosub schrift
1170  a=450:b=360:a$="GedÑchnis":gosub text:a=0:b=15:c=1:gosub schrift:a=412
1180  b=380:a$="Du warst schon    mal hier!":gosub text:a$="":a=535:gosub text
1190  if g(1)=0 then 1280
1200  ' << Kompaû Window >>
1210  a=405:b=85:c=513:d=245:gosub rboxb:a=5:b=18:c=2:gosub schrift:a=409:b=110
1220  a$="Kompaû":gosub text:a=458:b=180:c=35:color 1,1,1:gosub kreis
1230  c=c-3:color 1,0,0,1,1:gosub fkreis:restore 1240:a=1:b=17:c=2:gosub schrift
1240  data O,501,174,N,453,135,W,416,184,S,462,223
1250  for i=3 to 6:a=(i mod 4)*900:gosub twinkel:read a$,a,b:gosub text
1260  if i=4 then a=0:gosub sart
1270  next i:a=0:gosub twinkel
1280  if g(2)=0 then 1330
1290  ' << Ziel-Peiler Window >>
1300  a=528:b=85:c=636:d=245:gosub rboxb:a=5:b=15:c=2:gosub schrift:color 1,1,1
1310  a=537:b=105:a$="Ziel-Peiler":gosub text:a=582:b=180
1320  c=45:gosub kreis:c=c-3:color 1,0,0,1,1:gosub fkreis
1330  if g(4)=0 then 1380
1340  ' << Positions Window >>
1350  a=405:b=10:c=636:d=65:gosub rboxb:a=5:b=18:c=2:gosub schrift
1360  a$="Position":a=455:b=30:gosub text:a=0:b=10:c=1:gosub schrift
1370  a$="x-Achse : "+fndig$(lx)+" y-Achse : "+fndig$(ly):a=421:b=55:gosub text
1380  ' << Schritte Window >>
1390  a=405:b=265:c=636:d=320:gosub rboxb:a=5:b=18:c=2:gosub schrift
1400  a$="Schritte":a=455:b=285:gosub text:a=0:b=10:c=1:gosub schrift
1410  a$="Schritte:    Drehungen:   ":a=409:b=310:gosub text
1420  sound 1,15,12,4:wave 1,1,9,60000,44:sound 1,15,8,4:wave 1,1,9,60000,44       :sound 1,15,3,4:wave 1,1,9,60000,50
1430  x=lx:y=ly:z=-1:zg=0:dr=0:zn=0:k=0:za=1:zb=1:v=contrl:w=ptsin:j=99
1440  for e=1 to 17:l(e)=1:r(e)=1:next e:poke v+10,1:a=2:b=1:gosub lform
1450  a=5:gosub lstaerke:a=1:gosub modus:zn=0:s=0
1460  ' ################################ Spiel ##################################
1470  color 1,1,1:a=ry(s):b=rx(s):if g(1)+g(2)=0 then 1500
1480  poke v,6:poke v+2,2:poke w+2,180:if g(1)=0 then 1490                           else poke w,458:poke w+4,458-b*30:poke w+6,180+a*30:vdisys ' Kompass
1490  if g(2)<>0 then z=atn((x-1)/(y-.99999997))-s/2*pi!:poke w,582                  :poke w+4,-sin(z)*40+582:poke w+6,-cos(z)*40+180:vdisys                        'Ziel-Peiler-Pfeil berechen
1500  i=-1:g=x:h=y:p=0:u=0:n=10:o=390:q=10:t=390:if g(4)=0 then 1530                 ' Positionsanzeige -->
1510  poke v,8:poke v+2,1:poke v+6,2:poke w,501:poke w+2,55:poke intin               ,16+int(x/10)-16*(x<10):poke intin+2,16+(x mod 10):vdisys(1):poke w,605        :poke intin,16+int(y/10)-16*(y<10):poke intin+2,16+(y mod 10):vdisys
1520  ' Zeichenschleife
1530  e=asc(mid$(a$(h),g,1)):if g(3)+i=2 then poke v+6,1:poke w,535:poke v,8     :poke v+2,1:poke w+2,380:f=(int(e/16)and 3): poke intin,16+f-44*(f=3):vdisys   ' GedÑchnis
1540  i=i+2:f=srr(s,e and 15):l=sgn(f and 2):r=sgn(f and 8):m=(f and 1)
1550  e=200-f(i):f=200+f(i):c=200-f(i-1):if i>j then p=1:u=1:l(i)=2:r(i)=2
1560  d=200+f(i-1):if l=1 and l(i)=0 then p=1:l(i)=1
1570  if r=1 and r(i)=0 then u=1:r(i)=1
1580  if r+l=2 and m=0 then r(i)=r:l(i)=l:goto 1940 else if r+l=2 and p+u=0 then  1840
1590  if p+u=0 then 1680
1600  'Nicht benîtigte Abzweigungn Åbermalen (p Flag fÅr links, u fÅr rechts)
1610  color 1,wf(3),1,wm(3),wi(3):poke v,9:poke v+2,4
1620  if p=0 or(l=1 and m=0)then 1650
1630  poke w,n+1:poke w+2,n:poke w+4,n+1:poke w+6,o:p=0:n=e:o=f
1640  if l=0 then poke w+8,c+1:poke w+10,d:poke w+12,c+1:poke w+14,c:vdisys(1)   else poke w+8,e+1:poke w+10,f:poke w+12,e+1:poke w+14,e:vdisys
1650  if u=0 or(r=1 and m=0)then 1680
1660  poke w,t+1:poke w+2,q:poke w+4,t+1:poke w+6,t:u=0:q=e:t=f
1670  if r=0 then poke w+8,d+1:poke w+10,d:poke w+12,d+1:poke w+14,c:vdisys(1)   else poke w+8,f+1:poke w+10,f:poke w+12,f+1:poke w+14,e:vdisys
1680  if l=0 then n=e:o=f
1690  if r=0 then q=e:t=f
1700  if l(i)=0 then l(i)=l:l=1 else l(i)=l
1710  if r(i)=0 then r(i)=r:r=1 else r(i)=r
1720  if r+l=2 then if m=0 then 1940 else 1840
1730  poke v,9:poke v+2,3:poke w+2,c-1:poke w+6,e+1:poke w+10,e+1
1740  color 1,wf(2),1,wm(2),wi(2)'Oberer Teile der Abzweigung
1750  if l=0 then poke w,c+1:poke w+4,c+1:poke w+8,e+3:vdisys
1760  if r=0 then poke w,d+1:poke w+4,d+1:poke w+8,f-1:vdisys
1770  color 1,wf(1),1,wm(1),wi(1):poke w+2,d+1:poke w+6,f+1:poke w+10,f+1            ' Unterer Teil
1780  if l=0 then poke w,c+1:poke w+4,c+1:poke w+8,e+1:vdisys
1790  if r=0 then poke w,d+1:poke w+4,d+1:poke w+8,f+1:vdisys
1800  if m=1 then 1840 ' Mitte
1810  poke v,11:poke v+2,2:poke w+2,e:poke w+6,f:color 1,wf(4),wf(4),wm(4),wi(4)
1820  if l=0 then poke w,c+1:poke w+4,e+1:vdisys
1830  if r=1 then 1940 else poke w,d+1:poke w+4,f+1:vdisys(1):goto 1940
1840  color 1,wf(4),1,wm(4),wi(4):if g+h=2 then color 1,1,1,5,2'Hinten
1850  l=l(i):r=r(i):poke v,11:poke v+2,2:poke w,e*l+c*(1-l)+1:poke w+2,e
1860  poke w+4,f*r+d*(1-r)+1:poke w+6,f:vdisys(1)
1870  if j>=i then j=i:goto 1920
1880  poke v,9:poke v+2,4:poke w,12:poke w+2,390:poke w+4,390:poke w+6,390
1890  poke w+8,f:poke w+10,f:poke w+12,e+2:poke w+14,f
1900  color 1,wf(1),1,wm(1),wi(1):vdisys(1):color 1,wf(2),wf(2),wm(2),wi(2)
1910  poke w+2,10:poke w+6,10:poke w+10,e:poke w+14,e:j=i:vdisys
1920  if g=1 and h=1 and k=0 then k=1:sound 2,15,4,4:wave 3,4,12,8000
1930  goto 2010
1940  g=g+b:h=h+a:if i<15 then 1530
1950  'Nach 8 Abzeigungen Ende
1960  poke v,9:poke v+2,3:poke w,12:poke w+2,390:poke w+4,390:poke w+6,390
1970  poke w+8,201:poke w+10,201:color 1,wf(1),1,wm(1),wi(1):vdisys(1)
1980  poke w+6,10:color 1,wf(2),1,wm(2),wi(2):poke w+2,10:poke w+10,199:vdisys
1990  poke w,n+1:poke w+2,n:poke w+4,n+1:poke v+2,4:color 1,wf(3),1,wm(3),wi(3)
2000  poke w+6,o:poke w+8,t+1:poke w+10,q:poke w+12,t+1:poke w+14,t:vdisys
2010  m=asc(mid$(a$(y),x,1))
2020  h=srr(s,m and 15):l=sgn(h and 2):r=sgn(h and 8):i=h and 1
2030  if k=1 then if x<2 and y<2 then 2340 else f=1:gosub 2210:goto 2170
2040  sound 1,0:wave 1
2050  ' ***************************** Steuerung ********************************
2060  t=peek(ti):g=-(t=72)-2*(t=80)-3*(t=75)-4*(t=77):if g>0 then 2090
2070  if t=98 then 2340 else g=peek(jo):if g=0 then 2060
2080  g=log(g)/lo2!+1:if g<>int(g)then wave 1,0:sound 1,15,5,5,20:goto 2060
2090  wave 1,0:sound 1,15,(g and 1)*6+1,int(g/2)+3:wave 1,1,9,3000
2100  on g goto 2120,2150,2130,2140
2110  wave 0:sound 1,15,3,3:sound 2,15,2,1:sound 3,15,6,3,9:wave 15,15,9,83000,100:goto 2070
2120  if i=0 then 2170 else 2110 'Schritt vorwÑrts wenn keine Wand,sonst Knall
2130  if l=0 then dr=dr+1:gosub 2210:s=(s+1)and 3:goto 1470 else 2110 'links
2140  if r=0 then dr=dr+1:gosub 2210:s=(s-1)and 3:goto 1470 else 2110 'rechts
2150  dr=dr+1:gosub 2210:s=(s+2)and 3:goto 1470 ' 180¯ Drehung
2160  ' << Schritt vorwÑrts >>
2170  d=int(m/16)and 3:zn=zn-sgn(m and 128)*2+1'Berechnen,ob nîtig
2180  d=int(d+1+(d=3)):mid$(a$(y),x,1)=chr$(((m and 15)+d*16)+128*(m<128))
2190  zg=zg+1:x=x+rx(s):y=y+ry(s):if g(2)=0 then gosub 2260:goto 1460
2200  color 1,0,0:poke v,6:poke v+2,2:poke w+2,180:gosub 2240:goto 1460              'Nur den Zielpeilerpfeil lîschen
2210  color 1,0,0:if g(1)+g(2)=0 then 2260
2220  poke v,6:poke v+2,2:poke w+2,180
2230  if g(1)=1 then poke w,458:poke w+4,458-b*30:poke w+6,180+a*30:vdisys'Komp.
2240  if g(2)<>0 then poke w,582:poke w+4,-sin(z)*40+582                             :poke w+6,-cos(z)*40+180:vdisys ' Ziel-Peiler-Pfeil-lîschen
2250  ' << Anzahl Schritte und Drehungen printen >>
2260  poke v,8:poke v+2,1:poke v+6,3:poke intin,16+int(zg/100)-16*(zg<100)
2270  poke intin+2,16+int(zg mod 100)/10-16*(zg<10)
2280  poke intin+4,16+(zg mod 10):poke w,489:poke w+2,310:vdisys
2290  poke intin,16+int(dr/100)-16*(dr<100):poke intin+4,16+(dr mod 10)
2300  poke intin+2,16+int(dr mod 100)/10-16*(dr<10):poke w,609:vdisys
2310  za=za+1:if za>120 then za=1:zb=zb+1
2320  z$(zb)=z$(zb)+chr$(g):return ' Schrittspeicher
2330  ' *************************** Geschaft ************************************
2340  wave 0,0:a=0:b=0:s=0:l=lx:y=ly:poke systab+24,0
2350  gosub lform:a=3:gosub lstaerke:poke contrl,3:vdisys
2360  a$="Schritte : "+fndig3$(zg):if t<>98 then a$=a$+" Nîtige : "+fndig3$(zn)
2370  a$=a$+" Drehungen : "+fndig3$(dr):a=10:b=14:gosub text:gosub iraus
2380  ' Schritte, Drehung und wenn das Ziel erreicht wurde, minimale                   Schrittzahl ausgeben.
2390  x=lx:y=ly:g=v/2:h=w/2:c=g-4:d=h-4:for i=1 to zb:b$=z$(i)+chr$(0):j=1
2400  a=asc(mid$(b$,j,1))and 15:if a=0 then 2470 else if a<>1 then 2450
2410  color 1,1,1,0,0:a=x*v-g+5:b=y*w-h+21:gosub fellipse:x=x+rx(s):y=y+ry(s)
2420  if x<1 or y<1 or x>lx or y>ly then 2480 else color 1,1,1,4,2:a=x*v-g+5
2430  b=y*w-h+21:gosub fellipse:for a=1 to 10:if peek(tb)<>t then gosub warte:a=9
2440  poke systab+24,0:next a:goto 2460 'Warteschleifen
2450  s=(s+4-a+(a=4))and 3
2460  j=j+1:goto 2400
2470  next i
2480  gosub warte:goto 560
2490  '<<<<<< Irrgarten ausgeben >>>>>>>
2500  iraus:v=630/lx:w=373/ly:color 1,1,1,0,0:a=1:gosub lstaerke:a=0:b=0
2510  gosub lform:a=4:b=20:c=634:d=393:gosub boxa:poke contrl,6
2520  poke contrl+2,2:for x=1 to lx:for y=1 to ly:c=asc(mid$(a$(y),x,1))
2530  if(c and 4)<>0 then b=w*y+20:a=v*(x-1)+5:poke ptsin,int(a)                 :poke ptsin+2,int(b):poke ptsin+4,int(a+v):poke ptsin+6,cint(b):vdisys
2540  if(c and 8)<>0 then b=w*(y-1)+21:a=v*x+4:poke ptsin,int(a)                 :poke ptsin+2,int(b):poke ptsin+4,cint(a):poke ptsin+6,int(b+w):vdisys
2550  next y,x:gosub warte:return
2560  ' ************* Schwierigskeitsgrad- und GerÑteauswahl *******************
2570  auswahl:poke contrl,3:vdisys(1):color 1,1,1,4,2:a=4:gosub modus
2580  A=0:B=0:C=640:D=400:gosub boxa
2590  restore 3740:read x,a$:y=0:gosub titel:color 1,0,0,1,1:a=5:gosub lstaerke
2600  a=35:b=90:c=605:d=335:gosub prbox:color 1,1,1:gosub rbox'MenÅ-Window
2610  read a$:a=9:b=15:c=1:gosub schrift:a=100:b=110:gosub text'Name Spalte 1
2620  '<< Spalte 1 einlesen und MaximallÑnge (m) der Texte feststellen  >>
2630  a=0:b=9:c=1:gosub schrift:i=1:g(5)=0:g(6)=0
2640  read a$,a$(i+1),a$(i+2):if a$<>"sende"then if len(a$)>m then                   m=len(a$):i=i+3:goto 2640 else i=i+3:goto 2640 else i=i-3
2650  b=135:f=m*8+100:d=f-16:e=m*8+140'Koordinaten der Textteile berechnen
2660  ' << Spalte 1 ausgeben >>
2670  restore 3740:read x,a$,a$,a$,b$,c$:j=1
2680  a=70:gosub text:poke contrl+6,1:poke intin,40:poke ptsin,d:vdisys(1)
2690  poke intin,42:poke ptsin,d+40:vdisys(1):poke intin,41:poke ptsin,d+80
2700  vdisys(1):a=16:gosub sart:a$=b$:a=f-len(a$)*5+8:gosub text:a$=c$
2710  a=e-len(a$)*5+10:gosub text:a=2*(i-3=j)*sgn((dx=0)+(dy=0)):gosub sart
2720  b=b+12:j=j+3:if j<i then read a$,b$,c$:goto 2680 else if j<>i then 2760
2730  ' << Zahlen der letzten Selbstdefintion einsetzen >>
2740  read a$:a$(i)=a$:if dx=0 then b$="--"else b$=fnr$(dx)
2750  if dy=0 then c$="--":goto 2680 else c$=fnr$(dy):goto 2680
2760  read a$:a=9:b=15:c=1:gosub schrift:a=400:b=110:gosub text'Titel Spalte 2
2770  read a$,a$,a$,a$,a$:a=9:b=15:c=1:gosub schrift:a=400:b=110
2780  gosub text:a=0:b=15:c=1:gosub schrift:a=386:b=150:n=0
2790  ' << Spalte 2 ausdrucken >>
2800  read a$:if a$<>"ende"then a$=chr$(32-24*g(n+1))+" "+a$:gosub text:n=n+1:b=b+30:goto 2800
2810  ' << Vorbereitungen >>
2820  restore 2830:for j=1 to 10:read i(j):next j:sw=1:a=3:gosub modus:g(5)=0
2830  data 55,56,57,52,53,54,49,50,51,48
2840  a=66:b=sw*12+114:c=m*8+172:d=b+12:color 1,1,1,1,1:gosub boxa:g(6)=0:c=a
2850  d=b:gosub boxa:a=4:b=20:c=2:gosub schrift:color 1,1,1,1,1
2860  e=65:b=380:b$=chr$(189)+"1986 by Jens Fangmeier":poke ptsin+2,b
2870  for k=1 to 3:poke contrl,8:c=e-(k=1):poke contrl+2,1:color -(k<>2)
2880  for j=1 to len(b$):poke intin,asc(mid$(b$,j,1)):poke ptsin,c:vdisys
2890  c=c+22:next j:a=-(k=2)*16:gosub sart:next k:color 1
2900  a=0:b=15:c=1:gosub schrift:a=3:gosub lstaerke:a=2:b=1:gosub lform
2910  x=1:y=1:g(n)=0:gosub cur
2920  ' Tastatur- und Joytsick Abfrage
2930  sound 1,0,0:wave 1,0,0,0,0
2940  if peek(mj)=2 then 2990 else z=peek(ti):if z=28 or z=114 then 2990
2950  z=-(z=72)-2*(z=80)-3*(z=75)-4*(z=77):if z>0 then 2980
2960  z=peek(jo):if z=0 then 2930 else z=log(z)/log(2)+1
2970  if int(z)<>z then sound 1,15,1,3,5:goto 2930
2980  on z gosub 3510,3530,3550,3550:goto 2930
2990  wave 0:sound 1,15,6,4:sound 2,15,8,4:sound 3,15,10,4:wave 7,7,9,7000
3000  if x=2 then 3440
3010  ' <<<< Druck in Spalte 1 >>
3020  a=3:gosub modus:a=66:b=sw*12+114:c=m*8+172:d=b+12:color 1,1,1,1,1
3030  gosub boxa:c=a:d=b:gosub boxa:c=m*8+172:sw=y:b=sw*12+114:d=b+12:gosub boxa
3040  c=a:d=b:gosub boxa:a=1:gosub modus
3050  for j=1 to 200:next j:wave 0,0:if sw<>int(i/3)+1 then 2940
3060  ' <<<< Selbstdefinierte Grîûe Eingeben >>>>
3070  d=d+9:p=1:a=16:B=9:c=3:gosub schrift:k=0:if dx>9 then g=int(dx/10)+48      else if dx=0 then g=45                                                         else a$=chr$(dx+48):a=m*8+103:b=d:gosub text:a=a-5:a$="-"+a$:gosub text:g=45
3080  if dy>0 and dy<10 then b=d:a$=chr$(dy+48):a=m*8+145:gosub text:a=a-5              :a$="-"+a$:gosub text
3090  a=m*8+98:poke contrl,8:poke contrl+2,1:poke contrl+6,1:poke intin,g            :poke ptsin,a:poke ptsin+2,d:f=0:l=(dx<>0)*(dY<>0)
3100  d$=right$("--"+fnr$(dx),2)+right$("--"+fnr$(dy),2)
3110  a=m*8+98:if dx=0 then mid$(d$,1,2)="--"
3120  if dy=0 then mid$(d$,3,2)="--"
3130  ' Abfrageschleife
3140  k=k+1:if k=5 then vdisys(1)else if k=10 then vdisys(1):k=0
3150  j=peek(jo):c=peek(ti):b=peek(mj):if b=2 or c=28 or c=114 then 3290
3160  if j<>0 then sound 1,15,j,3:wave 1,1,9,3000
3170  if p<4 and(c=77 or j=8)then s=1:goto cur2 ' Cursor nach rechts
3180  IF c=75 or j=4 then if p>1 then s=-1:goto cur2 else 3290 'Cursor n.links
3190  if c=72 then 2930 else if (c<2 or c>11)and(j<1 or j>2)and (c<103 or c>112)     then 3140 ' Keine Zahl eingeben und Joystick nicht nach oben oder unten
3200  '<< Zahl annehmen >>
3210  if k<5 then vdisys
3220  if j=1 or j=2 then g=g+j*2-3:if g<48 then g=57+8*(g=46)                             else if g>57 then g=48                                                    ' Eingabe Åber Joytick
3230  if c>1 and c<12 then g=47+c+10*(c=11) ' Eingabe Åber Tastatur
3240  if c>102 and c<113 then g=i(c-102) ' Eingabe Åber Zehnerblock
3250  if (p and 1)=1 and g=48 then g=45 ' Wenn erste Stelle
3260  poke intin,g:vdisys(1):mid$(d$,p,1)=chr$(g)
3270  for k=1 to 100:next k:k=0:if j<>0 then 3140 else c=77:goto 3170
3280  ' <<< Exit Selbstdef >>>
3290  b$=left$(d$,2):b=d:c$=right$(d$,2):if k>=5 then vdisys
3300  if val(b$)=0 and b$<>"--"                                                                   then a$=b$:a=m*8+98:gosub text:b$="--":a$="--":gosub text
3310  if val(c$)=0 and c$<>"--"                                                                   then a$=c$:a=m*8+140:gosub text:c$="--":a$="--":gosub text
3320  if b$="--"then dx=0 else k=instr(b$,"-"):if k=0 then dx=val(b$)            else a$=b$:a=m*8+98:gosub text:a$=mid$(b$,3-k,1):a=a+5:gosub text:dx=val(a$)
3330  if c$="--"then dy=0 else k=instr(c$,"-"):if k=0 then dy=val(c$)            else a$=c$:a=m*8+140:gosub text:a$=mid$(c$,3-k,1):a=a+5:gosub text:dy=val(a$)
3340  if dx=0 or dy=0 then if l=0 then 3370                                          else a=2:b=9:c=2:gosub schrift:color 1:l=0:goto 3360'Schrift grau
3350  if l=1 then 3370                                                                 else color 0,0,0:l=1:a=0:b=9:c=2:gosub schrift'Schrift Weiû
3360  b=d:a$=a$(i):a=70:gosub text:a$="(    *    )":a=m*8+84:gosub text
3370  a=0:b=10:c=1:gosub schrift:color 1:goto 2930
3380  ' << Cursor bei Selbstdef >>
3390  cur2:if k>=5 then vdisys
3400  k=0:a=a+(10+22*abs(sgn((p=2)*(s=1)+(P=3)*(s=-1))))*s:poke ptsin,a
3410  if f=0 and p=2 and s=1 then f=1:a$=right$(d$,2):b=d:gosub text                    :c$=str$(cint(val(left$(d$,2))*2/3)):a$=right$("--"+                           right$(c$,len(c$)-1),2):gosub text:mid$(d$,3,2)=a$:poke contrl+6,1
3420  p=p+s:g=asc(mid$(d$,p,1)):poke intin,g:for j=1 to 200:next j:goto 3140
3430  '<<<<< Druck in Spalte 2 >>>>>
3440  f=int((y-1)/2):g(f)=1-g(f)
3450  if f=n-1 then if sw<>int(i/3)+1 then lx=val(a$(sw*3-1)):ly=val(a$(sw*3))       :return else if (dx<>0 and dy<>0)then lx=dx:ly=dy:return else 3270             ' Spielstart, bei Selbstdef. Koordinaten öberprÅfen
3460  if f=n then gosub ausgang:goto 2940 ' Spiel beenden
3470  a=386:b=120+f*30:a$=chr$(32-24*g(f)):gosub text ' Haken enfernen,setzen
3480  for j=1 to 700:next j:wave 1,0:sound 1,0:goto 2940
3490  sound 1,15,1,2:sound 2,15,3,3,2: wave 11,11,9,4500,10:return
3500  ' << Cursor hoch >>
3510  if y<2 or (y<4 and x=2)then 3490 else f=1:goto mcur
3520  ' << Cursor runter >>
3530  if y>i/3 or (y>n*2 and x=2)then 3490 else f=2:goto mcur
3540  ' << Cursor links o. rechts >>
3550  if x=1-(z=4)then 3490 else f=3-(z=4):goto mcur
3560  ' << Cursor bewegen (f) >>
3570  mcur:color 0,0,0:gosub cur ' Alten Cursor lîschen
3580  sound 1,15,((f*7-5) mod 12),3+f/3:wave 1,1,9,20000
3590  if f<3 then y=y+(f*2-3)*(1-(x=2))else x=f-2'Neue Koordinaten
3600  color 1,1,1:if f<>4 then cur
3610  y=int(y/2)*2+1:if y<3 then y=3 else if y>n*2+1 then y=n*2+1
3620  ' Cursor-Pfeil im Auswahl-Menue setzen
3630  cur: a=x*316-272:b=y*(12-(x=2)*3)+119+18*(x=2):c=a+16:d=b:goto linie
3640  ' Spiel beenden
3650  ausgang:a=1:b=10:c=1:gosub schrift:a=402:b=n*30+121:a$="Sicher ? (J) "         ' Nachfrage
3660  gosub text:gosub warte:a=0:gosub sart:a=402:if peek(ti)<>36                    then a$="Spiel beenden":gosub text:return 'Wenn nich,dann weiter
3670  a=0:b=0:gosub lform:a=1:gosub lstaerke:a=0:b=10:c=1:gosub schrift
3680  poke contrl,3:vdisys(1):a=1:b=18:c=640:d=18:gosub linie
3690  poke systab+24,0:poke contrl,122:poke intin,0:vdisys' Show Maus
3700  a$="Desk  File  Run  Edit  Debug":a=24:b=14:gosub text'MenÅ-Zeile schreiben
3710  t=peek(tb):while 1<2:t=(t+4)and 255:poke t+ta,3:poke t+ta-2,46:poke tb,t
3720  wend
3730  ?"Error";err,"In Zeile";erl:resume 3650
3740  data 200,3 D - I R R G A R T E N
3750  data Schwierigskeitsgerade:
3760  data Supersuperklein,6,4,Superklein,8,5,Sehrklein,10,6
3770  data Klein,12,7,Mittelklein,14,8,Mittel,17,11
3780  data Mittelgroû,21,13,Groû,26,16,Sehrgroû,32,20
3790  data Riesengroû,40,25,Superriesengroû,50,31,Fast unlîsbar,60,38
3800  data Einfach Irre,70,44,Unmîglich,80,50,Nur fÅr LebensmÅde,99,62
3810  data Selbstdefiniert,,
3820  data sende,,,Optionen:,Kompaû,Zielpeiler,GedÑchnis
3830  data Positionsanzeige,Spiel starten,Spiel beenden,ende
3840  ' << Warten auf Tasten- oder Joystickdruck >>
3850  warte:t=peek(tb):poke systab+24,0
3860  while t=peek(tb)and peek(mj)=0 and peek(jo)=0:wend
3870  t=peek(tb):poke systab+24,1:return
3880  ' ********************* VDI- und Graphickroutienen ***********************
3890  ' SÑmmtliche VDI-Befehle sind vom Output-Fenster unabhÑngig, kînnen also         auf den Gesammten Bildschirm zugreifen. Das Output-Fenster wird                Åberhauptnicht benutzt.
3900  ' << 3D-Text Koordinaten a,b Tiefe d >>
3910  texta:e=a:a=0
3920  gosub sart:a=2:gosub modus:a=e:gosub text
3930  for i=1 to d:poke ptsin,a+i:poke ptsin+2,b+i:vdisys(1):next i:a=2
3940  gosub sart:a=3:gosub modus:a=e:gosub text:a=1:gosub modus:return
3950  return
3960  ' << Titelzug >>
3970  titel:y=45:a=5:gosub lstaerke:e=len(A$)*8:a=1:gosub modus
3980  a=290-e:b=y-36:c=345+e:d=y+22:color 1,1,1,1,2:gosub prbox:gosub rbox
3990  a=12:b=20:c=2:gosub schrift:a=310-E:b=y:D=10:goto texta ' 3D-Text
4000  ' << Line (a,b:c,d)
4010  linie: poke contrl,6:poke contrl+2,2:poke ptsin,a:poke ptsin+2,b
4020  poke ptsin+4,c:poke ptsin+6,d:vdisys(1):return
4030  ' << Schrift a:Art b:Grîûe c:Modus >>
4040  schrift:gosub sart:a=b:gosub sgroesse:a=c:gosub modus:return
4050  ' << Graphick Text (a,b:a$) >>
4060  text:
4070  for c=0 to len(a$)-1
4080  poke intin+c*2,asc(mid$(a$,c+1,1)):next c
4090  poke intin+c*2,0:poke contrl,8:poke contrl+2,1
4100  poke contrl+6,len(a$):poke ptsin,a:poke ptsin+2,b:vdisys(1):return
4110  ' <<  Graphick Modus (a) >>
4120  ' a=1: AND-Modus (Normal)
4130  ' a=2: OR-Modus  (Mischen)
4140  ' a=3: XOR-Modus
4150  ' a=4: NOR-Modus (Revers-Schrift)
4160  modus:poke contrl,32:poke contrl+2,0:poke contrl+6,1:poke intin,a:vdisys
4170  return
4180  ' << Schriftart (a) >>
4190  'Bit 0=Fettschrift
4200  'Bit 1=Light-(Grau-)Schrift
4210  'Bit 2=Kursiv-(SchrÑg-)Schrift
4220  'Bit 3=Unterstrichen
4230  'Bit 4=Hohlschrift Achtung! gibt bei PRINT Probleme. Nur mit G.Text
4240  sart:poke contrl,106:poke contrl+2,0:poke contrl+6,1:poke intin,a:vdisys
4250  return
4260  ' << Schriftgrîûe (a) >>
4270  '  0-9 : sehr klein
4280  '   9  :  klein
4290  ' 10-15: normal
4300  ' 16-17: groû
4310  ' 18-19: sehr groû
4320  ' Achtung: Nur mit Graphick-Text verwenden. Print nimmt immer 8*16               Raster an, die Zeichen Åberschneiden sich also (Groûschrift)                   oder stehen zu weit auseinander (Kleinschrift)
4330  sgroesse:poke contrl,107:poke contrl+2,0:poke contrl+6,1:poke intin,a          :vdisys(1):return
4340  ' << Exit, setzt Schriftgrîû und Textwinkel zurÅck >>
4350  ' Bei verÑnderter Textgrîûe oder -winkel im Editor: RUN ,EXIT eingeben
4360  exit:a=15:gosub sgroesse:a=0:gosub twinkel:end
4370  ' << AusgefÅlltes, Abgerundetes Rechteck (a,b:c,d) >>
4380  prbox:poke contrl,11:poke contrl+2,2:poke contrl+6,0:poke contrl+10,9
4390  poke ptsin,a:poke ptsin+2,b:poke ptsin+4,c:poke ptsin+6,d:vdisys(1):return
4400  ' << Abgerundetes Rechteck (a,b:c,d) >>
4410  rbox:poke contrl,11:poke contrl+2,2:poke contrl+6,0:poke contrl+10,8
4420  poke ptsin,a:poke ptsin+2,b:poke ptsin+4,c:poke ptsin+6,d:vdisys(1):return
4430  ' << LiniestÑrke setzen (a) >>
4440  ' Achtung: funktioniert nicht bei ausgefÅllten Kîrpern (z.B. prbox)
4450  ' Funktioniert aber auch bei Basic-Befehlen (z.B. LINEF)
4460  lstaerke:poke contrl,16:poke contrl+2,1:poke ptsin,a:vdisys(1):return
4470  ' << Linienanfangs- und End-Form (a;b) >>
4480  ' 0 : Normal
4490  ' 1 : Abgerundet (nur bei LiniestÑrke>2)
4500  ' 2 : Mit Pfeilspitze
4510  lform:poke contrl,108:poke contrl+2,1:poke contrl+6,0:poke intin,a
4520  poke intin+2,b:vdisys(1):return
4530  ' << Textwinkel (a): Winkel der Textausgabe verÑnder >>
4540  ' a=0,900,1800 oder 2700 (900 enspricht 90¯)
4550  twinkel:poke contrl,13:poke contrl+2,0:poke contrl+6,1:poke intin,a:vdisys
4560  return
4570  ' << AugefÅlltes Rechteck (a,b:c,d) >>
4580  boxa:poke contrl,11:poke contrl+2,2:poke contrl+6,0:poke contrl+10,1
4590  poke ptsin,a:poke ptsin+2,b:poke ptsin+4,c:poke ptsin+6,d:vdisys(1):return
4600  ' << erzeuegen z.B. des Kompass-Windows >>
4610  rboxb:f=a:a=1:gosub modus:a=f:color 1,1,1,1,2:gosub prbox:color 1,0,0
4620  a=1:gosub lstaerke:a=f-e:b=b-e:c=c+e:d=d+e:gosub rbox:a=5:goto lstaerke
4630  gosub rbox:a=5:goto lstaerke
4640  ' << AusgefÅllter Polyeder >>
4650  'a(),b(): X und Y-Koordinaten
4660  'a:       Anzahl der Koordinaten
4670  polygon:poke contrl,9:poke contrl+2,a:poke contrl+10,7:for b=1 to a        :poke ptsin+b*4-4,a(b):poke ptsin+b*4-2,b(b):next b:vdisys(1):return
4680  ' << Kreis (a,b,c) >>
4690  kreis:poke contrl,11:poke contrl+2,2:poke contrl+6,2:poke contrl+10,6      :poke ptsin,a:poke ptsin+2,b:poke ptsin+4,c:poke ptsin+6,c                     :poke intin,0:poke intin+2,3700:vdisys(1):return
4700  ' << AusgefÅllter Kreis (a,b,c) >>
4710  fkreis:poke contrl,11:poke contrl+2,2:poke contrl+6,2:poke contrl+10,5     :poke ptsin,a:poke ptsin+2,b:poke ptsin+4,c:poke ptsin+6,c:vdisys(1):return
4720  ' << AusgefÅllte Ellipse (a,b,c,d) >>
4730  fellipse:poke contrl,11:poke contrl+2,2:poke contrl+6,2:poke contrl+10,5   :poke ptsin,a:poke ptsin+2,b:poke ptsin+4,c:poke ptsin+6,d:vdisys(1):return
