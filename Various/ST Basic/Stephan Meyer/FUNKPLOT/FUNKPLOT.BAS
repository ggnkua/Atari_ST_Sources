10    REM ###################### FUNKPLOT.BAS ########################
20    ' Funktionsberechnug zu Erstellung eines Graphen
30    on ERROR goto 1650:out 4,18:dim s(10),a(8)
40    s(1)=.1:s(2)=.25:s(3)=.5:s(4)=1:s(5)=2:s(6)=5
50    s(7)=10:s(8)=20:s(9)=50:s(10)=100
60    e=2.7183:Pi=3.1416
70    color 1,1,1,1,1:fullw 2:clearw 2:gosub INFO
80    if peek(systab)<>1 then clearw 2:out 4,8:end ' HIGH Resolution ?
90    gosub FKEINGAN
100   gosub EGRZSKL:if ff1=1 then gosub AEINGABE
110   gosub USCHRIFT:gosub ACHSENP:gosub SKALIERUNG:gosub BESCHRGR
120   gosub PLOTT
130   gotoxy 25,15:print"1 - Neue Funktion"
140   gotoxy 25,16:print"2 - Neue Grenzen"
150   gotoxy 25,17:print"3 - Gitter"
160   gotoxy 25,18:input"4 - Ende        ",ad
170   if ad<1 or ad>4 then gotoxy 25,18:print spc(20):goto 130
180   if ad=1 then ad=4
190   if ad=2 then clearw 2:goto 100
200   if ad=3 then va=0:gosub GITTER:gotoxy 25,18:print spc(20):goto 130
210   if ad=4 then out 4,8:end
220   goto 130
230   USCHRIFT:gotoxy 1,0:print"Funktions-Schar"chr$(191)" erstellt auf 260ST";
240   print chr$(191);" ";chr$(14);chr$(15);"  ";
250   print chr$(189);" by Martin Hachenberg April 1986"
260   linef 0,18,616,18:return
270   FKEINGAN:clearw 2:gosub USCHRIFT ' Funktionseingabe F(x.fa)
280   gotoxy 13,3:print" Funktion eingegeben ?"
290   gotoxy 12,5:print"Ansonsten F(x.fa) in der Form"
300   gotoxy 6,6:print"F(x.f(a))=[F(x.fa)] zB. F(x.fa)=2*x+1 ohne Variable fa"
310   gotoxy 9,7:print"oder zB. F(x.fa)=fa*x+1 mit Variable fa"
320   gotoxy 13,8:input"in Zeile 1150 eingeben.  ",aa$
330   gotoxy 6,9:print"Und falls Sie f(a)=[fa] als Funktion definieren wollen,"
340   gotoxy 10,10:print"z.B. in der Form fa=2*a+1 in Zeile 1180"
350   gotoxy 14,11:input"eingeben[J/N].  ",a$
360   if a$="n" or a$="N" then ff1=0 else ff1=1
370   if aa$="n" or aa$="N" then out 4,8:end
380   return
390   EGRZSKL:clearw 2:gosub USCHRIFT ' Eingabe Grenzen + Skalierung ---------
400   linef 500,100,500,200
410   linef 450,150,550,150
420   linef 550,150,545,155:linef 550,150,545,145
430   linef 500,100,505,105:linef 500,100,495,105
440   gotoxy 30,6:print"Y":gotoxy 31,9:print" X"
450   gotoxy 5,3:print"Eingabe der Grenzen :"
460   gotoxy 5,5:input"X-max : ",xo
470   gotoxy 5,6:input"X-min : ",xu
480   if xo<=xu then gotoxy 5,5:print spc(20):gotoxy 5,6:print spc(20):goto 460
490   gotoxy 8,9:print" + -> Gleiche Grenzen"
500   gotoxy 5,8:input"Y-max : ",a$
510   gotoxy 8,9:print spc(30)
520   if a$="+" then yo=xo:yu=xu:goto 570
530   yo=val(a$)
540   gotoxy 5,9:input"Y-min : ",yu
550   if yo<=yu then gotoxy 5,8:print spc(20):gotoxy 5,9:print spc(20):goto 490
560   goto 590
570   gotoxy 5,8:print"Y-max :";yo;"       "
580   gotoxy 5,9:print"Y-min :";yu;"           "
590   yy=(yo-yu):gotoxy 4,11:print"Schrittweite"
600   xx=(xo-xu):gotoxy 5,12:print"1 - Standart"
610   gotoxy 5,13:print"2 - Mastab 1:1"
620   gotoxy 5,14:print"3 - Mastab Variabel"
630   gotoxy 5,15:input"Mastab Nr.  ",va
640   if va<1 or va>3 then gotoxy 9,15:print spc(20):goto 630
650   on va gosub STANDART,MAST11,MVARIABEL ' Grenzwert + Skalierungs Berechnung
660   return ' Ende Eingabe ---------------------------------------
670   STANDART:dx=xx/400:dy=yy/300:gx=400:gy=300:vy=(3*xx)/(4*yy):vx=1
680   if vy<1 then vy=1:vx=(4*yy)/(3*xx)
690   return
700   MAST11:vx=1:vy=1
710   if xx*3>yy*4 then dx=xx/400:dy=dx:gx=400:gy=abs(yy/dx):return
720   dx=yy/300:dy=dx:gx=abs(xx/dx):gy=300
730   return
740   MVARIABEL:gotoxy 9,12:print"Verhaeltnis X*A - Y*B":gotoxy 9,15:print spc(20)
750   gotoxy 9,13:print spc(20):gotoxy 9,14:print spc(20)
760   gotoxy 9,14:input"X ",vx:gotoxy 11,14:input":  Y ",vy:vv=vx/vy
770   if xx*3*vv>yy*4 then goto 780 else goto 790
780   dx=xx/400:dy=dx/vv:gy=abs(yy/dx)/vv:gx=400:return
790   dx=(yy/300)/vv:dy=dx:gx=abs(xx/dx):gy=300:return
800   '--------------------------------------------------------------------
810   ACHSENP:clearw 2:gosub USCHRIFT ' Zeichnen X und Y Achse-------
820   if yo>0 and yu<0 then ny=gy-abs((0-yu)/yy)*gy:linef 5,ny+20,gx+5,ny+20 ' xA
830   if yo<0 or yu>=0 then ny=gy
840   if xo>0 and xu<0 then nx=abs((0-xu)/xx)*gx:linef nx+5,20,nx+5,gy+20 'yA
850   if xo<0 or xu>0 then nx=0
860   linef 5,20,5,gy+20:linef gx+5,20,gx+5,gy+20
870   linef 5,20,gx+5,20:linef 5,gy+20,gx+5,gy+20:return
880   SKALIERUNG:va=1
890   for i=1 to 10:skx=xx/s(i):sky=yy/s(i)
900   skx=gx/skx:sky=gy/sky:if skx<=40 then kx=i
910   if sky<=40 then ky=i
920   next:x1=nx+3:x2=nx+7:y1=ny+18:y2=ny+22
930   gosub GITTER:return
940   BESCHRGR:gotoxy 25,4:print"Grenzen des Graphen :"
950   gotoxy 27,5:print"X-max : ";xo:gotoxy 25,9:print"Skalierung der Achsen :"
960   gotoxy 27,6:print"X-min : ";xu:gotoxy 27,10:print chr$(127);" X   : ";s(kx)
970   gotoxy 27,7:print"Y-max : ";yo:gotoxy 27,11:print chr$(127);" Y   : ";s(ky)
980   gotoxy 27,8:print"Y-min : ";yu:linef 430,63,590,63
990   if ff1=1 and ffa=1 then gotoxy 30,2:print"mit f(a)":x=2 else x=0
1000  if ff1=1 then a$=" F(x.fa)" else a$="   F(x)"
1010  gotoxy 28-x,2:print a$:linef 430,249,590,249
1020  gotoxy 25,12:print"Mastab :":gotoxy 25,13:print"X * ";
1030  print using "###.##";vx;:print" ~ Y * ";:print using "###.##";vy:return
1040  FUNKTIONPL:x=xu:px=4:ay=ny:ax=5 ' Funktions Plott -----------
1050  gosub FUNKTION:py=gy-abs((y-yu)/yy)*gy+20:px=px+1
1060  x=x+dx:if x-dx>=xo then 1130
1070  if y<yu then py=gy+20
1080  if y>yo then py=20
1090  if ay=20 and py>=gy+20 then ay=py
1100  if ay=gy+20 and py<=20 then ay=py
1110  linef ax,ay,px,py:ay=py:ax=px
1120  goto 1050
1130  return
1140  FUNKTION: 'X Y - fa -------------------------------
1150  ' y=
1160  return
1170  FUNKTIONa: 'a --------------------------------------
1180  ' fa=
1190  return
1200  GITTER:if xu<=0 then v=0 else v=1 ' Gitter ---------------------------
1210  if va=0 then x1=5:x2=gx+5:y1=20:y2=20+gy
1220  skx=int(xu/s(kx)):skx=s(kx)*(skx+v):x=skx
1230  while x<=xo ' X - Achse --------------------------------
1240  snx=abs((x-xu)/xx)*gx:linef 5+snx,y1,5+snx,y2:x=x+s(kx)
1250  wend
1260  if yu<=0 then v=0 else v=1
1270  sky=int(yu/s(ky)):sky=s(ky)*(sky+v):y=sky
1280  while y<=yo ' Y - Achse ---------------------------------
1290  sny=gy-abs((y-yu)/yy)*gy:linef x1,sny+20,x2,sny+20:y=y+s(ky)
1300  wend
1310  if va=1 then return
1320  linef 5,ny+21,gx+5,ny+21:linef nx+4,20,nx+4,gy+20
1330  gotoxy 25,18:print spc(20):return
1340  AEINGABE:
1350  gotoxy 20,3:print"Definition Variable a :"
1360  gotoxy 20,4:input"1-Werte oder 2-Funktion";a$
1370  if a$="1" then ffa=0:taste$="Ok"
1380  if a$="2" then ffa=1:taste$="Ok":goto 1440
1390  if taste$<>"Ok" then 1360 else gotoxy 19,4:print spc(30)
1400  gotoxy 19,4:print"  max. 9 Werte (+ Ende)";spc(8):daw=-1
1410  daw=daw+1:gotoxy 21,5+daw:print"A(";daw+1;:input") - ",da$
1420  a(daw)=val(da$):if da$="+" then daw=daw-1
1430  if da$="+" or daw=8 then return else goto 1410
1440  gotoxy 19,4:print spc(35):gotoxy 19,11:input"f(a) eingegeben";a$
1450  if a$="N" or a$="n" then out 4,8:end
1460  gotoxy 20,12:print spc(10):gotoxy 20,12:input"a-max    :",ao
1470  gotoxy 20,13:input"a-min    :",au
1480  if ao<au then gotoxy 20,13:print spc(20):goto 1460
1490  gotoxy 20,14:print chr$(127);:input"a(9 max):",fdaw:fda=(ao-au)/(fdaw-1)
1500  if fdaw>9 or fdaw<=1 then gotoxy 20,14:print spc(14):goto 1490
1510  return
1520  PLOTT:i=1
1530  if ff1=0 then gosub FUNKTIONPL:return
1540  if ffa=0 then gosub ANZEIGEa:return
1550  for a=au to ao step fda
1560  gotoxy 4*i-4,19:print chr$(i+16);chr$(240);:print using"###.#";a;:i=i+1
1570  gosub FUNKTIONa:gosub FUNKTIONPL
1580  next
1590  return
1600  ANZEIGEa:
1610  for i=0 to daw:fa=a(i)
1620  gotoxy 4*i,19:print chr$(i+17);chr$(240);:print using"###.#";fa;
1630  gosub FUNKTIONPL:next
1640  return
1650  '-------SBRERROR-------------------------------
1660  if err=11 then resume next
1670  if err=5 then resume 1700
1680  if err=108 then resume
1690  out 4,8:end
1700  clearw 2:color 1,1,1,2,2:linef 0,0,620,0
1710  linef 0,0,0,340:linef 620,0,620,340
1720  linef 0,340,620,340:fill 100,100
1730  color 1,1,1,3,2:pellipse 320,160,230,40
1740  gotoxy 11,9:input"  Funktionsaufruf nicht erlaubt  ",x$
1750  out 4,8:end
1760  INFO: ' ---- INFO---------------------
1770  fullw 2:clearw 2:gosub USCHRIFT
1780  linef 5,20,610,20:linef 5,320,610,320
1790  linef 5,20,5,320:linef 610,20,610,320
1800  linef 15,30,600,30:linef 15,310,600,310
1810  linef 15,30,15,310:linef 600,30,600,310
1820  color 1,1,1,2,2:fill 305,319
1830  gotoxy 2,2:print string$(31,chr$(3))" Info ";string$(31,chr$(4))
1840  linef 37,58,574,58
1850  gotoxy 3,4
1860  print"Dieses Programm ist ein einfacher Funktions-Plotter . Er plottet"
1870  gotoxy 3,5
1880  print"eine Funktions-Schar oder eine einzelne Funktion auf den Monitor"
1890  gotoxy 3,6
1900  print"in  vorgegebenen Grenzen. Zun„chst muž  die Funktion  eingegeben"
1910  gotoxy 3,7
1920  print"werden. Die Eingabe erfolgt manuel.Das Programm fragt hierzu.Die"
1930  gotoxy 3,8
1940  print"Fragen lassen nur Ja oder Nein zu. Fuer Ja brauchen Sie nur >CR<"
1950  gotoxy 3,9
1960  print"druecken,fuer Nein >N<.Auch ist dieses Programm nur auf Hochauf-"
1970  gotoxy 3,10
1980  print"loesender Graphik lauffaehig. Zudem wird die Maus ausgeschaltet,"
1990  gotoxy 3,11
2000  print"kann aber falls Sie einen BREAK [Contrl-G] machen mit dem Befehl"
2010  gotoxy 3,12
2020  print">out 4,8< wieder eingeschaltet werden. Sollten Fehler auftreten,"
2030  gotoxy 3,13
2040  print"in Bezug auf den Plottvorgang, zuerst die Funktion  ueberprfen."
2050  gotoxy 3,14
2060  print"Die Konstanten  Pi(->3.1416) und  e(->2.7183) sind  dem Programm"
2070  gotoxy 3,15
2080  print"bekannt und koennen als Funktionsparameter verwendet werden."
2090  gotoxy 24,16:input"Viel Erfolg      ",a$
2100  color 1,1,1,1,1:clearw 2:return
