#ifdef __ACK__
.sect .text
.sect .rom
.sect .data
.sect .bss
.define endtext, enddata, endbss
.sect .text
.align 2
endtext:
.sect .data
.align 2
enddata:
.sect .bss
.align 2
endbss:
!.sect .end ! only for declaration of _end, __end and endbss.
! NO!, __end is defined in ncrtso.s
!_end:
#endif /* __ACK__ */
