     ; FF8A00    |XXXXXXXX| |XXXXXXXX|  MEMOIRE DEMI-TEINTE
     ; FF8A02    |XXXXXXXX| |XXXXXXXX| 
     ; FF8A04    |XXXXXXXX| |XXXXXXXX|
     ;  ..      :   ..   : :   ..   :
     ; FF8A1E    |XXXXXXXX| |XXXXXXXX|
     ; FF8A20    |XXXXXXXX| |XXXXXXX-|  INCREMENT HORIZONTAL SOURCE
     ; FF8A22    |XXXXXXXX| |XXXXXXX-|  INCREMENT VERTICAL SOURCE
     ; FF8A24    |--------| |XXXXXXXX|  ADRESSE BLOC SOURCE
     ; FF8A26    |XXXXXXXX| |XXXXXXX-|  
     ; FF8A28    |XXXXXXXX| |XXXXXXXX|  MASQUE FINAL 1
     ; FF8A2A    |XXXXXXXX| |XXXXXXXX|  MASQUE FINAL 2
     ; FF8A2C    |XXXXXXXX| |XXXXXXXX|  MASQUE FINAL 3
     ; FF8A2E    |XXXXXXXX| |XXXXXXX-|  INCREMENT HORIZ. DESTINATION
     ; FF8A30    |XXXXXXXX| |XXXXXXX-|  INCREMENT VERT. DESTINATION
     ; FF8A32    |--------| |XXXXXXXX|  ADRESSE BLOC DESTINATION
     ; FF8A34    |XXXXXXXX| |XXXXXXX-|  
     ; FF8A36    |XXXXXXXX| |XXXXXXXX|  TAILLE HORIZONTALE
     ; FF8A38    |XXXXXXXX| |XXXXXXXX|  TAILLE VERTICALE

     ; FF8A3A    |------XX|             OPERATION DEMI-TEINTE
     ; FF8A3B    |----XXXX|             OPERATION LOGIQUE
      
     ; FF8A3C    |XXX-XXXX|
     ;           ||| ||||
     ;           |||  ---------------- NUMERO DE LIGNE
     ;           || ------------------ DEBORDEMENT
     ;           | ------------------- PARTAGE DU BUS
     ;            -------------------- OCCUPATION DU BUS
 

     FF8A3D    |XX--XXXX|
               ||||||
               ||----------------OBLIQUE
               |-------------------NFSR
               --------------------FXSR