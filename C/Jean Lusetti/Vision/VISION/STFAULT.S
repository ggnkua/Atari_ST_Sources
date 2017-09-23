
    .EXPORT stack_fault


**************************
* void stack_fault(void) *
**************************
stack_fault:
    SUBA.L  #5,SP
    RTS                 ; BOUM !
