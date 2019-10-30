 '
 ' Easy-Windows.
 ' Les messages d'erreurs. D‚mo No 2.
 '
 ' Auteur Easy-Windows : Pierre-Jean Goulier
 '
 ' (c) Start Micro & P-Jean Goulier / 1994
 '
 Easy_Init
 Twin_Open(F%L,20,20,300,180)
 Twin_Print_(F%L,"Une erreur, ‡a arrive... ")
 Twin_Input(F%L,"Oui ou Non ? ")
 REPEAT
   Easy_Mesag("fermer")
 UNTIL FN Twin_Input%L(F%L)
 Easy_Exit
 END
 '
-Fermer
   Twin_Stop_Input(F%L)
   Win_Close(F%L)
   RETURN

