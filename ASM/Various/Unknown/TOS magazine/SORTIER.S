; Bubble-Sort
; Tabellenanfang in a1

sortierung:movem.l d0-d2/a0-a1,-(sp) ; Register retten

s_begin:move.w  (a1),d0       ; Anzahl der Tabelleneintr„ge
        lea     2(a1),a0
        bclr    #7,d2         ; Austausch-Bit l”schen
        subq.w  #2,d0

s_loop: move.w  (a0)+,d1      ; Eintrag i in d1
        cmp.w   (a0),d1       ; mit Eintrag i+1 vergleichen
        ble.s   s_ende        ; falls i <= i+1, dann Ende

        move.w  (a0),-2(a0)   ; Tabelleneintr„ge
        move.w  d1,(a0)       ; vertauschen
        bset    #7,d2         ; Austausch-Bit setzen

s_ende: dbra    d0,s_loop     ;
        btst    #7,d2         ; Austausch-Bit gesetzt ?
        bne.s   s_begin       ; Ja, dann noch mal
        movem.l (sp)+,d0-d2/a0-a1 ; Register zurckholen

fertig: rts                   ; und fertig !


