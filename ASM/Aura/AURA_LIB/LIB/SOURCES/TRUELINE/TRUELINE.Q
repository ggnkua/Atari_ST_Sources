; ============================================================================
; Zeichnet Linien im Falcon High-Colourmodus.
; Die Routinen sind einigermaûen optimiert (2 Stunden Programm !), es ginge
; noch schneller, aber 34 Diagonalen bei 320*240 pro VBL sind ja auch nicht
; ganz schlecht.

; For the english ones: coded in 2 hours ! So not high-end speed, but ok.

; Coded:      08.08.1994   Jochen Knaus
; Version:    1.02                                                
; Update:     Noch am selben Abend !!! Und am nÑchsten Morgen...
; Grund:      Benîtigt fÅr Testzwecke im 3D-System
; Ach so:     PMOD
; Weiter:     Sauschlecht dokumentiert !
; Coderight:  Ω 1994 by Jochen
; Komisch:    Das lÑngste an der Routine ist das Clippen und das das meine ab-
;             solute Lieblingsroutinenart ist, weiû jeder, der meine Polyrout
;             und die Geschichte ihres Clippings kennt...
; Debug:      Meinen Tests nach funktionieren die Linien sowie das Clipping.
;             Die VLine und HLineroutinen werden noch getrennt optimiert !
;             Die steilen Linien sind leicht ungenau, gehen aber nicht Åber
;             die Clippgrenzen hinaus.
; Bemerkung:  Das Clipping kann abgeschalten werden.
; ============================================================================

PMOD          EQU     1

        IFNE  PMOD
              MC68030
              MODUL   "F:\LIB\TRUELINE.INC"
              ORG     0
              OPT     D-,O+

              bra.w   tl                ; Linienroutine
              bra.w   init_tl           ; Initialisierung

              DC.B    'PMOD'
              DC.B    'Truecol.Lines  ',0
              DC.B    'BDCannibal/AURA',0
              DC.B    '089408940102'
              DC.B    '20V--------------'
        ENDIF

clipping:     DS.W    4                 ; { Clippbox
clipp:        DC.B    0                 ; | Clipping an ?
init:         DC.B    0                 ; | Initialisiert ?
scr_off:      DS.W    1                 ; | Bytes / Scan
off_tab:      DS.L    1                 ; } Offsettabelle

; ============================================================================
; Initialisiert Linienroutine, muû aufgerufen werden, ansondsten anulliert die
; Routine sofort jeden Branch, auch mit Unterschrift.

; Clipprahmen:        d0-d3 (alle Werte == 0 -> kein Clipping)
; Screenoffsettab:    a0.l  (Offsets auf Scanlines (.l))
; ============================================================================
init_tl:      pea     (a1)

              lea     clipping(pc),a1
              movem.w d0-d3,(a1)        ; Clipprahmen
              addq.l  #8,a1
              clr.b   (a1)              ; Default: kein Clipping
              or.w    d0,d3
              or.w    d1,d3
              or.w    d2,d3
              tst.w   d3
              sne     (a1)+             ; Clippbox da: Clipping
              st      (a1)+             ; Initialisiert.
              move.l  4(a0),d0          ; Offset zweite Zeile ~ Bytes/Scan
              move.w  d0,(a1)+          ; Bytes / Scan (16 Bit)
              move.l  a0,(a1)           ; Offsettabelle

              move.l  (sp)+,a1
              rts

; ============================================================================
; Zeichnet (inkl Clipping) Linie im Truecolor.

; Koordinaten:        d0-d3
; Farbe:              d4
; Screenadresse:      a0
; ============================================================================
tl:           tst.b   init(pc)          ; Linienroutine Åberhaupt init-
              bne.s   draw_line         ; ialisiert ?

              moveq   #0,d0             ; z-Bit setzen : Fehler
              rts

_rts:         movem.l (sp)+,d5-d6/a1/a6 ; Aufruf: Linie ganz auûerhalb oder
              moveq   #-1,d0            ; nur ein Punkte, deshalb KEIN Error,
              rts                       ; aber N-Flag als Abgrenzung setzen.

