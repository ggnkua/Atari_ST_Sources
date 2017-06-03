; This file contains the Gouraud-Interpolated-Filling-Source. You can remove
; the used divu.l each line totally easy, just make a 1/dx tab and reduce to
; a mulu.w.
; (C) Copyright 1995 by Jochen Knaus, AURA.


; ננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננ
;    GOURAUD-Routine: Berechnet Randkoordinaten und interpoliert Farben am
;                     Polygonrand.

;       Infos bzw. Einbindung s. Polygonroutine.

;       Polygonroutine Dezember 1992.
;       Shadinganpassungen Mai 1994 Jochen Knaus (BDCannibal/AURA/Independent)
;       Coderight (c) 1993/94 AURA Production.

; VERSION:              1.07 (Basierend auf Polygonroutine 3.11)
; SHADINGSTART:         April 1994
; LETZTES UPDATE:       07.08.1994
; MEGAVLINCLIPPBUGFIX:  12.07.1994
; ZWEITER GIGCLIPPBUG:  11.08.1994 (TESTCODE wurde im Source VERGESSEN!)
; WEITERES:             27.12.1994
; ALLERLETZTER BUG:     06.05.1995 (Farben bei HLines...)
; CPU:                  68020++ (CACHE!)
; ASSEMBLER:            Easy-Ass 4
; NANU:                 Alle Schleifen jetzt total cacheoptimiert !!!
; FORMAT:               PMOD oder Includefile (MC68030)

; BEMERKUNGEN:
; - Polygonbehandlung (fast (*1)) analog normaler Polygonroutine.
; - Clipping (vertikal und horizontal (*2)) integriert.
; - Screenh”henhandler immer noch sehr unflexibel eingebaut, aber wer bringt
;   auf dem Falc”nchen schon Gourauds im Interlacedmode ?
; - Punktformat „nderte sich im Bezug auf "normale" Polygonroutine.
; - Headeroffsets „nderten sich ebenfalls !!!

; (*1): Einige Registeroptimierungen muten entfernt werden, da durch die
;       beiden Farbwerte die Regis ganz sch”n knapp wurden, da im Nachhinein
;       die Polygonroutine auf Version 3.2x aufgepeppt wurde, liegen kleine
;       Differenzen in der Polygonbehandlung.
; (*2): Das vertikale Clipping kann ohne extremen Zeitaufwand nicht korrekt
;       durchgezogen werden, da die Farbwerte am Rand nicht nur von der Poly-
;       gonkante abh„ngen, sonder auch von der gegenberliegenden Seite. Es
;       mte also jede Scanline beim Fllen geclippt werden: langsam. Die
;       Farbinterpolation wird nun durchgezogen, auch wenn die Line auerhalb
;       ist. Das Poly wird dadurch ungenau und sogar falsch geshadet, aber es
;       f„llt in 90% der F„lle wohl nicht soooo st”rend auf.
; ננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננ

SCR_H           EQU 256         ; max. Screenh”he bzw. Polygonh”he
selbstjustiz    EQU 1           ; Test auf ultraflaches Polygon (0=an)
binaerfile      EQU 0           ; PC-relatives File (0=an)

; ננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננ
; Parameter:    a6      - Array mit Nummern der einzelnen Eckpunkte.
;               a5      - Array mit transformierten Eckpunkten.
;               a4      - Adresse rechtes Koordinatenarray.
;               a3      - Adresse linkes Koordinatenarray.
;               a2      - Adresse rechtes Farbenarray.
;               a1      - Adresse linkes Farbenarray.
;               d7.w    - Anzahl Eckpunkte (-1)
; Return:       d0.w    - Polygon ganz raus: ( 1 = raus).
;               a2.w    - kleinstes Polygon-y
;               a3.w    - gr”tes Polygon-y
; ( Alle Register werden gecrasht ! ).

; Der Fileheader bei Bin„rfile (absolut zur Adresse 0 (PC-relativ)):
;               00.w    - <bra.w> zur Clippinginitialisierung
;               04.w    - <bra.s> zur Berechnungsroutine
;               06.w    - Clipping: min_x (X-Koordinate linkes oberes Eck)
;               08.w    -     "   : max_x (     "       rechtes unteres Eck)
;               10.w    -     "   : min_y (Y-Koordinate linkes oberes Eck)
;               12.w    -     "   : max_y (     "       rechtes unteres Eck)
; ננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננ

; ננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננ
; ACHTUNG:      Anderes Eckpunktformat wie normale Polygonroutine:
;               0.w     - x                     => 8 Bytes / Eckpunkt.
;               2.w     - y
;               4.w     - Farbwert Ecke
;               6.w     - reserviert

; Die Gr”e der Eckpunktbuffer mu genau verdoppelt werden, hinter den Koo-
; rdinaten liegen jetzt die Farbwerte:
;       KOORDS_LINKS:   DS.W    SCR_H           ; {
;       FARBEN_LINKS:   DS.W    SCR_H           ; }
;       KOORDS_RECHTS:  DS.W    SCR_H           ; {
;       FARBEN_RECHTS:  DS.W    SCR_H           ; }
; ננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננננ

        IFEQ    binaerfile                      ; PC-relatives File erzeugen ?
                MC68030
                OPT     D-,O-
                ORG     0
                MODUL   "F:\LIB\GOURAND.INC"
        ENDIF
                bra.w   init_clipping           ; Clipping setzen.
                bra.s   calc_koords             ; Routine anspringen

min_x:          DC.W    0                       ; Clippbereich. Mu vom auzurufenden
max_x:          DC.W    319                     ; Programm korrekt gesetzt werden.
min_y:          DC.W    0
max_y:          DC.W    239
clipplist:      DS.L    8                       ; Buffer fr Clipplines. (16Bytes)
lleftys:        DC.L    0                       ; Adresse linkes Farbwertarray.    {
lrights:        DC.L    0                       ;    "    rechtes        "         }
aleftys:        DC.L    0                       ;    "    linkes Koordinatenarray. {
arights:        DC.L    0                       ;    "    rechtes        "         }
farben:         DS.W    2                       ; Farbwertbuffer.
lire:           DS.W    1                       ; Polygon links oder rechts ?

                DC.B    'PMOD'
                DC.B    'Gouraudrandber.',0
                DC.B    'BDCannibal/AURA',0
                DC.B    '04941294'
                DC.B    '010720--'              ; Nur 68020 ben”tigt.
                DC.B    '--------'

; ========================================================================
; Berechnet Randkoordinaten und interpoliert Farben an den Kanten entlang.
; Parameter s. Header.
; ========================================================================
calc_koords:    movec   cacr,d0
                move.l  d0,-(sp)                ; Alten Cachestatus retten.
                moveq   #$11,d0
                movec   d0,cacr                 ; Datencache aus.

                lea     lleftys(pc),a0          ; um PC-relativ zu bleiben !
                movem.l a1-a4,(a0)              ; Adressen der Arrays sichern.
                lea     min_x(pc),a1

                move.l  a6,a0
                move.w  d7,d6
total_out:      move.w  (a6)+,d0
                move.w  (a6),d2
                move.l  (a5,d0.w*8),d0          ; P1(x1/y1)
                move.l  (a5,d2.w*8),d2          ; P2(x2/y2)

                cmp2.w  4(a1),d0
                bcc.s   poly_in
                cmp2.w  4(a1),d2
                bcc.s   poly_in

                swap    d0
                swap    d2

                cmp2.w  (a1),d0
                bcc.s   poly_in
                cmp2.w  (a1),d2
                bcc.s   poly_in
                dbra    d6,total_out

                move.l  (sp)+,d0
                movec   d0,cacr
                moveq   #-1,d0
                rts

poly_in:        move.l  a0,a6

                lea     clipplist+4(pc),a4      ; Buffer fr Clippwerte (l.r.)
                move.l  min_y(pc),d0            ; min_y / max_y
                movea.w d0,a2                   ; kleinstes y im Poly hoch init.
                swap    d0
                movea.w d0,a3                   ; gr”tes y im Poly nieder init.

                move.l  d0,(a4)                 ; bisher keine Randlinie n”tig.
                move.l  d0,-(a4)
                clr.w   -(sp)                   ; Koordinatenbuffer reservieren

line_loop:      move.w  (a6)+,d0                ; Nr. Eckpunkt P1
                move.w  (a6),d2                 ;       "      P2

                move.w  (4.b,a5,d0.w*8),d4      ; Farbe P1
                move.l  (a5,d0.w*8),d0          ; P1(x1/y1)
                move.w  (4.b,a5,d2.w*8),d5      ; Farbe P2
                move.l  (a5,d2.w*8),d2          ; P2(x2/y2)

                move.w  d0,d1                   ; y-Koord. P1
                swap    d0                      ; x-Koord. P1
                move.w  d2,d3                   ; y-Koord. P2
                swap    d2                      ; x-Koord. P2

                move.l  arights(pc),a0          ; Linie recht = Default.
                moveq   #0,d6                   ; Rechts im Polygon => d6=0

                cmp.w   d1,d3                   ; Linie von oben nach unten ?
