; file finescr2.asm
;
; an example of fine screen scrolling
;
;
             .INCLUDE 'ATARI.IS'            ;include some definitions

scrollup:    movem.l   d0/a0,-(sp)          ;use variables d0, a0
             Physbase                       ;determine start of screen memory

             movea.l   d0,a0                ;address to address register
             move.w    #1,d0                ;set loop counter d0
loop:        move.l    80(a0),(a0)          ;move long word
             adda.w    #4,a0                ;increment pointer
             addi.w    #1,d0                ;increment counting variable
             cmpi.w    #8000-20,d0          ;testing
             bcs       loop                 ;7980 < d0, then repeat

             movem.l   (sp)+,d0/a0          ;restore processor variables
             rts                            ;and return
             .END                           ;indicates end of file to assembler
