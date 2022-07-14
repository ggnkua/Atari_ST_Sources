    .globl	_usbxhdi
    .globl	_xhdi_handler

    dc.l	0x27011992	// XHDIMAGIC
_usbxhdi:
    // Important: The XHDI specification requires to backup all the registers
#ifdef __mcoldfire__
    lea     -12(sp),sp
    movem.l d1/a0-a1,(sp)
#else
    movem.l d1/a0-a1,-(sp)
#endif
    pea     16(sp)
    jsr     _xhdi_handler
    addq.l  #4,sp
#ifdef __mcoldfire__
    movem.l (sp),d1/a0-a1
    lea     12(sp),sp
#else
    movem.l (sp)+,d1/a0-a1
#endif
    rts
