 '
 ' Easy-Windows.
 ' Les messages d'erreurs. D‚mo No 1.
 '
 ' Auteur Easy-Windows : Pierre-Jean Goulier
 '
 ' (c) Start Micro & P-Jean Goulier / 1994
 '
 Easy_Init
 Gwin_Open(F%L,100,100,200,200)
 Twin_Print(F%L,"Bla bla bla...")
 REPEAT
   Easy_Mesag
 UNTIL FN Win_Closed%L(F%L)
 Easy_Exit
 END
 '
