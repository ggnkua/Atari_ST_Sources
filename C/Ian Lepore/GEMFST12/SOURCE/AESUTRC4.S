
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

;*************************************************************************
;*
;* AESUTRC1.S - Rectangle utilities 4 of 4.
;*  Utility routines involving non-standard rectangle calcs...
;*
;*************************************************************************

;-------------------------------------------------------------------------
; rc_vtog - Convert VRECT to GRECT.
;-------------------------------------------------------------------------

_rc_vtog::

          .cargs    #4,.pvrect.l,.pgrect.l
          
          move.l    .pvrect(sp),a0
          move.l    .pgrect(sp),a1

          move.l    (a0),(a1)
          
          move.w    4(a0),d0
          sub.w     (a0),d0
          move.w    d0,4(a1)
          
          move.w    6(a0),d0
          sub.w     2(a0),d0
          move.w    d0,6(a1)
          
          rts

;-------------------------------------------------------------------------
; rc_gtov - Convert GRECT to VRECT.
;-------------------------------------------------------------------------

_rc_gtov::

          .cargs    #4,.pgrect.l,.pvrect.l
          
          move.l    .pgrect(sp),a0
          move.l    .pvrect(sp),a1
          
          move.w    (a0),d0
          move.w    d0,(a1)

          add.w     4(a0),d0
          move.w    d0,4(a1)

          move.w    2(a0),d0
          move.w    d0,2(a1)

          add.w     6(a0),d0
          move.w    d0,6(a1)
          
          rts
          
;         end of code


