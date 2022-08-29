;File: sine.asm

sine:   movem.l d1/a0,-(sp)     ;save used registers
        move.w  4+2*4(sp),d0    ;fetch angle from stack
        move.w  d0,d1           ;and make copy
        bpl     .square12       ;save: only 1st and 2nd square
        neg.w   d0              ;if not: mirror angle at x-axis
.square12:
        cmpi.w  #$4000,d0       ;test if 2nd square
        bcs     .index          ; no, then straight to table
        neg.w   d0              ; yes, then into table from back
        addi.w  #$7fff,d0
.index: mulu.w  #sinresol,d0    ;Calculate position of
                                ;appropriate table
        lsl.l   #1,d0           ;element: angle * number of
                                ;table elements
        swap.w  d0              ;    /2^14
        add.w   d0,d0           ;    *2 (word table)
        lea.l   sintab(pc),a0   ;fetch sine value from table
        move.w  0(a0,d0.w),d0
        lsl.w   #1,d1           ;Was angle in square 3 or 4?
        bcc     .return         ;  no, then leave
        neg.w   d0              ;  otherwise extend sine
.return:ext.1   d0              ;  to whole word
        movem.l (sp)+,d1/a0     ;so there
        rts

sintab: .IBYTES "SINE.DMP"      ;read in table calculated
                                ;in Basic
sinresol equ *-sintab           ;produces length of table in bytes

        .END
