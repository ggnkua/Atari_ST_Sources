;
; Mini application GEM de d‚monstration
; Assembleur		DEMOAPP.S
;

gemdos         = 1


               INCLUDE 'GEM_INIT.S'

	       SECTION TEXT
;appl_init

main:          move.w     #10,control   ;Num‚ro de fonction: 10
               clr.w      control+2     ;0 Entr‚es dans int_in
               move.w     #1,control+4  ;1 Entr‚e dans int_out
               clr.w      control+6     ;0 Entr‚es dans addr_in
               clr.w      control+8     ;0 Entr‚es dans addr_out
               jsr        aes           ;Appel de la fonction
;(la valeur de retour ap_id ne nous int‚resse pas)

;Afficher une boŒte d'alerte par form_alert

               move.w     #52,control   ;Num‚ro de fonction
               move.w     #1,control+2  ;...
               move.w     #1,control+4
               move.w     #1,control+6
               clr.w      control+8

               move.w     #1,int_in     ;le premier bouton est par d‚faut
               move.l     #al_box,addr_in         ;Contenu de la boŒte

               jsr        aes

;appl_exit

               move.w     #19,control   ;Num‚ro de fonction
               clr.w      control+2
               move.w     #1,control+4
               clr.w      control+6
               clr.w      control+8
               jsr        aes

               clr.w      -(sp)         ;Fonction GEMDOS Pterm0
               trap       #gemdos       ;termine le programme "correctement"


               SECTION DATA      
               
al_box:        DC.b "[1][Salut|Application GEM!][Aha]",0
               
               END 
