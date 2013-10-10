 '
 ' Conversion de fichiers en-tˆte C de RCS dans fichiers Basic
 ' OMIKRON-BASIC                     BASHEAD.BAS
 '
 PRINT "Conversion de fichiers en-tˆte C (*.H) de RCS dans fichiers Basic"
 PRINT "Nom du fichier sans extension"
 INPUT Filename$
 '
 OPEN "I",1,Filename$+".H"'    Fichier source en mode lecture
 OPEN "O",2,Filename$+".H2"'   Fichier cible en mode ‚criture
 '
 WHILE NOT EOF(1)
   INPUT #1,A$'           Lire ligne originale
   A$= MID$(A$,9)'        effacer #define
   P%L= INSTR(A$," ")'      Recherche des espaces
   PRINT #2, LEFT$(A$,P%L)+"="+ MID$(A$,P%L)
 WEND
 '
 CLOSE 1: CLOSE 2
 END
