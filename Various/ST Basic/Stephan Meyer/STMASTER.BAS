5     rem by David S. Lay
10    title$=" Mastermind "
20    title$=chr$(32)+chr$(14)+chr$(15)+title$
30    title$=title$+chr$(14)+chr$(15)+chr$(32)
35    gosub 40:goto 150
40    poke systab+24,1
50    a#=gb
60    gintin=peek(a#+8)
70    poke gintin+0,peek(systab+8)
80    poke gintin+2,2
90    s#=gintin+4
100   title$=title$+chr$(0)
110   poke s#,varptr(title$)
120   gemsys(105)
130   poke systab+24,0
140   return
150   fullw 2:clearw 2
160   if peek(systab)=4 then 220
170   ?:?:?:?
180   ?"  This program will work only in low resolution."
190   ?:?"  Please return to the desktop and use the SET PREFERENCES"
200   ?"  function to select low resolution mode."
210   x=inp(2):clearw 2:end
220   gotoxy 0,0
230   ?:?"I will select up to six coloured pegs
240   ?"from ten different colours (duplicates"
250   ?"are possible) and you will have ten"
260   ?"tries to guess the combination.  Enter"
270   ?"your guess using the numeric keypad"
280   ?"(you can change your guess using the"
290   ?"arrow keys) then press ENTER.  Each"
300   ?"time you make a guess I will provide"
310   ?"hints.  For every peg which is the"
320   ?"right colour and is in the right"
330   ?"place, I will show a white peg.  For"
340   ?"every peg of the right colour but"
350   ?"in the wrong place, I will show a"
360   ?"black peg."
370   gotoxy 0,17:?"   Select difficulty level (3 to 6)";
380   x=inp(2)
390   if x<51 or x>54 goto 380
400   dl=x-48
410   randomize 0
420   gosub setup
430   gosub in
440   if fi=0 then 430
450   tn=tn+1:for i=1 to dl
460   c=gu(i)
470   color 1,c,c,1,1
480   pcircle i*9+18,145-tn*10,4:next
490   gosub boxoff:bn=1:gosub boxon
500   gosub check
510   if nb=dl then 530
520   if tn<10 then 430
530   for i=1 to dl:c=gi(i)
540   color 1,c,c,1,1:pcircle i*9+18,30,4
550   next
560   x=inp(2):if x<>27 then tn=0:goto 420
565   title$="OUTPUT":gosub 40:end
570   check:nb=0:nw=0
580   for i=1 to dl
590   gis(i)=gi(i)
600   gus(i)=gu(i)
610   next
620   for i=1 to dl
630   if gus(i)=gis(i) then nb=nb+1:gis(i)=0:gus(i)=1
640   next i
650   for i=1 to dl:for j=1 to dl
660   if gus(i)=gis(j) then nw=nw+1:gis(j)=0:gus(i)=1
670   next j,i:bb=0
680   color 1,0,0,1,1:if nb=0 then 720
690   for i=1 to nb
700   bb=bb+1:pcircle bb*9+78,145-tn*10,3
710   next i
720   if nw=0 then 770
730   color 1,1,1,1,1
740   for i=1 to nw
750   bb=bb+1:pcircle bb*9+78,145-tn*10,3
760   next i
770   return
780   in:fi=0:x=inp(2)
790   if x=205 and bn<dl then gosub boxoff:bn=bn+1:gosub boxon:return
800   if x=203 and bn>1 then gosub boxoff:bn=bn-1:gosub boxon:return
810   if x=13 then fi=1:return
820   if x>57 or x<48 then return
830   c=x-46:if c>3 then c=c+1:if c>6 then c=c+3
840   gu(bn)=c
850   color 1,c,c,1,1: pcircle bn*10+193,30,4
860   x=205:goto 790
870   return
880   boxon:color 1,1,1,1,1:goto 900
890   boxoff:color 1,8,8,1,1
900   xp=bn*10+188
910   linef xp,25,xp,35:linef xp,35,xp+10,35
920   linef xp+10,35,xp+10,25:linef xp+10,25,xp,25
930   return
940   setup:clearw 2:fullw 2
950   color 1,8,8,1,1:fill 1,80
960   color 1,9,9,1,1
970   linef 10,10,150,10:linef 150,10,150,150
980   linef 150,150,10,150:linef 10,150,10,10
990   color 1,1,1,1,1
1000  linef 12,12,148,12:linef 148,12,148,148
1010  linef 148,148,12,148:linef 12,148,12,12
1020  rem fill 15,80
1030  color 1,9,9,1,1:fill 11,11
1040  linef 20,20,20,140
1050  linef 20,140,140,140
1060  linef 140,140,140,20
1070  linef 140,20,20,20
1080  linef 80,20,80,140
1090  for i=40 to 130 step 10
1100  linef 20,i,140,i:next
1110  for i=1 to dl
1120  pv=int(rnd*13)+2
1130  if pv=4 or (pv>6 and pv<10) then 1120
1140  gi(i)=pv
1150  next
1160  color 1,9,9,1,1
1170  for i=27 to dl*9+19 step 9
1180  pcircle i,30,4:next
1190  color 1,2,2,1,1
1200  linef 200,130,200,115:linef 200,115,235,115
1210  linef 235,115,235,130:linef 235,130,200,130
1220  fill 220,120
1230  color 1,3,3,1,1
1240  linef 200,110,200,95:linef 200,95,215,95
1250  linef 215,95,215,110:linef 215,110,200,110
1260  fill 210,100
1270  color 1,5,5,1,1
1280  linef 220,110,220,95:linef 220,95,235,95
1290  linef 235,95,235,110:linef 235,110,220,110
1300  fill 230,100
1310  color 1,6,6,1,1
1320  linef 240,110,240,95:linef 240,95,255,95
1330  linef 255,95,255,110:linef 255,110,240,110
1340  fill 250,100
1350  color 1,10,10,1,1
1360  linef 200,90,200,75:linef 200,75,215,75
1370  linef 215,75,215,90:linef 215,90,200,90
1380  fill 210,80
1390  color 1,11,11,1,1
1400  linef 220,90,220,75:linef 220,75,235,75
1410  linef 235,75,235,90:linef 235,90,220,90
1420  fill 230,80
1430  color 1,12,12,1,1
1440  linef 240,90,240,75:linef 240,75,255,75
1450  linef 255,75,255,90:linef 255,90,240,90
1460  fill 250,80
1470  color 1,13,13,1,1
1480  linef 200,70,200,55:linef 200,55,215,55
1490  linef 215,55,215,70:linef 215,70,200,70
1500  fill 210,60
1510  color 1,14,14,1,1
1520  linef 220,70,220,55:linef 220,55,235,55
1530  linef 235,55,235,70:linef 235,70,220,70
1540  fill 230,60
1550  color 1,15,15,1,1
1560  linef 240,70,240,55:linef 240,55,255,55
1570  linef 255,55,255,70:linef 255,70,240,70
1580  fill 250,60
1590  color 1,9,9,1,1
1600  linef 190,140,190,45
1610  linef 190,45,265,45
1620  linef 265,45,265,140
1630  linef 265,140,190,140
1640  linef 190,40,190,20:linef 190,20,265,20
1650  linef 190,40,265,40:linef 265,40,265,20
1660  color 1,7,7,1,1
1670  fill 180,100
1680  bn=1:gosub boxon
1690  return
