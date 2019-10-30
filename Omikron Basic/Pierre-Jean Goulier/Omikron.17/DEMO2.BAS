 '
 ' Easy-Windows.
 ' Fenˆtres utilisateurs.
 '
 ' Programme de d‚monstration No 2.
 '
 ' Auteur Easy-Windows : Pierre-Jean Goulier
 ' Un histogramme.
 ' (c) Start Micro & P-Jean Goulier / 1994
 '
 '
 Easy_Init: XBIOS (Rez%,4)
 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 Twin_Open(F1%L,Xdesk%L,Ydesk%L,Wdesk%L\2,Hdesk%L,80,50,"Fenˆtre Texte","Entrez vos donn‚es...",G_All%L)
 Twin_Cls(F1%L):Twin_Input(F1%L,"Combien de donn‚es : ","0",2)
 '
 REPEAT :Easy_Mesag("fermer"): UNTIL FN Twin_Input%L(F1%L)
 N%= VAL(FN Twin_Input$(F1%L))-1
 DIM A%L(N%):S%L=0
 '
 Twin_Print(F1%L)
 FOR I%=0 TO N%
   Twin_Print_(F1%L,"Donn‚e No"+ STR$(I%+1))
   Twin_Input(F1%L," : ","0",3)
   REPEAT :Easy_Mesag("fermer"): UNTIL FN Twin_Input%L(F1%L)
   A%L(I%)= VAL(FN Twin_Input$(F1%L)):S%L=S%L+A%L(I%)
 NEXT I%
 '
 Uwin_Open(F2%L,Xdesk%L+Wdesk%L\2,Ydesk%L,Wdesk%L\2,Hdesk%L,1000,1000,"Fenˆtre Utilisateur","Exemple : un grapheur...",G_All%L,"graphe")
 REPEAT :Easy_Mesag: UNTIL FN Win_Closed%L(F2%L) OR FN Win_Closed%L(F1%L)
 Fin
 '
 DEF PROC Fin
   Easy_Exit
   IF COMPILER THEN SYSTEM ELSE EDIT
 RETURN
 '
-Fermer
   FORM_ALERT (1,"[2][|Voulez-vous tout arrˆter ?][Oui|Non]",Rep%)
   IF Rep%=1 THEN Fin
   RETURN
 '
-Graphe
   BITBLT X%L,Y%L,W%L,H%L TO X%L,Y%L,W%L,H%L,0
   L%=Wdesk%L\(N%+1): IF L%<20 THEN TEXT HEIGHT =4
   FOR I%=0 TO N%
     IF Rez%=0 THEN
       FILL STYLE =1,1
       IF I%>=15 THEN FILL COLOR =I%-15 ELSE FILL COLOR =I%
     ELSE
       IF Rez%=1 THEN FILL COLOR =2 ELSE FILL COLOR =1
       IF I%>=15 THEN FILL STYLE =2,I%+1-15 ELSE FILL STYLE =2,I%+1
     ENDIF
     H%=Hdesk%L*A%L(I%)\S%L*.5:X%=Xtop%L+2+I%*(L%+1):Y%=Ytop%L+Hdesk%L-H%
     PBOX X%,Y%,L%,H%: BOX X%,Y%,L%,H%
     TEXT Xtop%L+I%*(L%+1),Ytop%L+Hdesk%L+20, STR$(A%L(I%))
     NEXT I%
   RETURN
