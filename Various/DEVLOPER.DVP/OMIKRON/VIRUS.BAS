 '
 ' D‚tecteur de virus (recherche un secteur de boot ex‚cutable)
 ' OMIKRON-BASIC                        VIRUS.BAS
 '
 Tampon$= STRING$(512,0)' Stocker le secteur boot dans cette chaŒne
 Tampon%L= LPEEK( VARPTR(Tampon$))+ LPEEK( SEGPTR +28)' Trouver l'adresse
 '
 CLS
 PRINT "Veuillez ins‚rer une disquette dans le lecteur A:"
 REPEAT : UNTIL INKEY$ >""
 '
 ' Lire la piste 0, secteur 1 (Bootsector)
 '
 XBIOS (Ret%L,8, HIGH(Tampon%L), LOW(Tampon%L),0,0,0,1,0,0,1)
 '
 IF NOT (Ret%L<0) THEN
   '
   ' Calculer le checksum
   '
   Somme%L=0
   FOR I%L=0 TO 510 STEP 2
     Somme%L=Somme%L+ WPEEK(Tampon%L+I%L)
   NEXT I%L
   '
   Somme%L=Somme%L AND 65535' Ne prendre que 16 bits en compte
   '
   IF Somme%L=$1234
     THEN PRINT "Le bootsector est ex‚cutable!"
          PRINT "Dois-je le modifier?"
          IF UPPER$( INPUT$(1))="O"
            THEN PRINT "Oui": PRINT
                 '
                 ' Modifier un octet
                 '
                 POKE (Tampon%L+511),( PEEK(Tampon%L+511)+1) AND 255
                 '
                 ' crire le tampon
                 '
                 XBIOS (Ret%L,9, HIGH(Tampon%L), LOW(Tampon%L),0,0,0,1,0,0,1)
                 IF Ret%L=-13 THEN
                   PRINT "La disquette est prot‚g‚e contre l'‚criture" ELSE
                 IF Ret%L<0 THEN PRINT "Disk Error": ENDIF : ENDIF
                 '
            ENDIF
     ELSE PRINT "Le bootsector n'est pas ex‚cutable!"
   ENDIF
   '
 ELSE PRINT "Disquette endommag‚e!"
 ENDIF
 END
