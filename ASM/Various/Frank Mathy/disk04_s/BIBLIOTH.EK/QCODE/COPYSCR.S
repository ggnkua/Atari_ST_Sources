*Kopieren von Bildschirmbereichen
*Aufruf mit copyscreen(quelle,ziel,ystart,yend)

.text
.xdef _copyscreen
_copyscreen:            movem.l d0-d7/a0-a5,-(a7) *Register retten
                        movea.l 60(a7),a0         *Zeiger auf Seite 1
                        movea.l 64(a7),a1         *Zeiger auf Seite 2
                        move.w  #70(a7),d0        *y2_Wert laden
                        addq.w  #1,d0             *Um 1 erh”hen
                        mulu    #160,d0           *Zeile berechnen
                        movea.w d0,a5
                        move.w  70(a7),d0         *y2_Wert
                        sub.w   68(a7),d0         *y2_Wert - y1_Wert
                        addq.w  #1,d0             *Zahl der zu l”sch. Zeilen
                        asl.w   #2,d0             *Zahl der L”schoperationen
                        sub.w   #1,d0             *Da dbra-Bef.(Abbruch bei -1)

cpscr_j1:               suba.l  #40,a5                *Zeiger erniedrigen
                        movem.l (a0,a5.w),d1-d7/a2-a4 *Werte laden
                        movem.l d1-d7/a2-a4,(a1,a5.w) *Werte schreiben
                        dbra    d0,cpscr_j1           *Schleife

                        movem.l (a7)+,d0-d7/a0-a5 *Register holen
                        rts
