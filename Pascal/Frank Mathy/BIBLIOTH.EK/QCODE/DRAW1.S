* Frame-Routine
* Zeichnet Rahmen mit den Eckpunkten (x1,y1), (x2,y1), (x2,y2) und (x1,y2)
* Aufruf: fframe(x1,y1,x2,y2,farbe,logbase,clipping)

.text
.xdef _fframe
_fframe:        movem.l d0-d3/d7/a0-a1,-(a7) *Register retten
                movea.l 46(a7),a1       *Clipping-Feld
                move.w  40(a7),d7       *Farbe laden

                movea.l 42(a7),a0       *Logbase
                move.w  32(a7),d0       *x1 laden
                move.w  34(a7),d1       *y1 laden
                move.w  38(a7),d2       *y2 laden
                bsr     vl_main         *Linie von (x1,y1) nach (x1,y2)

                movea.l 42(a7),a0       *Logbase
                move.w  36(a7),d0       *x2 laden
                move.w  34(a7),d1       *y1 laden
                move.w  38(a7),d2       *y2 laden
                bsr     vl_main         *Linie von (x2,y1) nach (x2,y2)

                movea.l 42(a7),a0       *Logbase
                move.w  32(a7),d0       *x1 laden
                move.w  36(a7),d1       *x2 laden
                move.w  34(a7),d2       *y1 laden
                bsr     hline           *Linie von (x1,y1) nach (x2,y1)

                movea.l 42(a7),a0       *Logbase
                movea.l 46(a7),a1       *Clipping-Feld
                move.w  32(a7),d0       *x1 laden
                move.w  36(a7),d1       *x2 laden
                move.w  38(a7),d2       *y2 laden
                bsr     hline           *Linie von (x1,y2) nach (x2,y2)

                movem.l (a7)+,d0-d3/d7/a0-a1 *Register zurÅckholen
ff_end:         rts

* VLine-Routine fÅr C/Pascal
* Zeichnet vertikale Linien von (x1,y1) nach (x1,y2)
* Aufruf: fvline(x1,y1,y2,farbe,logbase,clipping)

.text
.xdef _fvline
_fvline:        movem.l d0-d3/d7/a0-a1,-(a7) *Register retten
                move.w  32(a7),d0       *x1 laden
                move.w  34(a7),d1       *y1 laden
                move.w  36(a7),d2       *y2 laden
                move.w  38(a7),d7       *Farbe laden
                movea.l 44(a7),a1       *Zeiger auf Clipping-Feld
                movea.l 40(a7),a0       *Logbase laden
                bsr.s   vl_main         *Routine aufrufen
                movem.l (a7)+,d0-d3/d7/a0-a1 *Register holen
                rts

vl_main:        cmp.w   0(a1),d0        *x1 < Clip_x1 ?
                blt.s   vl_end          *Ja --> Ende
                cmp.w   4(a1),d0        *x1 > Clip_x2 ?
                bgt.s   vl_end          *Ja --> Ende
                cmp.w   d2,d1           *y1 <= y2 ?
                ble.s   vl_j1           *Ja --> Weiter
                exg     d1,d2           *y1 <--> y2
vl_j1:          cmp.w   6(a1),d1        *y1 > clip_y2 ?
                bgt.s   vl_end          *Ja --> Ende
                cmp.w   2(a1),d2        *y2 < clip_y1 ?
                blt.s   vl_end          *Ja --> Ende
                cmp.w   2(a1),d1        *y1 < clip_y1 ?
                bge.s   vl_j2           *Nein --> Weiter
                move.w  2(a1),d1        *y1 = clip_y1
vl_j2:          cmp.w   6(a1),d2        *y2 > clip_y2 ?
                ble.s   vl_j3           *Nein --> Weiter
                move.w  6(a1),d2        *y2 = clip_y2
