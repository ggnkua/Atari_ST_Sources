.text
.xdef _picsave
_picsave:       movem.l d6-d7/a0-a1,-(a7)  *Register retten

                clr.w   -(a7)           *Normale Datei erzeugen
                move.l  22(a7),-(a7)    *Adresse des Dateinamen
                move.w  #$3c,-(a7)      *Fcreate-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                addq.l  #8,a7           *Stapelzeiger korrigieren

                tst.w   d0              *Fehler aufgetreten ?
                bmi     ns_end          *Ja --> Ende

                move.w  d0,d7           *Datei-Handle nach d7

                tst.w   32(a7)          *Welcher Bildtyp ?
                bmi.s   sbin            *BinÑrsaven

                beq.s   ps_j1           *Neochrome --> Weiter

                clr.w   d6              *1 Wort bis Farben
                bra.s   ps_j2           *Weiter

ps_j1:          move.w  #1,d6           *2 Worte bis Farben

ps_j2:          pea     ns_buffer       *Pufferadresse
                move.l  #2,-(a7)        *2 Bytes (1 Wort) schreiben
                move.w  d7,-(a7)        *Datei-Handle
                move.w  #$40,-(a7)      *Fwrite,FÅllworte schreiben
                trap    #1              *GEMDOS
                add.l   #12,a7          *Stapelzeiger korrigieren
                tst.w   d0              *Diskfehler ?
                bmi     ns_close        *Ja --> Schlieûen und beenden
                dbra    d6,ps_j2        *Schleife

                move.l  28(a7),-(a7)    *Zeiger auf Farbenpuffer
                move.l  #32,-(a7)       *32 Bytes schreiben
                move.w  d7,-(a7)        *Datei-Handle
                move.w  #$40,-(a7)      *Fwrite-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                add.l   #12,a7          *Stapelzeiger korrigieren
                tst.w   d0              *Fehler aufgetreten ?
                bmi.s   ns_close        *Ja --> Schlieûen

                tst.w   32(a7)          *Welcher Bildtyp ?
                bne.s   sbin            *Degas --> weiter

                move.w  #45,d6          *46 Leerworte (Worte 18-63)
ps_j3:          pea     ns_buffer       *Pufferadresse
                move.l  #2,-(a7)        *2 Bytes (1 Wort) schreiben
                move.w  d7,-(a7)        *Datei-Handle
                move.w  #$40,-(a7)      *Fwrite,FÅllworte schreiben
                trap    #1              *GEMDOS
                add.l   #12,a7          *Stapelzeiger korrigieren
                tst.w   d0              *Diskfehler ?
                bmi     ns_close        *Ja --> Schlieûen und beenden
                dbra    d6,ps_j3        *Schleife

sbin:           move.l  24(a7),-(a7)    *Logbase
                move.l  #32000,-(a7)    *32000 Bytes schreiben
                move.w  d7,-(a7)        *Datei-Handle
                move.w  #$40,-(a7)      *Fwrite-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                add.l   #12,a7          *Stapelzeiger korrigieren

ns_close:       move.w  d0,d6           *Fehlercode merken
                move.w  d7,-(a7)        *Datei-Handle
                move.w  #$3e,-(a7)      *Fclose-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                addq.l  #4,a7           *Stapelzeiger korrigieren
                move.w  d6,d0           *Fehlercode zurÅckholen

ns_end:         movem.l (a7)+,d6/d7/a0-a1  *Register zurÅckholen
                rts                        *RÅckkehr

.data
ns_buffer:      dc.w    0               *Pufferwert

