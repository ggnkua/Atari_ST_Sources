* Routine zum Reinscrollen von unten nach oben / umgekehrt
* Aufruf: yin(quelle,ziel,richtung)
* Richtung: 0 = von oben , ungleich 0 = von unten

.text
.xdef _yin
_yin:           movem.l d0-d7/a0-a6,-(a7) *Register retten
                move.w  #32000,d1       *Offset-Zeiger

yi_j1:          sub.w   #640,d1         *Vier Zeilen hoch
                move.w  d1,d2           *Z„hler nach d1
                ext.l   d2              *Auf Langwort erweitern
                movem.l 64(a7),a0-a1    *Adressen holen
                tst.w   72(a7)          *Welche Richtung ?
                beq.s   yi_j4           *Von Unten --> Weiter

yi_j2:          adda.l  d2,a1           *Zur Zieladresse addieren
yi_j3:          movem.l (a0)+,d3-d7/a2-a6 *Langworte holen
                movem.l d3-d7/a2-a6,(a1) *Langworte schreiben
                adda.l  #40,a1
                add.w   #40,d2
                cmp.w   #32000,d2
                bne.s   yi_j3
                bra.s   yi_j6           *Weiter

yi_j4:          adda.l  d2,a0           *Zur Quelladresse addieren
yi_j5:          movem.l (a0)+,d3-d7/a2-a6 *Langworte holen
                movem.l d3-d7/a2-a6,(a1) *Langworte schreiben
                adda.l  #40,a1
                add.w   #40,d2
                cmp.w   #32000,d2
                bne.s   yi_j5

yi_j6:          tst.w   d1              *d1 == 0 ?
                bne.s   yi_j1           *Nein --> Zurck

                movem.l (a7)+,d0-d7/a0-a6 *Register holen
yi_end:         rts                     *Rcksprung
