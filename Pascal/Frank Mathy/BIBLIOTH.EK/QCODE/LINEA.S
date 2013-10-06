* Line-A-Bibliothek fÅr DR-C und ST-Pascal+
* (C) 1987 Frank Mathy

* Initialisierung: la_init();

.text
.xdef _la_init
_la_init:       movem.l a0-a2,-(a7)     *Register retten
                dc.w    $a000           *Adressen holen
                move.l  a0,la_param     *Zeiger auf Parameterblock
                move.l  a1,la_fonts     *Zeiger auf ZeichensÑtze
                movem.l (a7)+,a0-a2     *Register holen
                rts

.xdef _all_init
_all_init:      bsr.s   _la_init        *Zeiger setzen

                move.w  #15,-(a7)       *Farbe 15
                bsr.s   _setcolor       *Farbe setzen
                addq.l  #2,a7           *Stapel korrigieren
                clr.w   -(a7)           *Replace-Mode
                bsr     _set_wmode      *Setzen
                addq.l  #2,a7           *Stapel korrigieren

                move.w  #$ffff,-(a7)    *Durchgezogene Linie
                bsr     _set_line       *Setzen
                addq.l  #2,a7           *Stapel korrigieren

                clr.w   -(a7)           *Einfarbig
                clr.w   -(a7)           *Hîhe = 1
                pea     la_muster       *FÅllmusteradresse
                bsr     _def_fill       *FÅllmuster setzen
                addq.l  #8,a7           *Stapel korrigieren

                clr.w   -(a7)           *Kein Clipping
                clr.l   -(a7)           *Clip-x2/-y2
                clr.l   -(a7)           *Clip-x1/-y1
                bsr     _set_clip       *Clipparameter setzen
                add.l   #10,a7          *Stapel korrigieren

                clr.w   -(a7)           *Keine Textrotation
                clr.w   -(a7)           *Keine Effekte
                clr.w   -(a7)           *DDA
                clr.w   -(a7)           *Keine Vergr./Verkl.
                move.w  #15,-(a7)       *Textfarbe 15
                clr.w   -(a7)           *Hintergrundfarbe 0
                bsr     _settext        *Textattribute setzen
                add.l   #12,a7          *Stapel korrigieren

                rts

.bss
la_param:       ds.l    1
la_fonts:       ds.l    1
.data
la_muster:      dc.w    $ffff

* Setzen der Zeichenfarbe: setcolor(farbe);

.text
.xdef _setcolor
_setcolor:      movem.l d1-d3/a0,-(a7)  *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                add.l   #24,a0          *Zeiger auf Farbe Plane 0
                move.w  20(a7),d0       *Farbe holen
                move.w  d0,d1
                move.w  d0,d2
                move.w  d0,d3
                and.w   #1,d0           *Plane 0
                and.w   #2,d1           *Plane 1
                lsr.w   #1,d1
                and.w   #4,d2           *Plane 2
                lsr.w   #2,d2
                and.w   #8,d3           *Plane 3
                lsr.w   #3,d3
                movem.w d0-d3,(a0)      *Farben setzen
                movem.l (a7)+,d1-d3/a0  *Register holen
                rts

* Setzen eines Pixels: set_pixel(x,y,farbe);

.text
.xdef _set_pixel
_set_pixel:     movem.l d1-d2/a0-a2,-(a7) *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  12(a0),a1       *Zeiger auf PTSIN-Array
                move.l  8(a0),a2        *Zeiger auf INTIN-Array
                move.w  24(a7),(a1)+    *x-Koordinate schreiben
                move.w  26(a7),(a1)     *y-Koordinate schreiben
                move.w  28(a7),(a2)     *Farbe schreiben
                dc.w    $a001           *Funktion ausfÅhren
                movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts

* Holen der Pixelfarbe: farbe=get_point(x,y);

.text
.xdef _get_point
_get_point:     movem.l d1-d2/a0-a2,-(a7) *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  12(a0),a1       *Zeiger auf PTSIN-Array
                move.w  24(a7),(a1)+    *x-Koordinate schreiben
                move.w  26(a7),(a1)+    *y-Koordinate schreiben
                dc.w    $a002           *Farbe holen
                movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts

* Ziehen einer Linie: drawline(x1,y1,x2,y2);

.text
.xdef _drawline
_drawline:      movem.l d1-d2/a0-a2,-(a7) *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  24(a7),38(a0)   *x1 und y1 setzen
                move.l  28(a7),42(a0)   *x2 und y2 setzen
                move.w  #-1,32(a0)      *lstlin auf -1 setzen
                dc.w    $a003           *Linie ziehen
                movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts

* Horizontale Linie ziehen: drawhline(x1,y2,x2);