;               beq.w   gr_hline                ; HLines...
                bgt.s   right_line              ; y2>y1 => Linie rechts.

                moveq   #-1,d6                  ; Flag: links [schneller als <sle>]

                exg     d0,d2                   ; Koordinatenpaare austauschen.
                exg     d1,d3
                exg     d4,d5                   ; Farbwerte tauschen.

                move.l  aleftys(pc),a0          ; auf linkes Koordinatenarray.

right_line:     lea     lire(pc),a1
                move.w  d6,(a1)

                lea     farben(pc),a1           ; (PC-relativ bleiben)
                move.w  d4,(a1)+                ; Farben buffern.
                move.w  d5,(a1)

                lea     min_x(pc),a1            ; Clipprahmen.

; Abfrage ob komplett raus, erst nachdem festgestellt wurde, ob Linie links
; oder rechts im Polygon ist, wegen Clipping.
                cmp.w   4(a1),d1                ; CLIPPING: Linie oben raus ?
                bge.s   no_c_up

;               (x2-x1)*(clip-y2)
;    x_new=x2 + -----------------
;                     (y2-y1)           y_new=clip

                move.w  4(a1),d6
                sub.w   d3,d6                   ; Clipp-y2
                bpl.w   next_line               ; Linie komplett oben raus ?

                neg.w   d1
                add.w   d3,d1                   ; y1-y2

                neg.w   d0
                add.w   d2,d0                   ; x2-x1
                muls.w  d6,d0
                divs.w  d1,d0

                neg.w   d4                      ; Farbeninterpolation auch cl.
                add.w   d5,d4                   ; c2-c1
                muls.w  d6,d4
                divs.w  d1,d4
                add.w   d5,d4                   ; c1new

                add.w   d2,d0                   ; x_new = x2 + Gesamt.
                move.w  4(a1),d1                ; y_new = Clipprahmen.

no_c_up:        cmp.w   6(a1),d3                ; Linie unten raus ?
                ble.s   end_updo

;               (x2-x1)*(clip-y2)
;    x_new=x2 + -----------------
;                  (y2-y1)           y_new=clip

                move.w  6(a1),d6
                sub.w   d1,d6
                bmi.w   next_line               ; Linie komplett unten raus ?

                neg.w   d2
                add.w   d0,d2
                neg.w   d3
                add.w   d1,d3                   ; Farben brauchen unten nicht
                muls.w  d6,d2                   ; geclippt zu werden...
                divs.w  d3,d2
                add.w   d0,d2
                move.w  6(a1),d3                ; Linie komplett oben/unten geclippt.

end_updo:       move.w  d1,d6                   ; y1 sichern
                move.w  d3,(sp)                 ; y2    "

                cmp.w   d0,d2                   ; Von links nach rechts oder wa ?
                beq.w   _vline                  ; VLines bereits hier abfangen.
                blt.w   rec_lin                 ; Zuerst links und rechts clippen !

                cmp.w   (a1),d0                 ; Linie links raus ?
                bge.s   no_left1

;                 (y2-y1)*(clip-x2)
;    y_new = y2 - -----------------
;                      (x1-x2)           x_new=clip

                move.w  (a1),d4                 ; Clippwert
                sub.w   d2,d4                   ; Clipp - x2    (1)
                bpl.w   out_lr                  ; Linie komplett raus ?

                move.w  d1,d5                   ; y1 fr eventuelle VLine sichern
                neg.w   d1
                add.w   d3,d1                   ; y2 - y1       (2)
                sub.w   d2,d0                   ; x1 - x2       (3)
                muls.w  d4,d1                   ; (1) * (2)
                divs.w  d0,d1                   ; / (3) = (4)
                neg.w   d1
                add.w   d3,d1                   ; y_new = y2 - (4)
                move.w  (a1),d0                 ; x_new=Ausgaberahmen x

                tst.b   lire(pc)                ; Linie links im Polygon ?
                beq.s   no_left1                ; rechts keine VLine gebraucht.

                cmp.w   (a4),d5                 ; Fr VLine am Clipprand
                bge.s   got_it1                 ; oberer Wert bereits berschritten?

                move.w  d5,(a4)

got_it1:        cmp.w   2(a4),d1                ; unterer Wert ?
                ble.s   no_left1

                move.w  d1,2(a4)

