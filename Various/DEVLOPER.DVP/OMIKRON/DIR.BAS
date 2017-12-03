 '
 ' Affichage du rÇpertoire courant
 ' OMIKRON-BASIC          DIR.BAS
 '
 ' RÇserver une zone de la mÇmoire:
 Dta%L= MEMORY(44)' fÅr DTA-tampon
 Nameptr%L=Dta%L+30' Offset pour le nom de fichier: 30 Bytes
 Masque%L= MEMORY("*.*")' Masque Ö rechercher
 Crlf%L= MEMORY( CHR$(13)+ CHR$(10))' pour saut de ligne
 '
 ' Effacer l'Çcran du VT52
 BIOS (,3,2,27)' Escape
 BIOS (,3,2, ASC("E"))' + E = effacer l'Çcran
 '
 ' DÇterminer la DTA:
 GEMDOS (,$1A, HIGH(Dta%L), LOW(Dta%L))
 '
 ' Appel de Fsfirst:
 GEMDOS (Back%,$4E, HIGH(Masque%L), LOW(Masque%L),Lectseul%)
 IF Back%<0
   THEN PRINT "Fichier introuvable!"
   ELSE ' Afficher le premier fichier trouvÇ
        GEMDOS (,9, HIGH(Nameptr%L), LOW(Nameptr%L))
        GEMDOS (,9, HIGH(Crlf%L), LOW(Crlf%L))
        '
        ' Continuer Ö chercher jusqu'Ö Fsnext<0:
        WHILE 1' Boucle apparemment sans fin
          GEMDOS (Back%,$4F)
          IF Back%<0 THEN EXIT
          GEMDOS (,9, HIGH(Nameptr%L), LOW(Nameptr%L))
          GEMDOS (,9, HIGH(Crlf%L), LOW(Crlf%L))
        WEND
 ENDIF
 GEMDOS (,7)
 CLS
 END