draw_line:    movem.l d5-d6/a1/a6,-(sp) ; Geringes Registeraufkommen.

              cmp.w   d0,d2             ; Linie immer von links nach rechts.
              bge.s   no_exg_koo

              exg     d0,d2
              exg     d1,d3

no_exg_koo:   movea.w d4,a6             ; Farbe.

              tst.b   clipp(pc)         ; Clippen ?
              beq.w   no_clipping

              lea     clipping(pc),a1   ; Clippbox (minx/maxx/miny/maxy)

; Beim vertikalen Clippen jeweils beide Endpunkte an beiden RÑndern testen, da
; vertikal keine Richtung festgelegt ist (wie links->rechts horizontal).

              move.w  4(a1),d5          ; clipp_y1

              cmp.w   d5,d1             ; y1 oben raus ?
              bge.s   no_y1

              move.w  d5,d4
              sub.w   d3,d4             ; y2 auch raus ?
              bge.w   _rts              ; ja -> vollstÑndig raus: Error

;               (x2-x1)*(clip-y2)
;    x_neu=x2 + -----------------
;                     (y2-y1)           y_new=clip

              neg.w   d0
              neg.w   d1
              add.w   d2,d0
              add.w   d3,d1
              muls.w  d4,d0
              divs.w  d1,d0
              add.w   d2,d0             ; x_neu
              move.w  d5,d1             ; y_neu

no_y1:        cmp.w   d5,d3             ; y2 oben raus ?
              bge.s   no_y2

              move.w  d5,d4
              sub.w   d1,d4             ; y1 auch raus ?
              bge.w   _rts

              neg.w   d2
              neg.w   d3
              add.w   d0,d2
              add.w   d1,d3
              muls.w  d4,d2
              divs.w  d3,d2
              add.w   d0,d2             ; x_neu
              move.w  d5,d3             ; y_neu

no_y2:        move.w  6(a1),d5          ; Unterer Border checken.
              cmp.w   d5,d1             ; y1 raus ?
              blt.s   nu_y1

              move.w  d5,d4
              sub.w   d3,d4
              ble.w   _rts

              neg.w   d0
              neg.w   d1
              add.w   d2,d0
              add.w   d3,d1
              muls.w  d4,d0
              divs.w  d1,d0
              add.w   d2,d0             ; x_neu
              move.w  d5,d1             ; y_neu

nu_y1:        cmp.w   d5,d3             ; y2 unten raus ?
              blt.s   nu_y2

              move.w  d5,d4
              sub.w   d1,d4
              ble.w   _rts

              neg.w   d2
              neg.w   d3
              add.w   d0,d2
              add.w   d1,d3
              muls.w  d4,d2
              divs.w  d3,d2
              add.w   d0,d2             ; x_neu
              move.w  d5,d3             ; y_neu

nu_y2:        cmp.w   (a1)+,d0          ; Linie links raus ?
              bge.s   n_left_out

              move.w  -(a1),d4
              sub.w   d2,d4             ; Clip-x2
              bgt     _rts              ; x2<Clip -> Linie ganz raus.

;                 (y2-y1)*(clip-x2)
;    y_neu = y2 - -----------------
;                      (x1-x2)           x_new=clip
              neg.w   d1
              add.w   d3,d1             ; y2-y1
              sub.w   d2,d0             ; x1-x2
              muls.w  d4,d1
              divs.w  d0,d1
              neg.w   d1
              add.w   d3,d1             ; y_neu
              move.w  (a1)+,d0          ; x_neu (Clipprahmen)

n_left_out:   cmp.w   (a1)+,d2          ; Rechts raus ?
              ble.s   no_clipping

              move.w  -(a1),d4
              sub.w   d0,d4
              ble.w   _rts

              neg.w   d3
              add.w   d1,d3
              sub.w   d0,d2
              muls.w  d4,d3
              divs.w  d2,d3
              neg.w   d3
              add.w   d1,d3             ; y_neu
              move.w  (a1)+,d2          ; x_neu