no_left1:       cmp.w   2(a1),d2                ; Linie rechts raus ?
                ble.w   end_lr

;                 (y2-y1)*(clip-x2)
;    y_new = y2 - -----------------
;                      (x1-x2)           x_new = clip

                move.w  2(a1),d4
                cmp.w   d4,d0                   ; x1 auch raus ?
                bge.w   out_lr

                move.w  d3,d5
                sub.w   d2,d4
                sub.w   d1,d3
                neg.w   d2
                add.w   d0,d2
                muls.w  d4,d3
                divs.w  d2,d3
                neg.w   d3
                add.w   d5,d3
                move.w  2(a1),d2

                tst.b   lire(pc)                ; wenn Linie links im Poly wird keine
                bne.w   end_lr                  ; zus„tzliche VLine gebraucht.

                cmp.w   4(a4),d3                ; wird ber den Bereich bereits V-
                bge.w   got_it2                 ; Line gezogen ?

                move.w  d3,4(a4)

got_it2:        cmp.w   6(a4),d5
                ble.w   end_lr

                move.w  d5,6(a4)
                bra.w   end_lr

rec_lin:        cmp.w   (a1),d2                 ; Linie von rechts nach links.
                bge.s   no_left2

;               (y2-y1)*(clip-x2)
;    y_new=y2 - -----------------
;                     (x1-x2)           x_new = clip

                move.w  d3,d5
                move.w  (a1),d4

                cmp.w   d4,d0
                ble.w   out_lr

                sub.w   d2,d4                   ; Clip - x2
                sub.w   d1,d3                   ; y2 - y1
                neg.w   d2
                add.w   d0,d2                   ; x1 - x2
                muls.w  d4,d3
                divs.w  d2,d3
                neg.w   d3
                add.w   d5,d3
                move.w  (a1),d2

                tst.w   lire(pc)                ; Linie links im Poly ?
                beq.s   no_left2

                cmp.w   (a4),d3                 ;  sub.w (a4),d3  [sch”ner, aber um
                bge.s   got_it3                 ;  bpl.s got_it3   4-8 Tz langsamer]

                move.w  d3,(a4)                 ;  add.w d3,(a4)

got_it3:        cmp.w   2(a4),d5
                ble.s   no_left2

                move.w  d5,2(a4)

no_left2:       cmp.w   2(a1),d0                ; Linie rechts raus ?
                ble.s   end_lr

;                 (y2-y1)*(clip-x2)
;    y_new = y2 - -----------------
;                      (x1-x2)           x_new=clip

                move.w  d1,d5
                move.w  2(a1),d4
                sub.w   d2,d4
                ble.w   out_lr

                neg.w   d1
                add.w   d3,d1                   
                sub.w   d2,d0
                muls.w  d4,d1
                divs.w  d0,d1
                neg.w   d1
                add.w   d3,d1                   ; new_y
                move.w  2(a1),d0                ; new_x

                tst.w   lire(pc)
                bne.s   end_lr

                cmp.w   4(a4),d5
                bge.s   got_it4

                move.w  d5,4(a4)

got_it4:        cmp.w   6(a4),d1
                ble.s   end_lr

                move.w  d1,6(a4)

end_lr:         cmp.w   a2,d1                   ; kleinstes y im Polygon ?
                bge.s   not_small

                movea.w d1,a2

not_small:      cmp.w   a3,d3                   ; gr”tes y im Polygon ?
                ble.s   _end_clip

                movea.w d3,a3

_end_clip:      sub.w   d1,d3                   ; dy
                beq.w   gr_hline
                ext.l   d3                      ; auf 32 Bit, fr "divu.l"

                lea     (SCR_H*2.w,a0,d6.w*2),a1        ; Farbenarray
                lea     (a0,d1.w*2),a0          ; a0+2*ky (richtige Arraystelle.)
                movem.w farben(pc),d4-d5        ; Farben c1, c2.

                neg.w   d6                      ; dc (vor Clipping fr
                add.w   (sp),d6                 ; Farbinterpolation).
                bgt.s   n_zero3
                moveq   #1,d6
n_zero3:        ext.l   d6

                sub.w   d0,d2                   ; dx (Differenz x-Koordinate)
                beq.w   _vline                  ; x1=x2 => Vertikale
                bgt.w   pl_line                 ; x1<x2 => mit "addx" rechnen.

sub_li:         neg.w   d2                      ; |dx|

; --- Farbinterpolationsrichtung (links-rechts) und Steigung bestimmen ---

                clr.w   -(sp)
                sub.w   d4,d5                   ; dc (Farbendifferenz)
                beq.s   c_vline1
                bpl.s   add_col_mi              ; Farben addieren

                not.w   (sp)
                neg.w   d5

