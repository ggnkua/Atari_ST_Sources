; file: finescr3.asm (Part 1)
;
             .INCLUDE 'ATARI.IS'

scroll:      movem.l   a0/a1,-(sp)          ; save CPU registers used
             Physbase                       ; where is the screen
             movea.l   d0,a1                ; to a1
             move.w    12(sp),d0            ; fetch number of lines var.
             mulu.w    #80,d0               ; convert to bytes (Line*80)
             lea.l     0(a1,d0.w),a0        ; load a1+d0 to a0
             neg.l     d0                   ; -d0+32000 is the block
             addi.l    #32000,d0
             bsr       qcopy                ; call subroutine qcopy here

             movem.l   (sp)+,a0/a1          ; restore CPU registers
             rts                            ; and back to BASIC


; file: finescr3.asm (Part 2)
;==========================================================================
;
;qcopy       Quick copy of a memory block
;
;
; Input:
;  a0: Address of source block
;  a1: Address of destination block
;  d0: Length of block in bytes (0<= Length <= 3,145,727)
;  d0 is not checked for correct length!
;
; Output:
; a0,a1: Point to byte behind relevant block
;
; registers changed:
;  D 1,2,3,4,5,6,7
;  A 2,3,4,5,6,7
qcopy:       movem.l   d1-d7/a2-a6,-(sp)    ;save registers
             move.w    a0,d1                ;check orientation of blocks
             move.w    a1,d2                ; different  ==>copy bytes
             andi.w    #1,d1                ; both odd ==>one byte, then ,as if odd
             andi.w    #1,d2                ; both even copy blocks
             eor.w     d1,d2
             bne       .copybytes
             tst.w     d1
             beq       .copyeven
.copyodd:    move.b    (a0)+,(a1)+          ;odd address: copy one byte
             subq.w    #1,d0                ;adapt counter
             beq       .done                ;and test for end
.copyeven:   divu.w    #12*4,d0             ;even address: copy blocks of 48 bytes
             bra       .vlcpy               ;downward loop
.vlloop:     movem.l   (a0)+,d1-d7/a2-a6    ;Loop transfers 48 bytes at a time
             movem.l   d1-d7/a2-a6,(a1)     ;Simulates writing with
             lea.l     12*4(a1),a1          ;postincrement
.vlcpy:      dbf       d0,.vlloop           ;
             swap.w    d0                   ;look at remainder of division
             ext.l     d0                   ;extend to whole register
             ror.l     #2,d0                ;division by 4, remainder in bit 30,31
             bra       .lcpy                ;downward loop
.lloop:      move.l    (a0)+,(a1)+          ;counter div 4 copy longs
.lcpy:       dbf       d0,.lloop
.word:       lsl.l     #1,d0                ; Is remainder a word?
             bcc       .byte                ; no, then perhaps byte
             move.w    (a0)+,(a1)+          ; yes, then copy word
.byte:       tst.l     d0                   ; Is remainder byte?
             bpl       .done                ; no, then finished
             move.b    (a0)+,(a1)+          ; yes, then copy it
             bra       .done
;
; Blocks are of different orientation, so byte access is used.
; Optimisation not worth the effort as case too rare.
;
.copybytes:  bra       .btst                ; move memory block in bytes, as otherwise
.bloop:      move.b    (a0)+,(a1)+          ; an address error occurs
.btst:       dbf       d0,.bloop            ; here loop lower word
             swap.w    d0                   ; look at higher part
             subq.w    #1,d0                ; also decrement
             bcs       .done                ; <0, then finished
             swap.w    d0                   ; else: restore order
             bra       .bloop               ; and repeat inner loop
.done:       movem.l   (sp)+,d1-d7/a2-a6    ; finished.
             rts                            ; then back.

