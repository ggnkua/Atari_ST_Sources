;*************************************************************************
;* RCINTERS.S - Calc intersection of two GRECT rectangles.
;*************************************************************************

_rc_intersect::
          move.l    4(sp),a1 
          move.l    8(sp),a0 
          movem.l   d3-d4,-(sp)
                                        ; Calc right-side x...
          move.w    (a1),d0             ;  rx1 = x1 + w1 
          add.w     4(a1),d0            
          move.w    (a0),d1             ;  rx2 = x2 + w2
          add.w     4(a0),d1            
          cmp.w     d0,d1               ;  compare rx1 <-> rx2
          blt.s     .gotrx              ;  proper rx is the smaller
          move.w    d0,d1               ;  of the two.
.gotrx:   
                                        ; Calc bottom y...
          move.w    2(a1),d0            ;  by1 = y1 + h1
          add.w     6(a1),d0            
          move.w    2(a0),d2            ;  by2 = y2 + h2
          add.w     6(a0),d2            
          cmp.w     d0,d2               ;  compare by1 <-> by2
          blt.s     .gotby              ;  proper by is the smaller
          move.w    d0,d2               ;  of the two.       
.gotby:                                 
                                        ; Calc left-side x...
          move.w    (a0),d3             ;  assume x2
          cmp.w     (a1),d3             ;  compare x1 <-> x2  
          bge.s     .gotlx              ;  proper lx is larger
          move.w    (a1),d3             ;  of the two.
.gotlx:                                 
                                        ; Calc top y...
          move.w    2(a0),d4            ;  assume y2
          cmp.w     2(a1),d4            ;  compare y1 <-> y2 
          bge.s     .gotty              ;  proper ty is larger
          move.w    2(a1),d4            ;  of the two.
.gotty:
                                        ; Got all the x/y's...
          moveq.l   #0,d0               ; Assume intersection is false.             
          move.w    d3,(a0)+            ; store left x
          move.w    d4,(a0)+            ; store top y
          sub.w     d3,d1               ; compute width
          ble.s     .done               ; if negative or zero, no intersect
          move.w    d1,(a0)+            ; else store it
          sub.w     d4,d2               ; compute height
          ble.s     .done               ; if negative or zero, no intersect
          move.w    d2,(a0)+            ; else store it
          moveq.l   #1,d0               ; intersection is true 
.done:
          movem.l   (sp)+,d3-d4
          tst.w     d0                  ; insure CCR return matches d0.
          rts

