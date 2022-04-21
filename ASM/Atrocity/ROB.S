* petit prg a rajouter au debut de la routine
* anti trace d'une rob northen pour avoir le
* decryptage de toutes les instructions
* Dr Clone/RADIATION


          movem.l   D0-D1/A0/A6,$0300.w
          moveq     #0,D0
          moveq     #0,D1
          move.l    2(A7),D0            ; adr pc en cours
          move.l    $88.w,D1            ; ancien pc
          move.l    D0,$88.w            ; pc en cours->ancien pc
          sub.l     D1,D0
          lsr.w     #1,D0               ; d0/2 = nb de mots pris par l'instruction
          subq.l    #1,D0               ; pour la boucle
          movea.l   $0400.w,A0          ; adr de transfert
LOOP_T:   move.w    (A6)+,(A0)+
          dbra      D0,LOOP_T
          move.l    A0,$0400.w
          movem.l   $0300.w,D0-D1/A0/A6
          eor.l     D6,(A6)             ; les 2 premieres instr de la trace
          eor.l     D6,4(A6)
          jmp       $00
