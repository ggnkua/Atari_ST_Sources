 '
 ' Charger, afficher une boŒte de dialogue, exploiter des boutons radio
 ' OMIKRON-BASIC                         DIALOG3.OMI
 '
 Dialog%L=0'             Constantes dans DIALOG3.H2
 Om%L=3
 Fm%L=2
 Oc%L=4
 Go%L=5
 Fin%L=6
 '
 LIBRARY Gem ,"gem.lib"
 Appl_Init
 '
 Rsrc_Load("DIALOG3.RSC",Ret%L)
 IF Ret%L=0 THEN
  FORM_ALERT (1,"[3][Pas de fichier RSC!][Fin]")
 ELSE
  '
  ' Demander l'adresse de l'arbre:
  '
  Rsrc_Gaddr(0,Dialog%L,Arbre_Adr%L)
  '
  ' D‚terminer un bouton par d‚faut (ici: FM)
  '
  Select(Arbre_Adr%L,Fm%L)
  '
  ' Afficher la boŒte de dialogue:
  '
  Show_Dialog(Arbre_Adr%L)
  '
  ' Faire fonctionner la boŒte de dialogue:
  '
  Form_Do(0,Arbre_Adr%L,Bouton%L)
  '
  ' Inhiber l'‚tat 'selected' du bouton s‚lectionn‚:
  '
  Deselect(Arbre_Adr%L,Bouton%L)
  '
  ' Faire disparaŒtre la boŒte de dialogue:
  '
  Hide_Dialog(Arbre_Adr%L)
  '
  ' Exploitation des boutons:
  '
  IF FN Selected%L(Arbre_Adr%L,Fm%L) THEN A$="FM"
  IF FN Selected%L(Arbre_Adr%L,Om%L) THEN A$="Ondes moyennes"
  IF FN Selected%L(Arbre_Adr%L,Oc%L) THEN A$="Ondes courtes"
  IF FN Selected%L(Arbre_Adr%L,Go%L) THEN A$="Grandes ondes"
  '
  FORM_ALERT (1,"[1][Vous avez choisi la gamme|"+A$+"!][Oui!]")
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
 DEF FN Selected%L(Arbre%L,Index%L)= WPEEK(Arbre%L+24*Index%L+10) AND 1
 '
 '
 DEF PROC Show_Dialog(Arbre%L)
  LOCAL X%L,Y%L,W%L,H%L
  '
  ' Centrer le formulaire … l'‚cran
  ' (n'est pas encore dessin‚)
  '
  Form_Center(Arbre%L,X%L,Y%L,W%L,H%L)
  '
  ' Stocker les cadres des fenˆtres:
  '
  Form_Dial(0,X%L,Y%L,W%L,H%L)
  '
  ' DEssiner un rectangle "zoom":
  '
  Form_Dial(1,X%L,Y%L,W%L,H%L)
  '
  ' Dessin du formulaire:
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
  ' Redemander les coordonn‚es:
  '
   Form_Center(Arbre%L,X%L,Y%L,W%L,H%L)
  '
  ' Dessin d'un rectangle diminuant:
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
  WHILE PEEK(Adr%L+I%L)<>0'         lire jusqu'… l'octet nul
    Text$=Text$+ CHR$( PEEK(Adr%L+I%L))
    I%L=I%L+1
  WEND
 RETURN
