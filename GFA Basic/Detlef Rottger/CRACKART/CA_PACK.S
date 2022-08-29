
; CRACK ART Kompressionsroutine fÅr Bilddaten (CA?)
; Copyright Ω Detlef Rîttger 04.03.1990

; GFA-Aufruf: LÑnge%=C:CA_COMPRESS%( l:Quelle, l:Ziel )

; Kompressions-Codes:
; Byte                   = unkomprimiertes Byte
; ESC ESC                = ein ESC Byte
; ESC Anzahl-1 Byte      = Anzahl gleiche Bytes
; ESC 0 Anzahl-1 Byte    = Anzahl gleiche Bytes (nîtig, falls Anzahl-1=ESC)
; ESC 1 Mult Rest-1 Byte = 256 * Mult + Rest gleiche Bytes
; ESC 2 Mult Rest-1      = 256 * Mult + Rest DELTA Bytes
; ESC 2 0                = Bildende

; Komprimiertes Image:
; ESC.b DELTA.b OFFSET.w Komprimierte_Bilddaten... ESC 2 0

                TEXT

                movem.l d1-a6,-(sp)

                movem.l 60(sp),a0-a1    ; Quelle/Ziel
                movea.l 64(sp),a1       ; Zieladresse

                movea.l a1,a2           ; Platz fÅr die BytehÑufigkeit vorbereiten
                move.w  #255,d0
init:           clr.w   (a2)+
                dbra    d0,init

                movea.l a0,a2           ; BytehÑufigkeit zÑhlen
                move.w  #31999,d0       ; 32000 Bytes pro Bildschirm
zaehl:          clr.w   d1
                move.b  (a2)+,d1        ; Byte vom Quellbildschirm
                add.w   d1,d1
                addq.w  #1,0(a1,d1.w)   ; wortweise reicht
                dbra    d0,zaehl

; Das seltenste Byte finden, von hinten suchen, damit die Wahrscheinlichkeit,
; daû das ESC Byte mit dem Anzahl-ZÑhler Åbereinstimmt, geringer wird
; (ESC 0 Anzahl-1 Byte) soll so selten wie mîglich auftreten

                movea.l a1,a2           ; Minimum finden
                lea     512(a2),a2      ; an das Ende der ZÑhler
                move.w  #32500,d1       ; Minimum vorbelegen
                move.w  #252,d0         ; Bytes 0,1,2 sind reservierte Codes
minimum:        move.w  -(a2),d2
                cmp.w   d1,d2           ; mit bisherigem Minimum vergleichen
                bge.s   nextmin         ; das erste Minimum behalten
                move.w  d0,d3           ; ZÑhler merken
                move.w  d2,d1           ; neues Minimum merken
                beq.s   minend          ; d1=0 kein kleinerer Wert moeglich
nextmin:        dbra    d0,minimum
minend:         addq.w  #3,d3           ; das ist das Esc Byte
                move.w  d3,d7           ; ESC Byte merken

                movea.l a1,a2           ; Maximum finden
                move.w  #-1,d1          ; Maximum vorbelegen
                move.w  #255,d0
maximum:        move.w  (a2)+,d2
                cmp.w   d1,d2           ; mit bisherigem Maximum vergleichen
                ble.s   nextmax         ; bei gleichhÑufigen Bytes das erste nehmen
;                                         damit ESC und DELTA niemals gleich sein koennen
                move.w  d0,d3           ; ZÑhler merken
                move.w  d2,d1           ; neues Maximum merken
nextmax:        dbra    d0,maximum
                neg.w   d3
                addi.w  #255,d3         ; das ist das DELTA Byte
                move.w  d3,d6           ; DELTA Byte merken


; =================================== Hier beginnt der Kompressionsalgorithmus

                movea.l 60(sp),a0       ; Quelladresse
                lea     32000(a0),a2    ; Endadresse

                move.w  #32000,d4       ; VergleichslÑnge
                lea     offset(pc),a6   ; Offsetliste

while:          movea.l (a6)+,a5        ; Offset holen
                cmpa.l  #0,a5
                beq.s   endwhile        ; Offset=0 ist Abbruchkriterium
                cmpa.l  #-1,a5
                beq.s   endprg          ; -1 ist Programmende

                movem.l 60(sp),a0/a3    ; Quelle/Ziel
                movea.l a0,a1           ; Workadresse
                move.b  d7,(a3)+        ; ESC auf Zielbildschirm merken
                move.b  d6,(a3)+        ; DELTA uebertragen
                move.w  a5,(a3)+        ; Offset
                move.w  #4,d3           ; LÑnge des komprimierten Bildes
;                                         ESC.b + DELTA.b + Offset.w
                move.l  a5,d0           ; Offset als
                subq.w  #1,d0           ; DurchlaufzÑhler

