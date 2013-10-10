 '
 ' Demander les noms de fichiers par la boŒte de s‚lection des fichiers
 ' OMIKRON-BASIC                             FSEL.BAS
 '
 ' Ce programme n'a pas besoin de la bibliothŠque GEMLIB.BAS.
 ' Nous devons d‚sactiver le curseur texte
 ' et faire afficher le pointeur de la souris
 '
 PRINT CHR$(27);"f";'  Curseur d‚sactiv‚
 MOUSEON
 '
 Filename(Ret%L,"*.*","",Nomfich$)
 IF Ret%L
   THEN PRINT Nomfich$
   ELSE PRINT "S‚lection non valide!"
 ENDIF
 '
 END
 '
 '
 DEF PROC Dgetpath(R Chemin$)'  indique le r‚pertoire courant
   Chemin$= STRING$(64,0)'  Faire de la place
   Adr%L= LPEEK( VARPTR(Chemin$))+ LPEEK( SEGPTR +28)
   GEMDOS (,$47, HIGH(Adr%L), LOW(Adr%L),0)' 0=lecteur courant
   '
   ' supprimer tous les octets nuls de la chaŒne:
   '
   Chemin$= LEFT$(Chemin$, INSTR(Chemin$, CHR$(0))-1)
 RETURN
 '
 DEF PROC Filename(R Back%L,Masque$,Default$,R Affchge$)
   LOCAL Lect_Courant%L,Chemin$
   GEMDOS (Lect_Courant%L,$19)' indiquer le lecteur courant
   Dgetpath(Chemin$)' D‚terminer le chemin du lecteur courant
   Chemin$= CHR$( ASC("A")+Lect_Courant%L)+":"+Chemin$+"\"+Masque$
   '
   FILESELECT (Chemin$,Default$,Flag%L)
   '
   IF Flag%L=0 OR Default$="" THEN Back%L=0: RETURN
   '
   Back%L=1
   Affchge$= LEFT$(Chemin$, LEN(Chemin$)- INSTR( MIRROR$(Chemin$)+"\","\"))+"\"+Default$
 RETURN
