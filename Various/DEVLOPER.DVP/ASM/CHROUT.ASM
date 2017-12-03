;
; Entr‚e et sortie de caractŠres sous GEMDOS
; GFA-Assembleur     CHROUT.ASM
;

gemdos         = 1

crawcin        = 7
cconout        = 2

; Ce programme vous permet d'afficher
; un texte … l'‚cran. Fin: RETURN

               .TEXT 
loop:          move.w     #crawcin,-(sp)          ;Lire un caractŠre
               trap       #gemdos       ;(n'est pas affich‚
               addq.l     #2,sp         ;… l'‚cran)

               cmpi.b     #13,d0        ;Return appuy‚?
               beq.s      quitloop

               move.w     d0,-(sp)      ;si non, afficher le caractŠre...
               move.w     #cconout,-(sp)
               trap       #gemdos
               addq.l     #4,sp

               bra.s      loop          ;... et en lire un autre
quitloop:      clr.w      -(sp)         ;Quitter le programme
               trap       #gemdos

               .END 


