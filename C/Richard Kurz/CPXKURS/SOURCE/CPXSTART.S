; cpxstart.s
; Bei der Erzeugung von CPX-Modulen muû dieser Code anstelle
; von PCSTART.O verwendet werden.
;
; aus: Wir basteln uns ein CPX
;      CPX-Kurs Teil 1
;      TOS Magazin
;
; (c)1992 by Richard Kurz
; Vogelherdbogen 62
; 7992 Tettnang
;
; Erstellt mit Pure Assembler
;

; Wir geben bekannt.....
.globl cpxstart,cpx_init
.globl shslide,svslide,spopup,errno
    
.text

cpxstart:
    jmp cpx_init    ; Dieser Sprung ist lebenswichtig!
                    ; er muû am Anfang des Textsegments
                    ; stehen, da XControl dort den Anfang
                    ; des CPX-Moduls vermutet.
.data
; Die Funktion CPX_Save speichert die Werte am Anfang des
; Datensegments. ACHTUNG, es muû genÅgend Platz sein!!!!

shslide:    dc.w 16 ; Speicher fÅr hslide
svslide:    dc.w 10 ; Speicher fÅr vslide
spopup:     dc.w 1  ; Speicher fÅr popup

errno:      dc.w 0  ; Diese Variable wird von Pure C Funktionen
                    ; benîtigt.
.end        
