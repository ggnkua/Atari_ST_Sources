; Fichier: auto.asm
;
; course de voiture programme auxiliaire en Assembleur
          .INCLUDE 'ATARI.IS'

touchegauche        equ "7"
touchedroite        equ "9"
touchestop          equ "8"

largeurauto         equ 14
autohauteur         equ 12

scroll:   movem.l   d1-d4/a0/a1/a6,-(sp)          ;sauvegarde des registres CPU utilis‚s

label:    lea.l     label(pc),a6        ; toutes les adresses du programme sont  adress‚es
          .BASE 6,label                 ; en fonction du Label, l'Assembleur GfA proc‚dera automatiquement … la conversion


          move.l    screen,d0           ;l'‚tat de l'‚cran est-il d‚j… d‚fini

          bpl       .redraw             ; si oui, passer au d‚filement etc.
.firsttime:         Physbase            ; premier appel,o— en est l'‚cran

          move.l    d0,screen           ; … noter pour plus tard
          move.w    7*4+4(sp),d0        ; reprendre les paramŠtres
          move.w    d0,pos              ; d‚terminer la position de d‚part
          bsr       drawauto            ; puis dessiner la voiture
          bra       done                ; et termin‚!
.redraw:  Vsync     ; pour attendre le retour vertical de l'image
          move.w    pos,d0              ; effacer le dessin de la voiture
          bsr       drawauto
          movea.l   screen,a1
; transf‚rer l'adresse de d‚but d'‚cran dans a1
          move.w    7*4+4(sp),d0
; reprendre le paramŠtre nombre de lignes
          mulu.w    #80,d0
; le transformer en octets (lignes*80)
          lea.l     0(a1,d0.w),a0       ; charger a1+d0 dans a0
          neg.l     d0                  ; -d0+32000 pour avoir la longueur du bloc
          addi.l    #32000,d0
          bsr       qcopy               ; pour appeler le sous-programme qcopy
          Crawio    #$000000ff
; contr“le du clavier, code ASCII envoy‚ dans d0.b
          move.w    vx,d1               ; pr‚parer la vitesse horizontale
          move.w    pos,d2              ; et la position dans les registres
          cmpi.b    #touchegauche,d0
; acc‚l‚ration vers la gauche?
          bne       .tstdroite          ; non
          subq.w    #1,d1               ; si oui: vx := vx-1
          bra       .termine            ; et exploiter l'appui touche
.tstdroite:         cmpi.b              #touchedroite,d0
; si rien … gauche, v‚rif … droite
          bne       .tststop            ; v‚rif aussi touche stop
          addq.w    #1,d1               ; si oui: vx :=vx+1
          bra       .termine            ; et exploiter l'appui touche
.tststop: cmpi.b    #touchestop,d0      ; appui touche stop?
          bne       .termine            ; non, alors termin‚
          moveq.l   #0,d1               ; si oui, vx:=0
.termine: add.w     d1,d2               ; position = position + vitesse
          bpl       .tstborddroit
; >=0 donc n'est pas sorti de la route par la gauche
          moveq.l   #0,d1
; <0 : remettre … la position sur bord gauche et
          moveq.l   #0,d2               ; … la vitesse 0
          bra       savnpos             ; noter la nouvelle position

.tstborddroit:      cmpi.w              #640-largeurauto,d2
; largeur auto >=640
          bcs       savnpos             ; si non, position correcte
          move.w    #640-largeurauto,d2
; si oui, remettre … la position sur bord droit
          moveq.l   #0,d1               ; et … la vitesse 0
savnpos:  move.w    d1,vx               ; noter la nouvelle position et
          move.w    d2,pos              ; la nouvelle vitesse
          Vsync     ; attendre de nouveau qu'ait eu lieu le
; retour vertical de l'image ¨Instruction incomplŠte
          move.w    d2,d0
; et dessiner la voiture … sa nouvelle position
          bsr       drawauto            ; une ‚ventuelle collision si d0<>0
done:     movem.l   (sp)+,d1-d4/a1/a2/a6          ; restaurer les registres
          rts                           ; d0 contient le r‚sultat

;=======================================================
; drawauto
;=========
;
; entr‚e: d0 -- position ligne de la voiture, en pixels
; sortie: d0 -- <>0 lorsque la voiture sort de la route
;
; registres modifi‚s: 01234567
; D:-------
; A--------
;
; la route correspond … Memecran Bit = 1
; les foss‚s et les obstacles … Memecran Bit = 0
;
drawauto: movem.l   d1-d4/a0/a1,-(sp)
          moveq.l   #15,d1              ; d‚calage
          and.w     d0,d1
          lsr.w     #4,d0               ; word offset
          add.w     d0,d0
          movea.l   screen,a1           ; pointeur sur le premier mot sous la voiture
          lea.l     30*80(a1),a1
          adda.w    d0,a1
          lea.l     auto,a0             ; pointeur sur le tableau voiture
          moveq.l   #autohauteur-1,d2   ; compteur de lignes
          moveq.l   #0,d3               ; effacer les flags de collision
