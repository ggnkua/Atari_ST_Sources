;*========================================================================
; rc_copy(GRECT *source, GRECT *dest)
;*========================================================================

_rc_copy::
          .cargs    #4,.psrce.l,.pdest.l
          move.l    .psrce(sp),a0
          move.l    .pdest(sp),a1   
          move.l    a1,d0               ; return pdest
          move.l    (a0)+,(a1)+
          move.l    (a0),(a1)
          rts
          
