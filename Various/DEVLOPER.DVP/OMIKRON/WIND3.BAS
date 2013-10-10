 '
 ' Deux fenˆtres avec fonctions … l'‚cran
 ' OMIKRON-BASIC    WIND3.BAS
 '
 LIBRARY Gem ,"gem.lib"
 DIM Whandle%L(1),Wx%L(1),Wy%L(1),Ww%L(1),Wh%L(1),Opened%L(1)
 Appl_Init:V_Opnvwk
 '
 ' Demander la taille de la fenˆtre du bureau (Nummer 0):
 '
 Wind_Get(0,4,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L)
 '
 ' Inscrire la fenˆtre:
 IF FN Create_Windows%L THEN
   FORM_ALERT (1,"[3][D‚sol‚!|Plus d'identificateur fenˆtre libre!][OK]",Dummy%L)
 ELSE
   '
   ' Entrer la taille standard de la fenˆtre dans le tableau:
   '
   Wx%L(0)=20:Wy%L(0)=20:Ww%L(0)=200:Wh%L(0)=120
   Wx%L(1)=50:Wy%L(1)=50:Ww%L(1)=200:Wh%L(1)=120
   '
   ' Param‚trer les lignes de titre et d'information:
   '
   Adr%L= MEMORY(100)' Place m‚moire pour wind_set
   '
   Wind_Set(Whandle%L(0),2,"Fenˆtre 1",Adr%L)
   Wind_Set(Whandle%L(0),3,"Veuillez bien noter:",Adr%L+25)
   Wind_Set(Whandle%L(1),2,"Fenˆtre 2",Adr%L+50)
   Wind_Set(Whandle%L(1),3,"Veuillez ‚galement noter:",Adr%L+75)
   '
   ' Ouvrir la fenˆtre et ‚crire quelque chose dedans:
   '
   FOR I%L=0 TO 1
     Wind_Open(Whandle%L(I%L),Wx%L(I%L),Wy%L(I%L),Ww%L(I%L),Wh%L(I%L))
     Opened%L(I%L)=1
     Output_Text(I%L)
   NEXT I%L
   '
   ' *** Boucle d'attente ***
   '
   REPEAT
     Evnt_Mesag(Tampon$)
     '
     ' Identifier lafenˆtre d'o— le message est venu (0 ou 1)
     ' L'identificateur est dans tampon[3]
     '
     Window%L=0
     WHILE NOT (FN P%L(3)=Whandle%L(Window%L) OR Window%L=2)
       Window%L=Window%L+1
     WEND
     '
     IF Window%L<2 THEN '    ne consid‚rer que nos fenˆtres (0 et 1)
       IF FN P%L(0)=20 THEN Redraw(Window%L)
       '
       IF FN P%L(0)=21 THEN '    Window Topped
         Wind_Set(Whandle%L(Window%L))' Faire passer la fenˆtre au premier plan
       ENDIF
       '
       IF FN P%L(0)=23 THEN '    FullBox (bouton plein ‚cran)
         Wx%L(Window%L)=Xdesk%L+2
         Wy%L(Window%L)=Ydesk%L+2
         Ww%L(Window%L)=Wdesk%L-6
         Wh%L(Window%L)=Hdesk%L-6
         Wind_Set(Whandle%L(Window%L),Wx%L(Window%L),Wy%L(Window%L),Ww%L(Window%L),Wh%L(Window%L))
       ENDIF
       '
       IF FN P%L(0)=27 THEN '    SizeBox (bouton de modification de taille)
         Ww%L(Window%L)=FN P%L(6)
         Wh%L(Window%L)=FN P%L(7)
         Wind_Set(Whandle%L(Window%L),Wx%L(Window%L),Wy%L(Window%L),Ww%L(Window%L),Wh%L(Window%L))
       ENDIF
       '
       IF FN P%L(0)=28 THEN '    MoveBar (barre de d‚placement)
         Wx%L(Window%L)=FN P%L(4)
         Wy%L(Window%L)=FN P%L(5)
         Wind_Set(Whandle%L(Window%L),Wx%L(Window%L),Wy%L(Window%L),Ww%L(Window%L),Wh%L(Window%L))
       ENDIF
       '
       IF FN P%L(0)=22 THEN '    CloseBox (bouton de fermeture)
         Wind_Close(Whandle%L(Window%L))
         Wind_Delete(Whandle%L(Window%L))
         Opened%L(Window%L)=0'    stocker "ferm‚e"
       ENDIF
     '
     ENDIF
     '
   ' Continuer tant que des fenˆtres sont ouvertes
   UNTIL NOT ((Opened%L(0)=1) OR (Opened%L(1)=1))
   '
 ENDIF
 '
 V_Clsvwk:Appl_Exit
 END
 '
 '
 DEF FN P%L(N%L)= CVI( MID$(Tampon$,N%L*2+1,2))
 '
 '
 DEF FN Create_Windows%L
   FOR I%L=0 TO 1
     Wind_Create(63,Xdesk%L,Ydesk%L,Wdesk%L,Hdesk%L,Whandle%L(I%L))
   NEXT I%L
   '
 RETURN (Whandle%L(0)<0) OR (Whandle%L(1)<0)
 '
 '
 DEF PROC Intersect(X1%L,Y1%L,W1%L,H1%L,X2%L,Y2%L,W2%L,H2%L,R X%L,R Y%L,R Xx%L,R Yy%L,R Ret%L)
   ' Berechnet die Schnittfl„che zweier Rechtecke
   W%L= MIN(X2%L+W2%L,X1%L+W1%L)
   H%L= MIN(Y2%L+H2%L,Y1%L+H1%L)
   X%L= MAX(X2%L,X1%L)
   Y%L= MAX(Y2%L,Y1%L)
   Xx%L=W%L-1:Yy%L=H%L-1
   '
   Ret%L=(W%L>X%L) AND (H%L>Y%L)' Teste la pr‚sence d'intersection(s)
 RETURN
 '
 '
 DEF PROC Draw_Text(X1%L,Y1%L,X2%L,Y2%L,X%L,Y%L)
   ' Signification des paramŠtres:
   ' X1, Y2, X2 et Y2 forment le rectangle … effacer.
   ' x und y indiquent la position correcte de l'angle sup‚rieur gauche du texte
   ' Cela doit se trouver dans le rectangle si par exemple Redraw
   ' ne doit effacer que la moiti‚ inf‚rieure de la fenˆtre.
   '
   V_Hide_C
   '
   Vsf_Interior(0)'   Effacer le rectangle
   Vsf_Perimeter(0)
   V_Bar(X1%L,Y1%L,X2%L,Y2%L)
   Vsf_Perimeter(1)
   '
   V_Gtext(X%L+8,Y%L+14,"Bonjour, ceci est un d‚mo de fenˆtre!")
   V_Gtext(X%L+8,Y%L+30,"Vous pouvez la d‚placer et modifier sa taille.")
   V_Gtext(X%L+8,Y%L+46,"Pour quitter, cliquez sur le bouton de fermeture!")
   '
   V_Show_C(1)
 RETURN
 '
 '
 DEF PROC Output_Text(Window%L)
   Wind_Calc(1,63,Wx%L(Window%L),Wy%L(Window%L),Ww%L(Window%L),Wh%L(Window%L),X%L,Y%L,W%L,H%L)
   X2%L=X%L+W%L-1:Y2%L=Y%L+H%L-1
   Vs_Clip(X%L,Y%L,X2%L,Y2%L)
   Draw_Text(X%L,Y%L,X2%L,Y2%L,X%L,Y%L)
   Vs_Clip
 RETURN
 '
 '
 DEF PROC Redraw(Window%L)
   '
   ' Nous avons … nouveau besoin de la zone de travail:
   '
   Wind_Calc(1,63,Wx%L(Window%L),Wy%L(Window%L),Ww%L(Window%L),Wh%L(Window%L),Ax%L,Ay%L,Aw%L,Ah%L)
   '
   Wind_Update(1)'  Bloquer les fonctions de la souris
   '
   ' Traitement de la liste des rectangles:
   '
   Wind_Get(Whandle%L(Window%L),11,Rx%L,Ry%L,Rw%L,Rh%L)
   '
   WHILE Rw%L<>0'   Stopper quand la largeur est nulle
     Intersect(FN P%L(4),FN P%L(5),FN P%L(6),FN P%L(7),Rx%L,Ry%L,Rw%L,Rh%L,X%L,Y%L,Xx%L,Yy%L,Ret%L)
     IF Ret%L THEN '   En cas d'intersection
       Vs_Clip(X%L,Y%L,Xx%L,Yy%L)
       Draw_Text(X%L,Y%L,Xx%L,Yy%L,Ax%L,Ay%L)
     ENDIF
     '
     Wind_Get(Whandle%L(Window%L),12,Rx%L,Ry%L,Rw%L,Rh%L)' Rectangle suivant
   WEND
   '
   Vs_Clip'   D‚sactiver le clipping
   Wind_Update(0)
 RETURN