no_clipping:  adda.l  ([off_tab.w,pc],d1.w*4),a0    ; Vertikaler Screenoffset.
              move.w  scr_off(pc),d6    ; Zeilenoffset
              sub.w   d0,d2             ; dx = x2-x1 (positiv!)
              sub.w   d1,d3             ; dy = y2-y1
              bge.s   up_down           ; dy > 0 => Linie von oben nach unten
              neg.w   d3                ; |dy|
              neg.w   d6                ; Zeilenoff. neg.=> unten nach oben
up_down:      ext.l   d6                ; "adda.l" schneller als "adda.w"
              ext.l   d2                ; Hi-words lîschen (fÅr 32-Bit Div.)
              ext.l   d3

              cmp.w   d2,d3             ; Liniensteigung > 45 Grad ?
              bge.w   steil             ; dy>dx => Steigung>45

              move.w  d3,d4             ; "Flache" Linie:
              beq.s   no_div1           ; Steigung = (dy*2^16)/dx
              swap    d4                ; (Ergebnis 0.x, Nachkomma 16 Bit)
              clr.w   d4
              divu.l  d2,d4             ; d4.low_word = Nachkomma
no_div1:      move.w  #$8000,d5         ; Additionswert Startkomma
              lea     (a0,d0.w*2),a0    ; Richtige horizontale Stellung...

              move.w  d2,d3             ; dx Punkte setzen: Linie von links
              asr.w   #3,d2             ; nach rechts durchlaufen.
              subq.w  #1,d2
              bmi.s   flachrest         ; (Cacheoptimierte Schleife!)

abgeflacht:   REPEAT
              move.w  a6,(a0)+          ; Punkt setzen
              add.w   d4,d5             ; Nachkommaadd (öberlauf ?)
              bcc.s   *+4               ; Keine vertikale Addition.
              adda.l  d6,a0             ; öberlauf: Zeile hoch oder runter.
              UNTIL   #7
              dbra    d2,abgeflacht

flachrest:    moveq   #7,d0             ; Rest der Linie als aufgelîste
              and.w   d0,d3             ; Schleife zeichnen.
              eor.w   d0,d3
              jmp     (flachre.b,pc,d3.w*8)

flachre:      REPEAT
              move.w  a6,(a0)+
              add.w   d4,d5
              bcc.s   *+4
              adda.l  d6,a0
              UNTIL   #6

t_rts:        movem.l (sp)+,d5-d6/a1/a6
              moveq   #1,d0             ; z-Bit lîschen: Linie gezeichnet.
              rts

steil:        move.l  d2,d4             ; Linie > 45 Grad, Steigung:
              beq.s   no_div2           ; (dy*2^16)/dx
              swap    d4                ; Hier kommt wieder nur ein 0.x Fix-
              clr.w   d4                ; kommawert heraus, aber es wird nicht
              divu.l  d3,d4             ; auf öberlauf getestet, sondern die
              swap    d4                ; x-Koordinate absolut als Offset
                                        ; benutzt.
no_div2:      
; Das Startnachkomma wird auf 0 gesetzt, um nicht durch Fixkommaungenauigkei-
; ten Åber den rechten Rand hinauszugelangen.
              clr.l   d5                ; Standartnachkomma = 0
              move.w  d0,d5             ; Startkoordinate
              moveq   #7,d0             ; Loop-Konstante

              move.w  d3,d2             ; dy-Punkte setzen
              beq.w   _rts
              asr.w   #3,d3
              subq.w  #1,d3
              bmi.s   steilrest

steilloop:    REPEAT
              move.w  a6,(a0,d5.w*2)    ; Punkt setzen
              adda.l  d6,a0             ; NÑchste Zeile (X-Bit unverÑndert!)
              addx.l  d4,d5             ; Neue x-Koordinate
              UNTIL   #7
              dbra    d3,steilloop

steilrest:    and.w   d0,d2             ; X-Bit wird nicht geÑndert!
              eor.w   d0,d2
              jmp     (resteloops.b,pc,d2.w*8)
resteloops:   REPEAT
              move.w  a6,(a0,d5.w*2)
              adda.l  d6,a0
              addx.l  d4,d5
              UNTIL   #6

              movem.l (sp)+,d5-d6/a1/a6
              moveq   #1,d0
              rts
