 '
 ' Sprites               SPRITES.BAS
 ' Omikron BASIC
 '
 ' Lire les DATA du sprite:
 '
 FOR I%L=1 TO 16
  READ M$,S$'      Un mot pour le masque, un mot pour le sprite
  Sprite$=Sprite$+FN Nombre$(M$)+FN Nombre$(S$)
 NEXT I%L
 '
 DEF SPRITE 1,5, MEMORY(64)'    Num‚ro 1, type 5
 '
 ' Le sprite doit se d‚placer sur l'‚cran:
 '
 BOX 140,100 TO 500,200'      Dessiner le cadre en arriŠre-plan
 '
 FOR X%L=20 TO 620
  SPRITE 1,X%L,150, LPEEK( VARPTR(Sprite$))+ LPEEK( SEGPTR +28),0,1
  XBIOS (,37)' Le dessin suivant au retour de l'image pour ne d‚ranger personne
 NEXT X%L
 '
 ' Effacer le sprite de l'‚cran:
 '
 DEF SPRITE 1,0
 '
 END
 '
 '
 ' Data du sprite:
 '
 DATA "****************","----------------"
 DATA "****************","-**************-"
 DATA "****************","-*--*------*--*-"
 DATA "****************","-*--*------*--*-"
 DATA "****************","-*--*------*--*-"
 DATA "****************","-*--********--*-"
 DATA "****************","-*------------*-"
 DATA "****************","-*------------*-"
 DATA "****************","-*-**********-*-"
 DATA "****************","-*-*--------*-*-"
 DATA "****************","-*-*-*-***--*-*-"
 DATA "****************","-***--------*-*-"
 DATA "****************","-***--**-*--*-*-"
 DATA "****************","-*-*--------*-*-"
 DATA "****************","-**************-"
 DATA "****************","----------------"
 '
 '
 DEF FN Nombre$(A$)'     Transforme 16 z‚ros/uns en une chaŒne
  LOCAL I%L,N%L
  N%L=0
  FOR I%L=0 TO 15
    IF MID$(A$,16-I%L,1)<>"-"'  Est-ce que le bit est … 1?
      THEN N%L=N%L+2^I%L'           Alors ajouter la valeur correspondante
    ENDIF
  NEXT I%L
 RETURN RIGHT$( MKIL$(N%L),2)
