; file: hr_show.asm
;
;============================================================================
;
; hr_show
; =======
;
; Input: following 68000-C convention:
;       L address of 64000 bytes intermediate format file
;       L address of 32000 bytes low-res graphic
;       L address of 16 bytes conversion table
;         (pattern numbers sorted by colour values)
; Output: --
;
; Changed registers:   01234567
;                     D:-------
;                     A--------
;
;

             .CARGS #10*4+4,sadr.l,tadr.l,coltab.l
             .TEXT
hr_show:     movem.l    d1-d6/a0-a3,-(sp)
             movea.l    sadr(sp),a0
             movea.l    tadr(sp),a1
             movea.l    coltab(sp),a2
             lea.l      pattab1(pc),a3

             moveq.l    #0,d5              ;define contents of d5
             move.w     #199,d0            ;double lines counter
.nxtline:    moveq.l    #39,d1             ;words per line counter
.nxtwrd:     moveq.l    #0,d3
             moveq.l    #0,d4
             moveq.l    #7,d2              ;cells per word counter
.fillwrd:    move.b     (a0)+,d5           ;read colour code
             move.b     0(a2,d5.w),d5      ;translate into pattern code
             move.b     0(a3,d5.w),d6      ;load upper byte pattern
             add.b      d6,d6              ;   and append to word
             roxl.w     #1,d3
             add.b      d6,d6
             roxl.w     #1,d3
             move.b     pattab2-pattab1(a3,d5.w),d6   ;load lower byte patterne
             add.b      d6,d6              ;  and treat same as upper byte
             roxl.w     #1,d4
             add.b      d6,d6
             roxl.w     #1,d4
             dbf        d2,.fillwrd
             move.w     d4,80(a1)          ;fill second line of pair
             move.w     d3,(a1)+           ;fill first line of pair
             dbf        d1,.nxtwrd
             lea.l      80(a1),a1
             dbf        d0,.nxtline

             movem.l    (sp)+,d1-d6/a0-a3
             rts


pattab1:    .DC.b %00000000               ;Pattern 0
             .DC.b %10000000               ;        1
             .DC.b %01000000               ;        2
             .DC.b %00000000               ;        3
             .DC.b %00000000               ;        4
             .DC.b %11000000               ;        5
             .DC.b %00000000               ;        6
             .DC.b %10000000               ;        7
             .DC.b %01000000               ;        8
             .DC.b %10000000               ;        9
             .DC.b %01000000               ;        A
             .DC.b %11000000               ;        B
             .DC.b %01000000               ;        C
             .DC.b %10000000               ;        D
             .DC.b %11000000               ;        E
             .DC.b %11000000               ;        F

pattab2:    .DC.b %00000000               ;Pattern 0
             .DC.b %00000000               ;        1
             .DC.b %00000000               ;        2
             .DC.b %10000000               ;        3
             .DC.b %01000000               ;        4
             .DC.b %00000000               ;        5
             .DC.b %11000000               ;        6
             .DC.b %10000000               ;        7
             .DC.b %01000000               ;        8
             .DC.b %01000000               ;        9
             .DC.b %10000000               ;        A
             .DC.b %01000000               ;        B
             .DC.b %11000000               ;        C
             .DC.b %11000000               ;        D
             .DC.b %01000000               ;        E
             .DC.b %11000000               ;        F

             .END
