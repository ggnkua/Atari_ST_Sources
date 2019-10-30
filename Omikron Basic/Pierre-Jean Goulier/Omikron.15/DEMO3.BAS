 '
 ' Easy-Windows.
 ' Programme de d‚monstration No 3.
 ' Charger une image DEGAS dans une fenˆtre graphique.
 '
 ' ½ P-Jean Goulier (Annybal) & Start Micro / 1994.
 '
 Easy_Init
 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 Gwin_Open(F1%L,Xdesk%L+30,Ydesk%L+30,Wdesk%L-60,Hdesk%L-60,"FENETRE GRAPHIQUE","")
 Win_Redraw(F1%L)
 '
 Save_Pal%L= MEMORY(32): MEMORY_MOVE $FF8240,32 TO Save_Pal%L
 Nom$="":Index$="*.PI?"
 Easy_Fsel(Nom$,Index$,"Chargez une image DEGAS",Cancel%L)
 IF NOT Cancel%L THEN
   OPEN "U",1,Nom$: SEEK 1,2,0
   GET 1,$FF8240,32: GET 1,FN Gwin_Space%L(F1%L),32000
   CLOSE 1
   Win_Redraw(F1%L):Win_Info(F1%L,Nom$)
 ENDIF
 '
 REPEAT
   Easy_Mesag("fermer")
 UNTIL FN Win_Closed%L(F1%L)
 '
 Easy_Exit
 MEMORY_MOVE Save_Pal%L,32 TO $FF8240
 IF COMPILER THEN SYSTEM ELSE EDIT
 '
-Fermer
   FORM_ALERT (1,"[3][|Voulez-vous vraiment|quitter le programme ?][Oui|Non]",Choix%)
   IF Choix%=1 THEN Win_Close(F1%L)
   RETURN
 '
