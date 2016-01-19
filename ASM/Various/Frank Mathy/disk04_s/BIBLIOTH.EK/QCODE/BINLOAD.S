* Laden von Bin„rdateien
* Aufruf: status=binload("name",<start>,<bytes>);
* <start> gibt die Ladeadresse an
* <status> liefert die gelesenen Bytes bzw. Fehlercode (<0)
.text
.xdef _binload
_binload:       movem.l d1-d2/d7/a0-a2,-(a7) *Register retten
                clr.w   -(a7)           *Nur lesen
                move.l  30(a7),-(a7)    *Dateiname
                move.w  #$3d,-(a7)      *FOPEN-Funktion
                trap    #1              *Gemdos
                addq.l  #8,a7           *Stapelkorrektur
                tst.w   d0              *Fehler ?
                bmi     bl_exit         *Ja --> Beenden

                move.w  d0,d7           *Handle merken

                move.l  32(a7),-(a7)    *Startadresse
                move.l  40(a7),-(a7)    *L„nge
                move.w  d7,-(a7)        *Handle
                move.w  #$3f,-(a7)      *FREAD-Funktion
                trap    #1              *Gemdos
                add.l   #12,a7          *Stapelkorrektur

                move.l  d0,-(a7)        *Gelesene Bytes merken
                move.w  d7,-(a7)        *Handle
                move.w  #$3e,-(a7)      *FCLOSE-Funktion
                trap    #1              *Gemdos
                addq.l  #4,a7           *Stapelkorrektur
                move.l  (a7)+,d0        *Gelesene Bytes holen
bl_exit:        movem.l (a7)+,d1-d2/d7/a0-a2 *Register holen
                rts

