; File: hr_64000.asm;
;============================================================================
;
; hr64000
; =======
;Input: following 64000-C convention:
;       L address of 32000 bytes low-res graphic
;       L address of 64000 bytes intermediate file
;Output: --
;
; Changed registers:   01234567
;                     D:-------
;                     A--------
;
             .CARGS #8*4+4,src.l,dest.l
hr64000:     movem.l   d1-d4/d7/a0-a2,-(sp)
             movea.l   src(sp),a0
             lea.l     80(a0),a1
             movea.l   dest(sp),a2

             move.w    #199,d0              ;Number of double lines -1
             moveq.l   #0,d7

.line:       moveq.l   #39,d1               ;Run through line

.step:       move.w    (a0)+,d3             ;Process line
             move.w    (a1)+,d4
             moveq.l   #7,d2

.square:     moveq.l   #0,d5                ;set bit counter to zero
             add.w     d3,d3                ;test bits in square
             addx.w    d7,d5                ;and add them up
             add.w     d3,d3
             addx.w    d7,d5
             add.w     d4,d4
             addx.w    d7,d5
             add.w     d4,d4
             addx.w    d7,d5
             move.b    d5,(a2)+             ;write number of bits
             dbf       d2,.square           ;continue with next bits
             dbf       d1,.step             ;rest of line
             lea.l     80(a0),a0            ;next double line
             lea.l     80(a1),a1
             dbf       d0,.line

             movem.l   (sp)+,d1-d4/d7/a0-a2
             rts       

             .END 
