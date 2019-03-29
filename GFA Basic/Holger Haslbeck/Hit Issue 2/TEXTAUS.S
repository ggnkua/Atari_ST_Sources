;
; *******************************************
; * PROGRAMM:                               *
; * MELDUNG AUF BILDSCHIRM AUSGEBEN         *
; * und nach Tastendruck zurÅck zum Desktop *
; *******************************************
;
                move.l  #text_0,-(SP)   ; Diesen Text ausgeben
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

;
; **************************
; * Auf Tastendruck warten *
; **************************
;
                move.w  #7,-(SP)        ; Gemdos-Funktion: crawcin
                trap    #1
                addq.l  #2,SP           ; Stack korrigieren
;
; ************************
; * Programm terminieren *
; ************************
;
                move.w  #0,-(SP)        ; Gemdos-Funktion: Pterm
                trap    #1              ; zurÅck zu Gemdos

                DATA
                EVEN
;
;
; ****************************
; * Bildschirmtext gestalten *
; ****************************
;
;

text_0:
                DC.B $1B,$45,$1B,$70
                DC.B 'Beispieltext'
                DC.B $1B,$71
                DC.B $0A        ;›0d,$0a, 'Beispieltext'
                DC.B $0A,$0D,$0A,$0D,'Beispieltext'
                DC.B $0A,$0D,$0A,$1B,$70
                DC.B $0A,'Beispieltext'

