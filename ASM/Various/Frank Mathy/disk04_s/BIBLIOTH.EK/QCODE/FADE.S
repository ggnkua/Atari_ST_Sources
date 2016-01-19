* Einblenden eines Bildes
* Aufruf: fadein(palette)
* <palette> ist ein Zeiger auf die herzustellende Farbpalette

.text
.xdef _fadein
_fadein:        movem.l d1-d4/a0-a1,-(a7)
                move.w  #7,d1           *ZÑhler
                lea     fade_count,a1
                move.w  #15,d2          *32 Worte lîschen
fin_j0:         clr.l   (a1)+           *Lîschen
                dbra    d2,fin_j0       *ZurÅck in die Schleife
                move.l  28(a7),a0       *Zeiger auf Palette
                lea     fade_count,a1

fin_j1:         clr.w   d3              *ZÑhler fÅr Farbtîpfe

fin_j2:         move.w  (a1,d3.w),d2    *Zwischenwert holen
                move.w  (a0,d3.w),d4    *Neuen Wert holen
                and.w   #$777,d4        *Andere Bits ausschalten
                add.w   d4,d2           *Erhîhen um Farbwert
                move.w  d2,d4           *d2 retten
                and.w   #$f,d4          *Low-Nibble
                cmp.w   #7,d4           *d4<7 ?
                bls.s   fin_j3          *Ja --> Weiter
                sub.w   #7,d4           *d4 == d4 - #7
                and.w   #$0ff0,d2       *Nibble 0 == 0
                or.w    d4,d2           *d2 == d2 OR d4
                addq.w  #1,32(a1,d3.w)  *Farbwert erhîhen
fin_j3:         move.w  d2,d4           *d2 retten
                and.w   #$f0,d4         *Nibble 1
                cmp.w   #$70,d4         *d4<7*16 ?
                bls.s   fin_j4          *Ja --> Weiter
                sub.w   #$70,d4         *d4 == d4 - #$70
                and.w   #$0f0f,d2       *Nibble 1 == 0
                or.w    d4,d2           *d2 == d2 OR d4
                move.w  32(a1,d3.w),d4  *Farbwert laden
                add.w   #$10,d4         *Um $10 erhîhen
                move.w  d4,32(a1,d3.w)  *Farbwert schreiben
fin_j4:         move.w  d2,d4           *Farbwert erhîhen
                and.w   #$f00,d4        *Nibble 2
                cmp.w   #$700,d4        *d4<7*256 ?
                bls.s   fin_j5          *Ja --> Weiter
                sub.w   #$700,d4        *d4 == d4 - $c00
                and.w   #$ff,d2         *Nibble 2 == 0
                or.w    d4,d2           *d2 == d2 OR d4
                move.w  32(a1,d3.w),d4  *Farbwert laden
                add.w   #$100,d4        *Um $100 erhîhen
                move.w  d4,32(a1,d3.w)  *Farbwert schreiben

fin_j5:         move.w  d2,(a1,d3.w)    *Zwischenwert zurÅckschreiben
                addq.w  #2,d3           *NÑchster Topf
                cmp.w   #32,d3          *Alle Paletten ?
                bne.s   fin_j2          *Nein --> ZurÅck

                movem.l d1-d4/a0-a1,-(a7) *Register retten

                adda.l  #32,a1
                move.l  a1,-(a7)        *Adresse der Palette
                move.w  #6,-(a7)        *Setpalette-XBIOS-Funktion
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stack korrigieren

                move.w  #37,-(a7)       *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                move.w  #37,(a7)        *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                move.w  #37,(a7)        *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                move.w  #37,(a7)        *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                move.w  #37,(a7)        *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #2,a7           *Stapel korrigieren

                movem.l (a7)+,d1-d4/a0-a1 *Register holen

                dbra    d1,fin_j1       *Erniedrige und ggf. zurÅck in Schleife

                movem.l (a7)+,d1-d4/a0-a1 *Register zurÅckholen
                rts

* Ausblenden eines Bildes. Aufruf: fadeout()

.text
.xdef _fadeout
_fadeout:       movem.l d1-d4/a5-a6,-(a7)

                lea     fade_count,a5     *Zeiger auf ZÑhler
                lea     max_color,a6      *Zeiger auf Anfangsfarben
                movem.l d0-d3/a0-a2,-(a7) *Register retten
                clr.w   d4                *ZaÑhler lîschen

