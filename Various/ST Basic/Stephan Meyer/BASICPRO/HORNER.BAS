1     ' *****************************
2     ' *                           *
3     ' *       horner schema       *
4     ' *                           *
5     ' *    Ableitungsberechnung   *
6     ' *     + PUBLIC DOMAIN +     *
7     ' *            by             *
8     ' *                           *
9     ' *       Stephan Meyer       *
10    '*                           *
11    '*****************************
14    '
15    ' +++  HORNER SCHEMA +++
20    ' 
30    '       by  S. MEYER
40    '  ^^^^^^^^^^^^^^^^^^^^
50    DIM A(20),B(20)
60    GOSUB HEADLINE
70    GOTOXY 3,16:INPUT "FUNKTIONSGRAD  =  ";N
80    GOTOXY 3,18:INPUT "GEWUENSCHTES X =  ";X
90    A=7
100   GOSUB HEADLINE
110   FOR K=N TO 0 STEP -1
120   GOTOXY 6,A:?"A("K") =  ";:INPUT A(K)
130   C(K)=A(K)
140   A=A+1
150   NEXT
160   GOSUB HEADLINE
170   ' *ALGORITHMUS*
180   GOTOXY 2,6
190   FOR I=1 TO N
200   FOR K=N-1 TO I-1 STEP -1
210   C(K)=C(K+1)*X+C(K)
220   NEXT K,I
230   ?"F(X) = ";
240   FOR K=N TO 0 STEP -1
250   IF A(K)=0 THEN GOTO 300
260   IF A(K)>O AND K<>N THEN ?"+";
270   IF K=0 THEN ?A(0);:GOTO 290
280   IF K=1 THEN ?A(1);"X"; ELSE ?A(K);"X^"K;
290   ?" ";
300   NEXT K
310   A=9
320   FOR I=0 TO N
330   IF I=0 THEN F=1 ELSE F=F*I
340   C(I)=C(I)*F
350   GOTOXY  8,A:?"F";I;"(";X;") =";
360   ? USING "######.##"    ;C(I)
370   A=A+1
380   NEXT
390   E$=CHR$(INP(2))
400   END
410   HEADLINE:FULLW 2:CLEARW 2
420   GOTOXY 10,2:?"HORNER SCHEMA"
430   GOTOXY 3,4 :?"Funktionswert und Ableitung an der Stelle x"
440   RETURN
