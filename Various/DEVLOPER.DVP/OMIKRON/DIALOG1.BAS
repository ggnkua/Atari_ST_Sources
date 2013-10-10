 '
 ' Charger, afficher et traiter la premiŠre boŒte de dialogue
 ' OMIKRON-BASIC                    DIALOG1.BAS
 '
 Dialog%L=0'        Constantes dans DIALOG1.H2
 Bouton3%L=4
 Bouton1%L=5
 Bouton2%L=6
 '
 LIBRARY Gem ,"gem.lib"
 Appl_Init
 '
 Rsrc_Load("DIALOG1.RSC",Ret%L)
 IF Ret%L=0 THEN
  FORM_ALERT (1,"[3][Pas de fichier Rsc!][Fin]",Dummy%L)
 ELSE
  '
  ' Startadresse des (0 =) Chercher l'arbre 'dialog':
  '
  Rsrc_Gaddr(0,Dialog%L,Arbre_Adr%L)
  '
  ' Affichage de la boŒte de dialogue:
  '
  Show_Dialog(Arbre_Adr%L)
  '
  ' Faire travailler la boŒte de dialoguee, donc attendre appui touche
  '
  Form_Do(0,Arbre_Adr%L,Bouton%L)'         0 = pas de champ Edit
  '
  ' Inhiber l'‚tat 'selected' du bouton cliqu‚:
  '
  Deselect(Arbre_Adr%L,Bouton%L)
  '
  ' Faire disparaŒtre la boŒte de dialogue:
  '
  Hide_Dialog(Arbre_Adr%L)
  '
  ' Message … l'utilisateur lui indiquant quel bouton a ‚t‚ actionn‚:
  '
  IF Bouton%L=Bouton1%L THEN No%L=1
  IF Bouton%L=Bouton2%L THEN No%L=2
  IF Bouton%L=Bouton3%L THEN No%L=3
  '
  A$="[1][Appui sur le bouton no "+ STR$(No%L)+"!][Vrai!]"
  FORM_ALERT (1,A$,Dummy%L)
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
  ' Centrer le formulaire sur l'‚cran
  ' (sans le tracer)
  '
  Form_Center(Arbre%L,X%L,Y%L,W%L,H%L)
  '
  ' Stocker les cadres des fenˆtres, etc:
  '
  Form_Dial(0,X%L,Y%L,W%L,H%L)
  '
  ' Tracer un rectangle 'zoom':
  '
  Form_Dial(1,X%L,Y%L,W%L,H%L)
  '
  ' Tracer le formulaire:
  ' Commencer par l'objet no 0 (objet racine, cadre/boŒte ext‚rieur)
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
  ' Demander les coordonn‚es encore une fois:
  '
  Form_Center(Arbre%L,X%L,Y%L,W%L,H%L)
  '
  ' Tracer un rectangle diminuant:
  '
  Form_Dial(2,X%L,Y%L,W%L,H%L)
  '
  ' Redessiner les cadres des fenˆtres et message Redraw
  ' … toutes les efnˆtres d‚truites:
  '
  Form_Dial(3,X%L,Y%L,W%L,H%L)
  '
 RETURN
