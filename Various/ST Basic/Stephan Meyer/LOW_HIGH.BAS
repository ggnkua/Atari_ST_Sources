10    rem #####################################################################
20    rem #                                                                   #
30    rem #                     Low - High - Converter                        #
40    rem #                     ----------------------                        #
50    rem # written 1986 by   Sven Krppel, Linderner Str.29, 5138 Heinsberg  #
60    rem # ----------------------------------------------------------------  #
70    rem #                   LEVEL 16     Public Domain                      #
80    rem #                                                                   #
90    rem #####################################################################
100   dim w(80)
110   fullw 2:clearw 2
120   main:
130   poke contrl,123:poke contrl+2,0:poke contrl+6,0:vdisys
140   gotoxy 7,2:?"Low Resolution - High Resolution - CONVERTER"
150   gotoxy 7,3:?"--------------------------------------------"
160   gotoxy 7,5:?"LEVEL 16                       Public Domain"
170   gotoxy 0,10:input "Lade  -  Filename (*=Programmende) ";l$
180   if l$="*" then goto mausan
190   gotoxy 0,12:input "Speicher-Filename (*=Programmende) ";s$
200   if s$="*" then goto mausan
210   gotoxy 0,14:input "Offset (meistens 32) ";offset
220   gosub laden
230   gosub convert
240   gosub speichern
250   out 2,7:a=inp(2)
260   goto main
270   laden:
280   sm=peek(&h44e)*65536+abs(peek(&h450))
290   bload l$,sm+offset
300   for i=sm to sm+158:poke i,-1:next
310   return
320   speichern:
330   bsave s$,sm,32000
340   return
350   convert:
360   for y=sm+160 to sm+31840 step 160
370   for x=0 to 79:w(x)=peek(y+x*2):if sgn(w(x))=-1 then w(x)=65536+w(x)
380   next
390   x1=0
400   for x=0 to 76 step 4
410   k=32768:j=1
420   h1=32768:h2=h1:p1=0:p2=0
430   if w(x)>=k then p1=p1+h1:w(x)=w(x)-k
440   h1=h1/2
450   if w(x+1)>=k then p1=p1+h1:w(x+1)=w(x+1)-k
460   h1=h1/2
470   if w(x+2)>=k then p2=p2+h2:w(x+2)=w(x+2)-k
480   h2=h2/2
490   if w(x+3)>=k then p2=p2+h2:w(x+3)=w(x+3)-k
500   h2=h2/2
510   k=k/2
520   if j=8 then poke y+x1*2,p1:poke y+x1*2+80,p2:j=1:x1=x1+1:goto 420
530   j=j+1:if k>=1 then 430
540   next:next:return
550   mausan:
560   poke contrl,122:poke contrl+2,0:poke contrl+6,1:poke intin,0:vdisys
570   end
