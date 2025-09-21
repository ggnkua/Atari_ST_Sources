10    goto begin
20    b1=-99999:ss=0:ht=0:b5=0:td(1)=d(0):td(2)=d(1):td(3)=d(0):td(4)=d(0)
30    for i=1 to 4:tm(i)=24:next i:nm=mm:j=-b(0):if j>mm then j=mm
40    if j>0 then for i=1 to j:tm(i)=26:next i
50    for i=0 to 25:tb(i)=b(i):next i:mt=0
60    tm=me(0):for i=1 to nm:if tm(i)<26 then 100
70    if tb(25-td(i))>1 then 720
80    if tb(25-td(i))=1 then tb(25)=tb(25)+1:tb(25-td(i))=0
90    tb(25-td(i))=tb(25-td(i))-1:tb(0)=tb(0)+1:goto 230
100   if i>1 then if tm(i)+ss>tm(i-1) then 120
110   if tb(tm(i))<0 then 140
120   tm(i)=tm(i)-1:if tm(i)>0 then 100
130   goto 670
140   if tm(i)-td(i)<1 then 180
150   if tb(tm(i)-td(i))>1 then 120
160   if tb(tm(i)-td(i))=1 then tb(25)=tb(25)+1:tb(tm(i)-td(i))=0
170   tb(tm(i)-td(i))=tb(tm(i)-td(i))-1:tb(tm(i))=tb(tm(i))+1:goto 230
180   for j=7 to 24:if tb(j)<0 then 670
190   next j:if tm(i)-td(i)=0 then 220
200   jm=tm(i)+1:for j=jm to 6:if tb(j)<0 then 670
210   next j
220   tb(tm(i))=tb(tm(i))+1:tm=tm-1
230   mt=mt+td(i):next i
240   if mt<ht then 720
250   ht=mt:mi=0:bt=0:for i=1 to 24
260   if tb(i)>0 then if i<19 then mi=mi+tb(i)*int((22-i)/4)/2
270   if tb(i)<0 then if i>6 then mi=mi+tb(i)*int((i-3)/4)/2
280   next i:mi=mi+3*(tb(0)+tb(25)):if tb(25)>1 then mi=mi+1
290   ct=0:if tb(25)-tb(0) then ct=1:goto 340
300   for i=24 to 2 step -1:if tb(i)<0 then 320
310   next i:goto 340
320   for j=i-1 to 1 step -1:if tb(j)>0 then ct=1:goto 340
330   next j
340   bl=0
350   if ct=0 then bt=0:goto 420
360   hp=0:for i=1 to 24
370   if tb(i)=-1 then bt=bt-int((30-i)/4)/2:if i<7 then mi=mi-1
380   if i>18 and b(i)>1 then hp=hp+1
390   next i:hp=hp*hp+(hp=0):bt=int(bt*hp/25+0.5)/2
400   for i=1 to 4:b=0:for j=i to i+5:b=b-(tb(j)<-1):next j
410   b=int(b*b/4):bl=bl-(b>bl)*(b-bl):next i
420   if mi+bl+bt<b1+b2+b3 then 630
430   tc=0:bo=0:ds=0:lo=1:for i=1 to 24
440   if i>6 then if tb(i)<0 then tc=tc+tb(i)*int((i-1)/6):bo=bo+i*tb(i)
450   if tb(i)<0 then ds=ds+1:lo=lo*(0-tb(i))
460   next i
470   if b1=-99999 then 600
480   if bl+mi+bt>b2+b1+b3 then 600
490   if tm<b9 then 600
500   if tm>b9 then 630
510   if tc<b4 then 630
520   if tc>b4 then 600
530   if ds<b6 then 630
540   if ds>b6 then 600
550   if bo<b7 then 630
560   if bo>b7 then 600
570   if lo<b8 then 630
580   if lo>b8 then 600
590   goto 630
600   b5=nm:b2=bl:b3=bt:b4=tc:b1=mi:b9=tm:b6=ds:b7=bo:b8=lo:j=1-(b5<mm)
610   for i=1 to b5:sm(j)=tm(b5+1-i)
620   sd(j)=td(b5+1-i):j=j+1:next i
630   if tm(nm)=26 then 720
640   tm(nm)=tm(nm)-1
650   if tm(nm)>0 then 50
660   i=nm
670   for j=i to nm:tm(j)=24:next j:i=i-1
680   if i=0 then 720
690   if tm(i)=26 then 720
700   if tm(i)>1 then tm(i)=tm(i)-1:goto 50
710   goto 670
720   if d(1)=d(0) then 760
730   if ss=1 then 750
740   ss=1:td(1)=d(1):td(2)=d(0):goto 50
750   ss=0:td(1)=d(0):td(2)=d(1)
760   nm=nm-1:if nm=0 then 780
770   if ht=0 then 50
780   if b5<mm then sm(1)=27
790   ms=mm:if b5<mm then ms=b5+1
800   m=sm(ms):d=sd(ms):ms=ms-1:if m=26 then m=0
810   if m=27 then goto roll
820   mpt=m:gosub mark
830   goto 1180
840   os=1:if d(0)=2 and d(1)=6 then d(0)=6:d(1)=2:os=2
850   sm(2)=op(0,6*d(0)+d(1)-7):sm(1)=op(1,6*d(0)+d(1)-7)
860   sd(2)=d(0):sd(1)=d(1):if os=2 then d(0)=2:d(1)=6
870   if mm=4 then sm(3)=sm(1):sd(3)=sd(1):sm(4)=sm(2):sd(4)=sd(2)
880   if b(sm(1)-sd(1))>1 then 50
890   if b(sm(2)-sd(2))>1 then 50
900   ms=mm:goto 800
910   roll:for di=0 to 1:if d(di)>0 then gosub undice
920   next di:d(0)=int(6*rnd(1)+1):d(1)=int(6*rnd(1)+1):pl=-pl:mm=2
930   if d(0)=d(1) then mm=4
940   nextm:gosub dice:pc=1:if pl=1 then pc=0:goto getmove
950   if ms>0 then 800
960   if os=0 then 840 else 20
970   getmove:m=0:gosub mouse:if mpt=26 then 1320
980   if (b(25)>0 and mpt<>25) or mpt=0 or b(mpt)<1 then getmove
990   m=mpt:gosub mark
1000  gosub mouse:if mpt=m then gosub unmark:goto getmove
1010  if mpt>24 then 1000
1020  if mpt=0 then mpt=25
1030  if b(mpt)<-1 then 1000
1040  if m=25 then d=mpt else d=mpt-m
1050  if d<1 or d>6 then 1000
1060  di=-1:if d=d(0) then di=0:goto 1110
1070  if d=d(1) then di=1:goto 1110
1080  if mpt=25 and d(0)>d then d=d(0):di=0
1090  if mpt=25 and d(1)>d then d=d(1):di=1
1100  if di=-1 then 1000
1110  if m=25 then 1180
1120  if m+d<25 then 1180
1130  for i=1 to 18:if b(i)>0 then 1000
1140  next i
1150  if m+d=25 then 1180
1160  for i=19 to m-1:if b(i)>0 then  1000
1170  next i
1180  if d=d(0)then di=0 else di=1
1190  if mm<3 then gosub undice
1200  mm=mm-1:po=m:mn=abs(b(po)):gosub takeman:d=d*pl:b(m)=b(m)-pl
1210  if m=0 or m=25 then m=25-m
1220  if m+d<1 or m+d>24 then 1290
1230  if b(m+d)<>-pl then 1270
1240  po=m+d:mn=1:pc=1-pc
1250  gosub takeman:br=0:if pl=-1 then br=25
1260  b(br)=b(br)-pl:b(m+d)=0:po=br:mn=abs(b(br)):gosub putman:pc=1-pc
1270  b(m+d)=b(m+d)+pl:po=m+d:mn=abs(b(po))
1280  gosub putman:goto 1300
1290  me((pl+1)/2)=me((pl+1)/2)-1:if me(0)=0 or me(1)=0 then 1440
1300  if mm=0 then roll
1310  goto nextm
1320  if b(25)=0 then 1350
1330  for i=0 to 1:if d(i)>0 and b(d(i))>-2 then getmove
1340  next i:goto roll
1350  for i=0 to 1:if d(i)=0 then 1380
1360  for j=1 to 24-d(i):if b(j)>0 and b(j+d(i))>-2 then getmove
1370  next j
1380  next i:for j=1 to 18:if b(j)>0 then roll
1390  next j:for i=0 to 1:if d(i)>0 and b(25-d(i))>0 then getmove
1400  next i:for i=19 to 24:if b(i)>0 then 1420
1410  next i:goto roll
1420  for j=0 to 1:if d(j)>0 and d(j)>25-i then getmove
1430  next j:goto roll
1440  for di=0 to 1:if d(di)>0 then gosub undice
1450  next di
1460  gotoxy 2,8:wm=2:gosub setwm
1470  if me(0)=0 then ? "I win "; else ? "You win ";
1480  if me(0)<15 and me(1)<15 then 1520
1490  if b(0)<>0 or b(25)<>0 then print "BACKGAMMON";:goto 1520
1500  for i=1 to 6:if b(i)>0 or b(25-i)<0 then print "BACKGAMMON";:goto 1520
1510  next i:print "GAMMON";
1520  ?:gotoxy 38,8
1530  ? "Click left button to play again.":gotoxy 38,9
1540  ? "Click right button to end.":wm=1:gosub setwm
1550  poke systab+24,0
1560  if 3 and peek(9239) then 1560
1570  if 1 and peek(9239) then clear:goto 1760
1580  if 2 and peek(9239) then end else 1570
1590  begin:closew 0:closew 1:closew 3:fullw 2:clearw 2:width 76
1600  if peek(systab)=2 then 1630
1610  gotoxy 0,0:?"Please goto medium resolution.
1620  ?:input "Press RETURN to exit to BASIC.",x$:end
1630  te=12:gosub sette:gotoxy 24,1:? "ST BACKGAMMON by TCB":?
1640  te=0:gosub sette
1650  ?" You will play the white pieces and move clockwise from the upper left.
1660  ?:? " To move a piece, click on the piece to be moved and then";
1670  ?" click on the":?" destination point."
1680  ?:?" To bear off use the grey bar on the left as the destination.
1690  ?:?" If you do not have a valid move click on the dice.
1700  ?:?" To redraw the board click in the clear area above the OUTPUT window.
1710  gotoxy 17,17:? "Click left mouse button to start.";
1730  if peek(9239) and 1 then 1730
1740  v=v+1:if not peek(9239) and 1 then 1740
1750  v=rnd(-v)
1760  poke systab+24,1
1770  dim b(25),tb(25),me(1),op(1,35),sm(4),sd(4),d(1),td(4),tm(4)
1780  for i=0 to 25:b(i)=0:next i
1790  b(1)=2:b(6)=-5:b(8)=-3:b(12)=5:b(13)=-5:b(17)=3:b(19)=5:b(24)=-2
1800  me(0)=15:me(1)=15
1810  ms=0:os=0
1820  restore:for i=0 to 35:read x,y:op(0,i)=x:op(1,i)=y:next i
1830  gosub board
1840  for i=0 to 1:d(i)=int(6*rnd(1)+1):next i:if d(0)=d(1) then 1840
1850  pl=-1:mm=2:if d(0)>d(1) then pl=1
1860  goto nextm
1870  data 8,6,6,13,6,8,6,13,6,13,8,13
1880  data 13,6,13,6,13,13,6,8,13,13,0,0
1890  data 8,6,13,13,13,8,13,13,8,13,13,13
1900  data 13,6,8,6,13,13,13,9,13,13,13,13
1910  data 13,6,13,13,13,8,13,13,13,8,13,13
1920  data 13,8,13,7,13,13,13,13,13,13,24,13
1930  mouse:poke systab+24,0
1940  if 1 and peek(9239) then 1940
1950  if 1 and peek(9239) then xc=peek(9244)-1:yc=peek(9246)-22 else 1950
1960  if yc<0 or yc>166 or xc>607 then goto rdraw
1970  if xc<8 then mpt=0:goto 2020
1980  if xc>289 and xc<326 then mpt=25:goto 2020
1990  if yc>70 and yc<96 then mpt=26:goto 2020
2000  if xc>325 then xc=xc-36
2010  xc=xc-8:ptx=xc\47:if yc>95 then mpt=24-ptx else mpt=ptx+1
2020  poke systab+24,1:return
2030  rdraw:poke systab+24,1:gosub board:gosub dice
2040  pc=0:if m>0 then gosub mark
2050  goto mouse
2060  board:clearw 2
2070  color 1,1,1,4,2:linef 290,0,290,166:linef 325,0,325,166
2080  linef 7,0,7,166:fill 0,0:fill 291,0
2090  color 1,3,1,0,1:fill 8,0:fill 326,0
2100  for po=1 to 24
2110  gosub pxy
2120  color 1,2,1,pi,2:linef x-23,y1,x,y2:linef x,y2,x+23,y1:fill x,(y1+y2)/2
2130  next po
2140  for po=0 to 25
2150  if b(po)=0 then 2180
2160  pc=1+(b(po)>0)
2170  for mn=1 to abs(b(po)):gosub putman:next mn
2180  next po
2190  return
2200  pxy:
2210  if po<13 then pox=po-1 else pox=24-po
2220  x=31+pox*47:if pox>5 then x=x+36
2230  if po=0 or po=25 then x=307
2240  if po<13 then y1=0:y2=70:yd=1 else y1=166:y2=96:yd=-1
2250  y0=y1+yd*6
2260  if po mod 2 then pi=4 else pi=8
2270  return
2280  mxy:gosub pxy
2290  mx=x+3*(mn-1)\5
2300  my=y0+yd*13*((mn-1) mod 5)
2310  return
2320  putman:gosub mxy
2330  color 1,pc,1-pc,0,1:pcircle mx,my,14:circle mx,my,14
2340  return
2350  takeman:
2360  gosub mxy
2370  color 1,3,1,0,1:pcircle mx,my,14
2380  if po=0 or po=25 then color 1,1,1,4,2:goto 2400
2390  color 1,2,1,pi,2:linef x-23,y1,x,y2:linef x,y2,x+23,y1
2400  fill mx,my
2410  if mn>1 then for mn=1 to mn-1:gosub putman:next mn
2420  return
2430  mark:mn=abs(b(mpt)):po=mpt:gosub mxy
2440  color 1,3,1,0,1:fill mx,my
2450  return
2460  unmark:po=mpt:mn=b(mpt):gosub putman:return
2470  dice:if pl=1 then dx=92 else dx=412
2480  for dj=0 to 1:xd=dx+dj*64:if d(dj)=0 then 2510
2490  color 1,0,1,0,1:gosub outline:color 1,1,1,0,1
2500  on d(dj) gosub one,two,three,four,five,six
2510  next dj
2520  return
2530  outline:
2540  linef xd,73,xd+48,73:linef xd+48,73,xd+48,93
2550  linef xd+48,93,xd,93:linef xd,93,xd,73
2560  fill xd+1,74:return
2570  one:pcircle xd+24,83,4:return
2580  two:pcircle xd+8,77,4:pcircle xd+40,89,4:return
2590  three:gosub one:gosub two:return
2600  four:gosub two:pcircle xd+8,89,4:pcircle xd+40,77,4:return
2610  five:gosub one:gosub four:return
2620  six:gosub four:pcircle xd+8,83,4:pcircle xd+40,83,4:return
2630  undice:
2640  if pl=1 then dx=92 else dx=412
2650  xd=dx+di*64
2660  color 1,3,1,0,1:gosub outline
2670  on d(di) gosub one,two,three,four,five,six
2680  fill xd,73
2690  d(di)=0
2700  return
2710  sette:poke contrl,106:poke contrl+2,0:poke contrl+6,1
2720  poke intin,te:vdisys(1):return
2730  setwm:poke contrl,32:poke contrl+2,0:poke contrl+6,1
2740  poke intin,wm:vdisys(1):return
                     