add_col_mi:     swap    d5                      ; d5.low = 0 (movem.w bei pos. Zahl)
                divs.l  d6,d5
                swap    d5                      ; Additionsfarbwert.

                move.l  #$80000000,d1           ; Nachkomma vorsetzen.
                move.w  d4,d1
                move.l  d1,d4

c_vline1:       swap    d2                      ; dx * 2^16
                clr.w   d2                      ; unteres Wort l”schen (4 Tz.)
                divu.l  d3,d2                   ; (dx*2^16)/dy  (32 Bit Division !)
                swap    d2

;               moveq   #-1,d1                  ; Nachkomma berechnen
;               sub.l   d2,d1                   ; X-Bit fr Akt 1 vorsetzen
                move.l  #$80000000,d1           ; Nachkomma vorsetzen.
                move.w  d0,d1                   ; Ganzzahl in d1.low

                tst.w   (sp)+                   ; Colourline +/-
                bne.s   sub_col_mi
                tst.l   d5                      ; Farben: VLine ?
                bne.s   no_vline1
                bsr     col_vertical            ; VLine.
                bra.s   was_vline1
sub_col_mi:     bsr     col_sub
                bra.s   was_vline1
no_vline1:      bsr     col_add                 ; Farbenschleife einspringen
was_vline1:     move.w  d3,d0                   ; Farbschleife aufgel”st...
                asr.w   #3,d3
                subq.w  #1,d3
                bmi.s   sub_li_rest
sub_li_lp:                                      ; Linienschleife links nach
        REPEAT                                  ; rechts: zuerst Koordinate
                move.w  d1,(a0)+                ; sichern, dann subtrahieren,
                subx.l  d2,d1                   ; sondst crash bei flachen
        UNTIL   #7                              ; Polygonen !
                dbra    d3,sub_li_lp

sub_li_rest:    moveq   #7,d3                   ; X-Bit bleibt erhalten !
                and.w   d3,d0                   ; Restlinie: nur 15 Koords.
                eor.w   d3,d0
                jmp     (sl_re_lp.b,pc,d0.w*4)
sl_re_lp:       
        REPEAT
                move.w  d1,(a0)+
                subx.l  d2,d1
        UNTIL   #6
                bra.w   next_line

col_add:        addq.w  #1,d6
                move.w  d6,d0                   ; Farbenschleife "addx", L„nge
                asr.w   #3,d6                   ; in d6.w
                subq.w  #1,d6
                bmi.s   cadd_li_rest
cadd_li_lp:
        REPEAT
                move.w  d4,(a1)+
                addx.l  d5,d4
        UNTIL   #7
                dbra    d6,cadd_li_lp

cadd_li_rest:   moveq   #7,d6
                and.w   d6,d0                   ; Restlinie: nur 15 Koords.
                eor.w   d6,d0
                jmp     (cal_re_lp.b,pc,d0.w*4)
cal_re_lp:      
        REPEAT
                move.w  d4,(a1)+
                addx.l  d5,d4
        UNTIL   #6
                rts

col_sub:        addq.w  #1,d6
                move.w  d6,d0                   ; Farbenschleife "subx" analog
                asr.w   #3,d6                   ; <col_add>
                subq.w  #1,d6
                bmi.s   csub_li_rest
csub_li_lp:
        REPEAT
                move.w  d4,(a1)+
                subx.l  d5,d4
        UNTIL   #7
                dbra    d6,csub_li_lp

csub_li_rest:   moveq   #7,d6
                and.w   d6,d0                   ; Restlinie: nur 15 Koords.
                eor.w   d6,d0
                jmp     (csl_re_lp.b,pc,d0.w*4)
csl_re_lp:      
        REPEAT
                move.w  d4,(a1)+
                subx.l  d5,d4
        UNTIL   #6
                rts

col_vertical:   move.w  d6,d0                   ; Farbinterpolation:
                asr.w   #3,d6                   ; Vertikale Linie...
                subq.w  #1,d6
                bmi.s   cvert_li_rest
cvert_li_lp:
        REPEAT
                move.w  d4,(a1)+
        UNTIL   #7
                dbra    d6,cvert_li_lp

cvert_li_rest:  moveq   #7,d6
                and.w   d6,d0
                eor.w   d6,d0
                jmp     (cvl_re_lp.b,pc,d0.w*2)
