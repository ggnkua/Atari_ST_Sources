 '
 ' Easy-Windows.
 ' Fenˆtres utilisateurs.
 '
 ' Programme de d‚monstration No 1.
 ' Affichage de grands cercles.
 ' Auteur Easy-Windows : Pierre-Jean Goulier
 '
 ' (c) Start Micro & P-Jean Goulier / 1994
 '
 Easy_Init
 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 Uwin_Open(F%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L,1000,1000,"Fenˆtre Utilisateur","Des cercles...",G_All%L,"REDRAW")
 '
 REPEAT
   Easy_Mesag
 UNTIL FN Win_Closed%L(F%L)
 Easy_Exit
 IF COMPILER THEN SYSTEM ELSE EDIT
 '
-Redraw
   BITBLT X%L,Y%L,W%L,H%L TO X%L,Y%L,W%L,H%L,0
   Xm%L=Xtop%L+500:Ym%L=Ytop%L+500
   FOR R%=1 TO 500 STEP 30
     CIRCLE Xm%L,Ym%L,R%
   NEXT R%
   RETURN
