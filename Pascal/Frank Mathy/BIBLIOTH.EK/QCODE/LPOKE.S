* Langwort-Poke:  lpoke(adresse,wert);

.text
.xdef _lpoke
_lpoke:         move.l  4(a7),adress
                move.l  8(a7),wert
                pea     lpos            *Adresse der Routine
                move.w  #38,-(a7)       *Superexec
                trap    #14
                addq.l  #6,a7           *Stackkorrektur
                rts

lpos:           move.l  adress,a0       *Zeiger
                move.l  wert,(a0)       *Wert schreiben
                rts

.bss
adress:         ds.l    1
wert:           ds.l    1
