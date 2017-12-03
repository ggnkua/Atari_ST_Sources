 '
 ' Afficher le contenu d'un fichier
 ' OMIKRON-BASIC          SHOWFILE.BAS
 '
 ' Reserver m‚moire pour DTA:
 Dta%L= MEMORY(44)'
 Tampon%L= MEMORY(1000)' et pour le texte
 Filename%L= MEMORY("READ.ME")'
 '
 ' Effacer l'‚cran
 BIOS (,3,2,27)' Escape
 BIOS (,3,2, ASC("E"))
 '
 ' D‚finit la DTA:
 GEMDOS (,$1A, HIGH(Dta%L), LOW(Dta%L))
 '
 ' Utiliser Fsfirst :
 GEMDOS (Back%,$4E, HIGH(Filename%L), LOW(Filename%L),Nurlesen%)
 IF Back%<0
   THEN PRINT "Fichier non trouv‚!"
   ELSE Longueur%L= LPEEK(Dta%L+26)' Longueur en octets
        ' Ouvrir , lire et fermer
        GEMDOS (Handle%,$3D, HIGH(Filename%L), LOW(Filename%L),0)
        GEMDOS (,$3F,Handle%, HIGH(Longueur%L), LOW(Longueur%L), HIGH(Tampon%L), LOW(Tampon%L))
        GEMDOS (,$3E,Handle%)
        '
        ' Afficher les donn‚es:
        GEMDOS (,9, HIGH(Tampon%L), LOW(Tampon%L))
   ENDIF
 GEMDOS (,7)'Attendre une touche
 CLS
 END
