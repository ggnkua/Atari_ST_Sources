; ****************************************************************************
; *                                                                          *
; *   Polygonrandberechnungsroutine.                                         *
; *   - VollstÑndig PC-relativ, <PMOD>-Format.                               *
; *   - Einbindung als "include"-File oder als Objektfile.                   *
; *                                                                          *
; * Coded Dez./Jan. 1993 by Jochen Knaus, BDC of AURA-Production.            *
; * Ver. 3, dritte vollstÑndig neue Rout ! (Ver. 2 in "Mathematica").        *
; *                                                                          *
; *     Coderight (c) 1993/94 AURA Production.                               *
; *                                                                          *
; * VERSION:            3.20                                                 *
; * LETZTES UPDATE:     28.4.1993                                            *
; * LETZTER CHANGE:     27.12.1994                                           *
; * LETZTES BUGFIX:      9.4.1994 (Wegflippen bei rechteckigen Polys)        *
; * CPU:                68020++                                              *
; * ASSEMBLER:          Easy-Ass 4                                           *
; *                                                                          *
; * Bei extrem flachen und gkippten Polygon kann es dank der "addx" Komma-   *
; * behandlung noch zu Fehlern kommen, d.h. die linke Koordinaten sind       *
; * grîûer als die rechten. Maximal 1 Pixel, bei HLine-Rout auszumerzen.     *
; *                                                                          *
; * Bei meinen HLine-Routinen wird dies rechenzeitverlustfrei durchgefÅhrt,  *
; * einzig befindet sich an der Fehlerstelle kein Pixel anstatt eines.       *
; *                                                                          *
; * Das Clipping sollte jetzt auch bei beliebigen Åberbildschirmgroûen Poly- *
; * onen funktionieren (es brauchte ja auch 2 Jahre, bis es soweit war...).  *
; ****************************************************************************

SCR_H           EQU     260     ; max. Screenhîhe bzw. Polygonhîhe
SCR_W           EQU     400     ; max. Screenbreite
SELBSTJUSTIZ    EQU     0       ; Test auf ultraflaches Polygon (0=an)
PMOD_FILE       EQU     0       ; 0 = BinÑrfile im PMOD-Format

POINTS_8        EQU     0       ; 0 = Punkt 8 Bytes, <>0 = 4 Bytes (normal)
SHORT_LP        EQU     0       ; 1: Koordinatenschleifen aufrollen (0=Cachelp)
SL_ANZ          EQU     8       ; Anzahl der kurzen Cacheloops.
SL_SHIFT        EQU     3       ; log2(SL_ANZ)

; 
; Parameter:    a6      - Array mit Nummern der einzelnen Eckpunkte.
;               a5      - Array mit transformierten Eckpunkten.
;               a4      - Adresse rechtes Koordinatenarray.
;               a3      - Adresse linkes Koordinatenarray.
;               d7.w    - Anzahl Eckpunkte (-1)
; Return:       d0.w    - Polygon ganz raus: ( 1 = raus).
;               a2.w    - kleinstes Polygon-y
;               a3.w    - grîûtes Polygon-y
; ( Alle Register werden gecrasht ! ).

; Der Fileheader bei Objektfile:
;               00.w    - bra.s zum Routinenanfang
;               02.w    - Clipping: min_x (X-Koordinate linkes oberes Eck)
;               04.w    -     "   : max_x (     "       rechtes unteres Eck)
;               06.w    -     "   : min_y (Y-Koordinate linkes oberes Eck)
;               08.w    -     "   : max_y (     "       rechtes unteres Eck)
; 

        IFEQ    PMOD_FILE                       ; PMOD erzeugen ?
                MC68030
                OPT     O+,D-
                ORG     0                       ; PC-relativ
                MODUL   "F:\LIB\POLYGON.INC"
        ENDIF

                bra.s   .calc_koords            ; Routine anspringen
                bra.s   .init_clipp

