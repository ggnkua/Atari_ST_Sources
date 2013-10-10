;
; Charger un fichier Ressource et afficher une barre de menus
; Assembler                        MENU1.ASM
;

               .INCLUDE 'GEM_INEX.ASM'

gemdos         = 1

MENUS          = 0        ;Constantes pour l'arbre du menu et pour les deux
INFO           = 7        ;entr‚es (venant du fichier MENU1.H2 cr‚‚ avec
FIN            = 16       ;BASHEAD.TOS)

               .TEXT 

main:          jsr        gem_init

; Pointeur souris: flŠche

               move.w     #78,control   ;graf_mouse
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0 pour flŠche
               jsr        aes

; rsrc_load:

               move.w     #110,control  ;Opcode
               clr.w      control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #rsc_name,addr_in
               jsr        aes

               tst.w      int_out       ;Erreur s'est produite?
               beq        rsc_error

; Trouver l'adresse de l'abre d'objets menu (rsrc_gaddr)

               move.w     #112,control
               move.w     #2,control+2
               move.w     #1,control+4
               clr.w      control+6
               move.w     #1,control+8
               clr.w      int_in        ;0 -> nous cherchons un arbre
               move.w     #MENUS,int_in+2         ;Index de l'arbre de menu
               jsr        aes
               move.l     addr_out,menu_adr       ;Stockage de la valeur

; Affichage de la barre des menus (menu_bar):

               move.w     #30,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #1,int_in     ;1 pour affichage d'un menu
               move.l     menu_adr,addr_in        ;Arbre objet de menu
               jsr        aes

; Boucle d'attente evnt_mesag

loop:          move.w     #23,control
               clr.w      control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #tampon,addr_in
               jsr        aes

               cmpi.w     #10,tampon    ;Option de menu cliqu‚e?
               bne        loop          ;non, alors attendre

               cmpi.w     #INFO,tampon+8          ;sinon: demand‚ Info?
               bne.s      no_info
               move.w     #1,d0         ;Bouton par d‚faut
               lea.l      info_txt,a0
               jsr        form_alert    ;Affichage de la boŒte d'Alerte
               bra        tnormal       ;et du titre en mode normal

no_info:       cmpi.w     #FIN,tampon+8 ;Ou cliqu‚ sur Fin?
               bne        loop          ;non, alors attendre
               move.w     #2,d0         ;Bouton par d‚faut
               lea.l      fin_txt,a0    ;Demande de validation
               jsr        form_alert
               cmpi.w     #1,d0         ;Cliqu‚ oui?
               beq        fini          ;sinon quitter le programme

tnormal:       move.w     #33,control   ;menu_tnormal (affiche le titre
               move.w     #2,control+2  ;du menu en normal, et non plus
               move.w     #1,control+4  ;en vid‚o inverse)
               move.w     #1,control+6
               clr.w      control+8
               move.w     tampon+6,int_in         ;Num‚ro du titre (partie du message)
               move.w     #1,int_in+2   ;1: Afficher le titre en mode normal
               move.l     menu_adr,addr_in
               jsr        aes
               bra        loop          ;et attendre le clic suivant


; Fin du programme:
; Effacer la barre des menus (menu_bar):

fini:          move.w     #30,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0 pour effacer menu
               move.l     menu_adr,addr_in        ;Arbre objets menu
               jsr        aes

; Effacer fichier ressource en m‚moire (rsrc_free)

               move.w     #111,control
               clr.w      control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               jsr        aes

quit:          jsr        gem_exit

               clr.w      -(sp)
               trap       #gemdos


rsc_error:     
               move.w     #1,d0         ;Bouton par d‚faut
               lea.l      err_txt,a0
               jsr        form_alert    ;Message d'erreur
               bra        quit          ;et interrompre le programme

form_alert:    
; Affiche la boŒte d'alerte.
; ParamŠtres:
;   d0: Bouton par d‚faut (0..3)
;   a0: ChaŒne d‚crivant la boŒte [.][...][...]
; Affichage:
;   d0: bouton cliqu‚ (0..3)

               move.w     #52,control   ;Opcode form_alert
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     d0,int_in     ;Bouton par d‚faut
               move.l     a0,addr_in    ;ChaŒne
               jsr        aes
               move.w     int_out,d0    ;Bouton cliqu‚
               rts        


               .DATA 

info_txt:      .DC.b "[1][Programme d‚mo de menu|(c) 1989 Micro Application]"
               .DC.b "[Suite]",0

fin_txt:       .DC.b "[2][Quitter? S–r?][Oui|Non]",0

err_txt:       .DC.b "[3][Pas de fichier ressource!][Quitter]",0

rsc_name:      .DC.b "MENU1.RSC",0

               .BSS 

menu_adr:      .DS.l 1

tampon:        .DS.w 8

               .END 
