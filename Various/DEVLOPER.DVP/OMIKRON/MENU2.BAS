 '
 ' Affichage d'une barre de menus, fonctions par raccourcis clavier
 ' OMIKRON-BASIC                          MENU2.BAS
 '
 ' Il faut restituer de la m‚moire au GEMDOS pour rsrc_load:
 '
 LIBRARY Gem ,"gem.lib"
 CLEAR 33000'    Cela doit suffire car les fichiers ressource
 '               ne d‚passent pas 32 Ko
 '
 Menus%L=0'        Vous les connaissez, mais cette fois ils viennent de MENU2.H2
 Bureau%L=3'       (avec num‚ros de titres)
 Fonction%L=4
 Info%L=7
 Fin%L=16
 '
 Tampon$= SPACE$(16)' Place pour 8 mots
 '
 DEF FN P%L(X%L)= CVI( MID$(Tampon$,X%L*2+1,2))'  La fonction lit le mot
 '                                          no x dans le tampon
 '
 Appl_Init
 '
 ' Charger le fichier ressource (MENU1.RSC):
 '
 Rsrc_Load("MENU2.RSC",Back%L)
 IF Back%L=0 THEN
  FORM_ALERT (1,"[3][Pas de fichier ressource!][Fin]")
 ELSE
  '
  ' Demander l'adresse de l'arbre objet des menus (0 pour arbre):
  '
  Rsrc_Gaddr(0,Menus%L,Menus_Adresse%L)
  '
  ' Affichage de la barre des menus:
  '
  Menu_Bar(Menus_Adresse%L)
  '
  ' Boucle d'‚vŠnements:
  '
  Quitte%L=0
  '
  REPEAT
    Evnt_Multi(17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,Tampon$,W%L,D%L,D%L,D%L,D%L,K%L,D%L)
    '
    IF (W%L AND 16) AND (FN P%L(0)=10) THEN '       Option cliqu‚e?
      Title%L=FN P%L(3)'                            Stocker le num‚ro du titre
      IF FN P%L(4)=Info%L THEN '                    Information demand‚e?
        Sub_Info
      ENDIF
      IF FN P%L(4)=Fin%L THEN '                     ou fin du programme?
        Sub_Fin
      ENDIF
      '
      ' R‚tablir l'affichage normal (1) du titre du menu
      '
      Menu_Tnormal(Title%L,1)
    ENDIF
    '
    IF (W%L AND 1) THEN '                   Appui touche
      Touche$= UPPER$( CHR$(K%L AND 255))'  Le caractŠre est dans le Low-Byte
      IF Touche$="I" THEN
        Menu_Tnormal(Bureau%L,0)' Inverser le titre du menu
        Sub_Info
        Menu_Tnormal(Bureau%L,1)' et revenir … l'affichage normal
      ENDIF
      '
      IF Touche$="E" THEN
        Menu_Tnormal(Fonction%L,0)
        Sub_Fin
        Menu_Tnormal(Fonction%L,1)
      ENDIF
    ENDIF
  UNTIL Quitte%L=1
  '
  Menu_Bar(Menus_Adresse%L)'    Effacer la barre des menus
  Rsrc_Free' Faire de la place
 ENDIF
 '
 Appl_Exit
 '
 END
 '
 DEF PROC Sub_Info
   FORM_ALERT (1,"[1][Programme d‚mo des menus|(c) 1989 Micro Application][Continue]")
 RETURN
 '
 DEF PROC Sub_Fin
   FORM_ALERT (2,"[2][Quitter? Vraiment?][Oui|Non]",Back%L)
     IF Back%L=1 THEN Quitte%L=1
 RETURN
