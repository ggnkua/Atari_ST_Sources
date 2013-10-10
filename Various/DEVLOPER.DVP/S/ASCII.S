;
; Accessoire affichant la police de caractŠres (Table ASCII)
; Assembleur		ASCII.S
;

gemdos         = 1
crawcin        = 7


	       INCLUDE 'ACC_INIT.S'

               SECTION TEXT 

main:          jsr        gem_init

; menu_register:

               move.w     #35,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     ap_id,int_in
               move.l     #acc_name,addr_in
               jsr        aes
               move.w     int_out,ac_id ;Stocker l'ID de l'accessoire

; Boucle sans fin evnt_mesag:

mainloop:      move.w     #23,control   ;Opcode evnt_mesag
               clr.w      contrl+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #tampon,addr_in
               jsr        aes

; Examiner le message: est-il adress‚ … nous?

               cmpi.w     #40,tampon    ;Signe de reconnaissance: accessoire appel‚
               bne        mainloop

               move.w     tampon+8,d0   ;ac_id du programme demand‚
               cmp.w      ac_id,d0      ;C'est nous?
               bne        mainloop

               jsr        accessory     ;Alors c'est parti!
               bra        mainloop


; ***** Voici la routine proprement dite: *****


accessory:     

               move.w     #51,control   ;form_dial (AES)
               move.w     #9,control+2  ;AES doit sauvegarder les cadres des fenˆtres
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               clr.w      int_in        ;Num‚ro de sous-fonction 0
               move.w     #11,int_in+10 ;x,
               move.w     #31,int_in+12 ;y,
               move.w     #617,int_in+14          ;Largeur (x2-x1+1) et
               move.w     #345,int_in+16          ;hauteur (y2-y1+1)
               jsr        aes


; Cacher le pointeur souris:

               move.w     #123,contrl   ;v_hide_c
               clr.w      contrl+2
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               jsr        vdi

; Effacer la zone d'affichage:

               move.w     #23,contrl    ;vsf_interior
               clr.w      contrl+2      ;(s‚lectionne type de remplissage)
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               clr.w      intin         ;Remplir avec couleur de fond
               jsr        vdi

               move.w     #104,contrl   ;vsf_perimeter
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               clr.w      intin         ;Cadre d‚sactiv‚ pendant remplissage
               jsr        vdi

               move.w     #11,contrl    ;v_bar
               move.w     #2,contrl+2
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8
               move.w     #1,contrl+10  ;Num‚ro de sous-fonction
               move.w     handle,contrl+12
               move.w     #11,ptsin     ;Coordonn‚es
               move.w     #31,ptsin+2
               move.w     #627,ptsin+4
               move.w     #375,ptsin+6
               jsr        vdi


; Dessiner les petites boŒtes:

               clr.w      d6
               clr.w      d7

r_loop:        move.w     #6,contrl     ;v_pline
               move.w     #2,contrl+2   ;Relie 2 points
               clr.w      contrl+4
               clr.w      contrl+6
	       clr.w	  contrl+8
	       move.w     #15,ptsin     ;Coordonn‚e x du point 1
               move.w     #35,ptsin+2   ;Coordonn‚e y du point 1
               add.w      d6,ptsin+2
               move.w     #623,ptsin+4  ;Coordonn‚e x du point 2
               move.w     ptsin+2,ptsin+6         ;Coordonn‚e y du point 2

               jsr        vdi

               move.w     #6,contrl     ;v_pline
               move.w     #2,contrl+2   ;Relier 2 points
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8

               move.w     #15,ptsin     ;Coordonn‚e x du point 1
               add.w      d7,ptsin
               move.w     #35,ptsin+2   ;Coordonn‚e y du point 1
               move.w     ptsin,ptsin+4 ;Coordonn‚e x du point 2
               move.w     #371,ptsin+6

               jsr        vdi

               addi.w     #21,d6
               addi.w     #38,d7

               cmpi.w     #357,d6       ;Valeur finale
               bne        r_loop

; Tracer cadre comme dans boŒte de dialogue:

               move.w     #6,contrl     ;v_pline
               move.w     #5,contrl+2   ;Relier 5 points
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8

               move.w     #14,ptsin
               move.w     #34,ptsin+2
               move.w     #624,ptsin+4
               move.w     #34,ptsin+6
               move.w     #624,ptsin+8
               move.w     #372,ptsin+10
               move.w     #14,ptsin+12
               move.w     #372,ptsin+14
               move.w     #14,ptsin+16
               move.w     #34,ptsin+18

               jsr        vdi

               move.w     #6,contrl     ;v_pline
               move.w     #5,contrl+2   ;Relier 5 points
               clr.w      contrl+4
               clr.w      contrl+6
               clr.w      contrl+8

               move.w     #11,ptsin
               move.w     #31,ptsin+2
               move.w     #627,ptsin+4
               move.w     #31,ptsin+6
               move.w     #627,ptsin+8
               move.w     #375,ptsin+10
               move.w     #11,ptsin+12
               move.w     #375,ptsin+14
               move.w     #11,ptsin+16
               move.w     #31,ptsin+18

               jsr        vdi


; Affichage de la table: CaractŠres + code ASCII (d‚cimal et hexad‚cimal)

               move.b     #'$',hex      ;CaractŠre dollar ($) dans chaŒne hexa

               clr.w      d5            ;CaractŠre suivant … afficher
               clr.w      d7            ;Ligne
loop1:         clr.w      d6            ;Colonne

; Affichage du caractŠre:

