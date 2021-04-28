10    REM ****  Golf  *****
20    REM By  R.A.Waddilove
30    REM (c) Atari ST User
40    REM *** ST  Basic ***
50    REM Med/Hi resolution
60    CLEAR:x=FRE("")
70    GOSUB init
80    FOR hole=1 TO 9
90    GOSUB tee
100   done=0
110   FOR golfer=1 TO players
120   status(golfer)=5
130   WHILE status(golfer)>4 and distance(golfer)>0
140   GOSUB hit.ball
150   GOSUB report
160   WEND
170   total(golfer)=total(golfer)+shots(golfer)
180   done=done+distance(golfer)
190   NEXT
200   IF done THEN GOTO 100
210   NEXT
220   CLEARW 2:GOTOXY 0,0
230   ?"The final scores are:"
240   GOSUB scores
250   ? name$(best);" has won!"
260   k$=INPUT$(1)
270   END
280   REM ----------------------
290   tee:
300   CLEARW 2:GOTOXY 0,0
310   RESTORE 1270
320   FOR i=1 TO hole
330   READ length,bunker(1),bunker(2),bunker(3)
340   NEXT
350   ?:?"HOLE:";hole;"- You are on the tee."
360   ?"=============================="
370   ?"This is a ";
380   IF RND(1)<0.5 THEN ?"dogleg left,"; ELSE ?"dogleg right,";
390   ? length;"yards long."
400   ?"Watch out for the bunkers";
410   ? bunker(1);",";bunker(2);"and";bunker(3);"yards from the green"
420   ?"and the trees down the ";
430   IF RND(1)>0.5 THEN ?"right"; ELSE ?"left";
440   ?" hand side of the fairway."
450   IF RND(1)<0.4 THEN ?"Take care, there's a strong cross wind."
460   GOSUB scores
470   FOR golfer=1 TO players
480   shots(golfer)=0
490   status(golfer)=5
500   WHILE status(golfer)>4
510   distance(golfer)=length
520   GOSUB hit.ball
530   GOSUB report
540   WEND
550   NEXT
560   RETURN
570   REM -------------------
580   hit.ball:
590   ?:?"It's ";name$(golfer);" to play-"
600   ?"You have taken";shots(golfer);"strokes so far on this hole,"
610   GOSUB bunker
620   ?"and you're";distance(golfer);"yards from the pin."
630   ?"Which club will you use - Wood, Iron or Putter (W/1-9/P)";
640   IF name$(golfer)="Atari" THEN GOSUB atari ELSE INPUT k$
650   IF k$="W" OR k$="w" THEN k$="0"
660   IF k$="P" OR k$="p" THEN k$="10"
670   k=VAL(k$):IF k<0 OR k>10 THEN GOTO 630
680   yards=INT((RND(1)*bat(k)/5)+bat(k))
690   IF yards>distance(golfer) THEN ?"Too hard, it's going past the hole-"
700   FOR j=1 TO 3
710   IF ABS(distance(golfer)-bunkerj)<5 THEN yards=INT(RND(1)*20)
720   NEXT
730   shots(golfer)=shots(golfer)+1
740   status(golfer)=1
750   r=INT(RND(1)*100)
760   IF r<5 THEN status(golfer)=5:RETURN
770   IF r<10 THEN status(golfer)=6:RETURN
780   IF r<15 THEN status(golfer)=7:RETURN
790   IF r<20 THEN status(golfer)=2
800   IF r<25 THEN status(golfer)=3
810   IF r<30 THEN status(golfer)=4
820   distance(golfer)=ABS(distance(golfer)-yards)
830   IF distance(golfer)<5 THEN ?"You've holed it!":distance(golfer)=0
840   For delay=1 TO 2000:NEXT
850   RETURN
860   REM --------------------
870   report:
880   IF distance(golfer)=0 THEN RETURN
890   RESTORE 980
900   FOR i=1 TO status(golfer)
910   READ msg$
920   NEXT
930   IF RND(1)>0.9 THEN ?"Wow! Just missed a seagull!"
940   GOSUB bunker
950   IF distance(golfer)<10 THEN msg$="You're on the green,"
960   ? msg$;distance(golfer);"yards from from the hole."
970   RETURN
980   DATA "A great shot:"
990   DATA "You're in the rough..."
1000  DATA "You've sliced it into the woods,"
1010  DATA "You've hooked it into the trees,"
1020  DATA "You've hit it out of bounds, you're still"
1030  DATA "Oh, no! Missed it! You're still"
1040  DATA "Whoops! Landed in a pond. You're still"
1050  REM --------------------
1060  init:
1070  FULLW 2:CLEARW 2:GOTOXY 0,0
1080  DIM bunker(3),name$(5),distance(5),shots(5),total(5),bat(10)
1090  INPUT "How many players";players
1100  FOR i=1 TO players
1110  ?"Name of player";i;
1120  INPUT name$(i)
1130  total(i)=0
1140  NEXT
1150  players=players+1
1160  name$(players)="Atari":total(players)=0
1170  RESTORE 1240
1180  FOR i=0 TO 10
1190  READ bat(i)
1200  NEXT
1210  RETURN
1220  REM ----------------------
1230  REM Club strengths
1240  DATA 200,180,165,140,120,100,80,60,30,15,3
1250  REM ---------------------
1260  REM Length,bunker1,bunker2,bunker3
1270  DATA 200,20,50,100
1280  DATA 300,25,50,75
1290  DATA 250,20,55,100
1300  DATA 400,35,170,200
1310  DATA 350,100,200,300
1320  DATA 200,20,30,75
1330  DATA 320,45,80,90
1340  DATA 510,20,40,80
1350  DATA 400,30,35,50
1360  REM ------------------------
1370  atari:
1380  k=10
1390  IF distance(golfer)>bat(k)+10 AND k>0 THEN k=k-1:GOTO 1390
1400  k$=CHR$(48+k)
1410  IF k=10 THEN k$="P"
1420  IF k=0 THEN k$="W"
1430  PRINT"?  ";k$
1440  FOR delay=1 TO 3000:NEXT
1450  RETURN
1460  REM --------------------------
1470  scores:
1480  best=1:PRINT
1490  FOR i=1 TO players
1500  IF total(i) THEN ? name$(i);" has taken";total(i);"strokes."
1510  IF total(i)<total(best) THEN best=i
1520  NEXT
1530  RETURN
1540  REM --------------------
1550  bunker:
1560  FOR j=1 TO 3
1570  IF ABS(distance(golfer)-bunker(j))<5 THEN ?"You're in a bunker-"
1580  NEXT
1590  RETURN
