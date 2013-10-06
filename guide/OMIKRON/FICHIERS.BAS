 '
 ' Exemple de fichiers sous GEMDOS
 ' OMIKRON-BASIC    FICHIERS.BAS
 '
 Filename$="READ.ME"+ CHR$(0)
 Ligne$="Voici le texte qui sera inscrit dans le fichier"
 '
 ' Calculer l'adresse de la STRING:
 Nameptr%L= LPEEK( VARPTR(Filename$))+ LPEEK( SEGPTR +28)
 Ptrlign%L= LPEEK( VARPTR(Ligne$))+ LPEEK( SEGPTR +28)
 '
 ' CrÇer fichier:
 GEMDOS (Handle%L,$3C, HIGH(Nameptr%L), LOW(Nameptr%L),1)
 IF Handle%L<0
 THEN PRINT "Erreur Ö l'ouverture du fichier!"
      REPEAT : UNTIL INKEY$ <>""
 ELSE ' êcrire le texte dans fichier
      Nomb%L= LEN(Ligne$)
      GEMDOS (,$40,Handle%L, HIGH(Nomb%L), LOW(Nomb%L), HIGH(Ptrlign%L), LOW(Ptrlign%L))
      ' Fermer fichier
      GEMDOS (,$3E,Handle%L)
 ENDIF
 '
