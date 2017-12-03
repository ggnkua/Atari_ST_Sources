;
; Programme d‚mo pour Copy Raster, Opaque
; Assembler      COPYTRAM.ASM
;

               .INCLUDE 'GEM_INEX.ASM'

gemdos         = 1
crawcin        = 7

               .TEXT 

main:          jsr        gem_init

; Afficher texte

               lea.l      affichage,a0
               bsr        fix_text      ;Stocker chaŒne dans le tableau intin

               move.w     #8,contrl     ;Text (v_gtext)
               move.w     #1,contrl+2   ;Nombre de coordonn‚es dans ptsin
               clr.w      contrl+4      ;Nombre de points dans ptsout
               clr.w      contrl+8      ;Nombre des valeurs dans intout
               move.w     handle,contrl+12        ;Handle graphique VDI

               move.w     #20,ptsin     ;Coordonn‚es
               move.w     #50,ptsin+2

               jsr        vdi

; Premier appel de Copy Raster (Mode 3 => Remplace)

               move.w     #109,contrl   ;Opcode de fonction
               move.w     #4,contrl+2   ;4 coordonn‚es dans ptsin
               clr.w      contrl+4
               move.w     #1,contrl+6   ;Une valeur dans intin
               clr.w      contrl+8
               move.w     handle,contrl+12

               move.l     #null,contrl+14         ;Pointeur sur z‚ro (MFDB)
               move.l     #null,contrl+18         ;v. ci-dessus, mais pour la cible

               move.w     #20,ptsin     ;Coordonn‚es de la trame source
               move.w     #36,ptsin+2
               move.w     #204,ptsin+4
               move.w     #52,ptsin+6

               move.w     #20,ptsin+8   ;Coordonn‚es de la trame cible
               move.w     #65,ptsin+10
               move.w     #204,ptsin+12
               move.w     #81,ptsin+14

               move.w     #3,intin      ;Mode 3: Remplace

               jsr        vdi

; les coordonn‚es et le mode doivent
; ˆtre modifi‚s pour le 2Šme appel,

               move.w     #90,ptsin+10
               move.w     #106,ptsin+14
               move.w     #7,intin

               jsr        vdi

               move.w     #crawcin,-(sp)          ;Attendre touche
               trap       #gemdos
               addq.l     #2,sp

               jsr        gem_exit

               clr.w      -(sp)
               trap       #gemdos


fix_text:      
; Sous-programme qui ‚crit une chaŒne (passer son adresse
; dans a0) dans le tableau intin, d‚termine sa longueur
; et la stocke dans contrl[3]

               clr.w      d0            ;Longueur
               clr.w      d1            ;Registre d'aide
               lea.l      intin,a1

fix_loop:      move.b     (a0)+,d1      ;Lire un octet de la chaŒne cible
               tst.b      d1            ;Fin de chaŒne?
               beq.s      fix_end
               move.w     d1,(a1)+      ;non, alors ‚crire comme mot
               addq.w     #1,d0         ;dans le tableau intin
               bra.s      fix_loop

fix_end:       move.w     d0,contrl+6   ;
               rts        


               .DATA 

null:          .DC.l 0    ;Devient notre MFDB (0 pour l'‚cran)

affichage:     .DC.b 'Salut, voici le texte',0

               .END 
