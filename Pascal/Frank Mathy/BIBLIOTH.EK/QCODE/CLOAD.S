* Dekompaktier-Laderoutine
* Aufruf: cload("name",start,bytes,palette)
* <palette> zeigt auf die Farbpalette
* palette == 0  --> Keine Farbpalette wird geladen

.text
.xdef _cload
_cload:         movem.l d1-d7/a0-a6,-(a7)       *Register retten

                clr.w   -(a7)           *Datei nur lesen
                move.l  62(a7),-(a7)    *Dateiname
                move.w  #$3d,-(a7)      *Open-Funktion
                trap    #1              *GEMDOS-Funktion
                addq.l  #8,a7
                tst.w   d0              *Fehler ?
                bmi     l_exit          *Ja --> Ende
                move.w  d0,cp_handle    *Datei-Handle merken

cl_pal:         move.l  72(a7),d7       *Zeiger auf Palette
                beq.s   cl_j0           *Nicht laden --> Weiter

                move.l  d7,-(a7)        *Adresse des Puffers
                move.l  #32,-(a7)       *32 Bytes lesen
                move.w  cp_handle,-(a7) *Dateihandle
                move.w  #$3f,-(a7)      *FREAD-Funktionsnummer
                trap    #1              *GEMDOS-Aufruf
                add.l   #12,a7          *Stapelkorrektur
                tst.w   d0              *Fehler ?
                bmi     l_exit          *Ja --> Ende

cl_j0:          pea     cp_buffer         *Pufferadresse
                move.l  #512,-(a7)        *Einen Sektor lesen
                move.w  cp_handle,-(a7)   *Datei-Handle
                move.w  #$3f,-(a7)        *Read-Funktion
                trap    #1                *GEMDOS
                adda.l  #12,a7            *Stapelkorrektur
                tst.w   d0                *Fehler ?
                bmi     l_exit            *Ja --> Ende

                movea.l 64(a7),a6       *Startadresse
                move.l  68(a7),d2       *QuellbytezÑhler
                lea     cp_buffer,a5    *Zeiger auf Dateipuffer

                move.w  #2,d1           *ZÑhler fÅr aus Puffer gelesene Bytes
                move.w  (a5)+,d4        *Wert laden
                move.b  #15,d3          *ZÑhler fÅr Bits/Wort

cl_j1:          bsr.s   code_wort       *Lo-Nibble holen
                move.w  d5,(a6)+        *merken
                subq.l  #2,d2           *ZÑhler erniedrigen
                bne.s   cl_j1           *In Schleife

l_close:        move.l  d0,-(a7)                *Fehlercode retten
                move.w  cp_handle,-(a7)         *Dateihandle
                move.w  #$3e,-(a7)              *Fclose
                trap    #1                      *Gemdos
                addq.l  #4,a7                   *Stapelkorrektur
                move.l  (a7)+,d0                *Fehlercode holen

l_exit:         movem.l (a7)+,d1-d7/a0-a6
                rts

* Code -> Nibble - Routine.
* Ergebnisparameter:    D5 -> Geholtes Nibble

code_wort:      btst    #15,d4          *Bit 15 = 0 ?
                bne.s   cw_j1           *Nein --> Weiter

                clr.w   d5              *Wort = 0
                clr.w   d6              *1 Bit
                bra.s   schieben        *Schieben und Ende

cw_j1:          btst    #14,d4          *Bit 14 = 0 ?
                bne.s   cw_j2           *Nein --> Weiter

                move.w  #$ffff,d5       *Wort = $ffff
                move.w  #1,d6           *1 Bit
                bra.s   schieben        *Schieben und Ende

cw_j2:          move.w  #1,d6           *2 Bits rotieren
                bsr.s   schieben        *Aufrufen
                move.w  d4,d5           *Wert nach d5
                move.w  #15,d6          *16 Bits rotieren

schieben:       move.w  (a5),d0
cn_j3:          roxl.w  #1,d0           *Linksrotieren
                roxl.w  #1,d4           *Wert linksrotieren
                dbra    d3,cn_j4        *BitzÑhler erniedrigen und ggf. weiter

                move.w  #15,d3          *ZÑhler zurÅcksetzen
                addq.l  #2,a5
                move.w  (a5),d0         *Neuen Wert laden
                addq.w  #2,d1           *Erhîhe ZÑhler fÅr Pufferbyte
                cmp.w   #512,d1         *d1=512 ?
                bne.s   cn_j4           *Nein --> Weiter

                movem.l d0-d2/a0-a2,-(a7)
                move.l  #cp_buffer,-(a7)  *Pufferadresse
                move.l  #512,-(a7)        *Einen Sektor lesen
                move.w  cp_handle,-(a7)   *Datei-Handle
                move.w  #$3f,-(a7)        *Read-Funktion
                trap    #1                *GEMDOS
                adda.l  #12,a7            *Stapelkorrektur

                tst.w   d0                *Fehler aufgetreten ?
                bpl.s   r_ok              *Nein --> Weiter

                add.l   #28,a7            *Stapelkorrektur
                bra     l_close           *Abbruch

r_ok:           movem.l (a7)+,d0-d2/a0-a2
                clr.w   d1                *ZÑhler fÅr Pufferbyte lîschen
                move.l  #cp_buffer,a5
                move.w  (a5),d0

cn_j4:          dbra    d6,cn_j3        *In Schleife
                move.w  d0,(a5)         *Wert zurÅckschreiben
                clr.l   d0              *Kein Fehler
                rts                     *Ende

* Notwendige Puffer

.even
.bss
cp_buffer:      .ds.b   512             *Speicherbuffer
.even
cp_handle:      .ds.w   1               *Datei-Handle
cp_fname:       .ds.l   1               *Dateiname
cp_start:       .ds.l   1               *Startadresse
cp_length       .ds.l   1               *LÑnge
.even
