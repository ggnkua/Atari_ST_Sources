;
; Sprites
; Assembleur		SPRITES.S
;

gemdos         = 1
xbios          = 14
vsync          = 37


               INCLUDE 'GEM_INEX.S'

               SECTION TEXT 

main:          jsr        gem_init      ;Nous avons besoin du GEM pour un rectangle

               move.w     #123,contrl   ;v_hide_c, pointeur souris cach‚
               clr.w      contrl+2
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               jsr        vdi

               move.w     #3,contrl     ;VDI Clear Workstation
               clr.w      contrl+2      ;Efface l'‚cran
               clr.w      contrl+4      ;(voir chapitre 5)
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               jsr        vdi

               move.w     #23,contrl    ;vsf_interior (d‚finit motif de remplissage)
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     #1,intin      ;Remplir avec couleur du premier plan
               jsr        vdi

               move.w     #11,contrl    ;Rectangle coins arrondis, rempli
               move.w     #2,contrl+2   ;(v_rfbox)
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     #9,contrl+10
               move.w     handle,contrl+12
               move.w     #140,ptsin    ;Coordonn‚es
               move.w     #50,ptsin+2
               move.w     #500,ptsin+4
               move.w     #150,ptsin+6
               jsr        vdi

               move.w     #122,contrl   ;v_show_c, r‚afficher pointeur souris
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               move.w     #1,intin
               jsr        vdi

               moveq.l    #20,d5        ;Variable
               bra        entry

loop:          lea.l      save_area,a2
               DC.w $a00c              ;Undraw Sprite -> Effacer sprite

               cmpi.w     #620,d5       ;arriv‚ … droite?
               beq        fin
               addq.w     #1,d5         ;non, alors continuer

entry:         move.w     d5,d0         ;coordonn‚es x (abscisses)
               move.w     #100,d1       ;coordonn‚es y (ordonn‚es)
               lea.l      sprite,a0
               lea.l      save_area,a2
               DC.w $a00d              ;Draw Sprite

               move.w     #vsync,-(sp)  ;Attendre retour d'image
               trap       #xbios
               addq.l     #2,sp

               bra        loop

fin:           jsr        gem_exit

               clr.w      -(sp)
               trap       #gemdos


               SECTION DATA 

sprite:        DC.w 8,8  ;Point d'action
               DC.w 0    ;Format normal
               DC.w 0,1  ;Couleur d'arriŠre-plan/premier plan

               DC.w %1111111111111111,%0000000000000000
               DC.w %1111111111111111,%0111111111111110
               DC.w %1111111111111111,%0100100000010010
               DC.w %1111111111111111,%0100100000010010
               DC.w %1111111111111111,%0100100000010010
               DC.w %1111111111111111,%0100111111110010
               DC.w %1111111111111111,%0100000000000010
               DC.w %1111111111111111,%0100000000000010
               DC.w %1111111111111111,%0101111111111010
               DC.w %1111111111111111,%0101000000001010
               DC.w %1111111111111111,%0101010111001010
               DC.w %1111111111111111,%0111000000001010
               DC.w %1111111111111111,%0111001101001010
               DC.w %1111111111111111,%0101000000001010
               DC.w %1111111111111111,%0111111111111110
               DC.w %1111111111111111,%0000000000000000


               SECTION BSS 

save_area:     DS.w 32   ; De la place pour sauvegarder le fond

               END 
