 '
 '
 '*******************************************************************************
 '
 '
 '                     Pop-Menu en Basic OMIKRON
 '                     -------------------------
 '
 ' Auteur : Pierre-Jean Goulier - Juillet 1991.
 '
 ' L'appel se fait par Pop_Menu(X,Y,Taille,Format,ChaŒne,Retour)
 '
 ' Signification des paramŠtres :
 '                   X : Coordonn‚e X de la souris.
 '                   Y : Coordonn‚e Y de la souris.
 '              Taille : Taille des caractŠres ->  0 : Petite.
 '                                                 1 : Grande.
 '              Format : Formatage du texte    ->  0 : Gauche.
 '                                                 1 : Centrer.
 '              ChaŒne : ChaŒne d'options      ->  | : S‚paration des options.
 '                                                || : Option gris‚e.
 '                                             -> [] : Menus en cascades.
 '              Retour : Variable en retour de l'option choisie.
 '
 ' Tous les paramŠtres sont des entiers courts (%) sauf <ChaŒne> qui est une
 ' chaŒne de caractŠres ($).
 '
 ' Interpr‚tation de la variable en retour :
 ' <Retour> donne le num‚ro de l'option dans l'ordre d'affichage, menus en
 ' cascades compris. Un tiret gris‚ compte pour une option.
 '
 ' Variables … modifier selon besoin :
 '                Nb_% : Nombre d'options maximum.
 '              Lopt_% : Longueur maximale d'une option.
 '                 C_$ : CaractŠre utilis‚ pour options gris‚es.
 '
 '
 '                    Nouvelles fonctions - Mai 1992
 '                    ------------------------------
 '
 ' Check_Mark(R%,T$) et Uncheck_Mark(R%,T$) permettent de poser et de
 ' retirer une marque … une option du menu .
 '              R% : Indice de l'option … marquer.
 '              T$ : ChaŒne complŠte du Pop-Menu modifi‚e en retour.
 '
 ' Change_Menu(T$,R%,M$) permet de changer le texte d'une option du menu.
 '              T$ : ChaŒne complŠte du Pop-Menu modifi‚e en retour.
 '              R% : Indice de l'option … changer.
 '              M$ : Nouveau texte de l'option.
 '
 ' Attention : Pour ces nouvelles fonctions, il est obligatoire de passer
 ' le texte du Pop-Menu sous forme de variable chaŒne.
 '
 '
 '                       Mise … jour - Avril 1993
 '                       ------------------------
 '
 ' Correction du bug m‚moire : Gestion dynamique => Aucune consommation de m‚moire.
 ' Version Falcon 030 : Adaptation aux nouveaux modes vid‚o.
 '
 '******************************************************************************
 '
 DEF PROC Pop_Menu(X%,Y%,T%,F%,Ch$,R R%)
   LOCAL Ind1%=0,Lmax%=0,V%=0,L%,H%,Buf1,D1%,D2%,Flag_%,Z%,Z1%,K%,O$
   LOCAL Xm%,Ym%,Old%,Str1$,Str2$,Xc%,Yc%,Lc%,Hc%,Buf2,Ex%=0,Rez%,Np%
   Nb_%=20:Lopt_%=255:C_$="-"
   IF WPEEK( LPEEK($4F2)+2)<$400 THEN
     XBIOS (Rez%,4):Np%=1 SHL (2-Rez%)
   ELSE
     XBIOS (Rez%,88,-1):Np%=2^(Rez% AND 7)
   ENDIF
   DIM O1_$(Nb_%),O2_$(Nb_%),O3_$(Nb_%),O4_$(Nb_%,2)
   IF RIGHT$(Ch$,1)="|" OR RIGHT$(Ch$,1)="]" THEN Ex%=-1
   WHILE INSTR(Ch$,"|")
     O1_$(Ind1%)= LEFT$(Ch$, INSTR(Ch$,"|")-1)
     IF INSTR(O1_$(Ind1%),"[") THEN
       O1_$(Ind1%)= LEFT$(Ch$, INSTR(Ch$,"[")-1)+"  "+ CHR$(3)
       IF LEN(O1_$(Ind1%))>Lopt_% THEN O1_$(Ind1%)= LEFT$(O1_$(Ind1%),Lopt_%)
       Lmax%= MAX(Lmax%, LEN(O1_$(Ind1%))):Ch$= MID$(Ch$, INSTR(Ch$,"[")+1)
       O3_$(Ind1%)= LEFT$(Ch$, INSTR(Ch$,"]")-1):Ind1%=Ind1%+1
       Ch$= MID$(Ch$, INSTR(Ch$,"]")+2)
     ELSE
       IF LEN(O1_$(Ind1%))>Lopt_% THEN O1_$(Ind1%)= LEFT$(O1_$(Ind1%),Lopt_%)
       Lmax%= MAX(Lmax%, LEN(O1_$(Ind1%))):Ch$= MID$(Ch$, INSTR(Ch$,"|")+1)
       IF O1_$(Ind1%)="" THEN O1_$(Ind1%)=C_$
       Ind1%=Ind1%+1
     ENDIF
   WEND
   '
   ' Ce qui suit sert … forcer les flŠches des options proposant un menu
   ' en cascade … ˆtre align‚es … droite... Question de go–t !
   '
   FOR I%=0 TO Ind1%
     IF RIGHT$(O1_$(I%),1)= CHR$(3) AND LEN(O1_$(I%))<>Lmax% THEN
       O1_$(I%)= LEFT$(O1_$(I%), LEN(O1_$(I%))-1)+ SPACE$(Lmax%- LEN(O1_$(I%)))+ CHR$(3)
    ENDIF
   NEXT I%
   '
   O1_$(Ind1%)=Ch$:Lmax%= MAX(Lmax%, LEN(O1_$(Ind1%))):Str1$=C_$*(Lmax%+1)
   IF Ex% THEN Ind1%=Ind1%-1
   FOR I%=0 TO Ind1%
     IF O1_$(I%)=C_$ THEN O1_$(I%)=Str1$
   NEXT I%
   K%=0
   FOR I%=0 TO Ind1%
     O4_$(K%,0)=O1_$(I%):O4_$(K%,2)= STR$(I%+1)
     IF O3_$(I%)<>"" THEN
       O$=O3_$(I%)
       WHILE INSTR(O$,"|")
         O4_$(K%,1)= LEFT$(O$, INSTR(O$,"|")-1)
         O$= MID$(O$, INSTR(O$,"|")+1)
         IF O4_$(K%,1)="" THEN O4_$(K%,1)=C_$
         K%=K%+1
       WEND
       O4_$(K%,1)=O$:K%=K%+1
      ELSE
        K%=K%+1
      ENDIF
    NEXT I%
   L%=Lmax%*8+10:H%=Ind1%*16+32:L1%=L%+2:H1%=H%+2
   Buf1= MEMORY(6+(L1%+15) SHR 4*H1%*2*Np%)
   WHILE MOUSEBUT <>0: WEND :Draw_Box_(X%,Y%,L%,H%,Ind1%,T%,F%,Str1$,Buf1)
   MOUSEON :Flag_%=0:R%=0:Z%=0:Z1%=0:D1%=Ind1%+2:D2%=D1%-Ind1%+2
   OUTLINE OFF
   REPEAT
     Xm%= MOUSEX :Ym%= MOUSEY
     IF Ym%>Y% AND Ym%<Y%+H% AND Xm%>X% AND Xm%<X%+L% THEN
       Old%=R%:R%=(Ym%-Y%+H%)\16-D1%
       IF Old%>0 AND R%=0 THEN MOUSEOFF : PBOX X%+1,Y%+Old%*16-D2%,L%-2,16: MOUSEON : GOTO L1_
       IF R%>0 AND Old%<>0 THEN IF O1_$(R%-1)=Str1$ THEN
         MOUSEOFF : PBOX X%+1,Y%+Old%*16-D2%,L%-2,16: MOUSEON
         Old%=R%: WHILE Old%=R%:Ym%= MOUSEY :R%=(Ym%-Y%+H%)\16-D1%: WEND
         R%=0:Old%=1: GOTO L1_
       ENDIF
       IF Old%<>R% THEN
         MOUSEOFF
         IF Old%=0 THEN PBOX X%+1,Y%+R%*16-D2%,L%-2,16 ELSE PBOX X%+1,Y%+R%*16-D2%,L%-2,16: PBOX X%+1,Y%+Old%*16-D2%,L%-2,16
         MOUSEON
         IF RIGHT$(O1_$(R%-1),1)= CHR$(3) THEN
           OUTLINE ON
           Draw_Cascade_(X%,Y%,L%,H%,R%,T%,F%,O3_$(R%-1),Xc%,Yc%,Lc%,Hc%,Buf2,Ind2%,Np%)
           OUTLINE OFF
           Old%=R%
           WHILE R%=Old%
             Xm%= MOUSEX :Ym%= MOUSEY :R%=(Ym%-Y%+H%)\16-D1%
             IF Xm%<X% THEN EXIT
             IF Ym%>Yc% AND Ym%<Yc%+Hc% AND Xm%>Xc% AND Xm%<Xc%+Lc% THEN
               Cascade_(Xc%,Yc%,Lc%,Hc%,Ind2%,V%,R1%):Z%=R%:Z1%=R1%: EXIT
             ENDIF
           WEND
           MOUSEOFF : BITBLT Buf2 TO Xc%,Yc%,Lc%,Hc%: FRE (Buf2)
           PBOX X%+1,Y%+Old%*16-D2%,L%-2,16: MOUSEON :Old%=1:R%=0
           IF V% THEN Flag_%=-1:R1%=0: MOUSEOFF : BITBLT Buf1 TO X%,Y%-2,L%+2,H%+2: MOUSEON
         ENDIF
       ENDIF
      -L1_
       IF MOUSEBUT THEN
         MOUSEOFF : OUTLINE ON
         IF Ym%>Y% AND Ym%<Y%+8 THEN
           MODE =3: LINE STYLE =5
           WHILE MOUSEBUT <>0
             Xpos%= MOUSEX :Ypos%= MOUSEY
             IF Xpos%<> MOUSEX OR Ypos%<> MOUSEY THEN
               BOX Xpos%,Ypos%,L%,H%: BOX Xpos%,Ypos%,L%,H%
             ELSE
               BOX Xpos%,Ypos%,L%,H%
               WHILE Xpos%= MOUSEX AND Ypos%= MOUSEY AND MOUSEBUT <>0: WEND
               BOX Xpos%,Ypos%,L%,H%
             ENDIF
           WEND
           BITBLT Buf1 TO X%,Y%-2,L%+2,H%+2: LINE STYLE =1
           X%=Xpos%:Y%=Ypos%:Draw_Box_(X%,Y%,L%,H%,Ind1%,T%,F%,Str1$,Buf1)
         ELSE
           BITBLT Buf1 TO X%,Y%-2,L%+2,H%+2:Flag_%=-1: WHILE MOUSEBUT <>0: WEND
         ENDIF
         MOUSEON : OUTLINE OFF
       ENDIF
     ELSE
       IF MOUSEBUT THEN
         Flag_%=-1: MOUSEOFF : BITBLT Buf1 TO X%,Y%-2,L%+2,H%+2: MOUSEON
         WHILE MOUSEBUT <>0: WEND :R%=0
       ENDIF
     ENDIF
   UNTIL Flag_%
   OUTLINE ON
   IF R%=0 AND Z1%<>0 THEN R%=Z% ELSE Z1%=0
   IF R%<>0 THEN Get_Opt_(R%,Z1%)
   FRE (Buf1)
 RETURN
 '
 DEF PROC Draw_Box_(X%,Y%,L%,H%,Ind1%,T%,F%,Str1$,Buf1)
   LOCAL D%,I%
   MOUSEOFF : LINE STYLE =1: MODE =1
   FILL STYLE =0,0: FILL COLOR =1: LINE COLOR =1
   BITBLT X%,Y%-2,L%+2,H%+2 TO Buf1: PBOX X%,Y%,L%,H%
   FILL STYLE =1,1: PBOX X%+2,Y%-2,L%,2: PBOX X%+L%,Y%-2,2,H%: FILL STYLE =2,4: PBOX X%,Y%,L%,8
   IF T% THEN TEXT HEIGHT =13 ELSE TEXT HEIGHT =6
   TEXT COLOR =1: FILL STYLE =1,1: MODE =3
   FOR I%=0 TO Ind1%
     IF O1_$(I%)=Str1$ THEN TEXT STYLE =2:D%=1 ELSE TEXT STYLE =0:D%=5
     IF F% THEN TEXT X%+((L%- LEN(O1_$(I%)*8))/2),Y%+I%*16+24,O1_$(I%) ELSE TEXT X%+D%,Y%+I%*16+24,O1_$(I%)
   NEXT I%
   MOUSEON
 RETURN
 '
 DEF PROC Get_Opt_(R R%,Z1%)
   LOCAL I%=-1
   REPEAT :I%=I%+1: UNTIL R%= VAL(O4_$(I%,2)) OR I%=Nb_%
   IF Z1%<>0 THEN R%=I%+Z1% ELSE R%=I%+1
 RETURN
 '
 '-----------------------------------------------------------------------------
 '                    Partie g‚rant les menus en cascades.
 '                       (… supprimer si non utilis‚s)
 '-----------------------------------------------------------------------------
 '
 DEF PROC Draw_Cascade_(X%,Y%,L%,H%,R%,T%,F%,Ch$,R Xc%,R Yc%,R Lc%,R Hc%,R Buf2,R Ind2%,Np%)
   LOCAL Ind1%=0,Lmax%=0
   WHILE INSTR(Ch$,"|")
     O2_$(Ind1%)= LEFT$(Ch$, INSTR(Ch$,"|")-1)
     IF LEN(O2_$(Ind1%))>Lopt_% THEN O2_$(Ind1%)= LEFT$(O2_$(Ind1%),Lopt_%)
     Lmax%= MAX(Lmax%, LEN(O2_$(Ind1%))):Ch$= MID$(Ch$, INSTR(Ch$,"|")+1)
     IF O2_$(Ind1%)="" THEN O2_$(Ind1%)=C_$
     Ind1%=Ind1%+1
   WEND
   O2_$(Ind1%)=Ch$:Lmax%= MAX(Lmax%, LEN(O2_$(Ind1%))):Str2$=C_$*(Lmax%+1)
   FOR I%=0 TO Ind1%
     IF O2_$(I%)=C_$ THEN O2_$(I%)=Str2$
   NEXT I%
   Lc%=Lmax%*8+10:Hc%=Ind1%*16+24
   Buf2= MEMORY(6+(Lc%+15) SHR 4*Hc%*2*Np%)
   WHILE MOUSEBUT <>0: WEND
   MOUSEOFF : LINE STYLE =1: MODE =1: FILL STYLE =0,0:Yc%=Y%+R%*16:Xc%=X%+L%
   BITBLT Xc%,Yc%,Lc%,Hc% TO Buf2: PBOX Xc%,Yc%,Lc%,Hc%
   IF T% THEN TEXT HEIGHT =13 ELSE TEXT HEIGHT =6
   TEXT COLOR =1: FILL STYLE =1,1: MODE =3
   FOR I%=0 TO Ind1%
     IF O2_$(I%)=Str2$ THEN TEXT STYLE =2:D%=1 ELSE TEXT STYLE =0:D%=5
     IF F% THEN TEXT Xc%+((Lc%- LEN(O2_$(I%)*8))/2),Yc%+I%*16+16,O2_$(I%) ELSE TEXT Xc%+D%,Yc%+I%*16+16,O2_$(I%)
   NEXT I%
   MOUSEON
   Ind2%=Ind1%
 RETURN
 '
 DEF PROC Cascade_(Xc%,Yc%,Lc%,Hc%,Ind2%,R V%,R R1%)
   LOCAL Flag_%=0,Old%=0,D1%=Ind2%+1,D2%=D1%-Ind2%+12
   R1%=0:V%=-1
   REPEAT
     Xm%= MOUSEX :Ym%= MOUSEY
     IF Ym%>Yc% AND Ym%<Yc%+Hc% AND Xm%>Xc% AND Xm%<Xc%+Lc% THEN
       Old%=R1%:R1%=(Ym%-Yc%+Hc%)\16-D1%
       IF Old%>0 AND R1%=0 THEN MOUSEOFF : PBOX Xc%+1,Yc%+Old%*16-D2%,Lc%-2,16: MOUSEON : GOTO L2_
       IF R1%>0 AND Old%<>0 THEN IF O2_$(R1%-1)=Str2$ THEN
         MOUSEOFF : PBOX Xc%+1,Yc%+Old%*16-D2%,Lc%-2,16: MOUSEON
         Old%=R1%: WHILE Old%=R1%:Ym%= MOUSEY :R1%=(Ym%-Yc%+Hc%)\16-D1%: WEND
         R1%=0:Old%=1: GOTO L2_
       ENDIF
       IF Old%<>R1% THEN
         MOUSEOFF
         IF Old%=0 THEN PBOX Xc%+1,Yc%+R1%*16-D2%,Lc%-2,16 ELSE PBOX Xc%+1,Yc%+R1%*16-D2%,Lc%-2,16: PBOX Xc%+1,Yc%+Old%*16-D2%,Lc%-2,16
         MOUSEON
       ENDIF
      -L2_
       IF MOUSEBUT THEN MOUSEOFF :Flag_%=-1: WHILE MOUSEBUT <>0: WEND : MOUSEON
     ELSE
       BITBLT Buf2 TO Xc%,Yc%,Lc%,Hc%:Flag_%=-1:R1%=0:V%=0: FRE (Buf2)
     ENDIF
   UNTIL Flag_%
 RETURN
 '
 DEF PROC Check_Mark(R%,R T$)
   LOCAL X$,P%
   R%=R%-1: IF O4_$(R%,1)<>"" THEN X$=O4_$(R%,1) ELSE X$=O4_$(R%,0)
   P%= INSTR(T$,X$): MID$ (T$,P%,3)= CHR$(8)
 RETURN
 '
 DEF PROC Uncheck_Mark(R%,R T$)
   LOCAL X$,P%
   R%=R%-1: IF O4_$(R%,1)<>"" THEN X$=O4_$(R%,1) ELSE X$=O4_$(R%,0)
   P%= INSTR(T$,X$): MID$ (T$,P%,1)= CHR$(32)
 RETURN
 '
 DEF PROC Change_Menu(R T$,R%,M$)
   LOCAL X$,P%
   R%=R%-1: IF O4_$(R%,1)<>"" THEN X$=O4_$(R%,1) ELSE X$=O4_$(R%,0)
   P%= INSTR(T$,X$):T$= LEFT$(T$,P%-1)+M$+ MID$(T$,P%+ LEN(X$))
 RETURN
