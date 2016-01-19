* Saven von Bin„rdateien
* Aufruf: status=binsave("name",<start>,<bytes>);
* <start> gibt die Startadresse der Daten an
* <status> liefert die gelesenen Bytes bzw. Fehlercode (<0)

.text
.xdef _binsave
_binsave:       movem.l d1-d2/d7/a0-a2,-(a7) *Register retten
                clr.w   -(a7)           *R/W-Status
                move.l  30(a7),-(a7)    *Dateiname
                move.w  #$3c,-(a7)      *FCREATE-Funktion
                trap    #1              *Gemdos
                addq.l  #8,a7           *Stapelkorrektur
                tst.w   d0              *Fehler ?
                bmi     bs_exit         *Ja --> Beenden

                move.w  d0,d7           *Handle merken

                move.l  32(a7),-(a7)    *Startadresse
                move.l  40(a7),-(a7)    *L„nge
                move.w  d7,-(a7)        *Handle
                move.w  #$40,-(a7)      *FWRITE-Funktion
                trap    #1              *Gemdos
                add.l   #12,a7          *Stapelkorrektur

                move.l  d0,-(a7)        *Status merken
                move.w  d7,-(a7)        *Handle
                move.w  #$3e,-(a7)      *FCLOSE-Funktion
                trap    #1              *Gemdos
                addq.l  #4,a7           *Stapelkorrektur
                move.l  (a7)+,d0        *Status holen
bs_exit:        movem.l (a7)+,d1-d2/d7/a0-a2 *Register holen
                rts

