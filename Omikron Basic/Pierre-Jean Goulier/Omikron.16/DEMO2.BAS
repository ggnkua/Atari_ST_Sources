0 '
1 ' Easy-Windows.
2 ' Fenˆtres textes : Programme de d‚mo No 2.
3 '                   Chargement d'un fichier ASCII. Affichage interne.
4 '
5 ' Auteur Easy-Windows : Pierre-Jean Goulier.
6 ' ½ Start Micro & P-Jean Goulier.
7 '
8 Easy_Init
9 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
10 Twin_Open(F%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L,100,100,"Fenˆtre Texte","",G_All%L)
11 Twin_Cls(F%L)
12 '
13 Nom$="":Index$="*.*"
14 Easy_Fsel(Nom$,Index$,"Chargez un fichier ASCII",Cancel%L)
15 IF NOT Cancel%L THEN
16   Win_Info(F%L,Nom$)
17   OPEN "I",1,Nom$
18   WHILE NOT EOF(1)
19     LINE INPUT #1,A$:Twin_Iprint(F%L,A$)
20   WEND
21   CLOSE 1
22 ENDIF
23 Win_Redraw(F%L)
24 '
25 REPEAT
26   Easy_Mesag
27 UNTIL FN Win_Closed%L(F%L)
28 '
29 Easy_Exit
30 IF COMPILER THEN SYSTEM ELSE EDIT
