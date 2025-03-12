;************************************************
;* Falcon-Sound-Oszilloskop         Version 1.0 *
;* Autor: Stefan Bock        fÅr MAXON Computer *
;* erstellt mit Pure-C Version Feb 26 1992      *
;* CURVE.S : Assembler-Routine fÅr Bildaufbau   *
;************************************************

              .EXPORT zeichne_bild;

NULL_LINKS    EQU 47   ; Nullage linker Kanal
NULL_RECHTS   EQU 127  ; Nullage rechter Kanal
SCHRITTWEITE  EQU 24

              .TEXT

; Register retten, Stackparameter einlesen
zeichne_bild: movem.l d0-d7/a0-a6, -(sp)
              move.l  64(sp), a0 ; Zeilenliste
              move.l  68(sp), a1 ; Hintergrund
              move.l  72(sp), a2 ; Audiodaten

; Hintergrundbild ins Gesamtbild kopieren
kopiere_hntr: move.l  (a0), a6
              move.w  #208,d7
.schleife:    movem.l (a1)+,d0-d6/a5
              movem.l d0-d6/a5, (a6)
              lea     32(a6),a6
              dbra    d7, .schleife

; Oszilloskopkurve ins Bild odern
zeichne_krv:  clr.w   d7         ; Wortoffset
.schleife1:   move.w  #$8000, d6 ; linkes Pixel
              move.w  #15,d5     ; 16 Pixel
.schleife2:   move.b  (a2),d2    ; linker Kanal
              move.b  2(a2),d3   ; rechter Kanal
              ext.w   d2     ; vorzeichenrichtig
              ext.w   d3     ; erweitern
              asr.b   #2,d2  ; Wertebereich
              asr.b   #2,d3  ; anpassen
              add.w   #NULL_LINKS, d2
              add.w   #NULL_RECHTS, d3
; statt der folgenden vier Befehle ... :
              lsl.w   #2,d2
              lsl.w   #2,d3
              move.l  0(a0, d2.w), a5
              move.l  0(a0, d3.w), a6
; ... kann man auch nur zwei Befehle verwenden:
;             move.l  0(a0, d2.w * 4), a5
;             move.l  0(a0, d3.w * 4), a6
; dann ist die Routine nur ab der 68020er CPU
; verwendbar (dafÅr aber etwas schneller)
              or.w    d6, 0(a5, d7.w)
              or.w    d6, 0(a6, d7.w)
              lea     SCHRITTWEITE(a2),a2
              lsr.w   #1, d6
              dbra    d5, .schleife2
              addq.w  #2,d7
              cmp.w   #38,d7
              bne     .schleife1

; das war's schon
fertig:       movem.l (sp)+, d0-d7/a0-a6
              rts