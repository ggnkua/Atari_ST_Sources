10    rem #####################################################################
20    rem #                                                                   #
30    rem #                      FÅllmuster - Editor                          #
40    rem #                                                                   #
50    rem #                   LEVEL 16      Public Domain                     #
60    rem #                                                                   #
70    rem # written by :   Sven KrÅppel, Linderner Str.29, 5138 Heinsberg     #
80    rem #                                                                   #
90    rem #####################################################################
100   dim x(10),y(10),muster(16,16),daten(4,16)
110   gosub farben
120   f=0:for x=1 to 16:for y=1 to 16:muster(x,y)=0:next:next
130   fullw 2:clearw 2:out 2,27:out 2,69:gosub mausaus
140   rem ##################### Auflîsung ###################
150   if peek(systab)=2 then ?"Falsche Bildschirmaufloesung":end
160   r=cint(peek(systab)/2)
170   sm=peek(&h44e)*65536+abs(peek(&h450))
180   rem ********************* LAYOUT ***************************************
190   if r=2 then goto 210
200   color 1,1,1,0,0:xeck=380:yeck=140:lx=200:ly=100:gosub bar
210   if r=1 then gosub high else gosub low
220   rem ################## Feld zeichnen #################
230   feld:
240   color 1,1,1,0,0
250   p=2:for j=20/r to 340/r step 20/r
260   x(1)=j:y(1)=60/r:x(2)=x(1):y(2)=380/r:gosub polyline
270   x(1)=20/r:y(1)=j+40/r:x(2)=340/r:y(2)=y(1):gosub polyline:next
280   color 1,1,1,0,0:xeck=380/r:lx=40/r:ly=lx:yeck=260/r:gosub bar
290   rem #################### MenÅ ########################
300   menu:
310   lx=200/r:ly=20/r
320   for f=0 to peek(systab)
330   color 1,f,1,1,1:if f=0 then color 1,1,1,0,0
340   yeck=(f*40+60)/r:gosub bar:next
350   color 1,2,2,0,0:yeck=320/r:gosub bar:yeck=360/r:gosub bar
360   if r=1 then s=16:gosub effekt
370   xtext=390/r:wdehn=1:zdehn=1:xdehn=180/r:t$="abspeichern":ytext=336/r:
380   gosub text:t$="Programm-Ende":ytext=376/r:gosub text:s=0:gosub effekt
390   rem ********************* HAUPTPROGRAMM ********************************
400   main:
410   gosub mausan:f=0:y=1:goto fwahl
420   gosub mausan:gosub maus
430   if xmaus>20/r and xmaus<580/r and ymaus>60/r and ymaus<380/r then 450
440   out 2,7:goto 420
450   if taste=0 then 420
460   x=int(xmaus/(20/r)):y=int(ymaus/(20/r))-2
470   if y<1 or y>16 or x=17 then 420
480   if x<17 then goto punkt
490   if y=14 then goto speichern
500   if y=16 then end
510   if y=15 or y>peek(systab)*2+1 then 420
520   for j=2 to 8 step 2:if y=j then 420 else next
530   goto fwahl
540   rem #################### Punkte zeichnen #####################
550   punkt:
560   gosub mausaus:xeck=x*20/r+1:yeck=y*20/r+40/r+1:lx=(20-2*r)/r:ly=(20-2*r)/r
570   gosub bar
580   if f=0 then color 1,0,0
590   if r=2 then linef 191+x,110+y,191+x,110+y:goto 610
600   linef 391+x,233+y,391+x,233+y
610   muster(x,y)=f
620   goto 420
630   rem ################ Farbe auswÑhlen ################
640   fwahl:
650   gosub mausaus
660   xtext=360/r:ytext=f*20/r*2+76/r:wdehn=0:zdehn=0:t$=" ":gosub text
670   f=(y-1)/2:color f,f,f,1,1:if f=0 then color 1,f,f,1,1
680   t$=chr$(8):ytext=f*20/r*2+76/r:gosub text:goto 420
690   rem ################# abspeichern ###################
700   speichern:
710   gosub auswertung
720   open "O",#1,"pattern.bas",128
730   z=12000
740   for f=1 to peek(systab)
750   ?#1,z;"data";:for j=1 to 7:?#1,daten(f,j);",";:next:?#1,daten(f,8)
760   z=z+10
770   ?#1,z;"data";:for j=9 to 15:?#1,daten(f,j);",";:next:?#1,daten(f,16)
780   z=z+10
790   next
800   ?#1,z;"poke contrl,112":z=z+10
810   ?#1,z;"poke contrl+2,0":z=z+10
820   ?#1,z;"poke contrl+6,";16*peek(systab):z=z+10
830   ?#1,z;"restore 12000":z=z+10
840   ?#1,z;"for i=1 to peek(contrl+6)":z=z+10
850   ?#1,z;"read wert:poke intin+(i-1)*2,wert":z=z+10
860   ?#1,z;"next":z=z+10
870   ?#1,z;"vdisys"
880   close #1:goto 420
890   rem ############### Beschriftung ###################
900   low:
910   color 13:h=20:gosub groesse:s=17:gosub effekt:t$="FöLLMUSTER-EDITOR"
920   ytext=20:xtext=10:wdehn=1:zdehn=1:xdehn=300:gosub text
930   h=4:gosub groesse:s=0:gosub effekt
940   h=15:gosub groesse:s=5:gosub effekt
950   color 2:xtext=215:ytext=147:xdehn=75:t$="LEVEL 16":gosub text
960   h=6:gosub groesse:s=0:gosub effekt
970   t$="freigegeben ab 16 Bit":ytext=198:xtext=10:zdehn=1:xdehn=310
980   gosub text
990   for i=sm to sm+3998 step 8:poke i,not peek(i):next
1000  return
1010  high:
1020  h=27:gosub groesse:s=21:gosub effekt
1030  wdehn=1:zdehn=1:xdehn=629:xtext=10:ytext=28:t$="FöLLMUSTER - EDITOR"
1040  gosub text:h=13:gosub groesse:s=17:gosub effekt:ytext=45
1050  t$="written 1986 by Sven KrÅppel, Linderner Str.29, 5138 Heinsberg"
1060  gosub text:h=30:gosub groesse
1070  s=7:gosub effekt:xtext=390:ytext=185:xdehn=190:t$="LEVEL 16":gosub text
1080  s=5:gosub effekt:h=13:gosub groesse:ytext=205:xdehn=185
1090  t$="freigegeben":gosub text:ytext=223:t$="ab 16 Bit":gosub text
1100  h=14:gosub groesse:t$="Public Domain":xtext=440:ytext=280:xdehn=140
1110  gosub text
1120  h=13:gosub groesse:s=0:gosub effekt
1130  for i=sm to sm+3998 step 2:poke i,not peek(i):next
1140  return
1150  rem ################# Text ausgeben #################
1160  text:
1170  poke contrl,11
1180  poke contrl+2,2
1190  poke contrl+6,len(t$)+2
1200  poke contrl+10,10
1210  poke intin,wdehn
1220  poke intin+2,zdehn
1230  for i=1 to len(t$)
1240  poke intin+2+i*2,asc(mid$(t$,i,1))
1250  next
1260  poke ptsin,xtext
1270  poke ptsin+2,ytext
1280  poke ptsin+4,xdehn
1290  vdisys
1300  return
1310  rem ########## Text-Effekte ###########################
1320  effekt:
1330  poke contrl,106
1340  poke contrl+2,0
1350  poke contrl+6,1
1360  poke intin,s
1370  vdisys
1380  return
1390  rem ########### Text-Grîûe ############################
1400  groesse:
1410  poke contrl,12
1420  poke contrl+2,1
1430  poke contrl+6,0
1440  poke ptsin,0:poke ptsin+2,h
1450  vdisys
1460  return
1470  rem ############### Maus-Abfrage ##################
1480  maus:
1490  poke contrl,124
1500  poke contrl+2,0
1510  poke contrl+6,0
1520  vdisys
1530  taste=peek(intout)
1540  xmaus=peek(ptsout)
1550  ymaus=peek(ptsout+2)
1560  return
1570  rem ########## Rechteck zeichnen #######################
1580  bar:
1590  poke contrl,11
1600  poke contrl+2,2
1610  poke contrl+6,0
1620  poke contrl+10,1
1630  poke ptsin,xeck
1640  poke ptsin+2,yeck
1650  poke ptsin+4,xeck+lx
1660  poke ptsin+6,yeck+ly
1670  vdisys
1680  return
1690  rem ########## Polygon zeichnen #########################
1700  polyline:
1710  poke contrl,6
1720  poke contrl+2,p
1730  poke contrl+6,0
1740  for i=1 to p
1750  poke ptsin+(i-1)*4,x(i)
1760  poke ptsin+i*4-2,y(i)
1770  next
1780  vdisys
1790  return
1800  rem ##################### Maus ausschalten ###################
1810  mausaus:
1820  poke contrl,123
1830  poke contrl+2,0:poke contrl+6,0
1840  vdisys
1850  return
1860  rem ##################### Maus anschalten ###################
1870  mausan:
1880  poke contrl,122
1890  poke contrl+2,0:poke contrl+6,1:poke intin,0
1900  vdisys
1910  return
1920  rem ############## Auswertung #################
1930  auswertung:
1940  for c=1 to 4
1950  for j=1 to 16:daten(c,j)=0:next
1960  for j=1 to 16
1970  for i=16 to 1 step -1
1980  if muster(i,j)=c then daten(c,j)=daten(c,j)+2^(16-i)
1990  next i,j,c
2000  return
2010  rem ############ Farbeinstellung ################
2020  farben:
2030  data 7 , 7 , 7 , 0 , 0 , 0 , 7 , 0 , 0 , 0 , 7 , 0 
2040  data 0 , 0 , 7 , 0 , 7 , 7 , 7 , 7 , 0 , 7 , 0 , 7 
2050  data 5 , 5 , 5 , 3 , 3 , 3 , 7 , 3 , 3 , 3 , 7 , 3 
2060  data 3 , 3 , 7 , 3 , 7 , 7 , 7 , 7 , 3 , 7 , 3 , 7 
2070  restore 2030
2080  poke contrl,14:poke contrl+2,0:poke contrl+6,4
2090  for f=0 to 15:poke intin,f:for c=0 to 2:read i
2100  poke intin+c*2+2,i*140:next:vdisys
2110  next:return