min_x:          dc.w 0                          ; Clippbereich. Muû vom auzurufenden
max_x:          dc.w SCR_W-1                    ; Programm korrekt gesetzt werden.
min_y:          dc.w 0
max_y:          dc.w SCR_H-1
clipplist:      ds.l 4                          ; Buffer fÅr Clipplines. (16Bytes)
aleftys:        dc.l 0                          ; Adresse linkes Koordinatenarray. {
arights:        dc.l 0                          ;    "    rechtes        "          }

        IFEQ    PMOD_FILE
                DC.B    'PMOD'                          ; PMOD-Kennung
                DC.B    'Polygonroutine.',0     ; Modultitel
                DC.B    'BDCannibal/AURA',0     ; Autor
                DC.B    '12921294'                      ; Dez. 92, Update Apr. 93
                DC.B    '032020--'                      ; Version 3.20
                DC.B    '--------'                      ; Ab 68020.
        ENDIF           

.init_clipp:    pea     (a0)                            ; Clipping initialisieren.
                lea     min_x(pc),a0                    ; Werte im d0-d3.
                movem.w d0-d3,(a0)
                move.l  (sp)+,a0
                rts

.calc_koords:   movec   cacr,d0                 ; Polygonkanten berechnen.
                move.l  d0,-(sp)
                moveq   #$11,d0
                movec   d0,cacr

                lea     aleftys(pc),a0          ; um PC-relativ zu bleiben !
                movem.l a3/a4,(a0)              ; Adresse Arrays sichern.

                lea     clipplist+4(pc),a4      ; Buffer fÅr Clippwerte (l.r.)
                lea     min_x(pc),a1            ; Clippwerte.

                move.l  4(a1),d0                ; min_y / max_y

                movea.w d0,a2                   ; kleinstes y im Poly hoch init.
                swap    d0
                movea.w d0,a3                   ; grîûtes y im Poly nieder init.

                move.l  d0,(a4)                 ; bisher keine Randlinie nîtig.
                move.l  d0,-(a4)

line_loop:      move.w  (a6)+,d0                ; Nr. Eckpunkt 1
                move.w  (a6),d2                 ;       "      2

        IFNE    POINTS_8                        ; Normalpunkteformat.
                move.l  (a5,d0.w*4),d0          ; x1/y1
                move.l  (a5,d2.w*4),d2          ; x2/y2
        ELSE                                    ; Punkt + Farbinformation.
                move.l  (a5,d0.w*8),d0          ; x1/y1
                move.l  (a5,d2.w*8),d2          ; x2/y2
        ENDIF

                move.w  d0,d1                   ; y-Koord. P1
                swap    d0                      ; x-Koord. P1
                move.w  d2,d3                   ; y-Koord. P2
                swap    d2                      ; x-Koord. P2

                move.l  arights(pc),a0          ; Linie recht = Default.
                moveq   #0,d6                   ; Rechts im Polygon => d6=0

                cmp.w   d1,d3                   ; Linie von oben nach unten ?
                bgt.s   right_line              ; y2>y1 => Linie rechts.
;               beq.w   _hline                  ; y2=y1 => horizontale Linie.

;               sle     d6                      ; Wenn links im Poly, d6<>0   [4Tz]
                moveq   #-1,d6                  ; [2Tz 68030]

                exg     d0,d2                   ; Koordinatenpaare austauschen.
                exg     d1,d3

                move.l  aleftys(pc),a0          ; auf linkes Koordinatenarray.

; Abfrage ob komplett raus, erst nachdem festgestellt wurde, ob Linie links
; oder rechts im Polygon ist, wegen Clipping.
right_line:     cmp.w   4(a1),d1                ; CLIPPING: Linie oben raus ?
                bge.s   no_c_up

;               (x2-x1)*(clip-y2)
;    x_new=x2 + -----------------
;                     (y2-y1)           y_new=clip

                move.w  4(a1),d4
                sub.w   d3,d4                   ; Clipp-y2
                bpl.w   next_line               ; Linie komplett oben raus ?
                
                neg.w   d0
                add.w   d2,d0                   ; x2-x1
                neg.w   d1
                add.w   d3,d1                   ; y1-y2
                muls.w  d4,d0
                divs.w  d1,d0

                add.w   d2,d0                   ; x_new = x2 + Gesamt.
                move.w  4(a1),d1                ; y_new = Clipprahmen.

no_c_up:        cmp.w   6(a1),d3                ; Linie unten raus ?
                ble.s   end_updo

