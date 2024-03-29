;
; Chargement, affichage et modification des Edits de premi�re bo�te de dialogue
; Assembleur		DIALOG3.S
;

gemdos         = 1

DIALOG         = 0        ;Constantes venant de DIALOG3.H2
PO             = 3
FM             = 2
OC             = 4
GO             = 5
FIN            = 6


               INCLUDE 'GEM_INEX.S'

               SECTION TEXT 

main:          jsr        gem_init

; Pointeur souris: fl�che:

               move.w     #78,control   ;graf_mouse
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0 pour fl�che
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
               move.l     addr_out,arbre_adr      ;R�sultat: l'adresse

; Un bouton par d�faut (FM):

               move.w     #FM,bouton
               jsr        select

               jsr        show_dialog   ;Affichage de l'arbre

; form_do permet de modifier Dialog

               move.w     #50,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;pas de champ Edit
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w     int_out,bouton          ;Bouton appuy�

               jsr        deselect      ;Effacer l'�tat Selected

               jsr        hide_dialog   ;Effacer la bo�te de dialogue de l'�cran

; Exploitation des boutons:

               move.w     #FM,d0
               jsr        selected      ;Bouton activ�?
               beq.s      n_FM
               moveq.l    #0,d1

n_FM:          move.w     #PO,d0
               jsr        selected
               beq.s      n_PO
               moveq.l    #1,d1

n_PO:          move.w     #OC,d0
               jsr        selected
               beq.s      n_OC
               moveq.l    #2,d1

n_OC:          move.w     #GO,d0
               jsr        selected
               beq.s      n_GO
               moveq.l    #3,d1

n_GO:          asl.w      #2,d1         ;4 fois
               lea.l      frqtab,a0     ;Tableau de pointeurs sur des cha�nes
               movea.l    0(a0,d1.w),a0 ;Ajouter cha�ne avec nPO de longueur d'onde
               lea.l      form_cont,a1  ;� la cha�ne form_alert
cpy_lp:        move.b     (a0)+,(a1)+
               bne.s      cpy_lp

               subq.l     #1,a1         ;�craser l'octet nul
               lea.l      form_end,a0   ;avec le reste de la cha�ne
cpy_l2:        move.b     (a0)+,(a1)+
               bne.s      cpy_l2

               lea.l      form_debut,a0
               jsr        form_alert    ;Affichage de la bo�te

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
               jsr        form_alert    ;Affichage du texte d'avertissement

               bra        quit


show_dialog:   
; Ce sous-programme dessine un arbre objet � l'�cran.
; Son adresse doit se trouver � 'arbre_adr'

; form_center

               move.w     #54,control
               clr.w      control+2
               move.w     #5,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w     int_out+2,d4  ;Sauvegarder les coordonn�es
               move.w     int_out+4,d5
               move.w     int_out+6,d6
               move.w     int_out+8,d7

; form_dial sauvegarde les cadres des fen�tres, etc. (0)

               move.w     #51,control
               move.w     #9,control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               clr.w      int_in        ;Sous-fonction 0
; Pas de valeur pour le petit rectangle fo_dilittlx/y/w/h
               move.w     d4,int_in+10  ;Grand rectangle do_dibigx/y/w/h          ;
               move.w     d5,int_in+12
               move.w     d6,int_in+14
               move.w     d7,int_in+16
               jsr        aes

; form_dial dessine le rectangle zoPO� (1):

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
; Efface le formulaire de l'�cran
; Adresse de l'arbre � nouveau dans arbre_adr

; form_center

               move.w     #54,control
               clr.w      control+2
               move.w     #5,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     arbre_adr,addr_in
               jsr        aes
               move.w     int_out+2,d4  ;Sauvegarder les coordonn�es
               move.w     int_out+4,d5
               move.w     int_out+6,d6
               move.w     int_out+8,d7

; form_dial dessine le rectangle qui dispara�t (2):

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

; form_dial envoie des messages Redraw � la fen�tre (3)

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
; Met le bouton "bouton" � l'�tat "selected"
; L'arbre objet doit se trouver dans arbre_adr

               movea.l    arbre_adr,a0
               move.w     bouton,d0     ;Index de l'objet
               mulu.w     #24,d0        ;* 24 (chaque objet: 24 octets)
               addi.w     #10,d0        ;+10 (Offset de ob_state)
               ori.w      #1,0(a0,d0.w) ;Mettre le bit 0 (selected) � 1
               rts        


deselect:      
; Met le bouton "bouton" � l'�tat "deselected"
; L'arbre objet doit se trouver dans arbre_adr

               movea.l    arbre_adr,a0
               move.w     bouton,d0     ;Index de l'objet
               mulu.w     #24,d0        ;* 24 (chaque objet: 24 octets)
               andi.w     #-2,10(a0,d0.w)         ;Mettre le bit 0 (selected) � 0
               rts        


selected:      
; Le drapeau z�ro est mis � 1 quand l'objet (Index dans d0)
; n'est pas s�lectionn�. Adresse de l'arbre dans arbre_adr.

               movea.l    arbre_adr,a0
               mulu.w     #24,d0        ;Index * 24 = Offset
               btst       #0,11(a0,d0.w)          ;btst teste l'octet!!!, donc 11
               rts        


form_alert:    
; Affiche la bo�te d'alerte. La cha�ne se trouve � partir de a0.
; Le bouton num�ro 1 est le bouton par d�faut.

               move.w     #52,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #1,int_in     ;Bouton par d�faut
               move.l     a0,addr_in
               jmp        aes


write_text:    
; �crit la cha�ne dans l'objet Text ou Edit (Index dans d0)
; Cha�ne dans a0, arbre objet dans arbre_adr

               movea.l    arbre_adr,a1
               mulu.w     #24,d0
               movea.l    12(a1,d0.w),a1          ;Adresse du bloc TEDINFO
               movea.l    (a1),a1       ;te_ptext contient le texte

wrt_lp:        move.b     (a0)+,(a1)+
               bne.s      wrt_lp
               rts        


read_text:     
; Le pendant de write_text. L'adresse
; de destination doit �tre pass�e dans a0

               movea.l    arbre_adr,a1
               mulu.w     #24,d0
               movea.l    12(a1,d0.w),a1
               movea.l    (a1),a1

rd_lp:         move.b     (a1)+,(a0)+
               bne.s      rd_lp
               rts        


               SECTION DATA 

frqtab:        DC.l f_FM,f_PO,f_OC,f_GO          ; Adresses de la cha�ne

rscname:       DC.b 'DIALOG3.RSC',0
errtxt:        DC.b '[3][Pas de fichier RSC!][Fin]',0
f_FM:          DC.b 'Mod. de fr�quence',0
f_PO:          DC.b 'Ondes moyennes',0
f_OC:          DC.b 'Ondes courtes',0
f_GO:          DC.b 'Ondes longues',0
form_end:      DC.b " !][Oui!]",0
form_debut:    DC.b '[1][Vous avez s�lectionn�|'
form_cont:     

               SECTION BSS 

               DS.w 30   ;Place pour la fin de la cha�ne d'alerte
arbre_adr:     DS.l 1
bouton:        DS.w 1

               END 
