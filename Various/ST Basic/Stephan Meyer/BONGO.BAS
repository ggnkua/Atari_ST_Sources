10    rem #####################################################################
20    rem #                                                                   #
30    rem #                            - BONGO -                              #
40    rem #                                                                   #
50    rem #              LEVEL 16              Public-Domain-Software         #
60    rem #                                                                   #
70    rem # written 1986 by   Sven KrÅppel, Linderner Str.29, 5138 Heinsberg  #
80    rem #                                                                   #
90    rem #####################################################################
100   dim spieler$(4),p(3),x(10),y(10),z(9),g(6),wurf(5),score(4,15),bongo(4)
110   init:
120   zug=1:sp=1:wurf=1:for i=1 to 4:bongo(i)=0:next:for i=1 to 5:wurf(i)=0:next
130   a#=gb:aintout=peek(a#+12)
140   data Einer,Zweier,Dreier,Vierer,FÅnfer,Sechser,Bonus,Dreierpasch
150   data Viererpasch,Full House,Kleine Straûe,Groûe Straûe,Bongo,Chance,Summe
160   for x=1 to 4:for y=1 to 15:score(x,y)=-1:next y,x
170   fullw 2:clearw 2:out 2,27:out 2,69:gosub mausaus:gosub titel
180   x(1)=200:y(1)=250:p(1)=1:p(2)=1:p(3)=200:t$="Maustaste drÅcken":gosub text
190   j=1:huell=9:periode=9000:kanal=7
200   for h=1 to 2:restore 3770:for i=1 to 22:read ton,oktave,laenge
210   gemsys 79:if peek(aintout+6)<>0 then goto eingabe
220   sound 1,0,ton,oktave:sound 2,0,ton,oktave-1:sound 3,0,ton,oktave+1
230   wave kanal,7,huell,periode,laenge:next:next
240   restore 3800:for i=1 to 21:read ton,oktave,laenge
250   gemsys 79:if peek(aintout+6)<>0 then goto eingabe
260   sound 1,0,ton,oktave:sound 2,0,ton,oktave-1:sound 3,0,ton,oktave+1
270   wave kanal,7,huell,periode,laenge:next
280   if j=1 then huell=9:periode=7000:kanal=13
290   if j=2 then huell=15:periode=1500:kanal=7
300   if j=3 then huell=9:periode=1000:kanal=15
310   if j=4 then huell=9:periode=7000:kanal=3
320   if j=5 then huell=15:peri