5     REM  *****************************************************
6     REM  ***          Dateiverwaltung  Version  1.4        ***
7     REM  ***          PUBLIC DOMAIN  Oktober 1985          ***
8     REM  ***          Created by Wolfgang Zweygart         ***
9     REM  *****************************************************
10    CLEARW 2:OPTION BASE 1:DIM NA$(20),NA(20),DR(20)
20    FULLW 2:CLEARW 2:GOTOXY 0,0:A%=-1
30    PRINT "Neuer”ffnung      --> 1"
40    PRINT "Laden von Disk    --> 2"
50    INPUT A:IF A>2 OR A<1 THEN 30
60    ON A GOSUB 1810,720
70    REM ANFANG
80    REM MENUE
90    CLEARW 2:GOTOXY 0,0:PRINT "          Menue"
100   PRINT " Žnderung der Bezeichnungen                 --> 1"
110   PRINT " Eingabe neuer Daten                        --> 2"
120   PRINT " Programm verlassen, zurck ins BASIC       --> 3"
130   PRINT " Suche nach einem Stichwort / Buchstaben    --> 4"
140   PRINT " Anzeigen der gespeicherten Daten           --> 5"
150   PRINT " Hinausschreiben der Daten auf Diskette     --> 6"
160   PRINT " Žnderungen an den Daten                    --> 7"
170   PRINT " Drucken der gespeicherten Daten            --> 8"
175   PRINT " Laden einer neuen Datei                    --> 9"
180   GOSUB 2200:IF A<1 OR A>10 THEN 180
190   ON A GOSUB 1960,240,220,990,1610,630,280,1250,2300
200   GOTO 80
220   INPUT "Datei abspeichern (j/ ) :";A$:IF A$="J" OR A$="j" THEN GOSUB 630
230   END
240   N =N+1:GOSUB 520
250   INPUT "Weiter (j/n) :";A$:IF A$ = "J" OR A$ ="j" THEN 240
260   GOSUB 850
270   RETURN
280   REM ŽNDERUNGEN
290   CLEARW 2:GOTOXY 0,0:PRINT "Welcher Satz soll ge„ndert werden :"
300   A% =-1
310   GOSUB 1060
315   IF A%<0 THEN 360
320   PRINT "Was soll ge„ndert werden ?"
330   PRINT "L”schen                     --> 1"
340   PRINT "Korrekturen                 --> 2"
350   PRINT "Weitersuchen                --> 3"
360   PRINT "Nichts Žndern / Abbrechen   --> 4"
370   PRINT "Suche wiederholen           --> 5"
380   GOSUB 2200: IF A<1 OR A>5 THEN 315
385   IF A%<0 AND A<4 THEN 315
390   ON A GOTO 420,430,410,400,280
400   RETURN
410   I=I+1:GOSUB 1100:GOTO 320
420   FOR K=1 TO EL:B$(A%,K) ="  ":NEXT K:GOSUB 850:RETURN
430   PRINT "Was soll ge„ndert werden :"
440   FOR K=1 TO EL:PRINT " -->";K;"  ";NA$(K);
450   PRINT B$(A%,K):NEXT K:INPUT "Welche Nummer : ";A:IF A<1 OR A>EL THEN 430
455   A$=SPACE$(NA(A)):LSET A$=B$(A%,A)
460   PRINT " vorher : ";A$;"  ";
470   INPUT "Žnderung in :";A$:IF LEN(A$)>NA(A) THEN B$(A%,A)=LEFT$(A$,NA(A))
475   IF LEN(A$)=0 THEN PRINT "Unver„ndert !":GOTO 490
480   IF LEN(A$)<=NA(A) THEN B$(A%,A)=SPACE$(NA(A)):LSET B$(A%,A) =A$
490   INPUT "Weitere Žnderungen an diesem Satz (j/ ) ";A$
500   IF A$="J" OR A$="j" THEN 430
505   IF SO=A% THEN GOSUB 850
510   RETURN
520   REM EINGABE KB
530   FOR J=1 TO EL
540   GOSUB 570:B$(N,J) =D$
550   NEXT J
560   RETURN
570   REM EINGABE ZEILE
580   C$ ="":D$ =SPACE$(NA(J)):PRINT NA$(J);"  : ";
590   INPUT C$:IF LEN(C$)=0 THEN C$="???"
600   IF LEN(C$)>NA(J) THEN D$ =LEFT$(C