fout_j0:        move.w  #-1,-(a7)         *Inhalt holen
                move.w  d4,-(a7)          *Registernummer
                move.w  #7,-(a7)          *Setcolor-Funktion
                trap    #14               *XBIOS-Aufruf
                addq.l  #6,a7             *Stapelzeiger korrigieren
                move.w  d0,32(a5)         *Farbwert als Anfangswert setzen
                clr.w   (a5)+             *Zwischenwerte lîschen
                move.w  d0,(a6)+          *Farbwert schreiben
                addq.w  #1,d4             *ZÑhler erhîhen
                cmp.w   #16,d4            *16 mal durchgelaufen ?
                bne.s   fout_j0           *Nein --> ZurÅck in die Schleife

                movem.l (a7)+,d0-d3/a0-a2 *Register holen

                move.w  #7,d1           *ZÑhler
                lea     max_color,a6    *Zeiger auf Palette
                lea     fade_count,a5   *Zeiger auf ZÑhler

fout_j1:        clr.w   d3              *ZÑhler fÅr Farbtîpfe

fout_j2:        move.w  (a5,d3.w),d2    *Zwischenwert holen
                move.w  (a6,d3.w),d4    *Neuen Wert holen
                and.w   #$777,d4        *Andere Bits ausschalten
                add.w   d4,d2           *Erhîhen um Farbwert
                move.w  d2,d4           *d2 retten
                and.w   #$f,d4          *Low-Nibble
                cmp.w   #7,d4           *d4<7 ?
                bls.s   fout_j3         *Ja --> Weiter
                sub.w   #7,d4           *d4 == d4 - #7
                and.w   #$0ff0,d2       *Nibble 0 == 0
                or.w    d4,d2           *d2 == d2 OR d4
                subq.w  #1,32(a5,d3.w)  *Farbwert erhîhen
fout_j3:        move.w  d2,d4           *d2 retten
                and.w   #$f0,d4         *Nibble 1
                cmp.w   #$70,d4         *d4<7*16 ?
                bls.s   fout_j4         *Ja --> Weiter
                sub.w   #$70,d4         *d4 == d4 - #$70
                and.w   #$0f0f,d2       *Nibble 1 == 0
                or.w    d4,d2           *d2 == d2 OR d4
                move.w  32(a5,d3.w),d4  *Farbwert laden
                sub.w   #$10,d4         *Um $10 erhîhen
                move.w  d4,32(a5,d3.w)  *Farbwert schreiben
fout_j4:        move.w  d2,d4           *Farbwert erhîhen
                and.w   #$f00,d4        *Nibble 2
                cmp.w   #$700,d4        *d4<7*256 ?
                bls.s   fout_j5         *Ja --> Weiter
                sub.w   #$700,d4        *d4 == d4 - $c00
                and.w   #$ff,d2         *Nibble 2 == 0
                or.w    d4,d2           *d2 == d2 OR d4
                move.w  32(a5,d3.w),d4  *Farbwert laden
                sub.w   #$100,d4        *Um $100 erhîhen
                move.w  d4,32(a5,d3.w)  *Farbwert schreiben

fout_j5:        move.w  d2,(a5,d3.w)    *Zwischenwert zurÅckschreiben
                addq.w  #2,d3           *NÑchster Topf
                cmp.w   #32,d3          *Alle Paletten ?
                bne.s   fout_j2         *Nein --> ZurÅck

                movem.l d1-d4/a5-a6,-(a7) *Register retten

                adda.l  #32,a5
                move.l  a5,-(a7)        *Adresse der Palette
                move.w  #6,-(a7)        *Setpalette-XBIOS-Funktion
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stack korrigieren

                move.w  #37,-(a7)       *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                move.w  #37,(a7)        *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                move.w  #37,(a7)        *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                move.w  #37,(a7)        *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                move.w  #37,(a7)        *Vsync-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #2,a7           *Stapel korrigieren

                movem.l (a7)+,d1-d4/a5-a6 *Register holen

                dbra    d1,fout_j1      *Erniedrige und ggf. zurÅck in Schleife

                movem.l (a7)+,d1-d4/a5-a6 *Register zurÅckholen
fout_j6:        rts

.bss
fade_count:     ds.w    16              *FÅr Berechnung
fade_color:     ds.w    16              *Aktuelle Farbwerte
max_color:      ds.w    16              *Farbwerte vor Ausblenden

