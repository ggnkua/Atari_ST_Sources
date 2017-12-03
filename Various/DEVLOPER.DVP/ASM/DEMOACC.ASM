;
; Accessoire de d‚monstration DEMOACC.ASM
; Assembler
;

               .INCLUDE 'ACC_INIT.ASM'  ;Nouveau fichier include

               .TEXT 

main:          jsr        gem_init      ;retourne ap_id

; menu_register

               move.w     #35,control
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     ap_id,int_in
               move.l     #acc_name,addr_in
               jsr        aes
               move.w     int_out,ac_id ;ID de l'entr‚e du menu

;evnt_mesag dans une boucle sans fin

loop:          move.w     #23,control   ;Opcode evnt_mesag
               clr.w      control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.l     #tampon,addr_in
               jsr        aes

; v‚rifier le message re‡u:

               cmpi.w     #40,tampon    ;Accessoire appel‚?
               bne        loop

               move.w     tampon+8,d0   ;ID de notre accessoire
               cmp.w      ac_id,d0      ;est-ce vraiment notre tour?
               bne        loop

               jsr        go_accessory  ;Appeler programme
               bra        loop          ;et poursuivre la boucle sans fin...


; Le petit sous-programme suivant est l'accessoire proprement
; dit. Il affiche une petite boŒte d'alerte par form_alert


go_accessory:  

               move.w     #52,control   ;Opcode form_alert
               move.w     #1,control+2
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8
               move.w     #1,int_in     ;Bouton par d‚faut
               move.l     #form_str,addr_in
               jsr        aes

               rts                      ;Fin de l'accessoire


               .DATA 

form_str:      .DC.b '[1][S U P E R - A C C E S S O I R E|'
               .DC.b 'Veuillez choisir:]'
               .DC.b '[Fin|Fini|Quitter]',0

acc_name:      .DC.b '  Accessoire d‚monstration',0

               .BSS 

tampon:        .DS.w 8    ;De la place pour les messages

ac_id:         .DS.w 1    ;ID accessoire

               .END 
