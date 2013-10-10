 '
 ' Examiner plusieurs ‚vŠnements simultan‚ment
 ' OMIKRON-BASIC       MULTI.BAS
 '
 LIBRARY Gem ,"GEM.LIB"
 Appl_Init
 V_Opnvwk
 '
 CLS
 PRINT "Veuillez taper une touche. Si vous n'avez pas"
 PRINT "tap‚ de touche dans les 3 secondes, le programme"
 PRINT "sera interrompu."
 '
 Evnt_Multi(33,0,0,0,0,0,0,0,0,0,0,0,0,0,3000,A$,Quel%L,Dummy%L,Dummy%L,Dummy%L,Dummy%L,Touche%L,Dummy%L)
 '
 PRINT
 IF Which%L=1
   THEN PRINT "Taper une touche pour quitter"
   ELSE PRINT "Fin du programme dans 3 secondes"
 ENDIF
 '
 GEMDOS (,7)' Attendre appui touche
 V_Clsvwk
 Appl_Exit
 END
