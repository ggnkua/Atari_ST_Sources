 '
 ' Plusieurs ‚crans logiques (graphisme sans scintillement)
 ' GFA-BASIC                   MULTISCR.BAS
 '
 CLEAR 33000'       Restituer la m‚moire au GEMDOS
 '
 DIM Scr%L(1)
 '
 ' Demander l'adresse de l'‚cran
 ' Faire de la plce pour le deuxiŠme ‚cran
 '
 Scr%L(0)=FN Logbase%L
 Free%L= MEMORY(32256)
 '
 IF Free%L=0 THEN
  FORM_ALERT (1,"[3][Pas assez de m‚moire!][Dommage!]")
 ELSE
  '
  ' Scr(1) doit commencer au bord de la page:
  '
  Scr%L(1)=(Free%L+256) AND $FFFF00
  '
  FOR I%L=20 TO 300
    Setphys(Scr%L(I%L MOD 2))'     *  Effacez ces deux lignes
    Setlog(Scr%L(1-(I%L MOD 2)))'  *  pour voir ce qu'il se passe!
    '
    CLS
    TEXT I%L,I%L,"Bonjour!"
    '
    XBIOS (,37)'  Attendre retour d'image
    '
  NEXT I%L
  '
  GEMDOS (,7)'        Crawcin attend une touche
  '
  Setlog(Scr%L(0))'     Restituer l'‚tat pr‚c‚dent
  Setphys(Scr%L(0))
  '
 ENDIF
 '
 END
 '
 '
 DEF FN Logbase%L
  XBIOS (Logbase%L,3)
 RETURN (Logbase%L)
 '
 DEF PROC Setlog(X%L)
  XBIOS (,5, HIGH(X%L), LOW(X%L),-1,-1,-1)
 RETURN
 '
 DEF PROC Setphys(X%L)
  XBIOS (,5,-1,-1, HIGH(X%L), LOW(X%L),-1)
 RETURN
