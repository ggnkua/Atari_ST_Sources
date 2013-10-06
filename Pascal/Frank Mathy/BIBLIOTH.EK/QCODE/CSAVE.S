* Kompaktier- und Speicherroutine
* Speichert kompaktiert beliebige Speicherbereiche ab
* Aufruf aus C : csave("name",start,bytes,palette)
* Das Langwort <palette> zeigt auf den Palettenpuffer
* oder ist 0, wenn keine Palette gesaved werden soll.

.text
.xdef _csave
_csave:         movem.l d1-d7/a4-a6,-(a7)       *Register retten

                move.w  #0,-(a7)                *R/W-Zustand
                move.l  46(a7),-(a7)            *Dateiname
                move.w  #$3c,-(a7)              *Fcreate-Funktionsnummer
                trap    #1                      *Gemdos-Aufruf
                addq.l  #8,a7                   *Stapel korrigieren
                tst.w   d0                      *Fehler aufgetreten ?
                bmi     s_exit                  *Ja --> abbrechen
                move.w  d0,cp_handle            *Handle merken

cs_pal:         move.l  56(a7),d7               *Zeiger auf Palette
                beq.s   cs_j0                   *Keine Palette --> Weiter

                move.l  d7,-(a7)                *Pufferadresse
                move.l  #32,-(a7)               *32 Bytes schreiben
                move.w  cp_handle,-(a7)         *Dateihandle
                move.w  #$40,-(a7)              *WRITE-Funktionsnummer
                trap    #1                      *Gemdos
                add.l   #12,a7                  *Stapelkorrektur
                tst.w   d0                      *Fehler aufgetreten ?
                bmi     s_exit                  *Ja --> abbrechen

cs_j0:          movea.l 48(a7),a6               *Startadresse
                move.l  52(a7),d2               *QuellbytezÑhler
                lea     cp_buffer,a5            *Zeiger auf Dateipuffer
                clr.l   d3                      *ZÑhler fÅr Puffer
                move.b  #16,d4                  *16 Bits/Wort

cs_j1:          move.w  (a6)+,d7                *Bytewert
                bsr.s   word_code               *Wort kompaktieren
                subq.l  #2,d2
                bne.s   cs_j1                   *Schleifenende

cs_j2:          lsl.l   d4,d5                   *Letztes Langwort
                move.w  d5,(a5)                 *Sichern
                addq.l  #2,d3                   *PufferzÑhler erhîhen
                move.l  #cp_buffer,-(a7)        *Pufferadresse
                move.l  d3,-(a7)                *PufferzÑhler
                move.w  cp_handle,-(a7)         *Dateihandle
                move.w  #$40,-(a7)              *Write
                trap    #1                      *Gemdos
                add.l   #12,a7                  *Stapelkorrektur

s_close:        move.w  d0,-(a7)                *Fehlercode retten
                move.w  cp_handle,-(a7)         *Dateihandle
                move.w  #$3e,-(a7)              *Fclose
                trap    #1                      *Gemdos
                addq.l  #4,a7                   *Stapelkorrektur
                move.w  (a7)+,d0                *Fehlercode holen

s_exit:         movem.l (a7)+,d1-d7/a4-a6       *Register zurÅckholen
                rts

* Wort -> Code - Routine.
* öbergabeparameter:    D7 <- Byte mit zu Åbersetzendem Wort

word_code:      tst.w   d7              *gleich 0 ?
                bne.s   wc_j1           *Nein --> Weiter
                bclr    #31,d7          *Bit 31 lîschen
                clr.w   d6              *LÑnge == 1 Bit
                bra.s   nc_set          *Setzen

wc_j1:          cmp.w   #$ffff,d7       *gleich $ffff ?
                bne.s   wc_j2           *Nein --> Weiter
                bset    #31,d7          *Bit 31 setzen
                bclr    #30,d7          *Bit 30 lîschen
                move.w  #1,d6           *Zwei Bits
                bra.s   nc_set          *Setzen

wc_j2:          asl.l   #7,d7           *Hoch ins hîhere Wort
                asl.l   #7,d7
                bset    #31,d7          *Bit 31 setzen
                bset    #30,d7          *Bit 30 setzen
                move.w  #17,d6          *18 Bits

nc_set:         roxl.l  #1,d7           *Bit 7 -> X-Flag
                roxl.w  #1,d5           *X-Flag -> Bit 0 von d5
                subq.b  #1,d4           *d4 = d4 - 1
                bne.s   nc_j3           *d4 <> 0 --> nc_j3

                move.w  d5,(a5)+        *Pufferzeiger
                move.b  #16,d4          *ZÑhler fÅr Bits pro Wort
                addq.l  #2,d3           *ZÑhler fÅr Buffer
                cmp.l   #512,d3         *d3 == 512 ? (Buffer voll?)
                blt.s   nc_j3           *Nein --> nc_j3

                clr.l   d3                *PufferzÑhler = 0
                movea.l #cp_buffer,a5
                movem.l d0-d7/a5-a6,-(a7) *Register retten
                move.l  #cp_buffer,-(a7)  *Adresse des Puffers
                move.l  #512,-(a7)        *512 Bytes schreiben
                move.w  cp_handle,-(a7)   *Datei-Handle
                move.w  #$40,-(a7)        *Funktionsnummer schreiben
                trap    #1                *GEMDOS-Aufruf
                add.l   #12,a7            *Stapelzeiger korrigieren
                tst.w   d0                *Fehler ?
                bpl.s   wr_ok             *Nein -->Weiter

                add.l   #44,a7            *Stapelzeiger korrigieren
                bra     s_close           *Ende

wr_ok:          movem.l (a7)+,d0-d7/a5-a6 *Register zurÅckholen

nc_j3:          dbra    d6,nc_set       *d6 erniedrigen und verzweigen

                rts

* Notwendige Puffer

.bss
cp_buffer:      .ds.b   512             *Speicherbuffer
.even
cp_handle:      .ds.w   1               *Datei-Handle
cp_fname:       .ds.l   1               *Dateiname
cp_start:       .ds.l   1               *Startadresse
cp_length       .ds.l   1               *LÑnge
.even