.text
.xdef _drawhline
_drawhline:     movem.l d1-d2/a0-a2,-(a7) *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  24(a7),38(a0)   *x1 und y1 setzen
                move.w  28(a7),42(a0)   *x2 setzen
                dc.w    $a004           *Linie ziehen
                movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts

* GefÅlltest Rechteck zeichnen: frect(x1,y1,x2,y2);

.text
.xdef _frect
_frect:         movem.l d1-d2/a0-a2,-(a7) *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  24(a7),38(a0)   *x1 und y1 setzen
                move.l  28(a7),42(a0)   *x2 und y2 setzen
                dc.w    $a005           *Rechteck zeichnen
                movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts

* GefÅlltes Polygon zeichnen: fpoly(koord,anzahl);
* <koord> ist ein Zeiger auf die Koordinatenpaare
* <anzahl> ist die Zahl der Ecken

.text
.xdef _fpoly
_fpoly:         movem.l d1-d2/a0-a2,-(a7) *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  12(a0),a1       *Zeiger auf PTSIN-Array
                move.l  24(a7),a2       *Zeiger auf Koordinaten

                move.w  28(a7),d0       *Zahl der Ecken
                subq.w  #1,d0           *Da DBRA-Operation
fp_j1:          move.l  (a2)+,(a1)+     *Koordinaten nach PTSIN
                dbra    d0,fp_j1        *Schleife
                move.l  24(a7),a2       *Zeiger auf erste Koordinate
                move.l  (a2),(a1)       *Koordinate kopieren

                move.l  4(a0),a1        *Zeiger auf CONTRL-Array
                move.w  28(a7),d0       *Zahl der Ecken holen
                move.w  d0,2(a1)        *Nach CONTRL+2
                subq.w  #1,d0           *Da DBRA-Operation
                addq.l  #2,a2           *Auf erste Y-Ordinate
                move.w  #400,d1         *Minimum-Wert
                clr.w   d2              *Maximum-Wert

fp_j2:          cmp.w   (a2),d1         *(a2) < d1 ?
                ble.s   fp_j3           *Nein --> Weiter
                move.w  (a2),d1         *d1 = (a2)
fp_j3:          cmp.w   (a2),d2         *(a2) > d2 ?
                bge.s   fp_j4           *Nein --> Weiter
                move.w  (a2),d2         *d2 = (a2)
fp_j4:          addq.l  #4,a2           *NÑchste y-Ordinate
                dbra    d0,fp_j2        *Schleife

fp_j5:          move.w  d1,40(a0)       *Y-Scanzeile bestimmen
                movem.l d1-d2/a0,-(a7)  *Register retten
                dc.w    $a006           *Zeile zeichnen
                movem.l (a7)+,d1-d2/a0  *Register holen
                addq.w  #1,d1           *NÑchste Scanzeile
                cmp.w   d2,d1           *d1 > d2 ?
                ble.s   fp_j5           *Nein --> Schleife

                movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts

* BitBlock-Transfer: bitblt(struktur);

.xdef _bitblt
_bitblt:        movem.l d1-d2/a0-a2/a6,-(a7)    *Register retten
                move.l  28(a7),a6               *Zeiger auf Struktur
                dc.w    $a007                   *BitBlock-Transfer
                movem.l (a7)+,d1-d2/a0-a2/a6    *Register holen
                rts

* Textattribute setzen: settext(bgcol,fgcol,scale,effect,rotate);
* <bgcol>  : Hintergrundfarbe
* <fgcol>  : Vordergrundfarbe
* <scale>  : Vergrîûerung? 0 = nein, 1 = ja
* <effect> : Flags fÅr Effekte (kursiv, outline etc.)
* <rotate> : Rotation in Grad*10

.text
.xdef _settext
_settext:       move.l  a0,-(a7)        *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  #eff_buff,108(a0) *Puffer fÅr Effekte
                move.w  #$40,112(a0)    *Puffer fÅr Spezialeffekte
                move.w  8(a7),114(a0)   *Hintergrundfarbe
                move.w  10(a7),106(a0)  *Vordergrundfarbe
                clr.w   102(a0)         *Scale-Flag ausschalten
                tst.w   12(a7)          *Vergrîûerung?
                beq.s   stx_j1          *Nein --> Weiter
                move.w  #1,102(a0)      *Scale-Flag setzen
                move.w  #1,68(a0)       *Auf Vergrîûerung setzen
                move.w  #$ffff,66(a0)   *Einzig mîgl. Faktor
stx_j1:         move.w  14(a7),90(a0)   *Effektflags setzen
                move.w  16(a7),104(a0)  *Rotationswinkel
                move.l  (a7)+,a0        *Register holen
                rts

.bss
eff_buff:       ds.w    500             *Puffer fÅr Effekte

* Zeichen setzen: setchar(x,y,code,font);
* <code>   : ASCII-Code der Ziffer
* <font>   : Fontnummer (0 bis 2)

