* Laderoutine fÅr 320x200-16-Farben-Grafikmodus fÅr Degas/Neochrome-Bilder
* Aufruf: error=neoload(name,adresse,farben,art)
* farben ist ein 16-Wort-Feld: int farben[16];
* Art (Integer) :  0 = Neochrome
*                  1 = Degas
*                 -1 = BinÑr

.text
.xdef _picload
_picload:       movem.l d7/a0-a1,-(a7)  *Register retten

                clr.w   -(a7)           *Datei nur lesen
                move.l  18(a7),-(a7)    *Adresse des Dateinamen
                move.w  #$3d,-(a7)      *Fopen-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                addq.l  #8,a7           *Stapelzeiger korrigieren

                tst.w   d0              *Fehler aufgetreten ?
                bmi     nl_end          *Ja --> Ende

                move.w  d0,d7           *Datei-Handle nach d7

                tst.w   28(a7)          *Welcher Bildtyp ?
                bmi.s   lbin            *BinÑrladen

                beq.s   pl_j1           *Neochrome --> Weiter

                moveq   #2,d0           *2 Bytes bis Farben
                bra.s   pl_j2           *Weiter

pl_j1:          moveq   #4,d0           *4 Bytes bis Farben

pl_j2:          clr.w   -(a7)           *Von Anfang an bewegen
                move.w  d7,-(a7)        *Datei-Handle
                move.l  d0,-(a7)        *4 Bytes vorbewegen
                move.w  #$42,-(a7)      *Fseek-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                add.l   #10,a7          *Stapelzeiger korrigieren
                tst.w   d0              *Fehler aufgetreten ?
                bmi.s   nl_close        *Ja --> Schlieûen

                move.l  24(a7),-(a7)    *Zeiger auf Farbenpuffer
                move.l  #32,-(a7)       *32 Bytes lesen
                move.w  d7,-(a7)        *Datei-Handle
                move.w  #$3f,-(a7)      *Fread-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                add.l   #12,a7          *Stapelzeiger korrigieren
                tst.w   d0              *Fehler aufgetreten ?
                bmi.s   nl_close        *Ja --> Schlieûen

                tst.w   28(a7)          *Welcher Bildtyp ?
                bne.s   lbin            *Degas --> weiter

                clr.w   -(a7)           *Von Anfang an bewegen
                move.w  d7,-(a7)        *Datei-Handle
                move.l  #128,-(a7)      *auf das 128. Byte bewegen
                move.w  #$42,-(a7)      *Fseek-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                add.l   #10,a7          *Stapelzeiger korrigieren
                tst.w   d0              *Fehler aufgetreten ?
                bmi.s   nl_close        *Ja --> Schlieûen

lbin:           move.l  20(a7),-(a7)    *Ladeadresse = Logbase
                move.l  #32000,-(a7)    *32000 Bytes lesen
                move.w  d7,-(a7)        *Datei-Handle
                move.w  #$3f,-(a7)      *Fread-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                add.l   #12,a7          *Stapelzeiger korrigieren

nl_close:       move.w  d0,-(a7)        *Fehlercode merken
                move.w  d7,-(a7)        *Datei-Handle
                move.w  #$3e,-(a7)      *Fclose-GEMDOS-Funktion
                trap    #1              *GEMDOS-Aufruf
                addq.l  #4,a7           *Stapelzeiger korrigieren
                move.w  (a7)+,d0        *Fehlercode zurÅckholen

nl_end:         movem.l (a7)+,d7/a0-a1  *Register zurÅckholen
                rts                     *RÅckkehr