cvl_re_lp:      
        REPEAT
                move.w  d4,(a1)+
        UNTIL   #6
                rts

pl_line:        swap    d2                      ; Dok. s.o.
                clr.w   d2
                divu.l  d3,d2
                swap    d2

                clr.w   -(sp)
                sub.w   d4,d5
                beq.s   c_vline2
                bpl.s   add_col_pl

                not.w   (sp)
                neg.w   d5

add_col_pl:     swap    d5                      ; Dok. s.o.
                divs.l  d6,d5
                swap    d5

                move.l  #$80000000,d1           ; Nachkomma vorsetzen.
                move.w  d4,d1
                move.l  d1,d4

c_vline2:       move.l  #$80000000,d1
                move.w  d0,d1

                tst.w   (sp)+
                bne.s   sub_col_pl
                tst.l   d5
                bne.s   no_vline2

                bsr.w   col_vertical
                bra.s   was_vline2
sub_col_pl:     bsr.w   col_sub
                bra.s   was_vline2
no_vline2:      bsr.w   col_add
was_vline2:     move.w  d3,d0                   ; Linienschl. s.o.
                asr.w   #3,d3
                subq.w  #1,d3
                bmi.s   add_li_rest
add_li_lp:
        REPEAT
                move.w  d1,(a0)+
                addx.l  d2,d1
        UNTIL   #7
                dbra    d3,add_li_lp

add_li_rest:    moveq   #7,d3
                and.w   d3,d0                   
                eor.w   d3,d0
                jmp     (al_re_lp.b,pc,d0.w*4)
al_re_lp:       
        REPEAT
                move.w  d1,(a0)+
                addx.l  d2,d1
        UNTIL   #6

next_line:      dbra    D7,line_loop            ; N„chste Randlinie

                lea     min_x(pc),a1            ; Maximalkoordinaten.

                cmpa.w  a2,a3                   ; Polygon innerhalb und  sichtbar ?
                bge.s   sichtbar

                movem.w (a4),d0-d3              ; linke und rechte VLine-Koordinaten

                cmp.w   d0,d1                   ; Am linken Rand VLine ?
                blt.w   real_out                ; kein berhang m”glich.

                cmp.w   d2,d3                   ; Am rechten Rand VLine ?
                blt.w   real_out                ; mu an beiden Seiten sein.

take_it:        cmp.w   d0,d2                   ; gr”ere der oberen Koordinaten
                bge.s   take_d2

                move.w  d0,d2

take_d2:        cmp.w   a2,d2                   ; berhang ber Restpolygon
                bge.s   touchdown

                movea.w d2,a2

touchdown:      cmp.w   d1,d3                   ; kleinere der unteren Koordinaten
                ble.s   take_d3

                move.w  d1,d3

take_d3:        cmp.w   a3,d3
                ble.s   take_me

                movea.w d3,a3
                bra.s   take_me

sichtbar:       movem.w (a4),d0-d3              ; Existiert Gott ? ber oder unter
;                                               ; dem Polygon ?
                cmp.w   d0,d1                   ; Gott = "Linienloses Clippber-
                blt.w   take_me                 ; bleibsel".

                cmp.w   d2,d3                   ; Dok. s.o.
                bge.s   take_it

take_me:        cmpm.w  (a4)+,(a4)+             ; VLine am linken Rand ?
                blt.s   no_left                 ; max_y > min_y (oder Init.werte ?)

                move.l  aleftys(pc),a0          ; linkes Koordinatenarray
                movem.w -4(a4),d1/d3            ; untere/obere Grenze (24 Tz/6 Bytes)

                cmp.w   a2,d1                   ; VLine an Polygonextremas anpassen.
                bge.s   beiss                   ; Kann bei manchen Polys Vorteil
                                                ; bringen.
                move.w  a2,d1
beiss:          cmp.w   a3,d3
                ble.s   sofa

                move.w  a3,d3
sofa:           sub.w   d1,d3                   ; dy (H”he bzw. L„nge VLine)
                add.w   d1,d1                   ; a0 += d1.w*2
                adda.w  d1,a0
                move.w  (a1),d2                 ; Clippwert linker Rand.
                bsr.w   v_line

no_left:        cmpm.w  (a4)+,(a4)+             ; VLine am rechten Rand ?
                blt.s   no_right

                move.l  arights(pc),a0          ; analog links.
                movem.w -4(a4),d1/d3

                cmp.w   a2,d1
                bge.s   n_o
                move.w  a2,d1
n_o:            cmp.w   a3,d3
                ble.s   n_p
                move.w  a3,d3
