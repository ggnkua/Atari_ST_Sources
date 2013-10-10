 '
 ' Postcharger un programme et le lancer imm‚diatement par Pexec
 ' OMIKRON-BASIC                      PEXEC.BAS
 '
 CLEAR 10000:' 10000 octets pour le programme … postcharger
 '
 Nameptr%L= MEMORY("ACHARGER.TOS")
 Parametre%L= MEMORY("")
 Environment%L=Parametre%L
 '
 GEMDOS (,2,27)'        Compliqu‚ mais obligatoire:
 GEMDOS (,2, ASC("H"))' Le curseur est amen‚ sur la troisiŠme ligne
 GEMDOS (,2,10)'        … l'aide de s‚quences VT52 (ESC+H pour
 GEMDOS (,2,10)'        Home et 2 fois 10 pour le saut de ligne)
 '
 CLS :' Effacer l'‚cran
 '
 PRINT "Voici le programme appelant.": PRINT
 '
 ' Appel GEMDOS pour charger et lancer:
 '
 GEMDOS (Ret%,$4B,0, HIGH(Nameptr%L), LOW(Nameptr%L), HIGH(Parametre%L), LOW(Parametre%L), HIGH(Environment%L), LOW(Environment%L))
 '
 IF Ret%<0
   THEN PRINT "Il y a une erreur quelque part!!!"
 ENDIF
 '
 PRINT : PRINT
 PRINT "Et revoici le programme appelant!"
 '
 GEMDOS (,7):' Attente appui touche (Crawcin)
 END