loop2:         lea.l      digits,a0     ;crire code ASCII en chiffres

               move.w     d5,d4         ;Conversion en hexad‚cimal
               andi.w     #%1111,d4
               move.b     0(a0,d4.w),hex+2        ;Affichage des unit‚s
               move.w     d5,d4
               asr.w      #4,d4
               move.b     0(a0,d4.w),hex+1        ;Affichage des chiffres > 10

               move.w     d5,d4         ;Conversion en d‚cimal
               andi.l     #$ffff,d4     ;Effacer le mot sup‚rieur
               divu.w     #10,d4        ;/ base du systŠme num‚rique
               swap.w     d4            ;Reste dans mot inf‚rieur
               move.b     0(a0,d4.w),dec+2        ;Unit‚s
               swap.w     d4            ;Traiter le r‚sultat
               andi.l     #$ffff,d4     ;Effacer le mot sup‚rieur
               divu.w     #10,d4
               move.b     0(a0,d4.w),dec          ;Le r‚sultat est le chiffre des centaines
               swap.w     d4
               move.b     0(a0,d4.w),dec+1        ;Le reste est un chiffre des dizaines

               cmpi.b     #'0',dec      ;Effacer les premiers z‚ros
               bne.s      l
               move.b     #' ',dec      ;Espace
               cmpi.b     #'0',dec+1
               bne.s      l
               move.b     #' ',dec+1


l:             move.w     #107,contrl   ;S‚lectionner caractŠres 8x16
               clr.w      contrl+2      ;vst_point
               move.w     #2,contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               move.w     #13,intin     ;Corps 13
               jsr        vdi

               move.w     #8,contrl     ;v_gtext
               move.w     #1,contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6   ;Afficher 1 caractŠre
               clr.w      contrl+8
               move.w     handle,contrl+12
               move.w     d5,intin      ;CaractŠre
               move.w     #43,ptsin     ;Coordonn‚e en x
               add.w      d6,ptsin
               move.w     #52,ptsin+2   ;Coordonn‚e en y
               add.w      d7,ptsin+2
               jsr        vdi

               move.w     #107,contrl   ;S‚lectionner caractŠres 6x6
               clr.w      contrl+2      ;vst_point
               move.w     #2,contrl+4
               move.w     #1,contrl+6
               move.w     #1,contrl+8
               move.w     handle,contrl+12
               move.w     #4,intin      ;Corps 13
               jsr        vdi

               move.w     #8,contrl     ;v_gtext (affichage d‚cimal)
               move.w     #1,contrl+2
               clr.w      contrl+4
               move.w     #3,contrl+6   ;Afficher 3 caractŠres
               clr.w      contrl+8
               move.w     handle,contrl+12

               clr.b      intin         ;CaractŠre
               move.b     dec,intin+1
               clr.b      intin+2
               move.b     dec+1,intin+3
               clr.b      intin+4
               move.b     dec+2,intin+5

               move.w     #19,ptsin     ;Coordonn‚e x
               add.w      d6,ptsin
               move.w     #42,ptsin+2   ;Coordonn‚e y
               add.w      d7,ptsin+2
               jsr        vdi

               move.w     #8,contrl     ;v_gtext (Affichage hexad‚cimal)
               move.w     #1,contrl+2
               clr.w      contrl+4
               move.w     #3,contrl+6   ;Afficher 3 caractŠres
               clr.w      contrl+8
               move.w     handle,contrl+12

               clr.b      intin         ;CaractŠre
               move.b     hex,intin+1
               clr.b      intin+2
               move.b     hex+1,intin+3
               clr.b      intin+4
               move.b     hex+2,intin+5

               move.w     #19,ptsin     ;Coordonn‚e x
               add.w      d6,ptsin
               move.w     #53,ptsin+2   ;Coordonn‚e y
               add.w      d7,ptsin+2
               jsr        vdi

               addq.w     #1,d5         ;CaractŠre suivant

               addi.w     #38,d6
               cmpi.w     #608,d6       ;Ligne termin‚e?
               bne        loop2

               addi.w     #21,d7        ;oui, alors ligne suivante
               cmpi.w     #336,d7
               bne        loop1


; D‚sactiver … nouveau le pointeur souris:

               move.w     #122,contrl
               clr.w      contrl+2
               clr.w      contrl+4
               move.w     #1,contrl+6
               clr.w      contrl+8
               move.w     handle,contrl+12
               move.w     #1,intin
               jsr        vdi

; Attendre appui touche:

; Remarque:
;   J'avais l'intention d'utiliser evnt_multi et d'attendre l'appui
;   d'une touche ou un clic souris. Cela est impossible parce que GEM
;   ne transmet ces ‚vŠnements que lorsque nous avons la fenˆtre active.
;   Notre programme n'ayant aucune fenˆtre, nous n'avons pas de fenˆtre
;   active. C'est pourquoi vous trouvez un simple appel GEMDOS:

               move.w     #crawcin,-(sp)
               trap       #gemdos
               addq.l     #2,sp

; Laissons au GEM le soin de retracer l'‚cran:

               move.w     #51,control   ;form_dial
               move.w     #9,control+2  ;L'AES doit donner des messages Redraw
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #3,int_in     ;Num‚ro de sous-fonction
               move.w     #11,int_in+10 ;x,
               move.w     #31,int_in+12 ;y,
               move.w     #617,int_in+14          ;Largeur (x2-x1+1) et
               move.w     #345,int_in+16          ;Hauteur (y2-y1+1)
               jsr        aes

               rts                      ;Fin de l'accessoire


               SECTION DATA 

digits:        DC.b '0123456789ABCDEF'
acc_name:      DC.b '  ASCII-Codes',0


               SECTION BSS 

dec:           DS.b 3    ;Les chiffres sont pr‚par‚s ici en vue de l'affichage
hex:           DS.b 3

tampon:        DS.w 8
ac_id:         DS.w 1    ;Accessory-ID

               END 