n_p:            sub.w   d1,d3                   ; dy
                add.w   d1,d1                   ; a0 += 2*d1
                adda.w  d1,a0
                move.w  2(a1),d2                ; Rechte Grenze als Koordinate
                bsr.w   v_line
no_right:       
leave:
        IFEQ    selbstjustiz                    ; Polygon (fast) Linie ?
                movem.l aleftys(pc),a0/a1

                move.w  a2,d0                   ; sollten Koordinaten gr”er oder
                lea     (a0,d0.w*2),a0          ; gleich sein, ist das Polygon so
                lea     (a1,d0.w*2),a1          ; flach, das sich ein Zeichnen nicht

                move.w  a3,d1                   ; lohnt.
                sub.w   d0,d1                   ; dy

                move.w  (a0),d0                 ; Clippingungenauigkeiten machen sich
                cmp.w   (a1),d0                 ; in der ersten und letzten Zeile be-
                bgt.w   only_line               ; merkbar.

                move.w  (-2.b,a0,d1.w*2),d0 ; Gleichheit der Koords sagt hier
                cmp.w   (-2.b,a1,d1.w*2),d0 ; gar nichts aus.
                bgt.w   only_line

                asr.w   #2,d1                   ; L„nge vierteln.

                move.w  (a1,d1.w*2),d0          ; Abstand bei 1/4 und bei 1/2 der L„nge
                sub.w   (a0,d1.w*2),d0          ; mindestens 1 Pixel !
                ble.s   only_line

                move.w  (a1,d1.w*4),d0          ; Sondst ist Polygon so flach, da sich
                sub.w   (a0,d1.w*4),d0          ; ein Zeichnen eh nicht lohnt.
                ble.s   only_line
        ENDIF

                addq.l  #2,sp
                move.l  (sp)+,d0
                movec   d0,cacr                 ; Alten Cachestatus zurck.
                moveq   #0,d0                   ; Alles klar, Z-Flag setzen.
                rts

only_line:
real_out:       addq.l  #2,sp
                move.l  (sp)+,d0
                movec   d0,cacr
                moveq   #-1,d0                  ; Polygon raus, Z-Flag l”schen.
                rts

; Polygonkante war komplett links oder rechts auerhalb.
out_lr:         cmp.w   d0,d2                   ; Kleineres x untersuchen.
                bge.s   sorted_lr

                move.w  d2,d0                   ; Gr”eres x nicht gebraucht.

sorted_lr:      cmp.w   (a1),d0                 ; Linie links oder rechts raus ?
                bgt.s   rec_out

                lea     ([lleftys.w,pc],d6.w*2),a1      ; Linkes Farbenarray.
                move.w  (sp),d0                         ; pop y2
                bsr.w   colpolate                       ; Farben berechnen.

                tst.w   lire(pc)                ; Linie rechts im Polygon ?
                beq.w   next_line

                cmp.w   (a4),d1                 ; VLine-Werte entspr. anpassen !
                bge.s   equal1

                move.w  d1,(a4)                 ; in Extremwerttabelle eintragen.

equal1:         cmp.w   2(a4),d3                ; neues gr”tes y ?
                ble.w   next_line

                move.w  d3,2(a4)
                bra.w   next_line

rec_out:        lea     ([lrights.w,pc],d6.w*2),a1
                move.w  (sp),d0                 ; pop y2
                bsr.w   colpolate               

                tst.w   lire(pc)                ; Linie links im Poly ?
                bne.w   next_line

                cmp.w   4(a4),d1
                bge.s   equal2

                move.w  d1,4(a4)

equal2:         cmp.w   6(a4),d3
                ble.w   next_line

                move.w  d3,6(a4)
                bra.w   next_line

; Farbinterpolation fr komplett auerhalb liegende Linien.
; Bemerkungen s. Header.
colpolate:      neg.w   d6                      ; Farben interpolieren, falls
                add.w   d0,d6                   ; Linie ganz auerhalb.
                bgt.s   n_zero3o
                moveq   #1,d6
n_zero3o:       ext.l   d6

                movem.w farben(pc),d4-d5        ; Farben holen.
                sub.w   d4,d5                   ; dc (Farbendifferenz)
                beq.w   col_vertical            ; Vline (inkl. <rts>)
                bpl.s   add_col_mio             ; Farben addieren

                neg.l   d5
                swap    d5                      ; d5.low = 0 (movem.w bei pos. Zahl)
                divs.l  d6,d5
                swap    d5                      ; Additionsfarbwert.

                move.l  #$80000000,d0
                move.w  d4,d0
                move.l  d0,d4
                bra.w   col_sub                 ; inkl. <rts>

