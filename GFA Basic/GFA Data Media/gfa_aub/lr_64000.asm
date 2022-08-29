; File: lr_64000.asm
;
;============================================================================
;lr64000 convert low resolution to intermediate format
; Input: following 68000-C convention
;       L Address of the 32000 bytes low-res graphic
;       L Address of the 64000 bytes intermediate file
; Output: --
;
; Changed registers:    01234567
;                      D:-------
;                      A--------
;
             .CARGS #8*4+4,src.l,dest.l

lr64000:     movem.l    d1-d6/a0/a1,-(sp)
             movea.l    src(sp),a0
             movea.l    dest(sp),a1

             move.w     #3999,d0           ;test 4000 units
.line:       move.w     (a0)+,d1           ;read one unit into data register
             move.w     (a0)+,d2
             move.w     (a0)+,d3
             move.w     (a0)+,d4

             moveq.l    #15,d5             ;testing the bits in one unit
.word:       moveq.l    #0,d6              ;computing the "colour value"
             add.w      d4,d4              ;  equivalent to "lsl.w #1,D4"
             roxl.w     #1,d6
             add.w      d3,d3
             roxl.w     #1,d6
             add.w      d2,d2
             roxl.w     #1,d6
             add.w      d1,d1
             roxl.w     #1,d6
             move.b     d6,(a1)+
             dbf        d5,.word           ;processing the entire unit
             dbf        d0,.line           ;processing all units

             movem.l    (sp)+,d1-d6/a0/a1
             rts

             .END
