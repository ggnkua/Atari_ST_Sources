
 ' PRINT (6+(214+15) SHR 4*2*100*4)
 'PRINT @(10,0); FRE(0): GEMDOS ,7
 '
 '
 '****************************************************************************
 '                                REDUC_V9
 '
 '                  COIMPILEZ AVEC LE COMPILATEUR v4.08
 '
 '****************************************************************************
 '
 ' Fonctionne en ACC et PRG
 '
 ' Enleve : les lignes vide
 '        : les commentaires
 '        : Des  Fichiers ASCII ( sauvegarde par "SAVE BLOCK" )
 '
 ' les numÇros de ligne ne doivent pas Çtre sauvÇ
 '
 '...................................................................16/11/2017
 'Nettoyage du REM
 'Il restait des esapces vide en fin de quelque string
 'La taille du texte est fixÇ
 'Correction Redraw pour Çmulateur HAtari
 'prise en chage des fichier LST   bien que soit inutile :)
 '...................................................................28/12/2016
 'between statement.... is good !
 '...................................................................24/12/2015
 'P....  ca bug toujours
 'Un caractäre est parfois remplacÇ par n'inporte quoi
 '...................................................................20/05/2015
 'ajout de Aa%=A%-1
 'modif de For Z%=1 to Z%-1 devien For Adr_Line+1 to Adr_Line+aa%
 'dÇplacement du: Gabardage dans Condense
 'allignement du texte dans les box
 'ajout box_alerte contenant version et datte
 '...................................................................02/10/2014
 'CorrigÇ erreur  :  FOR Z=1 TO A% devient  FOR Z=1 TO A%-1
 '...................................................................02/09/2014
 ' Modifie
 '   G%= INSTR(A%,Line$, CHR$(34))
 '   G%= INSTR(A%,Line$, CHR$(34))+1
 '
 '------------------------------------------------------------------------------
  '
  COMPILER "STACK 16384; BAS_MEM 16384; MBS ; TRACE ON; CUTLIB"
  COMPILER "multitasking between statements": COMPILER "trace on"
  IPL 3 SHL 31: PRINT @(0,0);"f"
  Version$="- 16/11/2017 -"

  TEXT COLOR =1: TEXT HEIGHT =6: TEXT STYLE =0: LINE COLOR =1


  Seg_Ptr%L= LPEEK( SEGPTR +20)' = 0 apräs compilation
  '                                n'est pas retirÇ par le compilateur ! :(

 '..................................................TABLEAUX AES ET ADRESSES...
  DIM Msg%(7),Ctrl%(12),Intin%(128),Addrout%L(128),Intout%(128),Ptsin%(1,128),Ptsout%(1,128),Addrin%L(3),Global%(15)
  Ctrl%L=Seg_Ptr%L+ LPEEK( VARPTR(Ctrl%(0)))
  Intin%L=Seg_Ptr%L+ LPEEK( VARPTR(Intin%(0)))
  Addrout%L=Seg_Ptr%L+ LPEEK( VARPTR(Addrout%L(0)))
  Intout%L=Seg_Ptr%L+ LPEEK( VARPTR(Intout%(0)))
  'Ptsin=Seg_Ptr+ LPEEK( VARPTR(Ptsin%(0,0)))
  Ptsout%L=Seg_Ptr%L+ LPEEK( VARPTR(Ptsout%(0,0)))
  Addrin%L=Seg_Ptr%L+ LPEEK( VARPTR(Addrin%L(0)))
  'Global=Seg_Ptr+ LPEEK( VARPTR(Global%(0)))
  Adr_Msg%L=Seg_Ptr%L+ LPEEK( VARPTR(Msg%(0)))
  '................................................................APPL_INIT...
  Ap_Id%=-1: AES (10,Global%(0),Intin%(11),Addrin%L(0),Intout%(1),Addrout%L(0))
  IF WPEEK(Intout%L)<0 THEN END ENDIF
  Ap_Id%= WPEEK(Intout%L)
  '................................................................SHEL_READ...
  '   UtilesÇ pour rÇcupÇrer
  '    - Le chemin de lancement du programme
  '    - Le mode d'execution du programe ( ACC ou PRG )
  '
  IF COMPILER THEN
      Sh_Rpcmd%L= MEMORY( SPC(128)):Sh_Rp_Tail%L= MEMORY( SPC(100))
      Intin%(0)=128
      Intin%(1)=100
      MEMORY_MOVE VARPTR(Sh_Rpcmd%L),8 TO Addrin%L
      MEMORY_MOVE VARPTR(Sh_Rp_Tail%L),8 TO Addrin%L+8
      AES (120,Global%(0),Intin%(2),Addrin%L(2),Intout%(1),Addrout%L(0))

     '~ chemin de lancement ~
      Z%=0: WHILE PEEK(Sh_Rpcmd%L+Z%)>0:Z%=Z%+1 WEND :Rpcmd$= SPC(Z%)
      MEMORY_MOVEB Sh_Rpcmd%L,Z% TO LPEEK( SEGPTR +28)+ LPEEK( VARPTR(Rpcmd$))
     'rÇcup du chemin de lancement du prog
     'recherche "\" en commencant par la fin
      WHILE Z%>0: IF PEEK(Sh_Rpcmd%L+Z%)=92 THEN EXIT ENDIF Z%=Z%-1 WEND

     'Si Z%=0, C'est pas ACC !
     IF Z%=0 THEN
          Name_Prg$=Rpcmd$'       Ca peut Çtre le nom d'un ACC appellÇ avant
          Chem_Prg$="a:\"'        Toujours pour un  ACC
     ELSE
         'Name_Prg$= MID$(Rpcmd$,Z%+2)'            Toujours le nom d'un prg
         '                  On peu donc changer son nom et le rÇccuperÇ ici
         Chem_Prg$= LEFT$(Rpcmd$,Z%+1)'            Path d'un prg
     ENDIF

     'ligne de commande, rien Ö reccupÇrrer ici  pour ce programe
     'z%=0: WHILE PEEK(Sh_Rp_Tail+z%)>$D:Rptail$=Rptail$+ CHR$( PEEK(Sh_Rp_Tail+z%)):z%=z%+1 WEND
     '
     FRE (Sh_Rp_Tail%L): FRE (Sh_Rpcmd%L)
     Accessory%= ABS(Z%=0)
     Name_Prg$="REDUC_v9."+ MID$("PRGACC",Accessory%*3+1,3)
  ENDIF
  '----------------------------------------------------
  COMPILER OFF
     'lecteur du basic par defaut
      GEMDOS (R%L,25):Drv%L=R%L+1:Adr%L= MEMORY( SPC(64)): GEMDOS (R%L,71,L Adr%L,Drv%L)
      Chem_Prg$= CHR$(64+Drv%L)+":\"
      Name_Prg$="REDUC_v9.BAS"
      FRE (Adr%L)
  COMPILER ON

  '----------------------------------------------------------------------------
  '                                    PRG
  '----------------------------------------------------------------------------
  IF Accessory%=0 THEN
      ON ERROR GOTO Traite_Err
      GOSUB Mode_Prg

      'Appl_Exit
      AES (19,Global%(0),Intin%(0),Addrin%L(0),Intout%(1),Addrout%L(0))

      ON ERROR GOTO 0
      CLEAR
      END
  ENDIF
 '------------------------------------------------------------------------------
 '                            INIT ACCESSOIRE
 '------------------------------------------------------------------------------
 '...............................................................MENU_REGISTER
  Me_Text%L= MEMORY("  "+ MID$(Name_Prg$,1, INSTR(Name_Prg$,".")-1))
  Intin%(0)=Ap_Id%
  MEMORY_MOVE VARPTR(Me_Text%L),8 TO Addrin%L
  AES (35,Global%(0),Intin%(1),Addrin%L(1),Intout%(1),Addrout%L(0))
  Acc_Id%=Intout%(0)

 'pas de place dans le menu pour mon Accessoire
  IF Acc_Id%=-1 THEN IPL 3: END ENDIF

  'COMPILER OFF
 'texte visible au boot du ST
  RESTORE "INFO_ACC"
  FOR Z%=0 TO 8: READ A$: PRINT ;A$: NEXT Z%: WAIT 2
  'COMPILER ON

 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 '                            ACC ET PRG
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  MOUSEON
  REPEAT
      MEMORY_MOVE VARPTR(Adr_Msg%L),8 TO Addrin%L
      AES (23,Global%(3),Intin%(0),Addrin%L(1),Intout%(7),Addrout%L(0))
      Msg%L=Msg%(0)
      IF Msg%(4)=Acc_Id% THEN
          IF Msg%L=40 THEN
              Wind_Update(1):Wind_Update(3)

              ON ERROR GOTO Traite_Err
             -Mode_Prg
              Init_Prg
              Buf_Box%L= MEMORY(11206): BITBLT Mx%-107,My%-50,214,100 TO Buf_Box%L

             -Re_Acc_Prg:Condense
              IF Eror_File% THEN Eror_File%=0: GOTO Re_Acc_Prg ENDIF
              Mous_On
              Clean_Desktop
              FRE (Buf_Box%L)
              IF Accessory%=0 THEN RETURN ENDIF

              ON ERROR GOTO 0

              Wind_Update(2):Wind_Update(0)
          ENDIF
      ENDIF
  UNTIL 0
 '-------------------------------------------------------------------------------
 '                      INIT DU PROG ( ACC ET PRG )
 '-------------------------------------------------------------------------------
  DEF PROC Init_Prg
      'open virtual screen workstation
       Ctrl%(6)=1:Intin%(0)=1
       Intin%(1)=1'             set polyline type
       Intin%(2)=1'             set polyline color index
       Intin%(5)=1'             fonte de caractäres
       Intin%(7)=1'             set fill intetior style
       Intin%(8)=4'             set fill style index
       Intin%(9)=3'             set fill color index
       Intin%(10)=1'            set size text by basic
       VDI (100,Ctrl%(0),Intin%(11),Ptsin%(0,0),Intout%(45),Ptsout%(0,0))

       IF WPEEK(Ctrl%L+12)<=0 THEN END ENDIF
       Vdi_Handle%= WPEEK(Ctrl%L+12)

      'coordonnÇes pour l'affichage des objets celon la rÇsolution
       Mx%=( WPEEK(Intout%L)+1)\2:My%=( WPEEK(Intout%L+2)+1)\2

      'coordonnÇes pour l'affichage des textes celon la rÇsolution
       'X_T%=Mx%+16:Y_T1%=My%-3:Y_T2%=My%+7
       X_T%=Mx%+56:Y_T1%=My%-3:Y_T2%=My%+7:Y_T3%=My%+17

       TEXT COLOR =1: TEXT HEIGHT =6: TEXT STYLE =0

      'buffer pour palette
       Pal%L= MEMORY(32): MEMORY_MOVE $FF8240,32 TO Pal%L

      'buffer ecran
       Ecr%L= MEMORY(32000-1440)

      'path : prg, source, but
       DIM Path$(3)

      'color : blanc, rouge, bleue, noir
       WPOKE $FF8240,$FFF: WPOKE $FF8240+2,$F00: WPOKE $FF8240+4,$F: WPOKE $FF8240+6,0: WPOKE $FF8240+30,$0

       Mous_Off: MODE =1: FILL STYLE =1,0: OUTLINE ON : TEXT HEIGHT =6

       High_Rez%= ABS( PEEK($44C)<>2)

       Xm%=18-7*High_Rez%
       IF Accessory%=0 THEN 'AND High_Rez%=1 THEN
           FILL COLOR =3*High_Rez%: PBOX 0,Xm%,Mx%*2,My%*2-Xm%
           DRAW 0,Xm%-1 TO Mx%*2,Xm%-1
       ENDIF

       'MEMORY_MOVE LPEEK($44E)+1440,32000-1440 TO Ecr
       Dta%L= MEMORY(44): GEMDOS (R%L,26, HIGH(Dta%L), LOW(Dta%L))
       Seg_Ptr%L= LPEEK( SEGPTR +28)
  RETURN
 '------------------------------------------------------------------------------
  DEF PROC Clean_Desktop
      'Vdi_Exit
       Ctrl%(6)=Vdi_Handle%: VDI (101,Ctrl%(0),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0))
      '
       MEMORY_MOVE Pal%L,32 TO $FF8240: FRE (Dta%L): FRE (Ecr%L): FRE (Pal%L):Gabardage
       WHILE MOUSEBUT <>0 WEND
  RETURN
 '------------------------------------------------------------------------------
 '
 '------------------------------------------------------------------------------
  DEF PROC Condense

    'retour  "Cancel" du selecteur de fichier
    'retour   Apräs fin de netoyage
    -Re_Tree_Line:Tilte_Tree%=0:Tree_Line(-1)

    'retour boutons ( ? FR OK GB )
    -Modif_Tree:First_Bt%=0:Boton_Line:First_Bt%=0

     'gestion des bouton, bt% >2 pour ne pas bloquer un bouton
     Bt%=3:Boton_Tree

     IF Bt%=0 THEN Clean_Box: RETURN ENDIF

     'boutons ( ? FR OK GB )
     IF Bt%=2 THEN Tree_Info:Tree_Line(1): GOTO Modif_Tree ENDIF

     '...............................................SELECTION DES FICHIERS...
     Cd%=0:Clean_Box

     -Re_Select
     Selecteur( MID$(Label$,Cd%*Label%+1,Label%),Path$(Cd%),Path$(Cd%+2),Ret%)
     IF Ret%=0 THEN First_Bt%=2: GOTO Re_Tree_Line ENDIF

     Read_Line%=0:Sav_Line%=0:Rectif_Line%=0:Reduc%=0

     IF Cd%=0 THEN
           Tail_S%L= LPEEK(Dta%L+26):Cd%=1
           IF LEN(Path$(1))=0 THEN Path$(1)=Path$(0) ENDIF
           GOTO Re_Select
     ENDIF

     OPEN "I",1,Path$(0)+Path$(2)
     OPEN "O",2,Path$(1)+Path$(3)

     '....................................................REAFFICHE BOX_LINE...
     Mous_Off
     Tilte_Tree%=0:First_Bt%=0:Tree_Line(-1):Tree_Line(1):Tree_Wait
     '.............................................................NETTOYAGE...
     Info_File$=Path$(2)
     Lst%= UPPER$( RIGHT$(Path$(2),3))="LST"
     Char1%=39+6*Lst%'                                   Omikron  ['], Gfa [!]
     '                                 'X_T%=Mx%+16:Y_T1%=My%-3:Y_T2%=My%+7
     Ti!= TIMER
     WHILE NOT EOF(1)
        TEXT X_T%- LEN( STR$(Read_Line%))*8,Y_T1%, STR$(Read_Line%)

                     '' A% for ( ' )  or ( REM ) or ( ! )  for Lst file
                     '' G% for ( " )
                     ''
                     ''
                     '' ( ____ ) = zone de test
                     '' ( xxxx ) donnÇes a conserver
                     '' ( .... ) donÇes a supprimer
                     ''
                     ''
                     ''   ( ' )
                     ''   En tete de ligne
                     ''   Apräs la derniäre commande d'une ligne  sans ( " )
                     ''   Apres un nombre pair ( " ) dans  Sring ou Data
                     ''   Apres un nompre impair de ( " ) dans String ou Data
                     ''
        Line$="":Gabardage
        LINE INPUT #1,Line$: IF Line$="" THEN GOTO Passe ENDIF
        Adr_Line%L= LPEEK( SEGPTR +28)+ LPEEK( VARPTR(Line$))

        A%= INSTR(Line$, CHR$(39))'                               cherche ( ' )
        '                                                         cherche ( ! )
        IF A%=0 THEN IF Lst% THEN A%= INSTR(Line$, CHR$(33)) ENDIF ENDIF

        IF A%>0 THEN
          Aa%=A%-1
          IF LEFT$(Line$,Aa%)= SPC(Aa%) THEN GOTO Passe ENDIF

          G%= INSTR(Line$, CHR$(34))'                             cherche ( " )

          -Loop
          '                                   line$= ( __'... ) ou ( __'... " )
          '                                   ou   = ( __.'.. ) ou ( __.'..." )
          IF G%=0 OR G%>A% THEN Line$= LEFT$(Line$,Aa%): GOTO Space ENDIF

          G%=1
          FOR Z%L=Adr_Line%L+1 TO Adr_Line%L+Aa%: IF PEEK(Z%L)=34 THEN G%=G%+1 ENDIF NEXT Z%L

          'nombre pair de ( " ) avant ( ' )                   (..xx"xxx"..'.. )
          IF G% AND 1 THEN Line$= LEFT$(Line$,Aa%): GOTO Space ENDIF

          'nombre impair de ( " ) avant  ( ' )          chercher l' autre ( " )
          G%= INSTR(A%,Line$, CHR$(34))+1

          '                            cherche ( ' ) apräs nombre pair de ( " )
          A%= INSTR(G%,Line$, CHR$(Char1%))
          'A%= INSTR(G%,Line$, CHR$(39))

          IF A% THEN Aa%=A%-1: GOTO Loop ENDIF '-----------------un autre ( ' )
        ENDIF

        A%= INSTR(Line$,"REM")
        IF A%>0 THEN
           '                                                      ( ...REM ...)
           IF LEFT$(Line$,A%-1)= SPC(A%-1) THEN GOTO Passe ENDIF
           '                                                (..DATA "xxREMxx" )
           IF INSTR(Line$, CHR$(34))<A% THEN GOTO Space ENDIF
           '                                                  (...xxxx.REM....)
           Line$= MID$(Line$,1,A%-2)'                       = (...XXXX)
        ENDIF

        '                                            Espace en debut de ligne ?
        -Space:Z%=0: WHILE PEEK(Adr_Line%L+Z%)=32:Z%=Z%+1: WEND

        Lz%= LEN(Line$)
        IF Lz%>Z%+1 THEN
           '                                           Espace en fin de ligne ?
           WHILE RIGHT$(Line$,1)=" ":Lz%=Lz%-1:Line$= LEFT$(Line$,Lz%) WEND

           'PRINT #2, RIGHT$(Line$,Lz%-Z%)
           PRINT #2, MID$(Line$,Z%+1,Lz%)

           TEXT X_T%- LEN( STR$(Sav_Line%))*8,Y_T2%, STR$(Sav_Line%):Sav_Line%=Sav_Line%+1
           'ERROR 18
        ENDIF

        -Passe:Read_Line%=Read_Line%+1
     WEND

     Temps!=( TIMER -Ti!)/200:Reduc%=-1:Rectif_Line%=1

     Graf_Mouse(0)

     -No_Ascii: CLOSE :Select%=0:Gabardage

     '...............................................................fdelete...
     IF Eror_File% THEN
        Read_Line%=0:Sav_Line%=0:Rectif_Line%=0:Reduc%=0
        Adr%L= MEMORY(Path$(1)+Path$(3)+ CHR$(0)): GEMDOS (R%L,65,L Adr%L): FRE (Adr%L)
        EXIT 'sort de la procÇdure et remet la PILE a zero
     ENDIF
     ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

     WHILE MOUSEBUT <>0 WEND : WPOKE VARPTR( MOUSEBUT )+8,0:Mous_Off
     GOTO Re_Tree_Line
  RETURN

  DEF PROC Clean_Box
    IF Tree_Box%=0 THEN GEMDOS ,7: RETURN ENDIF
    Mous_Off
    XBIOS ,37: BITBLT Buf_Box%L TO Mx%-107,My%-50,214,100: XBIOS ,37:Tree_Box%=0
  RETURN
 '------------------------------------------------------------------------------
 '
 '------------------------------------------------------------------------------
  DEF PROC Selecteur(Apltxt$,Chem$,File$,R Select%)
        Mous_Off: MEMORY_MOVE LPEEK($44E)+1440,32000-1440 TO Ecr%L

       -Selecteur
        Mous_On: WHILE MOUSEBUT <>0 WEND
        XBIOS (,37)
        IF LEN(Chem$)=0 THEN
            Chem$=Chem_Prg$:Path$(Cd%)=Chem$:Path$(Cd%+2)="":File$=""
        ENDIF
        Chem$=Chem$+"*.*"

        Inpath%L= MEMORY(Chem$+ CHR$(0)+ SPC(64- LEN(Chem$)))
        Insel%L= MEMORY(File$+ CHR$(0)+ SPC(64- LEN(Lile$)))
        Label%L= MEMORY(Apltxt$+ CHR$(0))

        MEMORY_MOVE VARPTR(Inpath%L),8 TO Addrin%L
        MEMORY_MOVE VARPTR(Insel%L),8 TO Addrin%L+4
        MEMORY_MOVE VARPTR(Label%L),8 TO Addrin%L+8
        AES (91,Global%(0),Intin%(0),Addrin%L(3),Intout%(2),Addrout%L(0))
        Select%=Intout%(1)

        Chem$=FN Path$(Inpath%L):File$=FN Path$(Insel%L)

        FRE (Label%L): FRE (Insel%L): FRE (Inpath%L)

        Mous_Off: MEMORY_MOVE Ecr%L,32000-1440 TO LPEEK($44E)+1440

        IF Select%=0 THEN GOTO Retour ENDIF

        IF LEN(File$)=0 THEN Chem$=Path$(Cd%):File$=Path$(Cd%+2): GOTO Selecteur ENDIF

        Chem$= MIRROR$(Chem$):Chem$= MIRROR$( MID$(Chem$, INSTR(Chem$,"\")))

       'Erreur : but = soure
        IF Cd%=1 THEN IF Chem$+File$=Path$(0)+Path$(2) THEN Alert(1,"A3",Dummy%):File$="": GOTO Selecteur ENDIF ENDIF

        IF NOT FN Find%L THEN Chem$=Path$(Cd%):File$=Path$(Cd%+2): GOTO Selecteur ENDIF

        Path$(Cd%)=Chem$
        Path$(Cd%+2)=File$
       -Retour:Gabardage
  RETURN
  DEF FN Path$(Adresse%L)
       Z%=0: WHILE PEEK(Adresse%L+Z%)>0:Z%=Z%+1 WEND
       Adr$= SPC(Z%)
       MEMORY_MOVEB Adresse%L,Z% TO Seg_Ptr%L+ LPEEK( VARPTR(Adr$))
  RETURN Adr$
 '------------------------------------------------------------------------------
 ' Cd%=0 pour fichier source
 ' Cd%=1 pour fichier but
 '------------------------------------------------------------------------------
  DEF FN Find%L
        Mous_On
        GEMDOS (Dta%L,47)
        Adr%L= MEMORY(Chem$+File$): GEMDOS (R%L,78,L (Adr%L),63): FRE (Adr%L)

       'fichier trouvÇ
        IF R%L=0 THEN
           'c'est le Nom d'un dossier ou d'une disquette
            IF PEEK(Dta%L+21)=$8 OR PEEK(Dta%L+21)=$10 THEN Alert(1,"S"+ RIGHT$( STR$(Cd%),1),Dummy%): RETURN 0 ENDIF

           'fichier source trouvÇ
            IF Cd%=0 THEN RETURN -1 ENDIF

           'fichier but existant
            Alert(1,"R3",Ok%): IF Ok%=2 THEN RETURN 0 ENDIF

           '>> attribut lecture / ecriture   'Çcriture sur disk imposibe ???
            Adr%L= MEMORY(Chem$+File$): GEMDOS (R%L,67,L Adr%L,1,0): FRE (Adr%L)
            IF FN Test_Err%L(0,R%L) THEN RETURN 0 ENDIF
        ELSE
             IF FN Test_Err%L(-33*Cd%,R%L) THEN RETURN 0 ENDIF
        ENDIF

       '
        Libre%L= FRE(Chem$)
        IF Libre%L<Tail_S%L+1024 THEN
            Libre$=" "*(7- LEN( STR$(Libre%L)))+ STR$(Libre%L)
            Besoin$=" "*(7- LEN( STR$(Tail_S%L)))+ STR$(Tail_S%L)
            Alert(1,"A4",Dummy%)
            Libre$=""
            RETURN 0
        ENDIF
        Gabardage

       'crÇation du fichier de sauvegarde
        Adr%L= MEMORY(Chem$+File$+ CHR$(0)): GEMDOS (Handle%L,60,L Adr%L,0): FRE (Adr%L)
        R%L=Handle%L
        IF FN Test_Err%L(0,Handle%L) THEN RETURN 0 ENDIF

       'Fclose
        GEMDOS (R%L,62,Handle%L): IF FN Test_Err%L(0,R%L) THEN RETURN 0 ENDIF
  RETURN -1
 '------------------------------------------------------------------------------
 '
 '------------------------------------------------------------------------------
 'apl% =-1 redesine toute la boite
 '     = 1          les boite texte
 '------------------------------------------------------------------------------
  DEF PROC Tree_Line(Apl%)
        Tree_Box%=-1
        MODE =1: LINE COLOR =1: FILL STYLE =1,0
        RESTORE "TREE"
        FOR Z%=0 TO 3
           READ N0%,N1%,N2%,N3%,N4%,N5%
           IF Z%>Apl% THEN
              IF High_Rez%=0 THEN
                  IF Z%=1 THEN FILL STYLE =2,4 ELSE FILL STYLE =1,0 ENDIF
              ENDIF
              Pp_Box
           ENDIF
        NEXT Z%
       '
        RESTORE "LINE_"+ MID$("FRGB",Langue%+1,2)
       '-texte pour : Selecteur de fichier
       '              Non des boutons
        READ Label%,Label$,Info_File$,T_Bt1$,T_Bt2$,T_Bt3$

        IF LEN(Path$(2))>0 AND Tilte_Tree% THEN Info_File$=Path$(2) ENDIF
        Tilte_Tree%=-1

       'texte line
        Txt(4)

       'texte durant la reduction
        READ Wx%,Wy%,W$
  RETURN

 'First_Bt% n¯ du premier bouton a redessinner
 '         =0
 '         =2 uniquement apres cancel selecteur
 '
  DEF PROC Boton_Line
      RESTORE End_File:Txt(2)'nombre;  lu , sauvÇ, effacÇ

      IF Reduc% THEN
         Box_Rouge
         T$="Time :"+ STR$(Temps!):X%L= LEN(T$):X%L=(X%L\2)*8+(X%L MOD 2)*4
         MODE =2: TEXT COLOR =0: TEXT Mx%-X%L,My%+38,T$: TEXT COLOR =1
         Mous_On: WAIT 2:Mous_Off
         IF High_Rez%=0 THEN FILL STYLE =2,4 ELSE FILL STYLE =1,0 ENDIF
         Box_Rouge
         FILL STYLE =1,0
         Reduc%=0
      ENDIF

      'cadre des boutons
      'RESTORE "BT_TREE": FOR z%=0 TO 2: READ N0%,N1%,N2%,N3%,N4%,N5%:Pp_Box: NEXT z%
      N0%=0:N2%=My%+29:N3%=62:N4%=13:N5%=-1
      FOR Z%=First_Bt% TO 2:N1%=Mx%-99+Z%*68:Pp_Box: NEXT Z%

      'texte des boutons
      RESTORE T_Bt1$:Txt(2)
  RETURN
 '
  DEF PROC Tree_Wait
        Box_Rouge
        TEXT COLOR =0: MODE =2: TEXT Wx%,Wy%,W$
        TEXT COLOR =1: MODE =1
        Graf_Mouse(2):Mous_On
  RETURN
  DEF PROC Box_Rouge
        MODE =1
        'CLIP Mx%-99-1,My%+28,14+3*62,15
        CLIP Mx%-100,My%+28,200,15
        RESTORE Box_Rouge: READ N0%,N1%,N2%,N3%,N4%,N5%:Pp_Box
        CLIP 0,0,Mx%*2,My%*2
  RETURN
 '------------------------------------------------------------------------------
 '                            AFFICHE BOX INFO
 '------------------------------------------------------------------------------
  DEF PROC Tree_Info
      MODE =1: LINE COLOR =1: TEXT COLOR =1

     'redessine les deux box texte et le bouton ok
      RESTORE "FOR_INFO": FOR Z%=0 TO 2: READ N0%,N1%,N2%,N3%,N4%,N5%:Pp_Box: NEXT Z%

     'adresse texte des boutons
      T_Bt1$="BT1":T_Bt2$="BT2":T_Bt3$="BT3"

     'bouton langue selected
      Bt%=Ex_Bt%
     '''''''''''''''''''''''''''''''''''''''''''
      TEXT Mx%-8,My%+38,"Ok"

      REPEAT
        'text francais ou anglais et texte boton ok
         RESTORE "INFO_"+ MID$("FRGB",Langue%+1,2)
         Txt(4)

        'bouton FR & GB ( box et texte )
         N0%=0:N2%=My%+29:N3%=62:N4%=13:N5%=-1
         RESTORE "BT2"
         FOR Z%=0 TO 1
             N1%=Mx%-99+Z%*136: READ T1%,T2%,T$
             Inverse_Video( ABS(Bt%=Z%), ABS(Bt%=Z%) XOR 2)
         NEXT Z%

        'gestion des bouton
         Boton_Tree
         IF Bt%<>2 THEN Ex_Bt%=Bt%:Langue%=Langue% XOR 2 ENDIF
      UNTIL Bt%=2
  RETURN
 '------------------------------------------------------------------------------
 '            dessine un objet ( N5%= -1 pour les boutons )
 '------------------------------------------------------------------------------
  DEF PROC Pp_Box
       FILL COLOR =N0%
       PBOX N1%,N2%,N3%,N4%: BOX N1%,N2%,N3%,N4%
       IF N5% THEN BOX N1%-1,N2%-1,N3%+2,N4%+2 ENDIF
  RETURN
  DEF PROC Txt(Apl%): FOR T%=0 TO Apl%: READ T1%,T2%,Txt$: TEXT T1%,T2%,Txt$: NEXT T%: RETURN
 '------------------------------------------------------------------------------
 '                      gestion des boutons des deux arbres
 '                      sortie uniquement si bouton relachÇ
 '------------------------------------------------------------------------------
  DEF PROC Boton_Tree
     MODE =1: WHILE MOUSEBUT <>0 WEND :Mous_On

    'cordonÇes des boutons
     N0%=0:N2%=My%+29:N3%=62:N4%=13:N5%=-1:N6%=Mx%-31:N7%=Mx%-99:N8%=Mx%+37
     Boton%=0
    '
     REPEAT
        IF MOUSEBUT THEN
           IF Bt%=3 THEN
               IF MOUSEY >My%-43 AND MOUSEY <My%-31 THEN
               IF MOUSEX >Mx%-102 AND MOUSEX <Mx%+101 THEN
                   Alert(1,"INFO",Ok%)
               ENDIF
               ENDIF
           ENDIF

           IF Bt%<>2 THEN
              N1%=N6%
              IF FN In_Bouton%( MOUSEX , MOUSEY ) THEN
                   Clik_Boton(T_Bt1$): IF Boton%=1 THEN Bt%=2: EXIT ENDIF
              ENDIF
           ENDIF
           IF Bt%<>0 THEN
              N1%=N7%
              IF FN In_Bouton%( MOUSEX , MOUSEY ) THEN
                   Clik_Boton(T_Bt2$): IF Boton%=1 THEN Bt%=0: EXIT ENDIF
              ENDIF
           ENDIF
           IF Bt%<>1 THEN
              N1%=N8%
              IF FN In_Bouton%( MOUSEX , MOUSEY ) THEN
                   Clik_Boton(T_Bt3$): IF Boton%=1 THEN Bt%=1: EXIT ENDIF
              ENDIF
           ENDIF
        ENDIF
     UNTIL 0
     WHILE MOUSEBUT <>0 WEND :Mous_Off
  RETURN

 'mouse sur zone d'un bouton
  DEF FN In_Bouton%(X_Mouse%,Y_Mouse%)
       IF X_Mouse%<N1%+1 THEN RETURN 0 ENDIF
       IF X_Mouse%>N1%+N3%-2 THEN RETURN 0 ENDIF
       IF Y_Mouse%<N2%+1 THEN RETURN 0 ENDIF
       IF Y_Mouse%>N2%+N4%-2 THEN RETURN 0 ENDIF
  RETURN -1

  DEF PROC Clik_Boton(Apl$)
     RESTORE Apl$: READ T1%,T2%,T$
     Boton%=0
     REPEAT
         IF MOUSEBUT THEN
         'Mouse appuyÇ
              IF FN In_Bouton%( MOUSEX , MOUSEY ) THEN
                 '-Sur le bouton
                  IF Boton%=0 THEN Boton%=1:Inverse_Video(1,3) ENDIF
              ELSE
                 '-Hors du bouton
                  IF Boton% THEN Inverse_Video(0,1):Boton%=0: EXIT ENDIF
              ENDIF
         ELSE
         'Sortie Mouse relachÇ :
             IF Boton% THEN
                 '-Sur le bouton
                  IF FN In_Bouton%( MOUSEX , MOUSEY ) THEN EXIT ENDIF
             ELSE
                 '-Hors du bouton afin de pouvoir gÇrer les trois boutons
                  Inverse_Video(0,1):Boton%=0: EXIT
             ENDIF
         ENDIF
     UNTIL 0
  RETURN
  DEF PROC Inverse_Video(Apl1%,Apl2%)
        Mous_Off
        N0%=Apl1%:Pp_Box: MODE =Apl2%: TEXT T1%,T2%,T$: MODE =1
        Boton%=Apl1%
        Mous_On
  RETURN
 '------------------------------------------------------------------------------
  DEF PROC Alert(Boutons%,Drapeau$,R R_Alert%)
    Alt$= MID$("F G",Langue%+1,1)
    R_Alert%=0: RESTORE Alt$+Drapeau$: READ Icn_Alert$,Txt_Alert$,Bt_Alert$
    Mous_On
    FORM_ALERT (Boutons%,"["+Icn_Alert$+"]["+Name_Prg$+" - OMIKRON v3 |"+Txt_Alert$+"][ "+Bt_Alert$+" ]",R_Alert%)
    WHILE MOUSEBUT <>0 WEND
  RETURN
 '------------------------------------------------------------------------------
  DEF PROC Wind_Update(X%L)
    Intin%(0)=X%L: AES (107,Global%(15),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(0))
  RETURN
  DEF PROC Graf_Mouse(Intin%(0)): AES (78,Global%(0),Intin%(1),Addrin%L(0),Intout%(1),Addrout%L(1)): RETURN
 'show 122, hide 123
  DEF PROC Mous_On:Ctrl%(0)=122:Ctrl%(1)=0:Ctrl%(3)=1:Ctrl%(6)=Vdi_Handle%:Intin%(0)=0: VDI (122,Ctrl%(0),Intin%(1),Ptsin%(0,0),Intout%(0),Ptsout%(0,0)): RETURN
  DEF PROC Mous_Off:Ctrl%(0)=123:Ctrl%(1)=0:Ctrl%(3)=1:Ctrl%(6)=Vdi_Handle%: VDI (123,Ctrl%(0),Intin%(0),Ptsin%(0,0),Intout%(0),Ptsout%(0,0)): RETURN

  DEF PROC Gabardage:Free_Memory%L= FRE(""): RETURN
  '
  '--------------------------------------------------------------------ERROR---
  DEF FN Test_Err%L(Apl%L,Apl1%L)
    IF Apl%L<>Apl1%L AND Apl1%L<0 THEN
      IF Apl1%L=-33 THEN Alert(1,"R2",Dummy%): RETURN -1 ENDIF 'file no found
      IF Apl1%L=-13 THEN Alert(1,"F0",Dummy%): RETURN -1 ENDIF 'disk write protected
          ERROR 57-Apl1%L*256'                                  other error
          RETURN -1'                                          >>> Trair_Err
    ELSE
          RETURN 0'.......................Correction error file save no found
    ENDIF
  RETURN 0'...inutile normalement, mais par sÇcuritÇ...
  '
  -Traite_Err
      Mous_Off:Graf_Mouse(0):Eror_File%=Tree_Box%
      IF ERR =62 THEN '                                         File no ASCII0
          Alert(1,"E0",Dummy%):Mous_Off
      ELSE
          '.......................................................for debug...
          Alert(1,"Z0",Dummy%):Mous_Off: IF Eror_File%=0 THEN RESUME NEXT ENDIF
      ENDIF
  RESUME No_Ascii

  -Fz0:-Gz0: DATA "3",Tiret$+ ERR$ +"|erreur :"+ STR$( ERR )+"|ligne  :"+ STR$( ERL ),"Ok"
  -Ginfo:-Finfo: DATA "0","-------------------------  | | ROCKYONE "+Version$+"|"," -Ok- "
  'selecteur
  -Ga3: DATA "1","-------------------------|The file can not be saved|in the file loaded."," - Return -"
  -Ga4: DATA "3"," |No space.|Free : "+Libre$+" bytes|Need : "+Besoin$+" bytes"," - Abort - "
  -Gf0: DATA "3","-------------------------|Not disk write access."," - Abort - "
  '-Gf1: DATA "2","-------------------------|File eror. The extension |should be : "+Ext$+" |"," -Ok- "
  'find
  -Gr2: DATA "3","-------------------------|No found : "+File$+"| "," Abort "
  -Gr3: DATA "3","-------------------------|File : "+File$+"|existing |","Overwrite| - Abort - "
  -Gs1: DATA "3","-------------------------|Name already used by| the disk or a folder.|"," - Return - "
  -Gs0: DATA "3","-------------------------|Fille error... |It is a folder or disk.|"," - Return - "
  -Ge0: DATA "3","-------------------------|"+Path$(2)+"| Is not a ASCII file"," - Abort - "
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  'selecteur
  -Fa3: DATA "1","-------------------------|Le fichier de destination|ne peut Çtre le fichier|source."," - Retour -"
  -Fa4: DATA "3"," |Place insufisante.|Libre  : "+Libre$+" octets|besoin : "+Besoin$+" octets"," - Abandon - "
  -Ff0: DATA "3","-------------------------|Accäs disque imposible|en Çcriture."," - Abandon - "
  '-Ff1: DATA "2","-------------------------|Erreur de fichier|L'extention doit etre : "+Ext$+" |"," -Ok- "
  'find
  -Fr2: DATA "3","-------------------------|Pas trouvÇ : "+File$+"|"," Abandon "
  -Fr3: DATA "3","-------------------------|Destination: "+File$+"|existant |","êcrasser|Abandon"
  -Fs1: DATA "3","-------------------------|Nom dÇjÖ utilisÇ par la|disquette ou par un dossier.|"," - Retour - "
  -Fs0: DATA "3","-------------------------|Erreur de fichier... |C'est un dossier ou|une disquette."," - Retour - "
  -Fe0: DATA "3","--------------------------|"+Path$(2)+"|N'est pas un fichier ASCII"," - Abandon - "
 '------------------------------------------------------------------------------
 '------------------------------------------------------------------------------
 'DATA pour les objet :  Fill Color, X, Y, W, L, Ffag=-1 pour Bouton
 'DATA pour texte     :  X, Y,"texte"
 '------------------------------------------------------------------------------
 '                              TREE
 '------------------------------------------------------------------------------
       -Tree: DATA 0,Mx%-107,My%-50,214,100,0
  -Box_Rouge: DATA High_Rez%+1,Mx%-104,My%-47,208,94,0
   -For_Info: DATA 0,Mx%-102,My%-43,204,13,0
              DATA 0,Mx%-100,My%-27,200,50,0
    '-Bt_Tree:
              DATA 0,Mx%-31,My%+29,62,13,-1
      '-Bt_Fr:
              DATA 0,Mx%-99,My%+29,62,13,-1
              DATA 0,Mx%+37,My%+29,62,13,-1
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 '                             TXT INFO GB
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  -Info_Gb: DATA Mx%-100,My%-34," Reduce file  OMIKRON v3 "
            DATA Mx%-96,My%-17," RÇmove blank lines and"
            DATA Mx%-96,My%-7," comments files saved   "
            DATA Mx%-96,My%+3," in ASCII               "
            DATA Mx%-96,Y_T3%," Also works in "+ MID$("ACCPRG",Accessory%*3+1,3)+ SPC(5)
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 '                             TXT INFO FR
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  -Info_Fr: DATA Mx%-100,My%-34,"RÇduit fichier OMIKRON v3"
            DATA Mx%-96,My%-17,"Ote les lignes vides   "
            DATA Mx%-96,My%-7,"et les commentaires des "
            DATA Mx%-96,My%+3,"fichiers sauvÇs en ASCII"
            DATA Mx%-96,Y_T3%,"Foncionne aussi en "+ MID$("ACCPRG",Accessory%*3+1,3)+ SPC(2)
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 '                             TXT BOUTON INFO
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    -Bt1: DATA Mx%-8,My%+38,"Ok"
    -Bt2: DATA Mx%-76,My%+38,"FR"
    -Bt3: DATA Mx%+60,My%+38,"GB"
 '------------------------------------------------------------------------------
 '                                  BOX LINE
 '------------------------------------------------------------------------------
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 '                              TXT LINE GB
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  -Line_Gb: DATA 22,"ASCII FILE TO CONVERT ASCII DESTINATION FILE"
            DATA "FILE ASCII "+ CHR$($BD)+" ROCKYONE"
            DATA "BT3_GB","BT4_GB","BT5_GB"
            DATA Mx%-(( LEN(Info_File$)*8)\2),My%-34,Info_File$
            DATA Mx%-60,My%-17,"Number of lines"
            DATA Mx%-55,My%-3,"Read"
            DATA Mx%-55,My%+7,"Saved"
            DATA Mx%-55,Y_T3%,"Deleted"
            DATA Mx%-56,My%+38,"Wait some time"
   -Bt3_Gb: DATA Mx%-4,My%+38,"?"
   -Bt4_Gb: DATA Mx%-84,My%+38,"Exit"
   -Bt5_Gb: DATA Mx%+50,My%+38,"Next"
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 '                            TXT LINE FR
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  -Line_Fr: DATA 28," FICHIER ASCII A CONVERTIR  FICHIER ASCII DE DESTINATION"
            DATA "FICHIER ASCII "+ CHR$($BD)+" ROCKYONE"

            DATA "BT3_FR","BT4_FR","BT5_FR"
            DATA Mx%-(( LEN(Info_File$)*8)\2),My%-34,Info_File$
            DATA Mx%-64,My%-17,"Nombre de lignes"
            DATA Mx%-56,My%-3,"Lue"
            DATA Mx%-56,My%+7,"SauvÇ"
            DATA Mx%-56,Y_T3%,"EffacÇ"
            DATA Mx%-36,My%+38,"Patientez"
   -Bt3_Fr: DATA Mx%-4,My%+38,"?"
   -Bt4_Fr: DATA Mx%-84,My%+38,"Quit"
   -Bt5_Fr: DATA Mx%+40,My%+38,"Suivant"
  ''''''''''''''''''''''''''''''''''''
   -End_File: DATA X_T%- LEN( STR$(Read_Line%-Rectif_Line%))*8,Y_T1%, STR$(Read_Line%-Rectif_Line%)
              DATA X_T%- LEN( STR$(Sav_Line%-Rectif_Line%))*8,Y_T2%, STR$(Sav_Line%-Rectif_Line%)
              DATA X_T%- LEN( STR$(Read_Line%-Sav_Line%))*8,Y_T3%, STR$(Read_Line%-Sav_Line%)
 '------------------------------------------------------------------------------
  'COMPILER OFF
  -Info_Acc
  DATA "EHf"'+"-"*34'
  DATA " "
  DATA "  "+Name_Prg$+" "+Version$
  DATA " -----------------------------"
  DATA " This accessory works"
  DATA " in three resolution"
  DATA " "
  DATA " rocky.one@hotmail.fr"
  DATA " --------------------      "
  'COMPILER ON
 '------------------------------------------------------------------------------
