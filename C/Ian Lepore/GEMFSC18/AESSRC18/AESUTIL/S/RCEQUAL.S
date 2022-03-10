;=========================================================================
; rc_equal
;=========================================================================

_rc_equal::
          .cargs    #4,.psrce.l,.pdest.l
          move.l    .psrce(sp),a0
          move.l    .pdest(sp),a1

          moveq.l   #0,d0               ; Assume not equal
          cmp.l     (a0)+,(a1)+
          bne.s     .notequal
          cmp.l     (a0)+,(a1)+
          bne.s     .notequal
          moveq.l   #1,d0
.notequal:
          tst.w     d0                  ; insure CCR return matches d0.
          rts