;               (x2-x1)*(clip-y2)
;    x_new=x2 + -----------------
;                  (y2-y1)           y_new=clip

                move.w  6(a1),d4
                sub.w   d1,d4
                bmi.w   next_line               ; Linie komplett unten raus ?

                neg.w   d2
                add.w   d0,d2
                neg.w   d3
                add.w   d1,d3
                muls.w  d4,d2
                divs.w  d3,d2

                add.w   d0,d2
                move.w  6(a1),d3                ; Linie komplett oben/unten geclippt.

end_updo:       cmp.w   d1,d3                   ; Ergab Clippen eine HLine ?
                beq.w   _hline
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

                move.w  d1,d5                   ; y1 fÅr eventuelle VLine sichern
                neg.w   d1
                add.w   d3,d1                   ; y2 - y1       (2)
                sub.w   d2,d0                   ; x1 - x2       (3)
                muls.w  d4,d1                   ; (1) * (2)
                divs.w  d0,d1                   ; / (3) = (4)
                neg.w   d1
                add.w   d3,d1                   ; y_new = y2 - (4)
                move.w  (a1),d0                 ; x_new=Ausgaberahmen x

                tst.w   d6                      ; Linie links im Polygon ?
                beq.s   no_left1                ; rechts keine VLine gebraucht.

                cmp.w   (a4),d5                 ; FÅr VLine am Clipprand
                bge.s   got_it1                 ; oberer Wert bereits Åberschritten?

                move.w  d5,(a4)

got_it1:        cmp.w   2(a4),d1                ; unterer Wert ?
                ble.s   no_left1

                move.w  d1,2(a4)

no_left1:       cmp.w   2(a1),d2                ; Linie rechts raus ?
                ble.w   end_lr