.autoloop:          moveq.l             #0,d4     ; effacer le mot long
          move.w    (a0)+,d4            ; et inscrire le masque de la voiture dans le mot faible
          ror.l     d1,d4               ; d‚caler le masque de la voiture
          move.w    (a1),d0             ; mot … gauche, sous la voiture
          not.w     d0                  ; contr“le si collision
          and.w     d4,d0
          or.w      d0,d3               ; noter toutes les collisions
          eor.w     d4,(a1)+            ; ramener/effacer voiture sur la route
          swap.w    d4                  ; mˆme chose pour le deuxiŠme mot
          move.w    (a1),d0
          not.w     d0
          and.w     d4,d0
          or.w      d0,d3
          eor.w     d4,(a1)
          lea.l     78(a1),a1
          dbf       d2,.autoloop
          move.l    d3,d0               ; copier le statut collision dans d0
          movem.l   (sp)+,d1-d4/a0/a1   ; puis revenir
          rts       

pos:      .DC.w 0   ; position de d‚part de la voiture
vx:       .DC.w 0   ; vitesse de d‚part
screen:   .DC.l -1  ; m‚moire adresse de d‚but de l'‚cran

auto:     .DC.w %1111000000111100       ; voiture: largeur maxi 16
          .DC.w %1111111111111100       ; hauteur maxi … s‚lectionner
          .DC.w %1111111111111100       ; constantes
          .DC.w %0001111111110000       ; il convient d'adapter la largeur et
          .DC.w %0001111111110000       ; la hauteur de la voiture
          .DC.w %0000111111100000
          .DC.w %0000011111000000
          .DC.w %0000001110000000
          .DC.w %0000011111000000
          .DC.w %0000011111000000
          .DC.w %0000001110000000
          .DC.w %0000000100000000


;
;===================================================================
; qcopy : copie rapide d'un bloc de m‚moire
;==========================================
; Entr‚e de donn‚es:
; a0: adresse du bloc source
; a1: adresse du bloc cible
; d0: longueur du bloc en octets (0 <= longueur <= 3.145.727)
; pas de test pour v‚rifier si la longueur de d0 est correcte
; Sortie de donn‚es:
; a0,a1 : pointent sur l'octet se trouvant derriŠre le bloc correspondant
; registres modifi‚s: 01234567
; D:--------
; A:--------
qcopy:    movem.l   d1-d7/a2-a6,-(sp)   ; sauver registre
          move.w    a0,d1               ; contr“le de la position des blocs
          move.w    a1,d2               ; position diff‚rente ==> copy octets
          andi.w    #1,d1               ; tous deux impairs ==> un octet, puis comme si impair
          andi.w    #1,d2               ; tous deux pairs => copier par blocs
          eor.w     d1,d2
          bne       .copybytes
          tst.w     d1
          beq       .copyeven
.copyodd: move.b    (a0)+,(a1)+         ; adresse impaire : copier un octet
          subq.w    #1,d0               ; adapter le compteur
          beq       .done               ; et contr“ler si fin
.copyeven:          divu.w              #12*4,d0  ; adresse paire: copier des blocs … 48 octets
          bra       .vlcpy              ; boucle manquante
.vlloop:  movem.l   (a0)+,d1-d7/a2-a6   ; la boucle transmet 48 octets … chaque parcours
          movem.l   d1-d7/a2-a6,(a1)    ; simulation d'‚criture avec
          lea.l     12*4(a1),a1         ; postindexation
.vlcpy:   dbf       d0,.vlloop
          swap.w    d0                  ; prendre en compte le reste de la division
          ext.l     d0                  ; ‚tendre … tout le registre
          ror.l     #2,d0               ; division par 4, reste dans les
;bits 30,31
          bra       .lcpy               ; boucle manquante
.lloop:   move.l    (a0)+,(a1)+         ; compteur div 4 copier mots longs
.lcpy:    dbf       d0,.lloop
.word:    lsl.l     #1,d0               ; reste-t-il un mot?
          bcc       .byte               ; si non, alors ‚ventuellemt 'byte'
          move.w    (a0)+,(a1)+         ; si oui, copier mot
.byte:    tst.l     d0                  ; reste-t-il un octet?
          bpl       .done               ; si non: termin‚
          move.b    (a0)+,(a1)+         ; si oui: le copier
          bra       .done
;
; si l'ordonnancement des blocs diffŠre, on utilise les accŠs par octet
; pas la peine d'optimiser, car cas trŠs rare
;
.copybytes:         
          bra       .btst               ; d‚placer le bloc m‚moire octet par octet,
.bloop:   move.b    (a0)+,(a1)+         ; faute de quoi: erreur d'adresse
.btst:    dbf       d0,.bloop           ; ici: boucle mot de faible valeur
          swap.w    d0                  ; examiner la partie de valeur sup‚rieure
          subq.w    #1,d0               ; diminuer
          bcs       .done               ; inf‚rieur … z‚ro, donc termin‚
          swap.w    d0                  ; sinon: re-ranger correctement
          bra       .bloop              ; et r‚p‚ter la boucle int‚rieure
.done:    movem.l   (sp)+,d1-d7/a2-a6   ; termin‚
          rts                           ; retour au programme

          .END 
