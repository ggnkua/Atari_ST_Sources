 '
 ' Modification de l'‚paisseur et des extr‚mit‚s des lignes
 ' OMIKRON-BASIC                   LIGNES.BAS
 '
 LIBRARY Gem ,"gem.lib"
 Appl_Init'   Initialise GEM
 V_Opnvwk
 '
 CLS '           Effacer l'‚cran
 '
 Vsl_Width(33)' Largeur de ligne: 33 Pointes
 '
 FOR I%L=0 TO 2
 '
 Vsl_Ends(I%L,I%L)' Faire passer le style de 0 … 2
 '
 Ptsin%(0,0)=20'        En Omikron, les coordonn‚es doivent ˆtre
 Ptsin%(1,0)=20+70*I%L'   retourn‚es au tableau Ptsin%
 Ptsin%(0,1)=300
 Ptsin%(1,1)=Ptsin%(1,0)
 V_Pline(2)'            2 est le nombre des points … relier
 '
 NEXT I%L
 '
 GEMDOS (,7)'           Attendre appui touche
 '
 V_Clsvwk'              D‚sannonce au GEM
 Appl_Exit
 END
