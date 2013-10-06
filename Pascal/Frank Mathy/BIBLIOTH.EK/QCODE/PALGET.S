* GetPalette - Holen der aktuellen Farbpalette
* Aufruf: palget(<palette>);
* <palette> ist der Zeiger auf ein 16-Worte-Array

.text
.xdef _palget
_palget:        move.l  4(a7),plg_data  *Zeiger auf Array
                pea     plg_j1          *Adresse der Routine
                move.w  #38,-(a7)       *superexec
                trap    #14             *XBIOS
                addq.l  #6,a7
                rts

plg_j1:         lea     $ff8240,a0      *Zeiger auf Palette
                move.l  plg_data,a1     *Zeiger auf Array
                move.w  #7,d0           *8 Langworte
plg_j2:         move.l  (a0)+,(a1)      *Wert kopieren
                and.l   #$7770777,(a1)+ *Nur wichtige Bits
                dbra    d0,plg_j2       *Schleife
                rts
.bss
plg_data:       ds.l    1

