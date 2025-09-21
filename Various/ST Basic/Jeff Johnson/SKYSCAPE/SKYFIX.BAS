100   rem ** Skyscape ** Compute Dec 1985 ** Atari ST version by Jeff Johnson
101   rem ** Compute didn't want to publish this ST version so I'm
102   rem ** putting it in the public domain.  Enjoy it.  Jeff.
110   clearw(2):fullw(2):poke contrl,14:poke contrl+2,0
120   poke contrl+6,4:poke intin,3:poke intin+2,0
130   poke intin+4,0:poke intin+6,1000:vdisys
140   gosub 3100:gotoxy 20,16:color 2:? "Press any key to continue!";:i$=input$(1)
150   color 1
160   d$="000031059090120151181212243273304334":k1=1440:dim hc%(22)
165   mm$="041079040"
170   m$="286317345011041072102133164194225255":d$(1)="S":d$(2)="N":es=93
180   a$="JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC":oo$="OUT OF RANGE!":dg$=chr$(248)
190   md$="312831303130313130313031":d9=atn(1)/45
200   read ee:read m9:dim p(6,6),screen%(40,14)
210   def fnr(x)=int(x*10+.5)/10
220   def fns(x)=int(x*100+.5)/100
230   for y=1 to 2:for x=1 to 6:read p(x,y):next:next:y=0
240   for x=1 to 6:read p$(x),p(x,3):next
250   for x=1 to 7:read pp(x):next
260   j$="SATSUNMONTUEWEDTHUFRI":for x=1 to 12:read f$
270   cc$=cc$+"      "+f$:next:cc$=cc$+cc$:f$=right$(cc$,9):cc$=f$+cc$
280   for x=1 to 8:read ph$(x):next
290   for x=1 to 22:read hc%(x):next:goto 1200
300   cc=mt-720:if cc<0 then cc=cc+k1
310   cc=cc/120:cd=cc-int(cc):cc=int(cc):cd=int(cd*7+.2):cc=81-(cc*7+cd)
320   gosub 2440:if ll<0 then gosub 2980
330   print cd$:return
340   gosub 3060
350   gotoxy sl,4:? "** DAY'S SKY **":gotoxy sl,5:? "--------------"
360   gotoxy sl,7:? "INPUT THE TIME:":gotoxy sl,8:? "--------------"
370   gotoxy sl,9:? "HOUR (0-23)";:gosub 2810:if i$<>"" then t1=val(i$)
380   if t1<0 or t1>23 then gotoxy sl+3,10:? oo$:goto 370
390   gotoxy sl,11:? "MINUTE (0-59)";:gosub 2810:if i$<>"" then t2=val(i$)
400   if t2<0 or t2>59 then gotoxy sl,12:? oo$:goto 390
410   r$=right$(str$(t1),2):t$=str$(t2):if t2<10 then t$="0"+right$(t$,1)
420   t$=right$(t$,2)
430   gotoxy sl,14:? "TIME-- "r$":"t$
440   gotoxy 20,17:gosub 2590:if i$="N" or i$="n" then 340
450   color 1:clearw(2):t3=t1*60+t2+aa-720:if t3<0 then t3=t3+k1
460   if t3>k1 then t3=t3-k1
470   mt=t3-360:if mt<0 then mt=mt+k1
480   pt=t3+360:if pt>k1 then pt=pt-k1
490   poke contrl,32:poke contrl+2,0:poke contrl+6,1:rem trasparent write
500   poke intin,2:vdisys
510   gotoxy 5,0:? "--DAY'S SKY--  ";:gosub 2190:tim$="  "+r$+":"+t$
520   gotoxy 0,0:?:gotoxy 39,0:? tim$
530   for i=0 to 13:for j=0 to 39:screen%(j,i)=0:next:next
540   c=3:color 1:tm=val(r$+"."+t$):if tm<6 or tm>18 then c=1:color 3
550   poke contrl,25:poke contrl+2,0:poke contrl+6,1:rem set fill color
560   poke intin,c:vdisys
570   poke contrl,9:poke contrl+2,5:poke contrl+6,0:rem filled rectangle
580   restore 3040:for i=0 to 9:read zz:poke ptsin+i*2,zz:next
590   vdisys
600   xx=7+lc:gotoxy 5,xx
610   ? " - - - - - - - - - - - - - - - - - - - - - - "
620   poke contrl,25:poke contrl+2,0:poke contrl+6,1:rem change color
630   poke intin,2:vdisys
640   poke contrl,9:poke contrl+2,5:poke contrl+6,0:rem filled rectangle
650   restore 3050:for i=0 to 9:read zz:poke ptsin+i*2,zz:next
660   vdisys
670   gotoxy 5,15:color 1:gosub 300:gotoxy 5,16:color 0:if ll<0 then 700
680   if ll>24 then ? "E"spc(21)"S"spc(21)"W":goto 720
690   ? "UP-NORTH       ----OVERHEAD        DOWN-SOUTH":goto 720
700   if ll<-24 then ? "E"spc(21)"N"spc(21)"W":goto 720
710   ? "UP-SOUTH       ----OVERHEAD        DOWN-NORTH"
720   t4=aa:gosub 1100:y8=888
730   if y9=999 then 800
740   gosub 2820:y8=y9:if a1<0 then 800
750   if u9>17 or u9<4 then 800
760   u9=u9-3:y9=y9+15
770   gotoxy 0,0:?
780   screen%(54-y9,u9-2)=1
790   color 0:gotoxy 59-y9,u9:?chr$(42)
800   t4=aa+m2*k1:if t4>k1 then t4=t4-k1
810   color 1:if tm<6 or tm>18 then color 3
820   gosub 1100:if y9=999 then 880
830   mm=int(m1/9.83333)+1:gosub 1180
840   gosub 2820:if u9>17 or u9<4 then 880
850   u9=u9-3:y9=y9+15
860   screen%(54-y9,u9-2)=1
870   gotoxy 59-y9,u9:? chr$(mm)
880   for x=1 to 7:if x=7 then gosub 2710
890   if right$(b$,5)="COMET" and x=7 then 930
900   if x=7 then 1000
910   t4=p(x,6):gosub 1100:if y9=999 then 1000
920   u9=sin((p(x,6)/4)/(1/d9)):u9=int(-3*u9+.5)
930   gosub 2830
940   if u9<4 or u9>17 then 1000
950   u9=u9-3:y9=y9+15
960   z=screen%(54-y9,u9-2)
970   if z then u9=u9+sgn(ll)+(ll=0):goto 960
980   screen%(54-y9,u9-2)=1
990   gotoxy 59-y9,u9:? chr$(pp(x));
1000  rem dummy line
1010  next:color 1:gotoxy 40,17:? chr$(42);:gotoxy 0,0:?
1020  gotoxy 1,17:color 3:for x=1 to 6:?chr$(pp(x));p$(x);" ";:next
1030  ? " *SUN )O(MOON";
1040  gotoxy 0,0:?:gotoxy 40,17:? "ONEW MOON+SUN ";b$;:gotoxy 0,0:?
1050  color 2:gotoxy 47,15:? "T- NEW TIME, D- DATE,"
1060  gotoxy 47,16:? "P- P. TABLE, L- LAT";:sl=49
1070  poke contrl,32:poke contrl+2,0:poke contrl+6,1:rem normal write
1080  poke intin,1:vdisys
1090  color 1:goto 2360
1100  y9=999:if mt<pt then 1140
1110  if t4<mt and t4>pt then return
1120  if t4<mt or t4>k1 then t4=t4+k1
1130  goto 1150
1140  if t4<mt or t4>pt then return
1150  y9=int((t4-mt)/18+.5):if y9=40 then y9=39
1160  return
1170  u9=sin((t4/4)/(1/d9)):u9=int(-3*u9+.5):return
1180  mm=val(mid$(mm$,3*mm-2,3)):if l<0 and mm<>81 then mm=abs(mm-81)
1190  return
1200  color 1:clearw(2):gotoxy 15,0:? "************** SKYSCAPE **************"
1210  gotoxy 10,2:? "DATE INPUT":s1=0
1220  gotoxy 10,3:? "----------":if y<>0 then gotoxy 38,2:gosub 2190
1230  gotoxy 4,5:? "YEAR";:gosub 2810:if i$<>"" then y=val(i$)
1240  if y<1977 then ? "MUST BE AFTER 1977":goto 1230
1250  gosub 2260:gotoxy 4,7:? "MONTH (1-12)";:gosub 2810:if i$<>"" then m=val(i$)
1260  if m<1 or m>12 then ? oo$:goto 1250
1270  di=val(mid$(md$,2*m-1,2)):di=di-(m=2)*ly:di$=str$(di)
1280  gotoxy 4,9:? "DAY (1-"di$")";:gosub 2810:if i$<>"" then d=val(i$)
1290  if d<1 or d>di then ? oo$:goto 1280
1300  h$=mid$(a$,(m*3)-2,3):gotoxy 4,11:? "LATTITUDE (0-90)";:gosub 2810
1310  if i$<>"" then ll=val(i$)
1320  gosub 2860
1330  if abs(ll)>90 then ? oo$:goto 1300
1340  d1=val(mid$(d$,(m*3)-2,3))+d:gosub 2300:if m>2 then d1=d1+ly:y1=y1+ly
1350  s=0:gosub 1930:gotoxy 38,2:gosub 2190:gotoxy 38,3:? "----------------------
1360  gotoxy 20,17:gosub 2590:if i$="N" or i$="n" then 1200
1370  gotoxy 20,17:? "                                  ";
1380  d2=val(mid$(m$,(m*3)-2,3))+d:gosub 2300:if m>2 then d1=d1+ly:y1=y1+ly
1390  d3=d2-185:if m=3 and d<20 then d2=d2+ly:d3=d3+ly
1400  if d3<=0 then a=180*d2/185:goto 1420
1410  a=(180*d3/(180+zy))+180
1420  if a<180 then s=23.43333*sin(d9*d2*180/185)
1430  if a>180 then s=-23.43333*(sin(d9*d3))
1440  if a>=360 then a=a-360
1450  a=fnr(a)
1460  s=fnr(s):a1=(sgn(ll)-(ll=0))*s+90-abs(ll):a1=fnr(a1):gosub 1880:gosub 1830
1470  w=1-(ll<0):if a1>90 then a1=180-a1:w=3-w
1480  gotoxy 0,0:?
1490  gotoxy 32,6:? "DAY OF THE YEAR-----------    ";d1
1500  gotoxy 32,7:? "SUN'S GEOCENTRIC ANGLE----    ";str$(a);dg$
1510  gotoxy 32,8:? "SUN'S DECLINATION---------    ";str$(s);dg$
1520  gotoxy 32,9:? "SUN'S ALTITUDE AT NOON----    ";str$(a1);dg$;d$(w)
1530  gotoxy 32,10:? "SUN'S RIGHT ASCENSION-----    ";a3$
1540  gotoxy 32,11:? "R.A. AT 9:00PM------------    ";a5$
1550  gotoxy 32,12:? "MOON'S AGE----------------    ";str$(m1);"DY"
1560  gotoxy 32,13:? "MOON'S ELONGATION---------    ";str$(m8);dg$;l$
1570  gotoxy 32,14:? "MOON'S PHASE - "ph$(m3)
1580  gotoxy 20,17:? "-P- PLANET TABLE, -D- NEW DATE";:goto 2360
1590  color 1:clearw(2):gotoxy 20,0:? "SKYSCAPE-   ";:gosub 2190:s1=1
1600  gotoxy 10,1:?" "
1610  gotoxy 10,2:? "** PLANET TABLE **":gotoxy 10,3:? "------------------"
1620  gotoxy 2,4:? "PLANET   DIST.  ANG. W/ SUN     R.A."
1630  gotoxy 2,5:? "------------------------------------"
1640  for x=1 to 6:a2=y1/p(x,2)-int(y1/p(x,2)):q3=1
1650  a2=(a2*360)+p(x,1):if a2>360 then a2=a2-360
1660  e=180+a:if e>360 then e=e-360
1670  e1=abs(e-a2):if e1>180 then e1=360-e1
1680  gosub 1950:e1=e1*d9:p5=p(x,3):if x=3 then gosub 2420
1690  p(x,4)=sqr(1+p5^2-2*p5*cos(e1)):xx=((p5^2-1-p(x,4)^2)/(-2*p(x,4)))
1700  p(x,5)=-atn(xx/sqr(-xx*xx+1))+atn(1)*2:p(x,4)=int(p(x,4)*93+.5)
1710  p(x,5)=p(x,5)/d9
1720  p(x,5)=fns(p(x,5)):q1$=str$(p(x,4)):q2$=str$(p(x,5))
1730  q1=len(q1$):q2=len(q2$):gosub 2050
1740  gotoxy 2,x+5:? p$(x);tab(16-q1);q1$;tab(26-q2);q2$;:if q3=-1 then ? dg$"W";
1750  if q3=1 then ? dg$"E";
1760  gosub 2100:q4$=str$(q4):q5$=str$(q5):if q5<10 then q5$="0"+right$(q5$,1)
1770  q5$=right$(q5$,2):q4$=q4$+":"+q5$:z=len(q4$)
1780  ? tab(30);qq$;tab(38-z);q4$:next:gotoxy 2,13:? "* - VISIBLE AT 9 P.M."
1790  gotoxy 2,14:? "SUN'S R.A. -------";spc(q8);a3$
1800  gotoxy 2,15:? "R.A. at 9:00PM ---";spc(q9);a5$
1810  sl=46:gotoxy 20,17:? "-S- FOR DAY'S SKY, -D- FOR NEW DATE";
1820  gotoxy 0,0:?:goto 2360
1830  a2=k1*a/360:if a2>k1 then a2=a2-k1
1840  a3=int(a2/60):a4=a2-a3*60:a5=a3+9:if a5>23 then a5=a5-24
1850  a4=int(a2-a3*60+.5):if a4=60 then a4=0:a3=a3+1
1860  if a3=24 then a3=0
1870  aa=a3*60+a4:goto 2220
1880  m1=((y1/m9)-int(y1/m9))*m9+10:if m1>m9 then m1=m1-m9
1890  gosub 2620:m8=360*m2:if m8>180 then l$="W"
1900  if m8<=180 then l$="E"
1910  if m8>180 then m8=360-m8
1920  m1=int(m1+.5):m8=fnr(m8):return
1930  yy=int(7*(y1/7-int(y1/7))+.2):if yy=0 then yy=7
1940  k$=mid$(j$,(yy*3)-2,3):return
1950  q3=0:q1=e+180:if q1>360 then 1990
1960  if a2>e and a2<q1 then 1980
1970  q3=1:return
1980  q3=-1:return
1990  q1=q1-360:if a2<=360 and a2>e then 1980
2000  if q3<>0 then return
2010  if a2>0 and a2<=q1 then 1980
2020  if q3<>0 then return
2030  if a2>q1 then 1970
2040  return
2050  q5=q3*p(x,5)*4+aa:if q5<0 then q5=q5+k1
2060  if q5>k1 then q5=q5-k1
2070  p(x,6)=q5:q4=int(q5/60):q5=int(q5-q4*60+.5):if q5=60 then q5=0:q4=q4+1
2080  if q4=24 then q4=0
2090  return
2100  su=a5*60+a4:ps=su+360:ms=su-360:if ps>k1 then ps=ps-k1
2110  if ms<0 then ms=ms+k1
2120  if ms>ps then 2150
2130  if p(x,6)<ps and p(x,6)>ms then 2180
2140  qq$=" ":return
2150  if p(x,6)<k1 and p(x,6)>ms then 2180
2160  if p(x,6)<ps then 2180
2170  goto 2140
2180  qq$="*":return
2190  ll$=right$(str$(abs(ll)),2):if abs(ll)<10 then ll$=" "+right$(ll$,1)
2200  ? k$;"-- ";h$;str$(d);",";y;" ";ll$;dg$;:? mid$("SN",(ll<0)+2,1);
2210  return
2220  a4$=right$(str$(a4),2)
2230  if a4<10 then a4$="0"+right$(a4$,1)
2240  a3$=str$(a3)+":"+a4$:a5$=str$(a5)+":"+a4$
2250  q8=7-len(a3$):q9=7-len(a5$):return
2260  ly=0:if y/4=int(y/4) then ly=1
2270  if y/100=int(y/100) and y/400<>int(y/400) then ly=0
2280  if y/1000=int(y/1000) and y/4000=int(y/4000) then ly=0
2290  return
2300  y9=y+1:if y9/4=int(y9/4) then zy=1
2310  if y9/100=int(y9/100) and y9/400<>int(y9/400) then zy=0
2320  if y9/1000=int(y9/1000) and y9/4000=int(y9/4000) then zy=0
2330  y1=y-1977:y1=y1*365+int(y1/4)+d1:if y<2000 then 2350
2340  y1=y1-int((y-2001)/100)+int((y-2001)/400)-int((y-1)/4000)
2350  return
2360  gosub 2600
2370  if i$="D" or i$="d" then 1200
2380  if (i$="S" or i$="T" or i$="s" or i$="t") and s1=1 then 340
2390  if i$="P" or i$="p" then 1590
2400  if i$="L" or i$="l" and s1=1 then 2900
2410  goto 2360
2420  p5=1.376344:k5=a2*4
2430  k5=abs(k5-1233.73)*90/k1:k5=k5*d9:k5=sin(k5)*.3225812:p5=p5+k5:return
2440  if cc<=0 then xx=xx+84
2450  cd$=mid$(cc$,cc-1):if mid$(cd$,2,1)<>" " and mid$(cd$,3,1)=" " then cd$=" "+cd$
2460  if mid$(cd$,45,1)=" " and mid$(cd$,46,1)<>" " then cd$=mid$(cd$,2)
2470  cd$=mid$(cd$,2,45):return
2480  data 356.26,29.53059,59.818184,42.719626,262.364394,52.9196763
2490  data 134.69697,218.79464,87.97,224.7,686.98
2500  data 4332.79813,10759.7195,30686.5884
2510  data "MER",.3871,"VEN",.7233,"MAR",1.5237,"JUP",5.2028
2520  data "SAT",9.5308,"URA",19.182
2530  data 127,232,229,236,237,157,231
2540  data "SA","SC","LI","VI","LE","CA","GE","TA","AR","PI","AQ","CP"
2550  DATA "NEW","WAXING CRESCENT","1ST QUARTER","WAXING GIBBOUS","FULL"
2560  DATA "WANING GIBBOUS","3RD QUARTER","WANING CRESCENT"
2570  DATA 1770,1719,1620,1500,1418,1365,1335,1313,1290,1275,1260
2580  DATA 1238,1220,1200,1178,1115,915,720,660,640,625,610
2590  ? "-N- TO RE-INPUT OR -C- TO CONTINUE";
2600  i$=input$(1)
2610  return
2620  m2=m1/m9:if m1<1 or m1>28.5 then m3=1
2630  if m1>=1 and m1<6.9 then m3=2
2640  if m1>=6.9 and m1<=8 then m3=3
2650  if m1>8 and m1<14.2 then m3=4
2660  if m1>=14.2 and m1<15.2 then m3=5
2670  if m1>=15.2 and m1<21.6 then m3=6
2680  if m1>=21.6 and m1<=22.6 then m3=7
2690  if m1>22.6 and m1<=28.5 then m3=8
2700  return
2710  b$="":if y<>1985 and y<>1986 then return
2720  if (y=1985 and d1<305) or (y=1986 and d1>149) then return
2730  hd=d1+365:if hd>516 then hd=hd-365
2740  h1=(hd-295)/10:hd=int(h1):h1=h1-hd
2750  t4=hc%(hd)-hc%(hd+1):t4=hc%(hd)-h1*t4:if t4>1440 then t4=t4-1440
2760  gosub 1100:if y9=999 then return
2770  gosub 1170:if t4>1115 and t4>1200 then u9=u9+1
2780  if t4>1290 then u9=u9-1
2790  if t4>615 and t4<1115 then u9=u9+2
2800  u(7)=u9:b$=chr$(pp(7))+"HALLEY'S COMET":return
2810  input "";i$:return
2820  gosub 1170
2830  if ll>=0 then u9=lc+10+u9:goto 2850
2840  u9=lc+10-u9:y9=39-y9
2850  return
2860  ll$="@N":if ll<0 then ll$="@S"
2870  l1=abs(ll):if abs(ll)<24 then l1=40
2880  lc=int((l1-40)/7+.5):d1=val(mid$(d$,(m*3)-2,3))+d
2890  return
2900  gosub 3060
2910  gotoxy sl,7:? "NEW LATTITUDE":gotoxy sl,8:? "--------------"
2920  gotoxy sl,9:? "LAT (0-90)";:gosub 2810:if i$<>"" then ll=val(i$)
2930  if abs(ll)>90 then gotoxy sl+3,10:? oo$:goto 2920
2940  gotoxy 20,17:gosub 2590:if i$="N" or i$="n" then 2900
2950  a1=(sgn(ll)-(ll=0))*s+90-abs(ll):a1=fnr(a1)
2960  gotoxy sl,9:? spc(78-sl)
2970  gosub 2860:i$="S":goto 2380
2980  ci=1:c2$=""
2990  c1$=mid$(cd$,ci,1):if c1$<>" " then 3010
3000  c2$=c1$+c2$:ci=ci+1:goto 3020
3010  c2$=mid$(cd$,ci,2)+c2$:ci=ci+2
3020  if ci<4 then 2990
3030  cd$=c2$:return
3040  data 45,32,412,32,412,157,45,157,45,32
3050  data 45,158,412,158,412,175,45,175,45,158
3060  gotoxy 0,17:? "                                       ";
3070  gotoxy 0,0:?:gotoxy 34,17:? "                                    ";
3080  gotoxy 0,0:?:gotoxy 47,15:? "                      "
3090  gotoxy 47,16:? "                       ":return
3100  text$="SKYSCAPE ":tx=20:ty=10:fx=40:fy=40
3110  fullw(2):clearw(2)
3120  poke contrl,12:poke contrl+2,1:poke contrl+6,0:rem character height
3130  poke ptsin,0:poke ptsin+2,180:vdisys
3140  poke contrl,106:poke contrl+2,0:poke contrl+6,1:rem text effects
3150  poke intin,21:vdisys
3160  poke contrl,22:poke contrl+2,0:poke contrl+6,1:rem text color
3170  poke intin,2:vdisys
3180  poke contrl,11:poke contrl+2,2:poke contrl+6,len(text$)+2:poke contrl+10,10
3190  poke ptsin,tx*8:poke ptsin+2,ty*8:poke ptsin+4,len(text$)*40
3200  poke ptsin+6,0:poke intin,1:poke intin+2,1:rem justified text
3210  for i=1 to len(text$):poke intin+(i-1)*2+4,asc(text$)
3220  text$=right$(text$,len(text$)-1):next:vdisys
3230  poke contrl,12:poke contrl+2,1:poke contrl+6,0:rem reset normal text
3240  poke ptsin,0:poke ptsin+2,6:vdisys
3250  poke contrl,106:poke contrl+2,0:poke contrl+6,1:poke intin,0:vdisys
3260  poke contrl,22:poke contrl+2,0:poke contrl+6,1:poke intin,1:vdisys
3270  poke contrl,23:poke contrl+2,0:poke contrl+6,1:rem fill style
3280  poke intin,2:vdisys
3290  poke contrl,24:poke contrl+2,0:poke contrl+6,1:rem fill index
3300  poke intin,5:vdisys
3310  poke contrl,25:poke contrl+2,0:poke contrl+6,1:rem fill color
3320  poke intin,1:vdisys
3330  poke contrl,103:poke contrl+2,1:poke contrl+6,1:rem fill background
3340  poke ptsin,fx:poke ptsin+2,fy:poke intin,-1
3350  vdisys
3360  rem 2 lines change fill index and color
3370  poke contrl,25:poke contrl+2,0:poke contrl+6,1:poke intin,3:vdisys
3380  poke contrl,24:poke contrl+2,0:poke contrl+6,1:poke intin,2:vdisys
3390  restore 3450:a=0:while a>=0
3400  read a,b:poke contrl,103:poke contrl+2,1:rem fill letters
3410  poke contrl+6,1:poke intin,-1:poke ptsin,a:poke ptsin+2,b:vdisys
3420  wend:restore:rem reset fill color
3430  poke contrl,23:poke contrl+2,0:poke contrl+6,1:poke intin,1:vdisys
3440  return
3450  data 175,70,215,70,255,70,295,70,335,70,375,70,415,70,455,70,-1,-1
