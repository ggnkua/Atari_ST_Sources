***********   Directory-Inhalt anzeigen   ************
 
setdta  macro
        pea    \1               ;Adresse des DTA-Puffers
        move.w  #$1A,-(sp)      ;Funktionsnummer
        trap    #1              ;Funktion aufrufen
        addq.l  #6,sp           ;Stack korrigieren
        endm

sfirst  macro
        move.w  #0,-(sp)        ;Attribut "normale Files"
        pea     \1              ;Adresse des File-Namens
        move.w  #$4E,-(sp)      ;Funktionsnummer
        trap    #1              ;Aufruf       
        addq.l  #8,sp		;Stackkorrektur
        tst     d0              ;hole Status
        endm

snext   macro
        move.w  #$4F,-(sp)    	;naechstes File suchen
        trap    #1
        addq.l  #2,sp
        tst     d0
        endm

writes  macro
        pea     \1
        move.w  #9,-(sp)        ;Funk. PRINTLINE
        trap    #1
        addq.l  #6,sp
        endm

conin   macro
        move    #1,-(sp)    
        trap    #1
        addq.l  #2,sp
        endm

warte   macro
        writes  wait            ;Text "Warte auf Taste "
        conin
        endm 

term    macro
        clr     -(sp)           ; Funtion Term(inate)
        trap    #1          
        endm
    
        text                    ;Start hier
        writes  msg
        writes  crlf

        setdta  dta
        sfirst  fname           ;Ersten File gefunden?
        bne     done            ;wenn nicht, fertig
loop    writes  dta+30          ;sonst ...
        writes  crlf            ;... Name drucken
        snext                   ;Neuer Versuch
        beq     loop            ;wenn noch einer

done    warte
        term

* Datenbereich
* ------------
        data
msg     dc.b    27,'E'          ;Bildschirm loeschen
        dc.b    'Directory'     ;Text
crlf    dc.b    13,10           ;Neue Zeile
        dc.b    0               ;Ende Text

        ds.w    0               ;justiere auf Wortgrenze

wait    dc.b    13,10,'Warte auf Taste',0

        ds.w    0
fname   dc.b    '*.*',0         ;Auch Wild Cards erlaubt

        ds.w    0
dta     ds.b    44              ;DTA-Puffer

        end        

