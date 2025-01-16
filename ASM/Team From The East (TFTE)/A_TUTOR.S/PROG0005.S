* The Voice II by T.F.T.E.
* program sprawdzajcy jaki zostal nacisniety klawisz
* 
        move.w #1,-(sp)         ; 1 na stos
        trap #1                 ; wykonaj gemdos 1, czyli czekaj na klawisz
        addq.l #2,sp            ; uporzadkuj stos
        move.l d0,klawisz       ; zapamietaj kod ascii pod zmiena klawisz 
                                ; pod d0 byl kod ascii
        move.l #txt,-(sp)       ; tu wyswietlamy napis "Nacisnales klawisz..." 
        move.w #9,-(sp)
        trap #1
        addq.l #6,sp
        move.l klawisz,d0       ; d0 = klawisz 
        move.w d0,-(sp)         ; w d0 jest kod ascii nacisnietego klawisza 
        move.w #2,-(sp)         ; teraz go wyswietlamy
        trap #1                 ; gemdos 2, czyli wyswietl litere
        addq.l #6,sp            ; stos

wyjdz
        move.w #1,-(sp)
        trap #1
        clr.w (sp)
        trap #1                 ; bye

txt:
        dc.b 13,"Nacisnales klawisz ",0
        even
klawisz:                        ; zarezerwuj miejsce na kod ascii
        ds 1
        