vl_j3:          sub.w   d1,d2           *d2 = y2-y1 (Zahl der Zeilen - 1)
                mulu    #160,d1         *y_Offset ausrechnen
                adda.l  d1,a0           *y_Offset zu Logbase addieren
                move.w  d0,d3           *d3 = x0
                and.l   #$fff0,d0       *Bits 0 bis 3 und 16 bis 31 lîschen
                asr.w   #1,d0           *Durch 2 teilen
                adda.l  d0,a0           *x_Offset hinzuaddieren

                and.w   #$f,d3          *Bitnummer
                eor.w   #$f,d3          *Invertieren
vl_j4:          clr.w   d0              *ZÑhler
vl_j5:          move.w  (a0),d1         *Wort aus Bildschirmspeicher holen
                btst    d0,d7           *Farbbit testen
                bne.s   vl_j6           *Gesetzt --> Weiter
                bclr    d3,d1           *Bit lîschen
                bra.s   vl_j7           *Weiter
vl_j6:          bset    d3,d1           *Bit setzen
vl_j7:          move.w  d1,(a0)+        *Wort in Bildschirmspeicher schreiben
                addq.w  #1,d0           *ZÑhler erhîhen
                cmp.w   #4,d0           *ZÑhler == 4 ?
                bne.s   vl_j5           *ZurÅck in die Schleife

                adda.l  #152,a0         *Zeiger auf nÑchste Zeile
                dbra    d2,vl_j4        *ZeilezÑhler erniedrigen, ggf. zurÅck

vl_end:         rts                     *Ende

* FÅllkreis/Fillcircle-Routine fÅr C/Pascal
* Aufruf: fpcircle(x0,y0,r,farbe,logbase,clipping)

.text
.xdef _fpcircle
_fpcircle:      movem.l d0-d7/a0-a1,-(a7)
                tst.w   48(a7)          *Radius = 1 ?
                beq.s   pc_j3           *Ja --> Ende
                move.w  50(a7),d7       *Farbe
                movea.l 56(a7),a1       *Clipping
                clr.w   d4              *x-Startwert = 0
                move.w  48(a7),d5       *y-Startwert = Radius
                bpl.s   pc_j0           *Radius positiv --> Weiter
                neg.w   d5              *Negieren
pc_j0:          move.w  d5,d6           *ZÑhler
                subq.w  #1,d6           *ZÑhler-1

pc_j1:          tst.w   d6              *Teste ZÑhler
                bpl.s   pc_j2           *Positiv --> Weiter
pc_j1b:         subq.w  #1,d5           *y_Wert erniedrigen

                movea.l 56(a7),a1       *Clipping
                movea.l 52(a7),a0       *Logbase
                movem.w d3-d4,-(a7)     *retten
                move.w  48(a7),d0       *d0 = x0
                move.w  d0,d1           *d1 = x0
                sub.w   d4,d0           *d0 = x0 - x_Wert
                add.w   d4,d1           *d1 = x0 + x_Wert
                move.w  50(a7),d2       *d2 = y0
                movem.w d0-d2,-(a7)     *retten
                sub.w   d5,d2           *d2 = y0 - y_Wert
                bsr     hline           *Horizontale Linie ziehen

                movem.w (a7)+,d0-d2     *zurÅckholen
                movea.l 60(a7),a1       *Clipping
                movea.l 56(a7),a0       *Logbase
                add.w   d5,d2           *d2 = y0 + y_Wert
                bsr     hline           *Horizontale Linie ziehen

                movem.w (a7)+,d3-d4     *zurÅckholen

                add.w   d5,d6           *ZÑhler + y_Wert
                add.w   d5,d6           *ZÑhler + y_Wert

                tst.w   d5              *y_Wert = 0 ?
                beq.s   pc_j3           *Ja --> Ende

                tst.w   d6              *Teste ZÑhler, ob negativ
                bmi.s   pc_j1b          *Ja --> ZurÅck

pc_j2:          sub.w   d4,d6           *ZÑhler - x_Wert
                sub.w   d4,d6           *ZÑhler - x_Wert
                subq.w  #1,d6           *ZÑhler - 1
                addq.w  #1,d4           *x_Wert + 1
                bra.s   pc_j1           *ZurÅck

