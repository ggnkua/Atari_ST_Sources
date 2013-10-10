;
; Petit programme graphique de d‚monstration
; Assembleur          VDI_DEMO.ASM
;

gemdos         = 1
crawcin        = 7
print          = 9

               .INCLUDE 'GEM_INEX.ASM'

               .TEXT 

main:          jsr        gem_init      ;Annoncer l'AES et le VDI

               pea        clrscr        ;Effacer l'‚cran (VT-52)
               move.w     #print,-(sp)
               trap       #gemdos
               addq.l     #6,sp

; Tracer un rectangle

               move.w     #11,contrl    ;Rectangle angles arrondis  (v_rbox)
               move.w     #2,contrl+2   ;Nombre de coordonn‚es dans ptsin
               clr.w      contrl+4      ;Nombre de points ptsout
               move.w     #3,contrl+6   ;Longueur du tableau intin
               clr.w      contrl+8      ;Nombre des valeurs dans intout
               move.w     #8,contrl+10  ;Sous-num‚ro de la fonction
               move.w     handle,contrl+12        ;Handle graphique VDI

               move.w     #10,ptsin     ;Coordonn‚es du rectangle
               move.w     #10,ptsin+2
               move.w     x_max,d0      ;Toutes les coordonn‚es maximales
               subi.w     #10,d0        ;moins 10 (pour le point inf‚rieur
               move.w     d0,ptsin+4    ;droit)
               move.w     y_max,d0
               subi.w     #30,d0
               move.w     d0,ptsin+6

               jsr        vdi           ;Trac‚ du rectangle

; trac‚ de l'ellipse

               move.w     #11,contrl    ;Ellipse (v_ellipse)
               move.w     #2,contrl+2   ;Nombre de coordonn‚es dans ptsin
               clr.w      contrl+4      ;Nombre de points dans ptsout
               move.w     #3,contrl+6   ;Longueur du tableau intin
               clr.w      contrl+8      ;Nombre de valeurs dans intout
               move.w     #5,contrl+10  ;Sous-num‚ro de fonction
               move.w     handle,contrl+12        ;Handle graphique du VDI

               clr.l      d0            ;Calcul des coordonn‚es
               move.w     x_max,d0
               divu.w     #2,d0         ;divis‚ par 2 = centre de l'‚cran
               move.w     d0,ptsin

               subi.w     #10,d0        ;moins 10 donne x_max/2-10
               move.w     d0,ptsin+4    ;comme rayon x

               clr.l      d0
               move.w     y_max,d0
               divu.w     #2,d0
               subi.w     #10,d0
               move.w     d0,ptsin+2

               subi.w     #10,d0        ;y_max/2-20 comme rayon y
               move.w     d0,ptsin+6

               jsr        vdi           ;Trac‚ de l'ellipse

; Affichage du texte

               lea.l      affichage,a0
               bsr        fix_text      ;Stocker la chaŒne dans le tableau intin

               move.w     #8,contrl     ;Texte (v_gtext)
               move.w     #1,contrl+2   ;Nombre des coordonn‚es dans ptsin
               clr.w      contrl+4      ;Nombre de points dans ptsout
               clr.w      contrl+8      ;Nombre des valeurs dans intout
               move.w     handle,contrl+12        ;Handle graphique du VDI

               clr.l      d0            ;Calcul des coordonn‚es
               move.w     x_max,d0
               divu.w     #2,d0
               subi.w     #96,d0
               move.w     d0,ptsin

               move.w     y_max,d0
               subi.w     #10,d0
               move.w     d0,ptsin+2

               jsr        vdi

               move.w     #crawcin,-(sp)          ;Attendre touche
               trap       #gemdos
               addq.l     #2,sp

               jsr        gem_exit      ;D‚sactive l'AES et la VDI

               clr.w      -(sp)         ;Quitter le programme par la
               trap       #gemdos       ;fonction GEMDOS Pterm0


fix_text:      
; Sous-programme qui ‚crit une chaŒne dans le tableau intin,
; contr“le sa longueur et la stocke dans contrl[3]

               clr.w      d0            ;Longueur
               clr.w      d1            ;Registre d'aide
               lea.l      intin,a1

fix_loop:      move.b     (a0)+,d1      ;Aller chercher un octet de la chaŒne
               tst.b      d1            ;Fin de chaŒne?
               beq.s      fix_end
               move.w     d1,(a1)+      ;non, alors ‚crire le mot dans
               addq.w     #1,d0         ;le tableau intin
               bra.s      fix_loop

fix_end:       move.w     d0,contrl+6   ;D‚terminer la longueur
               rts        


               .DATA 

clrscr:        .DC.b 27,'E',0           ;S‚quence d'effacement d'‚cran

affichage:     .DC.b "Le graphisme VDI? C'est simple!",0

               .END 