;               (y2-y1)*(clip-x2)
;    y_new=y2 - -----------------
;                     (x1-x2)           x_new=clip

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

                tst.w   d6                      ; wenn Linie links im Poly wird keine
                bne.w   end_lr                  ; zusÑtzliche VLine gebraucht.

                cmp.w   4(a4),d3                ; wird Åber den Bereich bereits V-
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
;                     (x1-x2)           x_new=clip

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

                tst.w   d6                      ; Linie links im Poly ?
                beq.s   no_left2

                cmp.w   (a4),d3                 ;  sub.w (a4),d3  [schîner, aber um
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
                bmi.w   out_lr

                neg.w   d1
                add.w   d3,d1                   
                sub.w   d2,d0
                muls.w  d4,d1
                divs.w  d0,d1
                neg.w   d1

                add.w   d3,d1                   ; new_y
                move.w  2(a1),d0                ; new_x

                tst.w   d6
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

not_small:      cmp.w   a3,d3                   ; grîûtes y im Polygon ?
                ble.s   _end_clip

                movea.w d3,a3

_end_clip:      
;               cmp2.w  min_y(pc),d1
;               bcc.s   in1
;               illegal
;in1:           cmp2.w  min_x(pc),d3
;               bcc.s   in2
;               illegal
;in2:
                sub.w   d1,d3                   ; dy (HLine schon vorher abgefangen).
;               addq.w  #1,d3                   ; dy+1, 0 zÑhlt auch mit.
                beq.w   hhline                  ; Beim Clippen ver-hlined ?
                ext.l   d3                      ; auf 32 Bit, fÅr "divu.l"

                lea     (a0,d1.w*2),a0          ; a0+2*ky (richtige Arraystelle.)

                sub.w   d0,d2                   ; dx
                bge.w   pl_line                 ; x1<x2 => mit "addx" rechnen.

sub_li:         neg.w   d2                      ; |dx|
;               addq.w  #1,d2                   ; dx+1

;               move.w  (pro_wide.w,pc,d2.w*2),d1
;               swap    d1
;               move.w  d0,d1

                swap    d2                      ; dx * 2^16
                clr.w   d2                      ; unteres Wort lîschen (4 Tz.)
                divu.l  d3,d2                   ; (dx*2^16)/dy  (32 Bit Division !)

;               move.w  d2,d1
;               lsr.w   #1,d1
;               swap    d1
                swap    d2

                move.l  #$80000000,d1 
                move.w  d0,d1                   ; Ganzzahl in d1.low

        IFNE    SHORT_LP
                neg.w   D3                      ; Einsprungoffset errechnen.
                addi.w  #SCR_H,d3               ; Ein Schleifensegment 4 Bytes.
                jmp     (.sub_line.b,PC,d3.w*4) ; in Linienschleife einspringen
.sub_line:
                REPEAT
                move.w  d1,(a0)+
                subx.l  d2,d1
                UNTIL   #255
                REPEAT
                move.w  d1,(a0)+
                subx.l  d2,d1
                UNTIL   #SCR_H-256-1
        ELSE
                move.w  d3,d0                   ; Farbschleife aufgelîst...
                asr.w   #SL_SHIFT,d3
                subq.w  #1,d3                   ; d3 >= 0 : X-Bit gelîscht.
                bmi.s   rest_sub_line
.sub_line:                                      ; Linienschleife links nach
          REPEAT                                ; rechts: zuerst Koordinate
                move.w  d1,(a0)+                ; sichern, dann subtrahieren,
                subx.l  d2,d1                   ; sondst crash bei flachen
          UNTIL #(SL_ANZ-1)                     ; Polygonen !
                dbra    d3,.sub_line

rest_sub_line:  moveq   #SL_ANZ-1,d3            ; X-Bit bleibt erhalten !
                and.w   d3,d0                   ; Restlinie: nur 15 Koords.
                eor.w   d3,d0
                jmp     (.resl.b,pc,d0.w*4)
.resl:  
          REPEAT
                move.w  d1,(a0)+
                subx.l  d2,d1
          UNTIL #(SL_ANZ-2)
        ENDIF
                bra.w   next_line               ; nÑchste Linie

pl_line:
;               move.w  (pro_wide.w,pc,d2.w*2),d1
;               swap    d1
;               move.w  d0,d1

                swap    d2                      ; Dok. s.o.
                clr.w   d2
                divu.l  d3,d2

;               move.w  d2,d1
;               lsr.w   #1,d1
;               swap    d1
                swap    d2

                move.l  #$80000000,d1 
                move.w  d0,d1

        IFNE    SHORT_LP
                neg.w   d3
                addi.w  #SCR_H-1,d3             ; da dy+1 vorher weggelassen !
                jmp     (.add_line.b,PC,d3.w*4)
.add_line:
          REPEAT
                move.w  d1,(a0)+
                addx.l  d2,d1
          UNTIL #255
          REPEAT
                move.w  d1,(a0)+
                addx.l  d2,d1
          UNTIL #SCR_H-256-1

        ELSE
                move.w  d3,d0                   ; Farbschleife aufgelîst...
                asr.w   #SL_SHIFT,d3
                subq.w  #1,d3
                bmi.s   .rest_add_line
.add_line:
          REPEAT
                move.w  d1,(a0)+
                addx.l  d2,d1
          UNTIL #(SL_ANZ-1)
                dbra    d3,.add_line

.rest_add_line: moveq   #SL_ANZ-1,d3
                and.w   d3,d0
                eor.w   d3,d0
                jmp     (.resr.b,pc,d0.w*4)
.resr:  
          REPEAT
                move.w  d1,(a0)+
                addx.l  d2,d1
          UNTIL #(SL_ANZ-2)
        ENDIF

next_line:      dbra    D7,line_loop            ; nÑchste Linie

                cmpa.w  a2,a3                   ; Polygon innerhalb und  sichtbar ?
                bge.s   sichtbar                ; Init: min > max

                movem.w (a4),d0-d3              ; linke und rechte VLine-Koordinaten

                cmp.w   d0,d1                   ; Am linken Rand VLine ?
                blt.w   real_out                ; kein öberhang mîglich.

                cmp.w   d2,d3                   ; Am rechten Rand VLine ?
                blt.w   real_out                ; muû an beiden Seiten sein.

take_it:        cmp.w   d0,d2                   ; grîûere der oberen Koordinaten
                bge.s   take_d2

                move.w  d0,d2

take_d2:        cmp.w   a2,d2                   ; öberhang Åber Restpolygon
                bge.s   touchdown

                movea.w d2,a2

touchdown:      cmp.w   d1,d3                   ; kleinere der unteren Koordinaten
                ble.s   take_d3

                move.w  d1,d3

take_d3:        cmp.w   a3,d3
                ble.s   take_me

                movea.w d3,a3
                bra.s   take_me

sichtbar:       movem.w (a4),d0-d3              ; Existiert Gott ? öber oder unter
;                                               ; dem Polygon ?
                cmp.w   d0,d1                   ; Gott = "Linienloses ClippÅber-
                blt.w   take_me                 ; bleibsel".

                cmp.w   d2,d3                   ; Dok. s.o.
                bge.s   take_it

take_me:        cmpm.w  (a4)+,(a4)+             ; VLine am linken Rand ?
                blt.s   no_left                 ; max_y > min_y (oder Init.werte ?)

                movem.w -4(a4),d1/d3            ; untere/obere Grenze (24 Tz/6 Bytes)

                cmp.w   a2,d1                   ; VLine an Polygonextremas anpassen.
                bge.s   .beiss                  ; Kann bei manchen Polys Vorteil
;                                               ; bringen.
                move.w  a2,d1
.beiss:         cmp.w   a3,d3
                ble.s   .sofa

                move.w  a3,d3

.sofa:          sub.w   d1,d3                   ; Hîhe
                addq.w  #1,d3

                lea     ([aleftys.w,pc],d1.w*2),a0      ; linkes Koo.arr.
                move.w  (a1),d2                 ; Clippwert linker Rand.

        IFNE    SHORT_LP
                neg.w   d3
                addi.w  #SCR_H-1,d3
                jsr     (vline.w,pc,D3.w*2) ; VLine Schleife aufrufen.
        ELSE
                bsr.s   vline
        ENDIF

no_left:        cmpm.w  (a4)+,(a4)+             ; VLine am rechten Rand ?
                blt.s   no_right

                movem.w -4(a4),d1/d3

                cmp.w   a2,d1
                bge.s   n_o

                move.w  a2,d1

n_o:            cmp.w   a3,d3
                ble.s   n_p

                move.w  a3,d3

n_p:            sub.w   d1,d3
                addq.w  #1,d3

                lea     ([arights.w,pc],d1.w*2),a0
                move.w  2(a1),d2                ; rechte Grenze als Koordinate

        IFNE    SHORT_LP
                neg.w   D3
                addi.w  #SCR_H-1,D3
                jsr     (vline.w,pc,d3.w*2)     ; wegen z-Flag kein "jmp" !
        ELSE
                bsr.s   vline
        ENDIF

no_right:       bra.w   leave

vline:  IFNE    SHORT_LP                        ; VLine-Loop fÅr allgememeinen
          REPEAT                                ; Einsatz.
                move.w  d2,(a0)+
          UNTIL #255
          REPEAT
                move.w  d2,(a0)+
          UNTIL #SCR_H-256-1
        ELSE
                move.w  d3,d0
                asr.w   #SL_SHIFT,d3
                subq.w  #1,d3
                bmi.s   rest_va_line
va_line:
          REPEAT
                move.w  d2,(a0)+
          UNTIL #(SL_ANZ-1)
                dbra    d3,va_line

rest_va_line:   moveq   #SL_ANZ-1,d3
                and.w   d3,d0
                eor.w   d3,d0
                jmp     (.resva.b,pc,d0.w*2)
.resva: 
          REPEAT
                move.w  d2,(a0)+
          UNTIL #(SL_ANZ-2)                     
        ENDIF
                rts
                
leave:  IFEQ    SELBSTJUSTIZ                    ; "Polygon-(fast)-Linientest" ?
                movem.l aleftys(pc),a0/a1

                lea     (a0,a2.w*2),a0
                lea     (a1,a2.w*2),a1

                move.w  a3,d1
                sub.w   a2,d1                   ; dy

          REPEAT                                ; Auf 1/2 und 1/4 der Hîhe die
                asr.w   #1,d1                   ; Polygonkoordinaten testen,
                move.w  (a0,d1.w*2),d0          ; wenn nicht min. 1 Pixel Ab-
                cmp.w   (a1,d1.w*2),d0          ; stand, dann zu flach um zu
                bge.w   only_line               ; zeichnen.
          UNTIL #(2-1)
        ENDIF

                move.l  (sp)+,d0                ; Alten Cachezustand.
                movec   d0,cacr
                moveq   #0,d0                   ; Alles klar, Z-Flag setzen.
                rts

only_line:
real_out:       move.l  (sp)+,d0
                movec   d0,cacr
                moveq   #-1,d0                  ; Polygon raus, Z-Flag lîschen.
                rts

out_lr:         cmp.w   d0,d2                   ; kleineres x untersuchen.
                bge.s   sorted_lr

                exg     d0,d2

sorted_lr:      cmp.w   (a1),d0                 ; Linie links oder rechts raus ?
                bgt.s   rec_out

                tst.w   d6                      ; Linie rechts im Polygon ?
                beq.w   next_line

                cmp.w   (a4),d1                 ; VLine-Werte entspr. anpassen !
                bge.s   .equal1

                move.w  d1,(a4)                 ; in Extremwerttabelle eintragen.

.equal1:        cmp.w   2(a4),d3                ; neues grîûtes y ?
                ble.w   next_line

                move.w  d3,2(a4)
                bra.w   next_line

rec_out:        tst.w   d6                      ; Linie links im Poly ?
                bne.w   next_line

                cmp.w   4(a4),d1
                bge.s   equal2

                move.w  d1,4(a4)

equal2:         cmp.w   6(a4),d3
                ble.w   next_line

                move.w  d3,6(a4)
                bra.w   next_line

_hline:         cmp.w   d0,d2
                bgt.s   .big
                exg     d0,d2
.big:           move.w  (a1),d3
                cmp.w   d3,d2
                blt.w   next_line
                cmp.w   d3,d0                           ; HLine: Clippen
                bge.s   n_red
                move.w  d3,d0
n_red:          move.w  2(a1),d3
                cmp.w   d3,d0                           ; keine Checkung auf Max.korrds
                bgt.w   next_line                       ; da noch zweite Linie da sein
;                                                       ; muû.
                cmp.w   d3,d2
                ble.s   hhline2
                move.w  d3,d2

hhline:         cmp.w   d0,d2
                bgt.s   .okok
                exg     d0,d2
.okok:
hhline2:        move.l  aleftys(pc),a0                  ; HLinewert als Startkoordinate
                move.w  d0,(a0,d1.w*2)                  ; ins linkes Koordinatenarray
                move.l  arights(pc),a0
                move.w  d2,(a0,d1.w*2)

                bra.w   next_line

_vline:         cmp.w   (a1),d2                         ; VLine links oder rechts
                ble.w   sorted_lr                       ; raus ?
                cmp.w   2(a1),d2
                bge.w   sorted_lr

                cmp.w   a2,d1                           ; auf Maximalkoords checken
                bge.s   nu

                move.w  d1,a2

nu:             cmp.w   a3,d3
                ble.s   nd

                move.w  d3,a3

nd:             lea     (a0,d1.w*2),a0                  ; richtiger Arraystand.

                sub.w   d1,d3                           ; VLinelÑnge = dy

        IFNE    SHORT_LP
                neg.w   d3
                addi.w  #SCR_H-1,d3
                jsr     (vline.w,pc,d3.w*2)             ; VLine-Koordinate in d2.
        ELSE
                move.w  d3,d0
                asr.w   #SL_SHIFT,d3
                subq.w  #1,d3
                bmi.s   .rest_v_line
.v_line:
          REPEAT
                move.w  d2,(a0)+
          UNTIL #(SL_ANZ-1)
                dbra    d3,.v_line

.rest_v_line:   moveq   #SL_ANZ-1,d3
                and.w   d3,d0
                eor.w   d3,d0
                jmp     (.resv.b,pc,d0.w*2)
.resv:  
          REPEAT
                move.w  d2,(a0)+
          UNTIL #(SL_ANZ-1)
        ENDIF
                bra.w   next_line

        IFNE    0
pro_wide:
PRO_ONE         SET     0
        REPEAT
                DC.W    $ffff-(((PRO_ONE*65536)/scr_w))
PRO_ONE         SET     PRO_ONE+1
        UNTIL   #255
        REPEAT
                DC.W    $ffff-(((PRO_ONE*65536)/scr_w))
PRO_ONE         SET     PRO_ONE+1
        UNTIL   #(scr_w-256)-1
        ENDIF