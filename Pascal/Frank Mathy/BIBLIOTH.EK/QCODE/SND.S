.text
.xdef _setheight
_setheight:     move.w  4(a7),par1      *Kanal merken
                move.w  6(a7),par2      *Frequenz merken
                pea     hset            *Adresse der Routine
                move.w  #38,-(a7)       *'Superexec'-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stapelkorrektur
                rts                     *Rckkehr

hset:           move.w  sr,d0           *Statusregister laden
                move.w  d0,d1           *Merken
                or.w    #$700,d0        *Exceptions ausschalten
                move.w  d0,sr           *Setzen
                move.w  par1,d0         *Kanalnummer
                asl.b   #1,d0           *Mal 2
                move.b  d0,$ff8800      *Low-Register
                move.b  par2+1,$ff8802  *Daten schreiben
                addq.b  #1,d0           *High-Register
                move.b  d0,$ff8800      *Register w„hlen
                move.b  par2,$ff8802    *Daten schreiben
                move.w  d1,sr           *Exceptions aktivieren
                rts

.xdef _setfreq
_setfreq:       move.l  #125000,d0      *Basisfrequenz laden
                divu    6(a7),d0        *Wert errechnen
                move.w  d0,par2         *Wert merken
                move.w  4(a7),par1      *Kanalnummer
                pea     hset            *Adresse der Routine
                move.w  #38,-(a7)       *'Superexec'-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stapelkorrektur
                rts                     *Rckkehr

.xdef _setcurve
_setcurve:      move.w  4(a7),par1      *Hllkurvenform
                pea     cvset           *Adresse der Routine
                move.w  #38,-(a7)       *'Superexec'-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stapelkorrektur
                rts                     *Rckkehr

cvset:          move.w  sr,d0           *Statusregister
                move.w  d0,d1           *Merken
                or.w    #$700,d0        *Exceptions aus
                move.w  d0,sr           *Setzen
                move.b  #13,$ff8800     *Registernummer
                move.b  par1+1,$ff8802  *Form setzen
                move.w  d1,sr           *Exceptions ein
                rts

.xdef _setcfreq
_setcfreq:      move.w  4(a7),par1      *Frequenzwert
                pea     cfset           *Adresse der Routine
                move.w  #38,-(a7)       *'Superexec'-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stapelkorrektur
                rts                     *Rckkehr

cfset:          move.w  sr,d0           *Statusregister
                move.w  d0,d1           *Merken
                or.w    #$700,d0        *Exceptions aus
                move.w  d0,sr           *Setzen
                move.b  #11,$ff8800     *Low-Register
                move.b  par1+1,$ff8802  *Setzen
                move.b  #12,$ff8800     *High-Register
                move.b  par1,$ff8802    *Setzen
                move.w  d1,sr           *Exceptions ein
                rts

.xdef _setnoise
_setnoise:      move.w  4(a7),par1      *Frequenzwert
                pea     nsset           *Adresse der Routine
                move.w  #38,-(a7)       *'Superexec'-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stapelkorrektur
                rts                     *Rckkehr

nsset:          move.w  sr,d0           *Statusregister
                move.w  d0,d1           *Merken
                or.w    #$700,d0        *Exceptions aus
                move.w  d0,sr           *Setzen
                move.b  #6,$ff8800      *Low-Register
                move.b  par1+1,$ff8802  *Setzen
                move.w  d1,sr           *Zurcksetzen
                rts

.xdef _setvoice
_setvoice:      move.w  4(a7),par1      *Kanalnummer
                move.w  6(a7),par2      *Modus
                pea     vcset           *Adresse der Routine
                move.w  #38,-(a7)       *'Superexec'-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stapelkorrektur
                rts                     *Rckkehr

vcset:          move.w  sr,d0           *Statusregister
                move.w  d0,d3           *Merken
                or.w    #$700,d0        *Exceptions aus
                move.w  d0,sr           *Setzen

                move.b  #7,$ff8800      *Register 7 w„hlen
                move.b  $ff8800,d0      *Bisherigen Inhalt lesen
                move.w  par1,d1         *Kanalnummer laden
                move.w  par2,d2         *Modus laden

                btst    #0,d2           *Tongenerator ein ?
                bne.s   vc_j1           *Ja --> Weiter
                bset    d1,d0           *Bit setzen
                bra.s   vc_j2           *Weiter
vc_j1:          bclr    d1,d0           *Bit l”schen
vc_j2:          addq.w  #3,d1           *Bits 3-5
                btst    #1,d2           *Rauschgenerator ein ?
                bne.s   vc_j3           *Ja --> Weiter
                bset    d1,d0           *Bit setzen
                bra.s   vc_j4           *Weiter
vc_j3:          bclr    d1,d0           *Bit l”schen
vc_j4:          move.b  #7,$ff8800      *Register 7 w„hlen
                move.b  d0,$ff8802      *Neuen Inhalt schreiben

                move.w  d3,sr           *Exceptions ein
                rts                     *Fertig

.xdef _setloud
_setloud:       move.w  4(a7),par1      *Kanalnummer
                move.w  6(a7),par2      *Lautst„rke
                pea     ldset           *Adresse der Routine
                move.w  #38,-(a7)       *'Superexec'-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stapelkorrektur
                rts                     *Rckkehr

ldset:          move.w  sr,d0           *Statusregister
                move.w  d0,d1           *Merken
                or.w    #$700,d0        *Exceptions aus
                move.w  d0,sr           *Setzen
                move.w  #8,d0           *Lautst„rkeregister A
                add.w   par1,d0         *Kanalnummer addieren
                move.b  d0,$ff8800      *Register anw„hlen
                move.b  par2+1,$ff8802  *Lautst„rke setzen
                move.w  d1,sr           *Zurcksetzen
                rts

.xdef _fsound
_fsound:        move.w  4(a7),var1      *Kanalnummer
                move.l  #125000,d0      *Basisfrequenz
                divu    6(a7),d0        *Durch Frequenz teilen
                move.w  d0,var2         *Wert setzen
                bra.s   sound1          *Weiter

.xdef _sound
_sound:         move.l  4(a7),var1      *Kanalnummer und Tonh”he
sound1:         move.l  8(a7),var3      *Lautst„rke, Kanalwahl

                pea     jsound          *Adresse der Routine
                move.w  #38,-(a7)       *'Superexec'-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stapelkorrektur
                rts

jsound:         move.l  var1,par1       *Kanalnummer und Tonh”he
                bsr     hset            *setzen

                move.w  var3,par2       *Lautst„rke
                bsr     ldset           *setzen

                move.w  var4,par2       *Modus
                bra     vcset           *setzen

.xdef _pause
_pause:         move.w  4(a7),par1      *Wert merken
                pea     ps_j1           *Startadresse
                move.w  #38,-(a7)       *'Superexec'-Routine
                trap    #14             *XBIOS-Aufruf
                addq.l  #6,a7           *Stapelkorrektur
                rts

ps_j1           move.w  par1,d0         *Wartezeit
                ext.l   d0              *Auf Langwort erweitern
                add.l   $4ba,d0         *Aktuellen Timerwert addieren
ps_j2:          cmp.l   $4ba,d0         *Wert erreicht ?
                bhi.s   ps_j2           *Nein --> Zurck
                rts

.bss
par1:           ds.w    1
par2:           ds.w    1

var1:           ds.w    1
var2:           ds.w    1
var3:           ds.w    1
var4:           ds.w    1

