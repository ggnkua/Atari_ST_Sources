* GetPage - Funktion zum reservieren von Bildschirmspeicher fÅr eine Seite
* Aufruf: seite=getpage(); wobei <seite> ein Zeiger auf die Seite ist
* Bei Fehler ist <seite> negativ

.text
.xdef _getpage
_getpage:       move.l  a0,-(a7)        *a0 retten
                move.l  #32256,-(a7)    *32000+256 Bytes
                move.w  #$48,-(a7)      *Malloc-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                addq.l  #6,a7           *Stapelzeiger korrigieren
                movea.l (a7)+,a0        *a0 zurÅckholen
                rts                     *RÅckkehr

* CalPage - Funktion zum Ermitteln der logischen Bildschirmbasis einer
* Grafikseite, da diese an einer 256-Byte-Grenze beginnen muû.
* Aufruf: logbase=calpage(seite);

.text
.xdef _calpage
_calpage:       move.l  4(a7),d0        *Wert holen
                tst.b   d0              *Byte == 0 ?
                bne.s   cp_j1           *Nein --> Weiter
                move.l  4(a7),d0        *logbase = seite
                rts                     *RÅckkehr
cp_j1:          move.l  4(a7),d0        *Wert holen
                clr.b   d0              *Byte lîschen
                add.l   #$100,d0        *logbase = (seite&$ffffff00)+$100
                rts                     *RÅckkehr

* FreePage - Gibt mit GetPage reservierte Bildschirmseite frei
* Aufruf: fehler=freepage(seite); wobei <seite> ein Zeiger auf die Seite
* ist. Wenn <fehler> negativ, dann ist ein Fehler aufgetreten

.text
.xdef _freepage
_freepage:      move.l  a0,-(a7)        *a0 retten
                move.l  8(a7),-(a7)     *Adresse Åbergeben
                move.w  #$49,-(a7)      *Mfree-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                addq.l  #6,a7           *Stapelzeiger korrigieren
                movea.l (a7)+,a0        *a0 zurÅckholen
                rts                     *RÅckkehr
