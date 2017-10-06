10    REM ###################### FUNKTNPL.BAS ########################
20    REM Funktionsberechnug zu Erstellung eines Graphen
30    out 4,18:dim s(10),a(8)
40    s(1)=.1:s(2)=.25:s(3)=.5:s(4)=1:s(5)=2:s(6)=5
50    s(7)=10:s(8)=20:s(9)=50:s(10)=100:funkta$=""
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
180   if ad=1 then clearw 2:goto 90
190   if ad=2 then clearw 2:goto 100
200   if ad=3 then va=0:gosub GITTER:gotoxy 25,18:print spc(20):goto 130
210   if ad=4 then out 4,8:end
220   goto 130
230   USCHRIFT:gotoxy 1,0:print"Funktions-Schar"chr$(191)" erstellt auf 260ST";
240   print chr$(191);" ";chr$(14);chr$(15);"  ";
250   print chr$(189);" by Martin Hachenberg April 1986"
260   linef 0,18,616,18:return
270   FKEINGAN:clearw 2:gosub USCHRIFT ' Funktionseingabe F(x.fa)
280   gotoxy 13,3:print" Funktion eingegeben!"
290   gotoxy 12,5:print"Ansonsten F(x.fa) in der Form"
300   gotoxy 6,6:print"F(x.f(a))=[F(x.fa)] zB. F(x.fa)=2*x+1 ohne Variable fa"
310   gotoxy 9,7:print"oder zB. F(x.fa)=fa*x+1 mit Variable fa"
320   gotoxy 16,8:print"eingeben."
330   gotoxy 13,13:input"F(x.fa)=",funkt$
340   zeile$="1120 y=":gosub EINGABEfx:funktx$=funkt$
350   if instr(0,funktx$,"a") then ff1=1 else ff1=0:funkta$="l"
360   return
370   EGRZSKL:clearw 2:gosub USCHRIFT ' Eingabe Grenzen + Skalierung ---------
380   linef 500,100,500,200:gotoxy 6,2:print" F(x.fa)=";funktx$
390   linef 450,150,550,150
400   linef 550,150,545,155:linef 550,150,545,145
410   linef 500,100,505,105:linef 500,100,495,105
420   gotoxy 30,6:print"Y":gotoxy 31,9:print" X"
430   gotoxy 5,3:print"Eingabe der Grenzen :"
440   gotoxy 5,5:input"X-max : ",xo
450   gotoxy 5,6:input"X-min : ",xu
460   if xo<=xu then gotoxy 5,5:print spc(20):gotoxy 5,6:print spc(20):goto 440
470   gotoxy 8,9:print" + -> Gleiche Grenzen"
480   gotoxy 5,8:input"Y-max : ",yo$
490   gotoxy 8,9:print spc(30)
500   if yo$="+" then yo=xo:yu=xu:goto 550
510   yo=val(yo$)
520   gotoxy 5,9:input"Y-min : ",yu
530   if yo<=yu then gotoxy 5,8:print spc(20):gotoxy 5,9:print spc(20):goto 470
540   goto 570
550   gotoxy 5,8:print"Y-max :";yo;"       "
560   gotoxy 5,9:print"Y-min :";yu;"           "
570   yy=(yo-yu):gotoxy 4,11:print"Schrittweite"
580   xx=(xo-xu):gotoxy 5,12:print"1 - Standart"
590   gotoxy 5,13:print"2 - Mastab 1:1"
600   gotoxy 5,14:print"3 - Mastab Variabel"
610   gotoxy 5,15:input"Mastab Nr.  ",va
620   if va<1 or va>3 then gotoxy 9,15:print spc(20):goto 610
630   on va gosub STANDART,MAST11,MVARIABEL ' Grenzwert + Skalirungs Berechnung
640   return ' Ende Eingabe ---------------------------------------
650   STANDART:dx=xx/400:dy=yy/300:gx=400:gy=300:vy=(3*xx)/(4*yy):vx=1
660   if vy<1 then vy=1:vx=(4*yy)/(3*xx)
670   return
680   MAST11:vx=1:vy=1
690   if xx*3>yy*4 then dx=xx/400:dy=dx:gx=400:gy=abs(yy/dx):return
700   dx=yy/300:dy=dx:gx=abs(xx/dx):gy=300
710   return
720   MVARIABEL:gotoxy 9,12:print"Verhaeltnis X*A - Y*B":gotoxy 9,15:print spc(20)
730   gotoxy 9,13:print spc(20):gotoxy 9,14:print spc(20)
740   gotoxy 9,14:input"X ",vx:gotoxy 11,14:input":  Y ",vy:vv=vx/vy
750   if xx*3*vv>yy*4 then goto 760 else goto 770
760   dx=xx/400:dy=dx/vv:gy=abs(yy/dx)/vv:gx=400:return
770   dx=(yy/300)/vv:dy=dx:gx=abs(xx/dx):gy=300:return
780   ' ##############################################################
790   ACHSENP:clearw 2:gosub USCHRIFT ' Zeichnen X und Y Achse-------
800   if yo>0 and yu<0 then ny=gy-abs((0-yu)/yy)*gy:linef 5,ny+20,gx+5,ny+20 ' xA
810   if yo<0 or yu>=0 then ny=gy
820   if xo>0 and xu<0 then nx=abs((0-xu)/xx)*gx:linef nx+5,20,nx+5,gy+20 'yA
830   if xo<0 or xu>0 then nx=0
840   linef 5,20,5,gy+20:linef gx+5,20,gx+5,gy+20
850   linef 5,20,gx+5,20:linef 5,gy+20,gx+5,gy+20:return
860   SKALIERUNG:va=1
870   for i=1 to 10:skx=xx/s(i):sky=yy/s(i)
880   skx=gx/skx:sky=gy/sky:if skx<=40 then kx=i
890   if sky<=40 then ky=i
900   next:x1=nx+3:x2=nx+7:y1=ny+18:y2=ny+22
910   gosub GITTER:return
920   BESCHRGR:gotoxy 25,4:print"Grenzen des Graphen :"
930   gotoxy 27,5:print"X-max : ";xo:gotoxy 25,9:print"Skalierung der Achsen :"
940   gotoxy 27,6:print"X-min : ";xu:gotoxy 27,10:print chr$(127);" X   : ";s(kx)
950   gotoxy 27,7:print"Y-max : ";yo:gotoxy 27,11:print chr$(127);" Y   : ";s(ky)
960   gotoxy 27,8:print"Y-min : ";yu:linef 430,63,590,63
970   if funkta$<>"l" then gotoxy 25,2:print"f(a)=";funkta$:x=1 else x=0
980   gotoxy 24,2-x:print"F(x.a)=";funktx$:linef 430,249,590,249
990   gotoxy 25,12:print"Mastab :":gotoxy 25,13:print"X * ";
1000  print using "###.##";vx;:print" ~ Y * ";:print using "###.##";vy:return
1010  FUNKTIONPL:x=xu:px=4:ay=ny:ax=5 ' Funktions Plott -----------
1020  gosub FUNKTION:py=gy-abs((y-yu)/yy)*gy+20:px=px+1
1030  x=x+dx:if x-dx>=xo then 1100
1040  if y<yu then py=gy+20
1050  if y>yo then py=20
1060  if ay=20 and py>=gy+20 then ay=py
1070  if ay=gy+20 and py<=20 then ay=py
1080  linef ax,ay,px,py:ay=py:ax=px
1090  goto 1020
1100  return
1110  FUNKTION: 'X Y FA ---------------------------------
1120  ' y=
1130  return
1140  FUNKTIONa: 'a --------------------------------------
1150  ' fa=
1160  return
1170  EINGABEfx: ' Eingabe der Funktion ber Floppy
1180  dat$="FUNKTION.BAS"
1190  open "O",#1,dat$
1200  print #1,zeile$;funkt$
1210  close
1220  chain merge dat$,1230
1230  kill dat$
1240  return
1250  GITTER:if xu<=0 then v=0 else v=1 ' Gitter ---------------------------
1260  if va=0 then x1=5:x2=gx+5:y1=20:y2=20+gy
1270  skx=int(xu/s(kx)):skx=s(kx)*(skx+v):x=skx
1280  while x<=xo ' X - Achse --------------------------------
1290  snx=abs((x-xu)/xx)*gx:linef 5+snx,y1,5+snx,y2:x=x+s(kx)
1300  wend
1310  if yu<=0 then v=0 else v=1
1320  sky=int(yu/s(ky)):sky=s(ky)*(sky+v):y=sky
1330  while y<=yo ' Y - Achse ---------------------------------
1340  sny=gy-abs((y-yu)/yy)*gy:linef x1,sny+20,x2,sny+20:y=y+s(ky)
1350  wend
1360  if va=1 then return
1370  linef 5,ny+21,gx+5,ny+21:linef nx+4,20,nx+4,gy+20
1380  gotoxy 25,18:print spc(20):return
1390  AEINGABE:
1400  gotoxy 20,3:print"Definition Variable a :"
1410  gotoxy 19,4:input"als 1-Werte oder 2-Funktion";taste$
1420  if taste$="1" then ffa=0:taste$="Ok":funkta$="l"
1430  if taste$="2" then ffa=1:taste$="Ok":goto 1490
1440  if taste$<>"Ok" then 1410 else gotoxy 19,4:print spc(30)
1450  gotoxy 19,4:print"  max. 9 Werte (+ Ende)";spc(8):daw=-1
1460  daw=daw+1:gotoxy 21,5+daw:print"A(";daw+1;:input") - ",da$
1470  a(daw)=val(da$):if da$="+" then daw=daw-1
1480  if da$="+" or daw=8 then return else goto 1460
1490  gotoxy 19,4:print spc(35):gotoxy 19,11:input"f(a)=",funkt$
1500  gotoxy 20,12:print spc(10):gotoxy 20,12:input"a-max    :",ao
1510  gotoxy 20,13:input"a-min    :",au
1520  if ao<au then gotoxy 20,13:print spc(20):goto 1490
1530  gotoxy 20,14:print chr$(127);:input"a(9 max):",fdaw:fda=(ao-au)/(fdaw-1)
1540  if fdaw>9 or fdaw<=1 then gotoxy 20,14:print spc(14):goto 1530
1550  zeile$="1150 fa=":gosub EINGABEfx:funkta$=funkt$
1560  return
1570  PLOTT:i=1
1580  if ff1=0 then gosub FUNKTIONPL:return
1590  if ffa=0 then gosub ANZEIGEa:return
1600  for a=au to ao step fda
1610  gotoxy 4*i-4,19:print chr$(i+16);chr$(240);:print using"###.#";a;:i=i+1
1620  gosub FUNKTIONa:gosub FUNKTIONPL
1630  next
1640  return
1650  ANZEIGEa:
1660  for i=0 to daw:fa=a(i)
1670  gotoxy 4*i,19:print chr$(i+17);chr$(240);:print using"###.#";fa;
1680  gosub FUNKTIONPL:next
1690  return
1700  INFO: ' ---- INFO---------------------
1710  fullw 2:clearw 2:gosub USCHRIFT
1720  linef 5,20,610,20:linef 5,320,610,320
1730  linef 5,20,5,320:linef 610,20,610,320
1740  linef 15,30,600,30:linef 15,310,600,310
1750  linef 15,30,15,310:linef 600,30,600,310
1760  color 1,1,1,2,2:fill 305,319
1770  gotoxy 2,2:print string$(31,chr$(3))" Info ";string$(31,chr$(4))
1780  linef 37,58,574,58
1790  gotoxy 3,4
1800  print"Dieses Programm ist ein einfacher Funktions-Plotter . Er plottet"
1810  gotoxy 3,5
1820  print"eine Funktions-Schar oder eine einzelne Funktion auf den Monitor"
1830  gotoxy 3,6
1840  print"in  vorgegebenen Grenzen. Zun„chst muž  die Funktion  eingegeben"
1850  gotoxy 3,7
1860  print"werden. Die Eingabe erfolgt ueber  das Programm, jedoch wird das"
1870  gotoxy 3,8
1880  print"Disketten-Laufwerk benutzt, weswegen die Diskette nicht schreib-"
1890  gotoxy 3,9
1900  print"geschtzt sein darf. Auch ist dieses Programm  nur  auf Hochauf-"
1910  gotoxy 3,10
1920  print"loesender Graphik lauffaehig. Zudem wird die Maus ausgeschaltet,"
1930  gotoxy 3,11
1940  print"kann aber falls Sie einen BREAK [Contrl-G] machen mit dem Befehl"
1950  gotoxy 3,12
1960  print">out 4,8< wieder eingeschaltet werden. Sollten Fehler auftreten,"
1970  gotoxy 3,13
1980  print"in Bezug auf den Plottvorgang, zuerst die Funktion  ueberprfen."
1990  gotoxy 3,14
2000  print"Die Konstanten  Pi(->3.1416) und  e(->2.7183) sind  dem Programm"
2010  gotoxy 3,15
2020  print"bekannt und koennen als Funktionsparameter verwendet werden.Eine"
2030  gotoxy 3,16
2040  print"Fehlerbehandlung  erfolgt  durch  Meldungen  im Command-Fenster."
2050  gotoxy 3,17
2060  input"Deshalb sollte der Grafikbuffer aktiviert sein.         ",a$
2070  color 1,1,1,1,1:clearw 2:return