pc_j3:          movem.l (a7)+,d0-d7/a0-a1 *Register zurÅckholen
                rts                     *RÅckkehr

* Rechteck C/Pascal-Binding
* Aufruf: fbox(x1,y1,x2,y2,farbe,logbase,clipping)
* <x1>, <y1>, <x2>, <y2> und <farbe> sind Integerzahlen
* <logbase> ist ein Zeiger auf den logischen Bildschirmstart
* <clipping> ist ein Zeiger auf das Clipping-Feld

.text
.xdef _fbox
_fbox:          movem.l d0-d5/d7/a0-a1,-(a7) *Register retten

                movem.w 40(a7),d0-d3    *Koordinaten laden
                movea.l 54(a7),a1       *Clipping-Feld

                cmp.w   d1,d3           *y1 < y2 ?
                bgt.s   fb_t1           *Ja --> Weiter
                exg     d1,d3           *Vertauschen
fb_t1:          cmp.w   d0,d2           *x1 < x2 ?
                bgt.s   fb_t2           *Ja --> Weiter
                exg     d0,d2           *Vertauschen
fb_t2:          cmp.w   0(a1),d2        *clip-x1 > x2 ?
                blt.s   fb_ret          *Ja --> Ende
                cmp.w   4(a1),d0        *clip-x2 < x1 ?
                bgt.s   fb_ret          *Ja --> Ende
                cmp.w   2(a1),d3        *clip-y1 > y2 ?
                blt.s   fb_ret          *Ja --> Ende
                cmp.w   6(a1),d1        *clip-y2 < y1 ?
                bgt.s   fb_ret          *Ja --> Ende
                cmp.w   0(a1),d0        *clip-x1 <= x1 ?
                bge.s   fb_t3           *Ja --> Weiter
                move.w  0(a1),d0        *x1 == clip-x1
fb_t3:          cmp.w   2(a1),d1        *clip-y1 <= y1 ?
                bge.s   fb_t4           *Ja --> Weiter
                move.w  2(a1),d1        *y1 == clip-y1
fb_t4:          cmp.w   4(a1),d2        *clip-x2 >= x2 ?
                ble.s   fb_t5           *Ja --> Weiter
                move.w  4(a1),d2        *x2 == clip-x2
fb_t5:          cmp.w   6(a1),d3        *clip-y2 >= y2 ?
                ble.s   fb_t6           *Ja --> Weiter
                move.w  6(a1),d3        *y2 == clip-y2

fb_t6:          movem.w d0-d3,40(a7)    *Koordinaten schreiben

                move.w  42(a7),d5       *y-Scanline-Zaehler
fb_j1:          move.w  d5,d2           *y setzen
                move.w  40(a7),d0       *x1 setzen
                move.w  44(a7),d1       *x2 setzen
                move.w  48(a7),d7       *Farbe
                movea.l 50(a7),a0       *Logbase
                bsr.s   hl_t3           *Aufrufen
                addq.w  #1,d5           *y-Zaehler erhoehen
                cmp.w   46(a7),d5       *d5>y2 ?
                bls.s   fb_j1           *Nein --> Zurueck

fb_ret:         movem.l (a7)+,d0-d5/d7/a0-a1 *Register zurueckholen
                rts


* H-Line C/Pascal-Binding
* Aufruf: fhline(x1,y1,x2,farbe,logbase,clipping)
* <x1>, <y1>, <x2> und <farbe> sind Integerzahlen
* <logbase> ist ein Zeiger auf den logischen Bildschirmstart
* <clipping> ist ein Zeiger auf das Clipping-Feld

.text
.xdef _fhline
_fhline:        movem.l d0-d4/d7/a0-a1,-(a7) *Retten

                move.w  36(a7),d0       *x1 holen
                move.w  38(a7),d2       *y1 holen
                move.w  40(a7),d1       *x2 holen
                move.w  42(a7),d7       *Farbe holen
                movea.l 44(a7),a0       *Logbase holen
                movea.l 48(a7),a1       *Clipping-Feld
