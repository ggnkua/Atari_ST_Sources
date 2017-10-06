; cpxstart.s
; Bei der Erzeugung von CPX-Modulen muû dieser Code anstelle
; von PCSTART.O verwendet werden.
;
; aus: GEM Sound
;      TOS Magazin
;
; (c)1992 by Richard Kurz
; Vogelherdbogen 62
; 7992 Tettnang
; Fido 2:241/7232
;
; Erstellt mit Pure Assembler
;

; Wir geben bekannt.....
.globl cpxstart,cpx_init
.globl errno,sound_inf
    
.text

cpxstart:
    jmp cpx_init    ; Dieser Sprung ist lebenswichtig!
                    ; Er muû am Anfang des Textsegments
                    ; stehen, da XControl dort den Anfang
                    ; des CPX-Moduls vermutet.
.data
; Die Funktion CPX_Save speichert die Werte am Anfang des
; Datensegments. ACHTUNG, es muû genÅgend Platz sein!!!!


sound_inf:  dcb.w 1024,0    ; Puffer fÅr die Voreinstellungen
errno:      dc.w 0          ; Diese Variable wird von Pure-C-Funktionen
                            ; benîtigt.
.end        
