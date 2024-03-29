10    REM ###################### FUNKTNPR.BAS ########################
20    REM Funktionsberechnug zu Erstellung eines Graphen
30    out 4,18:dim s(10):e=2.7183:Pi=3.1416
40    color 1,1,1,1,1:fullw 2:clearw 2:gosub INFO:gosub INIT:goto 90
50    INIT:gotoxy 1,0:print"Funktions-Graph"chr$(191)" erstellt auf 260ST ";
60    print chr$(14);chr$(15);"  ";
70    print chr$(189);" by Martin Hachenberg April 1986"
80    linef 0,18,616,18:return
90    if peek(systab)<>1 then clearw 2:out 4,8:end ' HIGH Resolution
100   gotoxy 13,5:print" Funktion eingegeben!"
110   gotoxy 12,7:print"Ansonsten F(x) in der Form"
120   gotoxy 12,9:print"F(x)=[F(x)] zB. F(x)=2*x+1"
130   gotoxy 16,11:print"eingeben."
140   gosub EINGABEfx
150   gotoxy 10,5:print spc(45):gotoxy 12,7:print spc(30)
160   gotoxy 12,9:print spc(30):gotoxy 15,11:print spc(15)
170   linef 500,100,500,200 ' Eingabe Grenzen + Skalierung -----------
180   linef 450,150,550,150
190   linef 550,150,545,155:linef 550,150,545,145
200   linef 500,100,505,105:linef 500,100,495,105
210   gotoxy 30,6:print"Y":gotoxy 31,9:print" X"
220   gotoxy 8,3:print"Eingabe der Grenzen :"
230   gotoxy 9,5:input"X-max : ",xo
240   gotoxy 9,6:input"X-min : ",xu
250   if xo<=xu then gotoxy 9,5:print spc(20):gotoxy 9,6:print spc(20):goto 230
260   ax=abs(xo-xu)
270   gotoxy 12,9:print" + -> Gleiche Grenzen"
280   gotoxy 9,8:input"Y-max : ",yo$
290   gotoxy 12,9:print spc(30)
300   if yo$="+" then yo=xo:yu=xu:goto 350
310   yo=val(yo$)
320   gotoxy 9,9:input"Y-min : ",yu
330   if yo<=yu then gotoxy 9,8:print spc(20):gotoxy 9,9:print spc(20):goto 270
340   goto 370
350   gotoxy 9,8:print"Y-max :";yo;"       "
360   gotoxy 9,9:print"Y-min :";yu;"           "
370   yy=(yo-yu):gotoxy 8,11:print"Schrittweite"
380   xx=(xo-xu):gotoxy 9,12:print"1 - Standart"
390   gotoxy 9,13:print"2 - Mastab 1:1"
400   gotoxy 9,14:print"3 - Mastab Variabel"
410   gotoxy 9,15:input"Mastab Nr.  ",va
420   if va<1 or va>3 then gotoxy 9,15:print spc(20):goto 410
430   on va gosub STANDART,MAST11,MVARIABEL ' Grenzwert + Skalirungs Berechnung
440   goto 580 ' Sprung zum Plott-Programm --------------------------
450   STANDART:dx=xx/400:dy=yy/300:gx=400:gy=300:vy=(3*xx)/(4*yy):vx=1
460   if vy<1 then vy=1:vx=(4*yy)/(3*xx)
470   return
480   MAST11:vx=1:vy=1
490   if xx*3>yy*4 then dx=xx/400:dy=dx:gx=400:gy=abs(yy/dx):return
500   dx=yy/300:dy=dx:gx=abs(xx/dx):gy=300
510   return
520   MVARIABEL:gotoxy 9,12:print"Verhaeltnis X*A - Y*B":gotoxy 9,15:print spc(20)
530   gotoxy 9,13:print spc(20):gotoxy 9,14:print spc(20)
540   gotoxy 9,14:input"X ",vx:gotoxy 11,14:input":  Y ",vy:vv=vx/vy
550   if xx*3*vv>yy*4 then goto 560 else goto 570
560   dx=xx/400:dy=dx/vv:gy=abs(yy/dx)/vv:gx=400:return
570   dx=(yy/300)/vv:dy=dx:gx=abs(xx/dx):gy=300:return
580   ' ##############################################################
590   clearw 2:gosub INIT ' Zeichnen X und Y Achse--------------------
600   if yo>0 and yu<0 then ny=gy-abs((0-yu)/yy)*gy:linef 5,ny+20,gx+5,ny+20 ' xA
610   if yo<0 or yu>=0 then ny=gy
620   if xo>0 and xu<0 then nx=abs((0-xu)/xx)*gx:linef nx+5,20,nx+5,gy+20 'yA
630   if xo<0 or xu>0 then nx=0
640   linef 5,20,5,gy+20:linef gx+5,20,gx+5,gy+20
650   linef 5,20,gx+5,20:linef 5,gy+20,gx+5,gy+20
660   s(1)=.1:s(2)=.25:s(3)=.5:s(4)=1:s(5)=2:s(6)=5 ' Skalierung -------------
670   s(7)=10:s(8)=20:s(9)=50:s(10)=100
680   for i=1 to 10:skx=xx/s(i):sky=yy/s(i)
690   skx=gx/skx:sky=gy/sky:if skx<=40 then kx=i
700   if sky<=40 then ky=i
710   next:if xu<=0 then v=0 else v=1
720   skx=int(xu/s(kx)):skx=s(kx)*(skx+v):x=skx
730   while x<=xo ' X - Achse skalieren ------------------------------
740   snx=abs((x-xu)/xx)*gx:linef 5+snx,ny+18,5+snx,ny+22:x=x+s(kx)
750   wend
760   if yu<=0 then v=0 else v=1
770   sky=int(yu/s(ky)):sky=s(ky)*(sky+v):y=sky
780   while y<=yo ' Y - Achse skalieren -------------------------------
790   sny=gy-abs((y-yu)/yy)*gy:linef nx+3,sny+20,nx+7,sny+20:y=y+s(ky)
800   wend
810   gotoxy 25,4:print"Grenzen des Graphen :" ' ----------------------
820   gotoxy 27,5:print"X-max : ";xo:gotoxy 25,9:print"Skalierung der Achsen :"
830   gotoxy 27,6:print"X-min : ";xu:gotoxy 27,10:print chr$(127);" X   : ";s(kx)
840   gotoxy 27,7:print"Y-max : ";yo:gotoxy 27,11:print chr$(127);" Y   : ";s(ky)
850   gotoxy 27,8:print"Y-min : ";yu:linef 430,63,590,63
860   gotoxy 24,2:print"F(x)=";funkt$:linef 430,249,590,249
870   gotoxy 25,12:print"Mastab :":gotoxy 25,13:print"X * ";
880   print using "###.##";vx;:print" ~ Y * ";:print using "###.##";vy
890   px=5:x=xu:px=4:ay=ny:ax=5 ' Funktions Plott --------------
900   gosub FUNKTION:py=gy-abs((y-yu)/yy)*gy+20:px=px+1
910   x=x+dx:if x-dx>=xo then 990
920   if y<yu then py=gy+20
930   if y>yo then py=20
940   if ay=20 and py>=gy+20 then ay=py
950   if ay=gy+20 and py<=20 then ay=py
960   linef ax,ay,px,py:ay=py:ax=px
970   goto 900
980   ' ######################################################
990   gotoxy 25,15:print"1 - Neue Funktion"
1000  gotoxy 25,16:print"2 - Neue Grenzen"
1010  gotoxy 25,17:print"3 - Gitter"
1020  gotoxy 25,18:input"4 - Ende        ",ad
1030  if ad<1 or ad>4 then goto 990
1040  if ad=1 then clearw 2:gosub INIT:goto 100
1050  if ad=2 then clearw 2:gosub INIT:goto 170
1060  if ad=3 then gosub GITTER:goto 980
1070  if ad=4 then out 4,8:end
1080  FUNKTION:
1090  ' y=
1100  return
1110  EINGABEfx: ' Eingabe der Funktion �ber Floppy
1120  gotoxy 14,13:input"F(x)=",funkt$
1130  dat$="FUNKTION.BAS"
1140  open "O",#1,dat$
1150  print #1,"1090 y=";funkt$
1160  close:gotoxy 14,13:print spc(40)
1170  chain merge dat$,1190
1180  kill dat$
1190  return
1200  GITTER:if xu<=0 then v=0 else v=1 ' Gitter ---------------------------
1210  skx=int(xu/s(kx)):skx=s(kx)*(skx+v):x=skx
1220  while x<=xo ' X - Achse rastern --------------------------------
1230  snx=abs((x-xu)/xx)*gx:linef 5+snx,20,5+snx,gy+20:x=x+s(kx)
1240  wend
1250  if yu<=0 then v=0 else v=1
1260  sky=int(yu/s(ky)):sky=s(ky)*(sky+v):y=sky
1270  while y<=yo ' Y - Achse rastern ---------------------------------
1280  sny=gy-abs((y-yu)/yy)*gy:linef 5,sny+20,gx+5,sny+20:y=y+s(ky)
1290  wend
1300  linef 5,ny+21,gx+5,ny+21:linef nx+4,20,nx+4,gy+20
1310  gotoxy 25,18:print spc(20):return
1320  INFO: ' ---- INFO--------------------------------
1330  fullw 2:clearw 2:gosub INIT
1340  linef 5,20,610,20:linef 5,320,610,320
1350  linef 5,20,5,320:linef 610,20,610,320
1360  linef 15,30,600,30:linef 15,310,600,310
1370  linef 15,30,15,310:linef 600,30,600,310
1380  color 1,1,1,2,2:fill 305,319
1390  gotoxy 2,2:print string$(31,chr$(3))" Info ";string$(31,chr$(4))
1400  linef 37,58,574,58
1410  gotoxy 3,4
1420  print"Dieses Programm ist ein einfacher Funktions-Drucker. Die Ausgabe"
1430  gotoxy 3,5
1440  print"erfolgt auf dem Bilschirm. Zun�chst  mu� die Funktion eingegeben"
1450  gotoxy 3,6
1460  print"werden. Die Eingabe erfolgt ueber das Programm, jedoch  wird das"
1470  gotoxy 3,7
1480  print"Disketten-Laufwerk benutzt, weswegen die Diskette nicht schreib-"
1490  gotoxy 3,8
1500  print"gesch�tzt sein darf. Auch ist dieses Programm  nur  auf Hochauf-"
1510  gotoxy 3,9
1520  print"loesende Graphik lauffaehig. Zudem wird die Maus  ausgeschaltet,"
1530  gotoxy 3,10
1540  print"kann aber falls Sie einen BREAK [Contrl-G] machen mit dem Befehl"
1550  gotoxy 3,11
1560  print">out 4,8< wieder eingeschaltet werden. Auch mu� der Grafikbuffer"
1570  gotoxy 3,12
1580  print"aktiviert sein, da sonst bei einem Error wie z.B. Division durch"
1590  gotoxy 3,13
1600  print"Null das Funktionbild verloren geht.Pi und e sind als Konstanten"
1610  gotoxy 3,14
1620  input"zur Funktionsparameter-Verwendung definiert.               ",a$
1630  color 1,1,1,1,1:clearw 2:return
