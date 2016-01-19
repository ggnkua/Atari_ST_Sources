* rndbcopy - Kopiert zufÑllig (8x8-Blîcke) ein Bild ins andere
* Aufruf: rndbcopy(quelle,ziel)
*

.text
.xdef _rndbcopy
_rndbcopy:      movem.l d0-d4/a0-a1,-(a7) *Register retten
                movem.l 32(a7),a0-a1    *Quell- und Zielbereich laden
                move.w  #999,d4         *1000 Blîcke a 8x8 Pixel
                clr.w   d2              *d2 lîschen

rbc_j1:         move.w  40(a7),d3       *ZÑhler laden
rbc_j1a:        dbra    d3,rbc_j1a      *Schleife
rbc_j2:         move.w  d2,d3           *d2 kopieren
                lsl.w   #4,d2           *d2 mal 16
                add.w   d3,d2           *d2 + d3
                add.w   #87,d2          *d2 + 87
                and.w   #$3ff,d2        *and 1023
                cmp.w   #999,d2         *d2 > 999 ?
                bhi.s   rbc_j2          *Ja --> ZurÅck
                move.w  d2,d3           *d3 = d2
                ext.l   d3              *auf 32 Bit erweitern

                divu    #40,d3          *Durch 40 teilen
                move.w  d3,d0           *Ergebnis nach d0
                mulu    #1280,d0        *mal 1280, da 8 Zeilen a 160 Bytes
                swap    d3              *Modulo-Wert holen

                move.w  d3,d1           *d3 nach d1
                and.w   #1,d1           *Bits 1 bis 15 ausschalten
                add.w   d1,d0           *Hinzuaddieren

                and.w   #$fffe,d3       *Bit 0 lîschen
                asl.w   #2,d3           *d3 * 4
                add.w   d3,d0           *Hinzuaddieren

                move.w  #7,d3           *8 DurchlÑufe
rbc_j3:         move.b  0(a0,d0.w),d1   *Wert laden
                move.b  d1,0(a1,d0.w)   *Wert schreiben
                move.b  2(a0,d0.w),d1   *Wert laden
                move.b  d1,2(a1,d0.w)   *Wert schreiben
                move.b  4(a0,d0.w),d1   *Wert laden
                move.b  d1,4(a1,d0.w)   *Wert schreiben
                move.b  6(a0,d0.w),d1   *Wert laden
                move.b  d1,6(a1,d0.w)   *Wert schreiben
                add.w   #160,d0         *NÑchste Zeile
                dbra    d3,rbc_j3       *Schleife

                dbra    d4,rbc_j1       *ZurÅck

                movem.l (a7)+,d0-d4/a0-a1 *Register zurÅckholen
rbc_j4:         rts                     *RÅckkehr
