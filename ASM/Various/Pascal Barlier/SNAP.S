;
;
;                   CAPTURE D'IMAGES TOUTES RESOLUTIONS ST
;
;         (c) 1992 Pascal Barlier & Artipresse

          .PATH 'D:\GFA68000\INCLUDE\'  ; Localisation du fichier...
          .INCLUDE 'ATARI.IS'           ; ... ATARI.IS

          .TEXT 

          Supexec   #install            ; Sous-routine en  superviseur
          Dgetdrv   ; Num‚ro du disque courant...
          add.b     d0,nom              ; pour la sauvegarde des images

          Cconws    #texte              ; Texte d'installation

          Ptermres  #1024,#0            ; Programme r‚sident
install:  
          move.l    #snap,d0            ; Adresse du snap dans le...
          move.l    d0,$502             ; ... vecteur de copie d'‚cran
          rts       

snap:     
          Getrez    ; R‚solution courante
          move.w    d0,reso
          addi.b    #"1",d0
          move.b    d0,nom+12           ; Change l'extension du fichier
          lea.l     pal,a3
          clr.w     d3
.bcl3:    
          Setcolor  d3,#-1              ; R‚cupŠre la palette
          move.w    d0,(a3)+
          addq.w    #1,d3
          cmpi.w    #16,d3
          bne       .bcl3
          Physbase  ; Adresse de l'‚cran
          move.l    d0,d3

          Fcreate   #nom,#0             ; Cr‚ation de fichier
          move.w    d0,d6
          bmi       .fin                ; Erreur en cr‚ation
          Fwrite    d6,#34,#reso        ; En-tˆte+palette
          Fwrite    d6,#32000,d3        ; Image
          Fwrite    d6,#32,#effet       ; Cyclage des couleurs
          Fclose    d6                  ; Fremeture du fichier
.fin:     
          addq.b    #1,nom+8            ; Change le nom pour la...
          rts                           ; ... Prochaine capture d'‚cran


          .DATA 
;         Infos de cyclage des couleurs
effet:    .DC.w 0,4,8,$c,3,7,$b,$f,1,1,1,1,$80,$54,$2a,0

nom:      .DC.b "A:\SNAP_A.PI1",0

texte:    .DC.b "SNAP Install‚",13,10
          .DC.b "(c) 1992 P.Barlier & Artipresse ",13,10,0

          .BSS 

reso:     .DS.w 1   ; En-tˆte en r‚solution
pal:      .DS.w 16  ; Palette de couleurs

          .END 


