;
; Afficher barre de menus, fonctions command‚es par touches
; Assembler                      MENU2.ASM
;

               .INCLUDE 'GEM_INEX.ASM'

gemdos         = 1

MENUS          = 0        ;Constantes venant de MENU2.H2
DESK           = 3
FONCTION       = 4
INFO           = 7
FIN            = 16

               .TEXT 

main:          jsr        gem_init

; Pointeur souris: flŠche

               move.w     #78,control   ;graf_mouse
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0 pour la flŠche
               jsr        aes

; rsrc_load:

               move.w     #110,control  ;Opcode
               clr.w      control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #rsc_name,addr_in
               jsr        aes

               tst.w      int_out       ;Erreur?
               beq        rsc_error

; Trouver l'adresse de l'arbre d'objets menus (rsrc_gaddr)

               move.w     #112,control
               move.w     #2,control+2
               move.w     #1,control+4
               clr.w      control+6
               move.w     #1,control+8
               clr.w      int_in        ;0 -> nous cherchons un arbre
               move.w     #MENUS,int_in+2         ;Index de l'arbre de menus
               jsr        aes
               move.l     addr_out,menu_adr       ;Stocker la valeur

; Affichage de la barre de menus (menu_bar):

               move.w     #30,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #1,int_in     ;1 pour afficher le menu
               move.l     menu_adr,addr_in        ;Arbre d'objets menus
               jsr        aes

; Boucle d'attente evnt_multi

loop:          move.w     #25,control   ;evnt_multi
               move.w     #16,control+2 ;(relativement courte en assembleur!)
               move.w     #7,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #17,int_in    ;evnt_mesag + evnt_keybd
               move.l     #tampon,addr_in
               jsr        aes           ;int_out: 1 (Touche) / 16 (Menu)
               move.w     int_out,d7    ;pour suppression ult‚rieure

               btst       #4,d7         ;Re‡u un message?
               beq        no_menu

               cmpi.w     #10,tampon    ;Vraiment cliqu‚ option de menu?
               bne        loop          ;non, alors attendre

               cmpi.w     #INFO,tampon+8          ;sinon: Info demand‚e?
               bne.s      no_info
               move.w     #1,d0         ;Bouton par d‚faut
               lea.l      info_txt,a0
               jsr        form_alert    ;Affichage de la boŒte d'alerte
               bra        tnormal       ;et affichage normal du titre

no_info:       cmpi.w     #FIN,tampon+8 ;ou cliqu‚ Fin?
               bne        loop          ;non, alors attendre
               move.w     #2,d0         ;Bouton par d‚faut
               lea.l      fin_txt,a0    ;Demande de validation
               jsr        form_alert
               cmpi.w     #1,d0         ;cliqu‚ Oui?
               beq        fin           ;sinon interrompre le programme

tnormal:       move.w     #33,control   ;menu_tnormal (affiche le titre menu
               move.w     #2,control+2  ;en mode normal, et non plus en
               move.w     #1,control+4  ;vid‚o inverse)
               move.w     #1,control+6
               clr.w      control+8
               move.w     tampon+6,int_in         ;Num‚ro du titre (partie du message)
               move.w     #1,int_in+2   ;1: affichage normal du titre
               move.l     menu_adr,addr_in
               jsr        aes
               bra        loop          ;et attendre le clic suivant

no_menu:       btst       #0,d7         ;Touche appuy‚e?
               beq        loop
               move.w     int_out+10,d0 ;Touche appuy‚e
               andi.w     #$ff,d0       ;ne prendre en compte que le Low-Byte
               cmpi.b     #'Z',d0       ;minuscule
               ble        majusc
               subi.b     #'z'-'Z',d0   ;si oui, convertir en majuscule

majusc:        cmpi.b     #'I',d0       ;Demand‚ Information?
               bne        no_info2

; Titre du menu en vid‚o inverse:

               move.w     #33,control   ;menu_tnormal
               move.w     #2,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #DESK,int_in  ;Num‚ro du titre
               clr.w      int_in+2      ;0: affichage invers‚ du titre
               move.l     menu_adr,addr_in
               jsr        aes

               move.w     #1,d0         ;Bouton par d‚faut
               lea.l      info_txt,a0
               jsr        form_alert    ;Afficher la boŒte d'alerte

               move.w     #33,control   ;menu_tnormal
               move.w     #2,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #DESK,int_in  ;Num‚ro du titre
               move.w     #1,int_in+2   ;1: Afficher le titre noir sur blanc
               move.l     menu_adr,addr_in
               jsr        aes
               bra        loop

no_info2:      cmpi.b     #'E',d0
               bne        loop
               move.w     #33,control   ;menu_tnormal
               move.w     #2,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #FONCTION,int_in        ;Num‚ro du titre
               clr.w      int_in+2      ;0: Afficher le titre en vid‚o inverse
               move.l     menu_adr,addr_in
               jsr        aes

               move.w     #2,d0         ;Bouton par d‚faut
               lea.l      fin_txt,a0    ;Demande de confirmation
               jsr        form_alert
               cmpi.w     #1,d0         ;cliqu‚ Oui?
               beq        fin           ;sinon quitter programme

               move.w     #33,control   ;menu_tnormal
               move.w     #2,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #FONCTION,int_in        ;Num‚ro du titre
               move.w     #1,int_in+2   ;1: Affichage normal du titre
               move.l     menu_adr,addr_in
               jsr        aes
               bra        loop


; Fin programme:
; Effacer la barre des menus (menu_bar):

fin:           move.w     #30,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               clr.w      int_in        ;0 pour effacer le menu
               move.l     menu_adr,addr_in        ;Arbre objets de menu
               jsr        aes

; Effacer le fichier ressource de la m‚moire (rsrc_free)

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
; Affiche boŒte d'alerte
; ParamŠtres:
;   d0: Bouton par d‚faut (0..3)
;   a0: ChaŒne de description de la boŒte [.][...][...]
; Affichage:
;   d0: Bouton cliqu‚ (0..3)

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

rsc_name:      .DC.b "MENU2.RSC",0

               .BSS 

menu_adr:      .DS.l 1

tampon:        .DS.w 8

               .END 
