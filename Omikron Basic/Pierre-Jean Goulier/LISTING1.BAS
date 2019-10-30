0 CLS
1 OPEN "U",1,"A:\ESSAI.DAT"
2 OPEN "O",2,"A:\INDEX.DAT"
3 REPEAT
4   N$="":A$=""
5   INPUT @(2,6);"Nom : ";N$ USING "aU",R,20
6   IF N$="" THEN EXIT
7   INPUT @(4,2);"Adresse : ";A$ USING "a0%",R,65
8   WRITE #2,N$, LEN(A$)
9   PUT 1,A$
10 UNTIL 0
11 CLOSE 2
12 '
13 CLS : PRINT : PRINT "Lecture du fichier..."
14 SEEK 1,0
15 REPEAT
16   Nom$="":A$="":Cpt%=0
17   INPUT @(3,6);"Nom : ";Nom$ USING "aU",R,20
18   IF Nom$="" THEN EXIT
19   OPEN "I",2,"A:\INDEX.DAT"
20   WHILE NOT EOF(2)
21     INPUT #2,N$,L%:Cpt%=Cpt%+L%
22     IF Nom$=N$ THEN
23       SEEK 1,Cpt%-L%: GET 1,A$,L%
24       EXIT TO Ok
25     ENDIF
26   WEND
27   PRINT @(5,2); CHR$(7); CHR$(27);"K";
28   PRINT "Fiche non trouv‚e !"
29   GOTO Suite
30  -Ok
31   PRINT @(5,2); CHR$(27);"K";Nom$
32   PRINT @(6,2); CHR$(27);"K";A$
33  -Suite
34   CLOSE 2
35 UNTIL 0
36 '
37 CLOSE : CLS : END
 