.text
.xdef _setchar
_setchar:       movem.l d1-d2/a0-a2,-(a7) *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  la_fonts,a1     *Zeiger auf Fonttabelle
                move.w  30(a7),d0       *Fontnummmer
                asl.w   #2,d0           *Offset berechnen
                move.l  (a1,d0.w),a1    *Zeiger auf Zeichensatz

                move.w  28(a7),d0       *Zeichencode
                sub.w   36(a1),d0       *-Wert des niedr. Zeichens
                bmi     sch_end         *Negativ --> Fehler

                asl.w   #1,d0           *Mal 2, da Wortetabelle
                move.l  72(a1),a2       *Zeiger auf Offset-Table
                move.w  2(a2,d0.w),d1   *Zeichenbreite bestimmen
                sub.w   (a2,d0.w),d1
                move.w  d1,80(a0)       *Diese setzen
                move.w  (a2,d0.w),72(a0) *sourcex setzen
                clr.w   74(a0)          *sourcey setzen
                move.w  82(a1),82(a0)   *Hîhe des Zeichens
                move.w  #1,70(a0)       *Kein Proportionalfont

                move.l  76(a1),84(a0)   *Zeiger auf Zeichens.-Daten
                move.w  80(a1),88(a0)   *Breite aller Zeichen
                move.w  62(a1),92(a0)   *Maske fÅr Lightening
                move.w  64(a1),94(a0)   *Maske fÅr Kursivstellen
                move.w  54(a1),100(a0)  *Linker Offset fÅr kursiv
                move.w  56(a1),98(a0)   *Rechter Offset fÅr kursiv

                move.l  24(a7),76(a0)   *Koordinaten auf Schirm
                move.w  #$8000,64(a0)   *XACC_DDA

                dc.w    $a008           *Zeichen setzen

sch_end:        movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts

* Mauszeiger einschalten: onmouse();

.text
.xdef _onmouse
_onmouse:       movem.l d1-d2/a0-a2,-(a7) *Register retten
                dc.w    $a009             *Cursor einschalten
                movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts

* Mauszeiger ausschalten: offmouse();

.text
.xdef _offmouse
_offmouse:      movem.l d1-d2/a0-a2,-(a7) *Register retten
                dc.w    $a00a             *Mauscursor ausschalten
                movem.l (a7)+,d1-d2/a0-a2 *Register zurÅckholen
                rts

* Neue Form fÅr Mauszeiger definieren: transform(form)
* Form ist der Zeiger auf die Struktur/den Record mit den Daten

.text
.xdef _transform
_transform:     movem.l d1-d2/a0-a2,-(a7) *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  8(a0),a2        *Zeiger auf INTIN
                move.l  24(a7),a1       *Zeiger auf Daten
                move.l  (a1)+,(a2)+     *Aktionspunkt
                move.w  #1,(a2)+        *INTIN+4=1
                move.w  #16,d1          *34 Worte kopieren
tf_j1:          move.l  (a1)+,(a2)+     *Werte kopieren
                dbra    d1,tf_j1        *Schleife
                dc.w    $a00b           *Cursorform setzen
                movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts


* Sprite lîschen: clrsprite(ssb);
* <ssb> zeigt auf den Sprite-Save-Puffer

.text
.xdef _clrsprite
_clrsprite:     movem.l d1-d7/a0-a6,-(a7) *Register retten
                move.l  60(a7),a2         *Zeiger auf Puffer
                dc.w    $a00c             *Sprite lîschen
                movem.l (a7)+,d1-d7/a0-a6 *Register holen
                rts

* Sprite setzen: setsprite(x,y,sdb,ssb);
* <sdb> zeigt auf den Sprite-Definition-Block
* <ssb> zeigt auf den Sprite-Save-Puffer

.text
.xdef _setsprite
_setsprite:     movem.l d1-d7/a0-a6,-(a7) *Register retten
                move.w  60(a7),d0       *x-Koordinate
                move.w  62(a7),d1       *y-Koordinate
                move.l  64(a7),a0       *Sprite-Definition-Block
                move.l  68(a7),a2       *Sprite-Save-Puffer
                dc.w    $a00d           *Sprite setzen
                movem.l (a7)+,d1-d7/a0-a6 *Register holen
                rts

* Copy Rasterform: copy_raster(points,qmfdb,zmfdb,mode,art,col0,col1);
* <points> zeigt auf ein Array mit den 8 Eckpunktskoordinaten
* <qmfdb> und <zmfdb> zeigen auf die Memory-Form-Definitions-Blîcke
* <mode> gibt den Schreibmodus an
* <art> gibt die Art des Rasterkopierens an: 0=Opaque, -1=Transp.
* <col0> und <col1> sind die Farben fÅr Transparent-Copy