add_col_mio:    swap    d5
                divs.l  d6,d5
                swap    d5                      ; Additionsfarbwert.

                move.l  #$80000000,d0
                move.w  d4,d0
                move.l  d0,d4
                bra.w   col_add                 ; Additionsrout (inkl. <rts>)

_vline:         clr.w   d4                      ; VLine auerhalb.
                cmp.w   (a1),d2                 ; Horizontales Clippen,
                bge.s   no_l_v
                not.w   d4                      ; Schneller als <SLT>
                move.w  (a1),d2                 ; (Sollten sie ganz auerhalb
no_l_v:         cmp.w   2(a1),d2                ;  sein, kann es nicht den
                ble.s   no_r_v                  ;  Clipplines berlassen wer-
                move.w  2(a1),d2                ;  den, wegen der Farbinterp.)
                not.w   d4

no_r_v:         tst.w   d4                      ; Nur wenn VLine innerhalb,
                bne.s   nd                      ; auf Extremas testen.

                cmp.w   a2,d1                   ; Maximalkoords checken.
                bge.s   nu
                move.w  d1,a2
nu:             cmp.w   a3,d3
                ble.s   nd
                move.w  d3,a3

nd:             lea     (a0,d1.w*2),a0          ; richtiger Arraystand.
                lea     SCR_H*2(a0),a1          ; Farbarray.

                sub.w   d1,d3                   ; VLinel„nge = dy
                ble.w   next_line               ; Null„nge: nix !

                ext.l   d3
                movem.w farben(pc),d4-d5
                sub.w   d4,d5                   ; dc
                beq.s   col_vl_vl
                swap    d5
                divs.l  d3,d5
                swap    d5
                ori.l   #$80000000,d4

col_vl_vl:      move.w  d3,d6                   ; Farbroutpara
                tst.l   d5
                bne.s   no_vl_vl

                bsr.w   col_vertical            ; Farbvline
                bsr.s   v_line                  ; Koordinatenvline.
                bra.w   next_line

no_vl_vl:       bsr.w   col_add                 ; Farben berechnen.
                bsr.s   v_line                  ; Koordinaten.
                bra.w   next_line

v_line:         move.w  d3,d0                   ; Cacheschleife...
                asr.w   #3,d3                   ; Vertikale Linie...
                subq.w  #1,d3                   ; Fr Koordinaten...
                bmi.s   vert_li_rest

vert_li_lp:
        REPEAT
                move.w  d2,(a0)+
        UNTIL   #7
                dbra    d3,vert_li_lp

vert_li_rest:   moveq   #7,d3
                and.w   d3,d0
                eor.w   d3,d0
                jmp     (vl_re_lp.b,pc,d0.w*2)

vl_re_lp:       
        REPEAT
                move.w  d2,(a0)+
        UNTIL   #6
                rts

gr_hline:       cmp2.w  4(a1),d1                ; HLine vertikal auerhalb ?
                bcs.w   next_line                       

                movem.w farben(pc),d4-d5        ; Farben wieder holen.

                cmp.w   d0,d2
                bge.s   no_exg_col

                exg     d0,d2
                exg     d4,d5

no_exg_col:     move.w  (a1),d3
                cmp.w   d3,d0                   ; Horizontal Clippen.
                bgt.s   nlh_out                 ; Linker Rand
                cmp.w   d3,d2
                blt.w   next_line
                
                move.w  d3,d0
nlh_out:        move.w  2(a1),d3                ; Rechter Rand
                cmp.w   d3,d2
                ble.s   nrh_out
                cmp.w   d3,d0
                bgt.w   next_line
                
                move.w  d3,d2
nrh_out:        movea.l arights(pc),a0
                move.w  d2,(a0,d1.w*2)
                move.w  d5,(SCR_H*2.w,a0,d1.w*2)
                movea.l aleftys(pc),a0
                move.w  d0,(a0,d1.w*2)
                move.w  d4,(SCR_H*2.w,a0,d1.w*2)
                bra.w   next_line

; ========================================================================
; bernimmt Clippingwerte vom Hauptprogramm.
; Methode etwas mehr proper als direktes Schreiben in Routine via Offsets.
; ========================================================================
init_clipping:  pea     (a1)
                lea     min_x(pc),a1
                move.l  (a0)+,(a1)+             ; min/max x
                move.l  (a0)+,(a1)+             ; min/max y
                move.l  (sp)+,a1
                rts 
