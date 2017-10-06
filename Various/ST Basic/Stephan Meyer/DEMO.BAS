1     ' *****************************
2     ' *                           *
3     ' *           demo            *
4     ' *                           *
5     ' * Grafikdemo aus'm Handbuch *
6     ' *     + PUBLIC DOMAIN +     *
7     ' *            by             *
8     ' *                           *
9     ' *       Stephan Meyer       *
10    '*                           *
11    '*****************************
15    CLEARW 2:FULLW 2
20    QUADRATE: A=2:B=3:L=61:W=56
30    X=A:Y=B
40    LINEF X,Y,X+1,Y
50    LINEF X+1,Y,X+1,Y+W
60    LINEF X+1,Y+W,X,Y+W
70    LINEF X,Y+W,X,Y
80    X=X+61
90    IF X>600 THEN X=A:Y=Y+56
100   IF Y>320 THEN 120
110   GOTO 40
120   A=A+2:B=B+2:L=L-4:W=W-4
130   IF W<0 THEN 150
140   GOTO 30
150   GOSUB VERZOEGERUNG
160   LINIEN: X=0:Y=0
170   WHILE X<614
180   LINEF 307,172,X,Y
190   X=X+5
200   WEND
210   WHILE Y<344
220   LINEF 307,172,X,Y
230   Y=Y+3
240   WEND
250   WHILE X>0
260   LINEF 307,172,X,Y
270   X=X-5
280   WEND
290   WHILE Y>0
300   LINEF 307,172,X,Y
310   Y=Y-3
320   WEND
330   GOSUB VERZOEGERUNG
340   ENTWURF: X1=1:X2=614:Y1=1:Y2=343
350   LINEF X1,Y1,X2,Y1
360   LINEF X2,Y1,X2,Y2
370   LINEF X2,Y2,X1,Y2
380   LINEF X1,Y2,X1,Y1
390   X1=X1+2:X2=X2-2:Y1=Y1+2:Y2=Y2-2
400   IF Y2>-0   THEN 350
410   GOSUB VERZOEGERUNG
420   END
430   VERZOEGERUNG: FOR Z=1 TO 5000:NEXT
440   CLEARW 2:RETURN
