;File: large.asm

;Input: following 68000-C conventions
;       L address of source bitmap as Atari mono screen
;       L address of destination bitmap as Atari mono screen
;       WWWW xywh: source graphic
;       WW xy: destination graphic
;       W enlargement factor


;Output: --

;Registers changed:  01234567
;                   D--------
;                   A--------

;
             .CARGS #12*4+4,src.l,dest.l,sx.w,sy.w,sw.w,sh.w,dx.w,dy.w,scal.w
             .TEXT 
zoom:        movem.l   d1-d7/a0-a2/a5/a6,-(sp)

             move.w    dx(sp),d0
             move.w    dy(sp),d1
             moveq.l   #5,d2
             bsr       cpos
             movea.l   dest(sp),a6          ;A6: start of row stamp (Byte)
             adda.l    d1,a6

             move.w    scal(sp),d7          ;D7: Scaling
             moveq.l   #1,d1                ;  corresponding stamp width

             lsl.l     d7,d1
             subq.l    #1,d1
             ror.l     d7,d1                ;move to desired position

             ror.l     d0,d1
             move.l    d1,d6                ;D6: start of row stamp
;(Bit#)
             move.w    sx(sp),d0
             move.w    sy(sp),d1
             moveq.l   #5,d2
             bsr       cpos
             movea.l   src(sp),a5           ;A5: Graphics cursor start of row (Byte)
             adda.l    d1,a5
             move.w    d0,d5                ;D5: Graphics cursor start of row (Bit#)

             moveq.l   #8,d1                ; Jump address calculated
; for vertical enlargement
             sub.w     d7,d1                ;
             move.l    #(.entry6-.entry7),d0
             mulu.w    d1,d0
             lea.l     .entry7(pc),a2
             adda.l    d0,a2                ;A2: Jump to vertical enlargement

             move.w    sh(sp),d4            ;D4: counter rows
             bra       .vloop

.zoomline:   swap.w    d4                   ;D4: counter rows/columns
             move.w    sw(sp),d4
             movea.l   a5,a0                ;a0: Graphics cursor to read
             move.w    d5,d0                ;d0: valid length input stream
             movea.l   a6,a1                ;a1: write stamp
             move.l    d6,d1                ;d1: stamp
             move.l    (a0)+,d2             ;d2: input stream (initialised here)
             lsl.l     d0,d2
             neg.w     d0                   ;  d0 as loop counter
             addi.w    #31,d0
             moveq.l   #0,d3                ;d3: output stamp
             bra       .hloop

.scan:       add.l     d2,d2                ;equivalent to ASL #1,d2
             bcc       .step
             or.l      d1,d3
.step:       ror.l     d7,d1
             bcc       .zloop
             jmp       (a2)
.entry7:     move.l    d3,7*80(a1)          ;These instructions must all have the same
.entry6:     move.l    d3,6*80(a1)          ;length as they are used to calculate jump.
             move.l    d3,5*80(a1)
             move.l    d3,4*80(a1)
             move.l    d3,3*80(a1)
             move.l    d3,2*80(a1)
             move.l    d3,1*80(a1)
             move.l    d3,(a1)+
             moveq.l   #0,d3
.zloop:      dbf       d0,.hloop
             move.l    (a0)+,d2             ;load next lot of pixels
             moveq.l   #31,d0               ;  all valid
.hloop:      dbf       d4,.scan

             jmp       .last-.entry7(a2)
.last:       move.l    d3,7*80(a1)          ;These instructions must all have the same length
             move.l    d3,6*80(a1)          ;as they are used to calculate jump.
             move.l    d3,5*80(a1)          ;Always eliminate at end of row.
             move.l    d3,4*80(a1)          ;Waste of time in the worst case
             move.l    d3,3*80(a1)          ; but the source picture can
             move.l    d3,2*80(a1)          ; have any width.
             move.l    d3,1*80(a1)
             move.l    d3,(a1)+

             swap.w    d4
             moveq.l   #80,d0
             lea.l     0(a5,d0.w),a5
             move.w    d7,d1
             mulu.w    d0,d1
             lea.l     0(a6,d1.w),a6
.vloop:      dbf       d4,.zoomline

             movem.l   (sp)+,d1-d7/a0-a2/a5/a6
             rts       



;============================================================================
;
; cpos
;Input:       d0        .w,x,coordinate
;             d1        .w,y,coordinate
;       d2.w  orientation (to 2^d2.w bits)

;Output:      d0        .w,bit,position,of,graphics,cursor
;             d1        .l,byte,offset,of,graphics,cursor

;Registers changed:  01234567
;                   D::------
;                   A--------

;This function only works with a 640*400 monochrome screen.
;The byte offset is aligned to a bit limit of 2^d2.w.
;So you should choose
;  d2.w == 3 for byte access
;  d2.w == 4 for word access
;  d2.w == 5 for long word access

;Other values are possible but make little sense.

;- The bit number in d0.w starts counting at the MSB.
;
;
cpos:        swap.w    d0                   ;erase high word
             clr.w     d0
             swap.w    d0
             ror.l     d2,d0                ;d0 := (x div 2^align) * (2^(align-3))
             subq.w    #3,d2
             lsl.w     d2,d0
             addq.w    #3,d2
             mulu.w    #80,d1               ;d1 := y * 80 + d0
             add.w     d0,d1
             clr.w     d0                   ;Position of current bit in unit of
             rol.l     d2,d0                ;  d0 := x mod 2^align
             rts       


             .END 
