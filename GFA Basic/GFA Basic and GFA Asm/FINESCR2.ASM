; fichier: finescr2.asm
;
; exemple de d‚filement de l'‚cran en Assembleur
;
;
              .INCLUDE 'ATARI.IS' ; insertion de quelques d‚finitions

scrollup:     movem.l   d0/a0,-(sp) ; utilisation locale des variables a0 et d0

              Physbase ; rechercher le d‚but de la m‚moire d'‚cran
              movea.l   d0,a0  ; adresse port‚e dans le registre d'adresses
              move.w    #1,d0  ; mettre le compteur de boucle sur d0
loop:         move.l    80(a0),(a0) ; d‚placement d'un mot long
              adda.w    #4,a0 ; poursuite du d‚placement du pointeur
              add.w     #1,d0 ; incr‚menter la variable de comptage
              cmp.w     #8000-20,d0 ; contr“le de la condition
              blo       loop ; 7980 < d0, donc r‚p‚tition de la boucle

              movem.l   (sp)+,d0/a0 ; pour restaurer les variables
              rts            ; puis retourner dans le programme principal
              .END           ; signe Assembleur de fin de fichier

