; cpxstart.s
; Bei der Erzeugung von CPX-Modulen muû dieser Code anstelle
; von PCSTART.O verwendet werden.
;
; aus: Wir basteln uns ein CPX
;      CPX-Kurs Teil 3
;      TOS Magazin
;
; (c)1992 by Richard Kurz
; Vogelherdbogen 62
; 7992 Tettnang
; Fido 2:241/7232.5
;
; Erstellt mit Pure Assembler
;

; Wir geben bekannt.....
.globl cpxstart,cpx_init
.globl cdown,_FilSysVec, errno
    
.text

cpxstart:
    jmp cpx_init    ; Dieser Sprung ist lebenswichtig!
                    ; er muû am Anfang des Textsegments
                    ; stehen, da XControl dort den Anfang
                    ; des CPX-Moduls vermutet.
.data
; Die Funktion CPX_Save speichert die Werte am Anfang des
; Datensegments. ACHTUNG, es muû genÅgend Platz sein!!!!

cdown:		dc.w 1	; Flag fÅr die Autoabschaltung

_FilSysVec: dc.l 0	; Diese Variablen werden von Pure C Funktionen
errno:      dc.w 0  ; benîtigt.

.end        
