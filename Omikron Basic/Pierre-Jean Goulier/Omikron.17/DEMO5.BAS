 '
 ' Easy-Windows.
 ' Commandes-Fichiers.
 '
 ' Programme de démonstration No 5.
 ' Recherche d'un fichier.
 ' Auteur Easy-Windows : Pierre-Jean Goulier
 '
 ' (c) Start Micro & P-Jean Goulier / 1994
 '
 Easy_Init
 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 Twin_Open(F%L,Xdesk%L+50,Ydesk%L+50,Wdesk%L-100,Hdesk%L-100,80,100,"Easy-Windows","Recherche de fichiers...",G_All%L)
 Twin_Cls(F%L)
 '
 REPEAT
   Twin_Input(F%L,"Lecteur : ","au",1)
   REPEAT :Easy_Mesag("fermer"): UNTIL FN Twin_Input%L(F%L)
   IF FN Twin_Input$(F%L)= CHR$(0) THEN EXIT
   Drv%= ASC(FN Twin_Input$(F%L))-65
   Twin_Input(F%L,"Masque : ","a%u",12)
   REPEAT :Easy_Mesag("fermer"): UNTIL FN Twin_Input%L(F%L)
   IF FN Twin_Input$(F%L)= CHR$(0) THEN EXIT
   Mask$=FN Twin_Input$(F%L)
   Search_File(Drv%,Mask$,Ch$)
   IF Ch$="" THEN
     Twin_Print(F%L,"Pas trouvé...")
   ELSE
     Twin_Print(F%L,Ch$)
   ENDIF
   Twin_Print(F%L)
 UNTIL 0
 '
-Fermer
   Twin_Stop_Input(F%L):Win_Close(F%L)
   Easy_Exit
   IF COMPILER THEN SYSTEM ELSE EDIT
