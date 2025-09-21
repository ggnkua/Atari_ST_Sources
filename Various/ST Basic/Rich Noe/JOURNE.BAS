0     gosub 32000
1     fullw 2:clearw 2:gotoxy 20,6
2     poke contrl,106:poke contrl+2,0:poke contrl+6,1:poke intin,13:vdisys(1)
3     color 2,0,2
4     print "Journey to the Center of the Earth"
5     color 1,0,1
6     poke contrl,106:poke contrl+2,0:poke contrl+6,1:poke intin,4:vdisys(1)
7     ?:?
8     gotoxy 26,8:?" A 520ST Adventure"
9     poke contrl,106:poke contrl+2,0:poke contrl+6,1:poke intin,5:vdisys(1)
10    gotoxy 19,10:print"Converted to ST Basic by Rich Noe"
11    POKE CONTRL,106:POKE CONTRL+2,0:POKE CONTRL+6,1:POKE INTIN,1:VDISYS(1)
70    CP=1:GOSUB 1930
80    CLEARW 2:GOTOXY 0,0
90    GOSUB 1830:GOSUB 1720
100   IF CP=18 AND (VB<>25 OR NO<>21)THEN PRINT"Horrors!! The troll throws an axe at me!  I am dead":GOTO 1460
110   IF CP=18 THEN PRINT M2$:F5=1:GOSUB 1720
120   IF NO<23 OR VB>1 OR NO>30 THEN 210
130   IF NO<=26 THEN FD=FD+1 ELSE FD= -10000
140   IF NO>26 THEN NO=NO-4
150   NO=NO-22
160   IF CP=10 AND NO=1 THEN PRINT"And fall into the lava???  Fat chance!":GOSUB 1720:GOTO 120
170   IF CP=11 AND NO=2 THEN PRINT"Do you know what molten lava is???  It's hot, that's what!":GOSUB 1720:GOTO 120
180   IF CP=29 AND OB(10,0)=29 AND (NO=4 OR NO=2) THEN PRINT"The hydra won't let me through!":GOSUB 1720:GOTO 120
190   IF P(CP,NO)=0 THEN PRINT"I can't go THAT way!":GOSUB 1720:GOTO 120
200   CP=P(CP,NO):GOTO 80
210   IF VB<>2 AND VB<>20 THEN 290
220   IF NO=10 AND OB(33,0)=CP THEN PRINT"It is sort of heavy, you know.":GOSUB 1720:GOTO 120
230   IF NO=0 THEN PRINT"I don't know what a ";CHR$(34);NO$;CHR$(34);" is.":GOSUB 1720:GOTO 120
240   IF OB(NO,0)<>CP THEN PRINT"I don't see it here.":GOSUB 1720:GOTO 120
250   IF NO=10 OR NO=20 THEN PRINT"Oh give me a break!!":GOSUB 1720:GOTO 120
260   IF OB(NO,0)=-1 THEN PRINT"I'm already carrying it.":GOSUB 1720:GOTO 120
270   IF OB(NO,0)=CP AND NT>=6 THEN PRINT"I can't carry any more. You'll have to drop something.":GOSUB 1720:GOTO 120
280   IF OB(NO,0)=CP THEN PRINT"Check.":NT=NT+1:OB(NO,0)=-1:GOSUB 1720:GOTO 120
290   IF VB<>4 AND VB<>29 THEN 340
300   F3=0
310   PRINT"I am currently carrying :":FOR I=1 TO LO:IF OB(I,0)=-1 THEN PRINT OB$(I):F3=1
320   NEXT I:IF F3=0 THEN PRINT"Nothing."
330   GOSUB 1720:GOTO 120
340   IF VB=3 THEN 80
350   IF NO=0 AND VB=0 THEN PRINT"That doesn't make any sense to me.":GOSUB 1720:GOTO 120
360   IF VB<>5 THEN 420
370   J=0
380   FOR I=1 TO LO:IF OB(I,0)=1 THEN J=J+OB(I,1)
390   NEXT I:PRINT"Out of a maximum of 175 points, you have";J
400   IF J=0 THEN PRINT"Boy, you stink!"
410   GOSUB 1720:GOTO 120
420   IF VB<>6 AND VB<>22 THEN 490
430   IF NO$<>"Everything" AND NO$<>"All" THEN 470
440   FOR I=1 TO LO:IF OB(I,0)=-1 THEN OB(I,0)=CP
450   NEXT I:NT=0
460   PRINT"Okay.":GOSUB 1720:GOTO 120
470   IF OB(NO,0)<>-1 THEN PRINT"How can I drop what I am not holding???":GOSUB 1720:GOTO 120
480   OB(NO,0)=CP:PRINT"O.K.":NT=NT-1:GOSUB 1720:GOTO 120
490   IF VB<>7 AND VB<>28 THEN 530
500   IF H$(CP)="" THEN PRINT"You got me into this mess, now you get me out!"
510   PRINT H$(CP):H$(CP)=""
520   GOSUB 1720:GOTO 120
530   IF VB<>8 THEN 600
535   CLEARW 2:GOTOXY 0,0:?:PRINT:PRINT:PRINT TAB(10)," ";:INPUT"Filename";FILE$
540   CLEARW 2:GOTOXY 0,0 :INPUT"Press <RETURN> to save game";XX$:OPEN "O",1,FILE$
550   FOR I=1 TO LO:IF OB$(I)="" THEN 570
560   PRINT#1,OB(I,0),OB(I,1)
570   NEXT I
580   PRINT#1,CP:CLOSE
590   GOSUB 1720:GOTO 120
600   IF VB<>9 THEN 670
605   CLEARW 2:GOTOXY 0,0:PRINT:PRINT:PRINT:PRINT TAB(10)," ";:INPUT"Filename";FIL
610   CLEARW 2:GOTOXY 0,0:INPUT"Press <RETURN> to restore ";XX$:OPEN "I",1,FILE$
620   FOR I=1 TO LO:IF OB$(I)="" THEN 640
630   INPUT#1,OB(I,0),OB(I,1)
640   NEXT I
650   INPUT#1,CP:CLOSE
660   GOTO 80
670   IF VB<>10 THEN 690
680   GOTO 1470
690   IF VB<>11 THEN 720
700   IF NO=0 THEN PRINT"Say what?":GOSUB  1720:GOTO 120
710   PRINT"Okay, if it is really necessary...";NO$:GOSUB 1720:GOTO 120
720   IF VB<>12 THEN 760
730   IF NO<>12 THEN PRINT"I don't do stupid things.":GOSUB 1720:GOTO 120
740   IF OB(12,0)<>-1 THEN PRINT"I don't have any Coke to drink!":GOSUB 1720:GOTO 120
750   PRINT M3$:OB(12,0)=0:OB(13,0)=-1:GOSUB 1720:GOTO 120
760   IF VB<>13 THEN 830
770   IF OB(31,0)<>-1 THEN PRINT"But I have no food!!":GOSUB 1720:GOTO 120
780   IF OB(NO,0)<>CP THEN PRINT"I don't see it.":GOSUB 1720:GOTO 120
790   IF NO=10 THEN PRINT"The hydra whoofs down the food.":OB(31,0)=0:OB$(10)="a giant hydra rubbing his stomach":GOSUB 1720:GOTO 120
800   IF NO=20 THEN PRINT"The bugs in these caves only eat human flesh.":GOSUB 1720:GOTO 120
810   IF NO<>3 THEN PRINT"You can't be serious.":GOSUB 1720:GOTO 120
820   PRINT"It refuses to eat the food.":GOSUB 1720:GOTO 120
830   IF VB<>14 THEN 910
840   IF NO=10 AND OB(33,0)=CP THEN PRINT"The undertaker just took him away.":OB(33,0)=0:GOSUB 1720:GOTO 120
850   IF OB(NO,0)<>CP AND OB(NO,0)<>-1 THEN PRINT"I don't see it and I'm not holding ii, so how can I hit it?":GOSUB 1720:GOTO 120
860   IF NO=3 THEN PRINT"No!!!  I kind of like the parrot!  Polly want a cracker?"
870   IF NO=10 THEN PRINT"Okay...                                                                                The hydra grunts >>DAMN MOSQUITOS<<"
880   IF NO=20 THEN PRINT"Yuch!  I don't want to touch it!!!"
890   IF NO=30 OR NO=10 OR NO=20 THEN GOSUB 1720:GOTO 120
900   PRINT"Okay...    Ouch!  I hurt my hand!":GOSUB 1720:GOTO 120
910   IF VB=15 THEN PRINT"I can't kill anything, I'm too weak.  But maybe if you were a bit more specific.":GOSUB 1720:GOTO 120
920   IF VB<>16 THEN 1010
930   IF OB(33,0)=CP AND NO=10 THEN PRINT"It is already burnt to a crisp.":GOSUB 1720:GOTO 120
940   IF OB(6,0)<>-1 THEN PRINT"I don't have a lighter or matches!!":GOSUB 1720:GOTO 120
950   IF NO=3 THEN PRINT"Never!!  You know something, you're a sadist.":GOSUB 1720:GOTO 120
960   IF NO=10 AND OB(10,0)=CP THEN OB(10,0)=0:OB(33,0)=CP:PRINT"The hydra crumbles to the ground dead.":GOSUB 1720:GOTO 120
970   IF NO=20 THEN PRINT"The bug cannot be burnt.  <GULP>":GOSUB 1720:GOTO 120
980   IF NO=10 THEN OB(10,0)=0
990   PRINT"It doesn't burn."
1000  GOSUB 1720:GOTO 120
1010  IF VB=17 THEN PRINT"And just who do you think I am, Rocky???":GOSUB 1720:GOTO 120
1020  IF VB=18 THEN PRINT"I don't know how to light things.  If you want me to burn something, tell me so!":GOSUB 1720:GOTO 120
1030  IF VB<>19 THEN 1120
1040  IF NO$="COIN" THEN NO$="QUARTER":NO=7
1050  IF NO=0 THEN PRINT"I don't know what one is.":GOSUB 1720:GOTO 120
1060  IF NO=7 THEN 1080
1070  IF OB(NO,0)<>-1 THEN PRINT"I'm not holding it right now.":GOSUB 1720:GOTO 120
1080  IF CP<>27 THEN PRINT"I don't see any Coke machines here.":GOSUB 1720:GOTO 120
1090  IF NO<>7 THEN PRINT"That is ridiculous.":GOSUB 1720:GOTO 120
1100  IF OB(NO,0)<>-1 THEN PRINT"I have no money.":GOSUB 1720:GOTO 120
1110  IF OB(7,0)=-1 AND CP=27 THEN PRINT"All right.   Chikclik Chinggg!               A Coke popped out.  There is now a bottle of Coke here.":OB(7,0)=0:NT=NT-1:OB(12,0)=27:GOSUB 1720:GOTO 120
1120  REM
1130  IF VB<>21 THEN 1210
1140  IF NO<>18 AND OB(NO,0)=-1 THEN PRINT"It's kind of heavy, you know.":GOSUB 1720:GOTO 120
1150  IF OB(NO,0)<>-1 THEN PRINT"First you have to help me find it, dummy!":GOSUB 1720:GOTO 120
1160  IF CP=10 OR CP=11 THEN 1180
1170  PRINT"Nothing happened":GOSUB 1720:GOTO 120
1180  IF CP=10 THEN CP=11:GOTO 1200
1190  CP=10
1200  GOTO 80
1210  IF VB=23 THEN VB=1:GOTO 120
1220  IF VB=24 THEN PRINT"Try kill ";NO$:GOSUB 1720:GOTO 120
1230  IF VB<>25 THEN 1260
1240  IF NO=21 THEN PRINT"Nothing happened":GOSUB 1720:GOTO 120
1250  PRINT"Sir what???  I don't understand!":GOSUB 1720:GOTO 120
1260  IF VB<>26 THEN 1330
1270  IF CP=1 AND OB(14,0)=-1 AND OB(22,0)=1 THEN PRINT"Okay!!!":GOTO 1460
1280  IF CP<>1 THEN PRINT"I can't.":GOSUB 1720 :GOTO 120
1290  IF VB<>26 THEN 1330
1300  IF OB(14,0)<>-1 THEN PRINT"I can't.  I have no tools.":GOSUB 1720:GOTO 120
1310  PRINT"I can't.  I don't see the fribulating gonkulator around me.";:IF OB(22,0)=-1 THEN PRINT" I think I have to drop it first." ELSE PRINT
1320  GOSUB 1720:GOTO 120
1330  IF VB<>27 THEN 1410
1340  IF NO=0 THEN PRINT"What the devil is a ";NO$;"??":GOSUB 1720:GOTO 120
1350  IF NO=20 OR NO=10 THEN IF OB(NO,0)=CP THEN PRINT"Yuch!!!  I'd never eat a ";NO$;"!!!":GOSUB 1720:GOTO  120
1360  IF NO=10 AND OB(33,0)=CP THEN PRINT"Well...  It's cooked now, but it still looks kind of gross.":GOSUB 1720:GOTO 120
1370  IF OB(NO,0)<>-1 THEN PRINT"I'm not holding it.":GOSUB 1720 :GOTO 120
1380  IF NO=3 AND OB(3,0)=-1 THEN PRINT"I'd rather not.  I don't care for parrot meat.":GOSUB 1720:GOTO 120
1390  IF NO=31 AND OB(31,0)=-1 THEN NT=NT-1:PRINT"Humm!  It was Filet Mignon, my favorite dish.":OB(31,0)=0:GOSUB 1720:GOTO 120
1400  PRINT"I think that ";OB$(NO);" would give me indigestion, and I don't have any Pepto-Bismol.":GOSUB 1720:GOTO 120
1410  IF VB<>30 THEN 1450
1420  IF CP<>10 AND CP<>11 THEN PRINT"Nothing happened.":GOSUB 1720:GOTO 120
1430  PRINT"Nice try, but that's an old, worn out magic word."
1440  GOSUB 1720:GOTO 120
1450  PRINT"I don't know how to do that.":GOSUB 1720:GOTO 120
1460  FOR I=1 TO 1000:NEXT I
1470  PRINT"Out of a maximum of 175 points, you have scored";:J=0
1480  FOR I=1 TO LO:IF OB(I,0)=1 THEN J=J+OB(I,1)
1490  NEXT I
1500  PRINT J;" points."
1510  IF J=175 THEN ?"All give tribute to you, ADVENTURER GRANDMASTER":goto 1590
1520  IF J>165 THEN PRINT"Your score is Master Adventurer Class A.":GOTO 1590
1530  IF J>150 THEN PRINT"Your score is Master Adventurer Class B.":GOTO 1590
1540  IF J>140 THEN PRINT"You are";CHR$(34);"Junior Master";CHR$(34):goto 1590
1550  IF J>120 THEN PRINT"You are now a Seasoned Adventurer":goto 1590
1560  IF J>110 THEN ?"You have the rating: Experienced Adventurer":goto 1590
1570  IF J>100 THEN ?"Your score is a Novice Class Adventurer.":goto 1590
1580  PRINT"You are obviously a rank amateur.  Better luck next time."
1590  '
1600  END
1610  PRINT"GADZOOKS!!!  A giant bug just walked in to kill me!!!"
1620  FF=1
1630  GOSUB 1720
1640  IF NO$="Sesame" AND VB$="Open" THEN PRINT"The bug has shrunk to it's proper size and scurried away.":GOTO 1700
1650  IF NO<>20 OR VB<>15 THEN PRINT"HELP ME!!!  I'm being devoured by a giant bug!!!  The end is near!  OW!!  This hurts!!  I'm dying...dying...DEAD!!!":GOTO 1460
1660  IF OB(2,0)<>-1 THEN NO=2:PRINT"I don't have a sword!!!":GOTO 1650
1670  IF SW=8 THEN PRINT"My sword is dull, remember???":NO=2:GOTO 1650
1680  PRINT"Ding! Dong!  The bug is dead, the bug is dead!!!"
1690  SW=SW+1:IF SW=8 THEN PRINT"My sword is dull now."
1700  GOSUB 1720:GOTO 120
1710  END
1720  PRINT:INPUT"Enter your command";CM$:PRINT
1730  IF CM$="ABRA CADABRA" AND F5<3 AND FF=1 THEN NO$="SESAME":VB$="OPEN":FF=0:F5=F5+1:RETURN
1740  VB$="":NO$="":VB=0:NO=0
1750  LC=LEN(CM$):FOR I=1 TO LC
1754  IF MID$(CM$,I,1) >"0" THEN VB$=VB$+MID$(CM$,I,1) ELSE GOTO 1760
1755  NEXT I
1760  FOR I=1 TO NV:IF VB$(I)=VB$ THEN VB=I:GOTO 1780 ELSE NEXT I
1770  VB=0:NO$=VB$:GOTO 1800
1780  IF LEN(VB$)+1>=LEN(CM$) THEN NO=0: RETURN
1790  NO$=RIGHT$(CM$,LEN(CM$)-1-LEN(VB$))
1800  FOR I=1 TO NN:IF NO$(I)=NO$ THEN 1820 ELSE NEXT I
1810  NO=0:RETURN
1820  NO=I:RETURN
1830  PRINT P$(CP):PRINT
1840  FOR I=1 TO LO:IF OB(I,0)=CP THEN PRINT"There is ";OB$(I);" here.":PRINT
1850  NEXT I
1860  PRINT"I can go :     ";:F2=0
1870  FOR I=1 TO 4:IF P(CP,I)<>0 THEN PRINT NO$(I+22);"  ";:F2=1
1880  NEXT I:IF F2=0 THEN PRINT"Nowhere!"
1890  IF CP=18 AND OB(3,0)=-1 THEN PRINT:PRINT M1$
1900  IF RND(35)=5 AND CP<>1 AND CP<>37 AND CP<>27 THEN PRINT:GOTO 1610
1910  IF FD>4 THEN PRINT:PRINT"If you'd like, you can make it easy on yourself by typing                       N, S, E, or W instead of NORTH, SOUTH, etc.":FD=0
1920  RETURN
1930  NP=37:DIM P$(NP)
1940  REM
1950  P$(1)="I am in a ship.  On a computer screen in here it says:                          Ship will not function -- Fribulating Gonkulator is burned out.                  It is obvious that this ship has crashed."
1960  P$(2)="I'm in a cobblestone hallway.  I can hear CHIRPING BUGS NEARBY"
1965  DATA 2,6,5,4,8,1,3,5
1970  P$(3)="I'm in a dark room...OH NO!!! There are GIANT bugs all around me!!"
1975  DATA 0,0,0,2
1980  P$(4)="I'm in a small room.  A scribbling here says: >>ABBADAC ARBA <<"
1985  DATA 7,0,1,0
1990  P$(5)="I'm in a dusty cobblestone hallway"
1995  DATA 0,25,2,1
2000  P$(6)="I'm in a dusty place.  It is very dark in here  I'm scared!"
2005  DATA 1,24,0,0
2010  P$(7)="I'm in low crawl space.  It seems  we're not SUPPOSED to be here!"
2015  DATA 0,4,15,0
2020  P$(8)="I'm in a room with rock walls.  Imbedded in the walls are Rubies"
2025  DATA 9,2,0,13
2030  P$(9)="I'm in a dark room.  This one is not so scary. I hear groans"
2035  data 10,8,23,0
2040  P$(10)="I'm on the south side of a chasm.  Molten lava is beneath me."
2045  data 11,9,0,0
2050  P$(11)="I'm on the north side of the chasm."
2055  data 16,10,0,0
2060  P$(12)="I'm in a maze of twisty little passages."
2065  data 12,12,13,14
2070  P$(13)=P$(12)
2075  data 13,13,8,12
2080  P$(14)=P$(12)
2085  data 14,15,12,14
2090  P$(15)=P$(12)
2095  data 14,15,15,7
2100  P$(16)="on a wood platform.  A sign warns: Go back! Go S! weak bridge N"
2105  data 17,11,0,0
2110  P$(17)="dusty passage.  A sign points east and says:To TROLLS PLACE"
2115  data 0,16,18,0
2120  P$(18)="A voice booms out:Who dares enter my place (sounds like a TROLL"
2125  data 0,0,19,0
2130  P$(19)="I'm in the troll's palace.  It's breathtaking!!!"
2135  data 0,20,0,0
2140  P$(20)="I'm at one end of a secret passage."
2145  data 19,0,0,21
2150  P$(21)="I'm in a secret passage."
2155  data 21,22,20,21
2160  P$(22)=P$(21)
2165  data 21,22,22,23
2170  P$(23)=P$(21)
2175  data 23,23,22,9
2180  P$(24)="I'm in a huge ice cavern.  The ceiling and walls are all ice."
2185  data 6,26,25,0
2190  P$(25)="I'm in a room with many animals... Wait! They all ran away"
2195  data 5,0,0,0
2200  P$(26)="I'm in a room with traces of slime on the floor and walls."
2205  data 24,29,27,28
2210  P$(27)="I'm in Al's Diner???  There's a Coke machine. It says: Quarter "
2215  data 0,0,0,26
2220  P$(28)="I'm in a huge pit."
2230  DATA 0,0,26,0
2240  P$(29)="I'm in the hydra room.  The walls are all slime."
2245  DATA 26,30,31,32
2250  P$(30)="I'm in the dragon room.  It seems to decorated with dragons."
2255  data 29,34,0,33
2260  P$(31)="I'm in a torture chamber.  Let's get out of here quick!!"
2265  data 31,31,31,29
2270  P$(32)="This is the clam room.  The walls are solid clamshell"
2275  DATA 0,0,29,0
2280  P$(33)="I'm in a mammoth garden.  This is all plants."
2285  DATA 0,0,30,0
2290  P$(34)="I'm in the velvet room.  The walls and ceiling are velvet."
2295  DATA 30,34,35,0
2300  P$(35)="I'm in an Arabian room. ther is a machine oil slick nearby"
2305  DATA 36,37,0,34
2310  P$(36)="Treasure room.dwarfs guard some treasure.Nothing to flip over"
2315  DATA 0,35,0,0
2320  P$(37)="I'm at Mac's Earthdigger Bodyshop."
2325  DATA 35,0,0,0
2330  DIM P(37,4)
2335  FOR I = 1 TO 37
2336  FOR J = 1 TO 4
2337  READ P(I,J)
2338  NEXT J,I
2340  LO=33:DIM OB$(LO),OB(LO,1)
2350  OB$(1)="a set of keys":OB$(2)="a shiny sword"
2355  DATA 6,0,16,0
2360  OB$(3)="a parrot in a cage":OB$(4)="a gold nugget"
2365  DATA 25,5,4,10
2370  OB$(5)="a 35,000 carat diamond":OB$(6)="a cigarette lighter"
2375  DATA 7,10,28,0
2380  OB$(7)="a Quarter":OB$(8)="an enormous emerald"
2385  DATA 28,0,32,15
2390  OB$(9)="some silver bars":OB$(10)="a giant hydra with nine heads"
2395  DATA 33,15,29,0
2400  OB$(11)="a ming vase":OB$(12)="a bottle of Coke"
2405  DATA 30,10,0,0
2410  OB$(13)="an empty Coke bottle":OB$(14)="some tools"
2415  data 0,0,34,0
2420  OB$(15)="a large ruby":OB$(16)="gold bars"
2425  DATA 8,15,19,20
2430  OB$(17)="a diamond necklace":OB$(18)="a magic wand"
2435  data 19,25,14,0
2440  OB$(22)="a Fribulating Gonkulator"
2445  data 37,50
2450  OB$(20)="a giant bug asleep"
2455  DATA 31,0
2460  OB$(31)="some tasty food":OB$(32)="some human skeletons":OB(32,0)=31
2465  OB(32,1)=0
2470  OB$(33)="a dead hydra on the ground"
2480  FOR I=1 TO 20:READ OB(I,0),OB(I,1):NEXT I
2490  OB(22,0)=OB(19,0):OB(22,1)=OB(19,1)
2500  OB(19,1)=0:OB(19,0)=0
2510  OB(31,0)=27:OB(31,1)=0
2520  DATA KEYS,SWORD,PARROT,NUGGET,DIAMOND,LIGHTER,QUARTER,EMERALD,SILVER,HYDRA
2525  data VASE,COKE,BOTTLE,TOOLS,RUBY,GOLD,NECKLACE,WAND,SIGN,BUG,ALEXANDER
2526  DATA GONKULATOR,NORTH,SOUTH,EAST,WEST
2530  DATA N,S,E,W,FOOD,SKELETONS
2540  NN=32:DIM NO$(NN)
2550  FOR I=1 TO NN:READ NO$(I):NEXT I
2560  DATA GO,GET,LOOK,INVEN,SCORE,DROP,HELP,SAVE,LOAD,QUIT,SAY,DRINK,FEED,HIT
2561  DATA KILL,BURN,FIGHT,LIGHT,INSERT,TAKE,WAVE,RELEASE,CONTINUE,DESTROY,SIR
2562  DATA FIX,EAT,?,INVENTORY,HOCUS
2570  NV=30:DIM VB$(NV):FOR I=1 TO NV:READ VB$(I):NEXT I
2580  M1$="The parrot chants: Sir Alexander...Sir Alexander!"
2590  M2$="The troll scurries away in fear."
2600  M3$="Gulp gluk gulp! (burp)  That was refreshing!"
2610  DIM H$(NP)
2620  H$(25)="This parrot talks..."
2630  H$(29)="Cigar? Cigarette? Tipparillo?"
2640  H$(10)="You know this world is enchanted..."
2650  H$(12)="You can make the passages look less alike by dropping things."
2660  H$(13)=H$(12):H$(14)=H$(12):H$(15)=H$(12)
2670  H$(1)="I think we're supposed to leave what we find here."
2680  H$(35)="Often times oil means an auto bodyshop is nearby."
2690  H$(31)="The bug will not bother you it is asleep.                                       Hint:  If you linger too long in this room it will wake up!"
2700  H$(2)="You know, in this enchanted world, many things that                             are small on earth are very large..."
2710  H$(20)="Try to find your way to the other end, dummy!!":H$(23)=H$(20)
2720  RETURN
32000 title$=" A 520ST Adventure "
32001 poke systab+24,1 : ' Don't need to see this...
32002 a# = gb : ' Fetch globals address
32003 gintin = peek(a#+8) : ' AES int_in array
32004 poke gintin+0,peek(systab+8) : ' OUTPUT window handle
32005 poke gintin+2,2 : ' we're changing it's name
32006 s# = gintin+4 : ' DBL address for long poke
32007 title$ = title$ + chr$(0) : ' assure zero terminator
32008 poke s#,varptr(title$) : ' title of new window
32009 gemsys(105) : ' wind_set AES call
32010 poke systab+24,0 : ' Turn things back on
32011 return
