* XBIOS-Binding, welches die Register rettet
* Wichtig bei REGISTER-Variablen in C.
* Aufruf:       wert=sxbios(...);
*               wert=sbiox(...);
*               wert=sgemdos(...);

.text
.xdef _sxbios,_sbios,_sgemdos
_sxbios:        movem.l d1-d2/a0-a2,regsave     *Register retten
                move.l  (a7)+,retsave           *Adr. merken
                trap    #14                     *XBIOS-Aufruf
                move.l  retsave,-(a7)           *Adr. holen
                movem.l regsave,d1-d2/a0-a2     *Register holen
                rts

.xdef _sbios
_sbios:         movem.l d1-d2/a0-a2,regsave     *Register retten
                move.l  (a7)+,retsave           *Adr. merken
                trap    #13                     *BIOS-Aufruf
                move.l  retsave,-(a7)           *Adr. holen
                movem.l regsave,d1-d2/a0-a2     *Register holen
                rts

.xdef _sgemdos
_sgemdos:       movem.l d1-d2/a0-a2,regsave     *Register retten
                move.l  (a7)+,retsave           *Adr. merken
                trap    #1
                move.l  retsave,-(a7)           *Adr. holen
                movem.l regsave,d1-d2/a0-a2     *Register holen
                rts

save:
.bss
regsave:        ds.l    5                       *Puffer fÅr Register
retsave:        ds.l    1                       *RÅckkehradresse

