 '
 ' Ouvrir et refermer une fenˆtre
 ' OMIKRON   WIND1.BAS
 '
 LIBRARY Gem ,"gem.lib"
 Appl_Init
 V_Opnvwk
 '
 Wind_Create(4095,20,20,280,150,Handle%L)
 IF Handle%L<0
   THEN FORM_ALERT (1,"[3][D‚sol‚!|Il n'y a plus d'identificateur fenˆtre libre!][OK]",Ret%L)
   ELSE Wind_Open(Handle%L,20,20,280,150)
        '
        ' Annoncer la zone de travail:
        '
        Wind_Calc(1,4095,20,20,280,150,X%L,Y%L,W%L,H%L)
        '
        Vsf_Interior(0)'    remplir avec la couleur du fond
        Vsf_Perimeter(0)'   sans encadrement
        '
        V_Bar(X%L,Y%L,X%L+W%L-1,Y%L+H%L-1)
        '
        Vsf_Perimeter(1)'   Reconstituer les encadrements
        '
        GEMDOS (,7)'   Attendre appui touche
        '
        Wind_Close(Handle%L)
        Wind_Delete(Handle%L)
   ENDIF
 '
 V_Clsvwk
 Appl_Exit
 END
