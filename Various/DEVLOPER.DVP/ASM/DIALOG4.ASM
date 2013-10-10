;
; Affichage d'une boŒte de dialogue / Boutons Touchexit (UP/DOWN)
; Assembler              DIALOG4.ASM
;

gemdos         = 1

DIALOG         = 0        ;Constantes de DIALOG4.H2
ACTUEL         = 5
DOWN           = 7
UP             = 6
FINI           = 8

               .INCLUDE 'GEM_INEX.ASM'

               .TEXT 

main:          jsr        gem_init

; Pointeur souris : flŠche

               move.w     #78,control   ;graf_mouse
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0 pour flŠche
               jsr        aes

; rsrc_load:

               move.w     #110,control
               clr.w      control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #rscname,addr_in
               jsr        aes

               tst.w      int_out       ;Erreur?
               beq        rscerr

; rsrc_gaddr donne l'adresse de DIALOG

               move.w     #112,control
               move.w     #2,control+2
               move.w     #1,control+4
               clr.w      control+6
               move.w     #1,control+8
               clr.w      int_in        ;0 pour "recherche de l'arbre"
               move.w     #DIALOG,int_in+2        ;Index de l'arbre
               jsr        aes
               move.l     addr_out,arbre_adr      ;R‚sultat: l'adresse

; Initialisation du champ d'affichage (ACTUEL):

               lea.l      chifstr,a0    ;pointe au d‚part sur '0',0
               move.w     #ACTUEL,d0
               jsr        write_text

               jsr        show_dialog   ;Affichage de l'arbre

; form_do permet de modifier DIALOG:

loop:          move.w     #50,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;pas champ Edit
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w     int_out,bouton          ;Bouton actionn‚

               cmpi.w     #FINI,bouton
               beq        fine

               cmpi.w     #UP,bouton    ;Bouton 'UP' enfonc‚?
               bne        not_up
               addq.b     #1,chifstr    ;alors ajouter 1 … chiffre
               cmpi.b     #'9',chifstr  ;v‚rification de l'atteinte des limites
               ble.s      go_on         ;>9?
               move.b     #'0',chifstr  ;alors remplacer par un 0
               bra        go_on

not_up:        cmpi.w     #DOWN,bouton  ;ou 'DOWN'?
               bne        loop          ;non, alors continuer
               subq.b     #1,chifstr    ;moins 1
               cmpi.b     #'0',chifstr  ;<0?
               bge.s      go_on
               move.b     #'9',chifstr  ;alors ‚crire 9

go_on:         lea.l      chifstr,a0    ;"Entrer" chiffre dans masque
               move.w     #ACTUEL,d0
               jsr        write_text

; objc_draw dessine ACTUEL nouveau/pas de sous-objets (0)

               move.w     #42,control
               move.w     #6,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #ACTUEL,int_in          ;Le premier objet est un chiffre
               clr.w      int_in+2      ;Pas de sous-objets
               move.w     x,int_in+4
               move.w     y,int_in+6
               move.w     w,int_in+8
               move.w     h,int_in+10
               move.l     arbre_adr,addr_in
               jsr        aes

; evnt_timer attend 200 ms

               move.w     #24,control
               move.w     #2,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #200,int_in   ;Low-Word
               clr.w      int_in+2      ;et High-Word de 200
               jsr        aes

               bra        loop


fine:          jsr        deselect      ;Effacer l'‚tat Selected

               jsr        hide_dialog   ;Effacer la boŒte de dialogue

; rsrc_free:

               move.w     #111,control
               clr.w      control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               jsr        aes

quit:          jsr        gem_exit

               clr.w      -(sp)
               trap       #gemdos


rscerr:        lea.l      errtxt,a0
               jsr        form_alert    ;Affichage du message d'avertissement

               bra        quit


show_dialog:   
; Ce sous-programme dessine un arbre objet … l'‚cran.
; Son adresse doit se trouver … 'arbre_adr'

