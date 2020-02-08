;KAPA5.TOS
;ASM5.S
;
;
REPEAT:  ;Label
;
; Hier wÅrde jetzt ein Programmteil kommen
;
          CMP.W  #100,D0 ; CMP CoMPare - vergleiche 100 mit
                         ; dem Inhalt von D0
          BNE.S  REPEAT  ; Branch if Not Equal, verzweige wenn
                         ; ungleich
;******* QUIT **********
END

