
    .EXPORT poke0


********************
* void poke0(void) *
********************
poke0:
    CLR.L   A0
    MOVE.L  D2,(A0)
    RTS

