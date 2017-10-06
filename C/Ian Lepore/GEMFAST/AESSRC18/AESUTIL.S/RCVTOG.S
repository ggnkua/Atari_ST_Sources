;*************************************************************************
;* RCVTOG.S - Convert VRECT to GRECT.
;*************************************************************************

_rc_vtog::

          .cargs    #4,.pvrect.l,.pgrect.l
          
          move.l    .pvrect(sp),a0
          move.l    .pgrect(sp),a1
          move.l    a1,d0               ; return pgrect

          move.l    (a0),(a1)
          
          move.w    4(a0),d1
          sub.w     (a0),d1
          addq.w    #1,d1
          move.w    d1,4(a1)
          
          move.w    6(a0),d1
          sub.w     2(a0),d1
          addq.w    #1,d1
          move.w    d1,6(a1)
          
          rts

