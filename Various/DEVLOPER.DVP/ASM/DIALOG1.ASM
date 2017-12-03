;
; Charger, afficher et traiter la premiäre boåte de dialogue
; Assembler                         DIALOG1.ASM
;

gemdos         = 1

FORM1          = 0        ;Constantes venant de DIALOG1.H2
BOUTON3        = 4
BOUTON1        = 5
BOUTON2        = 6

               .INCLUDE 'GEM_INEX.ASM'

               .TEXT 

main:          jsr        gem_init

; Pointeur souris: fläche

               move.w     #78,control   ;graf_mouse
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0 pour la fläche
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

; rsrc_gaddr donne l'adresse de la boåte de dialogue:

               move.w     #112,control
               move.w     #2,control+2
               move.w     #1,control+4
               clr.w      control+6
               move.w     #1,control+8
               clr.w      int_in        ;0 pour "Cherche arbre"
               move.w     #FORM1,int_in+2         ;Index de l'arbre
               jsr        aes
               move.l     addr_out,arbre_adr      ;RÇsultat: l'adresse de l'arbre

               jsr        show_dialog   ;Affichage de l'arbre

; form_do fait fonctionner Dialog

               move.w     #50,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;Pas champ Edit
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w     int_out,bouton          ;Bouton appuyÇ

               jsr        deselect      ;Effacer l'Çtat Selected

               jsr        hide_dialog   ;Effacer la boåte de dialogue

; Message selon le bouton appuyÇ

               move.w     bouton,d1
               moveq.l    #1,d0
               cmpi.w     #BOUTON2,d1
               bne.s      not2
               moveq.l    #2,d0
not2:          cmpi.w     #BOUTON3,d1
               bne.s      not3
               moveq.l    #3,d0

not3:          addi.b     #'0',d0       ;Transforme nombre en chiffre ASCII
               move.b     d0,chiffre

               lea.l      form_str,a0   ;Affichage de la boåte d'alerte
               jsr        form_alert

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
               jsr        form_alert    ;Affichage du message d'alerte

               bra        quit


show_dialog:   
; Ce sous-programme dessine un arbre objets sur l'Çcran
; Son adresse doit se trouver sous "arbre_adr"

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

; form_dial corrige les cadres de fenàtres, etc. (0)

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               clr.w      int_in        ;Sous-fonction 0
; aucune valeur pour le petit rectangle fo_dilittlx/y/w/h
               move.w     d4,int_in+10  ;grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jsr        aes

; form_dial desine le rectangle "zoom" (1):

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
               move.w     d4,int_in+10  ;grand rectangle do_dibigx/y/w/h
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
               clr.w      int_in        ;Dessiner d'abord 0=objet racine
               move.w     #12,int_in+2  ;12 niveaux maxi (valeur arbitraire)
               move.w     d4,int_in+4
               move.w     d5,int_in+6
               move.w     d6,int_in+8
               move.w     d7,int_in+10
               move.l     arbre_adr,addr_in
               jmp        aes


hide_dialog:   
; Efface le formulaire de l'Çcran
; Adresse de l'arbre objet Ö nouveau dans arbre_adr

; form_center

               move.w     #54,control
               clr.w      control+2
               move.w     #5,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w     int_out+2,d4  ;Sauvegarder coordonnÇes
               move.w     int_out+4,d5
               move.w     int_out+6,d6
               move.w     int_out+8,d7

; form_dial dessine le rectangle diminuant (2):

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

; form_dial envoie les messages Redraw Ö la fenàtre (3)

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               move.w     #3,int_in     ;Sous-fonction 3
; aucune valeur pour le petit rectangle fo_dilittlx/y/w/h
               move.w     d4,int_in+10  ;grand rectangle do_dibigx/y/w/h
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jmp        aes


select:        
; Fait passer le bouton 'bouton' Ö l'Çtat 'selected'
; L'arbre objet doit de trouver dans arbre_adr

               movea.l    arbre_adr,a0
               move.w     bouton,d0     ;Index de l'objet
               mulu.w     #24,d0        ;* 24 (chaque object a 24 octets)
               ori.w      #1,10(a0,d0.w)          ;Mettre le bit 0 Ö 1 (selected)
               rts        


deselect:      

; Fait passer le bouton 'bouton' Ö l'Çtat 'deselected'
; L'arbre objet doit de trouver dans arbre_adr

               movea.l    arbre_adr,a0
               move.w     bouton,d0     ;Index de l'object
               mulu.w     #24,d0        ;* 24 (chaque object a 24 octets)
               andi.w     #-2,10(a0,d0.w)         ;Effacer le bit 0 (selected)
               rts        


form_alert:    
; Affiche la boåte d'alerte. La chaåne de description
; se trouve Ö partir de a0. Le bouton Nr. 1 est le bouton
; par dÇfaut.

               move.w     #52,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #1,int_in     ;Bouton par dÇfaut
               move.l     a0,addr_in
               jmp        aes



               .DATA 

rscname:       .DC.b 'DIALOG1.RSC',0

form_str:      .DC.b '[1][Appui sur le bouton no '
chiffre:       .DC.b ' ][Correct!]',0

errtxt:        .DC.b '[3][Fichier pas RSC!][Fin]',0


               .BSS 

arbre_adr:     .DS.l 1
bouton:        .DS.w 1

               .END 
