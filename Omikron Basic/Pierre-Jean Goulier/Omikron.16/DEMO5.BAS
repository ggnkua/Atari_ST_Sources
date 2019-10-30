0 '
1 ' Easy-Windows.
2 ' Fenˆtres textes : Programme de d‚mo No 5.
3 '                   Capture de blocs ASCII.
4 '
5 ' Auteur Easy-Windows : Pierre-Jean Goulier.
6 ' ½ Start Micro & P-Jean Goulier.
7 '
8 Easy_Init
9 Win_Getwork(Desktop,Xdesk,Ydesk,Wdesk,Hdesk)
10 Twin_Open(F1,Xdesk,Ydesk,Wdesk,Hdesk\2,100,100,"Fenˆtre Texte No 1","Get block : CTRL Clic",G_All)
11 Twin_Open(F2,Xdesk,Ydesk+Hdesk\2,Wdesk,Hdesk\2,100,100,"Fenˆtre Texte No 2","Put block : CTRL Clic",G_All-G_Close)
12 Twin_Cls(F1):Twin_Cls(F2)
13 '
14 Nom$="":Index$="*.*"
15 Easy_Fsel(Nom$,Index$,"Chargez un fichier ASCII",Cancel)
16 IF NOT Cancel THEN
17   OPEN "I",1,Nom$
18   WHILE NOT EOF(1)
19     LINE INPUT #1,A$:Twin_Iprint(F1,A$)
20   WEND
21   CLOSE 1
22 ENDIF
23 Win_Redraw(F1):Win_Top(F1)
24 '
25 REPEAT
26   Easy_Mesag(Opt,X$,Mx,My,Mb,Shift):Win_Domessages(X$)
27   IF Mb=1 AND Shift=4 THEN
28     Win_Mousepos(Fen,Mx,My,C,L)
29     IF Fen=F1 THEN Twin_Mouseget_Block(F1,A$)
30     IF Fen=F2 THEN Twin_Mouseput_Block(F2,A$)
31   ENDIF
32 UNTIL FN Win_Closed(F1)
33 '
34 Easy_Exit
35 IF COMPILER THEN SYSTEM ELSE EDIT
