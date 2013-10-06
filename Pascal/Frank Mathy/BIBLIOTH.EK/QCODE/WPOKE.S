* Wort-Poke: poke(adresse,wert);

.text
.xdef _poke
_poke:          move.l  4(a7),adress
                move.w  8(a7),wert
                pea     wpos            *Adresse der Routine
                move.w  #38,-(a7)       *Superexec
                trap    #14
                addq.l  #6,a7           *Stackkorrektur
                rts

wpos:           move.l  adress,a0       *Zeiger
                move.w  wert,(a0)       *Wert schreiben
                rts

.bss
adress:         ds.l    1
wert:           ds.w    1