fh_j2:          bsr.s   hline           *Routine aufrufen

fh_exit:        movem.l (a7)+,d0-d4/d7/a0-a1 *Zurueckholen
                rts

* H-Line-Routine, testet+korrigiert Koordinaten mit Clipping!
* d0 = x1 , d1 = x2 , d2 = y2 , d7 = Farbe
* a0 = Logische Bildschirmbasis, a2 = Zeiger auf Clipping-Feld (x1/y1/x2/y2)

hline:          cmp.w   2(a1),d2        *Clip-y1 > d2 ?
                blt     hl_ret          *Ja --> Ende
                cmp.w   6(a1),d2        *Clip-y2 < d2 ?
                bgt     hl_ret          *Ja --> Ende
                cmp.w   d0,d1           *x2 >= x1 ?
                bge.s   hl_t1           *Ja --> Weiter
                exg     d0,d1           *x1 <--> x2
hl_t1:          cmp.w   4(a1),d0        *d0 > Clip-x2 ?
                bgt     hl_ret          *Ja --> Ende
                cmp.w   0(a1),d1        *d1 < Clip-x1 ?
                blt     hl_ret          *Ja --> Ende
                cmp.w   0(a1),d0        *x1 < Clip-x1 ?
                bge.s   hl_t2           *Nein --> Weiter
                move.w  0(a1),d0        *d0 == Clip-x1
hl_t2:          cmp.w   4(a1),d1        *x2 > Clip-x2
                bls.s   hl_t3           *Nein --> Weiter
                move.w  4(a1),d1        *x2 == Clip-x2

* Hier Einsprung, wenn kein Test auf Koordinaten

hl_t3:          and.w   #$f,d7          *nur Bits 0 bis 3
                move.w  d0,-(a7)        *x1 retten
                move.w  d1,d3           *x2 kopieren
                and.w   #$fff0,d3       *Wortnummer
                and.w   #$fff0,d0       *Auch von x1
                sub.w   d0,d3
                lsr.w   #4,d3           *Zahl der Worte nun in d3

                mulu    #160,d2         *da 160 Bytes pro Zeile
                adda.l  d2,a0           *Y-Offset hinzuaddieren
                move.w  (a7),d0         *x1 zurÅckholen
                and.l   #$fff0,d0       *Wortnummer, Bits 16-31 lîschen
                lsr.w   #1,d0           *d0/2
                adda.l  d0,a0           *X-Offset hinzuaddieren

                move.w  (a7)+,d0        *x1 zurÅckholen
                and.w   #$f,d0          *Bitnummer holen
                lsl.w   #1,d0           *mal 2, da Wortetabelle
                lea     hl_btab,a1      *Zeiger auf Tabelle 'Beginn'
                move.w  0(a1,d0.w),d2   *Bitmuster laden
                lea     hl_etab,a1      *Zeiger auf Tabelle 'Ende'
                tst.w   d3              *Letztes Wort?
                bne.s   hl_j1           *Nein --> Weiter

                and.w   #$f,d1          *Bitnummer von x2 holen
                lsl.w   #1,d1           *mal 2, da Wortetabelle
                lea     hl_etab,a1      *Zeiger auf Tabelle 'Ende'
                and.w   0(a1,d1.w),d2   *Bitmuster holen
                bra.s   hl_2end         *Ende-Routine


hl_j1:          move.w  d2,d0           *Bitmuster nach d0 kopieren
                not.w   d0              *invertieren
                clr.w   d4              *ZÑhler lîschen
hl_j2:          btst    d4,d7           *Farbbit gesetzt?
                beq.s   hl_j3           *Nein --> Weiter

                or.w    d2,(a0)+        *Oder-VerknÅpfung
                bra.s   hl_j4           *Weiter

