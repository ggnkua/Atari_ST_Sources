; cpxstart.s
; Bei der Erzeugung von CPX-Modulen muû dieser Code anstelle
; von PCSTART.O verwendet werden.
;
; aus: Wir basteln uns ein CPX
;      CPX-Kurs Teil 2
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
.globl cp_head,_FilSysVec, errno
    
.text

cpxstart:
    jmp cpx_init    ; Dieser Sprung ist lebenswichtig!
                    ; er muû am Anfang des Textsegments
                    ; stehen, da XControl dort den Anfang
                    ; des CPX-Moduls vermutet.
.data
; Die Funktion CPX_Save speichert die Werte am Anfang des
; Datensegments. ACHTUNG, es muû genÅgend Platz sein!!!!

cp_head:	dcb.b 512,0	; Default Header

_FilSysVec: dc.l 0	; Diese Variablen werden von Pure C Funktionen
errno:      dc.w 0  ; benîtigt.

.end        
