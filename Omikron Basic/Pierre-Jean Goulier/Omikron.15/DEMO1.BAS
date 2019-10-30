 '
 ' Easy-Windows.
 ' Programme de d‚monstration No 1.
 ' Dessiner dans une fenˆtre graphique.
 '
 ' ½ P-Jean Goulier (Annybal) & Start Micro / 1994.
 '
 Easy_Init
 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 Gwin_Open(F1%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 '
 Gwin_Activate(F1%L)
 MOUSEOFF : FILL STYLE =2,4: PCIRCLE Wdesk%L\2,Hdesk%L\2,Hdesk%L\2: MOUSEON
 Gwin_Disactivate
 '
 REPEAT
   Easy_Mesag
 UNTIL FN Win_Closed%L(F1%L)
 '
 Easy_Exit
 IF COMPILER THEN SYSTEM ELSE EDIT
 '
