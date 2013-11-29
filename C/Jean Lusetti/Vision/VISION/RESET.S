
    .EXPORT reset


********************
* void reset(void) *
********************
reset:
    PEA.L    cold_reset
    MOVE.W   #$26,-(SP)
    TRAP     #$0E

cold_reset:
    MOVE.L   $4.w,A0
    JMP      (A0)


