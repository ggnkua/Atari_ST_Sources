0 '
1 ' Easy-Windows.
2 ' Fenˆtres textes : Programme de d‚mo No 1.
3 '                   Affichage simple.
4 '
5 ' Auteur Easy-Windows : Pierre-Jean Goulier.
6 ' ½ Start Micro & P-Jean Goulier.
7 '
8 Easy_Init
9 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
10 Twin_Open(F%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
11 Twin_Cls(F%L)
12 '
13 FOR I%=1 TO 10
14   Twin_Print(F%L,"J'affiche la ligne"+ STR$(I%))
15 NEXT I%
16 Twin_Print(F%L):Twin_Print(F%L,"Termin‚.")
17 '
18 REPEAT
19   Easy_Mesag
20 UNTIL FN Win_Closed%L(F%L)
21 '
22 Easy_Exit
23 IF COMPILER THEN SYSTEM ELSE EDIT
