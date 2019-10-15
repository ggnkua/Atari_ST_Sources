start:          move.w  #$4E71,match    ; Opcode fr >>NOP<<

match:          bsr.s   print           ; hier steht sp„ter >>NOP<<

end:            clr.w   -(SP)           ; Pterm0
                trap    #1              ; fin

print:          pea     text(PC)        ; Textadresse auf Stack
                move.w  #9,-(SP)        ; Cconws()
                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; Stack aufr„umen

                rts                     ; zurck

                DATA

text:           DC.B 'Beispiel fr Prefetch...',13,10,0
                END
