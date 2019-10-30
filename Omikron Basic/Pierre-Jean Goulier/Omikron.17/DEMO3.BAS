 '
 ' Easy-Windows.
 ' Fenˆtres utilisateurs.
 '
 ' Programme de d‚monstration No 3.
 ' Affichage d'une image IMG.
 ' Auteur Easy-Windows : Pierre-Jean Goulier
 '
 ' (c) Start Micro & P-Jean Goulier / 1994
 '
 CLEAR 200000
 MEMORY_BLOCK 01,320,Depac_Img%L
 IF NOT COMPILER THEN BLOAD "DEPACIMG.BIN",Depac_Img%L
 Easy_Init: XBIOS (Rez%,4):Plans%=1 SHL (2-Rez%)
 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 Load_Img(Cancel%L,Wpic%,Hpic%): IF Cancel%L THEN Fin
 '
 REPEAT
   Easy_Mesag("fermer")
 UNTIL FN Win_Closed%L(F%L)
 Fin
 '
-Fermer
   FORM_ALERT (1,"[3][|Charger une image ou quitter ?][Charger|Quitter]",Choix%)
   IF Choix%=1 THEN
     Win_Close(F%L):Load_Img(Cancel%L,Wpic%,Hpic%): IF Cancel%L THEN Fin
   ELSE
     Win_Close(F%L)
   ENDIF
 RETURN
 '
-Redraw
   BITBLT Objet%L TO Xtop%L,Ytop%L,Wpic%,Hpic%
 RETURN
 '
 DEF PROC Fin
   FRE (Depac_Img%L): FRE (Source%L): FRE (Objet%L)
   Easy_Exit: CLEAR $10000
   IF COMPILER THEN SYSTEM ELSE EDIT
 RETURN
 '
 DEF PROC Load_Img(R Cancel%L,R Wpic%,R Hpic%)
   FRE (Source%L): FRE (Objet%L)
   Nom$="":Index$="*.IMG"
   Easy_Fsel(Nom$,Index$,"Chargez une image",Cancel%L)
   IF Cancel%L THEN EXIT
   OPEN "I",1,Nom$:Source%L= MEMORY( LOF(1)): CLOSE 1
   BLOAD Nom$,Source%L
   IF Plans%<> WPEEK(Source%L+4) THEN
     FORM_ALERT (1,"[2][|Mauvaise r‚solution !][Abandon]")
     Fin
   ENDIF
   Wpic%= WPEEK(Source%L+12):Hpic%= WPEEK(Source%L+14)
   Size%L=6+(Wpic%+15) SHR 4*Hpic%*2*Plans%:Objet%L= MEMORY(Size%L)
   CALL Depac_Img%L(L Source%L,L Objet%L+6,Plans%,Wpic%,Hpic%)
   WPOKE Objet%L,Plans%*2: WPOKE Objet%L+2,Wpic%: WPOKE Objet%L+4,Hpic%
   Uwin_Open(F%L,Xdesk%L,Ydesk%L,- MIN(Wdesk%L,Wpic%),- MIN(Hdesk%L,Hpic%),Wpic%,Hpic%,Nom$,"",G_All%L-G_Info%L,"redraw")
 RETURN
