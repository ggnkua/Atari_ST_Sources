;
; Teste si imprimante prˆte par Bcostat
; GFA-Assembleur     ONLINE.ASM
;

imprimte       = 0
console        = 2

bconin         = 2
bcostat        = 8
cconws         = 9

gemdos         = 1
bios           = 13

               .TEXT 
               move.w     #imprimte,-(sp)         ;Imprimante prˆte?
               move.w     #bcostat,-(sp)
               trap       #bios
               addq.l     #4,sp

               tst.b      d0            ;Alors d0 = -1
               beq.s      not_ok        ;Si pas prˆte, alors d0 = 0
ready:         pea        ok_text       ;Afficher message
               bra.s      cont

not_ok:        pea        err_text
cont:          move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               move.w     #console,-(sp)          ;Attendre appui touche
               move.w     #bconin,-(sp)
               trap       #bios
               addq.l     #4,sp

               clr.w      -(sp)         ;Quitter programme
               trap       #gemdos

               .DATA 
ok_text:       .DC.b "L'imprimante est prˆte",0
err_text:      .DC.b "L'imprimante n'est pas prˆte!",0

               .END 

