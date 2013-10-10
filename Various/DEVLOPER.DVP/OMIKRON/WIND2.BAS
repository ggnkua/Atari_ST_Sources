 '
 ' Fenˆtre avec fonctions (agrandir, ...)
 ' OMIKRON-BASIC   WIND2.BAS
 '
 LIBRARY Gem ,"gem.lib"
 Appl_Init:V_Opnvwk
 '
 ' D‚terminer la r‚solution de l'‚cran:
 '
 XBIOS (Rez%L,4)'    0=low, 1=mid, 2=high
 X_Max%L=640+320*(Rez%L=0)
 Y_Max%L=200-200*(Rez%L=2)
 '
 ' Donner la taille de la fenˆtre initiale:
 '
 Wx%L=20:Wy%L=20:Ww%L=280:Wh%L=150
 '
 Wind_Create(63,0,0,X_Max%L,Y_Max%L,Whandle%L)
 IF Whandle%L<0 THEN
   FORM_ALERT (1,"[3][Plus d'identificateur fenˆtre libre!][OK]",Dummy%L)
 ELSE
   '
   ' Param‚trer les lignes de titre et d'information:
   '
   Adr%L= MEMORY(40)'   n‚cessaire pour wind_set
   Wind_Set(Whandle%L,2,"WIND2.PRG",Adr%L)
   Wind_Set(Whandle%L,3,"Veuillez bien noter:",Adr%L+15)
   '
   Wind_Open(Whandle%L,Wx%L,Wy%L,Ww%L,Wh%L)
   '
   ' Nous appelons maintenant un sous-programme qui efface la zone
   ' de travail de la fenˆtre pour y ‚crire quelque chose:
   '
   Output_Text
   '
   ' *** Attendre une action de l'utilisateur ***
   '
   REPEAT
     '
     Evnt_Mesag(Tampon$)'   2 octets forment un mot
     '
     IF FN P%L(0)=20 THEN Output_Text'   Invite … Redraw
     '
     IF FN P%L(0)=23 THEN '   Le bouton plein ‚cran a ‚t‚ actionn‚
       Wx%L=2:Wy%L=20:Ww%L=X_Max%L-5:Wh%L=Y_Max%L-25
       Wind_Set(Whandle%L,Wx%L,Wy%L,Ww%L,Wh%L)
     ENDIF
     '
     IF FN P%L(0)=27 THEN '   Bouton de modification de taille
       Ww%L=FN P%L(6)'    R‚cup‚rer la taille dans le tampon des messages
       Wh%L=FN P%L(7)
       Wind_Set(Whandle%L,Wx%L,Wy%L,Ww%L,Wh%L)
     ENDIF
     '
     IF FN P%L(0)=28 THEN '   Bouton de d‚placement
       Wx%L=FN P%L(4)
       Wy%L=FN P%L(5)
       Wind_Set(Whandle%L,Wx%L,Wy%L,Ww%L,Wh%L)
     ENDIF
     '
   UNTIL FN P%L(0)=22'   ...jusqu'au clic sur bouton de fermeture fenˆtre
   '
   ' Fermer la fenˆtre et la lib‚rer:
   '
   Wind_Close(Whandle%L)
   Wind_Delete(Whandle%L)
 ENDIF
 '
 V_Clsvwk:Appl_Exit
 END
 '
 '
 ' La fonction suivante est utilis‚e pour traiter la chaŒne d'‚vŠnement
 ' de evnt_mesag. Vous passez simplement le num‚ro du mot du message
 ' que vous voulez lire.
 '
 DEF FN P%L(N%L)= CVI( MID$(Tampon$,N%L*2+1,2))
 '
 '
 DEF PROC Output_Text'   Affiche le contenu de la fenˆtre
   V_Hide_C'   Le pointeur de la souris nous gˆne ici...
   '
   ' Nous devons faire calculer la taille de la zone de travail:
   '
   Wind_Calc(1,63,Wx%L,Wy%L,Ww%L,Wh%L,X%L,Y%L,W%L,H%L)
   '
   X2%L=X%L+W%L-1:Y2%L=Y%L+H%L-1'   Conversion de x/y/w/h en x1/y1/x2/y2
   '
   ' Effacer la zone de travail:
   '
   Vsf_Interior(0)'   Motif de remplissage: surface blanche
   Vsf_Perimeter(0)'  pas de cadres
   V_Bar(X%L,Y%L,X2%L,Y2%L)
   Vsf_Perimeter(1)'  R‚activer les cadres
   '
   ' Activer le clipping:
   '
   Vs_Clip(X%L,Y%L,X2%L,Y2%L)
   '
   V_Gtext(X%L+8,Y%L+14,"Bonjour! Voici une d‚mo des fenˆtres!")
   V_Gtext(X%L+8,Y%L+30,"Vous pouvez d‚placer cette fenˆtre et modifier sa taille.")
   V_Gtext(X%L+8,Y%L+46,"Pour quitter, cliquez sur le bouton de fermeture!")
   '
   Vs_Clip'   sans paramŠtre = le clipping est d‚sactiv‚
   '
   V_Show_C(1)'   R‚afficher le pointeur souris
 RETURN
 LIBRARY CODE Gem
