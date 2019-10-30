0 '
1 ' Easy-Windows.
2 ' Fenˆtres textes : Programme de d‚mo No 3.
3 '                   Saisie dans une fenˆtre.
4 '
5 ' Auteur Easy-Windows : Pierre-Jean Goulier.
6 ' ½ Start Micro & P-Jean Goulier.
7 '
8 Easy_Init
9 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
10 Twin_Open(F%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L,37,26,"Table de multiplication","[ESC] : Calcul - [CTRL]+[Q] : Fermer.",G_All%L)
11 '
12 New_Table
13 '
14 REPEAT
15   Easy_Mesag(Opt%L,X$,Ascii%L,Scan%L,Shift%L):Win_Domessages(X$)
16   IF Scan%L=1 THEN New_Table
17   IF Scan%L=30 AND Shift%L=4 THEN Win_Close(F%L)
18 UNTIL FN Win_Closed%L(F%L)
19 '
20-Fin
21 Easy_Exit
22 IF COMPILER THEN SYSTEM ELSE EDIT
23 '
24 DEF PROC New_Table
25   Twin_Cls(F%L):Twin_Setcursor(F%L,1,0):Win_Setslide(F%L,0,0)
26   Twin_Input(F%L,"Quelle table ? ","0",3)
27   REPEAT
28     Easy_Mesag
29     IF FN Win_Closed%L(F%L) THEN EXIT TO Fin
30   UNTIL FN Twin_Input%L(F%L)
31   Twin_Print(F%L)
32   N$=FN Twin_Input$(F%L):N%= VAL(N$)
33   FOR I%=1 TO 20
34     Twin_Print(F%L, STR$(I%)+" x "+N$+" ="+ STR$(N%*I%))
35   NEXT I%
36   Twin_Print(F%L):Twin_Print(F%L,"Termin‚.")
37 RETURN