hl_j3:          and.w   d0,(a0)+        *Und-Verkn. mit Inversen

hl_j4:          addq.w  #1,d4           *d4+1
                cmp.w   #4,d4           *d4 == 4 ?
                bne.s   hl_j2           *Nein --> ZurÅck

                lsl.w   #3,d7           *mal 8, da je 2 Langworte
                lea     hl_lwtab,a1     *Zeiger auf Langworttabelle
                move.l  0(a1,d7.w),d0   *Langwort 1
                move.l  4(a1,d7.w),d2   *Langwort 2
                lsr.w   #3,d7           *d7 restaurieren

hl_j5:          subq.w  #1,d3           *WortzÑhler-1
                beq.s   hl_end          *WortzÑhler == 0 --> Ende

                move.l  d0,(a0)+        *Langwort 1 schreiben
                move.l  d2,(a0)+        *Langwort 2 schreiben

                bra.s   hl_j5           *In Schleife zurÅck

hl_end:         and.w   #$f,d1          *Bitnummer von x2 holen
                lsl.w   #1,d1           *mal 2, da Wortetabelle
                lea     hl_etab,a1      *Zeiger auf Tabelle 'Ende'
                move.w  0(a1,d1.w),d2   *Bitmuster holen

hl_2end:        move.w  d2,d0           *Kopieren nach d0
                not.w   d0              *Invertieren
                clr.w   d4              *ZÑhler lîschen
hl_j9:          btst    d4,d7           *Farbbit gesetzt ?
                beq.s   hl_j10          *Nein --> Weiter

                or.w    d2,(a0)+        *Or-VerknÅpfung
                bra.s   hl_j11          *Weiter

hl_j10:         and.w   d0,(a0)+        *And-VerknÅpfung mit Inversem
hl_j11:         addq.w  #1,d4           *d4+1
                cmp.w   #4,d4           *d4 == 4 ?
                bne.s   hl_j9           *Nein --> ZurÅck

hl_ret:         rts                     *Fertig!!!

.data

hl_btab:        dc.w    %1111111111111111
                dc.w    %0111111111111111
                dc.w    %0011111111111111
                dc.w    %0001111111111111
                dc.w    %0000111111111111
                dc.w    %0000011111111111
                dc.w    %0000001111111111
                dc.w    %0000000111111111
                dc.w    %0000000011111111
                dc.w    %0000000001111111
                dc.w    %0000000000111111
                dc.w    %0000000000011111
                dc.w    %0000000000001111
                dc.w    %0000000000000111
                dc.w    %0000000000000011
                dc.w    %0000000000000001

hl_etab:        dc.w    %1000000000000000
                dc.w    %1100000000000000
                dc.w    %1110000000000000
                dc.w    %1111000000000000
                dc.w    %1111100000000000
                dc.w    %1111110000000000
                dc.w    %1111111000000000
                dc.w    %1111111100000000
                dc.w    %1111111110000000
                dc.w    %1111111111000000
                dc.w    %1111111111100000
                dc.w    %1111111111110000
                dc.w    %1111111111111000
                dc.w    %1111111111111100
                dc.w    %1111111111111110
                dc.w    %1111111111111111

hl_lwtab:       dc.l    $00000000,$00000000
                dc.l    $ffff0000,$00000000
                dc.l    $0000ffff,$00000000
                dc.l    $ffffffff,$00000000
                dc.l    $00000000,$ffff0000
                dc.l    $ffff0000,$ffff0000
                dc.l    $0000ffff,$ffff0000
                dc.l    $ffffffff,$ffff0000
                dc.l    $00000000,$0000ffff
                dc.l    $ffff0000,$0000ffff
                dc.l    $0000ffff,$0000ffff
                dc.l    $ffffffff,$0000ffff
                dc.l    $00000000,$ffffffff
                dc.l    $ffff0000,$ffffffff
                dc.l    $0000ffff,$ffffffff
                dc.l    $ffffffff,$ffffffff

