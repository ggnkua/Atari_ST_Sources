;*************************************************************************
;* RCGTOV.S - Convert GRECT to VRECT.
;*************************************************************************

_rc_gtov::

          .cargs    #4,.pgrect.l,.pvrect.l
          
          move.l    .pgrect(sp),a0
          move.l    .pvrect(sp),a1
          move.l    a1,d0               ; return pvrect
          
          move.w    (a0)+,d1
          move.w    d1,(a1)+

          move.w    (a0)+,d2
          move.w    d2,(a1)+

          add.w     (a0)+,d1
          subq.w    #1,d1
          move.w    d1,(a1)+

          add.w     (a0),d2
          subq.w    #1,d2
          move.w    d2,(a1)
          
          rts
          
;         end of code


