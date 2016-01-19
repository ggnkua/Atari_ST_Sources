* Byte-Poke:  lpoke(adresse,wert);
* <wert> muû als Integer Åbergeben werden !

.text
.xdef _bpoke
_bpoke:         move.l  4(a7),adress
                move.w  8(a7),wert
                pea     bpos            *Adresse der Routine
                move.w  #38,-(a7)       *Superexec
                trap    #14
                addq.l  #6,a7           *Stackkorrektur
                rts

bpos:           move.l  adress,a0       *Zeiger
                move.b  wert+1,(a0)       *Wert schreiben
                rts

.bss
adress:         ds.l    1
wert:           ds.w    1
