 '
 ' d‚monstration VDI pour un petit graphisme et texte
 ' OMIKRON-BASIC            VDI_DEMO.BAS
 '
 LIBRARY Gem ,"GEM.LIB"
 Appl_Init
 V_Opnvwk
 CLS
 '
 ' D‚terminer la r‚solution (par XBIOS 4 Getrez)
 '
 X_Max%=640:Y_Max%=400
 XBIOS (Rez%,4)
 IF Rez%<2 THEN Y_Max%=200
 IF Rez%=0 THEN X_Max%=320
 '
 V_Rbox(10,10,X_Max%-10,Y_Max%-30)
 V_Ellipse(X_Max%/2,Y_Max%/2-10,X_Max%/2-10,Y_Max%/2-20)
 V_Gtext(X_Max%/2-96,Y_Max%-10,"VDI - Grafik ist einfach!")
 '
 ' Attente appui touche:
 '
 GEMDOS (,7)'    Crawcin
 '
 V_Clsvwk
 Appl_Exit
 END
