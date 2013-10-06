 '
 ' Postharger un programme et le lancer plus tard par Pexec
 ' OMIKRON-BASIC                POSTCHA2.BAS
 '
 CLEAR 10000:' 10000 octets pour le programme … postcharger
 '
 Nameptr%L= MEMORY("ACHARGER.TOS")
 Parametre%L= MEMORY("")
 Environment%L=Parametre%L
 '
 GEMDOS (,2,27)'        Comme auparavant, mais le curseur
 GEMDOS (,2, ASC("H"))' est positionn‚ sur la ligne 5
 FOR I%=1 TO 4: GEMDOS (,2,10): NEXT I%
 '
 CLS :' Bildschirm l”schen
 '
 PRINT "Voici le programme appelant.": PRINT
 '
 ' Appel GEMDOS pour charger sans lancer (mode 3):
 '
 GEMDOS (Basepage%L,$4B,3, HIGH(Nameptr%L), LOW(Nameptr%L), HIGH(Parametre%L), LOW(Parametre%L), HIGH(Environment%L), LOW(Environment%L))
 '
 IF Basepage%L<0
   THEN PRINT "Il y a une erreur quelque part!!!"
   ELSE
   '
   PRINT "Le programme est charg‚. Taper une touche pour le lancer!": PRINT
   GEMDOS (,7):' Crawcin attend une touche
   '
   ' Lancer le programme (Mode 4):
   '
   GEMDOS (,$4B,4,0,0, HIGH(Basepage%L), LOW(Basepage%L),0,0)
   '
 ENDIF
 '
 PRINT : PRINT
 PRINT "Revoici le programme appelant!"
 '
 GEMDOS (,7):' Attendre appui touche (Crawcin)
 END
