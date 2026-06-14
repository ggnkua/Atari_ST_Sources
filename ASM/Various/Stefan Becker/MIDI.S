;
; Midi-senden (im Timer-A Interrupt)
;  

send_irq:       movem.l d0-d1/a0-a1,-(sp)

                move.l $3f0.w,a0        ; laufende Pufferadresse
                move.l $3f4.w,d0        ; noch zu sendende Bytes
                bmi.s send_irq_end      ; <0,dann fertig !
                beq.s send_irq_end      ; 0,dann fertig !

                ; warten, bis ACIA fertig ist
                move #$fc04,a1          ; Adresse MIDI-ACIA
send_wait:      move.b (a1),d1          ; Status
                btst #1,d1              ; Ok ?
                beq.s send_wait         ; nein,dann warten
                
                ; Byte ausgeben
                move.b (a0)+,2(a1)      ; Byte in ACIA schreiben

                ; Adressen... setzen
                move.l a0,$3f0.w        ; neue Ladeadresse
                subq.l #1,$3f4.w        ; neue L„nge

send_irq_end:   ; Interrupt beenden
                movem.l (sp)+,d0-d1/a0-a1
                bclr #5,$fffffa0f.w     ; und IRQ freigeben
                rte                     ; Ende

       
