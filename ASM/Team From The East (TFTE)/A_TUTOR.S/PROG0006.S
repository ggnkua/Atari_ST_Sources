* The Voice II by Team From The East
* Assembler Tutorial
* Program sprowdzajacy rozdzielczosc
* W GfA Basicu wygladalby on tak:
* X=XBIOS(4)
* if X=1 
* print "to jest srednia rozdzielczosc"
* else
* ? "to nie jest srednia rozdzielczosc"
* endif
* ~inp(2)
* end
*

        move.w #4,-(sp)         ; przeslanie na stos wartosci dla XBIOS
                                ; tu 4: XBIOS(4)
        trap #14                ; trap #14 to to samo co XBIOS
                                ; jesli na stosie(sp) jest odlozona wartosc 4
                                ; to po wykonaniu trap #14 w rejestrze d0
                                ; pojawi sie liczba z zakresu od 0 do 2
                                ; 0 dla roz. niskiej, 1 - sredniej, 2 - wysokiej
        addq.l #2,-(sp)         ; uporzadkuj stos (to trzeba zrobic) 
        cmp.b #1,D0             ; sprawdz czy d0 = 1
        bne tu                  ; jesli nie, to przejdz do linii TU
        move.l #srednia,-(sp) 	; jesli d0 = 1 wykonaj procedure wyswietlenia
        move.w #9,-(sp)
        trap #1
        addq.l #6,sp
        bsr exit                ; wyjdz
tu:                             ; jesli d0 <> 1
        move.l #zla,-(sp)       ; to wyswietl dane ZLA
        move.w #9,-(sp)
        trap #1
        addq.l #6,sp
exit                            ; procedura wyjscia
        move.w #1,-(sp)         ; GEMDOS 1
        trap #1                 ; czyli czekaj na klawisz
        addq.l #2,sp
        clr.w (sp)              ; wychodzimy
        trap #1                 ; bye !!!!!
        
* dane*

srednia:                        ; to wyswietla jesli d0=1
        dc.b "to jest srednia rozdzielczosc",10,0 
        even
zla:                            ; to wyswiela jesli d0<>1
        dc.b 13,"to nie jest srednia rozdzielczosc",0
        even
        
