1     ' *****************************
2     ' *                           *
3     ' *           draw            *
4     ' *                           *
5     ' *       Kurvenzeichner      *
6     ' *     + PUBLIC DOMAIN +     *
7     ' *            by             *
8     ' *                           *
9     ' *       Stephan Meyer       *
10    '*                           *
11    '*****************************
20    'trig graphs
30    pi=3.1415926
40    fullw 2:color 1,0,1:clearw 2
50    BILDSCHIRM:
60    if peek(systab)=4 then goto LOW
70    if peek(systab)=4 then goto MEDIUM
80    if peek(systab)=1 then goto HIGH
90    t=1:l=0
100   lng=r/4:inc=pi/lng:off=b/4
110   FUNKTION: value=-2*pi
120   clearw 2
130   ?"funktion auswaehlen:":?
140   ?"1) sinus"
150   ?"2) cosinus"
160   ?"3) tangente"
170   ?"4) cosekante"
180   ?"5) sekante"
190   ?"6) cotangente"
200   ?:input wahl
210   if wahl>0 and wahl<7 then goto GRAFIK
220   ?"w„hlen sie eine dieser zahlen aus."
230   goto FUNKTION
240   ZEICHNEN:
250   value=-2*pi
260   x=1:x1=1:y1=b/2
270   on wahl gosub SINUS,COSINUS,TANGENTE,COSEKANTE,SEKANTE,COTANGENTE
280   y=off*y:y=b/2-y
290   if y<t or y>b goto SPRUNG
300   if x<1 or x>r goto SPRUNG
310   linef x1,y1,x,y
320   SPRUNG: x1=x
330   y1=y:x=x+1
340   value=value+inc
350   if value>2*pi then goto ENDE
360   goto 270
370   ENDE: input wait$
380   goto 120
390   GRAFIK: color 1,bg,gr:clearw 2
400   linef 1,b/2,r,b/2
410   linef r/2,t,r/2,b
420   color 1,bg,ln
430   goto ZEICHNEN
440   SINUS: y=sin(value):return
450   COSINUS: y=cos(value):return
460   TANGENTE: y=tan(value):return
470   COSEKANTE: hold=sin(value)
480   if hold=0 then return
490   y=1/hold:return
500   SEKANTE: hold=cos(value)
510   if hold=0 then return
520   y=1/hold:return
530   COTANGENTE:hold=tan(value)
540   if hold=0 then return
550   y=1/hold:return
560   LOW: r=303:b=167
570   gr=2:ln=14:bg=4
580   goto 90
590   MEDIUM: r=608:b=167
600   gr=1:in=2:bg=3
610   goto 90
620   HIGH: r=615:b=343
630   gr=1:ln=1:bg=0
640   goto 90
