 '
 ' D‚mo de Copy Raster, opaque (vro_cpyfm)
 ' OMIKRON-Basic  COPYTRAM.BAS
 '
 LIBRARY Gem ,"gem.lib"
 Appl_Init'   Initialisation habituelle...
 V_Opnvwk
 '
 V_Gtext(20,50,"Bonjour, voici le texte")'  Texte "original"
 '
 Null_Long%L=0'              un long mot 0 (Variable 4 octets)
 Nullptr%L= VARPTR(Null_Long%L)'          Pointeur sur ce z‚ro
 '
 Vro_Cpyfm(Nullptr%L,Nullptr%L,3,20,36,204,52,20,65,204,81)
 ' (3 est le mot de mode => remplace)
 '
 Vro_Cpyfm(Nullptr%L,Nullptr%L,7,20,36,204,52,20,90,204,106)
 ' (Modus 8 => transparent)
 '
 GEMDOS (,7)'    Attente appui touche
 '
 V_Clsvwk'       Fin
 Appl_Exit
 END
