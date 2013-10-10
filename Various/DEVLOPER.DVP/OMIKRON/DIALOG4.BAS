 '
 ' Afficher boåte de dialogue / boutons Touchexit (UP/DOWN)
 ' GFA-BASIC                  DIALOG4.GFA
 '
 '
 LIBRARY Gem ,"gem.lib"
 Dialog%L=0'       Constantes dans DIALOG4.H2
 Actuel%L=5
 Down%L=7
 Up%L=6
 Termine%L=8
 '
 Appl_Init
 '
 Rsrc_Load("DIALOG4.RSC",Ret%L)
 IF Ret%L=0 THEN
  FORM_ALERT (1,"[3][Pas de fichier RSC!][Fin]")
 ELSE
  '
  ' Demander l'adresse de l'arbre:
  '
  Rsrc_Gaddr(0,Dialog%L,Arbre_Adr%L)
  '
  ' Initialiser le champ (actuel):
  '
  Write_Text(Arbre_Adr%L,Actuel%L,"0")
  Nombre%L=0
  '
  ' Afficher la boåte de dialogue, stocker les coordonnÇes:
  '
  Show_Dialog(Arbre_Adr%L,X%L,Y%L,W%L,H%L)
  '
  REPEAT
    '
    ' Faire exÇcuter la boåte de dialogue
    '
    Form_Do(0,Arbre_Adr%L,Bouton%L)
    '
    IF Bouton%L=Up%L THEN Nombre%L=Nombre%L+1
    IF Bouton%L=Down%L THEN Nombre%L=Nombre%L-1
    '
    ' VÇrifier les limites de la zone:
    '
    IF Nombre%L=10 THEN Nombre%L=0
    IF Nombre%L=-1 THEN Nombre%L=9
    '
    ' êcrire nombre dans le formulaire
    '
    Write_Text(Arbre_Adr%L,Actuel%L, RIGHT$( STR$(Nombre%L),1))
    Objc_Draw(Actuel%L,0,X%L,Y%L,W%L,H%L,Arbre_Adr%L)' 0=dessiner actuel seulement
    '
    ' Courte pause (0.2 secondes):
    '
    Evnt_Timer(200)
  UNTIL Bouton%L=Termine%L
  '
  ' Effacer l'Çtat selected:
  '
  Deselect(Arbre_Adr%L,Bouton%L)
  '
  ' Faire disparaåtre la boåte de dialogue:
  '
  Hide_Dialog(Arbre_Adr%L,X%L,Y%L,W%L,H%L)
  '
  ' Effacer le fichier ressource de la mÇmoire:
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
  ' Mettre le bit 0 Ö 1:
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
 DEF FN Selected%L(Arbre%L,Index%L)= WPEEK(Arbre%L+24*Index%L+10) AND 1
 '
 '
 DEF PROC Show_Dialog(Arbre%L,R X%L,R Y%L,R W%L,R H%L)
  '
  ' Centrer le formulaire Ö l'Çcran
  ' (n'est pas encore dessinÇ)
  '
  Form_Center(Arbre%L,X%L,Y%L,W%L,H%L)
  '
  ' Stocker les cadres des fenàtres, etc:
  '
  Form_Dial(0,X%L,Y%L,W%L,H%L)
  '
  ' Dessiner un rectangle "zoom"
  '
  Form_Dial(1,X%L,Y%L,W%L,H%L)
  '
  ' Dessiner le formulaire:
  ' Commencer par l'objet no 0 (objet racine, cadre/boåte extÇrieur)
  ' Profondeur: 12 niveaux maxi (valeur arbitraire)
  '
  Objc_Draw(0,12,X%L,Y%L,W%L,H%L,Arbre%L)
  '
 RETURN
 '
 '
 DEF PROC Hide_Dialog(Arbre%L,X%L,Y%L,W%L,H%L)
  '
  ' Dessiner un rectangle diminuant:
  '
  Form_Dial(2,X%L,Y%L,W%L,H%L)
  '
  ' Redessienr les cadres des fenàtres et envoyer des messages Redraw Ö
  ' toutes les fenàtres dÇtruites:
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
  WHILE PEEK(Adr%L+I%L)<>0'         lire jusqu'Ö l'octet nul
    Text$=Text$+ CHR$( PEEK(Adr%L+I%L))
    I%L=I%L+1
  WEND
 RETURN
