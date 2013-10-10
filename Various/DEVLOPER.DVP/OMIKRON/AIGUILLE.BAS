 '
 ' Aiguiller l'entr‚e du clavier vers un fichier
 ' OMIKRON-BASIC       AIGUILLE.BAS
 '
 Nameptr%L= MEMORY("AIGUILLE.DAT")
 '
 ' Ouvrir le fichier AIGUILLE.DAT en lecture
 '
 GEMDOS (Handle%,$3D, HIGH(Nameptr%L), LOW(Nameptr%L),0)
 IF Handle%<0
   THEN
     PRINT "Fichier introuvable!"
   ELSE
     '
     ' Dupliquer l'identificateur standard d'entr‚e (0):
     '
     GEMDOS (Non_Std_Handle%,$45,0)
     '
     ' Aiguiller: l'entr‚e standard (0) sur le fichier (Handle%)
     '
     GEMDOS (,$46,0,Handle%)
     '
     Eingabe(Zeile$)'   Entr‚e venant du fichier
     PRINT Zeile$'      suivie par un affichage de contr“le
     '
     ' Annuler l'aiguillage: standard (0) sur Non_std
     '
     GEMDOS (,$46,0,Non_Std_Handle%)
     '
     ' Fermer le fichier:
     '
     GEMDOS (,$3E,Handle%)
   ENDIF
 END
 '
 DEF PROC Entree(R A$)' Sous-programme: Entr‚e GEMDOS au clavier
 LOCAL Caractere%
   A$=""
   REPEAT
     GEMDOS (Caractere%,1)'  Cconin = entr‚e d'un caractere
     IF Caractere%=13 THEN EXIT ENDIF '   Quitter si Return
     A$=A$+ CHR$(Caractere%)
   UNTIL 0'    Boucle sans fin
 RETURN
