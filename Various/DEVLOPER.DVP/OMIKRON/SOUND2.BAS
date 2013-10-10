 '
 ' Son avec indication de la p‚riode
 ' OMIKRON      SOUND2.BAS
 '
 FOR A%L=1 TO 5
   FOR I%L=4000 TO 500 STEP -1
     TUNE 1,I%L
   NEXT I%L
   '
   FOR I%L=500 TO 4000
     TUNE 1,I%L
   NEXT I%L
 NEXT A%L
 '
 TUNE 1,0'   Ferme le canal
 END