mainloop:       tst.w   d0
                bmi.s   endcode         ; neuer Offset
                move.b  (a1),d1         ; erstes Byte holen
                clr.w   d2              ; gleiche Bytes zÑhlen
testloop:                               ; NÑchste Adresse errechnen
                adda.l  a5,a1           ; Offset addieren
                cmpa.l  a2,a1           ; Hinter dem Bildschirmende ?
                blt.s   nextok          ; wenn nicht, dann weiter
                addq.l  #1,a0           ; sonst Quelladresse einen weiter
                movea.l a0,a1           ; und neue Workadresse
                subq.w  #1,d0           ; ein öberschlag
                bmi.s   compress        ; Ende der Kompression anzeigen
nextok:
                cmp.b   (a1),d1
                bne.s   compress        ; Reihe abgebrochen
                addq.w  #1,d2
                bra.s   testloop

endcode:        addq.w  #1,d3           ; Code: ESC 2 0  (Endekennung)
                cmp.w   d4,d3
                bge.s   while
                move.b  d7,(a3)+        ; ESC
                addq.w  #1,d3
                cmp.w   d4,d3
                bge.s   while
                move.b  #2,(a3)+        ; 2
                addq.w  #1,d3
                cmp.w   d4,d3
                bge.s   while
                clr.b   (a3)+           ; 0

                move.w  d3,d4           ; neue LÑnge
                move.l  a5,d5           ; Offset merken
                bra.s   while           ; und weiter

endwhile:
                cmp.w   #32000,d4
                bge.s   endprg
                move.w  #32000,d4
                lea     shortest(pc),a6
                move.l  d5,(a6)
                move.l  #-1,4(a6)
                bra.s   while

endprg:         moveq   #0,d0
                move.w  d4,d0           ; LÑnge des komprimierten Bildes

                movem.l (sp)+,d1-a6
                rts


; ========================================================= compress
; In d1.b ist das Byte, in d2.w die Anzahl
compress:
                tst.w   d0
                bpl.s   intern
                cmp.b   d6,d1           ; DELTA
                beq.s   endcode

intern:         cmp.b   d7,d1
                bne.s   noesc

compesc:        addq.w  #1,d3           ; Code: ESC ESC
                cmp.w   d4,d3
                bge     while           ; nÑchste Kompression
                move.b  d7,(a3)+
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  d7,(a3)+
                dbra    d2,compesc      ; LÑnge erhîhen
                bra     mainloop        ; und weiter

noesc:          cmp.w   #2,d2
                bgt.s   more            ; mehr als 3 Bytes gleich
uncomp:         addq.w  #1,d3           ; Code: Byte
                cmp.w   d4,d3
                bge     while
                move.b  d1,(a3)+        ; Byte
                dbra    d2,uncomp
                bra     mainloop

more:           cmp.w   #255,d2
                bgt.s   evenmore
                addq.w  #1,d3           ; Code: ESC Anzahl-1 Byte
                cmp.w   d4,d3           ; oder: ESC 0 Anzahl-1 Byte
                bge     while
                move.b  d7,(a3)+        ; ESC
                cmp.b   d7,d2           ; zufÑllig Anzahl-1 = ESC ?
                bne.s   morenorm
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                clr.b   (a3)+           ; 00
morenorm:       addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  d2,(a3)+        ; Anzahl-1
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  d1,(a3)+        ; Byte
                bra     mainloop

evenmore:       cmp.b   d6,d1           ; DELTA ?
                beq.s   moredelta
                addq.w  #1,d3           ; Code: ESC 1 Mult Rest-1 Byte
                cmp.w   d4,d3
                bge     while
                move.b  d7,(a3)+        ; ESC
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  #1,(a3)+        ; 1
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                movea.w d2,a4           ; sichern
                lsr.w   #8,d2           ; div 256
                move.b  d2,(a3)+        ; Mult
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.w  a4,d2
                and.w   #255,d2
                move.b  d2,(a3)+        ; Rest-1
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  d1,(a3)+        ; Byte
                bra     mainloop

moredelta:      addq.w  #1,d3           ; Code: ESC 2 Mult Rest-1
                cmp.w   d4,d3
                bge     while
                move.b  d7,(a3)+
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  #2,(a3)+
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                movea.w d2,a4           ; sichern
                lsr.w   #8,d2           ; div 256
                move.b  d2,(a3)+
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.w  a4,d2
                and.w   #255,d2
                move.b  d2,(a3)+
                bra     mainloop

                DATA
                EVEN

offset:         DC.L 160,8,80,1,2,4,320,640,480,0

shortest:       DC.L 0,-1

                END
