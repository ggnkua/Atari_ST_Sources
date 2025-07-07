
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

;*************************************************************************
;*
;* AESUTRC2.S - Rectangle utilities 2 of 4.
;*  Utility routines involving the standard rectangle calcs...
;*
;*************************************************************************

;-------------------------------------------------------------------------
; rc_intersect
;-------------------------------------------------------------------------

_rc_intersect::
          move.l    4(sp),a1 
          move.l    8(sp),a0 
          movem.l   d4-d7,-(sp)
                                        ; Calc right-side x...
          move.w    (a1),d1             ;  rx1 = x1 + w1 
          add.w     4(a1),d1            
          move.w    (a0),d7             ;  rx2 = x2 + w2
          add.w     4(a0),d7            
          cmp.w     d1,d7               ;  compare rx1 <-> rx2
          blt.s     .gotrx              ;  proper rx is the smaller
          move.w    d1,d7               ;  of the two.
.gotrx:   
                                        ; Calc bottom y...
          move.w    2(a1),d1            ;  by1 = y1 + h1
          add.w     6(a1),d1            
          move.w    2(a0),d6            ;  by2 = y2 + h2
          add.w     6(a0),d6            
          cmp.w     d1,d6               ;  compare by1 <-> by2
          blt.s     .gotby              ;  proper by is the smaller
          move.w    d1,d6               ;  of the two.       
.gotby:                                 
                                        ; Calc left-side x...
          move.w    (a0),d5             ;  assume x2
          cmp.w     (a1),d5             ;  compare x1 <-> x2  
          bge.s     .gotlx              ;  proper lx is smaller
          move.w    (a1),d5             ;  of the two.
.gotlx:                                 
                                        ; Calc top y...
          move.w    2(a0),d4            ;  assume y2
          cmp.w     2(a1),d4            ;  compare y1 <-> y2 
          bge.s     .gotty              ;  proper ty is smaller
          move.w    2(a1),d4            ;  of the two.
.gotty:
                                        ; Got all the x/y's...
          move.w    d5,(a0)+            ; store left x
          move.w    d4,(a0)+            ; store top y
          sub.w     d5,d7               ; compute width
          move.w    d7,(a0)+            ; store it
          sub.w     d4,d6               ; compute height
          move.w    d6,(a0)+            ; store it
          moveq.l   #1,d0               ; assume intersect true
          or.w      d6,d7               ; OR the width & height, if either
          bpl.s     .done               ; was negative, the intersection
          moveq.l   #0,d0               ; was false.             
.done:
          movem.l   (sp)+,d4-d7
          tst.w     d0                  ; insure CCR return matches d0.
          rts