; Nouveaut‚: Les coordonn‚es devant ˆtre r‚utilis‚es dans le
; programme principal, elles sont stock‚es dans le segment BSS
; (et non plus dans les registres comme jusqu'ici)

; form_center

               move.w     #54,control
               clr.w      control+2
               move.w     #5,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w     int_out+2,x   ;Sauvegarder les coordonn‚es
               move.w     int_out+4,y
               move.w     int_out+6,w
               move.w     int_out+8,h

; form_dial sauvegarde les cadres des fenˆtres, etc. (0)

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               clr.w      int_in        ;Sous-fonction 0
; Pas de valeur pour le petit rectangle fo_dilittlx/y/w/h
               move.w     x,int_in+10   ;Grand rectangle do_dibigx/y/w/h          ;
               move.w     y,int_in+12
               move.w     w,int_in+14
               move.w     h,int_in+16
               jsr        aes

; form_dial dessine le rectangle zoom‚ (1):

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #1,int_in     ;Sous-fonction 1
               move.w     x,int_in+2    ;Taille du petit rectangle
               move.w     y,int_in+4
               move.w     #1,int_in+6
               move.w     #1,int_in+8
               move.w     x,int_in+10   ;Grand rectangle do_dibigx/y/w/h
               move.w     y,int_in+12
               move.w     w,int_in+14
               move.w     h,int_in+16
               jsr        aes

; Dessiner Dialog par objc_draw:

               move.w     #42,control
               move.w     #6,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0=Dessiner l'objet racine en premier
               move.w     #12,int_in+2  ;12 niveau maxi (arbitraire)
               move.w     x,int_in+4
               move.w     y,int_in+6
               move.w     w,int_in+8
               move.w     h,int_in+10
               move.l     arbre_adr,addr_in
               jmp        aes


hide_dialog:   
; Efface le formulaire de l'‚cran
; Adresse de l'arbre … nouveau dans arbre_adr

; form_dial dessine le rectangle qui disparaŒt (2):

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #2,int_in     ;Sous-fonction 2
               move.w     x,int_in+2    ;Taille du petit rectangle
               move.w     y,int_in+4
               move.w     #1,int_in+6
               move.w     #1,int_in+8
               move.w     x,int_in+10   ;Grand rectangle do_dibigx/y/w/h
               move.w     y,int_in+12
               move.w     w,int_in+14
               move.w     h,int_in+16
               jsr        aes

; form_dial envoie des messages Redraw … la fenˆtre (3)

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #3,int_in     ;Sous-fonction 3
; pas de valeur pour le petit rectangle fo_dilittlx/y/w/h
               move.w     x,int_in+10   ;Grand rectangle do_dibigx/y/w/h
               move.w     y,int_in+12
               move.w     w,int_in+14
               move.w     h,int_in+16
               jmp        aes


select:        
; Met le bouton "bouton" … l'‚tat "selected"
; L'arbre objet doit se trouver dans arbre_adr

               movea.l    arbre_adr,a0
               move.w     bouton,d0     ;Index de l'objet
               mulu.w     #24,d0        ;* 24 (chaque objet: 24 Bytes)
               ori.w      #1,10(a0,d0.w)          ;Mettre le bit 0 (selected) … 1
               rts        


deselect:      
; Met le bouton "bouton" … l'‚tat "deselected"
; L'arbre objet doit se trouver dans arbre_adr

               movea.l    arbre_adr,a0
               move.w     bouton,d0     ;Index de l'objet
               mulu.w     #24,d0        ;* 24 (chaque objet: 24 Bytes)
               andi.w     #-2,10(a0,d0.w)         ;Mettre le bit 0 (selected) … 0
               rts        


selected:      
; Le drapeau z‚ro est mis … 1 quand l'objet (Index dans d0)
; n'est pas s‚lectionn‚. Adresse de l'arbre dans arbre_adr.

               movea.l    arbre_adr,a0
               mulu.w     #24,d0        ;Index * 24 = Offset
               btst       #0,11(a0,d0.w)          ;btst teste l'octet!!!, donc 11
               rts        


form_alert:    
; Affiche la boŒte d'alerte. La chaŒne se trouve … partir de a0.
; Le bouton num‚ro 1 est le bouton par d‚faut.

               move.w     #52,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #1,int_in     ;Bouton par d‚faut
               move.l     a0,addr_in
               jmp        aes


write_text:    
; crit la chaŒne dans l'objet Text ou Edit (Index dans d0)
; ChaŒne dans a0, arbre objet dans arbre_adr

               movea.l    arbre_adr,a1
               mulu.w     #24,d0
               movea.l    12(a1,d0.w),a1          ;Adresse du bloc TEDINFO
               movea.l    (a1),a1       ;te_ptext contient le texte

wrt_lp:        move.b     (a0)+,(a1)+
               bne.s      wrt_lp
               rts        


read_text:     
; Le pendant de write_text. L'adresse de
; destination doit ˆtre pass‚e dans a0

               movea.l    arbre_adr,a1
               mulu.w     #24,d0
               movea.l    12(a1,d0.w),a1
               movea.l    (a1),a1

rd_lp:         move.b     (a1)+,(a0)+
               bne.s      rd_lp
               rts        


               .DATA 

chifstr:       .DC.b '0',0
rscname:       .DC.b 'DIALOG4.RSC',0
errtxt:        .DC.b '[3][Pas de fichier RSC!][Fin]',0

               .BSS 

x:             .DS.w 1    ;Coordonn‚es de la boŒte de dialogue
y:             .DS.w 1
w:             .DS.w 1
h:             .DS.w 1

arbre_adr:     .DS.l 1
bouton:        .DS.w 1

               .END 
