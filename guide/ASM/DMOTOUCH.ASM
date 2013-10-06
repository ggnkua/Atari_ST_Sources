;
; DÇmo permanente (Quitter: appui touche)
; Assembleur           DMOTOUCH.ASM
;

gemdos         = 1
bios           = 13

bconstat       = 1
bconin         = 2
bconout        = 3

               .TEXT 

               clr.w      d3

loop:          lea.l      affichage,a3  ;Affichage de la chaåne

outloop:       tst.b      (a3)          ;ArrivÇ en fin de chaåne?
               beq.s      outfin        ;alors aller Ö la boucle d'attente
               move.b     (a3)+,d3      ;Sinon afficher caractäre
               move.w     d3,-(sp)      ;PlacÇ sur pile comme un mot
               move.w     #2,-(sp)      ;La console est le "2" (Çcran)
               move.w     #bconout,-(sp)
               trap       #bios
               addq.l     #6,sp

               bra.s      outloop       ;Caractäre suivant...

outfin:        moveq.l    #-1,d0        ;Boucle de ralentissement
wait:          dbra       d0,wait

               move.w     #2,-(sp)      ;Touche appuyÇe pendant ce temps?
               move.w     #bconstat,-(sp)
               trap       #bios
               addq.l     #4,sp
               tst.w      d0
               beq.s      loop          ;Si non, continuer...

               move.w     #2,-(sp)      ;Si oui, lire le caractäre
               move.w     #bconin,-(sp) ;dans le tampon du clavier...
               trap       #bios
               addq.l     #4,sp

               clr.w      -(sp)         ;... et quitter le programme
               trap       #gemdos

               .DATA 
affichage:     .DC.b 'DêMONSTRATION. Touche = Fin...          ',0

               .END 

