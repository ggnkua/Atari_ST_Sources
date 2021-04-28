; file: 90_ass.asm
;

linesize     equ 80    ;bytes per line



;----------------------------------------------
;These macros are only for convenience;
;less typing means fewer errors

             .MACRO strst num
             move.b    -1(a0,d7.w),{"D",\num}
             .IF \num<>7
             add.w     a3,d7
             .ENDIF 
             .ENDM 

             .MACRO rot num
             lsr       #1,{"D",\num}
             roxl.b    #1,d7
             .ENDM 
;------------------------------------------------




;============================================================================
;
; 90_ass
; ======
;Input: following 68000-C conventions:
;       L address of source bitmap
;       L address of destination bitmap
;       W Width of bitmap
;       W Height of bitmap
;       Output: --
;
;Registers changed: 01234567
;                  D--------
;                  A--------
;


             .CARGS #13*4+4,source.l,dest.l,width.w,height.w
             .TEXT 
entry:       movem.l   d1-d7/a0-a5,-(sp)

             movea.l   source(sp),a0        ;a0: source address
             movea.l   dest(sp),a1          ;a1: destination address
             move.w    height(sp),d0        ;a2: height div 8
             lsr.w     #3,d0                ;a3: width div 8
             movea.w   d0,a2                ;a4: width
             move.w    width(sp),d1         ;a5: -(<height div 8> * width)
             movea.w   d1,a4
             mulu.w    d1,d0
             neg.w     d0
             movea.w   d0,a5
             lsr.w     #3,d1
             movea.w   d1,a3

             move.w    a2,d0                ;init strip counter
             bra       .vloop
.dostrip:    swap.w    d0

             move.w    a3,d1                ;init byte counter
             lea.l     0(a0,a3.w),a0
             bra       .hloop
.dobyte:     swap.w    d1

             move.w    a3,d7                ;beginning with first row
             strst     1                    ;load the relevant bytes
             strst     2
             strst     3
             strst     4
             strst     5
             strst     6
             strst     7
             move.b    -(a0),d0             ;row 0 with special treatment

             swap.w    d7                   ;save bytes
             swap.w    d2
             move.w    #7,d2                ;init byte counter (7..0)

.dobit:      swap.w    d2                   ;save bit counter

             rot       0                    ;build byte with lowest bits of Dn
             rot       1
             rot       2
             rot       3
             rot       4
             rot       5
             rot       6
             swap.w    d7                   ;  d7 is special
             lsr.b     #1,d7
             swap.w    d7
             roxl.b    #1,d7
             move.b    d7,(a1)

             adda.w    a2,a1                ;  90 degrees: source left ==> destination lower

             swap.w    d2                   ;loop more bits
             dbf       d2,.dobit

             swap.w    d1                   ;loop more bytes in strip
.hloop:      dbf       d1,.dobyte

             adda.w    a4,a0                ;correct pointers
             lea.l     1(a1,a5.w),a1

             swap.w    d0                   ;loop fewer strips
.vloop:      dbf       d0,.dostrip

             movem.l   (sp)+,d1-d7/a0-a5    ;finished
             rts       


             .END 
