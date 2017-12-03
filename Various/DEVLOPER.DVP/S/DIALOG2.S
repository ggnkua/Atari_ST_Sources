;
; Chargement, affichage et modification des Edits de premiäre boåte de dialogue
; Assembleur		DIALOG2.S
;

gemdos         = 1

DIALOG         = 0        ;Constantes venant de DIALOG2.H2
ENTREE         = 3
AFFICHAGE      = 5
OK             = 6
FIN            = 7


               INCLUDE 'GEM_INEX.S'

               SECTION TEXT 

main:          jsr        gem_init

; Pointeur souris: fläche:

               move.w     #78,control   ;graf_mouse
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0 pour fläche
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

; rsrc_gaddr transmet l'adresse de Dialog:

               move.w     #112,control
               move.w     #2,control+2
               move.w     #1,control+4
               clr.w      control+6
               move.w     #1,control+8
               clr.w      int_in        ;0 pour 'Recherche l'arbre'
               move.w     #DIALOG,int_in+2        ;Index de l'arbre
               jsr        aes
               move.l     addr_out,arbre_adr      ;RÇsultat: l'adresse

; Initialiser le champ d'affichage:

               lea.l      inittxt,a0    ;texte dÇbut
               move.w     #AFFICHAGE,d0 ;Index du champ de texte
               jsr        write_text

loop:          
; Effacement du champ de sasie:

               lea.l      empty,a0      ;Chaåne vide
               move.w     #ENTREE,d0    ;Index du champ Edit
               jsr        write_text

               jsr        show_dialog   ;Affichage de l'arbre

; form_do permet l'interaction Dialog - utilisateur

               move.w     #50,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #ENTREE,int_in          ;Champ Edit
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w     int_out,bouton          ;Bouton enfoncÇ

               jsr        deselect      ;Effacer l'Çtat Selected

               jsr        hide_dialog   ;Efface Dialogbox

; Copier la entrÇe dans le champ d'entrÇe:

               lea.l      str,a0
               move.w     #ENTREE,d0
               jsr        read_text

               lea.l      str,a0
               move.w     #AFFICHAGE,d0
               jsr        write_text

; Fin du programme si Fin a ÇtÇ appuyÇ

               cmpi.w     #FIN,bouton
               bne        loop

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
; Ce sous-programme dessine un arbre objet Ö l'Çcran.
; Son adresse doit se trouver Ö 'arbre_adr'

; form_center

               move.w     #54,control
               clr.w      control+2
               move.w     #5,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w	  int_out+2,d4  ;Sauvegarde des coordonnÇes
               move.w     int_out+4,d5
               move.w     int_out+6,d6
               move.w     int_out+8,d7

; form_dial sauvegarde les cadres des fenàtres, etc. (0)

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               clr.w      int_in        ;Sous-fonction 0
; Pas de valeur pour le petit rectangle fo_dilittlx/y/w/h
               move.w     d4,int_in+10  ;Grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jsr        aes

; form_dial dessine le rectangle zoomÇ (1):

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #1,int_in     ;Sous-fonction 1
               move.w     d4,int_in+2   ;Taille du petit rectangle
               move.w     d5,int_in+4
               move.w     #1,int_in+6
               move.w     #1,int_in+8
               move.w     d4,int_in+10  ;Grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jsr        aes

; Dessiner Dialog avec objc_draw:

               move.w     #42,control
               move.w     #6,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0=Dessiner l'objet racine en premier
               move.w     #12,int_in+2  ;12 niveau maxi (valeur arbitraire)
               move.w     d4,int_in+4
               move.w     d5,int_in+6
               move.w     d6,int_in+8
               move.w     d7,int_in+10
               move.l     arbre_adr,addr_in
               jmp        aes


hide_dialog:   
; Efface le masque de l'Çcran
; Adresse de l'arbre Ö nouveau dans arbre_adr

; form_center

               move.w     #54,control
               clr.w      control+2
               move.w     #5,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w     int_out+2,d4  ;Sauvegarde des coordonnÇes
               move.w     int_out+4,d5
               move.w     int_out+6,d6
               move.w     int_out+8,d7

; form_dial dessine le rectangle qui disparaåt (2):

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #2,int_in     ;Sous-fonction 2
               move.w     d4,int_in+2   ;Taille du petit rectangle
               move.w     d5,int_in+4
               move.w     #1,int_in+6
               move.w     #1,int_in+8
               move.w     d4,int_in+10  ;Grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jsr        aes

; form_dial envoie des messages Redraw Ö la fenàtre (3)

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #3,int_in     ;Sous-fonction 3
; pas de valeur pour le petit rectangle fo_dilittlx/y/w/h
               move.w     d4,int_in+10  ;Grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jmp        aes


select:        
; Met le bouton "bouton" Ö l'Çtat "selected"
; L'arbre objet doit se trouver dans arbre_adr

               movea.l    arbre_adr,a0
               move.w     bouton,d0     ;Index de l'objet
               mulu.w     #24,d0        ;* 24 (chaque objet: 24 octets)
               addi.w     #10,d0        ;+10 (offset de ob_state)
               ori.w      #1,0(a0,d0.w) ;Mettre le bit 0 (selected) Ö 1
               rts        


deselect:      
; Met le bouton "bouton" Ö l'Çtat "deselected"
; L'arbre objet doit se trouver dans arbre_adr

               movea.l    arbre_adr,a0
               move.w     bouton,d0     ;Index de l'objet
               mulu.w     #24,d0        ;* 24 (chaque objet: 24 octets)
               addi.w     #10,d0        ;+10 (offset de ob_state)
               andi.w     #-2,0(a0,d0.w)          ;Mettre le bit 0 (selected) Ö 1
               rts        


form_alert:    
; Affiche la boåte d'alerte. La chaåne se trouve Ö partir de a0.
; Le bouton numÇro 1 est le bouton par dÇfaut.

               move.w     #52,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #1,int_in     ;Bouton par dÇfaut
               move.l     a0,addr_in
               jmp        aes


write_text:    
; êcrit la chaåne dans l'objet Text ou (Index dans d0)
; Chaåne dans a0, arbre objet dans arbre_adr

               movea.l    arbre_adr,a1
               mulu.w     #24,d0
               movea.l    12(a1,d0.w),a1          ;Adresse du bloc TEDINFO
               movea.l    (a1),a1       ;te_ptext contient le texte

wrt_lp:        move.b     (a0)+,(a1)+
               bne.s      wrt_lp
               rts        


read_text:     
; L'opposÇ de write_text. L'adresse de destination
; doit àtre passÇe Ö a0

               movea.l    arbre_adr,a1
               mulu.w     #24,d0
               movea.l    12(a1,d0.w),a1
               movea.l    (a1),a1

rd_lp:         move.b     (a1)+,(a0)+
               bne.s      rd_lp
               rts        


               SECTION DATA 

rscname:       DC.b 'DIALOG2.RSC',0
errtxt:        DC.b "[3][Ce fichier n' est pas RSC !][Fin]",0
inittxt:       DC.b '*** aucun ***',0
empty:         DC.b 0


               SECTION BSS 

arbre_adr:     DS.l 1
bouton:        DS.w 1
str:           DS.b 40

               END 
