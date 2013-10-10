 '
 ' Charger, afficher une boŒte de dialogue et exploiter les champs Edit
 ' OMIKRON-BASIC                             DIALOG2.BAS
 '
 '
 LIBRARY Gem ,"gem.lib"
 Dialog%L=0'          Constantes dans DIALOG.H2
 Entree%L=3
 Affichage%L=5
 Ok%L=6
 Fin%L=7
 '
 Appl_Init
 '
 Rsrc_Load("DIALOG2.RSC",Ret%L)
 IF Ret%L=0 THEN
  FORM_ALERT (1,"[3][Pas de fichier RSC!][Fin]",Dummy%L)
 ELSE
  '
  ' Demander l'adresse de l'arbre:
  '
  Rsrc_Gaddr(0,Dialog%L,Arbre_Adr%L)
  '
  ' Initialisation du champ d'affichage:
  '
  Write_Text(Arbre_Adr%L,Affichage%L,"*** Aucun ***")
  '
  REPEAT
    '
    ' Effacer le champ d'entree:
    '
    Write_Text(Arbre_Adr%L,Entree%L,"")
    '
    ' Faire afficher la boŒte de dialogue:
    '
    Show_Dialog(Arbre_Adr%L)
    '
    ' Faire ex‚cuter la boŒte de dialogue; 'Entree' comme premier champ Edit
    '
    Form_Do(Entree%L,Arbre_Adr%L,Bouton%L)
    '
    ' Inhiber l'‚tat 'selected' du bouton s‚lectionn‚:
    '
    Deselect(Arbre_Adr%L,Bouton%L)
    '
    ' Faire disparaŒtre la boŒte de dialogue:
    '
    Hide_Dialog(Arbre_Adr%L)
    '
    ' Lire l'entr‚e et l'‚crire dans le champ d'affichage:
    '
    Read_Text(Arbre_Adr%L,Entree%L,A$)
    Write_Text(Arbre_Adr%L,Affichage%L,A$)
    '
  UNTIL Bouton%L=Fin%L
  '
  ' Effacer le fichier ressource de la m‚moire:
  '
  Rsrc_Free
  '
 ENDIF
 '
 Appl_Exit
 '
 END
 '
 '
 DEF PROC Select(Arbre%L,Index%L)
  ' Mettre le bit 0 … 1:
  WPOKE Arbre%L+24*Index%L+10, WPEEK(Arbre%L+24*Index%L+10) OR 1
 RETURN
 '
 '
 DEF PROC Deselect(Arbre%L,Index%L)
  ' Effacer le bit 0:
  WPOKE Arbre%L+24*Index%L+10, WPEEK(Arbre%L+24*Index%L+10) AND -2
 RETURN
 '
 '
 DEF PROC Show_Dialog(Arbre%L)
  LOCAL X%L,Y%L,W%L,H%L
  '
  ' Centrer le formulaire … l'‚cran
  ' (il n'est pas dessin‚ … ce stade)
  '
  Form_Center(Arbre%L,X%L,Y%L,W%L,H%L)
  '
  ' Stocker les cadres de fenˆtres, etc:
  '
  Form_Dial(0,X%L,Y%L,W%L,H%L)
  '
  ' Dessin d'un rectangle "zoom":
  '
  Form_Dial(1,X%L,Y%L,W%L,H%L)
  '
  ' Dessin du formulaire:
  ' Commencer par l'objet no 0 (objet racine: cadre/boŒte ext‚rieur)
  ' Profondeur: 12 niveaux maxi (valeur arbitraire)
  '
  Objc_Draw(0,12,X%L,Y%L,W%L,H%L,Arbre%L)
  '
 RETURN
 '
 '
 DEF PROC Hide_Dialog(Arbre%L)
  LOCAL X%L,Y%L,W%L,H%L
  '
  ' Redemander les coordonn‚es:
  '
  Form_Center(Arbre%L,X%L,Y%L,W%L,H%L)
  '
  ' Dessiner un rectangle qui diminue:
  '
  Form_Dial(2,X%L,Y%L,W%L,H%L)
  '
  ' Retracer les cadres des fenˆtres et envoyer des messages Redraw
  ' … toutes les fenˆtres d‚truites:
  '
  Form_Dial(3,X%L,Y%L,W%L,H%L)
  '
 RETURN
 '
 '
 DEF PROC Write_Text(Arbre%L,Index%L,Text$)
  LOCAL Adr%L,I%L,A$
  '
  ' Passer l'adresse du texte proprement dit (te_ptext):
  '
  Adr%L= LPEEK( LPEEK(Arbre%L+24*Index%L+12))
  '
  ' Ajouter un octet nul:
  '
  A$=Text$+ CHR$(0)
  '
  FOR I%L=1 TO LEN(A$)
    POKE Adr%L+I%L-1, ASC( MID$(A$,I%L,1))
  NEXT I%L
 RETURN
 '
 '
 DEF PROC Read_Text(Arbre%L,Index%L,R Text$)
  LOCAL Adr%L,I%L
  '
  ' Passer te_ptext:
  '
  Adr%L= LPEEK( LPEEK(Arbre%L+24*Index%L+12))
  '
  Text$=""
  I%L=0
  '
  WHILE PEEK(Adr%L+I%L)<>0'          lire jusqu'… l'octet nul
    Text$=Text$+ CHR$( PEEK(Adr%L+I%L))
    I%L=I%L+1
  WEND
 RETURN
