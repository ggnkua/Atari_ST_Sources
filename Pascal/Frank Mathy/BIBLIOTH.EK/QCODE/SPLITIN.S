* Zeilenweises Reinschieben eines Bildes von links und rechts
* Aufruf: splitin(quelle,ziel,vsyncs)

.text
.xdef _splitin
_splitin:       movem.l d0-d4/a0-a1,-(a7) *Register retten
                clr.w   d0              *Offset 1
                move.w  #152,d1         *Offset 2

spl_j0:         clr.l   d2              *y_Offset

spl_j1:         movem.l 32(a7),a0-a1    *Adressen der Bildschirmseiten
                adda.l  d2,a0           *Adresse der aktuellen Zeile
                adda.l  d2,a1
                move.w  #152,d3
                move.w  d0,d4

spl_j2:         move.l  (a0,d3.w),(a1,d4.w)   *kopieren Plane 1 + 2
                move.l  4(a0,d3.w),4(a1,d4.w) *kopieren Plane 3 + 4
                sub.w   #8,d3
                sub.w   #8,d4
                bpl.s   spl_j2          *Solange d4 >= 0 --> Zurck

                adda.l  #160,a0         *N„chste Zeile
                adda.l  #160,a1
                clr.w   d3
                move.w  d1,d4

spl_j3:         move.l  (a0,d3.w),(a1,d4.w)   *kopieren Plane 1 + 2
                move.l  4(a0,d3.w),4(a1,d4.w) *kopieren Plane 3 + 4
                add.w   #8,d3
                add.w   #8,d4
                cmp.w   #160,d4
                bne.s   spl_j3

                add.l   #320,d2         *2 Zeilen weiter
                cmp.l   #32000,d2       *Fertig ?
                bne.s   spl_j1          *Nein --> Zurck

                movem.l d0-d4/a0-a1,-(a7) *Register retten
                move.w  #37,-(a7)         *VSync-Funktion
                trap    #14               *XBIOS aufrufen
                addq.l  #2,a7             *Stackkorrektur
                movem.l (a7)+,d0-d4/a0-a1 *Register holen

                add.w   #8,d0           *Offset 1 erh”hen
                sub.w   #8,d1           *Offset 2 erniedrigen
                bpl     spl_j0          *Positiv --> Zurck

                movem.l (a7)+,d0-d4/a0-a1 *Register holen
spl_end:        rts
