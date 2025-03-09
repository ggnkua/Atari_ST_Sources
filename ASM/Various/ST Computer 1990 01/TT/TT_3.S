************************************************************
* Hier wird geprÅft, ob ein Programm auf einem TT lÑuft.   *
* Falls ja wird die Variable ttflg entsprechend gesetzt.   *
* Diese Routine muû im Supervisor-Modus ausgefÅhrt werden! *
************************************************************


_p_cookies = $5a0


         text

tttest:
         move.l _p_cookies,d0   ;cookie jar vorhanden?
         beq nocookie           ;nein-
         move.l d0,a0
loop:    movem.l (a0)+,d0-d1
         tst.l d0               ;Ende der Liste?
         beq nocookie           ;ja-
         cmp.l #"_MCH",d0       ;cookie fÅr Computertyp?
         bne loop               ;nein-
         cmp.l #$00020000,d1    ;TT (oder gar neuer)?
         scc ttflg
nocookie:rts


         bss

ttflg:   ds.b 1

Listing 3

