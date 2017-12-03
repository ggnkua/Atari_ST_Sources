;
; Affichage de la police complŠte avec Bconout
; Assembleur       	FONTOUT.S
;

console        = 2
ascii          = 5

bconout        = 3
bconin         = 2

gemdos         = 1
bios           = 13


               SECTION TEXT 

               clr.w      d3            ;Compteur de caractŠres
               move.w     #$ff,d4       ;Compteur de boucle

loop:          move.b     d3,d5         ;Teste si divisible par 16
               andi.b     #%11110000,d5
               cmp.b      d5,d3
               bne.s      no_crlf

               move.w     #13,-(sp)     ;Retour Chariot
               move.w     #console,-(sp)          ;p‚riph‚rique de sortie
               move.w     #bconout,-(sp)          ;Num‚ro de fonction
               trap       #bios
               addq.l     #6,sp

               move.w     #10,-(sp)     ;Saut de ligne
               move.w     #console,-(sp)
               move.w     #bconout,-(sp)
               trap       #bios
               addq.l     #6,sp

no_crlf:       move.w     d3,-(sp)      ;CaractŠre … afficher
               move.w     #ascii,-(sp)  ;Le p‚riph‚rique est le canal ASCII
               move.w     #bconout,-(sp)          ;Num‚ro de fonction
               trap       #bios
               addq.l     #6,sp

               move.w     #' ',-(sp)    ;Espace
               move.w     #ascii,-(sp)  ;P‚riph‚rique de sortie
               move.w     #bconout,-(sp)          ;Num‚ro de fonction
               trap       #bios
               addq.l     #6,sp

               addq.w     #1,d3         ;CaractŠre suivant

               dbra       d4,loop

               move.w     #console,-(sp)          ;Attend appui d'une touche
               move.w     #bconin,-(sp)
               trap       #bios
               addq.l     #4,sp

               clr.w      -(sp)
               trap       #gemdos

               END 