.text
.xdef _copy_raster
_copy_raster:   movem.l d1-d2/a0-a2,-(a7) *Register retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.w  38(a7),116(a0)  *RastergerÅst
                move.l  12(a0),a1       *Zeiger auf PTSIN-Array
                move.l  24(a7),a2       *Zeiger auf Koordinaten
                move.l  (a2)+,(a1)+     *Erstes Paar kopieren
                move.l  (a2)+,(a1)+
                move.l  (a2)+,(a1)+
                move.l  (a2)+,(a1)+
                move.l  4(a0),a1        *Zeiger auf CONTRL-Array
                move.l  28(a7),14(a1)   *Quell-MFDB
                move.l  32(a7),18(a1)   *Ziel-MFDB
                move.l  8(a0),a1        *Zeiger auf INTIN-Array
                move.w  36(a7),(a1)     *VerknÅpfungsmodus
                move.l  40(a7),2(a1)    *Farben fÅr Transparent
                dc.w    $a00e           *Raster kopieren
                movem.l (a7)+,d1-d2/a0-a2 *Register holen
                rts

* Schreibmodus setzen: set_wmode(modus);

.text
.xdef _set_wmode
_set_wmode:     move.l  a0,-(a7)        *Adreûregister retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.w  8(a7),36(a0)    *Schreibmodus setzen
                move.l  (a7)+,a0        *Adreûregister holen
                rts

* Linienform setzen: def_line(style);

.text
.xdef _def_line
_def_line:      move.l  a0,-(a7)        *Adreûregister retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.w  8(a7),34(a0)    *Linienstil setzen
                move.l  (a7)+,a0        *Adreûregister holen
                rts

* FÅllmuster setzen: def_fill(muster,maske,multifill);

.text
.xdef _def_fill
_def_fill:      move.l  a0,-(a7)        *Adreûregister retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  8(a7),46(a0)    *Zeiger auf Muster
                move.l  12(a7),50(a0)   *Maske und Multifill
                move.l  (a7)+,a0        *Adreûregister holen
                rts

* Clipping setzen: def_clip(x1,y1,x2,y2,modus);

.text
.xdef _def_clip
_def_clip:      move.l  a0,-(a7)        *Adreûregister retten
                move.l  la_param,a0     *Zeiger auf Parameterblock
                move.l  8(a7),56(a0)    *Clipping-x1 und -y1
                move.l  12(a7),60(a0)   *Clipping-x2 und -y2
                move.w  16(a7),54(a0)   *Modus setzen
                move.l  (a7)+,a0        *Adreûregister holen
cl_ret:         rts


* Objekt zeichnen
* Aufruf: object(x,y,faktor,daten)

* <x>,<y> (Integer) geben die Koordinaten an, an der das Objekt erscheinen soll
* <faktor> (Integer) gibt einen Vergrîûerungsfaktor von 0 bis 127 an

* <daten> zeigt auf das Quell-Integer-Feld, das folgendermaûen aufgebaut ist:
* Wort 0: Zahl der Ecken
* Wort 1+n*2:   x-Koordinate
* Wort 2+n*2:   y-Koordinate
* etc.

.text
.xdef _object
_object:        movem.l         d1-d4/a0-a1,-(a7)       *Register saven
                movem.w         28(a7),d0-d2            *Parameter laden
                move.l          34(a7),a0               *Quellzeiger laden
                lea             ptmem,a1                *Zeiger auf Ziel
                move.w          (a0)+,d3                *ZÑhler
                subq.w          #1,d3                   *Da DBRA
                and.w           #127,d2                 *Faktor nur Bits 0-6
                addq.w          #1,d2                   *Um 1 erhîhen

ob_j1:          move.w          (a0)+,d4                *Wert laden
                muls            d2,d4                   *Multiplizieren
                asr.l           #7,d4                   *Durch 128 teilen
                add.w           d0,d4                   *X-Koordinate addieren
                move.w          d4,(a1)+                *Wert schreiben

                move.w          (a0)+,d4                *Wert laden
                muls            d2,d4                   *Multiplizieren
                asr.l           #7,d4                   *Durch 128 teilen
                add.w           d1,d4                   *Y-Koordinate addieren
                move.w          d4,(a1)+

                dbra            d3,ob_j1                *Schleife

                move.l          34(a7),a0               *Zeiger auf Quelle
                move.w          (a0),d0                 *Zahl der Ecken

                movem.l         (a7)+,d1-d4/a0-a1       *Register holen

                move.w          d0,-(a7)                *Zahl der Ecken
                pea             ptmem                   *Feld mit Koordinaten
                bsr             _fpoly                  *Polygon zeichnen
                addq.l          #6,a7                   *Stapelkorrektur
                rts

.bss
ptmem:          ds.w            200                     *Bis 100 Eckpunkte
