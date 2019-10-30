 '
 ' Easy-Windows.
 ' Commandes-Fichiers.
 '
 ' Programme de d‚monstration No 4.
 ' Les commandes de manipulations de fichiers.
 ' Auteur Easy-Windows : Pierre-Jean Goulier
 '
 ' (c) Start Micro & P-Jean Goulier / 1994
 '
 '
 Easy_Init
 Win_Getwork(Desktop%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 Twin_Open(F%L,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L,80,25,"Easy-Windows","[ESC] : S‚lecteur.",G_All%L)
 Twin_Cls(F%L):Load_File
 '
 REPEAT
   Easy_Mesag(Opt%L,X$,Ascii%L,Scan%L,Shift%L):Win_Domessages(X$)
   IF Scan%L=1 THEN Load_File:Win_Redraw(F%L)
   IF Scan%L=30 AND Shift%L=4 THEN Win_Close(F%L)
 UNTIL FN Win_Closed%L(F%L)
 Easy_Exit: END
 '
 DEF PROC Load_File
   Nom$="":Index$="*.*"
   Easy_Fsel(Nom$,Index$,"* Chargez un fichier *",Cancel%L)
   IF Cancel%L THEN EXIT
   Twin_Cls(F%L)
   Twin_Iprint(F%L,"Nom complet : "+Nom$)
   Twin_Iprint(F%L,"Masque : "+Index$)
   Cut_Filename(Nom$,Ch$,N$,Ext$)
   Twin_Iprint(F%L,"Nom seul : "+N$)
   Twin_Iprint(F%L,"Chemin : "+Ch$)
   Twin_Iprint(F%L,"Extension : "+Ext$)
   Get_Infofile(Nom$,Size%L,D$,H$,Att%)
   Twin_Iprint(F%L,"Taille :"+ STR$(Size%L))
   Twin_Iprint(F%L,"Date : "+D$)
   Twin_Iprint(F%L,"Heure : "+H$)
   Twin_Iprint(F%L,"Attribut :"+ STR$(Att%))
   Twin_Iprint_(F%L,"On force l'extension *.PJG : ")
   Change_Ext(Nom$,".PJG"):Twin_Iprint(F%L,Nom$)
 RETURN
 '
