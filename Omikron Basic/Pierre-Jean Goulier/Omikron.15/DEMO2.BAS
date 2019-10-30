 '
 ' Easy-Windows.
 ' Programme de d‚monstration No 2.
 ' G‚rer plusieurs fenˆtres graphiques.
 '
 ' ½ P-Jean Goulier (Annybal) & Start Micro / 1994.
 '
 CLEAR 200000
 Easy_Init
 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 Gwin_Open(F1%L,Xdesk%L,Ydesk%L,Wdesk%L\2,Hdesk%L,"FENETRE 1","Des cercles...")
 Gwin_Open(F2%L,Xdesk%L+Wdesk%L\2,Ydesk%L,Wdesk%L\2,Hdesk%L,"FENETRE 2","Des carr‚s...",G_All%L-G_Close%L)
 '
 Gwin_Activate(F1%L)
 MOUSEOFF
 FOR I%=1 TO 20
   FILL COLOR = RND(14)+1: FILL STYLE =2, RND(24)+1
   PCIRCLE RND(Wdesk%L), RND(Hdesk%L), RND(50)+20
 NEXT I%
 MOUSEON
 Gwin_Activate(F2%L)
 MOUSEOFF
 FOR I%=1 TO 20
   FILL COLOR = RND(14)+1: FILL STYLE =2, RND(24)+1
   PBOX RND(Wdesk%L), RND(Hdesk%L),60,60
 NEXT I%
 MOUSEON
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