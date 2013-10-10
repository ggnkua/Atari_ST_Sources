 '
 ' Charger un fichier Ressource, afficher une barre de menus
 ' OMIKRON-BASIC                   MENU1.BAS
 '
 ' La m‚moire doit ˆtre restitu‚e au GEMDOS pour rsrc_load:
 '
 LIBRARY Gem ,"gem.lib"
 CLEAR 33000'    Cela devrait suffire car les fichiers Ressource
 '               ne font pas plus de 32 Ko
 '
 Menus%L=0'   Ces constantes ont ‚t‚ charg‚es par 'Merge' du fichier
 Info%L=7'    MENU1.H2, qui peut ˆtre cr‚‚ par le programme BASHEAD
 Fin%L=16'    (voir description)
 '
 Tampon$= SPACE$(16)' De la place pour 8 mots
 '
 DEF FN P%L(X%L)= CVI( MID$(Tampon$,X%L*2+1,2))'  La fonction lit le mot
 '                                          no X dans le tampon
 '
 Appl_Init
 '
 ' Charger le fichier ressource (MENU1.RSC):
 '
 Rsrc_Load("MENU1.RSC",Back%L)
 IF Back%L=0 THEN
  FORM_ALERT (1,"[3][Pas de fichier RSC!][Fin]")
 ELSE
  '
  ' Demander l'adresse de l'arbre du menu (0 pour arbre):
  '
  Rsrc_Gaddr(0,Menus%L,Menus_Adresse%L)
  '
  ' Afficher la barre des menus:
  '
  Menu_Bar(Menus_Adresse%L)
  '
  ' Boucle d'‚vŠnements:
  '
  Quitte%L=0
  '
  REPEAT
    Evnt_Mesag(Tampon$)
    '
    IF FN P%L(0)=10 THEN '       Option menu cliqu‚e?
      Title%L=FN P%L(3)'           Stocker le num‚ro du titre
      IF FN P%L(4)=Info%L THEN '   Information demand‚e?
        FORM_ALERT (1,"[1][Programme d‚mo des menus|(c) 1989 Micro Application][Continue]")
      ENDIF
      IF FN P%L(4)=Fin%L THEN '   ou fin du programme?
        FORM_ALERT (2,"[2][Quitter? Vraiment?][Oui|Non]",Back%L)
        IF Back%L=1 THEN Quitte%L=1
      ENDIF
      '
      ' Affichage normal  (1) du titre du menu:
      '
      Menu_Tnormal(Title%L,1)
    ENDIF
  UNTIL Quitte%L=1
  '
  Menu_Bar(Menus_Adresse%L)'    Effacer ligne menu
  Rsrc_Free' Faire de la place
 ENDIF
 '
 Appl_Exit
 '
 END
