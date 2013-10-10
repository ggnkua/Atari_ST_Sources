 '
 ' D‚mo evnt_button (gestion ‚vŠnements)
 ' OMIKRON-BASIC         BOUTON.BAS
 '
 LIBRARY Gem ,"gem.lib"
 Appl_Init
 V_Opnvwk
 '
 CLS
 Vswr_Mode(2)'    Transparent Write-Mode
 PRINT "Quitter: Shift et Clic"
 '
 WHILE 1'   pas de boucle DO ... LOOP en OMIKRON
 Evnt_Button(2,1,1,Clics%L,X%L,Y%L,K%L,Switch%L)
 ' Les paramŠtres ont ‚t‚ comment‚s dans le listing GFA. Diff‚rence:
 ' Les clics sont pass‚s comme paramŠtres VAR (GFA: valeur de fonction)
 '
 IF Switch%L>0 THEN EXIT '  Fin si une touche sp‚ciale est appuy‚e
 '                        pendant le clic
 IF Klicks%L=1'  Simple ou double-clic?
   THEN V_Gtext(X%L,Y%L,"x")
   ELSE V_Gtext(X%L,Y%L,"X")
 ENDIF
 WEND
 '
 V_Clsvwk
 Appl_Exit
 END
