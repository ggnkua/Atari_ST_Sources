;
; Mididaten lesen
;
midi_irq:       ; Test auf MIDI
                move #$fc04,a0          ; Basisadresse MIDI
                move.b (a0),d1          ; Status holen
                btst #7,d1              ; IRQ
                beq midi_end            ; nein !!
                btst #0,d1              ; RECEIVER full ?
                beq midi_end            ; Nein,dann Ende

                move.b 2(a0),d2         ; Byte holen
                move.l $3fc.w,a1        ; Adresse
                move.b d2,(a1)+         ; und sichern
                move.l a1,$3fc.w        ; und Adresse sichern

midi_end:       rts

